local PlayerInfoCardBaseUI = {}
local BackpackUtils = import("BackpackUtils")
local EAvatarSlotType = import("EAvatarSlotType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function PlayerInfoCardBaseUI:ctor(_, OnCloseCallback)
  self.IngameCurItemId = nil
  self.CurrentSelectedItemID = nil
  self.CurrentSelectedSlotType = nil
  self.OnClickCloseButtonCallback = nil
  self.  self.CurrentEquipWearItemIndex = 1
  self.CurrentEquipBattleItemIndex = 1
  self.NotFavouriteItems = {
    [403702] = true
  }
  self.ChildrenWidgets = {}
  self.AlreadyAddFriend = {}
  self.PlayerInfoBattleItemArray = {
    "EquipmentMenu1",
    "EquipmentMenu2",
    "EquipmentMenu3",
    "EquipmentMenu4",
    "EquipmentMenu5",
    "EquipmentMenu6"
  }
  self.PlayerInfoWearItemArray = {
    "EquipmentMenu7",
    "EquipmentMenu8",
    "EquipmentMenu9",
    "EquipmentMenu10",
    "EquipmentMenu11",
    "EquipmentMenu12",
    "EquipmentMenu13",
    "EquipmentMenu14"
  }
  self.BattleItemSlotOrder = {
    EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot,
    EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot
  }
  self.AvatarItemSlotOrder = {
    EAvatarSlotType.EAvatarSlotType_HatEquipemtSlot,
    EAvatarSlotType.EAvatarSlotType_GlassEquipemtSlot,
    EAvatarSlotType.EAvatarSlotType_FaceEquipemtSlot,
    EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot,
    EAvatarSlotType.EAvatarSlotType_PantsEquipemtSlot,
    EAvatarSlotType.EAvatarSlotType_ShoesEquipemtSlot,
    EAvatarSlotType.EAvatarSlotType_BackPack_PendantSlot,
    EAvatarSlotType.EAvatarSlotType_HandleEquipmentSlot
  }
  local OBConfig = GamePlayTools.GetCurrentConfig("OBConfig")
  self.IgnoreItemIDs = {}
  if OBConfig and OBConfig.PlayerInfoCardConfig then
    for _, ID in ipairs(OBConfig.PlayerInfoCardConfig.IgnoreItemIDs) do
      self.IgnoreItemIDs[ID] = true
    end
  end
end
function PlayerInfoCardBaseUI:OnInitialize()
  PlayerInfoCardBaseUI.__super.OnInitialize(self)
  self:InitPlayerInfoItems()
end
function PlayerInfoCardBaseUI:RegistEvents()
  PlayerInfoCardBaseUI.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnClickCloseButton, self)
  self:AddControlEventByControl(self.UIRoot.Button_AddFriend, "OnClicked", self.OnClickedAddFriendButton, self)
  self:AddControlEventByControl(self.UIRoot.Button_AddFavourite, "OnClicked", self.OnClickedAddFavouriteButton, self)
  self:AddControlEventByControl(self.UIRoot.SendGifts, "OnClicked", self.OnClickedSendGifts, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, self.InitCollectButtonByItemID, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ON_MONSTERID_CHANGE, self.OnPlayerMonsterChange, self)
end
function PlayerInfoCardBaseUI:OnShow()
  print(bWriteLog and "PlayerInfoCardBaseUI:OnShow")
  Client.RequireSlateTickEveryFrame(SlateUI_ID.PLAYERINFO_CARD)
  self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
end
function PlayerInfoCardBaseUI:GetPlayerName()
  return nil
end
function PlayerInfoCardBaseUI:SetCombatTotalInfo()
  self:SetCombatMatchMode()
end
function PlayerInfoCardBaseUI:GetBattleMode()
  return nil
end
function PlayerInfoCardBaseUI:CanWatchPlayerCombatData()
  return false
end
function PlayerInfoCardBaseUI:OnClickCloseButton()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.PLAYERINFO_CARD)
  Client.RequireSlateTickEveryFrameBeforeTargetFrame(5)
  self:HideSpectatePlayerInfo()
  if self.OnClickCloseButtonCallback then
    self.OnClickCloseButtonCallback()
  end
