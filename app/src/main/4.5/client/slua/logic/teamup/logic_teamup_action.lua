local logic_teamup_action = {
  needPlayActionUidMap = {},
  playedActionUidMap = {},
  ActionEnum = {
    GoldenSuit = 0,
    Segment = 1,
    Popularity = 2,
    Pround = 3,
    PeakGame = 4
  },
  PopularityEffectIDList = {106, 107},
  ProundEffectIDList = {108, 109},
  MinTopEffectRank = 3,
  MinHighEffectRank = 10,
  CachedItemMap = nil
}
function logic_teamup_action.ParseItemCfg()
  log(bWriteLog and "[logic_teamup_action] ParseItemCfg")
  if logic_teamup_action.CachedItemMap and next(logic_teamup_action.CachedItemMap) then
    log(bWriteLog and "[logic_teamup_action] cached item map already exist")
    return
  end
  logic_teamup_action.CachedItemMap = {}
  local TeamupEntryParticleConfig = CDataTable.GetTable("TeamupEntryParticleConfig")
  for _, cfg in pairs(TeamupEntryParticleConfig) do
    logic_teamup_action.CachedItemMap[cfg.ItemID] = cfg.EffectType
  end
end
function logic_teamup_action.OnRecvMailItems(_, _, item_list)
  log(bWriteLog and "[logic_teamup_action] OnRecvMailItems")
  if not logic_teamup_action.CachedItemMap or not next(logic_teamup_action.CachedItemMap) then
    logic_teamup_action.ParseItemCfg()
  end
  for _, item_data in pairs(item_list) do
    if logic_teamup_action.CachedItemMap[tonumber(item_data.res_id)] then
      log(bWriteLog and "[logic_teamup_action] catch teamup action item: " .. tostring(item_data.res_id))
      local action_type = logic_teamup_action.CachedItemMap[tonumber(item_data.res_id)]
      local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
      logic_display_setting.SendChangeTeamUpActionSetting(action_type)
      break
    end
  end
end
function logic_teamup_action:AutoChangeActionType(teamup_action_type)
  log(bWriteLog and "[logic_teamup_action] AutoChangeActionType: " .. tostring(teamup_action_type))
  local bNeedReplace = false
  local actionType = tonumber(teamup_action_type)
  if actionType == logic_teamup_action.ActionEnum.Popularity then
    bNeedReplace = logic_teamup_action.GetPopularityActionItemID() == 0
  elseif actionType == logic_teamup_action.ActionEnum.Pround then
    bNeedReplace = logic_teamup_action.GetProundActionItemID() == 0
  elseif actionType and actionType > logic_teamup_action.ActionEnum.PeakGame then
    bNeedReplace = next(logic_teamup_action.GetLastPeakGameActionItemIDs()) == nil
  end
  if bNeedReplace then
    local auto_action_type = logic_teamup_action.ActionEnum.Segment
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if LogicXSuit.CheckHasEquipXSuit() then
      auto_action_type = logic_teamup_action.ActionEnum.GoldenSuit
    end
    log(bWriteLog and "[logic_teamup_action] auto change action to: " .. tostring(auto_action_type))
    local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
    logic_display_setting.SendChangeTeamUpActionSetting(auto_action_type)
  end
end
function logic_teamup_action.OnInitTeamUpAction(teamup_action_type)
  log(bWriteLog and "[logic_teamup_action] OnInitTeamUpAction: " .. tostring(teamup_action_type))
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  logic_display_setting.UpdateTeamUpActionSetting(teamup_action_type)
end
function logic_teamup_action.ProcessTeammateInfo(info)
  log(bWriteLog and "logic_teamup_action.ProcessTeammateInfo")
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  log(bWriteLog and "logic_teamup_action.ProcessTeammateInfo 2")
  local team_  if team_info == nil then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    team_info = TeamUpNewSystem.teamInfo
  end
  if not (team_info.members and team_info.player_count) or team_info.player_count <= 1 then
    logic_teamup_action.ClearActionData()
    return
  end
  for _, member_info in pairs(team_info.members) do
    local action_detail = logic_teamup_action.ProcessTeammateAction(member_info)
    if action_detail then
      logic_teamup_action.needPlayActionUidMap[member_info.uid] = {
        action_detail = action_detail,
        action_type = tonumber(member_info.teamup_action_type) or 0
      }
    else
      logic_teamup_action.needPlayActionUidMap[member_info.uid] = nil
    end
  end
  log_tree("logic_teamup_action.ProcessTeammateInfo", logic_teamup_action.needPlayActionUidMap)
