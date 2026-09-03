local TimeUtil = require("client.common.time_util")
local ModelDisplayer = {
  Enum_Status = {
    Avatar = 0,
    Model = 1,
    None = 2,
    CoupleAvatar = 3
  },
  Enum_StoreKey = {
    DEFAULT = "STORE_KEY_DEFAULT",
    MAIN_UI = "KEY_STORE_MAIN_UI",
    PREVIEW_UI = "KEY_STORE_PREVIEW_UI",
    PASS_UI = "KEY_STORE_PASS_UI"
  },
  Enum_ModelType = {
    Weapon = 0,
    Pet = 1,
    Common = 2
  },
  Const = {DefaultBackpack = 501003, Default3DDownloadModel = 66631479},
  avatar_has_emote_ = false,
  _showingData = nil,
  _ShowingModelType = -1,
  _showExtraData = {},
  _storeData = {},
  _inited = false,
  _characterID = 0,
  _disableSwitchChar = false,
  _needAutoRotate = false,
  _animHideFlag = false,
  _startTime = 0,
  _status = -1,
  _lastStatus = -1,
  _avatarInited = false,
  _mapEmotionEndCallback = {},
  _mapEmotionStartCallback = {},
  _isHide = false,
  _cachedWeaponData = nil,
  _initAvatarData = {},
  _showingAvatar = nil,
  _bPlayingWeapon = nil,
  _petModel = nil,
  _petHidePosition = {
    x = -5,
    y = -383,
    z = -24346
  },
  _disableSwitchToModel = false,
  _hideAvatarBeforeEmote = false,
  _displayEmoteID = 0,
  nUIRestrictZoneType = 0,
  sexCache = nil
}
local _DestroyShowingAvatar = function()
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:Destroy()
  ModelDisplayer._showingAvatar = nil
  EventSystem:unregistEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, ModelDisplayer._OnCameraSwitched)
end
local _DestroyShowingWeapon = function()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.SetForceResetRotation(false)
  MallSystemWeaponModelHandler.DestroyWeaponShowActor()
end
local _DestroyPet = function()
  if not ModelDisplayer._petModel then
    return
  end
  ModelDisplayer._petModel:Destroy()
  ModelDisplayer._petModel = nil
end
local _DestroyCoupleAvatar = function()
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.ItemPreview)
end
local _HandleSuitsConflict = function(ResID)
  local hatSlotIndex = 3
  local suitsCfg = CDataTable.GetTableData("AvatarSuitsTable", ResID)
  if not suitsCfg then
    return
  end
  local suitItems
  local ELobbyCharacterAnimType = import("ELobbyCharacterAnimType")
  local StringUtil = require("common.string_util")
  if ModelDisplayer._showingAvatar and ModelDisplayer._showingAvatar:GetModel() and ModelDisplayer._showingAvatar:GetModel().lobbyGender == ELobbyCharacterAnimType.ELobbyCharAnim_Boy then
    suitItems = StringUtil.Split(suitsCfg.MaleSuits, "|")
  else
    suitItems = StringUtil.Split(suitsCfg.FemaleSuits, "|")
  end
  if ModelDisplayer._showingAvatar and ModelDisplayer._showingAvatar:GetModel() and suitItems and suitItems[hatSlotIndex] ~= nil and tonumber(suitItems[hatSlotIndex]) > 0 then
    local EAvatarSlotType = import("EAvatarSlotType")
    ModelDisplayer._showingAvatar:GetModel():PutOffEquipmentBySlot(EAvatarSlotType.EAvatarSlotType_HatEquipemtSlot)
  end
end
local _HandleSex = function(sexType)
  if sexType == nil then
    log_warning("ModelDisplayer sexType missing")
    return
  end
  if ModelDisplayer._showingAvatar then
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    if sexType == 2 then
      ModelDisplayer.sexCache = ModelDisplayer.sexCache or ModelDisplayer._showingAvatar:GetSex()
      ModelDisplayer._showingAvatar:ShowSex(LobbyAvatarManager.Enum_Sex.Female)
    elseif sexType == 1 then
      ModelDisplayer.sexCache = ModelDisplayer.sexCache or ModelDisplayer._showingAvatar:GetSex()
      ModelDisplayer._showingAvatar:ShowSex(LobbyAvatarManager.Enum_Sex.Male)
    end
  end
end
local _InitAvatar = function()
  if ModelDisplayer._avatarInited == true then
    log("[LobbyAvatar][ModelDisplayer] _InitAvatar avatar already Init.")
    return
  end
  _DestroyShowingAvatar()
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  if ModelDisplayer._initAvatarData.characterID ~= nil and tonumber(ModelDisplayer._initAvatarData.characterID) > 0 then
    local NewCharacterAvatarSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterAvatarSystem)
    local avatarData = NewCharacterAvatarSystem:GetAvatarDataByCharacterID(ModelDisplayer._initAvatarData.characterID)
    if avatarData == nil then
      log_error("[LobbyAvatar][ModelDisplayer] _InitAvatar avatarData is nil, characterID is:" .. ModelDisplayer._initAvatarData.characterID)
      return
    end
    ModelDisplayer._characterID = ModelDisplayer._initAvatarData.characterID
    ModelDisplayer._showingAvatar = MultipleAvatarManager.CreateMultipleAvatar(avatarData, {
      x = -55,
      y = -383,
      z = -14347
    }, ModelDisplayer._initAvatarData.itemList, ModelDisplayer._initAvatarData.bWeaponSyncLoad, {
      x = -5,
      y = -383,
      z = -24346
    })
  else
    ModelDisplayer._showingAvatar = MultipleAvatarManager.CreateMultipleAvatar(DataMgr.avatarData, {
      x = -55,
      y = -383,
      z = -14347
    }, ModelDisplayer._initAvatarData.itemList, ModelDisplayer._initAvatarData.bWeaponSyncLoad, {
      x = -5,
      y = -383,
      z = -24346
    })
  end
  EventSystem:registEvent(EVENTTYPE_CAMERA, EVENTID_SCREEN_RATIO_CHANGED, ModelDisplayer._OnScreenSizeChanged)
  EventSystem:registEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, ModelDisplayer._OnCameraSwitched)
  ModelDisplayer._avatarInited = true
end
local _SwitchToCharacter = function(characterID)
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _SwitchToCharacter characterID:" .. tostring(characterID))
  local NewCharacterAvatarSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterAvatarSystem)
  NewCharacterAvatarSystem:SwitchCharacterModel(ModelDisplayer._showingAvatar, characterID)
  local avatarData = NewCharacterAvatarSystem:GetAvatarDataByCharacterID(characterID)
  if not avatarData or not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:ShowSex(avatarData.gamegender)
end
local _HideWeapon = function()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.HideWeapon()
end
function ModelDisplayer.GetPetShowPosition(petID)
  if not petID then
    return nil
  end
  local positionX = ModelDisplayer._showingAvatar._showPosition.x
  local positionY = ModelDisplayer._showingAvatar._showPosition.y
  local positionZ = ModelDisplayer._showingAvatar._showPosition.z - 91
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local cameraID = Lobby_camera_manager_module.currentCameraID
  local PetCameraID = tostring(petID) .. "_" .. tostring(cameraID)
  local offsetCfg = CDataTable.GetTableData("PetCameraOffset", PetCameraID)
  if offsetCfg then
    positionX = positionX + offsetCfg.XOffset
    positionY = positionY + offsetCfg.YOffset
    positionZ = positionZ + offsetCfg.ZOffset
  end
  return {
    x = positionX,
    y = positionY,
    z = positionZ
  }
end
local _AdjustPetModelPosByConfig = function(itemID)
  if not ModelDisplayer._petModel then
    return
  end
  local petLocation = ModelDisplayer.GetPetShowPosition(itemID)
  if not petLocation then
    log(bWriteLog and "[ModelDisplayer] _AdjustPetModelPosByConfig petLocation is nil. itemID=" .. tostring(itemID))
    return
  end
  ModelDisplayer._petModel:SetPosition(petLocation.x, petLocation.y, petLocation.z)
