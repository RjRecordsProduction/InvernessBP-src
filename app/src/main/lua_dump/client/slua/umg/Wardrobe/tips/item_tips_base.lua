local ItemTipsBase = {}
local ShopSystem = require("client.logic.shop.logic_shop")
local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
local wardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local item_tips_util = require("client.slua.umg.Wardrobe.tips.item_tips_util")
local CONST_LONG_PRESS_GAP = 0.5
function ItemTipsBase:ctor(selfType, ...)
  self.ins_id, self.res_id = ...
end
function ItemTipsBase:InitTipData(...)
  self.ins_id, self.res_id = ...
  self:OnRefreshTag()
end
function ItemTipsBase:RegistEvents()
  ItemTipsBase.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_BANNER_DATA_CHANGE, self.OnBannerDataChange, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, self.OnUpdatePutOnData, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, self.OnUpdatePutDownData, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, self.OnWardrobeDataChange, self)
  self:AddCommonEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, self.OnBuyPass, self)
  self:AddCommonEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE, self.OnEquipStatChange, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_JUMP_DATA_RECEIVE, self.Refresh, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE, self.Refresh, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_DATA_UPDATE, self.OnRefreshTag, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_TAG_CHANGE, self.OnRefreshTag, self)
  if self.UIRoot.Button_Edit_Tags then
    self:AddControlEventByControl(self.UIRoot.Button_Edit_Tags, "OnReleased", self.OnReleaseEditTagsBtn, self)
    self:AddControlEventByControl(self.UIRoot.Button_Edit_Tags, "OnPressed", self.OnPressEditTagsBtn, self)
  end
end
function ItemTipsBase:OnPostInitialize()
  ItemTipsBase.__super.OnPostInitialize(self)
  local JumpUtils = require("client.logic.store.jump_utils")
  log(bWriteLog and "ItemTipsBase:OnPostInitialize RequestJumpMapInfo")
  JumpUtils.RequestJumpMapInfo()
  self:OnRefreshTag()
  self.LastPressEditTagTime = 0
end
function ItemTipsBase:OnShow()
  ItemTipsBase.__super.OnShow(self)
  self:OnRefreshTag()
  self:Refresh()
  self:SetWidgetVisible(self.UIRoot.Button_UseNum, false)
end
function ItemTipsBase:OnRefresh()
  if self:IsShow() then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    if wardrobe_data:GetItemCountByInsID(self.ins_id) == 0 then
      self:Hide()
    else
      self:Refresh()
    end
    self:OnRefreshTag()
  end
end
function ItemTipsBase:OnPlayBtnClicked()
  local itemResId = self.res_id
  if self:IsFilter() then
    return
  end
  log(bWriteLog and "ItemTipsBase:OnPlayBtnClicked")
  local Mvp_Motion_System = require("client.slua.logic.mvp_motion.logic_mvp_motion")
  local wardrobeUI = item_tips_util:GetWardrobeUI()
  wardrobeUI.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  Mvp_Motion_System.Play_MVP_Motion(itemResId, nil, function()
    local TableUtil = require("common.table_util")
    wardrobeUI.jumpPageId = TableUtil.GetTableValue(wardrobeMacro, "ENUM_WardrobePageTypeId", "ENUM_WardrobePageType_Parachute")
    wardrobeUI.jumpSubTabId = TableUtil.GetTableValue(wardrobeMacro, "ENUM_WardrobeSubTabString", "ENUM_WardrobeSubTabString_character_MVP_MOTION")
    wardrobeUI:Show()
    wardrobeUI.jumpSubTabId = nil
  end)
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
  self:PlayAudio(sound_config.click_v1)
