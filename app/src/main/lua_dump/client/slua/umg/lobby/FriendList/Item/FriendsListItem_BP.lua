require("client.slua.umg.lobby.FriendList.Item.FriendListItem_ClickFunc")
require("client.slua.umg.lobby.FriendList.Item.FriendListItem_RefreshFunc")
require("client.slua.umg.lobby.FriendList.Item.FriendListItem_RefreshAction")
require("client.slua.umg.lobby.FriendList.Item.FriendListItem_Profile")
require("client.slua.umg.lobby.FriendList.Item.FriendListItem_Comp")
local TimeUtil = require("client.common.time_util")
local FriendsListItem_BP = require("client.slua.umg.lobby.FriendList.Item.FriendListItem_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local logic_teammate_info = require("client.slua.umg.MainCity.Lobby_Friend.logic_teammate_info")
function FriendsListItem_BP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_ChatRoom, self.OnClickButton_ChatRoom, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Go, self.OnClickButton_Go, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_OfflineShare, self.OnClickButton_OfflineShare, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_TV, self.OnClickButton_TV, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Apply, self.OnClickButton_Apply, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Invite, self.OnClickButton_Invite, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Reserved, self.OnClickButton_Reservation, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Reservation_UGC, self.OnClickButton_Reservation_UGC, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Birthday, self.OnClickButton_Birthday, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Exit, self.OnClickButton_FreeInOut, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Search, self.OnClickButton_Detail, self)
  self:AddControlEventByControl(self.UIRoot.Common_Avatar_BP, "OnClickItemCallback", self.OnClickCommon_Avatar_BP, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_Delete, self.OnClickCheckBox_Delete, self)
  if self.UIRoot.UnknowPass_ContinuousBuy_BP.SetClickItemCallback then
    self.UIRoot.UnknowPass_ContinuousBuy_BP:SetClickItemCallback(self.OnClickUnknowPass, self)
  end
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GET_FRIEND_MANOR_INFO_RSP, self.OnGetFriendManorInfo, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_POKE_RSP, self.OnBackPoke, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_INTERACT_RSP, self.OnInteract, self)
end
function FriendsListItem_BP:OnRefresh(player)
  if not player or not player.uid then
    return
  end
  if not self.widgetPeakRankUI then
    local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
    local peakrankui = LogicPeakGameUtil.InitSmallPeakRankIntegralWidget(self, self.UIRoot.PeakGame_RankIntegralLevel_Style_Small_UIBP)
    self.widgetPeakRankUI = peakrankui
  end
  local index = self.index
  local ace_util = require("client.logic.season.ace.ace_util")
  ace_util.GetPlayerAllImprintInfo(player.uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(player.uid)
  if not profile then
    self:RequestProfile(player.uid, index)
    return
  end
  local customSwitches = self:GetPlayerCustomSwitches(profile)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  self:RefreshPokeAndInteract()
  local parentUI = self:GetLoopScrollBoxParentUI()
  self:SetWidgetVisible(self.UIRoot.Image_Bg, player.isTop and parentUI.IsTagUnGroup and parentUI:IsTagUnGroup())
  self:SetWidgetVisible(self.UIRoot.Image_Line, not player.isTop or not parentUI.IsTagUnGroup or not parentUI:IsTagUnGroup())
  local state = logic_friend_list_ui:GetState()
  if state == FLMacros.ENUM_STATE.FRIENDS_DELETE and tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    self:SetWidgetVisible(self.UIRoot.CheckBox_Delete, true, true)
    if logic_friend_list_ui:GetIsDelete(player.uid) then
      self.UIRoot.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Checked)
    else
      self.UIRoot.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
    end
  elseif state == FLMacros.ENUM_STATE.FRIENDS_TOP and tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    self:SetWidgetVisible(self.UIRoot.CheckBox_Delete, true, true)
    local checkState = logic_friend_list_ui:GetCheckState(player.uid)
    if not checkState then
      if player.isTop then
        self.UIRoot.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Checked)
      else
        self.UIRoot.CheckBox_Delete:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
      end
    else
      self.UIRoot.CheckBox_Delete:SetCheckedState(checkState)
    end
  else
    self:SetWidgetVisible(self.UIRoot.CheckBox_Delete, false)
  end
  local name = LogicFriend.GetRemark(player.uid)
  if self.UIRoot.Text_Name then
    self.UIRoot.Text_Name:SetText(name)
    self:AddTimer(0.1, function()
      if self.UIRoot and slua.isValid(self.UIRoot) then
        self.UIRoot:ForceLayoutPrepass()
        self.UIRoot.Text_Name:ForceLayoutPrepass()
      end
    end)
  end
  local bShowNickNameEffect = state ~= FLMacros.ENUM_STATE.FRIENDS_DELETE
  self:SetWidgetVisible(self.UIRoot.SizeBox_NicknameFrame, bShowNickNameEffect, true)
  local hasAlias = profile.alias and profile.alias.id and profile.alias.id > 0
  local showAlias = state ~= FLMacros.ENUM_STATE.FRIENDS_DELETE and hasAlias and customSwitches.alias
  if showAlias then
    self.UIRoot.Title_UIBP:SetAliasInfo(profile.alias.id or 0, profile.alias.title or "", profile.alias.nation or "", 0, profile.alias.rank_id or 0)
    self.UIRoot.title_box:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.title_box:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:SetWidgetVisible(self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP, true)
  self.UIRoot.WidgetSwitcher_Segment:SetActiveWidgetIndex(0)
  if logic_friend_list_ui:GetFrom() == FLMacros.ENUM_OPEN_FROM.TPLAN then
    log(bWriteLog and "teamup_side_bar:RefreshItemInternal RankIntegralLevel tplan")
    local military_level = profile.metro_summary and profile.metro_summary.military_level or 1
    self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteralInXMission(military_level)
  else
    local segment_show_type = profile.segment_show_type
    local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
    if segment_show_type == PeakGameConfig.EnumSegmentShowType.PeakGame then
      self.UIRoot.WidgetSwitcher_Segment:SetActiveWidgetIndex(1)
      local segment
      local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
      if tonumber(profile.uid) == tonumber(DataMgr.roleData.uid) then
        segment = LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxSegmentId()
      else
        segment = LogicPeakGameSegmentUtil.GetProfileCurMaxSegmentId(profile)
      end
      self.widgetPeakRankUI:SetPeakRankIntegral(segment or PeakGameConfig.DefaultPeakGameSegment)
    else
      log(bWriteLog and "teamup_side_bar:RefreshItemInternal RankIntegralLevel lobby")
      local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
      local segment, zoneId, modeId = logic_segment_title:GetMaxSegementLevelWithZoneAndModeId(profile.segment_info)
      local segmentTitleId = logic_segment_title:GetSegmentTitleId(profile.hsegment_title_det, zoneId, modeId)
      if not zoneId or not modeId then
        self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteral(segment or 101, nil)
      elseif not logic_segment_title:IsHighestSegment(segment) then
        self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteralWithSegmentTitle(segment, nil, nil, segmentTitleId)
      elseif not profile.rankdata then
        self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteralWithSegmentTitle(segment, nil, nil, segmentTitleId)
        local Lobby_InviteFriend_BP = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
        if Lobby_InviteFriend_BP then
          Lobby_InviteFriend_BP:RequestRankProfile(player.uid, index)
        end
      elseif not profile.rankdata[zoneId] or not profile.rankdata[zoneId][FLMacros.C_ModeMap[modeId]] then
        self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteralWithSegmentTitle(segment, nil, nil, segmentTitleId)
      else
        local rating = profile.rankdata[zoneId][FLMacros.C_ModeMap[modeId]].rank_rating
        self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteralWithSegmentTitle(segment, nil, nil, segmentTitleId, rating)
      end
    end
  end
  if customSwitches.nationFlag then
    local UIUtil = require("client.common.ui_util")
    UIUtil.UpdateNationImage(self.UIRoot.Image_flag, profile.nation)
  else
    self:SetWidgetVisible(self.UIRoot.Image_flag, false)
  end
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.LightBoard, profile and profile.light_board_info and next(profile.light_board_info), table.pack(player.uid, self.UIRoot.CanvasPanel_Family))
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if (profile.birthday_privacy_value == 1 or profile.birthday_privacy_value == 2 and LogicFriend.IsMyFriend(player.uid)) and profile.is_birthday then
      self.UIRoot.Button_Birthday:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      self:SetCompChild(self.ENUM_COMPONENT_TYPE.Birth, true)
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_Loop, 0, 0, 0, 1)
    else
      self.UIRoot.Button_Birthday:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:SetCompChild(self.ENUM_COMPONENT_TYPE.Birth, false)
    end
  elseif profile.is_birthday then
    self.UIRoot.Button_Birthday:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:SetCompChild(self.ENUM_COMPONENT_TYPE.Birth, true)
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Loop, 0, 0, 0, 1)
  else
    self.UIRoot.Button_Birthday:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SetCompChild(self.ENUM_COMPONENT_TYPE.Birth, false)
  end
  local relation = LogicFriend.GetRelation(player.uid)
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.SourceFrom, tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG and player.from and player.from ~= 0, FLMacros.LocMap[player.from or 0])
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.Recaller, logic_longline_task.IsRecaller(player.uid) == 1)
  local bIsStatusShow = false
  local picPath = ""
  local TimeUtil = require("client.common.time_util")
  if profile.frd_status_id and 0 < profile.frd_status_id and TimeUtil.GetServerTimeInSec() <= profile.frd_status_end_time and tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    local cfg = CDataTable.GetTableData("FriendStatusCfg", profile.frd_status_id)
    if cfg and cfg.type ~= 7 then
      bIsStatusShow = true
      if profile.frd_status_id == 13 and profile.frd_icon_idx ~= 0 then
        picPath = "/Game/UMG/Texture/Atlas/ChatEmojiUI/Frames/emoji_1_50_" .. tostring(profile.frd_icon_idx) .. "_png.emoji_1_50_" .. tostring(profile.frd_icon_idx) .. "_png"
      else
        picPath = cfg.icon_url
      end
    else
      bIsStatusShow = false
    end
  else
    bIsStatusShow = false
  end
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.Status, bIsStatusShow, picPath)
  local logic_luckystar = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_luckystar)
  local isLuckyStarMark = logic_luckystar:IsLuckyStarValid() and logic_luckystar:IsLuckyTeammate(player.uid) and not logic_luckystar:IsTeammateTriggered(player.uid)
  local logic_friend_gang_up = require("client.slua.logic.friend.logic_friend_gang_up")
  local max_last_week_level = logic_friend_gang_up.GetMaxLastWeekLevel(player.uid)
  local showOpenBlack = 0 < max_last_week_level and LogicFriend.IsMyFriend(player.uid)
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.Relation2, showOpenBlack, max_last_week_level)
  local hasCertification = logic_teammate_info.CheckAuthInfoOpen(profile.auth_type, profile.auth_end_time)
  local showCertification = hasCertification and customSwitches.certification
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.Certification, showCertification, table.pack(profile.auth_type, profile.auth_end_time))
  local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
  local bIsRejoin = logic_oldfriend_care.IsRejoinPlayer(profile)
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local type = return_activity_macro.Enum_Tag_ShowType.Other
  local showLucky = false
  local showReturnPlayer = false
  local showRelation = false
  if isLuckyStarMark then
    showLucky = true
  elseif bIsRejoin and not showOpenBlack then
    showReturnPlayer = true
  elseif 0 < relation then
    showRelation = true
  end
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.Lucky, showLucky)
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.ReturnPlayer, showReturnPlayer, {
    uid = player.uid,
    type = type,
    dir = 2
  })
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.Relation, showRelation, relation)
  self:SetNicknameFrame(self.UIRoot, player.uid, profile.friend_nickname_skin)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(player.uid)
  if tabID == FLMacros.ENUM_TAB.ENUM_CORPS_TAG then
    local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
    status = CorpsMemberSystem.GetOnlineStatus(player.uid)
  end
  local isOnline = status and status.online == 1
  self:RefreshCollectBadge(player.uid, profile.collect_data)
  self.UIRoot.Common_Avatar_BP:InitView(1, player.uid, profile.picUrl, 0, profile.cur_avatar_box_id, 0, false, "", isOnline)
  local hasGender = profile.social_card and profile.social_card.new_sex and 0 < profile.social_card.new_sex
  local showGender = hasGender and customSwitches.gender
  if showGender then
    self:SetWidgetVisible(self.UIRoot.SizeBox_Gender, true)
    self.UIRoot.Common_Gender_UIBP:LoadIcon(profile.uid)
  else
    self:SetWidgetVisible(self.UIRoot.SizeBox_Gender, false)
  end
  local UPassIsBuy, UPassIsShow, UPassKeepBuy, UPassValue, pass_type = LogicFriend.ParsePassInfo(profile.upass)
  local hasPass = UPassIsShow
  local showPass = hasPass and customSwitches.pass
  if showPass and slua.isValid(self.UIRoot.UnknowPass_ContinuousBuy_BP) then
    self:SetWidgetVisible(self.UIRoot.SizeBox_BP, true)
    self.UIRoot.UnknowPass_ContinuousBuy_BP:SetTypeData(0, UPassKeepBuy, UPassIsBuy, status and status.online or 0, UPassValue, pass_type or 0)
  else
    self:SetWidgetVisible(self.UIRoot.SizeBox_BP, false)
  end
  local hasWowPass = Util_UGC.WoWPassActive(profile)
  local showWowPass = hasWowPass and customSwitches.wowPass
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.WowPass, showWowPass, profile)
  if not status then
    return
  end
  if tabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
    self.UIRoot.WidgetSwitcher_Segment:SetActiveWidgetIndex(2)
    self:SetWidgetVisible(self.UIRoot.Image_flag, false)
    self.UIRoot.title_box:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:SetWidgetVisible(self.UIRoot.Image_Bg, false)
  end
  self:SetWidgetVisible(self.UIRoot.Button_Search, false)
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Action, false)
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Reserve, false)
  self:RefreshTeamOnlineStatus(self.UIRoot, player, status)
  self:RefreshActionButtons(self.UIRoot, index, player.uid, status)
  self:RefreshFriendGroupLabel(self.UIRoot, index)
  self:RefreshWOWFriend(self.UIRoot, player, profile)
  local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
  if logic_promotion_homepage:IsShowPromotionStatus(profile.uid) then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, true)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, false)
  end
