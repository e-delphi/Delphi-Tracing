// Eduardo - 19/10/2024
program Mapper;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  Mapper.Classes in 'src\Mapper.Classes.pas';

var
  Units: TUnits;
begin
  Units := TMapper.Map(TDirectory.GetFiles(ExpandFileName('..\Logger\src'), '*Test*'));
  Units.SaveToFile('Mapper.json');
  TMapper.Enable(Units);
end.
