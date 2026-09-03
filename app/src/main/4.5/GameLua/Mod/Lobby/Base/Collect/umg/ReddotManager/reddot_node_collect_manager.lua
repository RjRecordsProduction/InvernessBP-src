local TimeUtil = require("client.common.time_util")
local reddot_node_collect_manager = {}
local CollectTab = {
  collect_lobby = 8108,
  collect_main = 77527,
  collect_level = 77475,
  collect_library = 77477,
  collect_career = 77464,
  collect_season = 77465,
  collect_cloth = 77566,
  collect_weapon = 77490,
  collect_theme = 77491,
  collect_combobox = 77498,
  collect_vehicle = 4663,
  collect_pet = 65507,
  collect_milestone = 82001,
  collect_rank = 77603,
  collect_brand = 77574
}
function reddot_node_collect_manager:OnLogOut()
  self:HideNodeAllChildNewReddot(CollectTab.collect_lobby, true)
  self:HideNodeAllChildBoxReddot(CollectTab.collect_lobby, true)
end
function reddot_node_collect_manager:DefineAndResetData()
  local version = Client.GetApplicationVersion()
  local StringUtil = require("common.string_util")
  local result = StringUtil.Split(version, ".")
  self.curVersion = nil
  if result and 3 <= #result then
    local str = string.format("%s%s%s", result[1], result[2], result[3])
    self.curVersion = tonumber(str)
    log(bWriteLog and "xcc reddot_node_collect_manager:DefineAndResetData" .. str)
  end
  self.SpecialTabWithNotRemoveReddot = {}
  self.reddotWidgetMap = {}
  self.initNewData = false
  self.cacheRemoveRedDotMap = {}
end
function reddot_node_collect_manager:OnDestroy()
  self:RemoveAllTimer()
end
function reddot_node_collect_manager:GetCollectTab()
  return CollectTab
end
function reddot_node_collect_manager:GetConvertedTabId(name)
  if type(name) == "number" then
    return name
  end
  for _, tabId in pairs(CollectTab) do
    if type(name) == "string" and name == LocUtil.GetLocalizeResStr(tabId) then
      return tabId
    end
  end
  return name
end
function reddot_node_collect_manager:CreateReddotNode(tabId)
  self:InitReddotDataAndNode()
  local data = self:GetOneReddotCfgData(tabId)
  if not data then
    log(bWriteLog and "xcc reddot_node_collect_manager:CreateReddotNode data is nil, tabId: " .. tostring(tabId))
    return
  end
  local id, node = self:GetOneReddotNode(tabId)
  if id and node then
    return node
  end
  local parentTabId, parentNode = self:GetOneReddotNode(data.parentTabId)
  local reddot_node_collect = require("GameLua.Mod.Lobby.Base.Collect.umg.ReddotManager.reddot_node_collect")
  node = reddot_node_collect(nil, parentNode, data)
  node:SetCurVersion(self.curVersion)
  node:InitNode()
  self.reddotRoot = tabId == CollectTab.collect_lobby and node or self.reddotRoot
  return node
end
function reddot_node_collect_manager:GetOneReddotNode(tabId)
  if self.reddotRoot then
    return self.reddotRoot:GetOneReddotNode(tabId)
  end
end
function reddot_node_collect_manager:GetOneReddotLocalData(tabId)
  if not self.reddotDataLocalCache then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local reddotDataLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectTabNewData) or {}
    self.reddotDataLocalCache = {}
    for key, value in pairs(reddotDataLocalCache) do
      self:CreateOneReddotData(self.reddotDataLocalCache, value)
    end
  end
  return self.reddotDataLocalCache and self.reddotDataLocalCache[tabId]
end
function reddot_node_collect_manager:GetOneReddotCfgData(tabId)
  return self.reddotDataCfgCache[tabId]
end
function reddot_node_collect_manager:SetReddotCfgData(reddotDataCfgCache)
  if not self.reddotDataCfgCache then
    self.reddotDataCfgCache = {}
    for key, value in pairs(reddotDataCfgCache) do
      self:CreateOneReddotData(self.reddotDataCfgCache, value)
    end
  end
