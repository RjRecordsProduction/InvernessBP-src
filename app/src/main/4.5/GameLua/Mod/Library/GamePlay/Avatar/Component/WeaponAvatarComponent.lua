local WeaponAvatarComponent = {}
local GUN_MASTER_SLOT = 7
local PENDANT_SLOT = 9
local EDrawDyeingMode = import("EDrawDyeingMode")
local StaticMeshComponentClass = import("/Script/Engine.MeshComponent")
local audio_util = require("client.common.audio_util")
local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
function WeaponAvatarComponent:ctor()
  self.ListenedEquipEvent = false
  self.LobbyLoopModifyTimer = nil
  self.CachedLoadedID = 0
  self.KillEffectActionID = nil
  self.MatLoopParticleActionID = nil
  self.LoopMatModifyActionID = nil
  self.LODParticleActionID = 0
  self.LoopActivateParticleActionID = 0
  self.LoopActivateParticleTimer = nil
  self.IsScopeIn = nil
  self.IsFpp = nil
  self.IsLobbyEquipped = nil
  local EffectMgrClass = require("GameLua.Mod.Library.GamePlay.Avatar.Component.WeaponAvatarEffectMgr")
  self.EffectManager = EffectMgrClass()
  self.bHasRegistPawnEvent = nil
  self._pendingAudioUpdate = nil
end
function WeaponAvatarComponent:OnRespawnBP()
  print(bWriteLog and "WeaponAvatarComponent:OnRespawnBP")
  if not self.LuaRecycled then
    return
  end
  self:AddControlEvent(self, "OnWeaponAvatarPutOnSlot", self.OnWeaponAvatarPutOnSlotLua, self)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  self.IsDS = UKismetSystemLibrary.IsDedicatedServer(self)
  if self.IsDS then
    return
  end
  self.EffectManager:Clear()
  local MasterSlotHandle = self:GetEquippedHandle(GUN_MASTER_SLOT)
  self.EffectManager:Init(MasterSlotHandle, self.Object)
  if not self:IsLobbyActor() then
    local OwnerWeapon = self:GetOwner()
    if slua.isValid(OwnerWeapon) then
      self:AddControlEvent(OwnerWeapon, "OnWeaponBaseEquipDelegate", self.HandleWeaponBaseEquip, self)
      self:AddControlEvent(OwnerWeapon, "OnWeaponBaseUnEquipDelegate", self.HandleWeaponBaseUnEquip, self)
      if self:IsTeammate() and not self:IsSelf() and OwnerWeapon.GetOwnerPawn then
        local OwnerPawn = OwnerWeapon:GetOwnerPawn()
        if slua.isValid(OwnerPawn) and OwnerPawn.GetWeaponManager and slua.isValid(OwnerPawn:GetWeaponManager()) and OwnerPawn:GetWeaponManager().GetCurrentUsingWeapon then
          local UsingWeapon = OwnerPawn:GetWeaponManager():GetCurrentUsingWeapon()
          if slua.isValid(UsingWeapon) and UsingWeapon == OwnerWeapon then
            local UGameplayStatics = import("GameplayStatics")
            local PlayerController = UGameplayStatics.GetPlayerController(self, 0)
            if slua.isValid(PlayerController) and not self.ListenedEquipEvent then
              self:AddControlEvent(PlayerController, "OnPlayerKilledOthersPlayer", self.OnKilledEvent, self)
              self.ListenedEquipEvent = true
            end
          end
        end
      end
    end
  end
  self:AddControlEvent(self, "OnWeaponAvatarLoaded2", self.OnWeaponAvatarLoadedLua, self)
end
function WeaponAvatarComponent:OnRecycleBP()
  print(bWriteLog and "WeaponAvatarComponent:OnRecycleBP")
  self.LuaRecycled = true
  local Utility = require("common.utility")
  xpcall(self.UnRegistEvents, Utility.ErrorMessageHandler, self)
  xpcall(self.RemoveAllTimer, Utility.ErrorMessageHandler, self)
  xpcall(self.RemoveAllGameTimer, Utility.ErrorMessageHandler, self)
  xpcall(self.CancelAllAsyncLoad, Utility.ErrorMessageHandler, self)
  self.ListenedEquipEvent = false
  self._pendingAudioUpdate = nil
  self.LobbyLoopModifyTimer = nil
  self.CachedLoadedID = 0
  self.KillEffectActionID = nil
  self.MatLoopParticleActionID = nil
  self.LoopMatModifyActionID = nil
  self.LODParticleActionID = 0
  self.LoopActivateParticleActionID = 0
  self.LoopActivateParticleTimer = nil
  self.IsScopeIn = nil
  self.IsFpp = nil
  self.IsLobbyEquipped = nil
  self.bHasRegistPawnEvent = false
  if self.EffectManager then
    self.EffectManager:Destroy()
  end
  if Client then
    self:DestroyLightPartComp()
  end
end
function WeaponAvatarComponent:DestroyLightPartComp()
  if not slua.isValid(self:GetOwner()) then
    return
  end
  local uComponentClass = import("/Script/Engine.FXSystemComponent")
  local targetArray = self:GetOwner():GetComponentsByTag(uComponentClass, "WeaponLight")
  if targetArray and targetArray:Num() > 0 then
    for _, ParticleComp in pairs(targetArray) do
      if slua.isValid(ParticleComp) then
        ParticleComp:K2_DestroyComponent(ParticleComp)
      end
    end
  end
