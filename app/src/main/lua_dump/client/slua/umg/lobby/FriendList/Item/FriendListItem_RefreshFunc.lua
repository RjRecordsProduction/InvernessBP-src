local FriendsListItem_BP = require("client.slua.umg.lobby.FriendList.Item.FriendListItem_Data")
local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
function FriendsListItem_BP:SetNicknameFrame(widget, uid, nicknameFrameID)
  local clearFunc = function()
    if self.effectUI then
      self.effectUI:Close()
      self.effectUI = nil
    end
  end
  clearFunc()
  self[widget] = {uid = uid}
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
  local nicknameFrameBPPath = logic_roleInfo_nicknameframe:GetBPPath(nicknameFrameID)
  if not nicknameFrameBPPath then
    return
  end
  local uiConfig = UIManager.UI_Config.Lobby_RoleInfo_EffectSkin_Item_UIBP
  local extraData = {
    bPlayOnce = true,
    finishAniCallback = function()
      clearFunc()
    end
  }
  self.effectUI = self:CreateChildWindowWithBpPath(widget.SizeBox_NicknameFrame, uiConfig, nicknameFrameBPPath, "Anim_In", extraData)
end
local SetStatus = function(widget, text, color)
  if not (widget and slua.isValid(widget)) or not widget.Text_GameState then
    return
  end
  widget.Text_GameState:SetText(text)
  widget.Text_GameState:SetColorAndOpacity(color)
  widget.WidgetSwitcher_State:SetActiveWidgetIndex(0)
end
local SetHomeStatus = function(self, widget, uid, party_info, bIsWedding)
  if not (self and self.UIRoot) or not slua.isValid(self.UIRoot) then
    log(bWriteLog and "teamup_side_bar, SetHomeStatus, not self or self.UIRoot invalid")
    return
  end
  if not widget or not slua.isValid(widget) then
    log(bWriteLog and "teamup_side_bar, SetHomeStatus, widget invalid")
    return
  end
  local HomePartyUtil = require("client.slua.logic.homeparty.HomePartyUtil")
  local HomePartyConst = require("client.slua.logic.homeparty.HomePartyConst")
  widget.WidgetSwitcher_State:SetActiveWidgetIndex(2)
  if not bIsWedding and party_info and next(party_info) and party_info.start_time and (HomePartyUtil.GetPartyState(party_info) == HomePartyConst.PartyState.In_Party or party_info.mmbr_latest_party and party_info.mmbr_latest_party[tonumber(uid)] and HomePartyUtil.GetPartyState(party_info.mmbr_latest_party[tonumber(uid)]) == HomePartyConst.PartyState.In_Party) then
    local TimeUtil = require("client.common.time_util")
    local HomePartyUtil = require("client.slua.logic.homeparty.HomePartyUtil")
    self:SetWidgetVisible(widget.Common_Home_Visit_State_UIBP, false)
    self:SetWidgetVisible(widget.TextBlock_VisitNum, false)
    local currentTime = TimeUtil.GetServerTimeInSec()
    local timeFromPartyStart = TimeUtil.FormatCountDownTime_MS(currentTime - party_info.start_time)
    widget.TextBlock_HomeStatus:SetText(LocUtil.LocalizeResFormat(69181, timeFromPartyStart))
    local icon = HomePartyUtil.GetPartyIconTexture(party_info)
    self:SetTexture(widget.Image_HomeIcon, icon)
  elseif bIsWedding then
    local TimeUtil = require("client.common.time_util")
    local HomeWeddingUtil = require("client.slua.logic.homewedding.HomeWeddingUtil")
    self:SetWidgetVisible(widget.Common_Home_Visit_State_UIBP, false)
    self:SetWidgetVisible(widget.TextBlock_VisitNum, false)
    local currentTime = TimeUtil.GetServerTimeInSec()
    local timeFromPartyStart = TimeUtil.FormatCountDownTime_MS(party_info.end_time - currentTime)
    widget.TextBlock_HomeStatus:SetText(LocUtil.LocalizeResFormat(8075891, timeFromPartyStart))
    local icon = HomeWeddingUtil.GetWeddingIconTexture()
    self:SetTexture(widget.Image_HomeIcon, icon)
  else
    self:SetWidgetVisible(widget.Common_Home_Visit_State_UIBP, true)
    self:SetWidgetVisible(widget.TextBlock_VisitNum, true)
    self:UpdateHomeVisitor(widget, uid)
    local home_item_utils = require("client.slua.logic.home.home_item_utils")
    home_item_utils.SetHomeHouseIcon(widget.Image_HomeIcon, uid)
  end
