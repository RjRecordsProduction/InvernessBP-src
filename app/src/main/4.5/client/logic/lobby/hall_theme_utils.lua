local HallThemeUtils = {
  knapsack_ext_min = 0,
  knapsack_ext_weapon_skin = 1,
  knapsack_ext_vst_skin = 2,
  knapsack_ext_background = 3,
  knapsack_ext_second_weapon_skin = 4,
  knapsack_ext_max = 4,
  show_pos_background = 101,
  show_pos_vst_type = 102,
  show_pos_vst_skin = 103,
  default_vehicle_list = {
    [901] = 1901001,
    [902] = 1902001,
    [903] = 1903001,
    [904] = 1904001,
    [905] = 1905001,
    [906] = 1906001,
    [907] = 1907001,
    [908] = 1908001,
    [909] = 1909001,
    [910] = 1910001,
    [911] = 1911001,
    [912] = 1912001,
    [913] = 1913001,
    [914] = 1914001,
    [915] = 1915001
  },
  default_vehicle_map = {},
  resRoleData = {},
  themeBagInfo = {},
  nUseWearBagIndex = 1,
  homeThemeItemId = 0,
  homeThemeInstId = 0,
  themeVehicleShow = false,
  themeShowMode = 0,
  curShowAvatarData = nil,
  bIsWingManShowPermanently = true,
  CONST_RELATION_OP_TYPE = {BIND = 0, UNBIND = 1},
  CONST_RELATION_TYPE = {HELMET = 1, BAG = 2}
}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local ArmorySystem = require("client.logic.armory.logic_armory")
function HallThemeUtils.OnLogin()
  local roleData = LobbySystem.roleData
  HallThemeUtils.OnRecvRoleData(roleData)
end
function HallThemeUtils.OnRecvRoleData(res)
  log(bWriteLog and "HallThemeUtils.OnRecvRoleData")
  HallThemeUtils.default_vehicle_map = {}
  for k, v in pairs(HallThemeUtils.default_vehicle_list) do
    HallThemeUtils.default_vehicle_map[v] = 1
  end
  HallThemeUtils.resRoleData = res
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:SetAllKnapsackExtInfo(res.all_knapsack_ext_info)
  HallThemeUtils.homeThemeItemId = HallThemeUtils.GetMyHallThemeItemId()
  ArmorySystem.get_weapon_skin_list(ArmorySystem.ENUM_REQ_Wardrobe)
end
function HallThemeUtils.OnRecvRoleDepotData(depot)
  HallThemeUtils.homeThemeItemId = HallThemeUtils.GetMyHallThemeItemId()
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:ShowTheme()
  if HallThemeUtils.resRoleData and type(HallThemeUtils.resRoleData) == "table" then
    HallThemeUtils.resRoleData.  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  HallThemeUtils.UpdateThemeVehicleShow()
  if HallThemeUtils.GetThemeVehicleItemId() > 0 and login_module.ClientBasicCfg and PufferDownloader.PufferJsonDownloadReturn then
    local callback = function()
      HallThemeUtils.ShowThemeVehicle()
    end
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
      HallThemeUtils.GetThemeVehicleItemId()
    }, nil, callback)
  end
end
local GetAvatarShowInfo = function(bagIndex, showType)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(bagIndex)
  if bagInfo == nil then
    return
  end
  local showInfo = bagInfo.avatar_show and bagInfo.avatar_show[showType]
  if not showInfo then
    return
  end
  return showInfo
end
function HallThemeUtils.GetMyHallThemeItemId()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local info = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_background)
  if not info then
    log(bWriteLog and "HallThemeUtils.GetMyHallThemeItemId not Info")
    return 0
  end
  HallThemeUtils.SetThemeInstId(info.instid or 0)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(info.instid)
  if itemInfo == nil then
    log(bWriteLog and "HallThemeUtils.GetMyHallThemeItemId not itemInfo")
    return 0
  end
  log(bWriteLog and "HallThemeUtils.GetMyHallThemeItemId " .. tostring(itemInfo.resID))
  return itemInfo.resID
end
function HallThemeUtils.UpdateThemeVehicleShow()
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  HallThemeUtils.themeVehicleShow = logic_display_setting.GetData().OpenVehicle or false
end
function HallThemeUtils.GetThemeVehicleItemId()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemID = wardrobe_data:GetItemIDByInsID(DataMgr.vst_skin)
  return ItemID
end
function HallThemeUtils.GetThemeVehicleItemIdAndSource()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemID = wardrobe_data:GetItemIDByInsID(DataMgr.vst_skin)
  local Source = wardrobe_data:GetItemSource(DataMgr.vst_skin)
  return ItemID, Source
end
function HallThemeUtils.GetHallWingmanID()
  local itemID = 0
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local wingmanSkinInsID = fashionbag_data:GetWingmanSkin()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(wingmanSkinInsID)
  if itemInfo then
    itemID = itemInfo.resID
  end
  log(bWriteLog and "HallThemeUtils.GetHallWingmanID ItemID = " .. tostring(itemID))
  return itemID
end
function HallThemeUtils.GetThemeRelateItemId(tag, bFromRole)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local avatar_show = GetAvatarShowInfo(nUseWearBagIndex, tag)
  if avatar_show == nil then
    return 0
  end
  local resId = 0
  if bFromRole then
    local dept = HallThemeUtils.resRoleData.depot
    if dept == nil or dept.items == nil then
      return 0
    end
    local find = false
    for _, items in pairs(dept.items) do
      if items[avatar_show.instid] ~= nil then
        find = true
        break
      end
    end
    if not find then
      return 0
    end
    resId = dept.items[avatar_show.instid].res_id or 0
  else
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(avatar_show.instid)
    if itemInfo == nil then
      return 0
    end
    resId = itemInfo.resID
  end
  log(bWriteLog and "HallThemeUtils.GetThemeRelateItemId tag = " .. tag .. ",resId = " .. resId)
  return resId
end
function HallThemeUtils.IsWeaponWear(instId)
  log(bWriteLog and "HallThemeUtils IsWeaponWear " .. instId)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local avatar_show = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
  if avatar_show and tostring(avatar_show.instid) == tostring(instId) then
    return true
  end
  return false
