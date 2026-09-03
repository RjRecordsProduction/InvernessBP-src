local ModeSelection_Main_UIBP = {}
require("client.slua.umg.ModeSelection.ModeSelection_Main_UIBP_FlashTeam")(ModeSelection_Main_UIBP)
local ENUM_MENU_TYPE = {
  VIEW = 1,
  MENU = 2,
  SINGLE = 3
}
local GetSpecialMenuData = function(menu_id)
  local config_arena = require("client.slua.logic.arena.config_arena")
  local menuConfig = {
    [120] = {
      uiConfig = UIManager.UI_Config.item_peak_mode_selection_main,
      bgPath = "/Game/Mod/Lobby/Split/MatchSelectMap/450/ModeSelection_New/BG/ModeSelection_Image_BG03.ModeSelection_Image_BG03",
      showBGMask = true,
      root = "CanvasPanel_PeakGame"
    },
    [config_arena.ModeMenuId] = {
      uiConfig = UIManager.UI_Config.ModeSelection_Map_Team_Item,
      bgPath = "/Game/Mod/Lobby/Split/MatchSelectMap/450/ModeSelection_New/BG/ModeSelection_Image_BG06.ModeSelection_Image_BG06",
      showBGMask = false,
      root = "CanvasPanel_PeakGame",
      checkTabFunc = function()
        local ArenaSystem = require("client.slua.logic.arena.logic_arena")
        return ArenaSystem.IsInTargetSeasonShow()
      end
    },
    [270] = {
      uiConfig = UIManager.UI_Config.ModeSelection_Map_Asymmetric_Item,
      bgPath = "/Game/Mod/Lobby/Split/MatchSelectMap/450/ModeSelection_New/BG/ModeSelection_Image_BG06.ModeSelection_Image_BG06",
      showBGMask = true,
      root = "CanvasPanel_T"
    },
    [260] = {
      uiConfig = UIManager.UI_Config.ModeSelection_Map_Subway_Item,
      bgPath = "/Game/Mod/Lobby/Split/MatchSelectMap/450/ModeSelection_New/BG/ModeSelection_Image_BG09.ModeSelection_Image_BG09",
      showBGMask = true,
      root = "CanvasPanel_T"
    }
  }
  return menuConfig[menu_id]
end
local firstInModeSelectionUI = false
local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
function ModeSelection_Main_UIBP:ctor(selfType, url_params)
  self.ChildItemList = {}
  self.topMenuId = nil
  self.secMenuId = nil
  self.menuAlphaType = 0
  self.recommendedKeywords = {}
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.menu_info = logic_mode_selection:GetMenuInfo() or {}
  self.view_dict = logic_mode_selection:GetViewDictionary() or {}
  self.filter_info = logic_mode_selection:GetFilterInfo()
  self.mode_id, self.view_id, self.view_ids = logic_mode_selection:GetCurSelectInfo()
  self.bOnlyScroll = false
  if url_params then
    log_tree(bWriteLog and "[v_yibxu] share back ModeSelection_Main_UIBP:ctor  url_params = ", url_params)
  end
  if url_params and url_params.onlyScroll and tonumber(url_params.onlyScroll) == 1 then
    self.bOnlyScroll = true
  end
  if url_params and url_params.viewId and not self.bOnlyScroll then
    self.view_id = tonumber(url_params.viewId)
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    mode_selection_macro.jumpUrlViewId = self.view_id
    self.view_ids = {
      self.view_id
    }
  end
  self.scrollId = self.view_id
  if self.bOnlyScroll and url_params and url_params.viewId then
    self.scrollId = tonumber(url_params.viewId)
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    mode_selection_macro.scrollViewId = self.scrollId
  end
  if url_params and url_params.menuList then
    local StringUtil = require("common.string_util")
    self.menu_list = StringUtil.Split(url_params.menuList, "|")
    for k, v in pairs(self.menu_list) do
      self.menu_list[k] = tonumber(v)
    end
  else
    self.menu_list = logic_mode_selection:GetMenuListByViewID(self.view_id)
  end
  self.UGCNotPlayItemAnim = url_params and url_params.UGCNotPlayItemAnim
  self.creationTab = url_params and url_params.creationTab
  self.openUgcSubTabID = url_params and url_params.openUgcSubTabID
  self.openUgcInnerTabID = url_params and url_params.openUgcInnerTabID
  self.ugcModId = url_params and url_params.modId
  self.ugcModThemeID = url_params and url_params.modThemeID
  self.UGCDetailUIData = url_params and url_params.UGCDetailUIData
  self.bHasOverlayUI = self.UGCDetailUIData ~= nil
  self.homeRankFilterIndex = url_params and url_params.homeRankFilterIndex
  self.homeSubTabID = url_params and url_params.homeSubTabID
  self.src = url_params and url_params.src
  self.shareuid = url_params and url_params.uid
  self.UGCMainSubTabUI = nil
  self.openthemeID = url_params and tonumber(url_params.openthemeID)
  self.openauthorID = url_params and tonumber(url_params.openauthorID)
  self.defaultTopMenuId = url_params and url_params.defaultTopMenuId
  firstInModeSelectionUI = true
  self.bShowChangeModeBtn = url_params and url_params.bShowChangeModeBtn
  self.SearchInfo = url_params and url_params.SearchInfo
  self.return_url = url_params and url_params.return_url
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  self.ForumBtnCfg = {
    [1] = {
      NameKey = 69997,
      OpenFun = function()
        local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
        if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
          return false
        end
        return true
      end,
      Pic = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_Icon_CreationSquare_png.UGC_Icon_CreationSquare_png",
      TlogFun = function()
        local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
        local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
        Logic_UGC_TLog:ReportCommercialClick({
          source = UGCMacros.Enum_UGC_CommercialClick_Type.CreationSquare
        })
      end,
      BtnFun = function()
        self:OnButton_CreationSquare()
      end
    },
    [2] = {
      NameKey = 8800195,
      OpenFun = function()
        local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
        if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
          return false
        end
        return true
      end,
      Pic = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_Icon_Forum_png.UGC_Icon_Forum_png",
      TlogFun = function()
        local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
        local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
        Logic_UGC_TLog:ReportCommercialClick({
          source = UGCMacros.Enum_UGC_CommercialClick_Type.CreatorForum
        })
      end,
      BtnFun = function()
        self:OnClickWOWCreatorForum()
      end
    },
    [3] = {
      NameKey = 83201,
      OpenFun = function()
        return true
      end,
      Pic = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Setting_png.Common_Icon_Setting_png",
      TlogFun = function()
        local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
        local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
        Logic_UGC_TLog:ReportCommercialClick({
          source = UGCMacros.Enum_UGC_CommercialClick_Type.Setting
        })
      end,
      BtnFun = function()
        self:OnClickBtnUGCSetting()
      end
    },
    [4] = {
      NameKey = 993095,
      OpenFun = function()
        local bShowCommercialization = LobbySystem.CheckOpen(BP_ENUM_UGCCOMMERCIALIZATION_PASS_SWITCH)
        return bShowCommercialization
      end,
      Pic = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_DressUp_Select_png.Common_Tab_DressUp_Select_png",
      TlogFun = function()
        local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
        local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
        Logic_UGC_TLog:ReportCommercialClick({
          source = UGCMacros.Enum_UGC_CommercialClick_Type.UGCWarehouse
        })
      end,
      BtnFun = function()
        self:OnClickUGCWarehouse()
      end
    },
    [5] = {
      NameKey = 117068,
      OpenFun = function()
        local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
        if PublishRegionMacros.IsFITVersion() then
          return false
        end
        return true
      end,
      Pic = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_Icon_RoomName_png.UGC_Icon_RoomName_png",
      TlogFun = function()
        local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
        local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
        Logic_UGC_TLog:ReportCommercialClick({
          source = UGCMacros.Enum_UGC_CommercialClick_Type.Room
        })
      end,
      BtnFun = function()
        self:OnClickBtnUGCRoom()
      end
    },
    [6] = {
      NameKey = 87200,
      OpenFun = function()
        local ugc_hall_util = require("client.slua.logic.ugc.Hall.ugc_hall_util")
        local bVisible = ugc_hall_util.IsAppreciationGroupVisible(false)
        return bVisible
      end,
      Pic = "/Game/Mod/Lobby/Base/WoW/Texture/Ugc_Icon_AppreciationGroup_Brand.Ugc_Icon_AppreciationGroup_Brand",
      TlogFun = function()
        local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
        local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
        Logic_UGC_TLog:ReportCommercialClick({
          source = UGCMacros.Enum_UGC_CommercialClick_Type.CuratorTeam
        })
      end,
      BtnFun = function()
        self:OnButton_AppreciationGroupClick()
      end
    }
  }
  self.MoreBtnCfg = {
    [1] = {
      NameKey = 9413,
      OpenFun = function()
        return true
      end,
      Pic = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Setting_png.Common_Icon_Setting_png",
      TlogFun = function()
        local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
        local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
        Logic_UGC_TLog:ReportCommercialClick({
          source = UGCMacros.Enum_UGC_CommercialClick_Type.Setting
        })
      end,
      BtnFun = function()
        self:OnClickBtnUGCSetting()
      end
    }
  }
  self.SeasonClock = nil
  self.Button_Arena_Type = {FriendlyPoint = 1, Arena = 2}
  self.show_Button_Arena = {
    [110] = self.Button_Arena_Type.FriendlyPoint,
    [210] = self.Button_Arena_Type.FriendlyPoint,
    [220] = self.Button_Arena_Type.Arena,
    [130] = self.Button_Arena_Type.Arena
  }
  self.TimerTips = nil
  local RoomListSystem = require("client.slua.logic.room.logic_room_list")
  self.canShowRoomList = RoomListSystem.CanShowUI()
end
function ModeSelection_Main_UIBP:OnInitialize()
  ModeSelection_Main_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  self.MenuAlphaScroll = self:InitScrollBox(self.UIRoot.LoopScrollBox_Menu1)
  self.MenuBetaScroll = self:InitScrollBox(self.UIRoot.LoopScrollBox_Menu2)
  self.MenuBetaScroll2 = self:InitScrollBox(self.UIRoot.LoopScrollBox_Menu2_2)
  local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
  Logic_UGC_TLog:UpdateRequestId()
  self.UIRoot.Image_ForumRedPoint:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
  logic_ugc_inventory:InventoryReq()
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  logic_theme_system:send_get_magic_tree_stat_req()
  self:CheckNeedShowUGCModeGuide()
  self:SetWidgetVisible(self.UIRoot.Image_SocialIsland_Guide_New, false)
  self:SetWidgetVisible(self.UIRoot.Button_UGCWarehouse, false, false)
  self:SetWidgetVisible(self.UIRoot.Button_AppreciationGroup, false, false)
  self:SetWidgetVisible(self.UIRoot.Button_UGCRoom, false, false)
  self:UpdateWowCoin()
end
function ModeSelection_Main_UIBP:RegistEvents()
  if not self or not self.UIRoot then
    return
  end
  ModeSelection_Main_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnButton_CloseClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ChangeMode, self.OnButton_ChangeModeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SocialIsland, self.OnButton_SocialIslandClick, self)
  if self.UIRoot.Button_PHSocialIsland then
    self:AddOnClickedEventByControl(self.UIRoot.Button_PHSocialIsland, self.OnButton_PHSocialIslandClick, self)
  end
  self:AddOnClickedEventByControl(self.UIRoot.Button_Train, self.OnButton_TrainClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Room, self.OnButton_RoomClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Setting, self.OnButton_SettingClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Ratting, self.OnButton_RattingClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Arena, self.OnButton_ArenaClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_MatchSetting, self.OnButton_MatchSettingClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SegmentLimit, self.OnButton_SegmentLimitClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_UGCCommunity, self.OnButton_UGCCommunity, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Rank, self.OnButton_RankClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Task, self.OnButton_TaskClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_AppreciationGroup, self.OnButton_AppreciationGroupClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CreationSquare, self.OnButton_CreationSquare, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CWOW, self.OnClickButtonCWoW, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_UGCRoom, self.OnClickBtnUGCRoom, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_WorkplaceSquare, self.OnClickBtnWorkplaceSquare, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_UGCSetting, self.OnClickBtnUGCSetting, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_UGCForum, self.OnClickUGCForum, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Activity, self.OnClickButtonActivity, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_TeamUp, self.OnClickTeamUp, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Open, self.OnOpenSeasonUI, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_WoWPass, self.OnClickWoWPass, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tips, self.OnClickForumBubbleTips, self)
  self.MenuAlphaScroll:SetRefreshItemCallback(self.OnMenuAlphaItemRefresh, self)
  self.MenuAlphaScroll:AddItemWidgetChildEvent("Button_Item", "OnClicked", self.OnMenuAlphaButtonClick, self)
  self.MenuBetaScroll:SetRefreshItemCallback(self.OnMenuBetaItemRefresh, self)
  self.MenuBetaScroll:AddItemWidgetChildEvent("Button_Tab", "OnClicked", self.OnMenuBetaButtonClick, self)
  self.MenuBetaScroll2:SetRefreshItemCallback(self.OnMenuBetaItemRefresh, self)
  self.MenuBetaScroll2:AddItemWidgetChildEvent("Button_Tab", "OnClicked", self.OnMenuBetaButtonClick, self)
  self:AddControlEventByControl(self.UIRoot.LoopScrollBox_Menu2, "OnUserScrolled", self.OnUserScrolled, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_FILTER_CHANGE, self.OnSyncFilterInfo, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_VIEW_CLICK, self.OnViewItemClick, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, self.OnButton_CloseClick, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_UPDATE, self.RefreshRankInfo, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_JSON_POSTPROCESS, self.UpdateSocialIslandAndTrain, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_REFRESH_SOCIALISLAND, self.UpdateSocialIslandAndTrain, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_SYNC_MATCH_PRESELECT, self.UpdateFilterAnimAndTips, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_ALL_MODE_TEAMUP_SEGMENT_LIMIT_DATA, self.RefreshSegmentLimit, self)
  self:AddCommonEvent(EVENTTYPE_CRAZYWEEKEND, EVENTID_CRAZYWEEKEND_ACT_UPDATE, self.RefreshSegmentLimit, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, self.SeasonChange, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_MAP, self.OnChangeCurrModeMap, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_GET_NEWBIE_UPGRADE_DATA_RSP, self.OnGetNewbieUpgradeDataRsp, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_REFRESH_NEWBIE_UPGRADE_PROGRESS_AWARD, self.OnRefreshNewbieUpgradeProgressAward, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_NEWBIE_UPGRADE_SYNC_DATA, self.OnNewbieUpgradeSyncData, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_UGCCOMMUNITY_REDPOINT, self.OnUpdateCommunityRedPoint, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_POST_MENU_ALPHA_SWITCH, self.OnPostMenuAlphaSwitch, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_VIEW_ITEM_ANIM_APPEAR_END, self.OnViewItemAnimAppearEnd, self)
  self:AddOnAnimationFinishedEvent("Animation_Appear", self.AppearAnimCallback, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_COMMUNITY_ENTRY_DISCUSS_POP, self.OnUGCCommunityEntryDiscussPop, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_REFRESH_MINEMAINTAB, self.RefreshMenuBetaScroll, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_REFRESH_HOMEREDDOT, self.RefreshHomeRedDot, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_REFRESH_NTAB, self.ChangePageToRefreshRedDot, self)
  self:AddCommonEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_INFO_UPDATE, self.OnPeakTimeRsp, self)
  self:AddCommonEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_SEASON_INFO, self.OnPeakTimeRsp, self)
  self:AddCommonEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_TIME_UPDATE, self.OnPeakTimeRsp, self)
  self:AddCommonEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_RATING_NOTIFY, self.OnPeakTimeRsp, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_NEWBIE_UPGRADE_VIEW_AWARD, self.OnNewbieUpgradeViewAward, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_TASK_REDDOT_UPDATE, self.RefreshUGCTaskReddot, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_DETAIL_MAIN_PANEL_CLOSE, self.OnCleanJumpBack, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_TOPHIDEPANEL, self.OnPlayedSlide, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_RESETTOPPANEL, self.OnResetTopPanel, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_MINE_SUB_PANEL_CLOSE, self.OnCleanJumpBack, self)
  self:AddCommonEvent(EVENTTYPE_WEAPONSTRENGTH, EVENTID_SEASON_WEAPONSTRENGTH_DATA_RSP, self.OnWeaponStrengthDataRsp, self)
  self:AddCommonEvent(EVENTTYPE_WEAPONSTRENGTH, EVENTID_SEASON_WEAPONSTRENGTH_WEEKLY_AWARD, self.OnWeaponStrengthWeeklyAward, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_RED_DOT_STATE_CHANGE, self.RefreshWOWPassEntry, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_BUY_PASS_RSP, self.RefreshWOWPassBuyState, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_CREATOR_FORUM_BUBBLETIPS, self.OnPandoraForumTipsDataResponse, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_INVENTORY_SELECT_TAB, self.CheckUGCWarehousePoint, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_INVENTORY_SET_NEWITEM, self.CheckUGCWarehousePoint, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_APPRECIATIONGROUP_INFO, self.OnGetAppreciationGroupInfo, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_APPRECIATION_TASK_SYNC, self.RefreshAppreciationGroupRedDot, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_APPRECIATIONGROUP_EXIT, self.RefreshAppreciationGroupRedDot, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_ALBUM_THEME_REFRESH, self.ShowAlbumThemeUI, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREATE_TEAM, self.OnJoinTeamEvent, self)
  if self.UIRoot.Button_CurrencyInfo1 then
    self:AddOnClickedEventByControl(self.UIRoot.Button_CurrencyInfo1, self.CoinIconClick, self)
  end
  if self.UIRoot.Button_Currency then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Currency, self.CoinAddClick, self)
  end
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_UGC_ADVANCED_CRYSTAL_UPDATE, self.OnUGCAdvancedCrystalUpdate, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_LANGUAGE, self.RefreshLanMatchImage, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_RECOM_RSP, self.OnRecomInfoRsp, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_MEMBER_RSP, self.OnRecomMemberRsp, self)
end
function ModeSelection_Main_UIBP:OnPostInitialize()
  ModeSelection_Main_UIBP.__super.OnPostInitialize(self)
  self.UIRoot.TextBlock_ArenaBtn:SetText(LocUtil.LocalizeResFormat(7947))
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, true, true)
  self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(0)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, false, false)
  self:RefreshLanMatchImage()
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  if logic_newbie_mode_selection:CheckOpen() then
    local NewbieModeHandler = require("client.network.Protocol.NewbieModeHandler")
    NewbieModeHandler.send_get_newbie_upgrade_data_req()
  end
  local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
  LogicTeamUpLimit.send_get_all_pre_team_limit_req()
  local LogicRatingProtectActivity = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_activity")
  LogicRatingProtectActivity.GetActModeGroupCfg()
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.Enter()
  self:OnSyncFilterInfo(nil, nil, self.filter_info)
  self.menus = {}
  if not self.bShowChangeModeBtn then
    local TableUtil = require("common.table_util")
    self.menus = TableUtil.CopyTable(self.menu_info.sub_menus)
    if not self.menus then
      return
    end
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local ugcEntry = Config_UGC.GetEntryData()
  if ugcEntry and Config_UGC.IsUGCReleased() then
    table.insert(self.menus, ugcEntry)
  end
  self:RefreshTopMenuId(self.menus)
  self.MenuAlphaScroll:SetData(self.menus)
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_Appear, 0, 1, 0, 1)
  self:AddTimerOnce(0, function()
    self:UpdateSocialIslandAndTrain()
  end)
  self:OnRefreshSettingBtn(false, false)
  self:OnRefreshRoomBtn(false, false)
  self:OnRefreshFourmAndMoreBtn(false, false)
  self:OnRefreshUGCWarehouseBtn(false, false)
  self:OnRefreshButtonWoWPass(false, false)
  self.alphaClickCount = 0
  self.alphaMenuIndex = 0
  self.betaMenuIndex = 0
  local ArenaSystem = require("client.slua.logic.arena.logic_arena")
  if ArenaSystem.IsInTargetSeasonShow() then
    ArenaSystem.SendGetArenaSeasonPrizeReq()
  end
  local LogicPeakGameHomepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameHomepage)
  LogicPeakGameHomepage:RequestHomepageShowData()
  self:SaveLocalRedDotFileTb()
  self:RefreshUGCTaskReddot()
  local data = self.menus[3] or nil
  if data and not self:IsLevelLock(data.level_limit, data.id) then
    local UGCHandler = require("client.network.Protocol.UGCHandler")
    UGCHandler.send_ugc_get_review_panel_info_req()
  end
  self.UIRoot.WidgetSwitcher_Close:SetActiveWidgetIndex(self.bShowChangeModeBtn and 1 or 0)
