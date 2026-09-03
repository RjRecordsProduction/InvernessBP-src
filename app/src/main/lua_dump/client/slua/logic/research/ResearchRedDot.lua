local ResearchRedDot = {}
function ResearchRedDot:GetData()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local systemName = reddot_macro.SystemName.Research
  local item_upgrade_ui_config = require("client.slua.umg.upgrade.item_upgrade_ui_config")
  local data = {
    desc = systemName,
    newCount = 0,
    [item_upgrade_ui_config.UITabType.KillFeature] = {
      newCount = 0,
      [item_upgrade_ui_config.KillFeatureTabType.KillCounter] = {newCount = 0, isDynamic = true},
      [item_upgrade_ui_config.KillFeatureTabType.LastKillEffectUI] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.NewArrivals,
        instances = {_isLeaf = true}
      },
      [item_upgrade_ui_config.KillFeatureTabType.EliminationKing] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.NewArrivals,
        instances = {_isLeaf = true}
      }
    },
    [item_upgrade_ui_config.UITabType.ItemUpgradeUI] = {newCount = 0, isDynamic = true}
  }
  return data
end
function ResearchRedDot:GetNodeDataByTabType(tabType)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  local gropData = generalLabReddotData.GetReddotData(reddot_macro.SystemName.Research)
  if gropData and gropData[tabType] then
    return gropData[tabType]
  end
  return nil
end
function ResearchRedDot:LoadLocalResearchRedData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local temp = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eResearchRedDotMark)
  return temp or {}
end
function ResearchRedDot:SaveLocalResearchRedData(data, changed)
  if not data then
    return
  end
  if not changed then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(data or {}, PlayerPrefsSystem.ePlayerPrefsType.eResearchRedDotMark)
end
local GenerateItemUpgradeRed = function(desc, depth)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {newCount = 0}
  if depth == 0 then
    data.subID = 2
    data.category = reddot_macro.Category.NewArrivals
  else
    data.isDynamic = true
  end
  return data
end
function ResearchRedDot:SetItemUpgradeRedDot()
  if self.InitItemUpgradeRedDot then
    return
  end
  self.InitItemUpgradeRedDot = true
  local item_upgrade_ui_config = require("client.slua.umg.upgrade.item_upgrade_ui_config")
  local RedData = self:GetNodeDataByTabType(item_upgrade_ui_config.UITabType.ItemUpgradeUI)
  if not RedData then
    return
  end
  local RedDotConfig = CDataTable.GetTable("ItemUpgradeRedDotConfig")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eItemUpgradeReddot) or {}
  for _, config in pairs(RedDotConfig) do
    if self:CheckHasNew(config, cache) then
      local SubType = config.SubType
      if not RedData[SubType] then
        RedData[SubType] = GenerateItemUpgradeRed(SubType)
      end
      local GroupID = config.GroupID
      local EffectLevel = config.EffectLevel
      if not RedData[SubType][GroupID] then
        RedData[SubType][GroupID] = GenerateItemUpgradeRed(GroupID, EffectLevel)
      end
      if EffectLevel == 0 then
        RedData[SubType][GroupID].newCount = RedData[SubType][GroupID].newCount + 1
      else
        local SubEffectIndex = config.SubEffectIndex
        if not RedData[SubType][GroupID][EffectLevel] then
          RedData[SubType][GroupID][EffectLevel] = GenerateItemUpgradeRed(EffectLevel, SubEffectIndex)
        end
        if SubEffectIndex == 0 then
          RedData[SubType][GroupID][EffectLevel].newCount = RedData[SubType][GroupID][EffectLevel].newCount + 1
        else
          if not RedData[SubType][GroupID][EffectLevel][SubEffectIndex] then
            RedData[SubType][GroupID][EffectLevel][SubEffectIndex] = GenerateItemUpgradeRed(SubEffectIndex, 0)
          end
          RedData[SubType][GroupID][EffectLevel][SubEffectIndex].newCount = RedData[SubType][GroupID][EffectLevel][SubEffectIndex].newCount + 1
        end
      end
    end
  end
