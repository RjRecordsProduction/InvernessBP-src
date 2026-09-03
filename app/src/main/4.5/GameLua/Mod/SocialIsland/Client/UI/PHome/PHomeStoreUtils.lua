local PHomeStoreUtils = {}
local UIUtil = require("client.common.ui_util")
local errLog = IsEditor and error or print
local TimeUtil = require("client.common.time_util")
local version_util = require("client.common.version_util")
local PHomeStoreConst = require("client.slua.logic.homestore.PHomeStoreConst")
local PriceIconStyleMap = {
  [1208] = "<img src=\"HomeCoin2\"/>",
  [1209] = "<img src=\"HomeCoin1\"/>",
  [1006] = "<img src=\"HomeUCcoin\"/>"
}
local PriceTextStyle = "%s"
local PriceNotEnoughTextStyle = "<Setting_Font08>%s</>"
function PHomeStoreUtils.MakeBuyRichText(coinType, price, bDiffEnough)
  local ThisCurrencyStyle = PriceIconStyleMap[coinType]
  local ThisCurrencyPriceTextStyle = price
  if bDiffEnough then
    local store_buy_utils = require("client.slua.umg.NewStoreV280.NewStoreMove.buy.store_buy_utils")
    local myMoney = store_buy_utils.GetMyMoneyByType(coinType)
    if price > myMoney then
      ThisCurrencyPriceTextStyle = PriceNotEnoughTextStyle
    else
      ThisCurrency    end
  end
  local priceTextStr = string.format(ThisCurrencyPriceTextStyle, tostring(price))
  local priceDesc = LocUtil.LocalizeResFormat("6428", ThisCurrencyStyle, priceTextStr)
  return priceDesc
