local BackPackPanelUI = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Define")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local STExtraGameInstance = import("STExtraGameInstance")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local EBackPackDragOrigin = UEnums.EBackPackDragOrigin
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EWeaponChangeInvenroryDataType = import("EWeaponChangeInvenroryDataType")
local EBackpackItemSortType = import("EBackpackItemSortType")
local EItemStoreArea = import("EItemStoreArea")
local EHorizontalAlignment = import("EHorizontalAlignment")
local EVerticalAlignment = import("EVerticalAlignment")
local FriendlyBehaviorModule = require("GameLua.Mod.BaseMod.Common.Security.FriendlyBehavior")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function BackPackPanelUI:OnInitialize()
  BackPackPanelUI.__super.OnInitialize(self)
  print(bWriteLog and "BackPackPanelUI:OnInitialize")
  self.WidgetSwitcher_0 = self.UIRoot.WidgetSwitcher_0
  self.CanvasPanel_ClothingGroup = self.UIRoot.CanvasPanel_ClothingGroup
  self.WeaponAndListGroup = self.UIRoot.WeaponAndListGroup
  self.CanvasPanel_WeaponDetail = self.UIRoot.CanvasPanel_WeaponDetail
  self.GridPanel_WeaponInfo = self.UIRoot.GridPanel_WeaponInfo
  self.UniformGridPanel_Armor = self.UIRoot.UniformGridPanel_Armor
  self.ArmorSlotItem_Helmet = self.UIRoot.ArmorSlotItem_Helmet
  self.ArmorSlotItem_ArmoredVest = self.UIRoot.ArmorSlotItem_ArmoredVest
  self.ArmorSlotItem_Package = self.UIRoot.ArmorSlotItem_Package
  self.Image_EquipmentInfo = self.UIRoot.Image_EquipmentInfo
  self.UniformGridPanel_Armor_XAndT = self.UIRoot.UniformGridPanel_Armor_XAndT
  self.GridPanel_BackPackListParent = self.UIRoot.GridPanel_BackPackListParent
  self.TextBlock_0 = self.UIRoot.TextBlock_0
  self.TextBlock_CurrentItemNum_Classic = self.UIRoot.TextBlock_CurrentItemNum_Classic
  self.TextBlock_MaxItemNum_Classic = self.UIRoot.TextBlock_MaxItemNum_Classic
  self.Image_17 = self.UIRoot.Image_17
  self.GridPanel_BackPackList = self.UIRoot.GridPanel_BackPackList
  self.ScrollBox_ItemList = self.UIRoot.ScrollBox_ItemList
  self.GridPanel_BackPackBtnGroup = self.UIRoot.GridPanel_BackPackBtnGroup
  self.Button_AllItem = self.UIRoot.Button_AllItem
  self.Image_All = self.UIRoot.Image_All
  self.GridPanel_AttachmentFit = self.UIRoot.GridPanel_AttachmentFit
  self.Image_WeaponFit = self.UIRoot.Image_WeaponFit
  self.Button_WeaponFit = self.UIRoot.Button_WeaponFit
  self.GridPanel_ArmorFit = self.UIRoot.GridPanel_ArmorFit
  self.Image_ArmorFit = self.UIRoot.Image_ArmorFit
  self.Button_ArmorFit = self.UIRoot.Button_ArmorFit
  self.GridPanel_ConsumFit = self.UIRoot.GridPanel_ConsumFit
  self.Image_ConsumFit = self.UIRoot.Image_ConsumFit
  self.Button_Consumption = self.UIRoot.Button_Consumption
  self.GridPanel_OthersFit = self.UIRoot.GridPanel_OthersFit
  self.Image_OthersFit = self.UIRoot.Image_OthersFit
  self.Button_Other = self.UIRoot.Button_Other
  self.GridPanel_ClothFit = self.UIRoot.GridPanel_ClothFit
  self.Image_Cloth = self.UIRoot.Image_Cloth
  self.Button_Clothing = self.UIRoot.Button_Clothing
  self.GridPanel_Store = self.UIRoot.GridPanel_Store
  self.Image_Store = self.UIRoot.Image_Store
  self.Button_Store = self.UIRoot.Button_Store
  self.GridPanel_AllExcluded = self.UIRoot.GridPanel_AllExcluded
  self.Image_AllExcluded = self.UIRoot.Image_AllExcluded
  self.Button_AllExcluded = self.UIRoot.Button_AllExcluded
  self.Button_CloseBackPackUI = self.UIRoot.Button_CloseBackPackUI
  self.Image_Drop = self.UIRoot.Image_Drop
  self.Bounty_AchievementsList_Socket = self.UIRoot.Bounty_AchievementsList_Socket
  self.BountyShowSocket = self.UIRoot.BountyShowSocket
  self.Bounty_Achievements_Socket = self.UIRoot.Bounty_Achievements_Socket
  self.BountyListSocket = self.UIRoot.BountyListSocket
  self.CanvasPanel_StoreGroup = self.UIRoot.CanvasPanel_StoreGroup
  self.ExtraAddWidgetRoot1 = self.UIRoot.ExtraAddWidgetRoot1
  self.CloseBackPack = self.UIRoot.CloseBackPack
  local EBackpackTab = UEnums.EBackpackTab
  self.CurChosenTab = EBackpackTab.AllItem
  self.isBindWeaponMsg = false
  self.WeaponInfoItemArray = {}
  self.ArmorPlotItemArray = {}
  self.DragItemOrigin = EBackPackDragOrigin.FromList
  self.CanNotDropItemID = {
    3000301,
    371111,
    602999,
    1000,
    1001,
    3000314,
    602030,
    602040,
    3001061,
    3001062,
    3001063,
    602041,
    504003,
    602107,
    602108,
    602109,
    602110,
    602046,
    602047,
    602048,
    602049,
    602056
  }
  self.bOpenChangeWearing = false
  self.bChangeWearingState = false
  local EBackpackClothArmorType = UEnums.EBackpackClothArmorType
  self.ForbidDragArmorType = {
    [EBackpackClothArmorType.SurfBoard] = true,
    [EBackpackClothArmorType.SnowBoard] = true
  }
  self.UAVLastUsedItem = FItemDefineIDDefault()
  self.BackpackButtonItemPool = nil
  self.ItemMap = {}
  self.LastVehicleFinishCD = 0
  self.LocalBackpackItemArray = {}
  self.CurSortType = EBackpackItemSortType.ECT_Type
  self.WeaponList = {}
  self.CurUsingShootWeapon = nil
  self.ReloadingCD = 0.0
  self.tExtraWidgets = {}
  self.bHasHoldPickup = false
  self.bHasHold = false
  self.CurExpandingStoreAreaType = EItemStoreArea.InBag
  self.DragDropWidgetWeaponDetail = nil
  self.ArmorEquipInfoItemArray = {}
  self.NotShowInBackpackItems = {
    602041,
    602093,
    602096,
    602204,
    602208,
    602213,
    604207
  }
  self.MultiBackPackItemPoolInfos = {}
  self.UselessItem = {}
  self.ClothFitActive = true
  self.ArmorSlotType2WidgetMap = {}
  self.ArmorSlotItemVampireCloth = self.UIRoot.ArmorSlotItemVampireCloth
  self.ArmorSlotType2RowMapHasAR = self.UIRoot.ArmorSlotType2RowMapHasAR
  self.PendingDropDefineIDInstanceIDs = {}
  self.tScrollListItemsUI = {}
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  MainControlBaseUI.CanvasPanel_42:AddChild(self.UIRoot)
  self:SetZOrder(72)
  self:SetAnchors(0, 0, 1, 1)
  self:SetOffsets(0, 0, 0, 0)
  self.BackPackSideBarUI = require(GamePlayTools.GetModPath(true, "Client.Backpack.BackPackSideBarUI", true))()
  self.BackPackSideBarUI:InitWithParentWidget(self, self.UIRoot)
  self:CreateExItems()
  self:CallReceivedInitWidget()
  self:InitFoldList()
  self.UIRoot.Image_NormalBackpackBG:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.CanvasPanel_TrunkControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.isTogglingList = false
  if FriendlyBehaviorModule.IsEnableFriendlyGiftBox() then
    self:CreateFriendlyBehaviorUI()
  end
  self:PreLoadItem()