end
function ResearchRedDot:CheckHasNew(cfg, cache)
  local GroupId = cfg.GroupId
  if GroupId == 0 then
    return false
  end
  if cache[GroupId] then
    local cacheGroupData = cache[GroupId]
    local EffectLevel = cfg.EffectLevel
    if cacheGroupData[EffectLevel] then
      local cacheEffectData = cacheGroupData[EffectLevel]
      local SubEffectIndex = cfg.SubEffectIndex
      if cacheEffectData[SubEffectIndex] then
        return false
      end
    end
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  if not ItemUpgradeMgr:CheckIsValid(GroupId) then
    return false
  end
  if not FuncUtil.IsInVersionRange(cfg.VersionLower, cfg.VersionUpper) then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local Unix = TimeUtil.TimeStringToUnixstamp(cfg.ShowTime)
  if Unix > TimeUtil.GetServerTimeInSec() then
    return false
  end
  return true
end
function ResearchRedDot:ClearItemUpgradeRedDot(groupId, effectLevel, subEffectIndex)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eItemUpgradeReddot) or {}
  if not cache[groupId] then
    cache[groupId] = {}
  end
  if not cache[groupId][effectLevel] then
    cache[groupId][effectLevel] = {}
  end
  if not cache[groupId][effectLevel][subEffectIndex] then
    cache[groupId][effectLevel][subEffectIndex] = 1
  end
  PlayerPrefsSystem.SaveTableToFile_N(cache, PlayerPrefsSystem.ePlayerPrefsType.eItemUpgradeReddot)
end
function ResearchRedDot:SetKillCounterRedDot(counterData)
  if not counterData then
    return
  end
  local item_upgrade_ui_config = require("client.slua.umg.upgrade.item_upgrade_ui_config")
  local redData = self:GetNodeDataByTabType(item_upgrade_ui_config.UITabType.KillFeature)
  if not redData then
    return
  end
  local gunRedData = redData[item_upgrade_ui_config.KillFeatureTabType.KillCounter]
  if not gunRedData then
    return
  end
  local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
  local configs = LogicKillCounter:GetWeaponAndFeatureList()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = self:LoadLocalResearchRedData()
  local changed = false
  for weaponId, featureList in pairs(configs) do
    for _, featureId in pairs(featureList) do
      if featureId and not data[featureId] and counterData[featureId] and 0 < counterData[featureId] then
        if not gunRedData[weaponId] then
          gunRedData[weaponId] = {
            newCount = 0,
            subID = 1,
            category = reddot_macro.Category.NewArrivals,
            instances = {_isLeaf = true}
          }
        end
        gunRedData[weaponId].instances[featureId] = true
        data[featureId] = 1
        changed = true
      end
    end
  end
  self:SaveLocalResearchRedData(data, changed)
end
function ResearchRedDot:SetKillEffectRedDot(effectData)
  if not effectData then
    return
  end
  local item_upgrade_ui_config = require("client.slua.umg.upgrade.item_upgrade_ui_config")
  local redData = self:GetNodeDataByTabType(item_upgrade_ui_config.UITabType.KillFeature)
  if not redData then
    return
  end
  local gunRedData = redData[item_upgrade_ui_config.KillFeatureTabType.LastKillEffectUI]
  if not gunRedData then
    return
  end
  local configs = CDataTable.GetTable("LastKillEffectShowCfg")
  if not configs then
    return
  end
  local data = self:LoadLocalResearchRedData()
  local changed = false
  for itemID, _ in pairs(configs) do
    if not data[itemID] and effectData[itemID] and 0 < effectData[itemID] then
      gunRedData.instances[itemID] = true
      data[itemID] = 1
      changed = true
    end
  end
  self:SaveLocalResearchRedData(data, changed)
end
function ResearchRedDot:SetEliminationKingEffectRedDot(effectData)
  if not effectData then
    return
  end
  local item_upgrade_ui_config = require("client.slua.umg.upgrade.item_upgrade_ui_config")
  local redData = self:GetNodeDataByTabType(item_upgrade_ui_config.UITabType.KillFeature)
  local effectRedData = redData[item_upgrade_ui_config.KillFeatureTabType.EliminationKing]
  if not effectRedData then
    return
  end
  local cfg = CDataTable.GetTable("EliminationKingEffectCfg")
  if not cfg then
    return
  end
  local data = self:LoadLocalResearchRedData()
  local changed = false
  for itemID, _ in pairs(cfg) do
    if not data[itemID] and effectData[itemID] and 0 < effectData[itemID] then
      effectRedData.instances[itemID] = true
      data[itemID] = 1
      changed = true
    end
  end
  self:SaveLocalResearchRedData(data, changed)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, ResearchRedDot)
return CModuleTemplate