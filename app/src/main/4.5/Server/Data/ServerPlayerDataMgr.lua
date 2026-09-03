local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
require("client.logic.data.AvatarData")
local ServerPlayerDataMgr = {
  ProgressType = {ExtAttr = 1, TLog = 2}
}
local SyncPlayerInfos = {}
local tPlayerInGameItems = {}
local PlayerTLogDatas = {}
local PlayerPassThroughDatas = {}
local PlayerSkillInfos = {}
local ModeInfo = {}
function ServerPlayerDataMgr.Init()
  local TLogEventHandler = require("Server.Data.TLogEventHandler")
  ServerPlayerDataMgr.TLogEvent = TLogEventHandler()
  ServerPlayerDataMgr.TLogEvent:Init()
  EventSystem:registEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_NEAR_DEATH, ServerPlayerDataMgr.OnPawnNearDeath)
  local uGameStatisComp = CGame:GetGameStatisComponent()
  if uGameStatisComp ~= nil then
    uGameStatisComp:InitTLogDamageToPlayerCount()
  end
end
function ServerPlayerDataMgr.ExtraInfoToStr(info)
  local ExtraInfoStr = ""
  for key, value in pairs(info) do
    if value ~= nil and key ~= "ExtraInfoStr" then
      local str
      if type(value) ~= "table" then
        str = tostring(key) .. ":" .. tostring(value) .. ","
      else
        str = tostring(key) .. ":" .. ServerPlayerDataMgr.TableToStrInOrder(value) .. ","
      end
      ExtraInfoStr = ExtraInfoStr .. str
    end
  end
  log_tree("ServerPlayerDataMgr.ExtraInfoToStr: before" .. ExtraInfoStr, info)
  info = {}
  info.  log_tree("ServerPlayerDataMgr.ExtraInfoToStr: after" .. ExtraInfoStr, info)
  return ExtraInfoStr
end
function ServerPlayerDataMgr.TableToStrInOrder(tb)
  local retStr = "("
  for key, value in ipairs(tb) do
    if value == nil then
      return "()"
    end
    if type(value) ~= "table" then
      if type(value) == "userdata" and value.ToString then
        retStr = retStr .. value:ToString() .. ","
      else
        retStr = retStr .. tostring(value) .. ","
      end
    else
      retStr = retStr .. ServerPlayerDataMgr.TableToStrInOrder(value) .. ","
    end
  end
  return retStr .. ")"
end
function ServerPlayerDataMgr.GetSkillInfos(nUID)
  if type(nUID) == "string" then
    nUID = tonumber(nUID)
  end
  if PlayerSkillInfos[nUID] == nil then
    PlayerSkillInfos[nUID] = {}
  end
  return PlayerSkillInfos[nUID]
end
function ServerPlayerDataMgr.GetModInfos(nUID)
  if type(nUID) == "string" then
    nUID = tonumber(nUID)
  end
  if ModeInfo[nUID] == nil then
    ModeInfo[nUID] = {}
  end
  return ModeInfo[nUID]
end
function ServerPlayerDataMgr.AddSkillBaseInfo(uPlayerCharacter, nSkillId)
  if nil == uPlayerCharacter then
    print(bWriteLog and "ServerPlayerDataMgr.AddSkillBaseInfo uPlayerCharacter invalid")
    return
  end
  local uPlayerState = uPlayerCharacter:GetPlayerStateSafety()
  if nil == uPlayerState then
    print(bWriteLog and "ServerPlayerDataMgr.AddSkillBaseInfo uPlayerState invalid")
    return
  end
  local PlayerSkillInfo = ServerPlayerDataMgr.GetSkillInfos(uPlayerState.UID)
  if PlayerSkillInfo.BaseInfo == nil then
    PlayerSkillInfo.BaseInfo = {}
  end
  if PlayerSkillInfo.BaseInfo[nSkillId] == nil then
    PlayerSkillInfo.BaseInfo[nSkillId] = {}
  end
  local nSkillInfoCnt = PlayerSkillInfo.BaseInfo[nSkillId].SkillInfoCnt
  if nSkillInfoCnt == nil then
    nSkillInfoCnt = 0
  end
  nSkillInfoCnt = nSkillInfoCnt + 1
  local BaseInfo = {}
  local CurPawnLoc = Game:GetActorLocation(uPlayerCharacter)
  BaseInfo.PositionX = CurPawnLoc.X
  BaseInfo.PositionY = CurPawnLoc.Y
  BaseInfo.PositionZ = CurPawnLoc.Z
  BaseInfo.StartTime = ServerPlayerDataMgr.GetTime()
  PlayerSkillInfo.BaseInfo[nSkillId][nSkillInfoCnt] = BaseInfo
  PlayerSkillInfo.BaseInfo[nSkillId].SkillInfoCnt = nSkillInfoCnt
  log_tree("ServerPlayerDataMgr.AddSkillBaseInfo", PlayerSkillInfo.BaseInfo)
end
function ServerPlayerDataMgr.GetLatestSkillExtraInfoCnt(nUID, nSkillId)
  return ServerPlayerDataMgr.GetorAddSkillExtraInfo(nUID, nSkillId, -1)
end
function ServerPlayerDataMgr.GetorAddSkillExtraInfo(nUID, nSkillId, nSkillInfoCnt)
  local PlayerSkillInfo = ServerPlayerDataMgr.GetSkillInfos(nUID)
  if nSkillInfoCnt <= 0 then
    local BaseInfo = PlayerSkillInfo.BaseInfo
    if PlayerSkillInfo == nil or BaseInfo == nil or BaseInfo[nSkillId] == nil or BaseInfo[nSkillId].SkillInfoCnt == nil then
      print(bWriteLog and "ServerPlayerDataMgr.AddSkillExtraInfo baseinfo not exist")
      return nil
    end
    nSkillInfoCnt = BaseInfo[nSkillId].SkillInfoCnt
  end
  if PlayerSkillInfo.ExtraInfo == nil then
    PlayerSkillInfo.ExtraInfo = {}
  end
  if PlayerSkillInfo.ExtraInfo[nSkillId] == nil then
    PlayerSkillInfo.ExtraInfo[nSkillId] = {}
  end
  if PlayerSkillInfo.ExtraInfo[nSkillId][nSkillInfoCnt] == nil then
    PlayerSkillInfo.ExtraInfo[nSkillId][nSkillInfoCnt] = {}
  end
  return PlayerSkillInfo.ExtraInfo[nSkillId][nSkillInfoCnt]
