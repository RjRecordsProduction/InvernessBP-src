local InteractEmotePCFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local MCActionConfig = require("GameLua.Mod.MainCity.Gameplay.Config.MCActionConfig")
function InteractEmotePCFeature:ctor()
  self.ClientInteractEmoteState = 0
  self.MaxInteractAllowDistance = MCActionConfig.MaxInteractAllowDistance
  self.MinInteractAllowDistance = MCActionConfig.MinInteractAllowDistance
  self.CurEmoteDataSave = nil
  self.CurEmoteDataSave_DS = nil
  self.InviteCount_DS = 0
  self.InviteCountTimer_DS = nil
  self.PrepareEmotes = {}
  self.CurSelectTarget = nil
  self.ResponseEmotes = {}
  self.RequestEmotes = {}
  self.InteractOrigin = nil
  self.ResponseEmoteID = 0
  self.bIsAgreeAndDelayResponse = false
  self.OwnerPlayerCharacter = nil
  self.bIsInteractStopAnim = false
end
function InteractEmotePCFeature:ReceiveBeginPlay()
  InteractEmotePCFeature.__super.ReceiveBeginPlay(self)
end
function InteractEmotePCFeature:lazyInitCfgs()
  if not next(self.PrepareEmotes) then
    local CfgList = CDataTable.GetTable("SocialIslandInteractEmote")
    for k, v in pairs(CfgList) do
      self.PrepareEmotes[v.PrepareEmote] = true
      self.ResponseEmotes[v.TargetEmote] = true
      self.RequestEmotes[v.MyEmote] = true
    end
  end
end
function InteractEmotePCFeature:TryGetOwnerPlayerAndBindDel()
  local uChar = self.Owner:GetPlayerCharacterSafety()
  if not Game:IsValid(uChar) then
    printf("InteractEmotePCFeature:TryGetOwnerPlayerAndBindDel uChar is nil")
  end
  self.OwnerPlayerCharacter = uChar
  local EmoteComp = uChar:GetPlayEmoteComponent()
  self:AddControlEvent(EmoteComp, "EmoteMontageFinishedEvent", self.OnSelfEmoteFinished, self)
  self:AddControlEvent(EmoteComp, "OnLoadAndStartPlayEmoteAnimEvent", self.OnSelfEmoteStart, self)
  self:AddControlEvent(EmoteComp, "ReadyToPlayEmoteMontageFailedDelegate", self.OnDelayPlayEmoteFailed, self)
end
function InteractEmotePCFeature:OnSelfEmoteFinished(EmoteIndex, StopReason)
  printf("InteractEmotePCFeature:OnSelfEmoteFinished EmoteIndex:%s, StopReason:%s, self.ClientInteractEmoteState:%s", EmoteIndex, StopReason, self.ClientInteractEmoteState)
  self:lazyInitCfgs()
  if self.ClientInteractEmoteState == 2 then
    self:ServerStopReqInteractEmote(self.CurEmoteDataSave.ID)
    self:ClearInteractData()
  elseif self.ClientInteractEmoteState == 3 and StopReason == 1 then
    if self.bIsInteractStopAnim then
    elseif self.CurSelectTarget and self.CurEmoteDataSave then
      if slua.isValid(self.CurSelectTarget) then
        self:ServerFinishEmote(self.CurSelectTarget, self.CurEmoteDataSave.ID)
      else
        printf("InteractEmotePCFeature:OnSelfEmoteFinished CurSelectTarget is not valid")
      end
    end
    self:ClearInteractData()
  end
end
function InteractEmotePCFeature:OnSelfEmoteStart(EmoteIndex, Handle)
  printf("InteractEmotePCFeature:OnSelfEmoteStart EmoteIndex:%s, Handle:%s", EmoteIndex, Handle)
  self:lazyInitCfgs()
  if self.ClientInteractEmoteState == 1 and Game:IsValid(self.CurSelectTarget) and self.CurEmoteDataSave then
    if self.PrepareEmotes[EmoteIndex] then
      self:ServerReqPlayInteractEmote(self.CurSelectTarget, self.CurEmoteDataSave.ID, self.CurEmoteDataSave.MyEmote, self.CurEmoteDataSave.TargetEmote)
      self.ClientInteractEmoteState = 2
      self:RotatorToInteractTarget(self.CurSelectTarget)
      ShowNotice(20091)
    end
    return
  end
  if self.bIsAgreeAndDelayResponse and self.ResponseEmotes[EmoteIndex] then
    self.bIsAgreeAndDelayResponse = false
    if self.ResponseEmoteID ~= 0 and Game:IsValid(self.InteractOrigin) then
      self:ServerResponseInteractEmoteReq(self.InteractOrigin, self.ResponseEmoteID, 0)
      self:RotatorToInteractTarget(self.InteractOrigin)
    else
      self.OwnerPlayerCharacter:OnInterruptCurrentEmote()
    end
    return
  end
