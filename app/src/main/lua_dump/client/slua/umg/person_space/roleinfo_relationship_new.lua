local UI_RoleInfo_Relationship_New = {}
local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
function UI_RoleInfo_Relationship_New:ctor(_, uid, extraData)
  log(bWriteLog and "UI_RoleInfo_Relationship_New:ctor uid = " .. tostring(uid))
  log_tree("extraData = ", extraData)
  self.uid = uid or 0
  self.  self.bPopMenu = false
  self.system = require("client.logic.personspace.logic_person_space_relationship")
  self.selectIndex = extraData and extraData.viewIndex or 1
  self.showRelationshipNet = true
  self.bShowRecruitmentLight = false
  self.testInt = 0
  self.hinderedSharedBagPopup = {}
  self.bWeekSummaryReddot = false
  self.bIntimacyApplyReddot = false
end
function UI_RoleInfo_Relationship_New:OnInitialize()
  UI_RoleInfo_Relationship_New.__super.OnInitialize(self)
  self:InitData()
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP = self:InitHorizontalLevelOneTextTab(self.UIRoot.Common_Tab_Horizontal_LevelOne_Text_UIBP)
  self.child_Net = self:CreateChildWindow(self.UIRoot.CanvasPanel_Net, UIManager.UI_Config.roleInfo_Relationship_Net, self.uid)
  self.child_Overview = self:CreateChildWindow(self.UIRoot.CanvasPanel_Overview, UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Overview, self.uid, self.UIRoot.Button_ShowType)
  self.child_CanBuild = self:CreateChildWindow(self.UIRoot.CanvasPanel_CanBuild, UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP, self.uid)
end
function UI_RoleInfo_Relationship_New:RegistEvents()
  UI_RoleInfo_Relationship_New.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ShowType, self.OnChangeShowType, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Share, self.OnShareClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Cohabit, self.OnButton_CohabitClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Recruitment, self.OnRecruitmentClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Partner, self.OnPartnerClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ApplyList, self.OnApplyClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Rules, self.OnOpenBlackClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Lock, self.OnButton_LockClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ApplyListLock, self.Button_ApplyListLockClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_JumpRank, self.OnClickButton_JumpRank, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SettingJump, self.OnSettingClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_IntimacyJump, self.OnClickButton_IntimacyJump, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_GuidePop, self.OnClickButton_GuidePop, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Menu, self.OnButton_MenuClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_WeekSummary, self.OnButton_WeekSummaryClick, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, self.UpdateRedPoint, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_INTIMACY_GET_INFO_RSP, self.ShowPartner, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE, self.OnSwitchUpdate, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_SHARED_BAG_RSP, self.OnSharedBagRsp, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_TAKE_INTIMACY_REWARD, self.OnTakeIntimacyReward, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACYAPPLY_CHANGE, self.RefreshApplyReddot, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_INTIMACY_RELATIONSHIP_REFRESH_TAB, self.RefreshTab, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE, self.RefreshApplyReddot, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_INTERACT_GET_ALL_FRIENDLIST, self.RefreshWeeklySummaryReddot, self)
  self:AddControlEventByControl(self.UIRoot.Anim_in, "OnAnimationFinished", self.ShowPopupGuide, self)
end
function UI_RoleInfo_Relationship_New:OnPostInitialize()
  UI_RoleInfo_Relationship_New.__super.OnPostInitialize(self)
  self:PlayUserWidgetAnimation(self.UIRoot.Anim_in, 0, 1, 0, 1)
  self:InitUI()
  local IsSelf = self.system.IsMySelf(self.uid)
  if IsSelf then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Lobby_Intimacy_Click_Access)
    self.UIRoot.Button_Share:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Lobby_Intimacy_Click_Visit_Friend)
    self.UIRoot.Button_Share:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  if SocialLobbyHandler.bHasStateData == false then
    SocialLobbyHandler.send_get_intimacy_conscribe_state_req()
  end
  if IsSelf then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_shared_backpack_unlocked_req()
  end
  self:AddTimerOnce(0, function()
    self:ProcessExtraData()
  end)
  self:SetWidgetVisible(self.UIRoot.Image_Lightloop, false)
  self:SetWidgetVisible(self.UIRoot.Image_CohabitReddot, false)
  if IsSelf then
    self:RefreshIntimacyJumpBtnReddot()
    self:RefreshRecruitmentLight()
    local bCohabitOpen = LobbySystem.CheckOpen(BP_ENUM_MODULE_PLANPH_HOME_COHABIT)
    local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
    if logic_home_joint:HasJointHome() or bCohabitOpen then
      self:RefreshCohabitBtnReddot()
      self:SetWidgetVisible(self.UIRoot.Button_Cohabit, true, true)
    else
      log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:OnPostInitialize switch not open and do not have joint home, do not show entrance")
      self:SetWidgetVisible(self.UIRoot.Button_Cohabit, false)
    end
    local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
    logic_friend_interact_record:RequestHighFrequencyInteractData()
  else
    self:SetWidgetVisible(self.UIRoot.Button_Cohabit, false)
  end
