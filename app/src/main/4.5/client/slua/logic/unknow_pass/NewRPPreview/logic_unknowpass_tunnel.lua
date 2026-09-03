local UnknowPassTunnelSystem = {
  jumpInfo = nil,
  isShowRP = false,
  isRelogin = false,
  lastEnterPassTime = 0,
  closeForbidTime = 1,
  isFromMsgExcutor = false,
  bHasRankData = false,
  curlevel = "",
  hasShowExpBubble = false,
  bGMFadeInAnim = false,
  sceneName = nil,
  isLoginRequestMessage = false,
  bIsBattleBackToLobby = false
}
local RPShowType = {
  Show = 1,
  Close = 2,
  OnlyClose = 3
}
function UnknowPassTunnelSystem.ShowRP(jumpInfo, bIsJumpBack)
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.OpenRPUI)
  if not UnknowPassTunnelSystem.CheckCanShowPass() then
    log(bWriteLog and "[ZH] can not go in RP")
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Alias_popup) then
    return
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  NewFaceSlapSystem:BlockSlap()
  local logic_xmission_insurance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_insurance)
  logic_xmission_insurance:CloseInsuranceUI()
  if UIManager.GetUI(UIManager.UI_Config.ui_season_slapface_s47) then
    UIManager.CloseUI(UIManager.UI_Config.ui_season_slapface_s47)
  end
  local isShowAnimation, id = UnknowPassTunnelSystem.CheckShowNewSeasonVideo()
  if isShowAnimation then
    UnknowPassTunnelSystem.ShowSeasonAnimation(jumpInfo, id)
    local corpsTabMgr = UIManager.GetUI(UIManager.UI_Config.CorpsTabMgr)
    if corpsTabMgr then
      corpsTabMgr:Close()
    end
    log(bWriteLog and "[ZH] play animation")
    logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.OpenRPUI)
    return
  end
  UnknowPassTunnelSystem.OpenAnimationEnd(jumpInfo, bIsJumpBack)
  logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.OpenRPUI)
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local bIsCloudGameWeb = logic_cloud_game:IsCloudGameWeb()
  local aosShop = Client.GetAOSSHOP()
  local bIsShow = true
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    if aosShop ~= AOSSHOPMacros.Google and aosShop ~= AOSSHOPMacros.HMS then
      bIsShow = false
    end
  end
  if not bIsCloudGameWeb and bIsShow then
    UnknowPassBuySystem.UpdateNormalPassDirectPurchaseInfo()
    UnknowPassBuySystem.UpdateElitePassDirectPurchaseInfo()
  end
end
function UnknowPassTunnelSystem.OnLogOut()
  local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
  UnknowPassLevelupSystem.delayShow = false
end
function UnknowPassTunnelSystem.GetRpSceneName()
  if not UnknowPassTunnelSystem.sceneName then
    UnknowPassTunnelSystem.UpdateCameraAndBg(false)
  end
  return UnknowPassTunnelSystem.sceneName
end
function UnknowPassTunnelSystem.CloseRP(isJumpClose)
  log(bWriteLog and "[ZH] CloseRP")
  local TimeUtil = require("client.common.time_util")
  if FuncUtil.GetServerTimeInSec() - UnknowPassTunnelSystem.lastEnterPassTime > 0 and TimeUtil.GetServerTimeInSec() - UnknowPassTunnelSystem.lastEnterPassTime < UnknowPassTunnelSystem.closeForbidTime then
    log(bWriteLog and "[ZH] EventCloseUnknowPass forbid close")
    return
  end
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  UnknowPassOpenUISystem.isExperienceUI = false
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  NewFaceSlapSystem:ReleaseBlockSlap()
  local mainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_UnknowPass_UIBP_1_0_0)
  if mainUI then
    UIManager.CloseUI(UIManager.UI_Config.Lobby_UnknowPass_UIBP_1_0_0)
  else
    UnknowPassTunnelSystem.CloseRPExceptMainUI(isJumpClose)
  end
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  UnknowPassAwardSystem.bIsFirstOpenAward = true
  UnknowPassAwardSystem.bIsFirstOpenBonus = true