end
function reddot_node_collect_manager:CreateOneReddotData(datas, value)
  local tabId = value.tabId or value.TabId or value.ID or 0
  datas[tabId] = {}
  datas[tabId].  datas[tabId].parentTabId = value.parentTabId or value.ParentTabId
  datas[tabId].beginVersion = value.beginVersion or value.BeginVersion
  datas[tabId].endVersion = value.endVersion or value.EndVersion
  datas[tabId].count = value.count or value.Count or 0
  if not self.SpecialTabWithNotRemoveReddot[tabId] and value.SaveReddot and 0 < value.SaveReddot then
    self.SpecialTabWithNotRemoveReddot[tabId] = true
  end
  if tabId == 46631002 and datas[tabId].parentTabId == CollectTab.collect_vehicle then
    datas[tabId].parentTabId = CollectTab.collect_brand
  end
end
function reddot_node_collect_manager:CheckTabTimeLegal(startTime, endTime)
  local bOutStart = TimeUtil.CheckAfterTimeStr(startTime)
  local bOutEnd = TimeUtil.CheckAfterTimeStr(endTime)
  if not bOutStart then
    return false, startTime
  elseif not bOutEnd then
    return true, endTime
  end
  return endTime == "" and bOutStart and bOutEnd
end
function reddot_node_collect_manager:InitReddotDataAndNode()
  if self.initNewData then
    return
  end
  self.initNewData = true
  self.totalReddotCount = 0
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local newDataCache = collect_module:GetSplitTable("CollectTabNewData")
  self:SetReddotCfgData(newDataCache)
  for _, value in pairs(newDataCache or {}) do
    local tabId = value.tabId or value.TabId or 0
    local parentTabId = value.parentTabId or value.ParentTabId
    if tabId == CollectTab.collect_season then
      local logic_season_config = require("client.logic.season.logic_season_config")
      local SeasonCfg = logic_season_config.GetSeasonConfig(DataMgr.season_id) or {}
      value.StartTime = SeasonCfg.begin_time
      value.EndTime = SeasonCfg.end_time
    end
    local bAllowReddot, time = self:CheckTabTimeLegal(value.StartTime or "", value.EndTime or "")
    if GlobalData.IsJapanOrKorea() and parentTabId == CollectTab.collect_combobox then
      log(bWriteLog and "xcc reddot_node_collect_manager:InitReddotDataAndNode jk is no theme")
    elseif bAllowReddot then
      if time and time ~= "" then
        self:AddTimerOnce(TimeUtil.TimeStringToUnixstamp(time) - TimeUtil.GetServerTimeInSec(), function()
          self:RemoveReddot(tabId)
        end)
      end
      self:CreateReddotNode(tabId)
    elseif not bAllowReddot and time and time ~= "" then
      self:AddTimerOnce(TimeUtil.TimeStringToUnixstamp(time) - TimeUtil.GetServerTimeInSec(), function()
        self:CreateReddotNode(tabId)
      end)
    end
  end
  self:SaveNewReddotData()
end
function reddot_node_collect_manager:ShowNewReddot(parentNode, reddotMountRoot, tabId)
  self:InitReddotDataAndNode()
  tabId = self:GetConvertedTabId(tabId)
  self:HideOldReddotWithMap(parentNode)
  local id, node = self:GetOneReddotNode(tabId)
  if id and node and node:ShowNewReddot(reddotMountRoot) then
    self:AddNewReddotWithMap(parentNode, tabId)
    return true
  end
  return false
end
function reddot_node_collect_manager:CheckShowNewReddot(tabId)
  self:InitReddotDataAndNode()
  tabId = self:GetConvertedTabId(tabId)
  local id, node = self:GetOneReddotNode(tabId)
  if id and node then
    return node:CheckCanShowNewReddot(true)
  end
  return false
end
function reddot_node_collect_manager:ShowBoxReddot(parentNode, reddotMountRoot, tabId, bShow)
  tabId = self:GetConvertedTabId(tabId)
  self:HideOldReddotWithMap(parentNode)
  local id, node = self:GetOneReddotNode(tabId)
  if id and node and node:ShowBoxReddot(reddotMountRoot, bShow) then
    self:AddNewReddotWithMap(parentNode, tabId)
    return true
  end
  return false
end
function reddot_node_collect_manager:HideBoxReddot(tabId, reddotMountRoot)
  tabId = self:GetConvertedTabId(tabId)
  local id, node = self:GetOneReddotNode(tabId)
  if id and node then
    node:HideBoxReddot(reddotMountRoot)
  end
