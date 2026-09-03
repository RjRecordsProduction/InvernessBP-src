local DEFAULT_MAX_NUM = 2
local Switch = true
local UseMemAdaptiveNum = true
local POOL_SIZE_MAP = {
  LOW_MEM = 2,
  MEDIUM_MEM = 3,
  HIGH_MEM = 5
}
local LobbyPawnPool = {
  PawnList = {},
  PreParePawnList = {},
  PrePareIndex = 0,
  PrePareTimer = {},
  PrePareTime = 1,
  bInit = false,
  MaxNum = DEFAULT_MAX_NUM
}
local UKismetSystemLibrary = import("KismetSystemLibrary")
local PlayerLobbyPawnClass
local _CreatePawn = function()
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    LobbyPawnPool.StartTime = TimeUtil.GetMicroseconds()
  end
  local World = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(World) then
    log_shipping_client("[LobbyAvatar]LobbyPawnPool _CreatePawn World is null")
    return nil
  end
  PlayerLobbyPawnClass = import("/Game/Arts_PlayerBluePrints/Character_Show/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn_C")
  local PlayerLobbyPawn = World:SpawnActor(PlayerLobbyPawnClass, FVector(0, 0, 0), nil, nil)
  log(bWriteLog and "[LobbyAvatar]LobbyPawnPool _CreatePawn")
  if Client and Client.IsLowMemoryDevice and Client.IsLowMemoryDevice() then
    PlayerLobbyPawnClass = nil
  end
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    local EndTime = TimeUtil.GetMicroseconds()
    log(bWriteLog and string.format("TimeTracer [Avatar][LobbyPawn][lobbyPawnPool._CreatePawn] ActorName: %s bSync=true Pool=false totalTime: [%.3fms]", UKismetSystemLibrary.GetObjectName(PlayerLobbyPawn), (EndTime - LobbyPawnPool.StartTime) / 1000))
  end
  return PlayerLobbyPawn
end
local _DestroyPawn = function(Pawn)
  if slua.isValid(Pawn) then
    Pawn:K2_DestroyActor()
  end
end
local _GetPoolSize = function()
  if not UseMemAdaptiveNum then
    log(bWriteLog and "[LobbyAvatar]LobbyPawnPool._GetPoolSize Use Default Size")
    return DEFAULT_MAX_NUM
  end
  local memorySize = Client.GetMemorySize()
  if 4 < memorySize then
    log(bWriteLog and "[LobbyAvatar]LobbyPawnPool._GetPoolSize Use HIGH_MEM Size")
    return POOL_SIZE_MAP.HIGH_MEM
  elseif 2 < memorySize then
    log(bWriteLog and "[LobbyAvatar]LobbyPawnPool._GetPoolSize Use MEDIUM_MEM Size")
    return POOL_SIZE_MAP.MEDIUM_MEM
  else
    log(bWriteLog and "[LobbyAvatar]LobbyPawnPool._GetPoolSize Use LOW_MEM Size")
    return POOL_SIZE_MAP.LOW_MEM
  end
end
local _OnPawnReuse = function(Pawn)
  if not slua.isValid(Pawn) then
    return
  end
  Pawn:SetActorHiddenInGame(false)
  if Pawn.SetLobbyPawnTick then
    log(bWriteLog and "_OnPawnReuse SetLobbyPawnTick")
    Pawn:SetLobbyPawnTick(true)
  end
end
local _OnPawnRelease = function(Pawn)
  log(bWriteLog and "[LobbyAvatar]LobbyPawnPool._OnPawnRelease")
  if not slua.isValid(Pawn) then
    return
  end
  Pawn:SetActorTickEnabled(false)
  Pawn:SetActorHiddenInGame(true)
  local EDetachmentRule = import("EDetachmentRule")
  Pawn:K2_DetachFromActor(EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld)
end
function LobbyPawnPool._Init()
  if LobbyPawnPool.bInit then
    return
  end
  LobbyPawnPool.bInit = true
  LobbyPawnPool.MaxNum = _GetPoolSize()
  LobbyPawnPool._ResetPawnList()
end
function LobbyPawnPool._ResetPawnList()
  for _, Pawn in pairs(LobbyPawnPool.PawnList) do
    _DestroyPawn(Pawn)
  end
  LobbyPawnPool.PawnList = {}
  for _, Pawn in pairs(LobbyPawnPool.PreParePawnList) do
    _DestroyPawn(Pawn)
  end
  LobbyPawnPool.PreParePawnList = {}
  local time_ticker = require("common.time_ticker")
  for _, Timer in pairs(LobbyPawnPool.PrePareTimer) do
    if Timer then
      time_ticker.RemoveTimer(Timer)
    end
  end
  LobbyPawnPool.PrePareTimer = {}