end
function HallThemeUtils.IsWeaponWearBothSlots(instId)
  log(bWriteLog and "HallThemeUtils IsWeaponWearBothSlots " .. instId)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local avatar_show = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
  if avatar_show and tostring(avatar_show.instid) == tostring(instId) then
    log(bWriteLog and "HallThemeUtils IsWeaponWearBothSlots 1")
    return true
  end
  local avatar_show2 = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_second_weapon_skin)
  if avatar_show2 and tostring(avatar_show2.instid) == tostring(instId) then
    log(bWriteLog and "HallThemeUtils IsWeaponWearBothSlots 2")
    return true
  end
  return false
end
function HallThemeUtils.GetThemeInstId()
  return HallThemeUtils.homeThemeInstId
end
function HallThemeUtils.SetThemeInstId(insId)
  log(bWriteLog and string.format("HallThemeUtils.SetThemeInstId. insId=%s", tostring(insId)))
  HallThemeUtils.homeThemeInstId = insId
end
function HallThemeUtils.GetUsedItemCount(instId, tagId)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local info = fashionbag_data:GetAllKnapsackExtInfo()
  if info == nil then
    return 0
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(instId)
  if itemInfo == nil then
    return 0
  end
  if tagId == HallThemeUtils.knapsack_ext_background and itemInfo.resID == HallThemeUtils.GetDefaultThemeItemID() then
    return 0
  end
  if tagId == HallThemeUtils.knapsack_ext_vst_skin and HallThemeUtils.IsDefaultVehicle(itemInfo.resID) then
    return 0
  end
  local count = 0
  for k, v in pairs(info) do
    local avatar_show = GetAvatarShowInfo(k, tagId)
    if avatar_show and tostring(avatar_show.instid) == tostring(instId) then
      count = count + 1
    end
  end
  if count > itemInfo.count then
    count = itemInfo.count
  end
  return count
end
function HallThemeUtils.PutOnHallTheme(instId)
  log(bWriteLog and "HallThemeUtils.PutOnHallTheme instId = " .. instId)
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:wardrobe_puton_req(instId)
end
function HallThemeUtils.ProcPutOnHallTheme(putOnItem, putOffItem)
  if putOnItem == nil then
    return
  end
  HallThemeUtils.homeThemeItemId = putOnItem.res_id or 0
  HallThemeUtils.SetThemeInstId(putOnItem.instid or 0)
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:ShowTheme()
  HallThemeUtils.ShowThemeVehicle()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local itemInfo = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_background)
  if itemInfo then
    itemInfo.instid = putOnItem.instid
  end
end
function HallThemeUtils.GetWeaponInstId(bagIndex)
  local avatar_show = GetAvatarShowInfo(bagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
  if avatar_show then
    return avatar_show.instid
  end
  return 0
end
function HallThemeUtils.GetCurWeaponInstId()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  return HallThemeUtils.GetWeaponInstId(nUseWearBagIndex)
end
function HallThemeUtils.GetCarID()
  return HallThemeUtils.GetThemeVehicleItemId()
end
function HallThemeUtils.LogoutWeapon()
  log(bWriteLog and "HallThemeUtils w1=" .. HallThemeUtils.GetWeaponInstId(1) .. ",w2=" .. HallThemeUtils.GetWeaponInstId(2) .. ",w3=" .. HallThemeUtils.GetWeaponInstId(3))
end
function HallThemeUtils.ProcPutOnVehicle(putOnItem, bShowVehicle)
  if putOnItem == nil then
    return
  end
  DataMgr.vst_skin = putOnItem.instid or 0
  HallThemeUtils.UpdateThemeVehicleShow()
  if bShowVehicle then
    HallThemeUtils.ShowThemeVehicle()
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local itemInfo = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_vst_skin)
  if itemInfo then
    itemInfo.instid = putOnItem.instid
  end
end
function HallThemeUtils.ProcGunInstall(weapon_id, instanceID)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local itemInfo = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
  if itemInfo then
    itemInfo.instid = instanceID
  end
  HallThemeUtils.LogoutWeapon()
end
function HallThemeUtils.ProcGun2Install(weapon_id, instanceID)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local itemInfo = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_second_weapon_skin)
  if itemInfo then
    itemInfo.instid = instanceID
  end
end
function HallThemeUtils.ProcGunUnInstall(weapon_id)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local itemInfo = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
  if itemInfo then
    itemInfo.instid = 0
  end
  HallThemeUtils.LogoutWeapon()
end
function HallThemeUtils.ProcGun2UnInstall(weapon_id)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local itemInfo = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_second_weapon_skin)
  if itemInfo then
    itemInfo.instid = 0
  end
end
function HallThemeUtils.ProcGunWear(weapon_id, new_skin_id, extra_weapon_list)
  if new_skin_id == 0 then
    HallThemeUtils.ProcGunUnInstall(weapon_id)
  else
    HallThemeUtils.ProcGunInstall(weapon_id, new_skin_id)
  end
  if ArmorySystem.rsp_list and ArmorySystem.rsp_list.install_list and ArmorySystem.rsp_list.install_list[weapon_id] ~= nil then
    ArmorySystem.rsp_list.install_list[weapon_id].skin_id = new_skin_id
  end
  local wardrobeLogicGun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  wardrobeLogicGun:UpdateCurrentGunAvatar(weapon_id, new_skin_id)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if extra_weapon_list and next(extra_weapon_list) then
    for _, v in pairs(extra_weapon_list) do
      if not v.skin_id or v.skin_id == 0 then
        HallThemeUtils.ProcGun2UnInstall(weapon_id)
      else
        HallThemeUtils.ProcGun2Install(v.weapon_id, v.skin_id)
      end
      local success = wardrobeLogicGun:UpdateExtraGunAvatar(v.weapon_id, v.skin_id)
      if success == false then
        LobbyAvatarManager.UnEquipExtraWeapon(DataMgr.roleData.uid, nil)
        break
      end
    end
  else
    LobbyAvatarManager.UnEquipExtraWeapon(DataMgr.roleData.uid, nil)
  end
