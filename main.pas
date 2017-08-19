unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  AsyncProcess, ShellAPI, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    AsyncProcess1: TAsyncProcess;
    btChocoRun: TButton;
    btChocoInstall: TButton;
    btViewList: TButton;
    btUpgrade: TButton;
    btRefreshList: TButton;
    Memo1: TMemo;
    procedure btChocoRunClick(Sender: TObject);
    procedure btChocoInstallClick(Sender: TObject);
    procedure btRefreshListClick(Sender: TObject);
    procedure btUpgradeClick(Sender: TObject);
    procedure btViewListClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
    procedure execbat();
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function IsFileInUse(fName: string) : boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(fName) then begin
    Exit;
  end;

  HFileRes := CreateFile(PChar(fName)
    ,GENERIC_READ or GENERIC_WRITE
    ,0
    ,nil
    ,OPEN_EXISTING
    ,FILE_ATTRIBUTE_NORMAL
    ,0);

  Result := (HFileRes = INVALID_HANDLE_VALUE);

  if not(Result) then begin
    CloseHandle(HFileRes);
  end;
end;

procedure TForm1.btChocoRunClick(Sender: TObject);
var I :  Integer;  s : TStringList;
begin
   s:=TStringList.Create;
   for I:=0 to memo1.lines.count-1 do
    begin
      s.add('choco install '+memo1.Lines[i]+' -Y');
    end;
   s.savetofile('temp.bat');
   execbat;
end;

procedure TForm1.btChocoInstallClick(Sender: TObject);
var s : TStringList;
begin
   s:=TStringList.create;
   s.add('@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString(''https://chocolatey.org/install.ps1''))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"');
   s.SaveToFile('temp.bat');
   execbat;
   s.free;
end;

procedure TForm1.btRefreshListClick(Sender: TObject);
var s:tstringlist;
begin
s:=tstringlist.create;
s.add('choco install curl -Y');
s.add('choco upgrade curl -Y');
s.add('curl -k -o p.txt https://raw.githubusercontent.com/artnazarov/runchoco/master/packages.txt');
s.savetofile('temp.bat');
execbat();
s.free;
while not fileexists('p.txt') do;
while isfileinuse('p.txt') do;
memo1.lines.LoadFromFile('p.txt');
if memo1.lines.Count<10 then btRefreshList.Click();
deletefile('p.txt');
end;

procedure TForm1.btUpgradeClick(Sender: TObject);
var s : TStringList;
begin
 s:=TStringList.create;
 s.add('choco feature enable -n allowGlobalConfirmation');
 s.add('choco upgrade all');
 s.SaveToFile('temp.bat');
 execbat();
 s.free();
end;

procedure TForm1.btViewListClick(Sender: TObject);
begin
   memo1.Visible:= not memo1.visible;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if fileexists('p.txt') then deletefile('p.txt');
  if fileexists('temp.bat') then deletefile('temp.bat');
end;

procedure TForm1.execbat;
var scmd1, scmd2 : String;
begin
      scmd1:='cmd';
  scmd2:='/K temp.bat';
  ShellExecute(form1.handle, PChar ('open'), PChar(scmd1), PChar(scmd2), nil, 1);

end;

end.

