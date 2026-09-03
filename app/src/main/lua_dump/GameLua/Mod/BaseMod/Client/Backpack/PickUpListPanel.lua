local PickUpListPanel_BP = {bWriteAutoPickLog = false}
local audio_util = require("client.common.audio_util")
local BackpackUtils = import("BackpackUtils")
local GameBackendHUD = import("GameBackendHUD")
local GameplayStatics = import("GameplayStatics")
local KismetMathLibrary = import("KismetMathLibrary")
local KismetTextLibrary = import("KismetTextLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local STExtraUIUtils = import("STExtraUIUtils")
local SettingSubsystem = import("SettingSubsystem")
local SubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local FBattleSearchBoxSortingInfo = import("/Script/ShadowTrackerExtra.BattleSearchBoxSortingInfo")
local FBattleSearchItemSortingInfo = import("BattleSearchItemSortingInfo")
local EFreshWeaponStateType = import("EFreshWeaponStateType")
local EGameModeType = import("EGameModeType")
local EItemStoreArea = import("EItemStoreArea")
local EPawnState = import("EPawnState")
local ESlateVisibility = import("ESlateVisibility")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TableUtil = require("common.table_util")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local USlateBlueprintLibrary = import("SlateBlueprintLibrary")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
function PickUpListPanel_BP:OnInitialize()
  PickUpListPanel_BP.__super.OnInitialize(self)
  self.Button_OBmode_HideList = self.UIRoot.Button_OBmode_HideList
  self.Button_Sixpalaces = self.UIRoot.Button_Sixpalaces
  self.CanvasPanel_PickBoxItemGuide = self.UIRoot.CanvasPanel_PickBoxItemGuide
  self.CanvasPanel_PickupDetail_XAndT = self.UIRoot.CanvasPanel_PickupDetail_XAndT
  self.CustomizePickUpPanel_BP = self.UIRoot.CustomizePickUpPanel_BP
  self.DeadBoxBtnExistControl = self.UIRoot.DeadBoxBtnExistControl
  self.GridPanel_6 = self.UIRoot.GridPanel_6
  self.GridPanel_Mode = self.UIRoot.GridPanel_Mode
  self.GridPanel_PickUpList = self.UIRoot.GridPanel_PickUpList
  self.ImageNine = self.UIRoot.ImageNine
  self.PickUpBtnExistControl = self.UIRoot.PickUpBtnExistControl
  self.PickUpListItem_Row_BP = self.UIRoot.PickUpListItem_Row_BP
  self.ScrollBox_PickUpListMode1 = self.UIRoot.ScrollBox_PickUpListMode1
  self.ScrollBox_PickUpListMode2 = self.UIRoot.ScrollBox_PickUpListMode2
  self.ShortcutMenu_BP = self.UIRoot.ShortcutMenu_BP
  self.SizeBox_PanelList = self.UIRoot.SizeBox_PanelList
  self.TextBlockNine = self.UIRoot.TextBlockNine
  self.Tips14 = self.UIRoot.Tips14
  self.Tips14_1 = self.UIRoot.Tips14_1
  self.UTRichTextBlock_Tips14 = self.UIRoot.UTRichTextBlock_Tips14
  self.UTRichTextBlock_Tips14_1 = self.UIRoot.UTRichTextBlock_Tips14_1
  self.WidgetSwitcher_0 = self.UIRoot.WidgetSwitcher_0
  self.WidgetSwitcherCol = self.UIRoot.WidgetSwitcherCol
  self.WrapBox_Mode2 = self.UIRoot.WrapBox_Mode2
  self.DisplayStuffType = UEnums.EGroudStuffType.NormalStuff
  self.PickupToolTips = nil
  self.ToolTipsOffset = FVector2D(-300, -80)
  self.bGroundExist = false
  self.playerChoise = UEnums.EGroudStuffType.NormalStuff
  self.boxChoise = 0
  self.boxColumn = 0
  self.bHideForAim = false
  self.InAutoPickCD = false
  self.lastAutoPickTime = 0
  self.AutoPickupSwitcher = false
  self.DisableAutoPickupSwitcher = false
  self.AutoPickDelay = 0.3
  self.NeiborItemBoxName = "**********"
  self.PlayerBoxColumn = 3
  self.MoveOut = false
  self.isTrainingMode = false
  self.ForbitAutoPickByMode = false
  self.PauseAutoPickItem = {}
  self.bCloseNormal = false
  self.bCloseNormalAuto = false
  self.usefulLimit = 5
  self.GroundItemList = self.UIRoot.GroundItemList
  self.AutoPickupSwitcher_pve = false
  self.DisableAutoPickupSwitcher_pve = false
  self.IsFobidExpandDeadBox = false
  self.IsAutoExpandBox = false
  self.PickUpListMode = 0
  self.IsGroundContainsUseful = false
  self.bShowBackpack = false
  self.IsEnableWeaponAttachmentBindToWeapon = STExtraModLogicSwitchLibrary.IsEnableWeaponAttachmentBindToWeapon()
  if slua.isValid(self.UIRoot.CustomizePickUpPanel_BP) then
    self.UIRoot.CustomizePickUpPanel_BP.BTReuseList:DoInit()
  end
  self._WhiteLinearColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
  self._WhiteSlateColor = FSlateColor(self._WhiteLinearColor)
  self._TranslucentLinearColor = FLinearColor(1.0, 1.0, 1.0, 0.5)
  self._TranslucentSlateColor = FSlateColor(self._TranslucentLinearColor)
  self._TempPos2D = FVector2D(0, 0)
  self.TextBlockNine:SetColorAndOpacity(self._WhiteSlateColor)
  self:SetPanelShow(false)
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) then
    self.isTrainingMode = uGameState.bIsTrainingMode
    self.ForbitAutoPickByMode = uGameState.bForbitAutoPick
  end
  self.bWriteAutoPickLog = bWriteLog and self.bWriteAutoPickLog
  self.ForceUpdateBox = false
  self.BTreuseCreateItemTimer = nil
  self.AllGroundItemBase = {}
end
function PickUpListPanel_BP:OnPostInitialize()
  PickUpListPanel_BP.__super.OnPostInitialize(self)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.BackPackPickUpPanel_BP then
    MainControlBaseUI.BackPackPickUpPanel_BP.GridPanel_0:AddChild(self.UIRoot)
  end
  self.SearchedPickupItemInfo = self.UIRoot.SearchedPickupItemInfo
  self.AllSearchedTombBoxesInfo = self.UIRoot.AllSearchedTombBoxesInfo
  local proxy = self.UIRoot:GetPickupItemUsefulProxy(self.UIRoot)
  print(bWriteLog and "PickUpListPanel_BP:OnPostInitialize", proxy, Client.IsShipping())
  if proxy then
    proxy.EnableUsefulCacheReport = true
    if bWriteLog then
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      print(bWriteLog and UKismetSystemLibrary.GetClassPathName(proxy))
    end
  end
end
function PickUpListPanel_BP:RegistEvents()
  PickUpListPanel_BP.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Button_Ninepalaces, "OnClicked", self.OnClicked_Button_Ninepalaces, self)
  self:AddControlEventByControl(self.UIRoot.Button_Sixpalaces, "OnClicked", self.OnClicked_Button_Sixpalaces, self)
  self:AddControlEventByControl(self.UIRoot.Button_OBmode_HideList, "OnClicked", self.OnClicked_Button_OBmode_HideList, self)
  self:AddControlEventByControl(self.ShortcutMenu_BP, "ClickNormal", self.OnClickNormal, self)
  self:AddControlEventByControl(self.CustomizePickUpPanel_BP.ShortcutMenu_BP, "ClickNormal", self.OnClickNormal, self)
  self:AddControlEventByControl(self.ShortcutMenu_BP, "ClickClosePickup", self.ClickCloseCustomPanel, self)
  self:AddControlEventByControl(self.CustomizePickUpPanel_BP.ShortcutMenu_BP, "ClickClosePickup", self.ClickCloseCustomPanel, self)
  self:AddControlEventByControl(self.ShortcutMenu_BP, "ClickCloseBox", self.ClickCloseBoxByHand, self)
  self:AddControlEventByControl(self.CustomizePickUpPanel_BP, "CloseCustomPickUpPanel", self.ClickCloseCustomPanel, self)
  self:AddControlEventByControl(self.ScrollBox_PickUpListMode1, "OnMoveOut", self.OnMoveOut, self)
  self:AddControlEventByControl(self.ShortcutMenu_BP.PickUpBtnItem_BP, "ClickBoxTab", self.OnClickBoxTab, self)
  self:AddControlEventByControl(self.CustomizePickUpPanel_BP.ShortcutMenu_BP.PickUpBtnItem_BP, "ClickBoxTab", self.OnClickBoxTab, self)
  self:AddControlEventByControl(self.UIRoot.Button_PickupTombBox, "OnClicked", self.OnClicked_Button_PickupTombBox, self)
  self:AddUIMessageEvent("UIMsgEnterVehicleCompleted", self.OnEnterVehicleCompleted, self)
  self:AddUIMessageEvent("UIMsg_RefreshPlayerTombBoxCheckSum", self.UIMsg_RefreshPlayerTombBoxCheckSum, self)
  self:AddUIMessageEvent("UIMsg_UpdatePickUpList", self.UpdateListData, self)
  self:AddUIMessageEvent("UIMsg_ClearPickupChecksum", self.ClearAllCheckSum, self)
  self:AddUIMessageEvent("UIMsg_ShowOBAirDropBox", self.UIMsg_ShowOBAirDropBox, self)
  self:AddUIMessageEvent("UIMsg_HideOBAirDropBox", self.UIMsg_HideOBAirDropBox, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.GridPanel_root, self, "PickUpListPanel_BP_Root")
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_SHOWHIDE_BACKPACK_PANEL, self.OnBackPackShowOrHide, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_CLOSE, self.OnBackPackShowOrHide, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_CLEAR_ALL_CHECK_SUM, self.ClearAllCheckSum, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_ENTER_PLANE, self.UpdateListData, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_REVIVAL, function()
    print(bWriteLog and "PickUpListPanel_BP:RegistEvents EVENTID_PLAYEREVENT_REVIVAL")
    self:ClearAllCheckSum()
  end)
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    self.uWeaponManager = nil
    self.uPlayerCharacter = nil
    self:RegistPlayerDelegate()
    self:RegistBackPackComponentDelegate()
    self:RegistWeaponManagerDelegate()
  end)
  self:RegistSettings()
  self:ClearAllCheckSum()
  self:RegistBTReuseListEvent()
  self:Collapsed()
  self.UIRoot.CustomizePickUpPanel_BP.ShortcutMenu_BP:OpenPickList()
  self.UIRoot.Button_PickupTombBox:SetVisibility(ESlateVisibility.Collapsed)
  if slua.isValid(CGameState) then
    local uSTExtraDelegateMgr = import("STExtraDelegateMgr")
    local DelegateMgrInstance = uSTExtraDelegateMgr.STExtraDelegateMgrInstance(CGameState)
    self:AddControlEventByControl(DelegateMgrInstance, "OnCanCarryAnyActorChange", self.OnCanCarryAnyActorEvent, self)
  end
