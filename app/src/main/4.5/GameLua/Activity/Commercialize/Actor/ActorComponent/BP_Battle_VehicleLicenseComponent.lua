local BP_Battle_VehicleLicenseComponent = {
  MulticastRPC = {}
}
BP_Battle_VehicleLicenseComponent.MulticastRPC.MulticastRPC_ShowVoice = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.UInt32
  }
}
local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
function BP_Battle_VehicleLicenseComponent:ctor()
  self.FeatureOwner = nil
  self.VoiceCDTable = nil
  self.Effect_VehicleID = 0
  self.ViewVehicleID = 0
end
function BP_Battle_VehicleLicenseComponent:ReceiveBeginPlay()
  BP_Battle_VehicleLicenseComponent.__super.ReceiveBeginPlay(self)
  if slua.isValid(self:GetOwner()) and self:GetOwner():HasAuthority() then
    if slua.isValid(self:GetOwner().VehicleAvatarComponent_BP) then
      self:AddControlEvent(self:GetOwner().VehicleAvatarComponent_BP, "OnVehicleAvatarPreChange", self.OnPreChangeVehicleAvatar, self)
    end
    if self:GetOwner() then
      self:AddControlEvent(self:GetOwner(), "OnAdvanceAvatarChanged", self.OnAdvanceAvatarChanged, self)
    end
    local VehicleSeat = self:GetOwner():GetVehicleSeats()
    if slua.isValid(VehicleSeat) then
      self:AddControlEvent(VehicleSeat, "OnSeatAttached", self.HandleSeatAttached, self)
    end
  end
  if Client then
    local uVehicle = self:GetOwner()
    if uVehicle then
      self:AddControlEvent(uVehicle, "OnVehicleHealthStateChanged", self.HandleHealthStateChanged, self)
      self:AddControlEvent(uVehicle, "VehicleBeforeWheelDestroy", self.HandleWheelDestroy, self)
    end
    if slua.isValid(self:GetOwner()) then
      if self:GetOwner().GetAvatarComponent then
        local VehicleAvatar = self:GetOwner():GetAvatarComponent()
        if slua.isValid(VehicleAvatar) then
          self:AddControlEvent(VehicleAvatar, "VehicleAvatarEqiuped", self.OnVehicleAvatarChange, self)
          self:AddControlEvent(VehicleAvatar, "VehicleLoadedFPPMesh", self.OnVehicleAvatarChange, self)
        end
      end
      if self:GetOwner().GetAdvanceAvatarComponent then
        local VehicleAdvanceAvatarComp = self:GetOwner():GetAdvanceAvatarComponent()
        if slua.isValid(VehicleAdvanceAvatarComp) then
          self:AddControlEvent(VehicleAdvanceAvatarComp, "OnAvatarAllMeshLoaded", self.OnVehicleAvatarChange, self)
          self:AddControlEvent(VehicleAdvanceAvatarComp, "OnServerAvatarEquiped", self.OnVehicleAvatarChange, self)
        end
      end
    end
  end
end
function BP_Battle_VehicleLicenseComponent:OnPreChangeVehicleAvatar(ItemID)
  self:ServerOnAvatarDataChange(ItemID)
end
function BP_Battle_VehicleLicenseComponent:OnAdvanceAvatarChanged(bIsAdvanceAvatar)
  if not bIsAdvanceAvatar then
    return
  end
  local VehicleAdvanceAvatarComp = self:GetOwner():GetAdvanceAvatarComponent()
  local SkinID = VehicleAdvanceAvatarComp.NetAvatarData.BaseID
  self:ServerOnAvatarDataChange(SkinID)
end
function BP_Battle_VehicleLicenseComponent:ServerOnAvatarDataChange(ItemID)
  self:RefreshFeatureOwner()
  if not slua.isValid(self.FeatureOwner) then
    print(bWriteLog and "BP_Battle_VehicleLicenseComponent OnPreChangeVehicleAvatar Can't Find Valid Driver")
    self:ChangeNetData_ItemID(-1)
    return
  end
  if not ItemID or ItemID == -1 then
    print(bWriteLog and "BP_Battle_VehicleLicenseComponent OnPreChangeVehicleAvatar ItemID is nil ")
    self:ChangeNetData_ItemID(-1)
    return
  end
  self:ChangeNetData_ItemID(ItemID)
  local bChange = false
  bChange = self:ChangeLicenseItemOnAvatarChange(ItemID) or bChange
  bChange = self:ChangeAccessoryOnAvatarChange(ItemID) or bChange
  bChange = self:ServerChangeEffectOnAvatarChange(ItemID) or bChange
  bChange = self:ChangeExtendedFeatureOnAvatarChange(ItemID) or bChange
  if not bChange then
    self:ChangeNetData_ItemID(-1)
  end
