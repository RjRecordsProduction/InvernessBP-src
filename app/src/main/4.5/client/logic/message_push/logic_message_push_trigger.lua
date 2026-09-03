local MessagePushTriggerSystem = {
  hasRecordData = false,
  RecordData = {},
  testFlag = false
}
ENUM_TRIGGER_COND = {
  NONE = 0,
  FIRST_CHARGE = 1,
  FIRST_GET_MYTHIC_FASHION = 2,
  FIRST_CHICKEN = 3
}
local WEIGHT_TRIGGER_COND = {
  [1] = {
    Cond = ENUM_TRIGGER_COND.FIRST_CHARGE,
    Weight = 1
  },
  [2] = {
    Cond = ENUM_TRIGGER_COND.FIRST_GET_MYTHIC_FASHION,
    Weight = 2
  },
  [3] = {
    Cond = ENUM_TRIGGER_COND.FIRST_CHICKEN,
    Weight = 3
  }
}
table.sort(WEIGHT_TRIGGER_COND, function(a, b)
  if a.weight ~= b.weight then
    return a.weight > b.weight
  else
    return false
  end
end)
local TRIGGER_COND_CONFIG = {
  [ENUM_TRIGGER_COND.FIRST_CHARGE] = {
    Title = 5077,
    Content = 13219,
    BtnOK = 13222,
    BtnCancel = 13223
  },
  [ENUM_TRIGGER_COND.FIRST_GET_MYTHIC_FASHION] = {
    Title = 5077,
    Content = 13220,
    BtnOK = 13222,
    BtnCancel = 13224
  },
  [ENUM_TRIGGER_COND.FIRST_CHICKEN] = {
    Title = 5077,
    Content = 13221,
    BtnOK = 13222,
    BtnCancel = 13225
  }
}
local ENUM_SELECT_STATE = {
  NO_SELECT = 0,
  OK = 1,
  CANCEL = 2
}
local INDEX_TRIGGER_UTC = "trigger_utc"
local INDEX_TRIGGER_TRIGGERED_STATE = "is_triggered"
function MessagePushTriggerSystem.Init()
  log(bWriteLog and "steve MessagePushTriggerSystem.Init")
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, MessagePushTriggerSystem.OnModePostSwitch)
  EventSystem:registEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, MessagePushTriggerSystem.OnAllWidgetHide)
  EventSystem:registEvent(EVENTTYPE_MESSAGE_PUSH_TRIGGER, EVENTID_MESSAGE_PUSH_TRIGGER_RECEIVE_RECORD_DATA, MessagePushTriggerSystem.OnReceiveRecordData)
  EventSystem:registEvent(EVENTTYPE_MESSAGE_PUSH_TRIGGER, EVENTID_MESSAGE_PUSH_TRIGGER_RECORD_DATA, MessagePushTriggerSystem.TryRecordData)
end
function MessagePushTriggerSystem.OnLogin()
  log(bWriteLog and "steve MessagePushTriggerSystem.OnLogin")
  MessagePushTriggerSystem.ClearRecordData()
  MessagePushTriggerSystem.GetRecordData()
end
function MessagePushTriggerSystem.GetRecordData()
  log(bWriteLog and "steve MessagePushTriggerSystem.GetRecordData")
  local handler = require("client.network.Protocol.MessagePushTriggerHandler")
  handler.send_get_push_msg_pop_up_confirm_req()
end
function MessagePushTriggerSystem.OnReceiveRecordData(_, _, errcode, recordData)
  if errcode ~= 0 then
    log(bWriteLog and "steve MessagePushTriggerSystem.OnReceiveRecordData errcode = " .. tostring(errcode))
  end
  log_tree("steve MessagePushTriggerSystem.OnReceiveRecordData", recordData)
  recordData = recordData or {}
  MessagePushTriggerSystem.RecordData = recordData
  if MessagePushTriggerSystem.testFlag then
    MessagePushTriggerSystem.testFlag = false
    MessagePushTriggerSystem.MessagePushTriggerSystemTestData()
  end
  MessagePushTriggerSystem.hasRecordData = true