end
function InteractEmotePCFeature:OnDelayPlayEmoteFailed(EmoteIndex, StopReason)
  printf("InteractEmotePCFeature:OnDelayPlayEmoteFailed EmoteIndex:%s, StopReason:%s", EmoteIndex, StopReason)
  self:ClearInteractData()
end
InteractEmotePCFeature.ServerRPC.ServerReqPlayInteractEmote = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
InteractEmotePCFeature.ClientRPC.ClientRecInteractEmoteReq = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object,
    UEnums.EPropertyClass.Int
  }
}
InteractEmotePCFeature.ServerRPC.ServerResponseInteractEmoteReq = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
InteractEmotePCFeature.ClientRPC.ClientRecResponseInteractEmoteResponse = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
InteractEmotePCFeature.ServerRPC.ServerStopReqInteractEmote = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
InteractEmotePCFeature.ClientRPC.ClientStopReqInteractEmote = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object,
    UEnums.EPropertyClass.Int
  }
}
InteractEmotePCFeature.ServerRPC.ServerFinishEmote = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object,
    UEnums.EPropertyClass.Int
  }
}
function InteractEmotePCFeature:ServerReqPlayInteractEmote(TargetPlayer, CfgId, EmoteID, TargetEmoteID)
  printf("InteractEmotePCFeature:OnServerReqPlayInteractEmote TargetPlayer:%s, CfgId:%s, EmoteID:%s, TargetEmoteID:%s", TargetPlayer, CfgId, EmoteID, TargetEmoteID)
  if not Game:IsValid(TargetPlayer) then
    printf("InteractEmotePCFeature:OnServerReqPlayInteractEmote TargetPlayer is nil")
    return
  end
  local OriginPlayer = self.Owner:GetPlayerCharacterSafety()
  if not Game:IsValid(OriginPlayer) then
    printf("InteractEmotePCFeature:OnServerReqPlayInteractEmote OriginPlayer is nil")
    return
  end
  self.CurSelectTarget = TargetPlayer
  self.CurEmoteDataSave_DS = CDataTable.GetTableData("SocialIslandInteractEmote", CfgId)
  if not self.CurEmoteDataSave_DS then
    printf("InteractEmotePCFeature:OnServerReqPlayInteractEmote CurEmoteDataSave_DS is nil")
    return
  end
  self.InviteCount_DS = self.InviteCount_DS + 1
  local count = self.InviteCount_DS
  if self.InviteCountTimer_DS then
    self:RemoveGameTimer(self.InviteCountTimer_DS)
  end
  self.InviteCountTimer_DS = self:AddGameTimer(MCActionConfig.DSInviteTimeout, false, function()
    self.InviteCountTimer_DS = nil
    if count == self.InviteCount_DS and self.CurEmoteDataSave_DS then
      printf("InteractEmotePCFeature:OnServerReqPlayInteractEmote InviteCountTimer_DS timeout")
      self.CurEmoteDataSave_DS = nil
    end
  end)
  local uTargetPC = TargetPlayer:GetPlayerControllerSafety()
  if slua.isValid(uTargetPC) then
    uTargetPC.InteractEmotePCFeature:ClientRecInteractEmoteReq(OriginPlayer, CfgId)
  else
    printf("InteractEmotePCFeature:OnServerReqPlayInteractEmote uTargetPC is nil")
  end
end
function InteractEmotePCFeature:ClientRecInteractEmoteReq(OriginPlayer, CfgId)
  printf("InteractEmotePCFeature:OnClientRecInteractEmoteReq OriginPlayer:%s, CfgId:%s", OriginPlayer, CfgId)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_RECV_INTERACT_EMOTE, OriginPlayer, CfgId)
