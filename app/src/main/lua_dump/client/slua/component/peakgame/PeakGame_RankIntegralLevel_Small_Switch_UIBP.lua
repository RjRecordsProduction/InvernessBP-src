local PeakGame_RankIntegralLevel_Small_Switch_UIBP = {}
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:ctor(_, config)
  self.end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:OnInitialize()
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  self.PeakGame_RankIntegralLevel_Style_Small_UIBP = LogicPeakGameUtil.InitSmallPeakRankIntegralWidget(self, self.UIRoot.PeakGame_RankIntegralLevel_Style_Small_UIBP)
  local rankColor = FSlateColor(FLinearColor(0, 0, 0, 0.7))
  if self.config and self.config.bDarkMode then
    rankColor = FSlateColor(FLinearColor(1, 1, 1, 1))
  end
  self.UIRoot.PeakGame_RankIntegralLevel_Style_Small_UIBP.RankTextColor = rankColor
end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:RegistEvents()
end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:OnPostInitialize()
  local rankColor = FSlateColor(FLinearColor(0, 0, 0, 0.7))
  if self.config and self.config.bDarkMode then
    rankColor = FSlateColor(FLinearColor(1, 1, 1, 1))
  end
  self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP.RankTextColor = rankColor
end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:OnClose()
end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:SetSegmentBySegmentType(uid, withTitle)
  log(bWriteLog and "PeakGame_RankIntegralLevel_Small_Switch_UIBP:SetSegmentBySegmentType uid = " .. tostring(uid) .. " withTitle = " .. tostring(withTitle))
  if not uid then
    return
  end
  if FuncUtil.IsInXMission() then
    self:_SetTPlanSegment(uid)
    return
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    self:_SetSelfSegmentBySegmentType(uid, withTitle)
    return
  end
  self:_SetOthersSegmentBySegmentType(uid, withTitle)
end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:_SetTPlanSegment(uid)
  log(bWriteLog and "PeakGame_RankIntegralLevel_Small_Switch_UIBP:_SetTPlanSegment uid = " .. tostring(uid))
  self:Collapsed()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Small_Switch_UIBP:_SetTPlanSegment no profile")
    return
  end
  self:SelfHitTestInvisible()
  self.UIRoot.WidgetSwitcher_Segment:SetActiveWidgetIndex(0)
  local military_level = profile.metro_summary and profile.metro_summary.military_level or 1
  self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteralInXMission(military_level)
end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:_SetSelfSegmentBySegmentType(uid, withTitle)
  log(bWriteLog and "PeakGame_RankIntegralLevel_Small_Switch_UIBP:_SetSelfSegmentBySegmentType uid = " .. tostring(uid) .. " withTitle = " .. tostring(withTitle))
  self:SelfHitTestInvisible()
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local segment_show_type = DataMgr.roleData.segment_show_type
  segment_show_type = segment_show_type or PeakGameConfig.EnumSegmentShowType.Rank
  if segment_show_type == PeakGameConfig.EnumSegmentShowType.Rank then
    self.UIRoot.WidgetSwitcher_Segment:SetActiveWidgetIndex(0)
    if withTitle then
      local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
      logic_segment_title:SetMaxSegmentRankInteralWithTitle(self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP, DataMgr.roleData.allzoneSegment, DataMgr.roleData.allzoneSegmentTitle)
    else
      local logic_season_util = require("client.logic.season.logic_season_util")
      local rank_segment_id = logic_season_util:GetCurrAllZoneMaxSegment(DataMgr.roleData.allzoneSegment)
      self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteral(rank_segment_id or 101)
    end
  elseif segment_show_type == PeakGameConfig.EnumSegmentShowType.PeakGame then
    self.UIRoot.WidgetSwitcher_Segment:SetActiveWidgetIndex(1)
    local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
    local peakgame_segment_id = LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxSegmentId()
    self.PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankIntegral(peakgame_segment_id or PeakGameConfig.DefaultPeakGameSegment)
  end
end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:_SetOthersSegmentBySegmentType(uid, withTitle)
  log(bWriteLog and "PeakGame_RankIntegralLevel_Small_Switch_UIBP:_SetOthersSegmentBySegmentType uid = " .. tostring(uid) .. " withTitle = " .. tostring(withTitle))
  self:Collapsed()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Small_Switch_UIBP:_SetOthersSegmentBySegmentType no profile")
    return
  end
  self:SelfHitTestInvisible()
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local segment_show_type = profile.segment_show_type
  segment_show_type = segment_show_type or PeakGameConfig.EnumSegmentShowType.Rank
  if segment_show_type == PeakGameConfig.EnumSegmentShowType.Rank then
    self.UIRoot.WidgetSwitcher_Segment:SetActiveWidgetIndex(0)
    if withTitle then
      local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
      logic_segment_title:SetMaxSegmentRankInteralWithTitle(self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP, profile.segment_info, profile.hsegment_title_det)
    else
      local rank_segment_id
      local logic_season_util = require("client.logic.season.logic_season_util")
      rank_segment_id = logic_season_util:GetCurrAllZoneMaxSegment(profile.segment_info)
      self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteral(rank_segment_id or 101)
      log(bWriteLog and "PeakGame_RankIntegralLevel_Small_Switch_UIBP:_SetOthersSegmentBySegmentType 1")
    end
  elseif segment_show_type == PeakGameConfig.EnumSegmentShowType.PeakGame then
    self.UIRoot.WidgetSwitcher_Segment:SetActiveWidgetIndex(1)
    local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
    local peakgame_segment_id = LogicPeakGameSegmentUtil.GetProfileCurMaxSegmentId(profile)
    self.PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankIntegral(peakgame_segment_id or PeakGameConfig.DefaultPeakGameSegment)
  end
end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:SetRankInteralColor(rankColor)
  self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP.RankTextColor = rankColor
end
function PeakGame_RankIntegralLevel_Small_Switch_UIBP:ChangeRankInteralColor(rankColor)
  self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:ChangeRankInteralColor(rankColor)
  self.PeakGame_RankIntegralLevel_Style_Small_UIBP:ChangeRankInteralColor(rankColor)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CPeakGame_RankIntegralLevel_Small_Switch_UIBP = class(ui_base, nil, PeakGame_RankIntegralLevel_Small_Switch_UIBP)
return CPeakGame_RankIntegralLevel_Small_Switch_UIBP