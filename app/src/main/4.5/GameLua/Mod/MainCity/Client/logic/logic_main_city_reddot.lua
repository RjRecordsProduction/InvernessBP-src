local logic_main_city_reddot = {}
local PriorityQueue = require("common.priority_queue")
local ReddotConfig = require("client.slua.logic.reddot.reddot_config")
local ui_util = require("client.common.ui_util")
function logic_main_city_reddot:RegistEvents()
  log(bWriteLog and "logic_main_city_reddot:RegistEvents")
end
local OldReddotCompare = function(aData, bData)
  if not aData or not bData then
    return false
  end
  local a = aData.widget.dataNode
  local b = bData.widget.dataNode
  local weightA = a and a.realWeight or 0
  local weightB = b and b.realWeight or 0
  if weightA == weightB then
    if not a.desc and not b.desc then
      return tostring(aData) < tostring(bData)
    end
    if not a.desc then
      return true
    end
    if not b.desc then
      return true
    end
    return ReddotConfig:GetSystemWeight(a.desc) < ReddotConfig:GetSystemWeight(b.desc)
  end
  return weightA < weightB
end
local ReddotCompare = function(a, b)
  if not slua.isValid(a.widget) and not slua.isValid(b.widget) then
    return tostring(a) < tostring(b)
  elseif not slua.isValid(a.widget) then
    return true
  elseif not slua.isValid(b.widget) then
    return false
  end
  if a.mcWeight and not b.mcWeight then
    log(bWriteLog and "logic_main_city_reddot:ReddotCompare nil")
    return true
  end
  if b.mcWeight and not a.mcWeight then
    log(bWriteLog and "logic_main_city_reddot:ReddotCompare nil")
    return false
  end
  if a.mcWeight ~= b.mcWeight then
    return a.mcWeight < b.mcWeight
  end
  if a.widget.dataNode and not b.widget.dataNode then
    return false
  end
  if b.widget.dataNode and not a.widget.dataNode then
    return true
  end
  if not a.widget.dataNode and not b.widget.dataNode then
    return tostring(a) < tostring(b)
  end
  return OldReddotCompare(a, b)
end
function logic_main_city_reddot:DefineAndResetData()
end
function logic_main_city_reddot:OnInitialize()
  log(bWriteLog and "logic_main_city_reddot:OnInitialize")
  logic_main_city_reddot.__super.OnInitialize(self)
  self.ReddotLimitNumber = ReddotConfig:GetReddotLimitNumber()
  self.reddotWidgetsInUI = {}
  self.reddotWidgets = {}
  self.showingReddotWidgetQueue = PriorityQueue(ReddotCompare)
end
function logic_main_city_reddot:InitReddotQueueActivationTimer()
  log(bWriteLog and "logic_main_city_reddot:InitReddotQueueActivationTimer")
  if self.refreshAllQueuedReddotTimer then
    self:RemoveTimer(self.refreshAllQueuedReddotTimer)
  end
  self.refreshAllQueuedReddotTimer = self:AddTimerLoop(ReddotConfig:GetEntryRefreshCD(), function()
    log(bWriteLog and "logic_main_city_reddot:InitReddotQueueActivationTimer refresh queued reddots")
    self:RefreshReddots()
  end, TIMER_INFINITE, ReddotConfig:GetEntryRefreshCD())
end
function logic_main_city_reddot:TryAddReddotToQueue(reddotWidgetData)
  log_tree("logic_main_city_reddot:TryAddReddotWidgetToQueue reddotWidgetData = ", reddotWidgetData)
  local bReddotActivated = reddotWidgetData.bReddotActivated
  if not bReddotActivated then
    log(bWriteLog and "logic_main_city_reddot:TryAddReddotToQueue not active")
    return
  end
  self:GetMainCityWidgetWeight(reddotWidgetData)
  if not self:IsUserValid(reddotWidgetData.mcSystemName) then
    log(bWriteLog and "logic_main_city_reddot:TryAddReddotToQueue user invalid " .. tostring(reddotWidgetData.mcSystemName))
    return
  end
  if bReddotActivated then
    if reddotWidgetData.bIsInReddotQueue then
      log(bWriteLog and "logic_main_city_reddot:TryAddReddotToQueue already in")
      return
    end
    local top = self.showingReddotWidgetQueue:Top()
    if self.showingReddotWidgetQueue:Size() >= self.ReddotLimitNumber and top and ReddotCompare(top, reddotWidgetData) then
      self.showingReddotWidgetQueue:Pop()
      self:ToggleReddotVisibility(top, false)
      top.bIsInReddotQueue = false
    end
    if self.showingReddotWidgetQueue:Size() < self.ReddotLimitNumber then
      self.showingReddotWidgetQueue:Push(reddotWidgetData)
      self:ToggleReddotVisibility(reddotWidgetData, true)
      reddotWidgetData.bIsInReddotQueue = true
      log(bWriteLog and "logic_main_city_reddot:TryAddReddotToQueue data added to queue")
    else
      self:ToggleReddotVisibility(reddotWidgetData, false)
    end
  end
  log_tree("logic_main_city_reddot:TryAddReddotToQueue cur queue = ", self.showingReddotWidgetQueue)
