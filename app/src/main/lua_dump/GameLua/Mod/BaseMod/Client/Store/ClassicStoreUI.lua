local ClassicStoreUI = {}
local EPawnState = import("EPawnState")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local StoreConfig = GamePlayTools.GetCurrentConfig("StoreConfig")
local IntlHelper = import("IntlHelper")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EExtraPlayerLiveState = import("ExtraPlayerLiveState")
local TableUtil = require("common.table_util")
local TimeUtil = require("client.common.time_util")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local FormatLog = FuncUtil.FormatLog
local FriendlyBehaviorModule = require("GameLua.Mod.BaseMod.Common.Security.FriendlyBehavior")
local ui_util = require("client.common.ui_util")
local LogicClassicStore = require("GameLua.Mod.BaseMod.GamePlay.Logic.LogicClassicStore")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function ClassicStoreUI:ctor()
  self.nGold = 0
  self.nReviveTicket = 0
  self.nAdvancedWeaponTicket = 0
  self.bShouldShowNewItems = false
  self.CurrentSelectWidgetData = nil
  self.SelectedItemsList = {}
  self.SelectedItemsMap = {}
  self.CurrentCost = 0
  self.CurrentSelectItemID = 0
  self.CurrentSelectItemOldNum = 0
  self.TimeLimitIndexMap = {}
  self.CurrentSelectIndex = 1
  self.CurrentSelectSubIndex = 1
  self.GameTimerID = nil
  self.RedColor = FSlateColor(FLinearColor(1, 0, 0, 1))
  self.WhiteColor = FSlateColor(FLinearColor(1, 1, 1, 0.7))
  self.TeammateData = {}
  self.EmptyTeammateData = {}
  self.TeammateIDIndexTable = {}
  self.bShouldShowTeammateBuyLife = false
  self.BuyTeammateLifeGoodID = 0
  self.bHasTeammateDead = false
  self.DeadTeammateMap = {}
  self.bHasBuyLifeCount = false
  self.StoreSubData = {}
  self.StoreHideIDMap = {}
  self.ItemDataMap = {}
  self.DiscountGoodMap = {}
  self.bNeedBezel = false
  self.bHasBezel = false
  self.bHasShowBezelAnim = false
  self.CurrentBezelWidget = nil
  self.bNeedGunLock = false
  self.bHasGunLock = false
  self.bHasShowGunLockAnim = false
  self.CurrentGunLockWidget = nil
  self.bNeedTacticalAttach = false
  self.bHasTacticalAttach = false
  self.bHasShowTacticalAttachAnim = false
  self.CurrentTacticalAttachWidget = nil
  self.GiftBoxAnimMap = {}
  self.nCloseStoreReason = 0
  self.bShouldPlayOpenStoreAudio = true
  self.RotatingDiscountMap = {}
  self.CurrentRiviveTicketCost = 0
  self.CurrentAdvancedWeaponTicketCost = 0
  self.sRiviveTicketPath = "/Game/Arts/UI/NoAtlas/ResidentStore/CommodityCurrency_Icon03.CommodityCurrency_Icon03"
  self.sAdvancedWeaponTicketPath = "/Game/Arts/UI/NoAtlas/ResidentStore/CommodityCurrency_Icon04.CommodityCurrency_Icon04"
  self.bDisableCrit = false
  self.DefaultItemScript = nil
end
function ClassicStoreUI:OnInitialize()
  print(bWriteLog and "ClassicStoreUI:OnInitialize")
  ClassicStoreUI.__super.OnInitialize(self)
  self.UIRoot.TextBlock_158:SetText(tostring(0))
  self:UpdateBuyBtnStatus()
  local ResidentStore_Item_Details_UIBP = self.UIRoot.ResidentStore_Item_Details_UIBP
  self.AccessoriesSlot = {
    ResidentStore_Item_Details_UIBP.ResidentStore_Item_Accessories_UIBP1,
    ResidentStore_Item_Details_UIBP.ResidentStore_Item_Accessories_UIBP2,
    ResidentStore_Item_Details_UIBP.ResidentStore_Item_Accessories_UIBP3,
    ResidentStore_Item_Details_UIBP.ResidentStore_Item_Accessories_UIBP4,
    ResidentStore_Item_Details_UIBP.ResidentStore_Item_Accessories_UIBP5,
    ResidentStore_Item_Details_UIBP.ResidentStore_Item_Accessories_UIBP6
  }
  self.UIRoot.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeType, _ = GameMainConfig.GetModType()
  local DisableModType = StoreConfig.RandomEventConfig.DisableModType
  self.bDisableCrit = DisableModType[ModeType]
  self.UIRoot.Button_Question:SetWidgetVisibility(self.bDisableCrit and UEnums.ESlateVisibility.Collapsed or UEnums.ESlateVisibility.Visible)
  self.UIRoot.Image_Crit:SetWidgetVisibility(self.bDisableCrit and UEnums.ESlateVisibility.Collapsed or UEnums.ESlateVisibility.Visible)
  self:InitializeDefaultItemScript()
end
function ClassicStoreUI:InitializeDefaultItemScript()
  if not self.DefaultItemScript then
    local DefaultScriptClass = require(StoreConfig.DefaultItemScriptPath)
    self.DefaultItemScript = DefaultScriptClass()
    self.DefaultItemScript.ParentUI = self
  end
end
function ClassicStoreUI:GetItemScript(ItemID, ItemType)
  return self.DefaultItemScript
end
function ClassicStoreUI:RegistEvents()
  print(bWriteLog and "ClassicStoreUI:RegistEvents")
  self:AddControlEventByControl(self.UIRoot.Button_Close, "OnClicked", self.OnClicked_Leave, self)
  self:AddControlEventByControl(self.UIRoot.Button_Buy, "OnClicked", self.OnClicked_Buy, self)
  self:AddControlEventByControl(self.UIRoot.Button_ExchangeGoods, "OnClicked", self.OnClicked_ExchangeGoods, self)
  if self.UIRoot.Button_Question then
    self:AddControlEventByControl(self.UIRoot.Button_Question, "OnClicked", self.OnClicked_Question, self)
  end
  if self.UIRoot.Button_AdvancedWeaponTicket then
    self:AddControlEventByControl(self.UIRoot.Button_AdvancedWeaponTicket, "OnClicked", self.OnClicked_AdvancedWeaponTicket, self)
  end
  if self.UIRoot.Button_ReviveTicket then
    self:AddControlEventByControl(self.UIRoot.Button_ReviveTicket, "OnClicked", self.OnClicked_ReviveTicket, self)
  end
  self.UIRoot.WidgetSwitcher_BuyOrExchange:SetActiveWidgetIndex(0)
  self.StoreExtendScrollGrid = self:InitMultiItemsScrollGridWithScript(self.UIRoot.MultiItemsLoopScrollGrid_0, "GameLua.Mod.BaseMod.Client.Store.Items.StoreExtendTitleItem", "GameLua.Mod.BaseMod.Client.Store.Items.StoreExtendSubItem")
  self.UIRoot.MultiItemsLoopScrollGrid_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.ShoppingCarScrollBox = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
  self.ShoppingCarScrollBox:SetRefreshItemCallback(self.OnRefreshShoppingCarItems, self)
  self.ShoppingCarScrollBox:AddItemWidgetChildEvent("Button_Reduce", "OnClicked", self.OnClickShoppingCarItem, self)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
    if slua.isValid(uPlayerPawn) then
      self:AddControlEventByControl(uPlayerPawn, "IsEnterNearDeathDelegate", self.IsEnterNearDeathDelegate, self)
    end
  end
  self:ListenCommonEvent()
end
function ClassicStoreUI:ListenCommonEvent()
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_CHANGE_STATE, self.OnBackPackChangeState, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_CLASSICSTORE, EVENTID_INGAME_SHOW_OR_HIDE_CLASSICSTORE_BUTTON, self.ShowOrHideClassicStore, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.CloseSelf, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_STORE, EVENTID_INGAME_STORE_OPERATE_PRODUCT_END, self.OnRspOperateProductEnd, self)
end
function ClassicStoreUI:OnBackpackItemListChanged(_, _, uBackpackComponent)
  print(bWriteLog and "ClassicStoreUI:OnBackpackItemListChanged")
  if not slua.isValid(uBackpackComponent) then
    return
  end
  if uBackpackComponent:IsItemListUpdatedHasOneItem(StoreConfig.GoldID) then
    local Count = uBackpackComponent:GetItemCountByItemSpecialID(StoreConfig.GoldID)
    if Count ~= self.nGold then
      if self.UIRoot and self.UIRoot.Fadein_Exchange then
        self:PlayUserWidgetAnimation(self.UIRoot.Fadein_Exchange, 0, 1, 0, 1)
      end
      self:OnStoreGoldUpdate(Count)
    end
  end
  if uBackpackComponent:IsItemListUpdatedHasOneItem(StoreConfig.ExchangeTicketConfig.ReviveTicket.TicketItemID) then
    local ReviveTicketCount = uBackpackComponent:GetItemCountByItemSpecialID(StoreConfig.ExchangeTicketConfig.ReviveTicket.TicketItemID)
    if ReviveTicketCount ~= self.nReviveTicket then
      self:OnReviveTicketUpdate(ReviveTicketCount)
    end
  end
  if uBackpackComponent:IsItemListUpdatedHasOneItem(StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TicketItemID) then
    local AdvancedWeaponTicketCount = uBackpackComponent:GetItemCountByItemSpecialID(StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TicketItemID)
    if AdvancedWeaponTicketCount ~= self.nAdvancedWeaponTicket then
      self:OnAdvancedWeaponTicketUpdate(AdvancedWeaponTicketCount)
    end
  end
end
function ClassicStoreUI:ShowOrHideClassicStore(eventType, eventId, uStore, isShow)
  if isShow then
    self:UpdateCurrentStore(uStore)
    self:OnClicked_OpenStore()
    self:UpdateFriendlyUI()
    self:OpenStorePanel()
  else
    self:OnClicked_Leave()
  end
