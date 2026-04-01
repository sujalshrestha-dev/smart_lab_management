package com.smartlab.servlet;

import com.smartlab.dao.PaymentDAO;
import com.smartlab.dao.UserDAO;
import com.smartlab.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.Duration;
import java.util.Base64;
import java.util.Properties;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final UserDAO userDAO = new UserDAO();
    private static final String ESEWA_METHOD = "ESEWA";
    private static final String KHALTI_METHOD = "KHALTI";
    private static final String ESEWA_DEFAULT_TEST_PRODUCT_CODE = "EPAYTEST";
    private static final String ESEWA_DEFAULT_TEST_SECRET = "8gBm/:&EnhH.1/q";
    private static final String ESEWA_FORM_TEST_URL = "https://rc-epay.esewa.com.np/api/epay/main/v2/form";
    private static final String ESEWA_FORM_PROD_URL = "https://epay.esewa.com.np/api/epay/main/v2/form";
    private static final String ESEWA_STATUS_TEST_URL = "https://uat.esewa.com.np/api/epay/transaction/status/";
    private static final String ESEWA_STATUS_PROD_URL = "https://epay.esewa.com.np/api/epay/transaction/status/";
    private static final String KHALTI_INITIATE_TEST_URL = "https://dev.khalti.com/api/v2/epayment/initiate/";
    private static final String KHALTI_INITIATE_PROD_URL = "https://khalti.com/api/v2/epayment/initiate/";
    private static final String KHALTI_LOOKUP_TEST_URL = "https://dev.khalti.com/api/v2/epayment/lookup/";
    private static final String KHALTI_LOOKUP_PROD_URL = "https://khalti.com/api/v2/epayment/lookup/";
    private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(12))
            .build();
    private static final Properties APP_PROPS = loadAppProperties();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login");
            return;
        }
        String action = req.getParameter("action");
        if ("statement".equalsIgnoreCase(action)) {
            handleStatement(req, resp, session);
            return;
        }
        if ("list".equalsIgnoreCase(action)) {
            handleList(req, resp, session);
            return;
        }
        if ("esewaSuccess".equalsIgnoreCase(action)) {
            handleEsewaCallback(req, resp, true);
            return;
        }
        if ("esewaFailure".equalsIgnoreCase(action)) {
            handleEsewaCallback(req, resp, false);
            return;
        }
        if ("khaltiCallback".equalsIgnoreCase(action)) {
            handleKhaltiCallback(req, resp);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/patient/payment_statement.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login");
            return;
        }

        String action = req.getParameter("action");
        if ("payNow".equalsIgnoreCase(action)) {
            handlePatientPayNow(req, resp, session);
            return;
        }

        if (!isLabStaff(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Access+denied");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int labUserId = ((Number) uid).intValue();

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=Invalid+appointment+id");
            return;
        }
        try {
            boolean ok = paymentDAO.markPaidByLab(labUserId, appointmentId);
            resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?" + (ok ? "success=Payment+marked+as+Paid" : "error=Unable+to+mark+paid"));
        } catch (SQLException ex) {
            getServletContext().log("Mark paid failed", ex);
            resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=Database+error");
        }
    }

    private void handlePatientPayNow(HttpServletRequest req, HttpServletResponse resp, HttpSession session) throws IOException {
        if (!isPatient(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Access+denied");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int patientId = ((Number) uid).intValue();

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Invalid+appointment+id");
            return;
        }

        String method = req.getParameter("paymentMethod");
        if (method == null || method.trim().isEmpty() || "CASH".equalsIgnoreCase(method)) {
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Please+select+an+online+payment+method");
            return;
        }

        if (ESEWA_METHOD.equalsIgnoreCase(method)) {
            handleEsewaInit(req, resp, patientId, appointmentId);
            return;
        }

        try {
            boolean ok = paymentDAO.submitPatientPaymentRequest(patientId, appointmentId, method);
            String successMessage = "Payment+request+submitted.+Payment+status+is+now+VERIFYING.";
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?" + (ok
                    ? "success=" + successMessage
                    : "error=Unable+to+submit+payment+request"));
        } catch (SQLException ex) {
            getServletContext().log("Patient payment submit failed", ex);
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Database+error");
        }
    }

    private void handleEsewaInit(HttpServletRequest req, HttpServletResponse resp, int patientId, int appointmentId) throws IOException {
        String transactionUuid = "APPT-" + appointmentId + "-" + UUID.randomUUID();
        BigDecimal amount;
        try {
            amount = paymentDAO.getPendingAmountForPatientAppointment(patientId, appointmentId);
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Invalid+payment+amount+for+this+appointment");
                return;
            }
            boolean prepared = paymentDAO.prepareEsewaPayment(patientId, appointmentId, transactionUuid);
            if (!prepared) {
                resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Unable+to+start+eSewa+payment");
                return;
            }
        } catch (SQLException ex) {
            getServletContext().log("Prepare eSewa payment failed", ex);
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Database+error");
            return;
        }

        String amountText = amount.stripTrailingZeros().toPlainString();
        String productCode = getConfig("ESEWA_PRODUCT_CODE", "esewa.product_code", ESEWA_DEFAULT_TEST_PRODUCT_CODE);
        String secretKey = getConfig("ESEWA_SECRET_KEY", "esewa.secret_key", ESEWA_DEFAULT_TEST_SECRET);
        String signedFields = "total_amount,transaction_uuid,product_code";
        String signatureMessage = "total_amount=" + amountText
                + ",transaction_uuid=" + transactionUuid
                + ",product_code=" + productCode;
        String signature;
        try {
            signature = hmacSha256Base64(signatureMessage, secretKey);
        } catch (Exception ex) {
            getServletContext().log("eSewa signature generation failed", ex);
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Unable+to+create+eSewa+payment+signature");
            return;
        }

        String successUrl = buildCallbackUrl(req, "esewaSuccess");
        String failureUrl = buildCallbackUrl(req, "esewaFailure");

        req.setAttribute("esewaFormUrl", getEsewaFormUrl());
        req.setAttribute("amount", amountText);
        req.setAttribute("taxAmount", "0");
        req.setAttribute("serviceCharge", "0");
        req.setAttribute("deliveryCharge", "0");
        req.setAttribute("totalAmount", amountText);
        req.setAttribute("transactionUuid", transactionUuid);
        req.setAttribute("productCode", productCode);
        req.setAttribute("successUrl", successUrl);
        req.setAttribute("failureUrl", failureUrl);
        req.setAttribute("signedFieldNames", signedFields);
        req.setAttribute("signature", signature);
        try {
            req.getRequestDispatcher("/patient/esewa_redirect.jsp").forward(req, resp);
        } catch (ServletException ex) {
            getServletContext().log("eSewa redirect page failed", ex);
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Unable+to+redirect+to+eSewa");
        }
    }

    private void handleKhaltiInit(HttpServletRequest req, HttpServletResponse resp, HttpSession session, int patientId, int appointmentId) throws IOException {
        String purchaseOrderId = "KHALTI-APPT-" + appointmentId + "-" + UUID.randomUUID();
        BigDecimal amount;
        User patient;
        try {
            amount = paymentDAO.getPendingAmountForPatientAppointment(patientId, appointmentId);
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                redirectMyAppointments(req, resp, "error", "Invalid payment amount for this appointment");
                return;
            }
            patient = userDAO.findById(patientId);
            if (patient == null) {
                redirectMyAppointments(req, resp, "error", "Unable to load patient details for Khalti");
                return;
            }
            if (isBlank(patient.getFullName()) || isBlank(patient.getEmail()) || isBlank(patient.getContactNumber())) {
                redirectMyAppointments(req, resp, "error", "Complete your profile with name, email, and contact number before paying with Khalti");
                return;
            }
            boolean prepared = paymentDAO.prepareKhaltiPayment(patientId, appointmentId, purchaseOrderId);
            if (!prepared) {
                redirectMyAppointments(req, resp, "error", "Unable to start Khalti payment");
                return;
            }
        } catch (SQLException ex) {
            getServletContext().log("Prepare Khalti payment failed", ex);
            redirectMyAppointments(req, resp, "error", "Database error");
            return;
        }

        String secretKey = getConfig("KHALTI_SECRET_KEY", "khalti.secret_key", "");
        if (secretKey.isBlank()) {
            markKhaltiFailedQuietly(purchaseOrderId);
            redirectMyAppointments(req, resp, "error", "Khalti is not configured");
            return;
        }

        long amountPaisa;
        try {
            amountPaisa = toMinorUnits(amount);
        } catch (ArithmeticException ex) {
            markKhaltiFailedQuietly(purchaseOrderId);
            getServletContext().log("Invalid Khalti amount conversion for appointment " + appointmentId, ex);
            redirectMyAppointments(req, resp, "error", "Invalid amount format for Khalti payment");
            return;
        }

        String paymentUrl = initiateKhaltiPayment(
                req,
                purchaseOrderId,
                appointmentId,
                amountPaisa,
                patient.getFullName(),
                patient.getEmail(),
                patient.getContactNumber()
        );
        if (paymentUrl == null || paymentUrl.isBlank()) {
            markKhaltiFailedQuietly(purchaseOrderId);
            redirectMyAppointments(req, resp, "error", "Unable to create Khalti payment session");
            return;
        }
        resp.sendRedirect(paymentUrl);
    }

    private void handleEsewaCallback(HttpServletRequest req, HttpServletResponse resp, boolean successAction) throws IOException {
        String encodedData = req.getParameter("data");
        String transactionUuid = null;
        String totalAmount = null;
        String callbackSignature = null;
        String callbackSignedFields = null;
        String decodedPayload = null;
        if (encodedData != null && !encodedData.isBlank()) {
            try {
                decodedPayload = decodeBase64Payload(encodedData);
                transactionUuid = getJsonField(decodedPayload, "transaction_uuid");
                totalAmount = getJsonField(decodedPayload, "total_amount");
                callbackSignature = getJsonField(decodedPayload, "signature");
                callbackSignedFields = getJsonField(decodedPayload, "signed_field_names");
            } catch (IllegalArgumentException ex) {
                getServletContext().log("Invalid eSewa callback data payload", ex);
            }
        }
        if (transactionUuid == null || transactionUuid.isBlank()) {
            transactionUuid = req.getParameter("transaction_uuid");
        }
        if (totalAmount == null || totalAmount.isBlank()) {
            totalAmount = req.getParameter("total_amount");
        }

        if (transactionUuid == null || transactionUuid.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Missing+eSewa+transaction+details");
            return;
        }

        if (!successAction) {
            try {
                paymentDAO.markEsewaFailed(transactionUuid);
            } catch (SQLException ex) {
                getServletContext().log("eSewa failed-state update error", ex);
            }
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=eSewa+payment+was+cancelled+or+failed");
            return;
        }

        if (decodedPayload != null && callbackSignature != null && callbackSignedFields != null) {
            String secretKey = getConfig("ESEWA_SECRET_KEY", "esewa.secret_key", ESEWA_DEFAULT_TEST_SECRET);
            if (!isCallbackSignatureValid(decodedPayload, callbackSignedFields, callbackSignature, secretKey)) {
                try {
                    paymentDAO.markEsewaFailed(transactionUuid);
                } catch (SQLException ex) {
                    getServletContext().log("eSewa signature invalid update error", ex);
                }
                resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Invalid+eSewa+callback+signature");
                return;
            }
        }

        String productCode = getConfig("ESEWA_PRODUCT_CODE", "esewa.product_code", ESEWA_DEFAULT_TEST_PRODUCT_CODE);
        String status = verifyEsewaStatus(transactionUuid, totalAmount, productCode);
        if (!"COMPLETE".equalsIgnoreCase(status)) {
            try {
                paymentDAO.markEsewaFailed(transactionUuid);
            } catch (SQLException ex) {
                getServletContext().log("eSewa status fallback update error", ex);
            }
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=eSewa+payment+verification+failed");
            return;
        }

        try {
            boolean updated = paymentDAO.markEsewaSuccess(transactionUuid);
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?" + (updated
                    ? "success=eSewa+payment+completed+successfully"
                    : "error=Payment+verified+but+could+not+update+local+record"));
        } catch (SQLException ex) {
            getServletContext().log("eSewa success update failed", ex);
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Database+error+while+finalizing+payment");
        }
    }

    private void handleKhaltiCallback(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String pidx = req.getParameter("pidx");
        String callbackStatus = req.getParameter("status");
        String purchaseOrderId = req.getParameter("purchase_order_id");
        String callbackTransactionId = firstNonBlank(
                req.getParameter("transaction_id"),
                req.getParameter("txnId"),
                req.getParameter("tidx")
        );

        if (purchaseOrderId == null || purchaseOrderId.isBlank()) {
            redirectMyAppointments(req, resp, "error", "Missing Khalti payment details");
            return;
        }

        BigDecimal expectedAmount;
        try {
            expectedAmount = paymentDAO.getPendingAmountByTransactionRef(purchaseOrderId);
        } catch (SQLException ex) {
            getServletContext().log("Load local Khalti amount failed", ex);
            redirectMyAppointments(req, resp, "error", "Unable to load local payment record");
            return;
        }
        if (expectedAmount == null) {
            redirectMyAppointments(req, resp, "error", "Unable to find the local Khalti payment record");
            return;
        }

        if (pidx == null || pidx.isBlank()) {
            if (!"Completed".equalsIgnoreCase(callbackStatus)) {
                markKhaltiFailedQuietly(purchaseOrderId);
            }
            redirectMyAppointments(req, resp, "error", "Missing Khalti verification token");
            return;
        }

        KhaltiLookupResult lookup = lookupKhaltiPayment(pidx);
        if (lookup == null || lookup.status() == null || lookup.status().isBlank()) {
            redirectMyAppointments(req, resp, "error", "Unable to verify Khalti payment");
            return;
        }

        if (expectedAmount != null) {
            try {
                long expectedMinorUnits = toMinorUnits(expectedAmount);
                if (lookup.totalAmount() != null && lookup.totalAmount() != expectedMinorUnits) {
                    getServletContext().log("Khalti amount mismatch for ref " + purchaseOrderId
                            + ": expected=" + expectedMinorUnits + ", actual=" + lookup.totalAmount());
                    markKhaltiFailedQuietly(purchaseOrderId);
                    redirectMyAppointments(req, resp, "error", "Khalti payment amount mismatch");
                    return;
                }
            } catch (ArithmeticException ex) {
                getServletContext().log("Local Khalti amount conversion failed for ref " + purchaseOrderId, ex);
                redirectMyAppointments(req, resp, "error", "Unable to verify Khalti payment amount");
                return;
            }
        }

        if ("Completed".equalsIgnoreCase(lookup.status())) {
            try {
                String finalTransactionRef = firstNonBlank(
                        lookup.transactionId(),
                        callbackTransactionId,
                        pidx,
                        purchaseOrderId
                );
                boolean updated = paymentDAO.markKhaltiSuccess(purchaseOrderId, finalTransactionRef);
                redirectMyAppointments(req, resp, updated ? "success" : "error",
                        updated ? "Khalti payment completed successfully"
                                : "Khalti payment was verified but local record could not be updated");
            } catch (SQLException ex) {
                getServletContext().log("Finalize Khalti payment failed", ex);
                redirectMyAppointments(req, resp, "error", "Database error while finalizing Khalti payment");
            }
            return;
        }

        if ("Pending".equalsIgnoreCase(lookup.status()) || "Initiated".equalsIgnoreCase(lookup.status())) {
            redirectMyAppointments(req, resp, "success", "Khalti payment is pending confirmation");
            return;
        }

        markKhaltiFailedQuietly(purchaseOrderId);
        String resolvedStatus = lookup.status();
        if ((resolvedStatus == null || resolvedStatus.isBlank()) && callbackStatus != null && !callbackStatus.isBlank()) {
            resolvedStatus = callbackStatus;
        }
        redirectMyAppointments(req, resp, "error", buildKhaltiFailureMessage(resolvedStatus));
    }

    private String decodeBase64Payload(String encodedData) {
        try {
            return new String(Base64.getDecoder().decode(encodedData), StandardCharsets.UTF_8);
        } catch (IllegalArgumentException ex) {
            return new String(Base64.getUrlDecoder().decode(encodedData), StandardCharsets.UTF_8);
        }
    }

    private boolean isCallbackSignatureValid(String payload, String signedFieldNames, String callbackSignature, String secretKey) {
        try {
            String[] fields = signedFieldNames.split(",");
            StringBuilder msg = new StringBuilder();
            for (String rawField : fields) {
                String field = rawField == null ? "" : rawField.trim();
                if (field.isEmpty()) {
                    continue;
                }
                String value = getJsonField(payload, field);
                if (value == null) {
                    return false;
                }
                if (msg.length() > 0) {
                    msg.append(",");
                }
                msg.append(field).append("=").append(value);
            }
            String generated = hmacSha256Base64(msg.toString(), secretKey);
            return generated.equals(callbackSignature);
        } catch (Exception ex) {
            getServletContext().log("eSewa callback signature check failed", ex);
            return false;
        }
    }

    private String verifyEsewaStatus(String transactionUuid, String totalAmount, String productCode) {
        if (transactionUuid == null || transactionUuid.isBlank()
                || totalAmount == null || totalAmount.isBlank()
                || productCode == null || productCode.isBlank()) {
            return null;
        }
        try {
            String query = "product_code=" + URLEncoder.encode(productCode, StandardCharsets.UTF_8)
                    + "&total_amount=" + URLEncoder.encode(totalAmount, StandardCharsets.UTF_8)
                    + "&transaction_uuid=" + URLEncoder.encode(transactionUuid, StandardCharsets.UTF_8);
            URI uri = URI.create(getEsewaStatusUrl() + "?" + query);
            HttpRequest request = HttpRequest.newBuilder(uri)
                    .GET()
                    .timeout(Duration.ofSeconds(18))
                    .build();
            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                getServletContext().log("eSewa status API returned non-2xx: " + response.statusCode());
                return null;
            }
            return getJsonField(response.body(), "status");
        } catch (Exception ex) {
            getServletContext().log("eSewa status verification call failed", ex);
            return null;
        }
    }

    private String initiateKhaltiPayment(
            HttpServletRequest req,
            String purchaseOrderId,
            int appointmentId,
            long amountMinorUnits,
            String customerName,
            String customerEmail,
            String customerPhone
    ) {
        try {
            String secretKey = getConfig("KHALTI_SECRET_KEY", "khalti.secret_key", "");
            String payload = "{"
                    + "\"return_url\":\"" + escapeJson(buildCallbackUrl(req, "khaltiCallback")) + "\","
                    + "\"website_url\":\"" + escapeJson(getKhaltiWebsiteUrl(req)) + "\","
                    + "\"amount\":" + amountMinorUnits + ","
                    + "\"purchase_order_id\":\"" + escapeJson(purchaseOrderId) + "\","
                    + "\"purchase_order_name\":\"" + escapeJson("Lab Appointment #" + appointmentId) + "\","
                    + "\"customer_info\":{"
                    + "\"name\":\"" + escapeJson(customerName) + "\","
                    + "\"email\":\"" + escapeJson(customerEmail) + "\","
                    + "\"phone\":\"" + escapeJson(normalizePhone(customerPhone)) + "\""
                    + "}"
                    + "}";
            HttpRequest request = HttpRequest.newBuilder(URI.create(getKhaltiInitiateUrl()))
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .timeout(Duration.ofSeconds(18))
                    .header("Authorization", "Key " + secretKey)
                    .header("Content-Type", "application/json")
                    .build();
            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                getServletContext().log("Khalti initiate API returned non-2xx: " + response.statusCode()
                        + " body=" + response.body());
                return null;
            }
            return getJsonField(response.body(), "payment_url");
        } catch (Exception ex) {
            getServletContext().log("Khalti initiate call failed", ex);
            return null;
        }
    }

    private KhaltiLookupResult lookupKhaltiPayment(String pidx) {
        if (pidx == null || pidx.isBlank()) {
            return null;
        }
        try {
            String secretKey = getConfig("KHALTI_SECRET_KEY", "khalti.secret_key", "");
            String payload = "{\"pidx\":\"" + escapeJson(pidx) + "\"}";
            HttpRequest request = HttpRequest.newBuilder(URI.create(getKhaltiLookupUrl()))
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .timeout(Duration.ofSeconds(18))
                    .header("Authorization", "Key " + secretKey)
                    .header("Content-Type", "application/json")
                    .build();
            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                getServletContext().log("Khalti lookup API returned non-2xx: " + response.statusCode()
                        + " body=" + response.body());
                return null;
            }
            String body = response.body();
            String status = getJsonField(body, "status");
            String totalAmount = getJsonField(body, "total_amount");
            String transactionId = getJsonField(body, "transaction_id");
            Long parsedTotal = null;
            if (totalAmount != null && !totalAmount.isBlank()) {
                try {
                    parsedTotal = Long.parseLong(totalAmount);
                } catch (NumberFormatException ignored) {
                    getServletContext().log("Unexpected Khalti total_amount: " + totalAmount);
                }
            }
            return new KhaltiLookupResult(status, parsedTotal, transactionId);
        } catch (Exception ex) {
            getServletContext().log("Khalti lookup call failed", ex);
            return null;
        }
    }

    private String getJsonField(String json, String key) {
        if (json == null || key == null) {
            return null;
        }
        String pattern = "\"" + java.util.regex.Pattern.quote(key) + "\"\\s*:\\s*(?:\"([^\"]*)\"|(-?\\d+(?:\\.\\d+)?)|(null))";
        var matcher = java.util.regex.Pattern.compile(pattern).matcher(json);
        if (matcher.find()) {
            if (matcher.group(1) != null) return matcher.group(1);
            if (matcher.group(2) != null) return matcher.group(2);
        }
        return null;
    }

    private String getEsewaFormUrl() {
        String mode = getConfig("ESEWA_MODE", "esewa.mode", "test");
        String fallback = "production".equalsIgnoreCase(mode) ? ESEWA_FORM_PROD_URL : ESEWA_FORM_TEST_URL;
        return getConfig("ESEWA_FORM_URL", "esewa.form_url", fallback);
    }

    private String getEsewaStatusUrl() {
        String mode = getConfig("ESEWA_MODE", "esewa.mode", "test");
        String fallback = "production".equalsIgnoreCase(mode) ? ESEWA_STATUS_PROD_URL : ESEWA_STATUS_TEST_URL;
        return getConfig("ESEWA_STATUS_URL", "esewa.status_url", fallback);
    }

    private String getKhaltiInitiateUrl() {
        String mode = getConfig("KHALTI_MODE", "khalti.mode", "test");
        String fallback = "production".equalsIgnoreCase(mode) ? KHALTI_INITIATE_PROD_URL : KHALTI_INITIATE_TEST_URL;
        return getConfig("KHALTI_INITIATE_URL", "khalti.initiate_url", fallback);
    }

    private String getKhaltiLookupUrl() {
        String mode = getConfig("KHALTI_MODE", "khalti.mode", "test");
        String fallback = "production".equalsIgnoreCase(mode) ? KHALTI_LOOKUP_PROD_URL : KHALTI_LOOKUP_TEST_URL;
        return getConfig("KHALTI_LOOKUP_URL", "khalti.lookup_url", fallback);
    }

    private String buildCallbackUrl(HttpServletRequest req, String action) {
        return buildApplicationBaseUrl(req) + "/PaymentServlet?action=" + action;
    }

    private String getKhaltiWebsiteUrl(HttpServletRequest req) {
        String configured = getConfig("KHALTI_WEBSITE_URL", "khalti.website_url", "");
        if (configured != null && !configured.isBlank()) {
            return stripTrailingSlash(configured);
        }
        return buildApplicationBaseUrl(req);
    }

    private String buildApplicationBaseUrl(HttpServletRequest req) {
        String overrideBase = getConfig("APP_BASE_URL", "app.base_url", "");
        if (overrideBase != null && !overrideBase.isBlank()) {
            return stripTrailingSlash(overrideBase);
        }
        StringBuilder base = new StringBuilder();
        base.append(req.getScheme()).append("://").append(req.getServerName());
        int port = req.getServerPort();
        boolean defaultHttp = "http".equalsIgnoreCase(req.getScheme()) && port == 80;
        boolean defaultHttps = "https".equalsIgnoreCase(req.getScheme()) && port == 443;
        if (!defaultHttp && !defaultHttps) {
            base.append(":").append(port);
        }
        base.append(req.getContextPath());
        return stripTrailingSlash(base.toString());
    }

    private long toMinorUnits(BigDecimal amount) {
        return amount.multiply(BigDecimal.valueOf(100))
                .setScale(0, RoundingMode.HALF_UP)
                .longValueExact();
    }

    private String normalizePhone(String phone) {
        if (phone == null) {
            return "";
        }
        String digits = phone.replaceAll("[^0-9]", "");
        if (digits.length() > 10 && (digits.startsWith("977") || digits.startsWith("0"))) {
            digits = digits.substring(digits.length() - 10);
        }
        return digits;
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        StringBuilder out = new StringBuilder(value.length() + 16);
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '\\':
                    out.append("\\\\");
                    break;
                case '"':
                    out.append("\\\"");
                    break;
                case '\b':
                    out.append("\\b");
                    break;
                case '\f':
                    out.append("\\f");
                    break;
                case '\n':
                    out.append("\\n");
                    break;
                case '\r':
                    out.append("\\r");
                    break;
                case '\t':
                    out.append("\\t");
                    break;
                default:
                    if (c < 0x20) {
                        out.append(String.format("\\u%04x", (int) c));
                    } else {
                        out.append(c);
                    }
            }
        }
        return out.toString();
    }

    private String stripTrailingSlash(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }
        return value.endsWith("/") ? value.substring(0, value.length() - 1) : value;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }
        return null;
    }

    private String buildKhaltiFailureMessage(String status) {
        if (status == null || status.isBlank()) {
            return "Khalti payment was not completed";
        }
        if ("User canceled".equalsIgnoreCase(status)) {
            return "Khalti payment was canceled by the user";
        }
        if ("Expired".equalsIgnoreCase(status)) {
            return "Khalti payment session expired";
        }
        if ("Refunded".equalsIgnoreCase(status) || "Partially refunded".equalsIgnoreCase(status)) {
            return "Khalti payment was refunded";
        }
        if ("Pending".equalsIgnoreCase(status) || "Initiated".equalsIgnoreCase(status)) {
            return "Khalti payment is pending confirmation";
        }
        return "Khalti payment was not completed (" + status + ")";
    }

    private void markKhaltiFailedQuietly(String purchaseOrderId) {
        try {
            paymentDAO.markKhaltiFailed(purchaseOrderId);
        } catch (SQLException ex) {
            getServletContext().log("Khalti failed-state update error", ex);
        }
    }

    private void redirectMyAppointments(HttpServletRequest req, HttpServletResponse resp, String type, String message) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?"
                + type + "=" + URLEncoder.encode(message, StandardCharsets.UTF_8));
    }

    private static String hmacSha256Base64(String message, String secret) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] raw = mac.doFinal(message.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(raw);
    }

    private static String getConfig(String envKey, String fileKey, String fallback) {
        String prop = System.getProperty(envKey);
        if (prop != null && !prop.trim().isEmpty()) return prop.trim();
        String env = System.getenv(envKey);
        if (env != null && !env.trim().isEmpty()) return env.trim();
        String fileVal = APP_PROPS.getProperty(fileKey);
        if (fileVal != null && !fileVal.trim().isEmpty()) return fileVal.trim();
        return fallback;
    }

    private static Properties loadAppProperties() {
        Properties properties = new Properties();
        try (var in = PaymentServlet.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                properties.load(in);
            }
        } catch (IOException ignored) {
            // Defaults are used when properties cannot be read.
        }
        return properties;
    }

    private record KhaltiLookupResult(String status, Long totalAmount, String transactionId) {
    }

    private void handleStatement(HttpServletRequest req, HttpServletResponse resp, HttpSession session) throws IOException, ServletException {
        if (!isPatient(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Access+denied");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int patientId = ((Number) uid).intValue();
        int appointmentId;
        try {
            appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Invalid+appointment");
            return;
        }
        try {
            req.setAttribute("invoice", paymentDAO.getInvoiceForPatient(patientId, appointmentId));
            req.getRequestDispatcher("/patient/invoice.jsp").forward(req, resp);
        } catch (SQLException ex) {
            getServletContext().log("Load statement failed", ex);
            resp.sendRedirect(req.getContextPath() + "/MyAppointmentsServlet?error=Unable+to+load+statement");
        }
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp, HttpSession session) throws IOException, ServletException {
        if (!isPatient(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Access+denied");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int patientId = ((Number) uid).intValue();
        try {
            req.setAttribute("payments", paymentDAO.getPatientPaidRows(patientId));
            req.getRequestDispatcher("/patient/payment_statement.jsp").forward(req, resp);
        } catch (SQLException ex) {
            getServletContext().log("Load payments failed", ex);
            resp.sendRedirect(req.getContextPath() + "/patient/payment_statement.jsp?error=Unable+to+load+payments");
        }
    }

    private boolean isPatient(HttpSession session) {
        Object role = session.getAttribute("role");
        return role != null && "PATIENT".equalsIgnoreCase(role.toString());
    }

    private boolean isLabStaff(HttpSession session) {
        Object role = session.getAttribute("role");
        return role != null && "LAB_STAFF".equalsIgnoreCase(role.toString());
    }
}