end
function BackPackPanelUI:CreateExItems()
  self.PickUpItemTips = UIManager.ShowUI(UIManager.UI_Config_InGame.PickUpItemTips)
  self:AttachChildWindow("GridPanel_WeaponInfo", self.PickUpItemTips)
  local ItemSlot = self.PickUpItemTips.UIRoot.Slot
  ItemSlot:SetHorizontalAlignment(EHorizontalAlignment.HAlign_Right)
  ItemSlot:SetVerticalAlignment(EVerticalAlignment.VAlign_Bottom)
  ItemSlot:SetPadding(FMargin(0, 0, 0, 5))
  local FSlateChildSize = import("SlateChildSize")
  local SlateChidSize = FSlateChildSize()
  self.WeaponInfoItem_Weapon1 = UIManager.ShowUI(UIManager.UI_Config_InGame.MainWeaponInfoItem)
  self:AttachChildWindow("VerticalBox_Weapon", self.WeaponInfoItem_Weapon1)
  local WeaponItem1Slot = self.WeaponInfoItem_Weapon1.UIRoot.Slot
  WeaponItem1Slot:SetSize(SlateChidSize)
  WeaponItem1Slot:SetHorizontalAlignment(EHorizontalAlignment.HAlign_Fill)
  WeaponItem1Slot:SetVerticalAlignment(EVerticalAlignment.VAlign_Fill)
  self.WeaponInfoItem_Weapon2 = UIManager.ShowUI(UIManager.UI_Config_InGame.MainWeaponInfoItem)
  self:AttachChildWindow("VerticalBox_Weapon", self.WeaponInfoItem_Weapon2)
  local WeaponItem2Slot = self.WeaponInfoItem_Weapon2.UIRoot.Slot
  WeaponItem2Slot:SetSize(SlateChidSize)
  WeaponItem2Slot:SetHorizontalAlignment(EHorizontalAlignment.HAlign_Fill)
  WeaponItem2Slot:SetVerticalAlignment(EVerticalAlignment.VAlign_Fill)
  self.UIRoot.VerticalBox_Weapon:AddChild(self.UIRoot.HorizontalBox_Down)
  self.MeleeInfoItem_BP = UIManager.ShowUI(UIManager.UI_Config_InGame.MeleeInfoItem)
  self:AttachChildWindow("GridPanelMelInfo", self.MeleeInfoItem_BP)
  self.PistolInfoItem_BP = UIManager.ShowUI(UIManager.UI_Config_InGame.PistolInfoItem)
  self:AttachChildWindow("GridPanelPistolInfo", self.PistolInfoItem_BP)
