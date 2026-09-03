local Lobby_RoleInfo_Combat180_UIBP = {}
local EnumApplyType = {
  AddFriend = 1,
  Relation = 2,
  Partner = 3
}
local _Map_Mode2TabIndex = {
  single = {1, 1},
  double = {1, 2},
  team = {1, 3},
  fppsingle = {2, 1},
  fppdouble = {2, 2},
  fppteam = {2, 3}
}
local _Map_View2ModeStr = {"", "fpp"}
local _Map_TeamSize2ModeStr = {
  "single",
  "double",
  "team"
}
function Lobby_RoleInfo_Combat180_UIBP:ctor()
  self.ViewMode = 1
  self.TeamSize = 1
  self.isRader = true
  self.isShowCompare = false
end
function Lobby_RoleInfo_Combat180_UIBP:OnInitialize()
  Lobby_RoleInfo_Combat180_UIBP.__super.OnInitialize(self)
  self.LoopScrollBox_Data = self:InitScrollBox(self.UIRoot.LoopScrollBox_Data)
  self.UIRoot.GridPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local logic_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_combat)
  self.EnumModType = logic_combat:GetEnumModeType()
  self.currModeIndex = self.EnumModType.Rank
end
function Lobby_RoleInfo_Combat180_UIBP:RegistEvents()
  Lobby_RoleInfo_Combat180_UIBP.__super.RegistEvents(self)
  self.LoopScrollBox_Data:SetRefreshItemCallback(self.OnRefreshDataItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ShareCombatInfo, self.OnClickShareCombatInfo, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SeasonLookback, self.OnClickSeasonLookback, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_radar, self.OnClickRadar, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_line, self.OnClickBrokenLine, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Imprint, self.OnButtonAceImprintClick, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_1, self.OnCheckBoxChanged, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_4, self.OnClickReportButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Jubao, self.OnClickJubaoButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Pinbi, self.OnClickPinbiButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_12, self.OnClickViewChangeButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_0, self.OnBtnViewChangeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_4, self.OnBtnViewChangeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_6, self.OnClickSingleMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_8, self.OnClickDoubleMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_10, self.OnClickTeamMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_1, self.OnClickViewButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Lock, self.OnClickLock, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_ACE_IMPRINT_UPDATE, self.OnRefreshAceImprint, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO, self.OnRefreshRoleInfo, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_GET_PEAKGAME_HISTORY_SEASON_BATTLE_INFO_SUCCESS, self.OnGetPeakGameHistorySeasonBattleInfo, self)
  self.ComboBox_Season = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_UIBP_Season)
  self.ComboBox_Season:SetRefreshOptionCallback(self.OnRefreshSeasonItem, self)
  self.ComboBox_Season:SetSelectOptionCallback(self.OnClickSeasonItem, self)
  self.ComboBox_Season:SetOpenStateChangedCallback(self.OnOpenStateChangedCallback, self)
  self.ComboBox_Zone = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_UIBP_Zone)
  self.ComboBox_Zone:SetRefreshOptionCallback(self.OnRefreshZoneItem, self)
  self.ComboBox_Zone:SetSelectOptionCallback(self.OnClickZoneItem, self)
  self.ComboBox_Zone:SetOpenStateChangedCallback(self.OnOpenStateChangedCallback, self)
  self.ComboBox_Mode = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_UIBP_Mode)
  self.ComboBox_Mode:SetRefreshOptionCallback(self.OnRefreshModeItem, self)
  self.ComboBox_Mode:SetSelectOptionCallback(self.OnSelectModeCallback, self)
  self.ComboBox_Mode:SetOpenStateChangedCallback(self.OnOpenStateChangedCallback, self)
end
function Lobby_RoleInfo_Combat180_UIBP:OnPostInitialize()
  Lobby_RoleInfo_Combat180_UIBP.__super.OnPostInitialize(self)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.UpdateRoleinfoSeasonListID(1)
  self:UpdateUI()
  self:InitComboBoxZoneState()
end
function Lobby_RoleInfo_Combat180_UIBP:InitComboBoxZoneState()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local uid = RoleInfoSystem.CurShowPlayerInfoUid
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:InitComboBoxZoneState uid = " .. tostring(uid))
  local profile = LobbySocialSystem.GetProfileByUID(uid)
  if not profile then
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:InitComboBoxZoneState profile is invalid")
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if not profile.segment_info then
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:InitComboBoxZoneState profile.segment_info is invalid")
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:InitComboBoxZoneState is BLUEHOLE")
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local logic_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_combat)
  local zoneIdList = logic_combat:GetZoneList(profile.segment_info)
  if #zoneIdList == 1 then
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:InitComboBoxZoneState zoneIdList length = 1")
    return
  else
    self.ComboBox_Zone:SetData(zoneIdList)
  end
  if self.currModeIndex == self.EnumModType.Match or self.currModeIndex == self.EnumModType.Career then
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:InitComboBoxZoneState widget Collapsed with self.currModeIndex = " .. tostring(self.currModeIndex))
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  else
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.ComboBox_Zone:SelectIndex(1)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshComboBoxZone(bVisible)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshComboBoxZone bVisible = " .. tostring(bVisible))
  self:SetWidgetVisible(self.UIRoot.SizeBox_Zone, false, false)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshComboBoxZone is BLUEHOLE")
    return
  end
  if bVisible then
    local data = self.ComboBox_Zone:GetSetData()
    if data and 0 < #data then
      self.ComboBox_Zone:SelectIndex(1)
      self:SetWidgetVisible(self.UIRoot.SizeBox_Zone, true, false)
    end
  end
end
function Lobby_RoleInfo_Combat180_UIBP:OnRefreshZoneItem(widget, data, index, selectIndex)
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickZoneItem(widget, data, index, selectIndex)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnClickZoneItem index = " .. tostring(index) .. " selectIndex = " .. tostring(selectIndex))
  self:PlayAudio(sound_config.click_v1)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.nChooseZoneID
  log(bWriteLog and "OnClickZoneItem nChooseZoneID = " .. tostring(zoneID))
  local text = data.text
  local zone_id = data.zone_id
  if tonumber(zoneID) == tonumber(zone_id) then
    text = LocUtil.LocalizeResFormat(44891, text)
  end
  widget.TextBlock_ItemName:SetText(text)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnClickZoneItem zone_id = " .. tostring(zone_id))
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local modeId = RoleInfoMainSystem.GetCombatMode()
  if modeId == self.EnumModType.Rank then
    RoleInfoMainSystem.RequestBattleInfo(tonumber(zone_id))
  elseif modeId == self.EnumModType.PeakGame then
    local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
    local seasonList = logic_peakgame_combat:GetPeakGameBattleSeasonList()
    local season_id = seasonList[RoleInfoMainSystem.GetRoleinfoSeasonListID()].season_id
    local peakgame_info = logic_peakgame_combat:GetPeakGameInfo(season_id, zone_id)
    RoleInfoMainSystem.UpdateShowRoleinfoOfZoneID(zone_id)
    if peakgame_info == nil then
      logic_peakgame_combat:ReqPeakGameInfo(season_id, zone_id)
    else
      self:RefershCombatByModeType()
    end
  end
end
function Lobby_RoleInfo_Combat180_UIBP:UpdateUI()
  self:RequestData()
  self:InitComponentItemStyle()
  self:InitTextUI()
  self:InitTaps()
  self:RefershComboboxs()
  self:InitWidgetState()
  self:UpdateRoleInfo()
  self:InitSeasonLookbackGuide()
  self:RefreshRestrictButton()
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshRestrictButton()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRestrict = QRcodeRestrictManager:IsRestrictSocial()
  self:SetWidgetVisible(self.UIRoot.Button_Lock, isRestrict, true)
