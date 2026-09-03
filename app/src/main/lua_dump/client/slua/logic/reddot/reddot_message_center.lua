local ReddotMessageCenter = {}
local super_data = require("common.super_data")
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local reddot_config = require("client.slua.logic.reddot.reddot_config")
local pb = require("pb")
local Messages = {}
Messages = super_data.CreateSuperData(Messages)
local SystemCategoryList = {}
local InitSystemCateGoryList = function()
  for k, category in pairs(reddot_macro.Category) do
    local element = {
      map = super_data.CreateSuperLeafData({})
    }
    SystemCategoryList[category] = element
  end
end
InitSystemCateGoryList()
local TryGetMessageByCategory = function(systemName, category)
  local categoryInstances = Messages[systemName]
  if not categoryInstances then
    Messages[systemName] = {}
    categoryInstances = Messages[systemName]
  end
  local messageCategory = categoryInstances[category]
  if not messageCategory then
    categoryInstances[category] = {_isLeaf = true}
    messageCategory = categoryInstances[category]
  end
  return messageCategory
end
function ReddotMessageCenter:OnReddotAdd(systemName, node, instanceKey)
  log(bWriteLog and "ReddotMessageCenter:OnReddotAdd systemName:" .. systemName .. ", instanceID:" .. instanceKey .. ", subID:" .. node.subID .. ", category:" .. node.category)
  if not reddot_config:IsInMessageCenter(systemName, node.subID) then
    return
  end
  local messageCategory = TryGetMessageByCategory(systemName, node.category)
  local element = SystemCategoryList[node.category]
  if not element then
    element = {
      map = super_data.CreateSuperLeafData({})
    }
    SystemCategoryList[node.category] = element
  end
  if not element.map[systemName] then
    element.map[systemName] = node.subID
  end
  messageCategory[instanceKey] = node.subID
end
function ReddotMessageCenter:OnReddotRemove(systemName, node, instanceKey)
  log(bWriteLog and "ReddotMessageCenter:OnReddotRemove systemName:" .. systemName .. ", instanceID:" .. instanceKey .. ", subID:" .. node.subID .. ", category:" .. node.category)
  if not reddot_config:IsInMessageCenter(systemName, node.subID) then
    return
  end
  self:ReddotRemove(systemName, node.subID, node.category, instanceKey)
end
function ReddotMessageCenter:ReddotRemove(systemName, subID, category, instanceKey)
  local messageCategory = TryGetMessageByCategory(systemName, category)
  messageCategory[instanceKey] = nil
  local element = SystemCategoryList[category]
  if not element then
    log_error(bWriteLog and "ReddotMessageCenter:ReddotRemove element should not be nil")
    return
  end
  if messageCategory:IsEmpty() then
    element.map[systemName] = nil
  end
end
function ReddotMessageCenter:OnCategoryChange(systemName, node, oldCategory, newCategory, instanceKey)
  self:ReddotRemove(systemName, node.subID, oldCategory, instanceKey)
  if node.newCount > 0 then
    self:OnReddotAdd(systemName, node, instanceKey)
  end
end
function ReddotMessageCenter:GetReadMod()
  return pb.enum("server_client.reddot_readmode", "Normal")
end
function ReddotMessageCenter:OnLogin()
end
function ReddotMessageCenter:OnLogout()
  Messages = super_data.CreateSuperData({})
  InitSystemCateGoryList()
end
function ReddotMessageCenter.GetMessages()
  return Messages
end
function ReddotMessageCenter.GetSystemCategoryList()
  return SystemCategoryList
end
function ReddotMessageCenter.GetSubID(systemName, category, instanceKey)
  return Messages[systemName][category][instanceKey]
end
return ReddotMessageCenter