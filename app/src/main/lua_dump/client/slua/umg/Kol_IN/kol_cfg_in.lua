local kol_cfg_in = {}
kol_cfg_in.mainTabCfg = {
  [1] = {
    tabId = kol_const.page_id_kol_list,
    textId = 20020023
  },
  [2] = {
    tabId = kol_const.page_id_my_kol,
    textId = 20020024
  },
  [3] = {
    tabId = kol_const.page_id_top_fans,
    textId = 20020025
  }
}
function kol_cfg_in.GetMainTabCfg()
  return kol_cfg_in.mainTabCfg
end
kol_cfg_in.kolListTabCfg = {
  [1] = {
    tabId = kol_const.page_id_kol_list_this_week,
    textId = 20020021
  },
  [2] = {
    tabId = kol_const.page_id_kol_list_this_season,
    textId = 20020022
  },
  [3] = {
    tabId = kol_const.page_id_kol_list_historical_season,
    textId = 20020010
  }
}
function kol_cfg_in.GetKolListTabCfg()
  return kol_cfg_in.kolListTabCfg
end
kol_cfg_in.TabToPageConfig = {
  [kol_const.page_id_kol_list] = {
    default = "kol_list_page_new"
  },
  [kol_const.page_id_my_kol] = {
    default = "my_kol_page"
  },
  [kol_const.page_id_top_fans] = {
    default = "top_fans_page"
  }
}
function kol_cfg_in.GetPageConfigByTabId(tabId)
  local configName = kol_cfg_in.TabToPageConfig and kol_cfg_in.TabToPageConfig[tabId] and kol_cfg_in.TabToPageConfig[tabId].default
  return UIManager.UI_Config[configName]
end
kol_cfg_in.RankListDescription = {
  [kol_const.page_id_top_fans] = {
    TextBlock_rank = 20020033,
    TextBlock_avatar = 20020034,
    TextBlock_kol_score = 20020035,
    TextBlock_wins = 0,
    TextBlock_kills = 20020036,
    TextBlock_fan_score = 0
  }
}
function kol_cfg_in.GetDescriptionListByTabId(tabId)
  return kol_cfg_in.RankListDescription[tabId]
end
function kol_cfg_in.GetClientVersionAndRegionStatus()
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  local region = FuncUtil.GetAccountRegionForBP()
  log(bWriteLog and "xcc kol_cfg_in.GetClientVersionAndRegionStatus region:" .. tostring(region))
  if GlobalData.IsJapanOrKorea() then
    log(bWriteLog and "xcc kol_cfg_in.GetClientVersionAndRegionStatus Client IsJapanOrKorea: true")
    if region == AccountRegionForBPMacros.JP then
      return kol_const.ClientVersionAndRegionStatus_JP
    elseif region == AccountRegionForBPMacros.KR then
      return kol_const.ClientVersionAndRegionStatus_KR
    end
  end
  if GlobalData.IsBLUEHOLE() then
    log(bWriteLog and "xcc kol_cfg_in.GetClientVersionAndRegionStatus Client IsBLUEHOLE: true")
    if region == AccountRegionForBPMacros.IN then
      return kol_const.ClientVersionAndRegionStatus_IN
    end
  end
  return kol_const.ClientVersionAndRegionStatus_Default
end
function kol_cfg_in.GetTabNameByRegionId(tabName)
  local state = kol_cfg_in.GetClientVersionAndRegionStatus()
  if state == kol_const.ClientVersionAndRegionStatus_IN then
    return tabName
  elseif state == kol_const.ClientVersionAndRegionStatus_JP then
    return tabName .. "_JP"
  elseif state == kol_const.ClientVersionAndRegionStatus_KR then
    return tabName .. "_KR"
  end
  return ""
end
kol_cfg_in.kolTeamCfg = nil
function kol_cfg_in.GetTeamCfgByTeamId(team_id)
  return CDataTable.GetTableDataByFilter(kol_cfg_in.GetTabNameByRegionId("KOL_Leaderboard_Team"), "team_id", team_id)