end
function FriendsListItem_BP:RefreshTeamOnlineStatus(widget, player, status)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if widget and widget.Text_GameState then
    widget.Text_GameState:SetText("")
  end
  if not status then
    return
  end
  local logic_home_status = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_status)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  local logic_friend_list_utils = require("client.slua.logic.friend.refactor.logic_friend_list_utils")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local StringUtil = require("common.string_util")
  if status and status.online == 0 then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local lastOnlineTime = logic_profile:GetLastOnlineTime(player.uid)
    if lastOnlineTime then
      local TimeUtil = require("client.common.time_util")
      local lastOnlineTimeStr = TimeUtil.GetLastOnlineTimeStr(lastOnlineTime)
      log(bWriteLog and bWriteLog and "FriendsListItem_BP:RefreshTeamOnlineStatus lastOnlineTime " .. tostring(lastOnlineTime) .. " lastOnlineTimeStr = " .. lastOnlineTimeStr)
      SetStatus(widget, lastOnlineTimeStr, FLMacros.C_Colors.STATE_WHITE)
    else
      SetStatus(widget, LocUtil.GetLocalizeResStr(1212), FLMacros.C_Colors.STATE_WHITE)
    end
    if widget.Border_ItemStatus then
      widget.Border_ItemStatus:SetContentColorAndOpacity(FLMacros.C_Colors.OFFLINE)
    end
    if widget.Border_Action then
      widget.Border_Action:SetContentColorAndOpacity(FLMacros.C_Colors.OFFLINE)
    end
  else
    if widget.Border_ItemStatus then
      widget.Border_ItemStatus:SetContentColorAndOpacity(FLMacros.C_Colors.ONLINE)
    end
    if widget.Border_Action then
      widget.Border_Action:SetContentColorAndOpacity(FLMacros.C_Colors.ONLINE)
    end
    if PlayerStatusUtil.IsIdle(status) then
      local is_video_inspect = status and status.is_video_inspect or PlayerStatusMgr:GetIsVideoInspect(player.uid)
      if status and status.tplan_type ~= 0 then
        SetStatus(widget, LocUtil.GetLocalizeResStr(35189), FLMacros.C_Colors.STATE_BLUE)
      elseif is_video_inspect then
        SetStatus(widget, LocUtil.GetLocalizeResStr(25260), FLMacros.C_Colors.STATE_ORANGE)
      elseif status and status.channel_id and 0 < status.channel_id then
        widget.TextBlock_ChatRoom:SetText(LocUtil.GetLocalizeResStr(62375))
        widget.TextBlock_ChatRoom:SetColorAndOpacity(FLMacros.C_Colors.STATE_GREEN)
        widget.WidgetSwitcher_State:SetActiveWidgetIndex(3)
      elseif status.mod_id and 0 < status.mod_id then
        SetStatus(widget, LocUtil.GetLocalizeResStr(4020), FLMacros.C_Colors.STATE_GREEN)
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        PlayerStatusMgr:GetModInfoById(status.mod_id, function(modInfo)
          if not (widget and slua.isValid(widget) and self and self.UIRoot) or not slua.isValid(self.UIRoot) then
            return
          end
          if modInfo.mod_id ~= status.mod_id then
            return
          end
          if PlayerStatusUtil.InHall(status) then
            SetStatus(widget, LocUtil.LocalizeResFormat(78322, FriendsListItem_BP.ClipString(modInfo.setting.name)), FLMacros.C_Colors.STATE_BLUE)
            widget.Button_Search:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
            widget.WidgetSwitcher_Action:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
            widget.WidgetSwitcher_Action:SetActiveWidgetIndex(1)
          else
            SetStatus(widget, LocUtil.LocalizeResFormat(78320, FriendsListItem_BP.ClipString(modInfo.setting.name)), FLMacros.C_Colors.STATE_BLUE)
            widget.Button_Search:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
          end
        end)
      else
        SetStatus(widget, LocUtil.GetLocalizeResStr(4020), FLMacros.C_Colors.STATE_GREEN)
        local logic_community = require("client.slua.logic.community.logic_community")
        if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG and logic_community.CheckShowInTeamUpSideBar(player.uid) == true then
          local text = logic_community.GetShowTextInClub(player.uid)
          widget.Text_ClubGameState:SetText(text)
          widget.Text_ClubGameState:SetColorAndOpacity(FLMacros.C_Colors.STATE_GREEN)
          widget.WidgetSwitcher_State:SetActiveWidgetIndex(1)
          local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
          local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
          local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
          if MatchModeMgrSystem.IsSocialIslandMode() or UIManager.IsUIShow(UIManager.UI_Config.ui_room_waiting) or LogicTxMissionMain.IsInXMission() or PlanPH_GamePlay_Tools.IsPHomeMode() then
            log(bWriteLog and "FriendsListItem_BP:RefreshTeamOnlineStatus ignore click")
            widget.Button_Go:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
          else
            widget.Button_Go:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
          end
        end
      end
    elseif logic_home_status:IsHomeVisitMode(status.game_sub_mode) then
      if self:CheckCanNotShowHomeStatus(widget) then
        return
      end
      local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
      logic_home_profile:GetOrReqHomeProfile({
        player.uid
      }, function()
        if not (widget and slua.isValid(widget) and self and self.UIRoot) or not slua.isValid(self.UIRoot) then
          return
        end
        local profile = logic_home_profile:GetHomeProfileByUid(player.uid)
        if not profile then
          log_warning("teamup_side_bar:RefreshTeamOnlineStatus, logic_home_profile:GetOrReqHomeProfile failed. player.uid = " .. tostring(player.uid))
          SetHomeStatus(self, widget, player.uid, nil)
          return
        end
        local info = profile.party_info and next(profile.party_info) and profile.party_info or profile.join_soulmate_ceremony
        local bIsWedding = false
        local HomeWeddingUtil = require("client.slua.logic.homewedding.HomeWeddingUtil")
        local bIsBondingSystem = HomeWeddingUtil.IsShowWeddingEntry()
        if bIsBondingSystem and profile.join_soulmate_ceremony and next(profile.join_soulmate_ceremony) then
          local uid, ceremonyInfo = next(profile.join_soulmate_ceremony)
          local TimeUtil = require("client.common.time_util")
          local now = TimeUtil.GetServerTimeInSec()
          bIsWedding = tonumber(uid) == profile.uid and now <= ceremonyInfo.end_time
          log(bWriteLog and "FriendListItem_RefreshFunc:RefreshTeamOnlineStatus - bIsWedding = " .. tostring(bIsWedding))
          SetHomeStatus(self, widget, player.uid, ceremonyInfo, bIsWedding)
        else
          SetHomeStatus(self, widget, player.uid, info, false)
        end
      end)
    elseif PlayerStatusUtil.ISLANDIdle(status) then
      if status.socialland_type == 1 then
        SetStatus(widget, LocUtil.GetLocalizeResStr(9561), FLMacros.C_Colors.STATE_BLUE)
      else
        SetStatus(widget, LocUtil.GetLocalizeResStr(9563), FLMacros.C_Colors.STATE_BLUE)
      end
    elseif PlayerStatusUtil.IsMainCity(status) then
      if PlayerStatusUtil.IsMainCityTeam(status) then
        SetStatus(widget, LocUtil.LocalizeResFormat(655643, status.currentTeamAmount, status.maxTeamAmount), FLMacros.C_Colors.STATE_ORANGE)
      elseif PlayerStatusUtil.IsMainCityIdle(status) then
        SetStatus(widget, LocUtil.GetLocalizeResStr(655642), FLMacros.C_Colors.STATE_BLUE)
      end
      self:SetWidgetVisible(widget.Button_TV, false, true)
    elseif PlayerStatusUtil.IsInCollectionHall(status) then
      SetStatus(widget, LocUtil.GetLocalizeResStr(880060095), FLMacros.C_Colors.STATE_BLUE)
      self:SetWidgetVisible(widget.Button_TV, false, true)
    elseif PlayerStatusUtil.IsTeam(status) and not PlayerStatusUtil.TPlanInTeam(status) then
      SetStatus(widget, string.format("%s %s/%s", LocUtil.GetLocalizeResStr(1213), status.currentTeamAmount, status.maxTeamAmount), FLMacros.C_Colors.STATE_ORANGE)
    elseif PlayerStatusUtil.ISLANDInTeam(status) then
      if status.socialland_type == 1 then
        SetStatus(widget, LocUtil.LocalizeResFormat(9562, status.currentTeamAmount), FLMacros.C_Colors.STATE_ORANGE)
      else
        SetStatus(widget, LocUtil.LocalizeResFormat(9564, status.currentTeamAmount), FLMacros.C_Colors.STATE_ORANGE)
      end
    elseif PlayerStatusUtil.IsBattle(status) then
      local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
      log(bWriteLog and bWriteLog and "teamup_side_bar:RefreshTeamOnlineStatus game_sub_mode:" .. tostring(status and status.game_sub_mode))
      local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
      local IsCanWatch = PlayerStatusUtil.IsCanWatch(status)
      log(bWriteLog and "teamup_side_bar:RefreshTeamOnlineStatus IsCanWatch:" .. tostring(IsCanWatch))
      widget.WidgetSwitcher_Action:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      widget.WidgetSwitcher_Action:SetActiveWidgetIndex(2)
      local isUGCMode = LogicUGCMatch:IsUGCMode(status.game_sub_mode)
      local bCanWatchUGCMode = LogicUGCMatch:IsCanWatchUGCMode(status.game_sub_mode)
      local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      if not (not isUGCMode or bCanWatchUGCMode) or LogicPeakGame:IsPeakMode(status.game_sub_mode) or PlayerStatusUtil.InWoW(status) or not IsCanWatch then
        log(bWriteLog and "teamup_side_bar:RefreshTeamOnlineStatus IsUGCMode true")
        self:SetWidgetVisible(widget.WidgetSwitcher_Action, false, true)
      end
      if status.mod_id and 0 < status.mod_id then
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        PlayerStatusMgr:GetModInfoById(status.mod_id, function(modInfo)
          if not (widget and slua.isValid(widget) and self and self.UIRoot) or not slua.isValid(self.UIRoot) then
            return
          end
          if modInfo.mod_id ~= status.mod_id then
            return
          end
          widget.Button_Search:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
          self:SetWidgetVisible(widget.WidgetSwitcher_Action, true, true)
          self:SetWidgetVisible(widget.Button_TV, bCanWatchUGCMode, true)
          self:UpdateReservationButton(widget)
        end)
      end
      if status.game_sub_mode == 10080 then
        SetStatus(widget, LocUtil.GetLocalizeResStr(100042), FLMacros.C_Colors.STATE_ORANGE)
      elseif PlayerStatusUtil.WoWIdle(status) then
        SetStatus(widget, LocUtil.GetLocalizeResStr(77105), FLMacros.C_Colors.STATE_BLUE)
      elseif PlayerStatusUtil.WoWInTeam(status) then
        SetStatus(widget, LocUtil.LocalizeResFormat(77106, status.currentTeamAmount, status.maxTeamAmount or 4), FLMacros.C_Colors.STATE_ORANGE)
      else
        SetStatus(widget, LocUtil.GetLocalizeResStr(9911106), FLMacros.C_Colors.STATE_ORANGE)
        if status.gameBeginTime then
          do
            local TimeUtil = require("client.common.time_util")
            local text = TimeUtil.GetOpenedTimeStr(TimeUtil.GetServerTimeInSec() - status.gameBeginTime)
            local ModeName = DataMgr.GetModeName(status.game_sub_mode)
            if isUGCMode then
              if status.game_sub_mode ~= UGCMacros.EDIT_SUB_MODE and status.mod_id and 0 < status.mod_id then
                ModeName = LocUtil.LocalizeResFormat(64141, status.mod_id or "")
              elseif status.game_sub_mode == UGCMacros.EDIT_SUB_MODE then
                ModeName = LocUtil.GetLocalizeResStr(62896)
              end
            end
            local str = LocUtil.LocalizeResFormat(13121, ModeName, text, status.currentTeamAmount, status.maxTeamAmount)
            status.currentTeamAmount = math.min(status.currentTeamAmount, status.maxTeamAmount)
            SetStatus(widget, string.format("%s", str), FLMacros.C_Colors.STATE_ORANGE)
            if isUGCMode and status.game_sub_mode ~= UGCMacros.EDIT_SUB_MODE and status.mod_id then
              PlayerStatusMgr:GetModInfoById(status.mod_id, function(modInfo)
                if not (widget and slua.isValid(widget) and self and self.UIRoot) or not slua.isValid(self.UIRoot) then
                  return
                end
                if modInfo.mod_id ~= status.mod_id then
                  return
                end
                local str = LocUtil.LocalizeResFormat(13121, FriendsListItem_BP.ClipString(modInfo.setting.name), text, status.currentTeamAmount, status.maxTeamAmount)
                SetStatus(widget, string.format("%s", str), FLMacros.C_Colors.STATE_ORANGE)
              end)
            end
          end
        end
      end
    elseif PlayerStatusUtil.IsTeam(status) and PlayerStatusUtil.TPlanInTeam(status) then
      SetStatus(widget, LocUtil.LocalizeResFormat(35190, status.currentTeamAmount), FLMacros.C_Colors.STATE_ORANGE)
    elseif PlayerStatusUtil.IsRoom(status) then
      SetStatus(widget, LocUtil.GetLocalizeResStr(4019), FLMacros.C_Colors.STATE_ORANGE)
      if status.mod_id and 0 < status.mod_id then
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        PlayerStatusMgr:GetModInfoById(status.mod_id, function(modInfo)
          if not (widget and slua.isValid(widget) and self and self.UIRoot) or not slua.isValid(self.UIRoot) then
            return
          end
          PlayerStatusMgr:QueryFriendRoom(player.uid, function(roomId)
            if not (widget and slua.isValid(widget) and self and self.UIRoot) or not slua.isValid(self.UIRoot) then
              return
            end
            PlayerStatusMgr:GetRoomInfo(roomId, function(roomInfo)
              if not (widget and slua.isValid(widget) and self and self.UIRoot) or not slua.isValid(self.UIRoot) then
                return
              end
              if modInfo.mod_id ~= status.mod_id then
                return
              end
              SetStatus(widget, LocUtil.LocalizeResFormat(78321, FriendsListItem_BP.ClipString(modInfo.setting.name), roomInfo.player_count, roomInfo.max_room_player), FLMacros.C_Colors.STATE_ORANGE)
              widget.Button_Search:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
              widget.WidgetSwitcher_Action:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
              widget.WidgetSwitcher_Action:SetActiveWidgetIndex(1)
            end)
          end)
        end)
      end
    elseif PlayerStatusUtil.IsWatch(status) then
      if status.is_hawkeye then
        SetStatus(widget, LocUtil.GetLocalizeResStr(36660), FLMacros.C_Colors.STATE_ORANGE)
      else
        SetStatus(widget, LocUtil.GetLocalizeResStr(6880), FLMacros.C_Colors.STATE_ORANGE)
      end
    elseif PlayerStatusUtil.IsFree(status) then
      if status and status.tplan_type ~= 0 then
        SetStatus(widget, LocUtil.GetLocalizeResStr(35189), FLMacros.C_Colors.STATE_BLUE)
      elseif status.mod_id and 0 < status.mod_id then
        self:SetStatusWithWOW(PlayerStatusMgr, widget, status, LocUtil.GetLocalizeResStr(77775))
      else
        SetStatus(widget, LocUtil.GetLocalizeResStr(77775), FLMacros.C_Colors.STATE_GREEN)
      end
    elseif PlayerStatusUtil.IsBusy(status) then
      if status and status.tplan_type ~= 0 then
        SetStatus(widget, LocUtil.GetLocalizeResStr(35189), FLMacros.C_Colors.STATE_BLUE)
      elseif status.mod_id and 0 < status.mod_id then
        self:SetStatusWithWOW(PlayerStatusMgr, widget, status, LocUtil.GetLocalizeResStr(77776))
      else
        SetStatus(widget, LocUtil.GetLocalizeResStr(77776), FLMacros.C_Colors.STATE_RED)
      end
    elseif PlayerStatusUtil.IsDoNotBother(status) then
      if status and status.tplan_type ~= 0 then
        SetStatus(widget, LocUtil.GetLocalizeResStr(35189), FLMacros.C_Colors.STATE_BLUE)
      elseif status.mod_id and 0 < status.mod_id then
        self:SetStatusWithWOW(PlayerStatusMgr, widget, status, LocUtil.GetLocalizeResStr(773310))
      else
        SetStatus(widget, LocUtil.GetLocalizeResStr(773310), FLMacros.C_Colors.STATE_RED)
      end
    elseif PlayerStatusUtil.IsStealth(status) then
      SetStatus(widget, LocUtil.GetLocalizeResStr(77777), FLMacros.C_Colors.STATE_ORANGE)
    end
  end
  if GameStatus.IsCollectionHallMode() then
    if widget.WidgetSwitcher_Action:GetActiveWidgetIndex() == 0 then
      self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
    end
    self:SetWidgetVisible(widget.Button_TV, false, true)
  end