end
function Lobby_RoleInfo_Combat180_UIBP:RequestData()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.RequestBattleInfo()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({
    tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
  }, function(list)
    self:OnGetSelfRoleInfoCallBack(list)
  end, Enum_PROFILE_REPORT_CFG.ROLE_INFO, 100, true)
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:ReqPeakGameAllRatingInfo(false)
end
function Lobby_RoleInfo_Combat180_UIBP:OnGetSelfRoleInfoCallBack(list)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP.OnGetSelfRoleInfoCallBack")
  if list and next(list) then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    if tonumber(RoleInfoSystem.CurShowPlayerInfoUid) ~= tonumber(list[1].uid) then
      return
    end
    local root = self.UIRoot
    if not root then
      return
    end
    local historyRanks = list[1].history_max_segment_level or {101}
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local historyHigestRank, historySeasonId = RoleInfoMainSystem.GetHistotyMaxSegmentAndSeasonId(historyRanks, list[1].history_max_segment_season_id)
    root.Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteralBySeason(historyHigestRank or 101, nil, historySeasonId)
    root.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteralBySeason(historyHigestRank or 101, nil, historySeasonId)
    self:CheckShowSeasonLookbackButton()
  end
end
function Lobby_RoleInfo_Combat180_UIBP:InitComponentItemStyle()
  local seasonViewChangeItem = self.UIRoot.RoleInfo_Season_ViewChange_Item
  self:SetTexture(seasonViewChangeItem.Image_63, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_BG_Frame_1_Scene_png.Common_BG_Frame_1_Scene_png")
  self:SetTexture(seasonViewChangeItem.Image_27, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene02_png.Common_Btn_Lv2_Scene02_png")
  self:SetTexture(seasonViewChangeItem.Image_30, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene01_png.Common_Btn_Lv2_Scene01_png")
  self:SetTexture(seasonViewChangeItem.Image_32, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene02_png.Common_Btn_Lv2_Scene02_png")
  self:SetTexture(seasonViewChangeItem.Image_34, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene01_png.Common_Btn_Lv2_Scene01_png")
  self:SetTexture(seasonViewChangeItem.Image_0, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_BG_Frame_8_Scene_png.Common_BG_Frame_8_Scene_png")
  self:SetTexture(seasonViewChangeItem.Image_70, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene02_png.Common_Btn_Lv2_Scene02_png")
  self:SetTexture(seasonViewChangeItem.Image_43, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene02_png.Common_Btn_Lv2_Scene02_png")
  self:SetTexture(seasonViewChangeItem.Image_36, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene02_png.Common_Btn_Lv2_Scene02_png")
  self:SetTexture(seasonViewChangeItem.Image_38, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene01_png.Common_Btn_Lv2_Scene01_png")
  self:SetTexture(seasonViewChangeItem.Image_45, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene01_png.Common_Btn_Lv2_Scene01_png")
  self:SetTexture(seasonViewChangeItem.Image_72, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Scene01_png.Common_Btn_Lv2_Scene01_png")
  seasonViewChangeItem.Image_35.Brush.TintColor = FSlateColor(FLinearColor(1, 1, 1, 1))
  seasonViewChangeItem.Image_37.Brush.TintColor = FSlateColor(FLinearColor(0, 0, 0, 1))
  seasonViewChangeItem.Image_44.Brush.TintColor = FSlateColor(FLinearColor(1, 1, 1, 1))
  seasonViewChangeItem.Image_46.Brush.TintColor = FSlateColor(FLinearColor(0, 0, 0, 1))
  seasonViewChangeItem.Image_71.Brush.TintColor = FSlateColor(FLinearColor(1, 1, 1, 1))
  seasonViewChangeItem.Image_73.Brush.TintColor = FSlateColor(FLinearColor(0, 0, 0, 1))
  seasonViewChangeItem.Image_61.Brush.TintColor = FSlateColor(FLinearColor(1, 1, 1, 0.7))
  seasonViewChangeItem.Image_62:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.7))
  seasonViewChangeItem.Button_12:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  seasonViewChangeItem.TextBlock_20:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.7)))
  seasonViewChangeItem.TextBlock_21:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.7)))
  seasonViewChangeItem.TextBlock_0:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.4)))
  seasonViewChangeItem.TextBlock_1:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.7)))
  seasonViewChangeItem.TextBlock_2:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 1)))
  seasonViewChangeItem.TextBlock_3:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.7)))
  seasonViewChangeItem.TextBlock_4:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 1)))
  seasonViewChangeItem.TextBlock_5:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.4)))
end
function Lobby_RoleInfo_Combat180_UIBP:InitTextUI()
  self.UIRoot.TextBlock_CombatCountLabel:SetText(LocUtil.GetLocalizeResStr(616))
  self.UIRoot.TextBlock_CombatWinsCountLabel:SetText(LocUtil.GetLocalizeResStr(613))
  self.UIRoot.TopTenText:SetText(LocUtil.GetLocalizeResStr(614))
  self.UIRoot.TextBlock_CombatBeatCountLabel:SetText(LocUtil.GetLocalizeResStr(617))
  self.UIRoot.TextBlock_CombatBeatRatioLabel:SetText(LocUtil.GetLocalizeResStr(615))
  self.UIRoot.CompareText:SetText(LocUtil.GetLocalizeResStr(633))
  self.UIRoot.TextBlock_RadarName1:SetText(LocUtil.GetLocalizeResStr(634))
  self.UIRoot.TextBlock_RadarName5:SetText(LocUtil.GetLocalizeResStr(618))
  self.UIRoot.TextBlock_RadarName2:SetText(LocUtil.GetLocalizeResStr(635))
  self.UIRoot.TextBlock_RadarName3:SetText(LocUtil.GetLocalizeResStr(637))
  self.UIRoot.HistoryMaxText:SetText(LocUtil.GetLocalizeResStr(42633))
  self.UIRoot.ArceText:SetText(LocUtil.GetLocalizeResStr(611))
  self.UIRoot.ReportText:SetText(LocUtil.GetLocalizeResStr(638))
end
function Lobby_RoleInfo_Combat180_UIBP:InitTaps()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  local maxSegment, maxMode = 101, "single"
  if not RoleInfoMainSystem.IsShowSelf() then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    local profile = LobbySocialSystem.GetProfileByUID(RoleInfoSystem.CurShowPlayerInfoUid)
    if not profile then
      self:SetNewModeItemList(maxSegment)
      self:SetNewTap(maxMode)
      return
    end
    maxSegment, maxMode = DataMgr.GetCurMaxSegmentByZoneId(zoneId, profile.segment_info)
    self.UIRoot.CanvasPanel2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SetNewModeItemList(maxSegment)
    self:SetNewTap(maxMode)
    return
  end
  maxSegment, maxMode = DataMgr.GetCurMaxSegmentByZoneId(zoneId, DataMgr.roleData.allzoneSegment)
  self:SetNewModeItemList(maxSegment)
  if maxSegment < 102 then
    self:SetNewTap("team")
  else
    self.UIRoot.CanvasPanel2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SetNewTap(maxMode)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:SetNewTap(_selectMode)
  local index = _Map_Mode2TabIndex[_selectMode]
  self.ViewMode = index[1]
  self.TeamSize = index[2]
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.SetCombatShootTypeID(self.ViewMode)
  RoleInfoMainSystem.UpdateCombatModelType(self.TeamSize)
  if self.UIRoot.RoleInfo_Season_ViewChange_Item then
    local localizeIndex = self.ViewMode == 1 and "100054" or "100053"
    self.UIRoot.RoleInfo_Season_ViewChange_Item.TextBlock_20:SetText(LocUtil.GetLocalizeResStr(localizeIndex))
    local SizeText = ""
    if self.TeamSize == 1 then
      SizeText = LocUtil.GetLocalizeResStr(100030)
    elseif self.TeamSize == 2 then
      SizeText = LocUtil.GetLocalizeResStr(100031)
    else
      SizeText = LocUtil.GetLocalizeResStr(100032)
    end
    self.UIRoot.RoleInfo_Season_ViewChange_Item.TextBlock_21:SetText(SizeText)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.WidgetSwitcher_0:SetActiveWidgetIndex(self.ViewMode == 2 and 1 or 0)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.WidgetSwitcher_1:SetActiveWidgetIndex(self.ViewMode == 1 and 1 or 0)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.WidgetSwitcher_2:SetActiveWidgetIndex(self.TeamSize == 1 and 1 or 0)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.WidgetSwitcher_4:SetActiveWidgetIndex(self.TeamSize == 2 and 1 or 0)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.WidgetSwitcher_5:SetActiveWidgetIndex(self.TeamSize == 3 and 1 or 0)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:RefershComboboxs()
  self:SetNewSeasonItemList()
