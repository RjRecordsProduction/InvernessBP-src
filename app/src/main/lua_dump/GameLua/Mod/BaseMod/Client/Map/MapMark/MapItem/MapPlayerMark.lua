local MapPlayerMark = {}
function MapPlayerMark:ctor()
end
function MapPlayerMark:RegistEvents()
end
function MapPlayerMark:OnInitialize()
  if self.UIRoot.SetMarkDist then
    self.UIRoot:SetMarkDist(0, false)
  end
end
function MapPlayerMark:OnPostInitialize()
end
function MapPlayerMark:OnShow()
end
function MapPlayerMark:OnHide()
end
function MapPlayerMark:OnClose()
end
local class = require("class")
local object = require("client.slua_ui_framework.base")
return class(object, nil, MapPlayerMark)