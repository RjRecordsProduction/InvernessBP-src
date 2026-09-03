local collect_reddot_module = {}
local local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
local E_Library_Reddot_Label = {
  clothe = "clothe",
  gun = "gun",
  vehicle = "vehicle",
  pet = "pet",
  theme = "theme"
}
local LibrarySys2ModuleConfig = {
  [collect_cfg.Sys2Index.Clothes] = "collect_clothe_module",
  [collect_cfg.Sys2Index.Guns] = "collect_gun_module",
  [collect_cfg.Sys2Index.Vehicle] = "collect_vehicle_module",
  [collect_cfg.Sys2Index.Pet] = "collect_pet_module"
}
local LibrarySys2RedLabel = {
  [collect_cfg.Sys2Index.Clothes] = E_Library_Reddot_Label.clothe,
  [collect_cfg.Sys2Index.Guns] = E_Library_Reddot_Label.gun,
  [collect_cfg.Sys2Index.Vehicle] = E_Library_Reddot_Label.vehicle,
  [collect_cfg.Sys2Index.Pet] = E_Library_Reddot_Label.pet
}
function collect_reddot_module:DefineAndResetData()
  local super_data = require("common.super_data")
  local temp = {}
  for i, v in pairs(E_Library_Reddot_Label) do
    temp[v] = false
  end
  self.redData = super_data.CreateSuperData(temp)
  self.end
function collect_reddot_module:SetAllowRefreshReddot(boolValue)
  self.allowRefreshReddot = boolValue
end
function collect_reddot_module:RefreshRedPoint()
  local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
  local road = self:IsRedRoad()
  roleinfo_red_data.SetCollectRoadRed(road)
  log_warning(bWriteLog and "  collect_reddot_module:RefreshRedPoint. road: " .. tostring(road))
  local rank = self:IsRedCollectRank()
  roleinfo_red_data.SetCollectRankRed(rank)
  log_warning(bWriteLog and "  collect_reddot_module:RefreshRedPoint. rank: " .. tostring(rank))
  for sys, module in pairs(LibrarySys2ModuleConfig) do
    local module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig[module])
    if module then
      local label = LibrarySys2RedLabel[sys]
      self.redData[label] = module:HasRed()
    end
  end
  self:AsyncRefreshLibraryRedDot()
end
function collect_reddot_module:RefreshRoadRedPoint()
  local road = self:IsRedRoad()
  local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
  roleinfo_red_data.SetCollectRoadRed(self.allowRefreshReddot and road)
end
function collect_reddot_module:IsRedRoad()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local score, curLevel = collect_module:GetCollectTotalScore()
  if 0 < score and self:IsRedOneRoad(curLevel, collect_cfg.Sys2Index.Level) then
    return true
  end
  local season, seasonLevel = collect_module:GetSeasonScoreAndLevelBySeasonID()
  if 0 < season and self:IsRedOneRoad(seasonLevel, collect_cfg.Sys2Index.Season) then
    return true
  end
  return false
end
function collect_reddot_module:IsRedOneRoad(curLevel, nTab)
  local claimable = false
  if nTab == collect_cfg.Sys2Index.Season then
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    local seasonHide = collect_module:SeasonIsHide()
    if seasonHide then
      return claimable
    end
    claimable = self:GetSeasonClaimableOrClaimedAward(curLevel)
  else
    claimable = self:GetCareerClaimableOrClaimedAward(curLevel)
  end
  return claimable
end
function collect_reddot_module:CheckCommonClaimableOrClaimedAward(curLevel, nTab, getConfigFunc, checkExtraCondFunc)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local claimedLevel = 0
  for level = 1, curLevel do
    for subIndex = 1, 2 do
      local status = collect_module:GetAwardStatus(nTab, level, subIndex)
      if status == ActivityProgressStatus.Done then
        local config = getConfigFunc(level)
        if config then
          local drop = config["Drop" .. subIndex]
          local purchaseCond = config["PurchaseCond" .. subIndex]
          if drop and drop ~= 0 and collect_module:HasDependence(purchaseCond) and (not checkExtraCondFunc or checkExtraCondFunc(config, subIndex)) then
            return true, level
          end
        end
      elseif status == ActivityProgressStatus.Get then
        claimedLevel = level
      end
    end
  end
  return false, claimedLevel
