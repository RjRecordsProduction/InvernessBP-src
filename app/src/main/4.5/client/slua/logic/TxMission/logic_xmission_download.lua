local LogicTxMissionDownload = {
  BASE_MAP_KEY = "map_tplan",
  MAP_KEY = "map_tplanb",
  AWARD_ID = 50001,
  bSkipDownload = false,
  allTMapID = nil,
  cacheMapState = {},
  modeToKeyMap = {}
}
local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
function LogicTxMissionDownload.GetMilitaryShowAwards()
  local logic_txmission_season = require("client.slua.logic.TxMission.season.logic_xmission_season")
  local seasonCfg = logic_txmission_season.GetSeasonConfig()
  if seasonCfg and seasonCfg.RewardIDs then
    local StringUtil = require("common.string_util")
    LogicTxMissionDownload.rewardsList = StringUtil.Split(seasonCfg.RewardIDs, ";")
  end
  return LogicTxMissionDownload.rewardsList
end
function LogicTxMissionDownload.OpenTPlan(from)
  log(bWriteLog and string.format("[muidarzhang] LogicTxMissionDownload.OpenTPlan, from:%s", from))
  if IsWoWEditor then
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
  if logic_xmission_entrance:CheckCanEnterTxMission() then
    log(bWriteLog and "[muidarzhang] LogicTxMissionDownload.OpenTPlan, LogicTxMissionDownload.CheckCanEnterTPlan() == true. ")
    LogicTxMissionMain.SendEnterXMissionReq(from)
  elseif from == "reconnect" then
    LogicTxMissionMain.SendEnterXMissionReq(from)
  end
end
function LogicTxMissionDownload.OpenDownload(from)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.Clear()
  if IsWoWEditor then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.xmission_download, from)
end
function LogicTxMissionDownload.GetActivityList()
  local ActivityInfoList = ActivityNewSystem.GetActivityListByType(ActivityType.T_PLAN_DOWNLOAD)
  local TimeUtil = require("client.common.time_util")
  local nowSvr = TimeUtil.GetServerTimeInSec()
  if ActivityInfoList and next(ActivityInfoList) then
    local subIDList = {}
    for k, v in pairs(ActivityInfoList) do
      if (tonumber(v.EndTime) == 0 or nowSvr < tonumber(v.EndTime) and nowSvr >= tonumber(v.StartTime)) and v.List and v.List[1] and v.List[1].Condition and v.List[1].Condition[1] and 1 < tonumber(v.List[1].Condition[1]) then
        for k, v in pairs(v.List[1].Condition) do
          if tonumber(v) > 1 then
            table.insert(subIDList, tonumber(v))
          end
        end
      end
    end
    local retList = {}
    for k, v in pairs(subIDList) do
      local ActivityInfo = ActivityNewSystem.GetActivityByID(v)
      table.insert(retList, ActivityInfo)
    end
    return retList
  end
  return nil
end
function LogicTxMissionDownload.GetJustMapState()
  local bJustMapState = false
  if LobbySystem.CheckOpen(BP_ENUM_SKIP_DOWNLOAD_ITEMS_SWITCH) then
    bJustMapState = true
  end
  return bJustMapState
end
function LogicTxMissionDownload.CheckResHasDownloaded(mapKey)
  if IsWoWEditor then
    return false
  end
  local state = LogicTxMissionDownload.GetTPlanMapDownloadState(mapKey)
  return state == ENUM_DownloadState.Done
end
function LogicTxMissionDownload.CheckMapStateReady(showDownloadTips, downloadCallback, mapKey, finishCallback)
  if mapKey == nil then
    mapKey = LogicTxMissionDownload.GetMapKeyBySelMode()
  end
  if mapKey and mapKey ~= "" then
    local state = LogicTxMissionDownload.GetTPlanMapDownloadState(mapKey)
    if state ~= PufferConst.ENUM_DownloadState.Done then
      if showDownloadTips then
        local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {mapKey})
        local remainSize = tSize - cSize
        local size = math.floor(remainSize / PufferConst.MB + 0.5)
        size = math.max(size, 0.1)
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        if finishCallback then
          if not LogicTxMissionDownload.mapDownloadKey then
            log(bWriteLog and "LogicTxMissionDownload.CheckMapStateReady. registEvent")
            EventSystem:registEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, LogicTxMissionDownload.OnMapDownloadFinished)
          end
          LogicTxMissionDownload.mapDownloadKey = mapKey
          LogicTxMissionDownload.mapDownloadCallback = finishCallback
        end
        CommonMsgBoxMgr.Show(2, nil, LocUtil.LocalizeResFormat(45676, size), function()
          PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {mapKey})
          if type(downloadCallback) == "function" then
            downloadCallback()
          end
        end)
      end
      return false
    end
  end
  return true
end
function LogicTxMissionDownload.OnMapDownloadFinished()
  log(bWriteLog and "LogicTxMissionDownload.OnMapDownloadFinished.")
  if not (LogicTxMissionDownload.mapDownloadKey and LogicTxMissionDownload.mapDownloadCallback) or LogicTxMissionDownload.GetTPlanMapDownloadState(LogicTxMissionDownload.mapDownloadKey) ~= PufferConst.ENUM_DownloadState.Done then
    return
  end
  log(bWriteLog and "LogicTxMissionDownload.OnMapDownloadFinished. unregistEvent")
  EventSystem:unregistEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, LogicTxMissionDownload.OnMapDownloadFinished)
  local callback = LogicTxMissionDownload.mapDownloadCallback
  LogicTxMissionDownload.mapDownloadKey = nil
  LogicTxMissionDownload.mapDownloadCallback = nil
  callback()
