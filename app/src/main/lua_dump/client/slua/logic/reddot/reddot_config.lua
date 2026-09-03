local ReddotConfig = {
  INVALID_SUBID = -1,
  INVALID_CATEGORY = 0,
  isGMOpen = false,
  bSkipReddotLimitation = false
}
local local local local TableUtil = require("common.table_util")
local RedDotDriver
local math_ceil = require("math").ceil
local ReddotSystemConfig = {}
local ProtoNameMapping = {
  WeekOnlineTimeSD = 1,
  EliminateTimeSD = 2,
  WeekOnlineTimeAvg = 3,
  EliminateTimeAvg = 4,
  MessageReadSD = 5,
  MessageReadAvg = 6
}
local ReddotArgsID = {ReddotLimitID = 1, EntryRefreshCDID = 2}
local OverallData = {}
local DynamicWeight = {}
local DynamicWeightParameters
local InnerDepth = 5
local TextDescStyle = 5
local TextDescStyleThreshold = 100
function ReddotConfig:InitializeSystemConfig()
  local reddotConfig = CDataTable.GetTable("ReddotConfig")
  local idxToName = {}
  for i, v in pairs(reddotConfig) do
    ReddotSystemConfig[v.Name] = {
      Config = v,
      SubConfig = {}
    }
    idxToName[v.ID] = v.Name
  end
  local reddotCategoryConfig = CDataTable.GetTable("ReddotCategoryConfig")
  for _, v in pairs(reddotCategoryConfig) do
    local name = idxToName[v.SystemID]
    if name then
      local subID = v.SubID
      ReddotSystemConfig[name].SubConfig[subID] = v
    else
      log_warning(bWriteLog and string.format("reddot_config reddotCategoryConfig SystemID[%s] not find ", tostring(v.SystemID)))
    end
  end
end
function ReddotConfig:IsEliminatePrimaryReddot(dataNode)
  local systemName = dataNode.desc
  return ReddotSystemConfig[systemName].Config.IsEliminatePrimaryReddot
end
function ReddotConfig:GetWeight(systemName, data)
  if data.desc == systemName then
    return self:GetSystemWeight(systemName)
  end
  if not data.subID or data.subID == ReddotConfig.INVALID_SUBID then
    return 0
  end
  local subConfig = ReddotSystemConfig[systemName].SubConfig
  if not subConfig then
    log_error(bWriteLog and string.format("ReddotConfig:GetWeight subConfig = nil\239\188\140 systemName[%s], subID[%s]", systemName, data.subID))
    return 0
  end
  local config = subConfig[data.subID]
  if not config then
    log_error(bWriteLog and string.format("ReddotConfig:GetWeight config = nil\239\188\140 systemName[%s], subID[%s]", systemName, data.subID))
    return 0
  end
  return config.Weight
end
function ReddotConfig:GetSystemWeight(systemName)
  if DynamicWeight[systemName] then
    local weight = DynamicWeight[systemName]
    log(bWriteLog and string.format("ReddotConfig:GetSystemWeight systemName [%s], weight [%s]", tostring(systemName), tostring(weight)))
    return weight
  else
    if not ReddotSystemConfig[systemName] then
      log_error(bWriteLog and string.format("ReddotConfig:GetSystemWeight ReddotSystemConfig = nil\239\188\140 systemName[%s]", systemName))
      return 0
    end
    local weight = ReddotSystemConfig[systemName].Config.Weight
    log(bWriteLog and string.format("ReddotConfig:GetSystemWeight systemName [%s], weight [%s]", tostring(systemName), tostring(weight)))
    return weight
  end
end
function ReddotConfig:GetSystemDefaultWeight(systemName)
  return ReddotSystemConfig[systemName].Config.Weight
end
function ReddotConfig:GetValidUserBySystemName(systemName)
  local systemConfig = ReddotSystemConfig[systemName]
  if not systemConfig then
    log_error(bWriteLog and string.format("reddot_configGetValidUser is nil, systemName[%s]", systemName))
    return ""
  end
  return systemConfig.Config.ValidUser
end
function ReddotConfig:GetValidUserBySubID(systemName, subID)
  local systemConfig = ReddotSystemConfig[systemName]
  if not systemConfig then
    log_error(bWriteLog and string.format("reddot_configGetValidUser is nil, systemName[%s]", systemName))
    return ""
  end
  if not subID or subID == ReddotConfig.INVALID_SUBID then
    return nil
  end
  local subConfig = systemConfig.SubConfig[subID]
  if not subConfig then
    log_error_format("ReddotConfig:GetValidUserBySubID subConfig = nil\239\188\140 systemName[%s], subID[%s]", systemName, subID)
    return nil
  end
  return subConfig.ValidUser
end
function ReddotConfig:GetSystemValidLevel(systemName)
  if not ReddotSystemConfig[systemName] then
    log_error_format("ReddotConfig:GetSystemValidLevel ReddotSystemConfig = nil\239\188\140 systemName[%s]", systemName)
  end
  if not ReddotSystemConfig[systemName].Config then
    log_error_format("ReddotConfig:GetSystemValidLevel ReddotSystemConfig.Config = nil\239\188\140 systemName[%s]", systemName)
  end
  return ReddotSystemConfig[systemName].Config.ValidLevel
