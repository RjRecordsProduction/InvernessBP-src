local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local PromptFeature = {Owner = nil}
function PromptFeature:ctor()
  print(bWriteLog and "[copilot_prompt] PromptFeature:ctor")
  self:ResetData()
end
function PromptFeature:ResetData()
  print(bWriteLog and "[copilot_prompt] PromptFeature:ResetData")
  self.PromptDataCache = {}
end
function PromptFeature:OnInitialize()
  print(bWriteLog and "[copilot_prompt] PromptFeature:OnInitialize")
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
  print(bWriteLog and string.format("[copilot_prompt] InitPromptArrByTable - tableName: %s", tostring(tableName)))
  if not tableName or tableName == "" then
    print(bWriteLog and "[copilot_prompt] InitPromptArrByTable - Invalid tableName")
    return
  end
  local cacheData = self:GetOrCreateCacheData(tableName)
  cacheData.TotalWeight = 0
  cacheData.PromptWeightArr = {}
  local Cfg = CDataTable.GetTable(tableName)
  if not Cfg then
    print(bWriteLog and string.format("[copilot_prompt] InitPromptArrByTable - Table not found: %s", tostring(tableName)))
    return
  end
  local skippedCount = 0
  for ID, PromptInfo in pairs(Cfg) do
    if PromptInfo.Weight and 0 < PromptInfo.Weight then
      cacheData.TotalWeight = cacheData.TotalWeight + PromptInfo.Weight
      table.insert(cacheData.PromptWeightArr, PromptInfo)
    else
      skippedCount = skippedCount + 1
    end
  end
  print(bWriteLog and string.format("[copilot_prompt] InitPromptArrByTable - Loaded %d prompts, Skipped %d (Weight<=0), TotalWeight: %d", #cacheData.PromptWeightArr, skippedCount, cacheData.TotalWeight))
end
function PromptFeature:GetRandomPromptsByTable(tableName)
  print(bWriteLog and string.format("[copilot_prompt] GetRandomPromptsByTable - tableName: %s", tostring(tableName)))
  if not tableName or tableName == "" then
    print(bWriteLog and "[copilot_prompt] GetRandomPromptsByTable - Invalid tableName")
    return {}
  end
  local cacheData = self:GetOrCreateCacheData(tableName)
  if #cacheData.PromptWeightArr == 0 then
    self:InitPromptArrByTable(tableName)
    cacheData = self.PromptDataCache[tableName]
  end
  if #cacheData.PromptWeightArr == 0 then
    print(bWriteLog and "[copilot_prompt] GetRandomPromptsByTable - No prompts available")
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
  print(bWriteLog and string.format("[copilot_prompt] GetRandomPromptsByTable - PromptCount: %d, TotalCount: %d", PromptCount, #cacheData.PromptWeightArr))
  local Result = {}
  local MaxRandomCount = 10000
  local TotalCount = #cacheData.PromptWeightArr
  if PromptCount >= TotalCount then
    print(bWriteLog and string.format("[copilot_prompt] GetRandomPromptsByTable - TotalCount(%d) <= PromptCount(%d), return all", TotalCount, PromptCount))
    for i, v in ipairs(cacheData.PromptWeightArr) do
      table.insert(Result, v)
    end
    self:_PrintResultPrompts(tableName, Result)
    return Result
  end
  local UsedCount = TableUtil.CountTable(cacheData.PromptPool)
  local RemainingCount = TotalCount - UsedCount
  print(bWriteLog and string.format("[copilot_prompt] GetRandomPromptsByTable - UsedCount: %d, RemainingCount: %d, TotalCount: %d", UsedCount, RemainingCount, TotalCount))
  if PromptCount > RemainingCount then
    print(bWriteLog and "[copilot_prompt] GetRandomPromptsByTable - Pool exhausted, resetting pool...")
    cacheData.PromptPool = {}
  end
  for i = 1, MaxRandomCount do
    local RandomIndex = TableUtil.RandomIndexWeight(cacheData.PromptWeightArr, cacheData.TotalWeight)
    if not cacheData.PromptPool[RandomIndex] then
      cacheData.PromptPool[RandomIndex] = true
      table.insert(Result, cacheData.PromptWeightArr[RandomIndex])
      if PromptCount <= #Result then
        break
      end
    end
  end
  print(bWriteLog and string.format("[copilot_prompt] GetRandomPromptsByTable - Returned %d prompts (target: %d)", #Result, PromptCount))
  self:_PrintResultPrompts(tableName, Result)
  return Result
end
function PromptFeature:_PrintResultPrompts(tableName, result)
  if not bWriteLog then
    return
  end
  if not result or #result == 0 then
    return
  end
  for i, promptInfo in ipairs(result) do
    local title = promptInfo.Title or ""
    local titlePreview = string.sub(title, 1, 20)
    if 20 < #title then
      titlePreview = titlePreview .. "..."
    end
    print(string.format("[copilot_prompt] PromptResult - [%s] #%d index=%s title=\"%s\"", tostring(tableName), i, tostring(promptInfo.ID or "?"), titlePreview))
  end
end
function PromptFeature:ResetPromptCache(tableName)
  print(bWriteLog and string.format("[copilot_prompt] ResetPromptCache - tableName: %s", tostring(tableName)))
  if tableName then
    self.PromptDataCache[tableName] = nil
  else
    self.PromptDataCache = {}
  end
end
local class = require("class")
local object = require("object")
return class(object, nil, PromptFeature)