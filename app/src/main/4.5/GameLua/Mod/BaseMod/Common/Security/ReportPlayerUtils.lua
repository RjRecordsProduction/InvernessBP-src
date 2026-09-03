local EGameModeType = import("EGameModeType")
local EFatalDamageCharacterType = import("EFatalDamageCharacterType")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local FormatLog = FuncUtil.FormatLog
local IsTable = SecurityCommonUtils.IsTable
local IsNonemptyString = SecurityCommonUtils.IsNonemptyString
local IsBool = SecurityCommonUtils.IsBool
local IsString = SecurityCommonUtils.IsString
local LogIf = SecurityCommonUtils.LogIf
local FindItemInContainerByProperty = SecurityCommonUtils.FindItemInContainerByProperty
local S_NAME = "sPlayerName"
local S_UID = "sPlayerUID"
local B_IS_AI = "bIsPlayerAI"
local B_IS_MLAI = "bIsMLAI"
local S_ORIGINAL_UID = "sOriginalUID"
local B_IS_DELIVER = "bIsDeliver"
local N_OCCUR_TIME = "nOccurTime"
local N_IN_TEAM_INDEX = "nInTeamIndex"
local S_OPEN_ID = "sOpenID"
local B_IS_ESCAPED = "bIsEscaped"
local tHistoricalTeammateInfoEnabledGameModeTypeMap = {
  [EGameModeType.ETypicalGameMode] = true
}
local tHistoricalTeammateInfoEnabledMainModeIDMap = {
  [723] = true,
  [733] = true
}
local tSkipAlertFatalDamageCharacterTypeMapInDev = {
  [EFatalDamageCharacterType.ERobot] = true,
  [EFatalDamageCharacterType.EMonster] = true,
  [EFatalDamageCharacterType.EBoss] = true,
  [EFatalDamageCharacterType.EWalkingDeadAI] = true
}
local tSetSlayBotSubModeID = {
  [32001] = true,
  [32002] = true,
  [32003] = true,
  [32004] = true,
  [32005] = true,
  [32006] = true
}
local ReportPlayerUtils = {
  tSkipAlertFatalDamageCharacterTypeMapInDev = tSkipAlertFatalDamageCharacterTypeMapInDev,
  S_NAME = S_NAME,
  S_UID = S_UID,
  B_IS_AI = B_IS_AI,
  B_IS_MLAI = B_IS_MLAI,
  S_ORIGINAL_UID = S_ORIGINAL_UID,
  B_IS_DELIVER = B_IS_DELIVER,
  N_OCCUR_TIME = N_OCCUR_TIME,
  N_IN_TEAM_INDEX = N_IN_TEAM_INDEX,
  S_OPEN_ID = S_OPEN_ID,
  }
function ReportPlayerUtils.IsUsingHistoricalTeammateInfo()
  local nGameModeType = SecurityCommonUtils.GetGameModeTypeInBattle()
  local nMainModeID = SecurityCommonUtils.GetCurrentBattleMainModeID()
  FormatLog("nGameModeType=%s, nMainModeID=%s", nGameModeType, nMainModeID)
  if tHistoricalTeammateInfoEnabledGameModeTypeMap[nGameModeType] then
    return true
  end
  if tHistoricalTeammateInfoEnabledMainModeIDMap[nMainModeID] then
    return true
  end
  return false
