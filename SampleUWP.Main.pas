unit SampleUWP.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Effects, FMX.Ani,
  Dwmapi, Winapi.Windows, Winapi.Messages;

type
  TFormMain = class(TForm)
    TimerRepaint: TTimer;
    Rectangle1: TRectangle;
    Image2: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Rectangle10: TRectangle;
    Image11: TImage;
    Label21: TLabel;
    Label22: TLabel;
    Rectangle11: TRectangle;
    Image12: TImage;
    Label23: TLabel;
    Label24: TLabel;
    Rectangle2: TRectangle;
    Image3: TImage;
    Label5: TLabel;
    Label6: TLabel;
    Rectangle3: TRectangle;
    Image4: TImage;
    Label7: TLabel;
    Label8: TLabel;
    Rectangle4: TRectangle;
    Image5: TImage;
    Label9: TLabel;
    Label10: TLabel;
    Rectangle5: TRectangle;
    Image6: TImage;
    Label11: TLabel;
    Label12: TLabel;
    Rectangle6: TRectangle;
    Image7: TImage;
    Label13: TLabel;
    Label14: TLabel;
    Rectangle7: TRectangle;
    Image8: TImage;
    Label15: TLabel;
    Label16: TLabel;
    Rectangle8: TRectangle;
    Image9: TImage;
    Label17: TLabel;
    Label18: TLabel;
    Rectangle9: TRectangle;
    Image10: TImage;
    Label19: TLabel;
    Label20: TLabel;
    RectangleFirst: TRectangle;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    Rectangle12: TRectangle;
    Layout3: TLayout;
    ShadowEffect1: TShadowEffect;
    Label25: TLabel;
    TimerRecalcPos: TTimer;
    VertScrollBox1: TVertScrollBox;
    Rectangle13: TRectangle;
    Layout4: TLayout;
    Layout5: TLayout;
    procedure TimerRepaintTimer(Sender: TObject);
    procedure RectangleFirstMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure RectangleFirstMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Layout1Resized(Sender: TObject);
    procedure TimerRecalcPosTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RectangleFirstPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure Rectangle12MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Layout4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    procedure EnableBlur;
  public
    { Public declarations }
  end;

  TWinCompAttrData = packed record
    Attribute: THandle;
    Data: Pointer;
    DataSize: ULONG;
  end;

var
  FormMain: TFormMain;

var
  SetWindowCompositionAttribute: function(Wnd: HWND; const AttrData: TWinCompAttrData): BOOL; stdcall = nil;

implementation

uses
  System.Math, FMX.Platform.Win;

{$R *.fmx}

procedure TFormMain.EnableBlur;
type
  TAccentPolicy = packed record
    AccentState: DWORD;
    AccentFlags: DWORD;
    GradientColor: DWORD;
    AnimationId: DWORD;
  end;
const
  WCA_ACCENT_POLICY = 19;
  ACCENT_ENABLE_GRADIENT = 1;
  ACCENT_ENABLE_TRANSPARENTGRADIENT = 2;
  ACCENT_ENABLE_BLURBEHIND = 3;
  ACCENT_ENABLE_ACRYLICBLURBEHIND = 4;
  //Хз, что за флаги (но пока не принципиально)
  DrawLeftBorder = $20;
  DrawTopBorder = $40;
  DrawRightBorder = $80;
  DrawBottomBorder = $100;
var
  DWM: THandle;
  CompAttrData: TWinCompAttrData;
  Accent: TAccentPolicy;
begin
  DWM := LoadLibrary('user32.dll');
  try
    if @SetWindowCompositionAttribute = nil then
      @SetWindowCompositionAttribute := GetProcAddress(DWM, 'SetWindowCompositionAttribute');
    if @SetWindowCompositionAttribute <> nil then
    begin
      //Цвет акрил с цветом
      //Accent.GradientColor := $AA000000;
      //Accent.AccentState := ACCENT_ENABLE_ACRYLICBLURBEHIND;
      //Акрил без цвета
      Accent.AccentState := ACCENT_ENABLE_BLURBEHIND;

      Accent.AccentFlags := DrawLeftBorder or DrawTopBorder or DrawRightBorder or DrawBottomBorder;
      CompAttrData.Attribute := WCA_ACCENT_POLICY;
      CompAttrData.DataSize := SizeOf(Accent);
      CompAttrData.Data := @Accent;
      SetWindowCompositionAttribute(FmxHandleToHWND(Handle), CompAttrData);
    end;
  finally
    FreeLibrary(DWM);
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  EnableBlur;
  VertScrollBox1.AniCalculations.Animation := True;
  //Расставим всё без анимации
  TimerRecalcPosTimer(nil);
