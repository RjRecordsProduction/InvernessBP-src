local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
local Common_InformationCustom_Item = {}
function Common_InformationCustom_Item:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_SEASON_YEAR, EVENTID_OTHER_SEASON_YEAR_BADGE_UPDATE, self.UpdateModule, self)
end
function Common_InformationCustom_Item:OnPostInitialize()
  self:SetSelected(false)
  self:SetWidgetVisible(self.UIRoot.Image_Using, false)
  if self.UIRoot.Comp_CardCollection then
    local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
    self.Collect_Level_02 = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.CardCollection_Collect_Level_02, self.UIRoot.Comp_CardCollection)
  end
  if self.UIRoot.TextBlock_0 then
    self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(86352))
  end
  if self.UIRoot.Common_KingMark_UIBP_2 then
    local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
    self.Common_KingMark_UIBP_2 = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_KingMark_UIBP_2, self.UIRoot.Common_KingMark_UIBP_2)
  end
end
function Common_InformationCustom_Item:OnRegisterDrag()
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  local showType = logic_custom_presentation:GetInformationType()
  self.UIRoot.Common_DragDrop_Item:SetEnable(true)
  self.UIRoot.Common_DragDrop_Item:SetDragEnable(true)
  local path = "/Game/UMG/UI_BP/Common/Info/Common_InformationCustom_Large_Item.Common_InformationCustom_Large_Item"
  if showType == 2 then
    path = "/Game/UMG/UI_BP/Common/Info/Common_InformationCustom_Middle_Item.Common_InformationCustom_Middle_Item"
  elseif showType == 3 then
    path = "/Game/UMG/UI_BP/Common/Info/Common_InformationCustom_Tiny_Item.Common_InformationCustom_Tiny_Item"
  end
  self.UIRoot.Common_DragDrop_Item:RegisterDragWithDragPath(2, 0, 0, "", path)
  self.UIRoot.Common_DragDrop_Item:RegisterDrop(2)
  if self.data.hadEquip ~= 0 and not self:GetIsLeft() then
    self.UIRoot.Common_DragDrop_Item:SetEnable(false)
  end
end
function Common_InformationCustom_Item:SetEdit(isEdit)
  self.  if self.isEdit then
    if not self.isInitEvent then
      self.isInitEvent = true
      self:AddControlEventByControl(self.UIRoot.Common_DragDrop_Item, "OnDragReadyToShape", self.OnDragReadyToShape, self)
      self:AddControlEventByControl(self.UIRoot.Common_DragDrop_Item, "OnDragSuccess", self.OnDragSuccess, self)
      self:AddControlEventByControl(self.UIRoot.Common_DragDrop_Item, "OnDragCanCeled", self.OnDragCanceled, self)
      self:AddControlEventByControl(self.UIRoot.Common_DragDrop_Item, "OnDragClicked", self.OnDragClicked, self)
      self:AddControlEventByControl(self.UIRoot.Common_DragDrop_Item, "OnTestDragEnter", self.OnDragStart, self)
      self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_CLICK, self.OnItemSelect, self)
      self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_TYPE_CHANGE, self.OnRegisterDrag, self)
      self:OnRegisterDrag()
    end
  else
    self:HideCantEditorDetail()
  end
end
function Common_InformationCustom_Item:GetData()
  return self.data
end
function Common_InformationCustom_Item:SetIndex(index)
  self.data.end
