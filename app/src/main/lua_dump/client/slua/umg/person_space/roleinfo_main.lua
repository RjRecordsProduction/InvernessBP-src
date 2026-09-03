local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
local gem_report_utils = require("client.logic.store.gem_report_utils")
local TabIDPageToGem = {
  [RoleInfoMainSystem.Segment] = gem_report_utils.SubEventName_PersonSpaceSegment,
  [RoleInfoMainSystem.Combat] = gem_report_utils.SubEventName_PersonSpaceCombat,
  [RoleInfoMainSystem.HistoryCombat] = gem_report_utils.SubEventName_PersonSpaceHistory,
  [RoleInfoMainSystem.Honor] = gem_report_utils.SubEventName_PersonSpaceHonor,
  [RoleInfoMainSystem.Honor_SubTab.Achievement] = gem_report_utils.SubEventName_PersonSpaceHonor_Achievement,
  [RoleInfoMainSystem.Honor_SubTab.Alias] = gem_report_utils.SubEventName_PersonSpaceHonor_Alias,
  [RoleInfoMainSystem.Personalize] = gem_report_utils.SubEventName_PersonSpaceModifyInfo,
  [RoleInfoMainSystem.IntimateRelationship] = gem_report_utils.SubEventName_PersonSpaceRelation,
  [RoleInfoMainSystem.IntimateRelationship_SubTab.Close] = gem_report_utils.SubEventName_PersonSpaceRelation_Close,
  [RoleInfoMainSystem.IntimateRelationship_SubTab.Partner] = gem_report_utils.SubEventName_PersonSpaceRelation_Partner,
  [RoleInfoMainSystem.IntimateRelationship_SubTab.Exhibit] = gem_report_utils.SubEventName_PersonSpaceRelation_Exhibit,
  [RoleInfoMainSystem.WOW] = gem_report_utils.SubEventName_WOW,
  [RoleInfoMainSystem.WOW_SubTab.WorkData] = gem_report_utils.SubEventName_WOW_WorkData,
  [RoleInfoMainSystem.WOW_SubTab.PlayData] = gem_report_utils.SubEventName_WOW_PlayData,
  [RoleInfoMainSystem.RoleInfoCard] = gem_report_utils.SubEventName_PersonSpaceCredit,
  [RoleInfoMainSystem.Credit] = gem_report_utils.SubEventName_PersonSpaceCredit
}
local TabIDToTLog = {
  [RoleInfoMainSystem.Segment] = TLogEventDefine.PersonSpaceSegment,
  [RoleInfoMainSystem.Combat] = TLogEventDefine.PersonSpaceCombat,
  [RoleInfoMainSystem.HistoryCombat] = TLogEventDefine.PersonSpaceHistory,
  [RoleInfoMainSystem.Collect] = TLogEventDefine.CollectMain,
  [RoleInfoMainSystem.CollectMain] = TLogEventDefine.CollectRoad,
  [RoleInfoMainSystem.CollectRoom] = TLogEventDefine.CollectRoom,
  [RoleInfoMainSystem.CollectLib] = TLogEventDefine.CollectLibrary,
  [RoleInfoMainSystem.Milestone] = TLogEventDefine.Milestone,
  [RoleInfoMainSystem.CollectRank] = TLogEventDefine.CollectRank,
  [RoleInfoMainSystem.Honor] = TLogEventDefine.PersonSpaceHonor,
  [RoleInfoMainSystem.Honor_SubTab.Achievement] = TLogEventDefine.PersonSpaceHonor_Achievement,
  [RoleInfoMainSystem.Honor_SubTab.Alias] = TLogEventDefine.PersonSpaceHonor_Alias,
  [RoleInfoMainSystem.Personalize] = TLogEventDefine.PersonSpaceModifyInfo,
  [RoleInfoMainSystem.IntimateRelationship] = TLogEventDefine.PersonSpaceRelation,
  [RoleInfoMainSystem.WOW] = TLogEventDefine.PersonSpaceWOW,
  [RoleInfoMainSystem.WOW_SubTab.WorkData] = TLogEventDefine.PersonSpaceWOW_WorkData,
  [RoleInfoMainSystem.WOW_SubTab.PlayData] = TLogEventDefine.PersonSpaceWOW_PlayData,
  [RoleInfoMainSystem.RoleInfoCard] = TLogEventDefine.PersonSpaceCard,
  [RoleInfoMainSystem.Credit] = TLogEventDefine.PersonSpaceCredit
}
local refreshRedDotCollectSubTab = {
  [RoleInfoMainSystem.Collect] = true,
  [RoleInfoMainSystem.CollectMain] = true,
  [RoleInfoMainSystem.CollectRoom] = true,
  [RoleInfoMainSystem.CollectLib] = true,
  [RoleInfoMainSystem.Milestone] = true,
  [RoleInfoMainSystem.CollectRank] = true
}
local UI_Config = UIManager.UI_Config
local uiCfg = {
  [RoleInfoMainSystem.Segment] = {
    cfg = UI_Config.roleinfo_segment,
    locResID = "43269",
    redDotKey = "baseInfoRed",
    needShowBaseBg = false
  },
  [RoleInfoMainSystem.Combat] = {
    cfg = UI_Config.roleinfo_combat,
    locResID = "43779",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.HistoryCombat] = {
    cfg = UI_Config.roleinfo_history,
    locResID = "8142",
    redDotKey = "historyRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.Collect] = {
    locResID = 77527,
    redDotKey = "collectRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.CollectRoom] = {
    cfg = UI_Config.Collect_Room_UIBP,
    locResID = 77476,
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.CollectMain] = {
    cfg = UI_Config.Collect_Road_UIBP,
    locResID = 77475,
    redDotKey = "collectRoad",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.CollectLib] = {
    cfg = UI_Config.Collect_Library_UIBP,
    locResID = 77477,
    redDotKey = "collectLib",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.Milestone] = {
    cfg = UI_Config.Collect_Milestone_UIBP,
    locResID = 82001,
    redDotKey = "collectMilestone",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.CollectRank] = {
    cfg = UI_Config.Collect_TimeLimitedRanking_UIBP,
    locResID = 77603,
    redDotKey = "collectRank",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.Honor] = {
    locResID = "62266",
    redDotKey = "honorRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.Honor_SubTab.Achievement] = {
    locResID = "62272",
    redDotKey = "achievementRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.Honor_SubTab.HonourCertificate] = {
    cfg = UI_Config.HonourCertificate_Main_UIBP,
    locResID = "8801364",
    redDotKey = "honourCertificateRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.Honor_SubTab.Alias] = {
    cfg = UI_Config.Title_Main_UIBP,
    locResID = "62273",
    redDotKey = "aliasShowRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.Honor_SubTab.WeaponStrenthHonor] = {
    cfg = UI_Config.Season_WeaponStrength_Display_UIBP,
    locResID = "68218",
    redDotKey = "WeaponStrenthHonorShowRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.Personalize] = {
    cfg = UI_Config.Personalization_UIBP,
    locResID = "62159",
    redDotKey = "settingRed",
    needShowBaseBg = false
  },
  [RoleInfoMainSystem.IntimateRelationship] = {
    locResID = "199604",
    redDotKey = "partnerRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.IntimateRelationship_SubTab.Close] = {
    cfg = UI_Config.roleinfo_relationship2,
    locResID = "199604",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.IntimateRelationship_SubTab.Partner] = {
    cfg = UI_Config.Lobby_RoleInfo_IntimateRelationship_Interact_UIBP,
    locResID = "73265",
    needShowBaseBg = false
  },
  [RoleInfoMainSystem.IntimateRelationship_SubTab.Exhibit] = {
    cfg = UI_Config.Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP,
    locResID = "73296",
    needShowBaseBg = false
  },
  [RoleInfoMainSystem.WOW] = {
    locResID = "80031",
    redDotKey = "WOWRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.WOW_SubTab.WorkData] = {
    cfg = UI_Config.UGC_Player_PlayData_UIBP,
    locResID = "8910016",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.WOW_SubTab.PlayData] = {
    cfg = UI_Config.UGC_Player_PlayData_UIBP,
    locResID = "8910017",
    redDotKey = "PlayDataRed",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.WOW_SubTab.AuthorHome] = {
    cfg = UI_Config.UGC_Mine_Creative_Homepage_UIBP,
    locResID = "8910017",
    needShowBaseBg = true
  },
  [RoleInfoMainSystem.RoleInfoCard] = {
    cfg = UI_Config.Lobby_RoleInfo_Card_UIBP,
    locResID = "45907",
    redDotKey = "newCardRed",
    needShowBaseBg = false
  },
  [RoleInfoMainSystem.Credit] = {
    cfg = UI_Config.ReputationSystem_Homepage_UIBP,
    locResID = "29630",
    needShowBaseBg = true
  }
}
local SubTabList = {}
local RedIndex2RedDotKeyMap
local SubTabId2MainTabIndex = {}
local Index2TabID = {}
local collectDefaultIndex = 4
local UI_RoleInfoMain = {}
function UI_RoleInfoMain:ctor(_, index, isJumpBack, uid, intimacyType, personalizeExtraData, subTabID, extraData)
  if index then
    self.TabID = tonumber(index)
  else
    self.TabID = RoleInfoMainSystem.Segment
  end
  self.  self.nCurPageUI = nil
  self.  self.  log_tree("  UI_RoleInfoMain:ctor. personalizeExtraData ", personalizeExtraData)
  log_warning(bWriteLog and "  : self.TabID" .. tostring(self.TabID))
  if isJumpBack then
    self.    RoleInfoMainSystem.BeforeShowUI(index, nil, uid, nil, isJumpBack.inputAchieveInfo)
  else
    self.SubTabID = nil
  end
  if subTabID then
    self.SubTabID = subTabID
  end
  self.animFlagTb = {}
  self.collectLibMaster = true
  self.mod_id = extraData and extraData.mod_id or nil
  self._sRecordJumpToUIdUrl = extraData and extraData.sRecordJumpToUIdUrl
  self.openSource = extraData and extraData.openSource or nil
  if IsWoWEditor then
    self.TabID = RoleInfoMainSystem.WOW
  end
