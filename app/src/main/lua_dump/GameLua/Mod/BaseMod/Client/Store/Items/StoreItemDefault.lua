local StoreItemDefault = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local StoreConfig = GamePlayTools.GetCurrentConfig("StoreConfig")
function StoreItemDefault:ctor()
  StoreItemDefault.__super.ctor(self)
end
function StoreItemDefault:OnRefresh(Widget, Data, Index, SubIndex, Type)
  if not Widget or not Data then
    return
  end
  local StoreUI = self:GetStoreUI()
  if not StoreUI then
    print(bWriteLog and "StoreItemDefault:OnRefresh [1] StoreUI is nil")
    return
  end
  self.  self.  self.  local CustomConfig = self:GetCustomDisplayConfig(Data)
  if CustomConfig and CustomConfig.UIConfigKey then
    local bSuccess = self:ShowCustomDisplay(Widget, Data, CustomConfig.UIConfigKey, StoreUI)
    if bSuccess then
      return
    end
  end
  self:ShowDefaultDisplay(Widget)
  self:OnRefreshCurrentWidget(Widget, Data, StoreUI)
end
function StoreItemDefault:GetCustomDisplayConfig(Data)
  if not Data then
    return nil
  end
  if Data.ItemID and StoreConfig.CustomItemDisplayConfig[self.StoreID] then
    local ConfigByItemID = StoreConfig.CustomItemDisplayConfig[self.StoreID][Data.ItemID]
    if ConfigByItemID then
      return ConfigByItemID
    end
  end
  if Data.ConfigItemType and StoreConfig.CustomItemDisplayConfigByType[self.StoreID] then
    local ConfigByType = StoreConfig.CustomItemDisplayConfigByType[self.StoreID][Data.ConfigItemType]
    if ConfigByType then
      return ConfigByType
    end
  end
  return nil
end
function StoreItemDefault:OnRefreshCurrentWidget(Widget, Data, StoreUI)
  if not (Widget and Data) or not StoreUI then
    return
  end
  if Data.Empty then
    self:RefreshEmptyTeammate(Widget, Data, StoreUI)
    return
  end
  StoreUI:SetWidgetData(Widget, Data, self.Index, self.SubIndex)
  if self.Type == StoreConfig.BuyItemType or self.Type == StoreConfig.BuyItemDropListType or self.Type == StoreConfig.ExchangeItemType or self.Type == StoreConfig.CustomScriptItemType then
    self:RefreshBuyItem(Widget, Data, StoreUI)
  elseif self.Type == StoreConfig.BuyTeammateLifeType then
    self:RefreshTeammateLife(Widget, Data, StoreUI)
  elseif self.Type == StoreConfig.GiftBoxType then
    self:RefreshGiftBox(Widget, Data, StoreUI)
  end
  self:SetCommonProperties(Widget, Data, self.Index, self.SubIndex, StoreUI)
end
function StoreItemDefault:RefreshEmptyTeammate(Widget, Data, StoreUI)
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGameState) or not Widget.TextBlock_Name then
    return
  end
  local ReviveDisableTime = uGameState:GetReviveEndTime()
  local LeftTime = ReviveDisableTime - uGameState:GetServerWorldTimeSeconds()
  if 0 < LeftTime then
    Widget.TextBlock_Name:SetText(LocUtil.LocalizeResFormat(30806))
  else
    Widget.TextBlock_Name:SetText(LocUtil.LocalizeResFormat(30802))
  end
end
function StoreItemDefault:RefreshBuyItem(Widget, Data, StoreUI)
  Widget.Image_FlowLight:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  local ItemIcon = Data.Handle:GetItemIcon(StoreUI, Data)
  Widget.Image_Icon:SetBrushfromPathAsync(ItemIcon, false)
  self:HandleSpecialItemAnim(Widget, Data, StoreUI)
end
function StoreItemDefault:HandleSpecialItemAnim(Widget, Data, StoreUI)
  if StoreUI.bNeedBezel and Data.ItemID == StoreConfig.BezelItemID and not StoreUI.bHasShowBezelAnim then
    self:ShowItemFlowLightAnim(Widget, StoreUI, "Bezel")
  elseif StoreUI.bNeedGunLock and Data.ItemID == StoreConfig.GunLockItemID and not StoreUI.bHasShowGunLockAnim then
    self:ShowItemFlowLightAnim(Widget, StoreUI, "GunLock")
  elseif StoreUI.bNeedTacticalAttach and Data.ItemID == StoreConfig.TacticalAttachItemID and not StoreUI.bHasShowTacticalAttachAnim then
    self:ShowItemFlowLightAnim(Widget, StoreUI, "TacticalAttach")
  end
