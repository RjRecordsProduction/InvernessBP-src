local Lobby_Home_Door_Entrance_UIBP = {}
function Lobby_Home_Door_Entrance_UIBP:ctor(_, uid)
  self.  self.bSelf = tonumber(uid) == tonumber(DataMgr.roleData.uid)
end
function Lobby_Home_Door_Entrance_UIBP:OnInitialize()
  Lobby_Home_Door_Entrance_UIBP.__super.OnInitialize(self)
end
function Lobby_Home_Door_Entrance_UIBP:RegistEvents()
  Lobby_Home_Door_Entrance_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Detail, self.OnButton_DetailClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Enter, self.OnButton_EnterClick, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStart, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchToPageEnd, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHANGE_DOORPLATE, self.UpdateDoorPlate, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_HOME_NOT_OPEN_INFO_RSP, self.OnGetNotOpenInfo, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_REVISE_HOME_NAME_OK, self.OnModifyNameOk, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_PHOTO, self.UpdatePhoto, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DELETE_SUCCESS, self.OnDeleteSuccess, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_RECOMPUTE_SMART_UPGRADE, self.OnSmartUpgradeStatusChanged, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_NEWTHEME, EVENTID_PLANPH_NEWTHEME_REWARD_STATUS_RSP, self.RefreshRedDotAndTips, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_NEWTHEME, EVENTID_PLANPH_NEWTHEME_TAKE_ENTER_REWARD_RSP, self.RefreshRedDotAndTips, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_CAR_PARKING_GIFT_REDDOT_UPDATE, self.RefreshRedDotAndTips, self)
  self:AddCommonEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_CONFIG_UPDATE, self.UpdateTips, self)
  self:AddCommonEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_DATA_UPDATE, self.UpdateTips, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE, self.RefreshRedDotInfo, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRANCE_TIPS_ITEM_UPDATE, self.UpdateTips, self)
end
function Lobby_Home_Door_Entrance_UIBP:OnPostInitialize()
  Lobby_Home_Door_Entrance_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
end
function Lobby_Home_Door_Entrance_UIBP:OnShow()
  Lobby_Home_Door_Entrance_UIBP.__super.OnShow(self)
  log(bWriteLog and " Lobby_Home_Door_Entrance_UIBP:OnShow")
  local logic_home_smart_upgrade = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_smart_upgrade)
  if not logic_home_smart_upgrade:IsUsingLatestData() then
    logic_home_smart_upgrade:ProcessSmartLevelUpgradeStatus()
    log(bWriteLog and " Lobby_Home_Door_Entrance_UIBP:OnShow should req for latest smart upgrade data")
  end
  local logic_home_theme = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_theme)
  if logic_home_theme:GetCurrentConfig(true) then
    local PHomeAnniversaryHandler = require("client.network.Protocol.PHomeAnniversaryHandler")
    PHomeAnniversaryHandler.send_check_manor_extra_rewards_req()
  end
  local logic_home_car_parking_gift = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking_gift)
  logic_home_car_parking_gift:send_manor_parking_gift_info_req()
end
function Lobby_Home_Door_Entrance_UIBP:OnHide()
  Lobby_Home_Door_Entrance_UIBP.__super.OnHide(self)
end
function Lobby_Home_Door_Entrance_UIBP:OnClose()
  Lobby_Home_Door_Entrance_UIBP.__super.OnClose(self)
end
function Lobby_Home_Door_Entrance_UIBP:OnButton_DetailClick()
  self:PlayAudio(sound_config.click)
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:OnButton_DetailClick")
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(true) then
    return
  end
  local isInRoleInfo = false
  if UIManager.IsUIShow(UIManager.UI_Config.roleinfo_segment) then
    isInRoleInfo = true
  end
  self:ReqUseItems(function(_, use_items)
    local logic_home_detail = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_detail)
    local home_macros = require("client.slua.logic.home.home_macros")
    logic_home_detail:ShowCommonHomeDetailsUI(self.uid, use_items, isInRoleInfo and home_macros.ENUM_DETAIL_SCENE_TYPE.RoleInfo or home_macros.ENUM_DETAIL_SCENE_TYPE.SocialLobby, true, nil, true)
  end)
  self:ClearCurRedDot()
  local tlogType = TLogEventDefine.Home_Detail_Click_Social_Lobby
  if isInRoleInfo then
    tlogType = TLogEventDefine.Home_Detail_Click_RoleInfo
  end
  log(bWriteLog and string.format("Lobby_Home_Door_Entrance_UIBP:OnButton_DetailClick, tlogType:%s", tlogType))
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(tlogType)
end
function Lobby_Home_Door_Entrance_UIBP:ClearCurRedDot()
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:ClearCurRedDot")
  if self.redDotInfo then
    local logic_lobby_home_entry_item = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_lobby_home_entry_item)
    logic_lobby_home_entry_item:ProcClickEntry(self.redDotInfo)
  end
