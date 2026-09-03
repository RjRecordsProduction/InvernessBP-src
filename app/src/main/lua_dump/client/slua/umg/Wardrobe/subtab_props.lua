local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
local WardrobeProps = {}
function WardrobeProps:ctor()
end
local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
function WardrobeProps:OnShow()
  WardrobeProps.__super.OnShow(self)
  TeamAvatarManager.GetMutex(TeamAvatarManager.MUTEX_WARDROBE)
  TeamAvatarManager.HideAllAvatar(TeamAvatarManager.MUTEX_WARDROBE)
  self:OnWardrobeDataChange()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_ENTRY_ICON, false)
end
function WardrobeProps:OnHide()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_ENTRY_ICON, true)
  WardrobeProps.__super.OnHide(self)
end
function WardrobeProps:Close()
  TeamAvatarManager.ShowAllAvatar(TeamAvatarManager.MUTEX_WARDROBE)
  TeamAvatarManager.ReleaseMutex(TeamAvatarManager.MUTEX_WARDROBE)
  WardrobeProps.__super.Close(self)
end
function WardrobeProps:OnInitialize()
  log(bWriteLog and "WardrobeProps:OnInitialize")
  self.itemListTable = self:GetItemListTable()
  WardrobeProps.__super.OnInitialize(self)
  self:UpdateItemList(self.itemListTable)
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  log(bWriteLog and "[    " .. tostring(UnknowPassUtil.IsNewSeason()))
  if UnknowPassUtil.IsNewSeason() then
    local PassHander = require("client.network.Protocol.PassHander")
    PassHander.send_upass_open_check_req()
  end
end
function WardrobeProps:OnPostInitialize()
  WardrobeProps.__super.OnPostInitialize(self)
  self:SelectItem(1)
end
function WardrobeProps:RegistEvents()
  WardrobeProps.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST, self.OnUpdateItemList, self)
end
function WardrobeProps:OnUpdateItemList(eventType, eventID)
  self.itemListTable = self:GetItemListTable()
  self:SetInitItemList(self.itemListTable)
  if self.UIRoot.WidgetSwitcher_Search then
    self.itemListTable = self:DoSearch(self.itemListTable, WardrobeLogicManager:GetSearchString())
  end
  if self.bShowTagFilter then
    self.itemListTable = self:DoFilterTags(self.itemListTable)
  end
  self:UpdateItemList(self.itemListTable)
  local count = self.LoopScrollGrid_Normal:GetItemCount()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_NoItem, count == 0)
end
function WardrobeProps:OnWardrobeDataChange(eventType, eventID, changelist)
  self:OnUpdateItemList(eventType, eventID)
  if not changelist then
    self:SelectItem(1)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(changelist) do
    if wardrobe_data:GetItemCountByInsID(v.instid) == 0 then
      self:SelectItem(1)
      break
    else
      local selectIndex = 1
      for index, value in ipairs(self.itemListTable) do
        if v.instid and value.ins_id and tostring(v.instid) == tostring(value.ins_id) then
          selectIndex = index
          break
        end
      end
      self:SelectItem(selectIndex)
      break
    end
  end
end
function WardrobeProps:CheckCurrentPage(v, serverTime)
  if WardrobeLogicManager:IsValidCurrentPageItem(self.subTabConfig.pageId, self.subTabConfig.subTabId, v, serverTime) then
    return true
  end
  return false
end
local GetIsUsing = function(v)
  if DataMgr.ratingShieldCardID == v.insID then
    return true
  end
  if DataMgr.seasonRatingShieldCardID == v.insID then
    return true
  end
  if DataMgr.seasonPakeGameRatingShieldCardID == v.insID then
    return true
  end
  local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
  if logic_wardrobe_card:IsCardPutOn(v.insID) then
    return true
  end
  local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
  if LogicAddScordCard:IsPutOnAddScoreCardByInsId(v.insID) or LogicAddScordCard:IsPutOnPeakGameAddScoreCardByInsId(v.insID) then
    return true
  end
  if DataMgr.common_depot_puton and DataMgr.common_depot_puton.click_effect and DataMgr.common_depot_puton.click_effect == v.insID then
    return true
  end
  return false
