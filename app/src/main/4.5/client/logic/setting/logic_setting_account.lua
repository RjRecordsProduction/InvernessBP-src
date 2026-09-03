local SettingAccount = {
  UnbindPlatformName = "",
  Setting_Region_Set_Time = "",
  Setting_Region_Name = "",
  loginTypeOrderList = {},
  ForbidFollowJump = true,
  sFirstChannel = "",
  sSecondChannel = "",
  isFormPopup = false,
  canBindCode = nil,
  hasSentPhoneCode = false,
  hasSentMailCode = false,
  nLoginChannel = 1,
  lastSendCodeTime = 0,
  unifiedAccountLogging = false,
  qrcodeTime = 7,
  savedScanData = nil,
  myPromise = nil,
  VerifyCodeTabType = {
    Mail = 3,
    SMS = 2,
    WhatsApp = 1
  },
  WhatsAppPhoneShowCfg = {}
}
local ENUM_PANEL_TYPE = {Phone = 1, Mail = 2}
SettingAccount.local defaultAccountData = {
  show_mail = false,
  show_phone = false,
  bind_mail = false,
  bind_phone = false,
  award_state_mail = 0,
  award_state_phone = 0,
  need_get_server_info = nil,
  is_logout_after_bind = true,
  is_guest_can_bind = false,
  is_can_both_bind = false,
  is_get_code_by_server = true,
  area_code = 0,
  show_forget_password = false
}
local accountData = {}
local safeTableData
function SettingAccount.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Login then
    local TableUtil = require("common.table_util")
    accountData = TableUtil.CopyTable(defaultAccountData)
    accountData.need_get_server_info = true
    log_tree("  : accountData", accountData)
    SettingAccount.hasSentPhoneCode = false
    SettingAccount.hasSentMailCode = false
  elseif nextState == GameStatus.Lobby then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local bIsDiffDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eSeeBindInfo)
    if bIsDiffDate then
      SettingAccount.canBindCode = nil
      local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
      LoginVerifyHandler.send_verify_code_send_check_req()
      SettingAccount.PreCheckRequestData()
    else
      SettingAccount.CheckRequestData()
    end
    SettingAccount.InitLoginChannel()
    SettingAccount.SendScanData()
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    local data_config_marco = require("client.logic.data.data_config_marco")
    log_tree("SettingAccount.OnModePostSwitch. DataMgr.RegionData ", DataMgr.RegionData)
    BasicDataServerTable:GetOrReqData(data_config_marco.whatsapp_sms_gray_cfg, function(table_name, data)
      SettingAccount.WhatsAppPhoneShowCfg = data
      log_tree("SettingAccount.OnModePostSwitch. whatsapp_sms_gray_cfg data ", data)
    end)
  end
end
function SettingAccount.InitLoginChannel()
  SettingAccount.nLoginChannel = Client.GetLoginChannel(NetInterface)
  log_warning(bWriteLog and "  : SettingAccount.nLoginChannel: " .. tostring(SettingAccount.nLoginChannel))
