local SubActMaxCount = 20
local local E_local local ActivityNewSystem = {
  activityDataTable = {},
  data = {},
  dataMap = {},
  idMap = {},
  subListMap = {},
  hashList = {},
  bIsInit = false,
  bCanUpdateOtherModuleData = true,
  bActivityLoop = false,
  bQuestionDone = false,
  firstChargeInfo = nil,
  bFirstChargeInfoFromLogin = false,
  preciseToIdMap = {},
  nGetOnlineTimeDataTime = 0,
  tLeftOnlineTimeActMap = nil,
  delayRemoveActTimer = nil,
  delayUpdateActTimer = nil,
  fatherEnum = {
    [0] = false,
    [115018404] = true,
    [115018408] = true,
    [115018412] = true,
    [115018417] = true,
    [115018423] = true,
    [115018426] = true
  }
}
local GameletUtil = require("client.slua.logic.gamelet.GameletUtil")
local StringUtil = require("common.string_util")
local UIUtil = require("client.common.ui_util")
local TimeUtil = require("client.common.time_util")
local local ActivityStatus = ActivityProgressStatus
local local local local local local table_pool = require("common.table_pool").Create()
local SubAct201 = {}
local SubAct46 = {}
local Update_NoUpdateType = {
  [ActivityType.FRIEND_RECALL] = true,
  [ActivityType.FRIEND_RECALL_REFLUX] = true
}
local Update_OnlyOtherType = {
  [ActivityType.TOTAL_LOGIN] = true,
  [ActivityType.FIRST_RECHARGE_ADD] = true,
  [ActivityType.BUY_UPASS_ACTIVITY] = true,
  [ActivityType.ACTIVITY_TYPE_KRJP_PURCHASE] = true,
  [ActivityType.DOUBLE_RATING] = true,
  [ActivityType.ADVENTROUS_BIRDS] = true,
  [ActivityType.NEW_KILL_CNT] = true,
  [ActivityType.GROUP] = true,
  [ActivityType.NEW_SURVIVAL_TIME] = true,
  [ActivityType.DISTANCE] = true,
  [ActivityType.HEAL_AMOUNT] = true,
  [ActivityType.TOP_TENS] = true,
  [ActivityType.BlackFriday_Pass] = true,
  [ActivityType.BlackFriday_CyberScore] = true,
  [ActivityType.PERIODIC_CRATE] = true,
  [ActivityType.BEST_PARTNER_FOUR] = true,
  [ActivityType.LADDER_DRAW] = true,
  [ActivityType.MISSTION] = true,
  [ActivityType.DISCOUNTFEVER] = true,
  [ActivityType.EXTRA_TERRESTRIAL] = true,
  [ActivityType.SNOWWORLD_ADVENTURE] = true,
  [ActivityType.ACTIVITY_FRIEND_SHARE] = true,
  [ActivityType.ACTIVITY_THEME_TURNTABLE] = true,
  [ActivityType.LADDER_DRAW_NEW] = true,
  [ActivityType.BlackFriday_Upgrade] = true,
  [ActivityType.BlackFriday_Gun] = true,
  [ActivityType.WORLDCUP_SCORE_PROTECT] = true,
  [ActivityType.WORLDCUP_TEAMUP_ADD_RATING] = true,
  [ActivityType.WORLDCUP_DOUBLE_CHALLENGE] = true,
  [ActivityType.WORLDCUP_UPVOTE_DOUBLE_POPULARITY] = true,
  [ActivityType.WORLDCUP_TEAMUP_DOUBLE_INTIMACY] = true,
  [ActivityType.CHARM_VALUE_RANK] = true,
  [ActivityType.RPPassPreOrder] = true,
  [ActivityType.BLACK5_VOW] = true,
  [ActivityType.ACTIVITY_TYPE_CONSUME_UC] = true,
  [ActivityType.CONSUME_UC] = true,
  [ActivityType.OPTIONAL_TURNTABLE] = true,
  [ActivityType.LUCKYBACK] = true,
  [ActivityType.GOLDEN] = true,
  [ActivityType.Peak_GAME_NOT_SCORE] = true,
  [ActivityType.Peak_GAME_ADD_SCORE] = true,
  [ActivityType.MIX_ITEM] = true,
  [ActivityType.BlackFriday_Subscribe] = true,
  [ActivityType.BlackFriday_GroupBuy] = true,
  [ActivityType.BlackFriday_RPGroup] = true,
  [ActivityType.New_Group_Buying] = true
}
local Update_NoProgressType = {
  [ActivityType.STARTER_PACK_US] = true,
  [ActivityType.ACTIVITY_TYPE_EXCITINGTOUR] = true,
  [ActivityType.DESTOP_TOOL] = true
}
local Update_SpecialType = {
  [ActivityType.ONLINE_TIME] = "online_time",
  [ActivityType.KILL_CNT] = "kill_cnt",
  [ActivityType.SURVIVAL_TIME] = "survival_time",
  [ActivityType.LEVEL_UP_REWARD] = "level",
  [ActivityType.QUESTIONNAIRE] = "times",
  [ActivityType.H5_REWARD] = "click_count",
  [ActivityType.DAY_FIRST_WIN] = "daily_win_trigger_count",
  [ActivityType.TOTAL_LOGIN_SUPER] = "login_days",
  [ActivityType.ACTIVITY_CENTER_ACT] = "progress",
  [ActivityType.ChatRoom] = "progress",
  [ActivityType.DOUBLE_EXP] = "cycle_count",
  [ActivityType.WORLDCUP_SCORE_PROTECT] = "day_count",
  [ActivityType.WORLDCUP_SCORE_PROTECT] = "day_count",
  [ActivityType.WORLDCUP_TEAMUP_ADD_RATING] = "day_count",
  [ActivityType.WORLDCUP_DOUBLE_CHALLENGE] = "day_count",
  [ActivityType.WORLDCUP_UPVOTE_DOUBLE_POPULARITY] = "day_count",
  [ActivityType.WORLDCUP_TEAMUP_DOUBLE_INTIMACY] = "day_count",
  [ActivityType.TOP_TENS] = "progress",
  [ActivityType.ThemePlay_Activity] = "progress"
}
local Update_Group_NoProgressType = {
  [ActivityType.RANDOM_POOL_GROUP] = true
}
local blockPromptItemList = {
  [1702253] = true
}
local DefaultPredicate = function(ActType)
  local ActivityData = ActivityNewSystem.GetActivityListByType(ActType)
  if ActivityData and ActivityData[1] and ActivityData[1].ID then
    local SmallestID = ActivityData[1].ID
    for k, _ in pairs(ActivityData) do
      if type(ActivityData) == "table" and type(ActivityData[k]) == "table" and SmallestID > ActivityData[k].ID then
        SmallestID = ActivityData[k].ID
      end
    end
    for k, _ in pairs(ActivityData) do
      if type(ActivityData) == "table" and type(ActivityData[k]) == "table" and ActivityData[k].ID ~= SmallestID then
        ActivityNewSystem.RemoveActivity(ActivityData[k].ID)
        log(bWriteLog and "[HZA]ActivityNewSystem.ProcessDuplicatedActivity DefaultPredicate Delete Duplicated Activity ,Type: " .. tostring(ActType) .. " ID :" .. tostring(ActivityData[k].ID))
      end
    end
  end
end
local NonDuplicatedType = {
  [ActivityType.PROGRESS] = DefaultPredicate
}
local ImproveActivityData = function(activity)
  if not activity then
    return
  end
  if not activity.Order then
    activity.Order = 0
  end
  if not activity.StartTime then
    activity.StartTime = 0
  end
  local finish = true
  if activity.Type == ActivityType.ACTIVITY_TYPE_AREA_GROUP then
    local AreaGroupSystem = require("client.slua.logic.activity.commom_activity_center.logic_area_group")
    finish = AreaGroupSystem.IsActAllDone(activity.ID)
  else
    for _, subActivity in pairs(activity.List) do
      if subActivity.Status < ActivityStatus.Get then
        finish = false
        break
      end
    end
  end
  if finish then
    activity.Order = 2000
  end
end
function ActivityNewSystem.GetActivity()
  return ActivityNewSystem.data
end
function ActivityNewSystem.GetActivityMap()
  return ActivityNewSystem.dataMap
end
function ActivityNewSystem.GetSubListMap()
  return ActivityNewSystem.subListMap
end
function ActivityNewSystem.GetIDMap()
  return ActivityNewSystem.idMap
end
function ActivityNewSystem.GetServerData()
  return ActivityNewSystem.activityDataTable
end
local _svrActMapCacheByType = {}
function ActivityNewSystem.GetServerDataByType(actType)
  if not _svrActMapCacheByType then
    _svrActMapCacheByType = {}
  end
  if _svrActMapCacheByType[actType] then
    return _svrActMapCacheByType[actType]
  end
  local map = {}
  for k, v in pairs(ActivityNewSystem.activityDataTable) do
    if v.cfg and v.cfg.type and v.cfg.type == actType then
      map[k] = v
    end
  end
  _svrActMapCacheByType[actType] = map
  return _svrActMapCacheByType[actType]
end
function ActivityNewSystem.GetServerDataByID(actID)
  return ActivityNewSystem.activityDataTable[actID]
end
function ActivityNewSystem.GetActivityByID(actID)
  local map = ActivityNewSystem.dataMap
  return map[actID]
end
local _actCacheByType = {}
function ActivityNewSystem.GetActivityByType(actType)
  if not _actCacheByType then
    _actCacheByType = {}
  end
  if _actCacheByType[actType] and next(_actCacheByType[actType]) then
    return _actCacheByType[actType]
  end
  local list = ActivityNewSystem.GetActivityListByType(actType)
  table.sort(list, ActivityNewSystem.SortFunc)
  local result = list and list[1]
  if result then
    _actCacheByType[actType] = result
  end
  return result
