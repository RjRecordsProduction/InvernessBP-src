local subtab_tickets = {}
function subtab_tickets:ctor()
end
function subtab_tickets:OnInitialize()
  log(bWriteLog and "subtab_tickets:OnInitialize")
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_Wardrobe_Clothes, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Coupon, true)
  self.LoopScrollGrid_Normal = self:InitExtendedScrollGrid(self.UIRoot.ExtendedLoopScrollGrid_0)
  self.LoopScrollGrid_Normal:SetRefreshItemCallback(self.OnRefreshTitle, self)
  self.LoopScrollGrid_Normal:SetRefreshSubItemCallback(self.OnRefreshListItem, self)
  if self.UIRoot.CheckBox_Sort then
    self:RefreshCheckBoxState()
  else
    log(bWriteLog and "halendeng checkbox is missing")
  end
  self.itemListTable = self:GetItemListTable()
  self:UpdateItemList(self.itemListTable)
end
function subtab_tickets:OnPostInitialize()
  subtab_tickets.__super.__super.OnPostInitialize(self)
  self:SelectItem(1, 1)
end
function subtab_tickets:OnWardrobeDataChange(eventType, eventID, changelist)
  self:OnUpdateItemList(eventType, eventID)
  if not changelist then
    self:SelectItem(1, 1)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(changelist) do
    if wardrobe_data:GetItemCountByInsID(v.instid) == 0 then
      self:SelectItem(1, 1)
      return
    else
      local showListData = self:ClassificationOfItemType(self.itemListTable)
      for index, titleData in ipairs(showListData) do
        for subIndex, subData in ipairs(titleData.subItemList) do
          if v.instid and subData.ins_id and tostring(v.instid) == tostring(subData.ins_id) then
            self:SelectItem(index, subIndex)
            return
          end
        end
      end
    end
  end
end
function subtab_tickets:OnFashionBagChange()
  self.LoopScrollGrid_Normal:DeselectSub()
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Hide()
end
function subtab_tickets:UpdateItemList(itemListTable)
  log_tree("SubTabItemListBase:UpdateItemList ", itemListTable)
  if not itemListTable then
    log(bWriteLog and string.format("subtab_tickets:UpdateItemList itemListTable is nil"))
    return
  end
  local showListData = self:ClassificationOfItemType(itemListTable)
  self.LoopScrollGrid_Normal:SetData(showListData)
  for i, v in ipairs(showListData) do
    self.LoopScrollGrid_Normal:SetSubData(i, v.subItemList)
  end
  self.LoopScrollGrid_Normal:DeselectSub()
  if itemListTable and #itemListTable <= 0 then
    local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
    tipsMgr:Hide()
  end
end
function subtab_tickets:UpdateItemListBySort(itemListTable)
  if not itemListTable then
    log(bWriteLog and string.format("subtab_tickets:UpdateItemList itemListTable is nil"))
    return
  end
  local showListData = self:ClassificationOfItemType(itemListTable)
  self.LoopScrollGrid_Normal:SetData(showListData)
  for i, v in ipairs(showListData) do
    self.LoopScrollGrid_Normal:SetSubData(i, v.subItemList)
  end
  self.LoopScrollGrid_Normal:DeselectSub()
end
function subtab_tickets:UpdateOneItem(itemData)
  local index, subIndex, data = self:GetItemIndexByInsIdAndResId(itemData.ins_id, itemData.res_id)
  if data and next(data) then
    itemData.count = data.count
  end
  local MergeData = function(originData, newData)
    for k, v in pairs(newData) do
      originData[k] = v
    end
  end
  if index ~= -1 and data and next(data) then
    itemData.ins_id = nil
    itemData.res_id = nil
    MergeData(data, itemData)
    self.LoopScrollGrid_Normal:RefreshSubItem(index, subIndex, data)
  end
end
function subtab_tickets:GetItemIndexByInsIdAndResId(ins_id, res_id)
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, itemCount do
    local subItemList = self.LoopScrollGrid_Normal:GetSubItemList(i)
    for subIndex, data in ipairs(subItemList) do
      if data.ins_id == ins_id and data.res_id == res_id then
        return i, subIndex, data
      end
    end
  end
  return -1, -1, nil
