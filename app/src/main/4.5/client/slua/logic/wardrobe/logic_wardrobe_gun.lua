local WardrobeGunLogic = {
  subTabId = "Gun",
  recordTime = 0,
  bTriggerPutOn = false,
  SpecialWeaponData = {}
}
local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local IsGunMapInited = false
local TypeToGunMap = {}
local SubTabItemCount = {}
local hasGunSkinList = false
local hasSubTabItemCount = false
local previewGunResID = 0
local Wardrobe_GunID = 0
local Wardrobe_keep_GunID = 0
local Wardrobe_Extra_Weapon_Id_List = {}
local isPutOnGun = false
local Wardrobe_ShareBag_Config_GunID = 0
function WardrobeGunLogic:GetGunSkinListReq()
  if not hasGunSkinList then
    log(bWriteLog and "WardrobeGunLogic:GetGunSkinListReq")
    local ArmorySystem = require("client.logic.armory.logic_armory")
    ArmorySystem.get_weapon_skin_list(ArmorySystem.ENUM_REQ_Wardrobe)
  end
end
function WardrobeGunLogic:OnGunSkinListRes()
  log(bWriteLog and "WardrobeGunLogic:OnGunSkinListRes")
  log(bWriteLog and "halendeng test gun refresh")
  local ArmorySystem = require("client.logic.armory.logic_armory")
  if not hasGunSkinList and ArmorySystem.rsp_list then
    hasGunSkinList = true
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_GUN_LIST, -1)
  end
end
function WardrobeGunLogic:InitGunCountData()
  if hasSubTabItemCount then
    log(bWriteLog and string.format("WardrobeGunLogic:RebuildGunData has GunSkinList data."))
    return
  end
  local ArmorySystem = require("client.logic.armory.logic_armory")
  if not ArmorySystem.rsp_list or not ArmorySystem.rsp_list.skin_list then
    log(bWriteLog and string.format("WardrobeGunLogic:RebuildGunData rsp_list or rsp_list.skin_list is nil."))
    return
  end
  log(bWriteLog and string.format("WardrobeGunLogic:RebuildGunData init gun count."))
  self:UpdateSubTabItemCount()
  hasSubTabItemCount = true
end
function WardrobeGunLogic:InitGunTable()
  if IsGunMapInited then
    log(bWriteLog and string.format("WardrobeGunLogic:InitGunTable is inited."))
    return
  end
  IsGunMapInited = true
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local ArmoryTable = CDataTable.GetTable("ArmoryConfig")
  for k, v in pairs(ArmoryTable) do
    local itemDataCfg = CDataTable.GetTableData("Item", v.WeaponID)
    if itemDataCfg and itemDataCfg.WardrobeMainTab == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon then
      local gunArray = TypeToGunMap[v.WeaponType]
      if gunArray == nil then
        gunArray = {}
        TypeToGunMap[v.WeaponType] = gunArray
      end
      table.insert(gunArray, v)
      SubTabItemCount[v.WeaponID] = 0
    end
  end
end
function WardrobeGunLogic:InitGunIDByLoginGunID()
  self:SetGunID(0)
  if DataMgr.Weapon_ID ~= 0 then
    local gunCfg = CDataTable.GetTableData("ArmoryConfig", DataMgr.Weapon_ID)
    if gunCfg ~= nil then
      self:SetGunID(DataMgr.Weapon_ID)
    end
  end
end
function WardrobeGunLogic:GetGunTypeArray()
  local tempTable = {}
  local armoryTypeCfgTable = CDataTable.GetTable("ArmoryTypeConfig")
  for _, v in pairs(armoryTypeCfgTable) do
    table.insert(tempTable, v)
  end
  table.sort(tempTable, function(a, b)
    return a.TypeID < b.TypeID
  end)
  local gunType = {}
  for _, v in ipairs(tempTable) do
    table.insert(gunType, v)
  end
  return gunType
end
function WardrobeGunLogic:InitGunInfo(info, skinInsID)
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(skinInsID)
  if itemData then
    if not wardrobeLogic:IsCanUse(itemData.resID) then
      info.skinResID = 0
    else
      info.skinResID = itemData.resID
    end
  else
    info.skinResID = 0
  end