end
function SettingAccount.SendScanData(callback)
  local AllQRCodeLoginResults = SettingAccount.GetAllQRCodeLoginResults()
  local NMaxNum = 11
  local myOpenId = tostring(DataMgr.roleData.openID)
  local sort_util = require("common.sort_util")
  sort_util.SortByNumber(AllQRCodeLoginResults, true, "guid_token_expire")
  local len = #AllQRCodeLoginResults
  if NMaxNum < len then
    for _ = 1, len - NMaxNum do
      table.remove(AllQRCodeLoginResults)
    end
  end
  local hasMe
  for _, id in pairs(AllQRCodeLoginResults) do
    if tostring(id) == myOpenId then
      hasMe = true
      break
    end
  end
  if next(AllQRCodeLoginResults) then
    local ids = prealloctable(NMaxNum, 0)
    for i, v in ipairs(AllQRCodeLoginResults) do
      ids[i] = v.guid_open_id
    end
    if not hasMe then
      ids[#ids + 1] = myOpenId
    end
    local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
    LoginVerifyHandler.send_batch_get_user_names_req(ids):Then(function(_, names)
      SettingAccount.SetScanData(names)
      if callback then
        callback()
      end
    end)
  end
end
function SettingAccount.SetLastCodeTime(time)
  SettingAccount.lastSendCodeTime = time
  log_warning(bWriteLog and "  : SettingAccount.SetLastCodeTime: " .. tostring(time))
end
function SettingAccount.SetunifiedAccountLogging(flag)
  SettingAccount.unifiedAccountLogging = flag
  log_warning(bWriteLog and "  :SetunifiedAccountLogging flag: " .. tostring(flag))
end
function SettingAccount.SetQrcodeTime(days)
  log(bWriteLog and "  SettingAccount.SetQrcodeTime. days: " .. tostring(days))
  SettingAccount.qrcodeTime = days
end
function SettingAccount.InitData()
  accountData.is_can_both_bind = LobbySystem.CheckOpen(BP_ENUM_PHONEMAIL_BOTH_BIND)
  accountData.is_guest_can_bind = LobbySystem.CheckOpen(BP_ENUM_PHONEMAIL_GUEST_BIND)
  accountData.is_logout_after_bind = LobbySystem.CheckOpen(BP_ENUM_PHONEMAIL_BIND_LOGOUT)
  accountData.is_get_code_by_server = LobbySystem.CheckOpen(BP_ENUM_PHONEMAIL_GET_CODE_BY_SERVER)
  log(bWriteLog and "  : accountData.is_get_code_by_server" .. tostring(accountData.is_get_code_by_server))
  if SettingAccount.nLoginChannel == BP_ENUM_PLAYFORM_TOURIST and accountData.is_guest_can_bind == false then
    accountData.show_mail = false
    accountData.show_phone = false
  end
  log(bWriteLog and "  : accountData.need_get_server_info" .. tostring(accountData.need_get_server_info))
  if (accountData.show_mail or accountData.show_phone) and accountData.need_get_server_info == nil then
    accountData.need_get_server_info = true
  end
end
function SettingAccount.GetSettingAccountData()
  return accountData
end
function SettingAccount.SetSentCode(loginType)
  log(bWriteLog and "  : SetSentCode:" .. tostring(loginType))
  if loginType == 0 then
    SettingAccount.hasSentPhoneCode = true
  else
    SettingAccount.hasSentMailCode = true
  end
end
function SettingAccount.OnGetBuildAccountRsp(result)
  log_tree("OnGetBuildAccountRsp", result)
  accountData.need_get_server_info = false
  accountData.bind_mail = false
  if result.mail and result.mail ~= "" then
    accountData.bind_mail = result.mail
  end
  accountData.bind_phone = false
  if result.cellphone and result.cellphone ~= "" then
    accountData.bind_phone = result.cellphone
  end
  if result.area_code then
    accountData.area_code = result.area_code
  end
  accountData.account_type = result.account_type
  accountData.mail_bind_time = result.mail_bind_time
  accountData.phone_bind_time = result.phone_bind_time
  accountData.login_total_days = result.login_total_days
  accountData.need_login_days = result.need_login_days
  accountData.need_bind_days = result.need_bind_days
  if result.award_taketime and result.award_taketime ~= 0 then
    accountData.award_state_mail = 2
  elseif result.mail and result.mail ~= "" then
    accountData.award_state_mail = 1
  else
    accountData.award_state_mail = 0
  end
  if result.award_taketime2 and result.award_taketime2 ~= 0 then
    accountData.award_state_phone = 2
  elseif result.cellphone and result.cellphone ~= "" then
    accountData.award_state_phone = 1
  else
    accountData.award_state_phone = 0
  end
  EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_PHONE_MAIL_REFRESH)
  SettingAccount.CheckStealModelFlag()
end
local ENUM_MsgBindType = {Phone = 2, Email = 1}
function SettingAccount.OnGetAward(_, taketime_list)
  log_tree("  : taketime_list", taketime_list)
  if taketime_list and taketime_list[ENUM_MsgBindType.Email] > 0 then
    accountData.award_state_mail = 2
  end
  if taketime_list and 0 < taketime_list[ENUM_MsgBindType.Phone] then
    accountData.award_state_phone = 2
  end
end
function SettingAccount.OnUpdateAccountRes(err, _)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_UPD_ACCOUNT_RES, err)
end
function SettingAccount.ShowMail(isShow)
  accountData.show_mail = isShow
end
function SettingAccount.ShowPhone(isShow)
  accountData.show_phone = isShow
end
function SettingAccount.NeedShowForget()
  accountData.show_forget_password = true
end
function SettingAccount.SetMailChangeState(mail_change_state)
  accountData.end
function SettingAccount.SetPhoneChangeState(phone_change_state)
  accountData.end
function SettingAccount.CanChangeMail()
  if not accountData.mail_change_state then
    return false
  end
  if accountData.account_type ~= 1 then
    return false
  end
  if not SettingAccount.IsChangeAccountLoginDaysValid() then
    local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
    LoginVerifyHandler.send_report_account_group_log(1, tostring(1), 0, 0, 0, 0)
    return false
  end
  local canChange = SettingAccount.IsChangeAccountBindDaysValid(accountData.mail_bind_time)
  if not canChange then
    local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
    LoginVerifyHandler.send_report_account_group_log(1, tostring(2), 0, 0, 0, 0)
    return false
  end
  if not SettingAccount.IsVerifiedPhoneMail(SettingAccount.ENUM_PANEL_TYPE.Mail) then
    return false
  end
  return true
end
function SettingAccount.CanChangePhone()
  if not accountData.phone_change_state then
    return false
  end
  if accountData.account_type ~= 2 then
    return false
  end
  if not SettingAccount.IsChangeAccountLoginDaysValid() then
    local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
    LoginVerifyHandler.send_report_account_group_log(2, tostring(1), 0, 0, 0, 0)
    return false
  end
  local canChange = SettingAccount.IsChangeAccountBindDaysValid(accountData.phone_bind_time)
  if not canChange then
    local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
    LoginVerifyHandler.send_report_account_group_log(2, tostring(2), 0, 0, 0, 0)
    return false
  end
  if not SettingAccount.IsVerifiedPhoneMail(SettingAccount.ENUM_PANEL_TYPE.Phone) then
    return false
  end
  return true
