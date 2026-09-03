local UnknowPassRankFirstWeekAwardsSystem = {
  RankFirstWeekAwards = {},
  RankFirstWeekEndTime = 0,
  RankFirstWeekInfos = {},
  RankFirstWeekTopMap = {}
}
function UnknowPassRankFirstWeekAwardsSystem.Release()
  log(bWriteLog and "UnknowPassRankFirstWeekAwardsSystem.Release")
  UnknowPassRankFirstWeekAwardsSystem.RankFirstWeekEndTime = 0
  UnknowPassRankFirstWeekAwardsSystem.RankFirstWeekInfos = {}
end
function UnknowPassRankFirstWeekAwardsSystem.HidePreviewPanel()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.unknowpass_rank_first_week_awards_preview)
  end
end
function UnknowPassRankFirstWeekAwardsSystem.ShowAwardPanel()
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.unknowpass_rank_first_week_awards)
  end
end
function UnknowPassRankFirstWeekAwardsSystem.HideAwardPanel()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.unknowpass_rank_first_week_awards)
  end
end
function UnknowPassRankFirstWeekAwardsSystem.InitFirstWeekRankAwards()
  UnknowPassRankFirstWeekAwardsSystem.RankFirstWeekAwards = {}
  local cfgTable = CDataTable.GetTableByFilter("UnknowPassRankFirstWeekAwards", "SeasonId", UnknowPassSystem.Season)
  for i, data in pairs(cfgTable) do
    local itemdata = {}
    itemdata.id = data.ID
    itemdata.itemId = data.ItemID
    itemdata.startRank = data.StartRank
    itemdata.endRank = data.EndRank
    UnknowPassRankFirstWeekAwardsSystem.RankFirstWeekAwards[itemdata.startRank] = data
  end
end
function UnknowPassRankFirstWeekAwardsSystem.GetWeekRankAwardsByIndex(index)
  if index == UnknowPassSystem.Season then
    return UnknowPassRankFirstWeekAwardsSystem.RankFirstWeekAwards
  end
  local Rankwards = {}
  local cfgTable = CDataTable.GetTableByFilter("UnknowPassRankFirstWeekAwards", "SeasonId", index)
  for i, data in pairs(cfgTable) do
    local itemdata = {}
    itemdata.id = data.ID
    itemdata.itemId = data.ItemID
    itemdata.startRank = data.StartRank
    itemdata.endRank = data.EndRank
    Rankwards[itemdata.startRank] = data
  end
  return Rankwards
end
function UnknowPassRankFirstWeekAwardsSystem.SetAward(itemId, itemBp)
  local cfg = CDataTable.GetTableData("AliasCfg", itemId)
  if cfg ~= nil then
    local aliasTitle = FuncUtil.Gen_title(itemId)
    local aliasQuality = cfg.AliasQuality - 1
    itemBp.WidgetSwitcher_Quality:SetActiveWidgetIndex(aliasQuality)
    itemBp.title:SetText(aliasTitle)
    local util = require("client.slua_ui_framework.util")
    local UIUtil = require("client.common.ui_util")
    local DefaultIcon = UIUtil.GetDefaultIcon(itemId)
    util.SetTexture(itemBp.icon, cfg.AliasIconPathSmall, {sync = false, defaultIcon = DefaultIcon})
    util.SetTexture(itemBp.current_iconBG, cfg.AliasIconPathBig, {sync = false, defaultIcon = DefaultIcon})
    util.SetTexture(itemBp.current_icon, cfg.AliasIconPath, {sync = false, defaultIcon = DefaultIcon})
  end
end
function UnknowPassRankFirstWeekAwardsSystem.InFirstWeek()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local endTime = UnknowPassRankFirstWeekAwardsSystem.GetFirstWeekRankEndTime()
  return nowTime < endTime
end
function UnknowPassRankFirstWeekAwardsSystem.GetFirstWeekRankEndTime()
  local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassSystem.Season)
  if cfg then
    local TimeUtil = require("client.common.time_util")
    local StartTime = TimeUtil.TimeStringToUnixstamp(cfg.ScoreRankEndTime)
    return tonumber(StartTime)
  end
  return 0
end
function UnknowPassRankFirstWeekAwardsSystem.SendHistoryTopReq(season_id)
  local seasonList = UnknowPassRankFirstWeekAwardsSystem.RankFirstWeekInfos[season_id]
  if seasonList and 0 < #seasonList then
    local idList = {}
    for i, v in pairs(seasonList) do
      table.insert(idList, tonumber(v.uid))
    end
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(idList, function(listInfo)
      for i, info in pairs(listInfo) do
        for index, data in pairs(seasonList) do
          if tonumber(data.uid) == info.uid then
            info.fw_rank_no = tonumber(data.fw_rank_no)
            info.fw_score = tonumber(data.fw_score)
            info.fw_keep_buy = tonumber(data.fw_keep_buy)
            break
          end
        end
      end
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_FIRST_WEEK_INFO_UPDATE, season_id, listInfo)
    end, 1041)
  else
    local PassHander = require("client.network.Protocol.PassHander")
    PassHander.send_upass_history_top_req(season_id)
  end
end
function UnknowPassRankFirstWeekAwardsSystem.OnHistoryTopRsp(season_id, top)
  log_tree("UnknowPassRankFirstWeekAwardsSystem.OnHistoryTopRsp", top)
  if top then
    local InfoList = {}
    local idList = {}
    for i, data in pairs(top) do
      UnknowPassRankFirstWeekAwardsSystem.RankFirstWeekTopMap[data.uid] = {
        rank = data.rank_no
      }
      local roleInfo = {}
      roleInfo.uid = tonumber(data.uid)
      roleInfo.fw_rank_no = tonumber(data.rank_no)
      roleInfo.fw_score = tonumber(data.score)
      roleInfo.fw_keep_buy = tonumber(data.keep_buy)
      table.insert(InfoList, roleInfo)
      table.insert(idList, tonumber(data.uid))
      if data.uid == DataMgr.roleData.uid and (nil == UnknowPassSystem.Data.top_rewarded or nil == UnknowPassSystem.Data.top_rewarded[season_id]) then
        local PassHander = require("client.network.Protocol.PassHander")
        PassHander.send_upass_top_reward_req(season_id)
      end
    end
    UnknowPassRankFirstWeekAwardsSystem.RankFirstWeekInfos[season_id] = InfoList
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(idList, function(listInfo)
      log_tree("--listInfo", listInfo)
      for i, info in pairs(listInfo) do
        for index, data in pairs(top) do
          if tonumber(data.uid) == info.uid then
            info.fw_rank_no = tonumber(data.rank_no)
            info.fw_score = tonumber(data.score)
            info.fw_keep_buy = tonumber(data.keep_buy)
            break
          end
        end
      end
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_FIRST_WEEK_INFO_UPDATE, season_id, listInfo)
    end, 1042)
  end
end
function UnknowPassRankFirstWeekAwardsSystem.OnTopRewardRsp(season_id, place, awards)
  local logic_post_switch_popup = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_post_switch_popup)
  logic_post_switch_popup:TryExecuteOne(BP_ENUM_MODULE_ALIAS_POPUP)
end
return UnknowPassRankFirstWeekAwardsSystem