end
function WardrobeGunLogic:GetSkinList(skinList, sortViaTime, gunID, DataSource, tExtraData)
  local bIsFilterValidTimeItem = tExtraData and tExtraData.bIsFilterValidTimeItem
  local bIsFilterDiy = tExtraData and tExtraData.bIsFilterDiy
  local bIsFilterLockedItem = tExtraData and tExtraData.bIsFilterLockedItem
  local bIsIgnoreSort = tExtraData and tExtraData.bIsIgnoreSort
  local itemListTable = {}
  gunID = gunID or self:GetGunID()
  if gunID == 0 then
    gunID = self:GetKeepGunID()
  end
  local skinInsID = self:GetSkinIdByWeaponID(gunID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local depotItemList = wardrobe_data:GetArrayHallDepotItemInfo(DataSource)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInShareBagMode = logic_wardrobe:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
  if bInShareBagMode then
    bIsFilterValidTimeItem = true
  end
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  for _, v in pairs(depotItemList) do
    if v.resID ~= 1081205 then
      local skinInfo = skinList[v.resID]
      local isWear = false
      if skinInfo and DataMgr.IsValidTime(v.expireTS) then
        if skinInsID ~= nil then
          isWear = tonumber(v.insID) == skinInsID
          log(bWriteLog and "isWear .. " .. tostring(isWear))
        end
        local itemInfo = logic_wardrobe:ArrayHallDepotToCommonItem(v, #itemListTable, isWear, true, false, false, false)
        local bCanShow = true
        if bIsFilterValidTimeItem and itemInfo.hasLimitTime then
          bCanShow = false
        end
        if bIsFilterDiy and weapon_diy_system:IsDIYWeapon(v.resID) then
          bCanShow = false
        end
        if bIsFilterLockedItem and 0 >= itemInfo.count then
          bCanShow = false
        end
        if bCanShow then
          table.insert(itemListTable, itemInfo)
          local info = self:GetGunDiyInfo(v.resID)
          if info then
            local curPlanId = weapon_diy_system:GetCurUsePlanIdByWeaponId(v.resID)
            itemInfo.planID = weapon_diy_system:GetRecommendPlanIdByWeaponId(v.resID)
            if curPlanId ~= itemInfo.planID then
              itemInfo.isUsing = false
            end
            for i, j in pairs(info) do
              if j.status ~= 1 and j.status ~= 2 then
                local TableUtil = require("common.table_util")
                local itemInfoDIY = TableUtil.CopyTable(itemInfo)
                itemInfoDIY.planID = i
                itemInfoDIY.isUsing = false
                table.insert(itemListTable, itemInfoDIY)
                log(bWriteLog and "curPlanId = " .. tostring(curPlanId) .. " || i = " .. tostring(i))
                if curPlanId == i and skinInsID == tonumber(itemInfoDIY.ins_id) then
                  itemInfoDIY.isUsing = true
                end
              end
            end
          end
        end
      end
    end
  end
  if not bIsFilterLockedItem then
    local tempData = {}
    for _, info in pairs(itemListTable) do
      if info.lock_cnt and 0 < info.lock_cnt then
        if info.count == 0 then
          info.count = info.lock_cnt
        else
          local tFreezeData = DeepCopy(info)
          tFreezeData.count = info.lock_cnt
          info.lock_cnt = 0
          tempData[#tempData + 1] = tFreezeData
        end
      end
    end
    local TableUtil = require("common.table_util")
    TableUtil.TableConcat(itemListTable, tempData)
  end
  if not bIsIgnoreSort then
    logic_wardrobe:SortItemTable(itemListTable, sortViaTime)
  end
  return itemListTable
end
function WardrobeGunLogic:GetAllWeaponSkinList(skinList, sortViaTime, bIsFilterValidTimeItem, bIsFilterDiy, bIsFilterLockedItem, bIsIgnoreSort)
  local itemListTable = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local depotItemList = wardrobe_data:GetArrayHallDepotItemInfo(EWardrobeDataSource.Wardrobe)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInShareBagMode = logic_wardrobe:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
  if bInShareBagMode then
    bIsFilterValidTimeItem = true
  end
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  for _, v in pairs(depotItemList) do
    local skinInfo = skinList[v.resID]
    local isWear = false
    if skinInfo and DataMgr.IsValidTime(v.expireTS) then
      local itemInfo = logic_wardrobe:ArrayHallDepotToCommonItem(v, #itemListTable, isWear, true, false, false, false)
      itemInfo.weapon_id = skinInfo.weaponID
      local bCanShow = true
      if bIsFilterValidTimeItem and itemInfo.hasLimitTime then
        bCanShow = false
      end
      if bIsFilterDiy and weapon_diy_system:IsDIYWeapon(v.resID) then
        bCanShow = false
      end
      if bIsFilterLockedItem and itemInfo.count <= 0 then
        bCanShow = false
      end
      if bCanShow then
        table.insert(itemListTable, itemInfo)
        local info = self:GetGunDiyInfo(v.resID)
        if info then
          local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
          local curPlanId = weapon_diy_system:GetCurUsePlanIdByWeaponId(v.resID)
          itemInfo.planID = weapon_diy_system:GetRecommendPlanIdByWeaponId(v.resID)
          if curPlanId ~= itemInfo.planID then
            itemInfo.isUsing = false
          end
          for i, j in pairs(info) do
            if j.status ~= 1 and j.status ~= 2 then
              local TableUtil = require("common.table_util")
              local itemInfoDIY = TableUtil.CopyTable(itemInfo)
              itemInfoDIY.planID = i
              itemInfoDIY.isUsing = false
              table.insert(itemListTable, itemInfoDIY)
            end
          end
        end
      end
    end
  end
  if not bIsFilterLockedItem then
    local TableUtil = require("common.table_util")
    local tempData = {}
    for _, info in pairs(itemListTable) do
      if info.lock_cnt and 0 < info.lock_cnt then
        if info.count == 0 then
          info.count = info.lock_cnt
        else
          local tFreezeData = TableUtil.CopyTable(info)
          tFreezeData.count = info.lock_cnt
          info.lock_cnt = 0
          tempData[#tempData + 1] = tFreezeData
        end
      end
    end
    local TableUtil = require("common.table_util")
    TableUtil.TableConcat(itemListTable, tempData)
  end
  if not bIsIgnoreSort then
    logic_wardrobe:SortItemTable(itemListTable, sortViaTime)
  end
  return itemListTable
end
function WardrobeGunLogic:UpdateGunCount()
  log(bWriteLog and "WardrobeGunLogic:UpdateGunCount")
end
function WardrobeGunLogic:UpdateCurrentGunAvatar(gunID, skinID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(skinID)
  if itemData == nil then
    if 0 < gunID then
      self:PutOnGunAvatar(gunID, 0, 0)
    else
      self:PutOffGunAvatar()
    end
  else
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    local planID = weapon_diy_system:GetCurUsePlanIdByWeaponId(itemData.resID)
    local WeaponResID = itemData.resID
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    if WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag then
      local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
      if not FashionBagEditUtils:UpdateAvatarTarotWeapon(nil, skinID) then
        self:PutOnGunAvatar(gunID, WeaponResID, planID)
      end
    else
      self:PutOnGunAvatar(gunID, WeaponResID, planID)
    end
  end
end
function WardrobeGunLogic:UpdateExtraGunAvatar(gunID, skinID)
  if gunID and 0 < gunID and self:IsMeleeWeapon(gunID) then
    local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
    local nLgdResId = logic_legend_weapon:GetSelectedResId()
    if 0 < nLgdResId and logic_legend_weapon:IsSceneLobbyOn() then
      local E_PERM = logic_legend_weapon.E_LGD_WPN_PERM
      local nPerm = logic_legend_weapon:GetPermissionType(nLgdResId)
      if nPerm == E_PERM.PERMANENT or nPerm == E_PERM.TRIAL_ACTIVATED then
        return self:PutOnExtraGunAvatar(nLgdResId, nLgdResId, nil)
      end
    end
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(skinID)
  if itemData == nil then
    if 0 < gunID then
      return self:PutOnExtraGunAvatar(gunID, 0, nil)
    else
      return false
    end
  else
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    local planID = weapon_diy_system:GetCurUsePlanIdByWeaponId(itemData.resID)
    return self:PutOnExtraGunAvatar(gunID, itemData.resID, planID)
  end
end
function WardrobeGunLogic:IsMeleeWeapon(weaponID)
  if not weaponID or weaponID == 0 then
    return false
  end
  local ItemCfg = CDataTable.GetTableData("Item", weaponID)
  return ItemCfg ~= nil and ItemCfg.ItemSubType == 108
end
function WardrobeGunLogic.OnEquipStateChange()
  local gunID = 0
  local secondGunIDList = {}
  local skinInsID
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.FashionBag then
    gunID = WardrobeGunLogic:GetGunID()
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    local extraWeaponIdList = LobbyAvatarManager.GetExtraWeaponIdList()
    if extraWeaponIdList then
      secondGunIDList = extraWeaponIdList
    end
    for _, secondGunID in pairs(secondGunIDList) do
      local secondSkinInsID = WardrobeGunLogic:GetSkinIdByWeaponID(secondGunID)
      if secondSkinInsID then
        log(bWriteLog and "OnEquipStateChange, UpdateExtraGunAvatar " .. tostring(secondGunID) .. "  " .. tostring(secondSkinInsID))
        WardrobeGunLogic:UpdateExtraGunAvatar(secondGunID, secondSkinInsID)
      end
    end
    skinInsID = WardrobeGunLogic:GetSkinIdByWeaponID(gunID)
  else
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    gunID = FashionBagEditUtils:GetMainWeaponID()
    local secondGunID = FashionBagEditUtils:GetSecondWeaponID()
    if secondGunID ~= 0 then
      local secondSkinInsID = FashionBagEditUtils:GetSkinIDByWeaponID(secondGunID)
      if secondSkinInsID then
        log(bWriteLog and "OnEquipStateChange, UpdateExtraGunAvatar " .. tostring(secondGunID) .. "  " .. tostring(secondSkinInsID))
        WardrobeGunLogic:UpdateExtraGunAvatar(secondGunID, secondSkinInsID)
      end
    end
    skinInsID = FashionBagEditUtils:GetSkinIDByWeaponID(gunID)
  end
  if gunID == 0 then
    return
  end
  if skinInsID == nil then
    return
  end
  if DataMgr.Weapon_ID == gunID then
    WardrobeGunLogic:UpdateCurrentGunAvatar(gunID, skinInsID)
  end
end
function WardrobeGunLogic:OnPutOnStateChange()
  log(bWriteLog and "WardrobeGunLogic:OnPutOnStateChange")
  local ArmorySystem = require("client.logic.armory.logic_armory")
  if self:GetIsPutOnGun() then
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    local extraWeaponIdList = LobbyAvatarManager.GetExtraWeaponIdList()
    self:SetExtraWeaponIdList(extraWeaponIdList)
    self:put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, 0)
  else
    local gunID = self:GetGunID()
    log(bWriteLog and "WardrobeGunLogic:OnPutOnStateChange gunID=" .. tostring(gunID))
    local extraWeaponIdList = self:GetExtraWeaponIdList()
    if gunID == 0 then
      local keepGunID = self:GetKeepGunID()
      if keepGunID and keepGunID ~= 0 then
        self:SetGunID(keepGunID)
        self:put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, keepGunID, extraWeaponIdList)
      else
        self:put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, 101001)
      end
    else
      self:put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, gunID, extraWeaponIdList)
    end
  end
end
function WardrobeGunLogic:GetAllGun()
  if not IsGunMapInited then
    WardrobeGunLogic:InitGunTable()
  end
  return TypeToGunMap
end
function WardrobeGunLogic:GetGunArrayByGunType(gunType)
  if not IsGunMapInited then
    WardrobeGunLogic:InitGunTable()
  end
  local gunArray = TypeToGunMap[gunType]
  if not gunArray then
    return nil
  end
  if gunType == 8 then
    local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
    local lgdWpnCfg = logic_legend_weapon:GetAllCfg()
    if lgdWpnCfg then
      for i = #gunArray, 1, -1 do
        local nResId = gunArray[i].WeaponID
        if lgdWpnCfg[nResId] and not logic_legend_weapon:IsLgdWpnValid(nResId) then
          table.remove(gunArray, i)
        end
      end
      for nResId, _ in pairs(lgdWpnCfg) do
        if logic_legend_weapon:IsLgdWpnValid(nResId) then
          local bExist = false
          for _, v in ipairs(gunArray) do
            if v.WeaponID == nResId then
              bExist = true
              break
            end
          end
          if not bExist then
            table.insert(gunArray, {
              WeaponID = nResId,
              WeaponType = gunType,
              IsLegendWeapon = true
            })
          end
        end
      end
    end
  end
  return gunArray
end
function WardrobeGunLogic:SetPreviewGunResID(id)
  previewGunResID = id
end
function WardrobeGunLogic:GetPreviewGunResID()
  return previewGunResID
end
function WardrobeGunLogic:GetGunID()
  return Wardrobe_GunID
end
function WardrobeGunLogic:SetGunID(id)
  Wardrobe_GunID = id
end
function WardrobeGunLogic:GetKeepGunID()
  return Wardrobe_keep_GunID
end
function WardrobeGunLogic:SetKeepGunID(id)
  Wardrobe_keep_GunID = id
end
function WardrobeGunLogic:GetShareBagConfigGunID()
  return Wardrobe_ShareBag_Config_GunID
end
function WardrobeGunLogic:SetShareBagConfigGunID(id)
  Wardrobe_ShareBag_Config_GunID = id
end
function WardrobeGunLogic:GetExtraWeaponIdList()
  return Wardrobe_Extra_Weapon_Id_List
end
function WardrobeGunLogic:SetExtraWeaponIdList(weaponIdList)
  Wardrobe_Extra_Weapon_Id_List = weaponIdList
end
function WardrobeGunLogic:GetIsPutOnGun()
  return isPutOnGun
end
function WardrobeGunLogic:SetIsPutOnGun(putOn)
  isPutOnGun = putOn
end
function WardrobeGunLogic:HasGunSkinList()
  return hasGunSkinList
end
function WardrobeGunLogic:GetGunDiyInfo(id)
  local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
  local schemeData = weapon_diy_rec_scheme[tonumber(id)]
  if schemeData ~= nil then
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    if weapon_diy_system.weaponData ~= nil and weapon_diy_system.weaponData[id] ~= nil then
      return weapon_diy_system.weaponData[id].my_plan_table
    else
      weapon_diy_system:GetDiyItemSummaryDataReq(id)
    end
  end
end
function WardrobeGunLogic:put_on_weapon_wear(client_data, weapon_id, extra_weapon_id_list)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_put_on_weapon_wear(client_data, weapon_id, extra_weapon_id_list)
end
function WardrobeGunLogic:pspace_put_on_weapon_wear(client_data, weapon_id, extra_weapon_id_list)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_pspace_put_on_weapon_wear(client_data, weapon_id, extra_weapon_id_list)
end
function WardrobeGunLogic:on_put_on_weapon_wear_rsp(client_data, res, weapon_id, new_skin_id, extra_weapon_list)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if res == 0 then
    if weapon_id and 0 < weapon_id and weapon_id ~= 108005 and self:IsMeleeWeapon(weapon_id) then
      local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
      if not logic_legend_weapon:IsLegendWeaponItem(weapon_id) and 0 < logic_legend_weapon:GetActiveLegendWeaponIdForUid(DataMgr.roleData and DataMgr.roleData.uid or 0) then
        logic_legend_weapon:SetSceneLobbyOff()
      end
    end
    HallThemeUtils.ProcGunWear(weapon_id, new_skin_id, extra_weapon_list)
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(new_skin_id)
    local resID = 0
    if itemData and itemData.resID then
      resID = itemData.resID
    end
    DataMgr.InitWeaponData(weapon_id, resID, new_skin_id)
    DataMgr.InitExtraWeaponList(extra_weapon_list)
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    fashionbag_data:UpdateCurrentFashionBagWeaponSkin(weapon_id, new_skin_id)
    local ArmorySystem = require("client.logic.armory.logic_armory")
    if client_data == ArmorySystem.ENUM_REQ_Wardrobe then
      if weapon_id == 0 then
        self:PutOffGunAvatar()
        local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
        logic_legend_weapon:SetSceneLobbyOff()
      end
      self:SetKeepGunID(self:GetGunID())
      local nDisplayGunId = weapon_id
      if weapon_id == 108005 then
        local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
        local nLgd = logic_legend_weapon:GetActiveLegendWeaponIdForUid(DataMgr.roleData and DataMgr.roleData.uid or 0)
        if 0 < nLgd then
          nDisplayGunId = nLgd
        end
      end
      self:SetGunID(nDisplayGunId)
      EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, true, nDisplayGunId, true)
    end
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    BasicDataAvatarWearInfo:GetOrReqData(DataMgr.roleData.uid, function(callUid, callInfo)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, callUid)
    end, {bForceReq = true}, Enum_AvatarShowSource.WardrobeLogic)
  elseif res ~= nil then
    ShowNotice(res)
  end
  local TimeUtil = require("client.common.time_util")
  WardrobeGunLogic.recordTime = TimeUtil.GetServerTimeInSec()
  WardrobeGunLogic.bTriggerPutOn = true
