# 02 - Routing & API Endpoints

Routing in `blaise-horse` utilizes the official **HashLoad Horse** microframework API, identical to modern Express.js routing in Pascal.

## Registering Routes

Routes are declared using `THorse.Get`, `THorse.Post`, `THorse.Put`, `THorse.Delete`, etc.:

```pascal
uses
  Horse, Horse.Commons;

procedure GetHealth(Req: THorseRequest; Res: THorseResponse);
begin
  Res.ContentType('application/json; charset=utf-8')
     .Send('{"status":"healthy","backend":"HashLoad Horse"}');
end;

procedure GetItems(Req: THorseRequest; Res: THorseResponse);
begin
  Res.ContentType('application/json; charset=utf-8')
     .Send('[{"id":1,"name":"Widget"},{"id":2,"name":"Gadget"}]');
end;

begin
  THorse.Get('/api/health', GetHealth);
  THorse.Get('/api/items', GetItems);

  THorse.Listen(9000);
end.
```

---

## Reading Payloads (POST / PUT)

To read JSON payloads sent in request bodies:

```pascal
procedure CreateItem(Req: THorseRequest; Res: THorseResponse);
var
  BodyStr: string;
begin
  BodyStr := Req.Body;
  // Process payload (e.g. parse with fpjson or save to DB)
  
  Res.Status(THTTPStatus.Created)
     .ContentType('application/json; charset=utf-8')
     .Send('{"success":true,"received":' + BodyStr + '}');
end;

begin
  THorse.Post('/api/items', CreateItem);
end.
```

---

## Reading URL Query Parameters & Headers

Access query string parameters and HTTP headers seamlessly:

```pascal
procedure SearchItems(Req: THorseRequest; Res: THorseResponse);
var
  QueryTerm, AuthToken: string;
begin
  QueryTerm := Req.Query['q'];
  AuthToken := Req.Headers['Authorization'];
  
  Res.ContentType('application/json')
     .Send('{"query":"' + QueryTerm + '"}');
end;
```