end
function ServerPlayerDataMgr.GetSkillInfoByUID(nUID)
  if type(nUID) == "string" then
    nUID = tonumber(nUID)
  end
  local PlayerSkillInfo = ServerPlayerDataMgr.GetSkillInfos(nUID)
  log_tree("ServerPlayerDataMgr.GetSkillInfoByUID before", PlayerSkillInfo)
  if PlayerSkillInfo.ExtraInfo ~= nil then
    for skillID, info in pairs(PlayerSkillInfo.BaseInfo) do
      PlayerSkillInfo.BaseInfo[skillID].SkillInfoCnt = nil
    end
    for skillID, info in pairs(PlayerSkillInfo.ExtraInfo) do
      for time, value in pairs(PlayerSkillInfo.ExtraInfo[skillID]) do
        if value ~= nil and type(PlayerSkillInfo.ExtraInfo[skillID][time]) == "table" then
          local str = ServerPlayerDataMgr.ExtraInfoToStr(PlayerSkillInfo.ExtraInfo[skillID][time])
          PlayerSkillInfo.ExtraInfo[skillID][time] = {}
          PlayerSkillInfo.ExtraInfo[skillID][time].ExtraInfoStr = str
        end
      end
    end
  end
  local ret = {}
  ret.SkillInfo = PlayerSkillInfo
  local modeExtraInfo = ServerPlayerDataMgr.GetModInfos(nUID)
  if modeExtraInfo ~= nil then
    ret.Mod = modeExtraInfo
  end
  log_tree("ServerPlayerDataMgr.GetSkillInfoByUID after", ret)
  return ret
end
function ServerPlayerDataMgr.GetTime()
  local GameplayStatics = import("GameplayStatics")
  local uGameState = GameplayStatics.GetGameState(CGameMode)
  if nil ~= uGameState or uGameState.StartFlyTime ~= nil then
    return GameplayStatics.GetTimeSeconds(CGameWorld) - uGameState.StartFlyTime
  end
  return 0
end
function ServerPlayerDataMgr.OnSyncPlayerInfo(Uid, Info)
  print(bWriteLog and "ServerPlayerDataMgr.OnSyncPlayerInfo uid:" .. Uid)
  SyncPlayerInfos[Uid] = Info
end
function ServerPlayerDataMgr.OnPlayerExit(Uid, Reason)
  print(bWriteLog and "ServerPlayerDataMgr.OnPlayerExit uid:" .. Uid .. " Reason:" .. tostring(Reason))
  SyncPlayerInfos[Uid] = nil
end
function ServerPlayerDataMgr.GetPlayerInfo(Uid)
  return SyncPlayerInfos[Uid]
end
function ServerPlayerDataMgr.GetPlayerInfoRef(Uid)
  return SyncPlayerInfos[Uid]
end
function ServerPlayerDataMgr.GetAllPlayersInfo()
  return SyncPlayerInfos
end
function ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not PlayerTLogDatas[Uid] then
    PlayerTLogDatas[Uid] = {}
  end
  return PlayerTLogDatas[Uid]
end
function ServerPlayerDataMgr.GetPlayerTLogDatasByCharacter(Character)
  local PlayerState = FuncUtil.SafeCallFun(Character, "GetPlayerStateSafety", Character)
  local TableUtil = require("common.table_util")
  local Uid = TableUtil.GetTableValue(PlayerState, "UID")
  if Uid then
    return ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  end
end
function ServerPlayerDataMgr.GetPlayerTLogDatasByPlayerKey(PlayerKey)
  local Character = Game:GetPlayerByPlayerKey(PlayerKey)
  return ServerPlayerDataMgr.GetPlayerTLogDatasByCharacter(Character)
end
function ServerPlayerDataMgr.AddCountTLog(Uid, FieldName)
  if type(Uid) == "string" then
    Uid = tonumber(Uid)
  end
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if TLogData[FieldName] then
    TLogData[FieldName] = TLogData[FieldName] + 1
  else
    TLogData[FieldName] = 1
  end
  print(bWriteLog and "ServerPlayerDataMgr.AddCountTLog", Uid, FieldName, TLogData[FieldName])
end
function ServerPlayerDataMgr.AddValueTLog(Uid, FieldName, nVal)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if type(nVal) ~= "number" then
    return
  end
  if TLogData[FieldName] then
    TLogData[FieldName] = TLogData[FieldName] + nVal
  else
    TLogData[FieldName] = nVal
  end
  print(bWriteLog and "ServerPlayerDataMgr.AddValueTLog", Uid, FieldName, TLogData[FieldName])
end
function ServerPlayerDataMgr.SetValueTLog(Uid, FieldName, nVal)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  TLogData[FieldName] = nVal
  print(bWriteLog and "ServerPlayerDataMgr.SetValueTLog", Uid, FieldName, TLogData[FieldName])
end
function ServerPlayerDataMgr.AddTableElemTLog(Uid, FieldName, Value)
  print(bWriteLog and "ServerPlayerDataMgr.AddTableElemTLog: ", Uid, FieldName, Value)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if TLogData[FieldName] then
    table.insert(TLogData[FieldName], Value)
  else
    TLogData[FieldName] = {Value}
  end
end
function ServerPlayerDataMgr.GetPlayerPassThroughDatas(nUID)
  if not PlayerPassThroughDatas[nUID] then
    PlayerPassThroughDatas[nUID] = {}
  end
  return PlayerPassThroughDatas[nUID]
end
function ServerPlayerDataMgr.GetPlayerPassThroughDatasByCharacter(uCharacter)
  local PlayerState = FuncUtil.SafeCallFun(uCharacter, "GetPlayerStateSafety", uCharacter)
  local TableUtil = require("common.table_util")
  local Uid = TableUtil.GetTableValue(PlayerState, "UID")
  if Uid then
    return ServerPlayerDataMgr.GetPlayerPassThroughDatas(Uid)
  end
end
function ServerPlayerDataMgr.GetPlayerPassThroughDatasByPlayerKey(nPlayerKey)
  local Character = Game:GetPlayerByPlayerKey(nPlayerKey)
  return ServerPlayerDataMgr.GetPlayerPassThroughDatasByCharacter(Character)
end
function ServerPlayerDataMgr.SetValuePassThrough(nUID, sFieldName, nVal)
  local PassThroughDatas = ServerPlayerDataMgr.GetPlayerPassThroughDatas(nUID)
  PassThroughDatas[sFieldName] = nVal
  print(bWriteLog and "ServerPlayerDataMgr.SetValuePassThrough", nUID, sFieldName, PassThroughDatas[sFieldName])
