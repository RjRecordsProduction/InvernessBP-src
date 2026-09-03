local EntireMapLeftItemBase = {}
function EntireMapLeftItemBase:ctor()
end
function EntireMapLeftItemBase:SetUIRoot(UIRoot)
  self.end
function EntireMapLeftItemBase:OnRegistEvents()
end
function EntireMapLeftItemBase:OnUnRegistEvents()
  EntireMapLeftItemBase.__super.OnUnRegistEvents(self)
end
function EntireMapLeftItemBase:OnClose()
  self:Dispose()
end
function EntireMapLeftItemBase:CheckComplete()
  return false
end
function EntireMapLeftItemBase:OnInitUI()
end
local class = require("class")
local delegateContainer = require("common.delegate_container")
local CEntireMapLeftItemBase = class(delegateContainer, nil, EntireMapLeftItemBase)
return CEntireMapLeftItemBase