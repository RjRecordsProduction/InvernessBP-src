local collect_season_module = {}
function collect_season_module:DefineAndResetData()
  self.level2minScoreList = nil
  self.stage2CategoryNum = {}
  self.betterCar = {}
end
function collect_season_module:OnLogOut()
  self.level2minScoreList = nil
end
local isGold = function(itemID)
  local ItemConfig = CDataTable.GetTableData("Item", itemID)
  if ItemConfig and ItemConfig.ItemQuality == 8 and ItemConfig.ItemSubType == 403 then
    return true
  end
end
function collect_season_module:GetListOfAvailableRewards()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local sysIndex = collect_cfg.Sys2Index.Season
  local configs = collect_module:GetSplitTableByFilter("NewCollectSeasonLevel", collect_module.E_ColCfgMode.JK, "SeasonID", tonumber(DataMgr.season_id))
  if not configs then
    log(bWriteLog and string.format("collect_season_module:GetListOfAvailableRewards NewCollectSeasonLevel config is nil, season id = %s.", DataMgr.season_id))
    configs = {}
  end
  local list = {}
  for _, cfg in pairs(configs) do
    for i = 1, 2 do
      local itemId = cfg["Drop" .. i]
      local cost = cfg["Cost" .. i]
      if itemId ~= 0 and cost == 0 then
        local status = collect_module:GetAwardStatus(sysIndex, cfg.Level, i)
        if status == ActivityProgressStatus.Done then
          table.insert(list, {
            itemId = itemId,
            num = cfg["Num" .. i],
            time = cfg["Time" .. i],
            idx = cfg.Level,
            subIdx = i
          })
          log(bWriteLog and string.format("collect_season_module:GetListOfAvailableRewards itemId = %s", itemId))
        end
      end
    end
  end
  return list
end
function collect_season_module:GetCategoryEachProduct(startTime, endTime)
  if self.stage2CategoryNum[startTime] then
    local res = self.stage2CategoryNum[startTime]
    return res.xSuit, res.golden, res.upgrade, res.tarot
  end
  local xSuit, golden, upgrade, tarot = 0, 0, 0, 0
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local itemTb = collect_module:GetItemTb()
  for itemId, time in pairs(itemTb) do
    if type(time) == "number" and startTime <= time and time < endTime then
      if ItemUpgradeMgr:IsUpdateGun(itemId) then
        upgrade = upgrade + 1
      end
      if AvatarCommon.IsXSuit(itemId) then
        xSuit = xSuit + 1
      elseif isGold(itemId) then
        golden = golden + 1
      end
      if self:IsBetterCar(itemId) then
        tarot = tarot + 1
      end
    end
  end
  self.stage2CategoryNum[startTime] = {
    xSuit = xSuit,
    golden = golden,
    upgrade = upgrade,
      }
  return xSuit, golden, upgrade, tarot
end
function collect_season_module:IsBetterCar(itemId)
  local betterCar = self.betterCar
  if betterCar[itemId] == nil then
    local Table = CDataTable.GetTableData("BetterVehicleEffect", itemId)
    if Table then
      betterCar[itemId] = true
    else
      betterCar[itemId] = false
    end
  end
  return betterCar[itemId]
end
function collect_season_module:GetSeasonBenefitsAlreadyEarnedByLevel(seaLevel, seasonId)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local res = {}
  local CollectLevelCfg = collect_module:GetSplitTableByFilter("NewCollectSeasonLevel", collect_module.E_ColCfgMode.JK, "SeasonID", tonumber(seasonId))
  if not CollectLevelCfg then
    log(bWriteLog and string.format("collect_module:GetSeasonBenefitsAlreadyEarnedByLevel NewCollectSeasonLevel config is nil. season id = %s.", tonumber(seasonId)))
    return res
  end
  for _, cfg in pairs(CollectLevelCfg) do
    if tonumber(seaLevel) >= tonumber(cfg.Level) and cfg and cfg.Drop1 > 0 then
      res[#res + 1] = cfg
    end
  end
  return res
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_season_module)
return CModuleTemplate