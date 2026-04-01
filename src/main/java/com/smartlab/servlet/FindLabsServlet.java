package com.smartlab.servlet;

import com.smartlab.dao.PatientLabDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet("/FindLabsServlet")
public class FindLabsServlet extends HttpServlet {
    private final PatientLabDAO patientLabDAO = new PatientLabDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (!isPatient(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+patient");
            return;
        }

        String city = trim(req.getParameter("city"));
        String labName = trim(req.getParameter("labName"));
        boolean submitted = "1".equals(trim(req.getParameter("search")));
        String searchMode = trim(req.getParameter("searchMode"));
        if (searchMode.isBlank()) {
            searchMode = "nearest";
        }
        String sort = trim(req.getParameter("sort"));
        if (sort.isBlank()) {
            sort = "NEAREST";
        }
        if ("city".equalsIgnoreCase(searchMode)) {
            sort = "RATING_DESC".equalsIgnoreCase(sort) ? "RATING_DESC" : "PRICE_ASC".equalsIgnoreCase(sort) ? "PRICE_ASC" : "PRICE_ASC";
        } else {
            sort = "NEAREST".equalsIgnoreCase(sort) ? "NEAREST" : "PRICE_ASC".equalsIgnoreCase(sort) ? "PRICE_ASC" : "RATING_DESC";
        }
        List<String> selectedTests = req.getParameterValues("tests") == null
                ? Collections.emptyList()
                : Arrays.asList(req.getParameterValues("tests"));
        Double latitude = parseDouble(req.getParameter("latitude"));
        Double longitude = parseDouble(req.getParameter("longitude"));
        if ("city".equalsIgnoreCase(searchMode)) {
            latitude = null;
            longitude = null;
        }
        if (submitted && "nearest".equalsIgnoreCase(searchMode) && (latitude == null || longitude == null)) {
            req.setAttribute("error", "Please allow location to search nearest labs.");
        }

        try {
            PatientLabDAO.SearchFilter filter = new PatientLabDAO.SearchFilter(
                    city, labName, selectedTests, sort, null, null, latitude, longitude
            );
            List<PatientLabDAO.BrowseLab> labs = patientLabDAO.searchLabs(filter);
            labs = prioritizeCompleteMatches(labs, new HashSet<>(selectedTests));
            req.setAttribute("labs", labs);
            req.setAttribute("availableTests", patientLabDAO.getAvailableTestNames());
        } catch (SQLException ex) {
            getServletContext().log("Failed to search labs", ex);
            req.setAttribute("labs", Collections.emptyList());
            req.setAttribute("availableTests", Collections.emptyList());
            req.setAttribute("error", "Unable to load labs right now.");
        }

        req.setAttribute("selectedCity", city);
        req.setAttribute("selectedLabName", labName);
        req.setAttribute("selectedSearchMode", searchMode);
        req.setAttribute("selectedSort", sort);
        req.setAttribute("selectedTests", new HashSet<>(selectedTests));
        req.setAttribute("selectedLatitude", latitude);
        req.setAttribute("selectedLongitude", longitude);
        req.getRequestDispatcher("/patient/find_labs.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        doGet(req, resp);
    }

    private static boolean isPatient(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object role = session.getAttribute("role");
        return role != null && "PATIENT".equalsIgnoreCase(role.toString());
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static Double parseDouble(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private List<PatientLabDAO.BrowseLab> prioritizeCompleteMatches(
            List<PatientLabDAO.BrowseLab> labs,
            Set<String> selectedTests
    ) {
        if (selectedTests == null || selectedTests.isEmpty() || labs == null || labs.isEmpty()) {
            return labs;
        }
        List<PatientLabDAO.BrowseLab> complete = labs.stream()
                .filter(l -> l.availableTests().containsAll(selectedTests))
                .collect(Collectors.toList());
        List<PatientLabDAO.BrowseLab> partial = labs.stream()
                .filter(l -> !l.availableTests().containsAll(selectedTests))
                .collect(Collectors.toList());
        complete.addAll(partial);
        return complete;
    }
}