end
function UnknowPassTunnelSystem.CloseRPExceptMainUI(isJumpClose)
  UnknowPassTunnelSystem.CheckClosePassUI(true)
  if UnknowPassTunnelSystem.isShowRP == false then
    return
  end
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  UnknowPassOpenUISystem.isJumpClose = isJumpClose or false
  UnknowPassTunnelSystem.isShowRP = false
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.UnblockPopTip()
  local world = slua_GameFrontendHUD:GetWorld()
  local GlobalUIFunction = import("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary_C")
  GlobalUIFunction.SetLobbyDefaultLightProperty(world)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    local logic_xmission_insurance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_insurance)
    if logic_xmission_insurance.bInsuranceJumpRP and logic_xmission_insurance.bPrepareJumpRP then
      logic_xmission_insurance:RPJumpBackInsurance()
    end
  end
  EventSystem:postEvent(EVENT_BLACK, EVENT_BLACK_GRADIENT)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.ShowAllAvatar()
  local RankSystem = require("client.slua.logic.unknow_pass.rank.logic_unknowpass_rank")
  RankSystem.ClosePassRankUI()
  UnknowPassTunnelSystem.Release()
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.HidePanel()
  EventSystem:postEvent(EVENTTYPE_NEWBIE, EVENTID_NEWBIE_SYNC_DATA)
  UnknowPassTunnelSystem.CheckCloseNewbieGuide()
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  if not UnknowPassBuySystem.bIsShowRPBuyUI then
    UnknowPassTunnelSystem.UpdateCameraAndBg(false)
  end
  UnknowPassTunnelSystem.RemoveTimer()
  logic_achievement_float_tip.UnblockPopTip()
  logic_achievement_float_tip.ShowAchievementTip()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.SetCurTab(0)
  UnknowPassTunnelSystem.ClearOtherModuleData()
end
function UnknowPassTunnelSystem.OnModePreSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    UnknowPassTunnelSystem.isShowRP = false
    if not UnknowPassTunnelSystem.isLoginRequestMessage then
      log(bWriteLog and "UnknowPassTunnelSystem.OnModePostSwitch isLoginRequestMessage = false")
      UnknowPassTunnelSystem.bIsBattleBackToLobby = true
      local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
      PassDataSystem.upass_get_req()
    end
    local logic_upass_level_slap = require("client.slua.logic.upass.levelSlap.logic_upass_level_slap")
    logic_upass_level_slap.SetIsShowSlapLevel(false)
  end
end
function UnknowPassTunnelSystem.OnModePostSwitch(preState, gamestatus)
  log(bWriteLog and "[UnknowPassTunnelSystem] OnModePostSwitch: " .. tostring(gamestatus))
  local status = gamestatus
  if status == GameStatus.Login then
    UnknowPassSystem.Level = 0
  elseif GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "UnknownPassDataSystem.CheckExperienceBubble switch")
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    PassDataSystem.SetCurTab(0)
    local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
    if not UnknowPassTunnelSystem.isLoginRequestMessage then
      log(bWriteLog and "UnknowPassTunnelSystem.OnModePostSwitch isLoginRequestMessage = false")
      UnknowPassTunnelSystem.bIsBattleBackToLobby = true
      passReddotMainSystem.UpdateReddot()
    end
    UnknowPassTunnelSystem.UpDateRedPoint()
    local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
    local ResourseVersion = UnknowPassUtil.GetVersionNumber()
    Client.SetImageVersionString("1_3_0", ResourseVersion)
    PassDataSystem.UpdateUnknowPassReddot()
    local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
    local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
    log(bWriteLog and "UnknowPassTunnelSystem.OnModePostSwitch bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
    if bHaveLockedFeature then
      local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
      UnknowPassLevelupSystem.delayShow = false
    end
    local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
    if UnknowPassMissionSystem.ReturnLobbyMsg then
      local UpassHandle = require("client.network.Protocol.UpassHandle")
      UpassHandle.send_general_task_sync_all_req()
      UnknowPassMissionSystem.ReturnLobbyMsg = false
    end
  elseif status == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    local UpassHandle = require("client.network.Protocol.UpassHandle")
    UpassHandle.combatScore = 0
    local TipsMacro = require("client.slua.logic.tip.TipsMacro")
    local TipsManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.TipsManager)
    TipsManager:CloseTip(TipsMacro.ENUM_TipID.RPBubble)
  end
