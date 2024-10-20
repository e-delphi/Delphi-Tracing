// Eduardo - 19/10/2024
program Viewer;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Logger.Classes,
  Mapper.Classes,
  Viewer.Classes in 'src\Viewer.Classes.pas',
  Viewer.Export.JSON in 'src\Viewer.Export.JSON.pas';

begin
  TViewer.Read('Mapper.json', 'Logger.log', TExportJSON.SaveToFile('Viewer.json'));
end.
