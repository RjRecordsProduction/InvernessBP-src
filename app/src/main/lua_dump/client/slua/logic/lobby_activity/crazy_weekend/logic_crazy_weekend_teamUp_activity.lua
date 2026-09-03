local logic_crazy_weekend_teamUp_activity = {}
local actType = ActivityType
local CheckActUsedMap = {
  [actType.WORLDCUP_TEAMUP_DOUBLE_INTIMACY] = "OnDoubleIntimacyActive"
}
function logic_crazy_weekend_teamUp_activity:OnInitialize()
  logic_crazy_weekend_teamUp_activity.__super.OnInitialize(self)
  self:InitData()
end
function logic_crazy_weekend_teamUp_activity:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.OnActivityDataChanged, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, self.OnFaceSlapEnd, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayUpdate, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CRAZY_WEEKEND_GUILD, self.ShowPopUpGuildUI, self)
end
function logic_crazy_weekend_teamUp_activity:OnNextDayUpdate()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity OnNextDayUpdate")
  self:SetIsOpen()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity OnNextDayUpdate" .. tostring(self.FaceSlapEnd))
  if self.FaceSlapEnd then
    self:ShowPopUpGuildUI()
  end
end
function logic_crazy_weekend_teamUp_activity:OnActivityDataChanged(eventType, eventID, changeList)
  if not changeList or not changeList.idList then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity OnActivityDataChanged: changeList is nil")
    return
  end
  log_tree(bWriteLog and "logic_crazy_weekend_teamUp_activity OnActivityDataChanged: changeList", changeList)
  local hasChanged = false
  if self.ParentActID == 0 then
    hasChanged = true
  else
    if changeList.idList[self.ParentActID] then
      hasChanged = true
    end
    if not hasChanged then
      for Type, _ in pairs(self.ChildActDataList) do
        if changeList.typeList[Type] then
          hasChanged = changeList.typeList[Type]
          break
        end
      end
    end
  end
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity OnActivityDataChanged: hasChanged = " .. tostring(hasChanged))
  if hasChanged then
    self:UpdateActData()
    if self.FaceSlapEnd then
      self:ShowPopUpGuildUI()
    end
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity OnAllActChange realUpdate")
    EventSystem:postEvent(EVENTTYPE_CRAZYWEEKEND, EVENTID_CRAZYWEEKEND_ACT_UPDATE)
  end
end
function logic_crazy_weekend_teamUp_activity:SetIsOpen()
  self.HasOpened = self:CheckIsOpen()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity SetIsOpen HasOpened = " .. tostring(self.HasOpened))
end
function logic_crazy_weekend_teamUp_activity:OnDestroy()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity Destory")
end
function logic_crazy_weekend_teamUp_activity:InitData()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity InitData")
  self.hasShowedEntranceTips = false
  self.SegmentList = {
    [16] = actType.WORLDCUP_SCORE_PROTECT,
    [17] = actType.WORLDCUP_TEAMUP_ADD_RATING,
    [18] = actType.WORLDCUP_DOUBLE_CHALLENGE,
    [19] = actType.WORLDCUP_UPVOTE_DOUBLE_POPULARITY,
    [20] = actType.WORLDCUP_TEAMUP_DOUBLE_INTIMACY,
    [36] = actType.DOUBLE_EXP
  }
  self.FaceSlapEnd = false
  self.parentActivityType = 10
  self.ParentActID = 0
  self.ChildActDataList = {}
  self.weekDays = {}
  self.validActTypeList = {}
  self.OldProgressByType = {}
  self.rewardData = {}
  self:UpdateActData()
end
function logic_crazy_weekend_teamUp_activity:UpdateActData()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity InitActData")
  if self.ParentActID == 0 then
    self:InitParentActivityID()
  else
    self:UpdateChildActivityID()
  end
  self:SetIsOpen()
