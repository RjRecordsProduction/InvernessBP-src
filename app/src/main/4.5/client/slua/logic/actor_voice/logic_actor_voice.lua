local ActorVoiceSystem = {
  ENUM_UNLOCK_TYPE = {
    LOCK = 0,
    PERMANENT = 1,
    LIMIT = 2
  },
  ENUM_SORT_TYPE = {
    DEFAULT = 1,
    LATEST = 2,
    OWN = 3,
    FAVORITE = 4
  },
  ENUM_ACTOR_QUALITY = {
    NORMAL = 1,
    MIDDLE = 2,
    HIGH = 3
  },
  PlayerCurVoicePlanID = 1,
  PlayerCurVoiceEnterPlayID = -1,
  PlayerCurGameResultRank = -1,
  IsShowMainActorVoiceUI = true,
  ENUM_FEATURE_CATEGORY = {
    LEADER = 1,
    MEMBER = 2,
    WELCOME = 3,
    PRAISE = 4,
    KILL = 5,
    VICTIM = 6
  },
  FeatureVoiceMapVersion = 0,
  FeatureCategoryID2BattleID = nil,
  DEFAULT_VOICE_TIME = 5,
  hasPlayedWelcomeVoice = false,
  bIsGotPlanData = false,
  ETeamVoiceStatus = {
    NotPlayed = 1,
    Playing = 2,
    Finished = 3
  },
  enterTeamVoiceQueue = {},
  voiceQueueTimer = nil,
  SIGN_LIST_TYPE_OFFSET = 8,
  ENUM_DEFAULT_SIGN_TYPE_COUNT = {ACTOR_0 = 33, OTHER = 30},
  _tAllVoiceMultiLugShowIndex = nil
}
local PLAYER_CHAT_VOICE_PLAN_COUNT = 3
local ACTOR_ENTER_TEAM_VOICE_INTERVAL = 0.5
local ACTOR_ENTER_TEAM_VOICE_CD_BUFFER = 0.3
local VOICE_FRACTION = 100000
local isInited = false
local isCreateRole = false
local OwnActorList = {}
local OwnActorVoiceList = {}
local UnLockedActorListByVoice = {}
local ActorExpireDisplayList = {}
local ActorInfoList = {}
local ItemIDToActorIDList = {}
local SelectedVoiceList = {}
local SelectedVoiceWheelList = {}
local SelectedFeatureVoiceMap = {}
local SelectedQuickSignList = {}
local SelectedQuickSignWheelList = {}
local LoadedBankMap = {}
local voiceSoundID = 0
local ActorCollectInfo = {}
local ProcessedActorIDs = {}
local bHasCacheFullActorInfoList = false
local quickSignCfgWithSignType = {}
local time_ticker = require("common.time_ticker")
local TimeUtil = require("client.common.time_util")
function ActorVoiceSystem.GetSelectedActorList(planID)
  if SelectedVoiceList and SelectedVoiceList[planID] then
    return SelectedVoiceList[planID]
  end
  return {}
end
function ActorVoiceSystem.GetSelectedActorWheelList(planID)
  if SelectedVoiceWheelList and SelectedVoiceWheelList[planID] then
    return SelectedVoiceWheelList[planID]
  end
  return {}
end
function ActorVoiceSystem.GetSelectedFeatureVoiceMap(planID)
  if SelectedFeatureVoiceMap and SelectedFeatureVoiceMap[planID] then
    return SelectedFeatureVoiceMap[planID]
  end
  return {}
end
function ActorVoiceSystem.SetSelectedFeatureVoiceMap(planID, featureVoiceMap)
  if not planID then
    return
  end
  if not SelectedFeatureVoiceMap then
    SelectedFeatureVoiceMap = {}
  end
  SelectedFeatureVoiceMap[planID] = featureVoiceMap
  local featureVoiceCfg = {
    version = ActorVoiceSystem.FeatureVoiceMapVersion,
    data = SelectedFeatureVoiceMap
  }
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(featureVoiceCfg, PlayerPrefsSystem.ePlayerPrefsType.eFeatureVoiceCfg)
  ActorVoiceSystem.SaveCurrentPlanSelectFeatureVoice2Config()
end
function ActorVoiceSystem.GetSelectedQuickSignList()
  return SelectedQuickSignList
end
function ActorVoiceSystem.GetSelectedQuickSignWheelList()
  return SelectedQuickSignWheelList
end
function ActorVoiceSystem.SetCurrentSelectVoicePlanID(planID)
  ActorVoiceSystem.PlayerCurVoicePlanID = planID
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  settingConfig.PlayerChatIndex = planID - 1
  ActorVoiceSystem.SaveCurrentPlanSelectFeatureVoice2Config()
  slua_GameFrontendHUD:FinishModifyUserSettings()
  local ActorVoiceHandler = require("client.network.Protocol.ActorVoiceHandler")
  ActorVoiceHandler.send_select_voice_plan_change(planID)
end
function ActorVoiceSystem.SetCurrentSelectVoiceEnterPlayID(actorID)
  ActorVoiceSystem.PlayerCurVoiceEnterPlayID = actorID
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  settingConfig.PlayerChatActorID = actorID
  slua_GameFrontendHUD:FinishModifyUserSettings()
  local ActorVoiceHandler = require("client.network.Protocol.ActorVoiceHandler")
  ActorVoiceHandler.send_select_voice_enter_play_change(actorID)
end
function ActorVoiceSystem.CheckIsActorValid(actorID)
  ActorVoiceSystem.CheckAndCacheSingleActorInfo(actorID)
  if ActorInfoList[actorID] and ActorInfoList[actorID].IsUnLock == 1 then
    return true
  end
  if OwnActorList[actorID] then
    return true
  end
  return false
end
function ActorVoiceSystem.CheckIsActorUnLocked(actorID)
  if ActorVoiceSystem.CheckIsActorValid(actorID) then
    return true
  end
  if UnLockedActorListByVoice[actorID] then
    return true
  end
  return false
end
function ActorVoiceSystem.GetExpireDataByItemId(itemID)
  ActorVoiceSystem.CheckAndCacheSingleActorInfoByItemID(itemID)
  local actorID = ItemIDToActorIDList[itemID]
  if actorID then
    local unlockType = ActorVoiceSystem.GetActorExpireDisplay(actorID)
    return unlockType == ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT
  end
  return true
end
function ActorVoiceSystem.CheckIsActorValidByItemID(itemID)
  ActorVoiceSystem.CheckAndCacheSingleActorInfoByItemID(itemID)
  local actorID = ItemIDToActorIDList[itemID]
  if actorID then
    return ActorVoiceSystem.CheckIsActorValid(actorID)
  end
  return false
end
function ActorVoiceSystem.CheckIsVoiceValidByItemID(itemID)
  local itemData = CDataTable.GetTableData("Item", itemID)
  if itemData then
    local key = itemData.ItemSubType
    return ActorVoiceSystem.CheckIsVoiceUnLock(key)
  end
  return false
end
function ActorVoiceSystem.CheckIsVoiceUnLock(key)
  local actorID = key // VOICE_FRACTION
  if ActorVoiceSystem.CheckIsActorValid(actorID) then
    return true
  end
  return OwnActorVoiceList[key] ~= nil
end
function ActorVoiceSystem.GetActorIDByKey(key)
  if not key then
    return 0
  end
  local actorID = key // VOICE_FRACTION
  return actorID
end
function ActorVoiceSystem.GetVoiceIDByKey(key)
  if not key then
    return 0
  end
  local voiceID = math.fmod(key, VOICE_FRACTION)
  return voiceID
end
local _welcomeVoiceMapByOrigKey
local _BuildWelcomeVoiceMapIndex = function()
  if _welcomeVoiceMapByOrigKey then
    return
  end
  local cfg = CDataTable.GetTable("WelcomeVoiceMapCfg")
  _welcomeVoiceMapByOrigKey = {}
  if not cfg then
    return
  end
  for _, mapCfg in pairs(cfg) do
    local origKey = mapCfg.OrigVoiceKey
    if origKey then
      local list = _welcomeVoiceMapByOrigKey[origKey]
      if not list then
        list = {}
        _welcomeVoiceMapByOrigKey[origKey] = list
      end
      list[#list + 1] = mapCfg
    end
  end
end
function ActorVoiceSystem.GetWelcomeVoiceMapListByOrigKey(origVoiceKey)
  if not origVoiceKey then
    return nil
  end
  _BuildWelcomeVoiceMapIndex()
  return _welcomeVoiceMapByOrigKey[origVoiceKey]
end
function ActorVoiceSystem.GetFirstWelcomeVoiceMapByOrigKey(origVoiceKey)
  local list = ActorVoiceSystem.GetWelcomeVoiceMapListByOrigKey(origVoiceKey)
  return list and list[1]
end
function ActorVoiceSystem.GetVoiceQuality(key)
  local itemID = CDataTable.GetTableData("VoiceSingleIDCfg", key)
  if itemID then
    local itemData = CDataTable.GetTableData("Item", itemID.ItemID)
    if itemData then
      return itemData.ItemQuality
    end
  end
  local actorID = ActorVoiceSystem.GetActorIDByKey(key)
  local actorData = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if actorData then
    local itemData = CDataTable.GetTableData("Item", actorData.ActorItemID)
    if itemData then
      return itemData.ItemQuality
    end
  end
  return 0
end
function ActorVoiceSystem.CheckIsVoiceNew(key)
  if OwnActorVoiceList[key] then
    return OwnActorVoiceList[key].isNew
  end
  return false
end
function ActorVoiceSystem.ReadVoice(key)
  if OwnActorVoiceList[key] then
    OwnActorVoiceList[key].isNew = false
  end
end
function ActorVoiceSystem.ReadAllVoices()
  for k, _ in pairs(OwnActorVoiceList) do
    ActorVoiceSystem.ReadVoice(k)
  end
end
function ActorVoiceSystem.GetVoiceDescByKey(key)
  local desc = DataMgr.GetVoiceDescByID(key)
  if desc == nil or desc == "" then
    local voiceID = ActorVoiceSystem.GetVoiceIDByKey(key)
    desc = DataMgr.GetVoiceDescByID(voiceID)
    if desc == nil or desc == "" then
      log_warning("[tinghaohu]ActorVoiceSystem.GetVoiceDescByKey. Not found voice Desc, key = ", tostring(key))
      return ""
    end
  end
  return desc
end
local preStatus = "None"
function ActorVoiceSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "[tinghaohu]ActorVoiceSystem.OnModePostSwitch. nextState = " .. tostring(nextState))
  local AkGameplayStatics = import("AkGameplayStatics")
  if nextState == GameStatus.Lobby then
    AkGameplayStatics.LoadBankByName("UI_hall_180")
    AkGameplayStatics.LoadBankByName("Pandora")
    ActorVoiceSystem.CheckAndShowLobbyActorVoiceUI(preStatus)
  elseif GameStatus.IsInFightingNotMainCity() then
    ActorVoiceSystem.ReleaseAllLoadedBank()
    AkGameplayStatics.UnloadBankByName("UI_hall_180")
    AkGameplayStatics.UnloadBankByName("Pandora")
    quickSignCfgWithSignType = {}
  elseif nextState == GameStatus.Login then
    ActorVoiceSystem.bIsGotPlanData = false
    OwnActorList = {}
    OwnActorVoiceList = {}
    UnLockedActorListByVoice = {}
    ActorExpireDisplayList = {}
    ActorInfoList = {}
    ItemIDToActorIDList = {}
    quickSignCfgWithSignType = {}
    ProcessedActorIDs = {}
    bHasCacheFullActorInfoList = false
  end
  preStatus = nextState
