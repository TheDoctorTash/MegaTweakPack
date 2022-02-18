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

unit UI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  VCL.Graphics, VCL.Controls, VCL.Forms, VCL.Dialogs, VCL.ComCtrls,
  VCL.StdCtrls, VCL.ExtCtrls, VCL.Buttons, VCL.Menus, IFEO, System.ImageList,
  Vcl.ImgList;

type
  TExecListDialog = class(TForm)
    GroupBoxActions: TGroupBox;
    ListViewExec: TListView;
    EditImage: TEdit;
    LabelImagePath: TLabel;
    ButtonBrowse: TButton;
    EditExec: TEdit;
    ButtonBrowseExec: TButton;
    OpenDlg: TOpenDialog;
    LabelNote: TLabel;
    ButtonRefresh: TBitBtn;
    ButtonDelete: TButton;
    ButtonAdd: TButton;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuRunAsAdmin: TMenuItem;
    MenuSource: TMenuItem;
    N1: TMenuItem;
    MenuReg: TMenuItem;
    MenuUnreg: TMenuItem;
    N2: TMenuItem;
    RadioButtonAsk: TRadioButton;
    RadioButtonBlock: TRadioButton;
    RadioButtonElevate: TRadioButton;
    RadioButtonNoSleep: TRadioButton;
    RadioButtonDisplayOn: TRadioButton;
    RadioButtonDrop: TRadioButton;
    RadioButtonError: TRadioButton;
    ComboBoxErrorCodes: TComboBox;
    RadioButtonExecute: TRadioButton;
    ImageList: TImageList;
    procedure ButtonBrowseClick(Sender: TObject);
    procedure ButtonBrowseExecClick(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
    procedure ComboBoxErrorCodesClick(Sender: TObject);
    procedure Refresh(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewExecChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure MenuRunAsAdminClick(Sender: TObject);
    procedure MenuRegClick(Sender: TObject);
    procedure MenuUnregClick(Sender: TObject);
    procedure MenuSourceClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Core: TImageFileExecutionOptions;
    CurrentAction: TAction;
    procedure DisableActions;
    procedure InitMenuShieldIcon;
  end;

var
  ExecListDialog: TExecListDialog;

implementation

uses ProcessUtils, Winapi.ShellApi, ShellExtension, MessageDialog,
  Winapi.ShlObj, Winapi.ShLwApi;

const
  GITHUB_PAGE = 'https://github.com/diversenok/ExecutionMaster';

  ERR_ACTION_VERB = 'Некоторые компоненты отсутствуют';
  ERR_ACTION = 'Не удается найти исполняемый файл, выполняющий указанное действие.';

  ERR_ONLYNAME_VERB = 'Имя исполняемого файла';
  ERR_ONLYNAME = '"Имя исполняемого файла" должно содержать только имя файла, а не путь.';

  ERR_WOW64_VERB = 'WOW64 is detected';
  ERR_WOW64 = 'Похоже, вы используете 32-битную версию программы на ' +
    '64-битной операционной системе. Вы должны использовать 64-битную версию ' +
    'ExecutionMaster, в противном случае будут доступны только действия отказа.';

  ERR_EMCSHELL_VERB = 'Не удается установить расширение Shell';
  ERR_EMCSHELL = 'Компонент EMCShell отсутствует.';

  INFO_REG_VERB = 'Успешно';
  INFO_REG = 'Расширение оболочки успешно зарегистрировано.';
  INFO_UNREG = 'Расширение оболочки успешно удалено.';

{$R *.dfm}

procedure TExecListDialog.ButtonBrowseClick(Sender: TObject);
begin
  if OpenDlg.Execute then
    EditImage.Text := ExtractFileName(OpenDlg.FileName);
end;

procedure TExecListDialog.ButtonBrowseExecClick(Sender: TObject);
begin
  if OpenDlg.Execute then
    EditExec.Text := '"' + OpenDlg.FileName + '"';
end;

procedure TExecListDialog.RadioButtonClick(Sender: TObject);
begin
  if Sender is TRadioButton then
    CurrentAction := TAction((Sender as TRadioButton).Tag);

  if RadioButtonError.Checked then
    CurrentAction := TAction(Integer(aDenySilently) +
      ComboBoxErrorCodes.ItemIndex);

  EditExec.Enabled := RadioButtonExecute.Checked;
  ButtonBrowseExec.Enabled := RadioButtonExecute.Checked;
end;

procedure TExecListDialog.ComboBoxErrorCodesClick(Sender: TObject);
begin
  RadioButtonError.Checked := True;
  RadioButtonClick(RadioButtonError);
end;

procedure TExecListDialog.Refresh(Sender: TObject);
var
  i: Integer;
begin
  if (Sender <> ButtonAdd) and (Sender <> ButtonDelete) then
  begin
    Core.Free;
    Core := TImageFileExecutionOptions.Create;
  end;
  ListViewExec.Items.BeginUpdate;
  ListViewExec.Items.Clear;
  for i := 0 to Core.Count - 1 do
    with ListViewExec.Items.Add do
    begin
      Caption := Core.Debuggers[i].TreatedFile;
      SubItems.Add(Core.Debuggers[i].GetCaption)
    end;
  ListViewExec.Items.EndUpdate;
end;

procedure TExecListDialog.ListViewExecChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if Change = ctState then
  begin
    ButtonDelete.Enabled := ListViewExec.SelCount <> 0;
    if ListViewExec.SelCount <> 0 then
      with Core.Debuggers[ListViewExec.Selected.Index] do
      begin
        EditImage.Text := TreatedFile;
        case Action of
          aAsk: RadioButtonAsk.Checked := True;
          aDrop: RadioButtonDrop.Checked := True;
          aElevate: RadioButtonElevate.Checked := True;
          aNoSleep: RadioButtonNoSleep.Checked := True;
          aDisplayOn: RadioButtonDisplayOn.Checked := True;
          aDenyAndNotify: RadioButtonBlock.Checked := True;
          aDenySilently..aDenyNotWin32:
          begin
            RadioButtonError.Checked := True;
            ComboBoxErrorCodes.ItemIndex := Integer(Action) - Integer(aDenySilently);
          end;
          aExecuteEx:
          begin
            RadioButtonExecute.Checked := True;
            EditExec.Text := DebuggerStr;
          end;
        end;
      end;
  end;
end;

procedure TExecListDialog.ButtonAddClick(Sender: TObject);
var
  i: Integer;
begin
  if CurrentAction in [Low(TFileBasedAction)..High(TFileBasedAction)] then
    if not FileExists(Copy(EMDebuggers[CurrentAction], 2,
      Pos('"', EMDebuggers[CurrentAction], 2) - 2)) then // Only file without params
    begin
      ShowMessageEx(Handle, PROGRAM_NAME, ERR_ACTION_VERB, ERR_ACTION, miError,
        [mbOk]);
      Exit;
    end;

  if (Length(EditImage.Text) = 0) or (Pos('\', EditImage.Text) <> 0) or
    (Pos('/', EditImage.Text) <> 0) or (Pos('"', EditImage.Text) <> 0) then
  begin
    ShowMessageEx(Handle, PROGRAM_NAME, ERR_ONLYNAME_VERB, ERR_ONLYNAME,
      miError, [mbOk]);
    Exit;
  end;

  for i := Low(DangerousProcesses) to High(DangerousProcesses) do
    if LowerCase(EditImage.Text) = DangerousProcesses[i] then
      if ShowMessageEx(Handle, PROGRAM_NAME, ARE_YOU_SURE, Format(WARN_SYSPROC,
        [EditImage.Text]), miWarning, [mbYes, mbNo]) <> IDYES then
        Exit;

  if CurrentAction in [aAsk..aDisplayOn, aExecuteEx] then
  begin
    for i := Low(CompatibilityProblems) to High(CompatibilityProblems) do
      if LowerCase(EditImage.Text) = CompatibilityProblems[i] then
        if ShowMessageEx(Handle, PROGRAM_NAME, ARE_YOU_SURE, Format(WARN_COMPAT,
          [EditImage.Text]), miWarning, [mbYes, mbNo]) <> IDYES then
          Exit;

    for i := Low(UIAccessPrograms) to High(UIAccessPrograms) do
      if LowerCase(EditImage.Text) = UIAccessPrograms[i] then
        if ShowMessageEx(Handle, PROGRAM_NAME, ARE_YOU_SURE, Format(
          WARN_UIACCESS, [EditImage.Text]), miWarning, [mbYes, mbNo]) <> IDYES
          then Exit;
  end;

  Core.AddDebugger(TIFEORec.Create(CurrentAction, EditImage.Text,
    EditExec.Text));
  Refresh(ButtonAdd);
  ListViewExecChange(Sender, ListViewExec.Selected, ctState);
end;

procedure TExecListDialog.ButtonDeleteClick(Sender: TObject);
begin
  if ListViewExec.SelCount = 0 then
  begin
    ListViewExecChange(Sender, ListViewExec.Selected, ctState);
    Exit;
  end;
  Core.DeleteDebugger(ListViewExec.Selected.Index);
  Refresh(ButtonDelete);
  ListViewExecChange(Sender, ListViewExec.Selected, ctState);
end;

procedure TExecListDialog.DisableActions;
begin
  RadioButtonAsk.Enabled := False;
  RadioButtonDrop.Enabled := False;
  RadioButtonElevate.Enabled := False;
  RadioButtonNoSleep.Enabled := False;
  RadioButtonDisplayOn.Enabled := False;
  RadioButtonBlock.Checked := True;
end;

procedure TExecListDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Core.Free;
end;

procedure TExecListDialog.FormCreate(Sender: TObject);
var
  IsWow64: LongBool;
begin
  if IsWow64Process(GetCurrentProcess, IsWow64) and IsWow64 then
  begin
    ShowMessageEx(Handle, PROGRAM_NAME, ERR_WOW64_VERB, ERR_WOW64, miWarning,
      [mbOk]);
    DisableActions;
  end;

  ElvationHandle := Handle;
  Application.HintHidePause := 20000;
  Constraints.MinHeight := Height;
  MenuRunAsAdmin.Enabled := not ProcessIsElevated;
  ButtonAdd.ElevationRequired := not ProcessIsElevated;
  ButtonDelete.ElevationRequired := not ProcessIsElevated;
  SHAutoComplete(EditExec.Handle, SHACF_FILESYS_ONLY);
  if not ProcessIsElevated then
    InitMenuShieldIcon;
  Refresh(Sender);
end;

procedure TExecListDialog.InitMenuShieldIcon;
var
  SII: TSHStockIconInfo;
  Small, Large: HICON;
  Icon: TIcon;
begin
  FillChar(SII, SizeOf(SII), 0);
  SII.cbSize := SizeOf(SII);

  if SHGetStockIconInfo(SIID_SHIELD, SHGSI_ICONLOCATION, SII) <> S_OK then
    Exit;
  if SHDefExtractIcon(SII.szPath, SII.iIcon, 0, Large, Small, 16) <> S_OK then
    Exit;

  DestroyIcon(Large);
  Icon := TIcon.Create;
  Icon.Handle := Small;
  MenuRunAsAdmin.ImageIndex := ImageList.AddIcon(Icon);
  Icon.Free;
end;

{ Menu items }

procedure TExecListDialog.MenuRunAsAdminClick(Sender: TObject);
begin
  ElevetedExecute(Handle, ParamStr(0), '', False, SW_SHOWNORMAL);
  Close;
end;

procedure TExecListDialog.MenuRegClick(Sender: TObject);
begin
  if FileExists(ExtractFilePath(ParamStr(0)) + 'EMCShell.exe') then
  begin
    RegShellMenu(ExtractFilePath(ParamStr(0)) + 'EMCShell.exe');
    ShowMessageEx(Handle, PROGRAM_NAME, INFO_REG_VERB, INFO_REG, miInformation,
      [mbOk]);
  end
  else
    ShowMessageEx(Handle, PROGRAM_NAME, ERR_EMCSHELL_VERB, ERR_EMCSHELL,
      miError, [mbOk])
end;

procedure TExecListDialog.MenuUnregClick(Sender: TObject);
begin
  UnregShellMenu;
  ShowMessageEx(Handle, PROGRAM_NAME, INFO_REG_VERB, INFO_UNREG, miInformation,
    [mbOk]);
end;

procedure TExecListDialog.MenuSourceClick(Sender: TObject);
var
  ExecInfo: TShellExecuteInfoW;
begin
  FillChar(ExecInfo, SizeOf(ExecInfo), 0);
  with ExecInfo do
  begin
    cbSize := SizeOf(ExecInfo);
    Wnd := Handle;
    lpVerb := PWideChar('open');
    lpFile := PWideChar(GITHUB_PAGE);
    fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_UNICODE or SEE_MASK_FLAG_NO_UI;
    if not ShellExecuteExW(@ExecInfo) then
      RaiseLastOSError;
  end;
end;

end.
