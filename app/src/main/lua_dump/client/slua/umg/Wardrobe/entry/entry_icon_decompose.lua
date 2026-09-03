local EntryIconDecompose = {}
function EntryIconDecompose:RegistEvents()
  EntryIconDecompose.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnRestrictButtonClick, self)
end
function EntryIconDecompose:OnEntryButtonClick()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.Show(WardrobeLogicManager.GetCurrentPageId())
  self:PlayAudio(sound_config.click_v1)
end
function EntryIconDecompose:OnRestrictButtonClick()
  self:PlayAudio(sound_config.click_v1)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictDepotDecompose() then
    QRcodeRestrictManager:ShowRestrictTips()
  end
end
local class = require("class")
local ui_EntryIconBase = require("client.slua.umg.Wardrobe.entry.entry_icon_base")
local CEntryIconCharacter = class(ui_EntryIconBase, nil, EntryIconDecompose)
return CEntryIconCharacter