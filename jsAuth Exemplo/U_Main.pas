unit U_Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Ani,
  FMX.WebBrowser, FMX.TabControl, FMX.jsAuth;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    SB_Google: TSpeedButton;
    Image2: TImage;
    Tab_Google: TTabItem;
    Mm_Google: TMemo;
    Rectangle2: TRectangle;
    Button2: TButton;
    Button5: TButton;
    Rct_Google_Perfil: TRectangle;
    Cir_Google: TCircle;
    Button1: TButton;
    Tab_Facebook: TTabItem;
    Button4: TButton;
    Rct_Facebook: TRectangle;
    SB_face: TSpeedButton;
    Image1: TImage;
    Label1: TLabel;
    Rct_Google: TRectangle;
    Label2: TLabel;
    Rectangle4: TRectangle;
    Rct_Facebook_Perfil: TRectangle;
    Cir_Facebook: TCircle;
    Button3: TButton;
    Mm_Facebook: TMemo;
    jsAuthGoogle: TjsAuthGoogle;
    jsAuthFacebook: TjsAuthFacebook;
    Chq_AutoLoad: TCheckBox;
    procedure SB_faceClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SB_GoogleClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin

   Mm_Google.Lines.Clear;
   Mm_Google.Text := jsAuthGoogle.GetPeopleMe;


end;

procedure TForm1.Button3Click(Sender: TObject);
Var
 ImgCapa : TMemoryStream;
begin

 If jsAuthFacebook.TokenAccess <> '' then
 Begin

   ImgCapa := jsAuthFacebook.GetImageCover;

   if ImgCapa <> Nil then
   Begin
            Rct_Facebook_Perfil.Fill.Bitmap.Bitmap.LoadFromStream(ImgCapa);
            Rct_Facebook_Perfil.Fill.Kind := TBrushKind.Bitmap;
            Rct_Facebook_Perfil.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
   End;

 End;


end;

procedure TForm1.SB_faceClick(Sender: TObject);
begin

  jsAuthFacebook.Clear;
  jsAuthFacebook.IdClient := '<ID FACEBOOK> https://developers.facebook.com/apps/ ';

  if Chq_AutoLoad.IsChecked then
  jsAuthFacebook.LoadAutoSave;

  if jsAuthFacebook.TokenAccess <> '' then
  Begin

     ShowMessage('Config Encontrada');
         If jsAuthFacebook.GetInfoFacebook Then
         Begin

           Mm_Facebook.Lines.Clear;
           Mm_Facebook.Lines.Add(' ID : ' + jsAuthFacebook.Id);
           Mm_Facebook.Lines.Add(' Nome : ' + jsAuthFacebook.PersonsName);
           Mm_Facebook.Lines.Add(' Nascimento : ' + jsAuthFacebook.Birthday);
           Mm_Facebook.Lines.Add(' Primeiro Nome : ' + jsAuthFacebook.FirstPersonsName);
           Mm_Facebook.Lines.Add(' Link : ' + jsAuthFacebook.LinkProfile);
           Mm_Facebook.Lines.Add(' Website : ' + jsAuthFacebook.Website);
           Mm_Facebook.Lines.Add(' Email : ' + jsAuthFacebook.Email);
           Mm_Facebook.Lines.Add(' Token : ' + jsAuthFacebook.TokenAccess);


           if jsAuthFacebook.ImgProfile <> Nil then
           Cir_Facebook.Fill.Bitmap.Bitmap.LoadFromStream(jsAuthFacebook.ImgProfile);


           TabControl1.ActiveTab := Tab_Facebook;
         End;

  End
  Else
  Begin


  jsAuthFacebook.AutoSave := True;
  jsAuthFacebook.jsAuth(procedure
  Begin

     If (jsAuthFacebook.TokenAccess <> '')  Then
     Begin

         If jsAuthFacebook.GetInfoFacebook Then
         Begin

           Mm_Facebook.Lines.Clear;
           Mm_Facebook.Lines.Add(' ID : ' + jsAuthFacebook.Id);
           Mm_Facebook.Lines.Add(' Nome : ' + jsAuthFacebook.PersonsName);
           Mm_Facebook.Lines.Add(' Nascimento : ' + jsAuthFacebook.Birthday);
           Mm_Facebook.Lines.Add(' Primeiro Nome : ' + jsAuthFacebook.FirstPersonsName);
           Mm_Facebook.Lines.Add(' Link : ' + jsAuthFacebook.LinkProfile);
           Mm_Facebook.Lines.Add(' Website : ' + jsAuthFacebook.Website);
           Mm_Facebook.Lines.Add(' Email : ' + jsAuthFacebook.Email);
           Mm_Facebook.Lines.Add(' Token : ' + jsAuthFacebook.TokenAccess);


           if jsAuthFacebook.ImgProfile <> Nil then
           Cir_Facebook.Fill.Bitmap.Bitmap.LoadFromStream(jsAuthFacebook.ImgProfile);

           TabControl1.ActiveTab := Tab_Facebook;

         End
         Else
         ShowMessage('Erro ao recuperar informações da conta.');

     End
     Else
     ShowMessage('Erro na autenticação');

  End);

 End;

