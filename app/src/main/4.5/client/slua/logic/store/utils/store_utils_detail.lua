local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
local C_ENUM_GOLD = FLinearColor(0.879623, 0.672443, 0.304987, 1)
local C_ENUM_SILVER = FLinearColor(0.617207, 0.617207, 0.617207, 1)
local local local local local E_MissileSkin_SubType = {
  [ENUM_ITEM_SUBTYPE.Grenade_612] = true,
  [ENUM_ITEM_SUBTYPE.Smoke_Grenade] = true,
  [ENUM_ITEM_SUBTYPE.Grenade_614] = true,
  [ENUM_ITEM_SUBTYPE.Molotov_Cocktail] = true
}
local E_ShowFeatures_Type = {
  [ENUM_ITEM_TYPE.Voice_Pack] = true,
  [ENUM_ITEM_TYPE.Buddy] = true,
  [ENUM_ITEM_TYPE.Vehicle] = true,
  [ENUM_ITEM_TYPE.Wingman_Skin] = true,
  [ENUM_ITEM_TYPE.Aircraft_Skin] = true,
  [ENUM_ITEM_TYPE.Emote] = true
}
local C_Left_Corner_Video_Button_Type = {
  [ENUM_ITEM_TYPE.Emote] = true
}
local C_Left_Corner_Video_Button_SubType = {
  [ENUM_ITEM_SUBTYPE.DanceTogether] = true
}
local changeColorMap = {}
function StoreUtils.CheckLevelUpShow(itemID, itemType)
  if itemID == nil or itemType == nil then
    return false
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsVehicle(itemType) then
    return true
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local avatar = ModelDisplayer.GetShowingAvatar()
  if not avatar then
    return false
  end
  if not avatar:HasEquiped(itemID) and (not avatar:GetModel() or not avatar:IsSwitchingState(itemID)) and ModelDisplayer.GetShowingStatus() == ModelDisplayer.Enum_Status.Avatar then
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local maxItemID = ItemUpgradeMgr:GetMaxLevelItem(itemID)
    if 0 < maxItemID then
      if not ModelDisplayer.GetShowingAvatar():HasEquiped(maxItemID) then
        return false
      end
    else
      return false
    end
  end
  return true
end
function StoreUtils.IsDiyItem(itemID, type)
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if type == ENUM_ITEM_TYPE.Applique or ModelDisplayTypeHelper.IsDIYWeapon(itemID) then
    return true
  end
  return false
end
local checkMissileSkinSubType = function(itemType, itemSubType)
  if itemType == ENUM_ITEM_TYPE.Consumables and E_MissileSkin_SubType[itemSubType] then
    return true
  end
  return false
end
local checkItemTypeByFeatures = function(itemType, itemSubType)
  if E_ShowFeatures_Type[itemType] then
    return true
  elseif checkMissileSkinSubType(itemType, itemSubType) then
    return true
  end
  return false
end
local specialFeatureItemTb = {
  [1407387] = 1,
  [1407425] = 1
}
function StoreUtils.CheckLowerLeftCornerVideoButtonStyle(itemType, itemSubType)
  if C_Left_Corner_Video_Button_Type[itemType] and C_Left_Corner_Video_Button_SubType[itemSubType] then
    return true
  end
  return false
end
function StoreUtils.CheckShowFeatures(itemID, itemType, itemSubType)
  if checkItemTypeByFeatures(itemType, itemSubType) then
    return true
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local avatar = ModelDisplayer.GetShowingAvatar()
  if specialFeatureItemTb[itemID] then
    for id, _ in pairs(specialFeatureItemTb) do
      if avatar:HasEquiped(id) then
        log(bWriteLog and "  StoreUtils.CheckShowFeatures.  id" .. tostring(id))
        return true
      end
    end
  end
  if avatar and not avatar:HasEquiped(itemID) and (not avatar:GetModel() or not avatar:IsSwitchingState(itemID)) and ModelDisplayer.GetShowingStatus() == ModelDisplayer.Enum_Status.Avatar then
    return false
  end
  return true
