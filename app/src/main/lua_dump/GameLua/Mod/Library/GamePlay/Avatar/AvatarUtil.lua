local AvatarUtil = {
  CacheUnderWearMap = {},
  GM_GrenadeAvatarTest = nil
}
local GUN_MASTER_SLOT = 7
function AvatarUtil.GetGrenadeKillBindGunID(CurWeaponID, GrenadeID)
  local Cfg = CDataTable.GetTableData("GrenadeKillGunBindMap", GrenadeID)
  if not Cfg then
    return 0
  end
  for k, v in pairs(Cfg.GunIDList_a) do
    if v == CurWeaponID then
      return CurWeaponID
    end
  end
  return 0
end
function AvatarUtil.NeedDoubleCheck(ItemID)
  if CDataTable.GetTableData("UseIntBeforeDownload", ItemID) then
    return false
  end
  local UIUtil = require("client.common.ui_util")
  local itemCfg = UIUtil.GetItemCfg(ItemID)
  if not (itemCfg and itemCfg.ItemType) or not itemCfg.ItemSubType then
    return false
  end
  if itemCfg.ItemType == ENUM_ITEM_TYPE.Extra and (itemCfg.ItemSubType <= ENUM_ITEM_SUBTYPE.Theme_Play or itemCfg.ItemSubType <= ENUM_ITEM_SUBTYPE.Glider_Slot_415 and itemCfg.ItemSubType >= ENUM_ITEM_SUBTYPE.Glider_Slot_413) or itemCfg.ItemType == ENUM_ITEM_TYPE.Backpack and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Helmet then
    return true
  end
  return false
end
function AvatarUtil.DoubleCheckIsDownLoadFinish(resID, pakName)
  log(bWriteLog and "AvatarUtil.DoubleCheckIsDownLoadFinish resID" .. tostring(resID) .. " pakName " .. tostring(pakName))
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if not pakName or pakName == "" then
    return true
  end
  local filePath = Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. pakName
  if Client.IsFileExistsWithOutPakCheck(filePath) then
    return true
  end
  log(bWriteLog and "AvatarUtil.DoubleCheckIsDownLoadFinish filePath not in Device " .. tostring(filePath))
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  PufferODPakManager:RestStateByItemID(resID)
  return false
end
function AvatarUtil.GetAvatarHandlePath(resID)
  local UBackpackUtils = import("BackpackUtils")
  local ItemDefineID = UBackpackUtils.GetItemDefineIDByItemID(resID)
  return UBackpackUtils.GetBattleItemHandlePath(ItemDefineID, true, false)
end
function AvatarUtil.GetGlideType(ItemID)
  local GlideTypeConfig = CDataTable.GetTableData("GlideTypeConfig", ItemID)
  if not GlideTypeConfig then
    if Client and Client.IsDevelopment() then
      local itemCfg = CDataTable.GetTableData("Item", ItemID)
      if itemCfg and itemCfg.ItemSubType ~= ENUM_ITEM_SUBTYPE.Glider_Slot_415 then
        ShowDevNotice("###\233\163\158\232\161\140\229\153\168\233\133\141\231\189\174\232\161\168->\233\163\158\232\161\140\229\153\168\229\136\134\231\177\187\239\188\140\230\178\161\230\156\137\233\133\141\231\189\174\239\188\140\233\133\141\228\184\128\228\184\139")
      end
    end
    return -1
  end
  return GlideTypeConfig.TypeID
end
function AvatarUtil.GetGlideCameraSetting(ItemID)
  local TypeID = AvatarUtil.GetGlideType(ItemID)
  if TypeID < 0 then
    return
  end
  local GlideCameraSetting = CDataTable.GetTableData("GlideCameraSetting", TypeID)
  return GlideCameraSetting
end
function AvatarUtil.IsUnderWearItem(ItemID)
  local UIUtil = require("client.common.ui_util")
  local itemCfg = UIUtil.GetItemCfg(ItemID)
  if not itemCfg then
    return false
  end
  if itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.UnderCloth or itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.UnderPants then
    return true
  end
  return false
end
function AvatarUtil.ConvertUnderWearID(ItemID, Color)
  if not Color or Color <= 0 then
    return ItemID
  end
  if AvatarUtil.CacheUnderWearMap[ItemID] and AvatarUtil.CacheUnderWearMap[ItemID][Color] then
    return AvatarUtil.CacheUnderWearMap[ItemID][Color]
  end
  local TableData = CDataTable.GetTableDataByFilter("AvatarInit", "ColorID", Color, "BodyID", ItemID)
  if not TableData then
    return ItemID
  end
  AvatarUtil.CacheUnderWearMap[ItemID] = AvatarUtil.CacheUnderWearMap[ItemID] or {}
  AvatarUtil.CacheUnderWearMap[ItemID][Color] = TableData.UnderWearID
  return TableData.UnderWearID
