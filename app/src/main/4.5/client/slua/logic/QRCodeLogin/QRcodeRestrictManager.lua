local QRcodeRestrictManager = {}
function QRcodeRestrictManager:DefineAndResetData()
  self:_ResetData()
end
function QRcodeRestrictManager:_ResetData()
  log(bWriteLog and "  QRcodeRestrictManager:_ResetData.  ")
  self.isRestrictUC = false
  self.isRestrictGift = false
  self.isRestrictSocial = false
  self.isRestrictChat = false
  self.restrictBattle = 0
  self.restrictWareHouse = 0
  self.isRestrictManor = false
  self.bUseQRCodeLogin = false
  self.canScanQRCode = false
  self.canScanQRCodeGray = false
  self.isTestScanQRCode = false
  self.preLimitInfo = nil
  self.inviteFriendName = nil
  self.isRestrictWow = false
end
function QRcodeRestrictManager:_ShowTips(tips)
  UIManager.ShowUI(UIManager.UI_Config.QRCode_Restrict_Pop_UIBP, tips)
end
function QRcodeRestrictManager:_SetLimitInfo(limit_info)
  if not limit_info then
    return
  end
  log_tree("setLimitInfo:", limit_info)
  self.isRestrictUC = limit_info[1] == 1
  self.isRestrictGift = limit_info[2] == 1
  self.isRestrictSocial = limit_info[3] == 1
  self.isRestrictChat = limit_info[4] == 1
  self.restrictBattle = limit_info[5] or 0
  self.restrictWareHouse = limit_info[6] or 1
  if not limit_info[7] then
    self.isRestrictManor = true
  else
    self.isRestrictManor = limit_info[7] == 1
  end
  self.isRestrictWow = limit_info[8] == 1
  if self.bUseQRCodeLogin then
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_RESTRICT_CHANGE)
  end
end
function QRcodeRestrictManager:_GetLimitInfo()
  local limit_info = {
    1,
    1,
    1,
    1,
    1,
    0,
    0,
    1
  }
  if not self.isRestrictUC then
    limit_info[1] = 0
  end
  if not self.isRestrictWow then
    limit_info[8] = 0
  end
  if not self.isRestrictGift then
    limit_info[2] = 0
  end
  if not self.isRestrictSocial then
    limit_info[3] = 0
  end
  if not self.isRestrictChat then
    limit_info[4] = 0
  end
  if self.restrictBattle then
    limit_info[5] = self.restrictBattle
  end
  if self.restrictWareHouse then
    limit_info[6] = self.restrictWareHouse
  end
  if self.isRestrictManor then
    limit_info[7] = 1
  end
  return limit_info
end
function QRcodeRestrictManager:OnLogOut()
  self:_ResetData()
end
function QRcodeRestrictManager:ShowRestrictTips()
  log(bWriteLog and "QRcodeRestrictManager:ShowRestrictTips!")
  local content = LocUtil.GetLocalizeResStr(200000087)
  self:_ShowTips(content)
end
function QRcodeRestrictManager:SetPreLimitInfo()
  self.preLimitInfo = self:_GetLimitInfo()
end
function QRcodeRestrictManager:CheckShopBuyRestrictByMoneyType(moneyType)
  local ucType = 2
  if moneyType ~= ucType then
    return false
  end
  if self:IsRestrictUC() then
    self:ShowRestrictTips()
    return true
  end
  return false
end
function QRcodeRestrictManager:IsRestrictUC()
  return self.isRestrictUC and self.bUseQRCodeLogin
end
function QRcodeRestrictManager:SetUCRestrict(isRestrict)
  self.isRestrictUC = isRestrict
end
function QRcodeRestrictManager:CheckUCRestrict()
  local isRestrict = self:IsRestrictUC()
  log(bWriteLog and "QRcodeRestrictManager:CheckUCRestrict " .. tostring(isRestrict))
  if isRestrict then
    self:ShowRestrictTips()
    return true
  end
  return false
end
function QRcodeRestrictManager:IsRestrictGift()
  return self.isRestrictGift and self.bUseQRCodeLogin
end
function QRcodeRestrictManager:SetGiftRestrict(isRestrict)
  self.isRestrictGift = isRestrict
end
function QRcodeRestrictManager:CheckGiftRestrict()
  local isRestrict = self:IsRestrictGift()
  log(bWriteLog and "QRcodeRestrictManager:CheckGiftRestrict " .. tostring(isRestrict))
  if isRestrict then
    self:ShowRestrictTips()
    return true
  end
  return false
end
function QRcodeRestrictManager:IsRestrictSocial()
  return self.isRestrictSocial and self.bUseQRCodeLogin
end
function QRcodeRestrictManager:SetSocialRestrict(isRestrict)
  log(bWriteLog and "QRcodeRestrictManager:SetSocialRestrict " .. tostring(isRestrict))
  self.isRestrictSocial = isRestrict