end
function subtab_tickets:OnFashionBagEditUpdate(_, __)
  self.LoopScrollGrid_Normal:RefreshAllItems()
  self.LoopScrollGrid_Normal:RefreshAllSubItems()
end
function subtab_tickets:OnDownloadFinish(_, _, eventData)
end
function subtab_tickets:OnClickItem(widget, index, subIndex)
  self:PlayAudio(sound_config.click_v1)
  local itemData = self.LoopScrollGrid_Normal:GetSubItemData(index, subIndex)
  if not itemData then
    log(bWriteLog and string.format("subtab_tickets:OnClickItem itemData is nil"))
    return
  end
  log_tree("subtab_tickets:OnClickItem", itemData)
  if itemData.lock_cnt and itemData.lock_cnt > 0 then
    ShowNotice(3000016)
    return
  end
  if not DataMgr.IsValidTime(itemData.expireTS) then
    ShowNotice(9910101)
    return
  end
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe_new:SetClickItemInsId(itemData.ins_id)
  self:ClearItemNewAndRedPoint(itemData)
  self.LoopScrollGrid_Normal:SelectSub(index, subIndex)
  self:ShowTips(index, subIndex)
end
function subtab_tickets:SelectItem(index, subIndex)
  if index > #self.itemListTable then
    return
  end
  self.LoopScrollGrid_Normal:SelectSub(index, subIndex)
  self:ShowTips(index, subIndex)
  local itemData = self.LoopScrollGrid_Normal:GetSubItemData(index, subIndex)
  if itemData then
    local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    logic_wardrobe_new:SetClickItemInsId(itemData.ins_id)
  end
end
function subtab_tickets:ShowTips(index, subIndex)
  local itemData = self.LoopScrollGrid_Normal:GetSubItemData(index, subIndex)
  if itemData then
    local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
    tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_PROP, itemData.ins_id, itemData.res_id)
  end
end
function subtab_tickets:OnUpdatePutDownData(eventType, eventID, putDownItem)
end
function subtab_tickets:ClassificationOfItemType(itemListTable)
  local itemList = {}
  local couponList = {}
  local voucherList = {}
  local otherList = {}
  for _, v in ipairs(itemListTable) do
    if v.itemSubType == ENUM_ITEM_SUBTYPE.Coupon or v.itemSubType == ENUM_ITEM_SUBTYPE.SpecialCoupon then
      table.insert(couponList, v)
    elseif v.itemSubType == ENUM_ITEM_SUBTYPE.ExchangeCoin then
      table.insert(voucherList, v)
    else
      table.insert(otherList, v)
    end
  end
  if 0 < #voucherList then
    table.insert(itemList, {
      title = LocUtil.GetLocalizeResStr(792131),
      subItemList = voucherList
    })
  end
  if 0 < #couponList then
    table.insert(itemList, {
      title = LocUtil.GetLocalizeResStr(792133),
      subItemList = couponList
    })
  end
  if 0 < #otherList then
    table.insert(itemList, {
      title = LocUtil.GetLocalizeResStr(792132),
      subItemList = otherList
    })
  end
  return itemList
end
function subtab_tickets:OnRefreshTitle(widget, index)
  local titleInfo = self.LoopScrollGrid_Normal:GetItemData(index)
  if widget then
    local str = ""
    if titleInfo then
      str = tostring(titleInfo.title or "")
    end
    widget.TextBlock_Coupon:SetText(str)
  end
end
function subtab_tickets:OnRefreshListItem(widget, index, subIndex)
  local itemData = self.LoopScrollGrid_Normal:GetSubItemData(index, subIndex)
  local isSelect = index == self.LoopScrollGrid_Normal:GetSelectIndex()
  local isSelectSub = subIndex == self.LoopScrollGrid_Normal:GetSubSelectIndex()
  self:RefreshListItem(widget, itemData, isSelect and isSelectSub, index, true)
  widget:SetClickItemCallback(self.OnClickItem, self, widget, index, subIndex)
end
local Class = require("class")
local SubTabProPos = require("client.slua.umg.Wardrobe.subtab_props")
local UITemplate = Class(SubTabProPos, nil, subtab_tickets)
return UITemplate