end
function UI_RoleInfo_Relationship_New:OnClose()
  log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:OnClose")
  if self.cohabitGuideBubble then
    log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:OnClose self.cohabitGuideBubble exist, check if is current guide")
    if UIManager.GetUI(UIManager.UI_Config.level_unlock_bubble) == self.cohabitGuideBubble then
      log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:OnClose self.cohabitGuideBubble exist, is current guide, should close")
      UIManager.CloseUI(UIManager.UI_Config.level_unlock_bubble)
      self.cohabitGuideBubble = nil
    end
  else
    log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:OnClose self.cohabitGuideBubble not exist, do not need to proceed")
  end
end
function UI_RoleInfo_Relationship_New:ShowCohabitEntranceGuide()
  log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:ShowCohabitEntranceGuide")
  if not LobbySystem.CheckOpen(BP_ENUM_MODULE_PLANPH_HOME_COHABIT) then
    log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:ShowCohabitEntranceGuide switch not open")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeJointEntryUsed) or {}
  if saveData.bHasShownCohabitGuide then
    log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:ShowCohabitEntranceGuide guide already shown")
    return
  end
  local IsSelf = self.system.IsMySelf(self.uid)
  if not IsSelf then
    log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:ShowCohabitEntranceGuide not is self")
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local intimacyList = LogicFriend.GetIntimacyHasBuildList()
  local bCanShow = false
  local minIntimacy = 0
  local cfg = CDataTable.GetTableData("JointParamCfg", "manor_joint_lower_intimacy")
  if cfg and cfg.Value then
    minIntimacy = tonumber(cfg.Value) or 0
  end
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  for k, v in pairs(intimacyList) do
    local intimacy = logic_friend_list:GetIntimacy(tonumber(v.uid))
    if minIntimacy < intimacy then
      bCanShow = true
      break
    end
  end
  if not bCanShow then
    return
  end
  local text = LocUtil.GetLocalizeResStr(655879)
  self:AddTimerOnce(0, function()
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local ParamTable = ui_show_queue_config.GetParamTable(nil, "ShowNow")
    self.cohabitGuideBubble = UIManager.ShowUI(UIManager.UI_Config.level_unlock_bubble, 1, text, self.UIRoot.Button_Cohabit, function()
      if self.UIRoot then
        log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:ShowCohabitEntranceGuide click gudie callback")
        saveData.bHasShownCohabitGuide = true
        PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eHomeJointEntryUsed)
        self.cohabitGuideBubble = nil
      end
      self:ShowHinderedSharedBag()
    end, true, true, nil, ParamTable)
  end)
end
function UI_RoleInfo_Relationship_New:InitUI()
  local IsSelf = self.system.IsMySelf(self.uid)
  local tabs = {
    LocUtil.GetLocalizeResStr(44361),
    LocUtil.GetLocalizeResStr(44362)
  }
  local buildList = LogicFriend.GetIntimacyHasBuildList()
  if not buildList or not next(buildList) and IsSelf then
    self.selectIndex = 2
  end
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTabs(tabs, self.selectIndex)
  self:RefresTabView()
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:AddOnClickedCallback(self.OnClickedLevelOneTab, self)
  self:RefreshCanBuildReddot()
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_Buttons, IsSelf)
  self:SetWidgetVisible(self.UIRoot.Button_SettingJump, IsSelf, true)
  self:SetWidgetVisible(self.UIRoot.Common_Tab_Horizontal_LevelOne_Text_UIBP, IsSelf)
  self:SetWidgetVisible(self.UIRoot.Button_IntimacyJump, IsSelf, true)
  local switchStatus = self.system.RelationShip_SwitchStatus
  log_tree("system.RelationShip_SwitchStatus:", switchStatus)
  local intimacy_visible_switchs_tool = require("client.slua.logic.friend.Intimacy.intimacy_visible_switchs_tool")
  local isInVisibleOther = not IsSelf and not intimacy_visible_switchs_tool.GetVisiblePlayer(self.uid)
  if isInVisibleOther then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self.child_Overview:IsSetKong(nil)
    self.child_Overview:SetTextShow(true)
    self.UIRoot.Button_ShowType:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:SetWidgetVisible(self.UIRoot.HorizontalBox_0, false)
    return
  end
  self.child_Overview:SetTextShow(false)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_0, true)
  self.child_Overview:IsSetKong(self:GetHasBuildList())
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  if IntimacyUtils.IsBondingSystemOpen() then
    local str = LocUtil.GetLocalizeResStr(81271)
    self.UIRoot.TextBlock_Intimacies:SetText(str)
    self:SetWidgetVisible(self.UIRoot.TextBlock_Intimacies, true)
  else
    self:SetWidgetVisible(self.UIRoot.TextBlock_Intimacies, false)
  end
  self:Update_Restrict()
  self:Update_PopMenu()
