; CursorIDE-ContextMenuSetup.iss
; Instalador de menú contextual para Cursor IDE con opción de buscar ejecutable manualmente
; Compatible con Windows 10 y 11

[Setup]
AppName=Cursor IDE Context Menu
AppVersion=1.1
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
  { Buscar en AppData }
  found := ExpandConstant('{userappdata}\Local\Programs\cursor\Cursor.exe');
  if FileExists(found) then
  begin
    Result := found;
    exit;
  end;

  { Buscar en Program Files }
  found := ExpandConstant('{pf}\Cursor\Cursor.exe');
  if FileExists(found) then
  begin
    Result := found;
    exit;
  end;

  { Preguntar al usuario si no se encontró nada }
  if GetOpenFileName('No se encontró Cursor.exe en las ubicaciones habituales. Selecciónalo manualmente:', found, '', 'Archivos ejecutables|*.exe', 'Cursor.exe') then
  begin
    Result := found;
    exit;
  end;

  Result := '';
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
      MsgBox('No se encontró Cursor.exe. La instalación no puede continuar.', mbError, MB_OK);
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
