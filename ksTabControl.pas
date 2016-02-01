{*******************************************************************************
*                                                                              *
*  TksTabControl - tab control component with badge support                    *
*                                                                              *
*  https://github.com/gmurt/KernowSoftwareFMX                                  *
*                                                                              *
*  Copyright 2015 Graham Murt                                                  *
*                                                                              *
*  email: graham@kernow-software.co.uk                                         *
*                                                                              *
*  Licensed under the Apache License, Version 2.0 (the "License");             *
*  you may not use this file except in compliance with the License.            *
*  You may obtain a copy of the License at                                     *
*                                                                              *
*    http://www.apache.org/licenses/LICENSE-2.0                                *
*                                                                              *
*  Unless required by applicable law or agreed to in writing, software         *
*  distributed under the License is distributed on an "AS IS" BASIS,           *
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    *
*  See the License for the specific language governing permissions and         *
*  limitations under the License.                                              *
*                                                                              *
*******************************************************************************}

unit ksTabControl;

interface

{$I ksComponents.inc}

uses
  Classes, FMX.Types, FMX.Controls, FMX.Graphics, Types, System.UITypes,
  FMX.StdCtrls, System.Generics.Collections, FMX.Objects,
  System.UIConsts, ksSpeedButton, FMX.Layouts, ksTypes;

