local FriendsListItem_BP = require("client.slua.umg.lobby.FriendList.Item.FriendListItem_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
local loc_util = require("common.loc_util")
function FriendsListItem_BP:RefreshActionButtons(widget, index, uid, status)
  self._btnChildsUIList = self._btnChildsUIList or {}
  for _, v in ipairs(self._btnChildsUIList) do
    v:Hide()
  end
  local SetActionsByFuncNameList = function(dataFunctions)
    local actionDatas = {}
    for _, v in ipairs(dataFunctions) do
      local data = self[v](self, widget, uid, status)
      if data and data.bIsShow then
        table.insert(actionDatas, data)
      end
    end
    for k, v in ipairs(actionDatas) do
      if self._btnChildsUIList[k] then
        self._btnChildsUIList[k]:Show()
        self._btnChildsUIList[k]:SetData(v)
      else
        self._btnChildsUIList[k] = self:OnlyCreateCompChild(self.ENUM_COMPONENT_TYPE.Actions, v)
        if self._btnChildsUIList[k] then
          self._btnChildsUIList[k]:Show()
          self._btnChildsUIList[k]:SetPadding(0.0, 0.0, 6.0, 0.0)
        end
      end
    end
    if widget.HorizontalBox_Actions then
      self:SetWidgetVisible(widget.HorizontalBox_Actions, 0 < #actionDatas)
    end
  end
  if not status or status.online == 0 then
    local dataFunctions = {
      "UpdateOffLineButtonShow"
    }
    SetActionsByFuncNameList(dataFunctions)
    return
  end
  local dataFunctions = {
    "GetMainCityActionData",
    "GetIslandActionData",
    "GetWoWActionData",
    "GetHomeActionData",
    "GetInviteToHomeActionData",
    "GetSingleTrainingActionData",
    "GetCollectionHallInviteActionData",
    "GetCollectionHallFollowActionData"
  }
  SetActionsByFuncNameList(dataFunctions)
  self:RefreshTeamAction(widget, uid, status)
  self:RefreshReserveAction(widget, index, uid)
  self:RefreshInviteAction(widget, uid, status)
  self:RefreshApplyAction(widget, uid, status)
  self:RefreshFreeInOutButton(widget, uid, status)
end
function FriendsListItem_BP:UpdateOffLineButtonShow(widget, uid)
  local data = {bIsShow = false}
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsPHomeMode() then
    widget.Border_Action:SetContentColorAndOpacity(FLMacros.C_Colors.OFFLINE)
    return data
  end
  local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
  local canInviteMessenger = self:CheckShowMessengerOfflineButton(uid)
  local canUseOffline = Logic_Offline_Invite.JudgeUseFcmOrMessagener(canInviteMessenger, uid)
  if canUseOffline and canUseOffline == Logic_Offline_Invite.E_Invite_Type.Messagener and Client.IsInstallMessenger(NetInterface) then
    data.bIsShow = true
    data.pic = FLMacros.C_OfflineOpePic[1]
    data.callBack = self.OnClickButton_messenger
  end
  if Logic_Offline_Invite.GetOfflineInviteIsOpen() and Logic_Offline_Invite.IsCanInvite(uid) then
    data.bIsShow = true
    data.pic = FLMacros.C_OfflineOpePic[2]
    data.callBack = self.OnClickButton_Invite_offline
  end
  if data.bIsShow then
    widget.Border_Action:SetContentColorAndOpacity(FLMacros.C_Colors.ONLINE)
  else
    widget.Border_Action:SetContentColorAndOpacity(FLMacros.C_Colors.OFFLINE)
  end
  return data
end
function FriendsListItem_BP:CheckShowMessengerOfflineButton(uid)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  log(bWriteLog and bWriteLog and "[v_zhanggao] IMSDKHelperInstance:GetCurLoginPlatform " .. IMSDKHelperInstance:GetCurLoginPlatform())
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if (IMSDKHelperInstance:GetCurLoginPlatform() == ShareSource.Messenger or IMSDKHelperInstance:GetCurLoginPlatform() == ShareSource.Facebook) and LogicFriend.IsPlatFriend(uid) then
    log(bWriteLog and bWriteLog and "[v_ywuyuan] teamup_side_bar:CheckShowMessengerOfflineButton is plat friend" .. ":" .. tostring(uid))
    return true
  end
  return false
end
function FriendsListItem_BP:ShouldShowTeamAction(status)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsPHomeMode() then
    log(bWriteLog and "FriendsListItem_BP:ShouldShowTeamAction me in home")
    return false
  end
  local home_macros = require("client.slua.logic.home.home_macros")
  if status and status.game_sub_mode and status.game_sub_mode == home_macros.Home_SubMode.Visit then
    log(bWriteLog and "FriendsListItem_BP:ShouldShowTeamAction target in home")
    return false
  end
  if GameStatus.IsCollectionHallMode() then
    log(bWriteLog and "FriendsListItem_BP:ShouldShowTeamAction me in  hall")
    return false
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if PlayerStatusUtil.IsInCollectionHall(status) then
    log(bWriteLog and "FriendsListItem_BP:ShouldShowTeamAction target in collection hall")
    return false
  end
  return true
end
function FriendsListItem_BP:RefreshTeamAction(widget, uid, status)
  if not self:ShouldShowTeamAction(status) then
    self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
    return
  end
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  local isBusy = false
  if profile.frd_status_id and profile.frd_status_id > 0 then
    local cfg = CDataTable.GetTableData("FriendStatusCfg", profile.frd_status_id)
    if cfg and cfg.type == PlayerStatusEnum.Enum_TeamState.Busy then
      isBusy = true
    end
  end
  log(bWriteLog and bWriteLog and string.format("teamup_side_bar:RefreshTeamAction, profile.frd_status_id: %s, isBusy: %s", profile.frd_status_id or -1, isBusy))
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if (PlayerStatusUtil.IsIdleOrFree(status) or PlayerStatusUtil.ISLANDIdle(status) or PlayerStatusUtil.IsInHomeIdle(status) or PlayerStatusUtil.WoWIdle(status) or PlayerStatusUtil.IsMainCityIdle(status)) and TeamUpNewSystem.CanInvite() and not isBusy then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    local is_video_inspect = status and status.is_video_inspect or PlayerStatusMgr:GetIsVideoInspect(uid)
    if is_video_inspect then
      self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
    else
      local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
      local tabID = logic_friend_list_ui:GetTabID()
      self:SetWidgetVisible(widget.WidgetSwitcher_Action, true)
      widget.WidgetSwitcher_Action:SetActiveWidgetIndex(0)
      if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG and self.UIRoot.Panel_NewbieGuide then
        local LogicNewbie = require("client.logic.newbie.logic_newbie")
        if LogicNewbie.IsNewbie() and LogicNewbie.NeedShowNewbieGuide(20005) then
          self:SetWidgetVisible(self.UIRoot.Panel_NewbieGuide, true)
        else
          self:SetWidgetVisible(self.UIRoot.Panel_NewbieGuide, false)
        end
      end
    end
  elseif (PlayerStatusUtil.IsTeam(status) or PlayerStatusUtil.ISLANDInTeam(status) or PlayerStatusUtil.IsInHomeTeam(status) or PlayerStatusUtil.WoWInTeam(status) or PlayerStatusUtil.IsMainCityTeam(status)) and not TeamUpNewSystem.IsInTeam() and status.currentTeamAmount < status.maxTeamAmount and not isBusy then
    self:SetWidgetVisible(widget.WidgetSwitcher_Action, true)
    widget.WidgetSwitcher_Action:SetActiveWidgetIndex(1)
  elseif PlayerStatusUtil.IsBattle(status) and status.socialland_type == 0 and (status.enable_watch == 1 or status.enableWatch == 1) and (status.game_sub_mode == nil or status.game_sub_mode ~= 40031) then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local isUGCMode = LogicUGCMatch:IsUGCMode(status.game_sub_mode)
    local bCanWatchUGCMode = LogicUGCMatch:IsCanWatchUGCMode(status.game_sub_mode)
    local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
    local IsCanWatch = PlayerStatusUtil.IsCanWatch(status)
    local bIsPeakMode = LogicPeakGame:IsPeakMode(status.game_sub_mode)
    local bInWoW = PlayerStatusUtil.InWoW(status)
    local bInSingleTraining = status.game_sub_mode == 10080
    local bIsCollectionHallMode = PlayerStatusUtil.IsInCollectionHall(status)
    local bShouldBlockWatch = isUGCMode and not bCanWatchUGCMode or bIsPeakMode or bInWoW or not IsCanWatch or bInSingleTraining or bIsCollectionHallMode
    log(bWriteLog and string.format("teamup_side_bar:RefreshActionButtons watch check - uid=%s, game_sub_mode=%s, isUGCMode=%s, bCanWatchUGCMode=%s, bIsPeakMode=%s, bInWoW=%s, IsCanWatch=%s,bIsCollectionHallMode=%s, bInSingleTraining=%s, bShouldBlockWatch=%s", tostring(uid), tostring(status.game_sub_mode), tostring(isUGCMode), tostring(bCanWatchUGCMode), tostring(bIsPeakMode), tostring(bInWoW), tostring(IsCanWatch), tostring(bIsCollectionHallMode), tostring(bInSingleTraining), tostring(bShouldBlockWatch)))
    if not bShouldBlockWatch then
      self:SetWidgetVisible(widget.WidgetSwitcher_Action, true)
      widget.WidgetSwitcher_Action:SetActiveWidgetIndex(2)
    else
      self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
    end
  elseif LogicFriend.IsMyFriend(uid) and PlayerStatusUtil.IsDoNotBother(status) then
    log(bWriteLog and "[vvwwzhang] teamup_side_bar:IsDoNotBother show Invited friend : " .. tostring(uid))
    self:SetWidgetVisible(widget.WidgetSwitcher_Action, true)
    widget.WidgetSwitcher_Action:SetActiveWidgetIndex(0)
  else
    log(bWriteLog and "[vvwwzhang] teamup_side_bar:IsDoNotBother or other hide ")
    self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
  end
  if GameStatus.IsCollectionHallMode() and widget.WidgetSwitcher_Action:GetActiveWidgetIndex() == 0 then
    self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
  end
end
function FriendsListItem_BP:GetIslandActionData(widget, uid, status)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  local data = {bIsShow = false}
  if from == FLMacros.ENUM_OPEN_FROM.TPLAN or status.tplan_type == 1 then
    return data
  end
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  if ShootingTrainTool.IsSelfInTraining() or ShootingTrainTool.IsOtherInTraining(status) then
    return data
  end
  local LogicIslandStatus = require("GameLua.Mod.SocialIsland.Client.IslandStatusLogic")
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local socialIslandStatus = LogicIslandStatus:CheckIslandStatus(status.socialland_type, status.game_id, status.land_id)
  local home_macros = require("client.slua.logic.home.home_macros")
  self._isLandState = 1
  if not (not PlayerStatusUtil.IsBattle(status) or status.socialland_type ~= 0 or status.game_sub_mode == home_macros.Home_SubMode.Visit or PlayerStatusUtil.IsMainCity(status)) or (status.teamState or 0) > 2 then
    data.bIsShow = false
  elseif socialIslandStatus == LogicIslandStatus.ENUM_ISLAND_STATUS.ME_ON_ISLAND then
    data.bIsShow = true
    self._isLandState = 1
  elseif socialIslandStatus == LogicIslandStatus.ENUM_ISLAND_STATUS.TARGET_ON_ISLAND then
    data.bIsShow = true
    self._isLandState = 2
  elseif socialIslandStatus == LogicIslandStatus.ENUM_ISLAND_STATUS.ON_DIFFERENT_ISLAND then
    data.bIsShow = true
    self._isLandState = 3
  elseif socialIslandStatus == LogicIslandStatus.ENUM_ISLAND_STATUS.ON_SAME_ISLAND then
    data.bIsShow = true
    self._isLandState = 4
  else
    data.bIsShow = false
  end
  data.pic = FLMacros.C_IslandOpePic[self._isLandState] or ""
  data.callBack = self.OnClickButton_Island
  return data
end
function FriendsListItem_BP:RefreshReserveAction(widget, index, uid)
  log(bWriteLog and "teamup_side_bar:RefreshReserveAction uid = " .. uid)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(uid)
  if not status then
    log(bWriteLog and "teamup_side_bar:RefreshReserveAction no status")
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local isSwitchOpen = LogicFriend.IsFriendReserveSwitchOpen(uid)
  log(bWriteLog and "teamup_side_bar:RefreshReserveAction isSwitchOpen = " .. tostring(isSwitchOpen))
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local isInBattle = PlayerStatusUtil.IsBattle(status)
  local isHall = PlayerStatusUtil.IsInCollectionHall(status)
  log(bWriteLog and "teamup_side_bar:RefreshReserveAction isInBattle = " .. tostring(isInBattle))
  local logic_home_status = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_status)
  local bInHome = logic_home_status:IsHomeVisitMode(status.game_sub_mode) or logic_home_status:IsHomeBuildMode(status.game_sub_mode)
  log(bWriteLog and "teamup_side_bar:RefreshReserveAction bInHome = " .. tostring(bInHome))
  if not (isSwitchOpen and isInBattle) or status.socialland_type ~= 0 or bInHome or PlayerStatusUtil.IsMainCity(status) or isHall or GameStatus.IsCollectionHallMode() then
    self:SetWidgetVisible(widget.WidgetSwitcher_Reserve, false)
    return
  end
  local state = LogicFriend.GetReserveState(uid)
  log(bWriteLog and "teamup_side_bar:RefreshReserveAction state = " .. state)
  local pic = FLMacros.C_ReserveOpePic[state]
  widget.WidgetSwitcher_Reserve:SetActiveWidgetIndex(0)
  if state == 0 then
    self:SetWidgetVisible(widget.WidgetSwitcher_Reserve, false)
  elseif state == 1 then
    self:SetWidgetVisible(widget.WidgetSwitcher_Reserve, true)
    local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
    local tabID = logic_friend_list_ui:GetTabID()
    if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
      self:UpdateReserveGuideTips(widget, index)
    end
    widget.TextBlock_Reserve:SetText(LocUtil.GetLocalizeResStr(7554))
    widget.TextBlock_Reserve:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 1)))
    self:SetWidgetVisible(widget.Image_Reserve, true)
    self:SetTexture(widget.Image_Reserve, pic)
  elseif state == 2 then
    self:SetWidgetVisible(widget.WidgetSwitcher_Reserve, true)
    widget.TextBlock_Reserve:SetText(LocUtil.GetLocalizeResStr(7554))
    self:SetWidgetVisible(widget.Image_Reserve, true)
    self:SetTexture(widget.Image_Reserve, pic)
    widget.TextBlock_Reserve:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.2)))
  elseif state == 3 then
    self:SetWidgetVisible(widget.WidgetSwitcher_Reserve, true)
    widget.TextBlock_Reserve:SetText(LocUtil.GetLocalizeResStr(7555))
    self:SetWidgetVisible(widget.Image_Reserve, false)
    widget.TextBlock_Reserve:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 1)))
  else
    self:SetWidgetVisible(widget.WidgetSwitcher_Reserve, false)
  end