end
function LogicTxMissionDownload.GetMapKeyBySelMode()
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local mode_id = LogicTxMissionMatch.GetSelModel()
  log(bWriteLog and string.format("LogicTxMissionDownload.CheckMapStateReady. mode_id=%s", tostring(mode_id)))
  if mode_id and mode_id ~= 0 then
    return LogicTxMissionDownload.GetMapKeyByModeID(mode_id)
  end
  return ""
end
function LogicTxMissionDownload.GetTPlanMapDownloadState(mapKey)
  if LogicTxMissionDownload.bSkipDownload then
    return ENUM_DownloadState.Done
  end
  local bJustMapState = LogicTxMissionDownload.GetJustMapState()
  local state = PufferConst.ENUM_DownloadState.Done
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  mapKey = mapKey or LogicTxMissionDownload.MAP_KEY
  if PublishRegionMacros.IsCEVersion() then
    state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey}, bJustMapState, true)
  else
    state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey}, bJustMapState)
  end
  return state
end
function LogicTxMissionDownload.PlayTPlanVideo()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    return
  end
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  local showCloseTime = LogicXMissionBeginnerGuide.GetVideoShowCloseBtnTime()
  VideoLibrary.PlayVideo(LogicXMissionBeginnerGuide.videoPath, {animation = true, topRightClose = true})
end
function LogicTxMissionDownload.SendDownloadAward()
  if PufferDownloader.DownloadRewardCfg == nil or PufferDownloader.DownloadRewardCfg[LogicTxMissionDownload.AWARD_ID] == nil then
    local PufferDownloadHandler = require("client.network.Protocol.PufferDownloadHandler")
    PufferDownloadHandler.send_mini_client_reward_cfg_get_req(LogicTxMissionDownload.AWARD_ID)
  end
end
function LogicTxMissionDownload.GetDownloadAward()
  if PufferDownloader.DownloadRewardCfg and PufferDownloader.DownloadRewardCfg[LogicTxMissionDownload.AWARD_ID] then
    return PufferDownloader.DownloadRewardCfg[LogicTxMissionDownload.AWARD_ID]
  end
  return nil
end
function LogicTxMissionDownload.GetDownloadRate()
  local curSize, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {
    LogicTxMissionDownload.MAP_KEY
  })
  local rate = curSize / totalSize
  if tostring(rate) == "nan" or totalSize == 0 then
    rate = 0
  end
  if 1 < rate then
    rate = 1
  end
  if rate <= 0 then
    rate = 0
  end
  return rate
end
function LogicTxMissionDownload.CheckDevice()
  return true
end
function LogicTxMissionDownload.InitModeToKeyMap()
  if next(LogicTxMissionDownload.modeToKeyMap) then
    return
  end
  local TxMissionMap = CDataTable.GetTable("TxMissionMapMode")
  for k, v in pairs(TxMissionMap) do
    local ModData = CDataTable.GetTableData("BTMode", v.ModeID)
    if ModData and ModData.MapID then
      local map = CDataTable.GetTableData("Map", ModData.MapID)
      if map then
        LogicTxMissionDownload.modeToKeyMap[v.ModeID] = map.MapKey
      end
    end
  end
end
function LogicTxMissionDownload.GetMapKeyByModeID(modeID)
  if modeID == nil then
    return nil
  end
  LogicTxMissionDownload.InitModeToKeyMap()
  return LogicTxMissionDownload.modeToKeyMap[modeID]
end
function LogicTxMissionDownload.GetTPlanSubMapStat(StateParam, force)
  StateParam = StateParam or {}
  if not LogicTxMissionDownload.allTMapID then
    LogicTxMissionDownload.allTMapID = {}
    local TxMissionMap = CDataTable.GetTable("TxMissionMapMode")
    for k, v in pairs(TxMissionMap) do
      local ModData = CDataTable.GetTableData("BTMode", v.ModeID)
      if ModData and ModData.MapID then
        local map = CDataTable.GetTableData("Map", ModData.MapID)
        if map then
          LogicTxMissionDownload.allTMapID[ModData.MapID] = map.MapKey
        end
      end
    end
  end
  if not LogicTxMissionDownload.allTMapID then
    return
  end
  for mapID, mapKey in pairs(LogicTxMissionDownload.allTMapID) do
    local state = LogicTxMissionDownload.GetTPlanMapDownloadState(mapKey)
    if state ~= PufferConst.ENUM_DownloadState.Done then
      state = PufferConst.ENUM_DownloadState.Not
    end
    if state ~= LogicTxMissionDownload.cacheMapState[mapID] or force then
      StateParam[mapID] = state
    end
    LogicTxMissionDownload.cacheMapState[mapID] = state
  end
end
function LogicTxMissionDownload.CheckFinishDownloadMap()
  local param = {}
  LogicTxMissionDownload.GetTPlanSubMapStat(param, false)
  if next(param) then
    local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
    PufferMapManager:SendUserFinishDownloadMap(param)
  end
end
function LogicTxMissionDownload.TMapCustomGetSizeFunc(downloadType, mapKeyList, bSkipDepend)
  if not LogicTxMissionDownload.TMapBaseSize or LogicTxMissionDownload.TMapBaseSize > 1 then
    local _, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {
      LogicTxMissionDownload.BASE_MAP_KEY
    })
    LogicTxMissionDownload.TMapBaseSize = totalSize
  end
  local downloadSize, totalSize = PufferManager.GetSize(downloadType, mapKeyList, bSkipDepend)
  if downloadSize >= LogicTxMissionDownload.TMapBaseSize then
    downloadSize = downloadSize - LogicTxMissionDownload.TMapBaseSize
    totalSize = totalSize - LogicTxMissionDownload.TMapBaseSize
  end
  return downloadSize, totalSize
end
return LogicTxMissionDownload