local logic_cloud_game = {
  CLOUD_GAME_TYPE = {
    NONE = 0,
    WL_TIME = 1,
    PIONEER_CLOUD = 2
  },
  CLIENT_TYPE = {
    NONE = 0,
    MICRO_CLIENT = 1,
    WEB = 2
  },
  ProtocolName = {
    SDKLoginSuccess = "SDKLoginSuccess",
    SyncBaseInfo = "SyncBaseInfo",
    CreateNewRoleInfo = "CreateNewRoleInfo",
    LoginInfo = "LoginInfo",
    LogOutInfo = "LogOutInfo",
    LevelUpToCertainLevel = "LevelUpToCertainLevel",
    MatchBegin = "MatchBegin",
    MatchOver = "MatchOver",
    WinGameThreeTimes = "WinGameThreeTimes",
    LoginThreeDays = "LoginThreeDays",
    LoginSevenDays = "LoginSevenDays",
    ClickGuestToLogin = "ClickGuestToLogin"
  }
}
function logic_cloud_game:IsCloudVersion()
  logic_cloud_game.bIsCloudVersion = Client.IsCloudVersion()
  return logic_cloud_game.bIsCloudVersion
end
function logic_cloud_game:GetCloudGameType()
  local CloudGameType = logic_cloud_game.CLOUD_GAME_TYPE.NONE
  if self:IsCloudVersion() then
    if self:IsPioneerCloudGame() then
      CloudGameType = logic_cloud_game.CLOUD_GAME_TYPE.PIONEER_CLOUD
    else
      CloudGameType = logic_cloud_game.CLOUD_GAME_TYPE.NONE
    end
  end
  log(bWriteLog and string.format("logic_cloud_game:GetCloudGameType %s", tostring(CloudGameType)))
  return CloudGameType
end
function logic_cloud_game:IsPioneerCloudGame()
  local StringUtil = require("common.string_util")
  local systemProfile = Client.GetSystemProperty("ro.product.model")
  if systemProfile ~= nil and StringUtil.Starts(systemProfile, "yyx") then
    return true
  end
  return false
end
function logic_cloud_game:IsCloudGameWeb()
  if self:IsCloudVersion() and self:GetClientType() == logic_cloud_game.CLIENT_TYPE.WEB then
    return true
  end
  return false
end
function logic_cloud_game:GetCloudGameInterface()
  if self:GetCloudGameType() == logic_cloud_game.CLOUD_GAME_TYPE.PIONEER_CLOUD then
    local logic_pioneer = require("client.slua.logic.cloud_game.logic_pioneer")
    return logic_pioneer
  elseif self:GetCloudGameType() == logic_cloud_game.CLOUD_GAME_TYPE.WL_TIME then
    local logic_wl_time = require("client.slua.logic.cloud_game.logic_wl_time")
    return logic_wl_time
  else
    return nil
  end
end
function logic_cloud_game:onSyncBaseInfo(cloud_game_info)
  if cloud_game_info ~= nil then
    local msgParameter = {
      ip_isp = cloud_game_info.ip_isp or "",
      ip_country = cloud_game_info.ip_country or "",
      ip_province = cloud_game_info.ip_province or "",
      ip = cloud_game_info.ip or ""
    }
    self:SendMessageToCloudGame(logic_cloud_game.ProtocolName.SyncBaseInfo, msgParameter)
  end
end
function logic_cloud_game:SetCloudTokenInfo(tokenInfo)
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:SetCloudTokenInfo cloud_game is nil")
    return
  end
  return cloud_game:SetCloudTokenInfo(tokenInfo)
end
function logic_cloud_game:GetCloudTokenInfo()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetCloudTokenInfo cloud_game is nil")
    return nil
  end
  return cloud_game:GetCloudTokenInfo()
end
function logic_cloud_game:GetCloudGameClientXID()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetCloudGameClientXID cloud_game is nil")
    return ""
  end
  return cloud_game:GetCloudGameClientXID()
