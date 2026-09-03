function _ENV:ingame_RegisterUI()
  InGameUIManager.SubUIWidgetList(self, {
    {
      Path = "/Game/BluePrints/ControlInput/MainControlPanelTochButton.MainControlPanelTochButton_C",
      Container = "Default",
      ZOrder = 0
    }
  }, {"Fighting", "Training"}, false, true, false)
  ingame = self
end
function ReturnToLobbyConfirm()
  local text = "<LightWhite>" .. LocUtil.GetLocalizeResStr("77001") .. "</>"
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr("101001"), text, ReturnToLobbyConfirm_YES, ReturnToLobbyConfirm_NO)
end
function ReturnToLobbyConfirm_YES()
  LobbySystem.ReturnToLobby()
end
function ChangeSubUIWidgetList(WidgetList)
  InGameUIManager.ChangeSubUIWidgetList(ingame, WidgetList)
end
function ChangeInvalidWorldNameList(WorldNameList)
  InGameUIManager.ChangeInvalidWorldNameList(ingame, WorldNameList)
end
function ShareSelfieShowUI(str, CloseFunc)
  if str then
    BP_ShareSelfieImagePath = str
  end
  local Util = require("client.slua_ui_framework.util")
  local ShareDataList = require("client.logic.share.share_data")
  local shareCfg = {
    capturePath = str,
    isOld = true,
    shareData = ShareDataList.MEDIA_TAG_SHARE_SELFIE,
    campaign = "ingameSELFIE",
    closeFunc = CloseFunc,
    share_type = ShareBtnTLogShareTypeDefine.JuyuanPark
  }
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local isSocialIslandMode = MatchModeMgrSystem.IsSocialIslandMode()
  if isSocialIslandMode then
    local logic_community = require("client.slua.logic.community.logic_community")
    shareCfg.clubShareParams = {
      bShowShareClub = true,
      publishFeedType = logic_community.PublishFeedType.InGamePhoto,
      gameScene = logic_community.GameScene.InGamePhoto
    }
  end
  if GameStatus.IsInMainCity() then
    log(bWriteLog and "[DeanJYT] ShareSelfieShowUI is main city, should save to specific album")
    shareCfg.bSaveToMainCityAlbum = true
  end
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.JuyuanPark, nil, nil)
  Util.ShowShare(shareCfg)
end
function ShareSelfieHideUI()
  log(bWriteLog and "[DeanJYT] ShareSelfieHideUI")
  local ShareComponent = UIManager.GetUI(UIManager.UI_Config.share_component)
  if not ShareComponent then
    log(bWriteLog and "[DeanJYT] ShareSelfieHideUI ShareComponent not found")
    return
  end
  ShareComponent:ClosePanel()
end
function ShareSelfieInitInBattleSpecialUI()
end
function OpenReportBug()
  UIManager.ShowUI(UIManager.UI_Config.battle_report_bug)
end
function EventReportBugClose()
  UIManager.CloseUI(UIManager.UI_Config.battle_report_bug)
end
function EventIngameOpenGMMenu()
end
function OpenReportComplaint()
  local LogicComplaint = require("client.logic.battle.logic_complaint")
  LogicComplaint.ShowComplaint()
end
function OpenReportComplaintFromWatching()
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  if IngameEntry.UseCustomGameResult() then
    IngameEntry.ShowCustomWatchReport()
    return
  end
  local LogicComplaint = require("client.logic.battle.logic_complaint")
  LogicComplaint.ShowComplaint()
end
function OpenReportComplaintFromDeathReplay()
  local LogicComplaint = require("client.logic.battle.logic_complaint")
  LogicComplaint.ShowComplaint(LogicComplaint.EComplaintFrom.DeathReplay)
end
function OpenReportComplaintInvalid()
  local InvalidStr = DataMgr.GetMsgByIDForBattleText(30022)
  ShowNotice(InvalidStr)
end
function OpenReportComplaintInIormation(uid)
  local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
  uid = uid or SocialPersonSpaceSystem.CurrPersonSpaceUID
  local LogicComplaint = require("client.logic.battle.logic_complaint")
  LogicComplaint.ShowComplaint(LogicComplaint.EComplaintFrom.Lobby, {targetUID = uid})
end
function ReturnToLobbyConfirm_NO()
end
function GetLuaMemoryInfo()
  local MemoryInfo = MemoryUtil:GetLuaMemoryInfo()
  return MemoryInfo
end
function EventLuaMemoryProfile()
  MemoryUtil:DumpLuaBaseMemory()
end
function EventDownloadTestInBattle()
  local PufferNetManager = require("client.slua.logic.download.network.logic_puffer_netmanager")
  PufferNetManager.SetImmDLMaxSpeed(102400)
