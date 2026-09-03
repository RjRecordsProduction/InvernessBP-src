local UKismetSystemLibrary = import("KismetSystemLibrary")
local UKismetMathLibrary = import("KismetMathLibrary")
local PetExhibitConfig = require("client.lobby_ue_object.Actor.PetExhibit.PetExhibitConfig")
local FHitResult = import("/Script/Engine.HitResult")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local PetExhibitFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
PetExhibitFeature.ServerRPC.RPC_Server_ReqPlayPetExhibitAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
PetExhibitFeature.ServerRPC.RPC_Server_CancelPetExhibit = {
  Reliable = true,
  Params = {}
}
PetExhibitFeature.ServerRPC.RPC_Server_PetExhibitFinished = {
  Reliable = true,
  Params = {}
}
PetExhibitFeature.MulticastRPC.RPC_Multicast_SyncPetExhibitData = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Int
  }
}
PetExhibitFeature.MulticastRPC.RPC_Multicast_CancelPetExhibit = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
PetExhibitFeature.ServerRPC.RPC_Server_ReqPetBubble = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PetExhibitFeature.MulticastRPC.RPC_Multicast_SyncPetBubble = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
local ERROR_MINITV_BLOCKED = 1
local ERROR_PET_BLOCKED = 2
local ERROR_PET_ACTION_INVALID = 3
local ERROR_PET_ACTION_LEVEL_LOCKED = 4
local MINITV_ERROR_TEXT_MAP = {
  [ERROR_MINITV_BLOCKED] = 89956,
  [ERROR_PET_BLOCKED] = 89956,
  [ERROR_PET_ACTION_INVALID] = 530002,
  [ERROR_PET_ACTION_LEVEL_LOCKED] = 530002
}
PetExhibitFeature.ServerRPC.RPC_Server_ReqMiniTvInteraction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PetExhibitFeature.ClientRPC.RPC_Client_RspMiniTvInteractionFailed = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PetExhibitFeature.MulticastRPC.RPC_Multicast_SyncMiniTvInteraction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Str,
    import("/Script/CoreUObject.Vector"),
    import("/Script/CoreUObject.Vector"),
    import("/Script/CoreUObject.Rotator"),
    UEnums.EPropertyClass.Int
  }
}
PetExhibitFeature.ServerRPC.RPC_Server_CancelMiniTvInteraction = {
  Reliable = true,
  Params = {}
}
PetExhibitFeature.MulticastRPC.RPC_Multicast_CancelMiniTvInteraction = {
  Reliable = true,
  Params = {}
}
local MINITV_INTERACTION_DURATION = 3
function PetExhibitFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bPlaying",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Bool
    }
  }
end
function PetExhibitFeature:ctor()
  self.PetExhibitInteractiveActor = nil
  self.PetExhibitContainer = nil
end
function PetExhibitFeature:ReceiveBeginPlay()
  print(bWriteLog and "PetExhibitFeature:ReceiveBeginPlay")
  PetExhibitFeature.__super.ReceiveBeginPlay(self)
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    self:AddControlEvent(self.Owner, "OnAttachedToVehicle", self.OnOwnerAttachedToVehicle, self)
  else
    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_EXHIBITION_START, self.OnPetExhibitStart, self)
    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_EXHIBITION_END, self.OnPetExhibitEnd, self)
    if self.bPlaying then
      print(bWriteLog and "PetExhibitFeature: has played")
      self:RPC_Server_CancelPetExhibit()
    end
  end
end
function PetExhibitFeature:RPC_Server_ReqPlayPetExhibitAction(PetDataStr)
  print(bWriteLog and "PetExhibitFeature:RPC_Server_ReqPlayPetExhibitAction")
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    print(bWriteLog and "PetExhibitFeature:RPC_Server_ReqPlayPetExhibitAction 1")
    return
  end
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    return
  end
  local PetExhibitData = self:GetSelfPetExhibitData()
  local PetExhibitStr = self:ConvertPetExhibitDataToString(PetExhibitData)
  local uPlayer = Game:GetPlayerByPlayerKey(self.Owner.PlayerKey)
  if not slua.isValid(uPlayer) then
    return
  end
  local UID = Game:GetPlayerUID(uPlayer)
  local PetFormDataUtil = require("GameLua.Activity.Commercialize.GamePlay.Pet.PetFormDataUtil")
  local EffectItemID = PetFormDataUtil:GetPetEffectID(UID)
  self:RPC_Multicast_SyncPetExhibitData(tostring(UID), PetExhibitStr, tostring(self.Owner.PlayerKey), PetDataStr, EffectItemID)
  self:ServerSpawnInteractiveActor()