end
function ClassicStoreUI:InitStoreData(Store)
  self:OnUpdateCurrentStore(Store)
end
function ClassicStoreUI:CreateGoodsList(Store)
end
function ClassicStoreUI:OnStoreGoldUpdate(nGold)
  print(bWriteLog and "ClassicStoreUI:OnStoreGoldUpdate", nGold)
  self.  self.UIRoot.TextBlock_1:SetText(tostring(nGold))
  self:RefreshStoreItems()
  self:RefreshStoreItemsByClick()
end
function ClassicStoreUI:OnReviveTicketUpdate(nReviveTicket)
  print(bWriteLog and "ClassicStoreUI:OnReviveTicketUpdate", nReviveTicket)
  self.  if self.UIRoot and self.UIRoot.TextBlock_5 then
    self.UIRoot.TextBlock_5:SetText(tostring(nReviveTicket))
  end
end
function ClassicStoreUI:OnAdvancedWeaponTicketUpdate(nAdvancedWeaponTicket)
  print(bWriteLog and "ClassicStoreUI:OnAdvancedWeaponTicketUpdate", nAdvancedWeaponTicket)
  self.  if self.UIRoot and self.UIRoot.TextBlock_4 then
    self.UIRoot.TextBlock_4:SetText(tostring(nAdvancedWeaponTicket))
  end
end
function ClassicStoreUI:UpdateBuyBtnStatus()
  print(bWriteLog and "ClassicStoreUI:UpdateBuyBtnStatus")
  if #self.SelectedItemsList == 0 then
    self.UIRoot.Image_385:SetBrushfromPathAsync(StoreConfig.DesignatedStoreCannotBuyIcon, false)
    self.UIRoot.Image_Exchange:SetBrushfromPathAsync(StoreConfig.DesignatedStoreCannotBuyIcon, false)
  else
    self.UIRoot.Image_385:SetBrushfromPathAsync(StoreConfig.DesignatedStoreCanBuyIcon, false)
    self.UIRoot.Image_Exchange:SetBrushfromPathAsync(StoreConfig.DesignatedStoreCanBuyIcon, false)
  end
end
function ClassicStoreUI:UpdateShoppingCarCost()
  print(bWriteLog and "ClassicStoreUI:UpdateShoppingCarCost", tostring(self.CurrentCost))
  self.UIRoot.TextBlock_158:SetText(tostring(self.CurrentCost))
  if self.UIRoot and self.UIRoot.TextBlock_0 and self.UIRoot.TextBlock_3 then
    self.UIRoot.TextBlock_0:SetText(tostring(self.CurrentRiviveTicketCost))
    self.UIRoot.TextBlock_3:SetText(tostring(self.CurrentAdvancedWeaponTicketCost))
  end
end
function ClassicStoreUI:ClearShoppingCar()
  print(bWriteLog and "ClassicStoreUI:ClearShoppingCar")
  self:ClearData()
  self:UpdateShoppingCarCost()
  self:UpdateBuyBtnStatus()
  self.ShoppingCarScrollBox:SetData(self.SelectedItemsList)
end
function ClassicStoreUI:ClearData()
  print(bWriteLog and "ClassicStoreUI:ClearData")
  self.TeammateData = {}
  self.EmptyTeammateData = {}
  self.TeammateIDIndexTable = {}
  self.bHasTeammateDead = false
  self.bShouldShowTeammateBuyLife = false
  self.StoreSubData = {}
  self.StoreHideIDMap = {}
  self.DeadTeammateMap = {}
  self.ItemDataMap = {}
  self.DiscountGoodMap = {}
  self.DiscountItemMap = {}
  self.SelectedItemsList = {}
  self.SelectedItemsMap = {}
  self.StoreHideIDMap = {}
  self.CurrentCost = 0
  self.CurrentSelectIndex = 1
  self.CurrentSelectSubIndex = 1
  self.CurrentSelectWidgetData = nil
  self.RotatingDiscountMap = {}
  self.CurrentRiviveTicketCost = 0
  self.CurrentAdvancedWeaponTicketCost = 0
  self.nReviveTicket = 0
  self.nAdvancedWeaponTicket = 0
end
function ClassicStoreUI:InitAll(Store)
  print(bWriteLog and "ClassicStoreUI:InitAll")
  self:InitStoreData(Store)
  self:OpenStorePanel()
end
function ClassicStoreUI:OpenStorePanel()
  print(bWriteLog and "ClassicStoreUI:OpenStorePanel")
  if not self.tStore then
    print(bWriteLog and "ClassicStoreUI:[ERROR] The Store Actor is nil, Refresh the store failed")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "ClassicStoreUI:[ERROR] The uPlayerController is nil, Refresh the store failed")
    return
  end
  print(bWriteLog and "ClassicStoreUI:OpenStorePanel StoreID:" .. self.tStore.StoreID)
  local uCurGameState = GameplayData.GetGameState()
  if not slua.isValid(uCurGameState) then
    print(bWriteLog and "ClassicStoreUI:OpenStorePanel The uGameState is nil, Refresh the store failed")
    return
  end
  if not uCurGameState.StoreFeature then
    print(bWriteLog and "ClassicStoreUI:OpenStorePanel uGameState.StoreFeature is not valid")
    return
  end
  self:CloseBackPackPanel()
  self:ClearShoppingCar()
  self:RefreshDiscountPlan()
  self:LoadRotatingDiscountData()
  self:ReadShowNewItemConfig()
  self.bNeedBezel, self.bNeedGunLock, self.bNeedTacticalAttach = self:CheckNeedBezelAndGunLockAndTacticalAttach()
  self.GiftBoxAnimMap = {}
  local HideGoodsList = self.tStore.StoreFeature[StoreConfig.StoreHideGoodsList[self.tStore.StoreID]]
  if HideGoodsList and HideGoodsList:Num() > 0 then
    for _, GoodID in pairs(HideGoodsList) do
      if GoodID ~= 0 then
        self.StoreHideIDMap[GoodID] = true
      end
    end
  end
  local ShowDataTitle, StoreSubData = self:GetStoreItemData()
  self.StoreExtendScrollGrid:SetData(ShowDataTitle)
  for Num = 1, #ShowDataTitle do
    local Type = StoreConfig.BuyItemType
    if Num == 1 and self.bShouldShowTeammateBuyLife then
      Type = StoreConfig.BuyTeammateEmptyType
    end
    if StoreSubData[Num][1].bDiscount and not StoreSubData[Num][1].bRotatingDiscount then
      Type = StoreConfig.BuyTeammateLifeType
    end
    self.StoreExtendScrollGrid:SetSubData(Num, StoreSubData[Num], Type)
  end
  self:CheckTeammateAvalible()
  self:CheckGifBoxItemType()
  self.CurrentSelectWidgetData = self.StoreExtendScrollGrid:GetSubItemData(1, 1)
  self.CurrentSelectIndex = 1
  if self.bShouldShowTeammateBuyLife and self.CurrentSelectWidgetData.Empty then
    self.CurrentSelectWidgetData = self.StoreExtendScrollGrid:GetSubItemData(2, 1)
    self.CurrentSelectIndex = 2
  end
  self.CurrentSelectWidgetData.bSelected = true
  self:UpdateItemInfo()
  if self.bShouldPlayOpenStoreAudio then
    self:PlayAudioAsync(sound_config.Classic_Store_Open_Store)
  end
  if self.GameTimerID then
    self:RemoveGameTimer(self.GameTimerID)
  end
  self.GameTimerID = self:AddGameTimer(1, true, function()
    self:RefreshTimeOutItems()
  end)
  self:CheckShowBuyTeammateLifeTime()
  self:SendStoreRPC(StoreConfig.OperateType.OpenStore)
  self:RefreshStoreTitleInfo()
  self:ListenCommonEventWhenShow()
end
function ClassicStoreUI:ListenCommonEventWhenShow()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_TAKE_DAMAGE_CLIENT, self.HandleTakeDamage, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST, self.OnBackpackItemListChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_LIVE_STATE_CHANGE, self.OnTeammateLiveStateChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_STATE_FriendlyPointsCurrValue_CHANGED, self.OnFriendlyPointsCurrValueChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_STATE_FriendlyUsesCountThisGame_CHANGED, self.OnFriendlyUsesCountThisGameChanged, self)
end
function ClassicStoreUI:CloseBackPackPanel()
end
function ClassicStoreUI:GetStoreItemData()
  local ShowDataTitle, StoreSubData, TeammateDataResult, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach = LogicClassicStore.GetStoreItemData(self.tStore, self.StoreHideIDMap, self.DiscountGoodMap, self.RotatingDiscountMap, self.bNeedBezel, self.bNeedGunLock, self.bNeedTacticalAttach)
  if not ShowDataTitle or not StoreSubData then
    print(bWriteLog and "ClassicStoreUI:GetStoreItemData Failed to get store data from LogicClassicStore")
    return
  end
  self.ItemDataMap = ItemDataMap or self.ItemDataMap
  self.bHasBezel = bHasBezel or self.bHasBezel
  self.bHasGunLock = bHasGunLock or self.bHasGunLock
  self.bHasTacticalAttach = bHasTacticalAttach or self.bHasTacticalAttach
  if TeammateDataResult then
    self.bShouldShowTeammateBuyLife = TeammateDataResult.bShouldShowTeammateBuyLife
    self.BuyTeammateLifeGoodID = TeammateDataResult.BuyTeammateLifeGoodID
    if TeammateDataResult.EmptyTeammateData then
      self.EmptyTeammateData = TeammateDataResult.EmptyTeammateData
    end
    if self.bShouldShowTeammateBuyLife then
      self:ProcessTeammateRevivalData(TeammateDataResult)
    end
  end
  return ShowDataTitle, StoreSubData