end
function QRcodeRestrictManager:CheckSocialRestrict()
  local isRestrict = self:IsRestrictSocial()
  log(bWriteLog and "QRcodeRestrictManager:CheckSocialRestrict " .. tostring(isRestrict))
  if isRestrict then
    self:ShowRestrictTips()
    return true
  end
  return false
end
function QRcodeRestrictManager:IsRestrictDepotCheck()
  return self.restrictWareHouse == 2 and self.bUseQRCodeLogin
end
function QRcodeRestrictManager:IsRestrictDepotDecompose()
  return (self.restrictWareHouse == 1 or self.restrictWareHouse == 2) and self.bUseQRCodeLogin
end
function QRcodeRestrictManager:GetRestrictDepot()
  if self.restrictWareHouse then
    return self.restrictWareHouse
  end
  return 0
end
function QRcodeRestrictManager:SetWareHouseRestrict(restrict)
  self.restrictWareHouse = restrict
  if self.bUseQRCodeLogin then
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_RESTRICT_CHANGE)
  end
end
function QRcodeRestrictManager:IsRestrictChat()
  return self.isRestrictChat and self.bUseQRCodeLogin
end
function QRcodeRestrictManager:SetChatRestrict(isRestrict)
  log(bWriteLog and "QRcodeRestrictManager:SetChatRestrict " .. tostring(isRestrict))
  self.isRestrictChat = isRestrict
end
function QRcodeRestrictManager:CheckChatRestrict()
  local isRestrict = self:IsRestrictChat()
  log(bWriteLog and "QRcodeRestrictManager:CheckChatRestrict " .. tostring(isRestrict))
  if isRestrict then
    self:ShowRestrictTips()
    return true
  end
  return false
end
function QRcodeRestrictManager:IsRestrictBatlleAll()
  local isRestrict = self.restrictBattle == 2 and self.bUseQRCodeLogin
  log(bWriteLog and "QRcodeRestrictManager:IsRestrictBatlleAll " .. tostring(isRestrict))
  return isRestrict
end
function QRcodeRestrictManager:IsRestrictBatlleRank()
  return (self.restrictBattle == 1 or self.restrictBattle == 2) and self.bUseQRCodeLogin
end
function QRcodeRestrictManager:GetRestrictBattle()
  if self.restrictBattle then
    return self.restrictBattle
  end
  return 0
end
function QRcodeRestrictManager:SetRestrictBattle(restrict)
  self.restrictBattle = restrict
  if self.bUseQRCodeLogin then
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_RESTRICT_CHANGE)
  end
end
function QRcodeRestrictManager:IsRestirctManor()
  local isRestrict = self.isRestrictManor and self.bUseQRCodeLogin
  log(bWriteLog and "QRcodeRestrictManager:IsRestirctManor " .. tostring(isRestrict))
  return isRestrict
end
function QRcodeRestrictManager:SetManorRestirct(isRestrict)
  log(bWriteLog and "QRcodeRestrictManager:SetManorRestirct " .. tostring(isRestrict))
  self.isRestrictManor = isRestrict
end
function QRcodeRestrictManager:CheckManorRestrict()
  local isRestrict = self:IsRestirctManor()
  log(bWriteLog and "QRcodeRestrictManager:CheckManorRestrict " .. tostring(isRestrict))
  if isRestrict then
    self:ShowRestrictTips()
    return true
  end
  return false
