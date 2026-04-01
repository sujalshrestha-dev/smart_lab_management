package com.smartlab.dao;

import com.smartlab.model.Test;
import com.smartlab.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TestDAO {
    public List<Test> getByLabUserId(int labUserId) throws SQLException {
        Integer labId = findLabIdByUserId(labUserId);
        if (labId == null) {
            return List.of();
        }

        String sql = "SELECT id, lab_id, test_name, description, price, availability "
                + "FROM tests WHERE lab_id = ? ORDER BY id DESC";
        List<Test> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Test t = new Test();
                    t.setId(rs.getInt("id"));
                    t.setLabId(rs.getInt("lab_id"));
                    t.setTestName(rs.getString("test_name"));
                    t.setDescription(rs.getString("description"));
                    t.setPrice(rs.getBigDecimal("price"));
                    t.setAvailability(rs.getString("availability"));
                    rows.add(t);
                }
            }
        }
        return rows;
    }

    public boolean addTest(int labUserId, String name, String description, BigDecimal price, String availability) throws SQLException {
        Integer labId = findLabIdByUserId(labUserId);
        if (labId == null) {
            return false;
        }
        String sql = "INSERT INTO tests (lab_id, test_name, description, price, availability) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            ps.setString(2, name);
            ps.setString(3, description);
            ps.setBigDecimal(4, price);
            ps.setString(5, normalizeAvailability(availability));
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateTest(int labUserId, int testId, String name, String description, BigDecimal price, String availability) throws SQLException {
        Integer labId = findLabIdByUserId(labUserId);
        if (labId == null) {
            return false;
        }
        String sql = "UPDATE tests SET test_name = ?, description = ?, price = ?, availability = ? "
                + "WHERE id = ? AND lab_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setBigDecimal(3, price);
            ps.setString(4, normalizeAvailability(availability));
            ps.setInt(5, testId);
            ps.setInt(6, labId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteTest(int labUserId, int testId) throws SQLException {
        Integer labId = findLabIdByUserId(labUserId);
        if (labId == null) {
            return false;
        }
        String sql = "DELETE FROM tests WHERE id = ? AND lab_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, testId);
            ps.setInt(2, labId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean toggleAvailability(int labUserId, int testId) throws SQLException {
        Integer labId = findLabIdByUserId(labUserId);
        if (labId == null) {
            return false;
        }
        String sql = "UPDATE tests SET availability = CASE "
                + "WHEN availability = 'AVAILABLE' THEN 'NOT_AVAILABLE' "
                + "ELSE 'AVAILABLE' END "
                + "WHERE id = ? AND lab_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, testId);
            ps.setInt(2, labId);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Test> getAvailableByLabId(int labId) throws SQLException {
        String sql = "SELECT id, lab_id, test_name, description, price, availability "
                + "FROM tests WHERE lab_id = ? AND availability = 'AVAILABLE' ORDER BY test_name ASC";
        List<Test> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Test t = new Test();
                    t.setId(rs.getInt("id"));
                    t.setLabId(rs.getInt("lab_id"));
                    t.setTestName(rs.getString("test_name"));
                    t.setDescription(rs.getString("description"));
                    t.setPrice(rs.getBigDecimal("price"));
                    t.setAvailability(rs.getString("availability"));
                    rows.add(t);
                }
            }
        }
        return rows;
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

    private String normalizeAvailability(String v) {
        return "NOT_AVAILABLE".equalsIgnoreCase(v) ? "NOT_AVAILABLE" : "AVAILABLE";
    }
}