end
function ServerPlayerDataMgr.GetValuePassThrough(nUID, sFieldName)
  local PassThroughDatas = ServerPlayerDataMgr.GetPlayerPassThroughDatas(nUID)
  return PassThroughDatas[sFieldName]
end
function ServerPlayerDataMgr:AddSkillTriggerTLog(Uid, SkillID)
  printf("ServerPlayerDataMgr:OnTriggerSkill uid:%d SkillID:%d", Uid, SkillID)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  local SkillTLog = TLogData.TriggerSkillCount
  if not SkillTLog then
    SkillTLog = {}
    TLogData.TriggerSkillCount = SkillTLog
  end
  if not SkillTLog[SkillID] then
    SkillTLog[SkillID] = 1
  else
    SkillTLog[SkillID] = SkillTLog[SkillID] + 1
  end
  printf("ServerPlayerDataMgr:AddSkillTriggerTLog %s", dump(TLogData))
end
function ServerPlayerDataMgr.AddSkillTriggerSuccessTLog(Uid, SkillID)
  printf("ServerPlayerDataMgr:AddSkillTriggerSuccessTLog uid:%d SkillID:%d", Uid, SkillID)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.TriggerSkillSuccessCount then
    TLogData.TriggerSkillSuccessCount = {}
  end
  local SkillTLog = TLogData.TriggerSkillSuccessCount
  if not SkillTLog[SkillID] then
    SkillTLog[SkillID] = 1
  else
    SkillTLog[SkillID] = SkillTLog[SkillID] + 1
  end
  log_tree("ServerPlayerDataMgr:AddSkillTriggerSuccessTLog", TLogData)
end
function ServerPlayerDataMgr.SetStoreBuyItemTLog(UID, ItemIDs, ItemNums, PositionString, StoreID)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(UID)
  if not TLogData.PlayerBuyStat then
    TLogData.PlayerBuyStat = {}
  end
  local BuyTime = GamePlayTools.GetServerWorldTimeSeconds()
  local PlayerBuyStatTLog = TLogData.PlayerBuyStat
  local ItemString = ""
  for Index, ItemID in pairs(ItemIDs) do
    ItemString = ItemString .. ItemID .. "+" .. ItemNums[Index] .. ","
  end
  local LogString = "id:" .. ItemString .. "-time:" .. BuyTime .. "-pos:" .. PositionString .. "-sid:" .. StoreID
  table.insert(PlayerBuyStatTLog, LogString)
  log_tree("ServerPlayerDataMgr.SetStoreBuyItemTLog PlayerBuyStatTLog", PlayerBuyStatTLog)
end
function ServerPlayerDataMgr.SetStoreUsedTLog(UID, StartTime, PositionString, CloseStoreReason, Items, Coins, Cost, StoreInCircle, StoreID)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(UID)
  if not TLogData.PlayerStoreStat then
    TLogData.PlayerStoreStat = {}
  end
  local EndTime = GamePlayTools.GetServerWorldTimeSeconds()
  local PlayerStoreTLog = TLogData.PlayerStoreStat
  local CurrentStoeTlog = {
    StartTime = StartTime,
    EndTime = EndTime,
    CloseStoreReason = CloseStoreReason,
    Pos = PositionString,
    Items = Items,
    Coins = Coins,
    Cost = Cost,
    StoreInCircle = StoreInCircle,
    UseTimes = #PlayerStoreTLog + 1,
      }
  table.insert(PlayerStoreTLog, CurrentStoeTlog)
  log_tree("ServerPlayerDataMgr.SetStoreUsedTLog PlayerStoreStat", PlayerStoreTLog)
end
function ServerPlayerDataMgr.SetSkillChooseFlow(UID, BringInRoleID, FinalRoleID)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(UID)
  if not TLogData.PlayerSkillChooseFlow then
    TLogData.PlayerSkillChooseFlow = {}
  end
  local PlayerSkillChooseFlow = TLogData.PlayerSkillChooseFlow
  PlayerSkillChooseFlow = {BringInRoleID = BringInRoleID, FinalRoleID = FinalRoleID}
  TLogData.  log_tree("ServerPlayerDataMgr.SetSkillChooseFlow PlayerSkillChooseFlow", PlayerSkillChooseFlow)
end
function ServerPlayerDataMgr.SetLastHealthTLog(Uid, Health)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.TriggerSkillCount then
    TLogData.LastHealth = 0
  end
  TLogData.Lastend
function ServerPlayerDataMgr.AddVehicleSpeedKills(Uid, KillNum)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.VehicleSpeedKills then
    TLogData.VehicleSpeedKills = 0
  end
  TLogData.VehicleSpeedKills = TLogData.VehicleSpeedKills + KillNum
end
function ServerPlayerDataMgr.SetLastState(Uid, State)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.LastState then
    TLogData.LastState = 0
  end
  TLogData.Lastend
function ServerPlayerDataMgr.AddHurtByPlayers(Uid, HurtNum)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.HurtByPlayersNum then
    TLogData.HurtByPlayersNum = 0
  end
  TLogData.HurtByPlayersNum = TLogData.HurtByPlayersNum + HurtNum
end
function ServerPlayerDataMgr.SetOneGrenadeKillMaxNum(Uid, KillNum)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.GrenadeKillMaxNum then
    TLogData.GrenadeKillMaxNum = 0
  end
  if KillNum > TLogData.GrenadeKillMaxNum then
    TLogData.GrenadeKillMaxNum = KillNum
  end
end
function ServerPlayerDataMgr.AddLandTimeKills(Uid, KillNum)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.LandTimeKills then
    TLogData.LandTimeKills = 0
  end
  TLogData.LandTimeKills = TLogData.LandTimeKills + KillNum
end
function ServerPlayerDataMgr.SetLastCircleNum(Uid, Num)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.LastCircleNum then
    TLogData.LastCircleNum = 0
  end
  if Num > TLogData.LastCircleNum then
    TLogData.LastCircle  end
end
function ServerPlayerDataMgr.AddKillFourNumsTeam(Uid, Num)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.KillFourNumsTeam then
    TLogData.KillFourNumsTeam = 0
  end
  TLogData.KillFourNumsTeam = TLogData.KillFourNumsTeam + Num
end
function ServerPlayerDataMgr.OnPawnNearDeath(_, __, uPawn)
  if Game:IsValid(uPawn) then
    local nUID = Game:GetPlayerUID(uPawn)
    if uPawn:HasState(UEnums.EPawnState.InParachute) then
      local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(nUID)
      TLogData.DownInParachute = true
    end
  end
