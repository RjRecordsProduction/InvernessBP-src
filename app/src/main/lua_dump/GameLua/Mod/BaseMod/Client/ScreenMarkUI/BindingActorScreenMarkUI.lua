local BindingActorScreenMarkUI = {}
function BindingActorScreenMarkUI:ctor()
  print(bWriteLog and string.format("BindingActorScreenMarkUI:ctor"))
end
function BindingActorScreenMarkUI:OnDestroy()
  self:Dispose()
end
function BindingActorScreenMarkUI:OnActorBindUI(BindActor)
  if not self.TextBlock_Distance then
    self.TextBlock_Distance = self.DistanceText
  end
  self.bIsUpdateDistanceToLua = true
  self:ResetSlot()
  self:ResetLocalOffset(BindActor)
end
function BindingActorScreenMarkUI:OnActorUnbindUI(Loc)
  self.bIsUpdateDistanceToLua = false
end
function BindingActorScreenMarkUI:ResetSlot()
  self.Slot:SetAutoSize(true)
  self.Slot:SetAlignment(FVector2D(0.5, 0.5))
end
function BindingActorScreenMarkUI:ResetLocalOffset(BindActor)
  if not self.OriginLocOffset then
    print(bWriteLog and string.format("BindingActorScreenMarkUI:OnActorBindUI Cache LocOffset %s", self.LocOffset:ToString()))
    self.OriginLocOffset = self.LocOffset:clone()
  end
  local Transform = BindActor:GetTransform()
  local NewLocOffset = Transform:TransformPosition(self.OriginLocOffset) - BindActor:K2_GetActorLocation()
  self.LocOffset = NewLocOffset
  print(bWriteLog and string.format("BindingActorScreenMarkUI:OnActorBindUI Convert LocOffset %s -> %s", self.OriginLocOffset:ToString(), NewLocOffset:ToString()))
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, BindingActorScreenMarkUI)