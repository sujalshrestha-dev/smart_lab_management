package com.smartlab.dao;

import com.smartlab.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AppointmentDAO {
    public List<LabAppointmentRow> getLabAppointments(int labUserId) throws SQLException {
        return getLabAppointmentsByStatus(labUserId, "");
    }

    public List<LabAppointmentRow> getLabActiveAppointments(int labUserId) throws SQLException {
        return getLabAppointmentsByStatus(labUserId, " AND a.status <> 'COMPLETED'");
    }

    public List<LabAppointmentRow> getLabCompletedAppointments(int labUserId) throws SQLException {
        return getLabAppointmentsByStatus(labUserId, " AND a.status = 'COMPLETED'");
    }

    private List<LabAppointmentRow> getLabAppointmentsByStatus(int labUserId, String extraWhere) throws SQLException {
        String sql = "SELECT a.id, u.full_name AS patient_name, a.appointment_date, a.appointment_time, "
                + "a.status, a.payment_status, a.notes, COALESCE(p.status, 'PENDING') AS payment_tx_status, "
                + "COALESCE(p.method, 'CASH') AS payment_method, "
                + "r.file_path "
                + "FROM appointments a "
                + "JOIN labs l ON l.id = a.lab_id "
                + "JOIN users u ON u.id = a.patient_id "
                + "LEFT JOIN payments p ON p.appointment_id = a.id "
                + "LEFT JOIN reports r ON r.appointment_id = a.id "
                + "WHERE l.user_id = ? "
                + extraWhere
                + "ORDER BY a.appointment_date DESC, a.appointment_time DESC, a.id DESC";

        List<LabAppointmentRow> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(new LabAppointmentRow(
                            rs.getInt("id"),
                            rs.getString("patient_name"),
                            rs.getDate("appointment_date"),
                            rs.getTime("appointment_time"),
                            rs.getString("status"),
                            rs.getString("payment_status"),
                            rs.getString("payment_tx_status"),
                            rs.getString("payment_method"),
                            rs.getString("notes"),
                            rs.getString("file_path")
                    ));
                }
            }
        }
        return rows;
    }

    public boolean updateStatus(int labUserId, int appointmentId, String newStatus) throws SQLException {
        if (!isAllowedStatus(newStatus)) {
            return false;
        }
        String sql;
        if ("APPROVED".equalsIgnoreCase(newStatus) || "REJECTED".equalsIgnoreCase(newStatus)) {
            sql = "UPDATE appointments a "
                    + "JOIN labs l ON l.id = a.lab_id "
                    + "SET a.status = ? "
                    + "WHERE a.id = ? AND l.user_id = ? AND a.status = 'PENDING'";
        } else {
            sql = "UPDATE appointments a "
                    + "JOIN labs l ON l.id = a.lab_id "
                    + "SET a.status = ? "
                    + "WHERE a.id = ? AND l.user_id = ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, appointmentId);
            ps.setInt(3, labUserId);
            return ps.executeUpdate() > 0;
        }
    }

    public AppointmentUploadCheck getUploadCheck(int labUserId, int appointmentId) throws SQLException {
        String sql = "SELECT a.status, a.payment_status "
                + "FROM appointments a "
                + "JOIN labs l ON l.id = a.lab_id "
                + "WHERE a.id = ? AND l.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, labUserId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return new AppointmentUploadCheck(false, "Appointment not found for this lab.");
                }
                String status = rs.getString("status");
                String paymentStatus = rs.getString("payment_status");
                if (!"PAID".equalsIgnoreCase(paymentStatus)) {
                    return new AppointmentUploadCheck(false, "Payment not completed for this appointment.");
                }
                if (!("APPROVED".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status))) {
                    return new AppointmentUploadCheck(false, "Only APPROVED/COMPLETED appointments can receive reports.");
                }
                return new AppointmentUploadCheck(true, null);
            }
        }
    }

    public boolean upsertReport(int appointmentId, int uploaderUserId, String filePath) throws SQLException {
        String sql = "INSERT INTO reports (appointment_id, file_path, uploaded_by) VALUES (?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE file_path = VALUES(file_path), uploaded_by = VALUES(uploaded_by), "
                + "uploaded_at = CURRENT_TIMESTAMP";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setString(2, filePath);
            ps.setInt(3, uploaderUserId);
            return ps.executeUpdate() > 0;
        }
    }

    public int createAppointmentWithTests(
            int patientId,
            int labId,
            Date appointmentDate,
            Time appointmentTime,
            String notes,
            List<Integer> testIds
    ) throws SQLException {
        if (testIds == null || testIds.isEmpty()) {
            throw new SQLException("At least one test must be selected.");
        }

        String apptSql = "INSERT INTO appointments (patient_id, lab_id, appointment_date, appointment_time, notes) "
                + "VALUES (?, ?, ?, ?, ?)";
        String testLookupSql = "SELECT id, price FROM tests WHERE lab_id = ? AND availability = 'AVAILABLE' AND id = ?";
        String apptTestSql = "INSERT INTO appointment_tests (appointment_id, test_id, price_snapshot) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int appointmentId;
                try (PreparedStatement ps = conn.prepareStatement(apptSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, patientId);
                    ps.setInt(2, labId);
                    ps.setDate(3, appointmentDate);
                    ps.setTime(4, appointmentTime);
                    ps.setString(5, notes);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) {
                            throw new SQLException("Failed to create appointment.");
                        }
                        appointmentId = rs.getInt(1);
                    }
                }

                Map<Integer, java.math.BigDecimal> priceMap = new HashMap<>();
                try (PreparedStatement ps = conn.prepareStatement(testLookupSql)) {
                    for (Integer testId : testIds) {
                        ps.setInt(1, labId);
                        ps.setInt(2, testId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                priceMap.put(testId, rs.getBigDecimal("price"));
                            }
                        }
                    }
                }
                if (priceMap.size() != testIds.size()) {
                    throw new SQLException("One or more selected tests are unavailable.");
                }

                try (PreparedStatement ps = conn.prepareStatement(apptTestSql)) {
                    for (Integer testId : testIds) {
                        ps.setInt(1, appointmentId);
                        ps.setInt(2, testId);
                        ps.setBigDecimal(3, priceMap.get(testId));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }

                conn.commit();
                return appointmentId;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private boolean isAllowedStatus(String s) {
        return "APPROVED".equalsIgnoreCase(s)
                || "REJECTED".equalsIgnoreCase(s)
                || "COMPLETED".equalsIgnoreCase(s);
    }

    public record LabAppointmentRow(
            int appointmentId,
            String patientName,
            Date appointmentDate,
            Time appointmentTime,
            String status,
            String paymentStatus,
            String paymentTxStatus,
            String paymentMethod,
            String notes,
            String reportPath
    ) {
    }

    public record AppointmentUploadCheck(boolean allowed, String reason) {
    }
}
