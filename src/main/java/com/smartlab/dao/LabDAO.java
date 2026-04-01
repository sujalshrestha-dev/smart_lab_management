package com.smartlab.dao;

import com.smartlab.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LabDAO {
    public List<PendingLab> getPendingLabs() throws SQLException {
        String sql = "SELECT l.id AS lab_id, l.user_id, l.lab_name, l.city, l.address, l.latitude, l.longitude, "
                + "u.full_name, u.email, u.contact_number, l.created_at "
                + "FROM labs l "
                + "JOIN users u ON u.id = l.user_id "
                + "WHERE l.verified = 0 "
                + "ORDER BY l.created_at ASC";

        List<PendingLab> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(new PendingLab(
                        rs.getInt("lab_id"),
                        rs.getInt("user_id"),
                        rs.getString("lab_name"),
                        rs.getString("city"),
                        rs.getString("address"),
                        rs.getBigDecimal("latitude"),
                        rs.getBigDecimal("longitude"),
                        rs.getString("full_name"),
                        rs.getString("email"),
                        rs.getString("contact_number"),
                        rs.getTimestamp("created_at")
                ));
            }
        }
        return rows;
    }

    public boolean approveLab(int labId, int adminId) throws SQLException {
        String updateLab = "UPDATE labs SET verified = 1, verified_at = CURRENT_TIMESTAMP WHERE id = ? AND verified = 0";
        String insertLog = "INSERT INTO lab_verification_log (lab_id, admin_id, action, notes) VALUES (?, ?, 'APPROVED', ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int updated;
                try (PreparedStatement ps = conn.prepareStatement(updateLab)) {
                    ps.setInt(1, labId);
                    updated = ps.executeUpdate();
                }
                if (updated == 0) {
                    conn.rollback();
                    return false;
                }
                try (PreparedStatement ps = conn.prepareStatement(insertLog)) {
                    ps.setInt(1, labId);
                    ps.setInt(2, adminId);
                    ps.setString(3, "Lab approved from admin panel");
                    ps.executeUpdate();
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

    public boolean rejectLab(int labId, int adminId) throws SQLException {
        String updateLab = "UPDATE labs SET verified = 0, verified_at = NULL WHERE id = ?";
        String insertLog = "INSERT INTO lab_verification_log (lab_id, admin_id, action, notes) VALUES (?, ?, 'REJECTED', ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int updated;
                try (PreparedStatement ps = conn.prepareStatement(updateLab)) {
                    ps.setInt(1, labId);
                    updated = ps.executeUpdate();
                }
                if (updated == 0) {
                    conn.rollback();
                    return false;
                }
                try (PreparedStatement ps = conn.prepareStatement(insertLog)) {
                    ps.setInt(1, labId);
                    ps.setInt(2, adminId);
                    ps.setString(3, "Lab rejected from admin panel");
                    ps.executeUpdate();
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

    public List<AdminLabRow> getAllLabsForAdmin() throws SQLException {
        String sql = "SELECT l.id AS lab_id, l.user_id, l.lab_name, l.city, l.address, l.latitude, l.longitude, "
                + "l.verified, l.created_at, u.full_name, u.email, u.contact_number, u.status "
                + "FROM labs l JOIN users u ON u.id = l.user_id "
                + "ORDER BY l.created_at DESC";
        List<AdminLabRow> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(new AdminLabRow(
                        rs.getInt("lab_id"),
                        rs.getInt("user_id"),
                        rs.getString("lab_name"),
                        rs.getString("city"),
                        rs.getString("address"),
                        rs.getBigDecimal("latitude"),
                        rs.getBigDecimal("longitude"),
                        rs.getInt("verified") == 1,
                        rs.getTimestamp("created_at"),
                        rs.getString("full_name"),
                        rs.getString("email"),
                        rs.getString("contact_number"),
                        rs.getString("status")
                ));
            }
        }
        return rows;
    }

    public boolean updateLabByAdmin(AdminLabUpdate update) throws SQLException {
        String updateLabSql = "UPDATE labs SET lab_name = ?, city = ?, address = ?, latitude = ?, longitude = ?, verified = ? "
                + "WHERE id = ?";
        String updateUserSql = "UPDATE users SET full_name = ?, email = ?, contact_number = ?, status = ? "
                + "WHERE id = ? AND role = 'LAB_STAFF'";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int labUpdated;
                try (PreparedStatement ps = conn.prepareStatement(updateLabSql)) {
                    ps.setString(1, update.labName());
                    ps.setString(2, update.city());
                    ps.setString(3, update.address());
                    ps.setBigDecimal(4, update.latitude());
                    ps.setBigDecimal(5, update.longitude());
                    ps.setInt(6, update.verified() ? 1 : 0);
                    ps.setInt(7, update.labId());
                    labUpdated = ps.executeUpdate();
                }

                int userUpdated;
                try (PreparedStatement ps = conn.prepareStatement(updateUserSql)) {
                    ps.setString(1, update.ownerName());
                    ps.setString(2, update.ownerEmail());
                    ps.setString(3, update.ownerContact());
                    ps.setString(4, update.ownerStatus());
                    ps.setInt(5, update.userId());
                    userUpdated = ps.executeUpdate();
                }

                if (labUpdated == 0 || userUpdated == 0) {
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

    public boolean deleteLabAccountByAdmin(int labId) throws SQLException {
        String findUserSql = "SELECT user_id FROM labs WHERE id = ?";
        String deleteAppointmentsSql = "DELETE FROM appointments WHERE lab_id = ?";
        String deleteUserSql = "DELETE FROM users WHERE id = ? AND role = 'LAB_STAFF'";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Integer userId = null;
                try (PreparedStatement ps = conn.prepareStatement(findUserSql)) {
                    ps.setInt(1, labId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            userId = rs.getInt(1);
                        }
                    }
                }
                if (userId == null) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement(deleteAppointmentsSql)) {
                    ps.setInt(1, labId);
                    ps.executeUpdate();
                }

                int deleted;
                try (PreparedStatement ps = conn.prepareStatement(deleteUserSql)) {
                    ps.setInt(1, userId);
                    deleted = ps.executeUpdate();
                }

                if (deleted == 0) {
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

    public LabProfile getProfileByUserId(int labUserId) throws SQLException {
        String sql = "SELECT id, user_id, lab_name, city, address, latitude, longitude, description, verified "
                + "FROM labs WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labUserId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new LabProfile(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getString("lab_name"),
                        rs.getString("city"),
                        rs.getString("address"),
                        rs.getBigDecimal("latitude"),
                        rs.getBigDecimal("longitude"),
                        rs.getString("description"),
                        rs.getInt("verified") == 1
                );
            }
        }
    }

    public boolean updateProfileByUserId(
            int labUserId,
            String labName,
            String city,
            String address,
            String description,
            java.math.BigDecimal latitude,
            java.math.BigDecimal longitude
    ) throws SQLException {
        String sql = "UPDATE labs SET lab_name = ?, city = ?, address = ?, description = ?, latitude = ?, longitude = ? "
                + "WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, labName);
            ps.setString(2, city);
            ps.setString(3, address);
            ps.setString(4, description);
            ps.setBigDecimal(5, latitude);
            ps.setBigDecimal(6, longitude);
            ps.setInt(7, labUserId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean addLabPhotoByUserId(int labUserId, String photoPath) throws SQLException {
        Integer labId = findLabIdByUserId(labUserId);
        if (labId == null) {
            return false;
        }
        String sql = "INSERT INTO lab_photos (lab_id, photo_path) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            ps.setString(2, photoPath);
            return ps.executeUpdate() > 0;
        }
    }

    public List<LabPhoto> getPhotosByUserId(int labUserId) throws SQLException {
        Integer labId = findLabIdByUserId(labUserId);
        if (labId == null) {
            return List.of();
        }
        String sql = "SELECT id, photo_path, uploaded_at FROM lab_photos WHERE lab_id = ? ORDER BY uploaded_at DESC";
        List<LabPhoto> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(new LabPhoto(
                            rs.getInt("id"),
                            rs.getString("photo_path"),
                            rs.getTimestamp("uploaded_at")
                    ));
                }
            }
        }
        return rows;
    }

    public LabChartSummary getChartSummaryByUserId(int labUserId) throws SQLException {
        Integer labId = findLabIdByUserId(labUserId);
        if (labId == null) {
            return new LabChartSummary(0, 0, 0, 0, 0, java.math.BigDecimal.ZERO, 0.0, 0, 0, 0, 0, 0);
        }

        long completed = countByLab("SELECT COUNT(*) FROM appointments WHERE lab_id = ? AND status = 'COMPLETED'", labId);
        long pending = countByLab("SELECT COUNT(*) FROM appointments WHERE lab_id = ? AND status IN ('PENDING','APPROVED')", labId);
        long paid = countByLab("SELECT COUNT(*) FROM appointments WHERE lab_id = ? AND payment_status = 'PAID'", labId);
        long unpaid = countByLab(
                "SELECT COUNT(*) FROM appointments a LEFT JOIN payments p ON p.appointment_id = a.id "
                        + "WHERE a.lab_id = ? AND a.payment_status = 'UNPAID' AND COALESCE(p.method, 'CASH') = 'CASH'",
                labId
        );
        long verifying = countByLab(
                "SELECT COUNT(*) FROM appointments a LEFT JOIN payments p ON p.appointment_id = a.id "
                        + "WHERE a.lab_id = ? AND a.payment_status = 'UNPAID' AND COALESCE(p.method, 'CASH') <> 'CASH'",
                labId
        );
        java.math.BigDecimal revenue = sumByLab(
                "SELECT COALESCE(SUM(p.amount),0) FROM payments p "
                        + "JOIN appointments a ON a.id = p.appointment_id "
                        + "WHERE a.lab_id = ? AND p.status = 'SUCCESS'",
                labId
        );

        RatingSummary rating = getRatingSummary(labId);
        return new LabChartSummary(
                completed,
                pending,
                paid,
                unpaid,
                verifying,
                revenue,
                rating.average(),
                rating.total(),
                rating.r1(),
                rating.r2(),
                rating.r3(),
                rating.r4() + rating.r5()
        );
    }

    public PublicLabProfile getPublicLabProfile(int labId) throws SQLException {
        String sql = "SELECT l.id, l.lab_name, l.city, l.address, l.latitude, l.longitude, l.description, "
                + "u.contact_number AS lab_contact, "
                + "COALESCE(AVG(r.rating),0) AS avg_rating, COUNT(r.id) AS total_reviews "
                + "FROM labs l "
                + "JOIN users u ON u.id = l.user_id "
                + "LEFT JOIN reviews r ON r.lab_id = l.id "
                + "WHERE l.id = ? AND l.verified = 1 "
                + "GROUP BY l.id, l.lab_name, l.city, l.address, l.latitude, l.longitude, l.description, u.contact_number";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new PublicLabProfile(
                        rs.getInt("id"),
                        rs.getString("lab_name"),
                        rs.getString("city"),
                        rs.getString("address"),
                        rs.getBigDecimal("latitude"),
                        rs.getBigDecimal("longitude"),
                        rs.getString("description"),
                        rs.getString("lab_contact"),
                        rs.getDouble("avg_rating"),
                        rs.getLong("total_reviews"),
                        getPhotoPathsByLabId(rs.getInt("id"))
                );
            }
        }
    }

    private List<String> getPhotoPathsByLabId(int labId) throws SQLException {
        String sql = "SELECT photo_path FROM lab_photos WHERE lab_id = ? ORDER BY uploaded_at DESC";
        List<String> photos = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    photos.add(rs.getString("photo_path"));
                }
            }
        }
        return photos;
    }

    private RatingSummary getRatingSummary(int labId) throws SQLException {
        String sql = "SELECT "
                + "COALESCE(AVG(rating),0) AS avg_rating, COUNT(*) AS total, "
                + "SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) AS r1, "
                + "SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) AS r2, "
                + "SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) AS r3, "
                + "SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) AS r4, "
                + "SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) AS r5 "
                + "FROM reviews WHERE lab_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return new RatingSummary(0.0, 0, 0, 0, 0, 0, 0);
                }
                return new RatingSummary(
                        rs.getDouble("avg_rating"),
                        rs.getLong("total"),
                        rs.getLong("r1"),
                        rs.getLong("r2"),
                        rs.getLong("r3"),
                        rs.getLong("r4"),
                        rs.getLong("r5")
                );
            }
        }
    }

    private long countByLab(String sql, int labId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0L;
            }
        }
    }

    private java.math.BigDecimal sumByLab(String sql, int labId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, labId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : java.math.BigDecimal.ZERO;
            }
        }
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

    public record PendingLab(
            int labId,
            int userId,
            String labName,
            String city,
            String address,
            java.math.BigDecimal latitude,
            java.math.BigDecimal longitude,
            String ownerName,
            String ownerEmail,
            String ownerContact,
            java.sql.Timestamp requestedAt
    ) {
    }

    public record LabProfile(
            int id,
            int userId,
            String labName,
            String city,
            String address,
            java.math.BigDecimal latitude,
            java.math.BigDecimal longitude,
            String description,
            boolean verified
    ) {
    }

    public record LabPhoto(
            int id,
            String photoPath,
            java.sql.Timestamp uploadedAt
    ) {
    }

    private record RatingSummary(
            double average,
            long total,
            long r1,
            long r2,
            long r3,
            long r4,
            long r5
    ) {
    }

    public record LabChartSummary(
            long completedCount,
            long pendingCount,
            long paidCount,
            long unpaidCount,
            long verifyingCount,
            java.math.BigDecimal totalRevenue,
            double avgRating,
            long totalRatings,
            long rating1,
            long rating2,
            long rating3,
            long rating4And5
    ) {
    }

    public record PublicLabProfile(
            int id,
            String labName,
            String city,
            String address,
            java.math.BigDecimal latitude,
            java.math.BigDecimal longitude,
            String description,
            String contactNumber,
            double avgRating,
            long totalReviews,
            List<String> photos
    ) {
    }

    public record AdminLabRow(
            int labId,
            int userId,
            String labName,
            String city,
            String address,
            java.math.BigDecimal latitude,
            java.math.BigDecimal longitude,
            boolean verified,
            java.sql.Timestamp createdAt,
            String ownerName,
            String ownerEmail,
            String ownerContact,
            String ownerStatus
    ) {
    }

    public record AdminLabUpdate(
            int labId,
            int userId,
            String labName,
            String city,
            String address,
            java.math.BigDecimal latitude,
            java.math.BigDecimal longitude,
            boolean verified,
            String ownerName,
            String ownerEmail,
            String ownerContact,
            String ownerStatus
    ) {
    }
}