end
function LobbyPawnPool._GetTailValidPawn()
  local TailIndex = #LobbyPawnPool.PawnList
  if TailIndex == 0 then
    return nil
  end
  local Pawn = LobbyPawnPool.PawnList[TailIndex]
  table.remove(LobbyPawnPool.PawnList, TailIndex)
  if not slua.isValid(Pawn) then
    log(bWriteLog and "[LobbyAvatar]LobbyPawnPool._GetTailValidPawn Pawn Valid")
    return LobbyPawnPool._GetTailValidPawn()
  else
    log(bWriteLog and "[LobbyAvatar]LobbyPawnPool._GetTailValidPawn Get Fromm Pool Index" .. TailIndex)
    return Pawn
  end
end
function LobbyPawnPool.Get()
  if not Switch then
    return _CreatePawn()
  end
  log(bWriteLog and "[LobbyAvatar]LobbyPawnPool.Get")
  LobbyPawnPool._Init()
  if #LobbyPawnPool.PawnList == 0 then
    log(bWriteLog and "[LobbyAvatar]LobbyPawnPool.Get Create New")
    return _CreatePawn()
  end
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    LobbyPawnPool.StartTime = TimeUtil.GetMicroseconds()
  end
  local Pawn = LobbyPawnPool._GetTailValidPawn()
  _OnPawnReuse(Pawn)
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    local EndTime = TimeUtil.GetMicroseconds()
    log(bWriteLog and string.format("TimeTracer [Avatar][LobbyPawn][lobbyPawnPool._CreatePawn] ActorName: %s bSync=true Pool=true totalTime: [%.3fms]", UKismetSystemLibrary.GetObjectName(Pawn), (EndTime - LobbyPawnPool.StartTime) / 1000))
  end
  return Pawn
end
function LobbyPawnPool.Release(Pawn)
  log(bWriteLog and "[LobbyAvatar]LobbyPawnPool.Release")
  if not slua.isValid(Pawn) then
    return
  end
  if not Switch then
    _DestroyPawn(Pawn)
    return
  end
  if #LobbyPawnPool.PawnList + LobbyPawnPool._GetPreparePawnNum() == LobbyPawnPool.MaxNum then
    log(bWriteLog and "[LobbyAvatar]LobbyPawnPool.Release Reach Max Num ,Destroy")
    _DestroyPawn(Pawn)
    return
  end
  Pawn:SetIsRecycled(true)
  Pawn:OnRecycle()
  _OnPawnRelease(Pawn)
  LobbyPawnPool._InsertPreParePool(Pawn)
end
function LobbyPawnPool._InsertPreParePool(Pawn)
  local _Index = LobbyPawnPool.PrePareIndex
  LobbyPawnPool.PrePareIndex = LobbyPawnPool.PrePareIndex + 1
  LobbyPawnPool.PreParePawnList[_Index] = Pawn
  log(bWriteLog and "LobbyPawnPool._InsertPreParePool Index:" .. tostring(_Index) .. " Pawn: " .. tostring(UKismetSystemLibrary.GetObjectName(Pawn)))
  local time_ticker = require("common.time_ticker")
  LobbyPawnPool.PrePareTimer[_Index] = time_ticker.AddTimerOnce(LobbyPawnPool.PrePareTime, function()
    LobbyPawnPool.PreParePawnList[_Index] = nil
    LobbyPawnPool.PrePareTimer[_Index] = nil
    if slua.isValid(Pawn) then
      log(bWriteLog and "LobbyPawnPool._InsertPreParePool InsertPawnList Index:" .. tostring(_Index) .. "Pawn: " .. tostring(UKismetSystemLibrary.GetObjectName(Pawn)))
      table.insert(LobbyPawnPool.PawnList, Pawn)
    else
      log_error("LobbyPawnPool._InsertPreParePool Pawn Is not Valid Index" .. tostring(_Index))
    end
  end)
end
function LobbyPawnPool._GetPreparePawnNum()
  local Num = 0
  for _, _Pawn in pairs(LobbyPawnPool.PreParePawnList) do
    if slua.isValid(_Pawn) then
      Num = Num + 1
    end
  end
  return Num
end
function LobbyPawnPool.SetMaxNum(Num)
  if Num <= DEFAULT_MAX_NUM then
    LobbyPawnPool.MaxNum = _GetPoolSize()
  else
    LobbyPawnPool.Max  end
end
function LobbyPawnPool.Destroy()
  LobbyPawnPool.bInit = false
  LobbyPawnPool._ResetPawnList()
end
function LobbyPawnPool.GMSetSwitch(bOpen)
  Switch = bOpen
end
function LobbyPawnPool.IsSwitchOn()
  return Switch
end
function LobbyPawnPool.ReleasePawnClass()
  PlayerLobbyPawnClass = nil
end
return LobbyPawnPool