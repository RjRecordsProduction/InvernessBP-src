local friend_applylist_item = {}
local EnumApplyType = {
  AddFriend = 1,
  Relation = 2,
  Partner = 3,
  RelationChange = 4,
  RelationCustomNameChange = 5,
  HomeJoint = 6,
  HomeJointTerminate = 7
}
function friend_applylist_item:OnInitialize()
  friend_applylist_item.__super.OnInitialize(self)
end
function friend_applylist_item:RegistEvents()
  friend_applylist_item.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Common_Avatar_BP, "OnClickItemCallback", self.OnClickedHead, self)
  self:AddControlEventByControl(self.UIRoot.BtnOK, "OnClicked", self.OnClickedOK, self)
  self:AddControlEventByControl(self.UIRoot.BtnNo, "OnClicked", self.OnClickedNo, self)
  self:AddControlEventByControl(self.UIRoot.Button_Shield, "OnClicked", self.OnClickedShield, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_1, self.OnClickedRestirct, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Restrict, self.OnClickedRestirct, self)
end
function friend_applylist_item:OnRefresh(data)
  log(bWriteLog and "friend_applylist_item:OnRefresh")
  local widget = self.UIRoot
  self:SetWidgetVisible(widget.BtnNo, true, true)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(data.uid)
  if profile then
    widget.Common_Avatar_BP:InitView(1, data.uid, profile.picUrl, tonumber(profile.sex), profile.cur_avatar_box_id, profile.level, false, "")
    local maxRank = FuncUtil.GetCurMaxSegementLevel(profile.segment_info)
    widget.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteral(maxRank, nil)
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
      self:SetWidgetVisible(widget.SizeBox_Nation, false)
    else
      local UIUtil = require("client.common.ui_util")
      UIUtil.UpdateNationImage(widget.Image_Nation, profile.nation)
    end
    if profile.social_card and profile.social_card.new_sex and profile.social_card.new_sex > 0 then
      widget.SizeBox_9:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      widget.Common_Gender_UIBP:LoadIcon(profile.uid)
    else
      widget.SizeBox_9:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    widget.Common_LightBoard_UIBP:ShowLightBoard(data.uid, widget.CanvasPanel_Family)
    widget.TextName:SetText(profile.nickName)
    local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
    local newFont = self.UIRoot.TextName.Font
    if NicknameColorManager:GetUserData(profile.uid) == 61910001 then
      newFont.OutlineSettings.OutlineSize = 1
      newFont.OutlineSettings.OutlineColor = FLinearColor(0, 0, 0, 0.7)
    else
      newFont.OutlineSettings.OutlineSize = 0
      newFont.OutlineSettings.OutlineColor = FLinearColor(0, 0, 0, 1)
    end
    self.UIRoot.TextName:SetFont(newFont)
    widget.TextName:SetColorAndOpacity(NicknameColorManager:GetColorByUID(data.uid, ENUM_NAME_COLOR_UI_TYPE.FriendApply))
    if profile.alias and profile.alias.id and 0 < profile.alias.id then
      widget.Title_UIBP:SetAliasInfo(profile.alias.id or 0, profile.alias.title or "", profile.alias.nation or "", 0, profile.alias.rank_id or 0)
      widget.title_box:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget.title_box:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    widget.Common_Certification_UIBP:SetAuthInfo(profile.auth_type, profile.auth_end_time)
  end
  if data.first then
    widget.CanvasPanel_Type:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.CanvasPanel_Type:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  widget.GridPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if data.can_be_hidden == 1 then
    widget.Button_Shield:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    widget.Button_Shield:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:SetWidgetVisible(widget.CanvasPanel_Labels, false)
  widget.TextBlock_258:SetText(LocUtil.LocalizeResFormat(117035))
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if data.type == EnumApplyType.Partner then
    widget.WidgetSwitcher_Type:SetActiveWidgetIndex(2)
    widget.Text_Type:SetText(LocUtil.LocalizeResFormat(34643))
    widget.Text_ApplyTime:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Intimacy:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local intimacy = LogicFriend.GetInnerFriendIntimacy(data.uid)
    widget.Text_Intimacy:SetText(tostring(intimacy))
    widget.Partner:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local relation = LogicFriend.GetRelation(data.uid)
    local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
    self:SetTexture(self.UIRoot.Image_Relation, IntimacyAwardSystem.GetInitimacyIcon_other_new(relation))
    local str = LocUtil.LocalizeResFormat(35059)
    widget.Text_Apply_Partner:SetText(LocUtil.LocalizeResFormat(35060, str))
  elseif data.type == EnumApplyType.Relation then
    widget.WidgetSwitcher_Type:SetActiveWidgetIndex(1)
    widget.Text_Type:SetText(LocUtil.LocalizeResFormat(34644))
    widget.Text_ApplyTime:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Intimacy:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local intimacy = LogicFriend.GetInnerFriendIntimacy(data.uid)
    widget.Text_Intimacy:SetText(tostring(intimacy))
    widget.Partner:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
    local IntimacyTypeStr = ""
    if data.param ~= 6 then
      IntimacyTypeStr = LocUtil.GetLocalizeResStr(IntimacyConst.C_InviteBeText[data.param])
    else
      IntimacyTypeStr = LocUtil.LocalizeResFormat(IntimacyConst.C_InviteBeText[data.param])
    end
    widget.UTRichTextBlock_0:SetText(IntimacyTypeStr)
  elseif data.type == EnumApplyType.RelationChange then
    widget.WidgetSwitcher_Type:SetActiveWidgetIndex(1)
    widget.Text_Type:SetText(LocUtil.LocalizeResFormat(73288))
    widget.Text_ApplyTime:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Intimacy:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local intimacy = LogicFriend.GetInnerFriendIntimacy(data.uid)
    widget.Text_Intimacy:SetText(tostring(intimacy))
    widget.Partner:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local relation = LogicFriend.GetRelationText(data.relation)
    local text = LocUtil.LocalizeResFormat(73285, relation)
    widget.UTRichTextBlock_0:SetText(text)
  elseif data.type == EnumApplyType.RelationCustomNameChange then
    widget.WidgetSwitcher_Type:SetActiveWidgetIndex(1)
    widget.Text_Type:SetText(LocUtil.LocalizeResFormat(73262))
    widget.Text_ApplyTime:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Intimacy:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local intimacy = LogicFriend.GetInnerFriendIntimacy(data.uid)
    widget.Text_Intimacy:SetText(tostring(intimacy))
    widget.Partner:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local icons = {
      [0] = " ",
      [1] = "<img src=\"jiyou_New\"/>",
      [2] = "<img src=\"qinglv_New\"/>",
      [3] = "<img src=\"sidang_New\"/>",
      [4] = "<img src=\"guimi_New\"/>",
      [5] = "<img src=\"Jiaren\"/>"
    }
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local intimacyData = LogicFriend.GetIntimacyData(data.uid)
    local iconIndex = 0
    if intimacyData and intimacyData.relation then
      iconIndex = intimacyData.relation
    else
      log(bWriteLog and "friend_applylist_item:OnRefresh: Failed to get icon data")
    end
    local text = LocUtil.LocalizeResFormat(73263, icons[iconIndex], data.relation)
    widget.UTRichTextBlock_0:SetText(text)
  elseif data.type == EnumApplyType.HomeJoint then
    widget.WidgetSwitcher_Type:SetActiveWidgetIndex(2)
    widget.Text_Type:SetText(LocUtil.LocalizeResFormat(655776))
    widget.Text_ApplyTime:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Intimacy:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local intimacy = LogicFriend.GetInnerFriendIntimacy(data.uid)
    widget.Text_Intimacy:SetText(tostring(intimacy))
    self:SetWidgetVisible(widget.Partner, false)
    widget.Text_Apply_Partner:SetText(LocUtil.GetLocalizeResStr(655777))
    self:SetWidgetVisible(widget.BtnNo, false, true)
    widget.TextBlock_258:SetText(LocUtil.LocalizeResFormat(102037))
  elseif data.type == EnumApplyType.HomeJointTerminate then
    widget.WidgetSwitcher_Type:SetActiveWidgetIndex(2)
    widget.Text_Type:SetText(LocUtil.LocalizeResFormat(655826))
    widget.Text_ApplyTime:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Intimacy:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local intimacy = LogicFriend.GetInnerFriendIntimacy(data.uid)
    widget.Text_Intimacy:SetText(tostring(intimacy))
    self:SetWidgetVisible(widget.Partner, false)
    widget.Text_Apply_Partner:SetText(LocUtil.GetLocalizeResStr(655827))
    self:SetWidgetVisible(widget.BtnNo, false, true)
    widget.TextBlock_258:SetText(LocUtil.LocalizeResFormat(102037))
  else
    widget.WidgetSwitcher_Type:SetActiveWidgetIndex(0)
    widget.Text_Type:SetText(LocUtil.LocalizeResFormat(34645))
    local TimeUtil = require("client.common.time_util")
    local str = TimeUtil.GetTimeAgoStr(data.createTime)
    widget.Text_ApplyTime:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Text_ApplyTime:SetText(str)
    widget.Text_Msg:SetText(data.applyMsg)
    widget.Intimacy:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Partner:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:SetWidgetVisible(widget.CanvasPanel_Labels, true)
    for i = 1, 13 do
      widget["Friend_Tag_Item_UIBP_" .. i]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if profile then
      local logic_recommend_labels = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_recommend_labels)
      local labels = logic_recommend_labels:GetLableConfigList(profile.all_show_labels)
      if labels and next(labels) then
        for i, lableConfig in pairs(labels) do
          if widget["Friend_Tag_Item_UIBP_" .. i] then
            widget["Friend_Tag_Item_UIBP_" .. i]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            widget["Friend_Tag_Item_UIBP_" .. i].TextBlock_Lable:SetText(lableConfig.LabelText)
          end
        end
      end
    end
    if not data.mutual_friends_cnt or 1 > data.mutual_friends_cnt then
      widget.Friend_Mutual_Item_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      widget.Friend_Mutual_Item_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      widget.Friend_Mutual_Item_UIBP.TextBlock_Lable:SetText(LocUtil.LocalizeResFormat(64734, data.mutual_friends_cnt))
    end
  end
  if self.UIRoot.TextBlock_Ignore then
    self.UIRoot.TextBlock_Ignore:SetText(LocUtil.GetLocalizeResStr(14125))
  end
  self:CheckSocialRestrict()
