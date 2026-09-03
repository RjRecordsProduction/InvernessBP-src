local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
local logic_share_bag_privilege_util = {
  ENUM_ShareType = share_bag_macros.ENUM_ShareType
}
function logic_share_bag_privilege_util:ctor()
  self:DefineAndResetData()
end
function logic_share_bag_privilege_util:DefineAndResetData()
  self.bHasCollectSharePrivilege = false
  self.OriginShareType2Info = {}
  self.ShareType2Info = {}
  self.bMyPetShared = false
  self.bHasPetSharePrivilege = false
  self.bHasWeaponSharePrivilege = false
end
function logic_share_bag_privilege_util:HasSharingPrivilege(ShareType)
  if ShareType == share_bag_macros.ENUM_ShareType.Subscribe then
    local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
    local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
    local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
    return subscribeModuleObj:Get_Is_Valid(SubscribeEnumConfig.ENUM_SubId.Super)
  elseif ShareType == share_bag_macros.ENUM_ShareType.Collection then
    return self.bHasCollectSharePrivilege
  elseif ShareType == share_bag_macros.ENUM_ShareType.Pet then
    return self.bHasPetSharePrivilege
  elseif ShareType == share_bag_macros.ENUM_ShareType.Weapon then
    return self.bHasWeaponSharePrivilege
  end
  return false
end
function logic_share_bag_privilege_util:HasAnySharingPrivilege()
  return self:HasSharingPrivilege(share_bag_macros.ENUM_ShareType.Collection) or self:HasSharingPrivilege(share_bag_macros.ENUM_ShareType.Subscribe)
end
function logic_share_bag_privilege_util:IsShardBagValidByShareType(ShareType)
  if ShareType == share_bag_macros.ENUM_ShareType.Subscribe then
    local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
    local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
    local isChannelOpenSubscribe = subscribeModuleObj:GetIsPrimeOpen()
    if not isChannelOpenSubscribe then
      return false
    end
    local isSubscribeShareOpen = LobbySystem.CheckOpen(BP_ENUM_WARDROBE_SUBSCRIBE_SHARE_BAG)
    if not isSubscribeShareOpen then
      return false
    end
    return true
  elseif ShareType == share_bag_macros.ENUM_ShareType.Collection then
    return true
  elseif ShareType == share_bag_macros.ENUM_ShareType.Pet then
    return true
  elseif ShareType == share_bag_macros.ENUM_ShareType.Weapon then
    return true
  end
  return false
end
function logic_share_bag_privilege_util:IsAnyShardBagValid()
  return self:IsShardBagValidByShareType(share_bag_macros.ENUM_ShareType.Weapon) or self:IsShardBagValidByShareType(share_bag_macros.ENUM_ShareType.Pet) or self:IsShardBagValidByShareType(share_bag_macros.ENUM_ShareType.Collection) or self:IsShardBagValidByShareType(share_bag_macros.ENUM_ShareType.Subscribe)
end
function logic_share_bag_privilege_util:ReqSharedBagPermissionInfo()
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  for _, ShareType in pairs(share_bag_macros.ENUM_ShareType) do
    if self:IsShardBagValidByShareType(ShareType) then
      WardRobeHandler.send_get_shared_backpack_permission_info_req(ShareType)
    end
  end
end
function logic_share_bag_privilege_util:GetShareItemsByShareType(ShareType, bOrigin)
  if not ShareType then
    return nil
  end
  if bOrigin then
    return self.OriginShareType2Info[ShareType]
  else
    return self.ShareType2Info[ShareType]
  end
end
function logic_share_bag_privilege_util:RequestShareBagConfigIfHasPrivilege()
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  for _, ShareType in pairs(logic_share_bag_privilege_util.ENUM_ShareType) do
    if ShareType ~= share_bag_macros.ENUM_ShareType.Pet and self:HasSharingPrivilege(ShareType) then
      WardRobeHandler.send_get_shared_backpack_config_info_req(ShareType)
    end
  end
end
function logic_share_bag_privilege_util:OpenShareBagConfigPanel(ShareType)
  ShareType = ShareType or self.LastOpenShareType
  if not ShareType then
    if self.LastOpenShareType then
      ShareType = self.LastOpenShareType
    else
      ShareType = self:_GetFirstValidShareType()
    end
  end
  self.LastOpen  UIManager.ShowUI(UIManager.UI_Config.Wardrobe_ShareBackpack_Popup_UIBP, ShareType)
end
function logic_share_bag_privilege_util:SetLastShowShareType(ShareType)
  self.LastOpenend
function logic_share_bag_privilege_util:GetLastShowShareType()
  return self.LastOpenShareType
