local KeyPlayVideoSystem = {
  switch = true,
  videoId = 0,
  isPlayed = false,
  hadListener = false,
  firstLoginTrigger = false,
  enterCameraId = nil,
  bIsReLogin = false,
  bShowedEUGDPR = false,
  reward = nil,
  isPlayEnd = false,
  bFromReturnRewardSlap = false,
  bIgnoreQueue = false
}
local KeyPlayVideoPath = "./MoviesPakDir/PUBGM_Car.mp4"
function KeyPlayVideoSystem.Reset()
  KeyPlayVideoSystem.videoId = 0
  KeyPlayVideoSystem.bIsReLogin = true
  KeyPlayVideoSystem.bShowedEUGDPR = false
  KeyPlayVideoSystem.reward = nil
  KeyPlayVideoSystem.bFromReturnRewardSlap = false
  KeyPlayVideoSystem.bIgnoreQueue = false
end
function KeyPlayVideoSystem.NeedPlay(ignoreLoading, ignoreReturnRewardSlap)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_KEYPLAY_VIDEO_SWITCH)
  if not bSwitch then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay backend switch closed, don't play")
    return false
  end
  if not KeyPlayVideoSystem.switch then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay frontend switch closed, don't play")
    return false
  end
  if KeyPlayVideoSystem.bShowedEUGDPR == true then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay EUGDPR")
    return false
  end
  if KeyPlayVideoSystem.bIsReLogin and not logic_return_activity_utils.IsActInProgress() then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay had relogin")
    return false
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay GameStatus And Not In MainCity")
    return false
  end
  if KeyPlayVideoSystem.isPlayEnd then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay video had play end, don't play")
    return false
  end
  if not ignoreReturnRewardSlap then
    local logic_player_return_slap = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_player_return_slap)
    if logic_player_return_slap:CanGetGift() then
      log_shipping_client("KeyPlayVideoSystem.NeedPlay return reward first login, let return activity take over")
      return false
    end
  end
  if KeyPlayVideoSystem.firstLoginTrigger then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay had opened firstLoginTrigger , no need to check")
    return true
  end
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  if AdjustSystem:IsAwakedByAdjust() then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay Deeplink Enter Game, don't Play")
    return false
  end
  if KeyPlayVideoSystem.videoId == 0 then
    log_shipping_client("KeyPlayVideoSystem:NeedPlay videoId == 0, don't play")
    return false
  end
  KeyPlayVideoSystem.GetVideoPath(KeyPlayVideoSystem.videoId)
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local isNewbie = LogicNewbie.IsNewbie()
  local isFinishAllNewGuide = growthprojectMgrB.IsFinishAllNewGuide()
  log_format("KeyPlayVideoSystem.NeedPlay isNewbie %s, isFinishAllNewGuide %s", isNewbie, isFinishAllNewGuide)
  if isNewbie or not isFinishAllNewGuide then
    local ELobbyGuideID = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ELobbyGuideID
    if not LogicNewbie.NeedShowNewbieGuide(ELobbyGuideID.LOBBY_NEWBIE_THEME_SLAP_GUIDE_ID) then
      log_shipping_client("KeyPlayVideoSystem.NeedPlay is newbie, don't play")
      return false
    end
  end
  if not VideoLibrary.IsCanPlayVideo() then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay video has problem , don't play")
    return false
  end
  if KeyPlayVideoSystem.isPlayed then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay videoId had played once 1, won't play again")
    return false
  end
  if not ignoreLoading then
    local ui = UIManager.GetUI(UIManager.UI_Config.loading)
    if not ui then
      log_shipping_client("KeyPlayVideoSystem.NeedPlay Not in loading process, something must be wrong")
      return false
    end
  end
  if not VideoLibrary.IsVideoFileReady(KeyPlayVideoPath) then
    log_shipping_client("KeyPlayVideoSystem.NeedPlay copy failed")
    return false
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  KeyPlayVideoSystem.enterCameraId = Lobby_camera_manager_module.currentCameraID
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
  KeyPlayVideoSystem.firstLoginTrigger = true
  log_shipping_client("KeyPlayVideoSystem.NeedPlay allowed to play")
  return true