end
function SettingAccount.IsVerifiedPhoneMail(verifyType)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountPhoneMailVerifyTime)
  if saveData and saveData[tostring(verifyType)] then
    local verifyData = saveData[tostring(verifyType)]
    if verifyData and verifyData.expiresIn and verifyData.verifyTime then
      local TimeUtil = require("client.common.time_util")
      if TimeUtil.UnixTimeBetween(verifyData.verifyTime, verifyData.verifyTime + verifyData.expiresIn) == 0 then
        return true
      end
    end
  end
  return false
end
function SettingAccount.IsChangeAccountLoginDaysValid()
  local need_login_days = accountData.need_login_days
  if not need_login_days or need_login_days < 0 then
    need_login_days = 15
  end
  local login_total_days = accountData.login_total_days
  if not login_total_days or login_total_days < 0 then
    login_total_days = 0
  end
  if need_login_days <= login_total_days then
    login_total_days = need_login_days
  end
  return need_login_days <= login_total_days, login_total_days, need_login_days
end
function SettingAccount.IsChangeAccountBindDaysValid(bind_time)
  local TimeUtil = require("client.common.time_util")
  local cur_server_time = TimeUtil.GetServerTimeInSec()
  local bind_days = 0
  if bind_time and 0 < bind_time then
    bind_days = math.max(0, math.floor((cur_server_time - bind_time) / 86400))
  end
  local need_bind_days = accountData.need_bind_days
  if not need_bind_days or need_bind_days < 0 then
    need_bind_days = 7
  end
  if bind_days >= need_bind_days then
    bind_days = need_bind_days
  end
  return need_bind_days <= bind_days, bind_days, need_bind_days
end
function SettingAccount.PreCheckRequestData()
  local promise = require("common.Promise")
  local LobbyAwaitWithoutCond = promise.Helper.LobbyAwaitWithoutCond
  SettingAccount.myPromise = LobbyAwaitWithoutCond(1, SettingAccount.CheckRequestData)
end
function SettingAccount.CheckRequestData()
  SettingAccount.myPromise = nil
  log(bWriteLog and "  : SettingAccount.CheckRequestData")
  if accountData.need_get_server_info == true and (accountData.show_mail or accountData.show_phone) then
    log(bWriteLog and "request_self_build_account")
    local Handler = require("client.network.Protocol.PhoneMailLoginHandler")
    Handler.request_self_build_account()
    accountData.need_get_server_info = false
  end
  local LogicLoginVerify = require("client.slua.logic.login.logic_login_verify")
  LogicLoginVerify.GetAllDataReq()
end
function SettingAccount.GetRegionAndPhoneCode()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    return "IN", 91
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local region = login_module:GetIpRegion()
  local defaultRegion = "US"
  if region == "" then
    log(bWriteLog and "  : GetRegionAndPhoneCode Default")
    region = defaultRegion
  end
  local phoneCfg = CDataTable.GetTableData("RegionPhoneCfg", region)
  local phone = 1
  if phoneCfg and phoneCfg.Phone ~= 0 then
    phone = phoneCfg.Phone
  end
  if phone == 1 then
    region = defaultRegion
  end
  log(bWriteLog and "  :GetRegionAndPhoneCode :" .. tostring(region))
  return region, phone
end
function SettingAccount.CanShowWhatsAppPhone(No)
  local switch = SettingAccount.WhatsAppPhoneShowCfg[No]
  log(bWriteLog and "SettingAccount.CanShowWhatsAppPhone. switch: " .. tostring(switch))
  if switch == 1 then
    return true
  end
  return false
end
function SettingAccount.IsSafe()
  local strRegion = Client.GetPublishRegion()
  local uSafeCfg = CDataTable.GetTableData("AccountSafeCfg", strRegion)
  if not uSafeCfg then
    log(bWriteLog and "  : not uSafeCfg")
    return true
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local isGuest = IMSDKHelperInstance:IsEqualCurLoginPlatform(ShareSource.Guest)
  if isGuest then
    log(bWriteLog and "  : isGuest Can't BindPhone")
    return true
  end
  local LogicLoginVerify = require("client.slua.logic.login.logic_login_verify")
  if not LogicLoginVerify.IsBindPhoneOpen() then
    log(bWriteLog and "  : Can't BindPhone")
    return true
  end
  log(bWriteLog and "  :data.Phone" .. tostring(uSafeCfg.Phone))
  log(bWriteLog and "  :data.mail" .. tostring(uSafeCfg.Mail))
  log(bWriteLog and "  :data.verify" .. tostring(uSafeCfg.Verify))
  log(bWriteLog and "  :data.All total Score" .. tostring(uSafeCfg.All))
  local score = 0
  local info = SettingAccount.GetSettingAccountData()
  if info.bind_phone then
    score = score + uSafeCfg.Phone
  end
  if info.bind_mail then
    score = score + uSafeCfg.Mail
  end
  if LogicLoginVerify.IsLoginVerifyOpen() then
    score = score + uSafeCfg.Verify
  end
  log(bWriteLog and "  :score" .. tostring(score))
  return score >= uSafeCfg.All
