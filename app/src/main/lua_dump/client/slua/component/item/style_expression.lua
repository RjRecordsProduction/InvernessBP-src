local style_expression = {}
function style_expression:SetQuality(item, quality, itemID)
  local imageIconQuality = item.Image_IconQuality
  local imageQuality = item.Image_Quality
  self:_SetQuality(imageIconQuality, imageQuality, quality, itemID)
end
function style_expression:SetIsNew(item, isNew)
  self:_SetWidgetVisible(item.Text_New, isNew)
end
function style_expression:GetButtonItem(item)
  return item.Button_SubTab
end
function style_expression:SetIsUsing(item, isUsing)
  self:_SetWidgetVisible(item.Image_Using, isUsing)
end
function style_expression:SetIsSelected(item, isSelected)
  self:_SetWidgetVisible(item.Image_Select, isSelected)
end
function style_expression:SetCount(item, number, useNumber, isRolewear)
  self:_SetWidgetCount(item.Text_Number, number, useNumber, isRolewear)
end
function style_expression:SetIcon(item, resId)
  self:_SetWidgetIcon(item.Image_Icon, item.Image_Special, resId)
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetItemCoBrandedVisibility(resId, item)
end
function style_expression:SetIconAlpha(item, alpha)
  self:_SetIconAlpha(item.Image_Icon, item.Image_Quality, alpha)
end
function style_expression:SetHaveLimitTime(item, haveLimitTime)
  self:_SetWidgetVisible(item.Image_LimitTime, haveLimitTime)
end
function style_expression:ShowMask(item, isShow)
  self:_SetWidgetVisible(item.Image_BlackMask, isShow)
end
function style_expression:SetIsRedEmotion(item, isRedEmotion)
  self:_SetWidgetVisible(item.Image_RedEmotion, isRedEmotion)
end
function style_expression:SetSpecialNew(item, isNew, resID)
  if not isNew then
    self:_SetWidgetVisible(item.Image_New, false)
    return
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local isSpecial = LogicXSuit.IsXSuitEmotion(resID)
  self:_SetWidgetVisible(item.Image_New, false)
  if item.Image_New and isSpecial then
    self:_SetWidgetVisible(item.Image_New, isNew)
    self:SetIsNew(item, false)
  end
end
function style_expression:SetIsUnlockParticleEmote(item, isUnlock)
  self:_SetWidgetVisible(item.WidegegSwitcher_ParticleStar, isUnlock)
end
function style_expression:SetIsOpenParticleEmote(item, bOpen)
  if bOpen then
    item.WidegegSwitcher_ParticleStar:SetActiveWidgetIndex(1)
  else
    item.WidegegSwitcher_ParticleStar:SetActiveWidgetIndex(0)
  end
end
local class = require("class")
local BaseStyle = require("client.slua.component.item.base_style")
local CStyleExpression = class(BaseStyle, nil, style_expression)
return CStyleExpression