end
function reddot_node_collect_manager:HideNewReddot(tabId)
  tabId = self:GetConvertedTabId(tabId)
  local id, node = self:GetOneReddotNode(tabId)
  if id and node then
    node:HideReddot()
  end
end
function reddot_node_collect_manager:HideOldReddotWithMap(widget)
  local strId = tostring(widget)
  if self.reddotWidgetMap[strId] then
    self:HideBoxReddot(self.reddotWidgetMap[strId])
    self:HideNewReddot(self.reddotWidgetMap[strId])
    self.reddotWidgetMap[strId] = nil
  end
end
function reddot_node_collect_manager:AddNewReddotWithMap(widget, tabId)
  self.reddotWidgetMap[tostring(widget)] = tabId
end
function reddot_node_collect_manager:RemoveReddotWithMapp(tabId)
  for widgetName, _tabId in pairs(self.reddotWidgetMap) do
    if _tabId == tabId then
      self.reddotWidgetMap[widgetName] = nil
      break
    end
  end
end
function reddot_node_collect_manager:HideNodeAllChildNewReddot(tabId, bHide)
  tabId = self:GetConvertedTabId(tabId)
  local id, node = self:GetOneReddotNode(tabId)
  if id and node then
    if bHide then
      node:HideReddot()
    end
    node:HideAllChildReddot()
  end
end
function reddot_node_collect_manager:HideNodeAllChildBoxReddot(tabId, bHide)
  tabId = self:GetConvertedTabId(tabId)
  local id, node = self:GetOneReddotNode(tabId)
  if id and node then
    if bHide then
      node:HideBoxReddot()
    end
    node:HideAllChildBoxReddot()
  end
end
function reddot_node_collect_manager:RemoveReddot(tabId)
  self:InitReddotDataAndNode()
  tabId = self:GetConvertedTabId(tabId)
  local id, node = self:GetOneReddotNode(tabId)
  if id and node then
    local data = node:GetReddotData() or {}
    if data.count and data.count > 0 and node:GetChildNodeCount() == 0 then
      node:PushReddotCount(-1)
      node:PushReddotToParent(-1)
      self:AddOrSubTotalReddotCount(-1)
      self:SaveNewReddotData()
      EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_REDDOT)
      if self.totalReddotCount == 0 then
        local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
        roleinfo_red_data.RefreshCollectRed()
        self:HideNodeAllChildNewReddot(CollectTab.collect_lobby, true)
      end
    end
  end
end
function reddot_node_collect_manager:AddOrSubTotalReddotCount(diffCount)
  if not self.initNewData then
    return
  end
  self.totalReddotCount = self.totalReddotCount + diffCount
end
function reddot_node_collect_manager:CacheRemoveRedDot(tabId)
  self.cacheRemoveRedDotMap[tabId] = true
end
function reddot_node_collect_manager:ClearCacheRemoveRedDot()
  for tabId, v in pairs(self.cacheRemoveRedDotMap) do
    self:RemoveReddot(tabId)
  end
  self.cacheRemoveRedDotMap = {}
end
function reddot_node_collect_manager:SaveNewReddotData()
  local newDatas = {}
  if self.reddotRoot then
    self.reddotRoot:GetAllNodeData(newDatas)
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(newDatas or {}, PlayerPrefsSystem.ePlayerPrefsType.eCollectTabNewData)
end
function reddot_node_collect_manager:AddMilestoneRedPoint(tabId)
  self:InitReddotDataAndNode()
  local id, node = self:GetOneReddotNode(tabId)
  local data = id and node and node:GetReddotData(tabId)
  if not data then
    data = {
      tabId = tabId,
      parentTabId = CollectTab.collect_milestone,
      beginVersion = self.curVersion,
      endVersion = self.curVersion,
      count = 1
    }
    self:CreateOneReddotData(self.reddotDataCfgCache, data)
  else
    if data.count >= 1 then
      return
    end
    data.count = 1
  end
  self:CreateReddotNode(tabId)
  self:SaveNewReddotData()
  EventSystem:postEvent(EVENTTYPE_MILESTONE, EVENTID_MILESTONE_UPDATE_REDPOINT)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Creddot_node_collect_manager = class(CModuleBase, nil, reddot_node_collect_manager)
return Creddot_node_collect_manager