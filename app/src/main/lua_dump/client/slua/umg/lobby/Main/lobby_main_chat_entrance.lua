local lobby_main_chat_entrance = {}
local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
local Enum_RedNotifyType = {
  FriendReserve = 1,
  GameResultReserve = 2,
  Other = 3
}
function lobby_main_chat_entrance:ctor(selfType, from)
  self.timerHandle = nil
  self.isRolePannelHide = false
  self.isWardrobeHide = false
  self.chatMsg = nil
  self.isShowHouseKeeperTips = false
  local logic_chat_entrance = self:GetLogicChatEntrance()
  self.from = from or logic_chat_entrance.ENUM_FROM_TYPE.FROM_LOBBY
  self.redTipsType = nil
  self:AddTimerOnce(60, function()
    local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
    logic_chat_channel_friend.req_get_offline_chat_msg_num()
  end)
  self.showCorpsMsg = false
end
function lobby_main_chat_entrance:OnInitialize()
  lobby_main_chat_entrance.__super.OnInitialize(self)
end
function lobby_main_chat_entrance:RegistEvents()
  lobby_main_chat_entrance.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_ENTERANCE_REFRESH_REDPOINT, self.OnRefreshRedPoint, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.OnTeamUpInfoChange, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_GIFT_NOTIFY, self.GiftNotify, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_REDPACKET_RECEIVE_DETAIL_RSP, self.OnReceiveDetailRsp, self)
  self:AddOnClickedEventByControl(self.UIRoot.btn_show_chat, self.OnClickOpenChatMain, self)
  self:AddOnClickedEventByControl(self.UIRoot.btn_quick_msg, self.OnClickOpenQuickMsg, self)
  self:AddOnClickedEventByControl(self.UIRoot.btn_open_chat, self.OnClickOpenChatMain, self)
  self:AddOnClickedEventByControl(self.UIRoot.btn_friend_redpoint, self.OnClickFriendRedpoint, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ShareCard, self.OnClickButton_ShareCard, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ChatRoom, self.OnClickOpenChatRoom, self)
  if self.UIRoot.Button_HouseKeeperChat then
    self:AddOnClickedEventByControl(self.UIRoot.Button_HouseKeeperChat, self.OnClickHouseKeeperChat, self)
  end
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_HORN_MSG_COME, self.ReceiveHornMsg, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_QUIT, self.OnQuitCorps, self)
  self:AddCommonEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_OPEN, self.OnEventChatRoomOpen, self)
  self:AddCommonEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_CLOSE, self.OnEventChatRoomClose, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_QUIT, self.OnMemberQuitRoom, self)
  self:AddCommonEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_DELETE_ROOM, self.OnChatRoomDelete, self)
  self:AddCommonEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_EXIT_SUCCESS, self.OnRoomExitSuc, self)
  self:AddCommonEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_SHARE_CARD_RSP, self.OnShareCardRsp, self)
end
function lobby_main_chat_entrance:OnPostInitialize()
  lobby_main_chat_entrance.__super.OnPostInitialize(self)
  if not self.timerHandle then
    self.timerHandle = self:AddTimerLoop(0, function()
      self:SetMsg()
      self:ShowChatRecruitMsg()
    end, TIMER_INFINITE, 1)
  end
  self:UpdateChatRoomState()
end
function lobby_main_chat_entrance:SetMsg()
  local logic_chat_entrance = self:GetLogicChatEntrance()
  local chatMsg = logic_chat_entrance:GetNewMsg(true)
  local isShow, isRemove = logic_chat_entrance:CheckShowMsg(chatMsg, self.from)
  if not isShow then
    if isRemove then
      logic_chat_entrance:ClearData()
    end
    self.chatMsg = nil
    return
  end
  if logic_chat_entrance.hasNew then
    self:ResetUI()
    local newChatMsg = logic_chat_entrance:GetNewMsg()
    self.chatMsg = newChatMsg
    if not next(newChatMsg) or newChatMsg.InteractiveRed or newChatMsg.Poke and newChatMsg.selfMsg then
      return
    else
      self:SwitchChannel(newChatMsg)
      self:SetLeftIcon(newChatMsg)
      local msg = logic_chat_entrance:GetMsgContent(newChatMsg)
      if msg then
        local logic_main_city_chat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_chat)
        if not logic_main_city_chat:IsMainCityChannel(newChatMsg.msgChannel) then
          self.UIRoot.chat_content:SetText(msg)
        end
      end
    end
  end