end
function BackPackPanelUI:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, self.ShowTabPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_CLOSE, self.ClickCloseBackpack, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REFRESHUI_AFTERRESPAWN, self.BindWeaponMsgEvent, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_COMPLETE_PLAYBACK_UI, self.OnHideBackPack, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_SPECTATING_UI, self.OnHideBackPack, self)
  self:AddControlEventByControl(self.UIRoot, "OnDropImplementation", self.OnDropImplementation, self)
  if self.UIRoot.OnItemBeDrag then
    self:AddControlEventByControl(self.UIRoot, "OnItemBeDrag", self.OnDropSlide, self)
  end
  self:AddUIMessageEvent("UIMsg_GroupBackpackCompUpdate", self.OnUIMsg_GroupBackpackCompUpdate, self)
  self:AddUIMessageEvent("UIMsg_ExitGroupBackpackCompMsg", self.OnUIMsg_ExitGroupBackpackCompMsg, self)
  local uPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(uPlayerController) then
    local SingleBackpackComp = import("SingleBackpackComp")
    local uSingleBackpackComp = uPlayerController:GetComponentByClass(SingleBackpackComp)
    if Game:IsValid(uSingleBackpackComp) and uSingleBackpackComp.capacity > 0 then
      print(bWriteLog and "BackPackPanelUI:RegistEvents() uSingleBackpackComp.capacity > 0")
      self:OnUIMsg_GroupBackpackCompUpdate()
    end
  end
  if FriendlyBehaviorModule.IsHalloWeen5() then
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      self:AddControlEventByControl(uPlayerCharacter, "OnAttachedToVehicle", self.OnAttachedToVehicle, self)
      self:AddControlEventByControl(uPlayerCharacter, "OnDetachedFromVehicle", self.OnDetachedFromVehicle, self)
      print(bWriteLog and "BackPackPanelUI:RegistEvents() HalloWeen5 OnAttachedToVehicle")
      local bIsInVehicle = slua.isValid(uPlayerCharacter:GetCurrentVehicle())
      print(bWriteLog and "BackPackPanelUI:RegistEvents() HalloWeen5 bIsInVehicle: " .. tostring(bIsInVehicle))
      if bIsInVehicle then
        print(bWriteLog and "BackPackPanelUI:RegistEvents() HalloWeen5 bIsInVehicle is true, force call OnAttachedToVehicle")
        self:OnAttachedToVehicle()
      end
    end
  end
end
function BackPackPanelUI:OnHideBackPack()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.MAIN_BACKPACK_PANEL)
  self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function BackPackPanelUI:OnUIMsg_GroupBackpackCompUpdate()
  local VehicleBackpack = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleBackpack)
  if not VehicleBackpack then
    VehicleBackpack = UIManager.ShowUI(UIManager.UI_Config_InGame.VehicleBackpack, self)
    self:AttachChildWindow("CanvasPanel_Trunk", VehicleBackpack)
    VehicleBackpack:SetVehicleBackpackZOrder(5)
    local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
    self.tExtraWidgets[BackpackConfig.tExtraWidgetDragDropPriority.VehicleBackpack] = VehicleBackpack
    self.UIRoot.CanvasPanel_TrunkControl:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.  end