end
function PickUpListPanel_BP:OnCanCarryAnyActorEvent(CarryActor, Owner, IsTurnInto, bHasDifference, CompositeName)
  if CompositeName ~= "CanCarrySomeTombBox" then
    return
  end
  if not slua.isValid(Owner) then
    return
  end
  self.CarryPlayerTombBox = CarryActor
  local Visibility = IsTurnInto and ESlateVisibility.Visible or ESlateVisibility.Collapsed
  self.UIRoot.Button_PickupTombBox:SetVisibility(Visibility)
end
function PickUpListPanel_BP:OnClicked_Button_PickupTombBox()
  if not slua.isValid(self.CarryPlayerTombBox) then
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local EPawnState = import("EPawnState")
  if PlayerCharacter:AllowState(EPawnState.CarryBox, true) then
    local ECharacterSearchEnum = import("ECharacterSearchEnum")
    local EExecutionCondition = import("EExecutionCondition")
    if slua.isValid(PlayerCharacter.SearchOtherComponent) then
      PlayerCharacter.SearchOtherComponent:ImmediatelySearch(ECharacterSearchEnum.CanCarryPlayerTombBox, EExecutionCondition.Client)
    end
    if slua.isValid(self.CarryPlayerTombBox) then
      print(bWriteLog and "PickUpListPanel_BP:OnClicked_Button_PickupTombBox Start Carry Box")
      PlayerCharacter:ServerRPC_CarryDeadBox(self.CarryPlayerTombBox)
    end
  else
    print(bWriteLog and "PickUpListPanel_BP:OnClicked_Button_PickupTombBox Start Carry Box failed, not allow")
  end
end
function PickUpListPanel_BP:OnUnRegistEvents()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.GridPanel_root)
end
function PickUpListPanel_BP:SetPanelShow(bShow)
  if self.IsPickUpListPanelShow == bShow then
    return
  end
  print(bWriteLog and "PickUpListPanel_BP:SetPanelShow", bShow)
  self.IsPickUpListPanelShow = bShow
  self.UIRoot.bShowGridPickupListPanel = bShow
end
function PickUpListPanel_BP:OnEnterVehicleCompleted()
  local PC = GameplayData.GetPlayerController()
  if not (slua.isValid(PC) and PC.BP_VehicleUser) or not slua.isValid(PC.BP_VehicleUser.Vehicle) then
    print(bWriteLog and "PickUpListPanel_BP:OnEnterVehicleCompleted cont find PC or BP_VehicleUser")
    return
  end
  if not PC.BP_VehicleUser.Vehicle:IsUAV() then
    return
  end
  print(bWriteLog and "PickUpListPanel_BP:OnEnterVehicleCompleted")
  self:ClickCloseBoxPanel()
  self:FillButton()
end
function PickUpListPanel_BP:RegistPlayerDelegate()
  print(bWriteLog and "PickUpListPanel_BP:RegistPlayerDelegate")
  local uPlayerController = self:GetPlayerController()
  local uPlayerCharacter = self:GetPlayerCharacter()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PickUpListPanel_BP:RegistPlayerDelegate Error, uPlayerController is invalid")
    return
  end
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "PickUpListPanel_BP:RegistPlayerDelegate Error, uPlayerCharacter is invalid")
    return
  end
  self:AddControlEventByControl(uPlayerController, "OnPlayerEnterFlying", function()
    local uPlayerController = self:GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController.bInItemGenerator = false
      uPlayerController.bInTombBoxGenerator = false
    end
    self:UpdateListData()
    self.UIRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.bIsShowingOBAirDrop = false
  end)
  self:AddControlEventByControl(uPlayerCharacter, "OnHasPickupPropsAvailableChanged", function(bShow)
    local uPlayerController = self:GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController.bInItemGenerator = bShow
    end
    self.bNeedFillBtn = true
    self:UpdateListData()
    self:NotifyPickup(bShow)
  end)
  self:AddControlEventByControl(uPlayerCharacter, "OnHasTombBoxesAvailableChanged", function(bShow)
    local uPlayerController = self:GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController.bInTombBoxGenerator = bShow
    end
    self.bNeedFillBtn = true
    self:UpdateListData()
    self:NotifyBox(bShow)
    if not bShow then
      self.UIRoot:ClearSearchedTombBoxes()
    end
  end)
  self:AddControlEventByControl(uPlayerCharacter, "OnTombBoxesNumChanged", function(bShow)
    self:FillButton()
  end)
end
function PickUpListPanel_BP:RegistBackPackComponentDelegate()
  print(bWriteLog and "PickUpListPanel_BP:RegistBackPackComponentDelegate")
  local uBackPackComponent = self:GetBackpackComponent()
  if not slua.isValid(uBackPackComponent) then
    print(bWriteLog and "PickUpListPanel_BP:RegistBackPackComponentDelegate Error, uBackPackComponent is invalid")
    return
  end
  self:AddControlEventByControl(uBackPackComponent, "ItemOperationDelegate", self.OnItemOperation, self)
end
function PickUpListPanel_BP:RegistWeaponManagerDelegate()
  local uWeaponManager = self:GetWeaponManager()
  if not slua.isValid(uWeaponManager) then
    print(bWriteLog and "PickUpListPanel_BP:RegistWeaponManagerDelegate Error, uWeaponManager is invalid")
    return
  end
  self:AddControlEventByControl(uWeaponManager, "ChangeInventoryDataDelegate", self.ClearAllCheckSum, self)
  self:AddControlEventByControl(uWeaponManager, "ChangeCurrentUsingWeaponDelegate", self.ClearAllCheckSum, self)
end
function PickUpListPanel_BP:RegistSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  self.AutoPickupSwitcher = SettingConfig.AutoPickupSwitcher
  self.DisableAutoPickupSwitcher = SettingConfig.DisableAutoPickupSwitcher
  self.PickUpListMode = SettingConfig.PickUpListMode
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    SettingSubsystem:RegisterUserSettingsDelegate_Bool("AutoPickupSwitcher", function(bAutoPickupSwitch)
      print(bWriteLog and "PickUpListPanel_BP:RegistEvents bAutoPickupSwitch:" .. tostring(bAutoPickupSwitch))
      self.AutoPickupSwitcher = bAutoPickupSwitch
      self:ClearAllCheckSum()
    end)
    SettingSubsystem:RegisterUserSettingsDelegate_Bool("DisableAutoPickupSwitcher", function(bDisableAutoPickupSwitcher)
      print(bWriteLog and "PickUpListPanel_BP:RegistEvents bDisableAutoPickupSwitcher:" .. tostring(bDisableAutoPickupSwitcher))
      self.DisableAutoPickupSwitcher = bDisableAutoPickupSwitcher
      self:ClearAllCheckSum()
    end)
    SettingSubsystem:RegisterUserSettingsDelegate_Int("PickUpListMode", function(nPickUpListMode)
      print(bWriteLog and "PickUpListPanel_BP:RegistEvents nPickUpListMode:" .. tostring(nPickUpListMode))
      self.PickUpListMode = nPickUpListMode
      self:ClearAllCheckSum()
    end)
    self:SetAutoPickMeleeType()
    SettingSubsystem:RegisterUserSettingsDelegate_Int("AutoPickMeleeType", function(AutoPickMeleeType)
      self:SetAutoPickMeleeType(AutoPickMeleeType)
    end)
  end
end
function PickUpListPanel_BP:OnClicked_Button_ClosePickUpListUI()
  self:ClickCloseBoxPanel()
end
function PickUpListPanel_BP:RegistBTReuseListEvent()
  for Index = 0, self.CustomizePickUpPanel_BP.WrapBoxPickUpList:GetChildrenCount() - 1 do
    local AsPickUpItemSBP = self.CustomizePickUpPanel_BP.WrapBoxPickUpList:GetChildAt(Index)
    if Game:IsValid(AsPickUpItemSBP) then
      AsPickUpItemSBP.ParentUserWidget = self.UIRoot
    end
  end
  BackpackUtils.InitialItemTable()
  self:InitBTReuseList()
  self:AddControlEventByControl(self.CustomizePickUpPanel_BP.BTReuseList, "itemUpdateDelegate", self.UpdateGroundList, self)
  self:AddControlEventByControl(self.CustomizePickUpPanel_BP.BTReuseList, "OnCreateItem", self.OnBTReuseListCreateItem, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_INIT_REPLAYUI, function(_, __, ...)
    self:OnInitReplayUI(...)
  end)
end
function PickUpListPanel_BP:InitBTReuseList()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local PickUpConfig = GamePlayTools.GetCurrentConfig("PickUpConfig")
  local ItemPath = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/PickUpItem_S_BP.PickUpItem_S_BP"
  if PickUpConfig and PickUpConfig.PickUpListItemPath and PickUpConfig.PickUpListItemPath ~= "" then
    ItemPath = PickUpConfig.PickUpListItemPath
  end
  print(bWriteLog and "PickUpListPanel_BP:InitBTReuseList ItemPath:" .. tostring(ItemPath))
  local PickUpItemClass = slua.loadClass(ItemPath)
  self.CustomizePickUpPanel_BP.BTReuseList.itemClass = PickUpItemClass
  self.CustomizePickUpPanel_BP.BTReuseList:SetTemplate(self.UIRoot, 5)
  if self.BTreuseCreateItemTimer == nil then
    self:BTReuseListDelayCreateItem()
    self.BTreuseCreateItemTimer = self:AddGameTimer(0.1, true, function()
      self:BTReuseListDelayCreateItem()
    end)
  end
