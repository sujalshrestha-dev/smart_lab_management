package com.smartlab.dao;

import com.smartlab.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LabReviewDAO {
    public List<PatientReviewRow> getPatientReviewRows(int patientId) throws SQLException {
        ensureIgnoreTable();
        String sql = "SELECT a.id AS appointment_id, a.lab_id, l.lab_name, a.appointment_date, "
                + "r.rating, r.comment "
                + "FROM appointments a "
                + "JOIN labs l ON l.id = a.lab_id "
                + "LEFT JOIN reviews r ON r.appointment_id = a.id AND r.patient_id = ? "
                + "LEFT JOIN review_ignores ri ON ri.appointment_id = a.id AND ri.patient_id = ? "
                + "WHERE a.patient_id = ? AND a.status = 'COMPLETED' AND ri.appointment_id IS NULL "
                + "ORDER BY a.appointment_date DESC, a.id DESC";

        List<PatientReviewRow> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            ps.setInt(2, patientId);
            ps.setInt(3, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Integer rating = (Integer) rs.getObject("rating");
                    rows.add(new PatientReviewRow(
                            rs.getInt("appointment_id"),
                            rs.getInt("lab_id"),
                            rs.getString("lab_name"),
                            rs.getDate("appointment_date"),
                            rating,
                            rs.getString("comment")
                    ));
                }
            }
        }
        return rows;
    }

    public boolean submitRating(int patientId, int appointmentId, int rating, String comment) throws SQLException {
        ensureIgnoreTable();
        String sql = "INSERT INTO reviews (appointment_id, patient_id, lab_id, rating, comment) "
                + "SELECT a.id, a.patient_id, a.lab_id, ?, ? "
                + "FROM appointments a "
                + "LEFT JOIN review_ignores ri ON ri.appointment_id = a.id AND ri.patient_id = ? "
                + "WHERE a.id = ? AND a.patient_id = ? AND a.status = 'COMPLETED' AND ri.appointment_id IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rating);
            ps.setString(2, emptyToNull(comment));
            ps.setInt(3, patientId);
            ps.setInt(4, appointmentId);
            ps.setInt(5, patientId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean ignoreAppointmentForReview(int patientId, int appointmentId) throws SQLException {
        ensureIgnoreTable();
        String sql = "INSERT INTO review_ignores (appointment_id, patient_id) "
                + "SELECT a.id, a.patient_id FROM appointments a "
                + "LEFT JOIN reviews r ON r.appointment_id = a.id "
                + "WHERE a.id = ? AND a.patient_id = ? AND a.status = 'COMPLETED' AND r.appointment_id IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, patientId);
            return ps.executeUpdate() > 0;
        }
    }

    private void ensureIgnoreTable() throws SQLException {
        String sql = "CREATE TABLE IF NOT EXISTS review_ignores ("
                + "appointment_id INT PRIMARY KEY, "
                + "patient_id INT NOT NULL, "
                + "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
                + "INDEX idx_review_ignores_patient (patient_id), "
                + "CONSTRAINT fk_review_ignores_appt FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE ON UPDATE CASCADE, "
                + "CONSTRAINT fk_review_ignores_patient FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE"
                + ")";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.execute();
        }
    }

    private String emptyToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    public record PatientReviewRow(
            int appointmentId,
            int labId,
            String labName,
            Date appointmentDate,
            Integer rating,
            String comment
    ) {
    }
}
