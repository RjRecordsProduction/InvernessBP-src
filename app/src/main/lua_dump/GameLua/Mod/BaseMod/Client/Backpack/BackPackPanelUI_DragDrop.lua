local BackPackPanelUI = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Define")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EBackPackDragOrigin = UEnums.EBackPackDragOrigin
local EBattleItemUseReason = import("EBattleItemUseReason")
local EItemStoreArea = import("EItemStoreArea")
local EBattleItemDisuseReason = import("EBattleItemDisuseReason")
local FBattleItemUseTarget = import("BattleItemUseTarget")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UIUtil = require("client.common.ui_util")
function BackPackPanelUI:OnItemDragBegin(ItemBeDragged, DragOrigin)
  self.  self.DragItemOrigin = DragOrigin
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_ITEM_DRAG_BEGIN)
  local PlayerController = self.UIRoot:GetOwningPlayer()
  if slua.isValid(PlayerController) then
    PlayerController.CharacterTouchMove = false
  end
  if DragOrigin == EBackPackDragOrigin.FromList then
    self:HightLightArmorAttachSlots(self.ItemBeDragged)
    self:HighLightUpgradeWeapon(self.ItemBeDragged)
    self:EnterDrag(true)
  elseif DragOrigin == EBackPackDragOrigin.FromWeapon1 then
    self.WeaponInfoItem_Weapon1:HighLightBG(true)
  elseif DragOrigin == EBackPackDragOrigin.FromWeapon2 then
    self.WeaponInfoItem_Weapon2:HighLightBG(true)
  elseif DragOrigin == EBackPackDragOrigin.FromPistol then
    self.PistolInfoItem_BP:HighLightBG(true)
  elseif DragOrigin == EBackPackDragOrigin.FromOccupation and slua.isValid(self.DragDropWidgetWeaponDetail) then
    self.DragDropWidgetWeaponDetail:HighLightBG(false)
  end
  self:HightLightAttachSlots(self.ItemBeDragged)
  if self.Image_Drop then
    self.Image_Drop:SetBrushfromPathAsync("/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_icon_tuodongdiuqi_1_png.ZD_icon_tuodongdiuqi_1_png", false)
  end