end
function PlayerInfoCardBaseUI:OnClickedAddFriendButton()
  local UIDString = self:GetUIDString()
  if not UIDString then
    return
  end
  self.AlreadyAddFriend[UIDString] = true
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:add_inner_friend_req(UIDString, "", BP_ENUM_ADD_FRIEND_FROM_OB_PLAYER_INFO, 39)
end
function PlayerInfoCardBaseUI:GetUIDString()
  return nil
end
function PlayerInfoCardBaseUI:OnClickedAddFavouriteButton()
  if not self.IngameCurItemId then
    return
  end
  local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  if store_collect_data:IsCollectedByItemID(self.IngameCurItemId) then
    store_supply_manager:cancel_market_collect_by_item_req(self.IngameCurItemId)
  else
    store_supply_manager:add_market_collect_by_item_req(self.IngameCurItemId, StoreConst.market_collect_source_watch)
  end
end
function PlayerInfoCardBaseUI:OnClickedSendGifts()
  local UIDString = self:GetUIDString()
  local PlayerName = self:GetPlayerName()
  if not UIDString or not PlayerName then
    return
  end
  if BattleResultUI then
    BattleResultUI.SendGifts(UIDString, PlayerName)
  end
end
function PlayerInfoCardBaseUI:DisplayAvatar(bIsEnable, PlayerPawn)
  local AvatarCaptureInfo = self:GetAvatarCaptureInfo()
  if not slua.isValid(AvatarCaptureInfo) then
    return
  end
  AvatarCaptureInfo:DisplayAvatar(bIsEnable, PlayerPawn)
  if bIsEnable then
    self:RefreshAllItemsInfo()
    local GameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(GameInstance) and GameInstance.IsOpenHDR then
      self:SwitchHDRInner(GameInstance:IsOpenHDR())
    end
  end
end
function PlayerInfoCardBaseUI:SetCombatTotalCount(TotalCount)
  self.UIRoot.CombatTotalCountText:SetText(TotalCount)
end
function PlayerInfoCardBaseUI:SetCombatWinCount(WinCount)
  self.UIRoot.CombatWinCountText:SetText(WinCount)
end
function PlayerInfoCardBaseUI:SetCombatTopTenCount(TopTenCount)
  self.UIRoot.CombatTopTenCountText:SetText(TopTenCount)
end
function PlayerInfoCardBaseUI:SetCombatKillCount(KillCount)
  self.UIRoot.CombatKillCountText:SetText(KillCount)
end
function PlayerInfoCardBaseUI:SetCombatKillBeatenRatio(KillBeatenRatio)
  self.UIRoot.CombatKillBeatenRatioText:SetText(KillBeatenRatio)
end
function PlayerInfoCardBaseUI:SetCombatMatchMode()
  local Ingame_PlayerData_MatchMode = ""
  local Ingame_PlayerData_MatchMode_PlayerNum = ""
  local MatchMode
  local BattleMode = self:GetBattleMode()
  if BattleMode then
    MatchMode = CDataTable.GetTableData("MatchModeTable", BattleMode)
  end
  if MatchMode ~= nil then
    local MatchModeStringID = MatchMode.WordsToShowID
    Ingame_PlayerData_MatchMode = LocUtil.GetLocalizeResStr(MatchModeStringID)
    local PlayerNumStringID = MatchMode.PlayerNumStrID
    Ingame_PlayerData_MatchMode_PlayerNum = LocUtil.GetLocalizeResStr(PlayerNumStringID)
  end
  local CombatMatchMode = Ingame_PlayerData_MatchMode .. Ingame_PlayerData_MatchMode_PlayerNum
  self.UIRoot.CombatMatchModeText:SetText(CombatMatchMode)
end
function PlayerInfoCardBaseUI:SetCombatMatchCount(MatchCount, MatchKD)
  self.UIRoot.CombatMatchKD:SetText(MatchKD)
  self.UIRoot.CombatMatchCountText:SetText(MatchCount)
end
function PlayerInfoCardBaseUI:ShowSpectatePlayerInfo()
  self:SelfHitTestInvisible()
end
function PlayerInfoCardBaseUI:HideSpectatePlayerInfo()
  self:Collapsed()
end
function PlayerInfoCardBaseUI:RefreshSepctatePlayerInfo()
  self:RefreshAllItemsInfo()
  self:RefreshPlayerSimpleInfo()
  local bCanWatchPlayerCombatData = self:CanWatchPlayerCombatData()
  if bCanWatchPlayerCombatData then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  end
  self:SetCombatTotalInfo()