end
function ClassicStoreUI:ProcessTeammateRevivalData(TeammateDataResult)
  local TeammatePlayerState = self:GetTeamMatePlayerStateList()
  if not TeammatePlayerState or TeammatePlayerState:Num() <= 1 then
    return
  end
  local BaseItemData = TeammateDataResult.EmptyTeammateData and TeammateDataResult.EmptyTeammateData[1]
  if not BaseItemData then
    return
  end
  self.TeammateData = {}
  self.bHasTeammateDead = false
  self.bHasBuyLifeCount = false
  for Index, PlayerState in pairs(TeammatePlayerState) do
    if PlayerState then
      if PlayerState.LiveState == EExtraPlayerLiveState.InDied then
        self.bHasTeammateDead = true
      end
      if PlayerState:GetLeftBuyLifeCounts() > 0 then
        self.bHasBuyLifeCount = true
      end
      local TeammateBuyLifeData = TableUtil.CopyTable(BaseItemData)
      TeammateBuyLifeData.Handle = require(StoreConfig.BuyTeammateLifeHandle)
      TeammateBuyLifeData.ExtraData = {Index = Index, TeammatePlayerState = PlayerState}
      TeammateBuyLifeData.Empty = false
      self.TeammateData[Index] = TeammateBuyLifeData
    end
  end
  print(bWriteLog and "ClassicStoreUI:ProcessTeammateRevivalData Processed " .. tostring(#self.TeammateData) .. " teammates")
end
function ClassicStoreUI:RefreshStoreTitleInfo()
  self:ShowGodNum()
  local UIRoot = self.UIRoot
  if self.tStore.StoreID == StoreConfig.DiscountStore or self.tStore.StoreID == StoreConfig.DesertStore then
    UIRoot.Image_Top:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    UIRoot.Image_Top:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  UIRoot.TextBlock_StoreName:SetText(LocUtil.LocalizeResFormat(StoreConfig.StoreNameTextID[self.tStore.StoreID]))
  if self.tStore.StoreID == StoreConfig.CarloStore then
    self:RefreshStoreLimitTime()
    UIRoot.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    UIRoot.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ClassicStoreUI:ShowGodNum()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "ClassicStoreUI:ShowGodNum The uPlayerCharacter is invalid")
    return
  end
  local CurrencNum = Game:GetItemNumByResID(uPlayerCharacter, StoreConfig.GoldID)
  self:OnStoreGoldUpdate(CurrencNum)
  local ReviveTicketNum = Game:GetItemNumByResID(uPlayerCharacter, StoreConfig.ExchangeTicketConfig.ReviveTicket.TicketItemID)
  self:OnReviveTicketUpdate(ReviveTicketNum)
  local AdvancedWeaponTicketNum = Game:GetItemNumByResID(uPlayerCharacter, StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TicketItemID)
  self:OnAdvancedWeaponTicketUpdate(AdvancedWeaponTicketNum)
end
function ClassicStoreUI:ReadShowNewItemConfig()
  local StoreData = CDataTable.GetTableData("IngameStoreTable", self.tStore.StoreID)
  local NewGoodNotifyTimes = StoreData.NewGoodNotifyTimes
  local ModType, _ = GameMainConfig.GetModType()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local HasOpenStoreTime = SettingConfig.OpenStoreTimes:Get(ModType)
  HasOpenStoreTime = HasOpenStoreTime or 0
  if NewGoodNotifyTimes > HasOpenStoreTime then
    self.bShouldShowNewItems = true
    slua_GameFrontendHUD:BeginModifyUserSettings()
    HasOpenStoreTime = HasOpenStoreTime + 1
    SettingConfig.OpenStoreTimes:Add(ModType, HasOpenStoreTime)
    slua_GameFrontendHUD:FinishModifyUserSettings()
  else
    self.bShouldShowNewItems = false
  end
end
function ClassicStoreUI:SendStoreRPC(nOperateType)
  print(bWriteLog and "ClassicStoreUI:SendOpenStoreRPC nOperateType:" .. nOperateType)
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "ClassicStoreUI:SendOpenStoreRPC uPlayerState is invalid")
    return
  end
  if not uPlayerState.StoreFeature then
    print(bWriteLog and "ClassicStoreUI:SendOpenStoreRPC uPlayerState.StoreFeature is not valid")
    return
  end
  if nOperateType == StoreConfig.OperateType.OpenStore then
    uPlayerState.StoreFeature:RPC_Server_OpenStore(self.tStore.Object)
  elseif nOperateType == StoreConfig.OperateType.CloseStore then
    uPlayerState.StoreFeature:RPC_Server_CloseStore(self.tStore.Object, self.nCloseStoreReason)
  elseif nOperateType == StoreConfig.OperateType.BuyGoods then
    local GoodIDs = slua.Array(UEnums.EPropertyClass.Int)
    local GoodNums = slua.Array(UEnums.EPropertyClass.Int)
    local GoodIndexs = slua.Array(UEnums.EPropertyClass.Int)
    for Index, ItemData in pairs(self.SelectedItemsList) do
      local GoodID = ItemData.GoodID
      local GoodIndex = ItemData.ExtraData.Index
      local GoodNum = self.SelectedItemsMap[GoodID][GoodIndex]
      GoodIDs:Add(GoodID)
      GoodNums:Add(GoodNum)
      GoodIndexs:Add(GoodIndex)
      print(bWriteLog and "ClassicStoreUI:SendOpenStoreRPC BuyGoods GoodID:" .. GoodID .. " GoodNum:" .. GoodNum .. " GoodIndex:" .. GoodIndex)
    end
    uPlayerState.StoreFeature:RPC_Server_BuyGoods(self.tStore.Object, GoodIDs, GoodNums, GoodIndexs)
  elseif nOperateType == StoreConfig.OperateType.ExchangeGoods and #self.SelectedItemsList ~= 0 then
    print(bWriteLog and "ClassicStoreUI:SendOpenStoreRPC ExchangeGoods")
    local ItemData = self.SelectedItemsList[1]
    local GoodID = ItemData.GoodID
    local GoodIndex = ItemData.ExtraData.Index
    local ExchangeGoodSkillID = 1014710
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local uSkillManager = uPlayerCharacter:GetSkillManager()
      if slua.isValid(uSkillManager) then
        uSkillManager:SetValueAsInt(ExchangeGoodSkillID, "GoodID", GoodID)
        uSkillManager:SetValueAsInt(ExchangeGoodSkillID, "GoodIndex", GoodIndex)
        uSkillManager:SetValueAsObject(ExchangeGoodSkillID, "StoreActor", self.tStore.Object)
        print(bWriteLog and "ClassicStoreUI:SendOpenStoreRPC ExchangeGoods with Skill, GoodID:" .. tostring(GoodID))
        uPlayerCharacter:TriggerEntrySkillWithParams(ExchangeGoodSkillID, {
          "GoodID",
          "GoodIndex",
          "StoreActor"
        }, true)
      end
    end
  end
end
function ClassicStoreUI:RefreshDiscountPlan()
  self.DiscountGoodMap = LogicClassicStore.RefreshDiscountPlan(self.tStore)
end
function ClassicStoreUI:OnBackPackChangeState(nEventType, nEventID, bShow)
  print(bWriteLog and "ClassicStoreUI:OnBackPackChangeState")
  if bShow then
    self:OnClicked_Leave()
  end
end
function ClassicStoreUI:OnClicked_Buy(widget, index)
  print(bWriteLog and "ClassicStoreUI:OnClicked_Buy")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and PlayerCharacter:HasState(EPawnState.Restricted) then
    print(bWriteLog and "ClassicStoreUI:OnClicked_Buy Player in Restricted State, return")
    return
  end
  if #self.SelectedItemsList == 0 then
    print(bWriteLog and "ClassicStoreUI:OnClicked_Buy [ERROR] #SelectedItems ==0")
    return
  end
  self:SendStoreRPC(StoreConfig.OperateType.BuyGoods)
  self:CloseStore(StoreConfig.CloseStoreReason.BuyGoods)
end
function ClassicStoreUI:OnClicked_ExchangeGoods(widget, index)
  print(bWriteLog and "ClassicStoreUI:OnClicked_ExchangeGoods")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and PlayerCharacter:HasState(EPawnState.Restricted) then
    print(bWriteLog and "ClassicStoreUI:OnClicked_ExchangeGoods Player in Restricted State, return")
    return
  end
  if #self.SelectedItemsList == 0 then
    print(bWriteLog and "ClassicStoreUI:OnClicked_ExchangeGoods [ERROR] #SelectedItems ==0")
    return
  end
  self:SendStoreRPC(StoreConfig.OperateType.ExchangeGoods)
  self:CloseStore(StoreConfig.CloseStoreReason.BuyGoods)
end
function ClassicStoreUI:OnClicked_Leave()
  self:CloseStore(StoreConfig.CloseStoreReason.ClickCloseButton)
end
function ClassicStoreUI:CloseStore(nCloseStoreReason)
  Client.ResetSlateTickEveryFrame(SlateUI_ID.CLASSIC_STORE)
  print(bWriteLog and "ClassicStoreUI:CloseStore nCloseStoreReason:" .. nCloseStoreReason)
  self.  local UIRoot = self.UIRoot
  if UIRoot:GetVisibility() ~= UEnums.ESlateVisibility.SelfHitTestInvisible then
    return
  end
  UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:ClearShoppingCar()
  self:RemoveCommonEventWhenHide()
  if self.GameTimerID then
    self:RemoveGameTimer(self.GameTimerID)
    self.GameTimerID = nil
  end
  if nCloseStoreReason ~= StoreConfig.CloseStoreReason.BuyGoods then
    self:SendStoreRPC(StoreConfig.OperateType.CloseStore)
  end
end
function ClassicStoreUI:RemoveCommonEventWhenHide()
  self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_TAKE_DAMAGE_CLIENT)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_LIVE_STATE_CHANGE)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_STATE_FriendlyPointsCurrValue_CHANGED)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_STATE_FriendlyUsesCountThisGame_CHANGED)
