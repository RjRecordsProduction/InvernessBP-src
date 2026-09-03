local CommonRotaryTableUITool = {
  _MoveSpeed = 0,
  _TrueRadius = 0,
  _DegreePerPiece = 0,
  _RotateDegree = 0,
  _CanelRadius = 0,
  _CurPos = FVector2D(0),
  LocalPos = FVector2D(0),
  CurIndex = 0,
  PressPos = FVector2D(0)
}
local UKismetMathLibrary = import("KismetMathLibrary")
function CommonRotaryTableUITool:Initialize(MaxRadius, MoveSpeed, DivideNum, CanelRadius)
  self._  self._TrueRadius = MaxRadius / MoveSpeed
  self._  self._DegreePerPiece = 360 / DivideNum
  self._RotateDegree = self._DegreePerPiece * 0.5
  self._CanelRadius = CanelRadius / MoveSpeed
end
function CommonRotaryTableUITool:OnTouchedStart(CurPos)
  self.PressPos = CurPos:clone()
  self._CurPos = CurPos:clone()
end
function CommonRotaryTableUITool:OnTouchedMove(CurPos)
  if CurPos == nil then
    return self.LocalPos
  end
  self._CurPos = CurPos:clone()
  local Direction = CurPos - self.PressPos
  local DirectionSizeSquared = Direction:SizeSquared()
  if DirectionSizeSquared > self._TrueRadius * self._TrueRadius then
    local Pos = Direction:GetSafeNormal(0.001) * self._TrueRadius
    self.PressPos = CurPos - Pos
    self.LocalPos = Pos * self._MoveSpeed
  else
    self.LocalPos = Direction * self._MoveSpeed
  end
  if DirectionSizeSquared > self._CanelRadius * self._CanelRadius then
    local Rad = UKismetMathLibrary.Atan2(self.LocalPos.X, -self.LocalPos.Y)
    local Degree = UKismetMathLibrary.RadiansToDegrees(Rad)
    if Degree < 0 then
      Degree = Degree + 360
    end
    Degree = Degree + self._RotateDegree
    Degree = Degree % 360
    self.CurIndex = math.floor(Degree / self._DegreePerPiece)
  else
    self.CurIndex = -1
  end
  return self.LocalPos
end
function CommonRotaryTableUITool:GetLocalPos(Radius)
  local Direction = self._CurPos - self.PressPos
  if Direction:SizeSquared() > Radius * Radius then
    return Direction:GetSafeNormal(0.001) * Radius
  else
    return Direction
  end
end
function CommonRotaryTableUITool:IsValidedMove(CurPos, DeltaLength)
  local Direction = CurPos - self.PressPos
  return Direction:SizeSquared() >= DeltaLength * DeltaLength
end
local class = require("class")
local object = require("object")
local CCommonRotaryTableUITool = class(object, nil, CommonRotaryTableUITool)
return CCommonRotaryTableUITool