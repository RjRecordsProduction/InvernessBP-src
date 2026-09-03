local Lua_CommonItems = {}
function Lua_CommonItems:RegistEvents()
  Lua_CommonItems.__super.RegistEvents(self)
  self:BindDragDropEvent()
end
function Lua_CommonItems:OnClose()
  self._cObj_ui = nil
  Lua_CommonItems.__super.OnClose(self)
end
function Lua_CommonItems:_CreateItem()
  if self._cObj_ui then
    return
  end
  self._cObj_ui = self:CreateChildWindow(self.CanvasPanel_ItemBase, UIManager.UI_Config.Common_Items_UIBP)
end
function Lua_CommonItems:_ClearItem()
  self._cObj_ui = nil
  self:CloseChildWindow()
  self:UnBindDragDropEvent()
end
function Lua_CommonItems:BindDragDropEvent()
  self:AddControlEvent(self.Common_DragDrop_Item, "OnDragClicked", self.OnDragClicked, self)
end
function Lua_CommonItems:UnBindDragDropEvent()
  self:RemoveControlEvent(self.Common_DragDrop_Item, "OnDragClicked")
end
function Lua_CommonItems:OnDragClicked()
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:OnDragClickHandler()
end
function Lua_CommonItems:InitView(nItemId, nCount, nValidTime, tExtraData)
  self:_CreateItem()
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:InitView(nItemId, nCount, nValidTime, tExtraData)
end
function Lua_CommonItems:SetIconFromTexture(uObj_texture, bMatchSize)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIconFromTexture(uObj_texture, bMatchSize)
end
function Lua_CommonItems:SetIconFromPath(sPicPath, extendedParams)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIconFromPath(sPicPath, extendedParams)
end
function Lua_CommonItems:ReSetIconFromItemId(ItemId)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:ReSetIconFromItemId(ItemId)
end
function Lua_CommonItems:SetQualityBg(sPicPath)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetQualityBg(sPicPath)
end
function Lua_CommonItems:SetUseCount(nUseCount, bIsRoleWear, bIsShowZero)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetUseCount(nUseCount, bIsRoleWear, bIsShowZero)
end
function Lua_CommonItems:SetNumber(nCount, bIsShowZero)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetNumber(nCount, bIsShowZero)
end
function Lua_CommonItems:EnableShowTips(bIsShowTip)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:EnableShowTips(bIsShowTip)
end
function Lua_CommonItems:EnableItemPreview(nShowPreviewType, tShowPreviewParams, bPreviewFromSelf)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:EnableItemPreview(nShowPreviewType, tShowPreviewParams, bPreviewFromSelf)
end
function Lua_CommonItems:DisableItemPreview()
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:DisableItemPreview()
end
function Lua_CommonItems:EnableClick()
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:EnableClick()
end
function Lua_CommonItems:DisableClick()
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:DisableClick()
end
function Lua_CommonItems:SetPartnerItemShowPreview(bShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetPartnerItemShowPreview(bShow)
end
function Lua_CommonItems:SetPersonalizedItemPreview(bShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetPersonalizedItemPreview(bShow)
end
function Lua_CommonItems:SetClickItemCallback(fCallback, ...)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetClickItemCallback(fCallback, ...)
end
function Lua_CommonItems:SetCountFontSize(nFontSize)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetCountFontSize(nFontSize)
end
function Lua_CommonItems:SetCountScaleSize()
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetCountScaleSize()
end
function Lua_CommonItems:SetCostCount(nHasCount, nNeedCount)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetCostCount(nHasCount, nNeedCount)
end
function Lua_CommonItems:SetShadowCostCount(nHasCount, nNeedCount)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetShadowCostCount(nHasCount, nNeedCount)
end
function Lua_CommonItems:SetIsNew(bIsNew, newColor)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsNew(bIsNew, newColor)
end
function Lua_CommonItems:SetIsIncreaseProbability(bIsShowUp)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsIncreaseProbability(bIsShowUp)
end
function Lua_CommonItems:SetPlusSuperscript(bIsShowUp)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetPlusSuperscript(bIsShowUp)
end
function Lua_CommonItems:SetIsShowExclusiveOneYearPng(bIsShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsShowExclusiveOneYearPng(bIsShow)
end
function Lua_CommonItems:SetCheckIsPetSuitIcon(bIsShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetCheckIsPetSuitIcon(bIsShow)
end
function Lua_CommonItems:SetUsingState(bIsUsing)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetUsingState(bIsUsing)
end
function Lua_CommonItems:SetSpecialIconShow(bIsShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetSpecialIconShow(bIsShow)
end
function Lua_CommonItems:SetSignIconShow(bIsShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetSignIconShow(bIsShow)
end
function Lua_CommonItems:SetSpecialIcon(sPath)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetSpecialIcon(sPath)
end
function Lua_CommonItems:SetIsHavePVEAffix(bIsHave)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsHavePVEAffix(bIsHave)
end
function Lua_CommonItems:SetIsLock(bIsLock, bIsCheckMask)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsLock(bIsLock, bIsCheckMask)
end
function Lua_CommonItems:SetHasGet(bHasGet)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetHasGet(bHasGet)
end
function Lua_CommonItems:ShowMask(bIsShowMask)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetBlackMask(bIsShowMask)
end
function Lua_CommonItems:SetAwardState(nState)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetAwardState(nState)
end
function Lua_CommonItems:SetShowInheritIcon(bShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetShowInheritIcon(bShow)
end
function Lua_CommonItems:SetColorAndPattern(nColorId, nPatternId)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetColorAndPattern(nColorId, nPatternId)
end
function Lua_CommonItems:SetIsUnlockParticleEmote(bIsShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsUnlockParticleEmote(bIsShow)
end
function Lua_CommonItems:SetIsOpenParticleEmote(bIsOpen)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsOpenParticleEmote(bIsOpen)
end
function Lua_CommonItems:SetCenterTextShow(sContentStr, nFontSize)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetCenterTextShow(sContentStr, nFontSize)
end
function Lua_CommonItems:SetIsolated(bIsIsolated, sCustomText)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsolated(bIsIsolated, sCustomText)
end
function Lua_CommonItems:SetSelected(bIsSelected)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetSelected(bIsSelected)
end
function Lua_CommonItems:SetIconAndQualityAlpha(nAlpha)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIconAndQualityAlpha(nAlpha)
end
function Lua_CommonItems:SetIconAlpha(nAlpha)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIconAlpha(nAlpha)
end
function Lua_CommonItems:SetIconIsShow(bIsShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIconIsShow(bIsShow)
end
function Lua_CommonItems:SetQuality(nQuality)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetQuality(nQuality)
end
function Lua_CommonItems:SetLight(bIsShow, bIsHideSweepLight)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetLight(bIsShow, bIsHideSweepLight)
end
function Lua_CommonItems:SetCollectNum(nScore)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetCollectNum(nScore)
end
function Lua_CommonItems:SetTimeLimitIcon(bIsShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetTimeLimitIcon(bIsShow)
end
function Lua_CommonItems:SetHasGetText(bIsShowOwned, nFontSize)
  local sContentStr = bIsShowOwned and LocUtil.GetLocalizeResStr(3027)
  self:SetCenterTextShow(sContentStr, nFontSize)
end
function Lua_CommonItems:SetIsWear(bIsEquipping)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsWear(bIsEquipping)
end
function Lua_CommonItems:SetShowSharedIcon(bIsShow, nShareType)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetShowSharedIcon(bIsShow, nShareType)
end
function Lua_CommonItems:SetIsTryOn(bIsTryOn)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsTryOn(bIsTryOn)
end
function Lua_CommonItems:HideQuality()
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:HideQuality()
end
function Lua_CommonItems:HideItem()
  self:_ClearItem()
end
function Lua_CommonItems:HideItemButton()
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:HideItemButton()
end
function Lua_CommonItems:HideImageIcon()
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:HideImageIcon()
end
function Lua_CommonItems:SetShowUseTime(bShowUseTime)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetShowUseTime(bShowUseTime)
end
function Lua_CommonItems:SetMatchNum(bShow, nNum)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetMatchNum(bShow, nNum)
end
function Lua_CommonItems:SetJumpConfig(fJumpCallback, sJumpClickTxt)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetJumpConfig(fJumpCallback, sJumpClickTxt)
end
function Lua_CommonItems:SetSpecialContent(sSpecialContent, nSpecialContentFontSize)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetSpecialContent(sSpecialContent, nSpecialContentFontSize)
end
function Lua_CommonItems:SetIsRedEmotion(bIsRedEmotion, bIsRed)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsRedEmotion(bIsRedEmotion, bIsRed)
end
function Lua_CommonItems:SetUpgradeDiscountNumShow(nHasCount, nCostOriPrice, nCostDisPrice, bIsInActivityTime)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetUpgradeDiscountNumShow(nHasCount, nCostOriPrice, nCostDisPrice, bIsInActivityTime)
end
function Lua_CommonItems:PlayDecomposeAni(nOldItemID, tDecItem)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:PlayDecomposeAni(nOldItemID, tDecItem)
end
function Lua_CommonItems:ShowDecompose(nOldItemID, tDecItem)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:ShowDecompose(nOldItemID, tDecItem)
end
function Lua_CommonItems:SetIsShowExclusivePng(bIsShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIsShowExclusivePng(bIsShow)
end
function Lua_CommonItems:SetCollectStatus(bIsShow, bIsCollected)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetCollectStatus(bIsShow, bIsCollected)
end
function Lua_CommonItems:SetIconSpacerShow(bIsIconSpacerShow)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:SetIconSpacerShow(bIsIconSpacerShow)
end
function Lua_CommonItems:CORChildUIRefreshImage(sChildName, tChildCfg, bIsShow, sNodeName, sIconPath)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:CORChildUIRefreshImage(sChildName, tChildCfg, bIsShow, sNodeName, sIconPath)
end
function Lua_CommonItems:InitChildShowByChildCfg(sChildName, tChildCfg, bIsShow, fShowedCallback)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:InitChildShowByChildCfg(sChildName, tChildCfg, bIsShow, fShowedCallback)
end
function Lua_CommonItems:InitChildShowByUIConfig(sChildName, tUIConfig, bIsShow, fShowedCallback, nZOrder, ...)
  if not self._cObj_ui then
    return
  end
  self._cObj_ui:InitChildShowByUIConfig(sChildName, tUIConfig, bIsShow, fShowedCallback, nZOrder, ...)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Lua_CommonItems)