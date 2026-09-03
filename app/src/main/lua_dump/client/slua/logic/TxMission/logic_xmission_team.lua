local LogicTxMissionTeam = {
  teamInfo = {},
  avatarInfo = {},
  wait_members = {}
}
local C_SlotEnumMap
local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
local _GetSlotEnumMap = function()
  if not C_SlotEnumMap then
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    if not LobbyAvatarManager or not LobbyAvatarManager.Enum_WeaponAttachSlotID then
      return nil
    end
    local slotIDEnum = LobbyAvatarManager.Enum_WeaponAttachSlotID
    C_SlotEnumMap = {
      [xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_1] = slotIDEnum.MAIN_WEAPON1,
      [xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_2] = slotIDEnum.MAIN_WEAPON2,
      [xMission_macro.Enum_Slot.EnumSlot_Knife] = slotIDEnum.MELEE,
      [xMission_macro.Enum_Slot.EnumSlot_Pistol] = slotIDEnum.PISTOL
    }
  end
  return C_SlotEnumMap
end
local _GetSkinItemID = function(skinID, itemID)
  if 0 < skinID then
    local BackpackLevelMap = CDataTable.GetTableData("BackpackLevelMap", itemID)
    if BackpackLevelMap then
      local skinItemID = DataMgr.GetEquipmentItemIDByResID(BackpackLevelMap.Level, skinID)
      if 0 < skinItemID then
        return skinItemID
      end
    end
  end
  return itemID
end
local _GetWeaponOriginID = function(itemID)
  if itemID and 0 < itemID then
    local XMWeaponIDMap = CDataTable.GetTableData("XMWeaponIDMap", itemID)
    if XMWeaponIDMap then
      return XMWeaponIDMap.WeaponID
    end
  end
  return 0
end
function LogicTxMissionTeam.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Login or nextState == GameStatus.Fighting then
    if not GameStatus.IsInMainCity() then
      LogicTxMissionTeam.ClearData()
      local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
      XMissionAvatarMgr.DestroyAllAvatar()
      EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_GET_PLAYER_SCHEME_DATA, LogicTxMissionTeam.OnChangeDiyWeaponScheme)
    end
  else
    EventSystem:registEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_GET_PLAYER_SCHEME_DATA, LogicTxMissionTeam.OnChangeDiyWeaponScheme)
  end
end
function LogicTxMissionTeam.ClearData()
  LogicTxMissionTeam.teamInfo = {}
  LogicTxMissionTeam.avatarInfo = {}
end
function LogicTxMissionTeam.ClearDataRemainSelf()
  local uid = tostring(DataMgr.roleData.uid)
  for k, v in pairs(LogicTxMissionTeam.teamInfo) do
    if k ~= uid then
      LogicTxMissionTeam.teamInfo[k] = nil
    end
  end
  for k, v in pairs(LogicTxMissionTeam.avatarInfo) do
    if k ~= uid then
      LogicTxMissionTeam.avatarInfo[k] = nil
    end
  end
end
function LogicTxMissionTeam.OnTeamInfoChangeNotify(teamid, operate_type, param, param1, param2)
  log(bWriteLog and "[edward][logic_xmission_team] LogicTxMissionTeam.OnTeamInfoChangeNotify, teamid = " .. tostring(teamid) .. ", operate_type = " .. tostring(operate_type) .. ", param = " .. tostring(param) .. ", param1 = " .. tostring(param1) .. ", param2 = " .. tostring(param2))
  if operate_type == 110 then
    LogicTxMissionTeam.ChangeAvatarNotify(param)
  elseif operate_type == 111 then
    LogicTxMissionTeam.ChangeWorthNotify(param)
  elseif operate_type == 112 then
    LogicTxMissionTeam.ChangePrestigeLevelNotify(param)
  elseif operate_type == 113 then
    LogicTxMissionTeam.TeamMemberEnterNotify(param)
  elseif operate_type == 114 then
    LogicTxMissionTeam.TeamMemberQuitNotify(param)
  elseif operate_type == 115 then
    LogicTxMissionTeam.TeamMemberMatchParamsNotify(param)
  elseif operate_type == 116 then
    LogicTxMissionTeam.ChangeBeginnerGuideNotify(param)
  end