end
function HallThemeUtils.ProcSwitchUseWearBag(index)
  log(bWriteLog and "HallThemeUtils.ProcSwitchUseWearBag index = " .. index)
  HallThemeUtils.homeThemeItemId = HallThemeUtils.GetMyHallThemeItemId()
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:ShowTheme()
end
function HallThemeUtils.ProcSwitchSpaceUseWearBag(index)
  log(bWriteLog and "HallThemeUtils.ProcSwitchSpaceUseWearBag index = " .. index)
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:ShowTheme()
  HallThemeUtils.ShowThemeVehicle()
end
function HallThemeUtils.ProcRoleWearState(all_knapsack_ext_info)
  if all_knapsack_ext_info == nil then
    return
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:SetAllKnapsackExtInfo(all_knapsack_ext_info)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return
  end
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:ShowTheme()
  HallThemeUtils.ShowThemeVehicle()
end
function HallThemeUtils.GetThemeSkinIdByItemId(itemId)
  local cfg = CDataTable.GetTableData("HallThemeItem", itemId)
  if cfg then
    return tonumber(cfg.skinId)
  end
  return 0
end
function HallThemeUtils.GetTeamLeaderThemItemId()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.teamInfo or not TeamUpNewSystem.teamInfo.members then
    return 0
  end
  local leader = tonumber(TeamUpNewSystem.teamInfo.leader)
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if tonumber(k) == leader then
      return v.background or 0
    end
  end
  return 0
end
function HallThemeUtils.GetTeamMemberVehicle(uid)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.teamInfo then
    return 0, {}
  end
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if tonumber(k) == uid then
      return v.vst_info.skin_id or 0, v.vst_info.skin_style_list or {}
    end
  end
  return 0, {}
end
function HallThemeUtils.GetCurShowThemeItemId()
  local itemId = 0
  if HallThemeUtils.themeShowMode == 0 then
    itemId = HallThemeUtils.homeThemeItemId
  elseif HallThemeUtils.themeShowMode == 1 then
    if tonumber(HallThemeUtils.curShowAvatarData.uid) == tonumber(DataMgr.roleData.uid) then
      itemId = HallThemeUtils.GetSpaceThemeRelateItemId(HallThemeUtils.knapsack_ext_background)
    elseif HallThemeUtils.curShowAvatarData.pspace_wear_ext and HallThemeUtils.curShowAvatarData.pspace_wear_ext[101] then
      if HallThemeUtils.curShowAvatarData.bshow then
        itemId = HallThemeUtils.curShowAvatarData.pspace_wear_ext[101][1] or HallThemeUtils.GetDefaultThemeItemID()
      else
        itemId = HallThemeUtils.GetDefaultThemeItemID()
      end
    else
      itemId = HallThemeUtils.GetDefaultThemeItemID()
    end
  else
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.IsTeamLeader() then
      itemId = HallThemeUtils.homeThemeItemId
    else
      itemId = HallThemeUtils.GetTeamLeaderThemItemId()
      if not itemId or itemId == 0 then
        log(bWriteLog and "HallThemeUtils.GetCurShowThemeItemId GetTeamLeaderThemItemId = " .. tostring(itemId))
        itemId = HallThemeUtils.GetDefaultThemeItemID()
      end
    end
  end
  return itemId
end
function HallThemeUtils.GetSpaceThemeRelateItemId(tag)
  log(bWriteLog and "HallThemeUtils .pspace_rolewear_index" .. DataMgr.pspace_rolewear_index)
  local avatar_show = GetAvatarShowInfo(DataMgr.pspace_rolewear_index, tag)
  if avatar_show == nil or avatar_show.is_show == false then
    return 0
  end
  local resId = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(avatar_show.instid)
  if itemInfo == nil then
    return 0
  end
  resId = itemInfo.resID
  log(bWriteLog and "HallThemeUtils.GetSpaceThemeRelateItemId tag = " .. tag .. ",resId = " .. resId)
  return resId
end
local curShowWingmanID = 0
local _lobbyWingman
function HallThemeUtils.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "HallThemeUtils OnModePostSwitch" .. tostring(nextState))
  if nextState == GameStatus.Login or nextState == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    HallThemeUtils.DestroyHallThemeWingman()
    EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, HallThemeUtils.OnSwitchToPageStart)
    EventSystem:unregistEvent(EVENTTYPE_STORE, EVENTID_STORE_ON_CLOSE, HallThemeUtils.OnStoreCrateClose)
    EventSystem:unregistEvent(EVENTTYPE_LOBBY_THEME, EVENTID_LOBBY_THEME_CHANGE, HallThemeUtils.AdjustWingmanTransfrom)
  elseif nextState == GameStatus.Lobby then
    local wingmanItemID = HallThemeUtils.GetHallWingmanID()
    HallThemeUtils.CreateHallWingman(wingmanItemID)
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, HallThemeUtils.OnSwitchToPageStart)
    EventSystem:registEvent(EVENTTYPE_STORE, EVENTID_STORE_ON_CLOSE, HallThemeUtils.OnStoreCrateClose)
    EventSystem:registEvent(EVENTTYPE_LOBBY_THEME, EVENTID_LOBBY_THEME_CHANGE, HallThemeUtils.AdjustWingmanTransfrom)
  end
end
function HallThemeUtils.CanShowWingmanTeamVideo(itemID)
  if itemID == nil or itemID == 0 then
    return false
  end
  local itemData = CDataTable.GetTableData("Item", itemID)
  if not itemData then
    return false
  end
  if itemData.ItemQuality < 6 then
    return false
  end
  return true
end
function HallThemeUtils.CanShowHallWingman(itemID)
  log(bWriteLog and "[lizzhi]  HallThemeUtils.CanShowHallWingman itemID = " .. tostring(itemID))
  if itemID == nil or itemID == 0 then
    return false
  end
  if itemID == DataMgr.defaultWingmanSkinResID then
    return false
  end
  return true