end
function Lobby_Home_Door_Entrance_UIBP:OnButton_EnterClick()
  self:PlayAudio(sound_config.click_v1)
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(true) then
    return
  end
  self:ReqUseItems(function(_, _, showDownload)
    if showDownload then
      ShowNotice(102100025)
    else
      local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
      logic_home_entry:EntryVisitHome(self.uid)
    end
  end)
  self:ClearCurRedDot()
  local isInRoleInfo = false
  if UIManager.IsUIShow(UIManager.UI_Config.roleinfo_segment) then
    isInRoleInfo = true
  end
  local home_macros = require("client.slua.logic.home.home_macros")
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.Home_Enter_Self_Click_Entry, isInRoleInfo and home_macros.ENUM_VISIT_SCENE_TYPE.RoleInfo or home_macros.ENUM_VISIT_SCENE_TYPE.SocialLobby)
end
function Lobby_Home_Door_Entrance_UIBP:ReqUseItems(callback)
  local logic_home_detail = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_detail)
  logic_home_detail:SendGetManorUseItems(self.uid, function(uid, use_items)
    log(bWriteLog and string.format("Lobby_Home_Door_Entrance_UIBP:ReqUseItems(callback), callback:%s", callback))
    log(bWriteLog and string.format("Lobby_Home_Door_Entrance_UIBP:ReqUseItems(callback), self.uid:%s", self.uid))
    log(bWriteLog and string.format("Lobby_Home_Door_Entrance_UIBP:ReqUseItems(callback), uid:%s", uid))
    if not slua.isValid(self.UIRoot) or self.uid ~= uid then
      return
    end
    local use_items_arr = {}
    if use_items then
      local index = 1
      for itemID, v in pairs(use_items) do
        use_items_arr[index] = itemID
        index = index + 1
      end
    end
    local showDownload = self:UpdateDownloadInfo(use_items_arr)
    if callback then
      callback(uid, use_items, showDownload)
    end
  end)
end
function Lobby_Home_Door_Entrance_UIBP:UpdateDownloadInfo(use_items_arr)
  if tonumber(self.uid) ~= tonumber(DataMgr.roleData.uid) then
    return
  end
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local common_download_handler = require("client.slua.common.common_download_handler")
  if not self.downloaderStyle then
    self.downloaderStyle = {
      showProgress = true,
      showSize = true,
      hideProgressText = true,
      pos = FVector2D(5, -1),
      textFillRect = {
        Pos = FVector2D(18, 0),
        Size = FVector2D(100, 24)
      },
      from = PufferTlog.Enum_TLog_From.HomeDoorPlate,
      callback = function()
        if not slua.isValid(self.UIRoot) then
          return
        end
        self:UpdateDownloadInfo()
      end
    }
  end
  local common_download_ui = common_download_handler.CreateDownloadUIReturnUIBase(nil, use_items_arr, self, self.UIRoot.CanvasPanel_Download, self.downloaderStyle)
  local showDownloadInfo = common_download_ui ~= nil
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Entry, true)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, true, true)
  self.UIRoot.WidgetSwitcher_Entry:SetActiveWidgetIndex(showDownloadInfo and 1 or 0)
  log_format(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:UpdateDownloadInfo, showDownloadInfo:%s", showDownloadInfo)
  if showDownloadInfo then
    if self.RewardListUI then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Anniversary, false, false)
    end
  else
    if self.RewardListUI then
      self.RewardListUI:CloseSelf()
      self.RewardListUI = nil
    end
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Anniversary, true, false)
  end
