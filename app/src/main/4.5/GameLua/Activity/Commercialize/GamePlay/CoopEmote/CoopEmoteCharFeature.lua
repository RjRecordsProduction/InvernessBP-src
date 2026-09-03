local CoopEmoteCharFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
local EPawnState = import("EPawnState")
local CoopEmoteUtil = require("GameLua.Activity.Commercialize.GamePlay.CoopEmote.CoopEmoteUtil")
function CoopEmoteCharFeature:_PostConstruct()
  CoopEmoteCharFeature.__super._PostConstruct(self)
  print(bWriteLog and "CoopEmoteCharFeature:_PostConstruct")
  self.coopPhase = 0
  self.cachePreEmoteID = 0
end
function CoopEmoteCharFeature:ReceiveBeginPlay()
  CoopEmoteCharFeature.__super.ReceiveBeginPlay(self)
  if self:HasAuthority() then
    self:AddControlEvent(self.Owner, "OnCharacterPlayEmote", self.HandleDSOnCharacterPlayEmote, self)
  end
  if Client then
    self.isOpen = LobbySystem.CheckOpen(BP_ENUM_SWITCH_COOP_EMOTE)
    print(bWriteLog and string.format("CoopEmoteCharFeature:ReceiveBeginPlay isOpen:%s", self.isOpen))
    local playEmoteComponent = self.Owner.PlayEmoteComponent
    if Game:IsValid(playEmoteComponent) then
      self:AddControlEvent(playEmoteComponent, "OnLoadAndStartPlayEmoteAnimEvent", self.HandleClientOnCharacterPlayEmote, self)
    end
  end
end
function CoopEmoteCharFeature:HandleDSOnCharacterPlayEmote(EmoteId)
  print(bWriteLog and string.format("CoopEmoteCharFeature:HandleDSOnCharacterPlayEmote EmoteId:%s", EmoteId))
  if self:IsCoopEmote(EmoteId, 2) then
    print(bWriteLog and "CoopEmoteCharFeature:HandleDSOnCharacterPlayEmote 12219646")
    if self.Owner:GetCachedCoopEmotePlayer() then
      print(bWriteLog and "CoopEmoteCharFeature:HandleDSOnCharacterPlayEmote RPC_Server_SetCoopEmotePhase")
      self.Owner:GetCachedCoopEmotePlayer():RPC_Server_SetCoopEmotePhase(3)
    end
  elseif self:IsCoopEmote(EmoteId, 1) then
    if self.Owner.GetPlayEmoteComponent then
      local uPlayEmoteComp = self.Owner:GetPlayEmoteComponent()
      if slua.isValid(uPlayEmoteComp) then
        uPlayEmoteComp.CoopEmoteTargetOffset, uPlayEmoteComp.CoopEmoteTargetRotate = CoopEmoteUtil.GetCoopEmoteTarget(EmoteId)
      end
    end
    self.Owner:RPC_Server_SetCoopEmotePhase(1)
  end
end
function CoopEmoteCharFeature:HandleClientOnCharacterPlayEmote(EmoteId)
  print(bWriteLog and string.format("CoopEmoteCharFeature:HandleClientOnCharacterPlayEmote EmoteId:%s", EmoteId))
  if self:IsCoopEmote(EmoteId, 1) then
    self.Owner:RPC_Server_SetCoopEmotePhase(1)
    self:MarkPreEmoteID(EmoteId)
  end
end
function CoopEmoteCharFeature:IsCoopEmote(EmoteId, CoopPhase)
  if CoopPhase == 1 then
    return CoopEmoteUtil.IsCoopEmote(EmoteId)
  end
  if CoopPhase == 2 then
    return CoopEmoteUtil.IsCasterEmote(EmoteId)
  end
  if CoopPhase == 3 then
    return CoopEmoteUtil.IsJoinerEmote(EmoteId)
  end
  return false
end
function CoopEmoteCharFeature:CheckIsValidEmoteIDBP(EmoteID)
  if CoopEmoteUtil.IsCasterEmote(EmoteID) then
    return true
  end
  if CoopEmoteUtil.IsJoinerEmote(EmoteID) then
    return true
  end
  return false
end
function CoopEmoteCharFeature:ShouldCheckCoopEmote()
  if not self.isOpen then
    return false
  end
  return true
end
function CoopEmoteCharFeature:ShouldShowCoopEmoteBtn(EmotePlayer)
  local EmoteID = EmotePlayer.EmoteId
  if not self:IsCoopEmote(EmoteID, 1) then
    print(bWriteLog and "CoopEmoteCharFeature:ShouldShowCoopEmoteBtn IsCoop false")
    return false
  end
  local UEPathUtilityMethods = import("UEPathUtilityMethods")
  for _, v in pairs(CoopEmoteUtil.GetAllRelateEmote(EmoteID)) do
    local EmoteHandlePath = self.Owner:GetEmoteHandlePath(v)
    local ItemPathExist = UEPathUtilityMethods.IsAvatarResPathExist(EmoteHandlePath)
    if not ItemPathExist then
      print(bWriteLog and "CoopEmoteCharFeature:ShouldShowCoopEmoteBtn not ItemPathExist. EmoteHandlePath:" .. EmoteHandlePath)
      return false
    end
  end
  if self:IsInCoopEmote() then
    print(bWriteLog and "CoopEmoteCharFeature:ShouldShowCoopEmoteBtn already in coop emote")
    return false
  end
  if not self.Owner:AllowState(EPawnState.PlayEmote, true) then
    print(bWriteLog and "CoopEmoteCharFeature:ShouldShowCoopEmoteBtn not allowed EmoteState")
    return false
  end
  print(bWriteLog and "CoopEmoteCharFeature:ShouldShowCoopEmoteBtn true")
  return true