end
function BackPackPanelUI:OnUIMsg_ExitGroupBackpackCompMsg()
  local VehicleBackpack = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleBackpack)
  if VehicleBackpack then
    local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
    self.tExtraWidgets[BackpackConfig.tExtraWidgetDragDropPriority.VehicleBackpack] = nil
    VehicleBackpack:CloseSelf()
    self.UIRoot.CanvasPanel_TrunkControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.VehicleBackpack = nil
  end
end
function BackPackPanelUI:OnHide()
  print(bWriteLog and "BackPackPanelUI:OnHide")
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_CLOSE_BACKPACK)
end
function BackPackPanelUI:OnClose()
  print(bWriteLog and "BackPackPanelUI:OnClose")
  for _, PoolInfo in pairs(self.MultiBackPackItemPoolInfos) do
    if PoolInfo and slua.isValid(PoolInfo.Pool) then
      PoolInfo.Pool:RecycleAllItems()
      PoolInfo = nil
    end
  end
  self.MultiBackPackItemPoolInfos = {}
  for _, UnusedItems in pairs(self.UselessItem) do
    if UnusedItems then
      for _, Item in pairs(UnusedItems) do
        if Item and Item.UIRoot then
          Item.UIRoot:RemoveFromParent()
          Item = nil
        end
      end
      UnusedItems = nil
    end
  end
  self.UselessItem = nil
  if self.ButtonMenu then
    self.ButtonMenu:Close()
    self.ButtonMenu = nil
  end
  self.ArmorPlotItemArray = {}
  if self.ItemMap then
    for k, v in pairs(self.ItemMap) do
      v:Close()
    end
  end
  self.ItemMap = {}
  self.WeaponList = {}
  self.tExtraWidgets = {}
  self.ArmorEquipInfoItemArray = {}
  self.ArmorSlotType2WidgetMap = {}
  self.PendingDropDefineIDInstanceIDs = {}
  self.ItemFoldCleanList = {}
  self.WeaponInfoItemArray = {}
  self.BackPackSideBarUI = nil
  self.PickUpItemTips = nil
  self.WeaponInfoItem_Weapon1 = nil
  self.WeaponInfoItem_Weapon2 = nil
  self.PistolInfoItem_BP = nil
  self.MeleeInfoItem_BP = nil
  if self.DragDropWidgetWeaponDetail then
    self.DragDropWidgetWeaponDetail:RemoveFromParent()
    self.DragDropWidgetWeaponDetail = nil
  end
  if self.ArmorSlotItem_FriendlyBehavior then
    self.ArmorSlotItem_FriendlyBehavior:RemoveFromParent()
    self.ArmorSlotItem_FriendlyBehavior = nil
  end
  BackPackPanelUI.__super.OnClose(self)
end
function BackPackPanelUI:CallReceivedInitWidget()
  print(bWriteLog and "BackPackPanelUI:ReceivedInitWidget")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    self.bOpenChangeWearing = PlayerController.bOpenChangeWearing and not self:IsWarGameMode() and not self:IsInfectionGameMode()
    self:AddControlEventByControl(PlayerController, "OnEquipmentAvatarChange", self.EventOnEuipmentAvatarChange, self)
    print(bWriteLog and "BackPackPanelUI:ReceivedInitWidget self.bOpenChangeWearing:" .. tostring(self.bOpenChangeWearing))
  end
  self.PistolInfoItem_BP.ParentUserWidget = self.UIRoot
  self.MeleeInfoItem_BP.ParentUserWidget = self.UIRoot
  self.WeaponInfoItem_Weapon1.WeaponSlot = ESurviveWeaponPropSlot.SWPS_MainShootWeapon1
  self.WeaponInfoItem_Weapon2.WeaponSlot = ESurviveWeaponPropSlot.SWPS_MainShootWeapon2
  self.PistolInfoItem_BP.WeaponSlot = ESurviveWeaponPropSlot.SWPS_SubShootWeapon
  self.WeaponInfoItemArray = {
    self.WeaponInfoItem_Weapon1,
    self.WeaponInfoItem_Weapon2
  }
  for i_41, arrayelement_41 in pairs(self.WeaponInfoItemArray) do
    arrayelement_41.ParentUserWidget = self.UIRoot
  end
  if slua.isValid(self.DragDropWidgetWeaponDetail) then
    self.DragDropWidgetWeaponDetail:SetParentUserWidget(self.UIRoot)
    self.DragDropWidgetWeaponDetail:InitItemArray()
  end
  self:AddDataListener(GameplayData.GetSuperData(), "CharacterDataReady", self.BindWeaponMsgEvent, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_ITEM_DELETE_PANEL_CONFIRM, self.HandleClickDeleteConfirm, self)
  self:InitBackpackArmor()
  local asgamefrontendhud_89 = self.UIRoot:GetOwningFrontendHUD()
  if asgamefrontendhud_89 ~= nil then
    asgamefrontendhud_89:CallGlobalScriptFunction("EventShowAvatarZone")
  end
  self:InitWeaponDetailWidget()
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_TRIGGER_UPDATE_ITEM_LIST, function(_, __, ...)
    self:UpdateScrollItemList(...)
  end)
  self:InitBackpackItemMap()
  self:InitBackpackSortTag()
  self:OnUpdateScrollItems()
  self:OnRegistPlayerChangeWearingEvent()
