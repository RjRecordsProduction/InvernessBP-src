local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
local RoleInfo_Rank_Popup_UIBP = {}
function RoleInfo_Rank_Popup_UIBP:ctor(_, modeType)
  self.ModeType = modeType
end
function RoleInfo_Rank_Popup_UIBP:OnInitialize()
  self.Common_Popup_Medium_UIBP_2 = self:InitCommonPopup(self.UIRoot.Common_Popup_Medium_UIBP_2)
  local titleText = LocUtil.GetLocalizeResStr(646)
  self.UIRoot.TextBlock_TitleArchive:SetText(LocUtil.GetLocalizeResStr(45863))
  local extraData = {
    helpInfo = {
      showFunc = function()
        self:OnBtnTipClick()
      end
    }
  }
  self.Common_Popup_Medium_UIBP_2:SetData(self, titleText, extraData)
end
function RoleInfo_Rank_Popup_UIBP:RegistEvents()
  RoleInfo_Rank_Popup_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.BtnClose, self.OnBtnCloseClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Season_Grading_Single.Button_ShowLevelNameInfo, self.OnClickSingleScore, self)
  self:AddOnClickedEventByControl(self.UIRoot.Season_Grading_Double.Button_ShowLevelNameInfo, self.OnClickDoubleScore, self)
  self:AddOnClickedEventByControl(self.UIRoot.Season_Grading_Team.Button_ShowLevelNameInfo, self.OnClickTeamScore, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close_Tips, self.HideScoreTips, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Title, self.OnBtnTitleClick, self)
  self.UIRoot.ReuseComboboxGroup:Register(self.UIRoot.ReuseCombobox1_FPPorTPP)
  self.UIRoot.ReuseCombobox1_FPPorTPP:ShowFrame(true)
  self:AddControlEventByControl(self.UIRoot.ReuseCombobox1_FPPorTPP, "OnSelectItemChanged", self.OnSelectShootItem, self)
  self.UIRoot.ReuseComboboxGroup:Register(self.UIRoot.ReuseCombobox_Season)
  self.UIRoot.ReuseCombobox_Season:ShowFrame(true)
  self:AddControlEventByControl(self.UIRoot.ReuseCombobox_Season, "OnSelectItemChanged", self.OnSelectSeasonItem, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO, self.OnRefreshInfo, self)
  self:AddControlEventByControl(self.UIRoot.out, "OnAnimationFinished", self.OnAnimationFinished, self)
  self:AddCommonEvent(EVENTTYPE_SEGMENT_TITLE, EVENTID_SEGMENT_TITLE_SET_RSP, self.SetSegmentInfo, self)
  self.ComboBox_Zone = self:InitCustomComboBox(self.UIRoot.Common_ComboBox_200_C_0)
  self.ComboBox_Zone:SetRefreshOptionCallback(self.OnRefreshZoneItem, self)
  self.ComboBox_Zone:SetSelectOptionCallback(self.OnClickZoneItem, self)
  self.ComboBox_Zone:AddControlEventByControl(self.ComboBox_Zone.UIRoot, "OnOpening", self.OnBoxOpen, self)
end
function RoleInfo_Rank_Popup_UIBP:OnAnimationFinished()
  self:AddTimerOnce(0, function()
    self:CloseSelf()
  end)
end
function RoleInfo_Rank_Popup_UIBP:OnPostInitialize()
  RoleInfo_Rank_Popup_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
  self:InitComboBoxZoneState()
end
function RoleInfo_Rank_Popup_UIBP:OnClose()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if RoleInfoMainSystem.GetSaveDataSwitch() and RoleInfoSystem.IsSelf() then
    RoleInfoMainSystem.UpdateRoleinfoSeasonListID(1)
    RoleInfoMainSystem.RequestBattleInfo()
  end
  RoleInfo_Rank_Popup_UIBP.__super.OnClose(self)
end
function RoleInfo_Rank_Popup_UIBP:OnRefreshZoneItem(widget, data, index, selectIndex)
  widget.TextBlock_ItemName:SetText(data.text)
  if index == selectIndex then
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
  else
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.7)))
  end
