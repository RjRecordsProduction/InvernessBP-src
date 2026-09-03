local ModeSelection_Main_Segment = {}
local activeChallengeIcon = "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Challenge/Common_Icon_Challenge08.Common_Icon_Challenge08"
local inactiveChallengeIcon = "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Challenge/Common_Icon_Challenge01.Common_Icon_Challenge01"
function ModeSelection_Main_Segment:GetSegmentData(filter_info, zoneID)
  local SeasonSystem = require("client.logic.season.logic_season")
  local segment = SeasonSystem.GetCurrentSegment(filter_info.teamNum, filter_info.perspective)
  local rating = SeasonSystem.GetCurModeRating(filter_info.teamNum, filter_info.perspective)
  local perspective
  if segment and rating then
    if filter_info.perspective == ENUM_PerspectiveType.TPP then
      if filter_info.teamNum == 1 then
        perspective = "solo"
      elseif filter_info.teamNum == 2 then
        perspective = "duo"
      elseif filter_info.teamNum == 4 then
        perspective = "squad"
      end
    elseif filter_info.perspective == ENUM_PerspectiveType.FPP then
      if filter_info.teamNum == 1 then
        perspective = "fppsolo"
      elseif filter_info.teamNum == 2 then
        perspective = "fppduo"
      elseif filter_info.teamNum == 4 then
        perspective = "fppsquad"
      end
    end
    return segment, rating, perspective
  else
    log_error("[ZH]GetSegmentData get segment or rating is nil!!!, use default")
  end
  local segmentData = {}
  local rankData
  if DataMgr.roleData.allzoneSegment then
    segmentData = DataMgr.roleData.allzoneSegment[zoneID]
  end
  if DataMgr.roleData.rankdata then
    rankData = DataMgr.roleData.rankdata[zoneID]
  end
  if not rankData then
    return segmentData, rankData
  end
  local e_SementType = enum_SegmentType
  if filter_info.perspective == ENUM_PerspectiveType.TPP then
    if filter_info.teamNum == 1 then
      return segmentData[e_SementType.solo], rankData.solo.rank_rating, "solo"
    elseif filter_info.teamNum == 2 then
      return segmentData[e_SementType.double], rankData.duo.rank_rating, "duo"
    elseif filter_info.teamNum == 4 then
      return segmentData[e_SementType.team], rankData.squad.rank_rating, "squad"
    end
  elseif filter_info.perspective == ENUM_PerspectiveType.FPP then
    if filter_info.teamNum == 1 then
      return segmentData[e_SementType.fpp_solo], rankData.fppsolo.rank_rating, "fppsolo"
    elseif filter_info.teamNum == 2 then
      return segmentData[e_SementType.fpp_double], rankData.fppduo.rank_rating, "fppduo"
    elseif filter_info.teamNum == 4 then
      return segmentData[e_SementType.fpp_team], rankData.fppsquad.rank_rating, "fppsquad"
    end
  end
end
function ModeSelection_Main_Segment:SetVisible(root, viewData, UIIns, ENUM_MENU_TYPE)
  if not viewData then
    root.CanvasPanel_9:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  if viewData.menu_id == 120 and LogicPeakGame:CheckCanPlayPeakGame() then
    root.CanvasPanel_9:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    root.WidgetSwitcher_Seg:SetActiveWidgetIndex(1)
    self:SetPeakSeg(root, viewData, UIIns)
  elseif viewData.is_ranked and viewData.is_ranked == 1 then
    root.CanvasPanel_9:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    root.WidgetSwitcher_Seg:SetActiveWidgetIndex(0)
  else
    root.CanvasPanel_9:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if UIIns then
    self:RefreshSegmentLimit(root, viewData, UIIns.filter_info, UIIns.menuAlphaType, UIIns.topMenuId, ENUM_MENU_TYPE)
    self:UpdateSeasonEntry(root, viewData, UIIns.secMenuId, UIIns)
  else
    log(bWriteLog and "ModeSelection_Main_Segment:SetVisible UIIns is nil")
  end