end
function UI_RoleInfoMain:OnInitialize()
  UI_RoleInfoMain.__super.OnInitialize(self)
  RedIndex2RedDotKeyMap = {}
  SubTabId2MainTabIndex = {}
  self.Common_Tab = self:InitVerticalTextTab(self.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP)
  self.Common_Tab:AddOnTabClickedCallback(self.OnVerticalTextTabClickedCallback, self)
  self.Common_Tab:AddOnTabRefreshCallback(self.OnVerticalIconTabRefreshCallback, self)
  self.Common_Tab:AddOnTabSelectedCallback(self.OnSelectTab, self)
  self.Common_Tab:AddOnSubTabClickedCallback(self.OnVerticalTextSubTabClickedCallback, self)
  self.Common_Tab:AddOnSubTabRefreshCallback(self.OnVerticalIconSubTabRefreshCallback, self)
  local UIUtil = require("client.common.ui_util")
  self.Common_Tab:SetItemClickCDType(UIUtil.ClickFrequencyLimit.roleinfo_main)
  self.Common_Tab:SetSubItemClickCDType(UIUtil.ClickFrequencyLimit.roleinfo_main)
end
function UI_RoleInfoMain:RegistEvents()
  UI_RoleInfoMain.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_OPEN, self.ResetHide, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_CLOSE, self.ResetShow, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_PREVIEW_OPEN, self.ResetHide, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_PREVIEW_CLOSE, self.ResetShow, self)
  self:AddCommonEvent(EVENTTYPE_CLICK, EVENTID_ICON_SHOW, self.HideTips, self)
  self:AddCommonEvent(EVENTTYPE_CAREER, EVENTID_CAREER_SHOW_ENTRY, self.OnShowCareerEntry, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_PERSON_SPACE_AFTER_CLOSE, self.OnAfterPersonSpaceClose, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.HideLobbyUI)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnButton_CloseClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickHideTips, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Info, self.OnButton_InfoClick, self)
  self:AddControlEventByControl(self.UIRoot.DX_BaseInfoUnfold, "OnAnimationFinished", self.OnEnterAnimFinished, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_HONOR_ALIAS_CLICK_SHARE_ALIAS_LIST_UPDATE_BUTTON, self.UpdataCanvasPanel0Show, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_SELECT_MOD, self.OnSelectModForMatch, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_REDDOT, self.RefreshCollectReddot, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_INTIMACY_PHOTO_SHARE, self.OnRefreshUIVisible, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_BYBLACKLIST_UPDATE, self.OnByBlackListUpdate, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR, self.OnUpdateAuthor, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, self.RefreshIntimacyReddot, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_BACKGROUND_SCENE_LOADED, self.OnBackgroundSceneLoaded, self)
end
function UI_RoleInfoMain:OnPostInitialize()
  UI_RoleInfoMain.__super.OnPostInitialize(self)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(RoleInfoSystem.CurShowPlayerInfoUid)
  if profile then
    self:UpdateUI()
  else
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      RoleInfoSystem.CurShowPlayerInfoUid
    }, function()
      log(bWriteLog and "UI_RoleInfoMain:OnPostInitialize.logic_profile_get_wrap.GetNormalProfiles slua.isValid(self.UIRoot) = " .. tostring(slua.isValid(self.UIRoot)))
      if slua.isValid(self.UIRoot) then
        self:UpdateUI()
      end
    end, Enum_PROFILE_REPORT_CFG.COLLECT, 0, true)
  end
  log_warning(bWriteLog and "  UI_RoleInfoMain:OnPostInitialize. self.nTab: " .. tostring(self.nTab))
  if self.nTab ~= RoleInfoMainSystem.CollectMain then
    local collect_theme_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_theme_module)
    collect_theme_module:ReqCfg()
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    if not UIManager.IsUIShow(UIManager.UI_Config.Collect_Guide_UIBP) and not collect_module:DataHasBeenRequested() then
      local CollectHandler = require("client.network.Protocol.CollectHandler")
      CollectHandler.send_get_collect_sys_main_data_req()
    end
  end
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  logic_roleInfo_TeamUpFrame:send_get_team_notify_skin_list()
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  logic_ugc_playlevel:PreEnter()
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  logic_friend_interact_record:ReportInteractionReq(tostring(RoleInfoSystem.CurShowPlayerInfoUid), logic_friend_interact_record.reportInteractionType.PersonSpaceOrInfo)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  log_format("[HonourCert] OnPostInitialize - checking region, IsBLUEHOLE=%s, region=%s", tostring(PublishRegionMacros.IsBLUEHOLE()), tostring(Client.GetPublishRegion()))
  if not PublishRegionMacros.IsBLUEHOLE() then
    log_format("[HonourCert] not IsBLUEHOLE, requesting cert version")
    local logic_roleInfo_HonourCertificate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_HonourCertificate)
    local RoleInfoSystem_cert = require("client.logic.roleinfo.logic_roleinfo")
    local certUid = RoleInfoSystem_cert.CurShowPlayerInfoUid
    local bSelfCert = RoleInfoMainSystem.IsShowSelf()
    local weakSelf = setmetatable({ref = self}, {__mode = "v"})
    logic_roleInfo_HonourCertificate:RequestVersionIfNeeded(certUid, bSelfCert, function(showNum)
      local selfRef = weakSelf.ref
      if not selfRef or not slua.isValid(selfRef.UIRoot) then
        return
      end
      log(bWriteLog and string.format("UI_RoleInfoMain:OnPostInitialize honour cert version callback showNum=%s", tostring(showNum)))
      selfRef:RefreshHonorSubTabs()
    end)
  else
    log_format("[HonourCert] IsBLUEHOLE=true, skip cert request")
  end
end
function UI_RoleInfoMain:OnShow()
  UI_RoleInfoMain.__super.OnShow(self)
  self:HideOtherUI()
end
function UI_RoleInfoMain:HideOtherUI()
  local tmpTable = UIManager.GetTopUINameList(10)
  for k, v in pairs(tmpTable) do
    local config = UIManager.GetConfigByKey(v)
    if config and config ~= self._config and UIManager.IsUIShow(config) and not config.isMainUI and config.containerName ~= UIContainers.Top then
      local ui = UIManager.GetUI(config)
      if ui then
        ui:Collapsed()
      end
      if not self.HideList then
        self.HideList = {}
      end
      table.insert(self.HideList, config)
    end
  end
end
function UI_RoleInfoMain:ShowOtherUI()
  if not self.HideList then
    return
  end
  for k, config in pairs(self.HideList) do
    local ui = UIManager.GetUI(config)
    if ui then
      ui:SelfHitTestInvisible()
    end
  end
end
function UI_RoleInfoMain:OnClose()
  local collect_bgm_module = ModuleManager.GetSplitModuleDownload(ModuleManager.LobbyModuleConfig.collect_bgm_module)
  if collect_bgm_module then
    collect_bgm_module:StopCollectSystemBGM()
  end
  local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
  if PHomeStoreProxy.isShowingPHomeMain then
    RoleInfoMainSystem.CloseExceptMainUI(true)
  else
    RoleInfoMainSystem.CloseExceptMainUI()
  end
  local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
  logic_peakgame_combat:ClearData()
  local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
  RoleInfoHistorySystem.ClearRecordCache()
  self:ShowOtherUI()
end
function UI_RoleInfoMain:OnAndroidBack()
  RoleInfoMainSystem.Close(nil, self._sRecordJumpToUIdUrl)
end
function UI_RoleInfoMain:OnVerticalTextTabClickedCallback(widget, index)
  self:PlayAudio(sound_config.tab_v1)
  if self.TabID == Index2TabID[index] then
    log_warning(bWriteLog and "  UI_RoleInfoMain:OnVerticalTextTabClickedCallback. same TabID " .. tostring(self.TabID))
    return
  end
  if Index2TabID[index] == RoleInfoMainSystem.Honor then
    RoleInfoMainSystem.ResetAchieveInfo()
  end
  self:_ShowIndex(Index2TabID[index])
end
function UI_RoleInfoMain:OnSelectTab(lastIndex, index, bIsFromClick)
  local tabID = Index2TabID[index]
  if tabID == RoleInfoMainSystem.Honor then
    self.Common_Tab:RefreshTabItemShow(index)
  end
end
function UI_RoleInfoMain:OpenSubPage(subPageIndex)
  log(bWriteLog and "UI_RoleInfoMain:OpenSubPage subPageIndex = " .. subPageIndex)
  local targetSubTabId = SubTabList[self.TabID][subPageIndex].subTabId
  if self.SubTabID == targetSubTabId then
    log(bWriteLog and "UI_RoleInfoMain:OpenSubPage 2")
    return
  end
  self.Common_Tab:SelectSubTab(subPageIndex)
  self:_ShowIndex(targetSubTabId, nil, true)
end
function UI_RoleInfoMain:OnVerticalTextSubTabClickedCallback(_, SubPageIndex)
  self:PlayAudio(sound_config.tab_v1)
  if SubTabList[self.TabID] and SubTabList[self.TabID][SubPageIndex] and SubTabList[self.TabID][SubPageIndex].subTabId == RoleInfoMainSystem.IntimateRelationship_SubTab.Partner and RoleInfoMainSystem.IsMe() then
    local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
    if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE) then
      PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE)
    end
  end
  log_warning(bWriteLog and "  UI_RoleInfoMain:OnVerticalTextSubTabClickedCallback. self.TabID: " .. tostring(self.TabID))
  log_warning(bWriteLog and "  UI_RoleInfoMain:OnVerticalTextSubTabClickedCallback. SubPageIndex: " .. tostring(SubPageIndex))
  if not SubTabList[self.TabID] or not SubTabList[self.TabID][SubPageIndex] then
    log_warning(bWriteLog and "  UI_RoleInfoMain:OnVerticalTextSubTabClickedCallback. SubTabList is nil, TabID: " .. tostring(self.TabID) .. ", SubPageIndex: " .. tostring(SubPageIndex))
    return
  end
  if self.SubTabID and self.SubTabID == SubTabList[self.TabID][SubPageIndex].subTabId then
    return
  end
  self:_ShowIndex(SubTabList[self.TabID][SubPageIndex].subTabId, nil, true)
