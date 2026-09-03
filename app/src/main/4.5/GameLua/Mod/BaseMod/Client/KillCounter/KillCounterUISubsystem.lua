local KillCounterUISubsystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SupportKCMainModeType = {
  [101] = true,
  [102] = true,
  [103] = true,
  [111] = true,
  [112] = true,
  [113] = true,
  [401] = true,
  [402] = true,
  [403] = true,
  [411] = true,
  [412] = true,
  [413] = true,
  [11201] = true,
  [23101] = true,
  [23103] = true,
  [12103] = true
}
function KillCounterUISubsystem:_PostConstruct()
  print(bWriteLog and "KillCounterUISubsystem:_PostConstruct")
end
function KillCounterUISubsystem:OnRegister()
  print(bWriteLog and "KillCounterUISubsystem:OnRegister")
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    self:OnRefreshCharacter()
  end)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnOBPlayerWeaponChangedDelegate", self.TryRefreshUserData, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnLiveStateChanged", self.OnLiveStateChanged, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.TryRefreshUserData, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.RefreshMainKCVisible, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerChangeWearingDone", self.OnChangeRoleWearDone, self)
  self:AddSettingOptionEvent("bShowKillCounter", function(bShowKillCounter)
    self:RefreshMainKCVisible()
  end)
  self:AddCommonEvent(EVENTTYPE_KILL_COUNTER, EVENTID_KILL_COUNTER_NUM_REFRESH, self.OnKillCounterRefresh, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT, self.OnEnterBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.OnEnterBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_WEAPON_KILLCOUNTER, EVENTID_WEAPON_KILLCOUNTER_INFO_RSP, self.RefreshMainKCVisible, self)
end
function KillCounterUISubsystem:OnChangeRoleWearDone()
  self:AddTimer(0, function()
    self:RefreshMainKCVisible()
  end)
end
function KillCounterUISubsystem:UpdateCurUsingWeapon(TargetChangeSlot, ChangeType)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local bIsShow = SettingModule:GetOptionValue("bShowKillCounter")
  if not bIsShow then
    return
  end
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local STExtraShootWeapon = import("STExtraShootWeapon")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetCurPlayerCharacter()
  if not slua.isValid(PlayerCharacter) or not PlayerCharacter.PlayerUID then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  local PlayerID = tonumber(PlayerCharacter.PlayerUID)
  if TargetChangeSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    local CurWeapon = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
    self:CheckNeedMainKillCounterUI(CurWeapon, PlayerID)
  elseif TargetChangeSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    local CurWeapon = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
    self:CheckNeedMainKillCounterUI(CurWeapon, PlayerID)
  elseif TargetChangeSlot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    local CurWeapon = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
    self:CheckNeedMainKillCounterUI(CurWeapon, PlayerID)
  else
    self:UpdateMainKillCounterUI(false)
  end
end
function KillCounterUISubsystem:TryRefreshUserData()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetCurPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local PlayerID = Game:GetPlayerUID(PlayerCharacter)
  local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
  LogicKillCounter:ReqAccumulationKillInfo(PlayerID)
end
function KillCounterUISubsystem:CheckNeedMainKillCounterUI(Weapon, PlayerID)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController:IsDemoPlayGlobalObserver() or PlayerController:IsObserver() then
    self:UpdateMainKillCounterUI(false)
    return
  end
  if not slua.isValid(Weapon) then
    self:UpdateMainKillCounterUI(false)
    return
  end
  local WeaponID = Weapon:GetWeaponID()
  local AvatarID = Weapon:GetWeaponMainAvatarID()
  local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
  local curEquipedKillCounter = LogicKillCounter:GetEquipedKillCounterId(PlayerID, WeaponID)
  print(bWriteLog and "KillCounterUISubsystem:CheckNeedMainKillCounterUI WeaponID ", WeaponID, " PlayerID:", PlayerID, " curEquipedKillCounter: ", curEquipedKillCounter)
  if not curEquipedKillCounter then
    self:UpdateMainKillCounterUI(false)
  else
    self:UpdateMainKillCounterUI(true, WeaponID, AvatarID)
  end
end
function KillCounterUISubsystem:UpdateMainKillCounterUI(bShow, WeaponID, AvatarID)
  log(bWriteLog and "KillCounterUISubsystem:UpdateMainKillCounterUI")
  local MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
  if not self:CheckSupportKCUI() then
    log(bWriteLog and "KillCounterUISubsystem:UpdateMainKillCounterUI not support")
    return
  end
  if not bShow and MainKillCounter then
    UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter)
  elseif bShow then
    if not MainKillCounter then
      UIManager.ShowUI(UIManager.UI_Config_InGame.MainKillCounter, WeaponID, AvatarID)
    else
      MainKillCounter:UpdateWeaponID(WeaponID, AvatarID)
    end
  end
end
function KillCounterUISubsystem:RefreshMainKCVisible(PlayerCharacter)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local bIsShow = SettingModule:GetOptionValue("bShowKillCounter")
  if not bIsShow then
    self:UpdateMainKillCounterUI(false)
  else
    if PlayerCharacter == nil or not slua.isValid(PlayerCharacter) then
      local PlayerController = GameplayData.GetPlayerController()
      if not slua.isValid(PlayerController) then
        return
      end
      PlayerCharacter = PlayerController:GetCurPlayerCharacter()
      if not slua.isValid(PlayerCharacter) then
        return
      end
    end
    local WeaponManager = PlayerCharacter:GetWeaponManager()
    if not slua.isValid(WeaponManager) then
      return
    end
    local Weapon = WeaponManager:GetCurrentUsingWeapon()
    local PlayerID = Game:GetPlayerUID(PlayerCharacter)
    self:CheckNeedMainKillCounterUI(Weapon, PlayerID)
  end
end
function KillCounterUISubsystem:OnRefreshCharacter()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetCurPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if slua.isValid(WeaponManager) then
    self:AddControlEvent(WeaponManager, "ChangeCurrentUsingWeaponDelegate", self.UpdateCurUsingWeapon, self)
  end
  self:RefreshMainKCVisible(PlayerCharacter)
end
function KillCounterUISubsystem:OnKillCounterRefresh(_, _, UID)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetCurPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local SelfUID = Game:GetPlayerUID(PlayerCharacter)
  if SelfUID == UID then
    self:RefreshMainKCVisible(PlayerCharacter)
  end
end
function KillCounterUISubsystem:OnEnterBattleResult()
  self:UpdateMainKillCounterUI(false)
end
function KillCounterUISubsystem:CheckSupportKCUI()
  log(bWriteLog and "KillCounterUISubsystem:CheckSupportKCUI")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    log(bWriteLog and "KillCounterUISubsystem:CheckSupportKCUI not valid PlayerController")
    return false
  end
  if PlayerController:IsRoomMode() then
    log(bWriteLog and "KillCounterUISubsystem:CheckSupportKCUI is RoomMode")
    return false
  end
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  if uGameInstance then
    local CurMainModeID = uGameInstance:GetMainModeID()
    log(bWriteLog and "KillCounterUISubsystem:CheckSupportKCUI CurMainModeID: " .. tostring(CurMainModeID))
    return SupportKCMainModeType[CurMainModeID]
  end
  return false
end
function KillCounterUISubsystem:OnLiveStateChanged(State)
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if State == ExtraPlayerLiveState.InDied then
    self:UpdateMainKillCounterUI(false)
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, KillCounterUISubsystem)