local ListItemUIBase = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function ListItemUIBase:ctor()
  print(bWriteLog and "ListItemUIBase:ctor")
  self.SpecialUIItem = nil
  self.ModWeaponLabel = nil
end
function ListItemUIBase:OnInitialize()
  print(bWriteLog and "ListItemUIBase:OnInitialize")
end
function ListItemUIBase:GetSpecialItemUIConfig()
  return "ModWeaponLabelUI"
end
function ListItemUIBase:GetAllSpecialItemIds()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  return BackpackConfig.AllSpecialItemID
end
function ListItemUIBase:CheckIsSpeicalItem(nItemID)
  return self:GetAllSpecialItemIds()[nItemID]
end
function ListItemUIBase:UpdateItemDataNew(ItemData, ParentUserWidget)
  if self.UIRoot and self.UIRoot.UpdateItemData then
    self.UIRoot.    self.UIRoot:UpdateItemData(ItemData)
  end
  local SearchItemResult = ItemData.SearchItemResult
  local bHighPriority = ItemData.bHighPriority
  local pickCount = ItemData.pickCount
  local MainItemData = SearchItemResult.MainItemData
  local ItemID = MainItemData.ID.TypeSpecificID
  local itemRecord = CDataTable.GetTableData("Item", ItemID)
  self:UpdateItemDataMod(itemRecord)
  self:UpdateModWeaponUI(ItemID)
end
function ListItemUIBase:UpdateItemDataMod(itemRecord)
  if not itemRecord then
    print(bWriteLog and "ListItemUIBase:UpdateItemDataMod itemRecord is nil")
    return
  end
  local ItemID = itemRecord.ItemID
  local bSpecial = self:CheckIsSpeicalItem(ItemID)
  if bSpecial then
    local SpecialUIItem = self:GetCurSpecialItemUI()
    if SpecialUIItem then
      SpecialUIItem:SelfHitTestInvisible()
    end
  else
    local SpecialUIItem = self.SpecialUIItem
    if SpecialUIItem then
      SpecialUIItem:Collapsed()
    end
  end
  self:UpdateModWeaponUI(ItemID)
end
function ListItemUIBase:GetCurSpecialItemUI()
  local endCanvas = self.UIRoot.CanvasPanel_Special
  if endCanvas == nil then
    return nil
  end
  if self.SpecialUIItem == nil then
    local UIConfig = UIManager.UI_Config_InGame[self:GetSpecialItemUIConfig()]
    if UIConfig then
      self.SpecialUIItem = self:CreateChildWindow(endCanvas, UIConfig)
    end
  end
  return self.SpecialUIItem
end
function ListItemUIBase:UpdateModWeaponUI(ItemID)
  if not self.UIRoot.CanvasPanel_ModTitleRoot then
    return
  end
  local ModWeaponConfig = GamePlayTools.GetCurrentConfig("ModWeaponConfig")
  if ModWeaponConfig and ModWeaponConfig[ItemID] and ModWeaponConfig[ItemID].LabelUIConfig then
    if self.ModWeaponLabel then
      self.ModWeaponLabel:HitTestInvisible()
    else
      local WeaponConfig = ModWeaponConfig[ItemID]
      local LabelUIConfig = WeaponConfig.LabelUIConfig
      local ModLabelCanvas = self.UIRoot.CanvasPanel_ModTitleRoot
      if LabelUIConfig and ModLabelCanvas then
        local LabelConfig = UIManager.UI_Config_InGame[LabelUIConfig]
        if LabelConfig then
          self.ModWeaponLabel = self:CreateChildWindow(ModLabelCanvas, LabelConfig, 2)
          self.ModWeaponLabel:AttachParent(ModLabelCanvas)
        end
      end
    end
  elseif self.ModWeaponLabel then
    self.ModWeaponLabel:Collapsed()
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, ListItemUIBase)