function Common_InformationCustom_Item:OnRefresh(data, selectIndex)
  self.  self.data.index = self.index
  self.isEdit = data.isEdit or false
  if self.isEdit then
    self:SetEdit(self.isEdit)
  end
  self._uid = data.uid
  self._configData = data.configData
  self._isSelfRole = tonumber(self._uid) == tonumber(DataMgr.roleData.uid)
  if not self._configData then
    return
  end
  local configID = self._configData.ID
  self:RefreshEquip()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(self._uid)
  if not profile then
    self:ShowLogByClassName("SetModuleData self._uid " .. self._uid .. " profile is nil", UEnums.LogLevel.WARN)
    return
  end
  local collapseList = {
    "Common_Exquisite_Collect_Level_DynamicLoading_UIBP",
    "WidgetSwitcher_Home",
    "Common_Avatar_BP",
    "SizeBox_Badge_Root",
    "WidgetSwitcher_StarName",
    "Common_KingMark_UIBP_2",
    "Common_KingMark_UIBP",
    "Image_Level",
    "Comp_CardCollection",
    "Image_MarkBg",
    "UnknowPass_Medal_Item_UIBP",
    "Title_UIBP",
    "Image_Mark",
    "CanvasPanel_Mark"
  }
  for _, widgetName in ipairs(collapseList) do
    if self.UIRoot[widgetName] then
      self.UIRoot[widgetName]:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
  end
  local itemData
  local isMax = false
  if configID == custom_presentation_config.NewModuleID.Common_RankIntegralLevel then
    itemData = self:GetCommonRankIntegralLevelShow(profile, self.data.rank_segment_id)
  elseif configID == custom_presentation_config.NewModuleID.Common_RankIntegralLevelMax then
    itemData = self:GetCommonRankIntegralLevelShowMax(profile)
    isMax = true
  elseif configID == custom_presentation_config.NewModuleID.PeakGame_RankIntegralLevel then
    itemData = self:GetPeakGameRankIntegralShow(profile)
  elseif configID == custom_presentation_config.NewModuleID.PeakGame_RankIntegralLevelMax then
    itemData = self:GetPeakGameRankIntegralShowMax(profile)
    isMax = true
  elseif configID == custom_presentation_config.NewModuleID.KingMark then
    itemData = self:GetKingMarkShow(profile, self.data.honer_id, self.data.honer_count, self.data.advance_num)
  elseif configID == custom_presentation_config.NewModuleID.KingMarkMax then
    itemData = self:GetKingMarkShowMax(self.data.peakAce_id, self.data.peakAce_count)
  elseif configID == custom_presentation_config.NewModuleID.MetroSegment then
    itemData = self:GetMetroSegmentShow(profile)
    self.UIRoot.WidgetSwitcher_StarName:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif configID == custom_presentation_config.NewModuleID.Collect_Level then
    itemData = self:GetCollectInfo(profile)
  elseif configID == custom_presentation_config.NewModuleID.Home then
    self.UIRoot.WidgetSwitcher_Home:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    itemData = self:SetHomeInfo()
  elseif configID == custom_presentation_config.NewModuleID.WOW_Author then
    itemData = self:GetUGCAuthorShow(self.data.author_level)
  elseif configID == custom_presentation_config.NewModuleID.Relation then
    self.UIRoot.Common_Avatar_BP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    itemData = self:UpdateFriendBaseData(self.data.relation_uid or self.data.moduleData.mData.uid, self.data.relation_type, self.data.relation_intimacy)
  elseif configID == custom_presentation_config.NewModuleID.WOW_Play then
    itemData = self:GetUGCPlayShow()
  elseif configID == custom_presentation_config.NewModuleID.SeasonYear then
    itemData = self:GetAnnualBadgeData()
    self.UIRoot.SizeBox_Badge_Root:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif configID == custom_presentation_config.NewModuleID.Title then
    itemData = self:GetTitleData(profile, self.data.alias_id, self.data.alias_title)
  elseif configID == custom_presentation_config.NewModuleID.Achievement then
    itemData = self:GetAchievementData(self.data.summary_id)
  elseif configID == custom_presentation_config.NewModuleID.CardCollect then
    itemData = self:GetCardScoreData(self.data.card_score)
  elseif configID == custom_presentation_config.NewModuleID.Honor then
    itemData = self:GetHonorData(self.data.pround_level)
  elseif configID == custom_presentation_config.NewModuleID.Popularity then
    itemData = self:GetPopularityData(self.data.popularity)
  elseif configID == custom_presentation_config.NewModuleID.RP_Level then
    itemData = self:GetRPLevelData(profile, self.data.bp_season, self.data.bp_isBuyElite, self.data.bp_level)
  elseif configID == custom_presentation_config.NewModuleID.Relax_RankIntegralLevel then
    itemData = self:GetRelaxRankBigData(self.data.relex_rankId)
  end
  self:SetBottomData(itemData)
  if self.UIRoot.CanvasPanel_Max then
    if isMax then
      self.UIRoot.CanvasPanel_Max:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.CanvasPanel_Max:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  self.UIRoot.Border_Main:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function Common_InformationCustom_Item:SetBottomData(itemData)
  if itemData and self.UIRoot then
    if itemData.icon and itemData.icon ~= "" then
      self.UIRoot.Image_Base:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:SetTexture(self.UIRoot.Image_Base, itemData.icon)
    else
      self.UIRoot.Image_Base:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if itemData.bgTexture and itemData.bgTexture ~= "" and self.UIRoot.Image_3 then
      self:SetTexture(self.UIRoot.Image_3, itemData.bgTexture)
    elseif self.UIRoot.Image_3 then
      self:SetTexture(self.UIRoot.Image_3, "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Info/Common_Info_Image_Bg.Common_Info_Image_Bg")
    end
    if self.UIRoot.TextBlock_Title then
      if itemData.titleColor and itemData.titleColor ~= "" then
        self.UIRoot.TextBlock_Title:SetColorAndOpacity(itemData.titleColor)
        if self.UIRoot.TextBlock_FireLevel then
          self.UIRoot.TextBlock_FireLevel:SetColorAndOpacity(itemData.titleColor)
        end
      else
        self.UIRoot.TextBlock_Title:SetColorAndOpacity(FSlateColor(FLinearColor(1.0, 1.0, 1.0, 1)))
        if self.UIRoot.TextBlock_FireLevel then
          self.UIRoot.TextBlock_FireLevel:SetColorAndOpacity(FSlateColor(FLinearColor(1.0, 1.0, 1.0, 1)))
        end
      end
    end
    if itemData.title and itemData.title ~= "" then
      if self.UIRoot.TextBlock_Title then
        self.UIRoot.TextBlock_Title:SetText(itemData.title)
        self.UIRoot.TextBlock_Title:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.UIRoot.CanvasPanel_Rank then
        self.UIRoot.CanvasPanel_Rank:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.UIRoot.TextBlock_Achievement then
        self.UIRoot.TextBlock_Achievement:SetText(itemData.title)
        self.UIRoot.TextBlock_Achievement:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.UIRoot.TextBlock_FireLevel then
        self.UIRoot.TextBlock_FireLevel:SetText(itemData.title)
        self.UIRoot.TextBlock_FireLevel:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.UIRoot.TextBlock_ProundLevel then
        self.UIRoot.TextBlock_ProundLevel:SetText(itemData.title)
        self.UIRoot.TextBlock_ProundLevel:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.UIRoot.TextBlock_Honor01 then
        self.UIRoot.TextBlock_Honor01:SetText(itemData.title)
        self.UIRoot.TextBlock_Honor01:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.UIRoot.TextBlock_Honor02 then
        self.UIRoot.TextBlock_Honor02:SetText(itemData.title)
        self.UIRoot.TextBlock_Honor02:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      if self.UIRoot.CanvasPanel_Rank then
        self.UIRoot.CanvasPanel_Rank:SetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      if self.UIRoot.TextBlock_Title then
        self.UIRoot.TextBlock_Title:SetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function Common_InformationCustom_Item:OnDragReadyToShape(GeneratedWidget, DragDropData)
  self:RefreshDragWidget(GeneratedWidget, DragDropData)
end
function Common_InformationCustom_Item:OnDragStart(GeneratedWidget, DragDropData)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_CLICK, self.data, self.index, true)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_DRAG, true)
end
function Common_InformationCustom_Item:RefreshDragWidget(widget, data)
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  self.widget = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_InformationCustom_Item, widget)
  self.widget:OnRefresh(self.data)
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  logic_custom_presentation:SetCurDragData(self.data)
  widget.Border_Main.Slot:SetPosition(FVector2D(1, 1))
