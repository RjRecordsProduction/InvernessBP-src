local leisure_season_util = {}
function leisure_season_util.SetRankBigIcon(widget, rankID)
  if not leisure_season_util.CheckBigIconValid(widget) then
    log_warning("leisure_season_util.SetRankBigIcon widget not valid")
    return
  end
  local cfg = CDataTable.GetTableData("LeisureSeasonRankLevelCfg", rankID)
  if not cfg then
    log_warning(bWriteLog and "leisure_season_util.SetRankBigIcon not cfg, rankID = " .. tostring(rankID))
    return
  end
  if not cfg.BigIcon or cfg.BigIcon == "" then
    log_warning(bWriteLog and "leisure_season_util.SetRankBigIcon not BigIcon, rankID = " .. tostring(rankID))
    return
  end
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(widget.Image_Base, cfg.BigIcon)
end
function leisure_season_util.CheckBigIconValid(widget)
  if not widget then
    return false
  end
  if not widget.Image_Base then
    return false
  end
  return true
end
function leisure_season_util:SetLeisureReddotByType(reddotType, count)
  log(bWriteLog and "leisure_season_util:SetLeisureReddotByType reddotType = " .. tostring(reddotType) .. " count = " .. tostring(count))
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  if not logic_leisure_season:IsLeisureSeasonOpen() then
    log(bWriteLog and "leisure_season_util:SetLeisureReddotByType leisure season is closed, set count = 0")
    count = 0
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local redpoint = season_redpoint_data.GetRedData()
  local ReddotType = season_redpoint_data.ReddotType
  if redpoint then
    if redpoint.types[reddotType] then
      log(bWriteLog and "leisure_season_util:SetLeisureReddotByType 1")
      redpoint.types[reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[reddotType] then
      log(bWriteLog and "leisure_season_util:SetLeisureReddotByType 2")
      redpoint.types[ReddotType.seasonCombReward].types[reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.leisureSeasonEntry].types[reddotType] then
      log(bWriteLog and "leisure_season_util:SetLeisureReddotByType 3")
      redpoint.types[ReddotType.seasonCombReward].types[ReddotType.leisureSeasonEntry].types[reddotType].newCount = count
    end
  end
end
function leisure_season_util:GetLeisureReddotByType(reddotType)
  log(bWriteLog and "leisure_season_util:GetLeisureReddotByType reddotType = " .. tostring(reddotType))
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local redpoint = season_redpoint_data.GetRedData()
  local ReddotType = season_redpoint_data.ReddotType
  if redpoint then
    if redpoint.types[reddotType] then
      log(bWriteLog and "leisure_season_util:GetLeisureReddotByType 1")
      return redpoint.types[reddotType]
    elseif redpoint.types[ReddotType.seasonCombReward].types[reddotType] then
      log(bWriteLog and "leisure_season_util:GetLeisureReddotByType 2")
      return redpoint.types[ReddotType.seasonCombReward].types[reddotType]
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.leisureSeasonEntry].types[reddotType] then
      log(bWriteLog and "leisure_season_util:GetLeisureReddotByType 3")
      return redpoint.types[ReddotType.seasonCombReward].types[ReddotType.leisureSeasonEntry].types[reddotType]
    end
  end
  log(bWriteLog and "leisure_season_util:GetLeisureReddotByType not find reddot type")
  return nil
end
return leisure_season_util