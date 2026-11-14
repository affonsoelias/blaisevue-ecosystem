# Custom Middleware Example

Demonstrates request logging, execution timing, and API key authorization middleware in Free Pascal.

## Middleware Pipeline

1. **Timing & Logging Middleware**: Measures request duration in milliseconds and logs to console.
2. **API Key Authorization**: Verifies `X-Api-Key: secret123` on protected `/api/secure/*` endpoints.

## Endpoints

- `GET /api/public`: Open to everyone.
- `GET /api/secure/data`: Requires `X-Api-Key: secret123`.