end
function UI_RoleInfoMain:OnVerticalIconTabRefreshCallback(widget, index)
  self:SetWidgetVisible(widget.Panel_Download, false)
  log(bWriteLog and "[chub]UI_RoleInfoMain:OnVerticalIconTabRefreshCallback, index = " .. tostring(index))
  local data = self.Common_Tab:GetTabData(index)
  if not data then
    return
  end
  widget.Reddot_Anchor:_Reset()
  widget.Reddot_Anchor:UnBind()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local _index = 0
  local collectIndx = 0
  local wowIndex = 0
  local intimateIndex = 0
  for key, value in pairs(Index2TabID) do
    if value == RoleInfoMainSystem.Honor then
      _index = key
    end
    if value == RoleInfoMainSystem.Collect then
      collectIndx = key
    end
    if value == RoleInfoMainSystem.WOW then
      wowIndex = key
    end
    if value == RoleInfoMainSystem.IntimateRelationship then
      intimateIndex = key
    end
  end
  if collectIndx == index then
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    if collect_module.OPEN_COLLECT_DOWNLOAD_MARK then
      local common_download_handler = require("client.slua.common.common_download_handler")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
      common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {
        RoleInfoMainSystem.C_Check_Asset_Path
      }, widget.Panel_Download, {hideMask = true})
    end
  elseif intimateIndex == index then
    local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
    local PoseCfg = CDataTable.GetTable("MultiplayerAvatarPose")
    local KeyList = {
      LobbySceneModule:GetStreamLevelFullPathByName("Lobby_CP01")
    }
    if PoseCfg then
      for _, cfg in pairs(PoseCfg) do
        local Path = LobbySceneModule:GetStreamLevelFullPathByName(cfg.BackGroundLevel)
        if Path then
          table.insert(KeyList, Path)
        end
      end
    end
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local common_download_handler = require("client.slua.common.common_download_handler")
    common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, KeyList, widget.Panel_Download, {hideMask = true})
  end
  if wowIndex == index then
    local bSelf = RoleInfoMainSystem.IsShowSelf()
    if bSelf then
      local wowplay_red = require("client.slua.logic.ugc.playlevel.ugc_playlevel_reddot_data")
      local reddot = wowplay_red.GetData()
      widget.Reddot_Anchor:Bind(reddot)
    end
  end
  if RoleInfoSystem.IsSelf() and index == _index then
    local bRed = false
    if self:IsShowAchivement() then
      local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
      local achievement_red = require("client.logic.achievement.achievement_red")
      local reddot = achievement_red.GetRedData()
      widget.Reddot_Anchor:Bind(reddot)
      bRed = logic_achievement.HasRedpoint()
      self:SetWidgetVisible(widget.Reddot_Anchor, bRed)
      self:SetWidgetVisible(widget.Image_Reddot_01, false)
    end
    if not bRed then
      local bSelf = RoleInfoMainSystem.IsShowSelf()
      if not bSelf then
        self:SetWidgetVisible(widget.Reddot_Anchor, false)
        return
      end
      self:SetWidgetVisible(widget.Reddot_Anchor, false)
      local alias_red = require("client.logic.alias.alias_red")
      local spData = RoleInfoMainSystem.GetSuperData()
      bRed = alias_red.HasRedpoint() or spData.honorRed
      widget.Image_Reddot_01:SetBrushFromPathAsync("/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_RedPoint_png.Common_Icon_RedPoint_png", false)
      self:SetWidgetVisible(widget.Image_Reddot_01, bRed)
    end
  else
    local spData = RoleInfoMainSystem.GetSuperData()
    local _key = RedIndex2RedDotKeyMap[index]
    if not _key then
      self:SetWidgetVisible(widget.Image_Reddot_01, false)
      return
    end
    local _isRed = spData[_key]
    if _isRed == nil then
      self:SetWidgetVisible(widget.Image_Reddot_01, false)
      return
    end
    if collectIndx == index then
      local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
      local CollectTab = reddot_node_collect_manager:GetCollectTab()
      if not reddot_node_collect_manager:ShowBoxReddot(widget, _isRed and widget.Reddot_Anchor, CollectTab.collect_main) then
        reddot_node_collect_manager:ShowNewReddot(widget, widget.Reddot_Anchor, CollectTab.collect_main)
      end
    elseif intimateIndex == index then
      log(bWriteLog and "UI_RoleInfoMain:OnVerticalIconTabRefreshCallback intimateIndex ")
      local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
      local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
      local redBool = IntimacyAwardSystem.HasIntimacyRewardReddot()
      local partnerRed = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE) or PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE) or PersonSpaceSystem.HasIntimacyCanGetRewardReddot() or PersonSpaceSystem.HasCohabitReddot() or redBool
      log(bWriteLog and "UI_RoleInfoMain:OnVerticalIconTabRefreshCallback partnerRed " .. tostring(partnerRed))
      self:SetWidgetVisible(widget.Image_Reddot_01, partnerRed)
    else
      self:SetWidgetVisible(widget.Image_Reddot_01, _isRed)
    end
  end
end
function UI_RoleInfoMain:OnVerticalIconSubTabRefreshCallback(widget, index)
  log(bWriteLog and "[wzp]UI_RoleInfoMain:OnVerticalIconSubTabRefreshCallback, index = " .. tostring(index))
  if not SubTabList[self.TabID] then
    return
  end
  local data = SubTabList[self.TabID][index]
  if not data then
    return
  end
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if RoleInfoSystem.IsSelf() then
    if data.subTabId == RoleInfoMainSystem.IntimateRelationship_SubTab.Partner then
      local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
      local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
      local partnerRed = IntimacyAwardSystem.HasIntimacyRewardReddot() or PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE)
      log(bWriteLog and "UI_RoleInfoMain:OnVerticalIconTabRefreshCallback subRed partner" .. tostring(partnerRed))
      self:SetWidgetVisible(widget.Image_Reddot_01, partnerRed)
      return
    elseif data.subTabId == RoleInfoMainSystem.IntimateRelationship_SubTab.Close then
      local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
      local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
      local intimacyRed = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE) or PersonSpaceSystem.HasIntimacyCanGetRewardReddot() or PersonSpaceSystem.HasCohabitReddot()
      log(bWriteLog and "UI_RoleInfoMain:OnVerticalIconTabRefreshCallback subRed close " .. tostring(intimacyRed))
      self:SetWidgetVisible(widget.Image_Reddot_01, intimacyRed)
      return
    end
  end
  widget.Reddot_Anchor:_Reset()
  widget.Reddot_Anchor:UnBind()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  log(bWriteLog and "[wzp]UI_RoleInfoMain:OnVerticalIconSubTabRefreshCallback, data.subTabId = " .. tostring(data.subTabId))
  if RoleInfoSystem.IsSelf() then
    if self.TabID == RoleInfoMainSystem.Honor then
      if self:IsShowAchivement() and data.subTabId == RoleInfoMainSystem.Honor_SubTab.Achievement then
        local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
        local achievement_red = require("client.logic.achievement.achievement_red")
        widget.Reddot_Anchor:Bind(achievement_red.GetRedData())
        local bRed = logic_achievement.HasRedpoint()
        self:SetWidgetVisible(widget.Reddot_Anchor, bRed)
        self:SetWidgetVisible(widget.Image_Reddot_01, false)
      elseif data.subTabId == RoleInfoMainSystem.Honor_SubTab.HonourCertificate then
        local spData = RoleInfoMainSystem.GetSuperData()
        local bRed = spData.honourCertificateRed or false
        self:SetWidgetVisible(widget.Image_Reddot_01, bRed)
      else
        self:SetWidgetVisible(widget.Reddot_Anchor, false)
        local alias_red = require("client.logic.alias.alias_red")
        local bRed = alias_red.HasRedpoint()
        self:SetWidgetVisible(widget.Image_Reddot_01, bRed)
      end
    elseif self.TabID == RoleInfoMainSystem.WOW then
      if data.subTabId == RoleInfoMainSystem.WOW_SubTab.PlayData then
        local wowplay_red = require("client.slua.logic.ugc.playlevel.ugc_playlevel_reddot_data")
        local reddot = wowplay_red.GetPlayData()
        widget.Reddot_Anchor:Bind(reddot)
      elseif data.subTabId == RoleInfoMainSystem.WOW_SubTab.AuthorHome then
        local wowplay_red = require("client.slua.logic.ugc.playlevel.ugc_playlevel_reddot_data")
        local reddot = wowplay_red.GetAuthorHomeData()
        widget.Reddot_Anchor:Bind(reddot)
      end
    else
      log_warning(bWriteLog and "  UI_RoleInfoMain:OnVerticalIconSubTabRefreshCallback. self.TabID: " .. tostring(self.TabID))
      local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
      local bRed = roleinfo_red_data.GetSubRed(data.subTabId)
      if self.TabID == RoleInfoMainSystem.Collect then
        local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
        if not reddot_node_collect_manager:ShowBoxReddot(widget, bRed and widget.Reddot_Anchor, data.locResID) then
          reddot_node_collect_manager:ShowNewReddot(widget, widget.Reddot_Anchor, data.locResID)
        end
      else
        self:SetWidgetVisible(widget.Image_Reddot_01, bRed)
      end
    end
  else
    self:SetWidgetVisible(widget.Reddot_Anchor, false)
  end
end
function UI_RoleInfoMain:ResetHide()
  self:Collapsed()
end
function UI_RoleInfoMain:ResetShow()
  self:SelfHitTestInvisible()
end
function UI_RoleInfoMain:HideTips()
  local ui = UIManager.GetUI(UI_Config.roleinfo_history)
  if ui then
    self.UIRoot.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
function UI_RoleInfoMain:OnShowCareerEntry()
  self:SetTabs()
  for k, v in pairs(Index2TabID) do
    if v == self.TabID then
      self.Common_Tab:SelectTab(k)
      break
    end
  end
