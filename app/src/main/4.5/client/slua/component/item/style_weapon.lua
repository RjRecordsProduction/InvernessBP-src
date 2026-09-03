local style_weapon = {}
function style_weapon:SetQuality(item, quality, itemID)
  local imageIconQuality = item.Image_IconQuality
  local imageQuality = item.Image_Quality
  self:_SetQuality(imageIconQuality, imageQuality, quality, itemID)
end
function style_weapon:SetIsNew(item, isNew)
  self:_SetWidgetVisible(item.Text_New, isNew)
end
function style_weapon:_GetBgQualityPath(quality)
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetBgQualityPath(quality)
end
function style_weapon:GetButtonItem(item)
  return item.Button_Item
end
function style_weapon:SetIsUsing(item, isUsing)
  self:_SetWidgetVisible(item.Image_Using, isUsing)
end
function style_weapon:SetIsFreeze(item, isFreeze)
  self:_SetWidgetVisible(item.CanvasPanel_Freeze, isFreeze)
end
function style_weapon:SetIsIsolated(item, isIsolated)
  local textBlock = item.TextBlock_Isolated
  self:_SetWidgetVisible(textBlock, isIsolated)
  if isIsolated then
    textBlock:SetText(LocUtil.GetLocalizeResStr(7474))
  end
end
function style_weapon:SetIsSelected(item, isSelected)
  self:_SetWidgetVisible(item.Image_Select, isSelected)
end
function style_weapon:SetCount(item, number, useNumber, isRolewear, isShowZero)
  self:_SetWidgetCount(item.TextBlock_Wardrobe_GunNumber, number, useNumber, isRolewear, isShowZero)
end
function style_weapon:_GetIconPath(itemData, widget)
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetItemBigIcon(itemData.ItemID, widget)
end
function style_weapon:SetIcon(item, resId)
  log(bWriteLog and string.format("style_weapon:SetIcon, resId:%s", resId))
  self:_SetWidgetVisible(item.Image_Wardrobe_CarLogo, false)
  local UIUtil = require("client.common.ui_util")
  local itemData = UIUtil.GetItemCfg(resId)
  if not itemData then
    log(bWriteLog and "WARNING: style_weapon:SetIcon, not itemData. ")
    return
  end
  if not item.Image_Wardrobe_GunLogo then
    return
  end
  self:_SetWidgetVisible(item.Image_Wardrobe_GunLogo, true)
  self:_SetWidgetVisible(item.Logo, itemData.SpecialIcon ~= "")
  local util = require("client.slua_ui_framework.util")
  local SpecialIcon, bHasAddKnownMissingSp = UIUtil.GetItemSpecialIcon(resId, item.Logo)
  if SpecialIcon and SpecialIcon ~= "" then
    local params = {
      sync = false,
      bMatchSize = true,
      bHasAddKnownMissing = bHasAddKnownMissingSp
    }
    util.SetTexture(item.Logo, SpecialIcon, params)
  end
  local weapon_diy_utils = require("client.slua.umg.WeaponDIY.weapon_diy_utils")
  local bDIYColor, colorId = weapon_diy_utils:IsDiyColor(resId)
  if bDIYColor then
    weapon_diy_utils:SetDiyColorImage(item.Image_Wardrobe_GunLogo, colorId)
  else
    item.Image_Wardrobe_GunLogo:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    local iconPath, bHasAddKnownMissing = self:_GetIconPath(itemData, item.Image_Wardrobe_GunLogo)
    local params = {
      sync = false,
      bMatchSize = true,
          }
    util.SetTexture(item.Image_Wardrobe_GunLogo, iconPath, params)
    UIUtil.CheckAndUpdateIconScale(resId, iconPath, item.Image_Wardrobe_GunLogo, 1)
  end
  UIUtil.SetItemCoBrandedVisibility(resId, item)
end
function style_weapon:SetIconAlpha(item, alpha)
  self:_SetIconAlpha(item.Image_Wardrobe_GunLogo, item.Image_Quality, alpha)
end
function style_weapon:SetHaveLimitTime(item, haveLimitTime)
  if item and item.Image_LimitTime then
    self:_SetWidgetVisible(item.Image_LimitTime, haveLimitTime)
  end
end
function style_weapon:SetSpecialIcon(item, path)
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(item.Logo, path, {sync = false})
end
function style_weapon:ResetIcon(item)
  self:SetCombatReadinessIcon(item, false)
end
function style_weapon:SetCombatReadinessIcon(item, visibility)
  if item and item.box then
    self:_SetWidgetVisible(item.box, visibility)
  end
end
local class = require("class")
local BaseStyle = require("client.slua.component.item.base_style")
local CStyleWeapon = class(BaseStyle, nil, style_weapon)
return CStyleWeapon