end
function PlayerInfoCardBaseUI:RegistEventToPlayerInfoItem(PlayerInfoItem)
  if not slua.isValid(PlayerInfoItem) then
    return
  end
  self:RemoveControlEventByControl(PlayerInfoItem, "OnPlayerInfoItemClicked")
  self:AddControlEventByControl(PlayerInfoItem, "OnPlayerInfoItemClicked", self.HandlePlayerInfoItemClicked, self)
end
function PlayerInfoCardBaseUI:HandlePlayerInfoItemClicked(bShowTips, ItemID, ItemName, ItemDescription, ItemIconBrush, ItemQuality, ItemSlotType)
  self.CurrentSelected  self.CurrentSelectedSlotType = ItemSlotType
  local UIRoot = self.UIRoot
  if bShowTips then
    self:RefreshItemInfoTips(ItemID, ItemName, ItemDescription, ItemIconBrush, ItemQuality)
    self:ToggleItemSelected()
    UIRoot.ItemInfoTips:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    if self.NotFavouriteItems[ItemID] then
      UIRoot.CanvasPanel_AddFavourite:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      UIRoot.CanvasPanel_AddFavourite:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:InitCollectButtonByItemID()
    end
  else
    UIRoot.ItemInfoTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    UIRoot.CanvasPanel_AddFavourite:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PlayerInfoCardBaseUI:InitPlayerInfoItemClieckEventHandle()
  local WatchGameInGamePlayerInfoItem = require("GameLua.Mod.BaseMod.Client.WatchGame.WatchGameInGamePlayerInfoItem")
  for _, ItemName in pairs(self.PlayerInfoBattleItemArray) do
    local WidgetItem = self.UIRoot[ItemName]
    if WidgetItem then
      local WatchGameInGamePlayerInfoItemIns = WatchGameInGamePlayerInfoItem()
      WatchGameInGamePlayerInfoItemIns:InitWithWidget(WidgetItem)
      self:RegistEventToPlayerInfoItem(WidgetItem)
      self.ChildrenWidgets[ItemName] = WatchGameInGamePlayerInfoItemIns
    end
  end
  for _, ItemName in pairs(self.PlayerInfoWearItemArray) do
    local WidgetItem = self.UIRoot[ItemName]
    if WidgetItem then
      local WatchGameInGamePlayerInfoItemIns = WatchGameInGamePlayerInfoItem()
      WatchGameInGamePlayerInfoItemIns:InitWithWidget(WidgetItem)
      self:RegistEventToPlayerInfoItem(WidgetItem)
      self.ChildrenWidgets[ItemName] = WatchGameInGamePlayerInfoItemIns
    end
  end
end
function PlayerInfoCardBaseUI:InitPlayerInfoItems()
  self:InitPlayerInfoItemClieckEventHandle()
end
function PlayerInfoCardBaseUI:RefreshPlayerWearItemsInfo()
  local IsDefaultEquip = false
  for _, Element in pairs(self.AvatarItemSlotOrder) do
    self:RefreshOneItemInfo(self.BodyItemIDList:Get(Element), Element, false)
  end
  for Index = self.CurrentEquipWearItemIndex, #self.PlayerInfoWearItemArray do
    local ItemName = self.PlayerInfoWearItemArray[Index]
    local WidgetItem = self.ChildrenWidgets[ItemName]
    if WidgetItem then
      WidgetItem:HideInfoItem()
    end
  end
end
function PlayerInfoCardBaseUI:ToggleItemSelected()
  if not self.CurrentSelectedItemID then
    return
  end
  for _, ItemName in pairs(self.PlayerInfoWearItemArray) do
    local WidgetItem = self.ChildrenWidgets[ItemName]
    if WidgetItem then
      WidgetItem:ToggleItemSelected(self.CurrentSelectedItemID)
    end
  end
  for _, ItemName in pairs(self.PlayerInfoBattleItemArray) do
    local WidgetItem = self.ChildrenWidgets[ItemName]
    if WidgetItem then
      WidgetItem:ToggleItemSelected(self.CurrentSelectedItemID)
    end
  end