end
function BackPackPanelUI:EquipDraggedItem(TargetWeapon)
  local EItemAssociationType = import("EItemAssociationType")
  local TargetSocketAssociationType = EItemAssociationType.None
  local ItemBeDraggedType = self.ItemBeDragged.DefineID.Type
  local ItemBeDraggedId = self.ItemBeDragged.DefineID.TypeSpecificID
  if ItemBeDraggedType == 1 then
    local BackpackUtils = import("BackpackUtils")
    local ItemData = CDataTable.GetTableData("Item", ItemBeDraggedId)
    local ItemSubType = ItemData and ItemData.ItemSubType or 0
    if self.DragItemOrigin == EBackPackDragOrigin.FromList or self.DragItemOrigin == EBackPackDragOrigin.FromOccupation then
      local SubType = BackpackUtils.GetItemSubType(ItemBeDraggedId)
      if STExtraModLogicSwitchLibrary.IsActivePickupEquipIntoPack() or SubType == 108 then
        local Res, SocketName = self:CheckCanChangeWeapon(TargetWeapon, ItemSubType)
        local uPawn = GameplayData.GetPlayerCharacter()
        if slua.isValid(uPawn) and Res then
          local WeaponManager = uPawn:GetWeaponManager()
          local CuSurviveWeaponPropSlot = WeaponManager:GetPropSlotByLogicSocket(SocketName)
          TargetSocketAssociationType = BackpackUtils.GetAssociationTypeIDFromWeaponPropSlotType(CuSurviveWeaponPropSlot)
          local PlayerController = self.UIRoot:GetOwningPlayer()
          if slua.isValid(PlayerController) then
            local ItemDefineID = FItemDefineIDDefault()
            local UseTarget = FBattleItemUseTarget()
            UseTarget.TargetDefineID = ItemDefineID
            UseTarget.TargetAssociationType = TargetSocketAssociationType
            UseTarget.TargetActor = nil
            PlayerController:ServerUseItem(self.ItemBeDragged.DefineID, UseTarget, EBattleItemUseReason.EquipAndRecovery)
          end
        end
      end
    elseif TargetWeapon ~= ESurviveWeaponPropSlot.SWPS_SubShootWeapon and ItemSubType ~= 108 and self.DragItemOrigin ~= EBackPackDragOrigin.FromPistol then
      local STExtraUIUtils = import("STExtraUIUtils")
      local uPawn = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
      if slua.isValid(uPawn) then
        uPawn:SwapMainWeapon()
      end
    end
  elseif ItemBeDraggedType == 2 then
    local STExtraUIUtils = import("STExtraUIUtils")
    local uPawn = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
    if slua.isValid(uPawn) then
      local WeaponManager = uPawn:GetWeaponManager()
      local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(TargetWeapon)
      if slua.isValid(Weapon) then
        local ItemDefineID = Weapon:GetItemDefineID()
        if self.DragItemOrigin == EBackPackDragOrigin.FromVehicle then
          EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_WEAPONDETIAL_PICKUP_ATTACHMENT, self.AdditionalDataType, ItemDefineID)
        else
          local PlayerController = self.UIRoot:GetOwningPlayer()
          if PlayerController ~= nil then
            local UseTarget = FBattleItemUseTarget()
            UseTarget.TargetDefineID = ItemDefineID
            UseTarget.TargetAssociationType = EItemAssociationType.None
            UseTarget.TargetActor = nil
            PlayerController:ServerUseItem(self.ItemBeDragged.DefineID, UseTarget, EBattleItemUseReason.Manually)
          end
        end
      else
        print(bWriteLog and "Weapon not valid")
      end
    end
  elseif ItemBeDraggedType == 6 then
    local ItemConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ItemConfig")
    if not ItemConfig.WeaponUpgradeSkill[ItemBeDraggedId] then
      return
    end
    local STExtraUIUtils = import("STExtraUIUtils")
    local uPawn = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
    if slua.isValid(uPawn) then
      local WeaponManager = uPawn:GetWeaponManager()
      local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(TargetWeapon)
      if Game:IsValid(Weapon) then
        local WeaponUpgradeConfig = require("GameLua.Mod.Livik.GamePlay.Weapon.WeaponUpgradeCfg")
        if Weapon.HasUpgrade and not Weapon:HasUpgrade() and WeaponUpgradeConfig.UpgradeCfg[ItemBeDraggedId][Weapon:GetItemDefineID().TypeSpecificID] then
          local UseTarget = FBattleItemUseTarget()
          UseTarget.TargetDefineID = Weapon:GetItemDefineID()
          local PlayerController = self.UIRoot:GetOwningPlayer()
          if PlayerController ~= nil then
            PlayerController:ServerUseItem(self.ItemBeDragged.DefineID, UseTarget, 1)
          end
        end
      end
    end
  end
end
function BackPackPanelUI:UseDraggedIem()
  local EItemAssociationType = import("EItemAssociationType")
  local PlayerController = self.UIRoot:GetOwningPlayer()
  if PlayerController ~= nil then
    local ItemDefineID = FItemDefineIDDefault()
    local UseTarget = FBattleItemUseTarget()
    UseTarget.TargetDefineID = ItemDefineID
    UseTarget.TargetAssociationType = EItemAssociationType.None
    UseTarget.TargetActor = nil
    PlayerController:ServerUseItem(self.ItemBeDragged.DefineID, UseTarget, EBattleItemUseReason.Manually)
  end
