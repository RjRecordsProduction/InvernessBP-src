local CustomVirtualItemSubsystem = {}
local UAETableManager = import("UAETableManager")
function CustomVirtualItemSubsystem:ctor()
  self.VirtualItemInfoMap = {}
  self.UnMappingWrapperItemID = {}
end
function CustomVirtualItemSubsystem:OnInit()
  CustomVirtualItemSubsystem.__super.OnInit(self)
end
function CustomVirtualItemSubsystem:InsertItem(TableInfo, WrapperInfo, HandleInfo, BluePrintInfo)
  local bCheckTable = self:CheckTableInfo(TableInfo)
  if not bCheckTable and (not Client or not IsEditor) then
    print(bWriteLog and "CustomVirtualItemSubsystem:InsertItem invalid TableInfo")
    return false
  end
  local BPTableName = self:GetBPTableName(TableInfo.Item.ItemType)
  if not BPTableName then
    return false
  end
  local ItemID = TableInfo.Item.ItemID
  local BPID = TableInfo.Item.BPID
  local ItemTable = CDataTable.GetTable("Item")
  ItemTable[ItemID] = TableInfo.Item
  local BPTable = CDataTable.GetTable(BPTableName)
  BPTable[BPID] = TableInfo[BPTableName]
  if TableInfo.ItemAttrs then
    local ItemAttrsTable = CDataTable.GetTable("ItemAttrs")
    local AttrsID = TableInfo.ItemAttrs.Id
    ItemAttrsTable[AttrsID] = TableInfo.ItemAttrs
  end
  local UBackpackUtils = import("BackpackUtils")
  local BPUtils = UBackpackUtils.GetBPUtils()
  if slua.isValid(BPUtils) then
    if BPUtils.ItemID2AttrsFlagTableMap and BPUtils.ItemID2AttrsFlagTableMap:Get(ItemID) then
      BPUtils.ItemID2AttrsFlagTableMap:Remove(ItemID)
    end
    if BPUtils.ItemID2AttrsFlagMap and BPUtils.ItemID2AttrsFlagMap:Get(ItemID) then
      BPUtils.ItemID2AttrsFlagMap:Remove(ItemID)
    end
  end
  self.VirtualItemInfoMap[ItemID] = {
    TableInfo = TableInfo,
    BPTableName = BPTableName,
    WrapperInfo = WrapperInfo,
    HandleInfo = HandleInfo,
      }
  if BluePrintInfo and BluePrintInfo.TemplateItemID then
    self:InsertWeaponItem(ItemID, BPID, BluePrintInfo)
  end
  print(bWriteLog and "CustomVirtualItemSubsystem:InsertItem " .. tostring(ItemID))
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CUSTOMVIRTUALITEM_INSERT, ItemID)
  return true
end
function CustomVirtualItemSubsystem:DeleteItem(nItemID)
  if not self.VirtualItemInfoMap[nItemID] then
    return false
  end
  local BPTableName = self.VirtualItemInfoMap[nItemID].BPTableName
  local BPID = self.VirtualItemInfoMap[nItemID].TableInfo.Item.BPID
  local ItemTable = CDataTable.GetTable("Item")
  ItemTable[nItemID] = nil
  local BPTable = CDataTable.GetTable(BPTableName)
  BPTable[BPID] = nil
  local ItemAttrsTable = CDataTable.GetTable("ItemAttrs")
  ItemAttrsTable[nItemID] = nil
  self.VirtualItemInfoMap[nItemID] = nil
  print(bWriteLog and "CustomVirtualItemSubsystem:DeleteItem " .. tostring(nItemID))
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CUSTOMVIRTUALITEM_DELETE, nItemID)
  return true