end
function PlayerInfoCardBaseUI:GetAvatarCaptureInfo()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return nil
  end
  if slua.isValid(PlayerController.AvatarCaptureInfo) then
    if slua.isValid(PlayerController.AvatarCaptureInfo.SceneCaptureCameraActor) then
      if PlayerController.AvatarCaptureInfo.bUseNewCapture then
        self.UIRoot.WatchUIAvatarItem_UIBP.Image_AvatarIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.WatchUIAvatarItem_UIBP.SceneCaptureWidget_0:SetSceneCaptureCameraActor(PlayerController.AvatarCaptureInfo.SceneCaptureCameraActor)
      else
        self.UIRoot.WatchUIAvatarItem_UIBP.Image_AvatarIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.WatchUIAvatarItem_UIBP.SceneCaptureWidget_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
    return PlayerController.AvatarCaptureInfo
  end
  local World = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(World) then
    print(bWriteLog and "PlayerInfoCardBaseUI:GetAvatarCaptureInfo , World Is Not Valid")
    return nil
  end
  local AvatarCapture_BPClass = slua.loadClass(self:GetAvatarCaptureBPClass())
  local TempAvatarCapture = World:SpawnActor(AvatarCapture_BPClass, FVector(10000, -100, -1000), FRotator(0, 0, 0), nil)
  if not slua.isValid(TempAvatarCapture) then
    return nil
  end
  if TempAvatarCapture.bUseNewCapture then
    self.UIRoot.WatchUIAvatarItem_UIBP.Image_AvatarIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local AvatarCaptureCameraActor_BPClass = slua.loadClass("/Game/BluePrints/PlayerInfo/AvatarCaptureCameraActor_BP.AvatarCaptureCameraActor_BP")
    local TempAvatarCaptureCameraActor = World:SpawnActor(AvatarCaptureCameraActor_BPClass, FVector(10000, 175.378616, -908.323914), FRotator(0, -90, 0), nil)
    if not slua.isValid(TempAvatarCaptureCameraActor) then
      return nil
    end
    TempAvatarCaptureCameraActor.SceneCaptureComponent.ShowOnlyActors:AddUnique(TempAvatarCapture)
    self.UIRoot.WatchUIAvatarItem_UIBP.SceneCaptureWidget_0:SetSceneCaptureCameraActor(TempAvatarCaptureCameraActor)
    TempAvatarCapture.SceneCaptureCameraActor = TempAvatarCaptureCameraActor
  else
    self.UIRoot.WatchUIAvatarItem_UIBP.Image_AvatarIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.WatchUIAvatarItem_UIBP.SceneCaptureWidget_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    TempAvatarCapture.SceneCaptureComponent2D.ShowOnlyActors:AddUnique(TempAvatarCapture)
  end
  print(bWriteLog and "PlayerInfoCardBaseUI:GetAvatarCaptureInfo")
  return TempAvatarCapture
end
function PlayerInfoCardBaseUI:GetAvatarCaptureBPClass()
  return "/Game/BluePrints/PlayerInfo/AvatarCapture_BP.AvatarCapture_BP"
end
function PlayerInfoCardBaseUI:OnPlayerMonsterChange(_, _, Pawn, MonsterID)
  local PlayerController = GameplayData.GetPlayerController()
  if not (slua.isValid(PlayerController) and self:IsShow()) or not slua.isValid(self.UIRoot) then
    return
  end
  local uCurPawn = PlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uCurPawn) or Pawn ~= uCurPawn then
    return
  end
  print(bWriteLog and "PlayerInfoCardBaseUI:OnPlayerMonsterChange MonsterID", MonsterID)
  if MonsterID and 0 < MonsterID then
    self.UIRoot.CustomScrollBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.VerticalBox_ItemInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CustomScrollBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.VerticalBox_ItemInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function PlayerInfoCardBaseUI:RefreshPlayterBattleItemsInfo()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    self.UIRoot.CustomScrollBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.VerticalBox_ItemInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local uCurPawn = PlayerController:GetCurPlayerCharacter()
  if slua.isValid(uCurPawn) and uCurPawn.BecomeMonsterFeature and uCurPawn.BecomeMonsterFeature.IsMonster and uCurPawn.BecomeMonsterFeature:IsMonster() then
    print(bWriteLog and "PlayerInfoCardBaseUI:RefreshPlayterBattleItemsInfo target is Monster!")
    self.UIRoot.CustomScrollBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.VerticalBox_ItemInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.UIRoot.CustomScrollBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  local AvatarCaptureInfo = self:GetAvatarCaptureInfo()
  if slua.isValid(AvatarCaptureInfo) then
    local WeaponSkinIDs = AvatarCaptureInfo:GetWeaponSkinIDs()
    for _, ArrayElement in pairs(WeaponSkinIDs) do
      self:RefreshOneItemInfo(ArrayElement, EAvatarSlotType.EAvatarSlotType_NONE, true)
    end
  end
  for _, ArrayElement in pairs(self.BattleItemSlotOrder) do
    self:RefreshOneItemInfo(self.BodyItemIDList:Get(ArrayElement), ArrayElement, true)
  end
  for Index = self.CurrentEquipBattleItemIndex, #self.PlayerInfoBattleItemArray do
    local ItemName = self.PlayerInfoBattleItemArray[Index]
    local WidgetItem = self.ChildrenWidgets[ItemName]
    if WidgetItem then
      WidgetItem:HideInfoItem()
    end
  end