end
local _AdjustPetScaleByType = function()
  if not ModelDisplayer._petModel then
    return
  end
  local petType = ModelDisplayer._petModel:GetPetType()
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if not logic_pet:IsPetItemID(petType) then
    return
  end
  local scale = ModelDisplayer.GetPetScale(petType)
  if scale ~= nil then
    ModelDisplayer._petModel:SetScale(scale, scale, scale)
  end
end
local _RefreshOrCreatePetModel = function(itemID)
  local petID = itemID
  local config = CDataTable.GetTableData("PetDressTable", itemID)
  if config ~= nil then
    petID = config.PetID
  end
  log(bWriteLog and "[ModelDisplayer] ModelDisplayer._RefreshOrCreatePetModel petID " .. petID)
  local pet_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.pet_manager)
  local dressList = {}
  if itemID ~= petID then
    dressList[itemID] = {id = itemID}
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local ServerInfo = logic_pet:GetPetDataByPetItemID(petID)
  ServerInfo = ServerInfo or {}
  local PetData = logic_pet:FormatPetData(0, ServerInfo.id or petID, 0, dressList, ServerInfo.color, ServerInfo.change)
  local oldPetModel = ModelDisplayer._petModel
  ModelDisplayer._petModel = pet_manager:RefreshOrCreatePet(PetData, true, nil, oldPetModel)
  if ModelDisplayer._showExtraData then
    if ModelDisplayer._showExtraData.playBubbleIDList then
      ModelDisplayer._petModel:PlayBubble(ModelDisplayer._showExtraData.playBubbleIDList, true)
    else
      ModelDisplayer._petModel:StopBubble()
    end
    if ModelDisplayer._showExtraData.playSwitchEffectIDList then
      ModelDisplayer._petModel:PlaySwitchEffect(ModelDisplayer._showExtraData.playSwitchEffectIDList, true)
    else
      ModelDisplayer._petModel:StopSwitchEffect()
    end
  end
  ModelDisplayer._petModel:SetPetShowType(logic_pet.ENUM_PetShowType.Preview)
  ModelDisplayer._petModel:EnableRotation(true)
  ModelDisplayer._petModel:SetRotation(0, 0, 90)
  ModelDisplayer._petModel:EnableIdleRandomAction(false)
  _AdjustPetScaleByType()
  _AdjustPetModelPosByConfig(itemID)
end
local _HidePetModel = function()
  if not ModelDisplayer._petModel then
    return
  end
  ModelDisplayer._petModel:SetPosition(ModelDisplayer._petHidePosition.x, ModelDisplayer._petHidePosition.y, ModelDisplayer._petHidePosition.z, true)
  ModelDisplayer._petModel:StopSwitchEffect()
  ModelDisplayer._petModel:StopBubble()
end
local _IsNotInitedYet = function()
  return not ModelDisplayer._inited
end
local _SetShowModuleID = function(newItemID)
  ModelDisplayer._showingData.showModelId = newItemID
end
local _GetShowModuleID = function()
  if not ModelDisplayer._showingData then
    return 0
  end
  return ModelDisplayer._showingData.showModelId
end
local _Init = function(itemList, characterID, bWeaponSyncLoad, bJumpOverCreateAvatar)
  ModelDisplayer._inited = true
  ModelDisplayer._isHide = false
  ModelDisplayer._cachedWeaponData = nil
  ModelDisplayer._initAvatarData = {
    itemList = itemList,
    characterID = characterID,
      }
  ModelDisplayer._status = ModelDisplayer.Enum_Status.Avatar
  if bJumpOverCreateAvatar then
  else
    _InitAvatar()
  end
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.SetForceResetRotation(true)
end
local _InitShowingData = function()
  if ModelDisplayer._showingData ~= nil then
    return
  end
  local super_data = require("common.super_data")
  ModelDisplayer._showingData = super_data.CreateSuperData({showModelId = 0})
end
local _ResetShowingData = function()
  if not ModelDisplayer._showingData then
    return
  end
  _SetShowModuleID(0)
end
local _StartDisplayTimerCount = function()
  local getTime = slua.getMicroseconds
  ModelDisplayer._startTime = getTime()
end
local _EndDisplayTimerCount = function(nItemId)
  local getTime = slua.getMicroseconds
  local endTime = getTime()
  local costTIme = (endTime - ModelDisplayer._startTime) / 1000
  ModelDisplayer._startTime = 0
  local itemInfo = "item"
  if nItemId and math.tointeger(nItemId) then
    itemInfo = "item(" .. tostring(nItemId) .. ")"
  end
  log(bWriteLog and string.format("TimeTracer [Avatar][LobbyAvatar][ModelDisplayer._EndDisplayTimerCount] bSync=true Pool=false itemInfo:%s time:[%.3fms]", itemInfo, costTIme))
end
local _Show3DModel = function(itemID, extraData)
  if itemID == nil or itemID == 0 then
    log("[LobbyAvatar][ModelDisplayer] _Show3DModel with 0 itemID")
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg == nil then
    return
  end
  local needRotation = true
  local itemType = itemCfg.ItemType
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsWeapon(itemType) then
    MallSystemWeaponModelHandler.SetForceResetRotation(true)
  end
  if ModelDisplayTypeHelper.Is3DEffect(itemType) then
    needRotation = false
  end
  MallSystemWeaponModelHandler.ShowWeaponByResId(itemID, true, true, ModelDisplayer._needAutoRotate or false, false, needRotation, extraData)
end
local _SwitchStatus = function(status)
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _SwitchStatus " .. tostring(status) .. " ")
  if status == ModelDisplayer.Enum_Status.Model and ModelDisplayer._disableSwitchToModel then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _SwitchStatus _disableSwitchToModel is true")
    if ModelDisplayer._ShowingModelType ~= ModelDisplayer.Enum_ModelType.Pet then
      _HidePetModel()
    end
    return
  end
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local lastStatus = ModelDisplayer._status
  ModelDisplayer._  if ModelDisplayer._status ~= ModelDisplayer.Enum_Status.None then
    ModelDisplayer._isHide = false
  end
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetCoupleAvatar(CoupleAvatarSystem.ESceneType.ItemPreview)
  if status == ModelDisplayer.Enum_Status.Avatar then
    _InitAvatar()
    if not ModelDisplayer._hideAvatarBeforeEmote then
      ModelDisplayer.ShowAvatar()
    end
    if ModelDisplayer._cachedWeaponData and lastStatus == ModelDisplayer.Enum_Status.Model then
      ModelDisplayer.PutOnOrPutoff(ModelDisplayer._cachedWeaponData.itemID, ModelDisplayer._cachedWeaponData.bWear, ModelDisplayer._cachedWeaponData.extraData)
      ModelDisplayer._cachedWeaponData = nil
    end
    _HideWeapon()
    _HidePetModel()
    if CoupleAvatar then
      CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.ItemPreview)
    end
  elseif status == ModelDisplayer.Enum_Status.Model then
    ModelDisplayer.HideAvatar()
    if ModelDisplayer._ShowingModelType == ModelDisplayer.Enum_ModelType.Pet then
      _HideWeapon()
      _RefreshOrCreatePetModel(_GetShowModuleID())
    else
      _HidePetModel()
      if MallSystemWeaponModelHandler.GetShowingId() ~= _GetShowModuleID() then
        _Show3DModel(_GetShowModuleID(), ModelDisplayer._showExtraData)
      end
    end
    if CoupleAvatar then
      CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.ItemPreview)
    end
  elseif status == ModelDisplayer.Enum_Status.CoupleAvatar then
    ModelDisplayer.HideAvatar()
    _HideWeapon()
    _HidePetModel()
  elseif status == ModelDisplayer.Enum_Status.None then
    ModelDisplayer.HideAvatar()
    if CoupleAvatar then
      CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.ItemPreview)
    end
    _HideWeapon()
    _HidePetModel()
  end