end
function RoleInfo_Rank_Popup_UIBP:OnClickZoneItem(widget, data)
  self:PlayAudio(sound_config.click_v1)
  local text = data.text
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.nChooseZoneID
  log(bWriteLog and "OnClickZoneItem nChooseZoneID = " .. tostring(zoneID))
  if tonumber(zoneID) == tonumber(data.zone_id) then
    text = LocUtil.LocalizeResFormat(44891, text)
  end
  widget.TextBlock_ItemName:SetText(text)
  log(bWriteLog and "Lobby_RoleInfo_Combat180_UIBP:OnClickZoneItem data = " .. tostring(data.zone_id))
  RoleInfoMainSystem.RequestBattleInfo(tonumber(data.zone_id))
end
function RoleInfo_Rank_Popup_UIBP:InitComboBoxZoneState()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local uid = RoleInfoSystem.CurShowPlayerInfoUid
  log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:InitComboBoxZoneState uid = " .. tostring(uid))
  local profile = LobbySocialSystem.GetProfileByUID(uid)
  if not profile then
    log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:InitComboBoxZoneState profile is invalid")
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if not profile.segment_info then
    log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:InitComboBoxZoneState profile.segment_info is invalid")
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:InitComboBoxZoneState is BLUEHOLE")
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local logic_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_combat)
  local zoneIdList = logic_combat:GetZoneList(profile.segment_info)
  if #zoneIdList == 1 then
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:InitComboBoxZoneState zoneIdList length = 1")
    return
  else
    self.ComboBox_Zone:SetData(zoneIdList)
    self.UIRoot.SizeBox_Zone:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.ComboBox_Zone:SelectIndex(1)
  end
end
function RoleInfo_Rank_Popup_UIBP:UpdateUI()
  RoleInfoMainSystem.UpdateRoleinfoSeasonListID(1)
  self.UIRoot.TextBlock_TitleArchive:SetText(LocUtil.GetLocalizeResStr(45863))
  self:HideScoreTips()
  self:SetSwitchBtnsStatus()
  self:SetArchiveButtonVisibility()
  self:InitComboboxWidget()
  self:SetNewSeasonItemList()
  self:UpdateInfo()
end
function RoleInfo_Rank_Popup_UIBP:HideScoreTips()
  log(bWriteLog and "[RoleInfo_Rank_Popup_UIBP] HideScoreTips")
  self:PlayAudio(sound_config.click_v1)
  self.UIRoot.ScoreTips1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.ScoreTips2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.ScoreTips3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Button_Close_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function RoleInfo_Rank_Popup_UIBP:SetSwitchBtnsStatus()
  if LobbySystem.CheckOpen(20027) then
    self.UIRoot.Common_ComboBox_200_C_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Common_ComboBox_200_C_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function RoleInfo_Rank_Popup_UIBP:SetArchiveButtonVisibility()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
  if logic_segment_title:IsSegmentTitleSwitchOpen() then
    self:SetWidgetVisible(self.UIRoot.Button_Title, true, true)
  else
    self:SetWidgetVisible(self.UIRoot.Button_Title, false, true)
  end
end
function RoleInfo_Rank_Popup_UIBP:InitComboboxWidget()
  if self.ModeType then
    RoleInfoMainSystem.SetBaseShootTypeID(self.ModeType)
    self.ModeType = nil
    self:SetNewTypeItemList()
    return
  end
  local basicData = RoleInfoMainSystem.GetPersonInfo()
  if basicData and next(basicData) then
    local maxRank = math.max(basicData.role_segment_solo or 101, basicData.role_segment_double or 101, basicData.role_segment_team or 101)
    local maxFPPRank = math.max(basicData.role_segmentFPP_solo or 101, basicData.role_segmentFPP_double or 101, basicData.role_segmentFPP_team or 101)
    if maxRank >= maxFPPRank then
      RoleInfoMainSystem.SetBaseShootTypeID(1)
    else
      RoleInfoMainSystem.SetBaseShootTypeID(2)
    end
  end
  self:SetNewTypeItemList()