end;

procedure TForm1.SB_GoogleClick(Sender: TObject);
begin

  jsAuthGoogle.Clear;

  jsAuthGoogle.IdClient := '< ID GOOGLE https://console.developers.google.com/apis/';
  jsAuthGoogle.MessageAuth := 'Autenticando no Google...';

  if Chq_AutoLoad.IsChecked then
  jsAuthGoogle.LoadAutoSave;

  if (jsAuthGoogle.AuthCode <> '') And (jsAuthGoogle.AccessToken <> '') then
  Begin

           ShowMessage('Config Encontrada');
           If jsAuthGoogle.GetInfoGoogle Then
           Begin

             Mm_Google.Lines.Clear;
             Mm_Google.Lines.Add(' ID : ' + jsAuthGoogle.Id);
             Mm_Google.Lines.Add(' Nome : ' + jsAuthGoogle.PersonsName);
             Mm_Google.Lines.Add(' Primeiro Nome : ' + jsAuthGoogle.FirstPersonsName);
             Mm_Google.Lines.Add(' Link : ' + jsAuthGoogle.LinkProfile);
             Mm_Google.Lines.Add(' Website : ' + jsAuthGoogle.Website);
             Mm_Google.Lines.Add(' Token Access : ' + jsAuthGoogle.AccessToken);
             Mm_Google.Lines.Add(' Token Refresh : ' + jsAuthGoogle.RefreshToken);
             Mm_Google.Lines.Add(' AuthCode : ' + jsAuthGoogle.AuthCode);

             if jsAuthGoogle.ImgProfile <> Nil then
             Cir_Google.Fill.Bitmap.Bitmap.LoadFromStream(jsAuthGoogle.ImgProfile);

             TabControl1.ActiveTab := Tab_Google;

           End
           Else
           ShowMessage('Erro ao recuperar informações da conta.');


  End
  Else
  begin

  jsAuthGoogle.AutoSave := True;
  jsAuthGoogle.jsAuth(procedure
  begin

        If (jsAuthGoogle.AuthCode <> '')  Then
        Begin

           If jsAuthGoogle.GetInfoGoogle Then
           Begin

             Mm_Google.Lines.Clear;
             Mm_Google.Lines.Add(' ID : ' + jsAuthGoogle.Id);
             Mm_Google.Lines.Add(' Nome : ' + jsAuthGoogle.PersonsName);
             Mm_Google.Lines.Add(' Primeiro Nome : ' + jsAuthGoogle.FirstPersonsName);
             Mm_Google.Lines.Add(' Link : ' + jsAuthGoogle.LinkProfile);
             Mm_Google.Lines.Add(' Website : ' + jsAuthGoogle.Website);
             Mm_Google.Lines.Add(' Token Access : ' + jsAuthGoogle.AccessToken);
             Mm_Google.Lines.Add(' Token Refresh : ' + jsAuthGoogle.RefreshToken);
             Mm_Google.Lines.Add(' AuthCode : ' + jsAuthGoogle.AuthCode);

             if jsAuthGoogle.ImgProfile <> Nil then
             Cir_Google.Fill.Bitmap.Bitmap.LoadFromStream(jsAuthGoogle.ImgProfile);

             TabControl1.ActiveTab := Tab_Google;

           End
           Else
           ShowMessage('Erro ao recuperar informações da conta.');

        End
        Else
        ShowMessage('Erro na autenticação');

    End
  );

 End;

end;

end.