end
function BP_Battle_VehicleLicenseComponent:ChangeLicenseItemOnAvatarChange(ItemID)
  print(bWriteLog and "[LicensePlate] OnPreChangeVehicleAvatar ItemID" .. tostring(ItemID))
  if not slua.isValid(self.FeatureOwner) then
    print(bWriteLog and "[LicensePlate] OnPreChangeVehicleAvatar Can`t Find Valid Driver")
    self:SetInvalidLicenseNum()
    return false
  end
  local VehicleType = VehiclePlateLicenseUtil.GetVehicleType(ItemID)
  if VehicleType < 1 then
    print(bWriteLog and "[LicensePlate] OnPreChangeVehicleAvatar VehicleType < 1 ItemID:" .. tostring(ItemID))
    self:SetInvalidLicenseNum()
    return false
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local VehicleCollectTable = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(self.FeatureOwner.PlayerUID), ExtendAttribute.VehicleCollect)
  if not (VehicleCollectTable and VehicleCollectTable[VehicleType] and VehicleCollectTable[VehicleType].plate_number) or VehicleCollectTable[VehicleType].plate_number == "" then
    print(bWriteLog and "[LicensePlate] OnPreChangeVehicleAvatar VehicleCollectTable is nil UID:" .. tostring(self.FeatureOwner.PlayerUID))
    self:SetInvalidLicenseNum()
    return false
  end
  local PlateNum = VehicleCollectTable[VehicleType].plate_number
  local PlateTable = VehiclePlateLicenseUtil.GetPlateTable(PlateNum)
  for LuaIndex, Num in pairs(PlateTable) do
    self:ChangeLicenseNum(LuaIndex - 1, Num)
  end
  local ExtendedFeaturesData = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(self.FeatureOwner.PlayerUID), ExtendAttribute.VehicleExtendedFeatures)
  if ExtendedFeaturesData and ExtendedFeaturesData.plate_background_info and ExtendedFeaturesData.plate_background_info[VehicleType] then
    local bgId = ExtendedFeaturesData.plate_background_info[VehicleType]
    print(bWriteLog and "[LicensePlate] ChangeLicenseItemOnAvatarChange LicenseBackgroundId:" .. tostring(bgId))
    self.LicensePlate.LicenseBackgroundId = bgId
  else
    self.LicensePlate.LicenseBackgroundId = 0
  end
  return true
end
function BP_Battle_VehicleLicenseComponent:GetFeatureOwner()
  if slua.isValid(self.FeatureOwner) then
    return self.FeatureOwner
  end
  if slua.isValid(self:GetOwner()) and self:GetOwner().Ownership then
    local OwnerPlayerKey = self:GetOwner().Ownership.BelongToPlayerKey
    local uPawn = Game:GetPlayerByPlayerKey(OwnerPlayerKey)
    if slua.isValid(uPawn) then
      print(bWriteLog and "[LicensePlate] GetFeatureOwner Ownership BelongToPlayerKey" .. tostring(OwnerPlayerKey))
      self.FeatureOwner = uPawn
    end
  end
  return self.FeatureOwner
end
function BP_Battle_VehicleLicenseComponent:HandleHealthStateChanged(NewHealthState)
  local ESTExtraVehicleHealthState = import("ESTExtraVehicleHealthState")
  if NewHealthState == ESTExtraVehicleHealthState.VHS_Exploded then
    print(bWriteLog and "[VehicleAccessory] BP_Battle_VehicleLicenseComponent:HandleHealthStateChanged VHS_Exploded")
    self:PreChangeAccesssoryBrokenAvatar()
    self:DestoryChassisLight()
    self:DestroyPlateMesh()
  end
end
function BP_Battle_VehicleLicenseComponent:HandleWheelDestroy()
  print(bWriteLog and "BP_Battle_VehicleLicenseComponent:HandleWheelDestroy")
  self:DestoryChassisLight()
end
function BP_Battle_VehicleLicenseComponent:HandleSeatAttached(InCharacter, InSeatType, InSeatIndex)
  print(bWriteLog and "[LicensePlate] HandleSeatAttached")
  self:PlayVehicleCollectVideo(InCharacter)