end
function BackPackPanelUI:InitBackpackArmor()
  local UIRoot = self.UIRoot
  UIRoot.UniformGridPanel_Armor_XAndT:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.UniformGridPanel_Armor:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:InitAllArmorSlots()
end
function BackPackPanelUI:DelayEnableCharacterTouch()
  self:AddTimer(0.05, function()
    local returnvalue_69 = self.UIRoot:GetOwningPlayer()
    local asbpstextraplayercontroller_68 = returnvalue_69
    if asbpstextraplayercontroller_68 ~= nil then
      self.CharacterTouchMove = true
    end
  end)
end
function BackPackPanelUI:DelayStopFire()
  self:AddTimer(0.1, function()
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      self:BackpackOpenStopFire()
    end
  end)
end
function BackPackPanelUI:EventOnEuipmentAvatarChange()
  self:UpdateScrollItemListEvent()
end
function BackPackPanelUI:OnRegistPlayerChangeWearingEvent()
  print(bWriteLog and "BackPackPanelUI:OnRegistPlayerChangeWearingEvent", self)
  local uPlayerController = self.UIRoot:GetOwningPlayer()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BackPackPanelUI:OnRegistPlayerChangeWearingEvent PC is nil")
    return
  end
  self:AddControlEventByControl(uPlayerController, "OnPlayerChangeWearingDone", self.OnPlayerChangeWearingDoneEvent, self)
end
function BackPackPanelUI:OnUpdateScrollItems()
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  if BackpackConfig and BackpackConfig.DefaultShowArmorSlot then
    for _, ArmorType in pairs(BackpackConfig.DefaultShowArmorSlot) do
      print(bWriteLog and "BackpackConfig.ArmorSlotPosition", ArmorType)
      self:GetArmorSlotItem(ArmorType)
    end
  end
end
function BackPackPanelUI:OnPlayerChangeWearingDoneEvent(Index, LastTime)
  print(bWriteLog and "BackPackPanelUI OnPlayerChangeWearingDoneEvent Index:" .. Index)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if Index ~= 101 then
    IngameTipsTools.BattleNormalTipsByTextID(69123)
  end
  if self:IsInReadyStateOrSocialIsland() then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_AVATAR_ON_CHANGE_WEARING_DONE, true)
  end
end
function BackPackPanelUI:GetSlotRow(ArmorType)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  print(bWriteLog and "BackPackPanelUI:GetSlotRow", ArmorType)
  log_tree("BackPackPanelUI:GetSlotRow", BackpackConfig.ArmorSlotPosition)
  local Index = BackpackConfig.ArmorSlotPosition[ArmorType]
  if Index and 0 < Index then
    return Index
  end
  return -1
end
function BackPackPanelUI:ClickCloseBackpack()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.MAIN_BACKPACK_PANEL)
  self:HideSelf()
  if self.CloseBackPack then
    self.CloseBackPack:BroadCast()
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_CLOSE)
end
function BackPackPanelUI:ShowSelf()
  Client.RequireSlateTickEveryFrame(SlateUI_ID.MAIN_BACKPACK_PANEL)
  if self:IsShow() then
    print(bWriteLog and "BackPackPanelUI:ShowSelf")
    return
  end
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("Slate.Frequency", -1)
  self.bShowMeleeGuide = 0
  self.TlogOpenBagPanelNotSendTlog = true
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:HighLightChosenTab()
  self:ResetSelectItem()
  local PlayerController = self.UIRoot:GetOwningPlayer()
  if slua.isValid(PlayerController) and PlayerController.bIsBackPackPanelOpen ~= nil then
    PlayerController.bIsBackPackPanelOpen = true
  end
  self:UpdateScrollItemListEvent()
  self:UpdateWeaponBySlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:UpdateWeaponBySlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:UpdateWeaponBySlot(ESurviveWeaponPropSlot.SWPS_MeleeWeapon, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:UpdateCapacity()
  if slua.isValid(PlayerController) then
    PlayerController:CastUIMsg("UIInGameEvent_BackpackOpen_StopFreeLook", "ingame")
    PlayerController:CastUIMsg("UIInGameEvent_HideQuickChatMenu", "ingame")
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    self:BackpackOpenStopFire()
    self:DelayStopFire()
  end
  self:BindBackPackCompEvents()
  if slua.isValid(PlayerController) then
    PlayerController.bOpeningBackpack = true
  end
  self.WeaponInfoItem_Weapon1:BackpackOpenNotify()
  self.WeaponInfoItem_Weapon2:BackpackOpenNotify()
  self.PistolInfoItem_BP:BackpackOpenNotify()
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(uPlayerCharacter) then
      return
    end
    local uSkillManager = uPlayerCharacter:GetSkillManager()
    if not slua.isValid(uSkillManager) then
      return
    end
    self:AddControlEventByControl(uSkillManager, "SkillStopEvent", self.HandleOnSkillStop, self)
  end)
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_OPEN_BACKPACK)
  self:ClearInvalidationBoxesCache()