end
local _DisplayAvatar = function(itemID, bWear, extraData)
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _DisplayAvatar itemID:" .. tostring(itemID) .. " _disableSwitchChar:" .. tostring(ModelDisplayer._disableSwitchChar))
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  ModelDisplayer._ShowingModelType = -1
  _SwitchStatus(ModelDisplayer.Enum_Status.Avatar)
  local CharacterID = CharacterUtils:GetCharacterIDByItemID(itemID)
  if 0 < CharacterID or ModelDisplayer._disableSwitchChar then
    _SetShowModuleID(itemID)
    if CharacterID == ModelDisplayer._characterID or ModelDisplayer._disableSwitchChar and ModelDisplayer._characterID and 0 < ModelDisplayer._characterID then
    else
      ModelDisplayer._characterID = CharacterID
      if ModelDisplayer._characterID and 0 < ModelDisplayer._characterID then
        _SwitchToCharacter(ModelDisplayer._characterID)
      end
    end
    ModelDisplayer._showingAvatar:ShowAvatar()
    _HideWeapon()
    _HidePetModel()
  else
    ModelDisplayer.RestoreCharacter()
  end
  ModelDisplayer.PutOnOrPutoff(itemID, bWear, extraData)
end
local _DisplayCommonModel = function(itemID, itemType, subType, extraData)
  local RefitVehicle = require("client.logic.vehicle.logic_refit_vehicle")
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsRefitVehicle(itemID) then
    _SetShowModuleID(itemID)
    extraData = extraData or {}
    extraData.ExtraTable = extraData.ExtraTable or {}
    extraData.ExtraTable.is_refit_vehicle = true
    extraData.ExtraTable.refit_vehicle_no_possess = true
    extraData.ExtraTable.refit_vehicle_no_autoplay = true
    extraData.ExtraTable.refit_vehicle_cast_shadow = true
    local source = extraData.ExtraTable.Source
    _Show3DModel(itemID, extraData)
    local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
    RefitVehicle.EquipStyle(actor:GetrefitVehicleActor(), itemID, source)
  elseif ModelDisplayTypeHelper.IsParachute(itemType, subType) then
    _SetShowModuleID(itemID)
    MallSystemWeaponModelHandler.SetForceResetRotation(false)
    extraData = extraData or {}
    extraData.ExtraTable = extraData.ExtraTable or {}
    extraData.ExtraTable.lock_x_rotation = true
    extraData.forceDisplay = true
    _Show3DModel(itemID, extraData)
  elseif ModelDisplayTypeHelper.IsVehicle(itemType) == true then
    _SetShowModuleID(itemID)
    MallSystemWeaponModelHandler.SetForceResetRotation(false)
    _Show3DModel(itemID, extraData)
  elseif ModelDisplayTypeHelper.IsGrenade(itemType, subType) then
    _SetShowModuleID(itemID)
    MallSystemWeaponModelHandler.SetForceResetRotation(true)
    _Show3DModel(itemID, extraData)
  elseif ModelDisplayTypeHelper._IsIcon3D(itemType, subType, itemID) then
    _SetShowModuleID(itemID)
    _Show3DModel(itemID, extraData)
    local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
    if slua.isValid(actor) then
      actor.CanRotateBack = false
    end
  elseif ModelDisplayTypeHelper.IsMiniTv(itemType) then
    _SetShowModuleID(itemID)
    _Show3DModel(itemID, extraData)
  elseif ModelDisplayTypeHelper.IsHolography(itemType) then
    _SetShowModuleID(itemID)
    _Show3DModel(itemID, extraData)
  elseif ModelDisplayTypeHelper.IsStatue(itemType) then
    _SetShowModuleID(itemID)
    _Show3DModel(itemID, extraData)
  elseif ModelDisplayTypeHelper.IsHome3DAsset(itemType, subType) then
    _SetShowModuleID(itemID)
    _Show3DModel(itemID, extraData)
  elseif ModelDisplayTypeHelper.Is3DModelType(itemID) then
    if ModelDisplayTypeHelper.IsMileStone(subType) then
      extraData = extraData or {}
      extraData.SetRotateBackZ = true
    end
    local bpCfg = CDataTable.GetTableData("3DIconBPTable", itemID)
    if bpCfg then
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemID})
      if state ~= PufferConst.ENUM_DownloadState.Done then
        itemID = ModelDisplayer.Const.Default3DDownloadModel
      end
    end
    _SetShowModuleID(itemID)
    _Show3DModel(itemID, extraData)
  elseif ModelDisplayTypeHelper.Is3DEffect(itemType, subType) then
    _SetShowModuleID(itemID)
    _Show3DModel(itemID, extraData)
    local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
    if slua.isValid(actor) then
      actor:SetCanTouchRotate(false)
    end
  end
  ModelDisplayer._ShowingModelType = ModelDisplayer.Enum_ModelType.Common
  _SwitchStatus(ModelDisplayer.Enum_Status.Model)
end
local _DisplaySpecialModel = function(itemID, itemType, subType, bWear, extraData)
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if not ModelDisplayTypeHelper.IsWeapon(itemType) and not ModelDisplayTypeHelper.IsBagWidget(itemType, subType) then
    return
  end
  ModelDisplayer._ShowingModelType = ModelDisplayer.Enum_ModelType.Weapon
  local isDownloadFinish = false
  if extraData and extraData.downloadFinish then
    isDownloadFinish = true
  end
  if extraData and extraData.bPlayingWeapon then
    ModelDisplayer._bPlayingWeapon = extraData.bPlayingWeapon
  end
  if extraData and extraData.bForceCharacter then
    ModelDisplayer.PutOnOrPutoff(itemID, bWear, extraData)
    if ModelDisplayer._cachedWeaponData and ModelDisplayer._cachedWeaponData.itemID == itemID then
      ModelDisplayer._cachedWeaponData = nil
    end
    return
  elseif ModelDisplayer._status ~= ModelDisplayer.Enum_Status.Model or isDownloadFinish then
    ModelDisplayer.PutOnOrPutoff(itemID, bWear, extraData)
    ModelDisplayer.SwitchToAvatar()
    return
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bHasEquiped = ModelDisplayer.HasEquiped(itemID)
  if bWear and not bHasEquiped and ModelDisplayer._showingAvatar then
    ModelDisplayer._showingAvatar:PutoffSubtype(wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon)
  end
  ModelDisplayer._cachedWeaponData = {
    itemID = itemID,
    bWear = bWear,
      }
  if ModelDisplayTypeHelper.IsDIYWeapon(itemID) then
    extraData = extraData or {}
    extraData.ExtraTable = extraData.ExtraTable or {}
    extraData.ExtraTable.show_model_is_diy_weapon = true
  end
  _Show3DModel(itemID, extraData)
  ModelDisplayer.SwitchToModel()
end
local _Display2DModel = function()
  ModelDisplayer._ShowingModelType = -1
  _SwitchStatus(ModelDisplayer.Enum_Status.None)
end
local _DisplayEmotion = function(itemID, extraData)
  if extraData and extraData.bPlayingWeapon then
    ModelDisplayer._bPlayingWeapon = extraData.bPlayingWeapon
  end
  _DisplayAvatar(itemID)
  if extraData and extraData.enableCameraAnim == true then
    ModelDisplayer.EnableEmotionCameraAnim(true)
  else
    ModelDisplayer.EnableEmotionCameraAnim(false)
  end
  ModelDisplayer.SetSyncEmote(itemID)
  local actionExtraInfo
  if extraData and extraData.coupleEquipments and type(extraData.coupleEquipments) == "string" then
    actionExtraInfo = extraData.coupleEquipments
  elseif extraData and extraData.ActionExtraData then
    actionExtraInfo = extraData.ActionExtraData
  end
  ModelDisplayer._showingAvatar:PlayAction(itemID, actionExtraInfo)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local fromType = LobbyAvatarManager.Enum_SoundFrom.Mall
  if extraData and extraData.soundFromType then
    fromType = extraData.soundFromType
  end
  LobbyAvatarManager.PlayEmotionSound(itemID, ModelDisplayer._showingAvatar:GetSex(), 0, DataMgr.roleData.uid, fromType)
end
local _DisplayBrand = function(itemID, extraData)
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  LogicShowBrand:SetPreviewModeId(itemID)
  _DisplayEmotion(ShowBrandConst.GeneralEmoteId, extraData)