end
function PickUpListPanel_BP:BTReuseListDelayCreateItem()
  local BTReuseList = self.CustomizePickUpPanel_BP.BTReuseList
  if not BTReuseList then
    print(bWriteLog and "PickUpListPanel_BP:BTReuseListDelayCreateItem BTReuseList is nil")
    if self.BTreuseCreateItemTimer then
      self:RemoveGameTimer(self.BTreuseCreateItemTimer)
      self.BTreuseCreateItemTimer = nil
    end
    return
  end
  local nCurCount = BTReuseList.itemList:Num()
  if nCurCount < BTReuseList.visibleNum then
    local newItem = UIManager.ShowUI(UIManager.UI_Config_InGame.PickUpListItem)
    local newWidget = newItem.UIRoot
    if not newWidget then
      return
    end
    self:AddControlEventByControl(newWidget, "widgetSizeNofity", BTReuseList.UpdateSingleHeight)
    BTReuseList.FBox:AddChild(newWidget)
    newWidget:SetVisibility(ESlateVisibility.Collapsed)
    BTReuseList.itemList:Add(newWidget)
    self.AllGroundItemBase[newWidget] = newItem
    if newItem then
      newItem:SetHorizontalAlignment(UEnums.EHorizontalAlignment.HAlign_Fill)
    end
  else
    self:OnBTReuseListCreateItem()
    if self.BTreuseCreateItemTimer then
      self:RemoveGameTimer(self.BTreuseCreateItemTimer)
      self.BTreuseCreateItemTimer = nil
    end
  end
end
function PickUpListPanel_BP:OnClickNormal()
  self.CustomizePickUpPanel_BP.GridPanel_PickUpList:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.playerChoise = UEnums.EGroudStuffType.NormalStuff
  self.bCloseNormal = false
  self.bNeedFillBtn = true
  self:UpdateListData()
  self:ShowPickMode(UEnums.EGroudStuffType.NormalStuff)
end
function PickUpListPanel_BP:AutoPickOne(pickUpResult)
  print(bWriteLog and self.bWriteAutoPickLog and string.format("[AutoPick]PickUpListPanel_BP:AutoPickOne InPickCD=%s, PickDelay=%f, [Type=%d,Id=%d,Count=%d]", tostring(self.InAutoPickCD), self.AutoPickDelay, pickUpResult.MainItemData.ID.Type, pickUpResult.MainItemData.ID.TypeSpecificID, pickUpResult.MainItemData.Count))
  if self.InAutoPickCD then
    return
  end
  self.InAutoPickCD = true
  pickUpResult = pickUpResult:clone()
  self:AddTimer(self.AutoPickDelay, function()
    local AsSTExtraBaseCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(AsSTExtraBaseCharacter) then
      return
    end
    if self.bHideForAim then
      print(bWriteLog and self.bWriteAutoPickLog and string.format("[AutoPick]PickUpListPanel_BP:AutoPickOne bHideForAim, [Type=%d,Id=%d,Count=%d]", pickUpResult.MainItemData.ID.Type, pickUpResult.MainItemData.ID.TypeSpecificID, pickUpResult.MainItemData.Count))
      coroutine.yield(self.AutoPickDelay)
      self.InAutoPickCD = false
      self.AutoPickDelay = 0.15
    else
      local useful = self:GetUseful2(slua.IndexReference(pickUpResult, "MainItemData", "ID"), pickUpResult)
      if 0 < useful then
        print(bWriteLog and self.bWriteAutoPickLog and string.format("[AutoPick]PickUpListPanel_BP:AutoPickOne RealAutoPick, [Type=%d,Id=%d,Count=%d]", pickUpResult.MainItemData.ID.Type, pickUpResult.MainItemData.ID.TypeSpecificID, pickUpResult.MainItemData.Count))
        self:PickUpWrapperActor(AsSTExtraBaseCharacter, pickUpResult, useful)
        coroutine.yield(self.AutoPickDelay)
        self.InAutoPickCD = false
        self.AutoPickDelay = 0.15
      else
        self.InAutoPickCD = false
        self.AutoPickDelay = 0.15
        print(bWriteLog and self.bWriteAutoPickLog and string.format("[AutoPick]PickUpListPanel_BP:AutoPickOne No Useful, [Type=%d,Id=%d,Count=%d]", pickUpResult.MainItemData.ID.Type, pickUpResult.MainItemData.ID.TypeSpecificID, pickUpResult.MainItemData.Count))
      end
    end
  end)
end
function PickUpListPanel_BP:OnMoveOut(bMoveOut)
  self.MoveOut = bMoveOut
end
function PickUpListPanel_BP:OnClicked_Button_Sixpalaces()
  self.PickUpListMode = 1
  local col = self:GetPickUpColByCurrentMode()
  self:PlayerSetBoxCol(col)
  self:ShowPickMode(UEnums.EGroudStuffType.DeadBoxStuff)
  local FirstGameFrontendHUD = GameBackendHUD.GetInstance():GetFirstGameFrontendHUD(self.UIRoot)
  local UserSettings = FirstGameFrontendHUD:GetUserSettings()
  local AsSettingConfig_3 = UserSettings
  if Game:IsValid(AsSettingConfig_3) then
    AsSettingConfig_3.PickUpListMode = self.PickUpListMode
    FirstGameFrontendHUD:FinishModifyUserSettings()
  end
end
function PickUpListPanel_BP:OnClicked_Button_Ninepalaces()
  self.PickUpListMode = 0
  local col = self:GetPickUpColByCurrentMode()
  self:PlayerSetBoxCol(col)
  self:ShowPickMode(UEnums.EGroudStuffType.DeadBoxStuff)
  local FirstGameFrontendHUD = GameBackendHUD.GetInstance():GetFirstGameFrontendHUD(self.UIRoot)
  local UserSettings = FirstGameFrontendHUD:GetUserSettings()
  local AsSettingConfig_3 = UserSettings
  if Game:IsValid(AsSettingConfig_3) then
    AsSettingConfig_3.PickUpListMode = self.PickUpListMode
    FirstGameFrontendHUD:FinishModifyUserSettings()
  end
end
function PickUpListPanel_BP:OnClicked_Button_OBmode_HideList()
  local AsBPSTExtraPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(AsBPSTExtraPlayerController) then
    AsBPSTExtraPlayerController:CastUIMsg("HideAllDropBoxIcon", "observe")
    self.UIRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.bIsShowingOBAirDrop = false
  end
end
function PickUpListPanel_BP:OnBTReuseListCreateItem()
  if self.SearchedPickupItemInfo == nil then
    return
  end
  self:FillGroundList(self.SearchedPickupItemInfo.SortedItemsArray)
end
function PickUpListPanel_BP:UpdateListData()
  local uPlayerCharacter = self:GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "PickUpListPanel_BP:UpdateListData error uPlayerCharacter is invald")
    return
  end
  local uBackPackComponent = self:GetBackpackComponent()
  if not slua.isValid(uBackPackComponent) then
    print(bWriteLog and "PickUpListPanel_BP:UpdateListData error uBackPackComponent is invald")
    return
  end
  local uPlayerState = uPlayerCharacter:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "PickUpListPanel_BP:UpdateListData error uPlayerState is invald")
    return
  end
  if self.SearchedPickupItemInfo == nil or self.AllSearchedTombBoxesInfo == nil then
    print(bWriteLog and "PickUpListPanel_BP:UpdateListData error SearchedPickupItemInfo or AllSearchedTombBoxesInfo is nil", self.SearchedPickupItemInfo, self.AllSearchedTombBoxesInfo)
    return
  end
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if uPlayerState.LiveState ~= ExtraPlayerLiveState.InDefault then
    print(bWriteLog and "PickUpListPanel_BP:UpdateListData error uPlayerState is invald uPlayerState.LiveState:" .. tostring(uPlayerState.LiveState))
    self.UIRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
    return
  end
  print(bWriteLog and "PickUpListPanel_BP:UpdateListData [IsEnableOptimizePickupUIPanel]")
  self.UIRoot:UpdatePickupsAndTombBoxesData(uPlayerCharacter)
  if self.UIRoot.bNeedRefreshPickupList then
    self:FillGroundList(self.SearchedPickupItemInfo.SortedItemsArray)
    self.IsGroundContainsUseful = self.UIRoot.bPickupListHasUsefulItem
  end
  self.bSuccessAutoPickOne = false
  self:CheckPlayerCanAutoPick(uPlayerCharacter, uBackPackComponent)
  if self.bPlayerShouldAutoPick and uPlayerCharacter:HaveAvailablePickupProps() then
    if self.CustomizePickUpPanel_BP.GridPanel_PickUpList:GetVisibility() == ESlateVisibility.SelfHitTestInvisible or not self.DisableAutoPickupSwitcher then
      self:AutoPickGroundItem(uPlayerCharacter, self.SearchedPickupItemInfo.SortedItemsArray)
    end
  else
    print(bWriteLog and "PickUpListPanel_BP:UpdateListData skip autoloot")
  end
  if self.UIRoot.bNeedRefreshTombBoxesList then
    self:FillTombBoxList(uPlayerCharacter, uBackPackComponent)
  end
  if self.bNeedFillBtn then
    self:FillButton()
    self.bNeedFillBtn = false
  end
end
function PickUpListPanel_BP:CheckPlayerCanAutoPick(uPlayerCharacter, uBackPackComponent)
  self.bPlayerShouldAutoPick = BackpackUtils.ShouldAutoPickItem(self.UIRoot, uBackPackComponent, self.AutoPickupSwitcher, self.AutoPickupSwitcher_pve, self.bHideForAim, self.isTrainingMode, self.ForbitAutoPickByMode)
  if self.bPlayerShouldAutoPick and uPlayerCharacter:HasState(EPawnState.UseConsumables) then
    self.bPlayerShouldAutoPick = false
    print(bWriteLog and self.bWriteAutoPickLog and "PickUpListPanel_BP:CheckPlayerCanAutoPick false UseConsumables")
  end
  if self.bPlayerShouldAutoPick and not uPlayerCharacter:AllowState(EPawnState.Pick, false) then
    self.bPlayerShouldAutoPick = false
    print(bWriteLog and self.bWriteAutoPickLog and "PickUpListPanel_BP:CheckPlayerCanAutoPick false not allow state Pick")
  end
  print(bWriteLog and self.bWriteAutoPickLog and "PickUpListPanel_BP:CheckPlayerCanAutoPick " .. tostring(self.bPlayerShouldAutoPick))
end
function PickUpListPanel_BP:ShowToolTips(Image, ItemName, ItemDesc)
  local AsPickUpItemTipsBP = self:GetToolTipsSingleton()
  if Game:IsValid(AsPickUpItemTipsBP) then
    AsPickUpItemTipsBP:UpdateData(Image, ItemName, ItemDesc, 0, 0.0, 0)
    AsPickUpItemTipsBP:AddToViewport(10)
    local MousePositionOnViewport = WidgetLayoutLibrary.GetMousePositionOnViewport(self.UIRoot)
    AsPickUpItemTipsBP:SetPositionInViewport(MousePositionOnViewport + self.ToolTipsOffset, true)
  end
