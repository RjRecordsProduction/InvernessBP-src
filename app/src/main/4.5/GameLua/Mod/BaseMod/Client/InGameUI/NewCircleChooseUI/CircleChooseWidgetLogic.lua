local uBackpackUtils = import("BackpackUtils")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PriorityQueue = require("common.priority_queue")
local TableUtil = require("common.table_util")
local TableUtil_Clear = TableUtil.Clear
local TableUtil_ClearArray = TableUtil.ClearArray
local table_insert = table.insert
local table_remove = table.remove
local PriorityComp = function(EleA, EleB)
  return EleA.Priority < EleB.Priority
end
local EqualFunc = function(EleA, EleB)
  return EleA.InstanceID == EleB.InstanceID
end
local bUseBackpackProxy = true
local CircleChooseWidgetLogic = {}
function CircleChooseWidgetLogic:ctor()
  print(bWriteLog and "CircleChooseWidgetLogic:ctor", self)
  self.GrenadesAndMelees = {}
  self.Consumables = {}
  self.SortedGrenadesList = {}
  self.SortedGrenadesPriorityList = {}
  self.SortedConsumablesList = PriorityQueue(PriorityComp, EqualFunc)
  self.FinalGrenadesList = {}
  self.FinalConsumables = {}
  self.RingListData = {}
  self.AvatarPathByID = {}
  self.MedThrowPathByID = {}
  self.CurrentSelectedGrenadeIDData = {InstanceID = 0, TypeSpecificID = 0}
  self.CurrentSelectedConsumableBattleItem = nil
  self.PreUsingGrenadeID = -1
  self.IsChoosingMedicine = false
  self.bUsingIgnoreThrowable = false
  self.LastGrenadeCnt = 0
  self.LastMedicineThrown = false
  self.CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
  self.SortingMode = self.CircleChooseCfg.EConsumableSortMode.FullHealth
  self.LastSortTime = 0
  self.CachedHP = 100
  self.MaxHP = 100
  self.RelatedTypeList = {}
  self.RelatedIDList = {}
  self.RelatedTypeListArray = nil
  self.RelatedIDListArray = nil
  self.PlayerCharacter = nil
  self.BackpackComp = nil
  self.WeaponMgr = nil
  self.bIntelligentSort = false
  self.SortCD = 60
  self.bEnableThrowMeds = nil
  self.bWithSkin = true
  self.ModType = nil
  self.CachedGameState = nil
  self.CachedPlayerState = nil
  self.bWaitForceUpdateList = false
end
function CircleChooseWidgetLogic:OnInit()
  self.ModType = GameMainConfig.GetModType()
  print(bWriteLog and "CircleChooseWidgetLogic:OnInit", self.ModType)
  self:InitData()
  self:RegisterUserSettings()
  self:RegistCommonEvents()
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    print(bWriteLog and "CircleChooseWidgetLogic:CharacterDataReady")
    self:RegistEvents()
    self:WaitForceUpdateList()
  end)
  self:AddDataListener(SuperData, "GameState", function(_, GameState)
    self.Cached  end)
end
function CircleChooseWidgetLogic:WaitForceUpdateList()
  self.bWaitForceUpdateList = true
  self:AddGameTimer(2, false, function()
    if not self.bWaitForceUpdateList then
      return
    end
    self:ForceUpdateList()
  end)
end
function CircleChooseWidgetLogic:InitData()
  self.RelatedTypeListArray = slua.Array(UEnums.EPropertyClass.Int)
  self.RelatedIDListArray = slua.Array(UEnums.EPropertyClass.Int)
  local tRelatedSubType = self.CircleChooseCfg.RelatedSubtype or {}
  for key, value in pairs(tRelatedSubType) do
    table_insert(self.RelatedTypeList, key)
    self.RelatedTypeListArray:Add(key)
  end
  local tRelatedID = self.CircleChooseCfg.RelatedID or {}
  for key, value in pairs(tRelatedID) do
    table_insert(self.RelatedIDList, key)
    self.RelatedIDListArray:Add(key)
  end
  self.SortCD = 60
end
function CircleChooseWidgetLogic:OnRelease()
  print(bWriteLog and "CircleChooseWidgetLogic:OnRelease " .. tostring(self))
  self.WeaponMgr = nil
  self.BackpackComp = nil
  self.PlayerCharacter = nil
  self.CachedGameState = nil
  self.CachedPlayerState = nil
  if UIManager.UI_Config_InGame.GrenadeChooseWidgetNew then
    UIManager.CloseUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
  end
  if UIManager.UI_Config_InGame.MedicineChooseWidgetNew then
    UIManager.CloseUI(UIManager.UI_Config_InGame.MedicineChooseWidgetNew)
  end
  CircleChooseWidgetLogic.__super.OnRelease(self)
end
function CircleChooseWidgetLogic:ResetUIStateAfterRespawn()
  print("CircleChooseWidgetLogic:ResetUIStateAfterRespawn")
  self:RegistEvents()
end
function CircleChooseWidgetLogic:RegistCommonEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REFRESHUI_AFTERRESPAWN, self.ResetUIStateAfterRespawn, self)
  if not bUseBackpackProxy then
    self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST, function(_, _, uBackpackComponent)
      if slua.isValid(uBackpackComponent) then
        print(bWriteLog and "CircleChooseWidgetLogic:EVENTID_BACKPACK_UPDATE_ITEM_LIST")
        local bUpdate = false
        if self.RelatedTypeListArray and self.RelatedTypeListArray:Num() > 0 and uBackpackComponent:IsItemListUpdatedHasSomeItemSubTypes(self.RelatedTypeListArray) then
          bUpdate = true
        end
        if self.RelatedIDListArray and 0 < self.RelatedIDListArray:Num() and uBackpackComponent:IsItemListUpdatedHasSomeItems(self.RelatedIDListArray) then
          bUpdate = true
        end
        if bUpdate then
          self:ForceUpdateList()
        end
      end
    end)
  end
