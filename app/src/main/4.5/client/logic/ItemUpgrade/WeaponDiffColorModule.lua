local WeaponDiffColorModule = {}
function WeaponDiffColorModule:DefineAndResetData()
  log(bWriteLog and "WeaponDiffColorModule:DefineAndResetData")
  self.SpecialCloths = {}
  self.WeaponColorFollowSwitchCache = {}
  self.bHasSelfPrivilege = nil
  self.bHasInheritedPrivilege = nil
  self.LastClothID = nil
  self.LastSource = nil
  local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
  ItemUpGradeHandler.send_taluo_get_dress_change_gun_flag_req()
  ItemUpGradeHandler.send_upgrade_query_refit_req()
end
function WeaponDiffColorModule:GetCurrentClothID()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local showingAvatar = TeamAvatarManager.GetMainAvatar()
  if not showingAvatar then
    return nil
  end
  local showingAvatarModel = showingAvatar:GetModel()
  if not slua.isValid(showingAvatarModel) then
    return nil
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local clothID = showingAvatarModel:GetEquipmentInfoBySlot(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if clothID ~= 0 then
    return clothID
  end
  return nil
end
function WeaponDiffColorModule:GetCurrentClothSource()
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  logic_wardrobe_avatar:InitCurrentWearPreviewMap()
  local WearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(BP_ENUM_AVATAR_CLOTH)
  if WearInfo == nil then
    return nil
  end
  local Source = wardrobe_data:GetItemSource(WearInfo.insID)
  return Source
end
function WeaponDiffColorModule:FindTargetWeaponResID(ClothResID, SrcWeaponResID)
  if not self:ClothHasSwitch(ClothResID) then
    ClothResID = 1
  end
  if not SrcWeaponResID then
    return nil
  end
  local Cfg = CDataTable.GetTableDataByFilter("WeaponSwitchByClothCfg", "ClothID", ClothResID, "SrcSkinID", SrcWeaponResID)
  if not Cfg then
    log(bWriteLog and "WeaponDiffColorModule:SwitchWeaponSkinByClothID Failed to load cfg")
    return SrcWeaponResID
  else
    return Cfg.DstSkinID
  end
end
function WeaponDiffColorModule:CacheSelfPrivilege(refit_map)
  self.bHasSelfPrivilege = refit_map and refit_map[216] ~= nil
end
function WeaponDiffColorModule:CacheInheritedPrivilege(refit_map_inherit)
  self.bHasInheritedPrivilege = refit_map_inherit and refit_map_inherit[216] ~= nil
end
function WeaponDiffColorModule:HasDiffColorPrivilege(Source)
  if Source == EWardrobeDataSource.Wardrobe then
    if self.bHasSelfPrivilege == nil then
      local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
      ItemUpGradeHandler.send_upgrade_query_refit_req()
      return nil
    else
      return self.bHasSelfPrivilege
    end
  elseif self.bHasInheritedPrivilege == nil then
    local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
    ItemUpGradeHandler.send_upgrade_query_refit_req()
    return nil
  else
    return self.bHasInheritedPrivilege
  end
end
function WeaponDiffColorModule:GetSlotIDByItemID(ItemID)
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if not itemCfg then
    return 0
  end
  local bpCfg = CDataTable.GetTableData("AvatarBPTable", itemCfg.BPID)
  if not bpCfg then
    return 0
  end
  if 0 < bpCfg.TemplateID then
    return math.floor(bpCfg.TemplateID / 1000)
  else
    return 0
  end
end
function WeaponDiffColorModule:SwitchWeaponSkinByClothID(ClothID, bPutOn, Source)
  local EAvatarSlotType = import("EAvatarSlotType")
  if not ClothID or self:GetSlotIDByItemID(ClothID) ~= EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot then
    return
  end
  Source = Source or self:GetCurrentClothSource()
  if Source == nil then
    log(bWriteLog and string.format("WeaponDiffColorModule:SwitchWeapon Failed to get source, ClothID:%s", ClothID))
    return
  end
  if not self:HasDiffColorPrivilege(Source) and bPutOn then
    return
  end
  if bPutOn == nil then
    bPutOn = ClothID == self:GetCurrentClothID()
  end
  if bPutOn and self:ClothHasSwitch(ClothID) and self:CheckWeaponColorFollowSwitch(ClothID, Source) == nil then
    return
  end
  local Cfg = CDataTable.GetTable("WeaponSwitchByClothCfg")
  if not Cfg then
    log(bWriteLog and "WeaponDiffColorModule:SwitchWeaponSkinByClothID Failed to load cfg")
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
  local bSwitchOpen = self:ClothHasSwitch(ClothID) and self:CheckWeaponColorFollowSwitch(ClothID, Source)
  if bSwitchOpen == false or not bPutOn then
    ClothID = 1
  end
  if ClothID == self.LastClothID then
    return
  end
  self.Last  self.Last  if self.SendReqTimer then
    self:RemoveTimer(self.SendReqTimer)
    self.SendReqTimer = nil
  end
  self.SendReqTimer = self:AddTimerOnce(0, function()
    for k, v in pairs(Cfg) do
      if v.ClothID == ClothID then
        local Count = wardrobe_data:GetHallDepotItemCountByResID(v.SrcSkinID, false, Source)
        if 0 < Count then
          ItemUpGradeHandler.send_taluo_change_gun_with_dress_req(v.SrcSkinID, v.DstSkinID)
        end
      end
    end
  end)
end
function WeaponDiffColorModule:ClothHasSwitch(ClothID)
  if self.SpecialCloths[ClothID] == nil then
    local ClothWeaponColorFollowSwitchCfg = CDataTable.GetTableData("ClothWeaponColorFollowSwitchCfg", ClothID)
    if ClothWeaponColorFollowSwitchCfg then
      self.SpecialCloths[ClothID] = true
    else
      self.SpecialCloths[ClothID] = false
    end
  end
  return self.SpecialCloths[ClothID]
end
function WeaponDiffColorModule:CheckWeaponColorFollowSwitch(ClothID, Source)
  if not ClothID then
    return true
  end
  if not self:ClothHasSwitch(ClothID) or ClothID == 1 then
    return true
  end
  if self.WeaponColorFollowSwitchCache[Source] and self.WeaponColorFollowSwitchCache[Source][ClothID] ~= nil then
    return self.WeaponColorFollowSwitchCache[Source][ClothID]
  end
  self.LastCheckWeaponSwitchFlag  local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
  ItemUpGradeHandler.send_taluo_get_dress_change_gun_flag_req()
  return nil
end
function WeaponDiffColorModule:UpdateWeaponSwitchByClothFlag(ItemID, flag, Source)
  self.WeaponColorFollowSwitchCache[Source] = self.WeaponColorFollowSwitchCache[Source] or {}
  self.WeaponColorFollowSwitchCache[Source][ItemID] = flag
  if ItemID == self.LastCheckWeaponSwitchFlagClothID then
    self.LastCheckWeaponSwitchFlagClothID = nil
    EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_TOGGLE_WEAPON_SWITCH_BY_CLOTH, ItemID, flag)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CWeaponDiffColorModule = class(CModuleBase, nil, WeaponDiffColorModule)
return CWeaponDiffColorModule