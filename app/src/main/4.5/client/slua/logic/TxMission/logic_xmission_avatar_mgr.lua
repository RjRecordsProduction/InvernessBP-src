local XMissionAvatarMgr = {
  avatars = {},
  bIsShowing = true,
  npcAvatars = {},
  npcAvatarActionTimer = nil
}
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local C_AvatarPosition = {
  {
    -5,
    0,
    89.5
  },
  {
    -110,
    79,
    89.5
  },
  {
    -97,
    -47,
    89.5
  },
  {
    -253,
    -3.7,
    89.5
  }
}
local C_TeamMaxNum = 4
local _LogErrorAvatarNotExisted = function(uid)
  log_warning("[edward][logic_xmission_avatar_mgr] _LogErrorAvatarNotExisted ===========================================")
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] _LogErrorAvatarNotExisted uid = " .. tostring(uid))
end
local _LogErrorNpcNotExisted = function(npcID)
  log_warning("[edward][logic_xmission_avatar_mgr] _LogErrorNpcNotExisted ===========================================")
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] _LogErrorNpcNotExisted npcID = " .. tostring(npcID))
end
local _GetEmptyPosition = function()
  local TableUtil = require("common.table_util")
  local count = TableUtil.CountTable(XMissionAvatarMgr.avatars)
  if count >= C_TeamMaxNum then
    return nil
  end
  local position = C_AvatarPosition[count + 1]
  local result = {
    x = position[1],
    y = position[2],
    z = position[3],
    index = count + 1
  }
  return result
end
local _IsValidItemID = function(itemID)
  if itemID == nil then
    log_warning("[edward][logic_xmission_avatar_mgr] _IsValidItemID ===========================================")
    log(bWriteLog and "[edward][logic_xmission_avatar_mgr] _IsValidItemID, itemID not valid 2:" .. tostring(itemID))
    return false
  end
  if type(itemID) ~= "number" then
    log_warning("[edward][logic_xmission_avatar_mgr] _IsValidItemID ===========================================")
    log(bWriteLog and "[edward][logic_xmission_avatar_mgr] _IsValidItemID, itemID not valid 3:" .. tostring(itemID))
    return false
  end
  if itemID == 0 then
    log_warning("[edward][logic_xmission_avatar_mgr] _IsValidItemID ===========================================")
    log(bWriteLog and "[edward][logic_xmission_avatar_mgr] _IsValidItemID, itemID not valid 1:" .. tostring(itemID))
    return false
  end
  return true
end
function XMissionAvatarMgr.IsShowing()
  return XMissionAvatarMgr.bIsShowing
end
function XMissionAvatarMgr.RefreshAvatars()
  for uid, avatar in pairs(XMissionAvatarMgr.avatars) do
    if not avatar or not slua.isValid(avatar:GetModel()) then
      XMissionAvatarMgr.avatars[uid] = nil
    end
  end
end
function XMissionAvatarMgr.CreateAvatar(playerData)
  log(bWriteLog and "XMissionAvatarMgr.CreateAvatar")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  XMissionAvatarMgr.RefreshAvatars()
  local showPosition = _GetEmptyPosition()
  if not showPosition then
    log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.CreateAvatar position is full... not create")
    return
  end
  local uid = tostring(playerData.gid)
  if XMissionAvatarMgr.avatars[uid] then
    log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.CreateAvatar avatar is exist ... not create")
    return
  end
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  local modelSex = AvatarCommon.DataSexToModelSex(playerData.sex)
  local _avatarData = {
    gamegender = modelSex,
    headid = playerData.headId
  }
  local avatar = MultipleAvatarManager.CreateMultipleAvatar(_avatarData, showPosition)
  avatar:SetPosition(showPosition.x, showPosition.y, showPosition.z)
  avatar:SetSceneType(LobbyAvatarManager.Enum_SceneType.LOBBY_PURE)
  avatar.positionIndex = showPosition.index
  XMissionAvatarMgr.avatars[uid] = avatar
  local pawn = avatar:GetModel()
  if pawn and slua.isValid(pawn) then
    pawn:SetPlayerUID(uid)
    local avatarLevel = TeamAvatarManager.GetAvatarLevel(tonumber(uid) ~= tonumber(DataMgr.roleData.uid))
    if 1 <= avatarLevel and avatarLevel <= 3 then
      pawn:SetAvatarLevel(avatarLevel)
    else
      assert(false, "XMissionAvatarMgr.CreateAvatar false")
    end
  end
  avatar:EnableHatHelmetMutex(false)
  avatar:EnableLobbyShowItem(false)
  XMissionAvatarMgr.PutOnEquipment(uid, {
    skinID = playerData.headShow
  }, {
    ItemID = playerData.headShow
  })
  for i, v in ipairs(playerData.BP_ARRAY_AvatarList) do
    local wearInfo = {
      skinID = v.ItemID
    }
    XMissionAvatarMgr.PutOnEquipment(uid, wearInfo, v)
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local bNeed, wearID = LogicXSuit.CheckNeedPutOnRelic(uid)
  if bNeed then
    XMissionAvatarMgr.PutOnEquipment(uid, {skinID = wearID})
  end
  if not XMissionAvatarMgr.bIsShowing then
    avatar:HideAvatar()
  end
  return avatar
