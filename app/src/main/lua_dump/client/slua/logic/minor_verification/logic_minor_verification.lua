local MinorVerificationSystem = {
  IsTestMinorVerification = false,
  IsOnlyChangePhone = false,
  IsChangeFlag = false,
  CanShowTabInSetting = false,
  MinorFlag = 0,
  PhoneNum = "",
  IsVerified = true,
  UpdatePhoneTimestamp = 0,
  UpdateMinorFlagTimestamp = 0,
  GetCodeTimestamp = 0,
  NextStepFunc = nil,
  CONST = {
    MINOR_FLAG_INIT = 0,
    MINOR_FLAG_MINOR = 1,
    MINOR_FLAG_ADULT = 2,
    UPDATE_PHONE_NUM_LIMIT_DAYS = 90,
    UPDATE_MINOR_FLAG_LIMIT_DAYS = 30,
    SECONDS_PER_DAY = 86400,
    ERR_SUCCESS = 0,
    ERR_PARAM_ERR = 100000001,
    ERR_APPROVE_TIME_CD = 108200001,
    ERR_CODE_ERR = 108200002,
    ERR_FREQUENTLY = 108200003,
    ERR_DAY_LIMIT = 108200004,
    ERR_PHONE_ERR = 108200005,
    INDIA_PHONE_NUM_PREFIX = "91",
    VERIFY_CODE_CD = 30,
    GET_CODE_CD = 300,
    STATUS_NONE = 0,
    STATUS_REMIND_REST = 1,
    STATUS_QUIT_GAME = 2,
    MINOR_MSG_CONFIG = {REMIND_REST_MINUTES = 120, QUIT_GAME_MINUTES = 180},
    ADULT_VERIFIED_MSG_CONFIG = {REMIND_REST_MINUTES = 120, QUIT_GAME_MINUTES = 360},
    ADULT_NOT_VERIFIED_MSG_CONFIG = {REMIND_REST_MINUTES = 120, QUIT_GAME_MINUTES = 360},
    POPUP_TITLE_ID = 19302,
    QUIT_GAME_BUTTON_TEXT_ID = 4486,
    REMIND_RET_CONTENT_ID = 44548,
    QUIT_GAME_CONTENT_ID = 44549
  }
}
function MinorVerificationSystem.Init(MinorVerificationInfo, IsTestMinorVerification)
  if not MinorVerificationInfo then
    log(bWriteLog and "MinorVerificationSystem.Init MinorVerificationInfo is nil!")
    return
  end
  log_tree("MinorVerificationSystem.Init ", MinorVerificationInfo)
  MinorVerificationSystem.  MinorVerificationSystem.MinorFlag = MinorVerificationInfo.flag
  MinorVerificationSystem.PhoneNum = MinorVerificationInfo.phone_num
  MinorVerificationSystem.IsVerified = MinorVerificationInfo.is_verified
  MinorVerificationSystem.UpdatePhoneTimestamp = MinorVerificationInfo.update_phone_ts
  MinorVerificationSystem.UpdateMinorFlagTimestamp = MinorVerificationInfo.flag_update_ts
end
function MinorVerificationSystem.BeginVerificationFlow(NextStepFunc)
  MinorVerificationSystem.  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "MinorVerificationSystem.BeginVerificationFlow not in lobby!")
    MinorVerificationSystem.GoToNextStep()
    return
  end
  if not MinorVerificationSystem.IsEnableMinorVerification() then
    MinorVerificationSystem.CanShowTabInSetting = false
    MinorVerificationSystem.EndVerificationFlow()
    return
  end
  MinorVerificationSystem.CanShowTabInSetting = true
  if not MinorVerificationSystem.MinorFlag or MinorVerificationSystem.MinorFlag == MinorVerificationSystem.CONST.MINOR_FLAG_INIT or not MinorVerificationSystem.IsVerified then
    MinorVerificationSystem.OpenConfirmMinorWin()
  else
    MinorVerificationSystem.EndVerificationFlow()
  end
end
function MinorVerificationSystem.GoToNextStep()
  if MinorVerificationSystem.NextStepFunc then
    MinorVerificationSystem.NextStepFunc()
    MinorVerificationSystem.NextStepFunc = nil
  end
