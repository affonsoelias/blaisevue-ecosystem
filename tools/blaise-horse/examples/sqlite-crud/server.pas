program SQLiteCrudServer;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}cthreads,{$ENDIF}{$ENDIF}
  Horse,
  Horse.Commons,
  SysUtils,
  Classes,
  sqlite3conn,
  sqldb;

var
  Conn: TSQLite3Connection;
  Tran: TSQLTransaction;

procedure InitDatabase;
var
  Q: TSQLQuery;
begin
  Conn := TSQLite3Connection.Create(nil);
  Tran := TSQLTransaction.Create(nil);
  Conn.Transaction := Tran;
  Conn.DatabaseName := 'notes.db';
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
end;

procedure GetNotes(Req: THorseRequest; Res: THorseResponse);
var
  Q: TSQLQuery;
  JSON: string;
begin
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := Conn;
    Q.Transaction := Tran;
    Q.SQL.Text := 'SELECT id, title, body FROM notes ORDER BY id DESC;';
    Q.Open;

    JSON := '[';
    while not Q.EOF do
    begin
      if JSON <> '[' then
        JSON := JSON + ',';
      JSON := JSON + Format('{"id":%d,"title":"%s","body":"%s"}',
        [Q.FieldByName('id').AsInteger,
         StringReplace(Q.FieldByName('title').AsString, '"', '\"', [rfReplaceAll]),
         StringReplace(Q.FieldByName('body').AsString, '"', '\"', [rfReplaceAll])]);
      Q.Next;
    end;
    JSON := JSON + ']';
    Res.ContentType('application/json; charset=utf-8').Send(JSON);
  finally
    Q.Free;
  end;
end;

procedure PostNote(Req: THorseRequest; Res: THorseResponse);
var
  Q: TSQLQuery;
begin
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := Conn;
    Q.Transaction := Tran;
    Q.SQL.Text := 'INSERT INTO notes (title, body) VALUES (:title, :body);';
    Q.ParamByName('title').AsString := 'Sample Note';
    Q.ParamByName('body').AsString := Req.Body;
    Q.ExecSQL;
    Tran.Commit;

    Res.Status(THTTPStatus.Created)
       .ContentType('application/json; charset=utf-8')
       .Send('{"success":true,"message":"Note saved"}');
  finally
    Q.Free;
  end;
end;

begin
  InitDatabase;

  THorse.Get('/api/notes', GetNotes);
  THorse.Post('/api/notes', PostNote);

  WriteLn('Horse SQLite CRUD Server running on port 9000...');
  THorse.Listen(9000);
end.
