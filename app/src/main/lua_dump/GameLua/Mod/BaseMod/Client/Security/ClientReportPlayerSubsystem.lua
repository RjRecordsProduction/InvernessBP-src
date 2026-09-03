local ClientReportPlayerSubsystem = {}
local EDamageType = import("EDamageType")
local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
local ECharacterHealthStatus = import("ECharacterHealthStatus")
local ReportPlayerUtils = require("GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local StaticShowSecurityAlertInDev = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent").StaticShowSecurityAlertInDev
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local IsBool = SecurityCommonUtils.IsBool
local IsString = SecurityCommonUtils.IsString
local IsNonemptyString = SecurityCommonUtils.IsNonemptyString
local IsNumber = SecurityCommonUtils.IsNumber
local IsTable = SecurityCommonUtils.IsTable
local FormatLog = FuncUtil.FormatLog
local LogIf = SecurityCommonUtils.LogIf
local bIsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
local GetEnumNameByValue = USTExtraBlueprintFunctionLibrary.GetEnumNameByValue
local S_NAME = ReportPlayerUtils.S_NAME
local S_UID = ReportPlayerUtils.S_UID
local B_IS_AI = ReportPlayerUtils.B_IS_AI
local B_IS_MLAI = ReportPlayerUtils.B_IS_MLAI
local S_ORIGINAL_UID = ReportPlayerUtils.S_ORIGINAL_UID
local B_IS_DELIVER = ReportPlayerUtils.B_IS_DELIVER
local N_IN_TEAM_INDEX = ReportPlayerUtils.N_IN_TEAM_INDEX
local S_OPEN_ID = ReportPlayerUtils.S_OPEN_ID
local tSkipAlertDamageTypeMapInDev = {
  [0] = true,
  [EDamageType.FallingDamage] = true,
  [EDamageType.AirAttackDamage] = true,
  [EDamageType.VehicleExplodeRadiusDamage] = true,
  [EDamageType.LastBreathWithoutRescue] = true,
  [EDamageType.PoisonDamage] = true,
  [EDamageType.DrowningDamage] = true,
  [EDamageType.WinnerFakeDeath] = true,
  [EDamageType.TopFiveGaveUpDamage] = true,
  [EDamageType.Resurrection] = true
}
local sAlertInDevVersion = "6"
function ClientReportPlayerSubsystem:OnInit()
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self._OnBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_QUICK_REPORT, EVENTID_QUICK_REPORT_ON_SHOW_MUTUAL_EXCLUSIVE_UI, self._OnShowQuickReportMutualExclusiveUI, self)
  self:AddCommonEvent(EVENTTYPE_QUICK_REPORT, EVENTID_QUICK_REPORT_ON_HIDE_MUTUAL_EXCLUSIVE_UI, self._OnHideQuickReportMutualExclusiveUI, self)
  self:AddCommonEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_SYNC_FATAL_DAMAGE, self._OnSyncFatalDamage, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, self._SyncBattleResult, self)
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
    return
  end
  self:AddControlEvent(uMyController, "OnPlayerKilledOthersPlayer", self._OnPlayerKilledOtherPlayer, self)
  self:AddControlEvent(uMyController, "ClientOnDeathReplayDataWhenFatalDamagedDelegate", self._OnDeathReplayDataWhenFatalDamaged, self)
  self._tKnockDownerMap = {}
  self._tMurdererMap = {}
  self._bIsGameModeTypeTeamDeathMatch = false
  self._nGameModeType = -1
  self._nMainModeID = -1
  self._nSubModeID = -1
  self._tMapCurrentNotInTeamHistoricalTeammate = {}
  self:_StartCheckGameModeTypeTimer()
  self:_StartCheckCurrentNotInTeamHistoricalTeammateTimer()
  self._ds2history = {}
  self._bEnableRecordFatalDamage = true
end
function ClientReportPlayerSubsystem:_OnBattleResult(_, __)
  self:_RecordTeammatePlayerInfo()
end
function ClientReportPlayerSubsystem:_StartCheckGameModeTypeTimer()
  if self._nCheckTDMGameModeTypeTimer then
    return
  end
  self:_CheckGameModeType()
  self._nCheckTDMGameModeTypeTimer = self:AddGameTimer(5, true, function()
    self:_CheckGameModeType()
  end)