end
function friend_applylist_item:CheckSocialRestrict()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRestrict = QRcodeRestrictManager:IsRestrictSocial()
  self:SetWidgetVisible(self.UIRoot.Button_Restrict, isRestrict, true)
  self:SetWidgetVisible(self.UIRoot.Button_1, isRestrict, true)
end
function friend_applylist_item:OnClickedHead()
  self:PlayAudio(sound_config.click_v1)
  local data = self.data
  local Lobby_RoleInfo_Intimacy_List_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_RoleInfo_Intimacy_List_UIBP)
  if Lobby_RoleInfo_Intimacy_List_UIBP then
    Lobby_RoleInfo_Intimacy_List_UIBP:OnBeforeEnterPersonSpace()
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
    SocialPersonSpaceSystem.EnterPersonSpace(data.uid, true, RoleInfoMainSystem.RoleInfoOpenFromType.Lobby_RoleInfo_Intimacy_List_UIBP)
  else
    local msg = ""
    if data.type == EnumApplyType.Partner then
      local str = LocUtil.LocalizeResFormat(35059)
      msg = LocUtil.LocalizeResFormat(35060, str)
    elseif data.type == EnumApplyType.Relation then
      local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
      local IntimacyTypeStr = ""
      if data.param ~= 6 then
        IntimacyTypeStr = LocUtil.GetLocalizeResStr(IntimacyConst.C_InviteBeText[data.param])
      else
        IntimacyTypeStr = LocUtil.LocalizeResFormat(IntimacyConst.C_InviteBeText[data.param])
      end
      msg = IntimacyTypeStr
    else
      msg = data.applyMsg
    end
    if msg == "" then
      msg = " "
    end
    local ChatMenuSystem = require("client.slua.logic.lobby_chat.logic_chat_menu")
    local chatMacro = require("client.slua.logic.lobby_chat.chat_macro")
    UIManager.ShowUI(UIManager.UI_Config.ChatMenu_BP, {
      Uid = data.uid,
      IsShowReport = true,
      ChatContent = msg,
      ChatType = 0,
      CliSourceId = chatMacro.CliSourceId.friendApply
    }, ChatMenuSystem.EShowLocationType.FriendApply, false, true)
  end
