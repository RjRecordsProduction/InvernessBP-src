local WeaponSystem = {}
local TableUtil = require("common.table_util")
local UAETableManager = import("UAETableManager")
local WeaponDefine = require("GameLua.GameCore.Module.Weapon.WeaponDefine")
local WeaponLibrary = require("GameLua.GameCore.Module.Weapon.WeaponLibrary")
local WeaponUtils = require("GameLua.Mod.BaseMod.GamePlay.Weapon.WeaponUtils")
local ENetRole = import("ENetRole")
function WeaponSystem:Init()
  print(bWriteLog and "WeaponSystem:Init")
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  self.WeaponConfigTable = GamePlayTools.GetCurrentConfig("WeaponConfig")
  self:InitWeaponUAETableWithCfg(self.WeaponConfigTable)
  print(bWriteLog and "WeaponSystem:Init2")
end
function WeaponSystem:InitWeaponAttrReloadTable(uGameState)
  if slua.isValid(uGameState) and uGameState.WeaponAttrReloadTableName then
    local CWeaponUtils = import("WeaponUtils")
    CWeaponUtils.InitialWeaponAttrReloadTable(uGameState.WeaponAttrReloadTableName)
  end
end
function WeaponSystem:InitScirptWeaponHandle(WeaponHandle)
  print(bWriteLog and "WeaponSystem:InitScirptWeaponHandle " .. tostring(WeaponHandle))
  local WeaponId = TableUtil.GetTableValue(WeaponHandle, "DefineID").TypeSpecificID
  local ItemHandleConfig = TableUtil.GetTableValue(self.WeaponConfigTable, WeaponId, WeaponDefine.ConfigKey.ItemHandle)
  local DefaultHandleConfig = TableUtil.GetTableValue(self.WeaponConfigTable, "Default", WeaponDefine.ConfigKey.ItemHandle)
  if not DefaultHandleConfig or not ItemHandleConfig then
    local AlarmTips = "WeaponSystem:InitScirptWeaponHandle Error " .. tostring(WeaponHandle) .. "--" .. tostring(WeaponId)
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SHOOT_VERTIFY_ALARM, 0, AlarmTips, WeaponHandle)
    print(bWriteLog and AlarmTips)
    return
  end
  local SkeletonMeshPath = ItemHandleConfig.SkeletonMesh or DefaultHandleConfig.SkeletonMesh
  local SkeletonMeshLodPath = ItemHandleConfig.SkeletonMeshLod or DefaultHandleConfig.SkeletonMeshLod
  local StaticMeshPath = ItemHandleConfig.StaticMesh or DefaultHandleConfig.StaticMesh
  local StaticMeshLodPath = ItemHandleConfig.StaticMeshLod or DefaultHandleConfig.StaticMeshLod
  local MeshMatPath = ItemHandleConfig.MeshMat or DefaultHandleConfig.MeshMat
  WeaponHandle:SetMesh(SkeletonMeshPath, SkeletonMeshLodPath, StaticMeshPath, StaticMeshLodPath, MeshMatPath)
  local WeaponClassPath = ItemHandleConfig.WeaponClass or DefaultHandleConfig.WeaponClass
  WeaponHandle.DynamicWeaponClass = slua.loadClass(WeaponClassPath)
  WeaponHandle.bIsPistol = ItemHandleConfig.IsPistol or false
  WeaponHandle.ItemAttrsFlag = ItemHandleConfig.ItemAttrsFlag or 0
  if ItemHandleConfig.WrapperClass and ItemHandleConfig.WrapperClass ~= "" then
    WeaponHandle.DynamicWrapperClass = slua.loadClass(ItemHandleConfig.WrapperClass)
  end
  local AnimationBPPath = ItemHandleConfig.AnimationBP or DefaultHandleConfig.AnimationBP
  WeaponHandle:SetAnimationBp(AnimationBPPath)
  local DefaultAttachmentIDs = TableUtil.GetTableValue(self.WeaponConfigTable, WeaponId, WeaponDefine.ConfigKey.Attachment, WeaponDefine.AttachmentType.Constant) or {}
  local DefaultAttachmentArray = slua.Array(UEnums.EPropertyClass.Int)
  for _, AttachmentID in pairs(DefaultAttachmentIDs) do
    DefaultAttachmentArray:Add(AttachmentID)
  end
  WeaponHandle.  self:InitWeaponUAETable(WeaponId)
