local VoiceRecommendConditionItem = {}
function VoiceRecommendConditionItem:ctor(selfType, Config)
  if not Config then
    return
  end
  self.AndCondition = {}
  self.OrCondition = {}
  if Config.MainCondition then
    local MainConditionConfigClass = require(Config.MainCondition.LuaPath)
    local MainConditionItem = MainConditionConfigClass(Config.MainCondition.Params)
    self.  end
  if Config.AndCondition then
    for _, AndConditionConfig in pairs(Config.AndCondition) do
      local AndConditionConfigClass = require(AndConditionConfig.LuaPath)
      local AndConditionItem = AndConditionConfigClass(AndConditionConfig.Params)
      table.insert(self.AndCondition, AndConditionItem)
    end
  end
  if Config.OrCondition then
    for _, OrConditionConfig in pairs(Config.OrCondition) do
      local OrConditionConfigClass = require(OrConditionConfig.LuaPath)
      local OrConditionItem = OrConditionConfigClass(OrConditionConfig.Params)
      table.insert(self.OrCondition, OrConditionItem)
    end
  end
end
function VoiceRecommendConditionItem:DoCheckCondition()
  if self.MainConditionItem and not self.MainConditionItem:DoCheckCondition() then
    return false
  end
  for _, OrConditionItem in ipairs(self.OrCondition) do
    if OrConditionItem:DoCheckCondition() then
      if self.MainConditionItem then
        self.MainConditionItem:SetCD()
      end
      return true
    end
  end
  for _, AndConditionItem in ipairs(self.AndCondition) do
    if not AndConditionItem:DoCheckCondition() then
      return false
    end
  end
  if self.MainConditionItem then
    self.MainConditionItem:SetCD()
  end
  return true
end
function VoiceRecommendConditionItem:Clear()
  if self.MainConditionItem then
    self.MainConditionItem:Dispose()
    self.MainConditionItem = nil
  end
  for _, OrConditionItem in ipairs(self.OrCondition) do
    OrConditionItem:Dispose()
  end
  self.OrCondition = nil
  for _, AndConditionItem in ipairs(self.AndCondition) do
    AndConditionItem:Dispose()
  end
  self.AndCondition = nil
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CVoiceRecommendConditionItem = class(CDelegateContainer, nil, VoiceRecommendConditionItem)
return CVoiceRecommendConditionItem