end
function StoreItemDefault:ShowItemFlowLightAnim(Widget, StoreUI, AnimType)
  Widget.Image_FlowLight:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
  Widget:PlayUserWidgetAnimation(Widget.Anim_Newest, 0, 0, 0, 1)
  local TimerKey = "Show" .. AnimType .. "AnimTimer"
  local WidgetKey = "Current" .. AnimType .. "Widget"
  local FlagKey = "bHasShow" .. AnimType .. "Anim"
  StoreUI[WidgetKey] = Widget
  if not StoreUI[TimerKey] then
    StoreUI[TimerKey] = StoreUI:AddGameTimer(StoreConfig.nStorePanelBezelAnimShowTime, false, function()
      StoreUI[FlagKey] = true
      StoreUI[TimerKey] = nil
      if slua.isValid(Widget) then
        Widget:StopAnimation(Widget.Anim_Newest)
      end
    end)
  end
end
function StoreItemDefault:RefreshTeammateLife(Widget, Data, StoreUI)
  if Data.bDiscount then
    self:RefreshDiscountTeammate(Widget, Data, StoreUI)
  else
    self:RefreshNormalTeammate(Widget, Data, StoreUI)
  end
end
function StoreItemDefault:RefreshDiscountTeammate(Widget, Data, StoreUI)
  local TempDiscount = Data.LeftPlayerDiscountCount > 0 and math.floor(Data.PlayerDiscount * 100) or Data.Discount
  if 0 < TempDiscount then
    Widget.CanvasPanel_Discount:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    Widget.TextBlock_Discount:SetText(string.format("-%d%%", TempDiscount))
    Widget.CanvasPanel_OriginalPrice:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    Widget.TextBlock_OriginalPrice:SetText(tostring(Data.Price))
  else
    Widget.CanvasPanel_Discount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    Widget.CanvasPanel_OriginalPrice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local ItemBigIcon, bHasAddKnownMissing = Data.Handle:GetItemBigIcon(StoreUI, Data)
  local Params = {
    sync = false,
    bHasAddKnownMissing = bHasAddKnownMissing,
    bMatchSize = true
  }
  local ItemType = Data.Handle:GetItemType(StoreUI, Data)
  if ItemBigIcon ~= "" and ItemType == 1 then
    StoreUI:SetTexture(Widget.Image_ItemIcon, ItemBigIcon, Params)
    Widget.Image_ItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    Widget.Image_ItemSmall:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    local ItemIcon = Data.Handle:GetItemIcon(StoreUI, Data)
    Widget.Image_ItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    Widget.Image_ItemSmall:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    Widget.Image_ItemSmall:SetBrushfromPathAsync(ItemIcon, false)
  end
  if Data.PlayerLimitCount > -1 then
    Widget.UTRichTextBlock_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    Widget.UTRichTextBlock_0:SetText(string.format("%d/%d", Data.PlayerLimitCount - Data.Handle:GetLeftByPlayerLimit(StoreUI, uPlayerController, Data), Data.PlayerLimitCount))
  else
    Widget.UTRichTextBlock_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  Widget.Image_BG:SetBrushfromPathAsync(StoreConfig.DiscountTeammateItemBG, false)
  Widget.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if Widget.TextBlock_Name then
    Widget.TextBlock_Name:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function StoreItemDefault:RefreshNormalTeammate(Widget, Data, StoreUI)
  Widget.CanvasPanel_Discount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  Widget.CanvasPanel_OriginalPrice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  Widget.Image_ItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  Widget.Image_ItemSmall:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  Widget.UTRichTextBlock_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  Widget.Image_BG:SetBrushfromPathAsync(StoreConfig.TeammateItemBG, false)
  local ItemIcon = Data.Handle:GetItemIcon(StoreUI, Data)
  Widget.Image_Icon:SetBrushfromPathAsync(ItemIcon, false)
  Widget.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if Widget.TextBlock_Name then
    Widget.TextBlock_Name:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    Widget.TextBlock_Name:SetText(Data.Handle:GetPlayerName(StoreUI, Data))
  end