end
function logic_share_bag_privilege_util:IsPetShareOpen()
  local bOpen = LobbySystem.CheckLobbyMenuOpen(BP_ENUM_PET_SHARE_SWITCH, false)
  log(bWriteLog and string.format("logic_share_bag_privilege_util:IsPetShareOpen. bOpen=%s", tostring(bOpen)))
  return bOpen
end
function logic_share_bag_privilege_util:IsMyPetShared()
  return self.bMyPetShared
end
function logic_share_bag_privilege_util:ReqSetMyPetShared(bMyPetSharedNew)
  if self.bMyPetShared ~= bMyPetSharedNew then
    local PetHandler = require("client.network.Protocol.PetHandler")
    PetHandler.send_shared_pet_config_req(bMyPetSharedNew and 1 or 0)
  end
end
function logic_share_bag_privilege_util:RspSetMyPetShared(bMyPetSharedNew)
  self.bMyPetShared = bMyPetSharedNew
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_SHARE_CONFIG_CHANGE)
end
function logic_share_bag_privilege_util:GetShareWeaponJumpURL()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() or PublishRegionMacros.IsBLUEHOLE() then
    return "game://?module=1002300&index=15&openTab=1&jumpSubTabID=16&rewardIndex=98&rewardSubIndex=1"
  end
  return "game://?module=1002300&index=15&openTab=1&jumpSubTabID=16&rewardIndex=97&rewardSubIndex=1"
end
function logic_share_bag_privilege_util:on_get_collect_award_privilege_rsp(data)
  self:_ProcessPrivilegeData(data)
end
function logic_share_bag_privilege_util:on_notify_collect_privilege_data(data)
  self:_ProcessPrivilegeData(data)
end
function logic_share_bag_privilege_util:on_get_shared_backpack_config_info_rsp(shared_type, shared_items_info)
  self:_ProcessShareItemsInfo(shared_type, shared_items_info)
end
function logic_share_bag_privilege_util:on_shared_backpack_batch_config_item_rsp(shared_type, shared_items_info)
  self:_ProcessShareItemsInfo(shared_type, shared_items_info)
end
function logic_share_bag_privilege_util:_ProcessPrivilegeData(privilege_data)
  log_tree("logic_share_bag_privilege_util:_ProcessPrivilegeData privilege_data:", privilege_data)
  self.bHasCollectSharePrivilege = false
  self.bHasPetSharePrivilege = false
  self.bHasWeaponSharePrivilege = false
  if privilege_data.collect_shared_backpack and privilege_data.collect_shared_backpack.all_backpack and next(privilege_data.collect_shared_backpack.all_backpack) ~= nil then
    self.bHasCollectSharePrivilege = true
  end
  if type(privilege_data.shared_pet_priv) == "number" then
    if privilege_data.shared_pet_priv == 1 then
      self.bHasPetSharePrivilege = true
    else
      local TimeUtil = require("client.common.time_util")
      if privilege_data.shared_pet_priv >= TimeUtil.GetServerTimeInSec() then
        self.bHasPetSharePrivilege = true
      end
    end
  end
  if privilege_data.shared_weapon_priv then
    self.bHasWeaponSharePrivilege = true
  end
  log(bWriteLog and string.format("logic_share_bag_privilege_util:_ProcessPrivilegeData. bHasCollectSharePrivilege=%s, bHasPetSharePrivilege=%s", tostring(self.bHasCollectSharePrivilege), tostring(self.bHasPetSharePrivilege)))
end
function logic_share_bag_privilege_util:_ProcessShareItemsInfo(shared_type, shared_items_info)
  if not shared_type or not shared_items_info then
    log_warning(bWriteLog and "logic_share_bag_privilege_util:_ProcessShareItemsInfo either shared_type or shared_items_info is invalid")
    return
  end
  self.OriginShareType2Info[shared_type] = shared_items_info
  self.ShareType2Info[shared_type] = {}
  local ShareInfo = self.ShareType2Info[shared_type]
  for k, v in pairs(shared_items_info) do
    ShareInfo[#ShareInfo + 1] = k
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SUBSCRIBE_SHARE_SETUP, ShareInfo, shared_type)
end
function logic_share_bag_privilege_util:_GetFirstValidShareType()
  for _, ShareType in pairs(logic_share_bag_privilege_util.ENUM_ShareType) do
    if self:HasSharingPrivilege(ShareType) then
      return ShareType
    end
  end
  return logic_share_bag_privilege_util.ENUM_ShareType.Subscribe
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_share_bag_privilege_util = class(CModuleBase, nil, logic_share_bag_privilege_util)
return Clogic_share_bag_privilege_util