package com.smartlab.dao;

import com.smartlab.util.DBConnection;
import com.smartlab.util.HaversineUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class PatientLabDAO {
    public List<String> getAvailableTestNames() throws SQLException {
        String sql = "SELECT DISTINCT test_name FROM tests WHERE availability = 'AVAILABLE' ORDER BY test_name ASC";
        List<String> tests = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                tests.add(rs.getString("test_name"));
            }
        }
        return tests;
    }

    public List<BrowseLab> searchLabs(SearchFilter filter) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT l.id, l.lab_name, l.city, l.address, l.latitude, l.longitude, "
                        + "COALESCE(l.description, '') AS description, "
                        + "COALESCE((SELECT MIN(t1.price) FROM tests t1 WHERE t1.lab_id = l.id AND t1.availability = 'AVAILABLE'), 0) AS min_price, "
                        + "COALESCE((SELECT AVG(r1.rating) FROM reviews r1 WHERE r1.lab_id = l.id), 0) AS avg_rating, "
                        + "COALESCE((SELECT COUNT(*) FROM reviews r2 WHERE r2.lab_id = l.id), 0) AS review_count, "
                        + "COALESCE((SELECT COUNT(DISTINCT a1.patient_id) FROM appointments a1 WHERE a1.lab_id = l.id AND a1.status = 'COMPLETED'), 0) AS patients_served, "
                        + "(SELECT GROUP_CONCAT(DISTINCT t3.test_name ORDER BY t3.test_name SEPARATOR ', ') "
                        + " FROM tests t3 WHERE t3.lab_id = l.id AND t3.availability = 'AVAILABLE') AS tests_list "
                        + "FROM labs l "
                        + "WHERE l.verified = 1 "
                        + "AND EXISTS (SELECT 1 FROM tests tx WHERE tx.lab_id = l.id AND tx.availability = 'AVAILABLE') "
        );

        List<Object> params = new ArrayList<>();
        if (filter.city() != null && !filter.city().isBlank()) {
            sql.append("AND l.city LIKE ? ");
            params.add("%" + filter.city().trim() + "%");
        }
        if (filter.labName() != null && !filter.labName().isBlank()) {
            sql.append("AND l.lab_name LIKE ? ");
            params.add("%" + filter.labName().trim() + "%");
        }

        // Selected tests are used for visual comparison (available vs missing) in UI,
        // not as a hard filter that removes labs from results.

        if (filter.maxPrice() != null) {
            sql.append("AND COALESCE((SELECT MIN(tp.price) FROM tests tp WHERE tp.lab_id = l.id AND tp.availability = 'AVAILABLE'), 0) <= ? ");
            params.add(filter.maxPrice());
        }
        if (filter.minRating() != null) {
            sql.append("AND COALESCE((SELECT AVG(rr.rating) FROM reviews rr WHERE rr.lab_id = l.id), 0) >= ? ");
            params.add(filter.minRating());
        }

        if ("PRICE_ASC".equalsIgnoreCase(filter.sort())) {
            sql.append("ORDER BY min_price ASC, l.lab_name ASC ");
        } else if ("RATING_DESC".equalsIgnoreCase(filter.sort())) {
            sql.append("ORDER BY avg_rating DESC, l.lab_name ASC ");
        } else {
            sql.append("ORDER BY l.lab_name ASC ");
        }

        List<BrowseLab> labs = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BigDecimal lat = rs.getBigDecimal("latitude");
                    BigDecimal lng = rs.getBigDecimal("longitude");
                    Double distanceKm = null;
                    if (filter.userLatitude() != null && filter.userLongitude() != null && lat != null && lng != null) {
                        distanceKm = HaversineUtil.distanceKm(
                                filter.userLatitude(),
                                filter.userLongitude(),
                                lat.doubleValue(),
                                lng.doubleValue()
                        );
                    }

                    labs.add(new BrowseLab(
                            rs.getInt("id"),
                            rs.getString("lab_name"),
                            rs.getString("city"),
                            rs.getString("address"),
                            lat,
                            lng,
                            rs.getString("description"),
                            rs.getBigDecimal("min_price"),
                            rs.getDouble("avg_rating"),
                            rs.getLong("review_count"),
                            rs.getLong("patients_served"),
                            splitTests(rs.getString("tests_list")),
                            distanceKm
                    ));
                }
            }
        }

        if ("NEAREST".equalsIgnoreCase(filter.sort()) && filter.userLatitude() != null && filter.userLongitude() != null) {
            labs.sort(Comparator.comparing(
                    BrowseLab::distanceKm,
                    Comparator.nullsLast(Double::compareTo)
            ));
        }

        return labs;
    }

    private static List<String> normalizeTests(List<String> tests) {
        if (tests == null) {
            return List.of();
        }
        Set<String> normalized = new LinkedHashSet<>();
        for (String test : tests) {
            if (test != null && !test.trim().isEmpty()) {
                normalized.add(test.trim());
            }
        }
        return new ArrayList<>(normalized);
    }

    private static List<String> splitTests(String csv) {
        if (csv == null || csv.isBlank()) {
            return List.of();
        }
        return Arrays.stream(csv.split(","))
                .map(String::trim)
                .filter(v -> !v.isEmpty())
                .collect(Collectors.toList());
    }

    public record SearchFilter(
            String city,
            String labName,
            List<String> tests,
            String sort,
            BigDecimal maxPrice,
            Double minRating,
            Double userLatitude,
            Double userLongitude
    ) {
    }

    public record BrowseLab(
            int id,
            String labName,
            String city,
            String address,
            BigDecimal latitude,
            BigDecimal longitude,
            String description,
            BigDecimal minPrice,
            double avgRating,
            long reviewCount,
            long patientsServed,
            List<String> availableTests,
            Double distanceKm
    ) {
    }
}