end
function UnknowPassTunnelSystem.InitOnlyOne()
  local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, UnknowPassTunnelSystem.OnLoginSuccess)
  EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, UnknowPassLevelupSystem.OnBuyPass)
  EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ADD_SCORE_NOTIFY, UnknowPassLevelupSystem.OnAddScore)
  EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_STORE_CLICK_CLOSE_BOX_PANEL, UnknowPassLevelupSystem.CheckShowLevelUp)
  EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_BUY_AGAIN_CLICK, UnknowPassLevelupSystem.OnShopBuyAgain)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UNKNOW_PASS_EXTRASCORE, UnknowPassOpenUISystem.OpenExtraScoreUI)
end
function UnknowPassTunnelSystem.unregistEvent()
  local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, UnknowPassTunnelSystem.OnLoginSuccess)
  EventSystem:unregistEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, UnknowPassLevelupSystem.OnBuyPass)
  EventSystem:unregistEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ADD_SCORE_NOTIFY, UnknowPassLevelupSystem.OnAddScore)
  EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_STORE_CLICK_CLOSE_BOX_PANEL, UnknowPassLevelupSystem.CheckShowLevelUp)
  EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_BUY_AGAIN_CLICK, UnknowPassLevelupSystem.OnShopBuyAgain)
  EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UNKNOW_PASS_EXTRASCORE, UnknowPassOpenUISystem.OpenExtraScoreUI)
end
function UnknowPassTunnelSystem.TryShowLevelUp()
  log(bWriteLog and "[UnknowPassTunnelSystem] ShowLevelUp")
  local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
  if UnknowPassLevelupSystem.delayShow then
    log(bWriteLog and "[UnknowPassTunnelSystem] OpenLevelUpUI")
    UnknowPassLevelupSystem.delayShow = false
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local ParamTable = ui_show_queue_config.GetParamTable(nil, "IsQueueUI")
    UnknowPassLevelupSystem.OpenLevelUpUI(ParamTable)
  end
end
function UnknowPassTunnelSystem.CheckCloseNewbieGuide()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() and LogicNewbie.NeedShowNewbieGuide(20000) and not DataMgr.NewerHaveShowEightDay and DataMgr.IsEightDaySlpaed then
    local EightDaySystem = require("client.slua.logic.activity.newbie.logic_newbie_eight_day")
    EightDaySystem.ShowUI()
    DataMgr.NewerHaveShowEightDay = true
  end
end
function UnknowPassTunnelSystem.CheckClosePassUI(isCloseAll)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local passUI = PassDataSystem.GetPassUI() or {}
  local ReloginCantColseUI = PassDataSystem.GetReloginCantColseUI() or {}
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  for i, v in pairs(passUI) do
    if not isCloseAll and ReloginCantColseUI[v] then
      log(bWriteLog and "[ZH] \228\184\141\228\188\154\229\133\179\233\151\173\231\154\132ui: " .. tostring(v))
      break
    end
    if UIManager.UI_Config[v] then
      UnknowPassUtil.CheckCloseUI(UIManager.UI_Config[v])
    end
  end