end
function PHomeStoreUtils.SetHomeStoreItemData(uibase, widget, phomeStoreId, selected, count, explicitItemId)
  printf("PHomeStoreUtils.SetHomeStoreItemData phomeStoreId:%s, explicitItemId:%s", phomeStoreId, explicitItemId)
  local innerWidget = widget.PHomeStore_Fashion_Item_01_UIBP
  if selected then
    uibase:SetWidgetVisible(innerWidget.Common_selected_UIBP, true)
  else
    uibase:SetWidgetVisible(innerWidget.Common_selected_UIBP, false)
  end
  local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
  local phomeItemId = explicitItemId
  if nil == explicitItemId then
    if nil == phomeStoreId then
      log_error("PHomeStoreUtils.SetHomeStoreItemData both phomeStoreId and explicitItemId are nil")
      return
    end
    local storeCfg = PHomeStoreProxy:GetPHomeStoreCfg(phomeStoreId)
    if nil == storeCfg then
      printf("PHomeStoreUtils.SetHomeStoreItemData storeCfg is nil. storeId:%s", phomeStoreId)
      return
    end
    phomeItemId = storeCfg.PH_item_id
  end
  if nil == phomeItemId then
    log_error("PHomeStoreUtils.SetHomeStoreItemData phomeItemId is nil")
    return
  end
  local basicInfo = PHomeStoreProxy:GetPHomeItemCfg(phomeItemId)
  if nil == basicInfo then
    errLog("PHomeStoreUtils.SetHomeStoreItemData basicInfo is nil. phomeItemId:%s", phomeItemId)
    return
  end
  local UIUtil = require("client.common.ui_util")
  local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(phomeItemId, innerWidget.Item)
  uibase:SetTexture(innerWidget.Item, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  local QualityPath
  QualityPath = UIUtil.GetBgQualityPath(basicInfo.Quality)
  uibase:SetTexture(innerWidget.Image_quality, QualityPath)
  QualityPath = UIUtil.GetQualityPath(basicInfo.Quality)
  uibase:SetTexture(innerWidget.Label, QualityPath)
  if basicInfo.Style and basicInfo.Style ~= 0 then
    local StylePath = PHomeStoreUtils.GetBgStylePath(basicInfo.Style)
    uibase:SetTexture(innerWidget.Image_Style, StylePath)
    uibase:SetWidgetVisible(innerWidget.CanvasPanel_Style, true)
  else
    uibase:SetWidgetVisible(innerWidget.CanvasPanel_Style, false)
  end
  if count then
    uibase:SetWidgetVisible(innerWidget.Count, true)
    innerWidget.Count:SetText(count)
  else
    uibase:SetWidgetVisible(innerWidget.Count, false)
  end
end
function PHomeStoreUtils.SetStoreBuyItemData(uibase, widget, phomeStoreCfg, storeId, storeType)
  local innerWidget = widget
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
  local phomeItemId = phomeStoreCfg.PH_item_id
  local itemCfg = CDataTable.GetTableData("Item", phomeItemId)
  if storeType == PHomeStoreConst.StoreType.Set then
    local setCfg = PHomeStoreProxy:getPHomeStoreSetCfg(storeId)
    uibase:SetTexture(innerWidget.Image_Icon, setCfg.set_items_icon)
    local QualityPath = UIUtil.GetBgQualityPath(setCfg.set_items_quality or 5)
    uibase:SetTexture(innerWidget.Image_Quality, QualityPath)
  elseif storeType == PHomeStoreConst.StoreType.Store then
    local iconPath, bHasAddKnownMissing = UIUtil.GetItemBigIcon(phomeItemId, innerWidget.Item)
    uibase:SetTexture(innerWidget.Image_Icon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
    local QualityPath = UIUtil.GetBgQualityPath(itemCfg.ItemQuality)
    uibase:SetTexture(innerWidget.Image_Quality, QualityPath)
  elseif storeType == PHomeStoreConst.StoreType.Mould then
    local itemId = PHomeStoreUtils.GetMouldDisplayItemId(storeId)
    local uObj_itemCfg = CDataTable.GetTableData("Item", itemId)
    local iconPath, bHasAddKnownMissing = UIUtil.GetItemBigIcon(itemId, innerWidget.Item)
    uibase:SetTexture(innerWidget.Image_Icon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
    local QualityPath = UIUtil.GetBgQualityPath(uObj_itemCfg.ItemQuality)
    uibase:SetTexture(innerWidget.Image_Quality, QualityPath)
  end
  local nItemNum = phomeStoreCfg.item_count
  if nItemNum and 1 < nItemNum then
    innerWidget.Text_Num:SetText(nItemNum)
    uibase:SetWidgetVisible(innerWidget.Text_Num, true)
  else
    uibase:SetWidgetVisible(innerWidget.Text_Num, false)
  end
end
function PHomeStoreUtils.SetStoreBuyItemCfg(uibase, widget, nItemId, nItemNum)
  local innerWidget = widget
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
  local iconPath, bHasAddKnownMissing = UIUtil.GetItemBigIcon(uObj_itemCfg.ItemID, innerWidget.Icon)
  uibase:SetTexture(innerWidget.Image_Icon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  local QualityPath = UIUtil.GetBgQualityPath(uObj_itemCfg.ItemQuality)
  uibase:SetTexture(innerWidget.Image_Quality, QualityPath)
  if nItemNum and 1 < nItemNum then
    innerWidget.Text_Num:SetText(nItemNum)
    uibase:SetWidgetVisible(innerWidget.Text_Num, true)
  else
    uibase:SetWidgetVisible(innerWidget.Text_Num, false)
  end
end
function PHomeStoreUtils.SetStoreProductItemData(uibase, widget, phomeStoreCfg, basicInfo, haveCount, bSelected, storeId)
  local itemId = phomeStoreCfg.PH_item_id
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if nil == itemCfg then
    errLog(string.format("PHomeStoreUtils.SetStoreProductItemData itemCfg is nil. itemId:%s", itemId))
    return
  end
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local bShowNew = LogicPHomeStore:IsStoreHasNewMark(phomeStoreCfg, clientVersion)
  if widget.CanvasPanel_New then
    uibase:SetWidgetVisible(widget.CanvasPanel_New, bShowNew)
  end
  if phomeStoreCfg then
    uibase:SetWidgetVisible(widget.Membership, true)
    local hasRate, coinType, price, afterPrice = PHomeStoreUtils.GetOffRatePrice(phomeStoreCfg)
    local StoreUtils = require("client.slua.logic.store.utils.store_utils")
    uibase:SetTexture(widget.PriceType, StoreUtils.GetPriceIconByCurrency(coinType))
    if PHomeStoreUtils.HasRateExpires(uibase, widget, phomeStoreCfg, bShowNew) then
      hasRate = false
      afterPrice = price
    end
    uibase:SetWidgetVisible(widget.CanvasPanel_14, hasRate)
    if hasRate then
      widget.TextBlock_OriginMoney:SetText(price)
    end
    widget.TextBlock_Price:SetText(afterPrice)
  else
    uibase:SetWidgetVisible(widget.Membership, false)
  end
  local UIUtil = require("client.common.ui_util")
  local iconPath, bHasAddKnownMissing = UIUtil.GetItemBigIcon(itemCfg.ItemID, widget.Icon)
  uibase:SetTexture(widget.Icon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  if not (not bHasAddKnownMissing and iconPath) or iconPath == "" then
    printf("[PHomeStore-Diag] SetStoreProductItemData icon missing storeId:%s itemId:%s iconPath:%s bigIcon:%s knownMissing:%s", tostring(storeId), tostring(itemCfg.ItemID), tostring(iconPath), tostring(itemCfg.ItemBigIcon), tostring(bHasAddKnownMissing))
  end
  local UIUtil = require("client.common.ui_util")
  local qualityPath = UIUtil.GetBgQualityPath(itemCfg.ItemQuality)
  uibase:SetTexture(widget.Image_quality, qualityPath)
  if basicInfo and basicInfo.Style and basicInfo.Style ~= 0 then
    local styleIcon = CDataTable.GetTableData("PlanPH_StructureStyleCfg", basicInfo.Style).IconPath3
    uibase:SetTexture(widget.Image_Style, styleIcon)
    uibase:SetWidgetVisible(widget.CanvasPanel_Style, true)
  else
    uibase:SetWidgetVisible(widget.CanvasPanel_Style, false)
  end
  if bSelected and 0 < haveCount then
    uibase:SetWidgetVisible(widget.CanvasPanel_Quantity, true)
    widget.Count:SetText(LocUtil.LocalizeResFormat(6994, haveCount))
  else
    uibase:SetWidgetVisible(widget.CanvasPanel_Quantity, false)
  end
  if phomeStoreCfg.item_count > 1 then
    uibase:SetWidgetVisible(widget.TextBlock_Number_0, true)
    widget.TextBlock_Number_0:SetText(phomeStoreCfg.item_count)
  else
    uibase:SetWidgetVisible(widget.TextBlock_Number_0, false)
  end
  local manor_draw_id = phomeStoreCfg.manor_draw_id
  if manor_draw_id and 0 < manor_draw_id then
    printf("PHomeStoreUtils.SetStoreProductItemData storeId:%s manor_draw_id:%s", storeId, manor_draw_id)
    uibase:SetWidgetVisible(widget.CanvasPanel_5, true)
    widget.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    uibase:SetWidgetVisible(widget.CanvasPanel_5, false)
    widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
  if widget.Image_PDP then
    uibase:SetWidgetVisible(widget.Image_PDP, false)
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    local data_config_marco = require("client.logic.data.data_config_marco")
    BasicDataServerTable:GetOrReqData(data_config_marco.manor_shop_pdp_info_table, function(key, pdp_info_table)
      if not slua.isValid(uibase.UIRoot) then
        return
      end
      local pdp_info = pdp_info_table[storeId]
      if pdp_info then
        uibase:SetWidgetVisible(widget.Image_PDP, true)
      end
    end)
  end
end
function PHomeStoreUtils.SetStoreProductItemDataNoPrice(uibase, widget, itemId, haveCount, bSelected, num2, isProbabilityIncreasing, isExclusiveDisplayed)
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if nil == itemCfg then
    errLog(string.format("PHomeStoreUtils.SetStoreProductItemDataNoPrice itemCfg is nil. itemId:%s", itemId))
    return
  end
  local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
  local basicInfo = PHomeStoreProxy:GetPHomeItemCfg(itemId)
  local UIUtil = require("client.common.ui_util")
  local iconPath, bHasAddKnownMissing = UIUtil.GetItemBigIcon(itemId, widget.Icon)
  uibase:SetTexture(widget.Icon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  local UIUtil = require("client.common.ui_util")
  local qualityPath = UIUtil.GetBgQualityPath(itemCfg.ItemQuality)
  uibase:SetTexture(widget.Image_quality, qualityPath)
  if basicInfo then
    uibase:SetWidgetVisible(widget.Membership, false)
    if basicInfo.Style and basicInfo.Style ~= 0 then
      uibase:SetWidgetVisible(widget.CanvasPanel_Style, true)
      local styleIcon = CDataTable.GetTableData("PlanPH_StructureStyleCfg", basicInfo.Style).IconPath3
      uibase:SetTexture(widget.Image_Style, styleIcon)
    else
      uibase:SetWidgetVisible(widget.CanvasPanel_Style, false)
    end
    if bSelected and 0 < haveCount then
      uibase:SetWidgetVisible(widget.CanvasPanel_Quantity, true)
      widget.Count:SetText(LocUtil.LocalizeResFormat(6994, haveCount))
    else
      uibase:SetWidgetVisible(widget.CanvasPanel_Quantity, false)
    end
  elseif itemCfg then
    uibase:SetWidgetVisible(widget.Membership, false)
    uibase:SetWidgetVisible(widget.CanvasPanel_Style, false)
    uibase:SetWidgetVisible(widget.CanvasPanel_Quantity, false)
  else
    local dft = "/Game/Arts/DefaultBrush/DefaultBrush_64_64.DefaultBrush_64_64"
    uibase:SetTexture(widget.Icon, dft)
    print(bWriteLog and string.format(" PHomeStoreUtils.SetStoreProductItemDataNoPrice basicInfo and itemCfg is nil itemId:%s", itemId))
  end
  if num2 and 1 < num2 then
    uibase:SetWidgetVisible(widget.TextBlock_Number_0, true)
    widget.TextBlock_Number_0:SetText(num2)
  else
    uibase:SetWidgetVisible(widget.TextBlock_Number_0, false)
  end
  uibase:SetWidgetVisible(widget.CanvasPanel_New, false)
  uibase:SetWidgetVisible(widget.CanvasPanel_5, false)
  widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  local logic_home_exchange_dealer = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_exchange_dealer)
  if logic_home_exchange_dealer:GetIsActivityData() then
    uibase:SetWidgetVisible(widget.Image_Up, false)
    uibase:SetWidgetVisible(widget.Image_TH, false)
    if isExclusiveDisplayed == 1 then
      uibase:SetWidgetVisible(widget.Image_TH, true)
    elseif isProbabilityIncreasing == 1 then
      uibase:SetWidgetVisible(widget.Image_Up, true)
    else
      uibase:SetWidgetVisible(widget.Image_Up, false)
    end
  else
    uibase:SetWidgetVisible(widget.Image_Up, false)
    uibase:SetWidgetVisible(widget.Image_TH, false)
  end
end
function PHomeStoreUtils.GetBgStylePath(Style)
  local styleIcon = CDataTable.GetTableData("PlanPH_StructureStyleCfg", Style).IconPath3
  return styleIcon
end
function PHomeStoreUtils.ClearModel()
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_ON_REQ_UPDATE_MODEL, nil)
end
function PHomeStoreUtils.UpdateModel(pHomeItemId, explicitTestBPPath)
  if pHomeItemId == nil or pHomeItemId == 0 then
    PHomeStoreUtils.ClearModel()
    return
  end
  local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
  local basicInfo = PHomeStoreProxy:GetPHomeItemCfg(pHomeItemId)
  if not basicInfo then
    print(bWriteLog and string.format(" PHomeStoreUtils:UpdateModel basicInfo is nil phomeItemId:%s", pHomeItemId))
    printf("[PHomeStore-Diag] UpdateModel basicInfo nil phomeItemId:%s", tostring(pHomeItemId))
    return
  end
  local BPPath = explicitTestBPPath or basicInfo.BPPath
  if BPPath and BPPath ~= "" then
    printf("[PHomeStore-Diag] UpdateModel postEvent BP phomeItemId:%s BPPath:%s", tostring(pHomeItemId), tostring(BPPath))
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_ON_REQ_UPDATE_MODEL, {
      id = pHomeItemId,
      bppath = BPPath,
      AttachType = basicInfo.AttachType,
      SubType = basicInfo.SubType,
      StoreZOffset = basicInfo.StoreZOffset,
      StoreScale = basicInfo.StoreScale
    })
    return
  end
  local MatPath = basicInfo.MatPath
  if MatPath and MatPath ~= "" then
    printf("[PHomeStore-Diag] UpdateModel postEvent Mat phomeItemId:%s MatPath:%s", tostring(pHomeItemId), tostring(MatPath))
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_ON_REQ_UPDATE_MODEL, {id = pHomeItemId, MatPath = MatPath})
    return
  end
  printf("[PHomeStore-Diag] UpdateModel both BPPath and MatPath empty phomeItemId:%s", tostring(pHomeItemId))
end
function PHomeStoreUtils.ShowCommonItemGet(items, onceMoreFunc, onceMoreText)
  if nil == items then
    printf("PHomeStoreUtils.ShowCommonItemGet items is nil")
    return
  end
  printf("PHomeStoreUtils.ShowCommonItemGet onceMoreText:%s", onceMoreText)
  local allData = {}
  for k, v in pairs(items) do
    local data = {
      res_id = v.item_id,
      count = v.item_num,
      valid_hours = 0,
      expire_time = 0
    }
    table.insert(allData, data)
  end
  local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if onceMoreFunc then
    local tShowConfig = {
      tAllBtnShowData = CommonItemGet_BtnCfgUtils.CreateTwoGeneralBtnData(onceMoreText, onceMoreFunc)
    }
    Logic_CommonItemGet.ShowPanel_FullCustom(allData, tShowConfig)
  else
    Logic_CommonItemGet.ShowPanel_DefaultStyle(allData)
  end
end
function PHomeStoreUtils.ShowAnniversaryChestItemGet(items, onceMoreFunc, onceMoreText)
  printf("PHomeStoreUtils.ShowAnniversaryChestItemGet onceMoreText:%s", onceMoreText)
  local allData = {}
  for k, v in pairs(items) do
    local data = {
      res_id = v.item_id,
      count = v.item_num,
      valid_hours = 0,
      expire_time = 0
    }
    table.insert(allData, data)
  end
  local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if onceMoreFunc then
    local tShowConfig = {
      tAllBtnShowData = CommonItemGet_BtnCfgUtils.CreateTwoGeneralBtnData(onceMoreText, onceMoreFunc),
      tHomeStoreBoxTopProgressData = true
    }
    Logic_CommonItemGet.ShowPanel_FullCustom(allData, tShowConfig)
  else
    Logic_CommonItemGet.ShowPanel_FullCustom(allData, {tHomeStoreBoxTopProgressData = true})
  end
end
function PHomeStoreUtils.ShowCommonItemGetKV(items)
  local allData = {}
  local partyItemId, housekeeperItemId
  local HomePartyConst = require("client.slua.logic.homeparty.HomePartyConst")
  for k, v in pairs(items) do
    local data = {
      res_id = k,
      count = v,
      valid_hours = 0,
      expire_time = 0
    }
    table.insert(allData, data)
    local cfg = CDataTable.GetTableData("PlanPH_Housekeeper_cfg", k)
    if k == HomePartyConst.PartyTypeItemId.Normal or k == HomePartyConst.PartyTypeItemId.Advanced then
      partyItemId = k
    elseif cfg and cfg.AISwitchHome == 1 then
      housekeeperItemId = k
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if partyItemId then
    local LogicHomeParty = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicHomeParty)
    LogicHomeParty.freeTimesDirty = true
    printf("PHomeStoreUtils.ShowCommonItemGetKV has partyItemId. set freeTimesDirty")
    local PHomeStoreConst = require("client.slua.logic.homestore.PHomeStoreConst")
    local nGuideModuleId = DataMgr.NEWBIE_GUIDE_MODULE_ID_SOCIAL_ISLAND
    local nGuideStep = PHomeStoreConst.NEWBIE_ID_PARTY_ITEMGET_GUIDE
    local sBtnStr = LocUtil.GetLocalizeResStr(75036)
    local fBtnCallBack = function()
      DataMgr.SetNewbieGuide(nGuideModuleId, nGuideStep)
      local PlanPHThemeSetHandler = require("client.network.Protocol.PlanPHThemeSetHandler")
      local HomePartyProxy = require("client.slua.logic.homeparty.HomePartyProxy")
      local bHasPutdown = HomePartyProxy:IsHasPutdownPartyItem()
      if bHasPutdown then
        local content = LocUtil.GetLocalizeResStr(75038)
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        IngameTipsTools.ShowMsgBox(2, LocUtil.GetLocalizeResStr(101001), content, function()
          PlanPHThemeSetHandler.send_manor_ambient_module_set_req(HomePartyConst.PartySlotId, partyItemId)
          EventSystem:postEvent(EVENTTYPE_COMMON_ITEM_GET, EVENTID_CHECK_NEXT_SHOW)
        end)
      else
        PlanPHThemeSetHandler.send_manor_ambient_module_set_req(HomePartyConst.PartySlotId, partyItemId)
        EventSystem:postEvent(EVENTTYPE_COMMON_ITEM_GET, EVENTID_CHECK_NEXT_SHOW)
      end
    end
    local isNewbie = DataMgr.HaveNewbieGuide(nGuideModuleId, nGuideStep)
    if isNewbie then
      local sGuideTip = LocUtil.GetLocalizeResStr(75061)
      local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(allData, false, false, {
        tAllBtnShowData = {
          CommonItemGet_BtnCfgUtils.GetConfirmBtnData(),
          CommonItemGet_BtnCfgUtils.CustomGuideTipBtnData(sBtnStr, sGuideTip, fBtnCallBack, nGuideModuleId, nGuideStep)
        }
      })
    else
      Logic_CommonItemGet.ShowPanel_TwoBtnStyle(allData, sBtnStr, fBtnCallBack)
    end
  elseif housekeeperItemId then
    local logic_housekeeper_AI = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_AI)
    logic_housekeeper_AI:SetGetAIHousekeeper(housekeeperItemId)
    Logic_CommonItemGet.ShowPanel_DefaultStyle(allData, false, false)
  else
    local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
    local isHighQuality = false
    for k, v in pairs(allData) do
      local itemCfg = CDataTable.GetTableData("Item", v.res_id)
      if itemCfg and itemCfg.ItemQuality >= 6 then
        isHighQuality = true
        break
      end
    end
    local bIsInFightingStatus = GameStatus.GetGameStatus() == GameStatus.Fighting
    if not PlanPH_GamePlay_Tools.IsPHomeMode(bIsInFightingStatus) and isHighQuality then
      local PHomeStoreTimeRecordUtils = require("GameLua.Mod.SocialIsland.Client.UI.PHome.PHomeStoreTimeRecordUtils")
      if PHomeStoreTimeRecordUtils.CheckGetHighQualityItemGuideVersion() then
        local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
        local CommonItemGet_Const = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Const")
        local Enum_BtnStyle = CommonItemGet_Const.Enum_BtnStyle
        local tExtraData = {
          tAllBtnShowData = {
            CommonItemGet_BtnCfgUtils.GetConfirmBtnData(),
            CommonItemGet_BtnCfgUtils.CustomGuideTipBtnData(LocUtil.GetLocalizeResStr(67272), LocUtil.GetLocalizeResStr(75217), function()
              local gotoFunc = function()
                local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
                logic_home_entry:EntryVisitHome(DataMgr.roleData.uid)
                EventSystem:postEvent(EVENTTYPE_COMMON_ITEM_GET, EVENTID_CHECK_NEXT_SHOW)
              end
              local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
              logic_home_download.CheckHomeDownloadedDone(DataMgr.roleData.uid, gotoFunc)
            end)
          }
        }
        Logic_CommonItemGet.ShowPanel_FullCustom(allData, tExtraData)
      else
        Logic_CommonItemGet.ShowPanel_TwoBtnStyle(allData, LocUtil.GetLocalizeResStr(67272), function()
          local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
          logic_home_download.CheckHomeDownloadedDone(DataMgr.roleData.uid, nil)
        end)
      end
    else
      Logic_CommonItemGet.ShowPanel_DefaultStyle(allData, false, false)
    end
  end
