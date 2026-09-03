local Wardrobe_Tag_NewGuide_Tips_UIBP = {}
function Wardrobe_Tag_NewGuide_Tips_UIBP:ctor()
end
function Wardrobe_Tag_NewGuide_Tips_UIBP:OnPostInitialize()
  Wardrobe_Tag_NewGuide_Tips_UIBP.__super.OnPostInitialize(self)
  self:SetAnchors(0.5, 0.5, 0.5, 0.5)
  self:SetOffsets(0, 0, 0, 0)
  self:SetAlignment(1, 1)
  self:SetAutoSize(true)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CWardrobe_Tag_NewGuide_Tips_UIBP = class(ui_base, nil, Wardrobe_Tag_NewGuide_Tips_UIBP)
return CWardrobe_Tag_NewGuide_Tips_UIBP