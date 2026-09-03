local Logic_MultiShapeConst = require("client.slua.logic.wardrobe.Logic_MultiShapeConst")
local LogicMultiItemModule = {}
local ENUM_SHOWTYPE = {
  OnlyWardRobe = 1,
  None = 2,
  All = 3,
  UpLevel = 4,
  Coexist = 5
}
local _tWardrobeShowMultiTab = {
  [ENUM_SHOWTYPE.OnlyWardRobe] = true,
  [ENUM_SHOWTYPE.All] = true,
  [ENUM_SHOWTYPE.Coexist] = true
}
local _Enum_MultiShapeModuleID = Logic_MultiShapeConst.Enum_MultiShapeModuleID
function LogicMultiItemModule:DefineAndResetData()
  log(bWriteLog and "LogicMultiItemModule DefineAndResetData")
  self.LastSelectLevelList = {}
  self.DEFAULT_LEVEL = 1
  self.  self._bIsWardrobeMultiShapeTabUnlock = false
  self._tAllColorShapeGroupMap = nil
  self.CartoonStyleMap = nil
end
function LogicMultiItemModule:OnInitialize()
  self._bIsWardrobeMultiShapeTabUnlock = false
  log(bWriteLog and "LogicMultiItemModule OnInitialize")
end
function LogicMultiItemModule:RegistEvents()
  LogicMultiItemModule.__super.OnInitialize(self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_ADD_NEW, self.OnDepotAddNewItemEvent, self)
end
function LogicMultiItemModule:OnLogin(bReLogin)
  log(bWriteLog and "LogicMultiItemModule OnLogin bReLogin=" .. tostring(bReLogin))
  self:LoadLastSelectLevelList()
end
function LogicMultiItemModule:OnLogOut()
  log(bWriteLog and "LogicMultiItemModule OnLogOut")
  self:SavaLastSelectLevelList()
end
function LogicMultiItemModule:OnDepotAddNewItemEvent(_, _, tChangeList)
  for _, v in pairs(tChangeList) do
    self:IsLastSelectMultiLevel(v.res_id)
  end
