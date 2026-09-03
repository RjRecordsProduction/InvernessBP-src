local WeaponUtils = {}
local ULagCompensationSubSystem = import("LagCompensationSubSystem")
local USubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local EWeaponReuseCfgType = import("EWeaponReuseCfgType")
local UAvatarUtils = import("AvatarUtils")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local X4SightMatNames = {
  M_MZJ_4X_Sight = -1,
  M_MZJ_4X_Sight_2 = 0,
  M_MZJ_4X_Sight_3 = 2,
  M_MZJ_4X_Sight_4 = 1
}
local X4SightMatPaths = {
  [X4SightMatNames.M_MZJ_4X_Sight_2] = "/Game/Arts_Player/Weapon/Accessories/MZJ/MZJ_4X/Mat/M_MZJ_4X_Sight_2.M_MZJ_4X_Sight_2",
  [X4SightMatNames.M_MZJ_4X_Sight_3] = "/Game/Arts_Player/Weapon/Accessories/MZJ/MZJ_4X/Mat/M_MZJ_4X_Sight_3.M_MZJ_4X_Sight_3",
  [X4SightMatNames.M_MZJ_4X_Sight_4] = "/Game/Arts_Player/Weapon/Accessories/MZJ/MZJ_4X/Mat/M_MZJ_4X_Sight_4.M_MZJ_4X_Sight_4"
}
function WeaponUtils:IsWeaponFilledWithAccessory(uWeapon)
  local ASTExtraShootWeapon = import("STExtraShootWeapon")
  if slua.isValid(uWeapon) and Game:IsClassOf(uWeapon, ASTExtraShootWeapon) then
    local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
    local IgnoreAccessoryTable = {
      EWeaponAttachmentSocketType.ACCore
    }
    local EGameModeSubCPPType = import("EGameModeSubType")
    local IsSinkGameMode = CGameState and CGameState.GameModeSubType == EGameModeSubCPPType.ESinkGameMode
    if IsSinkGameMode then
      table.insert(IgnoreAccessoryTable, EWeaponAttachmentSocketType.AngledOpticalSight)
    end
    local UWeaponUtils = import("WeaponUtils")
    local BlankSocketArray = UWeaponUtils.GetBlankAttachmentSockets(uWeapon)
    local BlankSocketArrayCount = BlankSocketArray:Num()
    local TableUtil = require("common.table_util")
    for index = 0, BlankSocketArrayCount - 1 do
      local BlankSocket = BlankSocketArray:Get(index)
      if TableUtil.Find(IgnoreAccessoryTable, BlankSocket) == -1 then
        print(bWriteLog and "WeaponUtils:IsWeaponFilledWithAccessory = " .. tostring(uWeapon:GetWeaponID()) .. ", BlankSocket = " .. tostring(BlankSocketArrayCount))
        return false
      end
    end
    return true
  else
    return false
  end
end
function WeaponUtils:IsFilledWithAccessory(PlayerKey, Both)
  local FilledWithAccessory = false
  local uPlayerCharacter = Game:GetPlayerByPlayerKey(PlayerKey)
  if uPlayerCharacter == nil or slua.isValid(uPlayerCharacter) == false then
    return FilledWithAccessory
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  if uWeaponManager and slua.isValid(uWeaponManager) then
    local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
    local Temp = {
      ESurviveWeaponPropSlot.SWPS_MainShootWeapon1,
      ESurviveWeaponPropSlot.SWPS_MainShootWeapon2
    }
    local FullCount = 0
    for _, i in pairs(Temp) do
      local uWeapon = uWeaponManager:GetInventoryWeaponByPropSlot(i)
      if uWeapon and slua.isValid(uWeapon) then
        local ItemID = uWeapon:GetWeaponID()
        if ItemID and 0 < ItemID then
          if self:IsWeaponFilledWithAccessory(uWeapon) then
            FullCount = FullCount + 1
          end
          if Both == true then
            if FullCount >= #Temp then
              FilledWithAccessory = true
              break
            end
          elseif 0 < FullCount then
            FilledWithAccessory = true
            break
          end
        end
      end
    end
  end
  print(bWriteLog and "WeaponUtils:IsFilledWithAccessory, PlayerKey = " .. tostring(PlayerKey) .. ", Both = " .. tostring(Both) .. ", Filled = " .. tostring(FilledWithAccessory))
  return FilledWithAccessory