end
ServerPlayerDataMgr.DamageToEnemiesRecord = {}
function ServerPlayerDataMgr.OnTakeDamage(_, __, uDamageInfo)
  if Game:IsValid(uDamageInfo) then
    local uCaster = uDamageInfo.Caster
    local uTarget = uDamageInfo.Target
    local nDamage = uDamageInfo.Damage
    if 0 < nDamage and Game:IsValid(uCaster) and Game:IsValid(uTarget) and Game:IsHuman(uCaster) and Game:IsHuman(uTarget) and Game:GetTeamID(uCaster) ~= Game:GetTeamID(uTarget) then
      local nCasterUID = Game:GetPlayerUID(uCaster)
      local nTargetUID = Game:GetPlayerUID(uTarget)
      if nCasterUID and nTargetUID then
        ServerPlayerDataMgr.DamageToEnemiesRecord[nCasterUID] = ServerPlayerDataMgr.DamageToEnemiesRecord[nCasterUID] or {}
        local tCasterRecord = ServerPlayerDataMgr.DamageToEnemiesRecord[nCasterUID]
        tCasterRecord[nTargetUID] = true
      end
    end
  end
end
function ServerPlayerDataMgr.RefreshDamageToPlayerCount(nUID)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(nUID)
  local nCount = 0
  local uGameStatisComp = CGame:GetGameStatisComponent()
  if uGameStatisComp ~= nil then
    nCount = uGameStatisComp:GetTLogDamageToPlayerCount(nUID)
  end
  TLogData.DamageToPlayerCount = nCount
end
function ServerPlayerDataMgr.RefreshDamageWithWeapon(nUID)
  print(bWriteLog and "ServerPlayerDataMgr.RefreshDamageWithWeapon..", nUID)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(nUID)
  TLogData.HurtFlow = {}
  local WeaponIdTable = {101101}
  local TotalWeaponReport = GameplayCallbacks.GetWeaponReport()
  local TotalPlayerWeaponRecord = TotalWeaponReport.TotalWeaponRecord or {}
  for _, PlayerWeaponRecord in pairs(TotalPlayerWeaponRecord) do
    if PlayerWeaponRecord.PlayerId == tostring(nUID) then
      local WeaponsReport = PlayerWeaponRecord.Weapons or {}
      for _, WeaponReport in pairs(WeaponsReport) do
        local TableUtil = require("common.table_util")
        if TableUtil.Find(WeaponIdTable, WeaponReport.WeaponId) ~= -1 then
          TLogData.HurtFlow[WeaponReport.WeaponId] = WeaponReport.TotalDamage
          print(bWriteLog and "ServerPlayerDataMgr.RefreshDamageWithWeapon.id:." .. tostring(WeaponReport.WeaponId) .. ", damage: " .. tostring(WeaponReport.TotalDamage))
        end
      end
    end
  end
end
function ServerPlayerDataMgr.RefreshBackpackAttachmentCount(nUID)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(nUID)
  local uPlayerController = Game:GetPlayerControllerByUID(nUID)
  if not Game:IsValid(uPlayerController) then
    return
  end
  local uBackpackComponent = uPlayerController.BackpackComponent
  if not Game:IsValid(uBackpackComponent) then
    return
  end
  local nCount = 0
  local UBackpackUtils_C = import("BackpackUtils")
  local EItemStoreArea = import("EItemStoreArea")
  local uAllItems = UBackpackUtils_C.GetAllItemsInBackpack(uBackpackComponent, false, EItemStoreArea.InBag)
  for nIndex, uBattleItemData in pairs(uAllItems) do
    local uDefineID = uBattleItemData.DefineID
    if not uBattleItemData.bEquipping and uDefineID.Type == 2 then
      nCount = nCount + 1
    end
  end
  TLogData.BackpackAttachmentCount = nCount
end
function ServerPlayerDataMgr.GetServerWorldTimeSeconds()
  local ServerTime = CGameState:GetServerWorldTimeSeconds() or 0
  return math.floor(ServerTime)
end
function ServerPlayerDataMgr.GetPlayerAreaByPlayerKey(PlayerKey)
  local Character = Game:GetPlayerByPlayerKey(PlayerKey)
  return ServerPlayerDataMgr.GetPlayerArea(Character)
end
function ServerPlayerDataMgr.GetPlayerArea(Character)
  if not Game:IsValid(Character) then
    return
  end
  local CurPawnLoc = Game:GetActorLocation(Character)
  local AreaX = math.floor(CurPawnLoc.X / 100000) + string.byte("A")
  local AreaY = math.floor(CurPawnLoc.Y / 100000) + 1
  local Area = string.char(AreaX) .. AreaY
  return Area
end
function ServerPlayerDataMgr.AddWeaponReloadData(Character, WeaponId, BulletNum)
  if not (Character and WeaponId) or not BulletNum then
    return
  end
  local Time = ServerPlayerDataMgr.GetServerWorldTimeSeconds()
  local PlayerArea = ServerPlayerDataMgr.GetPlayerArea(Character)
  local TLogDataKey = "WeaponReloadData"
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatasByCharacter(Character) or {}
  TLogData[TLogDataKey] = TLogData[TLogDataKey] or {}
  table.insert(TLogData[TLogDataKey], {
    WeaponId = WeaponId,
    BulletNum = BulletNum,
    ServerTime = Time,
    Area = PlayerArea
  })
end
function ServerPlayerDataMgr.AddPickUpItemFromDeadBox(PlayerKey, ItemId)
  if not PlayerKey or not ItemId then
    return
  end
  local Time = ServerPlayerDataMgr.GetServerWorldTimeSeconds()
  local PlayerArea = ServerPlayerDataMgr.GetPlayerAreaByPlayerKey(PlayerKey)
  local TLogDataKey = "PickUpBoxItem"
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatasByPlayerKey(PlayerKey) or {}
  TLogData[TLogDataKey] = TLogData[TLogDataKey] or {}
  table.insert(TLogData[TLogDataKey], {
    ItemId = ItemId,
    ServerTime = Time,
    Area = PlayerArea
  })
