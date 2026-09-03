local logic_main_city_heart = {}
function logic_main_city_heart:DefineAndResetData()
  self.mainCityHeartCheckInterval = 30
  self.lastShowTipsTime = 0
  self.ShowTipsInterval = 60
  self.bEnableHeartCheck = true
  self.ClientWorldTimeOffset = 0
end
function logic_main_city_heart:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER_LOADING_FINISHI, self.OnEnterMainCity, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self.OnLeaveMainCity, self)
end
function logic_main_city_heart:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_main_city_heart:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  self:StopSendHeart()
end
function logic_main_city_heart:OnLogin(bReLogin)
  logic_main_city_heart.__super.OnLogin(self, bReLogin)
  self:SetEanbleHeartCheck(true)
end
function logic_main_city_heart:OnEnterMainCity()
  log(bWriteLog and "logic_main_city_heart:OnEnterMainCity")
  self:SetEanbleHeartCheck(true)
  self:StartSendHeart()
end
function logic_main_city_heart:OnLeaveMainCity()
  log(bWriteLog and "logic_main_city_heart:OnLeaveMainCity")
  self:StopSendHeart()
  self.lastShowTipsTime = 0
end
function logic_main_city_heart:StartSendHeart()
  log(bWriteLog and "logic_main_city_heart:StartSendHeart")
  if self.mainCityHeartTimer then
    self:RemoveTimer(self.mainCityHeartTimer)
    self.mainCityHeartTimer = nil
  end
  local TimeUtil = require("client.common.time_util")
  self.mainCityHeartTimer = self:AddTimerLoop(0, function()
    if GameStatus.IsInMainCity() then
      local MainCity_Heart_Client_Handler = require("GameLua.Mod.MainCity.Client.Handler.MainCity_Heart_Client_Handler")
      MainCity_Heart_Client_Handler.send_maincity_heart_req()
    end
  end, TIMER_INFINITE, 3)
  self:StartHeartTimeoutTimer()
end
function logic_main_city_heart:OnReceiveHeart(message)
  log(bWriteLog and "logic_main_city_heart:OnReceiveHeart")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local ds_world_seconds = message.ds_world_seconds
  if slua.isValid(CGameState) then
    local ClientWorldTime = CGameState:GetServerWorldTimeSeconds()
    self.ClientWorldTimeOffset = ClientWorldTime - ds_world_seconds
    printf("logic_main_city_heart:OnReceiveHeart ClientWorldTimeOffset = %s", self.ClientWorldTimeOffset)
  else
    printf("[WARNING] logic_main_city_heart:OnReceiveHeart CGameState is not valid")
  end
  log(bWriteLog and "logic_main_city_heart:OnReceiveHeart serverTime = " .. tostring(serverTime))
  self:StartHeartTimeoutTimer()
end
function logic_main_city_heart:StartHeartTimeoutTimer()
  log(bWriteLog and "logic_main_city_heart:StartHeartTimeoutTimer")
  if self.maincityHeartTimeoutTimer then
    self:RemoveTimer(self.maincityHeartTimeoutTimer)
    self.maincityHeartTimeoutTimer = nil
  end
  self.maincityHeartTimeoutTimer = self:AddTimerLoop(self.mainCityHeartCheckInterval, function()
    log(bWriteLog and "logic_main_city_heart:OnReceiveHeart heartbeat timeout 2")
    if not self.bEnableHeartCheck then
      return
    end
    if GameStatus.IsInMainCity() then
      local TimeUtil = require("client.common.time_util")
      local currTimer = TimeUtil.GetServerTimeInSec()
      if self.lastShowTipsTime == 0 or currTimer and self.lastShowTipsTime and currTimer - self.lastShowTipsTime >= self.ShowTipsInterval then
        local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
        logic_main_city_connect_state:ShowMainCityConnectingTipsUI(656197, 10)
        self.lastShowTipsTime = TimeUtil.GetServerTimeInSec()
      end
    end
  end, TIMER_INFINITE, self.mainCityHeartCheckInterval)
end
function logic_main_city_heart:SetEanbleHeartCheck(bEnableHeartCheck)
  self.end
function logic_main_city_heart:GetEanbleHeartCheck()
  return self.bEnableHeartCheck
end
function logic_main_city_heart:StopSendHeart()
  log(bWriteLog and "logic_main_city_heart:StopSendHeart")
  if self.mainCityHeartTimer then
    self:RemoveTimer(self.mainCityHeartTimer)
    self.mainCityHeartTimer = nil
  end
  if self.maincityHeartTimeoutTimer then
    self:RemoveTimer(self.maincityHeartTimeoutTimer)
    self.maincityHeartTimeoutTimer = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_main_city_heart = class(CModuleBase, nil, logic_main_city_heart)
return Clogic_main_city_heart