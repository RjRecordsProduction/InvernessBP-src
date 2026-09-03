local base_style = {}
function base_style:_SetWidgetVisible(widget, visible)
  if slua.isValid(widget) then
    local UIUtil = require("client.common.ui_util")
    widget:SetWidgetVisibility(UIUtil.BoolToVisible(visible))
  end
end
function base_style:_SetQuality(imageIconQuality, imageQuality, quality, itemID)
  self:_SetWidgetVisible(imageQuality, 0 < quality)
  self:_SetWidgetVisible(imageIconQuality, false)
  if quality < 0 then
    return
  end
  local UIUtil = require("client.common.ui_util")
  local path, bHasAddKnownMissing = UIUtil.GetSpecialQualityBg(itemID, imageQuality)
  local util = require("client.slua_ui_framework.util")
  if path == nil or path == "" then
    if imageQuality then
      util.SetTexture(imageQuality, self:_GetBgQualityPath(quality), {sync = false, bHasAddKnownMissing = bHasAddKnownMissing})
    end
  else
    util.SetTexture(imageQuality, path, {sync = false, bHasAddKnownMissing = bHasAddKnownMissing})
  end
end
function base_style:_GetBgQualityPath(quality)
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetBgQualityPath(quality)
end
function base_style:GetButtonItem(item)
  item = item.Common_Item_All_UIBP
  if item then
    return item.Button_item
  end
end
function base_style:SetLight(item, bShow)
  item = item and item.Common_Item_All_UIBP
  if not item or not item.Panel_Light then
    return
  end
  if bShow then
    item.Panel_Light:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    item.Panel_Light:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function base_style:SetCollectNum(item, num)
  item = item and item.Common_Item_All_UIBP
  if item then
    local show = num ~= 0
    self:_SetWidgetVisible(item.CanvasPanel_Collect, show)
    if show then
      item.TextBlock_Collect:SetText(tostring(num))
    end
  end
end
function base_style:SetBgVisible(item, isShow)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Bg, isShow)
  end
end
function base_style:SetQuality(item, quality, itemID)
  item = item and item.Common_Item_All_UIBP
  if not item then
    return
  end
  local imageIconQuality = item.Image_IconQuality
  local imageQuality = item.Image_Quality
  quality = quality or 1
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  self:_SetWidgetVisible(item.Quality8Item_UIBP, quality == ItemMacros.QUALITY_GOLDEN)
  self:_SetQuality(imageIconQuality, imageQuality, quality, itemID)
end
function base_style:SetIsNew(item, isNew)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Text_New, isNew)
  end
end
function base_style:SetIsIncreaseProbability(item, IsIncreaseProbability)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_Up_Probability, IsIncreaseProbability)
  end
end
function base_style:SetSpecialNew(item, isNew, resID)
end
function base_style:SetIsLock(item, isLock)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_Lock, isLock)
  end
end
function base_style:SetIsUsing(item, isUsing)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_Using, isUsing)
  end
end
function base_style:SetIsWear(item, isWear)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_SourceBook_Using, isWear)
  end
end
function base_style:SetIsFreeze(item, isFreeze)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.CanvasPanel_Freeze, isFreeze)
  end
end
function base_style:SetIsTryOn(item, isTryOn)
end
function base_style:SetIsIsolated(item, isIsolated)
  item = item and item.Common_Item_All_UIBP
  if item then
    local textBlock = item.TextBlock_Isolated
    self:_SetWidgetVisible(textBlock, isIsolated)
    if isIsolated then
      textBlock:SetText(LocUtil.GetLocalizeResStr(7474))
    end
  end
end
function base_style:SetIsSelected(item, isSelected)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_Select, isSelected)
  end
end
function base_style:_SetWidgetCount(widget, count, useCount, isRolewear, isShowZero)
  if not widget then
    return
  end
  count = count and tonumber(count) or 0
  local isShow = isShowZero and 0 <= count or 0 < count
  self:_SetWidgetVisible(widget, isShow)
  if count == 0 then
    if isShowZero then
      widget:SetText(FuncUtil.TransformNumToFormatStr(count))
    end
    return
  end
  if isRolewear then
    widget:SetText(string.format("%d/%d", count - (useCount or 0), count))
  else
    widget:SetText(FuncUtil.TransformNumToFormatStr(count))
  end
end
function base_style:SetCount(item, number, useNumber, isRolewear, isShowZero)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetCount(item.Count, number, useNumber, isRolewear, isShowZero)
  end
