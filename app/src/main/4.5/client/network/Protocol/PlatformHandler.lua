local NetManager = require("client.network.comm.NetManager")
local PlatformHandler = {}
function PlatformHandler.send_authorize_platform_req(app_id, app_token, role_id)
  NetManager.SendPkg(2076148327, app_id, app_token, role_id)
end
function PlatformHandler.on_authorize_platform_rsp(res, data)
  local StringUtil = require("common.string_util")
  log(bWriteLog and "PlatformHandler.on_authorize_platform_rsp res :" .. tostring(res))
  if res ~= NetErrorCode_NONE then
    log_error("PlatformHandler.on_authorize_platform_rsp error : " .. tostring(res))
    ShowNotice(7080)
  else
    if data ~= nil then
      for name, value in pairs(data) do
        if name == "wegame" then
          Client.LaunchUrl("intlhelper://webopenapi?action=30000&gameId=1005")
        else
          local SettingPlatformSystem = require("client.slua.logic.setting.logic_platform")
          local info = SettingPlatformSystem.GetPlatformInfo(name)
          local insideUrl = name .. "://gameauth?gameId=" .. info.game_id
          insideUrl = StringUtil.EncodeURI(insideUrl)
          local finalUrl = name .. "://jump?intent=" .. insideUrl
          Client.LaunchUrl(finalUrl)
        end
      end
    end
    ShowNotice(7079)
  end
  if data ~= nil then
    local SettingPlatformSystem = require("client.slua.logic.setting.logic_platform")
    SettingPlatformSystem.SaveAuthorizeInfo(data)
  end
end
function PlatformHandler.send_rescission_of_authorization_req(app_id)
  NetManager.SendPkg(1741973643, app_id)
end
function PlatformHandler.on_rescission_of_authorization_rsp(res, data)
  log(bWriteLog and "PlatformHandler.on_rescission_of_authorization_rsp res : " .. res)
  if res ~= NetErrorCode_NONE then
    log_error("PlatformHandler.on_authorize_platform_rsp error : " .. tostring(res))
    ShowNotice(7082)
  else
    ShowNotice(7081)
  end
  if data ~= nil then
    local SettingPlatformSystem = require("client.slua.logic.setting.logic_platform")
    SettingPlatformSystem.SaveAuthorizeInfo(data)
  end
end
return PlatformHandler