end
function CircleChooseWidgetLogic:RegistEvents()
  print(bWriteLog and "CircleChooseWidgetLogic:RegistEvents", self)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and not uPlayerController:IsSpectator() then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFighting", self.HandlePlayerEnterFighting, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.HandlePlayerEnterFighting, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnLocalCharacterHPChangeDel", self.HandleHPChange, self)
    self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
    self:InitWeaponChangeDel()
    local uPlayerState = self.CachedPlayerState
    if slua.isValid(uPlayerState) and uPlayerState.GetPlayerMaxHealth then
      self.MaxHP = uPlayerState:GetPlayerMaxHealth()
    end
    self:InitVehicleDel()
  end
  self:UpdateCurrentSelectedConsumableItemID()
end
function CircleChooseWidgetLogic:RegisterUserSettings()
  self:AddSettingOptionEvent("bConsumeThrow", function(bMedsThrowEnable)
    self:RefreshMedsThrowShow(bMedsThrowEnable)
  end)
  self:AddSettingOptionEvent("IntelligentDrugs", function(bIntelligentSort)
    self:RefreshIntelligentSort(bIntelligentSort)
  end)
  self.bEnableThrowMeds = CircleChooseUtil.GetSettingByStrKey("bConsumeThrow")
  self.bIntelligentSort = CircleChooseUtil.GetSettingByStrKey("IntelligentDrugs")
  self.bWithSkin = LobbySystem.CheckOpen(BP_ENUM_INGAME_GRENADE_SKIN_SWITCH)
end
function CircleChooseWidgetLogic:OnPlayerCharacterChange()
  print(bWriteLog and "CircleChooseWidgetLogic OnPlayerCharacterChange")
  local uWeaponMgr = self:GetWeaponMgr()
  if slua.isValid(uWeaponMgr) then
    self:RemoveControlEvent(uWeaponMgr, "ChangeCurrentUsingWeaponDelegate")
  end
  self.PlayerCharacter = nil
  self.BackpackComp = nil
  self.WeaponMgr = nil
  self:InitWeaponChangeDel()
  self:InitVehicleDel()
  self:ForceUpdateList()
end
function CircleChooseWidgetLogic:HandlePlayerEnterFighting()
  print(bWriteLog and "CircleChooseWidgetLogic ONPlayerEnteringFighting ForceUpdate")
  self:InitWeaponChangeDel()
  self:InitVehicleDel()
  self:ForceUpdateList()
end
function CircleChooseWidgetLogic:InitWeaponChangeDel()
  local uWeaponMgr = self:GetWeaponMgr()
  if slua.isValid(uWeaponMgr) then
    self:AddControlEvent(uWeaponMgr, "ChangeCurrentUsingWeaponDelegate", self.HandleWeaponchange, self)
    local CurrentUsingSlot = uWeaponMgr:GetCurrentUsingPropSlot()
    self:HandleWeaponchange(CurrentUsingSlot)
  end
end
function CircleChooseWidgetLogic:InitVehicleDel()
  local RelatedVehicles = self.CircleChooseCfg.RelatedVehicleType
  if TableUtil.CountTable(RelatedVehicles) > 0 then
    print(bWriteLog and "CircleChooseWidgetLogic:InitVehicleDel")
    local uPlayer = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayer) then
      self:AddControlEvent(uPlayer, "OnAttachedToVehicle", self.HandleAttachedToVehicle, self)
    end
  end
end
function CircleChooseWidgetLogic:ForceUpdateList()
  if bUseBackpackProxy then
    self:ForceUpdateList_New()
  else
    self:ForceUpdateList_Old()
  end
end
function CircleChooseWidgetLogic:ForceUpdateList_New()
  local BackpackConsumableProxy = CircleChooseUtil.GetBackpackConsumableProxy()
  if not BackpackConsumableProxy then
    return
  end
  self.bWaitForceUpdateList = false
  if bWriteLog then
    print("CircleChooseWidgetLogic:ForceUpdateList_New")
  end
  TableUtil_Clear(self.GrenadesAndMelees)
  TableUtil_Clear(self.Consumables)
  TableUtil_ClearArray(self.SortedGrenadesList)
  TableUtil_ClearArray(self.FinalGrenadesList)
  TableUtil_ClearArray(self.FinalConsumables)
  TableUtil_Clear(self.RingListData)
  self:CachePC()
  local ConsumablesDataTemp = BackpackConsumableProxy:GetConsumablesData()
  if ConsumablesDataTemp then
    for InstanceID, BattleItemData in pairs(ConsumablesDataTemp) do
      self.Consumables[InstanceID] = BattleItemData
    end
  end
  local GrenadesAndMeleesDataTemp = BackpackConsumableProxy:GetGrenadesAndMeleesData()
  if GrenadesAndMeleesDataTemp then
    for InstanceID, BattleItemData in pairs(GrenadesAndMeleesDataTemp) do
      self.GrenadesAndMelees[InstanceID] = BattleItemData
    end
  end
  local SortedGrenadesAndMeleesTemp = BackpackConsumableProxy:GetSortedGrenadesAndMeleesData()
  if SortedGrenadesAndMeleesTemp then
    for Index, SortData in pairs(SortedGrenadesAndMeleesTemp) do
      self.SortedGrenadesList[Index + 1] = SortData.InstanceID
    end
  end
  local RingListDataTemp = BackpackConsumableProxy:GetRingListData()
  if RingListDataTemp then
    for _, BattleItemData in pairs(RingListDataTemp) do
      self.RingListData[BattleItemData.DefineID.TypeSpecificID] = BattleItemData
    end
  end
  self:RefreshUIPanels(false, true)