end
function SettingAccount.RpUpgrade(level)
  log(bWriteLog and "  :level" .. tostring(level))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveCfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRPUpgrade)
  local oldLevel = saveCfg and saveCfg.level or level - 1
  local levels = {
    20,
    30,
    40
  }
  log(bWriteLog and "  :oldLevel" .. tostring(oldLevel))
  if level < oldLevel then
    oldLevel = level - 1
    saveCfg = {level = oldLevel}
    log(bWriteLog and "  :saveCfg  oldLevel" .. tostring(oldLevel))
    PlayerPrefsSystem.SaveTableToFile_N(saveCfg, PlayerPrefsSystem.ePlayerPrefsType.eRPUpgrade)
  end
  local isLarge, isLastSmall
  for _, v in ipairs(levels) do
    if v < level then
      isLarge = true
    end
    if v > oldLevel then
      isLastSmall = true
    end
  end
  if isLarge and isLastSmall and SettingAccount.ShowNotSafe(BP_ENUM_SWITCH_ACCOUNT_SAFE_TIP_RP) then
    saveCfg = {level = level}
    PlayerPrefsSystem.SaveTableToFile_N(saveCfg, PlayerPrefsSystem.ePlayerPrefsType.eRPUpgrade)
  end
end
function SettingAccount.SegmentUpgrade(level)
  local strRegion = Client.GetPublishRegion()
  local uSafeCfg = CDataTable.GetTableData("AccountSafeCfg", strRegion)
  log(bWriteLog and "  : SettingAccount.SegmentUpgrade level " .. tostring(level))
  if not uSafeCfg then
    log(bWriteLog and "  : not uSafeCfg")
    return
  end
  local minSegment = uSafeCfg.Segment
  if not minSegment or minSegment == "" then
    log(bWriteLog and "  : SegmentUpgrade not minSegment or minSegment")
    return
  end
  if tonumber(level) < tonumber(minSegment) then
    log(bWriteLog and "  :level " .. tostring(level))
    log(bWriteLog and "  :minSegment " .. tostring(minSegment))
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveCfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountSafe)
  local oldLevel = saveCfg and saveCfg.level or 101
  local rate = 100
  if level // rate <= oldLevel // rate then
    log(bWriteLog and "  :level // rate:" .. tostring(level // rate))
    log(bWriteLog and "  :oldLevel // rate:" .. tostring(oldLevel // rate))
    log(bWriteLog and "  : not SegmentUpgrade")
    return
  end
  if SettingAccount.ShowNotSafe(BP_ENUM_SWITCH_ACCOUNT_SAFE_SEGMENT) then
    saveCfg = {level = level}
    PlayerPrefsSystem.SaveTableToFile_N(saveCfg, PlayerPrefsSystem.ePlayerPrefsType.eAccountSafe)
  end
end
local ResTable = {
  [BP_ENUM_SWITCH_ACCOUNT_SAFE_SEGMENT] = 43514,
  [BP_ENUM_SWITCH_ACCOUNT_SAFE_CENTAURI] = 43515,
  [BP_ENUM_SWITCH_ACCOUNT_SAFE_TIP_ITEM] = 43516,
  [BP_ENUM_SWITCH_ACCOUNT_SAFE_TIP_UP_GUN] = 43517,
  [BP_ENUM_SWITCH_ACCOUNT_SAFE_StealModel] = 47102
}
function SettingAccount.ShowNotSafe(switch)
  log(bWriteLog and "  : SettingAccount.ShowNotSafe " .. tostring(switch))
  if SettingAccount.canBindCode ~= 0 then
    log(bWriteLog and "  : can't bind ShowNotSafe SettingAccount.canBindCode:" .. tostring(SettingAccount.canBindCode))
    return
  end
  if not LobbySystem.CheckOpen(switch) then
    log(bWriteLog and "  :switch not open:" .. tostring(switch))
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local isGuest = IMSDKHelperInstance:IsEqualCurLoginPlatform(ShareSource.Guest)
  if isGuest then
    log(bWriteLog and "[Shine] ShowNotSafe:468: User is Guest.")
    return
  end
  local logicLevelSprint = require("client.slua.logic.activity.newbie.logic_newbie_level_sprint")
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  if logicLevelSprint.IsOpen() and logic_newbie_assist.CheckIsNewbieBanner() then
    log(bWriteLog and "  : CheckIsNewbieBanner ShowNotSafe")
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  if logic_player_return.blockTip then
    log(bWriteLog and "[chub]SettingAccount.ShowNotSafe, logic_player_return.blockTip is true")
    return
  end
  if SettingAccount.IsSafe() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveTimeCfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountSafeNum)
  local curTime = TimeUtil.GetServerTimeInSec()
  if not saveTimeCfg then
    saveTimeCfg = {time = curTime}
    log(bWriteLog and "  :curTime " .. tostring(curTime))
  else
    local lastTime = saveTimeCfg.time or 0
    local strRegion = Client.GetPublishRegion()
    local uSafeCfg = CDataTable.GetTableData("AccountSafeCfg", strRegion)
    local cdSeconds = uSafeCfg.CDTime and uSafeCfg.CDTime * 24 * 3600 or 86400
    log(bWriteLog and "  :lastTime " .. tostring(lastTime))
    log(bWriteLog and "  :curTime " .. tostring(curTime))
    log(bWriteLog and "  :data.CD_time " .. tostring(uSafeCfg.CDTime))
    if curTime < lastTime + cdSeconds then
      log(bWriteLog and "  : lastTime + cdSeconds > curTime")
      return
    end
    saveTimeCfg.time = curTime
  end
  log(bWriteLog and "  : saveTimeCfg showTime" .. tostring(saveTimeCfg.time))
  PlayerPrefsSystem.SaveTableToFile_N(saveTimeCfg, PlayerPrefsSystem.ePlayerPrefsType.eAccountSafeNum)
  SettingAccount.ShowNotSafePopup(switch)
  return true
end
function SettingAccount.ShowNotSafePopup(switch)
  local jumpBtn = {}
  function jumpBtn.callback()
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.AccountSafe_SafeWarning)
    SettingAccount.isFormPopup = true
    local SettingUtil = require("client.slua.logic.setting.setting_util")
    SettingUtil.Enter("Account")
  end
  local titleLocalResId = ResTable[switch]
  titleLocalResId = titleLocalResId or 43513
  log(bWriteLog and "  : ShowNotSafePopup")
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local ConfigTab = {}
  RightPopSystem.CommonPopup(ConfigTab, "", LocUtil.GetLocalizeResStr(titleLocalResId), "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Warn_02_png.Setting_Icon_Warn_02_png", jumpBtn, 10)
end
local HDmpve2ChannelName = {
  [BP_ENUM_PLAYFORM_BGBG] = ShareSource.Facebook,
  [BP_ENUM_PLAYFORM_GAMECENTER] = ShareSource.GameCenter,
  [BP_ENUM_PLAYFORM_GOOGLEPLAY] = ShareSource.GooglePlay,
  [BP_ENUM_PLAYFORM_WX] = ShareSource.Noschat,
  [BP_ENUM_PLAYFORM_TOURIST] = ShareSource.Guest,
  [BP_ENUM_PLAYFORM_VK] = ShareSource.VK,
  [BP_ENUM_PLAYFORM_TWITTER] = ShareSource.Twitter,
  [BP_ENUM_PLAYFORM_LINE] = ShareSource.Line,
  [BP_ENUM_PLAYFORM_BGBGByiTOP] = ShareSource.BgBg,
  [BP_ENUM_PLAYFORM_AppleByiTOP] = ShareSource.Apple,
  [BP_ENUM_PLAYFORM_UnifiedAccountByiTOP] = "unifiedaccount"
}
function SettingAccount.GetNameByHDmpveChannel(channel)
  return channel and HDmpve2ChannelName[channel] or ShareSource.Guest
end
local ChannelId2Name = {
  [BP_ENUM_PLAYFORM_MORE] = ShareSource.More,
  [BP_ENUM_PLAYFORM_WX] = ShareSource.Noschat,
  [BP_ENUM_PLAYFORM_BGBG] = ShareSource.Facebook,
  [BP_ENUM_PLAYFORM_TOURIST] = ShareSource.Guest,
  [BP_ENUM_PLAYFORM_GAMECENTER] = ShareSource.GameCenter,
  [BP_ENUM_PLAYFORM_GOOGLEPLAY] = ShareSource.GooglePlay,
  [BP_ENUM_PLAYFORM_TWITTER] = ShareSource.Twitter,
  [BP_ENUM_PLAYFORM_VK] = ShareSource.VK,
  [BP_ENUM_PLAYFORM_LINE] = ShareSource.Line,
  [BP_ENUM_PLAYFORM_BGBGByiTOP] = ShareSource.BgBg,
  [BP_ENUM_PLAYFORM_AppleByiTOP] = ShareSource.Apple,
  [BP_ENUM_PLAYFORM_UnifiedAccountByiTOP] = "unifiedaccount",
  [BP_ENUM_PLAYFORM_HMSByiTOP] = ShareSource.Hms,
  [BP_ENUM_PLAYFORM_DiscordByiTOP] = ShareSource.Discord,
  [BP_ENUM_PLAYFORM_MIGRATE] = "migrate"
}
function SettingAccount.GetNameByHDmpveChannelId(channelId)
  return ChannelId2Name[channelId] or ShareSource.Guest
end
function SettingAccount.ShowHelpH5()
  local url = FuncUtil.GetDomainByID(3366036) .. "/act/a20210922unbind/index.html?sTicket={itop_ticket}&game_area={game_area}&region={country}&nickname={nickname}&area_id={areaid}&head_pic={head_pic}&gameid={gameid}&version={version}"
  local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
  local ChannelName = SettingAccount.GetNameByHDmpveChannelId(HDmpveChannelID)
  local Unbind_Mgr = require("client.slua.logic.unbind_account.logic_unbind")
  local IMSDKChannelID = Unbind_Mgr.GetChannelIdByLoginPlatform(HDmpveChannelID)
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  url = webModule:AddParameterByPersonalInfo(url)
  local data_enc = webModule:GetEncryptedDeviceInfoUrlValue(2, "&device={device_name}&deviceId={device_id}&scene=1")
  local TimeUtil = require("client.common.time_util")
  url = url .. "&time_zone=" .. tostring(TimeUtil.GetTimeZone())
  url = url .. "&channel_id=" .. IMSDKChannelID
  url = url .. "&channel_name=" .. ChannelName
  url = url .. "&register_time=" .. tostring(DataMgr.registertime)
  url = url .. "&level=" .. tostring(DataMgr.roleData.level)
  url = url .. "&platform=" .. string.lower(Client.GetDevicePlatformName())
  url = url .. "&os_version=" .. DeviceOSInfo.InfoList.SystemSoftware
  url = url .. "&operator=" .. DeviceOSInfo.InfoList.TelecomOper
  url = url .. "&data_enc=" .. data_enc
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(url)
end
function SettingAccount.SetStealModelFlag()
  log(bWriteLog and "[Shine] safeTableData is empty, set Flag.")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = {}
  saveData.notSafePopup = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eAccountSafeStealModelFlag)
end
function SettingAccount.ClearStealModelFlag()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountSafeStealModelFlag)
  if saveData and saveData.notSafePopup then
    log(bWriteLog and "[Shine] Enter the waiting queue, clear Flag.")
    saveData.notSafePopup = false
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eAccountSafeStealModelFlag)
  end