end
function PHomeStoreUtils.GetBuyLimitInfo(phomeStoreCfg)
  if phomeStoreCfg == nil then
    printf("PHomeStoreUtils.GetBuyLimitInfo phomeStoreCfg is nil")
    return 0, 0
  end
  if 0 < phomeStoreCfg.permanet_buy_limit then
    return 3, phomeStoreCfg.permanet_buy_limit
  elseif 0 < phomeStoreCfg.week_buy_limit then
    return 2, phomeStoreCfg.week_buy_limit
  elseif 0 < phomeStoreCfg.daily_buy_limit then
    return 1, phomeStoreCfg.daily_buy_limit
  else
    return 0, 0
  end
end
function PHomeStoreUtils.GetIsCanBuy(phomeStoreCfg, storeId, depotCountMapCache)
  local limitType, limitNum = PHomeStoreUtils.GetBuyLimitInfo(phomeStoreCfg)
  if limitType == 3 then
    local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
    local depotCount
    if depotCountMapCache then
      depotCount = depotCountMapCache[phomeStoreCfg.PH_item_id] or 0
    else
      depotCount = PHomeStoreProxy:GetDepotItemCount(phomeStoreCfg.PH_item_id)
    end
    printf(bWriteLog and "PHomeStoreUtils.GetIsCanBuy depotCount:%s limitNum:%s canBuy:%s", depotCount, limitNum, limitNum > depotCount)
    if limitNum <= depotCount then
      return false
    end
    local hasBuyNum = PHomeStoreProxy:GetHasBuyStoreCount(storeId)
    printf(bWriteLog and "PHomeStoreUtils.GetIsCanBuy hasBuyNum:%s limitNum:%s canBuy:%s", hasBuyNum, limitNum, limitNum > hasBuyNum)
    if limitNum <= hasBuyNum then
      return false
    end
  end
  return true