end
function ServerPlayerDataMgr.AddPickUpItemFromDiscarded(PlayerKey, ItemId)
  if not PlayerKey or not ItemId then
    return
  end
  local Time = ServerPlayerDataMgr.GetServerWorldTimeSeconds()
  local PlayerArea = ServerPlayerDataMgr.GetPlayerAreaByPlayerKey(PlayerKey)
  local TLogDataKey = "PickUpDiscardedItem"
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatasByPlayerKey(PlayerKey) or {}
  TLogData[TLogDataKey] = TLogData[TLogDataKey] or {}
  table.insert(TLogData[TLogDataKey], {
    ItemId = ItemId,
    ServerTime = Time,
    Area = PlayerArea
  })
end
function ServerPlayerDataMgr.AddPickUpItemFromWorldCreate(PlayerKey, ItemId, WorldCreateType)
  if not (PlayerKey and ItemId) or not WorldCreateType then
    return
  end
  local Time = ServerPlayerDataMgr.GetServerWorldTimeSeconds()
  local PlayerArea = ServerPlayerDataMgr.GetPlayerAreaByPlayerKey(PlayerKey)
  local TLogDataKey = "PickUpWorldItem"
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatasByPlayerKey(PlayerKey) or {}
  TLogData[TLogDataKey] = TLogData[TLogDataKey] or {}
  table.insert(TLogData[TLogDataKey], {
    ItemId = ItemId,
    Type = WorldCreateType,
    ServerTime = Time,
    Area = PlayerArea
  })
end
function ServerPlayerDataMgr.RefreshWeaponKillCounterData(nUID)
  local TLogDataKey = "WeaponKillCounterData"
  print(bWriteLog and "ServerPlayerDataMgr.RefreshWeaponKillCounterData" .. tostring(nUID))
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(nUID)
  TLogData[TLogDataKey] = {}
  if not nUID then
    print(bWriteLog and "ServerPlayerDataMgr.RefreshWeaponKillCounterData nUID is nil")
    return
  end
  local uPlayerController = Game:GetPlayerControllerByUID(nUID)
  if not slua.isValid(uPlayerController) or not uPlayerController.PlayerKey then
    print(bWriteLog and "ServerPlayerDataMgr.RefreshWeaponKillCounterData uPlayerController is nil")
    return
  end
  local PlayerKey = uPlayerController.PlayerKey
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local WeaponKillCounterEquip = ServerPlayerDataMgr.GetPlayerProgressFromServer(tonumber(nUID), ExtendAttribute.WeaponKillCounterEquip)
  if not WeaponKillCounterEquip or not next(WeaponKillCounterEquip) then
    print(bWriteLog and "ServerPlayerDataMgr.RefreshWeaponKillCounterData WeaponKillCounterEquip is empty")
    return
  end
  local OnePlayerWeaponData
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  if WeaponRecordSubSystem then
    OnePlayerWeaponData = WeaponRecordSubSystem:InitWeaponReportByWeaponRecord(PlayerKey, nUID)
  end
  if not OnePlayerWeaponData or not OnePlayerWeaponData.Weapons then
    print(bWriteLog and "ServerPlayerDataMgr.RefreshWeaponKillCounterData OnePlayerWeaponData is nil")
    return
  end
  local UAvatarUtils = import("AvatarUtils")
  local weaponKillCountMap = {}
  for _, weaponRecord in pairs(OnePlayerWeaponData.Weapons) do
    local weaponID
    if weaponRecord.WeaponId then
      weaponID = UAvatarUtils.GetAdjustWeaponID(weaponRecord.WeaponId)
    end
    if weaponID and WeaponKillCounterEquip[weaponID] and weaponRecord.KillCount and weaponRecord.KillCount > 0 then
      weaponKillCountMap[weaponID] = weaponKillCountMap[weaponID] or 0
      weaponKillCountMap[weaponID] = weaponKillCountMap[weaponID] + weaponRecord.KillCount
    end
  end
  for weaponID, killCount in pairs(weaponKillCountMap) do
    print(bWriteLog and "ServerPlayerDataMgr.RefreshWeaponKillCounterData.id:" .. tostring(weaponID) .. ", KillCount: " .. tostring(killCount))
    table.insert(TLogData[TLogDataKey], {WeaponId = weaponID, KillCount = killCount})
  end
