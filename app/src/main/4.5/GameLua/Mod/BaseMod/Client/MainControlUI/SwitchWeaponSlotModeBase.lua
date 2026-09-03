local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local SwitchWeaponSlotModeBase = {}
function SwitchWeaponSlotModeBase:ctor(selfType, SlotType)
  self.  local Playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.GuideInfo = Playerprefs.LoadFileToTable_N(Playerprefs.ePlayerPrefsType.eVehicleSwitchWeaponGuideCount) or {}
  if not self.GuideInfo.GuideCount then
    self.GuideInfo.GuideCount = 0
  end
end
function SwitchWeaponSlotModeBase:RegistEvents()
  print(bWriteLog and "SwitchWeaponSlotModeBase:RegistEvents")
  SwitchWeaponSlotModeBase.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "ClickOnSwitchWeapon", self.ClickOnSwitchWeapon, self, self.SlotType)
  self:AddControlEventByControl(self.UIRoot, "ReleaseOnSwitchWeapon", self.ReleaseOnSwitchWeapon, self, self.SlotType)
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  if self.SlotType == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    local GameplayActorData = require("GameLua.GameCore.Data.GameplayActorData")
    self:AddDataListener(GameplayActorData.GetSuppertData(), "CurrentVehicle", self.OnCurrentVehicleChange, self)
  end
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SCOPECHANGE, self.OnScopingChange_Handle, self)
end
function SwitchWeaponSlotModeBase:OnScopingChange_Handle(_, _, nPlayerKey, bIsGunADS)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  local CurUsingWeaponSlot = OperateSubsystem:GetCurrentUsingPropSlot()
  if CurUsingWeaponSlot ~= self.SlotType then
    return
  end
  local CurWeapon = OperateSubsystem:GetCurUsingWeapon()
  if slua.isValid(CurWeapon) and CurWeapon:GetItemDefineID() and CurWeapon:GetItemDefineID().TypeSpecificID == 104102 then
    self:OnNeosteadFireModeChange(bIsGunADS)
  end
end
function SwitchWeaponSlotModeBase:OnPostInitialize()
  self.UIRoot.WeaponSlotType = self.SlotType
end
function SwitchWeaponSlotModeBase:OnCurrentVehicleChange(_, CurrentVehicle)
  if not slua.isValid(CurrentVehicle) then
    return
  end
  if not CurrentVehicle.bNeedWeaponSlot then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.BP_VehicleUser then
    print(bWriteLog and "SwitchWeaponSlotModeBase:OnCurrentVehicleChange cont find PC or BP_VehicleUser")
    return
  end
  local SeatType = PlayerController.BP_VehicleUser.SeatType
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  if SeatType ~= ESTExtraVehicleSeatType.ESeatType_DriversSeat then
    return
  end
  if self.GuideInfo.GuideCount == 0 then
    self:StartGuide()
    self:AddGameTimer(5, false, function()
      self:FinishGuide()
    end)
  end
end
function SwitchWeaponSlotModeBase:StartGuide()
  local SwitchWeaponGuideTips = self:CreateChildWindow(self.UIRoot.CanvasPanel_Main, UIManager.UI_Config_InGame.SwitchWeaponGuideTips)
  if SwitchWeaponGuideTips then
    SwitchWeaponGuideTips:SetAnchors(0.5, 0, 0.5, 0)
    SwitchWeaponGuideTips:SetAlignment(0.5, 1.0)
    SwitchWeaponGuideTips:SetPosition(0, -12)
    SwitchWeaponGuideTips:SetAutoSize(true)
  end
end
function SwitchWeaponSlotModeBase:FinishGuide()
  UIManager.CloseUI(UIManager.UI_Config_InGame.SwitchWeaponGuideTips)
  if self.GuideInfo.GuideCount == 0 then
    self.GuideInfo.GuideCount = self.GuideInfo.GuideCount + 1
    local Playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
    Playerprefs.SaveTableToFile_N(self.GuideInfo, Playerprefs.ePlayerPrefsType.eVehicleSwitchWeaponGuideCount)
  end
end
function SwitchWeaponSlotModeBase:ClickOnSwitchWeapon(Slot)
  self:FinishGuide()
  print(bWriteLog and "SwitchWeaponSlotModeBase:ClickOnSwitchWeapon " .. tostring(Slot))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "SwitchWeaponSlotModeBase:ClickOnSwitchWeapon not uPlayerCharacter")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "SwitchWeaponSlotModeBase:ClickOnSwitchWeapon not WeaponManager")
    return
  end
  local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(Slot)
  if Weapon then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
    if not ShootingUIPanelLuaClass then
      return
    end
    ShootingUIPanelLuaClass:HandleTopRightWeaponSwitch(Slot)
  elseif self:IsValidEmptyWeaponSlotForQuickHint(Slot) then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      MainControlPanelTochButton:SendQuickNeedText(23)
    end
  end
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.SwitchWeapon, 1)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UGC_NATIVE_BUTTON_PRESSED, "SwitchGun")
end
function SwitchWeaponSlotModeBase:ReleaseOnSwitchWeapon(Slot)
  print(bWriteLog and "SwitchWeaponSlotModeBase:ReleaseOnSwitchWeapon " .. tostring(Slot))
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UGC_NATIVE_BUTTON_RELEASED, "SwitchGun")
end
function SwitchWeaponSlotModeBase:IsValidEmptyWeaponSlotForQuickHint(Slot)
  return Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 or Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2
