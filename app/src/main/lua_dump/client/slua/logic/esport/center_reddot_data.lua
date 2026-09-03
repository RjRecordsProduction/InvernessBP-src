local center_reddot_data = {}
local redpoint
local isInited = false
local ReddotType = {Center = 1}
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.EsportCenter,
    types = {
      newCount = 0,
      [ReddotType.Center] = {
        newCount = 0,
        category = Category.Other,
        subID = 1
      }
    }
  }
  return data
end
function center_reddot_data.InitData()
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
function center_reddot_data.OnLogin()
  log(bWriteLog and "center_reddot_data OnLogin")
  center_reddot_data.InitData()
end
function center_reddot_data.OnLogout()
  log(bWriteLog and "center_reddot_data OnLogout")
  center_reddot_data.DestroyData()
end
function center_reddot_data.DestroyData()
  redpoint = nil
  isInited = false
end
function center_reddot_data.GetCenterRedPointData()
  if redpoint then
    return redpoint.types[ReddotType.Center]
  end
end
function center_reddot_data.UpdateCenterCount(count)
  if redpoint then
    redpoint.types[ReddotType.Center].newCount = count
  end
end
function center_reddot_data.SendRemoveCenterTlog()
end
function center_reddot_data.GetData()
  return redpoint
end
function center_reddot_data.GetDescription(subID)
  local msg = ""
  if subID == 1 then
    msg = LocUtil.GetLocalizeResStr(18842)
  end
  return msg
end
return center_reddot_data