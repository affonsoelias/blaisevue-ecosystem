program CustomMiddlewareServer;

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, fphttpserver, DateUtils;

type
  TMiddlewareServer = class(TFPHttpServer)
  private
    function CheckAuth(ARequest: TFPHTTPConnectionRequest; AResponse: TFPHTTPConnectionResponse): Boolean;
  public
    procedure HandleRequest(Sender: TObject;
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
  end;

function TMiddlewareServer.CheckAuth(ARequest: TFPHTTPConnectionRequest; AResponse: TFPHTTPConnectionResponse): Boolean;
var
  Key: string;
begin
  Key := ARequest.GetCustomHeader('X-Api-Key');
  if Key <> 'secret123' then
  begin
    AResponse.Code := 401;
    AResponse.Content := '{"error":"Unauthorized: Invalid or missing X-Api-Key"}';
    AResponse.SendContent;
    Result := False;
    Exit;
  end;
  Result := True;
end;

procedure TMiddlewareServer.HandleRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);
var
  Method, Path: string;
  TStart, TEnd: TDateTime;
  ElapsedMs: Int64;
begin
  TStart := Now;
  Method := UpperCase(ARequest.Method);
  Path := ARequest.URL;

  AResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
  AResponse.SetCustomHeader('Content-Type', 'application/json; charset=utf-8');

  if (Method = 'GET') and (Path = '/api/public') then
  begin
    AResponse.Code := 200;
    AResponse.Content := '{"message":"Public content accessible without auth"}';
    AResponse.SendContent;
  end
  else if (Method = 'GET') and (Pos('/api/secure/', Path) = 1) then
  begin
    if CheckAuth(ARequest, AResponse) then
    begin
      AResponse.Code := 200;
      AResponse.Content := '{"secure_data":"Top secret metrics payload"}';
      AResponse.SendContent;
    end;
  end
  else
  begin
    AResponse.Code := 404;
    AResponse.Content := '{"error":"Not Found"}';
    AResponse.SendContent;
  end;

  TEnd := Now;
  ElapsedMs := MilliSecondsBetween(TEnd, TStart);
  WriteLn(Format('[%s] %s %s -> HTTP %d (%d ms)',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', TStart), Method, Path, AResponse.Code, ElapsedMs]));
end;

var
  Server: TMiddlewareServer;
begin
  Server := TMiddlewareServer.Create(nil);
  try
    Server.Port := 9000;
    WriteLn('Custom Middleware Server listening on port 9000...');
    Server.Active := True;
  finally
    Server.Free;
  end;
end.