end
function PickUpListPanel_BP:ShowToolTipsByIconPath(IconPath, ItemName, ItemDesc)
  local AsPickUpItemTipsBP = self:GetToolTipsSingleton()
  if Game:IsValid(AsPickUpItemTipsBP) then
    AsPickUpItemTipsBP:UpdateDataByIconPath(IconPath, ItemName, ItemDesc, 0, 0.0, 0)
    AsPickUpItemTipsBP:AddToViewport(10)
    local MousePositionOnViewport = WidgetLayoutLibrary.GetMousePositionOnViewport(self.UIRoot)
    AsPickUpItemTipsBP:SetPositionInViewport(MousePositionOnViewport + self.ToolTipsOffset, true)
  end
end
function PickUpListPanel_BP:HideToolTips()
  if self:GetIsShowingToolTips() and slua.isValid(self.PickupToolTips) then
    self.PickupToolTips:RemoveFromParent()
  end
end
function PickUpListPanel_BP:GetToolTipsSingleton()
  if slua.isValid(self.PickupToolTips) then
    return self.PickupToolTips
  else
    self.PickupToolTips = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/MainBackPackUI/PickUpItemTips_BP.PickUpItemTips_BP_C", self.UIRoot)
    return self.PickupToolTips
  end
end
function PickUpListPanel_BP:GetIsShowingToolTips()
  local ToolTipsSingleton = self:GetToolTipsSingleton()
  if not slua.isValid(ToolTipsSingleton) then
    return false
  end
  if ToolTipsSingleton:IsInViewport() then
    return true
  else
    return false
  end
end
function PickUpListPanel_BP:ChangeLayoutOnBackpackShow(bShow, bBRTDMStore)
  if bShow then
    self._TempPos2D.X = -388
    self._TempPos2D.Y = 0
    if bBRTDMStore then
      self._TempPos2D.X = -638
    end
    self.UIRoot.CanvasGroup_Pickup:SetRenderTranslation(self._TempPos2D)
    if self.IsEnableWeaponAttachmentBindToWeapon then
      self._TempPos2D.X = 0
      self._TempPos2D.Y = 140
      self.CustomizePickUpPanel_BP:SetRenderTranslation(self._TempPos2D)
    end
    self.UIRoot.Canvas_PickBox:ApplyDefaultLayout()
    self.CustomizePickUpPanel_BP.Canvas_PickUp:ApplyDefaultLayout()
    self:SetBoxColumn(2)
    self.UIRoot.ShortcutMenu_BP.Image_OpenBlank:SetWidgetVisibility(ESlateVisibility.Hidden)
    self.UIRoot.CustomizePickUpPanel_BP.ShortcutMenu_BP.Image_OpenBlank:SetWidgetVisibility(ESlateVisibility.Hidden)
  else
    self._TempPos2D.X = 0
    self._TempPos2D.Y = 0
    self.UIRoot.CanvasGroup_Pickup:SetRenderTranslation(self._TempPos2D)
    if self.IsEnableWeaponAttachmentBindToWeapon then
      self.CustomizePickUpPanel_BP:SetRenderTranslation(self._TempPos2D)
    end
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if SettingSubsystem then
      SettingSubsystem:BroadcastCustomLayoutChangeByCustomType(29)
      SettingSubsystem:BroadcastCustomLayoutChangeByCustomType(31)
    end
    self:SetBoxColumn(self.PlayerBoxColumn)
    self.UIRoot.ShortcutMenu_BP.Image_OpenBlank:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.UIRoot.CustomizePickUpPanel_BP.ShortcutMenu_BP.Image_OpenBlank:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function PickUpListPanel_BP:ShowPickMode(pickType)
  self.CustomizePickUpPanel_BP.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  self.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  local bRefreshPickUpPanel = false
  if pickType == UEnums.EGroudStuffType.UndefineType then
    self.CustomizePickUpPanel_BP.GridPanel_PickUpList:SetWidgetVisibility(ESlateVisibility.Hidden)
    self:ShowOrHidePickUpListPanel(false)
    bRefreshPickUpPanel = true
  elseif pickType == UEnums.EGroudStuffType.DeadBoxStuff then
    self.CustomizePickUpPanel_BP.GridPanel_PickUpList:SetWidgetVisibility(ESlateVisibility.Hidden)
    self:ShowOrHidePickUpListPanel(true)
    bRefreshPickUpPanel = true
  elseif pickType == UEnums.EGroudStuffType.NormalStuff then
    self.CustomizePickUpPanel_BP.GridPanel_PickUpList:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self:ShowOrHidePickUpListPanel(false)
    bRefreshPickUpPanel = true
  end
  if bRefreshPickUpPanel then
    local BackPackPanel = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
    local bShowBackpack = BackPackPanel ~= nil and BackPackPanel:IsShow()
    if not bShowBackpack and self.PlayerBoxColumn ~= self.boxColumn then
      self:SetBoxColumn(self.PlayerBoxColumn)
    end
  end
end
function PickUpListPanel_BP:FillGroundList(Array)
  self.GroundItemList = Array
  local nGroundItemListNum = self.GroundItemList:Num()
  local IsActivePickupEquipIntoPack = STExtraModLogicSwitchLibrary.IsActivePickupEquipIntoPack()
  if IsActivePickupEquipIntoPack then
    self.CustomizePickUpPanel_BP.BTReuseList:SetRowNumAsUnif(185.0, 93.0, nGroundItemListNum, false)
    if nGroundItemListNum == 1 then
      self.CustomizePickUpPanel_BP.SizeBox_PanelList:SetHeightOverride(98.0)
    elseif nGroundItemListNum == 2 then
      self.CustomizePickUpPanel_BP.SizeBox_PanelList:SetHeightOverride(192.0)
    else
      self.CustomizePickUpPanel_BP.SizeBox_PanelList:SetHeightOverride(215.0)
    end
  else
    self.CustomizePickUpPanel_BP.BTReuseList:SetRowNumAsUnif(185.0, 63.0, nGroundItemListNum, false)
    if nGroundItemListNum == 1 then
      self.CustomizePickUpPanel_BP.SizeBox_PanelList:SetHeightOverride(68.0)
    elseif nGroundItemListNum == 2 then
      self.CustomizePickUpPanel_BP.SizeBox_PanelList:SetHeightOverride(132.0)
    elseif nGroundItemListNum == 3 then
      self.CustomizePickUpPanel_BP.SizeBox_PanelList:SetHeightOverride(196.0)
    else
      self.CustomizePickUpPanel_BP.SizeBox_PanelList:SetHeightOverride(215.0)
    end
  end
end
function PickUpListPanel_BP:_TryGetOneItem(TombBox, Index)
  if Index < self.ScrollBox_PickUpListMode1:GetChildrenCount() then
    local ChildItem = self.ScrollBox_PickUpListMode1:GetChildAt(Index)
    ChildItem.tombName = slua.isValid(TombBox) and TombBox.TombName or self.NeiborItemBoxName
    return ChildItem
  else
    local NewItem = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName(self:GetNewListItemPath(), self.UIRoot)
    if not slua.isValid(NewItem) then
      return nil
    end
    NewItem.tombName = slua.isValid(TombBox) and TombBox.TombName or self.NeiborItemBoxName
    self.ScrollBox_PickUpListMode1:AddChild(NewItem)
    return NewItem
  end
end
function PickUpListPanel_BP:_TryGetPickupItem(Index)
  if Index < self.ScrollBox_PickUpListMode1:GetChildrenCount() then
    local ChildItem = self.ScrollBox_PickUpListMode1:GetChildAt(Index)
    ChildItem.tombName = self.NeiborItemBoxName
    return ChildItem
  else
    local NewItem = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName(self:GetNewListItemPath(), self.UIRoot)
    if not slua.isValid(NewItem) then
      return nil
    end
    NewItem.tombName = self.NeiborItemBoxName
    self.ScrollBox_PickUpListMode1:AddChild(NewItem)
    return NewItem
  end
end
function PickUpListPanel_BP:GetNewListItemPath()
  return "/Game/BluePrints/ControlInput/MainBackPackUI/Item/PickUpListItem_Row_BP.PickUpListItem_Row_BP_C"