end
function RoleInfo_Rank_Popup_UIBP:SetNewSeasonItemList()
  log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:SetNewSeasonItemList")
  self.ComboBox_Season = self:InitCustomComboBox(self.UIRoot.Common_ComboBox_200_C_1)
  self.ComboBox_Season:SetRefreshOptionCallback(self.OnRefreshSeasonItem, self)
  self.ComboBox_Season:SetSelectOptionCallback(self.OnClickSeasonItem, self)
  self.ComboBox_Season:AddControlEventByControl(self.ComboBox_Season.UIRoot, "OnOpening", self.OnBoxOpen, self)
  local logic_rank_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rank_combat)
  local seasonNames = logic_rank_combat:GetRankBattleSeasonList()
  if not seasonNames or not next(seasonNames) then
    log(bWriteLog and "  : not seasonNames")
    return
  end
  self.ComboBox_Season:SetData(seasonNames)
  self.ComboBox_Season:SelectIndex(RoleInfoMainSystem.GetRoleinfoSeasonListID())
end
function RoleInfo_Rank_Popup_UIBP:OnClickSeasonItem(widget, data, index, selectIndex)
  if not data then
    return
  end
  widget.TextBlock_ItemName:SetText(data.text)
  self:OnSelectSeasonItem(index)
end
function RoleInfo_Rank_Popup_UIBP:OnRefreshSeasonItem(widget, data, index, selectIndex)
  if not data then
    return
  end
  widget.TextBlock_ItemName:SetText(data.text)
  if index == selectIndex then
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
    widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.7)))
    widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function RoleInfo_Rank_Popup_UIBP:SetNewTypeItemList()
  self.ComboBox_Type = self:InitCustomComboBox(self.UIRoot.Common_ComboBox_200_C_2)
  self.ComboBox_Type:SetRefreshOptionCallback(self.OnRefreshTypeItem, self)
  self.ComboBox_Type:SetSelectOptionCallback(self.OnClickTypeItem, self)
  self.ComboBox_Type:AddControlEventByControl(self.ComboBox_Type.UIRoot, "OnOpening", self.OnBoxOpen, self)
  local typeList = RoleInfoMainSystem.GetRoleInfoShootTypeNameList()
  local modeInfoList = {}
  for k, v in ipairs(typeList) do
    table.insert(modeInfoList, {index = k, str = v})
  end
  self.ComboBox_Type:SetData(modeInfoList)
  self.ComboBox_Type:SelectIndex(RoleInfoMainSystem.GetRoleInfoBaseShootTypeID())
end
function RoleInfo_Rank_Popup_UIBP:OnRefreshTypeItem(widget, data, index, selectIndex)
  widget.TextBlock_ItemName:SetText(data.str)
  if index == selectIndex then
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
    widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.7)))
    widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function RoleInfo_Rank_Popup_UIBP:OnClickTypeItem(widget, data)
  widget.TextBlock_ItemName:SetText(data.str)
  self:OnSelectShootItem(data.index - 1, true)
end
function RoleInfo_Rank_Popup_UIBP:OnBoxOpen(widget)
  self:PlayAudio(sound_config.popup_v1)
end
function RoleInfo_Rank_Popup_UIBP:UpdateInfo()
  self.UIRoot.ReuseComboboxGroup:HideAll()
  self:UpdateSegmentInfo()
end
function RoleInfo_Rank_Popup_UIBP:UpdateSegmentInfo()
  self:SetSegmentInfo()
  self:SetTipsScoreInfo()
  self:RefreshScoreAndRank()
