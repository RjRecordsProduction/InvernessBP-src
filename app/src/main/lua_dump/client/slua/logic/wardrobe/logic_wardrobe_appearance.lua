local WardrobeAppearanceLogic = {
  AppearanceType = {
    Head = 1,
    Hair = 2,
    HairColor = 3,
    Gender = 4,
    Beard = 5,
    BeardColor = 6,
    UnderCloth = 7,
    UnderPants = 8
  },
  AppearanceMap = nil,
  TryAvatarMap = nil,
  TakeOffEquipMap = nil,
  AvatarTableCacheData = nil
}
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local SubTabString = wardrobe_macro.ENUM_WardrobeSubTabString
local UpdateModelDisplaySubTab = {
  [SubTabString.Enum_WardrobeSubTabString_SpecialVehicle] = true,
  [SubTabString.ENUM_WardrobeSubTabString_effect] = true
}
function WardrobeAppearanceLogic:TakeOffMakeUp()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if not myAvatar then
    return
  end
  local headShow = self:GetHeadShow()
  local tRoleWear = AvatarData.GetRoleWear()
  for _, insId in pairs(tRoleWear) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insId)
    if itemData and itemData.resID and itemData.itemType and itemData.itemSubType then
      local itemType, itemSubType = itemData.itemType, itemData.itemSubType
      if ModelDisplayTypeHelper.IsGlasses(itemType, itemSubType) or ModelDisplayTypeHelper.IsMask(itemType, itemSubType) then
        table.insert(self.TakeOffEquipMap, itemData)
        log(bWriteLog and "WardrobeAppearanceLogic:TakeOffMakeUp Glasses " .. tostring(itemData.resID))
        myAvatar:PutoffEquipment(itemData.resID)
      elseif ModelDisplayTypeHelper.IsHat(itemType, itemSubType) then
        if headShow == insId then
          table.insert(self.TakeOffEquipMap, 1, itemData)
        else
          table.insert(self.TakeOffEquipMap, itemData)
        end
        log(bWriteLog and "WardrobeAppearanceLogic:TakeOffMakeUp Hat " .. tostring(itemData.resID))
        myAvatar:PutoffEquipment(itemData.resID)
      end
    end
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(nUseWearBagIndex)
  for itemSubType, insId in pairs(DataMgr.equipmentSkinInsIDTable) do
    if insId ~= 0 then
      local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insId)
      if itemData and itemData.resID and itemData.itemType and itemData.itemSubType and (ModelDisplayTypeHelper.IsHelmet(itemData.itemType, itemSubType) or ModelDisplayTypeHelper.IsNoLevelHelmet(itemData.itemType, itemSubType)) then
        local resId = itemData.resID
        if bagInfo and bagInfo.helmet_level then
          resId = DataMgr.GetEquipmentItemIDByResID(bagInfo.helmet_level, resId)
        end
        if headShow == insId then
          table.insert(self.TakeOffEquipMap, itemData)
        end
        log(bWriteLog and "WardrobeAppearanceLogic:TakeOffMakeUp Helmet " .. tostring(itemData.resID))
        myAvatar:PutoffEquipment(resId)
      end
    end
  end
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  logic_display_setting.TrapIntoState(logic_display_setting.Enum_TrappedState.AppearanceTrapped)
end
function WardrobeAppearanceLogic:TakeOnMakeUp()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if not myAvatar then
    return
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(nUseWearBagIndex)
  for _, itemData in pairs(self.TakeOffEquipMap) do
    local resId = itemData.resID
    local bTakeOn = true
    if ModelDisplayTypeHelper.IsHelmet(itemData.itemType, itemData.itemSubType) or ModelDisplayTypeHelper.IsNoLevelHelmet(itemData.itemType, itemData.itemSubType) then
      local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
      if not logic_display_setting.ShowHelmet() then
        bTakeOn = false
      elseif bagInfo and bagInfo.helmet_level then
        resId = DataMgr.GetEquipmentItemIDByResID(bagInfo.helmet_level, resId)
      end
    end
    if bTakeOn and DataMgr.IsValidTime(itemData.expireTS) then
      myAvatar:PutonEquipment(resId)
    end
  end
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  logic_display_setting.TrapIntoState()
  self.TakeOffEquipMap = {}
