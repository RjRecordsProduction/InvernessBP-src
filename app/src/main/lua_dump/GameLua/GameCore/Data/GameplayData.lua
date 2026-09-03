local GameplayData = {
  bClient = false,
  ClientGlobalData = nil,
  DSGlobalData = nil
}
local ClientData = require("GameLua.GameCore.Data.ClientData")
local GlobalData = require("GameLua.GameCore.Data.GlobalData")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local CreateGlobalData = function(bClient)
  local OutGlobalData = setmetatable({}, GlobalData)
  return OutGlobalData
end
function GameplayData.InitDSEntry()
  GameplayData.bClient = _G.Client ~= nil
  if not GameplayData.bClient then
    GameplayData.DSGlobalData = CreateGlobalData()
    GameplayData.DSGlobalData.InitInagmeEntry(false)
    GameplayData.RedirectFunction()
  end
end
function GameplayData.InitStandAloneEntry()
  GameplayData.bClient = true
  ClientData.InitStandAloneEntry()
  if GameplayData.ClientGlobalData then
    GameplayData.ClientGlobalData.InitStandAloneEntry()
  end
end
function GameplayData.InitInagmeEntry()
  GameplayData.bClient = true
  ClientData.InitInagmeEntry()
  GameplayData.ClientGlobalData = CreateGlobalData()
  GameplayData.ClientGlobalData.InitInagmeEntry(true)
  GameplayData.RedirectFunction()
end
function GameplayData.RedirectFunction()
  local TempGlobalData
  if GameplayData.bClient then
    TempGlobalData = GameplayData.ClientGlobalData
  else
    TempGlobalData = GameplayData.DSGlobalData
  end
  GameplayData.UnbindPlayerController = TempGlobalData.UnbindPlayerController
  GameplayData.UnbindPlayerCharacter = TempGlobalData.UnbindPlayerCharacter
  GameplayData.UnbindPlayerState = TempGlobalData.UnbindPlayerState
  GameplayData.GetAllPlayerControllers = TempGlobalData.GetAllPlayerControllers
  GameplayData.GetAllPlayerCharacters = TempGlobalData.GetAllPlayerCharacters
  GameplayData.GetAllPlayerStates = TempGlobalData.GetAllPlayerStates
  if GameplayData.bClient then
    GameplayData.AddGameStateEvent = ClientData.AddGameStateEvent
    GameplayData.AddGameStateEventWithCondition = ClientData.AddGameStateEventWithCondition
  else
    GameplayData.AddPlayerControllerEvent = TempGlobalData.AddPlayerControllerEvent
    GameplayData.AddPlayerCharacterEvent = TempGlobalData.AddPlayerCharacterEvent
    GameplayData.AddPlayerStateEvent = TempGlobalData.AddPlayerStateEvent
    GameplayData.AddGameStateEvent = TempGlobalData.AddGameStateEvent
    GameplayData.AddPlayerControllerEventWithCondition = TempGlobalData.AddPlayerControllerEventWithCondition
    GameplayData.AddPlayerCharacterEventWithCondition = TempGlobalData.AddPlayerCharacterEventWithCondition
    GameplayData.AddPlayerStateEventWithCondition = TempGlobalData.AddPlayerStateEventWithCondition
    GameplayData.AddGameStateEventWithCondition = TempGlobalData.AddGameStateEventWithCondition
  end
  GameplayData.AddSelfPlayerControllerEvent = ClientData.AddPlayerControllerEvent
  GameplayData.AddSelfPlayerCharacterEvent = ClientData.AddPlayerCharacterEvent
  GameplayData.AddSelfPlayerStateEvent = ClientData.AddPlayerStateEvent
  GameplayData.AddSelfPlayerControllerEventWithCondition = ClientData.AddPlayerControllerEventWithCondition
  GameplayData.AddSelfPlayerCharacterEventWithCondition = ClientData.AddPlayerCharacterEventWithCondition
  GameplayData.AddSelfPlayerStateEventWithCondition = ClientData.AddPlayerStateEventWithCondition
  if not GameplayData.bClient then
    GameplayData.GetPlayerController = TempGlobalData.GetPlayerController
    GameplayData.GetPlayerCharacter = TempGlobalData.GetPlayerCharacter
    GameplayData.GetPlayerState = TempGlobalData.GetPlayerState
  end
  GameplayData.GetSuperData = ClientData.GetSuperData
end
function GameplayData.BindPlayerController(uPlayerController)
  if GameplayData.bClient then
    GameplayData.ClientGlobalData.BindPlayerController(uPlayerController)
    ClientData.BindPlayerController(uPlayerController)
  else
    GameplayData.DSGlobalData.BindPlayerController(uPlayerController)
  end
end
function GameplayData.BindPlayerCharacter(uPlayerCharacter, bRep)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local bIsStandalone = UKismetSystemLibrary.IsStandalone(uPlayerCharacter)
  if bRep == true or bIsStandalone then
    ClientData.BindPlayerCharacter(uPlayerCharacter)
  end
  if GameplayData.bClient then
    GameplayData.ClientGlobalData.BindPlayerCharacter(uPlayerCharacter)
  else
    GameplayData.DSGlobalData.BindPlayerCharacter(uPlayerCharacter)
  end
