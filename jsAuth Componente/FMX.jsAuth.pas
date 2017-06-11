unit FMX.jsAuth;
 {** 
 
      Componente desenvolvido por Jonatan Souza - Delphi sem enrolação
	  Este componente não deve ser vendido.
	  È gratuito para testar e aprender.
	  
	  
	  Canal Youtube
	  https://www.youtube.com/channel/UC6omhlEXe3ZCMDZd3WyB4_A
	  
	  Muitas informações para você.
	  
	  Data modificação : 12/02/2017
	  
	  jsAuth.dpk

   }


interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.IOUtils,
  REST.Authenticator.OAuth, IPPeerClient, REST.Types, System.Net.HttpClient,
  IdGlobal, IdHTTP, System.Net.HttpClientComponent, System.JSON, FMX.jsAuthForm, REST.Utils,
  FMX.Objects, FMX.StdCtrls, FMX.Types, IdURI, IPPeerAPI, IniFiles, FMX.WebBrowserHelper, FMX.Dialogs;

Type

  TjsAuth = procedure(Sender: TObject) of object;
  //TjsAuth = procedure of object;

Type
   TjsAuthFacebook = class(TComponent)
    private

     FTokenAccess     : String;
     FIdClient        : String;
     FScope           : String;
     FImgProfile      : TMemoryStream;
     FPersonsName     : String;
     FBirthday        : String;
     FFirstPersonsName: String;
     FId              : String;
     FLinkProfile     : String;
     FEmail           : String;
     FWebsite         : String;
     FMessageAuth     : String;
     FAutoSave: Boolean;

     procedure SetIdClient(const Value: String);
     procedure SetScope(const Value: String);
     procedure SetMessageAuth(const Value: String);
     procedure SetAutoSave(const Value: Boolean);

     procedure OnDidFinishLoadFace(ASender: TObject);
     procedure OnCloseFace(Sender: TObject; var Action: TCloseAction);

     Function DownloadImage( Link : String; out ImgStream : TMemoryStream ) : Boolean;
     Procedure Logout;

     Function CreateIniFile( Table, Field, Value : String ) : Boolean;
     Function ReadIniFile( Table, Field : String ) : String;


    protected

      frmAuthFacebook: TFrmJsAuth;
      finishedProcess : Boolean;

    public

         constructor Create(AOwner: TComponent);
         destructor Destroy; override;

         Procedure SetTokenAccess( Value : String );
         Procedure SetId( Value : String );

         Procedure jsAuth(const Proc : TProc );
         Function GetInfoFacebook : Boolean;
         Function GetImageCover : TMemoryStream; // Foto de capa
         Procedure LoadAutoSave;
         Procedure Clear;
         Function DeleteIniFile : Boolean;

     published

         property TokenAccess : String read FTokenAccess;
         property IdClient    : String read FIdClient    write SetIdClient;
         property Scope       : String read FScope       write SetScope;
         property ImgProfile  : TMemoryStream read FImgProfile;
         property Id          : String read FId;
         property Birthday    : String read FBirthday;
         property LinkProfile : String read FLinkProfile;
         property PersonsName        : String read FPersonsName;
         property FirstPersonsName  : String read FFirstPersonsName;
         property Email       : String read FEmail;
         property Website     : String read FWebsite;
         property MessageAuth : String read FMessageAuth write SetMessageAuth;
         property AutoSave    : Boolean read FAutoSave write SetAutoSave default False;

    End;


    TjsAuthGoogle = class(TComponent)
    private


        FAuthCode        : String;
        FIdClient        : String;
        FScope           : String;
        FLoginHint       : String;
        FPersonsName     : String;
        FEmail           : String;
        FFirstPersonsName: String;
        FWebsite         : String;
        FLinkProfile     : String;
        FRefreshToken    : String;
        FAccessToken     : String;
        FImgProfile      : TMemoryStream;
        FId              : String;
        FMessageAuth     : String;
        FAutoSave        : Boolean;


        procedure OnDidFinishLoadGoogle(ASender: TObject);
        procedure OnShouldStartLoadWithRequest(ASender: TObject; const URL: string);

        procedure SetIdClient(const Value: String);
        procedure SetScope(const Value: String);
        procedure SetLoginHint(const Value: String);
        procedure SetAccessToken(const Value: String);
        procedure SetRefreshToken(const Value: String);
        procedure SetAuthCode(Value: String);
        procedure SetMessageAuth(const Value: String);
        procedure SetAutoSave(const Value: Boolean);

        Function DownloadImage( Link : String; out ImgStream : TMemoryStream ) : Boolean;

        Function CreateIniFile( Table, Field, Value : String ) : Boolean;
        Function ReadIniFile( Table, Field : String ) : String;



        protected

          frmAuthGoogle: TFrmJsAuth;
          finishedProcess : Boolean;

        public

             constructor Create(AOwner: TComponent);
             destructor Destroy; override;

             Procedure SetAuthCodeValue( Value : String );
             Procedure SetAccessTokenValue( Value : String );
             Procedure SetRefreshTokenValue( Value : String );
             Procedure SetId( Value : String );

             Procedure jsAuth(const Proc : TProc );
             Function GetInfoGoogle : Boolean;
             Function GetPeopleMe : String;
             Procedure LoadAutoSave;
             Procedure Clear;
             Function DeleteIniFile : Boolean;

         published

           property IdClient     : String read FIdClient      write SetIdClient;
           property Scope        : String read FScope         write SetScope;
           property LoginHint    : String read FLoginHint     write SetLoginHint;
           property Id           : String read FId;
           property AuthCode     : String read FAuthCode;
           property AccessToken  : String read FAccessToken ;
           property RefreshToken : String read FRefreshToken;
           property LinkProfile  : String read FLinkProfile;
           property PersonsName         : String read FPersonsName;
           property FirstPersonsName   : String read FFirstPersonsName;
           property Email        : String read FEmail;
           property Website      : String read FWebsite;
           property ImgProfile   : TMemoryStream read FImgProfile;
           property MessageAuth  : String read FMessageAuth write SetMessageAuth;
           property AutoSave     : Boolean read FAutoSave write SetAutoSave default False;
  end;

