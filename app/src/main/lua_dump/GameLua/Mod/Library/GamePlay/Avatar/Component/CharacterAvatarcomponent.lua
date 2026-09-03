local CharacterAvatarComponent = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local EAvatarSlotType = import("EAvatarSlotType")
local ECabrioletState = import("ECabrioletState")
local EForceHideState = import("EForceHideState")
local EForceHideStateReason = import("EForceHideStateReason")
local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
local AVATAR_SLOTS_NEED_REPLACE_ON_VEHICLE = {
  2,
  3,
  5,
  9
}
local Enum_MaterialParamType = {
  Vector = 0,
  Scalar = 1,
  Texture = 2
}
local MAX_DIY_COLOR_PART_COUNT = 6
function CharacterAvatarComponent:ctor()
  local FGoldenSuitAvatarState = import("GoldenSuitAvatarState")
  self.AvatarStateList = slua.Array(UEnums.EPropertyClass.Struct, FGoldenSuitAvatarState)
  self.AvatarInheritList = slua.Array(UEnums.EPropertyClass.Struct, FGoldenSuitAvatarState)
  self.ColorDiyData = {}
  self.bLobbyUseSelfUID = true
  self.bHasChangedCameraParams = false
  self.bForceHideLocalHelmet = false
  self.bForceHideLocalArmor = false
  self.XSuitItemID = 0
  self.GoldenSuitItemID = 0
  self.FeatureMaterial = nil
  local FSuitDIYColorInfo = import("SuitDIYColorInfo")
  self.SuitDIYColorInfo = FSuitDIYColorInfo()
  self.XSuitUnlockFeatureList = slua.Array(UEnums.EPropertyClass.Int)
  self.XSuitUnlockFeatureMap = {}
  self.XSuitFeatureFlagList = slua.Array(UEnums.EPropertyClass.Int)
  self.XSuitFeatureFlagMap = {}
  self.bHasReportArmVisibleError = false
  self.bHasReportNetAvatarError = false
  self.DebugContent = ""
  self.bInitGoldenSuitInfo = false
  self.LobbyAvatarExceptionReport = false
  self.MoveEffectItem = 0
  self.FootStepEffectItem = 0
  self.bScopeIn = nil
end
function CharacterAvatarComponent:_PostConstruct()
  CharacterAvatarComponent.__super._PostConstruct(self)
  if Client then
    local EffectMgrClass = require("GameLua.Mod.Library.GamePlay.Avatar.Component.CharacterAvatarEffectMgr")
    self.EffectManager = EffectMgrClass(self.Object)
    self.EffectManager:Init()
    self:AddControlEvent(self, "OnAvatarAllMeshLoaded", self.OnAvatarAllMeshLoadedLua, self)
    self:AddControlEvent(self, "OnAvatarVisibleChanged", self.HandleOnAvatarVisibleChanged, self)
    self.bAvatarDebugReport = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableAvatarDebugReport", false)
    print("CharacterAvatarComponent:PostConstruct bAvatarDebugReport", self.bAvatarDebugReport)
    self.bDisableAvatarSlotIDFix = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableAvatarSlotIDFix", false)
    if Client then
      self.LobbyAvatarExceptionReport = HDmpveRemote.HDmpveRemoteConfigGetBool("LobbyAvatarExceptionReport", false)
    end
  end
end
function CharacterAvatarComponent:ReceiveBeginPlay()
  print(bWriteLog and "CharacterAvatarComponent:ReceiveBeginPlay")
  CharacterAvatarComponent.__super.ReceiveBeginPlay(self)
  if self.Super then
    self.Super:ReceiveBeginPlay()
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  self.IsDS = UKismetSystemLibrary.IsDedicatedServer(self)
  if Client then
    if self.bIsLobbyActor or self:IsSelf() then
      local AudioMgrClass = require("GameLua.Mod.Library.GamePlay.Avatar.Component.CharacterAvatarAudioMgr")
      self.AudioManager = AudioMgrClass(self.Object)
      self.AudioManager:Init()
    end
    local AdditionEffectMgrClass = require("GameLua.Mod.Library.GamePlay.Avatar.Component.CharacterAvatarAdditionEffectMgr")
    self.AdditionEffectMgr = AdditionEffectMgrClass(self.Object)
    self.AdditionEffectMgr:Init()
    self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_HIDESETTING_CHANGE, self.OnHiddenSettingChange, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_PLAYEREVENT_AVATAR_CLEAR_HANDLER_POOL, self.ClearAvatarHandlerPool, self)
    if not (SubsystemMgr and SubsystemMgr:Get("CharacterAvatarColorDIYSubsystem")) or self.bIsLobbyActor then
      self:RegisterSuitDyeUpdateEvent()
    end
  end
  if not Client then
    local uPawn = self:GetOwner()
    if slua.isValid(uPawn) and uPawn.OnStartInitDelegate then
      self:AddControlEvent(uPawn, "OnStartInitDelegate", self.OnStartInit, self)
    end
  end
  if Client then
    self:InitLocalSettingForceHide()
    local uPawn = self:GetOwner()
    if slua.isValid(uPawn) then
      if uPawn.OnPerspectiveChanged then
        self:AddControlEvent(uPawn, "OnPerspectiveChanged", self.HandlePlayerPerspectiveChanged, self)
      end
      if uPawn.OnFppChanged then
        self:AddControlEvent(uPawn, "OnFppChanged", self.OnFppChanged, self)
      end
      if uPawn.OnAttachedToVehicle then
        self:AddControlEvent(uPawn, "OnAttachedToVehicle", self.HandleAttachedToVehicle, self)
      end
      if uPawn.OnDetachedFromVehicle then
        self:AddControlEvent(uPawn, "OnDetachedFromVehicle", self.HandleDetachedFromVehicle, self)
      end
      if uPawn.OnCharacterCameraModeChange then
        self:AddControlEvent(uPawn, "OnCharacterCameraModeChange", self.CameraModeChange, self)
      end
      self:RefreshAvatarParticlesShow(uPawn.IsLocalActuallyScopeIn)
    end
    self:AddTimerOnce(0, function()
      self:RefreshGlidingCameraParam()
    end)
  end
  if not Client then
    self:AddControlEvent(self, "OnAvatarEquippedEvent", function(InSlotID, NewItemID, OldItemID)
      if InSlotID == EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot then
        self:OnAvatarChangeEvent()
      end
    end)
    self:AddControlEvent(self, "OnAvatarUnequippedEvent", function(InSlotID, OldItemID)
      if InSlotID == EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot then
        self:OnAvatarChangeEvent()
      end
    end)
  end
end
function CharacterAvatarComponent:PutOnCustomEquipmentByID(resID, CustomData)
  if not self:CheckItemValid(resID) then
    print(bWriteLog and "CharacterAvatarComponent:PutOnCustomEquipmentByID is not Valid")
    return
  end
  assert(CustomData == nil or type(CustomData) == "table" or type(CustomData) == "userdata", "CustomData is not Valid Type " .. tostring(CustomData))
  print(bWriteLog and "CharacterAvatarComponent:PutOnCustomEquipmentByID resID:" .. tostring(resID))
  log_tree("CharacterAvatarComponent:PutOnCustomEquipmentByID CustomData:", CustomData)
  local ItemDefineID = FItemDefineID(4, resID)
  local EAvatarCustomType = import("EAvatarCustomType")
  local AvatarCustom = FAvatarCustomDefault()
  if CustomData then
    AvatarCustom = CustomData
  end
  AvatarCustom.CustomType = EAvatarCustomType.AvatarCustomCharacter
  local result = self:HandleEquipItem(ItemDefineID, AvatarCustom)
  return result
end
function CharacterAvatarComponent:ConvertUnderWearID(ItemID, Color)
  return AvatarUtil.ConvertUnderWearID(ItemID, Color)
end
function CharacterAvatarComponent:CheckItemValid(ResID)
  if not ResID then
    return false
  end
  local UBackpackUtils = import("BackpackUtils")
  local BPID = UBackpackUtils.GetBPIDByResID(ResID)
  return 0 < BPID
end
function CharacterAvatarComponent:OnAvatarAllMeshLoadedLua()
  print(bWriteLog and "haracterAvatarComponent:OnAvatarAllMeshLoadedLua1")
  if Client and self.EffectManager then
    self.EffectManager:RefreshEffectCfg()
  end
  if Client and self.AudioManager then
    self.AudioManager:UpdateAudioCfg()
  end
  if Client and slua.isValid(self.FeatureMaterial) then
    local FeatureMaterial = self.FeatureMaterial
    self:ClearAllFeatureMaterial()
    self:ChangeAllMeshToFeatureMaterial(FeatureMaterial)
  end
  if Client and Client.HDmpveRemoteConfigGetBool("ClearAvatarHandlerFromPool", false) and self.bIsLobbyActor and Client then
    print(bWriteLog and "CharacterAvatarComponent:OnAvatarAllMeshLoaded LoadedAvatarHandlerPool Num:" .. tostring(self.LoadedAvatarHandlerPool:Num()))
    self:ClearAllAvatarHandlerFromPool()
  end
  if self.bIsLobbyActor then
    print(bWriteLog and "[update equiped mesh] lobby actor don't need set mesh lod.")
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local uCharacter = self:GetOwner()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "[update equiped mesh] uCharacter = nil")
    return
  end
  local uClassCharacterType = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  if not Game:IsClassOf(uCharacter, uClassCharacterType) then
    return
  end
  if self.bAutonomousLoadRes then
    local ArmorID = self:GetEquippedItemDefineID3(EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot).TypeSpecificID
    if 0 < ArmorID then
      self:SetAvatarForceLOD(EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot, 1)
    end
  end
  local EPawnState = import("EPawnState")
  if uCharacter:HasState(EPawnState.InVehicle) or uCharacter:HasState(EPawnState.DriveVehicle) then
    self:SetForceMeshLod(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot, true)
  end
  local ENetRole = import("ENetRole")
  if uCharacter.Role == ENetRole.ROLE_AutonomousProxy then
    self:OnAvatarChangeEvent()
    EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_LOCAL_PLAYEREVENT_AVATAR_ALL_MESH_LOADED)
    self:ReportNetAvatarDataByGameReport()
  end
  self:CheckArmVisibleErrorOnce()
end
function CharacterAvatarComponent:OnAvatarEquipFinish(slotType, isEquipped, itemID)
  if isEquipped == true and slotType == EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot then
    self:ResetClothSimulate()
  end
end
function CharacterAvatarComponent:ResetClothSimulate()
  local ClothMeshComp = self:GetMeshCompBySlot(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if slua.isValid(ClothMeshComp) and ClothMeshComp.ForceClothNextUpdateTeleportAndReset then
    ClothMeshComp:ForceClothNextUpdateTeleportAndReset()
  end
end
function CharacterAvatarComponent:ClearAvatarHandlerPool()
  if not Client or not self.LoadedAvatarHandlerPool then
    print(bWriteLog and "CharacterAvatarComponent:ClearAvatarHandlerPool not Client or not LoadedAvatarHandlerPool")
    return
  end
  print(bWriteLog and "CharacterAvatarComponent:ClearAvatarHandlerPool Owner: " .. tostring(self:GetOwnerName()))
  local AvatarItemIDListTable = self:GetAllEquipItemsTable()
  for i = self.LoadedAvatarHandlerPool:Num() - 1, 0, -1 do
    local Handle = self.LoadedAvatarHandlerPool:Get(i)
    if not slua.isValid(Handle) then
      self.LoadedAvatarHandlerPool:Remove(i)
      print(bWriteLog and "CharacterAvatarComponent:ClearAvatarHandlerPool Remove Invalid Handle")
    elseif not AvatarItemIDListTable[Handle:GetDefineID().TypeSpecificID] then
      self.LoadedAvatarHandlerPool:Remove(i)
      print(bWriteLog and "CharacterAvatarComponent:ClearAvatarHandlerPool Remove Handle:" .. tostring(Handle:GetDefineID().TypeSpecificID))
    else
      print(bWriteLog and "CharacterAvatarComponent:ClearAvatarHandlerPool Keep Handle:" .. tostring(Handle:GetDefineID().TypeSpecificID))
    end
  end
end
function CharacterAvatarComponent:GetAllEquipItemsTable()
  local AvatarItemIDList = self:GetAllItemIDLists()
  local AvatarItemIDListTable = {}
  for key, ItemID in pairs(AvatarItemIDList) do
    AvatarItemIDListTable[ItemID] = true
  end
  return AvatarItemIDListTable
end
function CharacterAvatarComponent:OnAvatarChangeEvent()
  local AvatarItem = self:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if AvatarItem and AvatarItem.TypeSpecificID > 0 then
    self.XSuitItemID = AvatarUtil.IsXSuitItem(AvatarItem.TypeSpecificID) and AvatarItem.TypeSpecificID or 0
    self.GoldenSuitItemID = AvatarUtil.IsGoldenSuitItem(AvatarItem.TypeSpecificID) and AvatarItem.TypeSpecificID or 0
  end
  if Client then
    local Owner = self:GetOwner()
    if slua.isValid(Owner) and Owner.GetPlayerControllerSafety then
      local uPlayerController = Owner:GetPlayerControllerSafety()
      if slua.isValid(uPlayerController) and uPlayerController.GetCurPlayerState then
        local uPlayerState = uPlayerController:GetCurPlayerState()
        local EMask = require("GameLua.Mod.MainCity.Gameplay.Core.MainCityCoreConst").EMainCityInteractiveStateTypeFlag
        if slua.isValid(uPlayerState) then
          local InteractivePlayerStateFeature = uPlayerState.InteractivePlayerStateFeature
          if InteractivePlayerStateFeature and InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_Seat) and Owner.SetClothMeshForceLod then
            log(bWriteLog and "CharacterAvatarComponent:OnAvatarChangeEvent.  SetClothMeshForceLod")
            Owner:SetClothMeshForceLod(true)
          end
        end
      end
    end
  end
