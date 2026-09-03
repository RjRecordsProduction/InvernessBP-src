local ReddotManager = {}
local string_format = string.format
local string_find = string.find
local math_max = math.max
local local local local local local local local CD = 0
local CDTimer, asyncHandle
local frameworkReady = false
local ReddotConfig = require("client.slua.logic.reddot.reddot_config")
local reddot_group = require("client.slua.logic.reddot.reddot_group")
local ReddotDriver = require("client.slua.logic.reddot.reddot_driver")
local ReddotLimitNumber
local EntryRefreshCD = 15
local PriorityQueue = require("common.priority_queue")
local delegate_container = require("common.delegate_container")
local DelegateContainer = delegate_container()
local AddSuperDataListener = function(superdata, fieldname, notFirstCallBack, callback)
  return superdata:AddListener(fieldname, callback, notFirstCallBack)
end
local AddSuperDataNewIndexListener = function(superdata, callback)
  return superdata:AddNewIndexListener(callback)
end
local ReddotCompare = function(a, b)
  local weightA = a.realWeight
  local weightB = b.realWeight
  if weightA == weightB then
    return ReddotConfig:GetSystemWeight(a.desc) < ReddotConfig:GetSystemWeight(b.desc)
  end
  return weightA < weightB
end
local ReddotQueue = PriorityQueue(ReddotCompare)
local Data = {}
local super_data = require("common.super_data")
local IsInReddotQueue = super_data.CreateSuperData({})
local RegistedSystem = super_data.CreateSuperData({})
local BreathingQueue = {}
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local UserInfo = {
  userLevel = 0,
  userLabel = reddot_macro.UserLabel.RetainPlayer
}
local SystemAsncHandles = {}
local _CacheSystemValidForUserLabel = {}
local _CacheValidForUserLabel = {}
local _CacheValidForUserLevel = {}
local MonitorLeafNewCount = function(data)
  local OnReddotStateChange = function(oldValue, value)
    if oldValue == 0 and 0 < value or oldValue == value and 0 < value then
      data.realWeight = math_max(data.realWeight, data.weight)
      local parentData = data:GetParent()
      while parentData do
        if data.realWeight > parentData.realWeight or not parentData.subID then
          parentData.subID = data.subID or ReddotConfig.INVALID_SUBID
          parentData.category = data.category or ReddotConfig.INVALID_CATEGORY
        end
        parentData.realWeight = math_max(parentData.realWeight, parentData.weight, data.realWeight)
        parentData = parentData:GetParent()
      end
    elseif 0 < oldValue and value == 0 then
      data.realWeight = 0
      local parentData = data:GetParent()
      while parentData do
        local maxWeight = -1
        local category = ReddotConfig.INVALID_CATEGORY
        local subID = ReddotConfig.INVALID_SUBID
        for _, v in pairs(parentData) do
          if type(v) == "table" and v.realWeight and maxWeight < v.realWeight then
            maxWeight = v.realWeight
            category = v.category or category
            subID = v.subID or subID
          end
        end
        parentData.realWeight = maxWeight
        parentData.        parentData.        parentData = parentData:GetParent()
      end
    end
  end
  AddSuperDataListener(data, "newCount", false, OnReddotStateChange)
end
local MonitorLeaf = function(data)
  MonitorLeafNewCount(data)
end
local function MonitorData(data, systemName)
  if data.newCount == nil then
    return
  end
  if not ReddotManager:IsValidForUserLabel(systemName, data.subID) then
    return
  end
  data.subID = data.subID or ReddotConfig.INVALID_SUBID
  data.category = data.category or ReddotConfig.INVALID_CATEGORY
  data.realCount = 0
  data.weight = ReddotConfig:GetWeight(systemName, data)
  data.realWeight = 0
  local ShowInGroup = function(groupShow)
    if data.isEliminatePrimary then
      return groupShow and data.extraNewCount > 0
    else
      return groupShow
    end
  end
  local FuncWrapNewCount = function(_, value)
    data.realCount = (IsInReddotQueue[systemName] or ShowInGroup(data.groupShow)) and value or 0
  end
  AddSuperDataListener(data, "newCount", true, FuncWrapNewCount)
  local FuncWrapIsInReddotQueue = function(_, value)
    data.realCount = (value or ShowInGroup(data.groupShow)) and data.newCount or 0
  end
  AddSuperDataListener(IsInReddotQueue, systemName, true, FuncWrapIsInReddotQueue)
  local FuncWrapGroupShow = function(_, value)
    data.realCount = (IsInReddotQueue[systemName] or ShowInGroup(value)) and data.newCount or 0
  end
  AddSuperDataListener(data, "groupShow", true, FuncWrapGroupShow)
  local isLeaf = true
  if data.isDynamic then
    AddSuperDataNewIndexListener(data, function(keyName, childData)
      if type(childData) == "table" and childData._isLeaf == nil then
        MonitorData(data[keyName], systemName)
      end
    end)
    isLeaf = false
  end
  for _, v in pairs(data) do
    if type(v) == "table" and v._isLeaf == nil then
      MonitorData(v, systemName)
      isLeaf = false
    end
  end
  if isLeaf and ReddotManager:IsValidForUserLevel(systemName, data.subID) then
    MonitorLeaf(data)
  end
