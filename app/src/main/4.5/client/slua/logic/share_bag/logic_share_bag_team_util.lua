local C_SUBTYPE_LIST_NEED_PUTOFF = {
  ENUM_ITEM_SUBTYPE.Hat_Slot,
  ENUM_ITEM_SUBTYPE.Mask_Slot,
  ENUM_ITEM_SUBTYPE.Package_Slot,
  ENUM_ITEM_SUBTYPE.Pants_Slot,
  ENUM_ITEM_SUBTYPE.Shoes_Slot,
  ENUM_ITEM_SUBTYPE.Eye_Slot,
  ENUM_ITEM_SUBTYPE.Upgrade_Backpack,
  ENUM_ITEM_SUBTYPE.Helmet,
  ENUM_ITEM_SUBTYPE.Gloves
}
local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
local SHARE_CLOTHES_TYPES = {
  share_bag_macros.ENUM_ShareType.Subscribe,
  share_bag_macros.ENUM_ShareType.Collection
}
local SHARE_PET_TYPE = share_bag_macros.ENUM_ShareType.Pet
local SHARE_WEAPON_TYPE = share_bag_macros.ENUM_ShareType.Weapon
local logic_share_bag_team_util = {C_SUBTYPE_LIST_NEED_PUTOFF = C_SUBTYPE_LIST_NEED_PUTOFF}
function logic_share_bag_team_util:DefineAndResetData()
  self._originShareBagInfo = {}
  self._availableShareBagCount = 0
  self._allShareInfo = {}
  self._shareClothesInfo = {}
  self._giveShareBagPrivilegeUIDs = {}
  self._recvShareBagPrivilegeUIDs = {}
  self._lastSelectSharedItems = {}
  self._showShareBagGuidUID = nil
  self._bHasSetBagInfo = false
end
function logic_share_bag_team_util:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Login and nextState == GameStatus.Lobby then
    self:DefineAndResetData()
  end