end
function CircleChooseWidgetLogic:ForceUpdateList_Old()
  if bWriteLog then
    print("CircleChooseWidgetLogic:ForceUpdateList")
  end
  TableUtil_Clear(self.GrenadesAndMelees)
  TableUtil_Clear(self.Consumables)
  TableUtil_ClearArray(self.SortedGrenadesList)
  TableUtil_ClearArray(self.SortedGrenadesPriorityList)
  self.SortedConsumablesList:Clear()
  TableUtil_ClearArray(self.FinalGrenadesList)
  TableUtil_ClearArray(self.FinalConsumables)
  TableUtil_Clear(self.RingListData)
  self:CachePC()
  if slua.isValid(self.PlayerCharacter) and slua.isValid(self.BackpackComp) then
    local ResList = uBackpackUtils.GetDesignatedTypeItemInBackpack(self.BackpackComp, self.RelatedTypeList)
    for key, BattleItem in pairs(ResList) do
      self:RefreshDataArray(BattleItem.DefineID)
    end
    local ResIDList = uBackpackUtils.GetBattleItemDataListByIDList(self.BackpackComp, self.RelatedIDList)
    for key, BattleItem in pairs(ResIDList) do
      self:RefreshDataArray(BattleItem.DefineID)
    end
    self:RefreshUIPanels(false, true)
  end
end
function CircleChooseWidgetLogic:RefreshDataArray(ItemDefineID)
  if self.CircleChooseCfg.IgnoreThrowableID and TableUtil.Find(self.CircleChooseCfg.IgnoreThrowableID, ItemDefineID.TypeSpecificID) ~= -1 then
    return
  end
  local TypeSpecificID = ItemDefineID.TypeSpecificID
  if self:IsConsumable(TypeSpecificID) then
    if bWriteLog then
      print("CircleChooseWidgetLogic::Add Meds Item ID:", TypeSpecificID, ItemDefineID.InstanceID)
    end
    local UpdateDataState = self:UpdateDataDic(ItemDefineID, self.Consumables, ItemDefineID.InstanceID)
    if UpdateDataState == 1 then
      self.SortedConsumablesList:Push({
        InstanceID = ItemDefineID.InstanceID,
        Priority = self:GetPriority(ItemDefineID)
      })
    elseif UpdateDataState == 0 then
      self.SortedConsumablesList:Remove({
        InstanceID = ItemDefineID.InstanceID,
        Priority = self:GetPriority(ItemDefineID)
      })
    end
  end
  if CircleChooseUtil.SimGrenade(TypeSpecificID) or CircleChooseUtil.SimMelee(TypeSpecificID) then
    if bWriteLog then
      print("CircleChooseWidgetLogic::Add Grenades Item ID:", TypeSpecificID, ItemDefineID.InstanceID)
    end
    local UpdateDataState = self:UpdateDataDic(ItemDefineID, self.GrenadesAndMelees, ItemDefineID.InstanceID)
    if UpdateDataState == 1 then
      local Priority = self:GetPriority(ItemDefineID)
      local InsertIndex = #self.SortedGrenadesList + 1
      for Index, Value in ipairs(self.SortedGrenadesList) do
        local TempPriority = self.SortedGrenadesPriorityList[Index]
        if Priority < TempPriority then
          Insert          break
        elseif TempPriority == Priority and Value >= ItemDefineID.InstanceID then
          Insert          break
        end
      end
      table_insert(self.SortedGrenadesList, InsertIndex, ItemDefineID.InstanceID)
      table_insert(self.SortedGrenadesPriorityList, InsertIndex, Priority)
    elseif UpdateDataState == 0 then
      for Index, Value in ipairs(self.SortedGrenadesList) do
        if Value == ItemDefineID.InstanceID then
          table_remove(self.SortedGrenadesList, Index)
          table_remove(self.SortedGrenadesPriorityList, Index)
          break
        end
      end
    end
  end
  if CircleChooseUtil.IsRingListItem(TypeSpecificID) then
    self:UpdateDataDic(ItemDefineID, self.RingListData, ItemDefineID.TypeSpecificID)
  end
end
function CircleChooseWidgetLogic:IsConsumable(TypeSpecificID)
  return CircleChooseUtil.IsAMedicine(TypeSpecificID) or CircleChooseUtil.IsAIceDrink(TypeSpecificID)
end
function CircleChooseWidgetLogic:UpdateDataDic(ItemDefineID, DataDic, InstanceID)
  if slua.isValid(self.BackpackComp) then
    local BattleItem = self.BackpackComp:GetItemByDefineID(ItemDefineID)
    if slua.isValid(BattleItem) then
      if BattleItem.Count > 0 then
        local Data = DataDic[InstanceID]
        if Data then
          Data.Count = Data.Count + BattleItem.Count
        else
          DataDic[InstanceID] = BattleItem
        end
        return 1
      elseif BattleItem.Count == 0 then
        if DataDic[InstanceID] then
          DataDic[InstanceID] = nil
          return 0
        end
      elseif bWriteLog then
        print("CircleChooseWidgetLogic:UpdateDataDic BattleItem.Count < 0 : ", InstanceID, BattleItem.Count)
      end
    elseif DataDic[InstanceID] then
      DataDic[InstanceID] = nil
      return 0
    end
  end
  return -1
end
function CircleChooseWidgetLogic:RefreshUIPanels(bForce, bManual)
  self:SortGrenadesAndMelees()
  self:SetGrenadeOrder()
  self:UpdateCurGrenade()
  self:SortConsumables(bForce, bManual)
  self:UpdateCurMed()
  self:UpdateGrenadePanel()
  self:UpdateMedicinePanel()