end
function EventLuaObjRefAnalysis()
  MemoryUtil:DumpLuaObjRefFile()
end
IngameCTL = IngameCTL or {}
IngameChat = IngameChat or {}
function IngameChat:on_notify_fight_friend_chat(str_gid, this_msg)
  local macro = require("client.slua.logic.lobby_chat.chat_macro")
  if this_msg.msgType ~= macro.targetShareMsgType and this_msg.msgType ~= macro.islandBattleShareMsgType then
    Client.OnNotifyFightFriendChat(GameFrontendHUD, this_msg)
  end
end
function EventSendFightChat(gid, content)
  local logicFriendChat = require("client.slua.logic.lobby_chat.logic_chat_channel_friend_in_fight")
  logicFriendChat.fight_send_msg(gid, content)
end
function EventSendDirtyToFilter(dirty, context)
  local logicMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  logicMain.filter_text_req(dirty, context)
end
function GetRemarkNameByGID(gid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local nickName = logic_profile:GetFriendNickNameInGame(tonumber(gid))
  if nickName ~= nil then
    return nickName
  end
  return ""
end
function IngameChat:on_filter_finish(filter_text, context)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local ChatComponent = PlayerController:GetChatComponent()
  if slua.isValid(ChatComponent) then
    ChatComponent:OnFilterFinishRsp(filter_text, context)
  end
end
function EventSentChatReport(content, extraParam)
  if nil == content or "" == content then
    return
  end
  local tabContent = {}
  local StringUtil = require("common.string_util")
  tabContent.text = StringUtil.CheckNameRetrunName(content)
  tabContent.voiceLength = 0
  tabContent.quickMsg = false
  tabContent.msgType = 0
  local TimeUtil = require("client.common.time_util")
  tabContent.msgSendTime = TimeUtil.GetServerTimeInSec()
  if extraParam and extraParam == 1 then
    tabContent.sendGift = true
  end
  if extraParam and extraParam == 7 then
    tabContent.bSpeechToText = true
  end
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  local MainModeID = GameInstance and GameInstance:GetMainModeID() or 0
  local SubModeID = GameInstance and GameInstance:GetModeID() or 0
  tabContent.ModeID = MainModeID
  tabContent.  print(bWriteLog and "SentChatReport:", dump(tabContent))
  local chatmacro = require("client.slua.logic.lobby_chat.chat_macro")
  NetUtil.SendPkg("chat_req", g_game_id, chatmacro.Channel.channelReport, 0, tabContent)
end
local m_CacheLobbyReserve = {}
function IngameChat:on_reserve_require_notify(str_gid, str_name)
  if Client.OnInviteNextBattle(GameFrontendHUD, str_gid, str_name) == false then
    local item = {}
    item.    item.    local TimeUtil = require("client.common.time_util")
    item.time = TimeUtil.OSTime()
    m_CacheLobbyReserve[str_gid] = item
  end
end
function IngameChat:HandleCacheLobbyReserve()
  if m_CacheLobbyReserve then
    local tempCache = {}
    local TimeUtil = require("client.common.time_util")
    local currentTime = TimeUtil.OSTime()
    local timeOut = 180
    for k, v in pairs(m_CacheLobbyReserve) do
      if timeOut > currentTime - v.time then
        table.insert(tempCache, #tempCache + 1, v)
      end
    end
    m_CacheLobbyReserve = {}
    if 0 < #tempCache then
      for index = 1, #tempCache do
        local item = tempCache[index]
        IngameChat:on_reserve_require_notify(item.str_gid, item.str_name)
      end
    end
  end
end
function EventSendPlayEmote(emoteIndex)
end
function EventReplyInviteNextBattle(gid, bReply)
  local result = 0
  if bReply == 1 or bReply == true then
    result = 1
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.appointment_game_friend_answer(gid, result)
end
function EventEnterFightChat(str_gid)
  local logicFriendChat = require("client.slua.logic.lobby_chat.logic_chat_channel_friend_in_fight")
  logicFriendChat.on_enter_fight_chat(str_gid)
end
function EventChatRequestPrivacyInGame()
  local savePrivacyAcceptStatus1 = function()
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      PlayerController:BroadcastUIMessage("OnChatPrivacyAccepted", 0, "", "")
    end
  end
  local params = {
    TitleID = 102012,
    PermissionDes = LocUtil.LocalizeResFormat(4073),
    OkBtnText = LocUtil.LocalizeResFormat(4515),
    IconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Speaking_png.Common_Icon_Speaking_png"
  }
  local logic_permission = require("client.slua.logic.permission.logic_permission")
  logic_permission.ShowWidget(logic_permission.PermissionTypeEnum.Microphone, params, savePrivacyAcceptStatus1)
end
function EventQuitFightChat()
  local logicFriendChat = require("client.slua.logic.lobby_chat.logic_chat_channel_friend_in_fight")
  logicFriendChat.on_quit_fight_chat()
end
IngameBeginnerGuide = IngameBeginnerGuide or {isOpenGuide = true}
function EventRetriveFinishedGuide()
  BeginnerGuideSystem.send_refresher_info_req()
end
function EventRecordGuideFinished(guide_id)
  BeginnerGuideSystem.send_record_finished_guide_req(guide_id)
end
function IngameBeginnerGuide:on_retrive_finished_guide_finish(finished_guide, player_level, player_exp_type)
  local exp_type_number = tonumber(player_exp_type) or 0
  Client.NotifyBeginnerFinishedGuideUpdated(GameFrontendHUD, IngameBeginnerGuide.isOpenGuide, finished_guide, player_level, exp_type_number)
end
function BattleShowHitDistributionInfo(bshow)
  if UIManager and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.BattleGunHitInfoRealTime then
    if bshow then
      UIManager.ShowUI(UIManager.UI_Config_InGame.BattleGunHitInfoRealTime)
    else
      UIManager.CloseUI(UIManager.UI_Config_InGame.BattleGunHitInfoRealTime)
    end
  end
end
function ShowBattleGMOutputText(sOutputText)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_BATTLE_GM_PANEL_SHOWOUTPUT, sOutputText)
end
function ShowBattleUI()
  print(bWriteLog and "ShowBattleUI")
  if not GameStatus.IsInFightingNotMainCity() then
    return
  end
  ShowAntiViolenceTips()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.bIsInResultView then
    return
  end
  local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
  if LogicLobbyWatching and DataMgr then
    Client.SetShowFriendObservers(GameFrontendHUD, DataMgr.IsEnableWatch() and LogicLobbyWatching.IsShowWatcherList())
    Client.SetCanWatchEnemy(GameFrontendHUD, LogicLobbyWatching.IsCanWatchEnemy())
  end
  if LobbySystem then
    Client.SetCanWatchEnemy(GameFrontendHUD, LobbySystem.IsCanWatchEnemy())
  end
  InGameUIManager.HandleUIMessage(ingame, "ShowBattleUI")
  if BatttleWindowMgr then
    BatttleWindowMgr.ShowUIWhenInBattle()
  end
  IngameChat:HandleCacheLobbyReserve()
  local waterMask = require("client.slua.umg.Fighting_Watermark.Fighting_Watermark_BP")
  waterMask.CreateWatermark()
  local tmp = CDataTable.GetTableData("BattleGeneralTip", 10001)
end
function ShowAntiViolenceTips()
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  print(bWriteLog and "ShowAntiViolenceTips", region)
  if region ~= PublishRegionMacros.BLUEHOLE then
    return
  end
  local UScriptGameplayStatics = import("ScriptGameplayStatics")
  if UScriptGameplayStatics.IsOfflineBuild() then
    return
  end
  if Client and Client.IsWindowsClientReplay() then
    return
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimer(2.0, function()
    local gameState = slua_GameFrontendHUD:GetGameState()
    local TableUtil = require("common.table_util")
    print(bWriteLog and "ShowAntiViolenceTips", TableUtil.GetTableValue(gameState, "GameModeState"))
    if TableUtil.GetTableValue(gameState, "GameModeState") == "ReadyState" then
      local msgData = {}
      msgData.title = LocUtil.LocalizeResFormat(101001)
      msgData.msg = "BATTLEGROUNDS MOBILE INDIA is not a real-world based game, but a survival simulation game set in a virtual world."
      msgData.styleType = 1
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(msgData.styleType, msgData.title, msgData.msg)
    end
  end)
end
function EventShowAvatarZone()
end
function EventRefreshArtQualityLabel()
  EventSystem:postEvent(EVENTTYPE_INGAME_PHONE_STATE, EVENTID_INGAME_PHONE_STATE_ART_QUALITY)
  if slua_GameFrontendHUD.OnRenderQualityChanged then
    slua_GameFrontendHUD:OnRenderQualityChanged(false)
  end
end
function IngameChat.RefreshFriendObserverDetails()
  log(bWriteLog and "IngameChat.RefreshFriendObserverDetails")
  local nameGames = Client.GetMyFriendObservers(GameFrontendHUD)
  local observerDetails = {}
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  for _, name in pairs(nameGames) do
    local friendData = LogicFriend.GetFriendDataByNickName(name)
    if friendData then
      observerDetails[#observerDetails + 1] = {
        PlayerName = name,
        Gender = friendData.sex
      }
    else
      observerDetails[#observerDetails + 1] = {PlayerName = name, Gender = 1}
    end
  end
  Client.SetMyFriendObserversDetail(GameFrontendHUD, observerDetails)
end
function EventKickPlayerFromGameNotice()
  local confirmClick = function()
    Client.ClientKickPlayerFromGame(GameFrontendHUD)
  end
  local content = LocUtil.GetLocalizeResStr(6275)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), content, confirmClick)