end
function base_style:_SetWidgetIcon(iconWidget, specialIconWidget, resId)
  if not iconWidget then
    return
  end
  local UIUtil = require("client.common.ui_util")
  local util = require("client.slua_ui_framework.util")
  local itemData = UIUtil.GetItemCfg(resId)
  self:_SetWidgetVisible(iconWidget, itemData ~= nil)
  if not itemData then
    return
  end
  self:_SetSpecialIconShow(specialIconWidget, resId, itemData)
  local weapon_diy_utils = require("client.slua.umg.WeaponDIY.weapon_diy_utils")
  local bDIYColor, colorId = weapon_diy_utils:IsDiyColor(resId)
  if bDIYColor then
    weapon_diy_utils:SetDiyColorImage(iconWidget, colorId)
  else
    iconWidget:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    local iconPath, bHasAddKnownMissing = self:_GetIconPath(itemData, iconWidget)
    local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
    util.SetTexture(iconWidget, iconPath, params)
  end
end
function base_style:_SetSpecialIconShow(node_specialIcon, nItemId, tItemCfg)
  if not node_specialIcon or not nItemId then
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not tItemCfg then
    tItemCfg = UIUtil.GetItemCfg(nItemId)
    if not tItemCfg then
      return
    end
  end
  self:_SetWidgetVisible(node_specialIcon, tItemCfg.SpecialIcon ~= "")
  local util = require("client.slua_ui_framework.util")
  local SpecialIcon, bHasAddKnownMissingSp = UIUtil.GetItemSpecialIcon(nItemId, node_specialIcon)
  if SpecialIcon and SpecialIcon ~= "" then
    local params = {
      sync = false,
      bMatchSize = true,
      bHasAddKnownMissing = bHasAddKnownMissingSp
    }
    util.SetTexture(node_specialIcon, SpecialIcon, params)
  end
end
function base_style:_GetIconPath(itemData, iconWidget)
  local ItemType = itemData and itemData.ItemType or 0
  local ItemSubType = itemData and itemData.ItemSubType or 0
  local ItemSmallIcon = itemData and itemData.ItemSmallIcon or ""
  if ItemType == 100 then
    return ItemSmallIcon
  end
  if ItemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item and (ItemSubType == 1640 or ItemSubType == 1602) and not Client.IsJaguar() then
    return ItemSmallIcon
  end
  local bHasAddKnownMissing = false
  local iconPath = ""
  local ItemID = itemData and itemData.ItemID or 0
  local ItemSmallIcon2 = itemData and itemData.ItemSmallIcon2 or ""
  if ItemSmallIcon2 ~= "" then
    local UIUtil = require("client.common.ui_util")
    iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon2(ItemID, iconWidget)
  else
    local UIUtil = require("client.common.ui_util")
    iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(ItemID, iconWidget)
  end
  return iconPath, bHasAddKnownMissing
end
function base_style:SetIcon(item, resId)
  item = item and item.Common_Item_All_UIBP
  if item then
    local headshot_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.headshot_module)
    local sAvatarIconPath = headshot_module:GetAvatarIconCfg(resId)
    if slua.isValid(item.GIF_frame) and sAvatarIconPath then
      self:SetAvatarIcon(item, resId, sAvatarIconPath)
    else
      self:_SetWidgetIcon(item.Image_Icon, item.SpecialIcon, resId)
    end
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetItemCoBrandedVisibility(resId, item)
end
function base_style:SetSpecialIconShow(item, bShow)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.SpecialIcon, bShow)
  end
end
function base_style:SetHasGet(item, hasGet)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_HasGet, hasGet)
    self:_SetWidgetVisible(item.Image_BlackMask, hasGet)
  end
end
function base_style:SetTakeState(item, canTake)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_Available, canTake)
  end
end
function base_style:SetIconFromTexture(item, texture)
  item = item and item.Common_Item_All_UIBP
  if item then
    item.Image_Icon:SetBrushFromTexture(texture, false)
    self:ResetIconShowByAvatarFrame(item, false)
  end
end
function base_style:SetIconFromPath(item, texture)
  item = item and item.Common_Item_All_UIBP
  if item then
    local uiUtil = require("client.slua_ui_framework.util")
    uiUtil.SetTexture(item.Image_Icon, texture, {sync = false})
    self:ResetIconShowByAvatarFrame(item, false)
  end
end
function base_style:SetQualityBg(item, texture)
  item = item and item.Common_Item_All_UIBP
  if item then
    local uiUtil = require("client.slua_ui_framework.util")
    uiUtil.SetTexture(item.Image_Quality, texture)
  end
end
function base_style:_SetIconAlpha(iconWidget, qualityWidget, alpha)
  if iconWidget then
    iconWidget:SetOpacity(alpha)
  end
  if qualityWidget then
    qualityWidget:SetOpacity(alpha)
  end
end
function base_style:SetIconAlpha(item, alpha)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetIconAlpha(item.Image_Icon, item.Image_Quality, alpha)
  end