end
function ReportPlayerUtils.RecordFatalDamager(tMap, sName, sUID, bIsAI, bIsMLAI, sOriginalUID, bIsDeliver)
  if LogIf(not IsTable(tMap), "invalid tMap") then
    return
  end
  if LogIf(not IsNonemptyString(sName), "invalid sName") then
    return
  end
  if LogIf(not IsBool(bIsAI), "invalid bIsAI") then
    return
  end
  if LogIf(not IsBool(bIsMLAI), "invalid bIsMLAI") then
    return
  end
  if LogIf(not IsBool(bIsDeliver), "invalid bIsDeliver") then
    return
  end
  if not IsString(sUID) then
    sUID = ""
  end
  if not IsString(sOriginalUID) then
    sOriginalUID = ""
  end
  local nOccurTime = Game:GetCurTimeMilliseconds()
  local tInfo = tMap[sName]
  if tInfo then
    tInfo[N_OCCUR_TIME] = nOccurTime
    local nExistingUID = tonumber(tInfo[S_UID])
    if LogIf(nExistingUID and 0 < nExistingUID, "uid existed, %s", nExistingUID) then
      return
    end
  else
    tInfo = {}
    tMap[sName] = tInfo
  end
  tInfo[S_NAME] = sName
  tInfo[S_UID] = sUID
  tInfo[B_IS_AI] = bIsAI
  tInfo[B_IS_MLAI] = bIsMLAI
  tInfo[S_ORIGINAL_UID] = sOriginalUID
  tInfo[B_IS_DELIVER] = bIsDeliver
  tInfo[N_OCCUR_TIME] = nOccurTime
  FormatLog("sName=%s, sUID=%s, bIsAI=%s, bIsMLAI=%s, sOriginalUID=%s, bIsDeliver=%s, nOccurTime=%s", sName, sUID, bIsAI, bIsMLAI, sOriginalUID, bIsDeliver, nOccurTime)
end
function ReportPlayerUtils.RecordFatalDamagerReconnect(tMap, sName, sUID, bIsAI, bIsMLAI, sOriginalUID, bIsDeliver, nOccurTime)
  if LogIf(not IsTable(tMap), "invalid tMap") then
    return
  end
  if LogIf(not IsNonemptyString(sName), "invalid sName") then
    return
  end
  if LogIf(not IsBool(bIsAI), "invalid bIsAI") then
    return
  end
  if LogIf(not IsBool(bIsMLAI), "invalid bIsMLAI") then
    return
  end
  if LogIf(not IsBool(bIsDeliver), "invalid bIsDeliver") then
    return
  end
  if not IsString(sUID) then
    sUID = ""
  end
  if not IsString(sOriginalUID) then
    sOriginalUID = ""
  end
  local tInfo = tMap[sName]
  if tInfo then
    local nExistingUID = tonumber(tInfo[S_UID])
    if nExistingUID and 0 < nExistingUID then
      FormatLog("uid existed, %s", nExistingUID)
      return
    end
  else
    tInfo = {}
    tMap[sName] = tInfo
  end
  tInfo[S_NAME] = sName
  tInfo[S_UID] = sUID
  tInfo[B_IS_AI] = bIsAI
  tInfo[B_IS_MLAI] = bIsMLAI
  tInfo[S_ORIGINAL_UID] = sOriginalUID
  tInfo[B_IS_DELIVER] = bIsDeliver
  tInfo[N_OCCUR_TIME] = nOccurTime
  FormatLog("sName=%s, sUID=%s, bIsAI=%s, bIsMLAI=%s, sOriginalUID=%s, bIsDeliver=%s, nOccurTime=%s", sName, sUID, bIsAI, bIsMLAI, sOriginalUID, bIsDeliver, nOccurTime)
end
function ReportPlayerUtils.IsCharacterDeliverAI(uCharacter)
  if not slua.isValid(uCharacter) then
    return false
  end
  if not uCharacter.GetController then
    return false
  end
  local uController = uCharacter:GetController()
  if not slua.isValid(uController) then
    return false
  end
  if uController.IsDeliver and uController:IsDeliver() then
    return true
  end
  return false
end
function ReportPlayerUtils.GetBotType(snPlayerUID, bIsAI, bDelivery)
  local nAIBotType = 0
  if bDelivery then
    nAIBotType = 1
  end
  if slua.isValid(CGameState) and CGameState.GetPlayerStateByUID then
    local nPlayerUID = tonumber(snPlayerUID)
    if nPlayerUID then
      local uPlayerState = CGameState:GetPlayerStateByUID(nPlayerUID)
      if slua.isValid(uPlayerState) and uPlayerState.nMasterIndex ~= nil then
        if uPlayerState.TeammateTakeOverFeature and uPlayerState.TeammateTakeOverFeature.bAITakeOver then
          nAIBotType = 2
        else
          nAIBotType = 3
        end
      end
      if 44001 <= nPlayerUID and nPlayerUID <= 44010 then
        nAIBotType = 5
      end
    end
  end
  return nAIBotType
end
function ReportPlayerUtils.IsSubModeIDSlayBot(nSubModeID)
  if tSetSlayBotSubModeID[nSubModeID] then
    return true
  end
  return false
end
return ReportPlayerUtils