end
local GetReddotQueueSize = function()
  local markedGroup = {}
  local size = 0
  for _, rootNode in pairs(ReddotQueue) do
    local groupName = reddot_group:GetSystemGroupName(rootNode.desc)
    if groupName then
      if not markedGroup[groupName] then
        size = size + 1
        markedGroup[groupName] = true
      end
    else
      size = size + 1
    end
  end
  return size
end
local OnEntryChange = function(data, oldValue, value)
  local systemName = data.desc
  if data.isEliminatePrimary and data.extraNewCount == 0 then
    if IsInReddotQueue[systemName] then
      ReddotQueue:Remove(data)
      IsInReddotQueue[systemName] = false
    end
    return
  end
  if oldValue == value and 0 < value or oldValue < value then
    if IsInReddotQueue[systemName] then
      ReddotQueue:Modify(data)
      return
    elseif GetReddotQueueSize() < ReddotLimitNumber then
      ReddotQueue:Push(data)
      IsInReddotQueue[systemName] = true
      return
    else
      while ReddotCompare(ReddotQueue:Top(), data) do
        local deprecated = ReddotQueue:Pop()
        IsInReddotQueue[deprecated.desc] = false
        if GetReddotQueueSize() < ReddotLimitNumber then
          ReddotQueue:Push(data)
          IsInReddotQueue[systemName] = true
          return
        end
      end
    end
  elseif value <= 0 and IsInReddotQueue[systemName] then
    ReddotQueue:Remove(data)
    IsInReddotQueue[systemName] = false
    return
  end
end
local MonitorEntry = function(data)
  DelegateContainer:AddDataListener(data, "realWeight", OnEntryChange, data)
  if data.isEliminatePrimary then
    AddSuperDataListener(data, "extraNewCount", true, function(oldValue, value)
      if oldValue == 0 and 0 < value then
        OnEntryChange(data, oldValue, value)
      elseif 0 < oldValue and value == 0 then
        OnEntryChange(data, oldValue, value)
      end
    end)
  end
end
local ReddotEntryClicked = function(data)
  if data ~= nil and data.desc ~= nil and ReddotConfig:IsEliminatePrimaryReddot(data) then
    data.extraNewCount = 0
  end
end
local Dispose = function()
  DelegateContainer:Dispose()
  CDTimer = nil
  BreathingQueue = {}
  Data = {}
  for systemName, _ in pairs(RegistedSystem) do
    RegistedSystem[systemName] = false
  end
  ReddotQueue:Clear()
  for k, v in pairs(IsInReddotQueue) do
    IsInReddotQueue[k] = false
  end
  ReddotDriver:_Dispose()
end
function ReddotManager:RegistOne(data)
  local systemName = data and data.desc or ""
  if systemName == "" or Data[systemName] then
    log_error(bWriteLog and string_format("reddot_manager:Regist Reddot[%s] system duplicate regist!", systemName))
    return
  end
  local getTime = slua.getMicroseconds
  local start = getTime()
  Data[systemName] = data
  data.groupShow = false
  data.isEliminatePrimary = ReddotConfig:IsEliminatePrimaryReddot(data)
  MonitorData(data, systemName)
  ReddotDriver:_TreeDrive(data)
  MonitorEntry(data)
  log(bWriteLog and string_format("TimeTracer [ReddotManager:RegistOne]systemName:%s time:[%.3fms]", systemName, (getTime() - start) / 1000))