end
local TlogPawnState = {
  Normal = 0,
  Dying = 1,
  Dead = 2
}
function ServerPlayerDataMgr.BattleResultDataRefresh(nUID)
  local uPC = Game:GetPlayerControllerByUID(nUID)
  if not Game:IsValid(uPC) then
    return
  end
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  ServerPlayerDataMgr.RefreshDamageToPlayerCount(nUID)
  ServerPlayerDataMgr.RefreshBackpackAttachmentCount(nUID)
  ServerPlayerDataMgr.RefreshDamageWithWeapon(nUID)
  ServerPlayerDataMgr.RefreshWeaponKillCounterData(nUID)
  local uPlayerCharacter = uPC:GetPlayerCharacterSafety()
  if Game:IsValid(uPlayerCharacter) then
    ServerPlayerDataMgr.SetLastHealthTLog(nUID, uPlayerCharacter.Health)
    if uPlayerCharacter:HasState(UEnums.EPawnState.Dying) then
      ServerPlayerDataMgr.SetLastState(nUID, TlogPawnState.Dying)
    elseif uPlayerCharacter:HasState(UEnums.EPawnState.Dead) then
      ServerPlayerDataMgr.SetLastState(nUID, TlogPawnState.Dead)
    else
      ServerPlayerDataMgr.SetLastState(nUID, TlogPawnState.Normal)
    end
    if uPlayerCharacter:HasState(UEnums.EPawnState.InParachute) then
      ServerPlayerDataMgr.SetValueTLog(nUID, "DownInParachute", true)
    end
    local PlayerInfo = ServerPlayerDataMgr.GetPlayerInfo(nUID)
    local TeammatePlayerState = CGame:GetTeamMatePlayerStateList(Game:GetPlayerKey(uPlayerCharacter), true)
    if CGameMode.PlayerNumPerTeam > TeammatePlayerState:Num() + 1 and PlayerInfo and PlayerInfo.fill ~= 0 then
      print(bWriteLog and "ServerPlayerDataMgr.SetPlayWithTeammateLostConnect CaseNotEnoughMember : " .. tostring(PlayerInfo.fill))
      ServerPlayerDataMgr.SetValueTLog(nUID, "PlayWithTeammateLostConnect", true)
    end
    local playerState = uPlayerCharacter:GetPlayerStateSafety()
    for _, Teammatestate in pairs(TeammatePlayerState) do
      if slua.isValid(playerState) and slua.isValid(Teammatestate) and playerState.LiveState == ExtraPlayerLiveState.InDied and playerState.isLostConnection then
        ServerPlayerDataMgr.SetValueTLog(Teammatestate.UID, "PlayWithTeammateLostConnect", true)
      end
      if slua.isValid(Teammatestate) and Teammatestate.isLostConnection and Teammatestate.LiveState ~= ExtraPlayerLiveState.InDied then
        print(bWriteLog and "ServerPlayerDataMgr.SetPlayWithTeammateLostConnect CaseTeammate : " .. tostring(Teammatestate.UID))
        ServerPlayerDataMgr.SetValueTLog(nUID, "PlayWithTeammateLostConnect", true)
      end
    end
    if slua.isValid(playerState) and playerState.OvertimeAssistsTime and 0 < playerState.OvertimeAssistsTime:Num() then
      local times = ""
      for index = 0, playerState.OvertimeAssistsTime:Num() - 1 do
        if index == 0 then
          times = playerState.OvertimeAssistsTime:Get(index)
        else
          times = times .. "," .. playerState.OvertimeAssistsTime:Get(index)
        end
      end
      ServerPlayerDataMgr.AddValueTLog(nUID, "OvertimeAssistTime", times)
    end
    ServerPlayerDataMgr.StatisticalKillAndDamageData(nUID, playerState, uPlayerCharacter.DamageRecords)
  else
    ServerPlayerDataMgr.SetLastHealthTLog(nUID, 0)
    ServerPlayerDataMgr.SetLastState(nUID, TlogPawnState.Dead)
  end
  ServerPlayerDataMgr.StatisticalPlayerAvgPingValue(nUID)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(nUID)
  TLogData.DownInParachute = TLogData.DownInParachute or false
  if CGameState then
    if Game:IsValid(uPlayerCharacter) and uPlayerCharacter:HasState(UEnums.EPawnState.Dead) then
      local nRecordNum = uPlayerCharacter.DamageRecords:Num()
      print(bWriteLog and "ServerPlayerDataMgr.BattleResultDataRefresh nRecordNum", nRecordNum)
      if 0 < nRecordNum then
        local LastRecord = uPlayerCharacter.DamageRecords:Get(nRecordNum - 1)
        print(bWriteLog and "ServerPlayerDataMgr.BattleResultDataRefresh DamageType", LastRecord.DamageType)
        if LastRecord.DamageType == UEnums.DamageType.PoisonDamage then
          ServerPlayerDataMgr.SetLastCircleNum(nUID, CGameState:GetCurCircleIndex())
        end
      end
    end
    local PlayerState = CGameState:GetPlayerStateByUID(nUID)
    print(bWriteLog and "ServerPlayerDataMgr.BattleResultDataRefresh", nUID, PlayerState)
    if slua.isValid(PlayerState) and PlayerState.GeneralCounterMap then
      local LowFPSCnt = PlayerState.GeneralCounterMap:Get(19999)
      print(bWriteLog and "ServerPlayerDataMgr.BattleResultDataRefresh LowFPSCnt", nUID, LowFPSCnt)
      TLogData.LowFPSCnt = LowFPSCnt or nil
    end
  else
    print(bWriteLog and "ServerPlayerDataMgr.BattleResultDataRefresh CGameState is nil!")
  end
end
function ServerPlayerDataMgr.AddMedicineThrowInfoTLog(Uid, MedicineID, _)
  if type(Uid) == "string" then
    Uid = tonumber(Uid)
  end
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(Uid)
  if not TLogData.MedicineThrowInfo then
    TLogData.MedicineThrowInfo = {}
  end
  local MedicineThrowInfoTLog = TLogData.MedicineThrowInfo
  if not MedicineThrowInfoTLog[MedicineID] then
    MedicineThrowInfoTLog[MedicineID] = 1
  else
    MedicineThrowInfoTLog[MedicineID] = MedicineThrowInfoTLog[MedicineID] + 1
  end
  print(bWriteLog and "ServerPlayerDataMgr.AddMedicineThrowInfoTLog " .. tostring(Uid) .. " MedicineThrowInfo: " .. MedicineID .. ":" .. MedicineThrowInfoTLog[MedicineID])
end
function ServerPlayerDataMgr.StatisticalPlayerAvgPingValue(Uid)
  if not slua_DSHUD or not slua.isValid(slua_DSHUD) then
    return
  end
  local AvgPingValue = slua_DSHUD:GetUtils():GetPlayerAvgPingValue(Uid) or 0.0
  ServerPlayerDataMgr.SetValueTLog(Uid, "PlayerAvgPing", AvgPingValue)
  print(bWriteLog and "ServerPlayerDataMgr.StatisticalPlayerAvgPingValue:" .. tostring(AvgPingValue))
end
function ServerPlayerDataMgr.StatisticalKillAndDamageData(Uid, State, DamageReport)
  local totalDamage = 0
  local isReported = false
  for _, DamageRecord in pairs(DamageReport) do
    totalDamage = totalDamage + DamageRecord.Damage
    if DamageRecord.DamageType ~= -1 and not isReported then
      local KillerState
      if slua.isValid(DamageRecord.Causer) and slua.isValid(DamageRecord.Causer.PlayerState) then
        KillerState = DamageRecord.Causer.PlayerState
      end
      if slua.isValid(KillerState) and slua.isValid(State) then
        if KillerState.PlayerID == State.PlayerID and DamageRecord.DamageType == UEnums.DamageType.GrenadeRadiusDamage then
          ServerPlayerDataMgr.SetValueTLog(Uid, "KillSelfByGrenade", true)
          isReported = true
        end
      elseif DamageRecord.DamageType == UEnums.DamageType.AirAttackDamage then
        ServerPlayerDataMgr.SetValueTLog(Uid, "KilledByAirAttack", true)
        isReported = true
      end
    end
  end
  ServerPlayerDataMgr.AddValueTLog(Uid, "TotalTakeDamage", totalDamage)
end
function ServerPlayerDataMgr.SetPlayerInGameItems(nUID, tItemList)
  print(bWriteLog and "[YY-D] ServerPlayerDataMgr.SetPlayerInGameItems")
  if not tItemList then
    print(bWriteLog and "[YY-E] ServerPlayerDataMgr.SetPlayerInGameItems tItemList is nil")
    return
  end
  local InGameItems
  if not tPlayerInGameItems[nUID] then
    tPlayerInGameItems[nUID] = {}
  end
  if ServerDataMgr then
    InGameItems = ServerDataMgr:GetInGameItems()
  end
  if InGameItems then
    ServerPlayerDataMgr.AddPlayerInGameItems(nUID, InGameItems)
  end
  ServerPlayerDataMgr.AddPlayerInGameItems(nUID, tItemList)