end
function MinorVerificationSystem.EndVerificationFlow()
  if MinorVerificationSystem.NextStepFunc then
    MinorVerificationSystem.NextStepFunc()
    MinorVerificationSystem.NextStepFunc = nil
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_COMPLIANCE_END)
  end
end
function MinorVerificationSystem.IsEnableMinorVerification()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE and LobbySystem.CheckOpen(BP_ENUM_MINOR_VERIFICATION) then
    return true
  end
  return false
end
function MinorVerificationSystem.IsVerificationFinished()
  if MinorVerificationSystem.IsEnableMinorVerification() then
    return MinorVerificationSystem.IsVerified
  end
  return true
end
function MinorVerificationSystem.OpenConfirmMinorWin()
  log(bWriteLog and "MinorVerificationSystem.OpenConfirmMinorWin " .. tostring(MinorVerificationSystem.UpdateMinorFlagTimestamp))
  local TimeUtil = require("client.common.time_util")
  if MinorVerificationSystem.UpdateMinorFlagTimestamp == nil or MinorVerificationSystem.UpdateMinorFlagTimestamp == 0 or TimeUtil.GetServerTimeInSec() - MinorVerificationSystem.UpdateMinorFlagTimestamp < 31536000 then
    local Title = LocUtil.GetLocalizeResStr(19302)
    local Content = LocUtil.GetLocalizeResStr(19293)
    local YesText = LocUtil.GetLocalizeResStr(4110)
    local NoText = LocUtil.GetLocalizeResStr(4115)
    local ExtraTable = {
      androidCallback = function()
        return true
      end
    }
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, Title, Content, function()
      MinorVerificationSystem.send_set_minor_flag(MinorVerificationSystem.CONST.MINOR_FLAG_ADULT)
    end, MinorVerificationSystem.OpenSecondConfirmMinorWin, YesText, NoText, ExtraTable)
  else
    local Title = LocUtil.GetLocalizeResStr(19302)
    local Content = LocUtil.GetLocalizeResStr(119335)
    local YesText = LocUtil.GetLocalizeResStr(4110)
    local ExtraTable = {
      androidCallback = function()
        return true
      end
    }
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, Title, Content, function()
      MinorVerificationSystem.OpenSetPhoneNumWin(false, false)
    end, MinorVerificationSystem.OpenConfirmMinorWin, YesText, nil, ExtraTable)
  end
end
function MinorVerificationSystem.OpenSecondConfirmMinorWin()
  local Title = LocUtil.GetLocalizeResStr(19302)
  local Content = LocUtil.GetLocalizeResStr(19326)
  local YesText = LocUtil.GetLocalizeResStr(110036)
  local NoText = LocUtil.GetLocalizeResStr(110035)
  local ExtraTable = {
    androidCallback = function()
      return true
    end
  }
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, Title, Content, function()
    MinorVerificationSystem.send_set_minor_flag(MinorVerificationSystem.CONST.MINOR_FLAG_MINOR)
  end, MinorVerificationSystem.OpenConfirmMinorWin, YesText, NoText, ExtraTable)
end
function MinorVerificationSystem.OpenSetPhoneNumWin(bFromChangePhone, bFromChangeFlag)
  MinorVerificationSystem.IsOnlyChangePhone = bFromChangePhone
  MinorVerificationSystem.IsChangeFlag = bFromChangeFlag
  UIManager.ShowUI(UIManager.UI_Config.minor_verification_phone)
end
function MinorVerificationSystem.CloseSetPhoneNumWin()
  UIManager.CloseUI(UIManager.UI_Config.minor_verification_phone)
  if not MinorVerificationSystem.IsOnlyChangePhone and not MinorVerificationSystem.IsChangeFlag then
    MinorVerificationSystem.OpenConfirmMinorWin()
  end
end
function MinorVerificationSystem.OpenVerificationCodeWin(bFromChangeFlag)
  MinorVerificationSystem.IsChangeFlag = bFromChangeFlag
  UIManager.ShowUI(UIManager.UI_Config.minor_verification_code)
