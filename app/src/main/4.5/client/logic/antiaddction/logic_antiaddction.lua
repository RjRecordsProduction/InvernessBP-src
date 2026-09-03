local AntiaddctionSystem = {
  is_nonage = true,
  need_show = false,
  age = -1,
  open_type = 0,
  is_login = false,
  anti_table = {},
  next_change_time = 0,
  next_switch_time = 0,
  is_show_setting = false,
  rest_time = 0,
  is_bind_parent = false,
  bind_parent_url = nil,
  parent_nation_code = 0,
  parent_number = 0
}
function AntiaddctionSystem.OpenNoticePanel()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return
  end
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.antiaddction_notice)
  end
end
function AntiaddctionSystem.GetNextChangeTime()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime >= AntiaddctionSystem.next_switch_time then
    return 0
  else
    return AntiaddctionSystem.next_switch_time
  end
end
function AntiaddctionSystem.OpenKickPanel(contentMsg, popupType)
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.antiaddction_kick, contentMsg, popupType)
  end
  LobbySystem.on_match_cancel_req()
end
function AntiaddctionSystem.CloseKickPanel()
  log(bWriteLog and "CloseKickPanel")
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.antiaddction_kick)
  end
end
function AntiaddctionSystem.CheckIsPakistan()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.sIpRegion == "PK" then
    log(bWriteLog and "AntiaddctionSystem.CheckIsPakistan is Pakistan")
    return true
  end
  return false
end
function AntiaddctionSystem.OpenVerifyH5()
  local BusinessHelper = import("BusinessHelper")
  local iEnv = BusinessHelper.GetIMSDKEnv()
  local url = FuncUtil.GetDomainByID(3366221)
  if iEnv == 1 then
    url = FuncUtil.GetDomainByID(3366222)
  end
  url = url .. "?openid={openid}&uid={uid}&region={country}&gameid={gameid}&sTicket={itop_ticket}&language={language}"
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  url = webModule:AddParameterByPersonalInfo(url, false, true, true)
  log(bWriteLog and string.format("AntiaddctionSystem.OpenVerifyH5, url:%s", url))
  GlobalData.JumpWebUrl(url)
  local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
  logic_account_protect_setting:SetIsJumpToAntiaddctionH5(true)
end
function AntiaddctionSystem:IsPakistanCanSlap()
  if not LobbySystem.CheckOpen(BP_ENUM_PAKISTAN_ANTIADDCTION_SWITCH_ID) then
    log(bWriteLog and "AntiaddctionSystem:IsPakistanCanSlap return of switch not open")
    return false
  end
  local status = AntiaddctionSystem.pk_status or 0
  if status == 1 then
    log(bWriteLog and "AntiaddctionSystem:IsPakistanCanSlap return of status ~= 0")
    return false
  end
  local lastTime = AntiaddctionSystem.pk_time or 0
  local TimeUtil = require("client.common.time_util")
  if lastTime and 0 < lastTime and TimeUtil.WithinInNDay(lastTime, 30) then
    log(bWriteLog and "AntiaddctionSystem:IsPakistanCanSlap return of WithinInNDay 30")
    return false
  end
  return true
end
function AntiaddctionSystem.ShowParentEmailUI()
  UIManager.ShowUI(UIManager.UI_Config.gdpr_email_verify, function(emailUrl, parentName)
    local minors_info = {guardian_name = parentName, guardian_email = emailUrl}
    local AntiaddctionHandler = require("client.network.Protocol.AntiaddctionHandler")
    AntiaddctionHandler.send_report_pakistan_minors_info_req(1, minors_info)
    AntiaddctionSystem.OpenNoticePanel()
  end, {
    bOpenNotice = true,
    titleTextID = 75063,
    descTextID = 75064,
    mailTextID = 75065,
    sureTextID = 75075,
    nameTextID = 75076
  })