end
function Lobby_RoleInfo_Combat180_UIBP:SetNewSeasonItemList()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local modeId = RoleInfoMainSystem.GetCombatMode()
  local seasonNames = {}
  local cur_index = 1
  if modeId == self.EnumModType.Rank then
    local logic_rank_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rank_combat)
    seasonNames = logic_rank_combat:GetRankBattleSeasonList()
    if not seasonNames or not next(seasonNames) then
      log(bWriteLog and "  : not seasonNames")
      return
    end
    cur_index = RoleInfoMainSystem.GetRoleinfoSeasonListID()
  elseif modeId == self.EnumModType.Match then
    local logic_match_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_match_combat)
    seasonNames = logic_match_combat:GetRankBattleSeasonList()
    if not seasonNames or not next(seasonNames) then
      log(bWriteLog and "  : not seasonNames")
      return
    end
    if RoleInfoMainSystem.GetRoleinfoSeasonListID() > #seasonNames then
      RoleInfoMainSystem.UpdateRoleinfoSeasonListID(1)
    end
    cur_index = RoleInfoMainSystem.GetRoleinfoSeasonListID()
  elseif modeId == self.EnumModType.Career then
    RoleInfoMainSystem.UpdateRoleinfoSeasonListID(1)
    local allSeasonText = LocUtil.GetLocalizeResStr(650)
    seasonNames = {
      {
        text = allSeasonText,
        season_id = DataMgr.season_id
      }
    }
    cur_index = 1
  end
  if seasonNames and next(seasonNames) then
    self.ComboBox_Season:SetData(seasonNames)
    if seasonNames[cur_index] and seasonNames[cur_index].text then
      self.ComboBox_Season.TextBlock_ItemName:SetText(seasonNames[cur_index].text)
    end
  end
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickSeasonItem(widget, data, index, selectIndex)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnClickSeasonItem index = " .. tostring(index) .. " selectIndex = " .. tostring(selectIndex))
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local modeId = RoleInfoMainSystem.GetCombatMode()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnClickSeasonItem modeId = " .. tostring(modeId))
  if modeId == self.EnumModType.Career then
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnClickSeasonItem career return")
    return
  end
  self:OnSelectSeasonItem(index)
end
function Lobby_RoleInfo_Combat180_UIBP:OnRefreshSeasonItem(widget, data, index, selectIndex)
  if not data then
    return
  end
  widget.TextBlock_ItemName:SetText(data.text)
  local UIUtil = require("client.common.ui_util")
  if self.ComboBox_Season.TextBlock_ItemName:GetText() == data.text then
    widget.Image_Select:SetWidgetVisibility(UIUtil.BoolToVisible(true))
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
  else
    widget.Image_Select:SetWidgetVisibility(UIUtil.BoolToVisible(false))
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.7)))
  end
end
function Lobby_RoleInfo_Combat180_UIBP:SetNewModeItemList(maxSegment)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:SetNewModeItemList maxSegment = " .. tostring(maxSegment))
  local logic_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_combat)
  local modeList = logic_combat:GetModeListCfg()
  local selectIndex
  if maxSegment and maxSegment < 102 then
    selectIndex = self.EnumModType.Match
  else
    selectIndex = self.EnumModType.Rank
  end
  self.ComboBox_Mode:SetData(modeList, selectIndex)
end
function Lobby_RoleInfo_Combat180_UIBP:OnRefreshModeItem(widget, data, index, selectIndex)
  widget.TextBlock_ItemName:SetText(data.text)
end
function Lobby_RoleInfo_Combat180_UIBP:OnSelectModeCallback(widget, data, index, selectIndex)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnSelectModeCallback index = " .. tostring(index) .. " selectIndex = " .. tostring(selectIndex))
  self:OnSelectModeItem(index)
end
function Lobby_RoleInfo_Combat180_UIBP:OnOpenStateChangedCallback(bIsOpen)
  if bIsOpen then
    self.UIRoot.RoleInfo_Season_ViewChange_Item.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.WidgetSwitcher_7:SetActiveWidgetIndex(0)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:InitWidgetState()
  self.UIRoot.CheckBox_1:SetCheckedState(0)
  self.UIRoot.RanderCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.SegmentCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.UIRoot.RoleInfo_Season_ViewChange_Item then
    self.UIRoot.RoleInfo_Season_ViewChange_Item.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.WidgetSwitcher_7:SetActiveWidgetIndex(0)
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if RoleInfoMainSystem.IsShowSelf() then
    self.UIRoot.HorizontalBox_9:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.WidgetSwitcher_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_82:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.HorizontalBox_9:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_82:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  self:ShowButtonByIsIOSCheck()
  self:CheckShowSeasonLookbackButton()
end
function Lobby_RoleInfo_Combat180_UIBP:ShowButtonByIsIOSCheck()
  if GlobalData.IsIOSCheck() then
    self.UIRoot.SizeBox_BtnShare:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.SizeBox_BtnShare:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  if LobbySystem.CheckOpen(20027) then
    self.UIRoot.SizeBox_Season:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.SizeBox_Season:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:CheckShowSeasonLookbackButton()
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  if not logic_season_lookback:GetEntranceSwitch() then
    self:SetWidgetVisible(self.UIRoot.SizeBox_SeasonLookback, false)
    return
  end
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:CheckShowSeasonLookbackButton self.currModeIndex = " .. tostring(self.currModeIndex))
  if self.currModeIndex ~= self.EnumModType.Rank then
    self:SetWidgetVisible(self.UIRoot.SizeBox_SeasonLookback, false)
    return
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if RoleInfoMainSystem.IsShowSelf() then
    self:SetWidgetVisible(self.UIRoot.SizeBox_SeasonLookback, true)
    return
  end
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local uid = RoleInfoSystem.CurShowPlayerInfoUid
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:CheckShowSeasonLookbackButton profile is invalid")
    self:SetWidgetVisible(self.UIRoot.SizeBox_SeasonLookback, false)
    return
  end
  if profile.lookback and profile.lookback.privacy then
    self:SetWidgetVisible(self.UIRoot.SizeBox_SeasonLookback, true)
  else
    self:SetWidgetVisible(self.UIRoot.SizeBox_SeasonLookback, false)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:InitSeasonLookbackGuide()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local uid = RoleInfoSystem.CurShowPlayerInfoUid
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  if logic_season_lookback:CheckShowGuideInCombat(uid) then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_LookbackGuide, true)
    self.UIRoot.TextBlock_LookbackGuide:SetText(LocUtil.GetLocalizeResStr(512154))
    logic_season_lookback:SaveCombatGuideFlag()
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_LookbackGuide, false)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:UpdateRoleInfo()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:UpdateRoleInfo")
  self:RefershCombatByModeType()
  self:SetNewSeasonItemList()
end
function Lobby_RoleInfo_Combat180_UIBP:RefershCombatByModeType()
  self:RefershKDInfo()
  self:SetCombatInfo()
end
function Lobby_RoleInfo_Combat180_UIBP:RefershKDInfo()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefershKDInfo")
  if self.currModeIndex == self.EnumModType.PeakGame then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local zone_id = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
    local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
    local seasonList = logic_peakgame_combat:GetPeakGameBattleSeasonList()
    local season_id = seasonList[RoleInfoMainSystem.GetRoleinfoSeasonListID()].season_id
    local peakgame_info = logic_peakgame_combat:GetPeakGameInfo(season_id, zone_id)
    if peakgame_info then
      self.UIRoot.TextBlock_KillRatio2:SetText(peakgame_info.kd_v2)
    end
    return
  end
  local combatTotalInfo
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if RoleInfoMainSystem.GetCombatShootTypeID() == ShootType.TPPType then
    if self.currModeIndex == self.EnumModType.Rank then
      combatTotalInfo = RoleInfoSystem.CombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Match then
      combatTotalInfo = RoleInfoSystem.MatchCombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Career then
      combatTotalInfo = RoleInfoSystem.CareerCombatTotalInfoList[self.TeamSize]
    end
  elseif RoleInfoMainSystem.GetCombatShootTypeID() == ShootType.FPPType then
    if self.currModeIndex == self.EnumModType.Rank then
      combatTotalInfo = RoleInfoSystem.FPPCombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Match then
      combatTotalInfo = RoleInfoSystem.FPPMCombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Career then
      combatTotalInfo = RoleInfoSystem.FPPCCombatTotalInfoList[self.TeamSize]
    end
  end
  if not combatTotalInfo or not next(combatTotalInfo) then
    return
  end
  local role_kd_v2 = string.format("%.2f", tonumber(combatTotalInfo.role_kd_v2) or 0)
  local role_kd = string.format("%.2f", tonumber(combatTotalInfo.role_kd) or 0)
  if combatTotalInfo.role_kd_v2 then
    self.UIRoot.TextBlock_KillRatio2:SetText(role_kd_v2)
  else
    self.UIRoot.TextBlock_KillRatio2:SetText(role_kd)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:SetCombatInfo()
  self:RefershCombatTotalInfo()
  self:RefreshgameDataList()
  self:UpdateChartImage()