end
function ActorVoiceSystem.ResetVoiceData()
  log(bWriteLog and "[tinghaohu]ActorVoiceSystem.ResetVoiceData")
  isInited = false
  ActorVoiceSystem.IsShowMainActorVoiceUI = true
end
function ActorVoiceSystem.InitActorVoiceInfo()
  log(bWriteLog and "[voice_cost]ActorVoiceSystem.InitActorVoiceInfo Start")
  local StartTime = slua.getMiliseconds()
  PLAYER_CHAT_VOICE_PLAN_COUNT = LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH) and 3 or 1
  if isCreateRole then
    ActorVoiceSystem.SetDefaultVoiceWhenCreateRole()
    isCreateRole = false
  end
  if isInited == false then
    ActorVoiceSystem.InitSelectVoiceListFromConfig()
    ActorVoiceSystem.InitSelectQuickSignListFromConfig()
    ActorVoiceSystem.InitFeatureCategoryInfo()
    isInited = true
    ActorVoiceSystem.hasPlayedWelcomeVoice = false
  end
  ActorVoiceSystem.GetActorVoiceInfoReq()
  log(bWriteLog and string.format("[voice_cost] ActorVoiceSystem.InitActorVoiceInfo End cost: %fms", slua.getMiliseconds() - StartTime))
end
function ActorVoiceSystem.GetDefaultActorID()
  local actorID
  local publishID = ActorVoiceSystem.GetVoicePublishGameID()
  local regionID = FuncUtil.GetAccountRegionForBP()
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  if publishID == 1321 and regionID == AccountRegionForBPMacros.JP then
    if AvatarData.GetGameGender() == 1 then
      actorID = 3
    else
      actorID = 1
    end
  elseif publishID == 1450 then
    actorID = 263
  else
    actorID = 0
  end
  return actorID
end
function ActorVoiceSystem.GetDefaultVoice(voiceID)
  if voiceID == 0 then
    return 0
  end
  local actorID = ActorVoiceSystem.GetDefaultActorID()
  return actorID * VOICE_FRACTION + voiceID
end
function ActorVoiceSystem.GetDefaultVoiceByVoiceIDAndSignType(signType)
  if not signType then
    return 0
  end
  local actorID = ActorVoiceSystem.GetDefaultActorID()
  if not actorID then
    return 0
  end
  local signCfg = CDataTable.GetTableDataByFilter("QuickSignTable", "ActorID", actorID, "SignType", signType)
  if signCfg then
    return actorID * VOICE_FRACTION + signCfg.VoiceID
  end
  return 0
end
function ActorVoiceSystem.GetVoiceKeyByActorIDAndSignType(actorID, signType, bNeedSignOffset)
  if not actorID or not signType then
    return 0
  end
  local realSignType = signType
  if bNeedSignOffset then
    realSignType = signType + ActorVoiceSystem.SIGN_LIST_TYPE_OFFSET
  end
  local signCfg = ActorVoiceSystem.GetAndCacheOneActorQuickSignWithType(actorID, realSignType)
  return signCfg and signCfg.Key or 0
end
function ActorVoiceSystem.MarkAsCreatingRole()
  isCreateRole = true
end
function ActorVoiceSystem.SetDefaultVoiceWhenCreateRole()
  log(bWriteLog and "[voice_cost] ActorVoiceSystem.SetDefaultVoiceWhenCreateRole. Start")
  local StartTime = slua.getMiliseconds()
  local actorID = ActorVoiceSystem.GetDefaultActorID()
  if not actorID then
    log_error("[Set default voice when create role] actorID is nil")
    return
  end
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  local quickChatIDList = ActorVoiceSystem.GetVoiceDefaultSetting("DefaultPlayerChatQuickTextIDList")
  local quickChatIDWheelList = ActorVoiceSystem.GetVoiceDefaultSetting("DefaultPlayerWheelChatQuickTextIDList")
  local quickSignIDList = ActorVoiceSystem.GetVoiceDefaultSetting("QuickSignIDList")
  local quickSignIDWheelList = ActorVoiceSystem.GetVoiceDefaultSetting("QuickSignWheelIDList")
  if quickChatIDList == nil then
    log_error("[Set default voice when create role] quickChatIDList is nil")
    return
  end
  if quickChatIDWheelList == nil then
    log_error("[Set default voice when create role] quickChatIDWheelList is nil")
    return
  end
  if quickSignIDList == nil then
    log_error("[Set default voice when create role] quickSignIDList is nil")
    return
  end
  if quickSignIDWheelList == nil then
    log_error("[Set default voice when create role] quickSignIDWheelList is nil")
    return
  end
  slua_GameFrontendHUD:BeginModifyUserSettings()
  settingConfig.PlayerChatIndex = ActorVoiceSystem.PlayerCurVoicePlanID - 1
  settingConfig.PlayerChatActorID = ActorVoiceSystem.PlayerCurVoiceEnterPlayID
  for a = 1, PLAYER_CHAT_VOICE_PLAN_COUNT do
    if settingConfig["PlayerChatQuickTextIDList_" .. a] then
      settingConfig["PlayerChatQuickTextIDList_" .. a]:Clear()
    else
      settingConfig["PlayerChatQuickTextIDList_" .. a] = slua.Array(UEnums.EPropertyClass.Int)
    end
    if settingConfig["PlayerWheelChatQuickTextIDList_" .. a] then
      settingConfig["PlayerWheelChatQuickTextIDList_" .. a]:Clear()
    else
      settingConfig["PlayerWheelChatQuickTextIDList_" .. a] = slua.Array(UEnums.EPropertyClass.Int)
    end
  end
  if settingConfig.QuickSignIDList then
    settingConfig.QuickSignIDList:Clear()
  else
    settingConfig.QuickSignIDList = slua.Array(UEnums.EPropertyClass.Int)
  end
  if settingConfig.QuickSignWheelIDList then
    settingConfig.QuickSignWheelIDList:Clear()
  else
    settingConfig.QuickSignWheelIDList = slua.Array(UEnums.EPropertyClass.Int)
  end
  for a = 1, PLAYER_CHAT_VOICE_PLAN_COUNT do
    for i = 0, quickChatIDList:Num() - 1 do
      settingConfig["PlayerChatQuickTextIDList_" .. a]:Add(ActorVoiceSystem.GetDefaultVoice(quickChatIDList:Get(i)))
    end
    for i = 0, quickChatIDWheelList:Num() - 1 do
      settingConfig["PlayerWheelChatQuickTextIDList_" .. a]:Add(ActorVoiceSystem.GetDefaultVoice(quickChatIDWheelList:Get(i)))
    end
  end
  local defaultSignCount = quickSignIDList:Num()
  local defaultActorID = ActorVoiceSystem.GetDefaultActorID()
  if defaultActorID ~= 0 then
    local signCountLimit = ActorVoiceSystem.ENUM_DEFAULT_SIGN_TYPE_COUNT.OTHER - ActorVoiceSystem.SIGN_LIST_TYPE_OFFSET
    if defaultSignCount > signCountLimit then
      defaultSignCount = signCountLimit
    end
  end
  for i = 0, defaultSignCount - 1 do
    local signVoiceID = ActorVoiceSystem.GetDefaultVoiceByVoiceIDAndSignType(i + 1 + ActorVoiceSystem.SIGN_LIST_TYPE_OFFSET)
    settingConfig.QuickSignIDList:Add(signVoiceID)
  end
  for i = 0, quickSignIDWheelList:Num() - 1 do
    local signVoiceID = ActorVoiceSystem.GetDefaultVoiceByVoiceIDAndSignType(i + 1)
    settingConfig.QuickSignWheelIDList:Add(signVoiceID)
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
  log(bWriteLog and string.format("[voice_cost] ActorVoiceSystem.SetDefaultVoiceWhenCreateRole. End cost: %fms", slua.getMiliseconds() - StartTime))
end
function ActorVoiceSystem.InitActorInfoFromTable(ignoreTime)
  if bHasCacheFullActorInfoList then
    return
  end
  log(bWriteLog and "[voice_cost][tinghaohu]ActorVoiceSystem.InitActorInfoFromTable Start")
  local StartTime = slua.getMiliseconds()
  local publishID = ActorVoiceSystem.GetVoicePublishGameID()
  local regionID = FuncUtil.GetAccountRegionForBP()
  local actorTable = CDataTable.GetTable("VoiceActorCfg")
  if not actorTable then
    return
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  local bVictorMenuOpen = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_CHARACTER)
  local bIsDev = Client and Client.IsDevelopment()
  ActorVoiceSystem.InitActorInfoFromTable_BatchCtx = {
    publishID = publishID,
    regionID = regionID,
    curTime = curTime,
    ignoreTime = ignoreTime,
    bVictorMenuOpen = bVictorMenuOpen,
      }
  for actorID, actorCfg in pairs(actorTable) do
    ActorVoiceSystem.InitSingleActorInfoFromTableInternal(actorID, actorCfg, ignoreTime, publishID, regionID, curTime)
  end
  ActorVoiceSystem.InitActorInfoFromTable_BatchCtx = nil
  log(bWriteLog and string.format("[voice_cost] ActorVoiceSystem.InitActorInfoFromTable. End cost %fms", slua.getMiliseconds() - StartTime))
  bHasCacheFullActorInfoList = true
end
function ActorVoiceSystem.InitSelectVoiceListFromConfig()
  log(bWriteLog and "[voice_cost] ActorVoiceSystem.InitSelectVoiceListFromConfig. Start")
  local StartTime = slua.getMiliseconds()
  SelectedVoiceList = {}
  SelectedVoiceWheelList = {}
  SelectedFeatureVoiceMap = {}
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  local quickChatIDList = ActorVoiceSystem.GetVoiceDefaultSetting("DefaultPlayerChatQuickTextIDList")
  local quickChatIDWheelList = ActorVoiceSystem.GetVoiceDefaultSetting("DefaultPlayerWheelChatQuickTextIDList")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local featureVoiceCfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFeatureVoiceCfg)
  local featureVoiceCfgData = featureVoiceCfg and featureVoiceCfg.data
  for a = 1, PLAYER_CHAT_VOICE_PLAN_COUNT do
    local playerChatList = settingConfig["PlayerChatQuickTextIDList_" .. a]
    if playerChatList and playerChatList:Num() <= 0 and quickChatIDList then
      for i = 0, quickChatIDList:Num() - 1 do
        playerChatList:Add(ActorVoiceSystem.GetDefaultVoice(quickChatIDList:Get(i)))
      end
    end
    local playerChatWheelList = settingConfig["PlayerWheelChatQuickTextIDList_" .. a]
    if playerChatWheelList and playerChatWheelList:Num() <= 0 and quickChatIDWheelList then
      for i = 0, quickChatIDWheelList:Num() - 1 do
        playerChatWheelList:Add(ActorVoiceSystem.GetDefaultVoice(quickChatIDWheelList:Get(i)))
      end
    end
    for i = 0, playerChatList:Num() - 1 do
      if SelectedVoiceList[a] == nil then
        SelectedVoiceList[a] = {}
      end
      table.insert(SelectedVoiceList[a], playerChatList:Get(i))
    end
    for i = 0, playerChatWheelList:Num() - 1 do
      if SelectedVoiceWheelList[a] == nil then
        SelectedVoiceWheelList[a] = {}
      end
      table.insert(SelectedVoiceWheelList[a], playerChatWheelList:Get(i))
    end
    if featureVoiceCfgData and featureVoiceCfgData[a] then
      SelectedFeatureVoiceMap[a] = featureVoiceCfgData[a]
    end
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
  log(bWriteLog and string.format("[voice_cost] ActorVoiceSystem.InitSelectVoiceListFromConfig. End cost %fms", slua.getMiliseconds() - StartTime))
