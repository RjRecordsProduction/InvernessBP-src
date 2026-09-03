local LobbyWaterMarkSystem = {}
local TimeUtil = require("client.common.time_util")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local _OpenID = 32955612493382952
local _DevCloseWatermarkSwitch = false
local _DeviceId
local NWarpAt = 50
function LobbyWaterMarkSystem.OnModePostSwitch(preState, nextState)
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  log(bWriteLog and "  LobbyWaterMarkSystem.OnModePostSwitch")
  if IngameEntry.IsReplayClient() then
    log(bWriteLog and "  LobbyWaterMarkSystem.OnModePostSwitch.  IsReplayClient")
    UIManager.CloseUI(UIManager.UI_Config.Lobby_Watermark_BP)
  end
  if nextState ~= GameStatus.Lobby and not GameStatus.IsInMainCity() then
    return
  end
  if Client.IsReleaseVersion(NetInterface) and PublishRegionMacros.IsCEVersion() then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimer(1, function()
      UIManager.ShowUI(UIManager.UI_Config.Lobby_Watermark_BP)
    end)
  end
end
function LobbyWaterMarkSystem.GetWatermarkString()
  local date = tostring(TimeUtil.OSDate("%m-%d %H:%M"))
  local Beta = ""
  if PublishRegionMacros.IsCEVersion() then
    Beta = "Beta "
  end
  local result1 = Beta .. _OpenID .. " " .. date .. " " .. Client.GetAppVersion()
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  local result2 = base64.enc(result1)
  if type(result2) ~= "string" then
    result2 = tostring(result2 or "")
  end
  local StringUtil = require("common.string_util")
  local result = StringUtil.InsertString(result2, "\n", NWarpAt)
  log_shipping_client("LobbyWaterMarkSystem.GetWatermarkString preState:" .. result1 .. " enc:" .. result2)
  return result
end
function LobbyWaterMarkSystem.GetWatermarkStringInLogin()
  local date = tostring(TimeUtil.OSDate("%m-%d %H:%M"))
  local Beta = ""
  if PublishRegionMacros.IsCEVersion() then
    Beta = "Beta "
  end
  if not _DeviceId then
    _DeviceId = Client.GetDeviceXID()
    log_warning(bWriteLog and "[jwm]LobbyWaterMarkSystem.GetWatermarkStringInLogin. _DeviceId: " .. tostring(_DeviceId))
  end
  local result1 = Beta .. _DeviceId .. " " .. date .. " " .. Client.GetAppVersion()
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  local result2 = base64.enc(result1)
  if type(result2) ~= "string" then
    result2 = tostring(result2 or "")
  end
  local StringUtil = require("common.string_util")
  local result = StringUtil.InsertString(result2, "\n", NWarpAt)
  log_shipping_client("LobbyWaterMarkSystem.GetWatermarkStringInLogin preState:" .. result1 .. " enc:" .. result2)
  return result
end
function LobbyWaterMarkSystem.GetFightingWatermarkString()
  local date = tostring(g_game_id)
  local Beta = ""
  if PublishRegionMacros.IsCEVersion() then
    Beta = "Beta "
  end
  local result1 = Beta .. _OpenID .. " " .. date .. " " .. Client.GetAppVersion()
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  local result2 = base64.enc(result1)
  if type(result2) ~= "string" then
    result2 = tostring(result2 or "")
  end
  local StringUtil = require("common.string_util")
  local result = StringUtil.InsertString(result2, "\n", NWarpAt)
  log_shipping_client("LobbyWaterMarkSystem.GetFightingWatermarkString preState:" .. result1 .. " enc:" .. result2)
  return result
end
function LobbyWaterMarkSystem.SetOpenID(openid)
  _OpenID = openid
end
function LobbyWaterMarkSystem.GetDevCloseWatermarkSwitch()
  return _DevCloseWatermarkSwitch
end
function LobbyWaterMarkSystem.SetDevCloseWatermarkSwitch(DevCloseWatermarkSwitch)
  _  LobbyWaterMarkSystem.RefreshWatermarkByGMSwitch()
end
function LobbyWaterMarkSystem.IsReleaseVersion()
  if Client.IsWindowOB() or Client.IsWindowsClientReplay() then
    return true
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return Client.IsShipping() and globalConfig.IsDirectConnect() and not PublishRegionMacros.IsCEVersion()
end
function LobbyWaterMarkSystem.CheckReleaseVersionWatermark()
  if LobbyWaterMarkSystem.GetDevCloseWatermarkSwitch() then
    log(bWriteLog and string.format("Whitelisting does not show watermarks."))
    return false
  end
  if not LobbyWaterMarkSystem.IsReleaseVersion() then
    log(bWriteLog and string.format("Force watermark display."))
    return true
  end
  local result = GlobalData.IsIOSCheck()
  result = result and DataMgr.GetBSManager()
  log(bWriteLog and string.format("LobbyWaterMarkSystem.CheckReleaseVersionWatermark result = %s", result))
  return result
end
function LobbyWaterMarkSystem.RefreshWatermarkByGMSwitch()
  local isShow = LobbyWaterMarkSystem.CheckReleaseVersionWatermark()
  UIManager.CloseUI(UIManager.UI_Config.Lobby_Watermark_BP)
  if isShow then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Watermark_BP)
  end
  return isShow
end
return LobbyWaterMarkSystem