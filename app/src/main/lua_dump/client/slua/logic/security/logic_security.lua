local SecuritySystem = {bHasLogin = false}
local MailMacro = require("client.slua.logic.mail.mail_macro")
local logic_mail = require("client.slua.logic.mail.logic_mail")
function SecuritySystem.IsSlapFaceMail(mailInfo)
  return mailInfo.opt.type == MailMacro.Enum_Mail_Type.Security and mailInfo.opt.subtype == MailMacro.Enum_Security_SubTabType.SlapFace
end
function SecuritySystem.IsWarningPenalty(mailInfo)
  return mailInfo.opt.type == MailMacro.Enum_Mail_Type.Security and mailInfo.opt.subtype == MailMacro.Enum_Security_SubTabType.WarningPenalty
end
function SecuritySystem.IsShowLobbyMainUI()
  local lobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  return lobbyMainUI and lobbyMainUI:IsShow()
end
function SecuritySystem.CanShowFace()
  local SlapFaceMailList = logic_mail.GetSecurityMailList(MailMacro.Enum_Security_SubTabType.SlapFace) or {}
  if not next(SlapFaceMailList) then
    log(bWriteLog and "[chub]SecuritySystem.ShowReportSucceedFace,next(SlapFaceMailList) = false")
    return
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if not NewFaceSlapSystem:IsCanShow() then
    log(bWriteLog and "SecuritySystem.CanShowFace:NewFaceSlapSystem:IsCanShow()")
    return false
  end
  local reportSlapUI = UIManager.GetUI(UIManager.UI_Config.ReportSucceed_Slap_UIBP)
  if reportSlapUI then
    log(bWriteLog and "SecuritySystem.CanShowFace:reportSlapUI")
    return false
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if NewFaceSlapSystem:IsCloseFaceSlap() then
    log(bWriteLog and "SecuritySystem.CanShowFace.IsCloseFaceSlap()")
    return false
  end
  if not SecuritySystem.IsShowLobbyMainUI() then
    log(bWriteLog and "SecuritySystem.CanShowFace.IsShowLobbyMainUI()")
    return false
  end
  if not UIManager.IsAndroidStackEmpty() then
    log(bWriteLog and "SecuritySystem.CanShowFace.IsLobbyEmpty()")
    return false
  end
  log(bWriteLog and "SecuritySystem.CanShowFace:true")
  return true
end
function SecuritySystem.CanShowWarningFace()
  local SlapFaceMailList = logic_mail.GetSecurityMailList(MailMacro.Enum_Security_SubTabType.WarningPenalty) or {}
  if not next(SlapFaceMailList) then
    log(bWriteLog and "[chub]SecuritySystem.CanShowWarningFace,next(SlapFaceMailList) = false")
    return
  end
  local reportSlapUI = UIManager.GetUI(UIManager.UI_Config.com_msg_box_slua)
  if reportSlapUI then
    return
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if NewFaceSlapSystem:IsCloseFaceSlap() then
    log(bWriteLog and "SecuritySystem.CanShowWarningFace NewFaceSlapSystem:IsCloseFaceSlap()")
    return false
  end
  if not SecuritySystem.IsShowLobbyMainUI() then
    log(bWriteLog and "SecuritySystem.CanShowWarningFace not SecuritySystem.IsShowLobbyMainUI()")
    return false
  end
  local topUIName = UIManager.GetTopUIName()
  if Client.IsDevelopment() then
    if not UIManager.IsAndroidStackEmpty() and topUIName ~= UIManager.UI_Config.Lobby_GM.keyName then
      log(bWriteLog and "SecuritySystem.CanShowWarningFace not UIManager.IsAndroidStackEmpty()1")
      return false
    end
  elseif not UIManager.IsAndroidStackEmpty() then
    log(bWriteLog and "SecuritySystem.CanShowWarningFace not UIManager.IsAndroidStackEmpty()2")
    return false
  end
  log(bWriteLog and "SecuritySystem.CanShowWarningFace:true")
  return true
