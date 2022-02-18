{ ExecutionMaster component.
  Copyright (C) 2018 diversenok

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/> }

program EMCShell;

{$WEAKLINKRTTI ON}
{$R *.res}

uses
  System.SysUtils,
  Winapi.Windows,
  IFEO in 'Include\IFEO.pas',
  Registry2 in 'Include\Registry2.pas',
  CmdUtils in 'Include\CmdUtils.pas',
  ProcessUtils in 'Include\ProcessUtils.pas',
  ShellExtension in 'Include\ShellExtension.pas',
  MessageDialog in 'Include\MessageDialog.pas';

const
  PROGRAM_NAME = 'Расширение оболочки Execution Master';

procedure ShowStatusMessage(Verb: String; Text: String = '';
  Icon: TMessageIcon = miInformation);
begin
  ShowMessageOk(PROGRAM_NAME, Verb, Text, Icon);
end;

procedure ActionReset;
var
  Core: TImageFileExecutionOptions;
  executable: String;
  i: integer;
begin
  executable := ExtractFileName(ParamStr(2));
  try
    Core := TImageFileExecutionOptions.Create;
    for i := 0 to Core.Count - 1 do
    begin
      if ParamCount >= 2 then
        if Core[i].TreatedFile <> executable then
          Continue;
      Core.UnregisterDebugger(Core[i].TreatedFile);
      Break;
    end;
  finally
    FreeAndNil(Core);
  end;
  ShowStatusMessage('Действие успешно сброшено.', executable);
end;

procedure CheckerUI(Text: string);
begin
  if ShowMessageYesNo(PROGRAM_NAME, 'Вы уверены?', Text, miWarning) <> IDYES
    then
    raise Exception.Create('Операция отменена пользователем.');
end;

procedure CheckForProblems(Action: TAction; S: String);
var
  i: integer;
begin
  for i := Low(DangerousProcesses) to High(DangerousProcesses) do
    if LowerCase(S) = DangerousProcesses[i] then
    begin
      CheckerUI(Format(WARN_SYSPROC, [S]));
      Break;
    end;

  if Action in [aAsk..aDisplayOn, aExecuteEx] then
  begin
    for i := Low(CompatibilityProblems) to High(CompatibilityProblems) do
      if LowerCase(S) = CompatibilityProblems[i] then
      begin
        CheckerUI(Format(WARN_COMPAT, [S]));
        Break;
      end;

    for i := Low(UIAccessPrograms) to High(UIAccessPrograms) do
      if LowerCase(S) = UIAccessPrograms[i] then
      begin
        CheckerUI(Format(WARN_UIACCESS, [S]));
        Break;
      end;
  end;
end;

procedure ActionSet;
var
  a: TAction;
  Dbg: TIFEORec;
  executable: string;
begin
  if ParamCount < 3 then
    raise Exception.Create('Недостаточно параметров.');

  for a := Low(TAction) to Pred(High(TAction)) do // not including aExecuteEx!
    if LowerCase(ParamStr(3)) = ActionShortNames[a] then
      Break;
  if a = High(TAction) then // for-cycle finished without breaking
    raise Exception.Create('Неизвестное действие.');

  if a in [Low(TFileBasedAction)..High(TFileBasedAction)] then
    if not FileExists(Copy(EMDebuggers[a], 2,
      Pos('"', EMDebuggers[a], 2) - 2)) then // Only file without params
    raise Exception.Create(ERR_ACTION);

  executable := ExtractFileName(ParamStr(2));
  CheckForProblems(a, executable);
  Dbg := TIFEORec.Create(a, executable);
  TImageFileExecutionOptions.RegisterDebugger(Dbg);
  ShowStatusMessage('Действие успешно установлено.', executable + '  →  ' +
    Dbg.GetCaption);
end;

begin
  try
    if ParamCount >= 1 then
    begin
      if LowerCase(ParamStr(1)) = 'set' then
        ActionSet
      else if LowerCase(ParamStr(1)) = 'reset' then
        ActionReset
      else if LowerCase(ParamStr(1)) = '/reg' then
      begin
        RegShellMenu(ParamStr(0));
        ShowStatusMessage('Расширение оболочки успешно зарегистрировано.');
      end
      else if LowerCase(ParamStr(1)) = '/unreg' then
      begin
        UnregShellMenu;
        ShowStatusMessage('Расширение оболочки успешно отменено.');
      end;
    end
    else
      ShowStatusMessage('Использование:',
        'EMCShell.exe /reg - зарегистрировать расширение оболочки;'#$D#$A +
        'EMCShell.exe /unreg - отменить регистрацию расширения оболочки.'#$D#$A);
  except
    on E: Exception do
      ShowStatusMessage('Действие не было зарегистрировано:', E.ToString, miError);
  end;
end.
