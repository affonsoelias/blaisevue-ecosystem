# Basic REST API Example

A minimal REST API example using the Horse microframework architecture in Free Pascal.

## Endpoints

- `GET /api/health` -> Health check JSON
- `GET /api/items` -> List sample items
- `POST /api/items` -> Create item from JSON payload

## How to Compile & Run

```bash
fpc -MObjFPC -Sh server.pas
./server 9000
```