end
function ServerPlayerDataMgr.AddPlayerInGameItems(nUID, tItemList)
  log_tree("[YY-D] ServerDataMgr:AddPlayerInGameItems tItemList:", tItemList)
  if not nUID then
    return print(bWriteLog and "[YY-E]ServerPlayerDataMgr.AddPlayerInGameItems UID is nil")
  end
  if not tPlayerInGameItems[nUID] then
    tPlayerInGameItems[nUID] = {}
  end
  log_tree("[YY-D] ServerDataMgr:AddPlayerInGameItems tPlayerInGameItems:", tPlayerInGameItems[nUID])
  for _, tItem in pairs(tItemList or {}) do
    if tItem.BornItemFlags and type(tItem.BornItemFlags) == "number" then
      if not tPlayerInGameItems[nUID][tItem.BornItemFlags] then
        tPlayerInGameItems[nUID][tItem.BornItemFlags] = {}
      end
      table.insert(tPlayerInGameItems[nUID][tItem.BornItemFlags], tItem)
    end
  end
end
function ServerPlayerDataMgr.ReplacePlayerIngameItems(nUID, tItemList)
  log_tree("[YY-D] ServerDataMgr:ReplacePlayerIngameItems tItemList:", tItemList)
  if not nUID then
    print(bWriteLog and "[YY-E]ServerPlayerDataMgr.ReplacePlayerIngameItems UID is nil")
    return
  end
  if not tPlayerInGameItems[nUID] then
    tPlayerInGameItems[nUID] = {}
  end
  log_tree("[YY-D] ServerDataMgr:ReplacePlayerIngameItems before replace:", tPlayerInGameItems[nUID])
  for _, tItem in pairs(tItemList or {}) do
    if tItem.BornItemFlags and type(tItem.BornItemFlags) == "number" then
      if not tPlayerInGameItems[nUID][tItem.BornItemFlags] then
        tPlayerInGameItems[nUID][tItem.BornItemFlags] = {}
      end
      local bReplaced = false
      for index, existedItem in ipairs(tPlayerInGameItems[nUID][tItem.BornItemFlags]) do
        if existedItem.BornItemID == tItem.BornItemID then
          bReplaced = true
          tPlayerInGameItems[nUID][tItem.BornItemFlags][index] = tItem
          break
        end
      end
      if not bReplaced then
        table.insert(tPlayerInGameItems[nUID][tItem.BornItemFlags], tItem)
      end
    end
  end
end
function ServerPlayerDataMgr.GetPlayerInGameItemsByTag(nUID, nTag)
  if not nUID then
    return print(bWriteLog and "[YY-E]ServerPlayerDataMgr.GetPlayerInGameItemsByTag UID is nil")
  end
  print(bWriteLog and "[YY-D] ServerPlayerDataMgr.GetPlayerInGameItemsByTag nUID = " .. nUID .. " Tag" .. nTag)
  if tPlayerInGameItems[nUID] then
    return tPlayerInGameItems[nUID][nTag]
  end
  return {}
end
function ServerPlayerDataMgr.GetPlayerBornItem(nUID)
  local tBornItems = {}
  if nUID and tPlayerInGameItems[nUID] then
    print(bWriteLog and "[YY-D] ServerPlayerDataMgr.GetPlayerBornItem nUID = " .. nUID)
    for _, tItem in pairs(tPlayerInGameItems[nUID][0] or {}) do
      table.insert(tBornItems, tItem)
    end
    for _, tItem in pairs(tPlayerInGameItems[nUID][1] or {}) do
      table.insert(tBornItems, tItem)
    end
  end
  log_tree("[YY-D] ServerPlayerDataMgr:GetPlayerBornItem tBornItems:", tBornItems)
  return tBornItems
end
function ServerPlayerDataMgr.GetPlayerInBattleItem(nUID)
  local tBornItems = {}
  if nUID and tPlayerInGameItems[nUID] then
    print(bWriteLog and "[YY-D] ServerPlayerDataMgr.GetPlayerInBattleItem nUID = " .. nUID)
    for _, tItem in pairs(tPlayerInGameItems[nUID][1] or {}) do
      table.insert(tBornItems, tItem)
    end
    for _, tItem in pairs(tPlayerInGameItems[nUID][2] or {}) do
      table.insert(tBornItems, tItem)
    end
  end
  log_tree("[YY-D] ServerPlayerDataMgr:GetPlayerInBattleItem tBornItems:", tBornItems)
  return tBornItems
end
function ServerPlayerDataMgr.GetInitInGameItems(nUID)
  print(bWriteLog and "[YY-D] ServerPlayerDataMgr.GetInitInGameItems nUID = " .. nUID)
  local tItemList = ServerPlayerDataMgr.GetPlayerInGameItemsByTag(nUID, 3)
  local tInitItems = {}
  if tItemList then
    for _, Item in pairs(tItemList) do
      if Item.BornItemID and Item.BornItemCount then
        if not tInitItems[Item.BornItemID] then
          tInitItems[Item.BornItemID] = {}
        end
        tInitItems[Item.BornItemID].Count = Item.BornItemCount
      end
    end
  end
  log_tree("[YY-D] ServerDataMgr:GetPlayerBornItem GetInitInGameItems:", tInitItems)
  return tInitItems
end
function ServerPlayerDataMgr.ClearInGameItems(nUID)
  if nUID and tPlayerInGameItems[nUID] then
    print(bWriteLog and "[YY-D] ServerPlayerDataMgr.ClearInGameItems UID = " .. nUID)
    tPlayerInGameItems[nUID] = {}
  end
end
function ServerPlayerDataMgr.GetPlayerProgressFromServer(nUID, nTypeID)
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  if nTypeID == ExtendAttribute.GeneralCounter then
    return ServerPlayerDataMgr.GetPlayerHistoryGeneralCount(nUID, nTypeID)
  else
    return ServerPlayerDataMgr.GetPlayerExtendAttribute(nUID, nTypeID)
  end
