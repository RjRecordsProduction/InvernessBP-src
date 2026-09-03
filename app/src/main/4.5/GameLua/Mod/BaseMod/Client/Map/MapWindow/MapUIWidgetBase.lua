local MapUIWidgetBase = {}
local STExtraMapFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraMapFunctionLibrary")
function MapUIWidgetBase:ctor()
  printf("MapUIWidgetBase:ctor")
end
function MapUIWidgetBase:OnInitialize()
  printf("MapUIWidgetBase:OnInitialize")
end
function MapUIWidgetBase:OnPostInitialize()
  printf("MapUIWidgetBase:OnPostInitialize")
  MapUIWidgetBase.__super.OnPostInitialize(self)
end
function MapUIWidgetBase:BindUIBase()
  if self.UIRoot and self.UIRoot.CurrentMapUIBP then
    print(bWriteLog and "MapUIWidgetBase MapUIBase")
    self.UIRoot.CurrentMapUIBP:BindMapWidget(self)
  end
end
function MapUIWidgetBase:OnDestroy()
end
function MapUIWidgetBase:OnClose()
  print(bWriteLog and "MapUIWidgetBase:OnClose")
  local UIRoot = self.UIRoot
  if UIRoot then
    UIRoot.MapUIBase = nil
    if UIRoot.CurrentMapUIBP then
      UIRoot.CurrentMapUIBP:OnDestroy()
      UIRoot.CurrentMapUIBP = nil
    end
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CMapUIWidgetBase = class(UIBase, nil, MapUIWidgetBase)
return CMapUIWidgetBase