end
function ClassicStoreUI:OnRspOperateProductEnd(_, _, bSuccess)
  if bSuccess then
    self:OnOperateProductSuccess()
  end
  print(bWriteLog and "ClassicStoreUI:OnRspOperateProductEnd bSuccess = " .. tostring(bSuccess))
end
function ClassicStoreUI:OnOperateProductSuccess()
  print(bWriteLog and "ClassicStoreUI:OnOperateProductSuccess")
  self:PlayAudioAsync(sound_config.Classic_Store_Purchase_Buy)
end
function ClassicStoreUI:LoadRotatingDiscountData()
  self.RotatingDiscountMap = LogicClassicStore.LoadRotatingDiscountData(self.tStore)
end
function ClassicStoreUI:CheckShouldNotify(GoodID)
  return LogicClassicStore.CheckShouldNotify(GoodID, self.bShouldShowNewItems, self.tStore)
end
function ClassicStoreUI:HandleTakeDamage(_, _, DamageInfo)
  print(bWriteLog and "ClassicStoreUI:HandleTakeDamage")
  if DamageInfo.DamageType == UEnums.DamageType.PoisonDamage then
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "ClassicStoreUI:HandleTakeDamage not slua.isValid(uPlayerController)")
    return
  end
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    print(bWriteLog and "ClassicStoreUI:HandleTakeDamage not slua.isValid(uPlayerPawn)")
    return
  end
  if DamageInfo.Target.PlayerUID ~= uPlayerPawn.PlayerUID then
    return
  end
  if DamageInfo.Damage == 0 then
    return
  end
  print(bWriteLog and "ClassicStoreUI:HandleTakeDamage Hide Store")
  self:CloseStore(StoreConfig.CloseStoreReason.BeHit)
end
function ClassicStoreUI:IsEnterNearDeathDelegate(IsEnter)
  print(bWriteLog and "ClassicStoreUI:IsEnterNearDeathDelegate IsEnter:", IsEnter)
  if IsEnter then
    self:CloseStore(StoreConfig.CloseStoreReason.NearDeath)
  end
end
function ClassicStoreUI:UpdateCurrentStore(tStore)
  self.end
function ClassicStoreUI:OnClicked_OpenStore()
  Client.RequireSlateTickEveryFrame(SlateUI_ID.CLASSIC_STORE)
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function ClassicStoreUI:SetWidgetData(Widget, WidgetItemData, Index, SubIndex)
  if WidgetItemData.Empty then
    return
  end
  if not Widget.TextBlock_1 then
    return
  end
  Widget.TextBlock_1:SetText(tostring(WidgetItemData.Handle:GetItemPrice(self, WidgetItemData)))
  local ItemCountPerBuy = WidgetItemData.ItemCountPerBuy
  if ItemCountPerBuy == 1 then
    Widget.quantity:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    Widget.quantity:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    Widget.quantity:SetText(tostring(ItemCountPerBuy))
  end
  if WidgetItemData.bSelected then
    Widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    Widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if WidgetItemData.bCannotAfford or WidgetItemData.bSoldOut or WidgetItemData.UnlockTime >= 0 then
    Widget.Image_Mask:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if WidgetItemData.bCannotAfford then
      Widget.TextBlock_1:SetColorAndOpacity(self.RedColor)
    else
      Widget.TextBlock_1:SetColorAndOpacity(self.WhiteColor)
    end
  else
    Widget.TextBlock_1:SetColorAndOpacity(self.WhiteColor)
    Widget.Image_Mask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local bShouldMarkLimit = false
  if WidgetItemData.BattleLimitCount > -1 or -1 < WidgetItemData.StoreLimitCount or -1 < WidgetItemData.PlayerLimitCount then
    if Widget.Image_TimeLimit and Widget.Image_LimitedBG and Widget.TextBlock_Limited then
      Widget.Image_TimeLimit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      Widget.Image_LimitedBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      Widget.TextBlock_Limited:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    bShouldMarkLimit = true
  end
  if 0 < WidgetItemData.TimeLimit then
    if Widget.Image_TimeLimit and Widget.Image_LimitedBG and Widget.TextBlock_Limited then
      Widget.Image_TimeLimit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      Widget.TextBlock_Limited:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      Widget.Image_LimitedBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    bShouldMarkLimit = true
    if not self.TimeLimitIndexMap[Index] then
      self.TimeLimitIndexMap[Index] = {}
    end
    self.TimeLimitIndexMap[Index][SubIndex] = true
  end
  if not bShouldMarkLimit and Widget.Image_TimeLimit and Widget.Image_LimitedBG and Widget.TextBlock_Limited then
    Widget.Image_TimeLimit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    Widget.Image_LimitedBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    Widget.TextBlock_Limited:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self:CheckShouldNotify(WidgetItemData.GoodID) then
    Widget.Image_New:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    Widget.Image_New:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if WidgetItemData.bAlreadySoldOut then
    Widget.CanvasPanel_SoldOut:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    Widget.CanvasPanel_SoldOut:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if Widget.CanvasPanel_Lock then
    if WidgetItemData.UnlockTime >= 0 then
      Widget.CanvasPanel_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      Widget.TextBlock_UnlockTime:SetText(TimeUtil.FormatCountDownTime_HMS(math.floor(WidgetItemData.UnlockTime), true))
    else
      Widget.CanvasPanel_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if WidgetItemData.ItemID == StoreConfig.FriendlyGiftBoxItemId then
  elseif slua.isValid(Widget.quantity) then
    Widget.quantity:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ClassicStoreUI:OnClickItem(Widget, SelectedItem, Index, SubIndex, Type)
  local GoodID = SelectedItem.GoodID
  self.CurrentSelectItemID = GoodID
  self:ReSelectWidget(SelectedItem, Index, SubIndex, Type)
  if SelectedItem.bAlreadySoldOut or SelectedItem.bCannotAfford or SelectedItem.bSoldOut or SelectedItem.UnlockTime >= 0 then
    Widget:PlayUserWidgetAnimation(Widget.Anim_Cannotbuy, 0, 1, 0, 1)
    self:PlayAudioAsync(sound_config.Classic_Store_Item_Cannot_Buy)
    return
  end
  if SelectedItem.ItemID == StoreConfig.FriendlyGiftBoxItemId and self.SelectedItemsMap[GoodID] and SelectedItem.ExtraData and self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] and 1 <= self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] then
    Widget:PlayUserWidgetAnimation(Widget.Anim_Cannotbuy, 0, 1, 0, 1)
    self:PlayAudioAsync(sound_config.Classic_Store_Item_Cannot_Buy)
    return
  end
  local SelectItemGoodBuyType = self:GetGoodBuyTypeByID(GoodID)
  for index, iterSelectedItem in ipairs(self.SelectedItemsList) do
    local iterGoodBuyType = self:GetGoodBuyTypeByID(iterSelectedItem.GoodID)
    if (StoreConfig.ExchangeItemType == SelectItemGoodBuyType or StoreConfig.ExchangeItemType == iterGoodBuyType) and iterGoodBuyType ~= SelectItemGoodBuyType then
      print(bWriteLog and "ClassicStoreUI:OnClickItem ExchangeItem cannot buy with normal goods!")
      IngameTipsTools.BattleNormalTipsByTextID(69862)
      Widget:PlayUserWidgetAnimation(Widget.Anim_Cannotbuy, 0, 1, 0, 1)
      self:PlayAudioAsync(sound_config.Classic_Store_Item_Cannot_Buy)
      return
    end
  end
  if SelectItemGoodBuyType == StoreConfig.ExchangeItemType then
    self.UIRoot.WidgetSwitcher_BuyOrExchange:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_BuyOrExchange:SetActiveWidgetIndex(0)
  end
  Widget:PlayUserWidgetAnimation(Widget.Anim_Select, 0, 1, 0, 1)
  self:PlayAudioAsync(sound_config.Classic_Store_Click_Item)
  if self.SelectedItemsMap[GoodID] == nil then
    self.SelectedItemsMap[GoodID] = {}
  end
  if SelectedItem.ExtraData then
    if not self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] then
      table.insert(self.SelectedItemsList, SelectedItem)
      self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] = 1
    else
      self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] = self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] + 1
    end
    self.CurrentSelectExtraDataIndex = SelectedItem.ExtraData.Index
    self.CurrentSelectItemOldNum = self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] - 1
  end
  self.CurrentSelectItemID = GoodID
  self.ShoppingCarScrollBox:SetData(self.SelectedItemsList)
  if SelectedItem.ItemID == StoreConfig.FriendlyGiftBoxItemId then
    self.CurrentCost = self.CurrentCost + 0
  elseif SelectedItem.ItemID == StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.GiftBoxItemID then
    self.CurrentAdvancedWeaponTicketCost = self.CurrentAdvancedWeaponTicketCost + SelectedItem.Handle:GetItemPrice(self, SelectedItem)
  elseif SelectedItem.ItemID == StoreConfig.ExchangeTicketConfig.ReviveTicket.GiftBoxItemID then
    self.CurrentRiviveTicketCost = self.CurrentRiviveTicketCost + SelectedItem.Handle:GetItemPrice(self, SelectedItem)
  else
    self.CurrentCost = self.CurrentCost + SelectedItem.Handle:GetItemPrice(self, SelectedItem)
  end
  self:UpdateBuyBtnStatus()
  self:UpdateShoppingCarCost()
  self:RefreshStoreItemsByClick()
end
function ClassicStoreUI:GetGoodBuyTypeByID(InGoodID)
  if not self.tStore then
    return StoreConfig.BuyItemType
  end
  return LogicClassicStore.GetGoodBuyTypeByID(InGoodID, self.tStore.StoreID)