end
function WardrobeProps:GetItemListTable()
  log(bWriteLog and "WardrobeProps:UpdatePropsList")
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local depotItemList = WardrobeDataManager:GetArrayHallDepotItemInfo()
  local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
  local itemListTable = {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(depotItemList) do
    if self:CheckCurrentPage(v, serverTime) and WardrobeLogicManager:IsWardrobeShow(v) then
      local is_using = GetIsUsing(v)
      local itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #itemListTable, is_using, true, false, false, false)
      table.insert(itemListTable, itemInfo)
    end
  end
  table.sort(itemListTable, function(a, b)
    local aHasTime = a.expireTS ~= 0
    local bHasTime = b.expireTS ~= 0
    local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
    if SortPreference then
      local High32Bits_a = WardrobeLogicManager:ExtractHigh32Bits(a.ins_id)
      local High32Bits_b = WardrobeLogicManager:ExtractHigh32Bits(b.ins_id)
      if High32Bits_a ~= High32Bits_b then
        return High32Bits_a > High32Bits_b
      else
        local Low19Bits_a = WardrobeLogicManager:ExtractLow19Bits(a.ins_id)
        local Low19Bits_b = WardrobeLogicManager:ExtractLow19Bits(b.ins_id)
        if Low19Bits_a ~= Low19Bits_b then
          return Low19Bits_a > Low19Bits_b
        end
      end
    end
    if a.isNew ~= b.isNew then
      return a.isNew
    end
    if a.quality ~= b.quality then
      return a.quality > b.quality
    end
    if aHasTime ~= bHasTime then
      return bHasTime
    else
      return false
    end
  end)
  return itemListTable
end
function WardrobeProps:OnClickItem(widget, index)
  WardrobeProps.__super.OnClickItem(self, widget, index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if itemData and not DataMgr.IsValidTime(itemData.expireTS) then
    ShowNotice(9910101)
    return
  end
  if self:NeedShowAvatarDisplay(itemData.itemSubType) then
    self:ShowAvatarDisplay(index)
  else
    self:ShowTips(index)
  end
  self:HandleRatingShieldOnceCard(index)
  self:HandleClickEffect(index)
end
function WardrobeProps:GetIndexByInsId(itemListTable, itemInsId)
  for k, v in ipairs(itemListTable) do
    if v.ins_id == itemInsId then
      return k
    end
  end
end
function WardrobeProps:SelectItem(index)
  if index > #self.itemListTable then
    return
  end
  self.LoopScrollGrid_Normal:Select(index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if not itemData then
    return
  end
  if self.NeedShowAvatarDisplay(itemData.itemSubType) then
    self:ShowAvatarDisplay(index)
  else
    self:ShowTips(index)
  end
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if itemData then
    local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    logic_wardrobe_new:SetClickItemInsId(itemData.ins_id)
  end
end
function WardrobeProps:ShowTips(index)
  if self.widgetAvatarDisplay then
    self.widgetAvatarDisplay:ClearAvatarDisplay()
  end
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if itemData then
    local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
    tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_PROP, itemData.ins_id, itemData.res_id)
  end
end
function WardrobeProps:ShowAvatarDisplay(index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if not itemData then
    return
  end
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Hide()
  local ConstAvatarDisplay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  if not self.widgetAvatarDisplay then
    local item_tips_util = require("client.slua.umg.Wardrobe.tips.item_tips_util")
    local widget = item_tips_util:GetWardrobeUI()
    self.widgetAvatarDisplay = self:CreateChildWindow(widget.UIRoot.CanvasPanel_9, UIManager.UI_Config.AvatarDisplayComponent)
    self.widgetAvatarDisplay:InitAvatarDisplay(nil, ConstAvatarDisplay.ESceneType.Wardrobe)
  end
  self.widgetAvatarDisplay:ShowAvatarDisplay(itemData.res_id, ConstAvatarDisplay.ESceneType.Wardrobe)
end
function WardrobeProps:HandleRatingShieldOnceCard(index)
  log(bWriteLog and "WardrobeProps:HandleRatingShieldOnceCard")
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  local TableUtil = require("common.table_util")
  local itemInsId = TableUtil.GetTableValue(itemData, "ins_id")
  local itemResId = TableUtil.GetTableValue(itemData, "res_id")
  local itemIsUsing = TableUtil.GetTableValue(itemData, "isUsing")
  local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if WardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE ~= itemResId and WardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE_SEASON ~= itemResId and PeakGameConfig.ProtectCard.PointsProtectionCard ~= itemResId then
    return
  end
  if itemIsUsing then
    WardrobeLogicManager:wardrobe_put_down_req(itemData.ins_id)
  else
    WardrobeLogicManager:wardrobe_puton_req(itemData.ins_id)
  end
end
function WardrobeProps:HandleClickEffect(index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if not itemData then
    return
  end
  if itemData.itemSubType ~= ENUM_ITEM_SUBTYPE.ClickEffect then
    return
  end
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, itemData.ins_id, itemData.res_id)
end
function WardrobeProps:ChangeItemStatusByInsID(itemInsID, status, type)
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    if data.ins_id == itemInsID then
      data[type] = status
      self.LoopScrollGrid_Normal:RefreshItem(i, data)
    end
  end
end
function WardrobeProps:OnUpdatePutOnData(eventType, eventID, putOnItem, putDownItem)
  if putDownItem ~= nil then
    self:ChangeItemStatusByInsID(putDownItem.instid, false, "isUsing")
  end
  if putOnItem ~= nil then
    self:ChangeItemStatusByInsID(putOnItem.instid, true, "isUsing")
  end
end
function WardrobeProps:OnUpdatePutDownData(eventType, eventID, putDownItem)
  local instid = putDownItem and putDownItem.instid
  self:ChangeItemStatusByInsID(instid, false, "isUsing")
end
function WardrobeProps:OnClickCheckBox()
  self:PlayAudio(sound_config.toggle_v1)
  local isChecked = self.UIRoot.CheckBox_Sort:IsChecked()
  if isChecked then
    WardrobeLogicManager:SetSortPreference(self.subTabConfig, true)
  else
    WardrobeLogicManager:SetSortPreference(self.subTabConfig, false)
  end
  self:OnUpdateItemList()
end
function WardrobeProps:HandleSeasonAddScoreCard(index)
  log(bWriteLog and "WardrobeProps:HandleSeasonAddScoreCard")
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  local TableUtil = require("common.table_util")
  local itemInsId = TableUtil.GetTableValue(itemData, "ins_id")
  local itemResId = TableUtil.GetTableValue(itemData, "res_id")
  local itemIsUsing = TableUtil.GetTableValue(itemData, "isUsing")
  local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
  if not LogicAddScordCard:IsPutOnSeasonAddScoreCard(itemResId) then
    return
  end
  if itemIsUsing then
    WardrobeLogicManager:wardrobe_put_down_req(itemData.ins_id)
  else
    WardrobeLogicManager:wardrobe_puton_req(itemData.ins_id)
  end
end
function WardrobeProps:NeedShowAvatarDisplay(itemSubType)
  if itemSubType == ENUM_ITEM_SUBTYPE.ClickEffect then
    return true
  end
  return false
end
local class = require("class")
local ui_subtab_item_list_base = require("client.slua.umg.Wardrobe.subtab_item_list_base")
local CWardrobeProps = class(ui_subtab_item_list_base, nil, WardrobeProps)
return CWardrobeProps