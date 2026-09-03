local ProduceDropItemComponent = {}
local CalcDropItemListHook
function ProduceDropItemComponent:ctor()
  self.TriggerCriticalDrop = false
  self.CharacterOwner = nil
  self.InstanceIDTemp = 100
end
function ProduceDropItemComponent:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "TriggerCriticalDrop",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
end
function ProduceDropItemComponent:ReceiveBeginPlay()
  if self.bCheckCriticalDrop then
    self:AddControlEvent(self, "OnFinalEffectiveDropRulesGenerated", self.OnEffectiveDropRulesGenerated, self)
  end
end
function ProduceDropItemComponent:SetCharacterOwner(CharacterOwner)
  self.end
function ProduceDropItemComponent:OnEffectiveDropRulesGenerated(EffectiveDropRules)
  printf("ProduceDropItemComponent:OnEffectiveDropRulesGenerated %d", EffectiveDropRules:Num())
  if self:CheckHasCriticalDrop(EffectiveDropRules) then
    printf("ProduceDropItemComponent:OnEffectiveDropRulesGenerated self.TriggerCriticalDrop = true")
    self.TriggerCriticalDrop = true
  end
end
function ProduceDropItemComponent:CheckHasCriticalDrop(EffectiveDropRules)
  if EffectiveDropRules:Num() <= 1 then
    return false
  end
  printf("ProduceDropItemComponent:CheckCriticalDrop EffectiveDropRules:Num() = %d, CriticalDropCheckPercent = %d", EffectiveDropRules:Num(), self.CriticalDropCheckPercent)
  local CriticalDropCheckPercent = FuncUtil.Clamp(self.CriticalDropCheckPercent, 0, 100)
  for _, rule in pairs(EffectiveDropRules) do
    printf("ProduceDropItemComponent:CheckCriticalDrop ItemDropRuleID = %d, ItemDropPercent = %d", rule.ItemDropRuleID, rule.ItemDropPercent)
    if CriticalDropCheckPercent >= rule.ItemDropPercent then
      return true
    end
  end
  return false
end
function ProduceDropItemComponent:OnRep_TriggerCriticalDrop()
  printf("ProduceDropItemComponent:OnRep_TriggerCriticalDrop %s", self.TriggerCriticalDrop)
  if not self.TriggerCriticalDrop then
    return
  end
  local Owner = self:GetOwner()
  printf("ProduceDropItemComponent:OnRep_TriggerCriticalDrop 2 %s", Owner)
  if not slua.isValid(Owner) or not Owner.GetAkComponent then
    return
  end
  local AkComponent = Owner:GetAkComponent()
  if not slua.isValid(AkComponent) then
    return
  end
  AkComponent:PostAkEvent(self.CriticalDropAudioEvent, "")
end
function ProduceDropItemComponent:StartSimpleDrop(KillerController, ScaleTimes)
  local FDropPropData = import("DropPropData")
  local StructArray = slua.Array(UEnums.EPropertyClass.Struct, FDropPropData)
  local Owner = self:GetOwner()
  if slua.isValid(Owner) and KillerController and slua.isValid(KillerController) then
    if Owner.bMobSuicide == true then
      local EMonsterSpawnSourceType = import("EMonsterSpawnSourceType")
      if Owner.GetSourceType and Owner:GetSourceType() == EMonsterSpawnSourceType.MonsterSpawnAction then
        return
      end
    end
    if KillerController.GetPlayerCharacterSafety then
      local KillPawn = KillerController:GetPlayerCharacterSafety()
      if KillPawn and slua.isValid(KillPawn) then
        self:GenerateBulletDropItem(StructArray, Owner, KillPawn)
      end
    end
  end
  local _, DropDataList = self:GenerateDropItemByCfg(StructArray)
  if ScaleTimes and 1 < ScaleTimes then
    for i = 1, ScaleTimes - 1 do
      self:GenerateDropItemByCfg(DropDataList)
    end
  end
  if DropDataList == nil or DropDataList:Num() <= 0 then
    printf("ProduceDropItemComponent:StartDrop DropDataList is not valid, return")
    return
  end
  printf("ProduceDropItemComponent:StartDrop ProduceID = %d", self.ProduceID)
  self:StartDropWithDropData(Owner, KillerController, DropDataList)