end
function ModeSelection_Main_UIBP:RefreshTopMenuId(menus)
  print(bWriteLog and "ModeSelection_Main_UIBP:RefreshTopMenuId")
  self.topMenuId = nil
  if self.defaultTopMenuId then
    for k, v in pairs(menus) do
      if v.id == self.defaultTopMenuId then
        if not self:IsLevelLock(v.level_limit, v.id) then
          self.topMenuId = self.defaultTopMenuId
          return
        else
          break
        end
      end
    end
  end
  local hasFind = false
  if self.menu_list then
    local topMenuId = self.menu_list[#self.menu_list]
    if topMenuId then
      for k, v in pairs(menus) do
        if v.id == topMenuId then
          if not self:IsLevelLock(v.level_limit, v.id) then
            hasFind = true
            self.topMenuId = v.id
            break
          else
            ShowNotice(LocUtil.LocalizeResFormat(31028, v.level_limit))
          end
        end
      end
    end
  end
  if not hasFind then
    for k, v in pairs(self.menu_info.sub_menus or {}) do
      if not self:IsLevelLock(v.level_limit, v.id) then
        self.topMenuId = v.id
        break
      end
    end
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleRank() then
    log(bWriteLog and "ModeSelection_Main_UIBP IsRestrictBatlleRank")
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    if self.topMenuId >= mode_selection_macro.Enum_TabID.RankClassic and self.topMenuId < mode_selection_macro.Enum_TabID.MatchAlpha then
      self.topMenuId = 200
    end
  end
end
function ModeSelection_Main_UIBP:SaveLocalRedDotFileTb()
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCFirstSquareGetIn) or {}
  if Data and not Data.FirstSquareGetIn then
    self:SetWidgetVisible(self.UIRoot.Image_34, true)
  else
    self:SetWidgetVisible(self.UIRoot.Image_34, false)
  end
end
function ModeSelection_Main_UIBP:OnClose()
  for k, v in pairs(self.ChildItemList) do
    v:CloseSelf()
  end
  self.ChildItemList = {}
  self.UGCMainSubTabUI = nil
  self:CloseGuideThemeViewUI()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_RESETTOPPANEL)
  ModeSelection_Main_UIBP.__super.OnClose(self)
  UIManager.CloseUI(UIManager.UI_Config.mode_selection_filter)
  UIManager.CloseUI(UIManager.UI_Config.Setting_ChangeServer)
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyCamera(true)
  self.SeasonClock = nil
  self:HideForumBubbleTips()
  if UIManager.IsUIShow(UIManager.UI_Config.CommonTextTips_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.CommonTextTips_UIBP)
  end
  self:OnClearAlbumThemeTimer()
end
function ModeSelection_Main_UIBP:AppearAnimCallback()
  log(bWriteLog and "[ModeSelection_Main_UIBP] AppearAnimCallback")
  self:StartUGCModeGuide()
  self:StartLevelUnlockGuide()
  self:AddTimerOnce(0, function()
    self:ShowWeaponStrengthWeeklyAward()
    local logic_weapon_strength = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength)
    logic_weapon_strength:send_get_weapon_power_data_req()
    for i, v in ipairs(self.menus) do
      if v.id == mode_selection_macro.Enum_TabID.UGC and not self:IsLevelLock(v.level_limit, v.id) then
        log(bWriteLog and "ModeSelection_Main_UIBP:OnPostInitialize id: " .. tostring(v.id) .. " not locked")
        local logic_ugc_album_theme = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_album_theme)
        logic_ugc_album_theme:send_ugc_get_all_spec_theme_list_req()
      end
    end
  end)
end
function ModeSelection_Main_UIBP:CheckNeedShowUGCModeGuide()
  self._needShowUGCModeGuide = false
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local level = growthprojectMgrB.GetUGCModeSelectionHandGuide()
  log(bWriteLog and "ModeSelection_Main_UIBP:CheckNeedShowUGCModeGuide level = " .. tostring(level) .. " DataMgr.roleData.level = " .. tostring(DataMgr.roleData.level))
  if level > DataMgr.roleData.level then
    return
  end
  local GrowthprojMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local bCheckEnterWoWNewbieGuide = GrowthprojMgrB.CheckEnterWoWNewbieGuide()
  log(bWriteLog and "ModeSelection_Main_UIBP:CheckNeedShowUGCModeGuide bCheckEnterWoWNewbieGuide = " .. tostring(bCheckEnterWoWNewbieGuide))
  if bCheckEnterWoWNewbieGuide then
    return
  end
  self._needShowUGCModeGuide = true
end
function ModeSelection_Main_UIBP:StartUGCModeGuide()
  if not self._needShowUGCModeGuide then
    log(bWriteLog and "ModeSelection_Main_UIBP:StartUGCModeGuide not need show guide")
    return
  end
  self:AddTimerOnce(0.1, function()
    if slua.isValid(self.UIRoot) then
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_OPENDED_UI_GUIDE, "OpenModeSelection")
    end
  end)
end
function ModeSelection_Main_UIBP:StartLevelUnlockGuide()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickMain(UIManager.UI_Config.mode_selection_main)
end
function ModeSelection_Main_UIBP:SetBetaMenuData(menuData)
  self.secMenuId = nil
  local hasFind = false
  if self.menu_list and firstInModeSelectionUI then
    local secMenuId = self.menu_list[#self.menu_list - 1]
    if secMenuId then
      for k, v in pairs(menuData) do
        if v.id == secMenuId and v.level_limit <= DataMgr.roleData.level and self:IsPeakOpen(v.id) and self:IsArenaRankOpen(v.id) then
          hasFind = true
          self.secMenuId = v.id
          break
        end
      end
    end
  end
  if not hasFind then
    for k, v in pairs(menuData) do
      if v.level_limit <= DataMgr.roleData.level then
        self.secMenuId = v.id
        break
      end
    end
  end
  if not self.secMenuId then
    for k, v in pairs(menuData) do
      self.secMenuId = v.id
      break
    end
  end
  log(bWriteLog and "ModeSelection_Main_UIBP:SetBetaMenuData self.secMenuId = " .. tostring(self.secMenuId))
  if self.SecMenuTimer then
    self:RemoveTimer(self.SecMenuTimer)
  end
  self.SecMenuTimer = self:AddTimer(0, function()
    self.MenuBetaScroll:SetData(menuData)
    self.MenuBetaScroll2:SetData(menuData)
    self:CheckShowTxmissionNewTips()
    self:OnUserScrolled()
    self.MenuBetaScroll:SetItemOffset(0)
    self.MenuBetaScroll2:SetItemOffset(0)
  end)
end
function ModeSelection_Main_UIBP:CheckShowTxmissionNewTips()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local viewId = mode_selection_macro.C_Xmission_ViewID
  if not logic_mode_selection:CheckSubViewIsOpen(viewId) or not logic_mode_selection:IsSubViewNew(viewId) then
    log(bWriteLog and "[v_wllwu] ModeSelection_Main_UIBP:CheckShowTxmissionNewTips return 1")
    return
  end
  if not self.topMenuId or self.topMenuId ~= mode_selection_macro.Enum_TabID.MatchAlpha then
    log(bWriteLog and "[v_wllwu] ModeSelection_Main_UIBP:CheckShowTxmissionNewTips return 3")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  if cfg.xmissionNewTips and cfg.xmissionNewTips.showCount and cfg.xmissionNewTips.showCount >= mode_selection_macro.C_XmissionNewTips_MaxCount then
    log(bWriteLog and "[v_wllwu] ModeSelection_Main_UIBP:CheckShowTxmissionNewTips return 2")
    return
  end
  self:ShowTxmissionNewTips()
  cfg.xmissionNewTips = cfg.xmissionNewTips or {}
  cfg.xmissionNewTips.showCount = (cfg.xmissionNewTips.showCount or 0) + 1
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
end
function ModeSelection_Main_UIBP:SelectMenuBetaScrollItemToCenter(index)
  index = index or 1
  local scrollRoot = self.UIRoot.LoopScrollBox_Menu2
  local viewSize = scrollRoot:GetViewSize().X
  local offset = (index - 1) * scrollRoot.ItemSize - viewSize / 2 + scrollRoot.ItemSize / 2
  local maxOffset = scrollRoot:GetScrollEndOffset()
  if offset < 0 then
    offset = 0
  elseif maxOffset < offset then
    offset = maxOffset
  end
  self.MenuBetaScroll:PlayAnimToTarget(offset, 0.3, 1)
  self.MenuBetaScroll2:PlayAnimToTarget(offset, 0.3, 1)
end
function ModeSelection_Main_UIBP:ShowTxmissionNewTips()
  local mapInfo
  local xmissionMapList = CDataTable.GetTable("TxMissionMap")
  for _, v in pairs(xmissionMapList) do
    if v.Notice and v.Notice == 1 and (not mapInfo or mapInfo.MapID < v.MapID) then
      mapInfo = v
    end
  end
  local mapName = ""
  if mapInfo then
    mapName = mapInfo.Name
  end
  local str = LocUtil.LocalizeResFormat(65365, mapName)
  self:CreateChildWindow(self.UIRoot.CanvasPanel_NodeTips, UIManager.UI_Config.Common_Tips_Top_UIBP, str)
  self:AddTimerOnce(0.1, function()
    local menuList = self.MenuBetaScroll:GetSetData()
    local widget
    for i, v in ipairs(menuList) do
      if v.id == mode_selection_macro.Enum_TabID.MatchTxMission then
        widget = self.MenuBetaScroll:GetIndexOfWidget(i)
        break
      end
    end
    if widget then
      local tool_widget_align = require("client.common.tool_widget_align")
      tool_widget_align.AlignWidget(self.UIRoot.CanvasPanel_NodeTips, self.UIRoot.CanvasPanel_Menu, widget, FVector2D(0, 20))
    end
  end)
end
function ModeSelection_Main_UIBP:HideTxmissionNewTips()
  if UIManager.IsUIShow(UIManager.UI_Config.Common_Tips_Top_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Common_Tips_Top_UIBP)
  end
end
local COLUMN_SHOW_INTERVAL = 0.125
function ModeSelection_Main_UIBP:SetViewData(data)
  if self.menuAlphaType == ENUM_MENU_TYPE.SINGLE then
    log(bWriteLog and "[COLE]ModeSelection_Main_UIBP:SetViewData return ugc mode")
    return
  end
  if self._refreshViewTimer then
    self:RemoveTimer(self._refreshViewTimer)
    self._refreshViewTimer = nil
  end
  local viewData = data.sub_views
  for k, v in pairs(self.ChildItemList) do
    v:Close()
  end
  self.ChildItemList = {}
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local columnIndex = 0
  self.viewMenuData = data
  local SetBigItem = function(itemData)
    if not self then
      return
    end
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, true, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, false, false)
    local specialMenuData = GetSpecialMenuData(itemData.menu_id)
    local item
    if itemData.id == 20000 or itemData.id == 20010 then
      self:SetTexture(self.UIRoot.Image_BG02, specialMenuData.bgPath)
      self:SetWidgetVisible(self.UIRoot.Image_BG02_Mask, specialMenuData.showBGMask, false)
      self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, false)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, true)
      item = self:CreateChildWindow(self.UIRoot[specialMenuData.root], specialMenuData.uiConfig, itemData, self.filter_info, columnIndex * COLUMN_SHOW_INTERVAL)
    elseif specialMenuData then
      self:SetTexture(self.UIRoot.Image_BG02, specialMenuData.bgPath)
      self:SetWidgetVisible(self.UIRoot.Image_BG02_Mask, specialMenuData.showBGMask, false)
      self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, self.alphaMenuIndex ~= 1, false)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, self.alphaMenuIndex == 1, true)
      item = self:CreateChildWindow(self.UIRoot[specialMenuData.root], specialMenuData.uiConfig, itemData, self.filter_info, columnIndex * COLUMN_SHOW_INTERVAL)
    elseif itemData.group_type == mode_selection_macro.Enum_Group_Type.Multi then
      item = self:CreateChildWindow(self.UIRoot.ModeSelection_Main_Map_UIBP.WrapBox_Big, UIManager.UI_Config.item_multi_big_mode_selection_main, itemData, self.filter_info, columnIndex * COLUMN_SHOW_INTERVAL)
    else
      item = self:CreateChildWindow(self.UIRoot.ModeSelection_Main_Map_UIBP.WrapBox_Big, UIManager.UI_Config.item_big_mode_selection_main, itemData, self.filter_info, columnIndex * COLUMN_SHOW_INTERVAL)
    end
    table.insert(self.ChildItemList, item)
    local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
    logic_ugc_newbie_guide:OnUIOpened(self, "WrapBox_Big")
    columnIndex = columnIndex + 1
  end
  local SetSmallItem = function(itemData1, itemData2)
    if not self then
      return
    end
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, true, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, false, false)
    local item = self:CreateChildWindow(self.UIRoot.ModeSelection_Main_Map_UIBP.WrapBox_Small, UIManager.UI_Config.item_double_small_mode_selection_main, itemData1, itemData2, self.filter_info, columnIndex * COLUMN_SHOW_INTERVAL)
    table.insert(self.ChildItemList, item)
    columnIndex = columnIndex + 1
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local dataLength = #viewData
  local i = 1
  local viewIndex = 0
  local hasFind = false
  self._refreshViewTimer = self:AddTimerOnce(0, function()
    while i <= dataLength do
      local dataIndex = viewData[i]
      local isOpen, isPreview = logic_mode_selection:IsThemeOpen(self.view_dict[dataIndex], curTime, true)
      local isShow = isOpen or isPreview
      if isShow then
        log(bWriteLog and "zwl ModeSelection_Main_UIBP:SetViewData. show " .. tostring(dataIndex))
        local data1 = self.view_dict[dataIndex]
        if data1.id == self.scrollId then
          hasFind = true
        end
        if data1.show_type == "BIG" then
          SetBigItem(data1)
          if not hasFind then
            viewIndex = viewIndex + 1
          end
          i = i + 1
        else
          local j = i + 1
          local dataIndex2 = viewData[j]
          local data2
          if dataIndex2 then
            data2 = self.view_dict[dataIndex2]
            if data2 and data2.id == self.scrollId then
              hasFind = true
            end
            while j < dataLength and data2 and data2.show_type == "BIG" do
              SetBigItem(data2)
              if not hasFind then
                viewIndex = viewIndex + 1
              end
              j = j + 1
              dataIndex2 = viewData[j]
              data2 = self.view_dict[dataIndex2]
            end
          end
          SetSmallItem(data1, data2)
          if not hasFind then
            viewIndex = viewIndex + 1
          end
          i = j + 1
        end
      else
        i = i + 1
      end
    end
    log("ModeSelection_Main_UIBP:SetViewData data" .. data.menu_bg)
    if data.menu_bg and data.menu_bg ~= "" then
      self:SetTexture(self.UIRoot.Image_BgBasic, data.menu_bg)
    else
      self:SetTexture(self.UIRoot.Image_BgBasic, "/Game/Mod/Lobby/Base/MatchSelectMap/450/ModeSelection_New/BG/ModeSelection_Image_BG10.ModeSelection_Image_BG10")
    end
    self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(0)
    self:AddTimerOnce(0.1, function()
      if not hasFind then
        viewIndex = 0
      end
      local maxOffset = self.UIRoot.ScrollBox_Main:GetScrollEndOffset()
      self.UIRoot.ScrollBox_Main:SetScrollOffset(math.min(maxOffset, viewIndex * 320))
      if self.bOnlyScroll then
        local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
        logic_mode_selection:SetSelectView(self.scrollId, self.filter_info)
      end
      self.scrollId = nil
    end)
    self:ShowDownLoadTips()
    local item = self.view_dict[viewData[1]]
    local ModeSelection_Main_Segment = require("client.slua.umg.ModeSelection.ModeSelection_Main_Segment")
    ModeSelection_Main_Segment:SetVisible(self.UIRoot, item, self, ENUM_MENU_TYPE)
    self:SetFilterInfoByMenuData()
    self:RefreshNarutoBg()
  end)
