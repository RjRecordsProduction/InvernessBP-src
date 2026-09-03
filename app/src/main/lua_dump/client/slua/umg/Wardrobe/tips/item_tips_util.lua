local ItemTipsUtil = {}
local ShopSystem = require("client.logic.shop.logic_shop")
local ESlateVisibility = UEnums.ESlateVisibility
local Visible = ESlateVisibility.Visible
local Collapsed = ESlateVisibility.Collapsed
local HitTestInvisible = ESlateVisibility.HitTestInvisible
local wardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
function ItemTipsUtil:IsUrl(str)
  local StringUtil = require("common.string_util")
  return StringUtil.Starts(str, "http") or StringUtil.Starts(str, "game://")
end
function ItemTipsUtil:IsIsolatedItem(itemResId)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  return WardrobeLogicManager:IsItemIsolated(itemResId or 0)
end
function ItemTipsUtil:IsSmallRPCard(nItemId)
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  return nItemId == Logic_SmallRP:GetSmallRPCardId()
end
function ItemTipsUtil:CanComposeItem(itemResId)
  if self:IsIsolatedItem(itemResId) then
    return false
  end
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion ~= PublishRegionMacros.JAPAN and strRegion ~= PublishRegionMacros.KOREA and (itemResId == 1532021 or itemResId == 1532022 or itemResId == 1532025) then
    return false
  end
  return CDataTable.GetTableData("ItemCompose", itemResId) ~= nil
end
function ItemTipsUtil:IsUpassUpgradeType(itemSubType)
  return itemSubType == ENUM_ITEM_SUBTYPE.Upass_Upgrade
end
function ItemTipsUtil:IsBonusPassUpgradeType(itemSubType)
  return itemSubType == ENUM_ITEM_SUBTYPE.BonusPass_Upgrade
end
function ItemTipsUtil:IsShopItemType(itemType, itemSubType)
  if itemType == 16 and (itemSubType == 1602 or itemSubType == 1609) then
    return true
  end
  return false
