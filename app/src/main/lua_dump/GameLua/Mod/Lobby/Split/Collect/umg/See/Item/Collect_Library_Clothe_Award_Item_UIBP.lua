local Collect_Library_Clothe_Award_Item_UIBP = {}
local Trait = require("common.trait")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local Traits = {
  require("GameLua.Mod.Lobby.Split.Collect.umg.Trait.TEncryption")
}
local CCollect_Library_Clothe_Award_Item_UIBP = Trait.TraitClass(ui_base, nil, Collect_Library_Clothe_Award_Item_UIBP, Traits)
local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
local local UIUtil = require("client.common.ui_util")
local status2Index = {
  [0] = 1,
  [1] = 2,
  [2] = 3,
  [3] = 0
}
local widgets = {"AwardItem1", "AwardItem2"}
function Collect_Library_Clothe_Award_Item_UIBP:OnRefresh(_, _)
  local root = self.UIRoot
  local Collect_Library_UIBP = self:GetLoopScrollBoxParentUI()
  self.nTab = Collect_Library_UIBP.nTab
  local itemList = {}
  local Cfg = self.data
  for i = 1, 2 do
    local itemW = root[widgets[i]]
    local itemId = Cfg["Drop" .. i]
    self["Drop" .. i] = itemId
    local num = Cfg["Num" .. i]
    self["Num" .. i] = num
    local time = Cfg["Time" .. i]
    self["Time" .. i] = time
    local price, priceType = 0
    self["CostNum" .. i] = price
    self["Cost" .. i] = priceType
    self["status" .. i] = ActivityProgressStatus.Not
    self:SetWidgetVisible(itemW, itemId ~= 0)
    if itemId ~= 0 then
      self:RefreshOneItem(itemW, itemId, num, time, price, priceType, i)
      itemList[#itemList + 1] = itemId
    end
  end
  root.TextBlock_Score:SetText(tostring(self.index))
  log_warning(bWriteLog and "  Collect_Library_Weapon_Item_UIBP:OnRefresh. self.index: " .. tostring(self.index))
  root.TextBlock_Score:SetText(LocUtil.LocalizeResFormat(77497, self.data.MinScore))
  if self.status1 == ActivityProgressStatus.Done or self.status2 == ActivityProgressStatus.Done then
    self.UIRoot.Switcher_LevelState:SetActiveWidgetIndex(1)
  else
    self.UIRoot.Switcher_LevelState:SetActiveWidgetIndex(0)
  end
  self:ShowEncryptionTime(root, itemList)
end
function Collect_Library_Clothe_Award_Item_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.AwardItem1.Button_Click, self.OnClickButton_Enter, self, 1)
  self:AddOnClickedEventByControl(self.UIRoot.AwardItem2.Button_Click, self.OnClickButton_Enter, self, 2)
end
function Collect_Library_Clothe_Award_Item_UIBP:OnClickButton_Enter(i)
  self:PlayAudio(sound_config.click_v1)
  local itemID = self["Drop" .. i]
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  if collect_encryption_module:IsEncryption(itemID) then
    collect_encryption_module:ShowEncryptionTips(itemID)
    return
  end
  local Collect_Library_Clothe_UIBP = self:GetLoopScrollBoxParentUI()
  local status, itemId, num, time, price, priceType = self["status" .. i], self["Drop" .. i], self["Num" .. i], self["Time" .. i], self["CostNum" .. i], self["Cost" .. i]
  Collect_Library_Clothe_UIBP:OnClickedAward(self.data.SeriesID, self.index, i, status, itemId, num, time, price, priceType)
end
function Collect_Library_Clothe_Award_Item_UIBP:RefreshOneItem(itemW, itemId, num, time, price, priceType, subIndex)
  local itemData = CDataTable.GetTableData("Item", itemId)
  if not itemData then
    return
  end
  local collect_clothe_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_clothe_module)
  local status = collect_clothe_module:GetClotheSeriesAwardStatus(self.data.SeriesID, self.index, subIndex)
  local showPrice = price ~= 0
  if showPrice and status == ActivityProgressStatus.Done then
    status = ActivityProgressStatus.Done_Not
  end
  if subIndex == 1 then
    self.status1 = status
  else
    self.status2 = status
  end
  log_warning(bWriteLog and "  Collect_Library_Weapon_Item_UIBP:RefreshOneItem. status: " .. tostring(status))
  itemW.WidgetSwitcher_0:SetActiveWidgetIndex(status2Index[status])
  self:SetWidgetVisible(itemW.Image_LimitTime, time ~= 0)
  self:SetWidgetVisible(itemW.ScaleBox_Price, showPrice)
  itemW.TextBlock_ToCollect:SetText(tostring(price))
  if showPrice then
    local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
    local coinPath = StoreUtils.SetCurrencyIcon(priceType)
    self:SetTexture(self.UIRoot.Image_12, coinPath)
  end
  itemW.TextBlock_Count:SetText(tostring(num))
  local qualityPath = UIUtil.GetBgQualityPath(itemData.ItemQuality)
  self:SetTexture(itemW.Image_Quality, qualityPath)
  self:ShowTipsOrEncryption(itemW, itemId)
  local common_download_handler = require("client.slua.common.common_download_handler")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {itemId}, itemW.Panel_Download)
end
return CCollect_Library_Clothe_Award_Item_UIBP