end
function MinorVerificationSystem.CancelVerificationCode()
  UIManager.CloseUI(UIManager.UI_Config.minor_verification_code)
  if not MinorVerificationSystem.IsChangeFlag then
    MinorVerificationSystem.OpenSetPhoneNumWin(MinorVerificationSystem.IsOnlyChangePhone, MinorVerificationSystem.IsChangeFlag)
  end
end
function MinorVerificationSystem.CanUpdatePhoneNum()
  local TimeUtil = require("client.common.time_util")
  local CurrentTimestamp = TimeUtil.GetServerTimeInSec()
  local PastTime = CurrentTimestamp - MinorVerificationSystem.UpdatePhoneTimestamp
  return PastTime >= MinorVerificationSystem.CONST.UPDATE_PHONE_NUM_LIMIT_DAYS * MinorVerificationSystem.CONST.SECONDS_PER_DAY
end
function MinorVerificationSystem.GetNextUpdatePhoneNumTimeStr()
  local TimeUtil = require("client.common.time_util")
  local CanUpdateTimestamp = MinorVerificationSystem.UpdatePhoneTimestamp + MinorVerificationSystem.CONST.UPDATE_PHONE_NUM_LIMIT_DAYS * MinorVerificationSystem.CONST.SECONDS_PER_DAY
  return TimeUtil.FormatTime_YMDHM(CanUpdateTimestamp, true)
end
function MinorVerificationSystem.CanUpdateMinorFlag()
  local TimeUtil = require("client.common.time_util")
  local CurrentTimestamp = TimeUtil.GetServerTimeInSec()
  local PastTime = CurrentTimestamp - MinorVerificationSystem.UpdateMinorFlagTimestamp
  log(bWriteLog and string.format("martinhtma MinorVerificationSystem.CanUpdateMinorFlag() PastTime(%s), CheckTime(%s)", tostring(PastTime), tostring(MinorVerificationSystem.CONST.UPDATE_MINOR_FLAG_LIMIT_DAYS * MinorVerificationSystem.CONST.SECONDS_PER_DAY)))
  return PastTime >= MinorVerificationSystem.CONST.UPDATE_MINOR_FLAG_LIMIT_DAYS * MinorVerificationSystem.CONST.SECONDS_PER_DAY
end
function MinorVerificationSystem.GetNextUpdateMinorFlagTimeStr()
  local TimeUtil = require("client.common.time_util")
  local CanUpdateTimestamp = MinorVerificationSystem.UpdateMinorFlagTimestamp + MinorVerificationSystem.CONST.UPDATE_MINOR_FLAG_LIMIT_DAYS * MinorVerificationSystem.CONST.SECONDS_PER_DAY
  return TimeUtil.FormatTime_YMD(CanUpdateTimestamp, true)
end
function MinorVerificationSystem.HandleErrorCode(ErrorCode)
  if ErrorCode == MinorVerificationSystem.CONST.ERR_SUCCESS then
  elseif ErrorCode == MinorVerificationSystem.CONST.ERR_APPROVE_TIME_CD then
    local NoticeContent = LocUtil.LocalizeResFormat(6973, MinorVerificationSystem.GetNextUpdateMinorFlagTimeStr())
    ShowNotice(NoticeContent)
  elseif ErrorCode == MinorVerificationSystem.CONST.ERR_CODE_ERR then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local Title = LocUtil.GetLocalizeResStr(19302)
    local Content = LocUtil.GetLocalizeResStr(19330)
    CommonMsgBoxMgr.Show(1, Title, Content)
  elseif ErrorCode == MinorVerificationSystem.CONST.ERR_FREQUENTLY then
    ShowNotice(19373)
  elseif ErrorCode == MinorVerificationSystem.CONST.ERR_DAY_LIMIT then
    local TimeUtil = require("client.common.time_util")
    local RemainSeconds = TimeUtil.GetTodayTimestamp()
    local RemainTimeText = TimeUtil.FormatCountDownTime_DH_or_HM(RemainSeconds)
    ShowNotice(LocUtil.LocalizeResFormat(19331, RemainTimeText))
  elseif ErrorCode == MinorVerificationSystem.CONST.ERR_PHONE_ERR then
  else
    ShowNotice(ErrorCode)
  end