end
function ModeSelection_Main_Segment:SetPeakSeg(root, viewData, UIIns)
  local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
  local segment_id = LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameSegmentId()
  local rating = LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameRating()
  if not segment_id or not rating then
    return
  end
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local rankCfg = LogicPeakGameUtil.GetPeakRankTableData(segment_id)
  if not rankCfg then
    return
  end
  root.UTRichTextBlock_PeakScore:SetText(LocUtil.LocalizeResFormat(43358, rating, rankCfg.NextIntegralScore))
  root.TextBlock_PeakSegName:SetText(rankCfg.Name)
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(root.Image_PeakSeg, rankCfg.SmallIcon)
end
function ModeSelection_Main_Segment:RefreshSegmentLimit(root, viewData, filter_info, menuAlphaType, topMenuId, ENUM_MENU_TYPE)
  root.CanvasPanel_SegmentLimit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local shouldShowSegmentArea = false
  if viewData then
    if viewData.menu_id == 120 then
      local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
      shouldShowSegmentArea = LogicPeakGame:CheckCanPlayPeakGame()
    elseif viewData.is_ranked and viewData.is_ranked == 1 then
      shouldShowSegmentArea = true
    end
  end
  if not shouldShowSegmentArea then
    return
  end
  if not LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    return
  end
  if not filter_info then
    return
  end
  if menuAlphaType == nil or menuAlphaType ~= ENUM_MENU_TYPE.VIEW and topMenuId ~= 100 then
    return
  end
  local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
  local minSeg, maxSeg = LogicTeamUpLimit.GetSpecifiedModeSegmentLimit(filter_info.perspective, filter_info.teamNum)
  if minSeg == nil or maxSeg == nil or minSeg == 0 or maxSeg == 0 then
    return
  end
  if minSeg == -1 or maxSeg == -1 then
    root.TextBlock_SegmentLimit:SetText(LocUtil.GetLocalizeResStr(27201))
    root.CanvasPanel_SegmentLimit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  local logic_rating_protect_for_umg = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_for_umg")
  local hasData = logic_rating_protect_for_umg.CallFuc("CheckHasNoLimitForSegment")
  if hasData then
    root.TextBlock_SegmentLimit:SetText(LocUtil.GetLocalizeResStr(85777))
    root.CanvasPanel_SegmentLimit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  local minSegCfg = FuncUtil.GetRankTableData(minSeg, DataMgr.season_id)
  local maxSegCfg = FuncUtil.GetRankTableData(maxSeg, DataMgr.season_id)
  if minSegCfg == nil or maxSegCfg == nil then
    root.CanvasPanel_SegmentLimit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if minSegCfg.IntegralTypeNew == maxSegCfg.IntegralTypeNew then
    root.TextBlock_SegmentLimit:SetText(LocUtil.LocalizeResFormat("27211", minSegCfg.IntegralTypeName))
  else
    root.TextBlock_SegmentLimit:SetText(LocUtil.LocalizeResFormat("27190", minSegCfg.IntegralTypeName, maxSegCfg.IntegralTypeName))
  end
  root.CanvasPanel_SegmentLimit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function ModeSelection_Main_Segment:UpdateSeasonEntry(root, viewData, secMenuId, UIIns)
  local shouldShowEntry = false
  if viewData and viewData.is_ranked and viewData.is_ranked == 1 then
    local currentSeasonCfg = CDataTable.GetTableData("SeasonInfo", DataMgr.season_id)
    if currentSeasonCfg then
      local TimeUtil = require("client.common.time_util")
      local now = TimeUtil.GetServerTimeInSec()
      local endTime = TimeUtil.TimeStringToUnixstamp(currentSeasonCfg.EndTime)
      local startTime = TimeUtil.TimeStringToUnixstamp(currentSeasonCfg.StartTime)
      if now > startTime and now < endTime then
        shouldShowEntry = true
      end
    end
  end
  if secMenuId == 120 then
    shouldShowEntry = false
  end
  if root and root.SizeBox_Open then
    self:UpdateSeasonEntryVisible(root, shouldShowEntry, UIIns)
  end
end
function ModeSelection_Main_Segment:UpdateSeasonEntryVisible(root, SeasonIsOpen, UIIns)
  log(bWriteLog and "ModeSelection_Main_Segment:UpdateSeasonEntry SeasonIsOpen " .. tostring(SeasonIsOpen))
  UIIns:SetWidgetVisible(root.SizeBox_Open, SeasonIsOpen)
