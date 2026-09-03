local ChangeSightUI = {}
local AvatarUtils = import("AvatarUtils")
local BackpackUtils = import("BackpackUtils")
local GameplayStatics = import("GameplayStatics")
local KismetTextLibrary = import("KismetTextLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local STExtraPlayerState = import("/Script/ShadowTrackerExtra.STExtraPlayerState")
local STExtraUIUtils = import("STExtraUIUtils")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local FBattleItemUseTarget = import("BattleItemUseTarget")
local FItemDefineSortingInfo = import("ItemDefineSortingInfo")
local EBattleItemDisuseReason = import("EBattleItemDisuseReason")
local EBattleItemDropReason = import("EBattleItemDropReason")
local EBattleItemUseReason = import("EBattleItemUseReason")
local ESlateVisibility = import("ESlateVisibility")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TableUtil = require("common.table_util")
function ChangeSightUI:OnInitialize()
  ChangeSightUI.__super.OnInitialize(self)
  self.SightDefineIDNotUsed = {}
  self.SightSettingSwitch = false
  self.sideSightList = {
    [203018] = true
  }
  self.SightCheckhandler = nil
  self.bListShow = false
  self.bRegistItemChangeEvent = false
  self:Collapsed()
end
function ChangeSightUI:RegistEvents()
  ChangeSightUI.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Button_ChangeSight, "OnClicked", self.OnClicked_Button_ChangeSight, self)
  local UIRoot = self.UIRoot
  for Index = 0, UIRoot.WrapBox_List:GetChildrenCount() - 1 do
    local AsChangeSightItem01UIBP = UIRoot.WrapBox_List:GetChildAt(Index)
    self:BindItemEvent(AsChangeSightItem01UIBP)
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  self:AddSettingOptionEvent("QuasiMirrorSwitch", function(bQuasiMirrorSwitch)
    print(bWriteLog and "ChangeSightUI:RegistEvents bQuasiMirrorSwitch:" .. tostring(bQuasiMirrorSwitch))
    self:QuasiMirrorSwitchEvent(bQuasiMirrorSwitch)
  end)
  local bValueFromSubsystem = SettingModule:GetOptionValue("QuasiMirrorSwitch")
  print(bWriteLog and "ChangeSightUI:RegistEvents bValueFromSubsystem:", tostring(bValueFromSubsystem))
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REFRESHUI_AFTERRESPAWN, self.ResetUIStateAfterRespawn, self)
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    self:CheckShouldShow()
  end)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.HandleSpectatorChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
  self:AddUIMessageEvent("UIMsg_SwitchCameraSatrtHandle", self.UIMsg_SwitchCameraSatrtHandle, self)
end
function ChangeSightUI:OnClose()
end
function ChangeSightUI:UIMsg_SwitchCameraSatrtHandle()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not slua.isValid(PlayerController.STExtraBaseCharacter) then
    return
  end
  if PlayerController.STExtraBaseCharacter.bIsGunADS then
    self:HideList()
  end
end
function ChangeSightUI:CheckShouldShow()
  local SightSettingSwitch = self:GetQuasiMirrorSwitch()
  self:SetSelfShow(SightSettingSwitch, true)
  print(bWriteLog and "ChangeSightUI:CheckShouldShow SightSettingSwitch:" .. tostring(self.SightSettingSwitch))
end
function ChangeSightUI:GetQuasiMirrorSwitch()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  self.SightSettingSwitch = SettingConfig.QuasiMirrorSwitch
  return self.SightSettingSwitch
end
function ChangeSightUI:ResetUIStateAfterRespawn()
  local SightSettingSwitch = self:GetQuasiMirrorSwitch()
  self:SetSelfShow(SightSettingSwitch)
  print(bWriteLog and "ChangeSightUI:ResetUIStateAfterRespawn SightSettingSwitch:" .. tostring(self.SightSettingSwitch))