end
function Lobby_Home_Door_Entrance_UIBP:OnDeleteSuccess()
  self:UpdateUI()
end
function Lobby_Home_Door_Entrance_UIBP:OnSmartUpgradeStatusChanged()
  log(bWriteLog and " Lobby_Home_Door_Entrance_UIBP:OnSmartUpgradeStatusChanged")
  self:RefreshRedDotAndTips()
end
function Lobby_Home_Door_Entrance_UIBP:RefreshUpgradeStatus()
  log(bWriteLog and " Lobby_Home_Door_Entrance_UIBP:RefreshUpgradeStatus")
  if tonumber(self.uid) ~= tonumber(DataMgr.roleData.uid) then
    self:SetWidgetVisible(self.UIRoot.Home_Details_Tips02_UIBP, false)
    return
  end
  local logic_home_smart_upgrade = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_smart_upgrade)
  local smartUpgradeInfo = logic_home_smart_upgrade:GetSmartUpgradeSaveInfo()
  local bRecentlyNotShown = false
  if not smartUpgradeInfo.lastTrySmartUpgradeTime then
    log(bWriteLog and " Lobby_Home_Door_Entrance_UIBP:RefreshUpgradeStatus not showed yet")
    bRecentlyNotShown = true
  else
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if curTime - smartUpgradeInfo.lastTrySmartUpgradeTime > 604800 then
      log(bWriteLog and " Lobby_Home_Door_Entrance_UIBP:RefreshUpgradeStatus long enough since last shown")
      bRecentlyNotShown = true
    end
  end
  if not logic_home_smart_upgrade:CheckCanSmartUpgrade() or not bRecentlyNotShown then
    log(bWriteLog and " Lobby_Home_Door_Entrance_UIBP:RefreshUpgradeStatus do not show smart upgrade")
    self:SetWidgetVisible(self.UIRoot.Home_Details_Tips02_UIBP, false)
    return
  end
  log(bWriteLog and " Lobby_Home_Door_Entrance_UIBP:RefreshUpgradeStatus should show smart upgrade")
  self:SetWidgetVisible(self.UIRoot.Home_Details_Tips02_UIBP, true)
  if not self.homeSmartUpgradeTips then
    local Home_Details_Tips02_UIBP = require("GameLua.Mod.PlanPH.Client.UI.Upgrade.Home_Details_Tips02_UIBP")
    self.homeSmartUpgradeTips = Home_Details_Tips02_UIBP()
    self.homeSmartUpgradeTips:InitWithParentWidget(self, self.UIRoot.Home_Details_Tips02_UIBP)
  end
end
function Lobby_Home_Door_Entrance_UIBP:RefreshAnniversaryEntry()
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RefreshAnniversaryEntry")
  if self.anniversaryEntryUI then
    self.anniversaryEntryUI:Close()
    self.anniversaryEntryUI = nil
  end
  local logic_home_anniversary_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_anniversary_activity)
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_anniversary_activity:IsActivityOpen() and not logic_home_switch:CheckHomeLimit() then
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RefreshAnniversaryEntry create subUI1")
    self.anniversaryEntryUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_Anniversary, UIManager.UI_Config.Lobby_Home_Door_Entrance_Anniversary_Item_UIBP)
  end
  if self.newThemeUI then
    self.newThemeUI:Close()
    self.newThemeUI = nil
  end
  local logic_home_theme = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_theme)
  if logic_home_theme:GetCurrentConfig(true) and not logic_home_switch:CheckHomeLimit() then
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RefreshAnniversaryEntry create subUI2")
    if tonumber(self.uid) == tonumber(DataMgr.roleData.uid) and logic_home_theme:NotGetOneFromThree() then
      self.newThemeUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_Anniversary, UIManager.UI_Config.Lobby_Home_AnniversaryActivity_UIBP)
    end
  end