end
function logic_share_bag_team_util:SetShareBagInfo(isIncrement, isMemberQuit, teamid, members)
  log(bWriteLog and string.format("logic_share_bag_team_util:SetShareBagInfo. isIncrement=%s, isMemberQuit=%s, teamid=%s, members=%s", tostring(isIncrement), tostring(isMemberQuit), tostring(teamid), tostring(members)))
  if not members then
    return
  end
  local TableUtil = require("common.table_util")
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  if not logic_share_bag_privilege_util:IsAnyShardBagValid() then
    return
  end
  local bPendingLogin = false
  if not self._bHasSetBagInfo then
    bPendingLogin = true
    self._bHasSetBagInfo = true
  end
  if teamid == 0 then
    self.uid2SelectPetData = {}
    self.uid2SelectGun = {}
  end
  if not isIncrement and not isMemberQuit then
    self._shareClothesInfo = {}
    self._allShareInfo = {}
    for uid, member in pairs(members) do
      local share_items_info = member.shared_items_info
      self._originShareBagInfo[uid] = {}
      if share_items_info then
        for shareType, data in pairs(share_items_info) do
          self._originShareBagInfo[uid][shareType] = data
        end
      end
      local info = {
        uid = uid,
        itemList = {}
      }
      local allInfo = {
        uid = uid,
        shareItemsInfo = {},
        totalCount = 0
      }
      allInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.AvatarItem] = {}
      for _, shareType in pairs(SHARE_CLOTHES_TYPES) do
        local data = self._originShareBagInfo[uid] and self._originShareBagInfo[uid][shareType]
        if data and next(data) ~= nil then
          for item_id, v in pairs(data) do
            local selectType = 0
            if v.uid then
              if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
                selectType = 1
              else
                selectType = 2
              end
            end
            table.insert(info.itemList, {
              itemId = item_id,
              selectType = selectType,
              selectUid = v.uid,
              shareType = shareType,
              CustomData = v
            })
          end
        end
        info.realItemCount = #info.itemList
      end
      table.insert(self._shareClothesInfo, info)
      local itemCount = #info.itemList
      allInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.AvatarItem] = TableUtil.CopyTable(info.itemList)
      allInfo.totalCount = allInfo.totalCount + itemCount
      local petList = {}
      local sharePetList = self._originShareBagInfo[uid] and self._originShareBagInfo[uid][share_bag_macros.ENUM_ShareType.Pet]
      if sharePetList and next(sharePetList) ~= nil then
        for pet_id, v in pairs(sharePetList) do
          local selectType = 0
          if v.uid then
            if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
              selectType = 1
            else
              selectType = 2
            end
          end
          table.insert(petList, {
            petData = v.data,
            selectType = selectType,
            selectUid = v.uid,
            shareType = share_bag_macros.ENUM_ShareType.Pet
          })
        end
      end
      local sharePetCount = #petList
      allInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.Pet] = petList
      allInfo.totalCount = allInfo.totalCount + sharePetCount
      local weaponList = {}
      local weaponShareType = share_bag_macros.ENUM_ShareType.Weapon
      local data = self._originShareBagInfo[uid] and self._originShareBagInfo[uid][weaponShareType]
      if data and next(data) ~= nil then
        for item_id, v in pairs(data) do
          local selectType = 0
          if v.uid then
            if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
              selectType = 1
            else
              selectType = 2
            end
          end
          table.insert(weaponList, {
            itemId = item_id,
            selectType = selectType,
            selectUid = v.uid,
            color = v.color,
            pattern = v.pattern,
            shareType = weaponShareType
          })
        end
      end
      local weaponCount = #weaponList
      allInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.Weapon] = weaponList
      allInfo.totalCount = allInfo.totalCount + weaponCount
      self._allShareInfo[#self._allShareInfo + 1] = allInfo
    end
    self:FilterRepeatUidForShareBagInfo()
    log_tree("logic_share_bag_team_util:_shareClothesInfo init ", self._shareClothesInfo)
  elseif isIncrement and not isMemberQuit then
    local oldUIDMapWithShareItem = {}
    for _, v in pairs(self._allShareInfo) do
      if v.uid and v.totalCount and 0 < v.totalCount then
        oldUIDMapWithShareItem[v.uid] = true
      end
    end
    local oldLength = #self._shareClothesInfo
    for uid, member in pairs(members) do
      local share_items_info = member.shared_items_info
      self._originShareBagInfo[uid] = {}
      if share_items_info then
        for shareType, data in pairs(share_items_info) do
          self._originShareBagInfo[uid][shareType] = data
        end
      end
      local info = {
        uid = uid,
        itemList = {}
      }
      local allInfo = {
        uid = uid,
        shareItemsInfo = {},
        totalCount = 0
      }
      if self._originShareBagInfo[uid] and next(self._originShareBagInfo[uid]) ~= nil then
        for _, shareType in pairs(SHARE_CLOTHES_TYPES) do
          local data = self._originShareBagInfo[uid] and self._originShareBagInfo[uid][shareType]
          if data then
            for item_id, v in pairs(data) do
              local selectType = 0
              if v.uid then
                if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
                  selectType = 1
                else
                  selectType = 2
                end
              end
              table.insert(info.itemList, {
                itemId = item_id,
                selectType = selectType,
                selectUid = v.uid,
                shareType = shareType,
                CustomData = v
              })
            end
          end
        end
      end
      info.realItemCount = #info.itemList
      allInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.AvatarItem] = TableUtil.CopyTable(info.itemList)
      allInfo.totalCount = allInfo.totalCount + #info.itemList
      table.insert(self._shareClothesInfo, info)
      local petList = {}
      local sharePetList = self._originShareBagInfo[uid] and self._originShareBagInfo[uid][share_bag_macros.ENUM_ShareType.Pet]
      if sharePetList and next(sharePetList) ~= nil then
        for pet_id, v in pairs(sharePetList) do
          local selectType = 0
          if v.uid then
            if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
              selectType = 1
            else
              selectType = 2
            end
          end
          table.insert(petList, {
            petData = v.data,
            selectType = selectType,
            selectUid = v.uid,
            shareType = share_bag_macros.ENUM_ShareType.Pet
          })
        end
      end
      local sharePetCount = petList and #petList or 0
      allInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.Pet] = petList
      allInfo.totalCount = allInfo.totalCount + sharePetCount
      local weaponList = {}
      local weaponShareType = share_bag_macros.ENUM_ShareType.Weapon
      local data = self._originShareBagInfo[uid] and self._originShareBagInfo[uid][weaponShareType]
      if data and next(data) ~= nil then
        for item_id, v in pairs(data) do
          local selectType = 0
          if v.uid then
            if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
              selectType = 1
            else
              selectType = 2
            end
          end
          table.insert(weaponList, {
            itemId = item_id,
            selectType = selectType,
            selectUid = v.uid,
            color = v.color,
            pattern = v.pattern,
            shareType = weaponShareType
          })
        end
      end
      local weaponCount = #weaponList
      allInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.Weapon] = weaponList
      allInfo.totalCount = allInfo.totalCount + weaponCount
      self._allShareInfo[#self._allShareInfo + 1] = allInfo
      if 0 < allInfo.totalCount and not oldUIDMapWithShareItem[uid] then
        log(bWriteLog and "[sharebag][tips] logic_share_bag_team_util.SetShareBagInfo new member with share item: " .. uid)
        local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
        logic_profile_get_wrap.GetNormalProfiles({uid}, function(list)
          local profile = list[1]
          if profile then
            local tips = LocUtil.LocalizeResFormat(47556, profile.nickName)
            if not GameStatus.IsInMainCity() then
              UIManager.ShowUI(UIManager.UI_Config.Team_Share_Tips_UIBP, tips)
              log(bWriteLog and "[sharebag][tips] logic_share_bag_team_util.SetShareBagInfo show Team_Share_Tips_UIBP" .. tips)
            end
            local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
            if Lobby_Main_City_Enter.bInMainCity then
              local logic_maincity_minilobby_team_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_maincity_minilobby_team_tips)
              logic_maincity_minilobby_team_tips:AddShareBagInfo(uid, tips)
            end
          end
        end, Enum_PROFILE_REPORT_CFG.TEAMUP_MEMBER_DETAIL)
      end
    end
    self:FilterRepeatUidForShareBagInfo()
    log_tree("logic_share_bag_team_util._shareClothesInfo ", self._shareClothesInfo)
  else
    if self._shareClothesInfo then
      for i = #self._shareClothesInfo, 1, -1 do
        local uid = self._shareClothesInfo[i].uid
        if not uid or not members[uid] then
          table.remove(self._shareClothesInfo, i)
        end
      end
    end
    if self._allShareInfo then
      for i = #self._allShareInfo, 1, -1 do
        local uid = self._allShareInfo[i].uid
        if not uid or not members[uid] then
          table.remove(self._allShareInfo, i)
        end
      end
    end
  end
  log(bWriteLog and "logic_share_bag_team_util:SetSubscribeBagsInfo call UpdateAllAvatarWithShareBagInfo for sync shared items")
  log_tree("logic_share_bag_team_util.SetShareBagInfo _allShareInfo:", self._allShareInfo or {})
  self:UpdateAllAvatarWithShareBagInfo(nil, nil, bPendingLogin)
  self:ResortAllShareList()
  self:UpdateAvailableShareBagCount()
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SHARE_INFO_CHANGED)
end
function logic_share_bag_team_util:UpdateShareBagsInfo(shared_uid, shared_type, shared_items_info, bOffline)
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  if not logic_share_bag_privilege_util:IsAnyShardBagValid() then
    return
  end
  log_tree("logic_share_bag_team_util:UpdateShareBagsInfo shared_items_info ", shared_items_info)
  if not self._originShareBagInfo[shared_uid] then
    self._originShareBagInfo[shared_uid] = {}
  end
  self._originShareBagInfo[shared_uid][shared_type] = shared_items_info
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local memberInfo = TeamUpNewSystem.GetMemberInfo(shared_uid)
  if memberInfo and memberInfo.shared_items_info then
    memberInfo.shared_items_info[shared_type] = shared_items_info
  end
  local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
  local shareItemType = share_bag_macros.ShareType2ShareItemTypeMap[shared_type]
  local relativeShareTypes = share_bag_macros.ShareItemType2ShareTypeMap[share_bag_macros.ShareType2ShareItemTypeMap[shared_type]]
  if not shareItemType or not relativeShareTypes then
    return
  end
  for i, allInfo in pairs(self._allShareInfo) do
    if allInfo.uid == shared_uid then
      local itemList = {}
      if memberInfo and memberInfo.shared_items_info then
        for _, shared_type in pairs(relativeShareTypes) do
          local data = memberInfo.shared_items_info[shared_type]
          if data then
            for item_id, v in pairs(data) do
              local selectType = 0
              if v.uid then
                log(bWriteLog and "logic_share_bag_team_util processUid: " .. v.uid .. " selfUID: " .. DataMgr.roleData.uid)
                if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
                  selectType = 1
                else
                  selectType = 2
                end
              end
              table.insert(itemList, {
                itemId = item_id,
                petData = v.data,
                selectType = selectType,
                selectUid = v.uid,
                shareType = shared_type,
                CustomData = v
              })
            end
          end
        end
      end
      local oldCount = allInfo.shareItemsInfo and allInfo.shareItemsInfo[shareItemType] and #allInfo.shareItemsInfo[shareItemType] or 0
      local newCount = #itemList
      allInfo.totalCount = allInfo.totalCount - oldCount + newCount
      allInfo.shareItemsInfo[shareItemType] = itemList
      allInfo.      log_tree("logic_share_bag_team_util:UpdateShareBagsInfo self._allShareInfo", self._allShareInfo)
      break
    end
  end
  log(bWriteLog and "logic_share_bag_team_util:UpdateShareBagsInfo call UpdateAllAvatarWithShareBagInfo for sync shared items")
  self:UpdateAllAvatarWithShareBagInfo()
  self:ResortAllShareList()
  self:UpdateAvailableShareBagCount()
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SHARE_INFO_CHANGED)
end
function logic_share_bag_team_util:UpdateAllAvatarWithShareBagInfo(updateUID, bForceUpdate, bPendingLogin)
  log(bWriteLog and "logic_share_bag_team_util:UpdateAllAvatarWithShareBagInfo " .. tostring(updateUID))
  local allShareItemInfo = self:GetAllShareItemInfo()
  if not allShareItemInfo then
    return
  end
  local uid2SelectList = {}
  self.uid2SelectPetData = {}
  local oldSelectGun = self.uid2SelectGun and self.uid2SelectGun[DataMgr.roleData.uid] or 0
  self.uid2SelectGun = {}
  for i, sharedInfo in pairs(allShareItemInfo) do
    local shareClothesList = sharedInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.AvatarItem]
    if shareClothesList then
      for _, itemInfo in pairs(shareClothesList) do
        if itemInfo.selectUid then
          local selectUid = tostring(itemInfo.selectUid)
          if not uid2SelectList[selectUid] then
            uid2SelectList[selectUid] = {}
          end
          table.insert(uid2SelectList[selectUid], {
            itemId = itemInfo.itemId,
            CustomData = itemInfo.CustomData
          })
        end
      end
    end
    local sharePetList = sharedInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.Pet]
    if sharePetList then
      for _, petInfo in pairs(sharePetList) do
        if petInfo.selectUid then
          local selectUid = tostring(petInfo.selectUid)
          self.uid2SelectPetData[selectUid] = petInfo
        end
      end
    end
    local shareWeaponList = sharedInfo.shareItemsInfo[share_bag_macros.ENUM_ShareItemType.Weapon]
    if shareWeaponList then
      for _, itemInfo in pairs(shareWeaponList) do
        if itemInfo.selectUid then
          local selectUid = tostring(itemInfo.selectUid)
          if not uid2SelectList[selectUid] then
            uid2SelectList[selectUid] = {}
          end
          table.insert(uid2SelectList[selectUid], {
            itemId = itemInfo.itemId,
            CustomData = itemInfo.CustomData
          })
          self.uid2SelectGun[selectUid] = itemInfo.itemId
        end
      end
    end
  end
  local newSelectGun = self.uid2SelectGun and self.uid2SelectGun[DataMgr.roleData.uid] or 0
  if oldSelectGun ~= newSelectGun then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SELF_USING_SHARE_WEAPON_CHANGE)
  end
  local emptyItemList = {}
  for k, v in pairs(allShareItemInfo) do
    local uid = tostring(v.uid)
    if not updateUID or tostring(updateUID) == uid then
      self:UpdateTeamAvatar(uid, uid2SelectList[uid] or emptyItemList, bForceUpdate, bPendingLogin)
      self:UpdatePetAvatarWithShareBagInfo(uid, bForceUpdate, bPendingLogin)
    end
  end
