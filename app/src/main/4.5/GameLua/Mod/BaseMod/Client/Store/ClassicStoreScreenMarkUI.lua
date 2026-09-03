local ClassicStoreScreenMarkUI = {}
function ClassicStoreScreenMarkUI:OnDestroy()
  print(bWriteLog and "ClassicStoreScreenMarkUI:OnDestroy")
  self:Dispose()
end
function ClassicStoreScreenMarkUI:OnLocationUnbindUI(Loc)
  print(bWriteLog and "ClassicStoreScreenMarkUI:OnLocationUnbindUI")
  Client.ResetSlateTickEveryFrame(SlateUI_ID.CLASSIC_STORE_SCREEN_MARK)
end
function ClassicStoreScreenMarkUI:OnLocationBindUI(Loc)
  if Loc == nil then
    return
  end
  Client.RequireSlateTickEveryFrame(SlateUI_ID.CLASSIC_STORE_SCREEN_MARK)
  if not self.TextBlock_Distance then
    self.TextBlock_Distance = self.TextBlock_Revive
  end
  print(bWriteLog and "ClassicStoreScreenMarkUI:OnLocationBindUI")
  self.Slot:SetSize(FVector2D(30, 30))
  self.LastShow = nil
  self.BindOutScreen = false
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, ClassicStoreScreenMarkUI)