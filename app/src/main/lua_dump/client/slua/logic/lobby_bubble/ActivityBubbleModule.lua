local LobbyBubbleConfig = require("client.slua.logic.lobby_bubble.LobbyBubbleConfig")
local JumpUtils = require("client.logic.store.jump_utils")
local ENUM_CONDITION_TYPE = LobbyBubbleConfig.ENUM_CONDITION_TYPE
local Enum_Open_Status = LobbyBubbleConfig.Enum_Open_Status
local ActivityBubbleModule = {}
function ActivityBubbleModule:DefineAndResetData()
  self.bubble_data = nil
  self.timeInterval = 2
end
function ActivityBubbleModule:_IsDailyTips(bubble_data)
  local id = bubble_data.id
  local con_list = bubble_data.con_list
  if con_list then
    for _, condition in pairs(con_list) do
      local conType = condition.ConType
      if conType == ENUM_CONDITION_TYPE.Daily then
        local conValue = condition.Con1
        if conValue == Enum_Open_Status.Open then
          return true
        end
      end
    end
  end
  return false
end
function ActivityBubbleModule:_GetTipsShowTime(id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eActivityBubble) or {}
  return Data[id]
end
function ActivityBubbleModule:_GetTipsShowToday(id)
  local time = self:_GetTipsShowTime(id)
  if not time then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  return TimeUtil.IsSameDay(time, currentTime)
end
function ActivityBubbleModule:_GetDurationTime()
  return self.bubble_data and self.bubble_data.duration or 0
end
function ActivityBubbleModule:_GetTipsShow(bubleData)
  if not self:_IsDailyTips(bubleData) then
    log(bWriteLog and "ActivityBubbleModule _GetTipsShow always")
    return false
  end
  local id = bubleData.id
  if bWriteLog then
    if self:_IsShowOnce() then
      log(bWriteLog and "ActivityBubbleModule _GetTipsShow _IsOncePerDay" .. tostring(self:_GetTipsShowTime(id)))
    else
      log(bWriteLog and "ActivityBubbleModule _GetTipsShow _IsSomeTimePerDay" .. tostring(self:_GetTipsShowTime(id)))
    end
  end
  return self:_GetTipsShowToday(id)
end
function ActivityBubbleModule:_IsInDuration(bubble_data, startTime)
  if bubble_data then
    local id = bubble_data.id
    if bubble_data then
      startTime = startTime or 0
      local duration = self:_GetDurationTime()
      local TimeUtil = require("client.common.time_util")
      local currentTime = TimeUtil.GetServerTimeInSec() or 0
      log(bWriteLog and "ActivityBubbleModule _IsInDuration" .. tostring(duration + startTime - currentTime))
      return startTime <= currentTime and currentTime <= startTime + duration
    end
  end
  return false
end
function ActivityBubbleModule:_IsInTime(bubble_data)
  if bubble_data then
    local startTime = bubble_data.start_time
    local endTime = bubble_data.end_time
    local TimeUtil = require("client.common.time_util")
    local currentTime = TimeUtil.GetServerTimeInSec()
    return startTime <= currentTime and endTime >= currentTime
  end
  return false
end
function ActivityBubbleModule:_SameBubble(bubble_data)
  local newId = bubble_data.id
  if self.bubble_data then
    local currentId = self.bubble_data.id
    if currentId == newId then
      return true
    end
  end
  return false
end
function ActivityBubbleModule:_CheckBubbleValid(bubble_data)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie(true) then
    log(bWriteLog and "ActivityBubbleModule IsNewbie")
    return
  end
  if self:_GetTipsShow(bubble_data) then
    log(bWriteLog and "ActivityBubbleModule _GetTipsShow")
    return
  end
  if not self:_IsInTime(bubble_data) then
    log(bWriteLog and "ActivityBubbleModule not _IsInTime")
    return
  end
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local midBannerUI
  if lobbyMain then
    midBannerUI = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Activity_UIBP)
  end
  local parentUIShow = midBannerUI and midBannerUI:IsShow()
  if not parentUIShow then
    log(bWriteLog and "ActivityBubbleModule not parentUIShow")
    return
  end
  return true
end
function ActivityBubbleModule:_IsShowOnce(bubble_data)
  if bubble_data then
    local duration = self:_GetDurationTime()
    return duration == 0
  end
end
function ActivityBubbleModule:_RuntimeCheck(startTime)
  local bubbleModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityBubbleModule)
  if not bubbleModule:_IsInTime(bubbleModule.bubble_data) then
    bubbleModule:SetTipsShow()
    bubbleModule:_SetBubbleStatus(false)
    return
  end
  if not bubbleModule:_IsInDuration(bubbleModule.bubble_data, startTime) then
    bubbleModule:SetTipsShow()
    bubbleModule:_SetBubbleStatus(false)
    return
  end
end
function ActivityBubbleModule:_OnNextDayZeroCome()
  log(bWriteLog and "ActivityBubbleModule _OnNextDayZeroCome" .. tostring(self.bubble_data and self.bubble_data.id))
  if self.bubble_data then
    if self:_IsDailyTips(self.bubble_data) then
      self:_SetBubbleStatus(true)
    end
  else
    self:_SetBubbleStatus(false)
  end
end
function ActivityBubbleModule:_GetActivityID()
  local jumpUrl = self:GetJumpUrl()
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(jumpUrl)
  local activityid = tonumber(params.activityid)
  return activityid