end
function BackPackPanelUI:DropDraggedIem()
  local tempexecute_1 = false
  local PlayerController = self.UIRoot:GetOwningPlayer()
  if PlayerController ~= nil then
    if PlayerController.bIsBackPackPanelOpen then
      tempexecute_1 = true
    end
  else
    tempexecute_1 = true
  end
  if tempexecute_1 then
    local EBackpackTab = UEnums.EBackpackTab
    if self.CurChosenTab ~= EBackpackTab.StoreItem and self.ItemBeDragged then
      self:ShowDropCountSliderByStuff(self.ItemBeDragged, true)
      local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
      local IsGun = BackPackFunctionLibrary.IsGun(self.ItemBeDragged.DefineID)
      if IsGun then
        local STExtraUIUtils = import("STExtraUIUtils")
        local uPawn = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
        if slua.isValid(uPawn) then
          uPawn:PlaySelfThrowAwayWeaponSound()
        end
      else
        EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_ITEM_DROP_PROCESS, self.ItemBeDragged)
      end
    end
  end
end
function BackPackPanelUI:UnEquipDraggedItem()
  local ItemBeDraggedType = self.ItemBeDragged.DefineID.Type
  if ItemBeDraggedType == 2 or ItemBeDraggedType == 10 then
    local PlayerController = self.UIRoot:GetOwningPlayer()
    if PlayerController ~= nil then
      if self.CurExpandingStoreAreaType == EItemStoreArea.InBag then
        PlayerController:ServerDisuseItem(self.ItemBeDragged.DefineID, EBattleItemDisuseReason.Manually)
      elseif self.CurExpandingStoreAreaType == EItemStoreArea.InSafetyBox then
        local itembedragged_count_3 = self.ItemBeDragged.Count
        PlayerController:ServerChangeItemStoreArea(self.ItemBeDragged.DefineID, itembedragged_count_3, EItemStoreArea.InSafetyBox)
        PlayerController:ServerDisuseItem(self.ItemBeDragged.DefineID, EBattleItemDisuseReason.PutIntoSafetyBox)
      end
    end
  else
    local ItemId = self.ItemBeDragged.DefineID.TypeSpecificID
    local BackpackUtils = import("BackpackUtils")
    local ItemSubType = BackpackUtils.GetItemSubType(ItemId)
    if (STExtraModLogicSwitchLibrary.IsActivePickupEquipIntoPack() or ItemSubType == 108) and (ItemBeDraggedType == 1 or ItemBeDraggedType == 5) then
      local PlayerController = self.UIRoot:GetOwningPlayer()
      if PlayerController ~= nil then
        if self.CurExpandingStoreAreaType == EItemStoreArea.InBag then
          PlayerController:ServerDisuseItem(self.ItemBeDragged.DefineID, EBattleItemDisuseReason.PutBack)
        elseif self.CurExpandingStoreAreaType == EItemStoreArea.InSafetyBox then
          PlayerController:ServerChangeItemStoreArea(self.ItemBeDragged.DefineID, self.ItemBeDragged.Count, EItemStoreArea.InSafetyBox)
          PlayerController:ServerDisuseItem(self.ItemBeDragged.DefineID, EBattleItemDisuseReason.PutIntoSafetyBox)
        end
      end
    end
  end
end
function BackPackPanelUI:OnDropImplementation(MyGeometry, PointerEvent, Operation)
  local BackPackDragDropOpt_BP_C = slua.loadClass("/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackDragDropOpt_BP.BackPackDragDropOpt_BP")
  if Game:IsClassOf(Operation, BackPackDragDropOpt_BP_C) then
    local KismetInputLibrary = import("KismetInputLibrary")
    local returnvalue_4 = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(PointerEvent)
    self:OnItemDragDrop(Operation.ItemData, Operation.ItemFrom, returnvalue_4, Operation.AdditionalDataType)
    self.UIRoot.OnDropResult = true
  else
    self.UIRoot.OnDropResult = false
  end