end
function ClientReportPlayerSubsystem:_CheckGameModeType()
  local nGameModeType = SecurityCommonUtils.GetGameModeTypeInBattle()
  local nMainModeID = SecurityCommonUtils.GetCurrentBattleMainModeID()
  local nSubModeID = SecurityCommonUtils.GetCurrentBattleSubModeID()
  if nGameModeType <= 0 then
    return
  end
  if nMainModeID <= 0 then
    return
  end
  if nSubModeID <= 0 then
    return
  end
  self._  self._  self._  self._bIsGameModeTypeTeamDeathMatch = SecurityCommonUtils.IsGameModeTypeTDM(nGameModeType)
  if self._nCheckTDMGameModeTypeTimer then
    self:RemoveGameTimer(self._nCheckTDMGameModeTypeTimer)
  end
  self._nCheckTDMGameModeTypeTimer = nil
end
function ClientReportPlayerSubsystem:_OnPlayerKilledOtherPlayer(FatalDamageParameter)
  if type(FatalDamageParameter.victimKey) ~= "number" then
    return
  end
  local nCauserKey = FatalDamageParameter.causerKey
  if type(nCauserKey) ~= "number" then
    return
  end
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uMyController) or uMyController.ClientFatalDamageLastRecords == nil then
    return
  end
  local nMyPlayerKey = uMyController.PlayerKey
  if nMyPlayerKey ~= FatalDamageParameter.victimKey then
    return
  end
  if not uMyController.KillOrPutDownMessageData.bIamVictim then
    return
  end
  if bWriteLog then
    FormatLog("nCauserKey=%s, nVictimKey=%d, nRelationship=%s, nCauserWeaponAvatarID=%s", tostring(nCauserKey), FatalDamageParameter.victimKey, tostring(FatalDamageParameter.Relationship), tostring(FatalDamageParameter.causerWeaponAvatarID))
  end
  self:_RecordTeammatePlayerInfo()
  if FatalDamageParameter.victimKey == nCauserKey then
    return
  end
  local uLastFatalDamageRecord = uMyController.ClientFatalDamageLastRecords
  local sCauserName = uLastFatalDamageRecord.Causer
  local nDamageType = uLastFatalDamageRecord.DamageType
  local nCauserCharacterType = uLastFatalDamageRecord.CauserType
  local bIsAlertInDev = bIsDevelopment
  if tSkipAlertDamageTypeMapInDev[nDamageType] then
    bIsAlertInDev = false
  elseif ReportPlayerUtils.tSkipAlertFatalDamageCharacterTypeMapInDev[nCauserCharacterType] then
    bIsAlertInDev = false
  elseif nCauserKey <= 0 then
    bIsAlertInDev = false
  end
  if sCauserName == "" and bIsAlertInDev then
    StaticShowSecurityAlertInDev(slua_GameFrontendHUD:GetPlayerController(), string.format([[
empty knock/killer name
ClientReportPlayerSubsystem:_OnPlayerKilledOtherPlayer
version=%s, DamageType=%s
CauserCharacterType=%s]], sAlertInDevVersion, nDamageType, GetEnumNameByValue("EFatalDamageCharacterType", nCauserCharacterType, false)), true)
    bIsAlertInDev = false
  end
  local uCauserCharacter = CGame:GetPlayerByNameIterateAllPawns(sCauserName)
  if not Game:IsHuman(uCauserCharacter) then
    return
  end
  local bIsCauserMLAI = uCauserCharacter.bMEnsure
  local sCauserUID = uCauserCharacter.PlayerUID
  local sOriginalUID = uCauserCharacter.PlayerUID
  local bIsCauserAI = uCauserCharacter.bEnsure
  local bIsCausedByDevliver = false
  if FatalDamageParameter.isCausedByDevliver then
    bIsCausedByDevliver = FatalDamageParameter.isCausedByDevliver
  end
  local nMyHealthStatus = uLastFatalDamageRecord.ResultHealthStatus
  FormatLog("sCauserName=%s, sCauserUID=%s, bIsCauserAI=%s, nMyHealthStatus=%d, sOriginalUID=%s, bIsCausedByDevliver=%s", sCauserName, sCauserUID, tostring(bIsCauserAI), nMyHealthStatus, sOriginalUID, tostring(bIsCausedByDevliver))
  if nMyHealthStatus == ECharacterHealthStatus.HasLastBreath then
    self:_RecordFatalDamager(true, sCauserName, sCauserUID, bIsCauserAI, bIsCauserMLAI, sOriginalUID, bIsCausedByDevliver)
  elseif self:_IsHealthStatusKilled(nMyHealthStatus) then
    self:_RecordFatalDamager(false, sCauserName, sCauserUID, bIsCauserAI, bIsCauserMLAI, sOriginalUID, bIsCausedByDevliver)
  end
  if bIsAlertInDev then
    local bIsAlertInvalidUID = true
    if bIsCauserAI then
      bIsAlertInvalidUID = false
    end
    if (not tonumber(sCauserUID) or not (0 < tonumber(sCauserUID))) and bIsAlertInvalidUID then
      StaticShowSecurityAlertInDev(slua_GameFrontendHUD:GetPlayerController(), string.format([[
error knock/killer uid
ClientReportPlayerSubsystem:_OnPlayerKilledOtherPlayer
version=%s, name=%s, DamageType=%s]], sAlertInDevVersion, sCauserName, nDamageType), false)
      bIsAlertInDev = false
    end
  end