end
function ItemTipsUtil:CanUseItem(itemResId, itemType, expireTS, itemSubType, jumpExchangeUrl)
  local TimeUtil = require("client.common.time_util")
  if expireTS ~= 0 and expireTS <= TimeUtil.GetServerTimeInSec() then
    return false
  end
  local fItemIdCheckCanUse = self["CheckIsCanUse_" .. itemResId]
  if fItemIdCheckCanUse then
    return fItemIdCheckCanUse()
  end
  if self:CanComposeItem(itemResId) then
    return false
  end
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if LogicParticleEmote:IsUnLockProp(itemResId) then
    return true
  end
  if itemSubType == ENUM_ITEM_SUBTYPE.MixItemEEProduct then
    return true
  end
  local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if wardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE == itemResId or wardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE_SEASON == itemResId or LogicAddScordCard:IsPutOnSeasonAddScoreCard(itemResId) or wardrobeMacro.ENUM_WardrobePropResId.VS_TEAM_RATING_PROTECT_TIMES_CARD == itemResId or PeakGameConfig.ProtectCard.PointsProtectionCard == itemResId then
    return false
  end
  if self:IsShopItemType(itemType, itemSubType) then
    if jumpExchangeUrl and jumpExchangeUrl ~= "" then
      return true
    end
    return ShopSystem.GetShopItemInfoByKeyItemId(itemResId) ~= nil
  end
  if itemSubType == 1615 then
    return false
  end
  if itemSubType == 1618 then
    return false
  end
  if itemSubType == 1626 then
    return false
  end
  if itemType == 30 then
    if itemSubType == ENUM_ITEM_SUBTYPE.BrainRotCard then
      return true, true
    end
    if itemSubType == ENUM_ITEM_SUBTYPE.Active_Exchange_Material then
      if itemResId == 1532065 then
        return false
      end
      if itemResId == 1617043 then
        return false
      end
      return true
    end
  end
  if (itemSubType == 1604 or itemSubType == 1612) and not FuncUtil.IsActivityUrlValid(jumpExchangeUrl) then
    return false
  end
  if itemSubType == 1613 or itemSubType == 30003 then
    return false
  end
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  if self:IsUpassUpgradeType(itemSubType) then
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    if UnknowPassBuySystem.IsPassId(itemResId) and PassDataSystem.is_experience and PassDataSystem.is_experience == 1 then
      return true
    end
    if UnknowPassBuySystem.IsNewUserPrivlegesCard(itemResId) then
      return not UnknowPassSystem.IsBuyElite
    end
    if UnknowPassBuySystem.IsRpExperienceCard(itemResId) then
      return not UnknowPassSystem.IsBuyElite
    end
    if UnknowPassBuySystem.IsPassIdWithType(itemResId, true) then
      return not UnknowPassSystem.IsBuyEliteSeg2
    end
    if UnknowPassBuySystem.IsPassIdWithType(itemResId) then
      return not UnknowPassSystem.IsBuyElite or UnknowPassSystem.CanExtraUpgrade
    end
  end
  if self:IsBonusPassUpgradeType(itemSubType) then
    local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
    if not Logic_BonusPass:IsInActivityTimes() then
      return false
    end
    local Logic_BonusPass_Buy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass_Buy)
    Logic_BonusPass_Buy:InitBPUpgradeCardConfig()
    if Logic_BonusPass_Buy:IsLevel1To30BPUpgradeCard(itemResId) then
      return not Logic_BonusPass:IsHasUnlockRpBranch()
    end
    if Logic_BonusPass_Buy:IsLevel30To60BPUpgradeCard(itemResId) then
      return not Logic_BonusPass:IsUnlockFullBP()
    end
    if Logic_BonusPass_Buy:IsLevel1To60BPUpgradeCard(itemResId) then
      return not Logic_BonusPass:IsUnlockFullBP()
    end
  end
  if itemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item and itemSubType == ENUM_ITEM_SUBTYPE.SmallRP_Card and self:IsSmallRPCard(itemResId) then
    local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
    return not Logic_SmallRP:GetIsUnlock()
  end
  if itemSubType == 1699 then
    return false
  end
  if self:IsIsolatedItem(itemResId) then
    return false
  end
  local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
  if LuckyUnbackSystem.IsLuckyUnbackOldVoucher(itemResId) then
    return true
  end
  local TableUtil = require("common.table_util")
  if itemSubType == ENUM_ITEM_SUBTYPE.Coupon or itemSubType == ENUM_ITEM_SUBTYPE.SpecialCoupon then
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    local couponInfo = CouponSystem.GetCouponInfoByItemId(itemResId)
    if couponInfo and couponInfo.scenes and 1 >= TableUtil.CountTable(couponInfo.scenes) then
      if couponInfo.scenes[CouponSystem._Enum_Scene._SupplyB0oxAct] then
        local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
        return supply_collect_chest_manager:GetShopTabInfoByShopId(couponInfo.child_scene)
      end
      if couponInfo.scenes[CouponSystem._Enum_Scene._GoldenSuitSpin] or couponInfo.scenes[CouponSystem._Enum_Scene._TarotCard] or couponInfo.scenes[CouponSystem._Enum_Scene._GoldenSuit] then
        return self:IsHaveJumpUrl(itemResId)
      end
    end
    if GlobalData.IsJapanOrKorea() and couponInfo and #couponInfo.scenes >= 2 then
      return false
    end
  elseif itemSubType == ENUM_ITEM_SUBTYPE.SpecialTicket then
    return LobbySystem.CheckJumpWhiteList(jumpExchangeUrl)
  end
  local useItemTable = {
    15,
    16,
    21,
    26,
    44,
    27,
    33,
    39,
    66,
    604,
    800,
    620
  }
  return 0 < TableUtil.Find(useItemTable, itemType)
end
function ItemTipsUtil:IsHaveJumpUrl(itemResId)
  local cfg = CDataTable.GetTableData("JumpExchangeUrlConfig", itemResId)
  return cfg and cfg.JumpExchangeUrl and cfg.JumpExchangeUrl ~= ""
end
function ItemTipsUtil:CanSendItem(itemResId)
  local UI_SEND_BUTTON_SWITCH_ID = 70003
  local switch = LobbySystem.CheckOpen(UI_SEND_BUTTON_SWITCH_ID)
  if not switch then
    return false
  end
  return CDataTable.GetTableData("ItemSendFriend", itemResId) ~= nil
end
function ItemTipsUtil:CanSendItem2(res_id)
  local sendId = LogicXSuit.GetSendGiftId(res_id)
  log(bWriteLog and tostring(sendId) .. "cccccccccccccccccc" .. tostring(res_id))
  return sendId ~= nil
end
function ItemTipsUtil:IsGoldenSuitGiftByOther(res_id)
  local exchangeID = LogicXSuit.GetExchagngeGiftIdOnCfg(res_id)
  return exchangeID ~= nil