end
function UI_RoleInfoMain:OnAfterPersonSpaceClose(_, _, showCard)
  log(bWriteLog and " UI_RoleInfoMain:OnAfterPersonSpaceClose")
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_Intimacy_List_UIBP, false, showCard)
end
function UI_RoleInfoMain:UpdateCareerRedPoint()
end
function UI_RoleInfoMain:OnButton_CloseClick()
  self:PlayAudio(sound_config.close)
  self.SubTabID = nil
  self:OnAndroidBack()
  local ItemPrewViewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
  ItemPrewViewSystem.CloseItemPreviewPanel()
end
function UI_RoleInfoMain:OnButton_SaveClick()
  self:PlayAudio(sound_config.click)
  RoleInfoMainSystem.SaveData(self.TabID)
end
function UI_RoleInfoMain:OnClickHideTips()
  self:PlayAudio(sound_config.click)
  local ui = UIManager.GetUI(UI_Config.roleinfo_history)
  if ui and ui.widget then
    ui.widget.CanvasPanel_10:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ui.widget = nil
  end
end
function UI_RoleInfoMain:OnButton_InfoClick()
  self:PlayAudio(sound_config.click)
  if self.SubTabID == RoleInfoMainSystem.Honor_SubTab.Achievement then
    local title = LocUtil.GetLocalizeResStr(6067)
    local context = LocUtil.GetLocalizeResStr(4829)
    UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, context)
  elseif self.TabID == RoleInfoMainSystem.IntimateRelationship then
    local msg = string.format("%s%s%s%s%s%s%s%s%s%s%s%s%s", DataMgr.GetMsgByID(4207), DataMgr.GetMsgByID(4208), DataMgr.GetMsgByID(4209), DataMgr.GetMsgByID(4210), DataMgr.GetMsgByID(4211), DataMgr.GetMsgByID(4212), DataMgr.GetMsgByID(4213), DataMgr.GetMsgByID(4214), DataMgr.GetMsgByID(4215), DataMgr.GetMsgByID(6715), DataMgr.GetMsgByID(4216), DataMgr.GetMsgByID(4217), DataMgr.GetMsgByID(4218))
    local strMsg = msg
    UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, LocUtil.GetLocalizeResStr(199604), strMsg)
  elseif self.SubTabID == RoleInfoMainSystem.CollectRank then
    UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, LocUtil.GetLocalizeResStr(6067), LocUtil.GetLocalizeResStr(76413))
  end
end
function UI_RoleInfoMain:OnEnterAnimFinished()
  local roleinfo_segment = UIManager.GetUI(UIManager.UI_Config.roleinfo_segment)
  if roleinfo_segment then
    roleinfo_segment:ShowAvatarAfterEnterAnim()
  end
  local Lobby_RoleInfo_Card_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_RoleInfo_Card_UIBP)
  if Lobby_RoleInfo_Card_UIBP then
    Lobby_RoleInfo_Card_UIBP:ShowAvatarAfterEnterAnim()
  end