end
function logic_teamup_action.ProcessTeammateAction(member_info)
  if not member_info then
    log(bWriteLog and "[logic_teamup_action] nil member info")
    return
  end
  local action_type = tonumber(member_info.teamup_action_type) or 0
  if action_type == logic_teamup_action.ActionEnum.GoldenSuit then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    local action_id = LogicXSuit.GetXSuitTeamupAction(member_info)
    if action_id then
      return {action_id = action_id, bRealGoldenSuit = false}
    else
      local realGoldenSuitActionID = logic_teamup_action.GetRealGoldenSuitTeamupAction(member_info)
      if realGoldenSuitActionID ~= 0 then
        return {action_id = realGoldenSuitActionID, bRealGoldenSuit = true}
      else
        return logic_teamup_action.GetSegmentTeamupAction(member_info)
      end
    end
  elseif action_type == logic_teamup_action.ActionEnum.Segment then
    return logic_teamup_action.GetSegmentTeamupAction(member_info)
  elseif action_type == logic_teamup_action.ActionEnum.Popularity then
    return logic_teamup_action.GetPopularityRankTeamupAction(member_info)
  elseif action_type == logic_teamup_action.ActionEnum.Pround then
    return logic_teamup_action.GetProundRankTeamupAction(member_info)
  elseif action_type > logic_teamup_action.ActionEnum.PeakGame and CDataTable.GetTableData("EmoteBPTable", action_type) then
    local cfg = CDataTable.GetTableData("EmoteBPTable", action_type)
    return {
      effect_ui = {
        UI_Config = UIManager.UI_Config.BP_PeakGameUIEffect_New,
        params = {itemID = action_type},
        res = cfg.Path
      }
    }
  else
    log(bWriteLog and "[logic_teamup_action] unknow action type: ", tostring(action_type))
  end
end
function logic_teamup_action.GetSegmentTeamupAction(member_info)
  if not member_info then
    log(bWriteLog and "[logic_teamup_action] nil member info")
    return
  end
  if tonumber(member_info.teamup_action_type) ~= logic_teamup_action.ActionEnum.Segment and tonumber(member_info.teamup_action_type) ~= logic_teamup_action.ActionEnum.GoldenSuit then
    log(bWriteLog and "[logic_teamup_action] action type not match: " .. tostring(member_info.teamup_action_type))
    return
  end
  local last_season_max_segment = member_info.last_season_max_segment
  if last_season_max_segment == nil then
    return
  end
  local action_id, effect_id
  local seasonid = tonumber(DataMgr.season_id)
  if seasonid and seasonid <= 8 then
    if 801 <= last_season_max_segment then
      log(bWriteLog and "GetSegmentTeamupAction last_season_max_segment >= 801 team actionID:2202401")
      action_id = 2202401
      effect_id = 3
    end
  elseif 601 <= last_season_max_segment then
    log(bWriteLog and "GetSegmentTeamupAction last_season_max_segment >= 601 team actionID:2202401")
    action_id = 2202401
    local last_active_season_id = member_info.last_active_season_id
    if 47 <= last_active_season_id then
      if 801 <= last_season_max_segment then
        effect_id = 203
      elseif 720 <= last_season_max_segment then
        effect_id = 202
      elseif 715 <= last_season_max_segment then
        effect_id = 201
      elseif 701 <= last_season_max_segment then
        effect_id = 200
      else
        effect_id = 100
      end
    elseif last_active_season_id and 20 <= last_active_season_id then
      if 801 <= last_season_max_segment then
        effect_id = 104
      elseif 720 <= last_season_max_segment then
        effect_id = 103
      elseif 715 <= last_season_max_segment then
        effect_id = 102
      elseif 701 <= last_season_max_segment then
        effect_id = 101
      else
        effect_id = 100
      end
    else
      local levelIndex = math.floor(last_season_max_segment / 100) - 6
      if levelIndex == 0 then
        effect_id = 1
      elseif levelIndex == 1 then
        effect_id = 2
      elseif levelIndex == 2 then
        effect_id = 3
      end
    end
  end
  return {action_id = action_id, effect_id = effect_id}