end
function BackPackPanelUI:BackpackOpenStopFire()
  print(bWriteLog and "BackPackPanelUI:BackpackOpenStopFire")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "BackPackPanelUI:BackpackOpenStopFire Fail not slua.isValid(uPlayerController)")
    return
  end
  PlayerController:EndTouchScreen(FVector(0.0, 0.0, 0.0), PlayerController.OnFireTouchFingerIndex, true)
end
function BackPackPanelUI:HideSelf()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.MAIN_BACKPACK_PANEL)
  if not self:IsShow() then
    print(bWriteLog and "BackPackPanelUI HideSelf is not show")
    return
  end
  if self.bShowMeleeGuide == 1 then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SET_HIGH_LIGHT_SETTING_BTN)
  end
  self:CloseAllScrollItemButton()
  local BackpackDeleteControl = UIManager.GetUI(UIManager.UI_Config_InGame.BackpackDeleteControl)
  if BackpackDeleteControl then
    BackpackDeleteControl:CloseSelf()
  end
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local PlayerController = self.UIRoot:GetOwningPlayer()
  if slua.isValid(PlayerController) then
    PlayerController.CharacterTouchMove = true
    if PlayerController.bIsBackPackPanelOpen ~= nil then
      PlayerController.bIsBackPackPanelOpen = false
    end
    if self.bShowMeleeGuide == 1 and not PlayerController.ReplaceMeleeGuide then
      PlayerController.ReplaceMeleeGuide = true
    end
  end
  self.bShowMeleeGuide = 2
  self:UnBindBackPackCompEvents()
  if slua.isValid(PlayerController) then
    PlayerController:CastUIMsg("UIInGameEvent_BackpackClose", "ingame")
  end
  if slua.isValid(PlayerController) then
    PlayerController.bOpeningBackpack = false
  end
  local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
  if ClientEVOConfig.bEnableSlateThrottle then
    local GameInstance = STExtraGameInstance.GetInstance()
    GameInstance:ExecuteCMD("Slate.Frequency", 60)
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  local uSkillManager = uPlayerCharacter:GetSkillManager()
  if not slua.isValid(uSkillManager) then
    return
  end
  self:RemoveControlEventByControl(uSkillManager, "SkillStopEvent")
  if self.FriendlyInfoPanel then
    self.FriendlyInfoPanel:Hide()
  end
  self:ClearInvalidationBoxesCache()
end
function BackPackPanelUI:HandleOnSkillStop()
  if self.CrtClickItem then
    self:HighLightUpgradeWeapon(self.CrtClickItem.ItemData)
  end
end
function BackPackPanelUI:OnEventTakeDamageForUI()
end
function BackPackPanelUI:BindBackPackCompEvents()
  local uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(self.UIRoot:GetOwningPlayer())
  if slua.isValid(uBackpackComponent) then
    self:AddControlEventByControl(uBackpackComponent, "CapacityUpdatedDelegate", self.UpdateCapacity, self)
    self:AddControlEventByControl(uBackpackComponent, "ItemOperationDelegate", self.OnItemOperation, self)
    self:AddControlEventByControl(uBackpackComponent, "ItemOperationFailedDelegate", self.OnItemOperationFailed, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST, self.UpdateScrollItemList, self)
  else
    print(bWriteLog and "Bind Event to uBackpackComponent Faild")
  end
end
function BackPackPanelUI:UnBindBackPackCompEvents()
  self:RemoveCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST)