type
  TksTabControl = class;

  TksTabBarTheme = (ksTbCustom, ksTbLightTabs, ksTbDarkTabs);
  TksTabBarPosition = (ksTbpBottom, ksTbpTop);
  TksTabBarHighlightStyle = (ksTbHighlightSingleColor, ksTbHighlightFullColour);

  TksTabItemIcon = (Custom, AlarmClock, BarChart, Bell, BookCover, BookCoverMinus, BookCoverTick, BookMark, BookOpen,
                     Car, Calendar, Camera, Clock, CloudDownload, CloudUpload, Cross, Download, Earch, Email, Document,
                     FileList, FileListTick, FileMinus, FilePlus, Files, FileStar, FileTick, Flag, Folder, FolderMinus,
                     FolderPlus, FolderStar, FolderTick, Home, Inbox, Incoming, Location, More, Note, Outgoing,
                     PaperClip, Photo, PieChart, Pin, Presentation, Settings, Share, ShoppingCart, Spanner, Speaker,
                     Star, Tablet, Tag, Telephone, ThumbDrive, Tick, Timer, Trash, Upload, User, VideoCamera, VideoPlayer, Viewer,
                     Wifi, Window, Write);

  TksTabBarAppearence = class(TPersistent)
  private
    [weak]FTabControl: TksTabControl;
    FSelected: TAlphaColor;
    FNormal: TAlphaColor;
    FBackground: TAlphaColor;
    FBadgeColor: TAlphaColor;
    FTheme: TksTabBarTheme;
    procedure SetColours(ASelected, ANormal, ABackground, ABadge: TAlphaColor);
    procedure SetBackground(const Value: TAlphaColor);
    procedure SetNormal(const Value: TAlphaColor);
    procedure SetSelected(const Value: TAlphaColor);
    procedure SetTheme(const Value: TksTabBarTheme);
    procedure Changed;
    procedure SetBadgeColor(const Value: TAlphaColor);
  public
    constructor Create(ATabControl: TksTabControl);
  published
    property SelectedColor: TAlphaColor read FSelected write SetSelected default claDodgerblue;
    property NormalColor: TAlphaColor read FNormal write SetNormal default claDimgray;
    property BackgroundColor: TAlphaColor read FBackground write SetBackground default claWhite;
    property BadgeColor: TAlphaColor read FBadgeColor write SetBadgeColor default claDodgerblue;
    property Theme: TksTabBarTheme read FTheme write SetTheme default ksTbLightTabs;
  end;

  TksTabItem = class(TControl)
  private
    FIcon: TBitmap;
    FIconType: TksTabItemIcon;
    FTabIndex: integer;
    FText: string;
    FBadgeValue: integer;
    FHighlightStyle: TksTabBarHighlightStyle;
    procedure SetText(const Value: string);
    procedure SetBadgeValue(const Value: integer);
    procedure UpdateTabs;
    procedure SetIcon(const Value: TBitmap);
    procedure SetIconType(const Value: TksTabItemIcon);
    procedure SetTabIndex(const Value: integer);
    procedure SetHighlightStyle(const Value: TksTabBarHighlightStyle);
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeforeDestruction; override;
    destructor Destroy; override;
    procedure DrawTab(ACanvas: TCanvas; AIndex: integer; ARect: TRectF);
  published
    property Text: string read FText write SetText;
    property BadgeValue: integer read FBadgeValue write SetBadgeValue;
    property Icon: TBitmap read FIcon write SetIcon;
    property StandardIcon: TksTabItemIcon read FIconType write SetIconType;
    property TabIndex: integer read FTabIndex write SetTabIndex stored False;
    property HighlightStyle: TksTabBarHighlightStyle read FHighlightStyle write SetHighlightStyle default ksTbHighlightSingleColor;

  end;

  TksTabItemList = class(TObjectList<TksTabItem>)
  private
    [weak]FTabControl: TksTabControl;
  protected
    procedure Notify(const Value: TksTabItem; Action: TCollectionNotification); override;
  public
    constructor Create(ATabControl: TksTabControl);

  end;

  TksTabBar = class(TControl)
  private
    [weak]FTabControl: TFmxObject;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Size;
    property Width;
    property Height;
    property Position;
  end;

  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or
    {$IFDEF XE8_OR_NEWER} pidiOSDevice32 or pidiOSDevice64
    {$ELSE} pidiOSDevice {$ENDIF} or pidiOSSimulator or pidAndroid)]
  TksTabControl = class(TControl, IItemsContainer)
  private
    FTabBar: TksTabBar;
    FTabIndex: integer;
    FOnChange: TNotifyEvent;
    FTabs: TksTabItemList;
    FAppearence: TksTabBarAppearence;
    procedure SetTabIndex(const Value: integer);
    function GetTabRect(AIndex: integer): TRectF;
    function GetTabIndexFromXPos(AXPos: single): integer;
    function GetTabFromXPos(AXPos: single): TksTabItem;
    function GetTabCount: integer;
    function GetActiveTab: TksTabItem;
    function GetSelectedTab: TksTabItem;
  protected
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure Paint; override;
    procedure DoAddObject(const AObject: TFmxObject); override;
    function GetItemsCount: Integer;
    function GetItem(const AIndex: Integer): TFmxObject;
    function GetObject: TFmxObject;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateTabs;
    function AddTab: TksTabItem;
    property ActiveTab: TksTabItem read GetActiveTab;
    property Tabs: TksTabItemList read FTabs;
    property SelectedTab: TksTabItem read GetSelectedTab;
  published
    property Align;
    property Appearence: TksTabBarAppearence read FAppearence write FAppearence;
    property TabIndex: integer read FTabIndex write SetTabIndex default -1;
    property Margins;
    property Position;
    property Width;
    property Size;
    property Height;
    property Visible;
    // events
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  {$R *.dcr}

  procedure Register;


implementation

uses SysUtils,  Math, FMX.Forms, ksCommon, TypInfo, FMX.Ani, fmx.dialogs;

procedure Register;
begin
  RegisterComponents('Kernow Software FMX', [TksTabControl]);
end;


{ TksTabSheTksTabItemet }

procedure TksTabItem.BeforeDestruction;
begin
  inherited;
  if (Parent is TksTabControl) then
    TksTabControl(Parent).Tabs.Remove(Self);
end;

constructor TksTabItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIcon := TBitmap.Create;
  ClipChildren := True;
  Stored := True;
  Locked := True;
  HitTest := False;
  Text := Name;
  FHighlightStyle := ksTbHighlightSingleColor;
end;

destructor TksTabItem.Destroy;
begin

  FreeAndNil(FIcon);
  inherited;
end;