end
function FriendsListItem_BP.ClipString(str)
  local StringUtil = require("common.string_util")
  local maxLength = 14
  local len = StringUtil.GetCharactersLength(str, 2)
  if maxLength < len then
    return LocUtil.LocalizeResFormat(8600314, StringUtil.ClipString(str, maxLength, 2))
  else
    return str
  end
end
function FriendsListItem_BP:UpdateReservationButton(widget)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.IsWidgetVisible(widget.WidgetSwitcher_Reserve) and UIUtil.IsWidgetVisible(widget.WidgetSwitcher_Action) then
    widget.WidgetSwitcher_Reserve:SetActiveWidgetIndex(1)
    self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
  else
    widget.WidgetSwitcher_Reserve:SetActiveWidgetIndex(0)
  end
end
function FriendsListItem_BP:RefreshFriendGroupLabel(widget, index)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local bShowReuseFall = logic_friend_list_ui:GetShowReuseFall()
  if not bShowReuseFall then
    self:SetWidgetVisible(widget.AutoScrollBox_Tips, true)
    self:SetWidgetVisible(widget.UTRichTextBlock_Tag1, false)
    self:SetWidgetVisible(widget.Image_TagLine, false)
    self:SetWidgetVisible(widget.UTRichTextBlock_Tag2, false)
  else
    local playerData = self.data
    local groupID = playerData.reuseFallGroupID
    local logic_friend_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_group)
    local label1, label2 = logic_friend_group:GetFriendLabel(playerData, groupID)
    local hasLabelOne = label1 and label1 ~= ""
    local hasLabelTwo = label2 and label2 ~= ""
    self:SetWidgetVisible(widget.AutoScrollBox_Tips, hasLabelOne or hasLabelTwo)
    self:SetWidgetVisible(widget.UTRichTextBlock_Tag1, hasLabelOne)
    if hasLabelOne then
      widget.UTRichTextBlock_Tag1:SetText(label1)
    end
    self:SetWidgetVisible(widget.Image_TagLine, hasLabelTwo)
    self:SetWidgetVisible(widget.UTRichTextBlock_Tag2, hasLabelTwo)
    if hasLabelTwo then
      widget.UTRichTextBlock_Tag2:SetText(label2)
    end
  end