end
function WardrobeAppearanceLogic:GetHeadShow()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local headShow = fashionbag_data:GetHeadShow()
  if headShow ~= 0 then
    return headShow
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tRoleWear = AvatarData.GetRoleWear()
  for _, insId in pairs(tRoleWear) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insId)
    if itemData and itemData.resID and itemData.itemType and itemData.itemSubType and ModelDisplayTypeHelper.IsHat(itemData.itemType, itemData.itemSubType) then
      return tonumber(insId)
    end
  end
  for itemSubType, insId in pairs(DataMgr.equipmentSkinInsIDTable) do
    if insId ~= 0 then
      local itemData = wardrobe_data:GetHallDepotItemDataByInsID(tonumber(insId))
      if itemData and itemData.resID and itemData.itemType and itemData.itemSubType and (ModelDisplayTypeHelper.IsHelmet(itemData.itemType, itemSubType) or ModelDisplayTypeHelper.IsNoLevelHelmet(itemData.itemType, itemSubType)) then
        return tonumber(insId)
      end
    end
  end
  return 0
end
function WardrobeAppearanceLogic:Init()
  self.AppearanceMap = self:GetUserDataMap()
  self.TryAvatarMap = {}
  self.TakeOffEquipMap = {}
  self.UserDataMap = self.AppearanceMap
end
function WardrobeAppearanceLogic:GetUserDataMap()
  local Map = {}
  local headAvatarData = CDataTable.GetTableDataByFilter("AvatarInit", "BodyID", AvatarData.GetHeadID())
  if headAvatarData then
    Map.headId = headAvatarData.id
  end
  local hairId = AvatarData.GetHairID()
  local data = hairId % (BP_ENUM_AVATAR_HAIR * 100000)
  local hairColor = math.floor(data / 1000)
  local hairType = data % 1000
  local hairAvatarData = CDataTable.GetTableDataByFilter("AvatarInit", "Hair", tostring(hairType))
  if hairAvatarData then
    Map.hairId = hairAvatarData.id
  end
  local hairColorAvatarData = CDataTable.GetTableDataByFilter("AvatarInit", "HairColor", hairColor)
  if hairColorAvatarData then
    Map.hairColorId = hairColorAvatarData.id
  end
  local beardAvatarData
  log(bWriteLog and "WardrobeAppearanceLogic AvatarData.GetBeardID() " .. tostring(AvatarData.GetBeardID()))
  if AvatarData.GetBeardID() == 0 then
    beardAvatarData = CDataTable.GetTableDataByFilter("AvatarInit", "BeardType", 1, "BodyID", AvatarData.GetBeardID())
  else
    beardAvatarData = CDataTable.GetTableDataByFilter("AvatarInit", "BodyID", AvatarData.GetBeardID())
  end
  if beardAvatarData then
    Map.beardId = beardAvatarData.id
    log(bWriteLog and "WardrobeAppearanceLogic AvatarData.GetBeardID() " .. tostring(beardAvatarData.BodyID) .. "AvatarData.GetBeardColorID()" .. tostring(AvatarData.GetBeardColorID()))
    local beardColorId
    if beardAvatarData.BodyID == 0 then
      beardColorId = 1
    elseif AvatarData.GetBeardColorID() == 0 then
      beardColorId = 1
    else
      beardColorId = AvatarData.GetBeardColorID()
    end
    local beardColorAvatarData = CDataTable.GetTableDataByFilter("AvatarInit", "BeardColor", beardColorId)
    if beardColorAvatarData then
      Map.beardColorId = beardColorAvatarData.id
    end
  end
  if DataMgr.avatarData.attr_info then
    Map.underClothId = self:GetUnderWearAvatarID(DataMgr.avatarData.attr_info[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_UNDERCLOTH])
    Map.underPantsId = self:GetUnderWearAvatarID(DataMgr.avatarData.attr_info[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_UNDERPANTS])
  end
  return Map
