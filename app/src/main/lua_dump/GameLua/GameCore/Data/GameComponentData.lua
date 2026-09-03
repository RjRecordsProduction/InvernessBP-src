local SuperData = require("common.super_data")
local CDelegateContainer = require("common.delegate_container")
local ThisDelegateContainer = CDelegateContainer()
local GameComponentData = {
  DelegateCache = {},
  DataKey2GeterFunction = {}
}
GameComponentData.BackpackComponent = "BackpackComponent"
GameComponentData.VehicleUserComponent = "BP_VehicleUser"
GameComponentData.VaultControllerComponent = "Vault_Controller"
GameComponentData.CharacterWeaponManager = "CharacterWeaponManager"
GameComponentData.BuffSystemComponent = "BuffSystem"
GameComponentData.GetComponentFunctionTable = {
  PlayerController = {
    [GameComponentData.BackpackComponent] = "GetBackpackComponent",
    [GameComponentData.VehicleUserComponent] = "GetVehicleUserComp"
  },
  PlayerCharacter = {
    [GameComponentData.CharacterWeaponManager] = "GetWeaponManager",
    [GameComponentData.VaultControllerComponent] = "GetVaultComponent",
    [GameComponentData.BuffSystemComponent] = "GetBuffComponent"
  }
}
function GameComponentData.InitInagmeEntry()
  GameComponentData.DataKey2GeterFunction = {
    PlayerController = GameComponentData._GetPlayerController,
    PlayerCharacter = GameComponentData._GetPlayerCharacter
  }
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_START, GameComponentData.OnPostSwitch)
end
function GameComponentData.OnPostSwitch(_, _, Status)
  print(bWriteLog and "GameComponentData.OnPostSwitch", Status.current)
  if Status.current == GameStatus.Fighting then
    GameComponentData._InitData()
  else
    GameComponentData._ClearData()
  end
end
function GameComponentData._InitData()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  ThisDelegateContainer:AddUIMessageEvent("UIMsg_ReceiveBackpackComponent", GameComponentData.OnReceiveBackpackComponent)
  ThisDelegateContainer:AddDataListener(GameplayData.GetSuperData(), "PlayerController", GameComponentData.BindPlayerController)
  ThisDelegateContainer:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", GameComponentData.BindPlayerCharacter)
end
function GameComponentData._ClearData()
  GameComponentData.DelegateCache = {}
  ThisDelegateContainer:Dispose()
end
function GameComponentData.OnReceiveBackpackComponent()
  GameComponentData._RebindComponentDelegate("PlayerController", GameComponentData.BackpackComponent)
end
function GameComponentData.BindPlayerController(_, PlayerController)
  local CurPlayerController = GameComponentData._GetPlayerController()
  if slua.isValid(CurPlayerController) then
    return
  end
  if slua.isValid(PlayerController) then
    GameComponentData._BindData("PlayerController", PlayerController)
  end
end
function GameComponentData.BindPlayerCharacter(_, PlayerCharacter)
  if slua.isValid(PlayerCharacter) then
    GameComponentData._BindData("PlayerCharacter", PlayerCharacter)
  end
end
function GameComponentData.AddSelfBackpackComponentEvent(DelegateContainer, EventName, HandleFunc, ...)
  GameComponentData._AddPlayerControllerComponentEvent(GameComponentData.BackpackComponent, DelegateContainer, EventName, HandleFunc, ...)
end
function GameComponentData.AddSelfVehicleUserComponentEvent(DelegateContainer, EventName, HandleFunc, ...)
  GameComponentData._AddPlayerControllerComponentEvent(GameComponentData.VehicleUserComponent, DelegateContainer, EventName, HandleFunc, ...)
end
function GameComponentData.AddSelfVaultControllerComponentEvent(DelegateContainer, EventName, HandleFunc, ...)
  GameComponentData._AddPlayerCharacterComponentEvent(GameComponentData.VaultControllerComponent, DelegateContainer, EventName, HandleFunc, ...)
end
function GameComponentData.AddSelfWeaponManagerComponentEvent(DelegateContainer, EventName, HandleFunc, ...)
  GameComponentData._AddPlayerCharacterComponentEvent(GameComponentData.CharacterWeaponManager, DelegateContainer, EventName, HandleFunc, ...)
end
function GameComponentData.AddSelfBuffComponentEvent(DelegateContainer, EventName, HandleFunc, ...)
  GameComponentData._AddPlayerCharacterComponentEvent(GameComponentData.BuffSystemComponent, DelegateContainer, EventName, HandleFunc, ...)
end
function GameComponentData._AddPlayerControllerComponentEvent(ComponentName, DelegateContainer, EventName, HandleFunc, ...)
  local PlayerController = GameComponentData._GetPlayerController()
  if not slua.isValid(PlayerController) or not slua.isValid(GameComponentData._GetComponent("PlayerController", ComponentName)) then
    GameComponentData._AddDelegateCache("PlayerController", ComponentName, DelegateContainer, EventName, HandleFunc, ...)
  else
    local Component = GameComponentData._GetComponent("PlayerController", ComponentName)
    if slua.isValid(Component) then
      GameComponentData._AddDataObjectEvent(DelegateContainer, Component, EventName, HandleFunc, ...)
    else
      sandbox.LogError("PlayerController dont hava Component: ", ComponentName)
    end
  end