end
function CharacterAvatarComponent:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "CharacterAvatarComponent:ReceiveEndPlay", EndPlayReason)
  if Client and self.EffectManager then
    self.EffectManager:Destroy()
    self.EffectManager = nil
  end
  if Client and self.AudioManager then
    self.AudioManager:Destroy()
    self.AudioManager = nil
  end
  if Client and self.AdditionEffectMgr then
    self.AdditionEffectMgr:Destroy()
    self.AdditionEffectMgr = nil
  end
  self.ColorDiyData = {}
  self.bInitGoldenSuitInfo = false
  CharacterAvatarComponent.__super.ReceiveEndPlay(self, EndPlayReason)
end
function CharacterAvatarComponent:OnStartInit()
  self:AddTimerOnce(0, function()
    self:InitGoldenSuitData()
    self:InitDepotCommonPutOn()
  end)
end
function CharacterAvatarComponent:InitGoldenSuitData()
  if self.bInitGoldenSuitInfo then
    print(bWriteLog and "CharacterAvatarComponent:bInitGoldenSuitInfo == true")
    return
  end
  print(bWriteLog and "CharacterAvatarComponent:InitGoldenSuitData")
  local uPawn = self:GetOwner()
  if slua.isValid(uPawn) then
    local PlayerUID = tonumber(uPawn.PlayerUID) or 0
    print(bWriteLog and "CharacterAvatarComponent:InitGoldenSuitData " .. tostring(PlayerUID))
    local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
    local GoldenSuitStateInfo = XSuitAvatarDataUtil:GetStateInfo(PlayerUID)
    if GoldenSuitStateInfo then
      for AvatarPeriod, AvatarPeriodStateInfo in pairs(GoldenSuitStateInfo) do
        if AvatarPeriodStateInfo and AvatarPeriodStateInfo.unlock_state and AvatarPeriodStateInfo.unlock_state[1] == 1 and AvatarPeriodStateInfo.unlock_state[2] == 1 then
          self.bInitGoldenSuitInfo = true
          self:SetCurAvatarState(AvatarPeriod, AvatarPeriodStateInfo.cur_state, XSuitAvatarDataUtil:GetShowLevel(PlayerUID, AvatarPeriod))
        end
      end
    end
    local GoldennheriSuitStateInfo = XSuitAvatarDataUtil:GetInheritStateInfo(PlayerUID)
    if GoldennheriSuitStateInfo then
      for AvatarPeriod, AvatarPeriodStateInfo in pairs(GoldennheriSuitStateInfo) do
        if AvatarPeriodStateInfo and AvatarPeriodStateInfo.unlock_state and AvatarPeriodStateInfo.unlock_state[1] == 1 and AvatarPeriodStateInfo.unlock_state[2] == 1 then
          self.bInitGoldenSuitInfo = true
          self:SetCurAvatarState(AvatarPeriod, AvatarPeriodStateInfo.cur_state, XSuitAvatarDataUtil:GetShowLevel(PlayerUID, AvatarPeriod), 1)
        end
      end
    end
  end
  self:InitXSuitFeatureList()
end
function CharacterAvatarComponent:InitXSuitFeatureList()
  print(bWriteLog and "CharacterAvatarComponent:InitXSuitFeatureList")
  local uPawn = self:GetOwner()
  if not uPawn then
    print(bWriteLog and "CharacterAvatarComponent:InitXSuitFeatureList Can`t find Pawn")
    return
  end
  local PlayerController = uPawn:GetPlayerControllerSafety()
  if not PlayerController then
    print(bWriteLog and "CharacterAvatarComponent:InitXSuitFeatureList Can`t find PlayerController")
    return
  end
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local unlockFeatureData = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(PlayerController.UID, ExtendAttribute.XSuitUnlockFeature)
  local tempUnlockArray = slua.Array(UEnums.EPropertyClass.Int)
  local tempFlagArray = slua.Array(UEnums.EPropertyClass.Int)
  if unlockFeatureData then
    for period, periodData in pairs(unlockFeatureData) do
      if periodData and periodData.unlock_info then
        for level, levelData in pairs(periodData.unlock_info) do
          for index, indexData in pairs(levelData) do
            if indexData and indexData.state == 1 then
              tempUnlockArray:Add(period)
              tempUnlockArray:Add(level)
              tempUnlockArray:Add(index)
              print(bWriteLog and "CharacterAvatarComponent:InitXSuitFeatureList unlock added:", period, level, index)
            end
          end
        end
      end
      if periodData and periodData.flag_info then
        for level, levelData in pairs(periodData.flag_info) do
          for index, indexData in pairs(levelData) do
            if indexData and indexData.flag_state == 0 then
              tempFlagArray:Add(period)
              tempFlagArray:Add(level)
              tempFlagArray:Add(index)
              print(bWriteLog and "CharacterAvatarComponent:InitXSuitFeatureList flag added:", period, level, index)
            end
          end
        end
      end
    end
  end
  self.XSuitUnlockFeatureList = tempUnlockArray
  print(bWriteLog and "CharacterAvatarComponent:InitXSuitFeatureList unlock count:", self.XSuitUnlockFeatureList:Num())
  self.XSuitFeatureFlagList = tempFlagArray
  print(bWriteLog and "CharacterAvatarComponent:InitXSuitFeatureList flag count:", self.XSuitFeatureFlagList:Num())
end
function CharacterAvatarComponent:InitDepotCommonPutOn()
  print(bWriteLog and "CharacterAvatarComponent:InitDepotCommonPutOn")
  local uPawn = self:GetOwner()
  if not uPawn then
    print(bWriteLog and "CharacterAvatarComponent:InitDepotCommonPutOn Can`t find Pawn")
    return
  end
  local PlayerController = uPawn:GetPlayerControllerSafety()
  if not PlayerController then
    print(bWriteLog and "CharacterAvatarComponent:InitDepotCommonPutOn Can`t find PlayerController")
    return
  end
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local DepotCommonPutOn = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(PlayerController.UID, ExtendAttribute.DepotCommonPutOn)
  if DepotCommonPutOn then
    local UGameplayStatics = import("GameplayStatics")
    local GameState = UGameplayStatics.GetGameState(self)
    local uEGameModeType = import("EGameModeType")
    if slua.isValid(GameState) and GameState.GameModeType == uEGameModeType.EWarGameMode then
      print(bWriteLog and "CharacterAvatarComponent:InitDepotCommonPutOn Is EWarGameMode")
    elseif slua.isValid(GameState) and GameState.GameModeType == uEGameModeType.EEntertainmentGameMode then
      print(bWriteLog and "CharacterAvatarComponent:InitDepotCommonPutOn Is EEntertainmentGameMode")
    else
      self.MoveEffectItem = DepotCommonPutOn.run_trail or 0
      self.FootStepEffectItem = DepotCommonPutOn.foot_print or 0
    end
  end
  print(bWriteLog and "CharacterAvatarComponent:InitDepotCommonPutOn " .. tostring(self.MoveEffectItem) .. "  " .. tostring(self.FootStepEffectItem))