end
function FriendsListItem_BP:RefreshPokeAndInteract()
  local player = self.data
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
    local texturePath, _, interactionScore = logic_interaction:GetIconInfoByID(player.uid)
    self:SetCompChild(self.ENUM_COMPONENT_TYPE.InterAction, texturePath and interactionScore and 0 < interactionScore, {picPath = texturePath, interactionScore = interactionScore})
    local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
    local pokeUIData = {
      uid = player.uid,
      pokeType = logic_poke:FriendPokeStatus(player.uid)
    }
    local isShowPoke = logic_poke:PokeChatBox(player.uid)
    if isShowPoke then
      if not pokeUIData.pokeType or pokeUIData.pokeType == logic_poke.PokeType.None then
        self:SetCompChild(self.ENUM_COMPONENT_TYPE.Poke, false)
      else
        self:SetCompChild(self.ENUM_COMPONENT_TYPE.Poke, true, pokeUIData)
      end
    else
      self:SetCompChild(self.ENUM_COMPONENT_TYPE.Poke, false)
    end
  else
    self:SetCompChild(self.ENUM_COMPONENT_TYPE.Poke, false)
    self:SetCompChild(self.ENUM_COMPONENT_TYPE.InterAction, false)
  end
end
function FriendsListItem_BP:OnBackPoke(eventType, eventID, uid)
  if not self.data or not self.data.uid then
    return
  end
  if uid ~= self.data.uid then
    return
  end
  log(bWriteLog and "FriendsListReuseFall_Item:OnBackPoke uid" .. tostring(uid))
  self:RefreshPokeAndInteract()
  local parentUI = self:GetLoopScrollBoxParentUI()
  if parentUI and parentUI.ReuseFall then
    parentUI.ReuseFall:RefreshAllItems()
  end
