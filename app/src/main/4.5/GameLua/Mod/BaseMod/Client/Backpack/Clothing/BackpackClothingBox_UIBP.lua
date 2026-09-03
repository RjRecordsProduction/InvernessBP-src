local ITEM_COUNT_PER_LINE = 2
local BackpackClothingBox_UIBP = {}
function BackpackClothingBox_UIBP:ctor()
  self.bExpanded = false
  self.ClothingEntryWidgets = {}
end
function BackpackClothingBox_UIBP:OnInitialize()
end
function BackpackClothingBox_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.NewButton_Arrow, self.OnArrowClicked, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_AVATAR_ON_CHANGE_WEARING_DONE, self.UpdateUI, self)
end
function BackpackClothingBox_UIBP:OnPostInitialize()
  self:InitChildEntryList()
  self:UpdateUI()
end
function BackpackClothingBox_UIBP:OnClose()
  self:CloseChildEntryItems()
end
function BackpackClothingBox_UIBP:OnArrowClicked()
  print(bWriteLog and "BackpackClothingBox_UIBP:OnArrowClicked")
  self.bExpanded = not self.bExpanded
  self:UpdateClothingEntryListVisibility()
end
function BackpackClothingBox_UIBP:UpdateUI()
  log(bWriteLog and "BackpackClothingBox_UIBP:UpdateUI")
  self.bExpanded = false
  self:UpdateClothingEntryListVisibility()
end
function BackpackClothingBox_UIBP:UpdateClothingEntryListVisibility()
  if self.bExpanded then
    self:SetWidgetVisible(self.UIRoot.ItemsBoxPanel, true, false)
    self.UIRoot.WidgetSwitcher_Arrow:SetActiveWidgetIndex(1)
  else
    self:SetWidgetVisible(self.UIRoot.ItemsBoxPanel, false, false)
    self.UIRoot.WidgetSwitcher_Arrow:SetActiveWidgetIndex(0)
  end
end
function BackpackClothingBox_UIBP:InitChildEntryList()
  local LogicBackpackClothUIUtil = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicBackpackClothUIUtil)
  local ChildEntryItemData = LogicBackpackClothUIUtil:GetClothEntryItemData()
  if not ChildEntryItemData then
    return
  end
  local bShowRPPlusBag = UnknowPassSystem and UnknowPassSystem.Season >= 59
  for i, v in ipairs(ChildEntryItemData) do
    if not bShowRPPlusBag and i == #ChildEntryItemData then
      break
    end
    if v then
      self:CreateChildEntryItem(i, v, math.floor((i - 1) / ITEM_COUNT_PER_LINE), (i - 1) % ITEM_COUNT_PER_LINE)
    end
  end
end
function BackpackClothingBox_UIBP:CreateChildEntryItem(RolewearIndex, EntryItemData, Row, Column)
  print(bWriteLog and "BackpackClothingBox_UIBP:CreateChildEntryItem", RolewearIndex, Row, Column)
  local ClothingItem = self:CreateChildWindow("ItemsBoxPanel", UIManager.UI_Config_InGame.MainBackPackRolewearTab, EntryItemData)
  if not self.ClothingEntryWidgets then
    self.ClothingEntryWidgets = {}
  end
  table.insert(self.ClothingEntryWidgets, ClothingItem)
  ClothingItem.UIRoot.Slot:SetRow(Row)
  ClothingItem.UIRoot.Slot:SetColumn(Column)
end
function BackpackClothingBox_UIBP:CloseChildEntryItems()
  for _, Widget in pairs(self.ClothingEntryWidgets) do
    if Widget then
      Widget:Close()
    end
  end
  self.ClothingEntryWidgets = nil
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, BackpackClothingBox_UIBP)