end
function ItemTipsBase:OnUseBtnClicked()
  log(bWriteLog and "ItemTipsBase:OnUseBtnClicked")
  local UIUtil = require("client.common.ui_util")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local itemData = wardrobe_data:GetHallDepotItemDataByInsID(self.ins_id)
  if not itemData then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  if self:IsFilter() then
    return
  end
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if LogicParticleEmote:IsUnLockProp(self.res_id) then
    LogicParticleEmote:UsePropItem(self.res_id)
    return
  end
  if itemData.itemSubType == ENUM_ITEM_SUBTYPE.MixItemEEProduct then
    local MixItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.MixItemModule)
    MixItemModule:UseEEProduct()
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  if PublishRegionMacros.IsJapanOrKorea() then
    local logic_season_shop_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_shop_system)
    local jumpUrl, canJump = logic_season_shop_system:GetJumpUrl(self.res_id)
    log(bWriteLog and string.format("ItemTipsBase:OnUseBtnClicked JAPAN or KOREA jumpUrl:%s, canJump:%s", jumpUrl, canJump))
    if not canJump then
      return
    end
    if jumpUrl then
      GlobalData.JumpUrl(jumpUrl)
      return
    end
    local JumpExchangeUrl = item_tips_util:GetJumpUrlByJk(self.res_id)
    if JumpExchangeUrl and JumpExchangeUrl ~= "" then
      log(bWriteLog and "[YY]2222222222====" .. tostring(JumpExchangeUrl))
      GlobalData.JumpUrl(JumpExchangeUrl)
      local activityType = FuncUtil.GetActivityTypeByURL(JumpExchangeUrl)
      if 0 < activityType then
        return
      end
      return
    end
  end
  local itemInfo = item_tips_util:GetItemInfo(self.ins_id, self.res_id)
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  if itemInfo.res_id == SocialIslandHandler.createIslandCardItemId then
    if not SocialIslandHandler.HaveDownloadSocialIsland() then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.SocialIsland_CreateByCard_UIBP)
    return
  end
  local ShopCouponSystem = require("client.slua.logic.coupon.logic_coupon_shop")
  if ShopCouponSystem.IsShopSoldCouponID(itemInfo.res_id) then
    local itemid = ShopCouponSystem.GetReflectItemIdToJumpByCouponItemID(itemInfo.res_id)
    if itemid then
      log(bWriteLog and "GetReflectItemIdToJumpByCouponItemID " .. tostring(itemid))
      StoreUtils.JumpFirst(itemid)
      StoreUtils.DelayNetCo = coroutine.create(function()
        ShopCouponSystem.ShowBuyWindowByItemID(itemid)
      end)
      return
    else
      do
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("6897"))
        return
      end
    end
  end
  log(bWriteLog and "EventWardrobeOnClickUseItem:" .. tostring(itemData.itemType))
  log(bWriteLog and "EventWardrobeOnClickUseItem:" .. tostring(itemData.itemSubType))
  local BlackFridayPassModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayPassModule)
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  if item_tips_util:IsShopItemType(itemData.itemType, itemData.itemSubType) then
    local pageId = ShopSystem.GetShopItemInfoByKeyItemId(itemInfo.res_id)
    if pageId then
      store_supply_manager:JumpToCrateByTabId(pageId)
    elseif itemInfo.jumpExchangeUrl ~= "" then
      GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    end
    return
  elseif itemData.itemType == 16 and itemData.itemSubType == 1625 then
    if StoreUtils.CheckHaveSubTab(StoreConst.Page_New_ID_Exchange, StoreConst.label_subtype_voice_chip) then
      GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    else
      ShowNotice(LocUtil.LocalizeResFormat(108101))
    end
    return
  elseif itemData.itemType == 26 and (itemData.itemSubType == 2601 or itemData.itemSubType == 2604) then
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.workshop) then
      ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.workshop))
      return
    end
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    ItemUpgradeMgr:ShowUI(self.res_id)
    return
  elseif itemData.itemType == 26 and itemData.itemSubType == 2602 then
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.workshopGunDiy) then
      ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.workshopGunDiy))
      return
    end
    local logic_weapon_diy = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    logic_weapon_diy:EnterSystem()
    return
  elseif itemData.itemType == 26 and itemData.itemSubType == 2603 then
    local period = LogicXSuit.IsUnlockStateMaterial(self.res_id)
    local oneLevel, state
    if period then
      local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
      oneLevel = logic_xsuit_activity:GetXSuitOneLevelID()
      if LogicXSuit.CheckUnlockState(period, 1, EWardrobeDataSource.Wardrobe) then
        state = 2
      else
        state = 1
      end
    end
    LogicXSuit.ShowUpgradeUI(period, oneLevel, state)
    return
  elseif itemData.itemType == 16 and itemData.itemSubType == 1605 then
    if LobbySystem.CheckOpen(BP_ENUM_PET_SWITCH) then
      if UIManager then
        local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
        logic_pet:OpenPetWorkShop(0)
      end
    else
      ShowNotice(120001)
    end
    return
  elseif itemData.itemType == 16 and itemData.itemSubType == 1606 then
    if UIManager then
      UIManager.ShowUI(UIManager.UI_Config.pet_dress_card)
      UIManager.GetUI(UIManager.UI_Config.pet_dress_card):SetData(itemInfo.res_id)
    end
    return
  elseif itemData.itemType == 16 and itemData.itemSubType == 1612 then
    log(bWriteLog and "[cw] itemData.itemType == 16 and itemData.itemSubType == 1612 ")
    if itemInfo and itemInfo.jumpExchangeUrl ~= "" then
      local activityType = FuncUtil.GetActivityTypeByURL(itemInfo.jumpExchangeUrl)
      if 0 < activityType then
        GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
        return
      end
    end
  elseif itemData.itemType == 16 and itemData.itemSubType == 1640 then
    local logic_season_shop_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_shop_system)
    local jumpUrl, canJump = logic_season_shop_system:GetJumpUrl(itemData.resID)
    log(bWriteLog and string.format("ItemTipsBase:OnUseBtnClicked jumpUrl:%s, canJump:%s", jumpUrl, canJump))
    if not canJump then
      return
    end
    if jumpUrl then
      GlobalData.JumpUrl(jumpUrl)
      return
    end
    GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    return
  elseif itemData.itemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item and itemData.itemSubType == ENUM_ITEM_SUBTYPE.SpecialTicket then
    if LobbySystem.CheckJumpWhiteList(itemInfo.jumpExchangeUrl) then
      GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    end
    return
  elseif itemData.itemType == 44 then
    self:ClickUseCharacterItem(itemData)
    return
  elseif itemData.itemType == 16 and (itemData.itemSubType == ENUM_ITEM_SUBTYPE.Coupon or itemData.itemSubType == ENUM_ITEM_SUBTYPE.SpecialCoupon) then
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
    if itemData.resID == UnknowPassMacro.ENUM_PASS_VOUCHER_ID[1] or itemData.resID == UnknowPassMacro.ENUM_PASS_VOUCHER_ID[2] then
      GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_UNKNOW_PASS)
    else
      CouponSystem.JumpByItemInfo(itemInfo, true)
    end
    return
  elseif itemData.itemType == 27 and itemData.itemSubType == 2701 then
    local isOpen = LobbySystem.CheckOpen(BP_ENUM_VEHICLE_REFIT_SWITCH)
    if not isOpen then
      ShowNotice(120001)
      return
    end
    local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
    VehicleCollectSystem:OpenVehicleWorkShop(VehicleCollectSystem.ENUM_VEHICLE_SYSTEM.REFIT)
    return
  elseif itemData.itemSubType == 1616 or itemData.itemSubType == 1617 or itemData.itemSubType == 1630 then
    GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    return
  elseif itemData.itemType == ENUM_ITEM_TYPE.Materials and itemData.itemSubType == ENUM_ITEM_SUBTYPE.BrainRotCard then
    GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    return
  elseif itemData.itemType == 33 and itemData.itemSubType == 3301 then
    if not LobbySystem.CheckOpen(BP_ENUM_CHAT_HORN_SWITCH) then
      ShowNotice(8802)
      return
    end
    local logic_access_restriction = require("client.logic.common.logic_access_restriction")
    if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.Wireless) then
      return
    end
    UIManager.CloseUI(UIManager.UI_Config.wardrobe)
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    logic_chat_main.OpenChatMain(logic_chat_main.chatMacro.Channel.channelWorld)
    return
  elseif itemData.itemType == 66 or itemData.itemType == 604 then
    if itemData.itemSubType == 6601 then
      CreateRoomSystem.CreateRoomByItemID(self.res_id)
    else
      CreateRoomSystem.ShowCreateRoomUIByItemID(self.res_id)
    end
    return
  elseif itemData.itemType == 30 and itemData.itemSubType == 30003 then
    local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", itemInfo.res_id)
    local jumpExchangeUrl = jumpConfig and jumpConfig.JumpExchangeUrl or ""
    if jumpExchangeUrl then
      GlobalData.JumpUrl(jumpExchangeUrl)
      return
    end
  elseif itemData.itemType == 39 and itemData.itemSubType == 3901 then
    if StoreUtils.JumpToCommonExchangeStore(itemData.resID) then
      return
    end
  elseif self.res_id == 1320 then
    local logic_new_player_spin = require("client.slua.logic.growth_project.logic_new_player_spin")
    logic_new_player_spin.OpenSpinUI()
    return
  elseif itemData.itemType == ENUM_ITEM_TYPE.Item_Card and itemData.itemSubType == ENUM_ITEM_SUBTYPE.UGC_Exposure_Coupon then
    GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    return
  elseif BlackFridayPassModule:IsPassExtraBox(self.res_id) then
    UIManager.ShowUI(UIManager.UI_Config.BlackFriday_Pass_ExtraAward_Use_UIBP, self.res_id)
    return
  elseif self.res_id == AiCopilotLimtItemId then
    UIManager.ShowUI(UIManager.UI_Config.UGC_Assistant_Main_UIBP)
    local UGCAIHandler = require("client.network.Protocol.UGCAIHandler")
    local itemList = {
      [1] = itemInfo.ins_id
    }
    UGCAIHandler.send_ugc_use_llm_card_req(itemList)
    return
  elseif itemData.itemType == 16 and itemData.itemSubType == 1663 then
    GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    return
  elseif itemData.itemType == 16 and itemData.itemSubType == 1660 then
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    if logic_group_buying:IsShow() then
      GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    else
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      local title = LocUtil.GetLocalizeResStr(166029)
      local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
      local Logic_ItemUtils = require("client.slua.logic.common.Logic_ItemUtils")
      local cost_id = logic_group_buying.COST_ID[self.res_id]
      local depositDeductionVoucherNum = Logic_ItemUtils.GetItemCount(logic_group_buying.DEPOSIT_DEDUCTION_VOUCHER_ID[cost_id])
      local content = LocUtil.LocalizeResFormat(166030, depositDeductionVoucherNum, "<img src=\"" .. logic_group_buying.SHOW_ICON_NAME[cost_id] .. "\"/>", depositDeductionVoucherNum)
      local Func = function()
        local NewGroupBuyHandler = RequireMod("client.network.Protocol.NewGroupBuyHandler")
        NewGroupBuyHandler.send_exchange_new_group_buy_entrance_req(self.res_id)
      end
      CommonMsgBoxMgr.Show(2, title, content, Func)
    end
    return
  elseif itemData.itemType == 16 and itemData.itemSubType == 1661 then
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    if logic_group_buying:IsShow() then
      GlobalData.JumpUrl(itemInfo.jumpExchangeUrl)
    else
      ShowNotice(88011)
    end
    return
  end
  UIUtil.OpenUseItemUI(itemInfo.ins_id)