end
function logic_share_bag_team_util:UpdateAvailableShareBagCount()
  log(bWriteLog and "logic_share_bag_team_util:UpdateAvailableShareBagCount begin")
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  if not logic_share_bag_privilege_util:IsAnyShardBagValid() then
    return 0
  end
  self._availableShareBagCount = 0
  if self._allShareInfo and next(self._allShareInfo) then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    for i, v in ipairs(self._allShareInfo) do
      local uid = v.uid
      local itemCount = v.totalCount or 0
      if 0 < itemCount and not v.bOffline then
        if LogicFriend.IsMyFriend(uid) then
          log(bWriteLog and "logic_share_bag_team_util:UpdateAvailableShareBagCount uid: " .. tostring(uid) .. " is my friend")
          self._availableShareBagCount = self._availableShareBagCount + 1
        elseif self:CanUseOtherShareBag(uid) then
          log(bWriteLog and "logic_share_bag_team_util:UpdateAvailableShareBagCount uid: " .. tostring(uid) .. " grant privilege for me")
          self._availableShareBagCount = self._availableShareBagCount + 1
        end
      end
    end
  end
  log(bWriteLog and "logic_share_bag_team_util:UpdateAvailableShareBagCount self.availableSubscribeBagCount = " .. self._availableShareBagCount)
  return self._availableShareBagCount