end
function ProduceDropItemComponent:HandleReplaceProduceID()
  if self.CharacterOwner and slua.isValid(self.CharacterOwner) then
    local uPlayerController = self.CharacterOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) and uPlayerController.ChangeProduceID then
      print(bWriteLog and "ProduceDropItemComponent:HandleReplaceProduceID Before, ProduceID = " .. tostring(self.ProduceID))
      self.ProduceID = uPlayerController:ChangeProduceID(self.ProduceID)
      print(bWriteLog and "ProduceDropItemComponent:HandleReplaceProduceID After, ProduceID = " .. tostring(self.ProduceID))
    end
  end
end
function ProduceDropItemComponent:GetDropItemCfgList(DropCfgList)
  self:HandleReplaceProduceID()
  local BoxName, DropCfgList = self.Super:GetDropItemCfgList(DropCfgList)
  if DropCfgList:Num() > 0 and self.CharacterOwner and slua.isValid(self.CharacterOwner) then
    local uPlayerController = self.CharacterOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) and uPlayerController.CheckNeedChangeDropPercent and uPlayerController:CheckNeedChangeDropPercent() then
      local NeedChangeDropCfgItem
      local CurrentMinPercent = 100
      local NeedChangeDropCfgItemIndex = 0
      for CurrentIndex, DropCfgItem in pairs(DropCfgList) do
        print(bWriteLog and "ProduceDropItemComponent:GetDropItemCfgList DropCfgItem:", DropCfgItem.ItemDropPercent, DropCfgItem.ItemDropRuleID, DropCfgItem.RandomCount)
        local DropInfo = CDataTable.GetTableData("AffixDropTable", DropCfgItem.ItemDropRuleID)
        if 0 < DropCfgItem.ItemDropPercent and DropInfo == nil and CurrentMinPercent > DropCfgItem.ItemDropPercent then
          NeedChange          CurrentMinPercent = DropCfgItem.ItemDropPercent
          NeedChangeDropCfgItemIndex = CurrentIndex
        end
      end
      if NeedChangeDropCfgItem then
        NeedChangeDropCfgItem.ItemDropPercent = 100
        DropCfgList:Set(NeedChangeDropCfgItemIndex, NeedChangeDropCfgItem)
        print(bWriteLog and "ProduceDropItemComponent:GetDropItemCfgList NeedChangeDropCfgItem:", NeedChangeDropCfgItem.ItemDropPercent, NeedChangeDropCfgItem.ItemDropRuleID, NeedChangeDropCfgItemIndex)
      end
    end
  end
  return BoxName, DropCfgList
end
function ProduceDropItemComponent:CalcDropItemListByDropRuleByCfg(DropItemConfig, DropItemList, FinalEffectiveDropRules)
  local ProduceID = self.ProduceID
  if 0 < ProduceID and CalcDropItemListHook then
    DropItemList = CalcDropItemListHook(ProduceID, DropItemConfig, DropItemList, FinalEffectiveDropRules)
  end
  self.Super:CalcDropItemListByDropRuleByCfg(DropItemConfig, DropItemList, FinalEffectiveDropRules)
  return DropItemList, FinalEffectiveDropRules
end
local ProduceDropItemComponentStatic = {}
function ProduceDropItemComponentStatic.SetCalcDropItemListHook(HookFunc)
  CalcDropItemListHook = HookFunc
