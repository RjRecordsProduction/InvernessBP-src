local collect_library_module = {}
local 
function collect_library_module:GeneratePopupData(itemList, configName, mode)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local orderMap = {}
  local collectThemeMap = {}
  for _, itemData in pairs(itemList) do
    if not collectThemeMap[itemData.SubThemeID] then
      local SubThemeCfg = collect_module:GetSplitTableData(configName, mode, itemData.SubThemeID)
      if SubThemeCfg then
        collectThemeMap[itemData.SubThemeID] = {
          SubThemeID = itemData.SubThemeID,
          SubThemeCfg = SubThemeCfg,
          ItemList = {}
        }
        table.insert(orderMap, itemData.SubThemeID)
      end
    end
    if collectThemeMap[itemData.SubThemeID] then
      table.insert(collectThemeMap[itemData.SubThemeID].ItemList, {
        ItemId = itemData.ItemID,
        Time = itemData.Time,
        Version = itemData.Version
      })
    end
  end
  local collectData = {}
  for _, SubThemeID in pairs(orderMap) do
    table.insert(collectData, collectThemeMap[SubThemeID])
  end
  return collectData
end
function collect_library_module:UpdateSeriesAwardStatus(seriesId, index, subIndex, sysID)
  if not index or not subIndex then
    return
  end
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local key = collect_cfg.Index2AwardName[sysID]
  if not key or key == "" then
    return
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_data = collect_module:GetCollectData()
  if not collect_data[key] then
    collect_data[key] = {}
  end
  if seriesId then
    seriesId = tonumber(seriesId)
    if not collect_data[key][seriesId] then
      collect_data[key][seriesId] = {}
    end
    if not collect_data[key][seriesId][index] then
      collect_data[key][seriesId][index] = {}
    end
    collect_data[key][seriesId][index][subIndex] = 1
  else
    if not collect_data[key][index] then
      collect_data[key][index] = {}
    end
    collect_data[key][index][subIndex] = 1
  end
end
function collect_library_module:GetSeriesAwardStatus(seriesId, level, subIndex, score, minScore, sysID)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_data = collect_module:GetCollectData()
  if not collect_data then
    return ActivityProgressStatus.Not
  end
  if not level or not subIndex then
    return ActivityProgressStatus.Not
  end
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local awardStatus = collect_data[collect_cfg.Index2AwardName[sysID]]
  if not awardStatus then
    if minScore <= score then
      return ActivityProgressStatus.Done
    end
    return ActivityProgressStatus.Not
  end
  if seriesId then
    seriesId = tonumber(seriesId)
    if not (awardStatus[seriesId] and awardStatus[seriesId][level]) or not awardStatus[seriesId][level][subIndex] then
      if minScore <= score then
        return ActivityProgressStatus.Done
      end
    elseif awardStatus[seriesId][level][subIndex] then
      return ActivityProgressStatus.Get
    end
  elseif not awardStatus[level] or not awardStatus[level][subIndex] then
    if minScore <= score then
      return ActivityProgressStatus.Done
    end
  elseif awardStatus[level][subIndex] then
    return ActivityProgressStatus.Get
  end
  return ActivityProgressStatus.Not
end
function collect_library_module:GetGunAwardStatus(index, subIndex, gunType, score)
  log_warning(bWriteLog and string.format("collect_module:GetGunAwardStatus. index %s, subIndex %s, gunType %s, score %s", index, subIndex, gunType, score))
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local tab = collect_cfg.Sys2Index.Guns
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_data = collect_module:GetCollectData()
  local awardTb = collect_data[collect_cfg.Index2AwardName[tab]]
  local TableUtil = require("common.table_util")
  log_tree("  collect_module:GetGunAwardStatus. awardTb ", awardTb)
  local get = TableUtil.GetTableValue(awardTb, gunType, index, subIndex)
  if get then
    return ActivityProgressStatus.Get
  end
  local noScore
  if score then
    local CollectGunCfg = collect_module:GetSplitTableByFilter("CollectGunCfg", collect_module.E_ColCfgMode.JK, "Gun", gunType, "Level", index)
    if CollectGunCfg then
      for _, v in pairs(CollectGunCfg) do
        if score < v.MinScore then
          noScore = true
        end
      end
    end
  else
    log_tree("  collect_module:GetGunAwardStatus. self.curLevels[gunType] ", collect_module.curLevels[gunType])
    noScore = index > collect_module.curLevels[gunType]
  end
  local status = ActivityProgressStatus.Done
  if noScore then
    status = ActivityProgressStatus.Not
  end
  return status
end
function collect_library_module:OnGetGunDropBatch(sysID, seriesID, awards)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local awardStatus = collect_module.collect_data[collect_cfg.Index2AwardName[sysID]]
  if not awardStatus then
    awardStatus = {}
    collect_module.collect_data[collect_cfg.Index2AwardName[sysID]] = awardStatus
  end
  if seriesID then
    awardStatus[tonumber(seriesID)] = awards
  else
    collect_module.collect_data[collect_cfg.Index2AwardName[sysID]] = awards
  end
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  collect_reddot_module:RefreshLibrarySubTabRed(sysID)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_library_module)
return CModuleTemplate