end
function WardrobeAppearanceLogic:DeInit()
  self.AppearanceMap = nil
  self.TryAvatarMap = nil
  self.TakeOffEquipMap = nil
  self.UserDataMap = nil
end
function WardrobeAppearanceLogic:GetAppearanceItems(appearanceType)
  if not appearanceType then
    return {}
  end
  local data = self:GetAvatarInitTableData(appearanceType)
  local avatarList = {}
  for _, v in pairs(data) do
    local avatarData = self:GenerateAvatarData(v)
    table.insert(avatarList, avatarData)
  end
  table.sort(avatarList, function(a, b)
    return a.Sort < b.Sort
  end)
  return avatarList
end
function WardrobeAppearanceLogic:GetAvatarInitTableData(appearanceType)
  if self.AvatarTableCacheData and self.AvatarTableCacheData[appearanceType] then
    return self.AvatarTableCacheData[appearanceType]
  end
  local data = CDataTable.GetTableByFilter("AvatarInit", "AvatarType", appearanceType)
  self.AvatarTableCacheData = self.AvatarTableCacheData or {}
  self.AvatarTableCacheData[appearanceType] = data
  return data
end
function WardrobeAppearanceLogic:GetAppearanceEquipData(appearanceType)
  if not appearanceType then
    return nil
  end
  local avatarId = self:GetAppearanceEquipAvatarId(appearanceType)
  return self:GetAvatarDataById(avatarId)
end
function WardrobeAppearanceLogic:HasEquipItemView(appearanceType, AvatarID)
  local EquipAvatarId = self:GetAppearanceEquipAvatarId(appearanceType)
  return AvatarID == EquipAvatarId
end
function WardrobeAppearanceLogic:GetAppearanceEquipAvatarId(appearanceType)
  return self:_GetEquipAvatarID(appearanceType, self.AppearanceMap)
end
function WardrobeAppearanceLogic:_GetEquipAvatarID(appearanceType, Map)
  if appearanceType == self.AppearanceType.Head then
    return Map.headId
  elseif appearanceType == self.AppearanceType.Hair then
    return Map.hairId
  elseif appearanceType == self.AppearanceType.HairColor then
    return Map.hairColorId
  elseif appearanceType == self.AppearanceType.Beard then
    return Map.beardId
  elseif appearanceType == self.AppearanceType.BeardColor then
    return Map.beardColorId
  elseif appearanceType == self.AppearanceType.UnderCloth then
    return Map.underClothId
  elseif appearanceType == self.AppearanceType.UnderPants then
    return Map.underPantsId
  end
end
function WardrobeAppearanceLogic:HasEquipItemData(appearanceType, AvatarID)
  local EquipAvatarId = self:_GetEquipAvatarID(appearanceType, self.UserDataMap)
  return AvatarID == EquipAvatarId
end
function WardrobeAppearanceLogic:SwitchGender()
  local curGender = AvatarData.GetGameGender()
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local switchGender = curGender == LobbyAvatarManager.Enum_Sex.Male and LobbyAvatarManager.Enum_Sex.Female or LobbyAvatarManager.Enum_Sex.Male
  local genderData = CDataTable.GetTableDataByFilter("AvatarInit", "Sex", switchGender)
  if genderData and genderData.id then
    WardrobeAppearanceLogic:PutAvatar(genderData.id, self.AppearanceType.Gender)
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    logic_wardrobe:SetTriggerPutOn(true)
  end
end
function WardrobeAppearanceLogic:PutAvatar(avatarId, appearanceType, bPutOn)
  self:RestoreToOrigin()
  local nPutOn = 1
  if bPutOn == false then
    nPutOn = 0
  end
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_batch_buy_avatar_features_req({
    [avatarId] = nPutOn
  })
