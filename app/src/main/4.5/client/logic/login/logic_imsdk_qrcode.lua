local IMSDKQRCodeSystem = {
  bRegistEvents = false,
  QRCodeQueryTimer = nil,
  QRCodeQueryMaxLoopTime = 1200,
  QRCodeQueryQueryInterval = 2,
  QRCodeId = nil,
  QRCodeRanStr = nil,
  QRCodeIMSDKLoginChannel = nil,
  expireTime = 0,
  nextTime = 0
}
local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
local IMSDKErrorCode = SDKMacros.IMSDKErrorCode
local IMSDKQRCodeStatus = SDKMacros.IMSDKQRCodeStatus
function IMSDKQRCodeSystem:RegistEvents()
  log(bWriteLog and "IMSDKQRCodeSystem:RegistEvents")
  if IMSDKQRCodeSystem.bRegistEvents then
    log(bWriteLog and "IMSDKQRCodeSystem:RegistEvents already")
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance.OnGenerateQRCodeNotify:Clear()
  IMSDKHelperInstance.OnGenerateQRCodeNotify:Add(function(retJson, QRCodeTexture)
    log(bWriteLog and "IMSDKQRCodeSystem.OnGenerateQRCodeNotify: " .. retJson)
    self:OnGenerateQRCodeNotify(json.decode(retJson), QRCodeTexture)
  end)
  IMSDKHelperInstance.OnQRCodeStatusNotify:Clear()
  IMSDKHelperInstance.OnQRCodeStatusNotify:Add(function(retJson)
    log(bWriteLog and "IMSDKQRCodeSystem.OnQRCodeStatusNotify: " .. retJson)
    self:OnQRCodeStatusNotify(json.decode(retJson))
  end)
  IMSDKHelperInstance.OnInvalidateQRCodeNotify:Clear()
  IMSDKHelperInstance.OnInvalidateQRCodeNotify:Add(function(retJson)
    log(bWriteLog and "IMSDKQRCodeSystem.OnInvalidateQRCodeNotify: " .. retJson)
    self:OnInvalidateQRCodeNotify(json.decode(retJson))
  end)
  IMSDKQRCodeSystem.bRegistEvents = true
end
function IMSDKQRCodeSystem:UnRegistEvents()
  log(bWriteLog and "IMSDKQRCodeSystem:UnRegistEvents")
  if not IMSDKQRCodeSystem.bRegistEvents then
    log(bWriteLog and "IMSDKQRCodeSystem:UnRegistEvents not found")
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance.OnGenerateQRCodeNotify:Clear()
  IMSDKHelperInstance.OnQRCodeStatusNotify:Clear()
  IMSDKHelperInstance.OnInvalidateQRCodeNotify:Clear()
  IMSDKQRCodeSystem.bRegistEvents = false
end
function IMSDKQRCodeSystem:GenerateQRCode(extraData)
  log(bWriteLog and "IMSDKQRCodeSystem:GenerateQRCode")
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local brand = Client.GetDeviceMake()
  local model = Client.GetDeviceModel()
  local devicename = Client.GetDeivceNickName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    local hardwareInfo = Client.GetPhoneType()
    local StringUtil = require("common.string_util")
    local hardwareInfoArr = StringUtil.Split(hardwareInfo, "+")
    if 2 <= #hardwareInfoArr then
      brand = hardwareInfoArr[1]
    end
  end
  if extraData == nil then
    extraData = {}
  end
  extraData.  extraData.  extraData.  local strExtraJson = json.encode(extraData)
  log(bWriteLog and "IMSDKQRCodeSystem:GenerateQRCode: " .. strExtraJson)
  IMSDKHelperInstance:GenerateQRCode(strExtraJson)
end
function IMSDKQRCodeSystem:QueryQRCodeStatus(codeId, ranStr, extraData)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if extraData == nil then
    extraData = {}
  end
  if codeId == nil then
    codeId = IMSDKQRCodeSystem.QRCodeId
  end
  if ranStr == nil then
    ranStr = IMSDKQRCodeSystem.QRCodeRanStr
  end
  local strExtraJson = json.encode(extraData)
  log(bWriteLog and "IMSDKQRCodeSystem:QueryQRCodeStatus: " .. codeId .. ", " .. ranStr .. ", " .. strExtraJson)
  IMSDKHelperInstance:QueryQRCodeStatus(codeId, ranStr, strExtraJson)