end
function ActivityNewSystem.GetActivityListByTypeAndLabel(actType, TabType)
  local acts = ActivityNewSystem.GetActivityListByType(actType)
  local list = {}
  for _, activity in ipairs(acts) do
    if activity.TabType == TabType then
      list[#list + 1] = activity
    end
  end
  return list
end
function ActivityNewSystem.GetActivityByTypeAndLabel(actType, TabType)
  local acts = ActivityNewSystem.GetActivityListByType(actType)
  for _, activity in ipairs(acts) do
    if activity.TabType == TabType then
      return activity
    end
  end
end
function ActivityNewSystem.GetActivityByLabel(nTabType)
  local tResult = {}
  local tAllActData = ActivityNewSystem.data
  for _, tActData in ipairs(tAllActData) do
    if tActData.TabType == nTabType then
      table.insert(tResult, tActData)
    end
  end
  return tResult
end
function ActivityNewSystem.GetActivityListByTypeAndLabelAndBackupParam1(actType, BackupParam1)
  local acts = ActivityNewSystem.GetActivityListByType(actType)
  local list = {}
  for i, v in pairs(acts) do
    if tonumber(v.BackupParam1) == BackupParam1 then
      list[#list + 1] = v
    end
  end
  return list
end
local _actListCacheByType = {}
function ActivityNewSystem.GetActivityListByType(actType)
  if not actType then
    return {}
  end
  if not _actListCacheByType then
    _actListCacheByType = {}
  end
  if _actListCacheByType[actType] and next(_actListCacheByType[actType]) then
    return _actListCacheByType[actType]
  end
  local list = {}
  local data = ActivityNewSystem.data
  for _, activity in ipairs(data) do
    if activity.Type == actType then
      list[#list + 1] = activity
    end
  end
  _actListCacheByType[actType] = list
  return list
end
local _actCacheBySceneID = {}
function ActivityNewSystem.GetActivityBySceneID(sceneID)
  if not _actCacheBySceneID then
    _actCacheBySceneID = {}
  end
  if _actCacheBySceneID[sceneID] and next(_actCacheBySceneID[sceneID]) then
    return _actCacheBySceneID[sceneID]
  end
  local data = ActivityNewSystem.data
  for _, activity in ipairs(data) do
    if activity.ShowSceneID == sceneID then
      _actCacheBySceneID[sceneID] = activity
      return activity
    end
  end
  return nil
end
local _actListCacheBySceneID = {}
function ActivityNewSystem.GetSurpriseActivityID(actType, inputID)
  local data = ActivityNewSystem.data
  local res = {}
  for _, activity in ipairs(data) do
    if activity.Type == actType then
      res[activity.ID] = activity
    end
  end
  for k, v in pairs(res) do
    local condition = StringUtil.Split(v.Condition, ",")
    local parentID = tonumber(condition[1])
    if parentID == inputID then
      return k
    end
  end
  return -1
end
function ActivityNewSystem.CheckActivityIsOpenByType(actType, labelType)
  local data = ActivityNewSystem.data
  for _, activity in ipairs(data) do
    if activity.Type == actType and activity.TabType == labelType then
      local now = TimeUtil.GetServerTimeInSec()
      if now > activity.StartTime and now < activity.EndTime then
        log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.CheckActivityIsOpenByType" .. activity.ID)
        return activity.ID, activity.StartTime, activity.EndTime
      else
        return -1, activity.StartTime, activity.EndTime
      end
    end
  end
  return -1
end
function ActivityNewSystem.ClearData()
  ActivityNewSystem.activityDataTable = {}
  ActivityNewSystem.data = {}
  ActivityNewSystem.dataMap = {}
  ActivityNewSystem.idMap = {}
  ActivityNewSystem.subListMap = {}
  ActivityNewSystem.hashList = {}
  ActivityNewSystem.bIsInit = false
  _actCacheByType = {}
  _actListCacheByType = {}
  _actCacheBySceneID = {}
  _actListCacheBySceneID = {}
  _svrActMapCacheByType = {}
  SubAct201 = {}
  ActivityNewSystem.RemoveAllTimer()
end
function ActivityNewSystem.ResetData()
  ActivityNewSystem.ClearData()
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_get_activity_list_req()
end
function ActivityNewSystem.GetActivityLoop()
  return ActivityNewSystem.bActivityLoop
end
function ActivityNewSystem.GetFirstChargeInfo()
  return ActivityNewSystem.firstChargeInfo
end
function ActivityNewSystem.IsContainsH5LeagueGameActivity()
  local isJK = GlobalData.IsJapanOrKorea()
  if isJK then
    if ActivityNewSystem.dataMap[ActivityFixedID.H5LeagueGame_JK] then
      return true
    end
    return false
  else
    if ActivityNewSystem.dataMap[ActivityFixedID.H5LeagueGame] then
      return true
    end
    return false
  end
end
local signInTypeTb = {
  1,
  1,
  1
}
function ActivityNewSystem.IsSignInType(data)
  if data.ExParam and signInTypeTb[tonumber(data.ExParam)] then
    return true
  end
  return false
end
function ActivityNewSystem.IsBattleScoreProtected()
  local result = false
  local activity = ActivityNewSystem.GetActivityByType(ActivityType.HAPPY_TO_TEAM)
  if activity and activity.List then
    for _, v in ipairs(activity.List) do
      if v.Status == ActivityStatus.Not then
        result = true
      end
    end
  end
  return result
end
function ActivityNewSystem.GetAppointmentActivityID()
  local isJK = GlobalData.IsJapanOrKorea()
  if isJK then
    return ActivityFixedID.Appointment_JK
  end
  return ActivityFixedID.Appointment
end
function ActivityNewSystem.GetActivityIDToType(_type)
  local data = ActivityNewSystem.GetActivityByType(_type)
  if data then
    return data.ID
  end
  return 0
end
function ActivityNewSystem.ReqGetSeasonRechargeInfo(isFromLogin)
  ActivityNewSystem.bFirstChargeInfoFromLogin = isFromLogin
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_get_season_recharge_info_req()
end
function ActivityNewSystem.IsModuleOnline(moduleID, actType)
  local bOnline = false
  if moduleID and tonumber(moduleID) and 0 < tonumber(moduleID) then
    bOnline = ActivityNewSystem.IsActivityOpenByBanner(moduleID)
  end
  if not bOnline and actType and tonumber(actType) and 0 < tonumber(actType) then
    bOnline = ActivityNewSystem.IsActivityOpenByActivityType(actType)
  end
  return bOnline
end
function ActivityNewSystem.IsActivityOpenByBanner(moduleID)
  local activity = ActivityNewSystem.GetActivityInfoByModuleID(moduleID)
  if activity then
    local now = TimeUtil.GetServerTimeInSec()
    if now > activity.StartTimeUTC and now < activity.EndTimeUTC then
      return true
    end
  end
  return false
end
function ActivityNewSystem.IsActivityOpenByActivityType(actType)
  actType = tonumber(actType) or 0
  if actType == 0 then
    return false
  end
  local now = TimeUtil.GetServerTimeInSec()
  local actList = ActivityNewSystem.GetActivityListByType(actType)
  for _, v in ipairs(actList) do
    if now > v.StartTime and now < v.EndTime then
      return true
    end
  end
  local activity = ActivityNewSystem.dataMap[actType]
  if activity and now > activity.StartTime and now < activity.EndTime then
    return true
  end
  return false
end
function ActivityNewSystem.GetActivityInfoByModuleID(moduleID)
  if LobbySystem.activityDisplayDataList and next(LobbySystem.activityDisplayDataList) then
    for _, v in pairs(LobbySystem.activityDisplayDataList) do
      if v.JumpUrl and type(v.JumpUrl) == "string" and v.JumpUrl ~= "" then
        local idx = string.find(v.JumpUrl, "module=")
        if idx and 0 < tonumber(idx) then
          local beginIdx = idx + string.len("module=")
          local jumpModule = string.sub(v.JumpUrl, beginIdx, beginIdx - 1 + string.len(tostring(moduleID)))
          if tonumber(jumpModule) == tonumber(moduleID) then
            return v
          end
        end
      end
    end
  end
  return nil
end
local testTb = {
  [87] = 1
}
function ActivityNewSystem.InitActivityList(activityTable, isReGetData, isReGetDisplay)
  if isReGetData then
    ActivityNewSystem:ClearData()
  end
  ActivityNewSystem.bIsInit = true
  ActivityNewSystem.bCanUpdateOtherModuleData = true
  ActivityNewSystem.activityDataTable = activityTable
  ActivityNewSystem.InitData(activityTable, isReGetDisplay)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO)
  if ActivityNewSystem.bIsInit then
    local AssemblyActivitySystem_JK = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_assembly_activity_jk)
    AssemblyActivitySystem_JK:SendAssemblyReply()
  end
  local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
  UnknowPassBuyActSystem.CheckHaveInvite()
end
function ActivityNewSystem.GetActData()
  if not ActivityNewSystem.activityDataTable then
    log_error(bWriteLog and "[jinqiang] self.activityDataTable is nil ")
  end
  return ActivityNewSystem.activityDataTable
end
function ActivityNewSystem.AddActivityList(activityTable)
  for actId, data in pairs(activityTable) do
    log(bWriteLog and "[qintong]: ActivityNewSystem.AddActivityList" .. tostring(actId))
    ActivityNewSystem.activityDataTable[actId] = data
  end
  ActivityNewSystem.InitData(ActivityNewSystem.activityDataTable)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO)
end
function ActivityNewSystem.InsertActivityList(activityTable)
  if not activityTable then
    log(pWriteLog and "[InsertActivityList]: activityTable is nil")
    return
  end
  for actId, data in pairs(activityTable) do
    log(bWriteLog and "[InsertActivityList]: ActivityNewSystem.InsertActivityList" .. tostring(actId))
    if ActivityNewSystem.activityDataTable then
      ActivityNewSystem.activityDataTable[actId] = data
    end
  end
  ActivityNewSystem.InitData(ActivityNewSystem.activityDataTable)
end
function ActivityNewSystem.UpdateActivityData(actID, activityData, dontUpdateRed)
  log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.UpdateActivityData, actID = " .. actID)
  log_tree("ActivityNewSystem.UpdateActivityData activityData = ", activityData)
  local time_ticker = require("common.time_ticker")
  if not activityData or not activityData[actID] then
    log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.UpdateActivityData, remove activity")
    ActivityNewSystem.RemoveActivity(actID)
    if ActivityNewSystem.bIsInit and GameStatus.IsInLobbyOrMainCity() then
      local bUpdate = false
      for _, v in ipairs(LobbySystem.activityDisplayDataList) do
        if v.EndTimeUTC < TimeUtil.GetServerTimeInSec() then
          bUpdate = true
          break
        end
      end
      if ActivityNewSystem.delayRemoveActTimer then
        time_ticker.RemoveTimer(ActivityNewSystem.delayRemoveActTimer)
        ActivityNewSystem.delayRemoveActTimer = nil
      end
      if bUpdate then
        ActivityNewSystem.delayRemoveActTimer = time_ticker.AddTimerOnce(0.1, function()
          EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR)
        end)
      end
    end
    return
  end
  local needUpdateRedDot = true
  local changeList = {
    idList = {},
    typeList = {}
  }
  for id, data in pairs(activityData) do
    if ActivityNewSystem.activityDataTable[id] then
      _actCacheByType[data.type] = nil
      if data.type == ActivityType.ONLINE_TIME and data.award then
        needUpdateRedDot = false
        for i, v in ipairs(data.award) do
          local TableUtil = require("common.table_util")
          local lastStatus = TableUtil.GetTableValue(ActivityNewSystem.activityDataTable[id].data, "award", i, "status")
          local curStatus = v.status
          if lastStatus and curStatus and lastStatus ~= curStatus then
            needUpdateRedDot = true
          end
        end
        if not dontUpdateRed then
          ActivityNewSystem.AddOnlineTimeTimer(TimeUtil.GetServerTimeInSec())
        end
      elseif data.type == ActivityType.LUCKYBACK then
        log(bWriteLog and string.format("ActivityNewSystem.UpdateActivityData activityID = %s", id))
        log_tree("data", data)
      end
      ActivityNewSystem.activityDataTable[id].      if ActivityNewSystem.dataMap[id] then
        ImproveActivityData(ActivityNewSystem.dataMap[id])
      end
    else
      ActivityNewSystem.activityDataTable[id] = {}
      ActivityNewSystem.activityDataTable[id].      local parentId = 0
      if data.cfg and data.cfg.father_activity_id and ActivityNewSystem.fatherEnum[data.cfg.father_activity_id or 0] then
        ActivityNewSystem.activityDataTable[id].cfg = data.cfg
        ActivityNewSystem.activityDataTable[id].        local cfg = ActivityNewSystem.activityDataTable[id].cfg
        parentId = cfg.father_activity_id
        local parentNode = ActivityNewSystem.dataMap[parentId]
        ActivityNewSystem.InitSubNode(parentNode, id, ActivityNewSystem.activityDataTable[id])
        ActivityNewSystem.hashList[id] = {
          HashCode = cfg.chk_str,
          UpdateTime = 0
        }
        ImproveActivityData(parentNode)
      end
      if 0 < parentId then
        local act = ActivityNewSystem.dataMap[parentId]
        if act then
          if _actListCacheByType[act.Type] then
            _actListCacheByType[act.Type] = nil
          end
          if 0 < act.ShowSceneID and _actListCacheBySceneID[act.ShowSceneID] then
            _actListCacheBySceneID[act.ShowSceneID] = nil
          end
          if _svrActMapCacheByType[act.Type] then
            _svrActMapCacheByType[act.Type][id] = nil
          end
        end
      end
    end
    ActivityNewSystem.UpdateOneActivityData(id, data)
    changeList.idList[ActivityNewSystem.idMap[id] or -1] = true
    changeList.typeList[data.type] = true
  end
  local logic_best_partner = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_best_partner)
  logic_best_partner:UpdateTeamInfoByActData(actID, changeList.typeList)
  if ActivityNewSystem.bIsInit and (GameStatus.IsInLobbyOrMainCity() or GameStatus.IsPHomeMode()) then
    ActivityNewSystem.SortActivity()
    log_warning(bWriteLog and "  ActivityNewSystem.UpdateActivityData. EVNETID_DATAMGR_ACTIVITY_CHANGE: " .. tostring(changeList and changeList.idList and changeList.idList[1]))
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
    if needUpdateRedDot and not dontUpdateRed then
      ActivityNewSystem.PostActivityRedDot()
    end
  end
