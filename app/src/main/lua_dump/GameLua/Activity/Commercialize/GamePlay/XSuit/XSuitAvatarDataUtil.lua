local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local EAvatarSlotType = import("EAvatarSlotType")
local XSuitAvatarDataUtil = {
  levelInfo = {},
  stateInfo = {},
  InheritStateInfo = {},
  UnLockLevelTable = {},
  UnlockFeatureDataMap = {},
  TeamShowLockData = {}
}
function XSuitAvatarDataUtil:GeneratePlayerAvatarData(PlayerInfo, uPlayerController, itemList, bHasFlyingState)
  print(bWriteLog and "XSuitAvatarDataUtil:GeneratePlayerAvatarData")
  if PlayerInfo.wear_ext then
    for i, v in pairs(PlayerInfo.wear_ext) do
      self:FillWearItemToInitialItemList(v, itemList, uPlayerController, bHasFlyingState, i)
    end
  end
  self:_FillUnLockLevelList(uPlayerController)
end
function XSuitAvatarDataUtil:_FillUnLockLevelList(uPlayerController)
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local MaxPeriod = XSuitUtil:GetMaxPeriod()
  uPlayerController.CommerFeature.XSuitUnlockLevelList = slua.Array(UEnums.EPropertyClass.Int)
  for i = 1, MaxPeriod do
    local unlock_level = self.UnLockLevelTable[i]
    if unlock_level and 0 < unlock_level then
      uPlayerController.CommerFeature.XSuitUnlockLevelList:Add(unlock_level)
    else
      uPlayerController.CommerFeature.XSuitUnlockLevelList:Add(0)
    end
  end
end
function XSuitAvatarDataUtil:FillWearItemToInitialItemList(v, itemList, uPlayerController, bHasFlyingState, i)
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  if v and next(v) ~= nil and v[ENUM_AVATAR_DATA_TYPE.ItemID] then
    local item = {}
    item.ItemTableID = v[ENUM_AVATAR_DATA_TYPE.ItemID]
    if i == 3 then
      self:FillXSuitDressList(v, item, uPlayerController)
      if item.ItemTableID == nil then
        item.ItemTableID = v[1]
      end
    end
    item.AdditionIntData = CommerAvatarDataUtil:GetAdditionIntData(v)
    item.Count = 1
    if bHasFlyingState then
      table.insert(itemList, item)
    elseif i ~= 11 and i ~= 14 then
      table.insert(itemList, item)
    end
  end
end
function XSuitAvatarDataUtil:FillXSuitDressList(v, item, uPlayerController)
  local ItemID = v[ENUM_AVATAR_DATA_TYPE.ItemID]
  print(bWriteLog and "XSuitAvatarDataUtil:FillXSuitDressList ItemID:" .. tostring(ItemID))
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local period = XSuitUtil:GetPeriodByItemId(ItemID)
  if not period then
    return
  end
  self:ChangeXSuitSourceData(v)
  self:ConstructStateInfo(uPlayerController.UID)
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  item.ItemTableID = XSuitAvatarDataUtil:GetConvertXSuitItemID(v, uPlayerController.UID)
  local unlock_level = XSuitUtil:GetLevelByItemId(ItemID)
  self:SetLevelByItem(uPlayerController.UID, item.ItemTableID, unlock_level)
  self.UnLockLevelTable[period] = unlock_level
  local unlockFeatureData = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.XSuitUnlockFeature)
  self.UnlockFeatureDataMap[uPlayerController.UID] = unlockFeatureData
end
function XSuitAvatarDataUtil:ChangeXSuitSourceData(Info)
  if not Info then
    print(bWriteLog and "XSuitAvatarDataUtil:ChangeXSuitSourceData Info is nil")
    return
  end
  local ItemID = Info[ENUM_AVATAR_DATA_TYPE.ItemID]
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local period = XSuitUtil:GetPeriodByItemId(ItemID)
  if not period then
    return
  end
  Info[ENUM_AVATAR_DATA_TYPE.ColorID] = Info[ENUM_AVATAR_DATA_TYPE.Source] or 0
