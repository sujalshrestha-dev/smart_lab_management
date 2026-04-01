package com.smartlab.dao;

import com.smartlab.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO {
    public boolean createPaymentForAppointment(int appointmentId, String method, BigDecimal amount, String transactionRef) throws SQLException {
        String sql = "INSERT INTO payments (appointment_id, method, amount, status, transaction_ref) "
                + "VALUES (?, ?, ?, 'PENDING', ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setString(2, normalizeMethod(method));
            ps.setBigDecimal(3, amount);
            ps.setString(4, emptyToNull(transactionRef));
            return ps.executeUpdate() > 0;
        }
    }

    public boolean markPaidByLab(int labUserId, int appointmentId) throws SQLException {
        String updatePayment = "UPDATE payments p "
                + "JOIN appointments a ON a.id = p.appointment_id "
                + "JOIN labs l ON l.id = a.lab_id "
                + "SET p.status = 'SUCCESS', p.paid_at = CURRENT_TIMESTAMP "
                + "WHERE p.appointment_id = ? AND l.user_id = ?";
        String updateAppointment = "UPDATE appointments a "
                + "JOIN labs l ON l.id = a.lab_id "
                + "SET a.payment_status = 'PAID' "
                + "WHERE a.id = ? AND l.user_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int p;
                try (PreparedStatement ps = conn.prepareStatement(updatePayment)) {
                    ps.setInt(1, appointmentId);
                    ps.setInt(2, labUserId);
                    p = ps.executeUpdate();
                }
                int a;
                try (PreparedStatement ps = conn.prepareStatement(updateAppointment)) {
                    ps.setInt(1, appointmentId);
                    ps.setInt(2, labUserId);
                    a = ps.executeUpdate();
                }
                if (p == 0 || a == 0) {
                    conn.rollback();
                    return false;
                }
                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean submitPatientPaymentRequest(int patientId, int appointmentId, String method) throws SQLException {
        String sql = "UPDATE payments p "
                + "JOIN appointments a ON a.id = p.appointment_id "
                + "SET p.method = ?, p.transaction_ref = NULL, p.status = 'PENDING', p.paid_at = NULL "
                + "WHERE p.appointment_id = ? AND a.patient_id = ? AND a.payment_status = 'UNPAID' "
                + "AND (COALESCE(p.method, 'CASH') = 'CASH' OR COALESCE(p.status, 'PENDING') = 'FAILED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizeMethod(method));
            ps.setInt(2, appointmentId);
            ps.setInt(3, patientId);
            return ps.executeUpdate() > 0;
        }
    }

    public BigDecimal getPendingAmountForPatientAppointment(int patientId, int appointmentId) throws SQLException {
        String sql = "SELECT p.amount "
                + "FROM payments p "
                + "JOIN appointments a ON a.id = p.appointment_id "
                + "WHERE p.appointment_id = ? AND a.patient_id = ? AND a.payment_status = 'UNPAID'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("amount");
                }
                return null;
            }
        }
    }

    public boolean prepareEsewaPayment(int patientId, int appointmentId, String transactionUuid) throws SQLException {
        String sql = "UPDATE payments p "
                + "JOIN appointments a ON a.id = p.appointment_id "
                + "SET p.method = 'ESEWA', p.transaction_ref = ?, p.status = 'PENDING', p.paid_at = NULL "
                + "WHERE p.appointment_id = ? AND a.patient_id = ? AND a.payment_status = 'UNPAID' "
                + "AND COALESCE(p.status, 'PENDING') <> 'SUCCESS'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, emptyToNull(transactionUuid));
            ps.setInt(2, appointmentId);
            ps.setInt(3, patientId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean prepareKhaltiPayment(int patientId, int appointmentId, String purchaseOrderId) throws SQLException {
        String sql = "UPDATE payments p "
                + "JOIN appointments a ON a.id = p.appointment_id "
                + "SET p.method = 'KHALTI', p.transaction_ref = ?, p.status = 'PENDING', p.paid_at = NULL "
                + "WHERE p.appointment_id = ? AND a.patient_id = ? AND a.payment_status = 'UNPAID' "
                + "AND COALESCE(p.status, 'PENDING') <> 'SUCCESS'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, emptyToNull(purchaseOrderId));
            ps.setInt(2, appointmentId);
            ps.setInt(3, patientId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean markEsewaSuccess(String transactionUuid) throws SQLException {
        String updatePayment = "UPDATE payments p "
                + "JOIN appointments a ON a.id = p.appointment_id "
                + "SET p.status = 'SUCCESS', p.method = 'ESEWA', p.paid_at = CURRENT_TIMESTAMP "
                + "WHERE p.transaction_ref = ? AND a.payment_status = 'UNPAID'";
        String updateAppointment = "UPDATE appointments a "
                + "JOIN payments p ON p.appointment_id = a.id "
                + "SET a.payment_status = 'PAID' "
                + "WHERE p.transaction_ref = ? AND a.payment_status = 'UNPAID'";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int p;
                try (PreparedStatement ps = conn.prepareStatement(updatePayment)) {
                    ps.setString(1, emptyToNull(transactionUuid));
                    p = ps.executeUpdate();
                }
                int a;
                try (PreparedStatement ps = conn.prepareStatement(updateAppointment)) {
                    ps.setString(1, emptyToNull(transactionUuid));
                    a = ps.executeUpdate();
                }
                if (p == 0 || a == 0) {
                    conn.rollback();
                    return false;
                }
                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean markEsewaFailed(String transactionUuid) throws SQLException {
        String sql = "UPDATE payments p "
                + "JOIN appointments a ON a.id = p.appointment_id "
                + "SET p.status = 'FAILED', p.method = 'ESEWA', p.paid_at = NULL "
                + "WHERE p.transaction_ref = ? AND a.payment_status = 'UNPAID'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, emptyToNull(transactionUuid));
            return ps.executeUpdate() > 0;
        }
    }

    public BigDecimal getPendingAmountByTransactionRef(String transactionRef) throws SQLException {
        String sql = "SELECT p.amount "
                + "FROM payments p "
                + "WHERE p.transaction_ref = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, emptyToNull(transactionRef));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("amount");
                }
                return null;
            }
        }
    }

    public boolean markKhaltiSuccess(String purchaseOrderId, String finalTransactionRef) throws SQLException {
        String findAppointment = "SELECT a.id "
                + "FROM appointments a "
                + "JOIN payments p ON p.appointment_id = a.id "
                + "WHERE p.transaction_ref = ? AND a.payment_status = 'UNPAID' "
                + "FOR UPDATE";
        String updateAppointment = "UPDATE appointments SET payment_status = 'PAID' "
                + "WHERE id = ? AND payment_status = 'UNPAID'";
        String updatePayment = "UPDATE payments "
                + "SET status = 'SUCCESS', method = 'KHALTI', transaction_ref = ?, paid_at = CURRENT_TIMESTAMP "
                + "WHERE appointment_id = ? AND transaction_ref = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Integer appointmentId = null;
                try (PreparedStatement ps = conn.prepareStatement(findAppointment)) {
                    ps.setString(1, emptyToNull(purchaseOrderId));
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            appointmentId = rs.getInt("id");
                        }
                    }
                }
                if (appointmentId == null) {
                    conn.rollback();
                    return false;
                }

                int a;
                try (PreparedStatement ps = conn.prepareStatement(updateAppointment)) {
                    ps.setInt(1, appointmentId);
                    a = ps.executeUpdate();
                }

                int p;
                try (PreparedStatement ps = conn.prepareStatement(updatePayment)) {
                    ps.setString(1, emptyToNull(finalTransactionRef));
                    ps.setInt(2, appointmentId);
                    ps.setString(3, emptyToNull(purchaseOrderId));
                    p = ps.executeUpdate();
                }

                if (p == 0 || a == 0) {
                    conn.rollback();
                    return false;
                }
                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean markKhaltiFailed(String purchaseOrderId) throws SQLException {
        String sql = "UPDATE payments p "
                + "JOIN appointments a ON a.id = p.appointment_id "
                + "SET p.status = 'FAILED', p.method = 'KHALTI', p.paid_at = NULL "
                + "WHERE p.transaction_ref = ? AND a.payment_status = 'UNPAID'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, emptyToNull(purchaseOrderId));
            return ps.executeUpdate() > 0;
        }
    }

    public InvoiceData getInvoiceForPatient(int patientId, int appointmentId) throws SQLException {
        String header = "SELECT a.id, a.appointment_date, a.appointment_time, a.status AS appointment_status, a.payment_status, "
                + "u.full_name AS patient_name, u.contact_number AS patient_contact, "
                + "l.lab_name, lu.contact_number AS lab_contact, "
                + "p.method, p.amount, p.status AS payment_tx_status, p.transaction_ref "
                + "FROM appointments a "
                + "JOIN users u ON u.id = a.patient_id "
                + "JOIN labs l ON l.id = a.lab_id "
                + "JOIN users lu ON lu.id = l.user_id "
                + "LEFT JOIN payments p ON p.appointment_id = a.id "
                + "WHERE a.id = ? AND a.patient_id = ?";
        String items = "SELECT t.test_name, at.price_snapshot "
                + "FROM appointment_tests at "
                + "JOIN tests t ON t.id = at.test_id "
                + "WHERE at.appointment_id = ? ORDER BY t.test_name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ph = conn.prepareStatement(header);
             PreparedStatement pi = conn.prepareStatement(items)) {
            ph.setInt(1, appointmentId);
            ph.setInt(2, patientId);
            try (ResultSet rs = ph.executeQuery()) {
                if (!rs.next()) return null;
                List<InvoiceItem> itemList = new ArrayList<>();
                pi.setInt(1, appointmentId);
                try (ResultSet ri = pi.executeQuery()) {
                    while (ri.next()) {
                        itemList.add(new InvoiceItem(
                                ri.getString("test_name"),
                                ri.getBigDecimal("price_snapshot")
                        ));
                    }
                }
                BigDecimal total = rs.getBigDecimal("amount");
                if (total == null) {
                    total = itemList.stream().map(InvoiceItem::price).reduce(BigDecimal.ZERO, BigDecimal::add);
                }
                return new InvoiceData(
                        rs.getInt("id"),
                        rs.getString("patient_name"),
                        rs.getString("patient_contact"),
                        rs.getString("lab_name"),
                        rs.getString("lab_contact"),
                        rs.getDate("appointment_date"),
                        rs.getTime("appointment_time"),
                        rs.getString("appointment_status"),
                        rs.getString("payment_status"),
                        rs.getString("method"),
                        rs.getString("payment_tx_status"),
                        rs.getString("transaction_ref"),
                        itemList,
                        total
                );
            }
        }
    }

    public List<PatientPaymentRow> getPatientPaymentRows(int patientId) throws SQLException {
        return getRowsByClause(patientId, "");
    }

    public List<PatientPaymentRow> getPatientUnfinishedAppointments(int patientId) throws SQLException {
        return getRowsByClause(patientId, " AND a.status <> 'COMPLETED'");
    }

    public List<PatientPaymentRow> getPatientCompletedAppointments(int patientId) throws SQLException {
        return getRowsByClause(patientId, " AND a.status = 'COMPLETED'");
    }

    public List<PatientPaymentRow> getPatientPaidRows(int patientId) throws SQLException {
        return getRowsByClause(patientId, " AND a.payment_status = 'PAID'");
    }

    public PatientResultAccess getPatientResultAccess(int patientId, int appointmentId) throws SQLException {
        String sql = "SELECT a.id, l.lab_name, a.appointment_date, a.appointment_time, a.status, a.payment_status, "
                + "r.file_path "
                + "FROM appointments a "
                + "JOIN labs l ON l.id = a.lab_id "
                + "LEFT JOIN reports r ON r.appointment_id = a.id "
                + "WHERE a.id = ? AND a.patient_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new PatientResultAccess(
                        rs.getInt("id"),
                        rs.getString("lab_name"),
                        rs.getDate("appointment_date"),
                        rs.getTime("appointment_time"),
                        rs.getString("status"),
                        rs.getString("payment_status"),
                        rs.getString("file_path")
                );
            }
        }
    }

    private List<PatientPaymentRow> getRowsByClause(int patientId, String additionalWhere) throws SQLException {
        String sql = "SELECT a.id, l.lab_name, a.appointment_date, a.appointment_time, a.status, a.payment_status, "
                + "COALESCE(p.method, 'CASH') AS method, COALESCE(p.amount, 0) AS amount, COALESCE(p.status, 'PENDING') AS payment_tx_status, "
                + "r.file_path "
                + "FROM appointments a "
                + "JOIN labs l ON l.id = a.lab_id "
                + "LEFT JOIN payments p ON p.appointment_id = a.id "
                + "LEFT JOIN reports r ON r.appointment_id = a.id "
                + "WHERE a.patient_id = ?"
                + additionalWhere
                + " ORDER BY a.id DESC";
        List<PatientPaymentRow> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(new PatientPaymentRow(
                            rs.getInt("id"),
                            rs.getString("lab_name"),
                            rs.getDate("appointment_date"),
                            rs.getTime("appointment_time"),
                            rs.getString("status"),
                            rs.getString("payment_status"),
                            rs.getString("method"),
                            rs.getBigDecimal("amount"),
                            rs.getString("payment_tx_status"),
                            rs.getString("file_path")
                    ));
                }
            }
        }
        return rows;
    }

    private String normalizeMethod(String method) {
        if ("ESEWA".equalsIgnoreCase(method)) return "ESEWA";
        if ("KHALTI".equalsIgnoreCase(method)) return "KHALTI";
        if ("BANK_TRANSFER".equalsIgnoreCase(method)) return "BANK_TRANSFER";
        return "CASH";
    }

    private String emptyToNull(String v) {
        return v == null || v.trim().isEmpty() ? null : v.trim();
    }

    public record InvoiceItem(String testName, BigDecimal price) {}

    public record InvoiceData(
            int appointmentId,
            String patientName,
            String patientContact,
            String labName,
            String labContact,
            Date appointmentDate,
            Time appointmentTime,
            String appointmentStatus,
            String paymentStatus,
            String method,
            String paymentTxStatus,
            String transactionRef,
            List<InvoiceItem> items,
            BigDecimal total
    ) {}

    public record PatientPaymentRow(
            int appointmentId,
            String labName,
            Date appointmentDate,
            Time appointmentTime,
            String appointmentStatus,
            String paymentStatus,
            String method,
            BigDecimal amount,
            String paymentTxStatus,
            String reportPath
    ) {}

    public record PatientResultAccess(
            int appointmentId,
            String labName,
            Date appointmentDate,
            Time appointmentTime,
            String appointmentStatus,
            String paymentStatus,
            String reportPath
    ) {}
}
