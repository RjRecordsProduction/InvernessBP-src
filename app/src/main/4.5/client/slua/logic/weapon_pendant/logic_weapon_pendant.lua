local logic_weapon_pendant = {}
function logic_weapon_pendant:DefineAndResetData()
  self.Data = {}
  self.EquipData = {}
  self.bGetEquipData = false
  self.CONST = {DEFAULT_SOCKET = 1, UNEQUIP_SOCKET = 0}
  self.DownloadMark = {}
end
function logic_weapon_pendant:_OnDownloadFinish(_, _, eventData)
  if not eventData then
    return
  end
  local itemID = eventData.itemID
  if itemID and self.DownloadMark[itemID] then
    log(bWriteLog and "logic_weapon_pendant:_OnDownloadFinish .. itemID = " .. tostring(itemID))
  else
    return
  end
  for _, v in pairs(self.DownloadMark[itemID]) do
    log(bWriteLog and "logic_weapon_pendant:_OnDownloadFinish notify " .. tostring(v.UID) .. "  " .. tostring(v.groupID))
    EventSystem:postEvent(EVENTTYPE_WEAPON_PENDANT, EVENTID_WEAPON_PENDANT_DATA_UPDATE, v.UID, v.groupID)
  end
  self.DownloadMark[itemID] = nil
end
function logic_weapon_pendant:MarkDownload(UID, groupID, weaponPendantID)
  log(bWriteLog and string.format("logic_weapon_pendant:MarkDownload UID=%s  groupID=%s  weaponPendantID=%s", tostring(UID), tostring(groupID), tostring(weaponPendantID)))
  if not self.DownloadMark[weaponPendantID] then
    self.DownloadMark[weaponPendantID] = {}
  end
  for _, v in pairs(self.DownloadMark[weaponPendantID]) do
    if v.UID == UID and v.groupID == groupID then
      return
    end
  end
  table.insert(self.DownloadMark[weaponPendantID], {UID = UID, groupID = groupID})
end
function logic_weapon_pendant:OnInitialize()
end
function logic_weapon_pendant:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self._OnDownloadFinish, self)
end
function logic_weapon_pendant:OnLogOut()
  self.Data = {}
  self.EquipData = {}
  self.bGetEquipData = false
end
function logic_weapon_pendant:GetWeaponPendantBySkinID(UID, skinID, socketID)
  if not UID or not skinID then
    log(bWriteLog and "logic_weapon_pendant:GetPendantBySkinID" .. tostring(UID) .. tostring(skinID))
    return 0
  end
  if not self:CanSkinWithPendant(skinID) then
    return 0
  end
  local groupID = self:GetGroupIDBySkinID(skinID)
  return self:GetWeaponPendantByGroupID(UID, groupID, socketID)
end
function logic_weapon_pendant:GetWeaponPendantByGroupID(UID, groupID, socketID)
  if not (UID and groupID) or groupID == 0 then
    log(bWriteLog and "logic_weapon_pendant:GetPendantByGroupID" .. tostring(UID) .. tostring(groupID))
    return 0
  end
  socketID = socketID or self.CONST.DEFAULT_SOCKET
  UID = tostring(UID)
  if UID == tostring(DataMgr.roleData.uid) and not self.bGetEquipData then
    log(bWriteLog and "logic_weapon_pendant:GetWeaponPendantByGroupID not EquipData")
    self:GetAllEquipPendant()
    return 0
  end
  if self.Data and self.Data[UID] and self.Data[UID][groupID] then
    for pendantID, socket in pairs(self.Data[UID][groupID]) do
      if socket == socketID then
        return self:GetWeaponPendantByBackPack(pendantID)
      end
    end
  end
  return 0
end
function logic_weapon_pendant:GetPendantInsBySkinID(skinID)
  if not self.bGetEquipData then
    log(bWriteLog and "logic_weapon_pendant:GetPendantInsBySkinID not EquipData")
    self:GetAllEquipPendant()
    return 0
  end
  local groupID = self:GetGroupIDBySkinID(skinID)
  if groupID == 0 then
    return 0
  end
  if self.EquipData[groupID] then
    return self.EquipData[groupID][self.CONST.DEFAULT_SOCKET] or 0
  end
  return 0
end
function logic_weapon_pendant:CanSkinWithPendant(skinID)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local itemUpgradeCfg = ItemUpgradeMgr:GetUpgradeCfg(skinID)
  if itemUpgradeCfg and itemUpgradeCfg.IsPendant then
    return itemUpgradeCfg.IsPendant == 1
  end
  return false
end
function logic_weapon_pendant:IsWeaponPendant(resID)
  return self:GetWeaponPendantByBackPack(resID) ~= 0