end
function ItemTipsUtil:IsGoldenSuit(itemType)
  return itemType == 601
end
function ItemTipsUtil:IsPetExchangeCard(itemType)
  return itemType == 603
end
function ItemTipsUtil:CanExchangeItem(jumpExchangeUrl)
  if not jumpExchangeUrl or jumpExchangeUrl == "" then
    return false
  end
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(jumpExchangeUrl)
  if tonumber(params.module) == BP_ENUM_MODULE_ACTIVITY then
    local id = params.id
    if id then
      id = tonumber(id)
      local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
      local activityMap = ActivityNewSystem.GetActivityMap()
      return activityMap[id] ~= nil
    end
  end
  return false
end
function ItemTipsUtil:CanJumpToShop(itemResId, itemSubType, isSourceBook)
  if self:IsIsolatedItem(itemResId) then
    return false
  end
  local JumpUtils = require("client.logic.store.jump_utils")
  if isSourceBook then
    return FuncUtil.CondOp(JumpUtils.FindJumpInfoAll(itemResId), true, false)
  end
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = CDataTable.GetTableData("Item", itemResId)
  if WardrobeDataManager.IsAirCastType(itemSubType) then
    return false
  end
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(itemInfo, "WardrobeTab") == wardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_effect
end
function ItemTipsUtil:CanShowUpgradeBtn(res_id, ins_id)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local Source = WardrobeData:GetItemSource(ins_id)
  if Source == EWardrobeDataSource.InheritWardrobe then
    return false
  end
  local level = LogicXSuit.GetLevelByItemId(res_id)
  local period = LogicXSuit.GetPeriodByItemId(res_id)
  local info = LogicXSuit.GetBaseInfo(period)
  if level ~= nil and info ~= nil and level ~= info.max_level then
    return true
  else
    return false
  end
end
function ItemTipsUtil:CanMvpPreview(res_id)
  local WardrobeMainTab, WardrobeSubTab = self:GetItemTab(res_id)
  local itemCfg = CDataTable.GetTableData("Item", res_id)
  if itemCfg == nil then
    return false
  end
  local macroTabString = wardrobeMacro.ENUM_WardrobeSubTabString
  local isMvpPreview = WardrobeMainTab == wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute and WardrobeSubTab == macroTabString.ENUM_WardrobeSubTabString_character_MVP_MOTION and itemCfg.itemType == 41 and (itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.MVPAction or itemCfg.itemSubType == 41001)
  return isMvpPreview
end
function ItemTipsUtil:CanGetItem(exchangeBtnValid, itemInfo)
  if jumpUrl == "game://?module=1008710" then
    return true
  end
  if self:GetAvatarItemOwned(itemInfo.res_id) then
    return false
  end
  if not exchangeBtnValid and itemInfo.isSourceBook then
    return self:IsUrl(itemInfo.jumpExchangeUrl)
  end
  return false
end
function ItemTipsUtil:CanDecomposeItem(itemResId, itemInsId)
  log(bWriteLog and "ItemTipsUtil:CanDecomposeItem  itemResId " .. tostring(itemResId))
  log(bWriteLog and "ItemTipsUtil:CanDecomposeItem  itemInsId " .. tostring(itemInsId))
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(itemInsId)
  local itemCfg = CDataTable.GetTableData("Item", itemResId)
  local TableUtil = require("common.table_util")
  local itemSubType = TableUtil.GetTableValue(itemCfg, "itemSubType")
  if self:IsUpassUpgradeType(itemSubType) then
    if not UnknowPassSystem.IsInCurSession then
      return false
    end
    if not UnknowPassSystem.IsBuyElite then
      return false
    end
    local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
    if UnknowPassBuySystem.IsPassIdWithType(itemResId, true) and UnknowPassSystem.IsBuyEliteSeg2 then
      return true
    end
    if UnknowPassBuySystem.IsPassIdWithType(itemResId) and not UnknowPassSystem.CanExtraUpgrade then
      return true
    end
    if UnknowPassBuySystem.IsRpExperienceCard(itemResId) and UnknowPassSystem.IsBuyElite then
      return true
    end
    if UnknowPassBuySystem.IsNewUserPrivlegesCard(itemResId) and UnknowPassSystem.IsBuyElite then
      return true
    end
  end
  if self:IsBonusPassUpgradeType(itemSubType) then
    if not UnknowPassSystem.IsInCurSession then
      return false
    end
    local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
    local Logic_BonusPass_Buy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass_Buy)
    Logic_BonusPass_Buy:InitBPUpgradeCardConfig()
    if Logic_BonusPass_Buy:IsLevel1To30BPUpgradeCard(itemResId) and Logic_BonusPass:IsHasUnlockRpBranch() then
      return true
    end
    if Logic_BonusPass_Buy:IsLevel30To60BPUpgradeCard(itemResId) and Logic_BonusPass:IsUnlockFullBP() then
      return true
    end
    if Logic_BonusPass_Buy:IsLevel1To60BPUpgradeCard(itemResId) and Logic_BonusPass:IsUnlockFullBP() then
      return true
    end
    return false
  end
  if itemCfg.ItemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item and itemSubType == ENUM_ITEM_SUBTYPE.SmallRP_Card then
    if self:IsSmallRPCard(itemResId) then
      local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
      return Logic_SmallRP:GetIsUnlock()
    end
    return false
  end
  local decomposeSystem = require("client.logic.decompose.logic_decompose")
  local keepCount = 1
  if itemSubType == 1604 or itemSubType == 1612 or itemResId == 1702049 or itemResId == 1702095 then
    keepCount = 0
  end
  return decomposeSystem.CheckItemCanDecompose(itemInfo, itemCfg, true, keepCount) or decomposeSystem.CheckItemCanDecompose(itemInfo, itemCfg, false, keepCount)
