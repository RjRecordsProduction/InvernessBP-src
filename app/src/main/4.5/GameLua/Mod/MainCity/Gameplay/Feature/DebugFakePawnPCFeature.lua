local DebugFakePawnPCFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
local SELF_KEY = "self"
local CONSEC_HIT_THRESHOLD_TO_SHOW = 25
function DebugFakePawnPCFeature:ctor()
  self.lastShowTime = 0
  self.consecHitCount = 0
  self.bEnableFakePawnDebug = false
  self.fakePawns = {}
end
function DebugFakePawnPCFeature:ReceiveBeginPlay()
  DebugFakePawnPCFeature.__super.ReceiveBeginPlay(self)
  printf("DebugFakePawnPCFeature:ReceiveBeginPlay")
end
function DebugFakePawnPCFeature:ReceiveEndPlay()
  DebugFakePawnPCFeature.__super.ReceiveEndPlay(self)
  printf("DebugFakePawnPCFeature:ReceiveEndPlay")
  self:DestroyAllFakePawns()
end
DebugFakePawnPCFeature.ServerRPC.ServerRPC_PosReq = {
  Reliable = true,
  Params = {}
}
DebugFakePawnPCFeature.ClientRPC.ClientRPC_PosRsp = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float
  }
}
DebugFakePawnPCFeature.ClientRPC.ClientRPC_SimPosRsp = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int64,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float
  }
}
function DebugFakePawnPCFeature:SetEnableFakePawnDebug(bEnable)
  self.bEnableFakePawnDebug = bEnable
  if not bEnable then
    if self.timer then
      self:RemoveGameTimer(self.timer)
      self.timer = nil
    end
    self:SetAllFakePawnsVisible(false)
  else
    if not self.timer then
      self.timer = self:AddGameTimer(0.02, true, function()
        self:ServerRPC_PosReq()
      end)
    end
    self:SetAllFakePawnsVisible(true)
  end
end
function DebugFakePawnPCFeature:ServerRPC_PosReq()
  local uChar = self.Owner:GetPlayerCharacterSafety()
  if slua.isValid(uChar) then
    local pos = uChar:K2_GetActorLocation()
    self:ClientRPC_PosRsp(pos.X, pos.Y, pos.Z)
  end
  local selfPS = slua.isValid(self.Owner.PlayerState) and self.Owner.PlayerState
  local selfUID = selfPS and selfPS.UID
  local allPCs = Game:GetAllPlayerControllers()
  if not allPCs then
    return
  end
  for _, pc in pairs(allPCs) do
    if slua.isValid(pc) then
      local ps = slua.isValid(pc.PlayerState) and pc.PlayerState
      local uid = ps and ps.UID
      if uid and uid ~= selfUID then
        local otherChar = pc:GetPlayerCharacterSafety()
        if slua.isValid(otherChar) then
          local pos = otherChar:K2_GetActorLocation()
          printf("DebugFakePawnPCFeature:ServerRPC_PosReq uid=%s pos=%s", uid, pos:ToString())
          self:ClientRPC_SimPosRsp(uid, pos.X, pos.Y, pos.Z)
        end
      end
    end
  end
end
function DebugFakePawnPCFeature:ClientRPC_PosRsp(X, Y, Z)
  local uPlayerPawn = self.Owner:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local uPawnLoc = uPlayerPawn:K2_GetActorLocation()
  local locOnDS = FVector(X, Y, Z)
  local nDisToDS = FVector.DistXY(locOnDS, uPawnLoc)
  log(bWriteLog and "DebugFakePawnPCFeature:ClientRPC_PosRsp nDisToDS = " .. nDisToDS)
  self:SpawnOrUpdateFakePawn(SELF_KEY, locOnDS)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if 500 < nDisToDS then
    self.consecHitCount = self.consecHitCount + 1
    printf("DebugFakePawnPCFeature:ClientRPC_PosRsp hit nDisToDS=%.2f consec=%d", nDisToDS, self.consecHitCount)
    if self.consecHitCount >= CONSEC_HIT_THRESHOLD_TO_SHOW and curTime - self.lastShowTime > 2 then
      self.lastShowTime = curTime
      self.consecHitCount = 0
      ShowDevNotice("###\230\130\168\229\189\147\229\137\141\231\154\132\228\189\141\231\189\174\228\184\142\230\156\141\229\138\161\229\153\168\231\154\132\229\157\144\230\160\135\231\155\184\229\183\174\232\191\135\232\191\156")
    end
  else
    self.consecHitCount = 0
  end
end
function DebugFakePawnPCFeature:ClientRPC_SimPosRsp(uid, X, Y, Z)
  printf("DebugFakePawnPCFeature:ClientRPC_SimPosRsp uid=%s X=%s Y=%s Z=%s", uid, X, Y, Z)
  if not self.bEnableFakePawnDebug then
    return
  end
  self:SpawnOrUpdateFakePawn(uid, FVector(X, Y, Z))
end
function DebugFakePawnPCFeature:SpawnOrUpdateFakePawn(key, pos)
  local entry = self.fakePawns[key]
  if entry and slua.isValid(entry.pawn) then
    entry.targetLoc = pos
    return
  end
  local showActorClass = slua.loadClass("/Game/Mod/EvoBase/BluePrints/Core/BP_FakePawn.BP_FakePawn")
  local pawn = CGameWorld:SpawnActor(showActorClass, pos, FRotator(0, 0, 0), nil)
  self.fakePawns[key] = {pawn = pawn, targetLoc = pos}
  local UKismetMathLibrary = import("KismetMathLibrary")
  self:AddGameTimer(0.01, true, function()
    if not self.bEnableFakePawnDebug then
      return
    end
    local e = self.fakePawns[key]
    if not e or not slua.isValid(e.pawn) then
      return
    end
    local cur = e.pawn:K2_GetActorLocation()
    e.pawn:K2_SetActorLocation(UKismetMathLibrary.VInterpTo(cur, e.targetLoc, 0.01, 20), false, nil, false)
  end)
end
function DebugFakePawnPCFeature:SetAllFakePawnsVisible(bVisible)
  for _, entry in pairs(self.fakePawns) do
    if entry.pawn and slua.isValid(entry.pawn) then
      entry.pawn:SetActorHiddenInGame(not bVisible)
    end
  end
end
function DebugFakePawnPCFeature:DestroyAllFakePawns()
  for _, entry in pairs(self.fakePawns) do
    if entry.pawn and slua.isValid(entry.pawn) then
      entry.pawn:SetLifeSpan(0)
    end
  end
  self.fakePawns = {}
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CDebugFakePawnPCFeature = class(CFeatureBase, nil, DebugFakePawnPCFeature)
return CDebugFakePawnPCFeature