end
function SwitchWeaponSlotModeBase:ClearWeaponSlotData()
  if self.UIRoot then
    self.UIRoot:ClearWeaponSlotData()
  end
end
function SwitchWeaponSlotModeBase:UpdateWeaponDurability(ShootWeapon)
  if self.UIRoot then
    self.UIRoot:UpdateWeaponDurability(ShootWeapon)
  end
end
function SwitchWeaponSlotModeBase:SetRenderScale(Scale)
  if self.UIRoot then
    self.UIRoot:SetRenderScale(Scale)
  end
end
function SwitchWeaponSlotModeBase:SetColorAndOpacity(Color)
  if self.UIRoot then
    self.UIRoot:SetColorAndOpacity(Color)
  end
end
function SwitchWeaponSlotModeBase:ShowHideFireMode(bIsShow, ShootWeapon)
  if self.UIRoot then
    self.UIRoot:Show_HideFireMode(bIsShow, ShootWeapon)
  end
end
function SwitchWeaponSlotModeBase:UpdateFireModeShape(bIsShow)
  if self.UIRoot then
    self.UIRoot:UpdateFireModeShape(bIsShow)
  end
end
function SwitchWeaponSlotModeBase:SetFireModeText()
  if self.UIRoot then
    self.UIRoot:SetFireModeText()
  end
end
function SwitchWeaponSlotModeBase:SetBorderOpacity(Opacity)
  if self.UIRoot then
    self.UIRoot:SetBorderOpacity(Opacity)
  end
end
function SwitchWeaponSlotModeBase:SelectedUnSelected(IsSelected)
  if self.UIRoot then
    self.UIRoot:Selected_UnSelected(IsSelected)
  end
end
function SwitchWeaponSlotModeBase:UpdateShield()
  if self.UIRoot then
    self.UIRoot:UpdateShield()
  end
end
function SwitchWeaponSlotModeBase:AddAttachmentAnimationToQuere(DefineID)
  if self.UIRoot then
    self.UIRoot:AddAttachmentAnimationToQuere(DefineID)
  end
end
function SwitchWeaponSlotModeBase:SetLeftBulletRate(CountYellow, CountRed)
  if self.UIRoot then
    self.UIRoot:SetLeftBulletRate(CountYellow, CountRed)
  end
end
function SwitchWeaponSlotModeBase:ShowHideSwitchWeaponTips(bIsShowGuide, TempGuideText)
  if self.UIRoot then
    self.UIRoot:Show_HideSwitchWeaponTips(bIsShowGuide, TempGuideText)
  end
end
function SwitchWeaponSlotModeBase:ChangeWeaponImage(ImagePath)
  if self.UIRoot then
    self.UIRoot:ChangeWeaponImage(ImagePath)
  end
end
function SwitchWeaponSlotModeBase:SetNextSelect(NextSelect)
  if self.UIRoot then
    self.UIRoot:SetNextSelect(NextSelect)
  end
end
function SwitchWeaponSlotModeBase:UpdateBulletByWeapon(Weapon, NeedUpdateBackpackNum)
  if self.UIRoot then
    self.UIRoot:UpdateBulletByWeapon(Weapon, NeedUpdateBackpackNum)
  end
end
function SwitchWeaponSlotModeBase:UpdateWeaponDurabilityAnimation()
  if self.UIRoot then
    self.UIRoot:UpdateWeaponDurabilityAnimation()
  end
end
function SwitchWeaponSlotModeBase:OnNeosteadFireModeChange(bIsGunADS)
  if self.UIRoot then
    self.UIRoot:OnNeosteadFireModeChange(bIsGunADS)
  end
end
function SwitchWeaponSlotModeBase:ShowHideEmbeddedMSwitch(bShow)
  if not self.UIRoot then
    return
  end
  self.UIRoot:ShowHideEmbeddedMSwitch(bShow)
end
function SwitchWeaponSlotModeBase:CanShowFireModeSwitchBtn()
  return self.UIRoot:CanShowFireModeSwitchBtn(self.UIRoot.CurWeapon)
end
function SwitchWeaponSlotModeBase:GetModTextAndBrush()
  return self.UIRoot:GetModTextAndBrush()
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
function SwitchWeaponSlotModeBase:OnClose()
  print(bWriteLog and "SwitchWeaponSlotModeBase:OnClose")
  SwitchWeaponSlotModeBase.__super.OnClose(self)
end
return class(UIBase, nil, SwitchWeaponSlotModeBase)