end
function FriendsListItem_BP:UpdateReserveGuideTips(widget, index)
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  if logic_friend_reserve:IsReserveGuideShowed() then
    return
  end
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  if logic_friend_list_ui.reserveGuideShowed then
    if logic_friend_list_ui.friendGuideItemIndex and logic_friend_list_ui.friendGuideItemIndex == index then
      local Friend_ReserveGuide_Tips = UIManager.GetUI(UIManager.UI_Config.Friend_ReserveGuide_Tips)
      if Friend_ReserveGuide_Tips and Friend_ReserveGuide_Tips:IsShow() then
        Friend_ReserveGuide_Tips:ResetPanelPosition(widget.Button_Reserved)
      end
    end
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Lobby_Lucky_Teammate_UIBP) then
    return
  end
  local Lobby_InviteFriend_BP = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
  if not Lobby_InviteFriend_BP then
    return
  end
  if not logic_friend_list_ui.friendGuideItemIndex then
    Lobby_InviteFriend_BP:UpdateReserveGuideShow()
  end
  Lobby_InviteFriend_BP:HideOrShowReserveGuideTips(true, widget, index)
end
function FriendsListItem_BP:GetHomeActionData(widget, uid, status)
  local data = {bIsShow = false}
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch:CheckHomeSwitchOpen() then
    return data
  end
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if from == FLMacros.ENUM_OPEN_FROM.TPLAN then
    return data
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if PlayerStatusUtil.IsBusy(status) then
    return data
  end
  if PlayerStatusUtil.IsDoNotBother(status) then
    return data
  end
  if status.socialland_type ~= 0 then
    return data
  end
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  if ShootingTrainTool.IsSelfInTraining() or ShootingTrainTool.IsOtherInTraining(status) then
    return data
  end
  local logic_home_status = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_status)
  if not logic_home_status:IsHomeVisitMode(status.game_sub_mode) then
    return data
  end
  data.bIsShow = true
  data.pic = FLMacros.C_HomeOpePic[1]
  data.callBack = self.OnClickButton_Homeland
  return data