end
function ModeSelection_Main_UIBP:RefreshNarutoBg(isUGC)
  if isUGC then
    self:RefreshNarutoColor(false)
    return
  end
  local viewData = self.viewMenuData and self.viewMenuData.sub_views
  if not viewData or #viewData == 0 then
    self:RefreshNarutoColor(false)
    return
  end
  local firstViewIndex = viewData[1]
  if not firstViewIndex then
    self:RefreshNarutoColor(false)
    return
  end
  local firstView = self.view_dict[firstViewIndex]
  if not firstView then
    self:RefreshNarutoColor(false)
    return
  end
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  if firstView.menu_id == mode_selection_macro.Enum_TabID.MatchTxMission then
    self:SetTexture(self.UIRoot.Image_BG02, logic_mode_utils.GetSubwayBgPath())
    self:SetWidgetVisible(self.UIRoot.Image_BG02_Mask, true, false)
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, false, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, true, true)
    self:RefreshNarutoColor(true)
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local themeData = logic_mode_selection:GetValidThemeData(firstView.id, true)
  if not themeData then
    self:RefreshNarutoColor(false)
    return
  end
  if not logic_mode_utils.IsNarutoView(firstView.id) and not logic_mode_utils.IsNarutoView(themeData.id) then
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, true, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, false, false)
    self:RefreshNarutoColor(false)
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local isSelect = logic_mode_selection:GetIsSelectTheme(firstView, themeData)
  if isSelect then
    log("ModeSelection_Main_UIBP:RefreshNarutoBg isSelect")
    self:SetTexture(self.UIRoot.Image_BG02, logic_mode_utils.GetNarutoBgPath())
    self:SetWidgetVisible(self.UIRoot.Image_BG02_Mask, true, false)
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, false, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, true, true)
    self:RefreshNarutoColor(true)
  else
    log("ModeSelection_Main_UIBP:RefreshNarutoBg not isSelect")
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, true, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, false, false)
    self:RefreshNarutoColor(false)
  end
end
function ModeSelection_Main_UIBP:RefreshNarutoColor(IsNaruto)
  local widgetNameList = {
    "Image_0",
    "TextBlock_0",
    "Image_9",
    "TextBlock_7",
    "Image_19",
    "TextBlock_9",
    "Image_188",
    "TextBlock_1",
    "Image_187",
    "TextBlock_2",
    "Image_80",
    "TextBlock_3",
    "UTRichTextBlock_RankScore",
    "TextBlock_SegmentLimit",
    "Image_26",
    "TextBlock_PeakSegName",
    "UTRichTextBlock_PeakScore",
    "Image_challengeIcon",
    "Image_81",
    "Image_Mode_PlayerCnt",
    "TextBlock_TeamCnt",
    "TextBlock_Fill",
    "Image_13",
    "Text_PerspectiveType",
    "Image_LanMatch",
    "Image_23",
    "Image_27",
    "Image_30",
    "Image_8",
    "Image_Time",
    "TextBlock_Time"
  }
  local colorIdx = IsNaruto and 1 or 0
  for _, widgetName in ipairs(widgetNameList) do
    local widget = self.UIRoot[widgetName]
    if widget and widget.SetActiveColorIndex then
      widget:SetActiveColorIndex(colorIdx)
    end
  end
  self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:ChangeRankInteralColor(IsNaruto and FSlateColor(FLinearColor(1, 1, 1, 0.7)) or FSlateColor(FLinearColor(0, 0, 0, 0.7)))
  self:SetTexture(self.UIRoot.Image_4, IsNaruto and "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_BG_Frame_1_Scene_png.Common_BG_Frame_1_Scene_png" or "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Huise_png.Common_Btn_Lv2_Huise_png")
  for widget, _ in pairs(self.MenuAlphaScroll._itemWidgetIndexMap) do
    if widget then
      self:SetAlphaWidgetByNaruto(widget, IsNaruto)
    end
  end
  self.UIRoot.WidgetSwitcher_TopTab:SetActiveWidgetIndex(IsNaruto and 1 or 0)
  if IsNaruto then
    self.MenuBetaScroll2:RefreshAllItems()
  else
    self.MenuBetaScroll:RefreshAllItems()
  end
  self:SetTexture(self.UIRoot.Image_3, IsNaruto and "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Closed_3_png.Common_Icon_Closed_3_png" or "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Closed_png.Common_Icon_Closed_png")
end
function ModeSelection_Main_UIBP:SetFilterInfoByMenuData()
  local menuData = self.viewMenuData
  local menuId = menuData.id
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  if not cfg.menuFilter then
    cfg.menuFilter = {}
  end
  local modeInfo = cfg.menuFilter[menuId]
  if not modeInfo then
    local viewId = menuData.sub_views[1]
    if not viewId then
      log_error("ModeSelection_Main_UIBP:SetFilterInfoByMenuData get nil view ID")
      return
    end
    local viewData = self.view_dict[viewId]
    if not viewData or not viewData.options then
      viewId = menuData.sub_views[2]
      viewData = self.view_dict[viewId]
      if not viewData or not viewData.options then
        log_error("ModeSelection_Main_UIBP:SetFilterInfoByMenuData first view has no options")
        return
      end
    end
    modeInfo = {}
    modeInfo.perspective = viewData.options.default_person
    modeInfo.teamNum = viewData.options.default_team_size
    modeInfo.bAutoFill = viewData.options.fill_team.default
    modeInfo.isEnableFill = viewData.options.fill_team.mutable
  else
    local viewId = menuData.sub_views[1]
    if not viewId then
      log_error("ModeSelection_Main_UIBP:SetFilterInfoByMenuData get nil view ID")
      return
    end
    local viewData = self.view_dict[viewId]
    if not viewData or not viewData.options then
      viewId = menuData.sub_views[2]
      viewData = self.view_dict[viewId]
      if not viewData or not viewData.options then
        log_error("ModeSelection_Main_UIBP:SetFilterInfoByMenuData first view has no options")
        return
      end
    end
    modeInfo.isEnableFill = viewData.options.fill_team.mutable
    if not modeInfo.isEnableFill then
      modeInfo.bAutoFill = viewData.options.fill_team.default
    end
  end
  if type(modeInfo.isEnableFill) == "nil" then
    modeInfo.isEnableFill = true
  end
  local hasFound = false
  for k, v in pairs(menuData.sub_views) do
    if self.view_id and self.view_id == v then
      hasFound = true
      break
    end
  end
  if hasFound and self.view_id then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(self.view_id)
    if viewInfo and viewInfo.options then
      modeInfo.isEnableFill = viewInfo.options.fill_team.mutable
    end
  end
  self:OnSyncFilterInfo(nil, nil, modeInfo)
end
function ModeSelection_Main_UIBP:UpdateSocialIslandAndTrain()
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local common_download_handler = require("client.slua.common.common_download_handler")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local params = {}
  params.hideMask = true
  params.from = PufferTlog.Enum_TLog_From.LobbyEntrance
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.MAP, {
    "map_socialisland"
  }, self, self.UIRoot.CanvasPanel_island, params)
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.MAP, {
    "map_socialisland"
  }, self, self.UIRoot.CanvasPanel_PHIsland, params)
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.MAP, {
    "map_singletraining"
  }, self, self.UIRoot.CanvasPanel_train, params)
end
function ModeSelection_Main_UIBP:IsLevelLock(cfgLevel, cfgId)
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
  log(bWriteLog and "ModeSelection_Main_UIBP:IsLevelLock = " .. tostring(bLevelUnlockSwitchOpen))
  if not bLevelUnlockSwitchOpen then
    return false
  end
  return cfgLevel > DataMgr.roleData.level
end
function ModeSelection_Main_UIBP:IsPeakOpen(menu_id)
  if not menu_id or menu_id ~= 120 then
    return true
  end
  local logic_mode_peak = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_peak)
  return logic_mode_peak:IsMenuOpen()
end
function ModeSelection_Main_UIBP:IsArenaRankOpen(menu_id)
  local config_arena = require("client.slua.logic.arena.config_arena")
  if not menu_id or menu_id ~= config_arena.ModeMenuId then
    return true
  end
  local ArenaSystem = require("client.slua.logic.arena.logic_arena")
  return ArenaSystem.IsInTargetSeasonShow()
end
function ModeSelection_Main_UIBP:OnPeakTimeRsp()
  self.MenuBetaScroll:RefreshAllItems()
end
function ModeSelection_Main_UIBP:OnMenuAlphaItemRefresh(widget, index)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnMenuAlphaItemRefresh index = " .. index)
  local data = self.MenuAlphaScroll:GetItemData(index)
  local UgcIndex = 3
  if self.bShowChangeModeBtn then
    UgcIndex = 1
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local isFitVersion = PublishRegionMacros.IsFITVersion()
    self:SetWidgetVisible(self.UIRoot.Button_ChangeMode, not isFitVersion, true)
  end
  local showCorner = false
  local showNew = false
  local needShowUnLockAnim = false
  if index == UgcIndex then
    local cfg = CDataTable.GetTableData("UGCParamConfig", "UgcBetaShow")
    showCorner = cfg ~= nil and tonumber(cfg.Value) == 1 and not self._needShowUGCModeGuide
    showNew = self._needShowUGCModeGuide
    needShowUnLockAnim = self._needShowUGCModeGuide
  end
  self:SetWidgetVisible(widget.TextBlock_Corner, showCorner)
  self:SetWidgetVisible(widget.Image_New, showNew)
  self:SetWidgetVisible(widget.Border_LockAnim, needShowUnLockAnim)
  if needShowUnLockAnim then
    widget:PlayAnimation(widget.Anim_Unlock, 0, 1, 0, 1)
    self:AddTimerOnce(2, function()
      if slua.isValid(widget) then
        self:SetWidgetVisible(widget.Border_LockAnim, false)
      end
    end)
  end
  local name = LocUtil.GetLocalizeResStr(data.name)
  widget.TextBlock_Name_1:SetText(name)
  widget.TextBlock_Name_2:SetText(name)
  widget.WidgetSwitcher_Item:SetActiveWidgetIndex(0)
  if widget.Image_Begin then
    widget.Image_Begin:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  if data.id == self.topMenuId then
    self:OnMenuAlphaClick(widget, index, true)
  end
  if not self:IsLevelLock(data.level_limit, data.id) then
    widget.Image_lock:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    widget.TextBlock_Name_1:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.4)))
  else
    widget.Image_lock:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    widget.TextBlock_Name_1:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.4)))
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if index == 1 then
    if QRcodeRestrictManager:IsRestrictBatlleRank() then
      widget.Image_lock:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      widget.TextBlock_Name_1:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.4)))
    elseif not self:IsLevelLock(data.level_limit, data.id) then
      widget.Image_lock:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      widget.TextBlock_Name_1:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.4)))
    end
  end
end
function ModeSelection_Main_UIBP:SetAlphaWidgetByNaruto(widget, IsNarutoView)
  local nodeNameList = {
    "TextBlock_Name_1",
    "TextBlock_Corner",
    "Image_Begin",
    "Image_Line",
    "TextBlock_Name_2",
    "TextBlock_Corner1",
    "Image_3",
    "Image_5",
    "Image_lock"
  }
  local colorIdx = IsNarutoView and 1 or 0
  for k, v in pairs(nodeNameList) do
    if widget[v] and widget[v].SetActiveColorIndex then
      widget[v]:SetActiveColorIndex(colorIdx)
    end
  end
end
function ModeSelection_Main_UIBP:OnMenuAlphaButtonClick(widget, index)
  self:OnMenuAlphaClick(widget, index)
  self:OnClickMenuLevelUnlockGuide(self.MenuAlphaScroll, index)