end
function logic_weapon_pendant:SetPendantData(UID, groupID, pendantID, socketID)
  log(bWriteLog and string.format("logic_weapon_pendant:SetPendantData  %s %s %s %s", tostring(UID), tostring(groupID), tostring(pendantID), tostring(socketID)))
  if not (UID and groupID and pendantID) or not socketID then
    log(bWriteLog and "logic_weapon_pendant:SetPendantData no input")
    return
  end
  UID = tostring(UID)
  if not self.Data[UID] then
    self.Data[UID] = {}
  end
  if not self.Data[UID][groupID] then
    self.Data[UID][groupID] = {}
  end
  if socketID == self.CONST.UNEQUIP_SOCKET then
    self.Data[UID][groupID][pendantID] = nil
  else
    self.Data[UID][groupID] = {}
    self.Data[UID][groupID][pendantID] = socketID
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_PENDANT, EVENTID_WEAPON_PENDANT_DATA_UPDATE, UID, groupID)
end
function logic_weapon_pendant:UpdatePendantData(UID, Data)
  log(bWriteLog and "logic_weapon_pendant:UpdatePendantData" .. tostring(UID))
  if not UID or not Data then
    log(bWriteLog and "logic_weapon_pendant:UpdatePendantData no input")
    return
  end
  UID = tostring(UID)
  for skinID, pendantList in pairs(Data) do
    local groupID = self:GetGroupIDBySkinID(skinID)
    if groupID ~= 0 then
      if self.Data[UID] and self.Data[UID][groupID] then
        for pendantID, _ in pairs(self.Data[UID][groupID]) do
          self:SetPendantData(UID, groupID, pendantID, self.CONST.UNEQUIP_SOCKET)
        end
      end
      for socket, pendant in pairs(pendantList) do
        self:SetPendantData(UID, groupID, pendant, socket)
      end
    end
  end
end
function logic_weapon_pendant:UpdateAllPendantData(UID, Data)
  log(bWriteLog and string.format("logic_weapon_pendant:SetPendantData  %s", tostring(UID)))
  if not UID then
    log(bWriteLog and "logic_weapon_pendant:SetPendantData no input")
    return
  end
  UID = tostring(UID)
  if not self.Data[UID] and not Data then
    return
  end
  local diffList = {}
  local oldData = self.Data[UID] or {}
  local newData = {}
  if Data then
    for skinID, pendantList in pairs(Data) do
      local groupID = self:GetGroupIDBySkinID(skinID)
      if groupID ~= 0 then
        newData[groupID] = {}
        for socket, pendant in pairs(pendantList) do
          newData[groupID][pendant] = socket
        end
      end
    end
  end
  for groupID, _ in pairs(oldData) do
    if not newData[groupID] then
      table.insert(diffList, groupID)
    end
  end
  for groupID, _ in pairs(newData) do
    if not oldData[groupID] then
      table.insert(diffList, groupID)
    elseif #oldData[groupID] ~= #newData[groupID] then
      table.insert(diffList, groupID)
    elseif oldData[groupID][self.CONST.DEFAULT_SOCKET] ~= newData[groupID][self.CONST.DEFAULT_SOCKET] then
      table.insert(diffList, groupID)
    end
  end
  self.Data[UID] = Data and newData or nil
  for groupID, _ in pairs(diffList) do
    EventSystem:postEvent(EVENTTYPE_WEAPON_PENDANT, EVENTID_WEAPON_PENDANT_DATA_UPDATE, UID, groupID)
  end
end
function logic_weapon_pendant:GetGroupIDBySkinID(skinID)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local itemUpgradeCfg = ItemUpgradeMgr:GetUpgradeCfg(skinID)
  local groupID = itemUpgradeCfg and itemUpgradeCfg.GroupID or nil
  if not groupID or groupID == 0 then
    log(bWriteLog and "logic_weapon_pendant:GetGroupIDBySkinID not groupID")
    return 0
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  groupID = ItemUpgradeMgr:GetNormalGroupID(groupID)
  return groupID
end
function logic_weapon_pendant:GetWeaponPendantByBackPack(backpackPendant)
  local MapCfg = CDataTable.GetTableData("PendantMapCfg", backpackPendant)
  if MapCfg then
    return MapCfg.WeaponPendantID
  end
  return 0
end
function logic_weapon_pendant:ProcessInvalidPendant()
  log(bWriteLog and "logic_weapon_pendant:ProcessInvalidPendant")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  for groupID, insList in pairs(self.EquipData) do
    local invalid = false
    for socket, insID in pairs(insList) do
      if insID ~= 0 and not logic_wardrobe:IsWearValid(insID, serverTime) then
        log(bWriteLog and string.format("logic_weapon_pendant:ProcessInvalidPendant local putoff  group=%d, insID = %d", groupID, insID))
        self.EquipData[groupID][socket] = nil
        invalid = true
      end
    end
    if invalid then
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local groupList = ItemUpgradeMgr:GetUpgradeGroupByID(groupID)
      if groupList ~= nil then
        for _, cfg in ipairs(groupList) do
          local DepotItemData = wardrobe_data:GetHallDepotItemDataByResID(cfg.ItemID)
          if DepotItemData ~= nil then
            self:UpdatePendantData(DataMgr.roleData.uid, {
              [cfg.ItemID] = insList
            })
            break
          end
        end
      end
    end
  end