end
function ActorVoiceSystem.InitSelectQuickSignListFromConfig()
  log(bWriteLog and "[voice_cost] ActorVoiceSystem.InitSelectQuickSignListFromConfig. Start")
  local StartTime = slua.getMiliseconds()
  SelectedQuickSignList = {}
  SelectedQuickSignWheelList = {}
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  for i = 0, settingConfig.QuickSignIDList:Num() - 1 do
    table.insert(SelectedQuickSignList, settingConfig.QuickSignIDList:Get(i))
  end
  for i = 0, settingConfig.QuickSignWheelIDList:Num() - 1 do
    table.insert(SelectedQuickSignWheelList, settingConfig.QuickSignWheelIDList:Get(i))
  end
  log(bWriteLog and string.format("[voice_cost] ActorVoiceSystem.InitSelectQuickSignListFromConfig. End cost: %fms", slua.getMiliseconds() - StartTime))
end
function ActorVoiceSystem.CheckNeedWarningSign(key)
  local voiceID = ActorVoiceSystem.GetVoiceIDByKey(key)
  local flagCfg = CDataTable.GetTable("FlagIDCfg")
  if flagCfg then
    for _, data in pairs(flagCfg) do
      if string.find(data.ChatIDList, voiceID) then
        return true
      end
    end
  end
  return false
end
function ActorVoiceSystem.GetActorVoiceInfoReq()
  log(bWriteLog and "[tinghaohu]ActorVoiceSystem.GetActorVoiceInfoReq")
  local ActorVoiceHandler = require("client.network.Protocol.ActorVoiceHandler")
  ActorVoiceHandler.send_get_voice_msg_info_req()
end
function ActorVoiceSystem.GetActorVoiceInfoRes(res)
  log_tree("[tinghaohu]ActorVoiceSystem.GetActorVoiceInfoRes. res = ", res)
  ActorVoiceSystem.RefreshActorOwnerList(res.dubber, res.dubber_get_times, res.dubber_expire)
  ActorVoiceSystem.AppendRegionLimitActor(res.dubber)
  ActorVoiceSystem.RefreshActorVoiceOwnerList(res.own_msgs, res.msg_expire, false)
  ActorVoiceSystem.RefreshActorExpireDisplayAll()
  if ActorVoiceSystem.CheckNeedReportPlayerInfo(res) then
    ActorVoiceSystem.UploadPlayerVoiceList()
    ActorVoiceSystem.UploadPlayerQuickSignList()
  end
  ActorCollectInfo = res.dubber_collect or {}
  ActorVoiceSystem.RefreshPlayerSelectConfig(res.cur_setting_idx, res.cur_dubber)
  ActorVoiceSystem.CheckWelcomeVoice()
  EventSystem:postEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_ACTOR_CHANGE)
end
function ActorVoiceSystem.ActorChangedNotify(dubber, dubber_expire)
  log(bWriteLog and "[DeanJYT] ActorVoiceSystem.ActorChangedNotify")
  ActorVoiceSystem.RefreshActorOwnerList(dubber, nil, dubber_expire)
  ActorVoiceSystem.RefreshActorExpireDisplayByActor(dubber, dubber_expire)
  ActorVoiceSystem.AppendRegionLimitActor(dubber)
  EventSystem:postEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_ACTOR_CHANGE)
end
function ActorVoiceSystem.RefreshActorOwnerList(dubber, dubber_get_times, dubber_expire)
  log_tree("[tinghaohu]ActorVoiceSystem.RefreshActorOwnerList dubber = ", dubber)
  if not dubber or not next(dubber) then
    return
  end
  dubber_get_times = dubber_get_times or {}
  dubber_expire = dubber_expire or {}
  local TimeUtil = require("client.common.time_util")
  for actorID, _ in pairs(dubber) do
    OwnActorList[actorID] = {
      getTime = dubber_get_times[actorID] or TimeUtil.GetServerTimeInSec(),
      expireTime = dubber_expire[actorID]
    }
  end
end
function ActorVoiceSystem.AppendRegionLimitActor(dubber)
  log(bWriteLog and string.format("[voice_cost][ActorInfoList] ActorVoiceSystem.AppendRegionLimitActor. dubber=%s write ActionInfoList", tostring(dubber)))
  if not dubber or not next(dubber) then
    return
  end
  local publishID = ActorVoiceSystem.GetVoicePublishGameID()
  local regionID = FuncUtil.GetAccountRegionForBP()
  for actorID, _ in pairs(dubber) do
    ActorVoiceSystem.CheckAndCacheSingleActorInfo(actorID)
    if ActorInfoList[actorID] == nil then
      local actorData = CDataTable.GetTableData("VoiceActorCfg", actorID)
      if actorData and (actorData.OpenPublish == "" or string.find(actorData.OpenPublish, publishID)) and (actorData.IsLimitRegion == false or actorData.OpenRegion == "" or string.find(actorData.OpenRegion, regionID)) then
        ActorInfoList[actorID] = actorData
      end
    end
  end
end
function ActorVoiceSystem.ActorVoiceChangedNotify(own_msgs, msg_expire)
  log(bWriteLog and "[DeanJYT] ActorVoiceSystem.ActorVoiceChangedNotify")
  ActorVoiceSystem.RefreshActorVoiceOwnerList(own_msgs, msg_expire, true)
  ActorVoiceSystem.RefreshActorExpireDisplayByActorVoice(own_msgs, msg_expire)
  ActorVoiceSystem.AppendRegionLimitActor(own_msgs)
  local updatedActors = {}
  for key, _ in pairs(own_msgs) do
    local actorID = ActorVoiceSystem.GetActorIDByKey(key)
    table.insert(updatedActors, actorID)
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_QUICK_MESSAGE_NEW, updatedActors)
  EventSystem:postEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_OWN_MESSAGE_CHANGAE)
end
function ActorVoiceSystem.RefreshActorVoiceOwnerList(own_msgs, msg_expire, isNew)
  log_tree("[tinghaohu]ActorVoiceSystem.RefreshActorVoiceOwnerList dubber = ", own_msgs)
  if not own_msgs or not next(own_msgs) then
    return
  end
  msg_expire = msg_expire or {}
  for key, _ in pairs(own_msgs) do
    OwnActorVoiceList[key] = {
      isNew = isNew,
      expireTime = msg_expire[key]
    }
    local actorID = ActorVoiceSystem.GetActorIDByKey(key)
    if not UnLockedActorListByVoice[actorID] then
      UnLockedActorListByVoice[actorID] = true
    end
  end
end
function ActorVoiceSystem.CheckNeedReportPlayerInfo(res)
  if res.is_need_report == true then
    log(bWriteLog and "[tinghaohu]ActorVoiceSystem.GetActorVoiceInfoRes. Need Report")
    return true
  end
  local need_update = false
  SelectedVoiceList = {}
  SelectedVoiceWheelList = {}
  SelectedQuickSignList = {}
  SelectedQuickSignWheelList = {}
  SelectedFeatureVoiceMap = {}
  if res.msgs ~= nil then
    SelectedVoiceList[1] = {}
    for i = 1, 20 do
      table.insert(SelectedVoiceList[1], 0)
    end
    for i, j in pairs(res.msgs) do
      SelectedVoiceList[1][j] = i
    end
  end
  if res.ext_msgs and next(res.ext_msgs) then
    for a = 1, #res.ext_msgs do
      SelectedVoiceList[a + 1] = {}
      for i = 1, 20 do
        table.insert(SelectedVoiceList[a + 1], 0)
      end
      for i, j in pairs(res.ext_msgs[a]) do
        SelectedVoiceList[a + 1][j] = i
      end
    end
  else
    need_update = true
  end
  if res.rotary_table ~= nil then
    SelectedVoiceWheelList[1] = {}
    for i = 1, 8 do
      table.insert(SelectedVoiceWheelList[1], 0)
    end
    for id, index in pairs(res.rotary_table) do
      SelectedVoiceWheelList[1][index] = id
    end
  end
  if res.ext_rotary_table and next(res.ext_rotary_table) then
    for a = 1, #res.ext_rotary_table do
      SelectedVoiceWheelList[a + 1] = {}
      for i = 1, 8 do
        table.insert(SelectedVoiceWheelList[a + 1], 0)
      end
      for id, index in pairs(res.ext_rotary_table[a]) do
        SelectedVoiceWheelList[a + 1][index] = id
      end
    end
  else
    need_update = true
  end
  if res.quicksign_msgs then
    for i = 1, 25 do
      table.insert(SelectedQuickSignList, 0)
    end
    for signType, key in pairs(res.quicksign_msgs) do
      if not ActorVoiceSystem.CheckIsVoiceUnLock(key) then
        local defaultKey = ActorVoiceSystem.GetVoiceKeyByActorIDAndSignType(0, signType, true)
        SelectedQuickSignList[signType] = defaultKey
        need_update = true
      else
        local curActorID = ActorVoiceSystem.GetActorIDByKey(key)
        if curActorID ~= 0 then
          local bExistSignType = false
          local currentSignKey = ActorVoiceSystem.GetVoiceKeyByActorIDAndSignType(curActorID, signType, true)
          bExistSignType = currentSignKey and currentSignKey ~= 0
          if not bExistSignType then
            log(bWriteLog and string.format("ActorVoiceSystem.CheckNeedReportPlayerInfo no responding key for actorID: %s and signType: %s, use corresponding sign item in ActorID 0 ", tostring(curActorID), tostring(signType)))
            SelectedQuickSignList[signType] = ActorVoiceSystem.GetVoiceKeyByActorIDAndSignType(0, signType, true)
            need_update = true
          else
            SelectedQuickSignList[signType] = key
          end
        else
          SelectedQuickSignList[signType] = key
        end
      end
    end
  else
    local defaultActorID = ActorVoiceSystem.GetDefaultActorID()
    local defaultSignTypeCount = defaultActorID == 0 and ActorVoiceSystem.ENUM_DEFAULT_SIGN_TYPE_COUNT.ACTOR_0 or ActorVoiceSystem.ENUM_DEFAULT_SIGN_TYPE_COUNT.OTHER
    for signType = 9, defaultSignTypeCount do
      local key = ActorVoiceSystem.GetVoiceKeyByActorIDAndSignType(0, signType, false)
      table.insert(SelectedQuickSignList, key)
    end
    need_update = true
  end
  if res.quicksign_rotary_table then
    for i = 1, 8 do
      table.insert(SelectedQuickSignWheelList, 0)
    end
    for key, signType in pairs(res.quicksign_rotary_table) do
      if not ActorVoiceSystem.CheckIsVoiceUnLock(key) then
        local defaultKey = ActorVoiceSystem.GetVoiceKeyByActorIDAndSignType(0, signType, false)
        SelectedQuickSignWheelList[signType] = defaultKey
        need_update = true
      else
        SelectedQuickSignWheelList[signType] = key
      end
    end
  else
    for signType = 1, 8 do
      local key = ActorVoiceSystem.GetVoiceKeyByActorIDAndSignType(0, signType, false)
      table.insert(SelectedQuickSignWheelList, key)
    end
    need_update = true
  end
  if res.ext_feature_msgs then
    for i = 1, PLAYER_CHAT_VOICE_PLAN_COUNT do
      SelectedFeatureVoiceMap[i] = {}
      local featureMapList = res.ext_feature_msgs[i]
      if featureMapList then
        for ii, jj in ipairs(featureMapList) do
          SelectedFeatureVoiceMap[i][ii] = {}
          for kkk, vvv in pairs(jj) do
            SelectedFeatureVoiceMap[i][ii][vvv] = kkk
          end
        end
      end
    end
  end
  ActorVoiceSystem.SaveVoiceList2Config()
  return need_update
