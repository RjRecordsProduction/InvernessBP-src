local MapWidgetBase = {}
function MapWidgetBase:BindMapUIBase(MapUI, bIsMiniMap)
  if not MapUI then
    print(bWriteLog and "MapWidgetBase:BindMapUIBase - MapUI is nil")
    return
  end
  self.MapUIBase = MapUI.CurrentMapUI
  self.  self.end
function MapWidgetBase:InitUI(ParentUI)
  if not ParentUI then
    print(bWriteLog and "MapWidgetBase:InitUI - ParentUI is nil")
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CMapWidgetBase = class(UIBase, nil, MapWidgetBase)
return CMapWidgetBase