end
function Common_InformationCustom_Item:OnDragSuccess(DragWidget, index, DragDropData)
  self:PlayAudio(sound_config.click)
  log(bWriteLog and string.format("Prepare_Consumables_Item:OnDragSuccess"))
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_DRAG, false)
end
function Common_InformationCustom_Item:OnDragCanceled()
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  logic_custom_presentation:SetCurDragData(nil)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_DRAG, false)
end
function Common_InformationCustom_Item:OnDragClicked()
  self:PlayAudio(sound_config.click_v1)
  local isSelectCancel = false
  if self.isSelect then
    isSelectCancel = true
  end
  if not self:GetIsLeft() then
    local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
    logic_custom_presentation:SetCurDragData(self.data)
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_CLICK, self.data, self.index, isSelectCancel)
end
function Common_InformationCustom_Item:GetCommonRankIntegralLevelShow(profile, segment_id)
  local rankData = profile.segment_info
  local logic_season_util = require("client.logic.season.logic_season_util")
  local rank_segment_id = segment_id or logic_season_util:GetCurrAllZoneMaxSegment(rankData)
  rank_segment_id = rank_segment_id or 101
  local rankCfg = FuncUtil.GetRankTableData(rank_segment_id, 0)
  if not rankCfg then
    log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteral rankCfg is nil")
    return {icon = "", title = ""}
  end
  local uiUtil = require("client.slua_ui_framework.util")
  if rankCfg.SubIcon and rankCfg.SubIcon ~= "" then
    self.UIRoot.Image_Level:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    uiUtil.SetTexture(self.UIRoot.Image_Level, rankCfg.SubIcon)
  else
    self.UIRoot.Image_Level:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
  end
  return {
    icon = rankCfg.BigIcon,
    title = rankCfg.Name
  }
end
function Common_InformationCustom_Item:GetCommonRankIntegralLevelShowMax(profile)
  if not profile.history_max_segment_level then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      tonumber(self._uid)
    }, function(list)
      if not (list and self.UIRoot) or #list == 0 then
        return
      end
      local _profile = list[1]
      local itemData = self:OnGetSelfRoleInfoCallBack(_profile)
      self:SetBottomData(itemData)
      if not self.isEdit then
        self:HideCantEditorDetail()
      end
    end, Enum_PROFILE_REPORT_CFG.ROLE_INFO, 100, true)
    return
  end
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
  end
  return self:OnGetSelfRoleInfoCallBack(profile)
end
function Common_InformationCustom_Item:OnGetSelfRoleInfoCallBack(profile)
  local historyRanks = profile.history_max_segment_level or {101}
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local rank_segment_id, historySeasonId = RoleInfoMainSystem.GetHistotyMaxSegmentAndSeasonId(historyRanks, profile.history_max_segment_season_id)
  if not rank_segment_id then
    return
  end
  local rankCfg = FuncUtil.GetRankTableData(rank_segment_id, historySeasonId)
  if not rankCfg then
    return
  end
  local uiUtil = require("client.slua_ui_framework.util")
  if self.UIRoot then
    if rankCfg.SubIcon and rankCfg.SubIcon ~= "" then
      self.UIRoot.Image_Level:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      uiUtil.SetTexture(self.UIRoot.Image_Level, rankCfg.SubIcon)
    else
      self.UIRoot.Image_Level:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.UIRoot.WidgetSwitcher_BG_Text then
      self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
    end
  end
  return {
    icon = rankCfg.BigIcon,
    title = rankCfg.Name
  }
end
function Common_InformationCustom_Item:GetPeakGameRankIntegralShow()
  local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local peakSegment = PeakGameConfig.DefaultPeakGameSegment
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  if self._isSelfRole then
    peakSegment = LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxSegmentId()
  else
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    local profile = LobbySocialSystem.GetProfileByUID(self._uid)
    if profile then
      peakSegment = LogicPeakGameSegmentUtil.GetProfileCurMaxSegmentId(profile)
    end
  end
  local segmentCfg = LogicPeakGameUtil.GetPeakRankTableData(peakSegment)
  if not segmentCfg then
    peakSegment = PeakGameConfig.DefaultPeakGameSegment
  end
  segmentCfg = LogicPeakGameUtil.GetPeakRankTableData(peakSegment)
  if not segmentCfg then
    return {icon = "", title = ""}
  end
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
  end
  return {
    icon = segmentCfg.BigIcon,
    title = segmentCfg.Name
  }
end
function Common_InformationCustom_Item:GetPeakGameRankIntegralShowMax(profile)
  local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
  local peakSegment = LogicPeakGameSegmentUtil.GetProfileHistoryMaxSegmentId(profile)
  if not peakSegment then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Large:SetPeakRankIntegral no segment")
    return
  end
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local segmentCfg = LogicPeakGameUtil.GetPeakRankTableData(peakSegment)
  if not segmentCfg then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Large:SetPeakRankIntegral no segmentCfg")
    return
  end
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
  end
  return {
    icon = segmentCfg.BigIcon,
    title = segmentCfg.Name
  }
end
function Common_InformationCustom_Item:GetPeakGameAce()
  local ace_util = require("client.logic.season.ace.ace_util")
  local peakgame_ace_id, peakgame_ace_count = ace_util.GetPeakGameAceData(self._uid)
  local hasData = peakgame_ace_id and 0 < peakgame_ace_count
  if not hasData then
    return {
      icon = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not",
      title = LocUtil.LocalizeResFormat(79778)
    }
  end
  local peakGameAceCfg = CDataTable.GetTableData("PeakGameAce", peakgame_ace_id)
  if not peakGameAceCfg then
    return {
      icon = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not",
      title = LocUtil.LocalizeResFormat(79778)
    }
  end
  return {
    icon = peakGameAceCfg.Icon,
    title = LocUtil.LocalizeResFormat(ace_config.peakGameAceIDLQA[peakgame_ace_id].Name)
  }
