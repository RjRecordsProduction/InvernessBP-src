local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
function Lobby_InviteFriend_BP:OnAndroidBack()
  self:PlayAudio(sound_config.click_v1)
  self:ClosePanelMute()
end
function Lobby_InviteFriend_BP:ClosePanelMute()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if from == FLMacros.ENUM_OPEN_FROM.LOBBY and not LogicTeamUpSideBar.IsInRoom() then
    LogicTeamUpSideBar.ShowLobbyFriendEntrance()
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
  self:CloseSelf()
end
function Lobby_InviteFriend_BP:ClickLuckyStar()
  self:PlayAudio(sound_config.click_v1)
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ParamTable = ui_show_queue_config.GetParamTable(nil, nil, true)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Lucky_Teammate_UIBP, ParamTable)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
end
function Lobby_InviteFriend_BP:ClickReturnTips()
  UIManager.ShowUI(UIManager.UI_Config.Common_Tips_Return_UIBP, self.UIRoot.CanvasPanel_ReturnTips)
end
function Lobby_InviteFriend_BP:ClickDeskTopTool()
  log(bWriteLog and "Lobby_InviteFriend_BP:ClickDeskTopTool")
  self:PlayAudio(sound_config.click_v1)
  if self.sync_fb_friend then
    log(bWriteLog and "Lobby_InviteFriend_BP:ClickDeskTopTool sync fb friends")
    local ModuleManager = require("client.module_framework.ModuleManager")
    local logic_friend_spk_fb = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_spk_fb)
    logic_friend_spk_fb:LaunchLoginAutho()
    self:CloseSelf()
    return
  end
  local url = "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D0%26game_scene%3DFriendList%26widget_pip%3D1%26from_scene%3D1"
  GlobalData.JumpGameUrl(url)
  log(bWriteLog and "Lobby_InviteFriend_BP:ClickDeskTopTool Click nDeskTopToolTriggerReason = " .. tostring(self.nDeskTopToolTriggerReason))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Click_Friend_DeskTopTool_Guide, self.nDeskTopToolTriggerReason or 0)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFrienDeskTopTooldGuide) or {}
  log_tree(bWriteLog and "lteamup_side_bar:ClickDeskTopTool saveData", saveData)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_DeskTopTool, false)
  local version_util = require("client.common.version_util")
  local currentMainVersion = version_util.GetMainFormat(Client.GetAppVersion())
  if saveData.isClick370 and saveData.lastClickVersion == currentMainVersion then
    log(bWriteLog and "teamup_side_bar:ClickDeskTopTool return of already guide")
    return
  end
  saveData.isClick370 = true
  saveData.lastClickVersion = currentMainVersion
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eFrienDeskTopTooldGuide)
end
function Lobby_InviteFriend_BP:ClickFriendApply()
  self:PlayAudio(sound_config.click)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  if logic_friend_apply:GetApplyCnt() > 0 then
    local FriendApplyHandler = require("client.network.Protocol.FriendApplyHandler")
    FriendApplyHandler.send_get_addfriend_reqlist_req()
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    logic_flash_match_team:OpenApplicationPopup(1)
  else
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    logic_flash_match_team:OpenApplicationPopup(1)
  end
end
function Lobby_InviteFriend_BP:ClickTopAddFriends()
  self:PlayAudio(sound_config.click)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
  local logic_friendnum_limit = require("client.slua.logic.friend.logic_friendnum_limit")
  logic_friendnum_limit.CloseFriendNumLimitTipsUI(self, true)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.RecommendedFriend_ClickEntry)
  UIManager.ShowUI(UIManager.UI_Config.friend_new_search)
end
function Lobby_InviteFriend_BP:ClickMenu()
  self:PlayAudio(sound_config.click_v1)
  if self.UIRoot.CanvasPanel_Menu:IsVisible() then
    self.UIRoot.CanvasPanel_Menu:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Menu, 0, 1, 0, 1)
    self.UIRoot.CanvasPanel_Menu:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if self.SeekFriend_NewGuide_Tips_UIBP then
      self.SeekFriend_NewGuide_Tips_UIBP:CloseSelf()
    end
  end
