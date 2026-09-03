local local MatchModeMgrSystem = {
  modeInfoList = {},
  selectModeIDs = {},
  selectViewIDs = {},
  bAutoMatch = true,
  nSelectMatchID = 0,
  bIsMatchingTrainMode = false,
  nInGameModeID = 0,
  bIsMatchingSocialIsland = false,
  EnterSocialIslandReason = nil,
  subMode2ModeMap = nil
}
local StringUtil = require("common.string_util")
local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
local defaultModeToViewIdList
local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
local C_SocialIslandMatchMode = 321
local E_ModeFightType = {
  Normal = 0,
  Train = 1,
  Social = 2
}
MatchModeMgrSystem.
function MatchModeMgrSystem.OnModePreSwitch(preState, nextState)
  ClientEVOConfig.OnModePreSwitch(preState, nextState)
end
function MatchModeMgrSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "[edward][logic_mode_mgr] MatchModeMgrSystem.OnModePostSwitch, nextState = " .. tostring(nextState))
  if nextState == GameStatus.Login then
    MatchModeMgrSystem.SetInGameModeID(0)
  elseif nextState == GameStatus.Lobby then
    MatchModeMgrSystem.SetInGameModeID(0)
    MatchModeMgrSystem.bIsMatchingTrainMode = false
  end
  MatchModeMgrSystem.bIsMatchingSocialIsland = false
  ClientEVOConfig.OnModePostSwitch(preState, nextState)
end
function MatchModeMgrSystem.SetInGameModeID(sub_mode)
  if sub_mode then
    ClientEVOConfig.OnSetInGameModeID(sub_mode)
    log(bWriteLog and "xxxx MatchModeMgrSystem.SetInGameModeID " .. tostring(sub_mode))
    MatchModeMgrSystem.nLastInGameModeID = MatchModeMgrSystem.nInGameModeID
    MatchModeMgrSystem.nInGameModeID = sub_mode
  else
    MatchModeMgrSystem.nInGameModeID = 0
  end
  GameStatus.SetMatchInGameModeID(MatchModeMgrSystem.nInGameModeID)
  if slua.isValid(slua_GameFrontendHUD) then
    local GameInstance = slua.getGameInstance()
    if GameInstance then
      GameInstance:SetModeID(MatchModeMgrSystem.nInGameModeID)
      log(bWriteLog and "GetGameInstance.ModeID " .. tostring(MatchModeMgrSystem.nInGameModeID))
    end
  end
end
function MatchModeMgrSystem.IsSocialIslandMode(onlyCheckMode, bIsGameStatusInFighting)
  if not onlyCheckMode then
    if type(bIsGameStatusInFighting) == "nil" then
      if not GameStatus.IsInFightingStatus() then
        return false
      end
    elseif not bIsGameStatusInFighting then
      return false
    end
  end
  if IsEditor and slua.isValid(CGameState) and CGameState.bSocialIslandGameMode then
    return true
  end
  local modeID = MatchModeMgrSystem.nInGameModeID or 0
  local BTMode = CDataTable.GetTableData("BTMode", modeID)
  if BTMode and BTMode.ModeFightType then
    return BTMode.ModeFightType == E_ModeFightType.Social
  end
  return false
end
function MatchModeMgrSystem.IsSocialIslandModeID(modeID)
  modeID = modeID or 0
  local BTMode = CDataTable.GetTableData("BTMode", modeID)
  if BTMode and BTMode.ModeFightType then
    return BTMode.ModeFightType == E_ModeFightType.Social
  end
  return false
end
function MatchModeMgrSystem.IsSocialIslandMatchMode(matchMode)
  if not matchMode then
    return false
  end
  return matchMode == C_SocialIslandMatchMode
end
function MatchModeMgrSystem.IsClassicMatchMode(matchMode)
  return matchMode == 101 or matchMode == 102 or matchMode == 103 or matchMode == 401 or matchMode == 402 or matchMode == 403
end
function MatchModeMgrSystem.IsCreativeMode()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if LogicUGC:IsUGCGameMod() or LogicUGC:IsUGCEditMod() then
    return true
  end
  return false