end
function WeaponAvatarComponent:ReceiveBeginPlay()
  WeaponAvatarComponent.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "WeaponAvatarComponent:ReceiveBeginPlay")
  self:AddControlEvent(self, "OnWeaponAvatarPutOnSlot", self.OnWeaponAvatarPutOnSlotLua, self)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  self.IsDS = UKismetSystemLibrary.IsDedicatedServer(self)
  if self.IsDS then
    return
  end
  self.EffectManager:Clear()
  local MasterSlotHandle = self:GetEquippedHandle(GUN_MASTER_SLOT)
  self.EffectManager:Init(MasterSlotHandle, self.Object)
  self:AddControlEvent(self, "OnWeaponPartsRender", self.HandleOnWeaponPartsRender, self)
  if not self:IsLobbyActor() then
    local OwnerWeapon = self:GetOwner()
    if slua.isValid(OwnerWeapon) then
      self:AddControlEvent(OwnerWeapon, "OnWeaponBaseEquipDelegate", self.HandleWeaponBaseEquip, self)
      self:AddControlEvent(OwnerWeapon, "OnWeaponBaseUnEquipDelegate", self.HandleWeaponBaseUnEquip, self)
      if self:IsTeammate() and not self:IsSelf() and OwnerWeapon.GetOwnerPawn then
        local OwnerPawn = OwnerWeapon:GetOwnerPawn()
        if slua.isValid(OwnerPawn) and OwnerPawn.GetWeaponManager and slua.isValid(OwnerPawn:GetWeaponManager()) and OwnerPawn:GetWeaponManager().GetCurrentUsingWeapon then
          local UsingWeapon = OwnerPawn:GetWeaponManager():GetCurrentUsingWeapon()
          if slua.isValid(UsingWeapon) and UsingWeapon == OwnerWeapon then
            local UGameplayStatics = import("GameplayStatics")
            local PlayerController = UGameplayStatics.GetPlayerController(self, 0)
            if slua.isValid(PlayerController) and not self.ListenedEquipEvent then
              self:AddControlEvent(PlayerController, "OnPlayerKilledOthersPlayer", self.OnKilledEvent, self)
              self.ListenedEquipEvent = true
            end
          end
        end
      end
    end
  end
  self:AddControlEvent(self, "OnWeaponAvatarLoaded2", self.OnWeaponAvatarLoadedLua, self)
end
function WeaponAvatarComponent:OnWeaponAvatarPutOnSlotLua(SlotID)
  if not self.IsDS then
    return
  end
  if SlotID ~= GUN_MASTER_SLOT then
    return
  end
  local WeaponSkinDefineID = self:GetEquippedItemDefineID(SlotID)
  if not WeaponSkinDefineID or not WeaponSkinDefineID.TypeSpecificID then
    print(bWriteLog and "WeaponAvatarComponent:OnWeaponAvatarPutOnSlotLua WeaponSkinDefineID is nil ")
    return
  end
  local OwnerWeapon = self:GetOwner()
  if not (slua.isValid(OwnerWeapon) and OwnerWeapon.GetOwnerPawn) or not slua.isValid(OwnerWeapon:GetOwnerPawn()) then
    return
  end
  local Pawn = OwnerWeapon:GetOwnerPawn()
  local PlayerController = Pawn:GetPlayerControllerSafety()
  if not slua.isValid(PlayerController) then
    return
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local WeaponOverrideFeatureInfo = PlayerDataMgr.GetPlayerProgressFromServer(PlayerController.UID, ExtendAttribute.WeaponOverrideFeature)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local WeaponSkinGroupID = ItemUpgradeMgr:GetNormalGroupIDOfWeaponID(WeaponSkinDefineID.TypeSpecificID)
  print(bWriteLog and "WeaponAvatarComponent:OnWeaponAvatarPutOnSlotLua WeaponSkinGroupID: " .. WeaponSkinGroupID .. ", Type:" .. type(WeaponSkinGroupID))
  local OverrideFlag = WeaponOverrideFeatureInfo and WeaponOverrideFeatureInfo[WeaponSkinGroupID] or 0
  print(bWriteLog and "WeaponAvatarComponent:OnWeaponAvatarPutOnSlotLua Set WeaponOverrideFeatureSwitchTypeFlag: " .. OverrideFlag .. ", WeaponSkinID: " .. WeaponSkinDefineID.TypeSpecificID)
  OwnerWeapon.WeaponOverrideFeatureSwitchTypeFlag = OverrideFlag
end
function WeaponAvatarComponent:OnWeaponAvatarLoadedLua(SlotID, DefinedID)
  if self.IsDS then
    return
  end
  print(bWriteLog and "WeaponAvatarComponent:OnWeaponAvatarLoadedLua")
  if not self:IsLobbyActor() then
    if slua.isValid(self:GetOwner()) and self:GetOwner().IsHoldingInHand and self:GetOwner():IsHoldingInHand() then
      self:RegistPawnEvent()
      self:RequestUpdateAudioVolume()
    end
    self:UpdateWeaponLodLevel()
    self:UpdateAttachmentsLodLevel()
    self:UpdateDrawDyeing()
  else
    self:OnLobbyEquippedChanged()
  end
  self:RefreshFeatureMateria()
  self:ProcessLobbyPhysicsAsset(DefinedID)
  local ItemTypeSpecificID = DefinedID.TypeSpecificID
  if self.CachedLoadedID == ItemTypeSpecificID then
    return
  end
  self.CachedLoadedID = ItemTypeSpecificID
  self.EffectManager:Clear()
  local MasterSlotHandle = self:GetEquippedHandle(GUN_MASTER_SLOT)
  self.EffectManager:Init(MasterSlotHandle, self.Object)
  if not self:IsSelf() then
    if self.LODParticleActionID ~= 0 then
      self:RemoveAction(GUN_MASTER_SLOT, self.LODParticleActionID, false)
      self.LODParticleActionID = 0
    end
    self.LODParticleActionID = self:AddAction_ParticleByName(GUN_MASTER_SLOT, "LODParticle")
  end
  local MatParamCfg = require("GameLua.Mod.Library.GamePlay.Avatar.Component.WeaponMatParamModifyCfg")
  local MatCfg = MatParamCfg[ItemTypeSpecificID]
  if not MatCfg then
    self:RemoveLobbyLoopKillEffectTimer()
    self:RemoveLoopTypeEffectAction()
    self:RemoveLoopActivateParticle()
    return
  end
  if self:IsLobbyActor() then
    self:RemoveLobbyLoopKillEffectTimer()
    if MatCfg.Type == 1 then
      self.LobbyLoopModifyTimer = self:AddTimer(0, function()
        while true do
          self:TriggerKillingEffect(ItemTypeSpecificID)
          coroutine.yield(10)
        end
      end)
    end
  end
  if MatCfg.Type == 2 then
    self:RemoveLoopTypeEffectAction()
    self:AddTimer(0, function()
      if not self:IsLobbyActor() and not self:IsSelf() then
        local UIUtil = require("client.common.ui_util")
        local GameInst = UIUtil.GetGameInstance()
        if not GameInst then
          return
        end
        if GameInst:GetExactDeviceLevel() <= 0 then
          print(bWriteLog and "WeaponAvatarComponent MatParamEffect Not Execute , The Device Level" .. GameInst:GetExactDeviceLevel())
          return
        end
      end
      self.MatLoopParticleActionID = self:AddAction_ParticleByName(GUN_MASTER_SLOT, MatCfg.ParticleName)
      if self.LoopMatModifyActionID == nil then
        self.LoopMatModifyActionID = {}
      end
      for _, CfgIndex in pairs(MatCfg.CfgIndexList) do
        local LoopMatModifyActionID = self:AddAction_MatParamModify(GUN_MASTER_SLOT, CfgIndex)
        table.insert(self.LoopMatModifyActionID, LoopMatModifyActionID)
      end
    end)
  end
  if MatCfg.Type == 3 then
    self:RemoveLoopActivateParticle()
    self.LoopActivateParticleTimer = self:AddTimer(0, function()
      while true do
        if self.LoopActivateParticleActionID ~= 0 then
          self:RemoveAction(GUN_MASTER_SLOT, self.LoopActivateParticleActionID, false)
        end
        self.LoopActivateParticleActionID = self:AddAction_ParticleByName(GUN_MASTER_SLOT, MatCfg.ParticleName)
        coroutine.yield(MatCfg.ActivateTime)
      end
    end)
  end