end
function EventKickPlayerFromGameNotice2(sPlayerName)
  local confirmClick = function()
    Client.ClientKickPlayerFromGame(GameFrontendHUD)
  end
  local content = LocUtil.LocalizeResFormat(8800702, sPlayerName)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), content, confirmClick)
end
function StrSplit(str, chr)
  local result = {}
  local findIndex = 0
  local id = 1
  while true do
    findIndex = string.find(str, chr)
    if findIndex == nil then
      result[id] = str
      break
    end
    local subStr = string.sub(str, 0, findIndex - 1)
    str = string.sub(str, findIndex + 1)
    result[id] = subStr
    id = id + 1
  end
  return result
end
nReportBattleNetworkStatusSequence = 0
function ReportBattleNetworkStatus(pingInfo, isResetSequence, fpsInfo, lossInfo)
  if isResetSequence == 1 then
    nReportBattleNetworkStatusSequence = 0
  end
  local IntlHelper = import("IntlHelper")
  local zone_id = IntlHelper.GetCurrentZoneID()
  local gameId = g_game_id or 0
  networkType = FuncUtil.GetNetworkTypeAsNum()
  local uploadSeq = nReportBattleNetworkStatusSequence
  local pinDataArr = StrSplit(pingInfo, "-")
  local avgPing = tonumber(pinDataArr[1])
  local maxPing = tonumber(pinDataArr[2])
  local minPing = tonumber(pinDataArr[3])
  local lostPackRate = tonumber(pinDataArr[4]) / 10000
  local avgNoOutlier = tonumber(pinDataArr[5])
  local stdNoOutlier = tonumber(pinDataArr[6])
  local numNoOutlier = tonumber(pinDataArr[7])
  local fpsDataArr = StrSplit(fpsInfo, "-")
  local fpsJitter = tonumber(fpsDataArr[1])
  local fpsLag = tonumber(fpsDataArr[2])
  local fpsAvgNoOutlier = tonumber(fpsDataArr[3])
  local fpsStdNoOutlier = tonumber(fpsDataArr[4])
  local fpsNumNoOutlier = tonumber(fpsDataArr[5])
  local lossInfoArray = StrSplit(lossInfo, "-")
  local inLoss = lossInfoArray[1]
  local outLoss = lossInfoArray[2]
  local AccelSystem = require("client.slua.logic.gamemaster.logic_accel")
  local accelOpened = AccelSystem.AccelOpened()
  NetUtil.SendPkg("report_battle_ping", zone_id, gameId, networkType, uploadSeq, avgPing, maxPing, minPing, lostPackRate, avgNoOutlier, stdNoOutlier, numNoOutlier, fpsJitter, fpsLag, fpsAvgNoOutlier, fpsStdNoOutlier, fpsNumNoOutlier, inLoss, outLoss, accelOpened)
  nReportBattleNetworkStatusSequence = nReportBattleNetworkStatusSequence + 1