end
function AvatarUtil.IsXSuitItem(ItemID)
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  return AvatarCommon.IsXSuit(ItemID)
end
function AvatarUtil.GetCharacterWearingXSuitItem(uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) and slua.isValid(uPlayerCharacter.CharacterAvatarComp2_BP) then
    return uPlayerCharacter.CharacterAvatarComp2_BP.XSuitItemID
  end
  return 0
end
function AvatarUtil.IsGoldenSuitItem(ItemID)
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  return AvatarCommon.IsGoldenSuit(ItemID)
end
function AvatarUtil.GetCharacterWearingGoldenSuitItem(uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) and slua.isValid(uPlayerCharacter.CharacterAvatarComp2_BP) then
    return uPlayerCharacter.CharacterAvatarComp2_BP.GoldenSuitItemID
  end
  return 0
end
function AvatarUtil.IsEnableGoldenSuitPerformance(uPlayerCharacter)
  if not slua.isValid(uPlayerCharacter) then
    return false
  end
  if _G.IsEditor then
    return true
  end
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local UID = Game:GetPlayerUID(uPlayerCharacter)
  local PlayerInfo = ServerPlayerDataMgr.GetPlayerInfo(UID)
  if not PlayerInfo or not PlayerInfo.ext_attr then
    print(bWriteLog and string.format("AvatarUtil.IsEnableGoldenSuitPerformance UID = %s, PlayerInfo or PlayerInfo.ext_attr is not valid", UID))
    return false
  end
  print(bWriteLog and string.format("AvatarUtil.IsEnableGoldenSuitPerformance UID = %s, PlayerInfo.ext_attr[63] = %s", UID, PlayerInfo.ext_attr[63]))
  return PlayerInfo.ext_attr[63] == nil or PlayerInfo.ext_attr[63] == 1
end
function AvatarUtil.GetThrowWeaponProtoItemID_Old(ItemDefineID, Outer)
  local ProtoItemID = AvatarUtil.GetThrowWeaponProtoItemID(ItemDefineID.TypeSpecificID)
  if ProtoItemID < 0 then
    local UBackpackUtils = import("BackpackUtils")
    local GrenadeHandle = UBackpackUtils.CreateBattleItemHandle(ItemDefineID, Outer, false)
    local BackpackGrenadeAvatarHandle = import("BackpackGrenadeAvatarHandle")
    if slua.isValid(GrenadeHandle) and Game:IsClassOf(GrenadeHandle, BackpackGrenadeAvatarHandle) then
      ProtoItemID = GrenadeHandle.ParentID.TypeSpecificID
    end
    if 0 < ProtoItemID then
      local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
      ReportPlatformCrashKit:ForceSend("GetThrowWeaponProtoItemID:Faild ItemID:" .. tostring(ItemDefineID.TypeSpecificID))
    end
  end
  return ProtoItemID
end
function AvatarUtil.GetThrowWeaponProtoItemID(AvatarID)
  local itemCfg = CDataTable.GetTableData("Item", AvatarID)
  if not itemCfg then
    return -1
  end
  if itemCfg.ItemSubType == 612 then
    return 60200400
  elseif itemCfg.ItemSubType == 613 then
    return 60200200
  elseif itemCfg.ItemSubType == 614 then
    return 60200100
  elseif itemCfg.ItemSubType == 615 then
    return 60200300
  end
  return -1
end
function AvatarUtil.IsBornIsland()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if Game:IsValid(uGameState) and uGameState:GetGameModeState() == "ReadyState" then
    return true
  end
  return false
end
function AvatarUtil.IsItemHasFeature(ItemID, FeatureType)
  local ItemCfg = CDataTable.GetTableData("FeaturesItems", ItemID)
  if ItemCfg then
    local StringUtil = require("common.string_util")
    local features = StringUtil.Split(ItemCfg.Features, ";")
    for _, featureID in ipairs(features) do
      local featureCfg = CDataTable.GetTableData("FeaturesConfig", tonumber(featureID))
      if featureCfg and featureCfg.FeatureType == FeatureType then
        return true
      end
    end
  end
  return false
end
function AvatarUtil.GetWeaponAvatarBPIdByWeapon(uWeapon)
  if not uWeapon or not uWeapon.WeaponAvatarComponent then
    return -1
  end
  local WeaponAvatarID = uWeapon.WeaponAvatarComponent:GetEquippedItemDefineID(GUN_MASTER_SLOT).TypeSpecificID
  if WeaponAvatarID <= 0 then
    print(bWriteLog and string.format("[Error][AvatarUtil]GetWeaponAvatarBPIdByWeapon failed, fallback to ItemID.WeaponAvatarID = %s", WeaponAvatarID))
    WeaponAvatarID = uWeapon:GetItemDefineID().TypeSpecificID
  end
  if WeaponAvatarID <= 0 then
    print(bWriteLog and string.format("[Error][AvatarUtil]GetWeaponAvatarBPIdByWeapon failed, no ItemID exist!WeaponAvatarID = %s", WeaponAvatarID))
    return -1
  end
  local UAvatarUtils = import("AvatarUtils")
  return UAvatarUtils.GetBPIDByResID(WeaponAvatarID)
end
return AvatarUtil