end
function Common_InformationCustom_Item:GetHonerGameAce()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local ace_imprint_show_id, ace_imprint_base_id, ace_imprint_show_cnt = LobbySocialSystem.GetAceImprintShowId(self._uid)
  if not season_year_util.CheckFunctionIsOpen() then
    return {
      icon = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not",
      title = LocUtil.LocalizeResFormat(79778)
    }
  end
  local hasData = ace_imprint_show_id ~= nil
  if not hasData then
    return {
      icon = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not",
      title = LocUtil.LocalizeResFormat(79778)
    }
  end
  local ace_util = require("client.logic.season.ace.ace_util")
  local advance_num = 0
  local history_num = 0
  if ace_imprint_show_cnt and 0 < ace_imprint_show_cnt then
    advance_num = ace_imprint_show_id - ace_imprint_base_id
    history_num = ace_imprint_show_cnt - advance_num
  end
  local base_id = ace_imprint_base_id
  if 1000 < ace_imprint_base_id then
    base_id = ace_imprint_base_id // 1000
  end
  local aceImprintCfg = ace_config.HonerImprintInfo[base_id]
  if not aceImprintCfg then
    return {
      icon = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not",
      title = LocUtil.LocalizeResFormat(79778)
    }
  end
  local source_id = ace_imprint_base_id
  if 1000 < source_id then
    source_id = source_id // 1000
  end
  if self.Common_KingMark_UIBP_2 then
    self.Common_KingMark_UIBP_2:SetWidgetInfo(source_id, {advance_num = advance_num, history_num = history_num})
    self.UIRoot.Common_KingMark_UIBP_2:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  return {
    icon = aceImprintCfg.Icon,
    title = ace_config.honerGameAceIDLQA[source_id].Name
  }
end
function Common_InformationCustom_Item:GetClassicAce()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local ace_imprint_show_id, ace_imprint_base_id = LobbySocialSystem.GetAceImprintShowId(self._uid)
  local hasData = ace_imprint_show_id ~= nil
  if not hasData then
    return {
      icon = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not",
      title = LocUtil.LocalizeResFormat(79778)
    }
  end
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  local ace_base_id, ace_num = AceImprintLogic.GetAceImprintBaseId(ace_imprint_show_id, ace_imprint_base_id)
  if ace_base_id <= 0 or ace_num <= 0 then
    return {
      icon = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not",
      title = LocUtil.LocalizeResFormat(79778)
    }
  end
  local ace_util = require("client.logic.season.ace.ace_util")
  ace_base_id = ace_util.GetFinalBaseId(ace_base_id)
  local aceImprintCfg = CDataTable.GetTableData("AceImprintIcon", ace_base_id)
  local icon = aceImprintCfg.Icon
  local title = ""
  local AceImprintDetailS20 = AceImprintLogic.GetAceImprintDetailS20(self._uid)
  local summaryMap = AceImprintDetailS20 and AceImprintDetailS20.summary or nil
  for _, id in pairs(ace_config.ImprintBaseIDList) do
    if summaryMap then
      local info = summaryMap[id]
      if info and info.base_id == ace_imprint_base_id then
        title = LocUtil.LocalizeResFormat(ace_config.ImprintBaseIDLQA[id].Name)
        break
      end
    end
  end
  return {icon = icon, title = title}
end
function Common_InformationCustom_Item:GetSpecialImprintPorcess()
  local ace_show_type = LobbySystem.roleData.ace_show_type
  if ace_show_type == nil then
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    local ace_imprint_show_id, ace_imprint_base_id, ace_imprint_show_cnt = LobbySocialSystem.GetAceImprintShowId(self._uid)
    if ace_imprint_base_id then
      local ace_util = require("client.logic.season.ace.ace_util")
      if ace_util.IsHonerImprint(ace_imprint_base_id) then
        return self:GetHonerGameAce()
      else
        return self:GetClassicAce()
      end
    else
      return self:GetClassicAce()
    end
  else
    return self:GetClassicAce()
  end
end
function Common_InformationCustom_Item:GetKingMarkShow(profile, honer_id, honer_count, advance_num)
  if not honer_id then
    return self:GetHonerGameAce(profile)
  end
  advance_num = advance_num or 0
  honer_count = honer_count or 0
  local aceImprintCfg = ace_config.HonerImprintInfo[honer_id]
  if not aceImprintCfg then
  end
  local source_id = honer_id
  if 1000 < source_id then
    source_id = source_id // 1000
  end
  if self.Common_KingMark_UIBP_2 then
    self.Common_KingMark_UIBP_2:SetWidgetInfo(honer_id, {
      advance_num = advance_num,
      history_num = honer_count - advance_num
    })
    self.UIRoot.Common_KingMark_UIBP_2:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
  end
  return {
    icon = "",
    title = LocUtil.GetLocalizeResStr(ace_config.honerGameAceIDLQA[source_id].Name)
  }
end
function Common_InformationCustom_Item:GetKingMarkShowMax(peakgame_ace_id, peakgame_ace_count)
  if not peakgame_ace_id then
    return {icon = "", title = ""}
  end
  local textId = 68583
  if peakgame_ace_id == 1301 then
    textId = 68583
  elseif peakgame_ace_id == 1401 then
    textId = 68584
  elseif peakgame_ace_id == 1501 then
    textId = 68585
  end
  local ace_util = require("client.logic.season.ace.ace_util")
  peakgame_ace_count = peakgame_ace_count or 1
  ace_util.SetPeakGameAceImage(self.UIRoot.Common_KingMark_UIBP, peakgame_ace_id, peakgame_ace_count)
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
  end
  return {
    icon = "",
    title = LocUtil.GetLocalizeResStr(textId)
  }
end
function Common_InformationCustom_Item:GetMetroRank(rankIntegral)
  local logic_TxMission_in_lobby = require("client.slua.logic.lobby.TxMission.logic_TxMission_in_lobby")
  local rankCfg = logic_TxMission_in_lobby.GetTPlanIconInLobby(rankIntegral)
  if not rankCfg then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:_SetRankInteralInXMission rankCfg is nil")
    return
  end
  local DefaultIcon = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/RanklntegralLevel_M_01.RanklntegralLevel_M_01"
  local TypeID = rankCfg.TypeID or 1
  local TextureList = {
    "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/RanklntegralLevel_M_01.RanklntegralLevel_M_01",
    "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/RanklntegralLevel_M_02.RanklntegralLevel_M_02",
    "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/RanklntegralLevel_M_03.RanklntegralLevel_M_03",
    "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/RanklntegralLevel_M_04.RanklntegralLevel_M_04",
    "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/RanklntegralLevel_M_05.RanklntegralLevel_M_05",
    "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/RanklntegralLevel_M_06.RanklntegralLevel_M_06",
    "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/RanklntegralLevel_M_07.RanklntegralLevel_M_07"
  }
  local Texture = TextureList[TypeID] or DefaultIcon
  return Texture