end
function WeaponAvatarComponent:ProcessLobbyPhysicsAsset(DefinedID)
  if not self:IsLobbyActor() then
    return
  end
  local itemCfg = CDataTable.GetTableData("WeaponPhysicsAsset", DefinedID.TypeSpecificID)
  if itemCfg and itemCfg.physics_asset and itemCfg.physics_asset ~= "" then
    local Mesh = self:GetMeshCompbySlotID(7)
    if not slua.isValid(Mesh) then
      return
    end
    Mesh.bGenerateOverlapEvents = true
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local softObjPath = UKismetSystemLibrary.MakeSoftObjectPath(itemCfg.physics_asset)
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local PhysicsAsset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(softObjPath)
    if slua.isValid(PhysicsAsset) and Mesh.SetPhysicsAsset then
      Mesh:SetPhysicsAsset(PhysicsAsset, true)
      local ECollisionEnabled = import("ECollisionEnabled")
      Mesh:SetCollisionEnabled(ECollisionEnabled.QueryAndPhysics)
      Mesh:SetCollisionProfileName("Pawn")
      Mesh.bShouldUpdateOverLaps = true
    end
  end
end
function WeaponAvatarComponent:RemoveLobbyLoopKillEffectTimer()
  if self.LobbyLoopModifyTimer then
    self:RemoveTimer(self.LobbyLoopModifyTimer)
    self.LobbyLoopModifyTimer = nil
  end
end
function WeaponAvatarComponent:RemoveLoopTypeEffectAction()
  if self.MatLoopParticleActionID then
    self:RemoveAction(GUN_MASTER_SLOT, self.MatLoopParticleActionID, false)
    self.MatLoopParticleActionID = nil
  end
  if self.LoopMatModifyActionID then
    for _, ID in pairs(self.LoopMatModifyActionID) do
      self:RemoveAction(GUN_MASTER_SLOT, ID, false)
    end
    self.LoopMatModifyActionID = {}
  end
end
function WeaponAvatarComponent:RemoveLoopActivateParticle()
  if self.LoopActivateParticleActionID ~= 0 then
    self:RemoveAction(GUN_MASTER_SLOT, self.LoopActivateParticleActionID, false)
  end
  if self.LoopActivateParticleTimer then
    self:RemoveTimer(self.LoopActivateParticleTimer)
  end
end
function WeaponAvatarComponent:HandleWeaponBaseEquip()
  if not Client then
    return
  end
  print(bWriteLog and "WeaponAvatarComponent:HandleWeaponBaseEquip")
  self:RegistPawnEvent()
  if not self:IsSelf() and not self:IsTeammate() then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(self, 0)
  if not self.ListenedEquipEvent then
    print(bWriteLog and "WeaponAvatarComponent:HandleWeaponBaseEquip Start listen sucess")
    if slua.isValid(PlayerController) then
      self:AddControlEvent(PlayerController, "OnPlayerKilledOthersPlayer", self.OnKilledEvent, self)
    end
    self.ListenedEquipEvent = true
  end
  self:RequestUpdateAudioVolume()
end
function WeaponAvatarComponent:RequestUpdateAudioVolume()
  if self._pendingAudioUpdate then
    print(bWriteLog and "WeaponAvatarComponent:RequestUpdateAudioVolume already pending, skip")
    return
  end
  self._pendingAudioUpdate = true
  self:AddTimer(0, function()
    if not slua.isValid(self) then
      return
    end
    self._pendingAudioUpdate = nil
    self:UpdateWeaponAvatarAudioVolume()
  end)
end
function WeaponAvatarComponent:UpdateWeaponAvatarAudioVolume()
  print(bWriteLog and "WeaponAvatarComponent:UpdateWeaponAvatarAudioVolume - Enter function")
  local WeaponSkinDefineID = self:GetEquippedItemDefineID(GUN_MASTER_SLOT)
  if not WeaponSkinDefineID or not WeaponSkinDefineID.TypeSpecificID then
    print(bWriteLog and "WeaponAvatarComponent UpdateWeaponAvatarAudioVolume WeaponSkinDefineID is nil ")
    return
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  if not ItemUpgradeMgr then
    print(bWriteLog and "WeaponAvatarComponent:UpdateWeaponAvatarAudioVolume ItemUpgradeMgr is nil")
    return
  end
  local WeaponSkinGroupID = ItemUpgradeMgr:GetNormalGroupIDOfWeaponID(WeaponSkinDefineID.TypeSpecificID)
  local VolumeInfoMap = DataMgr.GetWeaponSkinSoundVolumeInfoByGroup(WeaponSkinGroupID)
  print(bWriteLog and "WeaponAvatarComponent:UpdateWeaponAvatarAudioVolume. SkinID:" .. tostring(WeaponSkinDefineID.TypeSpecificID) .. ", GroupID:" .. tostring(WeaponSkinGroupID))
  local VoiceParamCache = AvatarUtil.GetWeaponSkinVoiceParamCache()
  for AudioType, CachedParam in pairs(VoiceParamCache) do
    for _, rtpcKey in pairs(CachedParam.RTPCKeyList) do
      local AudioVolume = VolumeInfoMap and VolumeInfoMap[AudioType] or 100
      audio_util.SetRTPCValue(rtpcKey, AudioVolume, 0)
    end
  end
