local LobbyAvatar = {
  Const = {
    DefaultPosition = {
      x = 0,
      y = 0,
      z = 0
    },
    DefaultShowPosition = {
      x = 0,
      y = 0,
      z = 0
    },
    DefaultPetBasePosition = {
      x = 50,
      y = 0,
      z = -91
    },
    DefaultPetBaseRotation = {
      x = 0,
      y = 0,
      z = 90
    },
    DefaultPawnScaleValue = 1,
    DefaultPawnCapsuleSize = {height = 88, radius = 34},
    DefaultRecyclePawnPosition = {
      x = 1000,
      y = 1000,
      z = 100000
    },
    PawnContainerClassPath = "client.slua.logic.lobby.Left.lobby_pawn_container",
    LOG_TYPE = {
      DEFAULT = 1,
      WARNING = 2,
      ERROR = 3,
      TREE = 4
    },
    EffectType = {
      None = 0,
      GlodenSuit = 1,
      XSuit = 2
    },
    NotShowBaseWeaponSkins = {
      [1108001062] = true,
      [1108001063] = true,
      [1108001064] = true
    },
    AdditionEffectEmote = 22010046
  }
}
local WEAPON_STANDBY_ACTION_TIRGGER_ID = 12219414
local _GetSlotByItemID = function(ItemID)
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
function LobbyAvatar:_GetDisplayItemID(itemID)
  local displayItemID = itemID
  if self._enableLobbyShowItem == false then
    return displayItemID
  end
  local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", itemID)
  if itemMappingCfg ~= nil then
    displayItemID = itemMappingCfg.LobbyShowItemID
  end
  return displayItemID
end
function LobbyAvatar:_GetReplaceItemID(itemID)
  local CharacterAvatarComp = self:GetModelAvatarComp()
  if not slua.isValid(CharacterAvatarComp) or not slua.isValid(CharacterAvatarComp.LogicSlotDesc) then
    return itemID
  end
  local SlotDesc = CharacterAvatarComp.LogicSlotDesc
  local ActualUsedItemID = itemID
  local LogicGlider = require("client.logic.glide.logic_glider")
  if LogicGlider.IsMultiStateGliderBaseState(itemID) and LogicGlider.IsWearDependentItem(itemID, SlotDesc) then
    ActualUsedItemID = LogicGlider.GetSpecialGliderID(itemID)
  end
  return ActualUsedItemID
end
function LobbyAvatar:ctor(_, sex, headId, avatarData, extraData)
  log(bWriteLog and string.format("LobbyAvatar:ctor(%s, %s, %s)", _, sex, headId))
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  self._sex = sex or LobbyAvatarManager.Enum_Sex.Male
  self._headId = headId or LobbyAvatarManager.Enum_DefaultSetID.Head
  local poolSize = extraData and extraData.poolSize or 0
  self._avatarID = LobbyAvatarManager.CreateAvatar(self._sex, self._headId, poolSize)
  local TableUtil = require("common.table_util")
  self._position = TableUtil.CopyTable(LobbyAvatar.Const.DefaultPosition)
  self._showPosition = TableUtil.CopyTable(LobbyAvatar.Const.DefaultShowPosition)
  self._enableLobbyShowItem = true
  self._enableHatHelmetMutex = true
  self._preActionID = 0
  self._pet = nil
  self._petBasePosition = TableUtil.CopyTable(LobbyAvatar.Const.DefaultPetBasePosition)
  self._petBaseRotation = TableUtil.CopyTable(LobbyAvatar.Const.DefaultPetBaseRotation)
  self._lastTakeOnEquipments = {}
  self._lastTakeoffEquipments = {}
  self._checkTakeOff = false
  self._tryPutOn = {}
  self.EmoteEquipmentMap = {}
  self.EmoteAvatarCustomMap = {}
  self.PlayingChangeActionMap = {}
  self.HigLevelClothEffectComp = nil
  self.EffectType = 0
  self._SyncEmote = 0
  self._  self.IsPlayWeaponShow = nil
  self.CanPlaySwitchWeapon = false
  self._hideFlag = 0
  self._sAnimSeqPath = nil
  self._bIsAutoDownloadControlled = false
  self:_InitPawn()
  self:SetAvatarSync(false)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnDownloadFinish, self)
  self:AddCommonEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, self.OnCameraSwitch, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_CAMERA_SHOWHIDE, self.OnLobbyCameraShowOrHide, self)
  self:AddCommonEvent(EVENTTYPE_WEAPON_PENDANT, EVENTID_WEAPON_PENDANT_DATA_UPDATE, self.OnWeaponPendantChange, self)
end
function LobbyAvatar:_InitPawn()
  log(bWriteLog and "LobbyAvatar:_InitPawn self._avatarID = " .. tostring(self._avatarID))
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    self.StartTime = TimeUtil.GetMicroseconds()
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if self._headId ~= 0 then
    local bDownloaded = self:HandleDownload(self._headId, nil, nil, true)
    if not bDownloaded then
      self._headId = LobbyAvatarManager.Enum_DefaultSetID.Head
    end
  else
    self._headId = LobbyAvatarManager.Enum_DefaultSetID.Head
  end
  if self._avatarData and self._avatarData.avatarLevel then
    local AvatarLevel = self._avatarData.avatarLevel
    if 1 <= AvatarLevel and AvatarLevel <= 3 then
      local operateAvatar = self:GetModel()
      if slua.isValid(operateAvatar) then
        log(bWriteLog and "LobbyAvatar:_InitPawn() avatarLevel = " .. tostring(self._avatarData.avatarLevel))
        operateAvatar:SetAvatarLevel(AvatarLevel)
      end
    end
  end
  self:_RealDoSwitchSexAndHeadAndHair(0)
  local LobbyPawnPool = require("client.logic.avatar.lobby_pawn_pool")
  if LobbyPawnPool.IsSwitchOn() then
    self:EnableCastPhotonShadow(true)
    self:_SetLocation(0, 0, 0)
  end
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log_error("[LobbyAvatar] Actor is nil!")
  else
    self:AddControlEvent(operateAvatar, "EmoteMontageFinishedEvent", self.OnEndActionHandle, self)
    operateAvatar:SetConflictRuleEnable(true)
  end
  self:HandleBattleDownload()
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    local EndTime = TimeUtil.GetMicroseconds()
    log(bWriteLog and string.format("TimeTracer LobbyAvatar:_InitPawn bSync=true Pool=false totalTime: [%.3fms]", (EndTime - self.StartTime) / 1000))
  end
end
function LobbyAvatar:_OnRecyclePawn()
  log(bWriteLog and "LobbyAvatar:_OnRecyclePawn() self._avatarID = " .. tostring(self._avatarID))
  local LobbyPawnPool = require("client.logic.avatar.lobby_pawn_pool")
  if not LobbyPawnPool.IsSwitchOn() then
    return
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local lac = LobbyAvatar.Const
  local e = LobbyAvatar.Const.DefaultRecyclePawnPosition
  self:ClearEquipments()
  self:SetAvatarLevel(1)
  self:EnableCastPhotonShadow(false)
  self:_SetLocation(e.x, e.y, e.z)
  self:RestoreCharacterAvatarComp()
  self:SetPlayerUID("")
  self:SetNeedLookAtCamera(false)
  self:SetScale(lac.DefaultPawnScaleValue)
  self:SetActorScale3D(lac.DefaultPawnScaleValue)
  self:ClearFriendPoseData()
  self:SetCanRotate(true)
  self:EnablePlayCameraAnim(false)
  self:SetForceUseDefaultIdle(false)
  self:StopGodEffect()
  self:ClearTeamupAvatarNotice()
  self:DestoryHighLevelClothEffect()
  self:PauseAnim(false)
  self:SetCapsuleHalfHeight(lac.DefaultPawnCapsuleSize.height)
  self:SetCapsuleRadius(lac.DefaultPawnCapsuleSize.radius)
  log(bWriteLog and "LobbyAvatar:_OnRecyclePawn. SetRotation")
  self:SetRotation(0, 0, 0)
  self:SetSceneType(LobbyAvatarManager.Enum_SceneType.DEFAULT)
  self:SetSceneType2(LobbyAvatarManager.Enum_SceneType2.DEFAULT)
  self:SetIsMVPMotion(false)
  local operateAvatar = self:GetModel()
  if slua.isValid(operateAvatar) then
    operateAvatar:SetAnimIgnoreWeaponHide(false)
  end
end
function LobbyAvatar:RestoreCharacterAvatarComp()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  if operateAvatar.CharacterAvatarComp2_BP then
    log(bWriteLog and "LobbyAvatar:RestoreCharacterAvatarComp")
    operateAvatar.CharacterAvatarComp2_BP:ResetData()
    operateAvatar.CharacterAvatarComp2_BP:ClearAllAvatarHandlerFromPool()
  end
end
function LobbyAvatar:CreateMyPetIfNot(uid, petData)
  log(bWriteLog and "LobbyAvatar:CreateMyPetIfNot.  " .. tostring(uid))
  if self._pet then
    return
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.CreatePet(uid, petData)
end
function LobbyAvatar:Destroy()
  log_shipping_client("LobbyAvatar.Destroy _avatarID:" .. tostring(self._avatarID))
  self:StopAction(nil, true)
  if self._pet then
    self._pet:Destroy()
    self._pet = nil
  end
  self:ClearHideFlag()
  self:SetCanPlaySwitchWeapon(false)
  self:StopTeamupEffect()
  self:DestoryHighLevelClothEffect()
  self:SetPoseInCollectionHall()
  local operateAvatar = self:GetModel()
  if slua.isValid(operateAvatar) then
    if operateAvatar.SetLobbyPawnTickInterval then
      operateAvatar:SetLobbyPawnTickInterval(0)
    end
    self:SetAvatarSync(false)
    self:_OnRecyclePawn()
    local LobbyPawnPool = require("client.logic.avatar.lobby_pawn_pool")
    LobbyPawnPool.Release(operateAvatar)
  end
  self:Dispose()
  if self._avatarID then
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.playerList[self._avatarID] = nil
  end
end
function LobbyAvatar:_PutOnReadyItem(readyItemId)
  log(bWriteLog and string.format("LobbyAvatar:_PutOnReadyItem(%s) self._avatarID = %s", readyItemId, tostring(self._avatarID)))
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if not weapon_diy_system:IsDIYWeapon(readyItemId) then
    self:PutonEquipment(readyItemId, self._tryPutOn[readyItemId].tAvatarCustom, self._tryPutOn[readyItemId].extraData)
    local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
    Lobby_Main_City.ReloadAllEquippedAvatar(readyItemId, true)
    local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
    local bIsWeapon = ModelDisplayTypeHelper.IsWeaponById(readyItemId)
    if bIsWeapon then
      local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
      local operateAvatar = self:GetModel()
      if slua.isValid(operateAvatar) then
        local UID = operateAvatar:GetPlayerUID()
        local pendantId = logic_weapon_pendant:GetWeaponPendantBySkinID(UID, readyItemId)
        if pendantId and pendantId ~= 0 then
          self:OnWeaponPendantChange(nil, nil, UID, logic_weapon_pendant:GetGroupIDBySkinID(readyItemId))
        end
      end
    end
    if self._checkTakeOff then
      log(bWriteLog and "LobbyAvatar:_PutOnReadyItem, ProcessTakeOff")
      local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
      logic_wardrobe_avatar:ProcessTakeOff()
    end
    return
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  for uid, weaponInfo in pairs(TeamAvatarManager.TryEquipWeapon) do
    for k, v in pairs(weaponInfo) do
      if v.weapon_wear_info.skinId == readyItemId then
        local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
        LobbyAvatarManager.EquipWeapon(uid, v.weapon_wear_info, v.reason, v.isUse)
        weaponInfo[k] = nil
        break
      end
    end
  end