end
function UI_RoleInfo_Relationship_New:Update_PopMenu()
  log(bWriteLog and "UI_RoleInfo_Relationship_New:Update_PopMenu")
  if self.bPopMenu then
    self.UIRoot.CanvasPanel_Menu:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_Menu:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UI_RoleInfo_Relationship_New:Update_Restrict()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local bRestrict = QRcodeRestrictManager:IsRestrictSocial()
  self:SetWidgetVisible(self.UIRoot.Button_Lock, bRestrict, true)
  self:SetWidgetVisible(self.UIRoot.Button_ApplyListLock, bRestrict, true)
end
function UI_RoleInfo_Relationship_New:GetHasBuildList()
  local TableUtil = require("common.table_util")
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local HasBuildList = TableUtil.DeepCloneTable(PersonSpaceSystem.FriendDetailsDatas)
  table.sort(HasBuildList, function(a, b)
    return a.intimacy > b.intimacy
  end)
  local LogicRelationship = require("client.logic.personspace.logic_person_space_relationship")
  local switchStatus = LogicRelationship.RelationShip_SwitchSetting
  for i = #HasBuildList, 1, -1 do
    for _, v in pairs(switchStatus) do
      if HasBuildList[i].relation == v.relation and not v.isVisible then
        table.remove(HasBuildList, i)
        break
      end
    end
  end
  return HasBuildList
end
function UI_RoleInfo_Relationship_New:UpdateUI()
  if self.extraData and self.extraData.intimacyType then
    self.Common_Tab_Horizontal_LevelOne_Text_UIBP:Select(self.extraData.intimacyType)
    self.selectIndex = self.extraData.intimacyType
    self:RefresTabView()
  end
  local switchStatus = self.system.RelationShip_SwitchStatus
  local IsSelf = self.system.IsMySelf(self.uid)
  local intimacy_visible_switchs_tool = require("client.slua.logic.friend.Intimacy.intimacy_visible_switchs_tool")
  local isInVisibleOther = not IsSelf and not intimacy_visible_switchs_tool.GetVisiblePlayer(self.uid)
  if isInVisibleOther then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self.child_Overview:IsSetKong(nil)
    self.child_Overview:SetTextShow(true)
    self.UIRoot.Button_ShowType:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.child_Overview:SetTextShow(false)
  local TableUtil = require("common.table_util")
  local relationStatus = TableUtil.DeepCloneTable(self.system.RelationShip_Status)
  if not IsSelf then
    for _, v1 in pairs(relationStatus) do
      for _, v2 in pairs(self.system.RelationShip_SwitchSetting) do
        if v1.relation == v2.relation and not v2.isVisible then
          v1.InitmacyFriendList = {}
          v1.curCount = 0
        end
      end
    end
  end
  local curCount = {}
  local maxIndex = IntimacyConst.EIntimacyType.Max
  for i = 1, maxIndex do
    curCount[i] = 0
  end
  if self.system.IsMySelf(self.uid) then
    for _, v in pairs(LogicFriend.GetIntimacyHasBuildList()) do
      if 1 <= v.param and maxIndex >= v.param then
        curCount[v.param] = curCount[v.param] + 1
      end
    end
  else
    for i = 1, maxIndex do
      if relationStatus[i] then
        curCount[i] = relationStatus[i].curCount
      else
        curCount[i] = 0
      end
    end
    local isAllZero = true
    for _, v in pairs(curCount) do
      if 0 < v then
        isAllZero = false
      end
    end
    if isAllZero and (switchStatus.IsAllSwitch_Closed or switchStatus.IsAllChildSwitch_Closed) then
      self:SetWidgetVisible(self.UIRoot.HorizontalBox_0, not isAllZero)
      self.child_Overview:SetTextShow(true)
    end
  end
  self.UIRoot.TextBlock_JiYou:SetText(curCount[1] .. "/" .. relationStatus[1].maxCount)
  if curCount[6] and curCount[6] ~= 0 then
    local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
    local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
    if not bIsBondingSystem then
      self.UIRoot.WidgetSwitcher_FCOrLover:SetActiveWidgetIndex(0)
      self.UIRoot.TextBlock_QingLv:SetText(curCount[6] .. "/" .. relationStatus[6].maxCount)
    else
      self.UIRoot.WidgetSwitcher_FCOrLover:SetActiveWidgetIndex(1)
      local maxCount = relationStatus[6] and relationStatus[6].maxCount or 0
      self.UIRoot.TextBlock_QingLv:SetText(curCount[6] .. "/" .. maxCount)
    end
  else
    self.UIRoot.WidgetSwitcher_FCOrLover:SetActiveWidgetIndex(0)
    self.UIRoot.TextBlock_QingLv:SetText(curCount[2] .. "/" .. relationStatus[2].maxCount)
  end
  self.UIRoot.TextBlock_SiDang:SetText(curCount[3] .. "/" .. relationStatus[3].maxCount)
  self.UIRoot.TextBlock_GuiMi:SetText(curCount[4] .. "/" .. relationStatus[4].maxCount)
  self.UIRoot.TextBlock_Jiaren:SetText(curCount[5] .. "/" .. (relationStatus[5] and relationStatus[5].maxCount or 6))
  self:UpdateRedPoint()
  self:RefreshApplyReddot()