end
function ItemTipsBase:OnUpgradeBtnClicked()
  log(bWriteLog and "ItemTipsBase:OnUpgradeBtnClicked")
  local itemInfo = item_tips_util:GetItemInfo(self.ins_id, self.res_id)
  self:PlayAudio(sound_config.click_v1)
  if itemInfo then
    local inPandora, jumpUrl = item_tips_util:CanUpgradeItemInPandora(itemInfo.res_id)
    if inPandora then
      GlobalData.JumpUrl(jumpUrl)
    else
      local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
      if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.workshop) then
        ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.workshop))
        return
      end
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      ItemUpgradeMgr:ShowUI(itemInfo.res_id)
    end
  end
end
function ItemTipsBase:OnComposeBtnClicked()
  local itemInsId = self.ins_id
  local itemResId = self.res_id
  local itemInfo = item_tips_util:GetItemInfo(self.ins_id, self.res_id)
  local itemCount = itemInfo.count
  self:PlayAudio(sound_config.click_v1)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  log(bWriteLog and "ItemTipsBase:OnComposeBtnClicked  item " .. itemInsId)
  local itemData = wardrobe_data:GetHallDepotItemDataByInsID(itemInsId)
  if not itemData then
    return
  end
  if itemData.count < item_tips_util:GetComposeNeedNum(itemResId) then
    ShowNotice(4716)
    return
  end
  GLOBAL_USE_ITEM = itemInsId
  UIManager.ShowUI(UIManager.UI_Config.wardrobe_compose, GLOBAL_USE_ITEM, itemResId, itemCount)