end
function CircleChooseWidgetLogic:UpdateCurGrenade()
  print(bWriteLog and "CircleChooseWidgetLogic:UpdateCurGrenade", self.bUsingIgnoreThrowable)
  if self.bUsingIgnoreThrowable then
    return
  end
  self.CurrentSelectedGrenadeIDData.InstanceID, self.CurrentSelectedGrenadeIDData.TypeSpecificID = self:GetGrenadeIDByWeapon()
  print(bWriteLog and "CircleChooseWidgetLogic:UpdateCurGrenade self.CurrentSelectedGrenadeIDData = " .. self.CurrentSelectedGrenadeIDData.InstanceID .. ", " .. self.CurrentSelectedGrenadeIDData.TypeSpecificID)
  if self.CurrentSelectedConsumableBattleItem then
    if self.CurrentSelectedGrenadeIDData.InstanceID ~= self.CurrentSelectedConsumableBattleItem.DefineID.InstanceID then
      self:SetIsChoosingMedicine(false)
    end
  else
    self:SetIsChoosingMedicine(false)
  end
end
function CircleChooseWidgetLogic:UpdateCurMed()
  self.CurrentSelectedConsumableBattleItem = nil
  if #self.FinalConsumables > 0 then
    self.CurrentSelectedConsumableBattleItem = self.FinalConsumables[1]
    local ItemID = self.CurrentSelectedConsumableBattleItem.DefineID.TypeSpecificID
    local bThrowable = self.CircleChooseCfg.ThrowableMedicineIDMap[ItemID]
    self:UpdateCurrentSelectedConsumableItemID()
    if true == bThrowable then
      local Count = self.CurrentSelectedConsumableBattleItem.Count
      self:RefreshCurrentSelectedConsumable(ItemID, Count, false)
      return self.CurrentSelectedConsumableBattleItem
    end
  end
  local GrenadesPanel = UIManager.GetUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
  if GrenadesPanel then
    self:RefreshCurrentSelectedConsumable(0, 0, false)
  end
  self:UpdateCurrentSelectedConsumableItemID()
end
function CircleChooseWidgetLogic:HandleWeaponchange(Slot)
  print(bWriteLog and "CircleChooseWidgetLogic:HandleWeaponchange", Slot)
  local bShow = false
  if Slot == ESurviveWeaponPropSlot.SWPS_MeleeWeapon or Slot == ESurviveWeaponPropSlot.SWPS_HandProp then
    local uWeaponMgr = self:GetWeaponMgr()
    if slua.isValid(uWeaponMgr) then
      local CurWeapon = uWeaponMgr:GetCurrentUsingWeapon()
      if slua.isValid(CurWeapon) then
        local ItemID = CurWeapon:GetItemDefineID().TypeSpecificID
        self.PreUsingGrenadeID = ItemID
        for key, value in ipairs(self.FinalGrenadesList) do
          if value.DefineID.TypeSpecificID == ItemID then
            bShow = true
            break
          end
        end
      else
        self.PreUsingGrenadeID = -1
      end
    end
  else
    self.PreUsingGrenadeID = -1
  end
  self.bUsingIgnoreThrowable = false
  if self.PreUsingGrenadeID ~= -1 and self.CircleChooseCfg.IgnoreThrowableID and TableUtil.Find(self.CircleChooseCfg.IgnoreThrowableID, self.PreUsingGrenadeID) ~= -1 then
    self.bUsingIgnoreThrowable = true
  end
  local GrenadesPanel = UIManager.GetUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
  if GrenadesPanel then
    GrenadesPanel:MarkDownStatus(bShow and not self.bUsingIgnoreThrowable)
  end
  if bShow then
    self:UpdateCurGrenade()
    self:SortGrenadesAndMelees()
    self:SetGrenadeOrder()
    self:UpdateGrenadePanel()
  end
end
function CircleChooseWidgetLogic:HandleAttachedToVehicle(InVehicle)
  if not slua.isValid(InVehicle) then
    return
  end
  if self.CircleChooseCfg.RelatedVehicleType[InVehicle.VehicleType] then
    self:UpdateCurGrenade()
    self:SortGrenadesAndMelees()
    self:SetGrenadeOrder()
    self:UpdateGrenadePanel()
  end
end
function CircleChooseWidgetLogic:RefreshMedsThrowShow(bMedsThrowEnable)
  if bWriteLog then
    print("CircleChooseWidgetLogic:RefreshMedsThrowShow(bMedsThrowEnable), ", bMedsThrowEnable)
  end
  self.bEnableThrowMeds = bMedsThrowEnable
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local uBackpackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(PlayerCharacter)
  if slua.isValid(uBackpackComp) then
    local CurMed = self:UpdateCurMed()
    if CurMed then
      if self.bEnableThrowMeds then
        if bWriteLog then
          print("CircleChooseWidgetLogic:RefreshMedsThrowShow CurMeds", CurMed)
        end
        self:RefreshCurrentSelectedConsumable(CurMed.DefineID.TypeSpecificID, CurMed.Count, true)
      else
        self:RefreshCurrentSelectedConsumable(0, 0, true)
      end
    else
      self:RefreshCurrentSelectedConsumable(0, 0, true)
    end
  end
