local TeamQuick_TeamApplication_Popup = {}
local ApplicationUITabs = {
  Friend = 1,
  TeamApply = -1,
  TeamInvite = 2
}
local EnumApplyType = {
  AddFriend = 1,
  Relation = 2,
  Partner = 3,
  RelationChange = 4,
  RelationCustomNameChange = 5,
  HomeJoint = 6,
  HomeJointTerminate = 7
}
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
function TeamQuick_TeamApplication_Popup:ctor(_, selectTab)
  self.selectTab = selectTab or 1
end
function TeamQuick_TeamApplication_Popup:OnInitialize()
  self.LoopScrollGrid_Player = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_Player, "client.slua.umg.TeamQuick.Popup.Item.TeamQuick_TeamApplication_Item")
  self.Common_Popup_Large_HaveTab_UIBP = self:InitCommonPopupWithTab(self.UIRoot.Common_Popup_Large_HaveTab_UIBP)
  local extra = {}
  self.ReuseListMultiSize_Apply = self:InitReuseListMultiSize(self.UIRoot.ReuseListMultiSize_Apply, "client.slua.umg.friend.friend_applylist_item")
  self.Common_Popup_Large_HaveTab_UIBP:SetData(self, LocUtil.GetLocalizeResStr(817090), extra)
  self.Common_Popup_Large_HaveTab_UIBP:SetTabsData({
    {
      txt = LocUtil.GetLocalizeResStr(8891)
    },
    {
      txt = LocUtil.GetLocalizeResStr(817091)
    }
  }, self.selectTab)
  self.Common_Popup_Large_HaveTab_UIBP:AddSelectTabEvent(self.OnClickTab, self)
end
function TeamQuick_TeamApplication_Popup:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_All_Read, self.OnClickButton_All_Read, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_All_Agree, self.OnClickButton_All_Agree, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_All_Reject, self.OnClickButton_All_Reject, self)
  if self.UIRoot.Button_0 then
    self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickedRestirct, self)
  end
  if self.UIRoot.Button_Restrict then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Restrict, self.OnClickedRestirct, self)
  end
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INFO_UPDATE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACYAPPLY_CHANGE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVETNID_PLANPH_JOINT_INFO_UPDATE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE, self.UpdateUI, self)
end
function TeamQuick_TeamApplication_Popup:OnPostInitialize()
  self:UpdateUI()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:ReqInviteData()
  logic_flash_match_team:CheckInvitorProfiles(true)
end
function TeamQuick_TeamApplication_Popup:OnClose()
end
function TeamQuick_TeamApplication_Popup:OnClickButton_All_Reject()
  log(bWriteLog and "TeamQuick_TeamApplication_Popup:OnClickButton_All_Reject")
  self:PlayAudio(sound_config.click_v1)
  self.lastClickAll = self.lastClickAll or 0
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if math.abs(curTime - self.lastClickAll) < 1 then
    ShowNotice(87969)
    return
  end
  self.lastClickAll = curTime
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  if self.selectTab == ApplicationUITabs.Friend then
    local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
    logic_friend_apply:batch_add_inner_friend_op_req(0)
    if self.bHaveIntimacyApply then
      ShowNotice(11826)
    end
  elseif self.selectTab == ApplicationUITabs.TeamApply then
    logic_flash_match_team:IgnoreAllApplyNew()
  elseif self.selectTab == ApplicationUITabs.TeamInvite then
    logic_flash_match_team:IgnoreAllInvite()
  end
end
function TeamQuick_TeamApplication_Popup:OnClickButton_All_Agree()
  log(bWriteLog and "TeamQuick_TeamApplication_Popup:OnClickButton_All_Agree")
  self:PlayAudio(sound_config.click_v1)
  self.lastClickAll = self.lastClickAll or 0
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if math.abs(curTime - self.lastClickAll) < 1 then
    ShowNotice(87969)
    return
  end
  self.lastClickAll = curTime
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  if self.selectTab == ApplicationUITabs.Friend then
    local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
    logic_friend_apply:batch_add_inner_friend_op_req(1)
    if self.bHaveIntimacyApply then
      ShowNotice(11826)
    end
  elseif self.selectTab == ApplicationUITabs.TeamApply then
    logic_flash_match_team:AgreeAllApplyNew()
  elseif self.selectTab == ApplicationUITabs.TeamInvite then
    logic_flash_match_team:AgreeAllInvite()
  end