end
function ClassicStoreUI:RefreshStoreItems()
  local uGameState = GameplayData.GetGameState()
  if not Game:IsValid(uGameState) then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  for Index = 1, self.StoreExtendScrollGrid:GetItemCount() do
    for SubIndex, WidgetItemData in pairs(self.StoreExtendScrollGrid:GetSubItemList(Index)) do
      if not WidgetItemData.Empty then
        local bNeedRefreshSubItem = false
        local bCannotAfford = WidgetItemData.Handle:CheckCannotAfford(self, WidgetItemData)
        if WidgetItemData.bCannotAfford ~= bCannotAfford and bCannotAfford then
          self:RemoveFromShoppingCar(WidgetItemData)
        end
        if not WidgetItemData.bAlreadySoldOut then
          local bAlreadySoldOut = WidgetItemData.Handle:CheckSoldOut(self, uGameState, uPlayerController, WidgetItemData)
          if WidgetItemData.bAlreadySoldOut ~= bAlreadySoldOut then
            WidgetItemData.            bNeedRefreshSubItem = true
            self:RemoveFromShoppingCar(WidgetItemData)
          end
        end
        if WidgetItemData.UnlockTime >= 0 then
          WidgetItemData.UnlockTime = WidgetItemData.Handle:GetUnLockRemainTime(uGameState, WidgetItemData)
          bNeedRefreshSubItem = true
        end
        if bNeedRefreshSubItem then
          self.StoreExtendScrollGrid:RefreshSubItem(Index, SubIndex, WidgetItemData)
        end
      end
    end
  end
end
function ClassicStoreUI:RefreshStoreItemsByClick()
  local uGameState = GameplayData.GetGameState()
  if not Game:IsValid(uGameState) then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  for Index = 1, self.StoreExtendScrollGrid:GetItemCount() do
    for SubIndex, WidgetItemData in pairs(self.StoreExtendScrollGrid:GetSubItemList(Index)) do
      if not WidgetItemData.Empty then
        local bNeedRefreshSubItem = false
        local LeftPlayerDiscountCount = WidgetItemData.Handle:GetLeftPlayerDiscountCount(self, uPlayerController, WidgetItemData, true)
        if WidgetItemData.LeftPlayerDiscountCount ~= LeftPlayerDiscountCount then
          WidgetItemData.          bNeedRefreshSubItem = true
        end
        local bCannotAfford = WidgetItemData.Handle:CheckCannotAfford(self, WidgetItemData, true)
        if WidgetItemData.bCannotAfford ~= bCannotAfford then
          WidgetItemData.          bNeedRefreshSubItem = true
        end
        if not WidgetItemData.bAlreadySoldOut then
          local bSoldOut = WidgetItemData.Handle:CheckSoldOut(self, uGameState, uPlayerController, WidgetItemData, true)
          if WidgetItemData.bSoldOut ~= bSoldOut then
            WidgetItemData.            bNeedRefreshSubItem = true
          end
        end
        if bNeedRefreshSubItem then
          self.StoreExtendScrollGrid:RefreshSubItem(Index, SubIndex, WidgetItemData)
        end
      end
    end
  end
end
function ClassicStoreUI:RemoveFromShoppingCar(WidgetItemData)
  local GoodID = WidgetItemData.GoodID
  local ExtraDataIndex = WidgetItemData.ExtraData.Index
  if not self.SelectedItemsMap[GoodID] then
    return
  end
  if not self.SelectedItemsMap[GoodID][ExtraDataIndex] then
    return
  end
  self.SelectedItemsMap[GoodID][ExtraDataIndex] = nil
  for SelectedItemsIndex, ItemData in pairs(self.SelectedItemsList) do
    if ItemData.GoodID == GoodID and ExtraDataIndex == ItemData.ExtraData.Index then
      table.remove(self.SelectedItemsList, SelectedItemsIndex)
      break
    end
  end
  self.CurrentCost = self.CurrentCost - WidgetItemData.Handle:GetItemPrice(self, WidgetItemData, true)
  self:UpdateShoppingCarCost()
  self.ShoppingCarScrollBox:SetData(self.SelectedItemsList)
  self:UpdateBuyBtnStatus()
end
function ClassicStoreUI:UpdateItemInfo()
  local SelectedItem = self.CurrentSelectWidgetData
  local ResidentStore_Item_Details_UIBP = self.UIRoot.ResidentStore_Item_Details_UIBP
  if not SelectedItem then
    ResidentStore_Item_Details_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  print(bWriteLog and "ClassicStoreUI:UpdateItemInfo Index:" .. self.CurrentSelectWidgetData.GoodID)
  local GoodID = SelectedItem.GoodID
  local ItemConfig = self:GetTableItemConfig(GoodID)
  ResidentStore_Item_Details_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  local ResidentStore_Item_3_UIBP = ResidentStore_Item_Details_UIBP.ResidentStore_Item_3_UIBP
  if SelectedItem.bDiscount then
    local TempDiscount = SelectedItem.LeftPlayerDiscountCount > 0 and math.floor(SelectedItem.PlayerDiscount * 100) or SelectedItem.Discount
    ResidentStore_Item_3_UIBP.Image_DiscountBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ResidentStore_Item_3_UIBP.Image_DiscountBG:SetBrushfromPathAsync(StoreConfig.DiscountTeammateItemInfoBG, false)
    ResidentStore_Item_3_UIBP.CanvasPanel_Discount:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ResidentStore_Item_3_UIBP.TextBlock_Discount:SetText(string.format("-%d%%", TempDiscount))
  elseif SelectedItem.ExtraData and SelectedItem.ExtraData.TeammatePlayerState then
    ResidentStore_Item_3_UIBP.Image_DiscountBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ResidentStore_Item_3_UIBP.Image_DiscountBG:SetBrushfromPathAsync(StoreConfig.TeammateItemInfoBG, false)
    ResidentStore_Item_3_UIBP.CanvasPanel_Discount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    ResidentStore_Item_3_UIBP.Image_DiscountBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ResidentStore_Item_3_UIBP.CanvasPanel_Discount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local RotatingDiscountVisbility = UEnums.ESlateVisibility.Collapsed
  if ItemConfig and ItemConfig.UpdateDescID ~= 0 then
    RotatingDiscountVisbility = UEnums.ESlateVisibility.SelfHitTestInvisible
    ResidentStore_Item_Details_UIBP.UTRichTextBlock_1:SetText(LocUtil.LocalizeResFormat(ItemConfig.UpdateDescID))
  end
  ResidentStore_Item_Details_UIBP.CanvasPanel_7:SetWidgetVisibility(RotatingDiscountVisbility)
  if not ItemConfig or ItemConfig.DropConfigID == -1 then
    ResidentStore_Item_Details_UIBP.CanvasPanel_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    ResidentStore_Item_Details_UIBP.CanvasPanel_5:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    local DropIDList = {}
    for i = 1, StoreConfig.DesignatedStoreMaxDropItemNum do
      local CurDropItemID = ItemConfig["DropItemID" .. i]
      if CurDropItemID ~= 0 then
        table.insert(DropIDList, CurDropItemID)
      else
        break
      end
    end
    local nItemNum = #DropIDList
    if nItemNum == 0 then
      ResidentStore_Item_Details_UIBP.CanvasPanel_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      for SlotIndex, Slot in pairs(self.AccessoriesSlot) do
        if SlotIndex > nItemNum then
          Slot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        else
          Slot:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
          local nItemID = DropIDList[SlotIndex]
          local ItemRecord = CDataTable.GetTableData("Item", nItemID)
          Slot.Image_Icon:SetBrushfromPathAsync(ItemRecord and ItemRecord.ItemSmallIcon or "", false)
        end
      end
      ResidentStore_Item_Details_UIBP.CanvasPanel_5:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      local AccessoriesDisplayStr = IntlHelper.GetLocalizationStringWithID(StoreConfig.CarryAccessoriesText)
      ResidentStore_Item_Details_UIBP.TextBlock_408:SetText(AccessoriesDisplayStr)
    end
  end
  ResidentStore_Item_Details_UIBP.Text_ItemName:SetText(SelectedItem.Handle:GetItemName(self, SelectedItem))
  ResidentStore_Item_Details_UIBP.UTRichTextBlock_0:SetText(SelectedItem.Handle:GetItemDesc(self, SelectedItem))
  ResidentStore_Item_Details_UIBP.TextBlock_279:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  ResidentStore_Item_Details_UIBP.TextBlock_280:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if SelectedItem.ExtraData and SelectedItem.ExtraData.TeammatePlayerState then
    ResidentStore_Item_3_UIBP.Image_TeammateIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ResidentStore_Item_3_UIBP.TextBlock_PlayerName:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ResidentStore_Item_3_UIBP.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ResidentStore_Item_3_UIBP.Image_TeammateIcon:SetBrushfromPathAsync(SelectedItem.Handle:GetItemIcon(self, SelectedItem), false)
    ResidentStore_Item_3_UIBP.TextBlock_PlayerName:SetText(SelectedItem.Handle:GetPlayerName(self, SelectedItem))
  else
    ResidentStore_Item_3_UIBP.Image_TeammateIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ResidentStore_Item_3_UIBP.TextBlock_PlayerName:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ResidentStore_Item_3_UIBP.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ResidentStore_Item_3_UIBP.Image_Icon:SetBrushfromPathAsync(SelectedItem.Handle:GetItemIcon(self, SelectedItem), false)
  end
  if self:CheckShouldNotify(GoodID) then
    ResidentStore_Item_3_UIBP.Image_New:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    ResidentStore_Item_3_UIBP.Image_New:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local ResidentStore_Item_3_UIBP_Image_TimeLimit = ResidentStore_Item_3_UIBP.Image_TimeLimit
  local ResidentStore_Item_3_UIBP_Image_LimitedBG = ResidentStore_Item_3_UIBP.Image_LimitedBG
  local ResidentStore_Item_3_UIBP_TextBlock_Limited = ResidentStore_Item_3_UIBP.TextBlock_Limited
  if 0 > SelectedItem.BattleLimitCount and 0 > SelectedItem.StoreLimitCount and 0 > SelectedItem.PlayerLimitCount and SelectedItem.TimeLimit == 0 and ItemConfig and ItemConfig.ConditionLimit == 0 then
    ResidentStore_Item_3_UIBP_Image_TimeLimit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ResidentStore_Item_3_UIBP_Image_LimitedBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ResidentStore_Item_3_UIBP_TextBlock_Limited:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local bShouldMarkLimit = false
  if -1 < SelectedItem.BattleLimitCount or -1 < SelectedItem.StoreLimitCount or -1 < SelectedItem.PlayerLimitCount then
    ResidentStore_Item_3_UIBP_Image_TimeLimit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ResidentStore_Item_3_UIBP_Image_LimitedBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ResidentStore_Item_3_UIBP_TextBlock_Limited:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    bShouldMarkLimit = true
  end
  if SelectedItem.TimeLimit ~= 0 then
    ResidentStore_Item_3_UIBP_Image_TimeLimit:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ResidentStore_Item_3_UIBP_Image_LimitedBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ResidentStore_Item_3_UIBP_TextBlock_Limited:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    bShouldMarkLimit = true
  end
  if not bShouldMarkLimit then
    ResidentStore_Item_3_UIBP_Image_TimeLimit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ResidentStore_Item_3_UIBP_Image_LimitedBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    ResidentStore_Item_3_UIBP_TextBlock_Limited:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local ShowStr = ""
  if -1 < SelectedItem.BattleLimitCount then
    ShowStr = self:NormalizedLimitString(ShowStr, LocUtil.LocalizeResFormat(StoreConfig.BattleLimitText, SelectedItem.Handle:GetLeftByBattleLimit(self, SelectedItem), SelectedItem.BattleLimitCount))
  end
  if -1 < SelectedItem.StoreLimitCount then
    ShowStr = self:NormalizedLimitString(ShowStr, LocUtil.LocalizeResFormat(StoreConfig.StoreLimitText, SelectedItem.Handle:GetLeftByStoreLimit(self, SelectedItem), SelectedItem.StoreLimitCount))
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if 0 <= SelectedItem.PlayerLimitCount then
    ShowStr = self:NormalizedLimitString(ShowStr, LocUtil.LocalizeResFormat(StoreConfig.PlayerLimitText, SelectedItem.Handle:GetLeftByPlayerLimit(self, uPlayerController, SelectedItem), SelectedItem.PlayerLimitCount))
  end
  if ItemConfig and ItemConfig.ConditionLimit ~= 0 then
    ShowStr = self:NormalizedLimitString(ShowStr, ItemConfig.ConditionLimit)
  end
  if 0 < SelectedItem.TimeLimit then
    ShowStr = self:NormalizedLimitString(ShowStr, LocUtil.LocalizeResFormat(StoreConfig.TimeLimitText))
    ResidentStore_Item_Details_UIBP.TextBlock_280:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local ResidentStore_Item_Details_UIBP_TextBlock_279 = ResidentStore_Item_Details_UIBP.TextBlock_279
  ResidentStore_Item_Details_UIBP_TextBlock_279:SetText(ShowStr)
  ResidentStore_Item_Details_UIBP_TextBlock_279:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:UpdateCurrentItemInfo()
