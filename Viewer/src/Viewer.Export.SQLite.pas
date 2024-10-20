// Eduardo - 20/10/2024
unit Viewer.Export.SQLite;

interface

uses
  FireDAC.Comp.Client,
  Viewer.Classes;

type
  TExportSQLite = record
  private
    class function NewConnection(sFile: String): TFDConnection; static;
  public
    class function SaveToFile(OutputFile: String): TReadEvents; static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Def,
  FireDAC.DApt,
  FireDAC.Stan.Async;

{ TExportSQLite }

class function TExportSQLite.NewConnection(sFile: String): TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  TFDPhysSQLiteConnectionDefParams(Result.Params).DriverID := 'SQLite';
  TFDPhysSQLiteConnectionDefParams(Result.Params).JournalMode := jmWAL;
  TFDPhysSQLiteConnectionDefParams(Result.Params).Synchronous := snNormal;
  TFDPhysSQLiteConnectionDefParams(Result.Params).LockingMode := lmNormal;
  TFDPhysSQLiteConnectionDefParams(Result.Params).SharedCache := False;

  Result.ResourceOptions.MacroCreate := False;
  Result.ResourceOptions.MacroExpand := False;
  Result.ResourceOptions.EscapeExpand := False;
  Result.ResourceOptions.ParamCreate := False;
  Result.ResourceOptions.ParamExpand := False;

  Result.UpdateOptions.LockWait := True;
  Result.Connected := True;
  Result.LoginPrompt := False;
  Result.Params.Values['Database'] := sFile;
  Result.Open;
end;

class function TExportSQLite.SaveToFile(OutputFile: String): TReadEvents;
begin
  Result := TReadEvents(
    procedure(Events: TArray<TEvent>)
    const
      sl = sLineBreak;
    var
      con: TFDConnection;
      Event: TEvent;
    begin
      con := TExportSQLite.NewConnection(OutputFile);
      try
        con.ExecSQL(
          sl +'create '+
          sl +' table if not exists log '+
          sl +'     ( id integer primary key autoincrement '+
          sl +'     , kind integer not null '+
          sl +'     , thread_id integer not null '+
          sl +'     , at text not null '+
          sl +'     , method_id integer not null '+
          sl +'     , unit_name text not null '+
          sl +'     , class_name text not null '+
          sl +'     , method_name text not null '+
          sl +'     ); '
        );

        for Event in Events do
          con.ExecSQL(
            sl +'insert '+
            sl +'  into log '+
            sl +'     ( kind '+
            sl +'     , thread_id '+
            sl +'     , at '+
            sl +'     , method_id '+
            sl +'     , unit_name '+
            sl +'     , class_name '+
            sl +'     , method_name '+
            sl +'     ) '+
            sl +'values '+
            sl +'     ( '+ Byte(Event.Kind).ToString +
            sl +'     , '+ Event.ThreadId.ToString +
            sl +'     , '+ DateToISO8601(Event.At).QuotedString +
            sl +'     , '+ Event.Method.ID.ToString +
            sl +'     , '+ Event.Method.UnitName.QuotedString +
            sl +'     , '+ Event.Method.ClassName.QuotedString +
            sl +'     , '+ Event.Method.MethodName.QuotedString +
            sl +'     ) '
          );
      finally
        con.Free;
      end;
    end
  );

(*
select entrada.id as entrada_id
     , saida.id as saida_id
     , entrada.thread_id
     , entrada.at as entrada
     , saida.at as saida
     , round((julianday(saida.at) - julianday(entrada.at)) * 86400000) as decorrido_ms
     , entrada.method_id
     , entrada.unit_name
     , entrada.class_name
     , entrada.method_name
  from log as entrada
  left
  join log as saida
    on saida.id =
     ( select id
         from log as proximo
        where proximo.kind = 2 /* 2-saida */
          and proximo.thread_id = entrada.thread_id
          and proximo.method_id = entrada.method_id
          and julianday(proximo.at) >= julianday(entrada.at)
        order
           by id
        limit 1
     )
 where entrada.kind = 1
*)
end;

end.