end
function friend_applylist_item:OnClickedOK()
  self:PlayAudio(sound_config.click_v1)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local data = self.data
  if not data then
    return
  end
  local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
  if data.type == EnumApplyType.Partner then
    PersonSpaceSystem.agree_make_intimacy_partner_req(data.uid)
  elseif data.type == EnumApplyType.Relation then
    local relation = data.param
    if relation == IntimacyConst.EIntimacyType.Bonding then
      local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
      local relationResult = logic_friend_intimacy:GetRelationCanBuildResult(data.uid, relation)
      printf("friend_applylist_item:OnClickedOK relationResult:%s", relationResult)
      if relationResult ~= 0 then
        local str = ""
        if relationResult == 36 then
          str = LocUtil.LocalizeResFormat(82943)
        elseif relationResult == 32 then
          str = LocUtil.LocalizeResFormat(82944)
        elseif relationResult == 46 then
          str = LocUtil.LocalizeResFormat(82945)
        elseif relationResult == 42 then
          str = LocUtil.LocalizeResFormat(82946)
        end
        ShowNotice(str)
        return
      end
      local args = {
        casterUid = tonumber(data.uid),
        targetUid = tonumber(DataMgr.roleData.uid)
      }
      UIManager.ShowUI(UIManager.UI_Config.Intimacy_BondingBook_UIBP, IntimacyConst.EShowMode.Accept, args)
    else
      LogicFriend.reply_intimacy_relation_req(data.uid, data.param, 1)
    end
  elseif data.type == EnumApplyType.RelationChange then
    if data.relation == IntimacyConst.EIntimacyType.Bonding then
      local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
      local currentRelation = LogicFriend.GetRelation(data.uid)
      local relationResult = logic_friend_intimacy:GetRelationCanChangeResult(data.uid, currentRelation, data.relation)
      printf("friend_applylist_item:OnClickedOK relationResult:%s", relationResult)
      if relationResult ~= 0 then
        local str = ""
        if relationResult == 36 then
          str = LocUtil.LocalizeResFormat(82943)
        elseif relationResult == 32 then
          str = LocUtil.LocalizeResFormat(82944)
        elseif relationResult == 46 then
          str = LocUtil.LocalizeResFormat(82945)
        elseif relationResult == 42 then
          str = LocUtil.LocalizeResFormat(82946)
        end
        ShowNotice(str)
        return
      end
      local args = {
        casterUid = tonumber(data.uid),
        targetUid = tonumber(DataMgr.roleData.uid),
        changeData = data.changeData
      }
      UIManager.ShowUI(UIManager.UI_Config.Intimacy_BondingBook_UIBP, IntimacyConst.EShowMode.ChangeAccept, args)
    else
      LogicFriend.send_reply_change_intimacy_relation_req(data.uid, LogicFriend.RelationApplyOp.Agree, LogicFriend.RelationChangeType.RelationType, data.relation)
    end
  elseif data.type == EnumApplyType.RelationCustomNameChange then
    LogicFriend.send_reply_change_intimacy_relation_req(data.uid, LogicFriend.RelationApplyOp.Agree, LogicFriend.RelationChangeType.CustomName, data.relation)
  elseif data.type == EnumApplyType.HomeJoint then
    if not LobbySystem.CheckOpen(BP_ENUM_MODULE_PLANPH_HOME_COHABIT) then
      ShowNotice(511702)
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.Home_DoubleOccupancy_Popups_UIBP, data.uid, tonumber(DataMgr.roleData.uid), data.masterUid)
  elseif data.type == EnumApplyType.HomeJointTerminate then
    local LogicHomeJoint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
    LogicHomeJoint:ShowTerminateInfo()
  else
    local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
    logic_friend_apply:add_inner_friend_op_req(data.uid, 1)
  end
