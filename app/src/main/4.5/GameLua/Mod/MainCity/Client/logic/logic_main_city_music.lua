local logic_main_city_music = {}
local closeUITable = {
  Download_Main_UIBP = 1,
  ReturnActivity_Main_UIBP = 1,
  ui_room_waiting = 2,
  CrazyWeekend_HomePage_UIBP = 1,
  MainCity_Penguin_Talking_UIBP = 3,
  MainCity_Penguin_Interactive_UIBP = 3
}
local MainCitySubUIList = {
  MainCity_Connecting_Tips_UIBP = 1,
  MainCity_Connecting_UIBP = 1,
  MainCity_Lobby_Friend_Explore_UIBP = 1,
  NewbieGuide_UIBP = 1,
  MainCity_SkipSeq_UIBP = 1,
  MainCity_Dance_Status_UIBP = 1
}
function logic_main_city_music:DefineAndResetData()
  self._playBox = nil
  self._playing = false
  self.enterMainCityMode = 0
  self.bReconnectCheck = nil
end
function logic_main_city_music:GetMusicID()
  return 1100001
end
function logic_main_city_music:OnInitialize()
end
function logic_main_city_music:RegistEvents()
  log(bWriteLog and "logic_main_city_music:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_LEAVE_UI, self.PauseMusic, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER_LOADING_FINISHI, self.PlayMusic, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_JUMPBACK, self.PlayMusic, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self.RestoreLobbyBGM, self)
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnUIClose, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_WAITING_OPEN, self.OnWaitRoomShow, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactivated, self)
end
function logic_main_city_music:OnLogin(bReLogin)
  self.bReconnectCheck = false
end
function logic_main_city_music:OnLogOut()
end
function logic_main_city_music:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_main_city_music:OnPreSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  log(bWriteLog and "logic_main_city_music:OnPreSwitchGameStatus self.enterMainCityMode = " .. tostring(self.enterMainCityMode))
  if nextState == GameStatus.Lobby then
    self._playing = false
  end
  local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    local bEnterGameFromMainCity = Lobby_Main_City_Enter.bEnterGameFromMainCity
    log(bWriteLog and "logic_main_city_music:OnPreSwitchGameStatus bEnterGameFromMainCity = " .. tostring(bEnterGameFromMainCity))
    if bEnterGameFromMainCity then
      self.enterMainCityMode = main_city_enter_config.EMainCityEnterMode.FightingToMainCity
    end
  end
end
function logic_main_city_music:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_main_city_music:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  if nextState == GameStatus.Fighting then
    self.enterMainCityMode = 0
  end
  self:ResetMusicStatu(1)
end
function logic_main_city_music:SetEnterMainCityMode(mode)
  self.enterMainCityMode = mode
end
function logic_main_city_music:InitLoginStatus()
  self.enterMainCityMode = 0
  local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  local switch = main_city_process_util.GetMainCityEnterSwitch()
  if switch then
    self:SetEnterMainCityMode(main_city_enter_config.EMainCityEnterMode.LoginToMainCity)
  end
end
function logic_main_city_music:GetEnterMainCityMode()
  if not self.bReconnectCheck then
    return -1
  end
  return self.enterMainCityMode
end
function logic_main_city_music:CheckEnterMainCity(game_info)
  local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
  log_tree(bWriteLog and "logic_main_city_music:GetEnterMainCityMode game_info = ", game_info)
  if game_info and game_info.sub_mode_group and game_info.sub_mode_group == 26000 then
    self:SetEnterMainCityMode(main_city_enter_config.EMainCityEnterMode.ReconnectToMainCity)
  end
  self.bReconnectCheck = true
end
function logic_main_city_music:PauseMusic()
  log(bWriteLog and "logic_main_city_music:PauseMusic")
  self.enterMainCityMode = 0
  if self._playBox then
    local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
    audio_manager:Pause(self:GetMusicID())
    self._playing = false
  end
  local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
  MainCity_GamePlay_Tools.SetDanceMusicState(false)