end
local _AddOnlineTime = function(onlineTimeActMap)
  local isAllDone = true
  local diff = math.floor((TimeUtil.GetServerTimeInSec() - ActivityNewSystem.nGetOnlineTimeDataTime) / 60) or 0
  for id, _ in pairs(onlineTimeActMap) do
    local act = onlineTimeActMap[id]
    if act then
      local data = act.data
      if data and data.award and data.award[#data.award] and data.award[#data.award].status then
        if data.award[#data.award].status == ActivityStatus.Not then
          isAllDone = false
          if data.other then
            data.other.online_time = (data.other.online_time or 0) + diff
            local newActData = table_pool:Get()
            newActData[id] = data
            ActivityNewSystem.UpdateActivityData(id, newActData, true)
            table_pool:Recycle(newActData)
            if 0 < diff then
              ActivityNewSystem.nGetOnlineTimeDataTime = TimeUtil.GetServerTimeInSec()
            end
          end
        end
      else
        isAllDone = false
      end
    end
  end
  return isAllDone
end
function ActivityNewSystem.AddOnlineTimeTimer(addTime)
  if addTime - ActivityNewSystem.nGetOnlineTimeDataTime < 1 then
    log(bWriteLog and "[edward] ActivityNewSystem.AddOnlineTimeTimer, dont add repeat")
    return
  end
  ActivityNewSystem.nGetOnlineTimeDataTime = addTime
  ActivityNewSystem.RemoveOnlineTimeTimer()
  if not ActivityNewSystem.onlineTimeTimer and not ActivityNewSystem.onlineTimeActMap then
    ActivityNewSystem.onlineTimeActMap = ActivityNewSystem.GetServerDataByType(ActivityType.ONLINE_TIME)
    if not next(ActivityNewSystem.onlineTimeActMap) then
      log(bWriteLog and "[edward] ActivityNewSystem.AddOnlineTimeTimer, no online_time activity")
      return
    end
    log(bWriteLog and "[edward] ActivityNewSystem.AddOnlineTimeTimer")
    local time_ticker = require("common.time_ticker")
    ActivityNewSystem.onlineTimeTimer = time_ticker.AddTimerLoop(30, function()
      local bIsFighting = GameStatus.IsInFightingNotSocialNotMainCityNotHome()
      if bIsFighting then
        ActivityNewSystem.tLeftOnlineTimeActMap = ActivityNewSystem.GetServerDataByType(ActivityType.ONLINE_TIME)
        time_ticker.RemoveTimer(ActivityNewSystem.onlineTimeTimer)
        ActivityNewSystem.onlineTimeTimer = nil
        return
      end
      local isAllDone = _AddOnlineTime(ActivityNewSystem.onlineTimeActMap)
      if isAllDone then
        time_ticker.RemoveTimer(ActivityNewSystem.onlineTimeTimer)
        ActivityNewSystem.onlineTimeTimer = nil
        return
      end
    end, TIMER_INFINITE, 30)
  end
end
function ActivityNewSystem.OnModePostSwitch(_, _, gamestatus)
  if gamestatus.current == GameStatus.Lobby and ActivityNewSystem.tLeftOnlineTimeActMap and next(ActivityNewSystem.tLeftOnlineTimeActMap) then
    _AddOnlineTime(ActivityNewSystem.tLeftOnlineTimeActMap)
    ActivityNewSystem.tLeftOnlineTimeActMap = nil
  end
  if gamestatus.current == GameStatus.Lobby and gamestatus.pre == GameStatus.Fighting then
    local LuckAirDropHandler = require("client.network.Protocol.LuckAirDropHandler")
    LuckAirDropHandler.send_target_airdrop_trigger_req(4)
  end
end
function ActivityNewSystem.RemoveOnlineTimeTimer()
  if ActivityNewSystem.onlineTimeTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ActivityNewSystem.onlineTimeTimer)
  end
  ActivityNewSystem.onlineTimeTimer = nil
  ActivityNewSystem.onlineTimeActMap = nil
end
function ActivityNewSystem.RemoveAllTimer()
  local time_ticker = require("common.time_ticker")
  ActivityNewSystem.RemoveOnlineTimeTimer()
  if ActivityNewSystem.delayRemoveActTimer then
    time_ticker.RemoveTimer(ActivityNewSystem.delayRemoveActTimer)
    ActivityNewSystem.delayRemoveActTimer = nil
  end
  if ActivityNewSystem.delayUpdateActTimer then
    time_ticker.RemoveTimer(ActivityNewSystem.delayUpdateActTimer)
    ActivityNewSystem.delayUpdateActTimer = nil
  end
end
function ActivityNewSystem.IsBlockPromptItem(id)
  return blockPromptItemList[id]
end
function ActivityNewSystem.IsCakeBakeAct(subActData)
  local task_father_id = next(subActData.other) and subActData.other.father_activity_id or 0
  if task_father_id ~= 0 then
    return true
  end
  return false
end
function ActivityNewSystem.OnTakeActivityAwardRsp(errorCode, activityId, awardIndex, factor, chest_open_items, item_list)
  log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.OnTakeActivityAwardRsp, " .. tostring(errorCode) .. ", " .. tostring(activityId) .. ", " .. tostring(awardIndex) .. ", " .. tostring(factor))
  local TableUtil = require("common.table_util")
  if errorCode == NetErrorCode_NONE then
    if not activityId then
      return
    end
    if ActivityNewSystem.bCanUpdateOtherModuleData then
      local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
      local LuckyDoubleSystem = require("client.slua.logic.lobby_activity.logic_luckydouble_activity")
      local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
      local BlackFridayUpgradeModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayUpgradeModule)
      local BlackFridayPassModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayPassModule)
      if activityId == LuckyUnbackSystem.ActivityId then
        LuckyUnbackSystem.on_take_activity_award_res(item_list, activityId)
        return
      elseif activityId == LuckyDoubleSystem.ActivityId then
        LuckyDoubleSystem.on_take_activity_award_res(item_list)
        return
      elseif activityId == LuckybackActivitySystem.activityId then
        LuckybackActivitySystem.on_take_activity_award_res(item_list, activityId)
        return
      elseif activityId == ActivityNewSystem.GetAppointmentActivityID() and awardIndex == 1 then
        return
      elseif activityId == ActivityFixedID.MysteryClueSub1 or activityId == ActivityFixedID.MysteryClueSub2 or activityId == ActivityFixedID.MysteryClueSub3 or activityId == ActivityFixedID.MysteryClueSub4 or activityId == ActivityFixedID.MysteryClueSub5 or activityId == ActivityFixedID.MysteryClueSub6 or activityId == ActivityFixedID.MysteryClueSub7 or activityId == ActivityFixedID.MysteryClueSub8 or activityId == ActivityFixedID.MysteryClueSub9 or activityId == ActivityFixedID.MysteryClueSub10 then
        return
      else
        local key = string.format("%d_%d", activityId, awardIndex)
        local subActivity = ActivityNewSystem.subListMap[key]
        if not subActivity then
          return
        end
        if subActivity.Type == ActivityType.SUPPLY_ACTIVITY_EXTRA_BOX then
          return
        end
        local get_times = factor or 1
        if get_times < 1 then
          get_times = 1
        end
        local arrayItemData = {}
        for _, dropData in ipairs(subActivity.Drop) do
          if not ActivityNewSystem.IsBlockPromptItem(dropData.itemId) then
            local ele = {
              res_id = dropData.itemId,
              count = dropData.count * get_times,
              valid_hours = dropData.validTimes or 0,
              expire_ts = dropData.expireTime or 0
            }
            ele.extra = {}
            local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
            ActivityUtil.CombineExpireTs(ele.expire_ts, ele.extra)
            table.insert(arrayItemData, ele)
          end
        end
        if subActivity.Type == ActivityType.DISCOUNT_TICKET then
          EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_GET_DISCOUNT_TICKET, arrayItemData)
        elseif subActivity.Type == ActivityType.BlackFriday_CyberScore then
          EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_GET_AWARDS, arrayItemData)
        elseif BlackFridayUpgradeModule:IsUpgradeActId(activityId) then
        elseif BlackFridayPassModule:IsPassActId(activityId) then
          BlackFridayPassModule:OnTakeActAward(arrayItemData)
        elseif TableUtil.GetTableValue(ActivityNewSystem.dataMap, activityId, "ShowSceneID") == ActivitySceneID.Avalon then
        elseif subActivity.Type == ActivityType.ACTIVITY_TYPE_RP_GROUPBUY then
          local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
          UnknowPassBuyActSystem.GetNeedShowReddot()
          EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUYUPASS_REDDOT)
          if next(arrayItemData) then
            local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
            Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
          end
        elseif ActivityNewSystem.IsCakeBakeAct(subActivity) then
        elseif subActivity.Type == ActivityType.PreventLose_LoginReward then
          ActivityNewSystem.OnTakePrechurnAward(arrayItemData)
        elseif subActivity.Type == ActivityType.BUY_UPASS_ACTIVITY then
          local upArrayItemData = {}
          if chest_open_items then
            for k, v in pairs(chest_open_items) do
              table.insert(upArrayItemData, {
                res_id = tonumber(k),
                count = v.itemNum,
                valid_hours = v.valid_hours
              })
            end
            local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
            Logic_CommonItemGet.ShowPanel_DefaultStyle(upArrayItemData)
          end
          local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
          UnknowPassBuyActSystem.GetNeedShowReddot()
          EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUYUPASS_REDDOT)
        elseif next(arrayItemData) then
          local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
          Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
        end
        local bulletinManager = require("client.slua.umg.activity.bulletin_board.bulletin_manager")
        if activityId == bulletinManager.rewardActID then
          EventSystem:postEvent(EVENTTYPE_BULLETIN, EVENTID_BULLETIN_REWARD_RESULT)
        end
        if activityId == ActivityNewSystem.GetActivityIDToType(ActivityType.ADVENTROUS_BIRDS) then
          EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_GET_BIRD_TICKET)
        end
        EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVEMTID_DATAMGR_ACTIVITY_REWARDS_COMMON, activityId, arrayItemData)
      end
    end
  else
    ShowNotice(errorCode)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_DATAMGR_ACTIVITY_REWARDS_GET_FAIL, errorCode)
  end
end
function ActivityNewSystem.OnBatchTakeActivityAwardRsp(err_code, activity_id, index_awards)
  if err_code == 0 then
    local item_data = {}
    for _, v in pairs(index_awards) do
      for _, vv in pairs(v) do
        item_data[#item_data + 1] = vv
      end
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(item_data)
  else
    ShowNotice(err_code)
  end
end
function ActivityNewSystem.OnTakePrechurnAward(arrayItemData)
  if 0 < #arrayItemData then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local curTime = TimeUtil.GetServerTimeInSec()
    for i = #arrayItemData, 1, -1 do
      local rewardInfo = arrayItemData[i]
      local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(rewardInfo.res_id)
      log(bWriteLog and "[v_wllwu] ActivityNewSystem.OnTakeActivityAwardRsp, itemData.expireTS:  " .. tostring(itemData and itemData.expireTS))
      if itemData and itemData.expireTS and itemData.expireTS ~= 0 then
        if curTime < itemData.expireTS then
          local remainTime = itemData.expireTS - curTime
          arrayItemData[i].valid_hours = math.modf(remainTime / 3600)
          log(bWriteLog and "[v_wllwu] ActivityNewSystem.OnTakeActivityAwardRsp, valid_hours\239\188\154 " .. tostring(arrayItemData[i].valid_hours))
        else
          log(bWriteLog and "[v_wllwu] ActivityNewSystem.OnTakeActivityAwardRsp, prechurn award has expired, curTime is " .. tostring(curTime))
          table.remove(arrayItemData, i)
        end
      end
    end
    if 0 < #arrayItemData then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
    end
  end
end
function ActivityNewSystem.OnTakeSpecialActivityAwardRsp(errorCode, activityId, awardId, factor)
  log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.OnTakeSpecialActivityAwardRsp, " .. tostring(errorCode) .. "," .. tostring(activityId) .. "," .. tostring(awardId) .. "," .. tostring(factor))
  if errorCode == NetErrorCode_NONE then
    if ActivityNewSystem.bCanUpdateOtherModuleData then
      local key = string.format("%d_%d", activityId, 1)
      local subActivity = ActivityNewSystem.subListMap[key]
      local get_times = factor or 1
      if get_times < 1 then
        get_times = 1
      end
      if subActivity then
        local arrayItemData = {}
        for _, dropData in ipairs(subActivity.Drop) do
          if dropData.itemId == awardId then
            table.insert(arrayItemData, {
              res_id = dropData.itemId,
              count = dropData.count * get_times,
              valid_hours = dropData.expireTime
            })
            break
          end
        end
        if #arrayItemData == 1 then
          local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
          Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
        end
      end
    end
  else
    ShowNotice(errorCode)
  end
end
function ActivityNewSystem.OnGetSeasonRechargeInfoRsp(res, data)
  log(bWriteLog and "ActivityNewSystem.OnGetSeasonRechargeInfoRsp res:" .. tostring(res))
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if not ActivityNewSystem.bCanUpdateOtherModuleData then
    return
  end
  local TheFirstChargeSystem = require("client.slua.logic.recharge.logic_the_first_charge")
  if res == NetErrorCode_NONE then
    if data then
      ActivityNewSystem.firstChargeInfo = data
      TheFirstChargeSystem.SetData()
      if not ActivityNewSystem.bFirstChargeInfoFromLogin then
        TheFirstChargeSystem.ShowSmallUI()
        if not LogicNewbie.IsNewbie() or LogicNewbie.NeedShowNewbieGuide(10603) then
          TheFirstChargeSystem.red_dot = false
          LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON, false)
        end
      else
        TheFirstChargeSystem.CheckIsFinished()
        TheFirstChargeSystem.CheckFirstChargeRedDot()
      end
      EventSystem:postEvent(EVENTTYPE_SEASON_RECHARGE, EVENTID_SEASON_RECHARGE_INFO)
    end
  else
    log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.OnGetSeasonRechargeInfoRsp error code = " .. res)
    if res == "not-open" then
      TheFirstChargeSystem.SetOpenCountDown(data)
    elseif res == "all-done" then
      TheFirstChargeSystem.SetAllDone()
    end
    local RechargeSystem = require("client.logic.recharge.logic_recharge")
    RechargeSystem.isHideFirstCharge = true
    local RechargeJKSystem = require("client.logic.recharge.logic_recharge_jk")
    RechargeJKSystem.SetIsHideFirstCharge(true)
    LobbySystem.RefreshBannerDisplayList()
    EventSystem:postEvent(EVENTTYPE_SEASON_RECHARGE, EVENTID_SEASON_RECHARGE_INFO)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_BANNER_CHANGE)
  end