end
function XSuitAvatarDataUtil:GetConvertXSuitItemID(Info, UID)
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local gold_dress_set_info = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(UID, ExtendAttribute.XSuitLevel)
  local stateData = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(UID, ExtendAttribute.XSuitState)
  local InheritData = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(UID, ExtendAttribute.InheritData)
  return XSuitAvatarDataUtil:GetConvertXSuitItemIDByData(Info, UID, gold_dress_set_info, stateData, InheritData)
end
function XSuitAvatarDataUtil:ConstructStateInfo(UID)
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local stateData = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(UID, ExtendAttribute.XSuitState)
  if stateData then
    self:InitStateInfo(UID, stateData)
  end
  local InheritData = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(UID, ExtendAttribute.InheritData)
  if InheritData and InheritData.gold_dress_state_info then
    self:InitInheritStateInfo(UID, InheritData.gold_dress_state_info)
  end
end
function XSuitAvatarDataUtil:GetConvertXSuitItemIDByData(Info, UID, gold_dress_set_info, stateData, InheritData)
  local ItemID = Info[ENUM_AVATAR_DATA_TYPE.ItemID]
  local Source = Info[ENUM_AVATAR_DATA_TYPE.ColorID] or 0
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local period = XSuitUtil:GetPeriodByItemId(ItemID)
  if not period then
    return ItemID
  end
  if gold_dress_set_info and gold_dress_set_info[period] and Source ~= 1 then
    local _ItemID = XSuitUtil:GetSwitchItemByItemAndSwitchLevel(ItemID, gold_dress_set_info[period])
    print(bWriteLog and "XSuitAvatarDataUtil:GetConvertXSuitItemID originalItem:" .. tostring(ItemID) .. ", switchItem:" .. _ItemID)
    ItemID = _ItemID
  end
  if stateData then
    print(bWriteLog and "XSuitAvatarDataUtil:FillXSuitDressList stateData ")
    if stateData[period] and Source ~= 1 then
      ItemID = XSuitUtil:ChangeItemIDByState(ItemID, stateData[period].cur_state)
    end
  end
  if InheritData and InheritData.gold_dress_state_info and Source == 1 and InheritData.gold_dress_state_info[period] then
    ItemID = XSuitUtil:ChangeItemIDByState(ItemID, InheritData.gold_dress_state_info[period].cur_state)
  end
  return ItemID
end
function XSuitAvatarDataUtil:GetConvertXSuitItemIDByExtAttr(Info, UID, ext_attr)
  if not Info then
    return nil
  end
  if not ext_attr or not next(ext_attr) then
    return Info[ENUM_AVATAR_DATA_TYPE.ItemID]
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local gold_dress_set_info = ext_attr[ExtendAttribute.XSuitLevel]
  local stateData = ext_attr[ExtendAttribute.XSuitState]
  local InheritData = ext_attr[ExtendAttribute.InheritData]
  return XSuitAvatarDataUtil:GetConvertXSuitItemIDByData(Info, UID, gold_dress_set_info, stateData, InheritData)
end
function XSuitAvatarDataUtil:SetLevelByItem(uid, item, unlock_level)
  if item and uid then
    local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
    local info = XSuitUtil:GetCfgByItemId(item)
    if info then
      self:SetLevel(uid, info.period, info.level, unlock_level)
    end
  end
end
function XSuitAvatarDataUtil:SetLevel(uid, period, level, unlock_level)
  print(bWriteLog and "XSuitAvatarDataUtil:SetLevel: " .. tostring(uid) .. " " .. tostring(period) .. " " .. tostring(level) .. " " .. tostring(unlock_level))
  if not self.levelInfo[uid] then
    self.levelInfo[uid] = {}
  end
  self.levelInfo[uid][period] = {show_level = level, unlock_level = unlock_level}