end
function Lobby_RoleInfo_Combat180_UIBP:RefershCombatTotalInfo()
  if self.currModeIndex == self.EnumModType.PeakGame then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local zone_id = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
    local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
    local seasonList = logic_peakgame_combat:GetPeakGameBattleSeasonList()
    local season_id = seasonList[RoleInfoMainSystem.GetRoleinfoSeasonListID()].season_id
    local peakgame_info = logic_peakgame_combat:GetPeakGameInfo(season_id, zone_id)
    if peakgame_info then
      self.UIRoot.TextBlock_CombatCount2:SetText(peakgame_info.game_num)
      self.UIRoot.TextBlock_Wins2:SetText(peakgame_info.win_num)
      self.UIRoot.TextBlock_TopTenCount2:SetText(peakgame_info.top10_count)
      self.UIRoot.TextBlock_KillCount2:SetText(peakgame_info.kill_num)
    end
    return
  end
  local combatTotalInfo
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if RoleInfoMainSystem.GetCombatShootTypeID() == ShootType.TPPType then
    if self.currModeIndex == self.EnumModType.Rank then
      combatTotalInfo = RoleInfoSystem.CombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Match then
      combatTotalInfo = RoleInfoSystem.MatchCombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Career then
      combatTotalInfo = RoleInfoSystem.CareerCombatTotalInfoList[self.TeamSize]
    end
  elseif RoleInfoMainSystem.GetCombatShootTypeID() == ShootType.FPPType then
    if self.currModeIndex == self.EnumModType.Rank then
      combatTotalInfo = RoleInfoSystem.FPPCombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Match then
      combatTotalInfo = RoleInfoSystem.FPPMCombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Career then
      combatTotalInfo = RoleInfoSystem.FPPCCombatTotalInfoList[self.TeamSize]
    end
  end
  if combatTotalInfo and next(combatTotalInfo) then
    self.UIRoot.TextBlock_KillCount2:SetText(combatTotalInfo.role_killnum or 0)
    self.UIRoot.TextBlock_TopTenCount2:SetText(combatTotalInfo.role_toptennum or 0)
    self.UIRoot.TextBlock_CombatCount2:SetText(combatTotalInfo.role_allmatchnum or 0)
    self.UIRoot.TextBlock_Wins2:SetText(combatTotalInfo.role_winnum or 0)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshgameDataList()
  if self.currModeIndex == self.EnumModType.PeakGame then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local zone_id = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
    local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
    local seasonList = logic_peakgame_combat:GetPeakGameBattleSeasonList()
    local season_id = seasonList[RoleInfoMainSystem.GetRoleinfoSeasonListID()].season_id
    local peakgame_info = logic_peakgame_combat:GetPeakGameInfo(season_id, zone_id)
    local item_data = logic_peakgame_combat:GetDetailDataList(peakgame_info) or {}
    self.LoopScrollBox_Data:SetData(item_data)
    return
  end
  local combatTotalInfo
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if RoleInfoMainSystem.GetCombatShootTypeID() == ShootType.TPPType then
    if self.currModeIndex == self.EnumModType.Rank then
      combatTotalInfo = RoleInfoSystem.CombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Match then
      combatTotalInfo = RoleInfoSystem.MatchCombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Career then
      combatTotalInfo = RoleInfoSystem.CareerCombatTotalInfoList[self.TeamSize]
    end
  elseif RoleInfoMainSystem.GetCombatShootTypeID() == ShootType.FPPType then
    if self.currModeIndex == self.EnumModType.Rank then
      combatTotalInfo = RoleInfoSystem.FPPCombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Match then
      combatTotalInfo = RoleInfoSystem.FPPMCombatTotalInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Career then
      combatTotalInfo = RoleInfoSystem.FPPCCombatTotalInfoList[self.TeamSize]
    end
  end
  local item_data = {}
  if combatTotalInfo and next(combatTotalInfo) then
    local item_data1 = {}
    item_data1.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_01.Players_icon_gerenshuju_sence_01"
    item_data1.text1 = LocUtil.GetLocalizeResStr(618)
    item_data1.text2 = LocUtil.GetLocalizeResStr(619)
    item_data1.text3 = LocUtil.GetLocalizeResStr(620)
    item_data1.data1 = LocUtil.LocalizeResFormat(69409, combatTotalInfo.role_winrate)
    item_data1.data2 = LocUtil.LocalizeResFormat(69409, combatTotalInfo.role_toptenrate)
    item_data1.data3 = LocUtil.LocalizeResFormat(69409, combatTotalInfo.role_hitrate)
    table.insert(item_data, item_data1)
    local item_data2 = {}
    item_data2.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_02.Players_icon_gerenshuju_sence_02"
    item_data2.text1 = LocUtil.GetLocalizeResStr(621)
    item_data2.text2 = LocUtil.GetLocalizeResStr(622)
    item_data2.text3 = LocUtil.GetLocalizeResStr(623)
    item_data2.data1 = LocUtil.LocalizeResFormat(69409, combatTotalInfo.role_critrate)
    item_data2.data2 = combatTotalInfo.role_critcount
    item_data2.data3 = combatTotalInfo.role_avedamage
    table.insert(item_data, item_data2)
    local item_data3 = {}
    item_data3.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_04.Players_icon_gerenshuju_sence_04"
    item_data3.text1 = LocUtil.GetLocalizeResStr(624)
    item_data3.text2 = LocUtil.GetLocalizeResStr(625)
    item_data3.text3 = LocUtil.GetLocalizeResStr(626)
    item_data3.data1 = combatTotalInfo.role_totalHurt
    item_data3.data2 = combatTotalInfo.role_maxkill
    item_data3.data3 = combatTotalInfo.role_maxdamage
    table.insert(item_data, item_data3)
    if self.TeamSize > 1 then
      local item_data6 = {}
      item_data6.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_06.Players_icon_gerenshuju_sence_06"
      item_data6.text1 = LocUtil.GetLocalizeResStr(43699)
      item_data6.text2 = LocUtil.GetLocalizeResStr(43700)
      item_data6.text3 = LocUtil.GetLocalizeResStr(632)
      item_data6.data1 = combatTotalInfo.role_assist
      item_data6.data2 = (tonumber(combatTotalInfo.role_allmatchnum) == 0 or tonumber(combatTotalInfo.role_allmatchnum) == nil) and string.format("%.1f", 0) or string.format("%.1f", tonumber(combatTotalInfo.role_assist) and tonumber(combatTotalInfo.role_assist) / tonumber(combatTotalInfo.role_allmatchnum) or 0 / tonumber(combatTotalInfo.role_allmatchnum))
      item_data6.data3 = string.format("%s", combatTotalInfo.role_maxdistance) .. tostring("KM")
      table.insert(item_data, item_data6)
    end
    local item_data4 = {}
    item_data4.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_05.Players_icon_gerenshuju_sence_05"
    item_data4.text1 = LocUtil.GetLocalizeResStr(627)
    item_data4.text2 = LocUtil.GetLocalizeResStr(628)
    item_data4.text3 = LocUtil.GetLocalizeResStr(629)
    item_data4.data1 = combatTotalInfo.role_aveheal
    item_data4.data2 = LocUtil.LocalizeResFormat(6007, combatTotalInfo.role_avesurvivetime)
    item_data4.data3 = string.format("%s", combatTotalInfo.role_avedistance) .. tostring("KM")
    table.insert(item_data, item_data4)
    local item_data5 = {}
    item_data5.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_03.Players_icon_gerenshuju_sence_03"
    item_data5.text1 = LocUtil.GetLocalizeResStr(630)
    item_data5.text2 = LocUtil.GetLocalizeResStr(631)
    item_data5.text3 = self.TeamSize > 1 and "" or LocUtil.GetLocalizeResStr(632)
    item_data5.data1 = combatTotalInfo.role_aidcount
    item_data5.data2 = LocUtil.LocalizeResFormat(6007, combatTotalInfo.role_maxsurvivetime)
    item_data5.data3 = self.TeamSize > 1 and "" or string.format("%s", combatTotalInfo.role_maxdistance) .. tostring("KM")
    table.insert(item_data, item_data5)
  end
  self.LoopScrollBox_Data:SetData(item_data)