end
function PickUpListPanel_BP:FillButton()
  local GlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
  local bHasGroundItem, bHasTombBox
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    bHasGroundItem = uPlayerCharacter:HaveAvailablePickupProps()
    bHasTombBox = uPlayerCharacter:HaveAvailableTombBoxes()
  end
  self.ShortcutMenu_BP.WidgetSwitcher_0:SetWidgetVisibility(ESlateVisibility.Hidden)
  self.CustomizePickUpPanel_BP.ShortcutMenu_BP.WidgetSwitcher_1:SetWidgetVisibility(ESlateVisibility.Hidden)
  local isuav = self:IsOnUAV()
  if not isuav and (bHasGroundItem or bHasTombBox) and not self.bHideForAim then
    if self.UIRoot.CurFrameTombBoxCount <= 0 then
      self.IsFobidExpandDeadBox = false
    end
    if self.UIRoot.CurFrameTombBoxCount == 1 then
      local Box = self.UIRoot.CurFrameFirstTombBox
      if slua.isValid(Box) and Box.bAutoShowItems then
        self.IsAutoExpandBox = true
      else
        self.IsAutoExpandBox = false
      end
    else
      self.IsAutoExpandBox = false
    end
    self.UIRoot:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self:MakeFlagToTabBox()
    local bRefreshChoise = false
    if self.playerChoise == UEnums.EGroudStuffType.UndefineType then
      if bHasGroundItem and not self.bCloseNormal and not self.bCloseNormalAuto then
        self.playerChoise = UEnums.EGroudStuffType.NormalStuff
      end
      bRefreshChoise = true
    elseif self.playerChoise == UEnums.EGroudStuffType.DeadBoxStuff then
      if bHasTombBox then
      elseif bHasGroundItem then
        self.playerChoise = UEnums.EGroudStuffType.NormalStuff
      else
        self.playerChoise = UEnums.EGroudStuffType.UndefineType
      end
      bRefreshChoise = true
    elseif self.playerChoise == UEnums.EGroudStuffType.NormalStuff then
      if not bHasGroundItem then
        self.playerChoise = UEnums.EGroudStuffType.UndefineType
      end
      bRefreshChoise = true
    end
    if bRefreshChoise then
      self:ShowPickMode(self.playerChoise)
      if bHasTombBox then
        self.ShortcutMenu_BP.WidgetSwitcher_1:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.ShortcutMenu_BP:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      else
        self.ShortcutMenu_BP.WidgetSwitcher_1:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
      if not self.IsPickUpListPanelShow then
        self.ShortcutMenu_BP.WidgetSwitcher_1:SetActiveWidgetIndex(0)
        local visible_1 = GlobalBattleUIFunctionLibrary.IsWidgetVisible(self.ShortcutMenu_BP.WidgetSwitcher_1, self.UIRoot)
        if visible_1 then
          local AsSTExtraPlayerController_1 = GameplayData.GetPlayerController()
          if Game:IsValid(AsSTExtraPlayerController_1) then
            AsSTExtraPlayerController_1:OnDeadBoxCollapsed(true)
            self:DeadBoxExistVisibilityControl(true)
            if self.IsAutoExpandBox and not self.IsFobidExpandDeadBox then
              self.ShortcutMenu_BP.PickUpBtnItem_BP:OnShowItems()
              self.IsFobidExpandDeadBox = true
            end
          end
        else
          self:DeadBoxExistVisibilityControl(false)
        end
      else
        self.ShortcutMenu_BP.WidgetSwitcher_1:SetActiveWidgetIndex(1)
      end
      self:MakePickupGuide(bHasTombBox, self.IsPickUpListPanelShow)
      if bHasGroundItem then
        self.CustomizePickUpPanel_BP.ShortcutMenu_BP.WidgetSwitcher_0:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      else
        self.CustomizePickUpPanel_BP.ShortcutMenu_BP.WidgetSwitcher_0:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
      if self.CustomizePickUpPanel_BP.GridPanel_PickUpList:GetVisibility() == ESlateVisibility.Hidden then
        self.CustomizePickUpPanel_BP.ShortcutMenu_BP.WidgetSwitcher_0:SetActiveWidgetIndex(0)
        local visible = GlobalBattleUIFunctionLibrary.IsWidgetVisible(self.CustomizePickUpPanel_BP.ShortcutMenu_BP.WidgetSwitcher_0, self.UIRoot)
        if visible then
          local AsSTExtraPlayerController = GameplayData.GetPlayerController()
          if Game:IsValid(AsSTExtraPlayerController) then
            AsSTExtraPlayerController:OnPickUpCollapsed(true)
            self.CustomizePickUpPanel_BP:PickUpListTipsExistVisibilistyControl(true)
            self.CustomizePickUpPanel_BP.ShortcutMenu_BP:SetNormalStuffIcon(self.IsGroundContainsUseful)
          end
        else
          self.CustomizePickUpPanel_BP:PickUpListTipsExistVisibilistyControl(false)
        end
      else
        self.CustomizePickUpPanel_BP.ShortcutMenu_BP.WidgetSwitcher_0:SetActiveWidgetIndex(1)
      end
    end
  else
    self.IsFobidExpandDeadBox = false
    self.UIRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self:ShowPickupWeaponInfo(false)
  end
end
function PickUpListPanel_BP:MakePickupGuide(bHasTombBox, bIsPickUpListPanelShow)
  if bHasTombBox and not bIsPickUpListPanelShow then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_PICKUPGUIDE_FOR_TOMBBOX, true)
  else
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_PICKUPGUIDE_FOR_TOMBBOX, false)
  end
end
function PickUpListPanel_BP:MakeFlagToTabBox()
  self.ShortcutMenu_BP.PickUpBtnItem_BP.TextBlock_ItemNum:SetText(KismetTextLibrary.Conv_IntToText(self.UIRoot.CurFrameTombBoxCount, true, 1, 324))
  self.CustomizePickUpPanel_BP.ShortcutMenu_BP.PickUpBtnItem_BP.TextBlock_ItemNum:SetText(KismetTextLibrary.Conv_IntToText(self.UIRoot.CurFrameTombBoxCount, true, 1, 324))
end
function PickUpListPanel_BP:OnClickBoxTab(index)
  self.boxChoise = index
  self:ShowOrHidePickUpListPanel(true)
  self.playerChoise = UEnums.EGroudStuffType.DeadBoxStuff
  self:UpdateListData()
  local col = self:GetPickUpColByCurrentMode()
  self:PlayerSetBoxCol(col)
  self:ShowPickMode(UEnums.EGroudStuffType.DeadBoxStuff)
  local AsSTExtraBaseCharacter = GameplayData.GetPlayerCharacter()
  if Game:IsValid(AsSTExtraBaseCharacter) then
    AsSTExtraBaseCharacter:HandleOpenPickUpBoxAction()
  end
end
function PickUpListPanel_BP:FillTombBoxList(uPlayerCharacter, uBackPackComponent)
  local CurTombRowUI
  if self.IsPickUpListPanelShow then
    for Index, SearchedTombBoxesInfo in self.AllSearchedTombBoxesInfo.AllBoxes:PairsLessGC() do
      local ChildItem = self:_TryGetOneItem(SearchedTombBoxesInfo.Box, Index)
      if slua.isValid(ChildItem) then
        if slua.isValid(SearchedTombBoxesInfo.Box) then
          if self.bPlayerShouldAutoPick then
            self:AutoPickTobmBoxItem(uPlayerCharacter, SearchedTombBoxesInfo.SortedItemsArray, SearchedTombBoxesInfo.Box)
          end
          if self:NeedUpdateTombBoxData(ChildItem, SearchedTombBoxesInfo) then
            ChildItem.ParentUserWidget = self.UIRoot
            ChildItem.TombBox = SearchedTombBoxesInfo.Box
            ChildItem.NeedUpdateUICount = SearchedTombBoxesInfo.NeedUpdateUICount
            ChildItem:UpdateTombBoxData(SearchedTombBoxesInfo.Box, SearchedTombBoxesInfo.SortedItemsArray)
            ChildItem.SizeBox_ItemList:SetWidthOverride(self.boxColumn * self:GetItemWidth())
            self:ShowNineOrSixCol(ChildItem, true)
            self:PostUpdateTombBoxData(ChildItem)
          end
          ChildItem:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        else
          ChildItem:SetWidgetVisibility(ESlateVisibility.Collapsed)
        end
      end
    end
    local ChildItem = self:_TryGetPickupItem(self.AllSearchedTombBoxesInfo.AllBoxes:Num())
    if slua.isValid(ChildItem) then
      if self.SearchedPickupItemInfo.SortedItemsArray:Num() > 0 then
        if self.bPlayerShouldAutoPick and uPlayerCharacter:HaveAvailablePickupProps() then
          self:AutoPickGroundItem(uPlayerCharacter, self.SearchedPickupItemInfo.SortedItemsArray)
        end
        ChildItem.ParentUserWidget = self.UIRoot
        ChildItem:UpdateGroundItemData(self.SearchedPickupItemInfo.SortedItemsArray)
        ChildItem.SizeBox_ItemList:SetWidthOverride(self.boxColumn * self:GetItemWidth())
        self:ShowNineOrSixCol(ChildItem, true)
        ChildItem:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      else
        ChildItem:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
    end
    self.ForceUpdateBox = false
  end
end
function PickUpListPanel_BP:ClickCloseCustomPanel()
  self.bNeedFillBtn = true
  self.CustomizePickUpPanel_BP.GridPanel_PickUpList:SetWidgetVisibility(ESlateVisibility.Hidden)
  self.playerChoise = UEnums.EGroudStuffType.UndefineType
  self.boxChoise = 0
  self.bCloseNormal = true
  self:UpdateListData()
  self:ShowPickupWeaponInfo(false)
end
function PickUpListPanel_BP:SetBoxColumn(column)
  if self.boxColumn == column then
    return
  end
  self.boxColumn = column
  self.SizeBox_PanelList:SetWidthOverride(self.boxColumn * self:GetItemWidth())
end
function PickUpListPanel_BP:ClickCloseBoxPanel()
  self:ShowOrHidePickUpListPanel(false)
  self.playerChoise = UEnums.EGroudStuffType.UndefineType
  self.boxChoise = 0
  self:UpdateListData()
end
function PickUpListPanel_BP:AutoPickOneItem(SearchItemResult, uBackPackComponent, uWeaponManagerComponent)
  print(bWriteLog and string.format("[AutoPick]PickUpListPanel_BP:AutoPickOneItem [Type=%d,Id=%d,Count=%d]", SearchItemResult.MainItemData.ID.Type, SearchItemResult.MainItemData.ID.TypeSpecificID, SearchItemResult.MainItemData.Count))
  local ForbitPick = false
  local Wrapper = SearchItemResult.Wrapper
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if Game:IsValid(uPlayerCharacter) and slua.isValid(Wrapper) then
    local uPlayerState = uPlayerCharacter:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      ForbitPick = uPlayerState:IsForbidPickWrapperActor(Wrapper)
    end
  end
  if not ForbitPick and self:CheckCanAutoPick(SearchItemResult, uBackPackComponent, uWeaponManagerComponent) then
    local ItemID = slua.IndexReference(SearchItemResult, "MainItemData", "ID").TypeSpecificID
    if self:CheckPauseAutoPick(ItemID) then
      self:AutoPickOne(SearchItemResult)
      return true
    end
  end
  return false
end
function PickUpListPanel_BP:InitRegistSettingInt(PropertyName, Delegate)
  SubsystemBlueprintLibrary.GetGameInstanceSubsystem(self.UIRoot, SettingSubsystem):RegisterUserSettingsDelegate_Int(PropertyName, Delegate)
  local UserSettings = GameBackendHUD.GetInstance():GetFirstGameFrontendHUD(self.UIRoot):GetUserSettings()
  local AsSettingConfig = UserSettings
  if Game:IsValid(AsSettingConfig) then
    return AsSettingConfig
  end
end
function PickUpListPanel_BP:InitRegistSettingBool(PropertyName, Delegate)
  SubsystemBlueprintLibrary.GetGameInstanceSubsystem(self.UIRoot, SettingSubsystem):RegisterUserSettingsDelegate_Bool(PropertyName, Delegate)
  local UserSettings = GameBackendHUD.GetInstance():GetFirstGameFrontendHUD(self.UIRoot):GetUserSettings()
  local AsSettingConfig = UserSettings
  if Game:IsValid(AsSettingConfig) then
    return AsSettingConfig
  end
end
function PickUpListPanel_BP:PauseAutoPick(nItemID, bShowTip)
  print(bWriteLog and "PickUpListPanel_BP:PauseAutoPick nItemID:" .. tostring(nItemID) .. " bShowTip:" .. tostring(bShowTip))
  local isTrainingMode = false
  local RealTimeSeconds = GameplayStatics.GetRealTimeSeconds(self.UIRoot)
  self.PauseAutoPickItem[nItemID] = RealTimeSeconds
  if bShowTip and RealTimeSeconds - self.lastAutoPickTime > 30.0 and self.AutoPickupSwitcher and not self.ForbitAutoPickByMode and not self.isTrainingMode then
    local AsSTExtraPlayerController = self:GetPlayerController()
    if Game:IsValid(AsSTExtraPlayerController) then
      AsSTExtraPlayerController:DisplayGameTipWithMsgID(30059)
      self.lastAutoPickTime = RealTimeSeconds
    end
  else
    self.lastAutoPickTime = RealTimeSeconds
  end