end
function ReportBattlePlayerStatus(playerStatusInfo, gameId)
  NetUtil.SendPkg("report_client_frame_details", playerStatusInfo, tostring(g_game_id))
end
function ConfirmKilledByFriend(killName)
  local clickOKCallback = function()
    Client.ClientConfirmMisKill(GameFrontendHUD, 1)
  end
  local clickCancelCallback = function()
    Client.ClientConfirmMisKill(GameFrontendHUD, 0)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local timeOutCounter = 10
  local timerOutCallback = function(UpdateMsg, kickOutTips1, kickOutTips2, UpdateOKText, okTimerBtn)
    log(bWriteLog and "timerOutCallback-----\230\137\163\233\153\164\229\175\185\230\150\185\228\191\161\232\170\137\231\167\175\229\136\134" .. timeOutCounter)
    if timeOutCounter <= 0 then
      clickOKCallback()
      CommonMsgBoxMgr.HidePanel()
      return
    else
      local OkTimerBtn = LocUtil.GeneralFormat(okTimerBtn, tostring(timeOutCounter), 1)
      UpdateOKText(OkTimerBtn)
      timeOutCounter = timeOutCounter - 1
    end
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local content = LocUtil.GetLocalizeResStr(7023)
  local okBtn = LocUtil.GetLocalizeResStr(110036)
  local cancelBtn = LocUtil.GetLocalizeResStr(110035)
  local okTimerBtn = LocUtil.GetLocalizeResStr(4118)
  local isCommonMsgBoxMgr = true
  content = LocUtil.GeneralFormat(content, killName, 2)
  CommonMsgBoxMgr.Show(2, title, content, clickOKCallback, clickCancelCallback, okBtn, cancelBtn, {
    onTimerInvoke = timerOutCallback,
    UpdateOKText = CommonMsgBoxMgr.UpdateOKText,
    OkTimerBtn = okTimerBtn,
    IsCommonMsgBoxMgr = isCommonMsgBoxMgr
  })