end
function FriendsListItem_BP:UpdateHomeVisitor(widget, UID)
  if self:CheckCanNotShowHomeStatus(widget) then
    return
  end
  local home_macros = require("client.slua.logic.home.home_macros")
  local logic_home_visit_count = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_visit_count)
  logic_home_visit_count:SetOtherVisitWidget(tonumber(UID), home_macros.ENUM_VISCNT_REQ_TYPE.FriendList, widget.Common_Home_Visit_State_UIBP, widget.TextBlock_VisitNum, nil, widget.TextBlock_HomeStatus)
end
function FriendsListItem_BP:CheckCanNotShowHomeStatus(widget)
  local _isRestrict = false
  local _isNotOpen = false
  local _isLevelLimit = false
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestirctManor() then
    _isRestrict = true
  end
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch:CheckHomeSwitchOpen(false) then
    log(bWriteLog and "teamup_side_bar switch not open")
    _isNotOpen = true
  end
  if logic_home_switch:CheckHomeLimit(false) then
    log(bWriteLog and "teamup_side_bar limit")
    _isLevelLimit = true
  end
  if _isRestrict or _isNotOpen or _isLevelLimit then
    self:SetWidgetVisible(widget.TextBlock_VisitNum, false)
    self:SetWidgetVisible(widget.Common_Home_Visit_State_UIBP, false)
    widget.WidgetSwitcher_State:SetActiveWidgetIndex(2)
    widget.TextBlock_HomeStatus:SetText(LocUtil.GetLocalizeResStr(655308))
    return true
  end
  return false