end
function KeyPlayVideoSystem.GetVideoPath(id)
  log(bWriteLog and "KeyPlayVideoSystem.GetVideoPath - id = " .. tostring(id))
  local videoCfg = CDataTable.GetTableData("KeyPlayVideo", id)
  if videoCfg and videoCfg.path ~= "" then
    KeyPlayVideoPath = videoCfg.path
    if id == 10059 then
      local needChangeVideoPath = KeyPlayVideoSystem.CheckNeedSetForcePath()
      log_format("KeyPlayVideoSystem.GetVideoPath - CheckNeedSetForcePath: %s", needChangeVideoPath)
      if needChangeVideoPath then
        local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
        if PublishRegionMacros.IsBLUEHOLE() then
          KeyPlayVideoPath = "./MoviesPakDir/VersionUpdate_4500_IN.mp4"
        else
          KeyPlayVideoPath = "./MoviesPakDir/VersionUpdate_4500.mp4"
        end
      end
    end
  end
end
function KeyPlayVideoSystem.CheckNeedSetForcePath()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local isNewbie = LogicNewbie.IsNewbie()
  local isFinishAllNewGuide = growthprojectMgrB.IsFinishAllNewGuide()
  local ELobbyGuideID = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ELobbyGuideID
  local needShowNewbieGuide = LogicNewbie.NeedShowNewbieGuide(ELobbyGuideID.LOBBY_NEWBIE_THEME_SLAP_GUIDE_ID)
  log_format("KeyPlayVideoSystem.CheckNeedSetForcePath - isNewbie:%s, isFinishAllNewGuide:%s, needShowNewbieGuide:%s", isNewbie, isFinishAllNewGuide, needShowNewbieGuide)
  if (isNewbie or not isFinishAllNewGuide) and needShowNewbieGuide then
    return true
  end
  local logic_player_return_slap = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_player_return_slap)
  local isReturn = logic_player_return_slap:CanGetGift()
  log_format("KeyPlayVideoSystem.CheckNeedSetForcePath - isReturn:%s", isReturn)
  if isReturn then
    return true
  end
  return false
end
function KeyPlayVideoSystem.FetchCurrentVideoDownloadPath()
  if KeyPlayVideoSystem.videoId == 0 then
    log(bWriteLog and "KeyPlayVideoSystem.FetchCurrentVideoDownloadPath videoId is 0, skip")
    return ""
  end
  KeyPlayVideoSystem.GetVideoPath(KeyPlayVideoSystem.videoId)
  return DataMgr.GetVideoDownloadPath(KeyPlayVideoPath)
end
function KeyPlayVideoSystem.PlayBeforeReturnWelcomeBack()
  if KeyPlayVideoSystem.isPlayed or KeyPlayVideoSystem.isPlayEnd then
    log_shipping_client("KeyPlayVideoSystem:PlayBeforeReturnWelcomeBack already played, skip")
    return
  end
  if not KeyPlayVideoSystem.NeedPlay(true, true) then
    log_shipping_client("KeyPlayVideoSystem:PlayBeforeReturnWelcomeBack no need play, skip")
    return
  end
  KeyPlayVideoSystem.bFromReturnRewardSlap = true
  KeyPlayVideoSystem.OpenKeyPlayVideo(true, true)
end
function KeyPlayVideoSystem.OpenKeyPlayVideoNow()
  log(bWriteLog and "KeyPlayVideoSystem: OpenKeyPlayVideoNow")
  KeyPlayVideoSystem.OpenKeyPlayVideo(true)
end
function KeyPlayVideoSystem.OnUrlOpenKeyPlayVideo(eventType, eventID)
  log(bWriteLog and "KeyPlayVideoSystem:OnUrlOpenKeyPlayVideo")
  KeyPlayVideoSystem.OpenKeyPlayVideo(false)
end
function KeyPlayVideoSystem.OnUrlOpenKeyPlayVideoNow(eventType, eventID)
  log(bWriteLog and "KeyPlayVideoSystem:OnUrlOpenKeyPlayVideoNow")
  KeyPlayVideoSystem.OpenKeyPlayVideo(true)
