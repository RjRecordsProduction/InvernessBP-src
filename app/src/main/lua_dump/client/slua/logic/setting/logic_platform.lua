local SettingPlatformSystem = {
  isBindingList = {},
  userIdList = {},
  tokenList = {},
  platformInfo = {},
  getInfoHandler = nil
}
local PlatformHandler = require("client.network.Protocol.PlatformHandler")
function SettingPlatformSystem.SetPlatformInfo(platform, info)
  if info == nil or info.userId == nil or info.token == nil or platform == nil then
    log_error("SettingPlatformSystem.SetWegameInfo infoError!")
    return
  end
  SettingPlatformSystem.userIdList[platform] = info.userId
  SettingPlatformSystem.tokenList[platform] = info.token
  log(bWriteLog and "SettingPlatformSystem.SetWegameInfo success! platform = " .. platform .. " || userid = " .. info.userId .. " || token : " .. info.token)
end
function SettingPlatformSystem.CheckIsRegionAvailable(platform)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if SettingPlatformSystem.platformInfo ~= nil and SettingPlatformSystem.platformInfo[platform] ~= nil then
    local ip = login_module.sIpRegion
    local find = string.find(SettingPlatformSystem.platformInfo[platform].open_region, ip)
    return find ~= nil
  end
  return false
end
function SettingPlatformSystem.IsBindingPlatform(paltform)
  if SettingPlatformSystem.isBindingList[paltform] == true then
    return true
  else
    return false
  end
end
function SettingPlatformSystem.CanShowTabInSetting()
  if SettingPlatformSystem.isBindingList then
    for k, v in pairs(SettingPlatformSystem.isBindingList) do
      return true
    end
    return false
  else
    return false
  end
end
function SettingPlatformSystem.authorize_platform_req(platform)
  if platform == nil or SettingPlatformSystem.userIdList[platform] == nil or SettingPlatformSystem.tokenList[platform] == nil then
    log_error("SettingPlatformSystem.authorize_platform_req null error!!")
    return
  end
  log(bWriteLog and "SettingPlatformSystem.authorize_platform_req, platform : " .. tostring(platform) .. "|| userID: " .. tostring(SettingPlatformSystem.userIdList[platform]) .. "|| token: " .. tostring(SettingPlatformSystem.tokenList[platform]))
  PlatformHandler.send_authorize_platform_req(platform, SettingPlatformSystem.tokenList[platform], SettingPlatformSystem.userIdList[platform])
end
function SettingPlatformSystem.rescission_of_authorization_req(platform)
  PlatformHandler.send_rescission_of_authorization_req(platform)
end
function SettingPlatformSystem.SaveAuthorizeInfo(InfoList)
  if InfoList ~= nil then
    SettingPlatformSystem.isBindingList = {}
    for k, v in pairs(InfoList) do
      log(bWriteLog and "SettingPlatformSystem.SaveAuthorizeInfo  -  " .. k)
      SettingPlatformSystem.isBindingList[k] = true
    end
  end
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_BIND_INFO_CHANGE)
end
function SettingPlatformSystem.GetPlatformInfo(name)
  return SettingPlatformSystem.platformInfo[name]
end
function SettingPlatformSystem.ClearInfo()
  log(bWriteLog and "SettingPlatformSystem.ClearInfo")
  SettingPlatformSystem.isBindingList = {}
  SettingPlatformSystem.userIdList = {}
  SettingPlatformSystem.tokenList = {}
end
function SettingPlatformSystem.OnGetPlatformInfo()
  if SettingPlatformSystem.getInfoHandler then
    SettingPlatformSystem.getInfoHandler()
    SettingPlatformSystem.getInfoHandler = nil
  end
end
return SettingPlatformSystem