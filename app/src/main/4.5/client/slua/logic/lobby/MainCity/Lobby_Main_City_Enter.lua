local Lobby_Main_City_Enter = {
  bInMainCity = false,
  bShowMainCityUI = false,
  bConnectDS = false,
  bEnterMainCityLoading = false,
  bEnterGameFromMainCity = false,
  bIgnoreAutoEnterMainCity = false,
  bMainCityMapLoaded = false,
  setviewTargetManual = false,
  bWaitingFollowEnterMainCity = false,
  bReceiveFollowEnterMainCity = false,
  pendingEnterInfo = nil
}
function Lobby_Main_City_Enter.EnterMainCity(reconnect, callback, skipGrayCheck)
  log(bWriteLog and "[Lobby_Main_City_Enter] Lobby_Main_City_Enter.EnterMainCity_New reconnect = " .. tostring(reconnect) .. " callback = " .. tostring(callback) .. " skipGrayCheck = " .. tostring(skipGrayCheck))
  local MainCity_Enter_Main = require("client.slua.logic.lobby.MainCity.Main.MainCity_Enter_Main")
  local bSuccess = MainCity_Enter_Main.EnterMainCity_Step1(reconnect, skipGrayCheck)
  if not bSuccess then
    return false
  end
  UIManager.CloseUI(UIManager.UI_Config.ModeSelection_Select_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.ModeSelection_Custom_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.ModeSelection_XMission_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.xmission_download)
  UIManager.CloseUI(UIManager.UI_Config.ModeSelection_Wow_UIBP)
  bSuccess = MainCity_Enter_Main.EnterMainCity_Step2(callback)
  if bSuccess then
    return true
  end
  bSuccess = MainCity_Enter_Main.EnterMainCity_Step3(callback)
  if bSuccess then
    return true
  end
  MainCity_Enter_Main.EnterMainCity_Step4(reconnect)
  MainCity_Enter_Main.EnterMainCity_Step5(callback)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("r.Mobile.UseAlphaToCoverage", 0)
  return true
end
function Lobby_Main_City_Enter.LeaveMainCity(bImmediatelyDisconnect, bShowLobbyUI, bSkipGiveupEnterGame)
  log(bWriteLog and "[Lobby_Main_City_Enter] Lobby_Main_City_Enter.LeaveMainCity bImmediatelyDisconnect = " .. tostring(bImmediatelyDisconnect) .. " bShowLobbyUI = " .. tostring(bShowLobbyUI) .. " bSkipGiveupEnterGame = " .. tostring(bSkipGiveupEnterGame))
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ImmediatelyDisconnectMainCity", false) then
    bImmediatelyDisconnect = true
  end
  EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY_PRE)
  local MainCity_Leave_Main = require("client.slua.logic.lobby.MainCity.Main.MainCity_Leave_Main")
  MainCity_Leave_Main.LeaveMainCity_Step1(bImmediatelyDisconnect, bShowLobbyUI, bSkipGiveupEnterGame)
  MainCity_Leave_Main.LeaveMainCity_Step2(bImmediatelyDisconnect, bSkipGiveupEnterGame)
  EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("r.Mobile.UseAlphaToCoverage", 1)
end
function Lobby_Main_City_Enter.EnterMainCity_Jump()
  log(bWriteLog and "[Lobby_Main_City_Enter] Lobby_Main_City_Enter.EnterMainCity_Jump")
  local MainCity_Enter_UI = require("client.slua.logic.lobby.MainCity.Main.Enter.MainCity_Enter_UI")
  local MainCity_Enter_Camera = require("client.slua.logic.lobby.MainCity.Main.Enter.MainCity_Enter_Camera")
  local MainCity_Enter_JoyStick = require("client.slua.logic.lobby.MainCity.Main.Enter.MainCity_Enter_JoyStick")
  local MainCity_Enter_Weather = require("client.slua.logic.lobby.MainCity.Main.Enter.MainCity_Enter_Weather")
  MainCity_Enter_UI.EnterMainCity_UI()
  MainCity_Enter_Camera.EnterMainCity_Camera()
  MainCity_Enter_JoyStick.EnterMainCity_JoyStick()
  MainCity_Enter_Weather.EnterMainCity_Weather()
end
function Lobby_Main_City_Enter.LeaveMainCity_Jump()
  log(bWriteLog and "[Lobby_Main_City_Enter] Lobby_Main_City_Enter.LeaveMainCity_Jump")
  local MainCity_Leave_UI = require("client.slua.logic.lobby.MainCity.Main.Leave.MainCity_Leave_UI")
  MainCity_Leave_UI.LeaveMainCity_UI(false, false)
end
return Lobby_Main_City_Enter