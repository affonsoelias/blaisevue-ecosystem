program server;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}cthreads,{$ENDIF}{$ENDIF}
  Horse,
  Horse.Commons,
  SysUtils,
  Classes;

const
  DEFAULT_PORT = 9000;

var
  FDistPath: string;

function ResolveDistDirectory: string;
var
  BaseDir, Candidate: string;
begin
  BaseDir := ExtractFileDir(ParamStr(0));
  Result := '';

  // 1. Two levels up from bin/ (server-horse/bin/server.exe -> project-root/dist)
  Candidate := ExpandFileName(BaseDir + DirectorySeparator + '..' + DirectorySeparator + '..' + DirectorySeparator + 'dist');
  if DirectoryExists(Candidate) and FileExists(Candidate + DirectorySeparator + 'index.html') then
    Exit(Candidate);

  // 2. One level up from server-horse/
  Candidate := ExpandFileName(BaseDir + DirectorySeparator + '..' + DirectorySeparator + 'dist');
  if DirectoryExists(Candidate) and FileExists(Candidate + DirectorySeparator + 'index.html') then
    Exit(Candidate);

  Candidate := ExpandFileName(GetCurrentDir + DirectorySeparator + '..' + DirectorySeparator + 'dist');
  if DirectoryExists(Candidate) and FileExists(Candidate + DirectorySeparator + 'index.html') then
    Exit(Candidate);

  // 3. Same directory (deploy/horse/server.exe alongside dist/)
  Candidate := ExpandFileName(BaseDir + DirectorySeparator + 'dist');
  if DirectoryExists(Candidate) and FileExists(Candidate + DirectorySeparator + 'index.html') then
    Exit(Candidate);

  Candidate := ExpandFileName(GetCurrentDir + DirectorySeparator + 'dist');
  if DirectoryExists(Candidate) and FileExists(Candidate + DirectorySeparator + 'index.html') then
    Exit(Candidate);

  // Fallbacks
  if DirectoryExists(BaseDir + DirectorySeparator + '..' + DirectorySeparator + '..' + DirectorySeparator + 'dist') then
    Exit(ExpandFileName(BaseDir + DirectorySeparator + '..' + DirectorySeparator + '..' + DirectorySeparator + 'dist'));
  if DirectoryExists(BaseDir + DirectorySeparator + '..' + DirectorySeparator + 'dist') then
    Exit(ExpandFileName(BaseDir + DirectorySeparator + '..' + DirectorySeparator + 'dist'));
  if DirectoryExists(GetCurrentDir + DirectorySeparator + '..' + DirectorySeparator + 'dist') then
    Exit(ExpandFileName(GetCurrentDir + DirectorySeparator + '..' + DirectorySeparator + 'dist'));

  Result := ExpandFileName(BaseDir + DirectorySeparator + 'dist');
end;

function DetectMimeType(const AFilePath: string): string;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(AFilePath));
  if (Ext = '.html') or (Ext = '.htm') then
    Result := 'text/html; charset=utf-8'
  else if (Ext = '.js') or (Ext = '.mjs') then
    Result := 'application/javascript; charset=utf-8'
  else if Ext = '.css' then
    Result := 'text/css; charset=utf-8'
  else if (Ext = '.json') or (Ext = '.map') then
    Result := 'application/json; charset=utf-8'
  else if Ext = '.svg' then
    Result := 'image/svg+xml'
  else if Ext = '.wasm' then
    Result := 'application/wasm'
  else if Ext = '.png' then
    Result := 'image/png'
  else if (Ext = '.jpg') or (Ext = '.jpeg') then
    Result := 'image/jpeg'
  else if Ext = '.gif' then
    Result := 'image/gif'
  else if Ext = '.webp' then
    Result := 'image/webp'
  else if Ext = '.ico' then
    Result := 'image/x-icon'
  else if Ext = '.woff' then
    Result := 'font/woff'
  else if Ext = '.woff2' then
    Result := 'font/woff2'
  else if Ext = '.ttf' then
    Result := 'font/ttf'
  else if Ext = '.eot' then
    Result := 'application/vnd.ms-fontobject'
  else if Ext = '.txt' then
    Result := 'text/plain; charset=utf-8'
  else
    Result := 'application/octet-stream';