end
function ProduceDropItemComponent:StartSimpleDropByBox(Loc, bNotTraceGround)
  local FDropPropData = import("DropPropData")
  local uDropDataStruct = slua.Array(UEnums.EPropertyClass.Struct, FDropPropData)
  local boxName, resultArray = self:GenerateDropItemByCfg(uDropDataStruct)
  local MyOwner = self:GetOwner()
  if resultArray == nil or resultArray:Num() <= 0 or not slua.isValid(MyOwner) then
    print(bWriteLog and "ProduceDropItemComponent:StartSimpleDropByBox, resultArray = " .. tostring(resultArray))
    return
  end
  local FirstItem = resultArray:Get(0)
  if FirstItem == nil then
    print(bWriteLog and "ProduceDropItemComponent:StartSimpleDropByBox, FirstItem = nil")
    return
  end
  local Count = resultArray:Num()
  local DropMode = FirstItem.DropMode
  if DropMode == 2 then
    local EPickUpBoxType = import("EPickUpBoxType")
    self.PlayerTombBoxResult = self:DropToTreasureBox(resultArray, MyOwner, boxName, EPickUpBoxType.EPickUpBoxType_TreasureBox, FVector(0, 0, 0), true, false)
    print(bWriteLog and "ProduceDropItemComponent:StartSimpleDropByBox, boxName = " .. tostring(boxName) .. ", num = " .. tostring(Count))
  else
    print(bWriteLog and "ProduceDropItemComponent:StartSimpleDropByBox, num = " .. tostring(Count))
    if Loc ~= nil then
      self:StartDropWithDropDataByLocation(resultArray, Loc, not bNotTraceGround)
    else
      self:StartDropWithDropData(MyOwner, nil, resultArray)
    end
  end
  MyOwner:ForceNetUpdate()
  return resultArray
end
function ProduceDropItemComponent:DropToExistBox(Producer, BoxTrans, BoxName, BoxType, TombBox)
  if not slua.isValid(TombBox) then
    return
  end
  local PickupListWrapper = TombBox.PickupListWrapper
  local uItemDropMgr = CGameMode.BP_ItemDropMgr
  if Game:IsValid(uItemDropMgr) then
    local uItemList = uItemDropMgr:GeneratePickupListByDropID(self.ProduceID)
    if slua.isValid(PickupListWrapper) then
      local CurrentPickupList = PickupListWrapper:GetPickUpDataList()
      local MergeList = self:MergeTwoPickUpDataList(CurrentPickupList, uItemList)
      if MergeList then
        PickupListWrapper:SetPickUpDataList(MergeList)
        PickupListWrapper:RPC_Broadcast_ForceSyncAllData(MergeList)
      end
    else
      self:DropToCommonLootBox(Producer, BoxTrans, BoxName, BoxType, TombBox)
    end
  end
end
function ProduceDropItemComponent:MergeTwoPickUpDataList(ToList, FromList)
  if not ToList or not FromList then
    return nil
  end
  local BackpackUtils = import("BackpackUtils")
  for i = 0, FromList:Num() - 1 do
    local FromItem = FromList:Get(i)
    local bAdded = false
    for key, ToItem in pairs(ToList) do
      if BackpackUtils.IsSameItem(FromItem.ID, ToItem.ID) then
        local ItemData = CDataTable.GetTableData("Item", ToItem.ID.TypeSpecificID)
        local MergeCount = ToItem.Count + FromItem.Count
        if MergeCount <= ItemData.MaxCount then
          ToItem.Count = MergeCount
          bAdded = true
          ToList:Set(key, ToItem)
          break
        end
      end
    end
    if not bAdded then
      self.InstanceIDTemp = self.InstanceIDTemp + 1
      FromItem.InstanceID = self.InstanceIDTemp
      ToList:Add(FromItem)
    end
  end
  return ToList
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CProduceDropItemComponent = class(CActorComponentBase, ProduceDropItemComponentStatic, ProduceDropItemComponent)
return CProduceDropItemComponent