end
function logic_share_bag_team_util:GetOriginShareBagInfo()
  return self._originShareBagInfo or {}
end
function logic_share_bag_team_util:GetAvailableShareBagCount()
  return self._availableShareBagCount or 0
end
function logic_share_bag_team_util:GetLastSelectSharedItemsByUID(uid)
  if not uid then
    return nil
  end
  return self._lastSelectSharedItems and self._lastSelectSharedItems[uid]
end
function logic_share_bag_team_util:GetAllShareItemInfo()
  return self._allShareInfo
end
function logic_share_bag_team_util:FilterRepeatUidForShareBagInfo()
  local repeatUidTb = {}
  for i = #self._shareClothesInfo, 1, -1 do
    local v = self._shareClothesInfo[i]
    if repeatUidTb[v.uid] then
      table.remove(self._shareClothesInfo, i)
    else
      repeatUidTb[v.uid] = true
    end
  end
  repeatUidTb = {}
  for i = #self._allShareInfo, 1, -1 do
    local v = self._allShareInfo[i]
    if repeatUidTb[v.uid] then
      table.remove(self._allShareInfo, i)
    else
      repeatUidTb[v.uid] = true
    end
  end
end
function logic_share_bag_team_util:DeselectShareBagItems()
  if not self._shareClothesInfo then
    return
  end
  local myUid = DataMgr.roleData.uid
  local mySelectUid
  for _, sharedInfo in pairs(self._shareClothesInfo) do
    if sharedInfo and sharedInfo.itemList then
      for __, itemInfo in pairs(sharedInfo.itemList) do
        if myUid == tostring(itemInfo.selectUid) then
          mySelectUid = sharedInfo.uid
          break
        end
      end
    end
  end
  if mySelectUid then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    log(bWriteLog and "clear previous selected items")
    WardRobeHandler.send_shared_backpack_select_item_req(mySelectUid, 1, {})
  end
end
function logic_share_bag_team_util:ClearAllGrantShareBagMember()
  self._giveShareBagPrivilegeUIDs = {}
  self._recvShareBagPrivilegeUIDs = {}
end
function logic_share_bag_team_util:CanOtherUseMyShareBag(uid)
  if not uid then
    return false
  end
  return self._giveShareBagPrivilegeUIDs[uid]
end
function logic_share_bag_team_util:CanUseOtherShareBag(uid)
  if not uid then
    return false
  end
  return self._recvShareBagPrivilegeUIDs[uid]
