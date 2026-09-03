local FriendsListItem_BP = require("client.slua.umg.lobby.FriendList.Item.FriendListItem_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
local logic_friend_list_utils = require("client.slua.logic.friend.refactor.logic_friend_list_utils")
function FriendsListItem_BP:ShowActionWaiting(widget, UID)
  self:SetWidgetVisible(widget.WidgetSwitcher_Action, true)
  widget.WidgetSwitcher_Action:SetActiveWidgetIndex(3)
  self:AddTimerOnce(5.5, function()
    if not self or not self.UIRoot then
      return
    end
    if not (self.data and self.data.uid) or self.data.uid ~= UID then
      return
    end
    self:OnRefresh(self.data)
  end)
end
function FriendsListItem_BP:OnClickButton_Birthday()
  self:PlayAudio(sound_config.click_v1)
  self.UIRoot:StopAnimation(self.UIRoot.Anim_Loop)
  local logic_main_city_player = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_player)
  local ChatMenuSystem = require("client.slua.logic.lobby_chat.logic_chat_menu")
  logic_main_city_player:ShowPlayerInfo(self.data.uid, {}, ChatMenuSystem.EShowLocationType.Friend)
end
function FriendsListItem_BP:OnClickButton_ME_ON_ISLAND()
  self:PlayAudio(sound_config.click_v1)
end
function FriendsListItem_BP:OnClickButton_Island()
  self:PlayAudio(sound_config.click_v1)
  printf("FriendsListItem_BP:OnClickButton_Island called, self._isLandState:%s, ", self._isLandState)
  if not self._isLandState then
    printf("FriendsListItem_BP:OnClickButton_Island return, self._isLandState is nil")
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleAll() then
    printf("FriendsListItem_BP:OnClickButton_Island return, QRcodeRestrictManager:IsRestrictBatlleAll()")
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  if not self.data or type(self.data) ~= "table" or not next(self.data) then
    printf("FriendsListItem_BP:OnClickButton_Island return, self.data is nil")
    return
  end
  if self._isLandState == 1 then
    local logic_chat_channel_social_island_chat = require("client.slua.logic.lobby_chat.logic_chat_channel_social_island_chat")
    local num = #logic_chat_channel_social_island_chat.islandMember
    local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
    local max = SocialIslandHandler.GetMaxPlayer()
    if num >= max then
      local clickOkCallback = function()
        SocialIslandHandler.ReqEnterSystemIsland()
      end
      local title = LocUtil.GetLocalizeResStr(5077)
      local content = LocUtil.GetLocalizeResStr(9864)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, title, content, clickOkCallback)
    else
      SocialIslandHandler.send_socialland_invite_req(self.data.uid)
    end
  elseif self._isLandState == 2 then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if LogicUGCMatch:HasUGCMatchInfo() then
      printf("FriendsListItem_BP:OnClickButton_Island return, LogicUGCMatch:HasUGCMatchInfo()")
      ShowNotice(48409)
      return
    end
    local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
    SocialIslandHandler.send_socialland_apply_req(self.data.uid, 1)
  elseif self._isLandState == 3 then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    local status = PlayerStatusMgr:GetStatusData(self.data.uid)
    if not status then
      printf("FriendsListItem_BP:OnClickButton_Island return, status is nil")
      return
    end
    local islandStr = LocUtil.GetLocalizeResStr(9558)
    if status.socialland_type == 2 then
      islandStr = LocUtil.GetLocalizeResStr(9559)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
    CommonMsgBoxMgr.Show(4, "", LocUtil.LocalizeResFormat(9552, islandStr, islandStr), function()
      SocialIslandHandler.send_socialland_invite_req(self.data.uid)
    end, function(_)
      SocialIslandHandler.send_socialland_apply_req(self.data.uid, 1)
    end, LocUtil.GetLocalizeResStr(9566), LocUtil.GetLocalizeResStr(9565))
  elseif self._isLandState == 4 then
    local SocialIslandTools = require("GameLua.Mod.SocialIsland.GamePlay.SocialIslandTools")
    if not SocialIslandTools.IsPlayerIdleClient() then
      printf("FriendsListItem_BP:OnClickButton_Island return, SocialIslandTools.IsPlayerIdleClient()")
      ShowNotice(34298)
      return
    end
    local IslandMacro = require("GameLua.Mod.SocialIsland.Client.IslandMacro")
    NetUtil.MoveFollowTarget(IslandMacro.ENUM_FollowType.FollowPlayer, tonumber(self.data.uid))
  end