end
function CustomVirtualItemSubsystem:InsertWeaponItem(nItemID, nBPID, BluePrintInfo)
  local TemplateItemID = BluePrintInfo.TemplateItemID
  print(bWriteLog and "CustomVirtualItemSubsystem:InsertWeaponItem " .. tostring(nItemID) .. tostring(TemplateItemID))
  local UAETable = UAETableManager.GetDataTableStatic("WeaponReuseCfgTable")
  if not slua.isValid(UAETable) then
    return
  end
  local AddRowRet = UAETable:ConditionAddEmptyRow(nItemID)
  if not AddRowRet and not IsEditor then
    return
  end
  if BluePrintInfo.WeaponReuseCfgTable then
    UAETable:SetTableData_Int32(nItemID, "WeaponID", nItemID)
    UAETable:SetTableData_Int32(nItemID, "WeaponBPID", nBPID)
    UAETable:SetTableData_Int32(nItemID, "ReuseFovID", BluePrintInfo.WeaponReuseCfgTable.ReuseFovID and BluePrintInfo.WeaponReuseCfgTable.ReuseFovID or 0)
    UAETable:SetTableData_Int32(nItemID, "ReuseSupportBulletID", BluePrintInfo.WeaponReuseCfgTable.ReuseSupportBulletID and BluePrintInfo.WeaponReuseCfgTable.ReuseSupportBulletID or 0)
    UAETable:SetTableData_Int32(nItemID, "ReuseSupportAttachID", BluePrintInfo.WeaponReuseCfgTable.ReuseSupportAttachID and BluePrintInfo.WeaponReuseCfgTable.ReuseSupportAttachID or 0)
    UAETable:SetTableData_Int32(nItemID, "ReuseAttachMeshID", BluePrintInfo.WeaponReuseCfgTable.ReuseAttachMeshID and BluePrintInfo.WeaponReuseCfgTable.ReuseAttachMeshID or 0)
    UAETable:SetTableData_Int32(nItemID, "ReuseDefaultAttachID", BluePrintInfo.WeaponReuseCfgTable.ReuseDefaultAttachID and BluePrintInfo.WeaponReuseCfgTable.ReuseDefaultAttachID or 0)
    UAETable:SetTableData_Int32(nItemID, "ReuseAvatarID", BluePrintInfo.WeaponReuseCfgTable.ReuseAvatarID and BluePrintInfo.WeaponReuseCfgTable.ReuseAvatarID or 0)
    UAETable:SetTableData_Int32(nItemID, "SensibilitySettingID", BluePrintInfo.WeaponReuseCfgTable.SensibilitySettingID and BluePrintInfo.WeaponReuseCfgTable.SensibilitySettingID or 0)
  else
    UAETable:SetTableData_Int32(nItemID, "WeaponID", nItemID)
    UAETable:SetTableData_Int32(nItemID, "WeaponBPID", nBPID)
    UAETable:SetTableData_Int32(nItemID, "ReuseFovID", TemplateItemID)
    UAETable:SetTableData_Int32(nItemID, "ReuseSupportBulletID", TemplateItemID)
    UAETable:SetTableData_Int32(nItemID, "ReuseSupportAttachID", TemplateItemID)
    UAETable:SetTableData_Int32(nItemID, "ReuseAttachMeshID", TemplateItemID)
    UAETable:SetTableData_Int32(nItemID, "ReuseDefaultAttachID", TemplateItemID)
    UAETable:SetTableData_Int32(nItemID, "ReuseAvatarID", TemplateItemID)
    UAETable:SetTableData_Int32(nItemID, "SensibilitySettingID", TemplateItemID)
  end
  local AvatarUtils = import("AvatarUtils")
  local AvatarBPUtils = AvatarUtils.GetBPUtils()
  AvatarBPUtils:InitWeaponReuseCfgTable()
