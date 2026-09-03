local ELobbyGuideID = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ELobbyGuideID
local level_unlock_config = require("client.logic.level_unlock.config.level_unlock_config")
local ETipDir = level_unlock_config.ETipDir
local ETipStyle = level_unlock_config.ETipStyle
local logic_teamquick_guide = {}
function logic_teamquick_guide:DefineAndResetData()
  self.isLobbyFadeinAnimFinish = false
  self.hasShownLobbyGuide = false
  self.joinedTeamFriendIcons = nil
  self.teamMembersIcons = nil
  self.hasShownLoginLoopGuide = false
end
function logic_teamquick_guide:OnInitialize()
end
function logic_teamquick_guide:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_TEAMQUICK_GUIDE, self.OnShowGuide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_FADE_IN_ANIM_FINISH, self.OnLobbyFadeinAnimFinish, self)
end
function logic_teamquick_guide:OnLogin()
  self.hasShownLobbyGuide = false
end
function logic_teamquick_guide:OnShowGuide()
  log(bWriteLog and "logic_teamquick_guide:OnShowGuide")
  if not self:CheckCanShowLobbyGuide() then
    log_warning(bWriteLog and "logic_teamquick_guide:OnShowGuide - Check failed")
    return
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local IsSlapEnd = NewFaceSlapSystem:IsSlapEnd()
  if not IsSlapEnd then
    log_warning(bWriteLog and "logic_teamquick_guide:OnShowGuide - Slap not end")
    return false
  end
  self:ShowLobbyEntryGuide()
end
function logic_teamquick_guide:OnLobbyFadeinAnimFinish()
  log(bWriteLog and "logic_teamquick_guide:OnLobbyFadeinAnimFinish")
  self.isLobbyFadeinAnimFinish = true
  self:ShowEntryGuide()
end
function logic_teamquick_guide:_RegisterLobbyBubbleJumpWatcher()
  self:_UnRegisterLobbyBubbleJumpWatcher()
  local handler = function(_, _, jumpUIConfig)
    log_format("logic_teamquick_guide:_RegisterLobbyBubbleJumpWatcher trigger. jumpKeyName = [%s]", jumpUIConfig and jumpUIConfig.keyName or "nil")
    if UIManager.IsUIShow(UIManager.UI_Config.level_unlock_bubble) then
      UIManager.CloseUI(UIManager.UI_Config.level_unlock_bubble)
    end
    self:_UnRegisterLobbyBubbleJumpWatcher()
  end
  self._lobbyBubbleJumpHandler = handler
  EventSystem:registEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_OPEN, handler)
end
function logic_teamquick_guide:_UnRegisterLobbyBubbleJumpWatcher()
  if not self._lobbyBubbleJumpHandler then
    return
  end
  EventSystem:unregistEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_OPEN, self._lobbyBubbleJumpHandler)
  self._lobbyBubbleJumpHandler = nil
end
function logic_teamquick_guide:OnDestroy()
  log(bWriteLog and "logic_teamquick_guide:OnDestroy")
  self:_UnRegisterLobbyBubbleJumpWatcher()
  logic_teamquick_guide.__super.OnDestroy(self)
end
function logic_teamquick_guide:ShowEntryGuide()
  log(bWriteLog and "logic_teamquick_guide:ShowEntryGuide")
  if not self:CheckCanShowLobbyGuide() then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowEntryGuide - Check failed")
    return
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local IsSlapStart = NewFaceSlapSystem:IsSlapStart()
  local IsSlapEnd = NewFaceSlapSystem:IsSlapEnd()
  if IsSlapStart and not IsSlapEnd then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowEntryGuide - Slap in progress")
    return false
  end
  self:ShowLobbyEntryGuide()
end
function logic_teamquick_guide:ShowLobbyEntryGuide()
  log(bWriteLog and "logic_teamquick_guide:ShowLobbyEntryGuide")
  if not self:_CheckNeedShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID) then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowLobbyEntryGuide - Has show lobby guide")
    return
  end
  local widget
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local Lobby_Mid_Friend_UIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Friend_UIBP)
    widget = Lobby_Mid_Friend_UIBP.UIRoot.CanvasPanel_TeamQuick
  end
  if not widget then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowLobbyEntryGuide - Widget not found")
    return
  end
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ParamTable = ui_show_queue_config.GetParamTable(nil, "IsLobbyLevelUnLock")
  local text = LocUtil.GetLocalizeResStr(817140)
  local cb = function()
    self:_UnRegisterLobbyBubbleJumpWatcher()
    local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
    UIManager.ShowUI(UIManager.UI_Config.Lobby_InviteFriend_BP, FLMacros.ENUM_OPEN_FROM.LOBBY, FLMacros.ENUM_TAB.ENUM_TEAM_TAG)
    self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.FlashSquad_Onboarding_Step, 0)
  end
  UIManager.ShowUI(UIManager.UI_Config.level_unlock_bubble, ETipDir.right, text, widget, cb, true, false, nil, nil, ParamTable)
  self.hasShownLobbyGuide = true
  self:_RegisterLobbyBubbleJumpWatcher()