end
function ActorVoiceSystem.SaveVoiceList2Config()
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  for a = 1, PLAYER_CHAT_VOICE_PLAN_COUNT do
    settingConfig["PlayerChatQuickTextIDList_" .. a]:Clear()
    if SelectedVoiceList[a] and next(SelectedVoiceList[a]) then
      for _, v in pairs(SelectedVoiceList[a]) do
        settingConfig["PlayerChatQuickTextIDList_" .. a]:Add(v)
      end
    end
    settingConfig["PlayerWheelChatQuickTextIDList_" .. a]:Clear()
    if SelectedVoiceWheelList[a] and next(SelectedVoiceWheelList[a]) then
      for _, v in pairs(SelectedVoiceWheelList[a]) do
        settingConfig["PlayerWheelChatQuickTextIDList_" .. a]:Add(v)
      end
    end
  end
  settingConfig.QuickSignIDList:Clear()
  for _, v in pairs(SelectedQuickSignList) do
    settingConfig.QuickSignIDList:Add(v)
  end
  settingConfig.QuickSignWheelIDList:Clear()
  for _, v in pairs(SelectedQuickSignWheelList) do
    settingConfig.QuickSignWheelIDList:Add(v)
  end
  ActorVoiceSystem.SaveCurrentPlanSelectFeatureVoice2Config()
  slua_GameFrontendHUD:FinishModifyUserSettings()
  ActorVoiceSystem.SaveSelectedFeatureVoiceMapToPrefs()
end
function ActorVoiceSystem.UploadPlayerVoiceList(planID)
  ActorVoiceSystem.InitSelectVoiceListFromConfig()
  local msgs, rotary_table, ext_msgs, ext_rotary_table
  if planID == nil then
    msgs = SelectedVoiceList[1]
    rotary_table = SelectedVoiceWheelList[1]
    if 1 < PLAYER_CHAT_VOICE_PLAN_COUNT then
      ext_msgs = {}
      ext_rotary_table = {}
      for a = 2, PLAYER_CHAT_VOICE_PLAN_COUNT do
        ext_msgs[a - 1] = SelectedVoiceList[a]
        ext_rotary_table[a - 1] = SelectedVoiceWheelList[a]
      end
    end
  elseif planID == 1 then
    msgs = SelectedVoiceList[1]
    rotary_table = SelectedVoiceWheelList[1]
  elseif 1 < planID then
    ext_msgs = {
      [planID - 1] = SelectedVoiceList[planID]
    }
    ext_rotary_table = {
      [planID - 1] = SelectedVoiceWheelList[planID]
    }
  end
  local ext_feature_msgs
  if planID == nil then
    for i = 1, PLAYER_CHAT_VOICE_PLAN_COUNT do
      if ext_feature_msgs == nil then
        ext_feature_msgs = {}
      end
      ext_feature_msgs[i] = SelectedFeatureVoiceMap[i]
    end
  else
    ext_feature_msgs = {
      [planID] = SelectedFeatureVoiceMap[planID]
    }
  end
  if msgs or rotary_table or ext_msgs or ext_rotary_table or ext_feature_msgs then
    local ActorVoiceHandler = require("client.network.Protocol.ActorVoiceHandler")
    ActorVoiceHandler.send_update_voice_msgs_req(msgs, rotary_table, 0, ext_msgs, ext_rotary_table, ext_feature_msgs)
  end
end
function ActorVoiceSystem.UploadPlayerQuickSignList()
  ActorVoiceSystem.InitSelectQuickSignListFromConfig()
  if next(SelectedQuickSignList) or next(SelectedQuickSignWheelList) then
    local ActorVoiceHandler = require("client.network.Protocol.ActorVoiceHandler")
    ActorVoiceHandler.send_update_voice_msgs_req(SelectedQuickSignList, SelectedQuickSignWheelList, 1)
  end
end
function ActorVoiceSystem.RefreshPlayerSelectConfig(planID, actorID)
  planID = planID or 1
  actorID = actorID or -1
  ActorVoiceSystem.PlayerCurVoicePlanID = planID
  ActorVoiceSystem.PlayerCurVoiceEnterPlayID = actorID
  ActorVoiceSystem.bIsGotPlanData = true
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  settingConfig.PlayerChatIndex = planID - 1
  settingConfig.PlayerChatActorID = actorID
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function ActorVoiceSystem.UpdatePlayerListenVoiceEvent(id)
  log(bWriteLog and "ActorVoiceSystem.UpdatePlayerListenVoiceEvent id:" .. id)
  local ActorVoiceHandler = require("client.network.Protocol.ActorVoiceHandler")
  ActorVoiceHandler.send_voice_msg_audition_req(id)
end
function ActorVoiceSystem.GetShowActors(bQuickSign)
  ActorVoiceSystem.InitActorInfoFromTable()
  local list = {}
  local publishID = ActorVoiceSystem.GetVoicePublishGameID()
  local region = FuncUtil.GetAccountRegionForBP()
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  for actorID, actorInfo in pairs(ActorInfoList) do
    local isActorExist = true
    if bQuickSign and not actorInfo.IsContainingSign then
      isActorExist = false
    end
    if isActorExist and not actorInfo.IsWardrobeHidden and (publishID == 1321 or actorInfo.IsShowUntilGet == false or ActorVoiceSystem.CheckIsActorUnLocked(actorID)) then
      local SortKey
      if publishID == 1321 then
        if region == AccountRegionForBPMacros.JP then
          SortKey = actorInfo.SortKeyJP
        else
          SortKey = actorInfo.SortKeyKR
        end
      else
        SortKey = actorInfo.SortKey
      end
      local tempActorData = {
        ActorID = actorID,
        ActorName = actorInfo.ActorName,
        ActorItemID = actorInfo.ActorItemID,
        ActorQuality = actorInfo.ActorQuality,
              }
      if not bQuickSign then
        tempActorData.IsSelectEnterPlay = actorID == ActorVoiceSystem.PlayerCurVoiceEnterPlayID
      end
      table.insert(list, tempActorData)
    end
  end
  table.sort(list, function(a, b)
    return a.SortKey < b.SortKey
  end)
  return list
end
function ActorVoiceSystem.SortShowActors(list, sortType)
  local sortFunc
  sortType = sortType or ActorVoiceSystem.ENUM_SORT_TYPE.DEFAULT
  if sortType == ActorVoiceSystem.ENUM_SORT_TYPE.DEFAULT then
    function sortFunc(a, b)
      return a.SortKey < b.SortKey
    end
  elseif sortType == ActorVoiceSystem.ENUM_SORT_TYPE.LATEST then
    function sortFunc(a, b)
      local unlockA = ActorVoiceSystem.CheckIsActorUnLocked(a.ActorID)
      local unlockB = ActorVoiceSystem.CheckIsActorUnLocked(b.ActorID)
      if unlockA == unlockB then
        local timeA = OwnActorList[a.ActorID] and OwnActorList[a.ActorID].getTime
        if not timeA then
          return false
        end
        local timeB = OwnActorList[b.ActorID] and OwnActorList[b.ActorID].getTime
        if not timeB then
          return true
        end
        if timeA == timeB then
          return a.ActorID > b.ActorID
        else
          return timeA > timeB
        end
      else
        return unlockA
      end
    end
  elseif sortType == ActorVoiceSystem.ENUM_SORT_TYPE.OWN then
    function sortFunc(a, b)
      local unlockA = ActorVoiceSystem.CheckIsActorUnLocked(a.ActorID)
      local unlockB = ActorVoiceSystem.CheckIsActorUnLocked(b.ActorID)
      if unlockA == unlockB then
        return a.SortKey < b.SortKey
      else
        return unlockA
      end
    end
  elseif sortType == ActorVoiceSystem.ENUM_SORT_TYPE.FAVORITE then
    function sortFunc(a, b)
      local CollectTSA = ActorCollectInfo[a.ActorID]
      local CollectTSB = ActorCollectInfo[b.ActorID]
      if CollectTSA and CollectTSB then
        return CollectTSA > CollectTSB
      elseif CollectTSA and not CollectTSB then
        return true
      elseif not CollectTSA and CollectTSB then
        return false
      elseif not CollectTSA and not CollectTSB then
        local unlockA = ActorVoiceSystem.CheckIsActorUnLocked(a.ActorID)
        local unlockB = ActorVoiceSystem.CheckIsActorUnLocked(b.ActorID)
        if unlockA == unlockB then
          return a.SortKey < b.SortKey
        else
          return unlockA
        end
      end
      return CollectTSA > CollectTSB
    end
  end
  if sortFunc ~= nil then
    table.sort(list, sortFunc)
  end
end
function ActorVoiceSystem.GetBankPath(itemID)
  log(bWriteLog and string.format("ActorVoiceSystem.GetBankPath. itemID=%s read ItemIDToActorIDList", tostring(itemID)))
  local bankName
  ActorVoiceSystem.CheckAndCacheSingleActorInfoByItemID(itemID)
  local actorID = ItemIDToActorIDList[itemID]
  if actorID then
    local cfg = CDataTable.GetTableData("VoiceActorCfg", actorID)
    if cfg and cfg.BankName then
      bankName = cfg.BankName
    end
  else
    local result = CDataTable.GetTableByFilter("VoiceActorCfg", "ActorItemID", itemID)
    if result then
      for _, cfg in pairs(result) do
        bankName = cfg.BankName
        break
      end
    end
  end
  if not bankName then
    return nil
  end
  local StringUtil = require("common.string_util")
  bankName = StringUtil.Split(bankName, "|")[1]
  return ActorVoiceSystem.GetFullBankPathByBankName(bankName)
end
function ActorVoiceSystem.GetBankPathByActorID(actorID)
  local bankName
  local cfg = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if cfg and cfg.BankName then
    bankName = cfg.BankName
  end
  if not bankName then
    return nil
  end
  local StringUtil = require("common.string_util")
  bankName = StringUtil.Split(bankName, "|")[1]
  return ActorVoiceSystem.GetFullBankPathByBankName(bankName)
end
function ActorVoiceSystem.GetFullBankPathByBankName(bankName)
  if not bankName then
    return nil
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    return "/Game/WwiseAudio/iOS/" .. bankName
  else
    return "/Game/WwiseAudio/Android/" .. bankName
  end
end
function ActorVoiceSystem.CheckVoiceRegionByCfg(actorCfg)
  if not actorCfg then
    return false
  end
  local publishID = ActorVoiceSystem.GetVoicePublishGameID()
  local regionID = FuncUtil.GetAccountRegionForBP()
  if actorCfg.OpenPublish and actorCfg.OpenPublish ~= "" and not string.find(actorCfg.OpenPublish, publishID) then
    return false
  end
  if actorCfg.IsLimitRegion and actorCfg.OpenRegion ~= "" and not string.find(actorCfg.OpenRegion, regionID) then
    return false
  end
  return true
