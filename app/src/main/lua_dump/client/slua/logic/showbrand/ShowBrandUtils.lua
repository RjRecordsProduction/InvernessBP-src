local ShowBrandUtils = {}
local string_util = require("common.string_util")
function ShowBrandUtils.ParseTemplate(template)
  local result = {}
  for _, s in pairs(string_util.Split(template, "|")) do
    local t = {}
    result[#result + 1] = t
    for _, ss in pairs(string_util.Split(s, ";")) do
      local v = tonumber(ss)
      if v then
        t[#t + 1] = v
      else
        local two = string_util.Split(ss, "..")
        if #two == 2 then
          local b, e = tonumber(two[1]), tonumber(two[2])
          if b and e and b < e then
            for i = b, e do
              t[#t + 1] = i
            end
          end
        end
      end
    end
  end
  log_tree("ShowBrandUtils.ParseTemplate", result)
  return result
end
function ShowBrandUtils.GetDefaultSettings(templateId)
  local cfg = CDataTable.GetTableData("ShowBrandTemplateCfg", templateId)
  if not cfg then
    return nil
  end
  local arr = string_util.Split(cfg.Default, "|")
  local ids = {}
  for i, v in ipairs(arr) do
    ids[i] = tonumber(v)
  end
  return ids
end
function ShowBrandUtils.GetDataOpCfgList(ShowBrandTemplateCfg, slotIndex)
  assert(ShowBrandTemplateCfg, "ShowBrandTemplateCfg is nil")
  local arr = ShowBrandUtils.ParseTemplate(ShowBrandTemplateCfg.Content)
  local ids = arr[slotIndex]
  assert(ids, "ShowBrandUtils.GetDataOpCfgList ids is nil")
  printf("ShowBrandUtils.GetDataOpCfgList ids: %s", table.concat(ids, ","))
  local items = {}
  for i, id in ipairs(ids) do
    local cfg = CDataTable.GetTableData("ShowBrandDataOpCfg", id)
    items[#items + 1] = cfg
  end
  return items
end
function ShowBrandUtils.SetMultiIconDisplay(slotWidget, dataTypeId, nUID, profile, dataVal)
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  local id = dataTypeId
  if id == ShowBrandConst.ShowType.TreasureLevel then
    slotWidget.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    if not profile.collect_data or not next(profile.collect_data) then
      printf("ShowBrandUtils.SetMultiIconDisplay collect_data is nil. uid: %d", nUID)
      return
    end
    local total_score, season_score = collect_module:GetCollectScoreByProfile(profile)
    local curLevel, dan = collect_module:GetLevelByScore(total_score)
    local sLevel = collect_module:GetSeasonLevelByScore(season_score)
    local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
    slotWidget.Collect_Level_Item_UIBP:InitExquisiteCollectBadge(nUID, {
      seasonLevel = sLevel,
      rank = dan,
      totalLevel = curLevel,
      animationType = collect_cfg.E_CollectBadge_AnimaType.None
    })
  elseif id == ShowBrandConst.ShowType.HighestLevel then
    slotWidget.WidgetSwitcher_0:SetActiveWidgetIndex(2)
    printf("ShowBrandUtils.SetMultiIconDisplay history_max_segment_level: %s", profile.history_max_segment_level)
    local inner = function()
      local historyRanks = profile.history_max_segment_level
      local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
      local historyHigestRank, historySeasonId = RoleInfoMainSystem.GetHistotyMaxSegmentAndSeasonId(historyRanks, profile.history_max_segment_season_id)
      slotWidget.Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteralBySeason(historyHigestRank or 101, nil, historySeasonId)
    end
    if profile.history_max_segment_level then
      inner()
    else
      do
        local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
        local report = Enum_PROFILE_REPORT_CFG.PLACARD_LOBBY
        logic_profile_get_wrap.GetNormalProfiles({nUID}, function()
          if slua.isValid(slotWidget) then
            local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
            profile = logic_profile:GetLocalProfile(nUID)
            inner()
          end
        end, report, 4, false)
      end
    end
  elseif id == ShowBrandConst.ShowType.CurrentLevel then
    slotWidget.WidgetSwitcher_0:SetActiveWidgetIndex(2)
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    local zoneId = ZoneSystem.nChooseZoneID
    if zoneId == 0 then
      zoneId = 1
    end
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local curTppScore = RoleInfoSystem.CurrSeasonTPPTotalScore[zoneId] or 0
    local curTppRank = RoleInfoSystem.CurrSeasonTPPTotalRank[zoneId] or ""
    local curFppScore = RoleInfoSystem.CurrSeasonFPPTotalScore[zoneId] or 0
    local curFppRank = RoleInfoSystem.CurrSeasonFPPTotalRank[zoneId] or ""
    if curTppScore == 0 or curTppRank == "" or curFppScore == 0 or curFppRank == "" then
      return
    end
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local rankShowType = RoleInfoMainSystem.GetRankShowType()
    local playersType, segment = RoleInfoMainSystem.GetMaxSegmentInfo(rankShowType)
    slotWidget.Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteral(segment or 101, nil)
  elseif id == ShowBrandConst.ShowType.CurrentCycleMark then
    slotWidget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    local bSelf = tonumber(nUID) == tonumber(DataMgr.roleData.uid)
    log(bWriteLog and "ShowBrandUtils.SetMultiIconDisplay bSelf = " .. tostring(bSelf))
    local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
    local ace_show_type
    if bSelf then
      ace_show_type = LobbySystem.roleData.ace_show_type
    else
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(nUID)
      if profile then
        ace_show_type = profile.ace_show_type
      end
    end
    log(bWriteLog and "ShowBrandUtils.SetMultiIconDisplay ace_show_type = " .. tostring(ace_show_type))
    if ace_show_type and ace_show_type == ace_config.EAceShowType.PeakGame then
      local ace_util = require("client.logic.season.ace.ace_util")
      local peakgame_ace_id, peakgame_ace_count = ace_util.GetPeakGameAceData(nUID)
      if peakgame_ace_id and 0 < peakgame_ace_count then
        slotWidget.WidgetSwitcher_1:SetActiveWidgetIndex(0)
        ace_util.SetPeakGameAceImage(slotWidget.Common_KingMark_UIBP, peakgame_ace_id, peakgame_ace_count)
      else
        slotWidget.WidgetSwitcher_1:SetActiveWidgetIndex(1)
      end
    elseif ace_show_type and ace_show_type == ace_config.EAceShowType.Honer then
      ShowBrandUtils.SetHonerImprint(slotWidget, nUID)
    elseif ace_show_type == nil then
      local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
      local ace_imprint_show_id, ace_imprint_base_id, ace_imprint_show_cnt = LobbySocialSystem.GetAceImprintShowId(nUID)
      if ace_imprint_base_id then
        local ace_util = require("client.logic.season.ace.ace_util")
        if ace_util.IsHonerImprint(ace_imprint_base_id) then
          ShowBrandUtils.SetHonerImprint(slotWidget, nUID)
        else
          ShowBrandUtils.SetClassicalImprint(slotWidget, nUID)
        end
      else
        ShowBrandUtils.SetClassicalImprint(slotWidget, nUID)
      end
    else
      ShowBrandUtils.SetClassicalImprint(slotWidget, nUID)
    end
  elseif id == ShowBrandConst.ShowType.PeakGameLevel then
    slotWidget.WidgetSwitcher_0:SetActiveWidgetIndex(3)
    local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
    local peakgame_segment_id = LogicPeakGameSegmentUtil.GetProfileCurMaxSegmentId(profile)
    if peakgame_segment_id then
      slotWidget.WidgetSwitcher_2:SetActiveWidgetIndex(0)
      local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
      local PeakGame_RankIntegralLevel_Style_Large_UIBP = UIComponentModule:InitWithoutParentComponent(UIComponentModule.Config.PeakGame_RankIntegralLevel_Style_Large_UIBP, slotWidget.PeakGame_RankIntegralLevel_Style_Large_UIBP)
      PeakGame_RankIntegralLevel_Style_Large_UIBP:SetPeakRankIntegral(peakgame_segment_id)
    else
      slotWidget.WidgetSwitcher_2:SetActiveWidgetIndex(1)
    end
  elseif id == ShowBrandConst.ShowType.BanLevel then
    slotWidget.WidgetSwitcher_0:SetActiveWidgetIndex(4)
    local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
    local Icon = PatrollerModule:GetPatrollerIconPath(dataVal)
    if Icon then
      local util = require("client.slua_ui_framework.util")
      util.SetTexture(slotWidget.Image_BanLevel, Icon)
      slotWidget.WidgetSwitcher_BanLevel:SetActiveWidgetIndex(0)
    else
      slotWidget.WidgetSwitcher_BanLevel:SetActiveWidgetIndex(1)
    end
  else
    slotWidget.WidgetSwitcher_0:SetActiveWidgetIndex(5)
    log_error("ShowBrandUtils.SetMultiIconDisplay unknown show type: " .. tostring(id))
  end
end
function ShowBrandUtils.SetClassicalImprint(slotWidget, nUID)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local ace_imprint_show_id, ace_imprint_base_id = LobbySocialSystem.GetAceImprintShowId(nUID)
  if ace_imprint_show_id == nil then
    slotWidget.WidgetSwitcher_1:SetActiveWidgetIndex(1)
  else
    slotWidget.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    local AceImprintLogic = require("client.logic.season.AceImprintLogic")
    AceImprintLogic.SetAceImprintImage(slotWidget.Common_KingMark_UIBP, ace_imprint_show_id, ace_imprint_base_id)
  end
end
function ShowBrandUtils.SetHonerImprint(slotWidget, nUID)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local ace_imprint_show_id, ace_imprint_base_id, ace_imprint_show_cnt = LobbySocialSystem.GetAceImprintShowId(nUID)
  log(bWriteLog and "ShowBrandUtils.SetMultiIconDisplay ace_imprint_show_id:" .. tostring(ace_imprint_show_id))
  log(bWriteLog and "ShowBrandUtils.SetMultiIconDisplay ace_imprint_base_id:" .. tostring(ace_imprint_base_id))
  log(bWriteLog and "ShowBrandUtils.SetMultiIconDisplay ace_imprint_show_cnt:" .. tostring(ace_imprint_show_cnt))
  if ace_imprint_show_id == nil then
    slotWidget.WidgetSwitcher_1:SetActiveWidgetIndex(1)
  else
    local season_year_util = require("client.logic.season_year.util.season_year_util")
    if season_year_util.CheckFunctionIsOpen() and slotWidget.Common_KingMark_UIBP_2 then
      slotWidget.WidgetSwitcher_1:SetActiveWidgetIndex(2)
      local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
      local Common_KingMark_UIBP_2 = UIComponentModule:InitWithoutParentComponent(UIComponentModule.Config.Common_KingMark_UIBP_2, slotWidget.Common_KingMark_UIBP_2)
      local advance_num = 0
      local history_num = 0
      if ace_imprint_show_cnt and 0 < ace_imprint_show_cnt then
        advance_num = ace_imprint_show_id - ace_imprint_base_id
        history_num = ace_imprint_show_cnt - advance_num
      end
      if Common_KingMark_UIBP_2 then
        Common_KingMark_UIBP_2:SetWidgetInfo(ace_imprint_base_id, {advance_num = advance_num, history_num = history_num})
      end
    else
      slotWidget.WidgetSwitcher_1:SetActiveWidgetIndex(1)
    end
  end
end
function ShowBrandUtils.PlayEmote(uid)
  uid = uid or tonumber(DataMgr.roleData.uid)
  printf("ShowBrandUtils.PlayEmote uid: %s", uid)
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  local emote = ShowBrandConst.GeneralEmoteId
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local isInXMission = XMissionSystem.IsInXMission()
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local bCanPlay = true
  if isInXMission then
    bCanPlay = XMissionAvatarMgr.PlayAction(uid, emote)
  else
    bCanPlay = LobbyAvatarManager.PlayEmoteAction(uid, emote)
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and bCanPlay then
    TeamUpNewSystem.team_player_action(emote, 0)
  end
end
function ShowBrandUtils.PrepareEmoteData(uid, callback, step, forceReq)
  uid = tostring(uid)
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local cacheBrandInfo = LogicShowBrand:GetCacheBrandInfo(uid)
  if (not step or step < 1) and (not cacheBrandInfo or forceReq) then
    LogicShowBrand:GetOrRequestBrandInfo(uid, nil, function()
      ShowBrandUtils.PrepareEmoteData(uid, callback, 1, forceReq)
    end)
    return false
  end
  if not cacheBrandInfo then
    log_error("ShowBrandUtils.PrepareEmoteData step = " .. tostring(step))
    return false
  end
  local profileUIDList = {uid}
  local needReqUIDList = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, v in pairs(profileUIDList) do
    local profile = logic_profile:GetLocalProfile(v)
    if not profile or not profile.history_max_segment_level then
      table.insert(needReqUIDList, v)
    end
  end
  if 0 < #needReqUIDList then
    if step == 3 then
      log_error("ShowBrandUtils.PrepareEmoteData step = " .. tostring(step))
      return false
    end
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    local report = Enum_PROFILE_REPORT_CFG.PLACARD_LOBBY
    if GameStatus.IsInFightingStatus() then
      report = Enum_PROFILE_REPORT_CFG.PLACARD_INGAME
    end
    printf("ShowBrandUtils.PrepareEmoteData no profile, uid:%s, report:%s", uid, report)
    logic_profile_get_wrap.GetNormalProfiles(needReqUIDList, function()
      printf("ShowBrandUtils.PrepareEmoteData get profile success, uid:%s", uid)
      ShowBrandUtils.PrepareEmoteData(uid, callback, 3, forceReq)
    end, report, 4, false)
    return false
  end
  callback()
  return true
end
local showWithPercent = {
  [615] = {bRound = true, format = "%.2f"},
  [618] = {multiplier = 100, suffix = "%"},
  [619] = {multiplier = 100, suffix = "%"},
  [620] = {multiplier = 100, suffix = "%"},
  [621] = {multiplier = 100, suffix = "%"}
}
function ShowBrandUtils.FormatValue(cfg, value)
  local formatCfg = showWithPercent[cfg.TextID]
  if formatCfg == nil or type(value) ~= "number" then
    return value
  end
  value = value * (formatCfg.multiplier or 1)
  local format = formatCfg.format or "%.0f"
  if formatCfg.suffix then
    value = string.format(format, value)
    value = value .. formatCfg.suffix
  elseif formatCfg.bRound then
    value = string.format(format, value)
  end
  return value
end
return ShowBrandUtils