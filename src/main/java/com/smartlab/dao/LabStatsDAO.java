package com.smartlab.dao;

import com.smartlab.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LabStatsDAO {
    public DashboardStats fetchByLabUserId(int labUserId) throws SQLException {
        Integer labId = findLabIdByUserId(labUserId);
        if (labId == null) {
            return new DashboardStats(0, 0, 0, 0, BigDecimal.ZERO, 0L, 0.0);
        }

        long totalTests = count("SELECT COUNT(*) FROM tests WHERE lab_id = ?", labId);
        long totalAppointments = count("SELECT COUNT(*) FROM appointments WHERE lab_id = ?", labId);
        long completedToday = count(
                "SELECT COUNT(*) FROM appointments WHERE lab_id = ? AND status = 'COMPLETED' AND appointment_date = CURDATE()",
                labId
        );
        long pendingReports = count(
                "SELECT COUNT(*) FROM appointments a LEFT JOIN reports r ON r.appointment_id = a.id "
                        + "WHERE a.lab_id = ? AND a.status = 'COMPLETED' AND r.id IS NULL",
                labId
        );
        BigDecimal dailyEarnings = sum(
                "SELECT COALESCE(SUM(p.amount),0) FROM payments p "
                        + "JOIN appointments a ON a.id = p.appointment_id "
                        + "WHERE a.lab_id = ? AND p.status = 'SUCCESS' "
                        + "AND DATE(COALESCE(p.paid_at, p.created_at)) = CURDATE()",
                labId
        );
        long ratedPatients = count(
                "SELECT COUNT(DISTINCT r.patient_id) FROM reviews r WHERE r.lab_id = ?",
                labId
        );
        double averageRating = decimal(
                "SELECT COALESCE(AVG(r.rating),0) FROM reviews r WHERE r.lab_id = ?",
                labId
        );

        return new DashboardStats(
                totalTests,
                totalAppointments,
                completedToday,
                pendingReports,
                dailyEarnings,
                ratedPatients,
                averageRating
        );
    }

    private Integer findLabIdByUserId(int userId) throws SQLException {
        String sql = "SELECT id FROM labs WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        }
    }

    private long count(String sql, int labId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0L;
            }
        }
    }

    private BigDecimal sum(String sql, int labId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    private double decimal(String sql, int labId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0.0;
            }
        }
    }

    public record DashboardStats(
            long totalTests,
            long totalAppointments,
            long completedToday,
            long pendingReports,
            BigDecimal dailyEarnings,
            long ratedPatients,
            double averageRating
    ) {
    }
}