end
function InteractEmotePCFeature:ServerResponseInteractEmoteReq(OriginPlayer, CfgId, ResponseType)
  printf("InteractEmotePCFeature:OnServerResponseInteractEmote OriginPlayer:%s, CfgId:%s, ResponseType:%s", OriginPlayer, CfgId, ResponseType)
  if not Game:IsValid(OriginPlayer) then
    printf("InteractEmotePCFeature:OnServerResponseInteractEmote OriginTarget is nil")
    return
  end
  local uOriginPC = OriginPlayer:GetPlayerControllerSafety()
  local uTargetPlayer = self.Owner:GetPlayerCharacterSafety()
  local OriginFeature = uOriginPC.InteractEmotePCFeature
  local CurEmoteDataSave_DS = OriginFeature.CurEmoteDataSave_DS
  if not CurEmoteDataSave_DS or CurEmoteDataSave_DS.ID ~= CfgId then
    printf("InteractEmotePCFeature:OnServerResponseInteractEmote OriginFeature CurEmoteDataSave_DS is nil or not match CfgId")
    uTargetPlayer:LocalInteruptPlayEmote(0)
    return
  end
  OriginFeature:ClientRecResponseInteractEmoteResponse(uTargetPlayer, CfgId, ResponseType)
  OriginFeature.CurEmoteDataSave_DS = nil
  if ResponseType == 0 then
  else
    self:ClearInteractData()
  end
end
function InteractEmotePCFeature:ClientRecResponseInteractEmoteResponse(TargetPlayer, CfgId, ResponseType)
  printf("InteractEmotePCFeature:OnClientRecResponseInteractEmoteResponse TargetPlayer:%s, CfgId:%s, ResponseType:%s", TargetPlayer, CfgId, ResponseType)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_RECV_RESPONSE_INTERACT_EMOTE, TargetPlayer, CfgId, ResponseType)
  if not Game:IsValid(TargetPlayer) then
    printf("InteractEmotePCFeature:OnClientRecResponseInteractEmoteResponse TargetPlayer is nil")
    return
  end
  if ResponseType == 0 then
    local EmoteData = CDataTable.GetTableData("SocialIslandInteractEmote", CfgId)
    local ret = self.OwnerPlayerCharacter:OnPlayEmote(EmoteData.MyEmote, "")
    if ret then
      self:RotatorToInteractTarget(TargetPlayer)
      self.ClientInteractEmoteState = 3
      self:ClearOldSelect()
      self.CurSelectTarget = TargetPlayer
      local EmoteComp = TargetPlayer:GetPlayEmoteComponent()
      self:AddControlEvent(EmoteComp, "EmoteMontageFinishedEvent", self.OnTargetEmoteMontageFinished, self)
      if EVENTTYPE_MAINCITY then
        EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_ACTION_TLOG_REPOART, {iId = CfgId, result = 2})
        EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_ACTION_CHARM_REPOART, {iId = CfgId, targetPlayer = TargetPlayer})
      end
    end
  else
    local mappimg = {
      [1] = 20093,
      [2] = 20094,
      [4] = 20097,
      [5] = 20120
    }
    if mappimg[ResponseType] then
      if ResponseType == 1 or ResponseType == 5 then
        local content = LocUtil.LocalizeResFormat(mappimg[ResponseType], TargetPlayer:GetPlayerNameSafety())
        ShowNotice(content)
      else
        ShowNotice(mappimg[ResponseType])
      end
    end
    if EVENTTYPE_MAINCITY then
      EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_ACTION_TLOG_REPOART, {iId = CfgId, result = 3})
    end
  end
end
function InteractEmotePCFeature:ServerStopReqInteractEmote(CfgId)
  printf("InteractEmotePCFeature:OnServerStopReqInteractEmote CfgId:%s", CfgId)
  self.CurEmoteDataSave_DS = nil
  if not Game:IsValid(self.CurSelectTarget) then
    printf("InteractEmotePCFeature:OnServerStopReqInteractEmote self.CurSelectTarget is nil")
    return
  end
  local uTargetPC = self.CurSelectTarget:GetPlayerControllerSafety()
  uTargetPC.InteractEmotePCFeature:ClientStopReqInteractEmote(self.Owner:GetPlayerCharacterSafety(), CfgId)
end
function InteractEmotePCFeature:ClientStopReqInteractEmote(OriginPlayer, CfgId)
  printf("InteractEmotePCFeature:OnClientStopReqInteractEmote OriginPlayer:%s, CfgId:%s", OriginPlayer, CfgId)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_RECV_CANCEL_INTERACT_EMOTE, OriginPlayer, CfgId)