end
function Lobby_Home_Door_Entrance_UIBP:RefreshParkingEntry()
  if self.parkingEntryUI then
    self.parkingEntryUI:Close()
    self.parkingEntryUI = nil
  end
  if self.anniversaryEntryUI then
    return
  end
  if self.newThemeUI then
    return
  end
  local logic_home_car_parking = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking)
  local bCheckParking = logic_home_car_parking:IsCarParkingActivityValid()
  if not bCheckParking then
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RefreshParkingEntry parking not open")
    return
  end
  local logic_home_car_parking_gift = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking_gift)
  local bHasGift = logic_home_car_parking_gift:hasGift()
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local homeProfile
  if logic_home_joint:HasJointHome() then
    homeProfile = logic_home_profile:GetHomeProfileByUid(logic_home_joint.res_joint_info.master_uid)
  else
    homeProfile = logic_home_profile:GetHomeProfileByUid(tonumber(DataMgr.roleData.uid))
  end
  local bhas
  if homeProfile then
    local home_car_parking_utils = require("client.slua.logic.home.CarParking.home_car_parking_utils")
    bhas = home_car_parking_utils.GetHomeIdleVehicleNum(homeProfile) > 0
  end
  if (bHasGift or bhas) and logic_home_car_parking:GetHomeDoorEntranceReddotEnable() then
    local reddotType = bHasGift or 0
    self.parkingEntryUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_Anniversary, UIManager.UI_Config.Lobby_Home_ParkingLot_UIBP, reddotType)
  end
end
function Lobby_Home_Door_Entrance_UIBP:UpdatePhoto(_, _, in_photo)
  if in_photo then
    self:SetWidgetVisible(self.UIRoot.Button_Enter, false, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, false)
  elseif tonumber(DataMgr.roleData.uid) == tonumber(self.uid) then
    self:SetWidgetVisible(self.UIRoot.Button_Enter, true, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, true)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, false)
    self:SetWidgetVisible(self.UIRoot.Button_Enter, false, true)
  end
end
function Lobby_Home_Door_Entrance_UIBP:OnSwitchToPageStart(_, _, toPage)
  if toPage == ENUM_LobbyPageType.Left and tonumber(self.uid) == tonumber(DataMgr.roleData.uid) then
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    if logic_home_switch:CheckHomeSwitchOpen() then
      self:SelfHitTestInvisible()
      self:UpdateUI()
    else
      self:Collapsed()
    end
  end
end
function Lobby_Home_Door_Entrance_UIBP:OnSwitchToPageEnd()
  self:CheckGuideTips()
end
function Lobby_Home_Door_Entrance_UIBP:UpdateDoorPlate(_, _, skinID)
  self:RefreshHomePlate(skinID)
end
function Lobby_Home_Door_Entrance_UIBP:OnGetNotOpenInfo(_, _, be_visited_cnt, visit_friend_list)
  if not be_visited_cnt and not visit_friend_list then
    return
  end
  if UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP) then
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local page = Lobby_Main_Control.curPage
    if page ~= ENUM_LobbyPageType.Left then
      return
    end
  end
  local topUIName = UIManager.GetTopUIName()
  if topUIName ~= "" then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Home_Visit_Popup_UIBP, {visCnt = be_visited_cnt, friendList = visit_friend_list})
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeOpenGuideShowWeek, false, 7)
end
function Lobby_Home_Door_Entrance_UIBP:OnModifyNameOk()
  if tonumber(self.uid) ~= tonumber(DataMgr.roleData.uid) then
    return
  end
  log(bWriteLog and "Common_Home_NamePlate_Item_UIBP:OnModifyNameOk")
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local homeProfile = logic_home_profile:GetHomeProfileByUid(self.uid)
  if homeProfile and homeProfile.name and homeProfile.name ~= "" then
    self.UIRoot.TextBlock_Name:SetText(homeProfile.name)
  end