end
function PetExhibitFeature:RPC_Multicast_SyncPetExhibitData(UID, PetDataStr, PlayerKey, ActionDataStr, EffectItemID)
  print(bWriteLog and "PetExhibitFeature:RPC_Multicast_SyncPetExhibitData")
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  if not self.Owner.Object or not slua.isValid(self.Owner.Object) then
    return
  end
  if self.PetExhibitContainer and slua.isValid(self.PetExhibitContainer) then
    self.PetExhibitContainer:K2_DestroyActor()
    self.PetExhibitContainer = nil
  end
  if not self:ShouldProcessPetExhibit() then
    print(bWriteLog and "PetExhibitFeature:RPC_Multicast_SyncPetExhibitData ShouldProcessPetExhibit return false")
    return
  end
  local World = slua_GameFrontendHUD:GetWorld()
  local PetExhibitContainerClass = slua.loadClass(PetExhibitConfig.PetExhibitContainerPath)
  local CharacterTransform = self.Owner.Object:GetTransform()
  local ContainerLocation = UKismetMathLibrary.TransformLocation(CharacterTransform, FVector(150, 0, 100))
  local HitResult = FHitResult()
  local Success = false
  Success, HitResult = USTExtraBlueprintFunctionLibrary.TraceGround(self.Owner.Object, ContainerLocation, 1000, HitResult, true)
  if Success then
    ContainerLocation.Z = HitResult.Location.Z + 40
    print(bWriteLog and "PetExhibitFeature:ServerSpawnInteractiveActor HitResult.Location.Z", HitResult.Location.Z)
  end
  local ContainerRotation = UKismetMathLibrary.TransformRotation(CharacterTransform, FRotator(0, -90, 0))
  local PetExhibitData = self:ConvertStringToPetExhibitData(PetDataStr)
  if not self:CheckHasDownloadedPet(PetExhibitData) then
    ShowNotice(73124)
    return
  end
  self.PetExhibitContainer = World:SpawnActor(PetExhibitContainerClass, ContainerLocation, ContainerRotation, nil)
  self.PetExhibitContainer:SetOwnerUIDAndPlayerKey(UID, PlayerKey)
  self.PetExhibitContainer:SetPetDataList(PetExhibitData)
  EffectItemID = EffectItemID or 0
  self.PetExhibitContainer:SetEffectItemId(EffectItemID)
  local ActionDataMap = self:ConvertStringToPetActionData(ActionDataStr)
  self.PetExhibitContainer:SetActionDataMap(ActionDataMap)
end
function PetExhibitFeature:RPC_Server_CancelPetExhibit()
  print(bWriteLog and "[pet][exhibit]PetExhibitFeature:RPC_Server_CancelPetExhibit")
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  if not slua.isValid(self.PetExhibitInteractiveActor) then
    return
  end
  self:ServerDestroyInteractiveActor()
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    return
  end
  self:RPC_Multicast_CancelPetExhibit(tostring(self.Owner.PlayerKey))
end
function PetExhibitFeature:RPC_Multicast_CancelPetExhibit(PlayerKey)
  print(bWriteLog and "[pet][exhibit]PetExhibitFeature:RPC_Multicast_CancelPetExhibit")
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  if not self.Owner.Object or not slua.isValid(self.Owner.Object) then
    return
  end
  if self.PetExhibitContainer and slua.isValid(self.PetExhibitContainer) then
    self.PetExhibitContainer:SetDisableTips(true)
    self.PetExhibitContainer:K2_DestroyActor()
    self.PetExhibitContainer = nil
  end
end
function PetExhibitFeature:GetSelfPetExhibitData()
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    return
  end
  local PetExhibitDataList = {}
  local CarryPetList = uPlayerController.AdditionalPetInfo
  for _, v in pairs(CarryPetList) do
    local PetData = {
      PetID = v.PetId or 50000,
      PetLevel = v.PetLevel or 1,
      Color = v.PetColor or 1,
      Dress = {}
    }
    for _, ItemID in pairs(v.PetAvatarList) do
      if ItemID ~= 0 then
        table.insert(PetData.Dress, ItemID)
      end
    end
    table.insert(PetExhibitDataList, PetData)
  end
  table.sort(PetExhibitDataList, function(a, b)
    return a.PetID > b.PetID
  end)
  return PetExhibitDataList
