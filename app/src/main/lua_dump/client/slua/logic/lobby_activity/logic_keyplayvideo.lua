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
  isPlayEnd = false
}
local KeyPlayVideoPath = "./MoviesPakDir/PUBGM_Car.mp4"
function KeyPlayVideoSystem.Reset()
  KeyPlayVideoSystem.videoId = 0
  KeyPlayVideoSystem.bIsReLogin = true
  KeyPlayVideoSystem.bShowedEUGDPR = false
  KeyPlayVideoSystem.reward = nil
end
function KeyPlayVideoSystem.NeedPlay()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_KEYPLAY_VIDEO_SWITCH)
  if not bSwitch then
    return false
  end
  if not KeyPlayVideoSystem.switch then
    return false
  end
  if KeyPlayVideoSystem.bShowedEUGDPR == true then
    log_shipping_client("KeyPlayVideoSystem: EUGDPR")
    return false
  end
  if KeyPlayVideoSystem.bIsReLogin then
    log_shipping_client("KeyPlayVideoSystem: had relogin")
    return false
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log_shipping_client("KeyPlayVideoSystem GameStatus And Not In MainCity")
    return false
  end
  if KeyPlayVideoSystem.isPlayEnd then
    return false
  end
  if KeyPlayVideoSystem.firstLoginTrigger then
    log_shipping_client("KeyPlayVideoSystem: had opened firstLoginTrigger , no need to check")
    return true
  end
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  if AdjustSystem:IsAwakedByAdjust() then
    log(bWriteLog and "KeyPlayVideoSystem: Deeplink Enter Game, don't Play")
    return false
  end
  if KeyPlayVideoSystem.videoId == 0 then
    log_shipping_client("KeyPlayVideoSystem: videoId == 0, don't play")
    return false
  end
  KeyPlayVideoSystem.GetVideoPath(KeyPlayVideoSystem.videoId)
  if LogicNewbie.IsNewbie() then
    log_shipping_client("KeyPlayVideoSystem: player is newbie , don't play")
    return false
  end
  if not VideoLibrary.IsCanPlayVideo() then
    log_shipping_client("KeyPlayVideoSystem: video has problem , don't play")
    return false
  end
  if KeyPlayVideoSystem.isPlayed then
    log_shipping_client("KeyPlayVideoSystem: videoId had played once 1, won't play again")
    return false
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.loading)
  if not ui then
    log_shipping_client("KeyPlayVideoSystem: Not in loading process, something must be wrong")
    return false
  end
  if not VideoLibrary.IsVideoFileReady(KeyPlayVideoPath) then
    log_shipping_client("KeyPlayVideoSystem: copy failed")
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    return false
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  KeyPlayVideoSystem.enterCameraId = Lobby_camera_manager_module.currentCameraID
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
  KeyPlayVideoSystem.firstLoginTrigger = true
  EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_KEY_PLAY_VIDEO, KeyPlayVideoSystem.OpenKeyPlayVideo)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_KEY_PLAY_VIDEO, KeyPlayVideoSystem.OpenKeyPlayVideo)
  return true
end
function KeyPlayVideoSystem.GetVideoPath(id)
  local videoCfg = CDataTable.GetTableData("KeyPlayVideo", id)
  if videoCfg and videoCfg.path ~= "" then
    KeyPlayVideoPath = videoCfg.path
  end
end
function KeyPlayVideoSystem.OpenKeyPlayVideo()
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  NewFaceSlapSystem:BlockSlap()
  KeyPlayVideoSystem._AddListener()
end
function KeyPlayVideoSystem._AddListener()
  if KeyPlayVideoSystem.hadListener then
    log(bWriteLog and "KeyPlayVideoSystem: already had listener")
    return
  else
    KeyPlayVideoSystem.hadListener = true
  end
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_FINISH, KeyPlayVideoSystem.PlayVideo)
  EventSystem:registEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, KeyPlayVideoSystem.OnVideoEnd)
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
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ParamTable = ui_show_queue_config.GetParamTable(nil, "IsSlapUI")
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
  NewFaceSlapSystem:SkipLimitSlap()
end
return KeyPlayVideoSystem