end
function FriendsListItem_BP:OnInteract(eventType, eventID, uid)
  if not self.data or not self.data.uid then
    return
  end
  if uid ~= self.data.uid then
    return
  end
  self:RefreshPokeAndInteract()
end
function FriendsListItem_BP:RefreshCollectBadge(uid, collect_data)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    self:SetCompChild(self.ENUM_COMPONENT_TYPE.CollectBadge, true, table.pack(uid, collect_data, true))
    return
  end
  local customSwitches = self:GetPlayerCustomSwitches(profile)
  local showBadge = customSwitches.collectLevel
  self:SetCompChild(self.ENUM_COMPONENT_TYPE.CollectBadge, showBadge, table.pack(uid, collect_data, true))
end
function FriendsListItem_BP:Close()
  self.widgetPeakRankUI = nil
  self.effectUI = nil
  FriendsListItem_BP.__super.Close(self)
end
function FriendsListItem_BP:GetPlayerCustomSwitches(profile)
  local logic_friendlist_custom_utils = require("client.slua.logic.friend.logic_friendlist_custom_utils")
  if not profile then
    log(bWriteLog and "FriendsListItem_BP:GetPlayerCustomSwitches profile is nil, use all on")
    return {
      collectLevel = true,
      alias = true,
      pass = true,
      wowPass = true,
      gender = true,
      nationFlag = true,
      certification = true
    }
  end
  local switchValue = profile.friend_list_bits_switch
  if switchValue == nil then
    log(bWriteLog and string.format("FriendsListItem_BP:GetPlayerCustomSwitches uid=%s, switchValue is nil, use calculated default", tostring(profile.uid)))
    switchValue = logic_friendlist_custom_utils.CalculateDefaultSwitch(profile)
  end
  local SWITCH_MASK = logic_friendlist_custom_utils.SWITCH_MASK
  local switches = {
    collectLevel = logic_friendlist_custom_utils.GetSwitch(switchValue, SWITCH_MASK.CollectLevel),
    alias = logic_friendlist_custom_utils.GetSwitch(switchValue, SWITCH_MASK.Alias),
    pass = logic_friendlist_custom_utils.GetSwitch(switchValue, SWITCH_MASK.Pass),
    wowPass = logic_friendlist_custom_utils.GetSwitch(switchValue, SWITCH_MASK.WowPass),
    gender = logic_friendlist_custom_utils.GetSwitch(switchValue, SWITCH_MASK.Gender),
    nationFlag = logic_friendlist_custom_utils.GetSwitch(switchValue, SWITCH_MASK.NationFlag),
    certification = logic_friendlist_custom_utils.GetSwitch(switchValue, SWITCH_MASK.Certification)
  }
  log(bWriteLog and string.format("FriendsListItem_BP:GetPlayerCustomSwitches uid=%s, switchValue=%d (0x%X), collectLevel=%s, alias=%s, pass=%s, wowPass=%s, gender=%s, nationFlag=%s, certification=%s", tostring(profile.uid), switchValue, switchValue, tostring(switches.collectLevel), tostring(switches.alias), tostring(switches.pass), tostring(switches.wowPass), tostring(switches.gender), tostring(switches.nationFlag), tostring(switches.certification)))
  return switches
end
local class = require("class")
local scroll_box_child_base = require("client.slua_ui_framework.component.scroll_box_child_base")
return class(scroll_box_child_base, nil, FriendsListItem_BP)