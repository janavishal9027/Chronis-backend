# Flutter and backend API alignment

The Flutter project at `../chronis_frontend` uses the following backend areas:

| Frontend area | Backend routes | Persistence |
| --- | --- | --- |
| Authentication and profile | `/api/v1/auth/**`, `/api/v1/employees/**` | Existing authentication and employee tables; authentication is unchanged. |
| Roadmap and daily report | `/api/v1/engineering/**` | Work, revisions and submitted reports are stored in PostgreSQL. The default roadmap is stored in PostgreSQL in `engineering_curricula`; the identical Flutter asset remains the offline fallback. |
| Projects, carryover, leave, interview and AI settings | `/api/v1/coaching/**` | Account records and revisions use PostgreSQL. Provider requests require the user's configured key and network access. |
| Drafts, focus, rhythm, preferences and reminder activity | `/api/v1/workspace-records/**` | Signed-in account records sync to PostgreSQL with version checks; offline copies can remain on the device until synchronization succeeds. |
| Other reachable screens | attendance, breaks, tasks, projects, work updates, daily reports and notifications | Existing API services and tables remain available. |

Department, team, schedule and time-block management routes, employee and project creation routes, the unused attendance-history route, and the unused standalone coaching-plan route have no callers in the reviewed Flutter project and have been removed. Migration V11 retires the five department, team and schedule tables while preserving their records in `retired_feature_records`. Existing manager-to-employee permissions are migrated to `manager_employee_access`; attendance schedule totals are preserved in `configuration`. Migration V13 removes five unused, empty legacy tables and three unused profile/attendance columns, after checking for data; it also stores the default roadmap in the database. Employee list/detail, project detail, task list/detail/create and the legacy daily-report list endpoints were removed because no reachable screen calls them. Those older migration source files were subsequently replaced by a single startup schema; any existing database migration history is retained. Coaching plans continue to be included in the coaching workspace response.

The Flutter text-size provider uses device preferences. Not every local or offline setting is automatically stored in the database. The database-backed endpoints require a signed-in account and successful synchronization.

Run the backend test suite with `mvnw.cmd test`. PostgreSQL integration suites are opt-in. The no-migrations startup was tested with all PostgreSQL integration suites against a separate temporary database. Restart the backend after rebuilding for the new route list to appear in Swagger at `/swagger-ui/index.html`.
