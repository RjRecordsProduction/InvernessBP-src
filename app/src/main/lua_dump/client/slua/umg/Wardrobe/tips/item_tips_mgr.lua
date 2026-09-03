local ItemTipsMgr = {}
local item_tips_util = require("client.slua.umg.Wardrobe.tips.item_tips_util")
ItemTipsMgr.ENUM_ITEM_TIPS_TYPE = {
  ENUM_ITEM_TIPS_TYPE_TINY = 1,
  ENUM_ITEM_TIPS_TYPE_PROP = 2,
  ENUM_ITEM_TIPS_TYPE_SUIT = 3
}
function ItemTipsMgr:Destroy()
  if self.curTips then
    self.curTips:Close()
    self.curTips = nil
  end
end
function ItemTipsMgr:Show(tipsType, ...)
  if not item_tips_util:GetWardrobeUI() then
    return
  end
  self:Destroy()
  self:RefreshTips(tipsType, ...)
end
function ItemTipsMgr:Hide()
  self:Destroy()
end
function ItemTipsMgr:GetTinyTips(...)
  local widget = item_tips_util:GetWardrobeUI()
  local ui = widget:CreateChildWindow(widget.UIRoot.CanvasPanel_Tips, UIManager.UI_Config.item_tips_tiny_tips, ...)
  ui:SetAnchors(0, 0, 0, 0)
  ui:SetOffsets(0, 0, 100, 30)
  return ui
end
function ItemTipsMgr:GetPropTips(...)
  local widget = item_tips_util:GetWardrobeUI()
  if not widget or not widget.UIRoot then
    return nil
  end
  local ui = widget:CreateChildWindow(widget.UIRoot.Canvas_Panel_Tips2, UIManager.UI_Config.item_tips_prop_tips, ...)
  ui:SetAnchors(0, 0, 0, 0)
  ui:SetOffsets(0, 0, 100, 30)
  ui:SetAutoSize(true)
  return ui
end
function ItemTipsMgr:GetSuitTips(...)
  local widget = item_tips_util:GetWardrobeUI()
  local ui = widget:CreateChildWindow(widget.UIRoot.CanvasPanel_Tips, UIManager.UI_Config.item_tips_suit_tips, ...)
  ui:SetAnchors(0, 0, 0, 0)
  ui:SetOffsets(0, 0, 100, 30)
  return ui
end
function ItemTipsMgr:RefreshTips(tipsType, ...)
  log(bWriteLog and "ItemTipsMgr:RefreshTips")
  if not item_tips_util:GetWardrobeUI() then
    return
  end
  self.curTips = self:GetTipsByTipsType(tipsType, ...)
end
function ItemTipsMgr:GetTipsByTipsType(tipsType, ...)
  if tipsType == self.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY then
    return self:GetTinyTips(...)
  elseif tipsType == self.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_PROP then
    return self:GetPropTips(...)
  elseif tipsType == self.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_SUIT then
    return self:GetSuitTips(...)
  end
  return nil
end
return ItemTipsMgr