end
function PHomeStoreUtils.GetOffRatePrice(phomeStoreCfg)
  local coinType = phomeStoreCfg.money1_type
  local price = phomeStoreCfg.money1_price
  if coinType == 0 then
    coinType = phomeStoreCfg.money2_type
    price = phomeStoreCfg.money2_price
  end
  local afterPrice = price
  local hasRate = false
  local off_rate = phomeStoreCfg.off_rate or 0
  if 0 < off_rate and off_rate < 100 then
    hasRate = true
    afterPrice = price * (100 - off_rate) / 100
    afterPrice = math.ceil(afterPrice)
  end
  return hasRate, coinType, price, afterPrice
end
function PHomeStoreUtils.HasRateExpires(uibase, widget, phomeStoreCfg, bShowNew)
  if not uibase.RateExpiresClock then
    uibase.RateExpiresClock = {}
  end
  if uibase.RateExpiresClock[tostring(widget)] then
    uibase:RemoveClock(uibase.RateExpiresClock[tostring(widget)])
    uibase.RateExpiresClock[tostring(widget)] = nil
  end
  if not widget.CanvasPanel_Discount then
    log(bWriteLog and "PHomeStoreUtils:HasRateExpires phomeStoreCfg no CanvasPanel_Discount")
    return
  end
  uibase:SetWidgetVisible(widget.CanvasPanel_Discount, false)
  local off_rate_hours = tonumber(phomeStoreCfg.off_rate_hours)
  log_tree("PHomeStoreUtils:HasRateExpires phomeStoreCfg", phomeStoreCfg)
  if not off_rate_hours or off_rate_hours == 0 then
    log(bWriteLog and "PHomeStoreUtils:HasRateExpires no off_rate_hours " .. tostring(off_rate_hours))
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local beginTime = TimeUtil.TimeStringToUnixstamp(phomeStoreCfg.sale_begin_time)
  if not beginTime or beginTime == 0 then
    log(bWriteLog and "PHomeStoreUtils:HasRateExpires no beginTime " .. tostring(beginTime))
    return false
  end
  local coinType = phomeStoreCfg.money1_type
  local price = phomeStoreCfg.money1_price
  if coinType == 0 then
    coinType = phomeStoreCfg.money2_type
    price = phomeStoreCfg.money2_price
  end
  local off_rate = phomeStoreCfg.off_rate
  if 0 < off_rate and off_rate < 100 then
    off_rate = "-" .. tostring(off_rate) .. "%"
  else
    log(bWriteLog and "PHomeStoreUtils:HasRateExpires off_rate is error " .. tostring(off_rate))
    return false
  end
  local endTime = off_rate_hours * 3600 + beginTime
  local now = TimeUtil.GetServerTimeInSec()
  local leftTime = endTime - now
  if leftTime <= 0 then
    log(bWriteLog and "PHomeStoreUtils:HasRateExpires has end")
    return true
  end
  local afterPrice = price
  local itemId = phomeStoreCfg.PH_item_id
  local EndFunc = function()
    log(bWriteLog and "PHomeStoreUtils:HasRateExpires EndFunc id " .. tostring(itemId))
    if not slua.isValid(widget) then
      log(bWriteLog and "PHomeStoreUtils:HasRateExpires EndFunc id return " .. tostring(itemId))
      return
    end
    uibase:SetWidgetVisible(widget.CanvasPanel_Discount, false)
    uibase:SetWidgetVisible(widget.CanvasPanel_14, false)
    widget.TextBlock_Price:SetText(afterPrice)
  end
  log(bWriteLog and "PHomeStoreUtils:HasRateExpires bShowNew " .. tostring(bShowNew))
  if bShowNew then
    uibase:SetWidgetVisible(widget.CanvasPanel_Discount, false, false)
  else
    uibase:SetWidgetVisible(widget.CanvasPanel_Discount, true, false)
  end
  widget.TextBlock_Discount:SetText(off_rate)
  uibase.RateExpiresClock[tostring(widget)] = uibase:AddClock(endTime, nil, EndFunc)