end
function MatchModeMgrSystem.GetClassicModeWord(matchMode, subMode)
  if not matchMode then
    return ""
  end
  matchMode = tonumber(matchMode)
  if subMode and MatchModeMgrSystem.IsClassicMatchMode(matchMode) then
    local BTMode = CDataTable.GetTableData("BTMode", subMode)
    if BTMode and BTMode.SpWordsToShowID and BTMode.SpWordsToShowID > 0 then
      log(bWriteLog and "[edward] MatchModeMgrSystem.GetClassicModeWord BTMode.SpWordsToShowID = " .. BTMode.SpWordsToShowID)
      return LocUtil.GetLocalizeResStr(BTMode.SpWordsToShowID)
    end
  end
  local MatchModeTable = CDataTable.GetTableData("MatchModeTable", matchMode)
  if MatchModeTable then
    return LocUtil.GetLocalizeResStr(MatchModeTable.WordsToShowID)
  end
  return ""
end
function MatchModeMgrSystem.GetDefaultMatchID()
  log(bWriteLog and "[edward][logic_mode_mgr] GetDefaultMatchID")
  local matchConfig = CDataTable.GetTable("MatchModeTable")
  for k, v in pairs(matchConfig) do
    if v.DefaultChosen == 1 then
      return v.ID
    end
  end
  return 0
end
function MatchModeMgrSystem.GetMapKeyBySubMode(sub_mode)
  local mapKey
  local cfg = CDataTable.GetTableData("BTMode", sub_mode)
  if cfg then
    local mapID = cfg.MapID
    mapKey = CDataTable.GetTableData("Map", mapID).MapKey
  end
  return mapKey