end
function PickUpListPanel_BP:AutoPickTobmBoxItem(uPlayerCharacter, TombBoxArray, TombBox)
  if self.bSuccessAutoPickOne then
    return
  end
  local uBackPackComponent = self:GetBackpackComponent()
  local uWeaponManagerComponent = self:GetWeaponManager()
  local uPlayerController = self:GetPlayerController()
  if not (slua.isValid(uBackPackComponent) and slua.isValid(uWeaponManagerComponent)) or not slua.isValid(uPlayerController) then
    return
  end
  local TeammatePlayerState = uPlayerController:GetTeammatePlayerStateFromPlayerTombBox(TombBox)
  print(bWriteLog and self.bWriteAutoPickLog and "[AutoPick]PickUpListPanel_BP:AutoPickTobmBoxItem", TombBoxArray, TombBoxArray:Num())
  for _, BattleSearchItemSortingInfo in TombBoxArray:PairsLessGC() do
    local Result = self:CheckIsRevivalCardCanPick(false, TeammatePlayerState, BattleSearchItemSortingInfo)
    if Result then
      self.bSuccessAutoPickOne = self:AutoPickOneItem(BattleSearchItemSortingInfo.SearchItemResult, uBackPackComponent, uWeaponManagerComponent)
      if self.bSuccessAutoPickOne then
        break
      end
    end
  end
end
function PickUpListPanel_BP:AutoPickGroundItem(uPlayerCharacter, PickupArray)
  if self.bSuccessAutoPickOne then
    return
  end
  local uBackPackComponent = self:GetBackpackComponent()
  local uWeaponManagerComponent = self:GetWeaponManager()
  if not slua.isValid(uBackPackComponent) or not slua.isValid(uWeaponManagerComponent) then
    return
  end
  print(bWriteLog and self.bWriteAutoPickLog and "[AutoPick]PickUpListPanel_BP:AutoPickGroundItem", PickupArray, PickupArray:Num())
  for _, ArrayElement in pairs(PickupArray) do
    if ArrayElement.bHighPriority then
      self.bSuccessAutoPickOne = self:AutoPickOneItem(slua.IndexReference(ArrayElement, "SearchItemResult"), uBackPackComponent, uWeaponManagerComponent)
      if self.bSuccessAutoPickOne then
        break
      end
    end
  end
end
function PickUpListPanel_BP:NotifyPickup(show)
  print(bWriteLog and "PickUpListPanel_BP:NotifyPickup", show)
  if show then
    self.CustomizePickUpPanel_BP.ScrollPickUpList:ScrollToStart()
    self.AutoPickDelay = 0.3
  else
    self.bCloseNormalAuto = false
  end
end
function PickUpListPanel_BP:NotifyBox(show)
  print(bWriteLog and "PickUpListPanel_BP:NotifyBox", show)
  if show then
    self.ScrollBox_PickUpListMode1:ScrollToStart()
    self.AutoPickDelay = 0.3
  else
    self.bCloseNormalAuto = false
    self:ClickCloseBoxPanel()
  end
end
function PickUpListPanel_BP:GetUseful2(defineID, PickUpItemResult)
  local uBackPackComponent = self:GetBackpackComponent()
  local uWeaponManagerComponent = self:GetWeaponManager()
  local uPlayerController = self:GetPlayerController()
  if not slua.isValid(uBackPackComponent) or not slua.isValid(uWeaponManagerComponent) then
    return
  end
  return self.UIRoot:GetItemUseful(uBackPackComponent, uWeaponManagerComponent, defineID, PickUpItemResult)
end
function PickUpListPanel_BP:ShowNineOrSixCol(itemRow, bShow)
  local BackPackPanel = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
  if BackPackPanel and BackPackPanel.UIRoot then
    local Visibility = BackPackPanel:GetVisibility()
    self:ShowNineOrSix(bShow, self.boxColumn ~= 3, Visibility ~= ESlateVisibility.SelfHitTestInvisible and Visibility ~= ESlateVisibility.Visible and Visibility ~= ESlateVisibility.HitTestInvisible)
  end
end
function PickUpListPanel_BP:PlayerSetBoxCol(col)
  local BackPackPanel = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
  if BackPackPanel and BackPackPanel.UIRoot and BackPackPanel:GetVisibility() ~= ESlateVisibility.SelfHitTestInvisible then
    self.PlayerBoxColumn = col
    for Index = 0, self.ScrollBox_PickUpListMode1:GetChildrenCount() - 1 do
      local AsPickUpListItemRowBP = self.ScrollBox_PickUpListMode1:GetChildAt(Index)
      if Game:IsValid(AsPickUpListItemRowBP) and AsPickUpListItemRowBP:IsVisible() then
        AsPickUpListItemRowBP.SizeBox_ItemList:SetWidthOverride(self.PlayerBoxColumn * self:GetItemWidth())
        self:ShowNineOrSix(true, self.PlayerBoxColumn ~= 3, true)
      end
    end
  end
end
function PickUpListPanel_BP:ShowNineOrSix(bShow, Nine, Enable)
  if bShow then
    self.WidgetSwitcherCol:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    if Nine then
      self.WidgetSwitcherCol:SetActiveWidgetIndex(1)
      if Enable then
        self.TextBlockNine:SetColorAndOpacity(self._WhiteSlateColor)
        self.ImageNine:SetColorAndOpacity(self._WhiteLinearColor)
      else
        self.TextBlockNine:SetColorAndOpacity(self._TranslucentSlateColor)
        self.ImageNine:SetColorAndOpacity(self._TranslucentLinearColor)
      end
    else
      self.WidgetSwitcherCol:SetActiveWidgetIndex(0)
    end
  else
    self.WidgetSwitcherCol:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function PickUpListPanel_BP:Show_HideExpandPickUpTips(isShow, NewParam)
end
function PickUpListPanel_BP:Show_HideExpandDeadBoxTips(isShow, NewParam)
  if isShow then
    self.Tips14:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    self.UTRichTextBlock_Tips14:SetText(KismetTextLibrary.Conv_StringToText(NewParam.text1))
  else
    self.Tips14:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function PickUpListPanel_BP:IsPlayerCanSeeWidget(NewParam)
  if NewParam:GetVisibility() == ESlateVisibility.Visible then
    return true
  elseif NewParam:GetVisibility() == ESlateVisibility.Collapsed then
    return false
  elseif NewParam:GetVisibility() == ESlateVisibility.Hidden then
    return false
  elseif NewParam:GetVisibility() == ESlateVisibility.HitTestInvisible then
    return true
  elseif NewParam:GetVisibility() == ESlateVisibility.SelfHitTestInvisible then
    return true
  end
end
function PickUpListPanel_BP:PickUpExistVisibilityControl(BtnExist)
  if BtnExist then
    self.CustomizePickUpPanel_BP.PickupBtnExistControl:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.PickUpBtnExistControl:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.PickUpBtnExistControl:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.CustomizePickUpPanel_BP.PickupBtnExistControl:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function PickUpListPanel_BP:DeadBoxExistVisibilityControl(IsExist)
  if IsExist then
    self.DeadBoxBtnExistControl:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.CustomizePickUpPanel_BP.DeadBoxBtnExistControl:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.CustomizePickUpPanel_BP.DeadBoxBtnExistControl:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.DeadBoxBtnExistControl:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function PickUpListPanel_BP:UIMsg_HideOBAirDropBox()
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.bIsShowingOBAirDrop = false
end
function PickUpListPanel_BP:UIMsg_ShowOBAirDropBox()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if PlayerController.CurrOBAirDropID >= 0 then
    local AirDropData = PlayerController:GenerateAirDropData(PlayerController.CurrOBAirDropID)
    self:DirectShowBox(AirDropData)
  end
end
function PickUpListPanel_BP:DirectShowBox(boxArray)
  local BoxSortList = {}
  local currBox
  if boxArray:Num() <= 0 then
    self.bIsShowingOBAirDrop = false
    self.UIRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
  else
    self.bIsShowingOBAirDrop = true
    self.UIRoot:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self:ShowOrHidePickUpListPanel(true)
    self.CustomizePickUpPanel_BP:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.GridPanel_Mode:SetWidgetVisibility(ESlateVisibility.Hidden)
    self.WidgetSwitcher_0:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.ShortcutMenu_BP:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.Button_OBmode_HideList:SetWidgetVisibility(ESlateVisibility.Visible)
    self:PlayerSetBoxCol(2)
    self:ShowNineOrSix(true, true, true)
    self:ShowPickMode(UEnums.EGroudStuffType.DeadBoxStuff)
    for Index = 0, self.ScrollBox_PickUpListMode1:GetChildrenCount() - 1 do
      local ChildItem = self.ScrollBox_PickUpListMode1:GetChildAt(Index)
      if Game:IsValid(ChildItem) then
        ChildItem:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
    end
    for ArrayIndex, ArrayElement in pairs(boxArray) do
      local ChildItem = self:_TryGetOneItem(ArrayElement.Box, ArrayIndex)
      if slua.isValid(ChildItem) then
        ChildItem.CanvasPanel_0:SetWidgetVisibility(ESlateVisibility.Collapsed)
        if slua.isValid(ArrayElement.Box) then
          print(bWriteLog and "PickUpListPanel_BP:DirectShowBox", ArrayElement.Box, ArrayElement.SearchedPickUpItemResultList:Num())
          for ArrayIndex_1, ArrayElement_1 in pairs(ArrayElement.SearchedPickUpItemResultList) do
            local BattleSearchBoxSortingInfo = FBattleSearchBoxSortingInfo()
            BattleSearchBoxSortingInfo.pickUpItemResult = ArrayElement_1
            BattleSearchBoxSortingInfo.bHighPriority = false
            BattleSearchBoxSortingInfo.pickCount = 0
            table.insert(BoxSortList, BattleSearchBoxSortingInfo)
          end
          ChildItem.TombBox = ArrayElement.Box
          ChildItem:UpdateTombBoxData(ArrayElement.Box, BoxSortList)
          self:SetOBAirBoxName(ChildItem, ArrayElement.Box.TombName)
          ChildItem:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        else
          ChildItem:SetWidgetVisibility(ESlateVisibility.Collapsed)
        end
      end
    end
    local Pos = self._TempPos2D
    Pos.X = 250
    Pos.Y = 0
    self.UIRoot:SetRenderTranslation(Pos)
  end