end
function StoreItemDefault:RefreshGiftBox(Widget, Data, StoreUI)
  Widget.Image_FlowLight:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  local ItemIcon = Data.Handle:GetItemIcon(StoreUI, Data)
  Widget.Image_Icon:SetBrushfromPathAsync(ItemIcon, false)
  StoreUI:CheckAndPlayGiftBoxAnimation(Widget, Data)
  StoreUI:SetGiftBoxPriceDisplay(Widget, Data)
end
function StoreItemDefault:SetCommonProperties(Widget, Data, Index, SubIndex, StoreUI)
  if not Data or not Data.GoodID then
    return
  end
  local GoodBuyType = StoreUI:GetGoodBuyTypeByID(Data.GoodID)
  if GoodBuyType == StoreConfig.ExchangeTicketType then
    print(bWriteLog and "StoreItemDefault:SetCommonProperties [1] Check gift box exchange ticket icon, GoodID:" .. tostring(Data.GoodID))
    local Handle = require(StoreConfig.ExchangeTicketHandle)
    local TicketConfig = Handle:GetTicketConfigByGoodID(Data.GoodID)
    local TicketItemID = TicketConfig and TicketConfig.TicketItemID or 0
    if 0 < TicketItemID then
      if TicketItemID == StoreConfig.ExchangeTicketConfig.ReviveTicket.TicketItemID then
        Widget.Image_333:SetBrushfromPathAsync(StoreUI.sRiviveTicketPath, false)
      elseif TicketItemID == StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TicketItemID then
        Widget.Image_333:SetBrushfromPathAsync(StoreUI.sAdvancedWeaponTicketPath, false)
      end
    end
  else
    Widget.Image_333:SetBrushfromPathAsync("/Game/Arts/UI/NoAtlas/ResidentStore/CommodityCurrency_Icon.CommodityCurrency_Icon", false)
  end
  if Data.UpdateDescID and Data.UpdateDescID ~= 0 then
    if Widget.CanvasPanel_3 then
      Widget.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif Widget.CanvasPanel_3 then
    Widget.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if Data.bRotatingDiscount then
    Widget.TextBlock_OriginalPrice:SetText(tostring(Data.Price))
    Widget.CanvasPanel_OriginalPrice:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    Widget.CanvasPanel_OriginalPrice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if Widget.TextBlock_0 then
    local Name = Data.Handle:GetItemName(StoreUI, Data)
    Widget.TextBlock_0:SetText(Name)
  end
  if Widget.limit then
    local Limit = ""
    local bHasLimit = false
    if Data.BattleLimitCount > -1 then
      local LeftCount = Data.Handle:GetLeftByBattleLimit(StoreUI, Data)
      Limit = LocUtil.LocalizeResFormat(StoreConfig.BattleLimitText, LeftCount, Data.BattleLimitCount)
      bHasLimit = true
    end
    if -1 < Data.StoreLimitCount then
      local LeftCount = Data.Handle:GetLeftByStoreLimit(StoreUI, Data)
      local StoreLimitText = LocUtil.LocalizeResFormat(StoreConfig.StoreLimitText, LeftCount, Data.StoreLimitCount)
      if bHasLimit then
        Limit = Limit .. "\n" .. StoreLimitText
      else
        Limit = StoreLimitText
        bHasLimit = true
      end
    end
    if -1 < Data.PlayerLimitCount then
      local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
      local LeftCount = Data.Handle:GetLeftByPlayerLimit(StoreUI, uPlayerController, Data)
      local PlayerLimitText = LocUtil.LocalizeResFormat(StoreConfig.PlayerLimitText, LeftCount, Data.PlayerLimitCount)
      if bHasLimit then
        Limit = Limit .. "\n" .. PlayerLimitText
      else
        Limit = PlayerLimitText
        bHasLimit = true
      end
    end
    if 0 < Data.TimeLimit then
      local TimeLimitText = LocUtil.LocalizeResFormat(StoreConfig.TimeLimitText)
      if bHasLimit then
        Limit = Limit .. "\n" .. TimeLimitText
      else
        Limit = TimeLimitText
        bHasLimit = true
      end
    end
    if bHasLimit then
      Widget.limit:SetText(Limit)
      Widget.limit:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      Widget.limit:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
local class = require("class")
local StoreItemBase = require("GameLua.Mod.BaseMod.Client.Store.Items.StoreItemBase")
local CStoreItemDefault = class(StoreItemBase, nil, StoreItemDefault)
return CStoreItemDefault