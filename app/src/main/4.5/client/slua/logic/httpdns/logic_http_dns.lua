local logic_http_dns = {}
local PufferDefine = require("client.slua.logic.download.puffer.puffer_define")
function logic_http_dns:Init()
  log(bWriteLog and "logic_http_dns:Init")
  local gameInstance = slua.getGameInstance()
  gameInstance:ExecuteCMD("n.DolphinHttpDnsType", self:GetHttpDnsType())
  if not self:IsEnabled() then
    log(bWriteLog and "logic_http_dns:Init return by not enable")
    return
  end
  local AppId = Client.GetConfigInt(Client.ProjectDir() .. "Config/DefaultAppBaseConfig.ini", "/Script/Client.AppBaseConfig", "GameId")
  local httpdnsDebug = HDmpveRemote.HDmpveRemoteConfigGetBool("HttpDNSDebug", false)
  local HDmpveSDKObj = self:GetHDmpveSDKObj()
  if not HDmpveSDKObj then
    log(bWriteLog and "logic_http_dns:Init - HDmpveSDKObj is nil")
    return
  end
  HDmpveSDKObj:HttpDnsInit(AppId, httpdnsDebug, 5000)
end
function logic_http_dns:OnMSDKLogin()
  if not self:IsEnabled() then
    log(bWriteLog and "logic_http_dns:OnMSDKLogin return by not enable")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "logic_http_dns:Init return by not support publish region")
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local openid = IMSDKHelperInstance:getOpenID()
  log(bWriteLog and "logic_http_dns:OnMSDKLogin: " .. openid)
  local HDmpveSDKObj = self:GetHDmpveSDKObj()
  if not HDmpveSDKObj then
    log(bWriteLog and "logic_http_dns:OnMSDKLogin - HDmpveSDKObj is nil")
    return
  end
  HDmpveSDKObj:HttpDnsSetOpenid(openid)
end
function logic_http_dns:destroy()
  if not self:IsEnabled() then
    log(bWriteLog and "logic_http_dns:destroy return by not enable")
    return
  end
  local HDmpveSDKObj = self:GetHDmpveSDKObj()
  if not HDmpveSDKObj then
    log(bWriteLog and "logic_http_dns:destroy - HDmpveSDKObj is nil")
    return
  end
  HDmpveSDKObj:HttpDnsDestroy()
end
function logic_http_dns:GetHDmpveSDKObj()
  local netObj = slua_GameFrontendHUD:GetClientNetObj()
  return netObj and netObj._ConnectorInst
end
function logic_http_dns:IsEnabled()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "logic_http_dns:IsEnabled return false by not support publish region")
    return false
  end
  local EnableGCHttpDns = true
  EnableGCHttpDns = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableGCHttpDns", EnableGCHttpDns)
  if not EnableGCHttpDns then
    return false
  end
  return true
end
function logic_http_dns:GetHttpDnsType()
  if self:IsEnabled() then
    return PufferDefine.PufferHttpDnsType.LocalDNSFailedToHttpDNS
  end
  return PufferDefine.PufferHttpDnsType.OnLocalDNS
end
return logic_http_dns