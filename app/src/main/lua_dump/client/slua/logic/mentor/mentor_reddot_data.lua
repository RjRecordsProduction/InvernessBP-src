local reddot_id = {task_award = 1, battle_award = 2}
local MentorRedPointData = {
  countFieldName = "newCount",
  desc = "mentor",
  }
local superRedPoint
local isInited = false
local delegateContainer
local GenDefaultSubData = function(subID, category)
  local data = {
    newCount = 0,
    category = category,
      }
  return data
end
local GenerateData = function()
  local data = {
    newCount = 0,
    SubDatas = {newCount = 0}
  }
  data.desc = MentorRedPointData.desc
  return data
end
local ClearListeners = function()
  if delegateContainer then
    delegateContainer:Dispose()
    delegateContainer = nil
  end
end
function MentorRedPointData.InitData()
  if isInited then
    return
  end
  isInited = true
  ClearListeners()
  local delegate_container = require("common.delegate_container")
  delegateContainer = delegate_container()
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local super_data = require("common.super_data")
  local data = GenerateData()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  for _, reddotid in pairs(reddot_id) do
    local reddotData = GenDefaultSubData(reddotid, reddot_macro.Category.Receive)
    data.SubDatas[reddotid] = reddotData
  end
  if superRedPoint == nil then
    superRedPoint = super_data.CreateSuperData(data)
  else
    for k, v in pairs(data) do
      superRedPoint[k] = v
    end
  end
  reddot_manager:Regist(superRedPoint)
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_REDDOT_NOTIFY)
end
function MentorRedPointData.OnLogin()
  log(bWriteLog and "MentorRedPointData.OnLogin")
  MentorRedPointData.InitData()
end
function MentorRedPointData.OnLogout()
  MentorRedPointData.DestroyData()
end
function MentorRedPointData.GetData()
  return superRedPoint
end
function MentorRedPointData.SetNewCount(_reddot_id, newCount)
  log(bWriteLog and "MentorRedPointData.SetNewCount reddot_id:" .. tostring(_reddot_id) .. ",newCount:" .. tostring(newCount))
  if superRedPoint then
    local data = superRedPoint.SubDatas[_reddot_id]
    if data then
      data.    end
  end
end
function MentorRedPointData.UpdateRedDot()
  log(bWriteLog and "MentorRedPointData.HasRedDot")
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  if MentorSystem.award_common_status or MentorSystem.award_permanent_status then
    MentorRedPointData.SetNewCount(reddot_id.task_award, 1)
  else
    MentorRedPointData.SetNewCount(reddot_id.task_award, 0)
  end
  MentorRedPointData.SetNewCount(reddot_id.battle_award, MentorSystem.award_mentor_status and 1 or 0)
end
function MentorRedPointData.DestroyData()
  superRedPoint = nil
  isInited = false
end
return MentorRedPointData