end
function ActivityNewSystem.OnTakeSeasonRechargeAwardRsp(res, data)
  if res == NetErrorCode_NONE then
    if ActivityNewSystem.bCanUpdateOtherModuleData and next(data) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(data)
    end
    ActivityNewSystem.ReqGetSeasonRechargeInfo(false)
  else
    log_error("[edward][logic_activity_mgr] ActivityNewSystem.OnTakeSeasonRechargeAwardRsp error code = " .. res)
  end
end
function ActivityNewSystem.UpdateActivityMainUIRedDot()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local midBannerUI = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Activity_UIBP)
    if midBannerUI ~= nil and midBannerUI.UpdateShowRedpoint then
      midBannerUI:UpdateShowRedpoint()
    end
  end
end
function ActivityNewSystem.OnSeasonRechargeBuyRsp(res, data)
  if res == NetErrorCode_NONE then
    if ActivityNewSystem.bCanUpdateOtherModuleData and next(data) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(data)
    end
    ActivityNewSystem.ReqGetSeasonRechargeInfo(false)
  else
    log_error("[edward][logic_activity_mgr] ActivityNewSystem.OnSeasonRechargeBuyRsp error code = " .. res)
  end
end
function ActivityNewSystem.OnGetAbTestingGroupidsRsp(tag)
  ActivityNewSystem.UpdateABTagData(tag)
end
function ActivityNewSystem.InitData(activityTable, isReGetDisplay)
  _actCacheByType = {}
  _actCacheBySceneID = {}
  _actListCacheBySceneID = {}
  _svrActMapCacheByType = {}
  if not ActivityNewSystem.bIsInit then
    log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.InitData, received get_activity_batch_res.")
  end
  ActivityNewSystem.Preprocess(activityTable)
  local changeList = {
    idList = {},
    typeList = {}
  }
  local haveNewActivity = false
  local data = ActivityNewSystem.data
  for activityId, activityData in pairs(activityTable) do
    local cfg = activityData.cfg
    cfg = cfg or {father_activity_id = nil, show_order = nil}
    cfg.father_activity_id = cfg.father_activity_id or 0
    cfg.show_order = cfg.show_order or 0
    local parentId = cfg.father_activity_id == 0 and activityId or cfg.father_activity_id
    local parentNode = ActivityNewSystem.dataMap[parentId]
    if not parentNode then
      parentNode = {
        ID = parentId,
        Desc = nil,
        Detail = nil,
        Title = nil,
        ImgUrl = nil,
        ImgLink = nil,
        DailyStartTime = nil,
        DailyEndTime = nil,
        StartTime = nil,
        EndTime = nil,
        PreShowTime = nil,
        DelayShowTime = nil,
        cond_2 = nil,
        BPPath = nil,
        LabelType = nil,
        RedPointSwitcher = nil,
        Order = nil,
        JumpActivity = nil,
        Type = nil,
        ExParam = nil,
        weekly_open_days = nil,
        TabType = nil,
        FirstLabel = nil,
        BrotherID = nil,
        Condition = nil,
        ExtraCondition = nil,
        ShowSceneID = nil,
        EntryImageUrl = nil,
        ReturnJumpUrl = nil,
        BackupParam1 = nil,
        BackupParam2 = nil,
        back_int_value = nil,
        other = nil,
        canAwardVersion = nil,
        List = {},
        LabelDesc = nil,
        DisplayScene = nil
      }
      data[#data + 1] = parentNode
      ActivityNewSystem.dataMap[parentId] = parentNode
      haveNewActivity = true
    end
    if cfg.father_activity_id == 0 then
      ActivityNewSystem.InitParentNode(parentNode, activityId, activityData)
    end
    ActivityNewSystem.InitSubNode(parentNode, activityId, activityData)
    ActivityNewSystem.hashList[activityId] = {
      HashCode = cfg.chk_str,
      UpdateTime = 0
    }
    changeList.idList[ActivityNewSystem.idMap[activityId] or -1] = true
    if cfg.type then
      changeList.typeList[cfg.type] = true
    end
    ActivityNewSystem.UpdateOneActivityData(activityId, activityData.data)
    if cfg.isprecise then
      ActivityNewSystem.preciseToIdMap[cfg.isprecise] = activityId
    end
  end
  for _, activity in pairs(ActivityNewSystem.data) do
    ImproveActivityData(activity)
  end
  ActivityNewSystem.SortActivity()
  if ActivityNewSystem.bIsInit then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
    if haveNewActivity or isReGetDisplay then
      EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR)
    end
    ActivityNewSystem.PostActivityRedDot()
  end
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.CheckCanShowBannerRedPoint()
  local match_redpoint_data = require("client.slua.logic.match.red_point.match_redpoint_data")
  match_redpoint_data.UpdateWarmUp()
  ActivityNewSystem.ProcessDuplicatedActivity()
  ActivityNewSystem.AddOnlineTimeTimer(TimeUtil.GetServerTimeInSec())