end
function LogicTxMissionTeam.TeamMemberMatchParamsNotify(param)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if param and param.metro_team_flag then
    TeamUpNewSystem.teamInfo.metro_team_flag = true
    if param.switch_mode then
      if param.match_params then
        TeamUpNewSystem.teamInfo.metro_match_params = param.match_params
        if param.match_params.mode_group and param.match_params.mode_group > 0 then
          local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
          local bChange = LogicTxMissionMatch.SetSelModel(param.match_params)
          if not param.not_notify and not bChange then
            param.not_notify = true
          end
          EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_SELECT_MAP_NOTIFY, param.not_notify)
        end
      end
    else
      local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
      if MatchModeMgrSystem.IsSocialIslandMode(true) then
        TeamUpNewSystem.team_quit_request(TeamUpNewSystem.teamInfo.id)
        return
      end
      local from = "team"
      if LogicTxMissionTeam.changeTeamTypeFromScroll then
        from = "scroll"
        LogicTxMissionTeam.changeTeamTypeFromScroll = nil
      end
      LogicTxMissionMain.SendEnterXMissionReq(from)
    end
  else
    TeamUpNewSystem.teamInfo.metro_team_flag = false
    LogicTxMissionMain.SendExitXMissionReq()
  end
end
function LogicTxMissionTeam.TeamMemberEnterNotify(param)
  local uid = tostring(param.uid)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if tonumber(uid) == TeamUpNewSystem.GetSelfUID() then
    return
  end
  LogicTxMissionTeam.SetTeamInfo(uid, param.metro_info or param.metro_team_info, param.metro_scence_status)
  local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
  if not memberInfo then
    log_error("[edward][logic_xmission_team] LogicTxMissionTeam.TeamMemberEnterNotify, team info have not member : " .. uid)
    return
  end
  if not LogicTxMissionTeam.avatarInfo[uid] then
    LogicTxMissionTeam.CreateAvatarInfo(uid, memberInfo)
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_MEMBER_ENTER, uid)
end
function LogicTxMissionTeam.GetAvatarInfo()
  return LogicTxMissionTeam.avatarInfo
end
function LogicTxMissionTeam.CreateAvatarInfo(uid, memberInfo)
  uid = tostring(uid)
  local sex = 1
  if memberInfo.gender then
    sex = memberInfo.gender
  end
  local show_info = {
    weapon = true,
    vehicle = true,
    helmet = true,
    bag = true,
    hand = true
  }
  local depot_show_info = memberInfo.depot_show_info or show_info
  local wareArray = {}
  if memberInfo.wear_ext then
    for k, v in pairs(memberInfo.wear_ext) do
      if k == ENUM_AVATAR_SHOW_TYPE.SHOW_POS_GLOVES then
        if depot_show_info.hand then
          table.insert(wareArray, AvatarData.ConvertToAvatarCustom(v))
        end
      else
        table.insert(wareArray, AvatarData.ConvertToAvatarCustom(v))
      end
    end
  end
  if memberInfo.bag_pendants then
    for k, v in pairs(memberInfo.bag_pendants) do
      table.insert(wareArray, AvatarData.CreateAvatarCustom(k))
    end
  end
  local avatarInfo = {
    gid = uid,
    BP_ARRAY_AvatarList = wareArray,
    avatar = memberInfo.avatar,
    skinInfo = memberInfo.skin_info
  }
  LogicTxMissionTeam.avatarInfo[uid] = avatarInfo
end
function LogicTxMissionTeam.CreateSelfAvatarInfo()
  local rolewear = {}
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:UpdateInvalidWearInfo(nil)
  local WearInfo = AvatarData.GetWearInfo()
  for k, v in pairs(WearInfo) do
    table.insert(rolewear, v)
  end
  local avatarSt = {
    gamegender = AvatarData.GetGameGender(),
    headid = AvatarData.GetHeadID(),
    hairid = AvatarData.GetHairID(),
    beardid = AvatarData.GetBeardID(),
    beardcolor = AvatarData.GetBeardColorID(),
    attr_info = DataMgr.avatarData.attr_info
  }
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bagInfo = fashionbag_data:GetCurrentFashionBag()
  local TableUtil = require("common.table_util")
  local skinInfo = TableUtil.CopyTable(bagInfo)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if bagInfo ~= nil then
    if bagInfo.head_show == 0 then
      if rolewear[1] and rolewear[1].ItemID then
        local item = wardrobe_data:GetHallDepotItemDataByResID(rolewear[1].ItemID)
        if skinInfo ~= nil and item and item.itemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot then
          skinInfo.head_show = rolewear[1].ItemID
          table.remove(rolewear, 1)
        end
      end
    elseif bagInfo.head_show == bagInfo.helmet_skin then
      if rolewear[1] and rolewear[1].ItemID then
        local item2 = wardrobe_data:GetHallDepotItemDataByResID(rolewear[1].ItemID)
        if item2 and item2.itemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot then
          skinInfo.head_show = rolewear[1].ItemID
          table.remove(rolewear, 1)
        end
      end
    else
      skinInfo.head_show = 0
    end
    skinInfo.helmet_skin = wardrobeLogic:GetItemResId(bagInfo.helmet_skin)
    skinInfo.bag_skin = wardrobeLogic:GetItemResId(bagInfo.bag_skin)
  end
  local bag_pendants = bagInfo and bagInfo.bag_pendants or {}
  for k, v in pairs(bag_pendants) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(k)
    if itemData then
      table.insert(rolewear, AvatarData.CreateAvatarCustom(itemData.resID))
    end
  end
  local uid = tostring(DataMgr.roleData.uid)
  local avatarInfo = {
    gid = uid,
    avatar = avatarSt,
    BP_ARRAY_AvatarList = rolewear,
      }
  LogicTxMissionTeam.avatarInfo[uid] = avatarInfo
