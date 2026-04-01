package com.smartlab.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public final class DBConnection {
    private static final String FALLBACK_URL =
            "jdbc:mysql://localhost:3306/smart_lab?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String FALLBACK_USER = "root";
    private static final String FALLBACK_PASSWORD = "";
    private static final Properties FILE_PROPS = loadDbProperties();

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            try {
                Class.forName("com.mysql.jdbc.Driver");
            } catch (ClassNotFoundException ignored) {
                // Driver missing at runtime; getConnection() will fail with clear error.
            }
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        String url = getConfig("DB_URL", "db.url", FALLBACK_URL);
        String user = getConfig("DB_USER", "db.user", FALLBACK_USER);
        String password = getConfig("DB_PASSWORD", "db.password", FALLBACK_PASSWORD);
        return DriverManager.getConnection(url, user, password);
    }

    private static String getConfig(String envKey, String fileKey, String fallback) {
        String prop = System.getProperty(envKey);
        if (prop != null && !prop.trim().isEmpty()) {
            return prop.trim();
        }

        String env = System.getenv(envKey);
        if (env != null && !env.trim().isEmpty()) {
            return env.trim();
        }

        String fileValue = FILE_PROPS.getProperty(fileKey);
        if (fileValue != null && !fileValue.trim().isEmpty()) {
            return fileValue.trim();
        }

        return fallback;
    }

    private static Properties loadDbProperties() {
        Properties properties = new Properties();
        try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                properties.load(in);
            }
        } catch (IOException ignored) {
            // keep fallback defaults
        }
        return properties;
    }
}