end
function PetExhibitFeature:ConvertSinglePetExhibitDataToString(SinglePetExhibitData)
  if not SinglePetExhibitData then
    return nil
  end
  local PetStr = string.format("%d_%d_%d", SinglePetExhibitData.PetID or 50000, SinglePetExhibitData.PetLevel or 1, SinglePetExhibitData.Color or 1)
  local DressStr = table.concat(SinglePetExhibitData.Dress, "_")
  if DressStr ~= "" then
    PetStr = PetStr .. "_" .. DressStr
  end
  return PetStr
end
function PetExhibitFeature:ConvertPetExhibitDataToString(PetExhibitData)
  if not PetExhibitData then
    return nil
  end
  local PetExhibitStrList = {}
  for k, v in pairs(PetExhibitData) do
    local PetStr = self:ConvertSinglePetExhibitDataToString(v)
    if PetStr then
      PetExhibitStrList[#PetExhibitStrList + 1] = PetStr
    end
  end
  local ResultStr = table.concat(PetExhibitStrList, "|")
  print(bWriteLog and "PetExhibitFeature:ConvertPetExhibitDataToString " .. ResultStr)
  return ResultStr
end
function PetExhibitFeature:ConvertStringToSinglePetExhibitData(SinglePetDataStr)
  if not SinglePetDataStr then
    return nil
  end
  local PetData
  local StringUtil = require("common.string_util")
  local SingleDataList = StringUtil.Split(SinglePetDataStr, "_")
  local PetID = tonumber(SingleDataList[1])
  if PetID then
    PetData = {
      PetID = PetID,
      PetLevel = tonumber(SingleDataList[2]) or 1,
      Color = tonumber(SingleDataList[3]) or 1,
      Dress = {}
    }
    for Index = 4, #SingleDataList do
      local ItemID = tonumber(SingleDataList[Index])
      if ItemID and ItemID ~= 0 then
        table.insert(PetData.Dress, ItemID)
      end
    end
  end
  return PetData
end
function PetExhibitFeature:ConvertStringToPetExhibitData(PetDataStr)
  if not PetDataStr then
    return
  end
  local StringUtil = require("common.string_util")
  local PetDataStrList = StringUtil.Split(PetDataStr, "|")
  local PetDataList = {}
  for _, SingleDataStr in pairs(PetDataStrList) do
    local SingleDataList = StringUtil.Split(SingleDataStr, "_")
    local PetID = tonumber(SingleDataList[1])
    local PetData = self:ConvertStringToSinglePetExhibitData(SingleDataStr)
    if PetData then
      table.insert(PetDataList, PetData)
    end
  end
  return PetDataList
end
function PetExhibitFeature:OnPetExhibitStart(_, __, UID, PlayerKey)
  log(bWriteLog and string.format("PetExhibitFeature:OnPetExhibitStart. _=%s, __=%s, UID=%s, PlayerKey=%s", tostring(_), tostring(__), tostring(UID), tostring(PlayerKey)))
  if UKismetSystemLibrary.IsDedicatedServer(self.Object) then
    return
  end
  if tostring(self.Owner.PlayerKey) ~= tostring(PlayerKey) then
    log(bWriteLog and string.format("PetExhibitFeature:OnPetExhibitStart. self.Owner.PlayerKey) is not equals to PlayerKey return. self.Owner.PlayerKey=%s", tostring(self.Owner.PlayerKey)))
    return
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) and tostring(PlayerController.PlayerKey) == tostring(PlayerKey) then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    logic_emote.StartPetExibition()
  end
  local PetPawn = self.Owner.PetComponent_BP:GetPetPawn()
  if PetPawn then
    PetPawn.bInPetExhibiting = true
    PetPawn:SetActorHiddenInGameMask(true, 5)
  end
  local MiniTvPawn = self.Owner.PetComponent_BP:GetMiniTVPawn()
  if slua.isValid(MiniTvPawn) then
    local EPetState = import("EPetState")
    MiniTvPawn:PetEnterState(EPetState.PetDisappear)
  end