end
function BackPackPanelUI:ResetUIAfterRespawn()
  if self:IsInfectionGameMode() then
    local asbpplayerpawn_4 = self.UIRoot:GetOwningPlayerPawn()
    if asbpplayerpawn_4 ~= nil then
      local returnvalue_5 = asbpplayerpawn_4:GetWeaponManager()
      self:AddControlEventByControl(returnvalue_5, "ChangeInventoryDataDelegate", self.UpdateWeaponBySlot1, self)
      self:AddControlEventByControl(returnvalue_5, "ChangeCurrentUsingWeaponDelegate", self.UpdateWeaponBySlot2, self)
      self:AddControlEventByControl(returnvalue_5, "SwapWeaponByPropSlotFinishedDelegate", self.SwapWeapon, self)
    end
  end
end
function BackPackPanelUI:InitBackpackItemMap()
  local UUIDuplicatedItemPool = import("UIDuplicatedItemPool")
  self.ButtonMenu = require(GamePlayTools.GetModPath(true, "Client.Backpack.BackpackItemButtonMenu", true))()
  self.ButtonMenu:Init("/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackpackItem_ButtonBP.BackpackItem_ButtonBP", UIContainers.None, EFixedZOrder.Default)
end
function BackPackPanelUI:OnItemOperation(DefineID, OperationType, Reason)
  if OperationType ~= UEnums.EBattleItemOperationType.Drop then
    return
  end
  self:CheckIsShowMeleeGuide(DefineID, OperationType, Reason)
  if not self.PendingDropDefineIDInstanceIDs[DefineID.InstanceID] then
    return
  end
  local EBattleItemDropReason = import("EBattleItemDropReason")
  if Reason == EBattleItemDropReason.WeaponExchangeDropAttach then
    return
  end
  self.PendingDropDefineIDInstanceIDs[DefineID.InstanceID] = nil
  print(bWriteLog and "BackPackPanelUI:OnItemOperation ServerDrop success: TypeSpecificID = %d, InstanceID = %d", DefineID.TypeSpecificID, DefineID.InstanceID)
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel then
    print(bWriteLog and "[BackPackPanelUI] PauseAutoPick TypeSpecificID = %d, InstanceID = %d", DefineID.TypeSpecificID, DefineID.InstanceID)
    PickUpListPanel:PauseAutoPick(DefineID.TypeSpecificID, true)
  end
end
function BackPackPanelUI:OnItemOperationFailed(DefineID, OperationType, FailedReason)
  if OperationType ~= UEnums.EBattleItemOperationType.Drop and OperationType ~= UEnums.EBattleItemOperationType.Disuse then
    return
  end
  if not self.PendingDropDefineIDInstanceIDs[DefineID.InstanceID] then
    return
  end
  self.PendingDropDefineIDInstanceIDs[DefineID.InstanceID] = nil
  printf("BackPackPanelUI:OnItemOperationFailed ServerDrop Failed: TypeSpecificID = %s, InstanceID = %s Reason = %s", DefineID.TypeSpecificID, DefineID.InstanceID, FailedReason)
end
function BackPackPanelUI:IsCollapsed()
  return not self:IsShow()
end
function BackPackPanelUI:GetPlayerController()
  print(bWriteLog and "BackPackPanelUI:GetPlayerController")
  if not slua.isValid(self.uPlayerController) then
    self.uPlayerController = GameplayData.GetPlayerController()
  end
  return self.uPlayerController
end
function BackPackPanelUI:GetBackPackComponent()
  print(bWriteLog and "BackPackPanelUI:GetBackPackComponent")
  if not slua.isValid(self.uBackpackComponent) then
    local uPlayerController = self:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      print(bWriteLog and "BackPackPanelUI:GetBackPackComponent Error, uPlayerController is invalid")
      return
    end
    self.uBackpackComponent = uPlayerController:GetBackpackComponent()
  end
  return self.uBackpackComponent
end
function BackPackPanelUI:GetPlayerCharacter()
  print(bWriteLog and "BackPackPanelUI:GetPlayerCharacter")
  if not slua.isValid(self.uPlayerCharacter) then
    self.uPlayerCharacter = GameplayData.GetPlayerCharacter()
  end
  return self.uPlayerCharacter
end
function BackPackPanelUI:GetWeaponManager()
  print(bWriteLog and "BackPackPanelUI:GetWeaponManager")
  if not slua.isValid(self.uWeaponManager) then
    local uPlayerCharacter = self:GetPlayerCharacter()
    if not slua.isValid(uPlayerCharacter) then
      print(bWriteLog and "BackPackPanelUI:GetWeaponManager Error, uPlayerCharacter is invalid")
      return
    end
    self.uWeaponManager = uPlayerCharacter:GetWeaponManager()
  end
  return self.uWeaponManager