end
function FriendsListItem_BP:GetCollectionHallFollowActionData(widget, uid, status)
  local data = {bIsShow = false}
  local Logic_SC_DownloadTools = require("client.slua.logic.lobby.Left.SocialLobby.Logic_SC_DownloadTools")
  local bIsOpen = Logic_SC_DownloadTools.GetPlanCHIsOpen()
  if not bIsOpen then
    return data
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if not PlayerStatusUtil.IsInCollectionHall(status) then
    return data
  end
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if from == FLMacros.ENUM_OPEN_FROM.TPLAN then
    return data
  end
  if PlayerStatusUtil.IsDoNotBother(status) then
    return data
  end
  if status.socialland_type ~= 0 then
    return data
  end
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  if ShootingTrainTool.IsSelfInTraining() or ShootingTrainTool.IsOtherInTraining(status) then
    return data
  end
  data.bIsShow = true
  data.pic = FLMacros.C_CollectionHallOpePic[1]
  data.callBack = self.OnClickButton_FollowToCollectionHall
  return data
end
function FriendsListItem_BP:GetWoWActionData(widget, uid, status)
  local data = {bIsShow = false}
  data.callBack = self.OnClickButton_WonderfulWorld
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if from == FLMacros.ENUM_OPEN_FROM.LOBBY then
    if status.cwow_type == 0 then
      return data
    end
  elseif from == FLMacros.ENUM_OPEN_FROM.UGCPlayHallInvite then
    local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
    if PlayerStatusUtil.IsBusy(status) or PlayerStatusUtil.IsDoNotBother(status) or PlayerStatusUtil.IsBattle(status) then
      self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
      return data
    end
    if status.socialland_type ~= 0 then
      self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
      return data
    end
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    if UGCPlayHallRoom:IsPlayerInRoom(uid) then
      self:SetWidgetVisible(widget.WidgetSwitcher_Action, false)
      return data
    end
    self:SetWidgetVisible(widget.WidgetSwitcher_Action, true)
    widget.WidgetSwitcher_Action:SetActiveWidgetIndex(0)
    return data
  elseif from ~= FLMacros.ENUM_OPEN_FROM.CREATIVEWOW then
    return data
  end
  local logic_creative_wow_friend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_creative_wow_friend)
  local WoWStatus = logic_creative_wow_friend:GetStatus(status.cwow_type, status.game_id, status.cwow_ds_partition_id)
  log(bWriteLog and "teamup_side_bar:RefreshWoWAction WoWStatus=" .. tostring(WoWStatus))
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if PlayerStatusUtil.IsMainCityIdle(status) then
    data.bIsShow = true
    data.pic = FLMacros.C_WowOpePic[1]
  elseif PlayerStatusUtil.IsBattle(status) and status.cwow_type == 0 or (status.teamState or 0) > 2 then
  elseif WoWStatus == logic_creative_wow_friend.ENUM_CWOW_STATUS.ME_ON_CWOW then
    data.bIsShow = true
    data.pic = FLMacros.C_WowOpePic[1]
  elseif WoWStatus == logic_creative_wow_friend.ENUM_CWOW_STATUS.TARGET_ON_CWOW then
    data.bIsShow = true
    data.pic = FLMacros.C_WowOpePic[2]
  elseif WoWStatus == logic_creative_wow_friend.ENUM_CWOW_STATUS.ON_DIFFERENT_CWOW then
  else
    if WoWStatus == logic_creative_wow_friend.ENUM_CWOW_STATUS.ON_SAME_CWOW then
    else
    end
  end
  return data