end
function Lobby_InviteFriend_BP:ClickConfirmDelete()
  self:PlayAudio(sound_config.click_v1)
  local list = {}
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  for i, _ in pairs(logic_friend_list_ui:GetDels()) do
    table.insert(list, i)
  end
  if #list == 0 then
    ShowNotice(5023)
    return
  end
  local confirmCallBack = function()
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    LogicFriend.del_inner_friend_batch_req(list)
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local content = LocUtil.LocalizeResFormat(4979, #list)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, content, confirmCallBack)
end
function Lobby_InviteFriend_BP:ClickConfirmTop()
  self:PlayAudio(sound_config.click_v1)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local batchTopMap = logic_friend_list_ui:GetTops()
  if batchTopMap and next(batchTopMap) then
    local FriendHandler = require("client.network.Protocol.FriendHandler")
    FriendHandler.send_do_friend_top_op_req(batchTopMap)
  end
  self:OnLeaveFriendsDelete()
end
function Lobby_InviteFriend_BP:OnLeaveFriendsDelete()
  self:PlayAudio(sound_config.click)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  logic_friend_list_ui:ClearDels()
  logic_friend_list_ui:ClearTops()
  logic_friend_list_ui:SetState(FLMacros.ENUM_STATE.FRIENDS)
  if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    self:SetOneTabData(true)
  end
  self:UpdateDeleteUI()
end
function Lobby_InviteFriend_BP:ClickBlackList()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.friend_blacklist)
end
function Lobby_InviteFriend_BP:OnClickFriendsDelete()
  self:PlayAudio(sound_config.click)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  logic_friend_list_ui:SetState(FLMacros.ENUM_STATE.FRIENDS_DELETE)
  local AllData = LogicTeamUpSideBar.GetFriends(true) or {}
  if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    self:RefreshFriendList(true, AllData)
  end
  self:UpdateDeleteUI()
end
function Lobby_InviteFriend_BP:ClickShowState()
  self:PlayAudio(sound_config.click)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
  if not LobbySystem.CheckOpen(BP_ENUM_NEW_FRIEND_STATUS_SWITCH) then
    self:ShowHideStateList(true)
  else
    self.UIRoot:StopAnimation(self.UIRoot.Anim_Guide)
    self:SetWidgetVisible(self.UIRoot.image_Reddot_status, false)
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Condition_UIBP)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Click_Status_Entry)
  end
end
function Lobby_InviteFriend_BP:ClickFaceTeam()
  self:PlayAudio(sound_config.click)
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.TeamCode) then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInFaceTeam() then
    ShowNotice(4364)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.FaceTeam_UIBP)
  self:ClosePanelMute()
end
function Lobby_InviteFriend_BP:ClickInviteJoin()
  self:PlayAudio(sound_config.click)
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.TeamInvite) then
    return
  end
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(2, ShareBtnTLogShareTypeDefine.ReturnInvitation, 0, nil)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.invite_offline_friend_req(ShareSource.More)
end
function Lobby_InviteFriend_BP:OnButton_LockClick()
  self:PlayAudio(sound_config.click_v1)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:ShowRestrictTips()
end
function Lobby_InviteFriend_BP:OnClickFriendsTop()
  log(bWriteLog and "OnClickFriendsTop")
  self:PlayAudio(sound_config.click)
  if self.Common_ScreenBox_UIBP:GetCurrentIndex() ~= 1 then
    ShowNotice(73513)
    return
  end
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  logic_friend_list_ui:SetState(FLMacros.ENUM_STATE.FRIENDS_TOP)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    local AllData = LogicTeamUpSideBar.GetFriends() or {}
    self:RefreshFriendList(true, AllData)
  end
  self:UpdateDeleteUI()
end
function Lobby_InviteFriend_BP:OnClickAvatar(player)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
  if not player then
    return
  end
  local ChatMenuSystem = require("client.slua.logic.lobby_chat.logic_chat_menu")
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  local menuUI = UIManager.ShowUI(UIManager.UI_Config.ChatMenu_BP, {
    Uid = player.uid,
    IsShowReport = false,
    openTag = tabID
  }, ChatMenuSystem.EShowLocationType.Friend)
  local UIUtil = require("client.common.ui_util")
  local viewPortScale = UIUtil.GetViewportSize()
  log(bWriteLog and "teamup_side_bar:OnClickAvatar view scale = " .. tostring(viewPortScale.X / viewPortScale.Y))
  local offsetX = 20
  if viewPortScale.X / viewPortScale.Y >= 1.5 and viewPortScale.X > 1500 then
    offsetX = 40
  end
  log(bWriteLog and "teamup_side_bar:OnClickAvatar offestX = " .. tostring(offsetX))
end
function Lobby_InviteFriend_BP:OnClickWorkName()
  self:PlayAudio(sound_config.click_v1)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if self.modInfo then
    UIManager.ShowUI(UIManager.UI_Config.UGCDetailMainPanel, Config_UGC.Config_UGC_DetailTabs, self.modInfo)
    self:ClosePanelMute()
  end
end
function Lobby_InviteFriend_BP:OnClickSNSInvite()
  log(bWriteLog and "Lobby_InviteFriend_BP:OnClickSNSInvite")
  self:PlayAudio(sound_config.click_v1)
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(2, ShareBtnTLogShareTypeDefine.ReturnInvitation, 9, nil)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.invite_offline_friend_req(ShareSource.SMS)
end
function Lobby_InviteFriend_BP:OnClickButton_SetDisplay()
  log(bWriteLog and "Lobby_InviteFriend_BP:OnClickButton_SetDisplay")
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.SetDisplay_UIBP)
end