local kol_reddot_config = {}
local redpoint
local isInited = false
local reddot_const_list
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.KolRank,
    category = Category.Other,
    subID = 1
  }
  return data
end
function kol_reddot_config.InitData()
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
function kol_reddot_config.OnLogin()
  log(bWriteLog and "center_reddot_data OnLogin")
  kol_reddot_config.InitData()
end
function kol_reddot_config.OnLogout()
  log(bWriteLog and "center_reddot_data OnLogout")
  kol_reddot_config.DestroyData()
end
function kol_reddot_config.DestroyData()
  redpoint = nil
  isInited = false
  reddot_const_list = nil
end
function kol_reddot_config.GetData()
  return redpoint
end
function kol_reddot_config.AddReddot(reddot_const)
  reddot_const_list = reddot_const_list or {}
  if not reddot_const or reddot_const_list[reddot_const] then
    return
  end
  reddot_const_list[reddot_const] = true
  if redpoint == nil then
    kol_reddot_config.InitData()
  end
  redpoint.newCount = redpoint.newCount + 1
end
function kol_reddot_config.RemoveReddot(reddot_const)
  reddot_const_list = reddot_const_list or {}
  if not reddot_const or not reddot_const_list[reddot_const] then
    return
  end
  reddot_const_list[reddot_const] = false
  if redpoint == nil then
    kol_reddot_config.InitData()
  end
  redpoint.newCount = redpoint.newCount > 0 and redpoint.newCount - 1 or 0
end
return kol_reddot_config