end
function WardrobeGunLogic:PutOnGunAvatar(gunID, skinID, planID)
  if gunID == nil or skinID == nil then
    return
  end
  local previewSkinID = 0 < skinID and skinID or gunID
  if previewSkinID ~= self:GetPreviewGunResID() or planID and DataMgr.Weapon_Diy_PlanID and planID ~= DataMgr.Weapon_Diy_PlanID then
    self:SetPreviewGunResID(previewSkinID)
    local weapon_wear_info = {weaponId = gunID, skinId = skinID}
    local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
    if not logic_legend_weapon:IsLegendWeaponItem(gunID) then
      DataMgr.Weapon_ID = gunID
    end
    if planID ~= nil and planID ~= "" then
      local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
      if WeaponDiySystem:IsPlanRecommend(planID) then
        DataMgr.InitWeaponDIYData(true, "")
        weapon_wear_info.usingDiyRecommend = true
        weapon_wear_info.diyPlanId = planID
      else
        DataMgr.InitWeaponDIYData(false, planID)
        weapon_wear_info.usingDiyRecommend = false
        weapon_wear_info.diyPlanId = planID
      end
    else
      local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
      local schemeData = weapon_diy_rec_scheme[tonumber(skinID)]
      if schemeData then
        DataMgr.InitWeaponDIYData(true, "")
        weapon_wear_info.usingDiyRecommend = true
        weapon_wear_info.diyPlanId = ""
      end
    end
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.EquipWeapon(DataMgr.roleData.uid, weapon_wear_info, nil, true)
    self:SetIsPutOnGun(true)
  else
  end