end
function HallThemeUtils.CreateHallWingman(itemID)
  do return end
  if HallThemeUtils.CanShowHallWingman(itemID) == false then
    log(bWriteLog and "[HallWingman]  HallThemeUtils.CreateHallWingman. Can not show HallWingman, itemID = " .. tostring(itemID))
    return
  end
  if curShowWingmanID ~= 0 and curShowWingmanID == itemID then
    log(bWriteLog and "[HallWingman] HallThemeUtils.CreateHallWingman. Create same HallWingman, itemID = " .. tostring(itemID))
    return
  end
  log_shipping_client("[HallWingman] CreateHallWingman:" .. tostring(itemID))
  curShowWingmanID = itemID
  if slua.isValid(_lobbyWingman) then
  else
    local world = slua_GameFrontendHUD:GetWorld()
    if not slua.isValid(world) then
      return
    end
    local ModelFactory = require("client.slua.logic.show_actor.common.ModelFactory")
    _lobbyWingman = ModelFactory.CreateShowActor()
  end
  local themeItemId = HallThemeUtils.GetCurShowThemeItemId()
  local themeData = CDataTable.GetTableData("HallThemeItem", themeItemId)
  if not themeData then
    themeItemId = HallThemeUtils.GetDefaultThemeItemID()
  end
  local param = HallThemeUtils.GetVehicleCreateParam(themeItemId, itemID)
  if param == nil then
    HallThemeUtils.DestroyHallThemeWingman()
    return
  end
  _lobbyWingman:K2_SetActorLocation(param[1], false, nil, false)
  _lobbyWingman:K2_SetActorRotation(FRotator(param[2].Y, param[2].Z, param[2].X), false)
  _lobbyWingman:SetActorScale3D(param[3])
  local ExtraTable = {is_hall_vehicle = true}
  if itemID == 181101030 then
    ExtraTable = ExtraTable or {}
    ExtraTable.ActorScale = FVector(0.3, 0.3, 0.3)
  end
  _lobbyWingman:ShowModelByResID(itemID, ExtraTable)
end
function HallThemeUtils.AdjustWingmanTransfrom()
  if curShowWingmanID == 0 or not slua.isValid(_lobbyWingman) then
    return
  end
  local themeItemId = HallThemeUtils.GetCurShowThemeItemId()
  local themeData = CDataTable.GetTableData("HallThemeItem", themeItemId)
  if not themeData then
    themeItemId = HallThemeUtils.GetDefaultThemeItemID()
  end
  local param = HallThemeUtils.GetVehicleCreateParam(themeItemId, curShowWingmanID)
  if param == nil then
    HallThemeUtils.DestroyHallThemeWingman()
    return
  end
  _lobbyWingman:K2_SetActorLocation(param[1], false, nil, false)
  _lobbyWingman:K2_SetActorRotation(FRotator(param[2].Y, param[2].Z, param[2].X), false)
  _lobbyWingman:SetActorScale3D(param[3])
end
function HallThemeUtils.RefreshTeamWingman(teaminfo, isMemberQuit)
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if HallThemeUtils.IsThemePreviewStatus() then
    log(bWriteLog and "HallThemeUtils.RefreshTeamWingman previewStatus")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return
  end
  if isMemberQuit == true then
    log(bWriteLog and "[tinghaohu]HallThemeUtils.RefreshTeamWingman. somebody quit team, do not refresh team wingman.")
    return
  end
  if teaminfo == nil then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    teaminfo = TeamUpNewSystem.teamInfo
    if teaminfo == nil then
      return
    end
  end
  local TableUtil = require("common.table_util")
  if teaminfo.members == nil or TableUtil.CountTable(teaminfo.members) <= 1 then
    return
  end
  log_tree("[tinghaohu]HallThemeUtils.RefreshTeamWingman Tree, ", teaminfo.members)
  local FashionBag = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local fashionBagWingman = WardrobeDataManager:GetHallDepotItemDataByInsID(FashionBag:GetWingmanSkin())
  local topRPMemberInfo = {
    UID = DataMgr.roleData.uid,
    WingmanID = fashionBagWingman and fashionBagWingman.resID or DataMgr.defaultWingmanSkinResID,
    RPScore = DataMgr.roleData.upass and DataMgr.roleData.upass.acc_score or 0
  }
  local tempRPScore = topRPMemberInfo.RPScore or 0
  local tempWingmanID = topRPMemberInfo.WingmanID or 0
  for uid, memberInfo in pairs(teaminfo.members) do
    if tostring(uid) ~= DataMgr.roleData.uid and memberInfo.upass and memberInfo.upass.acc_score ~= nil and (tempRPScore <= memberInfo.upass.acc_score or not HallThemeUtils.CanShowHallWingman(tempWingmanID)) and memberInfo.skin_info ~= nil and HallThemeUtils.CanShowHallWingman(memberInfo.skin_info.wingman_skin) then
      topRPMemberInfo.UID = tostring(uid)
      topRPMemberInfo.WingmanID = memberInfo.skin_info.wingman_skin
      topRPMemberInfo.RPScore = memberInfo.upass.acc_score
      tempRPScore = memberInfo.upass.acc_score
      tempWingmanID = memberInfo.skin_info.wingman_skin
    end
  end
  log_tree(bWriteLog and "[tinghaohu]HallThemeUtils.RefreshTeamWingman. post top RPMemberInfo = ", topRPMemberInfo)
  HallThemeUtils.PlayHallWingmanAnim(topRPMemberInfo.WingmanID)
end
function HallThemeUtils.OnSwitchToPageStart(_, __, toPage)
  log(bWriteLog and "[tinghaohu]HallThemeUtils.OnSwitchToPageStart. toPage" .. tostring(toPage))
  if toPage == ENUM_LobbyPageType.Mid then
    HallThemeUtils.ReplayHallWingmanAnim()
  end
end
function HallThemeUtils.OnStoreCrateClose(_, __)
  log(bWriteLog and "[tinghaohu]HallThemeUtils.OnStoreCrateClose.")
  HallThemeUtils.ReplayHallWingmanAnim()