procedure Register;

implementation
Uses FMX.WebBrowser, FMX.Forms, REST.Client;
{ TAuthFacebook }



procedure Register;
begin
  RegisterComponents('jsAuth', [TjsAuthFacebook]);
  RegisterComponents('jsAuth', [TjsAuthGoogle]);
end;


Function TjsAuthFacebook.GetInfoFacebook : Boolean;
Var
 LClientGetInfo : TRESTClient;
 LRequest, LRequestFr : TRESTRequest;
 LResponse : TRESTResponse;
 LOAuth2 : TOAuth2Authenticator;
 LinkImg : STring;
 RetStream : TMemoryStream;
begin

   if FTokenAccess <> '' then
   Begin


       LResponse := TRESTResponse.Create( Self );
       RetStream := TMemoryStream.Create;

       LClientGetInfo := TRESTClient.Create('https://graph.facebook.com/');
       LClientGetInfo.BaseURL := 'https://graph.facebook.com/';

       LOAuth2 := TOAuth2Authenticator.Create(self);
       LOAuth2.AuthorizationEndpoint   := 'https://www.facebook.com/dialog/oauth';
       LOAuth2.RedirectionEndpoint     := 'https://www.facebook.com/connect/login_success.html';
       LOAuth2.Scope                   := FScope;

       with (LOAuth2 AS TOAuth2Authenticator) do
       begin
         AccessToken             := FTokenAccess;
       End;

       LOAuth2.AccessTokenParamName    := 'access_token';
       LOAuth2.ResponseType            := TOAuth2ResponseType.rtTOKEN;

       LClientGetInfo.Authenticator           := LOAuth2;

       LRequest := TRESTRequest.Create(nil);
       LRequest.Response := LResponse;
       LRequest.Client    := LClientGetInfo;
       LRequest.Method    := TRESTRequestMethod.rmGET;
       LRequest.Resource := 'me?fields=id,name,birthday,first_name,email,link,religion,website' {friends};

      Try
       LRequest.Execute;

       LRequest.Response.GetSimpleValue('id', FId);
       LRequest.Response.GetSimpleValue('name', FPersonsName);
       LRequest.Response.GetSimpleValue('first_name', FFirstPersonsName);
       LRequest.Response.GetSimpleValue('birthday', FBirthday);
       LRequest.Response.GetSimpleValue('link', FLinkProfile);
       LRequest.Response.GetSimpleValue('website', FWebsite);
       LRequest.Response.GetSimpleValue('email', FEmail);

       If DownloadImage('https://graph.facebook.com/me/picture?width=200&height=200&access_token=' + FTokenAccess, RetStream ) Then
       FImgProfile := RetStream;

       if FAutoSave then
       Begin

         CreateIniFile('Facebook','TokenAccess',FTokenAccess);
         CreateIniFile('Facebook','Email',FEmail);
         CreateIniFile('Facebook','Id',FId);
         CreateIniFile('Facebook','first_name',FFirstPersonsName);
         CreateIniFile('Facebook','Email',FEmail);

       End;

       Result := True;

      Except
         Result := False;
      End;

   End
   Else
   Result := False;