end
function WeaponSystem:InitWeaponUAETableWithCfg(WeaponConfigTable)
  if not WeaponConfigTable then
    return
  end
  for WeaponId, WeaponConfig in pairs(WeaponConfigTable) do
    if WeaponConfig and not WeaponConfig[WeaponDefine.ConfigKey.SkipWeaponSystemInit] then
      self:InitWeaponUAETable(WeaponId)
    end
  end
end
function WeaponSystem:InitWeaponUAETable(WeaponId)
  if type(WeaponId) == "number" then
    self:InitWeaponScopeFovTable(WeaponId)
    self:InitWeaponAttachmentsTable(WeaponId)
  end
end
function WeaponSystem:InitWeaponScopeFovTable(WeaponId)
  print(bWriteLog and "WeaponSystem:InitWeaponScopeFovTable " .. tostring(WeaponId))
  local UAETable = UAETableManager.GetDataTableStatic("WeaponScopeFov")
  if not slua.isValid(UAETable) then
    return
  end
  local DefaultFovConfig = TableUtil.GetTableValue(self.WeaponConfigTable, "Default", WeaponDefine.ConfigKey.Fov) or {}
  local WeaponFovConfig = TableUtil.GetTableValue(self.WeaponConfigTable, WeaponId, WeaponDefine.ConfigKey.Fov) or {}
  local SetFovTable = function(ID)
    local FovValue = WeaponFovConfig[ID] or DefaultFovConfig[ID]
    if FovValue then
      local TableKey = tostring(ID) .. "_" .. tostring(WeaponId)
      local AddRowRet = UAETable:ConditionAddEmptyRow(TableKey)
      if AddRowRet or IsEditor then
        UAETable:SetTableData_String(TableKey, "ScopeGroupID", TableKey)
        UAETable:SetTableData_Float(TableKey, "ScopeFov_f", FovValue)
      end
    end
  end
  SetFovTable(0)
  local WeaponUpperAttachments = TableUtil.GetTableValue(self.WeaponConfigTable, WeaponId, WeaponDefine.ConfigKey.Attachment, WeaponDefine.AttachmentType.Upper) or {}
  for _, UpperID in pairs(WeaponUpperAttachments) do
    SetFovTable(UpperID)
  end
  local WeaponConstantAttachments = TableUtil.GetTableValue(self.WeaponConfigTable, WeaponId, WeaponDefine.ConfigKey.Attachment, WeaponDefine.AttachmentType.Constant) or {}
  for _, ConstantID in pairs(WeaponConstantAttachments) do
    SetFovTable(ConstantID)
  end
end
function WeaponSystem:InitWeaponAttachmentsTable(WeaponId)
  print(bWriteLog and "WeaponSystem:InitWeaponAttachmentsTable " .. tostring(WeaponId))
  local UAETable = UAETableManager.GetDataTableStatic("WeaponAttachments")
  if not slua.isValid(UAETable) then
    return
  end
  local WeaponAttachmentConfig = TableUtil.GetTableValue(self.WeaponConfigTable, WeaponId, WeaponDefine.ConfigKey.Attachment) or {}
  local TableKey = tostring(WeaponId)
  local AddRowRet = UAETable:ConditionAddEmptyRow(TableKey)
  if not AddRowRet and not IsEditor then
    return
  end
  for AttachmentKey, AttachmentTable in pairs(WeaponAttachmentConfig) do
    if AttachmentKey ~= WeaponDefine.AttachmentType.Constant then
      UAETable:SetTableData_Int32(TableKey, "KeyID", WeaponId)
      for Index, AttachmentID in pairs(AttachmentTable) do
        local TagName = WeaponDefine.AttachmentName[AttachmentKey] .. tostring(Index) .. "ID"
        UAETable:SetTableData_Int32(TableKey, TagName, AttachmentID)
        print(bWriteLog and "WeaponSystem:InitTableWeaponAttachments", TableKey, TagName, AttachmentID)
      end
    end
  end
  self:InitWeaponAttachmentsDataRow(WeaponId, WeaponAttachmentConfig)
