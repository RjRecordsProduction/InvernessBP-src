local tween_animation_util = {}
local Entry_Animation_Config = {
  AnimeBorder_Opacity_0 = "PlayOpacityAni",
  AnimeBorder_Opacity_2 = "PlayOpacityAni",
  AnimeBorder_Opacity_4 = "PlayOpacityAni",
  AnimeBorder_Opacity_6 = "PlayOpacityAni",
  AnimeBorder_Scale = "PlayScaleAni",
  AnimeBorder_Up = "PlayUpAni",
  AnimeBorder_Down = "PlayDownAni",
  AnimeBorder_Right = "PlayRightAni",
  AnimeBorder_Left = "PlayLeftAni",
  AnimeBorder_R_Whole = "PlayRWholeAni",
  AnimeBorder_L_Whole = "PlayLWholeAni",
  AnimeBorder_R_0 = "PlayRAni",
  AnimeBorder_R_2 = "PlayRAni",
  AnimeBorder_R_4 = "PlayRAni",
  AnimeBorder_R_6 = "PlayRAni",
  AnimeBorder_D_0 = "PlayDAni",
  AnimeBorder_D_2 = "PlayDAni",
  AnimeBorder_D_4 = "PlayDAni",
  AnimeBorder_D_6 = "PlayDAni"
}
local Entry_Opacity_Frame = {
  AnimeBorder_Opacity_0 = 0,
  AnimeBorder_Opacity_2 = 2,
  AnimeBorder_Opacity_4 = 4,
  AnimeBorder_Opacity_}
local Entry_R_Frame = {
  AnimeBorder_R_0 = 0,
  AnimeBorder_R_2 = 2,
  AnimeBorder_R_4 = 4,
  AnimeBorder_R_}
local Entry_D_Frame = {
  AnimeBorder_D_0 = 0,
  AnimeBorder_D_2 = 2,
  AnimeBorder_D_4 = 4,
  AnimeBorder_D_}
local Entry_LeftRight_X = 300
local Entry_UpDown_Y = 150
local Entry_RightOrDown_Dis = 50
local Second_4_Frame = 0.14
local Second_8_Frame = 0.27
local local UITween = require("client.slua.logic.common.logic_ui_tween")
local EUITweenEaseType = import("EUITweenEaseType")
local GetDelayFrame = function(UIRoot, Entry_Frame, key)
  for k, v in pairs(Entry_Frame) do
    if UIRoot[k] and key == k then
      return UIRoot[k], v
    end
  end
  return nil, nil
end
local HideWidgetByOpacity = function(Widget)
  if not slua.isValid(Widget) then
    return
  end
  local OpacitColor = FLinearColor(Widget.ContentColorAndOpacity.R, Widget.ContentColorAndOpacity.G, Widget.ContentColorAndOpacity.B, 0)
  Widget:SetContentColorAndOpacity(OpacitColor)
end
local ShowWidgetByOpacity = function(Widget)
  if not slua.isValid(Widget) then
    return
  end
  UITween.TweenAlpha(Widget, 0, 1, Second_4_Frame, EUITweenEaseType.EaseInOutCubic)
end
local ShowWidgetByPosition = function(Widget, StartPos, EndPos)
  if not slua.isValid(Widget) then
    return
  end
  UITween.TweenPosition(Widget, StartPos, EndPos, Second_8_Frame, EUITweenEaseType.EaseInOutCubic)
end
function tween_animation_util:PlayEntryAnimation(UIRoot, SelfBase)
  if not slua.isValid(UIRoot) or not SelfBase then
    return
  end
  for k, v in pairs(Entry_Animation_Config) do
    if UIRoot[k] then
      local func = self[v]
      if type(func) == "function" then
        func(self, UIRoot, SelfBase, k)
      end
    end
  end
end
function tween_animation_util:PlayOpacityAni(UIRoot, SelfBase, key)
  local OpacityWidget, OpacityFrame = GetDelayFrame(UIRoot, Entry_Opacity_Frame, key)
  if OpacityWidget and OpacityFrame then
    HideWidgetByOpacity(OpacityWidget)
    local DelaySecond = math.floor(100 * (OpacityFrame / 30)) / 100
    SelfBase:AddTimerOnce(DelaySecond, function()
      ShowWidgetByOpacity(OpacityWidget)
    end)
  end
end
function tween_animation_util:PlayScaleAni(UIRoot, _)
  if UIRoot.AnimeBorder_Scale then
    ShowWidgetByOpacity(UIRoot.AnimeBorder_Scale)
    UITween.TweenScale(UIRoot.AnimeBorder_Scale, {X = 0.6, Y = 0.6}, {X = 1.0, Y = 1.0}, Second_8_Frame, EUITweenEaseType.EaseInOutCubic)
  end
