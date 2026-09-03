local WeaponKillCounterSubsystem = {}
function WeaponKillCounterSubsystem:_PostConstruct()
  printf(bWriteLog and "WeaponKillCounterSubsystem:_PostConstruct")
end
function WeaponKillCounterSubsystem:OnInit()
  printf(bWriteLog and "WeaponKillCounterSubsystem:OnInit")
  self:RegistEvents()
end
function WeaponKillCounterSubsystem:RegistEvents()
  printf(bWriteLog and "WeaponKillCounterSubsystem:OnInit")
  if Client then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.OnSpectatorChanged, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
  end
end
function WeaponKillCounterSubsystem:OnRelease()
  printf(bWriteLog and "WeaponKillCounterSubsystem:OnRelease")
  WeaponKillCounterSubsystem.__super.OnRelease(self)
end
function WeaponKillCounterSubsystem:OnSpectatorChanged()
  printf(bWriteLog and "WeaponKillCounterSubsystem:OnSpectatorChanged")
  self:GetCurBattleAllWeaponKillInfo()
end
function WeaponKillCounterSubsystem:OnReconnect()
  printf(bWriteLog and "WeaponKillCounterSubsystem:OnReconnect")
  self:GetCurBattleAllWeaponKillInfo()
end
function WeaponKillCounterSubsystem:GetCurBattleAllWeaponKillInfo()
  printf(bWriteLog and "WeaponKillCounterSubsystem:GetCurBattleAllWeaponKillInfo")
  if not Client then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) or not uPlayerCharacter.WeaponKillCounterFeature then
    return
  end
  local uid = Game:GetPlayerUID(uPlayerCharacter)
  if not uid then
    log(bWriteLog and "WeaponKillCounterSubsystem:GetCurBattleAllWeaponKillInfo uid is nil")
    return
  end
  uPlayerCharacter.WeaponKillCounterFeature:RPC_Server_GetCurBattleWeaponKillInfo(uid)
end
function WeaponKillCounterSubsystem:GetCurBattleWeaponKillCount_DS(PlayerPawn, originWeaponId)
  log(bWriteLog and "WeaponKillCounterSubsystem:GetCurBattleWeaponKillCount_DS")
  if Client then
    return 0
  end
  if not slua.isValid(PlayerPawn) or not PlayerPawn.PlayerUID then
    log(bWriteLog and "WeaponKillCounterSubsystem:GetCurBattleWeaponKillCount_DS invalid params")
    return 0
  end
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local WeaponKillCountData = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(PlayerPawn.PlayerUID), ExtendAttribute.WeaponKillCountData)
  local killcount = WeaponKillCountData and WeaponKillCountData[originWeaponId] or 0
  local curBattleKill = 0
  local playerKey = Game:GetPlayerKey(PlayerPawn)
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  if WeaponRecordSubSystem and playerKey then
    local UAvatarUtils = import("AvatarUtils")
    local weaponRecord = WeaponRecordSubSystem:GetOnePlayerRecordData(playerKey) or {}
    for weaponId, record in pairs(weaponRecord) do
      local realWeaponId = UAvatarUtils.GetAdjustWeaponID(weaponId)
      if realWeaponId == originWeaponId and record.KillCount and 0 < record.KillCount then
        curBattleKill = curBattleKill + record.KillCount
      end
    end
  end
  log(bWriteLog and "WeaponKillCounterSubsystem:GetCurBattleWeaponKillCount_DS WeaponId" .. tostring(originWeaponId) .. " killcount:" .. tostring(killcount) .. " curBattleKill:" .. tostring(curBattleKill))
  return killcount + curBattleKill
