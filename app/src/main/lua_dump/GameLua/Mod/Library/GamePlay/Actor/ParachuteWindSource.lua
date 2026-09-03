local UGameplayStatics = import("GameplayStatics")
local UKismetMathLibrary = import("KismetMathLibrary")
local math = require("math")
local ParachuteWindSource = {}
function ParachuteWindSource:ctor(selfType)
  print("ParachuteWindSource:ctor")
  ParachuteWindSource.__super.ctor(self, selfType)
  self.TempVector1 = FVector()
  self.TempVector2 = FVector()
  self.Rotator = FRotator(0, 0, 0)
end
function ParachuteWindSource:ReceiveBeginPlay()
  print("ParachuteWindSource:ReceiveBeginPlay")
  ParachuteWindSource.__super.ReceiveBeginPlay(self)
  self:InitSourceData()
  self.TickScale = 0.3
  self:AddGameTimer(0.1, true, function()
    self:TickSourceData()
  end)
end
function ParachuteWindSource:ReceiveEndPlay(EndReason, bClearTable)
  print("ParachuteWindSource:ReceiveEndPlay")
  ParachuteWindSource.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
function ParachuteWindSource:TickSourceData()
  print("ParachuteWindSource:TickSourceData")
  self:UpdateTargetTransform()
  self:SyncWindSourcePos()
  self:UpdateResistanceWind()
  self:UpdateNaturalWind()
  self:CalcFinalWind()
  self:SyncWindSourceRotate()
  self:SyncWindSourceSpeed()
end
function ParachuteWindSource:UpdateTargetTransform()
  local Pawn = UGameplayStatics.GetPlayerPawn(self, 0)
  if Pawn and slua.isValid(Pawn) then
    local PawnVector = Pawn:GetActorUpVector()
    if PawnVector and slua.isValid(PawnVector) then
      self.TargetUpVector = PawnVector
    end
    local PawnPosition = Pawn:K2_GetActorLocation()
    if PawnPosition and slua.isValid(PawnPosition) then
      self.TargetPos = PawnPosition
    end
  end
end
function ParachuteWindSource:SyncWindSourcePos()
end
function ParachuteWindSource:UpdateResistanceWind()
  local CachePos = slua.IndexReference(self, "CachePos")
  local TargetPos = slua.IndexReference(self, "TargetPos")
  local ResistanceWindVector = slua.IndexReference(self, "ResistanceWindVector")
  ResistanceWindVector.X = CachePos.X - TargetPos.X
  ResistanceWindVector.Y = CachePos.Y - TargetPos.Y
  ResistanceWindVector.Z = CachePos.Z - TargetPos.Z
  self.CachePos = TargetPos
  self.MoveDirLengthSquared = ResistanceWindVector:SizeSquared() * self.TickScale
  if self.MoveDirLengthSquared < 0.1 then
    self.ResistanceWindSpeed = 0
  else
    local MoveDirLength = math.sqrt(self.MoveDirLengthSquared)
    local ClampValue = FuncUtil.Clamp(MoveDirLength, 0, self.MaxResistanceLength)
    self.ResistanceWindSpeed = ClampValue * self.ResistanceFactor
  end
end
function ParachuteWindSource:UpdateNaturalWind()
  self.NaturalWindVector = slua.IndexReference(self, "TargetUpVector")
  self.NaturalWindSpeed = self.ResistanceWindSpeed * self.NaturalWindOffset + 0.5
end
function ParachuteWindSource:CalcFinalWind()
  if self.ResistanceWindSpeed > 0 then
    if 0 < self.NaturalWindSpeed then
      local UEMathUtilityMethods = import("UEMathUtilityMethods")
      local TempVector1 = self.TempVector1
      local TempVector2 = self.TempVector2
      local FinalWindVector = slua.IndexReference(self, "FinalWindVector")
      UEMathUtilityMethods.VectorNormalizeMultiple(TempVector1, slua.IndexReference(self, "NaturalWindVector"), self.NaturalWindSpeed)
      UEMathUtilityMethods.VectorNormalizeMultiple(TempVector2, slua.IndexReference(self, "ResistanceWindVector"), self.ResistanceWindSpeed)
      UEMathUtilityMethods.VectorAdditive(FinalWindVector, TempVector1, TempVector2)
      self.FinalWindSpeed = FinalWindVector:Size()
    end
  elseif 0 < self.NaturalWindSpeed then
    self.FinalWindVector = slua.IndexReference(self, "NaturalWindVector")
    self.FinalWindSpeed = self.NaturalWindSpeed
  else
    self.FinalWindSpeed = 0
  end
end
function ParachuteWindSource:SyncWindSourceRotate()
  local UEMathUtilityMethods = import("UEMathUtilityMethods")
  UEMathUtilityMethods.Conv_VectorToRotator(self.Rotator, slua.IndexReference(self, "FinalWindVector"))
  self.WindDirectionalSource:K2_SetWorldRotation(self.Rotator, false, nil, false)
end
function ParachuteWindSource:SyncWindSourceSpeed()
  if self.WindSourceComponent == nil or not slua.isValid(self.WindSourceComponent) then
    self:TrySetWindSourceComponent()
  end
  if self.WindSourceComponent and slua.isValid(self.WindSourceComponent) then
    self.WindSourceComponent:SetSpeed(self.FinalWindSpeed)
  end
end
local Class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local ParachuteWindSourceClass = Class(CActorBase, nil, ParachuteWindSource)
return ParachuteWindSourceClass