end
function UI_RoleInfoMain:OnBackgroundSceneLoaded()
  self.UIRoot.Image_BaseBg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function UI_RoleInfoMain:UpdateUI()
  log(bWriteLog and "  UI_RoleInfoMain:UpdateUI")
  self:SetTabs()
  self:PlayUserWidgetAnimation(self.UIRoot.DX_BaseInfoUnfold, 0, 1, 0, 1)
  local tabId = self.TabID
  local find
  if self.SubTabID then
    self:_ShowIndex(self.SubTabID, nil, true, self.personalizeExtraData and self.personalizeExtraData.subTab)
  elseif RoleInfoMainSystem.IsCollectTabbByIndex(self.TabID) and self.personalizeExtraData then
    self:_ShowIndex(self.TabID, self.personalizeExtraData, true, self.personalizeExtraData.subTab)
  else
    self:_ShowIndex(self.TabID, {bInit = true})
  end
  local tabIndex, subTabIndex
  for k, v in pairs(Index2TabID) do
    if v == tabId then
      tabIndex = k
      local subId
      if SubTabList[tabId] then
        subId = 1
        for i, v in ipairs(SubTabList[tabId]) do
          if v.subTabId == self.SubTabID then
            subId = i
            log_warning(bWriteLog and "  UI_RoleInfoMain:UpdateUI.SubTabID subId: " .. tostring(subId))
          end
        end
        subTabIndex = subId
      end
      find = true
      break
    end
  end
  self.Common_Tab:SelectTab(tabIndex, subTabIndex, false)
  log_warning(bWriteLog and "  UI_RoleInfoMain:UpdateUI. find: " .. tostring(find))
  log_warning(bWriteLog and "  UI_RoleInfoMain:UpdateUI. tabId: " .. tostring(tabId))
  log_tree("  UI_RoleInfoMain:UpdateUI. SubTabList ", SubTabList)
  if not find then
    for id, list in pairs(SubTabList) do
      for subIndex, v in ipairs(list) do
        if v.subTabId == tabId then
          for index, tab in ipairs(Index2TabID) do
            if tab == id then
              log_warning(bWriteLog and "  UI_RoleInfoMain:UpdateUI. id: " .. tostring(id))
              find = true
              self.Common_Tab:SelectTab(index, subIndex)
              break
            end
          end
          break
        end
      end
    end
  end
  if not find then
    log_warning(bWriteLog and "  UI_RoleInfoMain:UpdateUI.  not find")
    self.TabID = RoleInfoMainSystem.Segment
    self.Common_Tab:SelectTab(1)
  end
  local logic_recent_gift_ani = require("client.slua.logic.person_space.logic_recent_gift_ani")
  if logic_recent_gift_ani then
    logic_recent_gift_ani.StopAllAni()
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.HideAllAvatar()
end
function UI_RoleInfoMain:_ShowIndex(TabID, extra, isSub, ctrData)
  log_warning(bWriteLog and "  : index" .. tostring(TabID))
  local curTabId = self.SubTabID or self.TabID
  if not uiCfg[curTabId] or not uiCfg[TabID] then
    self.UIRoot.Image_BaseBg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif uiCfg[curTabId].needShowBaseBg or uiCfg[TabID].needShowBaseBg then
    self.UIRoot.Image_BaseBg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Image_BaseBg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:_CloseCurPage()
  self.SubTabID = nil
  local ui
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  if not collect_reddot_module.allowRefreshReddot and refreshRedDotCollectSubTab[TabID] then
    collect_reddot_module:SetAllowRefreshReddot(true)
    collect_reddot_module:RefreshRedPoint()
  end
  if TabID == RoleInfoMainSystem.IntimateRelationship_SubTab.Close then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local extraData = RoleInfoMainSystem.GetIntimacyInfo()
    RoleInfoMainSystem.ResetIntimacyInfo()
    log_tree("[DeanJYT] UI_RoleInfoMain:_ShowIndex extraData = ", extraData)
    if extraData == nil then
      extraData = {}
    end
    extraData.intimacyType = self.intimacyType
    ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, uiCfg[RoleInfoMainSystem.IntimateRelationship_SubTab.Close].cfg, RoleInfoSystem.CurShowPlayerInfoUid, extraData)
    self.SubTabID = RoleInfoMainSystem.IntimateRelationship_SubTab.Close
  elseif TabID == RoleInfoMainSystem.Credit then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, uiCfg[TabID].cfg, RoleInfoSystem.CurShowPlayerInfoUid)
  elseif TabID == RoleInfoMainSystem.RoleInfoCard then
    if not extra or type(extra) ~= "table" then
      extra = {}
    end
    self.TabID = RoleInfoMainSystem.RoleInfoCard
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    extra.uid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
    ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, uiCfg[TabID].cfg, extra)
  elseif TabID == RoleInfoMainSystem.Personalize then
    if self.personalizeExtraData then
      if not extra or type(extra) ~= "table" then
        extra = self.personalizeExtraData
      else
        for k, v in pairs(self.personalizeExtraData) do
          if not extra[k] then
            extra[k] = v
          end
        end
      end
    end
    ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, uiCfg[TabID].cfg, extra)
  elseif TabID == RoleInfoMainSystem.Honor then
    local logic_weapon_strength = require("client.slua.logic.weapon_strength.logic_weapon_strength")
    if logic_weapon_strength:CheckIsOpenWeaponStrength() then
      logic_weapon_strength:send_get_weapon_power_data_req()
    end
    if self:IsShowAchivement() then
      local bSelf = RoleInfoMainSystem.IsShowSelf()
      if bSelf then
        ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UI_Config.Achievement_Task_UIBP)
      else
        ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UI_Config.Achievement_Space_UIBP)
      end
      self:SetWidgetVisible(self.UIRoot.Button_Info, true, true)
      self.SubTabID = RoleInfoMainSystem.Honor_SubTab.Achievement
      self.TabID = RoleInfoMainSystem.Honor
      isSub = true
    else
      local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
      local bSelf = RoleInfoMainSystem.IsShowSelf()
      if bSelf then
        ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UI_Config.Title_Main_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
        local alias_red = require("client.logic.alias.alias_red")
        if not alias_red.GetIsHasShowRedPoint() then
          alias_red.SetIsHasShowRedPoint(true)
          self.Common_Tab.ExtendedLoopScrollBox_Tab:RefreshItem(5)
          self.Common_Tab.ExtendedLoopScrollBox_Tab:RefreshAllSubItems()
        end
      else
        ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UI_Config.Title_Main_Guest_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
      end
      self.SubTabID = RoleInfoMainSystem.Honor_SubTab.Alias
      self.TabID = RoleInfoMainSystem.Honor
      isSub = true
    end
  elseif TabID == RoleInfoMainSystem.Honor_SubTab.Alias then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local bSelf = RoleInfoMainSystem.IsShowSelf()
    if bSelf then
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UI_Config.Title_Main_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
      local alias_red = require("client.logic.alias.alias_red")
      if not alias_red.GetIsHasShowRedPoint() then
        alias_red.SetIsHasShowRedPoint(true)
        self.Common_Tab.ExtendedLoopScrollBox_Tab:RefreshItem(5)
        self.Common_Tab.ExtendedLoopScrollBox_Tab:RefreshAllSubItems()
      end
    else
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UI_Config.Title_Main_Guest_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
    end
    self.SubTabID = RoleInfoMainSystem.Honor_SubTab.Alias
    self.TabID = RoleInfoMainSystem.Honor
    isSub = true
  elseif TabID == RoleInfoMainSystem.Honor_SubTab.Achievement then
    local bSelf = RoleInfoMainSystem.IsShowSelf()
    if bSelf then
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UI_Config.Achievement_Task_UIBP)
    else
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UI_Config.Achievement_Space_UIBP)
    end
    self.SubTabID = RoleInfoMainSystem.Honor_SubTab.Achievement
    self.TabID = RoleInfoMainSystem.Honor
    isSub = true
    self:SetWidgetVisible(self.UIRoot.Button_Info, true, true)
  elseif TabID == RoleInfoMainSystem.Honor_SubTab.HonourCertificate then
    local RoleInfoSystem_hc = require("client.logic.roleinfo.logic_roleinfo")
    local certUid_hc = RoleInfoSystem_hc.CurShowPlayerInfoUid
    local logic_hc = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_HonourCertificate)
    logic_hc:RequestCertListWithCallback(certUid_hc, function()
      log(bWriteLog and "UI_RoleInfoMain:_ShowIndex HonourCertificate cert list callback")
      if not slua.isValid(self.UIRoot) then
        return
      end
      if tonumber(certUid_hc) == tonumber(DataMgr.roleData.uid) then
        logic_hc:ClearRedDot()
      end
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.HonourCertificate_Main_UIBP)
      self.nCurPageUI = ui
      self.Common_Tab.ExtendedLoopScrollBox_Tab:RefreshAllSubItems()
    end)
    self.SubTabID = RoleInfoMainSystem.Honor_SubTab.HonourCertificate
    self.TabID = RoleInfoMainSystem.Honor
    isSub = true
  elseif TabID == RoleInfoMainSystem.Honor_SubTab.WeaponStrenthHonor then
    local logic_weapon_strength = require("client.slua.logic.weapon_strength.logic_weapon_strength")
    logic_weapon_strength:send_get_weapon_power_data_req()
    ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.Season_WeaponStrength_Display_UIBP, RoleInfoMainSystem.IsShowSelf())
    self.SubTabID = RoleInfoMainSystem.Honor_SubTab.WeaponStrenthHonor
    self.TabID = RoleInfoMainSystem.Honor
    isSub = true
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.PersonSpaceWeaponStrength)
  elseif TabID == RoleInfoMainSystem.WOW then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    if LogicUGCAuthor:NewCheckPlayerIsAuthor(tonumber(RoleInfoSystem.CurShowPlayerInfoUid), true) then
      local bSelf = RoleInfoMainSystem.IsShowSelf()
      local Logic_UGC_AuthorHome = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_authorhome)
      if Logic_UGC_AuthorHome:CheckShowAuthorHomePage(RoleInfoSystem.CurShowPlayerInfoUid, true) then
        self.TabID = RoleInfoMainSystem.WOW
        self.SubTabID = RoleInfoMainSystem.WOW_SubTab.AuthorHome
        ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.UGC_Mine_Creative_Homepage_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
      else
        if bSelf then
          ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.UGC_AuthorMasterstate_CreativeCenter_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
        else
          ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.UGC_AuthorBehavior_CreativeCenter_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
        end
        self.TabID = RoleInfoMainSystem.WOW
        self.SubTabID = RoleInfoMainSystem.WOW_SubTab.WorkData
      end
      isSub = true
    else
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.UGC_Player_PlayData_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
    end
  elseif TabID == RoleInfoMainSystem.WOW_SubTab.PlayData then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.UGC_Player_PlayData_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
    self.TabID = RoleInfoMainSystem.WOW
    self.SubTabID = RoleInfoMainSystem.WOW_SubTab.PlayData
    isSub = true
  elseif TabID == RoleInfoMainSystem.WOW_SubTab.WorkData then
    local bSelf = RoleInfoMainSystem.IsShowSelf()
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local Logic_UGC_AuthorHome = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_authorhome)
    if Logic_UGC_AuthorHome:CheckShowAuthorHomePage(RoleInfoSystem.CurShowPlayerInfoUid) then
      self.TabID = RoleInfoMainSystem.WOW
      self.SubTabID = RoleInfoMainSystem.WOW_SubTab.AuthorHome
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.UGC_Mine_Creative_Homepage_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
    else
      if bSelf then
        ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.UGC_AuthorMasterstate_CreativeCenter_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
      else
        ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.UGC_AuthorBehavior_CreativeCenter_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
      end
      self.TabID = RoleInfoMainSystem.WOW
      self.SubTabID = RoleInfoMainSystem.WOW_SubTab.WorkData
    end
    isSub = true
  elseif TabID == RoleInfoMainSystem.WOW_SubTab.AuthorHome then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    self.TabID = RoleInfoMainSystem.WOW
    self.SubTabID = RoleInfoMainSystem.WOW_SubTab.AuthorHome
    ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.UGC_Mine_Creative_Homepage_UIBP, RoleInfoSystem.CurShowPlayerInfoUid)
    isSub = true
  elseif SubTabList[TabID] then
    local tb = SubTabList[TabID]
    ctrData = ctrData or self.personalizeExtraData and self.personalizeExtraData.subTab
    local targetIndex = 1
    if extra and extra.extraTab and extra.extraTab.jumpSubTabID then
      for i, v in pairs(tb) do
        if v.subTabId == extra.extraTab.jumpSubTabID then
          targetIndex = i
          break
        end
      end
    elseif TabID == RoleInfoMainSystem.Collect then
      targetIndex = UI_RoleInfoMain:GetTargetCollectSubTab(tb)
    end
    if TabID == RoleInfoMainSystem.IntimateRelationship and tb[targetIndex].subTabId == RoleInfoMainSystem.IntimateRelationship_SubTab.Close then
      local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
      local extraData = RoleInfoMainSystem.GetIntimacyInfo()
      RoleInfoMainSystem.ResetIntimacyInfo()
      log_tree("UI_RoleInfoMain:_ShowIndex extraData = ", extraData)
      if extraData == nil then
        extraData = {}
      end
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, uiCfg[RoleInfoMainSystem.IntimateRelationship_SubTab.Close].cfg, RoleInfoSystem.CurShowPlayerInfoUid, extraData)
    else
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, tb[targetIndex].cfg, ctrData, self.personalizeExtraData)
    end
    self.SubTabID = tb[targetIndex].subTabId
    if 1 < targetIndex then
      self:AddTimerOnce(0, function()
        self.Common_Tab:SelectSubTab(targetIndex)
      end)
    end
  else
    for tab, list in pairs(SubTabList) do
      for _, tb in ipairs(list) do
        if tb.subTabId == TabID then
          self.Sub          self.TabID = tab
          break
        end
      end
    end
    if not uiCfg[TabID].cfg then
      log_error("UI_RoleInfoMain:_ShowIndex. uiCfg[TabID].cfg is nil. TabID: " .. tostring(TabID))
      return
    end
    if ctrData then
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, uiCfg[TabID].cfg, ctrData, self.personalizeExtraData)
      self:AutoSetSubTab(TabID)
    else
      ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, uiCfg[TabID].cfg, extra)
    end
  end
  if not isSub then
    self.  end
  if TabIDPageToGem[TabID] then
    gem_report_utils.ReportBtnClickEvent(TabIDPageToGem[TabID])
  end
  if TabIDToTLog[TabID] then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TabIDToTLog[TabID])
  end
  self.nCurPageUI = ui
  self.personalizeExtraData = nil
  log_warning(bWriteLog and "  UI_RoleInfoMain:_ShowIndex. TabID: " .. tostring(TabID))
  if TabID == RoleInfoMainSystem.Segment then
    local collect_guide_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_guide_module)
    collect_guide_module:ShowLevelGuide()
  end
  if self.SubTabID == RoleInfoMainSystem.CollectRank then
    self:SetWidgetVisible(self.UIRoot.Button_Info, true, true)
  end
  local collect_bgm_module = ModuleManager.GetSplitModuleDownload(ModuleManager.LobbyModuleConfig.collect_bgm_module)
  if collect_bgm_module then
    if RoleInfoMainSystem.IsCollectTabbByIndex(TabID) then
      collect_bgm_module:PlayCollectSystemBGM()
    else
      collect_bgm_module:StopCollectSystemBGM()
    end
  end
end
function UI_RoleInfoMain:GetTargetCollectSubTab(tb)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if not RoleInfoSystem.IsSelf() then
    return 1
  end
  local spData = RoleInfoMainSystem.GetSuperData()
  for i, v in pairs(tb) do
    local key = RedIndex2RedDotKeyMap[v.subTabId]
    if key and spData[key] then
      log(bWriteLog and string.format("UI_RoleInfoMain:GetTargetCollectSubTab. Jump to the reward tab index : %s", i))
      return i
    end
  end
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  for i, v in pairs(tb) do
    if v and v.locResID and reddot_node_collect_manager:CheckShowNewReddot(v.locResID) then
      log(bWriteLog and string.format("UI_RoleInfoMain:GetTargetCollectSubTab. Jump to the New tab index : %s", i))
      return i
    end
  end
  return 1
