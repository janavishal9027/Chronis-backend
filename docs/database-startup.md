# Database startup

Chronis uses the existing PostgreSQL database configured in `application.properties`. PostgreSQL and that database must already exist; starting Chronis initializes tables, not the database server or database itself.

On a new empty schema, `src/main/resources/schema.sql` creates the application tables, constraints, roles, permissions and the default 92-day roadmap in a single transaction. On an existing schema, it checks the required columns and roadmap without rebuilding or clearing tables. Hibernate then validates the mapped tables. The default schema is `public`.

The earlier Flyway source folder and dependency are no longer used. An existing `flyway_schema_history` table is retained as historical data and is not used to start Chronis. A fresh database does not create that table.

There are no automatic versioned upgrades for older or incompatible existing databases. The initializer stops if required columns or the roadmap are missing; back up and update such a database explicitly before using this version. It does not silently alter existing user data.