end
function logic_main_city_reddot:TryRemoveReddotFromQueue(reddotWidgetData)
  log_tree("logic_main_city_reddot:TryRemoveReddotFromQueue reddotWidgetData = ", reddotWidgetData)
  local bReddotActivated = reddotWidgetData.bReddotActivated
  if bReddotActivated then
    return
  end
  self.showingReddotWidgetQueue:Remove(reddotWidgetData)
  reddotWidgetData.bIsInReddotQueue = false
  self:ToggleReddotVisibility(reddotWidgetData, false)
end
function logic_main_city_reddot:RefreshReddots()
  log(bWriteLog and "logic_main_city_reddot:RefreshReddots")
  if self.showingReddotWidgetQueue:Size() < self.ReddotLimitNumber then
    log(bWriteLog and "logic_main_city_reddot:RefreshReddots add new")
    local unqueuedDataList = {}
    for _, v in pairs(self.reddotWidgets) do
      if not v.bIsInReddotQueue and v.bReddotActivated then
        unqueuedDataList[#unqueuedDataList + 1] = v
        self:GetMainCityWidgetWeight(v)
      end
    end
    local utility = require("common.utility")
    xpcall(function()
      table.sort(unqueuedDataList, function(a, b)
        return ReddotCompare(b, a)
      end)
      log_tree("logic_main_city_reddot:RefreshReddots candidate list", unqueuedDataList)
      local index = 1
      while self.showingReddotWidgetQueue:Size() < self.ReddotLimitNumber and index <= #unqueuedDataList do
        self:TryAddReddotToQueue(unqueuedDataList[index])
        index = index + 1
      end
    end, utility.ErrorMessageHandler)
  else
    log(bWriteLog and "logic_main_city_reddot:RefreshReddots is already full")
  end
  for _, v in pairs(self.showingReddotWidgetQueue) do
    self:ToggleReddotVisibility(v, true)
    log(bWriteLog and "logic_main_city_reddot:RefreshReddots showing system" .. tostring(v.mcSystemName) .. " w" .. tostring(v.mcWeight))
  end
end
function logic_main_city_reddot:ToggleReddotVisibility(reddotWidgetData, bShouldShow)
  if not reddotWidgetData then
    return
  end
  ui_util.SetWidgetVisible(reddotWidgetData.widget, bShouldShow)
  reddotWidgetData.bIsShowingReddot = bShouldShow
end
function logic_main_city_reddot:ToggleReddot(widget, bShouldActivate)
  if widget.dataNode then
    log(bWriteLog and "logic_main_city_reddot:ToggleReddot " .. tostring(widget.dataNode.desc) .. " State" .. tostring(bShouldActivate))
  end
  local utility = require("common.utility")
  local result = false
  xpcall(function()
    result = self:ToggleReddotImpl(widget, bShouldActivate)
  end, utility.ErrorMessageHandler)
  return result
end
function logic_main_city_reddot:ToggleReddotImpl(widget, bShouldActivate)
  local reddotWidgetData = self.reddotWidgets[widget]
  if not reddotWidgetData then
    log(bWriteLog and "logic_main_city_reddot:RealToggleReddotActivation reddotWidgetData not found")
    if not widget.dataNode then
      ui_util.SetWidgetVisible(widget, bShouldActivate)
    end
    return false
  else
    if not reddotWidgetData.mcSystemName then
      self:GetMainCityWidgetWeight(reddotWidgetData)
    end
    log(bWriteLog and "logic_main_city_reddot:ToggleReddotImpl " .. tostring(reddotWidgetData.mcSystemName))
  end
  reddotWidgetData.bReddotActivated = bShouldActivate
  if reddotWidgetData and reddotWidgetData.extraData and reddotWidgetData.extraData.mcSyncLobby then
    self:SyncLobby(reddotWidgetData)
    return
  end
  if bShouldActivate then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSecWithFraction()
    local timeSinceRegist = curTime - reddotWidgetData.registTime
    if timeSinceRegist <= 3 or 900 < timeSinceRegist then
      self:TryAddReddotToQueue(reddotWidgetData)
      reddotWidgetData.registTime = curTime
    end
  else
    self:TryRemoveReddotFromQueue(reddotWidgetData)
  end
  return true
end
function logic_main_city_reddot:SyncLobby(widgetData)
  log(bWriteLog and "logic_main_city_reddot:SyncLobby")
  local logic_reddot_limitation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reddot_limitation)
  local systemName
  if widgetData.extraData and widgetData.extraData.mcSystemName then
    systemName = widgetData.extraData.mcSystemName
  end
  if not systemName and widgetData.widget then
    local dataNode = widgetData.widget.dataNode
    systemName = dataNode and dataNode.desc
  end
  local bShow = false
  for k, v in pairs(logic_reddot_limitation.showingReddotWidgetQueue) do
    local dataNode = v.widget and v.widget.dataNode
    local tmpName = dataNode and dataNode.desc
    tmpName = tmpName or v.extraData and v.extraData.systemName
    if tmpName == systemName then
      log(bWriteLog and "logic_main_city_reddot:SyncLobby sync lobby name" .. tostring(tmpName))
      bShow = true
    end
  end
  local syncReddotState = logic_reddot_limitation.syncReddotState or {}
  for tmpName, stateInfo in pairs(syncReddotState) do
    if tmpName == systemName then
      log(bWriteLog and "logic_main_city_reddot:SyncLobby sync lobby name2" .. tostring(tmpName))
      bShow = stateInfo.bShow
    end
  end
  if bShow then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSecWithFraction()
    widgetData.mcWeight = 99999999
    widgetData.bReddotActivated = true
    self:TryAddReddotToQueue(widgetData)
    self:ToggleReddotVisibility(widgetData, true)
    widgetData.registTime = curTime
  else
    widgetData.mcWeight = 0
    self:TryRemoveReddotFromQueue(widgetData)
    widgetData.bIsInReddotQueue = false
    widgetData.bReddotActivated = false
    self:ToggleReddotVisibility(widgetData, false)
  end