end
function WeaponAvatarComponent:RegistPawnEvent()
  if self.bHasRegistPawnEvent then
    return
  end
  print(bWriteLog and "WeaponAvatarComponent:RegistPawnEvent")
  local OwnerWeapon = self:GetOwner()
  if slua.isValid(OwnerWeapon) and OwnerWeapon.GetOwnerPawn and slua.isValid(OwnerWeapon:GetOwnerPawn()) then
    local Pawn = OwnerWeapon:GetOwnerPawn()
    if Pawn.OnScopeInDelegate and Pawn.OnScopeOutDelegate then
      self:AddControlEvent(Pawn, "OnScopeInDelegate", self.OnOwnerCharacterScopeIn, self)
      self:AddControlEvent(Pawn, "OnScopeOutDelegate", self.OnOwnerCharacterScopeOut, self)
    end
    if Pawn.OnPerspectiveChanged and Pawn.GetIsFPP then
      self:AddControlEvent(Pawn, "OnPerspectiveChanged", self.OnOwnerCharacterPerspectiveChanged, self)
      local PlayerController = Pawn:GetPlayerControllerSafety()
      if slua.isValid(PlayerController) then
        self:AddControlEvent(PlayerController, "OnSwitchCameraModeStart", self.OnSwitchCameraModeChanged, self)
      end
      self.IsFpp = Pawn:GetIsFPP()
      print(bWriteLog and "WeaponAvatarComponent:RegistPawnEvent self.IsFpp" .. tostring(self.IsFpp))
    end
    self:UpdateWeaponLodLevel()
    self:UpdateAttachmentsLodLevel()
    self.bHasRegistPawnEvent = true
  end
end
function WeaponAvatarComponent:RemovePawnEvent()
  if not self.bHasRegistPawnEvent then
    return
  end
  local OwnerWeapon = self:GetOwner()
  if slua.isValid(OwnerWeapon) and OwnerWeapon.GetOwnerPawn and slua.isValid(OwnerWeapon:GetOwnerPawn()) then
    local Pawn = OwnerWeapon:GetOwnerPawn()
    if Pawn.OnScopeInDelegate and Pawn.OnScopeOutDelegate then
      print(bWriteLog and "WeaponAvatarComponent:HandleWeaponBaseUnEquip unlisten scope event")
      self:RemoveControlEvent(Pawn, "OnScopeInDelegate")
      self:RemoveControlEvent(Pawn, "OnScopeOutDelegate")
    end
    if Pawn.OnPerspectiveChanged then
      self:RemoveControlEvent(Pawn, "OnPerspectiveChanged")
    end
    local PlayerController = Pawn:GetPlayerControllerSafety()
    if slua.isValid(PlayerController) then
      self:RemoveControlEvent(PlayerController, "OnSwitchCameraModeStart")
    end
  end
  self.bHasRegistPawnEvent = false
end
function WeaponAvatarComponent:OnLobbyEquippedChanged()
  if not self:IsLobbyActor() then
    return
  end
  self.IsLobbyEquipped = false
  local OwnerWeapon = self:GetOwner()
  if slua.isValid(OwnerWeapon) and OwnerWeapon.GetOwnerPawn then
    local Pawn = OwnerWeapon:GetOwnerPawn()
    if slua.isValid(Pawn) then
      self.IsLobbyEquipped = true
    end
  end
  self:UpdateLobbyWeaponLodLevel()
end
function WeaponAvatarComponent:HandleWeaponBaseUnEquip()
  if not Client then
    return
  end
  self:RemovePawnEvent()
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(self, 0)
  if self.ListenedEquipEvent then
    print(bWriteLog and "WeaponAvatarComponent:HandleWeaponBaseUnEquip unlisten")
    if slua.isValid(PlayerController) then
      self:RemoveControlEvent(PlayerController, "OnPlayerKilledOthersPlayer")
    end
    self.ListenedEquipEvent = false
  end
end
function WeaponAvatarComponent:OnKilledEvent(FatalDamageParameter)
  if not Client then
    return
  end
  print(bWriteLog and "WeaponAvatarComponent:OnKilledEvent CauserKey" .. FatalDamageParameter.causerKey .. "VictimKey" .. FatalDamageParameter.victimKey .. "CauserWeaponAvatarID" .. FatalDamageParameter.causerWeaponAvatarID)
  local EquippedAvatarDefineID = self:GetEquippedItemDefineID(GUN_MASTER_SLOT)
  local ItemTypeSpecificID = EquippedAvatarDefineID.TypeSpecificID
  print(bWriteLog and "WeaponAvatarComponent:OnKilledEvent ItemTypeSpecificID " .. ItemTypeSpecificID)
  if FatalDamageParameter.causerWeaponAvatarID ~= ItemTypeSpecificID then
    return
  end
  local OwnerBaseChar = self:GetOwnerCharacter()
  local ScriptGameplayStatics = import("ScriptGameplayStatics")
  if slua.isValid(OwnerBaseChar) then
    local OwnerPlayerKey = OwnerBaseChar.PlayerKey
    print(bWriteLog and string.format("WeaponAvatarComponent:OnKilledEvent OwnerPlayerKey %s", OwnerPlayerKey))
    if OwnerPlayerKey and OwnerPlayerKey == FatalDamageParameter.causerKey then
      print(bWriteLog and "WeaponAvatarComponent:TriggerKillingEffect")
      self:TriggerKillingEffect(FatalDamageParameter.causerWeaponAvatarID)
      self:TriggerKillingAnimEffect()
      self.EffectManager:OnThisWeaponKilledOther(FatalDamageParameter)
    end
    if ItemTypeSpecificID == 1101001131 then
      print(bWriteLog and OwnerBaseChar)
    end
  end
end
function WeaponAvatarComponent:OnOwnerCharacterScopeIn(bBegin)
  print(bWriteLog and "WeaponAvatarComponent:OnOwnerCharacterScopeIn")
  self.IsScopeIn = true
  self:UpdateWeaponLodLevel()
  self:UpdateAttachmentsLodLevel()
  self:UpdatePendantVisibility()
  if bBegin then
    self:InterruptWeaponShow()
  end
end
function WeaponAvatarComponent:InterruptWeaponShow()
  local OwnerWeapon = self:GetOwner()
  if not slua.isValid(OwnerWeapon) then
    print(bWriteLog and "WeaponAvatarComponent:InterruptWeaponShow not slua.isValid(OwnerWeapon)")
    return
  end
  if OwnerWeapon.GetOwnerPawn and slua.isValid(OwnerWeapon:GetOwnerPawn()) then
    local Pawn = OwnerWeapon:GetOwnerPawn()
    if Pawn:IsCastingSkillIDFix(1014405) then
      print(bWriteLog and "WeaponAvatarComponent:InterruptWeaponShow StopSkill")
      Pawn:StopSkill(1014405)
    end
  end