end
function PHomeStoreUtils.CheckRateExpires(phomeStoreCfg)
  local NoRateExpiresReason = {
    NoOffRateHours = -1,
    NoBeginTime = -2,
    HasEnd = -3
  }
  local off_rate_hours = tonumber(phomeStoreCfg.off_rate_hours)
  log_tree("PHomeStoreUtils:CheckRateExpires phomeStoreCfg", phomeStoreCfg)
  if not off_rate_hours or off_rate_hours == 0 then
    log(bWriteLog and "PHomeStoreUtils:CheckRateExpires no off_rate_hours " .. tostring(off_rate_hours))
    return false, NoRateExpiresReason.NoOffRateHours
  end
  local TimeUtil = require("client.common.time_util")
  local beginTime = TimeUtil.TimeStringToUnixstamp(phomeStoreCfg.sale_begin_time)
  if not beginTime or beginTime == 0 then
    log(bWriteLog and "PHomeStoreUtils:CheckRateExpires no beginTime " .. tostring(beginTime))
    return false, NoRateExpiresReason.NoBeginTime
  end
  local endTime = off_rate_hours * 3600 + beginTime
  local now = TimeUtil.GetServerTimeInSec()
  local leftTime = endTime - now
  if leftTime <= 0 then
    log(bWriteLog and "PHomeStoreUtils:CheckRateExpires has end")
    return true, NoRateExpiresReason.HasEnd
  else
    log(bWriteLog and "PHomeStoreUtils:CheckRateExpires is in time endTime: " .. tostring(endTime))
    return false, endTime
  end