end
function UI_RoleInfoMain:BuildHonorSubTabCfgs()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local weaponStrengthCfgs = {
    {
      locResID = 62272,
      subTabId = RoleInfoMainSystem.Honor_SubTab.Achievement,
      cfg_self = UI_Config.Achievement_Task_UIBP,
      cfg_his = UI_Config.Achievement_Space_UIBP,
      showFunc = function()
        return self:IsShowAchivement()
      end
    },
    {
      locResID = 62273,
      subTabId = RoleInfoMainSystem.Honor_SubTab.Alias,
      cfg_self = UI_Config.Title_Main_UIBP,
      cfg_his = UI_Config.Title_Main_Guset_UIBP,
      showFunc = function()
        return true
      end
    },
    {
      locResID = 8801364,
      subTabId = RoleInfoMainSystem.Honor_SubTab.HonourCertificate,
      cfg = UI_Config.HonourCertificate_Main_UIBP,
      showFunc = function()
        if not RoleInfoSystem.IsSelf() then
          local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
          if logic_profile:IsPlayerBanned(tonumber(RoleInfoSystem.CurShowPlayerInfoUid)) then
            return false
          end
        end
        local logic_roleInfo_HonourCertificate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_HonourCertificate)
        return logic_roleInfo_HonourCertificate:GetShowNum() > 0
      end
    },
    {
      locResID = 68218,
      subTabId = RoleInfoMainSystem.Honor_SubTab.WeaponStrenthHonor,
      cfg = UI_Config.Season_WeaponStrength_Display_UIBP,
      showFunc = function()
        local logic_weapon_strength = require("client.slua.logic.weapon_strength.logic_weapon_strength")
        return logic_weapon_strength:CheckIsOpenWeaponStrength() and LobbySystem.CheckOpen(BP_ENUM_WEAPON_USAGE_SCORE_SWITCH)
      end
    }
  }
  local needShowCfgs = {}
  for _, v in ipairs(weaponStrengthCfgs) do
    if v.showFunc() then
      table.insert(needShowCfgs, v)
    end
  end
  SubTabList[RoleInfoMainSystem.Honor] = needShowCfgs
  return needShowCfgs
end
function UI_RoleInfoMain:RefreshHonorSubTabs()
  log(bWriteLog and "UI_RoleInfoMain:RefreshHonorSubTabs begin")
  local needShowCfgs = self:BuildHonorSubTabCfgs()
  local honorIndex
  for k, v in pairs(Index2TabID) do
    if v == RoleInfoMainSystem.Honor then
      honorIndex = k
      break
    end
  end
  if honorIndex then
    local subTabNameList = {}
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    for _, sv in ipairs(needShowCfgs) do
      table.insert(subTabNameList, {
        text = LocUtil.GetLocalizeResStr(sv.locResID)
      })
      if RoleInfoSystem.IsSelf() and uiCfg[sv.subTabId] and uiCfg[sv.subTabId].redDotKey then
        RedIndex2RedDotKeyMap[sv.subTabId] = uiCfg[sv.subTabId].redDotKey
        SubTabId2MainTabIndex[sv.subTabId] = honorIndex
      end
    end
    local tabData = self.Common_Tab:GetTabData(honorIndex)
    if tabData then
      tabData.subData = subTabNameList
      self.Common_Tab:RefreshTabItemShow(honorIndex)
    end
  end
  log(bWriteLog and "UI_RoleInfoMain:RefreshHonorSubTabs end")
end
function UI_RoleInfoMain:SetTabs()
  log(bWriteLog and "  UI_RoleInfoMain:SetTabs begin")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RedIndex2RedDotKeyMap = {}
  SubTabId2MainTabIndex = {}
  if IsWoWEditor then
    Index2TabID = {
      RoleInfoMainSystem.WOW
    }
    local uid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    if LogicUGCAuthor:NewCheckPlayerIsAuthor(uid, true) then
      local Logic_UGC_AuthorHome = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_authorhome)
      if Logic_UGC_AuthorHome:CheckShowAuthorHomePage(uid, true) then
        local cfgs = {
          {
            locResID = 8910016,
            subTabId = RoleInfoMainSystem.WOW_SubTab.AuthorHome,
            cfg = UI_Config.UGC_Mine_Creative_Homepage_UIBP
          },
          {
            locResID = 8910017,
            subTabId = RoleInfoMainSystem.WOW_SubTab.PlayData,
            cfg = UI_Config.UGC_Player_PlayData_UIBP
          }
        }
        SubTabList[RoleInfoMainSystem.WOW] = cfgs
      else
        local cfgs = {
          {
            locResID = 8910016,
            subTabId = RoleInfoMainSystem.WOW_SubTab.WorkData,
            cfg = UI_Config.UGC_AuthorBehavior_CreativeCenter_UIBP
          },
          {
            locResID = 8910017,
            subTabId = RoleInfoMainSystem.WOW_SubTab.PlayData,
            cfg = UI_Config.UGC_Player_PlayData_UIBP
          }
        }
        SubTabList[RoleInfoMainSystem.WOW] = cfgs
      end
    end
  else
    Index2TabID = {
      RoleInfoMainSystem.Segment,
      RoleInfoMainSystem.Combat,
      RoleInfoMainSystem.HistoryCombat,
      RoleInfoMainSystem.Honor,
      RoleInfoMainSystem.IntimateRelationship,
      RoleInfoMainSystem.RoleInfoCard,
      RoleInfoMainSystem.Credit
    }
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local bWOWOpen, LimitLevel = LogicUGC:IsWOWOpen()
    if bWOWOpen then
      table.insert(Index2TabID, 6, RoleInfoMainSystem.WOW)
    else
      log(bWriteLog and "[v_yibxu] UI_RoleInfoMain:SetTabs bWOWOpen = " .. tostring(bWOWOpen))
    end
    local uid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    if LogicUGCAuthor:NewCheckPlayerIsAuthor(uid, true) then
      local Logic_UGC_AuthorHome = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_authorhome)
      if Logic_UGC_AuthorHome:CheckShowAuthorHomePage(uid, true) then
        local cfgs = {
          {
            locResID = 8910016,
            subTabId = RoleInfoMainSystem.WOW_SubTab.AuthorHome,
            cfg = UI_Config.UGC_Mine_Creative_Homepage_UIBP
          },
          {
            locResID = 8910017,
            subTabId = RoleInfoMainSystem.WOW_SubTab.PlayData,
            cfg = UI_Config.UGC_Player_PlayData_UIBP
          }
        }
        SubTabList[RoleInfoMainSystem.WOW] = cfgs
      else
        local cfgs = {
          {
            locResID = 8910016,
            subTabId = RoleInfoMainSystem.WOW_SubTab.WorkData,
            cfg = UI_Config.UGC_AuthorBehavior_CreativeCenter_UIBP
          },
          {
            locResID = 8910017,
            subTabId = RoleInfoMainSystem.WOW_SubTab.PlayData,
            cfg = UI_Config.UGC_Player_PlayData_UIBP
          }
        }
        SubTabList[RoleInfoMainSystem.WOW] = cfgs
      end
    elseif SubTabList[RoleInfoMainSystem.WOW] then
      SubTabList[RoleInfoMainSystem.WOW] = nil
    end
    local intimacy_visible_switchs_tool = require("client.slua.logic.friend.Intimacy.intimacy_visible_switchs_tool")
    local intimacySubCfgs = {
      {
        locResID = 73265,
        subTabId = RoleInfoMainSystem.IntimateRelationship_SubTab.Partner,
        cfg = UI_Config.Lobby_RoleInfo_IntimateRelationship_Interact_UIBP,
        showFunc = function()
          local currUID = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
          if not LobbySystem.CheckOpen(BP_ENUM_PIRTNER_FIRE) then
            return false
          end
          if tonumber(currUID) == tonumber(DataMgr.roleData.uid) then
            return true
          else
            return intimacy_visible_switchs_tool.GetVisiblePlayer(currUID)
          end
        end
      },
      {
        locResID = 73296,
        subTabId = RoleInfoMainSystem.IntimateRelationship_SubTab.Exhibit,
        cfg = UI_Config.Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP,
        showFunc = function()
          local currUID = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
          if not LobbySystem.CheckOpen(BP_ENUM_PIRTNER_FIRE) then
            return false
          end
          if tonumber(currUID) == tonumber(DataMgr.roleData.uid) then
            return true
          else
            return intimacy_visible_switchs_tool.GetVisiblePlayer(currUID)
          end
        end
      },
      {
        locResID = 199604,
        subTabId = RoleInfoMainSystem.IntimateRelationship_SubTab.Close,
        cfg = UI_Config.roleinfo_relationship2,
        showFunc = function()
          return true
        end
      }
    }
    local needShowsintimacySubCfgs = {}
    for i, v in ipairs(intimacySubCfgs) do
      if v.showFunc() then
        table.insert(needShowsintimacySubCfgs, v)
      end
    end
    SubTabList[RoleInfoMainSystem.IntimateRelationship] = needShowsintimacySubCfgs
    if self.countdownTimer then
      self:RemoveTimer(self.countdownTimer)
      self.countdownTimer = nil
    end
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    local bShowCollect = collect_module:CanShowCollect(profile)
    log(bWriteLog and "UI_RoleInfoMain:SetTabs bShowCollect = " .. tostring(bShowCollect))
    if bShowCollect then
      table.insert(Index2TabID, collectDefaultIndex, RoleInfoMainSystem.Collect)
      local cfgs = {
        {
          locResID = 77476,
          subTabId = RoleInfoMainSystem.CollectRoom,
          cfg = UI_Config.Collect_Room_UIBP
        }
      }
      if RoleInfoMainSystem.IsMe() then
        table.insert(cfgs, 1, {
          locResID = 77475,
          subTabId = RoleInfoMainSystem.CollectMain,
          cfg = UI_Config.Collect_Road_UIBP
        })
        table.insert(cfgs, {
          locResID = 77477,
          subTabId = RoleInfoMainSystem.CollectLib,
          cfg = UI_Config.Collect_Library_UIBP
        })
        table.insert(cfgs, {
          locResID = 82001,
          subTabId = RoleInfoMainSystem.Milestone,
          cfg = UI_Config.Collect_Milestone_UIBP
        })
        self:InsertCollectRankTab(cfgs)
        if not self.collectLibMaster then
          uiCfg[RoleInfoMainSystem.CollectLib].cfg = UI_Config.Collect_Library_GuestState_UIBP
        else
          uiCfg[RoleInfoMainSystem.CollectLib].cfg = UI_Config.Collect_Library_UIBP
        end
        uiCfg[RoleInfoMainSystem.Milestone].cfg = UI_Config.Collect_Milestone_UIBP
      else
        table.insert(cfgs, {
          locResID = 77477,
          subTabId = RoleInfoMainSystem.CollectLib,
          cfg = UI_Config.Collect_Library_GuestState_UIBP
        })
        table.insert(cfgs, {
          locResID = 82001,
          subTabId = RoleInfoMainSystem.Milestone,
          cfg = UI_Config.Collect_Milestone_Visitor_UIBP
        })
        uiCfg[RoleInfoMainSystem.CollectLib].cfg = UI_Config.Collect_Library_GuestState_UIBP
        uiCfg[RoleInfoMainSystem.Milestone].cfg = UI_Config.Collect_Milestone_Visitor_UIBP
      end
      SubTabList[RoleInfoMainSystem.Collect] = cfgs
    end
    if RoleInfoMainSystem.IsMe() then
      if bShowCollect then
        table.insert(Index2TabID, 6, RoleInfoMainSystem.Personalize)
      else
        table.insert(Index2TabID, 5, RoleInfoMainSystem.Personalize)
      end
    end
    self:BuildHonorSubTabCfgs()
  end
  local tabVerticalTextLevelOne = {}
  local subTabNameList = {}
  for i, tabID in ipairs(Index2TabID) do
    if uiCfg[tabID] then
      if SubTabList and SubTabList[tabID] then
        for _, sv in ipairs(SubTabList[tabID]) do
          if sv.subTabId == RoleInfoMainSystem.CollectRank then
            local collect_rank_entry_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_rank_entry_module)
            local endTime = collect_rank_entry_module:GetActivityEndTime()
            table.insert(subTabNameList, {
              text = LocUtil.GetLocalizeResStr(sv.locResID),
              timing = endTime
            })
          else
            table.insert(subTabNameList, {
              text = LocUtil.GetLocalizeResStr(sv.locResID)
            })
          end
          if RoleInfoSystem.IsSelf() and uiCfg[sv.subTabId].redDotKey then
            local key = uiCfg[sv.subTabId].redDotKey
            RedIndex2RedDotKeyMap[sv.subTabId] = key
            SubTabId2MainTabIndex[sv.subTabId] = i
          end
        end
      end
      table.insert(tabVerticalTextLevelOne, {
        text = LocUtil.GetLocalizeResStr(uiCfg[tabID].locResID),
        subData = subTabNameList
      })
      subTabNameList = subTabNameList and {}
      if RoleInfoSystem.IsSelf() and uiCfg[tabID].redDotKey then
        local key = uiCfg[tabID].redDotKey
        RedIndex2RedDotKeyMap[i] = key
      end
    end
  end
  local spData = RoleInfoMainSystem.GetSuperData()
  for index, key in pairs(RedIndex2RedDotKeyMap) do
    self:AddDataListener(spData, key, self._UpdateRedPoint, self, index)
  end
  self.Common_Tab:SetTabs(tabVerticalTextLevelOne)
  log_tree("  UI_RoleInfoMain:SetTabs tabVerticalTextLevelOne = ", tabVerticalTextLevelOne)
  log(bWriteLog and "  UI_RoleInfoMain:SetTabs end")