end;

procedure TjsAuthFacebook.Clear;
begin

   FTokenAccess := '';
   FIdClient    := '';
   FScope       := '';
   FImgProfile  := Nil;
   FPersonsName := '';
   FBirthday    := '';
   FFirstPersonsName := '';
   FId          := '';
   FLinkProfile := '';
   FEmail       := '';
   FWebsite     := '';
   FMessageAuth := '';
   FAutoSave    := False;

end;

constructor TjsAuthFacebook.Create(AOwner: TComponent);
begin


end;

function TjsAuthFacebook.CreateIniFile(Table, Field, Value: String): Boolean;
Var
 FileIni : TIniFile;
 DirFile : String;
Begin

   Result := True;
   {$IFDEF IOS}
       if Not DirectoryExists(TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim) then
       ForceDirectories( TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim );

       DirFile := TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim;
   {$ELSE}
       DirFile := System.SysUtils.GetHomePath + PathDelim;
   {$ENDIF}


   if Not TDirectory.Exists(DirFile) then
   TDirectory.CreateDirectory( DirFile );


  Try
   FileIni := TIniFile.Create( DirFile + 'jsAuthFacebook.ini');
   FileIni.WriteString( Table, Field, Value);
   FreeAndNil(FileIni);

   Except On E : Exception Do
   Begin

     Result := False;

   End;

  End;
end;

function TjsAuthFacebook.ReadIniFile(Table, Field: String): String;
Var
 FileIni : TIniFile;
 DirFile : String;
begin

   Result := '';

   {$IFDEF IOS}
       if Not DirectoryExists(TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim) then
       ForceDirectories( TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim );

       DirFile := TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim;
   {$ELSE}
       DirFile := System.SysUtils.GetHomePath + PathDelim;
   {$ENDIF}


  if TFile.Exists( DirFile + 'jsAuthFacebook.ini' ) then
  Begin

    Try

     FileIni := TIniFile.Create( DirFile + 'jsAuthFacebook.ini');

     Result := FileIni.ReadString( Table, Field, '');
     FreeAndNil(FileIni);

      Except On E : Exception Do
       Begin

         Result := '';

       End;

    End;

  End;

end;

function TjsAuthFacebook.DeleteIniFile: Boolean;
Var
 DirFile : String;
begin

   {$IFDEF IOS}
       if Not DirectoryExists(TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim) then
       ForceDirectories( TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim );

       DirFile := TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim;
   {$ELSE}
       DirFile := System.SysUtils.GetHomePath + PathDelim;
   {$ENDIF}

   if TFile.Exists( DirFile + 'jsAuthFacebook.ini' ) then
   Begin

    TFile.Delete( DirFile + 'jsAuthFacebook.ini' );
    Result := TFile.Exists( DirFile + 'jsAuthFacebook.ini' );

   End
   Else
    Result := False;

end;

destructor TjsAuthFacebook.Destroy;
begin

  inherited;
end;


function TjsAuthFacebook.DownloadImage( Link : String; out ImgStream : TMemoryStream ) : Boolean;
Var
    NetHTTP : TNetHTTPRequest;
    NetClient : TNetHTTPClient;
begin

    Result := False;

  Try

    if Not Assigned( ImgStream ) then
    ImgStream := TMemoryStream.Create;

    NetClient  := TNetHTTPClient.Create( Nil );
    NetHTTP := TNetHTTPRequest.Create( Nil );
    NetHTTP.Client := NetClient;
    NetHTTP.Get(Link,ImgStream);
    ImgStream.Seek(0,soFromBeginning);

    if (ImgStream <> Nil) And ( ImgStream.Size > 0) then
     Result    := True
    Else
     Result := False;


   Finally
     FreeAndNil(NetHTTP);
     FreeAndNil(NetClient);
   End;

end;