end
function ServerPlayerDataMgr.GetPlayerHistoryGeneralCount(nUID, nTypeID)
  if false then
    local TestData = {
      [410] = 1,
      [411] = 2,
      [412] = 3
    }
    return TestData
  end
  if nUID and nTypeID then
    local tPlayerInfo = SyncPlayerInfos[nUID]
    if tPlayerInfo then
      if tPlayerInfo.ext_attr and tPlayerInfo.ext_attr[nTypeID] then
        return tPlayerInfo.ext_attr[nTypeID]
      else
        print(bWriteLog and "ServerPlayerDataMgr.GetPlayerHistoryGeneralCount, tPlayerInfo.ext_attr = " .. tostring(tPlayerInfo.ext_attr) .. " when nTypeID = " .. tostring(nTypeID))
      end
    else
      print(bWriteLog and "ServerPlayerDataMgr.GetPlayerHistoryGeneralCount, tPlayerInfo = nil when nUID = " .. tostring(nUID))
    end
  else
    print(bWriteLog and "ServerPlayerDataMgr.GetPlayerHistoryGeneralCount, nUID = " .. tostring(nUID) .. ", nTypeID = " .. tostring(nTypeID))
  end
  return nil
end
function ServerPlayerDataMgr.GetPlayerExtendAttribute(nUID, nTypeID)
  if nUID and nTypeID then
    local tPlayerInfo = SyncPlayerInfos[nUID]
    print(bWriteLog and "[YY-D] ServerPlayerDataMgr.GetPlayerExtendAttribute UID = " .. nUID .. " TypeID = " .. nTypeID)
    if tPlayerInfo and tPlayerInfo.ext_attr and tPlayerInfo.ext_attr[nTypeID] then
      return tPlayerInfo.ext_attr[nTypeID]
    else
      print(bWriteLog and "[YY-D] ServerPlayerDataMgr.GetPlayerExtendAttribute ExtendAttribute Not Found")
      return nil
    end
  else
    print(bWriteLog and "[YY-D] ServerPlayerDataMgr.GetPlayerExtendAttribute UID Or TypeID is Nil ")
  end
  return nil
end
function ServerPlayerDataMgr.SetWeaponUpgradeTlog(UID, UpgradeItemID, WeaponID, WeaponLevel)
  local TLogData = ServerPlayerDataMgr.GetPlayerTLogDatas(UID)
  if not TLogData.PlayerWeaponUpgrade then
    TLogData.PlayerWeaponUpgrade = {}
  end
  local UpgradeTime = math.floor(GamePlayTools.GetServerWorldTimeSeconds())
  local PlayerWeaponUpgradeTlog = TLogData.PlayerWeaponUpgrade
  local CurrentWeaponUpgradeTlog = {
    UpgradeItemID = UpgradeItemID,
    WeaponID = WeaponID,
    WeaponLevel = WeaponLevel,
      }
  PlayerWeaponUpgradeTlog[#PlayerWeaponUpgradeTlog + 1] = CurrentWeaponUpgradeTlog
  log_tree("ServerPlayerDataMgr.SetWeaponUpgradeTlog PlayerWeaponUpgrade", PlayerWeaponUpgradeTlog)
end
function ServerPlayerDataMgr.ShortcutBarDatasRefresh(uid, shortcutBarDatas)
  if uid then
    local tPlayerInfo = SyncPlayerInfos[uid]
    if tPlayerInfo and tPlayerInfo.ext_attr then
      local ExtendAttribute = require("Server.config.ExtendAttribute")
      tPlayerInfo.ext_attr[ExtendAttribute.ShortcutBarData] = shortcutBarDatas
    else
      print(bWriteLog and "[YY-D] ServerPlayerDataMgr.ShortcutBarDatasRefresh ExtendAttribute Not Found")
    end
  else
    print(bWriteLog and "[YY-D] ServerPlayerDataMgr.ShortcutBarDatasRefresh uid is Nil ")
  end
end
function ServerPlayerDataMgr:GetPlayerCustomSaveData(UID, Key)
  if not UID then
    return
  end
  local tPlayerInfo = SyncPlayerInfos[UID]
  if not tPlayerInfo then
    return
  end
  local client_custom_data_to_battle = tPlayerInfo.client_custom_data_to_battle
  if not client_custom_data_to_battle then
    return
  end
  return client_custom_data_to_battle[Key]
end
function ServerPlayerDataMgr.HandleAliasInfo(tInfo, container)
  local aliasData = tInfo and tInfo.alias
  if not aliasData then
    log_warning_format("ServerPlayerDataMgr.HandleAliasInfo. aliasData is nil. tInfo = [%s]", tInfo)
    return
  end
  log_tree("ServerPlayerDataMgr.HandleAliasInfo. aliasData = ", aliasData)
  local AliasInfo = {}
  AliasInfo = {}
  AliasInfo.aliasID = aliasData.id
  AliasInfo.aliasTitle = aliasData.title or ""
  AliasInfo.aliasNation = aliasData.nation
  AliasInfo.aliasRank = aliasData.rank
  local registerTime = tInfo.registertime
  if aliasData.ext_info then
    AliasInfo.aliasPartnerName = aliasData.ext_info.partner_name or ""
    AliasInfo.aliasPartnerRelation = aliasData.ext_info.partner_relation or 1
    if aliasData.ext_info.psmatch_team_name then
      AliasInfo.aliasTitle = aliasData.ext_info.psmatch_team_name or ""
    end
    if aliasData.ext_info.registertime then
      registerTime = aliasData.ext_info.registertime
    end
  end
  local aliasCfg = CDataTable.GetTableData("AliasCfg", aliasData.id)
  if aliasCfg and aliasCfg.AliasType == 8 and registerTime then
    local currTime = ServerPlayerDataMgr.GetCurrentTime()
    print(bWriteLog and "ServerPlayerDataMgr.HandleAliasInfo. currTime = " .. tostring(currTime))
    local day = math.floor((currTime - registerTime) / 86400 + 1)
    local year = math.floor(day / 365 + 0.5)
    year = math.max(year, 1)
    AliasInfo.aliasRank = year
  end
  AliasInfo.aliasRankID = aliasData.rank_id or 0
  if aliasCfg and aliasCfg.AliasType == 7 and aliasData.ext_info and aliasData.ext_info.weapon_power_zone_id then
    AliasInfo.aliasRankID = aliasData.ext_info.weapon_power_zone_id
  end
  log_tree("ServerPlayerDataMgr.HandleAliasInfo AliasInfo = ", AliasInfo)
  if container then
    container.  end
  return AliasInfo
end
function ServerPlayerDataMgr.GetCurrentTime()
  if CGameMode and type(CGameMode.ServerStartTime) == "number" and CGameMode.ServerStartTime ~= 0 then
    return CGameMode.ServerStartTime + CGameState:GetServerWorldTimeSeconds()
  end
  return os.time()
end
return ServerPlayerDataMgr