(*
 * WebBrowserHelper
 *   WebBrowser Utility
 *
 * Copyright (c) 2015 HOSOKAWA Jun.
 *
 * CONTACT
 *   Twitter @pik or freeonterminate@gmail.com
 *
 * LAST UPDATE
 *   2015/12/13  First Release
 *
 * PLATFORM
 *   iOS, Android
 *   Delphi (XE7 <- maybe) XE8, 10 seattle
 *     Maybe, Appmethod and C++Builder
 *
 * ORIGINAL SOURCE
 *   https://gist.github.com/freeonterminate/303c2910d96f871bd5db
 *
 * HOW TO USE
 *   1. uses FMX.WebBrowser;
 *
 *   // ハイブリッドアプリ（側ネイティブ）を作るための必要な設定をします
 *   // Setting for Hybrid Application (Embeded WebBrowser Application)
 *   procedure SetForHybridApp;
 *
 *   // UserAgent を設定します (Android Only)
 *   // Set UserAgent (Android Only)
 *   procedure SetUserAgent(const iUA: String);
 *
 *   // ハードウェアバックキーが押されたときに必要な処理をします（Android Only）
 *   // Necessary processing when hardware back key was pressed  (Android Only)
 *   function CheckBack(const iKey: Word): Boolean;
 *
 *   // WebBrowser を非表示にします
 *   // Hdie WebBrowser
 *   procedure Hide;
 *
 *   // WebBrowser を表示します
 *   // Show WebBrowser
 *   procedure Show;
 *
 * LICENSE:
 *   本ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、
 *   何らの保証もなく提供されます。
 *   本ソフトウェアの使用によって生じるいかなる損害についても、
 *   作者は一切の責任を負わないものとします。
 *
 *   以下の制限に従う限り、商用アプリケーションを含めて、本ソフトウェアを
 *   任意の目的に使用し、自由に改変して再頒布することをすべての人に許可します。
 *
 *   1. 本ソフトウェアの出自について虚偽の表示をしてはなりません。
 *      あなたがオリジナルのソフトウェアを作成したと主張してはなりません。
 *      あなたが本ソフトウェアを製品内で使用する場合、製品の文書に謝辞を入れて
 *      いただければ幸いですが、必須ではありません。
 *
 *   2. ソースを変更した場合は、そのことを明示しなければなりません。
 *      オリジナルのソフトウェアであるという虚偽の表示をしてはなりません。
 *
 *   3. ソースの頒布物から、この表示を削除したり、表示の内容を変更したりしては
 *      なりません。
 *
 *   This software is provided 'as-is', without any express or implied warranty.
 *   In no event will the authors be held liable for any damages arising from
 *   the use of this software.
 *
 *   Permission is granted to anyone to use this software for any purpose,
 *   including commercial applications, and to alter it and redistribute
 *   it freely, subject to the following restrictions:
 *
 *   1. The origin of this software must not be misrepresented;
 *      you must not claim that you wrote the original software.
 *      If you use this software in a product, an acknowledgment in the product
 *      documentation would be appreciated but is not required.
 *
 *   2. Altered source versions must be plainly marked as such,
 *      and must not be misrepresented as being the original software.
 *
 *   3. This notice may not be removed or altered from any source distribution.
 *)

unit FMX.WebBrowserHelper;

interface

uses
  FMX.WebBrowser;

type
  TWebBrowserHelper = class helper for TWebBrowser
  public
    function AsCustomBrowser: ICustomBrowser;
    function GetField<T>(const iField: String): T;
    procedure SetForHybridApp;
    procedure SetUserAgent(const iUA: String);
    function CheckBack(const iKey: Word): Boolean;
    procedure Hide;
    procedure Show;
  end;

implementation

uses
  System.UITypes
  , System.Rtti
  , System.Generics.Collections
  , FMX.Types
  , FMX.Forms
  , FMX.Platform
  , FMX.VirtualKeyboard
  {$IFDEF ANDROID}
  , Androidapi.JNI.JavaTypes
  , Androidapi.JNI.Embarcadero
  , Androidapi.JNI.Webkit
  , Androidapi.JNI.GraphicsContentViewText
  , Androidapi.Helpers
  , FMX.Helpers.Android
  {$ENDIF}
  {$IFDEF IOS}
  , iOSapi.UIKit
  {$ENDIF}
  ;

type
  TBrowserProps = record
    Align: TAlignLayout;
    X: Single;
  end;
  TBrowserPropsDic = TDictionary<TWebBrowser, TBrowserProps>;