end
function tween_animation_util:PlayUpAni(UIRoot, _)
  if UIRoot.AnimeBorder_Up then
    ShowWidgetByOpacity(UIRoot.AnimeBorder_Up)
    ShowWidgetByPosition(UIRoot.AnimeBorder_Up, {
      X = 0,
      Y = -1 * Entry_UpDown_Y
    }, {X = 0, Y = 0})
  end
end
function tween_animation_util:PlayDownAni(UIRoot, _)
  if UIRoot.AnimeBorder_Down then
    ShowWidgetByOpacity(UIRoot.AnimeBorder_Down)
    ShowWidgetByPosition(UIRoot.AnimeBorder_Down, {X = 0, Y = Entry_UpDown_Y}, {X = 0, Y = 0})
  end
end
function tween_animation_util:PlayRightAni(UIRoot, _)
  if UIRoot.AnimeBorder_Right then
    ShowWidgetByOpacity(UIRoot.AnimeBorder_Right)
    ShowWidgetByPosition(UIRoot.AnimeBorder_Right, {X = Entry_LeftRight_X, Y = 0}, {X = 0, Y = 0})
  end
end
function tween_animation_util:PlayLeftAni(UIRoot, _)
  if UIRoot.AnimeBorder_Left then
    ShowWidgetByOpacity(UIRoot.AnimeBorder_Left)
    ShowWidgetByPosition(UIRoot.AnimeBorder_Left, {
      X = -1 * Entry_LeftRight_X,
      Y = 0
    }, {X = 0, Y = 0})
  end
end
function tween_animation_util:PlayRWholeAni(UIRoot, _)
  if UIRoot.AnimeBorder_R_Whole then
    ShowWidgetByOpacity(UIRoot.AnimeBorder_R_Whole)
    local RWholeSize = UIRoot.AnimeBorder_R_Whole.Slot and UIRoot.AnimeBorder_R_Whole.Slot:GetSize() or {X = 0, Y = 0}
    ShowWidgetByPosition(UIRoot.AnimeBorder_R_Whole, {
      X = RWholeSize.X,
      Y = 0
    }, {X = 0, Y = 0})
  end
end
function tween_animation_util:PlayLWholeAni(UIRoot, _)
  if UIRoot.AnimeBorder_L_Whole then
    ShowWidgetByOpacity(UIRoot.AnimeBorder_L_Whole)
    local LWholeSize = UIRoot.AnimeBorder_L_Whole.Slot and UIRoot.AnimeBorder_L_Whole.Slot:GetSize() or {X = 0, Y = 0}
    ShowWidgetByPosition(UIRoot.AnimeBorder_L_Whole, {
      X = -1 * LWholeSize.X,
      Y = 0
    }, {X = 0, Y = 0})
  end
end
function tween_animation_util:PlayRAni(UIRoot, SelfBase, key)
  local RWidget, RFrame = GetDelayFrame(UIRoot, Entry_R_Frame, key)
  if RWidget and RFrame then
    HideWidgetByOpacity(RWidget)
    RWidget.RenderTransform.Translation = FVector2D(Entry_RightOrDown_Dis, 0)
    RWidget:SetRenderTransform(RWidget.RenderTransform)
    local DelaySecond = math.floor(100 * (RFrame / 30)) / 100
    SelfBase:AddTimerOnce(DelaySecond, function()
      ShowWidgetByOpacity(RWidget)
      ShowWidgetByPosition(RWidget, {X = Entry_RightOrDown_Dis, Y = 0}, {X = 0, Y = 0})
    end)
  end
end
function tween_animation_util:PlayDAni(UIRoot, SelfBase, key)
  local DWidget, DFrame = GetDelayFrame(UIRoot, Entry_D_Frame, key)
  if DWidget and DFrame then
    HideWidgetByOpacity(DWidget)
    DWidget.RenderTransform.Translation = FVector2D(0, -1 * Entry_RightOrDown_Dis)
    DWidget:SetRenderTransform(DWidget.RenderTransform)
    local DelaySecond = math.floor(100 * (DFrame / 30)) / 100
    SelfBase:AddTimerOnce(DelaySecond, function()
      ShowWidgetByOpacity(DWidget)
      ShowWidgetByPosition(DWidget, {X = 0, Y = Entry_RightOrDown_Dis}, {X = 0, Y = 0})
    end)
  end
end
return tween_animation_util