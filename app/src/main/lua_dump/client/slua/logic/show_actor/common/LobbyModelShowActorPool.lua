local bOpenPool = true
local MAX_NUM = 4
local LobbyModelShowActorPool = {
  ModelsPool = {},
  POOL_SIZE = MAX_NUM
}
function LobbyModelShowActorPool.GetModel()
  local loadUIStartTime
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    loadUIStartTime = TimeUtil.GetMicroseconds()
  end
  if not bOpenPool then
    return LobbyModelShowActorPool._CreatModel()
  end
  LobbyModelShowActorPool.ModelsPool = LobbyModelShowActorPool.ModelsPool or {}
  if #LobbyModelShowActorPool.ModelsPool == 0 then
    return LobbyModelShowActorPool._CreatModel()
  end
  local Model = LobbyModelShowActorPool._GetModelFromPool()
  if not slua.isValid(Model) then
    log_error("LobbyModelShowActorPool Model is not Valid")
    return LobbyModelShowActorPool._CreatModel()
  end
  LobbyModelShowActorPool._SetActorActivate(Model)
  if AvatarData.OpenTimeTracer then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local TimeUtil = require("client.common.time_util")
    local loadUIEndTime = TimeUtil.GetMicroseconds()
    log(bWriteLog and string.format("TimeTracer [Avatar][LobbyModel][LobbyModelShowActorPool.GetModel] ActorName:%s bSync=true Pool=true totalTime: [%.3fms]", UKismetSystemLibrary.GetObjectName(Model), (loadUIEndTime - loadUIStartTime) / 1000))
  end
  return Model
end
function LobbyModelShowActorPool.ReleaseModel(Actor)
  if not bOpenPool then
    LobbyModelShowActorPool._DestoryActor(Actor)
    return
  end
  LobbyModelShowActorPool.ModelsPool = LobbyModelShowActorPool.ModelsPool or {}
  if #LobbyModelShowActorPool.ModelsPool >= LobbyModelShowActorPool.POOL_SIZE then
    LobbyModelShowActorPool._DestoryActor(Actor)
    return
  end
  for _, _Actor in pairs(LobbyModelShowActorPool.ModelsPool) do
    if Actor == _Actor then
      log(bWriteLog and "LobbyModelShowActorPool.ReleaseModel Is In Pool")
      return
    end
  end
  table.insert(LobbyModelShowActorPool.ModelsPool, Actor)
  LobbyModelShowActorPool._SetActorSleep(Actor)
end
function LobbyModelShowActorPool.ClearPool()
  for _, actor in pairs(LobbyModelShowActorPool.ModelsPool) do
    LobbyModelShowActorPool._DestoryActor(actor)
  end
  LobbyModelShowActorPool.ModelsPool = {}
end
function LobbyModelShowActorPool._CreatModel()
  log(bWriteLog and "[LobbyAvatar]LobbyModelShowActorPool _CreatModel")
  local loadUIStartTime
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    loadUIStartTime = TimeUtil.GetMicroseconds()
  end
  local World = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(World) then
    log_shipping_client("[LobbyAvatar]LobbyModelShowActorPool _CreatModel World is null")
    return nil
  end
  local LobbyModelShowActorClass = import("/Game/Arts_PlayerBluePrints/Common/NewLobbyModelShowActorBP.NewLobbyModelShowActorBP_C")
  local Actor = World:SpawnActor(LobbyModelShowActorClass, FVector(0, 0, 0), nil, nil)
  if AvatarData.OpenTimeTracer then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local TimeUtil = require("client.common.time_util")
    local loadUIEndTime = TimeUtil.GetMicroseconds()
    log(bWriteLog and string.format("TimeTracer [Avatar][LobbyModel][LobbyModelShowActorPool.GetModel] ActorName:%s bSync=true Pool=false totalTime: [%.3fms]", UKismetSystemLibrary.GetObjectName(Actor), (loadUIEndTime - loadUIStartTime) / 1000))
  end
  return Actor
end
function LobbyModelShowActorPool._DestoryActor(Actor)
  if slua.isValid(Actor) then
    Actor:K2_DestroyActor()
  end
end
function LobbyModelShowActorPool._GetModelFromPool()
  local index = #LobbyModelShowActorPool.ModelsPool
  local Model = LobbyModelShowActorPool.ModelsPool[index]
  table.remove(LobbyModelShowActorPool.ModelsPool, index)
  if not slua.isValid(Model) then
    log_error("LobbyModelShowActorPool Model is not Valid index" .. tostring(index))
  end
  return Model
end
function LobbyModelShowActorPool._SetActorSleep(Actor)
  if not slua.isValid(Actor) then
    return
  end
  if Actor.OnRecycle then
    Actor:OnRecycle()
  end
  Actor:SetActorHiddenInGame(true)
  Actor:SetActorTickEnabled(false)
  Actor:K2_SetActorLocation(FVector(9999, 9999, 9999), false, nil, false)
end
function LobbyModelShowActorPool._SetActorActivate(Actor)
  if not slua.isValid(Actor) then
    return
  end
  if Actor.OnRespawn then
    Actor:OnRespawn()
  end
  Actor:SetActorHiddenInGame(false)
  Actor:SetActorTickEnabled(true)
end
function LobbyModelShowActorPool.SetMaxNum(Num)
  if Num <= MAX_NUM then
    LobbyModelShowActorPool.POOL_SIZE = MAX_NUM
  else
    LobbyModelShowActorPool.POOL_SIZE = Num
  end
end
return LobbyModelShowActorPool