end
function lobby_main_chat_entrance:ShowChatRecruitMsg()
  local logic_chat_recruit_msg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_recruit_msg)
  if not logic_chat_recruit_msg:IsNewPlanOpen() then
    return
  end
  logic_chat_recruit_msg:ShowRecruitMsgInChatEntrance()
end
function lobby_main_chat_entrance:ResetUI()
  self.UIRoot.NodeWorld:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.NodeLocallanguage:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.NodeTopic:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.NodeCorps:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.NodeTeam:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.NodePrivate:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.NodeChatRoom:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.NodeClub:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.NodeReturn:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.NodeNewbie:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.UIRoot.chat_content:SetText("")
end
function lobby_main_chat_entrance:SwitchChannel(chatMsg)
  if chatMsg.msgChannel == chat_macro.Channel.channelWorld then
    self.UIRoot.NodeWorld:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelTeam then
    self.UIRoot.NodeTeam:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelPrivate then
    self.UIRoot.NodePrivate:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelChatRoom then
    self.UIRoot.NodeChatRoom:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.channelTopic or chatMsg.msgChannel == chat_macro.channelTopic2 then
    self.UIRoot.NodeTopic:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelCorps then
    self.UIRoot.NodeCorps:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelTeamRecruit then
    self.UIRoot.NodeLocallanguage:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelClub then
    self.UIRoot.NodeClub:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelWorldCup then
    self.UIRoot.NodeTopic:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelUGC then
    self.UIRoot.NodeTopic:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelReturn then
    self.UIRoot.NodeReturn:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif chatMsg.msgChannel == chat_macro.Channel.channelNewbie then
    self.UIRoot.NodeNewbie:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function lobby_main_chat_entrance:SetLeftIcon(chatMsg)
  local bShowRedpacket = chatMsg.msgType == chat_macro.redpacket
  if not (chatMsg.content and chatMsg.content.redpacket) or not chatMsg.content.redpacket.basic_info then
    printf("lobby_main_chat_entrance:SetLeftIcon chatMsg.content or chatMsg.content.redpacket or chatMsg.content.redpacket.basic_info is nil")
    self:SetWidgetVisible(self.UIRoot.Image_RedEnvelope, false)
    self.shakeRedpacketId = nil
    return
  end
  local basic_info = chatMsg.content.redpacket.basic_info
  local msg_type = basic_info.msg_type
  local utils = require("client.slua.logic.crp.ChatRedpacketUtils")
  if msg_type == utils.EMsgType.Metro then
    bShowRedpacket = false
  end
  if bShowRedpacket then
    self:SetWidgetVisible(self.UIRoot.Image_RedEnvelope, true)
    self:PlayUserWidgetAnimation(self.UIRoot.RedEnvelope_Shake, 0, 0, 0, 1)
    self.shakeRedpacketId = chatMsg.content.redpacket.redpacket_id
  else
    self:SetWidgetVisible(self.UIRoot.Image_RedEnvelope, false)
    self.shakeRedpacketId = nil
  end
end
function lobby_main_chat_entrance:OnReceiveDetailRsp(_, _, redpacket_id)
  if redpacket_id ~= self.shakeRedpacketId then
    return
  end
  self.shakeRedpacketId = nil
  self.UIRoot:StopAnimation(self.UIRoot.RedEnvelope_Shake)
end
function lobby_main_chat_entrance:OnRefreshRedPoint()
  log(bWriteLog and "lobby_main_chat_entrance:OnRefreshRedPoint")
  self:RefreshRedPoint()