end
function logic_share_bag_team_util:RecvShareBagPriviligeUID(uid)
  log(bWriteLog and "[share_bag_priv] logic_share_bag_team_util:RecvShareBagPriviligeUID")
  if not uid then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Team_Open_Share_Bag_UIBP, uid)
  self._recvShareBagPrivilegeUIDs[uid] = true
  self:UpdateAvailableShareBagCount()
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SHARE_PRIVILEGE_GRANTED)
end
function logic_share_bag_team_util:UpdateShareBagPrivilige(grant_permission, granted_permission)
  log(bWriteLog and "[share_bag_priv] logic_share_bag_team_util.UpdateShareBagPrivilige")
  self._giveShareBagPrivilegeUIDs = {}
  if grant_permission then
    for uid, _ in pairs(grant_permission) do
      self._giveShareBagPrivilegeUIDs[uid] = true
    end
  end
  self._recvShareBagPrivilegeUIDs = {}
  if granted_permission then
    for uid, _ in pairs(granted_permission) do
      self._recvShareBagPrivilegeUIDs[uid] = true
    end
  end
  self:UpdateAvailableShareBagCount()
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SHARE_PRIVILEGE_GRANTED)
end
function logic_share_bag_team_util:CheckCanShowBagGuide()
  if not LobbySystem.CheckOpen(BP_ENUM_WARDROBE_SUBSCRIBE_SHARE_BAG) then
    return false
  end
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  if not logic_share_bag_privilege_util:IsAnyShardBagValid() then
    return
  end
  if not logic_share_bag_privilege_util:HasAnySharingPrivilege() then
    return false
  end
  local logic_share_bag_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_guide)
  local status = logic_share_bag_guide:GetShareBagGuideStatus(logic_share_bag_guide.SHARE_TYPE_SUBSCRIPBE, logic_share_bag_guide.GUIDETYPE_SUBSCRIBE_NON_FRIEND_TEAM_MAIN)
  if status ~= logic_share_bag_guide.GUIDE_SHOWSTATUS_NOT then
    return false
  end
  return true
end
function logic_share_bag_team_util:IsNonFriendAndNoSharePrivilege(uid)
  if not uid then
    return false
  end
  local selfUID = tonumber(DataMgr.roleData.uid) or 0
  if uid == selfUID then
    return false
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if LogicFriend.IsMyFriend(uid) then
    return false
  end
  if self:CanOtherUseMyShareBag(uid) then
    return false
  end
  return true
end
function logic_share_bag_team_util:GetShowShareBagGuidUID()
  return self._showShareBagGuidUID
end
function logic_share_bag_team_util:OnQuitTeam()
  self._showShareBagGuidUID = nil
  self._shareClothesInfo = {}
end
function logic_share_bag_team_util:OnOtherQuitTeam(uid)
  if not uid then
    return
  end
  self:ClearLastSelectShareItemsInfo(uid)
  if self._showShareBagGuidUID == uid then
    self._showShareBagGuidUID = nil
  end
end
function logic_share_bag_team_util:CheckShowShareeBagUsingTips(shared_uid, shared_type, shared_items_info, selected_uid)
  if selected_uid and selected_uid ~= 0 and next(shared_items_info) then
    local selectedItems = {}
    for item_id, v in pairs(shared_items_info) do
      if v.uid == selected_uid then
        selectedItems[item_id] = true
      end
    end
    if not next(selectedItems) then
      return
    end
    local oldSelectItems = {}
    local shareItemType = share_bag_macros.ShareType2ShareItemTypeMap[shared_type]
    if self._allShareInfo then
      for _, shareInfo in pairs(self._allShareInfo) do
        if shareInfo.uid == shared_uid then
          local itemList = shareInfo.shareItemsInfo and shareInfo.shareItemsInfo[shareItemType]
          if itemList then
            for __, item in pairs(itemList) do
              if item.itemId and item.selectType == 1 then
                oldSelectItems[item.itemId] = true
              end
            end
          end
        end
      end
    end
    local tipsId = 47518
    if shared_type == 3 then
      tipsId = 77063
    elseif shared_type == 4 then
      tipsId = 77062
    end
    local hasNewSelectItem = false
    for itemId, _ in pairs(selectedItems) do
      if not oldSelectItems[itemId] then
        hasNewSelectItem = true
        break
      end
    end
    if hasNewSelectItem then
      do
        local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
        logic_profile_get_wrap.GetNormalProfiles({selected_uid, shared_uid}, function(list)
          local profile1 = list[1]
          local profile2 = list[2]
          if profile1 and profile1.nickName and profile2 and profile2.nickName then
            local tips = LocUtil.LocalizeResFormat(tipsId, profile1.nickName, profile2.nickName)
            UIManager.ShowUI(UIManager.UI_Config.Team_Share_Tips_UIBP, tips)
          end
        end, Enum_PROFILE_REPORT_CFG.SUBSCRIBE_SHARE_BAG)
      end
    end
  end
end
function logic_share_bag_team_util:GiveShareBagPriviligeUID(uid)
  log(bWriteLog and "[share_bag_priv] logic_share_bag_team_util:GiveShareBagPriviligeUID " .. tostring(uid))
  if not uid then
    return
  end
  ShowNotice(49697)
  self._giveShareBagPrivilegeUIDs[uid] = true
