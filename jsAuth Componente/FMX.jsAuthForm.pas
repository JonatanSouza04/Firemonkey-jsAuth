unit FMX.jsAuthForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.WebBrowser,
  FMX.Effects, FMX.WebBrowserHelper;

type
  TFrmJsAuth = class(TForm)
    WebBrowser: TWebBrowser;
    Time_URL: TTimer;
    Lbl_Msg_Loading: TLabel;
    SB_Cancel: TSpeedButton;
    ToolBar: TToolBar;
    LayoutTop: TLayout;
    LayoutWeb: TLayout;
    Layout_Main: TLayout;
    Rct_Success: TRectangle;
    Img_Success: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Time_URLTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    URL : String;
    FAuthCodeGoogle : String;
    { Private declarations }
  public
    procedure SetURL(const AURL: string);
    procedure SetMsg( Value : String );
    { Public declarations }
  end;

var
  FrmJsAuth: TFrmJsAuth;

implementation

{$R *.fmx}

{ TForm1 }

procedure TFrmJsAuth.FormCreate(Sender: TObject);
begin

  Time_URL.Enabled    := False;

end;

procedure TFrmJsAuth.FormShow(Sender: TObject);
begin

  WebBrowser.Align   := TAlignLayout.Client;
  Tag := 0;
  Time_URL.Enabled    := True;

end;

procedure TFrmJsAuth.SetMsg(Value: String);
begin

  Lbl_Msg_Loading.Text := Value;

end;

procedure TFrmJsAuth.SetURL(const AURL: string);
begin

  URL := AURL;

end;

procedure TFrmJsAuth.Time_URLTimer(Sender: TObject);
begin

   Time_URL.Enabled := False;

   WebBrowser.CanFocus := True;
   WebBrowser.Navigate( URL );
   WebBrowser.SetFocus;

end;

end.