end
function CustomVirtualItemSubsystem:CheckTableInfo(TableInfo)
  if not TableInfo then
    return
  end
  if not (TableInfo.Item and TableInfo.Item.ItemID) or not TableInfo.Item.ItemType then
    return false
  end
  if TableInfo.Item and TableInfo.Item.ItemID and TableInfo.Item.ItemID > 0 and CDataTable.IsTableDataExist("Item", TableInfo.Item.ItemID) then
    return false
  end
  local BPTableName = self:GetBPTableName(TableInfo.Item.ItemType)
  if not (BPTableName and TableInfo[BPTableName]) or not TableInfo[BPTableName].ID and not TableInfo[BPTableName].ItemID then
    return false
  end
  if TableInfo.Item.BPID ~= TableInfo[BPTableName].ID and TableInfo.Item.BPID ~= TableInfo[BPTableName].ID then
    return false
  end
  if CDataTable.IsTableDataExist(BPTableName, TableInfo.Item.BPID) then
    return false
  end
  if TableInfo.ItemAttrs then
    if TableInfo.ItemAttrs.Id ~= TableInfo.Item.ItemID then
      return false
    end
    if CDataTable.IsTableDataExist("ItemAttrs", TableInfo.ItemAttrs.Id) then
      return false
    end
  end
  return true
end
function CustomVirtualItemSubsystem:DeleteAllItem()
  local TableUtil = require("common.table_util")
  local tItemIDs = TableUtil.GetKeys(self.VirtualItemInfoMap)
  for _, nItemID in ipairs(tItemIDs) do
    self:DeleteItem(nItemID)
  end
  print(bWriteLog and "CustomVirtualItemSubsystem:DeleteAllItem")
  return true
end
function CustomVirtualItemSubsystem:GetHandleInfo(nItemID)
  if self.VirtualItemInfoMap[nItemID] then
    return self.VirtualItemInfoMap[nItemID].HandleInfo
  end
  return nil
end
function CustomVirtualItemSubsystem:GetWrapperInfo(nItemID)
  if nItemID == nil then
    return nil
  end
  if self.VirtualItemInfoMap[nItemID] then
    return self.VirtualItemInfoMap[nItemID].WrapperInfo
  end
  print(bWriteLog and "CustomVirtualItemSubsystem:GetWrapperInfo UnMapping:" .. tostring(nItemID))
  return nil
end
function CustomVirtualItemSubsystem:GetBluePrintInfo(nItemID)
  if nItemID == nil then
    return nil
  end
  if self.VirtualItemInfoMap[nItemID] then
    return self.VirtualItemInfoMap[nItemID].BluePrintInfo
  end
  print(bWriteLog and "CustomVirtualItemSubsystem:GetBluePrintInfo UnMapping:" .. tostring(nItemID))
  return nil
end
function CustomVirtualItemSubsystem:GetBPTableName(ItemType)
  local UAELoadedClassManager = import("UAELoadedClassManager").Get()
  if not UAELoadedClassManager then
    return
  end
  local BPTableTypeName = UAELoadedClassManager:GetBPTableName(ItemType)
  local RealBPTableName = UAELoadedClassManager.BPTableName2TableName:Get(BPTableTypeName)
  if RealBPTableName then
    return RealBPTableName
  end
  return
end
function CustomVirtualItemSubsystem:IsExistVirtualItem(nItemID)
  return self.VirtualItemInfoMap[nItemID] ~= nil
end
function CustomVirtualItemSubsystem:SpawnVirtualWrapper(nItemID, uLoc, uRot, nCount)
  if not CGameWorld or not self:IsExistVirtualItem(nItemID) then
    return false
  end
  local UBackpackUtils = import("BackpackUtils")
  local DefineID = UBackpackUtils.GenerateItemDefineIDByItemTableIDWithRandomInstanceID(nItemID)
  local WrapperClass = UBackpackUtils.GetWrapperActorClass(DefineID)
  if not slua.isValid(WrapperClass) then
    return false
  end
  local UGameplayStatics = import("GameplayStatics")
  local SpawnTransform = FTransform(uRot, uLoc, FVector(1, 1, 1))
  local uWrapperActor = UGameplayStatics.BeginDeferredActorSpawnFromClass(CGameWorld, WrapperClass, SpawnTransform, UEnums.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil)
  if not slua.isValid(uWrapperActor) then
    return false
  end
  uWrapperActor.  UGameplayStatics.FinishSpawningActor(uWrapperActor, SpawnTransform)
  uWrapperActor:SetCountOnServerAfterSpawn(nCount)
  return true
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, CustomVirtualItemSubsystem)