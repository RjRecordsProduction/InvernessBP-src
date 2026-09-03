local TeamAvatarManager = {}
TeamAvatarManager.MUTEX_TEMP = "MUTEX_TEMP"
TeamAvatarManager.MUTEX_OPEN_BOX = "OpenBoxUI"
TeamAvatarManager.MUTEX_ROLEINFO = "RoleInfo"
TeamAvatarManager.MUTEX_WARDROBE = "Wardrobe"
TeamAvatarManager.MUTEX_LuckAirDropBox = "LuckAirPlay"
TeamAvatarManager.MUTEX_Preview = "Preview"
TeamAvatarManager.MUTEX_X_MISSION = "XMission"
TeamAvatarManager.NeedCorrect = false
TeamAvatarManager.CreateMySelf = false
TeamAvatarManager.TryEquipWeapon = {}
local delegateContainer
local _isShowing = true
local BAG = 0
local HELMET = 1
local HAND = 2
local POSITION_KEY_OCCUPIED = 4
local _teamPosition = {
  {
    -18.46,
    0,
    89.5,
    false
  },
  {
    105.36,
    -37.58,
    89.5,
    false
  },
  {
    36.22,
    -113.74,
    89.5,
    false
  },
  {
    194.5,
    -100.75,
    89.5,
    false
  },
  {
    -18.46,
    0,
    89.5,
    false
  },
  {
    105.36,
    -37.58,
    89.5,
    false
  },
  {
    36.22,
    -113.74,
    89.5,
    false
  },
  {
    194.5,
    -100.75,
    89.5,
    false
  }
}
local _GarageTeamPosition = {
  {
    -74.791245,
    -63.316406,
    89.5,
    false
  },
  {
    109.38259,
    -90.687241,
    89.5,
    false
  },
  {
    6.611,
    -108.35017,
    89.5,
    false
  },
  {
    219.52055,
    -157.99586,
    89.5,
    false
  },
  {
    -74.791245,
    -63.316406,
    89.5,
    false
  },
  {
    109.38259,
    -90.687241,
    89.5,
    false
  },
  {
    6.611,
    -108.35017,
    89.5,
    false
  },
  {
    219.52055,
    -157.99586,
    89.5,
    false
  }
}
local C_TeamGroupNum = 4
local _showTeamGroup = 1
local _mutex
local _avatars = {}
local _uid2PetData = {}
local _avatarDepotShowSettings = {}
local local _logErrorAvatarNotExisted = function(avatarUID)
  log_error("TeamAvatarManager:_logErrorAvatarNotExisted: " .. tostring(avatarUID))
end
local _GetTeamPosition = function()
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  if GarageThemeSystem:IsInGarageTheme() then
    return _GarageTeamPosition
  end
  return _teamPosition
end
local _GetEmptyPosition = function(uid)
  local result = {}
  for i, v in ipairs(_GetTeamPosition()) do
    if (i ~= 1 or uid == DataMgr.roleData.uid) and v[POSITION_KEY_OCCUPIED] == false then
      result.x = v[1]
      result.y = v[2]
      result.z = v[3]
      result.index = i
      if i == 1 and TeamAvatarManager.SingleInGarage() then
        local position = _GetTeamPosition()[3]
        result.x = position[1]
        result.y = position[2]
        result.z = position[3]
      end
      return result
    end
  end
  return nil
end
local _OccupyPosition = function(index, value)
  _teamPosition[index][POSITION_KEY_OCCUPIED] = value
  _GarageTeamPosition[index][POSITION_KEY_OCCUPIED] = value
end
local _IsVaildItemID = function(itemID)
  if itemID == 0 then
    log(bWriteLog and "itemID not valid:" .. tostring(itemID))
    return false
  end
  if itemID == nil then
    log_error("TeamAvatarManager:_IsVaildItemID itemID not valid:" .. tostring(itemID))
    return false
  end
  if type(itemID) ~= "number" then
    log_error("TeamAvatarManager:_IsVaildItemID itemID not valid:" .. tostring(itemID))
    return false
  end
  return true
end
function TeamAvatarManager.AvatarInShowGroup(index)
  if not index then
    return false
  end
  return index > C_TeamGroupNum * (_showTeamGroup - 1) and index <= C_TeamGroupNum * _showTeamGroup
end
function TeamAvatarManager.SwitchTeamGroup(group)
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return
  end
  assert(group and 0 < group and group <= 2, "TeamAvatarManager.SwitchTeamGroup group and group > 0 and group <= 2")
  _showTeamGroup = group
  for uid, v in pairs(_avatars) do
    TeamAvatarManager.StopAction(uid)
  end
  TeamAvatarManager.ShowAllAvatar()
end
function TeamAvatarManager.GetMutex(mutex)
  if _mutex ~= nil then
    log(bWriteLog and "[TeamAvatarManager] GetMutex " .. tostring(mutex) .. " failure , current mutex is" .. tostring(_mutex))
    return
  end
  _end
function TeamAvatarManager.ReleaseMutex(mutex)
  if _mutex ~= mutex then
    log(bWriteLog and "[TeamAvatarManager] ReleaseMutex " .. tostring(mutex) .. " failure , current mutex is" .. tostring(_mutex))
    return
  end
  _mutex = nil
end
function TeamAvatarManager.Init()
  TeamAvatarManager.Destroy()
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, TeamAvatarManager.OnGameStateChange)
  EventSystem:registEvent(EVENTTYPE_PET, EVENTID_PET_PLAY_ACTION, TeamAvatarManager.OnTeamPetAction)
  EventSystem:registEvent(EVENTTYPE_PET, EVENTID_PET_LEVEL_UP, TeamAvatarManager.OnTeamPetLevelup)
  EventSystem:registEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, TeamAvatarManager.OnChangeTeamPet)
  EventSystem:registEvent(EVENTTYPE_PET, EVENTID_PET_RENAME, TeamAvatarManager.OnChangeTeamPetName)
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_GET_PLAYER_SCHEME_DATA, TeamAvatarManager.OnChangeDiyWeaponScheme)
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_BUY_PLANE_SUC, TeamAvatarManager.OnBuyDiyWeaponPlan)
  EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, TeamAvatarManager.OnPutOnItem)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR, TeamAvatarManager.OnWearChange)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_AVATAR, TeamAvatarManager.OnAvatarChange)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_HEADSHOW, TeamAvatarManager.OnHeadShowChange)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR_PAIR, TeamAvatarManager.OnWearPairChange)
  EventSystem:registEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, TeamAvatarManager.OnCameraSwitch)
  EventSystem:registEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_LOADED, TeamAvatarManager.OnBeginLobbySkinChange)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM, TeamAvatarManager.OnTeamChange)
  local delegate_container = require("common.delegate_container")
  delegateContainer = delegate_container()
  _showTeamGroup = 1
end
function TeamAvatarManager.Destroy()
  log(bWriteLog and "TeamAvatarManager.Destroy")
  EventSystem:unregistEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, TeamAvatarManager.OnGameStateChange)
  EventSystem:unregistEvent(EVENTTYPE_PET, EVENTID_PET_PLAY_ACTION, TeamAvatarManager.OnTeamPetAction)
  EventSystem:unregistEvent(EVENTTYPE_PET, EVENTID_PET_LEVEL_UP, TeamAvatarManager.OnTeamPetLevelup)
  EventSystem:unregistEvent(EVENTTYPE_PET, EVENTID_PET_EQUIP_PET_CHANGE, TeamAvatarManager.OnChangeTeamPet)
  EventSystem:unregistEvent(EVENTTYPE_PET, EVENTID_PET_RENAME, TeamAvatarManager.OnChangeTeamPetName)
  EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_GET_PLAYER_SCHEME_DATA, TeamAvatarManager.OnChangeDiyWeaponScheme)
  EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_BUY_PLANE_SUC, TeamAvatarManager.OnBuyDiyWeaponPlan)
  EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, TeamAvatarManager.OnPutOnItem)
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR, TeamAvatarManager.OnWearChange)
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_AVATAR, TeamAvatarManager.OnAvatarChange)
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_HEADSHOW, TeamAvatarManager.OnHeadShowChange)
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR_PAIR, TeamAvatarManager.OnWearPairChange)
  EventSystem:unregistEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, TeamAvatarManager.OnCameraSwitch)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_LOADED, TeamAvatarManager.OnBeginLobbySkinChange)
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM, TeamAvatarManager.OnTeamChange)
  TeamAvatarManager.PetData = {}
  _mutex = nil
  _showTeamGroup = 1
  for k, avatar in pairs(_avatars) do
    avatar:Destroy()
  end
  _avatars = {}
  for i, v in ipairs(_teamPosition) do
    _OccupyPosition(i, false)
  end
  _avatarDepotShowSettings = {}
  if delegateContainer then
    delegateContainer:Dispose()
    delegateContainer = nil
  end
  if TeamAvatarManager.UpdateAvatarShowTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(TeamAvatarManager.UpdateAvatarShowTimer)
  end
  TeamAvatarManager.UpdateAvatarShowTimer = nil