end
function LogicTxMissionTeam.SetTeamInfo(uid, metro_team_info, metro_scence_status)
  uid = tostring(uid)
  local data = {
    uid = uid,
    metro_team_info = metro_team_info,
      }
  LogicTxMissionTeam.teamInfo = LogicTxMissionTeam.teamInfo or {}
  LogicTxMissionTeam.teamInfo[uid] = data
end
function LogicTxMissionTeam.CreateSelfTeamInfo(metro_team_info)
  local uid = tostring(DataMgr.roleData.uid)
  LogicTxMissionTeam.SetTeamInfo(uid, metro_team_info, 1)
  log_tree("LogicTxMissionTeam.CreateSelfTeamInfo myTeamInfo:", LogicTxMissionTeam.teamInfo[uid])
end
function LogicTxMissionTeam.TeamMemberQuitNotify(param)
  local uid = tostring(param.uid)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if tonumber(uid) == TeamUpNewSystem.GetSelfUID() then
    LogicTxMissionTeam.ClearData()
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    XMissionSystem.OnQuitXMission()
  else
  end
end
function LogicTxMissionTeam.RemoveMemberInfo(uid)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if tonumber(uid) == TeamUpNewSystem.GetSelfUID() then
    return
  end
  uid = tostring(uid)
  LogicTxMissionTeam.teamInfo[uid] = nil
  LogicTxMissionTeam.avatarInfo[uid] = nil
end
function LogicTxMissionTeam.ChangeAvatarNotify(param)
  if not param then
    return
  end
  local uid = tostring(param.uid)
  LogicTxMissionTeam.PutOffHelmetAndBag(uid)
  if LogicTxMissionTeam.teamInfo[uid] and LogicTxMissionTeam.teamInfo[uid].metro_team_info then
    LogicTxMissionTeam.teamInfo[uid].metro_team_info.avatar_info = param.metro_team_info and param.metro_team_info.avatar_info
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_MEMBER_CHANGE, uid)
end
function LogicTxMissionTeam.ChangeWorthNotify(param)
  if not param then
    return
  end
  local uid = tostring(param.uid)
  if LogicTxMissionTeam.teamInfo[uid] and LogicTxMissionTeam.teamInfo[uid].metro_team_info then
    LogicTxMissionTeam.teamInfo[uid].metro_team_info.metro_worth = param.metro_team_info.metro_worth
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_TEAM_INFO_SYNC, uid)
end
function LogicTxMissionTeam.MilitaryNotify(uid, militaryLvl)
  if not (uid and militaryLvl) or militaryLvl <= 0 then
    return
  end
  uid = tostring(uid)
  if LogicTxMissionTeam.teamInfo[uid] and LogicTxMissionTeam.teamInfo[uid].metro_team_info then
    LogicTxMissionTeam.teamInfo[uid].metro_team_info.military_level = militaryLvl
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_TEAM_INFO_SYNC, uid)
end
function LogicTxMissionTeam.ChangeBeginnerGuideNotify(param)
  log(bWriteLog and "LogicTxMissionTeam.ChangeBeginnerGuideNotify, param = " .. tostring(param))
  if not param then
    return
  end
  local uid = tostring(param.uid)
  if LogicTxMissionTeam.teamInfo[uid] and LogicTxMissionTeam.teamInfo[uid].metro_team_info then
    LogicTxMissionTeam.teamInfo[uid].metro_team_info.guide_progress = param.metro_team_info.guide_progress
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_TEAM_INFO_SYNC, uid)
end
function LogicTxMissionTeam.ChangePrestigeLevelNotify(param)
  if not param then
    return
  end
  local uid = tostring(param.uid)
  if LogicTxMissionTeam.teamInfo[uid] and LogicTxMissionTeam.teamInfo[uid].metro_team_info then
    LogicTxMissionTeam.teamInfo[uid].metro_team_info.prestige_level = param.metro_team_info.prestige_level
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_TEAM_INFO_SYNC, uid)
end
function LogicTxMissionTeam.CreatePetByUID(uid)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  local sharePetData = logic_share_bag_team_util:GetUsingSharePetInfoByUID(uid)
  if sharePetData then
    local petData = logic_pet:FormatPetDataByServerInfo(uid, sharePetData)
    XMissionAvatarMgr.CreatePet(uid, petData)
  else
    local pet_info
    if tonumber(uid) == TeamUpNewSystem.GetSelfUID() then
      pet_info = logic_pet:GetPetDataByInsID(logic_pet:GetEquipedPetInsID())
    else
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      pet_info = TeamUpNewSystem.GetMemberPetInfo(tonumber(uid))
    end
    if pet_info ~= nil and pet_info.id ~= 0 then
      local petLevel = logic_pet:GetPetLevelByExp(pet_info.id, pet_info.exp)
      local PetData = logic_pet:FormatPetDataByServerInfo(uid, pet_info)
      XMissionAvatarMgr.CreatePet(uid, PetData)
      if pet_info.name ~= nil then
        XMissionAvatarMgr.SetPetName(uid, pet_info.name)
      end
    end
  end