end
function ReddotConfig:GetValidLevel(systemName, subID)
  if subID == ReddotConfig.INVALID_SUBID then
    return 0
  end
  local subConfig = ReddotSystemConfig[systemName].SubConfig
  if not subConfig then
    log_error(bWriteLog and string.format("ReddotConfig:GetValidLevel subConfig = nil\239\188\140 systemName[%s], subID[%s]", systemName, subID))
    return 0
  end
  local config = subConfig[subID]
  if not config then
    log_error(bWriteLog and string.format("ReddotConfig:GetValidLevel config = nil\239\188\140 systemName[%s], subID[%s]", systemName, subID))
    return 0
  end
  return config.ValidLevel or 0
end
function ReddotConfig:GetReddotConfigByName(systemName, subID)
  if not ReddotSystemConfig[systemName] then
    log_error(bWriteLog and string.format("ReddotConfig:GetReddotConfigByName ReddotSystemConfig = nil\239\188\140 systemName[%s], subID[%s]", systemName, subID))
    return nil
  end
  if not ReddotSystemConfig[systemName].SubConfig[subID] then
    log_error(bWriteLog and string.format("ReddotConfig:GetReddotConfigByName ReddotSystemConfig.SubConfig = nil\239\188\140 systemName[%s], subID[%s]", systemName, subID))
    return nil
  end
  return ReddotSystemConfig[systemName].SubConfig[subID]
end
function ReddotConfig:IsInMessageCenter(systemName, subID)
  return ReddotSystemConfig[systemName].SubConfig[subID].IsInMessageCenter
end
local GetTransferDepth = function(systemName, data, field)
  local subConfig = ReddotSystemConfig[systemName].SubConfig
  if not subConfig or not subConfig[data.subID] then
    log_warning(bWriteLog and string.format("reddot_config subConfig is nil, systemName[%s], subID[%s]", systemName, data.subID))
    return 0
  end
  local depth = subConfig[data.subID][field] or 0
  if 0 <= depth then
    depth = depth * 2 - 1
  else
    depth = data.depth + (depth * 2 + 1)
  end
  return depth
end
function ReddotConfig:GetInQueueTransferDepth(systemName, data)
  return GetTransferDepth(systemName, data, "InQueueLevel")
end
function ReddotConfig:GetOutQueueTransferDepth(systemName, data)
  return GetTransferDepth(systemName, data, "OutQueueLevel")
end
function ReddotConfig:GetReddotStyle(systemName, subID, depth, isLeaf)
  local subConfig = ReddotSystemConfig[systemName].SubConfig[subID]
  if not subConfig then
    log(bWriteLog and string.format("ReddotConfig:GetReddotStyle subConfig = nil\239\188\140 systemName[%s], subID[%s]", systemName, subID))
    return
  end
  local key
  local calculatedDepth = math_ceil((depth + 2) / 2)
  if isLeaf then
    key = "StyleInner"
  elseif calculatedDepth >= InnerDepth then
    key = "Style5OrInner"
  else
    key = "Style" .. calculatedDepth
  end
  local style = subConfig[key]
  if not style then
    return
  end
  if style >= TextDescStyleThreshold then
    local localizeId = style
    style = TextDescStyle
    if calculatedDepth == 1 then
      style = style + subConfig.StyleOrientation1
    end
    return TextDescStyle, LocUtil.GetLocalizeResStr(localizeId)
  else
    return style
  end
end
function ReddotConfig:GetReddotStylePath(systemName, subID, depth, isLeaf)
  local style = self:GetReddotStyle(systemName, subID, depth, isLeaf)
  local styleData = CDataTable.GetTableData("ReddotStyle", style)
  return styleData.Path
end
function ReddotConfig:SetOverallData(overallData)
  OverallData = overallData or {}
end
function ReddotConfig:SetReddotArgs(reddotArgs)
  log_tree("ReddotConfig:SetReddotArgs", reddotArgs)
  self.end
function ReddotConfig:GetReddotArgsByID(ID)
  local result = TableUtil.GetTableValue(self.reddotArgs, ID)
  if result then
    return result
  end
  local args = CDataTable.GetTableData("ReddotArgs", ID)
  return args and args.Value
end
function ReddotConfig:GetReddotLimitNumber()
  if ReddotConfig.bSkipReddotLimitation then
    log(bWriteLog and "logic_reddot_limitation:RegistReddotWidget skip reddot limit by GM")
    return 9999
  end
  return self:GetReddotArgsByID(ReddotArgsID.ReddotLimitID)
end
function ReddotConfig:GetEntryRefreshCD()
  local minuteTime = self:GetReddotArgsByID(ReddotArgsID.EntryRefreshCDID)
  local secondTime = minuteTime * 60
  if ReddotConfig.isGMOpen then
    secondTime = 5
  end
  return secondTime