end
function logic_weapon_pendant:PutOnPendant(skinInsID, pendantInsID)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.PutOnWeaponPendant) == false then
    log(bWriteLog and "logic_weapon_pendant:PutOnPendant frequency limit")
    return
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_put_on_weapon_pendant_req(skinInsID, pendantInsID)
end
function logic_weapon_pendant:PutOffPendant(skinInsID, pendantInsID)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.PutOffWeaponPendant) == false then
    log(bWriteLog and "logic_weapon_pendant:PutOffPendant frequency limit")
    return
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_put_off_weapon_pendant_req(skinInsID, pendantInsID)
end
function logic_weapon_pendant:GetAllEquipPendant()
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_get_all_weapon_pendant_req()
end
function logic_weapon_pendant:on_put_on_weapon_pendant_rsp(retcode, skin_ins_id, pendant_ins_id, old_pendant_ins_id)
  if retcode ~= 0 then
    ShowNotice(retcode)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local weaponSkinData = wardrobe_data:GetValidHallDepotItemDataByInsID(skin_ins_id)
  local pendantData = wardrobe_data:GetValidHallDepotItemDataByInsID(pendant_ins_id)
  if not weaponSkinData or not pendantData then
    log_error("logic_weapon_pendant:on_put_on_weapon_pendant_rsp depot not match")
    return
  end
  local groupID = self:GetGroupIDBySkinID(weaponSkinData.resID)
  if not groupID or groupID == 0 then
    log_error("logic_weapon_pendant:on_put_on_weapon_pendant_rsp not groupID")
    return
  end
  if not self.EquipData[groupID] then
    self.EquipData[groupID] = {}
  end
  self.EquipData[groupID][self.CONST.DEFAULT_SOCKET] = pendant_ins_id
  self:SetPendantData(DataMgr.roleData.uid, groupID, pendantData.resID, self.CONST.DEFAULT_SOCKET)
  if old_pendant_ins_id then
    local oldPendantData = wardrobe_data:GetValidHallDepotItemDataByInsID(old_pendant_ins_id)
    if oldPendantData then
      self:SetPendantData(DataMgr.roleData.uid, groupID, oldPendantData.resID, self.CONST.UNEQUIP_SOCKET)
    end
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_PENDANT, EVENTID_WEAPON_PENDANT_WEAR_UPDATE, pendant_ins_id, old_pendant_ins_id)
end
function logic_weapon_pendant:on_put_off_weapon_pendant_rsp(retcode, skin_ins_id, pendant_ins_id)
  if retcode ~= 0 then
    ShowNotice(retcode)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local weaponSkinData = wardrobe_data:GetValidHallDepotItemDataByInsID(skin_ins_id)
  local pendantData = wardrobe_data:GetValidHallDepotItemDataByInsID(pendant_ins_id)
  if not weaponSkinData or not pendantData then
    log_error("logic_weapon_pendant:on_put_on_weapon_pendant_rsp depot not match")
    return
  end
  local groupID = self:GetGroupIDBySkinID(weaponSkinData.resID)
  if not groupID or groupID == 0 then
    log_error("logic_weapon_pendant:on_put_on_weapon_pendant_rsp not groupID")
    return
  end
  if not self.EquipData[groupID] then
    self.EquipData[groupID] = {}
  end
  self.EquipData[groupID][self.CONST.DEFAULT_SOCKET] = nil
  self:SetPendantData(DataMgr.roleData.uid, groupID, pendantData.resID, self.CONST.UNEQUIP_SOCKET)
  EventSystem:postEvent(EVENTTYPE_WEAPON_PENDANT, EVENTID_WEAPON_PENDANT_WEAR_UPDATE, nil, pendant_ins_id)
end
function logic_weapon_pendant:on_get_all_weapon_pendant_rsp(ret_code, weapon_pendants)
  if ret_code ~= 0 then
    ShowNotice(ret_code)
    return
  end
  log_tree("logic_weapon_pendant:on_get_all_weapon_pendant_rsp", weapon_pendants)
  self.EquipData = weapon_pendants or {}
  self.bGetEquipData = true
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for groupID, pendantList in pairs(self.EquipData) do
    for socket, pendantIns in pairs(pendantList) do
      if pendantIns and pendantIns ~= 0 then
        local pendantData = wardrobe_data:GetValidHallDepotItemDataByInsID(pendantIns)
        if pendantData then
          self:SetPendantData(DataMgr.roleData.uid, groupID, pendantData.resID, socket)
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_PENDANT, EVENTID_WEAPON_PENDANT_WEAR_UPDATE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_weapon_pendant = class(CModuleBase, nil, logic_weapon_pendant)
return Clogic_weapon_pendant