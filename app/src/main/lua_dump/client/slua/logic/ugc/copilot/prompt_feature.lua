local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local PromptFeature = {Owner = nil}
function PromptFeature:ctor()
  print(bWriteLog and "PromptFeature:ctor")
  self:ResetData()
end
function PromptFeature:ResetData()
  print(bWriteLog and "PromptFeature:ResetData")
  self.PromptDataCache = {}
end
function PromptFeature:OnInitialize()
  print(bWriteLog and "PromptFeature:OnInitialize")
end
function PromptFeature:GetOrCreateCacheData(tableName)
  if not self.PromptDataCache[tableName] then
    self.PromptDataCache[tableName] = {
      PromptWeightArr = {},
      TotalWeight = 0,
      PromptPool = {}
    }
  end
  return self.PromptDataCache[tableName]
end
function PromptFeature:InitPromptArrByTable(tableName)
  print(bWriteLog and string.format("PromptFeature:InitPromptArrByTable - tableName: %s", tostring(tableName)))
  if not tableName or tableName == "" then
    print(bWriteLog and "PromptFeature:InitPromptArrByTable - Invalid tableName")
    return
  end
  local cacheData = self:GetOrCreateCacheData(tableName)
  cacheData.TotalWeight = 0
  cacheData.PromptWeightArr = {}
  local Cfg = CDataTable.GetTable(tableName)
  if not Cfg then
    print(bWriteLog and string.format("PromptFeature:InitPromptArrByTable - Table not found: %s", tostring(tableName)))
    return
  end
  for ID, PromptInfo in pairs(Cfg) do
    cacheData.TotalWeight = cacheData.TotalWeight + PromptInfo.Weight
    table.insert(cacheData.PromptWeightArr, PromptInfo)
  end
  print(bWriteLog and string.format("PromptFeature:InitPromptArrByTable - Loaded %d prompts, TotalWeight: %d", #cacheData.PromptWeightArr, cacheData.TotalWeight))
end
function PromptFeature:GetRandomPromptsByTable(tableName)
  print(bWriteLog and string.format("PromptFeature:GetRandomPromptsByTable - tableName: %s", tostring(tableName)))
  if not tableName or tableName == "" then
    print(bWriteLog and "PromptFeature:GetRandomPromptsByTable - Invalid tableName")
    return {}
  end
  local cacheData = self:GetOrCreateCacheData(tableName)
  if #cacheData.PromptWeightArr == 0 then
    self:InitPromptArrByTable(tableName)
    cacheData = self.PromptDataCache[tableName]
  end
  if #cacheData.PromptWeightArr == 0 then
    print(bWriteLog and "PromptFeature:GetRandomPromptsByTable - No prompts available")
    return {}
  end
  local TableUtil = require("common.table_util")
  local PromptCountConfig = CDataTable.GetTable("AIGCConstConfig", 1001)
  local PromptCount = Config_UGC_Copilot.DefaultRandomPromptCount
  if PromptCountConfig then
    if type(PromptCountConfig) == "number" then
      PromptCount = PromptCountConfig
    elseif type(PromptCountConfig) == "table" and PromptCountConfig.Value then
      PromptCount = PromptCountConfig.Value
    end
  end
  print(bWriteLog and string.format("PromptFeature:GetRandomPromptsByTable - PromptCount: %s (type: %s)", tostring(PromptCount), type(PromptCount)))
  local Result = {}
  local MaxRandomCount = 10000
  local UsedCount = TableUtil.CountTable(cacheData.PromptPool)
  local RemainingCount = #cacheData.PromptWeightArr - UsedCount
  print(bWriteLog and string.format("PromptFeature:GetRandomPromptsByTable - Before reset - UsedCount: %d, RemainingCount: %d, TotalCount: %d", UsedCount, RemainingCount, #cacheData.PromptWeightArr))
  if PromptCount > RemainingCount then
    print(bWriteLog and string.format("PromptFeature:GetRandomPromptsByTable - Pool exhausted, resetting pool..."))
    cacheData.PromptPool = {}
    UsedCount = TableUtil.CountTable(cacheData.PromptPool)
    RemainingCount = #cacheData.PromptWeightArr - UsedCount
    print(bWriteLog and string.format("PromptFeature:GetRandomPromptsByTable - After reset - UsedCount: %d, RemainingCount: %d", UsedCount, RemainingCount))
  end
  local LoopCount = 0
  local MaxRetry = 2
  for retry = 1, MaxRetry do
    for i = 1, MaxRandomCount do
      local RandomIndex = TableUtil.RandomIndexWeight(cacheData.PromptWeightArr, cacheData.TotalWeight)
      LoopCount = LoopCount + 1
      if not cacheData.PromptPool[RandomIndex] then
        cacheData.PromptPool[RandomIndex] = true
        table.insert(Result, cacheData.PromptWeightArr[RandomIndex])
        print(bWriteLog and string.format("PromptFeature:GetRandomPromptsByTable - Loop %d: Added index %d, Result count: %d", LoopCount, RandomIndex, #Result))
        if PromptCount <= #Result then
          print(bWriteLog and string.format("PromptFeature:GetRandomPromptsByTable - Reached target count, breaking loop"))
          break
        end
      end
    end
    if PromptCount <= #Result then
      break
    end
    if PromptCount > #Result and retry < MaxRetry then
      print(bWriteLog and string.format("PromptFeature:GetRandomPromptsByTable - Not enough results (%d/%d) after %d iterations, resetting pool and retrying...", #Result, PromptCount, LoopCount))
      cacheData.PromptPool = {}
    end
  end
  print(bWriteLog and string.format("PromptFeature:GetRandomPromptsByTable - Loop finished after %d iterations, Returned %d prompts (target: %d)", LoopCount, #Result, PromptCount))
  return Result
end
function PromptFeature:ResetPromptCache(tableName)
  print(bWriteLog and string.format("PromptFeature:ResetPromptCache - tableName: %s", tostring(tableName)))
  if tableName then
    self.PromptDataCache[tableName] = nil
  else
    self.PromptDataCache = {}
  end
end
local class = require("class")
local object = require("object")
return class(object, nil, PromptFeature)