end
function LobbyAvatar:UpdateTryPutOnList(readyItemId, pakName)
  log(bWriteLog and "LobbyAvatar:UpdateTryPutOnList readyItemId = " .. tostring(readyItemId) .. "pakName = " .. tostring(pakName) .. "  self._avatarID = " .. tostring(self._avatarID))
  if not next(self._tryPutOn) then
    return
  end
  log_tree("LobbyAvatar:UpdateTryPutOnList ", self._tryPutOn)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if self._tryPutOn then
    for itemID, val in pairs(self._tryPutOn) do
      if self._tryPutOn[itemID] then
        if readyItemId == itemID then
          val.paks = nil
        elseif val.paks then
          for i = #val.paks, 1, -1 do
            if val.paks[i] == pakName then
              table.remove(val.paks, i)
            end
          end
          if next(val.paks) == nil then
            val.paks = nil
          end
        end
        if val.paks == nil and PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemID}) == PufferConst.ENUM_DownloadState.Done then
          self:_PutOnReadyItem(itemID)
        end
      end
    end
  end
  if self._checkTakeOff then
    self:MarkForCheckTakeoff()
  end
end
function LobbyAvatar:OnDownloadFinish(_, _, eventData)
  if not eventData then
    return
  end
  local itemID = eventData.itemID
  log(bWriteLog and string.format("LobbyAvatar:OnDownloadFinish itemID:%s", tostring(itemID)))
  local pakName = eventData.pakName
  self:UpdateTryPutOnList(itemID, pakName)
  self:PoseAnimSeqResDownloadFinish(eventData)
end
function LobbyAvatar:OnCameraSwitch(_, _, cameraID)
  self:ResetSkritParticles()
end
function LobbyAvatar:OnLobbyCameraShowOrHide(_, _, bShow)
  if bShow then
    self:ResetSkritParticles()
  end
end
function LobbyAvatar:ResetSkritParticles()
  self:AddTimerOnce(0.0, function()
    local operateAvatar = self:GetModel()
    if not slua.isValid(operateAvatar) then
      return
    end
    operateAvatar:ResetSkirtParticles()
  end)
end
function LobbyAvatar:GetModel()
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  return LobbyAvatarManager.GetOperateAvatarByAvatarID(self._avatarID)
end
function LobbyAvatar:GetModelAvatarComp()
  local Pawn = self:GetModel()
  if not slua.isValid(Pawn) then
    return
  end
  return Pawn.CharacterAvatarComp2_BP