end
function UI_RoleInfo_Relationship_New:UpdateRedPoint()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE) then
    self.UIRoot.Red1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Red1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:SetApplyRed()
end
function UI_RoleInfo_Relationship_New:SetApplyRed()
  local ApplyList = LogicFriend.GetApplyIntimacyList()
  if ApplyList and next(ApplyList) then
    DataMgr.SaveLocalIntimateApplyRed(ApplyList)
  end
end
function UI_RoleInfo_Relationship_New:InitData()
  self.system.InitStatusData()
  self.system.UpdataRelationStatusData()
  self.system.UpdateSecrecySetting(self.uid)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local IsSelf = self.system.IsMySelf(self.uid)
  if IsSelf then
    PersonSpaceSystem.get_intimacy_relation_visible_req()
    PersonSpaceSystem.get_intimacy_relation_req()
  else
    PersonSpaceSystem.get_other_intimacy_relation_req(self.uid)
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.PERSON_RELATION, {
    self.uid
  })
  self:RefreshWeeklySummaryReddot()
  self:RefreshApplyReddot()
end
function UI_RoleInfo_Relationship_New:ShowRestrictTip()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:ShowRestrictTips()
end
function UI_RoleInfo_Relationship_New:OnClickedLevelOneTab(_, index)
  log(bWriteLog and "[v_ruikyuan] UI_RoleInfo_Relationship_New:UpdateUI current level one selected index: " .. tostring(self.Common_Tab_Horizontal_LevelOne_Text_UIBP:GetSelectedIndex()))
  self:PlayAudio(sound_config.click_v1)
  if self.selectIndex == index then
    return
  end
  self.selectIndex = index
  self:RefresTabView()
end
function UI_RoleInfo_Relationship_New:RefresTabView()
  if self.selectIndex == 2 then
    self.UIRoot.GangUp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.GangUp:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.selectIndex == 1 then
    if self.showRelationshipNet then
      self:_SetShowMode(0)
    else
      self:_SetShowMode(1)
    end
  elseif self.selectIndex == 2 then
    self:_SetShowMode(2)
  end
end
function UI_RoleInfo_Relationship_New:_SetShowMode(mode)
  printf("UI_RoleInfo_Relationship_New:_SetShowMode mode: %s", mode)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(mode)
  if mode == 0 then
    self:SetWidgetVisible(self.UIRoot.Button_ShowType, true, true)
    self.UIRoot.TextBlock_Reletionship:SetText(LocUtil.GetLocalizeResStr(18403))
    self.child_Net:UpdateUI()
  elseif mode == 1 then
    self:SetWidgetVisible(self.UIRoot.Button_ShowType, true, true)
    self.UIRoot.TextBlock_Reletionship:SetText(LocUtil.GetLocalizeResStr(44363))
    self.child_Overview:UpdateUI()
  elseif mode == 2 then
    self:SetWidgetVisible(self.UIRoot.Button_ShowType, false)
    self.child_CanBuild:UpdateUI()
    local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
    if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE) then
      PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE)
    end
    self:RefreshCanBuildReddot()
  end
end
function UI_RoleInfo_Relationship_New:ProcessExtraData()
  if not self.extraData then
    return
  end
  if self.extraData.viewIndex == 1 then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Popup_UIBP, self.extraData.friendUid)
    return
  end
  local intimacy = tonumber(LogicFriend.GetInnerFriendIntimacy(self.extraData.friendUid))
  if intimacy >= LogicFriend.Friend_Intimacy_Threshold then
    local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
    IntimacyUtils.ShowIntimacyApplyUI(self.extraData.friendUid, true)
  end
