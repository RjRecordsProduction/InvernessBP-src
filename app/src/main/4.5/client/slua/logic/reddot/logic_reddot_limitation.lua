local logic_reddot_limitation = {}
local utility = require("common.utility")
local PriorityQueue = require("common.priority_queue")
local ReddotConfig = require("client.slua.logic.reddot.reddot_config")
local ui_util = require("client.common.ui_util")
local TimeUtil = require("client.common.time_util")
local OldReddotCompare = function(aData, bData)
  if not aData or not bData then
    return
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
function logic_reddot_limitation:OnInitialize()
  log(bWriteLog and "[DeanJYT] logic_reddot_limitation:OnInitialize")
  logic_reddot_limitation.__super.OnInitialize(self)
  self.ReddotLimitNumber = ReddotConfig:GetReddotLimitNumber()
  self.reddotWidgetsInUI = {}
  self.reddotWidgets = {}
  self.bEnableQueuedReddotRefresh = false
  self.showingReddotWidgetQueue = PriorityQueue(ReddotCompare)
end
function logic_reddot_limitation:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_SYSTEM_OVER_ALL, self.OnReddotInfoUpdated, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, self.OnLoadingFinish, self)
end
function logic_reddot_limitation:IsSpecialReddot(reddotWidgetData)
  if not reddotWidgetData or not reddotWidgetData.widget then
    return false
  end
  local dataNode = reddotWidgetData.widget.dataNode
  if not dataNode then
    return false
  end
  local systemName = dataNode.desc
  local subID = dataNode.subID
  if not (systemName and subID) or subID == ReddotConfig.INVALID_SUBID then
    return false
  end
  local categoryCfg = ReddotConfig:GetReddotConfigByName(systemName, subID)
  if not categoryCfg or categoryCfg.SpecialReddotConfig ~= 1 then
    return false
  end
  local startTime = tonumber(categoryCfg.SpecialRedStartTime) or 0
  local endTime = tonumber(categoryCfg.SpecialRedEndTime) or 0
  if startTime <= 0 or endTime <= 0 or startTime > endTime then
    return false
  end
  local curTime = TimeUtil.GetServerTimeInSecWithFraction()
  if startTime > curTime or endTime < curTime then
    return false
  end
  return true