end
function BackPackPanelUI:OnItemDragDrop(BattleItemData, DragItemOrigin, Location, AdditionalDataType)
  self.ItemBeDragged = BattleItemData
  self.  self.Drag  self.  self:ResetAttachSlots()
  self:ResetUpgradeWeapon()
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_ITEM_DRAG_DROP)
  if self.DragItemOrigin == EBackPackDragOrigin.FromWeapon1 then
    self.WeaponInfoItem_Weapon1:HighLightBG(false)
  elseif self.DragItemOrigin == EBackPackDragOrigin.FromWeapon2 then
    self.WeaponInfoItem_Weapon2:HighLightBG(false)
  elseif self.DragItemOrigin == EBackPackDragOrigin.FromPistol then
    self.PistolInfoItem_BP:HighLightBG(false)
  elseif self.DragItemOrigin == EBackPackDragOrigin.FromOccupation then
    self.PistolInfoItem_BP:HighLightBG(false)
  end
  if self.Image_Drop then
    self.Image_Drop:SetBrushfromPathAsync("/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/ZD_icon_tuodongdiuqi_png.ZD_icon_tuodongdiuqi_png", false)
  end
  local ItemID = BattleItemData.DefineID.TypeSpecificID
  if self:CheckExtraWidgetDragDrop(BattleItemData, DragItemOrigin, Location, AdditionalDataType) then
    print(bWriteLog and "BackPackPanelUI:OnItemDragDrop ExtraWidgetDragDrop ItemID:" .. ItemID)
  elseif self:CheckModWidgetDragDrop(BattleItemData, DragItemOrigin, Location, AdditionalDataType) then
    print(bWriteLog and "BackPackPanelUI:OnItemDragDrop ModWidgetDragDrop ItemID:" .. ItemID)
  elseif self.ItemDragNowCount ~= nil then
    self:DropSlideDone()
  elseif UIUtil.IsLocalpositionInBorder(Location, self.GridPanel_BackPackList) then
    if self.DragItemOrigin ~= EBackPackDragOrigin.FromList then
      if self.DragItemOrigin == EBackPackDragOrigin.FromVehicle then
        local ItemDefineID = FItemDefineIDDefault()
        EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_WEAPONDETIAL_PICKUP_ATTACHMENT, AdditionalDataType, ItemDefineID)
      end
      self.bHasHoldPickup = false
      for _, Widget in pairs(self.tExtraWidgets) do
        local Hold = Widget:PickToBackpack(self.ItemBeDragged, self.DragItemOrigin)
        if Hold then
          self.bHasHoldPickup = true
          break
        end
      end
      if not self.bHasHoldPickup then
        self:UnEquipDraggedItem()
      end
    end
  elseif UIUtil.IsLocalpositionInBorder(Location, self.WeaponInfoItem_Weapon1.UIRoot) then
    if self.DragItemOrigin ~= EBackPackDragOrigin.FromWeapon1 then
      self:EquipDraggedItem(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
    end
  elseif UIUtil.IsLocalpositionInBorder(Location, self.WeaponInfoItem_Weapon2.UIRoot) then
    if self.DragItemOrigin ~= EBackPackDragOrigin.FromWeapon2 then
      self:EquipDraggedItem(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
    end
  elseif UIUtil.IsLocalpositionInBorder(Location, self.MeleeInfoItem_BP.UIRoot) then
    if self.DragItemOrigin ~= EBackPackDragOrigin.FromMelee then
      self:EquipDraggedItem(ESurviveWeaponPropSlot.SWPS_MeleeWeapon)
    end
  elseif UIUtil.IsLocalpositionInBorder(Location, self.PistolInfoItem_BP.UIRoot) then
    if self.DragItemOrigin ~= EBackPackDragOrigin.FromPistol then
      self:EquipDraggedItem(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
    end
  elseif UIUtil.IsLocalpositionInBorder(Location, self.UniformGridPanel_Armor) then
    if STExtraModLogicSwitchLibrary.IsActivePickupEquipIntoPack() and self.DragItemOrigin ~= EBackPackDragOrigin.FromBackpackWeaponDetail then
      self:EquipDraggedArmor(Location)
    end
  elseif UIUtil.IsLocalpositionInBorder(Location, self.Image_EquipmentInfo) then
    if self.DragItemOrigin ~= EBackPackDragOrigin.FromArmor and STExtraModLogicSwitchLibrary.IsActivePickupEquipIntoPack() and self.DragItemOrigin ~= EBackPackDragOrigin.FromBackpackWeaponDetail then
      self:EquipDraggedArmor(Location)
    end
  elseif UIUtil.IsLocalpositionInBorder(Location, self.CanvasPanel_WeaponDetail) then
    if self.DragItemOrigin ~= EBackPackDragOrigin.FromOccupation then
      EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_DRAG_ITEM_TO_EQUIPMENT_DETAIL, Location, self.ItemBeDragged)
    end
  else
    self:DropDraggedIem()
  end
  self:DelayEnableCharacterTouch()
  self.ItemBeDragged = nil
  self:EnterDrag(false)
  print(bWriteLog and "BackPackPanelUI:OnItemDragDrop")
end
function BackPackPanelUI:CheckExtraWidgetDragDrop(BattleItemData, DragItemOrigin, Location, AdditionalDataType)
  for _, Widget in pairs(self.tExtraWidgets) do
    if Game:IsValid(Widget) and Widget:OnItemDragDrop(BattleItemData, DragItemOrigin, Location) then
      return true
    end
  end
  return false
end
function BackPackPanelUI:CheckModWidgetDragDrop(BattleItemData, DragItemOrigin, Location, AdditionalDataType)
  return false
end
function BackPackPanelUI:EquipDraggedArmor(Location)
  local EItemAssociationType = import("EItemAssociationType")
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_EQUIP_DRAGGED_ARMOR, Location, self.ItemBeDragged)
  local ItemId = self.ItemBeDragged.DefineID.TypeSpecificID
  local ItemData = CDataTable.GetTableData("Item", ItemId)
  local DraggedItemSubType = ItemData and ItemData.ItemSubType or 0
  local tempexecute_1 = false
  if UIUtil.IsLocalpositionInBorder(Location, self.ArmorSlotItem_Helmet) then
    if DraggedItemSubType == 502 then
      tempexecute_1 = true
    end
  elseif UIUtil.IsLocalpositionInBorder(Location, self.ArmorSlotItem_ArmoredVest) then
    if DraggedItemSubType == 503 then
      tempexecute_1 = true
    end
  elseif UIUtil.IsLocalpositionInBorder(Location, self.ArmorSlotItem_Package) and DraggedItemSubType == 501 then
    tempexecute_1 = true
  end
  if tempexecute_1 then
    local PlayerController = self.UIRoot:GetOwningPlayer()
    if PlayerController ~= nil then
      local ItemDefineID = FItemDefineIDDefault()
      local UseTarget = FBattleItemUseTarget()
      UseTarget.TargetDefineID = ItemDefineID
      UseTarget.TargetAssociationType = EItemAssociationType.None
      UseTarget.TargetActor = nil
      PlayerController:ServerUseItem(self.ItemBeDragged.DefineID, UseTarget, EBattleItemUseReason.EquipAndRecovery)
    end
  end
end
function BackPackPanelUI:OnItemDragCancelled()
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_ITEM_DRAG_CANCELLED)
  if self.DragItemOrigin == EBackPackDragOrigin.FromWeapon1 then
    self.WeaponInfoItem_Weapon1:HighLightBG(false)
  end
  if self.DragItemOrigin == EBackPackDragOrigin.FromWeapon2 then
    self.WeaponInfoItem_Weapon2:HighLightBG(false)
  end
  if self.DragItemOrigin == EBackPackDragOrigin.FromPistol then
    self.PistolInfoItem_BP:HighLightBG(false)
  end
  if self.DragItemOrigin == EBackPackDragOrigin.FromOccupation and slua.isValid(self.DragDropWidgetWeaponDetail) then
    local return_36 = self.DragDropWidgetWeaponDetail:HighLightBG(false)
  end
  if self.Image_Drop then
    self.Image_Drop:SetBrushfromPathAsync("/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/ZD_icon_tuodongdiuqi_png.ZD_icon_tuodongdiuqi_png", false)
  end
  self:DropDraggedIem()
  self:DelayEnableCharacterTouch()
  print(bWriteLog and "OnItemDragCancelled")
  self:EnterDrag(false)
