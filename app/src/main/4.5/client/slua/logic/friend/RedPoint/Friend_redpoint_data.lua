local FriendRedPointData = {}
local redpoint
local isInited = false
local delegateContainer
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    desc = "friend",
    pages = {
      newCount = 0,
      [1] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.NewArrivals
      },
      [2] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.NewArrivals
      }
    }
  }
  return data
end
function FriendRedPointData.InitData()
  if isInited then
    return
  end
  isInited = true
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local super_data = require("common.super_data")
  local data = GenerateData()
  redpoint = {}
  redpoint = super_data.CreateSuperData(data)
  log_tree("FriendRedPointData.InitData", redpoint)
  log_tree("FriendRedPointData.InitData", data)
  reddot_manager:Regist(redpoint)
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, FriendRedPointData.OnBackLogin)
end
function FriendRedPointData.GetRedPointSuperData()
  return redpoint
end
function FriendRedPointData.OnLogin()
  FriendRedPointData.InitData()
end
function FriendRedPointData.OnBackLogin()
  redpoint = nil
  isInited = false
  EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, FriendRedPointData.OnBackLogin)
end
function FriendRedPointData.AddAllRedPointData()
  log_tree("FriendRedPointData.AddAllRedPointData ", redpoint)
end
function FriendRedPointData.AddRedPointData(type)
  log(bWriteLog and "FriendRedPointData.AddRedPointData " .. type)
  if redpoint then
    redpoint.pages[type].newCount = 1
  end
end
function FriendRedPointData.RemoveRedPointData(type)
  log(bWriteLog and "FriendRedPointData.RemoveRedPointData " .. type)
  if redpoint then
    redpoint.pages[type].newCount = 0
  end
end
return FriendRedPointData