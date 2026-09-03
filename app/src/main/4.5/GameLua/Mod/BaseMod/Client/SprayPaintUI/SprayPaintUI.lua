local SprayPaintUI = {ClickTimeThreshold = 0.3, BeginDragThreshold = 5.0}
local KismetInputLibrary = import("KismetInputLibrary")
local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
function SprayPaintUI:ctor()
  self._TouchState = "Idle"
  self._AccumulatedPointDelta = FVector2D(0, 0)
  self._ClampLength = 100
  self._RadialMenuConfig = nil
end
function SprayPaintUI:RegistEvents()
  print(bWriteLog and "SprayPaintUI:RegistEvents")
  self._RadialMenuConfig = UIManager.UI_Config_InGame.SprayPaintRadialMenu
  self:AddControlEventByControl(self.UIRoot.Border_Opacity, "OnMouseButtonDownEvent", self.OnTouchStarted, self)
  self:AddControlEventByControl(self.UIRoot.Border_Opacity, "OnMouseButtonUpEvent", self.OnTouchEnded, self)
  self:AddControlEventByControl(self.UIRoot.Border_Opacity, "OnMouseMoveEvent", self.OnTouchMoved, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_NEW_EXPANDPANEL_MUTEX, function(_, __, Object)
    if Object ~= self then
      self:OnTouchEnded()
    end
  end)
end
function SprayPaintUI:OnClose()
  print(bWriteLog and "SprayPaintUI:OnClose")
  if self._RadialMenuConfig then
    UIManager.CloseUI(self._RadialMenuConfig)
  end
  SprayPaintUI.__super.OnClose(self)
end
function SprayPaintUI:OnTouchStarted(MyGeometry, InTouchEvent)
  print(bWriteLog and "SprayPaintUI:OnTouchStarted")
  self._TouchState = "Pressed"
  self:_CancelLongPressTimer()
  self._LongPressTimer = self:AddGameTimer(self.ClickTimeThreshold, false, function()
    self._LongPressTimer = nil
    if self._TouchState == "Pressed" then
      self:_ShowCircleUI()
      self._TouchState = "Dragging"
    end
  end)
  return WidgetBlueprintLibrary.CaptureMouse(WidgetBlueprintLibrary.Handled(), self.UIRoot.Border_Opacity)
end
function SprayPaintUI:OnTouchMoved(MyGeometry, InTouchEvent)
  if self._TouchState ~= "Pressed" and self._TouchState ~= "Dragging" then
    return WidgetBlueprintLibrary.Unhandled()
  end
  local Delta = KismetInputLibrary.PointerEvent_GetCursorDelta(InTouchEvent)
  local ClampLength = self._ClampLength
  local Accumulated = self._AccumulatedPointDelta + Delta
  local AccumLength = Accumulated:Size()
  if ClampLength < AccumLength then
    Accumulated = Accumulated * (ClampLength / AccumLength)
  end
  self._AccumulatedPointDelta = Accumulated
  if self._TouchState == "Pressed" and AccumLength >= self.BeginDragThreshold then
    self:_CancelLongPressTimer()
    self:_ShowCircleUI()
    self._TouchState = "Dragging"
  end
  if self._TouchState == "Dragging" then
    local FinalOffset = Accumulated * (1 / ClampLength)
    local RadialMenu = self:GetRadialMenu()
    if RadialMenu then
      RadialMenu:InputOffset(FinalOffset * FVector2D(1, -1))
    end
    if slua.isValid(self.UIRoot.CanvasPanel_SignIcon) then
      self.UIRoot.CanvasPanel_SignIcon:SetRenderTranslation(FinalOffset * 20)
    end
  end
  return WidgetBlueprintLibrary.Handled()
end
function SprayPaintUI:OnTouchEnded(MyGeometry, InTouchEvent)
  print(bWriteLog and "SprayPaintUI:OnTouchEnded - State=" .. tostring(self._TouchState))
  local PrevState = self._TouchState
  if PrevState == "Dragging" then
    self:_HandleDragEnd()
  elseif PrevState == "Pressed" then
    self:_CancelLongPressTimer()
    self:_HandleSingleClick()
  end
  self._TouchState = "Idle"
  self._AccumulatedPointDelta = self._AccumulatedPointDelta * 0
  if slua.isValid(self.UIRoot.CanvasPanel_SignIcon) then
    self.UIRoot.CanvasPanel_SignIcon:SetRenderTranslation(FVector2D(0, 0))
  end
  if slua.isValid(self.UIRoot.WidgetSwitcher_Base) then
    self.UIRoot.WidgetSwitcher_Base:SetActiveWidgetIndex(0)
  end
  return WidgetBlueprintLibrary.ReleaseMouseCapture(WidgetBlueprintLibrary.Handled())
end
function SprayPaintUI:_ShowCircleUI()
  print(bWriteLog and "SprayPaintUI:_ShowCircleUI")
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_NEW_EXPANDPANEL_MUTEX, self)
  if slua.isValid(self.UIRoot.WidgetSwitcher_Base) then
    self.UIRoot.WidgetSwitcher_Base:SetActiveWidgetIndex(1)
  end
  local RadialMenu = self:GetRadialMenu(true)
  if RadialMenu then
    RadialMenu:SelfHitTestInvisible()
  end
end
function SprayPaintUI:_HandleDragEnd()
  print(bWriteLog and "SprayPaintUI:_HandleDragEnd")
  local RadialMenu = self:GetRadialMenu()
  if RadialMenu then
    RadialMenu:Collapsed()
  end
end
function SprayPaintUI:_HandleSingleClick()
  print(bWriteLog and "SprayPaintUI:_HandleSingleClick")
  local ParentUI = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalUI)
  if not ParentUI then
    print(bWriteLog and "SprayPaintUI:_HandleSingleClick - QuickExpressionDecalUI not found")
    return
  end
  if ParentUI.OpenSubPanel then
    ParentUI:OpenSubPanel()
  end
end
function SprayPaintUI:_CancelLongPressTimer()
  if self._LongPressTimer then
    self:RemoveGameTimer(self._LongPressTimer)
    self._LongPressTimer = nil
  end
end
function SprayPaintUI:GetRadialMenu(bCreateIfNeeded)
  local Config = self._RadialMenuConfig
  if not Config then
    return nil
  end
  local UI = UIManager.GetUI(Config)
  if not UI and bCreateIfNeeded then
    UI = UIManager.ShowUI(Config)
  end
  return UI
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, SprayPaintUI)