end
function TeamQuick_TeamApplication_Popup:OnClickButton_All_Read()
  self:PlayAudio(sound_config.click_v1)
end
function TeamQuick_TeamApplication_Popup:OnClickedRestirct()
  self:PlayAudio(sound_config.click_v1)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:ShowRestrictTips()
end
function TeamQuick_TeamApplication_Popup:UpdateUI()
  log(bWriteLog and "TeamQuick_TeamApplication_Popup:UpdateUI selectTab = " .. tostring(self.selectTab))
  self:SetWidgetVisible(self.UIRoot.LoopScrollGrid_Player, self.selectTab ~= ApplicationUITabs.Friend, true)
  self:SetWidgetVisible(self.UIRoot.ReuseListMultiSize_Apply, self.selectTab == ApplicationUITabs.Friend, true)
  self.UIRoot.TextBlock_All_Agree:SetText(LocUtil.GetLocalizeResStr(817097))
  self.UIRoot.TextBlock_All_Reject:SetText(LocUtil.GetLocalizeResStr(817096))
  if self.selectTab == ApplicationUITabs.Friend then
    self:UpdateFriendUI()
    return
  elseif self.selectTab == ApplicationUITabs.TeamApply then
    self:UpdateTeamApplyUI()
  elseif self.selectTab == ApplicationUITabs.TeamInvite then
    self:UpdateTeamInviteUI()
  end
end
function TeamQuick_TeamApplication_Popup:OnClickTab(widget, index)
  if widget then
    self:PlayAudio(sound_config.click_v1)
    if self.selectTab == index then
      return
    end
  end
  self.selectTab = index
  self:UpdateUI()