end
function PetExhibitFeature:OnPetExhibitEnd(_, __, UID, PlayerKey)
  if tostring(self.Owner.PlayerKey) ~= tostring(PlayerKey) then
    return
  end
  local PetPawn = self.Owner.PetComponent_BP:GetPetPawn()
  if PetPawn then
    PetPawn.bInPetExhibiting = false
    PetPawn:SetActorHiddenInGameMask(false, 5)
  end
  local MiniTvPawn = self.Owner.PetComponent_BP:GetMiniTVPawn()
  if slua.isValid(MiniTvPawn) then
    local EPetState = import("EPetState")
    MiniTvPawn:PetLeaveState(EPetState.PetDisappear)
  end
end
function PetExhibitFeature:ServerSpawnInteractiveActor()
  print(bWriteLog and "PetExhibitFeature:ServerSpawnInteractiveActor")
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  self:ServerDestroyInteractiveActor()
  self.bPlaying = true
  local World = CGameMode:GetWorld()
  local PetExhibitInterActorClass = slua.loadClass("/Game/BluePrints/PET/PetExhibit/BP_PetExhibitInteractive.BP_PetExhibitInteractive")
  local CharacterTransform = self.Owner.Object:GetTransform()
  local InteractiveActorLocation = UKismetMathLibrary.TransformLocation(CharacterTransform, FVector(50, 0, -80))
  local HitResult = FHitResult()
  local Success = false
  Success, HitResult = USTExtraBlueprintFunctionLibrary.TraceGround(self.Owner.Object, InteractiveActorLocation, 300, HitResult, true)
  if Success then
    InteractiveActorLocation.Z = HitResult.Location.Z
    print(bWriteLog and "PetExhibitFeature:ServerSpawnInteractiveActor HitResult.Location.Z", HitResult.Location.Z)
  end
  local InteractiveActorRotation = UKismetMathLibrary.TransformRotation(CharacterTransform, FRotator(0, -90, 0))
  self.PetExhibitInteractiveActor = World:SpawnActor(PetExhibitInterActorClass, InteractiveActorLocation, InteractiveActorRotation, nil)
  self.PetExhibitInteractiveActor:SetOwner(self.Owner.Object)
end
function PetExhibitFeature:ServerDestroyInteractiveActor()
  print(bWriteLog and "PetExhibitFeature:ServerDestroyInteractiveActor")
  if slua.isValid(self.PetExhibitInteractiveActor) then
    self.PetExhibitInteractiveActor:K2_DestroyActor()
    self.bPlaying = false
    self.PetExhibitInteractiveActor = nil
  end
end
function PetExhibitFeature:RPC_Server_PetExhibitFinished()
  print(bWriteLog and "PetExhibitFeature:RPC_Server_PetExhibitFinished")
  self:ServerDestroyInteractiveActor()
end
function PetExhibitFeature:ShouldProcessPetExhibit()
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return false
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode(true) then
    return true
  end
  local GameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(GameState) and GameState.GetGameModeState and GameState:GetGameModeState() == "ReadyState" then
    return true
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if PlayerController.IsTeamMate and PlayerController:IsTeamMate(self.Owner.Object) then
    return true
  end
  return false
