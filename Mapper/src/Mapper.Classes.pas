// Eduardo - 19/10/2024
unit Mapper.Classes;

interface

uses
  DelphiAST.Classes;

type
  TLocation = record
    Line: Integer;
    Col: Integer;
  public
    constructor Create(const ALine, ACol: Integer);
  end;

  TMethod = record
    ID: Integer;
    UnitName: String;
    ClassName: String;
    MethodName: String;
    BeginLocation: TLocation;
    EndLocation: TLocation;
  end;

  TUnit = record
    FileName: String;
    ExistsUses: Boolean;
    UsesLocation: TLocation;
    Methods: TArray<TMethod>;
  end;

  TUnits = TArray<TUnit>;

  THUnits = record helper for TUnits
  public
    procedure SaveToFile(sFileName: String);
    procedure LoadToFile(sFileName: String);
    function Method(ID: Integer): TMethod;
  end;

  TMapper = record
  private const
    DIRECTIVE = 'LOG';
    USES_EXISTS = #13'{$IFDEF '+ DIRECTIVE +'} Logger.Classes, {$ENDIF}';
    USES_UNEXISTS = #13#13'{$IFDEF '+ DIRECTIVE +'} uses Logger.Classes; {$ENDIF}';
    BEGIN_LOG = #13'{$IFDEF '+ DIRECTIVE +'} TLogger.Enter(%d); try {$ENDIF}';
    END_LOG = '{$IFDEF '+ DIRECTIVE +'} finally TLogger.Exit(%d); end; {$ENDIF}'#13;
  private
    class var FMethodID: Integer;
    class function FindMethods(const Node: TSyntaxNode; const UnitName: String): TArray<TMethod>; static;
    class procedure FindUses(const Node: TSyntaxNode; out Exists: Boolean; out Location: TLocation); static;
  public
    class function Map(aFileNames: TArray<String>): TUnits; overload; static;
    class procedure Enable(Units: TUnits); overload; static;
    class procedure Disable(Units: TUnits); overload; static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.JSON.Serializers,
  DelphiAST,
  DelphiAST.Consts;

{ TLocation }

constructor TLocation.Create(const ALine, ACol: Integer);
begin
  Self.Line := ALine;
  Self.Col := ACol;
end;

{ TMapper }

class function TMapper.Map(aFileNames: TArray<String>): TUnits;
var
  SyntaxTree: TSyntaxNode;
  Builder: TPasSyntaxTreeBuilder;
  StringStream: TStringStream;
  sFileName: String;
  AUnit: TUnit;
  Methods: TArray<TMethod>;
begin
  FMethodID := 0;
  Result := [];
  for sFileName in aFileNames do
  begin
    Builder := TPasSyntaxTreeBuilder.Create;
    try
      StringStream := TStringStream.Create;
      try
        StringStream.LoadFromFile(sFileName);
        StringStream.Position := 0;
        SyntaxTree := Builder.Run(StringStream);
        try
          Methods := FindMethods(SyntaxTree, ChangeFileExt(ExtractFileName(sFileName), EmptyStr));

          if Length(Methods) = 0 then
            Continue;

          AUnit := Default(TUnit);
          AUnit.FileName := sFileName;
          FindUses(SyntaxTree, AUnit.ExistsUses, AUnit.UsesLocation);
          AUnit.Methods := Methods;
          Result := Result + [AUnit];
        finally
          SyntaxTree.Free;
        end;
      finally
        StringStream.Free;
      end;
    finally
      Builder.Free;
    end;
  end;
end;

class function TMapper.FindMethods(const Node: TSyntaxNode; const UnitName: String): TArray<TMethod>;
var
  ChildNode: TSyntaxNode;
  Method: TMethod;
  sName: String;
begin
  Result := [];

  if not Node.HasChildren then
    Exit;

  if Node.Typ <> ntMethod then
  begin
    for ChildNode in Node.ChildNodes do
      Result := Result + TMapper.FindMethods(ChildNode, UnitName);
    Exit;
  end;

  for ChildNode in Node.ChildNodes do
  begin
    if ChildNode.Typ <> ntStatements then
      Continue;

    Inc(FMethodID);
    Method := Default(TMethod);
    Method.ID := FMethodID;
    Method.UnitName := UnitName;
    sName := Node.GetAttribute(anName);
    if sName.Contains('.') then
    begin
      Method.ClassName := sName.Split(['.'])[0];
      Method.MethodName := sName.Split(['.'])[1];
    end
    else
    begin
      Method.ClassName := EmptyStr;
      Method.MethodName := sName;
    end;
    Method.BeginLocation := TLocation.Create(TCompoundSyntaxNode(ChildNode).Line, TCompoundSyntaxNode(ChildNode).Col);
    Method.EndLocation := TLocation.Create(TCompoundSyntaxNode(ChildNode).EndLine, TCompoundSyntaxNode(ChildNode).EndCol);
    Result := Result + [Method];
  end;