end
function UI_RoleInfoMain:InsertCollectRankTab(tabs)
  local collect_rank_entry_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_rank_entry_module)
  local endTime = collect_rank_entry_module and collect_rank_entry_module:GetActivityEndTime()
  if not endTime then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local leftTime = endTime - now
  if leftTime <= 0 then
    log(bWriteLog and string.format("UI_RoleInfoMain:InsertCollectRankTab leftTime = %s", leftTime))
    return
  end
  table.insert(tabs, 1, {
    locResID = 77603,
    subTabId = RoleInfoMainSystem.CollectRank,
    cfg = UIManager.UI_Config.Collect_TimeLimitedRanking_UIBP
  })
  self.countdownTimer = self:AddTimerLoop(1, function()
    leftTime = leftTime - 1
    if leftTime <= 0 then
      if self.SubTabID == RoleInfoMainSystem.CollectRank then
        self.SubTabID = RoleInfoMainSystem.CollectMain
        self:UpdateUI()
      end
      if self.countdownTimer then
        self:RemoveTimer(self.countdownTimer)
        self.countdownTimer = nil
      end
    end
  end, TIMER_INFINITE, 1)
end
function UI_RoleInfoMain:SetCollectLibTabCfg()
  self.collectLibMaster = false
end
function UI_RoleInfoMain:ReSetCollectLibTabCfg()
  if not self.collectLibMaster then
    self.collectLibMaster = true
    uiCfg[RoleInfoMainSystem.CollectLib].cfg = UI_Config.Collect_Library_UIBP
  end
end
function UI_RoleInfoMain:AutoSetSubTab(subId)
  log_warning(bWriteLog and "  UI_RoleInfoMain:AutoSetSubTab. subId: " .. tostring(subId))
  local subIndex
  for _, list in pairs(SubTabList) do
    for i, tb in ipairs(list) do
      if tb.subTabId == subId then
        subIndex = i
        break
      end
    end
  end
  log_warning(bWriteLog and "  UI_RoleInfoMain:AutoSetSubTab. subIndex: " .. tostring(subIndex))
  if subIndex then
    self.Common_Tab:SelectSubTab(subIndex)
  end
end
function UI_RoleInfoMain:HideLobbyUI()
  local logic_lobby_main = require("client.slua.logic.lobby.logic_lobby_main")
  logic_lobby_main.HideLobbyUI()
  LobbySystem.CloseOtherMenu()
end
function UI_RoleInfoMain:SwitchTab(tab, extra)
  if not slua.isValid(self.UIRoot) then
    return
  end
  log(bWriteLog and "UI_RoleInfoMain:SwitchTab" .. tostring(tab))
  if self.TabID == tab then
    return
  end
  self:_ShowIndex(tab, extra)
  for i, v in ipairs(Index2TabID) do
    if v == tab then
      if SubTabList[self.TabID] then
        self.Common_Tab:SelectTab(i, 1)
      else
        self.Common_Tab:SelectTab(i)
      end
    end
  end
end
function UI_RoleInfoMain:WorkDataToPlayData()
  if self.TabID ~= RoleInfoMainSystem.WOW and self.SubTabID ~= RoleInfoMainSystem.WOW_SubTab.WorkData then
    return
  end
  self:_ShowIndex(RoleInfoMainSystem.WOW_SubTab.PlayData)
  self.Common_Tab:SelectSubTab(2)
end
function UI_RoleInfoMain:_UpdateRedPoint(index)
  local refreshIndex = SubTabId2MainTabIndex[index] or index
  log(bWriteLog and string.format("UI_RoleInfoMain:_UpdateRedPoint. index=%s, refreshIndex=%s", tostring(index), tostring(refreshIndex)))
  self.Common_Tab.ExtendedLoopScrollBox_Tab:RefreshItem(refreshIndex)
  self.Common_Tab.ExtendedLoopScrollBox_Tab:RefreshAllSubItems()
end
function UI_RoleInfoMain:RefreshCollectReddot(_, _)
  self:_UpdateRedPoint(collectDefaultIndex)
end
function UI_RoleInfoMain:RefreshIntimacyReddot(_, _)
  for key, value in pairs(Index2TabID) do
    if value == RoleInfoMainSystem.IntimateRelationship then
      self:_UpdateRedPoint(key)
    end
  end
end
function UI_RoleInfoMain:_CloseCurPage()
  if self.nCurPageUI then
    self.nCurPageUI:CloseSelf()
    self.nCurPageUI = nil
  end
  self:SetWidgetVisible(self.UIRoot.Button_Info, false)