end
function CircleChooseWidgetLogic:RefreshCurrentSelectedConsumable(ItemID, Count, bForce)
  if self.bEnableThrowMeds or bForce then
    if bWriteLog then
      print("CircleChooseGrenadeUI:RefreshCurrentSelectedConsumable", ItemID, Count, bForce)
    end
  else
    return
  end
  local WeaponMgr = self:GetWeaponMgr()
  if ItemID ~= nil and 0 < ItemID and 0 < Count then
    if not self.IsChoosingMedicine and 0 >= #self.FinalGrenadesList then
      self:SetIsChoosingMedicine(true)
    end
  else
    if self.IsChoosingMedicine then
      self.LastMedicineThrown = true
      self:SetIsChoosingMedicine(false)
    end
    self:SetIsChoosingMedicine(false)
    if slua.isValid(WeaponMgr) and slua.isValid(WeaponMgr.InventoryData) then
      local usingGrenade = WeaponMgr.InventoryData:Get("GrenadeSlot")
      if slua.isValid(usingGrenade) then
        local CurGrenadeID = usingGrenade:GetItemDefineID().TypeSpecificID
        if bWriteLog then
          print("CircleChooseGrenadeUI:RefreshCurrentSelectedConsumable usingGrenade id", CurGrenadeID)
        end
        if CurGrenadeID and CircleChooseUtil.IsAMedicine(CurGrenadeID) then
          WeaponMgr:LocalDestroyWeapon("GrenadeSlot", true)
        end
      end
    end
  end
  self:SortGrenadesAndMelees()
  self:SetGrenadeOrder()
  self:UpdateGrenadePanel()
  local GrenadesPanel = UIManager.GetUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
  if GrenadesPanel then
    GrenadesPanel:UpdateMedSlot(ItemID)
    if slua.isValid(WeaponMgr) then
      local curWeaponSlot = WeaponMgr:GetCurrentUsingPropSlot()
      if ESurviveWeaponPropSlot.SWPS_HandProp == curWeaponSlot and self.IsChoosingMedicine then
        GrenadesPanel:HandleCenterChosen(false)
      end
    end
  end
end
function CircleChooseWidgetLogic:SetGrenadeOrder()
  if CircleChooseUtil.IsChoosingThemeProp() then
    return
  end
  local nFirstGrenadeID = 0
  if self.bUsingIgnoreThrowable then
    nFirstGrenadeID = self.PreUsingGrenadeID
  elseif 0 < #self.FinalGrenadesList then
    local ItemData = self.FinalGrenadesList[1]
    local ID = ItemData.DefineID.TypeSpecificID
    if not CircleChooseUtil.SimMelee(ID) then
      nFirstGrenade    end
  end
  local playerController = GameplayData.GetPlayerController()
  if not slua.isValid(playerController) then
    return
  end
  if bWriteLog then
    print("CircleChooseWidgetLogic:ServerTriggerSelectGrenade ForceUpdateList", self.IsChoosingMedicine, nFirstGrenadeID, self.LastMedicineThrown)
  end
  if 0 < nFirstGrenadeID then
    if self.LastMedicineThrown then
      playerController:ServerTriggerSelectGrenade(-1)
      self.LastMedicineThrown = false
    else
      playerController:ServerTriggerSelectGrenade(nFirstGrenadeID)
    end
  else
    playerController:ServerTriggerSelectGrenade(-1)
  end
end
function CircleChooseWidgetLogic:HandleHPChange(CurHP)
  if self:IsInSortCD() or not self.bIntelligentSort then
    return
  end
  if self.HandleHPChangeTimer then
    self:RemoveGameTimer(self.HandleHPChangeTimer)
    self.HandleHPChangeTimer = nil
  end
  self.HandleHPChangeTimer = self:AddGameTimer(0.1, false, function()
    self.HandleHPChangeTimer = nil
    local NewSortingMode = self:GetSortingMode()
    if NewSortingMode ~= self.SortingMode then
      self:SetSortingMode(NewSortingMode)
      self.CachedHP = CurHP
      self:SortConsumables(true, false)
      if self.bEnableThrowMeds then
        self:UpdateCurrentMedicine()
        self:UpdateGrenadePanel()
      end
      self:UpdateCurMed()
      self:UpdateMedicinePanel()
    end
  end)
end
function CircleChooseWidgetLogic:SortGrenadesAndMelees()
  self:AddSortedGrenades()
  self:UpdateCurrentMedicine()
end
function CircleChooseWidgetLogic:AddSortedGrenades()
  TableUtil_ClearArray(self.FinalGrenadesList)
  local CurrentSelectedGrenadeBattleItemData = self.GrenadesAndMelees[self.CurrentSelectedGrenadeIDData.InstanceID]
  if not slua.isValid(CurrentSelectedGrenadeBattleItemData) then
    print(bWriteLog and "CircleChooseWidgetLogic:AddSortedGrenades CurrentSelectedGrenadeBattleItemData is nil")
  end
  local CurrentSelectedGrenadeIDData = self.CurrentSelectedGrenadeIDData
  for Index, Value in ipairs(self.SortedGrenadesList) do
    local BattleItemData = self.GrenadesAndMelees[Value]
    if slua.isValid(BattleItemData) then
      if CurrentSelectedGrenadeBattleItemData and Value == CurrentSelectedGrenadeIDData.InstanceID or not CurrentSelectedGrenadeBattleItemData and BattleItemData.DefineID.TypeSpecificID == CurrentSelectedGrenadeIDData.TypeSpecificID then
        table_insert(self.FinalGrenadesList, 1, BattleItemData)
      else
        table_insert(self.FinalGrenadesList, BattleItemData)
      end
    elseif bWriteLog then
      print("CircleChooseWidgetLogic:AddSortedGrenades BattleItemData is nil, ", Value)
    end
  end
end
function CircleChooseWidgetLogic:UpdateCurrentMedicine()
  local GrenadeCnt = #self.SortedGrenadesList
  local CurMedThrow = self.CurrentSelectedConsumableBattleItem
  if not self.bEnableThrowMeds then
    CurMedThrow = nil
  end
  if CurMedThrow then
    local bThrowable = self.CircleChooseCfg.ThrowableMedicineIDMap[CurMedThrow.DefineID.TypeSpecificID]
    if not bThrowable then
      CurMedThrow = nil
    end
  end
  if CurMedThrow then
    if GrenadeCnt == 0 then
      self:SetIsChoosingMedicine(true)
    elseif self.LastGrenadeCnt == 0 then
      self:SetIsChoosingMedicine(false)
    end
    if bWriteLog then
      print(bWriteLog and "CircleChooseWidgetLogic:UpdateCurrentMedicine last", self.LastGrenadeCnt, GrenadeCnt, self.IsChoosingMedicine)
    end
    if CurMedThrow.DefineID.TypeSpecificID == 0 or CurMedThrow.Count == 0 then
      self:RefreshCurrentSelectedConsumable(0, 0, false)
    else
      self:AddMedicineToGrenadeList(CurMedThrow, self.IsChoosingMedicine)
    end
  end
  self.Lastend
