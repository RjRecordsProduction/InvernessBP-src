local ModeSelection_Main_Map_Item = {}
function ModeSelection_Main_Map_Item:ctor(selfType, itemData1, itemData2, filterInfo, showDelay)
  self.  if itemData2 then
    self.  end
  self.  self.end
function ModeSelection_Main_Map_Item:OnPostInitialize()
  ModeSelection_Main_Map_Item.__super.OnPostInitialize(self)
  self.item1 = self:NewItem(self.itemData1)
  self.item2 = self:NewItem(self.itemData2)
end
function ModeSelection_Main_Map_Item:NewItem(itemData)
  if not itemData then
    return
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  local item
  if itemData then
    if itemData.group_type == mode_selection_macro.Enum_Group_Type.Multi then
      item = self:CreateChildWindow(self.UIRoot.VerticalBox_0, UIManager.UI_Config.item_multi_small_mode_selection_main, itemData, self.filterInfo, self.showDelay)
    elseif logic_newbie_mode_selection:IsNewbieView(itemData.id) and logic_newbie_mode_selection:CheckOpen() then
      item = self:CreateChildWindow(self.UIRoot.VerticalBox_0, UIManager.UI_Config.item_newbie_small_mode_selection_main, itemData, self.filterInfo, self.showDelay)
    else
      item = self:CreateChildWindow(self.UIRoot.VerticalBox_0, UIManager.UI_Config.item_small_mode_selection_main, itemData, self.filterInfo, self.showDelay)
    end
  end
  return item
end
function ModeSelection_Main_Map_Item:IsDoubleItem()
  return true
end
function ModeSelection_Main_Map_Item:GetMapItem(in_index)
  if 0 < in_index and in_index < 3 then
    return self["item" .. tostring(in_index)]
  end
  return nil
end
function ModeSelection_Main_Map_Item:OnClose()
  ModeSelection_Main_Map_Item.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua.umg.ModeSelection.ModeSelection_Main_Item_Base")
local CModeSelection_Main_Map_Item = class(ui_base, nil, ModeSelection_Main_Map_Item)
return CModeSelection_Main_Map_Item