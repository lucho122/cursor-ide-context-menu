; CursorIDE_ContextMenu.iss
; Instalador para añadir menú contextual de Cursor IDE con soporte multilenguaje
; Compatible Windows 10 y 11

[Setup]
AppName=Cursor IDE Context Menu
AppVersion=1.0
DefaultDirName={autopf}\Cursor IDE Context
DefaultGroupName=Cursor IDE Context Menu
DisableProgramGroupPage=yes
OutputBaseFilename=CursorIDE_ContextMenu
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "french";  MessagesFile: "compiler:Languages\French.isl"

[Code]
function FindCursorExe(): String;
var
  found: String;
begin
  { Intenta buscar en la ubicación típica del instalador de Cursor }
  found := ExpandConstant('{userappdata}\Local\Programs\cursor\Cursor.exe');
  if FileExists(found) then
  begin
    Result := found;
    exit;
  end;

  { Si no lo encuentra, intenta buscar en la variable de entorno PATH (opcional) }
  found := ExpandConstant('{pf}\Cursor\Cursor.exe');
  if FileExists(found) then
  begin
    Result := found;
    exit;
  end;

  Result := '';  // no encontrado
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  lang, regText, cursorPath: String;
begin
  if CurStep = ssPostInstall then
  begin
    cursorPath := FindCursorExe();
    if cursorPath = '' then
    begin
      MsgBox('No se encontró Cursor.exe en las ubicaciones habituales. Por favor instala Cursor antes de usar este menú contextual.', mbError, MB_OK);
      exit;
    end;

    lang := ExpandConstant('{language}');
    if lang = 'spanish' then
      regText := 'Abrir con Cursor IDE'
    else if lang = 'french' then
      regText := 'Ouvrir avec Cursor IDE'
    else
      regText := 'Open with Cursor IDE';

    RegWriteStringValue(HKEY_CLASSES_ROOT, 'Directory\shell\OpenWithCursorIDE', '', regText);
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'Directory\shell\OpenWithCursorIDE', 'Icon', cursorPath);
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'Directory\shell\OpenWithCursorIDE\command', '', '"' + cursorPath + '" "%1"');
  end;
end;

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
