local LobbyShowActorConfig = require("client.slua.logic.show_actor.common.LobbyShowActorConfig")
local Switch = true
local TypeSwtich = {
  [LobbyShowActorConfig.Type.Weapon] = false,
  [LobbyShowActorConfig.Type.Vehicle] = false,
  [LobbyShowActorConfig.Type.Plane] = false,
  [LobbyShowActorConfig.Type.Grenade] = true,
  [LobbyShowActorConfig.Type.BagWidget] = true,
  [LobbyShowActorConfig.Type.RefitVehicle] = false,
  [LobbyShowActorConfig.Type.Parachute] = true,
  [LobbyShowActorConfig.Type.Icon3D] = true,
  [LobbyShowActorConfig.Type.Bag] = true,
  [LobbyShowActorConfig.Type.Wingman] = false,
  [LobbyShowActorConfig.Type.MiniTv] = false,
  [LobbyShowActorConfig.Type.Holography] = false,
  [LobbyShowActorConfig.Type.Statues] = false,
  [LobbyShowActorConfig.Type.Tank] = false,
  [LobbyShowActorConfig.Type.Home3DAsset] = false,
  [LobbyShowActorConfig.Type.Common3DModel] = false,
  [LobbyShowActorConfig.Type.MTLB] = false
}
local MAX_NUM = 2
local LobbyModelPool = {
  ModelsPool = {}
}
local _CreatModel = function(ModelType)
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    LobbyModelPool.StartTime = TimeUtil.GetMicroseconds()
  end
  local Config = LobbyShowActorConfig.ModelConfig[ModelType]
  local World = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(World) then
    log_shipping_client("[LobbyAvatar]LobbyModelPool _CreatModel World is null")
    return nil
  end
  local PawnClass = import(Config.ActorPath)
  local Actor = World:SpawnActor(PawnClass, FVector(0, 0, 0), nil, nil)
  log(bWriteLog and "[LobbyAvatar]LobbyModelPool _CreatModel")
  if AvatarData.OpenTimeTracer then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local TimeUtil = require("client.common.time_util")
    local EndTime = TimeUtil.GetMicroseconds()
    log(bWriteLog and string.format("TimeTracer [Avatar][LobbyModel][LobbyModelPool._CreatModel] ActorName: %s bSync=true Pool=false totalTime: [%.3fms]", UKismetSystemLibrary.GetObjectName(Actor), (EndTime - LobbyModelPool.StartTime) / 1000))
  end
  return Actor
end
local _DestoryActor = function(Actor)
  if slua.isValid(Actor) then
    Actor:K2_DestroyActor()
  end
end
local _GetModelByType = function(ModelType)
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    LobbyModelPool.StartTime = TimeUtil.GetMicroseconds()
  end
  local index = #LobbyModelPool.ModelsPool[ModelType]
  local Model = LobbyModelPool.ModelsPool[ModelType][index]
  table.remove(LobbyModelPool.ModelsPool[ModelType], index)
  if not slua.isValid(Model) then
    log_error("LobbyModelPool Model is not Valid ModelType" .. tostring(ModelType))
    Model = _CreatModel(ModelType)
  end
  if AvatarData.OpenTimeTracer then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local TimeUtil = require("client.common.time_util")
    local EndTime = TimeUtil.GetMicroseconds()
    log(bWriteLog and string.format("TimeTracer [Avatar][LobbyModel][LobbyModelPool._GetModelByType] ActorName: %s bSync=true Pool=true totalTime: [%.3fms]", UKismetSystemLibrary.GetObjectName(Model), (EndTime - LobbyModelPool.StartTime) / 1000))
  end
  return Model
end
local _SetActorSleep = function(Actor)
  if not slua.isValid(Actor) then
    return
  end
  if Actor.Sleep then
    Actor:Sleep()
  end
  Actor:SetActorHiddenInGame(true)
  Actor:SetActorTickEnabled(false)
  Actor:K2_SetActorLocation(FVector(9999, 9999, 9999), false, nil, false)
end
local _SetActorActivate = function(Actor)
  if not slua.isValid(Actor) then
    return
  end
  if Actor.Activate then
    Actor:Activate()
  end
  Actor:SetActorHiddenInGame(false)
  Actor:SetActorTickEnabled(true)
end
function LobbyModelPool.GetModel(ModelType)
  if not Switch or not TypeSwtich[ModelType] then
    return _CreatModel(ModelType)
  end
  LobbyModelPool.ModelsPool[ModelType] = LobbyModelPool.ModelsPool[ModelType] or {}
  if #LobbyModelPool.ModelsPool[ModelType] == 0 then
    return _CreatModel(ModelType)
  end
  local Model = _GetModelByType(ModelType)
  _SetActorActivate(Model)
  return Model
end
function LobbyModelPool.ReleaseModel(ModelType, Actor)
  if not Switch or not TypeSwtich[ModelType] then
    _DestoryActor(Actor)
    return
  end
  LobbyModelPool.ModelsPool[ModelType] = LobbyModelPool.ModelsPool[ModelType] or {}
  if #LobbyModelPool.ModelsPool[ModelType] >= MAX_NUM then
    _DestoryActor(Actor)
    return
  end
  table.insert(LobbyModelPool.ModelsPool[ModelType], Actor)
  _SetActorSleep(Actor)
end
function LobbyModelPool.ClearPool()
  for _, List in pairs(LobbyModelPool.ModelsPool) do
    for _, actor in ipairs(List) do
      _DestoryActor(actor)
    end
  end
  LobbyModelPool.ModelsPool = {}
end
return LobbyModelPool