end
function lobby_main_chat_entrance:RefreshRedPoint()
  local logic_chat_entrance = self:GetLogicChatEntrance()
  local unreadMsg = logic_chat_entrance:GetUnreadMsg()
  log_tree(bWriteLog and "lobby_main_chat_entrance:RefreshRedPoint unreadMsg:", unreadMsg)
  self:SetWidgetVisible(self.UIRoot.Button_HouseKeeperChat, false)
  if self.tipStayTimer ~= nil then
    log(bWriteLog and "lobby_main_chat_entrance:RefreshRedPoint remove tipStayTimer")
    self:RemoveTimer(self.tipStayTimer)
    self.tipStayTimer = nil
  end
  if not unreadMsg then
    log(bWriteLog and "lobby_main_chat_entrance:RefreshRedPoint no unreadMsg")
    self:HideRedNotifyTips()
    return
  end
  if unreadMsg.unreadChannelID == chat_macro.Channel.channelCorps and unreadMsg.unreadCount > 0 and LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "lobby_main_chat_entrance:RefreshRedPoint xmission")
    self:HideRedNotifyTips()
    return
  end
  self.tipConfig = CDataTable.GetTableData("ChatTipConfig", unreadMsg.unreadChannelID)
  if not self.tipConfig then
    log(bWriteLog and "lobby_main_chat_entrance:RefreshRedPoint no tipConfig")
    self:HideRedNotifyTips()
    return
  end
  self:SetWidgetVisible(self.UIRoot.RedPointRoot, true)
  self:PlayUserWidgetAnimation(self.UIRoot.Anim_tipsopen, 0, 1, 0, 1)
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  local ishkp = logic_housekeeper_dialog_lobby:IsHouseKeeper(unreadMsg.uid)
  if ishkp then
    self.UIRoot.TextBlock_8:SetText(LocUtil.GetLocalizeResStr(65236))
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(5)
    self.isShowHouseKeeperTips = true
    local logic_chat_butler_setting = require("client.slua.umg.lobby_chat.logic_chat_butler_setting")
    self:SetWidgetVisible(self.UIRoot.Button_HouseKeeperChat, logic_chat_butler_setting.isOpen)
  else
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local intimacyList = LogicFriend.GetIntimacyHasBuildList()
    local relation = 0
    for k, v in pairs(intimacyList) do
      if v.uid == tonumber(unreadMsg.uid) and v.relation then
        relation = v.relation
      end
    end
    if relation then
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(relation)
    end
    if unreadMsg.isGameResultReserveMsg then
      self.UIRoot.RedPointText:SetText(LocUtil.GetLocalizeResStr(44047))
      self.redTipsType = Enum_RedNotifyType.GameResultReserve
    elseif unreadMsg.isReserveMsg then
      self.UIRoot.RedPointText:SetText(LocUtil.GetLocalizeResStr(44047))
      self.redTipsType = Enum_RedNotifyType.FriendReserve
    else
      local logic_chat_channel_corps = require("client.slua.logic.lobby_chat.logic_chat_channel_corps")
      if unreadMsg.unreadChannelID == chat_macro.Channel.channelCorps and unreadMsg.uid then
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(5)
        self.isShowHouseKeeperTips = true
        self:SetWidgetVisible(self.UIRoot.Button_HouseKeeperChat, true)
        self.UIRoot.TextBlock_8:SetText(LocUtil.GetLocalizeResStr(46880132))
        self.showCorpsMsg = unreadMsg.uid
      else
        self.showCorpsMsg = false
        self.UIRoot.RedPointText:SetText(self.tipConfig.TipText)
        self.redTipsType = Enum_RedNotifyType.Other
      end
    end
  end
  if self.isShowHouseKeeperTips then
    self.tipStayTimer = self:AddTimerOnce(6, function(deltaTime)
      self:HideRedNotifyTips()
    end)
  else
    log(bWriteLog and "lobby_main_chat_entrance:RefreshRedPoint StayTime:" .. tostring(self.tipConfig.StayTime))
    if 0 < self.tipConfig.StayTime then
      self.tipStayTimer = self:AddTimerOnce(self.tipConfig.StayTime, function(deltaTime)
        log(bWriteLog and "lobby_main_chat_entrance:RefreshRedPoint deltaTime:" .. tostring(deltaTime))
        self:HideRedNotifyTips()
      end)
    end
  end
  logic_chat_entrance:ReadMsg()