end
function PetExhibitFeature:ConvertPetActionDataToString(PetActionData)
  local ResultStr = ""
  if not PetActionData then
    return ResultStr
  end
  log(bWriteLog and string.format("PetExhibitFeature:ConvertPetActionDataToString. PetActionData=%s", tostring(PetActionData)))
  local ResultStrList = {}
  for _, ActionData in pairs(PetActionData) do
    if ActionData and ActionData.PetID and ActionData.PetID ~= 0 then
      local SingleActionStr = string.format("%d_%d_%f_%s", ActionData.PetID, ActionData.ActionID or 0, ActionData.Length or 0, ActionData.AnimAsset or "")
      ResultStrList[#ResultStrList + 1] = SingleActionStr
    end
  end
  ResultStr = table.concat(ResultStrList, "|")
  log(bWriteLog and "PetExhibitFeature:ConvertStringToPetActionData Result=" .. ResultStr)
  return ResultStr
end
function PetExhibitFeature:ConvertStringToPetActionData(ActionDataStr)
  log(bWriteLog and string.format("PetExhibitFeature:ConvertStringToPetActionData. ActionDataStr=%s", tostring(ActionDataStr)))
  local Result = {}
  if not ActionDataStr then
    return Result
  end
  local StringUtil = require("common.string_util")
  local ActionDataStrList = StringUtil.Split(ActionDataStr, "|")
  if ActionDataStrList and next(ActionDataStrList) then
    for _, SingleDataStr in pairs(ActionDataStrList) do
      local SingleDataList = StringUtil.Split(SingleDataStr, "_")
      if SingleDataList then
        local PetID = tonumber(SingleDataList[1])
        if PetID and PetID ~= 0 then
          local SingleActionData = {
            PetID = PetID,
            ActionID = tonumber(SingleDataList[2]) or 0,
            Length = tonumber(SingleDataList[3]) or 0,
            ActionAsset = SingleDataList[4]
          }
          Result[PetID] = SingleActionData
        end
      end
    end
  end
  log_tree("PetExhibitFeature:ConvertStringToPetActionData Result=", Result)
  return Result
end
function PetExhibitFeature:CheckHasDownloadedPet(PetDataList)
  if not PetDataList then
    return false
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local bHasDownload = false
  for i, v in pairs(PetDataList) do
    if v and v.PetID then
      local DownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
        v.PetID
      })
      if DownloadState == PufferConst.ENUM_DownloadState.Done then
        bHasDownload = true
      end
    end
  end
  return bHasDownload
end
function PetExhibitFeature:RPC_Server_ReqPetBubble(BubbleItemID)
  print(bWriteLog and "PetExhibitFeature:RPC_Server_ReqPlayPetExhibitAction", BubbleItemID)
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PetExhibitFeature:RPC_Server_ReqPetBubble Controller is not valid")
    return
  end
  local currentPetID = self:_GetCurrentPetID()
  if currentPetID == 0 or currentPetID == 50001 then
    print(bWriteLog and "PetExhibitFeature:RPC_Server_ReqPetBubble pet bubble is not fit for gyrfalcon")
    return
  end
  local bHasPetBubblePrivilege = uPlayerController.CommerFeature and uPlayerController.CommerFeature.bHasPetBubblePrivilege
  if not bHasPetBubblePrivilege then
    print(bWriteLog and "PetExhibitFeature:RPC_Server_ReqPetBubble no pet bubber privilege")
    return
  end
  local PetBubbleIDList = uPlayerController.CommerFeature and uPlayerController.CommerFeature.PetBubbleIDList
  local bHasBubbleItem = false
  if PetBubbleIDList then
    local BubbleCount = PetBubbleIDList:Num()
    for i = 0, BubbleCount - 1 do
      if BubbleItemID == PetBubbleIDList:Get(i) then
        bHasBubbleItem = true
        break
      end
    end
  end
  if not bHasBubbleItem then
    log(bWriteLog and "PetExhibitFeature:RPC_Server_ReqPetBubble bubble item " .. tostring(BubbleItemID) .. " is not in equipment")
    return
  end
  self:RPC_Multicast_SyncPetBubble(BubbleItemID)
end
function PetExhibitFeature:RPC_Multicast_SyncPetBubble(BubbleItemID)
  print(bWriteLog and "PetExhibitFeature:RPC_Multicast_SyncPetBubble", BubbleItemID)
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  local ENetRole = import("ENetRole")
  if self.Owner.Role == ENetRole.ROLE_SimulatedProxy then
    local settingConfig = slua_GameFrontendHUD:GetUserSettings()
    if settingConfig and not settingConfig.OpenOthersPet then
      log(bWriteLog and "  PetExhibitFeature:RPC_Multicast_SyncPetBubble.  not settingConfig.OpenOthersPet")
      return
    end
  end
  if self.Owner and slua.isValid(self.Owner.PetComponent_BP) and slua.isValid(self.Owner.PetComponent_BP.PetPawn) and slua.isValid(self.Owner.PetComponent_BP.PetPawn.PetBubbleComponent_BP) then
    print(bWriteLog and "PetExhibitFeature:RPC_Multicast_SyncPetBubble 3")
    self.Owner.PetComponent_BP.PetPawn.PetBubbleComponent_BP:SpawnEmoteBubble(BubbleItemID)
  else
    print(bWriteLog and "PetExhibitFeature:RPC_Multicast_SyncPetBubble PetBubbleComponent_BP is not valid")
  end
end
function PetExhibitFeature:_GetCurrentPetID()
  if not self.Owner or not slua.isValid(self.Owner.PetComponent_BP) then
    return 0
  end
  return self.Owner.PetComponent_BP.PetInfo.PetId