function CircleChooseWidgetLogic:AddMedicineToGrenadeList(Item, bIsFirstMed)
  self:AddSortedGrenades()
  local InsertIndex = 1
  if not bIsFirstMed and 1 <= #self.FinalGrenadesList then
    InsertIndex = 2
  end
  local BattleItemData = self.Consumables[Item.DefineID.InstanceID]
  if slua.isValid(BattleItemData) then
    table_insert(self.FinalGrenadesList, InsertIndex, BattleItemData)
  elseif bWriteLog then
    print("CircleChooseWidgetLogic:AddMedicineToGrenadeList BattleItemData is nil, ", Item.DefineID.InstanceID, Item.DefineID.TypeSpecificID)
  end
end
function CircleChooseWidgetLogic:SortConsumables(bForce, bManual)
  TableUtil_ClearArray(self.FinalConsumables)
  local CurrentSelectedConsumableInstanceID = -1
  local CurrentSelectedConsumableTypeSpecificID = -1
  if self.CurrentSelectedConsumableBattleItem then
    CurrentSelectedConsumableInstanceID = self.CurrentSelectedConsumableBattleItem.DefineID.InstanceID
    CurrentSelectedConsumableTypeSpecificID = self.CurrentSelectedConsumableBattleItem.DefineID.TypeSpecificID
  end
  local bIgnoreFirst = self:ShouldIgnoreFirst(bForce, bManual)
  if bIgnoreFirst then
    local TopPriItem = self:GetSortedConsumablesListTop()
    if TopPriItem then
      CurrentSelectedConsumableInstanceID = TopPriItem.InstanceID
      local CurrentSelectedConsumableBattleItemData = self.Consumables[CurrentSelectedConsumableInstanceID]
      if CurrentSelectedConsumableBattleItemData then
        CurrentSelectedConsumableTypeSpecificID = CurrentSelectedConsumableBattleItemData.DefineID.TypeSpecificID
      end
    end
  end
  if 0 < CurrentSelectedConsumableInstanceID and not self.Consumables[CurrentSelectedConsumableInstanceID] then
    CurrentSelectedConsumableInstanceID = -1
  end
  for Key, Value in pairs(self.Consumables) do
    local DefineID = Value.DefineID
    if 0 < CurrentSelectedConsumableInstanceID and DefineID.InstanceID == CurrentSelectedConsumableInstanceID or CurrentSelectedConsumableInstanceID < 0 and DefineID.TypeSpecificID == CurrentSelectedConsumableTypeSpecificID then
      table_insert(self.FinalConsumables, 1, Value)
    else
      table_insert(self.FinalConsumables, Value)
    end
  end
end
function CircleChooseWidgetLogic:GetSortedConsumablesListTop()
  if bUseBackpackProxy then
    return self:GetSortedConsumablesListTop_New()
  else
    return self:GetSortedConsumablesListTop_Old()
  end
end
function CircleChooseWidgetLogic:GetSortedConsumablesListTop_New()
  local BackpackConsumableProxy = CircleChooseUtil.GetBackpackConsumableProxy()
  if not BackpackConsumableProxy or not BackpackConsumableProxy.GetSortedConsumablesTop then
    return
  end
  return BackpackConsumableProxy:GetSortedConsumablesTop()
end
function CircleChooseWidgetLogic:GetSortedConsumablesListTop_Old()
  return self.SortedConsumablesList:Top()
end
function CircleChooseWidgetLogic:ShouldIgnoreFirst(bForce, bManual)
  if bManual then
    return false
  end
  if self.bIntelligentSort and (self.CachedHP < self.MaxHP or bForce) then
    return true
  end
  return false
end
function CircleChooseWidgetLogic:SetFirstMed(BattleItem)
  self.LastSortTime = self:GetCurTime()
  self.CurrentSelectedConsumable  self:SortConsumables(false, true)
  if self.bEnableThrowMeds then
    self:UpdateCurrentMedicine()
    self:UpdateGrenadePanel()
  end
  self:UpdateCurMed()
  self:UpdateMedicinePanel()
  self:UpdateCurrentSelectedConsumableItemID()
end
function CircleChooseWidgetLogic:SetFirstGrenade(BattleItem)
  local ItemDefineID = slua.IndexReference(BattleItem, "DefineID")
  print(bWriteLog and "CircleChooseWidgetLogic:SetFirstGrenade:" .. ItemDefineID.InstanceID .. ", " .. ItemDefineID.TypeSpecificID)
  self.CurrentSelectedGrenadeIDData.InstanceID, self.CurrentSelectedGrenadeIDData.TypeSpecificID = ItemDefineID.InstanceID, ItemDefineID.TypeSpecificID
  self:SortGrenadesAndMelees()
  self:SetGrenadeOrder()
  self:UpdateGrenadePanel()
end
function CircleChooseWidgetLogic:ResetItemPriority(tData)
  local tNewData = {}
  for key, value in pairs(tData) do
    local NewValue = self:GetPriorityBySortModeNew(value)
    table_insert(tNewData, NewValue)
  end
  return tNewData