end
function WardrobeGunLogic:PutOnExtraGunAvatar(gunID, skinID, planID)
  if gunID == nil or skinID == nil then
    return false
  end
  local previewSkinID = 0 < skinID and skinID or gunID
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetModel(DataMgr.roleData.uid)
  if avatar == nil or avatar.BP_LobbyWeaponManager == nil then
    return false
  end
  local curEquipWeaponSkinID = 0
  local slotName = avatar.BP_LobbyWeaponManager:GetWeaponSocketNameByResId(previewSkinID)
  local weapon = avatar.BP_LobbyWeaponManager:GetWeaponBySocketID(slotName)
  if weapon then
    curEquipWeaponSkinID = weapon:GetItemDefineID().TypeSpecificID
  end
  if previewSkinID ~= curEquipWeaponSkinID or planID and DataMgr.Extra_Weapon_Info_List[gunID] and DataMgr.Extra_Weapon_Info_List[gunID].cur_use_plan and planID ~= DataMgr.Extra_Weapon_Info_List[gunID].cur_use_plan then
    local weapon_wear_info = {weaponId = gunID, skinId = skinID}
    if planID ~= nil and planID ~= "" then
      local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
      local ret = WeaponDiySystem:IsPlanRecommend(planID)
      weapon_wear_info.usingDiyRecommend = ret
      weapon_wear_info.diyPlanId = planID
    else
      local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
      local schemeData = weapon_diy_rec_scheme[tonumber(skinID)]
      if schemeData then
        weapon_wear_info.usingDiyRecommend = true
        weapon_wear_info.diyPlanId = ""
      end
    end
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.EquipWeapon(DataMgr.roleData.uid, weapon_wear_info, nil, false)
  end
  return true