end
function PetExhibitFeature:_CheckWallBetween(OriginLocation, SpawnLocation)
  local TraceHeight = SpawnLocation.Z + 80
  local TraceStart = FVector(OriginLocation.X, OriginLocation.Y, TraceHeight)
  local TraceEnd = FVector(SpawnLocation.X, SpawnLocation.Y, TraceHeight)
  local WallHitResult = FHitResult()
  local bHitWall, WallHitResult = UKismetSystemLibrary.LineTraceSingle(self.Owner.Object, TraceStart, TraceEnd, Game:ConvertToTraceType(import("ECollisionChannel").ECC_Visibility), true, nil, 0, WallHitResult, true, FLinearColor.Red, FLinearColor.Green, 1)
  return bHitWall
end
function PetExhibitFeature:RPC_Server_ReqMiniTvInteraction(PetActionID)
  print(bWriteLog and "PetExhibitFeature:RPC_Server_ReqMiniTvBubble PetActionID:" .. tostring(PetActionID))
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  local uPlayer = Game:GetPlayerByPlayerKey(self.Owner.PlayerKey)
  if not slua.isValid(uPlayer) then
    return
  end
  local UID = Game:GetPlayerUID(uPlayer)
  local ValidPetActionID = 0
  if PetActionID and 0 < PetActionID then
    local uPlayerController = self.Owner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) and uPlayerController.GetCurrentPetInfo then
      local CurrentPetInfo = uPlayerController:GetCurrentPetInfo()
      local ActionConfig = CDataTable.GetTableData("PetActionTable", PetActionID)
      if not ActionConfig or ActionConfig.PetID ~= CurrentPetInfo.PetId then
        print("PetExhibitFeature:RPC_Server_ReqMiniTvInteraction PetActionID validation failed, ActionConfig:" .. tostring(ActionConfig) .. " PetID:" .. tostring(CurrentPetInfo.PetId))
        self:RPC_Client_RspMiniTvInteractionFailed(ERROR_PET_ACTION_INVALID)
      else
        local PetLevel = CurrentPetInfo.PetLevel or 1
        local LevelConfigID = CurrentPetInfo.PetId * 10000 + PetLevel
        local PetLevelConfig = CDataTable.GetTableData("PetLevelTable", LevelConfigID)
        local bActionUnlocked = false
        if PetLevelConfig and PetLevelConfig.AllAction then
          local StringUtil = require("common.string_util")
          local AllActionList = StringUtil.Split(PetLevelConfig.AllAction, "|")
          local ActionIDStr = tostring(PetActionID)
          for _, v in pairs(AllActionList) do
            if v == ActionIDStr then
              bActionUnlocked = true
              break
            end
          end
        end
        if bActionUnlocked then
          Valid        else
          print("PetExhibitFeature:RPC_Server_ReqMiniTvInteraction PetActionID level locked, PetID:" .. tostring(CurrentPetInfo.PetId) .. " PetLevel:" .. tostring(PetLevel) .. " PetActionID:" .. tostring(PetActionID))
          self:RPC_Client_RspMiniTvInteractionFailed(ERROR_PET_ACTION_LEVEL_LOCKED)
        end
      end
    end
  end
  local OriginLocation = self.Owner.Object:K2_GetActorLocation()
  local CharacterRotation = self.Owner.Object:K2_GetActorRotation()
  local YawOnlyRotation = FRotator(0, CharacterRotation.Yaw, 0)
  local YawOnlyTransform = UKismetMathLibrary.MakeTransform(OriginLocation, YawOnlyRotation, FVector(1, 1, 1))
  local SpawnLocation1 = UKismetMathLibrary.TransformLocation(YawOnlyTransform, FVector(150, 50, 100))
  local HitResult = FHitResult()
  local Success = false
  Success, HitResult = USTExtraBlueprintFunctionLibrary.TraceGround(self.Owner.Object, SpawnLocation1, 1000, HitResult, true)
  if Success then
    SpawnLocation1.Z = HitResult.Location.Z
    print(bWriteLog and "PetExhibitFeature:RPC_Server_ReqMiniTvBubble #1: HitResult.Location.Z", HitResult.Location.Z)
  end
  local SpawnLocation2 = UKismetMathLibrary.TransformLocation(YawOnlyTransform, FVector(70, 50, 100))
  Success, HitResult = USTExtraBlueprintFunctionLibrary.TraceGround(self.Owner.Object, SpawnLocation2, 1000, HitResult, true)
  if Success then
    SpawnLocation2.Z = HitResult.Location.Z
    print(bWriteLog and "PetExhibitFeature:RPC_Server_ReqMiniTvBubble #2: HitResult.Location.Z", HitResult.Location.Z)
  end
  if self:_CheckWallBetween(OriginLocation, SpawnLocation1) then
    print("PetExhibitFeature:RPC_Server_ReqMiniTvInteraction cancelled: MiniTv spawn location is blocked by wall")
    self:RPC_Client_RspMiniTvInteractionFailed(ERROR_MINITV_BLOCKED)
    return
  end
  if self:_CheckWallBetween(OriginLocation, SpawnLocation2) then
    print("PetExhibitFeature:RPC_Server_ReqMiniTvInteraction cancelled: Pet spawn location is blocked by wall")
    self:RPC_Client_RspMiniTvInteractionFailed(ERROR_PET_BLOCKED)
    return
  end
  local SpawnRotation = UKismetMathLibrary.TransformRotation(YawOnlyTransform, FRotator(0, 90, 0))
  local MiniTvData, PetData = self:GenerationDataForInteraction()
  local MiniTvDataStr = self:ConvertSinglePetExhibitDataToString(MiniTvData)
  local PetDataStr = self:ConvertSinglePetExhibitDataToString(PetData)
  self:RPC_Multicast_SyncMiniTvInteraction(UID, MiniTvDataStr, PetDataStr, SpawnLocation1, SpawnLocation2, SpawnRotation, ValidPetActionID)
