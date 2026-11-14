program SQLiteCrudServer;

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, fphttpserver, sqlite3conn, sqldb;

type
  TSQLiteServer = class(TFPHttpServer)
  private
    Conn: TSQLite3Connection;
    Tran: TSQLTransaction;
    procedure InitDB;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure HandleRequest(Sender: TObject;
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
  end;

constructor TSQLiteServer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Conn := TSQLite3Connection.Create(Self);
  Tran := TSQLTransaction.Create(Self);
  Conn.Transaction := Tran;
  Conn.DatabaseName := 'app.db';
  InitDB;
end;

destructor TSQLiteServer.Destroy;
begin
  Conn.Close;
  inherited Destroy;
end;

procedure TSQLiteServer.InitDB;
var
  Q: TSQLQuery;
begin
  try
    Conn.Open;
    Q := TSQLQuery.Create(nil);
    try
      Q.DataBase := Conn;
      Q.Transaction := Tran;
      Q.SQL.Text := 'CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT);';
      Q.ExecSQL;
      Tran.Commit;
    finally
      Q.Free;
    end;
  except
    on E: Exception do
      WriteLn('[DB Error] Could not initialize SQLite: ', E.Message);
  end;
end;

procedure TSQLiteServer.HandleRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);
var
  Method, Path, JsonOut: string;
  Q: TSQLQuery;
begin
  Method := UpperCase(ARequest.Method);
  Path := ARequest.URL;

  AResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
  AResponse.SetCustomHeader('Content-Type', 'application/json; charset=utf-8');

  if Method = 'OPTIONS' then
  begin
    AResponse.Code := 204;
    AResponse.SendContent;
    Exit;
  end;

  if (Method = 'GET') and (Path = '/api/notes') then
  begin
    Q := TSQLQuery.Create(nil);
    try
      Q.DataBase := Conn;
      Q.Transaction := Tran;
      Q.SQL.Text := 'SELECT id, title, body FROM notes ORDER BY id DESC;';
      Q.Open;
      JsonOut := '[';
      while not Q.EOF do
      begin
        if Length(JsonOut) > 1 then JsonOut := JsonOut + ',';
        JsonOut := JsonOut + Format('{"id":%d,"title":"%s","body":"%s"}',
          [Q.FieldByName('id').AsInteger,
           Q.FieldByName('title').AsString,
           Q.FieldByName('body').AsString]);
        Q.Next;
      end;
      JsonOut := JsonOut + ']';
      AResponse.Code := 200;
      AResponse.Content := JsonOut;
      AResponse.SendContent;
    finally
      Q.Free;
    end;
    Exit;
  end;

  AResponse.Code := 404;
  AResponse.Content := '{"error":"Endpoint not found"}';
  AResponse.SendContent;
end;

var
  Server: TSQLiteServer;
begin
  Server := TSQLiteServer.Create(nil);
  try
    Server.Port := 9000;
    WriteLn('SQLite CRUD Server listening on port 9000...');
    Server.Active := True;
  finally
    Server.Free;
  end;
end.