end
kol_cfg_in.kolSeasonCfg = nil
function kol_cfg_in.GetAllSeasonCfg()
  if not kol_cfg_in.kolSeasonCfg then
    kol_cfg_in.kolSeasonCfg = CDataTable.GetTable(kol_cfg_in.GetTabNameByRegionId("KOL_Leaderboard_Season"))
  end
  return kol_cfg_in.kolSeasonCfg
end
function kol_cfg_in.GetSeasonCfgBySeasonId(season_id)
  kol_cfg_in.GetAllSeasonCfg()
  return kol_cfg_in.kolSeasonCfg[season_id]
end
kol_cfg_in.kolAwardCfg = nil
function kol_cfg_in.GetKolLevelAwardBySeasonId(season_id)
  if not kol_cfg_in.kolAwardCfg then
    kol_cfg_in.kolAwardCfg = {}
  end
  if not kol_cfg_in.kolAwardCfg[season_id] then
    local configs = CDataTable.GetTableByFilter(kol_cfg_in.GetTabNameByRegionId("KOL_Leaderboard_Award"), "season_id", season_id)
    kol_cfg_in.kolAwardCfg[season_id] = {}
    for index, config in pairs(configs) do
      table.insert(kol_cfg_in.kolAwardCfg[season_id], {
        config = config,
        awardState = kol_const.kol_award_can_not_get
      })
    end
  end
  return kol_cfg_in.kolAwardCfg[season_id]
end
kol_cfg_in.otherCfg = nil
function kol_cfg_in.GetAllOtherCfg()
  if not kol_cfg_in.otherCfg then
    kol_cfg_in.otherCfg = CDataTable.GetTable(kol_cfg_in.GetTabNameByRegionId("KOL_Leaderboard_Other"))
  end
  return kol_cfg_in.otherCfg
end
function kol_cfg_in.GetOneOtherCfgByName(name)
  kol_cfg_in.GetAllOtherCfg()
  return kol_cfg_in.otherCfg[name]
end
kol_cfg_in.scoreTipConfig = nil
function kol_cfg_in.GetOneScoreTipCfgBySeasonId(season_id)
  if not kol_cfg_in.scoreTipConfig then
    kol_cfg_in.scoreTipConfig = {}
  end
  if not kol_cfg_in.scoreTipConfig[season_id] then
    local scoreTipConfig = CDataTable.GetTableByFilter(kol_cfg_in.GetTabNameByRegionId("KOL_Leaderboard_Award_Tip"), "season_id", season_id)
    local datas = {}
    for index, data in pairs(scoreTipConfig) do
      local award_list = {}
      for i = 1, 4 do
        local itemId = data["award" .. i]
        if itemId and 0 < itemId then
          table.insert(award_list, {
            itemId = itemId,
            count = data["count" .. i],
            valid = data["valid" .. i]
          })
        end
      end
      table.insert(datas, {config = data, award_list = award_list})
    end
    kol_cfg_in.scoreTipConfig[season_id] = datas
  end
  return kol_cfg_in.scoreTipConfig[season_id]
end
function kol_cfg_in.GetImageConfigsByModuleName(moduleName, season_id)
  if not kol_cfg_in.imageCfg then
    kol_cfg_in.imageCfg = {}
  end
  if not kol_cfg_in.imageCfg[moduleName] then
    kol_cfg_in.imageCfg[moduleName] = {}
    local configs = CDataTable.GetTableByFilter(kol_cfg_in.GetTabNameByRegionId("KOL_Leaderboard_BG_Asset"), "module_name", moduleName, "season_id", season_id)
    for index, config in pairs(configs) do
      if config.image_root ~= "" then
        kol_cfg_in.imageCfg[moduleName][config.image_root] = config.image_path
      end
    end
  end
  return kol_cfg_in.imageCfg[moduleName]
end
return kol_cfg_in