end
function RoleInfo_Rank_Popup_UIBP:SetSegmentInfo()
  local root = self.UIRoot
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local GetScoreNum = function(index, segmentLevel, season_id)
    local combatData
    if RoleInfoMainSystem.GetRoleInfoBaseShootTypeID() == 1 then
      combatData = RoleInfoSystem.CombatTotalInfoList[index]
    else
      combatData = RoleInfoSystem.FPPCombatTotalInfoList[index]
    end
    local score = 0
    if combatData and combatData.role_score and combatData.role_score ~= "" then
      log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:SetSegmentInfo combatData.role_score = " .. tostring(combatData.role_score))
      score = tonumber(combatData.role_score)
    end
    if segmentLevel and segmentLevel == 801 then
      return string.format(LocUtil.GetLocalizeResStr(301301), score)
    else
      local RankCfg = FuncUtil.GetRankTableData(segmentLevel, season_id)
      if RankCfg and RankCfg.NextIntegralScore then
        return string.format(LocUtil.GetLocalizeResStr(301303), score, RankCfg.NextIntegralScore)
      end
    end
    return LocUtil.LocalizeResFormat(645, score)
  end
  local GetSegment = function()
    local basicData = RoleInfoMainSystem.GetPersonInfo()
    if not basicData or not next(basicData) then
      return 101, 101, 101
    end
    if RoleInfoMainSystem.GetRoleInfoBaseShootTypeID() == 1 then
      return basicData.role_segment_solo or 101, basicData.role_segment_double or 101, basicData.role_segment_team or 101
    else
      return basicData.role_segmentFPP_solo or 101, basicData.role_segmentFPP_double or 101, basicData.role_segmentFPP_team or 101
    end
  end
  local SetInteral = function(widget, segmentNum, seasonId, teamNum, index)
    widget.Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteralBySeason(segmentNum, nil, seasonId or 0)
    local perspective, combatData
    if RoleInfoMainSystem.GetRoleInfoBaseShootTypeID() == 1 then
      perspective = ENUM_PerspectiveType.TPP
      combatData = RoleInfoSystem.CombatTotalInfoList[index]
    else
      perspective = ENUM_PerspectiveType.FPP
      combatData = RoleInfoSystem.FPPCombatTotalInfoList[index]
    end
    local rating = 0
    if combatData and combatData.role_score and combatData.role_score ~= "" then
      log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:SetSegmentInfo SetInteral combatData.role_score = " .. tostring(combatData.role_score))
      rating = tonumber(combatData.role_score)
    end
    local segTitleId
    if seasonId and seasonId ~= 0 and seasonId ~= DataMgr.season_id then
      local shootType = RoleInfoMainSystem.GetRoleInfoBaseShootTypeID()
      segTitleId = RoleInfoSystem.GetHistorySegmentTitle(shootType, teamNum)
    else
      local basicData = RoleInfoMainSystem.GetPersonInfo()
      if basicData and basicData.hsegment_title_det then
        local segmentTitleInfo = basicData.hsegment_title_det
        local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
        segTitleId = logic_segment_title:GetSegmentTitleIdByTeamNum(segmentTitleInfo, RoleInfoMainSystem.GetShowRoleinfoOfZoneID(), teamNum, perspective)
      end
    end
    widget.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteralWithSegmentTitle(segmentNum, nil, seasonId or 0, segTitleId, rating)
  end
  local seasonId = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
  local roleSegmentSolo, roleSegmentDouble, roleSegmentTeam = GetSegment()
  local strScoreSolo = GetScoreNum(1, roleSegmentSolo, seasonId)
  local strScoreDouble = GetScoreNum(2, roleSegmentDouble, seasonId)
  local strScoreTeam = GetScoreNum(3, roleSegmentTeam, seasonId)
  log(bWriteLog and "[bgp] strScoreSolo" .. tostring(strScoreSolo))
  root.Season_Grading_Single.UTRichTextBlock_Rating:SetText(strScoreSolo)
  root.Season_Grading_Double.UTRichTextBlock_Rating:SetText(strScoreDouble)
  root.Season_Grading_Team.UTRichTextBlock_Rating:SetText(strScoreTeam)
  SetInteral(root.Season_Grading_Single, roleSegmentSolo, seasonId, 1, 1)
  SetInteral(root.Season_Grading_Double, roleSegmentDouble, seasonId, 2, 2)
  SetInteral(root.Season_Grading_Team, roleSegmentTeam, seasonId, 4, 3)
  local strTitle01 = LocUtil.GetLocalizeResStr(102120)
  root.Season_Grading_Single.TextBlock_Title:SetText(strTitle01)
  local strTitle02 = LocUtil.GetLocalizeResStr(102121)
  root.Season_Grading_Double.TextBlock_Title:SetText(strTitle02)
  local strTitle03 = LocUtil.GetLocalizeResStr(102122)
  root.Season_Grading_Team.TextBlock_Title:SetText(strTitle03)
