# 03 - Middlewares & CORS

Middlewares in `blaise-horse` follow the standard HashLoad Horse pipeline pattern with `THorse.Use` and `TNextProc`.

## Anatomy of a Horse Middleware

Every middleware procedure receives `Req`, `Res`, and a `Next` procedure:

```pascal
procedure MyMiddleware(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  // Execute code before route handler
  Next();
  // Execute code after route handler
end;
```

---

## CORS Middleware

`blaise-horse` comes with built-in CORS handling to support Vite development server hot reloading:

```pascal
procedure MiddlewareCORS(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  Res.RawWebResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
  Res.RawWebResponse.SetCustomHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  Res.RawWebResponse.SetCustomHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  
  if UpperCase(Req.RawWebRequest.Method) = 'OPTIONS' then
  begin
    Res.Status(THTTPStatus.NoContent).Send('');
    Exit;
  end;
  
  Next();
end;

begin
  THorse.Use(MiddlewareCORS);
end.
```

---

## Authentication Middleware

You can protect routes by chaining middlewares:

```pascal
procedure MiddlewareAuth(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  if Req.Headers['Authorization'] <> 'Bearer secret-token' then
  begin
    Res.Status(THTTPStatus.Unauthorized)
       .ContentType('application/json')
       .Send('{"error":"Unauthorized"}');
    Exit;
  end;
  Next();
end;

begin
  THorse.Route('/api/secure')
    .Use(MiddlewareAuth)
    .Get(GetSecureData);
end.
```
