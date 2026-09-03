local LobbyModelPossess = {
  PossessActor = nil,
  bMainCityConnectDS = false,
  bDisableRePossess = false
}
function LobbyModelPossess:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_CONNECTED_TO_DS_DELAY, self.OnConnectToDS, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_DISCONNECT_DS, self.OnDisconnectDS, self)
end
function LobbyModelPossess:Possess(InActor, bDisableTouchMoveInput)
  if not slua.isValid(InActor) then
    log(bWriteLog and "LobbyModelPossess:Possess return InActor is " .. tostring(InActor))
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "LobbyModelPossess:Possess return uPlayerController is " .. tostring(uPlayerController))
    return
  end
  if self.PossessActor then
    self:UnPossess()
  end
  self.PossessActor = InActor
  self.bDisableRePossess = false
  if InActor.bDestroyControllerIfPlayStateIsNull ~= nil then
    InActor.bDestroyControllerIfPlayStateIsNull = false
  end
  if bDisableTouchMoveInput == nil then
    bDisableTouchMoveInput = true
  end
  local bHasAuthority = uPlayerController.HasAuthority and uPlayerController:HasAuthority()
  log(bWriteLog and "LobbyModelPossess:Possess bMainCityConnectDS:" .. tostring(self.bMainCityConnectDS) .. " bHasAuthority: " .. tostring(bHasAuthority) .. " bDisableTouchMoveInput:" .. tostring(bDisableTouchMoveInput) .. " InActor:" .. tostring(InActor) .. " uPlayerController:" .. tostring(uPlayerController))
  if self.bMainCityConnectDS or not bHasAuthority then
    log(bWriteLog and "LobbyModelPossess:Possess PossessOnlyClient")
    uPlayerController:PossessOnlyClient(InActor)
  else
    log(bWriteLog and "LobbyModelPossess:Possess Possess")
    uPlayerController:Possess(InActor)
  end
  if uPlayerController.SetDisableTouchMoveInput then
    uPlayerController:SetDisableTouchMoveInput(bDisableTouchMoveInput)
  end
  if InActor.iPossessRate ~= nil then
    InActor.iPossessRate = 3
  end
  if InActor.bPossessOnlyClient ~= nil then
    InActor.bPossessOnlyClient = true
  end
end
function LobbyModelPossess:UnPossess()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "LobbyModelPossess:UnPossess return uPlayerController is " .. tostring(uPlayerController))
    return
  end
  if not self.PossessActor then
    log(bWriteLog and "LobbyModelPossess:UnPossess return self.PossessActor is nil")
    return
  end
  log(bWriteLog and "LobbyModelPossess:UnPossess")
  if uPlayerController.SetDisableTouchMoveInput then
    uPlayerController:SetDisableTouchMoveInput(false)
  end
  self.PossessActor = nil
end
function LobbyModelPossess:ClearPossess()
  log(bWriteLog and "LobbyModelPossess:ClearPossess")
  self:UnPossess()
end
function LobbyModelPossess:OnPostSwitchGameStatus(preState, nextState)
  if (nextState == GameStatus.Fighting or nextState == GameStatus.Login) and not GameStatus.IsInMainCity() then
    self:ClearPossess()
  end
end
function LobbyModelPossess:OnConnectToDS()
  self.bMainCityConnectDS = true
  if not self.PossessActor then
    log(bWriteLog and "LobbyModelPossess:OnConnectToDS return self.PossessActor is nil")
    return
  end
  if self.bDisableRePossess then
    log(bWriteLog and "LobbyModelPossess:OnConnectToDS return self.bDisableRePossess is true")
    return
  end
  log(bWriteLog and "LobbyModelPossess:OnConnectToDS")
  self:AddTimerOnce(0.1, function()
    if slua.isValid(self.PossessActor) then
      self:Possess(self.PossessActor, false)
    end
  end)
end
function LobbyModelPossess:OnDisconnectDS()
  self.bMainCityConnectDS = false
  if not self.PossessActor then
    log(bWriteLog and "LobbyModelPossess:OnDisconnectDS return self.PossessActor is nil")
    return
  end
  if self.bDisableRePossess then
    log(bWriteLog and "LobbyModelPossess:OnDisconnectDS return self.bDisableRePossess is true")
    return
  end
  log(bWriteLog and "LobbyModelPossess:OnDisconnectDS")
  self:AddTimerOnce(0.1, function()
    if slua.isValid(self.PossessActor) then
      self:Possess(self.PossessActor, true)
    end
  end)
end
function LobbyModelPossess:SetDisableRePossess(bValue)
  self.bDisableRePossess = bValue
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLobbyModelPossess = class(CModuleBase, nil, LobbyModelPossess)
return CLobbyModelPossess