end
function RoleInfo_Rank_Popup_UIBP:SetTipsScoreInfo()
  local root = self.UIRoot
  local GetScoreInfo = function(index)
    local combatScoreData
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    if RoleInfoMainSystem.GetRoleInfoBaseShootTypeID() == 1 then
      combatScoreData = RoleInfoSystem.CombatTotalInfoList[index] or {}
    else
      combatScoreData = RoleInfoSystem.FPPCombatTotalInfoList[index] or {}
    end
    if combatScoreData and next(combatScoreData) then
      return combatScoreData.role_score, combatScoreData.role_rankscore, combatScoreData.role_killscore
    end
    return 0, 0, 0
  end
  for idx = 1, 3 do
    local score, rankScore, killScore = GetScoreInfo(idx)
    if idx == 1 then
      root.TextBlock_RankScoreSingle:SetText(rankScore)
      root.TextBlock_ScoreSingle:SetText(score)
      root.TextBlock_KillScoreSingle:SetText(killScore)
    elseif idx == 2 then
      root.TextBlock_RankScoreDouble:SetText(rankScore)
      root.TextBlock_ScoreDouble:SetText(score)
      root.TextBlock_KillScoreDouble:SetText(killScore)
    elseif idx == 3 then
      root.TextBlock_RankScoreTeam:SetText(rankScore)
      root.TextBlock_ScoreTeam:SetText(score)
      root.TextBlock_KillScoreTeam:SetText(killScore)
    end
  end
end
function RoleInfo_Rank_Popup_UIBP:RefreshScoreAndRank()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local totalScore = ""
  local totalRank = ""
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  if RoleInfoMainSystem.GetRoleInfoBaseShootTypeID() == 1 then
    if RoleInfoSystem.PersonalTotalScoreInfo[zoneId] and RoleInfoSystem.PersonalTotalScoreInfo[zoneId].role_totalscore then
      totalScore = RoleInfoSystem.PersonalTotalScoreInfo[zoneId].role_totalscore
    end
    if RoleInfoSystem.PersonalTotalRankInfo[zoneId] and RoleInfoSystem.PersonalTotalRankInfo[zoneId].role_totalrank then
      totalRank = RoleInfoSystem.PersonalTotalRankInfo[zoneId].role_totalrank
    end
  else
    if RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId] and RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId].role_totalscore then
      totalScore = RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId].role_totalscore
    end
    if RoleInfoSystem.FPPPersonalTotalRankInfo[zoneId] and RoleInfoSystem.FPPPersonalTotalRankInfo[zoneId].role_totalrank then
      totalRank = RoleInfoSystem.FPPPersonalTotalRankInfo[zoneId].role_totalrank
    end
  end
  if totalScore ~= "" and totalRank ~= "" then
    self.UIRoot.TextBlock_TotalScore:SetText(totalScore)
    self.UIRoot.TextBlock_TotalScoreRank:SetText(totalRank)
  else
    self.UIRoot.TextBlock_TotalScore:SetText(1588)
    self.UIRoot.TextBlock_TotalScoreRank:SetText(LocUtil.GetLocalizeResStr(102127))
  end
end
function RoleInfo_Rank_Popup_UIBP:ResetData()
end
function RoleInfo_Rank_Popup_UIBP:OnBtnCloseClick()
  self:PlayAudio(sound_config.click)
  self:CloseSelf()
end
function RoleInfo_Rank_Popup_UIBP:OnClickSingleScore()
  self:PlayAudio(sound_config.subTab_v1)
  self:ShowItemTips(self.UIRoot.ScoreTips1)
end
function RoleInfo_Rank_Popup_UIBP:OnClickDoubleScore()
  self:PlayAudio(sound_config.subTab_v1)
  self:ShowItemTips(self.UIRoot.ScoreTips2)
end
function RoleInfo_Rank_Popup_UIBP:OnClickTeamScore()
  self:PlayAudio(sound_config.subTab_v1)
  self:ShowItemTips(self.UIRoot.ScoreTips3)