end
function ReddotManager:RegistImmediate(systemName, data)
  if not self:IsSystemValidForUserLabel(systemName) then
    RegistedSystem[systemName] = true
    return
  end
  local levelRequire = ReddotConfig:GetSystemValidLevel(systemName)
  if levelRequire <= UserInfo.userLevel then
    ReddotManager:RegistOne(data)
  end
  RegistedSystem[systemName] = true
end
function ReddotManager:Regist(data)
  local systemName = data.desc
  if not systemName or systemName == "" then
    log_error(bWriteLog and "ReddotManager:Regist \231\186\162\231\130\185\230\160\185\232\138\130\231\130\185desc\229\173\151\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129")
    return
  end
  if not frameworkReady then
    local async = require("client.common.async")
    if SystemAsncHandles[systemName] then
      async.Cancel(SystemAsncHandles[systemName])
    end
    SystemAsncHandles[systemName] = async.Run(function(co)
      async.AwaitEvent(co, nil, EVENTTYPE_REDDOT, EVENTID_REDDOT_SYSTEM_LOGIN)
      self:RegistImmediate(systemName, data)
      SystemAsncHandles[systemName] = nil
    end)
  else
    self:RegistImmediate(systemName, data)
  end
end
function ReddotManager:IsRegist(systemName)
  return Data[systemName] ~= nil
end
function ReddotManager:OnSystemShow(uiInstance, systemName)
  local rootData = Data[systemName]
  ReddotEntryClicked(rootData)
end
function ReddotManager:ListenIsInReddotQueue(systemName, callback)
  AddSuperDataListener(IsInReddotQueue, systemName, true, callback)
end
local ResetReddotQueue = function()
  while tonumber(ReddotQueue:Size()) and tonumber(ReddotLimitNumber) and ReddotQueue:Size() > ReddotLimitNumber do
    local deprecated = ReddotQueue:Pop()
    IsInReddotQueue[deprecated.desc] = false
  end
  for key, v in pairs(Data) do
    if v.realWeight > 0 and not IsInReddotQueue[key] then
      local queueSize = GetReddotQueueSize()
      if queueSize >= ReddotLimitNumber and ReddotCompare(ReddotQueue:Top(), v) then
        ReddotQueue:Push(v)
        IsInReddotQueue[key] = true
        local deprecated = ReddotQueue:Pop()
        IsInReddotQueue[deprecated.desc] = false
      elseif queueSize < ReddotLimitNumber then
        ReddotQueue:Push(v)
        IsInReddotQueue[key] = true
      end
    end
  end
end
local OnLogout = function()
  log_shipping_client("Reddot manager OnLogout")
  Dispose()
  local loginModules = reddot_macro.Login_Modules
  local moduleCount = #loginModules
  for i = moduleCount, 1, -1 do
    local m = require(loginModules[i])
    local func = m.OnLogout
    if func then
      func(m)
    else
      log_error("Reddot_manager OnLogout is nil loginModules: " .. loginModules[i])
    end
  end
  local async = require("client.common.async")
  for systemName, systemAsync in pairs(SystemAsncHandles) do
    async.Cancel(systemAsync)
    SystemAsncHandles[systemName] = nil
  end
  ReddotConfig:ClearData()
  EventSystem:postEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_SYSTEM_LOGOUT)
  frameworkReady = false
end
function ReddotManager:IsSystemValidForUserLabel(systemName)
  if _CacheSystemValidForUserLabel[systemName] then
    return _CacheSystemValidForUserLabel[systemName]
  end
  local systemValidUser = ReddotConfig:GetValidUserBySystemName(systemName)
  local userLable = UserInfo.userLabel
  if userLable and systemValidUser ~= "" and string_find(systemValidUser, userLable, 1, true) == nil then
    _CacheSystemValidForUserLabel[systemName] = false
    return false
  end
  _CacheSystemValidForUserLabel[systemName] = true
  return true