end
function Lobby_Home_Door_Entrance_UIBP:UpdateUI(uid)
  self.uid = uid or self.uid
  if self:CheckShow() then
    self:RefreshVisitorCnt()
    self:RefreshHomePlate()
    self:CheckGuideTips()
    if self.uid and self.uid == tonumber(DataMgr.roleData.uid) then
      local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
      PHomeJointHandler.send_manor_joint_info_req()
      local logic_home_installment = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_installment)
      logic_home_installment:send_get_manor_batch_buy_stage_info_req()
    end
  end
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(false) and tonumber(DataMgr.roleData.uid) ~= tonumber(self.uid) then
    local lv = DataMgr.roleData.manor_switch and DataMgr.roleData.manor_switch.open_level or 11
    self.UIRoot.TextBlock_Lock:SetText(LocUtil.LocalizeResFormat(69033, lv))
  else
    self.UIRoot.TextBlock_Lock:SetText(LocUtil.GetLocalizeResStr(655393))
  end
  self:CheckDownloadReward()
  self:RequestHomePKData(self.uid)
  self:RefreshRedDotAndTips()
end
function Lobby_Home_Door_Entrance_UIBP:CheckDownloadReward()
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:CheckDownloadReward")
  local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
  local rewardList = logic_home_download.GetDownloadReward()
  if rewardList and next(rewardList) then
    if not self.RewardListUI then
      self.RewardListUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_DLReward, UIManager.UI_Config.Lobby_Home_Download_Reward_UIBP, rewardList, 3)
    end
    if self.RewardListUI then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Anniversary, false, false)
    end
  else
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:CheckDownloadReward rewardList is {}")
    if self.RewardListUI then
      self.RewardListUI:CloseSelf()
      self.RewardListUI = nil
    end
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Anniversary, true, false)
  end
end
function Lobby_Home_Door_Entrance_UIBP:CheckShow()
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeSwitchOpen() then
    if logic_home_switch:CheckHomeLimit() then
      local logic_home_door_plate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_door_plate)
      local id = logic_home_door_plate:GetDefaultSkinId()
      self:CreateDoorPlateBP(id, 0)
      self.UIRoot.WidgetSwitcher_Home:SetActiveWidgetIndex(1)
      return false
    else
      self.UIRoot.WidgetSwitcher_Home:SetActiveWidgetIndex(0)
      self:SelfHitTestInvisible()
    end
    return true
  end
  self:Collapsed()
  return false
end
function Lobby_Home_Door_Entrance_UIBP:RefreshVisitorCnt()
  local home_macros = require("client.slua.logic.home.home_macros")
  local logic_home_visit_count = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_visit_count)
  if tonumber(self.uid) ~= tonumber(DataMgr.roleData.uid) then
    logic_home_visit_count:SetVisitWidget(tonumber(self.uid), home_macros.ENUM_VISCNT_REQ_TYPE.DoorPlate, self.UIRoot.Common_Home_Visit_State_UIBP, self.UIRoot.TextBlock_VisCnt)
    return
  end
  if self.refreshVisCntTimer then
    self:RemoveTimer(self.refreshVisCntTimer)
    self.refreshVisCntTimer = nil
  end
  logic_home_visit_count:SetVisitWidget(tonumber(self.uid), home_macros.ENUM_VISCNT_REQ_TYPE.DoorPlate, self.UIRoot.Common_Home_Visit_State_UIBP, self.UIRoot.TextBlock_VisCnt)
  self.refreshVisCntTimer = self:AddTimerLoop(60, function()
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    if Lobby_Main_Control.curPage == ENUM_LobbyPageType.Left then
      logic_home_visit_count:SetVisitWidget(tonumber(self.uid), home_macros.ENUM_VISCNT_REQ_TYPE.DoorPlate, self.UIRoot.Common_Home_Visit_State_UIBP, self.UIRoot.TextBlock_VisCnt)
    end
  end, 0, home_macros.visCntRefreshCD)
