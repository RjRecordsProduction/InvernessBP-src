local logic_weaponstrength_tool = {}
function logic_weaponstrength_tool.FakeProfileDataCreate()
  log(bWriteLog and "logic_weaponstrength_tool.FakeProfileDataCreate")
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local global = WeaponStrength_Config.WeaponRankHonorRegion.Global
  local weaponTypecfg = CDataTable.GetTable("WeaponStrengthWeapon")
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local weapon_power_data = {
    cur_weapon_power_table = {},
    history_weapon_power_table = {}
  }
  local weaponlist = {}
  for key, value in ipairs(weaponTypecfg) do
    table.insert(weaponlist, value.WeaponID)
  end
  table.insert(weaponlist, 107011)
  log(bWriteLog and "logic_weaponstrength_tool.FakeProfileDataCreate weaponlist count:" .. tostring(#weaponlist) .. " added weapon 107011")
  for _, weaponId in ipairs(weaponlist) do
    weapon_power_data.cur_weapon_power_table[weaponId] = {
      power_count = math.random(1, 130000),
      total_kill_count = math.random(0, 5000),
      total_damage = math.random(0, 1000000),
      total_hitcount = math.random(0, 10000),
      total_firecount = math.random(0, 20000),
      total_headshootcount = math.random(0, 500)
    }
    local historyData = {
      power_count = math.random(1, 130000),
      rank_data = {}
    }
    local regionCount = math.random(0, 6)
    local usedRegions = {}
    for j = 1, regionCount do
      local region
      repeat
        local temp = math.random(0, 6)
        region = temp == 0 and global or temp
      until not usedRegions[region]
      usedRegions[region] = true
      historyData.rank_data[region] = {
        best_rank = math.random(1, 100),
        rank_count = math.random(1, 50),
        first_rank_time = math.random(1, currentTime),
        last_reward_time = 0
      }
    end
    weapon_power_data.history_weapon_power_table[weaponId] = historyData
  end
  local strengthLevels = {
    {min = 0, max = 1000},
    {min = 1000, max = 2000},
    {min = 2000, max = 4000},
    {min = 4000, max = 12000},
    {min = 12000, max = 36000},
    {min = 36000, max = 120000},
    {min = 120000, max = 999999999}
  }
  local filterInput = {}
  for weaponId, data in pairs(weapon_power_data.history_weapon_power_table) do
    table.insert(filterInput, {
      [weaponId] = {
        power_count = data.power_count,
        rank_data = data.rank_data
      }
    })
  end
  local filteredWeapons = logic_weaponstrength_tool.FilterWeapons(filterInput, 1, 1)
  for i, weaponData in ipairs(filteredWeapons) do
    local weaponId = next(weaponData)
    local levelIndex = (i - 1) % #strengthLevels + 1
    local level = strengthLevels[levelIndex]
    weapon_power_data.cur_weapon_power_table[weaponId].power_count = math.random(level.min, level.max)
    weapon_power_data.history_weapon_power_table[weaponId] = {
      power_count = math.random(level.min, level.max),
      rank_data = nil
    }
  end
  local countryIDs = {
    1000000,
    3000000,
    26000000,
    20000000
  }
  local countryWeapons = {}
  local countryWeaponCount = math.max(5, math.floor(#weaponlist * 0.3))
  local weaponIndex = 0
  for weaponId, _ in pairs(weapon_power_data.history_weapon_power_table) do
    if countryWeaponCount <= weaponIndex then
      break
    end
    weapon_power_data.history_weapon_power_table[weaponId].rank_data = {}
    local countryCount = math.random(1, 3)
    local usedCountries = {}
    for i = 1, countryCount do
      local countryID
      repeat
        countryID = countryIDs[math.random(1, #countryIDs)]
      until not usedCountries[countryID]
      usedCountries[countryID] = true
      weapon_power_data.history_weapon_power_table[weaponId].rank_data[countryID] = {
        best_rank = math.random(1, 100),
        rank_count = math.random(1, 50),
        first_rank_time = math.random(1, currentTime),
        last_reward_time = 0
      }
    end
    table.insert(countryWeapons, weaponId)
    weaponIndex = weaponIndex + 1
  end
  log(bWriteLog and "logic_weaponstrength_tool.FakeProfileDataCreate - Generated country data for " .. tostring(#countryWeapons) .. " weapons")
  local districtWeaponCount = math.max(3, math.floor(#weaponlist * 0.2))
  local districtWeapons = {}
  local districtIndex = 0
  for weaponId, _ in pairs(weapon_power_data.history_weapon_power_table) do
    local hasCountryData = false
    for _, countryWeaponId in ipairs(countryWeapons) do
      if weaponId == countryWeaponId then
        hasCountryData = true
        break
      end
    end
    if not hasCountryData and districtWeaponCount > districtIndex then
      weapon_power_data.history_weapon_power_table[weaponId].rank_data = {}
      local districtCount = math.random(1, 4)
      for i = 1, districtCount do
        local districtID = math.random(1, 6)
        weapon_power_data.history_weapon_power_table[weaponId].rank_data[districtID] = {
          best_rank = math.random(1, 100),
          rank_count = math.random(1, 50),
          first_rank_time = math.random(1, currentTime),
          last_reward_time = 0
        }
      end
      table.insert(districtWeapons, weaponId)
      districtIndex = districtIndex + 1
    end
  end
  log(bWriteLog and "logic_weaponstrength_tool.FakeProfileDataCreate - Generated district data for " .. tostring(#districtWeapons) .. " weapons")
  local globalWeaponCount = math.max(2, math.floor(#weaponlist * 0.15))
  local globalWeapons = {}
  local globalIndex = 0
  for weaponId, _ in pairs(weapon_power_data.history_weapon_power_table) do
    local hasOtherData = false
    for _, countryWeaponId in ipairs(countryWeapons) do
      if weaponId == countryWeaponId then
        hasOtherData = true
        break
      end
    end
    if not hasOtherData then
      for _, districtWeaponId in ipairs(districtWeapons) do
        if weaponId == districtWeaponId then
          hasOtherData = true
          break
        end
      end
    end
    if not hasOtherData and globalWeaponCount > globalIndex then
      local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
      weapon_power_data.history_weapon_power_table[weaponId].rank_data = {
        [WeaponStrength_Config.WeaponRankHonorRegion.Global] = {
          best_rank = math.random(1, 100),
          rank_count = math.random(1, 50),
          first_rank_time = math.random(1, currentTime),
          last_reward_time = 0
        }
      }
      table.insert(globalWeapons, weaponId)
      globalIndex = globalIndex + 1
    end
  end
  log(bWriteLog and "logic_weaponstrength_tool.FakeProfileDataCreate - Generated global data for " .. tostring(#globalWeapons) .. " weapons")
  local logic_weapon_strength = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength)
  logic_weapon_strength.weapon_power_data_fake = weapon_power_data
end
function logic_weaponstrength_tool.CompareHistoryHighestSeverRank(data)
  log(bWriteLog and "logic_weaponstrength_tool.CompareHistoryHighestSeverRank")
  if not data then
    return nil
  end
  local getHonorLevel = function(key)
    if logic_weaponstrength_tool.IsGlobal(key) then
      return 10
    elseif logic_weaponstrength_tool.IsRegion(key) then
      return 9
    elseif logic_weaponstrength_tool.IsCountry(key) then
      return 8
    end
    return 0
  end
  local highest_key, highest_value
  local highest_level = 0
  for key, rank_info in pairs(data) do
    local curLevel = getHonorLevel(key)
    if not highest_value then
      highest_      highest_value = rank_info
      highest_level = curLevel
    elseif curLevel > highest_level then
      highest_      highest_value = rank_info
      highest_level = curLevel
    elseif curLevel == highest_level then
      if rank_info.best_rank < highest_value.best_rank then
        highest_        highest_value = rank_info
        highest_level = curLevel
      elseif rank_info.best_rank == highest_value.best_rank and rank_info.first_rank_time > highest_value.first_rank_time then
        highest_        highest_value = rank_info
        highest_level = curLevel
      end
    end
  end
  log(bWriteLog and "logic_weaponstrength_tool.CompareHistoryHighestSeverRank highest_key = ", highest_key, " highest_value = ", highest_value)
  return highest_key, highest_value
end
function logic_weaponstrength_tool.CalculateHistoryTotalRankCount(data)
  log(bWriteLog and "logic_weaponstrength_tool.CalculateHistoryTotalRankCount")
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local total_count = 0
  for key, rank_info in pairs(data) do
    if logic_weaponstrength_tool.IsRegion(key) and type(rank_info.rank_count) == "number" then
      total_count = total_count + rank_info.rank_count
    end
  end
  log(bWriteLog and "Total rank count (excluding global): ", total_count)
  return total_count
end
function logic_weaponstrength_tool.CalculateHistoryEarliestRankTime(data)
  log(bWriteLog and "logic_weaponstrength_tool.CalculateHistoryEarliestRankTime")
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local earliest_time
  for key, rank_info in pairs(data) do
    if logic_weaponstrength_tool.IsRegion(key) and type(rank_info.first_rank_time) == "number" and (not earliest_time or earliest_time > rank_info.first_rank_time) then
      earliest_time = rank_info.first_rank_time
    end
  end
  log(bWriteLog and "Earliest rank time (excluding global): ", earliest_time)
  return earliest_time
end
function logic_weaponstrength_tool.CalculateHistoryTotalCountryRankCount(data)
  log(bWriteLog and "logic_weaponstrength_tool.CalculateHistoryTotalCountryRankCount")
  local total_count = 0
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  for key, rank_info in pairs(data) do
    if logic_weaponstrength_tool.IsCountry(key) and type(rank_info.rank_count) == "number" then
      total_count = total_count + rank_info.rank_count
    end
  end
  log(bWriteLog and "Total country rank count: ", total_count)
  return total_count
end
function logic_weaponstrength_tool.CalculateHistoryEarliestCountryRankTime(data)
  log(bWriteLog and "logic_weaponstrength_tool.CalculateHistoryEarliestCountryRankTime")
  local earliest_time
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  for key, rank_info in pairs(data) do
    if logic_weaponstrength_tool.IsCountry(key) and type(rank_info.first_rank_time) == "number" and (not earliest_time or earliest_time > rank_info.first_rank_time) then
      earliest_time = rank_info.first_rank_time
    end
  end
  log(bWriteLog and "Earliest country rank time: ", earliest_time)
  return earliest_time
end
function logic_weaponstrength_tool.CalculateCurrentStrengthLevel(data)
  log(bWriteLog and "logic_weaponstrength_tool.CalculateCurrentStrengthLevel")
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  if not data then
    log(bWriteLog and "logic_weaponstrength_tool.CalculateCurrentStrengthLevel Invalid data parameter")
    return 1
  end
  local weaponStrengthcfg = CDataTable.GetTable("WeaponStrengthStrengthLevel")
  if not weaponStrengthcfg then
    log(bWriteLog and "logic_weaponstrength_tool.CalculateCurrentStrengthLevel Failed to get StrengthLevel config")
    return 1
  end
  local weanponLevel = 1
  if not data.power_count then
    log(bWriteLog and "logic_weaponstrength_tool.CalculateCurrentStrengthLevel Invalid data.power_count parameter")
    return weanponLevel
  end
  for k, value in pairs(weaponStrengthcfg) do
    log(bWriteLog and "logic_weaponstrength_tool.CalculateCurrentStrengthLevel Calculated weapon value.MinIntegral: ", value.MinIntegral .. "value.MaxIntegral: ", value.MaxIntegral .. "data.power_count: ", data.power_count)
    if k < 7 and data.power_count >= value.MinIntegral and data.power_count < value.MaxIntegral then
      weanponLevel = value.Level
      break
    else
      weanponLevel = 7
    end
  end
  log(bWriteLog and "logic_weaponstrength_tool.CalculateCurrentStrengthLevel Calculated weapon level: ", weanponLevel)
  return weanponLevel
end
function logic_weaponstrength_tool.GetNextLevelNeedScore(data, WeanponID)
  local curLevel = logic_weaponstrength_tool.CalculateCurrentStrengthLevel(data)
  local weaponStrengthcfg = CDataTable.GetTable("WeaponStrengthStrengthLevel")
  if curLevel < 7 then
    local nextLevel = curLevel + 1
    local nextLevelNeedCount = weaponStrengthcfg[nextLevel].MinIntegral
    log(bWriteLog and "logic_weaponstrength_tool.GetNextLevelNeedScore nextLevel: ", nextLevel .. " nextLevelNeedCount: ", nextLevelNeedCount)
    return nextLevel, nextLevelNeedCount
  else
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local uid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
    local logic_weapon_strength_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength_rank)
    local config = CDataTable.GetTableByFilter("WeaponStrengthWeapon", "WeaponID", WeanponID)
    local RankID
    for key, value in pairs(config) do
      RankID = key
    end
    local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    local zoneId = ZoneSystem.nChooseZoneID
    logic_weapon_strength_rank:send_get_on_user_weapon_power_rank_req(uid, zoneId, RankID)
  end
  return nil, nil
end
function logic_weaponstrength_tool.CalculateHistoryTotalRankCount_Global(data)
  log(bWriteLog and "logic_weaponstrength_tool.CalculateHistoryTotalRankCount")
  local total_count = 0
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  for key, rank_info in pairs(data) do
    if key == WeaponStrength_Config.WeaponRankHonorRegion.Global and type(rank_info.rank_count) == "number" then
      total_count = total_count + rank_info.rank_count
    end
  end
  log(bWriteLog and "Total rank count (excluding global): ", total_count)
  return total_count
end
function logic_weaponstrength_tool.IsGlobal(num)
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local region = WeaponStrength_Config.WeaponRankHonorRegion
  return num == region.Global
end
function logic_weaponstrength_tool.IsRegion(num)
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local region = WeaponStrength_Config.WeaponRankHonorRegion
  return num == region.NorthAmerica or num == region.Europe or num == region.Asia or num == region.SouthAmerica or num == region.MiddleEast or num == region.JapanKorea
end
function logic_weaponstrength_tool.IsCountry(num)
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local region = WeaponStrength_Config.WeaponRankHonorRegion
  if num == region.Country then
    return true
  end
  return not logic_weaponstrength_tool.IsGlobal(num) and not logic_weaponstrength_tool.IsRegion(num)
end
function logic_weaponstrength_tool.FilterWeapons(data, filterType, weaponType)
  log(bWriteLog and "logic_weaponstrength_tool.FilterWeapons")
  log_tree("data = ", data)
  if not data then
    return nil
  end
  local filtered = {}
  local wardrobeGunLogic = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local weaponIdSet = {}
  if weaponType and 0 < weaponType then
    local typeList = wardrobeGunLogic:GetGunArrayByGunType(weaponType)
    for _, weaponInfo in ipairs(typeList) do
      weaponIdSet[weaponInfo.WeaponID] = true
    end
  end
  for _, weaponData in ipairs(data) do
    local weaponId = next(weaponData)
    local global = WeaponStrength_Config.WeaponRankHonorRegion.Global
    if not weaponType or weaponIdSet[weaponId] or weaponType == 0 then
      local rankData = weaponData[weaponId].rank_data
      local hasGlobal = rankData and rankData[global] and rankData[global].rank_count and 0 < rankData[global].rank_count
      local hasRegion = false
      local hasCountry = false
      if rankData then
        for region, info in pairs(rankData) do
          if region ~= global and info.rank_count and 0 < info.rank_count then
            if logic_weaponstrength_tool.IsRegion(region) then
              hasRegion = true
            elseif logic_weaponstrength_tool.IsCountry(region) then
              hasCountry = true
            end
          end
        end
      end
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
        if filterType == 1 then
          table.insert(filtered, weaponData)
        elseif filterType == 2 and hasRegion and not hasGlobal then
          table.insert(filtered, weaponData)
        end
      elseif filterType == 1 then
        table.insert(filtered, weaponData)
      elseif filterType == 2 and hasGlobal then
        table.insert(filtered, weaponData)
      elseif filterType == 3 and hasRegion and not hasGlobal then
        table.insert(filtered, weaponData)
      elseif filterType == 4 and hasCountry and not hasRegion and not hasGlobal then
        table.insert(filtered, weaponData)
      end
    end
  end
  table.sort(filtered, function(a, b)
    local weaponIdA = next(a)
    local weaponIdB = next(b)
    local dataA = a[weaponIdA]
    local dataB = b[weaponIdB]
    local powerA = dataA.power_count or 0
    local powerB = dataB.power_count or 0
    local rankDataA = dataA.rank_data or {}
    local rankDataB = dataB.rank_data or {}
    local global = WeaponStrength_Config.WeaponRankHonorRegion.Global
    local aHasGlobal = rankDataA[global] and rankDataA[global].rank_count and 0 < rankDataA[global].rank_count
    local bHasGlobal = rankDataB[global] and rankDataB[global].rank_count and 0 < rankDataB[global].rank_count
    if aHasGlobal and bHasGlobal then
      return powerA > powerB
    elseif aHasGlobal then
      return true
    elseif bHasGlobal then
      return false
    end
    local aHasRegion = logic_weaponstrength_tool.HasRegionHonor(rankDataA)
    local bHasRegion = logic_weaponstrength_tool.HasRegionHonor(rankDataB)
    if aHasRegion and bHasRegion then
      return powerA > powerB
    elseif aHasRegion then
      return true
    elseif bHasRegion then
      return false
    end
    local levelA = logic_weaponstrength_tool.CalculateCurrentStrengthLevel(dataA)
    local levelB = logic_weaponstrength_tool.CalculateCurrentStrengthLevel(dataB)
    if levelA ~= levelB then
      return levelA > levelB
    end
    return powerA > powerB
  end)
  return filtered
end
function logic_weaponstrength_tool.CalculateGlobalHonorTotal(data)
  log(bWriteLog and "logic_weaponstrength_tool.CalculateGlobalHonorTotal")
  local total = 0
  if not data then
    return 0
  end
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local global = WeaponStrength_Config.WeaponRankHonorRegion.Global
  for _, weaponData in ipairs(data) do
    local weaponId = next(weaponData)
    local rankData = weaponData[weaponId].rank_data
    if rankData and rankData[global] and rankData[global].rank_count then
      total = total + rankData[global].rank_count
    end
  end
  return total
end
function logic_weaponstrength_tool.CalculateRegionHonorTotal(data)
  log(bWriteLog and "logic_weaponstrength_tool.CalculateRegionHonorTotal")
  local total = 0
  if not data then
    return 0
  end
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local global = WeaponStrength_Config.WeaponRankHonorRegion.Global
  for _, weaponData in ipairs(data) do
    local weaponId = next(weaponData)
    local rankData = weaponData[weaponId].rank_data
    if rankData then
      for region, info in pairs(rankData) do
        if region ~= global and info.rank_count then
          total = total + info.rank_count
        end
      end
    end
  end
  log(bWriteLog and "logic_weaponstrength_tool.CalculateRegionHonorTotal total: ", total)
  return total
end
function logic_weaponstrength_tool.FilterWeaponsByHonor(data, filterType)
  log(bWriteLog and "logic_weaponstrength_tool.FilterWeaponsByHonor")
  local filtered = {}
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local global = WeaponStrength_Config.WeaponRankHonorRegion.Global
  for _, weaponData in ipairs(data) do
    local weaponId = next(weaponData)
    local rankData = weaponData[weaponId].rank_data
    local hasGlobal = rankData and rankData[global] and rankData[global].rank_count and rankData[global].rank_count > 0
    local hasRegion = false
    if rankData and not hasGlobal then
      for region, info in pairs(rankData) do
        if region ~= global and info.rank_count and info.rank_count > 0 then
          hasRegion = true
          break
        end
      end
    end
    if filterType == "all" then
      table.insert(filtered, weaponData)
    elseif filterType == "global" and hasGlobal then
      table.insert(filtered, weaponData)
    elseif filterType == "region" and hasRegion and not hasGlobal then
      table.insert(filtered, weaponData)
    end
  end
  return filtered
end
function logic_weaponstrength_tool.GetAliasConfigByWeaponRankID(weapon_rank_id, zone_id)
  local AliasCfg
  local logic_weapon_strength = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength)
  local weapon_rank_cfg_list = logic_weapon_strength:GetWeaponRankConfig()
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  if zone_id == 0 or zone_id == WeaponStrength_Config.WeaponRankHonorRegion.Global then
    local alias_id = weapon_rank_cfg_list[weapon_rank_id].GlobalAliasID
    AliasCfg = CDataTable.GetTableData("AliasCfg", alias_id)
  elseif logic_weaponstrength_tool.IsRegion(zone_id) then
    local alias_id = weapon_rank_cfg_list[weapon_rank_id].ZoneAliasID
    AliasCfg = CDataTable.GetTableData("AliasCfg", alias_id)
  elseif logic_weaponstrength_tool.IsCountry(zone_id) then
    local alias_id = weapon_rank_cfg_list[weapon_rank_id].CountryAliasID
    AliasCfg = CDataTable.GetTableData("AliasCfg", alias_id)
  end
  return AliasCfg
end
function logic_weaponstrength_tool.HasRegionHonor(rankData)
  log(bWriteLog and "logic_weaponstrength_tool.HasRegionHonor")
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  local global = WeaponStrength_Config.WeaponRankHonorRegion.Global
  for region, info in pairs(rankData) do
    if region ~= global and info.rank_count and info.rank_count > 0 then
      return true
    end
  end
  return false
end
function logic_weaponstrength_tool.ParseRankId(rank_id)
  log(bWriteLog and string.format("logic_weaponstrength_tool.ParseRankId rank_id = %s", tostring(rank_id)))
  if not rank_id or rank_id <= 0 then
    log(bWriteLog and "logic_weaponstrength_tool.ParseRankId invalid rank_id")
    return nil
  end
  local result = {
    country_zone_id = -1,
    weapon_rank_id = -1,
    season_id = -1
  }
  if rank_id <= 70999 then
    result.weapon_rank_id = math.floor(rank_id / 1000)
    result.season_id = rank_id % 1000
    log(bWriteLog and string.format("logic_weaponstrength_tool.ParseRankId old format - weapon_rank_id = %s, season_id = %s", tostring(result.weapon_rank_id), tostring(result.season_id)))
  else
    result.season_id = rank_id % 1000
    local temp = math.floor(rank_id / 1000)
    result.weapon_rank_id = temp % 100
    result.country_zone_id = rank_id - result.weapon_rank_id * 1000 - result.season_id
    log(bWriteLog and string.format("logic_weaponstrength_tool.ParseRankId new format - country_zone_id = %s, weapon_rank_id = %s, season_id = %s", tostring(result.country_zone_id), tostring(result.weapon_rank_id), tostring(result.season_id)))
  end
  return result
end
function logic_weaponstrength_tool.GetWeaponStrengthZoneTitle(zone_id)
  local name = ""
  local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
  if zone_id == 0 or zone_id == WeaponStrength_Config.WeaponRankHonorRegion.Global then
    name = LocUtil.GetLocalizeResStr(25702)
  elseif logic_weaponstrength_tool.IsRegion(zone_id) then
    if GlobalData.IsBLUEHOLE() then
      name = LocUtil.GetLocalizeResStr(46029)
    else
      local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
      name = logic_multiple_area:GetDisplayNameByZoneID(zone_id)
    end
  elseif logic_weaponstrength_tool.IsCountry(zone_id) then
    local table_data = CDataTable.GetTableData("LBSRegionLevelConfig", zone_id)
    if table_data and table_data.name then
      name = table_data.name
    elseif zone_id == WeaponStrength_Config.WeaponRankHonorRegion.Country then
      name = LocUtil.GetLocalizeResStr(85387)
    end
  end
  return name
end
return logic_weaponstrength_tool