end
function logic_teamquick_guide:ShowFriendGuide(widget, callback)
  log(bWriteLog and "logic_teamquick_guide:ShowFriendGuide")
  if not widget or not slua.isValid(widget) then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowFriendGuide - Widget not found")
    return
  end
  if not self:_CheckNeedShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_FRIEND_GUIDE_ID) then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowFriendGuide - Check failed")
    return
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.Lobby_InviteFriend_BP) then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowFriendGuide - Lobby_InviteFriend_BP not show")
    return
  end
  local topUIName = UIManager.GetTopUIName()
  if topUIName ~= UIManager.UI_Config.Lobby_InviteFriend_BP.keyName then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowFriendGuide - Top UI is not Lobby_InviteFriend_BP")
    return
  end
  local cb = function()
    if callback then
      callback()
    end
    self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_FRIEND_GUIDE_ID)
  end
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ParamTable = ui_show_queue_config.GetParamTable(nil, "NotUseQueue")
  local uiInfo = UIManager.ShowUI(UIManager.UI_Config.level_unlock_bubble, -1, nil, widget, cb, true, nil, nil, nil, ParamTable)
  return uiInfo
end
function logic_teamquick_guide:CheckCanShowLobbyGuide()
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local flag = logic_newbie.NeedShowNewbieGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID)
  if not flag then
    log_warning(bWriteLog and "logic_teamquick_guide:CheckCanShowLobbyGuide - Already shown guide")
    return false
  end
  local logic_teamquick_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_entry)
  if not logic_teamquick_entry:CheckCanShow() then
    log_warning(bWriteLog and "logic_teamquick_guide:CheckCanShowLobbyGuide - Entry not open")
    return false
  end
  if not self.isLobbyFadeinAnimFinish then
    log_warning(bWriteLog and "logic_teamquick_guide:CheckCanShowLobbyGuide - Lobby FadeIn Anim not finish")
    return false
  end
  if self.hasShownLobbyGuide then
    log_warning(bWriteLog and "logic_teamquick_guide:CheckCanShowLobbyGuide - isShownLobbyGuide")
    return false
  end
  return true
end
function logic_teamquick_guide:TryShowPageGuide()
  local needShowGuide = self:_CheckNeedShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_PAGE_GUIDE_ID)
  if not needShowGuide then
    log_warning(bWriteLog and "logic_teamquick_guide:TryShowPageGuide - Already shown guide")
    return false
  end
  self:ShowPageGuide()
end
function logic_teamquick_guide:ShowPageGuide()
  local guideData = {
    list = {
      {
        contentType = ENUM_PAGE_GUIDE_CONTENT_TYPE.BluePrint,
        bpPath = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Guide_Page1_UIBP.TeamQuick_Guide_Page1_UIBP",
        title = LocUtil.GetLocalizeResStr(817151),
        desc = LocUtil.GetLocalizeResStr(817152)
      },
      {
        contentType = ENUM_PAGE_GUIDE_CONTENT_TYPE.BluePrint,
        bpPath = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Guide_Page2_UIBP.TeamQuick_Guide_Page2_UIBP",
        title = LocUtil.GetLocalizeResStr(817159),
        desc = LocUtil.GetLocalizeResStr(817160)
      },
      {
        contentType = ENUM_PAGE_GUIDE_CONTENT_TYPE.BluePrint,
        bpPath = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Guide_Page3_UIBP.TeamQuick_Guide_Page3_UIBP",
        title = LocUtil.GetLocalizeResStr(817163),
        desc = LocUtil.GetLocalizeResStr(817164)
      },
      {
        contentType = ENUM_PAGE_GUIDE_CONTENT_TYPE.BluePrint,
        bpPath = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Guide_Page4_UIBP.TeamQuick_Guide_Page4_UIBP",
        title = LocUtil.GetLocalizeResStr(817166),
        desc = LocUtil.GetLocalizeResStr(817167)
      }
    },
    closeFunc = function()
      self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_PAGE_GUIDE_ID)
    end,
    skipToNext = true
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_PageGuide_UIBP, guideData)
end
function logic_teamquick_guide:CheckNeedShowLoopGuide()
  if self.hasShownLoginLoopGuide then
    log(bWriteLog and "logic_teamquick_guide:CheckNeedShowLoopGuide - Already shown login loop guide")
    return false
  end
  return true