end
function BackPackPanelUI:OnTouchStarted(MyGeometry, InTouchEvent)
  local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  local Handled = WidgetBlueprintLibrary.Handled()
  local Capture = WidgetBlueprintLibrary.CaptureMouse(Handled, self.UIRoot)
  return Capture
end
function BackPackPanelUI:OnTouchEnded(MyGeometry, InTouchEvent)
  local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  local Handled = WidgetBlueprintLibrary.Handled()
  local Capture = WidgetBlueprintLibrary.ReleaseMouseCapture(Handled)
  return Capture
end
function BackPackPanelUI:ShouldDropItemFunc(DefineID)
  local TableUtil = require("common.table_util")
  local uPlayerController = GameplayData.GetPlayerController()
  local bIsControllerValid = slua.isValid(uPlayerController)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  local CanNotDropItemLuaConfig = BackpackConfig.CanNotDropItemID
  local ItemID = DefineID.TypeSpecificID
  local bCanNotDrop = TableUtil.Find(CanNotDropItemLuaConfig, ItemID) ~= -1
  if not bCanNotDrop then
    local ItemAttrsTableData = CDataTable.GetTableData("ItemAttrs", ItemID)
    bCanNotDrop = ItemAttrsTableData and ItemAttrsTableData.CannotManualDrop
  end
  if bCanNotDrop then
    if bIsControllerValid then
      uPlayerController:DisplayGameTipWithMsgID(30128)
      return false
    else
      return false
    end
  end
  local STExtraUIUtils = import("STExtraUIUtils")
  local uCharacter = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uCharacter) then
    return uCharacter:ShouldDropBagItem(DefineID)
  end
  return false