end
function LogicTxMissionTeam.CreateAvatar(uid)
  log(bWriteLog and "LogicTxMissionTeam.CreateAvatar uid = " .. tostring(uid))
  uid = tostring(uid)
  local avatarData = LogicTxMissionTeam.avatarInfo[uid]
  if not avatarData then
    log_warning("[edward][logic_xmission_team] LogicTxMissionTeam.CreateAvatar, have no avatar data, check the code!!!")
    return
  end
  local TableUtil = require("common.table_util")
  local spawnPlayerData = {
    gid = avatarData.gid,
    headId = avatarData.avatar.headid,
    sex = avatarData.avatar.gamegender - 1,
    headShow = avatarData.skinInfo and avatarData.skinInfo.head_show or 0,
    BP_ARRAY_AvatarList = avatarData.BP_ARRAY_AvatarList and TableUtil.CopyTable(avatarData.BP_ARRAY_AvatarList) or {}
  }
  if spawnPlayerData.sex == 0 then
    table.insert(spawnPlayerData.BP_ARRAY_AvatarList, AvatarData.CreateAvatarCustom(avatarData.avatar.beardid, avatarData.avatar.beardcolor))
  end
  table.insert(spawnPlayerData.BP_ARRAY_AvatarList, AvatarData.CreateAvatarCustom(avatarData.avatar.hairid))
  if avatarData.avatar.attr_info then
    for key, value in pairs(avatarData.avatar.attr_info) do
      table.insert(spawnPlayerData.BP_ARRAY_AvatarList, AvatarData.ConvertToAvatarCustom(value, true))
    end
  end
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local avatar = XMissionAvatarMgr.CreateAvatar(spawnPlayerData)
  if not avatar then
    log_warning("[edward][logic_xmission_team] LogicTxMissionTeam.CreateAvatar, create avatar failed!!!")
    return
  end
  local equipData = LogicTxMissionTeam.GetEquipDataByUID(uid)
  if equipData then
    avatar.isLoadXEquip = true
    LogicTxMissionTeam.UpdateAvatarByInfo(uid, equipData)
  else
    avatar.isLoadXEquip = false
  end
  LogicTxMissionTeam.CreatePetByUID(uid)
  return avatar
end
function LogicTxMissionTeam.UpdateAvatar(avatarUID)
  local uid = tostring(avatarUID)
  local equipData = LogicTxMissionTeam.GetEquipDataByUID(uid)
  if not equipData then
    log_warning("[edward][logic_xmission_team] LogicTxMissionTeam.UpdateAvatar, equipData is nil")
    return
  end
  LogicTxMissionTeam.UpdateAvatarByInfo(uid, equipData)