var
  GBrowserProps: TBrowserPropsDic;

{ TWebBrowserHelper }

function TWebBrowserHelper.AsCustomBrowser: ICustomBrowser;
var
  RttiType: TRttiType;
  RttiField: TRttiField;
begin
  Result := nil;

  RttiType := SharedContext.GetType(ClassType);
  if (RttiType = nil) then
    Exit;

  RttiField := RttiType.GetField('FWeb');
  if (RttiField = nil) then
    Exit;

  try
    Result := ICustomBrowser(RttiField.GetValue(Self).AsInterface);
  except
    Result := nil;
  end;
end;

function TWebBrowserHelper.CheckBack(const iKey: Word): Boolean;
var
  FService : IFMXVirtualKeyboardService;
begin
  Result := False;

  if (iKey = vkHardwareBack) then
  begin
    TPlatformServices.Current.SupportsPlatformService(
      IFMXVirtualKeyboardService,
      IInterface(FService));

    if
      (FService <> nil) and
      (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState)
    then
    begin
      // キーボード隠すので何もしない
      // No process, because Keyboard hidden.
      Result := True;
    end
    else
    begin
      if (Self.CanGoBack) then
      begin
        Self.GoBack;
        Result := True;
      end;
    end;
  end
end;

function TWebBrowserHelper.GetField<T>(const iField: String): T;
var
  RttiType: TRttiType;
  RttiField: TRttiField;
  Browser: ICustomBrowser;
  Obj: TObject;
begin
  Result := T(nil);

  // ICustomBrowser の取得
  Browser := AsCustomBrowser;
  if (Browser = nil) then
    Exit;

  // WebView Interface の取得
  Obj := Browser as TObject;
  RttiType := SharedContext.GetType(Obj.ClassType);
  if (RttiType = nil) then
    Exit;

  RttiField := RttiType.GetField(iField);
  if (RttiField = nil) then
    Exit;

  try
    Result := RttiField.GetValue(Obj).AsType<T>;
  except
    Result := T(nil);
  end;
end;

procedure TWebBrowserHelper.Hide;
var
  Props: TBrowserProps;
begin
  if (Self.Parent = nil) then
    Exit;

  Props.Align := Self.Align;
  Props.X := Self.Position.X;

  GBrowserProps.AddOrSetValue(Self, Props);

  Self.Align := TAlignLayout.None;
  Self.SetBounds(Screen.Width, Position.Y, Width, Height);
end;

procedure TWebBrowserHelper.SetForHybridApp;
{$IFDEF ANDROID}
var
  WebBrowser: JWebBrowser;
begin
  if (GetField<JWebBrowser>('FJWebBrowser') <> nil) then
  begin
    WebBrowser := GetField<JWebBrowser>('FJWebBrowser');
    WebBrowser.getSettings.setCacheMode(TJWebSettings.JavaClass.LOAD_NO_CACHE);
    WebBrowser.setOverScrollMode(TJView.JavaClass.OVER_SCROLL_NEVER);
    WebBrowser.getSettings.setBuiltInZoomControls(False);
    WebBrowser.getSettings.setLoadWithOverviewMode(True);
    WebBrowser.getSettings.setUseWideViewPort(True);
  end;
end;
{$ELSE}
  {$IFDEF IOS}
  var
    WebView: UIWebView;
  begin
    WebView := GetField<UIWebView>('FWebView');
    if (WebView <> nil) then
    begin
      WebView.scrollView.setBounces(False);
    end;
  end;
  {$ELSE}
  begin
  end;
  {$ENDIF}
{$ENDIF}

procedure TWebBrowserHelper.SetUserAgent(const iUA: String);
{$IFDEF ANDROID}
var
  WebBrowser: JWebBrowser;
begin
    WebBrowser := GetField<JWebBrowser>('FJWebBrowser');
    if (WebBrowser <> nil) then
      WebBrowser.getSettings.setUserAgentString(StringToJString(iUA));
end;
{$ELSE}
begin
end;
{$ENDIF}

procedure TWebBrowserHelper.Show;
var
  Props: TBrowserProps;
begin
  if (Self.Parent = nil) then
    Exit;

  if (GBrowserProps.TryGetValue(Self, Props)) then
  begin
    Self.SetBounds(Props.X, Position.Y, Width, Height);
    Self.Align := Props.Align;
  end;
end;


initialization
  GBrowserProps := TBrowserPropsDic.Create;

finalization
  GBrowserProps.DisposeOf;

end.
