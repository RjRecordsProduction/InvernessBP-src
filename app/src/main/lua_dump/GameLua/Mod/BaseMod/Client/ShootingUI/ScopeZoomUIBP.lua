local ScopeZoomUIBP = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local WeaponUtils = require("GameLua.Mod.BaseMod.GamePlay.Weapon.WeaponUtils")
function ScopeZoomUIBP:OnInitialize()
  print(bWriteLog and "ScopeZoomUIBP:OnInitialize")
  self.LastSightZoomIndex = 0
  self.SlideTouchLoc = FVector(0, 0, 0)
  self.SightZoomMemoryIndex = 0.0
end
function ScopeZoomUIBP:RegistEvents()
  print(bWriteLog and "ScopeZoomUIBP:RegistEvents")
  self:AddControlEventByControl(self.UIRoot.Slider_X8Zoom, "OnValueChanged", self.OnX8ZoomValueChanged, self)
  self:AddControlEventByControl(self.UIRoot.Button_HIdeX8Panel, "OnClicked", self.OnClickHideX8Panel, self)
  self:AddControlEventByControl(self.UIRoot.Button_8XBtn, "OnMouseButtonDownEvent", self.OnButton_8XBtnButtonDown, self)
  self:AddControlEventByControl(self.UIRoot.Button_ChangeSight, "OnClicked", self.OnButton_ChangeSightButtonDown, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
end
function ScopeZoomUIBP:OnPostInitialize()
  print(bWriteLog and "ScopeZoomUIBP:OnPostInitialize")
end
function ScopeZoomUIBP:OnClose()
  print(bWriteLog and "ScopeZoomUIBP:OnClose")
end
function ScopeZoomUIBP:OnPlayerCharacterChange(_, PlayerCharacter)
  print(bWriteLog and "ScopeZoomUIBP:OnPlayerCharacterChange")
  if slua.isValid(PlayerCharacter) then
    GameplayData.AddSelfPlayerCharacterEvent(self, "OnEquipZoomScope", self.OnEquipZoomScope, self)
  end
end
function ScopeZoomUIBP:OnX8ZoomValueChanged(Value)
  self:ChangeSightZoom(Value)
end
function ScopeZoomUIBP:OnClickHideX8Panel()
  print(bWriteLog and "ScopeZoomUIBP:OnClickHideX8Panel")
  self:HideSightZoom()
  self.UIRoot.Button_8XBtn:Release()
end
function ScopeZoomUIBP:OnButton_8XBtnButtonDown(MyGeometry, MouseEvent)
  local UKismetInputLibrary = import("KismetInputLibrary")
  local FingerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(MouseEvent)
  local ScreenPos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  local Loc = FVector(ScreenPos.X, ScreenPos.Y, 0)
  self:X8BtnPressed(math.floor(FingerIndex), Loc)
  local UWidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  return UWidgetBlueprintLibrary:Unhandled()
end
function ScopeZoomUIBP:OnButton_ChangeSightButtonDown()
  print(bWriteLog and "ScopeZoomUIBP:OnButton_ChangeSightButtonDown")
  local UPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(UPlayerCharacter) then
    return
  end
  UPlayerCharacter:PlaySwitchFireModeSound()
  WeaponUtils:SwitchX4ScopeSight(true)
end
function ScopeZoomUIBP:HideSightZoom()
  print(bWriteLog and "ScopeZoomUIBP:HideSightZoom")
  self.UIRoot.Button_8XBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.CanvasPanel_ShowX8Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function ScopeZoomUIBP:ShowSightZoom()
  print(bWriteLog and "ScopeZoomUIBP:ShowSightZoom")
  self.UIRoot.CanvasPanel_ShowX8Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.Button_8XBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function ScopeZoomUIBP:SightZoomTouchMove(FingerIndex, TouchLoc)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ScopeZoomUIBP:SightZoomTouchMove Fail not slua.isValid(PlayerController)")
    return
  end
  if PlayerController.CurSightZoomFingerIndex ~= FingerIndex then
    return
  end
  if not self.SlideTouchLoc then
    self.SlideTouchLoc = FVector(0, 0, 0)
  end
  local KismetMathLibrary = import("KismetMathLibrary")
  if KismetMathLibrary.EqualEqual_VectorVector(self.SlideTouchLoc, FVector.ZeroVector, 1.0E-4) then
    self.Slide  end
  local Slot = self.UIRoot.Slider_X8Zoom.Slot
  local Size = Slot:GetSize()
  local SightZoomScale = 1.5
  local Value = (TouchLoc.Y - self.SlideTouchLoc.Y) / -(Size.Y + 0.001) * SightZoomScale + self.SightZoomMemoryIndex
  self:ChangeSightZoom(Value)
end
function ScopeZoomUIBP:ChangeSightZoom(Value)
  Value = FuncUtil.Clamp(Value, 0.0, 1.0)
  self.UIRoot.Slider_X8Zoom:SetValue(Value)
  if self.LastSightZoomIndex == Value then
    print(bWriteLog and "ScopeZoomUIBP:ChangeSightZoom self.LastSightZoomIndex == Value")
    return
  end
  print(bWriteLog and "ChangeSightZoomValue", Value)
  self.LastSightZoomIndex = Value
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) or not slua.isValid(PlayerCharacter.FPPComponent) then
    print(bWriteLog and "ScopeZoomUIBP:ChangeSightZoom Not PlayerCharacter")
    return
  end
  PlayerCharacter.FPPComponent:ScopeZoomUpdate(1 - Value)