end
function ActorVoiceSystem.GetAssociateBankPathListByActorID(actorID)
  local bankName
  local cfg = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if cfg and cfg.BankName then
    bankName = cfg.BankName
  end
  if not bankName then
    return nil
  end
  local StringUtil = require("common.string_util")
  bankName = StringUtil.Split(bankName, "|")[1]
  local fullBankPath = ActorVoiceSystem.GetFullBankPathByBankName(bankName)
  if not fullBankPath then
    return nil
  end
  local bankPathList = {}
  table.insert(bankPathList, fullBankPath)
  if cfg.IsMultiLanguage == 1 and cfg.MultiLanguageActorIDList then
    local multiLanguageActorIDList = StringUtil.Split(cfg.MultiLanguageActorIDList, "|")
    if multiLanguageActorIDList and next(multiLanguageActorIDList) then
      for _, actorIDStr in pairs(multiLanguageActorIDList) do
        local associateActorID = tonumber(actorIDStr)
        if associateActorID then
          local associateCfg = CDataTable.GetTableData("VoiceActorCfg", associateActorID)
          if associateCfg and associateCfg.BankName and ActorVoiceSystem.CheckVoiceRegionByCfg(associateCfg) then
            local associateBankName = StringUtil.Split(associateCfg.BankName, "|")[1]
            local associateBankPath = ActorVoiceSystem.GetFullBankPathByBankName(associateBankName)
            if associateBankPath then
              table.insert(bankPathList, associateBankPath)
            end
          end
        end
      end
    end
  end
  return bankPathList
end
function ActorVoiceSystem.GetAssociateBankNameListByActorID(actorID)
  local bankName
  local cfg = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if cfg and cfg.BankName then
    bankName = cfg.BankName
  end
  if not bankName then
    return nil
  end
  local StringUtil = require("common.string_util")
  bankName = StringUtil.Split(bankName, "|")[1]
  local bankNameList = {}
  table.insert(bankNameList, bankName)
  if cfg.IsMultiLanguage == 1 and cfg.MultiLanguageActorIDList then
    local multiLanguageActorIDList = StringUtil.Split(cfg.MultiLanguageActorIDList, "|")
    if multiLanguageActorIDList and next(multiLanguageActorIDList) then
      for _, actorIDStr in pairs(multiLanguageActorIDList) do
        local associateActorID = tonumber(actorIDStr)
        if associateActorID then
          local associateCfg = CDataTable.GetTableData("VoiceActorCfg", associateActorID)
          if associateCfg and associateCfg.BankName and ActorVoiceSystem.CheckVoiceRegionByCfg(associateCfg) then
            local associateBankName = StringUtil.Split(associateCfg.BankName, "|")[1]
            table.insert(bankNameList, associateBankName)
          end
        end
      end
    end
  end
  return bankNameList
end
function ActorVoiceSystem.PlaySound(key, worldContextObject, bKeepPreviousSound)
  log(bWriteLog and "[debug] ActorVoiceSystem.PlaySound key: " .. tostring(key))
  if not bKeepPreviousSound then
    ActorVoiceSystem.StopSound()
  end
  local actorID = ActorVoiceSystem.GetActorIDByKey(key)
  local voiceID = ActorVoiceSystem.GetVoiceIDByKey(key)
  local eventName = "play_chat_" .. tostring(actorID) .. "_" .. tostring(voiceID)
  local voiceActorData = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if voiceActorData then
    log(bWriteLog and "[tinghaohu]ActorVoiceSystem.PlaySound. eventName = " .. tostring(eventName) .. ", bankName = " .. tostring(voiceActorData.BankName))
    LoadedBankMap[voiceActorData.BankName] = true
    local audio_util = require("client.common.audio_util")
    voiceSoundID = audio_util.PlaySound(eventName, voiceActorData.BankName, worldContextObject)
    log(bWriteLog and "[tinghaohu]ActorVoiceSystem.PlaySound util.PlaySound return " .. tostring(voiceSoundID))
  end
end
function ActorVoiceSystem.PlayHousekeeperVoice(itemId, worldContextObject, bKeepPreviousSound)
  log(bWriteLog and " ActorVoiceSystem.PlayHousekeeperVoice " .. tostring(itemId))
  if not bKeepPreviousSound then
    ActorVoiceSystem.StopSound()
  end
  local hkpVoiceCfg = CDataTable.GetTableData("HousekeeperVoiceCfg", itemId)
  if not hkpVoiceCfg then
    return
  end
  log(bWriteLog and "ActorVoiceSystem.PlayHousekeeperVoice " .. tostring(hkpVoiceCfg.EventName) .. ", bankName = " .. tostring(hkpVoiceCfg.BankName))
  LoadedBankMap[hkpVoiceCfg.BankName] = true
  local audio_util = require("client.common.audio_util")
  voiceSoundID = audio_util.PlaySound(hkpVoiceCfg.EventName, hkpVoiceCfg.BankName, worldContextObject, true)
end
function ActorVoiceSystem.PlayMultiLanguageSound(key, worldContextObject, bNeedDownload)
  log(bWriteLog and "ActorVoiceSystem.PlayMultiLanguageSound key: " .. tostring(key))
  if not LobbySystem.CheckOpen(BP_ENUM_MULTI_LANGUAGE_SOUND_SWITCH) then
    log(bWriteLog and "PlayMultiLanguageSound close")
    ActorVoiceSystem.PlaySound(key, worldContextObject)
    return
  end
  local actorID = ActorVoiceSystem.GetActorIDByKey(key)
  local voiceActorData = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if not voiceActorData then
    log(bWriteLog and "PlayMultiLanguageSound no voiceActorData")
    return
  end
  if voiceActorData.IsMultiLanguage ~= 1 then
    log(bWriteLog and "PlayMultiLanguageSound IsMultiLanguage false")
    ActorVoiceSystem.PlaySound(key, worldContextObject)
    return
  end
  local voiceID = ActorVoiceSystem.GetVoiceIDByKey(key)
  local bIsLoopPlay, nMapActorId, nLoopPlayIndex = ActorVoiceSystem.GetIsMultiLanguageLoopPlay(actorID, voiceID)
  if not bIsLoopPlay then
    local language = Client.GetCurrentLanguage()
    local actorKey = tostring(actorID) .. "_" .. language
    local multiLanguageActorCfg = CDataTable.GetTableData("MultiLanguageActor", actorKey)
    if not multiLanguageActorCfg or not multiLanguageActorCfg.ActorID then
      log(bWriteLog and "PlayMultiLanguageSound no multiLanguageActorCfg:" .. actorKey)
      ActorVoiceSystem.PlaySound(key, worldContextObject)
      return
    end
    nMapActorId = multiLanguageActorCfg.ActorID
  end
  if not nMapActorId then
    log(bWriteLog and "PlayMultiLanguageSound no nMapActorId")
    ActorVoiceSystem.PlaySound(key, worldContextObject)
    return
  end
  local voiceActorDataForMultiLanguage = CDataTable.GetTableData("VoiceActorCfg", nMapActorId)
  if not voiceActorDataForMultiLanguage then
    log(bWriteLog and "PlayMultiLanguageSound no voiceActorDataForMultiLanguage")
    ActorVoiceSystem.PlaySound(key, worldContextObject)
    return
  end
  local multiLanguageBankName = voiceActorDataForMultiLanguage.BankName
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local exist = PufferManager.IsBankExist(multiLanguageBankName)
  if not exist then
    log(bWriteLog and "PlayMultiLanguageSound pak not exist")
    ActorVoiceSystem.PlaySound(key, worldContextObject)
    if bNeedDownload ~= false then
      PufferManager.DownBankPak(multiLanguageBankName)
    end
    return
  end
  ActorVoiceSystem.StopSound()
  local eventName = string.format("play_chat_%s_%s", nMapActorId, tostring(voiceID))
  log(bWriteLog and "PlayMultiLanguageSound eventName = " .. tostring(eventName) .. ", bankName = " .. tostring(multiLanguageBankName))
  if bIsLoopPlay then
    ActorVoiceSystem.SaveMultiLugShowIndex(actorID, voiceID, nLoopPlayIndex)
  end
  LoadedBankMap[multiLanguageBankName] = true
  local audio_util = require("client.common.audio_util")
  voiceSoundID = audio_util.PlaySound(eventName, multiLanguageBankName, worldContextObject)
end
function ActorVoiceSystem.GetAssociateItemIDByActorIDList(actorID)
  if not actorID then
    return nil
  end
  local cfg = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if not (cfg and cfg.ActorItemID) or cfg.ActorItemID == 0 then
    log(bWriteLog and "Invalid VoiceActorCfg, either cfg or cfg.ActorItemCfg is not config for actorID: " .. actorID)
    return nil
  end
  local result = {
    cfg.ActorItemID
  }
  if cfg.IsMultiLanguage == 1 and cfg.MultiLanguageActorIDList then
    local StringUtil = require("common.string_util")
    local multiLanguageActorIDList = StringUtil.Split(cfg.MultiLanguageActorIDList, "|")
    if multiLanguageActorIDList and next(multiLanguageActorIDList) then
      for _, actorIDStr in pairs(multiLanguageActorIDList) do
        local associateActorID = tonumber(actorIDStr)
        if associateActorID then
          local associateCfg = CDataTable.GetTableData("VoiceActorCfg", associateActorID)
          if associateCfg and associateCfg.ActorItemID and associateCfg.ActorItemID ~= 0 and ActorVoiceSystem.CheckVoiceRegionByCfg(associateCfg) then
            table.insert(result, associateCfg.ActorItemID)
          end
        end
      end
    end
  end
  log_tree("GetAssociateItemIDByActorIDList for actorID: " .. actorID, result)
  return result
end
function ActorVoiceSystem.ReleaseAllLoadedBank()
  log(bWriteLog and "ActorVoiceSystem.ReleaseAllLoadedBank")
  local AkGameplayStatics = import("AkGameplayStatics")
  for bankName, _ in pairs(LoadedBankMap) do
    if bankName ~= "A0_English" then
      AkGameplayStatics.UnloadBankByName(bankName)
    end
  end
  LoadedBankMap = {}
end
function ActorVoiceSystem.StopSound()
  local audio_util = require("client.common.audio_util")
  audio_util.StopSound(voiceSoundID)
  voiceSoundID = 0
end
function ActorVoiceSystem.GetActorName(actorID)
  ActorVoiceSystem.CheckAndCacheSingleActorInfo(actorID)
  if ActorInfoList[actorID] then
    return ActorInfoList[actorID].ActorName
  end
  return ""
end
function ActorVoiceSystem:GetActorInfoList()
  ActorVoiceSystem.InitActorInfoFromTable()
  return ActorInfoList
end
function ActorVoiceSystem.GetActorsByName(searchInput, bQuickSign)
  log(bWriteLog and "[tinghaohu]ActorVoiceSystem.GetActorsByName. st = " .. tostring(searchInput))
  local ret = {}
  local list = ActorVoiceSystem.GetShowActors(bQuickSign)
  if not searchInput or searchInput == "" then
    return list
  end
  searchInput = string.upper(searchInput)
  for _, actorInfo in pairs(list) do
    if string.find(string.upper(actorInfo.ActorName), searchInput) then
      table.insert(ret, actorInfo)
    end
  end
  return ret
