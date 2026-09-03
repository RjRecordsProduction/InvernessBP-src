local SecurityCommonUtils = {}
local EStrategyTypeInReplay = {
  FirstType = 10000,
  EspTotalSimTraceCnt = 10001,
  EspTotalImeFocusCnt = 10002,
  ClientUploadBulletFlySpeed = 10003,
  ClientGravityAnomalyCount = 10004,
  FlyingErrorCnt = 10005,
  MaxAllowFallingTime = 10006,
  AvatarCheckFailed = 10007,
  WeaponAvatarCheckFailed = 10008,
  HighValueIllegalWear = 10009
}
local IsDevelopment = function()
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local bIsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
  return bIsDevelopment
end
local IsValid = function(bCheckSluaIsValid, Value)
  if bCheckSluaIsValid then
    if not slua.isValid(Value) then
      return false
    end
  elseif not Value then
    return false
  end
  return true
end
local IsLogEnabled = function()
  if Client and not bWriteLog then
    return false
  end
  return true
end
local IsString = function(sInput)
  return type(sInput) == "string"
end
local IsNumber = function(nInput)
  return type(nInput) == "number"
end
local IsNonemptyString = function(sInput)
  if not IsString(sInput) then
    return false
  end
  return sInput ~= ""
end
local IsFunction = function(fInput)
  return type(fInput) == "function"
end
local IsBool = function(bInput)
  return type(bInput) == "boolean"
end
local IsTable = function(tInput)
  return type(tInput) == "table"
end
local IsVector = function(uInput)
  return uInput and uInput.__name == "FVector"
end
local IsUserData = function(uInput)
  return type(uInput) == "userdata"
end
local IsPlayerState = function(uInput)
  local ASTExtraPlayerState = import("/Script/ShadowTrackerExtra.STExtraPlayerState")
  return Game:IsClassOf(uInput, ASTExtraPlayerState)
end
local IsBaseCharacter = function(uInput)
  local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  return Game:IsClassOf(uInput, ASTExtraBaseCharacter)
end
local IsExtraCharacter = function(uInput)
  local ASTExtraCharacter = import("STExtraCharacter")
  return Game:IsClassOf(uInput, ASTExtraCharacter)
end
local IsUAECharacter = function(uInput)
  local AUAECharacter = import("UAECharacter")
  return Game:IsClassOf(uInput, AUAECharacter)
end
local IsExtraController = function(uInput)
  local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
  return Game:IsClassOf(uInput, ASTExtraPlayerController)
end
local RunCallback = function(fCallback)
  if IsFunction(fCallback) then
    fCallback()
  end
end
local _SetTypedMember = function(fIsTypeCorrect, tTable, Value, sMemberName, tClearOption)
  if not tTable then
    return
  end
  if not IsNonemptyString(sMemberName) then
    return
  end
  if tClearOption then
    tTable[sMemberName] = tClearOption.ClearValue
  end
  if fIsTypeCorrect(Value) then
    tTable[sMemberName] = Value
  end