end
local _DisplayPet = function()
  ModelDisplayer._ShowingModelType = ModelDisplayer.Enum_ModelType.Pet
  _SwitchStatus(ModelDisplayer.Enum_Status.Model)
end
local _DisplayPartnerStance = function(itemID, extraData)
  local SelfWear, FriendWear, UseProfileWear
  if extraData and extraData.partnerStanceData then
    SelfWear = extraData.partnerStanceData.SelfWear
    FriendWear = extraData.partnerStanceData.FriendWear
    UseProfileWear = extraData.partnerStanceData.UseProfileWear
  end
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetOrCreateCoupleAvatar(CoupleAvatarSystem.ESceneType.ItemPreview)
  local tExtraData = {
    PoseItemID = itemID,
    bPlayCoupleAnim = true,
    SelfWear = SelfWear,
    FriendWear = FriendWear,
    UseProfileWear = UseProfileWear,
    nFriendUId = DataMgr.roleData.uid,
    bIsShowFriend = true
  }
  CoupleAvatar:UpdateAvatar(DataMgr.roleData.uid, tExtraData)
  _SwitchStatus(ModelDisplayer.Enum_Status.CoupleAvatar)
end
local _DisplayAdditionEffect = function(itemID, itemType, subType, extraData)
  _DisplayAvatar(itemID)
  if not ModelDisplayer._showingAvatar then
    log(bWriteLog and "ModelDisplayer._DisplayAdditionEffect return not _showingAvatar")
    return
  end
  local previewEmote = 22010056
  if extraData and extraData.previewEmote then
    previewEmote = extraData.previewEmote
  end
  local model = ModelDisplayer._showingAvatar:GetModel()
  if not slua.isValid(model) then
    log(bWriteLog and "ModelDisplayer._DisplayAdditionEffect return not model")
    return
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsWakeFlame(itemType, subType) then
    model:PreviewMoveEffect(itemID, previewEmote)
  end
  if ModelDisplayTypeHelper.IsFootprints(itemType, subType) then
    model:PreviewFootStepEffect(itemID, previewEmote)
  end
end
local _DisplayByType = function(itemID, bWear)
  log(bWriteLog and string.format("[LobbyAvatar][ModelDisplayer] _DisplayByType(%s, %s)", itemID, bWear))
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    return
  end
  local itemType = itemCfg.ItemType
  local subType = itemCfg.ItemSubType
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper._IsCommonModel(itemID, itemType, subType) then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _DisplayByType(CommonModel)")
    _SetShowModuleID(itemID)
    _DisplayCommonModel(itemID, itemType, subType, ModelDisplayer._showExtraData)
  elseif ModelDisplayTypeHelper._IsSpecialModel(itemType, subType) then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _DisplayByType(SpecialModel)")
    _SetShowModuleID(itemID)
    _DisplaySpecialModel(itemID, itemType, subType, bWear, ModelDisplayer._showExtraData)
  elseif ModelDisplayTypeHelper._Is2DModel(itemType, subType) then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _DisplayByType(2DModel)")
    _SetShowModuleID(itemID)
    _Display2DModel()
  elseif ModelDisplayTypeHelper.IsEmotion(itemType) then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _DisplayByType(Emotion)")
    if subType == ENUM_ITEM_SUBTYPE.BrandTemplate then
      _DisplayBrand(itemID, ModelDisplayer._showExtraData)
    else
      _DisplayEmotion(itemID, ModelDisplayer._showExtraData)
    end
  elseif ModelDisplayTypeHelper.IsPet(itemType) or ModelDisplayTypeHelper.IsPetSkin(itemType) == true then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _DisplayByType(Pet or PetSkin)")
    _SetShowModuleID(itemID)
    _DisplayPet()
  elseif ModelDisplayTypeHelper.IsLobbyPartnerStance(itemType) then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _DisplayByType(PartnerStance)")
    _DisplayPartnerStance(itemID, ModelDisplayer._showExtraData)
  elseif ModelDisplayTypeHelper.IsAdditionEffect(itemType, subType) then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _DisplayByType(AdditionEffect)")
    _DisplayAdditionEffect(itemID, itemType, subType, ModelDisplayer._showExtraData)
  else
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] _DisplayByType(default)")
    _SetShowModuleID(itemID)
    _DisplayAvatar(itemID, bWear, ModelDisplayer._showExtraData)
  end
end
local _HandleDisplayAirCast = function(nItemID)
  local itemCfg = CDataTable.GetTableData("Item", nItemID)
  if not itemCfg then
    return
  end
  if not ModelDisplayer._showingAvatar then
    return
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsGlideByItemID(nItemID) then
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    ModelDisplayer._showingAvatar:PutoffSubtype(wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon)
    ModelDisplayer._cachedWeaponData = nil
  end
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  if nItemID == 12204801 or wardrobeData.IsAirCastType(itemCfg.ItemSubType) then
    return
  end
  ModelDisplayer._showingAvatar:PutoffSubtype(ENUM_ITEM_SUBTYPE.Glider_Slot_415)
end
local _HandleDisplayRoleSex = function(itemCfg, bNotShowSexInMall)
  if bNotShowSexInMall then
    return
  end
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  if NewCharacterNetSystem:CurRoleIsCharacter() then
    ModelDisplayer.sexCache = nil
    return
  end
  if 0 == itemCfg.ShowSexInMall and ModelDisplayer.sexCache ~= nil then
    _HandleSex(ModelDisplayer.sexCache)
    ModelDisplayer.sexCache = nil
  else
    _HandleSex(itemCfg.ShowSexInMall)
  end
end
function ModelDisplayer.Init(itemList, characterID, bWeaponSyncLoad, bJumpOverCreateAvatar)
  if ModelDisplayer._inited == true then
    log("[LobbyAvatar][ModelDisplayer] ModelDisplayer.Init already Init.")
    return
  end
  log(bWriteLog and string.format("[LobbyAvatar][ModelDisplayer] ModelDisplayer.Init(%s, %s, %s, %s)", itemList, characterID, bWeaponSyncLoad, bJumpOverCreateAvatar))
  _InitShowingData()
  ModelDisplayer.Destroy(true)
  _Init(itemList, characterID, bWeaponSyncLoad, bJumpOverCreateAvatar)
end
function ModelDisplayer.RegistGetUIRestrictZoneFunc(Func, Type)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.RegistGetUIRestrictZoneFunc(Func, Type)
  ModelDisplayer.nUIRestrictZoneType = Type and Type or 0
end
function ModelDisplayer.registDefaultZoneFunc()
  local GetUIRestricZoneFunc = function()
    return {
      L = 0,
      R = 0,
      U = 0,
      D = 0
    }
  end
  ModelDisplayer.RegistGetUIRestrictZoneFunc(GetUIRestricZoneFunc)
end
function ModelDisplayer.GetUIRestrictZoneType()
  return ModelDisplayer.nUIRestrictZoneType
end
function ModelDisplayer.Destroy(bFromInit)
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer] ModelDisplayer.Destroy")
  _DestroyShowingAvatar()
  _DestroyShowingWeapon()
  _DestroyPet()
  _DestroyCoupleAvatar()
  _ResetShowingData()
  if not bFromInit then
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    MallSystemWeaponModelHandler.RemoveUIRestrictZone()
  end
  ModelDisplayer._characterID = 0
  ModelDisplayer._disableSwitchChar = false
  ModelDisplayer._inited = false
  ModelDisplayer._avatarInited = false
  ModelDisplayer._needAutoRotate = false
  ModelDisplayer._disableSwitchToModel = false
  ModelDisplayer._hideAvatarBeforeEmote = false
  ModelDisplayer._mapEmotionEndCallback = {}
  ModelDisplayer._mapEmotionStartCallback = {}
end
function ModelDisplayer.Show(bForceShow)
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer] ModelDisplayer.Show")
  if _IsNotInitedYet() then
    log_error("[LobbyAvatar][ModelDisplayer] ModelDisplayer.Show is not init yet")
    return
  end
  if not ModelDisplayer._isHide and not bForceShow then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] ModelDisplayer.Show is Already show")
    return
  end
  ModelDisplayer._isHide = false
  _SwitchStatus(ModelDisplayer._lastStatus)
