local logic_lobby_performance = {}
local main_city_performance_config = require("GameLua.Mod.MainCity.Client.logic.Performance.main_city_performance_config")
local GMDebug = false
function logic_lobby_performance:DefineAndResetData()
  log(bWriteLog and "logic_lobby_performance:DefineAndResetData")
  local main_city_switch_data = require("GameLua.Mod.MainCity.Client.logic.Performance.main_city_switch_data")
  self.switchData = main_city_switch_data()
  self.switchData:InitSwitch()
  self.switchData:OpenSwitch(main_city_performance_config.SwitchDataType.MainCity)
  self.lastSetTick = nil
end
function logic_lobby_performance:RegistEvents()
  log(bWriteLog and "logic_lobby_performance:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER_LOADING_FINISHI, self.OnCloseLobbyModelTick, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_JUMPBACK, self.OnCloseLobbyModelTick, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self.OnOpenLobbyModelTick, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_MINI_LOBBY_SHOW, self.OnOpenLobbyModelTick, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_MINI_LOBBY_CLOSE, self.OnCloseLobbyModelTick, self)
  self:AddCommonEvent(EVENTID_UI, BP_ENUM_UI_SHOW, self.OnUIShow, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_AVATAR_CREATED, self.OnTempupAvatarCreated, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.OnOpenLobbyModelTick, self)
end
function logic_lobby_performance:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_lobby_performance:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  if nextState ~= GameStatus.Fighting then
    return
  end
  local isInMainCity = GameStatus.IsInMainCity()
  log(bWriteLog and "logic_lobby_performance:OnPostSwitchGameStatus isInMainCity = " .. tostring(isInMainCity))
  if isInMainCity then
    return
  end
  self:DefineAndResetData()
end
function logic_lobby_performance:OnCloseLobbyModelTick()
  log(bWriteLog and "logic_lobby_performance:OnCloseLobbyModelTick")
  local MainCity_Lobby_Friend_UIBP = UIManager.GetUI(UIManager.UI_Config.MainCity_Lobby_Friend_UIBP)
  log(bWriteLog and "logic_lobby_performance:OnCloseLobbyModelTick MainCity_Lobby_Friend_UIBP = " .. tostring(MainCity_Lobby_Friend_UIBP))
  if MainCity_Lobby_Friend_UIBP and MainCity_Lobby_Friend_UIBP.nShowStatus == MainCity_Lobby_Friend_UIBP.EShowStatus.MiniLobby then
    log(bWriteLog and "logic_lobby_performance:OnCloseLobbyModelTick 1")
    return
  end
  local isInMainCity = GameStatus.IsInMainCity()
  log(bWriteLog and "logic_lobby_performance:OnCloseLobbyModelTick isInMainCity = " .. tostring(isInMainCity))
  if not isInMainCity then
    return
  end
  local wardrobeShow = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  log(bWriteLog and "logic_lobby_performance:OnCloseLobbyModelTick wardrobeShow = " .. tostring(wardrobeShow))
  if wardrobeShow then
    return
  end
  self:SetLobbyModelTick(main_city_performance_config.SwitchDataType.MainCity, false)
end
function logic_lobby_performance:OnUIShow(_, _, config)
  log(bWriteLog and "logic_lobby_performance:OnUIShow")
  if config and config.keyName and (config.keyName == "wardrobe" or config.keyName == "SharePackage_Edit_UIBP") then
    self:SetLobbyModelTick(main_city_performance_config.SwitchDataType.MainCity, true)
  end
end
function logic_lobby_performance:OnOpenLobbyModelTick()
  log(bWriteLog and "logic_lobby_performance:OnOpenLobbyModelTick")
  self:SetLobbyModelTick(main_city_performance_config.SwitchDataType.MainCity, true)
end
function logic_lobby_performance:OnTempupAvatarCreated(_, __, uid)
  log(bWriteLog and "logic_lobby_performance:OnTempupAvatarCreated 1 uid = " .. tostring(uid) .. " self.lastSetTick = " .. tostring(self.lastSetTick))
  if self.lastSetTick == nil then
    return
  end
  self:AddTimerOnce(1, function()
    log(bWriteLog and "logic_lobby_performance:OnTempupAvatarCreated 2 uid = " .. tostring(uid) .. " self.lastSetTick = " .. tostring(self.lastSetTick))
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    local avatar = TeamAvatarManager.GetAvatarByUid(uid)
    local performance_util = require("client.slua.logic.performance.performance_util")
    local tickInterval = performance_util.AvatarDefaultTickInterval
    if self.lastSetTick == false then
      tickInterval = performance_util.AvatarDisableTickInterval + math.random()
    end
    performance_util:SetAvatarTickInterval(avatar, tickInterval)
  end)
end
function logic_lobby_performance:SetLobbyModelTick(type, bTick)
  log(bWriteLog and "logic_lobby_performance:SetLobbyModelTick type = " .. type .. ", bTick = " .. tostring(bTick))
  if bTick then
    self.switchData:OpenSwitch(type)
  else
    self.switchData:CloseSwitch(type)
  end
  local switchVal = self.switchData:GetSwitchVal()
  log(bWriteLog and "logic_lobby_performance:SetLobbyModelTick switchVal = " .. tostring(switchVal))
  if self.lastSetTick == switchVal then
    return
  end
  self.lastSetTick = switchVal
  local TimeUtil, startTime
  if GMDebug then
    TimeUtil = require("client.common.time_util")
    startTime = TimeUtil.GetMicroseconds()
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatars = TeamAvatarManager.GetAllAvatar()
  if avatars == nil or not next(avatars) then
    return
  end
  local performance_util = require("client.slua.logic.performance.performance_util")
  for k, avatar in pairs(avatars) do
    local tickInterval = performance_util.AvatarDefaultTickInterval
    if not switchVal then
      tickInterval = performance_util.AvatarDisableTickInterval + math.random()
    end
    performance_util:SetAvatarTickInterval(avatar, tickInterval)
  end
  local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
  ThemeVehicleManager:SetVehicleTick(switchVal)
  if GMDebug then
    log(bWriteLog and string.format("logic_lobby_performance:SetLobbyModelTick time:[%.3fms]", (TimeUtil.GetMicroseconds() - startTime) / 1000))
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_lobby_performance)