end
function TeamAvatarManager.GetAvatarLevel(isTeammate)
  local lowDevice = false
  local level = Client.GetExactDeviceLevel()
  if level == -1 or level == 0 then
    lowDevice = true
  end
  local lowAvatar = HDmpveRemote.HDmpveRemoteConfigGetInt("LobbyLowAvatar", 0)
  if lowAvatar ~= 0 then
    return lowAvatar
  end
  if lowDevice == true then
    if isTeammate ~= true then
      return 2
    else
      return 3
    end
  elseif isTeammate ~= true then
    return 1
  else
    return 2
  end
end
function TeamAvatarManager.GetModel(AvatarUID)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  return avatar:GetModel()
end
function TeamAvatarManager.CreateAvatar(playerData)
  log(bWriteLog and "[TeamAvatarManager] CreateAvatar")
  local uid = tostring(playerData.gid)
  local showPosition = _GetEmptyPosition(uid)
  if not showPosition then
    log(bWriteLog and "[TeamAvatarManager] _teamPosition is full... not create")
    return
  end
  if _avatars[uid] then
    return
  end
  _OccupyPosition(showPosition.index, true)
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  local modelSex = AvatarCommon.DataSexToModelSex(playerData.sex)
  local _avatarData = {
    gamegender = modelSex,
    headid = playerData.headId,
    bDisableUpdatePos = true
  }
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  _avatarData.avatarLevel = TeamAvatarManager.GetAvatarLevel(playerData.isTeammate)
  local avatar = MultipleAvatarManager.CreateMultipleAvatar(_avatarData, showPosition)
  avatar:SetPosition(showPosition.x or 0, showPosition.y or 0, showPosition.z or 0)
  avatar.positionIndex = showPosition.index
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  avatar:SetSceneType(LobbyAvatarManager.Enum_SceneType.LOBBY_PURE)
  avatar:SetSceneType2(LobbyAvatarManager.Enum_SceneType2.Main)
  avatar:SetNeedLookAtCamera(true)
  _avatars[uid] = avatar
  local petData = _uid2PetData[uid]
  if petData then
    avatar:CreateMyPetIfNot(uid, petData)
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_AVATAR_CREATED, uid)
  local pawn = avatar:GetModel()
  if pawn and slua.isValid(pawn) then
    pawn:SetPlayerUID(uid)
  else
    log_error(bWriteLog and "TeamAvatarManager.CreateAvatar SetPlayerUID false")
  end
  avatar:EnableHatHelmetMutex(false)
  avatar:EnableLobbyShowItem(false)
  if uid ~= tostring(DataMgr.roleData.uid) then
    avatar:SetCanPlaySwitchWeapon(true)
  end
  local isSelf = tonumber(uid) == tonumber(DataMgr.roleData.uid)
  log(bWriteLog and "totalTakeoff " .. tostring(isSelf))
  log(bWriteLog and "totalTakeoff " .. tostring(TeamAvatarManager.NeedCorrect))
  local equipments = {}
  TeamAvatarManager._CreateEquipmentInfo(equipments, playerData.headShow)
  TeamAvatarManager._CreateEquipmentInfo(equipments, playerData.weaponResId, nil, {isCurUsingWeapon = true})
  TeamAvatarManager._CreateEquipmentInfo(equipments, playerData.bagSkinInsId)
  for _, v in pairs(playerData.extraWeaponInfoList) do
    if type(v) == "table" then
      local extraData = {
        isExtraWeapon = true,
        weaponId = v.weapon_id,
        skinId = v.skin_id,
        isUsingRecommend = v.is_using_recommend,
        curUsePlan = v.cur_use_plan
      }
      TeamAvatarManager._CreateEquipmentInfo(equipments, v.weapon_id, nil, extraData)
    end
  end
  for _, v in pairs(playerData.BP_ARRAY_AvatarList) do
    TeamAvatarManager._CreateEquipmentInfo(equipments, v.ItemID, v)
  end
  if isSelf then
    local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
    if not LogicDisplaySetting.ShowIdle() then
      avatar:SetForceUseDefaultIdle(true)
    end
  end
  if isSelf and TeamAvatarManager.NeedCorrect == true then
    TeamAvatarManager.NeedCorrect = false
    local equipmentIDList = {}
    for itemID, v in pairs(equipments) do
      table.insert(equipmentIDList, itemID)
    end
    equipmentIDList = LobbyAvatarManager.SortEquipmentIDList(equipmentIDList)
    local totalTakeoff = {}
    for i, data in ipairs(equipmentIDList) do
      local info = equipments[data.itemID]
      if info then
        if info.extraData.isCurUsingWeapon then
          local weaponID, _, isRecommend = DataMgr.GetCurrentWeaponID()
          local weapon_wear_info = {
            weaponId = weaponID,
            skinId = weaponID,
            usingDiyRecommend = isRecommend,
            diyPlanId = DataMgr.Weapon_Diy_PlanID
          }
          LobbyAvatarManager.EquipWeapon(uid, weapon_wear_info, nil, true)
        elseif info.extraData.isExtraWeapon then
          local weaponID, isRecommend = DataMgr.GerExtraWeaponID(info.extraData.weaponId, info.extraData.skinId, info.extraData.isUsingRecommend, info.extraData.curUsePlan)
          local weapon_wear_info = {
            weaponId = weaponID,
            skinId = weaponID,
            usingDiyRecommend = isRecommend,
            diyPlanId = DataMgr.Weapon_Diy_PlanID
          }
          LobbyAvatarManager.EquipWeapon(uid, weapon_wear_info, nil, false)
        else
          TeamAvatarManager.PutonEquipment(uid, info.itemID, info.tAvatarCustom)
        end
      end
      local es = avatar:GetTakeoffEquipments()
      for i, itemID in ipairs(es) do
        totalTakeoff[itemID] = 1
      end
    end
    local result = {}
    local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
    for itemID, v in pairs(totalTakeoff) do
      local insId = logic_wardrobe_avatar:GetRealWearInsID(itemID)
      if insId ~= -1 then
        table.insert(result, insId)
      end
    end
    if 0 < #result then
      local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
      WardRobeHandler.send_depot_batch_put_down_req(result)
    end
  else
    TeamAvatarManager.PutonEquipment(uid, playerData.headShow)
    TeamAvatarManager.PutonEquipment(uid, playerData.bagSkinInsId)
    local weaponID, _, isRecommend = DataMgr.GetCurrentWeaponID()
    local weapon_wear_info = {
      weaponId = weaponID,
      skinId = weaponID,
      usingDiyRecommend = isRecommend,
      diyPlanId = DataMgr.Weapon_Diy_PlanID
    }
    LobbyAvatarManager.EquipWeapon(tostring(DataMgr.roleData.uid), weapon_wear_info, nil, true)
    for _, v in pairs(playerData.extraWeaponInfoList) do
      local extraWeaponID, isRecommendExtra = DataMgr.GerExtraWeaponID(v.weapon_id, v.skin_id, v.is_using_recommend, v.cur_use_plan)
      local extra_weapon_wear_info = {
        weaponId = extraWeaponID,
        skinId = extraWeaponID,
        usingDiyRecommend = isRecommendExtra,
        diyPlanId = v.cur_use_plan
      }
      LobbyAvatarManager.EquipWeapon(tostring(DataMgr.roleData.uid), extra_weapon_wear_info, nil, false)
    end
    for i, v in ipairs(playerData.BP_ARRAY_AvatarList) do
      TeamAvatarManager.PutonEquipment(uid, v.ItemID, v)
    end
  end
  if _isShowing == false then
    avatar:HideAvatar()
  end
  if not TeamAvatarManager.AvatarInShowGroup(avatar.positionIndex) then
    avatar:HideAvatar()
  end
  local PetData = TeamAvatarManager.PetData[tostring(uid)]
  if PetData ~= nil then
    log(bWriteLog and "TeamAvatarManager.CreateAvatar. PetData~=nil PetID: " .. tostring(PetData and PetData.ServerInfo and PetData.ServerInfo.id))
    TeamAvatarManager.OnChangeTeamPetImpl(PetData)
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local bNeed, wearID = LogicXSuit.CheckNeedPutOnRelic(uid)
  if bNeed then
    TeamAvatarManager.PutonEquipment(uid, wearID)
  end
  TeamAvatarManager._SetTimerToUpdateAllAvatar()
  return avatar
