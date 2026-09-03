local RedSightUIBP = {}
function RedSightUIBP:OnInitialize()
  print(bWriteLog and "RedSightUIBP:OnInitialize")
  self.ISP90 = false
  self.RotateViewWithSniperSwitch = false
  self:ReceivedInitWidget()
end
function RedSightUIBP:RegistEvents()
  print(bWriteLog and "RedSightUIBP:RegistEvents")
  self:AddUIMessageEvent("UIMsg_NormalSideSight", self.UIMsg_NormalSideSight, self)
  self:AddUIMessageEvent("UIMsg_HighLightSideSight", self.UIMsg_HighLightSideSight, self)
  self:AddUIMessageEvent("UIMsg_HideSideSight", self.UIMsg_HideSideSight, self)
  self:AddUIMessageEvent("UIMsg_ShowSideSight", self.UIMsg_ShowSideSight, self)
  self:AddUIMessageEvent("UIMsg_ShootWeaponSight", self.UIMsg_ShootWeaponSight, self)
  self:AddUIMessageEvent("UIMsg_NormalWeaponSight", self.UIMsg_NormalWeaponSight, self)
  self:AddUIMessageEvent("UIMsg_HighLightWeaponSight", self.UIMsg_HighLightWeaponSight, self)
  self:AddControlEventByControl(self.UIRoot.MultiRedButton, "OnPressDown", self.OnPressDown, self)
  self:AddControlEventByControl(self.UIRoot.MultiRedButton, "OnHoldEnded", self.OnHoldEnded, self)
end
function RedSightUIBP:OnPostInitialize()
  print(bWriteLog and "RedSightUIBP:OnPostInitialize")
end
function RedSightUIBP:OnClose()
  print(bWriteLog and "RedSightUIBP:OnClose")
end
function RedSightUIBP:ReceivedInitWidget()
  print(bWriteLog and "RedSightUIBP:ReceivedInitWidget [1]")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("RotateViewWithSniperSwitch", function(BoolValue)
    self.RotateViewWithSniperSwitch = BoolValue
  end)
  local UserSettings = slua_GameFrontendHUD:GetUserSettings()
  if not UserSettings then
    print(bWriteLog and "RedSightUIBP:ReceivedInitWidget [2] UserSettings is nil")
    return
  end
  local RotateViewWithSniperSwitch = UserSettings.RotateViewWithSniperSwitch or false
  print(bWriteLog and string.format("RedSightUIBP:ReceivedInitWidget [3] RotateViewWithSniperSwitch: %s", tostring(RotateViewWithSniperSwitch)))
  self.  if slua.isValid(self.UIRoot) then
    if self.UIRoot.TextBlock_side then
      self.UIRoot.TextBlock_side:SetText(LocUtil.GetLocalizeResStr(12698))
    end
    if self.UIRoot.TextBlock_main then
      self.UIRoot.TextBlock_main:SetText(LocUtil.GetLocalizeResStr(12697))
    end
  end
end
function RedSightUIBP:OnPressDown(PointerIndex)
  print(bWriteLog and string.format("RedSightUIBP:OnPressDown [1] PointerIndex: %s", tostring(PointerIndex)))
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:OnRedSightPressed(PointerIndex, self.ISP90, self.RotateViewWithSniperSwitch)
  end
  if slua.isValid(self.UIRoot) and self.UIRoot.MultiRedButton then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      local AimMode = PlayerController.AimMode or 0
      print(bWriteLog and string.format("RedSightUIBP:OnPressDown [2] Set button type, AimMode: %s", tostring(AimMode)))
      self.UIRoot.MultiRedButton.ButtonType = AimMode
    end
  end
end
function RedSightUIBP:OnHoldEnded()
  print(bWriteLog and "RedSightUIBP:OnHoldEnded [1]")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:OnRedSightReleased(self.ISP90)
  end
end
function RedSightUIBP:UIMsg_NormalSideSight()
  print(bWriteLog and "RedSightUIBP:UIMsg_NormalSideSight [1]")
  self:SetSideSightMode()
  if not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.WidgetSwitcher_Redsight:SetActiveWidgetIndex(0)
  self.UIRoot.WidgetSwitcher_Redsight02:SetActiveWidgetIndex(1)
end
function RedSightUIBP:UIMsg_HighLightSideSight()
  print(bWriteLog and "RedSightUIBP:UIMsg_HighLightSideSight [1]")
  self:SetSideSightMode()
  if not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.WidgetSwitcher_Redsight02:SetActiveWidgetIndex(0)
  self.UIRoot.WidgetSwitcher_Redsight:SetActiveWidgetIndex(1)
end
function RedSightUIBP:UIMsg_HideSideSight()
  print(bWriteLog and "RedSightUIBP:UIMsg_HideSideSight [1]")
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.Redsight_Panel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function RedSightUIBP:UIMsg_ShowSideSight()
  print(bWriteLog and "RedSightUIBP:UIMsg_ShowSideSight [1]")
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.Redsight_Panel:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
end
function RedSightUIBP:UIMsg_ShootWeaponSight()
  print(bWriteLog and "RedSightUIBP:UIMsg_ShootWeaponSight [1]")
  if not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.WidgetSwitcher_Redsight:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self.UIRoot.Redsight_Panel:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  self.UIRoot.WidgetSwitcher_Redsight02:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self.UIRoot.WidgetSwitcher_P90_Redsight:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  self.UIRoot.WidgetSwitcher_P90_Redsight:SetActiveWidgetIndex(0)
  self.ISP90 = true
end
function RedSightUIBP:UIMsg_NormalWeaponSight()
  print(bWriteLog and "RedSightUIBP:UIMsg_NormalWeaponSight [1]")
  if not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.WidgetSwitcher_P90_Redsight:SetActiveWidgetIndex(0)
end
function RedSightUIBP:UIMsg_HighLightWeaponSight()
  print(bWriteLog and "RedSightUIBP:UIMsg_HighLightWeaponSight [1]")
  if not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.WidgetSwitcher_P90_Redsight:SetActiveWidgetIndex(1)
end
function RedSightUIBP:SetSideSightMode()
  print(bWriteLog and "RedSightUIBP:SetSideSightMode [1]")
  local UserSettings = slua_GameFrontendHUD:GetUserSettings()
  if not UserSettings then
    return
  end
  local SideMirrorMode = UserSettings.SideMirrorMode or 0
  print(bWriteLog and string.format("RedSightUIBP:SetSideSightMode [2] Side Mirror Mode : %s", tostring(SideMirrorMode)))
  if slua.isValid(self.UIRoot) then
    if SideMirrorMode ~= 1 then
      self.UIRoot.WidgetSwitcher_Redsight:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      self.UIRoot.WidgetSwitcher_Redsight02:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.WidgetSwitcher_Redsight:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      self.UIRoot.WidgetSwitcher_Redsight02:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
    self.UIRoot.WidgetSwitcher_P90_Redsight:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerPawn) then
    return
  end
  local FPPComponent = PlayerPawn.FPPComponent
  if not slua.isValid(FPPComponent) then
    return
  end
  local HasWeaponSight = FPPComponent:HaveWeaponSight()
  print(bWriteLog and string.format("RedSightUIBP:SetSideSightMode [3] HasWeaponSight: %s", tostring(HasWeaponSight)))
  if HasWeaponSight then
    self.ISP90 = true
  else
    self.ISP90 = false
  end
  PlayerPawn:RefreshWeaponSight()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CRedSightUIBP = class(ui_base, nil, RedSightUIBP)
return CRedSightUIBP