end
function ClassicStoreUI:GetTableItemConfig(GoodID)
  print(bWriteLog and "ClassicStoreUI:UpdateItemInfo GoodID:" .. self.tStore:GetDataTableName())
  if GoodID == StoreConfig.FriendlyGiftBoxItemId and not FriendlyBehaviorModule.IsEnableFriendlyGiftBox() then
    FormatLog("IsEnableFriendlyGiftBox return false")
    return nil
  end
  local ItemConfig = CDataTable.GetTableData(self.tStore:GetDataTableName(), GoodID)
  return ItemConfig
end
function ClassicStoreUI:NormalizedLimitString(ShowStr, AdditionStr)
  local OutputStr = ""
  if ShowStr == "" then
    OutputStr = ShowStr .. AdditionStr
  else
    OutputStr = ShowStr .. "\n" .. AdditionStr
  end
  return OutputStr
end
function ClassicStoreUI:OnClickStoreItem(Widget, Index, SubIndex, Type)
  print(bWriteLog and "ClassicStoreUI:OnClickStoreItem Subindex:", SubIndex)
  local SelectedItem = self.StoreExtendScrollGrid:GetSubItemData(Index, SubIndex)
  if not SelectedItem then
    return
  end
  self:OnClickItem(Widget, SelectedItem, Index, SubIndex, Type)
end
function ClassicStoreUI:ReSelectWidget(SelectedItemData, Index, SubIndex, Type)
  if self.CurrentSelectWidgetData == SelectedItemData then
    if self.CurrentSelectWidgetData.bSelected then
      self.StoreExtendScrollGrid:RefreshSubItem(self.CurrentSelectIndex, self.CurrentSelectSubIndex, self.CurrentSelectWidgetData)
    end
    return
  end
  if self.CurrentSelectWidgetData then
    self.CurrentSelectWidgetData.bSelected = false
    self.StoreExtendScrollGrid:RefreshSubItem(self.CurrentSelectIndex, self.CurrentSelectSubIndex, self.CurrentSelectWidgetData)
  end
  SelectedItemData.bSelected = true
  print(bWriteLog and "ClassicStoreUI:ReSelectWidget", Index, SubIndex)
  self.StoreExtendScrollGrid:RefreshSubItem(Index, SubIndex, SelectedItemData)
  self.CurrentSelectWidgetData = SelectedItemData
  self.CurrentSelect  self.CurrentSelect  self:UpdateItemInfo()
end
function ClassicStoreUI:OnRefreshShoppingCarItems(widget, index)
  print(bWriteLog and "ClassicStoreUI:OnRefreshShoppingCarItems index:", index)
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  local SelectedItem = self.ShoppingCarScrollBox:GetItemData(index)
  local GoodID = SelectedItem.GoodID
  local ItemNum = self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index]
  if 1 < ItemNum or 1 < SelectedItem.ItemCountPerBuy then
    widget.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    widget.TextBlock_1:SetText(tostring(SelectedItem.ItemCountPerBuy * ItemNum))
  else
    widget.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if GoodID == self.CurrentSelectItemID and SelectedItem.ExtraData.Index == self.CurrentSelectExtraDataIndex and self.CurrentSelectItemOldNum > 0 then
    self:PlayWidgetAnimation(widget, widget.Anim_Change, 0, 1, 0, 1)
  end
  if SelectedItem.ExtraData.TeammatePlayerState then
    widget.Image_TeammateIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_TeammateIcon:SetBrushfromPathAsync(SelectedItem.Handle:GetItemIcon(self, SelectedItem), false)
  else
    widget.Image_TeammateIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_Icon:SetBrushfromPathAsync(SelectedItem.Handle:GetItemIcon(self, SelectedItem), false)
  end
  if SelectedItem.bDiscount then
    widget.Image_DiscountBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_DiscountBG:SetBrushfromPathAsync(StoreConfig.DiscountTeammateItemInfoBG, false)
  elseif SelectedItem.ExtraData.TeammatePlayerState then
    widget.Image_DiscountBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_DiscountBG:SetBrushfromPathAsync(StoreConfig.TeammateItemInfoBG, false)
  else
    widget.Image_DiscountBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ClassicStoreUI:OnClickShoppingCarItem(widget, index)
  print(bWriteLog and "ClassicStoreUI:OnClickShoppingCarItem index:", index)
  local SelectedItem = self.ShoppingCarScrollBox:GetItemData(index)
  if not SelectedItem then
    print(bWriteLog and "ClassicStoreUI:[error] OnClickShoppingCarItem SelectedItem is nil", index)
    return
  end
  local GoodID = SelectedItem.GoodID
  if self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] == nil then
    print(bWriteLog and "ClassicStoreUI:[error] OnClickShoppingCarItem self.SelectedItemsMap[ItemID] == nil", GoodID)
    return
  end
  local Cost = SelectedItem.Handle:GetItemPrice(self, SelectedItem, true)
  if SelectedItem.ItemID == StoreConfig.FriendlyGiftBoxItemId then
    Cost = 0
  end
  self.CurrentCost = self.CurrentCost - Cost
  self:UpdateShoppingCarCost()
  self.CurrentSelectItemID = GoodID
  self.CurrentSelectItemOldNum = self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index]
  if self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] == 1 then
    table.remove(self.SelectedItemsList, index)
    self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] = nil
  else
    self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] = self.SelectedItemsMap[GoodID][SelectedItem.ExtraData.Index] - 1
  end
  self.ShoppingCarScrollBox:SetData(self.SelectedItemsList)
  self:UpdateBuyBtnStatus()
  self:RefreshStoreItemsByClick()
end
function ClassicStoreUI:UpdateTimeOutItems()
  self:RefreshStoreItems()
  self:RefreshStoreItemsByClick()
end
function ClassicStoreUI:UpdateCurrentItemInfo()
  if not self.TimeLimitIndexMap[self.CurrentSelectIndex] then
    return
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not self.TimeLimitIndexMap[self.CurrentSelectIndex][self.CurrentSelectSubIndex] then
    return
  end
  local SelectedItem = self.StoreExtendScrollGrid:GetSubItemData(self.CurrentSelectIndex, self.CurrentSelectSubIndex)
  if SelectedItem.TimeLimit == 0 then
    return
  end
  local StartFlyTime = 0 < uGameState.StartFlyTime and uGameState.StartFlyTime or 60
  local LeftTime = math.floor(math.abs(SelectedItem.TimeLimit) + StartFlyTime - uGameState:GetServerWorldTimeSeconds())
  if LeftTime < 0 then
    LeftTime = 0
  end
  local LeftTimeString = TimeUtil.FormatCountDownTime_HMS(LeftTime, true)
  print(bWriteLog and "ClassicStoreUI:UpdateCurrentItemInfo ", LeftTimeString, " : ", LeftTime)
  self.UIRoot.ResidentStore_Item_Details_UIBP.TextBlock_280:SetText(LeftTimeString)
