program Md5Check;

uses
  Forms,
  uMD5Check in 'uMD5Check.pas' {Form1},
  uMd5 in 'uMD5.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