end
function BackPackPanelUI:CheckCanChangeWeapon(Slot, ItemSubType)
  local bIsCanNotChange = false
  if Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    if ItemSubType ~= 108 and ItemSubType ~= 106 then
      return true, "MainSlot1"
    else
      bIsCanNotChange = true
    end
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    if ItemSubType ~= 108 and ItemSubType ~= 106 then
      return true, "MainSlot2"
    else
      bIsCanNotChange = true
    end
  elseif Slot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    if ItemSubType == 106 then
      return true, "SubSlot"
    else
      bIsCanNotChange = true
    end
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MeleeWeapon then
    if ItemSubType == 108 then
      return true, "MeleeSlot"
    else
      bIsCanNotChange = true
    end
  elseif Slot == ESurviveWeaponPropSlot.SWPS_HandProp then
    bIsCanNotChange = true
  elseif Slot == ESurviveWeaponPropSlot.SWPS_None then
    bIsCanNotChange = true
  end
  if bIsCanNotChange then
    return false, "None"
  end
end
function BackPackPanelUI:EnterDrag(bEnter)
  if bEnter then
    self.UIRoot.bItemDrag = true
    self:ClearDropSlideData()
  else
    self.UIRoot.bItemDrag = false
    self:ClearDropSlideData()
  end
end
function BackPackPanelUI:OnDropSlide(PointerEvent)
  print(bWriteLog and "BackPackPanelUI:DropSlide")
  if not self.ItemBeDragged then
    return
  end
  local KismetInputLibrary = import("KismetInputLibrary")
  local Location = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(PointerEvent)
  local TotalCount = self.ItemBeDragged.Count
  local DropSlideConfig = GamePlayTools.GetCurrentConfig("BackpackConfig").DropSlideInfo
  if 1 < TotalCount then
    if UIUtil.IsLocalpositionInBorder(Location, self.UIRoot.VerticalBox_Btns) then
      print(bWriteLog and "BackPackPanelUI:DropSlide hello")
      EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_BACKPACK_SHOW_DROP_SLIDER_GUIDE)
      if self.StartLocation == nil then
        self.Start        if slua.isValid(CGameState) then
          self.StartTime = CGameState:GetServerWorldTimeSeconds()
          if not self.StartTimer then
            self.StartTimer = self:AddGameTimer(DropSlideConfig.StayTime, false, function()
              if self.OpenLocation == nil then
                self.OpenLocation = self.StartLocation
                if self.ItemBeDragged then
                  local DragCount = self:CalculateNowCount(self.OpenLocation, self.ItemBeDragged.Count, true)
                  self:ShowSliderUI(self, DragCount, TotalCount, Location)
                end
                if self.StartTimer ~= nil then
                  self:RemoveGameTimer(self.StartTimer)
                end
                self.StartTimer = nil
              end
            end)
          end
        end
      else
        local Dist = math.abs(self.StartLocation.Y - Location.Y)
        if Dist > DropSlideConfig.Theta and self.OpenLocation == nil then
          self.Open          local DragCount = self:CalculateNowCount(Location, self.ItemBeDragged.Count, true)
          self:ShowSliderUI(self, DragCount, TotalCount, Location)
          if self.StartTimer ~= nil then
            self:RemoveGameTimer(self.StartTimer)
          end
          self.StartTimer = nil
        end
      end
      if self.OpenLocation ~= nil then
        local BackPackDropSlideUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackDropSlideUI)
        if BackPackDropSlideUI and BackPackDropSlideUI:GetIsShow() then
          self.ItemDragNowCount = self:CalculateNowCount(Location, self.ItemBeDragged.Count)
          BackPackDropSlideUI:ChangeNowCount(self.ItemDragNowCount)
        end
      end
    else
      self:ClearDropSlideData()
    end
  end