end
function ClientReportPlayerSubsystem:GetFatalDamagerMap(bIsKnockDown)
  if bIsKnockDown then
    return self._tKnockDownerMap
  end
  return self._tMurdererMap
end
function ClientReportPlayerSubsystem:GetFatalDamagerMapSize(bIsKnockDown)
  local tTable = self._tMurdererMap
  if bIsKnockDown then
    tTable = self._tKnockDownerMap
  end
  local Size = 0
  for k, v in pairs(tTable) do
    Size = Size + 1
  end
  return Size
end
function ClientReportPlayerSubsystem:GetName2InfoMap(bIsKnockDown)
  if not self._ds2history then
    self._ds2history = {}
  end
  if bIsKnockDown then
    return self._ds2history.tKnockDownerMap
  end
  return self._ds2history.tMurdererMap
end
function ClientReportPlayerSubsystem:EnableRecordFatalDamage(bEnable)
  self._bEnableRecordFatalDamage = bEnable
  FormatLog("_bEnableRecordFatalDamage=%s", self._bEnableRecordFatalDamage)
end
function ClientReportPlayerSubsystem:_RecordFatalDamager(bIsKnockDown, sName, sUID, bIsAI, bIsMLAI, sOriginalUID, bIsDeliver)
  FormatLog("bIsKnockDown=%s", bIsKnockDown)
  local tMap = self:GetFatalDamagerMap(bIsKnockDown)
  ReportPlayerUtils.RecordFatalDamager(tMap, sName, sUID, bIsAI, bIsMLAI, sOriginalUID, bIsDeliver)
end
function ClientReportPlayerSubsystem:_RecordTeammatePlayerInfo()
  if self._tTeammateName2InfoMap and bWriteLog then
    FormatLog("teammate info has already been recorded")
    return
  end
  self._tTeammateName2InfoMap = self:GetTeammateName2InfoMapDuringBattle(false)
end
function ClientReportPlayerSubsystem:GetCachedTeammateName2InfoMap(bIsExcludeMyself)
  if not self._tTeammateName2InfoMap then
    return nil
  end
  local sMyName = DataMgr.roleData.nickName
  local tResultMap = {}
  for sTeammateName, tTeammateInfo in pairs(self._tTeammateName2InfoMap) do
    if not bIsExcludeMyself or sTeammateName ~= sMyName then
      tResultMap[sTeammateName] = {
        sPlayerUID = tTeammateInfo.sPlayerUID,
        nInTeamIndex = tTeammateInfo.nInTeamIndex,
        bIsPlayerAI = tTeammateInfo.bIsPlayerAI,
        sOpenID = tTeammateInfo.sOpenID
      }
    end
  end
  return tResultMap
end
function ClientReportPlayerSubsystem:_IsHealthStatusKilled(nHealthStatus)
  return nHealthStatus == ECharacterHealthStatus.FinishedLastBreath or nHealthStatus == ECharacterHealthStatus.WaitingForRevival