end
function Common_InformationCustom_Item:GetMetroSegmentShow(profile)
  local military_level = profile.metro_summary and profile.metro_summary.military_level or 1
  local icon = self:GetMetroRank(military_level)
  local logic_TxMission_in_lobby = require("client.slua.logic.lobby.TxMission.logic_TxMission_in_lobby")
  local rankCfg = logic_TxMission_in_lobby.GetTPlanIconInLobby(military_level)
  return {
    icon = icon,
    title = rankCfg.name
  }
end
function Common_InformationCustom_Item:GetCollectInfo(profile)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_data = collect_module.collect_data
  local score, seasonScore = 0, 0
  local TableUtil = require("common.table_util")
  local season = collect_module:GetSeasonId()
  if not self._isSelfRole then
    collect_data = profile.collect_data
    score, seasonScore = collect_module:GetCollectScoreByCollectData(collect_data)
  elseif collect_data then
    score = collect_data.total_score
    seasonScore = TableUtil.GetTableValue(collect_data.season_score, season) or 0
  end
  local CollectLevelCfg = CDataTable.GetTable(collect_module:GetTBName("CollectLevel"))
  local nextScore, l = 0, 1
  local curLevel, nextLevel, levelName = 1, 1, ""
  for level, v in pairs(CollectLevelCfg) do
    nextScore = v.Score
    nextLevel = tonumber(level)
    l = v.Dan
    if score < nextScore then
      curLevel = nextLevel
      levelName = v.DanDesc
      break
    end
  end
  local maxLevel = 1
  for level, _ in pairs(CollectLevelCfg) do
    maxLevel = tonumber(level)
  end
  if score >= nextScore then
    curLevel = nextLevel
  end
  if curLevel == maxLevel then
    curLevel = nextLevel
    levelName = CDataTable.GetTableData(collect_module:GetTBName("CollectLevel"), curLevel).DanDesc
  end
  local sLevel = collect_module:GetSeasonLevelByScore(seasonScore)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  self.UIRoot.Common_Exquisite_Collect_Level_DynamicLoading_UIBP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Common_Exquisite_Collect_Level_DynamicLoading_UIBP:InitExquisiteCollectBadge(self._uid, {
    seasonLevel = sLevel,
    rank = l,
    totalLevel = curLevel,
    animationType = collect_cfg.E_CollectBadge_AnimaType.None
  })
  if self.UIRoot.WidgetSwitcher_BG_Text then
    local collect_badge_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_badge_module)
    local light = collect_badge_module:CheckBadgeActivation(sLevel, self._uid)
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(light and 6 or 7)
  end
  return {icon = "", title = levelName}
end
function Common_InformationCustom_Item:GetSlotIndex()
  return self.index or 0
end
function Common_InformationCustom_Item:SetHomeInfo()
  local configData = CDataTable.GetTableData("CustomPresentationModule", custom_presentation_config.NewModuleID.Home)
  local title = LocUtil.GetLocalizeResStr(configData.TextID)
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch:CheckHomeSwitchOpen() or logic_home_switch:CheckHomeLimit() then
    return {icon = "", title = title}
  end
  local uid = self._uid
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  logic_home_profile:GetOrReqHomeProfile({uid}, function()
    if not slua.isValid(self.UIRoot) then
      self:ShowLogByClassName("UpdateModule self.UIRoot is invalid", UEnums.LogLevel.WARN)
      return
    end
    local profile = logic_home_profile:GetHomeProfileByUid(uid)
    if profile and not profile.bUnLock then
      self:SetEmptyHomeShow()
    else
      local logic_home_detail = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_detail)
      logic_home_detail:GetOrReqHomeDetail(self._uid, function(uid, detail)
        if not slua.isValid(self.UIRoot) then
          self:ShowLogByClassName("UpdateModule self.UIRoot is invalid", UEnums.LogLevel.WARN)
          return
        end
        self:SetHomeShow(detail)
      end, false)
    end
  end, nil, false)
  return {icon = "", title = title}
end
function Common_InformationCustom_Item:SetEmptyHomeShow()
  self:ShowLogByClassName("SetEmptyHomeShow")
  self._isEmptyHome = true
  self.UIRoot.WidgetSwitcher_Home:SetActiveWidgetIndex(2)
  if self.UIRoot.Image_Home then
    self.UIRoot.Image_Home:SetColorAndOpacity(FLinearColor(0.097587, 0.097587, 0.097587, 1))
  end