end
function ModelDisplayer.Hide()
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer] ModelDisplayer.Hide")
  if _IsNotInitedYet() then
    log_error("[LobbyAvatar][ModelDisplayer] ModelDisplayer.Hide is not init yet")
    return
  end
  if ModelDisplayer._isHide then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] ModelDisplayer.Hide is Already hidden")
    return
  end
  ModelDisplayer._isHide = true
  ModelDisplayer._lastStatus = ModelDisplayer._status
  _SwitchStatus(ModelDisplayer.Enum_Status.None)
end
function ModelDisplayer._OnlyHide()
  _SwitchStatus(ModelDisplayer.Enum_Status.None)
end
function ModelDisplayer.Display(itemID, bWear, extraData)
  log(bWriteLog and string.format("[LobbyAvatar][ModelDisplayer] ModelDisplayer.Display(%s, %s, %s)", itemID, bWear, extraData))
  if _IsNotInitedYet() then
    log_error("[LobbyAvatar][ModelDisplayer] ModelDisplayer.Display is not init yet")
    return
  end
  _StartDisplayTimerCount()
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    return
  end
  ModelDisplayer._showExtraData = extraData
  _HandleDisplayAirCast(itemID)
  _HandleDisplayRoleSex(itemCfg, extraData and extraData.bNotShowSexInMall)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.SetForceResetRotation(true)
  _DisplayByType(itemID, bWear)
  _EndDisplayTimerCount(itemID)
end
function ModelDisplayer.GetShowingData()
  if ModelDisplayer._showingData == nil then
    _InitShowingData()
  end
  return ModelDisplayer._showingData
end
function ModelDisplayer.GetShowModelId()
  return _GetShowModuleID()
end
function ModelDisplayer.GetShowingStatus()
  return ModelDisplayer._status
end
function ModelDisplayer.GetShowingModelType()
  return ModelDisplayer._ShowingModelType
end
function ModelDisplayer.SwitchToAvatar()
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer] ModelDisplayer.SwitchToAvatar")
  if _IsNotInitedYet() then
    log_error("[LobbyAvatar][ModelDisplayer] ModelDisplayer.SwitchToAvatar is not init yet")
    return
  end
  _SwitchStatus(ModelDisplayer.Enum_Status.Avatar)
  EventSystem:postEvent(EVENTTYPE_MODELDISPLAY, EVENTID_MODELDISPLAY_SWITCH_TO_AVATAR)
end
function ModelDisplayer.SwitchToModel()
  if _IsNotInitedYet() then
    log_error("[LobbyAvatar][ModelDisplayer] ModelDisplayer.SwitchToModel is not init yet")
    return
  end
  ModelDisplayer._ShowingModelType = ModelDisplayer.Enum_ModelType.Weapon
  _SwitchStatus(ModelDisplayer.Enum_Status.Model)
  EventSystem:postEvent(EVENTTYPE_MODELDISPLAY, EVENTID_MODELDISPLAY_SWITCH_TO_MODEL)
end
function ModelDisplayer.SwitchToPet()
  if _IsNotInitedYet() then
    log_error("[LobbyAvatar][ModelDisplayer] ModelDisplayer.SwitchToPet is not init yet")
    return
  end
  ModelDisplayer._ShowingModelType = ModelDisplayer.Enum_ModelType.Pet
  _SwitchStatus(ModelDisplayer.Enum_Status.Model)
end
function ModelDisplayer.CreateAvatar()
  _InitAvatar()
end
function ModelDisplayer.ShowAvatar()
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:ShowAvatar()
end
function ModelDisplayer.HideAvatar()
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:HideAvatar()
end
function ModelDisplayer.HideAircraft()
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer.GetShowingAvatar():SetCanRotate(true)
  ModelDisplayer._showingAvatar:PutoffSubtype(ENUM_ITEM_SUBTYPE.Glider_Slot_415)
end
function ModelDisplayer.GetShowingAvatar()
  return ModelDisplayer._showingAvatar
end
function ModelDisplayer.ReloadAvatarSlot(slotID, reloadType, isRebuildAvatarSyncData)
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:ReloadAvatarSlot(slotID, reloadType, isRebuildAvatarSyncData)
end
function ModelDisplayer.PutOnOrPutoff(itemID, bWear, extraData)
  log(bWriteLog and "[SY]ModelDisplayer.PutOnOrPutoff." .. itemID)
  if not ModelDisplayer._showingAvatar then
    return
  end
  if bWear ~= nil then
    if bWear then
      _HandleSuitsConflict(itemID)
      ModelDisplayer._showingAvatar:PutonEquipment(itemID, nil, extraData)
    else
      ModelDisplayer._showingAvatar:PutoffEquipment(itemID)
    end
  elseif ModelDisplayer._showingAvatar:HasEquiped(itemID) == true then
    ModelDisplayer._showingAvatar:PutoffEquipment(itemID)
  else
    _HandleSuitsConflict(itemID)
    ModelDisplayer._showingAvatar:PutonEquipment(itemID, nil, extraData)
  end
end
function ModelDisplayer.StopAction()
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._hideAvatarBeforeEmote = false
  ModelDisplayer._showingAvatar:StopAction()
end
function ModelDisplayer.StopActionCamera()
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:StopActionCamera()
end
function ModelDisplayer.SetShowPosition(x, y, z)
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:SetShowPosition(x, y, z)
end
function ModelDisplayer.PutOnDefaultBackpack()
  local showingAvatar = ModelDisplayer.GetShowingAvatar()
  if not showingAvatar then
    return 0
  end
  local showingAvatarModel = showingAvatar:GetModel()
  if not showingAvatarModel then
    return 0
  end
  local wearBackpackId = showingAvatarModel:GetEquipmentInfoBySlot(8)
  if wearBackpackId ~= 0 then
    return wearBackpackId
  end
  ModelDisplayer.PutOnOrPutoff(ModelDisplayer.Const.DefaultBackpack, true)
  return ModelDisplayer.Const.DefaultBackpack
end
function ModelDisplayer.PutonEquipment(itemID, tAvatarCustom)
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:PutonEquipment(itemID, tAvatarCustom)
end
function ModelDisplayer.PutoffEquipment(itemID)
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:PutoffEquipment(itemID)
end
function ModelDisplayer.HasEquiped(itemID, tAvatarCustom)
  if not ModelDisplayer._showingAvatar then
    return
  end
  return ModelDisplayer._showingAvatar:HasEquiped(itemID, tAvatarCustom)
end
function ModelDisplayer.ClearEquipmentsExceptHairAndBeard()
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:ClearEquipmentsExceptHairAndBeard()
end
function ModelDisplayer.ShowSex(sexType, isInit)
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:ShowSex(sexType, isInit)
end
function ModelDisplayer.CopyMyEquipments(bUseMyChangeHeadInfo)
  if not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar:CopyMyEquipments(bUseMyChangeHeadInfo)
end
function ModelDisplayer.SwitchAvatarData(avatarData)
  if not avatarData or not ModelDisplayer._showingAvatar then
    return
  end
  ModelDisplayer._showingAvatar._curAvatarData = avatarData
end
function ModelDisplayer.SetDisableSwitchChar(disable)
  ModelDisplayer._disableSwitchChar = disable
end
function ModelDisplayer.SetDisableSwitchToModel(disable)
  ModelDisplayer._disableSwitchToModel = disable
end
function ModelDisplayer.GetDisableSwitchToModel()
  return ModelDisplayer._disableSwitchToModel
end
function ModelDisplayer.EnableEmotionCameraAnim(enable)
  if not ModelDisplayer._showingAvatar then
    return
  end
  local model = ModelDisplayer._showingAvatar:GetModel()
  if not slua.isValid(model) then
    return
  end
  if model.LobbyPlayEmoteComponent_BP == nil then
    return
  end
  if model.LobbyPlayEmoteComponent_BP.isPlayCameraAnim == nil then
    return
  end
  model.LobbyPlayEmoteComponent_BP.isPlayCameraAnim = enable