end
function logic_teamquick_guide:GetGuideCustomIconList()
  local url_tmp = {
    30025,
    30026,
    30027,
    30028,
    30029,
    30030,
    30031,
    30035,
    30039,
    30041,
    30042,
    30044,
    30050,
    30051,
    30052,
    30054,
    30056,
    30057,
    30059,
    30060,
    30061,
    30063,
    30064,
    30065,
    30066,
    30067,
    30071
  }
  local avatar_box_tmp = {
    30198,
    30202,
    30204,
    30216,
    30217,
    30238,
    30239,
    30254,
    30255,
    30257,
    30263,
    30264,
    30286,
    30287,
    30294,
    30295,
    30298,
    30299,
    30300,
    30301,
    30302,
    30303,
    30306,
    30307,
    30309,
    30312,
    30313
  }
  local iconList = {}
  for i = 1, 9 do
    local url_idx = math.min((i - 1) * 3 + math.random(1, 3), #url_tmp)
    local avatar_idx = math.min((i - 1) * 3 + math.random(1, 3), #avatar_box_tmp)
    table.insert(iconList, {
      uid = tonumber(DataMgr.roleData.uid),
      url = url_tmp[url_idx],
      avatar_box = avatar_box_tmp[avatar_idx]
    })
  end
  return iconList
end
function logic_teamquick_guide:GetGuideFriendIconList()
  if self.joinedTeamFriendIcons and #self.joinedTeamFriendIcons >= 4 then
    return self.joinedTeamFriendIcons
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendList = LogicFriend.GetFriendList(false)
  if not self.joinedTeamFriendIcons or #self.joinedTeamFriendIcons < 4 and #friendList <= 50 then
    self.joinedTeamFriendIcons = {}
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    for _, friend in pairs(friendList) do
      local profile = logic_profile:GetLocalProfile(friend.uid)
      if profile and profile.flash_squad and next(profile.flash_squad) then
        table.insert(self.joinedTeamFriendIcons, {
          uid = friend.uid,
          url = profile.picUrl,
          avatar_box = profile.cur_avatar_box_id
        })
      end
    end
    log_tree(bWriteLog and "logic_teamquick_guide:GetGuideFriendIconList self.joinedTeamFriendIcons: ", self.joinedTeamFriendIcons)
  end
  return self.joinedTeamFriendIcons
end
function logic_teamquick_guide:GetTeamMemberGuideIconList()
  if not self.teamMembersIcons or #self.teamMembersIcons < 3 then
    self.teamMembersIcons = {}
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    local teams = logic_flash_match_team:GetAllFlashTeamSummary()
    local filter = {
      [tonumber(DataMgr.roleData.uid)] = true
    }
    for id, team in pairs(teams) do
      if team.member_uids and next(team.member_uids) then
        local member_brief = logic_flash_match_team:GetFlashTeamMembersById(id)
        if member_brief and member_brief.list and next(member_brief.list) then
          for _, member in pairs(member_brief.list) do
            if not filter[member.uid] and member.picUrl and member.picUrl ~= "" then
              filter[tonumber(member.uid)] = true
              table.insert(self.teamMembersIcons, {
                uid = member.uid,
                url = member.picUrl,
                avatar_box = member.avatar_box_id
              })
            end
          end
        end
      end
    end
    log_tree(bWriteLog and "logic_teamquick_guide:GetTeamMemberGuideIconList self.teamMembersIcons: ", self.teamMembersIcons)
  end
  return self.teamMembersIcons
end
function logic_teamquick_guide:CheckHasShowLobbyGuide()
  local needShowGuide = self:_CheckNeedShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID)
  return not needShowGuide
end
function logic_teamquick_guide:GMCompleteLobbyGuide()
  self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID)
end
function logic_teamquick_guide:GMCompleteFriendGuide()
  self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_FRIEND_GUIDE_ID)
end
function logic_teamquick_guide:GMCompletePageGuide()
  self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_PAGE_GUIDE_ID)
end
function logic_teamquick_guide:_RecordShowGuide(guideID)
  log(bWriteLog and "logic_teamquick_guide:_RecordShowGuide - guideID: " .. guideID)
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  DataMgr.SetNewbieGuideValue(logic_newbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, guideID, 1)
end
function logic_teamquick_guide:_CheckNeedShowGuide(guideID)
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local needShowGuide = DataMgr.HaveNewbieGuide(logic_newbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, guideID)
  log_format("logic_teamquick_guide:CheckHasShowLobbyGuide. guideID: %s, needShowGuide: %s", guideID, needShowGuide)
  return needShowGuide
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_teamquick_guide = class(CModuleBase, nil, logic_teamquick_guide)
return Clogic_teamquick_guide