end
function Common_InformationCustom_Item:SetHomeShow(detail)
  self:ShowLogByClassName("SetHomeShow")
  log_tree("SetHomeShow detail = ", detail)
  self._isEmptyHome = false
  if self.SetHomeShowPreInit then
    self:SetHomeShowPreInit()
  end
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local homeProfile = logic_home_profile:GetHomeProfileByUid(self._uid, false)
  if homeProfile and homeProfile.grow_info and homeProfile.grow_info.level then
    self:SetWidgetVisible(self.UIRoot.TextBlock_Rank1, true, false)
    self:SetWidgetVisible(self.UIRoot.TextBlock_Rank2, true, false)
    local level = homeProfile.grow_info.level
    self.UIRoot.TextBlock_Rank1:SetText(level)
    self.UIRoot.TextBlock_Rank2:SetText(level)
  else
    self:SetWidgetVisible(self.UIRoot.TextBlock_Rank1, false, false)
    self:SetWidgetVisible(self.UIRoot.TextBlock_Rank2, false, false)
  end
  local jointUID = logic_home_profile:GetHomeJointUID(self._uid)
  self.UIRoot.WidgetSwitcher_Home:SetActiveWidgetIndex(jointUID ~= nil and 1 or 0)
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(3)
    self.UIRoot.Image_Home:SetColorAndOpacity(FLinearColor(0.571125, 0.266356, 0.022174, 1))
    local totalStructureProsperity = detail.grow_info.prosperity_detail[1] or 0
    local totalDecorateProsperity = detail.grow_info.prosperity_detail[2] or 0
    local totalOthersProsperity = detail.grow_info.prosperity_detail[3] or 0
    local totalProsperity = totalStructureProsperity + totalDecorateProsperity + totalOthersProsperity
    self.UIRoot.Text_Home:SetText(totalProsperity)
    local showRedPanel = false
    if self.HideParking then
      self:SetWidgetVisible(self.UIRoot.Image_Parking, false, false)
    else
      local parking_info = detail.master_tip_info and detail.master_tip_info.parking_info
      local showParking = false
      if parking_info then
        local hasParkingGift = parking_info.parking_gift and next(parking_info.parking_gift) or false
        showParking = hasParkingGift
      end
      showRedPanel = showParking
      self:SetWidgetVisible(self.UIRoot.Image_Parking, showParking)
    end
    if self.HideHomeTree then
      self:SetWidgetVisible(self.UIRoot.Image_Tree, false, false)
    else
      local planting_plat_list = detail.planting_plat_list
      local logic_home_golden_tree = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_golden_tree)
      local gtState = logic_home_golden_tree:GetCollectState(planting_plat_list, tonumber(self._uid) == tonumber(DataMgr.roleData.uid))
      local home_collection_macro = require("client.slua.logic.home.Collection.home_collection_macro")
      local showTree = gtState == home_collection_macro.Enum_GoldenTree_State.VALID
      showRedPanel = showTree or showRedPanel
      self:SetWidgetVisible(self.UIRoot.Image_Tree, showTree)
    end
    if self.HideParty then
      self:SetWidgetVisible(self.UIRoot.Image_Party, false, false)
    else
      local HomePartyUtil = require("client.slua.logic.homeparty.HomePartyUtil")
      local party_show_info = detail.party_show_info
      local showParty = HomePartyUtil.IsShowParty(self._uid, party_show_info)
      showRedPanel = showParty or showRedPanel
      self:SetWidgetVisible(self.UIRoot.Image_Party, showParty)
    end
    self.UIRoot.WidgetSwitcher_Text:SetActiveWidgetIndex(showRedPanel and 1 or 0)
  end
end
function Common_InformationCustom_Item:GetUGCAuthorShow(author_level)
  if not author_level then
    return {
      icon = "/Game/UMG/Texture_200/Lobby_NoAtlas/Ugc/CreatorLv/CreatorLv_Image_Lv_01.CreatorLv_Image_Lv_01",
      title = ""
    }
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local authorLevelConfig = Config_UGC.GetAuthorLevelConfigByID(author_level)
  local imagePath
  local rankName = ""
  local ugcLevel
  if authorLevelConfig then
    imagePath = authorLevelConfig.ModuleIcon or authorLevelConfig.PageIcon
    rankName = authorLevelConfig.Name
  else
    imagePath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Ugc/CreatorLv/CreatorLv_Image_Lv_01.CreatorLv_Image_Lv_01"
  end
  return {icon = imagePath, title = rankName}
end
function Common_InformationCustom_Item:UpdateFriendBaseData(friend_uid, intimacyType, relation_intimacy)
  if not friend_uid then
    return {icon = "", title = ""}
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(friend_uid)
  if not profile then
    self:ShowLogByClassName("SetFriendBaseData friendUID " .. friend_uid .. " profile is nil", UEnums.LogLevel.WARN)
    local callback = function(listinfo)
      if not slua.isValid(self.UIRoot) then
        return
      end
      local friendProfile = listinfo and 0 < #listinfo and listinfo[1]
      if friendProfile then
        self.UIRoot.Common_Avatar_BP:InitView(1, friendProfile.uid, friendProfile.picUrl, 0, friendProfile.cur_avatar_box_id, friendProfile.level, false, "")
        if self.UIRoot.TextBlock_Rank then
          self.UIRoot.TextBlock_Rank:SetText(friendProfile.nickName)
        end
        self:SetIntimacyData(friend_uid, intimacyType, relation_intimacy)
      end
    end
    local custom_presentation_util = require("client.slua.logic.person_space.custom_presentation_util")
    custom_presentation_util.GetRelationFriendData(friend_uid, callback)
    return
  end
  self.UIRoot.Common_Avatar_BP:InitView(1, profile.uid, profile.picUrl, 0, profile.cur_avatar_box_id, profile.level, false, "")
  self:SetIntimacyData(friend_uid, intimacyType, relation_intimacy)
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(1)
    self.UIRoot.TextBlock_Rank:SetText(profile.nickName)
  end
  return {
    icon = "",
    title = profile.nickName
  }
end
function Common_InformationCustom_Item:SetIntimacyData(friend_uid, intimacy_Type, relation_intimacy)
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  local intimacyInfo = logic_friend_intimacy:GetIntimacyInfo(self._uid, friend_uid)
  local intimacyType = logic_friend_intimacy:GetIntimacyType(self._uid, friend_uid)
  local hasIntimacy = intimacyInfo and 0 < intimacyType
  if not hasIntimacy and not intimacy_Type then
    self:SetTexture(self.UIRoot.Image_Mark, "")
    if self.UIRoot.Image_Mark then
      self.UIRoot.Image_Mark:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.UIRoot.Image_MarkBg then
      self.UIRoot.Image_MarkBg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.UIRoot.CanvasPanel_Mark then
      self.UIRoot.CanvasPanel_Mark:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.UIRoot.Image_Mark_Small then
      self.UIRoot.Image_Mark_Small:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.UIRoot.TextBlock_Star then
      self.UIRoot.TextBlock_Star:SetText(0)
    end
    if self.UIRoot.TextBlock_Rank then
      self.UIRoot.TextBlock_Rank:SetText("")
    end
    return
  end
  local relationType = intimacy_Type or intimacyInfo.param or intimacyInfo.relation
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local iconPath = IntimacyUtils.GetRelationTypeIcon(relationType)
  if iconPath then
    if self.UIRoot.Image_Mark then
      self:SetTexture(self.UIRoot.Image_Mark, iconPath)
    end
    local smallIcon = IntimacyUtils.GetRelationTypeSmallIcon(relationType)
    if self.UIRoot.Image_Mark_Small then
      self:SetTexture(self.UIRoot.Image_Mark_Small, smallIcon)
    end
  end
  if self.UIRoot.Image_Head then
    local color = {
      FLinearColor(0.107023, 0.254152, 0.371238, 1),
      FLinearColor(0.473532, 0.250158, 0.291771, 1),
      FLinearColor(0.672443, 0.467784, 0.155926, 1),
      FLinearColor(0.391573, 0.158961, 0.3564, 1),
      FLinearColor(0.450786, 0.194618, 0.138432, 1)
    }
    self.UIRoot.Image_Head:SetColorAndOpacity(color[relationType])
  end
  if self.UIRoot.Image_Mark then
    self.UIRoot.Image_Mark:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.UIRoot.Image_MarkBg then
    self.UIRoot.Image_MarkBg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.UIRoot.CanvasPanel_Mark then
    self.UIRoot.CanvasPanel_Mark:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.UIRoot.TextBlock_Star then
    self.UIRoot.TextBlock_Star:SetText(relation_intimacy or intimacyInfo and intimacyInfo.intimacy or "")
  end