end
function TeamQuick_TeamApplication_Popup:UpdateFriendUI()
  self.List = {}
  self.bHaveIntimacyApply = false
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local firstIndex = 1
  if PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list then
    for uid, _ in pairs(PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list) do
      local data = {
        uid = uid,
        type = EnumApplyType.Partner,
        first = firstIndex == 1
      }
      firstIndex = firstIndex + 1
      self.List[#self.List + 1] = data
      self.bHaveIntimacyApply = true
    end
  end
  firstIndex = 1
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local intimacyList = LogicFriend.GetIntimacyList(false)
  for _, relationData in pairs(intimacyList) do
    if relationData.state == 2 then
      relationData.type = EnumApplyType.Relation
      relationData.first = firstIndex == 1
      firstIndex = firstIndex + 1
      self.List[#self.List + 1] = relationData
      self.bHaveIntimacyApply = true
    end
  end
  firstIndex = 1
  local changeRelationList = LogicFriend.GetChangeRelationApplyList()
  if changeRelationList and next(changeRelationList) then
    for _, changeData in pairs(changeRelationList) do
      changeData.type = EnumApplyType.RelationChange
      changeData.first = firstIndex == 1
      firstIndex = firstIndex + 1
      self.List[#self.List + 1] = changeData
      self.bHaveIntimacyApply = true
    end
  end
  firstIndex = 1
  local changeCustomNameList = LogicFriend.GetChangeCustomNameApplyList()
  if changeCustomNameList and next(changeCustomNameList) then
    for _, customNameData in pairs(changeCustomNameList) do
      local data = {
        uid = customNameData.uid,
        relation = customNameData.relation,
        type = EnumApplyType.RelationCustomNameChange,
        first = firstIndex == 1
      }
      firstIndex = firstIndex + 1
      self.List[#self.List + 1] = data
      self.bHaveIntimacyApply = true
    end
  end
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  local applyList = logic_friend_apply:GetApplyList()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  firstIndex = 1
  for _, applyData in pairs(applyList) do
    local profile = logic_profile:GetLocalProfile(applyData.uid)
    if profile and not profile.is_del then
      applyData.type = EnumApplyType.AddFriend
      applyData.first = firstIndex == 1
      firstIndex = firstIndex + 1
      self.List[#self.List + 1] = applyData
    end
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local AddHomeJointList = function(listData, applyType)
    local listIndex = 1
    for _, jointData in pairs(listData) do
      jointData.uid = jointData.fromId
      local profile = logic_profile:GetLocalProfile(jointData.uid)
      if profile then
        jointData.type = applyType
        jointData.first = listIndex == 1
        listIndex = listIndex + 1
        self.List[#self.List + 1] = jointData
      end
    end
  end
  AddHomeJointList(logic_home_joint:GetJointApplications(), EnumApplyType.HomeJoint)
  AddHomeJointList(logic_home_joint:GetTerminateApplications(), EnumApplyType.HomeJointTerminate)
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  for _, listItem in pairs(self.List) do
    if listItem.type == EnumApplyType.Relation then
      if listItem.param == IntimacyConst.EIntimacyType.Bonding then
        PersonSpaceHandler.send_get_other_intimacy_relation_req(listItem.uid)
      end
    elseif listItem.type == EnumApplyType.RelationChange and listItem.changeData and listItem.changeData.param == IntimacyConst.EIntimacyType.Bonding then
      PersonSpaceHandler.send_get_other_intimacy_relation_req(listItem.uid)
    end
  end
  self:AddTimer(0.1, function()
    if self.ReuseListMultiSize_Apply then
      self.ReuseListMultiSize_Apply:SetData(self.List)
    end
  end)
  self:UpdateFriendsButtons()
end
function TeamQuick_TeamApplication_Popup:UpdateFriendsButtons()
  local showBatch = true
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  local applyList = logic_friend_apply:GetApplyList()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local friendApplyCount = 0
  for _, applyData in pairs(applyList) do
    local profile = logic_profile:GetLocalProfile(applyData.uid)
    if profile then
      friendApplyCount = friendApplyCount + 1
    end
  end
  if friendApplyCount == 0 then
    showBatch = false
  end
  local bHasBondingApply = false
  for _, listItem in pairs(self.List) do
    if listItem.type == EnumApplyType.Relation then
      if listItem.param == IntimacyConst.EIntimacyType.Bonding then
        bHasBondingApply = true
      end
    elseif listItem.type == EnumApplyType.RelationChange and listItem.changeData and listItem.changeData.param == IntimacyConst.EIntimacyType.Bonding then
      bHasBondingApply = true
    end
  end
  local canShowBatch = showBatch and not bHasBondingApply and self.selectTab == ApplicationUITabs.Friend
  if self.UIRoot.Button_All_Agree then
    self.UIRoot.Button_All_Agree:SetWidgetVisibility(canShowBatch and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.Button_All_Reject then
    self.UIRoot.Button_All_Reject:SetWidgetVisibility(canShowBatch and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed)
  end
  if canShowBatch then
    self:CheckSocialRestrict()
  elseif self.UIRoot.Button_Restrict and self.UIRoot.Button_0 then
    self:SetWidgetVisible(self.UIRoot.Button_Restrict, false, true)
    self:SetWidgetVisible(self.UIRoot.Button_0, false, true)
  end
  if self.UIRoot.Chicken then
    self.UIRoot.Chicken:SetWidgetVisibility(next(self.List) and UEnums.ESlateVisibility.Collapsed or UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function TeamQuick_TeamApplication_Popup:UpdateApplyOrInviteButtons(isApply)
  local showBatch = true
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local applyList = isApply and logic_flash_match_team:GetFlashTeamApplyList() or logic_flash_match_team:GetFlashTeamInviteList()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local applyWithProfileCount = 0
  for _, applyData in pairs(applyList) do
    local showUid = isApply and applyData.applicant_uid or applyData.inviter_uid
    local profile = logic_profile:GetLocalProfile(showUid)
    if profile then
      applyWithProfileCount = applyWithProfileCount + 1
    end
  end
  if applyWithProfileCount == 0 then
    showBatch = false
  end
  local isCorrectTab = self.selectTab == ApplicationUITabs.TeamApply or self.selectTab == ApplicationUITabs.TeamInvite
  local canShowBatch = showBatch and isCorrectTab and isApply
  if self.UIRoot.Button_All_Agree then
    self.UIRoot.Button_All_Agree:SetWidgetVisibility(canShowBatch and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.Button_All_Reject then
    self.UIRoot.Button_All_Reject:SetWidgetVisibility(canShowBatch and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed)
  end
  if canShowBatch then
    self:CheckSocialRestrict()
  elseif self.UIRoot.Button_Restrict and self.UIRoot.Button_0 then
    self:SetWidgetVisible(self.UIRoot.Button_Restrict, false, true)
    self:SetWidgetVisible(self.UIRoot.Button_0, false, true)
  end
  if self.UIRoot.Chicken then
    self.UIRoot.Chicken:SetWidgetVisibility(next(applyList) and UEnums.ESlateVisibility.Collapsed or UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function TeamQuick_TeamApplication_Popup:CheckSocialRestrict()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRestrict = QRcodeRestrictManager:IsRestrictSocial()
  if self.UIRoot.Button_Restrict and self.UIRoot.Button_0 then
    self:SetWidgetVisible(self.UIRoot.Button_Restrict, isRestrict, true)
    self:SetWidgetVisible(self.UIRoot.Button_0, isRestrict, true)
  end
end
function TeamQuick_TeamApplication_Popup:UpdateTeamApplyUI()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local flashTeamApplyList = logic_flash_match_team:GetFlashTeamApplyList()
  self.TeamApplyData = flashTeamApplyList
  for _, data in pairs(self.TeamApplyData) do
    data.isApply = true
  end
  table.sort(self.TeamApplyData, function(a, b)
    return (a.create_time or 0) > (b.create_time or 0)
  end)
  self.LoopScrollGrid_Player:SetData(self.TeamApplyData)
  self:UpdateApplyOrInviteButtons(true)
end
function TeamQuick_TeamApplication_Popup:UpdateTeamInviteUI()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local flashTeamInviteList = logic_flash_match_team:GetFlashTeamInviteList()
  self.TeamInviteData = flashTeamInviteList
  for _, data in pairs(self.TeamInviteData) do
    data.isInvite = true
  end
  table.sort(self.TeamInviteData, function(a, b)
    return (a.timestamp or 0) > (b.timestamp or 0)
  end)
  self.LoopScrollGrid_Player:SetData(self.TeamInviteData)
  self:UpdateApplyOrInviteButtons(false)
end
function TeamQuick_TeamApplication_Popup:ApplyTestData()
  log(bWriteLog and "TeamQuick_TeamApplication_Popup:ApplyTestData")
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  self.TeamApplyData = {
    [1] = {
      applicant_uid = tonumber(DataMgr.roleData.uid),
      inviter_uid = tonumber(DataMgr.roleData.uid),
      apply_id = 1,
      source = 1,
      status = 1,
      create_time = 1717000000,
      player_brief = {
        nickName = "##\228\184\180\230\151\182\230\181\139\232\175\149\230\149\176\230\141\1742",
        picUrl = "10001",
        cur_avatar_box_id = 1
      }
    }
  }
  logic_flash_match_team:SetFlashTeamApplyList(self.TeamApplyData)
  self.TeamInviteData = {
    [1] = {
      inviter_uid = tonumber(DataMgr.roleData.uid),
      source = 1,
      status = 1,
      create_time = 1717000000,
      player_brief = {
        nickName = "##\228\184\180\230\151\182\230\181\139\232\175\149\230\149\176\230\141\1741",
        picUrl = "10001",
        cur_avatar_box_id = 1
      }
    }
  }
  logic_flash_match_team:SetFlashTeamInviteList(self.TeamInviteData)
  self:UpdateUI()
end
function TeamQuick_TeamApplication_Popup:GetTestGM()
  local parentWidgetName = "HorizontalBox_0"
  local gmData = {
    {
      name = "\229\129\135\230\149\176\230\141\174",
      func = function()
        ShowNotice("FakeData")
        self:ApplyTestData()
      end
    },
    {
      name = "\230\139\137\229\143\150\230\149\176\230\141\174",
      func = function()
        ShowNotice("ReqData")
        local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
        logic_flash_match_team:ReqApplyData()
        logic_flash_match_team:ReqInviteData()
        self:ApplyTestData()
      end
    }
  }
  return {parentWidgetName = parentWidgetName, data = gmData}
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, TeamQuick_TeamApplication_Popup)