end
function IMSDKQRCodeSystem:InvalidateQRCode(codeId, ranStr, extraData)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if extraData == nil then
    extraData = {}
  end
  if codeId == nil or codeId == "" then
    codeId = IMSDKQRCodeSystem.QRCodeId
  end
  if ranStr == nil or ranStr == "" then
    ranStr = IMSDKQRCodeSystem.QRCodeRanStr
  end
  local strExtraJson = json.encode(extraData)
  log(bWriteLog and "IMSDKQRCodeSystem:InvalidateQRCode: " .. tostring(codeId) .. ", " .. tostring(ranStr) .. ", " .. strExtraJson)
  if codeId == nil or codeId == "" or ranStr == nil or ranStr == "" then
    log(bWriteLog and "IMSDKQRCodeSystem:InvalidateQRCode: return by param invalid")
  else
    IMSDKHelperInstance:InvalidateQRCode(codeId, ranStr, strExtraJson)
  end
  self:ClearQRCodeData()
end
function IMSDKQRCodeSystem:QRCodeLogin(imsdkChannelName)
  log(bWriteLog and "IMSDKQRCodeSystem:QRCodeLogin: " .. tostring(imsdkChannelName))
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local imsdkChannelId = IMSDKHelperInstance:ConvertStrToIMSDKChannel(imsdkChannelName)
  IMSDKHelperInstance:SetupLoginCacheInfo(imsdkChannelId, true)
  IMSDKHelperInstance:SetChannel(imsdkChannelName)
  local imsdkLoginResult = IMSDKHelperInstance:GetLoginResult()
  if imsdkLoginResult.imsdkRetCode ~= IMSDKErrorCode.SUCCESS then
    log(bWriteLog and "IMSDKQRCodeSystem:QRCodeLogin GetLoginResult imsdkRetCode: " .. imsdkLoginResult.imsdkRetCode)
    local title = DataMgr.GetMsgByID(101001)
    local notice = DataMgr.GetMsgByID(101205)
    notice = notice .. string.format(" (%d,%d)", imsdkLoginResult.imsdkRetCode, imsdkLoginResult.thirdRetCode)
    if imsdkLoginResult.thirdRetCode == 2001 then
      notice = DataMgr.GetMsgByID(200000149)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, notice)
    return
  end
  local tcondChannelId = IMSDKHelperInstance:ConvertIMSDKChannel2TConndChannel(imsdkChannelId)
  local game_frontend_hud = require("game_frontend_hud")
  local HUD = game_frontend_hud.GetInstance()
  HUD:OnLoginFlowNotify(0, tcondChannelId + 100, "")
  local StatManager = import("StatManager")
  StatManager.GetInstance():ReportEventWithNoParam(23, true)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:SethasLogout(false)
  local IMSDKSystem = require("client.logic.login.logic_imsdk")
  IMSDKSystem.StartIMSDKTimer(2)
  IMSDKHelperInstance:QuickLogin()
end
function IMSDKQRCodeSystem:IsQRCodeLogined()
  log(bWriteLog and "IMSDKQRCodeSystem:IsQRCodeLogined")
  local isQRCodeLogined = false
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local imsdkLoginToken = IMSDKHelperInstance:GetIMSDKLoginToken()
  if imsdkLoginToken ~= nil and 2 <= #imsdkLoginToken and string.sub(imsdkLoginToken, 1, 2) == "FF" then
    isQRCodeLogined = true
  end
  log(bWriteLog and "IMSDKQRCodeSystem:IsQRCodeLogined isQRCodeLogin " .. tostring(isQRCodeLogined))
  return isQRCodeLogined
end
function IMSDKQRCodeSystem:OnGenerateQRCodeNotify(genResult, QRCodeTexture)
  if genResult.imsdkRetCode == IMSDKErrorCode.SUCCESS then
    IMSDKQRCodeSystem.QRCodeId = genResult.codeId
    IMSDKQRCodeSystem.QRCodeRanStr = genResult.randStr
    IMSDKQRCodeSystem.QRCodeQueryQueryInterval = genResult.queryInterval
    log_warning(bWriteLog and "  IMSDKQRCodeSystem:OnGenerateQRCodeNotify. genResult.expireAt: " .. tostring(genResult.expireAt))
    IMSDKQRCodeSystem.expireTime = genResult.expireAt
    IMSDKQRCodeSystem.nextTime = genResult.nextAt
    self:StopQueryQRCodeTimer()
    self:StartQueryQRCodeTimer()
  else
    local noticeMsg = LocUtil.GetLocalizeResStr(100150050)
    noticeMsg = noticeMsg .. string.format(" (%d,%d)", genResult.imsdkRetCode, genResult.thirdRetCode)
    ShowNotice(noticeMsg)
  end
  EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_GEN, genResult, QRCodeTexture)
