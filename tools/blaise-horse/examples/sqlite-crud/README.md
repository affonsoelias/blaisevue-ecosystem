# SQLite CRUD API Example

Demonstrates a persistent SQLite REST API with Free Pascal's standard `sqlite3conn` and `sqldb` units.

## Features

- Automatic SQLite database creation (`app.db`).
- Schema initialization (`CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, title TEXT, body TEXT)`).
- Endpoints:
  - `GET /api/notes`: Lists all notes.
  - `POST /api/notes`: Creates a note from a JSON payload.
  - `DELETE /api/notes?id=X`: Removes a note.

## Requirements

Ensure `sqlite3` client library / DLL is accessible in your environment or system PATH.