end
function ModelDisplayer.OnEmotionStart(actionID)
  local emotionStartCallback = ModelDisplayer._mapEmotionStartCallback[actionID]
  log(bWriteLog and "ModelDisplayer.OnEmotionStart actionID:" .. tostring(actionID) .. " _displayEmoteID:" .. tostring(ModelDisplayer._displayEmoteID) .. " emotionStartCallback:" .. tostring(emotionStartCallback))
  if emotionStartCallback ~= nil then
    emotionStartCallback(actionID)
    ModelDisplayer._mapEmotionStartCallback[actionID] = nil
  end
  if ModelDisplayer.GetHideAvatarBeforeEmote() then
    ModelDisplayer.HideAvatarBeforeEmote(false)
  end
end
function ModelDisplayer.ClearEmotionStartCallBack()
  if ModelDisplayer._mapEmotionStartCallback[ModelDisplayer._displayEmoteID] ~= nil then
    ModelDisplayer._mapEmotionStartCallback[ModelDisplayer._displayEmoteID] = nil
  end
end
function ModelDisplayer.OnEmotionEnd(actionID)
  local emotionEndCallback = ModelDisplayer._mapEmotionEndCallback[actionID]
  log(bWriteLog and "ModelDisplayer.OnEmotionEnd actionID:" .. tostring(actionID) .. " _displayEmoteID:" .. tostring(ModelDisplayer._displayEmoteID) .. " emotionEndCallback:" .. tostring(emotionEndCallback))
  if emotionEndCallback ~= nil then
    local Callback = emotionEndCallback.Callback
    local iCallBackNum = emotionEndCallback.iCallBackNum
    ModelDisplayer._mapEmotionEndCallback[actionID].iCallBackNum = iCallBackNum - 1
    log(bWriteLog and "ModelDisplayer.OnEmotionEnd Callback:" .. tostring(Callback) .. " iCallBackNum:" .. tostring(iCallBackNum))
    if iCallBackNum == 1 and Callback then
      log(bWriteLog and "ModelDisplayer.OnEmotionEnd Callback Success")
      Callback(actionID)
      ModelDisplayer._mapEmotionEndCallback[actionID] = nil
    end
  end
  ModelDisplayer._bPlayingWeapon = nil
  if ModelDisplayer.GetHideAvatarBeforeEmote() then
    ModelDisplayer.HideAvatarBeforeEmote(false)
  end
end
function ModelDisplayer.ClearEmotionEndCallBack()
  local emotionEndCallback = ModelDisplayer._mapEmotionEndCallback[ModelDisplayer._displayEmoteID]
  log(bWriteLog and "ModelDisplayer.ClearEmotionEndCallBack _displayEmoteID:" .. tostring(ModelDisplayer._displayEmoteID) .. " emotionStartCallback:" .. tostring(emotionEndCallback))
  if emotionEndCallback ~= nil and ModelDisplayer._bPlayingWeapon ~= nil then
    ModelDisplayer._mapEmotionEndCallback[ModelDisplayer._displayEmoteID] = nil
  end
  ModelDisplayer._bPlayingWeapon = nil
end
function ModelDisplayer.SetNeedAutoRotate(needAutoRotate)
  ModelDisplayer._end
function ModelDisplayer.GetPetModel()
  return ModelDisplayer._petModel
end
function ModelDisplayer.PlayPetAction(value)
  if _IsNotInitedYet() or not ModelDisplayer._petModel then
    return
  end
  ModelDisplayer._petModel:PlayAction(value)
end
function ModelDisplayer.PlayPetFeature(bSkipSync)
  if _IsNotInitedYet() or not ModelDisplayer._petModel then
    return
  end
  ModelDisplayer._petModel:PlayPetFeature(bSkipSync)
end
function ModelDisplayer.GetPetScale(petType)
  print(bWriteLog and "ModelDisplayer.GetPetScale:", petType)
  local ScaleConfig = CDataTable.GetTableData("PetScaleTable", petType)
  local Scale = 1
  if ScaleConfig and ScaleConfig.PreviewScale_f and ScaleConfig.BaseScale_f then
    Scale = ScaleConfig.PreviewScale_f * ScaleConfig.BaseScale_f
  end
  return Scale
end
function ModelDisplayer.ShowPetSwitchEffect(ItemID, extraData, bWear, SceneType)
  ModelDisplayer.StopSwitchEffect()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local petIDForPreview = logic_pet:GetPetIDForPrivilegePreview()
  if logic_pet:IsPetForPrivilegeAssetReady() then
    extraData = extraData or {}
    extraData.playSwitchEffectIDList = {ItemID}
    ModelDisplayer.Display(logic_pet:GetPetIDForPrivilegePreview(), bWear, extraData)
  else
    ModelDisplayer.Hide()
    local effectCfg = logic_pet:GetPortalCfgByItemId(ItemID)
    if effectCfg then
      local inParticlePath = effectCfg.Appear
      local scale = effectCfg.Scale or 1
      local Util = require("client.slua_ui_framework.util")
      ModelDisplayer._loadSwiftParticleHandle = Util.GetAssetAsync(inParticlePath, function(uParticle)
        local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
        local location = ConstAvatarDislay.AvatarPos[SceneType]
        if not location or not location.x then
          location = ModelDisplayer.GetPetShowPosition(petIDForPreview)
        end
        local time_ticker = require("common.time_ticker")
        ModelDisplayer._playingPortalTimer = time_ticker.AddTimerLoop(0.5, function()
          if slua.isValid(uParticle) and location and location.x then
            local pet_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.pet_manager)
            local baseLocation = FVector(location.x, location.y, location.z)
            local showLocation = pet_manager:GetAdjustPetModelPosByConfig(petIDForPreview, baseLocation)
            local UGameplayStatics = import("GameplayStatics")
            print(bWriteLog and "AvatarDisplayComponent:ShowAvatarDisplay show effect:", showLocation.X, showLocation.Y, showLocation.Z)
            if slua.isValid(ModelDisplayer._playingPortalEffect) then
              ModelDisplayer._playingPortalEffect:K2_DestroyComponent(ModelDisplayer._playingPortalEffect)
              ModelDisplayer._playingPortalEffect = nil
            end
            ModelDisplayer._playingPortalEffect = UGameplayStatics.SpawnEmitterAtLocation(slua_GameFrontendHUD:GetWorld(), uParticle, showLocation, FRotator(0, 0, 0), FVector(scale, scale, scale), true)
          end
        end, 0, 4)
      end)
    end
  end
end
function ModelDisplayer.StopSwitchEffect()
  if slua.isValid(ModelDisplayer._playingPortalEffect) then
    ModelDisplayer._playingPortalEffect:K2_DestroyComponent(ModelDisplayer._playingPortalEffect)
    ModelDisplayer._playingPortalEffect = nil
  end
  if ModelDisplayer._loadSwiftParticleHandle then
    local Util = require("client.slua_ui_framework.util")
    Util.ClearAssetAsync(ModelDisplayer._loadSwiftParticleHandle)
    ModelDisplayer._loadSwiftParticleHandle = nil
  end
  if ModelDisplayer._playingPortalTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ModelDisplayer._playingPortalTimer)
    ModelDisplayer._playingPortalTimer = nil
  end
