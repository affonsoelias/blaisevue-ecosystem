program BasicApi;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}cthreads,{$ENDIF}{$ENDIF}
  Horse,
  Horse.Commons,
  SysUtils;

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

procedure GetHealth(Req: THorseRequest; Res: THorseResponse);
begin
  Res.ContentType('application/json; charset=utf-8').Send('{"status":"ok","time":"' + DateTimeToStr(Now) + '"}');
end;

procedure GetItems(Req: THorseRequest; Res: THorseResponse);
begin
  Res.ContentType('application/json; charset=utf-8').Send('[{"id":1,"name":"Item A"},{"id":2,"name":"Item B"}]');
end;

procedure PostItems(Req: THorseRequest; Res: THorseResponse);
begin
  Res.Status(THTTPStatus.Created).ContentType('application/json; charset=utf-8').Send('{"created":true,"body":' + Req.Body + '}');
end;

begin
  THorse.Use(MiddlewareCORS);

  THorse.Get('/api/health', GetHealth);
  THorse.Get('/api/items', GetItems);
  THorse.Post('/api/items', PostItems);

  WriteLn('Basic Horse REST API running on port 9000...');
  THorse.Listen(9000);
end.