end
function lobby_main_chat_entrance:HideRedNotifyTips()
  log(bWriteLog and "lobby_main_chat_entrance:HideRedNotifyTips")
  self:SetWidgetVisible(self.UIRoot.RedPointRoot, false)
  self:SetWidgetVisible(self.UIRoot.Button_HouseKeeperChat, false)
  self.redTipsType = nil
  self.isShowHouseKeeperTips = false
end
function lobby_main_chat_entrance:OnTeamUpInfoChange()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isTeamup = TeamUpNewSystem.GetTeamNum() > 1
  if isTeamup then
  else
    self.UIRoot.btn_show_chat:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.btn_quick_msg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:SetShareCardBtnShow()
end
function lobby_main_chat_entrance:OnClickOpenChatMain()
  self:PlayAudio(sound_config.click_v1)
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if not logic_chat_main.CanOpenChat(true) then
    return
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  if self.redTipsType and (self.redTipsType == Enum_RedNotifyType.FriendReserve or self.redTipsType == Enum_RedNotifyType.GameResultReserve) then
    local reason = 0
    if self.redTipsType == Enum_RedNotifyType.GameResultReserve then
      reason = 1
    end
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ChatEntraceReserveMsgClick, reason)
  end
  local channel
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() then
    channel = chat_macro.Channel.channelTeam
  end
  if self.chatMsg and self.chatMsg.isReserveMsg then
    log(bWriteLog and "[v_wllwu] lobby_main_chat_entrance:OnClickOpenChatMain, click ReserveMsgType")
    logic_chat_main.OpenChatMainByFriendId(self.chatMsg.uid)
  elseif self.isShowHouseKeeperTips then
    log(bWriteLog and "lobby_main_chat_entrance:OnClickOpenChatMain OpenChatMainByHouseKeeperId")
    self:OpenChatMainByHouseKeeperId()
  else
    logic_chat_main.OpenChatMain(channel)
  end
  if LogicTxMissionMain.IsInXMission() then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.TPlan_Open_Chat)
  else
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyChat)
  end
end
function lobby_main_chat_entrance:OnClickOpenQuickMsg()
  self:PlayAudio(sound_config.click_v1)
end
function lobby_main_chat_entrance:OnClickFriendRedpoint()
  local logic_chat_entrance = self:GetLogicChatEntrance()
  local ENUM_CORP_MSG_TYPE = logic_chat_entrance.ENUM_CORP_MSG_TYPE
  if self.showCorpsMsg then
    local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
    local extra
    if self.showCorpsMsg == ENUM_CORP_MSG_TYPE.TOP_CHAT_MSG then
      extra = {showChat = true, topmsg_highlight = true}
    elseif self.showCorpsMsg == ENUM_CORP_MSG_TYPE.NEW_NOTICE_MSG then
      extra = {showChat = true, notice_highlight = true}
    end
    self.showCorpsMsg = false
    if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_CORPS) then
      return
    end
    LobbySystem.CloseOtherMenu()
    logic_corps_tab_mgr.OpenCorpsUI(_, extra)
    return
  end
  self:PlayAudio(sound_config.click_v1)
  logic_chat_entrance:OpenChatWinByTipConfig(self.tipConfig)
  self.tipConfig = nil
end
function lobby_main_chat_entrance:GiftNotify(eventType, eventID, chat_gift_notify_ani)
  if not UIManager.IsUIShow(UIManager.UI_Config.ui_chat_main) and UIManager.IsUIShow(UIManager.UI_Config.Lobby_Main_UIBP) then
    chat_gift_notify_ani.UIRoot.CanvasPanel_Chat_Entrance:AddChild(chat_gift_notify_ani.UIRoot.Border_Root)
    local game_frontend_hud = require("game_frontend_hud")
    game_frontend_hud.AddToContainer(UIContainers.Default, chat_gift_notify_ani.UIRoot, 20)
    chat_gift_notify_ani.containerName = UIContainers.Default
  end