end
function FriendsListItem_BP:RefreshWOWFriend(widget, player, prifile)
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local Tag
  local Text = logic_ugc_mode:GetFriendEndTimeByType(player.uid, player.mod_id, player.type, prifile) or nil
  if not player.type then
    return
  end
  log(bWriteLog and "FriendsListItem_BP:RefreshWOWFriend player.type  == " .. player.type)
  if player.type == logic_ugc_mode.INTERACTION_TYPES.NONE then
    log(bWriteLog and "FriendsListItem_BP:RefreshWOWFriend player.type is NONE !")
  elseif player.type == logic_ugc_mode.INTERACTION_TYPES.PLAYING then
  elseif player.type == logic_ugc_mode.INTERACTION_TYPES.RANKING then
    local LogicUGCModRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCModRank)
    local rank_list = LogicUGCModRank.rank_list or {}
    for k, v in pairs(rank_list) do
      local uid = tonumber(v.uid)
      if uid and v.rank_no and uid == player.uid then
        Tag = LocUtil.LocalizeResFormat(655657)
        break
      end
    end
  elseif player.type == logic_ugc_mode.INTERACTION_TYPES.RECOMMENDED then
    Tag = LocUtil.LocalizeResFormat(655658)
  elseif player.type == logic_ugc_mode.INTERACTION_TYPES.COLLECTED then
    Tag = LocUtil.LocalizeResFormat(655659)
  elseif player.type == logic_ugc_mode.INTERACTION_TYPES.JUST_PLAYED then
  elseif player.type == logic_ugc_mode.INTERACTION_TYPES.PLAYED then
  elseif player.type == logic_ugc_mode.INTERACTION_TYPES.PLAYWOW then
  elseif player.type == logic_ugc_mode.INTERACTION_TYPES.JUST_PLAYWOW then
  else
    self:SetWidgetVisible(widget.CanvasPanel_Item, true)
    self:SetWidgetVisible(widget.SizeBox_Top, false)
    self:SetWidgetVisible(widget.SizeBox_Hint, false)
  end
  if not Text and not Tag then
    self:SetWidgetVisible(widget.TextBlock_TrajectoryTime, false)
    self:SetWidgetVisible(widget.UTRichTextBlock_Tag, false)
    log(bWriteLog and "FriendsListItem_BP:RefreshWOWFriend Text and Tag is nil, player.type = " .. player.type .. ",player.uid = " .. player.uid)
    return
  end
  if Text and not Tag then
    self:SetWidgetVisible(widget.TextBlock_TrajectoryTime, true)
    self.UIRoot.TextBlock_TrajectoryTime:SetText(Text)
  else
    self:SetWidgetVisible(widget.TextBlock_TrajectoryTime, false)
  end
  if Tag then
    self:SetWidgetVisible(widget.UTRichTextBlock_Tag, true)
    self.UIRoot.UTRichTextBlock_Tag:SetText(Tag)
  else
    self:SetWidgetVisible(widget.UTRichTextBlock_Tag, false)
  end