end
function LogicMultiItemModule:IsMultiLevelItem(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  if not MultiLevelItemCfg then
    return false
  end
  return true
end
local hideSwitchLevelResIdTb = {
  [1410720] = 1,
  [1410752] = 1,
  [1410923] = 1,
  [1410945] = 1,
  [1407441] = 1,
  [1407459] = 1
}
function LogicMultiItemModule:IsWardRobeMultiLevelItemWithTab(ItemID)
  if self:IsWardRobeMultiLevelItem(ItemID) then
    return not hideSwitchLevelResIdTb[ItemID]
  end
end
function LogicMultiItemModule:IsWardRobeMultiLevelItem(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  local showType = MultiLevelItemCfg and MultiLevelItemCfg.ShowType
  if _tWardrobeShowMultiTab[showType] then
    return true
  end
end
function LogicMultiItemModule:IsStoreMultiLevelItem(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  if MultiLevelItemCfg and MultiLevelItemCfg.ShowType == self.ENUM_SHOWTYPE.All then
    return true
  end
  return false
end
function LogicMultiItemModule:IsPreviewMultiLevelItem(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  if MultiLevelItemCfg and MultiLevelItemCfg.ShowType == self.ENUM_SHOWTYPE.All then
    return true
  end
  return false
end
function LogicMultiItemModule:IsLastSelectMultiLevel(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  if not MultiLevelItemCfg then
    log_error(bWriteLog and "LogicMultiItemModule IsLastSelectMultiLevel MultiLevelItemCfg is nil ItemID " .. tostring(ItemID))
    return false
  end
  if not self.LastSelectLevelList[MultiLevelItemCfg.GroupID] then
    if MultiLevelItemCfg.ShowType == ENUM_SHOWTYPE.Coexist then
      self.LastSelectLevelList[MultiLevelItemCfg.GroupID] = MultiLevelItemCfg.Level
    else
      self.LastSelectLevelList[MultiLevelItemCfg.GroupID] = self.DEFAULT_LEVEL
    end
  end
  return self.LastSelectLevelList[MultiLevelItemCfg.GroupID] == MultiLevelItemCfg.Level
end
function LogicMultiItemModule:GetIsWardrobeMultiShapeTabUnlock()
  return self._bIsWardrobeMultiShapeTabUnlock
end
function LogicMultiItemModule:SetIsWardrobeMultiShapeTabUnlock(bIsTabUnlock)
  self._bIsWardrobeMultiShapeTabUnlock = bIsTabUnlock
end
function LogicMultiItemModule:CheckLowLevelHasOwn(ItemID, DataSource)
  local List = self:GetMultiListByItemID(ItemID)
  local level = self:GetMultiItemLevel(ItemID)
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, value in pairs(List) do
    if level > value.Level and value.ShowType ~= ENUM_SHOWTYPE.Coexist and not WardrobeDataManager:HasValidItem(value.ItemID, false, DataSource) then
      return false
    end
  end
  return true
end
function LogicMultiItemModule:GetDisPlayItemByGroup(GroupID, DataSource, ItemSubType)
  local List = CDataTable.GetTableByFilter("MultiLevelItem", "GroupID", GroupID)
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local ownItemList = {}
  local maxLevel = 0
  local type
  for _, value in pairs(List) do
    if WardrobeDataManager:HasValidItem(value.ItemID, false, DataSource) then
      ownItemList[value.Level] = value.ItemID
    end
    type = value.ShowType
    maxLevel = math.max(maxLevel, value.Level)
  end
  if type ~= ENUM_SHOWTYPE.Coexist then
    local maxOwnLevel = 0
    for i = 1, maxLevel do
      if ownItemList[i] then
        maxOwnLevel = i
      else
        break
      end
    end
    for i = maxOwnLevel + 1, maxLevel do
      ownItemList[i] = nil
    end
    maxLevel = maxOwnLevel
  end
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(ItemSubType)
  local bInFashionBagEditMode = wardrobeLogic:IsInFashionBagEditMode()
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  for _, v in pairs(ownItemList) do
    if bInFashionBagEditMode then
      if FashionBagEditUtils:IsItemInTryMap(v, true) then
        return v
      end
    elseif wearInfo and v == wearInfo.resID then
      return v
    end
  end
  for _, v in pairs(ownItemList) do
    if self:IsLastSelectMultiLevel(v) then
      return v
    end
  end
  return ownItemList[maxLevel]
end
function LogicMultiItemModule:CheckLevel2HasOwn(ItemID, DataSource)
  local List = self:GetMultiListByItemID(ItemID)
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, value in pairs(List) do
    if value.Level == 2 and WardrobeDataManager:HasValidItem(value.ItemID, false, DataSource) then
      return true
    end
  end
  return false
end
function LogicMultiItemModule:GetItemID(ItemID, Level)
  local List = self:GetMultiListByItemID(ItemID)
  for _, value in pairs(List) do
    if value.Level == Level then
      return value.ItemID
    end
  end
  return -1
end
function LogicMultiItemModule:LoadLastSelectLevelList()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local table = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardropbeLastSelectItemLevel)
  table = table or {}
  self.LastSelectLevelList = table
end
function LogicMultiItemModule:SavaLastSelectLevelList()
  log(bWriteLog and "LogicMultiItemModule SavaLastSelectLevelList")
  if not self.LastSelectLevelList or not next(self.LastSelectLevelList) then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local table = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardropbeLastSelectItemLevel) or {}
  for key, value in pairs(self.LastSelectLevelList) do
    table[key] = value
  end
  PlayerPrefsSystem.SaveTableToFile_N(table, PlayerPrefsSystem.ePlayerPrefsType.eWardropbeLastSelectItemLevel)
end
function LogicMultiItemModule:GetMultiItemLevel(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  if not MultiLevelItemCfg then
    return -1
  end
  return MultiLevelItemCfg.Level
end
function LogicMultiItemModule:CheckIsHeightLevelItem(nItemId)
  local uObj_MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", nItemId)
  if not uObj_MultiLevelItemCfg then
    return false
  end
  if uObj_MultiLevelItemCfg.ShowType == ENUM_SHOWTYPE.Coexist then
    return false
  end
  return uObj_MultiLevelItemCfg.Level > 1
end
function LogicMultiItemModule:GetMultiItemGroup(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  if not MultiLevelItemCfg then
    return -1
  end
  return MultiLevelItemCfg.GroupID
end
function LogicMultiItemModule:GetMultiItemIDByGroupIDAndLevelID(nItemID, nLevelID)
  local nGroupID = self:GetMultiItemGroup(nItemID)
  local MultiLevelItemCfg = CDataTable.GetTableDataByFilter("MultiLevelItem", "GroupID", nGroupID, "Level", nLevelID)
  if not MultiLevelItemCfg then
    return nItemID
  end
  return MultiLevelItemCfg.ItemID
end
function LogicMultiItemModule:GetMultiItemGroupCurSelectItemId(nItemID)
  local nGroupID = self:GetMultiItemGroup(nItemID)
  if nGroupID == -1 then
    return nItemID
  end
  local tLastSelectLevelList = self.LastSelectLevelList
  local nSelectLevel = tLastSelectLevelList and tLastSelectLevelList[nGroupID]
  if not nSelectLevel then
    local uObj_allMultiShapeCfg = CDataTable.GetTableByFilter("MultiLevelItem", "GroupID", nGroupID)
    for _, uObj_cfg in pairs(uObj_allMultiShapeCfg) do
      if AvatarData.CheckIsWearItemId(uObj_cfg.ItemID) then
        return uObj_cfg.ItemID, uObj_cfg.Level
      end
    end
    return nItemID, self.DEFAULT_LEVEL
  end
  local uObj_multiItemCfg = CDataTable.GetTableDataByFilter("MultiLevelItem", "GroupID", nGroupID, "Level", nSelectLevel)
  if uObj_multiItemCfg then
    return uObj_multiItemCfg.ItemID, nSelectLevel
  end
  return nItemID, nSelectLevel
end
function LogicMultiItemModule:GetMultiListByItemID(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  if not MultiLevelItemCfg then
    return {}
  end
  local MultiLevelItemGroupCfg = CDataTable.GetTableByFilter("MultiLevelItem", "GroupID", MultiLevelItemCfg.GroupID)
  return MultiLevelItemGroupCfg
end
function LogicMultiItemModule:isSameGroupMultiItem(ItemID1, ItemID2)
  local MultiLevelItemCfg1 = CDataTable.GetTableData("MultiLevelItem", ItemID1)
  local MultiLevelItemCfg2 = CDataTable.GetTableData("MultiLevelItem", ItemID2)
  if not MultiLevelItemCfg1 or not MultiLevelItemCfg2 then
    return false
  end
  local Show1 = MultiLevelItemCfg1.ShowType
  local Show2 = MultiLevelItemCfg2.ShowType
  if Show1 ~= Show2 or not _tWardrobeShowMultiTab[Show1] then
    return false
  end
  if MultiLevelItemCfg1.GroupID == MultiLevelItemCfg2.GroupID then
    return true
  end
  return false
end
function LogicMultiItemModule:UpdateSelectMultiItem(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  if not MultiLevelItemCfg then
    return
  end
  self.LastSelectLevelList[MultiLevelItemCfg.GroupID] = MultiLevelItemCfg.Level
  self:SavaLastSelectLevelList()
end
function LogicMultiItemModule:ClearMultiItemSelectShapeCache(nItemId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if wardrobe_data:HasValidItem(nItemId) then
    return
  end
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", nItemId)
  if not MultiLevelItemCfg then
    return
  end
  if self.LastSelectLevelList[MultiLevelItemCfg.GroupID] == MultiLevelItemCfg.Level then
    self.LastSelectLevelList[MultiLevelItemCfg.GroupID] = nil
  end
  self:SavaLastSelectLevelList()
end
function LogicMultiItemModule:ShowUnlockJumpTips(ItemID, AttachWidget)
  local TipsID = self:GetUnlockTips(ItemID)
  if not TipsID then
    log(bWriteLog and "[WardrobeMultiItem] LogicMultiItemModule:ShowUnlockJumpTips not Tips ItemID:" .. tostring(ItemID))
    return
  end
  if not slua.isValid(AttachWidget) then
    log_error("LogicMultiItemModule:ShowUnlockJumpTips AttachWidget is not Valid")
  end
  local JumpText = LocUtil.GetLocalizeResStr(64208)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local JumpConfigTable = ItemUpgradeMgr:GetItemJumpTypeIDList(ItemID)
  if not JumpConfigTable or not next(JumpConfigTable) then
    log(bWriteLog and "[WardrobeMultiItem] LogicMultiItemModule:ShowTips not jumpConfig ItemID" .. tostring(ItemID))
    JumpText = nil
  end
  local JumpTo = function()
    GlobalData.JumpByTypeID(ItemID, JumpConfigTable[1])
  end
  local TipsParam = {
    widget = AttachWidget,
    content = LocUtil.GetLocalizeResStr(TipsID),
    jumpText = JumpText,
    jumpCallback = JumpTo,
    offsetY = 70
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, TipsParam)
end
function LogicMultiItemModule:GetUnlockTips(ItemID)
  local CollectTipsConfig = CDataTable.GetTableData("CollectTipsConfig", ItemID)
  if not CollectTipsConfig then
    return
  end
  return CollectTipsConfig.UnlockTipsID
end
function LogicMultiItemModule:IsUpgradeItem(ItemID)
  local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
  if MultiLevelItemCfg and MultiLevelItemCfg.ShowType == self.ENUM_SHOWTYPE.UpLevel then
    return true
  end
  return false
end
function LogicMultiItemModule:LoadCartoonStyleMap()
  self.CartoonStyleMap = {}
  local CartoonStyleCfg = CDataTable.GetTable("CartoonStyleCfg")
  for _, v in pairs(CartoonStyleCfg) do
    self.CartoonStyleMap[v.BaseID] = v
    self.CartoonStyleMap[v.CartoonStyleID] = v
  end
end
function LogicMultiItemModule:GetCartoonStyleCfg(ItemID)
  if not self.CartoonStyleMap then
    self:LoadCartoonStyleMap()
  end
  return self.CartoonStyleMap[ItemID]
end
function LogicMultiItemModule:ChangeCartoonStyle(uObject)
  local lobbyPawn = uObject:GetOwningActor()
  if not slua.isValid(lobbyPawn) then
    log(bWriteLog and "LogicMultiItemModule:ChangeCartoonStyle lobbyPawn is invalid")
    return
  end
  local uAvatarComp2 = lobbyPawn.CharacterAvatarComp2_BP
  if not slua.isValid(uAvatarComp2) then
    log(bWriteLog and "LogicMultiItemModule:ChangeCartoonStyle uAvatarComp2 is invalid")
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  log(bWriteLog and "LogicMultiItemModule:ChangeCartoonStyle TypeSpecificID = " .. tostring(AvatarItem.TypeSpecificID))
  local Cfg = LogicMultiItemModule:GetCartoonStyleCfg(AvatarItem.TypeSpecificID)
  if not Cfg then
    return
  end
  if AvatarItem.TypeSpecificID == Cfg.BaseID then
    lobbyPawn:PutOnEquipmentByResID(Cfg.CartoonStyleID)
  else
    lobbyPawn:PutOnEquipmentByResID(Cfg.BaseID)
  end
end
function LogicMultiItemModule:isSameGroupCartoonStyle(ItemA, ItemB)
  if not self.CartoonStyleMap then
    self:LoadCartoonStyleMap()
  end
  if self.CartoonStyleMap[ItemA] and self.CartoonStyleMap[ItemB] then
    return self.CartoonStyleMap[ItemA].BaseID == self.CartoonStyleMap[ItemB].BaseID
  end
  return false
end
function LogicMultiItemModule:GetMultiItemNum(ItemID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local Num = 0
  local List = self:GetMultiListByItemID(ItemID)
  for _, value in pairs(List) do
    Num = Num + WardrobeData:GetHallDepotItemCountByResID(value.ItemID)
  end
  return Num
end
function LogicMultiItemModule:GetMultiItemNumForever(ItemID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local Num = 0
  local List = self:GetMultiListByItemID(ItemID)
  for _, value in pairs(List) do
    if WardrobeData:HasItem(value.ItemID, true) then
      Num = Num + 1
    end
  end
  return Num
end
function LogicMultiItemModule:InitAllColorShapeData()
  local tAllColorShapeGroupMap = {}
  local MultiLevelItemCfg = CDataTable.GetTableByFilter("MultiLevelItem", "ModuleID", _Enum_MultiShapeModuleID.ColorShape)
  for _, v in pairs(MultiLevelItemCfg) do
    if not tAllColorShapeGroupMap[v.GroupID] then
      tAllColorShapeGroupMap[v.GroupID] = {}
    end
    table.insert(tAllColorShapeGroupMap[v.GroupID], v.ItemID)
  end
  self._end
function LogicMultiItemModule:GetAllUnlockableData()
  if not self._tAllColorShapeGroupMap then
    self:InitAllColorShapeData()
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tAllUnlockableData = {}
  for _, tGroup in pairs(self._tAllColorShapeGroupMap) do
    local bHaveOwned = false
    local bHaveNotOwned = false
    local tAllNotOwned = {}
    for _, v in pairs(tGroup) do
      if wardrobe_data:CheckHasPermanentItem(v) then
        bHaveOwned = true
      else
        bHaveNotOwned = true
        table.insert(tAllNotOwned, v)
      end
    end
    if bHaveOwned and bHaveNotOwned then
      for _, v in pairs(tAllNotOwned) do
        table.insert(tAllUnlockableData, v)
      end
    end
  end
  return tAllUnlockableData
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicMultiItemModule = class(CModuleBase, nil, LogicMultiItemModule)
return CLogicMultiItemModule