end
function PetExhibitFeature:RPC_Client_RspMiniTvInteractionFailed(ErrorID)
  print(bWriteLog and "PetExhibitFeature:RPC_Client_RspMiniTvInteractionFailed ErrorID:", ErrorID)
  local TextID = MINITV_ERROR_TEXT_MAP[ErrorID]
  if TextID then
    IngameTipsTools.BattleNormalTipsByTextID(TextID)
  end
end
function PetExhibitFeature:RPC_Multicast_SyncMiniTvInteraction(UID, MiniTvDataStr, PetDataStr, MiniTvLocation, PetLocation, Rotation, PetActionID)
  print(bWriteLog and "PetExhibitFeature:RPC_Multicast_SyncMiniTvInteraction PetActionID:" .. tostring(PetActionID))
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  local MiniTvData = self:ConvertStringToSinglePetExhibitData(MiniTvDataStr)
  local PetData = self:ConvertStringToSinglePetExhibitData(PetDataStr)
  self:CreateMiniTvActorForInteraction(UID, MiniTvData, PetData, MiniTvLocation, PetLocation, Rotation, PetActionID)
end
function PetExhibitFeature:CreateMiniTvActorForInteraction(UID, MiniTvData, PetData, MiniTvLocation, PetLocation, Rotation, PetActionID)
  print(bWriteLog and "PetExhibitFeature:CreateMiniTvActorForInteraction PetActionID:" .. tostring(PetActionID), tostring(Rotation.Yaw), Rotation.Roll, Rotation.Pitch)
  local PetCount = 0
  if not MiniTvData or not PetData then
    return
  end
  self:ClearInteractionActors()
  local World = slua_GameFrontendHUD:GetWorld()
  local PetShowActorClass = slua.loadClass(PetExhibitConfig.PetExhibitActorWrapperPath)
  local MiniTvActor = World:SpawnActor(PetShowActorClass, MiniTvLocation, Rotation + FRotator(0, 180, 0), nil)
  self.MiniTvActorForInteraction = MiniTvActor
  local bPlayResult = false
  local interactionDuration
  if slua.isValid(MiniTvActor) then
    MiniTvActor:SetExhibitPetData(UID, MiniTvData, true)
    MiniTvActor:SetActorEnableCollision(false)
    self:AddTimer(0, function()
      bPlayResult, interactionDuration = MiniTvActor:PlayRandomAction(true)
    end)
  end
  local PetActor = World:SpawnActor(PetShowActorClass, PetLocation, Rotation, nil)
  self.PetActorForInteraction = PetActor
  if slua.isValid(PetActor) then
    PetActor:SetExhibitPetData(UID, PetData, true)
    PetActor:SetActorEnableCollision(false)
    self:AddTimer(0, function()
      if PetActionID and 0 < PetActionID then
        bPlayResult, interactionDuration = PetActor:PlayActionByID(PetActionID)
      end
      if not bPlayResult then
        bPlayResult, interactionDuration = PetActor:PlayRandomAction(true)
      end
    end)
  end
  if self.Owner and slua.isValid(self.Owner.PetComponent_BP) then
    local PetPawn = self.Owner.PetComponent_BP:GetPetPawn()
    if slua.isValid(PetPawn) then
      PetPawn:SetActorHiddenInGameMask(true, 6)
    end
    local MiniTvPawn = self.Owner.PetComponent_BP:GetMiniTVPawn()
    if slua.isValid(MiniTvPawn) then
      local EPetState = import("EPetState")
      MiniTvPawn:SetActorHiddenInGameMask(true, 6)
    end
  end
  self.nClearInteractionActorsTimer = self:AddTimerOnce(interactionDuration or MINITV_INTERACTION_DURATION, function()
    self:ClearInteractionActors()
  end)