end
function KeyPlayVideoSystem.OpenKeyPlayVideo(bPlayNow, ignoreQueue)
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  NewFaceSlapSystem:BlockSlap()
  KeyPlayVideoSystem.bIgnoreQueue = ignoreQueue == true
  KeyPlayVideoSystem._AddListener(bPlayNow)
end
function KeyPlayVideoSystem._AddListener(bPlayNow)
  if bPlayNow then
    EventSystem:unregistEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, KeyPlayVideoSystem.OnVideoEnd)
    EventSystem:registEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, KeyPlayVideoSystem.OnVideoEnd)
    log(bWriteLog and "KeyPlayVideoSystem:_AddListener bPlayNow play immediately")
    KeyPlayVideoSystem.PlayVideo()
    return
  end
  if KeyPlayVideoSystem.hadListener then
    log(bWriteLog and "KeyPlayVideoSystem:_AddListener already had listener")
    return
  end
  KeyPlayVideoSystem.hadListener = true
  EventSystem:registEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, KeyPlayVideoSystem.OnVideoEnd)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_FINISH, KeyPlayVideoSystem.PlayVideo)
end
function KeyPlayVideoSystem.PlayVideo(eventType, eventId)
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  if KeyPlayVideoSystem.isPlayed then
    log(bWriteLog and "KeyPlayVideoSystem: videoId had played once, won't play again")
    return
  end
  KeyPlayVideoSystem.isPlayed = true
  local status = GameStatus.GetGameStatus()
  if status ~= GameStatus.Lobby and not GameStatus.IsInMainCity() then
    KeyPlayVideoSystem.isPlayEnd = true
    EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_FINISH, KeyPlayVideoSystem.PlayVideo)
    EventSystem:unregistEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, KeyPlayVideoSystem.OnVideoEnd)
    log_shipping_client("KeyPlayVideoSystem: PlayVideo , not in lobby status:" .. tostring(status))
    return
  end
  local ParamTable
  if not KeyPlayVideoSystem.bIgnoreQueue then
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    ParamTable = ui_show_queue_config.GetParamTable(nil, "IsSlapUI")
  end
  local result = VideoLibrary.PlayVideo(KeyPlayVideoPath, nil, true, ParamTable)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_FINISH, KeyPlayVideoSystem.PlayVideo)
  if result == false then
    KeyPlayVideoSystem.OnVideoEnd(0, 0, KeyPlayVideoPath)
  else
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_cutscenes_report()
  end
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.BlockPopTip()
end
function KeyPlayVideoSystem.SetReward(data)
  KeyPlayVideoSystem.reward = data
end
function KeyPlayVideoSystem.OnVideoEnd(eventType, eventId, path)
  log(bWriteLog and "KeyPlayVideoSystem: " .. tostring(path))
  if path ~= KeyPlayVideoPath then
    log(bWriteLog and "KeyPlayVideoSystem: path not right")
    return
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE)
  if KeyPlayVideoSystem.reward then
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVNETID_ITEM_GET_DONE, KeyPlayVideoSystem.OnShowRewardDone)
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(KeyPlayVideoSystem.reward)
    KeyPlayVideoSystem.reward = nil
  else
    KeyPlayVideoSystem.OnShowRewardDone()
  end
  EventSystem:unregistEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, KeyPlayVideoSystem.OnVideoEnd)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.UnblockPopTip()
end
function KeyPlayVideoSystem.OnShowRewardDone()
  log(bWriteLog and "KeyPlayVideoSystem.OnShowRewardDone")
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVNETID_ITEM_GET_DONE, KeyPlayVideoSystem.OnShowRewardDone)
  KeyPlayVideoSystem.isPlayEnd = true
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if KeyPlayVideoSystem.bFromReturnRewardSlap then
    KeyPlayVideoSystem.bFromReturnRewardSlap = false
    NewFaceSlapSystem:RevertSlap()
  else
    NewFaceSlapSystem:SkipLimitSlap()
  end
end
return KeyPlayVideoSystem