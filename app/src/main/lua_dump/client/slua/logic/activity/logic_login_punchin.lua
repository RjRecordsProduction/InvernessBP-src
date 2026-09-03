local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
local LoginPunchInSystem = {JumpData = nil}
function LoginPunchInSystem.GetActivitySubData()
  log(bWriteLog and "  : LoginPunchInSystem.GetActivitySubData")
  local nActType = ActivityType.LoginPunchIn
  local tActData = ActivityNewSystem.GetActivityListByType(nActType)
  local tFinalActData = {}
  for _, v in ipairs(tActData) do
    if v.ShowSceneID == 5 then
      local data = {
        nActID = v.ID,
        sName = v.Title,
        nRedDotNum = LoginPunchInSystem.HasRedDotNum,
        nSwitchType = v.TabType or nil,
        nHasDoneRate = LoginPunchInSystem.GetCurActHasDoneRate(v.ID),
        startTime = v.StartTime,
        endTime = v.EndTime,
        Title = v.Title,
        ImgUrl = v.ImgUrl,
        nType = ActivityType.LoginPunchIn,
        subData = v.List,
        DisplayScene = v.DisplayScene
      }
      table.insert(tFinalActData, data)
    end
  end
  if next(tFinalActData) then
    log(bWriteLog and "  : LoginPunchInSystem exist data")
    return tFinalActData
  end
  return nil
end
function LoginPunchInSystem.GetRealDataByFatherActID(nActID)
  local tActData = ActivityNewSystem.GetActivityByID(nActID)
  local tSubActData = {}
  local StringUtil = require("common.string_util")
  if tActData and tActData.Condition then
    for _, v in pairs(StringUtil.Split(tActData.Condition, ",")) do
      if tonumber(v) == 0 then
        break
      end
      local tTempData = ActivityNewSystem.GetActivityByID(tonumber(v))
      if tTempData and next(tTempData) then
        table.insert(tSubActData, tTempData)
      end
    end
  end
  return tSubActData
end
function LoginPunchInSystem.HasRedDot(nActID)
  local tCurActData = LoginPunchInSystem.GetRealDataByFatherActID(nActID)
  local tActRedTable = {}
  for _, v in ipairs(tCurActData) do
    if ActivityNewSystem.HasActivityRedDotByID(v.ID) then
      table.insert(tActRedTable, v.ID)
    end
  end
  if next(tActRedTable) then
    return true, tActRedTable
  else
    return false, tActRedTable
  end
end
function LoginPunchInSystem.HasRedDotNum(nActID)
  local tActData = ActivityNewSystem.GetActivityByID(nActID)
  local tCurActData = LoginPunchInSystem.GetRealDataByFatherActID(nActID)
  local redNum = 0
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  for _, v in ipairs(tCurActData) do
    local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
    local tabName = ActivityCenterSystem.GetTabName(tActData.TabType)
    local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
    local displaySceneMap = v.DisplayScene
    if ActivityNewSystem.HasActivityRedDotByID(v.ID) then
      if not Logic_Activity_Center.skipRedCheck[v.ID] then
        Logic_Activity_Center.skipRedCheck[v.ID] = {}
      end
      Logic_Activity_Center.skipRedCheck[v.ID].bRed = true
      if displaySceneMap and next(displaySceneMap) then
        for displayScene, _ in pairs(displaySceneMap) do
          local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
          ActivityRedDot.AddRedDotNode(systemName, tActData.TabType, tabName, v.ID, true, ActivityMacros.RedDotType.Reward)
        end
      else
        local RedDotSystemName = ActivityRedDot.GetActFirstRedDotSystemName(v.ID)
        ActivityRedDot.AddRedDotNode(RedDotSystemName, tActData.TabType, tabName, v.ID, true, ActivityMacros.RedDotType.Reward)
      end
      redNum = 1
    elseif Logic_Activity_Center.skipRedCheck[v.ID] then
      Logic_Activity_Center.skipRedCheck[v.ID].bRed = false
      if displaySceneMap and next(displaySceneMap) then
        for displayScene, _ in pairs(displaySceneMap) do
          local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
          ActivityRedDot.AddRedDotNode(systemName, tActData.TabType, tabName, v.ID, false)
        end
      else
        local RedDotSystemName = ActivityRedDot.GetActFirstRedDotSystemName(v.ID)
        ActivityRedDot.AddRedDotNode(RedDotSystemName, tActData.TabType, tabName, v.ID, false)
      end
    end
  end
  return redNum
end
function LoginPunchInSystem.GetCurActHasDoneRate(nActID)
  local tCurActData = LoginPunchInSystem.GetRealDataByFatherActID(nActID)
  local nAllTaskNum = 0
  local nCurDoneNum = 0
  for _, v in ipairs(tCurActData) do
    local nCurSum, nAllSum = Logic_Activity_Center.GetCurActTaskData(v)
    nAllTaskNum = nAllTaskNum + nAllSum
    nCurDoneNum = nCurDoneNum + nCurSum
  end
  return nCurDoneNum / nAllTaskNum
end
function LoginPunchInSystem.GetCurActThemeData(actID)
  local tSerVerData = ActivityNewSystem.GetServerDataByID(actID)
  if not tSerVerData or not tSerVerData.cfg then
    return {}
  end
  local sTheme = tSerVerData.cfg.back_up_one or ""
  local StringUtil = require("common.string_util")
  local data = StringUtil.Split(sTheme, "|") or {}
  if #data == 5 then
    return data
  end
  return {}
end
function LoginPunchInSystem.HasJump(key)
  log_tree("LoginPunchInSystem.JumpData", LoginPunchInSystem.JumpData)
  log(bWriteLog and "  : LoginPunchInSystem.HasJump  key" .. tostring(key))
  if not LoginPunchInSystem.JumpData then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    LoginPunchInSystem.JumpData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSignJump)
    if not LoginPunchInSystem.JumpData then
      LoginPunchInSystem.JumpData = {}
      return false
    end
    return LoginPunchInSystem.JumpData[key]
  end
  return LoginPunchInSystem.JumpData[key]
end
function LoginPunchInSystem.HandlePunchIn(activityId)
  if not activityId or type(activityId) ~= "number" or activityId == 0 then
    return
  end
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local act = logic_activity_mgr.GetActivityByID(activityId)
  if not act or not act.List then
    return
  end
  local keys = {}
  for _, subData in pairs(act.List) do
    if subData.Type == ActivityType.LoginPunchIn and subData.Status == ActivityProgressStatus.Done then
      keys[#keys + 1] = subData.Key
    end
  end
  if next(keys) then
    LoginPunchInSystem.SaveJumpLocalMultiData(keys)
  end
  local changeList = {
    idList = {
      [activityId] = true
    },
    typeList = {
      [act.Type] = true
    }
  }
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
end
function LoginPunchInSystem.SaveJumpLocalMultiData(keys)
  if not LoginPunchInSystem.JumpData then
    LoginPunchInSystem.JumpData = {}
  end
  if keys and next(keys) then
    for _, key in ipairs(keys) do
      LoginPunchInSystem.JumpData[key] = 1
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(LoginPunchInSystem.JumpData, PlayerPrefsSystem.ePlayerPrefsType.eSignJump)
end
return LoginPunchInSystem