end
function ConfirmLongTimeNoOperation222(playerName)
  local isTimeOut = 0
end
function ConfirmLongTimeNoOperation(timeOutCounter)
  local isTimeOut = 0
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local clickOKCallback = function()
    if isTimeOut == 0 then
      log(bWriteLog and "\231\161\174\232\174\164\232\191\148\229\155\158\230\184\184\230\136\143")
      CommonMsgBoxMgr.HidePanel()
      Client.ClientConfirmReturnToGame(GameFrontendHUD)
    else
      log(bWriteLog and "\231\161\174\232\174\164\232\191\148\229\155\158\229\164\167\229\142\133")
      CommonMsgBoxMgr.HidePanel()
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.ShowLoading(true)
      NetUtil.SendPkg("giveup_enter_game")
      Client.ReturnToLobby(GameFrontendHUD)
    end
  end
  local timerOutCallback = function(UpdateMsg, kickOutTips1, kickOutTips2, UpdateOKText, okTimerBtn)
    log(bWriteLog and "timerOutCallback-----\229\188\185\230\161\134\229\141\179\229\176\134\232\189\172\229\136\176\229\164\167\229\142\133\229\142\187" .. timeOutCounter)
    if timeOutCounter <= 0 then
      isTimeOut = 1
      UpdateMsg(kickOutTips1)
      UpdateOKText(okTimerBtn)
      return
    else
      local kickOutTips = DataMgr.GetMsgByIDForBattleText(756024)
      kickOutTips2 = LocUtil.GeneralFormat(kickOutTips, tostring(timeOutCounter))
      UpdateMsg(kickOutTips2)
      timeOutCounter = timeOutCounter - 1
    end
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local content = DataMgr.GetMsgByIDForBattleText(756024)
  local okBtn = DataMgr.GetMsgByIDForBattleText(756023)
  local kickOutTips1 = DataMgr.GetMsgByIDForBattleText(756025)
  local okTimerBtn = LocUtil.GetLocalizeResStr(110036)
  local kickOutTips2 = DataMgr.GetMsgByIDForBattleText(756024)
  local isCommonMsgBoxMgr = true
  content = LocUtil.GeneralFormat(content, tostring(timeOutCounter), 1)
  CommonMsgBoxMgr.Show(1, title, content, clickOKCallback, nil, okBtn, nil, {
    onTimerInvoke = timerOutCallback,
    UpdateMsg = CommonMsgBoxMgr.UpdateMsg,
    KickOutTips1 = kickOutTips1,
    KickOutTips2 = kickOutTips2,
    UpdateOKText = CommonMsgBoxMgr.UpdateOKText,
    OkTimerBtn = okTimerBtn,
    IsCommonMsgBoxMgr = isCommonMsgBoxMgr
  })
end
function EventIngameEnterSingleTraining()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.bIsMatchingTrainMode = true
  MatchModeMgrSystem.SyncMatchModeEntry()
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  MatchHandler.send_on_match_req(501, 0, {10080}, DeviceOSInfo.InfoList)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_SelectModeTrain)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SelectModeTrain)
end
function EventIngameShowArenaPlatformPanel()
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_SHOW_ARENA_PLATFORM_PANEL)
end
function GetCurrentPlayerUCLevel()
  local rechargeViplevel = "0"
  local key = "PlayerRechargeVipLevel"
  if DataMgr.roleData.openID ~= nil then
    local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
    local playerPrefsDict = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
    if playerPrefsDict ~= nil then
      rechargeViplevel = playerPrefsDict[key]
    end
  end
  return rechargeViplevel
end
function GetGameMasterVID()
  return FuncUtil.GetDVID()
end
function LuaSaveCrashLog()
  local logInfos = ""
  local openid = DataMgr.roleData.openID or ""
  logInfos = logInfos .. string.format("OpenID:%s\n", tostring(openid))
  return logInfos
end
function LuaTestGetWeaponRecort()
end
function BattleGeneralTipWithTranslation(tipsID, EncodeParams)
  local Params = slua.LuaArchiverDecode(LuaStateWrapper, EncodeParams)
  BattleGeneralTranslateTip(tipsID, Params)
