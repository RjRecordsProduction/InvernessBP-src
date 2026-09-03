local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local lbs_reddot_data = {}
local isInited = false
local pendingReddotsToAdd = {}
local superReddotData = {}
local pendingReddotsToRemove = {}
local GenerateDefaultData = function()
  return {
    desc = reddot_macro.SystemName.WarZone,
    category = reddot_macro.Category.Other,
    subID = 1,
    newCount = 0,
    instances = {_isLeaf = true}
  }
end
function lbs_reddot_data.AddReddot(instanceId)
  if not isInited then
    table.insert(pendingReddotsToAdd, instanceId)
    lbs_reddot_data.InitData()
  end
  if not superReddotData.instances then
    superReddotData.instances = {_isLeaf = true}
  end
  superReddotData.instances[instanceId] = true
end
function lbs_reddot_data.EliminateReddot()
  if not isInited then
    lbs_reddot_data.InitData()
  end
  if not superReddotData.instances then
    superReddotData.instances = {_isLeaf = true}
  end
  if superReddotData.instances then
    for k, v in pairs(superReddotData.instances) do
      superReddotData.instances[k] = nil
    end
  end
end
function lbs_reddot_data.RemoveReddot(instanceId)
  if not isInited then
    table.insert(pendingReddotsToRemove, instanceId)
    lbs_reddot_data.InitData()
  end
  if not superReddotData.instances then
    superReddotData.instances = {_isLeaf = true}
  end
  if superReddotData.instances[instanceId] then
    superReddotData.instances[instanceId] = nil
  end
end
function lbs_reddot_data.GetData()
  if not isInited then
    lbs_reddot_data.InitData()
  end
  if superReddotData == nil or superReddotData.GetParent == nil then
    local super_data = require("common.super_data")
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    superReddotData = GenerateDefaultData()
    superReddotData = super_data.CreateSuperData(superReddotData)
    reddot_manager:Regist(superReddotData)
  end
  return superReddotData
end
function lbs_reddot_data.InitData()
  if isInited then
    return
  end
  local super_data = require("common.super_data")
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  superReddotData = GenerateDefaultData()
  superReddotData = super_data.CreateSuperData(superReddotData)
  reddot_manager:Regist(superReddotData)
  isInited = true
  for i = 1, #pendingReddotsToAdd do
    lbs_reddot_data.AddReddot(pendingReddotsToAdd[i])
  end
  for i = 1, #pendingReddotsToRemove do
    lbs_reddot_data.RemoveReddot(pendingReddotsToAdd[i])
  end
  local lbsMgr = require("client.slua.logic.lbs.logic_lbs")
  lbsMgr.UpdateWarZoneRedPoint()
end
function lbs_reddot_data.DestroyData()
  superReddotData = nil
  isInited = false
end
function lbs_reddot_data.OnLogin()
  isInited = false
  lbs_reddot_data.InitData()
end
function lbs_reddot_data.OnLogout()
  lbs_reddot_data.DestroyData()
end
return lbs_reddot_data