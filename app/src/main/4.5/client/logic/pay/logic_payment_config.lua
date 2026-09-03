local PAY_ENV = {
  RELEASE = "release",
  TEST = "test",
  SANDBOX = "sandbox"
}
local M = {
  PAY_ENV = PAY_ENV,
  SVR_CONF = {
    BLUEHOLE = "2df16ae4ed56957a109f251284f08fef979059221dc9938da7839a95b91294e544b546c49c211dc3b1d81cc7f1474384e56c0c7e6415dd048cc76ceee88879ad74e93bf6e25c937707c5310ac3f5a4ea8d8f512c1f84cbceb8cc979eb65fc0e94c8f41c0a23806d9a29649feb21a5dd6a4321c7c774db14ed79b2fdafbfb33bd33bf7ce4f057d52f139f7436c2f4bdea91931a715186c0c1f9929588f51a80a445b806d392394d86f4df2cc1ff460c8ee45e46306444a00d8ac420f7e7ae3fa83abc7bedad5198784a913d02f9f2a0d494944b3f51d1f28de6d2dac5eb53d8f809e21b85df0912d7",
    DEFAULT = "2df16ae4ed56957a109f251284f08fef979059221dc9938da7839a95b91294e544b546c49c211dc3b1d81cc7f1474384e56c0c7e6415dd048cc76ceee88879ad74e93bf6e25c937707c5310ac3f5a4ea8d8f512c1f84cbceb8cc979eb65fc0e94c8f41c0a23806d9a29649feb21a5dd6a4321c7c774db14ed79b2fdafbfb33bd33bf7ce4f057d52f139f7436c2f4bdea91931a71519bc8d6fa8b9390b6188fa109b347dddf784dc189d01cc8f14203b8e2630c68640ee319cdc36ae6ebb272a578b076e8a11ed57e37d46f36caf2a3ffdac7636942d99081e6d0c2dfe853dffb058d55cd"
  }
}
function M:GetPaymentSvrInfo()
  local region = Client.GetPublishRegion()
  local svr_info_str = self.SVR_CONF[region] or self.SVR_CONF.DEFAULT
  local encrypt_util = require("client.common.encrypt_util")
  local jsonstr = encrypt_util:CommonXORDecryption(svr_info_str)
  local svr_info = json.decode(jsonstr)
  local Utility = require("common.utility")
  if Utility.IsReleaseVersion() and svr_info and svr_info.sandbox then
    for k, v in pairs(svr_info.sandbox) do
      if type(v) == "table" then
        svr_info.sandbox[k] = {}
      else
        svr_info.sandbox[k] = ""
      end
    end
  end
  log(bWriteLog and "logic_payment_config:GetPaymentSvrInfo jsonstr = " .. jsonstr)
  return svr_info
end
function M:GetPayEnvironment()
  local BusinessHelper = import("BusinessHelper")
  local iEnv = BusinessHelper.GetIMSDKEnv()
  if iEnv == 1 then
    return PAY_ENV.RELEASE
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local strPlatform = Client.GetDevicePlatformName()
  if strPlatform == DevicePlatformNameMacros.IOS then
    return PAY_ENV.TEST
  elseif strPlatform == DevicePlatformNameMacros.Android then
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    local shop = Client.GetAOSSHOP()
    if shop == AOSSHOPMacros.Google or shop == AOSSHOPMacros.ThirdPartyPayment then
      return PAY_ENV.SANDBOX
    else
      return PAY_ENV.TEST
    end
  else
    return PAY_ENV.SANDBOX
  end
end
function M:IsPayTestEnv()
  local env = self:GetPayEnvironment()
  return env == PAY_ENV.TEST or env == PAY_ENV.SANDBOX
end
function M:GetInIDC()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local inIDC
  if PublishRegionMacros.IsBLUEHOLE() then
    inIDC = "singapore_pubgld"
  else
    inIDC = "singapore_igame"
  end
  return inIDC
end
return M