end
function ItemTipsUtil:CanUpgradeItemInGame(itemResId)
  if self:IsIsolatedItem(itemResId) then
    return false
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  return ItemUpgradeMgr:CheckCanUpgrade(itemResId)
end
function ItemTipsUtil:CanUpgradeItemInPandora(itemResId)
  if self:IsIsolatedItem(itemResId) then
    return false
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  return ItemUpgradeMgr:CheckCanUpgradeInPandoraAct(itemResId)
end
function ItemTipsUtil:GetRemainTimeString(expireTS)
  local timeString = ""
  if expireTS and expireTS ~= 0 then
    local TimeUtil = require("client.common.time_util")
    local remainTime = expireTS - TimeUtil.GetServerTimeInSec()
    if remainTime <= 0 then
      timeString = LocUtil.GetLocalizeResStr(9910111)
    else
      local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      local tmpStr = WardrobeLogicManager:GetRemainTimeStr(expireTS)
      if tmpStr and tmpStr ~= "" then
        timeString = LocUtil.LocalizeResFormat(2000017, tmpStr)
      end
    end
  end
  local timeVis = 0 < string.len(timeString)
  return timeString, timeVis
end
function ItemTipsUtil:GetAvatarItemOwned(resId)
  local avatarData = CDataTable.GetTableDataByFilter("AvatarInit", "BodyID", resId)
  if avatarData then
    local remainTime = DataMgr.GetAvatarRemainTime(avatarData.id)
    local judgeTime = remainTime
    if remainTime < 0 then
      if 0 < avatarData.ForeverCost or 0 < avatarData.RoyalePassSeason then
        judgeTime = remainTime
      else
        judgeTime = 0
      end
    end
    return 0 <= judgeTime
  end
  return false
end
function ItemTipsUtil:GetComposeNeedNum(itemResId)
  local itemComposeCfg = CDataTable.GetTableData("ItemCompose", itemResId)
  if itemComposeCfg and itemComposeCfg.needNum then
    return itemComposeCfg.needNum
  end
  return 0
end
function ItemTipsUtil:IsPlating(itemResId)
  local itemcfg = CDataTable.GetTableData("Item", itemResId)
  return itemcfg and itemcfg.ItemType == ENUM_ITEM_TYPE.Spray_Pattern
end
function ItemTipsUtil:GetTipsString(exchangeValid, isSourceBook, jumpUrl)
  local tipsString = jumpUrl
  local tipsVis = Collapsed
  if not exchangeValid and isSourceBook and not self:IsUrl(jumpUrl) then
    tipsVis = Visible
  end
  if string.len(tipsVis) == 0 then
    tipsVis = LocUtil.GetLocalizeResStr("9910109")
  end
  return tipsString, tipsVis
end
function ItemTipsUtil:CanPlayThrowObjectEffect(res_id)
  if not LobbySystem.CheckOpen(BP_ENUM_THROW_OBJECT_EFFECT_SWITCH) then
    return false
  end
  local WardrobeMainTab, WardrobeSubTab = self:GetItemTab(res_id)
  local macroTabString = wardrobeMacro.ENUM_WardrobeSubTabString
  return WardrobeMainTab == wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute and WardrobeSubTab == macroTabString.ENUM_WardrobeSubTabString_throw_object
