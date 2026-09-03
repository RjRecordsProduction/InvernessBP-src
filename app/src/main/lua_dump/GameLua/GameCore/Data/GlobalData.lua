local DataCache = {}
function DataCache:AddUObject(InObject)
  if slua.isValid(InObject) and InObject.PlayerKey then
    local nPlayerKey = tonumber(InObject.PlayerKey)
    if 0 < nPlayerKey then
      self._AllObjcet[nPlayerKey] = InObject
    else
      self._AllNoPlayerKeyObject[#self._AllNoPlayerKeyObject + 1] = InObject
    end
  end
end
function DataCache:RemoveUObject(InObject)
  if slua.isValid(InObject) and InObject.PlayerKey then
    local nPlayerKey = tonumber(InObject.PlayerKey)
    local bRemoved = false
    if 0 < nPlayerKey and self._AllObjcet[nPlayerKey] ~= nil then
      self._AllObjcet[nPlayerKey] = nil
      bRemoved = true
    end
    if not bRemoved then
      for i, v in pairs(self._AllNoPlayerKeyObject) do
        if v == InObject then
          table.remove(self._AllNoPlayerKeyObject, i)
          break
        end
      end
    end
  end
end
function DataCache:GetUObject(nPlayerKey)
  nPlayerKey = tonumber(nPlayerKey)
  if nPlayerKey and 0 < nPlayerKey then
    local OutObject = self._AllObjcet[nPlayerKey]
    if OutObject == nil then
      for i, TempObject in pairs(self._AllNoPlayerKeyObject) do
        if TempObject and slua.isValid(TempObject) then
          local curPlayerKey = TempObject.PlayerKey
          if curPlayerKey and curPlayerKey == nPlayerKey then
            self._AllObjcet[nPlayerKey] = TempObject
            table.remove(self._AllNoPlayerKeyObject, i)
            OutObject = TempObject
            break
          end
        end
      end
    end
    if OutObject ~= nil or Client and Client.IsShipping() or Server and Server.IsShipping() then
    else
      print(bWriteLog and string.format("DataCache:GetUObject nil nPlayerKey:{%d} ", nPlayerKey))
    end
    return OutObject
  end
  return nil
end
function DataCache:GetAllUObject()
  return self._AllObjcet
end
function DataCache:__index(k)
  if DataCache[k] then
    return DataCache[k]
  end
end
local CreateDataCache = function(sName)
  local GameplayCacheData = setmetatable({
    _Name = sName,
    _AllObjcet = {},
    _AllNoPlayerKeyObject = {}
  }, DataCache)
  return GameplayCacheData
end
local GameGlobalData = {
  ControllerCaches = nil,
  CharacterCaches = nil,
  PlayerStateCaches = nil,
  GameState = nil,
  bClient = nil,
  bStandAlone = nil
}
function GameGlobalData:__index(k)
  if GameGlobalData[k] then
    return GameGlobalData[k]
  end
end
function GameGlobalData._InitData()
  GameGlobalData.ControllerCaches = CreateDataCache("ControllerCaches")
  GameGlobalData.CharacterCaches = CreateDataCache("CharacterCaches")
  GameGlobalData.PlayerStateCaches = CreateDataCache("PlayerStateCaches")
end
function GameGlobalData._ClearData()
  local SuperData = require("common.super_data")
  GameGlobalData.ControllerCaches = nil
  GameGlobalData.CharacterCaches = nil
  GameGlobalData.PlayerStateCaches = nil
  GameGlobalData.GameState = nil
end
function GameGlobalData.InitStandAloneEntry()
  GameGlobalData.bStandAlone = true
  GameGlobalData._InitData()
end
function GameGlobalData.InitInagmeEntry(bClient)
  GameGlobalData.  if bClient then
    EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_START, GameGlobalData.OnPostSwitch)
  else
    GameGlobalData._InitData()
  end
end
function GameGlobalData.OnPostSwitch(_, _, status)
  print(bWriteLog and "GameGlobalData.OnPostSwitch", status.current)
  if status.current == GameStatus.Fighting then
    if not GameGlobalData.bStandAlone then
      GameGlobalData._InitData()
    end
  else
    GameGlobalData.bStandAlone = false
    GameGlobalData._ClearData()
  end
end
function GameGlobalData._BindGlobalData(key, value)
  if slua.isValid(value) and type(GameGlobalData[key]) == "table" then
    GameGlobalData[key]:AddUObject(value)
  end
end
function GameGlobalData._UnbindGlobalData(key, value)
  if slua.isValid(value) and type(GameGlobalData[key]) == "table" then
    GameGlobalData[key]:RemoveUObject(value)
  end
end
function GameGlobalData._GetGlobalData(key, nPlayerKey)
  if GameGlobalData[key] then
    return GameGlobalData[key]:GetUObject(nPlayerKey)
  end
  return nil
end
function GameGlobalData._GetAllGlobalData(key)
  if GameGlobalData[key] then
    return GameGlobalData[key]:GetAllUObject()
  end
  return nil
end
function GameGlobalData._AddDataObjectEvent(delegateContainer, uObject, eventName, handleFunc, ...)
  if slua.isValid(uObject) then
    if delegateContainer.AddControlEventByControl then
      delegateContainer:AddControlEventByControl(uObject, eventName, handleFunc, ...)
    else
      delegateContainer:AddControlEvent(uObject, eventName, handleFunc, ...)
    end
    return true
  end
  return false