end
function collect_reddot_module:GetSeasonClaimableOrClaimedAward(curLevel)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local currentSeasonCfg = collect_module:GetSplitTableByFilter("NewCollectSeasonLevel", collect_module.E_ColCfgMode.JK, "SeasonID", tonumber(DataMgr.season_id))
  if not currentSeasonCfg then
    log(bWriteLog and string.format("collect_reddot_module:GetSeasonClaimableOrClaimedAward NewCollectSeasonLevel config is nil, season id = %s", DataMgr.season_id))
  end
  local levelCfgMap = {}
  if currentSeasonCfg then
    for _, v in pairs(currentSeasonCfg) do
      levelCfgMap[v.Level] = v
    end
  end
  local getConfig = function(level)
    return levelCfgMap[level]
  end
  local checkExtra = function(config, subIndex)
    local price = config["CostNum" .. subIndex]
    return price and price == 0
  end
  return self:CheckCommonClaimableOrClaimedAward(curLevel, collect_cfg.Sys2Index.Season, getConfig, checkExtra)
end
function collect_reddot_module:GetCareerClaimableOrClaimedAward(curLevel)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local getConfig = function(level)
    return collect_module:GetSplitTableData("CollectLevel", collect_module.E_ColCfgMode.JK, level)
  end
  return self:CheckCommonClaimableOrClaimedAward(curLevel, collect_cfg.Sys2Index.Level, getConfig)
end
function collect_reddot_module:IsRedCollectRank()
  local collect_rank_entry_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_rank_entry_module)
  local award, curIndex, status, cond, curScore = collect_rank_entry_module:GetActivityAward()
  if award then
    return status == ActivityProgressStatus.Done
  end
  return false
end
function collect_reddot_module:RefreshLibrarySubTabRed(sysID)
  local cfg = LibrarySys2ModuleConfig[sysID]
  if not cfg then
    log(bWriteLog and string.format("collect_reddot_module:RefreshLibrarySubTabRed. subLable: %s", sysID))
    return
  end
  local module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig[cfg])
  if module then
    local label = LibrarySys2RedLabel[sysID]
    self.redData[label] = module:HasRed()
  end
  self:PushLibraryRed()
end
function collect_reddot_module:AsyncRefreshLibraryRedDot(themeIds)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowTheme() then
    return
  end
  local TimeTicker = require("common.time_ticker")
  if self._preCalcTimer then
    TimeTicker.RemoveTimer(self._preCalcTimer)
  end
  local collect_theme_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_theme_module)
  local redData = self.redData
  themeIds = themeIds or collect_theme_module:GetAllIdsByTimeFilter()
  self._preCalcTimer = TimeTicker.AddTimer(0, function()
    local bRedDot = false
    local front = 1
    local back = #themeIds
    local delayCount = 0
    while front <= back do
      local frontThemeId = themeIds[front]
      local backThemeId = themeIds[back]
      if collect_theme_module:IsRedOneTheme(frontThemeId) or collect_theme_module:IsRedOneTheme(backThemeId) then
        bRedDot = true
        break
      end
      if front == back or front == back - 1 then
        break
      end
      front = front + 1
      back = back - 1
      delayCount = delayCount + 2
      if 8 < delayCount then
        coroutine.yield(TimeTicker.NEXT_FRAME)
        delayCount = 0
      end
    end
    redData.theme = bRedDot
    self:PushLibraryRed()
    EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_THEME_AWARD_NOTIFY, bRedDot)
    log_warning(bWriteLog and "collect_module:RefreshThemeRedPoint bRedDot: " .. tostring(redData.theme))
    TimeTicker.RemoveTimer(self._preCalcTimer)
  end)
end
function collect_reddot_module:PushLibraryRed()
  local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
  for key, res in pairs(self.redData) do
    if res then
      roleinfo_red_data.SetCollectLibraryRed(self.allowRefreshReddot and true)
      return
    end
  end
  roleinfo_red_data.SetCollectLibraryRed(self.allowRefreshReddot and false)
end
function collect_reddot_module:GetLibraryAvailableRedData()
  return self.redData
end
function collect_reddot_module:CheckLibraryAvailableRedData(key)
  if key and self.redData then
    return self.redData[key]
  end
  return false
end
function collect_reddot_module:SetLibraryAvailableRedData(key, value)
  if key and self.redData then
    self.redData[key] = value
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_reddot_module)
return CModuleTemplate