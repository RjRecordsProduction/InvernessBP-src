local NewbieRewardABTestRedDot = {}
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local systemName = reddot_macro.SystemName.NewbieRewardABTest
local activityConfig = require("client.slua.logic.activity.newbie.logic_newbie_activity_config")
local SubID = activityConfig.activityDef
local superRedPoint = {}
local isInited = false
local GetData = function()
  local data = {
    desc = systemName,
    newCount = 0,
    subID = SubID.Main,
    pages = {
      newCount = 0,
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
      [SubID.Reward] = {
        newCount = 0,
        subID = SubID.Reward,
        category = reddot_macro.Category.Receive,
        instances = {_isLeaf = true}
      },
      [SubID.Privilege] = {newCount = 0}
    }
  }
  return data
end
function NewbieRewardABTestRedDot.OnLogin()
end
function NewbieRewardABTestRedDot.OnLogout()
  isInited = false
  superRedPoint = {}
  EventSystem:unregistEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_TASK_UPDATE_REWARD, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:unregistEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_POINTS_UPDATE_SCORE, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:unregistEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_LOGIN_DAY_CHANGE, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:unregistEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_UPDATE_ALL_INFO, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:unregistEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_DAILY_LOGIN_DAY, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:unregistEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_UPGRADE_DATA, NewbieRewardABTestRedDot.UpdateRedDot)
end
function NewbieRewardABTestRedDot.UpdateRedDot()
  if not isInited then
    return
  end
  local logicNewbieMain = require("client.slua.logic.activity.newbie.logic_newbie_activity_config")
  local configList = logicNewbieMain.NewbieRewardABTestConfig
  for i = 1, #configList do
    local config = configList[i]
    if config.moduleName then
      local logicModule = require(config.moduleName) or {}
      if config.redDotCount then
        local funcCfg = logicModule[config.redDotCount]
        if funcCfg and type(funcCfg) == "function" then
          local logic_newbie_reward_abtest_reddot = require("client.slua.logic.activity.newbie.logic_newbie_reward_abtest_reddot")
          local redPointData = logic_newbie_reward_abtest_reddot.GetSuperDataByAct(config.activityType)
          funcCfg(redPointData)
        end
      end
    end
  end
end
function NewbieRewardABTestRedDot.InitData()
  if isInited then
    return
  end
  isInited = true
  local super_data = require("common.super_data")
  local data = GetData()
  superRedPoint = super_data.CreateSuperData(data)
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  reddot_manager:Regist(superRedPoint)
  EventSystem:registEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_TASK_UPDATE_REWARD, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:registEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_POINTS_UPDATE_SCORE, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:registEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_LOGIN_DAY_CHANGE, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:registEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_UPDATE_ALL_INFO, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:registEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_DAILY_LOGIN_DAY, NewbieRewardABTestRedDot.UpdateRedDot)
  EventSystem:registEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_UPGRADE_DATA, NewbieRewardABTestRedDot.UpdateRedDot)
  log(bWriteLog and "NewbieRewardABTestRedDot:InitData - Init red dot finished")
end
function NewbieRewardABTestRedDot.GetSuperData()
  NewbieRewardABTestRedDot.InitData()
  return superRedPoint
end
function NewbieRewardABTestRedDot.GetSuperDataByAct(actID)
  if superRedPoint and superRedPoint.pages then
    return superRedPoint.pages[actID]
  end
end
return NewbieRewardABTestRedDot