end
function FriendsListItem_BP:OnClickButton_Reservation()
  log(bWriteLog and "FriendsListItem_BP:OnClickButton_Reservation called")
  self:PlayAudio(sound_config.click_v1)
  local player = self.data
  if not player or type(player) ~= "table" or not next(player) then
    print(bWriteLog and "teamup_side_bar:ReserveFriend no player")
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local state = LogicFriend.GetReserveState(self.data.uid)
  if state ~= 1 then
    return
  end
  if player.game_sub_mode == 26001 then
    print(bWriteLog and "teamup_side_bar:ReserveFriend in bp mode")
    ShowNotice(39036)
    return
  end
  local SingleTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  if SingleTrainTool.IsSelfInTraining() then
    log(bWriteLog and "FriendsListItem_BP:OnClickButton_Reservation in single training")
    ShowNotice(43911)
    return
  else
    log(bWriteLog and "FriendsListItem_BP:OnClickButton_Reservation not in single train")
  end
  if not self.UIRoot then
    print(bWriteLog and "FriendListItem_ClickFunc:OnClickButton_Reservation UIRoot is nil")
    return
  end
  self.UIRoot.TextBlock_Reserve:SetText(LocUtil.LocalizeResFormat(7555))
  self:SetWidgetVisible(self.UIRoot.Image_Reserve, false)
  self.UIRoot.TextBlock_Reserve:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 1)))
  self:AddTimerOnce(61.5, function()
    if not self or not self.UIRoot then
      return
    end
    if not (self.data and self.data.uid) or self.data.uid ~= player.uid then
      return
    end
    self:OnRefresh(self.data)
  end)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if from == FLMacros.ENUM_OPEN_FROM.ISMOREPLAYERNUM then
    LogicFriend.ReserveFriend(player.uid, TeamUpNewSystem.E_InviteFromType.SwtichModeAppointment)
  else
    LogicFriend.ReserveFriend(player.uid, TeamUpNewSystem.E_InviteFromType.Appointment)
  end
  local jumpBackData = {
    configName = "Lobby_InviteFriend_BP",
    ctorData = {
      [1] = from,
      [2] = logic_friend_list_ui:GetTabID(),
      [3] = player.uid
    }
  }
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  logic_chat_main.RecordJumpBackData(jumpBackData)
  logic_chat_main.OpenChatMainByFriendId(player.uid)
  UIManager.CloseUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.FriendSideBarReserveClick)
end
function FriendsListItem_BP:OnClickButton_messenger(btnUI)
  self:PlayAudio(sound_config.click_v1)
  if btnUI then
    btnUI:Hide()
  end
  local player = self.data
  local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
  if not Logic_Offline_Invite.IsGlobalInviteOpened(player.uid) then
    ShowNotice(64091)
    return
  end
  local title = LocUtil.GetLocalizeResStr(4365)
  local msg = LocUtil.GetLocalizeResStr(33990)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, msg, function()
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_share_team_invite_link_req(player.uid)
  end, nil, nil, nil, {
    showUIKey = "com_msg_small_box_slua"
  })
  log(bWriteLog and "ruikang OnClickMessageInvite5")
  if player.from then
    log(bWriteLog and "ruikang OnClickMessageInvite8")
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.SideBar_Invite_Messenger_Offline, player.from, "MessageInvite")
  end
