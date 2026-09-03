local QuickExpressionUtils = {}
local _CheckIsCanPlayCollectEmote = function(nEmoteId)
  if not nEmoteId or nEmoteId == 0 then
    return false
  end
  local uItemUpgradeEmoteCfg = CDataTable.GetTableData("ItemUpgradeCollectEmote", nEmoteId)
  if not uItemUpgradeEmoteCfg then
    print(bWriteLog and " QuickExpressionUtils._CheckIsCanPlayCollectEmote no cfg")
    return true
  end
  local nItemId = uItemUpgradeEmoteCfg.CollectItemID_a:Get(0)
  local sTableName = "GoldenSuitUpgradeCfg"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    sTableName = "GoldenSuitUpgradeCfgKJ"
  elseif PublishRegionMacros.IsBLUEHOLE() then
    sTableName = "GoldenSuitUpgradeCfgIN"
  end
  local uXSuitDataCfg = CDataTable.GetTableDataByFilter(sTableName, "ItemID", nItemId)
  if not uXSuitDataCfg then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local nPeriod = uXSuitDataCfg.Period
  local uCurPeriodAllItem = CDataTable.GetTableByFilter(sTableName, "Period", nPeriod)
  for _, v in pairs(uCurPeriodAllItem) do
    if wardrobe_data:CheckHasPermanentItem(v.ItemID) then
      return true
    end
  end
end
local _CheckAndAddWeaponShowEmote = function(tShowEmoteList)
  local nWeaponShowEmoteID = 0
  local nState, nEmoteID = QuickExpressionUtils.GetCurrentWeaponShowEmoteState()
  if nState == 0 or nState == 1 then
    local uItemCfg = CDataTable.GetTableData("Item", nEmoteID)
    local sName = uItemCfg and uItemCfg.ItemName or ""
    print(bWriteLog and "QuickExpressionUtils.GetShowExpressionList hasWeaponShowEmote")
    local WeaponShowEmoteItem = {
      DefineID = {TypeSpecificID = nEmoteID},
      Name = sName,
      bWeaponShow = true
    }
    nWeaponShowEmoteID = nEmoteID
    table.insert(tShowEmoteList, 1, WeaponShowEmoteItem)
  end
  return tShowEmoteList, nWeaponShowEmoteID
end
local _CheckAndAddClothEmote = function(tShowEmoteList)
  local nClothEmoteID = 0
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "QuickExpressionUtils._CheckAndAddClothEmote OwningActor invalid")
    return tShowEmoteList, nClothEmoteID
  end
  if not OwningActor.getAvatarComponent2 then
    print(bWriteLog and "QuickExpressionUtils._CheckAndAddClothEmote getAvatarComponent2 not exist")
    return tShowEmoteList, nClothEmoteID
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    print(bWriteLog and "QuickExpressionUtils._CheckAndAddClothEmote AvatarComp2 invalid")
    return tShowEmoteList, nClothEmoteID
  end
  local targetExpressionID = 0
  local AvatarItemIDListTable = uAvatarComp2:GetAllEquipItemsTable()
  if AvatarItemIDListTable then
    local StringUtil = require("common.string_util")
    for itemID, _ in pairs(AvatarItemIDListTable) do
      local featuresItems = CDataTable.GetTableData("FeaturesItems", itemID)
      if featuresItems and featuresItems.Features ~= "" then
        local features = StringUtil.Split(featuresItems.Features, ";")
        for _, featureIDStr in ipairs(features) do
          local featureID = tonumber(featureIDStr)
          if featureID then
            local featureCfg = CDataTable.GetTableData("FeaturesConfig", featureID)
            if featureCfg and featureCfg.FeatureType == ENUM_FeatureType.ClickEmotion and featureCfg.FightExpressionID and 0 < featureCfg.FightExpressionID then
              targetExpressionID = featureCfg.FightExpressionID
              break
            end
          end
        end
      end
      if 0 < targetExpressionID then
        break
      end
    end
  end
  if 0 < targetExpressionID then
    local uItemCfg = CDataTable.GetTableData("Item", targetExpressionID)
    local sName = uItemCfg and uItemCfg.ItemName or ""
    print(bWriteLog and "QuickExpressionUtils._CheckAndAddClothEmote hasClothEmote ID:" .. tostring(targetExpressionID))
    local ClothEmoteItem = {
      DefineID = {TypeSpecificID = targetExpressionID},
      Name = sName,
      bClothEmote = true
    }
    nClothEmoteID = targetExpressionID
    table.insert(tShowEmoteList, 1, ClothEmoteItem)
  end
  return tShowEmoteList, nClothEmoteID