end
function WardrobeGunLogic:PutOffGunAvatar()
  self:SetPreviewGunResID(0)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.UnEquipWeapon(DataMgr.roleData.uid)
  self:SetIsPutOnGun(false)
end
function WardrobeGunLogic:SwitchShowGun(show)
  if show and not isPutOnGun then
    self:OnPutOnStateChange()
  end
end
function WardrobeGunLogic:RevertGun(showGun)
  if not showGun and isPutOnGun then
    self:OnPutOnStateChange()
  end
end
function WardrobeGunLogic:GetSkinIdByWeaponID(WeaponID)
  local skinid = 0
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bag = fashionbag_data:GetCurrentFashionBag()
  if bag and bag.weapon_skin_list ~= nil and bag.weapon_skin_list[WeaponID] ~= nil then
    skinid = bag.weapon_skin_list[WeaponID].skin_id
  end
  return skinid
end
function WardrobeGunLogic:UpdateSubTabItemCount(DataSource)
  if not IsGunMapInited then
    WardrobeGunLogic:InitGunTable()
  end
  local ArmorySystem = require("client.logic.armory.logic_armory")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for WeaponID, _v in pairs(SubTabItemCount) do
    local count = 0
    local skinList = ArmorySystem.GetSkinListByWeaponID(WeaponID)
    if skinList then
      for skin, _ in pairs(skinList) do
        local itemCount = wardrobe_data:GetHallDepotItemCountByResID(skin, true, DataSource)
        if 0 < itemCount then
          count = count + itemCount
        end
      end
    end
    SubTabItemCount[WeaponID] = count
  end