end
function SettingAccount.CheckStealModelFlag()
  log(bWriteLog and "[Shine] safeTableData load done.")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountSafeStealModelFlag)
  if saveData and saveData.notSafePopup then
    log(bWriteLog and "[Shine] has popup, show popup.")
    saveData.notSafePopup = false
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eAccountSafeStealModelFlag)
    SettingAccount.ShowNotSafe(BP_ENUM_SWITCH_ACCOUNT_SAFE_StealModel)
    SettingAccount.ClearStealModelFlag()
  end
end
function SettingAccount.BindSuccess()
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if IMSDKHelperInstance then
    IMSDKHelperInstance:GetBindInfo()
  end
  local msgTitle = LocUtil.GetLocalizeResStr("4045")
  local SettingSystem = require("client.logic.setting.logic_setting")
  local strBindName = SettingSystem.GetNameByImsdkChannel(SettingSystem.NBindChannel, SettingSystem.NBindExtType)
  local msgContent = string.format(DataMgr.GetMultiLineMsgByID(4455), strBindName)
  if SettingAccount.nLoginChannel ~= BP_ENUM_PLAYFORM_TOURIST then
    msgContent = string.format(DataMgr.GetMultiLineMsgByID(4452), strBindName)
  end
  local clickOKCallback = function()
    local LogicLoginVerify = require("client.slua.logic.login.logic_login_verify")
    LogicLoginVerify.PostTLog(strBindName)
    if SettingAccount.nLoginChannel == BP_ENUM_PLAYFORM_TOURIST then
      log(bWriteLog and "EventSettingPanelShowTipMsgBindSuccess clickOKCallback IMSDKRefreshBindUI BP_ENUM_PLAYFORM_TOURIST BP_LoginChannel=" .. SettingAccount.nLoginChannel)
      EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_BINDSUCC)
      local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
      ban_login_module:sendLogoutWithoutLogoutAccount()
    else
      if SettingSystem.NBindChannel == BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT then
        local Handler = require("client.network.Protocol.PhoneMailLoginHandler")
        Handler.request_self_build_account()
        EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_BIND_SUCCESS, strBindName)
      end
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_AREA_BIND_SUCCESS)
      log(bWriteLog and "EventSettingPanelShowTipMsgBindSuccess clickOKCallback IMSDKRefreshBindUI IMSDKRefreshBindUI BP_LoginChannel=" .. SettingAccount.nLoginChannel)
      EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_BINDANDUNBINDINFO)
    end
  end
  local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
  if logic_account_sensitive_aciton:IsGrayNew() then
    function clickOKCallback()
      logic_account_sensitive_aciton:OnBindSuccess()
    end
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, msgTitle, msgContent, clickOKCallback, nil, nil, nil, {clickCloseCallback = clickOKCallback})
end
function SettingAccount.AlreadyBindAskToLogin()
  local msgTitle = LocUtil.GetLocalizeResStr("4045")
  local SettingSystem = require("client.logic.setting.logic_setting")
  local strBindName = SettingSystem.GetNameByImsdkChannel(SettingSystem.NBindChannel)
  local msgContent = string.format(DataMgr.GetMultiLineMsgByID(4456), strBindName, strBindName, strBindName)
  if SettingAccount.nLoginChannel ~= BP_ENUM_PLAYFORM_TOURIST then
    msgContent = string.format(DataMgr.GetMultiLineMsgByID(4453), strBindName)
  end
  local clickOKCallback = function()
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    if SettingAccount.nLoginChannel == BP_ENUM_PLAYFORM_TOURIST then
      login_module:sendLogout()
    end
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, msgTitle, msgContent, clickOKCallback)
end
function SettingAccount.BindFail(toBindChannel, imsdkRetCode, imsdkThirdRetCode)
  local msgTitle = LocUtil.GetLocalizeResStr("4045")
  local SettingSystem = require("client.logic.setting.logic_setting")
  local msgContent = SettingSystem.GetNoticeByThirdCode(toBindChannel, imsdkRetCode, imsdkThirdRetCode)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, msgTitle, msgContent)