end
function Lobby_Home_Door_Entrance_UIBP:RefreshHomePlate(skinID)
  local uid = tonumber(self.uid)
  if uid == tonumber(DataMgr.roleData.uid) then
    self:SetWidgetVisible(self.UIRoot.Button_Enter, true, true)
  else
    self:SetWidgetVisible(self.UIRoot.Button_Enter, false, true)
  end
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  logic_home_profile:GetOrReqHomeProfile({uid}, function()
    if not self.UIRoot then
      log(bWriteLog and "ShowVSBanTip return of not self.UIRoot1")
      return
    end
    local profile = logic_home_profile:GetHomeProfileByUid(uid)
    if profile then
      self.UIRoot.WidgetSwitcher_Home:SetActiveWidgetIndex(0)
      if profile.name and profile.name ~= "" then
        self.UIRoot.TextBlock_Name:SetText(profile.name)
      else
        local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
        logic_profile_get_wrap.GetNormalProfiles({uid}, function()
          if not self.UIRoot then
            log(bWriteLog and "ShowVSBanTip return of not self.UIRoot2")
            return
          end
          self.UIRoot.TextBlock_Name:SetText(logic_home_profile:GetHomeName(uid))
        end, Enum_PROFILE_REPORT_CFG.PLANPH_SOCAIL_NAMEPLATE, 0, false)
      end
      self.UIRoot.TextBlock_Level:SetText(profile.grow_info.level)
      self:CreateDoorPlateBP(skinID or profile.cur_skin_id, profile.grow_info.prosperity)
      local logic_home_door_plate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_door_plate)
      local color = logic_home_door_plate:GetDoorPlateColorById(skinID or profile.cur_skin_id)
      self.UIRoot.TextBlock_Name:SetColorAndOpacity(FSlateColor(color))
      self.UIRoot.TextBlock_Level:SetColorAndOpacity(FSlateColor(color))
      self.UIRoot.Image_HomeIcon:SetColorAndOpacity(color)
      if uid == tonumber(DataMgr.roleData.uid) then
        self:ReqUseItems()
      else
        self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Entry, false)
        self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, false, true)
      end
      self:SetHomeJointUI()
    else
      self.UIRoot.WidgetSwitcher_Home:SetActiveWidgetIndex(1)
    end
  end, true)
end
function Lobby_Home_Door_Entrance_UIBP:CreateDoorPlateBP(skinID, prosperity)
  if self.doorPlateBGBP then
    self.doorPlateBGBP:CloseSelf()
    self.doorPlateBGBP = nil
  end
  local logic_home_door_plate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_door_plate)
  local config = logic_home_door_plate:GetSkinConfigById(skinID)
  if not config then
    log(bWriteLog and string.format("Lobby_Home_Door_Entrance_UIBP:CreateDoorPlateBP, skinID:%s", skinID))
    config = logic_home_door_plate:GetSkinConfigById(logic_home_door_plate:GetDefaultSkinId())
  end
  if not config then
    log(bWriteLog and string.format("Lobby_Home_Door_Entrance_UIBP:CreateDoorPlateBP, config:%s", config))
    return
  end
  self.doorPlateBGBP = self:CreateChildWindowWithBpPath("CanvasPanel_Bg", UIManager.UI_Config.Lobby_Home_Door_Entrance_BG_UIBP, config.LevelBPPath, self.uid, config)
end
function Lobby_Home_Door_Entrance_UIBP:CheckGuideTips()
  if UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP) then
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local page = Lobby_Main_Control.curPage
    if page ~= ENUM_LobbyPageType.Left then
      return
    end
  end
  if tonumber(self.uid) == tonumber(DataMgr.roleData.uid) then
    local logic_home_list_view = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_list_view)
    logic_home_list_view:CheckOpenGuideTips()
  end
end
function Lobby_Home_Door_Entrance_UIBP:SetHomeJointUI()
  local home_item_utils = require("client.slua.logic.home.home_item_utils")
  home_item_utils.SetHomeHouseIcon(self.UIRoot.Image_HomeIcon, self.uid)
end
function Lobby_Home_Door_Entrance_UIBP:RefreshRedDotAndTips()
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RefreshRedDotAndTips")
  self:RefreshRedDotInfo()
  self:UpdateTips()
end
function Lobby_Home_Door_Entrance_UIBP:RefreshRedDotInfo()
  if not self.bSelf then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_RedDot, false, false)
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RefreshRedDotInfo, not Self")
    return
  end
  local logic_home_entrance_red_dot = require("client.slua.logic.home.Lobby.logic_home_entrance_red_dot")
  self.redDotInfo = logic_home_entrance_red_dot.GetHomeEntranceRedDotInfo()
  log_tree(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RefreshRedDotInfo", self.redDotInfo)
  if self.redDotInfo and self.redDotInfo.iconPath then
    self:SetTexture(self.UIRoot.Image_RedDot, self.redDotInfo.iconPath)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_RedDot, true, false)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_RedDot, false, false)
  end