end
function ModeSelection_Main_UIBP:OnMenuAlphaClick(widget, index, autoClick)
  log(bWriteLog and "[GuideThemeView] ModeSelection_Main_UIBP:OnMenuAlphaClick")
  if self.alphaMenuIndex and self.alphaMenuIndex == index then
    return
  else
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_SEARCH_INFORM, index)
    self.UIRoot.Border_1:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
  end
  UIManager.CloseUI(UIManager.UI_Config.mode_selection_filter)
  if not autoClick then
    self:PlayAudio(sound_config.click)
  end
  local data = self.MenuAlphaScroll:GetItemData(index)
  if self:IsLevelLock(data.level_limit, data.id) then
    ShowNotice(LocUtil.LocalizeResFormat(31028, data.level_limit))
    return
  end
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  if UGCPlayHallRoom and UGCPlayHallRoom:GetRoomMatchInfo() and data.id ~= mode_selection_macro.Enum_TabID.UGC then
    ShowNotice(110014)
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if data.id == mode_selection_macro.Enum_TabID.RankClassic and QRcodeRestrictManager:IsRestrictBatlleRank() then
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  self:HideTxmissionNewTips()
  if not autoClick then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickTab, 0, tostring(data.id))
  end
  local canShow = self.show_Button_Arena[data.id]
  if canShow then
    self:SetWidgetVisible(self.UIRoot.Button_Arena, true, true)
    if canShow == self.Button_Arena_Type.FriendlyPoint then
      self:SetWidgetVisible(self.UIRoot.Button_Arena, false, true)
    else
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    end
  else
    self:SetWidgetVisible(self.UIRoot.Button_Arena, false, true)
  end
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  self:SetWidgetVisible(self.UIRoot.Canvas_NewbieProgressAward, data.id == mode_selection_macro.Enum_TabID.MatchNewbie and logic_newbie_mode_selection:CheckOpen())
  self:SetWidgetVisible(self.UIRoot.Button_MatchSetting, data.id ~= mode_selection_macro.Enum_TabID.MatchNewbie, true)
  self.menuAlphaType = data.type
  self.topMenuId = data.id
  if self.curTopMenuWidget then
    self.curTopMenuWidget.WidgetSwitcher_Item:SetActiveWidgetIndex(0)
    self.curTopMenuWidget.Image_Begin:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  widget.WidgetSwitcher_Item:SetActiveWidgetIndex(1)
  self.curTopMenuWidget = widget
  self.alphaMenuIndex = index
  self.betaMenuIndex = 0
  self:SetWidgetVisible(self.UIRoot.Button_Room, self.canShowRoomList, true)
  self:WidgetCollapse(self.UIRoot.Button_Task)
  self:OnResetTopPanel()
  if self:TryShowUGC(data) then
    self.UIRoot.WidgetSwitcher_Tag:SetActiveWidgetIndex(1)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, false)
    local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
    LogicUGCTemplate:ReqTemplates()
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    growthprojectMgrB.EnterWoWNewbieBranch()
    self:ShowCommercializationGuide()
    self:RefreshWOWActEntry()
    local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
    logic_ugc_WOWPass:ReqUGCWOWRedPointInfo()
    self:RefreshWOWPassEntry()
    self:RefreshWOWPassBuyState()
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    local rightMode = logic_home_switch.lobbyRightMode
    local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local curPage = lobbyMainLogic.curPage
    log(bWriteLog and "ModeSelection_Main_UIBP:OnMenuAlphaClick curPage = " .. tostring(curPage) .. " rightMode = " .. tostring(rightMode))
    local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
    local bNewWOWLobby = LogicUGCHall:CheckIsOpen()
    if bNewWOWLobby then
      self.UIRoot.WidgetSwitcher_Tag:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    elseif curPage == ENUM_LobbyPageType.Right then
      self.UIRoot.WidgetSwitcher_Tag:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    else
      self.UIRoot.WidgetSwitcher_Tag:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    end
    local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
    HostedProtoBridge:GeCreatorForumBubbleTips()
    widget.TextBlock_Name_2:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0.47, 1)))
    widget.Image_Begin:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(1)
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_BG, true, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_49, false, false)
    self:SetWidgetVisible(widget.TextBlock_Corner, true)
    self:SetWidgetVisible(widget.Image_New, false)
    self:SetWidgetVisible(widget.TextBlock_Corner1, true)
    self:InitRecommendTips(data.id)
    self:RefreshNarutoBg(true)
    return
  else
    widget.Image_Begin:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    widget.TextBlock_Name_2:SetColorAndOpacity(FSlateColor(FLinearColor(0.012983, 0.013702, 0.473532, 1)))
    self:SetWidgetVisible(widget.TextBlock_Corner1, false)
  end
  local _GetAvalibleSub = function(sub_menus)
    local menus = {}
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    for k, v in ipairs(sub_menus) do
      local canAdd = true
      local specialMenuData = GetSpecialMenuData(v.id)
      if specialMenuData and specialMenuData.checkTabFunc then
        canAdd = specialMenuData.checkTabFunc()
      end
      if canAdd then
        for kk, vv in ipairs(v.sub_views) do
          local isOpen, isPreview = logic_mode_selection:IsThemeOpen(self.view_dict[vv], curTime, true)
          if isOpen or isPreview then
            table.insert(menus, v)
            break
          end
        end
      end
    end
    return menus
  end
  self.UIRoot.WidgetSwitcher_Tag:SetActiveWidgetIndex(0)
  self.UIRoot.WidgetSwitcher_Tag:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_UGCTab, false)
  self.menuAlphaType = data.type
  if data.type == ENUM_MENU_TYPE.VIEW then
    self.UIRoot.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
    self:SetViewData(data)
  else
    self.UIRoot.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
    self:UpdateCountDownSeasonEndTime()
    local sub_menus = _GetAvalibleSub(data.sub_menus)
    self:SetBetaMenuData(sub_menus)
  end
  if self.curTopMenuWidget then
    self.curTopMenuWidget.WidgetSwitcher_Item:SetActiveWidgetIndex(0)
  end
  widget.WidgetSwitcher_Item:SetActiveWidgetIndex(1)
  self.curTopMenuWidget = widget
  self.alphaMenuIndex = index
  self.betaMenuIndex = 0
  if self.alphaClickCount then
    self.alphaClickCount = self.alphaClickCount + 1
  end
  if self.alphaClickCount and self.alphaClickCount >= 5 then
    self.alphaClickCount = 0
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_POST_MENU_ALPHA_SWITCH, data.id)
  local UGC_Main_Search_UIBP = UIManager.GetUI(UIManager.UI_Config.UGC_Main_Search_UIBP)
  if UGC_Main_Search_UIBP then
    UGC_Main_Search_UIBP:ExitSearch()
  end
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:ClearCacheData()
end
function ModeSelection_Main_UIBP:OnMenuBetaItemRefresh(widget, index)
  local data = self.MenuBetaScroll:GetItemData(index)
  if not data then
    log(bWriteLog and "ModeSelection_Main_UIBP:OnMenuBetaItemRefresh not data")
    return
  end
  local name = LocUtil.GetLocalizeResStr(data.name)
  widget.TextBlock_Select:SetText(name)
  widget.TextBlock_Unselect:SetText(name)
  if index ~= self.betaMenuIndex then
    widget.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
  else
    widget.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
    self.curSecMenuWidget = widget
  end
  if data.id == self.secMenuId then
    self:OnMenuBetaClick(widget, index, true)
  end
  if not self:IsLevelLock(data.level_limit, data.id) then
    widget.Image_lock:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  else
    widget.Image_lock:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
  if self.MenuBetaScroll:GetItemCount() == index then
    widget.Image_Line_LastCollapsed:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  else
    widget.Image_Line_LastCollapsed:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  if not cfg.viewRedRemind then
    cfg.viewRedRemind = {}
  end
  local isRed = false
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  for k, v in ipairs(data.sub_views) do
    if logic_mode_selection:IsSubViewNew(v) and not cfg.viewRedRemind[data.id] then
      isRed = true
      break
    end
  end
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  local bShowReddot = logic_newbie_mode_selection:CheckShowReddot(data.id)
  if bShowReddot then
    isRed = true
  end
  self:SetWidgetVisible(widget.Reddot_Anchor_Item05, isRed)
  self:RefreshCrossoverMark(widget, data)
end
function ModeSelection_Main_UIBP:RefreshCrossoverMark(widget, data)
  if not widget.Image_Crossover then
    return
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local bShow = LogicTxMissionMatch.IsCrossoverOpen() and data.id == mode_selection_macro.Enum_TabID.MatchTxMission
  self:SetWidgetVisible(widget.Image_Crossover, bShow)
end
function ModeSelection_Main_UIBP:OnMenuBetaButtonClick(widget, index)
  self:OnMenuBetaClick(widget, index)
  self:OnClickMenuLevelUnlockGuide(self.MenuBetaScroll, index)
  self:SelectMenuBetaScrollItemToCenter(index)
end
function ModeSelection_Main_UIBP:OnUserScrolled()
  self.MenuBetaScroll:ClearAnimationPlayTimer()
end
function ModeSelection_Main_UIBP:SetBetaSelect(index)
  if self.curSecMenuWidget and self.curSecMenuWidget.WidgetSwitcher_Tab then
    self.curSecMenuWidget.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
  end
  if self.curSecMenuWidget2 and self.curSecMenuWidget2.WidgetSwitcher_Tab then
    self.curSecMenuWidget2.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
  end
  local widget = self.MenuBetaScroll:GetIndexOfWidget(index)
  local widget2 = self.MenuBetaScroll2:GetIndexOfWidget(index)
  if widget and widget.WidgetSwitcher_Tab then
    widget.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
  end
  if widget2 and widget2.WidgetSwitcher_Tab then
    widget2.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
  end
  self.curSecMenuWidget = widget
  self.curSecMenuWidget2 = widget2
end
function ModeSelection_Main_UIBP:OnMenuBetaClick(widget, index, autoClick)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnMenuBetaClick index = " .. tostring(index))
  if self.betaMenuIndex and self.betaMenuIndex == index then
    log(bWriteLog and "ModeSelection_Main_UIBP:OnMenuBetaClick return same index")
    return
  end
  self:HideTxmissionNewTips()
  UIManager.CloseUI(UIManager.UI_Config.mode_selection_filter)
  if not autoClick then
    self:PlayAudio(sound_config.click)
  end
  local data = self.MenuBetaScroll:GetItemData(index)
  if self:IsLevelLock(data.level_limit, data.id) then
    ShowNotice(LocUtil.LocalizeResFormat(31028, data.level_limit))
    return
  end
  self.secMenuId = data.id
  if not autoClick then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickTab, 0, tostring(data.id))
  end
  self:SetViewData(data)
  self:SetBetaSelect(index)
  local canShow = self.show_Button_Arena[data.id]
  if canShow then
    self:SetWidgetVisible(self.UIRoot.Button_Arena, true, true)
    if canShow == self.Button_Arena_Type.FriendlyPoint then
      self:SetWidgetVisible(self.UIRoot.Button_Arena, false, true)
    else
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    end
  else
    self:SetWidgetVisible(self.UIRoot.Button_Arena, false, true)
  end
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  logic_newbie_mode_selection:SetSelectView(nil)
  logic_newbie_mode_selection:SetNewbieModeReddotGuide(data.id)
  if data.id == mode_selection_macro.Enum_TabID.MatchNewbie and logic_newbie_mode_selection:CheckShowReddot(data.id) then
    log(bWriteLog and "ModeSelection_Main_UIBP:OnMenuBetaClick 1")
    self:SetWidgetVisible(widget.Reddot_Anchor_Item05, true)
  else
    log(bWriteLog and "ModeSelection_Main_UIBP:OnMenuBetaClick 2")
    self:SetWidgetVisible(widget.Reddot_Anchor_Item05, false)
  end
  self:SetWidgetVisible(self.UIRoot.Canvas_NewbieProgressAward, data.id == mode_selection_macro.Enum_TabID.MatchNewbie and logic_newbie_mode_selection:CheckOpen())
  self:SetWidgetVisible(self.UIRoot.Button_MatchSetting, data.id ~= mode_selection_macro.Enum_TabID.MatchNewbie and data.id ~= 270 and data.id ~= 260, true)
  self.betaMenuIndex = index
  self:SetWidgetVisible(widget.Reddot_Anchor, false)
  self:InitRecommendTips(data.id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  if not cfg.viewRedRemind then
    cfg.viewRedRemind = {}
  end
  cfg.viewRedRemind[data.id] = 1
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
  local data = self.MenuAlphaScroll:GetItemData(self.alphaMenuIndex)
  if data.id == mode_selection_macro.Enum_TabID.RankClassic or data.id == mode_selection_macro.Enum_TabID.RankClassicMode then
    if self.betaMenuIndex == 1 then
      self:UpdateCountDownSeasonEndTime()
    else
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Time, false)
    end
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Time, false)
  end
end
function ModeSelection_Main_UIBP:UpdateNewbieProgressAward()
  log(bWriteLog and "ModeSelection_Main_UIBP:UpdateNewbieProgressAward")
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  self.UIRoot.TextBlock_AwardProgress:SetText(LocUtil.LocalizeResFormat(6830, logic_newbie_mode_selection:GetFinishCount(), logic_newbie_mode_selection:GetLevelTotalNum()))
  local finish_count = logic_newbie_mode_selection:GetFinishCount()
  local total_count = logic_newbie_mode_selection:GetLevelTotalNum()
  local progress = finish_count / total_count
  self.UIRoot.ProgressBar_Award:SetPercent(progress)
  log(bWriteLog and "ModeSelection_Main_UIBP:UpdateNewbieProgressAward finish_count = " .. tostring(finish_count) .. " total_count = " .. tostring(total_count) .. " progress = " .. tostring(progress))
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local award_status_table = logic_newbie_mode_selection:GetProgressAwardInfo()
  log_tree("ModeSelection_Main_UIBP:UpdateNewbieProgressAward award_status_table = ", award_status_table)
  for cfg_id = 1, 3 do
    local award_cfg = logic_newbie_mode_selection:GetProgressAwardCfg(cfg_id)
    if award_cfg and award_cfg.items and award_cfg.items[1] then
      local award_status = award_status_table[cfg_id]
      local item = award_cfg.items[1]
      local item_cfg = CDataTable.GetTableData("Item", item.item_id)
      if self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)] then
        if item_cfg then
          self:SetWidgetVisible(self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)], true, false)
          self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)].Common_Item_BP:InitView(item.item_id, item.count, 1, item.valid_hours or 0, true, false)
          self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)].Common_Item_BP:SetQuality(item_cfg.ItemQuality)
          self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)].Common_Item_BP:SetHasGet(award_status == mode_selection_macro.newbieAwardStatus.HAVE_GOT)
          self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)].Common_Item_BP:SetClickItemCallback(self.OnNewbieProgressAwardItemClick, self, cfg_id)
          self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)].Common_Item_BP:SetLight(award_status == mode_selection_macro.newbieAwardStatus.CAN_GET)
        else
          self:SetWidgetVisible(self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)], false, false)
        end
        local total_cnt = award_cfg.total_cnt
        self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)].TextBlock_Progress:SetText(total_cnt)
        if finish_count >= total_cnt then
          self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)].WidgetSwitcher_State:SetActiveWidgetIndex(0)
        else
          self.UIRoot["ModeSelection_Newbie_Progress_Item_" .. tostring(cfg_id)].WidgetSwitcher_State:SetActiveWidgetIndex(1)
        end
      end
    end
  end
end
function ModeSelection_Main_UIBP:OnNewbieProgressAwardItemClick(index)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnNewbieProgressAwardItemClick " .. tostring(index))
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.NewbieModeSelectionAward) then
    log(bWriteLog and "ModeSelection_Main_UIBP:OnNewbieProgressAwardItemClick in cd")
    return
  end
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  local award_status_table = logic_newbie_mode_selection:GetProgressAwardInfo()
  local award_status = award_status_table[index]
  log(bWriteLog and "ModeSelection_Main_UIBP:OnNewbieProgressAwardItemClick award_status = " .. tostring(award_status))
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if award_status == mode_selection_macro.newbieAwardStatus.CAN_GET then
    local NewbieModeHandler = require("client.network.Protocol.NewbieModeHandler")
    NewbieModeHandler.send_newbie_upgrade_total_reward_req(index)
    return true
  else
    return false
  end
end
function ModeSelection_Main_UIBP:OnSyncFilterInfo(_, _, filterInfo, isChangeFromSetting)
  if not filterInfo then
    return
  end
  if isChangeFromSetting == nil and not firstInModeSelectionUI then
    self:UpdateFilterAnimAndTips(_, _, self.filter_info, filterInfo, false)
  end
  self.filter_info = filterInfo
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsTeamLeader() and filterInfo then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local filterInfo = logic_mode_selection:GetFilterInfo()
    local newFilter = {}
    for k, v in pairs(filterInfo) do
      newFilter[k] = v
    end
    self.filter_info = newFilter
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local curTeamNum = TeamUpNewSystem.GetTeamNum()
  if self.filter_info.teamNum and curTeamNum > self.filter_info.teamNum then
    local setTeamNum = 1
    while curTeamNum > setTeamNum do
      setTeamNum = setTeamNum * 2
    end
    self.filter_info.teamNum = setTeamNum
  end
  self.UIRoot.TextBlock_TeamCnt:SetText(self.filter_info.teamNum or 1)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local _teamIconMap = mode_selection_macro.TeamNumIcon_Path_Config
  self:SetTexture(self.UIRoot.Image_Mode_PlayerCnt, _teamIconMap[self.filter_info.teamNum] or "")
  if self.filter_info.perspective then
    self.UIRoot.Text_PerspectiveType:SetText(LocUtil.LocalizeResFormat(self.filter_info.perspective))
  end
  self:SetWidgetVisible(self.UIRoot.TextBlock_Fill, self.filter_info.teamNum ~= 1)
  self:SetWidgetVisible(self.UIRoot.Image_13, self.filter_info.teamNum ~= 1)
  self.UIRoot.TextBlock_Fill:SetText(self.filter_info.bAutoFill and LocUtil.LocalizeResFormat(29862) or LocUtil.LocalizeResFormat(29863))
  if self.filter_info.teamNum == 1 then
    self.UIRoot.TextBlock_Fill:SetText("")
  end
  self:RefreshRankInfo()
  self:RefreshSegmentLimit()
  self:RefreshMatchSetting(false)
  if not self.viewMenuData then
    return
  end
  local menuId = self.viewMenuData.id
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  if not cfg.menuFilter then
    cfg.menuFilter = {}
  end
  cfg.menuFilter[menuId] = filterInfo
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_MAIN_FILTER_CHANGE, self.filter_info)
  if firstInModeSelectionUI then
    firstInModeSelectionUI = false
  end
end
function ModeSelection_Main_UIBP:UpdateFilterAnimAndTips(_, _, lastFilterInfo, selectFilterInfo, isShowTips)
  if not selectFilterInfo then
    return
  end
  if not lastFilterInfo or lastFilterInfo.perspective ~= selectFilterInfo.perspective or lastFilterInfo.teamNum ~= selectFilterInfo.teamNum then
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Refresh, 0, 1, 0, 1)
  end
end
function ModeSelection_Main_UIBP:OnRefreshNewbieUpgradeProgressAward()
  log(bWriteLog and "ModeSelection_Main_UIBP:OnRefreshNewbieUpgradeProgressAward")
  self:UpdateNewbieProgressAward()
  self:OnNewbieUpgradeViewAward()