end
function WeaponSystem:InitWeaponAttachmentsDataRow(WeaponId, WeaponAttachmentConfig)
  local WeaponAttachmentsDataRowStruct = import("WeaponAttachmentsDataRow")
  local AttachmentsDataRow = WeaponAttachmentsDataRowStruct()
  AttachmentsDataRow.WeaponID = WeaponId
  AttachmentsDataRow.MuzzleIDList = AddTableToTArray(WeaponAttachmentConfig[WeaponDefine.AttachmentType.Muzzle], AttachmentsDataRow.MuzzleIDList)
  AttachmentsDataRow.UpperIDList = AddTableToTArray(WeaponAttachmentConfig[WeaponDefine.AttachmentType.Upper], AttachmentsDataRow.UpperIDList)
  AttachmentsDataRow.StockIDList = AddTableToTArray(WeaponAttachmentConfig[WeaponDefine.AttachmentType.Stock], AttachmentsDataRow.StockIDList)
  AttachmentsDataRow.MagazineIDList = AddTableToTArray(WeaponAttachmentConfig[WeaponDefine.AttachmentType.Magazine], AttachmentsDataRow.MagazineIDList)
  AttachmentsDataRow.LowerIDList = AddTableToTArray(WeaponAttachmentConfig[WeaponDefine.AttachmentType.Lower], AttachmentsDataRow.LowerIDList)
  AttachmentsDataRow.UpperSideIDList = AddTableToTArray(WeaponAttachmentConfig[WeaponDefine.AttachmentType.UpperSide], AttachmentsDataRow.UpperSideIDList)
  local AvatarUtils = import("AvatarUtils")
  local AvatarBPUtils = AvatarUtils.GetBPUtils()
  AvatarBPUtils:RefreshWeaponAttachmentsTableRowMap(WeaponId, AttachmentsDataRow)
end
function WeaponSystem:HandleBeforeBeginPlay(uWeapon)
  print(bWriteLog and string.format("WeaponSystem:HandleBeforeBeginPlay: %s:", tostring(uWeapon)))
end
function WeaponSystem:InitWeapon(Weapon)
  print(bWriteLog and string.format("WeaponSystem:InitWeapon: %s:", tostring(Weapon)))
  if not slua.isValid(Weapon) then
    return
  end
  local WeaponId = Weapon:GetWeaponID() or 0
  if WeaponLibrary.IsScriptWeapon(WeaponId) then
    self:InitScirptWeapon(Weapon, WeaponId)
  end
end
function WeaponSystem:InitScirptWeapon(uWeapon, WeaponId)
  print(bWriteLog and string.format("WeaponSystem:InitScirptWeapon: %s:", tostring(uWeapon)))
  local WeaponEntityComp = slua.isValid(uWeapon) and uWeapon.WeaponEntityComp
  if slua.isValid(WeaponEntityComp) then
    WeaponEntityComp.WeaponID = WeaponId
  end
  if uWeapon.Role == ENetRole.ROLE_Authority then
    local WeaponConfigData = WeaponLibrary.GetWeaponConfig(WeaponId)
    local AttributeConfig = TableUtil.GetTableValue(WeaponLibrary.GetWeaponConfig(WeaponId), WeaponDefine.ConfigKey.Attribute)
    local Ret = WeaponUtils:AddAttrModifier(uWeapon, AttributeConfig)
    print(bWriteLog and string.format("WeaponSystem:InitScirptWeapon AddAttrModifier : %s, %s", tostring(uWeapon), tostring(Ret)))
  end
  if uWeapon.AfterInitScirptWeapon then
    uWeapon:AfterInitScirptWeapon()
  end
end
function WeaponSystem:PostInitWeapon(Weapon)
  print(bWriteLog and string.format("WeaponSystem:PostInitWeapon: %s:", tostring(Weapon)))
  if Weapon.ShootWeaponEntityComp and Weapon.CurMaxBulletNumInOneClip then
    Weapon.ShootWeaponEntityComp.MaxBulletNumInOneClip = Weapon.ShootWeaponEntityComp.MaxBulletNumInOneClip + Weapon.ShootWeaponEntityComp.ExtraBulletNumInOneClip
    if not Client then
      Weapon.CurMaxBulletNumInOneClip = Weapon.CurMaxBulletNumInOneClip + Weapon.ShootWeaponEntityComp.ExtraBulletNumInOneClip
    end
    print(bWriteLog and "WeaponSystem:InitAfterAttrModify", Weapon.CurMaxBulletNumInOneClip, Weapon.ShootWeaponEntityComp.ExtraBulletNumInOneClip)
  end
end
return WeaponSystem