end
function ModelDisplayer.ShowPetBubbleEmote(ItemIDList, extraData, bWear, SceneType, downloadCb)
  ModelDisplayer.StopBubbleEmote()
  if not ItemIDList then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, ItemIDList) ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "ModelDisplayer.ShowPetBubbleEmote ItemIDList is not downloaded")
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, ItemIDList)
    ShowNotice(508505)
    if type(downloadCb) == "function" then
      local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
      local pakNames = {}
      for i, itemID in ipairs(ItemIDList) do
        local paks = PufferODPakManager:GetPakNamesByItemID(itemID)
        for pakName, v in pairs(paks) do
          if PufferODPakManager:GetStateByPakName(pakName) ~= PufferConst.ENUM_DownloadState.Done then
            pakNames[pakName] = true
          end
        end
      end
      log_tree("ModelDisplayer.ShowPetBubbleEmote. pakNames = ", pakNames)
      if next(pakNames) then
        downloadCb(pakNames)
      end
    end
    return
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local petIDForPreview = logic_pet:GetPetIDForPrivilegePreview()
  local bWithPet = false
  if logic_pet:IsPetForPrivilegeAssetReady() and ItemIDList then
    for _, ItemID in pairs(ItemIDList) do
      if logic_pet:IsBubbleForPetBubblePrivilege(ItemID) then
        bWithPet = true
        break
      end
    end
  end
  if bWithPet then
    extraData = extraData or {}
    extraData.playBubbleIDList = ItemIDList
    ModelDisplayer.Display(logic_pet:GetPetIDForPrivilegePreview(), bWear, extraData)
  else
    ModelDisplayer.Hide()
    local ItemID = ItemIDList[1]
    if not ItemID then
      return
    end
    local bubbleCfg = logic_pet:GetBubbleTextureCfg(ItemID)
    if not bubbleCfg then
      return
    end
    local bubbleParticlePath = bubbleCfg.bubbleParticlePath
    local bubbleTexturePath = bubbleCfg.bubbleTexturePath
    local textParamName = bubbleCfg.textParamName
    if not (bubbleParticlePath and bubbleParticlePath ~= "" and bubbleTexturePath) or bubbleTexturePath == "" then
      return
    end
    if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {bubbleTexturePath}) ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and "ModelDisplayer.ShowPetBubbleEmote bubbleTexturePath is not downloaded: " .. tostring(bubbleTexturePath))
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {bubbleTexturePath})
      ShowNotice(508505)
      return
    end
    local Util = require("client.slua_ui_framework.util")
    ModelDisplayer._loadBubbleHandle = Util.GetAssetAsync(bubbleParticlePath, function(uParticle)
      ModelDisplayer._loadTextureHandle = Util.GetAssetAsync(bubbleTexturePath, function(uTexture)
        local scale = 2
        local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
        local location = ConstAvatarDislay.AvatarPos[SceneType]
        if not location or not location.x then
          location = ModelDisplayer.GetPetShowPosition(petIDForPreview)
        end
        local timer_tick = require("common.time_ticker")
        ModelDisplayer._playingBubbleTimer = timer_tick.AddTimerLoop(0.5, function()
          if slua.isValid(uParticle) and slua.isValid(uParticle) and location and location.x then
            local pet_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.pet_manager)
            local baseLocation = FVector(location.x, location.y, location.z + 91)
            local showLocation = pet_manager:GetAdjustPetModelPosByConfig(petIDForPreview, baseLocation)
            local UGameplayStatics = import("GameplayStatics")
            print(bWriteLog and "AvatarDisplayComponent:ShowAvatarDisplay show effect:", showLocation.X, showLocation.Y, showLocation.Z)
            if slua.isValid(ModelDisplayer._playingBubbleEffect) then
              ModelDisplayer._playingBubbleEffect:K2_DestroyComponent(ModelDisplayer._playingBubbleEffect)
              ModelDisplayer._playingBubbleEffect = nil
            end
            ModelDisplayer._playingBubbleEffect = UGameplayStatics.SpawnEmitterAtLocation(slua_GameFrontendHUD:GetWorld(), uParticle, showLocation, FRotator(0, 0, 0), FVector(scale, scale, scale), true)
            if slua.isValid(ModelDisplayer._playingBubbleEffect) then
              local Dynamic = ModelDisplayer._playingBubbleEffect:CreateDynamicMaterialInstance(0, nil)
              if slua.isValid(Dynamic) and slua.isValid(uTexture) then
                Dynamic:SetTextureParameterValue(textParamName, uTexture)
              end
            end
          end
        end, 0, 4)
      end)
    end)
  end
end
function ModelDisplayer.StopBubbleEmote()
  if slua.isValid(ModelDisplayer._playingBubbleEffect) then
    ModelDisplayer._playingBubbleEffect:K2_DestroyComponent(ModelDisplayer._playingBubbleEffect)
    ModelDisplayer._playingBubbleEffect = nil
  end
  local Util = require("client.slua_ui_framework.util")
  if ModelDisplayer._loadBubbleHandle then
    Util.ClearAssetAsync(ModelDisplayer._loadBubbleHandle)
    ModelDisplayer._loadBubbleHandle = nil
  end
  if ModelDisplayer._loadTextureHandle then
    Util.ClearAssetAsync(ModelDisplayer._loadTextureHandle)
    ModelDisplayer._loadTextureHandle = nil
  end
  if ModelDisplayer._playingBubbleTimer then
    local timer_tick = require("common.time_ticker")
    timer_tick.RemoveTimer(ModelDisplayer._playingBubbleTimer)
    ModelDisplayer._playingBubbleTimer = nil
  end
end
function ModelDisplayer.Store(storeKey)
  if _IsNotInitedYet() then
    log_error("[LobbyAvatar][ModelDisplayer] ModelDisplayer.Store is not init yet")
    return
  end
  if not ModelDisplayer._showingAvatar then
    log_error("[LobbyAvatar][ModelDisplayer] ModelDisplayer.Store is not showing avatar")
    return
  end
  storeKey = storeKey or ModelDisplayer.Enum_StoreKey.DEFAULT
  local data = {
    _storeModelId = _GetShowModuleID(),
    _status = ModelDisplayer._status,
    _storeEquipments = ModelDisplayer._showingAvatar:GetEquipments(),
    _storeSexType = ModelDisplayer._showingAvatar:GetSex(),
    _petType = 0
  }
  local pet = ModelDisplayer._showingAvatar:GetPet()
  if slua.isValid(pet) then
    data._petType = pet:GetPetType()
    data._petData = pet:GetPetData()
  end
  ModelDisplayer._storeData[storeKey] = data
end
function ModelDisplayer.Restore(storeKey)
  if _IsNotInitedYet() then
    log_error("[LobbyAvatar][ModelDisplayer] ModelDisplayer.Restore is not init yet")
    return
  end
  storeKey = storeKey or ModelDisplayer.Enum_StoreKey.DEFAULT
  local data = ModelDisplayer._storeData[storeKey]
  if data == nil then
    log(bWriteLog and "[LobbyAvatar][ModelDisplayer] ModelDisplayer.Restore storeKey data is nil.")
    return
  end
  if data._storeModelId and data._storeModelId ~= 0 then
    ModelDisplayer.Display(data._storeModelId, true)
  end
  ModelDisplayer._showingAvatar:ShowSex(data._storeSexType)
  ModelDisplayer._showingAvatar:SetStoreEquipments(data._storeEquipments)
  ModelDisplayer._showingAvatar:RestoreEquipments()
  _SwitchStatus(data._status)
  ModelDisplayer._isHide = false
  if data._petType ~= 0 then
    ModelDisplayer._showingAvatar:RefreshOrCreatePet(data._petData)
  end
end
function ModelDisplayer.RestoreCharacter()
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  local CurUseCharID = NewCharacterNetSystem:GetCurUsedCharacterID()
  if not ModelDisplayer._characterID or ModelDisplayer._characterID == 0 or ModelDisplayer._characterID == CurUseCharID then
    return
  end
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer] ModelDisplayer.RestoreCharacter _characterID:" .. tostring(ModelDisplayer._characterID) .. ", CurUseCharID:" .. tostring(CurUseCharID))
  local NewCharacterAvatarSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterAvatarSystem)
  NewCharacterAvatarSystem:SwitchCharacterModel(ModelDisplayer._showingAvatar, CurUseCharID)
  local avatarData = NewCharacterAvatarSystem:GetAvatarDataByCharacterID(CurUseCharID)
  if avatarData ~= nil and ModelDisplayer._showingAvatar then
    ModelDisplayer._showingAvatar:ShowSex(avatarData.gamegender)
  end
  ModelDisplayer._characterID = 0
end
function ModelDisplayer.ClearStore(storeKey)
  ModelDisplayer._storeData[storeKey] = nil
end
function ModelDisplayer.SetShowingModelRotation(roll, pitch, yaw)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.SetShowingActorRotation(roll, pitch, yaw)
end
function ModelDisplayer.AddShowingModelRotation(roll, pitch, yaw)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.AddShowingActorRotation(roll, pitch, yaw)
end
local putonEquipmentCallback
function ModelDisplayer.SetPutonEquipmentCallback(callback)
  putonEquipmentCallback = callback
