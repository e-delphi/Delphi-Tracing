// Eduardo - 19/10/2024
program Viewer;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Viewer.Classes in 'src\Viewer.Classes.pas',
  Viewer.Export.JSON in 'src\Viewer.Export.JSON.pas',
  Viewer.Export.CSV in 'src\Viewer.Export.CSV.pas',
  Viewer.Export.SQLite in 'src\Viewer.Export.SQLite.pas';

begin
  TViewer.Read('Mapper.json', 'Logger.log', TExportSQLite.SaveToFile('Viewer.db'));
end.