end
function logic_teamup_action.GetPopularityRankTeamupAction(member_info)
  if not member_info then
    log(bWriteLog and "[logic_teamup_action] nil member info")
    return
  end
  if tonumber(member_info.teamup_action_type) ~= logic_teamup_action.ActionEnum.Popularity then
    log(bWriteLog and "[logic_teamup_action] action type not match: " .. tostring(member_info.teamup_action_type))
    return
  end
  if not (member_info.rank_info and member_info.rank_info.popularity_rank) or member_info.rank_info.popularity_rank <= 0 then
    log(bWriteLog and "[logic_teamup_action] member not in popularity rank")
    return
  end
  local effect_id
  local member_rank = member_info.rank_info.popularity_rank
  if member_rank <= logic_teamup_action.MinTopEffectRank then
    effect_id = logic_teamup_action.PopularityEffectIDList[1]
  elseif member_rank <= logic_teamup_action.MinHighEffectRank then
    effect_id = logic_teamup_action.PopularityEffectIDList[2]
  end
  return {
    action_id = 2202401,
    effect_id = effect_id,
    notice_text = LocUtil.LocalizeResFormat(45861, member_info.rank_info.popularity_rank)
  }
end
function logic_teamup_action.GetProundRankTeamupAction(member_info)
  if not member_info then
    log(bWriteLog and "[logic_teamup_action] nil member info")
    return
  end
  if tonumber(member_info.teamup_action_type) ~= logic_teamup_action.ActionEnum.Pround then
    log(bWriteLog and "[logic_teamup_action] action type not match: " .. tostring(member_info.teamup_action_type))
    return
  end
  if not (member_info.rank_info and member_info.rank_info.pround_rank) or member_info.rank_info.pround_rank <= 0 then
    log(bWriteLog and "[logic_teamup_action] member not in pround rank")
    return
  end
  local effect_id
  local member_rank = member_info.rank_info.pround_rank
  if member_rank <= logic_teamup_action.MinTopEffectRank then
    effect_id = logic_teamup_action.ProundEffectIDList[1]
  elseif member_rank <= logic_teamup_action.MinHighEffectRank then
    effect_id = logic_teamup_action.ProundEffectIDList[2]
  end
  return {
    action_id = 2202401,
    effect_id = effect_id,
    notice_text = LocUtil.LocalizeResFormat(45862, member_info.rank_info.pround_rank)
  }
end
function logic_teamup_action.GetRealGoldenSuitTeamupAction(member_info)
  local realGoldenSuitActionID = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if member_info.uid == tonumber(DataMgr.roleData.uid) then
    local tRoleWear = AvatarData.GetRoleWear()
    for _, instId in pairs(tRoleWear) do
      local data = wardrobe_data:GetHallDepotItemDataByInsID(instId)
      if data and data.resID then
        local Cfg = CDataTable.GetTableData("RealGoldenSuitFeature", data.resID)
        if Cfg then
          realGoldenSuitActionID = Cfg.TemmupEmote
          break
        end
      end
    end
  elseif member_info.wear_ext and member_info.wear_ext[3] and member_info.wear_ext[3][1] then
    local Cfg = CDataTable.GetTableData("RealGoldenSuitFeature", member_info.wear_ext[3][1])
    if Cfg then
      realGoldenSuitActionID = Cfg.TemmupEmote
    end
  end
  return realGoldenSuitActionID
end
function logic_teamup_action.ClearActionData()
  logic_teamup_action.needPlayActionUidMap = {}
  logic_teamup_action.playedActionUidMap = {}