function TjsAuthFacebook.GetImageCover: TMemoryStream;
Var
   LClient : TRESTClient;
   LRequest : TRESTRequest;
   LinkCapa : String;
   Js_Obj     : TJSONObject;
   Js_ObjValue : TJSONValue;
   RetStream : TMemoryStream;
begin


   if (FId <> '') And (FTokenAccess <> '') then
   Begin

       Result     := TMemoryStream.Create;
       RetStream  := TMemoryStream.Create;

       LRequest := TRESTRequest.Create( Nil );

       LClient := TRESTClient.Create('https://graph.facebook.com/');
       LClient.BaseURL := 'https://graph.facebook.com/' + FId + '?fields=cover&access_token=' + FTokenAccess;

       LRequest.Client := LClient;
       LRequest.Execute;

       LinkCapa := '';

       if POS('source',LRequest.Response.Content) > 0 then
       Begin

          Try
              Js_Obj    := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(LRequest.Response.Content),0) as TJSONObject;

              Try
                 Js_ObjValue :=  Js_Obj.Get('cover').JsonValue;
                 LinkCapa := TJSONObject(Js_ObjValue).Get('source').JsonValue.Value;
              Finally
                  FreeAndNil(Js_Obj);
              End;

              if LinkCapa <> '' then
               if DownloadImage( LinkCapa, RetStream) then
                 Result := RetStream
               Else
                Result := Nil;

          Except
            Result := Nil;
          End;

       End;
   End
   ELse
   Begin

      Result := TMemoryStream.Create;
      Result := Nil;

   End;
end;

Procedure TjsAuthFacebook.jsAuth(const Proc : TProc );
Var
 URL : String;
begin

 if FTokenAccess <> '' then
 Begin

    finishedProcess := True;

 End
 Else
 Begin

     if FScope = '' then
     FScope := 'user_birthday,user_about_me,public_profile,user_friends,email';

     finishedProcess := False;
     URL := 'https://www.facebook.com/dialog/oauth'
           + '?client_id=' + URIEncode(FIdClient)
           + '&response_type=token'
           + '&scope=' + URIEncode(FScope)
           + '&redirect_uri=' + URIEncode('https://www.facebook.com/connect/login_success.html');

      if Not Assigned(frmAuthFacebook) then
      frmAuthFacebook := TFrmJsAuth.Create( Application );

      frmAuthFacebook.WebBrowser.OnDidFinishLoad := OnDidFinishLoadFace;
      frmAuthFacebook.LayoutTop.Visible   := False;

      if FMessageAuth <> '' then
      frmAuthFacebook.SetMsg( FMessageAuth );

      frmAuthFacebook.SetURL(URL);
      frmAuthFacebook.ShowModal(
              procedure(ModalResult: TModalResult)
              begin

                  finishedProcess := True;
                  Proc;

              End);


 End;

end;

procedure TjsAuthFacebook.LoadAutoSave;
begin

  FTokenAccess := ReadIniFile('Facebook','TokenAccess');
  FEmail       := ReadIniFile('Facebook','Email');

end;

procedure TjsAuthFacebook.Logout;
Var
 js : String;
begin

    js :=  'Var session = ' + QuotedStr('<%= GET[' + QuotedStr('tocken') + '] %>') + ';' +
           'var newURL = https://www.facebook.com/logout.php?next=' + URIEncode('https://www.facebook.com/connect/login_success.html') +
                     '&access_token=+ session ' +
                     'window.location = newURL;';



end;


procedure TjsAuthFacebook.OnCloseFace(Sender: TObject;
  var Action: TCloseAction);
begin
  finishedProcess := True;
end;

procedure TjsAuthFacebook.OnDidFinishLoadFace(ASender: TObject);
Var
 PosI, PosF : Integer;
 URL : String;
begin


     URL := TWebBrowser(ASender).URL;


     if FTokenAccess = '' then
     Begin

        PosI := POS('#access_token=',URL);

        if (PosI > 0) then
        Begin

           FTokenAccess := Copy(URL,PosI + 13, 300);

           PosF := POS('&expires_in',FTokenAccess);
           FTokenAccess := Copy( FTokenAccess,2,PosF - 2);

           if FTokenAccess <> '' then
           Begin

             if FAutoSave then
             Begin

               CreateIniFile('Facebook','TokenAccess',FTokenAccess);
               CreateIniFile('Facebook','Email',FEmail);

             End;

             TWebBrowser(ASender).Align   := TAlignLayout.None;
             TWebBrowser(ASender).Height  := 1;

             finishedProcess := True;
             frmAuthFacebook.ModalResult := mrOk;
             frmAuthFacebook.Close;

           End;

        End;

         if (POS('access_denied',URL) > 0) then
         Begin

           FTokenAccess    := '';
           finishedProcess := True;

         End;

     End;