end
local GetCallStackUpperLevelName = function()
  local tDebugInfo = debug.getinfo(3)
  if not tDebugInfo then
    return ""
  end
  local sFileBasename = ""
  local sMethodName = ""
  if IsString(tDebugInfo.name) then
    sMethodName = tDebugInfo.name
  end
  if IsString(tDebugInfo.short_src) then
    sFileBasename = tDebugInfo.short_src
    local tFilepathSplitArray = Game:SplitString(sFileBasename, "/")
    if 0 < #tFilepathSplitArray then
      sFileBasename = tFilepathSplitArray[#tFilepathSplitArray]
    end
    tFilepathSplitArray = Game:SplitString(sFileBasename, "\\")
    if 0 < #tFilepathSplitArray then
      sFileBasename = tFilepathSplitArray[#tFilepathSplitArray]
    end
    if sFileBasename:find(".lua", -4) == #sFileBasename - 3 then
      sFileBasename = string.sub(sFileBasename, 1, -5)
    end
  end
  return string.format("%s:%s", sFileBasename, sMethodName)
end
local LogIf = function(Condition, sFormat, ...)
  assert(IsNonemptyString(sFormat), "IsNonemptyString")
  if Condition and IsLogEnabled() then
    local sLogPrefix = string.format("called from %s, ", GetCallStackUpperLevelName())
    local FuncUtil = require("common.func_util")
    FuncUtil.FormatLog(sLogPrefix .. sFormat, ...)
  end
  return Condition
end
local FindItemInContainerByProperty = function(Container, PropertyKey, PropertyValue)
  if not Container or not next(Container) then
    return
  end
  for _, tSingle in pairs(Container) do
    if tSingle and tSingle[PropertyKey] == PropertyValue then
      return tSingle
    end
  end
end
local GetTableSize = function(tTable)
  if not tTable or not next(tTable) then
    return 0
  end
  local nSize = 0
  for _, __ in pairs(tTable) do
    nSize = nSize + 1
  end
  return nSize
end
function SecurityCommonUtils.SetNumberMember(tTable, nValue, sMemberName, tClearOption)
  _SetTypedMember(IsNumber, tTable, nValue, sMemberName, tClearOption)
end
function SecurityCommonUtils.SetStringMember(tTable, sValue, sMemberName, tClearOption)
  _SetTypedMember(IsString, tTable, sValue, sMemberName, tClearOption)
end
function SecurityCommonUtils.SetBoolMember(tTable, bValue, sMemberName, tClearOption)
  _SetTypedMember(IsBool, tTable, bValue, sMemberName, tClearOption)
end
function SecurityCommonUtils.SetFunctionMember(tTable, fValue, sMemberName, tClearOption)
  _SetTypedMember(IsFunction, tTable, fValue, sMemberName, tClearOption)
end
function SecurityCommonUtils.SetTableMember(tTable, tValue, sMemberName, tClearOption)
  _SetTypedMember(IsTable, tTable, tValue, sMemberName, tClearOption)
end
function SecurityCommonUtils.ClearTimerByMemberName(tTable, sMemberName)
  local FuncUtil = require("common.func_util")
  if not tTable then
    FuncUtil.FormatLog("invalid tTable")
    return
  end
  if not IsNonemptyString(sMemberName) then
    FuncUtil.FormatLog("invalid sMemberName")
    return
  end
  if not tTable.RemoveGameTimer then
    FuncUtil.FormatLog("invalid function")
    return
  end
  local nTimerID = tonumber(tTable[sMemberName])
  if not nTimerID then
    FuncUtil.FormatLog("invalid nTimerID")
    return
  end
  tTable:RemoveGameTimer(nTimerID)
  tTable[sMemberName] = nil
  FuncUtil.FormatLog("sMemberName=%s", sMemberName)
end
function SecurityCommonUtils.GetGameModeTypeInBattle()
  if Client and not GameStatus.IsInFightingStatus() then
    return -1
  end
  if slua.isValid(CGameState) and IsNumber(CGameState.GameModeType) then
    return CGameState.GameModeType
  end
  return -1
end
function SecurityCommonUtils.IsTeamDeathMatchInBattle()
  local nGameModeType = SecurityCommonUtils.GetGameModeTypeInBattle()
  return SecurityCommonUtils.IsGameModeTypeTDM(nGameModeType)
end
function SecurityCommonUtils.IsGameModeTypeTDM(nGameModeType)
  local EGameModeType = import("EGameModeType")
  return nGameModeType == EGameModeType.EDeathMatchGameMode or nGameModeType == EGameModeType.EVehicleWar_CAMP
end
function SecurityCommonUtils.IsHealthStatusHealthy(nHealthStatus)
  local ECharacterHealthStatus = import("ECharacterHealthStatus")
  return nHealthStatus == ECharacterHealthStatus.HealthyAlive
end
function SecurityCommonUtils.IsHealthStatusAlive(nHealthStatus)
  local ECharacterHealthStatus = import("ECharacterHealthStatus")
  return nHealthStatus == ECharacterHealthStatus.HealthyAlive or nHealthStatus == ECharacterHealthStatus.HasLastBreath
end
function SecurityCommonUtils.GetGameModeStateInBattle()
  local FuncUtil = require("common.func_util")
  local ASTExtraGameStateBase = import("STExtraGameStateBase")
  if not Game:IsClassOf(CGameState, ASTExtraGameStateBase) then
    FuncUtil.FormatLog("invalid CGameState")
    return ""
  end
  return CGameState.GameModeState
end
function SecurityCommonUtils.IsGameModeReadyStateInBattle()
  return SecurityCommonUtils.GetGameModeStateInBattle() == "ReadyState"
end
function SecurityCommonUtils.IsTrue(Value)
  if Value == true or Value == "true" then
    return true
  end
  return false
end
function SecurityCommonUtils.GetChildByPath(Element, bCheckSluaIsValid, sFailureLogID, ...)
  local sLogSuffix
  local FuncUtil = require("common.func_util")
  if IsNonemptyString(sFailureLogID) and IsLogEnabled() then
    sLogSuffix = string.format("%s, GetChildByPath called from %s", sFailureLogID, GetCallStackUpperLevelName())
  end
  local nChildCount = select("#", ...)
  for nChildIndex = 1, nChildCount do
    local ChildKey = select(nChildIndex, ...)
    if not ChildKey then
      if sLogSuffix then
        FuncUtil.FormatLog("invalid child key at %d/%d, %s", nChildIndex, nChildCount, sLogSuffix)
      end
      return
    end
    if not IsValid(bCheckSluaIsValid, Element) then
      if sLogSuffix then
        FuncUtil.FormatLog("invalid Element at %d/%d, %s", nChildIndex, nChildCount, sLogSuffix)
      end
      return
    end
    Element = Element[ChildKey]
  end
  return Element
end
local tExtractPlayerBasicInfoKeyFuncMap = {
  nPlayerKey = function(nPlayerKey)
    local uPlayerState, uCharacter
    if IsNumber(nPlayerKey) then
      uPlayerState = Game:GetPlayerStateByPlayerKey(nPlayerKey)
      if not slua.isValid(uPlayerState) then
        uCharacter = Game:GetPlayerByPlayerKeyIterateAllPawns(nPlayerKey)
      end
    end
    return uPlayerState, uCharacter
  end,
  nPlayerUID = function(nPlayerUID)
    local uPlayerState, uCharacter
    if IsNumber(nPlayerUID) then
      if slua.isValid(CGameState) then
        uPlayerState = CGameState:GetPlayerStateByUID(nPlayerUID)
      end
      if not slua.isValid(uPlayerState) then
        uCharacter = Game:GetPlayerByUIDIterateAllPawns(tostring(nPlayerUID))
      end
    end
    return uPlayerState, uCharacter
  end,
  sPlayerName = function(sPlayerName)
    local uPlayerState, uCharacter
    if IsNonemptyString(sPlayerName) then
      if slua.isValid(CGameState) then
        uPlayerState = CGameState:GetPlayerStateByPlayerName(sPlayerName)
      end
      if not slua.isValid(uPlayerState) then
        uCharacter = Game:GetPlayerByNameIterateAllPawns(sPlayerName)
      end
    end
    return uPlayerState, uCharacter
  end,
  uCharacter = function(uCharacter)
    local uPlayerState
    if IsBaseCharacter(uCharacter) then
      uPlayerState = uCharacter:GetPlayerStateSafety()
    end
    return uPlayerState, uCharacter
  end,
  uPlayerState = function(uPlayerState)
    if not IsPlayerState(uPlayerState) then
      uPlayerState = nil
    end
    return uPlayerState
  end
}
local tExtractPlayerBasicInfoAttributeFuncMap = {
  bName = function(uPlayerState, uCharacter, tResult)
    if slua.isValid(uPlayerState) then
      tResult.sPlayerName = uPlayerState.PlayerName
    elseif IsExtraCharacter(uCharacter) then
      tResult.sPlayerName = uCharacter:GetPlayerNameSafety()
    end
  end,
  bPlayerKey = function(uPlayerState, uCharacter, tResult)
    if slua.isValid(uPlayerState) then
      tResult.nPlayerKey = uPlayerState.PlayerKey
    elseif IsUAECharacter(uCharacter) then
      tResult.nPlayerKey = uCharacter.PlayerKey
    end
  end,
  bUID = function(uPlayerState, uCharacter, tResult)
    if slua.isValid(uPlayerState) then
      tResult.nPlayerUID = tonumber(uPlayerState.PlayerUID)
    elseif IsUAECharacter(uCharacter) then
      tResult.nPlayerUID = tonumber(uCharacter.PlayerUID)
    end
  end,
  bOpenID = function(uPlayerState, uCharacter, tResult)
    if slua.isValid(uPlayerState) then
      tResult.sOpenID = uPlayerState.OpenID
    end
  end,
  bIsAI = function(uPlayerState, uCharacter, tResult)
    if slua.isValid(uPlayerState) then
      tResult.bIsAI = uPlayerState.bPSEnsure
    elseif IsUAECharacter(uCharacter) then
      tResult.bIsAI = uCharacter.bEnsure
    end
  end,
  bTeamID = function(uPlayerState, uCharacter, tResult)
    if slua.isValid(uPlayerState) then
      tResult.nTeamID = uPlayerState.TeamID
    elseif IsUAECharacter(uCharacter) then
      tResult.nTeamID = uCharacter.TeamID
    end
  end,
  bInTeamIndex = function(uPlayerState, uCharacter, tResult)
    if not slua.isValid(uPlayerState) then
      return
    end
    local nInTeamIndex = 0
    local uTeammatePlayerStateArray = uPlayerState:GetTeamMatePlayerStateList({}, false)
    for _, uTeammatePlayerState in pairs(uTeammatePlayerStateArray) do
      nInTeamIndex = nInTeamIndex + 1
      if slua.isValid(uTeammatePlayerState) and uPlayerState == uTeammatePlayerState then
        tResult.        break
      end
    end
  end,
  bMLAIUID = function(uPlayerState, uCharacter, tResult)
    if slua.isValid(uPlayerState) then
      tResult.nMLAIUID = uPlayerState.MLAIDisplayUID
    elseif IsUAECharacter(uCharacter) then
      tResult.nMLAIUID = tonumber(uCharacter.PlayerUID)
    end
  end
}
function SecurityCommonUtils.ExtractPlayerBasicInfo(sKeyName, KeyValue, tAttributeNameMap)
  if LogIf(not IsString(sKeyName), "invalid sKeyName") then
    return
  end
  if LogIf(not IsTable(tAttributeNameMap), "invalid tAttributeNameMap") then
    return
  end
  local FuncUtil = require("common.func_util")
  local fExtractPlayerStateAndCharacterFunc = tExtractPlayerBasicInfoKeyFuncMap[sKeyName]
  if not fExtractPlayerStateAndCharacterFunc then
    FuncUtil.FormatLog("invalid sKeyName=%s", sKeyName)
    return
  end
  local uPlayerState, uCharacter = fExtractPlayerStateAndCharacterFunc(KeyValue)
  if not slua.isValid(uPlayerState) and not slua.isValid(uCharacter) then
    FuncUtil.FormatLog("both uPlayerState and uCharacter are invalid")
    return
  end
  local tResult = {}
  for sAttributeName, bIsAttributeNeeded in pairs(tAttributeNameMap) do
    if IsNonemptyString(sAttributeName) and bIsAttributeNeeded then
      local fExtractAttributeFunc = tExtractPlayerBasicInfoAttributeFuncMap[sAttributeName]
      if fExtractAttributeFunc then
        fExtractAttributeFunc(uPlayerState, uCharacter, tResult)
      end
    end
  end
  return tResult
end
function SecurityCommonUtils.IsTableCellContains(sTableName, nRowID, sColumnName, sSeparator, sValue2Search)
  if LogIf(not IsString(sTableName), "invalid sTableName") then
    return false
  end
  if LogIf(not IsNumber(nRowID), "invalid nRowID") then
    return false
  end
  if LogIf(not IsString(sColumnName), "invalid sColumnName") then
    return false
  end
  if LogIf(not IsNonemptyString(sSeparator), "invaid sSeparator") then
    return false
  end
  if LogIf(not IsString(sValue2Search), "invalid sValue2Search") then
    return false
  end
  local tRow = CDataTable.GetTableData(sTableName, nRowID)
  if LogIf(not tRow, "invalid tRow") then
    return false
  end
  local sCell = tRow[sColumnName]
  if LogIf(not IsNonemptyString(sCell), "invalid sCell") then
    return false
  end
  local StringUtil = require("common.string_util")
  local StrTrim = StringUtil.StrTrim
  sValue2Search = StrTrim(sValue2Search)
  local tSplitArray = Game:SplitString(sCell, sSeparator)
  for _, sSplittedString in pairs(tSplitArray) do
    if StrTrim(sSplittedString) == sValue2Search then
      return true
    end
  end
  return false
end
function SecurityCommonUtils.GetCurrentBattleMainModeID()
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  if slua.isValid(uGameInstance) then
    local nMainModeID = uGameInstance:GetMainModeID()
    if 0 < nMainModeID then
      local FuncUtil = require("common.func_util")
      FuncUtil.FormatLog("nMainModeID=%d", nMainModeID)
      return nMainModeID
    end
  end
  return -1
end
function SecurityCommonUtils.GetCurrentBattleSubModeID()
  if slua.isValid(CGameState) then
    local nSubModeID = tonumber(CGameState.GameModeID)
    if nSubModeID then
      return nSubModeID
    end
  end
  return -1
end
function SecurityCommonUtils.GetEnumValueByName(ImportedEnum, EntryName)
  if not ImportedEnum or not next(ImportedEnum) then
    return
  end
  if not IsString(EntryName) then
    return
  end
  EntryName = string.lower(EntryName)
  if not SecurityCommonUtils.CachedEnumNameToValue then
    SecurityCommonUtils.CachedEnumNameToValue = {}
  end
  if not SecurityCommonUtils.CachedEnumNameToValue[ImportedEnum] then
    local Name2Value = {}
    SecurityCommonUtils.CachedEnumNameToValue[ImportedEnum] = Name2Value
    for EnumName, EnumValue in pairs(ImportedEnum) do
      Name2Value[string.lower(tostring(EnumName))] = EnumValue
    end
  end
  return SecurityCommonUtils.CachedEnumNameToValue[ImportedEnum][EntryName]
end
function SecurityCommonUtils.IsFunctionCheckPass(FunctionOuter, sFuncName, ...)
  if not FunctionOuter then
    return false
  end
  local fIsCheckPass = FunctionOuter[sFuncName]
  if not SecurityCommonUtils.IsFunction(fIsCheckPass) then
    return false
  end
  if fIsCheckPass(...) then
    return true
  end
  return false
end
SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.SecurityCommonUtils.return SecurityCommonUtils