end
function HallThemeUtils.ReplayHallWingmanAnim()
  if HallThemeUtils.bIsWingManShowPermanently then
    log(bWriteLog and "[lizzhi]HallThemeUtils.OnStoreCrateClose bIsWingManShowPermanently true")
    return
  end
  local FashionBag = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local wingmanData = WardrobeDataManager:GetHallDepotItemDataByInsID(FashionBag:GetWingmanSkin())
  if not wingmanData then
    log(bWriteLog and "HallThemeUtils.ReplayHallWingmanAnim not wingmanData")
    return
  end
  if slua.isValid(_lobbyWingman) and slua.isValid(_lobbyWingman:GetWingmanActor()) and slua.isValid(_lobbyWingman:GetWingmanActor().Mesh) then
    local animInstance = _lobbyWingman:GetWingmanActor().Mesh:GetAnimInstance()
    if slua.isValid(animInstance) and not animInstance:IsAnyMontagePlaying() then
      HallThemeUtils.PlayHallWingmanAnim(wingmanData.resID)
    else
      log(bWriteLog and "HallThemeUtils.ReplayHallWingmanAnim animInsvalid" .. tostring(slua.isValid(animInstance)) .. "IsPlaying" .. tostring(animInstance:IsAnyMontagePlaying()))
    end
  end
end
function HallThemeUtils.PlayHallWingmanAnim(skinID)
  if HallThemeUtils.bIsWingManShowPermanently then
    log(bWriteLog and "[lizzhi]HallThemeUtils.OnStoreCrateClose PlayHallWingmanAnim true")
    return
  end
  log(bWriteLog and "HallThemeUtils.PlayHallWingmanAnim")
  HallThemeUtils.DestroyHallThemeWingman()
  HallThemeUtils.CreateHallWingman(skinID)
end
function HallThemeUtils.DestroyHallThemeWingman()
  print(bWriteLog and "[HallWingman] HallThemeUtils DestroyHallThemeWingman ")
  curShowWingmanID = 0
  if slua.isValid(_lobbyWingman) then
    _lobbyWingman:Destroy()
  end
  _lobbyWingman = nil
end
function HallThemeUtils.HideHallThemeWingman()
  print(bWriteLog and "[HallWingman] HallThemeUtils HideHallThemeWingman ")
  if slua.isValid(_lobbyWingman) and slua.isValid(_lobbyWingman:GetWingmanActor()) then
    _lobbyWingman:GetWingmanActor():SetActorHiddenInGame(true)
  end
end
function HallThemeUtils.ProcPutOnWingman(resId)
  log(bWriteLog and "[lizzhi]HallThemeUtils.ProcPutOnWingman.")
  HallThemeUtils.ReCreateHallWingman(resId)
end
function HallThemeUtils.ReCreateHallWingman(resId)
  log(bWriteLog and "[lizzhi]HallThemeUtils.ReCreateHallWingman.")
  if not HallThemeUtils.bIsWingManShowPermanently then
    log(bWriteLog and "[lizzhi]HallThemeUtils.ReCreateHallWingman. bIsWingManShowPermanently is false")
    return
  end
  if not resId then
    log(bWriteLog and "[lizzhi]HallThemeUtils.ReCreateHallWingman no resId")
    return
  end
  log(bWriteLog and "[lizzhi]HallThemeUtils.ReCreateHallWingman resID:" .. tostring(resId))
  HallThemeUtils.DestroyHallThemeWingman()
  HallThemeUtils.CreateHallWingman(resId)
end
function HallThemeUtils.ShowThemeVehicle(uid)
  local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
  ThemeVehicleManager:ShowThemeVehicle()
end
function HallThemeUtils.set_knapsack_pos_show_req(bShow)
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_set_knapsack_pos_show_req(HallThemeUtils.knapsack_ext_vst_skin, bShow)
end
function HallThemeUtils.set_knapsack_show_rsp(res, bShow)
  log(bWriteLog and "HallThemeUtils.set_knapsack_show_rsp res = " .. res)
  if res ~= 0 then
    return
  end
  HallThemeUtils.themeVehicleShow = bShow
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  logic_display_setting.GetData().OpenVehicle = bShow
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local info = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_vst_skin)
  if info then
    info.is_show = bShow
  end
  log(bWriteLog and "HallThemeUtils bShow = " .. tostring(bShow))
  HallThemeUtils.ShowThemeVehicle()
end
function HallThemeUtils.GetCheckBoxShowInHallSts()
  return HallThemeUtils.themeVehicleShow
end
function HallThemeUtils.SwitchShowMode(showMode, roleData, themeTips)
  log(bWriteLog and "HallThemeUtils.SwitchShowMode = " .. showMode)
  HallThemeUtils.curShowAvatarData = roleData
  HallThemeUtils.themeShowMode = showMode
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:ShowTheme(themeTips)
  HallThemeUtils.ShowThemeVehicle()
end
function HallThemeUtils.ProcEnterRoleSpace(roleData)
  HallThemeUtils.SwitchShowMode(1, roleData)
end
function HallThemeUtils.ProcLeaveRoleSpace()
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  if logic_team_up.GetTeamNum() > 1 then
    HallThemeUtils.SwitchShowMode(2)
  else
    HallThemeUtils.SwitchShowMode(0)
  end
end
function HallThemeUtils.ProcEnterTeam()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return
  end
  if HallThemeUtils.themeShowMode == 1 then
  else
    HallThemeUtils.SwitchShowMode(2, nil, true)
  end
end
function HallThemeUtils.ProcLeaveTeam()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return
  end
  if HallThemeUtils.themeShowMode == 1 then
  else
    HallThemeUtils.SwitchShowMode(0)
  end
end
function HallThemeUtils.ProcTeamUpdateWear(op_uid)
  log(bWriteLog and "HallThemeUtils.ProcTeamUpdateWear op_uid= " .. op_uid)
  if tonumber(op_uid) == tonumber(DataMgr.roleData.uid) then
    return
  end
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:ShowTheme()
  HallThemeUtils.ShowThemeVehicle()