end
function WeaponAvatarComponent:OnOwnerCharacterScopeOut(_)
  print(bWriteLog and "WeaponAvatarComponent:OnOwnerCharacterScopeOut")
  self.IsScopeIn = false
  self:UpdateWeaponLodLevel()
  self:UpdatePendantVisibility()
  self:UpdateAttachmentsLodLevel()
end
function WeaponAvatarComponent:OnOwnerCharacterPerspectiveChanged(bIsFpp)
  print(bWriteLog and "WeaponAvatarComponent:OnOwnerCharacterPerspectiveChanged bIsFpp:" .. tostring(bIsFpp))
  self:UpdateIsFPP()
  self:UpdateWeaponLodLevel()
  self:UpdateAttachmentsLodLevel()
  self:FixAttachSocketPosition()
end
function WeaponAvatarComponent:OnSwitchCameraModeChanged()
  self:UpdateIsFPP()
  self:UpdateWeaponLodLevel()
end
function WeaponAvatarComponent:UpdateIsFPP()
  local OwnerWeapon = self:GetOwner()
  if slua.isValid(OwnerWeapon) and OwnerWeapon.GetOwnerPawn and slua.isValid(OwnerWeapon:GetOwnerPawn()) then
    local Pawn = OwnerWeapon:GetOwnerPawn()
    if not slua.isValid(Pawn) then
      return
    end
    local _IsFpp = Pawn:GetIsFPP()
    if _IsFpp == self.IsFpp then
      return
    end
    self.IsFpp = _IsFpp
    print(bWriteLog and "WeaponAvatarComponent:UpdateIsFPP" .. tostring(self.IsFpp))
  end
end
function WeaponAvatarComponent:FixAttachSocketPosition()
  if self.IsFpp then
    return
  end
  if not self:IsSelf() then
    return
  end
  if self:CurrentWeaponHaveInteract() then
    self:AddTimerLoop(0.2, function()
      self:ResetAttachmentSocket()
    end, 2, 0.3)
  end
end
function WeaponAvatarComponent:CurrentWeaponHaveInteract()
  local AvatarHandle = self:GetEquippedHandle(GUN_MASTER_SLOT)
  local ECharSpecialLevelSequenceType = import("ECharSpecialLevelSequenceType")
  local bHasDIYWeaponCheck = false
  if AvatarHandle and slua.isValid(AvatarHandle) and AvatarHandle.WeaponSpecialLevelSequenceList then
    for i, v in pairs(AvatarHandle.WeaponSpecialLevelSequenceList) do
      if v.LevelSequenceType == ECharSpecialLevelSequenceType.ECharSpecLvSeq_WeaponCheck then
        bHasDIYWeaponCheck = true
        break
      end
    end
  end
  return bHasDIYWeaponCheck
end
function WeaponAvatarComponent:UpdateWeaponLodLevel()
  if not self:IsSelf() then
    return
  end
  local MasterSlotHandle = self:GetEquippedHandle(GUN_MASTER_SLOT)
  if not slua.isValid(MasterSlotHandle) then
    print(bWriteLog and "WeaponAvatarComponent UpdateWeaponLodLevel No Mastergun Handle")
    return
  end
  if not MasterSlotHandle.NeedSwitchLodOnScope and not MasterSlotHandle.NeedSwitchLodOnFpp then
    print(bWriteLog and "WeaponAvatarComponent UpdateWeaponLodLevel No NeedSwitchLodOnScope and No NeedSwitchLodOnFpp")
    return
  end
  local Mesh = self:GetMeshCompbySlotID(GUN_MASTER_SLOT)
  if not slua.isValid(Mesh) then
    print(bWriteLog and "WeaponAvatarComponent UpdateWeaponLodLevel Not Valid Mesh")
    return
  end
  if not Mesh.SetForcedLOD then
    print(bWriteLog and "WeaponAvatarComponent UpdateWeaponLodLevel Not SetForcedLOD function ")
    return
  end
  local bNeedHighLOD = false
  if MasterSlotHandle.NeedSwitchLodOnScope and self.IsScopeIn then
    bNeedHighLOD = true
  elseif MasterSlotHandle.NeedSwitchLodOnFpp and self.IsFpp then
    bNeedHighLOD = true
  end
  local bCanSwitchCutMesh = self.CanSwitchCutMesh and self:CanSwitchCutMesh(GUN_MASTER_SLOT) and self.UpdateCutMeshBySlotID
  if bCanSwitchCutMesh then
    local logMsg = self.IsScopeIn and "IsScopeIn" or bNeedHighLOD and "IsFpp" or "Normal"
    print(bWriteLog and string.format("WeaponAvatarComponent:UpdateWeaponLodLevel %s UpdateMeshBySlotID", logMsg))
    self:UpdateCutMeshBySlotID(GUN_MASTER_SLOT, bNeedHighLOD)
  else
    local targetLOD = bNeedHighLOD and 2 or 0
    local logMsg = self.IsScopeIn and "IsScopeIn" or bNeedHighLOD and "IsFpp" or "Normal"
    print(bWriteLog and string.format("WeaponAvatarComponent:UpdateWeaponLodLevel %s SetForceLOD %d", logMsg, targetLOD))
    Mesh:SetForcedLOD(targetLOD)
  end
end
function WeaponAvatarComponent:UpdateLobbyWeaponLodLevel()
  local Mesh = self:GetMeshCompbySlotID(GUN_MASTER_SLOT)
  if not slua.isValid(Mesh) or not Mesh.SetForcedLOD then
    print(bWriteLog and "WeaponAvatarComponent UpdateWeaponLodLevel Not Valid Mesh")
    return
  end
  local MasterSlotHandle = self:GetEquippedHandle(GUN_MASTER_SLOT)
  if not slua.isValid(MasterSlotHandle) then
    print(bWriteLog and "WeaponAvatarComponent UpdateWeaponLodLevel No Mastergun Handle")
    return
  end
  local forcedLod
  if MasterSlotHandle.NeedSwitchLodOnLobbyEquipped and self.IsLobbyEquipped then
    print(bWriteLog and "WeaponAvatarComponent:UpdateWeaponLodLevel IsLobbyEquipped SetForceLOD 2")
    forcedLod = 2
  else
    print(bWriteLog and "WeaponAvatarComponent:UpdateWeaponLodLevel SetForceLOD 1")
    forcedLod = 1
  end
  Mesh:SetForcedLOD(forcedLod)
  if forcedLod == 1 then
    local mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SkelMeshLODManager)
    if mgr and Mesh and slua.isValid(Mesh.SkeletalMesh) then
      local numLODs = Mesh.GetNumLODs and Mesh:GetNumLODs() or nil
      mgr:PunchLODHoles(Mesh.SkeletalMesh, {1}, forcedLod - 1, numLODs)
    end
  end