end
function TeamAvatarManager.UpdateAvatarPosition()
  log(bWriteLog and "TeamAvatarManager.UpdateAvatarPosition")
  for key, avatar in pairs(_avatars) do
    local showPosition = TeamAvatarManager.GetAvatarPosition(avatar.positionIndex)
    avatar:SetShowPosition(showPosition[1] or 0, showPosition[2] or 0, showPosition[3] or 0)
  end
  if not TeamAvatarManager.IsShowing() then
    return
  end
  for key, avatar in pairs(_avatars) do
    local pet = avatar:GetPet()
    if pet then
      pet:UpdateTeamPosIndex(avatar.positionIndex)
    end
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_AVATAR_POSITION_CHANGE)
end
function TeamAvatarManager.GetAvatarPosition(index)
  for k, v in pairs(_avatars) do
    if v.positionIndex == index then
      if index == 1 and TeamAvatarManager.SingleInGarage(index) then
        return _GetTeamPosition()[3]
      end
      return _GetTeamPosition()[index]
    end
  end
  return nil
end
function TeamAvatarManager.SingleInGarage()
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if GarageThemeSystem:IsInGarageTheme() and not TeamUpNewSystem.IsInTeam() then
    return true
  end
  return false
end
function TeamAvatarManager.DestroyAvatar(playerData, isLockPosition)
  log(bWriteLog and "[TeamAvatarManager] DestroyAvatar")
  local gid = tostring(playerData.gid)
  local avatar = _avatars[gid]
  if avatar == nil then
    _logErrorAvatarNotExisted(gid)
    return false
  end
  local index = avatar.positionIndex
  avatar:Destroy()
  _avatars[gid] = nil
  _uid2PetData[gid] = nil
  for i, v in ipairs(_teamPosition) do
    _OccupyPosition(i, false)
  end
  for k, v in pairs(_avatars) do
    if v.positionIndex == 1 then
      _OccupyPosition(v.positionIndex, true)
    else
      local needChangePosition = false
      local changeGroup = false
      if not isLockPosition and index ~= 1 and index < v.positionIndex then
        v.positionIndex = v.positionIndex - 1
        needChangePosition = true
        if v.positionIndex == C_TeamGroupNum then
          changeGroup = true
        end
      end
      _OccupyPosition(v.positionIndex, true)
      if needChangePosition then
        local pos = _GetTeamPosition()[v.positionIndex]
        v:SetShowPosition(pos[1], pos[2], pos[3])
        if changeGroup then
          v:ShowAvatar()
        end
        if not TeamAvatarManager.AvatarInShowGroup(v.positionIndex) then
          v:HideAvatar()
        end
      end
    end
  end
  TeamAvatarManager.UpdateMyPetAI()
  TeamAvatarManager._SetTimerToUpdateAllAvatar()
  return true
end
function TeamAvatarManager._CreateEquipmentInfo(t, itemID, tAvatarCustom, extraData)
  itemID = tonumber(itemID or 0)
  extraData = extraData or {}
  local data = {}
  data.  data.  data.  t[itemID] = data
end
function TeamAvatarManager.PlayGoldenSuitOrSegmentAction(AvatarUID, action_data)
  if not action_data then
    log(bWriteLog and "TeamAvatarManager.PlayGoldenSuitOrSegmentAction not action_data")
    return
  end
  log(bWriteLog and "TeamAvatarManager.PlayGoldenSuitOrSegmentAction action_id:" .. tostring(action_data.action_id))
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    log(bWriteLog and "TeamAvatarManager.PlayGoldenSuitOrSegmentAction not avatar")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() <= 1 then
    log(bWriteLog and "TeamAvatarManager.PlayGoldenSuitOrSegmentAction not in team")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission(false) then
    log(bWriteLog and "TeamAvatarManager.PlayGoldenSuitOrSegmentAction in xmission")
    return
  end
  local wardrobeShow = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  if AvatarUID == DataMgr.roleData.uid and (wardrobeShow or logicCreateRole.IsShowing()) then
    log(bWriteLog and "TeamAvatarManager.PlayGoldenSuitOrSegmentAction in wardrobe")
    return
  end
  local LobbySystem = require("client.logic.login.logic_lobby")
  local Enum_LobbyDownloadResType = LobbySystem.Enum_LobbyDownloadResType
  if action_data.action_id and action_data.action_id ~= 0 then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
      action_data.action_id
    })
    if state ~= PufferConst.ENUM_DownloadState.Done then
      local PufferSwitch = require("client.slua.logic.download.puffer_switch")
      if PufferSwitch.CanAutoDownload() then
        log(bWriteLog and "TeamAvatarManager.PlayGoldenSuitOrSegmentAction action not download " .. tostring(action_data.action_id))
        ShowNotice(7421)
      end
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_TEAM_RES_DOWNLOAD_UI, AvatarUID, Enum_LobbyDownloadResType.EntryAction, {
        action_data.action_id
      })
    else
      avatar:PlayAction(action_data.action_id, nil, nil, {bStopDelay = false})
      local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
      LobbyAvatarManager.PlayEmotionSound(action_data.action_id, 1, 0, AvatarUID)
    end
  else
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_TEAM_RES_DOWNLOAD_UI, AvatarUID, Enum_LobbyDownloadResType.EntryAction, {})
  end
  if action_data.effect_id and action_data.effect_id ~= 0 then
    avatar:PlayGodEffect(action_data.effect_id)
  end
end
local NoticeOffsetCfg = {
  -20,
  -20,
  50,
  50
}
function TeamAvatarManager.PlayTeamupAction(AvatarUID, action_data)
  if not action_data then
    return
  end
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  if LobbyThemeManager and LobbyThemeManager:IsPreviewTheme() then
    log(bWriteLog and "TeamAvatarManager.PlayTeamupAction skip in preview theme, AvatarUID: " .. tostring(AvatarUID) .. ", action_id: " .. tostring(action_data.action_id))
    return
  end
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() <= 1 then
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission(false) then
    return
  end
  local wardrobeShow = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  if AvatarUID == DataMgr.roleData.uid and (wardrobeShow or logicCreateRole.IsShowing()) then
    return
  end
  local tNeedDownloadRes = {}
  if action_data.effect_ui and action_data.effect_ui.UI_Config then
    local res = action_data.effect_ui.res
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local downloadType = PufferConst.ENUM_DownloadType.ODPAK
    local state = PufferManager.GetState(downloadType, {res})
    if state ~= PufferConst.ENUM_DownloadState.Done then
      table.insert(tNeedDownloadRes, res)
    else
      local ui = UIManager.GetUI(UIManager.UI_Config.team_main)
      if ui then
        ui:AddEffectUI(AvatarUID, action_data.effect_ui.UI_Config, action_data.effect_ui.params)
      end
    end
  end
  if action_data.action_id and action_data.action_id ~= 0 then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
      action_data.action_id
    })
    if state ~= PufferConst.ENUM_DownloadState.Done then
      local PufferSwitch = require("client.slua.logic.download.puffer_switch")
      if PufferSwitch.CanAutoDownload() then
        log(bWriteLog and "TeamAvatarManager.PlayTeamupAction action not download " .. tostring(action_data.action_id))
        ShowNotice(7421)
      end
      table.insert(tNeedDownloadRes, action_data.action_id)
    else
      avatar:PlayAction(action_data.action_id, nil, nil, {bStopDelay = false})
    end
  end
  local Enum_LobbyDownloadResType = LobbySystem.Enum_LobbyDownloadResType
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_TEAM_RES_DOWNLOAD_UI, AvatarUID, Enum_LobbyDownloadResType.EntryAction, tNeedDownloadRes)
  if action_data.effect_id and action_data.effect_id ~= 0 then
    avatar:PlayTeamupEffect(action_data.effect_id)
  end
  if action_data.notice_text and action_data.notice_text ~= "" then
    local offsetY = NoticeOffsetCfg[avatar.positionIndex] or -20
    avatar:ShowTeamupAvatarNotice(action_data.notice_text, FVector2D(-140, offsetY))
  end