end
function base_style:SetImageIconAlpha(item, alpha)
  item = item and item.Common_Item_All_UIBP
  if item and item.Image_Icon and alpha then
    item.Image_Icon:SetOpacity(alpha)
  end
end
function base_style:SetHaveLimitTime(item, haveLimitTime)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.CanvasPanel_LimitTime, haveLimitTime)
  end
end
function base_style:ShowMask(item, isShow)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_BlackMask, isShow)
  end
end
function base_style:_SetColorAndPattern(colorWidget, patternWidget, colorId, patternId)
  colorId = colorId or 0
  patternId = patternId or 0
  if colorId == 0 then
    self:_SetWidgetVisible(colorWidget, false)
  elseif colorWidget then
    local UAvatarUtils = import("AvatarUtils")
    local diyColor = UAvatarUtils.GetDIYSuitShowColor(colorId)
    colorWidget:SetColorAndOpacity(diyColor)
    self:_SetWidgetVisible(colorWidget, true)
  end
  if patternId == 0 then
    self:_SetWidgetVisible(patternWidget, false)
  elseif patternWidget then
    local diyPattern = CDataTable.GetTableData("DiySuitPatternConfig", patternId)
    if diyPattern then
      local util = require("client.slua_ui_framework.util")
      util.SetTexture(patternWidget, diyPattern.Icon, {sync = false})
      self:_SetWidgetVisible(patternWidget, true)
    end
  end
end
function base_style:SetColorAndPattern(item, colorId, patternId)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetColorAndPattern(item.Image_tag1, item.Image_tag2, colorId, patternId)
  end
end
function base_style:SetIsRedEmotion(item, isRedEmotion)
end
function base_style:SetIsUnlockParticleEmote(item, isUnlock)
end
function base_style:SetIsOpenParticleEmote(item, bOpen)
end
function base_style:SetNameAddStr(item, extendName, haveLimitTime)
end
function base_style:HideNameAddrStr(item)
end
function base_style:SetNameColor(item, Color)
end
function base_style:_UpdateItemName(item, haveLimitTime)
end
function base_style:ShowItemName(isShowName)
end
function base_style:SetEveryPackIcon(item, isSpecailIconSwitch)
end
function base_style:SetExtraGetText(item, isExtraGet)
  item = item and item.Common_Item_All_UIBP
  if item and item.Text_ExtraGet then
    local UIUtil = require("client.common.ui_util")
    item.Text_ExtraGet:SetWidgetVisibility(UIUtil.BoolToVisible(isExtraGet))
  end
end
function base_style:SetRandomGetText(item, isRandomGet)
  item = item and item.Common_Item_All_UIBP
  if item and item.Text_RandomGet then
    local UIUtil = require("client.common.ui_util")
    item.Text_RandomGet:SetWidgetVisibility(UIUtil.BoolToVisible(isRandomGet))
  end
end
function base_style:SetSpecialIcon(item, path)
  if item then
    item = item.Common_Item_All_UIBP
    local util = require("client.slua_ui_framework.util")
    local params = {sync = false, bMatchSize = true}
    util.SetTexture(item.SpecialIcon, path, params)
  end
end
local ZeroVector2D = FVector2D(0, 0)
local OneVector2D = FVector2D(1, 1)
function base_style:SetSmallerIcon(item, isNeedSmall, count)
  item = item and item.Common_Item_All_UIBP
  if item then
    local imageIcon = item.Image_Icon
    if isNeedSmall then
      imageIcon:SetRenderTranslation(FVector2D(-10, -10))
      imageIcon:SetRenderScale(FVector2D(0.9, 0.9))
      self:_SetWidgetVisible(item.Count, false)
      self:_SetWidgetVisible(item.countL, true)
      item.countL:SetText("x" .. tostring(count))
    else
      imageIcon:SetRenderTranslation(ZeroVector2D)
      imageIcon:SetRenderScale(OneVector2D)
      self:_SetWidgetVisible(item.Count, true)
      item.Count:SetText(FuncUtil.TransformNumToFormatStr(count))
      self:_SetWidgetVisible(item.countL, false)
    end
  end
end
function base_style:PlayDecomposeAni(item, oldItemID, newItemID, newCnt)
end
function base_style:StopDecomposeAni()
end
function base_style:PlayDecomposeAniUP(item)
end
function base_style:ClearName()
end
function base_style:ResetIcon()
end
function base_style:SetCombatReadinessIcon()
end
function base_style:SetAwardState(item, state)
  item = item and item.Common_Item_All_UIBP
  if item and item.Image_HasGet then
    if state == 0 then
      self:_SetWidgetVisible(item.Image_HasGet, false)
      self:_SetWidgetVisible(item.Image_BlackMask, false)
      self:_SetWidgetVisible(item.Image_Lock, true)
    elseif state == 1 then
      self:_SetWidgetVisible(item.Image_HasGet, false)
      self:_SetWidgetVisible(item.Image_BlackMask, false)
      self:_SetWidgetVisible(item.Image_Lock, false)
    elseif state == 2 then
      self:_SetWidgetVisible(item.Image_HasGet, true)
      self:_SetWidgetVisible(item.Image_BlackMask, true)
      self:_SetWidgetVisible(item.Image_Lock, false)
    end
  end
