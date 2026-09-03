local NewbieActivityRedDot = {}
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local systemName = reddot_macro.SystemName.NewbieActivity
local activityConfig = require("client.slua.logic.activity.newbie.logic_newbie_activity_config")
local SubID = activityConfig.activityDef
local superRedPoint = {}
local isInited = false
local UpdateAchievenment = function(data, actID)
  local logicNewbieAchievement = require("client.slua.logic.activity.newbie.logic_newbie_achievement")
  data.pages = {}
  data.pages.newCount = 0
  for i = 1, #logicNewbieAchievement.taskList do
    data.pages[#data.pages + 1] = {
      newCount = 0,
      subID = actID,
      category = reddot_macro.Category.Receive,
      instances = {_isLeaf = true}
    }
  end
end
local GetData = function()
  local data = {
    desc = systemName,
    newCount = 0,
    subID = SubID.Main,
    pages = {
      newCount = 0,
      [SubID.Training] = {
        newCount = 0,
        pages = {
          newCount = 0,
          [1] = {
            newCount = 0,
            subID = SubID.Training,
            category = reddot_macro.Category.Receive,
            instances = {_isLeaf = true}
          },
          [2] = {
            newCount = 0,
            subID = SubID.Training,
            category = reddot_macro.Category.Receive,
            instances = {_isLeaf = true}
          },
          [3] = {
            newCount = 0,
            subID = SubID.Training,
            category = reddot_macro.Category.Receive,
            instances = {_isLeaf = true}
          },
          [4] = {
            newCount = 0,
            subID = SubID.Training,
            category = reddot_macro.Category.Receive,
            instances = {_isLeaf = true}
          },
          [5] = {
            newCount = 0,
            subID = SubID.Training,
            category = reddot_macro.Category.Receive,
            instances = {_isLeaf = true}
          },
          [6] = {
            newCount = 0,
            subID = SubID.Training,
            category = reddot_macro.Category.Receive,
            instances = {_isLeaf = true}
          },
          [7] = {
            newCount = 0,
            subID = SubID.Training,
            category = reddot_macro.Category.Receive,
            instances = {_isLeaf = true}
          }
        }
      },
      [SubID.Achievement] = {newCount = 0},
      [SubID.Spin] = {
        newCount = 0,
        subID = SubID.Spin,
        category = reddot_macro.Category.Receive,
        instances = {_isLeaf = true}
      },
      [SubID.Sprint] = {
        newCount = 0,
        subID = SubID.Sprint,
        category = reddot_macro.Category.Receive,
        instances = {_isLeaf = true}
      },
      [SubID.EightDay] = {
        newCount = 0,
        subID = SubID.EightDay,
        category = reddot_macro.Category.Receive,
        instances = {_isLeaf = true}
      },
      [SubID.FriendsGathering] = {
        newCount = 0,
        subID = SubID.FriendsGathering,
        category = reddot_macro.Category.Other,
        instances = {_isLeaf = true}
      }
    }
  }
  UpdateAchievenment(data.pages[SubID.Achievement], SubID.Achievement)
  return data
end
function NewbieActivityRedDot.OnLogin()
end
function NewbieActivityRedDot.OnLogout()
  isInited = false
  superRedPoint = {}
  EventSystem:unregistEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA, NewbieActivityRedDot.UpdateRedDot)
  EventSystem:unregistEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_LOBBY_ENTRANCE_UPDATE, NewbieActivityRedDot.UpdateRedDot)
  EventSystem:unregistEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_POINT_CHANGE, NewbieActivityRedDot.UpdateRedDot)
  EventSystem:unregistEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_SYNC, NewbieActivityRedDot.UpdateRedDot)
  EventSystem:unregistEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_GET_DATA, NewbieActivityRedDot.UpdateRedDot)
end
function NewbieActivityRedDot.UpdateRedDot()
  if not isInited then
    log_warning(bWriteLog and "NewbieActivityRedDot.UpdateRedDot not init")
    return
  end
  log(bWriteLog and "NewbieActivityRedDot.UpdateRedDot. start update")
  local logicNewbieMain = require("client.slua.logic.activity.newbie.logic_newbie_activity_config")
  local configList = logicNewbieMain.config
  for i = 1, #configList do
    local config = configList[i]
    if config.moduleName then
      local logicModule = require(config.moduleName) or {}
      if config.redDotCount then
        local funcCfg = logicModule[config.redDotCount]
        if funcCfg and type(funcCfg) == "function" then
          local redPointData = NewbieActivityRedDot.GetSuperDataByAct(config.activityType)
          funcCfg(redPointData)
        end
      end
    end
  end
end
function NewbieActivityRedDot.InitData()
  if isInited then
    log_warning(bWriteLog and "NewbieActivityRedDot.InitData already init")
    return
  end
  local logicNewbieAchievement = require("client.slua.logic.activity.newbie.logic_newbie_achievement")
  if not logicNewbieAchievement.taskList then
    log_warning(bWriteLog and "NewbieActivityRedDot.InitData taskList is nil")
    return
  end
  log(bWriteLog and "NewbieActivityRedDot.InitData start init")
  isInited = true
  local super_data = require("common.super_data")
  local data = GetData()
  superRedPoint = super_data.CreateSuperData(data)
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  reddot_manager:Regist(superRedPoint)
  EventSystem:registEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA, NewbieActivityRedDot.UpdateRedDot)
  EventSystem:registEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_LOBBY_ENTRANCE_UPDATE, NewbieActivityRedDot.UpdateRedDot)
  EventSystem:registEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_POINT_CHANGE, NewbieActivityRedDot.UpdateRedDot)
  EventSystem:registEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_SYNC, NewbieActivityRedDot.UpdateRedDot)
  EventSystem:registEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_GET_DATA, NewbieActivityRedDot.UpdateRedDot)
  log(bWriteLog and "==============> newbie activity init red dot finished")
end
function NewbieActivityRedDot.GetSuperData()
  NewbieActivityRedDot.InitData()
  return superRedPoint
end
function NewbieActivityRedDot.GetSuperDataByAct(actID)
  if superRedPoint and superRedPoint.pages then
    return superRedPoint.pages[actID]
  end
end
return NewbieActivityRedDot