end
function UI_RoleInfo_Relationship_New:OnSettingClicked()
  self:PlayAudio(sound_config.click_v1)
  if tonumber(self.uid) == tonumber(DataMgr.roleData.uid) then
    local SettingUtil = require("client.slua.logic.setting.setting_util")
    local SettingMacro = require("client.slua.logic.setting.setting_macro")
    SettingUtil.Enter("PrivacyAndSocial")
  end
end
function UI_RoleInfo_Relationship_New:OnShareClicked()
  self:PlayAudio(sound_config.click_v1)
  if tonumber(self.uid) == tonumber(DataMgr.roleData.uid) then
    local Util = require("client.slua_ui_framework.util")
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local seasonIdForSegment = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
    local logic_season_util = require("client.logic.season.logic_season_util")
    local segmentLevel, maxMode, zoneId = logic_season_util:GetCurrZoneMaxSegment(DataMgr.roleData.allzoneSegment)
    local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
    local segmentTitleId = logic_segment_title:GetSelfSegmentTitleId(zoneId, maxMode)
    local shareCfg = {
      sceneType = 3,
      isOld = true,
      campaign = "roleinfo",
      bShowPoseSelect = false,
      share_type = ShareBtnTLogShareTypeDefine.Intimacy,
      segmentLevel = segmentLevel,
      seasonIdForSegment = seasonIdForSegment,
          }
    Util.ShowShare(shareCfg, UIManager.UI_Config.Lobby_RoleInfo_Share_UIBP)
    local ShareMgr = require("client.logic.share.share_logic")
    ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.Intimacy, nil, nil)
  end
end
function UI_RoleInfo_Relationship_New:OnButton_CohabitClick()
  self:PlayAudio(sound_config.click_v1)
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if logic_home_joint:HasJointHome() then
    local Home_DoubleOccupancy_Popups_UIBP = UIManager.ShowUI(UIManager.UI_Config.Home_DoubleOccupancy_Popups_UIBP, logic_home_joint.res_joint_info.mate_uid, tonumber(DataMgr.roleData.uid), tonumber(DataMgr.roleData.uid))
    Home_DoubleOccupancy_Popups_UIBP:ShowJointSucceed(logic_home_joint.res_joint_info.last_joint_time, true)
  elseif logic_home_joint:IsIntermediateState() then
    ShowNotice(19810260)
    local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
    PHomeJointHandler.send_manor_joint_info_req()
  else
    if not LobbySystem.CheckOpen(BP_ENUM_MODULE_PLANPH_HOME_COHABIT) then
      ShowNotice(511702)
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Cohabit_Popup_UIBP)
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeJointEntryUsed) or {}
  if saveData.bHasUsedCohabit then
    return
  end
  self:SetWidgetVisible(self.UIRoot.Image_CohabitReddot, false)
  saveData.bHasUsedCohabit = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eHomeJointEntryUsed)
  local tmpUI = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if tmpUI then
    tmpUI:RefreshIntimacyReddot()
  end
end
function UI_RoleInfo_Relationship_New:OnRecruitmentClicked()
  self:PlayAudio(sound_config.click_v1)
  local needFetchNew = true
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  if SocialLobbyHandler.bHasStateData and SocialLobbyHandler.intimacy_conscribe_state == nil then
    needFetchNew = false
  end
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_Intimacy_List_UIBP, needFetchNew)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Lobby_Intimacy_Click_Entry)
  if self.bShowRecruitmentLight then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local TimeUtil = require("client.common.time_util")
    self:SetWidgetVisible(self.UIRoot.Image_Lightloop, false)
    self.bShowRecruitmentLight = false
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.IntimateRelationSearchRefreshTime) or {}
    cfg[DataMgr.roleData.uid] = TimeUtil.GetServerTimeInSec()
    PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.IntimateRelationSearchRefreshTime)
  end
end
function UI_RoleInfo_Relationship_New:OnPartnerClicked()
  self:PlayAudio(sound_config.click_v1)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE) then
    PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE)
  end
  IntimacyAwardSystem.get_intimacy_reward_info_req(true)
  IntimacyAwardSystem.get_posture_info_req()
end
function UI_RoleInfo_Relationship_New:OnClickButton_IntimacyJump()
  self:PlayAudio(sound_config.click_v1)
  if self.jumpAwardUID and self.jumpAwardUID > 0 then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Popup_UIBP, self.jumpAwardUID)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Intimacy_Popup_Strategy_UIBP, 3)