end
function AntiaddctionSystem.SetAge()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() then
    log(bWriteLog and "AntiaddctionSystem.SetAge Newbie skip AgeRemind")
    return
  end
  local bIsPK = AntiaddctionSystem.CheckIsPakistan()
  if bIsPK and not AntiaddctionSystem.IsPakistanCanSlap() then
    log(bWriteLog and "AntiaddctionSystem.SetAge return of not IsPakistanCanSlap")
    return
  end
  local contentMsg = LocUtil.LocalizeResFormat(6769, AntiaddctionSystem.age)
  local okMsg = LocUtil.GetLocalizeResStr(4110)
  local noMsg = LocUtil.GetLocalizeResStr(4115)
  local title = LocUtil.GetLocalizeResStr(6770)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.CloseAchievementTip()
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, contentMsg, function()
    log(bWriteLog and "click confirm")
    AntiaddctionSystem.set_nonage_req(0)
    AntiaddctionSystem.OpenNoticePanel()
  end, function()
    log(bWriteLog and "click cancle")
    AntiaddctionSystem.set_nonage_req(1)
    if bIsPK then
      AntiaddctionSystem.OpenVerifyH5()
    else
      AntiaddctionSystem.OpenNoticePanel()
    end
  end, okMsg, noMsg)
end
function AntiaddctionSystem.set_nonage_rsp(res, is_nonage, next_time, is_show_setting)
  local TimeUtil = require("client.common.time_util")
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  log(bWriteLog and "set_nonage_rsp res:  " .. tostring(res) .. " ||is_nonage : " .. tostring(is_nonage) .. " || next_time " .. tostring(next_time) .. "|| is_show_setting " .. tostring(is_show_setting))
  if next_time ~= nil then
    AntiaddctionSystem.next_switch_time = next_time
  end
  if is_show_setting ~= nil then
    AntiaddctionSystem.  end
  if res == 510001 then
    local title = LocUtil.GetLocalizeResStr(6770)
    TimeUtil.FormatTime_YMDHMS(TimeUtil.OSTime(), true)
    local notice = LocUtil.LocalizeResFormat(6972, TimeUtil.FormatTime_YMDHMS(AntiaddctionSystem.next_switch_time, true))
    logic_achievement_float_tip.CloseAchievementTip()
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, notice)
  elseif res == 0 then
    AntiaddctionSystem.    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ANTIADDCTION)
  end
end
function AntiaddctionSystem.get_nonage_data_rsp(is_show, is_nonage, age, next_time, is_show_setting, pk_time, pk_status)
  log(bWriteLog and string.format("AntiaddctionSystem.get_nonage_data_rsp, is_show:%s", is_show))
  log(bWriteLog and string.format("AntiaddctionSystem.get_nonage_data_rsp, is_nonage:%s", is_nonage))
  log(bWriteLog and string.format("AntiaddctionSystem.get_nonage_data_rsp, age:%s", age))
  log(bWriteLog and string.format("AntiaddctionSystem.get_nonage_data_rsp, next_time:%s", next_time))
  log(bWriteLog and string.format("AntiaddctionSystem.get_nonage_data_rsp, is_show_setting:%s", is_show_setting))
  log(bWriteLog and string.format("AntiaddctionSystem.get_nonage_data_rsp, pk_time:%s", pk_time))
  log(bWriteLog and string.format("AntiaddctionSystem.get_nonage_data_rsp, pk_status:%s", pk_status))
  AntiaddctionSystem.  AntiaddctionSystem.  if is_show == true and is_nonage == nil then
    AntiaddctionSystem.need_show = true
  else
    AntiaddctionSystem.need_show = false
  end
  if next_time then
    AntiaddctionSystem.next_switch_time = next_time
  end
  if is_show_setting ~= nil then
    AntiaddctionSystem.  end
  AntiaddctionSystem.  AntiaddctionSystem.end
function AntiaddctionSystem.ShouldSlap()
  log(bWriteLog and " AntiaddctionSystem.ShouldSlap")
  local TimeUtil = require("client.common.time_util")
  if AntiaddctionSystem.need_show == true then
    return true
  elseif AntiaddctionSystem.is_login == true then
    return true
  end
  return false
end
function AntiaddctionSystem.ShowSlap()
  log(bWriteLog and " AntiaddctionSystem.ShowSlap")
  local TimeUtil = require("client.common.time_util")
  if AntiaddctionSystem.need_show == true then
    AntiaddctionSystem.SetAge()
  elseif AntiaddctionSystem.is_login == true then
    local contentMsg
    if AntiaddctionSystem.anti_table.popup_type == 2 then
      contentMsg = LocUtil.LocalizeResFormat(tonumber(AntiaddctionSystem.anti_table.content_attempt), TimeUtil.FormatCountDownTime_DH_or_HM(AntiaddctionSystem.rest_time, true))
      AntiaddctionSystem.OpenKickPanel(contentMsg, AntiaddctionSystem.anti_table.popup_type)
    elseif AntiaddctionSystem.anti_table.popup_type == 3 then
      contentMsg = LocUtil.LocalizeResFormat(tonumber(AntiaddctionSystem.anti_table.content_attempt), AntiaddctionSystem.GetNextLoginTime())
      AntiaddctionSystem.OpenKickPanel(contentMsg, AntiaddctionSystem.anti_table.popup_type)
    elseif AntiaddctionSystem.anti_table.popup_type == 4 then
      contentMsg = LocUtil.LocalizeResFormat(tonumber(AntiaddctionSystem.anti_table.content), TimeUtil.FormatCountDownTime_DH_or_HM(AntiaddctionSystem.anti_table.sustained_time_down, true))
      AntiaddctionSystem.OpenKickPanel(contentMsg, AntiaddctionSystem.anti_table.popup_type)
    end
  end