end
function ModeSelection_Main_Segment:RefreshUI(root, filter_info)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.nChooseZoneID
  if zoneID == 0 then
    zoneID = 1
  end
  local segment, rank_rating, modeStr = self:GetSegmentData(filter_info, zoneID)
  if not segment or not rank_rating then
    log(bWriteLog and "[ZH] segment info is empty")
    return
  end
  local util = require("client.slua_ui_framework.util")
  local segmentCfg = FuncUtil.GetRankTableData(segment)
  if segmentCfg then
    root.Image_Rank:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    util.SetTexture(root.Image_Rank, segmentCfg.SmallIcon128)
    root.Common_RankIntegralLevel_Style_Small_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
    local segTitleId = logic_segment_title:GetSelfSegmentTitleIdByTeamNum(zoneID, filter_info.teamNum, filter_info.perspective)
    root.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteralWithSegmentTitle(segment, nil, nil, segTitleId, rank_rating)
    local NextIntegralScore = segmentCfg.NextIntegralScore
    if tonumber(segment) >= 801 then
      NextIntegralScore = math.floor(rank_rating + 0.5) - math.floor(rank_rating + 0.5) % 100 + 100
    end
    root.UTRichTextBlock_RankScore:SetText(LocUtil.LocalizeResFormat(43358, math.floor(rank_rating + 0.5), NextIntegralScore))
  else
    root.Image_Rank:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    root.UTRichTextBlock_RankScore:SetText("")
    root.Common_RankIntegralLevel_Style_Small_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local SeasonSystem = require("client.logic.season.logic_season")
  local score, tag = SeasonSystem.GetChanllengeScoreAndFirstTag(zoneID, modeStr)
  local cfg = SeasonSystem.GetChanllengeCfg(segment)
  if not cfg or not score then
    root.CanvasPanel_Chanllenge:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  root.CanvasPanel_Chanllenge:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local mat = root.Image_ChanllengeProgress:GetDynamicMaterial()
  local util = require("client.slua_ui_framework.util")
  if score < cfg.AbleScore then
    util.SetTexture(root.Image_challengeIcon, inactiveChallengeIcon)
    root.Image_ChanllengeProgress:SetColorAndOpacity(FLinearColor(0.770833, 0.106352, 0.052192, 1))
  else
    util.SetTexture(root.Image_challengeIcon, activeChallengeIcon)
    root.Image_ChanllengeProgress:SetColorAndOpacity(FLinearColor(1, 0.509934, 0, 1))
  end
  if mat then
    mat:SetScalarParameterValue("Mask_Percent", SeasonSystem.CalChallengeProgressRate(score, cfg.MaxScore, cfg.AbleScore))
  end
end
function ModeSelection_Main_Segment:ShowChanllengeTip(root, filter_info)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.nChooseZoneID
  if zoneID == 0 then
    zoneID = 1
  end
  local segment, segmentData, modeStr = self:GetSegmentData(filter_info, zoneID)
  if not segment then
    return
  end
  local UIUtil = require("client.common.ui_util")
  local tipPos = UIUtil.GetWidgetViewportPos(root.Button_Ratting)
  local helpTipsUI = UIManager.ShowUI(UIManager.UI_Config.Common_HelpTips_UIBP)
  if helpTipsUI then
    local SeasonSystem = require("client.logic.season.logic_season")
    local score, tag = SeasonSystem.GetChanllengeScoreAndFirstTag(zoneID, modeStr)
    local cfg = SeasonSystem.GetChanllengeCfg(segment)
    if cfg then
      local content = self:GetChallengeTip(cfg, score)
      log(bWriteLog and "ModeSelection_Main_Segment:ShowChanllengeTip tipPos.Y:" .. tostring(tipPos.Y + 250) .. " score:" .. tostring(score) .. " cfg.AbleScore:" .. tostring(cfg.AbleScore))
      helpTipsUI:ShowPanelStrWithPos(content, tipPos.X - 33, tipPos.Y + 250, true, true)
    end
  end
end
function ModeSelection_Main_Segment:GetChallengeTip(cfg, score)
  local version_util = require("client.common.version_util")
  local AppVersion = version_util.GetCurVersionNumber()
  log(bWriteLog and "logic_config_mission_select_mode.GetChallengeTip() AppVersion = " .. AppVersion)
  local content = ""
  if AppVersion == 4400 then
    local honorRate = 0
    local changeConfig = CDataTable.GetTableData("ParamTable", "honer_exchange_ratio")
    if changeConfig then
      honorRate = changeConfig.ParamValue
    end
    content = LocUtil.LocalizeResFormat(1102510293, cfg.Rate, 1, score, cfg.AbleScore, honorRate, 1)
  else
    content = LocUtil.LocalizeResFormat(2000014, cfg.Rate, 1, score, cfg.AbleScore)
  end
  return content
end
return ModeSelection_Main_Segment