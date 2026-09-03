local Collect_RLevel_Item_UIBP = {}
local Trait = require("common.trait")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local Traits = {
  require("GameLua.Mod.Lobby.Split.Collect.umg.Trait.TEncryption")
}
local CCollect_RLevel_Item_UIBP = Trait.TraitClass(ui_base, nil, Collect_RLevel_Item_UIBP, Traits)
local UIUtil = require("client.common.ui_util")
local local noDependence = 4
local status2Index = {
  [0] = 1,
  [1] = 2,
  [2] = 3,
  [3] = 0,
  [noDependence] = 1
}
function Collect_RLevel_Item_UIBP:ctor()
  self.tRewardWidgets = {
    "Collect_Road_Season_Item02_UIBP",
    "Collect_Road_Season_Item02_UIBP_0"
  }
  self.ItemDataList = {}
end
function Collect_RLevel_Item_UIBP:OnRefresh(_, _)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local root = self.UIRoot
  local level = self.data.Level
  root.UTRichTextBlock_1:SetText(tostring(level))
  local Collect_Road_UIBP = self:GetLoopScrollBoxParentUI()
  self.nTab = Collect_Road_UIBP.nTab
  if self.nTab == collect_module.collect_cfg.Sys2Index.Season and level == Collect_Road_UIBP.NListMaxLevel then
    root.UTRichTextBlock_1:SetText(collect_module.collect_cfg.SeasonMaxText)
  end
  local CollectLevelCfg = self.data
  local itemList = {}
  local widgets = self.tRewardWidgets
  self.ItemDataList = {}
  for i = 1, #widgets do
    local itemW = root[widgets[i]]
    local itemId = CollectLevelCfg["Drop" .. i]
    local num = CollectLevelCfg["Num" .. i]
    local time = CollectLevelCfg["Time" .. i]
    local price, priceType, PurchaseCond = 0
    if Collect_Road_UIBP.nTab == collect_module.collect_cfg.Sys2Index.Season then
      price = CollectLevelCfg["CostNum" .. i]
      priceType = CollectLevelCfg["Cost" .. i]
      PurchaseCond = CollectLevelCfg["PurchaseCond" .. i]
    end
    self.ItemDataList[i] = {
      itemId = itemId,
      num = num,
      time = time,
      price = price,
      priceType = priceType,
      PurchaseCond = PurchaseCond,
      status = 0
    }
    self:SetWidgetVisible(itemW, itemId ~= 0)
    if itemId ~= 0 then
      self:RefreshOneItem(itemW, itemId, num, time, price, priceType, i, PurchaseCond)
      itemList[#itemList + 1] = itemId
    end
  end
  self:ShowEncryptionTime(root, itemList)
  if self.UIRoot.WidgetSwitcher_BG then
    self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(0)
  end
end
function Collect_RLevel_Item_UIBP:RegistEvents()
  local widgets = self.tRewardWidgets
  for i = 1, #widgets do
    local itemW = self.UIRoot[widgets[i]]
    self:AddOnClickedEventByControl(itemW.Button_Click, self.OnClickButton_Enter, self, i)
  end
end
function Collect_RLevel_Item_UIBP:OnClickButton_Enter(i)
  self:PlayAudio(sound_config.click_v1)
  local itemData = self.ItemDataList[i]
  if not itemData then
    return
  end
  local itemID = itemData.itemId
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  if collect_encryption_module:IsEncryption(itemID) then
    collect_encryption_module:ShowEncryptionTips(itemID)
    return
  end
  self:ChooseOneItem(i)
end
function Collect_RLevel_Item_UIBP:ChooseOneItem(i)
  local Collect_Road_UIBP = self:GetLoopScrollBoxParentUI()
  local itemData = self.ItemDataList[i]
  if not itemData then
    return
  end
  Collect_Road_UIBP:OnChooseOneItem(self.data.Level, i, itemData)
end
function Collect_RLevel_Item_UIBP:RefreshOneItem(itemW, itemId, num, time, price, priceType, subIndex, PurchaseCond)
  local itemData = CDataTable.GetTableData("Item", itemId)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_award_module = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.collect_award_module)
  local status = collect_module:GetAwardStatus(self.nTab, self.data.Level, subIndex)
  local showPrice = price ~= 0
  if status ~= ActivityProgressStatus.Get then
    if PurchaseCond and not collect_module:HasDependence(PurchaseCond) then
      status = noDependence
    end
    if showPrice and status == ActivityProgressStatus.Done then
      status = ActivityProgressStatus.Done_Not
    end
  end
  if self.ItemDataList[subIndex] then
    self.ItemDataList[subIndex].  end
  itemW.WidgetSwitcher_0:SetActiveWidgetIndex(status2Index[status])
  self:SetWidgetVisible(itemW.Image_LimitTime, time ~= 0 or collect_award_module:IsLimitSubType(itemData.ItemSubType, itemId))
  self:SetWidgetVisible(itemW.ScaleBox_Price, showPrice)
  itemW.TextBlock_ToCollect:SetText(tostring(price))
  if showPrice then
    local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
    local coinPath = StoreUtils.SetCurrencyIcon(priceType)
    self:SetTexture(self.UIRoot.Image_12, coinPath)
  end
  local showNum = 1 < num
  if showNum then
    itemW.TextBlock_Count:SetText(tostring(num))
  end
  self:SetWidgetVisible(itemW.TextBlock_Count, showNum)
  local qualityPath = UIUtil.GetBgQualityPath(itemData and itemData.ItemQuality)
  self:SetTexture(itemW.Image_Quality, qualityPath)
  self:ShowTipsOrEncryption(itemW, itemId)
  self:SetWidgetVisible(itemW.ScaleBox_0, status == noDependence)
  local common_download_handler = require("client.slua.common.common_download_handler")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {itemId}, itemW.Panel_Download)
end
return CCollect_RLevel_Item_UIBP