end
function ItemTipsBase:OnSendBtnClicked()
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "ItemTipsBase:OnSendBtnClicked")
end
function ItemTipsBase:OnDecomposeBtnClicked()
  local itemInsId = self.ins_id
  local itemResId = self.res_id
  local itemInfo = item_tips_util:GetItemInfo(self.ins_id, self.res_id)
  local itemCount = itemInfo.count
  local itemExpireTS = itemInfo.expireTS
  local itemMainTapType = itemInfo.mainTabType
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local wardrobeDataItemCount = WardrobeDataManager:GetUseCount(itemInsId)
  if itemInfo.lock_cnt and itemInfo.lock_cnt > 0 and not AvatarData.CheckWearItem(itemInfo.insID) then
    itemCount = itemCount + 1
  end
  log(bWriteLog and "ItemTipsBase:OnDecomposeBtnClicked")
  self:PlayAudio(sound_config.click_v1)
  if self:IsFilter() then
    return
  end
  if itemMainTapType ~= wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Tool and itemCount <= 1 and itemExpireTS <= 0 then
    ShowNotice(9910119)
    return
  end
  if itemMainTapType ~= wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Tool and wardrobeDataItemCount >= itemCount then
    ShowNotice(4809)
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", itemResId)
  if not itemCfg then
    return
  end
  if item_tips_util:IsUpassUpgradeType(itemCfg.ItemSubType) then
    local content = ""
    local itemName = LocUtil.LocalizeResFormat(7271, UnknowPassSystem.Season)
    local itemData = CDataTable.GetTableData("Item", 1099)
    itemName = itemData.itemName or LocUtil.LocalizeResFormat(11155)
    local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
    if UnknowPassBuySystem.IsUniversalRP(itemResId) then
      itemName = LocUtil.LocalizeResFormat(11155)
    end
    log(bWriteLog and "UnknowPassSystem.Season" .. UnknowPassSystem.Season)
    local num = 6
    local logic_decompose = require("client.logic.decompose.logic_decompose")
    local decomposeConfig = logic_decompose.GetItemDecomposeInfo(itemResId)
    if decomposeConfig then
      num = decomposeConfig.new_min_count
    end
    content = LocUtil.LocalizeResFormat(7270, itemName, num)
    local title = LocUtil.GetLocalizeResStr(9910118)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, content, function()
      logic_decompose.SendDecomposeMsg(itemInsId, 1)
    end)
    return
  end
  if itemCfg.ItemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.SmallRP_Card then
    local sContent = LocUtil.LocalizeResFormat(73562)
    local logic_decompose = require("client.logic.decompose.logic_decompose")
    local tDecomposeConfig = logic_decompose.GetItemDecomposeInfo(itemResId)
    if tDecomposeConfig then
      local nDecCount = tDecomposeConfig.new_min_count
      sContent = LocUtil.LocalizeResFormat(73563, nDecCount)
    end
    local sTitle = LocUtil.GetLocalizeResStr(9910118)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, sTitle, sContent, function()
      logic_decompose.SendDecomposeMsg(itemInsId, 1)
    end)
    return
  end
  local TimeUtil = require("client.common.time_util")
  if 0 < itemExpireTS and itemExpireTS < TimeUtil.GetServerTimeInSec() then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(9910101), function()
      EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST)
      self:Hide()
    end)
    return
  end
  GLOBAL_USE_ITEM = itemInsId
  local bIsLimitTimeItem = 0 < itemExpireTS
  local CommonUseItemSystem = require("client.slua.logic.common.logic_common_use_items")
  if itemMainTapType == wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Tool or 0 < itemExpireTS then
    CommonUseItemSystem.ShowDecomposeItem(itemCfg, itemCount, bIsLimitTimeItem)
  else
    CommonUseItemSystem.ShowDecomposeItem(itemCfg, itemCount - math.max(1, wardrobeDataItemCount), bIsLimitTimeItem)
  end
