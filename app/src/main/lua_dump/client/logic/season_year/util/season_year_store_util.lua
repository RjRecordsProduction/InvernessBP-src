local season_year_store_util = {}
function season_year_store_util.GetSeasonYearStoreCfg(filtype)
  log(bWriteLog and "season_year_store_util.GetSeasonShopCfg filtype = " .. tostring(filtype))
  local TableUtil = require("common.table_util")
  local logic_season_shop_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_shop_system)
  local seasonShopCfg = {}
  local season_shop_cfg = require("client.logic.season.season_shop.config.season_shop_cfg")
  for key, value in pairs(logic_season_shop_system.seasonShopConfig or {}) do
    if value.type == 3 then
      local item_cfg = CDataTable.GetTableData("Item", key)
      if item_cfg then
        local subItemCfg = TableUtil.CopyTable(value)
        subItemCfg.itemID = key
        subItemCfg.itemQuality = item_cfg.ItemQuality or 1
        subItemCfg.ItemType = item_cfg.ItemType
        season_year_store_util.SetItemSortFlag(subItemCfg)
        local season_year_config = require("client.logic.season_year.config.season_year_config")
        if filtype == season_year_config.EStoreFilter.All then
          table.insert(seasonShopCfg, subItemCfg)
        else
          local bisOwn = season_year_store_util.CheckItemIsHas(subItemCfg)
          if bisOwn and filtype == season_year_config.EStoreFilter.Own then
            table.insert(seasonShopCfg, subItemCfg)
          elseif not bisOwn and filtype == season_year_config.EStoreFilter.NotOwn then
            table.insert(seasonShopCfg, subItemCfg)
          end
        end
      else
        log_error(bWriteLog and "season_year_store_util.GetSeasonShopCfg item_cfg is invalid itemID = " .. tostring(key))
      end
    end
  end
  local sortFunc = function(a, b)
    if a.sortFlag ~= b.sortFlag then
      return a.sortFlag < b.sortFlag
    elseif a.serial_no ~= b.serial_no then
      return a.serial_no > b.serial_no
    else
      return false
    end
  end
  table.sort(seasonShopCfg, sortFunc)
  return seasonShopCfg
end
function season_year_store_util.SetItemSortFlag(subItemCfg)
  local season_shop_cfg = require("client.logic.season.season_shop.config.season_shop_cfg")
  if season_year_store_util.CheckItemIsHas(subItemCfg) then
    subItemCfg.sortFlag = season_shop_cfg.EItemSortFlag.AlreadyGet
    return
  end
  local season_shop_util = require("client.logic.season.season_shop.util.season_shop_util")
  if subItemCfg.buy_limit and subItemCfg.buy_limit ~= 0 and season_shop_util.GetExchangeNum(subItemCfg) >= subItemCfg.buy_limit then
    subItemCfg.sortFlag = season_shop_cfg.EItemSortFlag.HasExchange
    return
  end
  local curSeasonCoinCount = season_year_store_util.GetCurrentSeasonYearCoinCount(subItemCfg)
  local currMaxSeg = season_shop_util.GetMaxSegment(subItemCfg.seasonType)
  if subItemCfg.exchange_need_cnt and curSeasonCoinCount < subItemCfg.exchange_need_cnt then
    subItemCfg.sortFlag = season_shop_cfg.EItemSortFlag.NotEnoughMoney
    return
  end
  if subItemCfg.exchange_segment_id and subItemCfg.exchange_segment_id ~= 0 and currMaxSeg < subItemCfg.exchange_segment_id then
    subItemCfg.sortFlag = season_shop_cfg.EItemSortFlag.NotEnoughSegment
    return
  end
  subItemCfg.sortFlag = season_shop_cfg.EItemSortFlag.Convertible
end
function season_year_store_util.IsExchangeConditonMatch(subItemCfg)
  log(bWriteLog and "season_year_store_util.IsExchangeConditonMatch")
  if season_year_store_util.CheckItemIsHas(subItemCfg) then
    ShowNotice(3022)
    return false
  end
  local season_shop_util = require("client.logic.season.season_shop.util.season_shop_util")
  if season_shop_util.CheckItemIsExFinish(subItemCfg) then
    ShowNotice(3021)
    return false
  end
  if season_year_store_util.GetCurrentSeasonYearCoinCount(subItemCfg) < subItemCfg.exchange_need_cnt then
    local season_year_config = require("client.logic.season_year.config.season_year_config")
    if subItemCfg.exchange_item_id == season_year_config.ESeasonYearCoinType.SeasonYearCoin then
      ShowNotice(85150)
    end
    return false
  end
  if not season_shop_util.CheckSegMatch(subItemCfg) then
    ShowNotice(3020)
    return false
  end
  return true
end
function season_year_store_util.CheckItemIsHas(subItemCfg)
  log(bWriteLog and "season_year_store_util.CheckItemIsHas")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if subItemCfg.check_has and subItemCfg.check_has == 1 then
    if wardrobe_data:GetHallDepotItemCountByResID(subItemCfg.itemID) > 0 then
      return true
    end
    local season_shop_util = require("client.logic.season.season_shop.util.season_shop_util")
    if season_shop_util.GetExchangeNum(subItemCfg) ~= 0 then
      return true
    end
  end
  return false
end
function season_year_store_util.GetCurrentSeasonYearCoinCount(subItemCfg)
  log(bWriteLog and "season_year_store_util.GetCurrentSeasonYearCoinCount item_id = " .. tostring(subItemCfg.exchange_item_id))
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local season_year_config = require("client.logic.season_year.config.season_year_config")
  local count = 0
  if subItemCfg.exchange_item_id == season_year_config.ESeasonYearCoinType.SeasonYearCoin then
    count = wardrobe_data:GetHallDepotItemCountByResID(season_year_config.ESeasonYearCoinType.SeasonYearCoin)
  end
  log(bWriteLog and "season_year_store_util.GetCurrentSeasonYearCoinCount count = " .. tostring(count))
  return count
end
function season_year_store_util.LoadFile()
  log(bWriteLog and "season_year_store_util.LoadFile")
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileTb = playerprefs.LoadFileToTable_N(playerprefs.ePlayerPrefsType.eSeasonYearMainFirstOpen)
  season_year_store_util.  log_tree("fileTb 2 = ", fileTb)
  return fileTb
end
function season_year_store_util.SaveFile(fileTb)
  log(bWriteLog and "friend_interact_tool.SaveFile")
  if fileTb == nil then
    log(bWriteLog and "season_year_store_util.SaveFile 1")
    return
  end
  season_year_store_util.  log_tree("fileTb = ", fileTb)
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  playerprefs.SaveTableToFile_N(season_year_store_util.fileTb, playerprefs.ePlayerPrefsType.eSeasonYearMainFirstOpen)
end
return season_year_store_util