end
function SecuritySystem.ShouldShowReportSucceedFace()
  log(bWriteLog and "[chub]SecuritySystem.ShouldShowReportSucceedFace")
  SecuritySystem.bHasLogin = true
  local SlapFaceMailList = logic_mail.GetSecurityMailList(MailMacro.Enum_Security_SubTabType.SlapFace)
  log_tree("[chub]ShouldShowReportSucceedFace,SlapFaceMailList = ", SlapFaceMailList)
  for _, v in pairs(SlapFaceMailList or {}) do
    if not v.read then
      return true
    end
  end
  return false
end
function SecuritySystem.CheckShowReportSucceedFace()
  if SecuritySystem.CanShowFace() then
    SecuritySystem.ShowReportSucceedFace()
  end
end
function SecuritySystem.CheckShowReportSucceedWarningFace()
  if SecuritySystem.CanShowWarningFace() then
    SecuritySystem.ShowReportSucceedWarningFace()
  end
end
function SecuritySystem.CheckIsSlapFaceNotify(mailInfo)
  log(bWriteLog and "SecuritySystem.CheckIsSlapFaceNotify")
  if not SecuritySystem.IsSlapFaceMail(mailInfo) then
    log(bWriteLog and "SecuritySystem.IsSlapFaceMail(mailInfo) = false")
    return
  end
  SecuritySystem.CheckShowReportSucceedFace()
end
function SecuritySystem.CheckIsSlapWarningPenalty(mailInfo)
  if not SecuritySystem.IsWarningPenalty(mailInfo) then
    log(bWriteLog and "SecuritySystem.IsWarningPenalty(mailInfo) = false")
    return
  end
  SecuritySystem.CheckShowReportSucceedWarningFace()
end
function SecuritySystem.ShowReportSucceedFace()
  log(bWriteLog and "[chub]SecuritySystem.ShowReportSucceedFace")
  local SlapFaceMailList = logic_mail.GetSecurityMailList(MailMacro.Enum_Security_SubTabType.SlapFace) or {}
  if not next(SlapFaceMailList) then
    log(bWriteLog and "[chub]SecuritySystem.ShowReportSucceedFace,next(SlapFaceMailList) = false")
    return
  end
  log_tree("[chub]ShowReportSucceedFace,SlapFaceMailList = ", SlapFaceMailList)
  if not SecuritySystem.CanSlapFace() then
    log(bWriteLog and "[chub]SecuritySystem.ShowReportSucceedFace,SecuritySystem.CanSlapFace = false")
    return
  end
  table.sort(SlapFaceMailList, function(a, b)
    return a.time > b.time
  end)
  if SlapFaceMailList[1].opt then
    if SlapFaceMailList[1].opt.popface_type == 1 then
      UIManager.ShowUI(UIManager.UI_Config.ReportSucceed_Slap_Pro_UIBP, SlapFaceMailList[1])
    else
      UIManager.ShowUI(UIManager.UI_Config.ReportSucceed_Slap_UIBP, SlapFaceMailList[1])
    end
  end
  SecuritySystem.DeleteAllSlapFaceMail()
  SecuritySystem.SaveSlapFaceRecord()
end
function SecuritySystem.ShowReportSucceedWarningFace()
  log(bWriteLog and "[PXY]SecuritySystem.ShowReportSucceedFace")
  local SlapFaceMailList = logic_mail.GetSecurityMailList(MailMacro.Enum_Security_SubTabType.WarningPenalty) or {}
  if not next(SlapFaceMailList) then
    log(bWriteLog and "[PXY]SecuritySystem.ShowReportSucceedFace,next(SlapFaceMailList) = false")
    return
  end
  local mailInfo = SlapFaceMailList[1]
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local OpenCustomerService = function()
    local helpShiftStr = ""
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_Appeal_MountingCar_Click)
    helpShiftStr = "mr_ban_team with cheater"
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    LogicCustomerService.HelpshiftShowFAQsWithInfo(helpShiftStr)
  end
  local clickAppeallCallback = function()
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_Appeal_MountingCar_Click)
    SecuritySystem.JumpAppealURL()
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local strAppeal = LocUtil.GetLocalizeResStr(4004)
  local content = LocUtil.GetLocalizeResStr(47211)
  if mailInfo and mailInfo.content then
    content = mailInfo.content
    title = mailInfo.title
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if mailInfo and mailInfo.opt and mailInfo.opt.appeal_link_switch then
    CommonMsgBoxMgr.Show(3, title, content, clickAppeallCallback, nil, strAppeal)
  else
    CommonMsgBoxMgr.Show(4, title, content, nil, OpenCustomerService, nil, strAppeal)
  end
  SecuritySystem.DeleteWarningSlapFaceMail()