end
function ActorVoiceSystem.GetQuickSignListByVoiceType(actorID, voiceType)
  if not actorID or actorID < 0 then
    return nil
  end
  local quickSignList = {}
  local QuickSignDefaultVoiceTable = CDataTable.GetTableByFilter("QuickSignDefaultVoice", "VoiceType", voiceType)
  if QuickSignDefaultVoiceTable then
    for _, v in pairs(QuickSignDefaultVoiceTable) do
      local cloneData = ActorVoiceSystem.GetAndCacheOneActorQuickSignWithType(actorID, v.SubType)
      if cloneData and cloneData.Key then
        table.insert(quickSignList, cloneData)
      end
    end
  end
  return quickSignList
end
function ActorVoiceSystem.GetQuickSignItemBySignType(actorID, signType)
  if quickSignCfgWithSignType[actorID] and quickSignCfgWithSignType[actorID][signType] then
    return quickSignCfgWithSignType[actorID][signType]
  end
  local SingleSignTItem = ActorVoiceSystem.GetAndCacheOneActorQuickSignWithType(actorID, signType)
  return SingleSignTItem or {}
end
function ActorVoiceSystem.SetCurrentGameResultRank(resultRank)
  log(bWriteLog and "[tinghaohu]ActorVoiceSystem.SetCurrentGameResultRank. resultRank = " .. tostring(resultRank))
  ActorVoiceSystem.PlayerCurGameResultRank = resultRank or -1
end
function ActorVoiceSystem.CheckAndShowLobbyActorVoiceUI(preStatus)
  log(bWriteLog and "[Voice] ActorVoiceSystem.CheckAndShowLobbyActorVoiceUI")
  local voiceID, voicePlayCD
  local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
  if preStatus == GameStatus.Login and (not LogicDisplaySetting.ShowEnterPlayVoice() or not ActorVoiceSystem.bIsGotPlanData) then
    log(bWriteLog and "[Voice] ActorVoiceSystem.CheckAndShowLobbyActorVoiceUI IsShowMainActorVoiceUI preStatus == GameStatus.Login and not LogicDisplaySetting.ShowEnterPlayVoice()")
    return
  end
  log(bWriteLog and "[tinghaohu]ActorVoiceSystem.CheckAndShowLobbyActorVoiceUI. preStatus = " .. tostring(preStatus))
  if LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH_V2) then
    if preStatus == GameStatus.Login then
      if not isInited then
        log(bWriteLog and "ActorVoiceSystem.CheckAndShowLobbyActorVoiceUI ActorVoiceSystem not inited")
        return
      end
      voiceID = ActorVoiceSystem.GetCurrentFeatureVoiceKey(ActorVoiceSystem.ENUM_FEATURE_CATEGORY.WELCOME)
      voiceID = ActorVoiceSystem.GetFestivalWelcomeVoiceKey(voiceID)
      voicePlayCD = ActorVoiceSystem.GetVoiceTimeByKey(voiceID)
      ActorVoiceSystem.hasPlayedWelcomeVoice = true
    elseif preStatus == GameStatus.Fighting and ActorVoiceSystem.PlayerCurGameResultRank == 1 then
      voiceID = ActorVoiceSystem.GetCurrentFeatureVoiceKey(ActorVoiceSystem.ENUM_FEATURE_CATEGORY.PRAISE)
      voicePlayCD = ActorVoiceSystem.GetVoiceTimeByKey(voiceID)
      if not voiceID or voiceID == 0 then
        voiceID = ActorVoiceSystem.GetPraiseVoiceKeyForTeammate(ActorVoiceSystem.ENUM_FEATURE_CATEGORY.PRAISE)
        voicePlayCD = ActorVoiceSystem.GetVoiceTimeByKey(voiceID)
      end
    end
  elseif LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH) then
    if preStatus == GameStatus.Login and not LogicDisplaySetting.ShowEnterPlayVoice() then
      return
    end
    log(bWriteLog and "[tinghaohu]ActorVoiceSystem.CheckAndShowLobbyActorVoiceUI. ActorVoiceSystem.PlayerCurVoiceEnterPlayID = " .. tostring(ActorVoiceSystem.PlayerCurVoiceEnterPlayID))
    if ActorVoiceSystem.PlayerCurVoiceEnterPlayID == -1 or not ActorVoiceSystem.CheckIsActorValid(ActorVoiceSystem.PlayerCurVoiceEnterPlayID) then
      return
    end
    local actorFeatureData = CDataTable.GetTableData("ActorVoiceFeatures", ActorVoiceSystem.PlayerCurVoiceEnterPlayID)
    if not actorFeatureData then
      return
    end
    if preStatus == GameStatus.Login then
      voiceID = actorFeatureData.WelcomeVoiceID
      voicePlayCD = actorFeatureData.WelcomeVoicePlayCD
    elseif preStatus == GameStatus.Fighting and ActorVoiceSystem.PlayerCurGameResultRank == 1 then
      voiceID = actorFeatureData.PraiseVoiceID
      voicePlayCD = actorFeatureData.PraiseVoicePlayCD
    end
  end
  log(bWriteLog and "ActorVoiceSystem.CheckAndShowLobbyActorVoiceUI result " .. tostring(voiceID) .. " " .. tostring(voicePlayCD))
  ActorVoiceSystem.SetCurrentGameResultRank(-1)
  if voiceID and voiceID ~= 0 and voicePlayCD then
    local voiceText = ActorVoiceSystem.GetVoiceDescByKey(voiceID)
    time_ticker.AddTimer(0.01, function()
      EventSystem:postEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_SHOW_LOBBY_UI, voiceID, voicePlayCD, voiceText)
    end)
  end
