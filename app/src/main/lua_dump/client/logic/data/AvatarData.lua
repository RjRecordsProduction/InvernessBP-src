AvatarData = {OpenTimeTracer = false}
local _tRoleWear = {}
local _tRoleCommonSubtypeWear = {}
function AvatarData.GetGameGender()
  return DataMgr.avatarData.gamegender
end
function AvatarData.SetGameGender(Gender)
  local PreGender = DataMgr.avatarData.gamegender
  DataMgr.avatarData.gamegender = Gender
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
  if DataMgr.avatarData.gamegender ~= PreGender then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_GAME_GENDER_CHANGE)
  end
end
function AvatarData.GetHeadID()
  return DataMgr.avatarData.headid
end
function AvatarData.SetHeadID(HeadID)
  DataMgr.avatarData.headid = HeadID
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
end
function AvatarData.GetHairID()
  return DataMgr.avatarData.hairid
end
function AvatarData.SetHairID(HairID)
  DataMgr.avatarData.hairid = HairID
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
end
function AvatarData.GetBeardID()
  return DataMgr.avatarData.beardid
end
function AvatarData.SetBeardID(BeardID)
  DataMgr.avatarData.beardid = BeardID
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
end
function AvatarData.GetBeardColorID()
  return DataMgr.avatarData.beardcolorid
end
function AvatarData.SetBeardColorID(BeardColorID)
  DataMgr.avatarData.beardcolorid = BeardColorID
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
end
function AvatarData.GetRoleWear()
  return _tRoleWear
end
function AvatarData.SetRoleWear(tRoleWear)
  _  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
end
function AvatarData.SetAttrInfo(slot, data)
  DataMgr.avatarData.attr_info[slot] = data
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
end
function AvatarData.AddRoleWearData(nWearInsId, nIndex)
  nIndex = nIndex or #_tRoleWear + 1
  _tRoleWear[nIndex] = nWearInsId
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
end
function AvatarData.RemoveRoleWearDataByIndex(nRemoveIndex)
  table.remove(_tRoleWear, nRemoveIndex)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
end
function AvatarData.RemoveRoleWearDataByValue(nRemoveValue)
  for k, v in pairs(_tRoleWear) do
    if v == nRemoveValue then
      table.remove(_tRoleWear, k)
      EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
      break
    end
  end
end
function AvatarData.CheckWearItem(InsID)
  local tRoleWear = AvatarData.GetRoleWear()
  for _, v in pairs(tRoleWear) do
    if v == InsID then
      return true
    end
  end
  return false
end
function AvatarData.CheckIsWearItemId(nItemId)
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local tRoleWear = AvatarData.GetRoleWear()
  for _, v in pairs(tRoleWear) do
    local tItemData = wardrobeData:GetHallDepotItemDataByInsID(v)
    if tItemData and nItemId == tItemData.resID then
      return true
    end
  end
  return false
end
function AvatarData.SetCommonSubtypeWearData(data)
  log_tree(bWriteLog and "AvatarData.SetCommonSubtypeWearData data", data)
  _tRoleCommonSubtypeWear = data
end
function AvatarData.GetCommonSubtypeWearData()
  return _tRoleCommonSubtypeWear
end
function AvatarData.UpdateCommonSubtypeWearData(itemSubType, instId, bPutOn)
  log(bWriteLog and string.format("AvatarData.UpdateCommonSubtypeWearData, itemSubType:%s", itemSubType))
  log(bWriteLog and string.format("AvatarData.UpdateCommonSubtypeWearData, instId:%s", instId))
  log(bWriteLog and string.format("AvatarData.UpdateCommonSubtypeWearData, bPutOn:%s", bPutOn))
  local typeCfg = CDataTable.GetTableData("ThemeSkinItemTypeConfig", itemSubType)
  if typeCfg and typeCfg.DataType == "map" then
    if not _tRoleCommonSubtypeWear[itemSubType] then
      _tRoleCommonSubtypeWear[itemSubType] = {}
    end
    if bPutOn then
      _tRoleCommonSubtypeWear[itemSubType][instId] = true
    else
      _tRoleCommonSubtypeWear[itemSubType][instId] = 0
    end
  elseif bPutOn then
    _tRoleCommonSubtypeWear[itemSubType] = instId
  else
    _tRoleCommonSubtypeWear[itemSubType] = 0
  end