end
function ActivityNewSystem.Preprocess(activityTable)
  local needRemoveIDList = {}
  for activityId, activityData in pairs(activityTable) do
    local activityCfg = activityData.cfg
    if activityCfg and activityCfg.type and activityCfg.type == ActivityType.IMAGES_GROUP_SUB then
      if activityCfg.father_activity_id == 0 and activityCfg.award and 0 < #activityCfg.award then
        local condition = StringUtil.SplitToNum(activityCfg.award[1].cond, ",")
        activityCfg.father_activity_id = condition[1]
        log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.Preprocess, banner parent activity id = " .. activityCfg.father_activity_id)
      end
      SubAct46[activityCfg.id] = activityCfg.father_activity_id
    elseif activityCfg and activityCfg.type and activityCfg.type == ActivityType.BULLETINBOARD and activityCfg.award and 0 < #activityCfg.award then
      local condition = StringUtil.SplitToNum(activityCfg.award[1].cond, ",")
      for _, v in ipairs(condition) do
        if 1000 < v then
          local info = {id = v, fatherID = activityId}
          needRemoveIDList[#needRemoveIDList + 1] = info
        end
      end
    end
  end
  for _, v in ipairs(needRemoveIDList) do
    if activityTable[v.id] then
      activityTable[v.id].cfg.father_activity_id = v.fatherID
      local award = activityTable[v.id].cfg.award
      if award then
        for _, vv in ipairs(award) do
          vv.task_title = activityTable[v.id].cfg.activity_name or ""
        end
      end
    end
  end
end
local GetPageAndTabImgUrl = function(actData)
  if not (actData and actData.cfg) or not actData.cfg.activity_image_link then
    return "", ""
  end
  if not StringUtil.StrFind(actData.cfg.activity_image_link, ";") then
    return actData.cfg.activity_image_link, ""
  end
  local split = StringUtil.Split(actData.cfg.activity_image_link, ";")
  return split[1], split[2]
end
local GetTabType = function(actData)
  if not (actData and actData.cfg) or not actData.cfg.label_type then
    return 0
  end
  local cfg = actData.cfg
  if cfg.type == ActivityType.NOTICE_INFO then
    if cfg.back_int_value == ActivityBackUpIntType.Gamelet or cfg.back_int_value == ActivityBackUpIntType.TxMission then
      return ActivitySwitchType.None
    else
      return ActivitySwitchType.Notice
    end
  else
    return cfg.label_type or 0
  end
end
function ActivityNewSystem.InitParentNode(node, id, activityData)
  local cfg = activityData.cfg or {}
  node.ID = id
  node.Desc = cfg.activity_desc or ""
  node.Detail = cfg.activity_detail or ""
  node.Title = cfg.activity_name or ""
  local page, tab = GetPageAndTabImgUrl(activityData)
  node.ImgUrl = page
  node.TabImgUrl = tab
  node.ImgLink = cfg.page_link or ""
  node.DailyStartTime = cfg.daily_start_time or 0
  node.DailyEndTime = cfg.daily_end_time or 0
  node.StartTime, node.EndTime = ActivityNewSystem.GetStartWithEndTime(activityData)
  node.PreShowTime = cfg.priority_begin_time or 0
  node.DelayShowTime = cfg.priority_end_time or 0
  node.cond_2 = cfg.cond_2
  node.BPPath = cfg.blueprint_path or ""
  node.LabelType = 0
  node.RedPointSwitcher = cfg.left_label or 0
  node.Order = cfg.show_order
  node.JumpActivity = cfg.jump_activity_id or 0
  node.Type = cfg.type
  node.List = node.List or {}
  node.ExParam = cfg.remark_content
  node.weekly_open_days = cfg.weekly_open_days_hash or {}
  node.TabType = GetTabType(activityData)
  if cfg.first_label and cfg.first_label ~= "" then
    node.FirstLabel = cfg.first_label
  end
  if cfg.brother_activity_id then
    node.BrotherID = cfg.brother_activity_id
  end
  if cfg.award and 0 < #cfg.award then
    node.Condition = cfg.award[1].cond
    node.ExtraCondition = cfg.award[1].extra_cond
  end
  if not cfg.show_scene_id or cfg.show_scene_id == "" then
    node.ShowSceneID = 1
  else
    node.ShowSceneID = tonumber(cfg.show_scene_id)
  end
  node.EntryImageUrl = cfg.scene_image_link or ""
  node.ReturnJumpUrl = cfg.return_jump_link or ""
  node.BackupParam1 = cfg.back_up_one or ""
  node.BackupParam2 = cfg.back_up_two or ""
  node.back_int_value = cfg.back_int_value or 0
  if cfg.display_entrance and next(cfg.display_entrance) then
    node.DisplayScene = cfg.display_entrance
  else
    node.DisplayScene = {
      [ActivityDisplayScene.Default] = ActivityDisplayScene.Default
    }
  end
  ActivityNewSystem.idMap[id] = id
  ActivityNewSystem.dataMap[id] = node
  if cfg.type == ActivityType.QUESTION then
    node.Order = -100
    log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.InitParentNode, question data order = " .. node.Order)
  end
  node.other = activityData.data.other or {}
  node.canAwardVersion = ""
  if cfg.can_award_version and cfg.can_award_version ~= "" then
    node.canAwardVersion = cfg.can_award_version
  end
  local typeList = _actListCacheByType[node.Type]
  local created
  if not typeList then
    created = true
    typeList = {}
  end
  if node.Type == ActivityType.ACTIVITY_TYPE_LINK and node.ImgLink ~= "" then
    local JumpUtils = require("client.logic.store.jump_utils")
    local isPandora = JumpUtils.IsPanDoraJumpUrl(node.ImgLink)
    local isGame = JumpUtils.IsGameJumpUrl(node.ImgLink)
    local IsShowInActivityCenter = node.TabType >= ActivitySwitchType.Activity and node.TabType <= ActivitySwitchType.IPLink
    if (isPandora or isGame) and IsShowInActivityCenter then
      local params = StringUtil.ParseURLParams(node.ImgLink)
      if isPandora then
        local pandora_system = require("client.slua.logic.Pandora.pandora_system")
        local pandoraId = tonumber(params.actid)
        if pandoraId and not pandora_system.pandora2Id[pandoraId] then
          pandora_system.pandora2Id[pandoraId] = node.ID
          log(bWriteLog and string.format("ActivityNewSystem.InitParentNode pandoraId:%s, activityId:%s", tostring(pandoraId), tostring(node.ID)))
        end
      elseif isGame then
        local moduleId = tonumber(params.module)
        if moduleId and moduleId == BP_ENUM_MODULE_HOSTED_GAMELET_ACT then
          local appId = tonumber(params.appId or 0)
          local LogicGameletRedPoint = require("client.slua.logic.gamelet.LogicGameletRedPoint")
          LogicGameletRedPoint:SaveGameletActId(node.ID, appId)
          log(bWriteLog and string.format("ActivityNewSystem.InitParentNode gameletAct id:%s", tostring(node.ID)))
        end
      end
    end
  end
  local haveSameDataInListIndex = 0
  if typeList and next(typeList) then
    for k, v in pairs(typeList) do
      if v.ID == node.ID then
        haveSameDataInListIndex = v
        break
      end
    end
  end
  if haveSameDataInListIndex == 0 then
    typeList[#typeList + 1] = node
  else
    typeList[haveSameDataInListIndex] = node
  end
  if created and node.Type then
    _actListCacheByType[node.Type] = typeList
  end
end
function ActivityNewSystem.GetStartWithEndTime(activityData)
  local cfg = activityData.cfg or {}
  if cfg.type == ActivityType.PreventLose_LoginReward and activityData.data and activityData.data.open_time then
    local logic_prechurn_loginreward = require("client.slua.logic.activity.logic_prechurn_loginreward")
    logic_prechurn_loginreward.UpdateOpenActTime(activityData.data.open_time)
    local startTime = logic_prechurn_loginreward.GetActivityStartTime(activityData.data.open_time)
    local endTime = logic_prechurn_loginreward.GetActivityEndTime(startTime)
    log(bWriteLog and "[v_wllwu] ActivityNewSystem.GetStartWithEndTime, startTime = " .. tostring(startTime) .. " endTime = " .. tostring(endTime))
    return startTime, endTime
  end
  return cfg.start_time, cfg.end_time
end
local InitCond = function(subActivity, cond, extraCond)
  if not cond then
    subActivity.Total = 0
    return
  end
  local condition = StringUtil.SplitToNum(cond, ",")
  subActivity.Condition = condition
  subActivity.ExtraCondition = extraCond
  if subActivity.Type == ActivityType.ACTIVITY_TYPE_AREA_GROUP then
    for _, id in ipairs(condition) do
      if id ~= 0 then
        SubAct201[id] = subActivity.ID
      end
    end
    local extraCondition = StringUtil.SplitToNum(extraCond, ",")
    for _, id in ipairs(extraCondition) do
      if id ~= 0 then
        SubAct201[id] = subActivity.ID
      end
    end
  end
  local activityType = subActivity.Type
  local config = CDataTable.GetTableData("ActivityCenterConfig", activityType)
  local totalIndex = 0
  local globalTotalIndex = 0
  if config then
    for i = 1, 8 do
      if config["Condition" .. i] == "1" then
        totalIndex = i
      elseif config["Condition" .. i] == "2" then
        globalTotalIndex = i
      end
    end
  end
  if 0 < totalIndex then
    subActivity.Total = condition[totalIndex]
  else
    subActivity.Total = 0
  end
  if 0 < globalTotalIndex and 0 < condition[globalTotalIndex] then
    subActivity.GlobalTotalNum = condition[globalTotalIndex]
    subActivity.Total = condition[globalTotalIndex]
    subActivity.GlobalPersonMaxGetNum = condition[totalIndex]
  else
    subActivity.GlobalTotalNum = 0
    subActivity.GlobalPersonMaxGetNum = 0
  end
  local CostList = subActivity.CostList
  if activityType == ActivityType.ADDUP_KILL then
    if condition[1] == 0 and condition[2] == 0 then
      subActivity.Total = condition[3]
    end
  elseif activityType == ActivityType.ITEM_EXCHANGE then
    for i = 1, 4, 2 do
      if 0 < condition[i] then
        CostList[#CostList + 1] = {
          itemId = condition[i],
          count = condition[i + 1]
        }
      end
    end
    if extraCond and extraCond ~= "" then
      local args = StringUtil.SplitToNum(extraCond, ",")
      for i = 1, #args, 2 do
        local itemId = tonumber(args[i])
        local count = tonumber(args[i + 1])
        if 0 < itemId then
          CostList[#CostList + 1] = {itemId = itemId, count = count}
        end
      end
    end
  elseif activityType == ActivityType.AVALON_PROGRESS then
    if extraCond and extraCond ~= "" then
      local args = StringToTable(StringUtil.StrReplace(extraCond, ";", ",")) or {}
      local itemId = tonumber(args[1] and args[1][1] or 0)
      if itemId and 0 < itemId then
        subActivity.CostList[#subActivity.CostList + 1] = {itemId = itemId}
      end
    end
  elseif activityType == ActivityType.LUCKYBACK and extraCond and extraCond ~= "" then
    local args = StringUtil.SplitToNum(extraCond, ",")
    if args[1] and args[1] ~= "" then
      CostList[1] = args[1]
    end
    if args[2] and args[2] ~= "" then
      CostList[2] = args[2]
    end
  end
end
function ActivityNewSystem.InitSubNode(parentNode, id, activityData)
  local data = activityData.cfg
  ActivityNewSystem.idMap[id] = parentNode.ID
  if not data or not next(data) then
    return
  end
  for i, award in ipairs(data.award) do
    local key = string.format("%d_%d", id, i)
    local subActivity = ActivityNewSystem.subListMap[key]
    if not subActivity then
      subActivity = {
        ID = id,
        Index = i,
        Title = award.task_title,
        cond_2 = data.cond_2,
        Cycle = data.cycle_type,
        Arg1 = award.extern_arg_1,
        Arg2 = award.extern_arg_2,
        Key = key,
        Drop = {},
        CostList = {},
        Type = data.type,
        Order = data.show_order * 10000 + (100 - i),
        ImgLink = data.page_link or "",
        StartTime = data.start_time,
        EndTime = data.end_time,
        ShowImgLink = data.activity_image_link or "",
        Desc = data.activity_desc or "",
        IsCheckNotice = 0,
        Progress = 0,
        Status = 0,
        SharePicture = data.announcement_share_picture,
        ViedoUrl = data.announcement_play_video,
        canAwardVersion = ""
      }
      if data.can_award_version and data.can_award_version ~= "" then
        subActivity.canAwardVersion = data.can_award_version
      end
      if data.left_label then
        subActivity.RedPointSwitcher = data.left_label or 0
      end
      if data.type ~= ActivityType.IMAGES_GROUP then
        parentNode.List[#parentNode.List + 1] = subActivity
      end
      ActivityNewSystem.subListMap[key] = subActivity
      log_tree("SubNode = ", award)
    end
    if data.type == ActivityType.IMAGES_GROUP_SUB then
      subActivity.Title = data.activity_name or ""
      subActivity.BackupParam1 = data.back_up_one or ""
      subActivity.BackupParam2 = data.back_up_two or ""
    end
    if activityData.data and activityData.data.other then
      subActivity.other = activityData.data.other or {}
    end
    subActivity.Drop = {}
    subActivity.CostList = {}
    subActivity.IsCheckNotice = 0
    InitCond(subActivity, award.cond, award.extra_cond)
    for _, dropItem in ipairs(award.drop) do
      local itemCfg = CDataTable.GetTableData("Item", dropItem.item_id)
      if itemCfg then
        local ele = {}
        if ActivityNewSystem.IsForeverDropItem(dropItem, itemCfg) then
          local item_revise_str = dropItem.item_revise_str
          if item_revise_str and item_revise_str ~= "" then
            local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
            ele.expireTime = ActivityUtil.GetReviseExpireTime(item_revise_str)
          else
            ele.validTimes = itemCfg.ValidTimes or 0
          end
        elseif dropItem.item_expire_time ~= 0 then
          ele.validTimes = dropItem.item_expire_time
        else
          ele.validTimes = itemCfg.ValidTimes
        end
        ele.itemId = dropItem.item_id
        ele.count = dropItem.item_num
        ele.reviseId = dropItem.item_revise_id
        subActivity.Drop[#subActivity.Drop + 1] = ele
      end
    end
    if subActivity.Type == ActivityType.ITEM_EXCHANGE then
      if award.extern_arg_1 == 1 then
        parentNode.SelectExchange = true
      else
        parentNode.SelectExchange = false
      end
    end
    if subActivity.Type == ActivityType.MANOR_RISK then
      subActivity.data = activityData.data.moonlight
    end
  end
end
function ActivityNewSystem.IsForeverDropItem(dropData, itemCfg)
  if dropData.item_expire_time ~= 0 then
    return false
  end
  if itemCfg.ValidTimes ~= 0 then
    return false
  end
  if itemCfg.ExTime ~= "" then
    return false
  end
  return true
end
function ActivityNewSystem.SortFunc(a, b)
  local orderA = a.Order or 1
  local orderB = b.Order or 1
  if orderA == orderB then
    local nTime_A = a.StartTime or 0
    local nTime_B = b.StartTime or 0
    if nTime_A == nTime_B then
      return a.ID < b.ID
    else
      return nTime_A > nTime_B
    end
  else
    return orderA < orderB
  end
end
function ActivityNewSystem.SortActivity()
  if ActivityNewSystem.data and #ActivityNewSystem.data > 1 then
    table.sort(ActivityNewSystem.data, ActivityNewSystem.SortFunc)
  end
end
function ActivityNewSystem.UpdateOneActivityData(id, data)
  log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.UpdateOneActivityData, id = " .. tostring(id))
  if not data then
    log_warning("[edward][logic_activity_mgr] ActivityNewSystem.UpdateOneActivityData, no data, id = " .. tostring(id))
    return
  end
  if ActivityNewSystem.hashList[id] then
    ActivityNewSystem.hashList[id].UpdateTime = data.update_time or 0
  else
    log_warning("[edward][logic_activity_mgr] ActivityNewSystem.UpdateOneActivityData, activity not found in hashList, id =" .. tostring(id))
    return
  end
  ActivityNewSystem.UpdateExchangeData(id, data)
  local actType = tonumber(data.type)
  data.type = actType
  if Update_NoUpdateType[actType] then
    return
  end
  local activity = ActivityNewSystem.dataMap[id]
  if activity then
    if Update_OnlyOtherType[actType] then
      if data.other then
        activity.other = data.other or {}
      end
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ONLY_UPDATE_ACT_OTHER_DATA, actType)
    elseif actType == ActivityType.NEW_PLAYER then
      activity.open_time = data.open_time
    elseif actType == ActivityType.INVITEFBFRIENDS then
      if data.other then
        activity.invite_total_count = data.other.invite_total_count or 0
      end
    elseif actType == ActivityType.SUPPLY_BUY_ONE or actType == ActivityType.SUPPLY_BUY_TEN then
      if data.other then
        activity.other = data.other
        EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE)
      end
    elseif actType == ActivityType.LUCKYUNBACK_SURPRISE then
      local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
      LuckyUnbackSystem.CheckEasterEgg()
      local LuckyDoubleSystem = require("client.slua.logic.lobby_activity.logic_luckydouble_activity")
      LuckyDoubleSystem.UpdateEasterEgg()
    elseif actType == ActivityType.STARTER_PACK_US then
      ActivityNewSystem.UpdateStarterPackData(id, data)
    elseif actType == ActivityType.SUPPLY_ACTIVITY_MUST_DROP or actType == ActivityType.SUPPLY_ACTIVITY_EXTRA_BOX or actType == ActivityType.SUPPLY_ACTIVITY_LUCKY or actType == ActivityType.ACTIVITY_GRADUALLY_IMPROVE then
      if data.other then
        activity.other = data.other
        EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_ACTIVITY_UPDATE, activity)
      end
    elseif actType == ActivityType.ACTIVITY_TYPE_EXCITINGTOUR then
      activity.map_list = data.other.map_list or {}
      activity.cur_map_idx = data.other.cur_map_idx
      activity.cur_step = data.other.cur_step
      activity.score = data.other.score
      activity.logs = data.other.log
      activity.circle_award = data.other.circle_award
      activity.Param1 = data.cost_res_id
    elseif actType == ActivityType.DISCOUNT_TICKET then
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_DISCOUNT_TICKET)
    elseif actType == ActivityType.Privilege then
      if data.other.esports_money and activity.other.esports_money then
        local earn_money = data.other.esports_money - activity.other.esports_money
        if 0 < earn_money then
          local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
          Logic_CommonItemGet.ShowPanel_DefaultStyle({
            {
              res_id = 3601002,
              count = earn_money,
              valid_hours = 0
            }
          })
        end
      end
      activity.other = data.other
    elseif actType == ActivityType.ICE_DRINK then
      activity.other.repeat_count = data.other.repeat_count
      activity.other.carried_drinks = data.other.carried_drinks
      activity.other.is_first_reward_taken = data.other.is_first_reward_taken
      EventSystem:postEvent(EVENTTYPE_ACTIVITY_ICEDRINK, EVENTID_ICEDRINK_REFRESH_DATA, data.other.carried_drinks)
    elseif actType == ActivityType.Subway_Buy then
    elseif actType == ActivityType.PROGRESS or actType == ActivityType.AVALON_PROGRESS or actType == ActivityType.ACTIVITY_CENTER_KR_PROGRESS or actType == ActivityType.GIFT_INTIMACY_DOUBLE then
      if data.other then
        activity.other = data.other
      end
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_PROGRESS_UPDATE, data, id)
    elseif actType == ActivityType.EXPLORE_ACTIVITY then
      if data.other then
        activity.other = data.other
      end
      local ExploreSystem = require("client.slua.logic.explore.logic_explore")
      ExploreSystem.UpdateActivityData(id, data.other)
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_APLAN_ACTIVITY_UPDATE)
    elseif actType == ActivityType.TaskPropsCollect then
      if data.other then
        activity.other = data.other
        ActivityNewSystem.UpdateTaskPropsData(id, data)
      end
    elseif actType == ActivityType.ASSEMBLY_FRIEND_JK then
      if data.other then
        activity.other = data.other
        ActivityNewSystem.UpdateAssemblySubData_JK(id, data)
      end
    elseif actType == ActivityType.Home_Style_Accum_Activity then
      local logic_home_promotion_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_promotion_activity)
      local oldData = logic_home_promotion_activity:GetActivityData()
      local newData = data
      if oldData then
        oldData.other = newData.other
        if newData.award and oldData.List and #newData.award == #oldData.List then
          for i, v in ipairs(newData.award) do
            oldData.List[i].Status = v.status
          end
        end
        EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_UPDATE_HOME_STYLE_ACCUM_ACTIVITY)
      else
        printf("ActivityNewSystem.UpdateOneActivityData, Home_Style_Accum_Activity, no oldData")
      end
    elseif actType == ActivityType.HOME_LOGIN_ACT or actType == ActivityType.HOME_COMMON_ACT then
      activity.other = data.other
      for _, subActivity in pairs(activity.List) do
        subActivity.other = data.other
      end
    elseif actType == ActivityType.Home_HostParty then
      activity.other = data.other
      for _, subActivity in pairs(activity.List) do
        subActivity.Progress = tonumber(data.other.total_finish_count)
      end
    elseif actType == ActivityType.Home_JoinParty then
      activity.other = data.other
      for _, subActivity in pairs(activity.List) do
        subActivity.Progress = tonumber(data.other.total_join_count)
      end
    elseif actType == ActivityType.DESTOP_TOOL then
      activity.other = data.other
      if data.other and data.other.total_login_map then
        for _, subActivity in pairs(activity.List) do
          local Arg1 = subActivity.Arg1
          if data.other.total_login_map[Arg1] and data.other.total_login_map[Arg1].days then
            subActivity.Progress = data.other.total_login_map[Arg1].days
          end
        end
      end
    end
    if data.from then
      activity.    end
  end
  if data.father_activity_id then
    log(bWriteLog and "ActivityNewSystem.UpdateOneActivityData, father_activity_id")
    local tActivity = ActivityNewSystem.dataMap[data.father_activity_id]
    if tActivity and tActivity.List then
      for _, v in pairs(tActivity.List) do
        if v.ID == id then
          v.other = data.other
          if actType == ActivityType.DESTOP_TOOL then
            if data.other and data.other.total_login_map then
              local Arg1 = v.Arg1
              if Arg1 and data.other.total_login_map[Arg1] and data.other.total_login_map[Arg1].days then
                v.Progress = data.other.total_login_map[Arg1].days
              end
            end
          elseif actType == ActivityType.BlackFriday_CyberScore then
            local totalValue = tonumber(v.Total) or 0
            local scoreValue = tonumber(v.other.total_score) or 0
            v.Progress = math.min(totalValue, scoreValue)
          end
        end
      end
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_DATAMGR_ACTIVITY_FATHERTASK_DATA, data.father_activity_id)
    end
  end
  if Update_NoProgressType[actType] then
    return
  end
  if Update_SpecialType[actType] then
    local subActivity
    for i = 1, SubActMaxCount do
      subActivity = ActivityNewSystem.subListMap[string.format("%d_%d", id, i)]
      if subActivity then
        if subActivity.Type == actType then
          local svrProgress = data.other[Update_SpecialType[actType]]
          subActivity.Progress = svrProgress or 0
          if type(svrProgress) == "table" then
            subActivity.Progress = svrProgress[i] or 0
          end
          if subActivity.Progress > subActivity.Total then
            subActivity.Progress = subActivity.Total
          end
        end
      else
        break
      end
    end
    return
  end
  if not data.other then
    return
  end
  for _, progressData in pairs(data.other) do
    if type(progressData) == "table" then
      for index, value in pairs(progressData) do
        if type(value) == "number" then
          local key = id .. "_" .. index
          local subActivity = ActivityNewSystem.subListMap[key]
          if subActivity then
            subActivity.Progress = value
            if subActivity.Progress > subActivity.Total then
              subActivity.Progress = subActivity.Total
            end
          end
        end
      end
    end
  end
  if not next(data.other) and not Update_Group_NoProgressType[actType] then
    local subActivity
    for i = 1, SubActMaxCount do
      subActivity = ActivityNewSystem.subListMap[string.format("%d_%d", id, i)]
      if subActivity then
        if subActivity.Type ~= ActivityType.ITEM_EXCHANGE then
          subActivity.Progress = 0
        end
      else
        break
      end
    end
  end
