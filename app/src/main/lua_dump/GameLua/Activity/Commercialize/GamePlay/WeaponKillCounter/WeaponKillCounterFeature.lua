local WeaponKillCounterFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
WeaponKillCounterFeature.ClientRPC.RPC_Client_UpdateCurBattleWeaponKillInfo = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt64,
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
}
WeaponKillCounterFeature.ServerRPC.RPC_Server_GetCurBattleWeaponKillInfo = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt64
  }
}
function WeaponKillCounterFeature:ctor()
  self.ChangedKillCounterInfo = slua.Array(UEnums.EPropertyClass.Int)
end
function WeaponKillCounterFeature:ReceiveBeginPlay()
  print(bWriteLog and "WeaponKillCounterFeature:ReceiveBeginPlay")
  WeaponKillCounterFeature.__super.ReceiveBeginPlay(self)
end
function WeaponKillCounterFeature:GetLifetimeReplicatedProps()
  print(bWriteLog and "WeaponKillCounterFeature:GetLifetimeReplicatedProps")
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "ChangedKillCounterInfo",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
end
function WeaponKillCounterFeature:SetCurChangedKillCounterInfo(weaponId, killNum)
  if Client then
    return
  end
  print(bWriteLog and "WeaponKillCounterFeature:SetCurChangedKillCounterInfo, weaponId = " .. tostring(weaponId) .. ", killNum = " .. tostring(killNum))
  if self.ChangedKillCounterInfo:Num() >= 2 then
    self.ChangedKillCounterInfo:Set(0, weaponId)
    self.ChangedKillCounterInfo:Set(1, killNum)
  else
    self.ChangedKillCounterInfo:Add(weaponId)
    self.ChangedKillCounterInfo:Add(killNum)
  end
end
function WeaponKillCounterFeature:OnRep_ChangedKillCounterInfo()
  if not self.ChangedKillCounterInfo or self.ChangedKillCounterInfo:Num() < 2 then
    print(bWriteLog and "WeaponKillCounterFeature:OnRep_ChangedKillCounterInfo, invalid data")
    return
  end
  local PlayerState = self.Owner:GetPlayerStateSafety()
  if not PlayerState or not slua.isValid(PlayerState) then
    print(bWriteLog and "WeaponKillCounterFeature:OnRep_ChangedKillCounterInfo, invalid PlayerState")
    return
  end
  local weaponId = self.ChangedKillCounterInfo:Get(0)
  local killNum = self.ChangedKillCounterInfo:Get(1)
  print(bWriteLog and "WeaponKillCounterFeature:OnRep_ChangedKillCounterInfo, weaponId = " .. tostring(weaponId) .. ", killNum = " .. tostring(killNum))
  local WeaponKillCounterSubsystem = SubsystemMgr:Get("WeaponKillCounterSubsystem")
  if WeaponKillCounterSubsystem then
    WeaponKillCounterSubsystem:OnPlayerWeaponKillNumChange(PlayerState.UID, weaponId, killNum)
  end
end
function WeaponKillCounterFeature:RPC_Server_GetCurBattleWeaponKillInfo(UID)
  if Client then
    return
  end
  local uPlayerController = Game:GetPlayerControllerByUID(UID or 0)
  if not slua.isValid(uPlayerController) then
    return
  end
  local playerKey = uPlayerController.PlayerKey
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  if not WeaponRecordSubSystem then
    return
  end
  local weaponCountMap = {}
  local UAvatarUtils = import("AvatarUtils")
  local weaponRecord = WeaponRecordSubSystem:GetOnePlayerRecordData(playerKey)
  for weaponId, record in pairs(weaponRecord or {}) do
    local realWeaponId = UAvatarUtils.GetAdjustWeaponID(weaponId)
    if realWeaponId and record.KillCount and 0 < record.KillCount then
      weaponCountMap[realWeaponId] = weaponCountMap[realWeaponId] or 0
      weaponCountMap[realWeaponId] = weaponCountMap[realWeaponId] + record.KillCount
    end
  end
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local WeaponKillCounterEquip = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(UID), ExtendAttribute.WeaponKillCounterEquip)
  local weaponCountList = slua.Array(UEnums.EPropertyClass.Int)
  for weaponId, KillCount in pairs(weaponCountMap) do
    if WeaponKillCounterEquip and WeaponKillCounterEquip[weaponId] then
      weaponCountList:Add(weaponId)
      weaponCountList:Add(KillCount)
    end
  end
  self:RPC_Client_UpdateCurBattleWeaponKillInfo(UID, weaponCountList)
end
function WeaponKillCounterFeature:RPC_Client_UpdateCurBattleWeaponKillInfo(UID, KillInfoList)
  if not UID or not KillInfoList then
    log(bWriteLog and "WeaponKillCounterSubsystem:RPC_Client_UpdateCurBattleWeaponKillInfo invalid params")
    return
  end
  local listNum = KillInfoList:Num()
  if listNum <= 0 or listNum % 2 ~= 0 then
    log(bWriteLog and "WeaponKillCounterSubsystem:RPC_Client_UpdateCurBattleWeaponKillInfo invalid KillInfoList")
    return
  end
  local killCountMap = {}
  for i = 1, listNum - 1, 2 do
    local weaponId = KillInfoList:Get(i - 1)
    local killcount = KillInfoList:Get(i)
    killCountMap[weaponId] = killcount
  end
  log_tree(bWriteLog and "WeaponKillCounterSubsystem:RPC_Client_UpdateCurBattleWeaponKillInfo KillInfoList ", KillInfoList)
  local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
  LogicKillCounter:SetCurBattleWeaponKillCount(UID, killCountMap)
  EventSystem:postEvent(EVENTTYPE_KILL_COUNTER, EVENTID_KILL_COUNTER_NUM_REFRESH, UID)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CWeaponKillCounterFeature = class(CFeatureBase, nil, WeaponKillCounterFeature)
return require("combine_class").SetFeatureDynamic(CWeaponKillCounterFeature)