end
function UI_RoleInfo_Relationship_New:OnClickButton_GuidePop()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Intimacy_Popup_Strategy_UIBP, 1)
end
function UI_RoleInfo_Relationship_New:OnButton_MenuClick()
  self:PlayAudio(sound_config.click_v1)
  self.bPopMenu = not self.bPopMenu
  self:Update_PopMenu()
end
function UI_RoleInfo_Relationship_New:OnButton_WeekSummaryClick()
  self:PlayAudio(sound_config.click_v1)
  local friend_interact_tool = require("client.slua.logic.friend.Interact.friend_interact_tool")
  local file = friend_interact_tool.LoadFile()
  local curtime = FuncUtil.GetServerTimeInSec()
  if not file then
    file = {}
  else
    local TimeUtil = require("client.common.time_util")
    local bissameWeek = TimeUtil.IsSameWeek(file.time_read, curtime)
    if not bissameWeek then
      log(bWriteLog and "[v_zhwvzhang] UI_RoleInfo_Relationship_New:OnButton_WeekSummaryClick not same week:FriendHandler.send_get_all_friendlist_req")
      local FriendHandler = require("client.network.Protocol.FriendHandler")
      FriendHandler.send_get_all_friendlist_req()
    end
  end
  file.time_read = curtime
  friend_interact_tool.SaveFile(file)
  self:RefreshWeeklySummaryReddot()
  self.bPopMenu = false
  self:Update_PopMenu()
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_Weekly_Summary_Popup_UIBP)
end
function UI_RoleInfo_Relationship_New:ShowPartner()
end
function UI_RoleInfo_Relationship_New:OnApplyClicked()
  self:PlayAudio(sound_config.click_v1)
  self.bPopMenu = false
  self:Update_PopMenu()
  UIManager.ShowUI(UIManager.UI_Config.friend_applylist, true)
end
function UI_RoleInfo_Relationship_New:OnOpenBlackClicked()
  self:PlayAudio(sound_config.click_v1)
  local logic_friend_gang_up = require("client.slua.logic.friend.logic_friend_gang_up")
  local friend_counts = logic_friend_gang_up.GetFriendCounts()
  if friend_counts ~= nil then
    UIManager.ShowUI(UIManager.UI_Config.Intimacy_Popup_Black_UIBP, true)
  else
    UIManager.ShowUI(UIManager.UI_Config.Intimacy_Popup_Rules_UIBP, true)
  end
end
function UI_RoleInfo_Relationship_New:OnButton_LockClick()
  self:PlayAudio(sound_config.click_v1)
  self:ShowRestrictTip()
end
function UI_RoleInfo_Relationship_New:Button_ApplyListLockClick()
  self:PlayAudio(sound_config.click_v1)
  self:ShowRestrictTip()
end
function UI_RoleInfo_Relationship_New:OnClickButton_JumpRank()
  self:PlayAudio(sound_config.click_v1)
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  RankDataMgr.SetRankSelectType("intimacy")
  GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_RANK .. "&to=intimacy")
end
function UI_RoleInfo_Relationship_New:OnChangeShowType()
  self:PlayAudio(sound_config.click_v1)
  self.showRelationshipNet = not self.showRelationshipNet
  self:_RefreshShowNetOrNot()
end
function UI_RoleInfo_Relationship_New:_RefreshShowNetOrNot()
  printf("UI_RoleInfo_Relationship_New:_RefreshShowNetOrNot showRelationshipNet: %s", tostring(self.showRelationshipNet))
  if self.showRelationshipNet then
    local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
    local IsSelf = self.system.IsMySelf(self.uid)
    if IsSelf then
      PersonSpaceSystem.get_intimacy_relation_req()
    end
    self.UIRoot.TextBlock_Reletionship:SetText(LocUtil.GetLocalizeResStr(18403))
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self.child_Net:PlayUserWidgetAnimation(self.child_Net.UIRoot.Anim_in, 0, 1, 0, 1)
  else
    self.UIRoot.TextBlock_Reletionship:SetText(LocUtil.GetLocalizeResStr(44363))
    self.child_Overview:UpdateUI()
    local IsSelf = self.system.IsMySelf(self.uid)
    if IsSelf then
      local intimacyList = LogicFriend.GetIntimacyHasBuildList()
      self.child_Overview:IsSetKong(intimacyList)
    end
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  end
end
function UI_RoleInfo_Relationship_New:OnSharedBagRsp(_, _, uid, intimValue)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeJointEntryUsed) or {}
  if saveData.bHasShownCohabitGuide then
    self:TryShowSharedBag(uid, intimValue)
  else
    self:AddTimerOnce(0.83, function()
      self:TryShowSharedBag(uid, intimValue)
    end)
  end