end
function QuickExpressionUtils.GetWeaponShowEmoteID()
  local nWeaponShowEmoteID = 0
  local nState, nEmoteID = QuickExpressionUtils.GetCurrentWeaponShowEmoteState()
  if nState == 0 or nState == 1 then
    nWeaponShowEmoteID = nEmoteID
  end
  return nWeaponShowEmoteID
end
function QuickExpressionUtils.GetClothEmoteID()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "QuickExpressionUtils.GetClothEmoteID OwningActor invalid")
    return 0
  end
  if not OwningActor.getAvatarComponent2 then
    print(bWriteLog and "QuickExpressionUtils.GetClothEmoteID getAvatarComponent2 not exist")
    return 0
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    print(bWriteLog and "QuickExpressionUtils.GetClothEmoteID AvatarComp2 invalid")
    return 0
  end
  local targetExpressionID = 0
  local AvatarItemIDListTable = uAvatarComp2:GetAllEquipItemsTable()
  if AvatarItemIDListTable then
    local StringUtil = require("common.string_util")
    for itemID, _ in pairs(AvatarItemIDListTable) do
      local featuresItems = CDataTable.GetTableData("FeaturesItems", itemID)
      if featuresItems and featuresItems.Features ~= "" then
        local features = StringUtil.Split(featuresItems.Features, ";")
        for _, featureIDStr in ipairs(features) do
          local featureID = tonumber(featureIDStr)
          if featureID then
            local featureCfg = CDataTable.GetTableData("FeaturesConfig", featureID)
            if featureCfg and featureCfg.FeatureType == ENUM_FeatureType.ClickEmotion and featureCfg.FightExpressionID and 0 < featureCfg.FightExpressionID then
              targetExpressionID = featureCfg.FightExpressionID
              break
            end
          end
        end
      end
      if 0 < targetExpressionID then
        break
      end
    end
  end
  return targetExpressionID
end
function QuickExpressionUtils.GetCurrentWeaponShowEmoteState()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "QuickExpressionUtils.GetCurrentWeaponShowEmoteState Error 1")
    return -1
  end
  local OwningController = OwningActor:GetPlayerControllerSafety()
  if not OwningController or not slua.isValid(OwningController) then
    print(bWriteLog and "QuickExpressionUtils.GetCurrentWeaponShowEmoteState Error 2")
    return -1
  end
  if not OwningActor.GetCurrentWeapon then
    print(bWriteLog and "QuickExpressionUtils.GetCurrentWeaponShowEmoteState Error 3")
    return -1
  end
  local Weapon = OwningActor:GetCurrentWeapon()
  if not slua.isValid(Weapon) or not slua.isValid(Weapon.WeaponAvatarComponent) then
    return 2
  end
  local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
  local WeaponAvatarID = Weapon.WeaponAvatarComponent:GetEquippedItemDefineID(EWeaponAttachmentSocketType.MasterGun).TypeSpecificID
  if WeaponAvatarID <= 0 then
    print(bWriteLog and "QuickExpressionUtils.GetCurrentWeaponShowEmoteState Error A WeaponAvatarID =", WeaponAvatarID)
    WeaponAvatarID = Weapon:GetItemDefineID().TypeSpecificID
  end
  if WeaponAvatarID <= 0 then
    print(bWriteLog and "QuickExpressionUtils.GetCurrentWeaponShowEmoteState Error B WeaponAvatarID =", WeaponAvatarID)
    return -1
  end
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if PhotoGrapherSubSystem and PhotoGrapherSubSystem.bIsPhotoGrapherMode then
    return 1
  end
  local EmoteID = 0
  local Cfg = CDataTable.GetTableData("WeaponAvatarBattleEffect", WeaponAvatarID)
  if Cfg then
    local WeaponShowEmoteList = OwningController.CommerFeature and OwningController.CommerFeature.WeaponShowEmoteList or {}
    for _, v in pairs(WeaponShowEmoteList) do
      if Cfg.WeaponEmoteID == v then
        EmoteID = v
      end
    end
  end
  if not _CheckIsCanPlayCollectEmote(EmoteID) then
    return 3
  else
    local CheckGunSkillID = 1014405
    if OwningActor.GetSkillManager then
      local SkillMgr = OwningActor:GetSkillManager()
      if Game:IsValid(SkillMgr) and SkillMgr:IsCastingSkillID(CheckGunSkillID) then
        return 1, EmoteID
      end
    end
    if not (OwningActor.CurrentStates == 1 << UEnums.EPawnState.Stand and OwningActor.IsHandleInFold) or OwningActor:IsHandleInFold() then
      return 1, EmoteID
    else
      return 0, EmoteID
    end
  end