end
function QRcodeRestrictManager:SetInviteFriendInfo(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile then
    self.inviteFriendName = profile.nickName
  else
    log(bWriteLog and "QRcodeRestrictManager:SetInviteFriendInfo profile = nil ")
  end
end
function QRcodeRestrictManager:ShowFriendManorRestrictNotice()
  if not self.inviteFriendName then
    return
  end
  local restrictNotice = LocUtil.LocalizeResFormat(200000147, self.inviteFriendName)
  ShowNotice(restrictNotice)
end
function QRcodeRestrictManager:IsRestrictWow()
  return self.isRestrictWow and self.bUseQRCodeLogin
end
function QRcodeRestrictManager:SetWowRestrict(isRestrict)
  log(bWriteLog and "QRcodeRestrictManager:SetWowRestrict " .. tostring(isRestrict))
  self.isRestrictWow = isRestrict
end
function QRcodeRestrictManager:CheckWowRestrict()
  local isRestrict = self:IsRestrictWow()
  log(bWriteLog and "QRcodeRestrictManager:CheckWowRestrict " .. tostring(isRestrict))
  if isRestrict then
    self:ShowRestrictTips()
    return true
  end
  return false
end
function QRcodeRestrictManager:CanScanQRCode()
  return self.canScanQRCode
end
function QRcodeRestrictManager:CanScanQRCodeGray()
  return self.canScanQRCodeGray
end
function QRcodeRestrictManager:IsQRCodeLogin()
  return self.bUseQRCodeLogin
end
function QRcodeRestrictManager:IsTestScanQRCode()
  return self.isTestScanQRCode
end
function QRcodeRestrictManager:IsPUBGMQRCode(codeId)
  local StringUtil = require("common.string_util")
  local parts = StringUtil.Split(codeId, "-")
  if #parts ~= 3 then
    log(bWriteLog and "logic_qr_code:IsPUBGMQRCode return of Invalid format: must be three parts separated by '-'.")
    return false
  end
  if not parts[1] then
    log(bWriteLog and "logic_qr_code:IsPUBGMQRCode return of First part nil.")
    return
  end
  if not StringUtil.CheckStringLegal(tonumber(parts[1]), 2) then
    log(bWriteLog and "logic_qr_code:IsPUBGMQRCode return of First part must be numeric.")
    return false
  end
  if StringUtil.GetCharactersLength(parts[3]) ~= 32 then
    log(bWriteLog and "logic_qr_code:IsPUBGMQRCode return of Third part must be exactly 32 characters long.")
    return false
  end
  local gameId = tostring(Client.GetITopGameId())
  if parts[1] ~= gameId then
    log(bWriteLog and "logic_qr_code:IsPUBGMQRCode return of Game ID does not match the current device's Game ID.")
    return false
  end
  return true, parts
end
function QRcodeRestrictManager:HandleQRCodeResult(resultStr, from)
  log(bWriteLog and "QRcodeRestrictManager:HandleQRCodeResult:" .. tostring(resultStr))
  local isPUBGMQRCode, parts = self:IsPUBGMQRCode(resultStr)
  if not isPUBGMQRCode then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local title = LocUtil.GetLocalizeResStr(200000062)
    CommonMsgBoxMgr.Show(2, title, LocUtil.GetLocalizeResStr(200000064))
    return
  end
  local SendScan = function()
    log(bWriteLog and "  SendScan.  ")
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    local params = IMSDKHelperInstance:GetIMSDKClientApiParams()
    local LoginHandler = require("client.network.Protocol.LoginHandler")
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    local qrcodeTime = SettingAccount.qrcodeTime
    if parts[2] == "1" then
      qrcodeTime = 7
    end
    log(bWriteLog and "SendScan. qrcodeTime: " .. tostring(qrcodeTime))
    LoginHandler.send_start_scan_qrcode_req(resultStr, qrcodeTime, params)
  end
  if parts[2] == "1" then
    local title = LocUtil.GetLocalizeResStr(200000546)
    local content = LocUtil.GetLocalizeResStr(200000547)
    local content2 = LocUtil.GetLocalizeResStr(200000553) .. "\n" .. LocUtil.GetLocalizeStrConcatenation(200000554) .. "\n" .. LocUtil.GetLocalizeStrConcatenation(180048)
    UIManager.ShowUI(UIManager.UI_Config.Setting_WebPage_Authorization_Popup_UIBP, title, content, content2, SendScan)
  else
    local SendLoginScan = function()
      log(bWriteLog and "  SendLoginScan.  ")
      UIManager.ShowUI(UIManager.UI_Config.Setting_ScanningProcessing_UIBP)
      SendScan()
    end
    UIManager.ShowUI(UIManager.UI_Config.Setting_Code_Authorization_Popup_UIBP, SendLoginScan)
  end
end
function QRcodeRestrictManager:on_start_scan_qrcode_rsp(errcode, b_web_scan, device_name, expire_tm)
  log(bWriteLog and string.format("QRcodeRestrictManager:on_start_scan_qrcode_rsp errcode = %s b_web_scan = %s, device_name %s", tostring(errcode), tostring(b_web_scan), device_name))
  UIManager.CloseUI(UIManager.UI_Config.Setting_ScanningProcessing_UIBP)
  if errcode == 0 and b_web_scan then
    local title = LocUtil.GetLocalizeResStr(200000068)
    local TimeUtil = require("client.common.time_util")
    local ext_info = TimeUtil.GetServerTimeInSec() + 604800
    local text = LocUtil.LocalizeFormatConcatenation(200000551, tostring(device_name), TimeUtil.FormatTime_YMDHMS(ext_info, false, true)) .. LocUtil.GetLocalizeResStr(200000552)
    local content2 = LocUtil.GetLocalizeResStr(200000553) .. "\n" .. LocUtil.GetLocalizeStrConcatenation(200000554) .. "\n" .. LocUtil.GetLocalizeStrConcatenation(180048)
    UIManager.ShowUI(UIManager.UI_Config.Login_QRCode_Success_Popup_UIBP, title, text, content2)
    return
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local title = LocUtil.GetLocalizeResStr(200000062)
  if errcode == 100150042 or errcode == 100150052 then
    CommonMsgBoxMgr.Show(2, title, LocUtil.GetLocalizeResStr(200000064))
  elseif errcode == 100150041 or errcode == 100150043 or errcode == 100150044 or errcode == 100150046 then
    CommonMsgBoxMgr.Show(2, title, LocUtil.GetLocalizeResStr(200000066) .. tostring(errcode))
  elseif errcode == 100150053 then
    CommonMsgBoxMgr.Show(2, title, LocUtil.GetLocalizeResStr(200000065))
  elseif errcode == 100150054 then
    CommonMsgBoxMgr.Show(2, title, LocUtil.GetLocalizeResStr(200000067))
  elseif errcode == 511035 then
    local Content = LocUtil.GetLocalizeResStr(8888888)
    local ExtraData = {
      urlTips = LocUtil.GetLocalizeResStr(8888889),
      urlHandle = function()
        if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_UGC_AUTHOR_VERIFY_ENTRANCE) then
          ShowNotice(116009)
          return
        end
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        local bOpen = LogicUGC:IsWOWOpen()
        if not bOpen then
          ShowNotice(511201)
          return
        end
        local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
        LogicUGCCommunity:JumpToAuthorCertification()
      end
    }
    CommonMsgBoxMgr.Show(2, title, Content, nil, nil, nil, nil, ExtraData)
  elseif errcode == 511092 then
    CommonMsgBoxMgr.Show(2, title, LocUtil.GetLocalizeResStr(1050294))
  elseif errcode == 100150057 then
    CommonMsgBoxMgr.Show(2, title, LocUtil.GetLocalizeResStr(8888890))
  elseif errcode == 100150058 then
    local Content = LocUtil.GetLocalizeResStr(8888903)
    local ExtraData = {
      urlTips = LocUtil.GetLocalizeResStr(8888904),
      urlHandle = function()
        if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_UGC_AUTHOR_VERIFY_ENTRANCE) then
          ShowNotice(116009)
          return
        end
        local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
        local Config_UGC_Center_TabID = Config_UGC_Center.Config_UGC_Center_TabID
        local logic_ugc_center = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
        logic_ugc_center:OpenUGCCenterMainUI(Config_UGC_Center_TabID.CreatorsGrow, Config_UGC_Center_TabID.Level)
      end
    }
    CommonMsgBoxMgr.Show(2, title, Content, nil, nil, nil, nil, ExtraData)
  elseif errcode == 100150059 then
    CommonMsgBoxMgr.Show(2, title, LocUtil.GetLocalizeResStr(8888905))
  elseif errcode ~= 0 then
    CommonMsgBoxMgr.Show(2, title, LocUtil.LocalizeResFormat(200000117, tostring(errcode)))
  end
