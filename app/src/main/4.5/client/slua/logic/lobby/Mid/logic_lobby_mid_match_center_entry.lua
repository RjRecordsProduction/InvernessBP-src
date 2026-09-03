local logic_lobby_mid_match_center_entry = {
  videoList = nil,
  curPlayIndex = 0,
  videoSaveDir = Client.ProjectSavedDir() .. "MatchCenterVideo/",
  E_VideoActiveType = {
    Idle = 0,
    Play = 1,
    Finish = 2
  },
  nCloseUITime = nil,
  bDirty = true,
  bHasMatchActivity = false
}
local defaultVideoInfo = {
  interval_time = 0,
  retryTime = 0,
  source_url = "",
  downloadPath = "",
  bIsPlayed = true
}
function logic_lobby_mid_match_center_entry.GetLobbyMainUI()
  local lobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  return lobbyMainUI
end
function logic_lobby_mid_match_center_entry.on_championship_info_notify(tRedInfo)
  log_tree("dean matchcenter logic_lobby_mid_match_center_entry.on_championship_info_notify", tRedInfo)
  if not tRedInfo then
    return
  end
  for _, v in pairs(tRedInfo) do
    if v.source_info and #v.source_info > 0 then
      logic_lobby_mid_match_center_entry.SetVideoInfo(v.source_info)
    else
      logic_lobby_mid_match_center_entry.videoList = nil
    end
  end
  logic_lobby_mid_match_center_entry.curPlayIndex = 0
  local lobbyMainUI = logic_lobby_mid_match_center_entry.GetLobbyMainUI()
  if lobbyMainUI then
    local ui = lobbyMainUI:GetChildUI(UIManager.UI_Config.Lobby_Mid_Match_Center_Entry_UIBP)
    if ui then
      ui.fsm:ConvertIdle()
      return
    end
  end
  logic_lobby_mid_match_center_entry.RedPointInfo = tRedInfo
end
function logic_lobby_mid_match_center_entry.IsMatchCenterVideoValid()
  return logic_lobby_mid_match_center_entry.HasLiveVideo() or logic_lobby_mid_match_center_entry.HasMatchActivity()
end
function logic_lobby_mid_match_center_entry.HasLiveVideo()
  if not logic_lobby_mid_match_center_entry.videoList then
    return false
  end
  local videoPlayerUI = UIManager.GetUI(UIManager.UI_Config.video_player_system)
  if videoPlayerUI and videoPlayerUI.isPlaying then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local startTime = 0
  local endTime = 0
  for _, v in pairs(logic_lobby_mid_match_center_entry.RedPointInfo or {}) do
    startTime = v.start_pot_time or 0
    endTime = v.end_pot_time or 0
  end
  return serverTime >= startTime and serverTime <= endTime
end
function logic_lobby_mid_match_center_entry.HasMatchActivity()
  if not logic_lobby_mid_match_center_entry.bDirty then
    return logic_lobby_mid_match_center_entry.bHasMatchActivity
  end
  local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivity() or {}
  local bHasMatchActivity = false
  for _, activity in ipairs(activityData) do
    if ActivityUtil.CanShowAct(activity) and activity.TabType == ActivitySwitchType.Sport and activity.DisplayScene and activity.DisplayScene[ActivityDisplayScene.Sport] then
      bHasMatchActivity = true
      break
    end
  end
  logic_lobby_mid_match_center_entry.  logic_lobby_mid_match_center_entry.bDirty = false
  return bHasMatchActivity
end
function logic_lobby_mid_match_center_entry.CheckAndAddMatchCenterEntryUI()
  local lobbyMainUI = logic_lobby_mid_match_center_entry.GetLobbyMainUI()
  if not lobbyMainUI then
    return
  end
  if logic_lobby_mid_match_center_entry.IsMatchCenterVideoValid() then
    lobbyMainUI:AddChildUI("Border_matchcenter", UIManager.UI_Config.Lobby_Mid_Match_Center_Entry_UIBP)
  elseif lobbyMainUI:GetChildUI(UIManager.UI_Config.Lobby_Mid_Match_Center_Entry_UIBP) then
    lobbyMainUI:CloseChildUI(UIManager.UI_Config.Lobby_Mid_Match_Center_Entry_UIBP)
  end
end
function logic_lobby_mid_match_center_entry.AddNotifyRecommendDownloadUI(pakType, key)
  local lobbyMainUI = logic_lobby_mid_match_center_entry.GetLobbyMainUI()
  if not lobbyMainUI then
    return
  end
  local ui = lobbyMainUI:AddChildUI("Border_RecommendDownload", UIManager.UI_Config.notify_recommend_download, pakType, key)
  if ui then
    ui:InitUI(pakType, key)
  end