end
function SettingAccount.NotifySettingPanelIMSDK()
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local bindRetJson = IMSDKHelperInstance:GetBindRet()
  local bindRet = json.decode(bindRetJson)
  local imsdkRetCode = bindRet.imsdkRetCode
  local imsdkThirdRetCode = bindRet.thirdRetCode
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  if imsdkRetCode == SDKMacros.IMSDKErrorCode.SUCCESS then
    SettingAccount.BindSuccess()
  elseif imsdkRetCode == SDKMacros.IMSDKErrorCode.SERVER_ERROR and imsdkThirdRetCode == SDKMacros.IMSDKServerErrorCode.BIND_OPENID_ALREADY_EXIST then
    SettingAccount.AlreadyBindAskToLogin()
  elseif imsdkRetCode == SDKMacros.IMSDKErrorCode.BIND_CMD_NEED_PROCESS_BY_SVR then
    EventSystem:postEvent(EVENTTYPE_BIND_INTL, EVENTID_INTL_BIND_NEED_SVR_PROCESSS, bindRet)
  else
    SettingAccount.BindFail(bindRet.channel, imsdkRetCode, imsdkThirdRetCode)
  end
end
local channel2ResId = {
  [ShareSource.Facebook] = 27914,
  [ShareSource.Twitter] = 27915,
  [ShareSource.Noschat] = 27916,
  [ShareSource.VK] = 27917,
  [ShareSource.GooglePlay] = 27918,
  [ShareSource.GameCenter] = 27919,
  [ShareSource.Line] = 27920,
  [ShareSource.BgBg] = 27921,
  [ShareSource.Hms] = 27922,
  [ShareSource.Discord] = 27923,
  [ShareSource.Apple] = 19768,
  [ShareSource.unifiedaccount] = 27924,
  [ShareSource.Google] = 27918,
  [ShareSource.Guest] = 27913,
  [ShareSource.Whatsapp] = 75328,
  [ShareSource.TikTok] = 86616
}
function SettingAccount.GetPlatformDisplayName(strChannel)
  local locResId = channel2ResId[strChannel]
  if not locResId then
    return "QR Code"
  end
  return LocUtil.GetLocalizeResStr(locResId)