end
function GameplayData.BindPlayerState(uPlayerState, bRep)
  if bRep == true then
    ClientData.BindPlayerState(uPlayerState)
  end
  if GameplayData.bClient then
    GameplayData.ClientGlobalData.BindPlayerState(uPlayerState)
  else
    GameplayData.DSGlobalData.BindPlayerState(uPlayerState)
  end
end
function GameplayData.BindGameState(uGameState)
  if GameplayData.bClient then
    GameplayData.ClientGlobalData.BindGameState(uGameState)
    ClientData.BindGameState(uGameState)
  else
    GameplayData.DSGlobalData.BindGameState(uGameState)
  end
end
function GameplayData.AddPlayerControllerEvent(delegateContainer, nPlayerKey, eventName, handleFunc, ...)
  if nPlayerKey == nil then
    ClientData.AddPlayerControllerEvent(delegateContainer, eventName, handleFunc, ...)
  else
    GameplayData.ClientGlobalData.AddPlayerControllerEvent(delegateContainer, nPlayerKey, eventName, handleFunc, ...)
  end
end
function GameplayData.AddPlayerCharacterEvent(delegateContainer, nPlayerKey, eventName, handleFunc, ...)
  if nPlayerKey == nil then
    ClientData.AddPlayerCharacterEvent(delegateContainer, eventName, handleFunc, ...)
  else
    GameplayData.ClientGlobalData.AddPlayerCharacterEvent(delegateContainer, nPlayerKey, eventName, handleFunc, ...)
  end
end
function GameplayData.AddPlayerStateEvent(delegateContainer, nPlayerKey, eventName, handleFunc, ...)
  if nPlayerKey == nil then
    ClientData.AddPlayerStateEvent(delegateContainer, eventName, handleFunc, ...)
  else
    GameplayData.ClientGlobalData.AddPlayerStateEvent(delegateContainer, nPlayerKey, eventName, handleFunc, ...)
  end
end
function GameplayData.AddPlayerControllerEventWithCondition(delegateContainer, nPlayerKey, eventName, condTable, handleFunc, ...)
  if nPlayerKey == nil then
    ClientData.AddPlayerControllerEventWithCondition(delegateContainer, eventName, condTable, handleFunc, ...)
  else
    GameplayData.ClientGlobalData.AddPlayerControllerEventWithCondition(delegateContainer, nPlayerKey, eventName, condTable, handleFunc, ...)
  end
end
function GameplayData.AddPlayerCharacterEventWithCondition(delegateContainer, nPlayerKey, eventName, condTable, handleFunc, ...)
  if nPlayerKey == nil then
    ClientData.AddPlayerCharacterEventWithCondition(delegateContainer, eventName, condTable, handleFunc, ...)
  else
    GameplayData.ClientGlobalData.AddPlayerCharacterEventWithCondition(delegateContainer, nPlayerKey, eventName, condTable, handleFunc, ...)
  end
end
function GameplayData.AddPlayerStateEventWithCondition(delegateContainer, nPlayerKey, eventName, condTable, handleFunc, ...)
  if nPlayerKey == nil then
    ClientData.AddPlayerStateEventWithCondition(delegateContainer, eventName, condTable, handleFunc, ...)
  else
    GameplayData.ClientGlobalData.AddPlayerStateEventWithCondition(delegateContainer, nPlayerKey, eventName, condTable, handleFunc, ...)
  end
end
function GameplayData.GetPlayerController(nPlayerKey)
  return ClientData.GetPlayerController()
end
function GameplayData.GetPlayerCharacter(nPlayerKey)
  if nPlayerKey == nil then
    return ClientData.GetPlayerCharacter()
  else
    return GameplayData.ClientGlobalData.GetPlayerCharacter(nPlayerKey)
  end
end
function GameplayData.GetLocalCharacter()
  local Pawn = GameplayData.GetPlayerCharacter()
  if slua.isValid(Pawn) then
    return Pawn
  end
  local PC = GameplayData.GetPlayerController()
  if slua.isValid(PC) then
    return PC:GetCurPlayerCharacter()
  end
  return nil
end
function GameplayData.GetPlayerState(nPlayerKey)
  if nPlayerKey == nil then
    return ClientData.GetPlayerState()
  else
    return GameplayData.ClientGlobalData.GetPlayerState(nPlayerKey)
  end
end
function GameplayData.GetGameState()
  local uGameState
  if Client or GameplayData.bClient then
    uGameState = GameplayData.ClientGlobalData.GetGameState()
  else
    uGameState = GameplayData.DSGlobalData.GetGameState()
  end
  if uGameState and slua.isValid(uGameState) then
    return uGameState
  else
    return CGameState
  end
end
function GameplayData.GetGameMode()
  return CGameMode
end
function GameplayData.AddCharacter(uCharacter)
  if GameplayData.bClient then
    local bBatchMove = USTExtraBlueprintFunctionLibrary.IsActorRepMovementWithBatch(uCharacter)
    if bBatchMove then
      ClientData.AddCharacter(uCharacter)
    end
  end
end
function GameplayData.RemoveCharacter(uCharacter)
  if GameplayData.bClient then
    ClientData.RemoveCharacter(uCharacter)
  end
end
function GameplayData.GetAllCharacters()
  if GameplayData.bClient then
    return ClientData.GetAllCharacters()
  end
end
return GameplayData