// Eduardo - 19/10/2024
program Logger;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Logger.Classes in 'src\Logger.Classes.pas',
  Logger.Test in 'src\Logger.Test.pas';

begin
  for var I := 0 to 2 do
  begin
    Teste;
    var Rec: TTeste;
    Rec.Teste;
  end;
end.