end
function AvatarData.CheckIsCommonSubtypeWearItemId(nItemId)
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local tItemData = wardrobeData:GetAllHallDepotItemDataByResID(nItemId)
  if not tItemData then
    return false
  end
  local tRoleCommonSubtypeWear = AvatarData.GetCommonSubtypeWearData()
  local typeCfg = CDataTable.GetTableData("ThemeSkinItemTypeConfig", tItemData.itemSubType)
  if typeCfg and typeCfg.DataType == "map" then
    return tRoleCommonSubtypeWear[tItemData.itemSubType] and tRoleCommonSubtypeWear[tItemData.itemSubType][tonumber(tItemData.insID)] == true
  else
    return tRoleCommonSubtypeWear[tItemData.itemSubType] and tRoleCommonSubtypeWear[tItemData.itemSubType] == tonumber(tItemData.insID)
  end
end
function AvatarData.CheckIsCommonSubtypeWearValidItemId(nItemId)
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local tItemData = wardrobeData:GetHallDepotItemDataByResIDAndValidExpireTime(nItemId)
  if not tItemData then
    return false
  end
  local tRoleCommonSubtypeWear = AvatarData.GetCommonSubtypeWearData()
  local typeCfg = CDataTable.GetTableData("ThemeSkinItemTypeConfig", tItemData.itemSubType)
  if typeCfg and typeCfg.DataType == "map" then
    return tRoleCommonSubtypeWear[tItemData.itemSubType] and tRoleCommonSubtypeWear[tItemData.itemSubType][tonumber(tItemData.insID)] == true
  else
    return tRoleCommonSubtypeWear[tItemData.itemSubType] and tRoleCommonSubtypeWear[tItemData.itemSubType] == tonumber(tItemData.insID)
  end
end
function AvatarData.CreateAvatarCustom(resID, colorID, patternID, tShapeInfo)
  local tAvatarCustom = {
    ItemID = resID or 0,
    ColorID = colorID,
    PatternID = patternID,
    ShapeInfo = tShapeInfo
  }
  return tAvatarCustom
end
function AvatarData.GetWearInfo(IgnoreOpen)
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local wearingInfo = {}
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local tRoleWear = AvatarData.GetRoleWear()
  for k, v in pairs(tRoleWear) do
    local tItemData = wardrobeData:GetHallDepotItemDataByInsID(v)
    if tItemData then
      local temp = AvatarData.GetItemWearInfo(v, tItemData)
      if not IgnoreOpen and ModelDisplayTypeHelper.IsGloves(tItemData.itemType, tItemData.itemSubType) then
        if logic_display_setting.IsOpenLobbyHandDisplay() then
          table.insert(wearingInfo, temp)
        end
      else
        table.insert(wearingInfo, temp)
      end
    end
  end
  return wearingInfo
end
function AvatarData.GetItemWearInfo(InsID, tWardrobeItemData)
  local nItemId = tWardrobeItemData.resID
  local nColorId = tWardrobeItemData.colorID
  local nPatternID = tWardrobeItemData.patternID
  local temp = AvatarData.CreateAvatarCustom(nItemId, nColorId, nPatternID)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsXSuit(nItemId) then
    temp.ItemID = LogicXSuit.GetItemShowID(InsID)
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local shapeInfo = logic_suit_multi_shape:GetSuitShapeID(DataMgr.roleData.uid, nItemId)
  if shapeInfo then
    temp.ShapeInfo = shapeInfo
  end
  return temp
