local SuperData = require("common.super_data")
local ClientData = {
  TempPlayerController = nil,
  TempPlayerCharacter = nil,
  TempPlayerState = nil,
  DelegateCache = {},
  bStandAlone = false,
  AllCharacters = {}
}
local ClientSuperData = SuperData.CreateSuperData({})
function ClientData._RestTempData()
  ClientData.TempPlayerController = nil
  ClientData.TempPlayerCharacter = nil
  ClientData.TempPlayerState = nil
  ClientData.CharacterDataReady = nil
  ClientData.GameStateReady = nil
  ClientData.DelegateCache = {}
  ClientData.AllCharacters = {}
end
function ClientData._InitData()
  ClientData._RestTempData()
end
function ClientData._ClearData()
  ClientData._RestTempData()
  ClientSuperData = SuperData.CreateSuperData({})
end
function ClientData.InitInagmeEntry()
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_START, ClientData.OnPostSwitch)
end
function ClientData.InitStandAloneEntry()
  ClientData.bStandAlone = true
  ClientData._InitData()
end
function ClientData.OnPostSwitch(_, _, status)
  print(bWriteLog and "ClientData.OnPostSwitch", status.current)
  if status.current == GameStatus.Fighting then
    if not ClientData.bStandAlone then
      ClientData._InitData()
    end
  else
    ClientData.bStandAlone = false
    ClientData._ClearData()
  end
end
function ClientData.BindPlayerController(uPlayerController)
  local uCurPlayerController = ClientData.GetPlayerController()
  if slua.isValid(uCurPlayerController) then
    return
  end
  if slua.isValid(uPlayerController) then
    ClientData.TempPlayerController = uPlayerController
    ClientData._BindData("PlayerController", uPlayerController)
    ClientData._CheckPlayerCharacterBind(uPlayerController, ClientData.TempPlayerCharacter)
    ClientData._CheckPlayerStateBind(uPlayerController, ClientData.TempPlayerState)
  end
end
function ClientData._CheckPlayerCharacterBind(uPlayerController, uPlayerCharacter)
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerCharacter) then
    if slua.isValid(uPlayerController.Character) then
      if uPlayerController.Character == uPlayerCharacter then
        ClientData._BindData("PlayerCharacter", uPlayerCharacter)
      end
    elseif slua.isValid(uPlayerController.STExtraBaseCharacter) and uPlayerController.STExtraBaseCharacter == uPlayerCharacter then
      ClientData._BindData("PlayerCharacter", uPlayerCharacter)
    end
  end
end
function ClientData._CheckPlayerStateBind(uPlayerController, uPlayerState)
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerState) and uPlayerController.PlayerState == uPlayerState then
    ClientData._BindData("PlayerState", uPlayerState)
  end
end
local UCharacterClass = import("/Script/Engine.Character")
function ClientData.BindPlayerCharacter(uPlayerCharacter)
  if Game:IsClassOf(uPlayerCharacter, UCharacterClass) then
    if slua.isValid(uPlayerCharacter) then
      ClientData.TempPlayerCharacter = uPlayerCharacter
      ClientData._CheckPlayerCharacterBind(ClientData.TempPlayerController, ClientData.TempPlayerCharacter)
    else
      ClientData.TempPlayerCharacter = nil
      ClientData._UnbindData("PlayerCharacter")
    end
  end
end
function ClientData.BindPlayerState(uPlayerState)
  if slua.isValid(uPlayerState) then
    ClientData.TempPlayerState = uPlayerState
    ClientData._CheckPlayerStateBind(ClientData.TempPlayerController, ClientData.TempPlayerState)
  else
    ClientData.TempPlayerState = nil
    ClientData._UnbindData("PlayerState")
  end
end
function ClientData.BindGameState(uGameState)
  ClientData._BindData("GameState", uGameState)
end
function ClientData._BindData(key, value)
  local bValueChange = false
  if ClientSuperData and slua.isValid(value) then
    if ClientSuperData[key] == nil then
      ClientSuperData[key] = value
    elseif ClientSuperData[key] ~= value then
      ClientSuperData[key] = value
      bValueChange = true
    else
      return
    end
    ClientData._RebindDelegate(key)
  end
  if ClientSuperData then
    print(bWriteLog and "ClientData._BindData(key, value)", key, value, ClientSuperData[key])
  end
  ClientData._CheckDataReady(key, bValueChange)