end
function ReddotManager:IsValidForUserLabel(systemName, subID)
  if not subID then
    return true
  end
  if _CacheValidForUserLabel[systemName] and _CacheValidForUserLabel[systemName][subID] then
    return _CacheValidForUserLabel[systemName][subID]
  end
  local subValidUser = ReddotConfig:GetValidUserBySubID(systemName, subID)
  local userLable = UserInfo.userLabel
  if subValidUser ~= "" and subValidUser ~= nil and string_find(subValidUser, userLable, 1, true) == nil then
    _CacheValidForUserLabel[systemName] = _CacheValidForUserLabel[systemName] or {}
    _CacheValidForUserLabel[systemName][subID] = false
    return false
  end
  _CacheValidForUserLabel[systemName] = _CacheValidForUserLabel[systemName] or {}
  _CacheValidForUserLabel[systemName][subID] = true
  return true
end
function ReddotManager:IsValidForUserLevel(systemName, subID)
  if _CacheValidForUserLevel[systemName] and _CacheValidForUserLevel[systemName][subID] then
    return _CacheValidForUserLevel[systemName][subID]
  end
  local levelRequire = ReddotConfig:GetValidLevel(systemName, subID)
  local userLevel = UserInfo.userLevel
  if 0 < levelRequire and levelRequire > userLevel then
    _CacheValidForUserLevel[systemName] = _CacheValidForUserLevel[systemName] or {}
    _CacheValidForUserLevel[systemName][subID] = false
    return false
  end
  _CacheValidForUserLevel[systemName] = _CacheValidForUserLevel[systemName] or {}
  _CacheValidForUserLevel[systemName][subID] = true
  return true
end
function ReddotManager:GetUserInfo()
  return UserInfo
end
function ReddotManager:GetRegistedSystem()
  return RegistedSystem
end
function ReddotManager:BindSystemEntry(delegateContainer, widget, systemName)
  delegateContainer:AddDataListener(RegistedSystem, systemName, function(_, registed)
    if registed then
      widget:Bind(Data[systemName])
    end
  end)
end
local InitReddotArgs = function()
  ReddotLimitNumber = ReddotConfig:GetReddotLimitNumber()
  EntryRefreshCD = ReddotConfig:GetEntryRefreshCD()
end
local OnLogin = function(co)
  log_shipping_client("Reddot manager OnLogin")
  local async = require("client.common.async")
  local roleData = async.AwaitEvent(co, nil, EVENTTYPE_LOGIN_ROLEDATA, EVENTID_LOGIN_ROLEDATA_SYNC)
  UserInfo.userLevel = roleData.level
  log_shipping_client("Reddot manager role data sync, user level: " .. tostring(UserInfo.userLevel))
  if DelegateContainer:IsCommonEventExists(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE) then
    DelegateContainer:RemoveCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE)
  end
  DelegateContainer:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, function()
    UserInfo.userLevel = DataMgr.roleData.level
  end)
  local overallData, userLabel, reddotArgs, dynamicWeightArgs = async.AwaitEvent(co, nil, EVENTTYPE_REDDOT, EVENTID_REDDOT_SYSTEM_OVER_ALL)
  UserInfo.  log_shipping_client("Reddot manager on receive system overall data, user label:" .. tostring(UserInfo.userLabel))
  ReddotConfig:SetOverallData(overallData)
  ReddotConfig:SetReddotArgs(reddotArgs)
  ReddotConfig:SetDynamicWeightArgs(dynamicWeightArgs)
  InitReddotArgs()
  for _, moduleName in ipairs(reddot_macro.Login_Modules) do
    local m = require(moduleName)
    m:OnLogin()
  end
  asyncHandle = nil
  local Utility = require("common.utility")
  xpcall(ReddotConfig.CalcDynamicWeight, Utility.ErrorMessageHandler, ReddotConfig)
  EventSystem:postEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_SYSTEM_LOGIN)
  frameworkReady = true
end
function ReddotManager.OnGameStateChange(_, _, gameState)
  if gameState.current == GameStatus.Login then
    if gameState.pre ~= GameStatus.Login and gameState.pre ~= "None" then
      OnLogout()
    end
    local async = require("client.common.async")
    if asyncHandle then
      async.Cancel(asyncHandle)
    end
    asyncHandle = async.Run(OnLogin)
  elseif gameState.current == GameStatus.Lobby then
    if gameState.pre == GameStatus.Fighting and CD > EntryRefreshCD then
      ResetReddotQueue()
      CD = 0
    end
    if not CDTimer then
      CDTimer = DelegateContainer:AddTimerLoop(60, function(deltaTime)
        CD = CD + deltaTime
      end, TIMER_INFINITE, 60)
    end
  end
end
return ReddotManager