end;

procedure TFormMain.Layout1Resized(Sender: TObject);
begin
  //Сброс для перестановки
  TimerRecalcPos.Enabled := False;
  TimerRecalcPos.Enabled := True;
end;

procedure TFormMain.Layout4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  StartWindowResize;
end;

procedure TFormMain.Rectangle12MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  StartWindowDrag;
end;

procedure TFormMain.RectangleFirstMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
//Коэффициент скейла
const
  Rate = 0.96;
var
  Rectangle: TRectangle absolute Sender;
  P: TPointF;
begin
  //Скейлим и смещаем элемент (эффект нажатия)
  Rectangle.Scale.Point := TPointF.Create(Rate, Rate);
  P := Rectangle.Position.Point;
  P.Offset((Rectangle.Width - Rectangle.Width * Rate) / 2, (Rectangle.Height - Rectangle.Height * Rate) / 2);
  Rectangle.Position.Point := P;
  SetCaptured(Rectangle);
end;

procedure TFormMain.RectangleFirstMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
//Коэффициент скейла
const
  Rate = 0.96;
var
  Rectangle: TRectangle absolute Sender;
  P: TPointF;
begin
  //Убираем скейл, возвращаем смещение
  Rectangle.Scale.Point := TPointF.Create(1, 1);
  P := Rectangle.Position.Point;
  P.Offset(-(Rectangle.Width - Rectangle.Width * Rate) / 2, -(Rectangle.Height - Rectangle.Height * Rate) / 2);
  Rectangle.Position.Point := P;
end;

procedure TFormMain.RectangleFirstPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Rectangle: TRectangle absolute Sender;
begin
  with Rectangle.AbsoluteToLocal(ScreenToClient(Screen.MousePos)) do
  begin
    // Смещение точки радиального градиента
    Rectangle.Stroke.Gradient.RadialTransform.RotationCenter.Point :=
      TPointF.Create(((100 / Rectangle.Width) * X) / 100, ((100 / Rectangle.Height) * Y) / 100);

    //Толщина (просто чтоб не задавать в дизайнере)
    Rectangle.Stroke.Thickness := 1;

    //Рамка если навели на элемент
    if Rectangle.AbsoluteRect.Contains(ScreenToClient(Screen.MousePos)) then
      Rectangle.Stroke.Gradient.Color := $404B4B4B
    else
      Rectangle.Stroke.Gradient.Color := $004B4B4B;
  end;
end;

procedure TFormMain.TimerRepaintTimer(Sender: TObject);
begin
  Invalidate;
end;

procedure TFormMain.TimerRecalcPosTimer(Sender: TObject);
//Отступы в сетке
const
  OffsetX = 10;
  OffsetY = 10;
var
  i, C, R, WCount: Integer;
  NC, NR: Single;
  Control: TRectangle;
begin
  //Расстановка объектов по сетке. С анимацией, если Sender <> nil
  TimerRecalcPos.Enabled := False;
  for i := 0 to Pred(VertScrollBox1.Content.ControlsCount) do
    if VertScrollBox1.Content.Controls[i] is TRectangle then
    begin
      Control := VertScrollBox1.Content.Controls[i] as TRectangle;
      WCount := Trunc(VertScrollBox1.Width / (Control.Width + OffsetX * 2));
      if WCount > 0 then
      begin
        R := i div WCount;
        C := i mod WCount;
        if (C <> Trunc(Control.Margins.Rect.Left)) or (R <> Trunc(Control.Margins.Rect.Top)) then
        begin
          NC := C * (Control.Width + OffsetX * 2) + OffsetX;
          NR := R * (Control.Height + OffsetY * 2) + OffsetY;
          if Sender <> nil then
          begin
            TAnimator.AnimateFloat(Control, 'Position.X', NC, 0.5, TAnimationType.out, TInterpolationType.Circular);
            TAnimator.AnimateFloat(Control, 'Position.Y', NR, 0.5, TAnimationType.out, TInterpolationType.Circular);
          end
          else
          begin
            Control.Position.X := NC;
            Control.Position.Y := NR;
          end;
          Control.Margins.Rect := TRectF.Create(C, R, 0, 0);
        end;
      end;
    end;
end;

end.

