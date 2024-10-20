// Eduardo - 20/10/2024
unit Viewer.Export.CSV;

interface

uses
  Viewer.Classes;

type
  TExportCSV = record
  public
    class function SaveToFile(OutputFile: String): TReadEvents; static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.DateUtils;

{ TExportCSV }

class function TExportCSV.SaveToFile(OutputFile: String): TReadEvents;
begin
  Result := TReadEvents(
    procedure(Events: TArray<TEvent>)
    var
      ss: TStringStream;
      Event: TEvent;
    begin
      ss := TStringStream.Create;
      try
        ss.WriteString('Kind,ThreadId,At,MethodID,UnitName,ClassName,MethodName'+ sLineBreak);
        for Event in Events do
        begin
          ss.WriteString(
            Byte(Event.Kind).ToString +','+
            Event.ThreadId.ToString +','+
            DateToISO8601(Event.At) +','+
            Event.Method.ID.ToString +','+
            Event.Method.UnitName +','+
            Event.Method.ClassName +','+
            Event.Method.MethodName + sLineBreak
          );
        end;
        ss.SaveToFile(OutputFile);
      finally
        ss.Free;
      end;
    end
  );
end;

end.