end
function WeaponKillCounterSubsystem:GetBroadcastFatalDamageExpandData(realKiller, uVictimPawn, outExpandDataTable)
  if not slua.isValid(realKiller) or not realKiller.PlayerUID then
    log(bWriteLog and "WeaponKillCounterSubsystem:GetBroadcastFatalDamageExpandData invalid params")
    return outExpandDataTable
  end
  if not uVictimPawn or not uVictimPawn.GetPlayerStateSafety then
    return outExpandDataTable
  end
  local uVictimPlayerState = uVictimPawn:GetPlayerStateSafety()
  if slua.isValid(uVictimPlayerState) and uVictimPlayerState.KillerWeaponID then
    local ExtendAttribute = require("Server.config.ExtendAttribute")
    local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
    local WeaponKillCounterEquip = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(realKiller.PlayerUID), ExtendAttribute.WeaponKillCounterEquip)
    local UAvatarUtils = import("AvatarUtils")
    local weaponId = UAvatarUtils.GetAdjustWeaponID(uVictimPlayerState.KillerWeaponID)
    if weaponId and WeaponKillCounterEquip and WeaponKillCounterEquip[weaponId] then
      if outExpandDataTable == nil then
        outExpandDataTable = {}
      end
      outExpandDataTable.KillCounterItemId = tostring(weaponId)
      local killcount = self:GetCurBattleWeaponKillCount_DS(realKiller, weaponId)
      outExpandDataTable.KillCounterNum = tostring(killcount)
    end
  end
  return outExpandDataTable
end
function WeaponKillCounterSubsystem:OnPlayerWeaponKillNumChange(uid, weaponId, killNum)
  if not Client then
    log(bWriteLog and "WeaponKillCounterSubsystem:OnPlayerWeaponKillNumChange not Client")
    return
  end
  if not (uid and weaponId) or not killNum then
    log(bWriteLog and "WeaponKillCounterSubsystem:OnPlayerWeaponKillNumChange invalid params")
    return
  end
  local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
  LogicKillCounter:UpdateCurBattleOneWeaponKillCount(uid, weaponId, killNum)
  log(bWriteLog and "WeaponKillCounterSubsystem:OnPlayerWeaponKillNumChange uid:" .. tostring(uid) .. " weaponId:" .. tostring(weaponId) .. " killNum:" .. tostring(killNum))
  EventSystem:postEvent(EVENTTYPE_KILL_COUNTER, EVENTID_KILL_COUNTER_NUM_REFRESH, uid)
end
function WeaponKillCounterSubsystem:OnHandleKillRecordChange(playerKey, weaponId, killNum)
  if Client then
    log(bWriteLog and "WeaponKillCounterSubsystem:OnHandleKillRecordChange Client")
    return
  end
  if not (playerKey and weaponId) or not killNum then
    log(bWriteLog and "WeaponKillCounterSubsystem:OnHandleKillRecordChange invalid params")
    return
  end
  local uPlayerState = Game:GetPlayerStateByPlayerKey(playerKey)
  if not (slua.isValid(uPlayerState) and uPlayerState.UID) or not uPlayerState.GetPlayerCharacter then
    log(bWriteLog and "WeaponKillCounterSubsystem:OnHandleKillRecordChange invalid uPlayerState")
    return
  end
  local uCharacter = uPlayerState:GetPlayerCharacter()
  if not slua.isValid(uCharacter) or not uCharacter.WeaponKillCounterFeature then
    log(bWriteLog and "WeaponKillCounterSubsystem:OnHandleKillRecordChange invalid uCharacter")
    return
  end
  local UAvatarUtils = import("AvatarUtils")
  local realWeaponId = UAvatarUtils.GetAdjustWeaponID(weaponId)
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local WeaponKillCounterEquip = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(uPlayerState.UID), ExtendAttribute.WeaponKillCounterEquip)
  if not WeaponKillCounterEquip or not WeaponKillCounterEquip[realWeaponId] then
    log(bWriteLog and "WeaponKillCounterSubsystem:OnHandleKillRecordChange weapon has no killcounter")
    return
  end
  if uCharacter.WeaponKillCounterFeature.SetCurChangedKillCounterInfo then
    uCharacter.WeaponKillCounterFeature:SetCurChangedKillCounterInfo(realWeaponId, killNum)
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, WeaponKillCounterSubsystem)