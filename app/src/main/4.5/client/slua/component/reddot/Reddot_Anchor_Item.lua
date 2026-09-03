local Reddot_Anchor_Item = {}
function Reddot_Anchor_Item:SetTextNum(num)
  if self.UIRoot.TextBlock_Num then
    if num <= 99 then
      self.UIRoot.TextBlock_Num:SetText(tostring(num))
    else
      self.UIRoot.TextBlock_Num:SetText("...")
    end
  end
end
function Reddot_Anchor_Item:SetTextTips(text)
  if self.UIRoot.TextBlock_Tips then
    self.UIRoot.TextBlock_Tips:SetText(text)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CReddot_Anchor_Item = class(ui_base, nil, Reddot_Anchor_Item)
return CReddot_Anchor_Item