end
function ModeSelection_Main_UIBP:OnNewbieUpgradeSyncData()
  log(bWriteLog and "ModeSelection_Main_UIBP:OnNewbieUpgradeSyncData")
  self:UpdateNewbieProgressAward()
  self:OnNewbieUpgradeViewAward()
end
function ModeSelection_Main_UIBP:OnNewbieUpgradeViewAward()
  log(bWriteLog and "ModeSelection_Main_UIBP:OnNewbieUpgradeViewAward self.betaMenuIndex = " .. tostring(self.betaMenuIndex))
  if not self.betaMenuIndex or self.betaMenuIndex == 0 then
    return
  end
  self.MenuBetaScroll:RefreshItem(self.betaMenuIndex)
end
local _GetViewStrByViewIDs = function(viewIDs)
  if not viewIDs then
    return
  end
  if type(viewIDs) ~= "number" then
    local str = ""
    for _, v in ipairs(viewIDs) do
      if str ~= "" then
        str = string.format("%s,%s", str, tostring(v))
      else
        str = tostring(v)
      end
    end
    return str
  end
  return tostring(viewIDs)
end
function ModeSelection_Main_UIBP:OnViewItemClick(_, _, viewId)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:SetSelectView(viewId, self.filter_info)
  local _, _, lastViewIDs = logic_mode_selection:GetCurSelectInfo()
  local beforeStr = _GetViewStrByViewIDs(lastViewIDs) or ""
  local afterStr = _GetViewStrByViewIDs(viewId) or ""
  local str = string.format("before,%s,after,%s", beforeStr, afterStr)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickSelectView, 0, str)
end
function ModeSelection_Main_UIBP:OnButton_CloseClick()
  self:PlayAudio(sound_config.click)
  self:CloseSelf()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    return
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if LogicUGCMatch:HasUGCMatchInfo() or LogicUGCMulti.bIsBundleMatch then
  else
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    if logic_mode_selection.hasSelectTxMission then
    else
      local _, viewId = logic_mode_selection:GetCurSelectInfo()
      if not viewId or not logic_mode_selection.GetMenuListByViewID then
        logic_mode_selection:SetSelectView(self.view_ids, self.filter_info, true)
      else
        local menuIdList = logic_mode_selection:GetMenuListByViewID(viewId)
        local menuId = menuIdList and menuIdList[1]
        local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
        if not cfg.menuFilter then
          cfg.menuFilter = {}
        elseif menuId and cfg.menuFilter[menuId] then
          local localfilterInfo = cfg.menuFilter[menuId]
          if localfilterInfo then
            logic_mode_selection:SetSelectView(self.view_ids, localfilterInfo, true)
          else
            logic_mode_selection:SetSelectView(self.view_ids, self.filter_info, true)
          end
        else
          logic_mode_selection:SetSelectView(self.view_ids, self.filter_info, true)
        end
      end
    end
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  mode_selection_macro.jumpUrlViewId = nil
  local UGC_Main_Search_UIBP = UIManager.GetUI(UIManager.UI_Config.UGC_Main_Search_UIBP)
  if UGC_Main_Search_UIBP then
    UGC_Main_Search_UIBP:ExitSearch()
  end
end
function ModeSelection_Main_UIBP:OnButton_ChangeModeClick()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Select_UIBP, true)
  local ModeSelection_Wow_UIBP = UIManager.GetUI(UIManager.UI_Config.ModeSelection_Wow_UIBP)
  if ModeSelection_Wow_UIBP then
    ModeSelection_Wow_UIBP:CloseSelf()
  end
end
function ModeSelection_Main_UIBP:OnButton_SocialIslandClick()
  self:PlayAudio(sound_config.click)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local cb = function()
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    ui_jump_manager.Clear()
    self:CloseSelf()
  end
  logic_mode_selection:EnterSocialIsland(cb)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.socialIsland)
end
function ModeSelection_Main_UIBP:OnButton_PHSocialIslandClick()
  self:PlayAudio(sound_config.click)
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  local home_macros = require("client.slua.logic.home.home_macros")
  local ret = SocialIslandHandler.ReqEnterSystemIsland(nil, home_macros.Enter_SocialIsland_Start.Store)
end
function ModeSelection_Main_UIBP:OnButton_TrainClick()
  log(bWriteLog and "ModeSelection_Main_UIBP:OnButton_TrainClick")
  self:PlayAudio(sound_config.click)
  if LobbySystem.isInMatch then
    ShowNotice(110014)
    return
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickTrain)
  local iPadVirReduce = HDmpveRemote.HDmpveRemoteConfigGetInt("iPadVirReduce", 0)
  if 0 < iPadVirReduce then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.EnterSingleTraining() then
    self:CloseSelf()
  end
  if 0 < iPadVirReduce then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
end
function ModeSelection_Main_UIBP:OnClickButtonActivity()
  self:PlayAudio(sound_config.click)
  local jump_utils = require("client.logic.store.jump_utils")
  local url = jump_utils.GenerateGameUrl(BP_ENUM_MODULE_ACTIVITY, {
    DisplayScene = ActivityDisplayScene.WOW
  })
  GlobalData.JumpUrl(url)
end
function ModeSelection_Main_UIBP:OnButton_RoomClick()
  self:PlayAudio(sound_config.click)
  if LobbySystem.isInMatch then
    ShowNotice(110014)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    ShowNotice(110002)
    return
  end
  local RoomListSystem = require("client.slua.logic.room.logic_room_list")
  if self:IsShowingUGC() then
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    RoomListSystem.ShowUI(Config_UGC.RoomListTabIndex)
  else
    RoomListSystem.ShowUI()
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickRoom)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.SyncMatchModeEntry()
end
function ModeSelection_Main_UIBP:OnButton_SettingClick()
  self:PlayAudio(sound_config.click)
  UIManager.ShowUI(UIManager.UI_Config.mode_selection_option, self.topMenuId, self.secMenuId)
  if self.bIsShowNewGuide then
    self.bIsShowNewGuide = false
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_MATCH_LANG, 52)
    self:UpdateNewbieGuide()
  end
  if self:CheckDynamicMatchReddot() then
    self:HideDynamicMatchReddot()
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickMatchLanguageSettings)
end
function ModeSelection_Main_UIBP:OnClickBtnUGCRoom()
  self:PlayAudio(sound_config.click)
  if LobbySystem.isInMatch then
    ShowNotice(110014)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    ShowNotice(110002)
    return
  end
  local RoomListSystem = require("client.slua.logic.room.logic_room_list")
  if self:IsShowingUGC() then
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    RoomListSystem.ShowUI(Config_UGC.RoomListTabIndex)
  end
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.NewModeSelection_ClickRoom, nil, "ClassicWowHall")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.SyncMatchModeEntry()
  local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  Logic_UGC_TLog:ReportCommercialClick({
    source = UGCMacros.Enum_UGC_CommercialClick_Type.Room
  })
end
function ModeSelection_Main_UIBP:OnClickBtnWorkplaceSquare()
  self:PlayAudio(sound_config.click)
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if not LogicPufferBundle.IsFitLobbyResDownloaded() then
    ShowNotice(180109)
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCFirstSquareGetIn) or {}
  if Data and not Data.FirstSquareGetIn then
    Data.FirstSquareGetIn = true
    PlayerPrefsSystem.SaveTableToFile_N(Data, PlayerPrefsSystem.ePlayerPrefsType.eUGCFirstSquareGetIn)
  end
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  logic_moment.EnterMomentSquareUI(DataMgr.roleData.uid)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Click_CreationSquare, nil, "ClassicWowHall")
end
function ModeSelection_Main_UIBP:OnClickBtnUGCSetting()
  self:PlayAudio(sound_config.click)
  UIManager.ShowUI(UIManager.UI_Config.UGC_PlayPreference_Setting_Popup_UIBP, nil, false)
  local Logic_UGC_Personalization = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_personalization)
  if Logic_UGC_Personalization:CheckShowTipsMenu() then
    UIManager.ShowUI(UIManager.UI_Config.UGC_PlayPreference_TipsMenu_UIBP)
  end
  if self:CheckWOWDynamicMatchReddot() then
    self:HideWOWDynamicMatchReddot()
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickMatchLanguageSettings)
end
function ModeSelection_Main_UIBP:OnClickUGCForum()
  self:PlayAudio(sound_config.click)
  if self.UIRoot.CanvasPanel_UpdateTips:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    local version_util = require("client.common.version_util")
    local VersionStr = version_util.ExcludeTheBuildNumber(Client.GetAppVersion())
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({Version = VersionStr}, PlayerPrefsSystem.ePlayerPrefsType.eUGCCommercializationFirstGetIn)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_UpdateTips, false)
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_CommunityTips, false)
  self:ShowFloatTips(self.UIRoot.Button_UGCForum, self.ForumBtnCfg, -150, 30)
end
function ModeSelection_Main_UIBP:OnClickUGCMore()
  self:PlayAudio(sound_config.click)
  if self.UIRoot.CanvasPanel_UpdateTips:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    local version_util = require("client.common.version_util")
    local VersionStr = version_util.ExcludeTheBuildNumber(Client.GetAppVersion())
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({Version = VersionStr}, PlayerPrefsSystem.ePlayerPrefsType.eUGCCommercializationFirstGetIn)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_UpdateTips, false)
  end
  self:ShowFloatTips(self.UIRoot.Button_UGCMore, self.MoreBtnCfg, -150, 30)
end
function ModeSelection_Main_UIBP:OnClickUGCWarehouse()
  self:PlayAudio(sound_config.click)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_UGC_DEPOT)
end
function ModeSelection_Main_UIBP:OnClickTeamUp()
  self:PlayAudio(sound_config.click_v1)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  TeamPlatformSystem.ShowUI(TeamPlatform_Macro.Enum_PlatformType.WoW)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Click_WoWTeam)
end
function ModeSelection_Main_UIBP:OnButton_RattingClick()
  self:PlayAudio(sound_config.click)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickChallengeValue)
  local ModeSelection_Main_Segment = require("client.slua.umg.ModeSelection.ModeSelection_Main_Segment")
  ModeSelection_Main_Segment:ShowChanllengeTip(self.UIRoot, self.filter_info)
end
function ModeSelection_Main_UIBP:OnButton_ArenaClick()
  self:PlayAudio(sound_config.click)
  local index = self.UIRoot.WidgetSwitcher_1:GetActiveWidgetIndex()
  if index == 1 then
    log(bWriteLog and "ModeSelection_Main_UIBP:OnButton_ArenaClick show friendly point")
    UIManager.ShowUI(UIManager.UI_Config.MainBackPack_Tips_MaterialBox_Outside_BP, self.UIRoot.Button_Arena)
    return
  end
  local PrepareSchemeSystem = require("client.slua.logic.prepareScheme.logic_prepare_scheme")
  PrepareSchemeSystem.OpenPrepareSchemeMain()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickArena)
  local ArenaRedDotSystem = require("client.slua.logic.arena.logic_AW_red_dot")
  ArenaRedDotSystem.SetEntranceRedState()
end
function ModeSelection_Main_UIBP:OnButton_MatchSettingClick()
  self:PlayAudio(sound_config.click)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickPersonPespectiveDropList)
  local match_pre_info_bar_helper = require("client.slua.umg.lobby.Main.Helper.match_pre_info_bar_helper")
  match_pre_info_bar_helper.OpenMatchSettingPopup(self.viewMenuData.id)
end
function ModeSelection_Main_UIBP:OnButton_QuickRoomCreateClick()
  self:PlayAudio(sound_config.click)
  if LobbySystem.isInMatch then
    ShowNotice(110014)
    return
  end
  log(bWriteLog and "ModeSelection_Main_UIBP:OnButton_QuickRoomCreateClick. direct open create room ui")
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  CreateRoomSystem.ShowCreateRoomUI(CreateRoomConfig.C_RoomTypeMap.Hvh)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickRoom)
end
function ModeSelection_Main_UIBP:RefreshMatchSetting(isShowMatchSetting)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(isShowMatchSetting and 1 or 0)
end
function ModeSelection_Main_UIBP:RefreshRankInfo()
  local ModeSelection_Main_Segment = require("client.slua.umg.ModeSelection.ModeSelection_Main_Segment")
  ModeSelection_Main_Segment:RefreshUI(self.UIRoot, self.filter_info)
end
function ModeSelection_Main_UIBP:SeasonChange()
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.Enter()
end
function ModeSelection_Main_UIBP:OnChangeCurrModeMap(_, _, newViewIDs, oldViewIDs)
  if not (self.view_ids and next(self.view_ids) and next(newViewIDs)) or not next(oldViewIDs) then
    return
  end
  local isChange = false
  if #newViewIDs == #oldViewIDs then
    for i, v in ipairs(newViewIDs) do
      if oldViewIDs[i] ~= v then
        isChange = true
        break
      end
    end
  else
    isChange = true
  end
  if isChange then
    local isChangeCurrModeMap = true
    if #self.view_ids == #oldViewIDs then
      for i, v in ipairs(self.view_ids) do
        if oldViewIDs[i] ~= v then
          isChangeCurrModeMap = false
          break
        end
      end
    else
      isChangeCurrModeMap = false
    end
    if isChangeCurrModeMap then
      local TableUtil = require("common.table_util")
      self.view_ids = TableUtil.CopyTable(newViewIDs)
    end
  end
end
function ModeSelection_Main_UIBP:OnGetNewbieUpgradeDataRsp()
  self:UpdateNewbieProgressAward()
  self:OnNewbieUpgradeViewAward()
end
function ModeSelection_Main_UIBP:OnButton_SegmentLimitClick()
  self:PlayAudio(sound_config.click)
  local title = LocUtil.LocalizeResFormat(5077)
  local context = LocUtil.GetLocalizeStrConcatenation(27204)
  UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, context)
end
function ModeSelection_Main_UIBP:RefreshSegmentLimit()
  log(bWriteLog and "ModeSelection_Main_UIBP:RefreshSegmentLimit")
  if not self.betaMenuIndex or self.betaMenuIndex == 0 then
    log(bWriteLog and "ModeSelection_Main_UIBP:RefreshSegmentLimit betaMenuIndex is nil or 0")
    return
  end
  local ModeSelection_Main_Segment = require("client.slua.umg.ModeSelection.ModeSelection_Main_Segment")
  local menudata = self.MenuBetaScroll:GetSetData()
  if not menudata then
    log(bWriteLog and "ModeSelection_Main_UIBP:RefreshSegmentLimit menudata is nil")
    return
  end
  local selectData = menudata[self.betaMenuIndex]
  if not selectData then
    log(bWriteLog and "ModeSelection_Main_UIBP:RefreshSegmentLimit selectData is nil, betaMenuIndex: " .. tostring(self.betaMenuIndex))
    return
  end
  local subviewData = selectData.sub_views
  if not subviewData or #subviewData == 0 then
    log(bWriteLog and "ModeSelection_Main_UIBP:RefreshSegmentLimit subviewData is nil or empty")
    return
  end
  local viewdata = self.view_dict[subviewData[1]]
  if not viewdata then
    log(bWriteLog and "ModeSelection_Main_UIBP:RefreshSegmentLimit viewdata is nil")
    return
  end
  ModeSelection_Main_Segment:RefreshSegmentLimit(self.UIRoot, viewdata, self.filter_info, self.menuAlphaType, self.topMenuId, ENUM_MENU_TYPE)
end
function ModeSelection_Main_UIBP:ShowDownLoadTips()
  log(bWriteLog and "ModeSelection_Main_UIBP:ShowDownLoadTips self.view_id = " .. tostring(self.view_id))
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  local jumpState = logic_return_activity:GetModeJumpState()
  if not jumpState or jumpState == 0 then
    return
  end
  logic_return_activity:SetModeJumpState(0)
  local item
  local isTheme = false
  local CheckGroupView = function(groupView)
    for i, viewData in ipairs(groupView or {}) do
      if viewData.view_id == self.view_id then
        if not viewData.note then
          isTheme = true
        end
        return true
      end
    end
  end
  for _, v in ipairs(self.ChildItemList or {}) do
    if item then
      break
    end
    if v.data and v.data.id == self.view_id then
      item = v
      break
    elseif v.itemData1 and v.itemData1.id == self.view_id then
      item = v.item1
      break
    elseif v.itemData2 and v.itemData2.id == self.view_id then
      item = v.item2
      break
    else
      if CheckGroupView(v.data and v.data.group_view) then
        item = v
        break
      end
      if CheckGroupView(v.itemData1 and v.itemData1.group_view) then
        item = v.item1
        break
      end
      if CheckGroupView(v.itemData2 and v.itemData2.group_view) then
        item = v.item2
        break
      end
    end
  end
  if item then
    if isTheme and not item.isSelectTheme then
      item:OnButton_ThemeClick()
    end
    item:ShowDownLoadTips()
  end
