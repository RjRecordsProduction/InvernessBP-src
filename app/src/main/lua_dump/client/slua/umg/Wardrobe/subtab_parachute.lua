local FashionBag = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
local Visible = UEnums.ESlateVisibility.Visible
local Collapsed = UEnums.ESlateVisibility.Collapsed
local HitTestInvisible = UEnums.ESlateVisibility.HitTestInvisible
local WardrobeParachute = {}
function WardrobeParachute:ctor()
end
function WardrobeParachute:OnShow()
  WardrobeParachute.__super.OnShow(self)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_RESET_DEFAULT_RESTRICT_ZONE)
  TeamAvatarManager.GetMutex(TeamAvatarManager.MUTEX_WARDROBE)
  TeamAvatarManager.HideAllAvatar(TeamAvatarManager.MUTEX_WARDROBE)
  self:InitParachuteSkin()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Show()
end
function WardrobeParachute:Close()
  log(bWriteLog and "WardrobeParachute:Close")
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Hide()
  TeamAvatarManager.ShowAllAvatar(TeamAvatarManager.MUTEX_WARDROBE)
  TeamAvatarManager.ReleaseMutex(TeamAvatarManager.MUTEX_WARDROBE)
  WardrobeParachute.__super.Close(self)
end
function WardrobeParachute:OnInitialize()
  log(bWriteLog and "WardrobeParachute:OnInitialize")
  WardrobeParachute.__super.OnInitialize(self)
  self.LoopScrollGridSkins = self.LoopScrollGrid_Normal
  WardrobeLogicManager:EnterParachuteScene()
end
function WardrobeParachute:RegistEvents()
  WardrobeParachute.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SWITCH_USE_ROLEWEAR, self.OnFashionBagChange, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_PARACHUTE_UPDATE, self.OnFashionBagEditParachuteUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_JUMPBACK, self.OnFashionBagEditJumpBack, self)
end
function WardrobeParachute:InitParachuteSkin()
  log(bWriteLog and "WardrobeParachute:InitParachuteSkin")
  local isUsing, itemInfo
  local skinList = {}
  local tabID = self.subTabConfig.subTabId
  local pageID = self.subTabConfig.pageId
  local depotItemList = WardrobeDataManager:GetArrayHallDepotItemInfo()
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local equippedSkinInsID
  if WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag then
    equippedSkinInsID = FashionBagEditUtils:GetCurrentParachute()
    if not equippedSkinInsID then
      equippedSkinInsID = FashionBag:GetParachute()
    end
  else
    equippedSkinInsID = FashionBag:GetParachute()
  end
  local equippedSkin = WardrobeDataManager:GetHallDepotItemDataByInsID(equippedSkinInsID)
  if not equippedSkin then
    equippedSkin = WardrobeDataManager:GetHallDepotItemDataByResID(DataMgr.defaultParachuteResID)
    if not equippedSkin then
      return
    end
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(depotItemList) do
    if WardrobeLogicManager:IsValidCurrentPageItem(pageID, tabID, v, serverTime) then
      isUsing = equippedSkin.insID == v.insID
      itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #skinList, isUsing, false, false, false, false)
      table.insert(skinList, itemInfo)
    end
  end
  self:SetInitItemList(skinList)
  if self.UIRoot.WidgetSwitcher_Search then
    skinList = self:DoSearch(skinList, WardrobeLogicManager:GetSearchString())
  end
  if self.bShowTagFilter then
    skinList = self:DoFilterTags(skinList)
  end
  local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
  WardrobeLogicManager:SortItemTable(skinList, SortPreference)
  self:SetSkins(skinList)
  WardrobeLogicManager:SetClickItemInsId(equippedSkin.insID)
  self:ShowParachuteModelInfo(equippedSkin.insID, equippedSkin.resID)
end
function WardrobeParachute:OnClickItem(widget, index)
  log(bWriteLog and "WardrobeParachute:OnClickItem")
  WardrobeParachute.__super.OnClickItem(self, widget, index)
  local parachuteSkin = self:GetSkins(index)
  if parachuteSkin then
    if not DataMgr.IsValidTime(parachuteSkin.expireTS) then
      ShowNotice(9910101)
      return
    end
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    if not logic_wardrobe:IsCanUse(parachuteSkin.res_id) then
      ShowNotice(4987)
      return
    end
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    local bInFashionBagEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
    if not bInFashionBagEditMode then
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local State = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
        parachuteSkin.res_id
      })
      local bDownloaded = State == PufferConst.ENUM_DownloadState.Done
      if bDownloaded then
        WardrobeLogicManager:wardrobe_puton_req(parachuteSkin.ins_id)
      end
    else
      local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
      FashionBagEditUtils:PutOnFashionBagItem(parachuteSkin)
      self:ShowParachuteModelInfo(parachuteSkin.ins_id, parachuteSkin.res_id)
    end
  end
end
function WardrobeParachute:OnUpdatePutOnData(eventType, eventID, putOnItem, putDownItem)
  if putDownItem ~= nil then
    self:ChangeItemStatusByInsID(putDownItem.instid, false, "isUsing")
  end
  if putOnItem ~= nil then
    self:ChangeItemStatusByInsID(putOnItem.instid, true, "isUsing")
    self:ShowParachuteModelInfo(putOnItem.instid, putOnItem.res_id)
  end
end
function WardrobeParachute:OnFashionBagChange(_, __, CurrentIndex)
  WardrobeParachute.__super.OnFashionBagChange(self, _, __, CurrentIndex)
  self:InitParachuteSkin()