end
function CharacterAvatarComponent:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local FGoldenSuitAvatarState = import("GoldenSuitAvatarState")
  local FSuitDIYColorInfo = import("SuitDIYColorInfo")
  return {
    {
      "AvatarStateList",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      FGoldenSuitAvatarState
    },
    {
      "AvatarInheritList",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      FGoldenSuitAvatarState
    },
    {
      "SuitDIYColorInfo",
      ELifetimeCondition.COND_None,
      FSuitDIYColorInfo
    },
    {
      "MoveEffectItem",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "FootStepEffectItem",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "XSuitUnlockFeatureList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "XSuitFeatureFlagList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
end
function CharacterAvatarComponent:OnRep_AvatarStateList()
  print(bWriteLog and "CharacterAvatarComponent:OnRep_AvatarStateList", self.AvatarStateList:Num())
end
function CharacterAvatarComponent:OnRep_AvatarInheritList()
  print(bWriteLog and "CharacterAvatarComponent:OnRep_AvatarInheritList", self.AvatarInheritList:Num())
end
function CharacterAvatarComponent:OnRep_XSuitUnlockFeatureList()
  print(bWriteLog and "CharacterAvatarComponent:OnRep_XSuitUnlockFeatureList", self.XSuitUnlockFeatureList:Num())
  self.XSuitUnlockFeatureMap = {}
  local count = self.XSuitUnlockFeatureList:Num()
  if 0 < count and count % 3 == 0 then
    for i = 0, count - 1, 3 do
      local period = self.XSuitUnlockFeatureList:Get(i)
      local level = self.XSuitUnlockFeatureList:Get(i + 1)
      local index = self.XSuitUnlockFeatureList:Get(i + 2)
      if period and level and index then
        if not self.XSuitUnlockFeatureMap[period] then
          self.XSuitUnlockFeatureMap[period] = {}
        end
        if not self.XSuitUnlockFeatureMap[period][level] then
          self.XSuitUnlockFeatureMap[period][level] = {}
        end
        self.XSuitUnlockFeatureMap[period][level][index] = {state = 1}
        print(bWriteLog and "CharacterAvatarComponent:OnRep_XSuitUnlockFeatureList added:", period, level, index)
      end
    end
    print(bWriteLog and "CharacterAvatarComponent:OnRep_XSuitUnlockFeatureList updated, count:", count / 3)
    local AvatarHandle = self:GetLoadedHandle(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
    if AvatarHandle then
      self:ReFreshAnimListOverride(AvatarHandle)
    end
  else
    print(bWriteLog and "CharacterAvatarComponent:OnRep_XSuitUnlockFeatureList invalid count:", count, "should be multiple of 3")
  end
end
function CharacterAvatarComponent:OnRep_XSuitFeatureFlagList()
  print(bWriteLog and "CharacterAvatarComponent:OnRep_XSuitFeatureFlagList", self.XSuitFeatureFlagList:Num())
  self.XSuitFeatureFlagMap = {}
  local count = self.XSuitFeatureFlagList:Num()
  if 0 < count and count % 3 == 0 then
    for i = 0, count - 1, 3 do
      local period = self.XSuitFeatureFlagList:Get(i)
      local level = self.XSuitFeatureFlagList:Get(i + 1)
      local index = self.XSuitFeatureFlagList:Get(i + 2)
      if period and level and index then
        if not self.XSuitFeatureFlagMap[period] then
          self.XSuitFeatureFlagMap[period] = {}
        end
        if not self.XSuitFeatureFlagMap[period][level] then
          self.XSuitFeatureFlagMap[period][level] = {}
        end
        self.XSuitFeatureFlagMap[period][level][index] = {flag_state = 0}
        print(bWriteLog and "CharacterAvatarComponent:OnRep_XSuitFeatureFlagList added:", period, level, index)
      end
    end
    print(bWriteLog and "CharacterAvatarComponent:OnRep_XSuitFeatureFlagList updated, count:", count / 3)
    local AvatarHandle = self:GetLoadedHandle(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
    if AvatarHandle then
      self:ReFreshAnimListOverride(AvatarHandle)
    end
  else
    print(bWriteLog and "CharacterAvatarComponent:OnRep_XSuitFeatureFlagList invalid count:", count, "should be multiple of 3")
  end
end
function CharacterAvatarComponent:OnRep_SuitDIYColorInfo()
  print(bWriteLog and "[DIYColor] CharacterAvatarComponent:OnRep_SuitDIYColorInfo", self.SuitDIYColorInfo.bUsingSyncProp, self.SuitDIYColorInfo.SuitID, self.SuitDIYColorInfo.PlanID, self.SuitDIYColorInfo.PartColorList:Num())
  if not self.SuitDIYColorInfo.bUsingSyncProp then
    print(bWriteLog and "[DIYColor] CharacterAvatarComponent:OnRep_SuitDIYColorInfo not using sync prop, return")
    return
  end
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  local Period = logic_suit_dye:GetPeriodBySuitId(self.SuitDIYColorInfo.SuitID)
  if Period == 0 then
    print(bWriteLog and "[DIYColor] CharacterAvatarComponent:OnRep_SuitDIYColorInfo item id provided is not a dye suit", self.SuitDIYColorInfo.SuitID)
    return
  end
  local ColorData, originPlan
  if self.SuitDIYColorInfo.OriginPlanID and 0 < self.SuitDIYColorInfo.OriginPlanID then
    originPlan = self.SuitDIYColorInfo.OriginPlanID
  end
  if self.SuitDIYColorInfo.PlanID ~= -1 then
    ColorData = logic_suit_dye:ConvertDataFromServer(Period, self.SuitDIYColorInfo.PlanID)
    print(bWriteLog and "[DIYColor] CharacterAvatarComponent:OnRep_SuitDIYColorInfo using PlanID")
  elseif self.SuitDIYColorInfo.PartColorList:Num() > 0 then
    local PartColorLuaTable = {}
    for i = 0, self.SuitDIYColorInfo.PartColorList:Num() - 1 do
      PartColorLuaTable[#PartColorLuaTable + 1] = self.SuitDIYColorInfo.PartColorList:Get(i)
    end
    ColorData = logic_suit_dye:ConvertDataFromServer(Period, PartColorLuaTable)
    print(bWriteLog and "[DIYColor] CharacterAvatarComponent:OnRep_SuitDIYColorInfo using PartColorList")
  end
  if not ColorData then
    print(bWriteLog and "[DIYColor] CharacterAvatarComponent:OnRep_SuitDIYColorInfo no valid color data, return")
    return
  end
  logic_suit_dye:ApplySuitSchemeData(self.Object, self.SuitDIYColorInfo.SuitID, ColorData, originPlan)
end
function CharacterAvatarComponent:OnRep_MoveEffectItem(OldValue)
  print(bWriteLog and "CharacterAvatarComponent:OnRep_MoveEffectItem " .. tostring(self.MoveEffectItem))
  if not self.AdditionEffectMgr then
    return
  end
  self.AdditionEffectMgr:SetMoveEffectItem(self.MoveEffectItem)
end
function CharacterAvatarComponent:OnRep_FootStepEffectItem(OldValue)
  print(bWriteLog and "CharacterAvatarComponent:OnRep_FootStepEffectItem " .. tostring(self.FootStepEffectItem))
  if not self.AdditionEffectMgr then
    return
  end
  self.AdditionEffectMgr:SetFootStepEffectItem(self.FootStepEffectItem)
end
function CharacterAvatarComponent:SetCurAvatarState(AvatarPeriod, CurState, CurLevel, Source)
  if Client then
    return
  end
  print(bWriteLog and "CharacterAvatarComponent:SetCurAvatarState AvatarPeriod:" .. tostring(AvatarPeriod) .. " CurState:" .. tostring(CurState) .. " CurLevel:" .. tostring(CurLevel) .. " Source:" .. tostring(Source))
  if Source == 1 then
    for i = self.AvatarInheritList:Num() - 1, 0, -1 do
      local stateItem = self.AvatarInheritList:Get(i)
      if stateItem.AvatarPeriod == AvatarPeriod then
        self.AvatarInheritList:Remove(i)
      end
    end
    local AvatarInheritList = self.AvatarInheritList
    local FGoldenSuitAvatarState = import("GoldenSuitAvatarState")
    local NewState = FGoldenSuitAvatarState()
    NewState.    NewState.AvatarState = CurState
    NewState.AvatarLevel = CurLevel
    AvatarInheritList:Add(NewState)
    self.  else
    for i = self.AvatarStateList:Num() - 1, 0, -1 do
      local stateItem = self.AvatarStateList:Get(i)
      if stateItem.AvatarPeriod == AvatarPeriod then
        self.AvatarStateList:Remove(i)
      end
    end
    local AvatarStateList = self.AvatarStateList
    local FGoldenSuitAvatarState = import("GoldenSuitAvatarState")
    local NewState = FGoldenSuitAvatarState()
    NewState.    NewState.AvatarState = CurState
    NewState.AvatarLevel = CurLevel
    AvatarStateList:Add(NewState)
    self.  end
  self:ForceNetUpdate()
end
function CharacterAvatarComponent:GetCurAvatarState(AvatarPeriod, Source)
  print(bWriteLog and "CharacterAvatarComponent:GetCurAvatarState Source:" .. tostring(Source))
  local AvatarStateList = self.AvatarStateList
  if Source and Source == 1 then
    AvatarStateList = self.AvatarInheritList
  end
  for i = 0, AvatarStateList:Num() - 1 do
    local stateItem = AvatarStateList:Get(i)
    if stateItem.AvatarPeriod == AvatarPeriod then
      return stateItem.AvatarState
    end
  end
  return 0
end
function CharacterAvatarComponent:SetAvatarDIYColorData(SuitID, PlanID, PartColorList, OriginPlanID)
  if Client then
    return
  end
  print(bWriteLog and "[DIYColor] CharacterAvatarComponent:SetAvatarDIYColorData", SuitID, PlanID, OriginPlanID)
  log_tree("[DIYColor] CharacterAvatarComponent:SetAvatarDIYColorData PartColorList:", PartColorList)
  if not SuitID then
    print(bWriteLog and "CharacterAvatarComponent:SetAvatarDIYColorData SuitID is nil")
    return
  end
  self.SuitDIYColorInfo.bUsingSyncProp = true
  self.SuitDIYColorInfo.  self.SuitDIYColorInfo.PlanID = PlanID or -1
  self.SuitDIYColorInfo.OriginPlanID = OriginPlanID or -1
  local RealPartColorList = {}
  if PartColorList then
    for i = 1, MAX_DIY_COLOR_PART_COUNT do
      RealPartColorList[i] = PartColorList[i] or -1
    end
  end
  self.SuitDIYColorInfo.PartColorList = RealPartColorList or {}
  self:ForceNetUpdate()
end
function CharacterAvatarComponent:GetCurAvatarLevel(ItemID, Source)
  if Source and Source == 1 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
    local OriginID = multi_state_manager:GetOriginClothIDAndState(ItemID) or ItemID
    local level = LogicXSuit.GetLevelByItemId(OriginID) or 0
    return level
  end
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local AvatarPeriod = XSuitUtil:GetPeriodByItemId(ItemID)
  for i = 0, self.AvatarStateList:Num() - 1 do
    local stateItem = self.AvatarStateList:Get(i)
    if stateItem.AvatarPeriod == AvatarPeriod then
      return stateItem.AvatarLevel
    end
  end
  return 0
end
function CharacterAvatarComponent:SetFakeHeadMesh(UseNoLod)
  self.bForceUseNoLodHeadMesh = UseNoLod
end
function CharacterAvatarComponent:HideHeadMesh(MasterBoneComp, OriginHeadMesh)
  print(bWriteLog and "CharacterAvatarComponent:HideHeadMesh", MasterBoneComp, OriginHeadMesh)
  if not slua.isValid(MasterBoneComp) or not slua.isValid(OriginHeadMesh) then
    return
  end
  local FakeHeadPath
  if self.bForceUseNoLodHeadMesh or self.bAutonomousLoadRes then
    FakeHeadPath = "/Game/Arts_Player/Characters/Mesh/Male/Head/Mesh/CharacterFakeHeadMesh.CharacterFakeHeadMesh"
  else
    FakeHeadPath = "/Game/Arts_Player/Characters/Mesh/Male/Head/Mesh/CharacterFakeHeadMesh_Lod.CharacterFakeHeadMesh_Lod"
  end
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local SoftObjPath = KismetSystemLibrary.MakeSoftObjectPath(FakeHeadPath)
  local FakeHeadMesh = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(SoftObjPath)
  MasterBoneComp:SetSkeletalMesh(FakeHeadMesh, false)
  local MatsArray = OriginHeadMesh.Materials
  for index = 0, MatsArray:Num() - 1 do
    local Mat = MatsArray:Get(index)
    MasterBoneComp:SetMaterialByName(Mat.MaterialSlotName, Mat.MaterialInterface)
  end
  local uPawn = self:GetOwner()
  if slua.isValid(uPawn) then
    uPawn.AvatarAnimClassCache = nil
    if uPawn.ResetCharAnimInstanceClass then
      uPawn:ResetCharAnimInstanceClass("CharacterAvatarComponent:HideHeadMesh", false)
    end
    print(bWriteLog and "CharacterAvatarComponent:HideHeadMesh Clear Pawn Avatar AnimCache")
  end
end
function CharacterAvatarComponent:GenerateVehicleTemplateConfig()
  print(bWriteLog and "GenerateVehicleTemplateConfig")
  local config = CDataTable.GetTable("OnCarReplaceVTTable")
  for k, v in pairs(config) do
    local StringUtil = require("common.string_util")
    local vehicleIDs = StringUtil.Split(v.Vehicles, "|")
    if vehicleIDs and next(vehicleIDs) then
      for _, id in pairs(vehicleIDs) do
        self:FillVehicleTemplateConfig(v.TemplateID, tonumber(id))
      end
    end
  end
end
function CharacterAvatarComponent:GetRepalceIDOnVehicle(SkinID)
  local ReplaceCfg = CDataTable.GetTableData("OnCarAvatarReplaceTable", SkinID)
  if ReplaceCfg then
    local StringUtil = require("common.string_util")
    local TemplateIDs = StringUtil.Split(ReplaceCfg.TemplateID, "|")
    for _, id in pairs(TemplateIDs) do
      if id and tonumber(id) and self:IsNeedModifyVehicle(tonumber(id)) then
        print(bWriteLog and "GetRepalceIDOnVehicle" .. ReplaceCfg.ReplaceID)
        return ReplaceCfg.ReplaceID
      end
    end
  else
    local HelMetCfg = CDataTable.GetTableData("MALL_BAG_HELMET_BASE_ITEM_CONFIG", SkinID)
    if HelMetCfg then
      local ReplaceCfg_1 = CDataTable.GetTableData("OnCarAvatarReplaceTable", HelMetCfg.baseItemID)
      if ReplaceCfg_1 then
        local StringUtil = require("common.string_util")
        local TemplateIDs = StringUtil.Split(ReplaceCfg_1.TemplateID, "|")
        for _, id in pairs(TemplateIDs) do
          if id and tonumber(id) and self:IsNeedModifyVehicle(tonumber(id)) then
            print(bWriteLog and "GetRepalceIDOnVehicle" .. ReplaceCfg_1.ReplaceID)
            return ReplaceCfg_1.ReplaceID
          end
        end
      end
    end
  end
  print(bWriteLog and "GetRepalceIDOnVehicle 0")
  return 0
end
function CharacterAvatarComponent:BPIsNeedModifyVehicle(VehicleID, TemplateID, SeatIndex)
  local Origin  print(bWriteLog and "BPIsNeedModifyVehicle SeatIdx" .. SeatIndex)
  if not self:IsInVehicleTemplateConfig(VehicleID, TemplateID) then
    local SkinCfg = CDataTable.GetTableData("VehiclePlaneSkinMapping", VehicleID)
    if not SkinCfg then
      print(bWriteLog and "BPIsNeedModifyVehicle5")
      return false
    end
    if not self:IsInVehicleTemplateConfig(SkinCfg.OrginalID, TemplateID) then
      print(bWriteLog and "BPIsNeedModifyVehicle6")
      return false
    end
    OriginVehicleID = SkinCfg.OrginalID
  end
  local SeatCfg = CDataTable.GetTableData("SeatRestritTable", OriginVehicleID)
  if SeatCfg then
    local StringUtil = require("common.string_util")
    local Seats = StringUtil.Split(SeatCfg.Seats, "|")
    if Seats and Seats[1] ~= nil then
      for k, v in pairs(Seats) do
        if SeatIndex == tonumber(v) then
          print(bWriteLog and "BPIsNeedModifyVehicle1")
          return true
        end
      end
      print(bWriteLog and "BPIsNeedModifyVehicle2")
      self:RemoveAllReplaceOnVehicle()
      return false
    else
      print(bWriteLog and "BPIsNeedModifyVehicle3")
      return true
    end
  else
    print(bWriteLog and "BPIsNeedModifyVehicle4")
    return true
  end
end
function CharacterAvatarComponent:ProcessChangedVehicleSeat()
  print(bWriteLog and "CharacterAvatarComponent OnAttachedToVehicle")
  self:UpdateCutPlaneState()
  local Player = self:GetOwner()
  if not slua.isValid(Player) then
    return
  end
  local Vehicle = Player:GetCurrentVehicle()
  if not slua.isValid(Vehicle) then
    return
  end
  local VehicleAvatar = Vehicle:GetVehicleAvatar()
  if not slua.isValid(VehicleAvatar) then
    return
  end
  local ResID = VehicleAvatar.NetAvatarData.ItemDefineID.TypeSpecificID
  local SkinCfg = CDataTable.GetTableData("VehiclePlaneSkinMapping", ResID)
  if SkinCfg then
    ResID = SkinCfg.OrginalID
  end
  local SeatIndex = 0
  SeatIndex = Vehicle:GetVehicleSeats():GetChracterSeatIndex(Player)
  local SeatCfg = CDataTable.GetTableData("SeatRestritTable", ResID)
  if SeatCfg then
    local StringUtil = require("common.string_util")
    local Seats = StringUtil.Split(SeatCfg.Seats, "|")
    if Seats and Seats[1] ~= nil then
      for k, v in pairs(Seats) do
        if SeatIndex == tonumber(v) then
          self:DoAllAvatarReplaceOnVehicle()
          return
        end
      end
      self:RemoveAllReplaceOnVehicle()
    end
  end
end
function CharacterAvatarComponent:RemoveAllReplaceOnVehicle()
  print(bWriteLog and "CharacterAvatarComponent:RemoveAllReplaceOnVehicle")
  for _, slot in pairs(AVATAR_SLOTS_NEED_REPLACE_ON_VEHICLE) do
    self:RemoveForceReplaceOnVehicle(slot)
  end
end
function CharacterAvatarComponent:DoAllAvatarReplaceOnVehicle()
  print(bWriteLog and "CharacterAvatarComponent:DoAllAvatarReplaceOnVehicle")
  self.VehicleForceReplace = false
  for _, slot in pairs(AVATAR_SLOTS_NEED_REPLACE_ON_VEHICLE) do
    self:ForceReplaceAvatarOnVehicle(slot)
  end
end
function CharacterAvatarComponent:OnEnterOrLeaveVehicle()
  if self.bEnterVehicle then
    self:DoAllAvatarReplaceOnVehicle()
  else
    self:RemoveAllReplaceOnVehicle()
  end
  self.HasVehicleAjustHandle = false
  self:UpdateCutPlaneState()
end
function CharacterAvatarComponent:IsWearingAvatarNeedParachuteWind()
  local MeshCompList = self:GetAllMeshComponents(false)
  if MeshCompList == nil or not slua.isValid(MeshCompList) then
    printf("CharacterAvatarComponent:IsWearingAvatarNeedParachuteWind Error , MeshCompList Invalid")
    return false
  end
  local MeshNum = MeshCompList:Num()
  if 0 < MeshNum then
    for index = 0, MeshNum - 1 do
      local MeshComp = MeshCompList:Get(index)
      if MeshComp and slua.isValid(MeshComp) and MeshComp.GetAnimInstance ~= nil then
        local AnimIns = MeshComp:GetAnimInstance()
        if AnimIns and slua.isValid(AnimIns) and AnimIns.bParachuteWindFlag then
          return true
        end
      end
    end
  end
  return false
end
function CharacterAvatarComponent:IsCutPlaneOnVehicleOpen()
  print(bWriteLog and "CharacterAvatarComponent:IsCutPlaneOnVehicleOpen")
  return true
end
function CharacterAvatarComponent:RefreshAvatarParticlesShow(bScopeIn)
  if not Client then
    return
  end
  local uOwnerChar = self:GetOwner()
  if not slua.isValid(uOwnerChar) then
    return
  end
  local myCharacter = self:GetMyOwnCharacter()
  local bIsSelf = myCharacter == uOwnerChar or false
  if self:OwnerIsLobbyPawn() then
    bIsSelf = true
  end
  local IsFpp = myCharacter and myCharacter.GetIsFpp and myCharacter:GetIsFPP() or false
  local uComponentClass = import("FXSystemComponent")
  local uTargetArray = uOwnerChar:GetComponentsByTag(uComponentClass, "SkirtParticle")
  local uVehicleTargetArray = uOwnerChar:GetComponentsByTag(uComponentClass, "HideInVehicle")
  local Vehicle = myCharacter and myCharacter.GetCurrentVehicle and myCharacter:GetCurrentVehicle()
  local VehicleHidedParticleComps = {}
  for i = 0, uVehicleTargetArray:Num() - 1 do
    local ParticleComp = uVehicleTargetArray:Get(i)
    if slua.isValid(Vehicle) then
      if ParticleComp.Deactivate then
        ParticleComp:Deactivate()
        VehicleHidedParticleComps[ParticleComp] = true
      end
    elseif ParticleComp.Activate then
      ParticleComp:Activate(true)
    end
  end
  if uTargetArray:Num() < 1 then
    print(bWriteLog and "CharacterAvatarComponent:RefreshAvatarParticlesShow SkirtParticle num < 1")
    return
  end
  local bShowParticles = true
  if bScopeIn and bIsSelf then
    bShowParticles = false
  elseif slua.isValid(Vehicle) and IsFpp then
    local charVehicle = uOwnerChar.GetCurrentVehicle and uOwnerChar:GetCurrentVehicle()
    if bIsSelf or Vehicle == charVehicle then
      log(bWriteLog and "CharacterAvatarComponent:RefreshAvatarParticlesShow IsFpp and self:IsSelf() or Vehicle == charVehicle")
      bShowParticles = false
    end
  elseif IsFpp and bIsSelf then
    bShowParticles = false
  end
  print(bWriteLog and "CharacterAvatarComponent:RefreshAvatarParticlesShow bShowParticles:" .. tostring(bShowParticles))
  for i = 0, uTargetArray:Num() - 1 do
    local ParticleComp = uTargetArray:Get(i)
    if slua.isValid(ParticleComp) and not VehicleHidedParticleComps[ParticleComp] then
      if bShowParticles then
        if ParticleComp.Activate then
          ParticleComp:Activate(true)
        end
      elseif ParticleComp.Deactivate then
        ParticleComp:Deactivate()
      end
    end
  end
end
function CharacterAvatarComponent:HandlePlayerScopeInOrOut(bScopeIn)
  self.  self:RefreshAvatarParticlesShow(bScopeIn)
end
function CharacterAvatarComponent:OnFppChanged(bIsFpp)
  log(bWriteLog and "CharacterAvatarComponent:OnFppChanged  " .. tostring(bIsFpp))
  self:RefreshAvatarParticlesShow(bIsFpp)
end
function CharacterAvatarComponent:HandlePlayerPerspectiveChanged(bIsFpp)
  self:RefreshSelfVehiclePassengersPartcle()
end
function CharacterAvatarComponent:RefreshSelfVehiclePassengersPartcle(InVehicle)
  local uOwnerChar = self:GetOwner()
  if not slua.isValid(uOwnerChar) then
    return
  end
  if not self:IsSelf() then
    log(bWriteLog and "CharacterAvatarComponent:HandlePlayerPerspectiveChanged not self")
    return
  end
  local Vehicle = InVehicle or uOwnerChar:GetCurrentVehicle()
  if not slua.isValid(Vehicle) or not Vehicle.RefreshVehiclePassengersParticle then
    log(bWriteLog and "CharacterAvatarComponent:HandlePlayerPerspectiveChanged no Vehicle")
    return
  end
  Vehicle:RefreshVehiclePassengersParticle()
end
function CharacterAvatarComponent:HandleAttachedToVehicle(InVehicle)
  local uOwnerChar = self:GetOwner()
  if not slua.isValid(uOwnerChar) then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if self:IsSelf() then
    self:RefreshSelfVehiclePassengersPartcle(InVehicle)
    self:RefreshAvatarParticlesShow(uOwnerChar.IsLocalActuallyScopeIn)
  else
    self:RefreshAvatarParticlesShow(uOwnerChar.IsLocalActuallyScopeIn)
  end
end
function CharacterAvatarComponent:HandleDetachedFromVehicle(InVehicle)
  local uOwnerChar = self:GetOwner()
  if not slua.isValid(uOwnerChar) then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if self:IsSelf() then
    self:RefreshSelfVehiclePassengersPartcle(InVehicle)
  else
    self:RefreshAvatarParticlesShow(uOwnerChar.IsLocalActuallyScopeIn)
  end
end
function CharacterAvatarComponent:HandleOnAvatarVisibleChanged(SlotType, visible)
  if not visible then
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  if SlotType ~= EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot then
    return
  end
  local uOwnerChar = self:GetOwner()
  if not slua.isValid(uOwnerChar) then
    return
  end
  local bIsScopeIn = self.bScopeIn ~= nil and self.bScopeIn or uOwnerChar.IsLocalActuallyScopeIn
  self:RefreshAvatarParticlesShow(bIsScopeIn)
end
function CharacterAvatarComponent:BPOnRemoveAvatarReAttach()
  print(bWriteLog and "CharacterAvatarComponent:11BPOnRemoveAvatarReAttach")
end
function CharacterAvatarComponent:BPOnDeleteAvatarMeshData(InSlotID, MeshChanged)
  print(bWriteLog and "CharacterAvatarComponent:BPOnDeleteAvatarMeshData")
  self:RefreshAvatarReAttach()
end
function CharacterAvatarComponent:ProcessUnDownloadHead(InSlotID, MeshChanged)
  if not Client then
    return
  end
  if not self.GetEquippedItemDefineID3 then
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local HeadSlotID = 1
  local HeadItem = self:GetEquippedItemDefineID3(HeadSlotID)
  if HeadItem.TypeSpecificID == 0 then
    return
  end
  HeadItem.Type = 4
  if self:IsItemBlueprintExist(HeadSlotID, HeadItem, false) then
    return
  else
    print(bWriteLog and "CharacterAvatarComponent:ProcessUnDownloadHead Head Not Download")
    self:ModifySlotFakeID(EAvatarSlotType.EAvatarSlotType_HeadEquipemtSlot, 401996)
  end
end
function CharacterAvatarComponent:HandleCharacterHiddenChange(bHidden)
  if not Client then
    return
  end
  print(bWriteLog and "CharacterAvatarComponent HandleCharacterHiddenChange", bHidden)
  if bHidden == false then
    self:ActiviteGlideParticle()
  end
end
function CharacterAvatarComponent:ActiviteGlideParticle()
  if not self.GetOwner then
    return
  end
  local uPawn = self:GetOwner()
  if not slua.isValid(uPawn) then
    return
  end
  local EParachuteState = import("EParachuteState")
  if uPawn.ParachuteState == EParachuteState.PS_FreeFall then
    local uComponentClass = import("/Script/Engine.ParticleSystemComponent")
    local uTargetArray = uPawn:GetComponentsByTag(uComponentClass, "GlideParticle")
    for i = 0, uTargetArray:Num() - 1 do
      local ParticleComp = uTargetArray:Get(i)
      if slua.isValid(ParticleComp) then
        ParticleComp:Activate(true)
      end
    end
  end
end
function CharacterAvatarComponent:PrintDefaultConfig()
  print(bWriteLog and "CharacterAvatarComponent PrintDefaultConfig")
  if not Client or not Client.IsDevelopment() then
    return
  end
  if not self.DefaultAvataConfig then
    print(bWriteLog and "CharacterAvatarComponent PrintDefaultConfig not self.DefaultAvataConfig")
    return
  end
  for Slot, ItemDefine in pairs(self.DefaultAvataConfig) do
    print(bWriteLog and "CharacterAvatarComponent2:PrintDefaultConfig  Slot:" .. tostring(Slot) .. " Type:" .. tostring(ItemDefine.Type) .. " ItemID: " .. tostring(ItemDefine.TypeSpecificID))
  end
end
function CharacterAvatarComponent:OnAvatarMeshEquippedEventBP(InSlotID, bEquipped, InItemDefineID, RealShowItemID)
  if Client and bEquipped then
    self:AddTimer(0, function()
      print(bWriteLog and "CharacterAvatarComponent:OnAvatarMeshEquippedEventBP ===>" .. InSlotID .. "bEquipped" .. tostring(bEquipped) .. "InItemDefineID" .. InItemDefineID.TypeSpecificID .. "RealShowItemID" .. RealShowItemID)
      self:ProcessDIYColor(InSlotID, RealShowItemID)
    end)
  end
end
local GetCharacterAvatarColorDIYSubsystem = function()
  if not SubsystemMgr then
    return
  end
  return SubsystemMgr:Get("CharacterAvatarColorDIYSubsystem")
end
function CharacterAvatarComponent:ProcessDIYColor(InSlotID, RealShowItemID)
  print(bWriteLog and "CharacterAvatarComponent:ProcessDIYColor ItemID " .. tostring(RealShowItemID))
  if self.ColorDiyData[InSlotID] then
    if self.ColorDiyData[InSlotID][RealShowItemID] then
      self:DoChangeColor(InSlotID, RealShowItemID, self.ColorDiyData[InSlotID][RealShowItemID])
      return
    end
  else
    self.ColorDiyData[InSlotID] = {}
  end
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  if not logic_suit_dye:IsDyeSuit(RealShowItemID) then
    return
  end
  local PlayerUID = self:GetSelfPlayerID_DIYColor()
  if not PlayerUID or PlayerUID == "" then
    return
  end
  if self:UseColorDataByBattleProfile(PlayerUID) then
    GetCharacterAvatarColorDIYSubsystem():RequestColorData(self.Object, tonumber(PlayerUID), RealShowItemID)
  else
    local period = logic_suit_dye:GetPeriodBySuitId(RealShowItemID)
    if not period or period == 0 then
      return
    end
    local data, originPlan = logic_suit_dye:GetPlanData(PlayerUID, period)
    if not data then
      if PlayerUID == DataMgr.roleData.uid then
        logic_suit_dye:RequestSelfPlanData(period)
      else
        print(bWriteLog and "CharacterAvatarComponent:ProcessDIYColor Data Not Found! ")
      end
      return
    end
    logic_suit_dye:ApplySuitSchemeData(self.Object, RealShowItemID, data, originPlan)
  end
end
function CharacterAvatarComponent:UseColorDataByBattleProfile(PlayerUID)
  if self:OwnerIsLobbyPawn() then
    return false
  end
  if PlayerUID == DataMgr.roleData.uid and self:GetOwner().IsMainCityCharacter then
    return false
  end
  if not GetCharacterAvatarColorDIYSubsystem() then
    return false
  end
  return true
end
function CharacterAvatarComponent:OwnerIsLobbyPawn()
  local Owner = self:GetOwner()
  if not Owner then
    return
  end
  local ASTExtraLobbyCharacter = import("STExtraLobbyCharacter")
  return Game:IsClassOf(Owner, ASTExtraLobbyCharacter)
end
function CharacterAvatarComponent:GetSelfPlayerID_DIYColor()
  local PlayerUID = ""
  local Owner = self:GetOwner()
  if not (slua.isValid(Owner) and Owner.PlayerUID) or type(Owner.PlayerUID) ~= "string" or Owner.PlayerUID == "" then
    local _UID = slua.isValid(Owner) and Owner.PlayerUID or ""
    print(bWriteLog and string.format("CharacterAvatarComponent:ProcessDIYColor InBattleProcess=%s _UID=%s", tostring(InBattleProcess), tostring(_UID)))
    if not self:OwnerIsLobbyPawn() then
      if slua.isValid(Owner) and Owner.GetPlayerControllerSafety then
        local uPlayerController = Owner:GetPlayerControllerSafety()
        if slua.isValid(uPlayerController) and uPlayerController.GetCurPlayerState then
          local uPlayerState = uPlayerController:GetCurPlayerState()
          if slua.isValid(uPlayerState) then
            PlayerUID = uPlayerState.PlayerUID or ""
          end
        end
      end
      if PlayerUID == "" then
        print(bWriteLog and "CharacterAvatarComponent:ProcessDIYColor InBattleProcess PlayerUID is invalid return")
        return
      end
    else
      print(bWriteLog and "CharacterAvatarComponent:ProcessDIYColor bLobbyUseSelfUID " .. tostring(self.bLobbyUseSelfUID))
      if self.bLobbyUseSelfUID then
        PlayerUID = DataMgr.roleData.uid
      else
        return
      end
    end
  else
    PlayerUID = Owner.PlayerUID
  end
  return PlayerUID
end
function CharacterAvatarComponent:ApplyDIYColorData(AvatarSlotID, ItemID, ColorDatas)
  print(bWriteLog and "CharacterAvatarComponent:ApplyDIYColorData" .. ItemID .. " Owner: " .. tostring(self:GetOwnerName()))
  if not self.ColorDiyData[AvatarSlotID] then
    self.ColorDiyData[AvatarSlotID] = {}
  end
  self.ColorDiyData[AvatarSlotID][ItemID] = ColorDatas
  self:DoChangeColor(AvatarSlotID, ItemID, ColorDatas)
end
function CharacterAvatarComponent:ClearDIYColorData()
  print(bWriteLog and "CharacterAvatarComponent:ClearDIYColorData")
  if not self.ColorDiyData then
    return
  end
  for AvatarSlotID, SlotData in pairs(self.ColorDiyData) do
    if SlotData then
      for ItemID, _ in pairs(SlotData) do
        self.ColorDiyData[AvatarSlotID][ItemID] = nil
      end
    end
  end
end
function CharacterAvatarComponent:DoChangeColor(AvatarSlotID, RealShowItemID, ColorDatas)
  local EquipItemDefineID = self:GetEquippedItemDefineID3(AvatarSlotID)
  print(bWriteLog and string.format("CharacterAvatarComponent:DoChangeColor AvatarSlotID:%s, TypeSpecificID:%s, RealShowItemID:%s", tostring(AvatarSlotID), tostring(EquipItemDefineID and EquipItemDefineID.TypeSpecificID), tostring(RealShowItemID)))
  local ViewItemID = 0
  if self.ViewSlotDesc then
    local ViewItemDesc = self.ViewSlotDesc:Get(AvatarSlotID)
    if ViewItemDesc then
      ViewItemID = ViewItemDesc.RealShowItemDefineID.TypeSpecificID
    end
  end
  if EquipItemDefineID.TypeSpecificID ~= RealShowItemID and ViewItemID ~= RealShowItemID then
    print(bWriteLog and "CharacterAvatarComponent:DoChangeColor ID Not Match EquipID" .. EquipItemDefineID.TypeSpecificID .. "ApplyID" .. RealShowItemID)
    return
  end
  local MeshComp = self:GetMeshCompBySlot(AvatarSlotID)
  if not slua.isValid(MeshComp) then
    print(bWriteLog and "CharacterAvatarComponent:DoChangeColor No Mesh")
    return
  end
  print(bWriteLog and "CharacterAvatarComponent:DoChangeColor " .. tostring(self.Object))
  for _, ColorData in pairs(ColorDatas) do
    local DynamicMat = self:GetOrCreateDynamicMat(MeshComp, ColorData.MatSlotID)
    if slua.isValid(DynamicMat) and ColorData.ColorParamName and ColorData.Color then
      if ColorData.ColorParamType == Enum_MaterialParamType.Scalar then
        DynamicMat:SetScalarParameterValue(ColorData.ColorParamName, ColorData.Color)
      elseif ColorData.ColorParamType == Enum_MaterialParamType.Texture then
        if ColorData.Color then
          local asset_util = require("common.asset_util")
          asset_util.GetAssetAsync(ColorData.Color, function(Texture)
            DynamicMat:SetTextureParameterValue(ColorData.ColorParamName, Texture)
          end)
        end
      else
        DynamicMat:SetVectorParameterValue(ColorData.ColorParamName, ColorData.Color)
      end
    end
  end
end
function CharacterAvatarComponent:ResetData()
  print(bWriteLog and "CharacterAvatarComponent:ResetData")
  self:SetLobbyUseSelfUID(true)
  self.ColorDiyData = {}
end
function CharacterAvatarComponent:SetLobbyUseSelfUID(bUse)
  print(bWriteLog and "CharacterAvatarComponent:SetLobbyUseSelfUID " .. tostring(bUse) .. tostring(self.Object))
  self.bLobbyUseSelfUID = bUse
end
function CharacterAvatarComponent:RegisterSuitDyeUpdateEvent()
  self:RemoveCommonEvent(EVENTTYPE_SUITDYE, EVENTID_SUITDYE_CHARACTERAVATARCOMP_UPDATE)
  print("CharacterAvatarComponent:RegisterSuitDyeUpdateEvent AddCommonEvent UpdateSuitDyeEffect" .. tostring(self.Object))
  self:AddCommonEvent(EVENTTYPE_SUITDYE, EVENTID_SUITDYE_CHARACTERAVATARCOMP_UPDATE, self.UpdateSuitDyeEffect, self)
end
function CharacterAvatarComponent:UpdateSuitDyeEffect(_, _, UID, ItemID, Data, OriginPlan)
  print(bWriteLog and "CharacterAvatarComponent:UpdateSuitDyeEffect " .. tostring(UID))
  local PlayerUID = ""
  local Owner = self:GetOwner()
  print(bWriteLog and "CharacterAvatarComponent:UpdateSuitDyeEffect " .. tostring(UID) .. "(" .. type(UID) .. ") PlayerUID " .. tostring(Owner and Owner.PlayerUID) .. "(" .. type(Owner and Owner.PlayerUID) .. ")")
  if not (slua.isValid(Owner) and Owner.PlayerUID) or type(Owner.PlayerUID) ~= "string" or Owner.PlayerUID == "" then
    if self.bLobbyUseSelfUID then
      PlayerUID = DataMgr.roleData.uid
    else
      print(bWriteLog and "CharacterAvatarComponent:UpdateSuitDyeEffect does not use self uid")
      return
    end
  else
    PlayerUID = Owner.PlayerUID
  end
  if UID ~= PlayerUID then
    print(bWriteLog and "CharacterAvatarComponent:UpdateSuitDyeEffect UID is not equals to PlayerUID")
    return
  end
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  if not logic_suit_dye:IsDyeSuit(ItemID) then
    print(bWriteLog and "CharacterAvatarComponent:UpdateSuitDyeEffect current item is not a dye suit" .. tostring(ItemID))
    return
  end
  print(bWriteLog and "CharacterAvatarComponent:UpdateSuitDyeEffect ItemID " .. tostring(ItemID))
  logic_suit_dye:ApplySuitSchemeData(self.Object, ItemID, Data, OriginPlan)
end
function CharacterAvatarComponent:NeedVehicleForceReplate(ItemID)
  local Cfg = CDataTable.GetTableData("OnCarCloteCutTable", ItemID)
  if not Cfg then
    print(bWriteLog and "CharacterAvatarComponent NeedVehicleForceReplate false ItemID" .. tostring(ItemID))
    return false
  end
  print(bWriteLog and "CharacterAvatarComponent NeedVehicleForceReplate true ItemID" .. tostring(ItemID))
  return true
end
function CharacterAvatarComponent:ProcessSpecialGlider()
  if self:IsLobbyActor() or Client then
    print(bWriteLog and "CharacterAvatarComponent:ProcessSpecialGlider In lobby or is Client")
    return
  end
  if not self.LogicSlotDesc then
    return
  end
  local GlideLogicSlotDesc = self.LogicSlotDesc:Get(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot)
  if not GlideLogicSlotDesc then
    print(bWriteLog and "CharacterAvatarComponent:ProcessSpecialGlider No glide equipped")
    return
  end
  local uPawn = self:GetOwner()
  if not uPawn then
    print(bWriteLog and "CharacterAvatarComponent:ProcessSpecialGlider Can`t find Pawn")
    return
  end
  local PlayerController = uPawn:GetPlayerControllerSafety()
  if not PlayerController then
    print(bWriteLog and "CharacterAvatarComponent:ProcessSpecialGlider Can`t find PlayerController")
    return
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local LogicGlider = require("client.logic.glide.logic_glider")
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local GliderID = GlideLogicSlotDesc.ItemDefineID.TypeSpecificID
  local ActualUsed  if LogicXSuit.IsXSuitGlide(GliderID) then
    local NormalGlideID = LogicXSuit.GetNormalGlideID(GliderID)
    local ClothID = LogicXSuit.GetLevel7XSuitID(NormalGlideID)
    local ClotheLogicSlotDesc = self.LogicSlotDesc:Get(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
    if not ClothID or not ClotheLogicSlotDesc then
      return
    end
    local bHasEquip = ClothID == ClotheLogicSlotDesc.ItemDefineID.TypeSpecificID
    local state2Item = XSuitUtil:ChangeItemIDByState(ClothID, 2)
    if state2Item == ClotheLogicSlotDesc.ItemDefineID.TypeSpecificID then
      bHasEquip = true
    end
    if bHasEquip and XSuitUtil.IsUserOpenSpecialGlideSetting(PlayerController.UID, NormalGlideID) then
      ActualUsedGliderID = LogicXSuit.GetSpecialGlideID(NormalGlideID)
    else
      ActualUsedGliderID = NormalGlideID
    end
  elseif LogicGlider.IsMultiStateGliderBaseState(GliderID) then
    local ClotheLogicSlotDesc = self.LogicSlotDesc:Get(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
    if not ClotheLogicSlotDesc then
      return
    end
    if LogicGlider.IsMultiStateGliderBaseState(GliderID) and LogicGlider.IsWearDependentItem(GliderID, self.LogicSlotDesc) then
      ActualUsedGliderID = LogicGlider.GetSpecialGliderID(GliderID)
    end
  else
    return
  end
  print(bWriteLog and "CharacterAvatarComponent:ProcessSpecialGlider OldGliderID: " .. tostring(GliderID) .. " NewGliderID: " .. tostring(ActualUsedGliderID))
  self:ModifyLogicSlotDescID(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot, ActualUsedGliderID)
end
function CharacterAvatarComponent:ProcessSpecialGoldenSuit()
  local clothes = self:GetSlotSyncData(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local clothesId = clothes and clothes.ItemID
  local Hat = self:GetSlotSyncData(EAvatarSlotType.EAvatarSlotType_HatEquipemtSlot)
  local hatId = Hat and Hat.ItemID
  if not hatId then
    return
  end
  log(bWriteLog and "  CharacterAvatarComponent:ProcessSpecialGoldenSuit. hatId: " .. tostring(hatId))
  local cfg = CDataTable.GetTableData("GoldenSuit2ClothesCfg", hatId)
  if not cfg then
    return
  end
  local resultId = cfg.noId
  if cfg.condition1 == clothesId then
    resultId = cfg.result1
  elseif cfg.condition2 == clothesId then
    resultId = cfg.result2
  end
  log(bWriteLog and "  CharacterAvatarComponent:ProcessSpecialGoldenSuit. resultId: " .. tostring(resultId))
  local ESyncOperation = import("ESyncOperation")
  if Hat.OperationType == ESyncOperation.PutOn and clothes.OperationType == ESyncOperation.PutOn then
    self:ModifySlotFakeID(EAvatarSlotType.EAvatarSlotType_HatEquipemtSlot, resultId)
  end
end
function CharacterAvatarComponent:ServerProcessData()
  log(bWriteLog and "CharacterAvatarComponent:ServerProcessData")
  self:ProcessSpecialGlider()
end
local _ReplaceBagConfig = {
  [1407523] = {
    [1501001640] = 1501001668,
    [1501002640] = 1501002668,
    [1501003640] = 1501003668
  }
}
function CharacterAvatarComponent:GetEquipmentSkinItemID(InItemID)
  if not self.Super then
    return
  end
  local ItemID = self.Super:GetEquipmentSkinItemID(InItemID)
  print(bWriteLog and "CharacterAvatarComponent:GetEquipmentSkinItemID" .. tostring(ItemID))
  local clothes = self:GetSlotSyncData(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local ESyncOperation = import("ESyncOperation")
  if clothes and _ReplaceBagConfig[clothes.ItemID] and clothes.OperationType == ESyncOperation.PutOn then
    local ReplaceID = _ReplaceBagConfig[clothes.ItemID][ItemID]
    if ReplaceID then
      print(bWriteLog and "CharacterAvatarComponent:GetEquipmentSkinItemID ChangeItemID " .. tostring(ItemID) .. " To: " .. tostring(ReplaceID))
      ItemID = ReplaceID
    end
  end
  return ItemID
end
function CharacterAvatarComponent:NeedHideParachuteEquipemtInFreeState()
  if not self.GetOwner then
    return
  end
  local uPawn = self:GetOwner()
  if uPawn and slua.isValid(uPawn) then
    if uPawn.IgnoreGliderOneTime then
      return false
    end
    if uPawn.IsFakeOnVehicle then
      print(bWriteLog and "CharacterAvatarComponent:NeedHideParachuteEquipemtInFreeState IsFakeOnVehicle true")
      return true
    end
  end
  if self:HaveSubTypeMesh(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot, self.BackAircraftType) then
    print(bWriteLog and "CharacterAvatarComponent:NeedHideParachuteEquipemtInFreeState HaveSubTypeMesh")
    return true
  end
  if not self:HaveSubTypeMesh(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot, self.BackSkateType) then
    print(bWriteLog and "CharacterAvatarComponent:NeedHideParachuteEquipemtInFreeState not BackSkateType")
    return false
  end
  local ItemDefineID = self:GetEquippedItemDefineID3(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot)
  local GlideID = ItemDefineID.TypeSpecificID
  if not GlideID then
    print(bWriteLog and "CharacterAvatarComponent:NeedHideParachuteEquipemtInFreeState not GlideID")
    return false
  end
  local Cfg = CDataTable.GetTableData("HideParachuteConfig", GlideID)
  if Cfg then
    print(bWriteLog and "CharacterAvatarComponent:NeedHideParachuteEquipemtInFreeState Hide GlideID:", GlideID)
    return true
  end
  return false
end
function CharacterAvatarComponent:ProcessClothSuits()
  if self.Super then
    self.Super:ProcessClothSuits()
  end
  self:ProcessSpecialGoldenSuit()
  if not self:HasSlotSyncData(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot) then
    print(bWriteLog and "CharacterAvatarComponent ProcessClothSuits not Cloth")
    return
  end
  local CurrentClothID = self:GetSlotSyncData(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot).ItemID
  self:HandleFaceHidden(CurrentClothID)
  local _SuitConfig = CDataTable.GetTableData("NoReplaceHatTable", CurrentClothID)
  if not (CurrentClothID and _SuitConfig) or _SuitConfig.HatID <= 0 then
    return
  end
  local itemDefineID = FItemDefineID(self.ItemType, CurrentClothID)
  if not self:IsItemBlueprintExist(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot, itemDefineID, false) then
    print(bWriteLog and "CharacterAvatarComponent ProcessClothSuits not self:IsItemBlueprintExist")
    return
  end
  local MeshSyncData = self:GetSlotSyncData(EAvatarSlotType.EAvatarSlotType_HatEquipemtSlot)
  if MeshSyncData.ForceHideState == EForceHideState.All then
    print(bWriteLog and "CharacterAvatarComponent ProcessClothSuits ForceHideState == EForceHideState.All")
    return
  end
  self:ModifySlotFakeID(EAvatarSlotType.EAvatarSlotType_HatEquipemtSlot, _SuitConfig.HatID)
end
function CharacterAvatarComponent:BPHandleTempRunningSlotDesc()
  self:HandleClothReplace()
  self:HandleBackPackHidden()
end
function CharacterAvatarComponent:HandleClothReplace()
  if not self.VehicleForceReplace then
    return
  end
  self:AddTempRunningSlotDesc(EAvatarSlotType.EAvatarSlotType_VehicleCut, 4, 27000, false)
end
function CharacterAvatarComponent:HandleBackPackHidden()
  if self.bIsLobbyActor then
    local owner = self:GetOwner()
    if not owner or not owner.GetPlayerUID then
      log(bWriteLog and "CharacterAvatarComponent:HandleBackPackHidden not self:GetOwner()")
      return
    end
    local UID = owner:GetPlayerUID()
    if tostring(UID) ~= tostring(DataMgr.roleData.uid) then
      return
    end
  elseif not self:IsSelf() then
    print(bWriteLog and "CharacterAvatarComponent HandleBackPackHidden is not Self")
    return
  end
  if not self.TempRunningSlotDesc then
    return
  end
  local SlotDesc = self.TempRunningSlotDesc:Get(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if not SlotDesc then
    return
  end
  local SlotSyncData = self:GetSlotSyncData(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local ItemID = SlotSyncData.FakeItemID > 0 and SlotSyncData.FakeItemID or SlotSyncData.ItemID
  local LogicUserBattleDataManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicUserBattleDataManager)
  if LogicUserBattleDataManager:GetHideBagSetting(ItemID) then
    SlotDesc.RelationData.HideFlags:Add(800)
    SlotDesc.RelationData.HideFlags:Add(1700)
    self.TempRunningSlotDesc:Add(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot, SlotDesc)
  end
end
function CharacterAvatarComponent:OnHiddenSettingChange()
  log(bWriteLog and "CharacterAvatarComponent OnHiddenSettingChange")
  self:OnRep_BodySlotStateChanged()
end
function CharacterAvatarComponent:HandleFaceHidden(CurrentClothID)
  if self.bIsLobbyActor then
    local UID = self:GetOwner():GetPlayerUID()
    if UID == "" then
      if not self.bLobbyUseSelfUID then
        return
      end
    elseif tostring(UID) ~= tostring(DataMgr.roleData.uid) then
      return
    end
  elseif not self:IsSelf() then
    return
  end
  local LogicUserBattleDataManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicUserBattleDataManager)
  if LogicUserBattleDataManager:GetHideFaceSetting(CurrentClothID) then
    print(bWriteLog and "CharacterAvatarComponent HandleFaceHidden CurrentClothID" .. tostring(CurrentClothID))
    self:ModifySlotFakeID(EAvatarSlotType.EAvatarSlotType_FaceEquipemtSlot, 0)
  end
end
function CharacterAvatarComponent:BP_SetAvatarVisibility(slotType, visible, isForce)
  if slotType == EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot then
    self:UserGlidingCameraParam(visible)
    if visible == false then
      self:DeactivateGlideParticle()
      self:StopGliderAkEvent()
    end
  end
end
function CharacterAvatarComponent:RefreshGlidingCameraParam()
  local GlideMeshComp = self:GetMeshCompBySlot(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot)
  if not slua.isValid(GlideMeshComp) then
    print(bWriteLog and "CharacterAvatarComponent:RefreshGlidingCameraParam No GlideMeshComp")
    return
  end
  self:UserGlidingCameraParam(GlideMeshComp.bVisible)
end
function CharacterAvatarComponent:DeactivateGlideParticle()
  local uOwnerChar = self:GetOwner()
  if not slua.isValid(uOwnerChar) then
    return
  end
  local uComponentClass = import("/Script/Engine.ParticleSystemComponent")
  local uTargetArray = uOwnerChar:GetComponentsByTag(uComponentClass, "SpawnWhenMeshVisible")
  if uTargetArray:Num() >= 1 then
    for key, ParticleComp in pairs(uTargetArray) do
      if slua.isValid(ParticleComp) and ParticleComp.Deactivate then
        ParticleComp:Deactivate()
      end
    end
  end
  uTargetArray = uOwnerChar:GetComponentsByTag(uComponentClass, "SpawnIfMeshVisible")
  if uTargetArray:Num() >= 1 then
    for key, ParticleComp in pairs(uTargetArray) do
      if slua.isValid(ParticleComp) and ParticleComp.Deactivate then
        ParticleComp:Deactivate()
      end
    end
  end
end
function CharacterAvatarComponent:StopGliderAkEvent()
  local uOwnerChar = self:GetOwner()
  if not slua.isValid(uOwnerChar) then
    return
  end
  local akComponentClass = import("/Script/AkAudio.AkComponent")
  local uTargetArray = uOwnerChar:GetComponentsByTag(akComponentClass, "GliderAkComp")
  if uTargetArray:Num() >= 1 then
    for key, akComp in pairs(uTargetArray) do
      if slua.isValid(akComp) and akComp.Stop then
        log(bWriteLog and "CharacterAvatarComponent:StopGliderAkEvent success")
        akComp:Stop()
        return
      end
    end
  end
  log(bWriteLog and "CharacterAvatarComponent:StopGliderAkEvent not found")
end
function CharacterAvatarComponent:UserGlidingCameraParam(bEnable)
  print(bWriteLog and "CharacterAvatarComponent:UserGlidingCameraParam bEnable" .. tostring(bEnable))
  local uPawn = self:GetOwner()
  local UBaseCharacterClass = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  if not Game:IsClassOf(uPawn, UBaseCharacterClass) then
    print(bWriteLog and "CharacterAvatarComponent:UserGlidingCameraParam not STExtraBaseCharacter")
    return
  end
  if bEnable then
    local ItemDefineID = self:GetEquippedItemDefineID3(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot)
    local GlideID = ItemDefineID.TypeSpecificID
    if not GlideID or GlideID == 0 then
      print(bWriteLog and "CharacterAvatarComponent:UserGlidingCameraParam not GlideID ")
      return
    end
    local GlideCameraSetting = AvatarUtil.GetGlideCameraSetting(GlideID)
    if not GlideCameraSetting or GlideCameraSetting.ArmLength == 0 then
      print(bWriteLog and "CharacterAvatarComponent:UserGlidingCameraParam not not GlideCameraSetting" .. tostring(GlideID))
      return
    end
    print(bWriteLog and "CharacterAvatarComponent:UserGlidingCameraParam GlideID" .. tostring(GlideID))
    if uPawn.DefaultFreeFallSpringArmParam.CameraParam.FieldOfView < 0.1 then
      print(bWriteLog and "CharacterAvatarComponent:UserGlidingCameraParam UnInit")
      return
    end
    uPawn.FreeFallSpringArmParam = uPawn.DefaultFreeFallSpringArmParam
    uPawn.FreeFallSpringArmParam.TargetArmALength = GlideCameraSetting.ArmLength
    self.bHasChangedCameraParams = true
    if GlideCameraSetting.TypeID == 10 then
      uPawn.MeshBoundCapsuleComonent:SetCapsuleSize(160, 200, false)
    end
  else
    if not self.bHasChangedCameraParams then
      return
    end
    if uPawn.DefaultFreeFallSpringArmParam.CameraParam.FieldOfView < 0.1 then
      print(bWriteLog and "CharacterAvatarComponent:UserGlidingCameraParam UnInit")
      return
    end
    uPawn.FreeFallSpringArmParam = uPawn.DefaultFreeFallSpringArmParam
    self.bHasChangedCameraParams = false
    uPawn.MeshBoundCapsuleComonent:SetCapsuleSize(80, 100, false)
  end
  local EParachuteState = import("EParachuteState")
  if uPawn.ParachuteState == EParachuteState.PS_FreeFall then
    uPawn:SwitchCameraToParachuteFalling()
  end
end
function CharacterAvatarComponent:UpdateCutPlaneState()
  local VehicleSkinID = self:GetCurrentVehicleOrParachuteVehicleSkinID()
  local SeatIndex = self:GetCurrentSeatIndex()
  local IsFakeOnVehicle = self:GetOwner() and self:GetOwner().IsFakeOnVehicle
  local EClothCutStateType = import("EClothCutStateType")
  local CutType = EClothCutStateType.EClothCutStateType_NotCut
  local bSeatAllowClip = self:IsSeatAllowClip(VehicleSkinID, SeatIndex)
  local bEquipingClipCloth = self:IsEquipingClipCloth()
  print(bWriteLog and "CharacterAvatarComponent:UpdateCutPlaneState IsFakeOnVehicle:" .. tostring(IsFakeOnVehicle) .. " bEnterVehicle:" .. tostring(self.bEnterVehicle) .. " VehicleSkinID:" .. tostring(VehicleSkinID) .. " SeatIndex:" .. tostring(SeatIndex) .. " bSeatAllowClip:" .. tostring(bSeatAllowClip) .. " bEquipingClipCloth:" .. tostring(bEquipingClipCloth))
  if (IsFakeOnVehicle or self.bEnterVehicle) and bSeatAllowClip and bEquipingClipCloth then
    if not self:CheckShouldCutTopPlane() then
      CutType = EClothCutStateType.EClothCutStateType_Bottom
    else
      CutType = EClothCutStateType.EClothCutStateType_TopAndBottom
    end
  end
  self:SetClothPlaneCutState(CutType)
end
function CharacterAvatarComponent:SetClothPlaneCutState(CutState)
  if self.ClothPlaneCutState ~= CutState then
    print(bWriteLog and "CharacterAvatarComponent:SetClothPlaneCutState CutState:" .. tostring(CutState))
    self.ClothPlane    self:ForceNetUpdate()
  end
end
function CharacterAvatarComponent:UpdateTopPlaneWExtraOffset(WOffset)
  self.TopPlaneWExtraOffset = WOffset or 0
end
function CharacterAvatarComponent:CheckShouldCutTopPlane()
  local uCharacter = self:GetOwner()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "CharacterAvatarComponent:CheckShouldCutTopPlane invalid uCharacter")
    return false
  end
  if uCharacter.IsFakeOnVehicle then
    print(bWriteLog and "CharacterAvatarComponent:CheckShouldCutTopPlane ParachuteComponent")
    local VehicleSkinID = self:GetCurrentParachuteVehicleSkinID()
    if VehicleSkinID then
      local itemCfg = CDataTable.GetTableData("Item", VehicleSkinID)
      if itemCfg and itemCfg.ItemSubType and itemCfg.ItemSubType == 915 then
        return false
      end
    end
    return true
  end
  local Vehicle = uCharacter:GetCurrentVehicle()
  if not slua.isValid(Vehicle) then
    print(bWriteLog and "CharacterAvatarComponent:CheckShouldCutTopPlane invalid Vehicle")
    return false
  end
  if not Vehicle.GetVehicleCabrioletState then
    print(bWriteLog and "CharacterAvatarComponent:CheckShouldCutTopPlane invalid GetVehicleCabrioletState")
    return true
  end
  local CabrioletState = Vehicle:GetVehicleCabrioletState()
  if CabrioletState and CabrioletState ~= ECabrioletState.BeenClose then
    print(bWriteLog and "CharacterAvatarComponent:CheckShouldCutTopPlane false")
    return false
  end
  print(bWriteLog and "CharacterAvatarComponent:CheckShouldCutTopPlane true")
  return true
end
function CharacterAvatarComponent:IsSeatAllowClip(VehicleSkinID, SeatIndex)
  local CarClipConfig = CDataTable.GetTableData("CarClipConfig", VehicleSkinID)
  if not CarClipConfig then
    local UAvatarUtils = import("AvatarUtils")
    local OriginID = UAvatarUtils.GetVehicleDefaultID(VehicleSkinID, true)
    CarClipConfig = CDataTable.GetTableData("CarClipConfig", OriginID)
    if not CarClipConfig then
      return false
    end
  end
  local StringUtil = require("common.string_util")
  local UnableSeatList = StringUtil.Split(CarClipConfig.UnableSeatIndexList, "|")
  for _, _UnableIndex in pairs(UnableSeatList) do
    if SeatIndex == _UnableIndex then
      return false
    end
  end
  return true
end
function CharacterAvatarComponent:IsEquipingClipCloth()
  for _, Slot in pairs(self.AvatarSlotNeedCut) do
    local ItemID = self:GetEquippedItemDefineID3(Slot).TypeSpecificID
    local NeedCut = self:IsClothNeedCut(ItemID)
    if NeedCut then
      return true
    end
  end
  return false
end
function CharacterAvatarComponent:GetUnderWearMaterialStruct(Handle)
  if not slua.isValid(Handle) then
    print(bWriteLog and "CharacterAvatarComponent:GetUnderWearMaterialStruct Handle Is Not Valid")
    return
  end
  local MaterialMap = Handle.UnderWearConfig
  if not MaterialMap then
    log_error("CharacterAvatarComponent:GetUnderWearMaterialStruct not MaterialMap")
    return
  end
  local HeadID = self:GetEquippedItemDefineID3(EAvatarSlotType.EAvatarSlotType_HeadEquipemtSlot).TypeSpecificID
  local UnderWearMat = MaterialMap:Get(HeadID)
  if not UnderWearMat then
    print(bWriteLog and "CharacterAvatarComponent:GetUnderWearMaterialStruct not UnderWearMat HeadID:" .. tostring(HeadID) .. " Handle:" .. tostring(Handle))
    return
  end
  return UnderWearMat
end
function CharacterAvatarComponent:BPClientPostProcessViewDataBefore()
  print(bWriteLog and "CharacterAvatarComponent:BPClientPostProcessViewDataBefore")
  self:InitLocalSettingForceHide()
  if self.Super then
    self.Super:BPClientPostProcessViewDataBefore()
  end
end
function CharacterAvatarComponent:InitLocalSettingForceHide()
  local uOwnerPawn = self.GetOwner and self:GetOwner() or nil
  if slua.isValid(uOwnerPawn) and self:ShouldInitForceHide(uOwnerPawn) and not self.bLocalSettingForceHide then
    self:InitLocalEquipmentDisplay()
    local ForceHideState = self:IsPlayingWonderfulPlayback() and EForceHideState.All or EForceHideState.Self
    print(bWriteLog and "CharacterAvatarComponent:InitLocalSettingForceHide", ForceHideState, self.bForceHideLocalHelmet, self.bForceHideLocalArmor)
    if self.bForceHideLocalHelmet then
      self:SetForceHideStateData(EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot, ForceHideState, EForceHideStateReason.Client_InLocalSetting)
    end
    if self.bForceHideLocalArmor then
      self:SetForceHideStateData(EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot, ForceHideState, EForceHideStateReason.Client_InLocalSetting)
    end
    self.bLocalSettingForceHide = true
  end
end
function CharacterAvatarComponent:InitLocalEquipmentDisplay()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    print(bWriteLog and "CharacterAvatarComponent:InitLocalEquipmentDisplay", SettingConfig.LocalHideHelmet)
    self.bForceHideLocalHelmet = SettingConfig.LocalHideHelmet == true
  end
end
function CharacterAvatarComponent:ShouldInitForceHide(Pawn)
  if not slua.isValid(Pawn) or not Pawn.IsLocallyControlled then
    print(bWriteLog and "CharacterAvatarComponent:ShouldInitForceHide Invalid Pawn!")
    return false
  end
  if Pawn:IsLocallyControlled() then
    return true
  end
  local bIsPlayingWonderfulPlayback = self:IsPlayingWonderfulPlayback()
  if not slua_GameFrontendHUD then
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.GetCurPawn and bIsPlayingWonderfulPlayback then
    local CurPawn = uPlayerController:GetCurPawn()
    print(bWriteLog and "CharacterAvatarComponent:ShouldInitForceHide Pawn", CurPawn == Pawn, CurPawn, Pawn, self:IsSelf())
    return CurPawn == Pawn
  end
  return false
end
function CharacterAvatarComponent:IsPlayingWonderfulPlayback()
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  local uWonderfulPlayback = slua.isValid(uGameInstance) and uGameInstance:GetWonderfulPlayback() or nil
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  return uWonderfulPlayback and uWonderfulPlayback:IsInPlayState() or logic_replay.IsPlayingReplay()
end
function CharacterAvatarComponent:ChangeWeaponShow(bEnable, ClothID)
  local uOwnerPawn = self:GetOwner()
  local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  local WeaponShowID = logic_emote.GetCustomWeaponShowID(ClothID)
  if Game:IsClassOf(uOwnerPawn, ASTExtraBaseCharacter) and uOwnerPawn.PlayerUID == DataMgr.roleData.uid then
    logic_emote.ChangeWeaponShow(bEnable, WeaponShowID)
  end
  if bEnable == false then
    local UBaseCharacterClass = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
    if slua.isValid(uOwnerPawn) and Game:IsClassOf(uOwnerPawn, UBaseCharacterClass) and slua.isValid(uOwnerPawn:GetPlayEmoteComponent()) then
      local EmoteComp = uOwnerPawn:GetPlayEmoteComponent()
      if EmoteComp.CurrentEmoteIndex == WeaponShowID then
        EmoteComp:LocalInteruptPlayEmote(WeaponShowID)
      end
    end
  end
end
function CharacterAvatarComponent:GetMyOwnCharacter()
  if not slua_GameFrontendHUD then
    return nil
  end
  if not Client then
    return nil
  end
  local playerControl = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(playerControl) then
    return nil
  end
  if not playerControl.GetPlayerCharacterSafety then
    print(bWriteLog and "SCharacterAvatarComponent:GetMyOwnCharr no GetPlayerCharacterSafety")
    return nil
  end
  local playerChar = playerControl:GetPlayerCharacterSafety()
  if not slua.isValid(playerChar) then
    return nil
  end
  return playerChar
end
function CharacterAvatarComponent:ChangeAllMeshToFeatureMaterial(material)
  self.FeatureMaterial = material
  local model_util = require("client.common.model_util")
  model_util.ChangeActorAllMeshCompFeatureMaterial(self:GetOwner(), material)
end
function CharacterAvatarComponent:ClearAllFeatureMaterial()
  self.FeatureMaterial = nil
  local model_util = require("client.common.model_util")
  model_util.ClearActorMeshCompsFeatureMaterial(self:GetOwner())
end
function CharacterAvatarComponent:ShouldUpdateAvatarLODByConfig(InSlot, InAvatarHandle)
  if InSlot ~= EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot then
    return false
  end
  local uPawn = self:GetOwner()
  if not slua.isValid(uPawn) or not slua.isValid(InAvatarHandle) then
    return false
  end
  if not InAvatarHandle.bEnableSelfForceLODInVehicle then
    return false
  end
  local ENetRole = import("ENetRole")
  if uPawn.Role ~= ENetRole.ROLE_AutonomousProxy then
    return false
  end
  local bShouldUpdateLod = uPawn.IsFakeOnVehicle or uPawn:HasState(EPawnState.InVehicle) or uPawn:HasState(EPawnState.DriveVehicle)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if bShouldUpdateLod and GameInstance:GetExactDeviceLevel() > 0 then
    return true
  end
  return false
end
function CharacterAvatarComponent:CameraModeChange(newMode)
  print(bWriteLog and "CharacterAvatarComponent:CameraModeChange newMode" .. tostring(newMode))
  local EPlayerCameraMode = import("EPlayerCameraMode")
  if newMode ~= EPlayerCameraMode.PCM_Aim and self.bAutonomousLoadRes then
    local ArmorID = self:GetEquippedItemDefineID3(EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot).TypeSpecificID
    if 0 < ArmorID then
      self:SetAvatarForceLOD(EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot, 1)
    end
  end
end
local GetObjectName = function(Object)
  if not Object then
    return "nil"
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  return UKismetSystemLibrary.GetObjectName(Object)
end
function CharacterAvatarComponent:ShouldCheckArmVisibleError(bCheckAutonomous)
  if not self.bAvatarDebugReport then
    print("CharacterAvatarComponent:ShouldCheckArmVisibleError not bAvatarDebugReport")
    return false
  end
  if self.bHasReportArmVisibleError then
    return false
  end
  if bCheckAutonomous and not self.bAutonomousLoadRes then
    return false
  end
  if GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  return true
end
function CharacterAvatarComponent:CheckArmVisibleErrorOnce()
  if not self:ShouldCheckArmVisibleError(true) then
    return
  end
  self:AddTimerOnce(3, function()
    self:CheckArmVisibleErrorInner()
  end)
end
function CharacterAvatarComponent:CheckArmVisibleErrorInner()
  if self.bHasReportArmVisibleError then
    return
  end
  local bHasArm = false
  local bArmIsVisible
  local bHasHideArmCloth = false
  local bClothIsVisible
  for key, AvatarSyncData in pairs(self.NetAvatarData.SlotSyncData) do
    if (AvatarSyncData.ItemID == 1406891 or AvatarSyncData.ItemID == 1407123 or AvatarSyncData.ItemID == 1407522 or AvatarSyncData.ItemID == 1407441) and self:IsItemBlueprintExist(AvatarSyncData.SlotID, FItemDefineID(self.ItemType, AvatarSyncData.ItemID), false) then
      bHasHideArmCloth = true
      local MeshComp = self:GetMeshCompBySlot(AvatarSyncData.SlotID)
      if slua.isValid(MeshComp) then
        local bVisible = MeshComp:IsVisible()
        bClothIsVisible = bVisible
      end
    end
    if AvatarSyncData.ItemID == 503001 or AvatarSyncData.ItemID == 503002 or AvatarSyncData.ItemID == 503003 then
      bHasArm = true
      local MeshComp = self:GetMeshCompBySlot(AvatarSyncData.SlotID)
      if slua.isValid(MeshComp) then
        local bVisible = MeshComp:IsVisible()
        bArmIsVisible = bVisible
      end
    end
    if bHasArm and bHasHideArmCloth then
      break
    end
  end
  print("CharacterAvatarComponent:DebugReport bHasArm:" .. tostring(bHasArm) .. " bArmIsVisible:" .. tostring(bArmIsVisible) .. " bHasHideArmCloth:" .. tostring(bHasHideArmCloth) .. " bClothIsVisible:" .. tostring(bClothIsVisible))
  if bHasArm and bHasHideArmCloth and bArmIsVisible == true and bClothIsVisible == true then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local CurWorldTime = GamePlayTools.GetServerWorldTimeSeconds() or 0
    local ErrorContent = "WorldTime:" .. tostring(CurWorldTime) .. "\n"
    local ErrorContent = " NetAvatarData.SlotSyncData:" .. " WorldTime:" .. tostring(CurWorldTime) .. " \n"
    for key, AvatarSyncData in pairs(self.NetAvatarData.SlotSyncData) do
      ErrorContent = ErrorContent .. " SlotID:" .. tostring(AvatarSyncData.SlotID) .. " SubSlotID:" .. tostring(AvatarSyncData.SubSlotID) .. " ItemID:" .. tostring(AvatarSyncData.ItemID) .. " HideState:" .. tostring(AvatarSyncData.HideState) .. " ReplaceState:" .. tostring(AvatarSyncData.ReplaceState) .. " bForceHideState:" .. tostring(AvatarSyncData.bForceHideState) .. " ForceHideState:" .. tostring(AvatarSyncData.ForceHideState) .. "\n"
    end
    ErrorContent = ErrorContent .. "ViewSlotDesc: \n"
    for key, FAvatarSlotDesc in pairs(self.ViewSlotDesc) do
      local MeshComp = self:GetMeshCompBySlot(FAvatarSlotDesc.SlotID)
      ErrorContent = ErrorContent .. " ID:" .. tostring(FAvatarSlotDesc.ItemDefineID.TypeSpecificID) .. " ShowID:" .. tostring(FAvatarSlotDesc.RealShowItemDefineID.TypeSpecificID) .. " Slot:" .. tostring(FAvatarSlotDesc.SlotID) .. " Mesh:" .. tostring(GetObjectName(MeshComp and (MeshComp.SkeletalMesh or MeshComp.StaticMesh))) .. " IsVisible:" .. tostring(MeshComp and MeshComp:IsVisible()) .. " HideState:" .. tostring(FAvatarSlotDesc.HideState) .. " ReplaceState:" .. tostring(FAvatarSlotDesc.ReplaceState) .. " bForceHideState:" .. tostring(FAvatarSlotDesc.bForceHideState) .. "\n"
    end
    ErrorContent = ErrorContent .. " LogicSlotDesc: \n"
    for key, FAvatarSlotDesc in pairs(self.LogicSlotDesc) do
      ErrorContent = ErrorContent .. "   Slot:" .. tostring(key) .. "   SlotID:" .. tostring(FAvatarSlotDesc.SlotID) .. "   ID:" .. tostring(FAvatarSlotDesc.ItemDefineID.TypeSpecificID) .. "   ShowID:" .. tostring(FAvatarSlotDesc.RealShowItemDefineID.TypeSpecificID) .. "   SlotDescDiff" .. tostring(FAvatarSlotDesc.SlotDescDiff) .. "\n"
    end
    if slua_GameFrontendHUD then
      local BattleIDHexStr = slua_GameFrontendHUD:GetBattleIDHexStr()
      ErrorContent = ErrorContent .. " BattleIDHexStr: " .. tostring(BattleIDHexStr) .. "\n"
    end
    self.bHasReportArmVisibleError = true
    ErrorContent = ErrorContent .. " NetDataHistory: \n" .. self.DebugContent
    self:AvatarCrashPostBattle("AvatarArmVisibleError", ErrorContent)
  end
end
function CharacterAvatarComponent:AddNetAvatarDataDebugContent()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local CurWorldTime = GamePlayTools.GetServerWorldTimeSeconds() or 0
  self.DebugContent = self.DebugContent .. "NetAvatarData WorldTime:" .. tostring(CurWorldTime) .. "\n"
  for key, AvatarSyncData in pairs(self.NetAvatarData.SlotSyncData) do
    self.DebugContent = self.DebugContent .. " SlotID:" .. tostring(AvatarSyncData.SlotID) .. " ItemID:" .. tostring(AvatarSyncData.ItemID) .. "\n"
  end
  self.DebugContent = self.DebugContent .. debug.traceback() .. "\n"
end
function CharacterAvatarComponent:BuildNetAvatarDataReportArray()
  if not self.NetAvatarData or not self.NetAvatarData.SlotSyncData then
    return nil
  end
  local ReportArray = {}
  for _, AvatarSyncData in pairs(self.NetAvatarData.SlotSyncData) do
    table.insert(ReportArray, AvatarSyncData.SlotID or 0)
    table.insert(ReportArray, AvatarSyncData.ItemID or 0)
    table.insert(ReportArray, AvatarSyncData.HideState or 0)
  end
  if #ReportArray <= 0 then
    return nil
  end
  return ReportArray
end
function CharacterAvatarComponent:ReportNetAvatarDataByGameReport()
  local ReportArray = self:BuildNetAvatarDataReportArray()
  if not ReportArray then
    return
  end
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  GameReportUtils.ReplayReportData(4, ReportArray)
end
function CharacterAvatarComponent:CheckNetAvatarSlotID()
  if self.bHasReportNetAvatarError then
    return
  end
  local bError = false
  for key, AvatarSyncData in pairs(self.NetAvatarData.SlotSyncData) do
    if AvatarSyncData.SlotID == 0 then
      bError = true
      break
    end
  end
  if not bError then
    return
  end
  local ErrorContent = ""
  if bError then
    for key, AvatarSyncData in pairs(self.NetAvatarData.SlotSyncData) do
      ErrorContent = ErrorContent .. " SlotID:" .. tostring(AvatarSyncData.SlotID) .. " ItemID:" .. tostring(AvatarSyncData.ItemID) .. "\n"
    end
  end
  if slua_GameFrontendHUD then
    local BattleIDHexStr = slua_GameFrontendHUD:GetBattleIDHexStr()
    ErrorContent = ErrorContent .. " BattleIDHexStr: " .. tostring(BattleIDHexStr) .. "\n"
  end
  self.bHasReportNetAvatarError = true
  print(bWriteLog and "CharacterAvatarComponent:CheckNetAvatarSlotID ErrorContent: " .. ErrorContent)
  self:AvatarCrashPostBattle("AvatarNetAvatarSlotIDError", ErrorContent)
end
function CharacterAvatarComponent:AvatarCrashPostBattle(ErrorReason, ErrorContent)
  if GameStatus.IsInLobbyOrMainCity() then
    return
  end
  Client.AddAttachFileString(ErrorReason, true, ErrorContent)
  local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
  ReportPlatformCrashKit:ForceSend(tostring(ErrorReason) .. ErrorContent)
end
function CharacterAvatarComponent:AvatarCrashPost(ErrorReason, ErrorContent)
  if not self.LobbyAvatarExceptionReport then
    log(bWriteLog and "CharacterAvatarComponent:AvatarCrashPost is not Open")
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  Client.AddAttachFileString(ErrorReason, true, ErrorContent)
  local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
  ReportPlatformCrashKit:ForceSend(tostring(ErrorReason) .. ":ItemHandle LoadObject Failed " .. ErrorContent)
end
function CharacterAvatarComponent:PreOnRep_BodySlotStateChangedInternal()
  if not Client then
    return
  end
  print(bWriteLog and "CharacterAvatarComponent:PreOnRep_BodySlotStateChangedInternal")
  if Client and Client.IsDevelopment() then
    self:LogNetAvatarData()
  end
  if self:ShouldCheckArmVisibleError() then
    self:AddNetAvatarDataDebugContent()
  end
  if Client and Client.IsDevelopment() then
    self:CheckNetAvatarSlotID()
  end
end
function CharacterAvatarComponent:LogNetAvatarData()
  local DebugString = ""
  for key, AvatarSyncData in pairs(self.NetAvatarData.SlotSyncData) do
    DebugString = DebugString .. " SlotID:" .. tostring(AvatarSyncData.SlotID) .. " ItemID:" .. tostring(AvatarSyncData.ItemID) .. "\n"
  end
  print(bWriteLog and "CharacterAvatarComponent:LogNetAvatarData NetAvatarData: \n" .. DebugString)
end
function CharacterAvatarComponent:PostBuildAvatarSyncData()
  print(bWriteLog and "CharacterAvatarComponent:PostBuildAvatarSyncData")
  self:LogNetAvatarData()
end
function CharacterAvatarComponent:IsUnlockSpecialMove()
  local UGameplayStatics = import("GameplayStatics")
  local CurLevelName = UGameplayStatics.GetCurrentLevelName(self:GetOwner(), true)
  if IsEditor and CurLevelName == "Avatar_Editor" then
    return true
  end
  local EquipItemDefineID = self:GetEquippedItemDefineID3(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local XSuitItemID = EquipItemDefineID and EquipItemDefineID.TypeSpecificID or 0
  if XSuitItemID == 0 then
    return true
  end
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local UnLockFeatureType = require("GameLua.Activity.Commercialize.GamePlay.XSuit.UnLockFeatureType")
  local period = XSuitUtil:GetPeriodByItemId(XSuitItemID)
  if not period then
    return true
  end
  local level = XSuitUtil:GetLevelByItemId(XSuitItemID)
  if level < 2 then
    return false
  end
  local needUnlock, unlockLevel, unlockIndex = XSuitUtil:IsUnlockedFeature(period, UnLockFeatureType.SprintShow)
  if not unlockLevel or not unlockIndex then
    return true
  end
  if self.XSuitFeatureFlagMap and self.XSuitFeatureFlagMap[period] and self.XSuitFeatureFlagMap[period][unlockLevel] and self.XSuitFeatureFlagMap[period][unlockLevel][unlockIndex] and self.XSuitFeatureFlagMap[period][unlockLevel][unlockIndex].flag_state == 0 then
    return false
  end
  if not needUnlock then
    return true
  end
  if self.XSuitUnlockFeatureMap and self.XSuitUnlockFeatureMap[period] and self.XSuitUnlockFeatureMap[period][unlockLevel] and self.XSuitUnlockFeatureMap[period][unlockLevel][unlockIndex] and self.XSuitUnlockFeatureMap[period][unlockLevel][unlockIndex].state == 1 then
    return true
  end
  return false
end
function CharacterAvatarComponent:ReFreshAnimListOverride(AvatarHandle)
  print(bWriteLog and "CharacterAvatarComponent:ReFreshAnimListOverride")
  self:ApplyAnimListOverride(AvatarHandle, false)
  self:ApplyAnimListOverride(AvatarHandle, true)
end
function CharacterAvatarComponent:OnDestroyed()
  self.bScopeIn = nil
  self:Dispose()
  CharacterAvatarComponent.__super.OnDestroyed(self)
end
function CharacterAvatarComponent:CheckIsSlotItemIDMatched(AvatarSlotID, RealShowItemID)
  local EquipItemDefineID = self:GetEquippedItemDefineID3(AvatarSlotID)
  print(bWriteLog and string.format("CharacterAvatarComponent:CheckIsSlotItemIDMatched AvatarSlotID:%s, TypeSpecificID:%s, RealShowItemID:%s", tostring(AvatarSlotID), tostring(EquipItemDefineID and EquipItemDefineID.TypeSpecificID), tostring(RealShowItemID)))
  local ViewItemID = 0
  if self.ViewSlotDesc then
    local ViewItemDesc = self.ViewSlotDesc:Get(AvatarSlotID)
    if ViewItemDesc then
      ViewItemID = ViewItemDesc.RealShowItemDefineID.TypeSpecificID
    end
  end
  if EquipItemDefineID.TypeSpecificID ~= RealShowItemID and ViewItemID ~= RealShowItemID then
    print(bWriteLog and string.format("CharacterAvatarComponent:CheckIsSlotItemIDMatched ID Not Match EquipID: %s, ViewItemID: %s, RealShowItemID: %s", tostring(EquipItemDefineID.TypeSpecificID), tostring(ViewItemID), tostring(RealShowItemID)))
    return false
  end
  return true
end
function CharacterAvatarComponent:SwitchMeshToMinLOD(bSwitchToMinLOD)
  local EAvatarSpecialType = import("EAvatarSpecialType")
  for SlotID, SlotMeshDesc in pairs(self.LoadedMeshComps) do
    if SlotID == EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot then
      local AvatarHandle = self:GetLoadedHandle(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
      if slua.isValid(AvatarHandle) and AvatarHandle.SpecialType ~= EAvatarSpecialType.EAvatarSpecialType_MoreBoneCloth and AvatarHandle.SpecialType ~= EAvatarSpecialType.EAvatarSpecialType_ClothMidDeviceBiasLOD then
        goto lbl_55
      end
    end
    local MeshComp = SlotMeshDesc.MeshComp
    if slua.isValid(MeshComp) and MeshComp.SetMinLOD and MeshComp.LODInfo then
      if bSwitchToMinLOD then
        local LODNumber = MeshComp.LODInfo:Num()
        if 1 < LODNumber then
          MeshComp:SetMinLOD(LODNumber - 1)
        end
      else
        MeshComp:SetMinLOD(0)
      end
    end
    ::lbl_55::
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CAvatarComp = class(CActorComponentBase, nil, CharacterAvatarComponent)
return CAvatarComp