end
function StoreUtils.HaveVideoFeature(strFeatures)
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  if VideoLibrary.IsCanPlayVideo() == false then
    return nil, nil
  end
  local StringUtil = require("common.string_util")
  local features = StringUtil.Split(strFeatures, ";")
  for i, v in ipairs(features) do
    local cfg = CDataTable.GetTableData("FeaturesConfig", tonumber(v))
    if not cfg or cfg.FeatureType ~= ENUM_FeatureType.Video or StoreUtils.CheckExcludeForCurRegion(cfg) then
    else
      return cfg.Video, cfg.ID
    end
  end
  return nil, nil
end
function StoreUtils.HaveEnterExpressionFeature(strFeatures)
  local StringUtil = require("common.string_util")
  local features = StringUtil.Split(strFeatures, ";")
  for i, v in ipairs(features) do
    local cfg = CDataTable.GetTableData("FeaturesConfig", tonumber(v))
    if not cfg or cfg.FeatureType ~= ENUM_FeatureType.Emotion or StoreUtils.CheckExcludeForCurRegion(cfg) then
    else
      return cfg
    end
  end
  return nil
end
local hasDependenceDesc = {
  [ENUM_Feature_Desc_Type.hasHorse] = 1,
  [ENUM_Feature_Desc_Type.hasSecondLevel] = 1,
  [ENUM_Feature_Desc_Type.hasKill] = 1,
  [ENUM_Feature_Desc_Type.hasIdle] = 1,
  [ENUM_Feature_Desc_Type.hasBfSecondLevel] = 1,
  [ENUM_Feature_Desc_Type.MaleHasSunAndMoon] = 1,
  [ENUM_Feature_Desc_Type.FemaleHasSunAndMoon] = 1,
  [ENUM_Feature_Desc_Type.GeminiCollectMale] = 1,
  [ENUM_Feature_Desc_Type.GeminiCollectFemale] = 1,
  [ENUM_Feature_Desc_Type.GeminiCollectFusion] = 1,
  [ENUM_Feature_Desc_Type.GeminiSword] = 1
}
local hasNotDependenceDesc = {
  [ENUM_Feature_Desc_Type.nHasHorse] = 1,
  [ENUM_Feature_Desc_Type.nHasSecondLevel] = 1,
  [ENUM_Feature_Desc_Type.nHasKill] = 1,
  [ENUM_Feature_Desc_Type.nHasIdle] = 1,
  [ENUM_Feature_Desc_Type.nHasBfSecondLevel] = 1,
  [ENUM_Feature_Desc_Type.nMaleHasSunAndMoon] = 1,
  [ENUM_Feature_Desc_Type.nFemaleHasSunAndMoon] = 1,
  [ENUM_Feature_Desc_Type.GeminiCollectMaleNot] = 1,
  [ENUM_Feature_Desc_Type.GeminiCollectFemaleNot] = 1,
  [ENUM_Feature_Desc_Type.GeminiCollectFusionNot] = 1,
  [ENUM_Feature_Desc_Type.GeminiSwordNot] = 1
}
function StoreUtils.GetFeatureData(cfg, itemType, itemSubType, enableCameraAnim, minLv)
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local needShow = true
  local DescID = cfg.DescID
  if cfg.FeatureType == ENUM_FeatureType.Video then
    needShow = VideoLibrary.IsCanPlayVideo()
  elseif cfg.FeatureType == ENUM_FeatureType.Grenade then
    needShow = LobbySystem.CheckOpen(BP_ENUM_THROW_OBJECT_EFFECT_SWITCH)
  elseif ENUM_CAN_SHARE_SUIT_DESC[DescID] or ENUM_CAN_NOT_SHARE_SUIT_DESC[DescID] then
    local ShareSuit = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ShareSuit)
    if ENUM_CAN_SHARE_SUIT_DESC[DescID] then
      needShow = ShareSuit:CheckLoverCollect(cfg.itemId)
    else
      log(bWriteLog and "[SY]StoreUtils.GetFeatureData. ENUM_CAN_NOT_SHARE_SUIT_DESC")
      needShow = not ShareSuit:CheckLoverCollect(cfg.itemId)
    end
  else
    local itemId = cfg.itemId
    if itemId ~= 0 then
      local has = StoreUtils.HasItem(itemId)
      needShow = StoreUtils.CheckFeatureDescIsHave(has, DescID)
    end
    local stringUtil = require("common.string_util")
    if cfg.itemList ~= "" then
      local itemList = stringUtil.Split(cfg.itemList, ";")
      local allHave = true
      for i, v in pairs(itemList) do
        local has = StoreUtils.HasItem(tonumber(v))
        if not has then
          allHave = false
          break
        end
      end
      needShow = StoreUtils.CheckFeatureDescIsHave(allHave, DescID)
    end
  end
  if needShow then
    local data = {
      btnIcon = StoreUtils.GetCurrentFeatureIcon(cfg),
      btnIconLock = StoreUtils.GetCurrentFeatureIconLock(cfg),
      itemType = itemType,
      itemSubType = itemSubType,
      enableCameraAnim = enableCameraAnim,
      featureName = "",
      featureDes = "",
      config = cfg,
      minLv = minLv or 1
    }
    local descID = cfg.DescID or 0
    if 0 < descID then
      local featuresDetail = CDataTable.GetTableData("FeaturesDetail", descID)
      if featuresDetail then
        data.featureName = featuresDetail.FeatureName
        data.featureDes = featuresDetail.FeatureDes
        data.btnIconLock = data.btnIconLock or featuresDetail.IconColor == 1
      end
    end
    return data
  end
  return nil