end
function ClientReportPlayerSubsystem:GetTeammateName2InfoMapDuringBattle(bIsExcludeMyself)
  if type(bIsExcludeMyself) ~= "boolean" then
    return nil
  end
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
    FormatLog("not Game:IsClassOf(uMyController, ASTExtraPlayerController)")
    return nil
  end
  local uMyPlayerState = uMyController.PlayerState
  if not slua.isValid(uMyPlayerState) then
    FormatLog("not slua.isValid(uMyPlayerState)")
    return nil
  end
  FormatLog("MyPlayerState=%s", uMyPlayerState.OpenID)
  local tResultMap = {}
  if uMyPlayerState.IsSinglePlayer and uMyPlayerState:IsSinglePlayer() then
    if not bIsExcludeMyself and uMyPlayerState.PlayerName ~= "" then
      tResultMap[uMyPlayerState.PlayerName] = {
        sPlayerUID = uMyPlayerState:GetUIDString(),
        bIsPlayerAI = uMyPlayerState.bPSEnsure,
        nInTeamIndex = 1,
        sOpenID = uMyPlayerState.OpenID
      }
    end
    return tResultMap
  end
  if ReportPlayerUtils.IsUsingHistoricalTeammateInfo() then
    if uMyPlayerState.HistoricalTeammateInfoArray then
      for _, uHistoricalTeammateInfo in pairs(uMyPlayerState.HistoricalTeammateInfoArray) do
        tResultMap[uHistoricalTeammateInfo.Name] = {
          sPlayerUID = tostring(uHistoricalTeammateInfo.UID),
          bIsPlayerAI = uHistoricalTeammateInfo.bIsAI,
          nInTeamIndex = uHistoricalTeammateInfo.InTeamIndex,
          sOpenID = uHistoricalTeammateInfo.OpenID
        }
      end
    end
    for sTeammateName, tTeammateInfo in pairs(tResultMap) do
      local nInTeamIndex = 0
      if uMyPlayerState.GetTeamMatePlayerStateList then
        for _, uTeammatePlaystate in pairs(uMyPlayerState:GetTeamMatePlayerStateList({}, false)) do
          nInTeamIndex = nInTeamIndex + 1
          if slua.isValid(uTeammatePlaystate) and uTeammatePlaystate.PlayerName == sTeammateName then
            tTeammateInfo.            break
          end
        end
      end
    end
  elseif uMyPlayerState.GetTeamMatePlayerStateList then
    local tTeammatePlayerStateArray = uMyPlayerState:GetTeamMatePlayerStateList({}, false)
    local nInTeamIndex = 0
    for _, tTeammatePlaystate in pairs(tTeammatePlayerStateArray) do
      nInTeamIndex = nInTeamIndex + 1
      if slua.isValid(tTeammatePlaystate) and tTeammatePlaystate.PlayerName ~= "" and (not bIsExcludeMyself or tTeammatePlaystate.PlayerName ~= uMyPlayerState.PlayerName) then
        local sTeammateName = tTeammatePlaystate.PlayerName
        local sTeammateUID = tTeammatePlaystate:GetUIDString()
        local bIsTeammateAI = tTeammatePlaystate.bPSEnsure
        local sOpenID = tTeammatePlaystate.OpenID
        tResultMap[sTeammateName] = {
          sPlayerUID = sTeammateUID,
          bIsPlayerAI = bIsTeammateAI,
          nInTeamIndex = nInTeamIndex,
                  }
      end
    end
  end
  return tResultMap
end
function ClientReportPlayerSubsystem:_OnDeathReplayDataWhenFatalDamaged(...)
  self:_RecordMurdererFromDeathReplayData(...)