end
function FriendsListItem_BP:OnClickButton_WonderfulWorld()
  self:PlayAudio(sound_config.click_v1)
  local logic_ugc_creativewow = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_creativewow)
  if not logic_ugc_creativewow:CheckHaveDownload() then
    log(bWriteLog and "teamup_side_bar:ClickWonderfulWorld have not download")
    return
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local Status = PlayerStatusMgr:GetStatusData(self.data.uid)
  if not Status then
    log(bWriteLog and "teamup_side_bar:ClickWonderfulWorld player status not found")
    return
  end
  local logic_creative_wow_friend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_creative_wow_friend)
  local CreativeWoWHandler = require("client.network.Protocol.CreativeWoWHandler")
  log(bWriteLog and "teamup_side_bar:ClickWonderfulWorld cwow_type", Status.cwow_type)
  local WoWStatus = logic_creative_wow_friend:GetStatus(Status.cwow_type, Status.game_id, Status.cwow_ds_partition_id)
  log(bWriteLog and "teamup_side_bar:ClickWonderfulWorld dom WoWStatus: " .. tostring(WoWStatus))
  if WoWStatus == logic_creative_wow_friend.ENUM_CWOW_STATUS.ME_ON_CWOW then
    CreativeWoWHandler.send_cwow_invite_req(Status.uid, 1)
  elseif WoWStatus == logic_creative_wow_friend.ENUM_CWOW_STATUS.TARGET_ON_CWOW then
    CreativeWoWHandler.send_cwow_apply_req(Status.uid, self.from, 1)
  elseif WoWStatus == logic_creative_wow_friend.ENUM_CWOW_STATUS.ON_DIFFERENT_CWOW then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      Status.uid
    }, function(profileList)
      if profileList and 0 < #profileList and profileList[1] ~= nil then
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(4, "", LocUtil.LocalizeResFormat(511096, profileList[1].nickName), function()
          CreativeWoWHandler.send_cwow_invite_req(Status.uid, 1)
        end, function(_)
          CreativeWoWHandler.send_cwow_apply_req(Status.uid, self.from, 1)
        end, LocUtil.GetLocalizeResStr(9566), LocUtil.GetLocalizeResStr(9565))
      end
    end, Enum_PROFILE_REPORT_CFG.UGC)
  elseif WoWStatus == logic_creative_wow_friend.ENUM_CWOW_STATUS.ON_SAME_CWOW then
    log(bWriteLog and "teamup_side_bar: dom ClickWonderfulWorld \229\156\168\229\144\140\228\184\128\228\184\170\229\165\135\229\166\153\228\184\150\231\149\140")
  else
    log(bWriteLog and "teamup_side_bar: dom ClickWonderfulWorld NA")
  end
end
function FriendsListItem_BP:OnClickButton_Homeland()
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "FriendsListItem_BP:OnClickButton_Homeland")
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(true) then
    return
  end
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local home_macros = require("client.slua.logic.home.home_macros")
  self.reqManorInfoType = home_macros.ENUM_FOLLOW_REQ_TYPE.FriendList
  self.reqManorInfoUID = self.data.uid
  self.rspManorDetail = nil
  logic_home_entry:ReqGetFriendManorInfo(self.data.uid, self.reqManorInfoType)
end
function FriendsListItem_BP:OnGetFriendManorInfo(_, _, reqManorInfoType, manor_owner_id, manor_inst_id)
  log(bWriteLog and "teamup_side_bar:OnGetFriendManorInfo type: " .. reqManorInfoType)
  if not self.reqManorInfoType or self.reqManorInfoType ~= reqManorInfoType then
    return
  end
  if not manor_owner_id or not manor_inst_id then
    log(bWriteLog and "teamup_side_bar:OnGetFriendManorInfo nil manor detail")
    return
  end
  self.rspManorDetail = {manorOwnerId = manor_owner_id, manorInstId = manor_inst_id}
  local logic_home_detail = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_detail)
  logic_home_detail:SendGetManorUseItems(self.reqManorInfoUID, function(_, use_items)
    if not slua.isValid(self.UIRoot) then
      return
    end
    self.use_items_arr = {}
    if use_items then
      local index = 1
      for itemID, v in pairs(use_items) do
        self.use_items_arr[index] = itemID
        index = index + 1
      end
    end
    self:CheckCanClickHome(self.reqManorInfoUID)
  end)
end
function FriendsListItem_BP:CheckCanClickHome()
  local logic_home_status = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_status)
  logic_home_status:CheckEnterHome(self.reqManorInfoUID, self.use_items_arr, self.rspManorDetail)
end
function FriendsListItem_BP:OnClickButton_InviteToHome()
  log(bWriteLog and "FriendsListItem_BP:OnClickButton_InviteToHome")
  self:PlayAudio(sound_config.click_v1)
  local PHomeEditPlanInviteHandler = require("client.network.Protocol.PHomeEditPlanInviteHandler")
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  logic_home_joint:GetMemberListByUid(self.data.uid, function(manor_id, memberList)
    local PlanPH_EditHome_Config = require("GameLua.Mod.PlanPH.Gameplay.Config.PlanPH_EditHome_Config")
    PHomeEditPlanInviteHandler.send_manor_invite_req(self.data.uid, PlanPH_EditHome_Config.EditHomePurposeType.Visit, memberList)
  end)