end
function logic_share_bag_team_util:ClearLastSelectShareItemsInfo(uid)
  uid = uid and tonumber(uid)
  if not uid then
  else
    self._lastSelectSharedItems[uid] = nil
  end
end
local _GetShareeBagListPriorityByUID = function(uid)
  local priority = 999
  if not uid then
    return priority
  end
  if tostring(uid) == DataMgr.roleData.uid then
    priority = 3
  else
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if LogicFriend.IsMyFriend(uid) then
      priority = 1
    else
      priority = 2
    end
  end
  return priority
end
function logic_share_bag_team_util:ResortAllShareList()
  self:_ResortShareBagList()
  if not self._allShareInfo then
    return
  end
  table.sort(self._allShareInfo, function(a, b)
    local priorityA = _GetShareeBagListPriorityByUID(a.uid)
    local priorityB = _GetShareeBagListPriorityByUID(b.uid)
    local hasSharedItemA = a.totalCount > 0 and 1 or 0
    local hasSharedItemB = b.totalCount > 0 and 1 or 0
    return priorityA < priorityB or priorityA == priorityB and hasSharedItemA > hasSharedItemB
  end)
end
function logic_share_bag_team_util:_ResortShareBagList()
  if not self._shareClothesInfo then
    return
  end
  table.sort(self._shareClothesInfo, function(a, b)
    local priorityA = _GetShareeBagListPriorityByUID(a.uid)
    local priorityB = _GetShareeBagListPriorityByUID(b.uid)
    local hasSharedItemA = a.itemList and #a.itemList > 0 and 1 or 0
    local hasSharedItemB = b.itemList and #b.itemList > 0 and 1 or 0
    return priorityA < priorityB or priorityA == priorityB and hasSharedItemA > hasSharedItemB
  end)
end
function logic_share_bag_team_util:UpdateShareBagGuide()
  if not self:CheckCanShowBagGuide() then
    self._showShareBagGuidUID = nil
    return
  end
  if (not self._showShareBagGuidUID or not self:IsNonFriendAndNoSharePrivilege(self._showShareBagGuidUID)) and self.teamInfo and self.teamInfo.members then
    for uid, _ in pairs(self.teamInfo.members) do
      if self:IsNonFriendAndNoSharePrivilege(uid) then
        self._showShareBagGuidUID = uid
        break
      end
    end
  end
