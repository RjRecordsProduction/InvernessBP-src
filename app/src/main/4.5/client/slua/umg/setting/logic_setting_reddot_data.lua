local logic_setting_reddot_data = {}
local redpoint
local isInited = false
local reddot_const_list
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.Setting,
    category = Category.Other,
    subID = 1
  }
  return data
end
function logic_setting_reddot_data.InitData()
  if isInited then
    return
  end
  isInited = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if redpoint == nil then
    redpoint = super_data.CreateSuperData(data)
  end
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  reddot_manager:Regist(redpoint)
end
function logic_setting_reddot_data.OnLogin()
  log(bWriteLog and "logic_setting_reddot_data OnLogin")
  logic_setting_reddot_data.InitData()
end
function logic_setting_reddot_data.OnLogout()
  log(bWriteLog and "logic_setting_reddot_data OnLogout")
  logic_setting_reddot_data.DestroyData()
end
function logic_setting_reddot_data.DestroyData()
  redpoint = nil
  isInited = false
  reddot_const_list = nil
end
function logic_setting_reddot_data.GetData()
  return redpoint
end
function logic_setting_reddot_data.AddReddot(reddot_const)
  reddot_const_list = reddot_const_list or {}
  if not reddot_const or reddot_const_list[reddot_const] then
    return
  end
  reddot_const_list[reddot_const] = true
  if redpoint == nil then
    logic_setting_reddot_data.InitData()
  end
  redpoint.newCount = redpoint.newCount + 1
end
function logic_setting_reddot_data.RemoveReddot(reddot_const)
  reddot_const_list = reddot_const_list or {}
  if not reddot_const or not reddot_const_list[reddot_const] then
    return
  end
  reddot_const_list[reddot_const] = false
  if redpoint == nil then
    logic_setting_reddot_data.InitData()
  end
  redpoint.newCount = redpoint.newCount > 0 and redpoint.newCount - 1 or 0
end
return logic_setting_reddot_data