end
function ChangeSightUI:OnReconnect()
  local SightSettingSwitch = self:GetQuasiMirrorSwitch()
  self:SetSelfShow(SightSettingSwitch)
  print(bWriteLog and "ChangeSightUI:OnReconnect SightSettingSwitch:" .. tostring(self.SightSettingSwitch))
end
function ChangeSightUI:RegistItemChangeEvent(bInitialize)
  self:BindWeaponMsg(bInitialize)
  if self.bRegistItemChangeEvent then
    return
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST, function(_, _, uBackpackComponent)
    if slua.isValid(uBackpackComponent) and uBackpackComponent:IsItemListUpdatedHasOneItemType(2) then
      self:UpdateSightItem()
    end
  end)
  self.bRegistItemChangeEvent = true
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameStateChanged, self)
  self:UpdateSightItem()
end
function ChangeSightUI:BindWeaponMsg(bInitialize)
  print(bWriteLog and "ChangeSightUI:BindWeaponMsg bInitialize:" .. tostring(bInitialize))
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if bInitialize or not slua.isValid(uPlayerCharacter) then
    self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  else
    self:OnPlayerCharacterChange(uPlayerCharacter)
  end
end
function ChangeSightUI:OnPlayerCharacterChange(uPlayerCharacter)
  if Game:IsValid(uPlayerCharacter) then
    local WeaponManager = uPlayerCharacter:GetWeaponManager()
    if Game:IsValid(WeaponManager) then
      self.      self:AddControlEventByControl(WeaponManager, "ChangeInventoryDataDelegate", self.UpdateSightItem, self)
      self:AddControlEventByControl(WeaponManager, "ChangeCurrentUsingWeaponDelegate", self.UpdateSightItem, self)
      self:AddControlEventByControl(WeaponManager, "SwapWeaponByPropSlotFinishedDelegate", self.UpdateSightItem, self)
    end
  else
    print(bWriteLog and "ChangeSightUI:BindPlayerWeaponDelegate uPlayerCharacter invalid")
  end
end
function ChangeSightUI:UnRegistItemChangeEvent()
  self.bRegistItemChangeEvent = false
  self:RemoveCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE)
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if Game:IsValid(uPlayerCharacter) then
    local WeaponManager = uPlayerCharacter:GetWeaponManager()
    if Game:IsValid(WeaponManager) then
      self:RemoveControlEventByControl(WeaponManager, "ChangeInventoryDataDelegate")
      self:RemoveControlEventByControl(WeaponManager, "ChangeCurrentUsingWeaponDelegate")
      self:RemoveControlEventByControl(WeaponManager, "SwapWeaponByPropSlotFinishedDelegate")
    end
  end
end
function ChangeSightUI:OnClicked_Button_ChangeSight()
  if self.bListShow then
    self:HideList()
  else
    self:ShowList()
  end
end
function ChangeSightUI:DelayEnableCharacterTouch()
  self:AddTimer(0.05, function()
    local uPlayerController = GameplayData.GetPlayerController()
    if Game:IsValid(uPlayerController) then
      uPlayerController.CharacterTouchMove = true
    end
  end)
end
function ChangeSightUI:QuasiMirrorSwitchEvent(BoolValue)
  if BoolValue == self.SightSettingSwitch then
    return
  end
  self.SightSettingSwitch = BoolValue
  self:SetSelfShow(BoolValue)
end
function ChangeSightUI:SetSelfShow(bShow, bInitialize)
  if bShow then
    self:UpdateSightItem()
    self:SetPlayerUseQuickSight(1)
    self:RegistItemChangeEvent(bInitialize)
  else
    self:Collapsed()
    self:SetPlayerUseQuickSight(0)
    self:UnRegistItemChangeEvent()
  end
end
function ChangeSightUI:Destruct()
  if self.SightCheckhandler then
    self:RemoveGameTimer(self.SightCheckhandler)
    self.SightCheckhandler = nil
  end