end
function WardrobeAppearanceLogic:TryOnAvatar(appearanceType, avatar_id)
  if not appearanceType or not avatar_id then
    return
  end
  local tryAvatarData = self:GetAvatarDataById(avatar_id)
  if not self.TryAvatarMap[appearanceType] then
    local curEquipAvatarId = self:GetAppearanceEquipAvatarId(appearanceType)
    self.TryAvatarMap[appearanceType] = curEquipAvatarId
  end
  self:ModifyAvatar(appearanceType, tryAvatarData, true)
end
function WardrobeAppearanceLogic:RestoreToOrigin()
  if not self.TryAvatarMap or not next(self.TryAvatarMap) then
    return
  end
  local handle = {}
  for type, avatarId in pairs(self.TryAvatarMap) do
    if type == self.AppearanceType.HairColor or type == self.AppearanceType.BeardColor then
      table.insert(handle, 1, {Type = type, AvatarId = avatarId})
    else
      table.insert(handle, {Type = type, AvatarId = avatarId})
    end
  end
  self.TryAvatarMap = {}
  for _, handleData in pairs(handle) do
    local avatarData = self:GetAvatarDataById(handleData.AvatarId)
    self:ModifyAvatar(handleData.Type, avatarData, true, true)
  end
end
function WardrobeAppearanceLogic:TryOffAvatar()
  if not self.TryAvatarMap or not next(self.TryAvatarMap) then
    return
  end
  local keyWords = {
    [self.AppearanceType.Head] = "headId",
    [self.AppearanceType.Hair] = "hairId",
    [self.AppearanceType.HairColor] = "hairColorId",
    [self.AppearanceType.Beard] = "beardId",
    [self.AppearanceType.BeardColor] = "beardColorId"
  }
  for type, avatarId in pairs(self.TryAvatarMap) do
    local keyWord = keyWords[type]
    self.AppearanceMap[keyWord] = avatarId
  end
  self.TryAvatarMap = {}
end
function WardrobeAppearanceLogic:UpdateAvatarCallback(avatar_list, req_list)
  if not avatar_list or not next(avatar_list) then
    return
  end
  local modifyType, modifyAvatarData
  for k, _ in pairs(avatar_list) do
    local avatar = self:GetAvatarDataById(k)
    if not avatar then
      return
    end
    modifyType = avatar.AvatarType
    modifyAvatarData = avatar
    modifyAvatarData.PutOnState = req_list and req_list[k]
  end
  self:ModifyAvatar(modifyType, modifyAvatarData, false)
end
function WardrobeAppearanceLogic:ModifyAvatar(modifyType, modifyAvatarData, bTry, bTryOff)
  if not modifyType or not modifyAvatarData then
    return
  end
  if not self.AppearanceMap then
    self.AppearanceMap = {}
  end
  local ModifyTypeFunc = {
    [self.AppearanceType.Head] = self.ModifyHeadAvatar,
    [self.AppearanceType.Hair] = self.ModifyHairAvatar,
    [self.AppearanceType.HairColor] = self.ModifyHairColorAvatar,
    [self.AppearanceType.Beard] = self.ModifyBeardAvatar,
    [self.AppearanceType.BeardColor] = self.ModifyBeardColorAvatar,
    [self.AppearanceType.Gender] = self.ModifyGenderAvatar,
    [self.AppearanceType.UnderCloth] = self.ModifyUnderClothAvatar,
    [self.AppearanceType.UnderPants] = self.ModifyUnderPantsAvatar
  }
  if ModifyTypeFunc[modifyType] then
    log(bWriteLog and string.format("WardrobeAppearanceLogic:ModifyAvatar. modifyType=%s AvatarId=%s", tostring(modifyType), tostring(modifyAvatarData.AvatarId)))
    local func = ModifyTypeFunc[modifyType]
    func(self, modifyAvatarData, bTry, bTryOff)
  end
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe:SetTriggerPutOn(true)
  if modifyType == self.AppearanceType.Gender then
    return
  end
  self.UserDataMap = self:GetUserDataMap()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_APPEARANCE)