end
function HallThemeUtils.proc_skin_list_chg(type_name, param_key, param_val, bagIndex, extra_weapon_list)
  log(bWriteLog and "HallThemeUtils.proc_skin_list_chg type_name=" .. type_name .. ",param_key=" .. param_key .. ",param_val=" .. param_val .. ",bagIndex=" .. bagIndex)
  if type_name == "weapon_skin" then
    local info = GetAvatarShowInfo(bagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
    if info == nil then
      info = {
        is_show = true,
        instid = 0,
        relat_param = 0
      }
      local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
      local bag = fashionbag_data:GetKnapsackExtInfoByIndex(bagIndex)
      if not bag then
        bag = {}
        fashionbag_data:SetKnapsackExtInfoByIndex(bagIndex, bag)
      end
      if not bag.avatar_show then
        bag.avatar_show = {}
      end
      bag.avatar_show[HallThemeUtils.knapsack_ext_weapon_skin] = info
    end
    info.relat_param = param_key
    info.instid = param_val
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local wardrobeLogicGun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(param_val)
    local itemID = 0
    if itemInfo and itemInfo.resID then
      itemID = itemInfo.resID
    end
    DataMgr.InitWeaponData(tonumber(param_key), itemID, param_val)
    if itemInfo == nil then
      if param_key == 0 then
        local gunID = wardrobeLogicGun:GetGunID()
        if ArmorySystem.rsp_list and ArmorySystem.rsp_list.install_list and ArmorySystem.rsp_list.install_list[gunID] ~= nil then
          ArmorySystem.rsp_list.install_list[gunID].skin_id = 0
        end
        wardrobeLogicGun:UpdateCurrentGunAvatar(gunID, param_val)
        wardrobeLogicGun:SetGunID(0)
        wardrobeLogicGun:PutOffGunAvatar()
      else
        wardrobeLogicGun:SetGunID(param_key)
        if ArmorySystem.rsp_list and ArmorySystem.rsp_list.install_list and ArmorySystem.rsp_list.install_list[param_key] ~= nil then
          ArmorySystem.rsp_list.install_list[param_key].skin_id = 0
        end
        wardrobeLogicGun:UpdateCurrentGunAvatar(param_key, param_val)
      end
    else
      wardrobeLogicGun:SetGunID(param_key)
      if ArmorySystem.rsp_list and ArmorySystem.rsp_list.install_list and ArmorySystem.rsp_list.install_list[param_key] ~= nil then
        ArmorySystem.rsp_list.install_list[param_key].skin_id = param_val
      end
      wardrobeLogicGun:UpdateCurrentGunAvatar(param_key, param_val)
    end
    HallThemeUtils.LogoutWeapon()
    if coroutine.isyieldable() then
      coroutine.yield(0)
    end
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    DataMgr.InitExtraWeaponList(extra_weapon_list)
    if extra_weapon_list and next(extra_weapon_list) then
      for k, v in pairs(extra_weapon_list) do
        local success = wardrobeLogicGun:UpdateExtraGunAvatar(v.weapon_id, v.skin_id)
        if success == false then
          LobbyAvatarManager.UnEquipExtraWeapon(DataMgr.roleData.uid, nil)
          break
        end
      end
    else
      LobbyAvatarManager.UnEquipExtraWeapon(DataMgr.roleData.uid, nil)
    end
  elseif type_name == "vst_skin" then
  end
end
function HallThemeUtils.IsDefaultVehicle(itemId)
  if HallThemeUtils.default_vehicle_map[itemId] then
    return true
  else
    return false
  end
end
function HallThemeUtils.GetVehicleCreateParam(themeId, vehicleId)
  local cfgItem = CDataTable.GetTableData("Item", vehicleId)
  if cfgItem == nil then
    return nil
  end
  log(bWriteLog and "HallThemeUtils GetVehicleCreateParam themeId" .. tostring(themeId))
  local cfgTheme = CDataTable.GetTableData("HallThemeItem", themeId)
  if cfgTheme == nil then
    return nil
  end
  local pos = ""
  local rotation = ""
  local scale = ""
  if cfgItem.ItemSubType == 901 then
    pos = cfgTheme.wheel2Position
    rotation = cfgTheme.wheel2Rotation
    scale = cfgTheme.wheel2Scale
  elseif cfgItem.ItemSubType == 902 then
    pos = cfgTheme.wheel3Position
    rotation = cfgTheme.wheel3Rotation
    scale = cfgTheme.wheel3Scale
  elseif cfgItem.ItemSubType == 911 then
    pos = cfgTheme.boatPosition
    rotation = cfgTheme.boatRotation
    scale = cfgTheme.boatScale
  elseif cfgItem.ItemSubType == 912 then
    pos = cfgTheme.motoBoatPosition
    rotation = cfgTheme.motoBoatRotation
    scale = cfgTheme.motoBoatScale
  elseif cfgItem.ItemSubType == 916 then
    pos = cfgTheme.footPosition
    rotation = cfgTheme.footRotation
    scale = cfgTheme.footScale
  elseif cfgItem.ItemSubType == 918 then
    pos = cfgTheme.snowMotoPosition
    rotation = cfgTheme.snowMotoRotation
    scale = cfgTheme.snowMotoScale
  elseif cfgItem.ItemSubType == 1101 then
    pos = cfgTheme.WingmanPosition
    rotation = cfgTheme.WingmanRotation
    scale = cfgTheme.WingmanScale
  elseif cfgItem.ItemSubType == 963 then
    pos = cfgTheme.TankPosition
    rotation = cfgTheme.TankRotation
    scale = cfgTheme.TankScale
  elseif cfgItem.ItemSubType == 967 then
    pos = cfgTheme.ByciclePosition
    rotation = cfgTheme.BycicleRotation
    scale = cfgTheme.BycicleScale
  elseif cfgItem.ItemSubType == ENUM_ITEM_SUBTYPE.Fighter then
    pos = cfgTheme.FighterPosition
    rotation = cfgTheme.FighterRotation
    scale = cfgTheme.FighterScale
  elseif cfgItem.ItemSubType == ENUM_ITEM_SUBTYPE.Horse then
    pos = cfgTheme.HorsePosition
    rotation = cfgTheme.HorseRotation
    scale = cfgTheme.HorseScale
  elseif cfgItem.ItemSubType == ENUM_ITEM_SUBTYPE.AmphibiousBoat then
    pos = cfgTheme.AmphibiousBoatPosition
    rotation = cfgTheme.AmphibiousBoatRotation
    scale = cfgTheme.AmphibiousBoatScale
  elseif cfgItem.ItemSubType == ENUM_ITEM_SUBTYPE.ElectricBus then
    pos = cfgTheme.ElectricBusPosition
    rotation = cfgTheme.ElectricBusRotation
    scale = cfgTheme.ElectricBusScale
  elseif cfgItem.ItemSubType == ENUM_ITEM_SUBTYPE.BrownSedan then
    pos = cfgTheme.BrownSedanPosition
    rotation = cfgTheme.BrownSedanRotation
    scale = cfgTheme.BrownSedanScale
  end
  log(bWriteLog and "HallThemeUtils GetVehicleCreateParam cfg pos " .. tostring(pos))
  log(bWriteLog and "HallThemeUtils GetVehicleCreateParam cfg rotation " .. tostring(rotation))
  log(bWriteLog and "HallThemeUtils GetVehicleCreateParam cfg scale " .. tostring(scale))
  if pos == "" then
    pos = cfgTheme.vehiclePosition
  end
  if rotation == "" then
    rotation = cfgTheme.vehicleRotation
  end
  if scale == "" then
    scale = cfgTheme.vehicleScale
  end
  log(bWriteLog and "HallThemeUtils GetVehicleCreateParam pos " .. tostring(pos))
  log(bWriteLog and "HallThemeUtils GetVehicleCreateParam rotation " .. tostring(rotation))
  log(bWriteLog and "HallThemeUtils GetVehicleCreateParam scale " .. tostring(scale))
  pos = LobbySceneManager.ParseVec3(pos)
  rotation = LobbySceneManager.ParseVec3(rotation)
  scale = LobbySceneManager.ParseVec3(scale)
  local params = {}
  local PosVec = FVector(pos.x_f, pos.y_f, pos.z_f)
  if cfgItem.ItemSubType == 967 then
    PosVec.Z = PosVec.Z + 3
  end
  table.insert(params, PosVec)
  table.insert(params, FVector(rotation.x_f, rotation.y_f, rotation.z_f))
  table.insert(params, FVector(scale.x_f, scale.y_f, scale.z_f))
  return params
end
function HallThemeUtils.ProcSetSkinInfo(skin_info)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local useIndex = fashionbag_data:GetFashionBagUseIndex()
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(useIndex)
  if bagInfo == nil then
    return
  end
  if skin_info == nil then
    return
  end
  HallThemeUtils.PutOffBag(useIndex)
  if skin_info.helmet_level then
    if bagInfo.helmet_skin_list and HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
      bagInfo.head_show = bagInfo.helmet_skin_list[skin_info.helmet_level]
    end
    bagInfo.helmet_level = skin_info.helmet_level
  end
  if skin_info.bag_level then
    bagInfo.bag_level = skin_info.bag_level
  end
  HallThemeUtils.PutOnBag(useIndex)
end
function HallThemeUtils.ChangeBag(index, isPutOn)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(index)
  if bagInfo ~= nil then
    local myUid = DataMgr.roleData.uid
    local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    if bagInfo.head_show ~= 0 then
      local helmet_skin = bagInfo.helmet_skin
      if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) ~= nil then
        helmet_skin = bagInfo.helmet_skin_list[bagInfo.helmet_level]
      end
      local originalResId = wardrobeLogic:GetItemResId(helmet_skin)
      if bagInfo.head_show == helmet_skin then
        local resID = DataMgr.GetEquipmentItemIDByResID(bagInfo.helmet_level, originalResId)
        local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
        TeamAvatarManager.ChangeAvatarEquipment(myUid, AvatarData.CreateAvatarCustom(resID), isPutOn)
      end
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local depotItem = wardrobe_data:GetHallDepotItemDataByInsID(helmet_skin)
      local item = {
        use_flag = isPutOn and 1 or 0,
        isnew = 0,
        count = depotItem and depotItem.count or 1,
        instid = helmet_skin,
        res_id = originalResId
      }
      EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, isPutOn and item or nil, not isPutOn and item or nil)
    end
    local bag_skin = bagInfo.bag_skin
    if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.BAG) ~= nil then
      bag_skin = bagInfo.bag_skin_list[bagInfo.bag_level]
    end
    if bag_skin ~= 0 then
      local originalResId = wardrobeLogic:GetItemResId(bag_skin)
      local resID = DataMgr.GetEquipmentItemIDByResID(bagInfo.bag_level, originalResId)
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      TeamAvatarManager.ChangeAvatarEquipment(myUid, AvatarData.CreateAvatarCustom(resID), isPutOn)
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local depotItem = wardrobe_data:GetHallDepotItemDataByInsID(bag_skin)
      local item = {
        use_flag = isPutOn and 1 or 0,
        isnew = 0,
        count = depotItem and depotItem.count or 1,
        instid = bag_skin,
        res_id = originalResId
      }
      EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, isPutOn and item or nil, not isPutOn and item or nil)
    end
  end