end
function ChangeSightUI:UpdateSightItem()
  local CurrentWeaponID = 0
  if self.SightSettingSwitch then
    local UIRoot = self.UIRoot
    UIRoot.TextBlock_SightName:SetText(LocUtil.LocalizeResFormat(34274))
    TableUtil.Clear(self.SightDefineIDNotUsed)
    local uPlayerController = GameplayData.GetPlayerController()
    if not Game:IsValid(uPlayerController) or not Game:IsValid(uPlayerController.BackpackComponent) then
      return
    end
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if not Game:IsValid(uPlayerCharacter) then
      return
    end
    local WeaponManager = uPlayerCharacter:GetWeaponManager()
    if not Game:IsValid(WeaponManager) then
      return
    end
    local CurrentUsingWeapon = WeaponManager:GetCurrentUsingWeapon()
    if slua.isValid(CurrentUsingWeapon) then
      local ItemDefineID = CurrentUsingWeapon:GetItemDefineID()
      CurrentWeaponID = ItemDefineID.TypeSpecificID
    end
    self:AddSightOnEquipped(CurrentUsingWeapon, WeaponManager, UIRoot)
    self:AddSightByBackpack(uPlayerController, CurrentWeaponID)
    self:RefreshSighItem()
  end
end
function ChangeSightUI:AddSightOnEquipped(CurrentUsingWeapon, WeaponManager, UIRoot)
  local ItemDefineID_2 = FItemDefineIDDefault()
  self.MainWeaponUsingSight = ItemDefineID_2
  local CurrUsingSlot = WeaponManager:GetCurrentUsingPropSlot()
  if (CurrUsingSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 or CurrUsingSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 or CurrUsingSlot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon) and slua.isValid(CurrentUsingWeapon) then
    local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
    local socketList = BackPackFunctionLibrary.GetWeaponSupportSocket(CurrentUsingWeapon:GetItemDefineID().TypeSpecificID)
    local MainWeaponSupported = TableUtil.Find(socketList, EWeaponAttachmentSocketType.OpticalSight) ~= -1
    if MainWeaponSupported then
      local sight, find = self:GetSightByWeaponDefineID(CurrentUsingWeapon)
      if find then
        local TypeSpecificID_2 = sight.TypeSpecificID
        self.MainWeaponSightID = TypeSpecificID_2
        self.MainWeaponUsingSight = sight:clone()
        local ItemDefineSortingInfo = FItemDefineSortingInfo()
        ItemDefineSortingInfo.defineID = sight:clone()
        ItemDefineSortingInfo.bUsed = true
        ItemDefineSortingInfo.bMainHand = true
        ItemDefineSortingInfo.Count = 0
        table.insert(self.SightDefineIDNotUsed, ItemDefineSortingInfo)
        local ItemTable = CDataTable.GetTableData("Item", TypeSpecificID_2)
        if ItemTable and ItemTable.BackpackSimple then
          UIRoot.TextBlock_SightName:SetText(KismetTextLibrary.Conv_StringToText(ItemTable.BackpackSimple))
        end
      end
    end
  end
end
function ChangeSightUI:AddSightByBackpack(uPlayerController, CurrentWeaponID)
  local BackItemList = BackpackUtils.GetWeaponAttachmentsInBackpack(uPlayerController.BackpackComponent)
  for ArrayIndex, ArrayElement in pairs(BackItemList) do
    local DefineID = ArrayElement.DefineID
    local IsGunSupportAttachByRes = AvatarUtils.IsGunSupportAttachByRes(DefineID.TypeSpecificID, CurrentWeaponID, true, EWeaponAttachmentSocketType.OpticalSight)
    if IsGunSupportAttachByRes and self:IsGunSupportAttachByRes(DefineID.TypeSpecificID, CurrentWeaponID) then
      self:AddSightByFilter(DefineID, ArrayElement.bEquipping, false)
    end
  end
end
function ChangeSightUI:IsGunSupportAttachByRes(AttachTypeSpecificID, CurrentWeaponID)
  return true