end
function Lobby_RoleInfo_Combat180_UIBP:OnRefreshDataItem(widget, index)
  local resDataTab = self.LoopScrollBox_Data:GetItemData(index)
  if resDataTab and next(resDataTab) then
    self:SetTexture(widget.Image_Icon, resDataTab.icon_path)
    widget.TextBlock_WinrateLabel:SetText(resDataTab.text1)
    widget.TextBlock_ToptenrateLabel:SetText(resDataTab.text2)
    widget.TextBlock_HealLabel:SetText(resDataTab.text3)
    widget.TextBlock_winrate:SetText(resDataTab.data1)
    widget.TextBlock_toptenrate:SetText(resDataTab.data2)
    widget.TextBlock_Heal:SetText(resDataTab.data3)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:UpdateChartImage()
  if self.currModeIndex == self.EnumModType.Career then
    return
  end
  self:UpdateChartType()
  if self.isRader then
    if self.currModeIndex == self.EnumModType.PeakGame then
      local peakgame_combat_ui = require("client.logic.combat.ui.peakgame_combat_ui")
      peakgame_combat_ui:RefreshRaderInfo(self)
    else
      self:RefershCombatRadarDescInfo()
      self:RefershRadarChartImage()
    end
  elseif self.currModeIndex == self.EnumModType.Rank then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    RoleInfoSystem.CalculateLineData()
    local linetab = RoleInfoSystem.GetLineTable()
    self:UpdateBrokenLineDesc(linetab)
    self:UpdateBrokenLine(linetab)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:UpdateChartType()
  if self.isRader then
    self.UIRoot.WidgetSwitcher:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_634:SetActiveWidgetIndex(0)
    self.UIRoot.CanvasPanel_17:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SetWidgetVisible(self.UIRoot.Image_Score, true, false)
    self:SetWidgetVisible(self.UIRoot.TextBlock_GradeScore, true, false)
  else
    self.UIRoot.WidgetSwitcher:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_634:SetActiveWidgetIndex(1)
    self.UIRoot.CanvasPanel_17:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:SetWidgetVisible(self.UIRoot.Image_Score, false, false)
    self:SetWidgetVisible(self.UIRoot.TextBlock_GradeScore, false, false)
    return
  end
end
local SetClolorAndText = function(widget, num)
  num = tonumber(string.format("%.1f", num))
  log(bWriteLog and "[jiantaosu] SetClolorAndText num 's value is " .. tostring(num))
  if num < 0 then
    widget:SetColorAndOpacity(FSlateColor(FLinearColor(1, 0, 0, 1)))
    local text = tostring(num)
    widget:SetText(text)
  elseif 0 < num then
    widget:SetColorAndOpacity(FSlateColor(FLinearColor(0, 1, 0, 1)))
    local text = "+" .. tostring(num)
    widget:SetText(text)
  else
    num = math.abs(num)
    widget:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
    local text = "+" .. tostring(num)
    widget:SetText(text)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:RefershCombatRadarDescInfo()
  local root = self.UIRoot
  local combatModelType = self.TeamSize
  local combatData = self:GetCombatGradeItemData()
  if combatData and next(combatData) then
    root.TextBlock_RadarSurvive:SetText(combatData.survive_score or 0)
    root.TextBlock_RadarTop1:SetText(combatData.top1_score or 0)
    root.TextBlock_RadarRating:SetText(combatData.rating_score or 0)
    root.TextBlock_RadarAssist:SetText(combatData.assist_score or 0)
    root.TextBlock_RadarFight:SetText(combatData.fight_score or 0)
    local score = tonumber(combatData.sum_score or 0) or 0
    local strScore = LocUtil.LocalizeResFormat(7490, math.floor(score * 10) / 10.0)
    root.TextBlock_GradeScore:SetText(strScore)
    log(bWriteLog and "[bgp] combatData.grade" .. tostring(combatData.grade))
    local RoleInfoCombatSystem = require("client.slua.logic.lobby.left.logic_roleinfo_combat")
    local imgPath = RoleInfoCombatSystem.GetGradeImgPathByIndex(combatData.grade or 0)
    self:SetTexture(root.Image_Score, imgPath)
  end
  local strHelp = ""
  if combatModelType and combatModelType == 1 then
    strHelp = LocUtil.GetLocalizeResStr(105012)
  else
    strHelp = LocUtil.GetLocalizeResStr(105013)
  end
  root.TextBlock_RadarName4:SetText(strHelp)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if self.currModeIndex == self.EnumModType.Rank then
    local season_id = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
    if season_id and season_id <= 22 then
      self.UIRoot.TextBlock_RadarName2:SetText(LocUtil.GetLocalizeResStr(635))
    else
      self.UIRoot.TextBlock_RadarName2:SetText(LocUtil.GetLocalizeResStr(636))
    end
  elseif self.currModeIndex == self.EnumModType.Match then
    self.UIRoot.TextBlock_RadarName2:SetText(LocUtil.GetLocalizeResStr(636))
  end
  if not (not RoleInfoMainSystem.IsShowSelf() and combatData) or not self.isShowCompare then
    root.TextBlock_Dsurvive:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    root.TextBlock_Dtop1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    root.TextBlock_Drating:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    root.TextBlock_Dassit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    root.TextBlock_Dfight:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  else
    root.TextBlock_Dsurvive:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    root.TextBlock_Dtop1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    root.TextBlock_Drating:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    root.TextBlock_Dassit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    root.TextBlock_Dfight:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local MyRadarData = RoleInfoSystem.GetMyRadarData()
  if MyRadarData and next(MyRadarData) then
    local DSurviveValue = tonumber(MyRadarData.survive_score or 0) - tonumber(combatData.survive_score ~= "" and combatData.survive_score or 0)
    log(bWriteLog and "[jiantaosu] DSurviveValue 's value is " .. tostring(DSurviveValue))
    local DTopValue = tonumber(MyRadarData.top1_score or 0) - tonumber(combatData.top1_score ~= "" and combatData.top1_score or 0)
    log(bWriteLog and "[jiantaosu] DTopValue 's value is " .. tostring(DTopValue))
    local DRatingValue = tonumber(MyRadarData.rating_score or 0) - tonumber(combatData.rating_score ~= "" and combatData.rating_score or 0)
    log(bWriteLog and "[jiantaosu] DRatingValue 's value is " .. tostring(DRatingValue))
    local DAssitValue = tonumber(MyRadarData.assist_score or 0) - tonumber(combatData.assist_score ~= "" and combatData.assist_score or 0)
    log(bWriteLog and "[jiantaosu] DAssitValue 's value is " .. tostring(DAssitValue))
    local DFightValue = tonumber(MyRadarData.fight_score or 0) - tonumber(combatData.fight_score ~= "" and combatData.fight_score or 0)
    log(bWriteLog and "[jiantaosu] DFightValue 's value is " .. tostring(DFightValue))
    SetClolorAndText(root.TextBlock_Dsurvive, DSurviveValue)
    SetClolorAndText(root.TextBlock_Dtop1, DTopValue)
    SetClolorAndText(root.TextBlock_Drating, DRatingValue)
    SetClolorAndText(root.TextBlock_Dassit, DAssitValue)
    SetClolorAndText(root.TextBlock_Dfight, DFightValue)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:RefershRadarChartImage()
  local root = self.UIRoot
  local combatData = self:GetCombatGradeItemData() or {}
  if combatData and next(combatData) then
    self:ShowRadarChart(root.RadarChart, combatData)
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if RoleInfoMainSystem.IsShowSelf() or not self.isShowCompare then
    root.MyRadarChart:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  root.MyRadarChart:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local MyRadarData = RoleInfoSystem.GetMyRadarData() or {}
  if MyRadarData and next(MyRadarData) then
    self:ShowRadarChart(root.MyRadarChart, MyRadarData)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:ShowRadarChart(RadarChart, radarInfo)
  local root = self.UIRoot
  RadarChart:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  RadarChart.CenterPointImg = root.Image_MidPoint
  RadarChart.VertexFarPointImg:Clear()
  for i = 1, 5 do
    RadarChart.VertexFarPointImg:Add(root["Image_Point" .. i])
  end
  for k, v in pairs(radarInfo) do
    if not v or v == "" then
      radarInfo[k] = 0
    end
  end
  RadarChart.VertexScale:Clear()
  RadarChart.VertexScale:Add(tonumber(radarInfo.top1_score) / 100)
  RadarChart.VertexScale:Add(tonumber(radarInfo.rating_score) / 100)
  RadarChart.VertexScale:Add(tonumber(radarInfo.assist_score) / 100)
  RadarChart.VertexScale:Add(tonumber(radarInfo.survive_score) / 100)
  RadarChart.VertexScale:Add(tonumber(radarInfo.fight_score) / 100)
  self.timer = self:AddTimerOnce(0, function()
    RadarChart:FreshChartDataToContent()
  end)
