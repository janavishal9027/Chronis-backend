package com.chronis.support;

import java.sql.DriverManager;

/** Creates only a uniquely named integration-test schema in the configured test database. */
public final class PostgresTestSchema {
    private PostgresTestSchema() {}
    public static void create(String schema) {
        if (!schema.matches("chronis_(study|email|coach)_it_[a-f0-9]{32}")) {
            throw new IllegalArgumentException("Invalid test schema name");
        }
        String url = System.getenv("CHRONIS_TEST_DB_URL");
        String user = System.getenv("CHRONIS_TEST_DB_USER");
        String password = System.getenv("CHRONIS_TEST_DB_PASSWORD");
        if (url == null || user == null || password == null) throw new IllegalStateException("A separate test database is required");
        try (var connection = DriverManager.getConnection(url, user, password); var statement = connection.createStatement()) {
            statement.execute("CREATE SCHEMA \"" + schema + "\"");
        } catch (java.sql.SQLException ex) {
            throw new IllegalStateException("Could not create the isolated test schema", ex);
        }
    }
}