End;


procedure TjsAuthFacebook.SetAutoSave(const Value: Boolean);
begin
  FAutoSave := Value;
end;

procedure TjsAuthFacebook.SetId(Value: String);
begin

  if Value <> '' then
  FId := Value;

end;

procedure TjsAuthFacebook.SetIdClient(const Value: String);
begin
  FIdClient := Value;
end;

procedure TjsAuthFacebook.SetMessageAuth(const Value: String);
begin
  FMessageAuth := Value;
end;

procedure TjsAuthFacebook.SetScope(const Value: String);
begin
 FScope := Value;
end;


procedure TjsAuthFacebook.SetTokenAccess(Value: String);
begin

  if Value <> '' then
  FTokenAccess := Value;

end;



{ TjsAuthGoogle }

procedure TjsAuthGoogle.Clear;
begin

   FAccessToken  := '';
   FRefreshToken := '';
   FIdClient    := '';
   FScope       := '';
   FImgProfile  := Nil;
   FPersonsName := '';
   FFirstPersonsName := '';
   FId          := '';
   FLinkProfile := '';
   FEmail       := '';
   FWebsite     := '';
   FMessageAuth := '';
   FAutoSave    := False;
   FLoginHint   := '';


end;

constructor TjsAuthGoogle.Create(AOwner: TComponent);
begin
  FScope := '';
end;

function TjsAuthGoogle.CreateIniFile(Table, Field, Value: String): Boolean;
Var
 FileIni : TIniFile;
 DirFile : String;
Begin

   Result := True;
   {$IFDEF IOS}
       if Not DirectoryExists(TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim) then
       ForceDirectories( TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim );

       DirFile := TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim;
   {$ELSE}
       DirFile := System.SysUtils.GetHomePath + PathDelim;
   {$ENDIF}


   if Not TDirectory.Exists(DirFile) then
   TDirectory.CreateDirectory( DirFile );


  Try
   FileIni := TIniFile.Create( DirFile + 'jsAuthGoogle.ini');
   FileIni.WriteString( Table, Field, Value);
   FreeAndNil(FileIni);

   Except On E : Exception Do
   Begin

     Result := False;

   End;

  End;

End;

function TjsAuthGoogle.ReadIniFile(Table, Field: String): String;
Var
 FileIni : TIniFile;
 DirFile : String;
begin

   Result := '';

   {$IFDEF IOS}
       if Not TDirectory.Exists(TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim) then
       TDirectory.CreateDirectory( TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim );

       DirFile := TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim;
   {$ELSE}
       DirFile := System.SysUtils.GetHomePath + PathDelim;
   {$ENDIF}


  if TFile.Exists( DirFile + 'jsAuthGoogle.ini' ) then
  Begin

    Try

     FileIni := TIniFile.Create( DirFile + 'jsAuthGoogle.ini');
     Result := FileIni.ReadString( Table, Field, '');
     FreeAndNil(FileIni);

      Except On E : Exception Do
       Begin

         Result := '';

       End;

    End;

  End;

End;

function TjsAuthGoogle.DeleteIniFile: Boolean;
Var
 DirFile : String;
begin

   {$IFDEF IOS}
       if Not DirectoryExists(TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim) then
       ForceDirectories( TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim );

       DirFile := TPath.GetDocumentsPath + PathDelim + 'Config' + PathDelim;
   {$ELSE}
       DirFile := System.SysUtils.GetHomePath + PathDelim;
   {$ENDIF}

   if TFile.Exists( DirFile + 'jsAuthGoogle.ini' ) then
   Begin

     TFile.Delete( DirFile + 'jsAuthGoogle.ini' );
     Result := TFile.Exists( DirFile + 'jsAuthGoogle.ini' );

   End
   Else
    Result := False;

end;

destructor TjsAuthGoogle.Destroy;
begin

  inherited;
end;

function TjsAuthGoogle.DownloadImage(Link: String;
  out ImgStream: TMemoryStream): Boolean;
Var
    NetHTTP : TNetHTTPRequest;
    NetClient : TNetHTTPClient;
