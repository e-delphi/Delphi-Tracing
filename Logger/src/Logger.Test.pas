// Eduardo - 19/10/2024
unit Logger.Test;

{$DEFINE LOG}

interface

type
  TTeste = record
    procedure Teste;
  end;

procedure Teste;

implementation

uses{$IFDEF LOG} Logger.Classes, {$ENDIF}
  System.SysUtils;

procedure Teste;
begin{$IFDEF LOG} TLogger.Enter(1); try {$ENDIF}
  // teste
  Sleep(100);
{$IFDEF LOG} finally TLogger.Exit(1); end; {$ENDIF}end;

{ TTeste }

procedure TTeste.Teste;
begin{$IFDEF LOG} TLogger.Enter(2); try {$ENDIF}
  // teste
  Sleep(100);
{$IFDEF LOG} finally TLogger.Exit(2); end; {$ENDIF}end;

end.
