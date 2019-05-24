unit FMX.jsAuthForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.WebBrowser,
  FMX.Effects, FMX.WebBrowserHelper;

type
  TFrmJsAuth = class(TForm)
    WebBrowser: TWebBrowser;
    lblTitle: TLabel;
    SB_Cancel: TSpeedButton;
    LayoutTop: TLayout;
    LayoutWeb: TLayout;
    Layout_Main: TLayout;
    Rct_Success: TRectangle;
    Img_Success: TImage;
    pthCancel: TPath;
    rctTitle: TRectangle;
    aniLoading: TAniIndicator;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FUrl: String;
    FAuthCodeGoogle: String;
    { Private declarations }
  public
    procedure SetUrl(const AUrl: string);
    procedure SetTitleMsg(Value: String);
    procedure Navigate(const AUrl: string);
    procedure SetBackGroundTitleColor(const AValue: TAlphaColor);
    procedure SetTitleVisible(const AValue: Boolean);
    { Public declarations }
  end;

var
  FrmJsAuth: TFrmJsAuth;

implementation

{$R *.fmx}
{ TForm1 }

procedure TFrmJsAuth.FormCreate(Sender: TObject);
begin
  aniLoading.Enabled := True;
end;

procedure TFrmJsAuth.FormDestroy(Sender: TObject);
begin
  aniLoading.Enabled := False;
end;

procedure TFrmJsAuth.FormShow(Sender: TObject);
begin
  WebBrowser.Align := TAlignLayout.Client;
  Tag := 0;
  Navigate(FUrl)
end;

procedure TFrmJsAuth.Navigate(const AUrl: string);
begin
  WebBrowser.CanFocus := True;
  WebBrowser.Navigate(FUrl);
  WebBrowser.SetFocus;
end;

procedure TFrmJsAuth.SetBackGroundTitleColor(const AValue: TAlphaColor);
begin
  rctTitle.Fill.Kind := TBrushKind.Solid;
  rctTitle.Fill.Color := AValue;
end;

procedure TFrmJsAuth.SetTitleMsg(Value: String);
begin
  lblTitle.Text := Value;
end;

procedure TFrmJsAuth.SetTitleVisible(const AValue: Boolean);
begin
  LayoutTop.Visible := AValue;
end;

procedure TFrmJsAuth.SetUrl(const AUrl: string);
begin
  FUrl := AUrl;
end;

end.
