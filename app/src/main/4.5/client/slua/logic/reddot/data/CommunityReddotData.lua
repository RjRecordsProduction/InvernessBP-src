local CommunityReddotData = {}
local redData
local bInit = false
function CommunityReddotData.OnLogin()
  CommunityReddotData.InitData()
end
function CommunityReddotData.OnLogout()
  log(bWriteLog and "CommunityReddotData.OnLogout")
  bInit = false
  redData = nil
end
function CommunityReddotData.InitData()
  if bInit then
    return
  end
  bInit = true
  local reddot_util = require("client.slua.logic.reddot.reddot_util")
  local data = {
    newCount = 0,
    desc = "community",
    leaf_1 = reddot_util.CreateLeafData(1),
    leaf_2 = reddot_util.CreateLeafData(2),
    leaf_3 = reddot_util.CreateLeafData(3),
    leaf_4 = reddot_util.CreateLeafData(4),
    leaf_5 = reddot_util.CreateLeafData(5)
  }
  local super_data = require("common.super_data")
  if redData == nil then
    redData = super_data.CreateSuperData(data)
  end
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  reddot_manager:Regist(redData)
end
function CommunityReddotData.SetRed(subId)
  log(bWriteLog and "CommunityReddotData.SetRed subId = " .. subId)
  if redData == nil then
    CommunityReddotData.InitData()
  end
  redData["leaf_" .. subId].instanceID[subId] = true
end
function CommunityReddotData.ClearRed(subId)
  log(bWriteLog and "CommunityReddotData.ClearRed subId = " .. subId)
  if redData == nil then
    return
  end
  redData["leaf_" .. subId].instanceID[subId] = nil
end
function CommunityReddotData.GetData()
  return redData
end
return CommunityReddotData