end
function ItemTipsBase:OnJumpShopBtnClicked()
  log(bWriteLog and "ItemTipsBase:OnJumpShopBtnClicked")
  self:PlayAudio(sound_config.click_v1)
  if self:IsFilter() then
    return
  end
  local itemResId = self.res_id
  local itemInfo = CDataTable.GetTableData("Item", itemResId)
  if itemInfo ~= nil and itemInfo.WardrobeTab == wardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_effect then
    local logic_season_shop_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_shop_system)
    local jumpUrl, canJump = logic_season_shop_system:GetJumpUrl(itemResId)
    log(bWriteLog and string.format("ItemTipsBase:OnJumpShopBtnClicked jumpUrl:%s, canJump:%s", jumpUrl, canJump))
    if not canJump then
      return
    end
    if jumpUrl then
      GlobalData.JumpUrl(jumpUrl)
    else
      GlobalData.JumpUrl("game://?module=1003200&itemId=" .. itemResId)
    end
  else
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    store_supply_manager:JumpToStoreCrateByItemId(itemResId, nil, BP_ENUM_MODULE_LOBBY)
  end
end
function ItemTipsBase:OnExchangeBtnClicked()
  log(bWriteLog and "ItemTipsBase:OnExchangeBtnClicked")
  self:PlayAudio(sound_config.click_v1)
  local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", self.res_id)
  if jumpConfig ~= nil then
    GlobalData.JumpUrl(jumpConfig.JumpExchangeUrl)
  end