end
function logic_share_bag_team_util:UpdateTeamAvatar(uid, usingSharedItemList, bForceUpdate, bPendingLogin)
  log(bWriteLog and "logic_share_bag_team_util:UpdateTeamAvatar " .. tostring(uid))
  self:UpdateAvatarWithShareBagItemList(uid, usingSharedItemList, bForceUpdate, bPendingLogin)
  local ShareSuit = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ShareSuit)
  ShareSuit:RefreshAllTeammateShareSuit()
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  LogicXSuit.RefreshAllTeammateRelic()
  local Enum_LobbyDownloadResType = LobbySystem.Enum_LobbyDownloadResType
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_TEAM_RES_DOWNLOAD_UI, uid, Enum_LobbyDownloadResType.PlayerRole)
end
function logic_share_bag_team_util:UpdateAvatarWithShareBagItemList(uid, usingSharedItemList, bForceUpdate, bPendingLogin)
  log(bWriteLog and string.format("logic_share_bag_team_util:UpdateAvatarWithShareBagItemList. uid=%s, usingSharedItemList=%s, bForceUpdate=%s", tostring(uid), tostring(usingSharedItemList), tostring(bForceUpdate)))
  if not uid then
    return
  end
  if type(uid) == "number" then
    uid = tostring(uid)
  end
  log_tree("UpdateAvatarWithShareBagItemList uid: " .. uid .. " usingSharedItemList = ", usingSharedItemList)
  local bSelf = uid == DataMgr.roleData.uid
  if bSelf and bPendingLogin then
    log(bWriteLog and "UpdateAvatarWithShareBagItemList need not process my avatar pending login .")
    return
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local TableUtil = require("common.table_util")
  local lastSelectSharedItemList = self._lastSelectSharedItems[uid] or {}
  usingSharedItemList = usingSharedItemList or {}
  if not bForceUpdate and TableUtil.IsDataEqual(lastSelectSharedItemList, usingSharedItemList) then
    local bAllWear = true
    log(bWriteLog and "UpdateAvatarWithShareBagItemList uid: " .. uid .. " IsDataEqual check all items are equipped.")
    local Avatar = TeamAvatarManager.GetAvatarByUid(uid)
    if Avatar then
      for k, v in pairs(usingSharedItemList) do
        local itemId = type(v) == "table" and v.itemId or v
        if not Avatar:HasEquiped(itemId) then
          bAllWear = false
          break
        end
      end
    end
    if bAllWear then
      log(bWriteLog and "UpdateAvatarWithShareBagItemList uid: " .. uid .. " IsDataEqual and all items are equipped return.")
      return
    end
  end
  self._lastSelectSharedItems[uid] = usingSharedItemList
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if bSelf then
    for k, v in pairs(self.C_SUBTYPE_LIST_NEED_PUTOFF) do
      TeamAvatarManager.PutoffSubtype(uid, v)
    end
    local WearInfo = AvatarData.GetWearInfo(true)
    for k, v in pairs(WearInfo) do
      TeamAvatarManager.PutonEquipment(uid, v.ItemID, v)
    end
    local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
    if memberInfo and memberInfo.skin_info then
      local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
      local insID = DataMgr.equipmentSkinInsIDTable and DataMgr.equipmentSkinInsIDTable[DataMgr.BagSkinTableIndex]
      local bagItemID = logic_wardrobe_avatar:GetEquipmentItemIDBySkinInsID(DataMgr.BagSkinTableIndex, insID)
      if bagItemID ~= 0 and bagItemID ~= -1 then
        TeamAvatarManager.PutonEquipment(uid, bagItemID)
      end
      if memberInfo.skin_info.helmet_level and memberInfo.skin_info.helmet_skin then
        local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local currentHeadShow = fashionbag_data:GetHeadShow(fashionbag_data:GetFashionBagUseIndex())
        local currentHelmetSkin = fashionbag_data:GetHelmetSkin(fashionbag_data:GetFashionBagUseIndex())
        if not currentHeadShow or currentHeadShow == 0 or currentHeadShow == currentHelmetSkin then
          local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
          local data = wardrobe_data:GetHallDepotItemDataByInsID(currentHelmetSkin)
          if data ~= nil then
            local currentHelmetSkinResID = data.resID
            local currentHelmetSkinLevel = fashionbag_data:GetHelmetLevel()
            local helmetItemID = DataMgr.GetEquipmentItemIDByResID(currentHelmetSkinLevel, currentHelmetSkinResID)
            if helmetItemID then
              TeamAvatarManager.PutonEquipment(uid, helmetItemID)
            end
          else
            log(bWriteLog and "UpdateAvatarWithShareBagItemList no wardrobe item for insID:  " .. tostring(currentHelmetSkin))
          end
        end
      end
    end
  else
    local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
    if not memberInfo then
      return
    end
    for k, v in pairs(self.C_SUBTYPE_LIST_NEED_PUTOFF) do
      TeamAvatarManager.PutoffSubtype(uid, v)
    end
    if memberInfo.wear_ext then
      for k, v in pairs(memberInfo.wear_ext) do
        local resID = v[1]
        local tAvatarCustom = AvatarData.ConvertToAvatarCustom(v, true)
        TeamAvatarManager.PutonEquipment(uid, resID, tAvatarCustom)
      end
    end
    if memberInfo.skin_info then
      if memberInfo.skin_info.bag_level and memberInfo.skin_info.bag_skin then
        local bagItemID = DataMgr.GetEquipmentItemIDByResID(memberInfo.skin_info.bag_level, memberInfo.skin_info.bag_skin)
        if bagItemID then
          TeamAvatarManager.PutonEquipment(uid, bagItemID)
        end
      end
      if memberInfo.skin_info.helmet_level and memberInfo.skin_info.helmet_skin then
        local helmetItemID = DataMgr.GetEquipmentItemIDByResID(memberInfo.skin_info.helmet_level, memberInfo.skin_info.helmet_skin)
        if helmetItemID then
          TeamAvatarManager.PutonEquipment(uid, helmetItemID)
        end
      end
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.OnMemberWeaponChange(uid)
  if usingSharedItemList and next(usingSharedItemList) then
    for k, v in pairs(usingSharedItemList) do
      local itemId = type(v) == "table" and v.itemId or v
      local customData = type(v) == "table" and v.CustomData or nil
      local itemIDForDisplay = itemId
      local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
      local itemCfg = CDataTable.GetTableData("Item", itemId)
      local curItemType = itemCfg and itemCfg.ItemType
      local curItemSubType = itemCfg and itemCfg.ItemSubType
      if ModelDisplayTypeHelper.IsBag(curItemType, curItemSubType) or ModelDisplayTypeHelper.IsNoLevelBag(curItemType, curItemSubType) or ModelDisplayTypeHelper.IsNoLevelHelmet(curItemType, curItemSubType) then
        itemIDForDisplay = DataMgr.GetEquipmentItemIDByResID(3, itemId)
      end
      local tAvatarCustom = {}
      if customData and customData.pattern and customData.color then
        tAvatarCustom.PatternID = customData.pattern
        tAvatarCustom.ColorID = customData.color
      end
      TeamAvatarManager.PutonEquipment(uid, itemIDForDisplay, tAvatarCustom)
    end
  end
end
function logic_share_bag_team_util:UpdatePetAvatarWithShareBagInfo(uid, bForceUpdate, bPendingLogin)
  log(bWriteLog and string.format("logic_share_bag_team_util:UpdatePetAvatarWithShareBagInfo. uid=%s", tostring(uid)))
  local bUpdateDirectly = true
  if not bForceUpdate and tostring(uid) == DataMgr.roleData.uid and self:IsInShareBagUsingPanel() then
    bUpdateDirectly = false
  end
  if bUpdateDirectly then
    self:UpdatePetAvatarWithShareBagInfoDirectly(uid)
  end