end
function ClientData._UnbindData(key)
  if ClientSuperData then
    ClientSuperData[key] = nil
  end
  if ClientData.DelegateCache ~= nil then
    ClientData.DelegateCache[key] = nil
  end
end
function ClientData._CheckDataReady(key, bValueChange)
  if ClientSuperData and slua.isValid(ClientSuperData.PlayerController) and slua.isValid(ClientSuperData.PlayerCharacter) and slua.isValid(ClientSuperData.PlayerState) then
    if ClientSuperData.CharacterDataReady then
      if bValueChange then
        ClientSuperData.CharacterDataReady = ClientSuperData.CharacterDataReady + 1
        print(bWriteLog and string.format("ClientData._CheckDataReady CharacterDataReady=%d,  bValueChange", ClientSuperData.CharacterDataReady))
      end
    else
      ClientSuperData.CharacterDataReady = 1
      print(bWriteLog and string.format("ClientData._CheckDataReady CharacterDataReady=%d", ClientSuperData.CharacterDataReady))
    end
    if slua.isValid(ClientSuperData.GameState) then
      if not ClientSuperData.GameDataReady then
        print(bWriteLog and string.format("ClientData._CheckDataReady GameDataReady"))
      end
      ClientSuperData.GameDataReady = true
    end
  end
end
function ClientData._AddDataObjectEvent(delegateContainer, uObject, eventName, handleFunc, ...)
  if delegateContainer and slua.isValid(uObject) then
    if delegateContainer.AddControlEventByControl then
      delegateContainer:AddControlEventByControl(uObject, eventName, handleFunc, ...)
    else
      delegateContainer:AddControlEvent(uObject, eventName, handleFunc, ...)
    end
    return true
  end
  return false
end
function ClientData._AddDataObjectEventWithCondition(delegateContainer, uObject, eventName, condTable, handleFunc, ...)
  if delegateContainer and slua.isValid(uObject) then
    if delegateContainer.AddControlEventByControlWithCondition then
      delegateContainer:AddControlEventByControlWithCondition(uObject, eventName, condTable, handleFunc, ...)
    else
      delegateContainer:AddControlEventWithCondition(uObject, eventName, condTable, handleFunc, ...)
    end
    return true
  end
  return false
end
function ClientData.AddPlayerCharacterEvent(delegateContainer, eventName, handleFunc, ...)
  if ClientSuperData and not ClientData._AddDataObjectEvent(delegateContainer, ClientSuperData.PlayerCharacter, eventName, handleFunc, ...) then
    ClientData._AddDelegateCache("PlayerCharacter", delegateContainer, eventName, handleFunc, ...)
  end
end
function ClientData.AddPlayerControllerEvent(delegateContainer, eventName, handleFunc, ...)
  if ClientSuperData and not ClientData._AddDataObjectEvent(delegateContainer, ClientSuperData.PlayerController, eventName, handleFunc, ...) then
    ClientData._AddDelegateCache("PlayerController", delegateContainer, eventName, handleFunc, ...)
  end
end
function ClientData.AddPlayerStateEvent(delegateContainer, eventName, handleFunc, ...)
  if ClientSuperData and not ClientData._AddDataObjectEvent(delegateContainer, ClientSuperData.PlayerState, eventName, handleFunc, ...) then
    ClientData._AddDelegateCache("PlayerState", delegateContainer, eventName, handleFunc, ...)
  end
end
function ClientData.AddGameStateEvent(delegateContainer, eventName, handleFunc, ...)
  if ClientSuperData and not ClientData._AddDataObjectEvent(delegateContainer, ClientSuperData.GameState, eventName, handleFunc, ...) and not ClientData._AddDataObjectEvent(delegateContainer, CGameState, eventName, handleFunc, ...) then
    ClientData._AddDelegateCache("GameState", delegateContainer, eventName, handleFunc, ...)
  end
end
function ClientData.AddPlayerCharacterEventWithCondition(delegateContainer, eventName, condTable, handleFunc, ...)
  if ClientSuperData and not ClientData._AddDataObjectEventWithCondition(delegateContainer, ClientSuperData.PlayerCharacter, eventName, condTable, handleFunc, ...) then
    ClientData._AddDelegateCacheWithCondition("PlayerCharacter", delegateContainer, eventName, condTable, handleFunc, ...)
  end
end
function ClientData.AddPlayerControllerEventWithCondition(delegateContainer, eventName, condTable, handleFunc, ...)
  if ClientSuperData and not ClientData._AddDataObjectEventWithCondition(delegateContainer, ClientSuperData.PlayerController, eventName, condTable, handleFunc, ...) then
    ClientData._AddDelegateCacheWithCondition("PlayerController", delegateContainer, eventName, condTable, handleFunc, ...)
  end