end
function ClassicStoreUI:RefreshTimeOutItems()
  self:UpdateTimeOutItems()
  self:UpdateCurrentItemInfo()
  self:CheckShowBuyTeammateLifeTime()
  self:CheckTeammateAvalible()
  self:RefreshStoreLimitTime()
  if self.bNeedBezel and self.bHasBezel and self.bHasShowBezelAnim and slua.isValid(self.CurrentBezelWidget) then
    self.CurrentBezelWidget:StopAnimation(self.CurrentBezelWidget.Anim_Newest)
  end
  if self.bNeedGunLock and self.bHasGunLock and self.bHasShowGunLockAnim and slua.isValid(self.CurrentGunLockWidget) then
    self.CurrentGunLockWidget:StopAnimation(self.CurrentGunLockWidget.Anim_Newest)
  end
  if self.bNeedTacticalAttach and self.bHasTacticalAttach and self.bHasShowTacticalAttachAnim and slua.isValid(self.CurrentTacticalAttachWidget) then
    self.CurrentTacticalAttachWidget:StopAnimation(self.CurrentTacticalAttachWidget.Anim_Newest)
  end
end
function ClassicStoreUI:OnAndroidBack()
  print(bWriteLog and "ClassicStoreUI:AndroidBack")
  self:OnClicked_Leave()
end
function ClassicStoreUI:GetTeamMatePlayerStateList()
  if not self.TeamMatePlayerStateList then
    local uCurPlayerState = GameplayData.GetPlayerState()
    self.TeamMatePlayerStateList = uCurPlayerState:GetTeamMatePlayerStateList({}, true)
  end
  return self.TeamMatePlayerStateList
end
function ClassicStoreUI:OnTeammateLiveStateChanged(EventType, EventID, TeammateIndex, LiveState)
  if not self.bShouldShowTeammateBuyLife then
    return
  end
  self:CheckTeammateAvalible()
end
function ClassicStoreUI:CheckTeammateAvalible()
  if not self.bShouldShowTeammateBuyLife then
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not Game:IsValid(uGameState) then
    return
  end
  print(bWriteLog and "ClassicStoreUI:CheckTeammateAvalible")
  local ShouldShowTeammate = {}
  if not self.BuyTeammateLifeTimeOut then
    for Index, Val in pairsByKeys(self.TeammateData) do
      local TeammatePlayerState = Val.ExtraData.TeammatePlayerState
      if TeammatePlayerState.LiveState == EExtraPlayerLiveState.InDied then
        print(bWriteLog and "ClassicStoreUI:CheckTeammateAvalible LiveState InDied Index:" .. Index)
        if TeammatePlayerState:GetLeftBuyLifeCounts() > 0 then
          print(bWriteLog and "ClassicStoreUI:CheckTeammateAvalible LiveState GetLeftBuyLifeCounts > 0 Index:" .. Index)
          local CurrentTime = uGameState:GetServerWorldTimeSeconds()
          if TeammatePlayerState.GetDiedTime and CurrentTime > TeammatePlayerState:GetDiedTime() + StoreConfig.DisabledTimeAfterDied then
            print(bWriteLog and "ClassicStoreUI:CheckTeammateAvalible LiveState CurrentTime > GetDiedTime + DisabledTimeAfterDied Index:" .. Index)
            ShouldShowTeammate[Val.ExtraData.Index] = true
          end
        end
      end
    end
  end
  if ShouldShowTeammate and next(ShouldShowTeammate) and not TableUtil.IsDataEqual(ShouldShowTeammate, self.DeadTeammateMap) then
    local ShowTeammateData = {}
    for Index, _ in pairs(ShouldShowTeammate) do
      table.insert(ShowTeammateData, self.TeammateData[Index])
    end
    if self.CurrentSelectIndex == 1 and self.CurrentSelectWidgetData then
      self.CurrentSelectWidgetData.bSelected = false
    end
    self.StoreExtendScrollGrid:SetSubData(1, ShowTeammateData, StoreConfig.BuyTeammateLifeType)
    self:RefreshStoreItemsByClick()
    for Index, _ in pairs(self.DeadTeammateMap) do
      if not ShouldShowTeammate[Index] and self.SelectedItemsMap[self.BuyTeammateLifeGoodID] and self.SelectedItemsMap[self.BuyTeammateLifeGoodID][Index] then
        self:RemoveFromShoppingCar(self.TeammateData[Index])
      end
    end
    if self.CurrentSelectIndex == 1 and self.CurrentSelectWidgetData then
      self.CurrentSelectWidgetData = self.StoreExtendScrollGrid:GetSubItemData(1, 1)
      self.CurrentSelectIndex = 1
      self.CurrentSelectSubIndex = 1
      self.CurrentSelectWidgetData.bSelected = true
      self.StoreExtendScrollGrid:RefreshSubItem(self.CurrentSelectIndex, self.CurrentSelectSubIndex, self.CurrentSelectWidgetData)
      self:UpdateItemInfo()
    end
    self.DeadTeammateMap = TableUtil.CopyTable(ShouldShowTeammate)
  elseif (not ShouldShowTeammate or not next(ShouldShowTeammate)) and self.DeadTeammateMap and next(self.DeadTeammateMap) and 0 < #self.DeadTeammateMap then
    for Index, _ in pairs(self.DeadTeammateMap) do
      if self.SelectedItemsMap[self.BuyTeammateLifeGoodID] and self.SelectedItemsMap[self.BuyTeammateLifeGoodID][Index] then
        self:RemoveFromShoppingCar(self.TeammateData[Index])
      end
    end
    self.StoreExtendScrollGrid:SetSubData(1, self.EmptyTeammateData, StoreConfig.BuyTeammateEmptyType)
    self:RefreshStoreItemsByClick()
    self.DeadTeammateMap = {}
    if self.CurrentSelectIndex == 1 and self.CurrentSelectWidgetData then
      self.CurrentSelectWidgetData = self.StoreExtendScrollGrid:GetSubItemData(2, 1)
      self.CurrentSelectIndex = 2
      self.CurrentSelectSubIndex = 1
      self.CurrentSelectWidgetData.bSelected = true
      self.StoreExtendScrollGrid:RefreshSubItem(self.CurrentSelectIndex, self.CurrentSelectSubIndex, self.CurrentSelectWidgetData)
      self:UpdateItemInfo()
    end
  end
end
function ClassicStoreUI:CheckShowBuyTeammateLifeTime()
  if not self.bShouldShowTeammateBuyLife then
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not Game:IsValid(uGameState) then
    return
  end
  local FirstWidgetData = self.StoreExtendScrollGrid:GetSubItemData(1, 1)
  if not FirstWidgetData.Empty and not FirstWidgetData.ExtraData.TeammatePlayerState then
    return
  end
  local ReviveDisableTime = uGameState:GetReviveEndTime()
  local FirstTitleWidgetData = TableUtil.CopyTable(self.StoreExtendScrollGrid:GetItemData(1))
  local LeftTime = ReviveDisableTime - uGameState:GetServerWorldTimeSeconds()
  if 0 < LeftTime then
    FirstTitleWidgetData.TimeString = TimeUtil.FormatCountDownTime_MS(LeftTime)
  else
    self.BuyTeammateLifeTimeOut = true
    FirstTitleWidgetData.TimeString = IntlHelper.GetLocalizationStringWithID(30811)
  end
  self.StoreExtendScrollGrid:RefreshItem(1, FirstTitleWidgetData)
end
function ClassicStoreUI:PlayAudioAsync(AudioPath)
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(AudioPath, function(AkEvent)
    if AkEvent then
      local AkGameplayStatics = import("AkGameplayStatics")
      local ZeroLocation = FVector(0, 0, 0)
      local ZeroRotator = FRotator(0, 0, 0)
      AkGameplayStatics.PostEventAtLocation(AkEvent, ZeroLocation, ZeroRotator, "", self.UIRoot)
    else
      print(bWriteLog and "ClassicStoreUI:PlayAudioAsync Failed to load the sound asset")
    end
  end)
end
function ClassicStoreUI:RefreshStoreLimitTime()
  local nLeftTime = LogicClassicStore.GetStoreLimitTime(self.tStore)
  if nLeftTime then
    self.UIRoot.TextBlock_Time:SetText(TimeUtil.FormatCountDownTime_MS(nLeftTime, true))
  end
end
function ClassicStoreUI:CheckNeedBezelAndGunLockAndTacticalAttach()
  return LogicClassicStore.CheckNeedBezelAndGunLockAndTacticalAttach()
end
function ClassicStoreUI:OnClose()
  self.AccessoriesSlot = nil
  self:ClearData()
  if self.StoreExtendScrollGrid then
    self.StoreExtendScrollGrid:Close()
    self.StoreExtendScrollGrid = nil
  end
  ClassicStoreUI.__super.OnClose(self)
end
function ClassicStoreUI:OnFriendlyPointsCurrValueChanged(_, _, nPlayerKey, nValue)
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    FormatLog("Invalid uPlayerState")
    return
  end
  FormatLog("OnFriendlyPointsCurrValueChanged nPlayerKey[%d], nValue[%d]", nPlayerKey, nValue)
  if nPlayerKey == uPlayerState.PlayerKey then
    self:UpdateFriendlyUI()
    FormatLog("[%u][%s] OnFriendlyPointsCurrValueChanged UpdateUI finished", uPlayerState.PlayerKey, uPlayerState.PlayerName)
  end
end
function ClassicStoreUI:OnFriendlyUsesCountThisGameChanged(_, _, nPlayerKey, nValue)
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    FormatLog("Invalid uPlayerState")
    return
  end
  FormatLog("OnFriendlyUsesCountThisGameChanged nPlayerKey[%d], nValue[%d]", nPlayerKey, nValue)
  if nPlayerKey == uPlayerState.PlayerKey then
    self:UpdateFriendlyUI()
    FormatLog("[%u][%s] OnFriendlyUsesCountThisGameChanged UpdateUI finished", uPlayerState.PlayerKey, uPlayerState.PlayerName)
  end