end
function PetExhibitFeature:ClearInteractionActors()
  if self.nClearInteractionActorsTimer then
    self:RemoveTimer(self.nClearInteractionActorsTimer)
    self.nClearInteractionActorsTimer = nil
  end
  if slua.isValid(self.MiniTvActorForInteraction) then
    self.MiniTvActorForInteraction:K2_DestroyActor()
    self.MiniTvActorForInteraction = nil
  end
  if slua.isValid(self.PetActorForInteraction) then
    self.PetActorForInteraction:K2_DestroyActor()
    self.PetActorForInteraction = nil
  end
  if self.Owner and slua.isValid(self.Owner.PetComponent_BP) then
    local PetPawn = self.Owner.PetComponent_BP:GetPetPawn()
    if slua.isValid(PetPawn) then
      PetPawn:SetActorHiddenInGameMask(false, 6)
    end
    local MiniTvPawn = self.Owner.PetComponent_BP:GetMiniTVPawn()
    if slua.isValid(MiniTvPawn) then
      local EPetState = import("EPetState")
      MiniTvPawn:SetActorHiddenInGameMask(false, 6)
    end
  end
end
function PetExhibitFeature:RPC_Server_CancelMiniTvInteraction()
  print(bWriteLog and "PetExhibitFeature:RPC_Server_CancelMiniTvInteraction")
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  self:RPC_Multicast_CancelMiniTvInteraction()
end
function PetExhibitFeature:RPC_Multicast_CancelMiniTvInteraction()
  print(bWriteLog and "PetExhibitFeature:RPC_Multicast_CancelMiniTvInteraction")
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  self:ClearInteractionActors()
end
function PetExhibitFeature:OnOwnerAttachedToVehicle(uVehicle)
  print(bWriteLog and "PetExhibitFeature:OnOwnerAttachedToVehicle")
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  self:RPC_Multicast_CancelMiniTvInteraction()
end
function PetExhibitFeature:GenerationDataForInteraction()
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return nil, nil
  end
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) or not uPlayerController.GetCurrentPetInfo then
    return nil, nil
  end
  local CurrentPetInfo = uPlayerController:GetCurrentPetInfo()
  if CurrentPetInfo.PetId == 0 then
    return nil, nil
  end
  local MiniTVDataUtil = require("GameLua.Activity.Commercialize.GamePlay.MiniTV.MiniTVDataUtil")
  local MinITvDressID = MiniTVDataUtil:GetPlayerMiniTVDressID(uPlayerController.UID)
  local MiniTvData = {
    PetID = 50000,
    PetLevel = 1,
    Dress = {MinITvDressID}
  }
  local PetData = {
    PetID = CurrentPetInfo.PetId,
    PetLevel = CurrentPetInfo.PetLevel or 1,
    Color = CurrentPetInfo.PetColor or 1,
    Dress = {}
  }
  for _, ItemID in pairs(CurrentPetInfo.PetAvatarList) do
    if ItemID ~= 0 then
      table.insert(PetData.Dress, ItemID)
    end
  end
  return MiniTvData, PetData
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPetExhibitFeature = class(CFeatureBase, nil, PetExhibitFeature)
return require("combine_class").SetFeatureDynamic(CPetExhibitFeature)