begin

    Result := False;

  Try

    if Not Assigned( ImgStream ) then
    ImgStream := TMemoryStream.Create;

    NetClient  := TNetHTTPClient.Create( Nil );
    NetHTTP := TNetHTTPRequest.Create( Nil );
    NetHTTP.Client := NetClient;
    NetHTTP.Get(Link,ImgStream);
    ImgStream.Seek(0,soFromBeginning);

    if (ImgStream <> Nil) And ( ImgStream.Size > 0) then
     Result    := True
    Else
     Result := False;


   Finally
     FreeAndNil(NetHTTP);
     FreeAndNil(NetClient);
   End;

end;

function TjsAuthGoogle.GetInfoGoogle: Boolean;
Var
 LClient : TRESTClient;
 LRequest, LRequestFr : TRESTRequest;
 LResponse : TRESTResponse;
 LOAuth2 : TOAuth2Authenticator;
 Link,JSONRet : STring;
 RetStream : TMemoryStream;
begin

   LResponse := TRESTResponse.Create( Self );

   LClient := TRESTClient.Create('https://accounts.google.com/');
   LClient.BaseURL := 'https://accounts.google.com/';

 Try

   LRequest := TRESTRequest.Create(nil);
   LRequest.Client := LClient;

   if FScope = '' then
   FScope := 'https://www.googleapis.com/auth/plus.login';//https://www.googleapis.com/auth/userinfo.email


   if (FAccessToken = '') Or (FRefreshToken = '') then
   Begin

     LRequest.Method := TRESTRequestMethod.rmPOST;
     LRequest.Resource := 'o/oauth2/token';
     LRequest.AddParameter('code', FAuthCode, TRESTRequestParameterKind.pkGETorPOST);
     LRequest.AddParameter('client_id', IdClient, TRESTRequestParameterKind.pkGETorPOST);
     LRequest.AddParameter('redirect_uri', 'urn:ietf:wg:oauth:2.0:oob', TRESTRequestParameterKind.pkGETorPOST);
     LRequest.AddParameter('grant_type', 'authorization_code', TRESTRequestParameterKind.pkGETorPOST);
     LRequest.Execute;

     LRequest.Response.GetSimpleValue('access_token', FAccessToken);
     LRequest.Response.GetSimpleValue('refresh_token', FRefreshToken);

   End;

   if FAccessToken <> '' then
   Begin


       LClient.ResetToDefaults;
       LRequest.ResetToDefaults;

       LRequest.Client := LClient;

       LOAuth2 := TOAuth2Authenticator.Create(Application);
       LOAuth2.AccessTokenEndpoint     := 'https://accounts.google.com/o/oauth2/token';
       LOAuth2.AuthorizationEndpoint   := 'https://accounts.google.com/o/oauth2/auth';
       LOAuth2.Scope                   := FScope;
       LOAuth2.RedirectionEndpoint     := 'urn:ietf:wg:oauth:2.0:oob';
       LOAuth2.AccessToken             := FAccessToken;
       LOAuth2.RefreshToken            := FRefreshToken;
       LOAuth2.AccessTokenParamName    := 'access_token';
       LOAuth2.ResponseType            := TOAuth2ResponseType.rtTOKEN;

       LClient.BaseURL       := 'https://www.googleapis.com/oauth2/v1/';
       LClient.Authenticator := LOAuth2;

       LRequest.Resource   := 'userinfo?alt=json';
       LRequest.Execute;

       JSONRet := LRequest.Response.Content;

       LRequest.Response.GetSimpleValue('id', FId);
       LRequest.Response.GetSimpleValue('email', FEmail);
       LRequest.Response.GetSimpleValue('name', FPersonsName);
       LRequest.Response.GetSimpleValue('given_name', FFirstPersonsName);
       LRequest.Response.GetSimpleValue('link', FLinkProfile);
       LRequest.Response.GetSimpleValue('picture', Link);

       if (FAutoSave) And (FId <> '') then
       CreateIniFile('Google','Id',FId);

       If FAutoSave then
       Begin

         CreateIniFile('Google','AccessToken',FAccessToken);
         CreateIniFile('Google','RefreshToken',FRefreshToken);
         CreateIniFile('Google','AuthCode',FAuthCode);
         CreateIniFile('Google','Email',FEmail);

       End;

       RetStream := TMemoryStream.Create;

       if Link <> '' then
         If DownloadImage(Link, RetStream ) Then
         Begin

           RetStream.SaveToFile( System.SysUtils.GetHomePath + PathDelim + 'ImgPerfil.jpg');
           FImgProfile := RetStream;

         End
         Else
         if TFile.Exists( System.SysUtils.GetHomePath + PathDelim + 'ImgPerfil.jpg' ) then
         Begin

           RetStream.LoadFromFile( System.SysUtils.GetHomePath + PathDelim + 'ImgPerfil.jpg' );
           FImgProfile := RetStream;

         End;


       FreeAndNil(LOAuth2);
       FreeAndNil(RetStream);

       Result := True;

   End
   Else
   Result := False;


 Finally
   FreeAndNil(LRequest);
   FreeAndNil(LClient);
 End;