end
function PlayerInfoCardBaseUI:RefreshOneItemInfo(itemSpecificID, ItemSlotType, bIsBattleItem)
  local TempItemId = itemSpecificID
  if BackpackUtils.GetEquipmentLevel(itemSpecificID) > 0 and (ItemSlotType == EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot or ItemSlotType == EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot) then
    TempItemId = -1
  elseif self.IgnoreItemIDs[itemSpecificID] then
    TempItemId = -1
  end
  local CurrentIndex = self.CurrentEquipWearItemIndex
  local CurrentItemArray = self.PlayerInfoWearItemArray
  if bIsBattleItem then
    CurrentIndex = self.CurrentEquipBattleItemIndex
    CurrentItemArray = self.PlayerInfoBattleItemArray
  end
  local ItemName = CurrentItemArray[CurrentIndex]
  local WidgetItem = self.ChildrenWidgets[ItemName]
  if WidgetItem then
    local bIsShow = WidgetItem:SetItemInfo(TempItemId, ItemSlotType)
    local IncreaseCount = bIsShow and 1 or 0
    if bIsBattleItem then
      self.CurrentEquipBattleItemIndex = self.CurrentEquipBattleItemIndex + 1
      self.ShowinBattleItemNum = self.ShowinBattleItemNum + IncreaseCount
    else
      self.CurrentEquipWearItemIndex = self.CurrentEquipWearItemIndex + 1
      self.ShowingWearItemNum = self.ShowingWearItemNum + IncreaseCount
    end
  end
  if itemSpecificID == self.CurrentSelectedItemID then
    self.CurrentItemFoundAfterRefresh = true
  end
end
function PlayerInfoCardBaseUI:RefreshAllItemsInfo()
  self.CurrentItemFoundAfterRefresh = false
  self.ShowingWearItemNum = 0
  self.ShowinBattleItemNum = 0
  self.CurrentEquipWearItemIndex = 1
  self.CurrentEquipBattleItemIndex = 1
  local AvatarCaptureInfo = self:GetAvatarCaptureInfo()
  if not slua.isValid(AvatarCaptureInfo) then
    print(bWriteLog and "PlayerInfoCardBaseUI:RefreshPlayerWearItemsInfo Invalid Viewed captureinfo")
    return
  end
  local OBAvatarComponent = AvatarCaptureInfo:GetOBAvatarComponent()
  if not slua.isValid(OBAvatarComponent) then
    print(bWriteLog and "PlayerInfoCardBaseUI:RefreshPlayerWearItemsInfo Invalid Character AvatarComponent")
    return
  end
  self.BodyItemIDList = OBAvatarComponent:GetDefaultBodyItemIDList()
  self:RefreshPlayterBattleItemsInfo()
  self:RefreshPlayerWearItemsInfo()
  self:RefreshLayout()
  self:RefreshCorder(self.BodyItemIDList)
  if not self.CurrentItemFoundAfterRefresh then
    self:HandlePlayerInfoItemClicked(false, -1, "", "", nil, 0, EAvatarSlotType.EAvatarSlotType_NONE)
    self:ToggleItemSelected()
  end
end
function PlayerInfoCardBaseUI:RefreshItemInfoTips(ItemID, ItemName, ItemDescription, ItemImageIcon, ItemQuality)
  local UIRoot = self.UIRoot
  UIRoot.ItemName1:SetText(ItemName)
  UIRoot.UTRichTextBlock_ItemDesc:SetText(ItemDescription)
  self:SetEquipQuality(ItemQuality)