end
function FriendsListItem_BP:GetInviteToHomeActionData(widget, uid, status)
  local data = {bIsShow = false}
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch:CheckHomeSwitchOpen() then
    return data
  end
  if status.tplan_type == 1 then
    return data
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode() then
    return data
  end
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  if not logic_home_entry:IsPlanPHMode() then
    return data
  end
  local logic_home_status = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_status)
  local bInHome = logic_home_status:IsHomeVisitMode(status.game_sub_mode) or logic_home_status:IsHomeBuildMode(status.game_sub_mode)
  local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
  local bInMainCity = status.game_sub_mode == main_city_config.C_GameSubMode
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if not (not PlayerStatusUtil.IsBattle(status) or PlayerStatusUtil.IsInCollectionHall(status) or bInHome or status.socialland_type ~= 0 or bInMainCity) or (status.teamState or 0) > 2 and not PlayerStatusUtil.IsFree(status) then
    log(bWriteLog and string.format("teamup_side_bar:RefreshInviteToHomeAction hide button, uid = %s mod = %s", uid, status.game_sub_mode))
    return data
  end
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  if ShootingTrainTool.IsSelfInTraining() or ShootingTrainTool.IsOtherInTraining(status) then
    return data
  end
  data.bIsShow = true
  data.pic = FLMacros.C_HomeOpePic[2]
  data.callBack = self.OnClickButton_InviteToHome
  return data