end
function LobbyAvatar:_SetLocation(x, y, z)
  log(bWriteLog and string.format("LobbyAvatar:_SetLocation(%s, %s, %s) self._avatarID = %s", x, y, z, tostring(self._avatarID)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:K2_SetActorLocation(FVector(x or 0, y or 0, z or 0), false, nil, false)
end
function LobbyAvatar:GetPosition()
  log(bWriteLog and "LobbyAvatar:GetPosition()")
  return self._position
end
function LobbyAvatar:SetPosition(x, y, z)
  log(bWriteLog and string.format("LobbyAvatar:SetPosition(%s, %s, %s) self._avatarID = %s", x, y, z, tostring(self._avatarID)))
  self._position.  self._position.  self._position.  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatar:SetPosition operateAvatar is not Valid")
    return
  end
  local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
  operateAvatar:K2_SetActorRelativeLocation(FVector(x, y, z), false, nil, false)
  if self._pet and z ~= logic_couple_avatar_util.HidePos.Z then
    self._pet:WaitingForMaster()
  end
end
function LobbyAvatar:AttachToPawnContainer(lobbyPawnContainer)
  log(bWriteLog and string.format("LobbyAvatar:AttachToPawnContainer(%s)", lobbyPawnContainer))
  if lobbyPawnContainer == nil then
    return
  end
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return nil
  end
  local pawnContainerId = lobbyPawnContainer._id
  local pawnContainer = require(LobbyAvatar.Const.PawnContainerClassPath)
  operateAvatar:K2_AttachToActor(pawnContainer.GetOperatePawnContainer(pawnContainerId), "None", 1, 1, 1, false)
end
function LobbyAvatar:DetachFromPawnContainer()
  log(bWriteLog and "LobbyAvatar:DetachFromPawnContainer()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return nil
  end
  operateAvatar:K2_DetachFromActor(1, 1, 1)
end
function LobbyAvatar:GetRotation()
  log(bWriteLog and "LobbyAvatar:GetRotation()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return nil
  end
  return operateAvatar:K2_GetActorRotation()
end
function LobbyAvatar:SetRotation(roll, pitch, yaw)
  log(bWriteLog and string.format("LobbyAvatar:SetRotation(%s, %s, %s) self._avatarID = %s", roll, pitch, yaw, tostring(self._avatarID)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  if operateAvatar.StartRotateFlag and operateAvatar.ResetRotateFlag then
    operateAvatar:ResetRotateFlag()
    log(bWriteLog and "LobbyAvatar:SetRotation stop tick Rotate")
  end
  operateAvatar:K2_SetActorRotation(FRotator(pitch, yaw, roll), false)
end
function LobbyAvatar:RotateOnTick(time, target)
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar.RotateTime = time / 1000
  operateAvatar.TargetRotation = target
  operateAvatar.StartRotateFlag = true
end
function LobbyAvatar:ForceResetRotate()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  log(bWriteLog and "LobbyAvatar:ForceResetRotate.SetRotation")
  self:SetRotation(0, 0, 0)
  if operateAvatar.ResetRotateFlag then
    operateAvatar:ResetRotateFlag()
  end
end
function LobbyAvatar:SetScale(value)
  log(bWriteLog and string.format("LobbyAvatar:SetScale(%s) self._avatarID = %s", value, tostring(self._avatarID)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar.mesh:SetRelativeScale3D(FVector(value, value, value))
end
function LobbyAvatar:SetActorScale3D(value)
  log(bWriteLog and string.format("LobbyAvatar:SetActorScale3D(value = %s) self._avatarID = %s", tostring(value), tostring(self._avatarID)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:SetActorScale3D(FVector(value, value, value))
end
function LobbyAvatar:GetRadius()
  log(bWriteLog and "LobbyAvatar:GetRadius()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return nil
  end
  return operateAvatar.CapsuleComponent:GetUnscaledCapsuleRadius()
end
function LobbyAvatar:SetCapsuleHalfHeight(halfHeight)
  log(bWriteLog and string.format("LobbyAvatar:SetCapsuleHalfHeight(%s)", halfHeight))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar.CapsuleComponent:SetCapsuleHalfHeight(halfHeight, true)
end
function LobbyAvatar:SetCapsuleRadius(radius)
  log(bWriteLog and string.format("LobbyAvatar:SetCapsuleRadius(%s)", radius))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar.CapsuleComponent:SetCapsuleRadius(radius, true)
end
function LobbyAvatar:SetCapsuleSize(halfHeight, radius)
  self:SetCapsuleHalfHeight(halfHeight)
  self:SetCapsuleRadius(radius)
end
function LobbyAvatar:GetMouthWorldPosition()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  local ActorPos = operateAvatar:K2_GetActorLocation()
  local CapsuleComponent = operateAvatar.CapsuleComponent
  local HeadHeight = ActorPos.Z + CapsuleComponent:GetScaledCapsuleHalfHeight()
  local HeadHeightWithoutHemisphere = ActorPos.Z + CapsuleComponent:GetScaledCapsuleHalfHeight_WithoutHemisphere()
  local Radius = CapsuleComponent:GetScaledCapsuleRadius()
  local Z = (HeadHeight + HeadHeightWithoutHemisphere) * 0.5
  ActorPos.  ActorPos.X = ActorPos.X - Radius * 0.5
  return ActorPos
end
function LobbyAvatar:GetSex()
  log(bWriteLog and string.format("LobbyAvatar:GetSex() return %s", self._sex))
  return self._sex
end
function LobbyAvatar:GetHeadId()
  log(bWriteLog and string.format("LobbyAvatar:GetHeadId() return %s", self._headId))
  return self._headId
end
function LobbyAvatar:SwitchSexAndHeadAndHair(sex, headID, hair)
  log(bWriteLog and string.format("LobbyAvatar:SwitchSexAndHeadAndHair(%s, %s, %s)", sex, headID, hair))
  if self._sex == sex and self._headId == headID then
    return
  end
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  log(bWriteLog and "LobbyAvatar:SwitchSexAndHeadAndHair")
  local EAvatarSlotType = import("EAvatarSlotType")
  if hair and hair ~= 0 then
    self:RemovetTryPutOnBySlot(EAvatarSlotType.EAvatarSlotType_HairEquipemtSlot)
  end
  if headID and headID ~= 0 then
    self:RemovetTryPutOnBySlot(EAvatarSlotType.EAvatarSlotType_HeadEquipemtSlot)
  end
  self._  self._headId = headID
  self:_RealDoSwitchSexAndHeadAndHair(hair)
end
function LobbyAvatar:SwitchSex(sex)
  if self._sex == sex then
    return
  end
  self._  self:_RealDoSwitchSexAndHeadAndHair()
end
function LobbyAvatar:_RealDoSwitchSexAndHeadAndHair(hair)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  self:StopAction()
  local default_head_id = LobbyAvatarManager.CreateDefaultAvatar(self._headId, operateAvatar)
  if self._headId ~= 0 and default_head_id ~= self._headId then
    self._headId = default_head_id
  else
    local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
    local dataSex = AvatarCommon.ModelSexToDataSex(self._sex)
    operateAvatar:SwitchSexAndHeadAndHair(dataSex, self._headId, hair)
  end
end
function LobbyAvatar:SetCanRotate(isCan)
  log(bWriteLog and string.format("LobbyAvatar:SetCanRotate(%s)", isCan))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:SetCanRotate(isCan)
end
function LobbyAvatar:EnableClothAnimation(isEnable)
  log(bWriteLog and string.format("LobbyAvatar:EnableClothAnimation(%s)", isEnable))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:EnableClothAndHairAnimation(isEnable)
  if isEnable then
    operateAvatar:DelayResetClothSimulate()
  end
end
function LobbyAvatar:SetSceneType(sceneType)
  log(bWriteLog and string.format("LobbyAvatar:SetSceneType(%s)", sceneType))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:SetCharSceneType(sceneType)
end
function LobbyAvatar:SetSceneType2(sceneType)
  log(bWriteLog and string.format("LobbyAvatar:SetSceneType2(%s)", sceneType))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:SetCharSceneType2(sceneType)
end
function LobbyAvatar:EnableLobbyShowItem(isEnable)
  log(bWriteLog and string.format("LobbyAvatar:EnableLobbyShowItem(%s)", isEnable))
  self._enableLobbyShowItem = isEnable
end
function LobbyAvatar:EnableHatHelmetMutex(isEnable)
  log(bWriteLog and "LobbyAvatar:EnableHatHelmetMutex is " .. tostring(isEnable))
  self._enableHatHelmetMutex = isEnable
end
function LobbyAvatar:EnablePlayCameraAnim(bEnable)
  log(bWriteLog and string.format("LobbyAvatar:EnablePlayCameraAnim(%s)", bEnable))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not slua.isValid(operateAvatar.LobbyPlayEmoteComponent_BP) then
    return
  end
  operateAvatar.LobbyPlayEmoteComponent_BP.isPlayCameraAnim = bEnable
end
function LobbyAvatar:SetForceUseDefaultIdle(bForce)
  log(bWriteLog and string.format("LobbyAvatar:SetForceUseDefaultIdle(%s)", bForce))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:SetForceUseDefaultIdle(bForce)
end
function LobbyAvatar:PoseAnimSeqResDownloadFinish(tDownloadData)
  local sAnimSeqPath = self._sAnimSeqPath
  if not sAnimSeqPath then
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local sPakName = PufferManager.GetPakName(self._sAnimSeqPath)
  if sPakName ~= tDownloadData.pakName then
    return
  end
  local model_util = require("client.common.model_util")
  local uAnimSeq = model_util.GetAssetObjByPath(sAnimSeqPath)
  self:SetPoseInCollectionHall(sAnimSeqPath, uAnimSeq)
end
function LobbyAvatar:SetPoseInCollectionHall(sAnimSeqPath, AnimSeq)
  log(bWriteLog and string.format("LobbyAvatar:SetPoseInCollectionHall(%s)", tostring(slua.isValid(AnimSeq))))
  self._  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:SetPoseInCollectionHall(AnimSeq)
end
function LobbyAvatar:SetAvatarLevel(level)
  log(bWriteLog and string.format("LobbyAvatar:SetAvatarLevel(%s)", level))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:SetAvatarLevel(level)
end
function LobbyAvatar:ClearTryPutOnList()
  log(bWriteLog and "LobbyAvatar:ClearTryPutOnList()")
  self._tryPutOn = {}
end
function LobbyAvatar:RemovetTryPutOnBySlot(Slot)
  log(bWriteLog and "LobbyAvatar:RemovetTryPutOnBySlot Slot:" .. tostring(Slot))
  log_tree("LobbyAvatar:RemovetTryPutOnBySlot _tryPutOn:", self._tryPutOn)
  for itemID, _ in pairs(self._tryPutOn) do
    if Slot == _GetSlotByItemID(itemID) then
      log(bWriteLog and "LobbyAvatar:RemovetTryPutOnBySlot itemID" .. tostring(itemID))
      self._tryPutOn[itemID] = nil
    end
  end
end
function LobbyAvatar:SetIsMVPMotion(flag)
  log(bWriteLog and string.format("LobbyAvatar:SetIsMVPMotion(%s)", flag))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:SetIsMVPMotion(flag)
end
function LobbyAvatar:EnableCastPhotonShadow(bEnable)
  log(bWriteLog and "LobbyAvatar:EnableCastPhotonShadow()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:SetCastPhotonShadow(bEnable)
end
function LobbyAvatar:GetEquipments()
  log(bWriteLog and "LobbyAvatar:GetEquipments()")
  local equipmentsList = {}
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatar:GetEquipments Error:Actor is nil.")
    return equipmentsList
  end
  local equipmentsInfoList = operateAvatar:GetCurAllEquipmentsInfo()
  for k, v in pairs(equipmentsInfoList) do
    local isUsingWeapon
    if v.IsWeapon then
      isUsingWeapon = v.IsUsing
    end
    local item = {
      itemID = v.ItemID,
      isCurUsingWeapon = isUsingWeapon,
      CustomInfo = slua.IndexReference(v, "CustomInfo"):clone()
    }
    equipmentsList[#equipmentsList + 1] = item
  end
  return equipmentsList
end
function LobbyAvatar:CopyEquipments(targetAvatar, extraData)
  log(bWriteLog and string.format("LobbyAvatar:CopyEquipments(%s,%s)", targetAvatar, tostring(extraData and extraData.uidForChangingHead)))
  if not targetAvatar or not slua.isValid(targetAvatar:GetModel()) then
    log(bWriteLog and "LobbyAvatar:CopyEquipments() fail : targetAvatar not valid")
    return
  end
  if not slua.isValid(self:GetModel()) then
    log(bWriteLog and "LobbyAvatar:CopyEquipments() fail : self not valid")
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local targetHeadID = targetAvatar:GetModel():GetEquipmentInfoBySlot(EAvatarSlotType.EAvatarSlotType_HeadEquipemtSlot)
  local selfHeadID = self:GetModel():GetEquipmentInfoBySlot(EAvatarSlotType.EAvatarSlotType_HeadEquipemtSlot)
  local excludes
  if targetHeadID == selfHeadID then
    excludes = {targetHeadID}
    log(bWriteLog and "LobbyAvatar:CopyEquipments() same head")
  end
  self:ClearEquipments({targetHeadID})
  local targetEquipments = targetAvatar:GetEquipments()
  for _, equipmentInfo in pairs(targetEquipments) do
    if excludes and excludes[1] == equipmentInfo.itemID then
    elseif extraData and extraData.isblockHelmet == true then
      local itemCfg = CDataTable.GetTableData("Item", equipmentInfo.itemID)
      if itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Helmet or itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
      else
        self:PutonEquipment(equipmentInfo.itemID, equipmentInfo.CustomInfo, {
          bIsUse = equipmentInfo.isCurUsingWeapon
        })
      end
    else
      self:PutonEquipment(equipmentInfo.itemID, equipmentInfo.CustomInfo, {
        bIsUse = equipmentInfo.isCurUsingWeapon
      })
    end
  end
end
function LobbyAvatar:HasEquippedWeapon(weaponID)
  log(bWriteLog and string.format("LobbyAvatar:HasEquippedWeapon(%s)", weaponID))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarError:Actor is nil.")
    return false
  end
  weaponID = self:_GetDisplayItemID(weaponID)
  local config = CDataTable.GetTableData("Item", weaponID)
  if not config then
    return false
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if config.ItemType ~= LobbyAvatarManager.Enum_ItemTypeID.Weapon then
    return false
  end
  if not operateAvatar.BP_LobbyWeaponManager or not operateAvatar.BP_LobbyWeaponManager.InventoryData then
    return false
  end
  for _, weapon in pairs(operateAvatar.BP_LobbyWeaponManager.InventoryData) do
    if weapon then
      local originalWeaponID = weapon:GetItemDefineID().TypeSpecificID
      if originalWeaponID == weaponID then
        return true
      end
    end
  end
  return false
end
function LobbyAvatar:HasEquippedWeapon_New(weaponID, operateAvatar, config)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if config.ItemType ~= LobbyAvatarManager.Enum_ItemTypeID.Weapon then
    return false
  end
  if not operateAvatar.BP_LobbyWeaponManager or not operateAvatar.BP_LobbyWeaponManager.InventoryData then
    return false
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local ShowingStatus = ModelDisplayer.GetShowingStatus()
  for _, weapon in pairs(operateAvatar.BP_LobbyWeaponManager.InventoryData) do
    if weapon then
      local originalWeaponID = weapon:GetItemDefineID().TypeSpecificID
      if originalWeaponID == weaponID then
        return true
      end
    end
  end
  if ShowingStatus == ModelDisplayer.Enum_Status.Model then
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    local ShowingWeaponId = MallSystemWeaponModelHandler.GetShowingId()
    if ShowingWeaponId == weaponID then
      return true
    end
  end
  return false
end
function LobbyAvatar:HasEquippedLevelItem(itemID, tAvatarCustom)
  log(bWriteLog and string.format("LobbyAvatar:HasEquippedLevelItem(%s, %s)", itemID, tostring(tAvatarCustom)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarError:Actor is nil.")
    return false
  end
  local baseConfig = CDataTable.GetTableData("MALL_BAG_HELMET_BASE_ITEM_CONFIG", itemID)
  if not baseConfig then
    return false
  end
  local baseItemID = baseConfig.baseItemID
  local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", baseItemID)
  if not itemMappingCfg then
    return false
  end
  local _check = function(key)
    return operateAvatar:IsItemHasEquipped(key, tAvatarCustom)
  end
  if _check(itemMappingCfg.SkinItemIDLv1) then
    return true
  end
  if _check(itemMappingCfg.SkinItemIDLv2) then
    return true
  end
  if _check(itemMappingCfg.SkinItemIDLv3) then
    return true
  end
  return false
end
function LobbyAvatar:HasEquiped(itemID, tAvatarCustom)
  log(bWriteLog and string.format("LobbyAvatar:HasEquiped(%s, %s)", itemID, tostring(tAvatarCustom)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarError:Actor is nil.")
    return false
  end
  itemID = self:_GetDisplayItemID(itemID)
  local config = CDataTable.GetTableData("Item", itemID)
  if not config then
    return false
  end
  if self:HasEquippedWeapon_New(itemID, operateAvatar, config) then
    return true
  end
  if operateAvatar:IsItemHasEquipped(itemID, tAvatarCustom) then
    return true
  end
  if self:HasEquippedLevelItem(itemID, tAvatarCustom) then
    return true
  end
  if self._tryPutOn and self._tryPutOn[itemID] then
    local ItemInfo = CDataTable.GetTableData("Item", itemID)
    if ItemInfo and ItemInfo.ItemType == 22 and ItemInfo.ItemSubType == 2201 then
      return false
    end
    return true
  end
  return false
end
function LobbyAvatar:HasEquipedGlide()
  local GlideID = self:GetEquipedGlideID()
  if not GlideID or GlideID <= 0 then
    return false
  end
  return true
end
function LobbyAvatar:GetEquipedGlideID()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarHasEquipedGlide Error:Actor is nil.")
    return 0
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local GlideID = operateAvatar:GetEquipmentInfoBySlot(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot)
  return GlideID
end
function LobbyAvatar:SetGlideAnimNotifyEffectVisible(bVisible)
  local AvatarComp = self:GetModelAvatarComp()
  if not slua.isValid(AvatarComp) or not self:HasEquipedGlide() then
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local MeshComp = AvatarComp:GetMeshCompBySlotID(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot)
  if not slua.isValid(MeshComp) or not MeshComp.GetChildrenComponents then
    return
  end
  local ParticleComponentClass = import("/Script/Engine.ParticleSystemComponent")
  local uComponentArray = MeshComp:GetChildrenComponents(false, nil)
  if not uComponentArray then
    return
  end
  for _, ChildComp in pairs(uComponentArray) do
    if slua.isValid(ChildComp) and Game:IsClassOf(ChildComp, ParticleComponentClass) and ChildComp:ComponentHasTag("DestroyWithEmote") then
      ChildComp:SetVisibility(bVisible, false)
    end
  end
end
function LobbyAvatar:GetEquipedGloveID()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "[LobbyAvatar:GetEquipedGloveID] Actor is invalid")
    return 0
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local GloveID = operateAvatar:GetEquipmentInfoBySlot(EAvatarSlotType.EAvatarSlotType_HandleEquipmentSlot)
  log(bWriteLog and "[LobbyAvatar:GetEquipedGloveID] GloveID: " .. tostring(GloveID))
  return GloveID
end
function LobbyAvatar:GetTakeOnEquipments()
  log(bWriteLog and "[tinghaohu][LobbyAvatar] LobbyAvatar:GetTakeOnEquipments()")
  return self._lastTakeOnEquipments
end
function LobbyAvatar:GetTakeoffEquipments()
  log(bWriteLog and "LobbyAvatar:GetTakeoffEquipments()")
  return self._lastTakeoffEquipments
end
function LobbyAvatar:MarkForCheckTakeoff()
  local check = next(self._tryPutOn) ~= nil
  log(bWriteLog and "LobbyAvatar:MarkForCheckTakeoff " .. tostring(check))
  self._checkTakeOff = check
end
function LobbyAvatar:PutonEquipment(itemID, tAvatarCustom, tExtraData)
  tAvatarCustom = tAvatarCustom or {}
  tExtraData = tExtraData or {}
  local nColorID = tAvatarCustom.ColorID or 0
  local nPatternID = tAvatarCustom.PatternID or 0
  log(bWriteLog and string.format("LobbyAvatar:PutonEquipment(%s, %s, %s, %s) self._avatarID = %s", itemID, nColorID, nPatternID, tExtraData, tostring(self._avatarID)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarLobbyAvatar:PutonEquipment Error:Actor is nil.")
    return
  end
  if Client and Client.IsDevelopment() and not operateAvatar.BP_LobbyWeaponManager then
    log(bWriteLog and "LobbyAvatar:PutonEquipment Error:BP_LobbyWeaponManager is nil.")
    return
  end
  if tAvatarCustom.ShapeInfo == nil then
    local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
    local shapeInfo = logic_suit_multi_shape:GetSuitShapeID(operateAvatar:GetPlayerUID(), itemID)
    tAvatarCustom.ShapeInfo = shapeInfo
  end
  if itemID == nil or itemID == 0 then
    log_error("[LobbyAvatar] Error: PutonEquipment itemID is " .. tostring(itemID) .. " ,skip...")
    return
  end
  itemID = self:_GetReplaceItemID(itemID)
  itemID = self:_GetDisplayItemID(itemID)
  local config = CDataTable.GetTableData("Item", itemID)
  if config == nil then
    log_error("LobbyAvatar:PutonEquipment Error: config is nil " .. itemID)
    return
  end
  local FBI = require("client.slua.logic.fbi.logic_fbi")
  if FBI.IsIllegalTime(itemID) then
    log_error(bWriteLog and "LobbyAvatar:PutonEquipment IllegalTime " .. tostring(itemID))
    return
  end
  local gc_util = require("common.gc_util")
  gc_util.GCByMaxObjectOrMemory()
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsGlide(config.ItemSubType) then
    self:SetGlideAnimNotifyEffectVisible(false)
  end
  local nCurEmoteID = self:GetCurActionID()
  if self.PlayingChangeActionMap[nCurEmoteID] then
    if self.PlayingChangeActionMap[nCurEmoteID] == itemID then
      log(bWriteLog and "LobbyAvatar:PutonEquipment same with changeAction Item")
      return
    end
    if tExtraData.bIsUse == false then
      log(bWriteLog and "LobbyAvatar:PutonEquipment bIsUse = false, dont stop action")
      return
    end
    log(bWriteLog and "LobbyAvatar:PutonEquipment Stop Change Action")
    self:StopAction()
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsNeedStopActionWhenPutOn(nCurEmoteID) then
    log(bWriteLog and "LobbyAvatar:PutonEquipment Stop Xsuit Action")
    self:StopAction()
  end
  local beforeEquipments = {}
  for i, equipmentInfo in ipairs(self:GetEquipments()) do
    beforeEquipments[equipmentInfo.itemID] = 1
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if self._enableHatHelmetMutex == true then
    if config.ItemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot then
      self:PutoffSubtype(ENUM_ITEM_SUBTYPE.Helmet)
      self:PutoffSubtype(ENUM_ITEM_SUBTYPE.Helmet_NoLevel)
    end
    if config.ItemSubType == ENUM_ITEM_SUBTYPE.Helmet or config.ItemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
      self:PutoffSubtype(ENUM_ITEM_SUBTYPE.Hat_Slot)
    end
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if config.ItemType == wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon then
    local isUse = true
    local isAsync = true
    if tExtraData and next(tExtraData) then
      if tExtraData.bIsUse ~= nil then
        isUse = tExtraData.bIsUse
      end
      if tExtraData.bIsAsync ~= nil then
        isAsync = tExtraData.bIsAsync
      end
    end
    local JumpOverEquipWeapon = false
    if LobbyAvatar.Const.NotShowBaseWeaponSkins[itemID] then
      local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
      if PufferODPakManager:GetStateByItemID(itemID) ~= PufferConst.ENUM_DownloadState.Done then
        JumpOverEquipWeapon = true
      end
    end
    if not JumpOverEquipWeapon then
      self:CharEquipWeaponByResId(itemID, isUse, isAsync)
    end
  elseif config.ItemSubType == ENUM_ITEM_SUBTYPE.Head_Slot_400 then
    local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
    local dataSex = AvatarCommon.ModelSexToDataSex(self._sex)
    operateAvatar:SwitchSexAndHeadAndHair(dataSex, itemID, 0)
  elseif config.ItemSubType == ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin and operateAvatar:GetEquipmentInfoBySlot(8) == 0 then
    self:StopEnterAction()
  else
    self:StopEnterAction()
    local suitsCfg = CDataTable.GetTableData("AvatarSuitsTable", itemID)
    local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
    local stateCheckItemID = AvatarUtil.ConvertUnderWearID(itemID, nColorID)
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {stateCheckItemID})
    if suitsCfg and state ~= ENUM_DownloadState.Done then
    elseif AvatarUtil.NeedDoubleCheck(itemID) and not AvatarUtil.DoubleCheckIsDownLoadFinish(itemID) then
    else
      local LocalPutOn = function()
        operateAvatar:PutOnEquipmentByResID(itemID, tAvatarCustom)
      end
      local withOutAction = tExtraData and tExtraData.withOutAction
      if withOutAction then
        LocalPutOn()
      elseif ModelDisplayTypeHelper.IsWakeFlame(config.ItemType, config.ItemSubType) and operateAvatar.PlayerUID ~= "" then
        operateAvatar:PreviewMoveEffect(itemID, LobbyAvatar.Const.AdditionEffectEmote)
        self:SendPreviewEffectSyncReq(itemID)
      elseif ModelDisplayTypeHelper.IsFootprints(config.ItemType, config.ItemSubType) and operateAvatar.PlayerUID ~= "" then
        operateAvatar:PreviewFootStepEffect(itemID, LobbyAvatar.Const.AdditionEffectEmote)
        self:SendPreviewEffectSyncReq(itemID)
      elseif not self:CheckAndExecuteChangeOperate(operateAvatar, itemID, tAvatarCustom) then
        LocalPutOn()
      end
    end
  end
  if config.ItemSubType == ENUM_ITEM_SUBTYPE.Foot_Effect and self:HasEquiped(itemID, tAvatarCustom) then
    local EAvatarSlotType = import("EAvatarSlotType")
    operateAvatar:SetMeshVisibleByID(EAvatarSlotType.EAvatarSlotType_FootEffectEquipemtSlot, true, false, false)
  end
  if config.ItemSubType == ENUM_ITEM_SUBTYPE.Backpack or config.ItemSubType == ENUM_ITEM_SUBTYPE.Upgrade_Backpack then
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local bag = fashionbag_data:GetCurrentFashionBag()
    if operateAvatar:GetEquipmentInfoBySlot(17) == 0 and bag.bag_pendants and 0 < #bag.bag_pendants then
      for insID, _ in pairs(bag.bag_pendants) do
        if insID ~= nil and insID ~= 0 then
          local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
          local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(insID)
          if itemInfo then
            self:PutonEquipment(itemInfo.resID, tAvatarCustom)
          end
        end
        break
      end
    end
  end
  log(bWriteLog and "LobbyAvatar:PutonEquipment itemID = " .. tostring(itemID) .. " GetWeaponSocketNameByResId(itemID) = " .. tostring(operateAvatar.BP_LobbyWeaponManager:GetWeaponSocketNameByResId(itemID)))
  if self._tryPutOn and next(self._tryPutOn) then
    local itemSlot = _GetSlotByItemID(itemID)
    for tryToPutOnItemID, _ in pairs(self._tryPutOn) do
      local iCfg = CDataTable.GetTableData("Item", tryToPutOnItemID)
      if iCfg and config.ItemType == ENUM_ITEM_TYPE.Weapon and iCfg.ItemType == 1 then
        log(bWriteLog and "LobbyAvatar:PutonEquipment i = " .. tostring(tryToPutOnItemID) .. " GetWeaponSocketNameByResId(i) = " .. tostring(operateAvatar.BP_LobbyWeaponManager:GetWeaponSocketNameByResId(tryToPutOnItemID)))
        if operateAvatar.BP_LobbyWeaponManager:GetWeaponSocketNameByResId(tryToPutOnItemID) == operateAvatar.BP_LobbyWeaponManager:GetWeaponSocketNameByResId(itemID) then
          self._tryPutOn[tryToPutOnItemID] = nil
          break
        end
      else
        log(bWriteLog and "LobbyAvatar:PutonEquipment i = " .. tostring(tryToPutOnItemID))
        if _GetSlotByItemID(tryToPutOnItemID) == itemSlot then
          self._tryPutOn[tryToPutOnItemID] = nil
          break
        end
      end
    end
  end
  self:HandleDownload(itemID, tAvatarCustom, tExtraData)
  local afterEquipments = {}
  for i, equipmentInfo in ipairs(self:GetEquipments()) do
    afterEquipments[equipmentInfo.itemID] = 1
  end
  local takeonEquipments = {}
  for nTempItemId, _ in pairs(afterEquipments) do
    if beforeEquipments[nTempItemId] == nil then
      table.insert(takeonEquipments, itemID)
    end
  end
  local takeoffEquipments = {}
  for nTempItemId, _ in pairs(beforeEquipments) do
    if afterEquipments[nTempItemId] == nil then
      table.insert(takeoffEquipments, nTempItemId)
    end
  end
  self._lastTakeOnEquipments = takeonEquipments
  self._lastTakeoffEquipments = takeoffEquipments
  local PlayAnimationFeatureInGameGuide = require("client.slua.umg.newbie_guide.PlayAnimationFeatureInGameGuide")
  if operateAvatar.PlayerUID and operateAvatar.PlayerUID == DataMgr.roleData.uid and PlayAnimationFeatureInGameGuide.CanShowGuide(itemID) then
    PlayAnimationFeatureInGameGuide.ShowAndSaveGuide()
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if Client.IsShipping() and globalConfig.IsDirectConnect() and LobbySystem.CheckOpen(BP_ENUM_LOBBY_IS_REPORT_PUT_ON) and CDataTable.GetTableData("PutOnReport", itemID) and not LobbyAvatarManager._report_ids[itemID] then
    LobbyAvatarManager._report_ids[itemID] = true
    local gem_report_utils = require("client.logic.store.gem_report_utils")
    gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_LobbyPutOnSpecial, itemID, config.ItemName)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyPutOnSpecial, 0, tostring(itemID) .. "_" .. config.ItemName)
  end
  return takeoffEquipments
end
function LobbyAvatar:SetIsAutoDownloadControlled(bIsAutoDownloadControlled)
  self._end
function LobbyAvatar:HandleDownload(itemID, tAvatarCustom, extraData, onlyCheckFight)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local bDownloaded = true
  if PufferODPakManager:GetStateByItemID(itemID) ~= PufferConst.ENUM_DownloadState.Done then
    self._tryPutOn[itemID] = {
      tAvatarCustom = tAvatarCustom,
      extraData = extraData,
      paks = {}
    }
    local paks = PufferODPakManager:GetPakNamesByItemID(itemID)
    for pakName, v in pairs(paks) do
      if PufferODPakManager:GetStateByPakName(pakName) ~= PufferConst.ENUM_DownloadState.Done then
        table.insert(self._tryPutOn[itemID].paks, pakName)
      end
    end
    if onlyCheckFight then
      local BackpackUtils = import("BackpackUtils")
      local DefineID = BackpackUtils.GenerateItemDefineIDByItemTableIDWithRandomInstanceID(itemID)
      local bSkinEist = BackpackUtils.IsBattleItemHandleExist(DefineID, false, false, false)
      if not bSkinEist then
        bDownloaded = false
      end
    else
      bDownloaded = false
    end
  end
  log_tree("LobbyAvatar:HandleDownload self._tryPutOn =  ", self._tryPutOn)
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if not PufferSwitch.BanAutoDownload then
    local operateAvatar = self:GetModel()
    local autoDownload = true
    local isWardrobe = UIManager.IsUIShow(UIManager.UI_Config.wardrobe)
    if isWardrobe or self._bIsAutoDownloadControlled then
      autoDownload = true
    end
    local params = {bAutoDownload = autoDownload, bFirst = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {itemID}, nil, nil, params)
    log(bWriteLog and "LobbyAvatar:HandleDownload try find shape id with " .. tostring(itemID))
    if slua.isValid(operateAvatar) then
      local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
      local ShapeID = logic_suit_multi_shape:GetSuitShapeID(operateAvatar:GetPlayerUID(), itemID)
      if ShapeID then
        log(bWriteLog and "LobbyAvatar:HandleDownload Found ShapeID with" .. tostring(itemID) .. " ShapeID: " .. tostring(ShapeID))
        PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {ShapeID}, nil, nil, params)
      else
        log(bWriteLog and "LobbyAvatar:HandleDownload NOT Found ShapeID with" .. tostring(itemID))
      end
    end
  end
  PufferManager.DownloadRelateActionList(itemID)
  return bDownloaded
end
function LobbyAvatar:HandleBattleDownload()
  local actions = {
    "/Game/Arts_Player/Characters/Animation/Shared_Anim/Lobby_Anim/funny_show_ani_Montage.funny_show_ani_Montage",
    "/Game/Arts_Player/Characters/Animation/Shared_Anim/Skill/Unarmed_Combat_Pet_RetractPortal_Montage.Unarmed_Combat_Pet_RetractPortal_Montage"
  }
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, actions)
  log(bWriteLog and "  LobbyAvatar:HandleBattleDownload. state: " .. tostring(state))
  if state ~= ENUM_DownloadState.Done and state ~= ENUM_DownloadState.Download then
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, actions, nil, nil, {bAutoDownload = true})
  end
end
function LobbyAvatar:HandleShapeInfo(ClothID, shapeInfo)
  if not slua.isValid(self:GetModel()) then
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local ItemID, CustomData = self:GetModel():GetEquipmentInfoBySlot(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if ItemID ~= ClothID then
    log(bWriteLog and "LobbyAvatar:HandleShapeInfo ItemID ~= ClothID ItemID:" .. tostring(ItemID) .. " ClothID:" .. tostring(ClothID))
    return
  end
  if CustomData.ShapeInfo == shapeInfo then
    log(bWriteLog and "LobbyAvatar:HandleShapeInfo ShapeInfo Same" .. tostring(shapeInfo))
    return
  end
  CustomData.ShapeInfo = shapeInfo
  self:PutonEquipment(ItemID, CustomData)
end
function LobbyAvatar:PutoffEquipment(itemID)
  log_shipping_client("LobbyAvatar:PutoffEquipment _avatarID:" .. tostring(self._avatarID) .. " PutoffEquipment " .. tostring(itemID))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarLobbyAvatar:PutoffEquipment Error:Actor is nil.")
    return
  end
  itemID = self:_GetReplaceItemID(itemID)
  itemID = self:_GetDisplayItemID(itemID)
  local config = CDataTable.GetTableData("Item", itemID)
  if config == nil then
    log_error("LobbyAvatar:PutoffEquipment Error: config is nil " .. tostring(itemID))
    return
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if config.ItemSubType == ENUM_ITEM_SUBTYPE.Head_Slot_400 then
    return
  end
  self._tryPutOn[itemID] = nil
  log(bWriteLog and "LobbyAvatar:PutoffEquipment " .. itemID .. " config.ItemType " .. config.ItemType)
  if config.ItemType == wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon then
    operateAvatar:CharUnEquipWeaponByResId(itemID)
    return
  end
  local nCurEmoteID = self:GetCurActionID()
  if self.PlayingChangeActionMap[nCurEmoteID] then
    log(bWriteLog and "LobbyAvatar:PutoffEquipment Stop Change Action")
    self:StopAction()
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsGlide(config.ItemSubType) then
    self:SetGlideAnimNotifyEffectVisible(false)
  end
  if ModelDisplayTypeHelper.IsAdditionEffect(config.ItemType, config.ItemSubType) then
    self:StopAction()
  end
  local beforeEquipments = {}
  local curEquip = self:GetEquipments()
  for i, equipmentInfo in ipairs(curEquip) do
    beforeEquipments[equipmentInfo.itemID] = 1
  end
  self:StopEnterAction()
  local baseConfig = CDataTable.GetTableData("MALL_BAG_HELMET_BASE_ITEM_CONFIG", itemID)
  if not baseConfig then
    operateAvatar:UnEquipByResID(itemID)
  else
    local baseItemID = baseConfig.baseItemID
    local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", baseItemID)
    if itemMappingCfg ~= nil then
      operateAvatar:UnEquipByResID(itemMappingCfg.SkinItemIDLv1)
      operateAvatar:UnEquipByResID(itemMappingCfg.SkinItemIDLv2)
      operateAvatar:UnEquipByResID(itemMappingCfg.SkinItemIDLv3)
    end
  end
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local multiCloth = multi_state_manager:GetAllMultiClothID(itemID)
  for itemId, _ in ipairs(multiCloth) do
    operateAvatar:UnEquipByResID(itemId)
  end
  local bonus_pass_util = require("client.slua.logic.unknow_pass.BonusPass.bonus_pass_util")
  local otherId = bonus_pass_util.GetColorfulItemId(itemID)
  if otherId then
    operateAvatar:UnEquipByResID(otherId)
  end
  local afterEquipments = {}
  curEquip = self:GetEquipments()
  for i, equipmentInfo in ipairs(curEquip) do
    afterEquipments[equipmentInfo.itemID] = 1
  end
  local takeonEquipments = {}
  for itemID, _ in pairs(afterEquipments) do
    if beforeEquipments[itemID] == nil then
      table.insert(takeonEquipments, itemID)
    end
  end
  local takeoffEquipments = {}
  for itemID, _ in pairs(beforeEquipments) do
    if afterEquipments[itemID] == nil then
      table.insert(takeoffEquipments, itemID)
    end
  end
  self._lastTakeOnEquipments = takeonEquipments
  self._lastTakeoffEquipments = takeoffEquipments
end
function LobbyAvatar:PutoffSubtype(subtype)
  log(bWriteLog and string.format("LobbyAvatar:PutoffSubtype(%s) self._avatarID = %s", subtype, tostring(self._avatarID)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarLobbyAvatar:PutoffSubtype Error:Actor is nil.")
    return
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if subtype == wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon then
    local nCurEmoteID = self:GetCurActionID()
    if self.PlayingChangeActionMap[nCurEmoteID] then
      log(bWriteLog and "LobbyAvatar:PutoffSubtype Stop Change Action")
      self:StopAction()
    end
    operateAvatar:CharUnEquipWeapon()
    return
  end
  local config = CDataTable.GetTableData("LobbyBattleSlotMapping", subtype)
  if config == nil then
    log_error("LobbyAvatar:PutoffSubtype Error: config is nil " .. subtype)
    return
  end
  self:RemovetTryPutOnBySlot(config.battleSlot)
  local itemID = operateAvatar:GetEquipmentInfoBySlot(config.battleSlot)
  if itemID == 0 then
    return
  end
  self:PutoffEquipment(itemID)
end
function LobbyAvatar:PutoffExtraWeapon()
  log(bWriteLog and "LobbyAvatar:PutOffExtraWeapon()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarError:Actor is nil.")
    return
  end
  operateAvatar:CharUnEquipExtraWeapon()
end
function LobbyAvatar:PutoffHead()
  log(bWriteLog and "LobbyAvatar:PutoffHead() self._avatarID = " .. tostring(self._avatarID))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarError:Actor is nil.")
    return
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local config = CDataTable.GetTableData("LobbyBattleSlotMapping", ENUM_ITEM_SUBTYPE.Head_Slot_400)
  if config == nil then
    return
  end
  local itemID = self:_GetDisplayItemID(operateAvatar:GetEquipmentInfoBySlot(config.battleSlot))
  if itemID == 0 then
    return
  end
  operateAvatar:UnEquipByResID(itemID)
end
function LobbyAvatar:ClearEquipments(doNotNeedPutOffItemList)
  log_shipping_client(string.format("LobbyAvatar:ClearEquipments(%s) _avatarID:%s", doNotNeedPutOffItemList, tostring(self._avatarID)))
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  self:PutoffSubtype(wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon)
  local maintainItemMap = {}
  if doNotNeedPutOffItemList and type(doNotNeedPutOffItemList) == "table" and next(doNotNeedPutOffItemList) then
    for _, v in ipairs(doNotNeedPutOffItemList) do
      maintainItemMap[v] = true
    end
  end
  local equipments = self:GetEquipments()
  log_tree("ClearEquipments", equipments)
  for itemID, _ in pairs(self._tryPutOn) do
    local uObj_itemCfg = CDataTable.GetTableData("Item", itemID)
    if uObj_itemCfg and not maintainItemMap[uObj_itemCfg.ItemSubType] then
      self._tryPutOn[itemID] = nil
    end
  end
  for subType, equipmentInfo in pairs(equipments) do
    local itemID = equipmentInfo.itemID
    local config = CDataTable.GetTableData("Item", itemID)
    if config == nil then
      log_error("LobbyAvatar:ClearEquipments config is nil " .. itemID)
    elseif maintainItemMap[config.ItemSubType] == nil then
      self:PutoffEquipment(equipmentInfo.itemID)
    end
  end
end
function LobbyAvatar:EquipWeaponBySlotID(weaponSkinID, slotID, autoUse)
  log(bWriteLog and string.format("LobbyAvatar:EquipWeaponBySlotID(%s, %s, %s) self._avatarID = %s", weaponSkinID, slotID, autoUse, tostring(self._avatarID)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not operateAvatar.BP_LobbyWeaponManager then
    return
  end
  if slotID == nil then
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    slotID = LobbyAvatarManager.Enum_WeaponAttachSlotID.MAIN_WEAPON1
  end
  if autoUse == nil then
    autoUse = true
  end
  self:CharEquipWeaponByResId(weaponSkinID, autoUse, true, slotID)
end
function LobbyAvatar:CharEquipWeaponByResId(resID, isUse, isAsync, SocketName)
  if IsEditor and slua_GameFrontendHUD.bEnableEditorPufferDownload then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local nDownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {resID})
    if nDownloadState ~= PufferConst.ENUM_DownloadState.Done then
      local logic_armory = require("client.logic.armory.logic_armory")
      resID = logic_armory.GetWeaponOriItemIdBySkinId(resID)
    end
  end
  log(bWriteLog and "LobbyAvatar:CharEquipWeaponByResId")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not operateAvatar.BP_LobbyWeaponManager then
    return
  end
  if self:TryPlaySwitchWeaponAction(resID, isUse, isAsync, SocketName) then
    log(bWriteLog and "LobbyAvatar:CharEquipWeaponByResId TryPlaySwitchWeaponAction")
    return
  end
  operateAvatar:CharEquipWeaponByResID(resID, isUse, isAsync, SocketName)
  operateAvatar:CharEquipWeaponPendant(resID, 2)
end
function LobbyAvatar:UnEquipWeaponBySlotID(weaponSkinID, slotID)
  log(bWriteLog and string.format("LobbyAvatar:UnEquipWeaponBySlotID(%s, %s)", weaponSkinID, slotID))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not operateAvatar.BP_LobbyWeaponManager then
    return
  end
  if slotID == nil then
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    slotID = LobbyAvatarManager.Enum_WeaponAttachSlotID.MAIN_WEAPON1
  end
  operateAvatar:CharUnEquipWeaponByResId(weaponSkinID, slotID)
end
function LobbyAvatar:UseWeaponBySlotID(slotID)
  log(bWriteLog and string.format("LobbyAvatar:UseWeaponBySlotID(%s)", slotID))
  local operateAvatar = self:GetModel()
  if not (slua.isValid(operateAvatar) and operateAvatar.BP_LobbyWeaponManager) or not slotID then
    return
  end
  operateAvatar.BP_LobbyWeaponManager:UseWeaponBySocketID(slotID)
end
function LobbyAvatar:UnUseCurHoldingWeapon()
  log(bWriteLog and "LobbyAvatar:UnUseCurHoldingWeapon()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not operateAvatar.BP_LobbyWeaponManager then
    return
  end
  operateAvatar.BP_LobbyWeaponManager:UnUseWeapon()
end
function LobbyAvatar:SwapMainWeapon()
  log(bWriteLog and "LobbyAvatar:SwapMainWeapon()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not operateAvatar.BP_LobbyWeaponManager then
    return
  end
  operateAvatar.BP_LobbyWeaponManager:SwapMainWeapon()
end
function LobbyAvatar:ReloadAvatarSlot(slotID, reloadType, isRebuildAvatarSyncData)
  log(bWriteLog and string.format("LobbyAvatar:ReloadAvatarSlot(%s, %s, %s)", slotID, reloadType, isRebuildAvatarSyncData))
  log_error(bWriteLog and "[useful] LobbyAvatar:ReloadAvatarSlot is useful")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarError:Actor is nil.")
    return
  end
  operateAvatar:ReloadLogicAvatar(slotID, reloadType, isRebuildAvatarSyncData)
end
function LobbyAvatar:ClearFriendPoseData()
  log(bWriteLog and "LobbyAvatar:ClearFriendPoseData()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  if slua.isValid(operateAvatar.Mesh) and slua.isValid(operateAvatar.Mesh.AnimScriptInstance) then
    operateAvatar.Mesh.AnimScriptInstance:OnCancelPoseWithFriend()
  end
end
function LobbyAvatar:StopEnterAction()
  log(bWriteLog and "LobbyAvatar:StopEnterAction()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local EnteringActionMap = LobbyAvatarManager.GetEnteringActionMap()
  if EnteringActionMap[operateAvatar.CurrentActionID] ~= nil and operateAvatar.IsPlayingAction then
    log(bWriteLog and "Real StopEnterAction")
    self:StopAction(true)
  end
end
local _FindAdaptEmotionID = function(operateAvatar, emoteID)
  log(bWriteLog and string.format("[LobbyAvatar] _FindAdaptEmotionID(%s, %s)", operateAvatar, emoteID))
  local playingEmoteID = -1
  if slua.isValid(operateAvatar.LobbyPlayEmoteComponent_BP) and operateAvatar.LobbyPlayEmoteComponent_BP.GetCurrentEmoteID then
    playingEmoteID = operateAvatar.LobbyPlayEmoteComponent_BP:GetCurrentEmoteID()
  end
  if playingEmoteID == emoteID then
    return emoteID
  end
  local cfg = CDataTable.GetTableData("EmoteBPTable", emoteID)
  if not cfg then
    return emoteID
  end
  local StringUtil = require("common.string_util")
  local parts = StringUtil.Split(cfg.LobbyEmoteAdapt, "|")
  local ItemID = tostring(operateAvatar:GetEquipmentInfoBySlot(5))
  if #parts == 2 and ItemID ~= parts[1] then
    if parts[1] == "1405983" and ItemID == "1407140" then
      return emoteID
    end
    if parts[1] == "1406152" and ItemID == "1407141" then
      return emoteID
    end
    if parts[1] == "1406311" and ItemID == "1407142" then
      return emoteID
    end
    return parts[2]
  end
  return emoteID
end
function LobbyAvatar:PlayAction(actionID, extraInfo, isMe, extraParam)
  log_warning(bWriteLog and string.format("LobbyAvatar:PlayAction(%s, %s)", actionID, extraInfo))
  local bStopDelay = extraParam and extraParam.bStopDelay
  if bStopDelay == nil then
    bStopDelay = true
  end
  self:StopAction(bStopDelay)
  if self._preActionID ~= actionID then
    self._preActionID = actionID
  end
  local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  if LobbySceneModule.IsLoading and (not extraParam or not extraParam.Nonblock) then
    LobbySceneModule:OnPlayAction(actionID)
    return
  end
  if actionID ~= WEAPON_STANDBY_ACTION_TIRGGER_ID then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {actionID})
    if state ~= PufferConst.ENUM_DownloadState.Done then
      if state ~= PufferConst.ENUM_DownloadState.Download then
        PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {actionID})
      end
      log_warning("[tinghaohu]LobbyAvatar:PlayAction. action has not download, actionID = " .. tostring(actionID))
      return
    end
  end
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  local useSeqCfg = CDataTable.GetTableData("TeamEmoteSeqCfg", actionID)
  if useSeqCfg and useSeqCfg.UseSeq then
    self:EnablePlayCameraAnim(true)
    if operateAvatar.LobbyPlayEmoteComponent_BP ~= nil then
      operateAvatar.LobbyPlayEmoteComponent_BP.bUseSequenceCamera = false
    end
  end
  if actionID == WEAPON_STANDBY_ACTION_TIRGGER_ID then
    log(bWriteLog and "LobbyAvatar:PlayAction Trigger Standby Action")
    local HasStanby, StanbyActionID, TipID = self:HasWeaponStandbyAction()
    if not HasStanby then
      if isMe then
        ShowNotice(TipID)
      end
      return
    end
    actionID = StanbyActionID
    self.IsPlayWeaponShow = true
    self:HideGloveByWeaponShow(true)
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.SetDisplayEmoteIDStart(actionID)
  local adaptActionID = _FindAdaptEmotionID(operateAvatar, actionID)
  log(bWriteLog and "LobbyAvatar playAction id:" .. tostring(adaptActionID))
  self:SetAvatarSyncWear(adaptActionID, true)
  if extraInfo and type(extraInfo) == "string" then
    operateAvatar:CharPlayEmoteByResId(adaptActionID, extraInfo, extraParam)
  else
    operateAvatar:CharPlayEmoteByResId(adaptActionID, "Default", extraParam)
  end
  ModelDisplayer.SetDisplayEmoteIDEnd(actionID)
  return true
end
function LobbyAvatar:PreparePlayAction(actionID, bDirectLoad)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {actionID})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    if state ~= PufferConst.ENUM_DownloadState.Download then
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {actionID})
    end
    log_warning("[tinghaohu]LobbyAvatar:PreparePlayAction. action has not download, actionID = " .. tostring(actionID))
    return
  end
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  local adaptActionID = _FindAdaptEmotionID(operateAvatar, actionID)
  log(bWriteLog and "LobbyAvatar PreparePlayAction id:" .. tostring(adaptActionID))
  operateAvatar:PreparePlayEmote(adaptActionID, bDirectLoad)
  return true
end
function LobbyAvatar:HideGloveByWeaponShow(bHidden)
  local AvatarComp = self:GetModelAvatarComp()
  if slua.isValid(AvatarComp) then
    local EAvatarSlotType = import("EAvatarSlotType")
    local EForceHideState = import("EForceHideState")
    local EForceHideStateReason = import("EForceHideStateReason")
    log(bWriteLog and "LobbyAvatar:HideGloveByWeaponShow bHidden:" .. tostring(bHidden))
    if bHidden then
      AvatarComp:SetForceHideState(EAvatarSlotType.EAvatarSlotType_HandleEquipmentSlot, EForceHideState.All, EForceHideStateReason.Client_WeaponShow)
    else
      AvatarComp:SetForceHideState(EAvatarSlotType.EAvatarSlotType_HandleEquipmentSlot, EForceHideState.None, EForceHideStateReason.Client_WeaponShow)
    end
  end
end
function LobbyAvatar:GetCurActionID()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not slua.isValid(operateAvatar.LobbyPlayEmoteComponent_BP) then
    return 0
  end
  return operateAvatar.LobbyPlayEmoteComponent_BP.GetCurrentEmoteID and operateAvatar.LobbyPlayEmoteComponent_BP:GetCurrentEmoteID()
end
function LobbyAvatar:PlayTeamupEffect(effectID, location)
  if not effectID or effectID == 0 then
    return
  end
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  log(bWriteLog and "LobbyAvatar PlayTeamupEffect")
  local EffectConfig = CDataTable.GetTableData("TeamupEntryParticleConfig", effectID)
  if not EffectConfig then
    log(bWriteLog and "[LobbyAvatar] invalid effect config: " .. tostring(effectID))
    return
  end
  self:DestoryHighLevelClothEffect()
  local Util = require("client.slua_ui_framework.util")
  if EffectConfig.EffectPath and EffectConfig.EffectPath ~= "" then
    Util.GetAssetAsync(EffectConfig.EffectPath, function(uPartcileSystem)
      if uPartcileSystem and slua.isValid(operateAvatar) and slua.isValid(operateAvatar.Mesh) then
        local EAttachLocation = import("EAttachLocation")
        local UGameplayStatics = import("GameplayStatics")
        self.teamupParticleEffect = UGameplayStatics.SpawnEmitterAttached(uPartcileSystem, operateAvatar.Mesh, "None", location or FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1), EAttachLocation.KeepRelativeOffset, true)
      end
    end)
  end
  if EffectConfig.AudioPath and EffectConfig.AudioPath ~= "" then
    local audio_util = require("client.common.audio_util")
    _, self.teamupAudioID = audio_util.PlayAudioByActor(EffectConfig.AudioPath)
  end
end
function LobbyAvatar:StopTeamupEffect()
  if slua.isValid(self.teamupParticleEffect) then
    self.teamupParticleEffect:K2_DestroyComponent(self.teamupParticleEffect)
    self.teamupParticleEffect = nil
  end
  if self.teamupAudioID then
    local audio_util = require("client.common.audio_util")
    audio_util.StopSound(self.teamupAudioID)
    self.teamupAudioID = nil
  end
end
function LobbyAvatar:ShowTeamupAvatarNotice(notice_text, offset)
  if not notice_text or notice_text == "" then
    return
  end
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  self:ClearTeamupAvatarNotice()
  self.avatar_notice = UIManager.ShowUI(UIManager.UI_Config.Teamup_Avatar_Notice, notice_text, operateAvatar, offset)
end
function LobbyAvatar:ClearTeamupAvatarNotice()
  if not self.avatar_notice then
    return
  end
  self.avatar_notice:Close()
  self.avatar_notice = nil
end
function LobbyAvatar:HasWeaponStandbyAction()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return false, 0, 0
  end
  if not operateAvatar:IsHoldingWeapon() then
    log(bWriteLog and "LobbyAvatar:HasWeaponStandbyAction Trigger Standby Action Failed Reason : No Weapon")
    return false, 0, 43600
  end
  local Weapon = operateAvatar:GetHoldingWeapon()
  local StanbyActionID = Weapon:GetStandbyActionID()
  if StanbyActionID == 0 or StanbyActionID == nil then
    log(bWriteLog and "LobbyAvatar:HasWeaponStandbyAction Trigger Standby Action Failed Reason : Invalid ID")
    return false, 0, 43601
  end
  return true, StanbyActionID, 0
end
function LobbyAvatar:HasWeaponPoseReloadAction()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return false, 0, 0
  end
  if not operateAvatar:IsHoldingWeapon() then
    log(bWriteLog and "LobbyAvatar:HasWeaponPoseReloadAction Trigger Pose Reload Action Failed Reason : No Weapon")
    return false, 0, 43600
  end
  local Weapon = operateAvatar:GetHoldingWeapon()
  local PoseReloadActionID = Weapon:GetPoseReloadActionID()
  if PoseReloadActionID == 0 or PoseReloadActionID == nil then
    log(bWriteLog and "LobbyAvatar:HasWeaponPoseReloadAction Trigger Pose Reload Action Failed Reason : Invalid ID")
    return false, 0, 43601
  end
  return true, PoseReloadActionID, 0
end
function LobbyAvatar:HasWeaponHighlightAction()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return false, 0, 0
  end
  if not operateAvatar:IsHoldingWeapon() then
    log(bWriteLog and "LobbyAvatar:HasWeaponHighlightAction Trigger Highlight Action Failed Reason : No Weapon")
    return false, 0, 43600
  end
  local Weapon = operateAvatar:GetHoldingWeapon()
  local HighlightActionID = Weapon:GetHighlightActionID()
  if HighlightActionID == 0 or HighlightActionID == nil then
    log(bWriteLog and "LobbyAvatar:HasWeaponHighlightAction Trigger Highlight Action Failed Reason : Invalid ID")
    return false, 0, 43601
  end
  return true, HighlightActionID, 0
end
function LobbyAvatar:IsStopDelay(bStopDelay)
  if bStopDelay ~= nil then
    return bStopDelay
  end
  local nCurEmoteID = self:GetCurActionID()
  if nCurEmoteID <= 0 then
    return false
  end
  if self.PlayingChangeActionMap[nCurEmoteID] then
    return false
  end
  return false
end
local PreStopAvatarID = 0
local PreStopActionID = 0
function LobbyAvatar:StopAction(bStopDelay, bSkipCD)
  log(bWriteLog and "LobbyAvatar:StopAction bStopDelay:" .. tostring(bStopDelay) .. " bSkipCD:" .. tostring(bSkipCD) .. " _avatarID:" .. tostring(self._avatarID) .. " _preActionID:" .. tostring(self._preActionID))
  local UIUtil = require("client.common.ui_util")
  if not bSkipCD and not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.StopAction, false) and self._avatarID == PreStopAvatarID and self._preActionID == PreStopActionID then
    log(bWriteLog and "LobbyAvatar:StopAction CD return")
    return
  end
  PreStopAvatarID = self._avatarID
  PreStopActionID = self._preActionID
  self:StopTeamupEffect()
  local nCurEmoteID = self:GetCurActionID()
  if self.PlayingChangeActionMap[nCurEmoteID] then
    log(bWriteLog and "LobbyAvatar:StopAction Force EndActionHandle for " .. tostring(nCurEmoteID))
    self:OnEndActionHandle(nCurEmoteID)
  end
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  bStopDelay = self:IsStopDelay(bStopDelay)
  log(bWriteLog and "[LobbyAvatar] LobbyAvatar:StopAction bStopDelay = " .. tostring(bStopDelay))
  operateAvatar:CharStopEmoteByResId(bStopDelay)
end
function LobbyAvatar:PauseAnim(bPause)
  log(bWriteLog and string.format("LobbyAvatar:PauseAnim(%s)", bPause))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not operateAvatar.Mesh then
    return
  end
  operateAvatar.Mesh.bPauseAnims = bPause
end
function LobbyAvatar:StopActionCamera()
  log(bWriteLog and "LobbyAvatar:StopActionCamera()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:StopActionCamera()
end
function LobbyAvatar:PlayGodEffect(index)
  log(bWriteLog and string.format("LobbyAvatar:PlayGodEffect(%s)", index))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  local useNewGodEffectLogic = HDmpveRemote.HDmpveRemoteConfigGetInt("GEnableNewGodEffect", 1)
  log_format("LobbyAvatar:PlayGodEffect. useNewGodEffectLogic=%s", useNewGodEffectLogic)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if slua.isValid(GameInstance) then
    GameInstance:ExecuteCMD("r.LobbyGodEffectUseNew", useNewGodEffectLogic)
  end
  operateAvatar:PlayGodEffect(index)
  local cfg = CDataTable.GetTableDataByFilter("SeasonGodEffect", "EffectID", index)
  log_format("LobbyAvatar:PlayGodEffect. cfg=%s", cfg)
  if cfg and cfg.AudioPath ~= "" then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(cfg.AudioPath, operateAvatar)
  end
end
function LobbyAvatar:UpdateGodEffectPosition()
  log(bWriteLog and "LobbyAvatar:UpdateGodEffectPosition()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  if operateAvatar.LobbyPlayerEffectComponent and operateAvatar.LobbyPlayerEffectComponent.UpdatePosition then
    operateAvatar.LobbyPlayerEffectComponent:UpdatePosition()
  end
end
function LobbyAvatar:StopGodEffect()
  log(bWriteLog and "LobbyAvatar:StopGodEffect()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  operateAvatar:StopGodEffect()
end
function LobbyAvatar:GetDebugInfoScreenPosition()
  log(bWriteLog and "LobbyAvatar:GetDebugInfoScreenPosition()")
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  local location = operateAvatar:K2_GetActorLocation()
  local UIUtil = require("client.common.ui_util")
  return UIUtil.ProjectWorldToScreen(location)
end
function LobbyAvatar:SetCanPlaySwitchWeapon(can)
  log(bWriteLog and "LobbyAvatar:SetCanPlaySwitchWeapon " .. tostring(can))
  self.CanPlaySwitchWeapon = can
end
function LobbyAvatar:TryPlaySwitchWeaponAction(resID, isUse, isAsync, SocketName)
  if not self.CanPlaySwitchWeapon then
    return
  end
  if type(self.CanPlaySwitchWeapon) == "number" then
    log(bWriteLog and "LobbyAvatar:TryPlaySwitchWeaponAction CanPlaySwitchWeapon = " .. tonumber(self.CanPlaySwitchWeapon))
    if self.CanPlaySwitchWeapon > 0 then
      self.CanPlaySwitchWeapon = self.CanPlaySwitchWeapon - 1
    else
      self.CanPlaySwitchWeapon = false
      return
    end
  end
  if not isUse then
    return
  end
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not operateAvatar.BP_LobbyWeaponManager then
    return
  end
  if operateAvatar.IsPlayingAction == true or operateAvatar.HeadIsVisible == false then
    return
  end
  local CurrentUseWeaponID = operateAvatar.BP_LobbyWeaponManager.CurUseWeaponID
  if not CurrentUseWeaponID or CurrentUseWeaponID <= 0 then
    log(bWriteLog and "LobbyAvatar:TryPlaySwitchWeaponAction not PreSkin")
    return
  end
  if not self:HasEquiped(CurrentUseWeaponID) then
    log(bWriteLog and "LobbyAvatar:TryPlaySwitchWeaponAction not equip PreSkin")
    return
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local actionCfg = ItemUpgradeMgr:GetSwitchWeaponAction(CurrentUseWeaponID, resID)
  if actionCfg then
    log(bWriteLog and "LobbyAvatar:TryPlaySwitchWeaponAction ID = " .. tostring(actionCfg.ID))
    if actionCfg.NeedCloth and actionCfg.NeedCloth ~= 0 and not self:HasEquiped(actionCfg.NeedCloth) then
      log(bWriteLog and "LobbyAvatar:TryPlaySwitchWeaponAction not EquipCloth " .. tostring(actionCfg.NeedCloth))
      return
    end
    ItemUpgradeMgr:SetSwitchWeaponActionPlan(operateAvatar:GetPlayerUID(), actionCfg.ID)
    if self:PlayAction(actionCfg.Action) then
      self.EmoteEquipmentMap[actionCfg.Action] = resID
      self.PlayingChangeActionMap[actionCfg.Action] = resID
      return true
    end
  end
end
function LobbyAvatar:PlayEmoteBeforePutOnEquipment(EmoteID, EquipItemID, tAvatarCustom)
  local operateAvatar = self:GetModel()
  local adaptActionID = EmoteID
  if slua.isValid(operateAvatar) then
    adaptActionID = _FindAdaptEmotionID(operateAvatar, EmoteID)
  end
  self.EmoteEquipmentMap[adaptActionID] = EquipItemID
  self.EmoteAvatarCustomMap[adaptActionID] = tAvatarCustom
  self.PlayingChangeActionMap[adaptActionID] = EquipItemID
  if not self:PlayAction(EmoteID, "Default") then
    self:OnEndActionHandle(adaptActionID)
  end
end
function LobbyAvatar:CheckAndExecuteChangeOperate(operateAvatar, itemID, tAvatarCustom)
  local tAllActionCfg = CDataTable.GetTableByFilter("StateChangeActionConfig", "AfterClothID", itemID)
  if not tAllActionCfg then
    return false
  end
  for _, tCurActionCfg in pairs(tAllActionCfg) do
    local nBeforeCloth = tCurActionCfg.BeforeClothID
    local nActionID = tCurActionCfg.ActionID
    if nBeforeCloth == 1407632 or nBeforeCloth == 1407668 then
      local NewActionID = self:CheckDowngradeEmoteResLevel(nActionID)
      log(bWriteLog and "LobbyAvatar:CheckAndExecuteChangeOperate Change action from: " .. nActionID .. " to: " .. NewActionID)
      nActionID = NewActionID
    end
    if operateAvatar:IsItemHasEquipped(nBeforeCloth) then
      if tCurActionCfg.IsPlayAnimAfterTransform == 1 then
        log(bWriteLog and "LobbyAvatar:CheckAndExecuteChangeOperate PutOnEquipmentAfterPlayEmote " .. tostring(itemID) .. " nActionID " .. tostring(nActionID))
        operateAvatar:PutOnEquipmentByResID(itemID, tAvatarCustom)
        operateAvatar.LobbyPlayEmoteComponent_BP.bSyncEmote = true
        self._SyncEmote = nActionID
        local adaptActionID = _FindAdaptEmotionID(operateAvatar, nActionID)
        self.PlayingChangeActionMap[adaptActionID] = itemID
        self:PlayAction(nActionID, "Default")
      else
        log(bWriteLog and "LobbyAvatar:CheckAndExecuteChangeOperate PlayEmoteBeforePutOnEquipment " .. tostring(itemID) .. " EmoteID " .. tostring(nActionID))
        self:PlayEmoteBeforePutOnEquipment(nActionID, itemID, tAvatarCustom)
      end
      return true
    elseif self:IsSwitchingState(nBeforeCloth) then
      log(bWriteLog and "LobbyAvatar:CheckAndExecuteChangeOperate SwitchingState PlayEmoteBeforePutOnEquipment " .. tostring(itemID) .. " EmoteID " .. tostring(nActionID))
      self:PlayEmoteBeforePutOnEquipment(nActionID, itemID, tAvatarCustom)
      return true
    end
  end
  return false
end
function LobbyAvatar:CheckDowngradeEmoteResLevel(nActionID)
  local bShouldDowngrade = false
  local UIUtil = require("client.common.ui_util")
  local gameInstance = UIUtil.GetGameInstance()
  if gameInstance and gameInstance.ShouldNotUseVTFResource then
    bShouldDowngrade = gameInstance:ShouldNotUseVTFResource()
    log(bWriteLog and "LobbyAvatar:CheckTempDowngradeEmoteResLevel bShouldDowngrade: " .. tostring(bShouldDowngrade))
  end
  if bShouldDowngrade then
    if nActionID == 12220494 then
      local NewActionID = 12220561
      local EmoteAnimCfg = CDataTable.GetTableData("EmoteBPTable", NewActionID)
      if EmoteAnimCfg then
        return NewActionID
      end
    elseif nActionID == 12220508 then
      local NewActionID = 12220562
      local EmoteAnimCfg = CDataTable.GetTableData("EmoteBPTable", NewActionID)
      if EmoteAnimCfg then
        return NewActionID
      end
    end
  end
  return nActionID
end
function LobbyAvatar:OnEndActionHandle(EmoteID)
  if self.IsPlayWeaponShow then
    self:HideGloveByWeaponShow(false)
    self.IsPlayWeaponShow = false
  end
  local putOnItemId = self.EmoteEquipmentMap[EmoteID]
  local tAvatarCustom = self.EmoteAvatarCustomMap[EmoteID]
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local operateAvatar = self:GetModel()
  if putOnItemId then
    log_warning(bWriteLog and "  LobbyAvatar:OnEndActionHandle. EmoteID: " .. tostring(EmoteID))
    if slua.isValid(operateAvatar) then
      local config = CDataTable.GetTableData("Item", putOnItemId)
      if config and config.ItemType == wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon then
        operateAvatar:CharEquipWeaponByResID(putOnItemId, true, false)
        operateAvatar:CharEquipWeaponPendant(putOnItemId, 2)
      else
        operateAvatar:PutOnEquipmentByResID(putOnItemId, tAvatarCustom)
      end
    end
    self.EmoteEquipmentMap[EmoteID] = nil
    self.EmoteAvatarCustomMap[EmoteID] = nil
  end
  self.PlayingChangeActionMap[EmoteID] = nil
  self:SetAvatarSyncWear(EmoteID, false)
  if self._SyncEmote == EmoteID then
    self._SyncEmote = 0
    operateAvatar.LobbyPlayEmoteComponent_BP.bSyncEmote = false
  end
end
function LobbyAvatar:IsSwitchingState(itemID)
  for _, EquipItemID in pairs(self.PlayingChangeActionMap) do
    if EquipItemID and EquipItemID == itemID then
      return true
    end
  end
  return false
end
function LobbyAvatar:ShowHighLevelClothEffect(AssetPath)
  log(bWriteLog and "LobbyAvatar:ShowHighLevelClothEffect AssetPath:" .. tostring(AssetPath))
  if not slua.isValid(self.HigLevelClothEffectComp) then
    local UParticleSystemComponent = import("/Script/Engine.ParticleSystemComponent")
    self.HigLevelClothEffectComp = Game:AddComponent(UParticleSystemComponent, self:GetModel(), "HigLevelClothEffectComp")
    self.HigLevelClothEffectComp:K2_AttachToComponent(self:GetModel().Mesh, "None", 1, 1, 1, false)
    self.HigLevelClothEffectComp:K2_SetRelativeLocation(FVector(0, 0, 0), false, nil, false)
    self.HigLevelClothEffectComp:SetTranslucentSortPriority(1)
  end
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(AssetPath, function(LoadObj)
    if slua.isValid(LoadObj) and slua.isValid(self.HigLevelClothEffectComp) then
      self.HigLevelClothEffectComp:Deactivate()
      self.HigLevelClothEffectComp:SetTemplate(LoadObj)
      self.HigLevelClothEffectComp:Activate(true)
      self.HigLevelClothEffectComp:SetVisibility(true, false)
    end
  end)
end
function LobbyAvatar:DestoryHighLevelClothEffect()
  log(bWriteLog and "LobbyAvatar:DestoryHighLevelClothEffect")
  if slua.isValid(self.HigLevelClothEffectComp) then
    self.HigLevelClothEffectComp:K2_DestroyComponent(self.HigLevelClothEffectComp)
    self.HigLevelClothEffectComp = nil
  end
end
function LobbyAvatar:TryShowHighLevelClothEffect()
  local equipmentsList = self:GetEquipments()
  log_tree("LobbyAvatar:TryShowHighLevelClothEffect equipmentsList", equipmentsList)
  local EffectType = LobbyAvatar.Const.EffectType.None
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  for key, equipment in pairs(equipmentsList) do
    local itemID = equipment.itemID
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemID})
    if state == PufferConst.ENUM_DownloadState.Done then
      local itemID = multi_state_manager:GetOriginClothIDAndState(itemID) or itemID
      local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
      if LogicXSuit.IsXSuit(itemID) then
        EffectType = LobbyAvatar.Const.EffectType.XSuit
        break
      end
      local ItemConfig = CDataTable.GetTableData("Item", itemID)
      if ItemConfig and ItemConfig.ItemQuality == 8 and ItemConfig.ItemSubType == 403 then
        EffectType = LobbyAvatar.Const.EffectType.GlodenSuit
      end
    else
      log(bWriteLog and "LobbyAvatar:TryShowHighLevelClothEffect ShowHighLevelCloth is not Download" .. tostring(itemID))
    end
  end
  self:ShowHighEffect(EffectType)
end
function LobbyAvatar:ShowHighEffect(EffectType)
  log(bWriteLog and "LobbyAvatar:ShowHighEffect EffectType" .. tostring(EffectType))
  local EffectPath, AudioPath
  if self.EffectType == EffectType then
    log(bWriteLog and "LobbyAvatar:ShowHighEffect self.EffectType == EffectType")
    return
  end
  self.  self:AddTimer(0, function()
    self.EffectType = LobbyAvatar.Const.EffectType.None
  end)
  if EffectType == LobbyAvatar.Const.EffectType.XSuit then
    EffectPath = "/Game/Arts_Effect/ParticleSystems/Share/P_Chart_Sheng_xjq_01.P_Chart_Sheng_xjq_01"
    AudioPath = "/Game/WwiseEvent/UI_hall/UI_Hall_270/Play_UI_Hall_Display_XSuit.Play_UI_Hall_Display_XSuit"
  elseif EffectType == LobbyAvatar.Const.EffectType.GlodenSuit then
    EffectPath = "/Game/Arts_Effect/ParticleSystems/Share/P_Chart_Jin_xjq_01.P_Chart_Jin_xjq_01"
    AudioPath = "/Game/WwiseEvent/UI_hall/UI_Hall_270/Play_UI_Hall_Display_Gilt.Play_UI_Hall_Display_Gilt"
  else
    return
  end
  self:ShowHighLevelClothEffect(EffectPath)
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(AudioPath)
end
function LobbyAvatar:SetPlayerUID(UID)
  local operateAvatar = self:GetModel()
  if slua.isValid(operateAvatar) then
    operateAvatar:SetPlayerUID(UID)
  end
end
function LobbyAvatar:SetNeedLookAtCamera(bNeed)
  local operateAvatar = self:GetModel()
  if slua.isValid(operateAvatar) then
    operateAvatar.NeedLookAtCam = bNeed
  end
end
function LobbyAvatar:GetCurHoldingWeaponSkinID()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "TryShowHighLevelClothEffect Error:Actor is nil.")
    return 0
  end
  if not operateAvatar.BP_LobbyWeaponManager then
    log(bWriteLog and "TryShowHighLevelClothEffect Error: WeaponManager is nil.")
    return 0
  end
  local curUsingWeapon = operateAvatar.BP_LobbyWeaponManager:GetUsingWeapon()
  if slua.isValid(curUsingWeapon) then
    return curUsingWeapon:GetItemDefineID().TypeSpecificID
  else
    return 0
  end
end
function LobbyAvatar:BuildWeaponPendantDownloadedHandler(UID, nWeaponSkinID, nPendantID)
  local IsHandlingWeapon = function(uWeapon)
    if not slua.isValid(uWeapon) then
      return false
    end
    local nCurWeaponSkinID = uWeapon:GetItemDefineID().TypeSpecificID
    if nCurWeaponSkinID ~= nWeaponSkinID then
      return false
    end
    return true
  end
  return function()
    local uOperatingAvatar = self:GetModel()
    if not slua.isValid(uOperatingAvatar) or uOperatingAvatar:GetPlayerUID() ~= UID then
      return
    end
    local uCurUsingWeapon = uOperatingAvatar:GetCurUsingWeapon()
    if not IsHandlingWeapon(uCurUsingWeapon) then
      local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
      for _, socketID in pairs(LobbyAvatarManager.Enum_WeaponAttachSlotID) do
        local uWeapon = uOperatingAvatar.BP_LobbyWeaponManager:GetWeaponBySocketID(socketID)
        if IsHandlingWeapon(uWeapon) then
          uCurUsingWeapon = uWeapon
          break
        end
      end
    end
    if not slua.isValid(uCurUsingWeapon) then
      return
    end
    local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
    if logic_weapon_pendant:GetWeaponPendantBySkinID(UID, nWeaponSkinID) ~= nPendantID then
      return
    end
    uCurUsingWeapon:EquipWeaponPandentByPandentId(nPendantID, 2)
  end
end
function LobbyAvatar:OnWeaponPendantChange(_, _, UID, groupID)
  print(bWriteLog and "LobbyAvatar:OnWeaponPendantChange UID:" .. tostring(UID) .. " groupID:" .. tostring(groupID))
  local operateAvatar = self:GetModel()
  local TriggerDownload = function(itemID, nWeaponSkinID)
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferSwitch = require("client.slua.logic.download.puffer_switch")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    if PufferODPakManager:GetStateByItemID(itemID) ~= PufferConst.ENUM_DownloadState.Done and not PufferSwitch.BanAutoDownload then
      local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
      logic_weapon_pendant:MarkDownload(UID, groupID, itemID)
      local params = {}
      local DownloadedHandler = self:BuildWeaponPendantDownloadedHandler(UID, nWeaponSkinID, itemID)
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {itemID}, nil, DownloadedHandler, params)
    end
  end
  if slua.isValid(operateAvatar) and operateAvatar:GetPlayerUID() == UID then
    local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    local curUsingWeapon = operateAvatar:GetCurUsingWeapon()
    if slua.isValid(curUsingWeapon) then
      local weaponSkinId = curUsingWeapon:GetItemDefineID().TypeSpecificID
      local weaponGroup = logic_weapon_pendant:GetGroupIDBySkinID(weaponSkinId)
      if weaponGroup == groupID and logic_weapon_pendant:CanSkinWithPendant(weaponSkinId) then
        local pendant = logic_weapon_pendant:GetWeaponPendantByGroupID(UID, groupID)
        curUsingWeapon:UnEquipWeaponPandent(2)
        if pendant and pendant ~= 0 then
          curUsingWeapon:EquipWeaponPandentByPandentId(pendant, 2)
        end
        TriggerDownload(pendant, weaponSkinId)
      end
    else
      print(bWriteLog and "LobbyAvatar:OnWeaponPendantChange curUsingWeapon not Valid")
    end
    for _, v in pairs(LobbyAvatarManager.Enum_WeaponAttachSlotID) do
      local weapon = operateAvatar.BP_LobbyWeaponManager:GetWeaponBySocketID(v)
      if slua.isValid(weapon) and slua.isValid(curUsingWeapon) and weapon ~= curUsingWeapon then
        local weaponSkinId = weapon:GetItemDefineID().TypeSpecificID
        if weaponSkinId ~= 0 then
          local weaponGroup = logic_weapon_pendant:GetGroupIDBySkinID(weaponSkinId)
          if weaponGroup == groupID and logic_weapon_pendant:CanSkinWithPendant(weaponSkinId) then
            local pendant = logic_weapon_pendant:GetWeaponPendantByGroupID(UID, groupID)
            weapon:UnEquipWeaponPandent(2)
            if pendant and pendant ~= 0 then
              weapon:EquipWeaponPandentByPandentId(pendant, 2)
            end
            TriggerDownload(pendant, weaponSkinId)
          end
        end
      end
    end
  end
end
function LobbyAvatar:SetHideFlag(flag)
  log(bWriteLog and string.format("LobbyAvatar:SetHideFlag. flag=%s", tostring(flag)))
  self._hideFlag = self._hideFlag | flag
end
function LobbyAvatar:RemoveHideFlag(flag)
  log(bWriteLog and string.format("LobbyAvatar:RemoveHideFlag. flag=%s", tostring(flag)))
  self._hideFlag = self._hideFlag & 1 ^ flag
end
function LobbyAvatar:ClearHideFlag()
  log(bWriteLog and "LobbyAvatar:ClearHideFlag.")
  self._hideFlag = 0
end
function LobbyAvatar:HasHideFlag()
  return self._hideFlag ~= 0
end
function LobbyAvatar:SetAvatarSync(bSync)
  local operateAvatar = self:GetModel()
  if operateAvatar and operateAvatar.CharacterAvatarComp2_BP then
    operateAvatar.CharacterAvatarComp2_BP.bSyncAvatar = bSync
  end
end
function LobbyAvatar:GetAvatarSync()
  local operateAvatar = self:GetModel()
  if operateAvatar then
    return operateAvatar.CharacterAvatarComp2_BP.bSyncAvatar
  end
  return false
end
function LobbyAvatar:SetAvatarSyncWear(ID, bSync)
  if CDataTable.GetTableData("item_sync_wear_config", ID) then
    self:SetAvatarSync(bSync)
  end
end
function LobbyAvatar:SendPreviewEffectSyncReq(itemID)
  if itemID and 0 < itemID then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetAllHallDepotItemDataByResID(itemID)
    if itemData and itemData.insID and 0 < itemData.insID then
      local TeamupHandler = require("client.network.Protocol.TeamupHandler")
      TeamupHandler.send_depot_common_puton_sync_team_req(itemData.insID)
    end
  end
end
local class = require("class")
local base = require("common.delegate_container")
local C_LobbyAvatar = class(base, nil, LobbyAvatar)
return C_LobbyAvatar