end
function XMissionAvatarMgr.GetMainAvatar()
  return XMissionAvatarMgr.avatars[tostring(DataMgr.roleData.uid)]
end
function XMissionAvatarMgr.GetAvatarByUID(uid)
  if not uid then
    return nil
  end
  return XMissionAvatarMgr.avatars[tostring(uid)]
end
function XMissionAvatarMgr.GetAvatarList()
  return XMissionAvatarMgr.avatars
end
function XMissionAvatarMgr.DestroyAvatar(playerData)
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.DestroyAvatar")
  local uid = tostring(playerData.gid)
  local avatar = XMissionAvatarMgr.avatars[uid]
  if avatar == nil then
    _LogErrorAvatarNotExisted(uid)
    return
  end
  avatar:Destroy()
  XMissionAvatarMgr.avatars[uid] = nil
  XMissionAvatarMgr:UpdateAvatarPosition()
end
function XMissionAvatarMgr.DestroyAllAvatar()
  log(bWriteLog and "[logic_xmission_avatar_mgr] XMissionAvatarMgr.DestroyAllAvatar")
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    v:Destroy()
  end
  XMissionAvatarMgr.avatars = {}
  for k, v in pairs(XMissionAvatarMgr.npcAvatars) do
    v:Destroy()
  end
  XMissionAvatarMgr.npcAvatars = {}
  if XMissionAvatarMgr.npcAvatarActionTimer then
    local timer_ticker = require("common.time_ticker")
    timer_ticker.RemoveTimer(XMissionAvatarMgr.npcAvatarActionTimer)
  end
  XMissionAvatarMgr.npcAvatarActionTimer = nil
end
function XMissionAvatarMgr.GetAvatarPosition(index)
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    if v.positionIndex == index then
      return C_AvatarPosition[index]
    end
  end
  return nil
end
function XMissionAvatarMgr.UpdateAvatarPosition()
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    if v.positionIndex == 3 and not XMissionAvatarMgr.GetAvatarPosition(v.positionIndex - 1) then
      v.positionIndex = v.positionIndex - 1
      local position = C_AvatarPosition[v.positionIndex]
      v:SetShowPosition(position[1], position[2], position[3])
    end
  end
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    if v.positionIndex == 4 and not XMissionAvatarMgr.GetAvatarPosition(v.positionIndex - 1) then
      v.positionIndex = v.positionIndex - 1
      local position = C_AvatarPosition[v.positionIndex]
      v:SetShowPosition(position[1], position[2], position[3])
    end
  end
end
function XMissionAvatarMgr.ShowAllAvatar()
  XMissionAvatarMgr.bIsShowing = true
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    v:ShowAvatar()
  end
  for k, v in pairs(XMissionAvatarMgr.npcAvatars) do
    v:ShowAvatar()
  end
end
function XMissionAvatarMgr.HideAllAvatar()
  log(bWriteLog and "XMissionAvatarMgr.HideAllAvatar")
  XMissionAvatarMgr.bIsShowing = false
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    v:HideAvatar()
  end
  for k, v in pairs(XMissionAvatarMgr.npcAvatars) do
    v:HideAvatar()
  end
end
function XMissionAvatarMgr.ShowMainAvatar()
  local avatar = XMissionAvatarMgr.GetMainAvatar()
  if not avatar then
    return
  end
  avatar:ShowAvatar()
end
function XMissionAvatarMgr.HideMainAvatar()
  local avatar = XMissionAvatarMgr.GetMainAvatar()
  if not avatar then
    return
  end
  avatar:HideAvatar()
end
function XMissionAvatarMgr.ShowTeamAvatar()
  XMissionAvatarMgr.bIsShowing = true
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    v:ShowAvatar()
  end
end
function XMissionAvatarMgr.HideTeamAvatar()
  log(bWriteLog and "XMissionAvatarMgr.HideTeamAvatar")
  XMissionAvatarMgr.bIsShowing = false
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    if tonumber(k) ~= tonumber(DataMgr.roleData.uid) then
      v:HideAvatar()
    end
  end