end
function ClientReportPlayerSubsystem:_RecordMurdererFromDeathReplayData(bIsDead, bIsValidDeathReplay, bIsSuicide, sPlayerName, sPlayerUID, bIsPlayerAI, eAIType, nDamageType, sMLAIUID)
  if not IsBool(bIsDead) then
    return
  end
  if not IsBool(bIsValidDeathReplay) then
    return
  end
  if not IsBool(bIsSuicide) then
    return
  end
  if not IsString(sPlayerName) then
    return
  end
  if not IsString(sPlayerUID) then
    return
  end
  if not IsBool(bIsPlayerAI) then
    return
  end
  if not IsNumber(nDamageType) then
    return
  end
  if not IsString(sMLAIUID) then
    return
  end
  self:_RecordTeammatePlayerInfo()
  if not bIsValidDeathReplay then
    return
  end
  if bIsSuicide then
    return
  end
  local EAIType = import("EAIType")
  local bIsPlayerMLAI = false
  local bIsDeliver = false
  local sOriginalUID = sPlayerUID
  if eAIType == EAIType.DeliverByBT then
    bIsDeliver = true
    bIsPlayerMLAI = false
  elseif eAIType == EAIType.NormalByBT then
    bIsDeliver = false
    bIsPlayerMLAI = false
  elseif eAIType == EAIType.DeliverByML then
    bIsDeliver = true
    bIsPlayerMLAI = true
  elseif eAIType == EAIType.NormalByML then
    bIsDeliver = false
    bIsPlayerMLAI = true
  end
  if bIsPlayerMLAI then
    bIsPlayerAI = true
    sPlayerUID = sMLAIUID
  end
  FormatLog("sPlayerName=%s, sPlayerUID=%s, bIsPlayerAI=%s, bIsPlayerMLAI=%s, sMLAIUID=%s, sOriginalUID=%s, bIsDeliver=%s", sPlayerName, sPlayerUID, bIsPlayerAI, bIsPlayerMLAI, sMLAIUID, sOriginalUID, bIsDeliver)
  if bIsDead then
    self:_RecordFatalDamager(false, sPlayerName, sPlayerUID, bIsPlayerAI, bIsPlayerMLAI, sOriginalUID, bIsDeliver)
  else
    self:_RecordFatalDamager(true, sPlayerName, sPlayerUID, bIsPlayerAI, bIsPlayerMLAI, sOriginalUID, bIsDeliver)
  end
  local bIsAlertInDev = bIsDevelopment
  if tSkipAlertDamageTypeMapInDev[nDamageType] then
    bIsAlertInDev = false
  end
  if sPlayerName == "" and bIsAlertInDev then
    StaticShowSecurityAlertInDev(slua_GameFrontendHUD:GetPlayerController(), string.format([[
empty knock/killer name
ClientReportPlayerSubsystem:_RecordMurdererFromDeathReplayData
version=%s, DamageType=%s]], sAlertInDevVersion, nDamageType), false)
    bIsAlertInDev = false
  end
  if not tonumber(sPlayerUID) or not (tonumber(sPlayerUID) > 0) then
    FormatLog("invalid uid")
    local bIsAlertInvalidUID = true
    if bIsPlayerAI then
      bIsAlertInvalidUID = false
    end
    if bIsAlertInDev and bIsAlertInvalidUID then
      StaticShowSecurityAlertInDev(slua_GameFrontendHUD:GetPlayerController(), string.format([[
error knock/killer uid
ClientReportPlayerSubsystem:_RecordMurdererFromDeathReplayData
version=%s, name=%s, DamageType=%s]], sAlertInDevVersion, sPlayerName, nDamageType), false)
      bIsAlertInDev = false
    end
  end
end
function ClientReportPlayerSubsystem:IsGameModeTypeTeamDeathMatch()
  return self._bIsGameModeTypeTeamDeathMatch
end
function ClientReportPlayerSubsystem:GetGameModeType()
  return self._nGameModeType
end
function ClientReportPlayerSubsystem:GetMainModeID()
  return self._nMainModeID
end
function ClientReportPlayerSubsystem:GetSubModeID()
  return self._nSubModeID
end
function ClientReportPlayerSubsystem:_StartCheckCurrentNotInTeamHistoricalTeammateTimer()
  if self._nCurrentNotInTeamHistoricalTeammateTimer then
    return
  end
  self:_CheckCurrentNotInTeamHistoricalTeammate()
  self._nCurrentNotInTeamHistoricalTeammateTimer = self:AddGameTimer(5, true, function()
    self:_CheckCurrentNotInTeamHistoricalTeammate()
  end)