end
function PHomeStoreUtils.CheckIsValidStoreCfg(storeCfg, itop_app_id)
  if false == PHomeStoreUtils.CheckVersionPassed(storeCfg.open_ver, storeCfg.close_ver, storeCfg.sale_begin_time, storeCfg.sale_end_time) then
    printf("PHomeStoreUtils.CheckIsValidStoreCfg failed by version")
    return false
  end
  if false == PHomeStoreUtils.CheckAppIdList(storeCfg.app_list, itop_app_id) then
    printf("PHomeStoreUtils.CheckIsValidStoreCfg failed by app_list")
    return false
  end
end
function PHomeStoreUtils.CheckIsCurrentVersion(version, clientVersion)
  local result = version_util.CompareVersionMain(clientVersion, version) == 0
  return result
end
function PHomeStoreUtils.CheckAppIdList(sAppList, itop_app_id)
  if sAppList == nil or sAppList == "" or sAppList == "0" then
    return true
  end
  if not string.find(sAppList, itop_app_id) then
    return false
  end
  return true
end
function PHomeStoreUtils.CheckVersionPassed_LoopOptimize(openVer, closeVer, beginSaleTime, endSaleTime, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable)
  local versionMatch = 0 <= FnCmpVersion(clientVersion, openVer)
  if not versionMatch then
    return false
  end
  if closeVer and closeVer ~= "" then
    versionMatch = FnCmpVersion(clientVersion, closeVer) < 0
    if not versionMatch then
      return false
    end
  end
  if beginSaleTime and beginSaleTime ~= "" then
    local beginSaleTimeInSec = FnCmpTime(beginSaleTime, timeZone, refTimeTable)
    if now < beginSaleTimeInSec then
      return false
    end
  end
  if endSaleTime and endSaleTime ~= "" then
    local endSaleTimeInSec = FnCmpTime(endSaleTime, timeZone, refTimeTable)
    if now > endSaleTimeInSec then
      return false
    end
  end
  return true