end
function MinorVerificationSystem.send_set_minor_flag(flag)
  local MinorVerificationHandler = require("client.network.Protocol.MinorVerificationHandler")
  MinorVerificationHandler.send_set_minor_flag(flag)
end
function MinorVerificationSystem.on_set_minor_flag_rsp(err_code, flag)
  log(bWriteLog and string.format("martinhtma MinorVerificationSystem.on_set_minor_flag_rsp err_code(%s)", err_code))
  err_code = tonumber(err_code)
  MinorVerificationSystem.HandleErrorCode(err_code)
  if err_code ~= MinorVerificationSystem.CONST.ERR_SUCCESS then
    return
  end
  MinorVerificationSystem.MinorFlag = flag
  if flag ~= MinorVerificationSystem.CONST.MINOR_FLAG_ADULT then
    MinorVerificationSystem.OpenSetPhoneNumWin(false, false)
  else
    MinorVerificationSystem.IsVerified = true
    local TimeUtil = require("client.common.time_util")
    MinorVerificationSystem.UpdateMinorFlagTimestamp = TimeUtil.GetServerTimeInSec()
    MinorVerificationSystem.EndVerificationFlow()
  end
end
function MinorVerificationSystem.send_set_approve_phone(phone_num)
  local IndiaPhoneNum = string.format("%s%s", MinorVerificationSystem.CONST.INDIA_PHONE_NUM_PREFIX, phone_num)
  if MinorVerificationSystem.IsTestMinorVerification then
    IndiaPhoneNum = string.format("%s%s", "86", phone_num)
  end
  if MinorVerificationSystem.IsVerified and IndiaPhoneNum == MinorVerificationSystem.PhoneNum then
    return
  end
  local MinorVerificationHandler = require("client.network.Protocol.MinorVerificationHandler")
  MinorVerificationHandler.send_set_approve_phone(IndiaPhoneNum)
end
function MinorVerificationSystem.on_set_approve_phone_rsp(err_code, phone_num)
  log(bWriteLog and string.format("martinhtma MinorVerificationSystem.on_set_approve_phone_rsp err_code(%s) phone_num(%s)", err_code, tostring(phone_num)))
  err_code = tonumber(err_code)
  MinorVerificationSystem.HandleErrorCode(err_code)
  EventSystem:postEvent(EVENTTYPE_MINOR_VERIFICATION, EVENTID_MINOR_VERIFICATION_SET_PHONE_ERROR, err_code)
  if err_code == MinorVerificationSystem.CONST.ERR_FREQUENTLY then
    local TimeUtil = require("client.common.time_util")
    MinorVerificationSystem.GetCodeTimestamp = TimeUtil.GetServerTimeInSec()
  elseif err_code == MinorVerificationSystem.CONST.ERR_SUCCESS then
    local TimeUtil = require("client.common.time_util")
    MinorVerificationSystem.GetCodeTimestamp = TimeUtil.GetServerTimeInSec()
    UIManager.CloseUI(UIManager.UI_Config.minor_verification_phone)
    MinorVerificationSystem.OpenVerificationCodeWin(MinorVerificationSystem.IsChangeFlag)
  end
end
function MinorVerificationSystem.send_get_verification_code()
  local MinorVerificationHandler = require("client.network.Protocol.MinorVerificationHandler")
  MinorVerificationHandler.send_get_verification_code()
end
function MinorVerificationSystem.on_get_verification_code_rsp(err_code)
  log(bWriteLog and string.format("martinhtma MinorVerificationSystem.on_get_verification_code_rsp err_code(%s)", err_code))
  err_code = tonumber(err_code)
  MinorVerificationSystem.HandleErrorCode(err_code)
  if err_code == MinorVerificationSystem.CONST.ERR_SUCCESS or err_code == MinorVerificationSystem.CONST.ERR_FREQUENTLY then
    local TimeUtil = require("client.common.time_util")
    MinorVerificationSystem.GetCodeTimestamp = TimeUtil.GetServerTimeInSec()
  end
  EventSystem:postEvent(EVENTTYPE_MINOR_VERIFICATION, EVENTID_MINOR_VERIFICATION_GET_CODE_ERROR, err_code)