end
function BattleGeneralTranslateTip(tipsID, params)
  local ParamasTable = {}
  for key, value in pairs(params) do
    if value.IsNeedTranslation and tonumber(value.ParamValue) then
      local translation = LocUtil.GetLocalizeResStr(value.ParamValue)
      table.insert(ParamasTable, translation)
    else
      table.insert(ParamasTable, value.ParamValue)
    end
  end
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleGeneralTranslateTip: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:BattleGeneralTip(tipsID, table.unpack(ParamasTable))
  end
end
function BattleGeneralTipWithParams(tipsID, paramTable)
  if not UIManager then
    LogExceptionAndReport("BattleGeneralTip: UIManager Is Nil ", 6)
    return
  end
  if not UIManager.UI_Config_InGame then
    return
  end
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleGeneralTip: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:BattleGeneralTip(tipsID, table.unpack(paramTable))
  end
end
function BattleGeneralSAPTipWithParams(tipsID, paramTable)
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleGeneralSAPTip: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:BattleGeneralSAPTip(tipsID, table.unpack(paramTable))
  end
end
function BattleGeneralTip(tipsID, param1, param2, param3)
  if not UIManager then
    LogExceptionAndReport("BattleGeneralTip: UIManager Is Nil ", 6)
    return
  end
  if not UIManager.UI_Config_InGame then
    return
  end
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleGeneralTip: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:BattleGeneralTip(tipsID, param1, param2, param3)
  end
end
function BattleGeneralTipWithExternTableFromServer(tipsID, EncodeParams)
  local ExternTable = slua.LuaArchiverDecode(LuaStateWrapper, EncodeParams)
  BattleGeneralTipWithExternTable(tipsID, ExternTable)
end
function BattleGeneralTipWithExternTable(tipsID, ExternTable)
  if not UIManager then
    LogExceptionAndReport("BattleGeneralTipWithExternTable: UIManager Is Nil ", 6)
    return
  end
  if not UIManager.UI_Config_InGame then
    return
  end
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleGeneralTipWithExternTable: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:BattleGeneralTipWithExternTable(tipsID, ExternTable)
  end
end
function BattleGeneralSAPTip(tipsID, param1, param2)
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleGeneralSAPTip: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:BattleGeneralSAPTip(tipsID, param1, param2)
  end
end
function BattleStopGeneralTip(tipsID)
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleStopGeneralTip: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:BattleStopGeneralTip(tipsID)
  end
end
function BattleNormalTips(tipsContent, tipsAnimType, controlTime)
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleNormalTips: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowNormalTips(tipsContent, tipsAnimType, controlTime)
  end
end
function BattleNormalTipsByTextID(tipsID, param1, param2, controlTime)
  log(bWriteLog and "BattleNormalTipsByTextID" .. tostring(param1))
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleNormalTipsByTextID: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowNormalTipsByTextID(tipsID, param1, param2, controlTime)
  end
end
function BattleNormalTipsByTextIDAndDefaultConfig(tipsID, param1, param2, controlTime)
  print(bWriteLog and string.format("BattleNormalTipsByTextIDAndDefaultConfig:%d", tipsID))
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleNormalTipsByTextIDAndDefaultConfig: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    local textID = tipsID
    local tipsValue = CDataTable.GetTableData("BattleGeneralTip", tipsID)
    if tipsValue and tipsValue.TextID then
      textID = tipsValue.TextID
      print(bWriteLog and string.format("BattleNormalTipsByTextIDAndDefaultConfig. tipsID:%d, textID:%d", tipsID, textID))
    else
      print(bWriteLog and string.format("BattleNormalTipsByTextIDAndDefaultConfig. Warning: tipsId[%d] not in BattleGeneralTip config", tipsID))
    end
    NewBattlePopTips:ShowNormalTipsByTextIDAndTipsValue(textID, param1, param2, controlTime, tipsValue)
  end
end
function BattleNormalTipsByTextIDAndTipsValue(tipsID, param1, param2, controlTime, tipsValue)
  log(bWriteLog and "BattleNormalTipsByTextIDAndTipsValue" .. tostring(param1))
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleNormalTipsByTextIDAndTipsValue: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowNormalTipsByTextIDAndTipsValue(tipsID, param1, param2, controlTime, tipsValue)
  end
end
function BattleNormalTipsByTextIDAndParams(textID, paramTable, controlTime)
  log(bWriteLog and "BattleNormalTipsByTextIDAndParams " .. tostring(textID))
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleNormalTipsByTextIDAndParams: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowNormalTipsByTextIDAndParams(textID, paramTable, controlTime)
  end