end
function HallThemeUtils.PutOffBag(oldIndex)
  log(bWriteLog and "[edward][hall_theme_utils] HallThemeUtils.PutOffBag")
  HallThemeUtils.ChangeBag(oldIndex, false)
end
function HallThemeUtils.PutOnBag(newIndex)
  log(bWriteLog and "[edward][hall_theme_utils] HallThemeUtils.PutOnBag")
  HallThemeUtils.ChangeBag(newIndex, true)
end
function HallThemeUtils.ProcPutDownHelmet(item)
  if item == nil then
    return
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(nUseWearBagIndex)
  if bagInfo == nil then
    return
  end
  local myUid = DataMgr.roleData.uid
  local resID = DataMgr.GetEquipmentItemIDByResID(bagInfo.helmet_level, item.res_id)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.ChangeAvatarEquipment(myUid, AvatarData.CreateAvatarCustom(resID), false)
  bagInfo.head_show = 0
  bagInfo.helmet_skin = 0
  if not bagInfo.helmet_skin_list then
    bagInfo.helmet_skin_list = {}
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:SetHeadShow(bagInfo.head_show)
  fashionbag_data:SetHelmetSkin(bagInfo.helmet_skin)
  if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
    bagInfo.helmet_skin_list[bagInfo.helmet_level] = 0
    fashionbag_data:SetHelmetSkinByLevel(0, bagInfo.helmet_level)
  elseif HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) == HallThemeUtils.CONST_RELATION_OP_TYPE.BIND then
    for i = 1, 3 do
      bagInfo.helmet_skin_list[i] = 0
      fashionbag_data:SetHelmetSkinByLevel(0, i)
    end
  end
  DataMgr.equipmentSkinInsIDTable[ENUM_ITEM_SUBTYPE.Helmet_NoLevel] = bagInfo.helmet_skin or 0
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
end
function HallThemeUtils.ProcPutDownHat()
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  if not logic_display_setting.IsOpenHelmet() then
    return
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local insID = fashionbag_data:GetHelmetSkin()
  if insID ~= 0 then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local data = wardrobe_data:GetHallDepotItemDataByInsID(insID)
    if data ~= nil then
      HallThemeUtils.ProcPutOnHelmet({
        res_id = data.resID,
        instid = insID
      })
      local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
      WardRobeHandler.send_depot_set_head_show_req(insID)
    end
  end
