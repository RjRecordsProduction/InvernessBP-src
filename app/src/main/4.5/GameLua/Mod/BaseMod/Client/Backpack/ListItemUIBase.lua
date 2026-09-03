local ListItemUIBase = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function ListItemUIBase:ctor()
  print(bWriteLog and "ListItemUIBase:ctor")
  self.ListItemType = 0
  self.SpecialUIItem = nil
  self.ModWeaponLabel = nil
end
function ListItemUIBase:OnInitialize()
  print(bWriteLog and "ListItemUIBase:OnInitialize")
end
function ListItemUIBase:OnPostInitialize()
  ListItemUIBase.__super.OnPostInitialize(self)
  local ItemUIConfig = GamePlayTools.GetCurrentConfig("ItemUIConfig")
  if not ItemUIConfig or not ItemUIConfig.ModSpecialUI then
    return
  end
  self.ItemSpecialUI = {}
  local ModSpecialUI = ItemUIConfig.ModSpecialUI
  local UIRoot = self.UIRoot
  if ModSpecialUI.EntireSide and UIRoot then
    local Panel = UIRoot.CanvasPanel_EntireSide or UIRoot.CanvasPanel_Special
    for _, UIConfig in ipairs(ModSpecialUI.EntireSide) do
      local UIConfig = UIManager.UI_Config_InGame[UIConfig]
      if UIConfig then
        local ItemUI = self:CreateChildWindow(Panel, UIConfig, self.ListItemType)
        if ItemUI then
          self.ItemSpecialUI[#self.ItemSpecialUI + 1] = ItemUI
        end
      end
    end
  end
  if ModSpecialUI.LeftSide then
    for _, UIConfig in ipairs(ModSpecialUI.LeftSide) do
      local UIConfig = UIManager.UI_Config_InGame[UIConfig]
      if UIConfig then
        local ItemUI = self:CreateChildWindow("CanvasPanel_LeftSide", UIConfig, self.ListItemType)
        if ItemUI then
          self.ItemSpecialUI[#self.ItemSpecialUI + 1] = ItemUI
        end
      end
    end
  end
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
  self.  local SearchItemResult = ItemData.SearchItemResult
  local bHighPriority = ItemData.bHighPriority
  local pickCount = ItemData.pickCount
  local MainItemData = SearchItemResult.MainItemData
  local ItemID = MainItemData.ID.TypeSpecificID
  local itemRecord = CDataTable.GetTableData("Item", ItemID)
  self:UpdateItemDataMod(itemRecord)
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
  self:UpdateItemSpecialUI(ItemID)
end
function ListItemUIBase:UpdateGuideNewIcon(nItemID)
  if not self.UIRoot then
    return
  end
  local Image_New = self.UIRoot.Image_New
  if not Image_New then
    return
  end
  local GameGuideUIConfigSubsystem = SubsystemMgr:Get("GameGuideUIConfigSubsystem")
  local bIsGuideItem = GameGuideUIConfigSubsystem and GameGuideUIConfigSubsystem:CheckShouldShowGuideNew(nItemID, false)
  if bIsGuideItem then
    Image_New:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    Image_New:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ListItemUIBase:UpdateItemSpecialUI(ItemData, bIsItemData)
  if not self.ItemSpecialUI then
    return
  end
  for _, ItemUI in ipairs(self.ItemSpecialUI) do
    if ItemUI then
      if bIsItemData then
        ItemUI:UpdateItemUIByItemData(ItemData)
      else
        ItemUI:UpdateItemUIByItemID(ItemData)
      end
    end
  end
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
function ListItemUIBase:OnClose()
  if not self.ItemSpecialUI then
    return
  end
  for _, ItemUI in ipairs(self.ItemSpecialUI) do
    ItemUI:Close()
  end
  self.ItemSpecialUI = nil
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, ListItemUIBase)