end
function lobby_main_chat_entrance:OnShow()
  lobby_main_chat_entrance.__super.OnShow(self)
  self:RefreshRedPoint()
  self:ResetUI()
  self:PlayUserWidgetAnimation(self.UIRoot.DX_Transitions_Enter, 0, 1, 0, 1)
  self.UIRoot.TextBlock_7:SetText(LocUtil.LocalizeResFormat(44364, LocUtil.LocalizeResFormat(33146)))
  self.UIRoot.TextBlock_5:SetText(LocUtil.LocalizeResFormat(44364, LocUtil.LocalizeResFormat(33145)))
  self.UIRoot.TextBlock_4:SetText(LocUtil.LocalizeResFormat(44364, LocUtil.LocalizeResFormat(33147)))
  self.UIRoot.TextBlock_6:SetText(LocUtil.LocalizeResFormat(44364, LocUtil.LocalizeResFormat(33148)))
  if LogicTxMissionMain.IsInXMission() then
    self.UIRoot.Root.Slot:SetPosition(FVector2D(0, -68))
    self.UIRoot.HorizontalBox_0.Slot:SetPosition(FVector2D(-175, -68))
  else
    self.UIRoot.Root.Slot:SetPosition(FVector2D(0, -88))
    self.UIRoot.HorizontalBox_0.Slot:SetPosition(FVector2D(-175, -88))
  end
  self:AutoSpeak()
end
function lobby_main_chat_entrance:Close()
  if self.timerHandle then
    self:RemoveTimer(self.timerHandle)
    self.timerHandle = nil
  end
  self.isRolePannelHide = false
  self.isWardrobeHide = false
  self.tipStayTimer = nil
  self.tipConfig = nil
  self.isShowHouseKeeperTips = false
  lobby_main_chat_entrance.__super.Close(self)
end
function lobby_main_chat_entrance:ReceiveHornMsg(eventType, eventID, channel_type, chat_content, avatar_data, self_msg, topic)
  if self.ins_chat_horn_msg_tips == nil then
    self.ins_chat_horn_msg_tips = self:CreateChildWindow(self.UIRoot.CanvasPanel_Speaker, UIManager.UI_Config.chat_entrance_horn)
  end
  if self.ins_chat_horn_msg_tips ~= nil then
    self.ins_chat_horn_msg_tips:InitTips(channel_type, chat_content, avatar_data, self_msg, topic)
    self.ins_chat_horn_msg_tips:SelfHitTestInvisible()
  end
end
function lobby_main_chat_entrance:OnOpenRolePannel()
  self:Hide()
  self.isRolePannelHide = true
end
function lobby_main_chat_entrance:OnCloseRolePannel()
  if self.isRolePannelHide then
    self.isRolePannelHide = false
  end
  if not self.isRolePannelHide and not self.isWardrobeHide then
    self:SelfHitTestInvisible()
  end
end
function lobby_main_chat_entrance:OnQuitCorps()
  self:ResetUI()
end
function lobby_main_chat_entrance:GetLogicChatEntrance()
  return ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
end
function lobby_main_chat_entrance:OnEventChatRoomOpen()
  self:SetWidgetVisible(self.UIRoot.Button_ChatRoom, false)
end
function lobby_main_chat_entrance:OnEventChatRoomClose()
  log(bWriteLog and "lobby_main_chat_entrance:OnEventChatRoomClose")
  self:UpdateChatRoomState()
end
function lobby_main_chat_entrance:UpdateChatRoomState()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local bInChatRoom = logic_chat_channel_chat_room.IsInVoiceRoom()
  printf("lobby_main_chat_entrance:UpdateChatRoomState bInChatRoom\239\188\154%s", bInChatRoom)
  if bInChatRoom then
    self:SetWidgetVisible(self.UIRoot.Button_ChatRoom, true, true)
    self:PlayUserWidgetAnimation(self.UIRoot.chatVoiceRoomLoop, 0, 0, 0, 1)
    self:ShowRoomChatGuide()
  else
    self:SetWidgetVisible(self.UIRoot.Button_ChatRoom, false)
  end
end
function lobby_main_chat_entrance:ShowRoomChatGuide()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.ChatRoomGuide
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  local hasGuide = saveData and saveData.hasGuide
  self:SetWidgetVisible(self.UIRoot.Lobby_Main_Tips_ChatRoom_UIBP, not hasGuide)