end
function FriendsListItem_BP:GetMainCityActionData(widget, uid, status)
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local isInMainCity = PlayerStatusUtil.IsMainCity(status)
  local isSelfInMainCity = GameStatus.IsInMainCityConnectDs()
  local isOtherInBattle = PlayerStatusUtil.IsBattle(status) and not isInMainCity
  local data = {bIsShow = false}
  if isOtherInBattle then
    return data
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return data
  end
  if not isInMainCity and not isSelfInMainCity then
    return data
  end
  data.bIsShow = true
  data.pic = FLMacros.C_MaincityOpePic[not isInMainCity and isSelfInMainCity and 2 or 1]
  data.callBack = self.OnClickMainCity
  return data
end
function FriendsListItem_BP:GetCollectionHallInviteActionData(widget, uid, status)
  local data = {bIsShow = false}
  if status.tplan_type == 1 then
    return data
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode() then
    return data
  end
  if not GameStatus.IsCollectionHallMode() then
    return data
  end
  local logic_home_status = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_status)
  local bInHome = logic_home_status:IsHomeVisitMode(status.game_sub_mode) or logic_home_status:IsHomeBuildMode(status.game_sub_mode)
  local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
  local bInMainCity = status.game_sub_mode == main_city_config.C_GameSubMode
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if not (not PlayerStatusUtil.IsBattle(status) or PlayerStatusUtil.IsInCollectionHall(status) or bInHome or status.socialland_type ~= 0 or bInMainCity) or (status.teamState or 0) > 2 and not PlayerStatusUtil.IsFree(status) then
    log(bWriteLog and "teamup_side_bar:RefreshInviteToHomeAction hide button, uid = " .. tostring(uid))
    return data
  end
  data.bIsShow = true
  data.pic = FLMacros.C_CollectionHallOpePic[2]
  data.callBack = self.OnClickButton_InviteToCollectionHall
  return data