end
function BP_Battle_VehicleLicenseComponent:PlayVehicleCollectVideo(InCharacter)
  print(bWriteLog and "[LicensePlate] PlayVehicleCollectVideo")
  local AvatarComp = self:GetOwner().VehicleAvatarComponent_BP
  if not slua.isValid(AvatarComp) then
    print(bWriteLog and "[LicensePlate] PlayVehicleCollectVideo AvatarComp is nil")
    return
  end
  if AvatarComp.bAdvanceAvatar then
    print(bWriteLog and "[LicensePlate] PlayVehicleCollectVideo AvatarComp is bAdvanceAvatar")
    return
  end
  local FeatureOwner = self:GetFeatureOwner()
  if not slua.isValid(FeatureOwner) then
    print(bWriteLog and "[LicensePlate] PlayVehicleCollectVideo FeatureOwner is not Valid")
    return
  end
  if not FeatureOwner:IsSameTeam(InCharacter) and not self:IsSocialIsland() then
    print(bWriteLog and "[LicensePlate] PlayVehicleCollectVideo not Same Team InCharacter:" .. tostring(InCharacter.PlayerKey) .. " FeatureOwner:" .. tostring(FeatureOwner.PlayerKey))
    return
  end
  if not self:CheckVehicleVoiceSwitchOpen(FeatureOwner.PlayerUID) then
    print(bWriteLog and "[LicensePlate] PlayVehicleCollectVideo CheckVehicleVoiceSwitchOpen false")
    return
  end
  local CurrentAvatarID = AvatarComp:GetCurrentAvatarID()
  if not VehiclePlateLicenseUtil.CheckHasUnLockFeature(VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.VOICE, FeatureOwner.PlayerUID, CurrentAvatarID) then
    print(bWriteLog and "[LicensePlate] PlayVehicleCollectVideo CheckHasUnLockFeature CurrentAvatarID:" .. tostring(CurrentAvatarID) .. " PlayerUID:" .. tostring(FeatureOwner.PlayerUID))
    return
  end
  local PlayerKey = tonumber(InCharacter.PlayerKey)
  self.VoiceCDTable = self.VoiceCDTable or {}
  if self.VoiceCDTable[PlayerKey] then
    print(bWriteLog and "[LicensePlate] PlayVehicleCollectVideo is In CD PlayerKey" .. tostring(PlayerKey))
    return
  end
  self.VoiceCDTable[PlayerKey] = true
  self:AddGameTimer(5, false, function()
    print(bWriteLog and "[LicensePlate] PlayVehicleCollectVideo Clear CD" .. tostring(PlayerKey))
    if self.VoiceCDTable and self.VoiceCDTable[PlayerKey] then
      self.VoiceCDTable[PlayerKey] = false
    end
  end)
  self:MulticastRPC_ShowVoice(CurrentAvatarID, tonumber(FeatureOwner.PlayerKey), PlayerKey)