end
function friend_applylist_item:OnClickedNo()
  self:PlayAudio(sound_config.click_v1)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local data = self.data
  if not data then
    return
  end
  if data.type == EnumApplyType.Partner then
    PersonSpaceSystem.refuse_make_intimacy_partner_req(data.uid)
  elseif data.type == EnumApplyType.Relation then
    LogicFriend.reply_intimacy_relation_req(data.uid, data.param, 0)
  elseif data.type == EnumApplyType.RelationChange then
    LogicFriend.send_reply_change_intimacy_relation_req(data.uid, LogicFriend.RelationApplyOp.Refuse, LogicFriend.RelationChangeType.RelationType, data.relation)
  elseif data.type == EnumApplyType.RelationCustomNameChange then
    LogicFriend.send_reply_change_intimacy_relation_req(data.uid, LogicFriend.RelationApplyOp.Refuse, LogicFriend.RelationChangeType.CustomName, data.relation)
  elseif data.type == EnumApplyType.HomeJoint then
    local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
    PHomeJointHandler.send_manor_joint_reply_req(data.uid, false)
  elseif data.type == EnumApplyType.HomeJointTerminate then
    local LogicHomeJoint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
    LogicHomeJoint:send_manor_joint_terminate_reply_req(false)
  else
    local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
    logic_friend_apply:add_inner_friend_op_req(data.uid, 0)
  end
end
function friend_applylist_item:OnClickedShield()
  self:PlayAudio(sound_config.click_v1)
  local data = self.data
  local widget = self.UIRoot
  local ui = UIManager.ShowUI(UIManager.UI_Config.friend_item_menu, data)
  local UIUtil = require("client.common.ui_util")
  local Size = UIUtil.GetLocalSize(widget)
  local ViewportPosition = UIUtil.GetWidgetViewportPos(widget, Size.X * 0.5 - 16, Size.Y - 35)
  ui:SetTipsWithPos(ViewportPosition)
end
function friend_applylist_item:OnClickedRestirct()
  self:PlayAudio(sound_config.click_v1)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:ShowRestrictTips()
end
local class = require("class")
local scroll_box_child_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CUISubtabSuitItem = class(scroll_box_child_base, nil, friend_applylist_item)
return CUISubtabSuitItem