end
function ItemTipsBase:OnGetBtnClicked()
  log(bWriteLog and "ItemTipsBase:OnGetBtnClicked")
  self:PlayAudio(sound_config.click_v1)
  if self:IsFilter() then
    return
  end
  local ItemID = self.res_id
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if LogicParticleEmote:IsParticleEmote(ItemID) and not LogicParticleEmote:HasUnlockParticle(ItemID) and LogicParticleEmote:HaveUnLockProp() then
    ItemID = LogicParticleEmote.UNLOCK_PROP_ID
  end
  local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", ItemID)
  if jumpConfig ~= nil then
    GlobalData.JumpUrl(jumpConfig.JumpExchangeUrl)
  end
end
function ItemTipsBase:ClickUseCharacterItem(itemData)
  if self:IsFilter() then
    return
  end
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_CHARACTER, true) then
    return
  end
  if itemData == nil then
    return
  end
  local noticeStr = ""
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  local tItemJumpCfg = CDataTable.GetTableData("JumpExchangeUrlConfig", itemData.resID)
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
  if itemData.itemSubType == CharacterUtils.Enum_Item_SubType.EnumType_Exp then
    if NewCharacterNetSystem:IsUsedCharacter(CharacterUtils.DEFAULT_CHARACTER_ID) then
      noticeStr = LocUtil.GetLocalizeResStr(9066)
      ShowNotice(noticeStr)
    else
      local CurCharID = NewCharacterNetSystem:GetCurUsedCharacterID()
      local CurCharacterData = NewCharacterNetSystem:GetCurUsedCharacterData(CurCharID)
      local MaxLevel = CharacterUtils:GetCharacterMaxLevel(CurCharID)
      if CurCharacterData ~= nil then
        if MaxLevel <= CurCharacterData.level then
          noticeStr = LocUtil.GetLocalizeResStr(4608)
          ShowNotice(noticeStr)
        else
          do
            local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
            if LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_NewCharacter) then
              local info = {itemId = CurCharID, bUpgrade = true}
              NewCharacterSystem:JumpToCharacter(info)
            else
              LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.EName_NewCharacter, function()
                local info = {itemId = CurCharID, bUpgrade = true}
                NewCharacterSystem:JumpToCharacter(info)
              end)
            end
          end
        end
      end
    end
  elseif itemData.itemSubType == CharacterUtils.Enum_Item_SubType.EnumType_Chip and tItemJumpCfg and tItemJumpCfg.JumpExchangeUrl ~= "" then
    GlobalData.JumpUrl(tItemJumpCfg.JumpExchangeUrl)
  else
    local info = {
      itemId = itemData.resID
    }
    NewCharacterSystem:JumpToCharacter(info)
  end
end
function ItemTipsBase:OnPlayGrenadeEffect()
  log(bWriteLog and "ItemTipsBase:OnPlayGrenadeEffect")
  if self:IsFilter() then
    return
  end
  local wardrobeUI = item_tips_util:GetWardrobeUI()
  wardrobeUI:Hide()
  local callback = function()
    local TableUtil = require("common.table_util")
    wardrobeUI.jumpPageId = TableUtil.GetTableValue(wardrobeMacro, "ENUM_WardrobePageTypeId", "ENUM_WardrobePageType_Parachute")
    wardrobeUI.jumpSubTabId = TableUtil.GetTableValue(wardrobeMacro, "ENUM_WardrobeSubTabString", "ENUM_WardrobeSubTabString_throw_object")
    wardrobeUI:Show()
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
  local Grenade_Motion_System = require("client.slua.logic.grenade_motion.logic_grenade_motion")
  local x = -5156
  local y = 2112
  local z = -19190
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.store_general)
  Grenade_Motion_System.Play_Grenade_Motion(x, y, z, callback)
end
function ItemTipsBase:OnCarLevelUp()
  self:PlayAudio(sound_config.click_v1)
  if self:IsFilter() then
    return
  end
  local isOpen = LobbySystem.CheckOpen(BP_ENUM_VEHICLE_REFIT_SWITCH)
  if not isOpen then
    ShowNotice(120001)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(self.ins_id)
  if itemData then
    local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
    VehicleCollectSystem:OpenVehicleWorkShop(VehicleCollectSystem.ENUM_VEHICLE_SYSTEM.REFIT, itemData.resID)
  end