end
function AvatarData.ConvertToAvatarCustom(tServerWearInfo, bIsIgnore)
  if type(tServerWearInfo) ~= "table" then
    return AvatarData.CreateAvatarCustom(0, 0, 0)
  end
  local nItemId = tServerWearInfo[ENUM_AVATAR_DATA_TYPE.ItemID]
  local nColorId = tServerWearInfo[ENUM_AVATAR_DATA_TYPE.ColorID]
  local nPatternID = tServerWearInfo[ENUM_AVATAR_DATA_TYPE.PatternID]
  local ShapeInfo = tServerWearInfo[ENUM_AVATAR_DATA_TYPE.ShapeInfo]
  local tAvatarCustom = AvatarData.CreateAvatarCustom(nItemId, nColorId, nPatternID, ShapeInfo)
  if type(tAvatarCustom.ShapeInfo) ~= "number" then
    tAvatarCustom.ShapeInfo = nil
  end
  if bIsIgnore then
    return tAvatarCustom
  end
  if type(tAvatarCustom.ColorID) ~= "number" then
    tAvatarCustom.ColorID = 0
  end
  if type(tAvatarCustom.PatternID) ~= "number" then
    tAvatarCustom.PatternID = 0
  end
  return tAvatarCustom
end
function AvatarData.HashTableToAvatarCustom(tTable)
  local nItemId = tTable.resID or tTable.itemID
  return AvatarData.CreateAvatarCustom(nItemId, tTable.colorID, tTable.patternID)
end
function AvatarData.BeardTableToAvatarCustom(tBeardTable)
  return AvatarData.CreateAvatarCustom(tBeardTable.beardid, tBeardTable.beardcolorid)
end
function AvatarData.CreateEnumFormatAvatarCustom(resID, colorID, patternID, tShapeInfo)
  local   local tAvatarCustom = {
    [ENUM_AVATAR_DATA_TYPE.ItemID] = resID or 0,
    [ENUM_AVATAR_DATA_TYPE.ColorID] = colorID,
    [ENUM_AVATAR_DATA_TYPE.PatternID] = patternID,
    [ENUM_AVATAR_DATA_TYPE.ShapeInfo] = tShapeInfo
  }
  return tAvatarCustom
end
function AvatarData.GetAllWearInfoEnumFormat(IgnoreOpen)
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local wearingInfo = {}
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local tRoleWear = AvatarData.GetRoleWear()
  for _, v in pairs(tRoleWear) do
    local tItemData = wardrobeData:GetHallDepotItemDataByInsID(v)
    if tItemData then
      local temp = AvatarData.GetItemWearInfoEnumFormat(v, tItemData)
      if not IgnoreOpen and ModelDisplayTypeHelper.IsGloves(tItemData.itemType, tItemData.itemSubType) then
        if logic_display_setting.IsOpenLobbyHandDisplay() then
          table.insert(wearingInfo, temp)
        end
      else
        table.insert(wearingInfo, temp)
      end
    end
  end
  return wearingInfo
end
function AvatarData.GetItemWearInfoEnumFormat(InsID, tWardrobeItemData)
  local nItemId = tWardrobeItemData.resID
  local nColorId = tWardrobeItemData.colorID
  local nPatternID = tWardrobeItemData.patternID
  local temp = AvatarData.CreateEnumFormatAvatarCustom(nItemId, nColorId, nPatternID)
  local   local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsXSuit(nItemId) then
    temp[ENUM_AVATAR_DATA_TYPE.ItemID] = LogicXSuit.GetItemShowID(InsID)
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local shapeInfo = logic_suit_multi_shape:GetSuitShapeID(DataMgr.roleData.uid, nItemId)
  if shapeInfo then
    temp[ENUM_AVATAR_DATA_TYPE.ShapeInfo] = shapeInfo
  end
  return temp
end
if Client and Client.IsDevelopment() then
  AvatarData.OpenTimeTracer = true
else
  AvatarData.OpenTimeTracer = false
end
return AvatarData