end
function FriendsListItem_BP:OnClickButton_FollowToCollectionHall()
  log(bWriteLog and string.format("FriendsListItem_BP:OnClickButton_FollowToCollectionHall"))
  self:PlayAudio(sound_config.click_v1)
  local PlanCH_Friend_Visit_Client_Handler = require("client.network.Protocol.PlanCH_Friend_Visit_Client_Handler")
  PlanCH_Friend_Visit_Client_Handler.send_get_friend_collect_hall_info_req(self.data.uid)
end
function FriendsListItem_BP:OnClickButton_InviteToCollectionHall()
  log("FriendsListItem_BP:OnClickButton_InviteToCollectionHall")
  self:PlayAudio(sound_config.click_v1)
  local PlanCHInviteHandler = require("client.network.Protocol.PlanCHInviteHandler")
  PlanCHInviteHandler.send_collect_hall_invite_req(self.data.uid)
end
function FriendsListItem_BP:OnClickButton_Invite()
  self:PlayAudio(sound_config.click_v1)
  logic_friend_list_utils.HideLobby_InviteFriend_BP_Menu()
  local player = self.data
  self:ShowActionWaiting(self.UIRoot, player.uid)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() and LogicNewbie.NeedShowNewbieGuide(20005) then
    DataMgr.SetNewbieGuide(35, 20005)
    logic_friend_list_utils.HideLobby_InviteFriend_BP_Newbie()
  end
  local isInRoomWaiting = RoomSystem.IsShowWaiting()
  local isInMatching = LobbySystem.isInMatch
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if isInRoomWaiting then
    log(bWriteLog and "Click Invite Friend Go Room UID:" .. tostring(player.uid))
    RoomSystem.room_invite_request(player.uid)
  elseif from == FLMacros.ENUM_OPEN_FROM.UGCPlayHallInvite then
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    if UGCPlayHallRoom:IsInFriendInviteCD(player.uid) then
      ShowNotice(8500487)
      return
    else
      UGCPlayHallRoom:InviteFriendToUGCPlayRoomReq(player.uid)
    end
  elseif isInMatching then
    log(bWriteLog and "In matching")
    ShowNotice(110122)
  elseif TeamUpNewSystem.CanInviteFriend(player.uid) then
    log(bWriteLog and "Invite UID:" .. tostring(player.uid))
    log(bWriteLog and "[liyang] form = " .. from)
    if from == FLMacros.ENUM_OPEN_FROM.TPLAN then
      TeamUpNewSystem.team_invite_request(player.uid, TeamUpNewSystem.E_InviteFromType.TPlan)
    elseif from == FLMacros.ENUM_OPEN_FROM.TPLANISMOREPLAYERNUM then
      TeamUpNewSystem.team_invite_request(player.uid, TeamUpNewSystem.E_InviteFromType.SwtichModeTPlan)
    elseif from == FLMacros.ENUM_OPEN_FROM.CREATIVEWOW then
      TeamUpNewSystem.team_invite_request(player.uid, TeamUpNewSystem.E_InviteFromType.CreativeWoW)
    elseif from == FLMacros.ENUM_OPEN_FROM.WOWMod then
      TeamUpNewSystem.team_invite_request(player.uid, TeamUpNewSystem.E_InviteFromType.WOWTeam)
    elseif from == FLMacros.ENUM_OPEN_FROM.WOWTogether then
      TeamUpNewSystem.team_invite_request(player.uid, TeamUpNewSystem.E_InviteFromType.WOWTogether)
    else
      TeamUpNewSystem.team_invite_request(player.uid, self:GetInviteFromType(self.index))
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENT_ONE_TEAM_INVITE_SENT, player.uid)
  local StatManager = import("StatManager")
  StatManager.GetInstance():ReportEventWithNoParam(33, true)