end
function LogicTxMissionTeam.UpdateAvatarByInfo(avatarUID, xAvatarInfo, isPreview, onlyPuton)
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local logic_xmission_wardrobe_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_wardrobe_setting)
  if isPreview then
    local info = LogicTxMissionTeam.avatarInfo[avatarUID]
    if info and info.BP_ARRAY_AvatarList then
      for i, v in ipairs(info.BP_ARRAY_AvatarList) do
        local wearInfo = {
          skinID = v.ItemID
        }
        XMissionAvatarMgr.PutOnEquipment(avatarUID, wearInfo, v)
      end
    end
  end
  local isEquipHelmet = false
  local Wear456LevelArmor = false
  local wear456Bag = false
  local wear456Helmet = false
  local slotEnumMap = _GetSlotEnumMap() or {}
  local handSlotID = LogicTxMissionTeam.GetHandWeapon(xAvatarInfo)
  for k, v in pairs(xMission_macro.Enum_Slot) do
    local info = xAvatarInfo[v]
    if not onlyPuton or info then
      local itemID = info and info.item_id or 0
      if v == xMission_macro.Enum_Slot.EnumSlot_Armor and logic_xmission_wardrobe_setting:Is456TItem(itemID) then
        Wear456LevelArmor = true
      end
      if v == xMission_macro.Enum_Slot.EnumSlot_Bag and logic_xmission_wardrobe_setting:Is456TItem(itemID) then
        wear456Bag = true
      end
      if v == xMission_macro.Enum_Slot.EnumSlot_Helmet and logic_xmission_wardrobe_setting:Is456TItem(itemID) then
        wear456Helmet = true
      end
      local slotID = slotEnumMap[v]
      if slotID then
        local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
        local weaponSkinInfo, weaponDiyPlanID
        if isPreview then
          info = LogicTxMissionTeam.avatarInfo[avatarUID]
          local skinInfo = info and info.skinInfo
          local weaponID = _GetWeaponOriginID(itemID)
          skinInfo = skinInfo.weapon_skin_list[weaponID]
          local skinID = skinInfo and wardrobeLogic:GetItemResId(skinInfo.skin_id) or 0
          weaponSkinInfo = {itemID = itemID, skinID = skinID}
          local diyConfig = WeaponDiySystem:GetWeaponCfg(weaponID)
          if diyConfig then
            local WardrobeGunLogic = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
            local diyInfo = WardrobeGunLogic:GetGunDiyInfo(skinID)
            if diyInfo then
              local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
              weaponDiyPlanID = weapon_diy_system:GetCurUsePlanIdByWeaponId(skinID)
            end
          end
        elseif info then
          local skinID = 0 < itemID and info.weapon_skin or 0
          weaponSkinInfo = {
            itemID = itemID,
            skinID = 0 < skinID and skinID or itemID
          }
          weaponDiyPlanID = info.weapon_diy and info.weapon_diy[3]
        else
          weaponSkinInfo = {itemID = 0, skinID = 0}
        end
        if weaponDiyPlanID and weaponDiyPlanID ~= "" then
          local isRecommend = WeaponDiySystem:IsPlanRecommend(weaponDiyPlanID)
          if isRecommend then
            XMissionAvatarMgr.EquipWeaponBySlotID(avatarUID, weaponSkinInfo, slotID, handSlotID == slotID)
            local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
            local schemeData = weapon_diy_rec_scheme[weaponSkinInfo.skinID]
            if schemeData then
              XMissionAvatarMgr.ChangeDiyWeaponScheme(avatarUID, schemeData, slotID)
            end
          else
            local scheme
            if avatarUID == tostring(DataMgr.roleData.uid) then
              scheme = WeaponDiySystem:GetSchemeData(weaponSkinInfo.skinID, weaponDiyPlanID)
            else
              local WeaponDiyHandler = require("client.network.Protocol.WeaponDiyHandler")
              scheme = WeaponDiyHandler.GetWeaponData(avatarUID, weaponDiyPlanID)
            end
            if scheme then
              XMissionAvatarMgr.EquipWeaponBySlotID(avatarUID, weaponSkinInfo, slotID, handSlotID == slotID)
              XMissionAvatarMgr.ChangeDiyWeaponScheme(avatarUID, scheme, slotID)
            else
              local WeaponDiyHandler = require("client.network.Protocol.WeaponDiyHandler")
              WeaponDiyHandler.send_get_player_ds_data_req(avatarUID, 1, {weaponDiyPlanID}, "lobby", nil)
            end
          end
        else
          XMissionAvatarMgr.EquipWeaponBySlotID(avatarUID, weaponSkinInfo, slotID, handSlotID == slotID)
        end
      else
        local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
        info = LogicTxMissionTeam.avatarInfo[avatarUID]
        local wearInfo = {itemID = itemID}
        local skinInfo = info and info.skinInfo
        if not skinInfo then
          log(bWriteLog and "[muidarzhang] ERROR: LogicTxMissionTeam.UpdateAvatarByInfo, not skinInfo. ")
          return
        end
        if v == xMission_macro.Enum_Slot.EnumSlot_Helmet then
          if itemID ~= 0 then
            isEquipHelmet = true
            wearInfo.skinID = _GetSkinItemID(skinInfo.helmet_skin, itemID)
          end
        elseif v == xMission_macro.Enum_Slot.EnumSlot_Bag and itemID ~= 0 then
          wearInfo.skinID = _GetSkinItemID(skinInfo.bag_skin, itemID)
        end
        local bHasHelmetSkin = _GetSkinItemID(skinInfo.helmet_skin, 502103) ~= 502103
        local bHasBagSkin = _GetSkinItemID(skinInfo.bag_skin, 501103) ~= 501103
        local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
        local bHideLobbyMetroFashion = LogicSettingBasic.GetOneSettingValue("MetroFashionLobbySwitcher")
        local bHideTeamFashion = avatarUID ~= tostring(DataMgr.roleData.uid) and bHideLobbyMetroFashion
        log(bWriteLog and "LogicTxMissionTeam.UpdateAvatarByInfo bHideTeamFashion = " .. tostring(bHideTeamFashion))
        if v == xMission_macro.Enum_Slot.EnumSlot_Armor and Wear456LevelArmor and (LogicDisplaySetting.LobbyHideMetroFashionArmor() and avatarUID == tostring(DataMgr.roleData.uid) or bHideTeamFashion) then
          if info and info.BP_ARRAY_AvatarList and next(info.BP_ARRAY_AvatarList) then
            for _, data in ipairs(info.BP_ARRAY_AvatarList) do
              XMissionAvatarMgr.PutOnEquipment(avatarUID, {
                skinID = data.ItemID
              }, data)
            end
          else
            local nChangeItemId = 503103
            local tChangeItem = {
              itemID = nChangeItemId,
              skinID = _GetSkinItemID(0, nChangeItemId)
            }
            XMissionAvatarMgr.PutOnEquipment(avatarUID, tChangeItem)
          end
        elseif v == xMission_macro.Enum_Slot.EnumSlot_Bag then
          if LogicDisplaySetting.HideMetroLobbyBag() then
            local EAvatarSlotType = import("EAvatarSlotType")
            XMissionAvatarMgr.PutOffBySlot(avatarUID, EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot)
          elseif wear456Bag and (LogicDisplaySetting.LobbyHideMetroFashionBackpack() and avatarUID == tostring(DataMgr.roleData.uid) or bHideTeamFashion) and bHasBagSkin then
            local nChangeItemId = 501103
            local tChangeItem = {
              itemID = nChangeItemId,
              skinID = _GetSkinItemID(skinInfo.bag_skin, nChangeItemId)
            }
            XMissionAvatarMgr.PutOnEquipment(avatarUID, tChangeItem)
          else
            XMissionAvatarMgr.PutOnEquipment(avatarUID, wearInfo)
          end
        elseif v == xMission_macro.Enum_Slot.EnumSlot_Helmet then
          if LogicDisplaySetting.HideMetroLobbyHelmet() then
            local EAvatarSlotType = import("EAvatarSlotType")
            XMissionAvatarMgr.PutOffBySlot(avatarUID, EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot)
          elseif wear456Helmet and (LogicDisplaySetting.LobbyHideMetroFashionHelmet() and avatarUID == tostring(DataMgr.roleData.uid) or bHideTeamFashion) and bHasHelmetSkin then
            local nChangeItemId = 502103
            local tChangeItem = {
              itemID = nChangeItemId,
              skinID = _GetSkinItemID(skinInfo.helmet_skin, nChangeItemId)
            }
            XMissionAvatarMgr.PutOnEquipment(avatarUID, tChangeItem)
          else
            XMissionAvatarMgr.PutOnEquipment(avatarUID, wearInfo)
          end
        else
          XMissionAvatarMgr.PutOnEquipment(avatarUID, wearInfo)
        end
      end
    end
  end
  if not isPreview and not isEquipHelmet and not Wear456LevelArmor then
    local info = LogicTxMissionTeam.avatarInfo[avatarUID]
    if info then
      local wearInfo = {
        skinID = info.skinInfo.head_show or 0
      }
      XMissionAvatarMgr.PutOnEquipment(avatarUID, wearInfo)
    end
  end
