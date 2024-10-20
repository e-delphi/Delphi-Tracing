// Eduardo - 19/10/2024
unit Viewer.Classes;

interface

uses
  System.SysUtils,
  Logger.Classes,
  Mapper.Classes;

type
  TEvent = record
    Kind: TLoggerKind;
    ThreadId: Integer;
    At: TDateTime;
    Method: TMethod;
  end;

  TReadEvents = reference to procedure(Events: TArray<TEvent>);

  TViewer = record
  public
    class procedure Read(const MapFile, LogFile: String; OutMethod: TReadEvents); static;
  end;

implementation

uses
  System.Classes;

{ TViewer }

function BytesToInt(const Bytes: TBytes): Integer;
begin
  if Length(Bytes) <> 4 then
    raise Exception.Create('Invalid byte array size. Expected 4 bytes.');
  Move(Bytes[0], Result, SizeOf(Result));
end;

function BytesToInt64(const Bytes: TBytes): Int64;
begin
  if Length(Bytes) <> 8 then
    raise Exception.Create('Invalid byte array size. Expected 8 bytes.');
  Move(Bytes[0], Result, SizeOf(Result));
end;

function MillisecondsToDateTime(const Milliseconds: Int64): TDateTime;
begin
  Result := TimeStampToDateTime(MSecsToTimeStamp(Milliseconds));
end;

class procedure TViewer.Read(const MapFile, LogFile: String; OutMethod: TReadEvents);
var
  FileLog: TFileStream;
  Map: TUnits;
  Bytes: TBytes;
  Event: TEvent;
  Events: TArray<TEvent>;
begin
  Map := Default(TUnits);
  Map.LoadToFile(MapFile);

  FileLog := TFileStream.Create(LogFile, fmOpenRead);
  try
    Events := [];
    FileLog.Seek(0, soBeginning);

    while FileLog.Position < FileLog.Size do
    begin
      Event := Default(TEvent);

      // Tipo
      Bytes := [];
      SetLength(Bytes, 1);
      FileLog.Read(Bytes, Length(Bytes));
      Event.Kind := TLoggerKind(Bytes[0]);

      // CurrentThreadId
      Bytes := [];
      SetLength(Bytes, 4);
      FileLog.Read(Bytes, Length(Bytes));
      Event.ThreadId := BytesToInt(Bytes);

      // DateTime
      Bytes := [];
      SetLength(Bytes, 8);
      FileLog.Read(Bytes, Length(Bytes));
      Event.At := MillisecondsToDateTime(BytesToInt64(Bytes));

      // ID
      Bytes := [];
      SetLength(Bytes, 4);
      FileLog.Read(Bytes, Length(Bytes));
      Event.Method := Map.Method(BytesToInt(Bytes));

      Events := Events + [Event];
    end;
  finally
    FileLog.Free;
  end;

  OutMethod(Events);
end;

end.