end
function ActorVoiceSystem.CheckAndShowTeamActorVoiceUI(memberInfo, isLeader)
  if ActorVoiceSystem.IsShowMainActorVoiceUI == false then
    log(bWriteLog and "ActorVoiceSystem.CheckAndShowTeamActorVoiceUI IsShowMainActorVoiceUI == false")
    return
  end
  local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
  if not LogicDisplaySetting.ShowEnterPlayVoice() then
    log(bWriteLog and "ActorVoiceSystem.CheckAndShowTeamActorVoiceUI not LogicDisplaySetting.ShowEnterPlayVoice()")
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "ActorVoiceSystem.CheckAndShowTeamActorVoiceUI not in lobby or main city")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "ActorVoiceSystem.CheckAndShowTeamActorVoiceUI LogicTxMissionMain.IsInXMission()")
    return
  end
  local voiceID, voicePlayCD
  if LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH_V2) then
    log(bWriteLog and "ActorVoiceSystem.CheckAndShowTeamActorVoiceUI BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH_V2 is open")
    local featureMap = memberInfo and memberInfo.ext_feature_msgs
    if not featureMap then
      log(bWriteLog and "ActorVoiceSystem.CheckAndShowTeamActorVoiceUI memberInfo.ext_feature_msgs is nil")
      return
    end
    local featureSubMap = isLeader and featureMap[ActorVoiceSystem.ENUM_FEATURE_CATEGORY.LEADER] or featureMap[ActorVoiceSystem.ENUM_FEATURE_CATEGORY.MEMBER]
    if not featureSubMap then
      log(bWriteLog and "ActorVoiceSystem.CheckAndShowTeamActorVoiceUI featureSubMap is nil")
      return
    end
    local featureSubList = {}
    for k, _ in pairs(featureSubMap) do
      if k then
        table.insert(featureSubList, k)
      end
    end
    if next(featureSubList) then
      voiceID = featureSubList[math.random(#featureSubList)]
      voicePlayCD = ActorVoiceSystem.GetVoiceTimeByKey(voiceID)
    end
  elseif LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH) then
    if memberInfo == nil or memberInfo.cur_dubber == nil or memberInfo.cur_dubber == -1 then
      return
    end
    log_tree("[tinghaohu]ActorVoiceSystem.CheckAndShowTeamActorVoiceUI memberInfo Tree, ", memberInfo)
    local actorFeatureData = CDataTable.GetTableData("ActorVoiceFeatures", memberInfo.cur_dubber)
    if not actorFeatureData then
      return
    end
    if isLeader then
      voiceID = actorFeatureData.LeaderVoiceID
      voicePlayCD = actorFeatureData.LeaderVoicePlayCD
    else
      voiceID = actorFeatureData.MemberVoiceID
      voicePlayCD = actorFeatureData.MemberVoicePlayCD
    end
  else
    return
  end
  if voiceID and voicePlayCD then
    ActorVoiceSystem.AddEnterTeamVoice(memberInfo.uid, memberInfo.name, voiceID, voicePlayCD + ACTOR_ENTER_TEAM_VOICE_CD_BUFFER)
  end
end
function ActorVoiceSystem.GetAndCacheOneActorQuickSignWithType(actorID, signType)
  if not actorID or actorID < 0 or not signType then
    log_warning(bWriteLog and "ActorVoiceSystem.GetAndCacheOneActorQuickSignWithType actorID or signType is invalid.")
    return nil
  end
  if not quickSignCfgWithSignType then
    quickSignCfgWithSignType = {}
  end
  if not quickSignCfgWithSignType[actorID] then
    quickSignCfgWithSignType[actorID] = {}
  end
  if quickSignCfgWithSignType[actorID][signType] then
    return quickSignCfgWithSignType[actorID][signType]
  end
  local signItemCfg = CDataTable.GetTableDataByFilter("QuickSignTable", "ActorID", actorID, "SignType", signType)
  if not signItemCfg then
    quickSignCfgWithSignType[actorID][signType] = {}
    return quickSignCfgWithSignType[actorID][signType]
  end
  local defaultVoiceCfg = CDataTable.GetTableData("QuickSignDefaultVoice", signType)
  if not defaultVoiceCfg then
    quickSignCfgWithSignType[actorID][signType] = {}
    return quickSignCfgWithSignType[actorID][signType]
  end
  local data = {}
  if signItemCfg.VoiceID == 0 then
    if actorID ~= 0 then
      local defaultActorWithSameSignType = ActorVoiceSystem.GetAndCacheOneActorQuickSignWithType(0, signType)
      data.Key = defaultActorWithSameSignType.Key
    else
      log_warning(bWriteLog and string.format("ActorVoiceSystem.GetAndCacheOneActorQuickSignWithType. key is invalid for actorID=%s, signType=%s", tostring(actorID), tostring(signType)))
      quickSignCfgWithSignType[actorID][signType] = {}
      return quickSignCfgWithSignType[actorID][signType]
    end
  else
    data.Key = actorID * VOICE_FRACTION + signItemCfg.VoiceID
  end
  data.SignType = signType
  data.DescID = defaultVoiceCfg.DescriptionID
  data.VoiceDescription = defaultVoiceCfg.VoiceDescription
  data.VoiceType = defaultVoiceCfg.VoiceType
  quickSignCfgWithSignType[actorID][signType] = data
  return quickSignCfgWithSignType[actorID][signType]
end
function ActorVoiceSystem.SaveSelectedFeatureVoiceMapToPrefs()
  if not SelectedFeatureVoiceMap then
    return
  end
  local result = {
    version = ActorVoiceSystem.FeatureVoiceMapVersion,
    data = {}
  }
  for k, v in pairs(SelectedFeatureVoiceMap) do
    result.data[k] = v
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(result, PlayerPrefsSystem.ePlayerPrefsType.eFeatureVoiceCfg)
end
function ActorVoiceSystem.InitFeatureCategoryInfo()
  log(bWriteLog and "[voice_cost] ActorVoiceSystem.InitFeatureCategoryInfo. Start")
  local StartTime = slua.getMiliseconds()
  if ActorVoiceSystem.FeatureCategoryID2BattleID then
    log(bWriteLog and string.format("[voice_cost] ActorVoiceSystem.InitFeatureCategoryInfo. End1 cost %fms", slua.getMiliseconds() - StartTime))
    return
  end
  ActorVoiceSystem.FeatureCategoryID2BattleID = {}
  local cfg = CDataTable.GetTable("FeatureUICfg")
  if cfg then
    local StringUtil = require("common.string_util")
    for k, v in pairs(cfg) do
      local index = tonumber(k)
      if index and v.BattleEventIDs and v.BattleEventIDs ~= "" then
        ActorVoiceSystem.FeatureCategoryID2BattleID[index] = {}
        local battleIDList = StringUtil.Split(v.BattleEventIDs, "|")
        for _, id in ipairs(battleIDList) do
          local strID = tostring(id)
          if strID and strID ~= "" then
            table.insert(ActorVoiceSystem.FeatureCategoryID2BattleID[index], strID)
          end
        end
      end
    end
  end
  log(bWriteLog and string.format("[voice_cost] ActorVoiceSystem.InitFeatureCategoryInfo. End2 cost: %fms", slua.getMiliseconds() - StartTime))
end
function ActorVoiceSystem.TransCurrentrFeatureVoiceCfg()
  if not ActorVoiceSystem.FeatureCategoryID2BattleID then
    ActorVoiceSystem.InitFeatureCategoryInfo()
  end
  local event2IDStrMap = {}
  local currentVoicePlanID = ActorVoiceSystem.PlayerCurVoicePlanID
  local currentPlanFeatureSubList = currentVoicePlanID and SelectedFeatureVoiceMap and SelectedFeatureVoiceMap[currentVoicePlanID]
  if currentPlanFeatureSubList and ActorVoiceSystem.FeatureCategoryID2BattleID then
    for categoryID, subCateoryList in pairs(ActorVoiceSystem.FeatureCategoryID2BattleID) do
      if currentPlanFeatureSubList[categoryID] then
        local currentCategoryList = currentPlanFeatureSubList[categoryID]
        local currentSettingList = {}
        for index = 1, #currentCategoryList do
          if currentCategoryList[index] and currentCategoryList[index] ~= 0 then
            table.insert(currentSettingList, currentCategoryList[index])
          end
        end
        local idStr = table.concat(currentSettingList, "|")
        for _, vv in ipairs(subCateoryList) do
          event2IDStrMap[vv] = idStr
        end
      end
    end
  end
  return event2IDStrMap
end
function ActorVoiceSystem.GetCurrentFeatureVoiceKey(featureCategory)
  if not featureCategory then
    return nil
  end
  local planID = ActorVoiceSystem.PlayerCurVoicePlanID or 1
  local voiceMap = SelectedFeatureVoiceMap[planID] or SelectedFeatureVoiceMap[1]
  if not voiceMap then
    return nil
  end
  local voiceCateoryList = voiceMap[featureCategory]
  if voiceCateoryList and next(voiceCateoryList) then
    return voiceCateoryList[math.random(#voiceCateoryList)]
  end
  return nil
end
function ActorVoiceSystem.GetFestivalWelcomeVoiceKey(originKey)
  if not originKey then
    return nil
  end
  if not LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH_V2) then
    return originKey
  end
  local items = ActorVoiceSystem.GetWelcomeVoiceMapListByOrigKey(originKey)
  if not items then
    return originKey
  end
  local cfgs = {}
  for k, v in pairs(items) do
    table.insert(cfgs, v)
  end
  if not next(cfgs) then
    return originKey
  end
  table.sort(cfgs, function(a, b)
    return a.Priority > b.Priority
  end)
  local TimeUtil = require("client.common.time_util")
  local timeNow = TimeUtil.GetServerTimeInSec()
  for i, v in ipairs(cfgs) do
    if v.StartTime and v.EndTime then
      local startTime = TimeUtil.TimeStringToUnixstamp(v.StartTime, true)
      local endTime = TimeUtil.TimeStringToUnixstamp(v.EndTime, true)
      if timeNow >= startTime and timeNow < endTime then
        log(bWriteLog and "[Voice] ActorVoiceSystem.GetFestivalWelcomeVoiceKey originKey: " .. tostring(originKey) .. " targetKey: " .. tostring(v.TargetVoiceKey or originKey))
        return v.TargetVoiceKey or originKey
      end
    end
  end
  log(bWriteLog and "[Voice] ActorVoiceSystem.GetFestivalWelcomeVoiceKey return origKey as default, result: " .. tostring(originKey))
  return originKey
end
function ActorVoiceSystem.GetVoiceTimeByKey(voiceKey)
  if not voiceKey then
    return ActorVoiceSystem.DEFAULT_VOICE_TIME
  end
  local voiceData = CDataTable.GetTableData("VoiceIDCfg", voiceKey)
  if voiceData and voiceData.VoiceTime and voiceData.VoiceTime > 0 then
    return voiceData.VoiceTime
  end
  return ActorVoiceSystem.DEFAULT_VOICE_TIME
end
function ActorVoiceSystem.CheckWelcomeVoice()
  if not ActorVoiceSystem.hasPlayedWelcomeVoice then
    ActorVoiceSystem.CheckAndShowLobbyActorVoiceUI(GameStatus.Login)
  end
end
function ActorVoiceSystem.GetActorCollectTS(ActorID)
  return ActorID and ActorCollectInfo and ActorCollectInfo[ActorID]
end
function ActorVoiceSystem.ReqChangeCollectInfo(ActorID)
  local ActorVoiceHandler = require("client.network.Protocol.ActorVoiceHandler")
  local CollectTS = ActorVoiceSystem.GetActorCollectTS(ActorID)
  ActorVoiceHandler.send_change_dubber_collect_data_req(ActorID, CollectTS and 2 or 1)
end
function ActorVoiceSystem.OnRspActorCollectInfo(ActorID, bCollect, CollectTime)
  if not ActorID then
    return
  end
  if not ActorCollectInfo then
    ActorCollectInfo = {}
  end
  if bCollect then
    ActorCollectInfo[ActorID] = CollectTime
  else
    ActorCollectInfo[ActorID] = nil
  end
  EventSystem:postEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_COLLECT_STATE_CHANGE, ActorID, bCollect)
end
function ActorVoiceSystem.InitSingleActorInfoFromTable(actorID)
  if not actorID then
    return
  end
  local publishID = ActorVoiceSystem.GetVoicePublishGameID()
  local regionID = FuncUtil.GetAccountRegionForBP()
  local voiceCfg = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if not voiceCfg then
    return
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  ActorVoiceSystem.InitSingleActorInfoFromTableInternal(actorID, voiceCfg, false, publishID, regionID, curTime)
end
local Voice_Pack = ENUM_ITEM_TYPE.Voice_Pack
function ActorVoiceSystem.InitSingleActorInfoFromTableInternal(actorID, voiceCfg, ignoreTime, publishID, regionID, curTime)
  if not actorID or not voiceCfg then
    return
  end
  if ProcessedActorIDs[actorID] then
    return
  end
  local ActorID = voiceCfg.ActorID
  local ActorItemID = voiceCfg.ActorItemID
  local openRegion = voiceCfg.OpenRegion
  local openPublish = voiceCfg.OpenPublish
  ItemIDToActorIDList[ActorItemID] = ActorID
  ProcessedActorIDs[actorID] = true
  local ctx = ActorVoiceSystem.InitActorInfoFromTable_BatchCtx
  if ActorID == 31 then
    local bVictorMenuOpen = ctx and ctx.bVictorMenuOpen or LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_CHARACTER)
    if not bVictorMenuOpen then
      return
    end
  end
  if openRegion ~= "" and openRegion ~= regionID then
    return
  end
  if openPublish ~= "" and string.find(openPublish, publishID, 1, true) == nil then
    return
  end
  if not ignoreTime then
    local OpenTimestamp = voiceCfg.OpenTimestamp
    if OpenTimestamp and 0 < OpenTimestamp then
      OpenTimestamp = OpenTimestamp * 60
      if curTime < OpenTimestamp then
        return
      end
    end
  end
  if ActorItemID ~= 0 then
    local uItemCfg = CDataTable.GetTableData("Item", ActorItemID)
    if uItemCfg and uItemCfg.ItemType ~= Voice_Pack then
      local bIsDev = ctx and ctx.bIsDev
      if bIsDev == nil then
        bIsDev = Client and Client.IsDevelopment()
      end
      if bIsDev and openPublish ~= "0" then
        log(bWriteLog and "ActorVoiceSystem.InitSingleActorInfoFromTableInternal >>> Check VoiceActorCfg Error >>>> ActorID:" .. tostring(actorID))
        local utility = require("common.utility")
        local sMsg = "ActorVoiceSystem The non-voice package configuration area is incorrectly configured. ActorID:" .. tostring(actorID)
        utility.ErrorMessageHandlerExtra(sMsg, nil, sMsg)
      end
      return
    end
  end
  ActorInfoList[ActorID] = voiceCfg
end
function ActorVoiceSystem.CheckAndCacheSingleActorInfo(actorID)
  if not actorID then
    return
  end
  if ProcessedActorIDs[actorID] then
    return
  end
  ActorVoiceSystem.InitSingleActorInfoFromTable(actorID)
  ProcessedActorIDs[actorID] = true
end
function ActorVoiceSystem.CheckAndCacheSingleActorInfoByItemID(itemID)
  if not itemID then
    return
  end
  if ItemIDToActorIDList[itemID] ~= nil then
    return
  end
  ItemIDToActorIDList[itemID] = -1
  local voiceCfg = CDataTable.GetTableDataByFilter("VoiceActorCfg", "ActorItemID", itemID)
  if voiceCfg and voiceCfg.ActorID ~= 0 then
    ActorVoiceSystem.InitSingleActorInfoFromTable(voiceCfg.ActorID)
  end
end
function ActorVoiceSystem.GetVoiceExpireDisplay(voiceKey)
  local actorID = ActorVoiceSystem.GetActorIDByKey(voiceKey)
  local actorData = OwnActorList[actorID]
  local actorVoiceData = OwnActorVoiceList[voiceKey]
  if actorVoiceData == nil then
    if actorData == nil then
      return ActorVoiceSystem.ENUM_UNLOCK_TYPE.LOCK, nil
    elseif actorData.expireTime then
      return ActorVoiceSystem.ENUM_UNLOCK_TYPE.LIMIT, actorData.expireTime
    else
      return ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT, nil
    end
  elseif actorVoiceData.expireTime == nil then
    return ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT, nil
  elseif actorData then
    if actorData.expireTime then
      return ActorVoiceSystem.ENUM_UNLOCK_TYPE.LIMIT, math.max(actorVoiceData.expireTime, actorData.expireTime)
    else
      return ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT, nil
    end
  else
    return ActorVoiceSystem.ENUM_UNLOCK_TYPE.LIMIT, actorVoiceData.expireTime
  end
end
function ActorVoiceSystem.GetActorExpireDisplay(actorID)
  local actorDisplayData = ActorExpireDisplayList[actorID]
  if actorDisplayData then
    return actorDisplayData.unlockType, actorDisplayData.expireTime
  end
  return ActorVoiceSystem.ENUM_UNLOCK_TYPE.LOCK, nil