end
function WeaponUtils:GetFullAttachmentWeapons(PlayerKey, TargetSlots)
  local Ret = {}
  local uPlayerCharacter = Game:GetPlayerByPlayerKey(PlayerKey)
  local uWeaponManager = slua.isValid(uPlayerCharacter) and uPlayerCharacter:GetWeaponManager()
  if not slua.isValid(uWeaponManager) then
    print(bWriteLog and "WeaponUtils:GetFullAttachmentWeapons : WeaponManager Unvalid ")
    return Ret
  end
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local DefaultSlots = {
    ESurviveWeaponPropSlot.SWPS_MainShootWeapon1,
    ESurviveWeaponPropSlot.SWPS_MainShootWeapon2
  }
  TargetSlots = TargetSlots or DefaultSlots
  for _, TargetSlot in pairs(TargetSlots) do
    local uWeapon = uWeaponManager:GetInventoryWeaponByPropSlot(TargetSlot)
    if self:IsWeaponFilledWithAccessory(uWeapon) then
      table.insert(Ret, uWeapon:GetWeaponID())
      print(bWriteLog and "WeaponUtils:GetFullAttachmentWeapons  ", Ret[#Ret])
    end
  end
  return Ret
end
function WeaponUtils:AddAttrModifier(uWeapon, AttrModifyCfg)
  if not AttrModifyCfg or not next(AttrModifyCfg) then
    return
  end
  local uAttrModifierCompoment = slua.isValid(uWeapon) and uWeapon.AttrModifierCompoment
  if not slua.isValid(uAttrModifierCompoment) then
    return
  end
  local IsUGC = false
  if slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    IsUGC = true
  end
  local BModifyIdTable = {}
  for _, Cfg in pairs(AttrModifyCfg) do
    if bWriteLog then
      local beforeValue = uAttrModifierCompoment:GetAttributeValue(Cfg.AttrName)
      printf("WeaponUtils:AddAttrModifier %s before value = %s ", Cfg.AttrName, beforeValue)
    end
    local BModifyId = uAttrModifierCompoment:AddBModifyAndCacheWithCParam(Cfg.AttrName, Cfg.OP, Cfg.Value, false)
    table.insert(BModifyIdTable, BModifyId)
    Cfg.ModifyID = BModifyId
    if Cfg.AttrName == "MaxBulletNumInOneClip" and Cfg.OP == 2 then
      uWeapon.CurMaxBulletNumInOneClip = uWeapon.CurMaxBulletNumInOneClip + Cfg.Value
    elseif Cfg.AttrName == "MaxBulletNumInOneClip" and Cfg.OP == 1 then
      if IsUGC then
        uWeapon.CurMaxBulletNumInOneClip = math.floor(uAttrModifierCompoment:GetAttributeValue("MaxBulletNumInOneClip"))
        printf(bWriteLog and "WeaponUtils:AddAttrModifier uWeapon.CurMaxBulletNumInOneClip =  %s", uWeapon.CurMaxBulletNumInOneClip)
      else
        uWeapon.CurMaxBulletNumInOneClip = math.floor(uWeapon.CurMaxBulletNumInOneClip * (1 + Cfg.Value))
      end
    end
    if bWriteLog then
      local afterValue = uAttrModifierCompoment:GetAttributeValue(Cfg.AttrName)
      printf("WeaponUtils:AddAttrModifier %s after value = %s ", Cfg.AttrName, afterValue)
    end
  end
  print(bWriteLog and "WeaponUtils:AddAttrModifier: ", uWeapon, AttrModifyCfg)
  return BModifyIdTable
end
function WeaponUtils:DSAddAttrModifier(uWeapon, AttrModify)
  local uAttrModifierCompoment = slua.isValid(uWeapon) and uWeapon.AttrModifierCompoment
  if not (slua.isValid(uAttrModifierCompoment) and AttrModify) or not next(AttrModify) then
    print(bWriteLog and string.format("WeaponUtils:DSAddAttrModifier unvalid [%s]", tostring(uWeapon)))
    return
  end
  print(bWriteLog and string.format("WeaponUtils:DSAddAttrModifier [%s]", tostring(uWeapon)))
  local ModifyIdTable = {}
  for _, Cfg in pairs(AttrModify) do
    local BModifyId = uAttrModifierCompoment:AddBModifyAndCacheWithCParam(Cfg.AttrName, Cfg.OP, Cfg.Value, false)
    table.insert(ModifyIdTable, BModifyId)
    if Cfg.AttrName == "MaxBulletNumInOneClip" and Cfg.OP == 2 then
      uWeapon.CurMaxBulletNumInOneClip = uWeapon.CurMaxBulletNumInOneClip + Cfg.Value
    end
  end
  return ModifyIdTable
end
function WeaponUtils:DSRemoveAttrModifier(uWeapon, ModifyIdTable)
  local uAttrModifierCompoment = slua.isValid(uWeapon) and uWeapon.AttrModifierCompoment
  if not (slua.isValid(uAttrModifierCompoment) and ModifyIdTable) or not next(ModifyIdTable) then
    print(bWriteLog and string.format("WeaponUtils:DSRemoveUpgradeAttrModifier unvalid [%s]", tostring(uWeapon)))
    return
  end
  print(bWriteLog and string.format("WeaponUtils:DSRemoveUpgradeAttrModifier [%s]", tostring(uWeapon)))
  for _, ModifyId in pairs(ModifyIdTable) do
    uAttrModifierCompoment:RemoveModifyItemFromCache(ModifyId)
  end
end
function WeaponUtils:AddLocalEquipAttrModifierConfig(uWeapon, UnquieID, LocalAttrModify)
  if not (slua.isValid(uWeapon) and LocalAttrModify) or not next(LocalAttrModify) then
    print(bWriteLog and string.format("WeaponUtils:AddLocalEquipAttrModifierConfig unvalid [%s]", tostring(UnquieID)))
    return
  end
  print(bWriteLog and string.format("WeaponUtils:AddLocalEquipAttrModifierConfig [%s] [%s]", tostring(uWeapon), tostring(UnquieID)))
  local FWeaponAttrModifyData = import("WeaponAttrModifyData")
  local AttrModifyDataArray = slua.Array(UEnums.EPropertyClass.Struct, FWeaponAttrModifyData)
  for _, Cfg in pairs(LocalAttrModify) do
    local OpFix = Cfg.OP
    local ValueFix = Cfg.Value
    if OpFix == 0 then
    elseif OpFix == 1 then
      ValueFix = ValueFix + 1
    elseif OpFix == 2 then
      OpFix = 0
    elseif OpFix == 3 then
      OpFix = 2
    end
    local AttrModifyData = FWeaponAttrModifyData()
    AttrModifyData.ModifyAttr = Cfg.AttrName
    AttrModifyData.Op = OpFix
    AttrModifyData.ModifyValue = ValueFix
    AttrModifyDataArray:Add(AttrModifyData)
  end
  local EquipTag = "Equip"
  uWeapon:AddWeaponAttrModifierConfig(EquipTag, AttrModifyDataArray, UnquieID)
  local WeaponOwenr = uWeapon:GetOwnerPawn()
  local OwenrUseWeapon = slua.isValid(WeaponOwenr) and WeaponOwenr:GetCurrentWeapon()
  if OwenrUseWeapon == uWeapon then
    uWeapon:SetWeaponAttrModifierEnable(EquipTag, false, true)
    uWeapon:SetWeaponAttrModifierEnable(EquipTag, true, true)
  end
end
function WeaponUtils:RemoveLocalEquipAttrModifierConfig(uWeapon, UnquieID)
  if not slua.isValid(uWeapon) then
    print(bWriteLog and string.format("WeaponUtils:RemoveLocalEquipAttrModifierConfig unvalid [%s]", tostring(UnquieID)))
    return
  end
  print(bWriteLog and string.format("WeaponUtils:RemoveLocalEquipAttrModifierConfig [%s] [%s]", tostring(uWeapon), tostring(UnquieID)))
  local EquipTag = "Equip"
  uWeapon:SetWeaponAttrModifierEnable(EquipTag, false, true)
  uWeapon:RemoveWeaponAttrModifierConfig(UnquieID)
  local WeaponOwenr = uWeapon:GetOwnerPawn()
  local OwenrUseWeapon = slua.isValid(WeaponOwenr) and WeaponOwenr:GetCurrentWeapon()
  if OwenrUseWeapon == uWeapon then
    uWeapon:SetWeaponAttrModifierEnable(EquipTag, true, true)
  end
end
function WeaponUtils:GetCurBulletUploadData()
  self.LagCompensationSubSystem = self.LagCompensationSubSystem or USubsystemBlueprintLibrary.GetWorldSubsystem(CGameWorld, ULagCompensationSubSystem)
  local CurHitData = slua.isValid(self.LagCompensationSubSystem) and self.LagCompensationSubSystem.CurHitData
  local BulletUploadData = CurHitData and CurHitData.IsValid and CurHitData.UploadData
  return BulletUploadData
end
function WeaponUtils:IsWeaponIgnoreRecordDamage(WeaponID)
  return WeaponID == 106012
end
function WeaponUtils:GetWeaponSupportAttachments(WeaponID)
  local FixWeaponID = UAvatarUtils.GetWeaponReuseConfigTarget(WeaponID, EWeaponReuseCfgType.ReuseSupportAttach)
  return CDataTable.GetTableData("WeaponAttachments", FixWeaponID)
end
function WeaponUtils:SwitchX4ScopeSight(IsToggle)
  local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  local uCurrentShootWeapon = slua.isValid(uPlayerCharacter) and uPlayerCharacter.GetCurrentShootWeapon and uPlayerCharacter:GetCurrentShootWeapon()
  local uScopeSKMeshComp = slua.isValid(uCurrentShootWeapon) and uCurrentShootWeapon.GetScopeAimCameraSecondScopeByType and uCurrentShootWeapon:GetScopeAimCameraSecondScopeByType("ScopeAimCamera", EWeaponAttachmentSocketType.OpticalSight, 0)
  if not slua.isValid(uScopeSKMeshComp) then
    print(bWriteLog and string.format("WeaponUtils:SwitchX4ScopeSight, uPlayerCharacter[%s], uCurrentShootWeapon[%s], uScopeSKMeshComp[%s]", tostring(uPlayerCharacter), tostring(uCurrentShootWeapon), tostring(uScopeSKMeshComp)))
    return
  end
  local TableUtil = require("common.table_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local X4SightIndexReadData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eX4ScopeSightIndex)
  local X4SightIndexData = type(X4SightIndexReadData) == "table" and X4SightIndexReadData or {}
  local WeaponID = uCurrentShootWeapon.GetWeaponID and uCurrentShootWeapon:GetWeaponID() or 0
  local X4SightIndexTarget = type(X4SightIndexData[WeaponID]) == "number" and X4SightIndexData[WeaponID] or 0
  X4SightIndexTarget = (X4SightIndexTarget + (IsToggle and 1 or 0)) % 3
  local X4SightIndexRead = TableUtil.GetTableValue(X4SightIndexReadData, WeaponID)
  if X4SightIndexTarget ~= X4SightIndexRead then
    X4SightIndexData[WeaponID] = X4SightIndexTarget
    PlayerPrefsSystem.SaveTableToFile_N(X4SightIndexData, PlayerPrefsSystem.ePlayerPrefsType.eX4ScopeSightIndex)
    print(bWriteLog and string.format("WeaponUtils:SwitchX4ScopeSight [%s->%s]", tostring(X4SightIndexRead), tostring(X4SightIndexTarget)))
  end
  local GetCurSightMaterial = function(uScopeSKMeshComp)
    local X4SightIndexCur, MatIndex, CurMatName, ParentMatName
    local MatNum = uScopeSKMeshComp:GetNumMaterials()
    for i = 1, MatNum do
      local MatInterface = uScopeSKMeshComp:GetMaterial(i - 1)
      if slua.isValid(MatInterface) and MatInterface.Parent then
        local MatName = STExtraBlueprintFunctionLibrary.GetObjName(MatInterface)
        local MatParentName = STExtraBlueprintFunctionLibrary.GetObjName(MatInterface.Parent)
        print(bWriteLog and string.format("WeaponUtils:SwitchX4ScopeSight [%s] [%s]", tostring(MatName), tostring(MatParentName)))
        if X4SightMatNames[MatParentName] then
          MatIndex = i - 1
          Cur          ParentMatName = MatParentName
          break
        end
      end
    end
    if MatIndex then
      local CurMatIndex = CurMatName and X4SightMatNames[CurMatName]
      local ParentMatIndex = ParentMatName and X4SightMatNames[ParentMatName]
      if CurMatIndex == 0 or CurMatIndex ~= 1 and CurMatIndex ~= 2 and ParentMatIndex == 0 then
        X4SightIndexCur = 0
      elseif CurMatIndex == 1 or ParentMatIndex == 1 then
        X4SightIndexCur = 1
      elseif CurMatIndex == 2 or ParentMatIndex == 2 then
        X4SightIndexCur = 2
      end
    end
    return MatIndex, X4SightIndexCur
  end
  local MatIndex, X4SightIndexCur = GetCurSightMaterial(uScopeSKMeshComp)
  if not MatIndex then
    print(bWriteLog and string.format("WeaponUtils:SwitchX4ScopeSight MatIndex = nil"))
    return
  end
  if X4SightIndexCur == X4SightIndexTarget then
    print(bWriteLog and string.format("WeaponUtils:SwitchX4ScopeSight X4SightIndexCur = X4SightIndexTarget"))
  end
  local X4SightMatPathTarget = X4SightMatPaths[X4SightIndexTarget]
  if not X4SightMatPathTarget then
    print(bWriteLog and string.format("WeaponUtils:SwitchX4ScopeSight X4SightMatPathTarget = nil"))
    return
  end
  local asset_util = require("common.asset_util")
  asset_util.GetAssetAsyncOneParam(X4SightMatPathTarget, function(uMaterial)
    if not slua.isValid(uScopeSKMeshComp) or not slua.isValid(uMaterial) then
      print(bWriteLog and string.format("WeaponUtils:SwitchX4ScopeSight X4SightMatPathTarget uScopeSKMeshComp[%s], uMaterial[%s]", tostring(uScopeSKMeshComp), tostring(uMaterial)))
      return
    end
    uScopeSKMeshComp:SetMaterial(MatIndex, uMaterial)
    if slua.isValid(uPlayerCharacter) then
      if uPlayerCharacter.AutoAimComp and uPlayerCharacter.AutoAimComp.bModifyCrossHair then
        uScopeSKMeshComp:CreateAndSetMaterialInstanceDynamic(MatIndex)
      end
      local IsInElectromagneticArea = uPlayerCharacter:GetAttrValue("IsInElectromagneticArea")
      if 0.99 < IsInElectromagneticArea then
        local NeonMat = uScopeSKMeshComp:CreateAndSetMaterialInstanceDynamic(MatIndex)
        if slua.isValid(NeonMat) then
          NeonMat:SetScalarParameterValue("Tex Center Opacity", 0)
        end
      end
    end
  end)
end
return WeaponUtils