end
function ActivityBubbleModule:_GetLinkActType()
  return ActivityType.ACTIVITY_TYPE_LINK
end
function ActivityBubbleModule:_GetLinkTabType()
  return LobbyBubbleConfig.E_ImportantActTab
end
function ActivityBubbleModule:_GetActivityData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local id = self:_GetActivityID()
  local url = self:GetJumpUrl()
  if JumpUtils.IsGameJumpUrl(url) then
    if id then
      local activity = ActivityNewSystem.GetActivityByID(id)
      return activity
    end
  elseif JumpUtils.IsPanDoraJumpUrl(url) then
    return nil
  elseif JumpUtils.IsHttpOrHttpsJumpUrl(url) then
    return nil
  end
end
function ActivityBubbleModule:_SetBubbleStatus(status)
  local LobbyBubbleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyBubbleManager)
  local Enum_Bubble_Queue_Type = LobbyBubbleManager:GetBubbleQueueType()
  local Enum_Bubble_Type = LobbyBubbleManager:GetBubbleType(Enum_Bubble_Queue_Type.Middle)
  if status then
    LobbyBubbleManager:TryShowBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.Activity)
  else
    LobbyBubbleManager:HideBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.Activity)
  end
end
function ActivityBubbleModule:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self._OnNextDayZeroCome, self)
end
function ActivityBubbleModule:OnLogOut()
  self.bubble_data = nil
  log(bWriteLog and "ActivityBubbleModule OnLogOut")
end
function ActivityBubbleModule:GetJumpUrl()
  if self.bubble_data then
    return self.bubble_data.jump
  end
end
function ActivityBubbleModule:GetCDNUrl()
  if self.bubble_data then
    return self.bubble_data.cdn
  end
end
function ActivityBubbleModule:HasActivityData()
  local _activityData = self:_GetActivityData()
  return _activityData ~= nil
end
function ActivityBubbleModule:GetActivityStartTime()
  local _activityData = self:_GetActivityData()
  return _activityData.StartTime
end
function ActivityBubbleModule:GetActivityEndTime()
  local _activityData = self:_GetActivityData()
  return _activityData.EndTime
end
function ActivityBubbleModule:GetIsGoExchange()
  local _activityData = self:_GetActivityData()
  return _activityData.cond_2
end
function ActivityBubbleModule:CheckBubbleValid()
  if not self.bubble_data then
    log(bWriteLog and "ActivityBubbleModule CheckBubbleValid no bubble_data")
    return false
  end
  return self:_CheckBubbleValid(self.bubble_data)
end
function ActivityBubbleModule:CheckTipsShow(uiinstance)
  if not self:_IsDailyTips(self.bubble_data) then
    log(bWriteLog and "ActivityBubbleModule always")
    return
  end
  if self:_IsShowOnce(self.bubble_data) then
    self:SetTipsShow()
    log(bWriteLog and "ActivityBubbleModule _IsShowOncePerDay")
    return
  end
  log(bWriteLog and "ActivityBubbleModule _IsSomeimePerDay")
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "ActivityBubbleModule start runtime check")
  uiinstance:AddTimerLoop(0, function()
    self:_RuntimeCheck(currentTime)
  end, TIMER_INFINITE, self.timeInterval)
end
function ActivityBubbleModule:SetTipsShow(hasShow)
  if not self.bubble_data then
    log_error("ActivityBubbleModule SetTipsShow bubbleData = nil")
    return
  end
  local id = self.bubble_data.id
  local TimeUtil = require("client.common.time_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eActivityBubble) or {}
  if hasShow == false then
    Data[id] = nil
  else
    Data[id] = TimeUtil.GetServerTimeInSec()
  end
  PlayerPrefsSystem.SaveTableToFile_N(Data, PlayerPrefsSystem.ePlayerPrefsType.eActivityBubble)
  log(bWriteLog and "ActivityBubbleModule SetTipsShow" .. tostring(id) .. tostring(Data[id]))
end
function ActivityBubbleModule:ResetShowTips()
  log(bWriteLog and "ActivityBubbleModule ResetShowTips")
  self:SetTipsShow(false)
end
function ActivityBubbleModule:IsOpenCountDown()
  local con_list = self.bubble_data.con_list
  if con_list then
    for _, condition in pairs(con_list) do
      local conType = condition.ConType
      if conType == ENUM_CONDITION_TYPE.CountDown then
        local conValue = condition.Con1
        if conValue == Enum_Open_Status.Open then
          return true
        end
      end
    end
  end
  return false
end
function ActivityBubbleModule:IsInTime()
  return self:_IsInTime(self.bubble_data)
end
function ActivityBubbleModule:HandleBubbleData(bubbleData)
  log(bWriteLog and "ActivityBubbleModule HandleBubbleData" .. tostring(bubbleData and bubbleData.id))
  if not bubbleData then
    log(bWriteLog and "ActivityBubbleModule HandleBubbleData bubbleData = nil")
    self:_SetBubbleStatus(false)
    return
  end
  if self:_SameBubble(bubbleData) then
    log(bWriteLog and "ActivityBubbleModule HandleBubbleData same bubble" .. tostring(bubbleData.id))
    return
  end
  self.bubble_data = bubbleData
  log(bWriteLog and "ActivityBubbleModule HandleBubbleData ready to show")
  self:_SetBubbleStatus(true)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CActivityBubbleModule = class(CModuleBase, nil, ActivityBubbleModule)
return CActivityBubbleModule