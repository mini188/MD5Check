unit uMD5Check;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    edtFile: TEdit;
    btnFile: TButton;
    mmoResult: TMemo;
    OpenDlg: TOpenDialog;
    btnCalc: TButton;
    rdoText: TRadioButton;
    rdoFile: TRadioButton;
    mmoText: TMemo;
    GroupBox1: TGroupBox;
    rdoUtf8: TRadioButton;
    rdoUnicode: TRadioButton;
    rdoAnsi: TRadioButton;
    lblLink: TLabel;
    procedure btnFileClick(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure rdoFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblLinkClick(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation
uses
  uMD5, HTTPApp, ShellAPI;

{$R *.dfm}

procedure TForm1.btnFileClick(Sender: TObject);
begin
  if OpenDlg.Execute then
  begin
    edtFile.Text := OpenDlg.FileName;
  end;
end;

procedure TForm1.btnCalcClick(Sender: TObject);
  procedure CalcFile;
  var
    objFileStream: TFileStream;
  begin
    if FileExists(edtFile.Text) then
    begin
      objFileStream := TFileStream.Create(edtFile.Text, fmOpenRead);
      try
        mmoResult.Lines.Add(MD5Stream(objFileStream));
      finally
        FreeAndNil(objFileStream);
      end;
    end;
  end;

  procedure CalcText;
  var
    objStrStream: TStringStream;
  begin
    objStrStream := TStringStream.Create(mmoText.Text);
    try
      mmoResult.Lines.Add(MD5Stream(objStrStream));
    finally
      FreeAndNil(objStrStream);
    end;
  end;

  procedure CalcTextUtf8;
  var
    objStrStream: TStringStream;
  begin

    objStrStream := TStringStream.Create(AnsiToUtf8(mmoText.Text));
    try
      mmoResult.Lines.Add(MD5Stream(objStrStream));
    finally
      FreeAndNil(objStrStream);
    end;
  end;


  //×ª»»
  function Str_Gb2UniCode(text: string): String;
  var 
    i,len: Integer;
    cur: Integer;
    t: String;
    ws: WideString;
  begin
    Result := '';
    ws := text;
    len := Length(ws);
    i := 1;
    while i <= len do
    begin
      cur := Ord(ws[i]);
      FmtStr(t,'%4.4X',[cur]);
      Result := Result + t;
      Inc(i);
    end;
  end;

  //×ª»»ÎªUnicode
  function AnsiToUnicode(s:string):WideString;
  var
    lpWideChar:PWideChar;
    len:Integer;
  begin
    len := ( Length(s) + 1 ) * 2;
    GetMem(lpWideChar, len);
    ZeroMemory(lpWideChar, len);

    MultiByteToWideChar(CP_ACP,MB_PRECOMPOSED,
    PChar(s), Length(s),lpWideChar, Len);

    Result := lpWideChar;
    FreeMem(lpWideChar);
  end;

  procedure CalcTextUnicode;
  var
    objStrStream: TStringStream;
  begin
    mmoResult.Lines.Add(MD5String(Str_Gb2UniCode(mmoText.Text)));
  end;

begin
  if rdoFile.Checked then
    CalcFile
  else if rdoText.Checked then
  begin
    if rdoUtf8.Checked then
      CalcTextUtf8
    else if rdoUnicode.Checked then
      CalcTextUnicode
    else
      CalcText;
  end
end;

procedure TForm1.rdoFileClick(Sender: TObject);
begin
  edtFile.Enabled := (Sender = rdoFile);
  btnFile.Enabled := (Sender = rdoFile);

  mmoText.Enabled := Sender = rdoText;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  rdoFile.Checked := True;
end;

procedure TForm1.lblLinkClick(Sender: TObject);
begin
  ShellExecute(Handle, nil, 'http://www.mini188.com', nil, nil, SW_NORMAL); 
end;

end.