end
function ClassicStoreUI:UpdateFriendlyUI()
  local tData = FriendlyBehaviorModule.GetFriendlyDataClient()
  if not tData then
    return
  end
end
function ClassicStoreUI:CanBuyFriendlyGiftBox()
  local tData = FriendlyBehaviorModule.GetFriendlyDataClient()
  if not tData then
    return false
  end
  if tData.FriendlyPointsCurrValue < 100 then
    return false
  end
  if tData.FriendlyUsesCountThisGame >= 1 then
    return false
  end
  return true
end
function ClassicStoreUI:OnClicked_Question()
  local TipsParam = {
    widget = self.UIRoot.Button_Question,
    title = LocUtil.GetLocalizeResStr(StoreConfig.RandomEventConfig.QuestionTipTitleID),
    content = LocUtil.GetLocalizeResStr(StoreConfig.RandomEventConfig.QuestionTipTextID)
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, TipsParam)
end
function ClassicStoreUI:OnClicked_AdvancedWeaponTicket()
  local TipsParam = {
    widget = self.UIRoot.Button_AdvancedWeaponTicket,
    content = LocUtil.GetLocalizeResStr(StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.StoreTipTextID)
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, TipsParam)
end
function ClassicStoreUI:OnClicked_ReviveTicket()
  local TipsParam = {
    widget = self.UIRoot.Button_ReviveTicket,
    content = LocUtil.GetLocalizeResStr(StoreConfig.ExchangeTicketConfig.ReviveTicket.StoreTipTextID)
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, TipsParam)
end
function ClassicStoreUI:CheckShowQuestionTip()
  self:LoadFirstOpenData()
  if self.bIsFirstOpen and not self.bDisableCrit and slua.isValid(self.UIRoot.Button_Question) then
    self:OnClicked_Question()
    self:SaveFirstOpenData()
    self.bIsFirstOpen = false
  end
end
function ClassicStoreUI:LoadFirstOpenData()
  local Playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local ePlayerStoreFirstOpen = Playerprefs.LoadFileToTable_N(Playerprefs.ePlayerPrefsType.ePlayerStoreFirstOpen)
  self.bIsFirstOpen = (ePlayerStoreFirstOpen and ePlayerStoreFirstOpen.bIsFirstOpen) == nil
  print(bWriteLog and "ClassicStoreUI:LoadFirstOpenData bIsFirstOpen: " .. tostring(self.bIsFirstOpen))
end
function ClassicStoreUI:SaveFirstOpenData()
  local Playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  Playerprefs.SaveTableToFile_N({bIsFirstOpen = false}, Playerprefs.ePlayerPrefsType.ePlayerStoreFirstOpen)
  print(bWriteLog and "ClassicStoreUI:SaveFirstOpenData bIsFirstOpen saved as false")
end
function ClassicStoreUI:CheckGifBoxItemType()
  print(bWriteLog and "ClassicStoreUI:CheckGifBoxItemType [1] Start checking gift box items")
  if not self.StoreExtendScrollGrid then
    print(bWriteLog and "ClassicStoreUI:CheckGifBoxItemType [2] StoreExtendScrollGrid is nil, return")
    return
  end
  local bHasAdvancedWeaponGiftBox = false
  local bHasReviveGiftBox = false
  for Index = 1, self.StoreExtendScrollGrid:GetItemCount() do
    local SubItemList = self.StoreExtendScrollGrid:GetSubItemList(Index)
    if SubItemList then
      local bHasGiftBoxItem = false
      for SubIndex, WidgetItemData in pairs(SubItemList) do
        if WidgetItemData then
          local bIsGiftBoxItem = false
          if WidgetItemData.ItemID == StoreConfig.FriendlyGiftBoxItemId or WidgetItemData.GoodID == StoreConfig.FriendlyGiftBoxItemId then
            bIsGiftBoxItem = true
            print(bWriteLog and "ClassicStoreUI:CheckGifBoxItemType [3] Found friendly gift box")
          else
            for TicketType, Config in pairs(StoreConfig.ExchangeTicketConfig) do
              if WidgetItemData.GoodID == Config.GiftBoxItemID or WidgetItemData.ItemID == Config.GiftBoxItemID then
                bIsGiftBoxItem = true
                print(bWriteLog and "ClassicStoreUI:CheckGifBoxItemType [4] Found exchange ticket gift box, TicketType:" .. tostring(TicketType))
                if TicketType == "AdvancedWeaponTicket" then
                  bHasAdvancedWeaponGiftBox = true
                  break
                end
                if TicketType == "ReviveTicket" then
                  bHasReviveGiftBox = true
                end
                break
              end
            end
          end
          if bIsGiftBoxItem then
            bHasGiftBoxItem = true
          end
        end
      end
      if bHasGiftBoxItem then
        self.StoreExtendScrollGrid:SetSubData(Index, SubItemList, StoreConfig.GiftBoxType)
        print(bWriteLog and "ClassicStoreUI:CheckGifBoxItemType [5] Set gift box category type, Index:" .. tostring(Index))
      end
    end
  end
  if self.UIRoot.Button_AdvancedWeaponTicket then
    local Visibility = bHasAdvancedWeaponGiftBox and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed
    self.UIRoot.Button_AdvancedWeaponTicket:SetWidgetVisibility(Visibility)
  end
  if self.UIRoot.Button_ReviveTicket then
    local Visibility = bHasReviveGiftBox and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed
    self.UIRoot.Button_ReviveTicket:SetWidgetVisibility(Visibility)
  end
  print(bWriteLog and "ClassicStoreUI:CheckGifBoxItemType [6] Finish checking gift box items")
end
function ClassicStoreUI:SetGiftBoxPriceDisplay(Widget, WidgetItemData)
  print(bWriteLog and "ClassicStoreUI:SetGiftBoxPriceDisplay [1] Setting price display for ItemID:" .. tostring(WidgetItemData.ItemID))
  if not (Widget and WidgetItemData) or not Widget.WidgetSwitcher_0 then
    print(bWriteLog and "ClassicStoreUI:SetGiftBoxPriceDisplay [2] Invalid Widget or WidgetItemData or missing WidgetSwitcher_0")
    return
  end
  local bIsSoldOut = WidgetItemData.bAlreadySoldOut
  if bIsSoldOut then
    Widget.WidgetSwitcher_0:SetActiveWidgetIndex(2)
    print(bWriteLog and "ClassicStoreUI:SetGiftBoxPriceDisplay [3] Set to sold out display")
    return
  end
  local ItemPrice = WidgetItemData.Handle:GetItemPrice(self, WidgetItemData)
  print(bWriteLog and "ClassicStoreUI:SetGiftBoxPriceDisplay [4] Item price:" .. tostring(ItemPrice))
  if ItemPrice <= 0 then
    Widget.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    print(bWriteLog and "ClassicStoreUI:SetGiftBoxPriceDisplay [5] Set to free display")
  else
    Widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    if Widget.TextBlock_1 then
      Widget.TextBlock_1:SetText(tostring(ItemPrice))
      print(bWriteLog and "ClassicStoreUI:SetGiftBoxPriceDisplay [6] Set price text:" .. tostring(ItemPrice))
    end
    print(bWriteLog and "ClassicStoreUI:SetGiftBoxPriceDisplay [7] Set to price display")
  end
end
function ClassicStoreUI:CheckAndPlayGiftBoxAnimation(Widget, WidgetItemData)
  if not Widget or not WidgetItemData then
    return false
  end
  local bIsGiftBoxItem = false
  local bCanExchange = false
  local GiftBoxItemID = 0
  if WidgetItemData.ItemID == StoreConfig.FriendlyGiftBoxItemId or WidgetItemData.GoodID == StoreConfig.FriendlyGiftBoxItemId then
    bIsGiftBoxItem = true
    GiftBoxItemID = StoreConfig.FriendlyGiftBoxItemId
    bCanExchange = not WidgetItemData.bCannotAfford and not WidgetItemData.bSoldOut and not (0 <= WidgetItemData.UnlockTime)
    print(bWriteLog and "ClassicStoreUI:CheckAndPlayGiftBoxAnimation [1] Found friendly gift box, CanExchange:" .. tostring(bCanExchange))
  else
    for TicketType, Config in pairs(StoreConfig.ExchangeTicketConfig) do
      if WidgetItemData.GoodID == Config.GiftBoxItemID or WidgetItemData.ItemID == Config.GiftBoxItemID then
        bIsGiftBoxItem = true
        GiftBoxItemID = Config.GiftBoxItemID
        bCanExchange = not WidgetItemData.bCannotAfford and not WidgetItemData.bSoldOut and not (0 <= WidgetItemData.UnlockTime)
        print(bWriteLog and "ClassicStoreUI:CheckAndPlayGiftBoxAnimation [2] Found exchange ticket gift box, TicketType:" .. tostring(TicketType) .. ", CanExchange:" .. tostring(bCanExchange))
        break
      end
    end
  end
  if bIsGiftBoxItem and bCanExchange and not self.GiftBoxAnimMap[GiftBoxItemID] then
    if Widget.Anim_Glow then
      Widget.Image_FlowLight:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
      Widget:PlayUserWidgetAnimation(Widget.Anim_Glow, 0, 1, 0, 1)
      self.GiftBoxAnimMap[GiftBoxItemID] = true
      print(bWriteLog and "ClassicStoreUI:CheckAndPlayGiftBoxAnimation [3] Anim_Glow animation played successfully for ItemID:" .. tostring(WidgetItemData.ItemID))
    else
      print(bWriteLog and "ClassicStoreUI:CheckAndPlayGiftBoxAnimation [4] Warning: Anim_Glow animation not found in Widget")
    end
    return true
  end
  return false
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, ClassicStoreUI)