end
function HallThemeUtils.ProcPutDownBagSkin(item)
  if item == nil then
    return
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(nUseWearBagIndex)
  if bagInfo == nil then
    return
  end
  local myUid = DataMgr.roleData.uid
  local resID = DataMgr.GetEquipmentItemIDByResID(bagInfo.bag_level, item.res_id)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.ChangeAvatarEquipment(myUid, AvatarData.CreateAvatarCustom(resID), false)
  bagInfo.bag_skin = 0
  if not bagInfo.bag_skin_list then
    bagInfo.bag_skin_list = {}
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:SetBagSkin(bagInfo.bag_skin)
  if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.BAG) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
    bagInfo.bag_skin_list[bagInfo.bag_level] = 0
    fashionbag_data:SetBagSkinByLevel(0, bagInfo.bag_level)
  elseif HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.BAG) == HallThemeUtils.CONST_RELATION_OP_TYPE.BIND then
    for i = 1, 3 do
      bagInfo.bag_skin_list[i] = 0
      fashionbag_data:SetBagSkinByLevel(0, i)
    end
  end
  DataMgr.equipmentSkinInsIDTable[ENUM_ITEM_SUBTYPE.Backpack] = bagInfo.bag_skin ~= 0 and bagInfo.bag_skin or 0
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
end
function HallThemeUtils.ProcPutOnHelmet(item, olditem)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(nUseWearBagIndex)
  if bagInfo == nil then
    return
  end
  bagInfo.helmet_skin = item.instid
  bagInfo.head_show = item.instid
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:SetHeadShow(bagInfo.head_show)
  fashionbag_data:SetHelmetSkin(bagInfo.helmet_skin)
  if not bagInfo.helmet_skin_list then
    bagInfo.helmet_skin_list = {}
  end
  if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
    bagInfo.helmet_skin_list[bagInfo.helmet_level] = bagInfo.helmet_skin
    fashionbag_data:SetHelmetSkinByLevel(bagInfo.helmet_skin, bagInfo.helmet_level)
  elseif HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) == HallThemeUtils.CONST_RELATION_OP_TYPE.BIND then
    for i = 1, 3 do
      bagInfo.helmet_skin_list[i] = bagInfo.helmet_skin
      fashionbag_data:SetHelmetSkinByLevel(bagInfo.helmet_skin, i)
    end
  end
  DataMgr.equipmentSkinInsIDTable[ENUM_ITEM_SUBTYPE.Helmet_NoLevel] = bagInfo.helmet_skin ~= 0 and bagInfo.helmet_skin or 0
  local myUid = DataMgr.roleData.uid
  local resID = DataMgr.GetEquipmentItemIDByResID(bagInfo.helmet_level, item.res_id)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.ChangeAvatarEquipment(myUid, AvatarData.CreateAvatarCustom(resID), true)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, item, olditem)
end
function HallThemeUtils.ProcPutOnHat(item)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(nUseWearBagIndex)
  if bagInfo == nil then
    return
  end
  bagInfo.head_show = item.instid
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:SetHeadShow(bagInfo.head_show)
end
function HallThemeUtils.ProcPutOnBagSkin(item, olditem)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(nUseWearBagIndex)
  if bagInfo == nil then
    return
  end
  bagInfo.bag_skin = item.instid
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:SetBagSkin(bagInfo.bag_skin)
  if not bagInfo.bag_skin_list then
    bagInfo.bag_skin_list = {}
  end
  if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.BAG) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
    bagInfo.bag_skin_list[bagInfo.bag_level] = bagInfo.bag_skin
    fashionbag_data:SetBagSkinByLevel(bagInfo.bag_skin, bagInfo.bag_level)
  elseif HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.BAG) == HallThemeUtils.CONST_RELATION_OP_TYPE.BIND then
    for i = 1, 3 do
      bagInfo.bag_skin_list[i] = bagInfo.bag_skin
      fashionbag_data:SetBagSkinByLevel(bagInfo.bag_skin, i)
    end
  end
  DataMgr.equipmentSkinInsIDTable[ENUM_ITEM_SUBTYPE.Backpack] = bagInfo.bag_skin ~= 0 and bagInfo.bag_skin or 0
  local myUid = DataMgr.roleData.uid
  local resID = DataMgr.GetEquipmentItemIDByResID(bagInfo.bag_level, item.res_id)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.ChangeAvatarEquipment(myUid, AvatarData.CreateAvatarCustom(resID), true)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, item, olditem)
end
function HallThemeUtils.GetDefaultLobbySkin()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return 10052
  end
  return 10006
end
function HallThemeUtils.GetDefaultThemeItemID()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return 202408052
  end
  return 202408001
end
function HallThemeUtils.IsThemePreviewStatus()
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  return LobbyThemeManager:IsPreviewTheme()
end
function HallThemeUtils.GetBindRelation(type)
  if not type then
    log_error("HallThemeUtils.GetBindRelation not type")
    return nil
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInFashionBagEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if not bInFashionBagEditMode then
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    return fashionbag_data:GetDepotBindRelation(type)
  else
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    return FashionBagEditUtils:GetDepotBindRelation(type)
  end
end
return HallThemeUtils