end
function ChangeSightUI:GetSightByWeaponDefineID(WeaponObject)
  local ItemDefineID = FItemDefineIDDefault()
  if not Game:IsValid(WeaponObject) then
    return ItemDefineID, false
  end
  local WeaponsInBackpack = BackpackUtils.GetWeaponsInBackpack(GameplayData.GetPlayerController().BackpackComponent)
  for i, Weapon in pairs(WeaponsInBackpack) do
    if Weapon.DefineID.InstanceID == WeaponObject:GetItemDefineID().InstanceID then
      for _, Association in pairs(Weapon.Associations) do
        local AssociationTargetDefineID = Association.AssociationTargetDefineID
        local TypeSpecificID = AssociationTargetDefineID.TypeSpecificID
        if TypeSpecificID // 1000 == 203 and not self.sideSightList[TypeSpecificID] then
          return AssociationTargetDefineID, true
        end
      end
    end
  end
  return ItemDefineID, false
end
function ChangeSightUI:RefreshSighItem()
  local index = 0
  local UIRoot = self.UIRoot
  local MergeExecutionPath1 = function()
    local ReturnValue_6 = BackpackUtils.SortDefineIDByWeight(self.SightDefineIDNotUsed)
    for _, Value in ipairs(ReturnValue_6) do
      self.SightDefineIDNotUsed[#self.SightDefineIDNotUsed + 1] = Value
    end
    for Index = 0, UIRoot.WrapBox_List:GetChildrenCount() - 1 do
      UIRoot.WrapBox_List:GetChildAt(Index):SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
    for ArrayIndex, ArrayElement in pairs(self.SightDefineIDNotUsed) do
      local defineID = ArrayElement.defineID
      if UIRoot.WrapBox_List:GetChildrenCount() > index then
        local AsChangeSightItem01UIBP = UIRoot.WrapBox_List:GetChildAt(index)
        AsChangeSightItem01UIBP:SetSightItem(ArrayElement.bUsed, ArrayElement.bMainHand, defineID)
        AsChangeSightItem01UIBP:SetWidgetVisibility(ESlateVisibility.Visible)
        index = index + 1
      else
        local ReturnValue_2 = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/IngameUI/TipsItem/ChangeSight_Item01_UIBP.ChangeSight_Item01_UIBP_C", self.UIRoot)
        ReturnValue_2:SetWidgetVisibility(ESlateVisibility.Visible)
        local ReturnValue_3 = UIRoot.WrapBox_List:AddChild(ReturnValue_2)
        ReturnValue_2:SetSightItem(ArrayElement.bUsed, ArrayElement.bMainHand, defineID)
        self:BindItemEvent(ReturnValue_2)
        index = index + 1
      end
    end
  end
  local MergeExecutionPath0 = function()
    local ReturnValue_11 = WidgetLayoutLibrary.SlotAsCanvasSlot(UIRoot.SizeBox_Sight)
    local ReturnValue_9 = WidgetLayoutLibrary.SlotAsCanvasSlot(UIRoot.WrapBox_List)
    if (#self.SightDefineIDNotUsed - 1) // 2 == 0 then
      ReturnValue_11:SetSize(FVector2D(140.0, 68.0))
      ReturnValue_9:SetSize(FVector2D(132.0, 70.0))
      MergeExecutionPath1()
    elseif (#self.SightDefineIDNotUsed - 1) // 2 == 1 then
      ReturnValue_11:SetSize(FVector2D(140.0, 136.0))
      ReturnValue_9:SetSize(FVector2D(132.0, 138.0))
      MergeExecutionPath1()
    elseif (#self.SightDefineIDNotUsed - 1) // 2 == 2 then
      ReturnValue_11:SetSize(FVector2D(140.0, 202.0))
      ReturnValue_9:SetSize(FVector2D(132.0, 204.0))
      MergeExecutionPath1()
    else
      ReturnValue_11:SetSize(FVector2D(140.0, 268.0))
      ReturnValue_9:SetSize(FVector2D(132.0, 270.0))
      MergeExecutionPath1()
    end
  end
  if #self.SightDefineIDNotUsed > 0 then
    if self.SightSettingSwitch then
      UIRoot:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      MergeExecutionPath0()
    else
      self:HideList()
      UIRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
      MergeExecutionPath0()
    end
  else
    self:HideList()
    UIRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
    UIRoot.CanvasPanelList:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function ChangeSightUI:OnItemBeDragBegin(itemDefineID)
  self.DragSightDefineID = itemDefineID
  local uPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(uPlayerController) then
    uPlayerController.CharacterTouchMove = false
  end
end
function ChangeSightUI:OnItemBeDragCancelled()
  local uPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(uPlayerController) then
    uPlayerController:ServerDropItem(self.DragSightDefineID, 1, EBattleItemDropReason.Manually)
    uPlayerController:UserDropItemOperation(self.DragSightDefineID)
    local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
    if PickUpListPanel then
      PickUpListPanel:PauseAutoPick(self.DragSightDefineID.TypeSpecificID, true)
    end
  end
  self:DelayEnableCharacterTouch()
end
function ChangeSightUI:BindItemEvent(item)
  self:AddControlEventByControl(item, "ItemBeDragBegin", self.OnItemBeDragBegin, self)
  self:AddControlEventByControl(item, "ItemBeDrapCancelled", self.OnItemBeDragCancelled, self)
  self:AddControlEventByControl(item, "ChangeSightOK", self.ChangeSigntOK, self)
  self:AddControlEventByControl(item, "DisuseCurringSight", self.DisuseCurrentSight, self)
end
function ChangeSightUI:HideList()
  local UIRoot = self.UIRoot
  UIRoot.CanvasPanelList:SetWidgetVisibility(ESlateVisibility.Collapsed)
  UIRoot.WidgetSwitcher_ChangeSight:SetActiveWidgetIndex(0)
  self.bListShow = false
end
function ChangeSightUI:ShowList()
  local UIRoot = self.UIRoot
  UIRoot.CanvasPanelList:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  UIRoot.WidgetSwitcher_ChangeSight:SetActiveWidgetIndex(1)
  self.bListShow = true
end
function ChangeSightUI:OnDrop(MyGeometry, PointerEvent, Operation)
  self:DelayEnableCharacterTouch()
  return true
end
function ChangeSightUI:AddSightByFilter(defineID, used, mainHand)
  for ArrayIndex, ArrayElement in pairs(self.SightDefineIDNotUsed) do
    local ItemID = ArrayElement.defineID.TypeSpecificID
    if ItemID == defineID.TypeSpecificID then
      if used or ArrayElement.bUsed and ArrayElement.bMainHand then
        return
      else
        table.remove(self.SightDefineIDNotUsed, ArrayIndex)
        break
      end
    end
  end
  local ItemDefineSortingInfo = FItemDefineSortingInfo()
  ItemDefineSortingInfo.  ItemDefineSortingInfo.bUsed = used
  ItemDefineSortingInfo.bMainHand = mainHand
  ItemDefineSortingInfo.Count = 0
  table.insert(self.SightDefineIDNotUsed, ItemDefineSortingInfo)
end
function ChangeSightUI:DisuseCurrentSight()
  local uPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(uPlayerController) then
    uPlayerController:ServerDisuseItem(self.MainWeaponUsingSight, EBattleItemDisuseReason.Manually)
  end
end
function ChangeSightUI:ChangeSigntOK(item)
  print(bWriteLog and "ChangeSightUI:ChangeSigntOK 0")
  local MergeExecutionPath0 = function()
    self.SightCheckhandler = self:AddGameTimer(1, false, function()
      self:CheckSightUpdate()
    end)
  end
  self:HideList()
  local IsSameItem = slua.isValid(self.MainWeaponUsingSight) and BackpackUtils.IsSameItem(item, self.MainWeaponUsingSight)
  print(bWriteLog and "ChangeSightUI:ChangeSigntOK 1", IsSameItem)
  if IsSameItem then
    self:DisuseCurrentSight()
  else
    local OwningPlayerPawnOrVehicleDriver = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
    local WeaponManager = OwningPlayerPawnOrVehicleDriver:GetWeaponManager()
    local CurrentUsingWeapon = WeaponManager:GetCurrentUsingWeapon()
    if slua.isValid(CurrentUsingWeapon) then
      local ItemDefineID = CurrentUsingWeapon:GetItemDefineID()
      local uPlayerController = GameplayData.GetPlayerController()
      if Game:IsValid(uPlayerController) then
        local BattleItemUseTarget = FBattleItemUseTarget()
        local EItemAssociationType = import("EItemAssociationType")
        BattleItemUseTarget.TargetDefineID = ItemDefineID
        BattleItemUseTarget.TargetAssociationType = EItemAssociationType.None
        BattleItemUseTarget.TargetActor = nil
        uPlayerController:ServerUseItem(item, BattleItemUseTarget, EBattleItemUseReason.Manually)
      end
    end
  end
  if self.SightCheckhandler then
    self:RemoveGameTimer(self.SightCheckhandler)
    self.SightCheckhandler = nil
    MergeExecutionPath0()
  else
    MergeExecutionPath0()
  end
end
function ChangeSightUI:SetPlayerUseQuickSight(IsUse)
  local PlayerCharacter = GameplayStatics.GetPlayerCharacter(self.UIRoot, 0)
  if slua.isValid(PlayerCharacter) and slua.isValid(PlayerCharacter.PlayerState) then
    local AsSTExtraPlayerState = PlayerCharacter.PlayerState
    if Game:IsClassOf(AsSTExtraPlayerState, STExtraPlayerState) then
      AsSTExtraPlayerState.PlayerUseQuickSight = IsUse
    end
  end
end
function ChangeSightUI:CheckSightUpdate()
  local OwningPlayerPawnOrVehicleDriver = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(OwningPlayerPawnOrVehicleDriver) then
    local WeaponManager = OwningPlayerPawnOrVehicleDriver:GetWeaponManager()
    if slua.isValid(WeaponManager) then
      local CurrentUsingWeapon = WeaponManager:GetCurrentUsingWeapon()
      if slua.isValid(CurrentUsingWeapon) then
        local ItemDefineID = CurrentUsingWeapon:GetItemDefineID()
        local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
        local socketList = BackPackFunctionLibrary.GetWeaponSupportSocket(ItemDefineID.TypeSpecificID)
        if TableUtil.Find(socketList, EWeaponAttachmentSocketType.OpticalSight) ~= -1 then
          local sight_TypeSpecificID, find = self:GetSightByWeaponDefineID(CurrentUsingWeapon)
          if find then
            local WrapBox_List = self.UIRoot.WrapBox_List
            for Index = 0, WrapBox_List:GetChildrenCount() - 1 do
              local AsChangeSightItem01UIBP = WrapBox_List:GetChildAt(Index)
              if AsChangeSightItem01UIBP.bMainHandUsed then
                print(bWriteLog and tostring(AsChangeSightItem01UIBP.itemDefineID.TypeSpecificID) .. ":: " .. tostring(sight_TypeSpecificID) .. ": ddddylan")
                if AsChangeSightItem01UIBP.itemDefineID.TypeSpecificID ~= sight_TypeSpecificID then
                  self:UpdateSightItem()
                end
              end
            end
          end
        end
      end
    end
  end
end
function ChangeSightUI:OnGameStateChanged(_, __, sGameState)
  print(bWriteLog and "ChangeSightUI:OnGameStateChanged" .. sGameState)
  if sGameState == "FinishedState" then
    self:SetSelfShow(false)
  end
end
function ChangeSightUI:HandleSpectatorChange()
  local uPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(uPlayerController) and (uPlayerController:IsObserver() or uPlayerController:IsSpectator()) then
    self:SetSelfShow(false)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, ChangeSightUI)