end
function PHomeStoreUtils.CheckVersionPassed(openVer, closeVer, beginSaleTime, endSaleTime)
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local versionMatch = version_util.CompareVersionStandard(clientVersion, openVer) >= 0
  if not versionMatch then
    return false
  end
  if closeVer and closeVer ~= "" then
    versionMatch = version_util.CompareVersionStandard(clientVersion, closeVer) < 0
    if not versionMatch then
      return false
    end
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if beginSaleTime and beginSaleTime ~= "" then
    local beginSaleTimeInSec = TimeUtil.TimeStringToUnixstamp(beginSaleTime)
    if now < beginSaleTimeInSec then
      return false
    end
  end
  if endSaleTime and endSaleTime ~= "" then
    local endSaleTimeInSec = TimeUtil.TimeStringToUnixstamp(endSaleTime)
    if now > endSaleTimeInSec then
      return false
    end
  end
  return true
end
function PHomeStoreUtils.GetMouldDisplayItemId(storeId)
  local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
  local setCfg = PHomeStoreProxy:getPHomeStoreSetCfg(storeId)
  local items = setCfg.set_items_list
  local StringUtil = require("common.string_util")
  local mouldStoreId = StringUtil.Split(setCfg.set_items_list, "|")[1]
  local mouldStoreCfg = PHomeStoreProxy:GetPHomeStoreCfg(mouldStoreId)
  local itemId = tonumber(mouldStoreCfg.PH_item_id)
  return itemId