end
function ReddotConfig:SetDynamicWeightArgs(dynamicWeightTable)
  if not dynamicWeightTable then
    log(bWriteLog and "[ReddotConfig] No DynamicWeightArgs from server!")
    return
  end
  local UID = tonumber(DataMgr.roleData.uid)
  if not UID then
    log(bWriteLog and "[ReddotConfig] UID is nil!")
    return
  end
  local num = 0
  local useData, useID
  for ID, data in pairs(dynamicWeightTable) do
    num = num + 1
    local bits = data.uid_tail_num
    local minimum = data.lower_bound_closed_interval
    local maximum = data.higher_bound_closed_interval
    local tail = UID % 10 ^ bits
    if minimum <= tail and maximum >= tail then
      useData = data
      use    end
  end
  if useData then
    DynamicWeightParameters = {
      ID = useID,
      k = useData.parm,
      k1 = useData.parm1,
      k2 = useData.parm2,
      k3 = useData.parm3
    }
  end
end
function ReddotConfig:CalcDynamicWeight()
  if not DynamicWeightParameters then
    log(bWriteLog and "[ReddotConfig] No dynamic weight parameters")
    return
  end
  for systemName, _ in pairs(ReddotSystemConfig) do
    if self:IsSystemOverallDataValid(systemName) and self:IsUserLocalDataValid(systemName) then
      DynamicWeight[systemName] = self:CalcOneSystemDynamicWeight(systemName)
    else
      DynamicWeight[systemName] = nil
    end
  end
end
function ReddotConfig:IsSystemOverallDataValid(systemName)
  local systemData = self:GetSystemOverallData(systemName)
  if not systemData then
    log(bWriteLog and "[RedDotConfig] CheckSystemOverallDataIsValid No Data : " .. tostring(systemName))
    return false
  end
  for tagName, enum in pairs(ProtoNameMapping) do
    local value = systemData[tostring(enum)]
    if not value or value <= 0 then
      log(bWriteLog and string.format("[RedDotConfig] CheckSystemOverallDataIsValid dirty or missing for %s", tagName))
      return false
    end
  end
  return true
end
function ReddotConfig:IsUserLocalDataValid(systemName)
  RedDotDriver = RedDotDriver or require("client.slua.logic.reddot.reddot_driver")
  local data = RedDotDriver:LoadSystemStatics(systemName)
  if not data then
    return false
  end
  if data.PlayerRedEliminateNum <= 10 or 10 >= data.SystemRedEliminateNum or data.WeekOnlineTimeSampleNum <= 1 then
    return false
  end
  if data.SystemAvgReadRate <= 0 or 0 >= data.SystemAvgEliminateTime or 0 >= data.SystemAvgWeekOnlineTime then
    return false
  end
  return true
end
function ReddotConfig:GetWeightCalcParameters()
  return DynamicWeightParameters.k, DynamicWeightParameters.k1, DynamicWeightParameters.k2, DynamicWeightParameters.k3, DynamicWeightParameters.ID
end
function ReddotConfig:CalcOneSystemDynamicWeight(systemName)
  RedDotDriver = RedDotDriver or require("client.slua.logic.reddot.reddot_driver")
  local data = RedDotDriver:LoadSystemStatics(systemName)
  local k, k1, k2, k3, ID = self:GetWeightCalcParameters()
  local initialWeight = self:GetSystemDefaultWeight(systemName)
  local A1 = data.SystemAvgEliminateTime
  local P1 = self:GetSystemOverallDataByTag(systemName, ProtoNameMapping.EliminateTimeAvg)
  local D1 = self:GetSystemOverallDataByTag(systemName, ProtoNameMapping.EliminateTimeSD)
  local A2 = data.SystemAvgReadRate
  local P2 = self:GetSystemOverallDataByTag(systemName, ProtoNameMapping.MessageReadAvg)
  local D2 = self:GetSystemOverallDataByTag(systemName, ProtoNameMapping.MessageReadSD)
  local A3 = data.SystemAvgWeekOnlineTime
  local P3 = self:GetSystemOverallDataByTag(systemName, ProtoNameMapping.WeekOnlineTimeAvg)
  local D3 = self:GetSystemOverallDataByTag(systemName, ProtoNameMapping.WeekOnlineTimeSD)
  if ID == 2 then
    D1 = P1
    D2 = P2
    D3 = P3
  end
  local weight = initialWeight * (k - k1 * (A1 - P1) / D1 - k2 * (A2 - P2) / D2 - k3 * (A3 - P3) / D3)
  log(bWriteLog and "CalcOneSystemDynamicWeight " .. systemName .. " " .. tostring(weight))
  return weight
end
function ReddotConfig:GetSystemOverallData(systemName)
  if OverallData then
    return OverallData[systemName]
  end
end
function ReddotConfig:GetSystemOverallDataByTag(systemName, tag)
  if OverallData then
    return OverallData[systemName][tostring(tag)]
  end
end
function ReddotConfig:ClearData()
  DynamicWeight = {}
  DynamicWeightParameters = nil
end
ReddotConfig:InitializeSystemConfig()
return ReddotConfig