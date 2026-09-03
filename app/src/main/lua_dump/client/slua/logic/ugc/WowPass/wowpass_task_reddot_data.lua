local wowpass_task_reddot_data = {}
local superRedPoint
local isInited = false
local GenDefaultSubData = function(subID, category)
  local data = {
    newCount = 0,
    category = category,
      }
  return data
end
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.UGCWOWPassTask,
    SubDatas = {newCount = 0}
  }
  return data
end
function wowpass_task_reddot_data.InitData()
  if isInited then
    return
  end
  isInited = true
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local super_data = require("common.super_data")
  local data = GenerateData()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local reddotData = GenDefaultSubData(1, reddot_macro.Category.Receive)
  data.SubDatas[1] = reddotData
  if superRedPoint == nil then
    superRedPoint = super_data.CreateSuperData(data)
  else
    for k, v in pairs(data) do
      superRedPoint[k] = v
    end
  end
  reddot_manager:Regist(superRedPoint)
end
function wowpass_task_reddot_data.OnLogin()
  log(bWriteLog and "wowpass_task_reddot_data.OnLogin")
  wowpass_task_reddot_data.InitData()
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  if logic_ugc_WOWPass then
    logic_ugc_WOWPass:ReqUGCWOWRedPointInfo()
  end
end
function wowpass_task_reddot_data.OnLogout()
  wowpass_task_reddot_data.DestroyData()
end
function wowpass_task_reddot_data.GetData()
  return superRedPoint
end
function wowpass_task_reddot_data.HasRedDot()
  if not superRedPoint then
    return false
  end
  local reddotData = superRedPoint.SubDatas[1]
  if reddotData and reddotData.newCount and reddotData.newCount > 0 then
    return true
  end
  return false
end
function wowpass_task_reddot_data.SetNewCount(newCount)
  if superRedPoint then
    superRedPoint.groupShow = true
    local data = superRedPoint.SubDatas[1]
    if data then
      data.    end
  end
end
function wowpass_task_reddot_data.UpdateRedDot()
  log(bWriteLog and "wowpass_task_reddot_data.UpdateRedDot")
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  local bShow = logic_ugc_WOWPass:GetWOWPassTaskRedDotState()
  wowpass_task_reddot_data.SetNewCount(bShow and 1 or 0)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_TASK_REDDOT_UPDATE)
end
function wowpass_task_reddot_data.DestroyData()
  superRedPoint = nil
  isInited = false
end
return wowpass_task_reddot_data