end
function TeamAvatarManager.PlayGodByCheck(AvatarUID)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  if LobbyThemeManager and LobbyThemeManager:IsPreviewTheme() then
    log(bWriteLog and "TeamAvatarManager.PlayGodByCheck skip in preview theme, AvatarUID: " .. tostring(AvatarUID))
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() <= 1 then
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission(false) then
    return
  end
  local wardrobeShow = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  if AvatarUID == DataMgr.roleData.uid and (wardrobeShow or logicCreateRole.IsShowing()) then
    return
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.CheckAndPlayEnterAction(AvatarUID) then
    return
  end
  local TableUtil = require("common.table_util")
  local memberInfo = TableUtil.GetTableValue(TeamUpNewSystem.teamInfo, "members", tonumber(AvatarUID))
  if memberInfo == nil or memberInfo.last_season_max_segment == nil then
    return
  end
  local last_season_max_segment = memberInfo.last_season_max_segment
  local seasonid = tonumber(DataMgr.season_id)
  if seasonid and seasonid <= 8 then
    if 801 <= last_season_max_segment then
      log(bWriteLog and "PlayGodByCheck last_season_max_segment >= 801 team actionID:2202401")
      avatar:PlayAction(2202401, nil, nil, {bStopDelay = false})
      avatar:PlayGodEffect(3)
    end
  elseif 601 <= last_season_max_segment then
    log(bWriteLog and "PlayGodByCheck last_season_max_segment >= 601 team actionID:2202401")
    avatar:PlayAction(2202401, nil, nil, {bStopDelay = false})
    local last_active_season_id = memberInfo.last_active_season_id or 0
    if 47 <= last_active_season_id then
      if 801 <= last_season_max_segment then
        avatar:PlayGodEffect(203)
      elseif 720 <= last_season_max_segment then
        avatar:PlayGodEffect(202)
      elseif 715 <= last_season_max_segment then
        avatar:PlayGodEffect(201)
      elseif 701 <= last_season_max_segment then
        avatar:PlayGodEffect(200)
      else
        avatar:PlayGodEffect(100)
      end
    elseif 20 <= last_active_season_id then
      if 801 <= last_season_max_segment then
        avatar:PlayGodEffect(104)
      elseif 720 <= last_season_max_segment then
        avatar:PlayGodEffect(103)
      elseif 715 <= last_season_max_segment then
        avatar:PlayGodEffect(102)
      elseif 701 <= last_season_max_segment then
        avatar:PlayGodEffect(101)
      else
        avatar:PlayGodEffect(100)
      end
    else
      local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
      local zoneid = memberInfo.self_zone_id or TeamUpNewSystem.teamInfo.zone_id
      if not zoneid or zoneid == 0 then
        local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
        zoneid = ZoneSystem.GetChooseZone() or 0
      end
      log(bWriteLog and "TeamAvatarManager.PlayGodByCheck. zoneid = " .. tostring(zoneid))
      local teamType = TeamUpNewSystem.GetTeamType()
      local peakGameInfo = LogicPeakGameSegmentUtil.GetPeakSegmentFromTeamMemberInfo(memberInfo, zoneid, teamType)
      if peakGameInfo then
      else
        local levelIndex = math.floor(last_season_max_segment / 100) - 6
        if levelIndex == 0 then
          avatar:PlayGodEffect(1)
        elseif levelIndex == 1 then
          avatar:PlayGodEffect(2)
        elseif levelIndex == 2 then
          avatar:PlayGodEffect(3)
        end
      end
    end
  end
end
function TeamAvatarManager.UpdateMyPetAI()
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if myAvatar == nil then
    return
  end
  local myPet = myAvatar:GetPet()
  if myPet == nil then
    return
  end
  myPet:EnableClickRandomAction(true)
end
function TeamAvatarManager.GetPet()
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if myAvatar == nil then
    return
  end
  local myPet = myAvatar:GetPet()
  if myPet == nil then
    return
  end
  return myPet
end
function TeamAvatarManager.GetAllAvatar()
  log(bWriteLog and "TeamAvatarManager.GetAllAvatar")
  return _avatars
end
function TeamAvatarManager.GetMainAvatar()
  return _avatars[tostring(DataMgr.roleData.uid)]
end
function TeamAvatarManager.GetAvatarByUid(uid)
  return _avatars[tostring(uid)]
end
function TeamAvatarManager.GetMainAvatarEquipmentsString()
  local mainAvatar = TeamAvatarManager.GetMainAvatar()
  if mainAvatar == nil then
    return ""
  end
  local equipments = mainAvatar:GetEquipments()
  local str = ""
  for k, equipment in pairs(equipments) do
    str = str .. "|" .. equipment.itemID
  end
  local pet = mainAvatar:GetPet()
  if pet ~= nil then
    str = str .. "|" .. tostring(pet:GetPetType())
  end
  return str
end
function TeamAvatarManager.GetAvatarCount()
  local result = 0
  for gid, avatar in pairs(_avatars) do
    result = result + 1
  end
  return result
end
function TeamAvatarManager.PutoffInvalidEquipments()
  log(bWriteLog and "[TeamAvatarManager] PutoffInvalidEquipment")
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  for gid, avatar in pairs(_avatars) do
    local equipments = avatar:GetEquipments()
    for subtype, equipment in pairs(equipments) do
      if logic_wardrobe_new:IsItemIsolated(equipment.itemID) then
        avatar:PutoffEquipment(equipment.itemID)
        log(bWriteLog and "[TeamAvatarManager] PutoffInvalidEquipment " .. gid .. " itemID " .. equipment.itemID)
      end
    end
  end
end
function TeamAvatarManager.bCanPutOn(AvatarUID, itemID)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return false
  end
  if _IsVaildItemID(itemID) == false then
    return false
  end
  if TeamAvatarManager.DepotShowSettingControl(tostring(AvatarUID), itemID) then
    return false
  end
  log(bWriteLog and "[TeamAvatarManager] PutonEquipment AvatarUID " .. tostring(AvatarUID) .. " itemID " .. tostring(itemID))
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if logic_wardrobe_new:IsItemIsolated(itemID) == true then
    log(bWriteLog and "[TeamAvatarManager] PutonEquipment IsItemIsolated " .. itemID)
    return false
  end
  return true
end
local actionNeedStopTb = {
  [2206015] = 1,
  [2206016] = 1,
  [2206017] = 1,
  [2206018] = 1,
  [12220262] = 1,
  [12220263] = 1,
  [12220371] = 1,
  [12220577] = 1,
  [12220578] = 1
}
function TeamAvatarManager.StopActionWhenChangeClothes()
  local avatar = _avatars[DataMgr.roleData.uid]
  if not avatar then
    return
  end
  TeamAvatarManager.StopActionWhenChangeClothesWithAvatar(avatar)
end
function TeamAvatarManager.StopActionWhenChangeClothesWithAvatar(avatar)
  local pawn = avatar:GetModel()
  if pawn and slua.isValid(pawn) then
    local curAction = pawn:GetCurrentActionID()
    if actionNeedStopTb[curAction] then
      avatar:StopAction()
    end
  end
end
function TeamAvatarManager.PutonEquipment(AvatarUID, itemID, tAvatarCustom, isUse)
  if not TeamAvatarManager.bCanPutOn(AvatarUID, itemID) then
    return
  end
  tAvatarCustom = tAvatarCustom or {}
  local avatar = _avatars[tostring(AvatarUID)]
  log(bWriteLog and "[TeamAvatarManager] PutonEquipment not IsItemIsolated " .. itemID)
  local pawn = avatar:GetModel()
  if pawn and slua.isValid(pawn) then
    local currentActionID = pawn:GetCurrentActionID()
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if LogicXSuit.IsNeedStopActionWhenPutOn(currentActionID) then
      avatar:StopAction()
    end
    if LogicXSuit.needPlayActionMember[AvatarUID] == pawn:GetCurrentActionID() then
      avatar:StopAction()
    end
    TeamAvatarManager.StopActionWhenChangeClothesWithAvatar(avatar)
  end
  local tExtraData = {bIsUse = isUse}
  avatar:PutonEquipment(itemID, tAvatarCustom, tExtraData)
  local ShareSuit = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ShareSuit)
  ShareSuit:RefreshAvatarShareSuit(tonumber(AvatarUID))
end
function TeamAvatarManager.SwitchSex(AvatarUID, sex)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:SwitchSex(sex)
end
function TeamAvatarManager.PutoffEquipment(AvatarUID, itemID)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  if _IsVaildItemID(itemID) == false then
    return
  end
  log(bWriteLog and "[TeamAvatarManager] PutoffEquipment AvatarUID " .. AvatarUID .. " itemID " .. itemID)
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local otherId = multi_state_manager:GetOtherStateClothID(itemID)
  local pawn = avatar:GetModel()
  if pawn then
    local currentActionID = pawn:GetCurrentActionID()
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if LogicXSuit.IsNeedStopActionWhenPutOn(currentActionID) then
      avatar:StopAction()
    end
    if LogicXSuit.IsMatchAction(AvatarUID, pawn:GetCurrentActionID(), itemID) then
      avatar:StopAction()
    end
    TeamAvatarManager.StopActionWhenChangeClothes()
  end
  if otherId and not avatar:HasEquiped(itemID) then
    itemID = otherId
  end
  avatar:PutoffEquipment(itemID)
