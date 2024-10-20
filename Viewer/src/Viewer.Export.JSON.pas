// Eduardo - 20/10/2024
unit Viewer.Export.JSON;

interface

uses
  System.JSON,
  Viewer.Classes,
  Logger.Classes;

type
  TExportJSON = record
  public
    class function SaveToFile(OutputFile: String): TReadEvents; static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.DateUtils;

{ TExportJSON }

class function TExportJSON.SaveToFile(OutputFile: String): TReadEvents;
begin
  Result := TReadEvents(
    procedure(Events: TArray<TEvent>)
    var
      aJSON: TJSONArray;
      oJSON: TJSONObject;
      ss: TStringStream;
      Event: TEvent;
    begin
      aJSON := TJSONArray.Create;
      try
        for Event in Events do
        begin
          oJSON := TJSONObject.Create;
          aJSON.Add(oJSON);

          oJSON.AddPair('Kind', Integer(Event.Kind));
          oJSON.AddPair('ThreadId', Event.ThreadId);
          oJSON.AddPair('At', DateToISO8601(Event.At));
          oJSON.AddPair('MethodID', Event.Method.ID);
          oJSON.AddPair('UnitName', Event.Method.UnitName);
          oJSON.AddPair('ClassName', Event.Method.ClassName);
          oJSON.AddPair('MethodName', Event.Method.MethodName);
        end;

        ss := TStringStream.Create(aJSON.ToJSON);
        try
          ss.SaveToFile(OutputFile);
        finally
          ss.Free;
        end;
      finally
        aJSON.Free;
      end;
    end
  );
end;

end.