end
function MessagePushTriggerSystem.TryRecordData(_, _, trigger_cond, ...)
  log(bWriteLog and "steve MessagePushTriggerSystem.TryRecordData trigger_cond = " .. tostring(trigger_cond))
  if MessagePushTriggerSystem.HasSelected(trigger_cond) then
    log(bWriteLog and "steve MessagePushTriggerSystem:TryRecordData HasTriggered!")
    return
  end
  if trigger_cond == ENUM_TRIGGER_COND.FIRST_CHARGE then
    log(bWriteLog and "steve MessagePushTriggerSystem.TryRecordData trigger_cond = FIRST_CHARGE")
    MessagePushTriggerSystem.RecordDataInternal(trigger_cond)
  elseif trigger_cond == ENUM_TRIGGER_COND.FIRST_GET_MYTHIC_FASHION then
    local addList = select(1, ...) or {}
    log_tree("steve MessagePushTriggerSystem.TryRecordData trigger_cond = FIRST_GET_MYTHIC_FASHION", addList)
    for _, v in pairs(addList) do
      if v.itemQuality and v.itemQuality >= 7 then
        MessagePushTriggerSystem.RecordDataInternal(trigger_cond)
        break
      end
    end
  elseif trigger_cond == ENUM_TRIGGER_COND.FIRST_CHICKEN then
    MessagePushTriggerSystem.RecordDataInternal(trigger_cond)
  end
end
function MessagePushTriggerSystem.RecordDataInternal(trigger_cond)
  log(bWriteLog and "steve MessagePushTriggerSystem.RecordDataInternal")
  if MessagePushTriggerSystem.RecordData[trigger_cond] == nil then
    MessagePushTriggerSystem.RecordData[trigger_cond] = {
      [INDEX_TRIGGER_TRIGGERED_STATE] = ENUM_SELECT_STATE.NO_SELECT
    }
  elseif MessagePushTriggerSystem.RecordData[trigger_cond][INDEX_TRIGGER_TRIGGERED_STATE] == nil then
    log(bWriteLog and "steve MessagePushTriggerSystem.RecordDataInternal MessagePushTriggerSystem.RecordData[trigger_cond][INDEX_TRIGGER_TRIGGERED_STATE] == nil")
    MessagePushTriggerSystem.RecordData[trigger_cond][INDEX_TRIGGER_TRIGGERED_STATE] = ENUM_SELECT_STATE.NO_SELECT
  end
  if MessagePushTriggerSystem.RecordData[trigger_cond][INDEX_TRIGGER_TRIGGERED_STATE] == ENUM_SELECT_STATE.NO_SELECT then
    local TimeUtil = require("client.common.time_util")
    MessagePushTriggerSystem.RecordData[trigger_cond][INDEX_TRIGGER_UTC] = TimeUtil.GetServerTimeInSec()
  end
end
function MessagePushTriggerSystem.ClearRecordData()
  log(bWriteLog and "steve MessagePushTriggerSystem.ClearRecordData")
  MessagePushTriggerSystem.hasRecordData = false
  MessagePushTriggerSystem.RecordData = {}
end
function MessagePushTriggerSystem.SetRecordData(triggerCond, isClickOK)
  log(bWriteLog and "steve MessagePushTriggerSystem.SetRecordData")
  if MessagePushTriggerSystem.RecordData[triggerCond] == nil then
    MessagePushTriggerSystem.RecordData[triggerCond] = {}
  end
  local handler = require("client.network.Protocol.MessagePushTriggerHandler")
  if isClickOK then
    local TimeUtil = require("client.common.time_util")
    MessagePushTriggerSystem.RecordData[triggerCond][INDEX_TRIGGER_UTC] = TimeUtil.GetServerTimeInSec()
    MessagePushTriggerSystem.RecordData[triggerCond][INDEX_TRIGGER_TRIGGERED_STATE] = ENUM_SELECT_STATE.OK
    handler.send_set_push_msg_pop_up_confirm_req(triggerCond, ENUM_SELECT_STATE.OK)
    log(bWriteLog and "handler.send_set_push_msg_pop_up_confirm_req OK triggerCond = " .. tostring(triggerCond) .. ", confirm = " .. tostring(ENUM_SELECT_STATE.OK))
    MessagePushTriggerSystem.GetRecordData()
  else
    local TimeUtil = require("client.common.time_util")
    MessagePushTriggerSystem.RecordData[triggerCond][INDEX_TRIGGER_UTC] = TimeUtil.GetServerTimeInSec()
    MessagePushTriggerSystem.RecordData[triggerCond][INDEX_TRIGGER_TRIGGERED_STATE] = ENUM_SELECT_STATE.CANCEL
    handler.send_set_push_msg_pop_up_confirm_req(triggerCond, ENUM_SELECT_STATE.CANCEL)
    log(bWriteLog and "handler.send_set_push_msg_pop_up_confirm_req CANCEL triggerCond = " .. tostring(triggerCond) .. ", confirm = " .. tostring(ENUM_SELECT_STATE.OK))
    MessagePushTriggerSystem.GetRecordData()
  end