end
function MatchModeMgrSystem.CheckDataBeforeMatch(matchID)
  local modeList = {}
  local viewList = {}
  local newViewList = {}
  for i, v in ipairs(MatchModeMgrSystem.selectModeIDs) do
    local info = MatchModeMgrSystem.modeInfoList[v]
    if info.nMatchID == matchID and info.bIsOpen then
      table.insert(modeList, v)
      table.insert(viewList, info.nViewID)
      table.insert(newViewList, info.nNewViewID)
    end
  end
  if #modeList == 0 then
    for k, v in pairs(MatchModeMgrSystem.modeInfoList) do
      if v.nMatchID == matchID and v.bIsOpen then
        table.insert(modeList, k)
        table.insert(viewList, v.nViewID)
        table.insert(newViewList, v.nNewViewID)
      end
    end
    log(bWriteLog and "god test my test self.selectModeIDs CheckDataBeforeMatch " .. tostring(#MatchModeMgrSystem.selectModeIDs))
    MatchModeMgrSystem.selectModeIDs = modeList
    MatchModeMgrSystem.selectViewIDs = viewList
  end
  return modeList
end
function MatchModeMgrSystem.SetAutoFill(autoMatch)
  MatchModeMgrSystem.bAutoMatch = autoMatch
end
function MatchModeMgrSystem.GetMapKeyBySubMode(sub_mode, ugc_map_id)
  local mapID = ugc_map_id
  if mapID == nil then
    local cfg = CDataTable.GetTableData("BTMode", sub_mode)
    if cfg then
      mapID = cfg.MapID
    end
  end
  if mapID then
    local mapInfo = CDataTable.GetTableData("Map", mapID)
    if mapInfo then
      return mapInfo.MapKey
    end
  end
  return nil
end
function MatchModeMgrSystem.GetMapNameBySubMode(sub_mode)
  local mapName
  local cfg = CDataTable.GetTableData("BTMode", sub_mode)
  if cfg then
    local mapID = cfg.MapID
    mapName = CDataTable.GetTableData("Map", mapID).ShowName
  end
  return mapName
end
function MatchModeMgrSystem.GetModeInfoBySubMode(subMode)
  if not subMode then
    log(bWriteLog and "[edward][logic_mode_mgr] MatchModeMgrSystem.GetModeInfoBySubMode, subMode = nil")
    return nil
  end
  log(bWriteLog and "[edward][logic_mode_mgr] GetModeInfoBySubMode, subMode = " .. subMode)
  if not MatchModeMgrSystem.subMode2ModeMap then
    MatchModeMgrSystem.subMode2ModeMap = {}
    local BTMode = CDataTable.GetTable("ModeTeamTable")
    for k, v in pairs(BTMode) do
      local SubModeIds = load("return" .. v.SubModeIds)()
      for _, subModeID in pairs(SubModeIds) do
        MatchModeMgrSystem.subMode2ModeMap[tonumber(subModeID)] = tonumber(k)
      end
    end
    if not MatchModeMgrSystem.subMode2ModeMap or not next(MatchModeMgrSystem.subMode2ModeMap) then
      log(bWriteLog and "[edward][logic_mode_mgr] MatchModeMgrSystem.GetModeInfoBySubMode, subMode2ModeMap = nil")
      return nil
    end
  end
  local modeID = MatchModeMgrSystem.subMode2ModeMap[subMode]
  if not modeID then
    log(bWriteLog and "[edward][logic_mode_mgr] MatchModeMgrSystem.GetModeInfoBySubMode, find no modeID")
    return nil
  end
  return nil, modeID
end
local _GetViewIdListByMode = function(defaultMode)
  log(bWriteLog and "[v_wllwu] MatchModeMgrSystem _GetViewIdListByMode, defaultMode is " .. tostring(defaultMode))
  if not defaultMode then
    log_error(bWriteLog and "[v_wllwu] MatchModeMgrSystem _GetViewIdListByMode defaultMode is nil")
    return
  end
  if defaultModeToViewIdList and defaultModeToViewIdList[defaultMode] then
    return defaultModeToViewIdList[defaultMode]
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewDict = logic_mode_selection:GetViewDictionary()
  if not viewDict or not next(viewDict) then
    return
  end
  local TableUtil = require("common.table_util")
  local viewIdList = {}
  for viewId, info in pairs(viewDict) do
    local teamType = TableUtil.GetTableValue(info, "options", "team_type")
    if teamType then
      for _, cfg in pairs(teamType) do
        for _, modeId in pairs(cfg) do
          if modeId == defaultMode then
            table.insert(viewIdList, modeId)
            break
          end
        end
      end
    end
  end
  if not defaultModeToViewIdList then
    defaultModeToViewIdList = {}
  end
  defaultModeToViewIdList[defaultMode] = viewIdList
  log_tree(bWriteLog and "[v_wllwu] MatchModeMgrSystem _GetViewIdListByMode viewIdList", viewIdList)
  return viewIdList
end
local _GetSelectMatchModeType = function()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local teamNum = TeamUpNewSystem.GetTeamNum()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode, _, __ = logic_mode_selection:GetCurSelectInfo()
  if matchMode ~= nil and teamNum <= 1 then
    return matchMode
  end
  local defaultMode = 201
  local viewIdList = _GetViewIdListByMode(defaultMode)
  if not viewIdList or #viewIdList <= 0 then
    return
  end
  if 1 < teamNum then
    return defaultMode
  else
    for _, viewId in pairs(viewIdList) do
      if logic_mode_selection:CheckSubViewIsOpen(viewId) then
        return defaultMode
      end
    end
  end
  return nil
end
function MatchModeMgrSystem.GetSelectModeType()
  local matchModeType = _GetSelectMatchModeType()
  log(bWriteLog and "[v_wllwu] MatchModeMgrSystem MatchModeMgrSystem.GetSelectModeType, matchModeType is " .. tostring(matchModeType))
  if not matchModeType then
    return 1
  end
  local matchConfig = CDataTable.GetTableData("MatchModeTable", matchModeType)
  if not matchConfig then
    return 1
  end
  local modeType = matchConfig.ModeType
  log(bWriteLog and "[v_wllwu] MatchModeMgrSystem MatchModeMgrSystem.GetSelectModeType, modeType is " .. tostring(modeType))
  return modeType
end
function MatchModeMgrSystem.ClearData()
  MatchModeMgrSystem.bIsMatchingSocialIsland = false
  MatchModeMgrSystem.subMode2ModeMap = nil
  defaultModeToViewIdList = nil
end
function MatchModeMgrSystem.SaveMatchMode(modeIDs, viewIDs, autoMatch, newViewIDs)
  log(bWriteLog and "[edward][logic_mode_mgr] SaveMatchMode, autoMatch = " .. tostring(autoMatch))
  MatchModeMgrSystem.bAutoMatch = autoMatch
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.team_change_fill_request(autoMatch and 1 or 0)
  log(bWriteLog and "god test my test viewIDs " .. tostring(#viewIDs))
  log_tree("[edward][logic_mode_mgr] SaveMatchMode, self.selectViewIDs", viewIDs)
  log_tree("[edward][logic_mode_mgr] SaveMatchMode, modeIDs", modeIDs)
  log(bWriteLog and "god test modeIDs~~~ " .. tostring(#modeIDs))
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_SYNC_MATCH_INFO)
  TeamUpNewSystem.ShowExtraTeamUI()
end
function MatchModeMgrSystem.SyncMatchModeEntry()
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_SYNC_MATCH_INFO)
end
function MatchModeMgrSystem.GetNewMatchModeData()
  local activityData, matchID, modeIDs, viewIDs, newViewIDs
  local   local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actList = ActivityNewSystem.GetActivityListByType(ActivityType.GAME_URI)
  for k, v in ipairs(actList) do
    if v.ShowSceneID == ActivitySceneID.None or v.ShowSceneID == ActivitySceneID.ActivityCenter then
      if string.find(v.ImgLink, "module=" .. BP_ENUM_MODULE_MATCH_MODE) or string.find(v.ImgLink, "module=" .. BP_ENUM_MODULE_MATCH_MODE_CHOOSE) then
        log(bWriteLog and "[edward][logic_mode_mgr] GetNewMatchModeData, jump to select mode, actID = " .. v.ID)
        activityData = v
        local paramList = StringUtil.Split(v.ImgLink, "&")
        for ii, vv in ipairs(paramList) do
          if string.find(vv, "matchID=") then
            matchID = tonumber(StringUtil.Split(vv, "=")[2])
          elseif string.find(vv, "modeIDs=") then
            modeIDs = StringUtil.Split(vv, "=")[2]
          elseif string.find(vv, "viewIDs=") then
            viewIDs = StringUtil.Split(vv, "=")[2]
          elseif string.find(vv, "newViewIDs=") then
            newViewIDs = StringUtil.Split(vv, "=")[2]
          end
        end
        break
      elseif string.find(v.ImgLink, "module=" .. BP_ENUM_MODULE_ARENA) then
        log(bWriteLog and "MatchModeMgrSystem.GetNewMatchModeData, actID = " .. v.ID)
        activityData = v
        break
      elseif BP_Platform ~= BP_ENUM_PLAYFORM_TOURIST and string.find(v.ImgLink, "module=" .. BP_ENUM_MODULE_TXMISSION_LOBBY_FROM_JUMP) then
        log(bWriteLog and "MatchModeMgrSystem.GetNewMatchModeData, actID = " .. v.ID)
        activityData = v
        break
      elseif string.find(v.ImgLink, "module=" .. BP_ENUM_MODULE_GODZILLA_BIGEVENTG) or string.find(v.ImgLink, "module=") or string.find(v.ImgLink, "faceSlap=") then
        activityData = v
        break
      end
    end
  end
  if modeIDs then
    modeIDs = StringUtil.Split(modeIDs, "|")
    for i, v in ipairs(modeIDs) do
      modeIDs[i] = tonumber(v)
    end
  end
  if viewIDs then
    viewIDs = StringUtil.Split(viewIDs, "|")
    for i, v in ipairs(viewIDs) do
      viewIDs[i] = tonumber(v)
    end
  end
  if newViewIDs then
    newViewIDs = StringUtil.Split(newViewIDs, "|")
    for i, v in ipairs(newViewIDs) do
      newViewIDs[i] = tonumber(v)
    end
  end
  return activityData, matchID, modeIDs, viewIDs, newViewIDs
end
function MatchModeMgrSystem.OnSyncSegmentProtectShield(shield_info)
  if not shield_info or type(shield_info) ~= "table" then
    return
  end
  DataMgr.roleData.segment_protect_end
function MatchModeMgrSystem.HaveWarmUpRedDot()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local warmUpActData = ActivityNewSystem.GetActivityBySceneID(ActivitySceneID.WarmUpMatch)
  if warmUpActData and warmUpActData.List then
    for i, v in ipairs(warmUpActData.List) do
      if v.Status == ActivityProgressStatus.Done then
        return true
      end
    end
  end
  return false
end
function MatchModeMgrSystem.EnterSingleTraining()
  log(bWriteLog and "MatchModeMgrSystem.EnterSingleTraining")
  if LobbySystem.isInMatch then
    ShowNotice(9938)
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInLargeTeam() then
    ShowNotice(27571)
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSelect8PlayersMode() then
    ShowNotice(27572)
    return false
  end
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  if not SocialIslandHandler.HaveDownloadSingleTraining() then
    return false
  end
  EventIngameEnterSingleTraining()
  return true
end
function MatchModeMgrSystem.IsInPlanZMode()
  if not GameStatus.IsInFightingStatus() then
    return false
  end
  local modeID = MatchModeMgrSystem.nInGameModeID
  if modeID and modeID == 26001 then
    return true
  else
    if IsEditor then
      local mapName = CGame:GetMapName()
      if mapName == "PlanZ_Main" then
        return true
      end
    end
    return false
  end
end
return MatchModeMgrSystem