end
function ActivityNewSystem.ProcessDuplicatedActivity()
  for Type, Predicate in pairs(NonDuplicatedType) do
    if type(Predicate) ~= "function" then
      Predicate = DefaultPredicate
    end
    Predicate(Type)
  end
end
function ActivityNewSystem.UpdateExchangeData(id, data)
  local count = 0
  data.award = data.award or {}
  for index, statusData in ipairs(data.award) do
    local key = string.format("%d_%d", id, index)
    local subActivity = ActivityNewSystem.subListMap[key]
    if not subActivity then
      log_warning(string.format("[edward][logic_activity_mgr] ActivityNewSystem.UpdateExchangeData, activity can't find on id:%d index:%d ]", id, index))
    else
      subActivity.Status = statusData.status
      if subActivity.Type == ActivityType.ITEM_EXCHANGE then
        subActivity.Progress = statusData.exchange_cnt or 0
        subActivity.IsCheckNotice = statusData.has_point or 0
        if subActivity.Progress == subActivity.Total then
          subActivity.Status = ActivityStatus.Get
        end
      elseif subActivity.Type == ActivityType.ASSEMBLY_FRIEND_JK then
        subActivity.Total = #data.award
        if statusData.status and statusData.status ~= 0 then
          count = count + 1
        end
        subActivity.Progress = count
      elseif subActivity.Type == ActivityType.ThemePlay_Activity then
        subActivity.Total = subActivity.Condition and subActivity.Condition[2] or 0
        subActivity.Progress = data.other and data.other.progress and data.other.progress[1] or 0
      end
    end
  end
end
function ActivityNewSystem.UpdateTaskPropsData(id, data)
  for index, _ in ipairs(data.other) do
    local key = string.format("%d_%d", id, index)
    local subActivity = ActivityNewSystem.subListMap[key]
    if not subActivity then
      log_warning(string.format("[edward][logic_activity_mgr] ActivityNewSystem.UpdateTaskPropsData, activity can't find on id:%d index:%d ]", id, index))
    else
      subActivity.other = data.other
    end
  end
end
function ActivityNewSystem.UpdateAssemblySubData_JK(id, data)
  if data.award and next(data.award) then
    for index, getInfo in pairs(data.award) do
      local key = string.format("%d_%d", id, index)
      local subActivity = ActivityNewSystem.subListMap[key]
      if not subActivity then
        log_warning(string.format("[YY][logic_activity_mgr] ActivityNewSystem.UpdateAssemblySubData_JK, activity can't find on id:%d index:%d ]", id, index))
      else
        subActivity.Status = getInfo and getInfo.status or 0
      end
    end
  end
end
function ActivityNewSystem.RemoveActivity(id, dontNtf)
  log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.RemoveActivity, actID = " .. tostring(id))
  ActivityNewSystem.hashList[id] = nil
  ActivityNewSystem.dataMap[id] = nil
  local removed = false
  local subActivity
  for i = 1, SubActMaxCount do
    local key = string.format("%d_%d", id, i)
    subActivity = ActivityNewSystem.subListMap[key]
    if subActivity then
      ActivityNewSystem.subListMap[key] = nil
      if subActivity.Type == ActivityType.IMAGES_GROUP_SUB then
        local fatherActivity = ActivityNewSystem.dataMap[ActivityNewSystem.idMap[id]]
        if fatherActivity then
          for ii, vv in ipairs(fatherActivity.List) do
            if vv.ID == id then
              table.remove(fatherActivity.List, ii)
              removed = true
              log(bWriteLog and "[edward][logic_activity_mgr] ActivityNewSystem.RemoveActivity, remove sub activity id = " .. tostring(id))
              break
            end
          end
        end
      end
    else
      break
    end
  end
  if removed and not dontNtf then
    local changeList = {
      idList = {},
      typeList = {}
    }
    changeList.idList[ActivityNewSystem.idMap[id] or -1] = true
    changeList.typeList[ActivityType.IMAGES_GROUP_SUB] = true
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
  end
  for i, activity in pairs(ActivityNewSystem.data) do
    if activity.ID == id then
      table.remove(ActivityNewSystem.data, i)
      _actCacheByType[activity.Type] = nil
      _actListCacheByType[activity.Type] = nil
      if activity.ShowSceneID > 0 then
        _actCacheBySceneID[activity.ShowSceneID] = nil
        _actListCacheBySceneID[activity.ShowSceneID] = nil
      end
      if _svrActMapCacheByType[activity.Type] then
        _svrActMapCacheByType[activity.Type][id] = nil
      end
      EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ACTIVITY_REMOVED, activity)
      break
    end
  end
