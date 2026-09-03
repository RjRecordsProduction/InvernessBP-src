local CommonScreenMarkUI = {}
function CommonScreenMarkUI:ctor()
  print(bWriteLog and string.format("CommonScreenMarkUI:ctor"))
end
function CommonScreenMarkUI:OnDestroy()
  self:Dispose()
end
function CommonScreenMarkUI:OnActorBindUI(BindActor)
  print(bWriteLog and string.format("CommonScreenMarkUI:OnLocationBindUI %s", BindActor))
  self:ResetUI()
end
function CommonScreenMarkUI:OnActorUnbindUI(Loc)
  self.bIsUpdateDistanceToLua = false
end
function CommonScreenMarkUI:OnLocationBindUI(Loc)
  print(bWriteLog and string.format("CommonScreenMarkUI:OnLocationBindUI %s", Loc:ToString()))
  self:ResetUI()
end
function CommonScreenMarkUI:OnLocationUnbindUI(Loc)
  self.bIsUpdateDistanceToLua = false
end
function CommonScreenMarkUI:ResetUI()
  if not self.TextBlock_Distance then
    self.TextBlock_Distance = self.DistanceText
  end
  self.bIsUpdateDistanceToLua = true
  self:ResetSlot()
end
function CommonScreenMarkUI:ResetSlot()
  self.Slot:SetAutoSize(true)
  self.Slot:SetAlignment(FVector2D(0.5, 0.5))
end
function CommonScreenMarkUI:ResetLocalOffset(BindActor)
  if not slua.isValid(BindActor) then
    return
  end
  if not self.OriginLocOffset then
    print(bWriteLog and string.format("CommonScreenMarkUI:OnActorBindUI Cache LocOffset %s", self.LocOffset:ToString()))
    self.OriginLocOffset = self.LocOffset:clone()
  end
  local Transform = BindActor:GetTransform()
  local NewLocOffset = Transform:TransformPosition(self.OriginLocOffset) - BindActor:K2_GetActorLocation()
  self.LocOffset = NewLocOffset
  print(bWriteLog and string.format("CommonScreenMarkUI:OnActorBindUI Convert LocOffset %s -> %s", self.OriginLocOffset:ToString(), NewLocOffset:ToString()))
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, CommonScreenMarkUI)