end
function IMSDKQRCodeSystem:OnQRCodeStatusNotify(queryResult)
  EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_REFRESH, queryResult)
  if queryResult.imsdkRetCode == IMSDKErrorCode.SUCCESS then
    if IMSDKQRCodeStatus.LOGINED == queryResult.status then
      if GameStatus.GetGameStatus() == GameStatus.Login then
        IMSDKQRCodeSystem.QRCodeIMSDKLoginChannel = queryResult.channel
        local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
        login_module:SetJustScanLogin(true)
        self:QRCodeLogin(IMSDKQRCodeSystem.QRCodeIMSDKLoginChannel)
      else
        local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
        login_module:BackLoginWithCallback(function()
          log_warning(bWriteLog and "  OnQRCodeStatusNotify:BackLoginWithCallback.")
          IMSDKQRCodeSystem.QRCodeIMSDKLoginChannel = queryResult.channel
          self:QRCodeLogin(IMSDKQRCodeSystem.QRCodeIMSDKLoginChannel)
        end)
      end
    end
    if IMSDKQRCodeStatus.EXPIRED == queryResult.status or IMSDKQRCodeStatus.INVALID == queryResult.status or IMSDKQRCodeStatus.FINISHED == queryResult.status then
      self:StopQueryQRCodeTimer()
    end
  else
    local noticeMsg = LocUtil.GetLocalizeResStr(200000130)
    noticeMsg = noticeMsg .. string.format(" (%d,%d)", queryResult.imsdkRetCode, queryResult.thirdRetCode)
    ShowNotice(noticeMsg)
  end
end
function IMSDKQRCodeSystem:OnInvalidateQRCodeNotify(invalidateResult)
  EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_IVALIDATE, invalidateResult)
  if invalidateResult.imsdkRetCode == IMSDKErrorCode.SUCCESS or invalidateResult.imsdkRetCode == IMSDKErrorCode.SERVER_ERROR then
    self:ClearQRCodeData()
  end
end
function IMSDKQRCodeSystem:ClearQRCodeData()
  log(bWriteLog and "IMSDKQRCodeSystem:ClearQRCodeData")
  self:StopQueryQRCodeTimer()
  IMSDKQRCodeSystem.QRCodeId = ""
  IMSDKQRCodeSystem.QRCodeRanStr = ""
  IMSDKQRCodeSystem.QRCodeIMSDKLoginChannel = ""
end
function IMSDKQRCodeSystem:StartQueryQRCodeTimer()
  log(bWriteLog and "IMSDKQRCodeSystem:StartQueryQRCodeTimer")
  local time_ticker = require("common.time_ticker")
  IMSDKQRCodeSystem.QRCodeQueryTimer = time_ticker.AddTimerLoop(IMSDKQRCodeSystem.QRCodeQueryQueryInterval, function()
    self:QueryQRCodeStatus(IMSDKQRCodeSystem.QRCodeId, IMSDKQRCodeSystem.QRCodeRanStr, {})
  end, IMSDKQRCodeSystem.QRCodeQueryMaxLoopTime, IMSDKQRCodeSystem.QRCodeQueryQueryInterval)
end
function IMSDKQRCodeSystem:StopQueryQRCodeTimer()
  log(bWriteLog and "IMSDKQRCodeSystem:StopQueryQRCodeTimer")
  if IMSDKQRCodeSystem.QRCodeQueryTimer ~= nil then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(IMSDKQRCodeSystem.QRCodeQueryTimer)
    IMSDKQRCodeSystem.QRCodeQueryTimer = nil
  end
end
function IMSDKQRCodeSystem:SwitchQRCodeLoginResult(openId)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance:SwitchQRCodeLoginResult(openId)
end
function IMSDKQRCodeSystem:QRCodeLoginWithChannelId(imsdkChannelId)
  log(bWriteLog and "IMSDKQRCodeSystem:QRCodeLoginWithChannelId: " .. tostring(imsdkChannelId))
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local imsdkChannelName = IMSDKHelperInstance:ConvertIMSDKChannelToStr(imsdkChannelId, true)
  self:QRCodeLogin(imsdkChannelName)
end
return IMSDKQRCodeSystem