end
function TeamAvatarManager.PlayAction(AvatarUID, actionID, extraInfo)
  log(bWriteLog and "[TeamAvatarManager] PlayAction AvatarUID " .. AvatarUID)
  log(bWriteLog and "[TeamAvatarManager] PlayAction actionID " .. actionID)
  if not _isShowing then
    log(bWriteLog and "[TeamAvatarManager] PlayAction not show")
    return
  end
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.IsMileStoneEmote(actionID) then
    local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
    extraInfo = LobbyEmoteManager:AddMileStoneExtraInfo(AvatarUID, extraInfo, actionID)
  end
  local isMe = DataMgr.IsMe(tonumber(AvatarUID))
  avatar:PlayAction(actionID, extraInfo, isMe, {bStopDelay = false})
end
function TeamAvatarManager.StopAction(AvatarUID)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:StopAction()
end
function TeamAvatarManager.GetCurrentAction(AvatarUID)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return nil
  end
  local pawn = avatar:GetModel()
  if pawn and slua.isValid(pawn) then
    local currentActionID = pawn:GetCurrentActionID()
    return currentActionID
  end
  return avatar:GetCurActionID()
end
function TeamAvatarManager.GetMontageEmoteTime(CurMontage, UID)
  local avatar = _avatars[tostring(UID)]
  if avatar then
    local AnimIns = avatar:GetModel().Mesh:GetAnimInstance()
    if slua.isValid(AnimIns) then
      local time = AnimIns:Montage_GetPosition(CurMontage)
      if 0.5 < time then
        return time
      end
    end
  end
  return 0.0
end
function TeamAvatarManager.PutoffSubtype(AvatarUID, subtype)
  log(bWriteLog and "[TeamAvatarManager] PutoffSubtype AvatarUID " .. AvatarUID)
  log(bWriteLog and "[TeamAvatarManager] PutoffSubtype subtype " .. subtype)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:PutoffSubtype(subtype)
end
function TeamAvatarManager.PutoffExtraWeapon(AvatarUID)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:PutoffExtraWeapon()
end
function TeamAvatarManager.IsShowing()
  return _isShowing
end
function TeamAvatarManager.ShowAllAvatar(mutex)
  log(bWriteLog and "[TeamAvatarManager] ShowAllAvatar")
  if _mutex ~= nil and _mutex ~= mutex then
    log(bWriteLog and "[TeamAvatarManager] ShowAllAvatar failure, mutex is " .. tostring(mutex) .. ", current mutex is" .. tostring(_mutex))
    return
  end
  _isShowing = true
  for k, v in pairs(_avatars) do
    if TeamAvatarManager.AvatarInShowGroup(v.positionIndex) then
      v:ResetRotation()
      v:ShowAvatar()
    else
      v:HideAvatar()
    end
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SHOW_ALL_AVATAR)
end
function TeamAvatarManager._SetTimerToUpdateAllAvatar()
  local time_ticker = require("common.time_ticker")
  if TeamAvatarManager.UpdateAvatarShowTimer then
    time_ticker.RemoveTimer(TeamAvatarManager.UpdateAvatarShowTimer)
    TeamAvatarManager.UpdateAvatarShowTimer = nil
  end
  TeamAvatarManager.UpdateAvatarShowTimer = time_ticker.AddTimer(5, function()
    TeamAvatarManager._UpdateAllAvatar()
  end)
end
function TeamAvatarManager._UpdateAllAvatar()
  if not _isShowing or not _avatars then
    log(bWriteLog and "TeamAvatarManager._UpdateAllAvatar _isShowing: " .. tostring(_isShowing))
    return
  end
  local table_util = require("common.table_util")
  local TeamMemberCount = table_util.CountTable(_avatars)
  if TeamMemberCount < 5 then
    return
  end
  log(bWriteLog and "TeamAvatarManager._UpdateAllAvatar, TeamMemberCount: " .. tostring(TeamMemberCount))
  for k, v in pairs(_avatars) do
    if TeamAvatarManager.AvatarInShowGroup(v.positionIndex) then
      v:ShowAvatar()
    else
      v:HideAvatar()
    end
  end
end
function TeamAvatarManager.HideAllAvatar(mutex)
  log(bWriteLog and "[TeamAvatarManager] HideAllAvatar")
  if _mutex ~= nil and _mutex ~= mutex then
    log(bWriteLog and "[TeamAvatarManager] HideAllAvatar failure, mutex is " .. tostring(mutex) .. ", current mutex is" .. tostring(_mutex))
    return
  end
  _isShowing = false
  _avatars = _avatars or {}
  for k, v in pairs(_avatars) do
    v:StopAction(nil, true)
    v:HideAvatar()
  end
end
function TeamAvatarManager.CreateAvatarDepotShowSetting(AvatarUID, ShowSetting)
  if not ShowSetting then
    return
  end
  local Setting = {}
  local SuperData = require("common.super_data")
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  Setting.bag = ShowSetting.bag
  Setting.helmet = ShowSetting.helmet
  Setting.hand = ShowSetting.hand
  Setting.weapon = ShowSetting.weapon
  Setting.vehicle = ShowSetting.vehicle
  Setting.idle = ShowSetting.idle
  _avatarDepotShowSettings[AvatarUID] = SuperData.CreateSuperData(Setting)
  if not delegateContainer then
    local delegate_container = require("common.delegate_container")
    delegateContainer = delegate_container()
  end
  delegateContainer:AddDataListener(_avatarDepotShowSettings[AvatarUID], "helmet", function(oldValue, value)
    TeamAvatarManager.ChangeAvatarEquipmentByType(AvatarUID, function(itemID)
      return WardrobeData:IsHelmetItem(itemID)
    end, value, HELMET)
  end)
  delegateContainer:AddDataListener(_avatarDepotShowSettings[AvatarUID], "bag", function(oldValue, value)
    TeamAvatarManager.ChangeAvatarEquipmentByType(AvatarUID, function(itemID)
      return WardrobeData:IsBagItem(itemID)
    end, value, BAG)
  end)
  delegateContainer:AddDataListener(_avatarDepotShowSettings[AvatarUID], "hand", function(oldValue, value)
    TeamAvatarManager.ChangeAvatarEquipmentByType(AvatarUID, function(itemID)
      return WardrobeData:IsGlovesItem(itemID)
    end, value, HAND)
  end)
  delegateContainer:AddDataListener(_avatarDepotShowSettings[AvatarUID], "idle", function(oldValue, value)
    TeamAvatarManager.SetOpenSpeicalIdle(AvatarUID, value)
  end)
end
function TeamAvatarManager.ChangeAvatarEquipmentByType(AvatarUID, TypeFunc, Status, Type)
  log(bWriteLog and "TeamAvatarManager ChangeAvatarEquipmentByType" .. AvatarUID)
  local itemID
  local avatar = _avatars[AvatarUID]
  if not avatar then
    return
  end
  if Status == false then
    local equipments = avatar:GetEquipments()
    for subtype, equipment in pairs(equipments) do
      if TypeFunc(equipment.itemID) then
        avatar:PutoffEquipment(equipment.itemID)
      end
    end
  elseif Status == true then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local memberInfo = TeamUpNewSystem.GetMemberInfo(tonumber(AvatarUID))
    if memberInfo == nil or memberInfo.wear_ext == nil then
      log(bWriteLog and "[aki] ChangeAvatarEquipmentByType memberInfo.wear_ext is nil")
      return
    end
    if Type == BAG then
      itemID = DataMgr.GetEquipmentItemIDByResID(memberInfo.skin_info.bag_level, memberInfo.skin_info.bag_skin)
    elseif Type == HELMET then
      itemID = DataMgr.GetEquipmentItemIDByResID(memberInfo.skin_info.helmet_level, memberInfo.skin_info.helmet_skin)
    elseif Type == HAND then
      itemID = TeamAvatarManager.GetWearExtItemID(AvatarUID, ENUM_AVATAR_SHOW_TYPE.SHOW_POS_GLOVES)
    end
    if TypeFunc(itemID) and not avatar:HasEquiped(itemID) then
      avatar:PutonEquipment(itemID)
    end
  end
end
function TeamAvatarManager.GetWearExtItemID(UID, Type)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local memberInfo = TeamUpNewSystem.GetMemberInfo(tonumber(UID))
  if memberInfo == nil or memberInfo.wear_ext == nil then
    return 0
  end
  if not memberInfo.wear_ext[Type] then
    return 0
  end
  return memberInfo.wear_ext[Type][ENUM_AVATAR_DATA_TYPE.ItemID]
end
function TeamAvatarManager.UpdateAvatarDepotShowSetting(AvatarUID, ShowSetting)
  if AvatarUID == DataMgr.roleData.uid then
    return
  end
  if not ShowSetting then
    return
  end
  for SettingName, Value in pairs(ShowSetting) do
    if _avatarDepotShowSettings[AvatarUID] then
      _avatarDepotShowSettings[AvatarUID][SettingName] = Value
    end
  end
