local EntryIconBase = {}
function EntryIconBase:ctor(selfType, IconConfig)
  self.end
function EntryIconBase:OnInitialize()
  log(bWriteLog and "EntryIconBase:OnInitialize")
  self:AddOnClickedEventByControl(self.UIRoot.Button, self.OnEntryButtonClick, self)
  if self.IconConfig then
    if self.IconConfig.iconPath ~= nil then
      self:SetTexture(self.UIRoot.IconImage, self.IconConfig.iconPath)
    end
    if self.UIRoot.NameText then
      self.UIRoot.NameText:SetText(LocUtil.LocalizeResFormat(self.IconConfig.nameStrId))
    end
  end
end
function EntryIconBase:RegistEvents()
  EntryIconBase.__super.RegistEvents(self)
end
function EntryIconBase:OnEntryButtonClick()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CEntryIconBase = class(ui_base, nil, EntryIconBase)
return CEntryIconBase