end
function RoleInfo_Rank_Popup_UIBP:OnBtnTipClick()
  self:PlayAudio(sound_config.click_v1)
  local UIUtil = require("client.common.ui_util")
  local tipPos = UIUtil.GetWidgetViewportPos(self.Common_Popup_Medium_UIBP_2.UIRoot.Button_Help)
  local helpTipsUI = UIManager.ShowUI(UIManager.UI_Config.Common_HelpTips_UIBP)
  if helpTipsUI then
    helpTipsUI:ShowPanelStrWithPos(LocUtil.GetLocalizeStrConcatenation(27218), tipPos.X, tipPos.Y + 180, true, true)
  end
end
function RoleInfo_Rank_Popup_UIBP:OnBtnTitleClick()
  self:PlayAudio(sound_config.click_v1)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneId = ZoneSystem.nChooseZoneID
  if zoneId == 0 then
    zoneId = 1
  end
  local curTppScore = RoleInfoSystem.CurrSeasonTPPTotalScore[zoneId] or 0
  local curTppRank = RoleInfoSystem.CurrSeasonTPPTotalRank[zoneId] or ""
  local curFppScore = RoleInfoSystem.CurrSeasonFPPTotalScore[zoneId] or 0
  local curFppRank = RoleInfoSystem.CurrSeasonFPPTotalRank[zoneId] or ""
  if curTppScore == 0 or curTppRank == "" or curFppScore == 0 or curFppRank == "" then
    log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:OnBtnTitleClick not data")
    return
  end
  local ERankShowType = {Tpp = 1, Fpp = 2}
  local rankShowType = RoleInfoMainSystem.GetRankShowType()
  local playersType, segment = RoleInfoMainSystem.GetMaxSegmentInfo(rankShowType)
  local modeId = 1
  if rankShowType == ERankShowType.Tpp then
    modeId = 4 - playersType
  else
    modeId = 7 - playersType
  end
  local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
  local segToShow = logic_segment_title:ConvertSegmentToShow(segment)
  log(bWriteLog and "RoleInfo_Rank_Popup_UIBP:OnBtnTitleClick Show Title segToShow = " .. tostring(segToShow) .. ", zoneId = " .. tostring(zoneId) .. ", modeId = " .. tostring(modeId) .. ", RoleInfoSystem.CurShowPlayerInfoUid = " .. tostring(RoleInfoSystem.CurShowPlayerInfoUid))
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_AceExcellence_Detail_Temporada_UIBP, segToShow, zoneId, modeId, tonumber(RoleInfoSystem.CurShowPlayerInfoUid))
end
function RoleInfo_Rank_Popup_UIBP:ShowItemTips(item_widget)
  if not item_widget then
    return
  end
  if item_widget:IsVisible() then
    item_widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    item_widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Button_Close_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
function RoleInfo_Rank_Popup_UIBP:OnSelectShootItem(index)
  log(bWriteLog and "[RoleInfo_Rank_Popup_UIBP] OnSelectShootItem")
  self:PlayAudio(sound_config.click_v1)
  index = index + 1
  RoleInfoMainSystem.SetBaseShootTypeID(index)
  self:UpdateSegmentInfo()
end
function RoleInfo_Rank_Popup_UIBP:OnSelectSeasonItem(index)
  log(bWriteLog and "[RoleInfo_Rank_Popup_UIBP] OnSelectSeasonItem")
  self:PlayAudio(sound_config.click_v1)
  RoleInfoMainSystem.UpdateRoleinfoSeasonListID(index)
  local showZoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  RoleInfoMainSystem.RequestBattleInfo(showZoneId)
end
function RoleInfo_Rank_Popup_UIBP:OnRefreshInfo()
  self:UpdateInfo()
end
local class = require("class")
local ui_base = require("client.slua.umg.person_space.roleinfo_child_base")
local CRoleInfo_Rank_Popup_UIBP = class(ui_base, nil, RoleInfo_Rank_Popup_UIBP)
return CRoleInfo_Rank_Popup_UIBP