end;

function TjsAuthGoogle.GetPeopleMe: String;
Var
 LClient : TRESTClient;
 LRequest, LRequestFr : TRESTRequest;
 LResponse : TRESTResponse;
 LOAuth2 : TOAuth2Authenticator;
 Link,JSONRet, Uri : String;
begin

     {$IFDEF MSWINDOWS}
       Uri := 'http://localhost';
     {$ELSE}
       Uri := 'urn:ietf:wg:oauth:2.0:oob';
     {$ENDIF}

   if (FAccessToken <> '') And (FRefreshToken <> '') And (FId <> '') then
   begin

       LRequest := TRESTRequest.Create( Self );

       LClient := TRESTClient.Create('https://www.googleapis.com/');
 Try

       LClient.ResetToDefaults;
       LRequest.ResetToDefaults;

       LRequest.Client := LClient;

       LOAuth2 := TOAuth2Authenticator.Create(Nil);
       LOAuth2.AccessTokenEndpoint     := 'https://accounts.google.com/o/oauth2/token';
       LOAuth2.AuthorizationEndpoint   := 'https://accounts.google.com/o/oauth2/auth';
       LOAuth2.Scope                   := FScope;
       LOAuth2.RedirectionEndpoint     := Uri;
       LOAuth2.AccessToken             := FAccessToken;
       LOAuth2.RefreshToken            := FRefreshToken;
       LOAuth2.AuthCode                := FAuthCode;
       LOAuth2.AccessTokenParamName    := 'access_token';
       LOAuth2.ResponseType            := TOAuth2ResponseType.rtTOKEN;

       LClient.Authenticator := LOAuth2;
       LClient.BaseURL       := 'https://www.googleapis.com/';

       LRequest.Resource     :=  'plus/v1/people/' + FId;
       LRequest.Execute;

       JSONRet := LRequest.Response.Content;

       Result := JSONRet;


       FreeAndNil(LOAuth2);

       JSONRet := '';

     Finally
       FreeAndNil(LRequest);
       FreeAndNil(LClient);
     End;

   End;

End;

Procedure TjsAuthGoogle.jsAuth(const Proc : TProc );
Var
  URL, Uri : String;
begin

    if FAuthCode <> '' then
    Begin

        finishedProcess := True;

     End
     Else
     Begin

         if FScope = '' then
         FScope := 'https://www.googleapis.com/auth/plus.login';//https://www.googleapis.com/auth/userinfo.email

         {$IFDEF MSWINDOWS}
           Uri := 'http://localhost';
         {$ELSE}
           Uri := 'urn:ietf:wg:oauth:2.0:oob';
         {$ENDIF}


         finishedProcess := False;
         URL := 'https://accounts.google.com/o/oauth2/v2/auth'
           + '?response_type=' + URIEncode('code')
           + '&client_id=' + URIEncode( IdClient )
           + '&redirect_uri=' + URIEncode(Uri)
           + '&access_type=offline'
           + '&scope=' + URIEncode(FScope);

          if FLoginHint <> '' then
          URL := URL +
           '&login_hint=' + URIEncode(FLoginHint);


          if Not Assigned(frmAuthGoogle) then
          frmAuthGoogle := TFrmJsAuth.Create( Application );

          frmAuthGoogle.WebBrowser.OnShouldStartLoadWithRequest := OnShouldStartLoadWithRequest;
          frmAuthGoogle.WebBrowser.OnDidFinishLoad              := OnDidFinishLoadGoogle;
          frmAuthGoogle.WebBrowser.SetUserAgent('Mozilla/5.0 Google');
          frmAuthGoogle.LayoutTop.Visible := True;
          frmAuthGoogle.SetURL(URL);

          if FMessageAuth <> '' then
          frmAuthGoogle.SetMsg( FMessageAuth );

          frmAuthGoogle.ModalResult := mrOk;
          frmAuthGoogle.ShowModal(
              procedure(ModalResult: TModalResult)
              begin

                  finishedProcess := True;
                  Proc;

              End);

   End;