end
function SettingAccount.GetAllQRCodeLoginResults()
  if IsEditor then
    return {
      {
        guid_open_id = 123,
        guid_token_expire = 1717648116,
        guid_channel_id = 31
      },
      {
        guid_open_id = 456,
        guid_token_expire = 1717748116,
        guid_channel_id = 31
      },
      {
        guid_open_id = 789,
        guid_token_expire = 1717848116,
        guid_channel_id = 31
      }
    }
  end
  local IMSDKHelper = import("IMSDKHelper")
  local ret = IMSDKHelper.GetInstance():GetAllQRCodeLoginResults()
  log_warning(bWriteLog and "  SettingAccount.GetAllQRCodeLoginResults: " .. tostring(ret))
  local retJson = json.decode(ret)
  return retJson and retJson.AllQRCodeLoginResults or {}
end
function SettingAccount.SetScanData(data)
  SettingAccount.savedScanData = data
  log_tree("  SettingAccount.SaveScanData. data ", data)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eScanLogin)
end
function SettingAccount.ResetSavedScanData()
  log(bWriteLog and "  SettingAccount.ResetSavedScanData.  ")
  local AllQRCodeLoginResults = SettingAccount.GetAllQRCodeLoginResults()
  local NMaxNum = 11
  local myOpenId = tostring(DataMgr.roleData.openID)
  local sort_util = require("common.sort_util")
  sort_util.SortByNumber(AllQRCodeLoginResults, true, "guid_token_expire")
  local len = #AllQRCodeLoginResults
  if NMaxNum < len then
    for _ = 1, len - NMaxNum do
      table.remove(AllQRCodeLoginResults)
    end
  end
  local needOpenIdTb = {
    [myOpenId] = 1
  }
  for _, v in ipairs(AllQRCodeLoginResults) do
    needOpenIdTb[tostring(v)] = 1
  end
  local saved = SettingAccount.savedScanData
  for id2s, _ in pairs(SettingAccount.savedScanData) do
    if not needOpenIdTb[id2s] then
      saved[id2s] = nil
    end
  end