end
function WeaponAvatarComponent:UpdateLobbyAttachmentsLodLevel(SlotID)
  local Handle = self:GetEquippedHandle(SlotID)
  local Mesh = self:GetMeshCompbySlotID(SlotID)
  if not slua.isValid(Handle) or not slua.isValid(Mesh) then
    print(bWriteLog and "WeaponAvatarComponent:UpdateLobbyAttachmentsLodLevel Not Valid Handle or Mesh")
    return
  end
  if SlotID == GUN_MASTER_SLOT then
    print(bWriteLog and "WeaponAvatarComponent:UpdateLobbyAttachmentsLodLevel master slot, delegating to UpdateLobbyWeaponLodLevel")
    self:UpdateLobbyWeaponLodLevel()
    return
  end
  print(bWriteLog and "WeaponAvatarComponent:UpdateLobbyAttachmentsLodLevel SetForceLOD 1")
  if Mesh.SetForcedLOD then
    Mesh:SetForcedLOD(1)
  elseif Mesh.SetForcedLodModel then
    Mesh:SetForcedLodModel(1)
  end
  local mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SkelMeshLODManager)
  if mgr and Mesh and slua.isValid(Mesh.SkeletalMesh) then
    local numLODs = Mesh.GetNumLODs and Mesh:GetNumLODs() or nil
    mgr:PunchLODHoles(Mesh.SkeletalMesh, {1}, 0, numLODs)
  end
  Mesh.bUseAttachParentBound = true
end
function WeaponAvatarComponent:UpdateAttachmentsLodLevel()
  local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
  self:UpdateItemLodLevel(EWeaponAttachmentSocketType.OpticalSight)
  self:UpdateItemLodLevel(EWeaponAttachmentSocketType.Magazine)
  self:UpdateItemLodLevel(EWeaponAttachmentSocketType.AngledOpticalSight)
  self:UpdateItemLodLevel(EWeaponAttachmentSocketType.GunPoint)
  self:UpdateItemLodLevel(EWeaponAttachmentSocketType.Gunstock)
end
function WeaponAvatarComponent:UpdateItemLodLevel(Socket)
  if not self:IsSelf() then
    return
  end
  local SightHandle = self:GetEquippedHandle(Socket)
  if not slua.isValid(SightHandle) then
    print(bWriteLog and string.format("WeaponAvatarComponent UpdateAttachmentLodLevel No Valid Handle Socket: %d", Socket))
    return
  end
  if not SightHandle.NeedSwitchLodOnScope then
    print(bWriteLog and "WeaponAvatarComponent UpdateAttachmentLodLevel No NeedSwitchLodOnScope and No NeedSwitchLodOnFpp")
    return
  end
  local Mesh = self:GetMeshCompbySlotID(Socket)
  if not slua.isValid(Mesh) then
    print(bWriteLog and "WeaponAvatarComponent UpdateAttachmentLodLevel Not Valid Mesh")
    return
  end
  local bNeedHighLOD = false
  if SightHandle.NeedSwitchLodOnScope and self.IsScopeIn then
    bNeedHighLOD = true
  end
  local bCanSwitchCutMesh = self.CanSwitchCutMesh and self:CanSwitchCutMesh(Socket) and self.UpdateCutMeshBySlotID
  if bCanSwitchCutMesh then
    local logMsg = self.IsScopeIn and "IsScopeIn" or bNeedHighLOD and "IsFpp" or "Normal"
    print(bWriteLog and string.format("WeaponAvatarComponent:UpdateItemLodLevel %s UpdateMeshBySlotID Socket: %d", logMsg, Socket))
    self:UpdateCutMeshBySlotID(Socket, bNeedHighLOD)
  else
    local targetLOD = bNeedHighLOD and 2 or 0
    local logMsg = self.IsScopeIn and "IsScopeIn" or bNeedHighLOD and "IsFpp" or "Normal"
    print(bWriteLog and string.format("WeaponAvatarComponent:UpdateItemLodLevel %s SetForceLOD %d Socket: %d", logMsg, targetLOD, Socket))
    if Mesh.SetForcedLOD then
      Mesh:SetForcedLOD(targetLOD)
    elseif Mesh.SetForcedLodModel then
      Mesh:SetForcedLodModel(targetLOD)
    end
  end
end
function WeaponAvatarComponent:UpdatePendantVisibility()
  if not self:IsSelf() then
    return
  end
  local MasterSlotHandle = self:GetEquippedHandle(GUN_MASTER_SLOT)
  if not slua.isValid(MasterSlotHandle) or not MasterSlotHandle.bHidePendantOnScope then
    return
  end
  local Mesh = self:GetMeshCompbySlotID(PENDANT_SLOT)
  if not slua.isValid(Mesh) then
    print(bWriteLog and "WeaponAvatarComponent UpdatePendantVisibility Without ANY Valid Pendant Mesh")
    return
  end
  Mesh:SetHiddenInGame(self.IsScopeIn, false)
end
function WeaponAvatarComponent:TriggerKillingAnimEffect()
  local Entity = self:GetAvatarEntity(GUN_MASTER_SLOT, -1)
  if not slua.isValid(Entity) then
    return
  end
  local MeshComponent = Entity.MeshComponent
  if not slua.isValid(MeshComponent) then
    return
  end
  if MeshComponent.GetAnimInstance then
    local AnimIns = MeshComponent:GetAnimInstance()
    if not slua.isValid(AnimIns) then
      return
    end
    if AnimIns.BPOnPlayerKillEvent then
      AnimIns:BPOnPlayerKillEvent()
    end
  end
end
function WeaponAvatarComponent:TriggerKillingEffect(WeaponAvatarID)
  if self.KillEffectActionID then
    self:RemoveAction(GUN_MASTER_SLOT, self.KillEffectActionID, false)
  end
  self.KillEffectActionID = self:AddAction_ParticleByName(GUN_MASTER_SLOT, "KillEffect")
  local MatParamCfg = require("GameLua.Mod.Library.GamePlay.Avatar.Component.WeaponMatParamModifyCfg")
  local Cfg = MatParamCfg[WeaponAvatarID]
  if Cfg and Cfg.Type == 1 then
    self:ModifyMatParam(GUN_MASTER_SLOT, Cfg.ParamName, Cfg.ContinueTime, Cfg.StartValue, Cfg.EndValue)
  end