end
function FriendsListItem_BP:RefreshQueryGift(widget, index)
  log(bWriteLog and "FriendsListItem_BP:RefreshQueryGift index = " .. tostring(index))
end
function FriendsListItem_BP:SetStatusWithWOW(PlayerStatusMgr, widget, status, statusStr)
  PlayerStatusMgr:GetModInfoById(status.mod_id, function(modInfo)
    if not slua.isValid(widget) or not slua.isValid(self.UIRoot) then
      return
    end
    if modInfo.mod_id ~= status.mod_id then
      return
    end
    if PlayerStatusUtil.InHall(status) then
      SetStatus(widget, LocUtil.LocalizeResFormat(78322, FriendsListItem_BP.ClipString(modInfo.setting.name)), FLMacros.C_Colors.STATE_BLUE)
      widget.Button_Search:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      widget.WidgetSwitcher_Action:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      widget.WidgetSwitcher_Action:SetActiveWidgetIndex(1)
    else
      local sWoWInfo = LocUtil.LocalizeResFormat(78323, FriendsListItem_BP.ClipString(modInfo.setting.name))
      SetStatus(widget, LocUtil.LocalizeResFormat(48071, statusStr, sWoWInfo), FLMacros.C_Colors.STATE_BLUE)
      widget.Button_Search:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    end
  end)
end
return true