end
function ModelDisplayer.OnPutonEquipmentEnd()
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer]  ModelDisplayer.OnPutonEquipmentEnd")
  if putonEquipmentCallback then
    putonEquipmentCallback()
  end
end
function ModelDisplayer.GetDebugInfoScreenPosition()
  local ScreenPosition
  if ModelDisplayer.GetShowingStatus() == ModelDisplayer.Enum_Status.Model then
    if ModelDisplayer._ShowingModelType == ModelDisplayer.Enum_ModelType.Pet then
      ScreenPosition = ModelDisplayer._petModel:GetDebugInfoScreenPosition()
    else
      local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
      ScreenPosition = MallSystemWeaponModelHandler.GetDebugInfoScreenPosition()
    end
  elseif ModelDisplayer.GetShowingStatus() == ModelDisplayer.Enum_Status.Avatar then
    ScreenPosition = ModelDisplayer._showingAvatar:GetDebugInfoScreenPosition()
  end
  return ScreenPosition
end
function ModelDisplayer.PlayAccelerateEffect()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not slua.isValid(actor) or not actor:GetVehicleActor() then
    log_error("ModelDisplayer PlayAccelerateEffect not VehicleActor")
    return
  end
  local vehicle = actor:GetVehicleActor()
  if not slua.isValid(vehicle) then
    log_error("ModelDisplayer PlayAccelerateEffect vehicle is not Valid")
    return
  end
  if vehicle.PlayAccelerateEffect then
    vehicle:PlayAccelerateEffect()
  end
end
function ModelDisplayer.PlayDoorAnim()
  log(bWriteLog and "ModelDisplayer.PlayDoorAnim")
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not slua.isValid(actor) or not actor:GetVehicleActor() then
    log(bWriteLog and "ModelDisplayer PlayDoorAnim not VehicleActor")
    return
  end
  if not actor:GetVehicleActor().PlayOpenDoorAnim then
    log(bWriteLog and "ModelDisplayer PlayDoorAnim  GetVehicleActor not PlayOpenDoorAnim")
    return
  end
  actor:GetVehicleActor():PlayOpenDoorAnim()
end
function ModelDisplayer.PlayVehicleStartUpEffect()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not slua.isValid(actor) or not actor:GetVehicleActor() then
    log_error("ModelDisplayer PlayVehicleStartUpEffect not VehicleActor")
    return
  end
  local vehicle = actor:GetVehicleActor()
  if not slua.isValid(vehicle) then
    log_error("ModelDisplayer PlayVehicleStartUpEffect vehicle is not Valid")
    return
  end
  if vehicle.PlayStartUpEffect then
    vehicle:PlayStartUpEffect()
  end
end
function ModelDisplayer.PutOnOrOffWeapon(ItemID, bWear, bEquipped)
  local ShowingAvatar = ModelDisplayer.GetShowingAvatar()
  if not ShowingAvatar then
    return
  end
  if bEquipped == nil then
    bEquipped = ModelDisplayer.HasEquiped(ItemID)
  end
  if not bWear and ModelDisplayer._status == ModelDisplayer.Enum_Status.Avatar and bEquipped then
    ModelDisplayer.Display(ItemID, false)
  else
    ModelDisplayer.Display(ItemID, true)
    ModelDisplayer.SwitchToModel()
  end
end
function ModelDisplayer.SetSyncEmote(itemID)
  if not ModelDisplayer._showingAvatar then
    log(bWriteLog and "ModelDisplayer.SetSyncEmote return not _showingAvatar")
    return
  end
  local model = ModelDisplayer._showingAvatar:GetModel()
  if not slua.isValid(model) then
    log(bWriteLog and "ModelDisplayer.SetSyncEmote return not model")
    return
  end
  if model.LobbyPlayEmoteComponent_BP == nil then
    log(bWriteLog and "ModelDisplayer.SetSyncEmote return not LobbyPlayEmoteComponent_BP")
    return
  end
  model.LobbyPlayEmoteComponent_BP.bSyncEmote = false
end
function ModelDisplayer._OnCameraSwitched(_, _, cameraID)
  log(bWriteLog and "ModelDisplayer._OnCameraSwitched" .. tostring(cameraID))
  if not ModelDisplayer.GetShowingAvatar() then
    return
  end
  ModelDisplayer.GetShowingAvatar():UpdatePositionByCamera()
end
function ModelDisplayer._OnScreenSizeChanged()
  log(bWriteLog and "ModelDisplayer._OnScreenSizeChanged")
  ModelDisplayer.StopAction()
end
function ModelDisplayer.SetLobbyUseSelfUID(bUse)
  local avatar = ModelDisplayer.GetShowingAvatar()
  if not avatar then
    return
  end
  local pawn = avatar:GetModel()
  if slua.isValid(pawn) and pawn.CharacterAvatarComp2_BP then
    pawn.CharacterAvatarComp2_BP:ResetData()
    pawn.CharacterAvatarComp2_BP:SetLobbyUseSelfUID(bUse)
  end
end
function ModelDisplayer.IsShowModel()
  log_warning(bWriteLog and "  ModelDisplayer.IsShowModel. ModelDisplayer._status: " .. tostring(ModelDisplayer._status))
  return ModelDisplayer._status == ModelDisplayer.Enum_Status.Model
end
function ModelDisplayer.IsShowPet()
  if ModelDisplayer.GetShowingStatus() == ModelDisplayer.Enum_Status.Avatar then
    return false
  end
  local itemId = ModelDisplayer._showingData and ModelDisplayer._showingData.showModelId
  if not itemId or itemId == 0 then
    return false
  end
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if not itemCfg then
    return false
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsPet(itemCfg.ItemType) or ModelDisplayTypeHelper.IsPetSkin(itemCfg.ItemType) then
    return true
  end
end
function ModelDisplayer.HideAvatarBeforeEmote(bHide, bForceShow)
  log(bWriteLog and "[LobbyAvatar][ModelDisplayer] ModelDisplayer.HideAvatarBeforeEmote bHide:" .. tostring(bHide))
  ModelDisplayer._hideAvatarBeforeEmote = bHide
  if bHide then
    ModelDisplayer.SwitchToAvatar()
    ModelDisplayer.Hide()
  else
    if bForceShow == nil then
      bForceShow = true
    end
    ModelDisplayer.Show(bForceShow)
  end
end
function ModelDisplayer.GetHideAvatarBeforeEmote()
  return ModelDisplayer._hideAvatarBeforeEmote
end
function ModelDisplayer.ResetHideAvatarBeforeEmote()
  ModelDisplayer._hideAvatarBeforeEmote = false
end
function ModelDisplayer.SetDisplayEmoteIDStart(EmoteID)
  ModelDisplayer._display  if ModelDisplayer._showExtraData and ModelDisplayer._showExtraData.emotionStartCallback then
    ModelDisplayer._mapEmotionStartCallback[EmoteID] = ModelDisplayer._showExtraData.emotionStartCallback
  end
end
function ModelDisplayer.SetDisplayEmoteIDEnd(EmoteID)
  if ModelDisplayer._showExtraData and ModelDisplayer._showExtraData.emotionEndCallback then
    local emotionEndCallback = ModelDisplayer._showExtraData.emotionEndCallback
    local iCallBackNum = 1
    if ModelDisplayer._mapEmotionEndCallback[EmoteID] then
      iCallBackNum = ModelDisplayer._mapEmotionEndCallback[EmoteID].iCallBackNum + 1
    end
    log(bWriteLog and "ModelDisplayer.SetDisplayEmoteIDEnd EmoteID:" .. tostring(EmoteID) .. " _displayEmoteID:" .. tostring(ModelDisplayer._displayEmoteID) .. " emotionStartCallback:" .. tostring(emotionEndCallback) .. " iCallBackNum:" .. tostring(iCallBackNum))
    ModelDisplayer._mapEmotionEndCallback[EmoteID] = {Callback = emotionEndCallback, iCallBackNum = iCallBackNum}
  end
end
function ModelDisplayer.ClearSexCache()
  ModelDisplayer.sexCache = nil
end
return ModelDisplayer