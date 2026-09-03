local EntryIconSetting = {}
function EntryIconSetting:RegistEvents()
  EntryIconSetting.__super.RegistEvents(self)
  local display_setting_redpoint_data = require("client.slua.logic.wardrobe.display_setting_redpoint_data")
  local redPointData = display_setting_redpoint_data.GetData()
  if redPointData then
    self:AddDataListener(redPointData, "checked", function(oldValue, value)
      self:SetWidgetVisible(self.UIRoot.Image_Reddot, not value)
    end)
  end
end
function EntryIconSetting:OnEntryButtonClick()
  UIManager.ShowUI(UIManager.UI_Config.displaysetting)
  self:PlayAudio(sound_config.click_v1)
end
function EntryIconSetting:OnClose()
  UIManager.CloseUI(UIManager.UI_Config.displaysetting)
end
local class = require("class")
local ui_EntryIconBase = require("client.slua.umg.Wardrobe.entry.entry_icon_base")
local CEntryIconCharacter = class(ui_EntryIconBase, nil, EntryIconSetting)
return CEntryIconCharacter