end
function Lobby_RoleInfo_Combat180_UIBP:GetCombatGradeItemData()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local combatTotalInfo
  if RoleInfoMainSystem.GetCombatShootTypeID() == ShootType.TPPType then
    if self.currModeIndex == self.EnumModType.Rank then
      combatTotalInfo = RoleInfoSystem.CombatGradeInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Match then
      combatTotalInfo = RoleInfoSystem.MatchCombatGradeInfoList[self.TeamSize]
    end
  elseif RoleInfoMainSystem.GetCombatShootTypeID() == ShootType.FPPType then
    if self.currModeIndex == self.EnumModType.Rank then
      combatTotalInfo = RoleInfoSystem.FPPCombatGradeInfoList[self.TeamSize]
    elseif self.currModeIndex == self.EnumModType.Match then
      combatTotalInfo = RoleInfoSystem.FPPMCombatGradeInfoList[self.TeamSize]
    end
  end
  return combatTotalInfo
end
function Lobby_RoleInfo_Combat180_UIBP:UpdateBrokenLineDesc(linetab)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local seasonId = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
  local minData = FuncUtil.GetRankTableData(linetab[1].level, seasonId) or {}
  local maxData = FuncUtil.GetRankTableData(linetab[#linetab].level, seasonId) or {}
  local minLevelName = minData.Name or ""
  local maxLevelName = maxData.Name or ""
  local Text = LocUtil.LocalizeResFormat(25141, minLevelName, maxLevelName)
  self.UIRoot.TextBlock_0:SetText(Text)
  local start_time, end_time = RoleInfoSystem.GetStartTimeAndEndTime()
  if not start_time or not end_time then
    self.UIRoot.TextBlock_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.TextBlock_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  else
    self.UIRoot.TextBlock_5:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_6:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local TimeUtil = require("client.common.time_util")
  local EndTime = TimeUtil.FormatTime_MD(start_time, true)
  local StartTime = TimeUtil.FormatTime_MD(end_time, true)
  self.UIRoot.TextBlock_5:SetText(StartTime)
  self.UIRoot.TextBlock_6:SetText(EndTime)
end
function Lobby_RoleInfo_Combat180_UIBP:UpdateBrokenLine(linetab)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local List = RoleInfoSystem.GetCurBrokenLineData()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local seasonId = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
  local offset = 0
  if #linetab == 2 then
    self.UIRoot.linechart.AuxLineNum = 1
    self.UIRoot.WidgetSwitcher_3:SetActiveWidgetIndex(1)
  else
    offset = 2
    self.UIRoot.linechart.AuxLineNum = 2
    self.UIRoot.WidgetSwitcher_3:SetActiveWidgetIndex(0)
  end
  local i = 0
  for index, value in ipairs(linetab) do
    i = index + offset
    value.rating = math.floor(value.rating or 0)
    local rankCfg = FuncUtil.GetRankTableData(value.level or 101, seasonId)
    self.UIRoot["LevelText_" .. tostring(i)]:SetText(value.rating)
    self.UIRoot["LevelItem_" .. tostring(i)]:SetRankInteral(value.level or 101, nil)
    self.UIRoot["LevelName_" .. tostring(i)]:SetText(rankCfg and rankCfg.Name or "")
    self.UIRoot["LevelText_" .. tostring(i)]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot["LevelName_" .. tostring(i)]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local unitizePosition = RoleInfoSystem.GetUnitizationPositionList(List)
  self.UIRoot.linechart:ClearSeries()
  local   local TArray = slua.Array
  local EPropertyClass = UEnums.EPropertyClass
  local points = TArray(EPropertyClass.Float)
  local flags = TArray(EPropertyClass.Int)
  for index, value in ipairs(unitizePosition) do
    points:Add(value.X or 0)
    points:Add(value.Y or 0)
    flags:Add(value.isShowPoint or 1)
  end
  local color = FColor(1, 0, 253, 191)
  local segment = 8
  self.UIRoot.linechart:AddSeriesForLua(points, flags, color, segment)
  self.UIRoot.linechart:Refresh()
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshAceImprint()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshAceImprint")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local bSelf = tonumber(RoleInfoSystem.CurShowPlayerInfoUid) == tonumber(DataMgr.roleData.uid)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshAceImprint bSelf = " .. tostring(bSelf))
  local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
  self:SetCurShowAceBp(false)
  if bSelf then
    local ace_show_type = LobbySystem.roleData.ace_show_type
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshAceImprint ace_show_type = " .. tostring(ace_show_type))
    if ace_show_type and ace_show_type == ace_config.EAceShowType.PeakGame then
      self:RefreshPeakGameAce()
    elseif ace_show_type and ace_show_type == ace_config.EAceShowType.Honer then
      self:RefreshHonerGameAce()
    else
      self:SpecialImprintPorcess(ace_show_type)
    end
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(RoleInfoSystem.CurShowPlayerInfoUid)
    if profile then
      local ace_show_type = profile.ace_show_type
      if ace_show_type and ace_show_type == ace_config.EAceShowType.PeakGame then
        self:RefreshPeakGameAce()
      elseif ace_show_type and ace_show_type == ace_config.EAceShowType.Honer then
        self:RefreshHonerGameAce()
      else
        self:SpecialImprintPorcess(ace_show_type)
      end
    end
  end
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshClassicAce()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshClassicAce")
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local ace_imprint_show_id, ace_imprint_base_id = LobbySocialSystem.GetAceImprintShowId(RoleInfoSystem.CurShowPlayerInfoUid)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshClassicAce ace_imprint_show_id:" .. tostring(ace_imprint_show_id))
  if ace_imprint_show_id then
    self:SetWidgetVisible(self.UIRoot.Image_Imprint_Not, false, false)
    local AceImprintLogic = require("client.logic.season.AceImprintLogic")
    AceImprintLogic.SetAceImprintImage(self.UIRoot.Common_KingMark_UIBP, ace_imprint_show_id, ace_imprint_base_id)
  else
    self:SetWidgetVisible(self.UIRoot.Common_KingMark_UIBP, false, false)
    self:SetTexture(self.UIRoot.Image_Imprint_Not, "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not")
    self:SetWidgetVisible(self.UIRoot.Image_Imprint_Not, true, false)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshPeakGameAce()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshPeakGameAce")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local ace_util = require("client.logic.season.ace.ace_util")
  local peakgame_ace_id, peakgame_ace_count = ace_util.GetPeakGameAceData(RoleInfoSystem.CurShowPlayerInfoUid)
  if peakgame_ace_id and 0 < peakgame_ace_count then
    self:SetWidgetVisible(self.UIRoot.Image_Imprint_Not, false, false)
    ace_util.SetPeakGameAceImage(self.UIRoot.Common_KingMark_UIBP, peakgame_ace_id, peakgame_ace_count)
  else
    self:SetWidgetVisible(self.UIRoot.Common_KingMark_UIBP, false, false)
    self:SetTexture(self.UIRoot.Image_Imprint_Not, "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not")
    self:SetWidgetVisible(self.UIRoot.Image_Imprint_Not, true, false)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshHonerGameAce()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshHonerGameAce")
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local ace_imprint_show_id, ace_imprint_base_id, ace_imprint_show_cnt = LobbySocialSystem.GetAceImprintShowId(RoleInfoSystem.CurShowPlayerInfoUid)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP RefreshHonerGameAce ace_imprint_show_id:" .. tostring(ace_imprint_show_id))
  if not season_year_util.CheckFunctionIsOpen() then
    self:SetWidgetVisible(self.UIRoot.Common_KingMark_UIBP, false, false)
    self:SetTexture(self.UIRoot.Image_Imprint_Not, "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not")
    self:SetWidgetVisible(self.UIRoot.Image_Imprint_Not, true, false)
    return
  end
  if ace_imprint_show_id then
    if not self.Common_KingMark_UIBP_2 then
      if self.UIRoot.CanvasPanel_7 then
        self.Common_KingMark_UIBP_2 = self:CreateChildWindow(self.UIRoot.CanvasPanel_7, UIManager.UI_Config.Common_KingMark_UIBP_2)
        self.Common_KingMark_UIBP_2:SetAnchors(0.5, 0.5, 0.5, 0.5)
        self.Common_KingMark_UIBP_2:SetPosition(0, 0)
        self.Common_KingMark_UIBP_2:SetAlignment(0.5, 0.5)
        self.Common_KingMark_UIBP_2:SetSize(128, 128)
      else
        log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP: not have self.UIRoot.CanvasPanel_7 ")
      end
    end
    if self.Common_KingMark_UIBP_2 then
      local advance_num = 0
      local history_num = 0
      if ace_imprint_show_cnt and 0 < ace_imprint_show_cnt then
        advance_num = ace_imprint_show_id - ace_imprint_base_id
        history_num = ace_imprint_show_cnt - advance_num
      end
      self.Common_KingMark_UIBP_2:SetWidgetInfo(ace_imprint_base_id, {advance_num = advance_num, history_num = history_num})
    end
    self:SetWidgetVisible(self.UIRoot.Image_Imprint_Not, false, false)
    self:SetCurShowAceBp(season_year_util.CheckFunctionIsOpen())
  else
    self:SetWidgetVisible(self.UIRoot.Common_KingMark_UIBP, false, false)
    self:SetTexture(self.UIRoot.Image_Imprint_Not, "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_Not.iCON_KingMark_Not")
    self:SetWidgetVisible(self.UIRoot.Image_Imprint_Not, true, false)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:SetCurShowAceBp(bIsNew)
  if self.Common_KingMark_UIBP_2 then
    if not bIsNew then
      self.Common_KingMark_UIBP_2:Hide()
    else
      self.Common_KingMark_UIBP_2:Show()
    end
  end
  self:SetWidgetVisible(self.UIRoot.Common_KingMark_UIBP, not bIsNew)
end
function Lobby_RoleInfo_Combat180_UIBP:SpecialImprintPorcess(ace_show_type)
  if ace_show_type == nil then
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local ace_imprint_show_id, ace_imprint_base_id, ace_imprint_show_cnt = LobbySocialSystem.GetAceImprintShowId(RoleInfoSystem.CurShowPlayerInfoUid)
    if ace_imprint_base_id then
      local ace_util = require("client.logic.season.ace.ace_util")
      if ace_util.IsHonerImprint(ace_imprint_base_id) then
        self:RefreshHonerGameAce()
      else
        self:RefreshClassicAce()
      end
    else
      self:RefreshClassicAce()
    end
  else
    self:RefreshClassicAce()
  end
end
function Lobby_RoleInfo_Combat180_UIBP:ClearAddTimerHighPerformance(timer_hander)
  if timer_hander then
    self:RemoveTimer(timer_hander)
    timer_hander = nil
  end
end
function Lobby_RoleInfo_Combat180_UIBP:ResetData()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  self.TeamSize = 1
  RoleInfoMainSystem.UpdateCombatModelType(self.TeamSize)
  self.ViewMode = 1
  RoleInfoMainSystem.SetCombatShootTypeID(self.ViewMode)
  self.currModeIndex = 1
  RoleInfoMainSystem.SetCombatMode(self.currModeIndex)
  self:ClearAddTimerHighPerformance(self.timer)
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickShareCombatInfo()
  self:PlayAudio(sound_config.click_v1)
  if self.currModeIndex == self.EnumModType.PeakGame then
    local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
    logic_peakgame_combat:SharePeakGameCombatInfo()
  else
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.ShareCombat()
  end
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.IndividualAchievements, nil, nil)
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickSeasonLookback()
  self:PlayAudio(sound_config.click_v1)
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  if not logic_season_lookback:GetEntranceSwitch() then
    ShowNotice(512138)
    return
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_LookbackGuide, false)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  UIManager.ShowUI(UIManager.UI_Config.Season_Looback_Main_UIBP, RoleInfoSystem.CurShowPlayerInfoUid, "roleinfo_combat")
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickRadar()
  self:PlayAudio(sound_config.click_v1)
  if self.isRader then
    return
  end
  self.isRader = true
  self:UpdateChartImage()
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickBrokenLine()
  self:PlayAudio(sound_config.click_v1)
  if not self.isRader then
    return
  end
  self.isRader = false
  self:UpdateChartImage()