end
function logic_lobby_mid_match_center_entry.RedPointLoopTimer()
  if not next(logic_lobby_mid_match_center_entry.RedPointInfo or {}) then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lastRedPointTime = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEsportsCenterRedPointInfo) or 0
  local center_reddot_data = require("client.slua.logic.esport.center_reddot_data")
  for _, v in pairs(logic_lobby_mid_match_center_entry.RedPointInfo) do
    if serverTime > v.start_pot_time and serverTime < v.end_pot_time and serverTime - lastRedPointTime > v.red_pot_show * 3600 and not GlobalData.IsJapanOrKorea() then
      PlayerPrefsSystem.SaveTableToFile_N(serverTime, PlayerPrefsSystem.ePlayerPrefsType.eEsportsCenterRedPointInfo)
      center_reddot_data.UpdateCenterCount(1)
      return
    end
  end
  center_reddot_data.SendRemoveCenterTlog()
  center_reddot_data.UpdateCenterCount(0)
end
function logic_lobby_mid_match_center_entry.SetVideoInfo(sourceInfo)
  local tInfo = {}
  for i = 1, 4 do
    tInfo[i] = defaultVideoInfo
  end
  local bHasValidInfo = false
  for _, v in pairs(sourceInfo) do
    local nIdx = tonumber(v.open_index)
    tInfo[nIdx] = {}
    tInfo[nIdx].retryTime = 0
    tInfo[nIdx].source_url = v.source_ulr or ""
    tInfo[nIdx].downloadPath = logic_lobby_mid_match_center_entry.videoSaveDir .. string.gsub(tInfo[nIdx].source_url, ".*/", "")
    tInfo[nIdx].interval_time = v.interval_time or 0
    if 0 < tInfo[nIdx].interval_time and tInfo[nIdx].source_ulr ~= "" then
      bHasValidInfo = true
      tInfo[nIdx].bIsPlayed = false
    else
      tInfo[nIdx].bIsPlayed = true
    end
  end
  if not bHasValidInfo then
    tInfo = nil
  end
  logic_lobby_mid_match_center_entry.videoList = tInfo
  local TimeUtil = require("client.common.time_util")
  log_tree("dean matchcenter logic_lobby_mid_match_center_entry:SetVideoInfo - self.videoList: ", logic_lobby_mid_match_center_entry.videoList)
end
function logic_lobby_mid_match_center_entry.GetNextVideoCDTime()
  if not logic_lobby_mid_match_center_entry.videoList then
    return 1
  end
  local nextIndex = logic_lobby_mid_match_center_entry.curPlayIndex + 1
  if nextIndex >= logic_lobby_mid_match_center_entry.ChampionVideoIndex() then
    nextIndex = 1
  end
  local info = logic_lobby_mid_match_center_entry.videoList[nextIndex]
  if not info or info.bIsPlayed or info.retryTime >= 3 or 1 >= info.interval_time then
    return 1
  end
  return info.interval_time
end
function logic_lobby_mid_match_center_entry.SwitchCurPlayVideo(bPauseIndex)
  if logic_lobby_mid_match_center_entry.videoList == nil or #logic_lobby_mid_match_center_entry.videoList <= 1 then
    log(bWriteLog and "dean matchcenter logic_lobby_mid_match_center_entry.SwitchCurPlayVideo - no valid video")
    logic_lobby_mid_match_center_entry.curPlayIndex = 0
    return
  end
  log_tree("[chub] matchCenter LogicMatchCenterEntry.SwitchCurPlayVideo, videoInfo = ", logic_lobby_mid_match_center_entry.videoList)
  local bAllPlayed = true
  for i = 1, #logic_lobby_mid_match_center_entry.videoList - 1 do
    local curInfo = logic_lobby_mid_match_center_entry.videoList[i]
    if curInfo and not curInfo.bIsPlayed and curInfo.retryTime < 3 then
      bAllPlayed = false
    end
  end
  if bAllPlayed then
    log(bWriteLog and "dean matchcenter logic_lobby_mid_match_center_entry.SwitchCurPlayVideo - all video played")
    return
  end
  if bPauseIndex ~= true then
    logic_lobby_mid_match_center_entry.curPlayIndex = logic_lobby_mid_match_center_entry.curPlayIndex + 1
  end
  if logic_lobby_mid_match_center_entry.curPlayIndex >= #logic_lobby_mid_match_center_entry.videoList then
    logic_lobby_mid_match_center_entry.curPlayIndex = 1
  end
  local curVideoInfo = logic_lobby_mid_match_center_entry.GetCurVideoInfo()
  if 0 >= curVideoInfo.interval_time or curVideoInfo.bIsPlayed or curVideoInfo.retryTime >= 3 then
    curVideoInfo.bIsPlayed = true
    local lobbyMainUI = logic_lobby_mid_match_center_entry.GetLobbyMainUI()
    if lobbyMainUI then
      EventSystem:postEvent(EVENTTYPE_MATCH_CENTER, EVENTID_START_SWITCH_VIDEO)
      return
    end
  end
  log(bWriteLog and "dean matchcenter logic_lobby_mid_match_center_entry.SwitchCurPlayVideo - switch to: " .. tostring(logic_lobby_mid_match_center_entry.curPlayIndex))
  logic_lobby_mid_match_center_entry.InitVideoDownload(logic_lobby_mid_match_center_entry.curPlayIndex)
