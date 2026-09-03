local style_four = {}
function style_four:SetAwardState(item, state)
  if state == 0 then
    self:_SetWidgetVisible(item.CanvasPanel_2, false)
    self:SetIsLock(item, true)
  elseif state == 1 then
    self:_SetWidgetVisible(item.CanvasPanel_2, false)
    self:SetIsLock(item, false)
  elseif state == 2 then
    self:_SetWidgetVisible(item.CanvasPanel_2, true)
    self:SetIsLock(item, false)
  end
end
local class = require("class")
local BaseStyle = require("client.slua.component.item.base_style")
local CStyleFour = class(BaseStyle, nil, style_four)
return CStyleFour