end
function BackPackPanelUI:CheckIsShowMeleeGuide(DefineID, OperationType, Reason)
  if self.bShowMeleeGuide ~= 0 then
    return
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  if SettingModule:GetOptionValue("bDropUnusefulMelee") then
    return
  end
  local BackpackUtils = import("BackpackUtils")
  local SubType = BackpackUtils.GetItemSubType(DefineID.TypeSpecificID)
  if SubType ~= 108 then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uBackPackComp = uPlayerController:GetBackpackComponent()
  if not slua.isValid(uBackPackComp) then
    return
  end
  local bFindOtherMelee = false
  local AllItems = uBackPackComp:GetAllItemList(0)
  for _, Item in pairs(AllItems) do
    if slua.isValid(Item) and Item.DefineID ~= DefineID then
      local ItemDefineID = Item.DefineID
      if BackpackUtils.GetItemSubType(Item.DefineID.TypeSpecificID) == 108 and ItemDefineID.InstanceID ~= DefineID.InstanceID then
        bFindOtherMelee = true
        self.bShowMeleeGuide = 1
        EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SET_SHOW_DROP_MELEE_GUIDE)
        break
      end
    end
  end
  print(bWriteLog and "BackPackPanelUI:CheckIsShowMeleeGuide ", bFindOtherMelee)
end
function BackPackPanelUI:CreateFriendlyBehaviorUI()
  local FormatLog = FuncUtil.FormatLog
  if not FriendlyBehaviorModule.IsEnableFriendlyGiftBox() then
    FormatLog("Create FriendlyBehaviorUI failed. FriendlyBehaviorModule.IsEnableFriendlyGiftBox() is false")
    return
  end
  self.FriendlyBehaviorUI = UIManager.ShowUI(UIManager.UI_Config_InGame.FriendlyBehavior_Slot_UIBP)
  if not self.FriendlyBehaviorUI then
    FormatLog("Create FriendlyBehaviorUI failed. FriendlyBehaviorUI is nil")
    return
  end
  if not self.FriendlyBehaviorUI.UIRoot then
    FormatLog("Create FriendlyBehaviorUI failed. FriendlyBehaviorUI.UIRoot is nil")
    return
  end
  self.ArmorSlotItem_FriendlyBehavior = self.FriendlyBehaviorUI.UIRoot
  local EBackpackClothArmorType = UEnums.EBackpackClothArmorType
  self.ArmorSlotType2WidgetMap[EBackpackClothArmorType.FriendlyBehavior] = self.ArmorSlotItem_FriendlyBehavior
  local TableUtil = require("common.table_util")
  TableUtil.UniqueInsert(self.ArmorPlotItemArray, self.ArmorSlotItem_FriendlyBehavior)
  local GridSlot = self.UniformGridPanel_Armor:AddChildToUniformGrid(self.ArmorSlotItem_FriendlyBehavior)
  local Row = self:GetSlotRow(EBackpackClothArmorType.FriendlyBehavior)
  GridSlot:SetRow(Row)
  GridSlot:SetVerticalAlignment(UEnums.EVerticalAlignment.VAlign_Center)
  FormatLog("Create ArmorSlotItem_FriendlyBehavior finished. ClothArmorType[%d] Row[%d]", EBackpackClothArmorType.FriendlyBehavior, Row)
  self.FriendlyInfoPanel = self:CreateChildWindow("CanvasPanel_friendly2", UIManager.UI_Config_InGame.FriendlyBehavior_InfoPanel_UIBP)
  if self.FriendlyInfoPanel then
    self.FriendlyInfoPanel:SetAnchors(0, 0.3819, 1, 0.3819)
    self.FriendlyBehaviorUI:SetInfoPanel(self.FriendlyInfoPanel)
  end
end
function BackPackPanelUI:OnAttachedToVehicle()
  print(bWriteLog and "BackPackPanelUI:OnAttachedToVehicle")
  if not self.ArmorSlotItem_FriendlyBehavior then
    print(bWriteLog and "BackPackPanelUI:OnAttachedToVehicle Error, ArmorSlotItem_FriendlyBehavior is invalid")
    return
  end
  self.ArmorSlotItem_FriendlyBehavior:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.FriendlyInfoPanel then
    self.FriendlyInfoPanel:Hide()
  end
end
function BackPackPanelUI:OnDetachedFromVehicle()
  print(bWriteLog and "BackPackPanelUI:OnDetachedFromVehicle")
  if not self.ArmorSlotItem_FriendlyBehavior then
    print(bWriteLog and "BackPackPanelUI:OnDetachedFromVehicle Error, ArmorSlotItem_FriendlyBehavior is invalid")
    return
  end
  self.ArmorSlotItem_FriendlyBehavior:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Util")
require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_ScrollList")
require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_ArmorSlot")
require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Weapon")
require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_DragDrop")
require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_SubControl")
require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Mod")
local Class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return Class(UIBase, nil, BackPackPanelUI)