end
function InteractEmotePCFeature:ServerFinishEmote(TargetPlayer, CfgId)
  printf("InteractEmotePCFeature:OnServerFinishEmote TargetPlayer:%s, CfgId:%s", TargetPlayer, CfgId)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_FINISH_INTERACT_EMOTE, TargetPlayer, CfgId)
end
function InteractEmotePCFeature:RequreInteractEmote(TargetPlayer, CfgId)
  printf("InteractEmotePCFeature:RequreInteractEmote TargetPlayer:%s, CfgId:%s", TargetPlayer, CfgId)
  if not Game:IsValid(TargetPlayer) then
    printf("InteractEmotePCFeature:RequreInteractEmote TargetPlayer is nil")
    return
  end
  if not Game:IsValid(self.OwnerPlayerCharacter) then
    self:TryGetOwnerPlayerAndBindDel()
    if not Game:IsValid(self.OwnerPlayerCharacter) then
      printf("InteractEmotePCFeature:RequreInteractEmote self.OwnerPlayerCharacter is nil")
      return
    end
  end
  local cfg = CDataTable.GetTableData("SocialIslandInteractEmote", CfgId)
  if not cfg then
    printf("InteractEmotePCFeature:RequreInteractEmote cfg is nil")
    return
  end
  local tipsId = self:CheckCanRequreInteract(TargetPlayer)
  if tipsId then
    printf("InteractEmotePCFeature:RequreInteractEmote CheckCanRequreInteract false")
    ShowNotice(tipsId)
    return
  end
  local PrepareEmote = cfg.PrepareEmote
  if PrepareEmote ~= 0 then
    local bSucc = self.OwnerPlayerCharacter:OnPlayEmote(PrepareEmote, "")
    if bSucc then
      self.ClientInteractEmoteState = 1
      self:ClearOldSelect()
      self.CurEmoteDataSave = cfg
      self.CurSelectTarget = TargetPlayer
    end
    if EVENTTYPE_MAINCITY then
      EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_ACTION_TLOG_REPOART, {
        iId = CfgId,
        result = bSucc and 4 or 3
      })
    end
    return bSucc
  end
  printf("InteractEmotePCFeature:RequreInteractEmote PrepareEmote is 0")
  return true
end
function InteractEmotePCFeature:CheckCanRequreInteract(TargetPlayer)
  local EPawnState = import("EPawnState")
  if self.OwnerPlayerCharacter:HasState(EPawnState.Move) or self.OwnerPlayerCharacter:HasState(EPawnState.Sprint) or self.OwnerPlayerCharacter:HasState(EPawnState.Jump) or self.OwnerPlayerCharacter:HasState(EPawnState.Swim) or self.OwnerPlayerCharacter:HasState(EPawnState.Skill) or self.OwnerPlayerCharacter:HasState(EPawnState.InVehicle) then
    return 20119
  end
  local targetPos = TargetPlayer:K2_GetActorLocation()
  local selfPos = self.OwnerPlayerCharacter:K2_GetActorLocation()
  local distance = FVector.Distance(selfPos, targetPos)
  printf("InteractEmotePCFeature:CheckCanRequreInteract distance = %s", distance)
  if distance < self.MinInteractAllowDistance then
    return 30140
  end
  if distance > self.MaxInteractAllowDistance then
    return 30141
  end
end
function InteractEmotePCFeature:ClearInteractData()
  printf("InteractEmotePCFeature:ClearInteractData")
  self.ClientInteractEmoteState = 0
  self.CurEmoteDataSave = nil
  self.CurEmoteDataSave_DS = nil
  self:ClearOldSelect()
  self.CurSelectTarget = nil
  self.InteractOrigin = nil
  self.ResponseEmoteID = 0
  self.bIsInteractStopAnim = false
  self.bIsAgreeAndDelayResponse = false
end
function InteractEmotePCFeature:RotatorToInteractTarget(targetPlayer)
  local ownerPlayerControl = self.Owner
  ownerPlayerControl:ExitFreeCamera(true)
  local ownerCharacter = ownerPlayerControl:GetPlayerCharacterSafety()
  local KismetMathLibrary = import("KismetMathLibrary")
  local InteactViewPitch = -20
  local LookatYaw = KismetMathLibrary.FindLookAtRotation(ownerCharacter:K2_GetActorLocation(), targetPlayer:K2_GetActorLocation()).Yaw
  ownerPlayerControl:SetControlRotation(FRotator(InteactViewPitch, LookatYaw, 0), "RotatorToInteractTarget")
  ownerPlayerControl:StartFreeCamera(0)