end
function PickUpListPanel_BP:SetOBAirBoxName(item, name)
  local GlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
  item.TextBox:SetWidgetVisibility(ESlateVisibility.Collapsed)
  local AsBPSTExtraPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(AsBPSTExtraPlayerController) then
    if AsBPSTExtraPlayerController.CurrOBAirDropID >= 0 then
      item.playerName:SetText(KismetTextLibrary.Conv_StringToText(GlobalBattleUIFunctionLibrary.GetLocalizeText("4012", self.UIRoot)))
    else
      item.playerName:SetText(KismetTextLibrary.Conv_StringToText(name))
    end
  end
end
function PickUpListPanel_BP:IsCurrWeaponReloading()
  local OwningPlayerPawnOrVehicleDriver = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  local WeaponManager = OwningPlayerPawnOrVehicleDriver:GetWeaponManager()
  local CurrentUsingWeapon = WeaponManager:GetCurrentUsingWeapon()
  if slua.isValid(CurrentUsingWeapon) then
    return CurrentUsingWeapon.CurFreshWeaponState == EFreshWeaponStateType.FreshWeaponStateType_Reload or OwningPlayerPawnOrVehicleDriver:HasState(EPawnState.UseConsumables)
  else
    return false
  end
end
function PickUpListPanel_BP:CheckPauseAutoPick(resID)
  local ProposeData = BackpackUtils.GetProposeData()
  if self.PauseAutoPickItem[resID] ~= nil then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    if Game:IsValid(SettingConfig) then
      if (TableUtil.Find(ProposeData.SideMirrorList, resID) ~= -1 or TableUtil.Find(ProposeData.MirrorList, resID) ~= -1) and SettingConfig.DisableAutoPickDropMirror then
        return false
      elseif GameplayStatics.GetRealTimeSeconds(self.UIRoot) >= self.PauseAutoPickItem[resID] + 30.0 then
        self.PauseAutoPickItem[resID] = nil
        return true
      else
        return false
      end
    end
  else
    return true
  end
end
function PickUpListPanel_BP:ClickCloseBoxByHand()
  self.bCloseNormalAuto = true
  self:ClickCloseBoxPanel()
end
function PickUpListPanel_BP:ModifySetting()
  self:ClearAllCheckSum()
end
function PickUpListPanel_BP:ClearCheckSumByDefineID(ItemList)
  self.UIRoot:ClearCheckSum(true, true)
  for _, DefineID in pairs(ItemList) do
    self.UIRoot:ClearItemUsefulCache(DefineID)
  end
end
function PickUpListPanel_BP:ClearAllCheckSum()
  if not self.UIRoot then
    return
  end
  self.UIRoot:ClearCheckSum(true, true)
  self.UIRoot:ClearAllItemUsefulCache()
end
function PickUpListPanel_BP:ResetChecksum()
  self.UIRoot:ClearCheckSum(true, false)
  self:UpdateListData()
end
function PickUpListPanel_BP:UpdateGroundList(item, index)
  local UIItem = self.AllGroundItemBase[item]
  if UIItem and index < self.GroundItemList:Num() and 0 <= index then
    local ItemData = self.GroundItemList:Get(index)
    UIItem:UpdateItemDataNew(ItemData, self.UIRoot)
  end
end
function PickUpListPanel_BP:CheckIsRevivalCardCanPick(IsTeamTombBox, DroperPlayerState, Info)
  if Info.bHighPriority then
    local RevivalCardID = BackpackUtils.GetRevivalCardID()
    if RevivalCardID == Info.SearchItemResult.MainItemData.ID.TypeSpecificID then
      local IsValidRevivalCard = BackpackUtils.IsValidRevivalCard(DroperPlayerState)
      return IsValidRevivalCard
    else
      return true
    end
  else
    return false
  end
end
function PickUpListPanel_BP:UIMsg_RefreshPlayerTombBoxCheckSum(TombName)
  self:UpdateListData()
  print(bWriteLog and "UIMsg_RefreshPlayerTombBoxCheckSum  player: " .. TombName)
end
function PickUpListPanel_BP:IsOnUAV()
  local AsSTExtraPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(AsSTExtraPlayerController) then
    local VehicleUserComp = AsSTExtraPlayerController:GetVehicleUserComp()
    if slua.isValid(VehicleUserComp) and slua.isValid(VehicleUserComp.Vehicle) then
      return VehicleUserComp.Vehicle:IsUAV()
    end
  end
  return false
end
function PickUpListPanel_BP:CheckCapacityEnough(SearchItemResult, uBackPackComponent)
  local TypeSpecificID = slua.IndexReference(SearchItemResult, "MainItemData", "ID").TypeSpecificID
  local ItemTableData = CDataTable.GetTableData("Item", TypeSpecificID)
  if ItemTableData then
    if ItemTableData.UnitWeight_f < 1.0E-7 then
      return true
    end
    local ReturnValue_2 = KismetMathLibrary.Round(uBackPackComponent.Capacity)
    local ReturnValue_3 = KismetMathLibrary.FCeil(uBackPackComponent.OccupiedCapacity)
    return ReturnValue_2 >= ReturnValue_3 and uBackPackComponent.Capacity >= uBackPackComponent.OccupiedCapacity + ItemTableData.UnitWeight_f
  else
    return false
  end
end
function PickUpListPanel_BP:CheckCanAutoPick(SearchItemResult, uBackPackComponent, uWeaponManagerComponent)
  local bCapacityEnough = self:CheckCapacityEnough(SearchItemResult, uBackPackComponent)
  if bCapacityEnough then
    return true
  else
    local DefineID = slua.IndexReference(SearchItemResult, "MainItemData", "ID")
    local ItemType = DefineID.Type
    local ItemID = DefineID.TypeSpecificID
    if ItemType == 2 then
      local AssociationsUseful = BackpackUtils.GetAssociationsUseful(uBackPackComponent, uWeaponManagerComponent, DefineID)
      if 0 < AssociationsUseful then
        local UserSettings = GameBackendHUD.GetInstance():GetFirstGameFrontendHUD(self.UIRoot):GetUserSettings()
        local AsSettingConfig = UserSettings
        if not Game:IsValid(AsSettingConfig) or AsSettingConfig.AutoEquipAim then
          return true
        else
          local ProposeData = BackpackUtils.GetProposeData()
          if TableUtil.Find(ProposeData.MirrorList, ItemID) ~= -1 then
            return false
          else
            return true
          end
        end
      end
    elseif ItemType == 5 then
      local useful_2 = self:GetUseful2(DefineID, SearchItemResult)
      return 0 < useful_2
    elseif ItemType == 1 then
      local ItemTableData = CDataTable.GetTableData("Item", ItemID)
      if ItemTableData and ItemTableData.ItemSubType == 108 then
        local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
        if SettingSubsystem and SettingSubsystem:GetUserSettings_Bool("bDropUnusefulMelee") then
          local useful = self:GetUseful2(DefineID, SearchItemResult)
          return 0 < useful
        end
        if slua.isValid(uWeaponManagerComponent:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MeleeWeapon)) then
          return false
        end
      end
      local useful = self:GetUseful2(DefineID, SearchItemResult)
      return 0 < useful
    end
    return false
  end
end
function PickUpListPanel_BP:ShowPickupWeaponInfo(Show)
  local IsActivePickupEquipIntoPack = STExtraModLogicSwitchLibrary.IsActivePickupEquipIntoPack()
  if IsActivePickupEquipIntoPack then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_WEAPONDETIAL_SHOW_PICKUP_WEAPON_DETAIL, Show)
  end
  local BTReuseList = self.UIRoot.CustomizePickUpPanel_BP.BTReuseList
  BTReuseList.List:ScrollWidgetIntoView(BTReuseList.FBox:GetChildAt(0), false, UEnums.EDescendantScrollDestination.TopOrLeft)
  BTReuseList.List:ScrollToStart()
end
function PickUpListPanel_BP:GetPickUpColByCurrentMode()
  if self.PickUpListMode == 0 then
    return 3
  elseif self.PickUpListMode == 1 then
    return 2
  end
end
function PickUpListPanel_BP:MarkRecentAutoPickUp(PickUpResult)
  print(bWriteLog and "PickUpPanel_BP:MarkRecentAutoPickUp")
  local uPlayerCharacter = self:GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "PickUpPanel_BP:MarkRecentAutoPickUp error uPlayerCharacter invalid")
    return
  end
  local uPickupManager = uPlayerCharacter:GetPickupManager()
  if not slua.isValid(uPickupManager) then
    print(bWriteLog and "PickUpPanel_BP:MarkRecentAutoPickUp error uPickupManager invalid")
    return
  end
  uPickupManager:MarkRecentAutoPickUp(PickUpResult)
end
function PickUpListPanel_BP:CheckRecentAutoPickUp(PickUpResult)
  print(bWriteLog and "PickUpPanel_BP:CheckRecentAutoPickUp")
  local uPlayerCharacter = self:GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "PickUpPanel_BP:MarkRecentAutoPickUp error uPlayerCharacter invalid")
    return true
  end
  local uPickupManager = uPlayerCharacter:GetPickupManager()
  if not slua.isValid(uPickupManager) then
    print(bWriteLog and "PickUpPanel_BP:MarkRecentAutoPickUp error uPickupManager invalid")
    return true
  end
  return uPickupManager:CheckRecentAutoPickUp(PickUpResult, 3.0)
end
function PickUpListPanel_BP:PickUpWrapperActorWithAnim(uPlayerCharacter, PickupItem, PickCount)
  print(bWriteLog and "[AutoPick]PickUpListPanel_BP PickUpWrapperActorWithAnim")
  if not slua.isValid(PickupItem.Wrapper) then
    print(bWriteLog and "PickUpListPanel_BP PickUpWrapperActorWithAnim Failed not PickupItem")
    return
  end
  uPlayerCharacter:PickUpWrapperActor(PickupItem.Wrapper, PickupItem.MainItemData, PickCount, 0)
end
function PickUpListPanel_BP:PickUpWrapperActorWithoutAnim(uPlayerCharacter, PickupItem, PickCount)
  print(bWriteLog and "[AutoPick]PickUpListPanel_BP PickUpWrapperActorWithoutAnim")
  local uPickupManager = uPlayerCharacter:GetPickupManager()
  if not slua.isValid(uPickupManager) then
    print(bWriteLog and "PickUpPanel_BP:PickUpWrapperActorWithoutAnim error uPickupManager invalid")
    return true
  end
  if not slua.isValid(PickupItem.Wrapper) then
    print(bWriteLog and "PickUpPanel_BP:PickUpWrapperActorWithoutAnim error PickupItem.Wrapper invalid")
    return true
  end
  local InstanceID = PickupItem.MainItemData.InstanceID
  uPickupManager:PickUpTarget(PickupItem.Wrapper, InstanceID, PickCount, 0)