end
function logic_crazy_weekend_teamUp_activity:GetThemeActJumpLink()
  local logic_crazy_weekend_luckydraw = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_crazy_weekend_luckydraw)
  local curSeasonID = logic_crazy_weekend_luckydraw:getSeasonId()
  local jumpLink = ""
  if curSeasonID and 0 < curSeasonID then
    local curCfg = CDataTable.GetTableByFilter("CrazyWeekendThemeActConfig", "SeasonID", curSeasonID)
    if not curCfg then
      log(bWriteLog and "logic_crazy_weekend_teamUp_activity:GetThemeActJumpLink - curCfg is nil")
      return jumpLink
    end
    local TimeUtil = require("client.common.time_util")
    local currentTime = TimeUtil.GetServerTimeInSec()
    local latestStartTime = 0
    for _, itemCfg in pairs(curCfg) do
      local actStartTime = TimeUtil.TimeStringToUnixstamp(itemCfg.ActivityStartTime)
      local actEndTime = TimeUtil.TimeStringToUnixstamp(itemCfg.ActivityEndTime)
      local url = itemCfg.JumpLink
      log_format(bWriteLog and "GetThemeActJumpLink: currentTime :%s, actStartTime=%s, actEndTime=%s, url:%s", currentTime, actStartTime, actEndTime, url)
      if actStartTime and actEndTime and currentTime and currentTime >= actStartTime and currentTime <= actEndTime and latestStartTime < actStartTime then
        local checkPandoraReady = self:CheckPandoraLinkIsReady(url)
        if checkPandoraReady then
          latestStartTime = actStartTime
          jumpLink = url or ""
        end
        log(bWriteLog and string.format("logic_crazy_weekend_teamUp_activity:GetThemeActJumpLink - found jumpLink=%s", jumpLink))
      end
    end
  end
  return jumpLink
end
function logic_crazy_weekend_teamUp_activity:CheckPandoraLinkIsReady(url)
  log(bWriteLog and string.format("logic_crazy_weekend_teamUp_activity:CheckPandoraLinkIsReady - url=%s", tostring(url)))
  local JumpUtils = require("client.logic.store.jump_utils")
  if JumpUtils.IsPanDoraJumpUrl(url) then
    local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
    if not pandoraSystem.CheckSysOpen() then
      log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckPandoraLinkIsReady: pandoraSystem is not open")
      return false
    end
    local pandoraUtils = require("client.slua.logic.Pandora.pandora_utils")
    local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
    local PandoraID = pandoraUtils.GetActIdByUrl(url)
    local ActIsReady = pandoraLogic.ActIsReady(PandoraID)
    local PakIsReady = pandoraLogic.ActPakIsReady(PandoraID)
    log(bWriteLog and string.format("logic_crazy_weekend_teamUp_activity:CheckPandoraLinkIsReady - ActIsReady=%s, PakIsReady=%s", tostring(ActIsReady), tostring(PakIsReady)))
    return ActIsReady and PakIsReady
  else
    return true
  end
end
function logic_crazy_weekend_teamUp_activity:OnFaceSlapEnd()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity OnFaceSlapEnd")
  self.FaceSlapEnd = true
  self:ShowPopUpGuildUI()
end
function logic_crazy_weekend_teamUp_activity:InitParentActivityID()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:InitParentActivityID")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataList = ActivityNewSystem.GetActivityListByType(self.parentActivityType)
  if not activityDataList or not activityDataList[1] then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:InitParentActivityID activityDataList is nil")
    return
  end
  local activityData
  for _, actData in pairs(activityDataList) do
    local logic_crazy_weekend_config = require("client.slua.logic.lobby_activity.crazy_weekend.logic_crazy_weekend_config")
    if actData.TabType == logic_crazy_weekend_config.ActivityLabelType then
      self.ParentActID = actData.ID
      log_tree(bWriteLog and "logic_crazy_weekend_teamUp_activity:InitParentActivityID activityData", actData)
      activityData = actData
      break
    end
  end
  if not activityData then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:InitParentActivityID activityData is nil")
    return
  end
  self.weekDays = {}
  if activityData.weekly_open_days then
    for day, isOpen in pairs(activityData.weekly_open_days) do
      if isOpen then
        log(bWriteLog and "logic_crazy_weekend_teamUp_activity:InitParentActivityID, day:" .. tostring(day))
        table.insert(self.weekDays, day)
      end
    end
  end
  self:UpdateChildActivityID(activityData)
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:InitParentActivityID, ParentActID:" .. tostring(self.ParentActID))
end
function logic_crazy_weekend_teamUp_activity:GetValidTypeList()
  return self.validActTypeList or {}
end
function logic_crazy_weekend_teamUp_activity:GetValidActivityCount()
  self.validActTypeList = {}
  local sortHelper = {
    17,
    16,
    18,
    19,
    20,
    36
  }
  local activityCfgToTypeList = self:GetActivityCfgToTypeList()
  local firstValidActCfgId
  local count = 0
  for _, cfgId in pairs(sortHelper) do
    local activityType = activityCfgToTypeList[cfgId]
    if activityType then
      local totalNum, progressNum = self:GetProgressByType(activityType)
      if totalNum and progressNum then
        local bShow = progressNum < totalNum
        if bShow then
          count = count + 1
          local data = {
            protect_id = cfgId,
            totalNum = totalNum,
                      }
          table.insert(self.validActTypeList, data)
          firstValidActCfgId = firstValidActCfgId or cfgId
        end
      end
    end
  end
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:GetValidActivityCount count:" .. tostring(count) .. " firstValidActCfgId:" .. tostring(firstValidActCfgId))
  return count, firstValidActCfgId
