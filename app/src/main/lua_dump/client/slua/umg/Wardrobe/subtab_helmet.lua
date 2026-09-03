local WardrobeHelmet = {}
function WardrobeHelmet:RegistEvents()
  WardrobeHelmet.__super.RegistEvents(self)
  for index = 1, 3 do
    self:AddOnClickedEventByControl(self.UIRoot["HelmetLevelButton_" .. tostring(index)], self.OnHelmetLevelButtonClicked, self, index)
  end
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_EDIT_HELMET_LEVEL_CHANGE, self.OnFashionBagEditHelmetLevelChange, self)
end
function WardrobeHelmet:OnHelmetLevelChange()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  self:EnableAllHelmetLevelButton()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInFashionBagEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if not bInFashionBagEditMode then
    self:EnableHelmetLevelButton(fashionbag_data:GetHelmetLevel(), false)
  else
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    local CurrentHelmetLevel = FashionBagEditUtils:GetCurrentHelmetLevel()
    log(bWriteLog and string.format("WardrobeHelmet:OnHelmetLevelChange. CurrentHelmetLevel=%s", tostring(CurrentHelmetLevel)))
    self:EnableHelmetLevelButton(CurrentHelmetLevel, false)
  end
end
function WardrobeHelmet:OnHelmetLevelButtonClicked(index)
  self:PlayAudio(sound_config.click_v1)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInFashionBagEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if not bInFashionBagEditMode then
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_depot_set_skin_info_req(fashionbag_data:GetBagLevel(), index)
  else
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    FashionBagEditUtils:SetHelmetLevel(index, false, true)
  end
end
function WardrobeHelmet:EnableAllHelmetLevelButton()
  for index = 1, 3 do
    self:EnableHelmetLevelButton(index, true)
  end
end
function WardrobeHelmet:EnableHelmetLevelButton(index, enable)
  local btnName = "HelmetLevelButton_" .. tostring(index)
  if self.UIRoot[btnName] == nil then
    return
  end
  self.UIRoot[btnName]:SetIsEnabled(enable)
  local widgetSwitcher_Bag = "WidgetSwitcher_Helmet_" .. tostring(index)
  if self.UIRoot[widgetSwitcher_Bag] == nil then
    return
  end
  if enable then
    self.UIRoot[widgetSwitcher_Bag]:SetActiveWidgetIndex(0)
  else
    self.UIRoot[widgetSwitcher_Bag]:SetActiveWidgetIndex(1)
  end
  local WidgetSwitcher_Selected = "WidgetSwitcher_Selected0" .. tostring(index)
  if self.UIRoot[WidgetSwitcher_Selected] == nil then
    return
  end
  if enable then
    self.UIRoot[WidgetSwitcher_Selected]:SetActiveWidgetIndex(0)
  else
    self.UIRoot[WidgetSwitcher_Selected]:SetActiveWidgetIndex(1)
  end
end
function WardrobeHelmet:WatchBag(bagIndex)
  log(bWriteLog and string.format("WardrobeHelmet:WatchBag. bagIndex=%s", tostring(bagIndex)))
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local fashionBag = fashionbag_data:GetFashionBag(bagIndex)
  self:AddDataListener(fashionBag, "helmet_level", function(oldValue, value)
    log(bWriteLog and string.format("WardrobeHelmet:WatchBag. oldValue=%s, value=%s", tostring(oldValue), tostring(value)))
    self:OnHelmetLevelChange()
  end)
end
function WardrobeHelmet:UpdateLevelPanelShow()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local simpleUI_Clothes = UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP)
  if WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag or simpleUI_Clothes then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_HelmetLevelPanel, false, false)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_HelmetLevelPanel, true, false)
  end
end
function WardrobeHelmet:OnFashionBagEditHelmetLevelChange()
  self:OnHelmetLevelChange()
  self:RefreshEquipmentLevel()
end
function WardrobeHelmet:OnFashionBagEditUpdate(_, __)
  WardrobeHelmet.__super.OnFashionBagEditUpdate(self, _, __)
  self:OnHelmetLevelChange()
end
function WardrobeHelmet:OnFashionBagEditExit(_, __)
  WardrobeHelmet.__super.OnFashionBagEditExit(self, _, __)
  self:OnHelmetLevelChange()
end
local class = require("class")
local ui_subtab_bag_base = require("client.slua.umg.Wardrobe.subtab_bag_base")
local CWardrobeHelmet = class(ui_subtab_bag_base, nil, WardrobeHelmet)
return CWardrobeHelmet