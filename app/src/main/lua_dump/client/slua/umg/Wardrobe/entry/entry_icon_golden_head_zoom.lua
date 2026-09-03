local entry_icon_golden_head_zoom = {}
function entry_icon_golden_head_zoom:ctor()
  self._bZoomIn = false
end
function entry_icon_golden_head_zoom:RegistEvents()
  entry_icon_golden_head_zoom.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ZOOM_BUTTON, self.UpdateZoomState, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ZOOM_VISIBILITY, self.UpdateZoomVisibility, self)
end
function entry_icon_golden_head_zoom:OnShow()
  self:UpdateZoomIcon()
end
function entry_icon_golden_head_zoom:OnEntryButtonClick()
  self:PlayAudio(sound_config.click_v1)
  self._bZoomIn = not self._bZoomIn
  self:UpdateZoomIcon()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SUIT_ZOOM, self._bZoomIn)
end
function entry_icon_golden_head_zoom:UpdateZoomIcon()
  self.UIRoot.WidgetSwitcher_Zoom:SetActiveWidgetIndex(self._bZoomIn and 1 or 0)
end
function entry_icon_golden_head_zoom:UpdateZoomState(_, __, bEnlarged)
  self._bZoomIn = bEnlarged
  self:UpdateZoomIcon()
end
function entry_icon_golden_head_zoom:UpdateZoomVisibility(_, __, bVisible)
  if bVisible then
    self:SelfHitTestInvisible()
  else
    self:Collapsed()
  end
end
local class = require("class")
local ui_EntryIconBase = require("client.slua.umg.Wardrobe.entry.entry_icon_base")
local Centry_icon_golden_head_zoom = class(ui_EntryIconBase, nil, entry_icon_golden_head_zoom)
return Centry_icon_golden_head_zoom