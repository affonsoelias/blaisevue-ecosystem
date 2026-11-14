# 02 - Routing & API Endpoints

Routing in `blaise-horse` follows a straightforward Express-style mental model implemented with Free Pascal procedures.

## Handling Requests

Incoming requests are routed based on HTTP method and path:

```pascal
procedure HandleRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);
var
  Path, Method: string;
begin
  Path := ARequest.URL;
  Method := UpperCase(ARequest.Method);

  // Health check endpoint
  if (Method = 'GET') and (Path = '/api/health') then
  begin
    SendJSON(AResponse, 200, '{"status":"ok","engine":"horse","uptime":"active"}');
    Exit;
  end;

  // Custom resource endpoint
  if (Method = 'GET') and (Path = '/api/items') then
  begin
    SendJSON(AResponse, 200, '[{"id":1,"name":"Widget"},{"id":2,"name":"Gadget"}]');
    Exit;
  end;

  // 404 Not Found for unmapped API routes
  if (Pos('/api/', Path) = 1) then
  begin
    SendJSON(AResponse, 404, '{"error":"Not Found","path":"' + Path + '"}');
    Exit;
  end;

  // Fallback to static SPA hosting
  ServeStaticOrSPA(ARequest, AResponse);
end;
```

---

## Reading Payloads (POST / PUT)

To read JSON payloads from the client:

```pascal
var
  BodyStr: string;
begin
  if (Method = 'POST') and (Path = '/api/items') then
  begin
    SetLength(BodyStr, ARequest.ContentLength);
    if ARequest.ContentLength > 0 then
      ARequest.Content.Read(BodyStr[1], ARequest.ContentLength);

    // Process BodyStr...
    SendJSON(AResponse, 201, '{"created":true,"received":' + BodyStr + '}');
    Exit;
  end;
end;
```

---

## Query Parameters

Query strings can be parsed directly from `ARequest.QueryFields`:

```pascal
var
  SearchTerm: string;
begin
  SearchTerm := ARequest.QueryFields.Values['q'];
  if SearchTerm <> '' then
    // Filter results...
end;
```
