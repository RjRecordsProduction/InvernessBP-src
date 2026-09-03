local MSSwitchUI = {}
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EWeaponChangeInvenroryDataType = import("EWeaponChangeInvenroryDataType")
local UIUtil = require("client.common.ui_util")
function MSSwitchUI:ctor(_)
  print(bWriteLog and "MSSwitchUI:ctor")
  self.TimerHandleChangeInventoryData = nil
  self.TimerForBindWeaponChangeDelegate = nil
end
function MSSwitchUI:OnInitialize()
  print(bWriteLog and "MSSwitchUI:OnInitialize")
  self:BindWeaponChangeDelegate()
end
function MSSwitchUI:RegistEvents()
  print(bWriteLog and "MSSwitchUI:RegistEvents")
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.LeftWeaponMSwitchPanel, self, "ShootingUIPanel_MultiLayer_LeftWeaponSlot")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.RightWeaponMSwitchPanel, self, "ShootingUIPanel_MultiLayer_RightWeaponSlot")
  self:AddOnClickedEventByControl(self.UIRoot.LeftWeaponMSwitchBtn, self.SwitchFireMode, self, ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
  self:AddOnClickedEventByControl(self.UIRoot.RightWeaponMSwitchBtn, self.SwitchFireMode, self, ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
  self:AddCommonEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_FIREMODE_UPDATE, self.OnWeaponSlotFireModeChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_FIREMODEVISIBILITY_CHANGE, self.OnWeaponSlotFireModeVisibleChange, self)
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    self.bSeperateShootMBtn = SettingSubsystem:GetUserSettings_Bool("bSeperateShootMBtn")
    self:RefreshByBSeperateShootMBtn()
    SettingSubsystem:RegisterUserSettingsDelegate_Bool("bSeperateShootMBtn", function(bSeperateShootMBtn)
      print(bWriteLog and "ShootingUIPanelIMP:RegistEventsDelay bSeperateShootMBtn:" .. tostring(bSeperateShootMBtn))
      if bSeperateShootMBtn ~= self.bSeperateShootMBtn then
        self.        self:RefreshByBSeperateShootMBtn()
      end
    end)
  end
end
function MSSwitchUI:OnWeaponSlotFireModeVisibleChange(_, _, SlotType, bVisible)
  print(bWriteLog and "MSSwitchUI:OnWeaponSlotFireModeVisibleChange", SlotType, bVisible)
  if not self.bSeperateShootMBtn then
    return
  end
  local Index = SlotType == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 and 1 or 2
  self:ShowMSwitchBtn(Index, bVisible)
end
function MSSwitchUI:OnWeaponSlotFireModeChange(_, _, SlotType, ModeText, ModeBrush)
  print(bWriteLog and "MSSwitchUI:OnWeaponSlotFireModeChange", SlotType, ModeText, ModeBrush)
  if not self.bSeperateShootMBtn then
    return
  end
  if SlotType == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    self.UIRoot.Text_Weapon1_MSwitch:SetText(ModeText)
    self.UIRoot.Image_Weapon1_MSwitch:SetBrush(ModeBrush)
  elseif SlotType == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    self.UIRoot.Text_Weapon2_MSwitch:SetText(ModeText)
    self.UIRoot.Image_Weapon2_MSwitch:SetBrush(ModeBrush)
  end
end
function MSSwitchUI:SwitchFireMode(SlotType)
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_FIREMODE_CHANGE, SlotType)
end
function MSSwitchUI:BindWeaponChangeDelegate()
  self:_BindWeaponChangeDelegateInternal()