end
function QuickExpressionUtils.GetShowExpressionList()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) or not uPlayerController.PlayEmoteFeature then
    log(bWriteLog and "QuickExpressionUtils.GetShowExpressionList PlayerController or PlayEmoteFeature is Not valid!")
    return nil
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local BackPackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(uPlayerController)
  if not BackPackComp or not slua.isValid(BackPackComp) then
    log(bWriteLog and "QuickExpressionUtils.GetShowExpressionList BackpackCmp is Not valid!")
    return nil
  end
  local BackpackUtils = import("BackpackUtils")
  local EmoteItems = BackpackUtils.GetEmoteItemInBackpack(BackPackComp)
  local tShowEmoteList = {}
  for Index, Data in pairs(EmoteItems) do
    tShowEmoteList[Index + 1] = Data
  end
  local nWeaponShowEmoteID = 0
  tShowEmoteList, nWeaponShowEmoteID = _CheckAndAddWeaponShowEmote(tShowEmoteList)
  local nClothEmoteID = 0
  tShowEmoteList, nClothEmoteID = _CheckAndAddClothEmote(tShowEmoteList)
  return tShowEmoteList, nWeaponShowEmoteID
end
function QuickExpressionUtils.GetClothBackpackItem()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not PlayerController or not slua.isValid(PlayerController) then
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local BackPackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(PlayerController)
  if not BackPackComp or not slua.isValid(BackPackComp) then
    return
  end
  local BackpackUtils = import("BackpackUtils")
  local uClothBackpackItem = BackpackUtils.GetClothingAndArmorInBackpack(BackPackComp)
  local tClothBackpackItem = {}
  for _, Data in pairs(uClothBackpackItem) do
    local TypeSpecificID = Data.DefineID.TypeSpecificID
    tClothBackpackItem[TypeSpecificID] = true
    print(bWriteLog and "QuickExpressionUtils.GetClothBackpackItem ClothBackpackItem, " .. TypeSpecificID)
  end
  return tClothBackpackItem
end
function QuickExpressionUtils.TryPlayWeaponShowEmote()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local nState = QuickExpressionUtils.GetCurrentWeaponShowEmoteState()
  if nState ~= 0 then
    local OwningController = OwningActor:GetPlayerControllerSafety()
    if OwningController and slua.isValid(OwningController) and OwningController.DisplayGameTipWithMsgID and nState == 1 then
      OwningController:DisplayGameTipWithMsgID(30121)
    else
    end
    return
  end
  local WeaponShowSkillID = 1014433
  local SkillMgr = OwningActor:GetSkillManager()
  if Game:IsValid(SkillMgr) and SkillMgr:IsCastingSkillID(WeaponShowSkillID) then
    return
  end
  OwningActor:ForceSyncMovementState()
  OwningActor:TriggerEntrySkillWithID(WeaponShowSkillID, true)
end
return QuickExpressionUtils