end
function GameComponentData._AddPlayerCharacterComponentEvent(ComponentName, DelegateContainer, EventName, HandleFunc, ...)
  local PlayerCharacter = GameComponentData._GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) or not slua.isValid(GameComponentData._GetComponent("PlayerCharacter", ComponentName)) then
    GameComponentData._AddDelegateCache("PlayerCharacter", ComponentName, DelegateContainer, EventName, HandleFunc, ...)
  else
    local Component = GameComponentData._GetComponent("PlayerCharacter", ComponentName)
    if slua.isValid(Component) then
      GameComponentData._AddDataObjectEvent(DelegateContainer, Component, EventName, HandleFunc, ...)
    else
      sandbox.LogError("PlayerCharacter dont hava Component: ", ComponentName)
    end
  end
end
function GameComponentData._AddDataObjectEvent(DelegateContainer, Object, EventName, HandleFunc, ...)
  if slua.isValid(Object) then
    if DelegateContainer.AddControlEventByControl then
      DelegateContainer:AddControlEventByControl(Object, EventName, HandleFunc, ...)
    else
      DelegateContainer:AddControlEvent(Object, EventName, HandleFunc, ...)
    end
    return true
  end
  return false
end
function GameComponentData._AddDelegateCache(DataKey, ComponentName, DelegateContainer, EventName, HandleFunc, ...)
  local DelegateCache = GameComponentData.DelegateCache
  if DelegateCache[DataKey] == nil then
    DelegateCache[DataKey] = {}
  end
  local CachedComponentTable = DelegateCache[DataKey]
  if CachedComponentTable[ComponentName] == nil then
    CachedComponentTable[ComponentName] = {}
  end
  local ThisCachedComponentTable = CachedComponentTable[ComponentName]
  local CallbackParams = {
    DelegateContainer = DelegateContainer,
    EventName = EventName,
    HandleFunc = HandleFunc,
    Args = table.pack(...)
  }
  ThisCachedComponentTable[CallbackParams] = true
end
function GameComponentData._RebindDelegate(DataKey)
  local CachedComponentTable = GameComponentData.DelegateCache[DataKey]
  if not CachedComponentTable then
    return
  end
  local ComponentNameTable = {}
  for ComponentName, _ in pairs(CachedComponentTable) do
    ComponentNameTable[ComponentName] = true
  end
  for ComponentName, _ in pairs(ComponentNameTable) do
    GameComponentData._RebindComponentDelegate(DataKey, ComponentName)
  end
end
function GameComponentData._RebindComponentDelegate(DataKey, ComponentName)
  local CachedComponentTable = GameComponentData.DelegateCache[DataKey]
  if CachedComponentTable == nil then
    return
  end
  if CachedComponentTable[ComponentName] == nil then
    return
  end
  local Component = GameComponentData._GetComponent(DataKey, ComponentName)
  if not slua.isValid(Component) then
    sandbox.LogError("GameComponentData._RebindComponentDelegate, ", DataKey, " dont hava Component: ", ComponentName)
    return
  end
  for CallbackParams, _ in pairs(CachedComponentTable[ComponentName]) do
    GameComponentData._AddDataObjectEvent(CallbackParams.DelegateContainer, Component, CallbackParams.EventName, CallbackParams.HandleFunc, table.unpack(CallbackParams.Args))
  end
  CachedComponentTable[ComponentName] = nil
end
function GameComponentData._GetComponent(DataKey, ComponentName)
  if GameComponentData.DataKey2GeterFunction[DataKey] == nil then
    return
  end
  local MainActor = GameComponentData.DataKey2GeterFunction[DataKey]()
  if not slua.isValid(MainActor) then
    sandbox.LogWarning("GameComponentData._GetComponent, ", DataKey, " is not Valid ")
    return nil
  end
  if slua.isValid(MainActor[ComponentName]) then
    return MainActor[ComponentName]
  end
  local ComponentFunctionTable = GameComponentData.GetComponentFunctionTable[DataKey]
  if not ComponentFunctionTable then
    sandbox.LogError("GameComponentData._GetComponent, ComponentFunctionTable is nil")
    return nil
  end
  local GetterFunctionName = ComponentFunctionTable[ComponentName]
  if not GetterFunctionName or not MainActor[GetterFunctionName] then
    sandbox.LogError("GameComponentData._GetComponent, GetterFunctionName is nil, ", ComponentName)
    return nil
  end
  local Component = MainActor[GetterFunctionName](MainActor)
  if not slua.isValid(Component) then
    sandbox.LogError("GameComponentData._GetComponent, Component is nil, ", ComponentName)
    return nil
  end
  return Component
end
function GameComponentData._BindData(Key, Value)
  if slua.isValid(Value) then
    GameComponentData._RebindDelegate(Key)
  end
  print(bWriteLog and "GameComponentData._BindData(key, value)", Key, Value)
end
function GameComponentData._GetPlayerController(PlayerKey)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  return GameplayData.GetPlayerController(PlayerKey)
end
function GameComponentData._GetPlayerCharacter(PlayerKey)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  return GameplayData.GetPlayerCharacter(PlayerKey)
end
function GameComponentData.GetSelfBackpackComponent()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return nil
  end
  return PlayerController:GetBackpackComponent()
end
function GameComponentData.GetSelfWeaponManagerComponent()
  GameComponentData._GetComponent("PlayerCharacter", GameComponentData.CharacterWeaponManager)
end
function GameComponentData.GetSelfVehicleUserComp()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return nil
  end
  return PlayerController:GetVehicleUserComp()
end
return GameComponentData