procedure TksTabItem.DrawTab(ACanvas: TCanvas; AIndex: integer; ARect: TRectF);
var
  AAppearence: TksTabBarAppearence;
  ABmp: TBitmap;
  ADestRect: TRectF;
  ABadgeRect: TRectF;
  ABadgeBmp: TBitmap;
  ABadgeScale: single;
begin
  AAppearence := TksTabControl(Parent).Appearence;
  InflateRect(ARect, 0, -3);
  ACanvas.Fill.Color := AAppearence.NormalColor;
  if AIndex = TksTabControl(Parent).TabIndex then
    ACanvas.Fill.Color := AAppearence.SelectedColor;
  ACanvas.Font.Size := 11;
  ACanvas.FillText(ARect, FText, False, 1, [], TTextAlign.Center, TTextAlign.Trailing);
  ABmp := TBitmap.Create;
  try
    ABmp.Assign(FIcon);

    if FHighlightStyle = ksTbHighlightSingleColor then
    begin
      // single colour selected/unselected icons...
      if (AIndex = TksTabControl(Parent).TabIndex) then
        ReplaceOpaqueColor(ABmp, AAppearence.SelectedColor)
      else
        ReplaceOpaqueColor(ABmp, AAppearence.NormalColor);
    end
    else
    begin
      // single colour selected/unselected icons...
      if (AIndex <> TksTabControl(Parent).TabIndex) then
        ReplaceOpaqueColor(ABmp, AAppearence.NormalColor);
    end;
    ADestRect := RectF(0, 0, 20, 20);
    OffsetRect(ADestRect, ARect.Left + ((ARect.Width - 20) / 2), 10);
    ACanvas.DrawBitmap(ABmp, RectF(0, 0, ABmp.Width, ABmp.Height), ADestRect, 1, False);

    if FBadgeValue > 0 then
    begin
      ABadgeScale := (GetScreenScale*2);
      ABadgeBmp := TBitmap.Create(Round(18 * ABadgeScale), Round(18 * ABadgeScale));
      try
        ABadgeBmp.Clear(claNull);
        ABadgeBmp.Canvas.BeginScene;
        ABadgeBmp.Canvas.Fill.Color := AAppearence.BadgeColor;
        ABadgeBmp.Canvas.Stroke.Color := AAppearence.BackgroundColor;
        ABadgeBmp.Canvas.FillEllipse(RectF(0, 0, ABadgeBmp.Width, ABadgeBmp.Height), 1);
        ABadgeBmp.Canvas.StrokeThickness := 3*ABadgeScale;
        ABadgeBmp.Canvas.DrawEllipse(RectF(0, 0, ABadgeBmp.Width, ABadgeBmp.Height), 1);
        ABadgeBmp.Canvas.Fill.Color := claWhite;
        ABadgeBmp.Canvas.Font.Size := 9*ABadgeScale;
        ABadgeBmp.Canvas.FillText(RectF(0, 0, ABadgeBmp.Width, ABadgeBmp.Height), IntToStr(FBadgeValue), False, 1, [], TTextAlign.Center);
        ABadgeBmp.Canvas.EndScene;
        ABadgeRect := RectF(ADestRect.Right-9, ADestRect.Top-9, ADestRect.Right+9, ADestRect.Top+9);
        OffsetRect(ABadgeRect, 0, 2);
        ACanvas.DrawBitmap(ABadgeBmp, RectF(0, 0, ABadgeBmp.Width, ABadgeBmp.Height), ABadgeRect, 1, False);
      finally
        FreeAndNil(ABadgeBmp);
      end;
    end;
  finally
    FreeAndNil(ABmp);
  end;
end;

procedure TksTabItem.SetIconType(const Value: TksTabItemIcon);
var
  AStream: TResourceStream;
  AEnumName: String;
begin
  if Value <> TksTabItemIcon.Custom  then
  begin
    AEnumName := GetENumName(TypeInfo(TksTabItemIcon), Ord(Value));
    AStream := TResourceStream.Create(HInstance, AEnumName, RT_RCDATA);
    try
      FIcon.LoadFromStream(AStream);
    finally
      AStream.Free;
    end;
    FHighlightStyle := TksTabBarHighlightStyle.ksTbHighlightSingleColor;
  end;
  FIconType := Value;
  UpdateTabs;