end
function FriendsListItem_BP:OnClickButton_Apply()
  self:PlayAudio(sound_config.click_v1)
  logic_friend_list_utils.HideLobby_InviteFriend_BP_Menu()
  local player = self.data
  local isInMatching = LobbySystem.isInMatch
  if not player or type(player) ~= "table" or not next(player) then
    return
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(player.uid)
  if not status then
    return
  end
  self:ShowActionWaiting(self.UIRoot, player.uid)
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if PlayerStatusUtil.InHall(status) and status.mod_id then
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    UGCPlayHallRoom:ReplyUGCPlayRoomInvitation(status.mod_id, status.hall_id, status.ph_room_svr_id, {src_def = "friend"}, true)
  elseif PlayerStatusUtil.IsRoom(status) and status.mod_id then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    local StatusHandler = require("client.network.Protocol.StatusHandler")
    PlayerStatusMgr:QueryFriendRoom(player.uid, function(roomId)
      local LogicUGCRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRoom)
      LogicUGCRoom:ReqQueryRoom(tonumber(roomId))
    end)
  elseif isInMatching then
    ShowNotice(110122)
    return
  elseif TeamUpNewSystem.CanInviteFriend() then
    if status.tplan_type and status.tplan_type ~= 0 then
      local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
      if not LogicTxMissionDownload.CheckResHasDownloaded() then
        ShowNotice(45677)
        return
      end
    end
    local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
    local from = logic_friend_list_ui:GetFrom()
    if from == FLMacros.ENUM_OPEN_FROM.TPLAN then
      if not status.tplan_type or status.tplan_type == 0 then
        local title = LocUtil.GetLocalizeResStr(101001)
        local content = LocUtil.GetLocalizeResStr(35198)
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.ShowTPlan(2, title, content, function()
          local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
          LogicTxMissionMain.QuitXMissionByJoinTeam(player.uid)
        end)
        return
      end
      TeamUpNewSystem.team_apply_request(player.uid, TeamUpNewSystem.E_InviteFromType.TPlan)
    elseif from == FLMacros.ENUM_OPEN_FROM.ISLAND then
      if status.tplan_type and status.tplan_type == 1 then
        ShowNotice(11893)
        return
      else
        TeamUpNewSystem.team_apply_request(player.uid, self:GetInviteFromType(self.index))
      end
    elseif from == FLMacros.ENUM_OPEN_FROM.CREATIVEWOW then
      TeamUpNewSystem.team_apply_request(player.uid, TeamUpNewSystem.E_InviteFromType.CreativeWoW)
    else
      TeamUpNewSystem.team_apply_request(player.uid, self:GetInviteFromType(self.index))
    end
  end
end
function FriendsListItem_BP:OnClickButton_TV()
  self:PlayAudio(sound_config.click_v1)
  logic_friend_list_utils.HideLobby_InviteFriend_BP_Menu()
  local player = self.data
  if not player or type(player) ~= "table" or not next(player) then
    return
  end
  local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(player.uid)
  if status and status.game_sub_mode then
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    local mapKey = LogicTxMissionDownload.GetMapKeyByModeID(status.game_sub_mode)
    if mapKey and not LogicTxMissionDownload.CheckResHasDownloaded(mapKey) then
      ShowNotice(45677)
      return
    end
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(5077), LocUtil.GetLocalizeResStr(501124), function()
    local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
    if AccessRestrictionSystem.CheckAccessAndPopTips(AccessRestrictionSystem.EAccessType.FriendWatch) then
      LogicLobbyWatching.enter_battle_watch(player.uid)
    end
  end, nil)
end
function FriendsListItem_BP:OnClickButton_OfflineShare()
  self:PlayAudio(sound_config.click_v1)
end
function FriendsListItem_BP:OnClickButton_Invite_offline(btnUI)
  self:PlayAudio(sound_config.click_v1)
  if btnUI then
    btnUI:Hide()
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(self.data.uid)
  if profile and profile.offline_invite_setting == 1 then
    ShowNotice(33400)
    return
  end
  local intimacyLimit = 0
  local cfg = CDataTable.GetTableData("SettingNotificationParamConfig", "offline_invite_intimacy_min")
  if cfg then
    intimacyLimit = cfg.ParamValue
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendData = LogicFriend.GetFriendData(self.data.uid)
  local intimacy = friendData and friendData.intimacy or 0
  if intimacy == 0 then
    intimacy = profile and profile.intimacy or 0
  end
  if intimacyLimit > intimacy then
    ShowNotice(27159)
    return
  end
  self:ShowActionWaiting(self.UIRoot, self.data.uid)
  TeamUpNewSystem.team_invite_request(self.data.uid, TeamUpNewSystem.E_InviteFromType.FireBaseInvite)
  local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
  Logic_Offline_Invite.RecordInviteTime(self.data.uid)