end
function Lobby_Home_Door_Entrance_UIBP:RequestHomePKData(uid)
  if self.hasReq then
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RequestHomePKData, hasReq")
    return
  end
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RequestHomePKData")
  self.hasReq = true
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:ReqGetActConfigTable()
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  local logic_popular_home_pk_util = require("client.slua.logic.popular_home_pk.logic_popular_home_pk_util")
  local actState = logic_popular_home_pk_util.GetActState()
  if actState == PopularHomePKMacros.ENUM_STATE.CLOSE then
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RequestHomePKData, actState is close")
  elseif not logic_popular_home_pk:IsHomePkDataValid(tonumber(uid), 2) then
    logic_popular_home_pk:RequestGetHomePKData(tonumber(uid))
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:RequestHomePKData not valid pk data ")
  end
end
function Lobby_Home_Door_Entrance_UIBP:UpdateTips()
  if self.refreshTimer then
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:UpdateTips, delay 1s")
    return
  end
  self.refreshTimer = self:AddGameTimer(1, false, function()
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:UpdateTips CreateTips")
    if self and slua.isValid(self.UIRoot) then
      self:CreateTips()
      self.refreshTimer = nil
    end
  end)
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:UpdateTips AddTimerOnce", self, self.refreshTimer)
end
function Lobby_Home_Door_Entrance_UIBP:CloseHomeCommonTipsUI()
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:CloseHomeCommonTipsUI")
  if self.homeCommonTipsUI then
    self.homeCommonTipsUI:CloseSelf()
    self.homeCommonTipsUI = nil
  end
end
function Lobby_Home_Door_Entrance_UIBP:CloseHomePKUI()
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:CloseHomePKUI")
  if self.homePKUI then
    self.homePKUI:CloseSelf()
    self.homePKUI = nil
  end
end
function Lobby_Home_Door_Entrance_UIBP:CloseAllTipsUI()
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:CloseAllTipsUI")
  if self.homePKUI then
    self.homePKUI:CloseSelf()
    self.homePKUI = nil
  end
  if self.homeCommonTipsUI then
    self.homeCommonTipsUI:CloseSelf()
    self.homeCommonTipsUI = nil
  end
end
function Lobby_Home_Door_Entrance_UIBP:CreateTips()
  local logic_home_entrance_tips = require("client.slua.logic.home.Lobby.logic_home_entrance_tips")
  self.curTipsType = logic_home_entrance_tips.GetTipsInfo(self.uid)
  log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:CreateTips curTipsType", self.curTipsType)
  local logic_lobby_home_entry_item = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_lobby_home_entry_item)
  if self.curTipsType and self.curTipsType == logic_lobby_home_entry_item.eRedDotModule.homePkRedDot then
  elseif not self.bSelf then
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:CreateTips not self")
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Entry, false)
    return
  end
  if self.curTipsType then
    self.UIRoot.WidgetSwitcher_tips:SetActiveWidgetIndex(1)
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Entry, true)
    if self.curTipsType == logic_lobby_home_entry_item.eRedDotModule.homePkRedDot then
      self:CloseHomeCommonTipsUI()
      if not self.homePKUI then
        self.homePKUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_tips, UIManager.UI_Config.Lobby_Home_PK_UIBP, self.uid)
      end
    else
      self:CloseHomePKUI()
      if self.curTipsType then
        if not self.homeCommonTipsUI then
          self.homeCommonTipsUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_tips, UIManager.UI_Config.Lobby_Home_Entrance_Tips_Item, self.curTipsType)
        else
          self.homeCommonTipsUI:UpdateHomeCommonTips(self.curTipsType)
        end
      end
    end
  else
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Entry, true)
    self.UIRoot.WidgetSwitcher_tips:SetActiveWidgetIndex(0)
    log(bWriteLog and "Lobby_Home_Door_Entrance_UIBP:CreateTips no tips11")
    self:CloseAllTipsUI()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Home_Door_Entrance_UIBP = class(ui_base, nil, Lobby_Home_Door_Entrance_UIBP)
return CLobby_Home_Door_Entrance_UIBP