end
function logic_cloud_game:GetCloudGameClientGPUFamily()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetCloudGameClientGPUFamily cloud_game is nil")
    return ""
  end
  return cloud_game:GetCloudGameClientGPUFamily()
end
function logic_cloud_game:GetCloudGameClientDeviceName()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetCloudGameClientDeviceName cloud_game is nil")
    return ""
  end
  return cloud_game:GetCloudGameClientDeviceName()
end
function logic_cloud_game:SendMessageToCloudGame(event, msg)
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:SendMessageToCloudGame cloud_game is nil")
    return
  end
  local msgParameter = {}
  if msg == nil then
    msgParameter = {}
  elseif type(msg) == "string" then
    msgParameter = {param0 = msg}
  elseif type(msg) == "number" or type(msg) == "boolean" then
    msgParameter = {
      param0 = tostring(msg)
    }
  elseif type(msg) == "table" then
    msgParameter = msg
  end
  log_tree("logic_cloud_game:SendMessageToCloudGame event = " .. event, msgParameter)
  cloud_game:SendMessageToCloudGame(event, msgParameter)
end
function logic_cloud_game:GetClientType()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetClientType cloud_game is nil")
    return logic_cloud_game.CLIENT_TYPE.NONE
  end
  return cloud_game:GetClientType()
end
function logic_cloud_game:ActtachPaymentChannelExtra(paymenChannelExtra)
  local channelExtra = paymenChannelExtra
  if self:GetCloudGameType() == logic_cloud_game.CLOUD_GAME_TYPE.PIONEER_CLOUD and self:GetClientType() == logic_cloud_game.CLIENT_TYPE.WEB then
    local roleNameAfterUrlEncode = Client.UrlEncode(DataMgr.roleData.nickName or "")
    if paymenChannelExtra ~= nil and 0 < #paymenChannelExtra then
      channelExtra = string.format("%s&charac_id=%s&charac_name=%s", paymenChannelExtra, tostring(DataMgr.roleData.uid), roleNameAfterUrlEncode)
    else
      channelExtra = string.format("charac_id=%s&charac_name=%s", tostring(DataMgr.roleData.uid), roleNameAfterUrlEncode)
    end
  end
  return channelExtra
end
function logic_cloud_game:GetCloudGameLoginExtra(url)
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:IsCloudGameLoginUrl cloud_game is nil")
    return 0, ""
  end
  return cloud_game:GetCloudGameLoginExtra(url)
end
function logic_cloud_game:IsClientVPNConnected()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:IsClientVPNConnected cloud_game is nil")
    return false
  end
  return cloud_game:IsClientVPNConnected()
end
function logic_cloud_game:GetCarrierInfo()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetCarrierInfo cloud_game is nil")
    return ""
  end
  return cloud_game:GetCarrierInfo()
end
function logic_cloud_game:GetClientTimeZone()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetClientTimeZone cloud_game is nil")
    return ""
  end
  return cloud_game:GetClientTimeZone()
end
function logic_cloud_game:GetClientLanuage()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetClientTimeZone cloud_game is nil")
    return ""
  end
  return cloud_game:GetClientLanuage()
end
function logic_cloud_game:GetClientBrowserBrand()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetClientTimeZone cloud_game is nil")
    return ""
  end
  return cloud_game:GetClientBrowserBrand()
end
function logic_cloud_game:GetClientTimeOffset()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetClientTimeOffset cloud_game is nil")
    return 0
  end
  return cloud_game:GetClientTimeOffset()
end
function logic_cloud_game:GetClientHttpAcceptLanguage()
  local cloud_game = self:GetCloudGameInterface()
  if cloud_game == nil then
    log(bWriteLog and "logic_cloud_game:GetClientHttpAcceptLanguage cloud_game is nil")
    return ""
  end
  return cloud_game:GetClientHttpAcceptLanguage()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_cloud_game = class(CModuleBase, nil, logic_cloud_game)
return Clogic_cloud_game