end
function MessagePushTriggerSystem.OnModePostSwitch(_, _, statusData)
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:registEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, MessagePushTriggerSystem.OnAllWidgetHide)
  else
    EventSystem:unregistEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, MessagePushTriggerSystem.OnAllWidgetHide)
  end
  MessagePushTriggerSystem.TryToShowTipsWnd("ModeSwitch")
end
function MessagePushTriggerSystem.OnAllWidgetHide(_, _)
  MessagePushTriggerSystem.TryToShowTipsWnd("AllWidgetHide")
end
function MessagePushTriggerSystem.TryToShowTipsWnd(sceneType)
  log(bWriteLog and "steve MessagePushTriggerSystem.TryToShowTipsWnd sceneType = " .. tostring(sceneType))
  local time_ticker = require("common.time_ticker")
  if MessagePushTriggerSystem.DelayTimer ~= nil then
    time_ticker.RemoveTimer(MessagePushTriggerSystem.DelayTimer)
    MessagePushTriggerSystem.DelayTimer = nil
  end
  MessagePushTriggerSystem.DelayTimer = time_ticker.AddTimerOnce(0.1, function()
    if not GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and "steve MessagePushTriggerSystem.TryToShowTipsWnd delay return not in lobby")
      return
    end
    local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
    if NewFaceSlapSystem:IsInSlap() then
      log(bWriteLog and "steve MessagePushTriggerSystem.TryToShowTipsWnd delay return IsInSlap")
      return
    end
    if not UIManager.IsAndroidStackEmpty() then
      log(bWriteLog and "steve MessagePushTriggerSystem.TryToShowTipsWnd delay return IsAndroidStackEmpty")
      return
    end
    if MessagePushTriggerSystem.hasRecordData then
      MessagePushTriggerSystem.CheckToShowTipsWnd()
    end
  end)
end
function MessagePushTriggerSystem.CheckToShowTipsWnd()
  log(bWriteLog and "steve MessagePushTriggerSystem.CheckToShowTipsWnd")
  local triggerCond = MessagePushTriggerSystem.IsNeedToShow()
  if triggerCond ~= ENUM_TRIGGER_COND.NONE then
    MessagePushTriggerSystem.ShowTipsWnd(triggerCond)
  end
end
function MessagePushTriggerSystem.ShowTipsWnd(triggerCond)
  log(bWriteLog and "steve MessagePushTriggerSystem.ShowTipsWnd")
  local cfg = TRIGGER_COND_CONFIG[triggerCond]
  if cfg == nil or cfg.Title == nil or cfg.Content == nil or cfg.BtnOK == nil or cfg.BtnCancel == nil then
    log(bWriteLog and "steve MessagePushTriggerSystem.ShowTipsWnd cfg = nil, triggerCond = " .. tostring(triggerCond))
    return
  end
  local title = LocUtil.GetLocalizeResStr(cfg.Title)
  local content = LocUtil.GetLocalizeResStr(cfg.Content)
  local btnOK = LocUtil.GetLocalizeResStr(cfg.BtnOK)
  local btnCancel = LocUtil.GetLocalizeResStr(cfg.BtnCancel)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, content, function()
    MessagePushTriggerSystem.OnClickOK(triggerCond)
  end, function()
    MessagePushTriggerSystem.OnClickCancel(triggerCond)
  end, btnOK, btnCancel, {
    androidCallback = function()
      MessagePushTriggerSystem.OnAndroidBack(triggerCond)
    end
  })