end
function BP_Battle_VehicleLicenseComponent:MulticastRPC_ShowVoice(CurrentAvatarID, OwnerPlayerKey, InCharacterPlayerKey)
  if self:GetOwner():IsAuthority() then
    return
  end
  local InCharacter = Game:GetPlayerByPlayerKey(InCharacterPlayerKey)
  local FeatureOwner = Game:GetPlayerByPlayerKey(OwnerPlayerKey)
  if not slua.isValid(FeatureOwner) or not slua.isValid(InCharacter) then
    print(bWriteLog and "[VehicleVoice] Character not valid")
    return
  end
  if not CurrentAvatarID or CurrentAvatarID == 0 then
    print(bWriteLog and "[VehicleVoice] CurrentAvatarID is 0")
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPawn) then
    print(bWriteLog and "[VehicleVoice] uPawn not valid")
    return
  end
  print(bWriteLog and "[VehicleVoice] MulticastRPC_ShowVoice uPawn.TeamID" .. tostring(uPawn.TeamID) .. "InCharacter.TeamID" .. tostring(InCharacter.TeamID))
  if uPawn.TeamID ~= InCharacter.TeamID and not self:IsSocialIsland() then
    print(bWriteLog and "[VehicleVoice] uPawn not SameTeam")
    return
  end
  local Cfg = VehiclePlateLicenseUtil.GetCollectCarFeatureCfg(CurrentAvatarID)
  if not Cfg then
    print(bWriteLog and "[VehicleVoice] not Cfg CurrentAvatarID" .. tostring(CurrentAvatarID))
    return
  end
  local AvatarComp = self:GetOwner().VehicleAvatarComponent_BP
  if not slua.isValid(AvatarComp) then
    print(bWriteLog and "[VehicleVoice] MulticastRPC_ShowVoice AvatarComp is nil")
    return
  end
  if not AvatarComp:IsAssetsAlreadyAvailable(CurrentAvatarID) then
    print(bWriteLog and "[VehicleVoice] MulticastRPC_ShowVoice VehicleAvatar Asset is not downloaded CurrentAvatarID:" .. tostring(CurrentAvatarID))
    return
  end
  local Text = ""
  local VoiceID = 0
  local Msg = ""
  local SelfPlayerKey = tonumber(uPawn.PlayerKey)
  if OwnerPlayerKey == InCharacterPlayerKey then
    if InCharacterPlayerKey == SelfPlayerKey then
      Text = Cfg.DriverVoiceText or ""
      VoiceID = Cfg.DriverVoiceID or 0
    end
  else
    Text = Cfg.PassengerVoiceText or ""
    if InCharacterPlayerKey == SelfPlayerKey then
      VoiceID = Cfg.PassengerVoiceID or 0
    end
  end
  if OwnerPlayerKey == SelfPlayerKey then
    Msg = "<ChatSelfName>Me" .. LocUtil.GetLocalizeResStr(4164) .. "</>" .. Text
  else
    Msg = "<ChatOtherName>" .. FeatureOwner:GetPlayerNameSafety() .. LocUtil.GetLocalizeResStr(4164) .. "</>" .. Text
  end
  if self:IsSocialIsland() then
    print(bWriteLog and "BP_Battle_VehicleLicenseComponent:Text == nil")
    Text = ""
  end
  print(bWriteLog and "[VehicleVoice] MulticastRPC_ShowVoice Text" .. tostring(Text) .. "VoiceID" .. tostring(VoiceID))
  if Text ~= "" then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    InGameUITools.DisplayMessageInGame(Msg)
  end
  if VoiceID ~= 0 then
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
    ActorVoiceSystem.PlayMultiLanguageSound(VoiceID, self.Object, true)
  end
end
function BP_Battle_VehicleLicenseComponent:CheckVehicleVoiceSwitchOpen(PlayerUID)
  print(bWriteLog and "BP_Battle_VehicleLicenseComponent CheckVehicleVoiceSwitchOpen PlayerUID:" .. tostring(PlayerUID))
  if not PlayerUID then
    return true
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local VehicleExtendedFeatures = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(PlayerUID), ExtendAttribute.VehicleExtendedFeatures)
  if not VehicleExtendedFeatures then
    return true
  end
  local bVoiceOpen = true
  if VehicleExtendedFeatures.car_voice_switch and VehicleExtendedFeatures.car_voice_switch == 0 then
    print(bWriteLog and "BP_Battle_VehicleLicenseComponent CheckVehicleVoiceSwitchOpen car_voice_switch:0")
    bVoiceOpen = false
  end
  return bVoiceOpen
end
function BP_Battle_VehicleLicenseComponent:IsSocialIsland()
  if Client then
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    if MatchModeMgrSystem.IsSocialIslandMode(true) then
      print(bWriteLog and "BP_Battle_VehicleLicenseComponent:IsSocialIsland true")
      return true
    end
  else
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    if GamePlayTools.IsSocialIslandModeDS() then
      print(bWriteLog and "BP_Battle_VehicleLicenseComponent:IsSocialIsland true")
      return true
    end
  end
  print(bWriteLog and "BP_Battle_VehicleLicenseComponent:IsSocialIsland false")
  return false
end
function BP_Battle_VehicleLicenseComponent:RefreshFeatureOwner()
  local Driver = self:GetOwner():GetDriver()
  if slua.isValid(Driver) then
    self.FeatureOwner = Driver
  else
    self:GetFeatureOwner()
  end