end
function WeaponAvatarComponent:ModifyMatParam(SlotID, ParamName, ContinueTime, StartValue, EndValue)
  if self.ParamModifyTimer then
    self:RemoveTimer(self.ParamModifyTimer)
  end
  local Entity = self:GetAvatarEntity(SlotID, -1)
  if not slua.isValid(Entity) then
    return
  end
  local MeshComponent = Entity.MeshComponent
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  local StartTime = uGameState:GetServerWorldTimeSeconds()
  local DelayTime = ContinueTime
  self.ParamModifyTimer = self:AddTimer(0, function()
    if not slua.isValid(MeshComponent) then
      return
    end
    local Materials = MeshComponent:GetMaterials()
    for Index, Mat in pairs(Materials) do
      local DynamicMaterial = MeshComponent:CreateDynamicMaterialInstance(Index, Mat)
    end
    while slua.isValid(MeshComponent) and slua.isValid(uGameState) do
      local TimeNow = uGameState:GetServerWorldTimeSeconds()
      local DeltaTime = TimeNow - StartTime
      local AllMaterials = MeshComponent:GetMaterials()
      for Index, Mat in pairs(AllMaterials) do
        local InParam = DeltaTime / ContinueTime * (EndValue - StartValue) + StartValue
        if slua.isValid(Mat) and Mat.SetScalarParameterValue then
          Mat:SetScalarParameterValue(ParamName, InParam)
        end
      end
      if DeltaTime > DelayTime then
        break
      end
      coroutine.yield(0)
    end
  end)
end
function WeaponAvatarComponent:RequestDIYPlan(weaponId, planId)
  local uid = self.OwnerPlayerUID
  print(bWriteLog and "xxxx DiyWeaponUtils.RequestPlayerWeaponData " .. uid)
  print(bWriteLog and "xxxx weaponId = ", weaponId)
  print(bWriteLog and "xxxx planId = ", planId)
  local WeaponDiyHandler = require("client.network.Protocol.WeaponDiyHandler")
  local data_type = 1
  local data_param
  if tonumber(planId) == 0 then
    data_param = {bRec = true, weaponId = weaponId}
  else
    data_param = {
      tostring(weaponId) .. "-" .. planId
    }
  end
  local logic_island_status = require("GameLua.Mod.SocialIsland.Client.IslandStatusLogic")
  local myGameId = logic_island_status.myGameId
  log(bWriteLog and "xxxx myGameId = " .. tostring(myGameId))
  WeaponDiyHandler.send_get_player_ds_data_req(uid, data_type, data_param, "ds", myGameId)
end
function WeaponAvatarComponent:ReceiveEndPlay(EndPlayReason)
  self.ListenedEquipEvent = false
  if self.EffectManager then
    self.EffectManager:Destroy()
  end
  WeaponAvatarComponent.__super.ReceiveEndPlay(self, EndPlayReason, false)
end
function WeaponAvatarComponent:GetLobbyStanbyActionID()
  return self:GetLobbyExclusiveActionID("Standby", "StanbyActionID")
end
function WeaponAvatarComponent:GetLobbyPoseReloadActionID()
  return self:GetLobbyExclusiveActionID("PoseReload", "PoseReloadActionID")
end
function WeaponAvatarComponent:GetLobbyHighlightActionID()
  return self:GetLobbyExclusiveActionID("Highlight", "HighlightActionID")
end
function WeaponAvatarComponent:GetLobbyExclusiveActionID(ActionKey, ConfigKey)
  local MasterSlotHandle = self:GetEquippedHandle(GUN_MASTER_SLOT)
  if not slua.isValid(MasterSlotHandle) then
    log(bWriteLog and "WeaponAvatarComponent GetLobbyExclusiveActionID No Mastergun Handle")
    return 0
  end
  local ActionCfg = MasterSlotHandle.SkinExclusiveActions:Get(ActionKey)
  if ActionCfg then
    log(bWriteLog and string.format("WeaponAvatarComponent GetLobbyExclusiveActionID, Action: %s ActionID: %d", ActionKey, ActionCfg.ActionID))
    return ActionCfg.ActionID
  else
    local OriginID = self:RedirectToUnskinnedWeaponId()
    local Cfg = CDataTable.GetTableData("LobbyWeaponClassTable", OriginID)
    if Cfg then
      local ActionID = Cfg[ConfigKey]
      log(bWriteLog and string.format("WeaponAvatarComponent GetLobbyExclusiveActionID Default Action: %s ActionID: %d", ActionKey, ActionID))
      return ActionID
    else
      log(bWriteLog and "WeaponAvatarComponent GetLobbyExclusiveActionID No LobbyWeaponClassTable Cfg")
      return 0
    end
  end
end
function WeaponAvatarComponent:RedirectToUnskinnedWeaponId()
  local EquippedAvatarDefineID = self:GetEquippedItemDefineID(GUN_MASTER_SLOT)
  local ItemTypeSpecificID = EquippedAvatarDefineID.TypeSpecificID
  local OriginID = ItemTypeSpecificID * 100
  local SkinMapCfg = CDataTable.GetTableData("WeaponSkinMapping", ItemTypeSpecificID)
  if SkinMapCfg then
    OriginID = SkinMapCfg.WeaponId * 100
  else
    local BPReuseCfg = CDataTable.GetTableData("BPIDReuseMap", ItemTypeSpecificID * 100)
    if BPReuseCfg then
      OriginID = BPReuseCfg.ReuseID
    end
  end
  return OriginID
end
function WeaponAvatarComponent:PreReloadAllEquippedAvatar()
  print(bWriteLog and "WeaponAvatarComponent:PreReloadAllEquippedAvatar")
  if self.EffectManager then
    self.EffectManager:OnReloadAllEquippedAvatar()
  end
end
function WeaponAvatarComponent:GetPitchRange(PoseData, Pitch)
  local PitchList = {}
  for PitchKey, _ in pairs(PoseData) do
    table.insert(PitchList, PitchKey)
  end
  table.sort(PitchList)
  if #PitchList ~= 3 then
    return
  end
  if Pitch >= PitchList[1] and Pitch < PitchList[2] then
    return PitchList[1], PitchList[2]
  elseif Pitch >= PitchList[2] and Pitch <= PitchList[3] then
    return PitchList[2], PitchList[3]
  end
end
function WeaponAvatarComponent:ChangeAllMeshToFeatureMaterial(material)
  if not Client then
    return
  end
  self.FeatureMaterial = material
  local model_util = require("client.common.model_util")
  model_util.ChangeActorAllMeshCompFeatureMaterial(self:GetOwner(), material)