end
function lobby_main_chat_entrance:OnClickOpenChatRoom()
  self:PlayAudio(sound_config.click_v1)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local roomId = logic_chat_channel_chat_room.GetMyChatRoomId()
  if roomId == "0" then
    return
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  logic_chat_main.OpenChatMain(chat_macro.Channel.channelChatRoom)
  self:RecordRoomChatGuide()
end
function lobby_main_chat_entrance:RecordRoomChatGuide()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.ChatRoomGuide
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData and saveData.hasGuide then
    return
  end
  saveData = saveData or {}
  saveData.hasGuide = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
end
function lobby_main_chat_entrance:AutoSpeak()
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local isReturn = logic_player_return.isPlayerReturnOpenNew()
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  local hasCorps = LogicCorps.HasCorps()
  log(bWriteLog and string.format("lobby_main_chat_entrance:AutoSpeak isReturn:%s, hasCorps:%s", tostring(isReturn), tostring(hasCorps)))
  if hasCorps and isReturn then
    local TableUtil = require("common.table_util")
    local rejoinStartTime = TableUtil.GetTableValue(DataMgr.roleData, "back_user_data", "rejoin_start_time")
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCorpsBackUserAutoSpeek) or {}
    if not rejoinStartTime then
      log(bWriteLog and "lobby_main_chat_entrance:AutoSpeak rejoinStartTime is nil")
    end
    if save_data.rejoin_start_time and save_data.rejoin_start_time == rejoinStartTime and save_data.has_send then
    else
      local logic_chat_channel_coprs = require("client.slua.logic.lobby_chat.logic_chat_channel_corps")
      local extra = {
        loc_id = 86317,
        nick_name = DataMgr.roleData.nickName,
        source = "returning_auto_speak"
      }
      logic_chat_channel_coprs.SendNewsMsg(nil, extra)
      save_data.has_send = true
      save_data.rejoin_start_time = rejoinStartTime
      PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.eCorpsBackUserAutoSpeek)
    end
  end
end
function lobby_main_chat_entrance:OnMemberQuitRoom(_, _, param)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsMyVoiceRoomEvent(param) then
    return
  end
  log(bWriteLog and "lobby_main_chat_entrance:OnMemberQuitRoom")
  self:SetWidgetVisible(self.UIRoot.Button_ChatRoom, false)
end
function lobby_main_chat_entrance:OnChatRoomDelete()
  log(bWriteLog and "lobby_main_chat_entrance:OnChatRoomDelete")
  self:SetWidgetVisible(self.UIRoot.Button_ChatRoom, false)
end
function lobby_main_chat_entrance:OnRoomExitSuc()
  log(bWriteLog and "lobby_main_chat_entrance:OnRoomExitSuc")
  self:SetWidgetVisible(self.UIRoot.Button_ChatRoom, false)
end
function lobby_main_chat_entrance:OnClickHouseKeeperChat()
  self:PlayAudio(sound_config.click_v1)
  self:OpenChatMainByHouseKeeperId()
end
function lobby_main_chat_entrance:OpenChatMainByHouseKeeperId()
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  local curHousekeeperId = logic_housekeeper_dialog_lobby:GetCurHousekeeperId()
  if curHousekeeperId <= 0 then
    log(bWriteLog and "lobby_main_chat_entrance:OpenChatMainByHouseKeeperId no id")
    return
  end
  local logic_main_chat = require("client.slua.logic.lobby_chat.logic_chat_main")
  logic_main_chat.OpenChatMainByHouseKeeperId(curHousekeeperId)
end
function lobby_main_chat_entrance:OnClickButton_ShareCard()
  self:PlayAudio(sound_config.click_v1)
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  logic_return_team_recommend:OpenShareCardUI(return_activity_macro.Enum_ShareCard_FromType.TeamUp)
end
function lobby_main_chat_entrance:OnTeamupTeaminfoSync()
  self:SetShareCardBtnShow()
end
function lobby_main_chat_entrance:OnShareCardRsp()
  self:SetShareCardBtnShow()
end
function lobby_main_chat_entrance:SetShareCardBtnShow()
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  self:SetWidgetVisible(self.UIRoot.Button_ShareCard, logic_return_team_recommend:IsShowShareCardEntry(), true)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUIChatEnterance = class(ui_base, nil, lobby_main_chat_entrance)
return CUIChatEnterance