end
function PHomeStoreUtils.IsStructureOrDecoration(itemId)
  local cfg_PlanPH_StructureItemCfg = CDataTable.GetTableData("PlanPH_StructureItemCfg", itemId)
  if cfg_PlanPH_StructureItemCfg then
    return true
  end
  local cfg_PlanPH_DecorateItemCfg = CDataTable.GetTableData("PlanPH_DecorateItemCfg", itemId)
  if cfg_PlanPH_DecorateItemCfg then
    return true
  end
  return false
end
function PHomeStoreUtils.GetBuyItemShowNameAndDesc(nStoreType, nStoreId, tPHomeStoreCfg)
  if nStoreType == PHomeStoreConst.StoreType.Set then
    local key = tPHomeStoreCfg.items_name
    local numberKey = tonumber(key)
    local finalKey
    if numberKey then
      finalKey = LocUtil.GetLocalizeResStr(numberKey)
    else
      local IntlHelper = import("IntlHelper")
      finalKey = IntlHelper.GetLocalizationString(key)
    end
    return finalKey, LocUtil.LocalizeResFormat(tPHomeStoreCfg.item_des)
  elseif nStoreType == PHomeStoreConst.StoreType.Store then
    local itemCfg = CDataTable.GetTableData("Item", tPHomeStoreCfg.PH_item_id)
    return itemCfg.ItemName, itemCfg.ItemDesc
  elseif nStoreType == PHomeStoreConst.StoreType.Mould then
    local itemId = PHomeStoreUtils.GetMouldDisplayItemId(nStoreId)
    local itemCfg = CDataTable.GetTableData("Item", itemId)
    return itemCfg.ItemName, itemCfg.ItemDesc
  end
  return "", ""
end
return PHomeStoreUtils