end
function logic_lobby_mid_match_center_entry.InitVideoDownload(videoIndex)
  log(bWriteLog and "dean matchcenter logic_lobby_mid_match_center_entry.InitVideoDownload - start download video: " .. tostring(videoIndex))
  if not logic_lobby_mid_match_center_entry.videoList or videoIndex == 0 or videoIndex > #logic_lobby_mid_match_center_entry.videoList then
    return
  end
  local videoInfo = logic_lobby_mid_match_center_entry.videoList[videoIndex]
  local url = videoInfo.source_url
  local path = videoInfo.downloadPath
  videoInfo.retryTime = videoInfo.retryTime + 1
  local cdn_downloader = require("client.common.cdn_downloader")
  cdn_downloader.download(url, path, logic_lobby_mid_match_center_entry.OnDownloadCompleteCallBack, 0)
end
function logic_lobby_mid_match_center_entry.OnDownloadCompleteCallBack(url, path, bIsDownloaded)
  log(bWriteLog and "dean matchcenter logic_lobby_mid_match_center_entry.OnDownloadCompleteCallBack - url: " .. tostring(url) .. ", path: " .. tostring(path) .. ", bIsDownloaded: " .. tostring(bIsDownloaded))
  if not logic_lobby_mid_match_center_entry.videoList or not logic_lobby_mid_match_center_entry.curPlayIndex then
    return
  end
  local curInfo = logic_lobby_mid_match_center_entry.videoList[logic_lobby_mid_match_center_entry.curPlayIndex] or {}
  if curInfo.source_url ~= url then
    return
  end
  EventSystem:postEvent(EVENTTYPE_MATCH_CENTER, EVENTID_PLAY_VIDEO, path, bIsDownloaded)
end
function logic_lobby_mid_match_center_entry.IsLobbyUIShow()
  local lobbyMainUI = logic_lobby_mid_match_center_entry.GetLobbyMainUI()
  return lobbyMainUI and lobbyMainUI:IsShow()
end
function logic_lobby_mid_match_center_entry.IsMediaPlayerHidden()
  local bShow = UIManager.IsUIShow(UIManager.UI_Config.UPassIntroduceUIBP)
  return bShow
end
function logic_lobby_mid_match_center_entry.SetCurVideoIndex(nIndex)
  logic_lobby_mid_match_center_entry.curPlayIndex = nIndex
end
function logic_lobby_mid_match_center_entry.ChampionVideoIndex()
  return #logic_lobby_mid_match_center_entry.videoList
end
function logic_lobby_mid_match_center_entry.GetCurVideoInfo()
  return logic_lobby_mid_match_center_entry.videoList and logic_lobby_mid_match_center_entry.videoList[logic_lobby_mid_match_center_entry.curPlayIndex] or {}
end
function logic_lobby_mid_match_center_entry.GetVideoInfo(nIndex)
  return logic_lobby_mid_match_center_entry.videoList and logic_lobby_mid_match_center_entry.videoList[nIndex] or {}
end
function logic_lobby_mid_match_center_entry.GetPreCloseUITime()
  return logic_lobby_mid_match_center_entry.nCloseUITime
end
function logic_lobby_mid_match_center_entry.RecordCloseUITime()
  local TimeUtil = require("client.common.time_util")
  logic_lobby_mid_match_center_entry.nCloseUITime = TimeUtil.GetServerTimeInSec()
end
function logic_lobby_mid_match_center_entry.ClearCloseUITime()
  logic_lobby_mid_match_center_entry.nCloseUITime = nil
end
return logic_lobby_mid_match_center_entry