end
function MinorVerificationSystem.send_send_verification_code(verification_code)
  local MinorVerificationHandler = require("client.network.Protocol.MinorVerificationHandler")
  MinorVerificationHandler.send_send_verification_code(verification_code)
end
function MinorVerificationSystem.on_send_verification_code_rsp(err_code, minor_info)
  log(bWriteLog and string.format("martinhtma MinorVerificationSystem.on_send_verification_code_rsp err_code(%s)", err_code))
  log_tree("martinhtma MinorVerificationSystem.on_send_verification_code_rsp minor_info", minor_info)
  err_code = tonumber(err_code)
  MinorVerificationSystem.HandleErrorCode(err_code)
  if err_code == MinorVerificationSystem.CONST.ERR_FREQUENTLY then
    local TimeUtil = require("client.common.time_util")
    MinorVerificationSystem.GetCodeTimestamp = TimeUtil.GetServerTimeInSec()
  elseif err_code == MinorVerificationSystem.CONST.ERR_SUCCESS then
    local TimeUtil = require("client.common.time_util")
    MinorVerificationSystem.GetCodeTimestamp = TimeUtil.GetServerTimeInSec()
    MinorVerificationSystem.MinorFlag = minor_info.flag
    MinorVerificationSystem.PhoneNum = minor_info.phone_num
    MinorVerificationSystem.IsVerified = minor_info.is_verified
    MinorVerificationSystem.UpdatePhoneTimestamp = minor_info.update_phone_ts
    MinorVerificationSystem.UpdateMinorFlagTimestamp = minor_info.flag_update_ts
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local Title = LocUtil.GetLocalizeResStr(19302)
    local Content = LocUtil.GetLocalizeResStr(19374)
    CommonMsgBoxMgr.Show(1, Title, Content)
    UIManager.CloseUI(UIManager.UI_Config.minor_verification_code)
    MinorVerificationSystem.EndVerificationFlow()
  end
  EventSystem:postEvent(EVENTTYPE_MINOR_VERIFICATION, EVENTID_MINOR_VERIFICATION_VERIFY_CODE_ERROR, err_code)
end
function MinorVerificationSystem.on_notify_minor_online_time(time)
  if Client.IsWindowOB() then
    return
  end
  local showInfo = MinorVerificationSystem.GetShowMsgInfo(time)
  if not showInfo or showInfo.showStatus == MinorVerificationSystem.CONST.STATUS_NONE then
    return
  end
  if showInfo.showStatus == MinorVerificationSystem.CONST.STATUS_QUIT_GAME then
    local Title = showInfo.titleStr
    local Content = showInfo.contentStr
    local ExitText = showInfo.exitStr
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, Title, Content, function()
      GameStatus.QuitGame()
    end, nil, ExitText)
  elseif showInfo.showStatus == MinorVerificationSystem.CONST.STATUS_REMIND_REST then
    local Title = showInfo.titleStr
    local Content = showInfo.contentStr
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, Title, Content)
  end
end
function MinorVerificationSystem.send_change_minor_flag(flag)
  local MinorVerificationHandler = require("client.network.Protocol.MinorVerificationHandler")
  MinorVerificationHandler.send_change_minor_flag(flag)
end
function MinorVerificationSystem.on_change_minor_flag_rsp(err_code, flag)
  log(bWriteLog and string.format("martinhtma MinorVerificationSystem.on_change_minor_flag_rsp err_code(%s)", err_code))
  err_code = tonumber(err_code)
  MinorVerificationSystem.HandleErrorCode(err_code)
  if err_code == MinorVerificationSystem.CONST.ERR_FREQUENTLY then
    local TimeUtil = require("client.common.time_util")
    MinorVerificationSystem.GetCodeTimestamp = TimeUtil.GetServerTimeInSec()
  elseif err_code == MinorVerificationSystem.CONST.ERR_SUCCESS then
    if flag == MinorVerificationSystem.CONST.MINOR_FLAG_ADULT then
      local TimeUtil = require("client.common.time_util")
      MinorVerificationSystem.GetCodeTimestamp = TimeUtil.GetServerTimeInSec()
      MinorVerificationSystem.OpenVerificationCodeWin(true)
    else
      MinorVerificationSystem.OpenSetPhoneNumWin(false, true)
    end
  end