end
function BP_Battle_VehicleLicenseComponent:ChangeAccessoryOnAvatarChange(vehicleItemId)
  print(bWriteLog and "[VehicleAccessory] ChangeAccessoryOnAvatarChange vehicleItemId" .. tostring(vehicleItemId))
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local VehicleAccessoryDataUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehicleAccessoryDataUtil")
  local VehicleCollectTable = VehicleAccessoryDataUtil:GetPlayerVehicleAccessoryData(tonumber(self.FeatureOwner.PlayerUID))
  if not (VehicleCollectTable and VehicleCollectTable[vehicleItemId]) or not next(VehicleCollectTable[vehicleItemId]) then
    print(bWriteLog and "[VehicleAccessory] ChangeAccessoryOnAvatarChange VehicleCollectTable is nil UID:" .. tostring(self.FeatureOwner.PlayerUID))
    self:RemoveAllAccessoryItem()
    return
  end
  local accessoryItems = VehicleCollectTable[vehicleItemId]
  local accessoryItemIds = {}
  log_tree(bWriteLog and "[VehicleAccessory] ChangeAccessoryOnAvatarChange accessoryItems", accessoryItems)
  for accessoryItemId, _ in pairs(accessoryItems) do
    table.insert(accessoryItemIds, accessoryItemId)
  end
  self:ChangeAccessoryItemList(accessoryItemIds)
  return true
end
function BP_Battle_VehicleLicenseComponent:PreChangeAccesssoryBrokenAvatar()
  log(bWriteLog and "[VehicleAccessory] BP_Battle_VehicleLicenseComponent:PreChangeAccesssoryBrokenAvatar")
  if not (self.LicensePlate and self.LicensePlate.ItemID) or not self.LicensePlate.AccessoryIdList then
    print(bWriteLog and "[vehicleAccessory]AsyncLoadAccessoryHandle invalid AccessoryIdList")
    return
  end
  local accessoryItemNum = self.LicensePlate.AccessoryIdList:Num()
  if accessoryItemNum <= 0 then
    print(bWriteLog and "[vehicleAccessory]AsyncLoadAccessoryHandle AccessoryIdList is empty")
    return
  end
  for i = 0, accessoryItemNum - 1 do
    local accItemId = self.LicensePlate.AccessoryIdList:Get(i)
    self:ChangeOneAccessoryToBroken(accItemId)
  end
end
function BP_Battle_VehicleLicenseComponent:ChangeExtendedFeatureOnAvatarChange(vehicleItemId)
  print(bWriteLog and "[VehicleAccessory] ChangeExtendedFeatureOnAvatarChange vehicleItemId" .. tostring(vehicleItemId))
  if not vehicleItemId then
    print(bWriteLog and "[VehicleAccessory] ChangeExtendedFeatureOnAvatarChange vehicleItemId is nil")
    return false
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local VehicleFeatureTable = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(self.FeatureOwner.PlayerUID), ExtendAttribute.VehicleExtendedFeatures)
  if not VehicleFeatureTable then
    print(bWriteLog and "[VehicleAccessory] ChangeAccessoryOnAvatarChange VehicleFeatureTable is nil UID:" .. tostring(self.FeatureOwner.PlayerUID))
    return false
  end
  local bChange = false
  local chassis_light_info = VehicleFeatureTable and VehicleFeatureTable.chassis_light_info and VehicleFeatureTable.chassis_light_info[vehicleItemId]
  if type(chassis_light_info) == "number" then
    self.LicensePlate.ChassisLightId = chassis_light_info
    bChange = true
  else
    self.LicensePlate.ChassisLightId = 0
  end
  return bChange
end
local IsUpgradeVehicle = function(ItemID)
  local cfgCar = CDataTable.GetTableData("VehicleRefitInfo", ItemID)
  if not cfgCar then
    return false
  end
  return true
end
function BP_Battle_VehicleLicenseComponent:ServerChangeEffectOnAvatarChange(ItemID)
  if not IsUpgradeVehicle(ItemID) then
    self:ChangeNetData_EffectIDList({})
    return false
  end
  local EffectList = VehiclePlateLicenseUtil.GetUpgradeEffectList(self.FeatureOwner.PlayerUID)
  if not EffectList or not next(EffectList) then
    self:ChangeNetData_EffectIDList({})
    return false
  end
  self:ChangeNetData_EffectIDList(EffectList)
  return true
end
function BP_Battle_VehicleLicenseComponent:OnVehicleAvatarChange()
  self.ViewVehicleID = self:GetOwner():GetVehicleSkinItemID()
  print(bWriteLog and "[VehicleEffect] BP_Battle_VehicleLicenseComponent:OnVehicleAvatarChange " .. tostring(self.ViewVehicleID))
  self:PreChangeEffect()