end
function LogicTxMissionTeam.UpdateHighLevelItem(avatarUID)
  local uid = tostring(avatarUID)
  local equipData = LogicTxMissionTeam.GetEquipDataByUID(uid)
  if not equipData then
    log_warning("[edward][logic_xmission_team] LogicTxMissionTeam.UpdateHighLevelItem, equipData is nil")
    return
  end
  local HighLevelItem = {}
  for _, v in pairs(xMission_macro.Enum_Slot) do
    if v == xMission_macro.Enum_Slot.EnumSlot_Helmet or v == xMission_macro.Enum_Slot.EnumSlot_Armor or v == xMission_macro.Enum_Slot.EnumSlot_Bag then
      HighLevelItem[v] = equipData[v]
    end
  end
  LogicTxMissionTeam.UpdateAvatarByInfo(uid, HighLevelItem, false, true)
end
function LogicTxMissionTeam.PreviewAvatarInfo(avatarInfo)
  LogicTxMissionTeam.UpdateAvatarByInfo(tostring(DataMgr.roleData.uid), avatarInfo, true)
end
function LogicTxMissionTeam.PutOffHelmetAndBag(avatarUID, avatarInfo)
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local uid = tostring(avatarUID)
  local equipData = avatarInfo or LogicTxMissionTeam.GetEquipDataByUID(uid)
  if not equipData then
    return
  end
  for k, slot in pairs(xMission_macro.Enum_Slot) do
    local info = LogicTxMissionTeam.avatarInfo[avatarUID]
    local EAvatarSlotType = import("EAvatarSlotType")
    if slot == xMission_macro.Enum_Slot.EnumSlot_Armor then
      XMissionAvatarMgr.PutOffBySlot(avatarUID, EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot)
      if info and info.BP_ARRAY_AvatarList then
        for i, tAvatarCustom in ipairs(info.BP_ARRAY_AvatarList) do
          local wearInfo = {
            skinID = tAvatarCustom.ItemID
          }
          XMissionAvatarMgr.PutOnEquipment(avatarUID, wearInfo, tAvatarCustom)
        end
      end
    elseif slot == xMission_macro.Enum_Slot.EnumSlot_Helmet then
      XMissionAvatarMgr.PutOffBySlot(avatarUID, EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot)
      if info and info.skinInfo then
        local wearInfo = {
          skinID = info.skinInfo.head_show or 0
        }
        XMissionAvatarMgr.PutOnEquipment(avatarUID, wearInfo)
      end
    elseif slot == xMission_macro.Enum_Slot.EnumSlot_Bag then
      XMissionAvatarMgr.PutOffBySlot(avatarUID, EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot)
    end
  end
