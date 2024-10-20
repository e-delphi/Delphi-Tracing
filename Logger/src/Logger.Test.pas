// Eduardo - 19/10/2024
unit Logger.Test;

interface

type
  TTeste = record
    procedure Teste;
  end;

procedure Teste;

implementation

uses
  System.SysUtils;

procedure Teste;
begin
  // teste
  Sleep(100);
end;

{ TTeste }

procedure TTeste.Teste;
begin
  // teste
  Sleep(100);
end;

end.