end
function ClientData.AddPlayerStateEventWithCondition(delegateContainer, eventName, condTable, handleFunc, ...)
  if ClientSuperData and not ClientData._AddDataObjectEventWithCondition(delegateContainer, ClientSuperData.PlayerState, eventName, condTable, handleFunc, ...) then
    ClientData._AddDelegateCacheWithCondition("PlayerState", delegateContainer, eventName, condTable, handleFunc, ...)
  end
end
function ClientData.AddGameStateEventWithCondition(delegateContainer, eventName, condTable, handleFunc, ...)
  if ClientSuperData and not ClientData._AddDataObjectEventWithCondition(delegateContainer, ClientSuperData.GameState, eventName, condTable, handleFunc, ...) and not ClientData._AddDataObjectEventWithCondition(delegateContainer, CGameState, eventName, condTable, handleFunc, ...) then
    ClientData._AddDelegateCacheWithCondition("GameState", delegateContainer, eventName, condTable, handleFunc, ...)
  end
end
function ClientData._AddDelegateCache(dataKey, delegateContainer, eventName, handleFunc, ...)
  if ClientData.DelegateCache == nil then
    ClientData.DelegateCache = {}
  end
  if ClientData.DelegateCache[dataKey] == nil then
    ClientData.DelegateCache[dataKey] = {}
  end
  local CallbackParams = {
    delegateContainer = delegateContainer,
    eventName = eventName,
    handleFunc = handleFunc,
    args = table.pack(...)
  }
  table.insert(ClientData.DelegateCache[dataKey], CallbackParams)
end
function ClientData._AddDelegateCacheWithCondition(dataKey, delegateContainer, eventName, condTable, handleFunc, ...)
  if ClientData.DelegateCache == nil then
    ClientData.DelegateCache = {}
  end
  if ClientData.DelegateCache[dataKey] == nil then
    ClientData.DelegateCache[dataKey] = {}
  end
  local CallbackParams = {
    delegateContainer = delegateContainer,
    eventName = eventName,
    condTable = condTable,
    handleFunc = handleFunc,
    args = table.pack(...)
  }
  table.insert(ClientData.DelegateCache[dataKey], CallbackParams)
end
function ClientData._RebindDelegate(dataKey)
  if ClientSuperData and slua.isValid(ClientSuperData[dataKey]) and ClientData.DelegateCache[dataKey] ~= nil then
    for index, CallbackParams in pairs(ClientData.DelegateCache[dataKey]) do
      local DelegateContainer = CallbackParams.delegateContainer
      if next(DelegateContainer) and DelegateContainer.IsValid and DelegateContainer:IsValid() then
        if CallbackParams.condTable ~= nil then
          xpcall(function()
            ClientData._AddDataObjectEventWithCondition(CallbackParams.delegateContainer, ClientSuperData[dataKey], CallbackParams.eventName, CallbackParams.condTable, CallbackParams.handleFunc, table.unpack(CallbackParams.args))
          end, require("common.utility").ErrorMessageHandler)
        else
          xpcall(function()
            ClientData._AddDataObjectEvent(CallbackParams.delegateContainer, ClientSuperData[dataKey], CallbackParams.eventName, CallbackParams.handleFunc, table.unpack(CallbackParams.args))
          end, require("common.utility").ErrorMessageHandler)
        end
      end
    end
    ClientData.DelegateCache[dataKey] = nil
  end
end
function ClientData.GetSuperData()
  return ClientSuperData
end
function ClientData.GetPlayerController()
  return ClientSuperData.PlayerController
end
function ClientData.GetPlayerCharacter()
  return ClientSuperData.PlayerCharacter
end
function ClientData.GetPlayerState()
  return ClientSuperData.PlayerState
end
function ClientData.GetGameState()
  return ClientSuperData.GameState
end
function ClientData.AddCharacter(uCharacter)
  ClientData.AllCharacters[#ClientData.AllCharacters + 1] = uCharacter
end
function ClientData.RemoveCharacter(uCharacter)
  for i = #ClientData.AllCharacters, 1, -1 do
    if ClientData.AllCharacters[i] == uCharacter then
      table.remove(ClientData.AllCharacters, i)
    end
  end
end
function ClientData.GetAllCharacters()
  return ClientData.AllCharacters
end
return ClientData