end
function GameGlobalData._AddDataObjectEventWithCondition(delegateContainer, uObject, eventName, condTable, handleFunc, ...)
  if slua.isValid(uObject) then
    if delegateContainer.AddControlEventByControlWithCondition then
      delegateContainer:AddControlEventByControlWithCondition(uObject, eventName, condTable, handleFunc, ...)
    else
      delegateContainer:AddControlEventWithCondition(uObject, eventName, condTable, handleFunc, ...)
    end
    return true
  end
  return false
end
function GameGlobalData.BindPlayerController(uPlayerController)
  GameGlobalData._BindGlobalData("ControllerCaches", uPlayerController)
end
function GameGlobalData.BindPlayerCharacter(uPlayerCharacter)
  GameGlobalData._BindGlobalData("CharacterCaches", uPlayerCharacter)
end
function GameGlobalData.BindPlayerState(uPlayerState)
  GameGlobalData._BindGlobalData("PlayerStateCaches", uPlayerState)
end
function GameGlobalData.UnbindPlayerController(uPlayerController)
  GameGlobalData._UnbindGlobalData("ControllerCaches", uPlayerController)
end
function GameGlobalData.UnbindPlayerCharacter(uPlayerCharacter)
  GameGlobalData._UnbindGlobalData("CharacterCaches", uPlayerCharacter)
end
function GameGlobalData.UnbindPlayerState(uPlayerState)
  GameGlobalData._UnbindGlobalData("PlayerStateCaches", uPlayerState)
end
function GameGlobalData.BindGameState(uGameState)
  GameGlobalData.GameState = uGameState
end
function GameGlobalData.AddPlayerControllerEvent(delegateContainer, nPlayerKey, eventName, handleFunc, ...)
  local uPlayerController = GameGlobalData.GetPlayerController(nPlayerKey)
  GameGlobalData._AddDataObjectEvent(delegateContainer, uPlayerController, eventName, handleFunc, ...)
end
function GameGlobalData.AddPlayerCharacterEvent(delegateContainer, nPlayerKey, eventName, handleFunc, ...)
  local uPlayerCharacter = GameGlobalData.GetPlayerCharacter(nPlayerKey)
  GameGlobalData._AddDataObjectEvent(delegateContainer, uPlayerCharacter, eventName, handleFunc, ...)
end
function GameGlobalData.AddPlayerStateEvent(delegateContainer, nPlayerKey, eventName, handleFunc, ...)
  local uPlayerState = GameGlobalData.GetPlayerState(nPlayerKey)
  GameGlobalData._AddDataObjectEvent(delegateContainer, uPlayerState, eventName, handleFunc, ...)
end
function GameGlobalData.AddGameStateEvent(delegateContainer, eventName, handleFunc, ...)
  if not GameGlobalData._AddDataObjectEvent(delegateContainer, GameGlobalData.GameState, eventName, handleFunc, ...) then
    GameGlobalData._AddDataObjectEvent(delegateContainer, CGameState, eventName, handleFunc, ...)
  end
end
function GameGlobalData.AddPlayerControllerEventWithCondition(delegateContainer, nPlayerKey, eventName, condTable, handleFunc, ...)
  local uPlayerController = GameGlobalData.GetPlayerController(nPlayerKey)
  GameGlobalData._AddDataObjectEventWithCondition(delegateContainer, uPlayerController, eventName, condTable, handleFunc, ...)
end
function GameGlobalData.AddPlayerCharacterEventWithCondition(delegateContainer, nPlayerKey, eventName, condTable, handleFunc, ...)
  local uPlayerCharacter = GameGlobalData.GetPlayerCharacter(nPlayerKey)
  GameGlobalData._AddDataObjectEventWithCondition(delegateContainer, uPlayerCharacter, eventName, condTable, handleFunc, ...)
end
function GameGlobalData.AddPlayerStateEventWithCondition(delegateContainer, nPlayerKey, eventName, condTable, handleFunc, ...)
  local uPlayerState = GameGlobalData.GetPlayerState(nPlayerKey)
  GameGlobalData._AddDataObjectEventWithCondition(delegateContainer, uPlayerState, eventName, condTable, handleFunc, ...)
end
function GameGlobalData.AddGameStateEventWithCondition(delegateContainer, eventName, condTable, handleFunc, ...)
  if not GameGlobalData._AddDataObjectEventWithCondition(delegateContainer, GameGlobalData.GameState, eventName, condTable, handleFunc, ...) then
    GameGlobalData._AddDataObjectEventWithCondition(delegateContainer, CGameState, eventName, condTable, handleFunc, ...)
  end
end
function GameGlobalData.GetPlayerController(nPlayerKey)
  return GameGlobalData._GetGlobalData("ControllerCaches", nPlayerKey)
end
function GameGlobalData.GetPlayerCharacter(nPlayerKey)
  return GameGlobalData._GetGlobalData("CharacterCaches", nPlayerKey)
end
function GameGlobalData.GetPlayerState(nPlayerKey)
  return GameGlobalData._GetGlobalData("PlayerStateCaches", nPlayerKey)
end
function GameGlobalData.GetGameState()
  return GameGlobalData.GameState
end
function GameGlobalData.GetAllPlayerControllers()
  return GameGlobalData._GetAllGlobalData("ControllerCaches")
end
function GameGlobalData.GetAllPlayerCharacters()
  return GameGlobalData._GetAllGlobalData("CharacterCaches")
end
function GameGlobalData.GetAllPlayerStates()
  return GameGlobalData._GetAllGlobalData("PlayerStateCaches")
end
return GameGlobalData