end
function WardrobeGunLogic:GetSubTabItemCount(WeaponID)
  self:InitGunCountData()
  return SubTabItemCount[WeaponID] or 0
end
function WardrobeGunLogic:GetTabItemCount(GunType)
  self:InitGunCountData()
  local gunArray = self:GetGunArrayByGunType(GunType)
  local cnt = 0
  if gunArray and next(gunArray) then
    for k, v in pairs(gunArray) do
      for WeaponID, _v in pairs(SubTabItemCount) do
        if tonumber(v.WeaponID) == tonumber(WeaponID) then
          cnt = cnt + _v
        end
      end
    end
  else
    log_error("WardrobeGunLogic:GetTabItemCount. GunType is not exist. GunType =", GunType)
  end
  return cnt
end
function WardrobeGunLogic:GetSubTabItemCountList()
  self:InitGunCountData()
  return SubTabItemCount
end
function WardrobeGunLogic:SetTriggerPutOn(bTrigger)
  WardrobeGunLogic.bTriggerPutOn = bTrigger
end
function WardrobeGunLogic.OnLogOut()
  WardrobeGunLogic:ResSpecialWeaponData({})
end
function WardrobeGunLogic:change_special_weapon_skin_req(weapon_id, inst_id)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_change_special_weapon_skin_req(weapon_id, inst_id)
end
function WardrobeGunLogic:on_change_special_weapon_skin_rsp(weapon_id, instid)
  self.SpecialWeaponData[weapon_id] = instid
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_VEHICLE_SLOT_DATA_CHANGE)
end
function WardrobeGunLogic:InitSpecialWeaponData()
  if not next(self.SpecialWeaponData) then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_get_special_weapon_wear_info_req()
  end
end
function WardrobeGunLogic:ResSpecialWeaponData(data)
  self.SpecialWeaponData = data or {}
end
function WardrobeGunLogic:GetSpecialWeaponData()
  return self.SpecialWeaponData or {}
end
function WardrobeGunLogic:IsSkinUsingByItemData(ins_id)
  if not next(self.SpecialWeaponData) then
    return false
  end
  for weapon_id, skin_id in pairs(self.SpecialWeaponData) do
    if skin_id == tonumber(ins_id) then
      return true
    end
  end
  return false
end
return WardrobeGunLogic