end
function XSuitAvatarDataUtil:GetShowLevel(uid, period)
  if self.levelInfo and self.levelInfo[uid] and self.levelInfo[uid][period] and self.levelInfo[uid][period].show_level then
    return self.levelInfo[uid][period].show_level
  end
  return 0
end
function XSuitAvatarDataUtil:GetUnlockLevel(uid, period)
  if self.levelInfo and self.levelInfo[uid] and self.levelInfo[uid][period] and self.levelInfo[uid][period].unlock_level then
    return self.levelInfo[uid][period].unlock_level
  end
  return 0
end
function XSuitAvatarDataUtil:InitStateInfo(uid, stateInfo)
  if not uid or not stateInfo then
    return
  end
  self.stateInfo[uid] = stateInfo
end
function XSuitAvatarDataUtil:InitInheritStateInfo(uid, stateInfo)
  if not uid or not stateInfo then
    return
  end
  self.InheritStateInfo[uid] = stateInfo
end
function XSuitAvatarDataUtil:GetStateInfo(uid)
  return self.stateInfo[uid] or {}
end
function XSuitAvatarDataUtil:GetInheritStateInfo(uid)
  return self.InheritStateInfo[uid] or {}
end
function XSuitAvatarDataUtil:GetEquipXSuitLevel(uCharacter)
  local XSuitID = self:GetEquipXSuitID(uCharacter)
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local Period = XSuitUtil:GetPeriodByItemId(XSuitID)
  return self:GetUnlockLevel(uCharacter.PlayerUID, Period)
end
function XSuitAvatarDataUtil:GetEquipXSuitID(uCharacter)
  if not Game or not Game:IsValid(uCharacter) then
    return 0
  end
  local XSuitID = STExtraBlueprintFunctionLibrary.GetPlayerWearingGoldenSuitID(uCharacter, uCharacter, EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  return XSuitID
end
function XSuitAvatarDataUtil:GetItemIDByPeriodAndState(uid, period, state)
  if not (uid and period) or not state then
    return nil
  end
  if not self.levelInfo[uid] or not self.levelInfo[uid][period] then
    print(bWriteLog and "XSuitAvatarDataUtil:GetItemIDByPeriodAndState: level not found  " .. tostring(period))
    return nil
  end
  local show_level = self.levelInfo[uid][period].show_level
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local upgradeInfo = XSuitUtil:GetUpgradeInfo()
  if not (upgradeInfo and upgradeInfo[period]) or not upgradeInfo[period][show_level] then
    print(bWriteLog and "XSuitAvatarDataUtil:GetItemIDByPeriodAndState: data not found  period:" .. tostring(period) .. " show_level:" .. tostring(show_level))
    return nil
  end
  local info = upgradeInfo[period][show_level]
  if not info.second_item_id then
    print(bWriteLog and "XSuitAvatarDataUtil:GetItemIDByPeriodAndState: not bicolor xsuit " .. tostring(period))
    return nil
  end
  if state == 1 then
    return info.item_id
  end
  if state == 2 then
    return info.second_item_id
  end
end
function XSuitAvatarDataUtil:GenerateKillBroadcastItemID(ClothAvatarID, PlayerUID)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uTmpPlayerController = GameplayData.GetPlayerController(PlayerUID)
  local UID = uTmpPlayerController and uTmpPlayerController.UID or PlayerUID
  print(bWriteLog and "XSuitAvatarDataUtil:GenerateKillBroadcastItemID Start ClothAvatarID:" .. tostring(ClothAvatarID) .. " PlayerUID:" .. tostring(PlayerUID) .. " UID:" .. tostring(UID))
  local NewItemID = ClothAvatarID
  local LowLevelEffect = require("GameLua.Activity.Commercialize.GamePlay.XSuit.LowLevelEffect")
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local Period = XSuitUtil:GetPeriodByItemId(NewItemID)
  local UnLockLevel = self:GetUnlockLevel(UID, Period)
  if not XSuitUtil:IsValidXSuitEffect(ClothAvatarID, LowLevelEffect.KillBroadcast, UnLockLevel) then
    return NewItemID
  end
  local XSuitBattleEffectCfg = CDataTable.GetTable("GoldClothBattleEffect")
  if not XSuitBattleEffectCfg then
    return NewItemID
  end
  local tmpLevel = 0
  for _, v in pairs(XSuitBattleEffectCfg) do
    if v.KillEffect and v.KillEffect ~= "" then
      local tmpPeriod = XSuitUtil:GetPeriodByItemId(v.ID)
      if tmpPeriod and tmpPeriod == Period and UnLockLevel >= v.Level and tmpLevel < v.Level then
        NewItemID = v.ID
        tmpLevel = v.Level
      end
    end
  end
  print(bWriteLog and "XSuitAvatarDataUtil:GenerateKillBroadcastItemID End NewItemID:" .. tostring(NewItemID) .. " UID:" .. tostring(UID))
  return NewItemID
end
function XSuitAvatarDataUtil:GetValidXSuitIconId(UID)
  if not UID or type(UID) ~= "number" then
    return 0
  end
  local uCharacter = Game:GetCharacterByUID(UID)
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "XSuitAvatarDataUtil:GetValidXSuitIconId uCharacter is not valid UID:" .. tostring(UID))
    return 0
  end
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local XSuitID = self:GetEquipXSuitID(uCharacter)
  local Period = XSuitUtil:GetPeriodByItemId(XSuitID)
  local UnLockLevel = self:GetUnlockLevel(UID, Period)
  local LowLevelEffect = require("GameLua.Activity.Commercialize.GamePlay.XSuit.LowLevelEffect")
  local bValid = XSuitUtil:IsValidXSuitEffect(XSuitID, LowLevelEffect.XSuitIconID, UnLockLevel)
  if not bValid then
    return 0
  end
  return Period