end
function ActorVoiceSystem.RefreshActorExpireDisplayAll()
  for actorID, actorData in pairs(OwnActorList) do
    ActorExpireDisplayList[actorID] = {
      unlockType = actorData.expireTime and ActorVoiceSystem.ENUM_UNLOCK_TYPE.LIMIT or ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT,
      expireTime = actorData.expireTime
    }
  end
  for key, actorVoiceData in pairs(OwnActorVoiceList) do
    local actorID = ActorVoiceSystem.GetActorIDByKey(key)
    if OwnActorList[actorID] == nil then
      local expireTime = actorVoiceData.expireTime
      if ActorExpireDisplayList[actorID] == nil then
        ActorExpireDisplayList[actorID] = {
          unlockType = expireTime and ActorVoiceSystem.ENUM_UNLOCK_TYPE.LIMIT or ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT,
          expireTime = nil
        }
      elseif expireTime == nil then
        ActorExpireDisplayList[actorID].unlockType = ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT
        ActorExpireDisplayList[actorID].expireTime = nil
      end
    end
  end
end
function ActorVoiceSystem.RefreshActorExpireDisplayByActor(dubber, dubber_expire)
  if dubber == nil or next(dubber) == nil then
    return
  end
  dubber_expire = dubber_expire or {}
  for actorID, _ in pairs(dubber) do
    ActorExpireDisplayList[actorID] = {
      unlockType = dubber_expire[actorID] and ActorVoiceSystem.ENUM_UNLOCK_TYPE.LIMIT or ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT,
      expireTime = dubber_expire[actorID]
    }
  end
end
function ActorVoiceSystem.RefreshActorExpireDisplayByActorVoice(own_msgs, msg_expire)
  if own_msgs == nil or next(own_msgs) == nil then
    return
  end
  msg_expire = msg_expire or {}
  for key, _ in pairs(own_msgs) do
    local actorID = ActorVoiceSystem.GetActorIDByKey(key)
    if OwnActorList[actorID] == nil then
      local expireTime = msg_expire[key]
      if ActorExpireDisplayList[actorID] == nil then
        ActorExpireDisplayList[actorID] = {
          unlockType = expireTime and ActorVoiceSystem.ENUM_UNLOCK_TYPE.LIMIT or ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT,
          expireTime = nil
        }
      elseif expireTime == nil then
        ActorExpireDisplayList[actorID].unlockType = ActorVoiceSystem.ENUM_UNLOCK_TYPE.PERMANENT
        ActorExpireDisplayList[actorID].expireTime = nil
      end
    end
  end
end
function ActorVoiceSystem.SaveCurrentPlanSelectFeatureVoice2Config()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  if settingConfig.PlayerFeatureVoiceCfg then
    local currentFeatureVoiceCfg = ActorVoiceSystem.TransCurrentrFeatureVoiceCfg()
    settingConfig.PlayerFeatureVoiceCfg:Clear()
    for k, v in pairs(currentFeatureVoiceCfg) do
      if v and v ~= "" then
        settingConfig.PlayerFeatureVoiceCfg:Add(k, v)
      end
    end
  end
end
function ActorVoiceSystem.GetPraiseVoiceKeyForTeammate(voiceType)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  for uid, memberInfo in pairs(TeamUpNewSystem.teamInfo.members) do
    local featureMap = memberInfo and memberInfo.ext_feature_msgs
    if featureMap then
      local featureSubMap = featureMap[voiceType]
      if featureSubMap then
        local featureSubList = {}
        for k, _ in pairs(featureSubMap) do
          if k then
            table.insert(featureSubList, k)
          end
        end
        if next(featureSubList) then
          return featureSubList[math.random(#featureSubList)]
        end
      end
    end
  end
end
function ActorVoiceSystem.AddEnterTeamVoice(uid, name, voiceKey, voiceCD)
  log(bWriteLog and "[debug][actor][voice] ActorVoiceSystem.AddEnterTeamVoice uid: " .. tostring(uid) .. " voiceKey: " .. tostring(voiceKey) .. " voiceCD: " .. tostring(voiceCD) .. " timestamp: " .. tostring(slua.getMiliseconds() / 1000))
  if not uid then
    log(bWriteLog and "ActorVoiceSystem.AddEnterTeamVoice uid is nil")
    return
  end
  if not voiceKey then
    log(bWriteLog and "ActorVoiceSystem.AddEnterTeamVoice voiceKey is nil")
    return
  end
  local ETeamVoiceStatus = ActorVoiceSystem.ETeamVoiceStatus
  for i, item in ipairs(ActorVoiceSystem.enterTeamVoiceQueue) do
    if item.uid == uid and item.key == voiceKey and item.status ~= ETeamVoiceStatus.Finished then
      log(bWriteLog and string.format("ActorVoiceSystem.AddEnterTeamVoice the same item is already in queue, uid: %u, voiceKey: %u", uid, voiceKey))
      return
    end
  end
  voiceCD = voiceCD or ActorVoiceSystem.GetVoiceTimeByKey(voiceKey)
  if not voiceCD then
    voiceCD = ActorVoiceSystem.DEFAULT_VOICE_TIME
    log(bWriteLog and "ActorVoiceSystem.AddEnterTeamVoice get voice cd failed, use default value - 5 seconds")
  end
  log(bWriteLog and "ActorVoiceSystem.AddEnterTeamVoice get key: " .. tostring(voiceKey) .. " CD: " .. tostring(voiceCD))
  table.insert(ActorVoiceSystem.enterTeamVoiceQueue, {
    uid = uid,
    name = name,
    key = voiceKey,
    CD = voiceCD,
    status = ActorVoiceSystem.ETeamVoiceStatus.NotPlayed
  })
  ActorVoiceSystem._CheckAndStartTeamVoiceQueue()
end
function ActorVoiceSystem._CheckAndStartTeamVoiceQueue()
  if ActorVoiceSystem.voiceQueueTimer then
    log(bWriteLog and "ActorVoiceSystem._CheckAndStartTeamVoiceQueue voiceQueueTimer has started ready, do not start it duplicate")
    return
  end
  if not next(ActorVoiceSystem.enterTeamVoiceQueue) then
    log(bWriteLog and "ActorVoiceSystem._CheckAndStartTeamVoiceQueue enterTeamVoiceQueue is empty")
    return
  end
  local voiceItem = ActorVoiceSystem.enterTeamVoiceQueue[1]
  voiceItem.CD = voiceItem.CD or ActorVoiceSystem.DEFAULT_VOICE_TIME
  ActorVoiceSystem._PlayTeamVoiceInner(voiceItem.name, voiceItem.key, voiceItem.CD)
  voiceItem.status = ActorVoiceSystem.ETeamVoiceStatus.Playing
  ActorVoiceSystem.voiceQueueTimer = time_ticker.AddTimerOnce(voiceItem.CD + ACTOR_ENTER_TEAM_VOICE_INTERVAL, function()
    table.remove(ActorVoiceSystem.enterTeamVoiceQueue, 1)
    ActorVoiceSystem.voiceQueueTimer = nil
    ActorVoiceSystem._CheckAndStartTeamVoiceQueue()
  end)
end
function ActorVoiceSystem._PlayTeamVoiceInner(name, key, CD)
  if not key or not CD then
    return
  end
  local voiceText = ActorVoiceSystem.GetVoiceDescByKey(key)
  if name and name ~= "" then
    voiceText = string.format("%s: %s", tostring(name), voiceText)
  end
  time_ticker.AddTimer(0.01, function()
    log(bWriteLog and "[debug][actor][voice] ActorVoiceSystem._PlayTeamVoiceInner voiceKey: " .. tostring(key) .. " voiceCD: " .. tostring(CD) .. " timestamp: " .. tostring(slua.getMiliseconds()) / 1000)
    EventSystem:postEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_SHOW_LOBBY_UI, key, CD, voiceText, true)
  end)
end
function ActorVoiceSystem.RemovePlayerTeamVoice(uid)
  local enterTeamVoiceQueue = ActorVoiceSystem.enterTeamVoiceQueue
  if not next(enterTeamVoiceQueue) then
    return
  end
  for i = #enterTeamVoiceQueue, 1, -1 do
    local voiceItem = enterTeamVoiceQueue[i]
    if uid == nil or voiceItem.uid == uid then
      table.remove(enterTeamVoiceQueue, i)
    end
  end
end
function ActorVoiceSystem.GetVoiceDefaultSetting(ParamName)
  local Cfg = CDataTable.GetTableData("VoiceDefaultSettingConfig", ParamName)
  return Cfg and Cfg.IntArray_a
end
function GetDescIDSignType(actorID, signType)
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  local item = ActorVoiceSystem.GetQuickSignItemBySignType(actorID, signType)
  if item then
    return item.DescID
  end
  return nil
end
function GetAudioIDSignType(actorID, signType)
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  local item = ActorVoiceSystem.GetQuickSignItemBySignType(actorID, signType)
  if item then
    local key = item.Key
    local audioID = math.fmod(key, VOICE_FRACTION)
    return audioID
  end
  return nil
end
function ActorVoiceSystem.JumpItemByID(eventType, eventID, vars)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local wardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if vars and vars.id then
    wardrobeLogicManager:Enter(wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute, wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quickmessage, vars.id)
  else
    wardrobeLogicManager:Enter(wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute, wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quickmessage)
  end
end
function ActorVoiceSystem.GetVoicePublishGameID()
  local publishID = FuncUtil.GetGamePublishID()
  if publishID == 1440 then
    return 1320
  end
  return publishID
end
function ActorVoiceSystem.GetVoiceMultiLugCacheKey(nActorId, nVoiceID)
  return nActorId .. "_" .. nVoiceID
end
function ActorVoiceSystem.GetIsMultiLanguageLoopPlay(nActorId, nVoiceID)
  local uObj_multiCfg = CDataTable.GetTableData("MultiLanguageLoopPlayCfg", nActorId)
  if not uObj_multiCfg or uObj_multiCfg.MultiLanguageAllActorID == "" then
    return false
  end
  local StringUtil = require("common.string_util")
  local tAllActorId = StringUtil.Split(uObj_multiCfg.MultiLanguageAllActorID, "|")
  local nShowActorCount = #tAllActorId
  if nShowActorCount <= 1 then
    return false
  end
  local sCacheKey = ActorVoiceSystem.GetVoiceMultiLugCacheKey(nActorId, nVoiceID)
  if not ActorVoiceSystem._tAllVoiceMultiLugShowIndex then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eVoiceMultiPlayIndex) or {}
    ActorVoiceSystem._tAllVoiceMultiLugShowIndex = tLocalCache
  end
  local nLastIndex = ActorVoiceSystem._tAllVoiceMultiLugShowIndex[sCacheKey] or 0
  local nShowIndex = nLastIndex + 1
  if nShowActorCount < nShowIndex then
    nShowIndex = 1
  end
  local nShowActorId = tAllActorId[nShowIndex]
  if not nShowActorId then
    return false
  end
  local uObj_voiceCfg = CDataTable.GetTableDataByFilter("VoiceIDCfg", "ActorID", tonumber(nShowActorId), "VoiceID", tonumber(nVoiceID))
  if not uObj_voiceCfg then
    return false
  end
  return true, nShowActorId, nShowIndex
end
function ActorVoiceSystem.SaveMultiLugShowIndex(nActorId, nVoiceID, nShowIndex)
  local sCacheKey = ActorVoiceSystem.GetVoiceMultiLugCacheKey(nActorId, nVoiceID)
  ActorVoiceSystem._tAllVoiceMultiLugShowIndex[sCacheKey] = nShowIndex
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(ActorVoiceSystem._tAllVoiceMultiLugShowIndex, PlayerPrefsSystem.ePlayerPrefsType.eVoiceMultiPlayIndex)
end
function ActorVoiceSystem.GetVoicePlanCount()
  return PLAYER_CHAT_VOICE_PLAN_COUNT
end
return ActorVoiceSystem