end
function UI_RoleInfoMain:GetDataForJumpBack()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local Team_Evaluation_UIBP = UIManager.GetUI(UIManager.UI_Config.Team_Evaluation_UIBP)
  local data_Team_Evaluation_UIBP
  if Team_Evaluation_UIBP then
    data_Team_Evaluation_UIBP = Team_Evaluation_UIBP:GetDataForJumpBack()
  end
  local Achievement_Detail_1_UIBP = UIManager.GetUI(UIManager.UI_Config.Achievement_Detail_1_UIBP)
  local data_Achievement_Detail_1_UIBP
  if Achievement_Detail_1_UIBP then
    data_Achievement_Detail_1_UIBP = Achievement_Detail_1_UIBP:GetDataForJumpBack()
  end
  local role_info_big_avatar = UIManager.GetUI(UIManager.UI_Config.role_info_big_avatar)
  local data_role_info_big_avatar
  if role_info_big_avatar then
    data_role_info_big_avatar = role_info_big_avatar:GetDataForJumpBack()
  end
  local Personalization_UIBP = UIManager.GetUI(UIManager.UI_Config.Personalization_UIBP)
  local Personalization_UIBP_Data
  if Personalization_UIBP then
    Personalization_UIBP_Data = Personalization_UIBP:GetDataForJumpBack()
  end
  local intimacyType = 1
  if UIManager.IsUIShow(UIManager.UI_Config.Intimacy_Popup_Black_UIBP) then
    intimacyType = 2
  end
  local IntimateRelationship_Popup_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Popup_UIBP)
  local IntimateRelationship_Popup_Data
  if IntimateRelationship_Popup_UIBP then
    IntimateRelationship_Popup_Data = IntimateRelationship_Popup_UIBP:GetDataForJumpBack()
  end
  local Collect_Road_UIBP = UIManager.GetUI(UIManager.UI_Config.Collect_Road_UIBP)
  local Collect_Library_UIBP = UIManager.GetUI(UIManager.UI_Config.Collect_Library_UIBP)
  local Collect_Milestone_UIBP = UIManager.GetUI(UIManager.UI_Config.Collect_Milestone_UIBP)
  local Collect_Milestone_Visitor_UIBP = UIManager.GetUI(UIManager.UI_Config.Collect_Milestone_Visitor_UIBP)
  local Collect_TimeLimitedRanking_UIBP = UIManager.GetUI(UIManager.UI_Config.Collect_TimeLimitedRanking_UIBP)
  if not self.personalizeExtraData then
    self.personalizeExtraData = {}
  end
  if Collect_Road_UIBP then
    self.personalizeExtraData.subTab = Collect_Road_UIBP.nTab
    self.personalizeExtraData.showPopUp = Collect_Road_UIBP:GetJumpSourceInformation()
    log_warning(bWriteLog and "  UI_RoleInfoMain:GetDataForJumpBack. Collect_Road_UIBP.nTab: " .. tostring(Collect_Road_UIBP.nTab))
  elseif Collect_Library_UIBP then
    self.personalizeExtraData.subTab = Collect_Library_UIBP.nIndex
    self.personalizeExtraData.subData = Collect_Library_UIBP:GetDataForJumpBack()
    log_tree("  UI_RoleInfoMain:GetDataForJumpBack. self.personalizeExtraData.subData ", self.personalizeExtraData.subData)
  elseif Collect_Milestone_UIBP then
    self.personalizeExtraData.subTab = Collect_Milestone_UIBP.curSelectTab
  elseif Collect_Milestone_Visitor_UIBP then
    self.personalizeExtraData.subTab = Collect_Milestone_Visitor_UIBP.curSelectTab
  elseif Collect_TimeLimitedRanking_UIBP and Collect_TimeLimitedRanking_UIBP.GetJumpSourceInformation then
    self.personalizeExtraData.curType = Collect_TimeLimitedRanking_UIBP.GetJumpSourceInformation()
  end
  local Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP_Data
  local Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP)
  if Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP then
    Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP_Data = Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:GetDataForJumpBack()
  end
  log_warning(bWriteLog and "  UI_RoleInfoMain:GetDataForJumpBack. self.personalizeExtraData.subTab: " .. tostring(self.personalizeExtraData.subTab))
  if self.SubTabID == RoleInfoMainSystem.Honor_SubTab.Achievement and self.nCurPageUI and self.nCurPageUI.CurTab and self.nCurPageUI.CurTab == 0 then
    RoleInfoMainSystem.ResetAchieveInfo()
  end
  local nCurUId = RoleInfoSystem.CurShowPlayerInfoUid
  log_warning(bWriteLog and "  UI_RoleInfoMain:GetDataForJumpBack. self.SubTabID: " .. tostring(self.SubTabID))
  return {
    ctorData = {
      [1] = self.TabID,
      [2] = {
        inputAchieveInfo = RoleInfoMainSystem.GetAchieveInfo()
      },
      [3] = nCurUId,
      [4] = intimacyType,
      [6] = self.SubTabID,
      [7] = {
        sRecordJumpToUIdUrl = self._sRecordJumpToUIdUrl
      }
    },
    uiData = {
      friend_inner_list = UIManager.IsUIShow(UIManager.UI_Config.friend_inner_list),
      data_Team_Evaluation_UIBP = data_Team_Evaluation_UIBP,
      data_Achievement_Detail_1_UIBP = data_Achievement_Detail_1_UIBP,
      AchievementScoreAward_UIBP = UIManager.IsUIShow(UIManager.UI_Config.AchievementScoreAward_UIBP),
      data_role_info_big_avatar = data_role_info_big_avatar,
      Personalization_UIBP_Data = Personalization_UIBP_Data,
      data_intimacy_popup_Black = UIManager.IsUIShow(UIManager.UI_Config.Intimacy_Popup_Black_UIBP),
      Lobby_RoleInfo_IntimateRelationship_Popup_Large_UIBP = UIManager.IsUIShow(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Popup_Large_UIBP),
      IntimateRelationship_Popup_Data = IntimateRelationship_Popup_Data,
      SubTabID = self.SubTabID,
      personalizeExtraData = self.personalizeExtraData,
          }
  }
end
function UI_RoleInfoMain:JumpBack(uiData)
  if uiData then
    if uiData.friend_inner_list then
      UIManager.ShowUI(UIManager.UI_Config.friend_inner_list)
    end
    if uiData.data_Team_Evaluation_UIBP then
      local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
      logic_team_evaluation_view.ShowDetailedEvaluationView(uiData.data_Team_Evaluation_UIBP.ctorData[1])
    end
    if uiData.data_Achievement_Detail_1_UIBP then
      UIManager.ShowUI(UIManager.UI_Config.Achievement_Detail_1_UIBP, uiData.data_Achievement_Detail_1_UIBP.ctorData[1])
    end
    if uiData.AchievementScoreAward_UIBP then
      UIManager.ShowUI(UIManager.UI_Config.AchievementScoreAward_UIBP)
    end
    if uiData.data_role_info_big_avatar then
      UIManager.ShowUI(UIManager.UI_Config.role_info_big_avatar, uiData.data_role_info_big_avatar.ctorData[1])
    end
    if uiData.Personalization_UIBP_Data then
      self:_ShowIndex(self.TabID, {
        openTab = uiData.Personalization_UIBP_Data.ctorData[1]
      })
    end
    if uiData.Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP_Data then
      self:_ShowIndex(self.TabID, nil, true, 27)
    end
    if uiData.data_intimacy_popup_Black then
      UIManager.ShowUI(UIManager.UI_Config.Intimacy_Popup_Black_UIBP)
    end
    if uiData.Lobby_RoleInfo_IntimateRelationship_Popup_Large_UIBP then
      UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Popup_Large_UIBP)
    end
    if uiData.IntimateRelationship_Popup_Data then
      UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Popup_UIBP, uiData.IntimateRelationship_Popup_Data.ctorData[1])
    end
    if uiData.SubTabID then
      self.SubTabID = uiData.SubTabID
      self.personalizeExtraData = uiData.personalizeExtraData
      log_tree("  UI_RoleInfoMain:JumpBack. uiData.personalizeExtraData ", uiData.personalizeExtraData)
      self:UpdateUI()
    end
  end
end
function UI_RoleInfoMain:SetLoopAnimFlag(tab)
  self.animFlagTb[tab] = 1
end
function UI_RoleInfoMain:GetLoopAnimFlag(tab)
  return self.animFlagTb[tab]
end
function UI_RoleInfoMain:IsShowAchivement()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  return level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.achievement)
end
function UI_RoleInfoMain:UpdataCanvasPanel0Show(_, _, show)
  if self.UIRoot.CanvasPanel_0 then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_0, show)
  end
end
function UI_RoleInfoMain:OnSelectModForMatch()
  UIManager.AndroidBackToLobby()
end
function UI_RoleInfoMain:GetCurUIShowData()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  return RoleInfoSystem.GetCurShowUserId(), self.TabID, self.SubTabID
end
function UI_RoleInfoMain:SetRecordJumpToSelf(bIsRecord)
  self._sRecordJumpToUIdUrl = bIsRecord
end
function UI_RoleInfoMain:OnRefreshUIVisible(_, __, IsVisible)
  log(bWriteLog and "UI_RoleInfoMain:OnRefreshUIVisible IsVisible = " .. tostring(IsVisible))
  if not IsVisible then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UI_RoleInfoMain:OnByBlackListUpdate()
  log(bWriteLog and "RoleInfoMainSystem.OnByBlackListUpdate()")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local uid = RoleInfoSystem.CurShowPlayerInfoUid
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  if RoleInfoMainSystem.IsShow() and logic_friend_blacklist:IsByBlacklist(uid) then
    RoleInfoMainSystem.Close()
    ShowNotice(77902)
    return
  end
end
function UI_RoleInfoMain:OnUpdateAuthor(_, _, uid)
  log(bWriteLog and "UI_RoleInfoMain:OnUpdateAuthor uid = " .. uid .. " self.SubTabID = " .. tostring(self.SubTabID))
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if tonumber(uid) ~= tonumber(RoleInfoSystem.CurShowPlayerInfoUid) then
    return
  end
  if self.openSource == RoleInfoMainSystem.RoleInfoOpenFromType.RegionStrongerRank or self.openSource == RoleInfoMainSystem.RoleInfoOpenFromType.UGCTemplateUI or self.openSource == RoleInfoMainSystem.RoleInfoOpenFromType.WoWItem then
    log(bWriteLog and "UI_RoleInfoMain:OnUpdateAuthor  self.openSource = " .. tostring(self.openSource))
    if self.SubTabID then
      log(bWriteLog and "UI_RoleInfoMain:OnUpdateAuthor   self.SubTabID = " .. tostring(self.SubTabID))
      self.openSource = nil
      return
    end
    self:SetTabs()
    local tabId = self.TabID
    local find
    if RoleInfoMainSystem.IsCollectTabbByIndex(self.TabID) and self.personalizeExtraData then
      self:_ShowIndex(self.TabID, self.personalizeExtraData, true, self.personalizeExtraData.subTab)
    else
      self:_ShowIndex(self.TabID, {bInit = true})
    end
    for k, v in pairs(Index2TabID) do
      if v == tabId then
        if SubTabList[tabId] then
          local subId = 1
          for i, j in ipairs(SubTabList[tabId]) do
            if j.subTabId == self.SubTabID then
              subId = i
              log_warning(bWriteLog and "  UI_RoleInfoMain:OnUpdateAuthor.SubTabID subId: " .. tostring(subId))
            end
          end
          log(bWriteLog and "  UI_RoleInfoMain:OnUpdateAuthor. tabid: " .. tostring(k) .. " subId: " .. tostring(subId))
          self.Common_Tab:SelectTab(k, subId)
        else
          log(bWriteLog and "  UI_RoleInfoMain:OnUpdateAuthor. tabid: " .. tostring(k))
          self.Common_Tab:SelectTab(k)
        end
        find = true
        break
      end
    end
    log_warning(bWriteLog and "  UI_RoleInfoMain:OnUpdateAuthor. find: " .. tostring(find))
    log_warning(bWriteLog and "  UI_RoleInfoMain:OnUpdateAuthor. tabId: " .. tostring(tabId))
    log_tree("  UI_RoleInfoMain:OnUpdateAuthor. SubTabList ", SubTabList)
    if not find then
      for id, list in pairs(SubTabList) do
        for subIndex, v in ipairs(list) do
          if v.subTabId == tabId then
            for index, tab in ipairs(Index2TabID) do
              if tab == id then
                log_warning(bWriteLog and "  UI_RoleInfoMain:OnUpdateAuthor. id: " .. tostring(id))
                find = true
                self.Common_Tab:SelectTab(index, subIndex)
                break
              end
            end
            break
          end
        end
      end
    end
    if not find then
      log_warning(bWriteLog and "  UI_RoleInfoMain:OnUpdateAuthor.  not find")
      self.TabID = RoleInfoMainSystem.Segment
      self.Common_Tab:SelectTab(1)
    end
    self.openSource = nil
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, UI_RoleInfoMain)