end
function QRcodeRestrictManager:SendQRCodeLoginLimitReq()
  local LoginHandler = require("client.network.Protocol.LoginHandler")
  local limit_info = self:_GetLimitInfo()
  log_tree("req limit_info :", limit_info)
  LoginHandler.send_qrcode_login_func_limit_req(limit_info)
end
function QRcodeRestrictManager:on_qrcode_login_func_limit_rsp(limit_info)
  if not limit_info and self.preLimitInfo then
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_RESTRICT_SETTING_CHANGE, self.preLimitInfo)
    return
  end
  self:_SetLimitInfo(limit_info)
end
function QRcodeRestrictManager:send_get_qrcode_login_data_req()
  log(bWriteLog and "QRcodeRestrictManager:send_get_qrcode_login_data_req")
  local LoginHandler = require("client.network.Protocol.LoginHandler")
  LoginHandler.send_get_qrcode_login_data_req()
end
function QRcodeRestrictManager:on_get_qrcode_login_data_rsp(can_scan_qrcode, qrcode_login_info, can_scan_qrcode_gray)
  self.canScanQRCode = can_scan_qrcode or false
  self.canScanQRCodeGray = can_scan_qrcode_gray or false
  local IMSDKQRCodeSystem = require("client.logic.login.logic_imsdk_qrcode")
  local isQRCode = IMSDKQRCodeSystem:IsQRCodeLogined()
  self.bUseQRCodeLogin = isQRCode or false
  log(bWriteLog and "QRcodeRestrictManager:on_get_qrcode_login_data_rsp can_scan_qrcode = " .. tostring(can_scan_qrcode))
  log(bWriteLog and "QRcodeRestrictManager:on_get_qrcode_login_data_rsp can_scan_qrcode_gray = " .. tostring(can_scan_qrcode_gray))
  if qrcode_login_info and qrcode_login_info.limit_info then
    self:_SetLimitInfo(qrcode_login_info.limit_info)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, QRcodeRestrictManager)
return CModuleTemplate