end
function TeamAvatarManager.GetAvatarDepotShowSetting(AvatarUID, Type)
  if not _avatarDepotShowSettings[AvatarUID] then
    _logErrorAvatarNotExisted(AvatarUID)
    return true
  else
    return _avatarDepotShowSettings[AvatarUID][Type]
  end
end
function TeamAvatarManager.DepotShowSettingControl(AvatarUID, itemID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
  local ShowBag, ShowHelmet, ShowGloves
  if AvatarUID == DataMgr.roleData.uid and UIManager.IsUIShow(UIManager.UI_Config.wardrobe) then
    return false
  end
  if AvatarUID == DataMgr.roleData.uid then
    ShowBag = LogicDisplaySetting.ShowBag()
    ShowHelmet = LogicDisplaySetting.ShowHelmet()
    ShowGloves = LogicDisplaySetting.ShowGloves()
  else
    ShowBag = TeamAvatarManager.GetAvatarDepotShowSetting(AvatarUID, "bag")
    ShowHelmet = TeamAvatarManager.GetAvatarDepotShowSetting(AvatarUID, "helmet")
    ShowGloves = TeamAvatarManager.GetAvatarDepotShowSetting(AvatarUID, "hand")
  end
  if WardrobeData:IsBagItem(itemID) and not ShowBag then
    return true
  elseif WardrobeData:IsHelmetItem(itemID) and not ShowHelmet then
    return true
  elseif WardrobeData:IsGlovesItem(itemID) and not ShowGloves then
    return true
  end
end
function TeamAvatarManager.test()
  for k, v in pairs(_avatars) do
    log(bWriteLog and "[TeamAvatarManager] test")
    v:PlayPetAction(50001006)
  end
end
function TeamAvatarManager.OnGameStateChange(eventType, eventID, vars)
  log(bWriteLog and "TeamAvatarManager.OnGameStateChange " .. vars.current .. "  " .. vars.pre)
  if GameStatus.IsInLobbyOrMainCity() then
  elseif vars.current == GameStatus.Login then
    TeamAvatarManager.CreateMySelf = false
  elseif vars.current == GameStatus.Fighting then
    TeamAvatarManager.CreateMySelf = false
  end
end
function TeamAvatarManager.OnTeamPetAction(eventType, eventID, petData)
  local AvatarUID = petData.UID
  local petActionID = petData.PetActionID
  log(bWriteLog and "[TeamAvatarManager] OnTeamPetAction uid " .. AvatarUID .. " petActionID " .. petActionID)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission(true) then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    XMissionAvatarMgr.PlayPetAction(AvatarUID, petActionID)
    return
  end
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:PlayPetAction(petActionID)
end
function TeamAvatarManager.OnTeamPetLevelup(eventType, eventID, petData)
  local AvatarUID = petData.UID
  local exp = petData.ServerInfo.exp
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local petLevel = logic_pet:GetPetLevelByExp(petData.ServerInfo.id, exp)
  log(bWriteLog and "[TeamAvatarManager] OnTeamPetLevelup uid " .. tostring(AvatarUID) .. " level " .. tostring(petLevel))
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:SetPetLevel(petLevel)
  TeamAvatarManager.UpdateMyPetAI()
end
function TeamAvatarManager.OnChangeTeamPet(eventType, eventID, PetData)
  TeamAvatarManager.OnChangeTeamPetImpl(PetData)
end
function TeamAvatarManager.OnChangeTeamPetImpl(PetData)
  if not PetData then
    log(bWriteLog and "TeamAvatarManager.OnChangeTeamPetImpl PetData is nil")
    return
  end
  local uid = PetData.UID
  local petTypeID = PetData.ServerInfo and PetData.ServerInfo.id or 0
  local petExp = PetData.ServerInfo and PetData.ServerInfo.exp or 0
  local petDress = PetData.ServerInfo and PetData.ServerInfo.dress or {}
  log(bWriteLog and "[TeamAvatarManager] OnChangeTeamPetImpl uid " .. tostring(uid) .. " petid " .. tostring(petTypeID) .. " exp " .. tostring(petExp))
  log_tree("[TeamAvatarManager] OnChangeTeamPetImpl petDress ", petDress)
  if petTypeID ~= 0 then
    TeamAvatarManager.CreatePet(uid, PetData)
  else
    TeamAvatarManager.DestroyPet(uid)
  end
  TeamAvatarManager.UpdateMyPetAI()
end
function TeamAvatarManager.TestData()
  local data = {}
  data.UID = DataMgr.roleData.uid
  data.ServerInfo = {id = 1}
  data.PetName = "\230\181\139\232\175\149\229\144\141\229\173\151"
  TeamAvatarManager.OnChangeTeamPetName(1, 1, data)
end
function TeamAvatarManager.OnChangeTeamPetName(eventType, eventID, petData)
  local uid = petData.UID
  local petTypeID = petData.ServerInfo and petData.ServerInfo.id
  local petName = petData.PetName
  log(bWriteLog and "[TeamAvatarManager] OnChangeTeamPetName uid " .. uid .. " petid " .. petTypeID .. " petName " .. petName)
  TeamAvatarManager.SetPetName(uid, petName)
end
function TeamAvatarManager.CreatePet(AvatarUID, PetData)
  local petTypeID = PetData and PetData.ServerInfo and PetData.ServerInfo.id or 0
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if logic_pet:IsPetIDBlocked(petTypeID) then
    log(bWriteLog and "[TeamAvatarManager] CreatePet petTypeID invalid " .. tostring(petTypeID))
    return
  end
  log(bWriteLog and string.format("TeamAvatarManager.CreatePet. AvatarUID=%s, petTypeID=%s PetData=%s", tostring(AvatarUID), tostring(petTypeID), tostring(PetData)))
  local uidStr = tostring(AvatarUID)
  _uid2PetData[uidStr] = PetData
  local avatar = _avatars[uidStr]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  local bSimulate = false
  if uidStr ~= tostring(DataMgr.roleData.uid) then
    bSimulate = true
  end
  avatar:RefreshOrCreatePet(PetData, true, bSimulate)
  TeamAvatarManager.UpdateMyPetAI()
  if uidStr == tostring(DataMgr.roleData.uid) and avatar then
    local pet = avatar:GetPet()
    if pet then
      local petModel = pet:GetModel()
      if slua.isValid(petModel) then
        if slua.isValid(petModel.BP_LobbyPetMoodComponent) then
          petModel.BP_LobbyPetMoodComponent:SetEnable(true)
        end
        if slua.isValid(petModel.LobbyRotateComponent) then
          petModel.LobbyRotateComponent.Press = false
        end
      end
    end
  end
end
function TeamAvatarManager.DestroyPet(AvatarUID)
  if not AvatarUID then
    log(bWriteLog and "[TeamAvatarManager] DestroyPet AvatarUID is nil")
    return
  end
  log(bWriteLog and "[TeamAvatarManager] DestroyPet AvatarUID " .. tostring(AvatarUID))
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  log(bWriteLog and "[TeamAvatarManager] DestroyPet")
  avatar:DestroyPet()
end
function TeamAvatarManager.SetPetName(AvatarUID, petName)
  log(bWriteLog and "[TeamAvatarManager] SetPetName AvatarUID " .. AvatarUID .. "petName " .. petName)
  do return end
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:SetPetName(petName)
end
function TeamAvatarManager.ChangePetEquipment(AvatarUID, itemID)
  itemID = itemID or 0
  itemID = tonumber(itemID)
  log(bWriteLog and "[TeamAvatarManager] ChangePetEquipment AvatarUID " .. AvatarUID .. " itemID " .. itemID)
  local avatar = _avatars[tostring(AvatarUID)]
  if avatar == nil then
    _logErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:PutOnOrPutOff(itemID, true)
end
TeamAvatarManager.PetData = {}
function TeamAvatarManager.SetPetData(uid, petTypeID, petExp)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local PetData = logic_pet:FormatPetData(uid, petTypeID, petExp)
  TeamAvatarManager.PetData[tostring(uid)] = PetData
  TeamAvatarManager.OnChangeTeamPetImpl(PetData)
end
function TeamAvatarManager.ChangeDiyWeaponScheme(uid, scheme)
  local avatar = _avatars[tostring(uid)]
  if avatar == nil then
    _logErrorAvatarNotExisted(uid)
    return
  end
  avatar:ChangeDiyWeaponScheme(scheme)
end
function TeamAvatarManager.OnChangeDiyWeaponScheme(eventType, eventID, uid, weaponId, scheme)
  if GameStatus.IsInLobbyOrMainCity() then
    if weaponId then
      TeamAvatarManager.PutonEquipment(uid, weaponId)
      if scheme then
        TeamAvatarManager.ChangeDiyWeaponScheme(uid, scheme)
      end
    else
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
      if memberInfo and memberInfo.weapon_wear_info then
        TeamAvatarManager.PutonEquipment(uid, memberInfo.weapon_wear_info.weapon_id or 0)
      end
    end
  end
end
function TeamAvatarManager.OnBuyDiyWeaponPlan(eventType, eventID, weaponId, planId, scheme)
  local gunid = 0
  local cfg = CDataTable.GetTableData("WeaponSkinMapping", weaponId)
  if cfg and cfg.WeaponID then
    gunid = cfg.WeaponID
  end
  if DataMgr.Weapon_ID == gunid and DataMgr.Weapon_Diy_PlanID == planId and not DataMgr.Weapon_Diy_Using_Recommend then
    local uid = tostring(DataMgr.roleData.uid)
    TeamAvatarManager.PutonEquipment(uid, weaponId)
    TeamAvatarManager.ChangeDiyWeaponScheme(uid, scheme)
  end
end
function TeamAvatarManager.OnPutOnItem()
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local relicInfo = LogicXSuit.relicInfoList[DataMgr.roleData.uid]
  if relicInfo and relicInfo.status then
    local avatar = TeamAvatarManager.GetMainAvatar()
    if avatar and avatar:HasEquiped(LogicXSuit.needShowRelicID) == false then
      LogicXSuit.OnRelicStatusChange(DataMgr.roleData.uid, LogicXSuit.needShowRelicID, 1)
    end
  end
end
function TeamAvatarManager.OnWearChange(_, _, tChangeWearData)
  local isPutOff = false
  if tChangeWearData.pos > 0 then
    isPutOff = true
  end
  local resID = tChangeWearData.resId
  if resID then
    local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
    local OriginItemID = multi_state_manager:GetOriginClothIDAndState(resID) or resID
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if LogicXSuit.IsXSuit(OriginItemID) then
      LogicXSuit.RefreshSharedRelicInfo()
    end
  end
  local wearInfo = tChangeWearData.wearInfo
  if Client.IsDevelopment() then
    log_tree("[DIYColor] TeamAvatarManager.OnWearChange info: ", {
      uid = tChangeWearData.uid,
      wear_ext = wearInfo
    })
  end
  if wearInfo[5] then
    local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
    logic_suit_dye:SetPlanData(tChangeWearData.uid, resID, wearInfo[5])
  end
  TeamAvatarManager.ChangeAvatarEquipment(tChangeWearData.uid, AvatarData.CreateAvatarCustom(resID, tChangeWearData.wearInfo[2], tChangeWearData.wearInfo[3]), isPutOff)
  EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_REFRESH_RELIC_STATUS)