end
function PickUpListPanel_BP:PickUpWrapperActor(uPlayerCharacter, PickupItem, PickCount)
  print(bWriteLog and string.format("[AutoPick]PickUpListPanel_BP PickUpWrapperActor [Type=%d,Id=%d,Count=%d] ---------------------------------", PickupItem.MainItemData.ID.Type, PickupItem.MainItemData.ID.TypeSpecificID, PickCount))
  if not uPlayerCharacter:AllowState(EPawnState.Pick, true) then
    print(bWriteLog and "PickUpListPanel_BP PickUpWrapperActor Failed not uPlayerCharacter:AllowState Pick")
    return
  end
  if self:CheckRecentAutoPickUp(PickupItem) then
    self:PickUpWrapperActorWithAnim(uPlayerCharacter, PickupItem, PickCount)
  else
    self:PickUpWrapperActorWithoutAnim(uPlayerCharacter, PickupItem, PickCount)
  end
  self:MarkRecentAutoPickUp(PickupItem)
end
function PickUpListPanel_BP:OnInitReplayUI()
  self.UIRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.bIsShowingOBAirDrop = false
end
function PickUpListPanel_BP:GetPlayerController()
  if not slua.isValid(self.uPlayerController) then
    self.uPlayerController = GameplayData.GetPlayerController()
  end
  return self.uPlayerController
end
function PickUpListPanel_BP:GetBackpackComponent()
  if not slua.isValid(self.uBackpackComponent) then
    local uPlayerController = self:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      print(bWriteLog and "PickUpListPanel_BP:GetBackpackComponent Error, uPlayerController is invalid")
      return
    end
    self.uBackpackComponent = uPlayerController:GetBackpackComponent()
  end
  return self.uBackpackComponent
end
function PickUpListPanel_BP:GetPlayerCharacter()
  if not slua.isValid(self.uPlayerCharacter) then
    self.uPlayerCharacter = GameplayData.GetPlayerCharacter()
  end
  return self.uPlayerCharacter
end
function PickUpListPanel_BP:GetWeaponManager()
  if not slua.isValid(self.uWeaponManager) then
    local uPlayerCharacter = self:GetPlayerCharacter()
    if not slua.isValid(uPlayerCharacter) then
      print(bWriteLog and "PickUpListPanel_BP:GetWeaponManager Error, uPlayerCharacter is invalid")
      return
    end
    self.uWeaponManager = uPlayerCharacter:GetWeaponManager()
  end
  return self.uWeaponManager
end
function PickUpListPanel_BP:PickUpGroundItemByIndex(nIndex)
  if self:GetVisibility() == UEnums.GSlateVisibility.Collapsed then
    return
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    print(bWriteLog and "PickUpListPanelUI:PickUpGroundItemByIndex Error, uPlayerCharacter is invalid")
    return
  end
  local BTReuseList = self.CustomizePickUpPanel_BP.BTReuseList
  local fItemSizeY = BTReuseList.itemSizeY
  local fCurrentOffset = BTReuseList.CurrentOffset
  local nHideIndex, fLastMill = math.modf(fCurrentOffset / fItemSizeY)
  if 0.1 < fLastMill then
    nHideIndex = nHideIndex + 1
  end
  local nPickIndex = nHideIndex + nIndex - 1
  if nPickIndex >= self.GroundItemList:Num() then
    return
  end
  local uItemData = self.GroundItemList:Get(nPickIndex)
  uPlayerCharacter:PickUpWrapperActor(uItemData.SearchItemResult.Wrapper, uItemData.SearchItemResult.MainItemData, uItemData.SearchItemResult.MainItemData.Count, 0)
end
function PickUpListPanel_BP:PickUpBoxItemByIndex(nIndex)
  if self:GetVisibility() == UEnums.GSlateVisibility.Collapsed then
    return
  end
  if not self.IsPickUpListPanelShow then
    return
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    print(bWriteLog and "PickUpListPanelUI:PickUpBoxItemByIndex Error, uPlayerCharacter is invalid")
    return
  end
  local WrapBox_List = self.PickUpListItem_Row_BP.WrapBox_List
  local nRow = self.boxColumn
  if nIndex > nRow then
    print(bWriteLog and "PickUpListPanelUI:PickUpBoxItemByIndex nIndex:" .. nIndex .. " >nRow:" .. nRow)
    return
  end
  local ScrollPos = USlateBlueprintLibrary.GetAbsolutePosition(self.ScrollBox_PickUpListMode1:GetCachedGeometry())
  local fScrollPos_Y = ScrollPos.Y
  local nChildNum = WrapBox_List:GetChildrenCount()
  for nWrapBoxItemIndex = 0, nChildNum - 1, nRow do
    local nRealIndex = nWrapBoxItemIndex + nIndex - 1
    local WrapBoxItem = WrapBox_List:GetChildAt(nRealIndex)
    if WrapBoxItem then
      local ItemPos = USlateBlueprintLibrary.GetAbsolutePosition(WrapBoxItem:GetCachedGeometry())
      if fScrollPos_Y < ItemPos.Y and WrapBoxItem:GetVisibility() ~= UEnums.GSlateVisibility.Collapsed then
        local uItemData = WrapBoxItem.sortInfo.pickUpItemResult
        uPlayerCharacter:PickUpWrapperActor(uItemData.Wrapper, uItemData.MainItemData, uItemData.MainItemData.Count, 0)
        return
      end
    end
  end
end
function PickUpListPanel_BP:ClearAutoPickItem()
  print(bWriteLog and "PickUpListPanel_BP:ClearAutoPickItem")
  self.PauseAutoPickItem = {}
end
function PickUpListPanel_BP:SetUseFullLimit(nUseFullLimit)
  print(bWriteLog and "PickUpListPanel_BP:SetUseFullLimit nUseFullLimit:" .. tostring(nUseFullLimit))
  self.UIRoot.CalcUsefulLimit = nUseFullLimit
end
function PickUpListPanel_BP:GetItemWidth()
  return 193
end
function PickUpListPanel_BP:ShowOrHidePickUpListPanel(bIsShow)
  self.bNeedFillBtn = true
  if bIsShow then
    self.GridPanel_PickUpList:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    Client.RequireSlateTickEveryFrame(SlateUI_ID.PICKUP_LIST_PANEL)
  else
    if self.IsPickUpListPanelShow then
      print(bWriteLog and "PickUpListPanel_BP:ShowOrHidePickUpListPanel Hide")
      for Index = 0, self.ScrollBox_PickUpListMode1:GetChildrenCount() - 1 do
        local ChildItem = self.ScrollBox_PickUpListMode1:GetChildAt(Index)
        if slua.isValid(ChildItem) then
          ChildItem.bNeedUpdate = true
          ChildItem.TombBox = nil
          ChildItem.NeedUpdateUICount = 0
        end
      end
    end
    self.GridPanel_PickUpList:SetWidgetVisibility(ESlateVisibility.Collapsed)
    Client.ResetSlateTickEveryFrame(SlateUI_ID.PICKUP_LIST_PANEL)
  end
  self:SetPanelShow(bIsShow)
end
function PickUpListPanel_BP:SetAutoPickMeleeType(AutoPickMeleeType)
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  local AutoPickMeleeType = SettingSubsystem:GetUserSettings_Int("AutoPickMeleeType")
  local MeleeWeaponTable = {
    [1] = 108004,
    [2] = 108005,
    [3] = 108001
  }
  local WeaponSpecialID = MeleeWeaponTable[AutoPickMeleeType] or 0
  for _, SpecialID in pairs(MeleeWeaponTable) do
    self.UIRoot:ClearItemUsefulCacheBySpecialID(1, SpecialID)
  end
  BackpackUtils.SetAutoPickMeleeType(WeaponSpecialID)
  self:ClearAllCheckSum()
end
function PickUpListPanel_BP:OnItemOperation(DefineID, OperationType, Reason)
  if OperationType ~= UEnums.EBattleItemOperationType.Drop then
    return
  end
  local TypeSpecificID = DefineID.TypeSpecificID
  local ItemTableData = CDataTable.GetTableData("Item", TypeSpecificID)
  if ItemTableData and ItemTableData.ItemSubType == 108 and not self.PauseAutoPickItem[TypeSpecificID] then
    self:PauseAutoPick(TypeSpecificID, false)
  end
end
function PickUpListPanel_BP:OnBackPackShowOrHide(_, __, ShowBackpack, bBRTDMStore)
  if ShowBackpack == nil then
    ShowBackpack = false
    local BackPackPanelUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
    ShowBackpack = BackPackPanelUI ~= nil and BackPackPanelUI:IsShow()
  end
  if self.bShowBackpack == ShowBackpack then
    return
  end
  self.b  self:ChangeLayoutOnBackpackShow(ShowBackpack, bBRTDMStore)
  self.ForceUpdateBox = true
  self:UpdateListData()
  audio_util.PlayAudioAsync("/Game/WwiseEvent/UI/Play_UI_BackpackClose.Play_UI_BackpackClose")
end
function PickUpListPanel_BP:NeedUpdateTombBoxData(ChildItem, SearchedTombBoxesInfo)
  return self.ForceUpdateBox or ChildItem.TombBox ~= SearchedTombBoxesInfo.Box or ChildItem.NeedUpdateUICount ~= SearchedTombBoxesInfo.NeedUpdateUICount
end
function PickUpListPanel_BP:PostUpdateTombBoxData(ChildItem)
end
function PickUpListPanel_BP:OnClose()
  print(bWriteLog and "PickUpListPanel_BP:OnClose")
  for Index = 0, self.ScrollBox_PickUpListMode1:GetChildrenCount() - 1 do
    local ChildItem = self.ScrollBox_PickUpListMode1:GetChildAt(Index)
    if slua.isValid(ChildItem) and ChildItem.OnDestroy then
      ChildItem:OnDestroy()
    end
  end
  for _, UIItem in pairs(self.AllGroundItemBase) do
    if UIItem then
      UIItem:CloseSelf()
    end
  end
  for _, Item in pairs(self.CustomizePickUpPanel_BP.BTReuseList.itemList) do
    if slua.isValid(Item) and Item.OnDestroy then
      Item:OnDestroy()
    end
  end
  if slua.isValid(self.PickupToolTips) and self.PickupToolTips.RemoveFromParent then
    self.PickupToolTips:RemoveFromParent()
  end
  self.PickupToolTips = nil
  self.AllGroundItemBase = nil
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, PickUpListPanel_BP)