end
function ActivityNewSystem.UpdateStarterPackData(id, data)
  if not ActivityNewSystem.bCanUpdateOtherModuleData then
    return
  end
  log_tree("Get one data from server:  ", data)
  log_tree("Local Activity Data:  ", ActivityNewSystem.activityDataTable[id].data)
  if data == nil or data.award == nil or data.award[1] == nil or data.award[1].status == nil then
    return
  end
  local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
  if data ~= nil and data.starter_pack_final_offer ~= nil and data.starter_pack_final_offer == true then
    StarterPackSystem.bShowedFinalOfferServer = true
  else
    StarterPackSystem.bShowedFinalOfferServer = false
  end
  if data ~= nil and data.award ~= nil and StarterPackSystem.bShowedFinalOfferServer == false then
    StarterPackSystem.bForceUpdate = true
    log(bWriteLog and "Server Player Starterpack status:  " .. tostring(data.award[1].status) .. " local Status: " .. tostring(ActivityNewSystem.activityDataTable[id].data.award[1].status))
    if data.award[1].status == 1 and ActivityNewSystem.activityDataTable[id].data.award[1].status == 0 then
      if data.other ~= nil then
        StarterPackSystem.fStarterpack_UnlockTime = data.other.starter_pack_unlock_time
      end
      StarterPackSystem.bShowStarterPackUnlockUI = true
    else
      log(bWriteLog and "Set unlockUI bShowStarterPackUnlockUI to false ")
      log(bWriteLog and "Server Player Starterpack status:  " .. tostring(data.award[1].status) .. " local Status: " .. tostring(ActivityNewSystem.activityDataTable[id].data.award[1].status))
    end
    ActivityNewSystem.activityDataTable[id].data.award[1].status = data.award[1].status
    ActivityNewSystem.bActivityLoop = true
    if data.award[1].status == 1 then
      StarterPackSystem.Enabled = true
      StarterPackSystem.LogicStart()
    elseif data.award[1].status == 2 then
      StarterPackSystem.Enabled = false
      StarterPackSystem.LogicStop()
    end
    ActivityNewSystem.bActivityLoop = false
  end
end
function ActivityNewSystem.UpdateABTagData(tag)
  if not ActivityNewSystem.bCanUpdateOtherModuleData then
    return
  end
  if tag then
    DataMgr.roleData.ab_testing_groupid = tag
  end
  if DataMgr.roleData.ab_testing_groupid then
    log(bWriteLog and "ABTest###retrive   AB tag \239\188\154" .. tostring(DataMgr.roleData.ab_testing_groupid))
    local telemetry_file_name = string.format("%s_%s", "SaveGames/ABTesting", "tel.bin")
    local bHasSavedGrouId = false
    local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
    if StarterPackSystem.lastLogoutTime == nil or StarterPackSystem.lastLogoutTime == 0 then
      log(bWriteLog and "ZK this is a new user")
    else
      local str = Client.LoadFileToString(telemetry_file_name)
      if str ~= nil and str ~= "" then
        local tab = json.decode(str)
        for k, v in pairs(tab) do
          if k == "abtesting" and v == DataMgr.roleData.ab_testing_groupid then
            log(bWriteLog and "ZK get " .. tostring(k) .. "  " .. tostring(v))
            bHasSavedGrouId = true
          end
        end
      end
    end
    if bHasSavedGrouId == false then
      local tab = {}
      tab.abtesting = DataMgr.roleData.ab_testing_groupid
      local jsonStr = json.encode(tab)
      log(bWriteLog and "ZK Save Json file for ab testing , ID " .. DataMgr.roleData.ab_testing_groupid)
      Client.SaveStringToFile(jsonStr, telemetry_file_name)
      log(bWriteLog and "ABTest###retrive   AB teletry: " .. tostring(DataMgr.roleData.ab_testing_groupid))
      local gem_report_utils = require("client.logic.store.gem_report_utils")
      gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_StarterPack, gem_report_utils.SubEventName_ABTestingGroup, tostring(DataMgr.roleData.uid), tostring(DataMgr.roleData.ab_testing_groupid))
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.ABTestingGroup, 0, tostring(DataMgr.roleData.ab_testing_groupid))
    end
  else
    log(bWriteLog and "ABTest###retrive   AB tag \239\188\154null")
  end
end
function ActivityNewSystem.IsAllDone(act, Type)
  Type = Type or act.TabType
  if Type ~= ActivitySwitchType.Activity then
    return false
  end
  local list = act and act.List
  if list and next(list) then
    for _, v in ipairs(list) do
      if v.Status ~= E_ActivityProgressStatus.Get then
        return false
      end
    end
  end
  return true
end
function ActivityNewSystem.HasActivityRedDotByID(activityId, fromBrother)
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = ActivityMacros.RedDotType.None
  if not activityId then
    log_warning("[ Error when HasActivityRedDotByID : activityId is null]")
    return false, RedDotType
  end
  local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
  if Logic_Activity_Center.otherImageActRedDot[activityId] ~= nil then
    RedDotType = Logic_Activity_Center.otherImageActRedDot[activityId]
    return RedDotType ~= ActivityMacros.RedDotType.None, RedDotType
  end
  if Logic_Activity_Center.GetBrotherId(activityId) and not fromBrother then
    return false, RedDotType
  end
  local map = ActivityNewSystem.dataMap
  if not map then
    log_warning("[ Error when HasActivityRedDotByID : activity data need init]")
    return false, RedDotType
  end
  local activity = map[activityId]
  if not activity then
    log_warning("[ Error when HasActivityRedDotByID : activity not found id :]" .. activityId)
    return false, RedDotType
  end
  if activity.Type == ActivityType.QUESTION then
    log(bWriteLog and "HasActivityRedDotByID question done=" .. tostring(ActivityNewSystem.bQuestionDone))
    local bShow = ActivityNewSystem.bQuestionDone == false
    if bShow then
      RedDotType = ActivityMacros.RedDotType.Normal
    end
    return bShow, RedDotType
  end
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  local pandoraRed
  if pandoraSystem.CheckSysOpen() then
    local subList = ActivityNewSystem.GetActivityByID(activityId)
    local JumpUtils = require("client.logic.store.jump_utils")
    local TableUtil = require("common.table_util")
    local url = TableUtil.GetTableValue(subList, "ImgLink")
    if url and JumpUtils.IsPanDoraJumpUrl(url) then
      local params = StringUtil.ParseURLParams(url)
      local actid = tonumber(params.actid)
      pandoraRed = pandoraSystem.ActHasRedPoint(actid, activityId)
      if pandoraRed then
        RedDotType = pandoraSystem.GetRedDotType(actid)
      end
      return pandoraRed, RedDotType
    end
  end
  local LogicGameletRedPoint = require("client.slua.logic.gamelet.LogicGameletRedPoint")
  if LogicGameletRedPoint.GameletAct2Red[activityId] then
    local bRed = false
    bRed, RedDotType = LogicGameletRedPoint:GetRed(activityId)
    return bRed, RedDotType
  end
  local isCenterRedPoint = Logic_Activity_Center.CheckHasH5CenterRedPoint(activityId)
  if isCenterRedPoint then
    return isCenterRedPoint, ActivityMacros.RedDotType.Normal
  end
  for _, subActivity in ipairs(activity.List) do
    if subActivity.Type == ActivityType.ITEM_EXCHANGE then
      if subActivity.IsCheckNotice == 1 and subActivity.Status == ActivityStatus.Done then
        return true, ActivityMacros.RedDotType.Reward
      end
    elseif subActivity.Type == ActivityType.LoginPunchIn then
      local punchIn = require("client.slua.logic.activity.logic_login_punchin")
      if subActivity.Status == ActivityProgressStatus.Done and (punchIn.HasJump(subActivity.Key) or subActivity.ImgLink == "") then
        log_warning(bWriteLog and "  :LoginPunchIn true : " .. tostring(activityId))
        return true, ActivityMacros.RedDotType.Reward
      end
    elseif subActivity.Status == ActivityStatus.Done then
      local UIUtil = require("client.common.ui_util")
      for _, dropData in ipairs(subActivity.Drop) do
        if UIUtil.IsEncryptionItem(dropData.itemId) then
          return false, RedDotType
        end
      end
      return true, ActivityMacros.RedDotType.Reward
    end
  end
  return false, RedDotType
end
function ActivityNewSystem.GetFormatUrl(url)
  local webTicket = Client.GetWebViewTicket(NetInterface)
  local gameID = Client.GetITopGameId()
  local formatUrl = string.gsub(url, "{gameid}", gameID, 1)
  formatUrl = string.gsub(formatUrl, "{itop_openid}", DataMgr.roleData.openID, 1)
  formatUrl = string.gsub(formatUrl, "{itop_ticket}", webTicket, 1)
  formatUrl = string.gsub(formatUrl, "{game_season}", DataMgr.season_id, 1)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  formatUrl = string.gsub(formatUrl, "{game_area}", ZoneSystem.GetChooseZone(), 1)
  formatUrl = string.gsub(formatUrl, "{language}", Client.GetCurrentLanguage(), 1)
  formatUrl = string.gsub(formatUrl, "{version}", tostring(Client.GetApplicationVersion()), 1)
  return formatUrl
end
function ActivityNewSystem.GetFormatUrlByPersonalInfo(url, actID)
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  url = webModule:AddParameterByPersonalInfo(url, true)
  if url == "" then
    return url
  end
  if string.find(url, "activity_id=") == nil then
    url = string.format("%s&activity_id=%s", url, tostring(actID))
  end
  return url
end
function ActivityNewSystem.PostActivityRedDot(onlyBannerRedDot)
  if not onlyBannerRedDot then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVNETID_ACTIVITY_REDDOT)
  end
  if ActivityNewSystem.data then
    for _, v in ipairs(ActivityNewSystem.data) do
      if v.Type == ActivityType.ITEM_EXCHANGE then
        local exParam = v.ExParam
        if exParam ~= "" then
          local params = StringUtil.Split(exParam, ",")
          local isShowInLobby = tonumber(params[1]) == 1
          if isShowInLobby then
            for _, vv in ipairs(v.List) do
              if vv.Status == ActivityStatus.Done then
                EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVNETID_ACTIVITY_BANNER_REDDOT, BP_ENUM_MODULE_EXCHANGE_ACTIVITY, true)
                return
              end
            end
          end
        end
      end
    end
  end
  local taskData = ActivityNewSystem.GetActivityBySceneID(ActivitySceneID.TopicExchange)
  if taskData and #taskData.List > 0 then
    for index = 1, #taskData.List do
      local data = taskData.List[index]
      if not data then
        break
      end
      if data.Status == ActivityStatus.Done then
        EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVNETID_ACTIVITY_BANNER_REDDOT, BP_ENUM_MODULE_EXCHANGE_ACTIVITY, true)
        return
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVNETID_ACTIVITY_BANNER_REDDOT, BP_ENUM_MODULE_EXCHANGE_ACTIVITY, false)
end
function ActivityNewSystem.ShowActivityUISlap(_, _, vars)
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ParamTable = ui_show_queue_config.GetParamTable(nil, "IsSlapUI")
  ActivityNewSystem.ShowActivityUI(_, _, vars, ParamTable)
end
function ActivityNewSystem.ShowActivityUI(_, _, vars, ParamTable)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local GuideType = LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_SEASON_GUIDE
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if growthprojectMgrB.CheckGuideStep(GuideType, 0) then
    log(bWriteLog and "[v_vyhhzhang] SeasonGuide not Show Act Center")
    return
  end
  log_tree("vars", vars)
  local logic_activity_recharge_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_activity_recharge_mgr)
  local actId = vars and vars.id and tonumber(vars.id)
  if logic_activity_recharge_mgr:IsInActivityBlackList(actId, true) then
    log(bWriteLog and "[YY]ShowActivityUI=====" .. tostring(111111111))
    return
  end
  local ActivityCenterTabModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterTabModule)
  ActivityCenterTabModule:ReqActCenterTabConfig()
  if UIManager.IsUIShow(UIManager.UI_Config.new_activity_center) then
    local UI = UIManager.GetUI(UIManager.UI_Config.new_activity_center)
    local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
    if vars.id then
      local id = tonumber(vars.id)
      if Logic_Activity_Center.FindActSwitchTypeByID(id) ~= 0 then
        UI:SetData(vars.id)
      else
        UIManager.AndroidBackToLobby()
      end
    elseif vars.tab then
      local tab = tonumber(vars.tab)
      if Logic_Activity_Center.ExistTabIndexByType(tab) then
        local index = Logic_Activity_Center.FindTabIndexByType(tab)
        UI:ShowSwitchAndTab(index)
      else
        UIManager.AndroidBackToLobby()
      end
    end
  else
    local extraData = {
      actId = tonumber(vars.id),
      tabId = tonumber(vars.tab),
      DisplayScene = tonumber(vars.DisplayScene),
      OriginParams = vars
    }
    UIManager.ShowUI(UIManager.UI_Config.new_activity_center, extraData, ParamTable)
  end