end
function ModeSelection_Main_UIBP:TryShowUGC(data)
  if data.type == ENUM_MENU_TYPE.SINGLE then
    self:OnRefreshSettingBtn(false, true)
    self:OnRefreshRoomBtn(false, true)
    self:OnRefreshFourmAndMoreBtn(false, true)
    self:OnRefreshUGCWarehouseBtn(false, true)
    self:OnRefreshButtonWoWPass(false, true)
    self:RefreshAppreciationGroupRedDot()
    self:SetWidgetVisible(self.UIRoot.Button_Task, true, true)
    self:SetWidgetVisible(self.UIRoot.Button_WorkplaceSquare, false, true)
    self:SetWidgetVisible(self.UIRoot.Button_Activity, true, true)
    self:SwitchUGC(true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_UGCTab, true)
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_WowAppear, 0, 1, 0, 1)
    if UIManager.IsUIShow(UIManager.UI_Config.CommonTextTips_UIBP) then
      UIManager.CloseUI(UIManager.UI_Config.CommonTextTips_UIBP)
    end
    self:OnClearAlbumThemeTimer()
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    if data.id == mode_selection_macro.Enum_TabID.UGC then
      self:ShowUGC()
    else
      log_error(bWriteLog and "[edward] ModeSelection_Main_UIBP:ShowUGC, UGC\229\133\165\229\143\163\233\133\141\231\189\174\233\148\153\232\175\175")
    end
    return true
  else
    self:OnRefreshSettingBtn(false, false)
    self:OnRefreshRoomBtn(false, false)
    self:OnRefreshFourmAndMoreBtn(false, false)
    self:OnRefreshUGCWarehouseBtn(false, false)
    self:OnRefreshButtonWoWPass(false, false)
    self:SwitchUGC(false)
  end
  return false
end
function ModeSelection_Main_UIBP:IsShowingUGC()
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if self.topMenuId == mode_selection_macro.Enum_TabID.UGC then
    return true
  end
  return false
end
function ModeSelection_Main_UIBP:SwitchUGC(isUGC)
  local root = self.UIRoot
  if isUGC then
    if root.WidgetSwitcher_SocialIsland then
      self:SetWidgetVisible(root.WidgetSwitcher_SocialIsland, false)
    end
    root.CanvasPanel_Original:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    root.Button_Train:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:RequestCommunityRedPoint()
    self:RequestCommunityHomeRedPoint()
  else
    if root.WidgetSwitcher_SocialIsland then
      self:SetWidgetVisible(root.WidgetSwitcher_SocialIsland, true)
      root.WidgetSwitcher_SocialIsland:SetActiveWidgetIndex(0)
    end
    root.CanvasPanel_Original:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    root.Button_Train:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    if self.UGCMainSubTabUI then
      self.UGCMainSubTabUI:OnCloseSelf()
      self.UGCMainSubTabUI = nil
    end
  end
  self:SetWidgetVisible(self.UIRoot.Button_Rank, false, false)
end
function ModeSelection_Main_UIBP:ShowUGC()
  local jumpbackData = self.jumpBackUIData
  local tab
  local extendedParams = {}
  if jumpbackData and jumpbackData.UGCMainTabUIData then
    tab = jumpbackData.UGCMainTabUIData.tab
    extendedParams = jumpbackData.UGCMainTabUIData.extendedParams or {}
  end
  if jumpbackData and jumpbackData.UGCMineSubCtorData then
    tab = jumpbackData.UGCMainTabUIData.tab
    extendedParams = jumpbackData.UGCMineSubCtorData or {}
  end
  if not tab and self.creationTab then
    tab = self.creationTab
    self.creationTab = nil
  end
  local UGCDetailCtorData
  if self.UGCDetailUIData and self.UGCDetailUIData[1] and self.UGCDetailUIData[2] then
    UGCDetailCtorData = self.UGCDetailUIData
    self.UGCDetailUIData = nil
    self.ugcModId = nil
  elseif jumpbackData and jumpbackData.UGCDetailCtorData and jumpbackData.UGCDetailCtorData[1] and jumpbackData.UGCDetailCtorData[2] then
    UGCDetailCtorData = jumpbackData.UGCDetailCtorData
    self.ugcModId = nil
  end
  extendedParams.notPlayItemAnim = self.UGCNotPlayItemAnim
  extendedParams.ugcModId = self.ugcModId
  extendedParams.openSubTabID = self.openUgcSubTabID
  extendedParams.openInnerTabID = self.openUgcInnerTabID
  extendedParams.homeSubTabID = self.homeSubTabID
  extendedParams.homeRankFilterIndex = self.homeRankFilterIndex
  extendedParams.ugcModThemeID = self.ugcModThemeID
  extendedParams.src = self.src
  extendedParams.shareuid = self.shareuid
  extendedParams.openthemeID = self.openthemeID
  extendedParams.openauthorID = self.openauthorID
  extendedParams.SearchInfo = self.SearchInfo
  extendedParams.return_url = self.return_url
  local Logic_UGC_Share = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_share)
  if self.ugcModId then
    Logic_UGC_Share.mod_id = self.ugcModId
    log_tree("ModeSelection_Main_UIBP extendedParams = ", extendedParams)
    log(bWriteLog and "ModeSelection_Main_UIBP Logic_UGC_Share.mod_id  = " .. Logic_UGC_Share.mod_id)
  end
  self.homeSubTabID = nil
  self.homeRankFilterIndex = nil
  self.openUgcSubTabID = nil
  self.openUgcInnerTabID = nil
  log(bWriteLog and "ModeSelection_Main_UIBP:ShowUGC")
  self.UGCMainSubTabUI = self:CreateChildWindow(self.UIRoot.ScrollBox_Tab, UIManager.UI_Config.UGCMainTabUIBP, tab, extendedParams)
  self.UGCNotPlayItemAnim = false
  self.ugcModId = nil
  self.ugcModThemeID = nil
  self.openthemeID = nil
  self.openauthorID = nil
  local logic_ugc_comment_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_switch)
  if logic_ugc_comment_switch:IsNeedReqParamsConfigTable() then
    logic_ugc_comment_switch:ReqGetParamsConfigTable()
  end
  local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
  if logic_ugc_newbie_guide and not logic_ugc_newbie_guide:IsUGCNewbieGuideOn() and UGCDetailCtorData then
    if UGCDetailCtorData[3] then
      for k, v in pairs(UGCDetailCtorData[3]) do
        extendedParams[k] = v
      end
    end
    UIManager.ShowUI(UIManager.UI_Config.UGCDetailMainPanel, UGCDetailCtorData[1], UGCDetailCtorData[2], extendedParams)
  end
end
function ModeSelection_Main_UIBP:JumpBack(uiData)
  self.jumpBackUIData = uiData
end
function ModeSelection_Main_UIBP:GetDataForJumpBack()
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local uiData
  if self.topMenuId == mode_selection_macro.Enum_TabID.UGC then
    uiData = {}
    if self.UGCMainSubTabUI and self.UGCMainSubTabUI.GetDataForJumpBack then
      uiData.UGCMainTabUIData = self.UGCMainSubTabUI:GetDataForJumpBack().uiData
    end
    local NewUGCMainPanel = UIManager.GetUI(UIManager.UI_Config.NewUGCMainPanel)
    if NewUGCMainPanel and NewUGCMainPanel.GetDataForJumpBack then
      uiData.NewUGCMainPanelData = NewUGCMainPanel:GetDataForJumpBack().ctorData
    end
    local UGC_Main_Mine_Sub_UI = UIManager.GetUI(UIManager.UI_Config.UGC_Main_Mine_Sub_UI)
    if UGC_Main_Mine_Sub_UI and UGC_Main_Mine_Sub_UI.GetDataForJumpBack then
      uiData.UGCMineSubCtorData = UGC_Main_Mine_Sub_UI:GetDataForJumpBack().uiData
    end
  elseif self.topMenuId == mode_selection_macro.Enum_TabID.MatchAlpha and self.secMenuId == mode_selection_macro.Enum_TabID.MatchNewbie then
    local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
    local view_id = logic_newbie_mode_selection:GetSelectViewInfo()
    return {
      ctorData = {
        [1] = {
          menuList = string.format("%s|%s", tostring(self.secMenuId), tostring(self.topMenuId)),
          viewId = view_id,
          onlyScroll = view_id and 1 or nil
        }
      }
    }
  end
  return {
    ctorData = {
      [1] = {
        menuList = string.format("%s|%s", tostring(self.secMenuId), tostring(self.topMenuId))
      }
    },
      }
end
function ModeSelection_Main_UIBP:OnCleanJumpBack()
  self.jumpBackUIData = nil
end
function ModeSelection_Main_UIBP:OnPlayedSlide(_, _, state)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnPlayedSlide state = " .. tostring(state))
  if state then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Content, false)
    self:SetWidgetVisible(self.UIRoot.Button_ChangeMode, false)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Content, true)
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local isFitVersion = PublishRegionMacros.IsFITVersion()
    self:SetWidgetVisible(self.UIRoot.Button_ChangeMode, not isFitVersion, true)
  end
end
function ModeSelection_Main_UIBP:OnResetTopPanel()
  log(bWriteLog and "ModeSelection_Main_UIBP:OnResetTopPanel")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Content, true)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isFitVersion = PublishRegionMacros.IsFITVersion()
  self:SetWidgetVisible(self.UIRoot.Button_ChangeMode, not isFitVersion, true)
end
function ModeSelection_Main_UIBP:OnWeaponStrengthDataRsp()
  log(bWriteLog and "ModeSelection_Main_UIBP:OnWeaponStrengthDataRsp")
  local logic_weapon_strength_weekly_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength_weekly_award)
  logic_weapon_strength_weekly_award:send_get_last_weapon_power_rank_reward_req()
end
function ModeSelection_Main_UIBP:OnWeaponStrengthWeeklyAward()
  log(bWriteLog and "ModeSelection_Main_UIBP:OnWeaponStrengthWeeklyAward")
  self:ShowWeaponStrengthWeeklyAward()
end
function ModeSelection_Main_UIBP:OnButton_UGCCommunity()
  self:PlayAudio(sound_config.click)
  log(bWriteLog and "[zzw]ModeSelection_Main_UIBP:click OnButton_UGCCommunity")
  local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
  mode_selection_macro.curHomeRedDot = false
  self:RefreshButton_UGCCommunity_RedPoint()
  local NewUGCMainPanel = UIManager.GetUI(UIManager.UI_Config.NewUGCMainPanel)
  local tagID = NewUGCMainPanel and NewUGCMainPanel.nTab or 0
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if tagID == Config_UGC.Config_UGC_TabID.PHome then
    log(bWriteLog and "[zzw]ModeSelection_Main_UIBP:self.tabWidgetList:Select(index), home jump")
    LogicUGCCommunity:JumpToUGCCommunityHomeChatPage(true)
  else
    log(bWriteLog and "[zzw]ModeSelection_Main_UIBP:self.tabWidgetList:Select(index), other jump")
    LogicUGCCommunity:JumpToUGCCommunityMainPange()
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_CommunityTips, false)
end
function ModeSelection_Main_UIBP:RefreshButton_UGCCommunity_RedPoint()
  log(bWriteLog and string.format("[vvwwzhang] ModeSelection_Main_UIBP: RefreshButton_UGCCommunity_RedPoint"))
  log(bWriteLog and "RefreshButton_UGCCommunity_RedPoint as mode_selection_macro.curHomeRedDot = " .. tostring(mode_selection_macro.curHomeRedDot))
  local bShow = mode_selection_macro.curHomeRedDot or false
  log(bWriteLog and "bShow = " .. tostring(bShow))
  self:SetWidgetVisible(self.UIRoot.Image_UGCCommunityRedPoint, bShow)
end
function ModeSelection_Main_UIBP:OnButton_WOWGuideClick()
  self:PlayAudio(sound_config.click)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MomentClick) == false then
    return
  end
  if not LobbySystem.CheckOpen(BP_ENUM_UGC_GUIDE_ENTRANCE) then
    ShowNotice(116009)
    return
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_Click_WowGuide)
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  Util_UGC.JumpStrategyGuideUrl()
end
function ModeSelection_Main_UIBP:OnButton_RankClick()
  self:PlayAudio(sound_config.click)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local RankSystem = require("client.slua.logic.rank.logic_rank")
  RankSystem.EventEnterRank(RankConfig.RankSelectEnum.wow)
end
function ModeSelection_Main_UIBP:OnButton_TaskClick()
  self:PlayAudio(sound_config.click)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:ShowTaskPanel()
  local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  Logic_UGC_TLog:ReportCommercialClick({
    source = UGCMacros.Enum_UGC_CommercialClick_Type.Mission
  })
end
function ModeSelection_Main_UIBP:OnButton_AppreciationGroupClick()
  self:PlayAudio(sound_config.click)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.UGC_APPRECIATION_BUTTON) then
    return
  end
  self.bClickedAppreciationBtn = true
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_get_review_panel_info_req()
end
function ModeSelection_Main_UIBP:UpdateApGroupBtnVisible(bHomeTab)
  self:SetWidgetVisible(self.UIRoot.Button_AppreciationGroup, false, true)
  self:RefreshAppreciationGroupRedDot()
end
function ModeSelection_Main_UIBP:OnButton_CreationSquare()
  self:PlayAudio(sound_config.click)
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if not LogicPufferBundle.IsFitLobbyResDownloaded() then
    ShowNotice(180109)
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCFirstSquareGetIn) or {}
  if Data and not Data.FirstSquareGetIn then
    Data.FirstSquareGetIn = true
    PlayerPrefsSystem.SaveTableToFile_N(Data, PlayerPrefsSystem.ePlayerPrefsType.eUGCFirstSquareGetIn)
  end
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  logic_moment.EnterMomentSquareUI(DataMgr.roleData.uid)
end
function ModeSelection_Main_UIBP:OnClickButtonCWoW()
  self:PlayAudio(sound_config.click_v1)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.Clear()
  UIManager.CloseUI(UIManager.UI_Config.mode_selection_main)
  local LogicUGCCreativeWow = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_creativewow)
  LogicUGCCreativeWow:ReqEnter()
end
function ModeSelection_Main_UIBP:RequestCommunityRedPoint()
  local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
  LogicUGCCommunity:RequestUGCCommunityMainPageGuideState()
end
function ModeSelection_Main_UIBP:RequestCommunityHomeRedPoint()
  local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
  local source = "wow_home"
  LogicUGCCommunity:RequestUGCCommunityHomePageGuideState(source)
end
function ModeSelection_Main_UIBP:UpdateUGCCommunityRedPoint()
  local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
  local active = LogicUGCCommunity:UGCCommunityMainPangeRedPointState()
  if active then
    local logic_community = require("client.slua.logic.community.logic_community")
    local bCanGetEntry = logic_community.GetShowEntry()
    if bCanGetEntry then
      self:RefreshForumRedPoint()
      self.UIRoot.Image_UGCCommunityRedPoint:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.UIRoot.Image_UGCCommunityRedPoint:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:RefreshForumRedPoint()
  end
end
function ModeSelection_Main_UIBP:OnUpdateCommunityRedPoint(_, _, fileType)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if fileType == PlayerPrefsSystem.ePlayerPrefsType.eUGCCommunityMainPageRedDot then
    self:UpdateUGCCommunityRedPoint()
  end
end
function ModeSelection_Main_UIBP:ShouldGuideThemeView(map_item)
  if map_item and slua.isValid(map_item.UIRoot) and map_item.GetItemData then
    local item_data = map_item:GetItemData()
    if item_data then
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      local theme_data = logic_mode_selection:GetValidThemeData(item_data.id)
      log(bWriteLog and string.format("[GuideThemeView] ShouldGuideThemeView viewId:%s group_type:%s ", tostring(item_data.id), tostring(item_data.group_type)))
      log_tree("[GuideThemeView] theme_data", theme_data)
      if theme_data and map_item.GetNewbieGuideWidget then
        local target_widget = map_item:GetNewbieGuideWidget()
        if target_widget then
          log(bWriteLog and "[GuideThemeView] ModeSelection_Main_UIBP:ShouldGuideThemeView")
          return true, item_data.id
        end
      end
    end
  end
  return false
end
function ModeSelection_Main_UIBP:OnPostMenuAlphaSwitch(_, __, menu_id)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:SetCacheGuideThemeViewId(nil)
  self:CloseGuideThemeViewUI()
  if not LobbySystem.roleData.rank_guide_flag then
    log(bWriteLog and "[GuideThemeView] rank_guide_flag " .. tostring(LobbySystem.roleData.rank_guide_flag))
    return
  end
  if not DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_MODE_SELECTION, mode_selection_macro.Enum_Newbie_Guide_Step_Key.STEP_THEME_RANK) then
    log(bWriteLog and "[GuideThemeView] Rank Theme Guide finish")
    return
  end
  if Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST then
    log(bWriteLog and "[GuideThemeView] ModeSelection_Main_UIBP:OnPostMenuAlphaSwitch tourist login")
    return
  end
  if self.topMenuId == mode_selection_macro.Enum_TabID.RankClassic then
    log(bWriteLog and "[GuideThemeView] OnPostMenuAlphaSwitch 1")
    for _, item in ipairs(self.ChildItemList) do
      if item and slua.isValid(item.UIRoot) then
        if item.IsDoubleItem and item:IsDoubleItem() and item.GetMapItem then
          log(bWriteLog and "[GuideThemeView] OnPostMenuAlphaSwitch 2 - 1")
          for i = 1, 2 do
            local map_item = item:GetMapItem(i)
            local bShould, view_id = self:ShouldGuideThemeView(map_item)
            if bShould then
              logic_mode_selection:SetCacheGuideThemeViewId(view_id)
              return
            end
          end
        else
          log(bWriteLog and "[GuideThemeView] OnPostMenuAlphaSwitch 2 - 2")
          local bShould, view_id = self:ShouldGuideThemeView(item)
          if bShould then
            logic_mode_selection:SetCacheGuideThemeViewId(view_id)
            return
          end
        end
      end
    end
  end