end
function UI_RoleInfo_Relationship_New:TryShowSharedBag(uid, intimValue)
  if not uid or not intimValue then
    log(bWriteLog and "UI_RoleInfo_Relationship_New:TryShowSharedBag failed due to nil")
    return false
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Common_FirstPolymorphism_UIBP) or UIManager.IsUIShow(UIManager.UI_Config.level_unlock_bubble) then
    log(bWriteLog and "UI_RoleInfo_Relationship_New:TryShowSharedBag failed due to guide hinder")
    self.hinderedSharedBagPopup[uid] = intimValue
    return false
  else
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Popup_RoleInfo_Slap_UIBP, uid, intimValue)
    return true
  end
end
function UI_RoleInfo_Relationship_New:ShowHinderedSharedBag()
  log(bWriteLog and "UI_RoleInfo_Relationship_New:ShowHinderedSharedBag")
  for uid, intimValue in pairs(self.hinderedSharedBagPopup) do
    if uid and intimValue then
      UIManager.ShowUI(UIManager.UI_Config.Lobby_Popup_RoleInfo_Slap_UIBP, uid, intimValue)
    end
  end
  self.hinderedSharedBagPopup = {}
end
function UI_RoleInfo_Relationship_New:OnTakeIntimacyReward()
  log(bWriteLog and "UI_RoleInfo_Relationship_New:OnTakeIntimacyReward")
  self:RefreshIntimacyJumpBtnReddot()
end
function UI_RoleInfo_Relationship_New:OnSwitchUpdate()
  self.system.UpdateSecrecySetting(self.uid)
  self:UpdateUI()
end
function UI_RoleInfo_Relationship_New:CheckAndShowSystemGuide()
  local bIsGuideShowing = (self.system.NeedShowRelationGuide() or self.system.NeedShowCohabitRelationGuide()) and self.system.IsMySelf(self.uid)
  log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:CheckAndShowSystemGuide bIsGuideShowing = " .. tostring(bIsGuideShowing))
  if UIManager.GetUI(UIManager.UI_Config.Common_FirstPolymorphism_UIBP) then
    log(bWriteLog and "[DeanJYT] UI_RoleInfo_Relationship_New:CheckAndShowSystemGuide Common_FirstPolymorphism_UIBP is already showing")
    bIsGuideShowing = true
  end
  if bIsGuideShowing then
    local notesData = self.system.GetRelationSystemGuideData()
    UIManager.ShowUI(UIManager.UI_Config.Common_FirstPolymorphism_UIBP, notesData, function()
      self.system.SetHasShowRelationGuide()
    end, function()
      self:ShowHinderedSharedBag()
    end)
  end
  return bIsGuideShowing
end
function UI_RoleInfo_Relationship_New:RefreshIntimacyJumpBtnReddot()
  local IntimacyLevel = CDataTable.GetTable("IntimacyLevel")
  local intimacyList = LogicFriend.GetIntimacyHasBuildList()
  local hasDetailReddot = false
  self.jumpAwardUID = 0
  for _, data in pairs(intimacyList) do
    if data.awardlevel then
      for __, levelData in pairs(IntimacyLevel) do
        local bNeedCheckReddot = true
        local bIsLover = data.param == 2
        if bIsLover and levelData.LoverAwardType ~= 0 or levelData.AwardType ~= 0 then
          bNeedCheckReddot = false
        end
        if bNeedCheckReddot and 0 < levelData.ID and data.awardlevel < levelData.Level and data.intimacy >= levelData.MinExp then
          hasDetailReddot = true
          self.jumpAwardUID = data.uid
          break
        end
      end
      if self.jumpAwardUID > 0 then
        break
      end
    end
  end
  self:SetWidgetVisible(self.UIRoot.Image_IntimacyJumpReddot, hasDetailReddot)
end
function UI_RoleInfo_Relationship_New:RefreshCohabitBtnReddot()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local bHasCohabitReddot = PersonSpaceSystem.HasCohabitReddot()
  self:SetWidgetVisible(self.UIRoot.Image_CohabitReddot, bHasCohabitReddot)
end
function UI_RoleInfo_Relationship_New:RefreshRecruitmentLight()
  local intimacyList = LogicFriend.GetIntimacyHasBuildList()
  if not next(intimacyList) then
    local TimeUtil = require("client.common.time_util")
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.IntimateRelationSearchRefreshTime)
    if not cfg or not cfg[DataMgr.roleData.uid] then
      self:SetWidgetVisible(self.UIRoot.Image_Lightloop, true)
      self.bShowRecruitmentLight = true
    end
    if cfg and cfg[DataMgr.roleData.uid] then
      local isSameDay = TimeUtil.IsSameDay(cfg[DataMgr.roleData.uid], TimeUtil.GetServerTimeInSec())
      if not isSameDay then
        self.bShowRecruitmentLight = true
        self:SetWidgetVisible(self.UIRoot.Image_Lightloop, true)
      end
    end
  end