end
function WardrobeAppearanceLogic:ModifyHeadAvatar(modifyAvatarData, bTry, bTryOff)
  local headItemId = modifyAvatarData.ItemId
  if not bTry then
    AvatarData.SetHeadID(headItemId)
  end
  self.AppearanceMap.headId = modifyAvatarData.AvatarId
  self:PutOnAvatar(headItemId)
end
function WardrobeAppearanceLogic:ModifyHairAvatar(modifyAvatarData, bTry, bTryOff)
  local hairColor = 1
  local hairColorData = self:GetAvatarDataById(self.AppearanceMap.hairColorId)
  if hairColorData then
    hairColor = hairColorData.HairColor
  end
  local hairType = modifyAvatarData.Hair
  local putId = tonumber(string.format("%s%02s%03s", BP_ENUM_AVATAR_HAIR, hairColor, hairType), 10)
  if not bTry then
    AvatarData.SetHairID(putId)
  end
  self.AppearanceMap.hairId = modifyAvatarData.AvatarId
  self:PutOnAvatar(putId)
end
function WardrobeAppearanceLogic:ModifyHairColorAvatar(modifyAvatarData, bTry, bTryOff)
  local hairId = AvatarData.GetHairID()
  local data = hairId % (BP_ENUM_AVATAR_HAIR * 100000)
  local hairColor = modifyAvatarData.HairColor
  local hairType = data % 1000
  if bTry and not bTryOff then
    local tryHairAvatarId = self.AppearanceMap.hairId
    local tryAvatarData = self:GetAvatarDataById(tryHairAvatarId)
    if tryAvatarData and tryAvatarData.Hair then
      hairType = tryAvatarData.Hair
    end
  end
  local putId = tonumber(string.format("%s%02s%03s", BP_ENUM_AVATAR_HAIR, hairColor, hairType), 10)
  if not bTry then
    AvatarData.SetHairID(putId)
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    logic_wardrobe:SetTriggerPutOn(true)
  end
  self.AppearanceMap.hairColorId = modifyAvatarData.AvatarId
  self:PutOnAvatar(putId)
end
function WardrobeAppearanceLogic:ModifyBeardAvatar(modifyAvatarData, bTry, bTryOff)
  local preAvatarId = self.AppearanceMap.beardId
  local preAvatarData = self:GetAvatarDataById(preAvatarId)
  local beardItemId = modifyAvatarData.ItemId
  local beardColor = 0
  if not bTry then
    AvatarData.SetBeardID(beardItemId)
  end
  self.AppearanceMap.beardId = modifyAvatarData.AvatarId
  local beardColorAvatarData = self:GetAvatarDataById(self.AppearanceMap.beardColorId)
  if beardColorAvatarData then
    beardColor = beardColorAvatarData.BeardColor
  end
  if beardItemId == 0 then
    if preAvatarData then
      self:PutOffAvatar(preAvatarData.ItemId)
    end
  else
    self:PutOnAvatar(beardItemId, beardColor)
  end
end
function WardrobeAppearanceLogic:ModifyBeardColorAvatar(modifyAvatarData, bTry, bTryOff)
  local beardColor = modifyAvatarData.BeardColor
  local beardId = AvatarData.GetBeardID()
  local beardAvatarId = self.AppearanceMap.beardId
  local beardAvatarData = self:GetAvatarDataById(beardAvatarId)
  if bTry and not bTryOff then
    beardId = beardAvatarData.ItemId
  end
  if not bTry then
    AvatarData.SetBeardColorID(beardColor)
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    logic_wardrobe:SetTriggerPutOn(true)
  end
  self.AppearanceMap.beardColorId = modifyAvatarData.AvatarId
  self:PutOnAvatar(beardId, beardColor)
