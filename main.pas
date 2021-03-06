unit main;

{$mode objfpc}{$H+}
// replace os to win on compilation
{$define win}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  AsyncProcess, ExtCtrls, ComCtrls, CheckLst
  {$ifdef win}
  ,  Windows
  {$endif}
  ;
const
  SAMDRIVERS_HEX_CODE : String = '6D61676E65743A3F78743D75726E3A627469683A3437653030383938333339373331633334333537303339623564626262326130383761303462626526646E3D7275746F722E696E666F5F53616D447269766572732B31372E372B2D2B2544302541312544302542312544302542452544312538302544302542442544302542382544302542412B2544302542342544312538302544302542302544302542392544302542322544302542352544312538302544302542452544302542322B2544302542342544302542422544312538462B2544302542322544312538312544302542352544312538352B57696E646F77732B253238323031372532392B50432B2537432B46554C4C2B2D2B49534F2674723D7564703A2F2F6F70656E746F722E6F72673A323731302674723D7564703A2F2F6F70656E746F722E6F72673A323731302674723D687474703A2F2F7265747261636B65722E6C6F63616C2F616E6E6F756E6365';
  MINSTALL_HEX_CODE : String = '6D61676E65743A3F78743D75726E3A627469683A3862343366366135376133393564633531323763643663343035376332613333376166306462333526646E3D7275746F722E696E666F2674723D7564703A2F2F6F70656E746F722E6F72673A323731302674723D7564703A2F2F6F70656E746F722E6F72673A323731302674723D687474703A2F2F7265747261636B65722E6C6F63616C2F616E6E6F756E6365';
  BELOFF_HEX_CODE : String = '6D61676E65743A3F78743D75726E3A627469683A3937373136396538376437396434376636316366616131336137346230373735343263316662636126646E3D7275746F722E696E666F2674723D7564703A2F2F6F70656E746F722E6F72673A323731302674723D7564703A2F2F6F70656E746F722E6F72673A323731302674723D687474703A2F2F7265747261636B65722E6C6F63616C2F616E6E6F756E6365';

type


  { TExecuteExt }

  TExecuteExt = class(TThread)
    public
      WND : HWND;
      scmd1,  scmd2 : String;
      optShowWindow, optWait : Boolean;
         Constructor Create(CreateSuspended : boolean);

    procedure JobRun;
    private
      fStatusText : string;
      procedure status;
    protected
    procedure Execute; override;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    AsyncProcess1: TAsyncProcess;
    btChocoInstall: TButton;
    btChocoRun: TButton;
    btRefreshList: TButton;
    btUpgrade: TButton;
    btViewList: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Apps: TCheckListBox;
    btCheatCode: TButton;
    btRemovePackages: TButton;
    btSearch: TButton;
    btInstalledApps: TButton;
    edCheatCode: TEdit;
    edSearch: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lDiv1: TLabel;
    lDiv2: TLabel;
    lInvertAll: TLabel;
    lSelectAll: TLabel;
    lSkipAll: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    pApps: TPanel;
    Info: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    tabCheating: TTabSheet;
    procedure btCheatCodeClick(Sender: TObject);
    procedure btChocoRunClick(Sender: TObject);
    procedure btChocoInstallClick(Sender: TObject);
    procedure btInstalledAppsClick(Sender: TObject);
    procedure btRefreshListClick(Sender: TObject);
    procedure btRemovePackagesClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure btUpgradeClick(Sender: TObject);
    procedure btViewListClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure lInvertAllClick(Sender: TObject);
    procedure lSelectAllClick(Sender: TObject);
    procedure lSkipAllClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    optShowWindow : boolean;
    optWait : boolean;
    procedure execbat();
    procedure disable_buttons;
    procedure enable_buttons;
    procedure write_to_bat(s : TStringList);
  end;

  function StringToHex(S: String): string;
function HexToString(H: String): String;

function StartProcess(ExeName: string; CmdLineArgs: string = '';
  ShowWindow: boolean = True; WaitForFinish: boolean = False): integer;
var
  Form1: TForm1;

implementation

function StartProcess(ExeName: string; CmdLineArgs: string = '';
  ShowWindow: boolean = True; WaitForFinish: boolean = False): integer;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