end
function PlayerInfoCardBaseUI:InitCollectButtonByItemID()
  self.IngameCurItemId = self.CurrentSelectedItemID
  local ItemCfg = CDataTable.GetTableDataByFilter("ItemUpgradeConfig", "ItemID", self.CurrentSelectedItemID)
  if ItemCfg then
    self.IngameCurItemId = ItemCfg.FavourateItemID
  elseif self.CurrentSelectedSlotType == EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot or self.CurrentSelectedSlotType == EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot then
    self.IngameCurItemId = self:FindSpecialItemSkinID(self.IngameCurItemId)
  end
  local ActiveIndex = 0
  local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
  if store_collect_data:IsCollectedByItemID(self.IngameCurItemId) then
    ActiveIndex = 1
  end
  self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(ActiveIndex)
end
function PlayerInfoCardBaseUI:FindSpecialItemSkinID(ItemId)
  local BackpackMappingTableData = CDataTable.GetTable("BackpackMapping")
  if BackpackMappingTableData then
    for _, RowItem in pairs(BackpackMappingTableData) do
      if RowItem.SkinItemIDLv1 == ItemId or RowItem.SkinItemIDLv2 == ItemId or RowItem.SkinItemIDLv3 == ItemId then
        return RowItem.SkinID
      end
    end
  end
  return ItemId
end
function PlayerInfoCardBaseUI:RefreshLayout()
  local UIRoot = self.UIRoot
  if self.ShowingWearItemNum == 0 or self.ShowinBattleItemNum == 0 then
    UIRoot.line:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    UIRoot.line:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
end
function PlayerInfoCardBaseUI:SetRankIntegraInfo(RankIntegral)
  local RowItem = FuncUtil.GetRankTableData(RankIntegral, 0)
  if not RowItem then
    return
  end
  self.UIRoot.Image_icon:SetBrushFromPathAsync(RowItem.BigIcon, false)
  self.UIRoot.TextBlock_RankTitleName:SetText(RowItem.Name)
end
function PlayerInfoCardBaseUI:RefreshPlayerSimpleInfo()
end
function PlayerInfoCardBaseUI:RefreshCorder(WearList)
  log_tree("PlayerInfoCardBaseUI:RefreshCorder WearList", WearList)
  if not WearList then
    return
  end
  if not slua.isValid(self.UIRoot) then
    log(bWriteLog and "PlayerInfoCardBaseUI:RefreshCorder not slua.isValid(self.UIRoot)")
    return
  end
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  local XSuitID = -1
  local GoldenSuitID = -1
  for key, value in pairs(WearList) do
    if value and 0 < value then
      if AvatarCommon.IsXSuit(value) then
        XSuitID = value
        break
      elseif AvatarCommon.IsGoldenSuit(value) then
        GoldenSuitID = value
      end
    end
  end
  if 0 < XSuitID then
    log(bWriteLog and "PlayerInfoCardBaseUI:RefreshCorder is XSuit" .. tostring(XSuitID))
    self.UIRoot.CornerIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SetTexture(self.UIRoot.Image_CornerIcon, AvatarCommon.GetXSuitCornerPath(XSuitID))
  elseif 0 < GoldenSuitID then
    log(bWriteLog and "PlayerInfoCardBaseUI:RefreshCorder is IsGoldenSuit" .. tostring(GoldenSuitID))
    self.UIRoot.CornerIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SetTexture(self.UIRoot.Image_CornerIcon, AvatarCommon.GetGoldenSuitCornerPath(GoldenSuitID))
  else
    self.UIRoot.CornerIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PlayerInfoCardBaseUI:SetSeasonAndZone(ZoneID)
  local CurSeasonName = ""
  local CfgConfig = CDataTable.GetTableData("SeasonInfo", DataMgr.season_id)
  if CfgConfig then
    CurSeasonName = CfgConfig.SeasonName
  end
  local IntlHelper = import("IntlHelper")
  local ZoneConfigRow = CDataTable.GetTableData("ZoneConfig", ZoneID)
  local FinalText = CurSeasonName
  if ZoneConfigRow then
    FinalText = CurSeasonName .. " " .. IntlHelper.GetLocalizationString(ZoneConfigRow.NameInChinese)
  end
  self.UIRoot.TextBlock_SeasonAndZone:SetText(FinalText)