end
function WardrobeAppearanceLogic:ModifyGenderAvatar(modifyAvatarData, bTry, bTryOff)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local genderTextId = 200042
  if modifyAvatarData.Gender == LobbyAvatarManager.Enum_Sex.Female then
    genderTextId = 200043
  end
  AvatarData.SetGameGender(modifyAvatarData.Gender)
  self.AppearanceMap.gender = modifyAvatarData.Gender
  ShowNotice(LocUtil.LocalizeResFormat(69103, LocUtil.GetLocalizeResStr(genderTextId)))
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  myAvatar:SwitchSexAndHeadAndHair(AvatarData.GetGameGender(), AvatarData.GetHeadID(), AvatarData.GetHairID())
  if modifyAvatarData.Gender == LobbyAvatarManager.Enum_Sex.Male then
    self:PutOnAvatar(AvatarData.GetBeardID(), AvatarData.GetBeardColorID())
  end
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local pageId = logic_wardrobe.GetCurrentPageId()
  local tabId = logic_wardrobe.GetCurrentTabId()
  if wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Appearance == pageId then
    local bKeepSubTab = tabId ~= wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_Beard
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_PAGE, bKeepSubTab)
  elseif wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute == pageId then
    if not UpdateModelDisplaySubTab[tabId] then
      return
    end
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    local myAvatar = ModelDisplayer.GetShowingAvatar()
    myAvatar:SwitchSexAndHeadAndHair(AvatarData.GetGameGender(), AvatarData.GetHeadID(), AvatarData.GetHairID())
    local EAvatarSlotType = import("EAvatarSlotType")
    local SuitID = myAvatar:GetModel():GetEquipmentInfoBySlot(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
    if SuitID then
      local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
      local ShapeID = logic_suit_multi_shape:GetSelfSuitShapeID(SuitID) or 0
      myAvatar:HandleShapeInfo(SuitID, ShapeID)
    end
  end
end
function WardrobeAppearanceLogic:ModifyUnderClothAvatar(modifyAvatarData, bTry, bTryOff)
  if modifyAvatarData.PutOnState and modifyAvatarData.PutOnState == 0 then
    AvatarData.SetAttrInfo(ENUM_AVATAR_SHOW_TYPE.SHOW_POS_UNDERCLOTH, {
      [1] = 0,
      [2] = 0
    })
    self.AppearanceMap.underClothId = nil
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    local myAvatar = TeamAvatarManager.GetMainAvatar()
    if myAvatar then
      local EAvatarSlotType = import("EAvatarSlotType")
      myAvatar:GetModel():PutOffEquipmentBySlot(EAvatarSlotType.EAvatarSlotType_UnderClothSlot)
    end
  else
    AvatarData.SetAttrInfo(ENUM_AVATAR_SHOW_TYPE.SHOW_POS_UNDERCLOTH, {
      [1] = modifyAvatarData.ItemId,
      [2] = modifyAvatarData.ColorID
    })
    self.AppearanceMap.underClothId = modifyAvatarData.AvatarId
    self:PutOnAvatar(modifyAvatarData.ItemId, modifyAvatarData.ColorID)
  end
end
function WardrobeAppearanceLogic:ModifyUnderPantsAvatar(modifyAvatarData, bTry, bTryOff)
  if modifyAvatarData.PutOnState and modifyAvatarData.PutOnState == 0 then
    AvatarData.SetAttrInfo(ENUM_AVATAR_SHOW_TYPE.SHOW_POS_UNDERPANTS, {
      [1] = 0,
      [2] = 0
    })
    self.AppearanceMap.underPantsId = nil
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    local myAvatar = TeamAvatarManager.GetMainAvatar()
    if myAvatar then
      local EAvatarSlotType = import("EAvatarSlotType")
      myAvatar:GetModel():PutOffEquipmentBySlot(EAvatarSlotType.EAvatarSlotType_UnderPantsSlot)
    end
  else
    AvatarData.SetAttrInfo(ENUM_AVATAR_SHOW_TYPE.SHOW_POS_UNDERPANTS, {
      [1] = modifyAvatarData.ItemId,
      [2] = modifyAvatarData.ColorID
    })
    self.AppearanceMap.underPantsId = modifyAvatarData.AvatarId
    self:PutOnAvatar(modifyAvatarData.ItemId, modifyAvatarData.ColorID)
  end
end
function WardrobeAppearanceLogic:IsRealEquip(appearanceType, avatarId)
  if not appearanceType or not avatarId then
    return false
  end
  local avatarData = self:GetAvatarDataById(avatarId)
  if not avatarData then
    return false
  end
  if not self.TryAvatarMap or not self.TryAvatarMap[appearanceType] then
    return false
  end
  local equipId = self.TryAvatarMap[appearanceType]
  return avatarData.AvatarId == equipId and avatarData.Owned
end
function WardrobeAppearanceLogic:PutOnAvatar(resId, colorId)
  if not resId then
    return
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if myAvatar then
    local tAvatarCustom = AvatarData.CreateAvatarCustom(resId, colorId)
    myAvatar:PutonEquipment(resId, tAvatarCustom)
  end
end
function WardrobeAppearanceLogic:PutOffAvatar(resId)
  if not resId then
    return
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if myAvatar then
    myAvatar:PutoffEquipment(resId)
  end
end
function WardrobeAppearanceLogic:GetAvatarDataByKey(keyword, key)
  if not key or not keyword then
    return nil
  end
  local result
  local originData = CDataTable.GetTableDataByFilter("AvatarInit", keyword, key)
  if originData then
    result = self:GenerateAvatarData(originData)
  end
  return result
end
function WardrobeAppearanceLogic:GetAvatarDataById(avatarId)
  if not avatarId then
    return nil
  end
  local result
  local originData = CDataTable.GetTableData("AvatarInit", avatarId)
  if originData then
    result = self:GenerateAvatarData(originData)
  end
  return result
end
function WardrobeAppearanceLogic:GenerateAvatarData(originData)
  local result = {
    AvatarId = originData.id,
    AvatarName = originData.AvatarName,
    AvatarIcon = originData.AvatarIcon,
    FemaleAvatarIcon = originData.FemaleAvatarIcon,
    AvatarType = originData.AvatarType,
    Head = tonumber(originData.Race),
    Hair = tonumber(originData.Hair),
    HairColor = originData.HairColor,
    Gender = originData.Sex,
    Beard = originData.BeardType,
    BeardColor = originData.BeardColor,
    ItemId = originData.BodyID,
    Sort = originData.Sort,
    ForeverCost = originData.ForeverCost,
    ColorID = originData.ColorID,
    UnderWearID = originData.UnderWearID,
    RoyalePassSeason = originData.RoyalePassSeason
  }
  local remainTime = DataMgr.GetAvatarRemainTime(result.AvatarId)
  if 0 <= remainTime then
    result.RemainTime = remainTime
  elseif result.ForeverCost > 0 or result.RoyalePassSeason > 0 then
    result.RemainTime = remainTime
  else
    result.RemainTime = 0
  end
  result.Owned = 0 <= result.RemainTime
  return result
end
function WardrobeAppearanceLogic:GetUnderWearAvatarID(avatarData)
  if not avatarData or not next(avatarData) then
    return
  end
  local ItemID = avatarData[ENUM_AVATAR_DATA_TYPE.ItemID]
  local ColorID = avatarData[ENUM_AVATAR_DATA_TYPE.ColorID]
  if not ItemID then
    return
  end
  local TableData = CDataTable.GetTableDataByFilter("AvatarInit", "ColorID", ColorID, "BodyID", ItemID)
  if not TableData then
    return
  end
  return TableData.id
end
function WardrobeAppearanceLogic:GetAvatarIdByBodyID(ItemID)
  local tItemTableData = CDataTable.GetTableDataByFilter("AvatarInit", "BodyID", ItemID)
  if not tItemTableData then
    return
  end
  return tItemTableData.id
end
return WardrobeAppearanceLogic