end
function XSuitAvatarDataUtil:GetCurrentWearGlideID(PlayerController)
  if not PlayerController or PlayerController.RolewearIndex >= PlayerController.InitialKnapsackExtInfo:Num() then
    print(bWriteLog and "XSuitAvatarDataUtil:GetCurrentWearGlideID RolewearIndex not Valid" .. tostring(PlayerController.RolewearIndex))
    return -1
  end
  local GlideID = PlayerController.InitialKnapsackExtInfo:Get(PlayerController.RolewearIndex).KnapsackExtInfo.ParachuteGlider
  print(bWriteLog and "XSuitAvatarDataUtil:GetCurrentWearGlideID " .. tostring(GlideID))
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  if LogicXSuit.IsXSuitGlide(GlideID) then
    local NormalGlideID = LogicXSuit.GetNormalGlideID(GlideID)
    local ClothID = LogicXSuit.GetLevel7XSuitID(NormalGlideID)
    local state2ItemClothID = XSuitUtil:ChangeItemIDByState(ClothID, 2)
    local bHasEquip = false
    local allwear = PlayerController:GetClothingInAllBackpack(PlayerController.RolewearIndex)
    for _, v in pairs(allwear) do
      print(bWriteLog and "XSuitAvatarDataUtil:GetCurrentWearGlideID v.DefineID.TypeSpecificID" .. tostring(v.DefineID.TypeSpecificID) .. " " .. tostring(ClothID))
      if v.DefineID.TypeSpecificID == ClothID or v.DefineID.TypeSpecificID == state2ItemClothID then
        print(bWriteLog and "XSuitAvatarDataUtil:GetCurrentWearGlideID bHasEquip v.DefineID.TypeSpecificID" .. tostring(v.DefineID.TypeSpecificID) .. " " .. tostring(ClothID))
        bHasEquip = true
        break
      end
    end
    if bHasEquip and XSuitUtil.IsUserOpenSpecialGlideSetting(PlayerController.UID, NormalGlideID) then
      GlideID = LogicXSuit.GetSpecialGlideID(NormalGlideID)
    else
      GlideID = NormalGlideID
    end
  end
  return GlideID
end
return XSuitAvatarDataUtil