end
function base_style:SetBGVisibility(item, visible)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_Bg_Default, visible)
  end
end
function base_style:SetBlackBg(item, isShow)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_BlackBg, isShow)
  end
end
function base_style:SetGrayBg(item, isShow)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_Bg_Lucky, isShow)
  end
end
function base_style:SetIsShowSubTransparentBg(item, isShow)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_SubTransparentBg, isShow)
  end
end
function base_style:SetValidTime(item, validtime)
  item = item and item.Common_Item_All_UIBP
  if item then
    if 0 < validtime then
      self:_SetWidgetVisible(item.TimePanel, true)
      item.TimeText:SetText(tostring(validtime) .. "d")
    else
      self:_SetWidgetVisible(item.TimePanel, false)
    end
  end
end
function base_style:HideQuality(item)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_IconQuality, false)
    self:_SetWidgetVisible(item.Image_Quality, false)
  end
end
function base_style:HideQualityOfBG(item)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_Quality, false)
  end
end
function base_style:SetLimitCount(item, IsShow, Has, Max)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.cost_root, IsShow)
    if IsShow then
      item.have_num:SetText(tostring(Has))
      item.cost_num:SetText(tostring(Max))
      local greenText = FSlateColor(FLinearColor(0, 1, 0, 1))
      local redColor = FSlateColor(FLinearColor(1, 0, 0, 1))
      if Has < Max then
        item.have_num:SetColorAndOpacity(greenText)
      else
        item.have_num:SetColorAndOpacity(redColor)
      end
    end
  end
end
function base_style:SetCostCount(item, IsShow, Has, Cost)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.cost_root, IsShow)
    if IsShow then
      item.have_num:SetText(tostring(Has))
      item.cost_num:SetText(tostring(Cost))
      local greenText = FSlateColor(FLinearColor(0, 1, 0, 1))
      local redColor = FSlateColor(FLinearColor(1, 0, 0, 1))
      if Has < Cost then
        item.have_num:SetColorAndOpacity(redColor)
      else
        item.have_num:SetColorAndOpacity(greenText)
      end
    end
  end
end
function base_style:SetHasGetText(item, hasGet)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.GetText, hasGet)
  end
end
function base_style:SetLimitTimeBlackBG(item, isBlack)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.Image_3, isBlack)
  end
end
function base_style:SetShowPriveShare(item, bShow, ShareType)
  item = item and item.Common_Item_All_UIBP
  if item then
    self:_SetWidgetVisible(item.CanvasPanel_Prime, bShow)
    local ShareIconIndex = ShareType == 2 and 1 or 0
    item.WidgetSwitcher_1:SetActiveWidgetIndex(ShareIconIndex)
  end
end
function base_style:SetAvatarIcon(node_item, nItemId, sAvatarIconPath)
  local AvatarGIFImageBPPool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AvatarGIFImageBPPool)
  AvatarGIFImageBPPool:GetAvatarGIFImage(node_item.GIF_frame, sAvatarIconPath)
  self:_SetSpecialIconShow(node_item.SpecialIcon, nItemId)
  self:ResetIconShowByAvatarFrame(node_item, true)
end
function base_style:ResetIconShowByAvatarFrame(node_item, bIsAvatarIcon)
  if slua.isValid(node_item.GIF_Frame) then
    self:_SetWidgetVisible(node_item.GIF_Frame, bIsAvatarIcon)
  end
  self:_SetWidgetVisible(node_item.Image_Icon, not bIsAvatarIcon)
end
function base_style:ClearAvatarIcon(node_item)
  node_item = node_item and node_item.Common_Item_All_UIBP
  if node_item and slua.isValid(node_item.GIF_Frame) then
    local AvatarGIFImageBPPool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AvatarGIFImageBPPool)
    AvatarGIFImageBPPool:RemoveAvatarChild(node_item.GIF_Frame)
    self:ResetIconShowByAvatarFrame(node_item, false)
  end
end
function base_style:ShowOrHideExclusivePng(node_item, show)
  if node_item.Image_Exclusive then
    self:_SetWidgetVisible(node_item.Image_Exclusive, show)
  end
end
local class = require("class")
local object = require("object")
local CBaseStyle = class(object, nil, base_style)
return CBaseStyle