# 03 - Middlewares & CORS

Middlewares in `blaise-horse` execute sequentially in the request handling pipeline before target route procedures.

## Cross-Origin Resource Sharing (CORS)

During frontend development, Vite typically runs on `http://localhost:5173`, while the Horse backend listens on `http://localhost:9000`. To prevent CORS blocking, the template automatically registers CORS headers:

```pascal
procedure ApplyCORS(var AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
  AResponse.SetCustomHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  AResponse.SetCustomHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
end;
```

Preflight `OPTIONS` requests are acknowledged with HTTP 204:

```pascal
if Method = 'OPTIONS' then
begin
  AResponse.Code := 204;
  AResponse.SendContent;
  Exit;
end;
```

---

## Authentication Middleware

You can enforce Bearer token verification on protected routes:

```pascal
function AuthenticateRequest(var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse): Boolean;
var
  AuthHeader: string;
begin
  Result := False;
  AuthHeader := ARequest.GetCustomHeader('Authorization');

  if (AuthHeader = '') or (Pos('Bearer ', AuthHeader) <> 1) then
  begin
    SendJSON(AResponse, 401, '{"error":"Unauthorized: Missing or invalid Authorization header"}');
    Exit;
  end;

  // Validate token...
  Result := True;
end;
```

Usage in route handler:

```pascal
if (Method = 'GET') and (Path = '/api/profile') then
begin
  if not AuthenticateRequest(ARequest, AResponse) then
    Exit;

  SendJSON(AResponse, 200, '{"user":"admin","role":"superuser"}');
  Exit;
end;
```
