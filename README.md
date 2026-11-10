# Chronis Backend

Chronis personal workflow and work management backend. A Spring Boot (Java 21) REST API that powers the Chronis Flutter client, backed by PostgreSQL.

## Overview

Chronis is a personal daily routine and work management system. The backend handles:

- User authentication and authorization (email/password, Google, Facebook)
- JWT access and refresh tokens with rotation
- Attendance and work-session tracking
- Break management
- Task and project management
- Daily work updates and daily reports
- Notifications
- AI engineering study workspace (roadmap, practice, coaching)
- Email verification and password reset via SMTP

## Technology stack

| Layer | Technology |
|-------|------------|
| Language | Java 21 |
| Framework | Spring Boot 3.3.4 |
| Security | Spring Security + JWT (jjwt 0.12.6) |
| Data access | Spring Data JPA / Hibernate |
| Database | PostgreSQL 42.7.4 (driver) |
| API docs | SpringDoc OpenAPI / Swagger UI |
| Mapping | MapStruct 1.6.3 |
| Build | Apache Maven (Maven Wrapper) |
| Mail | Spring Boot Starter Mail (Gmail SMTP) |
| Scheduling | Spring `@EnableScheduling` |

## Prerequisites

- Java 21 (JDK)
- A running PostgreSQL server with an existing database named `chronis_dev`
- Maven Wrapper (`./mvnw` / `mvnw.cmd`) — do not rely on a system `mvn`

## Project structure

```
chronis-backend/
├── pom.xml                      # Maven build descriptor
├── mvnw / mvnw.cmd              # Maven Wrapper
├── src/
│   ├── main/
│   │   ├── java/com/chronis/    # Application source
│   │   │   ├── ChronisBackendApplication.java   # Entry point
│   │   │   ├── auth/              # Authentication, JWT, social login
│   │   │   ├── attendance/        # Attendance sessions
│   │   │   ├── breakmanagement/   # Break sessions
│   │   │   ├── coaching/          # Coaching / AI study workspace
│   │   │   ├── configuration/     # Configuration + data seeder
│   │   │   ├── dailyreport/       # Daily reports
│   │   │   ├── engineering/       # AI engineering roadmap/work
│   │   │   ├── project/           # Projects and members
│   │   │   ├── task/              # Tasks
│   │   │   ├── worksession/       # Work sessions
│   │   │   ├── workupdate/        # Work updates
│   │   │   └── common/            # Exceptions, DTOs, audit base
│   │   └── resources/
│   │       ├── application.properties        # Shared configuration
│   │       ├── application-local.properties  # Private local values (gitignored)
│   │       ├── application-local.properties.example  # Template
│   │       └── schema.sql                    # Startup schema bootstrap
│   └── test/java/com/chronis/   # Unit and integration tests
├── target/                      # Build output (gitignored)
└── docs/
    ├── database-startup.md
    ├── authentication-testing.md
    └── frontend-backend-alignment.md
```

## Configuration

### application.properties

Shared configuration lives in `src/main/resources/application.properties`. Key settings:

- `spring.datasource.url=jdbc:postgresql://localhost:5432/chronis_dev`
- `spring.jpa.hibernate.ddl-auto=validate`
- `spring.sql.init.schema-locations=classpath:schema.sql`
- `server.port=${SERVER_PORT:8080}`
- `springdoc.swagger-ui.path=/swagger-ui.html`
- `app.cors.allowed-origins=http://localhost:*,http://127.0.0.1:*`

Spring Boot also imports `application-local.properties` (optional) from the module directory, backend folder, or project root. Environment variables take precedence over file values.

### application-local.properties (private, gitignored)

Create `src/main/resources/application-local.properties` from `application-local.properties.example` and fill in your local values:

```
DB_URL=jdbc:postgresql://localhost:5432/chronis_dev
DB_USERNAME=postgres
DB_PASSWORD=replace-with-local-password
JWT_SECRET=replace-with-a-random-secret-at-least-32-characters-long
CHRONIS_BOOTSTRAP_PASSWORD=choose-a-local-password-at-least-12-characters
```

Optional provider/SMTP settings can be added as needed (see the example file). This file is ignored by Git and excluded from the built JAR.

### Environment variables

The following can be set as environment variables and override file values:

- `SERVER_PORT` — backend HTTP port (default 8080)
- `JWT_SECRET` — JWT signing secret
- `GOOGLE_CLIENT_ID` / `GOOGLE_SERVER_CLIENT_ID` / `GOOGLE_ANDROID_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `FACEBOOK_APP_ID` / `FACEBOOK_APP_SECRET`
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`

## Database setup

PostgreSQL and the `chronis_dev` database must already exist; the backend initializes tables, not the database server itself.

On a new empty schema, `src/main/resources/schema.sql` creates all application tables, constraints, indexes, and the default 92-day AI engineering roadmap in a single transaction. On an existing schema it validates required columns and roadmap content without rebuilding or clearing tables. Hibernate then validates the mapped tables (`ddl-auto=validate`).

The earlier Flyway migrations are no longer used; any existing `flyway_schema_history` table is retained as historical data.

## Build and run

From the project root:

```powershell
cd chronis-backend
.\mvnw.cmd -DskipTests package
java -Xms128m -Xmx512m -XX:+UseSerialGC -jar .\target\chronis-backend-1.0.0.jar
```

Keep the terminal open. The backend starts on `http://localhost:8080` by default (override with `SERVER_PORT`).

Verify it is running:

```powershell
Invoke-RestMethod http://127.0.0.1:8080/actuator/health
```

## Running tests

```powershell
cd chronis-backend
.\mvnw.cmd test
```

PostgreSQL integration suites are opt-in. Use `mvnw.cmd` rather than a system `mvn`.

## API documentation

Swagger UI is available at:

```
http://localhost:8080/swagger-ui.html
```

OpenAPI docs:

```
http://localhost:8080/api/v1/openapi
```

## Main API areas

- `/api/v1/auth/**` — login, refresh, logout, signup with email OTP, forgot/reset password, Google/Facebook social login
- `/api/v1/users/me` — current user profile
- `/api/v1/attendance/**` — check-in, check-out, today's attendance
- `/api/v1/breaks/**` — start/end breaks, today's breaks
- `/api/v1/tasks/**` — tasks (my-tasks, status transitions)
- `/api/v1/projects/**` — projects
- `/api/v1/work-updates/**` — daily work updates
- `/api/v1/daily-reports/**` — daily reports and submission
- `/api/v1/notifications/**` — notifications, unread count, mark read
- `/api/v1/engineering/**` — AI engineering roadmap, work, practice
- `/api/v1/coaching/**` — coaching workspace, AI settings, carryover
- `/api/v1/workspace-records/**` — drafts, focus, rhythm, preferences

## Security notes

- Passwords are never stored in plain text.
- JWT secrets must never be committed; keep them in `application-local.properties` or environment variables.
- Protected endpoints require a valid access token (`Authorization: Bearer <token>`).
- Logout revokes all refresh tokens for the account.

## Related documentation

- `docs/database-startup.md` — database initialization behavior
- `docs/authentication-testing.md` — local authentication test flow via Swagger
- `docs/frontend-backend-alignment.md` — Flutter frontend and backend API alignment
- `../docs/runbook.md` — full local development runbook (backend + Flutter)