end
function LogicTxMissionTeam.GetHandWeapon(avatarInfo)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local slotIDEnum = LobbyAvatarManager.Enum_WeaponAttachSlotID
  if avatarInfo[xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_1] then
    return slotIDEnum.MAIN_WEAPON1
  end
  if avatarInfo[xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_2] then
    return slotIDEnum.MAIN_WEAPON2
  end
  if avatarInfo[xMission_macro.Enum_Slot.EnumSlot_Knife] then
    return slotIDEnum.MELEE
  end
  if avatarInfo[xMission_macro.Enum_Slot.EnumSlot_Pistol] then
    return slotIDEnum.PISTOL
  end
  return nil
end
function LogicTxMissionTeam.sync_player_action(player_uid, action_id, randSoundId, follow_id, extraParam)
  log(bWriteLog and "[edward][logic_xmission_team] LogicTxMissionTeam.sync_player_action player_uid = " .. tostring(player_uid) .. ", action_id = " .. tostring(action_id) .. ",randSoundId=" .. tostring(randSoundId))
  local extraInfo = extraParam and extraParam.extraInfo or nil
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local sex = logic_profile:GetRoleSexByUid(player_uid, true)
  if GlobalData.IsJapanOrKorea() then
    local itemCfg = CDataTable.GetTableData("Item", action_id)
    if itemCfg and itemCfg.JKBPID > 0 then
      action_id = itemCfg.JKBPID
    end
  end
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if TeamUpNewSystem.GetTeamNum() > 1 and TeamUpNewSystem.IsTeamLeader(player_uid) and TeamUpNewSystem.CheckEmoteCanFollow(action_id) then
    local FollowerUIDS = TeamUpNewSystem.GetEmoteFollowersUID()
    for _, uid in pairs(FollowerUIDS) do
      local EmoteID = TeamUpNewSystem.GetFollowPlayEmoteID(uid, action_id)
      XMissionAvatarMgr.PlayAction(uid, EmoteID, extraInfo)
      LobbyAvatarManager.PlayEmotionSound(EmoteID, logic_profile:GetRoleSexByUid(uid, true), randSoundId, uid)
    end
  end
  local EmoteID = TeamUpNewSystem.GetFollowPlayEmoteID(player_uid, action_id)
  XMissionAvatarMgr.PlayAction(player_uid, EmoteID, extraInfo or follow_id)
  LobbyAvatarManager.PlayEmotionSound(EmoteID, sex, randSoundId, player_uid)