end
function WardrobeParachute:PutDownItem(eventType, eventID, putDownItem)
  self:ChangeItemStatusByInsID(putDownItem.instid, false, "isUsing")
end
function WardrobeParachute:ChangeItemStatusByInsID(itemInsID, status, type)
  for i = 1, self:GetItemCount() do
    local data = self:GetSkins(i)
    if data.ins_id == itemInsID then
      data[type] = status
      self:RefreshSkin(i, data)
    end
  end
end
function WardrobeParachute:OnWardrobeDataChange(eventType, eventID)
  self:InitParachuteSkin()
  local count = self.LoopScrollGrid_Normal:GetItemCount()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_NoItem, count == 0)
end
function WardrobeParachute:GetItemCount()
  return self.LoopScrollGridSkins:GetItemCount()
end
function WardrobeParachute:RefreshSkin(index, data)
  self.LoopScrollGridSkins:RefreshItem(index, data)
end
function WardrobeParachute:ClearSkins()
  self.LoopScrollGridSkins:SetData({})
end
function WardrobeParachute:SetSkins(skinTable)
  self.LoopScrollGridSkins:SetData(skinTable)
end
function WardrobeParachute:GetSkins(index)
  return self.LoopScrollGridSkins:GetItemData(index)
end
function WardrobeParachute:ShowParachuteModelInfo(instid, res_id)
  local wardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local itemData = WardrobeDataManager:GetHallDepotItemDataByInsID(instid)
  if itemData and itemData.subTabType == wardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_parachute then
    WardrobeLogicManager:ShowParachuteModel(res_id)
    local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
    tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, instid, res_id)
  else
    local ins_id = WardrobeLogicManager:GetClickItemInsId()
    local data = WardrobeDataManager:GetHallDepotItemDataByInsID(ins_id)
    if data and data.subTabType == wardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_parachute then
      local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
      tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, ins_id, data.resID)
    end
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, res_id)
end
function WardrobeParachute:OnFashionBagEditUpdate(_, __)
  WardrobeParachute.__super.OnFashionBagEditUpdate(self, _, __)
  self:RefreshParachuteInFashionBag()
end
function WardrobeParachute:OnFashionBagEditExit(_, __)
  WardrobeParachute.__super.OnFashionBagEditExit(self, _, __)
  log(bWriteLog and "WardrobeParachute:OnFashionBagEditExit. ")
  self:InitParachuteSkin()
  self:RefreshParachuteInFashionBag()
end
function WardrobeParachute:RefreshParachuteInFashionBag()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInFashionBagEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  local equippedSkinInsID
  if bInFashionBagEditMode then
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    equippedSkinInsID = FashionBagEditUtils:GetCurrentParachute()
    if not equippedSkinInsID then
      equippedSkinInsID = FashionBag:GetParachute()
    end
  else
    equippedSkinInsID = FashionBag:GetParachute()
  end
  local parachuteSkin = WardrobeDataManager:GetHallDepotItemDataByInsID(equippedSkinInsID)
  if parachuteSkin then
    if not DataMgr.IsValidTime(parachuteSkin.expireTS) then
      return
    end
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    if not logic_wardrobe:IsCanUse(parachuteSkin.resID) then
      return
    end
    self:ShowParachuteModelInfo(parachuteSkin.insID, parachuteSkin.resID)
  end
end
function WardrobeParachute:OnFashionBagEditParachuteUpdate(_, _, InsID)
  if not InsID or InsID == 0 then
    return
  end
  local parachuteSkin = WardrobeDataManager:GetHallDepotItemDataByInsID(InsID)
  if parachuteSkin then
    if not DataMgr.IsValidTime(parachuteSkin.expireTS) then
      return
    end
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    if not logic_wardrobe:IsCanUse(parachuteSkin.resID) then
      return
    end
    self:ShowParachuteModelInfo(parachuteSkin.insID, parachuteSkin.resID)
  end
end
function WardrobeParachute:OnReloginInFashionBagEditMode()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe:EnterGrenadeScene()
  self:InitParachuteSkin()
end
function WardrobeParachute:OnFashionBagEditJumpBack(_, __)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe:EnterGrenadeScene()
end
function WardrobeParachute:ReSortItem()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local itemList = self.LoopScrollGrid_Normal:GetSetData()
  local SortPreference = logic_wardrobe:GetSortPreference(self.subTabConfig)
  logic_wardrobe:SortItemTable(itemList, SortPreference, true)
  for i, v in pairs(itemList) do
    v.index = i - 1
  end
  self:UpdateItemListBySort(itemList)
end
function WardrobeParachute:OnDownloadFinish(_, __, eventData)
  log(bWriteLog and "WardrobeParachute:OnDownloadFinish")
  WardrobeParachute.__super.OnDownloadFinish(self, _, __, eventData)
  local itemID = eventData.itemID
  if not itemID or tonumber(itemID) <= 0 then
    return
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local CurParacurteInsID = fashionbag_data:GetParachute()
  local CurItemData = WardrobeDataManager:GetValidHallDepotItemDataByInsID(CurParacurteInsID)
  local CurItemID = CurItemData and CurItemData.resID
  log(bWriteLog and "WardrobeParachute:OnDownloadFinish CurItemID: " .. tostring(CurItemID) .. " itemID: " .. tostring(itemID))
  if CurItemID ~= itemID then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemID}) ~= PufferConst.ENUM_DownloadState.Done then
    return
  end
  WardrobeLogicManager:ShowParachuteModel(itemID)
end
local class = require("class")
local normal_item_list = require("client.slua.umg.Wardrobe.subtab_item_list_base")
local Parachute = class(normal_item_list, nil, WardrobeParachute)
return Parachute