end;



procedure TksTabItem.SetBadgeValue(const Value: integer);
begin
  if FBadgeValue <> Value then
  begin
    FBadgeValue := Value;
    UpdateTabs;
  end;
end;

procedure TksTabItem.SetHighlightStyle(const Value: TksTabBarHighlightStyle);
begin
  if FHighlightStyle <> Value then
  begin
    FHighlightStyle := Value;
    UpdateTabs;
  end;
end;

procedure TksTabItem.SetIcon(const Value: TBitmap);
begin
  FIcon.Assign(Value);
  FIconType := TksTabItemIcon.Custom;
  UpdateTabs;
end;

procedure TksTabItem.SetTabIndex(const Value: integer);
var
  ATabs: TksTabItemList;
  ANewIndex: integer;
begin
  if FTabIndex <> Value then
  begin
    ATabs := TksTabControl(Parent).Tabs;
    ANewIndex := Value;
    if ANewIndex < 0 then FTabIndex := 0;
    if ANewIndex > ATabs.Count-1 then ANewIndex := ATabs.Count-1;
    ATabs.Move(FTabIndex, ANewIndex);
    FTabIndex := ANewIndex;
    UpdateTabs;
  end;
end;

procedure TksTabItem.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    UpdateTabs;
  end;
end;


procedure TksTabItem.UpdateTabs;
begin
  TksTabControl(Parent).UpdateTabs;
end;

{ TksTabControl }

function TksTabControl.AddTab: TksTabItem;
var
  ATab: TksTabItem;
begin
  ATab := TksTabItem.Create(Self);

  AddObject(ATab);
  Result := ATab;
end;


constructor TksTabControl.Create(AOwner: TComponent);
begin
  inherited;
  FTabs := TksTabItemList.Create(Self);
  FTabBar := TksTabBar.Create(Self);
  FAppearence := TksTabBarAppearence.Create(Self);
  SetAcceptsControls(True);
  Size.Height := 250;
  Size.Width := 250;
  FTabBar.Align := TAlignLayout.Bottom;
  AddObject(FTabBar);
end;

destructor TksTabControl.Destroy;
begin
  FreeAndNil(FTabs);
  FAppearence.DisposeOf;
  inherited;
end;

procedure TksTabControl.DoAddObject(const AObject: TFmxObject);
var
  ATab: TksTabItem;
begin
  inherited;

  if AObject.ClassType = TksTabItem then
  begin

    ATab := TksTabItem(AObject);
    FTabs.Add(ATab);
    if not (csLoading in ComponentState) then
    begin
      ATab.Text := 'Item '+IntToStr(GetTabCount);
      ATab.Name := 'TabItem'+IntToStr(GetTabCount);
    end;
    UpdateTabs;
    Exit;
  end;

  if (SelectedTab <> nil) and (AObject <> FTabBar) then
  begin
    SelectedTab.AddObject(AObject);
  end;
end;

function TksTabControl.GetActiveTab: TksTabItem;
begin
  if InRange(TabIndex, 0, GetTabCount - 1) then
    Result := Tabs[TabIndex]
  else
    Result := nil;
end;


function TksTabControl.GetItem(const AIndex: Integer): TFmxObject;
begin
  Result := Tabs[AIndex];
end;

function TksTabControl.GetItemsCount: Integer;
begin
  Result := FTabs.Count;
end;

function TksTabControl.GetObject: TFmxObject;
begin
  Result := Self;
end;



function TksTabControl.GetSelectedTab: TksTabItem;
begin
  Result := nil;
  if (FTabIndex > -1) and (FTabIndex <= FTabs.Count-1) then
    Result := FTabs[FTabIndex];
end;

function TksTabControl.GetTabCount: integer;
begin
  Result := 0;
  if FTabs <> nil then
    Result := FTabs.Count;
end;

function TksTabControl.GetTabFromXPos(AXPos: single): TksTabItem;
var
  ICount: integer;