end
function Common_InformationCustom_Item:GetUGCPlayShow()
  local level, exp
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  if self._isSelfRole then
    level = logic_ugc_playlevel.CurLevel
    exp = logic_ugc_playlevel.CurExp
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(self._uid)
    level = profile.ugc_play_level
    exp = profile.ugc_play_exp
  end
  level = level or 1
  exp = exp or 0
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local authorLevelConfig = Config_UGC.GetAuthorLevelConfigByID(level)
  local imagePath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Ugc/CreatorLv/CreatorLv_Image_Lv_01.CreatorLv_Image_Lv_01"
  if authorLevelConfig then
    imagePath = authorLevelConfig.ModuleIcon or authorLevelConfig.PageIcon
  end
  local nameStr = logic_ugc_playlevel:GetTitle(level)
  return {icon = imagePath, title = nameStr}
end
function Common_InformationCustom_Item:GetAnnualBadgeData()
  local badgeData
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  if tonumber(self._uid) == tonumber(DataMgr.roleData.uid) then
    badgeData = logic_season_year_badge:GetCurSeasonYearBadgeInfo()
  else
    badgeData = logic_season_year_badge:CheckOtherSeasonYearBadge(self._uid)
    if badgeData == nil then
      logic_season_year_badge:ReqOtherSeasonYearBadgeInfo(tonumber(self._uid))
      return {icon = "", title = ""}
    end
  end
  local season_year_badge_util = require("client.logic.season_year.util.season_year_badge_util")
  badgeData = season_year_badge_util.GetSeasonYearBadge(self._uid)
  if self.badge_item then
    self.badge_item:SetBadgeInfo(badgeData)
  else
    self.badge_item = self:CreateChildWindow(self.UIRoot.SizeBox_Badge_Root, UIManager.UI_Config.Lobby_Season_Badge_Item_UIBP, badgeData)
  end
  return {
    icon = "",
    title = LocUtil.GetLocalizeResStr(85103)
  }
end
function Common_InformationCustom_Item:SetSelected(isSelect)
  self:SetWidgetVisible(self.UIRoot.Image_Select, isSelect)
  self.end
function Common_InformationCustom_Item:OnItemSelect(_, _, selectData, index, isSelectCancel)
  if isSelectCancel then
    self:SetSelected(false)
    return
  end
  local isSelect = self.index == index
  self:SetSelected(isSelect)
end
function Common_InformationCustom_Item:SetLeftSelect(isLeftSelect)
  self.  self:SetSelected(self.isLeftSelect)
end
function Common_InformationCustom_Item:GetTitleData(profile, alias_id, alias_title)
  if not alias_id or not self.UIRoot.Title_UIBP then
    return {icon = "", title = ""}
  end
  local cfg = CDataTable.GetTableData("AliasCfg", alias_id)
  if cfg then
    local Quality = cfg.AliasQuality
    local bgTexture = ""
    local titleColor
    if Quality == 0 then
      bgTexture = "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao4_png.LOBBY_image_chenghao4_png"
    elseif Quality == 1 then
      bgTexture = "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao3_png.LOBBY_image_chenghao3_png"
    elseif Quality == 2 then
      bgTexture = "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao_png.LOBBY_image_chenghao_png"
    elseif Quality == 3 then
      bgTexture = "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao1_png.LOBBY_image_chenghao1_png"
    elseif Quality == 4 then
      bgTexture = "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao2_png.LOBBY_image_chenghao2_png"
    elseif Quality == 5 then
      bgTexture = "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_zuigaoji_png.LOBBY_image_zuigaoji_png"
    elseif Quality == 6 then
      bgTexture = "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao6_png.LOBBY_image_chenghao6_png"
      titleColor = FSlateColor(FLinearColor(1.0, 0.572549, 0.572549, 1))
    end
    self.UIRoot.Title_UIBP:SetAliasInfo(alias_id or 0, alias_title or cfg.AliasName, profile.alias.nation or "", 256, profile.alias.rank_id or 0)
    self.UIRoot.Title_UIBP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  return {icon = "", title = ""}
end
function Common_InformationCustom_Item:GetAchievementData(summary_id)
  if not summary_id then
    return {icon = "", title = ""}
  end
  local cfg = CDataTable.GetTableData("AchievementCfg", summary_id)
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(9)
    local color = {
      FLinearColor(0.124772, 0.401978, 0.783538, 1),
      FLinearColor(0.158961, 0.47932, 0.234551, 1),
      FLinearColor(0.184475, 0.346704, 0.760525, 1),
      FLinearColor(0.53948, 0.258183, 0.863157, 1),
      FLinearColor(0.508881, 0.135633, 0.467784, 1),
      FLinearColor(0.752942, 0.135633, 0.191202, 1),
      FLinearColor(0.571125, 0.266356, 0.022174, 1)
    }
    self.UIRoot.Image_Achievement:SetColorAndOpacity(color[cfg.ColorType])
  end
  if cfg then
    return {
      icon = cfg.ImgUrl,
      title = cfg.Name
    }
  end