end;

function IsStaticAssetExt(const Ext: string): Boolean;
begin
  Result :=
    (Ext = '.js') or (Ext = '.mjs') or (Ext = '.css') or
    (Ext = '.png') or (Ext = '.jpg') or (Ext = '.jpeg') or
    (Ext = '.gif') or (Ext = '.webp') or (Ext = '.svg') or
    (Ext = '.ico') or (Ext = '.woff') or (Ext = '.woff2') or
    (Ext = '.ttf') or (Ext = '.eot') or (Ext = '.map') or
    (Ext = '.json') or (Ext = '.wasm');
end;

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

procedure MiddlewareStaticAndSPA(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  ReqPath, TargetFile, Ext: string;
  QPos: Integer;
begin
  ReqPath := Req.RawWebRequest.PathInfo;
  QPos := Pos('?', ReqPath);
  if QPos > 0 then
    ReqPath := Copy(ReqPath, 1, QPos - 1);
  QPos := Pos('#', ReqPath);
  if QPos > 0 then
    ReqPath := Copy(ReqPath, 1, QPos - 1);

  // Let API requests pass directly to registered endpoints
  if (Pos('/api/', LowerCase(ReqPath)) = 1) or (LowerCase(ReqPath) = '/api') then
  begin
    Next();
    Exit;
  end;

  if (ReqPath = '') or (ReqPath = '/') then
    ReqPath := '/index.html';

  if (ReqPath <> '') and (ReqPath[1] = '/') then
    TargetFile := FDistPath + StringReplace(ReqPath, '/', DirectorySeparator, [rfReplaceAll])
  else
    TargetFile := FDistPath + DirectorySeparator + StringReplace(ReqPath, '/', DirectorySeparator, [rfReplaceAll]);

  if FileExists(TargetFile) and (not DirectoryExists(TargetFile)) then
  begin
    Res.SendFile(TargetFile, DetectMimeType(TargetFile));
    Exit;
  end;

  // Missing static asset guard (avoid serving index.html for missing .js/.css/etc.)
  Ext := LowerCase(ExtractFileExt(TargetFile));
  if IsStaticAssetExt(Ext) then
  begin
    if (Ext = '.js') and (Pos('main.', LowerCase(ExtractFileName(TargetFile))) = 1) and
       FileExists(FDistPath + DirectorySeparator + 'js' + DirectorySeparator + 'main.js') then
    begin
      Res.SendFile(FDistPath + DirectorySeparator + 'js' + DirectorySeparator + 'main.js', 'application/javascript; charset=utf-8');
      Exit;
    end;
    Res.Status(THTTPStatus.NotFound).ContentType('text/plain; charset=utf-8').Send('404 File Not Found: ' + ReqPath);
    Exit;
  end;

  // SPA Fallback: serve index.html for non-API routes
  if FileExists(FDistPath + DirectorySeparator + 'index.html') then
  begin
    Res.SendFile(FDistPath + DirectorySeparator + 'index.html', 'text/html; charset=utf-8');
    Exit;
  end;

  // Informational landing page if frontend is not yet built
  if (ReqPath = '/index.html') or (ReqPath = '/') or (ReqPath = '') then
  begin
    Res.ContentType('text/html; charset=utf-8').Send(
      '<!DOCTYPE html><html><head><meta charset="utf-8">' +
      '<title>BlaiseVue Horse Server</title>' +
      '<style>body{font-family:system-ui,sans-serif;background:#0f172a;color:#f8fafc;display:flex;align-items:center;justify-content:center;height:100vh;margin:0}' +
      '.card{background:#1e293b;padding:2.5rem 3rem;border-radius:12px;box-shadow:0 10px 25px rgba(0,0,0,0.4);border:1px solid #334155;text-align:center;max-width:480px}' +
      'h1{color:#38bdf8;margin:0 0 0.5rem}p{color:#94a3b8;font-size:0.95rem;line-height:1.5}' +
      '.badge{background:#0369a1;color:#fff;padding:4px 12px;border-radius:99px;font-size:0.8rem;display:inline-block;margin-bottom:1rem}' +
      '.box{background:#0f172a;padding:1rem;border-radius:8px;text-align:left;font-family:monospace;font-size:0.9rem;margin-top:1.5rem}' +
      'a{color:#38bdf8;text-decoration:none}a:hover{text-decoration:underline}' +
      '</style></head><body><div class="card">' +
      '<div class="badge">BlaiseVue Horse Backend</div>' +
      '<h1>Server Active</h1>' +
      '<p>Official HashLoad Horse backend is running on port <strong>' + IntToStr(THorse.Port) + '</strong>.</p>' +
      '<div class="box">' +
      '<div>- Health: <a href="/api/health">/api/health</a></div>' +
      '<div>- Ping: <a href="/api/ping">/api/ping</a></div>' +
      '<div>- Items: <a href="/api/items">/api/items</a></div>' +
      '</div>' +
      '<p style="margin-top:1.5rem;font-size:0.85rem">To serve your frontend SPA, run: <code>bv build</code></p>' +
      '</div></body></html>');
    Exit;
  end;

  Next();
end;

procedure GetHealth(Req: THorseRequest; Res: THorseResponse);
begin
  Res.ContentType('application/json; charset=utf-8').Send('{"status":"healthy","backend":"HashLoad Horse","framework":"BlaiseVue","version":"1.0.0"}');
end;

procedure GetPing(Req: THorseRequest; Res: THorseResponse);
begin
  Res.ContentType('application/json; charset=utf-8').Send('{"pong":true,"timestamp":"' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + '"}');
end;

procedure GetItems(Req: THorseRequest; Res: THorseResponse);
begin
  Res.ContentType('application/json; charset=utf-8').Send('[{"id":1,"name":"First Item","active":true},{"id":2,"name":"Second Item","active":false}]');
end;

procedure PostItem(Req: THorseRequest; Res: THorseResponse);
begin
  Res.Status(THTTPStatus.Created).ContentType('application/json; charset=utf-8').Send('{"message":"Item created successfully","received":' + Req.Body + '}');
end;

var
  PortNum: Integer;
begin
  FDistPath := ResolveDistDirectory;

  PortNum := DEFAULT_PORT;
  if ParamCount >= 1 then
    PortNum := StrToIntDef(ParamStr(1), DEFAULT_PORT);

  // Middlewares
  THorse.Use(MiddlewareCORS);
  THorse.Use(MiddlewareStaticAndSPA);

  // REST Routes
  THorse.Get('/api/health', GetHealth);
  THorse.Get('/api/ping', GetPing);
  THorse.Get('/api/items', GetItems);
  THorse.Post('/api/items', PostItem);

  WriteLn('================================================================');
  WriteLn('  BlaiseVue Horse Native Backend Server v1.0.0 (HashLoad)');
  WriteLn('================================================================');
  WriteLn('  Engine:      HashLoad Horse (FPC Delphi-Mode)');
  WriteLn('  Port:        ', PortNum);
  WriteLn('  Local App:   http://localhost:', PortNum);
  WriteLn('  API Health:  http://localhost:', PortNum, '/api/health');
  WriteLn('  Static SPA:  Serving ', FDistPath);
  WriteLn('================================================================');
  WriteLn('Press Ctrl+C to terminate.');
  WriteLn('');

  THorse.Listen(PortNum);
end.