end
function UnknowPassTunnelSystem.CheckCanShowPass()
  log(bWriteLog and "UnknowPassTunnelSystem.CheckCanShowPass")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_UNKNOW_PASS) then
    log(bWriteLog and "UnknowPassTunnelSystem.CheckCanShowPass switch close")
    return false
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetRpResourceDownloadState() ~= ENUM_DownloadState.Done then
    local msgData = {}
    msgData.title = LocUtil.GetLocalizeResStr(5077)
    local size = string.format("%.2f", PassDataSystem.GetRPResDownloadSize())
    msgData.msg = LocUtil.LocalizeResFormat(23950, size)
    local ok = function()
      PassDataSystem.DownloadRPRes()
    end
    msgData.styleType = 2
    msgData.clickOkCallback = ok
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(msgData.styleType, msgData.title, msgData.msg, msgData.clickOkCallback)
    log(bWriteLog and "[ZH] No RPDownloadState")
    return false
  end
  if not UnknowPassSystem.IsInCurSession then
    local TimeUtil = require("client.common.time_util")
    local currentTime = TimeUtil.GetServerTimeInSec()
    local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
    if UnknowPassUtil.CheckVersionValid() then
      local start_time = UnknowPassUtil.GetNextSeasonStartTime()
      log(bWriteLog and "EventShowUnknowPassIsNotInSession" .. start_time)
      local lastTime = start_time - currentTime
      lastTime = lastTime < 86400 and lastTime or 0
      local text = LocUtil.LocalizeResFormat(7289, TimeUtil.FormatCountDownTime_D_or_HMS(lastTime, 1))
      ShowNotice(text)
    else
      local text = LocUtil.LocalizeResFormat(101706)
      ShowNotice(text)
    end
    local PassHander = require("client.network.Protocol.PassHander")
    PassHander.send_upass_open_check_req()
    return false
  end
  return true
end
function UnknowPassTunnelSystem.CheckShowNewSeasonVideo()
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "UnknowPassTunnelSystem.CheckShowNewSeasonVideo UI responsiveness testing")
    return false
  end
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  if UnknowPassOpenUISystem.GetIsOpenBonusPassAward() then
    return false
  end
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  if UnknowPassBuySystem.IsBuyEliteCloseUI then
    return false
  end
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  if UnknowPassAwardSystem.IsBanVedioAndAnmiOnGrowthRPGuide() then
    return false
  end
  local id = UnknowPassTunnelSystem.GetNewbieGuideIdKey()
  local hasNewSeason = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, id)
  if hasNewSeason or UnknowPassTunnelSystem.bGMFadeInAnim then
    UnknowPassTunnelSystem.bGMFadeInAnim = false
    return true, id
  else
    return false
  end
end
function UnknowPassTunnelSystem.GetNewbieGuideIdKey()
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  UnknowPassUtil.GetUnknowPassNextSeason()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local id = (UnknowPassMacro.UnKnowPass_NextSeason - 1) * 1000
  return id
end
function UnknowPassTunnelSystem.ShowSeasonAnimation(jumpInfo)
  UIManager.ShowUI(UIManager.UI_Config.UPassIntroduceUIBP, false, jumpInfo, true)
end
function UnknowPassTunnelSystem.OpenAnimationEnd(jumpInfo, bIsJumpBack)
  UnknowPassTunnelSystem.SendMessage()
  UnknowPassTunnelSystem.StartInitData(jumpInfo)
  UnknowPassTunnelSystem.HandleShowSlap()
  UnknowPassTunnelSystem.GoInToUnknowPass(jumpInfo, bIsJumpBack)
end
function UnknowPassTunnelSystem.SendMessage()
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  UnknowPassBuySystem.upass_buy_pass_list_req()
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_sync_battle_largess_req()
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local bIsFirstOpenRp = UnknowPassAwardSystem.bIsFirstOpenAward
  local time_ticker = require("common.time_ticker")
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  UnknowPassTunnelSystem.msgTimer = time_ticker.AddTimerOnce(UnknowPassMacro.ENUM_Timer.Main.requestTimer, function()
    local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
    PassPreviewSystem.ResetLeftDetail()
    if bIsFirstOpenRp then
      local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
      PassDataSystem.upass_get_req()
    end
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    local data_config_marco = require("client.logic.data.data_config_marco")
    local general_task_cond_cfg_simple = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple)
    if not general_task_cond_cfg_simple then
      BasicDataServerTable:GetOrReqData(data_config_marco.general_task_cond_cfg_simple)
    end
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if not PublishRegionMacros.IsBLUEHOLE() then
      local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
      local depotItemMap = LogicPHomeStore:GetDepotAndUsedItemCount()
      if not depotItemMap or not next(depotItemMap) then
        local PHomeStoreHandler = require("client.network.Protocol.PHomeStoreHandler")
        local PHomeDetailHandler = require("client.network.Protocol.PHomeDetailHandler")
        local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
        if logic_home_joint:HasJointHome() then
          PHomeDetailHandler.send_manor_item_in_scene_req()
        end
        PHomeStoreHandler.send_get_manor_depot_req()
        PHomeDetailHandler.send_manor_use_item_detail_req(DataMgr.roleData.uid)
      end
    end
  end)