end
function AntiaddctionSystem.check_nonage_anti_work(ok, plan_id, anti_table, rest_time, is_login, is_bind_parent, bind_parent_url)
  log(bWriteLog and "check_nonage_anti_work")
  log_tree("anti_table ", anti_table)
  log(bWriteLog and "rest_time " .. tostring(rest_time))
  log(bWriteLog and "is_bind_parent " .. tostring(is_bind_parent))
  log(bWriteLog and "bind_parent_url " .. tostring(bind_parent_url))
  local TimeUtil = require("client.common.time_util")
  local curStatus = GameStatus.GetGameStatus()
  if GameStatus.IsInLobbyOrMainCity() or curStatus == GameStatus.Login then
    if ok == 0 then
      log(bWriteLog and "check_nonage_anti_work is ok")
      local contentMsg
      AntiaddctionSystem.      AntiaddctionSystem.      AntiaddctionSystem.      AntiaddctionSystem.      AntiaddctionSystem.      if is_login == false then
        if anti_table.popup_type == 1 then
          contentMsg = LocUtil.LocalizeResFormat(tonumber(anti_table.content), TimeUtil.FormatCountDownTime_DH_or_HM(anti_table.sustained_time_down, true), TimeUtil.FormatCountDownTime_DH_or_HM(anti_table.gap_time, true))
          AntiaddctionSystem.OpenKickPanel(contentMsg, anti_table.popup_type)
        elseif anti_table.popup_type == 2 then
          contentMsg = LocUtil.LocalizeResFormat(tonumber(anti_table.content), TimeUtil.FormatCountDownTime_DH_or_HM(anti_table.sustained_time_down, true), TimeUtil.FormatCountDownTime_DH_or_HM(rest_time, true), TimeUtil.FormatCountDownTime_DH_or_HM(anti_table.gap_time, true))
          AntiaddctionSystem.OpenKickPanel(contentMsg, anti_table.popup_type)
        elseif anti_table.popup_type == 3 then
          contentMsg = LocUtil.LocalizeResFormat(tonumber(anti_table.content), TimeUtil.FormatCountDownTime_DH_or_HM(anti_table.sustained_time_down, true), AntiaddctionSystem.GetNextLoginTime())
          AntiaddctionSystem.OpenKickPanel(contentMsg, anti_table.popup_type)
        elseif anti_table.popup_type == 4 then
          contentMsg = LocUtil.LocalizeResFormat(tonumber(anti_table.content), TimeUtil.FormatCountDownTime_DH_or_HM(anti_table.sustained_time_down, true))
          AntiaddctionSystem.OpenKickPanel(contentMsg, anti_table.popup_type)
        end
      end
    else
      AntiaddctionSystem.is_login = false
      err_anti_normal = 510000
      if ok ~= err_anti_normal then
        log_error("check_nonage_anti_work error code is " .. tostring(ok))
      end
    end
  end
end
function AntiaddctionSystem.GetNextLoginTime()
  local TimeUtil = require("client.common.time_util")
  local str = TimeUtil.GetServerTimeInSec()
  local zero = TimeUtil.OSDate("!%Y-%m-%d 00:00:00", str)
  local result = TimeUtil.TimeStringToUnixstamp(zero) + 86400
  log(bWriteLog and "after == " .. TimeUtil.FormatTime_YMDHMS(result, true))
  return TimeUtil.FormatTime_YMDHMS(result, true)
end
function AntiaddctionSystem.set_nonage_req(is_nonage)
  local AntiaddctionHandler = require("client.network.Protocol.AntiaddctionHandler")
  AntiaddctionHandler.send_set_nonage_req(is_nonage)
end
return AntiaddctionSystem