end
function UI_RoleInfo_Relationship_New:RefreshWeeklySummaryReddot()
  local friend_interact_tool = require("client.slua.logic.friend.Interact.friend_interact_tool")
  local file = friend_interact_tool.LoadFile()
  local bissameWeek = false
  if file then
    local TimeUtil = require("client.common.time_util")
    local curtime = FuncUtil.GetServerTimeInSec()
    bissameWeek = TimeUtil.IsSameWeek(file.time_read, curtime)
  end
  if bissameWeek then
    self.UIRoot.Image_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.bWeekSummaryReddot = false
  else
    self.UIRoot.Image_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.bWeekSummaryReddot = true
  end
  local log_str = friend_interact_tool.GetStatisLog()
  if log_str == "" then
    self.UIRoot.Image_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.bWeekSummaryReddot = false
  end
  self:RefreshTreePointReddot()
end
function UI_RoleInfo_Relationship_New:RefreshCanBuildReddot()
  log(bWriteLog and "UI_RoleInfo_Relationship_New:RefreshCanBuildReddot")
  if self.Common_Tab_Horizontal_LevelOne_Text_UIBP then
    local buildReddotWidget = self.Common_Tab_Horizontal_LevelOne_Text_UIBP:GetItemReddotAnchor(2)
    if buildReddotWidget then
      local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
      local hasReddot = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE)
      log(bWriteLog and "UI_RoleInfo_Relationship_New:RefreshCanBuildReddot " .. tostring(hasReddot))
      self:SetWidgetVisible(buildReddotWidget, hasReddot)
    else
      log(bWriteLog and "UI_RoleInfo_Relationship_New:RefreshCanBuildReddot no widget")
    end
  else
    log(bWriteLog and "UI_RoleInfo_Relationship_New:RefreshCanBuildReddot no ui")
  end
end
function UI_RoleInfo_Relationship_New:RefreshApplyReddot()
  log(bWriteLog and "UI_RoleInfo_Relationship_New:RefreshApplyReddot - Start refreshing apply reddot")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local apply_count = LogicFriend.GetAllApplyCntWithProfileCheck()
  local friendApply_count = 0
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  local applyList = logic_friend_apply:GetApplyList()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for i, v in pairs(applyList) do
    local profile = logic_profile:GetLocalProfile(v.uid)
    if profile and not profile.is_del then
      friendApply_count = friendApply_count + 1
    end
  end
  apply_count = apply_count - friendApply_count
  if 0 < apply_count then
    self:SetWidgetVisible(self.UIRoot.Image_ApplyReddot, true)
    self.bIntimacyApplyReddot = true
    log(bWriteLog and "UI_RoleInfo_Relationship_New:RefreshApplyReddot - Show reddot, apply count: " .. tostring(apply_count))
  else
    self:SetWidgetVisible(self.UIRoot.Image_ApplyReddot, false)
    self.bIntimacyApplyReddot = false
    log(bWriteLog and "UI_RoleInfo_Relationship_New:RefreshApplyReddot - Hide reddot, no apply")
  end
  self:RefreshTreePointReddot()
end
function UI_RoleInfo_Relationship_New:RefreshTreePointReddot()
  log(bWriteLog and "UI_RoleInfo_Relationship_New:RefreshTreePointReddot")
  if self.bIntimacyApplyReddot or self.bWeekSummaryReddot then
    self:SetWidgetVisible(self.UIRoot.Image_Reddot02, true)
  else
    self:SetWidgetVisible(self.UIRoot.Image_Reddot02, false)
  end
end
function UI_RoleInfo_Relationship_New:RefreshTab(_, _, args)
  local tabIndex = args and args.tabIndex or nil
  if tabIndex then
    self.Common_Tab_Horizontal_LevelOne_Text_UIBP:Select(tabIndex)
    self.selectIndex = tabIndex
    if tabIndex == 1 and args.showRelationshipNet ~= nil then
      self.showRelationshipNet = args.showRelationshipNet
    end
    self:RefresTabView()
    self.child_Overview:AutoExpandFirstItemMenu()
  end
end
function UI_RoleInfo_Relationship_New:ShowPopupGuide()
  log(bWriteLog and "UI_RoleInfo_Relationship_New:ShowPopupGuide")
  if not self:CheckAndShowSystemGuide() then
    self:ShowCohabitEntranceGuide()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUIRoleInfo_Relationship = class(ui_base, nil, UI_RoleInfo_Relationship_New)
return CUIRoleInfo_Relationship