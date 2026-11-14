program BasicApi;

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, fphttpapp, fphttpserver;

type
  TBasicServerApp = class(TFPHttpServer)
  public
    procedure HandleRequest(Sender: TObject;
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
  end;

procedure TBasicServerApp.HandleRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);
var
  Method, Path: string;
begin
  Method := UpperCase(ARequest.Method);
  Path := ARequest.URL;

  // CORS
  AResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
  AResponse.SetCustomHeader('Content-Type', 'application/json; charset=utf-8');

  if Method = 'OPTIONS' then
  begin
    AResponse.Code := 204;
    AResponse.SendContent;
    Exit;
  end;

  if (Method = 'GET') and (Path = '/api/health') then
  begin
    AResponse.Code := 200;
    AResponse.Content := '{"status":"ok","time":"' + DateTimeToStr(Now) + '"}';
    AResponse.SendContent;
    Exit;
  end;

  if (Method = 'GET') and (Path = '/api/items') then
  begin
    AResponse.Code := 200;
    AResponse.Content := '[{"id":1,"name":"Item A"},{"id":2,"name":"Item B"}]';
    AResponse.SendContent;
    Exit;
  end;

  AResponse.Code := 404;
  AResponse.Content := '{"error":"Not Found"}';
  AResponse.SendContent;
end;

var
  Server: TBasicServerApp;
  PortVal: Word;
begin
  PortVal := 9000;
  if ParamCount >= 1 then
    PortVal := StrToIntDef(ParamStr(1), 9000);

  Server := TBasicServerApp.Create(nil);
  try
    Server.Port := PortVal;
    WriteLn('Basic API Server listening on port ', PortVal, '...');
    Server.Active := True;
  finally
    Server.Free;
  end;
end.