end
function TeamAvatarManager.OnAvatarChange()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.OnAvatarChange then
    log(bWriteLog and "[edward][logic_team_avatar_manager] TeamAvatarManager.OnAvatarChange is none")
  end
  local changeAvatarInfo = TeamUpNewSystem.changeAvatarInfo
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if changeAvatarInfo.reCreate == false then
    log(bWriteLog and "[edward][logic_team_avatar_manager] TeamAvatarManager.OnAvatarChange hairid: " .. changeAvatarInfo.avatar.hairid)
    TeamAvatarManager.ChangeAvatarEquipment(changeAvatarInfo.uid, AvatarData.CreateAvatarCustom(changeAvatarInfo.avatar.hairid), true)
    if changeAvatarInfo.avatar.beardid then
      if changeAvatarInfo.avatar.beardid == 0 and changeAvatarInfo.oldAvatar.beardid and changeAvatarInfo.oldAvatar.beardid ~= 0 then
        local putBeard = changeAvatarInfo.oldAvatar.beardid
        TeamAvatarManager.ChangeAvatarEquipment(changeAvatarInfo.uid, AvatarData.CreateAvatarCustom(putBeard), false)
      else
        TeamAvatarManager.ChangeAvatarEquipment(changeAvatarInfo.uid, AvatarData.CreateAvatarCustom(changeAvatarInfo.avatar.beardid, changeAvatarInfo.avatar.beardcolor), true)
      end
    end
    local oldAttrInfo = changeAvatarInfo.oldAvatar.attr_info or {}
    local newAttrInfo = changeAvatarInfo.avatar.attr_info or {}
    for key, value in pairs(oldAttrInfo) do
      if not newAttrInfo[key] then
        TeamAvatarManager.ChangeAvatarEquipment(changeAvatarInfo.uid, AvatarData.ConvertToAvatarCustom(value, true), false)
      end
    end
    for key, value in pairs(newAttrInfo) do
      TeamAvatarManager.ChangeAvatarEquipment(changeAvatarInfo.uid, AvatarData.ConvertToAvatarCustom(value, true), true)
    end
    if changeAvatarInfo.needChangeSex then
      TeamAvatarManager.SwitchSex(changeAvatarInfo.uid, changeAvatarInfo.avatar.gamegender)
    end
  elseif changeAvatarInfo.reCreate == true then
    local memberInfo = TeamUpNewSystem.GetMemberInfo(changeAvatarInfo.uid)
    local wearArray = {}
    if memberInfo.wear_ext ~= nil then
      for k, v in pairs(memberInfo.wear_ext) do
        table.insert(wearArray, AvatarData.ConvertToAvatarCustom(v))
      end
    end
    local bagSkinInsId, headShow
    if memberInfo.skin_info then
      bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(memberInfo.skin_info.bag_level, memberInfo.skin_info.bag_skin)
      if memberInfo.skin_info.head_show == 0 or memberInfo.skin_info.head_show == memberInfo.skin_info.helmet_skin then
        headShow = DataMgr.GetEquipmentItemIDByResID(memberInfo.skin_info.helmet_level, memberInfo.skin_info.head_show)
      end
    end
    local playerData = {
      gid = changeAvatarInfo.uid,
      sex = changeAvatarInfo.avatar.gamegender,
      BP_ARRAY_AvatarList = wearArray,
      avatar = changeAvatarInfo.avatar,
      headShow = headShow,
          }
    LobbySceneManager.SetLockLobbyCamera(true)
    LobbyAvatarManager.SpawnPlayer(playerData, false, true)
    LobbyAvatarManager.SpawnPlayer(playerData, true, nil, true)
    LobbySceneManager.SetLockLobbyCamera(false)
    TeamUpNewSystem.OnMemberWeaponChange(changeAvatarInfo.uid)
    if TeamUpNewSystem.GetTeamNum() > 1 then
      local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
      logic_share_bag_team_util:UpdateAllAvatarWithShareBagInfo(changeAvatarInfo.uid, true)
    end
  end
end
function TeamAvatarManager.OnHeadShowChange()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local oldMemberInfo = TeamUpNewSystem.GetMemberInfo(TeamUpNewSystem.headShowChangeInfo.uid)
  if not oldMemberInfo then
    log_warning("[edward][logic_team_avatar_manager] TeamAvatarManager.OnHeadShowChange, oldMemberInfo is none")
    return
  end
  local oldHeadShow = oldMemberInfo.skin_info.head_show
  local oldHelmet = oldMemberInfo.skin_info.helmet_skin
  local oldBagSkin = oldMemberInfo.skin_info.bag_skin
  local oldBagLevel = oldMemberInfo.skin_info.bag_level
  local oldHelmetLevel = oldMemberInfo.skin_info.helmet_level
  TeamUpNewSystem.UpdateMemberHeadShowInfo(TeamUpNewSystem.headShowChangeInfo)
  local newMemberInfo = TeamUpNewSystem.GetMemberInfo(TeamUpNewSystem.headShowChangeInfo.uid)
  local headShowChangeInfo = TeamUpNewSystem.headShowChangeInfo
  log_tree("[tinghaohu]TeamAvatarManager.OnHeadShowChange. headShowChangeInfo", headShowChangeInfo)
  if headShowChangeInfo.param.head_show then
    if oldHelmet == oldHeadShow then
      local resID = DataMgr.GetEquipmentItemIDByResID(oldHelmetLevel, oldHeadShow)
      TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(resID), false)
    end
    if headShowChangeInfo.param.head_show == headShowChangeInfo.param.helmet_skin then
      local resID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.helmet_level, headShowChangeInfo.param.head_show)
      TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(resID), true)
    end
    if headShowChangeInfo.param.head_show == 0 then
      if oldMemberInfo.wear_ext and oldMemberInfo.wear_ext[1] then
        TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(oldMemberInfo.wear_ext[1]), false)
      end
    else
      TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(headShowChangeInfo.param.head_show), true)
    end
  end
  if headShowChangeInfo.param.bag_skin then
    if headShowChangeInfo.param.bag_skin ~= 0 then
      local bagResID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.bag_level, headShowChangeInfo.param.bag_skin)
      if bagResID ~= 0 then
        TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(bagResID), true)
      end
    else
      local bagResID = DataMgr.GetEquipmentItemIDByResID(oldBagLevel, oldBagSkin)
      if bagResID ~= 0 then
        TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(bagResID), false)
      end
    end
  end
  if headShowChangeInfo.param.bag_level then
    local bagResID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.bag_level, newMemberInfo.skin_info.bag_skin)
    TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(bagResID), true)
  end
  if headShowChangeInfo.param.helmet_skin then
    if headShowChangeInfo.param.helmet_skin ~= 0 and newMemberInfo.skin_info.helmet_skin == newMemberInfo.skin_info.head_show then
      local helmetResID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.helmet_level, headShowChangeInfo.param.helmet_skin)
      if helmetResID ~= 0 then
        TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(helmetResID), true)
      end
    else
      local helmetResID = DataMgr.GetEquipmentItemIDByResID(oldHelmetLevel, oldHelmet)
      if helmetResID ~= 0 then
        TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(helmetResID), false)
      end
    end
  end
  if headShowChangeInfo.helmet_level ~= 0 and newMemberInfo.skin_info.helmet_skin == newMemberInfo.skin_info.head_show then
    local resID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.helmet_level, newMemberInfo.skin_info.helmet_skin)
    TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(resID), true)
  end
  if newMemberInfo.bag_pendants then
    for k, v in pairs(newMemberInfo.bag_pendants) do
      TeamAvatarManager.ChangeAvatarEquipment(headShowChangeInfo.uid, AvatarData.CreateAvatarCustom(k), true)
    end
  end
