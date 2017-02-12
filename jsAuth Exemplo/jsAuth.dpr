program jsAuth;

uses
  System.StartUpCopy,
  FMX.Forms,
  U_Main in 'U_Main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