end
function ActivityNewSystem.OpenSuperCore(_, _, vars)
  local SuperCoreRedDotData = require("client.slua.logic.supercore.supercore_reddot_data")
  SuperCoreRedDotData.UpdateSuperCoreEntryCount(0)
  local CommunityHandler = require("client.network.Protocol.CommunityHandler")
  if CommunityHandler.red_type_new == 106 then
    CommunityHandler.send_shequn_clear_reddot_req(CommunityHandler.red_type_new)
    CommunityHandler.red_type_new = 0
    EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_SUPERCORE_ENTRY)
  end
  local ticket = Client.GetWebViewTicket(NetInterface)
  local country = FuncUtil.GetAccountRegionForBP()
  local language = Client.GetCurrentLanguage()
  local area_id = tostring(DataMgr.roleData.idip_area_id or 1)
  local baseUrl = FuncUtil.GetDomainByID(3366206)
  local source = "SecondaryEntrance"
  if vars and vars.source and vars.source ~= "" then
    source = vars.source
  end
  local finalUrl = baseUrl .. "sTicket=" .. ticket .. "&country=" .. country .. "&area_id=" .. area_id .. "&language=" .. language .. "&source=" .. source
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(finalUrl)
end
function ActivityNewSystem.CheckSuperVIP()
  if LobbySystem.roleData and LobbySystem.roleData.is_rich_user and tonumber(LobbySystem.roleData.is_rich_user) == 1 then
    return true
  end
  return false
end
function ActivityNewSystem.OpenPremiumHallSVIP(_, _, vars)
  local CustomerHandler = require("client.network.Protocol.CustomerHandler")
  CustomerHandler.send_customer_service_clear_reddot_req()
  local IntlHelper = import("IntlHelper")
  IntlHelper.HelpshiftClearUnreadMessgesCount()
  local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
  LogicCustomerService.Open("kfbcustomer")
end
function ActivityNewSystem.CheckPremiumHallSVIP()
  log(bWriteLog and "ActivityNewSystem.CheckPremiumHallSVIP is_svip_user is " .. tostring(LobbySystem.roleData.is_svip_user))
  if LobbySystem.roleData and LobbySystem.roleData.is_svip_user and tonumber(LobbySystem.roleData.is_svip_user) == 1 then
    return true
  end
  return false
end
function ActivityNewSystem.CanShowActivityCenterFace()
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if logic_return_activity_utils.IsActInProgress() then
    local serverTime = TimeUtil.GetServerTimeInSec()
    local interval = 259200
    local back_user_data = DataMgr.roleData and DataMgr.roleData.back_user_data
    if back_user_data.rejoin_start_time and interval > serverTime - back_user_data.rejoin_start_time then
      log(bWriteLog and "ActivityNewSystem.CanShowActivityCenterFace. Return Player can't show activity face slap")
      return false
    end
  end
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local SystemRedDot = ActivityRedDot.GetRedDotData(reddot_macro.SystemName.ActivityCenter)
  if SystemRedDot and SystemRedDot.realCount and SystemRedDot.realCount <= 0 then
    log(bWriteLog and "ActivityNewSystem.CanShowActivityCenterFace. There is no red dot in activity center")
    return false
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if NewFaceSlapSystem:HasShowedFaceSlap(BP_ENUM_MODULE_NOTICE) then
    log(bWriteLog and "ActivityNewSystem.CanShowActivityCenterFace. has showed iTop or IDIP face slap")
    return false
  end
  return true
end
function ActivityNewSystem.ShowExchangeActivityUI(_, _, vars)
  if vars then
    if vars.id then
      local actID = tonumber(vars.id)
      local activity = ActivityNewSystem.dataMap[actID]
      if activity then
        local exParam = activity.ExParam
        if exParam ~= "" then
          local params = StringUtil.Split(exParam, ",")
          local isShowInLobby = tonumber(params[1]) == 1
          if isShowInLobby and params[2] and params[2] ~= "" then
            local ui = UIManager.ShowUI(UIManager.UI_Config[params[2]])
            ui:SetData(actID)
            return
          end
        end
      end
    elseif vars.itemId then
      local actList = ActivityNewSystem.GetActivityListByType(ActivityType.ITEM_EXCHANGE)
      for _, v in ipairs(actList) do
        local exParam = v.ExParam
        if exParam ~= "" then
          local params = StringUtil.Split(exParam, ",")
          local isShowInLobby = tonumber(params[1]) == 1
          if isShowInLobby and params[2] and params[2] ~= "" and string.find(params[3], vars.itemId) then
            local ui = UIManager.ShowUI(UIManager.UI_Config[params[2]])
            ui:SetData(v.ID)
            return
          end
        end
      end
    end
  end
  ShowNotice(4002)
end
function ActivityNewSystem.JumpUrl(url, total, actID, dontCloseActivityInJumping)
  log_warning(bWriteLog and "  :ActivityNewSystem.JumpUrl url: " .. tostring(url))
  if not ActivityNewSystem.bCanUpdateOtherModuleData then
    return
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if Lobby_Main_City_Enter.bEnterMainCityLoading then
    log(bWriteLog and "ActivityNewSystem.JumpUrl return in enterMainCityLoading")
    return
  end
  local JumpUtils = require("client.logic.store.jump_utils")
  local CloseActivityUI = function()
    if UIManager then
      UIManager.CloseUI(UIManager.UI_Config.new_activity_center)
    end
  end
  if JumpUtils.IsGameJumpUrl(url) then
    GlobalData.JumpGameUrl(url)
    dontCloseActivityInJumping = dontCloseActivityInJumping and dontCloseActivityInJumping or false
    if string.find(url, string.format("module=%d", BP_ENUM_MODULE_ACTIVITY)) == nil and dontCloseActivityInJumping == false then
      log(bWriteLog and "Close Activity Center")
      CloseActivityUI()
    end
  elseif JumpUtils.IsPanDoraJumpUrl(url) then
    local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
    log(bWriteLog and "[ :ActivityNewSystem.JumpUrl")
    pandoraSystem.TryJumpUrl(url, actID)
  elseif StringUtil.Starts(url, "http") or StringUtil.Starts(url, "www") then
    local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
    ActivityCenterSystem.UpdateRedPointInJumpWebUrl(actID)
    if total and 0 < total then
      url = ActivityNewSystem.GetFormatUrlByPersonalInfo(url, actID)
      if total == 2 then
        url = url .. string.format("&partition=%s-%s-%s-%s", DataMgr.VGameAppID, Client.GetAppVersion(), DataMgr.roleData.openID, FuncUtil.GetAccountRegionForBP())
      end
      GlobalData.JumpWebUrl(url)
      local async = require("client.common.async")
      async.Run(function(co)
        async.AwaitEvent(co, nil, EVENTTYPE_ACTIVITY, EVENTID_QUESTIONNAIRE_BACK)
        local QuestionnaireHander = require("client.network.Protocol.QuestionnaireHander")
        QuestionnaireHander.send_questionnaire_finished_report_req(actID)
      end)
    else
      url = string.gsub(url, "{openid}", DataMgr.roleData.openID, 1)
      GlobalData.JumpWebUrl(url)
    end
  else
    if url ~= "" and _G[url] then
      local func = _G[url]
      func()
    end
    CloseActivityUI()
  end
end
function ActivityNewSystem.HandleH5WebViewJson(str)
  log(bWriteLog and "ActivityNewSystem.HandleH5WebViewJson & str = " .. tostring(str))
  local CentauriHandler = require("client.network.Protocol.CentauriHandler")
  if not ActivityNewSystem.bCanUpdateOtherModuleData then
    log(bWriteLog and "ActivityNewSystem.HandleH5WebViewJson not bCanUpdateOtherModuleData")
    return
  end
  EventSystem:postEvent(EVENTTYPE_WEBVIEW, EVENTID_CLOSEWEBVIEW_FROMH5, str)
  if str == nil or str == "" then
    log(bWriteLog and "ActivityNewSystem.HandleH5WebViewJson str nil")
    CentauriHandler.send_imobile_notify_client_charge(0)
    return
  end
  local result = json.decode(str)
  if result ~= nil then
    log(bWriteLog and "ActivityNewSystem.HandleH5WebViewJson result ~= nil")
    if result.url then
      result.url = ActivityNewSystem.GetFormatUrl(result.url)
    end
    local protoType = result.type
    log(bWriteLog and "  :protoType" .. tostring(protoType))
    local web2clientModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.web2clientModule)
    local func = web2clientModule[protoType]
    if type(func) == "function" then
      func(web2clientModule, result)
    end
  else
    log(bWriteLog and "ActivityNewSystem.HandleH5WebViewJson, result = nil")
  end
  CentauriHandler.send_imobile_notify_client_charge(0)
end
function ActivityNewSystem.GetSubAct201()
  return SubAct201
end
function ActivityNewSystem.GetSubAct46()
  return SubAct46
end
function ActivityNewSystem.IsEmbeddingGameletAct(actData)
  if not actData or not actData.ImgLink then
    return false
  end
  local url = actData.ImgLink
  local params = StringUtil.ParseURLParams(url)
  local moduleId = tonumber(params.module)
  if not moduleId or moduleId ~= BP_ENUM_MODULE_HOSTED_GAMELET_ACT then
    return false
  end
  return actData.back_int_value == ActivityBackUpIntType.Gamelet
end
function ActivityNewSystem.IsGameletActCanShow(actData)
  if not actData or not actData.ImgLink then
    return false
  end
  local url = actData.ImgLink
  local params = StringUtil.ParseURLParams(url)
  local appId = tonumber(params.appId)
  if not appId then
    return false
  end
  local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  if not logic_gamelet_interface:gamelet_enable() then
    log(bWriteLog and "ActivityNewSystem.IsGameletActReady. gamelet not enable")
    return false
  end
  return true
end
function ActivityNewSystem.IsGameletReadyByJumpUrl(url)
  if not url or url == "" then
    return false
  end
  local JumpUtils = require("client.logic.store.jump_utils")
  if not JumpUtils.IsGameJumpUrl(url) then
    return false
  end
  local params = StringUtil.ParseURLParams(url)
  local moduleId = tonumber(params.module)
  if not moduleId or moduleId ~= BP_ENUM_MODULE_HOSTED_GAMELET_ACT then
    return false
  end
  local appId = tonumber(params.appId)
  if not appId then
    return false
  end
  local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  local ready = logic_gamelet_interface:IsInterfaceReady(appId)
  log(bWriteLog and string.format("ActivityNewSystem.IsGameletReadyByJumpUrl. url=%s, ready=%s", tostring(url), tostring(ready)))
  return ready
end
function ActivityNewSystem.OpenHomePromotion()
  local logic_home_promotion_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_promotion_activity)
  local activity_data = logic_home_promotion_activity:GetActivityData()
  log_tree("logic_home_promotion_activity:OpenActivity activity_data =", activity_data)
  if not activity_data then
    ShowNotice(7809)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Elegant_Ancient_Capital_UIBP_New, activity_data, false, true)
end
function ActivityNewSystem.GetActIdByUrl(jumpUrl)
  local actID = 0
  if not jumpUrl or jumpUrl == "" then
    return actID
  end
  local JumpUtils = require("client.logic.store.jump_utils")
  if JumpUtils.IsPanDoraJumpUrl(jumpUrl) then
    log(bWriteLog and "ActivityNewSystem.GetActIdByUrl processing pandora jump url")
    local pandoraUtils = require("client.slua.logic.Pandora.pandora_utils")
    local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
    local PandoraID = pandoraUtils.GetActIdByUrl(jumpUrl)
    actID = pandoraSystem.pandora2Id[PandoraID]
    log(bWriteLog and string.format("ActivityNewSystem.GetActIdByUrl Pandora actID: %s", actID))
  elseif JumpUtils.IsGameJumpUrl(jumpUrl) then
    log(bWriteLog and "ActivityNewSystem.GetActIdByUrl processing game jump url")
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    jumpUrl = string.lower(jumpUrl)
    jumpUrl = webModule:URLDecode(jumpUrl)
    jumpUrl = GlobalData.PreprocessUrl(jumpUrl)
    local params = StringUtil.ParseURLParams(jumpUrl)
    actID = tonumber(params.id)
    log(bWriteLog and string.format("ActivityNewSystem.GetActIdByUrl game actID: %s", actID))
  end
  return actID
end
return ActivityNewSystem