end
local InstanceIDStartOccupiedValue = 0
local InstanceIDOccupiedValue = 25
local ItemIDStartOccupiedValue = InstanceIDStartOccupiedValue + InstanceIDOccupiedValue
local ItemIDOccupiedValue = 32
local ConfigStartOccupiedValue = ItemIDStartOccupiedValue + ItemIDOccupiedValue
local ConfigOccupiedValue = 6
function CircleChooseWidgetLogic:GetPriority(ItemDefineID)
  local Priority = ConfigOccupiedValue
  local PriorityMap = self.CircleChooseCfg.SortingModePriorityIDList[self.SortingMode]
  if PriorityMap then
    Priority = PriorityMap[ItemDefineID.TypeSpecificID]
    if not Priority and self.CircleChooseCfg.CommonGrenadePriorityDic then
      Priority = self.CircleChooseCfg.CommonGrenadePriorityDic[ItemDefineID.TypeSpecificID]
      if not Priority and self.CircleChooseCfg.MeleeWeaponPriority and CircleChooseUtil.SimMelee(ItemDefineID.TypeSpecificID) then
        Priority = self.CircleChooseCfg.MeleeWeaponPriority
      end
    end
  end
  Priority = Priority or (1 << ConfigOccupiedValue) - 1
  Priority = Priority << ConfigStartOccupiedValue
  Priority = Priority + (ItemDefineID.TypeSpecificID << ItemIDStartOccupiedValue)
  return Priority
end
function CircleChooseWidgetLogic:PriorityToInstanceID(Priority)
  return Priority >> InstanceIDStartOccupiedValue & (1 << InstanceIDOccupiedValue) - 1
end
function CircleChooseWidgetLogic:UpdateGrenadePanel()
  local bShow = false
  local bListShow = false
  if #self.FinalGrenadesList > 0 then
    bShow = true
  end
  if #self.FinalGrenadesList > 1 then
    bListShow = true
  end
  local GrenadesPanel = UIManager.GetUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
  if GrenadesPanel then
    GrenadesPanel:Update(bShow)
    GrenadesPanel:UpdateListBox(bListShow, self.FinalGrenadesList, true)
    return
  end
  if bShow then
    local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
    if ShootingUIPanel and ShootingUIPanel.ConsumableSocket and UIManager.UI_Config_InGame.GrenadeChooseWidgetNew then
      local NewGrenadesPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
      if NewGrenadesPanel then
        NewGrenadesPanel:AttachToPanel(ShootingUIPanel.RingThrowSocket)
        NewGrenadesPanel.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
        NewGrenadesPanel.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
        if bListShow then
          NewGrenadesPanel:UpdateListBox(bListShow, self.FinalGrenadesList, true)
        end
      end
    end
  end
end
function CircleChooseWidgetLogic:UpdateMedicinePanel()
  local SuperData = self:GetSuperData()
  if SuperData.bMedicineItemChange == nil then
    SuperData.bMedicineItemChange = false
    return
  end
  SuperData.bMedicineItemChange = not SuperData.bMedicineItemChange
end
function CircleChooseWidgetLogic:RefreshIntelligentSort(bIntelligentSort)
  self.  if bIntelligentSort then
    self:SetSortingMode(self:GetSortingMode())
  else
    self:SetSortingMode(self.CircleChooseCfg.EConsumableSortMode.NormalMode)
  end
  self:SortConsumables(true, false)
  if self.bEnableThrowMeds then
    self:UpdateCurrentMedicine()
    self:UpdateGrenadePanel()
  end
  self:UpdateCurMed()
  self:UpdateMedicinePanel()
end
function CircleChooseWidgetLogic:SetSortingMode(NewMode)
  if bUseBackpackProxy then
    self:SetSortingMode_New(NewMode)
  else
    self:SetSortingMode_Old(NewMode)
  end
end
function CircleChooseWidgetLogic:SetSortingMode_New(NewMode)
  local BackpackConsumableProxy = CircleChooseUtil.GetBackpackConsumableProxy()
  if not BackpackConsumableProxy or not BackpackConsumableProxy.RegenerateAllConsumablesPriority then
    return
  end
  self.SortingMode = NewMode
  pcall(function()
    BackpackConsumableProxy:RegenerateAllConsumablesPriority()
  end)
end
function CircleChooseWidgetLogic:SetSortingMode_Old(NewMode)
  self.SortingMode = NewMode
  self.SortedConsumablesList:Clear()
  for InstanceID, BattleItem in pairs(self.Consumables) do
    local IDWithPriority = {
      InstanceID = InstanceID,
      Priority = self:GetPriority(BattleItem.DefineID)
    }
    self.SortedConsumablesList:Push(IDWithPriority)
  end
end
function CircleChooseWidgetLogic:GetSortingMode()
  local EConsumableSortMode = self.CircleChooseCfg.EConsumableSortMode
  local SortingMode = EConsumableSortMode.FullHealth
  local uPlayerState = self.CachedPlayerState
  if slua.isValid(uPlayerState) and uPlayerState.GetPlayerHealth then
    local CurHealth = uPlayerState:GetPlayerHealth()
    local Threshold = 100
    if self.MaxHP ~= 0 then
      Threshold = CurHealth / self.MaxHP * 100
    end
    if Threshold == 100 then
      SortingMode = EConsumableSortMode.FullHealth
    elseif 75 <= Threshold and Threshold < 100 then
      SortingMode = EConsumableSortMode.LittleBitWound
    elseif 50 <= Threshold and Threshold < 75 then
      SortingMode = EConsumableSortMode.PlentyWound
    elseif 25 <= Threshold and Threshold < 50 then
      SortingMode = EConsumableSortMode.SeriousWound
    elseif 0 <= Threshold and Threshold < 25 then
      SortingMode = EConsumableSortMode.AlmostDie
    end
  end
  return SortingMode
end
function CircleChooseWidgetLogic:GetCurTime()
  local CurTime = 0.0
  local uGameState = self.CachedGameState
  if slua.isValid(uGameState) then
    CurTime = uGameState:GetServerWorldTimeSeconds()
  end
  return CurTime
end
function CircleChooseWidgetLogic:IsInSortCD()
  local CurTime = self:GetCurTime()
  if CurTime then
    local DeltaTime = CurTime - self.LastSortTime
    if DeltaTime < self.SortCD then
      return true
    end
  end
  return false
