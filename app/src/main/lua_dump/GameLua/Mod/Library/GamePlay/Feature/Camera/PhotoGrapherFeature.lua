local PhotoGrapherFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PhotoGrapherConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.PhotoGrapherConfig")
PhotoGrapherFeature.ServerRPC.RPC_Server_ChangePhotoGrapherOpenState = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Int
  }
}
PhotoGrapherFeature.ServerRPC.RPC_Server_ChangeEmotePlayRate = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PhotoGrapherFeature.ServerRPC.RPC_Server_PlayPetFeature = {
  Reliable = true,
  Params = {}
}
PhotoGrapherFeature.ServerRPC.RPC_Server_PhotographerOp = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PhotoGrapherFeature:_PostConstruct()
  local uSTExtraDelegateMgr = import("STExtraDelegateMgr")
end
function PhotoGrapherFeature:ctor()
  self.bPhotoGrapherOpenState = false
  self.OldWearIndex = nil
  self.ModifyEmotePlayRateNums = 0
  self.OpenedFeatureMark = 0
  self.UseRecord = {}
end
function PhotoGrapherFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bPhotoGrapherOpenState",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Bool
    }
  }
end
function PhotoGrapherFeature:RPC_Server_ChangePhotoGrapherOpenState(bNewOpenState, FeatureMark)
  if Client then
    return
  end
  print(bWriteLog and "PhotoGrapherFeature:RPC_Server_ChangePhotoGrapherOpenState", bNewOpenState, FeatureMark)
  if bNewOpenState then
    local CheckGunSkillID = 1014405
    local CheckItemSkillID = 1039006
    if not self.Owner or not slua.isValid(self.Owner.Object) then
      print(bWriteLog and "PhotoGrapherFeature:RPC_Server_ChangePhotoGrapherOpenState  PlayerState is nil")
      return
    end
    local PlayerCharacter = self.Owner.Object:GetPlayerCharacter()
    if not slua.isValid(PlayerCharacter) then
      print(bWriteLog and " PhotoGrapherSubSystem:RPC_Server_ChangePhotoGrapherOpenState PlayerCharacter is nil")
      return
    end
    local SkillMgr = PlayerCharacter:GetSkillManager()
    if Game:IsValid(SkillMgr) and (SkillMgr:IsCastingSkillID(CheckGunSkillID) or SkillMgr:IsCastingSkillID(CheckItemSkillID)) then
      print(bWriteLog and "PhotoGrapherFeature:RPC_Server_ChangePhotoGrapherOpenState IsCastingSkillID")
      return
    end
  end
  self:ChangePhotoGrapherOpenState(bNewOpenState, FeatureMark)
  print(bWriteLog and "PhotoGrapherFeature:RPC_Server_ChangePhotoGrapherOpenState", self.bPhotoGrapherOpenState)
  if self.bPhotoGrapherOpenState then
    self:RegisterPhotoGrapherExitEvent()
  else
    self:RemovePhotoGrapherExitEvent()
  end
end
function PhotoGrapherFeature:RPC_Server_ChangeEmotePlayRate(EmotePlayRate)
  if Client then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PhotoGrapherFeature:UpdateServerState failed")
    return
  end
  local PlayerCharacter = self.Owner.Object:GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and " PhotoGrapherSubSystem:ModifyEmotePlayRate PlayerCharacter is nil")
    return
  end
  if EmotePlayRate <= 0 or 30000 < EmotePlayRate then
    print(bWriteLog and " PhotoGrapherSubSystem:RPC_Server_ChangeEmotePlayRate EmotePlayRate is OutOfRange EmotePlayRate is ", EmotePlayRate)
    return
  end
  self.ModifyEmotePlayRateNums = self.ModifyEmotePlayRateNums + 1
  print(bWriteLog and " PhotoGrapherSubSystem:ModifyEmotePlayRate ModifyEmotePlayRateNums is ", self.ModifyEmotePlayRateNums, "current time is ", CGameState:GetServerWorldTimeSeconds())
  PlayerCharacter:SetAttrValue("EmotePlayRate", EmotePlayRate, -1)
  local PhotographerOptype = PhotoGrapherConfig.PhotographerOptype
  self:RPC_Server_PhotographerOp(PhotographerOptype.EmotePlayRate)