end
function TeamAvatarManager.OnWearPairChange()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local changeWearPair = TeamUpNewSystem.changeWearPair
  local oldMemberInfo = TeamUpNewSystem.GetMemberInfo(changeWearPair.uid)
  if not oldMemberInfo then
    log_warning("[edward][logic_team_avatar_manager] TeamAvatarManager.ChangeWearPair, oldMemberInfo is none")
    return
  end
  if oldMemberInfo.wear_ext then
    for k, v in pairs(oldMemberInfo.wear_ext) do
      if v[1] then
        TeamAvatarManager.ChangeAvatarEquipment(changeWearPair.uid, AvatarData.CreateAvatarCustom(v[1]), false)
      end
    end
  end
  local newWearArray = {}
  if Client.IsDevelopment() then
    log_tree("[DIYColor] TeamAvatarManager.OnWearPairChange info: ", {
      uid = changeWearPair.uid,
      wear_ext = changeWearPair.wear_ext,
      old_wear_ext = oldMemberInfo.wear_ext
    })
  end
  if changeWearPair.wear_ext then
    for k, v in pairs(changeWearPair.wear_ext) do
      if v[5] then
        local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
        logic_suit_dye:SetPlanData(changeWearPair.uid, v[1], v[5])
      end
      table.insert(newWearArray, AvatarData.ConvertToAvatarCustom(v))
    end
  end
  for i, v in ipairs(newWearArray) do
    TeamAvatarManager.ChangeAvatarEquipment(changeWearPair.uid, v, true)
  end
  TeamUpNewSystem.UpdateTeamMemberWear(changeWearPair.uid, changeWearPair.ware, changeWearPair.wear_ext)
  EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_REFRESH_RELIC_STATUS)
end
function TeamAvatarManager.PlayBigEventToLobbyAction()
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  local BP_FromBigEvent = LoadingSystem.GetBigEvent()
  local isLoading = LoadingSystem.IsShowing()
  log(bWriteLog and "PlayBigEventToLobbyAction BP_FromBigEvent = " .. tostring(BP_FromBigEvent) .. " CreateMySelf = " .. tostring(TeamAvatarManager.CreateMySelf) .. " isLoading = " .. tostring(isLoading))
  if BP_FromBigEvent and TeamAvatarManager.CreateMySelf and not isLoading then
    local STExtraGameInstance = import("STExtraGameInstance")
    local gameInstance = STExtraGameInstance.GetInstance()
    local deviceLevel = gameInstance:GetDeviceLevel()
    local delayTime
    if 2 <= deviceLevel then
      delayTime = 1.6
    elseif 1 <= deviceLevel then
      delayTime = 2.2
    else
      delayTime = 2.8
    end
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimer(1, function()
      TeamAvatarManager.HideAllAvatar()
      coroutine.yield(delayTime)
      TeamAvatarManager.PlayAction(tostring(DataMgr.roleData.uid), 12215536)
      coroutine.yield(0.1)
      TeamAvatarManager.ShowAllAvatar()
    end)
    BP_FromBigEvent = false
  end
end
function TeamAvatarManager.SetOpenSpeicalIdle(uid, OpenSpecialIdle)
  log(bWriteLog and "TeamAvatarManager.SetOpenSpeicalIdle uid:" .. uid .. "OpenSpecialIdle" .. tostring(OpenSpecialIdle))
  local avatar = TeamAvatarManager.GetAvatarByUid(tostring(uid))
  if avatar == nil then
    return
  end
  local forceUseDefaultIdel = false
  if OpenSpecialIdle ~= nil then
    forceUseDefaultIdel = not OpenSpecialIdle
  end
  avatar:SetForceUseDefaultIdle(forceUseDefaultIdel)
end
function TeamAvatarManager.OnCameraSwitch(_, _, CameraID)
  local EnablePhotonShadow
  if CameraID == 10001 or CameraID == 10002 or CameraID == 10008 or CameraID == 10160 then
    EnablePhotonShadow = true
  else
    EnablePhotonShadow = false
  end
  for _, pawn in pairs(_avatars) do
    if pawn then
      pawn:EnableCastPhotonShadow(EnablePhotonShadow)
    end
  end
end
function TeamAvatarManager.GetAvatarUIDByModel(model)
  if model then
    for k, v in pairs(_avatars) do
      if v and v:GetModel() == model then
        return k
      end
    end
  end
  return ""
end
function TeamAvatarManager.OnBeginLobbySkinChange()
  TeamAvatarManager.UpdateAvatarPosition()
end
function TeamAvatarManager.OnTeamChange()
  TeamAvatarManager.UpdateAvatarPosition()
end
function TeamAvatarManager.ChangeAvatarEquipment(uid, tAvatarCustom, isPutOn)
  log(bWriteLog and string.format("TeamAvatarManager.ChangeAvatarEquipment(%s,%s, %s)", uid, tAvatarCustom, isPutOn))
  uid = tostring(uid)
  if isPutOn then
    TeamAvatarManager.PutonEquipment(uid, tAvatarCustom.ItemID, tAvatarCustom)
  else
    local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
    local ItemID = AvatarUtil.ConvertUnderWearID(tAvatarCustom.ItemID, tAvatarCustom.ColorID)
    TeamAvatarManager.PutoffEquipment(uid, ItemID)
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_EQUIPMENT)
end
function TeamAvatarManager.CheckHasEquipped(uid, itemID, tAvatarCustom)
  tAvatarCustom = tAvatarCustom or {}
  log(bWriteLog and string.format("TeamAvatarManager.CheckHasEquiped uid = %s, itemID = %s, colorID = %s, patternID = %s", uid, itemID, tostring(tAvatarCustom.ColorID), tostring(tAvatarCustom.PatternID)))
  uid = tostring(uid)
  local avatar = _avatars[tostring(uid)]
  if avatar == nil then
    _logErrorAvatarNotExisted(uid)
    return false
  end
  if _IsVaildItemID(itemID) == false then
    return false
  end
  return avatar:HasEquiped(itemID, tAvatarCustom)
end
function TeamAvatarManager.DisableAllPetTick()
  log(bWriteLog and "  TeamAvatarManager.DestroyAllPet.  ")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local members = TeamUpNewSystem.teamInfo.members
  for uid, v in pairs(members) do
    local avatar = TeamAvatarManager.GetAvatarByUid(uid)
    local pet, petActor
    if avatar then
      pet = avatar:GetPet()
      if pet then
        petActor = pet:GetModel()
      end
    end
    local mesh = petActor and petActor.Mesh
    if mesh then
      log(bWriteLog and "  TeamAvatarManager.DestroyAllPet.  no tick  PetActionTable ")
      mesh:SetComponentTickEnabled(false)
    end
  end
end
function TeamAvatarManager.ResumeAllPetTick()
  log(bWriteLog and "  TeamAvatarManager.ResumeAllPetTick.  ")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local members = TeamUpNewSystem.teamInfo.members
  for uid, v in pairs(members) do
    local avatar = TeamAvatarManager.GetAvatarByUid(uid)
    local pet, petActor
    if avatar then
      pet = avatar:GetPet()
      if pet then
        petActor = pet:GetModel()
        avatar:UpdatePetPos()
      end
    end
    local mesh = petActor and petActor.Mesh
    if mesh then
      log(bWriteLog and "  TeamAvatarManager.DestroyAllPet.  tick  PetActionTable ")
      mesh:SetComponentTickEnabled(true)
    end
  end
end
return TeamAvatarManager