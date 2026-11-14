program server;

{$mode objfpc}{$H+}{$M+}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils, Classes, fphttpserver, fpjson, jsonparser, HTTPDefs;

const
  DEFAULT_PORT = 9000;

type
  { THorseServer }
  THorseServer = class(TFPHTTPServer)
  private
    FDistPath: string;
    function GetMimeType(const FileName: string): string;
    function TryServeStaticFile(var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse): Boolean;
    procedure SetCorsHeaders(var AResponse: TFPHTTPConnectionResponse);
    function LoadFileContent(const APath: string): string;
  protected
    procedure HandleRequest(var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

constructor THorseServer.Create(AOwner: TComponent);
var
  BaseDir: string;
begin
  inherited Create(AOwner);
  Port := DEFAULT_PORT;
  BaseDir := ExtractFileDir(ParamStr(0));
  // Look for dist/ in current working directory or relative to executable
  if DirectoryExists(GetCurrentDir + DirectorySeparator + '..' + DirectorySeparator + 'dist') then
    FDistPath := ExpandFileName(GetCurrentDir + DirectorySeparator + '..' + DirectorySeparator + 'dist')
  else if DirectoryExists(GetCurrentDir + DirectorySeparator + 'dist') then
    FDistPath := ExpandFileName(GetCurrentDir + DirectorySeparator + 'dist')
  else if DirectoryExists(BaseDir + DirectorySeparator + '..' + DirectorySeparator + 'dist') then
    FDistPath := ExpandFileName(BaseDir + DirectorySeparator + '..' + DirectorySeparator + 'dist')
  else
    FDistPath := ExpandFileName(BaseDir + DirectorySeparator + 'dist');
end;

function THorseServer.GetMimeType(const FileName: string): string;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(FileName));
  if Ext = '.html' then Result := 'text/html; charset=utf-8'
  else if Ext = '.js' then Result := 'application/javascript; charset=utf-8'
  else if Ext = '.css' then Result := 'text/css; charset=utf-8'
  else if Ext = '.json' then Result := 'application/json; charset=utf-8'
  else if Ext = '.png' then Result := 'image/png'
  else if Ext = '.jpg' then Result := 'image/jpeg'
  else if Ext = '.jpeg' then Result := 'image/jpeg'
  else if Ext = '.svg' then Result := 'image/svg+xml'
  else if Ext = '.ico' then Result := 'image/x-icon'
  else if Ext = '.wasm' then Result := 'application/wasm'
  else Result := 'application/octet-stream';
end;

function THorseServer.LoadFileContent(const APath: string): string;
var
  FS: TFileStream;
  S: string;
begin
  Result := '';
  if not FileExists(APath) then Exit;
  FS := TFileStream.Create(APath, fmOpenRead or fmShareDenyNone);
  try
    SetLength(S, FS.Size);
    if FS.Size > 0 then
      FS.ReadBuffer(S[1], FS.Size);
    Result := S;
  finally
    FS.Free;
  end;
end;

procedure THorseServer.SetCorsHeaders(var AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
  AResponse.SetCustomHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  AResponse.SetCustomHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
end;

function THorseServer.TryServeStaticFile(var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse): Boolean;
var
  TargetFile, ReqPath: string;
  FS: TFileStream;
begin
  Result := False;
  if not DirectoryExists(FDistPath) then Exit;

  ReqPath := ARequest.PathInfo;
  if (ReqPath = '') or (ReqPath = '/') then
    ReqPath := '/index.html';

  TargetFile := FDistPath + StringReplace(ReqPath, '/', DirectorySeparator, [rfReplaceAll]);
  if FileExists(TargetFile) then
  begin
    AResponse.ContentType := GetMimeType(TargetFile);
    AResponse.Code := 200;
    FS := TFileStream.Create(TargetFile, fmOpenRead or fmShareDenyNone);
    try
      AResponse.ContentStream := FS;
      AResponse.SendContent;
    finally
      AResponse.ContentStream := nil;
      FS.Free;
    end;
    Result := True;
  end;
end;

procedure THorseServer.HandleRequest(var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
var
  ReqPath, Method, JsonOut: string;
begin
  SetCorsHeaders(AResponse);
  ReqPath := LowerCase(Trim(ARequest.PathInfo));
  Method := UpperCase(ARequest.Method);

  // Handle pre-flight CORS OPTIONS
  if Method = 'OPTIONS' then
  begin
    AResponse.Code := 204;
    AResponse.SendContent;
    Exit;
  end;

  // 1. Health check endpoint
  if (ReqPath = '/api/health') or (ReqPath = '/health') then
  begin
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.Code := 200;
    JsonOut := '{"status":"healthy","backend":"horse","framework":"BlaiseVue","version":"1.0.0"}';
    AResponse.Content := JsonOut;
    AResponse.SendContent;
    Exit;
  end;

  // 2. Ping endpoint
  if ReqPath = '/api/ping' then
  begin
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.Code := 200;
    AResponse.Content := '{"pong":true,"timestamp":"' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + '"}';
    AResponse.SendContent;
    Exit;
  end;

  // 3. Sample items REST API
  if ReqPath = '/api/items' then
  begin
    AResponse.ContentType := 'application/json; charset=utf-8';
    if Method = 'GET' then
    begin
      AResponse.Code := 200;
      AResponse.Content := '[{"id":1,"name":"First Item","active":true},{"id":2,"name":"Second Item","active":false}]';
      AResponse.SendContent;
      Exit;
    end
    else if Method = 'POST' then
    begin
      AResponse.Code := 201;
      AResponse.Content := '{"message":"Item created successfully","received":true}';
      AResponse.SendContent;
      Exit;
    end;
  end;

  // 4. Try serving static frontend asset from dist/
  if TryServeStaticFile(ARequest, AResponse) then
    Exit;

  // 5. Fallback for SPA routing: serve index.html for non-API requests
  if Pos('/api/', ReqPath) <> 1 then
  begin
    if FileExists(FDistPath + DirectorySeparator + 'index.html') then
    begin
      AResponse.ContentType := 'text/html; charset=utf-8';
      AResponse.Code := 200;
      AResponse.Content := LoadFileContent(FDistPath + DirectorySeparator + 'index.html');
      AResponse.SendContent;
      Exit;
    end;
  end;

  // 6. 404 Not Found
  AResponse.ContentType := 'application/json; charset=utf-8';
  AResponse.Code := 404;
  AResponse.Content := '{"error":"Route not found: ' + ReqPath + '"}';
  AResponse.SendContent;
end;

var
  App: THorseServer;
  PortNum: Integer;
begin
  PortNum := DEFAULT_PORT;
  if ParamCount >= 1 then
    PortNum := StrToIntDef(ParamStr(1), DEFAULT_PORT);

  WriteLn('================================================================');
  WriteLn('  BlaiseVue Horse Native Backend Server v1.0.0');
  WriteLn('================================================================');
  WriteLn('  Engine:      Horse / fpWeb (Free Pascal Compiler)');
  WriteLn('  Port:        ', PortNum);
  WriteLn('  API Health:  http://localhost:', PortNum, '/api/health');
  WriteLn('  Static SPA:  Serving ../dist/');
  WriteLn('================================================================');
  WriteLn('Press Ctrl+C to terminate.');
  WriteLn('');

  App := THorseServer.Create(nil);
  try
    App.Port := PortNum;
    App.Active := True;
  finally
    App.Free;
  end;
end.