end
function SecuritySystem.JumpAppealURL()
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local url = FuncUtil.GetDomainByID(3366036) .. "/act/a20211125aqz/index.html?sTicket={itop_ticket}&gameid={gameid}&loginType={loginType}&region={country}&timeZone={timeZone}&area_id={areaid}&game_area={game_area}&nickname={nickname}&head_pic={head_pic}"
  url = webModule:AddParameterByPersonalInfo(url)
  url = url .. "#/illegal"
  log(bWriteLog and "SecuritySystem.JumpAppealURL url = " .. url)
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(url)
end
function SecuritySystem.DeleteWarningSlapFaceMail()
  log(bWriteLog and "SecuritySystem.DeleteAllWarningSlapFaceMail")
  local MailIdList = {}
  local SlapFaceMailList = logic_mail.GetSecurityMailList(MailMacro.Enum_Security_SubTabType.WarningPenalty) or {}
  table.insert(MailIdList, SlapFaceMailList[1].my_id)
  log_tree("[pxy]mailIdList= ", MailIdList)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.req_delete_mail_list(MailIdList)
end
function SecuritySystem.DeleteAllSlapFaceMail()
  log(bWriteLog and "SecuritySystem.DeleteAllSlapFaceMail")
  local mailIdList = {}
  local SlapFaceMailList = logic_mail.GetSecurityMailList(MailMacro.Enum_Security_SubTabType.SlapFace) or {}
  for _, v in pairs(SlapFaceMailList) do
    table.insert(mailIdList, v.my_id)
  end
  log_tree("[chub]mailIdList= ", mailIdList)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.req_delete_mail_list(mailIdList)
end
function SecuritySystem.CanSlapFace()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SlapFaceRecord = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ReportSlapFaceRecord)
  if not SlapFaceRecord then
    log(bWriteLog and "[chub]SecuritySystem.CanSlapFace,SlapFaceRecord = nil")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  if not TimeUtil.IsSameDay(SlapFaceRecord.Timestamp or 0, TimeUtil.GetServerTimeInSec()) then
    log(bWriteLog and "[chub]SecuritySystem.CanSlapFace,TimeUtil.IsSameDay = nil")
    return true
  end
  log(bWriteLog and "[chub]SecuritySystem.CanSlapFace,SlapFaceRecord.SlapFaceTimes < 3" .. tostring(SlapFaceRecord.SlapFaceTimes < 3))
  return SlapFaceRecord.SlapFaceTimes < 3
end
function SecuritySystem.SaveSlapFaceRecord()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local PreSlapFaceRecord = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ReportSlapFaceRecord)
  local SlapFaceRecord = {}
  local TimeUtil = require("client.common.time_util")
  if not PreSlapFaceRecord or not TimeUtil.IsSameDay(PreSlapFaceRecord.Timestamp or 0, TimeUtil.GetServerTimeInSec()) then
    SlapFaceRecord = {
      Timestamp = TimeUtil.GetServerTimeInSec(),
      SlapFaceTimes = 1
    }
  else
    SlapFaceRecord = {
      Timestamp = PreSlapFaceRecord.Timestamp,
      SlapFaceTimes = PreSlapFaceRecord.SlapFaceTimes + 1
    }
  end
  PlayerPrefsSystem.SaveTableToFile_N(SlapFaceRecord, PlayerPrefsSystem.ePlayerPrefsType.ReportSlapFaceRecord)
end
function SecuritySystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "SecuritySystem: OnModePostSwitch, nextState = " .. tostring(nextState))
  log(bWriteLog and "SecuritySystem: OnModePostSwitch, SecuritySystem.bHasLogin = " .. tostring(SecuritySystem.bHasLogin))
  if GameStatus.IsInLobbyOrMainCity() and SecuritySystem.bHasLogin then
    SecuritySystem.CheckShowReportSucceedFace()
  end
end
function SecuritySystem.OnLogout()
  if UIManager.GetUI(UIManager.UI_Config.ReportSucceed_Slap_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.ReportSucceed_Slap_UIBP)
  end
end
return SecuritySystem