end
function BackPackPanelUI:ClearDropSlideData()
  self.StartLocation = nil
  self.OpenLocation = nil
  self.ItemDragNowCount = nil
  self.StartTime = nil
  if self.StartTimer ~= nil then
    self:RemoveGameTimer(self.StartTimer)
  end
  self.StartTimer = nil
  self:HideSliderUI()
end
function BackPackPanelUI:CalculateNowCount(Location, TotalCount, bIsFirst)
  local DropSlideConfig = GamePlayTools.GetCurrentConfig("BackpackConfig").DropSlideInfo
  local NowCount
  local HalfLength = DropSlideConfig.Length / 2
  local CurLocY = Location.Y
  local MinY = self.OpenLocation.Y + HalfLength
  local NowPercent = 0.5
  if bIsFirst then
    self.FirstChangeCount = true
  end
  if HalfLength < self.OpenLocation.Y - CurLocY then
    self.OpenLocation.Y = HalfLength + CurLocY
  elseif HalfLength < CurLocY - self.OpenLocation.Y then
    self.OpenLocation.Y = CurLocY - HalfLength
  end
  if self.FirstChangeCount and math.abs(self.OpenLocation.Y - Location.Y) >= DropSlideConfig.FirstIgnoreLen then
    self.OpenLocation.Y = Location.Y
    self.FirstChangeCount = false
  elseif not self.FirstChangeCount or math.abs(self.OpenLocation.Y - Location.Y) > DropSlideConfig.FirstIgnoreLen then
    NowPercent = math.max(0, math.min(1.0, (MinY - Location.Y) / DropSlideConfig.Length))
  end
  NowCount = math.floor((TotalCount - 1) * NowPercent) + 1
  return NowCount
end
function BackPackPanelUI:DropSlideDone()
  if self.ItemDragNowCount ~= nil then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_ITEM_DELETE_PANEL_CONFIRM, self.ItemBeDragged, UEnums.DropItem.Ground, self.ItemDragNowCount)
  end
end
function BackPackPanelUI:HideSliderUI()
  local SliderUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackDropSlideUI)
  if SliderUI then
    SliderUI:HideAndClearData()
  end
end
function BackPackPanelUI:ShowSliderUI(ParentWidget, NowCount, ItemCount, Location)
  local SliderUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackDropSlideUI)
  if SliderUI then
    SliderUI:ShowAndUpdateData(NowCount, ItemCount, Location)
  else
    UIManager.ShowUI(UIManager.UI_Config_InGame.BackPackDropSlideUI, ParentWidget, NowCount, ItemCount, Location)
  end
end