end
function logic_crazy_weekend_teamUp_activity:CheckActUsed(newData)
  local Type = newData.Type
  local checkFunc = CheckActUsedMap[Type]
  if checkFunc then
    local oldProgress = self.OldProgressByType[Type]
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckActUsed Type:" .. tostring(Type) .. ", oldProgress:" .. tostring(oldProgress) .. ", NewProgress:" .. tostring(newData.Progress) .. ", Desc:" .. tostring(newData.Title))
    if oldProgress and oldProgress < newData.Progress then
      self[checkFunc](self, Type, newData)
    end
    self.OldProgressByType[Type] = newData.Progress or 0
  end
end
function logic_crazy_weekend_teamUp_activity:updateActData(newData)
  local Type = newData.Type
  if not self.ChildActDataList[Type] then
    self.ChildActDataList[Type] = {}
  end
  local foundIndex
  for i, data in ipairs(self.ChildActDataList[Type]) do
    if data.ID == newData.ID then
      foundIndex = i
      break
    end
  end
  if foundIndex then
    self.ChildActDataList[Type][foundIndex] = newData
  else
    table.insert(self.ChildActDataList[Type], newData)
  end
  if Type == actType.TOP_TENS then
    local logic_crazy_weekend_config = require("client.slua.logic.lobby_activity.crazy_weekend.logic_crazy_weekend_config")
    local Desc = newData.Desc
    if Desc and Desc == "TicketTask" then
      self.rewardData[logic_crazy_weekend_config.TeamUpFourLabelType] = newData
    else
      self.rewardData[logic_crazy_weekend_config.TeamUpTwiceLabelType] = newData
    end
  end
end
function logic_crazy_weekend_teamUp_activity:GetActAwardData()
  log_tree(bWriteLog and "logic_crazy_weekend_teamUp_activity:GetActAwardData", self.rewardData)
  return self.rewardData
end
function logic_crazy_weekend_teamUp_activity:hasAwardCanGet()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:hasAwardCanGet")
  for _, v in pairs(self.rewardData) do
    if v.Status == 1 then
      return true
    end
  end
  return false
end
function logic_crazy_weekend_teamUp_activity:CheckHasNoLimitForSegment()
  return self:IsOpen()
end
function logic_crazy_weekend_teamUp_activity:UpdateChildActivityID(activityData)
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:UpdateChildActivityID")
  if self.ParentActID == 0 then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:UpdateChildActivityID ParentActID is 0")
    return
  end
  if not activityData then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:UpdateChildActivityID activityData is nil")
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    activityData = ActivityNewSystem.GetActivityByID(self.ParentActID)
    if not activityData then
      return
    end
  end
  log_tree(bWriteLog and "logic_crazy_weekend_teamUp_activity:UpdateChildActivityID activityData:", activityData)
  for _, activity in pairs(activityData.List) do
    self:CheckActUsed(activity)
    self:updateActData(activity)
  end
  self:GetValidActivityCount()
end
function logic_crazy_weekend_teamUp_activity:GetActivityCfgToTypeList()
  return self.SegmentList
end
function logic_crazy_weekend_teamUp_activity:IsNewBieOrReturn()
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  if logic_newbie_assist.CheckIsNewBie() then
    return true
  else
    local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
    return logic_player_return.isPlayerReturnOpenNew()
  end
end
function logic_crazy_weekend_teamUp_activity:IsOpen()
  self:SetIsOpen()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:IsOpen = " .. tostring(self.HasOpened))
  return self.HasOpened
end
function logic_crazy_weekend_teamUp_activity:CheckIsOpen()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckIsOpen")
  if self.ParentActID == 0 then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckIsOpen no activity id")
    return false
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityByID(self.ParentActID)
  if not activityData then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckIsOpen no activity data")
    return false
  end
  local startTime = activityData.StartTime
  local endTime = activityData.EndTime
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec() or 0
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckIsOpen serverTime:" .. tostring(serverTime))
  if startTime == nil or endTime == nil or startTime > serverTime or endTime < serverTime then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity.CheckIsOpen activity not in open time")
    return false
  end
  if self.weekDays and 0 < #self.weekDays then
    local weekDay = TimeUtil.GetWeekDayByTime(serverTime, false)
    local table_util = require("common.table_util")
    local isOpenWeekDay = table_util.IsInTable(self.weekDays, weekDay)
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckIsOpen weekDay:" .. tostring(weekDay) .. " isOpenWeekDay:" .. tostring(isOpenWeekDay))
    return isOpenWeekDay
  end
  return true