end
function PhotoGrapherFeature:RPC_Server_PlayPetFeature()
  if Client then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PhotoGrapherFeature:RPC_Server_PlayPetFeature failed")
    return
  end
  local uPlayerController = self.Owner.Object:GetOwner()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerCharacter) and slua.isValid(uPlayerCharacter.PetComponent_BP) and slua.isValid(uPlayerCharacter.PetComponent_BP.PetPawn) and uPlayerCharacter.PetComponent_BP.PetPawn.PlayPetFeature then
    uPlayerCharacter.PetComponent_BP.PetPawn:PlayPetFeature()
  end
end
function PhotoGrapherFeature:RPC_Server_PhotographerOp(OperationType, NewFeatureList)
  if Client then
    return
  end
  local bIsFirstUse = false
  if not self.UseRecord[OperationType] then
    self.UseRecord[OperationType] = 0
    bIsFirstUse = true
  end
  self.UseRecord[OperationType] = self.UseRecord[OperationType] + 1
  local PhotographerTlogInfo = {OperationType = OperationType, bIsFirstUse = bIsFirstUse}
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if DSCommonTLogSubsystem then
    DSCommonTLogSubsystem:ReportSmartPhotoTLog(PhotographerTlogInfo, NewFeatureList)
  end
end
function PhotoGrapherFeature:ChangePhotoGrapherOpenState(bNewOpenState, FeatureMark)
  if self.bPhotoGrapherOpenState == bNewOpenState then
    print(bWriteLog and "PhotoGrapherFeature:ChangePhotoGrapherOpenState Server PhotoGrapher state is  already", bNewOpenState)
    return
  end
  self.bPhotoGrapherOpenState = bNewOpenState
  local NewFeatureList = {}
  if FeatureMark and FeatureMark ~= 0 then
    for _, Index in pairs(PhotoGrapherConfig.PhotographerFeatureState) do
      if self:IsFeatureSet(FeatureMark, Index) and not self:IsFeatureSet(self.OpenedFeatureMark, Index) then
        local TableUtil = require("common.table_util")
        TableUtil.UniqueInsert(NewFeatureList, Index)
      end
    end
    self.OpenedFeatureMark = self.OpenedFeatureMark | FeatureMark
  end
  print(bWriteLog and "PhotoGrapherFeature:ChangePhotoGrapherOpenState Server PhotoGrapher state is ", bNewOpenState)
  if FeatureMark then
    print(bWriteLog and "PhotoGrapherFeature:ChangePhotoGrapherOpenState OpenedFeatureMark is", self.OpenedFeatureMark, " FeatureMark is", FeatureMark)
  end
  self:UpdateServerState()
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PhotoGrapherFeature:ChangePhotoGrapherOpenState  PlayerState is nil")
    return
  end
  local PlayerState = self.Owner.Object
  if self.bPhotoGrapherOpenState == true then
    local uPlayerController = PlayerState:GetOwner()
    if slua.isValid(uPlayerController) then
      local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
      if slua.isValid(uPlayerCharacter) then
        EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_DS_ENTER_SELFIE_MODE, uPlayerCharacter)
      end
    end
    PlayerState:AddGeneralCount(775, 1, true)
    print(bWriteLog and "PhotoGrapherFeature:AddGeneralCount")
    local PhotographerOptype = PhotoGrapherConfig.PhotographerOptype
    self:RPC_Server_PhotographerOp(PhotographerOptype.Open, NewFeatureList)
  end
end
function PhotoGrapherFeature:UpdateServerState()
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PhotoGrapherFeature:UpdateServerState failed")
    return
  end
  local uPlayerController = self.Owner.Object:GetOwner()
  if not slua.isValid(uPlayerController) then
    return
  end
  if self.bPhotoGrapherOpenState then
    self.OldWearIndex = uPlayerController.RoleWearIndex
  else
    if slua.isValid(uPlayerController.BP_ChangeWearingComp) and self.OldWearIndex then
      if self.OldWearIndex ~= uPlayerController.RoleWearIndex then
        uPlayerController.BP_ChangeWearingComp:ServerRequestChangeWearInPhoto(self.OldWearIndex)
        self.OldIndex = nil
      end
    else
      print(bWriteLog and "PhotoGrapherFeature:RPC_Server_ChangePhotoGrapherOpen Server BP_ChangeWearingComp  is invalid ", self.OldWearIndex)
    end
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) then
      uPlayerCharacter:SetAttrValue("EmotePlayRate", 10000, -1)
    end
  end
