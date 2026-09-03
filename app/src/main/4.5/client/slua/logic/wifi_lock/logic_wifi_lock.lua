local local local bWifiLockAcquired = false
local bEventRegistered = false
local WifiLockSystem = {}
function WifiLockSystem:OnPreSwitchGameStatus(_, _, data)
  if not data then
    return
  end
  local preState = data.pre
  local nextState = data.current
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) and not bWifiLockAcquired then
    log(bWriteLog and "logic_wifi_lock:OnPreSwitchGameStatus - AcquireWifiLock, preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
    Client.AcquireWifiLock()
    bWifiLockAcquired = true
  end
end
function WifiLockSystem:TryReleaseWifiLock(preState, nextState, source)
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) and bWifiLockAcquired then
    log(bWriteLog and "logic_wifi_lock:" .. source .. " - ReleaseWifiLock, preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
    Client.ReleaseWifiLock()
    bWifiLockAcquired = false
  end
end
function WifiLockSystem:OnPostSwitchLobbyEntry(_, _, data)
  if not data then
    return
  end
  self:TryReleaseWifiLock(data.pre, data.current, "OnPostSwitchLobbyEntry")
end
function WifiLockSystem:OnPostSwitchGameStatus(_, _, data)
  if not data then
    return
  end
  self:TryReleaseWifiLock(data.pre, data.current, "OnPostSwitchGameStatus")
end
function WifiLockSystem:RegisterEvent()
  if bEventRegistered then
    return
  end
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, self.OnPreSwitchGameStatus, self)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_LOBBY_ENTRY, self.OnPostSwitchLobbyEntry, self)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, self.OnPostSwitchGameStatus, self)
  bEventRegistered = true
  log(bWriteLog and "logic_wifi_lock - WifiLock EventSystem listeners registered")
end
function WifiLockSystem:UnregisterEvent()
  if not bEventRegistered then
    return
  end
  EventSystem:unregistEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, self.OnPreSwitchGameStatus)
  EventSystem:unregistEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_LOBBY_ENTRY, self.OnPostSwitchLobbyEntry)
  EventSystem:unregistEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, self.OnPostSwitchGameStatus)
  bEventRegistered = false
  log(bWriteLog and "logic_wifi_lock - WifiLock EventSystem listeners unregistered")
end
function WifiLockSystem:IsWifiLockEnabled()
  local bEnableWifiLock = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableWifiLock", true)
  return bEnableWifiLock
end
function WifiLockSystem.OnLogin()
  if not WifiLockSystem:IsWifiLockEnabled() then
    log(bWriteLog and "logic_wifi_lock:OnLogin - local cloud switch is off, skip request")
    return
  end
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_get_wifi_lock_info_req()
end
function WifiLockSystem.OnGetWifiLockInfoRsp(info)
  if not info then
    return
  end
  if info.enable then
    WifiLockSystem:RegisterEvent()
  else
    WifiLockSystem:UnregisterEvent()
  end
end
return WifiLockSystem