end
function ClientReportPlayerSubsystem:_CheckCurrentNotInTeamHistoricalTeammate()
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uMyController) then
    return
  end
  local uMyPlayerState = uMyController.PlayerState
  if not slua.isValid(uMyPlayerState) then
    return
  end
  if not uMyPlayerState.CurrentNotInTeamHistoricalTeammateInfoArray then
    return
  end
  local tNewUIDSet = {}
  for _, uInfo in pairs(uMyPlayerState.CurrentNotInTeamHistoricalTeammateInfoArray) do
    local sUID = tostring(uInfo.OriginalUID)
    tNewUIDSet[sUID] = true
    if not self._tMapCurrentNotInTeamHistoricalTeammate[sUID] then
      local tNewInfo = {}
      self._tMapCurrentNotInTeamHistoricalTeammate[sUID] = tNewInfo
      tNewInfo[S_NAME] = uInfo.Name
      tNewInfo[S_UID] = tostring(uInfo.UID)
      tNewInfo[B_IS_AI] = uInfo.bIsAI
      tNewInfo[B_IS_MLAI] = uInfo.bIsMLAI
      tNewInfo[S_ORIGINAL_UID] = tostring(uInfo.OriginalUID)
      tNewInfo[B_IS_DELIVER] = uInfo.bIsDeliver
      tNewInfo[N_IN_TEAM_INDEX] = uInfo.InTeamIndex
      tNewInfo[S_OPEN_ID] = uInfo.OpenID
      FormatLog("add %s %s", uInfo.Name, uInfo.UID)
    end
  end
  for sUID, tInfo in pairs(self._tMapCurrentNotInTeamHistoricalTeammate) do
    if not tNewUIDSet[sUID] then
      self._tMapCurrentNotInTeamHistoricalTeammate[sUID] = nil
      FormatLog("remove %s %s", tInfo[S_NAME], tInfo[S_UID])
    end
  end
end
function ClientReportPlayerSubsystem:GetCurrentNotInTeamHistoricalTeammateMap()
  return self._tMapCurrentNotInTeamHistoricalTeammate
end
function ClientReportPlayerSubsystem:_OnShowQuickReportMutualExclusiveUI(_, __)
  require("GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate").OnShowMutualExclusiveUI()
end
function ClientReportPlayerSubsystem:_OnHideQuickReportMutualExclusiveUI(_, __)
  require("GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate").OnHideMutualExclusiveUI()
end
function ClientReportPlayerSubsystem:_OnSyncFatalDamage(_, __, FatalDamageArray, bIsKnockDown)
  if not FatalDamageArray then
    return
  end
  for i = 0, FatalDamageArray:Num() - 1 do
    local tInfo = FatalDamageArray:Get(i)
    local tMap = self:GetFatalDamagerMap(bIsKnockDown)
    ReportPlayerUtils.RecordFatalDamagerReconnect(tMap, tInfo.PlayerName, tostring(tInfo.PlayerUID), tInfo.bIsPlayerAI, tInfo.bIsMLAI, tostring(tInfo.OriginUID), tInfo.bIsDeliver, tInfo.OccurTime)
  end
end
function ClientReportPlayerSubsystem:_SyncBattleResult(_, __, tBattleResult)
  if not g_game_id then
    FormatLog("g_game_id nil")
    return
  end
  if not tBattleResult then
    FormatLog("tBattleResult nil")
    return
  end
  if not tBattleResult.ds2history then
    FormatLog("tBattleResult.ds2history nil")
    return
  end
  if not tBattleResult.battle_id then
    FormatLog("tBattleResult.battle_id nil")
    return
  end
  FormatLog("g_game_id=%s battle_id=%s", tostring(g_game_id), tostring(tBattleResult.battle_id))
  if g_game_id ~= tBattleResult.battle_id then
    FormatLog("battle_id not match")
    return
  end
  self._ds2history = DeepCopy(tBattleResult.ds2history)
  FormatLog("Update self._ds2history")
  log_tree(bWriteLog and "_ds2history", self._ds2history)
end
function ClientReportPlayerSubsystem:GetInTeamIndexFromHistoricalTeammateInfo(sName)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uMyPlayerState = GameplayData.GetPlayerState()
  if LogIf(not slua.isValid(uMyPlayerState), "invalid player state") then
    return
  end
  if LogIf(not uMyPlayerState.HistoricalTeammateInfoArray, "invalid HistoricalTeammateInfoArray") then
    return
  end
  for _, uHistoricalTeammateInfo in pairs(uMyPlayerState.HistoricalTeammateInfoArray) do
    FormatLog("%s %s", uHistoricalTeammateInfo.Name, uHistoricalTeammateInfo.InTeamIndex)
    if uHistoricalTeammateInfo.Name == sName then
      return uHistoricalTeammateInfo.InTeamIndex
    end
  end
  return -1
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ClientReportPlayerSubsystem)