end
function ModeSelection_Main_UIBP:OnViewItemAnimAppearEnd(_, __, map_item, view_id)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if not view_id or logic_mode_selection:GetCacheGuideThemeViewId() ~= view_id or not map_item then
    return
  end
  log(bWriteLog and "[GuideThemeView] OnViewItemAnimAppearEnd " .. tostring(view_id))
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if not slua.isValid(self.UIRoot) or self.topMenuId ~= mode_selection_macro.Enum_TabID.RankClassic then
    log(bWriteLog and "[GuideThemeView] OnViewItemAnimAppearEnd invalid")
    return
  end
  if map_item.GetNewbieGuideWidget then
    local target_widget = map_item:GetNewbieGuideWidget()
    if target_widget then
      log(bWriteLog and "[GuideThemeView] OnViewItemAnimAppearEnd")
      local guide_text = LocUtil.GetLocalizeResStr(49105)
      UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 2, guide_text, target_widget, nil, true, 2)
      DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_MODE_SELECTION, mode_selection_macro.Enum_Newbie_Guide_Step_Key.STEP_THEME_RANK)
    end
  end
end
function ModeSelection_Main_UIBP:CloseGuideThemeViewUI()
  if UIManager.IsUIShow(UIManager.UI_Config.NewbieGuide_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
  end
  self.GuideThemeViewUI = nil
end
function ModeSelection_Main_UIBP:CheckWOWDynamicMatchReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDynamicMatchWOW)
  if saveData and saveData.isShowGuideWOW then
    log(bWriteLog and "ModeSelection_Main_UIBP:CheckDynamicMatchReddot is guide")
    return false
  end
  return true
end
function ModeSelection_Main_UIBP:CheckDynamicMatchReddot()
  log_tree(bWriteLog and "ModeSelection_Main_UIBP:CheckDynamicMatchReddot MatchLanguage:", DataMgr.MatchLanguage)
  local openSameLangMatch = DataMgr.MatchLanguage and DataMgr.MatchLanguage.only_match or false
  if not openSameLangMatch then
    log(bWriteLog and "ModeSelection_Main_UIBP:CheckDynamicMatchReddot not openSameLangMatch")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDynamicMatch)
  if saveData and saveData.isShowGuide then
    log(bWriteLog and "ModeSelection_Main_UIBP:CheckDynamicMatchReddot is guide")
    return false
  end
  return true
end
function ModeSelection_Main_UIBP:HideDynamicMatchReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = {isShowGuide = true}
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eDynamicMatch)
  self:SetWidgetVisible(self.UIRoot.Image_Reddot_Setting, false)
end
function ModeSelection_Main_UIBP:HideWOWDynamicMatchReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = {isShowGuideWOW = true}
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eDynamicMatchWOW)
  self:SetWidgetVisible(self.UIRoot.Image_Reddot_Setting, false)
end
function ModeSelection_Main_UIBP:OnUGCCommunityEntryDiscussPop(_, _, text, bShow)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnUGCCommunityEntryDiscussPop text : " .. text .. " bShow : " .. tostring(bShow))
  if not bShow then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_CommunityTips, false)
    return
  end
  if self:CheckShowCommercializationGuide() then
    return
  end
  self:ShowUGCDiscussGuide(text)
end
function ModeSelection_Main_UIBP:RefreshHomeRedDot(_, _, bHaveReddot)
  log(bWriteLog and "ModeSelection_Main_UIBP:RefreshHomeRedDot bHaveReddot : " .. tostring(bHaveReddot))
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if bHaveReddot == true then
    log(bWriteLog and "ModeSelection_Main_UIBP:RefreshHomeRedDot bHaveReddot is true ")
    mode_selection_macro.curHomeRedDot = true
    self:RefreshButton_UGCCommunity_RedPoint()
  end
end
function ModeSelection_Main_UIBP:RefreshUGCTaskReddot(_, _)
  log(bWriteLog and string.format("ModeSelection_Main_UIBP RefreshUGCTaskReddot"))
  local wowpass_task_reddot_data = require("client.slua.logic.ugc.WowPass.wowpass_task_reddot_data")
  if wowpass_task_reddot_data.HasRedDot() then
    self:SetWidgetVisible(self.UIRoot.Image_31, true)
  else
    self:SetWidgetVisible(self.UIRoot.Image_31, false)
  end
end
function ModeSelection_Main_UIBP:RefreshAppreciationGroupRedDot()
  local logic_ugc_appreciation_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_appreciation_group)
  if logic_ugc_appreciation_group and (logic_ugc_appreciation_group:HasAppreciationAward() or logic_ugc_appreciation_group:HasHistoryAppreciationAward()) then
    self.ForumBtnCfg[6].BShowRedDot = true
    self:RefreshForumRedPoint()
  else
    self.ForumBtnCfg[6].BShowRedDot = false
    self:RefreshForumRedPoint()
  end
end
function ModeSelection_Main_UIBP:ChangePageToRefreshRedDot()
  log(bWriteLog and string.format("ModeSelection_Main_UIBP ChangePageToRefreshRedDot"))
  local NewUGCMainPanel = UIManager.GetUI(UIManager.UI_Config.NewUGCMainPanel)
  if NewUGCMainPanel then
    local tagID = NewUGCMainPanel.nTab
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    if tagID == Config_UGC.Config_UGC_TabID.PHome then
      log(bWriteLog and "ModeSelection_Main_UIBP ChangePageToRefreshRedDot\239\188\154 Config_UGC.Config_UGC_TabID.PHome")
      self:RefreshButton_UGCCommunity_RedPoint()
    else
      log(bWriteLog and string.format("ModeSelection_Main_UIBP ChangePageToRefreshRedDot\239\188\154 other config"))
      self:UpdateUGCCommunityRedPoint()
    end
  end
end
function ModeSelection_Main_UIBP:RefreshMenuBetaScroll(_, _, bHomeTab)
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_SocialIsland, false, bHomeTab)
  self.UIRoot.WidgetSwitcher_SocialIsland:SetActiveWidgetIndex(1)
  self:SetWidgetVisible(self.UIRoot.Button_Task, not bHomeTab, not bHomeTab)
  self:SetWidgetVisible(self.UIRoot.Button_Room, self.canShowRoomList and not bHomeTab, not bHomeTab)
  self:UpdateApGroupBtnVisible(bHomeTab)
  self:OnRefreshSettingBtn(bHomeTab, true)
  self:OnRefreshRoomBtn(bHomeTab, true)
  self:OnRefreshFourmAndMoreBtn(bHomeTab, true)
  self:OnRefreshUGCWarehouseBtn(bHomeTab, true)
  self:OnRefreshButtonWoWPass(bHomeTab, true)
  self:SetWidgetVisible(self.UIRoot.Button_Activity, true, true)
end
function ModeSelection_Main_UIBP:UpdatePlayDataRedDot()
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  local bRed = logic_ugc_playlevel:HasRedpoint()
  self:SetWidgetVisible(self.UIRoot.Image_15, bRed)
end
function ModeSelection_Main_UIBP:ShowUGCDiscussGuide(text)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_CommunityTips, true)
  self.UIRoot.UTRichTextBlock_ComTips:SetText(text)
end
function ModeSelection_Main_UIBP:ShowWeaponStrengthWeeklyAward()
  log(bWriteLog and "ModeSelection_Main_UIBP:ShowWeaponStrengthWeeklyAward")
  local logic_weapon_strength_weekly_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength_weekly_award)
  if not logic_weapon_strength_weekly_award:CanJump() then
    return
  end
  local data = logic_weapon_strength_weekly_award:GetRewardData()
  if data == nil or next(data) == nil then
    return
  end
  if data.is_show then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Season_WeekResult_ShareInterface_UIBP)
end
function ModeSelection_Main_UIBP:OnRefreshSettingBtn(bHomeTab, bIsUGC)
  if LobbySystem.CheckOpen(910001) and not bHomeTab then
    if bIsUGC then
      self:SetWidgetVisible(self.UIRoot.Image_Reddot_Setting, self:CheckWOWDynamicMatchReddot())
      self.UIRoot.TextBlock_3:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    else
      self:SetWidgetVisible(self.UIRoot.Image_Reddot_Setting, self:CheckDynamicMatchReddot())
      self.UIRoot.TextBlock_3:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    end
  else
    self.UIRoot.Button_Setting:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    log(bWriteLog and "[v_yibxu]  ModeSelection_Main_UIBP:OnPostInitialize() LobbySystem.CheckOpen(910001) = " .. tostring(LobbySystem.CheckOpen(910001)))
  end
end
function ModeSelection_Main_UIBP:OnRefreshRoomBtn(bHomeTab, bIsUGC)
  if not bHomeTab then
    self.UIRoot.Button_Room:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
    if bIsUGC then
      self.UIRoot.TextBlock_2:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    else
      self.UIRoot.TextBlock_2:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    end
  else
    self.UIRoot.Button_Room:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Button_UGCRoom:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  self:SetWidgetVisible(self.UIRoot.Button_Room, self.canShowRoomList, true)
end
function ModeSelection_Main_UIBP:OnRefreshFourmAndMoreBtn(bHomeTab, bIsUGC)
  if not bHomeTab then
    if bIsUGC then
      self.UIRoot.CanvasPanel_94:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.CanvasPanel_94:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  else
    self.UIRoot.CanvasPanel_94:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
end
function ModeSelection_Main_UIBP:OnRefreshUGCWarehouseBtn(bHomeTab, bIsUGC)
  if not bHomeTab then
    self:SetWidgetVisible(self.UIRoot.Button_UGCCommunity, false, true)
  else
    self:SetWidgetVisible(self.UIRoot.Button_UGCCommunity, true, true)
  end
end
function ModeSelection_Main_UIBP:CheckUGCWarehousePoint()
  local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
  local hasNew = logic_ugc_inventory:HasNewItemsAllTab()
  self.ForumBtnCfg[4].BShowRedDot = hasNew
  self:RefreshForumRedPoint()
end
function ModeSelection_Main_UIBP:OnRefreshButtonWoWPass(bHomeTab, bIsUGC)
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if not LogicPufferBundle.IsFitLobbyResDownloaded() then
    self:SetWidgetVisible(self.UIRoot.Button_WoWPass, false)
    return
  end
  if not bHomeTab then
    local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
    local bSwitch = logic_ugc_WOWPass:IsSystemOpen()
    if bIsUGC and bSwitch then
      self:SetWidgetVisible(self.UIRoot.Button_WoWPass, true, true)
    else
      self:SetWidgetVisible(self.UIRoot.Button_WoWPass, false)
    end
  else
    self:SetWidgetVisible(self.UIRoot.Button_WoWPass, false)
  end
end
function ModeSelection_Main_UIBP:CheckShowCommercializationGuide()
  return false
end
function ModeSelection_Main_UIBP:ShowCommercializationGuide()
  local bShow = self:CheckShowCommercializationGuide()
  if bShow then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_UpdateTips, true)
    local index = 68741
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
      index = 68742
    end
    self.UIRoot.TextBlock_GuideTip:SetText(LocUtil.GetLocalizeResStr(index))
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_UpdateTips, false)
  end
end
function ModeSelection_Main_UIBP:ShowFloatTips(widget, cfg, extraOffsetX, extraOffsetY)
  local tipsUI = UIManager.ShowUI(UIManager.UI_Config.ModeSelection_UGC_Item_UIBP)
  local TipsParam = {
    offsetX = extraOffsetX or 20,
    offsetY = extraOffsetY or 100,
    wrapWidthType = 1
  }
  tipsUI.UIRoot:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 0.0))
  tipsUI:SetTips(widget, cfg, TipsParam)
  self:AddTimerOnce(0.1, function()
    if tipsUI.UIRoot and slua.isValid(tipsUI.UIRoot) then
      tipsUI.UIRoot:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
    end
  end)
end
function ModeSelection_Main_UIBP:ShowFloatTips2(widget, cfg, extraOffsetX, extraOffsetY)
  local tipsUI = UIManager.ShowUI(UIManager.UI_Config.ModeSelection_UGC_Item_UIBP)
  tipsUI.UIRoot:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 0.0))
  tipsUI:SetTips2(widget, extraOffsetX, extraOffsetY, cfg)
  self:AddTimerOnce(0.1, function()
    if tipsUI.UIRoot and slua.isValid(tipsUI.UIRoot) then
      tipsUI.UIRoot:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
    end
  end)
end
function ModeSelection_Main_UIBP:UpdateCountDownSeasonEndTime()
  local data = self.MenuAlphaScroll:GetItemData(self.alphaMenuIndex)
  if data.id == mode_selection_macro.Enum_TabID.RankClassic or data.id == mode_selection_macro.Enum_TabID.RankClassicMode then
    local currentSeasonCfg = CDataTable.GetTableData("SeasonInfo", DataMgr.season_id)
    if not currentSeasonCfg then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Time, false)
      self:UpdateSeasonEntry(false)
      log_error("CountDownSeasonEndTime currentSeasonCfg is nil")
      return
    end
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    local endTime = TimeUtil.TimeStringToUnixstamp(currentSeasonCfg.EndTime)
    local startTime = TimeUtil.TimeStringToUnixstamp(currentSeasonCfg.StartTime)
    local time = startTime - now
    if now > startTime and now < endTime then
      self:UpdateSeasonEntry(true)
    else
      self:UpdateSeasonEntry(false)
    end
    if 0 < time then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Time, false)
      log(bWriteLog and "CountDownSeasonEndTime hide1")
    else
      do
        local nowTime = TimeUtil.GetServerTimeInSec()
        local lastdaytime = TimeUtil.FormatCountDownTime_DHM_or_HMS(endTime - nowTime, 1)
        local lastday = math.floor((endTime - nowTime) / 86400)
        log(bWriteLog and "CountDownSeasonEndTime lastday = " .. lastday)
        if 0 <= lastday and lastday <= 6 then
          self:SetWidgetVisible(self.UIRoot.CanvasPanel_Time, true)
          if self.SeasonClock then
          else
            self.SeasonClock = self:AddClock(endTime, function()
              nowTime = TimeUtil.GetServerTimeInSec()
              local lastday = math.floor((endTime - nowTime) / 86400)
              local lasthours = math.fmod(math.floor((endTime - nowTime) / 3600), 24)
              local lastmins = math.fmod(math.floor((endTime - nowTime) / 60), 60)
              self.UIRoot.TextBlock_Time:SetText(LocUtil.LocalizeResFormat(86494, lastday, lasthours, lastmins))
              log(bWriteLog and string.format("ModeSelection_Main_UIBP:UpdateCountDownSeasonEndTime Newlasttime = %s\229\164\169%s\230\151\182%s\229\136\134", lastday, lasthours, lastmins))
            end)
          end
        else
          self:SetWidgetVisible(self.UIRoot.CanvasPanel_Time, false)
          log(bWriteLog and "CountDownSeasonEndTime hide2")
        end
      end
    end
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Time, false)
    log(bWriteLog and "CountDownSeasonEndTime hide3")
  end
end
function ModeSelection_Main_UIBP:UpdateSeasonEntry(SeasonIsOpen)
  log(bWriteLog and "ModeSelection_Main_UIBP:UpdateSeasonEntry SeasonIsOpen " .. tostring(SeasonIsOpen))
  local ModeSelection_Main_Segment = require("client.slua.umg.ModeSelection.ModeSelection_Main_Segment")
  ModeSelection_Main_Segment:UpdateSeasonEntryVisible(self.UIRoot, SeasonIsOpen, self)
  if self.secMenuId == 120 then
    ModeSelection_Main_Segment:UpdateSeasonEntryVisible(self.UIRoot, false, self)
  end
end
function ModeSelection_Main_UIBP:OnOpenSeasonUI()
  self:PlayAudio(sound_config.click)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnOpenSeasonUI")
  local logic_season_util = require("client.logic.season.logic_season_util")
  local needCloseSelf = logic_season_util.OpenClassicSeasonUI()
  if needCloseSelf then
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    ui_jump_manager.Clear()
    self:CloseSelf()
  end