end
function logic_teamup_action.GetPopularityActionItemID()
  local item_id = 0
  local TeamupEntryParticleConfig = CDataTable.GetTable("TeamupEntryParticleConfig")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, cfg in pairs(TeamupEntryParticleConfig) do
    if cfg.EffectType == logic_teamup_action.ActionEnum.Popularity and wardrobe_data:HasValidItem(cfg.ItemID) then
      item_id = cfg.ItemID
      break
    end
  end
  return item_id
end
function logic_teamup_action.GetProundActionItemID()
  local item_id = 0
  local TeamupEntryParticleConfig = CDataTable.GetTable("TeamupEntryParticleConfig")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, cfg in pairs(TeamupEntryParticleConfig) do
    if cfg.EffectType == logic_teamup_action.ActionEnum.Pround and wardrobe_data:HasValidItem(cfg.ItemID) then
      item_id = cfg.ItemID
      break
    end
  end
  return item_id
end
function logic_teamup_action.GetLastPeakGameActionItemIDs()
  local TeamupEntryParticleConfig = CDataTable.GetTableByFilter("TeamupEntryParticleConfig", "EffectType", logic_teamup_action.ActionEnum.PeakGame)
  local itemList = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, cfg in pairs(TeamupEntryParticleConfig) do
    if wardrobe_data:HasValidItem(cfg.ItemID) then
      table.insert(itemList, cfg.ItemID)
    end
  end
  return itemList
end
function logic_teamup_action.GetEffectConfigByItemID(item_id)
  if not item_id or item_id == 0 then
    log(bWriteLog and "[logic_teamup_action] nil item id for effect config")
    return
  end
  local TeamupEntryParticleConfig = CDataTable.GetTable("TeamupEntryParticleConfig")
  for _, effect_cfg in pairs(TeamupEntryParticleConfig) do
    if effect_cfg.ItemID == item_id then
      return effect_cfg
    end
  end
  log(bWriteLog and "[logic_teamup_action] nil effect config for item: " .. tostring(item_id))
end
function logic_teamup_action.EquipActionByItemID(item_id)
  log(bWriteLog and "[logic_teamup_action] EquipActionByItemID: " .. tostring(item_id))
  if not item_id or item_id == 0 then
    return
  end
  local effect_cfg
  local TeamupEntryParticleConfig = CDataTable.GetTable("TeamupEntryParticleConfig")
  for _, cfg in pairs(TeamupEntryParticleConfig) do
    if cfg.ItemID == item_id then
      effect_    end
  end
  if effect_cfg then
    local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
    logic_display_setting.SendChangeTeamUpActionSetting(effect_cfg.EffectType)
  end
end
function logic_teamup_action.PlayTeamupAction(uid)
  log(bWriteLog and "logic_teamup_action.PlayTeamupAction " .. tostring(uid))
  if not uid then
    log(bWriteLog and "[logic_teamup_action] nil member info")
    return
  end
  local action_info = logic_teamup_action.needPlayActionUidMap[uid]
  if not action_info or not action_info.action_detail then
    log(bWriteLog and "[logic_teamup_action] not need play action")
    return
  end
  local gc_util = require("common.gc_util")
  if gc_util.IsNeedDropAvatarFeature(2) then
    return
  end
  logic_teamup_action.playedActionUidMap[uid] = true
  if action_info.action_type == logic_teamup_action.ActionEnum.GoldenSuit and not action_info.action_detail.bRealGoldenSuit then
    log(bWriteLog and "logic_teamup_action.PlayTeamupAction SetPlayedActionUid")
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.SetPlayedActionUid(uid)
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  if action_info.action_type == logic_teamup_action.ActionEnum.GoldenSuit or action_info.action_type == logic_teamup_action.ActionEnum.Segment then
    TeamAvatarManager.PlayGoldenSuitOrSegmentAction(uid, action_info.action_detail)
  else
    TeamAvatarManager.PlayTeamupAction(uid, action_info.action_detail)
  end
end
return logic_teamup_action