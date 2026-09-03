local DiscountStoreScreenMarkUI = {}
function DiscountStoreScreenMarkUI:OnLocationBindUI(Loc)
  if Loc == nil then
    return
  end
  if not self.TextBlock_Distance then
    self.TextBlock_Distance = self.TextBlock_Revive
  end
  print(bWriteLog and "DiscountStoreScreenMarkUI:OnLocationBindUI")
  self.LastShow = nil
end
function DiscountStoreScreenMarkUI:OnActorBindUI(uActor)
  print(bWriteLog and "DiscountStoreScreenMarkUI:OnActorBindUI")
  if not slua.isValid(uActor) then
    return
  end
  Client.RequireSlateTickEveryFrame(SlateUI_ID.DISCOUNT_STORE_SCREEN_MARK)
  if not self.TextBlock_Distance then
    self.TextBlock_Distance = self.TextBlock_Revive
  end
  self.LastShow = nil
end
function DiscountStoreScreenMarkUI:OnActorUnbindUI(uActor)
  print(bWriteLog and "DiscountStoreScreenMarkUI:OnActorUnbindUI")
  Client.ResetSlateTickEveryFrame(SlateUI_ID.DISCOUNT_STORE_SCREEN_MARK)
end
function DiscountStoreScreenMarkUI:OnDestroy()
  print(bWriteLog and "DiscountStoreScreenMarkUI:OnDestroy")
  self:Dispose()
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, DiscountStoreScreenMarkUI)