end
function ModeSelection_Main_UIBP:OnClickWoWPass()
  self:PlayAudio(sound_config.click_v1)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OpenWowPassPanel(UIManager.UI_Config.UGC_WOW_PASS_MainUI, nil, true)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnClickWoWPass UGC_WOW_PASS_MainUI")
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_WoWPass_Open_From_MainPanel)
end
function ModeSelection_Main_UIBP:RefreshFriendlyPoint()
  log(bWriteLog and "ModeSelection_Main_UIBP:RefreshFriendlyPoint")
  local Logic_Friendly = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Friendly)
  local frinenlyInfo = Logic_Friendly:GetFriendlyInfo()
  if frinenlyInfo then
    local curr_value = frinenlyInfo.curr_value or 0
    local ProgressBar_    local ProgressBar_1 = 0
    local box_price = CDataTable.GetTableData("SystemConfig", "FriendlyGiftBoxPrice")
    box_price = box_price and tonumber(box_price.ConfigValue) or 100
    if curr_value < box_price then
      ProgressBar_0 = curr_value / box_price
      self:SetTexture(self.UIRoot.Image_Friendly_box, "/Game/Arts/UI/TableIcons/ItemIcon/Item/Icon_StrategicMaterialBox_Empty_128.Icon_StrategicMaterialBox_Empty_128")
    else
      ProgressBar_0 = 1
      ProgressBar_1 = (curr_value - box_price) / box_price
      self:SetTexture(self.UIRoot.Image_Friendly_box, "/Game/Arts/UI/TableIcons/ItemIcon/Item/Icon_StrategicMaterialBox_128.Icon_StrategicMaterialBox_128")
    end
    self.UIRoot.ProgressBar_0:SetPercent(ProgressBar_0)
    self.UIRoot.ProgressBar_1:SetPercent(ProgressBar_1)
  end
end
function ModeSelection_Main_UIBP:UpdateJumpData(url_params)
  local canUpdate = false
  if url_params and url_params.menuList then
    canUpdate = true
    local StringUtil = require("common.string_util")
    self.menu_list = StringUtil.Split(url_params.menuList, "|")
    for k, v in pairs(self.menu_list) do
      self.menu_list[k] = tonumber(v)
    end
    firstInModeSelectionUI = true
  end
  if canUpdate then
    self:OnUpdateJumpShow()
  end
end
function ModeSelection_Main_UIBP:OnUpdateJumpShow()
  self:RefreshTopMenuId(self.menus)
  self.MenuAlphaScroll:SetData(self.menus)
end
function ModeSelection_Main_UIBP:RefreshWOWActEntry()
  log(bWriteLog and "ModeSelection_Main_UIBP:RefreshWOWActEntry.")
  local DisplayScene = ActivityDisplayScene.WOW
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  local SystemName = ActivityRedDot.DisplayScene2SystemName(DisplayScene)
  local RedDot = ActivityRedDot.GetRedDotData(SystemName)
  if RedDot then
    self.UIRoot.Reddot_Anchor_Item_Act:Bind(RedDot)
  end
end
function ModeSelection_Main_UIBP:RefreshWOWPassEntry()
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  if logic_ugc_WOWPass:IsSystemOpen() then
    self.UIRoot.Reddot_Anchor:ShowRedPointByPath("/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item03.Reddot_Anchor_Item03")
    self:SetWidgetVisible(self.UIRoot.Reddot_Anchor, logic_ugc_WOWPass:GetWOWPassRedDotState(), false)
  end
end
function ModeSelection_Main_UIBP:RefreshWOWPassBuyState()
  self.UIRoot.TextBlock_Ashlike:SetText(LocUtil.LocalizeResFormat(68890))
  self.UIRoot.TextBlock_Ashlike02:SetText(LocUtil.LocalizeResFormat(68890))
  self.UIRoot.WidgetSwitcher_Status:SetActiveWidgetIndex(1)
end
function ModeSelection_Main_UIBP:ShowForumBubbleTips(text)
  self.UIRoot.CanvasPanel_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.TextBlock_Tips1:SetText(text)
  self.ShowForumBubble = true
end
function ModeSelection_Main_UIBP:HideForumBubbleTips()
  log(bWriteLog and "ModeSelection_Main_UIBP:HideForumBubbleTips()  ")
  self.UIRoot.CanvasPanel_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.ShowForumBubble then
    local logic_ugc_ForumBubble = require("client.slua.logic.ugc.logic_ugc_ForumBubble")
    logic_ugc_ForumBubble:SaveForumBubbleTipsData(logic_ugc_ForumBubble.ENUM_BUBBLE_TIPS_TYPE.Forum)
  end
end
function ModeSelection_Main_UIBP:OnClickForumBubbleTips()
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnClickForumBubbleTips()  ")
  self:HideForumBubbleTips()
end
function ModeSelection_Main_UIBP:OnClickWOWCreatorForum()
  self:PlayAudio(sound_config.click)
  local logic_ugc_ForumBubble = require("client.slua.logic.ugc.logic_ugc_ForumBubble")
  logic_ugc_ForumBubble:OpenWOWCreatorForum()
end
function ModeSelection_Main_UIBP:OnPandoraForumTipsDataResponse(_, _, data)
end
function ModeSelection_Main_UIBP:OnGetAppreciationGroupInfo(_, _, info)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnGetAppreciationGroupInfo()  ", info)
  if not self.bClickedAppreciationBtn then
    return
  end
  self.bClickedAppreciationBtn = false
  local logic_ugc_appreciation_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_appreciation_group)
  if not logic_ugc_appreciation_group then
    return
  end
  if info.status == logic_ugc_appreciation_group.APPRECIATION_GROUP_STATUS.REVIEW_PANEL_STATUS_APPROVED then
    UIManager.ShowUI(UIManager.UI_Config.UGC_AppreciationGroup_Main, info)
  elseif info.status == logic_ugc_appreciation_group.APPRECIATION_GROUP_STATUS.REVIEW_PANEL_STATUS_REJECTED then
    UIManager.ShowUI(UIManager.UI_Config.UGC_AppreciationGroup_Exit_UIBP, info)
  elseif info.status == logic_ugc_appreciation_group.APPRECIATION_GROUP_STATUS.REVIEW_PANEL_STATUS_ACTIVE_EXIT then
    UIManager.ShowUI(UIManager.UI_Config.UGC_AppreciationGroup_Exit_UIBP, info)
  elseif info.status == logic_ugc_appreciation_group.APPRECIATION_GROUP_STATUS.REVIEW_PANEL_STATUS_PASSIVE_EXIT then
    UIManager.ShowUI(UIManager.UI_Config.UGC_AppreciationGroup_Exit_UIBP, info)
  elseif info.status == logic_ugc_appreciation_group.APPRECIATION_GROUP_STATUS.REVIEW_PANEL_STATUS_NOT_JOIN then
    UIManager.ShowUI(UIManager.UI_Config.UGC_AppreciationGroup_Join, info)
  end
end
function ModeSelection_Main_UIBP:ShowAlbumThemeUI()
  log(bwriteLog and "ModeSelection_Main_UIBP:ShowAlbumThemeUI")
  log(bWriteLog and "ModeSelection_Main_UIBP:ShowAlbumThemeUI self.topMenuId: " .. tostring(self.topMenuId))
  if self.topMenuId ~= mode_selection_macro.Enum_TabID.UGC then
    self:OnShowNewbieGuide()
  end
end
function ModeSelection_Main_UIBP:OnJoinTeamEvent()
  log(bWriteLog and "ModeSelection_Main_UIBP:OnJoinTeamEvent")
  local logic_ugc_hall_mod = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall_mod)
  logic_ugc_hall_mod:OnJoinTeamEventInModeSelection()
end
function ModeSelection_Main_UIBP:OnShowNewbieGuide()
  local logic_ugc_album_theme = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_album_theme)
  local AlbumThemeList = logic_ugc_album_theme:GetAlbumThemeList()
  if not AlbumThemeList or not next(AlbumThemeList) then
    log(bWriteLog and "ModeSelection_Main_UIBP:OnShowNewbieGuide AlbumThemeList is nil")
    return
  end
  local FirstDayAlbumThemeList = logic_ugc_album_theme:GetFirstDayAlbumThemeData()
  if not FirstDayAlbumThemeList or not next(FirstDayAlbumThemeList) then
    log(bWriteLog and "ModeSelection_Main_UIBP:OnShowNewbieGuide FirstDayAlbumThemeList is nil")
    return
  end
  local TipsShowState = logic_ugc_album_theme:CheckAlbumThemeTips()
  if not TipsShowState then
    log(bWriteLog and "ModeSelection_Main_UIBP:OnShowNewbieGuide TipsShowState is nil or false")
    return
  end
  local RandomAlbumThemeIndex = math.random(1, #FirstDayAlbumThemeList)
  log(bWriteLog and "ModeSelection_Main_UIBP:OnShowNewbieGuide RandomAlbumThemeIndex: " .. tostring(RandomAlbumThemeIndex))
  local AlbumTheme = FirstDayAlbumThemeList[RandomAlbumThemeIndex]
  log_tree("ModeSelection_Main_UIBP:OnShowNewbieGuide AlbumTheme", AlbumTheme)
  local TipsText = LocUtil.LocalizeResFormat(87278, AlbumTheme.name)
  self:AddTimerOnce(0, function()
    local TargetWidget = self.MenuAlphaScroll:GetIndexOfWidget(3)
    log(bWriteLog and "ModeSelection_Main_UIBP:OnShowNewbieGuide TargetWidget: " .. tostring(TargetWidget))
    local tipsParam = {
      widget = TargetWidget,
      content = TipsText,
      offsetX = 200,
      offsetY = 28,
      bHideBtnClose = true
    }
    UIManager.ShowUI(UIManager.UI_Config.CommonTextTips_UIBP, tipsParam)
    local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
    UGCTLogReport:ReportDelay(TLogEventDefine.UGC_AlbumTheme_TipsShow, nil, "AlbumThemeID = " .. tostring(AlbumTheme.id))
    logic_ugc_album_theme:SaveAlbumThemeShowTipsTime()
  end)
  self.TimerTips = self:AddTimerOnce(8, function()
    UIManager.CloseUI(UIManager.UI_Config.CommonTextTips_UIBP)
  end)
end
function ModeSelection_Main_UIBP:OnClearAlbumThemeTimer()
  if self.TimerTips then
    self:RemoveTimer(self.TimerTips)
    self.TimerTips = nil
  end
end
function ModeSelection_Main_UIBP:GetAlphaMenuItemWidgetByTabID(tabID)
  return self:GetMenuItemWidgetByTabID(self.MenuAlphaScroll, tabID)
end
function ModeSelection_Main_UIBP:GetBetaMenuItemWidgetByTabID(tabID, needScroll)
  return self:GetMenuItemWidgetByTabID(self.MenuBetaScroll, tabID, needScroll)
end
function ModeSelection_Main_UIBP:GetMenuItemWidgetByTabID(loopScroll, tabID, needScroll)
  local index
  local menuList = loopScroll:GetSetData()
  for k, v in pairs(menuList) do
    if v.id == tabID then
      index = k
    end
  end
  log_format("ModeSelection_Main_UIBP:MenuItemWidgetByTabID. tabID = [%s], index = [%s]", tabID, index)
  if not index then
    return nil
  end
  if needScroll then
    loopScroll:ScrollToItem(index)
  end
  local widget = loopScroll:GetIndexOfWidget(index)
  return widget, index
end
function ModeSelection_Main_UIBP:OnClickMenuLevelUnlockGuide(loopScroll, index)
  local data = loopScroll:GetItemData(index)
  if not data then
    log_format("ModeSelection_Main_UIBP:OnClickMenuAlphaLevelUnlockGuide data is nil. index = [%d]", index)
    return
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local feature
  if data.id == mode_selection_macro.Enum_TabID.MatchArena then
    feature = level_unlock_manager.featureDef.teamCompetitionMode
  elseif data.id == mode_selection_macro.Enum_TabID.RankClassic then
    feature = level_unlock_manager.featureDef.matchMode
  elseif data.id == mode_selection_macro.Enum_TabID.Other then
    feature = level_unlock_manager.featureDef.entertainMode
  end
  if not feature then
    log_format("ModeSelection_Main_UIBP:OnClickMenuAlphaLevelUnlockGuide feature is nil. id = [%d]", data.id)
    return
  end
  level_unlock_manager:OnClickFeature(feature)
end
function ModeSelection_Main_UIBP:JumpToAlphaMenuByTabID(tabID)
  local widget, index = self:GetMenuItemWidgetByTabID(self.MenuAlphaScroll, tabID)
  if not widget then
    return
  end
  self:OnMenuAlphaClick(widget, index)
end
function ModeSelection_Main_UIBP:JumpToBetaMenuByTabID(tabID)
  local widget, index = self:GetMenuItemWidgetByTabID(self.MenuBetaScroll, tabID)
  if not widget then
    return
  end
  self:OnMenuBetaClick(widget, index)
end
function ModeSelection_Main_UIBP:GetViewMapItemByViewID(viewID)
  local targetIndex, targetSubIndex, targetWidget
  for k, v in pairs(self.ChildItemList) do
    if v.data and v.data.id == viewID then
      targetIndex = k
      targetWidget = v.UIRoot
      break
    end
    for i = 1, 2 do
      local itemName = "item" .. i
      local itemInfo = v[itemName]
      if itemInfo and itemInfo.data and itemInfo.data.id == viewID then
        targetIndex = k
        targetSubIndex = i
        targetWidget = itemInfo.UIRoot
        break
      end
    end
  end
  log_format("ModeSelection_Main_UIBP:GetViewMapItemByViewID. viewID = [%d], targetIndex = [%s], targetSubIndex = [%s], targetWidget = [%s]", viewID, targetIndex, targetSubIndex, targetWidget)
  return targetWidget
end
function ModeSelection_Main_UIBP:RefreshForumRedPoint()
  local show_red = false
  for k, v in pairs(self.ForumBtnCfg) do
    if v.BShowRedDot then
      show_red = true
      break
    end
  end
  if show_red then
    self.UIRoot.Image_ForumRedPoint:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Image_ForumRedPoint:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ModeSelection_Main_UIBP:UpdateWowCoin()
  local bSwitch_money = LobbySystem.CheckOpen(BP_ENUM_UGC_RECHARGE)
  if self.UIRoot.Button_CurrencyInfo1 then
    self:SetWidgetVisible(self.UIRoot.Button_CurrencyInfo1, bSwitch_money, true)
  end
  if self.UIRoot.Button_Currency then
    self:SetWidgetVisible(self.UIRoot.Button_Currency, bSwitch_money, true)
  end
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_WowCurrency, bSwitch_money)
  if not bSwitch_money then
    log(bWriteLog and "UGC_Hall_Top_Item_UIBP:UpdateWowCoin bSwitch_money = " .. tostring(bSwitch_money))
    return
  end
  local Logic_ItemUtils = require("client.slua.logic.common.Logic_ItemUtils")
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  local WOW_BG = Logic_ItemUtils.GetCurrencyIconPath(CoinMacro.UGCAdvancedCrystal)
  if self.UIRoot.Image_WoWCurrency then
    self:SetTexture(self.UIRoot.Image_WoWCurrency, WOW_BG)
  end
  if self.UIRoot.TextBlock_CurrencyNum then
    self.UIRoot.TextBlock_CurrencyNum:SetText(FuncUtil.Conv_Int64ToText(DataMgr.ugc_advanced_crystal))
  end
end
function ModeSelection_Main_UIBP:CoinIconClick()
  self:PlayAudio(sound_config.click_v1)
  local config_ugc_crystal_coin_tips = require("client.slua.umg.ugc.Commercialization.config_ugc_crystal_coin_tips")
  local tipsUI = UIManager.ShowUI(UIManager.UI_Config.UGC_Crystal_Coin_Tips_UIBP, self.UIRoot.Button_CurrencyInfo1, config_ugc_crystal_coin_tips)
  tipsUI.UIRoot:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 0.0))
  self:AddTimerOnce(0.1, function()
    if tipsUI.UIRoot and slua.isValid(tipsUI.UIRoot) then
      tipsUI.UIRoot:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
    end
  end)
end
function ModeSelection_Main_UIBP:CoinAddClick()
  self:PlayAudio(sound_config.click_v1)
  local Logic_UGC_Recharge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_recharge)
  Logic_UGC_Recharge:SetEnterFrom(Logic_UGC_Recharge.E_WOWEntryType.WOWLobbyOld)
  Logic_UGC_Recharge:OpenRechargeUI()
end
function ModeSelection_Main_UIBP:OnUGCAdvancedCrystalUpdate()
  print(bWriteLog and "ModeSelection_Main_UIBP:OnUGCAdvancedCrystalUpdate")
  self:UpdateWowCoin()
end
function ModeSelection_Main_UIBP:RefreshLanMatchImage()
  if not self.UIRoot or not self.UIRoot.Image_LanMatch then
    return
  end
  local matchLang = DataMgr and DataMgr.MatchLanguage
  local bOn = matchLang and matchLang.only_match == true
  self:SetWidgetVisible(self.UIRoot.Image_LanMatch, bOn)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CModeSelection_Main_UIBP = class(ui_base, nil, ModeSelection_Main_UIBP)
return CModeSelection_Main_UIBP