local collect_theme_module = {}
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local local local cfgLength = 3700
local ENUM_WardrobePageTypeId = wardrobe_macro.ENUM_WardrobePageTypeId
local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
local sortTb = {
  [macroTabString.ENUM_WardrobeSubTabString_suit] = 1,
  [macroTabString.ENUM_WardrobeSubTabString_helmet] = 2,
  [macroTabString.ENUM_WardrobeSubTabString_head] = 3,
  [macroTabString.ENUM_WardrobeSubTabString_glasses] = 4,
  [macroTabString.ENUM_WardrobeSubTabString_face] = 5,
  [macroTabString.ENUM_WardrobeSubTabString_clothes] = 6,
  [macroTabString.ENUM_WardrobeSubTabString_bag] = 7,
  [macroTabString.ENUM_WardrobeSubTabString_trousers] = 8,
  [macroTabString.ENUM_WardrobeSubTabString_shoes] = 9,
  [macroTabString.ENUM_WardrobeSubTabString_bag_pendant] = 10
}
function collect_theme_module:DefineAndResetData()
  self.hasLocCfg = nil
  self.Item2Quality = nil
  self.item2PageTypeId = nil
  self.item2Tab = nil
  self.themeIds = prealloctable(0, 8)
  self.season2themes = prealloctable(0, 8)
  self.theme2Items = prealloctable(0, 8)
  self.theme2Time = prealloctable(0, 8)
  self.Quality2ItemTb = {}
  self.isOpened = false
  self.stage2QuantityNum = {}
end
function collect_theme_module:ItemToQuality(itemID)
  self.Item2Quality = self.Item2Quality or prealloctable(0, cfgLength)
  if not self.Item2Quality[itemID] then
    local itemData = CDataTable.GetTableData("Item", itemID)
    if itemData then
      self.Item2Quality[itemID] = itemData.ItemQuality
    end
  end
  return self.Item2Quality[itemID]
end
function collect_theme_module:ItemToPageType(itemID)
  self.item2PageTypeId = self.item2PageTypeId or prealloctable(0, cfgLength)
  if not self.item2PageTypeId[itemID] then
    local itemData = CDataTable.GetTableData("Item", itemID)
    if itemData then
      if itemData.ItemType == ENUM_ITEM_TYPE.Weapon then
        self.item2PageTypeId[itemID] = ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
      else
        local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
        self.item2PageTypeId[itemID] = collect_cfg.tab2Sort[itemData.WardrobeTab]
      end
    end
  end
  return self.item2PageTypeId[itemID]
end
function collect_theme_module:ItemToTab(itemID)
  self.item2Tab = self.item2Tab or prealloctable(0, cfgLength)
  if not self.item2Tab[itemID] then
    local itemData = CDataTable.GetTableData("Item", itemID)
    if itemData then
      self.item2Tab[itemID] = itemData.WardrobeTab
    end
  end
  return self.item2Tab[itemID]
end
function collect_theme_module:GetSeasonToThemes()
  self:LoadLocalSeasonCfg()
  return self.season2themes
end
function collect_theme_module:GetItemsByThemeId(themeId)
  self:LoadLocalSeasonCfg()
  return self.theme2Items[themeId] or {}
end
function collect_theme_module:GetTimeByThemeId(themeId)
  self:LoadLocalSeasonCfg()
  return self.theme2Time[themeId] or 0