end
function ItemTipsUtil:CanCarLevelUp(resID)
  local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
  return VehicleRefitHandler.CanLevelUp(resID)
end
function ItemTipsUtil:GetItemInfo(itemInsId, itemResId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfg = CDataTable.GetTableData("Item", itemResId)
  local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(itemInsId)
  if itemCfg then
    local itemInfo = {}
    itemInfo.ins_id = itemInsId
    itemInfo.res_id = itemResId
    itemInfo.itemType = itemCfg.ItemType or 0
    itemInfo.itemDesc = itemCfg.ItemDesc or ""
    itemInfo.jumpExchangeUrl = self:GetJumpUrlByJk(itemResId)
    itemInfo.mainTabType = itemCfg.WardrobeMainTab or 0
    itemInfo.itemSubType = itemCfg.itemSubType or 0
    itemInfo.itemName = itemCfg.itemName or ""
    itemInfo.quality = itemCfg.itemQuality or 0
    local UIUtil = require("client.common.ui_util")
    itemInfo.preview = UIUtil.GetPreview(itemResId)
    if itemData then
      itemInfo.expireTS = itemData.expireTS or 0
      itemInfo.count = itemData.count or 0
      itemInfo.lock_cnt = itemData.lock_cnt or 0
      itemInfo.isSourceBook = false
      itemInfo.isFree = itemData.isFree
    else
      itemInfo.expireTS = 0
      itemInfo.count = 0
      itemInfo.isSourceBook = true
    end
    log_tree("ItemTipsUtil:GetItemInfo ", itemInfo)
    return itemInfo
  end
end
function ItemTipsUtil:GetWardrobeUI()
  return UIManager.GetUI(UIManager.UI_Config.wardrobe)
end
function ItemTipsUtil:HideWardrobUI()
  UIManager.CloseUI(UIManager.UI_Config.wardrobe)
end
function ItemTipsUtil:ShowWardrobUI()
  UIManager.ShowUI(UIManager.UI_Config.wardrobe)
end
function ItemTipsUtil:GetItemTab(itemResId)
  local itemInfo = CDataTable.GetTableData("Item", itemResId)
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(itemInfo, "WardrobeMainTab"), TableUtil.GetTableValue(itemInfo, "WardrobeTab")
end
function ItemTipsUtil:CanInteractiveActionPreview(res_id)
  local WardrobeMainTab, WardrobeSubTab = self:GetItemTab(res_id)
  local canPreview = WardrobeMainTab == wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute and WardrobeSubTab == wardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_interactive_action
  return canPreview
end
function ItemTipsUtil:CanShowEmoteButton(res_id)
  return false
end
function ItemTipsUtil:ShowCollectJumpButton(res_id)
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local VehicleType = VehicleCollectSystem:GetVehicleType(res_id)
  if VehicleType < 1 then
    return false
  end
  local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
  if not ThemeVehicleManager:CheckVehicleTypeHasUnlock(VehicleType) then
    return false
  end
  return true
end
function ItemTipsUtil:SetItemFrom(image, isFree)
  log(bWriteLog and "  :isFree" .. tostring(isFree))
  image:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function ItemTipsUtil:ShowHideBagButton(ItemID)
  local AvatarHideBagConfig = CDataTable.GetTableData("AvatarHideBagConfig", ItemID)
  if AvatarHideBagConfig then
    return true
  end
  return false
end
function ItemTipsUtil:ShowHideFaceButton(ItemID)
  return LogicXSuit.GetPeriodByItemId(ItemID) == 10
end
function ItemTipsUtil:ShowColorFollowButton(ItemID, InsID)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInFashionBagEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if bInFashionBagEditMode then
    return false
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local Source = WardrobeData:GetItemSource(tonumber(InsID))
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  if WeaponDiffColorModule:ClothHasSwitch(ItemID) then
    return WeaponDiffColorModule:CheckWeaponColorFollowSwitch(ItemID, Source) ~= nil
  else
    return false
  end
end
function ItemTipsUtil:ShowButtonDetail(ItemID)
  local WardrobeAccConfig = CDataTable.GetTableData("WardrobeAccConfig", ItemID)
  if WardrobeAccConfig and WardrobeAccConfig.bShowAccEffect then
    return true
  end
  return false
end
function ItemTipsUtil:ShowButtonStartUpFX(ItemID)
  local WardrobeAccConfig = CDataTable.GetTableData("WardrobeAccConfig", ItemID)
  if WardrobeAccConfig and WardrobeAccConfig.bShowStartUpEffect then
    return true
  end
  return false
end
function ItemTipsUtil:ShowButtonGarageEdit(ItemID)
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  return GarageThemeSystem:IsGarageTheme(ItemID)
end
function ItemTipsUtil:ShowButtonThemeUpgrade(ItemID)
  local JumpConfigItem
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    JumpConfigItem = CDataTable.GetTableData("ItemSourceJumpINConfig", ItemID)
  elseif PublishRegionMacros.IsJapanOrKorea() then
    JumpConfigItem = CDataTable.GetTableData("ItemSourceJumpJKConfig", ItemID)
  else
    JumpConfigItem = CDataTable.GetTableData("ItemSourceJumpConfig", ItemID)
  end
  local ItemInfo = CDataTable.GetTableData("Item", ItemID)
  if JumpConfigItem and ItemInfo and ItemInfo.ItemType == 202 then
    return true
  end
  return false
end
function ItemTipsUtil:IsItemHasFeature(ItemID, FeatureType)
  local ItemCfg = CDataTable.GetTableData("FeaturesItems", ItemID)
  if ItemCfg then
    local StringUtil = require("common.string_util")
    local features = StringUtil.Split(ItemCfg.Features, ";")
    for _, featureID in ipairs(features) do
      local featureCfg = CDataTable.GetTableData("FeaturesConfig", tonumber(featureID))
      if featureCfg and featureCfg.FeatureType == FeatureType then
        return true
      end
    end
    features = StringUtil.Split(ItemCfg.SFeatures, ";")
    for _, featureID in ipairs(features) do
      local featureCfg = CDataTable.GetTableData("FeaturesConfig", tonumber(featureID))
      if featureCfg and featureCfg.FeatureType == FeatureType then
        return true
      end
    end
  end
  return false
end
function ItemTipsUtil:ShowButtonRandomVoice(ItemID)
  return self:IsItemHasFeature(ItemID, ENUM_FeatureType.RandomVoice)
end
function ItemTipsUtil:ShowButtonBattleDamage(ItemID)
  return self:IsItemHasFeature(ItemID, ENUM_FeatureType.BattleDamage)
end
function ItemTipsUtil:ShowButtonAerialShow(ItemID)
  return self:IsItemHasFeature(ItemID, ENUM_FeatureType.AerialShow)
end
function ItemTipsUtil:CheckIsCanUse_1627001()
  local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
  return Logic_ColorShapeUtils.CheckIsExistCanUnlockColorShape()
end
function ItemTipsUtil:CanShowClickEmoteButton(res_id)
  return self:IsItemHasFeature(res_id, ENUM_FeatureType.ClickEmotion)
end
function ItemTipsUtil:CanEquipItem(itemSubType)
  if itemSubType == ENUM_ITEM_SUBTYPE.ClickEffect then
    return true
  end
  return false
end
function ItemTipsUtil:CanJumpSupplyRolePool(jumpExchangeUrl)
  if jumpExchangeUrl and jumpExchangeUrl ~= "" then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(jumpExchangeUrl)
    local moduleId = params.module and params.module ~= "" and tonumber(params.module)
    if moduleId == BP_ENUM_MODULE_SUPPLY and params.character and params.character ~= "" then
      return true
    end
  end
end
function ItemTipsUtil:GetJumpUrlByJk(itemId)
  if GlobalData.IsJapanOrKorea() then
    local jumpCfg = CDataTable.GetTableData("ItemSourceJumpJKConfig", itemId)
    if jumpCfg and jumpCfg.JumpType and jumpCfg.JumpType ~= "" then
      local StringUtil = require("common.string_util")
      local jumpTypeList = StringUtil.Split(jumpCfg.JumpType, "|")
      for i, jType in ipairs(jumpTypeList) do
        local nJumpID = tonumber(jType)
        local jumpUrlCfg = CDataTable.GetTableData("JumpConfig", nJumpID)
        if jumpUrlCfg and string.len(jumpUrlCfg.JumpUrl) > 0 and LobbySystem.CheckUrlCanJump(jumpUrlCfg.JumpUrl) then
          return jumpUrlCfg.JumpUrl
        end
      end
    end
  end
  local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", itemId)
  local jumpExchangeUrl = jumpConfig and jumpConfig.JumpExchangeUrl or ""
  return jumpExchangeUrl
end
return ItemTipsUtil