end
function PhotoGrapherFeature:OnRep_bPhotoGrapherOpenState()
  print(bWriteLog and "PhotoGrapherFeature:OnRep_bPhotoGrapherOpenState ", self.bPhotoGrapherOpenState)
  if not Client then
    return
  end
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem then
    print(bWriteLog and "PhotoGrapherFeature:OnRep_bPhotoGrapherOpenState IngameSelfieSubsystem  is not open ")
    return
  end
  if self.bPhotoGrapherOpenState then
    IngameSelfieSubsystem:OnEnterSelfie()
  else
    IngameSelfieSubsystem:ExitSelfie()
  end
end
function PhotoGrapherFeature:ExitPhotoGrapher()
  self:RPC_Server_ChangePhotoGrapherOpenState(false, 0)
  print(bWriteLog and "PhotoGrapherFeature:ExitPhotoGrapher")
end
function PhotoGrapherFeature:RegisterPhotoGrapherExitEvent()
  if Client then
    return
  end
  self:AddCommonEvent(EVENTTYPE_PLAYER, EVENTID_PLAYER_STATE_CHANGED, self.HandlePlayerStateChnanged, self)
  print(bWriteLog and "PhotoGrapherFeature:RegisterPhotoGrapherExitEvent  EVENTID_PLAYER_STATE_CHANGED Success")
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PhotoGrapherFeature:RegisterPhotoGrapherExitEvent failed")
    return
  end
  local uPlayerController = self.Owner.Object:GetOwner()
  if not slua.isValid(uPlayerController) then
    return
  end
  self:AddControlEvent(uPlayerController, "PlayerControllerLostDelegate", function()
    self:ExitPhotoGrapher()
  end)
  self:AddControlEvent(uPlayerController, "PlayerControllerAboutToExitDelegate", function()
    self:ExitPhotoGrapher()
  end)
  print(bWriteLog and "PhotoGrapherFeature:RegisterPhotoGrapherExitEvent Success")
end
function PhotoGrapherFeature:RemovePhotoGrapherExitEvent()
  if Client then
    return
  end
  self:RemoveCommonEvent(EVENTTYPE_PLAYER, EVENTID_PLAYER_STATE_CHANGED)
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PhotoGrapherFeature:UpdateServerState failed")
    return
  end
  local uPlayerController = self.Owner.Object:GetOwner()
  if not slua.isValid(uPlayerController) then
    return
  end
  if self:HasControlEventByControl(uPlayerController, "PlayerControllerLostDelegate") then
    self:RemoveControlEvent(uPlayerController, "PlayerControllerLostDelegate")
  end
  if self:HasControlEventByControl(uPlayerController, "PlayerControllerAboutToExitDelegate") then
    self:RemoveControlEvent(uPlayerController, "PlayerControllerAboutToExitDelegate")
  end
  print(bWriteLog and "PhotoGrapherFeature:RemovePhotoGrapherExitEvent Success")
end
function PhotoGrapherFeature:HandlePlayerStateChnanged(_, _, uid, InPlayerState, bIsPlayerExit)
  if Client then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "PhotoGrapherFeature:HandlePlayerStateChnanged PlayerController is nil")
    return
  end
  local uPlayerController = self.Owner.Object:GetOwner()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "PhotoGrapherFeature:HandlePlayerStateChnanged uPlayerCharacter is nil")
    return
  end
  local PlayerUID = Game:GetPlayerUID(uPlayerCharacter)
  print(bWriteLog and "PhotoGrapherFeature:HandlePlayerStateChnanged playeruid is", PlayerUID, "uid is", uid)
  if PlayerUID and uid ~= PlayerUID then
    return
  end
  print(bWriteLog and "PhotoGrapherFeature:HandlePlayerStateChnanged playeruid is", PlayerUID, "playerstate is", InPlayerState)
  local PlayerState = string.lower(InPlayerState)
  if PlayerState == "logout" or PlayerState == "exited" or PlayerState == "connectionexception" or PlayerState == "connectiontimeout" or PlayerState == "cheatdetected" or PlayerState == "lost" then
    self:ExitPhotoGrapher()
    print(bWriteLog and "PhotoGrapherFeature:HandlePlayerStateChnanged exit PhotoGrapher")
  end
  if PlayerState == "login" then
    self:ExitPhotoGrapher()
  end
end
function PhotoGrapherFeature:IsFeatureSet(FeatureMark, Id)
  return FeatureMark & 1 << Id - 1 ~= 0
end
function PhotoGrapherFeature:IsPhotoGrapherOpenState()
  return self.bPhotoGrapherOpenState
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPhotoGrapherFeature = class(CFeatureBase, nil, PhotoGrapherFeature)
return CPhotoGrapherFeature