end
function Common_InformationCustom_Item:GetCardScoreData(card_score)
  self.Collect_Level_02:SetLevelByScore(card_score)
  self.UIRoot.Comp_CardCollection:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  local cfg = logic_card_collection_season:GetCardScoreLevelCfgByScore(card_score)
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
  end
  if cfg then
    return {
      icon = "",
      title = cfg.Title
    }
  else
    return {icon = "", title = ""}
  end
end
function Common_InformationCustom_Item:GetHonorData(pround_level)
  local level = pround_level or 1
  local ProundLevelCfg = CDataTable.GetTable("ProundLevelCfg")
  local CurLevelProundCfg = ProundLevelCfg[level]
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(5)
    local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
    local _, iconColor = RoleInfoPopularitySystem.GetProundIconPath(pround_level)
    if iconColor then
      self.UIRoot.Image_ProundLevel:SetColorAndOpacity(FLinearColor.FromSRGBColor(FColor.FromHex(iconColor)))
    end
  end
  return {
    icon = CurLevelProundCfg.LevelIconPath,
    title = LocUtil.LocalizeResFormat(43196, level)
  }
end
function Common_InformationCustom_Item:GetPopularityData(popularity)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local popularityLevel = RoleInfoPopularitySystem.GetPopularityLevelByExp(popularity or 1)
  local color = {
    FLinearColor(0.296138, 0.296138, 0.296138, 1),
    FLinearColor(1.0, 1.0, 1.0, 1),
    FLinearColor(0.033105, 0.496933, 0.226966, 1),
    FLinearColor(0.082283, 0.254152, 0.64448, 1),
    FLinearColor(0.296138, 0.08022, 0.701102, 1),
    FLinearColor(0.879623, 0.099899, 0.679543, 1),
    FLinearColor(0.879623, 0.074214, 0.074214, 1),
    FLinearColor(0.904661, 0.610496, 0.059511, 1)
  }
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(4)
  end
  if popularity then
    if 7 < popularityLevel then
      popularityLevel = 7
    end
    local titleColor = FSlateColor(color[popularityLevel + 1])
    return {
      icon = RoleInfoPopularitySystem.GetPopularityTexture(popularity, true, true),
      title = LocUtil.LocalizeResFormat(6417, popularityLevel),
          }
  else
    return {icon = "", title = ""}
  end
end
function Common_InformationCustom_Item:GetRPLevelData(profile, bp_season, bp_isBuyElite, bp_level)
  if self.UIRoot.UnknowPass_Medal_Item_UIBP then
    local level = profile.upass.level or bp_level
    self.UIRoot.UnknowPass_Medal_Item_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.UnknowPass_Medal_Item_UIBP:SetData(UnknowPassSystem.Season or bp_season, profile.upass_is_buy ~= 0, level)
    if self.UIRoot.WidgetSwitcher_BG_Text then
      self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(8)
      self.UIRoot.TextBlock_RoyalPass:SetText(LocUtil.LocalizeResFormat(43196, level))
    end
  end
  return {icon = "", title = ""}
end
function Common_InformationCustom_Item:GetRelaxRankBigData(rankID)
  local cfg = CDataTable.GetTableData("LeisureSeasonRankLevelCfg", rankID)
  if not cfg then
    return {icon = "", title = ""}
  end
  if not cfg.BigIcon or cfg.BigIcon == "" then
    return {icon = "", title = ""}
  end
  if self.UIRoot.WidgetSwitcher_BG_Text then
    self.UIRoot.WidgetSwitcher_BG_Text:SetActiveWidgetIndex(0)
  end
  return {
    icon = cfg.BigIcon,
    title = cfg.Name
  }
end
function Common_InformationCustom_Item:SetIsLeft(isLeft)
  self.isLeft = isLeft or false
  self:SetWidgetVisible(self.UIRoot.Image_Using, false)
  if self.isLeft then
    if self.UIRoot.VerticalBox_Line then
      self.UIRoot.VerticalBox_Line:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.UIRoot.HorizontalBox_Line then
      self.UIRoot.HorizontalBox_Line:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.UIRoot.SizeBox_Line then
      self.UIRoot.SizeBox_Line:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.UIRoot.Common_DragDrop_Item then
      self.UIRoot.Common_DragDrop_Item:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.UIRoot.CanvasPanel_Rank then
      self.UIRoot.CanvasPanel_Rank:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.UIRoot.WidgetSwitcher_StarName then
      self.UIRoot.WidgetSwitcher_StarName:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  self:RefreshEquip()
end
function Common_InformationCustom_Item:GetIsLeft()
  return self.isLeft or false
end
function Common_InformationCustom_Item:SetIsEquip(isEquipIdx)
  self.data.hadEquip = isEquipIdx or 0
  self:RefreshEquip()
end
function Common_InformationCustom_Item:RefreshEquip()
  if not self.data then
    return
  end
  if self.data.hadEquip and self.data.hadEquip == 1 and not self.isLeft then
    self.UIRoot.Image_Using:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Border_Main:SetContentColorAndOpacity(FLinearColor(1, 1, 1, 0.4))
  else
    self.UIRoot.Image_Using:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Border_Main:SetContentColorAndOpacity(FLinearColor(1, 1, 1, 1))
  end
end
function Common_InformationCustom_Item:HideCantEditorDetail()
  if self.UIRoot.Image_Type then
    self.UIRoot.Image_Type:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.WrapBox_Type then
    self.UIRoot.WrapBox_Type:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.CanvasPanel_Rank then
    self.UIRoot.CanvasPanel_Rank:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.WidgetSwitcher_StarName then
    self.UIRoot.WidgetSwitcher_StarName:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.VerticalBox_Line then
    self.UIRoot.VerticalBox_Line:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.HorizontalBox_Line then
    self.UIRoot.HorizontalBox_Line:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.SizeBox_Line then
    self.UIRoot.SizeBox_Line:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Common_InformationCustom_Item:UpdateModule()
  if self._configData and self._configData.ID == custom_presentation_config.NewModuleID.SeasonYear then
    self:GetAnnualBadgeData()
    self.UIRoot.SizeBox_Badge_Root:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
local class = require("class")
local scroll_box_child_base = require("client.slua_ui_framework.component.scroll_box_child_base")
return class(scroll_box_child_base, nil, Common_InformationCustom_Item)