end
function BattleNormalSAPTipsByTextIDAndParams(textID, paramTable, controlTime)
  log(bWriteLog and "BattleNormalSAPTipsByTextIDAndParams" .. tostring(textID))
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleNormalSAPTipsByTextIDAndParams: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowNormalSAPTipsByTextIDAndParams(textID, paramTable, controlTime)
  end
end
function BattleNormalSAPTipsByTextID(textID, param1, param2, controlTime)
  log(bWriteLog and "BattleNormalTipsByTextID" .. tostring(param1))
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleNormalTipsByTextID: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowNormalSAPTipsByTextID(textID, param1, param2, controlTime)
  end
end
function BattleGeneralTipWithSetting(tipsID, EncodeParams)
  local bIsSettingOpen = false
  local SettingParams = slua.LuaArchiverDecode(LuaStateWrapper, EncodeParams)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  for key, value in pairs(SettingParams) do
    if not SettingConfig[value] then
      return
    end
  end
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleGeneralTipWithSetting: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:BattleGeneralTip(tipsID, "", "")
  end
end
function ShowNormalTipsByTextIDAlias(tipsID, param1, param2)
  printf("ShowNormalTipsByTextIDAlias %s,%s,%s", tostring(tipsID), tostring(param1), tostring(param2))
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("ShowNormalTipsByTextIDAlias: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowNormalTipsByTextIDAlias(tipsID, param1, param2)
  end
end
function BattleWariningTipsByTextID(tipsID, param1, param2)
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleWariningTipsByTextID: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowGameWarning(tipsID, 1, param1, param2)
  end
end
function BattleWariningTipsByTextIDWithSpeed(tipsID, animationSpeed, param1, param2)
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleWariningTipsByTextIDWithSpeed: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowGameWarning(tipsID, animationSpeed, param1, param2)
  end
end
function BattleBottomKillTips(messageData)
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("BattleBottomKillTips: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowBottomKillTips(messageData)
  end
end
function ClearBattleGeneralTip()
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("ClearBattleGeneralTip: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ClearTips()
  end
end
function BattleHandleTipInfo(FullMsg)
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local PlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  PlayerController:HandleTipInfo(FullMsg)
end
function IngameCTL.OnIslandPlayerInfoNotify(land_id)
end
function ShowShareResultRanking()
  local IngameShareManager = require("client.logic.share.IngameShareManager")
  IngameShareManager.ShowShareResultRanking(nil, true)
end
function ShowShareResultProtect()
  local IngameShareManager = require("client.logic.share.IngameShareManager")
  IngameShareManager.ShowShareResultProtect(nil, true)
end
function ShowShareResultTeamAthleticsPose()
  local IngameShareManager = require("client.logic.share.IngameShareManager")
  IngameShareManager.ShowShareResultTeamAthleticsPose()
end
function ShowShareResultTeamAthleticsData()
  local IngameShareManager = require("client.logic.share.IngameShareManager")
  IngameShareManager.ShowShareResultTeamAthleticsData()
end
function ShowShareResultInfection()
  local IngameShareManager = require("client.logic.share.IngameShareManager")
  IngameShareManager.ShowShareResultInfection()
end
function ShowShareResultVehicle()
  local IngameShareManager = require("client.logic.share.IngameShareManager")
  IngameShareManager.ShowShareResultVehicle()
end
function ShowShareResultPVE()
  local IngameShareManager = require("client.logic.share.IngameShareManager")
  IngameShareManager.ShowShareResultPVE()
end
InGameGMHandler = InGameGMHandler or {}
function InGameGMHandler.InGameAndroidBack()
  if not BP_Global_AndroidKey_IsValid then
    log(bWriteLog and "EventLobbyAndroidBack: AndroidKey Is Not Valid")
    return
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ANDROID_BACK)
end
function InGameGMHandler.LocalConnectToLobby(url)
  if url == nil or url == "" then
    local BusinessHelper = import("BusinessHelper")
    url = BusinessHelper.GetInGameLocalConnectURL()
  end
  print(bWriteLog and "InGameGMHandler.LocalConnectToLobby:" .. tostring(url))
  NetUtil.ConnectToURL(url)
  local NetManager = require("client.network.comm.NetManager")
  NetManager.Init()
  local PrevSendPkg = NetManager.SendPkg
  local DisablePkgIDTable = {
    [1208] = true
  }
  function NetManager.SendPkg(id, ...)
    if DisablePkgIDTable[id] ~= nil then
      print(bWriteLog and "LocalConnectToLobby Disable Send Pkg:" .. tostring(id))
      return
    end
    PrevSendPkg(id, ...)
  end
  function NetUtil.CheckTime()
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimer(3.0, function()
    logic_connection_waiting:Hide(1)
  end)
end
function TestTopPlat()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.TopPlatformTips01_anima then
    MainControlBaseUI:PlayUserWidgetAnimation(MainControlBaseUI.TopPlatformTips01_anima, 0, 1, 0, 1)
  end
end
function EventIngameOpenNewSetting()
end
function EventToggleReplayGMUI()
  local ReplayGMUISwitchSpectatorUI = require("GameLua.Mod.BaseMod.Client.Replay.ReplayGMUISwitchSpectatorUI")
  ReplayGMUISwitchSpectatorUI.OnToggleReplayGMUI()
  require("GameLua.Mod.BaseMod.Client.Replay.ReplayGMUIDSStrategyTimestamp").OnToggleReplayGMUI()
end
function EventCreateCompletePlaybackReplayStatusInfoUIIfNotExists()
  local CompletePlaybackReplayStatusInfoUI = require("GameLua.Mod.BaseMod.Client.Replay.CompletePlaybackReplayStatusInfoUI")
  CompletePlaybackReplayStatusInfoUI.CreateIfNotExists()
  local tUIConfig = UIManager.UI_Config_InGame.ReplayGMUIKillInfo
  if not tUIConfig then
    return
  end
  local KillInfoUI = UIManager.GetUI(UIManager.UI_Config_InGame.ReplayGMUIKillInfo)
  if KillInfoUI == nil then
    UIManager.ShowUI(UIManager.UI_Config_InGame.ReplayGMUIKillInfo)
  end
end
function EventInitHawkEyePatrolSubsystem()
  require("GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.ClientHawkEyePatrolSubsystem").InitHawkEyePatrolSubsystem()
end
function EventOnClickWatchGameNextHawkEyePatrol()
  print(bWriteLog and "EventOnClickWatchGameNextHawkEyePatrol")
  local ClientHawkEyePatrolSubsystem = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
  if ClientHawkEyePatrolSubsystem then
    ClientHawkEyePatrolSubsystem:WantMatchNextPatrol()
  end
end
function ShowItemTipsByTextID(TipsID, EncodeParams)
  local TableParams = slua.LuaArchiverDecode(LuaStateWrapper, EncodeParams)
  local Param1 = TableParams[1]
  local Param2 = TableParams[2]
  local Param3 = TableParams[3]
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("ShowItemTipsByTextID: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowItemTipsByTextID(TipsID, Param1, Param2, Param3)
  end
end
function ShowItemTipsByTextID2(TipsID, Param1, Param2, controlTime)
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    LogExceptionAndReport("ShowItemTipsByTextID2: BattlePopTipsConfig Is Nil ", 6)
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowItemTipsByTextID2(TipsID, Param1, Param2, controlTime)
  end
end
function ShowItemTipsWithAllTextID(TipsID, EncodeParams)
  local TableParams = slua.LuaArchiverDecode(LuaStateWrapper, EncodeParams)
  local Param1 = TableParams[1]
  local Param2 = TableParams[2]
  local Param3 = TableParams[3]
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    print(bWriteLog and "ShowItemTipsWithAllTextID: BattlePopTipsConfig Is Nil")
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowItemTipsWithAllTextID(TipsID, Param1, Param2, Param3)
  end
end
function ShowTipsByAllTextID(TipsID, EncodeParams)
  local TableParams = slua.LuaArchiverDecode(LuaStateWrapper, EncodeParams)
  local Param1 = TableParams[1]
  local Param2 = TableParams[2]
  local Param3 = TableParams[3]
  local UIConfig = UIManager.UI_Config_InGame.BattlePopTips
  if not UIConfig then
    print(bWriteLog and "ShowTipsByAllTextID: BattlePopTipsConfig Is Nil")
    return
  end
  local NewBattlePopTips = UIManager.GetUI(UIConfig)
  if NewBattlePopTips and slua.isValid(NewBattlePopTips.UIRoot) then
    NewBattlePopTips:ShowTipsByAllTextID(TipsID, Param1, Param2, Param3)
  end
end
function ClientCallPartnerTips(_, EncodeParams)
  ClientCallSidePopupTips(_, EncodeParams)
end
function ClientCallSidePopupTips(_, EncodeParams)
  local ClientSidePopupTipsSubsystem = SubsystemMgr:Get("ClientSidePopupTipsSubsystem")
  if ClientSidePopupTipsSubsystem then
    local TableParams = slua.LuaArchiverDecode(LuaStateWrapper, EncodeParams)
    ClientSidePopupTipsSubsystem:CallTips(TableParams.TextID, TableParams.FaceID, TableParams.RichTextID, TableParams.Param1, TableParams.Param2)
  end
end