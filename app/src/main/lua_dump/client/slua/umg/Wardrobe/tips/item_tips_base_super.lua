local ItemTipsBaseSuper = {}
function ItemTipsBaseSuper:InitTipData(...)
end
function ItemTipsBaseSuper:Refresh()
end
function ItemTipsBaseSuper:OnCloseBtnClicked()
  self:PlayAudio(sound_config.click_v1)
  self:Hide()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CItemTipsBaseSuper = class(ui_base, nil, ItemTipsBaseSuper)
return CItemTipsBaseSuper