end
function logic_crazy_weekend_teamUp_activity:GetEntryInfo()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:GetEntryInfo" .. tostring(self.HasOpened))
  return self:IsOpen()
end
function logic_crazy_weekend_teamUp_activity:GetProgressByType(activityType)
  if not activityType then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:GetProgressByType activityType is nil")
    return -1, -1, "", ""
  end
  if activityType == actType.TOP_TENS then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:GetProgressByType activityType is reward activity, can not get progress")
    return -1, -1, "", ""
  end
  local activityDataArray = self.ChildActDataList[activityType]
  if not activityDataArray or #activityDataArray == 0 then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:GetProgressByType no data found for type:" .. tostring(activityType))
    return -1, -1, "", ""
  end
  local activityData = activityDataArray[1]
  if not activityData then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:GetProgressByType activityData is nil for type:" .. tostring(activityType))
    return -1, -1, "", ""
  end
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:GetProgressByType Type:" .. tostring(activityType))
  return activityData.Total, activityData.Progress, activityData.Title, activityData.Desc
end
function logic_crazy_weekend_teamUp_activity:CheckValidActTypeInAct()
  log(bWriteLog and "logic_rating_protect_for_crazy_weekend.CheckValidActTypeInAct")
  if not self:IsOpen() then
    return false
  end
  self:GetValidActivityCount()
  if not self.validActTypeList or not next(self.validActTypeList) then
    return false
  end
  return true, self.validActTypeList
end
function logic_crazy_weekend_teamUp_activity:IsActScoreProtectFirst()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:IsActScoreProtectFirst")
  if not self:IsOpen() then
    return false
  end
  local totalNum, progressNum = self:GetProgressByType(actType.WORLDCUP_SCORE_PROTECT)
  progressNum = progressNum or 0
  if totalNum > progressNum then
    return true
  end
end
function logic_crazy_weekend_teamUp_activity:GoToActMainUI()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:GoToActMainUI")
  UIManager.ShowUI(UIManager.UI_Config.CrazyWeekend_HomePage_UIBP)
end
function logic_crazy_weekend_teamUp_activity:ShowPopUpGuildUI()
  local canShowGuildUI = self:CheckCanOpenGuildUI()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:ShowPopUpGuildUI canShowGuildUI = " .. tostring(canShowGuildUI))
  if canShowGuildUI then
    local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local TimeUtil = require("client.common.time_util")
    local CurTime = TimeUtil.GetServerTimeInSec()
    playerPrefsSystem.SaveTableToFile_N({OpenTime = CurTime}, playerPrefsSystem.ePlayerPrefsType.eCrazyWeekendGuild)
    UIManager.ShowUI(UIManager.UI_Config.CrazyWeekend_Popup_UIBP)
  end
end
function logic_crazy_weekend_teamUp_activity:CheckCanOpenGuildUI()
  local isOpen = self:IsOpen()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckCanOpenGuildUI isOpen:" .. tostring(isOpen))
  if not isOpen then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckCanOpenGuildUI not open")
    return false
  end
  local validCount = self:IsActScoreProtectFirst()
  if validCount == 0 then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckCanOpenGuildUI task completed")
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local activityData = ActivityNewSystem.GetActivityByID(self.ParentActID)
    if activityData and activityData.status == 2 then
      log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckCanOpenGuildUI reward received")
      return false
    end
  end
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local OpenRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eCrazyWeekendGuild)
  local TimeUtil = require("client.common.time_util")
  local CurTime = TimeUtil.GetServerTimeInSec()
  if OpenRecord == nil or OpenRecord.OpenTime == nil then
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckCanOpenGuildUI no record")
    return true
  else
    local lastTime = OpenRecord.OpenTime
    local hasOpen = TimeUtil.IsSameDay(lastTime, CurTime)
    log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckCanOpenGuildUI today has open : ", tostring(hasOpen))
    if hasOpen then
      return false
    else
      log(bWriteLog and "logic_crazy_weekend_teamUp_activity:CheckCanOpenGuildUI today not open", hasOpen)
      return true
    end
  end
end
function logic_crazy_weekend_teamUp_activity:OnDoubleIntimacyActive()
  log(bWriteLog and "logic_crazy_weekend_teamUp_activity:OnDoubleIntimacyActive")
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(3, function()
    UIManager.ShowUI(UIManager.UI_Config.CrazyWeekend_PopupItem_UIBP)
  end)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_crazy_weekend_teamUp_activity = class(CModuleBase, nil, logic_crazy_weekend_teamUp_activity)
return Clogic_crazy_weekend_teamUp_activity