begin
form1.info.SimpleText:='Выполняется задача... ждите';
//form1.disable_buttons;
Application.ProcessMessages;
  //Simple wrapper for the CreateProcess command
  //returns the process id of the started process.
  FillChar(StartInfo,SizeOf(TStartupInfo),#0);
  FillChar(ProcInfo,SizeOf(TProcessInformation),#0);
  StartInfo.cb := SizeOf(TStartupInfo);

  if not(ShowWindow) then begin
    StartInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartInfo.wShowWindow := SW_HIDE;
  end;

  CreateProcess(nil,PChar(ExeName + ' ' + CmdLineArgs),nil,nil,False,
    CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS,nil,nil,StartInfo,
    ProcInfo);

  Result := ProcInfo.dwProcessId;

  if WaitForFinish then begin
    WaitForSingleObject(ProcInfo.hProcess,Infinite);
  end;

  //close process & thread handles
  CloseHandle(ProcInfo.hProcess);
  CloseHandle(ProcInfo.hThread);
   form1.info.SimpleText:='Выполнено';
   //form1.enable_buttons;
   Application.ProcessMessages;
end;





function StringToHex(S: String): string;
var I: Integer;
begin
  Result:= '';
  for I := 1 to length (S) do
    Result:= Result+IntToHex(ord(S[i]),2);
end;

function HexToString(H: String): String;
var I: Integer;
begin
  Result:= '';
  for I := 1 to length (H) div 2 do
    Result:= Result+Char(StrToInt('$'+Copy(H,(I-1)*2+1,2)));
end;

{$R *.lfm}

{ TForm1 }

procedure magnet(m : String);
var p : TAsyncProcess;
begin
p:=TAsyncProcess.Create(NIL);
 p.CommandLine:='C:\Program Files\qBittorrent\qbittorrent '+m;
 p.Execute;
end;

function IsFileInUse(fName: string) : boolean;
{$ifdef win}
var
  HFileRes: HFILE;
{$endif}
begin
{$ifdef win}
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
  {$endif}
end;

{ TExecuteExt }

constructor TExecuteExt.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

procedure TExecuteExt.JobRun;
begin
   scmd1:='cmd';
  scmd2:='/K temp.bat';
  {$ifdef win}
  if optShowWindow then

   ShellExecute(WND, PChar ('open'), PChar(scmd1), PChar(scmd2),nil,SW_SHOWNORMAL)
  else
    ShellExecute(WND, PChar ('open'), PChar(scmd1), PChar(scmd2),nil,SW_HIDE);
  {$endif}
  fStatusText:='Выполняется...';
  Synchronize(@status);
  Terminate;
end;

procedure TExecuteExt.status;
begin
  form1.Info.SimpleText:=fStatusText;
end;

procedure TExecuteExt.Execute;
begin
   JobRun;
end;

procedure TForm1.btChocoRunClick(Sender: TObject);
var I :  Integer;  s : TStringList;
begin
   s:=TStringList.Create;
   //memo1.clear;
   s.add('choco feature enable -n allowGlobalConfirmation');
   for I:=0 to apps.items.count-1 do
    begin
      if apps.Checked[i] then
      begin
      s.add('choco install '+apps.items[i]+' -y');
      //memo1.lines.add('choco install '+apps.items[i]+' -y');
      end;

    end;
   //memo1.visible:=true;
   write_to_bat(s);
   execbat;
end;

procedure TForm1.btCheatCodeClick(Sender: TObject);
begin
  if edCheatCode.Text = 'KIRA' then
     tabSheet2.TabVisible:=true;
  if edCheatCode.Text = 'SHOW-TERM' then
      optShowWindow:=true;
  if edCheatCode.Text = 'NO-WAIT' then
      optWait:=False;
end;

procedure TForm1.btChocoInstallClick(Sender: TObject);
var s : TStringList;
begin
   s:=TStringList.create;
   s.add('@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString(''https://chocolatey.org/install.ps1''))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"');
   write_to_bat(s);
   execbat;
   s.free;
end;

procedure TForm1.btInstalledAppsClick(Sender: TObject);
var s, f: TStringList;  n : String; i : Integer;
begin
 s:=TStringList.create;
 s.add('choco list --local-only > list.txt');
 write_to_bat(s);
 execbat();
 s.free();
 f:=TStringList.Create;
 apps.Clear;
while not fileexists('list.txt') do Application.ProcessMessages;
while isfileinuse('list.txt') do Application.ProcessMessages;
f.LoadFromFile('list.txt');
for i:=1 to f.count-2 do
     begin
     n:=Copy(f[i], 0, Pos(' ', f[i]));
     if (n<>'') then
        apps.Items.Add(n);
     end;

deletefile('list.txt');
if not apps.Visible then btViewList.Click;
i:=f.count-1;
n:=Copy(f[i], 0, Pos(' ', f[i]));
info.SimpleText:='Установлено '+n;
f.free;
end;

procedure TForm1.btRefreshListClick(Sender: TObject);
var s:tstringlist; i : integer;
begin
s:=tstringlist.create;
s.add('choco install curl -Y');
s.add('choco upgrade curl -Y');
s.add('curl -k -o p.txt https://raw.githubusercontent.com/artnazarov/runchoco/master/packages.txt');
write_to_bat(s); ;
execbat();
s.free;
while not fileexists('p.txt') do Application.ProcessMessages;
while isfileinuse('p.txt') do Application.ProcessMessages;
memo1.lines.LoadFromFile('p.txt');
if memo1.lines.Count<10 then btRefreshList.Click();
deletefile('p.txt');
apps.Clear;
for i:=0 to memo1.Lines.Count-1 do apps.Items.Append(memo1.Lines[i]);
end;

procedure TForm1.btRemovePackagesClick(Sender: TObject);
var I :  Integer;  s : TStringList;
begin
   s:=TStringList.Create;
   for I:=0 to apps.items.count-1 do
    begin
      if apps.Checked[i] then
      s.add('choco uninstall '+apps.items[i]+' -Y');
    end;
   write_to_bat(s);
   execbat;
end;

procedure TForm1.btSearchClick(Sender: TObject);
var s, f : TStringList    ; n : String;  i : Integer;
begin
if edSearch.Text='IDDQD' then begin tabCheating.tabVisible:=true; exit; end;
s:=TStringList.Create;
s.add('choco search '+edSearch.text+' > search.txt');
s.savetofile('temp.bat');
execbat();
s.free;
f:=TStringList.Create;
apps.Clear;
while not fileexists('search.txt') do Application.ProcessMessages;
while isfileinuse('search.txt') do Application.ProcessMessages;
f.LoadFromFile('search.txt');
for i:=1 to f.count-2 do
    begin
    n:=Copy(f[i], 0, Pos(' ', f[i]));
    if (n<>'') then
    apps.Items.Add(n);
    end;

deletefile('search.txt');
if not apps.Visible then btViewList.Click;
i:=f.count-1;
n:=Copy(f[i], 0, Pos(' ', f[i]));
info.SimpleText:='Найдено '+n;
f.free;
end;

procedure TForm1.btUpgradeClick(Sender: TObject);
var s : TStringList;
begin
 s:=TStringList.create;
 s.add('choco feature enable -n allowGlobalConfirmation');
 s.add('choco upgrade all');
 write_to_bat(s);
 execbat();
 s.free();
end;

procedure TForm1.btViewListClick(Sender: TObject);
begin
 //memo1.Visible:= not memo1.visible;

 apps.visible:=not apps.visible;
 papps.visible:=apps.Visible;
end;

procedure TForm1.Button1Click(Sender: TObject);

begin
magnet(hextostring(MINSTALL_HEX_CODE));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 magnet(hextostring(BELOFF_HEX_CODE));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
magnet(hextostring(SAMDRIVERS_HEX_CODE));
end;

procedure TForm1.edSearchChange(Sender: TObject);
begin

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if fileexists('p.txt') then deletefile('p.txt');
  if fileexists('temp.bat') then deletefile('temp.bat');
end;

procedure TForm1.FormCreate(Sender: TObject);
var i : integer;
begin
optShowWindow:=False;
optWait:=True;
  apps.Clear;
for i:=0 to memo1.Lines.Count-1 do apps.Items.Append(memo1.Lines[i]);
end;

procedure TForm1.lInvertAllClick(Sender: TObject);
var i : Integer;
begin
 for i:=0 to apps.count-1 do
    apps.Checked[i]:=not apps.checked[i];
end;

procedure TForm1.lSelectAllClick(Sender: TObject);
var i : Integer;
begin
for i:=0 to apps.count-1 do
   apps.Checked[i]:=true;
end;

procedure TForm1.lSkipAllClick(Sender: TObject);
var i : Integer;
begin
for i:=0 to apps.count-1 do
   apps.Checked[i]:=false;
end;

procedure TForm1.execbat;
var job : TExecuteExt;
begin
     disable_buttons;
     job:=TExecuteExt.Create(True);
     job.optShowWindow:=optShowWindow;
     job.optWait:=optWait;
     job.WND:=form1.Handle;
     job.Start;
     while not job.Terminated do
           begin

                Application.ProcessMessages;
           end;
 enable_buttons;
end;

procedure TForm1.enable_buttons;
begin
         btChocoInstall.Enabled:=True;
       btRefreshList.Enabled:=True;
       btChocoRun.Enabled:=True;
       btSearch.Enabled:=True;
       btUpgrade.Enabled:=True;
       btViewList.Enabled:=True;
       btRemovePackages.Enabled:=True;
       application.ProcessMessages;
end;

procedure TForm1.write_to_bat(s: TStringList);
begin
  s.add('exit');
  s.Insert(0, '@echo off');
  s.savetofile('temp.bat');
end;

procedure TForm1.disable_buttons;
begin
       btChocoInstall.Enabled:=False;
       btRefreshList.Enabled:=False;
       btChocoRun.Enabled:=False;
       btSearch.Enabled:=False;
       btUpgrade.Enabled:=False;
       btViewList.Enabled:=False;
       btRemovePackages.Enabled:=False;
       application.ProcessMessages;
end;

end.