end
function Lobby_RoleInfo_Combat180_UIBP:OnButtonAceImprintClick()
  self:PlayAudio(sound_config.click_v1)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PersonSpaceSegmentCycleImprint)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  AceImprintLogic.ShowAceMarkUI(RoleInfoSystem.CurShowPlayerInfoUid)
end
function Lobby_RoleInfo_Combat180_UIBP:OnCheckBoxChanged()
  self:PlayAudio(sound_config.click_v1)
  self.isShowCompare = not self.isShowCompare
  if self.isShowCompare then
    self.UIRoot.CheckBox_1:SetCheckedState(1)
  else
    self.UIRoot.CheckBox_1:SetCheckedState(0)
  end
  self:UpdateChartImage()
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickReportButton()
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if RoleInfoSystem.CurShowPlayerInfoUid ~= tonumber(DataMgr.roleData.uid) then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if LogicFriend.IsMyFriend(RoleInfoSystem.CurShowPlayerInfoUid) then
      OpenReportComplaintInIormation(RoleInfoSystem.CurShowPlayerInfoUid)
    elseif self.UIRoot.GridPanel_More:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
      self.UIRoot.GridPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.GridPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickJubaoButton()
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  OpenReportComplaintInIormation(RoleInfoSystem.CurShowPlayerInfoUid)
  self.UIRoot.GridPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickPinbiButton()
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if "" == RoleInfoSystem.CurShowPlayerInfoUid then
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  if logic_friend_blacklist:IsBlacklist(RoleInfoSystem.CurShowPlayerInfoUid) then
    ShowNotice(106065)
  else
    local title = LocUtil.GetLocalizeResStr(34696)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local data = logic_profile:GetLocalProfile(RoleInfoSystem.CurShowPlayerInfoUid)
    if data then
      do
        local msg = LocUtil.LocalizeResFormat(34697, data.nickName)
        local callback = function()
          local bSuccess = logic_friend_blacklist:proc_add_black_list_req(data.uid, logic_friend_blacklist.Enum_Add_Black_Scene.Lobby_RoleInfo_Combat)
          if bSuccess then
            if data.type == EnumApplyType.Partner then
              PersonSpaceSystem.refuse_make_intimacy_partner_req(data.uid)
            elseif data.type == EnumApplyType.Relation then
              LogicFriend.reply_intimacy_relation_req(data.uid, data.param, 0)
            else
              local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
              logic_friend_apply:add_inner_friend_op_req(data.uid, 0)
            end
          end
        end
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(2, title, msg, callback, nil)
      end
    end
  end
  self.UIRoot.GridPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function Lobby_RoleInfo_Combat180_UIBP:OnSelectModeItem(index)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnSelectModeItem index = " .. tostring(index) .. " self.currModeIndex = " .. tostring(self.currModeIndex))
  if index == self.currModeIndex then
    return
  end
  self.currModeIndex = index
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.SetCombatMode(self.currModeIndex)
  if self.currModeIndex == self.EnumModType.Rank then
    self:RefreshRank()
  elseif self.currModeIndex == self.EnumModType.PeakGame then
    self:RefreshPeakGameSeasonList()
    self:RefreshPeakGame()
  elseif self.currModeIndex == self.EnumModType.Match then
    self:RefreshMatch()
  elseif self.currModeIndex == self.EnumModType.Career then
    self:RefreshCareer()
  end
  self:RefershCombatByModeType()
  self:CheckShowSeasonLookbackButton()
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshRank()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshRank")
  self:SetNewSeasonItemList()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.RoleMatchCombatInfoGet = {}
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local showZoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  RoleInfoMainSystem.RequestBattleInfo(showZoneId)
  self:RefreshComboBoxZone(true)
  self.UIRoot.RanderCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.SegmentCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if RoleInfoMainSystem.IsShowSelf() then
    self.UIRoot.SizeBox_BtnShare:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  self.UIRoot.CanvasPanel2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.BattleRank)
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshPeakGameSeasonList()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshPeakGameSeasonList")
  local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
  local seasonNames = logic_peakgame_combat:GetPeakGameBattleSeasonList()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.UpdateRoleinfoSeasonListID(1)
  local cur_index = 1
  self.ComboBox_Season:SetData(seasonNames)
  self.ComboBox_Season.TextBlock_ItemName:SetText(seasonNames[cur_index].text)
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshPeakGame()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshPeakGame")
  self:SetNewTap("team")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local zone_id = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
  local seasonList = logic_peakgame_combat:GetPeakGameBattleSeasonList()
  local season_id = seasonList[RoleInfoMainSystem.GetRoleinfoSeasonListID()].season_id
  local peakGame_info = logic_peakgame_combat:GetPeakGameInfo(season_id, zone_id)
  if peakGame_info == nil then
    logic_peakgame_combat:ReqPeakGameInfo(season_id, zone_id)
  end
  if RoleInfoMainSystem.IsShowSelf() then
    self:SetWidgetVisible(self.UIRoot.SizeBox_BtnShare, true, false)
  end
  self:RefreshComboBoxZone(true)
  self:SetWidgetVisible(self.UIRoot.RanderCanvas, true, false)
  self:SetWidgetVisible(self.UIRoot.SegmentCanvas, false, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel2, false, false)
  self.isRader = true
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.BattlePeakGame)
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshMatch()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshMatch")
  self:SetNewSeasonItemList()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  self:RefreshComboBoxZone(false)
  local season_id = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
  if season_id == RoleInfoSystem.curseasonid then
    RoleInfoSystem.RequestCurrSeasonBattleInfo()
  else
    local RoleInfoMatchSystem = require("client.logic.roleinfo.logic_roleinfo_match")
    RoleInfoMatchSystem.RequestMatchBattleInfo()
  end
  self.UIRoot.RanderCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.SegmentCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.SizeBox_BtnShare:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.CanvasPanel2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.isRader = true
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.BattleMatch)
end
function Lobby_RoleInfo_Combat180_UIBP:RefreshCareer()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:RefreshCareer")
  self:SetNewSeasonItemList()
  self:RefreshComboBoxZone(false)
  self.UIRoot.RanderCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.SegmentCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:RefreshAceImprint()
  self.UIRoot.SizeBox_BtnShare:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.BattleCareer)