end
function InteractEmotePCFeature:ResponseInteractEmote(OriginPlayer, Cfg, Response)
  local TargetEmoteID = Cfg.TargetEmote
  local CfgId = Cfg.ID
  printf("InteractEmotePCFeature:ResponseInteractEmote OriginPlayer:%s, Response:%s, TargetEmoteID:%s, CfgId:%s", OriginPlayer, Response, TargetEmoteID, CfgId)
  if nil == self.OwnerPlayerCharacter then
    self:TryGetOwnerPlayerAndBindDel()
  end
  if not Game:IsValid(OriginPlayer) then
    printf("InteractEmotePCFeature:ResponseInteractEmote OriginPlayer is nil")
    return
  end
  self.ResponseEmoteID = 0
  self.InteractOrigin = nil
  self.bIsAgreeAndDelayResponse = false
  local CurResponseType
  if Response then
    CurResponseType = 0
    local pos1 = self.OwnerPlayerCharacter:K2_GetActorLocation()
    local pos2 = OriginPlayer:K2_GetActorLocation()
    local distance = FVector.Distance(pos1, pos2)
    if distance > self.MaxInteractAllowDistance then
      CurResponseType = 4
    else
      local uPS = self.OwnerPlayerCharacter.PlayerState
      local MainCityCoreConst = require("GameLua.Mod.MainCity.Gameplay.Core.MainCityCoreConst")
      if uPS.InteractivePlayerStateFeature then
        if not uPS.InteractivePlayerStateFeature:IsInteractiveStateIdle(MainCityCoreConst.EMainCityInteractiveStateTypeFlag.ISTF_Soccer) then
          CurResponseType = 5
        else
          local bSucc = self.OwnerPlayerCharacter:OnPlayEmote(TargetEmoteID, "")
          if bSucc then
            self:RotatorToInteractTarget(OriginPlayer)
            self.InteractOrigin = OriginPlayer
            self.ResponseEmoteID = CfgId
            self.bIsAgreeAndDelayResponse = true
            if EVENTTYPE_MAINCITY then
              EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_ACTION_TLOG_REPOART, {iId = CfgId, result = 2})
            end
          else
            CurResponseType = 2
          end
        end
      elseif not uPS:IsInteractiveStateIdle() then
        CurResponseType = 5
      else
        local bSucc = self.OwnerPlayerCharacter:OnPlayEmote(TargetEmoteID, "")
        if bSucc then
          self:RotatorToInteractTarget(OriginPlayer)
          self.InteractOrigin = OriginPlayer
          self.ResponseEmoteID = CfgId
          self.bIsAgreeAndDelayResponse = true
        else
          CurResponseType = 2
        end
      end
    end
  else
    CurResponseType = 1
  end
  printf("InteractEmotePCFeature:ResponseInteractEmote CurResponseType:%s", CurResponseType)
  if CurResponseType ~= 0 then
    self:ServerResponseInteractEmoteReq(OriginPlayer, CfgId, CurResponseType)
    local mappimg = {
      [2] = 20094,
      [4] = 20097,
      [5] = 20119
    }
    if mappimg[CurResponseType] then
      ShowNotice(mappimg[CurResponseType])
    end
    if CurResponseType == 2 then
      EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_ACTION_TLOG_REPOART, {iId = CfgId, result = 3})
    end
  end
end
function InteractEmotePCFeature:OnTargetEmoteMontageFinished(EmoteIndex, StopReason)
  printf("InteractEmotePCFeature:OnTargetEmoteMontageFinished EmoteIndex:%s, StopReason:%s", EmoteIndex, StopReason)
end
function InteractEmotePCFeature:ClearOldSelect()
  printf("InteractEmotePCFeature:ClearOldSelect")
  if Game:IsValid(self.CurSelectTarget) then
    local EmoteComp = self.CurSelectTarget:GetPlayEmoteComponent()
    self:RemoveControlEvent(EmoteComp, "EmoteMontageFinishedEvent")
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CInteractEmotePCFeature = class(CFeatureBase, nil, InteractEmotePCFeature)
return CInteractEmotePCFeature