package com.smartlab.dao;

import com.smartlab.model.User;
import com.smartlab.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class UserDAO {
    public int registerPatient(RegisterRequest req) throws SQLException {
        String insertUserSql = "INSERT INTO users (full_name, username, email, password_hash, contact_number, role, status) "
                + "VALUES (?, ?, ?, ?, ?, 'PATIENT', 'ACTIVE')";
        String insertPatientSql = "INSERT INTO patient_details (user_id, date_of_birth, emergency_contact, address) "
                + "VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int userId;
                try (PreparedStatement ps = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, req.fullName());
                    ps.setString(2, req.username());
                    ps.setString(3, req.email());
                    ps.setString(4, req.passwordHash());
                    ps.setString(5, req.contactNumber());
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) {
                            throw new SQLException("Failed to create user account.");
                        }
                        userId = rs.getInt(1);
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(insertPatientSql)) {
                    ps.setInt(1, userId);
                    ps.setDate(2, java.sql.Date.valueOf(req.dateOfBirth()));
                    ps.setString(3, req.emergencyContact());
                    ps.setString(4, req.address());
                    ps.executeUpdate();
                }

                conn.commit();
                return userId;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public int registerLabStaff(RegisterRequest req) throws SQLException {
        String insertUserSql = "INSERT INTO users (full_name, username, email, password_hash, contact_number, role, status) "
                + "VALUES (?, ?, ?, ?, ?, 'LAB_STAFF', 'ACTIVE')";
        String insertLabSql = "INSERT INTO labs (user_id, lab_name, city, address, latitude, longitude, verified) "
                + "VALUES (?, ?, ?, ?, ?, ?, 0)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int userId;
                try (PreparedStatement ps = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, req.fullName());
                    ps.setString(2, req.username());
                    ps.setString(3, req.email());
                    ps.setString(4, req.passwordHash());
                    ps.setString(5, req.contactNumber());
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) {
                            throw new SQLException("Failed to create lab user account.");
                        }
                        userId = rs.getInt(1);
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(insertLabSql)) {
                    ps.setInt(1, userId);
                    ps.setString(2, req.labName());
                    ps.setString(3, req.city());
                    ps.setString(4, req.address());
                    ps.setBigDecimal(5, req.latitude());
                    ps.setBigDecimal(6, req.longitude());
                    ps.executeUpdate();
                }

                conn.commit();
                return userId;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT id, full_name, username, email, password_hash, contact_number, role, status "
                + "FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setFullName(rs.getString("full_name"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setPasswordHash(rs.getString("password_hash"));
                user.setContactNumber(rs.getString("contact_number"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                return user;
            }
        }
    }

    public User findById(int id) throws SQLException {
        String sql = "SELECT id, full_name, username, email, password_hash, contact_number, role, status "
                + "FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setFullName(rs.getString("full_name"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setPasswordHash(rs.getString("password_hash"));
                user.setContactNumber(rs.getString("contact_number"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                return user;
            }
        }
    }

    public int registerAdmin(RegisterRequest req) throws SQLException {
        String insertUserSql = "INSERT INTO users (full_name, username, email, password_hash, contact_number, role, status) "
                + "VALUES (?, ?, ?, ?, ?, 'ADMIN', 'ACTIVE')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, req.fullName());
            ps.setString(2, req.username());
            ps.setString(3, req.email());
            ps.setString(4, req.passwordHash());
            ps.setString(5, req.contactNumber());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (!rs.next()) {
                    throw new SQLException("Failed to create admin account.");
                }
                return rs.getInt(1);
            }
        }
    }

    public boolean updatePasswordByEmail(String email, String newPasswordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        }
    }

    public PatientAccountData getPatientAccountByUserId(int userId) throws SQLException {
        String sql = "SELECT u.id, u.full_name, u.username, u.email, u.contact_number, "
                + "pd.date_of_birth, pd.emergency_contact, pd.address "
                + "FROM users u "
                + "LEFT JOIN patient_details pd ON pd.user_id = u.id "
                + "WHERE u.id = ? AND u.role = 'PATIENT'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new PatientAccountData(
                        rs.getInt("id"),
                        rs.getString("full_name"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("contact_number"),
                        rs.getDate("date_of_birth"),
                        rs.getString("emergency_contact"),
                        rs.getString("address")
                );
            }
        }
    }

    public boolean updatePatientAccount(PatientAccountUpdate update) throws SQLException {
        String updateUserSql = "UPDATE users SET full_name = ?, username = ?, email = ?, contact_number = ? "
                + "WHERE id = ? AND role = 'PATIENT'";
        String upsertPatientSql = "INSERT INTO patient_details (user_id, date_of_birth, emergency_contact, address) "
                + "VALUES (?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE date_of_birth = VALUES(date_of_birth), emergency_contact = VALUES(emergency_contact), address = VALUES(address)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int updatedRows;
                try (PreparedStatement ps = conn.prepareStatement(updateUserSql)) {
                    ps.setString(1, update.fullName());
                    ps.setString(2, update.username());
                    ps.setString(3, update.email());
                    ps.setString(4, update.contactNumber());
                    ps.setInt(5, update.userId());
                    updatedRows = ps.executeUpdate();
                }

                if (updatedRows == 0) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement(upsertPatientSql)) {
                    ps.setInt(1, update.userId());
                    ps.setDate(2, Date.valueOf(update.dateOfBirth()));
                    ps.setString(3, update.emergencyContact());
                    ps.setString(4, update.address());
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

    public boolean updatePasswordByUserId(int userId, String newPasswordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateAdminProfile(AdminProfileUpdate update) throws SQLException {
        String sql = "UPDATE users SET full_name = ?, username = ?, email = ?, contact_number = ? "
                + "WHERE id = ? AND role = 'ADMIN'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, update.fullName());
            ps.setString(2, update.username());
            ps.setString(3, update.email());
            ps.setString(4, update.contactNumber());
            ps.setInt(5, update.userId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deletePatientAccountByUserId(int userId) throws SQLException {
        String deleteReviewsSql = "DELETE FROM reviews WHERE patient_id = ?";
        String deleteAppointmentsSql = "DELETE FROM appointments WHERE patient_id = ?";
        String deleteUserSql = "DELETE FROM users WHERE id = ? AND role = 'PATIENT'";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(deleteReviewsSql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(deleteAppointmentsSql)) {
                    ps.setInt(1, userId);
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

    public boolean deleteLabStaffAccountByUserId(int userId) throws SQLException {
        String findLabSql = "SELECT id FROM labs WHERE user_id = ?";
        String deleteAppointmentsSql = "DELETE FROM appointments WHERE lab_id = ?";
        String deleteUserSql = "DELETE FROM users WHERE id = ? AND role = 'LAB_STAFF'";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Integer labId = null;
                try (PreparedStatement ps = conn.prepareStatement(findLabSql)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            labId = rs.getInt(1);
                        }
                    }
                }

                if (labId != null) {
                    try (PreparedStatement ps = conn.prepareStatement(deleteAppointmentsSql)) {
                        ps.setInt(1, labId);
                        ps.executeUpdate();
                    }
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

    public record RegisterRequest(
            String fullName,
            String username,
            String email,
            String passwordHash,
            String contactNumber,
            String dateOfBirth,
            String emergencyContact,
            String address,
            String labName,
            String city,
            java.math.BigDecimal latitude,
            java.math.BigDecimal longitude
    ) {
    }

    public record PatientAccountData(
            int userId,
            String fullName,
            String username,
            String email,
            String contactNumber,
            Date dateOfBirth,
            String emergencyContact,
            String address
    ) {
    }

    public record PatientAccountUpdate(
            int userId,
            String fullName,
            String username,
            String email,
            String contactNumber,
            String dateOfBirth,
            String emergencyContact,
            String address
    ) {
    }

    public record AdminProfileUpdate(
            int userId,
            String fullName,
            String username,
            String email,
            String contactNumber
    ) {
    }
}