end
function StoreUtils.CheckFeatureDescIsHave(has, DescID)
  if has then
    if hasNotDependenceDesc[DescID] then
      return false
    end
  elseif hasDependenceDesc[DescID] then
    return false
  end
  return true
end
function StoreUtils.GetCurrentFeatureIcon(featureCfg)
  local iconPath = ""
  if not featureCfg then
    return iconPath
  end
  if featureCfg.DescID then
    local featuresDetail = CDataTable.GetTableData("FeaturesDetail", featureCfg.DescID)
    if featuresDetail then
      iconPath = featuresDetail.IconPath or ""
    end
  else
    iconPath = featureCfg.BtnIcon or ""
  end
  return iconPath
end
function StoreUtils.GetCurrentFeatureIconLock(featureCfg)
  if ENUM_CAN_NOT_SHARE_SUIT_DESC[featureCfg.DescID] then
    return true
  end
  return false
end
function StoreUtils.SetFeatureIconByWidget(widget, descID)
  if not widget then
    return
  end
  local featuresDetail = CDataTable.GetTableData("FeaturesDetail", descID)
  if featuresDetail then
    if featuresDetail.IconPath then
      local util = require("client.slua_ui_framework.util")
      util.SetTexture(widget, featuresDetail.IconPath, {sync = false})
    end
    if featuresDetail.IconColor == 0 then
      widget:SetColorAndOpacity(C_ENUM_GOLD)
    else
      widget:SetColorAndOpacity(C_ENUM_SILVER)
    end
  else
    log_error(string.format("This configuration item was not found by descID = %s", descID))
  end
end
function StoreUtils.CheckExcludeForCurRegion(cfg)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    if cfg and cfg.ExcludeJPKR == 1 then
      return true
    end
  elseif PublishRegionMacros.IsBLUEHOLE() then
    if cfg and cfg.ExcludeIN == 1 then
      return true
    end
  elseif cfg and cfg.ExcludeGlobal == 1 then
    return true
  end
  return false
end
function StoreUtils.GetChangeColorWeaponCfg(itemID, featureID)
  if not changeColorMap[itemID] or not next(changeColorMap[itemID]) then
    changeColorMap[itemID] = {}
    local mapData = changeColorMap[itemID]
    local cfgData = CDataTable.GetTableByFilter("WeaponChangeColorFeature", "suitId", itemID)
    local stringUtil = require("common.string_util")
    for i, cfg in pairs(cfgData) do
      local features = stringUtil.Split(cfg.features, ";")
      for _, feature in pairs(features) do
        mapData[tonumber(feature)] = cfg
      end
    end
  end
  local table_util = require("common.table_util")
  return table_util.GetTableValue(changeColorMap, itemID, featureID)
end