end
function FriendsListItem_BP:OnClickButton_Go()
  self:PlayAudio(sound_config.click_v1)
  local logic_community = require("client.slua.logic.community.logic_community")
  if logic_community.CheckInClub(self.data.uid) == false then
    log(bWriteLog and "CheckNotInClub")
    return
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode() then
    log(bWriteLog and "[v_ywuyuan] social land is forbidden to jump")
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.ui_room_waiting) then
    log(bWriteLog and "[v_ywuyuan] ui_room_waiting is showing")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "[v_ywuyuan] IsInXMission here!!!")
    return
  end
  local EClubStateValue = logic_community.EClubStateValue
  local cache = logic_community.ClubMemberStatusCache[tostring(self.data.uid)]
  if cache.stateValue == EClubStateValue.CHAT_STATE_ONLINE then
    logic_community.GotoCommunityH5(nil, {
      game_scene = logic_community.GameScene.FriendSideBar
    })
  elseif cache.stateValue == EClubStateValue.CHAT_STATE_WATCH_LIVE then
    logic_community.DoJumpCommunityUrl(cache.jump, logic_community.GameScene.FriendSideBar)
  end
end
function FriendsListItem_BP:OnClickButton_ChatRoom()
  self:PlayAudio(sound_config.click_v1)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(self.data.uid)
  if not status or not status.channel_id then
    return
  end
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  logic_chat_channel_chat_room.SetChatRoomQueryPassword(true)
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  logic_chat_channel_chat_room.send_join_channel_req(tonumber(status.channel_id), "", LogicChatRoomMacro.JoinType.from_sidebar)
end
local _clickTime = 0
local _nClick = 0
function FriendsListItem_BP:OnClickCommon_Avatar_BP()
  self:PlayAudio(sound_config.click_v1)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID ~= FLMacros.ENUM_TAB.ENUM_FRIEND_TAG and tabID ~= FLMacros.ENUM_TAB.ENUM_RECENT_TAG then
    self:OnClickAvatar()
    return
  end
  local player = self.data
  log(bWriteLog and "teamup_side_bar:DoubleClick:" .. tostring(_nClick))
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
  local intervalTime = tonumber(CDataTable.GetTableData("InteractiveParameterTable", "POKE_RESPONSE_TIME").Value)
  if _nClick == 0 then
    log(bWriteLog and "teamup_side_bar:DoubleClick 1")
    _clickTime = nowTime
    _nClick = 1
  elseif intervalTime > nowTime - _clickTime then
    log(bWriteLog and "teamup_side_bar:DoubleClick 2")
    local UIUtil = require("client.common.ui_util")
    UIUtil.PlayWidgetAnimation(self.UIRoot.Common_Avatar_BP, "Animation_chuo1chuo", 0, 1, 1, 1)
    logic_poke:send_poke_friend_req(player.uid)
    self:DoubleClickClearData()
    return
  end
  self.doubleTimer = self:AddTimerOnce(intervalTime, function()
    self:OnClickAvatar()
    self:DoubleClickClearData()
  end)
end
function FriendsListItem_BP:OnClickAvatar()
  local Lobby_InviteFriend_BP = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
  if not Lobby_InviteFriend_BP then
    return
  end
  Lobby_InviteFriend_BP:OnClickAvatar(self.data)
end
function FriendsListItem_BP:DoubleClickClearData()
  log(bWriteLog and "teamup_side_bar:DoubleClickClearData")
  _clickTime = 0
  _nClick = 0
  if self.doubleTimer then
    self:RemoveTimer(self.doubleTimer)
    self.doubleTimer = nil
  end
end
function FriendsListItem_BP:ClickAvatar()
  logic_friend_list_utils.HideLobby_InviteFriend_BP_Menu()
  logic_friend_list_utils.ShowLobby_InviteFriend_BP_Menu(self.data.uid)