end
function BP_Battle_VehicleLicenseComponent:PreChangeEffect()
  print(bWriteLog and "[VehicleEffect] BP_Battle_VehicleLicenseComponent:PreChangeEffect")
  if self.ViewVehicleID ~= self.LicensePlate.ItemID then
    self.Effect_VehicleID = 0
    print(bWriteLog and "[VehicleEffect] BP_Battle_VehicleLicenseComponent:PreChangeEffect VehicleSkinID:" .. tostring(self.ViewVehicleID) .. " ~= self.LicensePlate.ItemID:" .. tostring(self.LicensePlate.ItemID))
    return
  end
  if self.Effect_VehicleID == self.ViewVehicleID then
    print(bWriteLog and "[VehicleEffect] BP_Battle_VehicleLicenseComponent:PreChangeEffect Equal " .. tostring(self.ViewVehicleID))
    return
  end
  self.Effect_VehicleID = self.ViewVehicleID
  if 0 >= self.LicensePlate.EffectIDList:Num() then
    return
  end
  for key, ItemID in pairs(self.LicensePlate.EffectIDList) do
    if not self.AccessoryHandleCacheMap:Get(ItemID) then
      local handle = self:CreatItemHandle(ItemID)
      self.AccessoryHandleCacheMap:Add(ItemID, handle)
    end
  end
  self:AsyncLoadEffectAssets(self.LicensePlate.EffectIDList)
end
function BP_Battle_VehicleLicenseComponent:OnEffectAssetLoadFinish()
  print(bWriteLog and "[VehicleEffect] BP_Battle_VehicleLicenseComponent:OnEffectAssetLoadFinish" .. tostring(self.LicensePlate.ItemID))
  if self.LicensePlate.ItemID < 0 then
    print(bWriteLog and "[VehicleEffect] BP_Battle_VehicleLicenseComponent:OnEffectAssetLoadFinish self.LicensePlate.ItemID < 0")
    return
  end
  for key, ItemID in pairs(self.LicensePlate.EffectIDList) do
    local handle = self.AccessoryHandleCacheMap:Get(ItemID)
    if not handle.bAdd and self:GetParticlePack(ItemID) then
      local Pack = self:GetParticlePack(ItemID).ParticleSfx
      if Pack then
        local FVehicleParticlePack = import("VehicleParticlePack")
        local ParticlePack = FVehicleParticlePack()
        ParticlePack.ParticleSfx = Pack
        self:GetOwner().ReplaceParticleMap:Add(self.LicensePlate.ItemID, ParticlePack)
      end
    end
  end
  for key, ItemID in pairs(self.LicensePlate.EffectIDList) do
    local handle = self.AccessoryHandleCacheMap:Get(ItemID)
    if handle.bAdd and self:GetParticlePack(ItemID) then
      local Pack = self:GetParticlePack(ItemID).ParticleSfx
      if Pack then
        local FVehicleParticlePack = import("VehicleParticlePack")
        local ParticlePack = FVehicleParticlePack()
        ParticlePack.ParticleSfx = Pack
        self:GetOwner().AdditionalParticleMap:Add(self.LicensePlate.ItemID, ParticlePack)
      end
    end
  end
  local VehicleSkinID = self:GetOwner().ClientUsedAvatarID
  if VehicleSkinID == self.LicensePlate.ItemID then
    self:GetOwner():UpdateParticle(VehicleSkinID)
  end
end
function BP_Battle_VehicleLicenseComponent:CheckIsWheelDestoryed()
  local uVehicle = self:GetOwner()
  if not (uVehicle and uVehicle.VehicleCommon) or not uVehicle.VehicleCommon.WheelsCurrentHP then
    return false
  end
  for _, WheelsHP in pairs(uVehicle.VehicleCommon.WheelsCurrentHP) do
    if WheelsHP and WheelsHP <= 0 then
      return true
    end
  end
  return false
end
function BP_Battle_VehicleLicenseComponent:CheckIsVehicleExploded()
  local uVehicle = self:GetOwner()
  if not uVehicle then
    return true
  end
  if not uVehicle.IsExploded then
    return false
  end
  return uVehicle:IsExploded()
end
local class = require("class")
local BP_VehicleLicenseComponentBase = require("GameLua.Activity.Commercialize.Actor.ActorComponent.BP_VehicleLicenseComponentBase")
local CBP_Battle_VehicleLicenseComponent = class(BP_VehicleLicenseComponentBase, nil, BP_Battle_VehicleLicenseComponent)
return CBP_Battle_VehicleLicenseComponent