end
function logic_share_bag_team_util:UpdatePetAvatarWithShareBagInfoDirectly(uid)
  log(bWriteLog and string.format("logic_share_bag_team_util:UpdatePetAvatarWithShareBagInfoDirectly. uid=%s", tostring(uid)))
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  local sharePetData = logic_share_bag_team_util:GetUsingSharePetInfoByUID(uid)
  if sharePetData then
    log(bWriteLog and string.format("logic_share_bag_team_util:UpdatePetAvatarWithShareBagInfo. uid=%s sharePetData.id=%s", tostring(uid), tostring(sharePetData and sharePetData.id)))
    local petData = logic_pet:FormatPetDataByServerInfo(uid, sharePetData)
    TeamAvatarManager.CreatePet(uid, petData)
  else
    local pet_info
    if tostring(uid) == tostring(DataMgr.roleData.uid) then
      pet_info = logic_pet:GetPetDataByInsID(logic_pet:GetEquipedPetInsID())
    else
      pet_info = memberInfo and memberInfo.pet_info
    end
    if pet_info ~= nil and pet_info.id ~= 0 then
      log(bWriteLog and string.format("logic_share_bag_team_util:UpdatePetAvatarWithShareBagInfo. uid=%s pet_info.id=%s", tostring(uid), tostring(pet_info.id)))
      local petLevel = logic_pet:GetPetLevelByExp(pet_info.id, pet_info.exp)
      local PetData = logic_pet:FormatPetDataByServerInfo(uid, pet_info)
      TeamAvatarManager.CreatePet(uid, PetData)
      if memberInfo and memberInfo.name ~= nil then
        TeamAvatarManager.SetPetName(uid, memberInfo.name)
      end
    else
      log(bWriteLog and string.format("logic_share_bag_team_util:UpdatePetAvatarWithShareBagInfo. uid=%s pet_info = %s, pet_info.id=%s", tostring(uid), tostring(pet_info), tostring(pet_info and pet_info.id)))
      TeamAvatarManager.DestroyPet(uid)
    end
  end
end
function logic_share_bag_team_util:GetUsingSharePetInfoByUID(uid)
  uid = tostring(uid)
  local petData = self.uid2SelectPetData and self.uid2SelectPetData[uid] and self.uid2SelectPetData[uid].petData
  return petData
end
function logic_share_bag_team_util:GetUsingShareWeaponIDByUID(uid)
  uid = tostring(uid)
  return self.uid2SelectGun and self.uid2SelectGun[uid] or 0
end
function logic_share_bag_team_util:GetRemainUseTimesInfo(shareItemType)
  if not shareItemType then
    return nil
  end
  return self.remainUseTimes and self.remainUseTimes[shareItemType]
end
function logic_share_bag_team_util:SetRemainUseTimes(shareItemType, usedTimes, maxUseTimes)
  if not shareItemType then
    return
  end
  if not self.remainUseTimes then
    self.remainUseTimes = {}
  end
  self.remainUseTimes[shareItemType] = {
    usedTimes = usedTimes or 0,
    maxUseTimes = maxUseTimes or 0
  }
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_SHARE_BAG_REMAIN_INFO, shareItemType)
end
function logic_share_bag_team_util:ResetMyAvatarWeapon()
  local selfUid = DataMgr.roleData.uid
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local weaponID = DataMgr.Weapon_ID
  if not weaponID or tonumber(weaponID) == 0 then
    LobbyAvatarManager.UnEquipWeapon(selfUid)
  else
    local weapon_wear_info = {}
    if DataMgr.Weapon_Skin_ResID and DataMgr.Weapon_Skin_ResID ~= 0 then
      weapon_wear_info.weaponId = weaponID
      weapon_wear_info.skinId = DataMgr.Weapon_Skin_ResID
      weapon_wear_info.usingDiyRecommend = DataMgr.Weapon_Diy_Using_Recommend
      weapon_wear_info.diyPlanId = DataMgr.Weapon_Diy_PlanID
    else
      weapon_wear_info.weaponId = 0
      weapon_wear_info.skinId = 0
      weapon_wear_info.usingDiyRecommend = false
      weapon_wear_info.diyPlanId = ""
    end
    LobbyAvatarManager.EquipWeapon(selfUid, weapon_wear_info, nil, true)
    local ext_weapon_list = DataMgr.Extra_Weapon_Info_List
    if ext_weapon_list and next(ext_weapon_list) then
      for _, extra_weapon in pairs(ext_weapon_list) do
        if not extra_weapon.weapon_id or tonumber(extra_weapon.weapon_id) == 0 then
          LobbyAvatarManager.UnEquipExtraWeapon(selfUid)
        else
          weapon_wear_info.weaponId = extra_weapon.weapon_id
          weapon_wear_info.skinId = extra_weapon.skin_id
          weapon_wear_info.usingDiyRecommend = extra_weapon.is_using_recommend
          weapon_wear_info.diyPlanId = extra_weapon.cur_use_plan
          LobbyAvatarManager.EquipWeapon(selfUid, weapon_wear_info, nil, false)
        end
      end
    end
  end
end
function logic_share_bag_team_util:IsInShareBagUsingPanel()
  if UIManager.IsUIShow(UIManager.UI_Config.SharePackage_Edit_UIBP) then
    return true
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_share_bag_team_util = class(CModuleBase, nil, logic_share_bag_team_util)
return Clogic_share_bag_team_util