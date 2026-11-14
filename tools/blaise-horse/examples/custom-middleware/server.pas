program CustomMiddlewareServer;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}cthreads,{$ENDIF}{$ENDIF}
  Horse,
  Horse.Commons,
  SysUtils,
  DateUtils;

procedure MiddlewareAuth(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  ApiKey: string;
begin
  ApiKey := Req.Headers['X-Api-Key'];
  if ApiKey <> 'secret123' then
  begin
    Res.Status(THTTPStatus.Unauthorized)
       .ContentType('application/json; charset=utf-8')
       .Send('{"error":"Unauthorized: Invalid or missing X-Api-Key"}');
    Exit;
  end;
  Next();
end;

procedure MiddlewareTiming(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  T1, T2: TDateTime;
  ElapsedMs: Int64;
begin
  T1 := Now;
  Next();
  T2 := Now;
  ElapsedMs := MilliSecondsBetween(T2, T1);
  WriteLn('[TIMING] ', Req.RawWebRequest.Method, ' ', Req.RawWebRequest.PathInfo, ' - ', ElapsedMs, ' ms');
end;

procedure GetPublic(Req: THorseRequest; Res: THorseResponse);
begin
  Res.ContentType('application/json; charset=utf-8').Send('{"status":"public","info":"No API key required"}');
end;

procedure GetProtected(Req: THorseRequest; Res: THorseResponse);
begin
  Res.ContentType('application/json; charset=utf-8').Send('{"status":"secret","data":"Super secure resource"}');
end;

begin
  // Global timing middleware
  THorse.Use(MiddlewareTiming);

  // Public route
  THorse.Get('/api/public', GetPublic);

  // Protected route with MiddlewareAuth
  THorse.Route('/api/protected')
    .Use(MiddlewareAuth)
    .Get(GetProtected);

  WriteLn('Custom Middleware Server running on port 9000...');
  THorse.Listen(9000);
end.