end
function CoopEmoteCharFeature:HandleClientOnCoopEmotePhaseChange(CoopPhase)
  self.coopPhase = CoopPhase
  print(bWriteLog and string.format("CoopEmoteCharFeature:HandleOnCoopEmotePhaseChange CoopPhase:%d", CoopPhase))
  local result = true
  if CoopPhase == 0 then
    self:MarkPreEmoteID(0)
  elseif CoopPhase == 2 then
    result = false
    local emote = CoopEmoteUtil.GetEmoteByCoopPhase(self.cachePreEmoteID, CoopPhase)
    if emote ~= 0 then
      local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
      result = logic_emote.PlayEmote(self.Owner, emote)
    end
  end
  if false == result then
    self:_BreakCoopEmote(CoopPhase)
  end
end
function CoopEmoteCharFeature:HandleServerOnCoopEmotePhaseChange(CoopPhase)
  print(bWriteLog and string.format("CoopEmoteCharFeature:HandleServerOnCoopEmotePhaseChange CoopPhase:%s", CoopPhase))
  local CoopEmoteSubSystem = SubsystemMgr:Get("CoopEmoteSubSystem")
  if CoopPhase == 1 then
    CoopEmoteSubSystem:RecordCaster(self.Owner.PlayerKey)
  elseif CoopPhase == 2 then
    if self.Owner:GetCachedCoopEmotePlayer() then
      CoopEmoteSubSystem:RecordJoiner(self.Owner:GetCachedCoopEmotePlayer().PlayerKey, self.Owner.PlayerKey)
    end
  elseif CoopPhase == 3 then
    CoopEmoteSubSystem:RecordPhase(self.Owner.PlayerKey)
    self:RPC_Client_CasterFollow(CoopEmoteSubSystem:GetJoinerByCaster(self.Owner.PlayerKey))
  elseif CoopPhase == 0 then
    CoopEmoteSubSystem:BreakCoopEmote(self.Owner.PlayerKey, 0)
  end
end
CoopEmoteCharFeature.ServerRPC.RPC_Server_BreakCoopEmote = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.Int
  }
}
function CoopEmoteCharFeature:RPC_Server_BreakCoopEmote(PlayerKey, reason)
  print(bWriteLog and string.format("CoopEmoteCharFeature:RPC_Server_BreakCoopEmote PlayerKey:%s reason:%s", PlayerKey, reason))
  local CoopEmoteSubSystem = SubsystemMgr:Get("CoopEmoteSubSystem")
  CoopEmoteSubSystem:BreakCoopEmote(PlayerKey, reason)
end
function CoopEmoteCharFeature:_BreakCoopEmote(reason)
  log(bWriteLog and "CoopEmoteCharFeature:_BreakCoopEmote")
  self.Owner:RPC_Server_SetCoopEmotePhase(0)
  self:RPC_Server_BreakCoopEmote(self.Owner.PlayerKey, reason)
end
CoopEmoteCharFeature.ClientRPC.RPC_Client_LocalInteruptPlayEmote = {Reliable = true}
function CoopEmoteCharFeature:RPC_Client_LocalInteruptPlayEmote()
  local emote = CoopEmoteUtil.GetEmoteByCoopPhase(self.cachePreEmoteID, self.coopPhase)
  print(bWriteLog and string.format("CoopEmoteCharFeature:RPC_Client_LocalInteruptPlayEmote:%d , coopPhase:%d, interrupt:%d", self.cachePreEmoteID, self.coopPhase, emote))
  self.Owner:LocalInteruptPlayEmote(emote)
end
CoopEmoteCharFeature.ClientRPC.RPC_Client_CasterFollow = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32
  }
}
function CoopEmoteCharFeature:RPC_Client_CasterFollow(PlayerKey)
  print(bWriteLog and string.format("CoopEmoteCharFeature:RPC_Client_CasterFollow:%d", PlayerKey))
  local result = false
  local emote = CoopEmoteUtil.GetEmoteByCoopPhase(self.cachePreEmoteID, 3)
  if emote ~= 0 and PlayerKey ~= 0 then
    local uPlayEmoteComp = self.Owner:GetPlayEmoteComponent()
    if slua.isValid(uPlayEmoteComp) then
      result = uPlayEmoteComp:OnPlayEmoteFollowPos(emote, PlayerKey)
    end
  end
  if false == result then
    self:_BreakCoopEmote(3)
  end
end
function CoopEmoteCharFeature:IsInCoopEmote()
  local nCurEmoteID = self.Owner:GetCurrentEmoteId()
  log(bWriteLog and "CoopEmoteCharFeature:IsInCoopEmote nCurEmoteID = " .. tostring(nCurEmoteID))
  if nCurEmoteID <= 0 then
    return false
  end
  return self.coopPhase ~= 0
end
function CoopEmoteCharFeature:MarkPreEmoteID(EmoteID)
  self.cachePre  print(bWriteLog and string.format("CoopEmoteCharFeature:MarkPreEmoteID:%d", EmoteID))
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CCoopEmoteCharFeature = class(CFeatureBase, nil, CoopEmoteCharFeature)
return require("combine_class").SetFeatureDynamic(CCoopEmoteCharFeature)