end
function logic_main_city_music:PlayMusic()
  if self._playing then
    log(bWriteLog and "logic_main_city_music:PlayMusic is playing")
    return
  end
  log(bWriteLog and "logic_main_city_music:PlayMusic")
  GlobalData.StopLobbyBGM()
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  self._playBox = audio_manager:Resume(self:GetMusicID())
  if not self._playBox then
    self._playBox = audio_manager:Start(self:GetMusicID(), true)
    log(bWriteLog and "logic_main_city_music:PlayMusic restart music")
  end
  self._playing = true
  local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
  MainCity_GamePlay_Tools.SetDanceMusicState(true)
end
function logic_main_city_music:RestoreLobbyBGM()
  log(bWriteLog and "logic_main_city_music:RestoreLobbyBGM back lobby")
  if not GameStatus.IsIn2DLobby() then
    log_error("logic_main_city_music:RestoreLobbyBGM is not in lobby?")
  end
  self:PauseMusic()
  GlobalData.RestoreLobbyBGM()
end
function logic_main_city_music:OnReturnShow()
  self:OnUIShowOrHide("ReturnActivity_Main_UIBP", true)
end
function logic_main_city_music:OnWaitRoomShow()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(1, function()
    self:OnUIShowOrHide("ui_room_waiting", true)
  end)
end
function logic_main_city_music:OnUIClose(_, __, configKeyName)
  self:OnUIShowOrHide(configKeyName, false)
end
function logic_main_city_music:OnUIShowOrHide(configKeyName, isShow)
  if not GameStatus.IsInMainCity() then
    return
  end
  log(bWriteLog and string.format("logic_main_city_music:OnUIShowOrHide configKeyName = [%s] isShow = [%s]", configKeyName, isShow))
  if closeUITable[configKeyName] then
    if isShow and (closeUITable[configKeyName] == 1 or closeUITable[configKeyName] == 2) then
      self:PauseMusic()
    elseif closeUITable[configKeyName] == 1 or closeUITable[configKeyName] == 3 then
      self:PlayMusic()
    end
  end
end
function logic_main_city_music:OnApplicationReactivated()
  log(bWriteLog and "logic_main_city_music:OnApplicationReactivated ")
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.1, function()
    if not GameStatus.IsInMainCity() then
      log(bWriteLog and "logic_main_city_music:OnApplicationReactivated not in main city")
      return false
    end
    log(bWriteLog and "logic_main_city_music:OnApplicationReactivated in main city and _playing = " .. (self._playing and "true" or "false"))
    if self._playing then
      self:PlayMusic()
    else
      self:PauseMusic()
    end
  end)
end
function logic_main_city_music:ResetMusicStatu(timer)
  log(bWriteLog and "logic_main_city_music:ResetMusicStatu ")
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(timer or 0, function()
    if self:CheckMusicCanPlay() then
      self:PlayMusic()
    else
      self:PauseMusic()
    end
  end)
end
function logic_main_city_music:CheckMusicCanPlay()
  if not GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_main_city_music:CheckMusicCanPlay not in main city")
    return false
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.MainCity_Main_UIBP)
  if not ui then
    log(bWriteLog and "logic_main_city_music:CheckMusicCanPlay not in main city ui")
    return false
  end
  local topUIList = UIManager.GetTopUINameList(5)
  if #topUIList == 0 then
    log(bWriteLog and "logic_main_city_music:CheckMusicCanPlay topUIList is empty")
    return true
  end
  local topUI = ""
  for index, value in ipairs(topUIList) do
    if MainCitySubUIList[value] == 1 then
    else
      topUI = value
      break
    end
  end
  log_tree("logic_main_city_music:CheckMusicCanPlay topUIList = ", topUIList)
  log(bWriteLog and "logic_main_city_music:CheckMusicCanPlay topUI = ", topUI)
  return topUI == "MainCity_Main_UIBP" or topUI == ""
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_main_city_music = class(CModuleBase, nil, logic_main_city_music)
return Clogic_main_city_music