end
function MSSwitchUI:_BindWeaponChangeDelegateInternal()
  print(bWriteLog and "MSSwitchUI:BindWeaponChangeDelegate")
  if self.TimerForBindWeaponChangeDelegate then
    self:RemoveGameTimer(self.TimerForBindWeaponChangeDelegate)
    self.TimerForBindWeaponChangeDelegate = nil
  end
  local WeaponManager = self:GetWeaponManager()
  if not WeaponManager then
    self.TimerForBindWeaponChangeDelegate = self:AddGameTimer(0.5, false, function()
      print(bWriteLog and "MSSwitchUI:BindWeaponChangeDelegate Loop2")
      self.TimerForBindWeaponChangeDelegate = nil
      self:BindWeaponChangeDelegate()
    end)
    return
  end
  self:HandleChangeInventoryData(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:HandleChangeInventoryData(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2, EWeaponChangeInvenroryDataType.EWCIDT_Init)
end
function MSSwitchUI:HandleChangeInventoryData(TargetChangeSlot, EChangeType)
  print(bWriteLog and "MSSwitchUI:HandleChangeInventoryData")
  self:UpdateTopRightWeaponBulletWhenEquipAndUnequip(TargetChangeSlot, EChangeType)
end
function MSSwitchUI:UpdateTopRightWeaponBulletWhenEquipAndUnequip(WeaponSlot, ChangeType)
  print(bWriteLog and "MSSwitchUI:UpdateTopRightWeaponBulletWhenEquipAndUnequip")
  local WeaponManager = self:GetWeaponManager()
  if not WeaponManager then
    return
  end
  local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(WeaponSlot)
  if not slua.isValid(Weapon) then
    if WeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
      self:ShowMSwitchBtn(1, false)
    elseif WeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
      self:ShowMSwitchBtn(2, false)
    end
  end
end
function MSSwitchUI:ShowMSwitchBtn(Index, bShow)
  local Visibility = bShow and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed
  if Index == 1 then
    self.UIRoot.LeftWeaponMSwitchBtn:SetWidgetVisibility(Visibility)
  elseif Index == 2 then
    self.UIRoot.RightWeaponMSwitchBtn:SetWidgetVisibility(Visibility)
  end
end
function MSSwitchUI:OnPlayerCharacterChange(_, PlayerCharacter)
  self:BindWeaponChangeDelegate()
end
function MSSwitchUI:RefreshByBSeperateShootMBtn()
  print(bWriteLog and "MSSwitchUI:RefreshByBSeperateShootMBtn", self.bSeperateShootMBtn)
  if self.bSeperateShootMBtn then
    self:SelfHitTestInvisible()
  else
    self:Collapsed()
  end
end
function MSSwitchUI:ResetUIStateAfterRespawn()
  print(bWriteLog and "MSSwitchUI:ResetUIStateAfterRespawn")
  local GameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(GameState) then
    print(bWriteLog and "MSSwitchUI:ResetUIStateAfterRespawn not slua.isValid(uGameState)")
    return
  end
  local EGameModeType = import("EGameModeType")
  local bIsInfectGameMode = GameState.GameModeType == EGameModeType.EPVEInfectionGameMode
  if bIsInfectGameMode then
    GameplayData.AddSelfPlayerCharacterEvent(self, "OnWeaponFireModeChangeDelegate", function()
      self:HandleCurWeaponFireModeChange()
    end)
  end
  if GameState.GameModeType == EGameModeType.EWarGameMode then
    self:BindWeaponChangeDelegate()
  end
  if GameState.bReInitUIAfterReCreatePawn then
    print(bWriteLog and "MSSwitchUI:ResetUIStateAfterRespawn uGameState.bReInitUIAfterReCreatePawn")
    return
  end
  self:BindWeaponChangeDelegate()
end
function MSSwitchUI:Reconnect_ResetUIByPlayerControllerState()
  print(bWriteLog and "MSSwitchUI:Reconnect_ResetUIByPlayerControllerState")
  self:BindWeaponChangeDelegate()
end
function MSSwitchUI:GetWeaponManager()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "MSSwitchUI:HandleCurWeaponFireModeChange not slua.isValid(PlayerCharacter)")
    return nil
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "MSSwitchUI:HandleCurWeaponFireModeChange not slua.isValid(WeaponManager)")
    return nil
  end
  return WeaponManager
end
function MSSwitchUI:Show()
  print(bWriteLog and "MSSwitchUI:Show")
  MSSwitchUI.__super.Show(self)
end
function MSSwitchUI:Collapsed()
  print(bWriteLog and "MSSwitchUI:Collapsed")
  MSSwitchUI.__super.Collapsed(self)
end
function MSSwitchUI:OnClose()
  print(bWriteLog and "MSSwitchUI:OnClose")
  MSSwitchUI.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CMSSwitchUI = class(ui_base, nil, MSSwitchUI)
return CMSSwitchUI