end
function logic_reddot_limitation:InitReddotQueueActivationTimer()
  log(bWriteLog and "[DeanJYT] logic_reddot_limitation:InitReddotQueueActivationTimer")
  if self.refreshAllQueuedReddotTimer then
    self:RemoveTimer(self.refreshAllQueuedReddotTimer)
  end
  self.refreshAllQueuedReddotTimer = self:AddTimerLoop(ReddotConfig:GetEntryRefreshCD(), function()
    log(bWriteLog and "[DeanJYT] logic_reddot_limitation:InitReddotQueueActivationTimer refresh queued reddots")
    for _, v in pairs(self.reddotWidgets) do
      if self:IsSpecialReddot(v) then
        v.bIsInReddotQueue = false
        self:ToggleSingleReddotVisibility(v, v.bReddotActivated == true)
      end
    end
    if self.showingReddotWidgetQueue:Size() < self.ReddotLimitNumber then
      log(bWriteLog and "[DeanJYT] logic_reddot_limitation:InitReddotQueueActivationTimer should push new reddot widgets to queue")
      local unqueuedDataList = {}
      for _, v in pairs(self.reddotWidgets) do
        if not v.bIsInReddotQueue and v.bReddotActivated and not self:IsSpecialReddot(v) then
          unqueuedDataList[#unqueuedDataList + 1] = v
        end
      end
      xpcall(function()
        table.sort(unqueuedDataList, function(a, b)
          return ReddotCompare(b, a)
        end)
        log_tree("[DeanJYT] logic_reddot_limitation:InitReddotQueueActivationTimer unqueuedDataList", unqueuedDataList)
        local index = 1
        while self.showingReddotWidgetQueue:Size() < self.ReddotLimitNumber and index <= #unqueuedDataList do
          self:TryAddReddotWidgetToQueue(unqueuedDataList[index])
          index = index + 1
        end
      end, utility.ErrorMessageHandler)
    end
    for _, v in pairs(self.showingReddotWidgetQueue) do
      self:ToggleSingleReddotVisibility(v, true)
    end
  end, TIMER_INFINITE, ReddotConfig:GetEntryRefreshCD())
end
function logic_reddot_limitation:OnReddotInfoUpdated()
  self.ReddotLimitNumber = ReddotConfig:GetReddotLimitNumber()
  log(bWriteLog and "[DeanJYT] logic_reddot_limitation:OnReddotInfoUpdated self.ReddotLimitNumber = " .. tostring(self.ReddotLimitNumber))
end
function logic_reddot_limitation:OnLoadingFinish()
  log(bWriteLog and "[DeanJYT] logic_reddot_limitation:OnLoadingFinish")
  if self.bEnableQueuedReddotRefresh then
    self.bEnableQueuedReddotRefresh = false
  end
end
function logic_reddot_limitation:RegistReddotWidget(uiBase, widget, extra)
  log(bWriteLog and "[DeanJYT] logic_reddot_limitation:RegistReddotWidget")
  if not uiBase or not widget then
    log(bWriteLog and "[DeanJYT] logic_reddot_limitation:RegistReddotWidget invalid widget, cannot regist reddot")
    return
  end
  if self.reddotWidgets[widget] then
    log(bWriteLog and "[DeanJYT] logic_reddot_limitation:RegistReddotWidget widget already registered")
    self:ToggleSingleReddotVisibility(self.reddotWidgets[widget], self.reddotWidgets[widget].bIsInReddotQueue)
    return
  end
  if ReddotConfig.bSkipReddotLimitation then
    log(bWriteLog and "[DeanJYT] logic_reddot_limitation:RegistReddotWidget skip reddot limit by GM")
    return
  end
  if extra and extra.mcSystemName then
    log(bWriteLog and "logic_reddot_limitation:RegistReddotWidget is MC red")
    local LobbyModuleConfig = ModuleManager.LobbyModuleConfig
    local logic_main_city_reddot = ModuleManager.GetModule(LobbyModuleConfig.logic_main_city_reddot)
    if logic_main_city_reddot then
      logic_main_city_reddot:RegistReddotWidget(uiBase, widget, extra)
    end
    return
  end
  self.reddotWidgetsInUI[uiBase] = self.reddotWidgetsInUI[uiBase] or {}
  local curTime = TimeUtil.GetServerTimeInSecWithFraction()
  local reddotWidgetData = {
    uiRoot = uiBase.UIRoot,
    widget = widget,
    bReddotActivated = false,
    bIsShowingReddot = false,
    extraData = extra,
    lastActivationTime = curTime,
    bIsInOldSystem = false,
    bIsInReddotQueue = false
  }
  self.reddotWidgetsInUI[uiBase][widget] = reddotWidgetData
  self.reddotWidgets[widget] = reddotWidgetData
  if type(reddotWidgetData.widget.ToggleReddotVisibilityByLimitation) == "function" then
    reddotWidgetData.bIsInOldSystem = true
  end
  self:ToggleSingleReddotVisibility(self.reddotWidgets[widget], self.reddotWidgets[widget].bIsInReddotQueue)
end
function logic_reddot_limitation:UnregistReddotWidget(uiBase, widget)
  if widget then
    log_tree("[DeanJYT] logic_reddot_limitation:UnregistReddotWidget widget = ", widget)
  end
  if not self.reddotWidgetsInUI[uiBase] then
    log(bWriteLog and "[DeanJYT] logic_reddot_limitation:UnregistReddotWidget cannot find registed reddot widgets")
    return
  end
  if not widget then
    for k, v in pairs(self.reddotWidgetsInUI[uiBase]) do
      self.showingReddotWidgetQueue:Remove(v)
      self.reddotWidgets[k] = nil
    end
    self.reddotWidgetsInUI[uiBase] = nil
    return
  end
  self.reddotWidgets[widget] = nil
  if self.reddotWidgetsInUI[uiBase] then
    self.showingReddotWidgetQueue:Remove(self.reddotWidgetsInUI[uiBase][widget])
    self.reddotWidgetsInUI[uiBase][widget] = nil
    if not next(self.reddotWidgetsInUI) then
      self.reddotWidgetsInUI[uiBase] = nil
    end
  end
end
function logic_reddot_limitation:CheckWidgetRegistered(widget)
  if self.reddotWidgets[widget] == nil then
    local LobbyModuleConfig = ModuleManager.LobbyModuleConfig
    local logic_main_city_reddot = ModuleManager.GetModule(LobbyModuleConfig.logic_main_city_reddot)
    return logic_main_city_reddot:CheckWidgetRegistered(widget)
  end
  return true
end
function logic_reddot_limitation:RealToggleReddotActivation(widget, bShouldActivate)
  local reddotWidgetData = self.reddotWidgets[widget]
  if not reddotWidgetData then
    local ModuleManager_GetModule = ModuleManager.GetModule
    local LobbyModuleConfig = ModuleManager.LobbyModuleConfig
    local logic_main_city_reddot = ModuleManager_GetModule(LobbyModuleConfig.logic_main_city_reddot)
    if logic_main_city_reddot:ToggleReddot(widget, bShouldActivate) then
      return
    end
    log(bWriteLog and "[DeanJYT] logic_reddot_limitation:RealToggleReddotActivation reddotWidgetData not found")
    if not widget.dataNode then
      ui_util.SetWidgetVisible(widget, bShouldActivate)
    end
    return
  end
  reddotWidgetData.bReddotActivated = bShouldActivate
  reddotWidgetData.lastActivationTime = TimeUtil.GetServerTimeInSecWithFraction()
  if bShouldActivate then
    if not self.bEnableQueuedReddotRefresh then
      log(bWriteLog and "[DeanJYT] logic_reddot_limitation:RealToggleReddotActivation not self.bEnableQueuedReddotRefresh")
      return
    end
    self:TryAddReddotWidgetToQueue(reddotWidgetData)
  else
    self:TryRemoveReddotWidgetFromQueue(reddotWidgetData)
  end
end
function logic_reddot_limitation:ToggleReddotActivation(widget, bShouldActivate)
  xpcall(function()
    self:RealToggleReddotActivation(widget, bShouldActivate)
  end, utility.ErrorMessageHandler)
end
function logic_reddot_limitation:TryRemoveReddotWidgetFromQueue(reddotWidgetData)
  log_tree("[DeanJYT] logic_reddot_limitation:TryRemoveReddotWidgetFromQueue reddotWidgetData = ", reddotWidgetData)
  local bReddotActivated = reddotWidgetData.bReddotActivated
  if bReddotActivated then
    return
  end
  if self:IsSpecialReddot(reddotWidgetData) then
    log(bWriteLog and "[DeanJYT] logic_reddot_limitation:TryRemoveReddotWidgetFromQueue special reddot bypass queue")
    reddotWidgetData.bIsInReddotQueue = false
    self:ToggleSingleReddotVisibility(reddotWidgetData, false)
    return
  end
  self.showingReddotWidgetQueue:Remove(reddotWidgetData)
  reddotWidgetData.bIsInReddotQueue = false
  self:ToggleSingleReddotVisibility(reddotWidgetData, false)
end
function logic_reddot_limitation:TryAddReddotWidgetToQueue(reddotWidgetData)
  log_tree("[DeanJYT] logic_reddot_limitation:TryAddReddotWidgetToQueue reddotWidgetData = ", reddotWidgetData)
  local bReddotActivated = reddotWidgetData.bReddotActivated
  if not bReddotActivated then
    log(bWriteLog and "[DeanJYT] logic_reddot_limitation:TryAddReddotWidgetToQueue reddot not active, cannot add reddot to queue!")
    return
  end
  if self:IsSpecialReddot(reddotWidgetData) then
    log(bWriteLog and "[DeanJYT] logic_reddot_limitation:TryAddReddotWidgetToQueue special reddot bypass queue")
    reddotWidgetData.bIsInReddotQueue = false
    self:ToggleSingleReddotVisibility(reddotWidgetData, true)
    return
  end
  if bReddotActivated then
    if reddotWidgetData.bIsInReddotQueue then
      log(bWriteLog and "[DeanJYT] logic_reddot_limitation:TryAddReddotWidgetToQueue reddot already in queue")
      return
    end
    local top = self.showingReddotWidgetQueue:Top()
    if self.showingReddotWidgetQueue:Size() >= self.ReddotLimitNumber and top and ReddotCompare(top, reddotWidgetData) then
      self.showingReddotWidgetQueue:Pop()
      self:ToggleSingleReddotVisibility(top, false)
      top.bIsInReddotQueue = false
    end
    if self.showingReddotWidgetQueue:Size() < self.ReddotLimitNumber and not reddotWidgetData.bIsInReddotQueue then
      self.showingReddotWidgetQueue:Push(reddotWidgetData)
      self:ToggleSingleReddotVisibility(reddotWidgetData, true)
      reddotWidgetData.bIsInReddotQueue = true
      log(bWriteLog and "[DeanJYT] logic_reddot_limitation:TryAddReddotWidgetToQueue data added to queue")
    else
      self:ToggleSingleReddotVisibility(reddotWidgetData, false)
    end
  end
  log_tree("[DeanJYT] logic_reddot_limitation:TryAddReddotWidgetToQueue cur queue status = ", self.showingReddotWidgetQueue)
end
function logic_reddot_limitation:ToggleSingleReddotVisibility(reddotWidgetData, bShouldShow)
  if not reddotWidgetData.bIsInOldSystem then
    ui_util.SetWidgetVisible(reddotWidgetData.widget, bShouldShow)
    reddotWidgetData.bIsShowingReddot = bShouldShow
    return
  end
  reddotWidgetData.widget:ToggleReddotVisibilityByLimitation(bShouldShow)
  reddotWidgetData.bIsShowingReddot = bShouldShow
end
function logic_reddot_limitation:ResetReddotWidgetLimitationData()
  log(bWriteLog and "[DeanJYT] logic_reddot_limitation:ResetReddotWidgetLimitationData")
  self.reddotWidgetsInUI = {}
  self.reddotWidgets = {}
  self.showingReddotWidgetQueue:Clear()
end
function logic_reddot_limitation:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[DeanJYT] logic_reddot_limitation:OnPreSwitchGameStatus pre = " .. tostring(preState) .. ", nextState = " .. tostring(nextState))
  if preState ~= nextState and nextState == GameStatus.Lobby then
    self.bEnableQueuedReddotRefresh = true
    self:ResetReddotWidgetLimitationData()
    self:InitReddotQueueActivationTimer()
  end
  if not GameStatus.IsInLobbyOrMainCity() and self.refreshAllQueuedReddotTimer then
    self:RemoveTimer(self.refreshAllQueuedReddotTimer)
    self.refreshAllQueuedReddotTimer = nil
  end
end
function logic_reddot_limitation:SyncReddotState(systemName, bShow, bUpdate)
  log(bWriteLog and "logic_reddot_limitation:SyncReddotState " .. tostring(systemName) .. " bshow " .. tostring(bShow) .. " bforce " .. tostring(bUpdate))
  if not systemName then
    return
  end
  if not self.syncReddotState then
    self.syncReddotState = {}
  end
  self.syncReddotState[systemName] = {bShow = bShow, bUpdate = bUpdate}
end
function logic_reddot_limitation:GetSyncReddotState(systemName)
  log(bWriteLog and "logic_reddot_limitation:GetSyncReddotState " .. tostring(systemName))
  if not systemName then
    return
  end
  if not self.syncReddotState then
    self.syncReddotState = {}
  end
  return self.syncReddotState[systemName] or {}
end
function logic_reddot_limitation:IsShowingReddot(widget)
  local data = self.reddotWidgets[widget]
  if not data then
    return
  else
    return data.bIsShowingReddot
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_reddot_limitation = class(CModuleBase, nil, logic_reddot_limitation)
return Clogic_reddot_limitation