end
function SettingAccount.LoadScanData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  SettingAccount.savedScanData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eScanLogin)
  if not SettingAccount.savedScanData or not next(SettingAccount.savedScanData) then
    SettingAccount.savedScanData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eScanLoginOld)
  end
  log_tree("  SettingAccount.LoadScanData. data ", SettingAccount.savedScanData)
end
function SettingAccount.Logout()
  log(bWriteLog and "SettingAccount.Logout")
  local logic_maincity_minilobby_report = require("GameLua.Mod.MainCity.Client.logic.MiniLobby.logic_maincity_minilobby_report")
  local CloseType = logic_maincity_minilobby_report.CloseTypeTable.DisconnectClose
  logic_maincity_minilobby_report.SetAndReportUseTime(CloseType)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:sendLogout()
  Client.ClearChannelID(NetInterface)
  Client.EnableIosStuckWork(GameFrontendHUD, false)
  Client.CrashLog(NetInterface, 4, "Login", "LogoutE")
end
function SettingAccount.ShowLogout()
  local IMSDKQRCodeSystem = require("client.logic.login.logic_imsdk_qrcode")
  local isQRCode = IMSDKQRCodeSystem:IsQRCodeLogined()
  if not isQRCode and not GlobalData.IsBLUEHOLE() then
    UIManager.ShowUI(UIManager.UI_Config.Com_MsgBox_Slua_checkout__UIBP)
    return
  end
  local LogoutFunc = function()
    SettingAccount.DeleteQRCodeLogin()
    SettingAccount.Logout()
  end
  local logic_common_msg_box = require("client.slua.logic.common.logic_common_msg_box")
  logic_common_msg_box.Show(2, LocUtil.GetLocalizeResStr(86062), LocUtil.GetLocalizeResStr(86061), LogoutFunc)
end
function SettingAccount.SwitchAccountLogin()
  local LogoutFunc = function()
    SettingAccount.Logout()
  end
  local logic_common_msg_box = require("client.slua.logic.common.logic_common_msg_box")
  logic_common_msg_box.Show(2, LocUtil.GetLocalizeResStr(86063), LocUtil.GetLocalizeResStr(86060), LogoutFunc)
end
function SettingAccount.DeleteQRCodeLogin()
  local AllQRCodeLoginResults = SettingAccount.GetAllQRCodeLoginResults() or {}
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  for _, account in ipairs(AllQRCodeLoginResults) do
    local openId = account.guid_open_id
    log(bWriteLog and "[xcc]SettingAccount:DeleteQRCodeLogin  " .. tostring(openId))
    IMSDKHelperInstance:LogoutQRCode(openId)
  end
end
function SettingAccount.IsPassWardError(pass, len)
  if len < 8 then
    return 180049
  end
  local StringUtil = require("common.string_util")
  if not StringUtil.CheckStringLegal(pass, 3) then
    return 180050
  end
  return false
end
function SettingAccount.ClientLogout()
  log_warning(bWriteLog and "  SettingAccount.ClientLogout.  ")
  Client.Logout(NetInterface)
  local WinLoginSystem = require("client.logic.login.logic_winlogin")
  local cacheData = WinLoginSystem.ClearMailLoginCache()
end
function SettingAccount.CanBindMore()
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local bindCount = IMSDKHelperInstance:GetBindCount()
  if 2 <= bindCount then
    log(bWriteLog and "SettingAccount.CanBindMore.  bindCount >= 2")
    return false
  end
  local mailInfo = SettingAccount.GetSettingAccountData()
  local state = mailInfo.award_state_mail
  log(bWriteLog and "GetBindAbleSocialEmails CanBindMore : state" .. tostring(state))
  if state == 1 or state == 2 then
    return false
  end
  local phoneState = mailInfo.award_state_phone
  if phoneState == 1 or phoneState == 2 then
    return false
  end
  return true
end
function SettingAccount.GetBindAbleSocialEmails()
  local mailInfo = SettingAccount.GetSettingAccountData()
  local state = mailInfo.award_state_mail
  log(bWriteLog and "GetBindAbleSocialEmails mailInfo : state" .. tostring(state))
  if state == 1 or state == 2 then
    return {}
  end
  local phoneState = mailInfo.award_state_phone
  if phoneState == 1 or phoneState == 2 then
    return {}
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountBindSocialRemind)
  local time = saveData and saveData.time or 0
  local TimeUtil = require("client.common.time_util")
  local isWithInOneDay = TimeUtil.WithinInNDay(time, 3)
  if not isWithInOneDay then
    log(bWriteLog and "SettingAccount.GetBindAbleSocialEmails. isWithInOneDay ")
    return nil
  end
  local result
  if saveData and saveData.emails and next(saveData.emails) then
    result = {}
    local num = 0
    for _, v in ipairs(saveData.emails) do
      if v.canBind == 1 then
        result[#result + 1] = v
        num = num + 1
        if 2 <= num then
          break
        end
      end
    end
  end
  if not result and time ~= 0 then
    log(bWriteLog and "SettingAccount.GetBindAbleSocialEmails.  has sent email, but no result")
    return {}
  end
  log_tree("SettingAccount.GetBindAbleSocialEmails. result ", result)
  return result
end
return SettingAccount