end
function CircleChooseWidgetLogic:DebugPrintDataList(DataDic)
  print(bWriteLog and "CircleChooseWidgetLogic:DebugPrintDataList() COUNT=", #DataDic)
  for key, value in pairs(DataDic) do
    print(bWriteLog and "CircleChooseWidgetLogic: DebugPrintDataList==: ", key, value, value.Count)
  end
end
function CircleChooseWidgetLogic:DebugPrintGrenadesAndMelees()
  print(bWriteLog and "CircleChooseWidgetLogic:DebugPrintGrenadesAndMelees() COUNT=", #self.GrenadesAndMelees)
  for key, value in pairs(self.GrenadesAndMelees) do
    print(bWriteLog and "CircleChooseWidgetLogic: DebugPrintGrenadesAndMelees+: ", key, value.Count)
  end
end
function CircleChooseWidgetLogic:DebugPrintConsumables()
  print(bWriteLog and "CircleChooseWidgetLogic:DebugPrintConsumables() COUNT=", #self.Consumables)
  for key, value in pairs(self.Consumables) do
    print(bWriteLog and "CircleChooseWidgetLogic: DebugPrintConsumables+: ", key, value.Count)
  end
end
function CircleChooseWidgetLogic:CheckCountsInRange(BattleItem)
  if BattleItem.Count >= 1 and BattleItem.Count <= 200 then
    return true
  else
    return false
  end
end
function CircleChooseWidgetLogic:CachePC()
  self.CachedPlayerState = GameplayData.GetPlayerState()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    self.PlayerCharacter = uPlayerCharacter
    local uBackpackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uPlayerCharacter)
    if slua.isValid(uBackpackComp) then
      self.BackpackComp = uBackpackComp
    end
  end
end
function CircleChooseWidgetLogic:GetWeaponMgr()
  if slua.isValid(self.WeaponMgr) then
    return self.WeaponMgr
  else
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local uWeaponMgr = uPlayerCharacter:GetWeaponManager()
      if slua.isValid(uWeaponMgr) then
        self.WeaponMgr = uWeaponMgr
        return uWeaponMgr
      end
    end
  end
  print(bWriteLog and "CircleChooseWidgetLogic: Error Get WeaponMgr")
end
function CircleChooseWidgetLogic:GetGrenadeIDByWeapon()
  print(bWriteLog and "CircleChooseWidgetLogic:GetGrenadeIDByWeapon")
  local uWeaponMgr = self:GetWeaponMgr()
  if slua.isValid(uWeaponMgr) then
    local uCurrentWeapon = uWeaponMgr:GetCurrentUsingWeapon()
    if slua.isValid(uCurrentWeapon) then
      local ItemDefineID = uCurrentWeapon:GetItemDefineID()
      local TypeSpecificID = ItemDefineID.TypeSpecificID
      if not CircleChooseUtil.IsAThemeProp(TypeSpecificID) and (CircleChooseUtil.IsAMelee(TypeSpecificID) or CircleChooseUtil.IsAGrenade(TypeSpecificID) or CircleChooseUtil.IsAMedicine(TypeSpecificID)) then
        return ItemDefineID.InstanceID, TypeSpecificID
      end
    end
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local CurrentVehicle = PlayerCharacter:GetCurrentVehicle()
    if slua.isValid(CurrentVehicle) and CurrentVehicle.GetItemInstacneID then
      return CurrentVehicle:GetItemInstacneID(), 0
    end
  end
  if 0 >= #self.FinalGrenadesList then
    return 0, 0
  end
  local ItemDefineID = self.FinalGrenadesList[1].DefineID
  if #self.FinalGrenadesList == 1 and ItemDefineID.TypeSpecificID == 602420 then
    return 0, 0
  end
  return ItemDefineID.InstanceID, ItemDefineID.TypeSpecificID
end
function CircleChooseWidgetLogic:GetPathFromCachedMap(ItemID, bIsMedThrow)
  local AvatarPath
  if bIsMedThrow then
    AvatarPath = self.MedThrowPathByID[ItemID]
  else
    AvatarPath = self.AvatarPathByID[ItemID]
  end
  if AvatarPath and AvatarPath ~= "" then
    return AvatarPath
  else
    return self:CacheAvatarPathMap(ItemID, bIsMedThrow)
  end
end
function CircleChooseWidgetLogic:CacheAvatarPathMap(ItemID, bIsMedThrow)
  if CGameState and slua.isValid(CGameState) and CGameState.IsEnableRedirectItemIdToAvatarID and CGameState:IsEnableRedirectItemIdToAvatarID() then
    local RedirectAvatarID = CGameState:GetRedirectAvatarID(ItemID)
    if 0 ~= RedirectAvatarID then
      print(bWriteLog and "CircleChooseWidgetLogic:CacheAvatarPathMap RedirectItemID=", RedirectAvatarID)
      ItemID = RedirectAvatarID
    end
  end
  local AvatarPath = CircleChooseUtil.GetAvatarPath(ItemID, bIsMedThrow, self.bWithSkin)
  if bIsMedThrow then
    self.MedThrowPathByID[ItemID] = AvatarPath
  elseif ItemID < 602001 or 602004 < ItemID then
    self.AvatarPathByID[ItemID] = AvatarPath
  end
  return AvatarPath
end
function CircleChooseWidgetLogic:SetIsChoosingMedicine(IsChoosingMedicine)
  self.end
function CircleChooseWidgetLogic:UpdateCurrentSelectedConsumableItemID()
  local SuperData = self:GetSuperData()
  if not self.CurrentSelectedConsumableBattleItem then
    SuperData.CurrentSelectedConsumableItemID = 0
  else
    SuperData.CurrentSelectedConsumableItemID = self.CurrentSelectedConsumableBattleItem.DefineID.TypeSpecificID
  end
end
function CircleChooseWidgetLogic:GetFinalConsumables()
  return self.FinalConsumables
end
local class = require("class")
local CDelegateContainer = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CDelegateContainer, nil, CircleChooseWidgetLogic)