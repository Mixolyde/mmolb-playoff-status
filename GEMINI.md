# MMOLB Playoff Status - Project Instructions

Foundational mandates for the MMOLB Playoff Status repository.

## Architecture & Core Components

The project is split into two primary functional areas, bridged by the shared `lib/` directory:

1.  **Data Generator (CLI):** `tools/update_stats.dart`. A CLI script that fetches data from the MMOLB API, simulates the remainder of the season/postseason, and uploads JSON results to AWS S3.
2.  **Web Frontend:** `web/`. A static Dart web application that consumes the JSON data from S3 and renders the playoff status dashboard.

### Logic Placement
- **Domain Models:** All shared data structures and JSON serialization logic must reside in `lib/src/`.
- **Simulation & Calculation:** Statistical logic, magic number calculations, and season simulations belong in `lib/stats/`.
- **API Clients:** Logic for interacting with the MMOLB API or AWS S3 belongs in `lib/database_api.dart` and `lib/s3_api.dart`.
- **UI Logic:** Table population and DOM manipulation for the web app live in `lib/html/`.

## Development Workflow

### Requirements
- **Dart SDK:** ^3.11.5 (as specified in `pubspec.yaml`).
- **Tools:** Use `dart run` instead of the legacy `pub` command where possible.

### Local Development
- **Testing:** Run all unit tests with `dart run test`. New simulation or data parsing logic **MUST** include corresponding tests in `test/`.
- **Web Preview:** Use `webdev` to serve the application locally:
  ```powershell
  dart pub global activate webdev
  webdev serve
  ```
- **Data Generation:** To run the local data update script:
  ```powershell
  dart run tools/update_stats.dart
  ```

### Deployment
- Deployment to the production site (typically `gh-pages` or a custom domain via Peanut) is handled by the `peanut` tool.
  ```powershell
  dart pub global activate peanut
  peanut
  ```

## Coding Standards

- **Consistency:** Follow standard Dart styling and naming conventions (Effective Dart).
- **Asynchronous Code:** Prefer `Future` and `async/await` for all I/O and API calls.
- **Error Handling:** Ensure robust error handling for API responses, especially in the simulation logic where data may be incomplete or unexpected.
- **UI Styling:** Maintain the existing aesthetic using Vanilla CSS in `web/styles.css`. Avoid adding heavy CSS frameworks.

## Security & Environment

- **Secrets:** Never commit AWS credentials or sensitive API keys. Use the `.env` file for local development (via the `dotenv` package).
- **Production Safety:** Be extremely cautious when modifying the S3 upload logic in `lib/s3_api.dart` or `tools/update_stats.dart` to avoid overwriting production data with invalid results.