end
function ItemTipsBase:RefreshComposeNum(valid, curNum, itemResId)
  local needNum = item_tips_util:GetComposeNeedNum(itemResId)
  local color = FuncUtil.CondOp(curNum >= needNum, FSlateColor(FLinearColor(0, 0, 0, 0.4)), FSlateColor(FLinearColor(1, 0, 0, 1)))
  self:SetWidgetVisible(self.UIRoot.composeC, valid)
  self.UIRoot.composeTxt_1:SetText(tostring(curNum))
  self.UIRoot.composeTxt_2:SetText(tostring(needNum))
  self.UIRoot.composeTxt_1:SetColorAndOpacity(color)
end
function ItemTipsBase:OnPutOnBtnClicked()
  self:PlayAudio(sound_config.click_v1)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe:wardrobe_puton_req(self.ins_id)
end
function ItemTipsBase:OnPutOffBtnClicked()
  self:PlayAudio(sound_config.click_v1)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe:wardrobe_put_down_req(self.ins_id)
end
function ItemTipsBase:OnGiveBtnClicked()
  self:PlayAudio(sound_config.click_v1)
  if self:IsFilter() then
    return
  end
  local sendId = LogicXSuit.GetSendGiftId(self.res_id)
  if not sendId then
    return
  end
  LogicXSuit.ShowSendGiftUI(self.res_id, false)
  UIManager.CloseUI(UIManager.UI_Config.wardrobe)
end
function ItemTipsBase:OnOpenBtnClicked()
  self:PlayAudio(sound_config.click_v1)
  if self:IsFilter() then
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfg = CDataTable.GetTableData("Item", self.res_id)
  local isPetExchangeCard = item_tips_util:IsPetExchangeCard(itemCfg.itemType)
  if isPetExchangeCard then
    return
  end
  if itemCfg.itemSubType == 6012 then
    LogicXSuit.ShowSelectStateUI(tonumber(self.ins_id))
  else
    local XSuitHandler = require("client.network.Protocol.XSuitHandler")
    XSuitHandler.send_open_gold_dress_req(tonumber(self.ins_id))
  end
end
function ItemTipsBase:IsFilter()
  local JaguarSystem = require("client.slua.logic.jaguar.logic_jaguar")
  local is_filter = JaguarSystem.IsFilter(self.res_id)
  if is_filter then
    ShowNotice(116009)
    return true
  end
  return false
end
function ItemTipsBase:OnClickShareToClub()
  log(bWriteLog and "ItemTipsBase:OnClickShareToClub")
  self:PlayAudio(sound_config.click_v1)
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.OpenPublishFeed(logic_community.PublishFeedType.WardrobeItem, self.res_id, nil, logic_community.GameScene.WardrobeItemShare)
end
function ItemTipsBase:IsCanShareClubWardrobeMainTab(wardrobeMainTab)
  return wardrobeMainTab == wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar or wardrobeMainTab == wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon or wardrobeMainTab == wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Vehicle
end
function ItemTipsBase:Close()
  local logic_mvp_motion = require("client.slua.logic.mvp_motion.logic_mvp_motion")
  logic_mvp_motion.Stop_Mvp_Motion_Without_End_Call_Back()
  ItemTipsBase.__super.Close(self)
end
function ItemTipsBase:OnBannerDataChange()
  self:OnRefresh()
end
function ItemTipsBase:OnUpdatePutOnData()
  self:OnRefresh()
end
function ItemTipsBase:OnUpdatePutDownData()
  self:OnRefresh()
end
function ItemTipsBase:OnWardrobeDataChange()
  self:OnRefresh()
end
function ItemTipsBase:OnBuyPass()
  self:OnRefresh()
end
function ItemTipsBase:OnEquipStatChange()
  self:OnRefresh()
end
function ItemTipsBase:OnPressEditTagsBtn()
  local TimeUtil = require("client.common.time_util")
  self.LastPressEditTagTime = TimeUtil.GetServerTimeInSecWithFraction()