end;

class procedure TMapper.FindUses(const Node: TSyntaxNode; out Exists: Boolean; out Location: TLocation);
var
  ChildNode: TSyntaxNode;
  ChildNode2: TSyntaxNode;
  iPosLine: Integer;
  iPosCol: Integer;
  sTipo: String;
begin
  iPosLine := -1;
  iPosCol := -1;

  for ChildNode in Node.ChildNodes do
  begin
    if not (ChildNode.Typ in [ntImplementation, ntInterface]) then
      Continue;

    case ChildNode.Typ of
      ntImplementation: sTipo := 'implementation';
      ntInterface: sTipo := 'interface';
    end;

    iPosLine := ChildNode.Line;
    iPosCol := ChildNode.Col;

    for ChildNode2 in ChildNode.ChildNodes do
    begin
      if ChildNode2.Typ = ntUses then
      begin
        Exists := True;
        Location := TLocation.Create(ChildNode2.Line, ChildNode2.Col);
        Exit;
      end;
    end;
  end;

  if iPosLine = -1 then
    raise Exception.Create('Implementation and Interface not found!');

  Exists := False;
  Location := TLocation.Create(iPosLine, iPosCol + Length(sTipo));
end;

class procedure TMapper.Enable(Units: TUnits);
var
  sl: TStringList;
  AUnit: TUnit;
  Method: TMethod;
begin
  sl := TStringList.Create;
  try
    for AUnit in Units do
    begin
      sl.LoadFromFile(AUnit.FileName);

      if sl.Text.IndexOf('{$IFDEF '+ DIRECTIVE +'}') >= 0 then
        Continue;

      if AUnit.ExistsUses then
        sl[Pred(AUnit.UsesLocation.Line)] := sl[Pred(AUnit.UsesLocation.Line)].Insert(AUnit.UsesLocation.Col + Length('uses'), USES_EXISTS)
      else
        sl[Pred(AUnit.UsesLocation.Line)] := sl[Pred(AUnit.UsesLocation.Line)].Insert(AUnit.UsesLocation.Col, USES_UNEXISTS);

      for Method in AUnit.Methods do
      begin
        sl[Pred(Method.BeginLocation.Line)] := sl[Pred(Method.BeginLocation.Line)].Insert(Method.BeginLocation.Col + Pred(Length('begin')), Format(BEGIN_LOG, [Method.ID]));
        sl[Pred(Method.EndLocation.Line)] := sl[Pred(Method.EndLocation.Line)].Insert(Method.EndLocation.Col - Length('end;'), Format(END_LOG, [Method.ID]));
      end;

      sl.SaveToFile(AUnit.FileName);
    end;
  finally
    sl.Free;
  end;
end;

class procedure TMapper.Disable(Units: TUnits);
var
  ss: TStringStream;
  AUnit: TUnit;
  Method: TMethod;
  sConteudo: String;
begin
  ss := TStringStream.Create;
  try
    for AUnit in Units do
    begin
      ss.LoadFromFile(AUnit.FileName);

      sConteudo := ss.DataString;

      if sConteudo.IndexOf('{$IFDEF '+ DIRECTIVE +'}') < 0 then
        Continue;

      if AUnit.ExistsUses then
        sConteudo := sConteudo.Replace(USES_EXISTS, EmptyStr)
      else
        sConteudo := sConteudo.Replace(USES_UNEXISTS, EmptyStr);

      for Method in AUnit.Methods do
      begin
        sConteudo := sConteudo.Replace(Format(BEGIN_LOG, [Method.ID]), EmptyStr);
        sConteudo := sConteudo.Replace(Format(END_LOG, [Method.ID]), EmptyStr);
      end;

      ss.Clear;
      ss.WriteString(sConteudo);
      ss.SaveToFile(AUnit.FileName);
    end;
  finally
    ss.Free;
  end;
end;

{ THUnits }

procedure THUnits.SaveToFile(sFileName: String);
var
  js: TJsonSerializer;
  ss: TStringStream;
begin
  js := TJsonSerializer.Create;
  try
    ss := TStringStream.Create(js.Serialize(Self));
    try
      ss.SaveToFile(sFileName);
    finally
      ss.Free;
    end;
  finally
    js.Free;
  end;
end;

procedure THUnits.LoadToFile(sFileName: String);
var
  js: TJsonSerializer;
  ss: TStringStream;
begin
  ss := TStringStream.Create;
  try
    ss.LoadFromFile(sFileName);
    js := TJsonSerializer.Create;
    try
      Self := js.Deserialize<TUnits>(ss.DataString);
    finally
      js.Free;
    end;
  finally
    ss.Free;
  end;
end;

function THUnits.Method(ID: Integer): TMethod;
var
  AUnit: TUnit;
  AMethod: TMethod;
begin
  for AUnit in Self do
    for AMethod in AUnit.Methods do
      if AMethod.ID = ID then
        Exit(AMethod);
end;

end.