End;


procedure TjsAuthGoogle.LoadAutoSave;
begin

   FAuthCode     := ReadIniFile('Google','AuthCode');
   FAccessToken  := ReadIniFile('Google','AccessToken');
   FRefreshToken := ReadIniFile('Google','RefreshToken');
   FId           := ReadIniFile('Google','RefreshToken');
   FEmail        := ReadIniFile('Google','Email');

end;

procedure TjsAuthGoogle.OnDidFinishLoadGoogle(ASender: TObject);
Var
 PosI, PosF : Integer;
 js,URL : String;
begin

    URL := TWebBrowser(ASender).URL;

    if (FAuthCode = '') And (POS('accounts',URL) > 0) And (POS('srfsign',URL) > 0) then
    Begin

       TWebBrowser(ASender).Align   := TAlignLayout.None;
       TWebBrowser(ASender).Height  := 1;

       js := 'var markup = document.documentElement.innerHTML;' + #13 + #10
                 + 'var newURL = "http://1.1.1.1/" + markup;' + #13 + #10 +
                'window.location = newURL;';
       TWebBrowser(ASender).EvaluateJavaScript(js);

    End;


  if POS('https://www.google.com.br/?1=1',URL) > 0 then
  Begin

    finishedProcess := True;
    frmAuthGoogle.Close;

  End;

end;

procedure TjsAuthGoogle.OnShouldStartLoadWithRequest(ASender: TObject;
  const URL: string);
Var
 jsonStr, ret : String;
 PosI, PosF : Integer;
begin

    if FAuthCode = '' then
     if (Pos('http://1.1.1.1/', URL) = 1) then
     begin

        jsonStr := URL;
        Fetch(jsonStr, 'http://1.1.1.1/');

        jsonStr := TIdURI.URLDecode(jsonStr, IndyTextEncoding_UTF8);

        PosI := POS('<title>',jsonStr);


        if PosI > 0 then
        ret := Copy(jsonStr,PosI + 7,250);

        PosF := POS('</title>',ret);

        if PosF > 0 then
        ret := Copy(ret,1,PosF-1);

        PosI := POS('=',ret);

        if PosI > 0 then
        ret := Copy(ret,PosI + 1,200);

        if ret <> '' then
        Begin

          FAuthCode        := ret;

          if FAutoSave then
          CreateIniFile('Google','AuthCode',FAuthCode);

          TWebBrowser(ASender).Align  := TAlignLayout.None;
          TWebBrowser(ASender).Height := 1;
          finishedProcess  := True;

          frmAuthGoogle.ModalResult := mrOk;

          TWebBrowser(ASender).URL := 'https://www.google.com.br/?1=1'

        End;

    end;
end;



procedure TjsAuthGoogle.SetAccessToken(const Value: String);
begin
  FAccessToken := Value;
end;

procedure TjsAuthGoogle.SetAccessTokenValue(Value: String);
begin

  if Value <> '' then
  FAccessToken := Value;

end;

procedure TjsAuthGoogle.SetAuthCode(Value: String);
begin

  if Value <> '' then
  FRefreshToken := Value;

end;

procedure TjsAuthGoogle.SetAuthCodeValue(Value: String);
begin

  if Value <> '' then
  FAuthCode := Value;

end;


procedure TjsAuthGoogle.SetAutoSave(const Value: Boolean);
begin
  FAutoSave := Value;
end;

procedure TjsAuthGoogle.SetId(Value: String);
begin

  if Value <> '' then
  FId := Value;

end;

procedure TjsAuthGoogle.SetIdClient(const Value: String);
begin
  FIdClient := Value;
end;

procedure TjsAuthGoogle.SetLoginHint(const Value: String);
begin
  FLoginHint := Value;
end;

procedure TjsAuthGoogle.SetMessageAuth(const Value: String);
begin
  FMessageAuth := Value;
end;

procedure TjsAuthGoogle.SetRefreshToken(const Value: String);
begin
  FRefreshToken := Value;
end;

procedure TjsAuthGoogle.SetRefreshTokenValue(Value: String);
begin

end;

procedure TjsAuthGoogle.SetScope(const Value: String);
begin
  FScope := Value;
end;



end.