end
function logic_main_city_reddot:CheckWidgetRegistered(widget)
  return self.reddotWidgets[widget] ~= nil
end
function logic_main_city_reddot:RegistReddotWidget(uiBase, widget, extra)
  log(bWriteLog and "logic_main_city_reddot:RegistReddotWidget")
  if not uiBase or not widget then
    log(bWriteLog and "logic_main_city_reddot:RegistReddotWidget invalid widget")
    return
  end
  if self.reddotWidgets[widget] then
    log(bWriteLog and "logic_main_city_reddot:RegistReddotWidget widget already registered")
    return
  end
  if ReddotConfig.bSkipReddotLimitation then
    log(bWriteLog and "logic_main_city_reddot:RegistReddotWidget skip by GM")
    return
  end
  self.reddotWidgetsInUI[uiBase] = self.reddotWidgetsInUI[uiBase] or {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSecWithFraction()
  local reddotWidgetData = {
    uiRoot = uiBase.UIRoot,
    widget = widget,
    bReddotActivated = false,
    bIsShowingReddot = false,
    extraData = extra,
    registTime = curTime,
    bIsInOldSystem = false,
    bIsInReddotQueue = false
  }
  self.reddotWidgetsInUI[uiBase][widget] = reddotWidgetData
  self.reddotWidgets[widget] = reddotWidgetData
  reddotWidgetData.bIsInOldSystem = type(reddotWidgetData.widget.ToggleReddotVisibilityByLimitation) == "function"
  log_tree("logic_main_city_reddot:RegistReddotWidget reddotWidgetData = ", reddotWidgetData)
  self:ToggleReddotVisibility(reddotWidgetData, false)
  if extra and extra.mcSyncLobby then
    self:SyncLobby(reddotWidgetData)
  end
end
function logic_main_city_reddot:GetMainCityWidgetWeight(widgetData)
  if not widgetData then
    return 0
  end
  if not widgetData.mcWeight then
    local systemName
    local weight = 0
    if widgetData.extraData and widgetData.extraData.mcSystemName then
      systemName = widgetData.extraData.mcSystemName
      weight = self:GetMainCitySystemWeight(systemName)
    end
    if (not systemName or weight == 0) and widgetData.widget then
      local dataNode = widgetData.widget.dataNode
      systemName = dataNode and dataNode.desc
      weight = self:GetMainCitySystemWeight(systemName)
    end
    widgetData.mcSystemName = systemName
    widgetData.mcWeight = weight
  end
  log(bWriteLog and "logic_main_city_reddot:GetMainCityWidgetWeight systemName " .. tostring(widgetData.mcSystemName) .. " weight" .. tostring(widgetData.mcWeight))
  return widgetData.mcWeight
end
function logic_main_city_reddot:GetMainCitySystemWeight(systemName)
  if systemName == nil or systemName == "" then
    return 0
  end
  local ReddotConfig = self:GetMCReddotConfig()[systemName]
  if ReddotConfig then
    return ReddotConfig.Weight and ReddotConfig.Weight or 0
  else
    log(bWriteLog and "logic_main_city_reddot:GetMainCitySystemWeight failed to get cfg " .. tostring(systemName))
    return 0
  end
end
function logic_main_city_reddot:GetMCReddotConfig()
  log(bWriteLog and "logic_main_city_reddot:GetMCReddotConfig")
  if not self.ReddotsConfig or not next(self.ReddotsConfig) then
    self.ReddotsConfig = {}
    local DTMCRedddotsConfig = CDataTable.GetTable("MCReddotConfig")
    if DTMCRedddotsConfig then
      for _, v in pairs(DTMCRedddotsConfig) do
        self.ReddotsConfig[v.Name] = {
          Name = v.Name,
          ValidUser = v.ValidUser,
          ValidLevel = v.ValidLevel,
          Weight = v.Weight,
          EliminatePrimary = v.IsEliminatePrimaryReddot
        }
      end
      log(bWriteLog and "logic_main_city_reddot:GetMCReddotConfig init")
      log_tree(self.ReddotsConfig)
    else
      log(bWriteLog and "logic_main_city_reddot:GetMCReddotConfig failed to get table")
    end
  end
  return self.ReddotsConfig or {}
end
function logic_main_city_reddot:IsUserValid(systemName)
  if not systemName or systemName == "" then
    return true
  end
  local MCReddotConfig = self:GetMCReddotConfig()[systemName]
  if MCReddotConfig then
    local systemValidUser = MCReddotConfig.ValidUser
    local ReddotManager = require("client.slua.logic.reddot.reddot_manager")
    local userInfo = ReddotManager:GetUserInfo()
    local userLabel = userInfo and userInfo.userLabel or nil
    if userLabel and systemValidUser ~= "" and string.find(systemValidUser, userLabel, 1, true) == nil then
      log(bWriteLog and "logic_main_city_reddot:IsUserValid failed label")
      return false
    end
    local levelRequire = MCReddotConfig.ValidLevel
    local userLevel = userInfo.userLevel
    if 0 < levelRequire and levelRequire > userLevel then
      log(bWriteLog and "logic_main_city_reddot:IsUserValid failed level")
      return false
    end
    return true
  else
    log(bWriteLog and "logic_main_city_reddot:IsUserValid failed to get config" .. tostring(systemName))
    return true
  end
end
function logic_main_city_reddot:UnregistReddotWidget(uiBase, widget)
  log_tree("logic_main_city_reddot:UnregistReddotWidget widget = ", widget)
  if not self.reddotWidgetsInUI[uiBase] then
    log(bWriteLog and "logic_main_city_reddot:UnregistReddotWidget cannot find registed reddot widgets")
    return
  end
  if not widget then
    for k, v in pairs(self.reddotWidgetsInUI[uiBase]) do
      self.showingReddotWidgetQueue:Remove(v)
      local wData = self.reddotWidgets[k]
      self:ToggleReddotVisibility(wData, false)
      self.reddotWidgets[k] = nil
    end
    self.reddotWidgetsInUI[uiBase] = nil
    return
  end
  local wData = self.reddotWidgets[widget]
  self:ToggleReddotVisibility(wData, false)
  self.reddotWidgets[widget] = nil
  if self.reddotWidgetsInUI[uiBase] then
    self.showingReddotWidgetQueue:Remove(self.reddotWidgetsInUI[uiBase][widget])
    self.reddotWidgetsInUI[uiBase][widget] = nil
    if not next(self.reddotWidgetsInUI) then
      self.reddotWidgetsInUI[uiBase] = nil
    end
  end
end
function logic_main_city_reddot:ResetData()
  log(bWriteLog and "logic_main_city_reddot:ResetData")
  self.ReddotLimitNumber = ReddotConfig:GetReddotLimitNumber()
  self.reddotWidgetsInUI = {}
  self.reddotWidgets = {}
  self.showingReddotWidgetQueue = PriorityQueue(ReddotCompare)
end
function logic_main_city_reddot:ResetAll()
  log(bWriteLog and "logic_main_city_reddot:OnLeaveMainCity")
  for _, v in pairs(self.reddotWidgets) do
    v.bIsInReddotQueue = false
    self:ToggleReddotVisibility(v, false)
  end
  self:ResetData()
end
function logic_main_city_reddot:Test()
  if self.TestTimer then
    self:RemoveTimer(self.TestTimer)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_main_city_reddot)