end
function PlayerInfoCardBaseUI:SetAceImprintItem(AceImprintShowID, AceImprintBaseID)
  local nAceImprintShowID = tonumber(AceImprintShowID)
  if nAceImprintShowID then
    local nAceImprintBaseID = AceImprintBaseID and tonumber(AceImprintBaseID) or 0
    local AceImprintLogic = require("client.logic.season.AceImprintLogic")
    if AceImprintLogic then
      AceImprintLogic.SetAceImprintItem(self.UIRoot.AceImprintItem, nAceImprintShowID, nAceImprintBaseID, AceImprintLogic.EAceImprintStyle.IconAndTextBg1)
    end
  end
end
function PlayerInfoCardBaseUI:SetSegmentSubIcon(SegmentLv)
  local nSegmentLevel = tonumber(SegmentLv)
  if not nSegmentLevel then
    return
  end
  local RankCfg = FuncUtil.GetRankTableData(nSegmentLevel)
  if not RankCfg then
    return
  end
  local Image_SubIcon = self.UIRoot.Image_SubIcon
  if RankCfg.SubIcon and RankCfg.SubIcon ~= "" then
    Image_SubIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SetTexture(Image_SubIcon, RankCfg.SubIcon)
  else
    Image_SubIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PlayerInfoCardBaseUI:HideSegmentInJaguar()
  local UIUtil = require("client.common.ui_util")
  self.UIRoot.CanvasPanel_Left:SetWidgetVisibility(UIUtil.BoolToVisible(true))
end
function PlayerInfoCardBaseUI:SetNation(Nation)
  local NationInfo = CDataTable.GetTableData("RegionConfig", Nation)
  NationInfo = NationInfo or CDataTable.GetTableData("RegionConfig", "G1")
  if not NationInfo then
    return
  end
  if GlobalData.GetNationSwitch("Battle") and GlobalData.GetNationSwitch("All") then
    self.UIRoot.Image_Nation:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.Image_Nation:SetBrushFromPathAsync(NationInfo.res_path, false)
  else
    self.UIRoot.Image_Nation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if GamePlayTools.IsBlueHoleVersion() then
    self.UIRoot.Image_Nation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PlayerInfoCardBaseUI:SwitchHDRInner(bIsHDR)
  self.UIRoot.WatchUIAvatarItem_UIBP:HDRSwitch(bIsHDR)
end
function PlayerInfoCardBaseUI:ParseUpassShow(UpassShow)
  return UpassShow & 1, UpassShow & 2
end
function PlayerInfoCardBaseUI:SetEquipQuality(InQuality)
  local UIRoot = self.UIRoot
  UIRoot.Image_Icon_Quality:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local GlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
  local Path = GlobalBattleUIFunctionLibrary.GetButtomQualityPath(InQuality, self.UIRoot)
  UIRoot.Image_Icon_Quality:SetBrushFromPathAsync(Path, false)
end
function PlayerInfoCardBaseUI:SetCloseButtonClickCallback(CallbackFunction)
  self.OnClickCloseButtonCallback = CallbackFunction
end
function PlayerInfoCardBaseUI:IsVisible()
  if type(self.UIRoot) == "table" then
    return false
  end
  return self.UIRoot:IsVisible()
end
function PlayerInfoCardBaseUI:GetVisibility()
  if type(self.UIRoot) == "table" then
    return UEnums.ESlateVisibility.Collapsed
  end
  return self.UIRoot:GetVisibility()
end
function PlayerInfoCardBaseUI:ClearChild()
  local utility = require("common.utility")
  for _, WidgetTable in pairs(self.ChildrenWidgets) do
    if WidgetTable and WidgetTable.Close then
      xpcall(WidgetTable.Close, utility.ErrorMessageHandler, WidgetTable)
    end
  end
  self.ChildrenWidgets = {}
end
function PlayerInfoCardBaseUI:OnClose()
  print(bWriteLog and "PlayerInfoCardBaseUI:OnClose")
  Client.ResetSlateTickEveryFrame(SlateUI_ID.PLAYERINFO_CARD)
  Client.RequireSlateTickEveryFrameBeforeTargetFrame(5)
  if self.OnCloseCallback and type(self.OnCloseCallback) == "function" then
    self.OnCloseCallback()
  end
  self.OnCloseCallback = nil
  self:ClearChild()
  PlayerInfoCardBaseUI.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, PlayerInfoCardBaseUI)