local MeleeInfoItemUI = {}
local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
local ESlateVisibility = import("ESlateVisibility")
function MeleeInfoItemUI:OnInitialize()
  MeleeInfoItemUI.__super.OnInitialize(self)
  self:SetAutoSize(true)
end
function MeleeInfoItemUI:OnMouseLeave(MouseEvent)
  self:HighLightBG(false)
  self.bHasStartedTouchIn = false
end
function MeleeInfoItemUI:OnDragCancelled(PointerEvent, Operation)
  self.ItemBeDragCancelled:BroadCast()
end
function MeleeInfoItemUI:OnTouchStarted(MyGeometry, InTouchEvent)
  self.bHasStartedTouchIn = true
  self:HighLightBG(true)
  local DragHandle = WidgetBlueprintLibrary.DetectDragIfPressed(InTouchEvent, nil, nil)
  return WidgetBlueprintLibrary.CaptureMouse(DragHandle, nil)
end
function MeleeInfoItemUI:OnTouchEnded(MyGeometry, InTouchEvent)
  if self.bHasStartedTouchIn then
    self.bHasStartedTouchIn = false
    return WidgetBlueprintLibrary.ReleaseMouseCapture(WidgetBlueprintLibrary.Handled())
  end
end
function MeleeInfoItemUI:UpdateWeaponAppearanceInfo(TypeSpecificID, ItemData)
  print(bWriteLog and "MeleeInfoItemUI:UpdateWeaponAppearanceInfo TypeSpecificID:" .. TypeSpecificID)
  local ItemDataTemp = ItemData:clone()
  local UIRoot = self.UIRoot
  self.BattleData = ItemDataTemp
  UIRoot.BattleData = ItemDataTemp
  UIRoot.Image_MeleeIcon:SetWidgetVisibility(ESlateVisibility.Collapsed)
  UIRoot.Image_Quality:SetWidgetVisibility(ESlateVisibility.Collapsed)
  UIRoot.default_Image_icon:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  if TypeSpecificID ~= 0 then
    local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
    local WeaponIDOrAvatarID, DIYPlanID = BackPackFunctionLibrary.GetWeaponAvatarRes(TypeSpecificID, ItemDataTemp.AdditionalData)
    local itemCfg1 = CDataTable.GetTableData("Item", TypeSpecificID)
    if itemCfg1 then
      UIRoot.TextBlock_MeleeName:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
      UIRoot.TextBlock_MeleeName:SetText(itemCfg1.ItemName)
    end
    local IconPath = ""
    if WeaponIDOrAvatarID then
      local itemCfg2 = CDataTable.GetTableData("Item", WeaponIDOrAvatarID)
      if itemCfg2 then
        IconPath = itemCfg2.ItemBigIcon
        local LogicUserBattleDataManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicUserBattleDataManager)
        if not LogicUserBattleDataManager:HasBigIconDownloaded(WeaponIDOrAvatarID) then
          IconPath = itemCfg1.ItemBigIcon
        end
        UIRoot.Image_MeleeIcon:SetBrushFromPathAsync(IconPath, true)
        self:UpdateQuality(itemCfg2.ItemQuality)
      end
    end
    UIRoot.Image_MeleeIcon:SetWidgetVisibility(ESlateVisibility.Visible)
    UIRoot.default_Image_icon:SetWidgetVisibility(ESlateVisibility.Collapsed)
    print(bWriteLog and "MeleeInfoItemUI:UpdateWeaponAppearanceInfo WeaponIDOrAvatarID:" .. WeaponIDOrAvatarID .. " IconPath:" .. IconPath)
  else
    UIRoot.TextBlock_MeleeName:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function MeleeInfoItemUI:UpdateQuality(Quality)
  print(bWriteLog and "MeleeInfoItemUI:UpdateQuality Quality:" .. Quality)
  local UIRoot = self.UIRoot
  local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
  BackPackFunctionLibrary.UpdataQualityColorAndBG(Quality, UIRoot.Image_Quality, UIRoot.Image_QualityBG)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, MeleeInfoItemUI)