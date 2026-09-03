local SuperData = require("common.super_data")
local ClientSuperData = SuperData.CreateSuperData({})
local GameplayActorData = {
  DelegateCache = {}
}
function GameplayActorData.InitInagmeEntry()
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_START, GameplayActorData.OnPostSwitch)
end
function GameplayActorData.OnPostSwitch(_, _, Status)
  print(bWriteLog and "GameplayActorData.OnPostSwitch", Status.current)
  if Status.current == GameStatus.Fighting then
    GameplayActorData._InitData()
  else
    GameplayActorData._ClearData()
  end
end
function GameplayActorData._InitData()
end
function GameplayActorData._ClearData()
  ClientSuperData = SuperData.CreateSuperData({})
  GameplayActorData.DelegateCache = {}
end
function GameplayActorData.GetSelfActor(ActorName)
  return ClientSuperData[ActorName]
end
function GameplayActorData.GetSuppertData()
  return ClientSuperData
end
function GameplayActorData.BindSelfActor(ActorName, Actor)
  ClientSuperData[ActorName] = Actor
end
function GameplayActorData.UnBindSelfActor(ActorName)
  ClientSuperData[ActorName] = nil
end
function GameplayActorData.GetCurrentVehicle()
  return ClientSuperData.CurrentVehicle
end
function GameplayActorData.GetCurrentWeapon()
  return ClientSuperData.CurrentWeapon
end
return GameplayActorData