end
function XMissionAvatarMgr.DestroyTeamAvatar()
  log(bWriteLog and "XMissionAvatarMgr.DestroyTeamAvatar")
  XMissionAvatarMgr.bIsShowing = false
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    if tonumber(k) ~= tonumber(DataMgr.roleData.uid) then
      v:Destroy()
      XMissionAvatarMgr.avatars[k] = nil
    end
  end
end
function XMissionAvatarMgr.PutOnEquipment(avatarUID, wearInfo, tAvatarCustom)
  tAvatarCustom = tAvatarCustom or {}
  local skinID = wearInfo.skinID or wearInfo.itemID
  skinID = tonumber(skinID) or 0
  if not _IsValidItemID(skinID) then
    return
  end
  local avatar = XMissionAvatarMgr.avatars[tostring(avatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(avatarUID)
    return
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.ClientBasicCfg and PufferDownloader.PufferJsonDownloadReturn then
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {skinID})
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {skinID})
    if state ~= ENUM_DownloadState.Done and wearInfo.itemID and wearInfo.itemID > 0 then
      avatar:PutonEquipment(wearInfo.itemID, tAvatarCustom)
      return
    end
  end
  avatar:PutonEquipment(skinID, tAvatarCustom)
end
function XMissionAvatarMgr.PutOffEquipment(avatarUID, itemID)
  if not _IsValidItemID(itemID) then
    return
  end
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.PutOffEquipment avatarUID " .. avatarUID .. " itemID " .. itemID)
  local avatar = XMissionAvatarMgr.avatars[tostring(avatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(avatarUID)
    return
  end
  avatar:PutoffEquipment(itemID)
end
function XMissionAvatarMgr.PutOffBySlot(avatarUID, Slot)
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.PutOffBySlot avatarUID " .. avatarUID)
  local avatar = XMissionAvatarMgr.avatars[tostring(avatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(avatarUID)
    return
  end
  if slua.isValid(avatar:GetModel()) then
    avatar:GetModel():PutOffEquipmentBySlot(Slot)
  end
end
function XMissionAvatarMgr.GetUidByPosition(pos)
  for k, v in pairs(XMissionAvatarMgr.avatars) do
    if v.positionIndex == pos then
      return k
    end
  end
  return nil
end
function XMissionAvatarMgr.EquipWeaponBySlotID(avatarUID, weaponWearInfo, slotID, autoUse)
  local avatar = XMissionAvatarMgr.avatars[tostring(avatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(avatarUID)
    return
  end
  local weaponSkinID = weaponWearInfo.skinID > 0 and weaponWearInfo.skinID or weaponWearInfo.itemID
  weaponSkinID = tonumber(weaponSkinID)
  if not _IsValidItemID(weaponSkinID) then
    avatar:UnEquipWeaponBySlotID(weaponSkinID, slotID)
    return
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.ClientBasicCfg and PufferDownloader.PufferJsonDownloadReturn then
    local callback = function()
      log(bWriteLog and "XMissionAvatarMgr.EquipWeaponBySlotID callback execute")
      local XMWeaponIDMap = CDataTable.GetTableData("XMWeaponIDMap", weaponSkinID)
      if XMWeaponIDMap then
        local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
        if weapon_diy_system:IsDIYWeapon(XMWeaponIDMap.WeaponID) then
          return
        end
      end
      XMissionAvatarMgr.EquipWeaponBySlotID(avatarUID, weaponWearInfo, slotID, autoUse)
    end
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {weaponSkinID})
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {weaponSkinID}, nil, callback)
    if state ~= ENUM_DownloadState.Done then
      avatar:EquipWeaponBySlotID(weaponWearInfo.itemID, slotID, autoUse)
      return
    end
  end
  avatar:EquipWeaponBySlotID(weaponSkinID, slotID, autoUse)
end
function XMissionAvatarMgr.PlayAction(avatarUID, actionID, extraInfo)
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.avatarUID " .. avatarUID)
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.actionID " .. actionID)
  local avatar = XMissionAvatarMgr.avatars[tostring(avatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(avatarUID)
    return false
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  if tostring(avatarUID) == DataMgr.roleData.uid then
    if LogicXSuit.IsInviteAction(actionID) then
      local hasEquip, levelEnough = LogicXSuit.CheckHasEquipXSuitByAction(actionID)
      if not hasEquip then
        ShowNotice(16153)
        return false
      end
      if not levelEnough then
        ShowNotice(29026)
        return false
      end
    else
      local wordId = golden_suit_module:EmoteNeedClothesWithWord(actionID)
      if wordId then
        ShowNotice(wordId)
        return
      end
      local wordId = golden_suit_module:EmoteNeedClothesAllWithWord(actionID)
      if wordId then
        ShowNotice(wordId)
        return false
      end
    end
  end
  local isBattleEmotion, period = LogicXSuit.IsBattleEmotion(actionID)
  if isBattleEmotion then
    local itemID = LogicXSuit.GetItemIDByLevel(period, 5)
    if itemID then
      local UIUtil = require("client.common.ui_util")
      local itemCfg = UIUtil.GetItemCfg(itemID)
      ShowNotice(GlobalData.GetLocalizeStringWithNum(11079, 0, itemCfg and itemCfg.ItemName or ""))
    end
    return false
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.IsMileStoneEmote(actionID) then
    local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
    extraInfo = LobbyEmoteManager:AddMileStoneExtraInfo(avatarUID, extraInfo, actionID)
  end
  avatar:PlayAction(actionID, extraInfo)
  return true
end
function XMissionAvatarMgr.StopAction(avatarUID)
  local avatar = XMissionAvatarMgr.avatars[tostring(avatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(avatarUID)
    return
  end
  avatar:StopAction()
end
function XMissionAvatarMgr.ChangeDiyWeaponScheme(avatarUID, scheme, slotID)
  local avatar = XMissionAvatarMgr.avatars[tostring(avatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(avatarUID)
    return
  end
  avatar:ChangeDiyWeaponSchemeBySocketID(scheme, slotID)
end
function XMissionAvatarMgr.CreateNpcAvatar(config, playAction)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  if not config or not config.ID then
    return
  end
  local npcID = tostring(config.ID)
  if XMissionAvatarMgr.npcAvatars[npcID] then
    return
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  local sex = config.Gender ~= 1 and config.Gender ~= 2 and LobbyAvatarManager.Enum_Sex.Male or config.Gender
  local StringUtil = require("common.string_util")
  local _pos = StringUtil.Split(config.PosInScene, ";")
  local showPosition = {
    x = tonumber(_pos[1]),
    y = tonumber(_pos[2]),
    z = tonumber(_pos[3])
  }
  local _avatarData = {
    gamegender = sex,
    headid = config.Head
  }
  local avatar = MultipleAvatarManager.CreateMultipleAvatar(_avatarData, showPosition)
  avatar:SetPosition(showPosition.x, showPosition.y, showPosition.z)
  avatar:SetSceneType(LobbyAvatarManager.Enum_SceneType.DEFAULT)
  avatar:SetCanRotate(false)
  if config.RotationInScene then
    local _rotation = StringUtil.Split(config.RotationInScene, ";")
    local showRotation = {
      x = tonumber(_rotation[1]),
      y = tonumber(_rotation[2]),
      z = tonumber(_rotation[3])
    }
    avatar:SetRotation(showRotation.x, showRotation.y, showRotation.z)
  end
  XMissionAvatarMgr.npcAvatars[npcID] = avatar
  local pawn = avatar:GetModel()
  if pawn and slua.isValid(pawn) then
    local avatarLevel = TeamAvatarManager.GetAvatarLevel(false)
    if 1 <= avatarLevel and avatarLevel <= 3 then
      pawn:SetAvatarLevel(avatarLevel)
    else
      assert(false, "XMissionAvatarMgr.CreateNpcAvatar false")
    end
  end
  XMissionAvatarMgr.PutOnNpcEquipment(npcID, config.Hair)
  local _beardList = StringUtil.Split(config.Beard or "", "|")
  if 0 < #_beardList then
    XMissionAvatarMgr.PutOnNpcEquipment(npcID, tonumber(_beardList[1]), tonumber(_beardList[2]) or 0)
  end
  local _suitList = StringUtil.Split(config.Suit, "|")
  for _, redID in ipairs(_suitList) do
    XMissionAvatarMgr.PutOnNpcEquipment(npcID, tonumber(redID))
  end
  avatar.initActionID = tonumber(config.ActionInScene) or 0
  if 0 < avatar.initActionID and playAction then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimer(0.5, function()
      avatar:PlayAction(avatar.initActionID)
    end)
  end
  return avatar
end
function XMissionAvatarMgr.GetNpcAvatar(id)
  id = tostring(id)
  if not id then
    return nil
  end
  local avatar = XMissionAvatarMgr.npcAvatars[id]
  if not avatar then
    _LogErrorNpcNotExisted(id)
  end
  return avatar
end
function XMissionAvatarMgr.PutOnNpcEquipment(avatarUID, itemID, colorID, patternID)
  if not _IsValidItemID(itemID) then
    return
  end
  local avatar = XMissionAvatarMgr.GetNpcAvatar(avatarUID)
  if avatar == nil then
    return
  end
  local tAvatarCustom = AvatarData.CreateAvatarCustom(itemID, colorID, patternID)
  avatar:PutonEquipment(itemID, tAvatarCustom)
end
function XMissionAvatarMgr.PutOffNpcEquipment(avatarUID, itemID)
  if not _IsValidItemID(itemID) then
    return
  end
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.PutOffEquipment avatarUID " .. avatarUID .. " itemID " .. itemID)
  local avatar = XMissionAvatarMgr.GetNpcAvatar(avatarUID)
  if avatar == nil then
    return
  end
  avatar:PutoffEquipment(itemID)
end
function XMissionAvatarMgr.PlayNpcAction(npcID, actionID)
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.PlayNpcAction " .. npcID)
  log(bWriteLog and "[edward][logic_xmission_avatar_mgr] XMissionAvatarMgr.PlayNpcAction " .. actionID)
  local avatar = XMissionAvatarMgr.GetNpcAvatar(npcID)
  if not avatar then
    return
  end
  if UIManager.GetUI(UIManager.UI_Config.xmission_npc_conversation) then
    local cfg = CDataTable.GetTableData("NPCConfig", npcID)
    if not cfg then
      return
    end
    local string_util = require("common.string_util")
    local posList = string_util.Split(cfg.SpeakPosInScene, ";")
    if posList and #posList == 3 then
      avatar:SetPosition(tonumber(posList[1]), tonumber(posList[2]), tonumber(posList[3]))
    end
  end
  if actionID == 0 then
    avatar:PlayAction(avatar.initActionID)
  else
    avatar:PlayAction(actionID)
  end
end
function XMissionAvatarMgr.StopNpcAction(npcID)
  local avatar = XMissionAvatarMgr.GetNpcAvatar(npcID)
  if not avatar then
    return
  end
  avatar:PlayAction(avatar.initActionID)
end
local C_LobbyNpcID = 1003
function XMissionAvatarMgr.GetLobbyNpcAvatar()
  local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
  return XMissionAvatarMgr.npcAvatars[tostring(XMissionNpcSystem.GetLobbyNpcID(C_LobbyNpcID))]
end
function XMissionAvatarMgr.CreatePet(AvatarUID, PetData)
  log(bWriteLog and string.format("[XMissionAvatarMgr] CreatePet. AvatarUID=%s, PetID=%s", tostring(AvatarUID), tostring(PetData and PetData.ServerInfo and PetData.ServerInfo.id)))
  local avatar = XMissionAvatarMgr.avatars[tostring(AvatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(AvatarUID)
    return
  end
  local bSimulate = false
  if tostring(AvatarUID) ~= tostring(DataMgr.roleData.uid) then
    bSimulate = true
  end
  avatar:RefreshOrCreatePet(PetData, true, bSimulate)
  XMissionAvatarMgr.UpdateMyPetAI()
  if tostring(AvatarUID) == tostring(DataMgr.roleData.uid) and avatar then
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
function XMissionAvatarMgr.DestroyPet(AvatarUID)
  log(bWriteLog and "[XMissionAvatarMgr] DestroyPet AvatarUID " .. AvatarUID)
  local avatar = XMissionAvatarMgr.avatars[tostring(AvatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(AvatarUID)
    return
  end
  log(bWriteLog and "[XMissionAvatarMgr] DestroyPet")
  avatar:DestroyPet()
end
function XMissionAvatarMgr.UpdateMyPetAI()
  local myAvatar = XMissionAvatarMgr.GetMainAvatar()
  if myAvatar == nil then
    return
  end
  local myPet = myAvatar:GetPet()
  if myPet == nil then
    return
  end
  myPet:EnableClickRandomAction(true)
end
function XMissionAvatarMgr.SetPetName(AvatarUID, petName)
  log(bWriteLog and "[XMissionAvatarMgr] SetPetName AvatarUID " .. AvatarUID .. "petName " .. petName)
  do return end
  local avatar = XMissionAvatarMgr.avatars[tostring(AvatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:SetPetName(petName)
end
function XMissionAvatarMgr.PlayPetAction(AvatarUID, petActionID)
  local avatar = XMissionAvatarMgr.avatars[tostring(AvatarUID)]
  if avatar == nil then
    _LogErrorAvatarNotExisted(AvatarUID)
    return
  end
  avatar:PlayPetAction(petActionID)
end
return XMissionAvatarMgr