package com.smartlab.dao;

import com.smartlab.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AdminStatsDAO {
    public DashboardStats fetchDashboardStats() throws SQLException {
        long totalPatients = countBySql("SELECT COUNT(*) FROM users WHERE role = 'PATIENT'");
        long totalLabs = countBySql("SELECT COUNT(*) FROM labs");
        long totalAppointments = countBySql("SELECT COUNT(*) FROM appointments");
        long pendingLabs = countBySql("SELECT COUNT(*) FROM labs WHERE verified = 0");
        return new DashboardStats(totalPatients, totalLabs, totalAppointments, pendingLabs);
    }

    private long countBySql(String sql) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
            return 0L;
        }
    }

    public record DashboardStats(long totalPatients, long totalLabs, long totalAppointments, long pendingLabs) {
    }
}
