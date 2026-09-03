local CONST_PET_COUNT = 2
local pet_pawn_pool = {}
function pet_pawn_pool:DefineAndResetData()
  self.bEnabled = true
  self.POOL_SIZE = CONST_PET_COUNT
  self:_ResetPawnPool()
end
function pet_pawn_pool:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:_ResetPawnPool()
  end
end
function pet_pawn_pool:GetAsy(BPPath, Callback)
  log(bWriteLog and "  pet_pawn_pool:GetAsy. BPPath: " .. tostring(BPPath))
  if not BPPath and Callback then
    Callback(nil)
  end
  if self.bEnabled then
    local PawnFromPool = self:_GetOneFromPool(BPPath)
    if slua.isValid(PawnFromPool) then
      self:_OnPetPawnReuse(PawnFromPool)
      if Callback then
        Callback(PawnFromPool)
      end
      return
    end
  end
  self:_CreatePetPawn(BPPath, Callback)
end
function pet_pawn_pool:Release(Pawn)
  if not slua.isValid(Pawn) then
    return
  end
  if not self.bEnabled then
    self:_DestroyPetPawn(Pawn)
    return
  end
  local BPPath = Pawn:GetBPPath()
  if not BPPath then
    self:_DestroyPetPawn(Pawn)
    return
  end
  if not self.PetPawnMap then
    self.PetPawnMap = {}
  end
  local PetPawnList = self.PetPawnMap[BPPath]
  if not PetPawnList then
    PetPawnList = {}
    self.PetPawnMap[BPPath] = PetPawnList
  end
  if #PetPawnList >= pet_pawn_pool.POOL_SIZE then
    self:_DestroyPetPawn(Pawn)
    return
  end
  PetPawnList[#PetPawnList + 1] = Pawn
  self:_OnPetPawnRelease(Pawn)
end
function pet_pawn_pool:SetPetPawnEnabled(bEnabled)
  self.end
function pet_pawn_pool:_CreatePetPawn(BPPath, Callback)
  if not BPPath then
    if Callback then
      Callback(nil)
    end
    return
  end
  log(bWriteLog and "  pet_pawn_pool:_CreatePetPawn.  ")
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(BPPath, function(ClassObj)
    log(bWriteLog and "  pet_pawn_pool:_CreatePetPawn.  callback" .. tostring(ClassObj))
    local World = slua_GameFrontendHUD:GetWorld()
    local PetActor = World:SpawnActor(ClassObj, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
    if PetActor then
      PetActor:SetBPPath(BPPath)
    end
    if Callback then
      Callback(PetActor)
    end
  end)
end
function pet_pawn_pool:_DestroyPetPawn(Pawn)
  if slua.isValid(Pawn) then
    Pawn:K2_DestroyActor()
  end
end
function pet_pawn_pool:_ResetPawnPool()
  if self.PetPawnMap and next(self.PetPawnMap) then
    for _, PetPawnList in pairs(self.PetPawnMap) do
      if PetPawnList and next(PetPawnList) then
        for _, Pawn in pairs(PetPawnList) do
          self:_DestroyPetPawn(Pawn)
        end
      end
    end
  end
  self.PetPawnMap = {}
end
function pet_pawn_pool:ReleasePool()
  self:_ResetPawnPool()
end
function pet_pawn_pool:_GetOneFromPool(BPPath)
  if not BPPath or not self.PetPawnMap then
    return nil
  end
  local PetList = self.PetPawnMap[BPPath]
  if not PetList or not next(PetList) then
    return nil
  end
  local LastIndex = #PetList
  local Pawn = PetList[#PetList]
  PetList[LastIndex] = nil
  if slua.isValid(Pawn) then
    return Pawn
  else
    log_warning("pet_pawn_pool:_GetOneFromPool Pawn is not Valid, try get next one")
    return self:_GetOneFromPool(BPPath)
  end
end
function pet_pawn_pool:_OnPetPawnReuse(Pawn)
  if not slua.isValid(Pawn) then
    return
  end
  Pawn:OnPawnReused()
end
function pet_pawn_pool:_OnPetPawnRelease(Pawn)
  if not slua.isValid(Pawn) then
    return
  end
  Pawn:OnPawnReleased()
end
function pet_pawn_pool.SetMaxNum(Num)
  if Num <= CONST_PET_COUNT then
    pet_pawn_pool.POOL_SIZE = CONST_PET_COUNT
  else
    pet_pawn_pool.POOL_SIZE = Num
  end
end
local class = require("class")
local ModuleBase = require("client.module_framework.ModuleBase")
local Cpet_pawn_pool = class(ModuleBase, nil, pet_pawn_pool)
return Cpet_pawn_pool