end
function FriendsListItem_BP:RefreshInviteAction(widget, uid, status)
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  if logic_return_team_recommend:CheckTeamUpReward(uid) then
    widget.WidgetSwitcher_Invite:SetActiveWidgetIndex(1)
  else
    widget.WidgetSwitcher_Invite:SetActiveWidgetIndex(0)
  end
end
function FriendsListItem_BP:RefreshApplyAction(widget, uid, status)
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  if logic_return_team_recommend:CheckTeamUpReward(uid) then
    widget.WidgetSwitcher_Apply:SetActiveWidgetIndex(1)
  else
    widget.WidgetSwitcher_Apply:SetActiveWidgetIndex(0)
  end
end
function FriendsListItem_BP:RefreshFreeInOutButton(widget, uid, status)
  if not widget.Button_Exit then
    return
  end
  self:SetWidgetVisible(widget.Button_Exit, false)
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  PlayerStatusUtil.CheckCanJoinFriendGame(status, function(canJoin)
    if not slua.isValid(widget) or not slua.isValid(widget.Button_Exit) then
      return
    end
    self:SetWidgetVisible(widget.Button_Exit, canJoin, true)
  end)
end
function FriendsListItem_BP:GetSingleTrainingActionData(widget, uid, status)
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  local data = {bIsShow = false}
  data.bIsShow = ShootingTrainTool.IsButtonShow(uid, status)
  data.pic = FLMacros.C_SingleTrainingOpePic[1]
  data.callBack = self.OnClickButton_SingleTraining
  return data
end