end
function collect_theme_module:GetAllIdsByTimeFilter()
  self:LoadLocalSeasonCfg()
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local result = {}
  for _, themeId in pairs(self.themeIds) do
    local time = self:GetTimeByThemeId(themeId)
    if not time or now > time then
      result[#result + 1] = themeId
    end
  end
  return result
end
function collect_theme_module:OnPreSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    if self.nMyLoadTimer then
      self:RemoveTimer(self.nMyLoadTimer)
    end
    self.nMyLoadTimer = nil
    log(bWriteLog and string.format("collect_theme_module:OnPreSwitchGameStatus clear data"))
    self:DefineAndResetData()
  end
end
function collect_theme_module:LoadLocalSeasonCfg()
  if self.hasLocCfg then
    return
  end
  self.hasLocCfg = true
  self.Item2Quality = self.Item2Quality or prealloctable(0, cfgLength)
  self.item2PageTypeId = self.item2PageTypeId or prealloctable(0, cfgLength)
  self.item2Tab = self.item2Tab or prealloctable(0, cfgLength)
  local item2Quality, item2PageTypeId, item2Tab = self.Item2Quality, self.item2PageTypeId, self.item2Tab
  local season2themes, theme2Items, theme2Time, themeIds = self.season2themes, self.theme2Items, self.theme2Time, self.themeIds
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local CollectSeasonCfg = collect_module:GetSplitTable("CollectSeasonCfg", collect_module.E_ColCfgMode.JK)
  for seasonId, _ in pairs(CollectSeasonCfg) do
    seasonId = tonumber(seasonId)
    season2themes[seasonId] = prealloctable(8, 0)
  end
  local TimeUtil = require("client.common.time_util")
  local CollectThemeCfg = collect_module:GetSplitTable("CollectThemeCfg", collect_module.E_ColCfgMode.JK)
  for themeId, v in pairs(CollectThemeCfg) do
    themeId = tonumber(themeId)
    local themes = season2themes[v.Season]
    if themes then
      themes[#themes + 1] = themeId
      theme2Items[themeId] = prealloctable(8, 0)
      local time = v.Time
      if time ~= "" then
        theme2Time[themeId] = TimeUtil.TimeStringToUnixstamp(time)
      end
    else
      log_warning(bWriteLog and "  collect_module:LoadLocalSeasonCfg.  error need season" .. tostring(v.Season))
    end
  end
  local Weapon = ENUM_ITEM_TYPE.Weapon
  local ENUM_WardrobePageType_Weapon = ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
  local doMap = {}
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local tab2Sort = collect_cfg.tab2Sort
  local CollectItemCfg = collect_module:GetSplitTable("CollectItemCfg", collect_module.E_ColCfgMode.JK)
  if not CollectItemCfg then
    log_error(bWriteLog and "  collect_module:LoadLocalSeasonCfg. error need CollectItemCfg")
    return
  end
  local num = 0
  local step = 700
  if self.nMyLoadTimer then
    self:RemoveTimer(self.nMyLoadTimer)
  end
  self.nMyLoadTimer = self:AddTimer(0, function()
    for _, v in pairs(CollectItemCfg) do
      local ThemeID = v.ThemeID
      local items = theme2Items[ThemeID]
      if items then
        num = num + 1
        if not self.isOpened and num % step == 0 then
          coroutine.yield(0)
        end
        local itemId = tonumber(v.ID)
        local itemData = CDataTable.GetTableData("Item", itemId)
        if itemData then
          item2Quality[itemId] = itemData.ItemQuality
          item2Tab[itemId] = itemData.WardrobeTab
          if itemData.ItemType == Weapon then
            item2PageTypeId[itemId] = ENUM_WardrobePageType_Weapon
          else
            item2PageTypeId[itemId] = tab2Sort[itemData.WardrobeTab]
          end
          items[#items + 1] = itemId
          if not doMap[ThemeID] then
            doMap[ThemeID] = true
            themeIds[#themeIds + 1] = ThemeID
          end
        end
      end
    end
  end)
end
function collect_theme_module:ReqCfg()
  log(bWriteLog and "  collect_module:ReqCfg.  ")
  self.isOpened = true
end
function collect_theme_module:AddedAlreadyOwnedProps(itemTb)
  self.Quality2ItemTb = {}
  self.Item2Quality = self.Item2Quality or prealloctable(0, cfgLength)
  local item2Quality = self.Item2Quality
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  for quality = ItemMacros.QUALITY_PURPLE, ItemMacros.QUALITY_GOLDEN do
    self.Quality2ItemTb[quality] = {}
  end
  local getTableData = CDataTable.GetTableData
  local quality2ItemTb = self.Quality2ItemTb
  for itemId, v in pairs(itemTb) do
    local curQuality = item2Quality[itemId]
    if not curQuality then
      local itemData = getTableData("Item", itemId)
      if itemData then
        curQuality = itemData.ItemQuality
        item2Quality[itemId] = curQuality
      end
    end
    if curQuality and quality2ItemTb[curQuality] then
      quality2ItemTb[curQuality][itemId] = v
    end
  end
end
function collect_theme_module:GetQuantityEachProduct(startTime, endTime)
  if self.stage2QuantityNum[startTime] then
    return self.stage2QuantityNum[startTime]
  end
  self.stage2QuantityNum[startTime] = {}
  local res = self.stage2QuantityNum[startTime]
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  for i = ItemMacros.QUALITY_PURPLE, ItemMacros.QUALITY_GOLDEN do
    local all = self.Quality2ItemTb[i] or {}
    local n = 0
    for _, time in pairs(all) do
      if startTime <= time and time < endTime then
        n = n + 1
      end
    end
    res[i] = n
  end
  return res
end
function collect_theme_module:GetLibrarySortData(quality)
  local tb = {}
  local result = {}
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local hasTb = collect_module:GetItemTb()
  if quality then
    hasTb = self.Quality2ItemTb[quality]
  end
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  local ENUM_WardrobePageType_Avatar = ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
  for itemId, _ in pairs(hasTb) do
    if not LogicFusionModule:IsFusionTargetItem(itemId) then
      local curSort = self:ItemToPageType(itemId)
      if curSort == ENUM_WardrobePageType_Avatar then
        local tab = self:ItemToTab(itemId)
        if not tab then
          log(bWriteLog and string.format("collect_theme_module:GetLibrarySortData itemId = %s", itemId))
        end
        if tab and not tb[tab] then
          tb[tab] = 1
          result[#result + 1] = tab
        end
      end
    end
  end
  table.sort(result, function(a, b)
    local sort1 = sortTb[a] or 1
    local sort2 = sortTb[b] or 1
    return sort1 < sort2
  end)
  return result
end
function collect_theme_module:GetLibrarySortGridData(tab)
  log_warning(bWriteLog and "  collect_module:GetLibrarySortGridData. tab: " .. tostring(tab))
  local result = {}
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local itemTb = collect_module:GetItemTb()
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  for itemId, _ in pairs(itemTb) do
    if not LogicFusionModule:IsFusionTargetItem(itemId) then
      local itemData = CDataTable.GetTableData("Item", itemId)
      if itemData and self:ItemToTab(itemId) == tab then
        result[#result + 1] = itemId
      end
    end
  end
  return result
end
function collect_theme_module:IsRedOneTheme(themeId)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_data = collect_module:GetCollectData()
  if not collect_data then
    return false
  end
  local theme_award_status = collect_data.theme_award_status
  local get = theme_award_status and theme_award_status[themeId]
  if get then
    return false
  end
  local items = self:GetItemsByThemeId(themeId)
  if not items then
    return false
  end
  local num = 0
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  for _, itemId in ipairs(items) do
    if StoreUtils.HasItem(itemId) then
      num = num + 1
    else
      return false
    end
  end
  return #items == num
end
function collect_theme_module:HasRedTheme(themeIds)
  local bRedDot = false
  local front = 1
  local back = #themeIds
  while front <= back do
    local frontThemeId = themeIds[front]
    local backThemeId = themeIds[back]
    if self:IsRedOneTheme(frontThemeId) or self:IsRedOneTheme(backThemeId) then
      bRedDot = true
      break
    end
    if front == back or front == back - 1 then
      break
    end
    front = front + 1
    back = back - 1
  end
  return bRedDot
end
function collect_theme_module:GetClotheTotalCount()
  local result = 0
  local tabs = self:GetLibrarySortData()
  for _, tabName in pairs(tabs) do
    local tabData = self:GetLibrarySortGridData(tabName)
    result = result + #tabData or 0
  end
  return result
end
function collect_theme_module:OnThemeDrop(themeId)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module.collect_data.theme_award_status then
    collect_module.collect_data.theme_award_status = {}
  end
  collect_module.collect_data.theme_award_status[themeId] = 1
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  collect_reddot_module:AsyncRefreshLibraryRedDot()
end
function collect_theme_module:SetThemeAwardStatus(themeId)
  if not themeId then
    return
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module.collect_data.theme_award_status then
    collect_module.collect_data.theme_award_status = {}
  end
  collect_module.collect_data.theme_award_status[themeId] = 1
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_theme_module)
return CModuleTemplate