end
function UnknowPassTunnelSystem.HandleShowSlap()
  local UnknowPassSlapSystem = require("client.slua.logic.unknow_pass.NewRPInitFlow.logic_unknowpass_slap")
  UnknowPassSlapSystem.ShowPostOpenSlap()
end
function UnknowPassTunnelSystem.StartInitData(jumpInfo)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.BlockPopTip()
  UnknowPassTunnelSystem.bHasRankData = false
  UnknowPassTunnelSystem.isRelogin = nil
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  if jumpInfo then
    UnknowPassOpenUISystem.openFrom = 1
    UnknowPassOpenUISystem.isJumpBack = jumpInfo.isJumpBack or false
  else
    UnknowPassOpenUISystem.openFrom = 0
    UnknowPassOpenUISystem.isJumpBack = false
  end
  UnknowPassOpenUISystem.isJumpClose = false
  UnknowPassTunnelSystem.  UnknowPassTunnelSystem.isShowRP = true
  local TimeUtil = require("client.common.time_util")
  UnknowPassTunnelSystem.lastEnterPassTime = TimeUtil.GetServerTimeInSec()
end
function UnknowPassTunnelSystem.GoInToUnknowPass(jumpInfo, bIsJumpBack)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission() then
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    if ui_jump_manager.IsEmpty() then
      UIManager.AndroidBackToLobby()
    end
  end
  if not jumpInfo or not jumpInfo.isJumpBack then
    UnknowPassTunnelSystem.ShowUnknowPass()
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
  EventSystem:postEvent(EVENT_BLACK, EVENT_BLACK_GRADIENT)
  UnknowPassTunnelSystem.UpdateCameraAndBg(true)
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  UnknowPassOpenUISystem.JumpInToRPTab(bIsJumpBack)
  UnknowPassTunnelSystem.UpDateRedPoint()
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.CloseAchievementTip()
  local UnknowPassTipsSystem = require("client.logic.unknow_pass.logic_unknow_pass_tips")
  UnknowPassTipsSystem.SaveRightPopUp()
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetCoupleAvatar(CoupleAvatarSystem.ESceneType.Preview)
  if CoupleAvatar then
    CoupleAvatar:HideAvatars()
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_MAIN_OPEN)
end
function UnknowPassTunnelSystem.ShowUnknowPass()
  UIManager.ShowUI(UIManager.UI_Config.Lobby_UnknowPass_UIBP_1_0_0)
end
function UnknowPassTunnelSystem.UpdateCameraAndBg(isShowRPBg, isLoadBonusPassScene)
  log(bWriteLog and "UnknowPassTunnelSystem.UpdateCameraAndBg " .. tostring(isShowRPBg))
  isShowRPBg = isShowRPBg or false
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local sceneName = "Lobby_RP_Common"
  local SeasonCfg
  if isLoadBonusPassScene then
    SeasonCfg = CDataTable.GetTableDataByFilter("BranchSeasonControl", "SeasonID", UnknowPassSystem.Season)
  else
    SeasonCfg = CDataTable.GetTableData("UnknowpassRecordSeasonCfg", UnknowPassSystem.Season)
  end
  if SeasonCfg then
    sceneName = SeasonCfg.SeasonScene
  end
  local lastSceneName = UnknowPassTunnelSystem.sceneName
  if lastSceneName and lastSceneName ~= sceneName then
    UnknowPassTunnelSystem.    LobbySceneManager.LoadStreamLevel(false, lastSceneName)
  end
  if isShowRPBg then
    UnknowPassTunnelSystem.    LobbySceneManager.LoadStreamLevel(true, sceneName, UnknowPassMacro.UnknowPass_CameraId, "Lobby_RP_Light", {
      bAsync = LobbySceneManager.ENUM_ASYNC.RP
    })
  else
    LobbySceneManager.LoadStreamLevel(false, sceneName, nil, nil, {bForceUnload = true})
  end
