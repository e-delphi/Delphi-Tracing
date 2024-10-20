// Eduardo - 19/10/2024
unit Logger.Classes;

interface

uses
  System.SysUtils;

{$SCOPEDENUMS ON}

type
  TLoggerKind = (Enter = 1, Exit = 2);

  TLogger = record
  private
    {$IFDEF LOG}
    class var FILE_NAME: String;
    {$ENDIF}
    class procedure AppendToFile(const Bytes: TBytes); static;
  public
    class procedure Enter(const ID: Integer); static;
    class procedure Exit(const ID: Integer); static;
  end;

implementation

uses
  Winapi.Windows,
  System.Classes,
  System.SyncObjs,
  System.DateUtils,
  System.TypInfo;

var
  FFileLock: TCriticalSection;
  FFileStream: TFileStream;

threadvar
  FCurrentThreadId: TBytes;

{ TLogger }

function IntToBytes(const Value: Integer): TBytes;
begin
  SetLength(Result, SizeOf(Value));
  Move(Value, Result[0], SizeOf(Value));
end;

function Int64ToBytes(const Value: Int64): TBytes;
begin
  SetLength(Result, SizeOf(Value));
  Move(Value, Result[0], SizeOf(Value));
end;

class procedure TLogger.Enter(const ID: Integer);
begin
  if Length(FCurrentThreadId) = 0 then
    FCurrentThreadId := IntToBytes(GetCurrentThreadId);

  AppendToFile([Byte(TLoggerKind.Enter)] + FCurrentThreadId + Int64ToBytes(DateTimeToMilliseconds(Now)) + IntToBytes(ID));
end;

class procedure TLogger.Exit(const ID: Integer);
begin
  AppendToFile([Byte(TLoggerKind.Exit)] + FCurrentThreadId + Int64ToBytes(DateTimeToMilliseconds(Now)) + IntToBytes(ID));
end;

class procedure TLogger.AppendToFile(const Bytes: TBytes);
begin
  FFileLock.Enter;
  try
    FFileStream.Seek(0, soEnd);
    FFileStream.WriteBuffer(Bytes, Length(Bytes));
  finally
    FFileLock.Leave;
  end;
end;

{$IFDEF LOG}
initialization
  FFileLock := TCriticalSection.Create;
  TLogger.FILE_NAME := ChangeFileExt(ParamStr(0), '.log');
  if not FileExists(TLogger.FILE_NAME) then
    FFileStream := TFileStream.Create(TLogger.FILE_NAME, fmCreate)
  else
    FFileStream := TFileStream.Create(TLogger.FILE_NAME, fmOpenReadWrite or fmShareDenyWrite);

finalization
  FFileLock.Free;
  FFileStream.Free;
{$ENDIF}

end.