end
function LogicTxMissionTeam.IsConfirmSelect(uid)
  for k, v in pairs(LogicTxMissionTeam.wait_members) do
    if tonumber(uid) == tonumber(v) then
      return false
    end
  end
  return true
end
function LogicTxMissionTeam.on_metro_select_confirm_rsp(mode)
  if mode and mode.mode_group and mode.mode_group > 0 then
    local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
    LogicTxMissionMatch.SetSelModel(mode)
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_SELECT_MAP_RSP)
  end
end
function LogicTxMissionTeam.GetXMissionTeamInfoByUID(uid)
  if LogicTxMissionTeam.teamInfo then
    return LogicTxMissionTeam.teamInfo[uid]
  end
  return nil
end
function LogicTxMissionTeam.GetTeamInfoByUID(uid)
  if LogicTxMissionTeam.teamInfo and LogicTxMissionTeam.teamInfo[uid] then
    return LogicTxMissionTeam.teamInfo[uid].metro_team_info
  end
  return nil
end
function LogicTxMissionTeam.GetEquipDataByUID(uid)
  local teamInfo = LogicTxMissionTeam.GetTeamInfoByUID(uid)
  if teamInfo then
    return teamInfo.avatar_info and teamInfo.avatar_info.slots or teamInfo.slots
  end
  return nil
end
function LogicTxMissionTeam.GetAvatarInfoByUID(uid)
  if LogicTxMissionTeam.avatarInfo then
    return LogicTxMissionTeam.avatarInfo[uid]
  end
  return nil
end
function LogicTxMissionTeam.CheckCanPlay()
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local mode_group = LogicTxMissionMatch.GetSelModel()
  return LogicTxMissionMatch.CheckModeIsUnlock(mode_group, true)
end
local C_DefaultModeID = 23004
function LogicTxMissionTeam.GetModeShowInfo(modeID)
  local TxMissionMapMode = CDataTable.GetTableData("TxMissionMapMode", modeID or C_DefaultModeID)
  TxMissionMapMode = TxMissionMapMode or CDataTable.GetTableData("TxMissionMapMode", C_DefaultModeID)
  if not TxMissionMapMode then
    return nil
  end
  local TxMissionMode = CDataTable.GetTableData("TxMissionMode", TxMissionMapMode.ModeType)
  local TxMissionMap = CDataTable.GetTableData("TxMissionMap", TxMissionMapMode.MapID)
  return TxMissionMap and TxMissionMap.Name or "", TxMissionMode and TxMissionMode.Name or ""
end
function LogicTxMissionTeam.OnChangeDiyWeaponScheme(_, _, uid, weaponID, scheme)
  if GameStatus.IsInLobbyOrMainCity() and weaponID then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    local slots = LogicTxMissionTeam.GetEquipDataByUID(uid)
    if not slots then
      return
    end
    local handSlotID = LogicTxMissionTeam.GetHandWeapon(slots)
    for k, v in pairs(slots) do
      local slotID = tonumber(k)
      if weaponID == v.res_id and (slotID == xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_1 or slotID == xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_2) then
        XMissionAvatarMgr.EquipWeaponBySlotID(uid, weaponID, slotID, handSlotID == slotID)
        if scheme then
          XMissionAvatarMgr.ChangeDiyWeaponScheme(uid, scheme, slotID)
        end
      end
    end
  end
end
function LogicTxMissionTeam.UpdateLobbyCamera(withoutAnim, isForce)
  local updateCamera = function()
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    if TeamUpNewSystem.GetTeamNum() == 1 then
      Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.TPlan_Default, not withoutAnim and 1.0)
    else
      Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.TPlan_Team, not withoutAnim and 1.0)
    end
  end
  if isForce then
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_RETURN_LOBBY)
    updateCamera()
  else
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    if XMissionAvatarMgr.IsShowing() then
      updateCamera()
    end
  end
end
function LogicTxMissionTeam.GetTeamInfoMetroWorthByUid(uid)
  local metroWorth = 0
  if not uid then
    return metroWorth
  end
  uid = tostring(uid)
  if LogicTxMissionTeam.teamInfo and LogicTxMissionTeam.teamInfo[uid] and LogicTxMissionTeam.teamInfo[uid].metro_team_info then
    metroWorth = LogicTxMissionTeam.teamInfo[uid].metro_team_info.metro_worth or 0
  end
  return metroWorth
end
return LogicTxMissionTeam