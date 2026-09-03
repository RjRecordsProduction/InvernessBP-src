local style_six = {}
function style_six:GetButtonItem(item)
  return item.Button_Item
end
function style_six:ShowItemName(item, name)
  if name then
    item.Text_Name:SetText(name)
  end
end
function style_six:SetQuality(item, quality, itemID)
  self:_SetQuality(item.Image_IconQuality, item.Image_Quality, quality, itemID)
end
function style_six:SetCount(item, number, useNumber, isRolewear)
  self:_SetWidgetCount(item.Text_Count, number, useNumber, isRolewear)
end
function style_six:SetIcon(item, resId)
  self:_SetWidgetIcon(item.Image_Icon, item.SpecialIcon, resId)
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetItemCoBrandedVisibility(resId, item)
end
function style_six:SetHaveLimitTime(item, haveLimitTime)
  if item and item.Image_LimitTime then
    self:_SetWidgetVisible(item.Image_LimitTime, haveLimitTime)
  end
end
function style_six:PlayDecomposeAniUP(item)
  item:PlayUserWidgetAnimation(item.number, 0, 1, 0, 0.7)
end
function style_six:PlayDecomposeAni(item, oldItemID, newItemID, newCnt)
  local UIUtil = require("client.common.ui_util")
  if oldItemID and 0 < oldItemID and newItemID and 0 < newItemID then
    local BusinessHelper = import("BusinessHelper")
    local asset_util = require("common.asset_util")
    local DynamicMaterial = item.Image_Icon:GetDynamicMaterial()
    if not DynamicMaterial then
      local KismetMaterialLibrary = import("KismetMaterialLibrary")
      local Material = asset_util.GetAssetSync("/Game/UMG/UI_Effect/Materials/DX_UITransform03_Inst.DX_UITransform03_Inst")
      if Material then
        DynamicMaterial = KismetMaterialLibrary.CreateDynamicMaterialInstance(UIUtil.GetGameInstance(), Material)
        item.Image_Icon:SetBrushFromMaterial(DynamicMaterial)
      else
        return
      end
    end
    local Texture2D = import("/Script/Engine.Texture2D")
    local tOldItemData = UIUtil.GetItemCfg(oldItemID)
    local oldItemIcon = self:_GetIconPath(tOldItemData)
    local oldItemTexture = asset_util.GetAssetSync(oldItemIcon)
    if oldItemTexture and BusinessHelper.IsClassOf(oldItemTexture, Texture2D) then
      DynamicMaterial:SetTextureParameterValue("Tex_1", oldItemTexture)
    end
    local newItemIcon = UIUtil.GetItemBigIcon(newItemID)
    local newItemTexture = asset_util.GetAssetSync(newItemIcon)
    if newItemTexture and BusinessHelper.IsClassOf(newItemTexture, Texture2D) then
      DynamicMaterial:SetTextureParameterValue("Tex_2", newItemTexture)
    end
    item.Text_Count:SetText(newCnt)
    local itemCfg = CDataTable.GetTableData("Item", newItemID)
    if itemCfg then
      local util = require("client.slua_ui_framework.util")
      util.SetTexture(item.Image_Quality, UIUtil.GetBgQualityPath(itemCfg.ItemQuality), {sync = false})
      if itemCfg.SpecialIcon and itemCfg.SpecialIcon ~= "" then
        util.SetTexture(item.SpecialIcon, itemCfg.SpecialIcon, {sync = false})
      else
        item.SpecialIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    else
      item.SpecialIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    item:PlayUserWidgetAnimation(item.Transform, 0, 1, 0, 0.7)
    UIUtil.SetWidgetVisible(item.Image_LimitTime, false)
  end
end
function style_six:StopDecomposeAni(item)
  if item.Transform then
    item:StopAnimation(item.Transform)
  end
end
function style_six:ShowItemName(item, ItemName)
  if ItemName then
    item.Text_Name:SetText(ItemName)
    item.Text_Name:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    item.Text_Name:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local BaseStyle = require("client.slua.component.item.base_style")
local CStyleExpression = class(BaseStyle, nil, style_six)
return CStyleExpression