end
function Lobby_RoleInfo_Combat180_UIBP:OnSelectSeasonItem(index)
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.UpdateRoleinfoSeasonListID(index)
  local modeId = RoleInfoMainSystem.GetCombatMode()
  if modeId == self.EnumModType.PeakGame then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local zone_id = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
    local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
    local seasonList = logic_peakgame_combat:GetPeakGameBattleSeasonList()
    local season_id = seasonList[RoleInfoMainSystem.GetRoleinfoSeasonListID()].season_id
    local peakgame_info = logic_peakgame_combat:GetPeakGameInfo(season_id, zone_id)
    if peakgame_info == nil then
      RoleInfoMainSystem.UpdateShowRoleinfoOfZoneID(zone_id)
      logic_peakgame_combat:ReqPeakGameInfo(season_id, zone_id)
    else
      self:RefershCombatByModeType()
    end
  else
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local season_id = RoleInfoSystem.AllSeasonIDList[index]
    log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnSelectSeasonItem season_id = " .. tostring(season_id))
    if not season_id then
      log_error("no season_id")
      return
    end
    local showZoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
    if season_id == RoleInfoSystem.curseasonid then
      RoleInfoSystem.RoleMatchCombatInfoGet = {}
      if RoleInfoSystem.CurShowPlayerInfoUid == DataMgr.roleData.uid then
        RoleInfoSystem.RoleSegmentInfo()
      end
      RoleInfoMainSystem.RequestBattleInfo(showZoneId)
    elseif self.currModeIndex == self.EnumModType.Rank then
      RoleInfoMainSystem.RequestBattleInfo(showZoneId)
    elseif self.currModeIndex == self.EnumModType.Match then
      RoleInfoSystem.RoleCombatInfoGet = {}
      local RoleInfoMatchSystem = require("client.logic.roleinfo.logic_roleinfo_match")
      RoleInfoMatchSystem.RequestMatchBattleInfo()
    end
  end
end
function Lobby_RoleInfo_Combat180_UIBP:OnBtnViewChangeClick()
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local modeId = RoleInfoMainSystem.GetCombatMode()
  if modeId == self.EnumModType.PeakGame then
    ShowNotice(68210)
    return
  end
  self.ViewMode = self.ViewMode == 1 and 2 or 1
  self:OnTeamSizeChange()
  RoleInfoMainSystem.SetCombatShootTypeID(self.ViewMode)
  self:RefershCombatByModeType()
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickSingleMode()
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local modeId = RoleInfoMainSystem.GetCombatMode()
  if modeId == self.EnumModType.PeakGame then
    ShowNotice(68210)
    return
  end
  self.TeamSize = 1
  self:OnTeamSizeChange()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.UpdateCombatModelType(1)
  self:RefershCombatByModeType()
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickDoubleMode()
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local modeId = RoleInfoMainSystem.GetCombatMode()
  if modeId == self.EnumModType.PeakGame then
    ShowNotice(68210)
    return
  end
  self.TeamSize = 2
  self:OnTeamSizeChange()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.UpdateCombatModelType(2)
  self:RefershCombatByModeType()
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickTeamMode()
  self:PlayAudio(sound_config.click_v1)
  self.TeamSize = 3
  self:OnTeamSizeChange()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.UpdateCombatModelType(3)
  self:RefershCombatByModeType()
end
function Lobby_RoleInfo_Combat180_UIBP:OnTeamSizeChange()
  local str1 = _Map_TeamSize2ModeStr[self.TeamSize]
  local str2 = _Map_View2ModeStr[self.ViewMode]
  local _selectMode = str2 .. str1
  self:SetNewTap(_selectMode)
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickViewChangeButton()
  self:PlayAudio(sound_config.popup_v1)
  self:ResetButtonState()
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickViewButton()
  self:PlayAudio(sound_config.click_v1)
  self:ResetButtonState()
end
function Lobby_RoleInfo_Combat180_UIBP:OnClickLock()
  self:PlayAudio(sound_config.click_v1)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:ShowRestrictTips()
end
function Lobby_RoleInfo_Combat180_UIBP:ResetButtonState()
  if self.UIRoot.RoleInfo_Season_ViewChange_Item.CanvasPanel_1:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
    self.UIRoot.RoleInfo_Season_ViewChange_Item.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.WidgetSwitcher_7:SetActiveWidgetIndex(1)
  else
    self.UIRoot.RoleInfo_Season_ViewChange_Item.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.RoleInfo_Season_ViewChange_Item.WidgetSwitcher_7:SetActiveWidgetIndex(0)
  end
end
function Lobby_RoleInfo_Combat180_UIBP:OnRefreshAceImprint()
  self:RefreshAceImprint()
end
function Lobby_RoleInfo_Combat180_UIBP:OnRefreshRoleInfo()
  self:UpdateRoleInfo()
end
function Lobby_RoleInfo_Combat180_UIBP:OnGetPeakGameHistorySeasonBattleInfo()
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnGetPeakGameHistorySeasonBattleInfo")
  self:UpdateRoleInfo()
end
local class = require("class")
local ui_base = require("client.slua.umg.person_space.roleinfo_child_base")
local CLobby_RoleInfo_Combat180_UIBP = class(ui_base, nil, Lobby_RoleInfo_Combat180_UIBP)
return CLobby_RoleInfo_Combat180_UIBP