end
function ScopeZoomUIBP:ReleaseSightZoomButton(PlayerController)
  print(bWriteLog and "ScopeZoomUIBP:ReleaseSightZoomButton")
  local ETouchIndex = import("ETouchIndex")
  PlayerController.CurSightZoomFingerIndex = ETouchIndex.Touch10
  self.SlideTouchLoc = FVector(0, 0, 0)
  self:HideSightZoom()
  self.UIRoot.Button_8XBtn:Release()
end
function ScopeZoomUIBP:X8BtnPressed(FingerIndex, Loc)
  print(bWriteLog and "ScopeZoomUIBP:X8BtnPressed")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  local FocalLengthModifySwitch = SettingSubsystem:GetUserSettings_Bool("FocalLengthModifySwitch")
  if not FocalLengthModifySwitch then
    self:ShowSightZoom()
    self.UIRoot.Button_HIdeX8Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    print(bWriteLog and "ScopeZoomUIBP:X8BtnPressed not FocalLengthModifySwitch")
    return
  end
  self.SightZoomMemoryIndex = self.UIRoot.Slider_X8Zoom:GetValue()
  self.UIRoot.Button_HIdeX8Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnFingerMove", function(MoveFingerIndex, Loc)
    self:OnSightZoomFingerMove(MoveFingerIndex, Loc)
  end)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReleaseScreen", function(ReleaseFingerIndex)
    self:OnSightZoomReleaseScreen(ReleaseFingerIndex)
  end)
  local PlayerController = GameplayData.GetPlayerController()
  PlayerController.CurSightZoom  PlayerController.IgnoreCameraMovingIndexArray:AddUnique(PlayerController.CurSightZoomFingerIndex)
  PlayerController.bIsTouching = true
  self:ShowSightZoom()
end
function ScopeZoomUIBP:OnSightZoomFingerMove(FingerIndex, TouchLoc)
  self:SightZoomTouchMove(FingerIndex, TouchLoc)
end
function ScopeZoomUIBP:OnSightZoomReleaseScreen(FingerIndex)
  print(bWriteLog and "ScopeZoomUIBP:OnSightZoomReleaseScreen")
  local PlayerController = GameplayData.GetPlayerController()
  if PlayerController.CurSightZoomFingerIndex ~= FingerIndex then
    return
  end
  self:RemoveControlEventByControl(PlayerController, "OnFingerMove")
  self:RemoveControlEventByControl(PlayerController, "OnReleaseScreen")
  self:ReleaseSightZoomButton(PlayerController)
end
function ScopeZoomUIBP:InitScopeZoomUI(ZoomValue, ScopeID, bUseZoomScope)
  print(bWriteLog and "ScopeZoomUIBP:InitScopeZoomUI")
  if not self.UIRoot then
    return
  end
  self.UIRoot.Slider_X8Zoom:SetValue(ZoomValue)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and slua.isValid(PlayerCharacter.FPPComponent) and bUseZoomScope then
    local Config = PlayerCharacter.FPPComponent:GetCurScopeZoomConfig()
    self.UIRoot.TextBlock_7:SetText(LocUtil.LocalizeResFormat(45453, Config.DisplayMaxScale))
    self.UIRoot.TextBlock_8:SetText(LocUtil.LocalizeResFormat(45453, Config.DisplayMinScale))
  end
  if bUseZoomScope then
    self.UIRoot.CanvasPanel_X8ZoomSlider:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_ShowX8Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.UIRoot.Button_8XBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.UIRoot.CanvasPanel_X8ZoomSlider:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_ShowX8Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Button_8XBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  end
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SCOPECHANGE_UI, self, bUseZoomScope)
  if PlayerCharacter and slua.isValid(PlayerCharacter) and slua.isValid(PlayerCharacter.FPPComponent) then
    local ESightType = import("ESightType")
    local IsSightX4 = PlayerCharacter.FPPComponent:GetSightType() == ESightType.SightX4
    local IsSpecialScope = ScopeID == 203150 or ScopeID == 203151 or ScopeID == 203011 or ScopeID == 203012
    local IsAngledSightScope = PlayerCharacter.FPPComponent:IsAngledSight()
    if IsSightX4 and PlayerCharacter.bIsGunADS and not IsSpecialScope and not IsAngledSightScope then
      self.UIRoot.CanvasPanel_ChangeSight:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      WeaponUtils:SwitchX4ScopeSight(false)
    else
      log(bWriteLog and "ScopeZoomUIBP:InitScopeZoomUI, IsSightX4 = ", IsSightX4, ", PlayerCharacter.bIsGunADS = ", PlayerCharacter.bIsGunADS, ", IsSpecialScope = ", IsSpecialScope, ", IsAngledSightScope = ", IsAngledSightScope)
      self.UIRoot.CanvasPanel_ChangeSight:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function ScopeZoomUIBP:OnEquipZoomScope(ZoomValue, ScopeID, bUseZoomScope)
  print(bWriteLog and "ScopeZoomUIBP:OnEquipZoomScope " .. tostring(ZoomValue) .. " " .. tostring(ScopeID) .. " " .. tostring(bUseZoomScope))
  if type(ZoomValue) ~= "number" then
    ZoomValue = 1.0
  end
  self:InitScopeZoomUI(ZoomValue, ScopeID, bUseZoomScope)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CScopeZoomUIBP = class(ui_base, nil, ScopeZoomUIBP)
return CScopeZoomUIBP