begin
  Result := nil;
  for ICount := 0 to GetTabCount-1 do
  begin
    if PtInRect(GetTabRect(ICount), PointF(AXPos, 1)) then
    begin
      Result := Tabs[ICount];
      Exit;
    end;
  end;
end;

function TksTabControl.GetTabIndexFromXPos(AXPos: single): integer;
var
  ICount: integer;
begin
  Result := -1;
  for ICount := 0 to GetTabCount-1 do
  begin
    if PtInRect(GetTabRect(ICount), PointF(AXPos, 1)) then
    begin
      Result := ICount;
      Exit;
    end;
  end;
end;

function TksTabControl.GetTabRect(AIndex: integer): TRectF;
var
  AWidth: single;
begin
  AWidth := Width / GetTabCount;
  Result := RectF(0, 0, AWidth, 50);
  OffsetRect(Result, AWidth * AIndex, 0)
end;

procedure TksTabControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;

end;

procedure TksTabControl.Paint;
var
  AState: TCanvasSaveState;
begin
  with Canvas do
  begin
    AState := SaveState;
    try
      IntersectClipRect(RectF(0, 0, Size.Width, Size.Height));
      Fill.Kind := TBrushKind.Solid;
      Fill.Color := claWhitesmoke;
      FillRect(RectF(0, 0, Size.Width, Size.Height), 0, 0, AllCorners,1);
    finally
      RestoreState(AState);
    end;
    AState := SaveState;
    try
      IntersectClipRect(RectF(0, 0, Size.Width, Size.Height));
      Stroke.Kind := TBrushKind.Solid;
      Stroke.Color := claSilver;
      DrawRect(RectF(0, 0, Size.Width, Size.Height), 0, 0, AllCorners,1);
    finally
      RestoreState(AState);
    end;
  end;

  if (csDesigning in ComponentState) then
  begin
    DrawDesignBorder(claDimgray, claDimgray);
    Canvas.Fill.Color := claDimgray;;
    {$IFDEF MSWINDOWS}
    if GetTabCount = 0 then
    begin
      Canvas.Font.Size := 14;
      Canvas.FillText(ClipRect, 'Right-click to add tabs', True, 1, [], TTextAlign.Center);
    end;
    {$ENDIF}
  end;
end;

procedure TksTabControl.Resize;
begin
  inherited;
  UpdateTabs;
  Repaint;
end;

procedure TksTabControl.SetTabIndex(const Value: integer);
begin
  if FTabIndex <> Value then
  begin
    FTabIndex := Value;
    UpdateTabs;
    if Assigned(FOnChange) then
      FOnChange(Self);

  end;
end;

procedure TksTabControl.UpdateTabs;
var
  ICount: integer;
  ATab: TksTabItem;
begin
  for ICount := 0 to GetTabCount-1 do
  begin
    ATab := Tabs[ICount];
    ATab.FTabIndex := ICount;
    ATab.Width := Self.Width;
    ATab.Height := Self.Height-50;
    ATab.Position.Y := 0;
    ATab.Position.X := 0;
    ATab.Visible := (ICount = FTabIndex);
  end;
  Repaint;
end;

{ TksTabBar }

constructor TksTabBar.Create(AOwner: TComponent);
begin
  inherited;
  FTabControl := (AOwner as TksTabControl);
  Size.Height := 50;
  Stored := False;
  FDesignInteractive := True;
end;

procedure TksTabBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  ATab: TksTabItem;
begin
  inherited;
  TksTabControl(Parent).TabIndex := TksTabControl(FTabControl).GetTabIndexFromXPos(X);
  ATab := TksTabControl(FTabControl).GetTabFromXPos(X);

  {$IFDEF MSWINDOWS}
  if (csDesigning in ComponentState) and
     (TCommonCustomForm(FTabControl.Owner).Designer <> nil) then
  begin
    if ATab <> nil then
    begin
      TCommonCustomForm(FTabControl.Owner).Focused := nil;
      TCommonCustomForm(FTabControl.Owner).Designer.SelectComponent(ATab);
      TCommonCustomForm(FTabControl.Owner).Designer.Modified;
    end;
    Repaint;
  end;
 {$ENDIF}