end
function ItemTipsBase:OnReleaseEditTagsBtn()
  self:PlayAudio(sound_config.click_v1)
  if not self.UIRoot.Button_Edit_Tags or not self.UIRoot.WidgetSwitcher_1 then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeTagTips) or {}
  data.bHasShowTagTips = true
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eWardrobeTagTips)
  if UIManager.GetUI(UIManager.UI_Config.Wardrobe_Tag_NewGuide_Tips_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Wardrobe_Tag_NewGuide_Tips_UIBP)
  end
  local TimeUtil = require("client.common.time_util")
  local TimeNow = TimeUtil.GetServerTimeInSecWithFraction()
  local bLongPress = TimeNow - self.LastPressEditTagTime >= CONST_LONG_PRESS_GAP
  local ActiveIndex = self.UIRoot.WidgetSwitcher_1:GetActiveWidgetIndex()
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  if bLongPress then
    log(bWriteLog and "ItemTipsBase:OnReleaseEditTagsBtn. long click")
    self:OpenTagEditPanel()
  elseif ActiveIndex == 0 then
    log(bWriteLog and "ItemTipsBase:OnReleaseEditTagsBtn. no tag")
    logic_wardrobe_tag_mgr:AddItemToDefaultTagDirect(self.res_id)
  elseif ActiveIndex == 1 then
    log(bWriteLog and "ItemTipsBase:OnReleaseEditTagsBtn. single tag")
    logic_wardrobe_tag_mgr:RemoveAllTagDirect(self.res_id)
  else
    self:OpenTagEditPanel()
  end
end
function ItemTipsBase:OnRefreshTag()
  if self.UIRoot.WidgetSwitcher_1 then
    local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
    local tagList = logic_wardrobe_tag_mgr:GetTagListByItemID(self.res_id)
    local tag1Key, tag2Key
    if tagList and next(tagList) then
      for k, v in pairs(tagList) do
        if v then
          if not tag1Key then
            tag1Key = k
          elseif not tag2Key then
            tag2Key = k
            break
          end
        end
      end
    end
    if tag1Key then
      if tag2Key then
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(2)
        local Color1 = logic_wardrobe_tag_mgr.TAG_COLOR_MAP[tag1Key]
        local Color2 = logic_wardrobe_tag_mgr.TAG_COLOR_MAP[tag2Key]
        if Color1 then
          self.UIRoot.Image_MultiTag1:SetColorAndOpacity(Color1)
        end
        if Color2 then
          self.UIRoot.Image_MultiTag2:SetColorAndOpacity(Color2)
        end
      else
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
        local Color1 = logic_wardrobe_tag_mgr.TAG_COLOR_MAP[tag1Key]
        if Color1 then
          self.UIRoot.Image_SingleTag:SetColorAndOpacity(Color1)
        end
      end
    else
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    end
  end
  if UIManager.GetUI(UIManager.UI_Config.Wardrobe_Tag_NewGuide_Tips_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Wardrobe_Tag_NewGuide_Tips_UIBP)
  end
  if self.UIRoot.Button_Edit_Tags then
    local wardrobeUI = item_tips_util:GetWardrobeUI()
    local bShowTagFilter = false
    if wardrobeUI then
      bShowTagFilter = wardrobeUI:IsCurrentPageShowTagFilter()
    end
    self:SetWidgetVisible(self.UIRoot.Button_Edit_Tags, bShowTagFilter, true)
    if bShowTagFilter then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeTagTips)
      local bShowTagTips = not data or not data.bHasShowTagTips
      if not bShowTagTips then
        return
      end
      self:CreateChildWindowWithBpPath(self.UIRoot.CanvasPanel_TagTips, UIManager.UI_Config.Wardrobe_Tag_NewGuide_Tips_UIBP)
    end
  end
end
function ItemTipsBase:OpenTagEditPanel()
  if self.TagSelectPanel then
    UIManager.CloseUI(UIManager.UI_Config.Wardrobe_TipsPanel_Favorites_UIBP)
    self.TagSelectPanel = nil
  end
  local UIUtil = require("client.common.ui_util")
  local ButtonAbsPos = UIUtil.GetWidgetViewportPos(self.UIRoot.Button_Edit_Tags, 0, 0)
  self.TagSelectPanel = UIManager.ShowUI(UIManager.UI_Config.Wardrobe_TipsPanel_Favorites_UIBP, self.res_id, ButtonAbsPos)
end
local class = require("class")
local ui_ItemTipsBaseSuper = require("client.slua.umg.Wardrobe.tips.item_tips_base_super")
local CItemTipsBase = class(ui_ItemTipsBaseSuper, nil, ItemTipsBase)
return CItemTipsBase