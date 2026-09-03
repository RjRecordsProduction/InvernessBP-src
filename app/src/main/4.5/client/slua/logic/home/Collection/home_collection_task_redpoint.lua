local home_collection_task_redpoint = {}
local redPoint
local bInit = false
local GenerateData = function()
  local redDot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = redDot_macro.Category
  local data = {
    newCount = 0,
    desc = redDot_macro.SystemName.ManorTask,
    types = {
      newCount = 0,
      [1] = {
        newCount = 0,
        category = Category.Receive,
        subID = 1
      }
    }
  }
  return data
end
function home_collection_task_redpoint.InitData()
  if bInit then
    return
  end
  bInit = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if redPoint == nil then
    redPoint = super_data.CreateSuperData(data)
  else
    for k, v in pairs(data) do
      redPoint[k] = v
    end
  end
  local redDot_manager = require("client.slua.logic.reddot.reddot_manager")
  redDot_manager:Regist(redPoint)
  home_collection_task_redpoint.InitRedpointCount()
end
function home_collection_task_redpoint.OnLogin()
  log(bWriteLog and "home_collection_task_redpoint.OnLogin")
  home_collection_task_redpoint.InitData()
end
function home_collection_task_redpoint.OnLogout()
  log(bWriteLog and "home_collection_task_redpoint.OnLogout")
  home_collection_task_redpoint.DestroyData()
end
function home_collection_task_redpoint.DestroyData()
  redPoint = nil
  bInit = false
end
function home_collection_task_redpoint.UpdateRedpointCount(count)
  if redPoint then
    redPoint.types[1].newCount = count
  end
end
function home_collection_task_redpoint.GetData()
  return redPoint
end
function home_collection_task_redpoint.InitRedpointCount()
  local award_flag = LobbySystem.roleData.manor_task_award_flag
  if award_flag and award_flag == 1 then
    log(bWriteLog and "home_collection_task_redpoint.InitRedpointCount award_flag == 1")
    home_collection_task_redpoint.UpdateRedpointCount(1)
  end
end
return home_collection_task_redpoint