end
function FriendsListItem_BP:OnClickCheckBox_Delete(isCheck)
  self:PlayAudio(sound_config.toggle_v1)
  local uid = self.data.uid
  local widget = self.UIRoot
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local state = logic_friend_list_ui:GetState()
  if state == FLMacros.ENUM_STATE.FRIENDS_DELETE then
    local topcnt = logic_friend_list_ui:GetDelCnt()
    local batchDeleteMap = logic_friend_list_ui:GetDels()
    if batchDeleteMap[uid] then
      logic_friend_list_ui:SetIsDelete(uid, nil)
      widget.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
    elseif topcnt < FLMacros.Friend_MaxBatchDelCount then
      logic_friend_list_ui:SetIsDelete(uid, true)
      widget.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Checked)
    elseif topcnt >= FLMacros.Friend_MaxBatchDelCount then
      widget.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
    end
    local Lobby_InviteFriend_BP = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
    if Lobby_InviteFriend_BP and Lobby_InviteFriend_BP.UpdateDeleteUI then
      Lobby_InviteFriend_BP:UpdateDeleteUI()
    end
  elseif state == FLMacros.ENUM_STATE.FRIENDS_TOP then
    if isCheck then
      local topcnt = #logic_friend_list_ui:GetTops()
      if topcnt >= FLMacros.Friend_MaxBatchTopCount then
        widget.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
        logic_friend_list_ui:SetIsTop(uid, 0)
      else
        widget.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Checked)
        logic_friend_list_ui:SetIsTop(uid, 1)
      end
    else
      widget.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
      logic_friend_list_ui:SetIsTop(uid, 2)
    end
    local Lobby_InviteFriend_BP = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
    if Lobby_InviteFriend_BP and Lobby_InviteFriend_BP.UpdateDeleteUI then
      Lobby_InviteFriend_BP:UpdateDeleteUI()
    end
  end
end
function FriendsListItem_BP:OnClickUnknowPass()
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  UnknowPassUtil.GetUnknowPassNextSeason()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(self.data.uid)
  if profile and profile.upass and profile.upass.switch.record_privacy then
    UIManager.ShowUI(UIManager.UI_Config.UnknowPass_RecordMain_UIBP, true, self.data.uid)
  else
    ShowNotice(18256)
  end
end
function FriendsListItem_BP:GetInviteFromType(index)
  local index2Type
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if LBSFriendMgr:CanOpenNearFriend() then
    if from ~= FLMacros.ENUM_OPEN_FROM.ISMOREPLAYERNUM then
      index2Type = {
        TeamUpNewSystem.E_InviteFromType.FriendBar,
        TeamUpNewSystem.E_InviteFromType.RecentBar,
        TeamUpNewSystem.E_InviteFromType.CorpsBar,
        TeamUpNewSystem.E_InviteFromType.NearsFriend
      }
    else
      index2Type = {
        TeamUpNewSystem.E_InviteFromType.SwtichModeFriendBar,
        TeamUpNewSystem.E_InviteFromType.SwtichModeRecentBar,
        TeamUpNewSystem.E_InviteFromType.SwtichModeCorpsBar,
        TeamUpNewSystem.E_InviteFromType.SwtichModeNearsFriend
      }
    end
  elseif from ~= FLMacros.ENUM_OPEN_FROM.ISMOREPLAYERNUM then
    index2Type = {
      TeamUpNewSystem.E_InviteFromType.FriendBar,
      TeamUpNewSystem.E_InviteFromType.RecentBar,
      TeamUpNewSystem.E_InviteFromType.CorpsBar
    }
  else
    index2Type = {
      TeamUpNewSystem.E_InviteFromType.SwtichModeFriendBar,
      TeamUpNewSystem.E_InviteFromType.SwtichModeRecentBar,
      TeamUpNewSystem.E_InviteFromType.SwtichModeCorpsBar
    }
  end
  local tabID = logic_friend_list_ui:GetTabID()
  local fromType = index2Type[tabID] or TeamUpNewSystem.E_InviteFromType.Normal
  return fromType