end;

procedure TksTabBar.Paint;
var
  AState: TCanvasSaveState;
  ICount: integer;
  ARect: TRectF;
  ATabControl: TksTabControl;
begin
  inherited;
  ATabControl := TksTabControl(FTabControl);
  with Canvas do
  begin

    AState := SaveState;
    try
      ARect := RectF(0, 0, Size.Width, Size.Height);
      if (csDesigning in ComponentState) then
        InflateRect(ARect, -1, -1);
      IntersectClipRect(ARect);
      Fill.Kind := TBrushKind.Solid;

      Canvas.Clear(ATabControl.Appearence.BackgroundColor);
      Stroke.Kind := TBrushKind.Solid;
      Stroke.Color := claBlack;

      if (csDesigning in ComponentState) then
        DrawDesignBorder(claDimgray, claDimgray);

      DrawRectSides(ARect, 0, 0, AllCorners,1, [TSide.Top]);

      for ICount := 0 to TksTabControl(FTabControl).GetTabCount-1 do
        ATabControl.Tabs[ICount].DrawTab(Canvas, ICount, ATabControl.GetTabRect(ICount));
    finally
      RestoreState(AState);
      Font.Size := 10;

    end;
  end;
end;

{ TksTabBarAppearence }

procedure TksTabBarAppearence.Changed;
begin
  TksTabControl(FTabControl).Repaint;
end;

constructor TksTabBarAppearence.Create(ATabControl: TksTabControl);
begin
  inherited Create;
  FTabControl := ATabControl;
  FSelected := claDodgerblue;
  FNormal := claDimgray;
  FBackground := claWhite;
  FBadgeColor := claDodgerblue;
  FTheme := ksTbLightTabs;

end;

procedure TksTabBarAppearence.SetBackground(const Value: TAlphaColor);
begin
  if FBackground <> Value then
  begin
    FBackground := Value;
    FTheme := ksTbCustom;
    Changed;
  end;
end;

procedure TksTabBarAppearence.SetBadgeColor(const Value: TAlphaColor);
begin
  if FBadgeColor <> Value then
  begin
    FBadgeColor := Value;
    FTheme := ksTbCustom;
    Changed;
  end;
end;

procedure TksTabBarAppearence.SetColours(ASelected, ANormal, ABackground, ABadge: TAlphaColor);
begin
  FSelected := ASelected;
  FNormal := ANormal;
  FBackground := ABackground;
  FBadgeColor := ABadge;
end;

procedure TksTabBarAppearence.SetNormal(const Value: TAlphaColor);
begin
  if FNormal <> Value then
  begin
    FNormal := Value;
    FTheme := ksTbCustom;
    Changed;
  end;
end;

procedure TksTabBarAppearence.SetSelected(const Value: TAlphaColor);
begin
  if FSelected <> Value then
  begin
    FSelected := Value;
    FTheme := ksTbCustom;
    Changed;
  end;
end;

procedure TksTabBarAppearence.SetTheme(const Value: TksTabBarTheme);
begin
  if FTheme <> Value then
  begin
    if Value = ksTbLightTabs then SetColours(claDodgerblue, claGray, claWhite, claDodgerblue);
    if Value = ksTbDarkTabs then SetColours(claWhite, claGray, $FF202020, claRed);
    FTheme := Value;
    Changed;
  end;
end;

{ TksTabItemList }

constructor TksTabItemList.Create(ATabControl: TksTabControl);
begin
  inherited Create(False);
  FTabControl := ATabControl;
end;


procedure TksTabItemList.Notify(const Value: TksTabItem; Action: TCollectionNotification);
begin
  inherited;
  if csDestroying in FTabControl.ComponentState then
    Exit;
  if (Action = TCollectionNotification.cnRemoved) and (not (csDesigning in FTabControl.ComponentState)) then
  begin
    Value.DisposeOf;
  end;
end;

initialization

RegisterFmxClasses([TksTabControl, TksTabItem]);

end.