end
function MessagePushTriggerSystem.OnClickOK(triggerCond)
  log(bWriteLog and "steve MessagePushTriggerSystem.OnClickOK Start")
  local IntlHelper = import("IntlHelper")
  IntlHelper.DirectToNotificationSetup()
  MessagePushTriggerSystem.SetRecordData(triggerCond, true)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.MessagePushTriggerOK, triggerCond)
  log(bWriteLog and "steve MessagePushTriggerSystem.OnClickOK END")
end
function MessagePushTriggerSystem.OnClickCancel(triggerCond)
  log(bWriteLog and "steve MessagePushTriggerSystem.OnClickCancel Start")
  MessagePushTriggerSystem.SetRecordData(triggerCond, false)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.MessagePushTriggerCancel, triggerCond)
  log(bWriteLog and "steve MessagePushTriggerSystem.OnClickCancel End")
end
function MessagePushTriggerSystem.OnAndroidBack(triggerCond)
  MessagePushTriggerSystem.OnClickCancel(triggerCond)
  log(bWriteLog and "hza MessagePushTriggerSystem.OnAndroidBack, trigger cond is: ", triggerCond)
end
function MessagePushTriggerSystem.IsNeedToShow()
  log(bWriteLog and "steve MessagePushTriggerSystem.IsNeedToShow 1")
  local IntlHelper = import("IntlHelper")
  local isEnabled = IntlHelper.IsRemoteNotificationsEnabled()
  log(bWriteLog and "MessagePushTriggerSystem.IsNeedToShow Enabled = " .. tostring(isEnabled))
  if IsEditor or not isEnabled then
    log_tree("steve MessagePushTriggerSystem.IsNeedToShow 2", MessagePushTriggerSystem.RecordData)
    for _, weightData in pairs(WEIGHT_TRIGGER_COND) do
      local recordData = MessagePushTriggerSystem.RecordData[weightData.Cond]
      if recordData and MessagePushTriggerSystem.HasSelected(weightData.Cond) and MessagePushTriggerSystem.IsToday(recordData[INDEX_TRIGGER_UTC]) then
        return ENUM_TRIGGER_COND.NONE
      end
    end
    for _, weightData in pairs(WEIGHT_TRIGGER_COND) do
      local recordData = MessagePushTriggerSystem.RecordData[weightData.Cond]
      if recordData and not MessagePushTriggerSystem.HasSelected(weightData.Cond) and MessagePushTriggerSystem.IsToday(recordData[INDEX_TRIGGER_UTC]) then
        return weightData.Cond
      end
    end
  end
  return ENUM_TRIGGER_COND.NONE
end
function MessagePushTriggerSystem.HasSelected(trigger_cond)
  log(bWriteLog and "steve MessagePushTriggerSystem.HasSelected")
  local recordData = MessagePushTriggerSystem.RecordData[trigger_cond]
  if recordData and recordData[INDEX_TRIGGER_TRIGGERED_STATE] and recordData[INDEX_TRIGGER_TRIGGERED_STATE] ~= ENUM_SELECT_STATE.NO_SELECT then
    return true
  end
  return false
end
function MessagePushTriggerSystem.IsToday(utc)
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "steve MessagePushTriggerSystem.IsToday")
  local now = TimeUtil.GetServerTimeInSec()
  return TimeUtil.IsSameDay(utc, now)
end
function MessagePushTriggerSystem.MessagePushTriggerSystemTestData()
  local TimeUtil = require("client.common.time_util")
  MessagePushTriggerSystem.RecordData = {
    [ENUM_TRIGGER_COND.FIRST_GET_MYTHIC_FASHION] = {
      trigger_utc = TimeUtil.GetServerTimeInSec(),
      is_triggered = ENUM_SELECT_STATE.NO_SELECT
    }
  }
end
function MessagePushTriggerSystem.GetRecordDataTable2String()
  return Table2String(MessagePushTriggerSystem.RecordData)
end
return MessagePushTriggerSystem