end
function MinorVerificationSystem.send_cancel_change()
  local MinorVerificationHandler = require("client.network.Protocol.MinorVerificationHandler")
  MinorVerificationHandler.send_cancel_change()
end
function MinorVerificationSystem.on_cancel_change_rsp(err_code)
  log(bWriteLog and string.format("martinhtma MinorVerificationSystem.on_cancel_change_rsp err_code(%s)", err_code))
  err_code = tonumber(err_code)
  MinorVerificationSystem.HandleErrorCode(err_code)
  if err_code ~= MinorVerificationSystem.CONST.ERR_SUCCESS then
    return
  end
  MinorVerificationSystem.CloseSetPhoneNumWin()
end
function MinorVerificationSystem.GetShowMsgConfig()
  local cfg
  if MinorVerificationSystem.MinorFlag == MinorVerificationSystem.CONST.MINOR_FLAG_MINOR then
    cfg = MinorVerificationSystem.CONST.MINOR_MSG_CONFIG
    log(bWriteLog and "MinorVerificationSystem.GetShowMsgConfig type 1")
  elseif MinorVerificationSystem.MinorFlag == MinorVerificationSystem.CONST.MINOR_FLAG_ADULT then
    if MinorVerificationSystem.IsVerified then
      cfg = MinorVerificationSystem.CONST.ADULT_VERIFIED_MSG_CONFIG
      log(bWriteLog and "MinorVerificationSystem.GetShowMsgConfig type 2")
    else
      cfg = MinorVerificationSystem.CONST.ADULT_NOT_VERIFIED_MSG_CONFIG
      log(bWriteLog and "MinorVerificationSystem.GetShowMsgConfig type 3")
    end
  else
    cfg = MinorVerificationSystem.CONST.ADULT_VERIFIED_MSG_CONFIG
    log(bWriteLog and "MinorVerificationSystem.GetShowMsgConfig type 2 for default")
  end
  return cfg
end
function MinorVerificationSystem.GetShowMsgInfo(time)
  if not time then
    return nil
  end
  local cfg = MinorVerificationSystem.GetShowMsgConfig()
  if not cfg then
    log(bWriteLog and "MinorVerificationSystem.GetShowMsgInfo cfg is nil")
    return nil
  end
  local msgInfo = {
    showStatus = MinorVerificationSystem.CONST.STATUS_NONE,
    titleStr = "",
    contentStr = "",
    exitStr = ""
  }
  local passedHours = math.floor(time / 60)
  if time >= cfg.QUIT_GAME_MINUTES then
    msgInfo.showStatus = MinorVerificationSystem.CONST.STATUS_QUIT_GAME
    msgInfo.titleStr = LocUtil.GetLocalizeResStr(MinorVerificationSystem.CONST.POPUP_TITLE_ID)
    msgInfo.contentStr = LocUtil.LocalizeResFormat(MinorVerificationSystem.CONST.QUIT_GAME_CONTENT_ID)
    msgInfo.exitStr = LocUtil.GetLocalizeResStr(MinorVerificationSystem.CONST.QUIT_GAME_BUTTON_TEXT_ID)
  elseif time >= cfg.REMIND_REST_MINUTES then
    msgInfo.showStatus = MinorVerificationSystem.CONST.STATUS_REMIND_REST
    msgInfo.titleStr = LocUtil.GetLocalizeResStr(MinorVerificationSystem.CONST.POPUP_TITLE_ID)
    msgInfo.contentStr = LocUtil.LocalizeResFormat(MinorVerificationSystem.CONST.REMIND_RET_CONTENT_ID, passedHours)
  end
  log(bWriteLog and "MinorVerificationSystem.GetShowMsgInfo time: " .. tostring(time) .. " status: " .. tostring(msgInfo.showStatus))
  return msgInfo
end
return MinorVerificationSystem