end
function UnknowPassTunnelSystem.UpDateRedPoint()
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.UpdateFirstAwardReddot()
  passReddotMainSystem.UpdateEasyTicketReddot()
  passReddotMainSystem.UpdatePrivilegeReddot()
  passReddotMainSystem.UpdateExchangeReddot()
end
function UnknowPassTunnelSystem.OnLoginSuccess(evenType, eventID, isRelogin)
  if UIManager.GetUI(UIManager.UI_Config.rate_panel_ui) then
    UIManager.CloseUI(UIManager.UI_Config.rate_panel_ui)
  end
  UnknowPassTunnelSystem.isLoginRequestMessage = true
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_get_req()
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  UnknowPassBuySystem.upass_buy_pass_list_req()
  UnknowPassTunnelSystem.hasShowExpBubble = false
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_prime_query_req()
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.send_general_task_sync_all_req()
  log(bWriteLog and "[ZH] UnknowPassTunnelSystem.isShowRP: " .. tostring(UnknowPassTunnelSystem.isShowRP))
  if isRelogin and UnknowPassTunnelSystem.isShowRP then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    if RoleInfoMainSystem.GetOpenForm() == RoleInfoMainSystem.RoleInfoOpenFromType.Upass then
      UnknowPassTunnelSystem.isRelogin = true
    else
    end
  end
  local logic_unknownpass_action = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_unknownpass_action)
  logic_unknownpass_action:ReInitOnReLogin()
  local UnknowPassRankFirstWeekAwardsSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_rank_first_week_awards")
  UnknowPassRankFirstWeekAwardsSystem.Release()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(5, function()
    UpassHandle.send_upass_sync_battle_largess_req()
    local RPCrtScoreSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_crt_score")
    if RPCrtScoreSystem.CheckActIsOpen() then
      RPCrtScoreSystem.ReqRpCrtScoreData()
    end
  end)
  local logic_unknowpass_full_level_slap = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_unknowpass_full_level_slap)
end
function UnknowPassTunnelSystem.ReinitOnRelogin()
  log(bWriteLog and "[ZH] ReinitOnRelogin")
  local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
  PassPreviewSystem.ChangeIsOnlyShow(true)
  UnknowPassTunnelSystem.UpdateCameraAndBg(true)
  local CommonUseItemSystem = require("client.slua.logic.common.logic_common_use_items")
  CommonUseItemSystem.CloseUI()
  local ItemPrewViewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
  ItemPrewViewSystem.CloseItemPreviewPanel()
  UIManager.CloseUI(UIManager.UI_Config.package_preview_panel)
  local UnknowPassTreasureBoxSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_treasurebox")
  UnknowPassTreasureBoxSystem.CloseTreasureBoxUI()
  UnknowPassTunnelSystem.CheckClosePassUI(false)
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_CLOSEUI)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.HidePanel()
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  UnknowPassOpenUISystem.OpenAward()
  PassPreviewSystem.ResetLeftDetail()
end
function UnknowPassTunnelSystem.RemoveTimer()
  local time_ticker = require("common.time_ticker")
  if UnknowPassTunnelSystem.slapTimer then
    time_ticker.RemoveTimer(UnknowPassTunnelSystem.slapTimer)
    UnknowPassTunnelSystem.slapTimer = nil
  end
  if UnknowPassTunnelSystem.msgTimer then
    UnknowPassTunnelSystem.msgTimer = nil
  end
  if UnknowPassTunnelSystem.JumpTimer then
    UnknowPassTunnelSystem.JumpTimer = nil
  end
end
function UnknowPassTunnelSystem.ClearOtherModuleData()
  local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
  PassPreviewSystem.ClearCameraActionID()
  local logic_unknownpass_action = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_unknownpass_action)
  logic_unknownpass_action:ClearData()
end
function UnknowPassTunnelSystem.Release()
  log(bWriteLog and "UnknowPassTunnelSystem.Release")
  local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
  PassPreviewSystem.ResetLeftDetail()
  PassPreviewSystem.DestroyAvatar()
  local exchangeSyetem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  exchangeSyetem.Release()
end
return UnknowPassTunnelSystem