{   ExecutionMaster component.
    Copyright (C) 2017-2018 diversenok 

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>    }

program emc;

{$APPTYPE CONSOLE}
{$WEAKLINKRTTI ON}

{$R *.res}

uses
  System.SysUtils,
  Winapi.Windows,
  System.Masks,
  IFEO in 'Include\IFEO.pas',
  ProcessUtils in 'Include\ProcessUtils.pas',
  CmdUtils in 'Include\CmdUtils.pas',
  Registry2 in 'Include\Registry2.pas';

const
  USAGE = {$INCLUDE emcusage.txt};

procedure Help;
begin
  writeln(USAGE);
  ExitCode := ERROR_INVALID_PARAMETER;
  Halt;
end;

procedure ActionQuery;
var
  Core: TImageFileExecutionOptions;
  i: integer;
  Found: Boolean;
begin
  Found := False;
  try
    Core := TImageFileExecutionOptions.Create;
    for i := 0 to Core.Count - 1 do
      with Core[i] do
      begin
        if ParamCount >= 2 then
          if not MatchesMask(TreatedFile, ParamStr(2)) then
            Continue;
        writeln(Format('[*] %s --> %s', [TreatedFile, GetCaption]));
        Found := True;
      end;
    if not Found then
      writeln('Nothing found.');
  finally
    FreeAndNil(Core);
  end;
end;

procedure ActionReset;
var
  Core: TImageFileExecutionOptions;
  i: integer;
begin
  try
    Core := TImageFileExecutionOptions.Create;
    for i := 0 to Core.Count - 1 do
      with Core[i] do
      begin
        if ParamCount >= 2 then
          if not MatchesMask(TreatedFile, ExtractFileName(ParamStr(2))) then
            Continue;
        writeln(Format('[-] Deleting action for %s', [TreatedFile]));
        Core.UnregisterDebugger(TreatedFile);
      end;
  finally
    FreeAndNil(Core);
  end;
end;

{ We don't need to parse this part of command line � user is free at using
  quotes and spaces now. }
function GetExec: string;
begin
  if ParamCount < 4 then
    raise Exception.Create('Need command line for "execute" action. See help.');
  Result := ParamsStartingFrom(4);
end;

procedure CheckForProblems(Executable: String; Action: TAction);
const
  WARN = ' [y/n]: ';
  ERR_CANCELED = 'Canceled by user.';
var
  Answer: string;
  i: integer;
begin
  for i := Low(DangerousProcesses) to High(DangerousProcesses) do
    if LowerCase(Executable) = DangerousProcesses[i] then
    begin
      write(Format(WARN_SYSPROC + WARN, [Executable]));
      readln(Answer);
      if LowerCase(Answer) <> 'y' then
        raise Exception.Create(ERR_CANCELED);
      Break;
    end;

  if Action in [aAsk..aDisplayOn, aExecuteEx] then
  begin
    for i := Low(CompatibilityProblems) to High(CompatibilityProblems) do
      if LowerCase(Executable) = CompatibilityProblems[i] then
      begin
        write(Format(WARN_COMPAT + WARN, [Executable]));
        readln(Answer);
        if LowerCase(Answer) <> 'y' then
          raise Exception.Create(ERR_CANCELED);
        Break;
      end;

    for i := Low(UIAccessPrograms) to High(UIAccessPrograms) do
      if LowerCase(Executable) = UIAccessPrograms[i] then
      begin
        write(Format(WARN_UIACCESS + WARN, [Executable]));
        readln(Answer);
        if LowerCase(Answer) <> 'y' then
          raise Exception.Create(ERR_CANCELED);
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
    raise Exception.Create('Not enough parameters.');

  for a := Low(TAction) to High(TAction) do
    if LowerCase(ParamStr(3)) = ActionShortNames[a] then
      Break;

  if LowerCase(ParamStr(3)) = 'raise' then
  begin
    if ParamCount >= 4 then
      a := ErrorCodeToAction(StrToInt(ParamStr(4)))
    else
      a := aDenyAccess;
  end;

  if a = Succ(High(TAction)) then // for-cycle finished without breaking
    raise Exception.Create('Unknown action.');

  if a in [Low(TFileBasedAction)..High(TFileBasedAction)] then
    if not FileExists(Copy(EMDebuggers[a], 2,
      Pos('"', EMDebuggers[a], 2) - 2)) then // Only file without params
      raise Exception.Create(ERR_ACTION);

  executable := ExtractFileName(ParamStr(2));
  CheckForProblems(executable, a);

  if a = aExecuteEx then
    Dbg := TIFEORec.Create(a, executable, GetExec)
  else
    Dbg := TIFEORec.Create(a, executable);
  writeln(Format('[+] %s --> %s', [Dbg.TreatedFile, Dbg.GetCaption]));
  TImageFileExecutionOptions.RegisterDebugger(Dbg);
end;

begin
  try
    write('ExecutionMaster ');
{$IFDEF WIN64}
    write('x64');
{$ELSE}
    write('x86');
{$ENDIF}
    writeln(' [console] v1.4 Copyright (C) 2017-2018 diversenok');
    if IsElevated then
      writeln('Current process: elevated')
    else
      writeln('Current process: non-elevated');
    writeln;

    if ParamCount = 0 then
      Help;

    if LowerCase(ParamStr(1)) = 'query' then
      ActionQuery
    else if LowerCase(ParamStr(1)) = 'set' then
      ActionSet
    else if LowerCase(ParamStr(1)) = 'reset' then
      ActionReset
    else
      Help;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