end
function FriendsListItem_BP:OnClickMainCity(btnUI)
  self:PlayAudio(sound_config.click_v1)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(self.data.uid)
  if not status then
    return
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local isInMainCity = PlayerStatusUtil.IsMainCity(status)
  local isSelfInMainCity = GameStatus.IsInMainCityConnectDs()
  if not isSelfInMainCity and isInMainCity then
    local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
    if not main_city_process_util.IsMainCityEntryOpen(true) then
      return false
    end
    local logic_main_city_follow = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_follow)
    logic_main_city_follow:SendReqFollowPlayerFromFriend(self.data.uid)
    local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
    logic_main_city_enter_report.SetReportData("NewEnterMainCity", "EnterMCFromLobby", "FriendListIntoMC")
  elseif isSelfInMainCity and not isInMainCity then
    local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
    if not main_city_process_util.IsMainCityEntryOpen(true, true) then
      return false
    end
    local logic_main_city_follow = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_follow)
    logic_main_city_follow:send_main_city_invite_req(self.data.uid)
  else
    if isSelfInMainCity and isInMainCity then
      local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
      if not main_city_process_util.IsMainCityEntryOpen(true, true) then
        return false
      end
      local UIUtil = require("client.common.ui_util")
      local widget = btnUI and btnUI.UIRoot and btnUI.UIRoot.Button_Act or self.UIRoot.WidgetSwitcher_Reserve
      local widgetPos = UIUtil.GetWidgetViewportPos(widget, 0, 0)
      UIManager.ShowUI(UIManager.UI_Config.FriendsListItem_MainCity_Tips_UIBP, self.data.uid, widgetPos)
      local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
      logic_main_city_enter_report.SetReportData("SwitchIntoMainCity", "EnterMCFromAnotherMC", "FriendListIntoMC")
    else
    end
  end
end
function FriendsListItem_BP:OnClickButton_Detail()
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(self.data.uid)
  if not status or not status.mod_id then
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  PlayerStatusMgr:GetModInfoById(status.mod_id, function(modInfo)
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    UIManager.ShowUI(UIManager.UI_Config.UGCDetailMainPanel, Config_UGC.Config_UGC_DetailTabs, modInfo)
  end)
end
function FriendsListItem_BP:OnClickButton_Reservation_UGC()
  local UIUtil = require("client.common.ui_util")
  local widget = self.UIRoot.Button_Reservation_UGC
  local widgetPos = UIUtil.GetWidgetViewportPos(widget, 0, 0)
  UIManager.ShowUI(UIManager.UI_Config.FriendsListItem_Invitation_Tips_UIBP, {
    ButtonWatch = function()
      self:OnClickButton_TV()
    end,
    ButtonReserve = function()
      self:OnClickButton_Reservation()
    end
  }, widgetPos)
end
function FriendsListItem_BP:OnClickButton_FreeInOut()
  self:PlayAudio(sound_config.click_v1)
  local player = self.data
  if not player or type(player) ~= "table" or not next(player) then
    return
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(player.uid)
  if not status then
    log(bWriteLog and "FriendsListItem_BP:OnClickButton_FreeInOut status is nil")
    return
  end
  if status and status.game_sub_mode then
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    local mapKey = LogicTxMissionDownload.GetMapKeyByModeID(status.game_sub_mode)
    if mapKey and not LogicTxMissionDownload.CheckResHasDownloaded(mapKey) then
      ShowNotice(45677)
      return
    end
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  local FailReason = PlayerStatusEnum.Enum_FreeInOutFailReason
  local FromType = PlayerStatusEnum.Enum_FreeInOutFromType
  PlayerStatusUtil.CheckCanJoinFriendGame(status, function(canJoin, pub_mod_meta, needDownload, failReason)
    if not canJoin then
      if failReason == FailReason.NotBattle or failReason == FailReason.NoMod then
        ShowNotice(20050024)
      else
        ShowNotice(9911106)
      end
      return
    end
    if needDownload then
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      UIManager.ShowUI(UIManager.UI_Config.UGCDetailMainPanel, Config_UGC.Config_UGC_DetailTabs, pub_mod_meta)
      ShowNotice(78351)
      return
    end
    if pub_mod_meta and next(pub_mod_meta) then
      local Logic_UGC_Res_Manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
      if Logic_UGC_Res_Manager then
        Logic_UGC_Res_Manager:Send_update_client_mod_info_ByModInfo(pub_mod_meta)
      end
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, "", LocUtil.GetLocalizeResStr(78436), function()
      local UGCHandler = require("client.network.Protocol.UGCHandler")
      UGCHandler.send_free_inout_apply_req(player.uid, FromType.FriendList)
    end)
  end)
end
function FriendsListItem_BP:OnClickButton_SingleTraining()
  log(bWriteLog and "FriendsListItem_BP:OnClickButton_SingleTraining")
  self:PlayAudio(sound_config.click_v1)
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  ShootingTrainTool.ClickButton_SingleTraining(self.data.uid)
end