end
function WeaponAvatarComponent:ClearAllFeatureMaterial()
  if not Client then
    return
  end
  self.FeatureMaterial = nil
  local model_util = require("client.common.model_util")
  model_util.ClearActorMeshCompsFeatureMaterial(self:GetOwner())
end
function WeaponAvatarComponent:RefreshFeatureMateria()
  if self.FeatureMaterial then
    local FeatureMaterial = self.FeatureMaterial
    self:ClearAllFeatureMaterial()
    self:ChangeAllMeshToFeatureMaterial(FeatureMaterial)
  end
end
function WeaponAvatarComponent:HandleOnWeaponPartsRender(WeaponSlotID)
  print(bWriteLog and string.format("WeaponAvatarComponent:OnWeaponPartsEquiped %s", tostring(WeaponSlotID)))
  self:RefreshFeatureMateria()
  local OwnerWeapon = self:GetOwner()
  local OwnerCharacter
  if slua.isValid(OwnerWeapon) and OwnerWeapon.GetOwnerPawn then
    OwnerCharacter = OwnerWeapon:GetOwnerPawn()
  end
  self:ConditionalHideDefaultAttachment(OwnerWeapon, WeaponSlotID)
  if self:IsLobbyActor() then
    self:UpdateLobbyAttachmentsLodLevel(WeaponSlotID)
    return
  end
  if slua.isValid(OwnerCharacter) and OwnerCharacter.ScreenMarkFeature then
    self:UpdateDrawDyeing()
  end
end
function WeaponAvatarComponent:ConditionalHideDefaultAttachment(OwnerWeapon, WeaponSlotID)
  local MasterSlotHandle = self:GetEquippedHandle(GUN_MASTER_SLOT)
  if not MasterSlotHandle or not slua.isValid(MasterSlotHandle) then
    return
  end
  local HiddenDefaultAttachments = MasterSlotHandle.HiddenDefaultAttachments
  if not HiddenDefaultAttachments or HiddenDefaultAttachments:Num() <= 0 then
    return
  end
  if WeaponSlotID == GUN_MASTER_SLOT then
    local HiddenReason = import("EDIYEntityHiddenReason").Hidden_DefaultAttachment
    for AttachmentSlot, _ in pairs(HiddenDefaultAttachments) do
      local AttachmentEntity = self:GetAvatarEntity(AttachmentSlot, -1)
      if AttachmentEntity and slua.isValid(AttachmentEntity) then
        AttachmentEntity:SetAvatarVisibilityByReason(self, not self:CheckIsDefaultAvatarEquipped(AttachmentSlot), HiddenReason)
      end
    end
  elseif HiddenDefaultAttachments:Get(WeaponSlotID) then
    local HiddenReason = import("EDIYEntityHiddenReason").Hidden_DefaultAttachment
    local AttachmentEntity = self:GetAvatarEntity(WeaponSlotID, -1)
    if AttachmentEntity and slua.isValid(AttachmentEntity) then
      AttachmentEntity:SetAvatarVisibilityByReason(self, not self:CheckIsDefaultAvatarEquipped(WeaponSlotID), HiddenReason)
    end
  end
end
function WeaponAvatarComponent:UpdateDrawDyeing()
  if not Client then
    return
  end
  local OwnerWeapon = self:GetOwner()
  local OwnerCharacter
  if slua.isValid(OwnerWeapon) and OwnerWeapon.GetOwnerPawn then
    OwnerCharacter = OwnerWeapon:GetOwnerPawn()
  end
  if not slua.isValid(OwnerCharacter) or not OwnerCharacter.ScreenMarkFeature then
    print(bWriteLog and "WeaponAvatarComponent UpdateDrawDyeing OwnerCharacter = nil")
    return
  end
  print(bWriteLog and "WeaponAvatarComponent UpdateDrawDyeing")
  if OwnerCharacter:IsLocalControlOrView() then
    local StaticMeshComponents = OwnerWeapon:GetComponentsByClass(StaticMeshComponentClass)
    for Index = 0, StaticMeshComponents:Num() - 1 do
      local StaticMeshComponent = StaticMeshComponents:Get(Index)
      if slua.isValid(StaticMeshComponent) then
        print(bWriteLog and "WeaponAvatarComponent UpdateDrawDyeing SetLastRenderInOpaque")
        StaticMeshComponent:SetLastRenderInOpaque(true)
      end
    end
  end
  if OwnerCharacter.ScreenMarkFeature.IsMarked and not self:IsSpectingPlayer() then
    local UIUtil = require("client.common.ui_util")
    local gameInstance = UIUtil.GetGameInstance()
    local nDeviceLevel = gameInstance:GetDeviceLevel()
    print(bWriteLog and "WeaponAvatarComponent  UpdateDrawDyeing IsMarked 1")
    local StaticMeshComponents = OwnerWeapon:GetComponentsByClass(StaticMeshComponentClass)
    for Index = 0, StaticMeshComponents:Num() - 1 do
      local StaticMeshComponent = StaticMeshComponents:Get(Index)
      if slua.isValid(StaticMeshComponent) then
        if 1 < nDeviceLevel then
          StaticMeshComponent:SetDrawDyeing(true)
          StaticMeshComponent:SetDrawDyeingMode(EDrawDyeingMode.EDDM_OCCLUDED)
          StaticMeshComponent:SetOccludedDyeingColor(FLinearColor(1, 0, 0, 1))
          StaticMeshComponent:SetLastRenderInOpaque(false)
        else
          StaticMeshComponent:SetLastRenderInOpaque(true)
        end
      end
    end
  else
    print(bWriteLog and "WeaponAvatarComponent UpdateDrawDyeing IsMarked 0")
    local StaticMeshComponents = OwnerWeapon:GetComponentsByClass(StaticMeshComponentClass)
    for Index = 0, StaticMeshComponents:Num() - 1 do
      local StaticMeshComponent = StaticMeshComponents:Get(Index)
      if slua.isValid(StaticMeshComponent) then
        StaticMeshComponent:SetDrawDyeing(false)
        StaticMeshComponent:SetLastRenderInOpaque(true)
      end
    end
  end
end
function WeaponAvatarComponent:IsSpectingPlayer()
  if Client then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController:IsSpectator() then
      return true
    end
  end
  return false
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CWeaponAvatarComp = class(object, nil, WeaponAvatarComponent)
return CWeaponAvatarComp