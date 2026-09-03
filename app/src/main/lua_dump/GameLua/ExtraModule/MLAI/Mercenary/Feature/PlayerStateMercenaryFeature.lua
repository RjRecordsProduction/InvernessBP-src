local PlayerStateMercenaryFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local FSyncTeamMatePlayerState = import("SyncTeamMatePlayerState")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function PlayerStateMercenaryFeature:_PostConstruct()
  PlayerStateMercenaryFeature.__super._PostConstruct(self)
  self.MercenaryPlayerState = nil
  self.MercenaryHealth = 0
  self.MercenaryHealthMax = 0
  self.MercenaryMsgContent = ""
  self.MercenaryLocation = FVector.ZeroVector
  self.MercenaryIsHide = false
  self.nMercenaryKillNum = 0
  self.bIsMercenaryMLAI = false
end
function PlayerStateMercenaryFeature:ReceiveBeginPlay()
  PlayerStateMercenaryFeature.__super.ReceiveBeginPlay(self)
  if self.Owner then
    self.Owner.IsSoloCheckTeamID = true
    if not Client then
      self.IsSoloMode = slua.isValid(CGameState) and CGameState.PlayerNumPerTeam == 1
    end
  end
  if not Client then
    self.nMercenaryKillNum = 0
  end
  if Client and self:IsCannotOpenVoiceTipsEnabled() then
    self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_CANNOT_OPEN, self.HandleOnCannotOpenVoice, self)
  end
end
function PlayerStateMercenaryFeature:ReceiveEndPlay()
  if Client and self:IsValidMercenaryPS() then
    local SuperData = self:GetSuperData()
    if SuperData then
      SuperData.bShowMercenaryUI = false
      SuperData.nMercenaryKillNum = self.nMercenaryKillNum
    end
    self:HideAllMarkAction()
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:ReceiveEndPlay, Owner PlayerKey = %s", tostring(self.Owner and self.Owner.PlayerKey or 0)))
  end
  if not Client then
    self:RemoveUpdateLocationTimerServer()
    self:RemoveResetContentTimer()
  end
  PlayerStateMercenaryFeature.__super.ReceiveEndPlay(self)
end
function PlayerStateMercenaryFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "MercenaryPlayerState",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Object
    },
    {
      "MercenaryPawn",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Object
    },
    {
      "MercenaryHealth",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "MercenaryHealthMax",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "MercenaryMsgContent",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Str
    },
    {
      "MercenaryLocation",
      ELifetimeCondition.COND_None,
      import("/Script/CoreUObject.Vector")
    },
    {
      "MercenaryIsHide",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "nMercenaryKillNum",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "bIsMercenaryMLAI",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
  return RepTable
end
function PlayerStateMercenaryFeature:OnRep_MercenaryPlayerState()
  print(bWriteLog and string.format("PlayerStateMercenaryFeature:OnRep_MercenaryPlayerState, Owner PlayerKey = %s, TeamMatePlayerState isValid=%s, master GetPlayerTeamIndex=%s", tostring(self.Owner.PlayerKey), tostring(slua.isValid(self.MercenaryPlayerState)), tostring(self.Owner:GetPlayerTeamIndex())))
  local SuperData = self:GetSuperData()
  if SuperData then
    SuperData.MercenaryPSData = self.MercenaryPlayerState
  end
  if self:IsValidMercenaryPS() then
    self.MercenaryPlayerState.PlayerHealthMax = self.MercenaryHealthMax
    self.MercenaryPlayerState.PlayerHealth = self.MercenaryHealth
    if self.Owner.GetPlayerTeamIndex then
      self.MercenaryPlayerState.nMasterIndex = self.Owner:GetPlayerTeamIndex()
    end
    if SuperData then
      SuperData.bShowMercenaryUI = true
    end
    self:UpdateMercenaryMapMark()
  else
    if SuperData then
      SuperData.bShowMercenaryUI = false
    end
    self:HideMercenaryMapMarkAction()
  end
end
function PlayerStateMercenaryFeature:OnRep_nMercenaryKillNum()
  print(bWriteLog and "PlayerStateMercenaryFeature:OnRep_nMercenaryKillNum, nMercenaryKillNum = " .. tostring(self.nMercenaryKillNum))
  local SuperData = self:GetSuperData()
  if SuperData then
    SuperData.nMercenaryKillNum = self.nMercenaryKillNum
  end
end
function PlayerStateMercenaryFeature:OnRep_MercenaryPawn()
  print(bWriteLog and string.format("PlayerStateMercenaryFeature:OnRep_MercenaryPawn:slua.isValid(self.MercenaryPawn)=%s, IsValidMercenaryPS=%s", slua.isValid(self.MercenaryPawn), tostring(self:IsValidMercenaryPS())))
  if self:IsValidMercenaryPS() then
    self:UpdateMercenaryMapMark()
  end
  if slua.isValid(self.MercenaryPawn) and self.MercenaryPawn.AddDebugInfo then
    self.MercenaryPawn:AddDebugInfo("PlayerKey", self.MercenaryPawn.PlayerKey)
  end
end
function PlayerStateMercenaryFeature:OnRep_bIsMercenaryMLAI(...)
  print(bWriteLog and "PlayerStateMercenaryFeature:OnRep_bIsMercenaryMLAI", tostring(self.bIsMercenaryMLAI))
end
function PlayerStateMercenaryFeature:SetIsMercenaryMLAIServer(bIsMLAI)
  print(bWriteLog and "PlayerStateMercenaryFeature:SetIsMercenaryMLAIServer", tostring(bIsMLAI))
  self.bIsMercenaryMLAI = bIsMLAI
  self:ForceNetUpdate()
end
function PlayerStateMercenaryFeature:HireMercenaryServer(uMercenaryPS, uMercenaryPawn)
  if Client then
    return
  end
  if uMercenaryPS == nil or not slua.isValid(uMercenaryPS) then
    return
  end
  self:RemoveCommonEvent(EVENTTYPE_PLAYER, EVENTID_PLAYEREVENT_ADD_KILLS)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_ADD_KILLS, self.HandleOnAddKill, self)
  self.MercenaryPlayerState = uMercenaryPS
  if slua.isValid(uMercenaryPawn) then
    self.MercenaryHealthMax = uMercenaryPawn.HealthMax
    self.MercenaryHealth = uMercenaryPawn.Health
    self.MercenaryPawn = uMercenaryPawn
    if uMercenaryPawn.IsCharacterHideIngame then
      self.MercenaryIsHide = uMercenaryPawn:IsCharacterHideIngame()
    end
    self:UpdateMercenaryLocation()
    self:RemoveUpdateLocationTimerServer()
    local nUpdateLocationInterval = 1
    self.UpdateLocationTimerServer = self:AddGameTimer(nUpdateLocationInterval, true, function()
      self:UpdateMercenaryLocation()
    end)
    local uMercenaryCtrl = uMercenaryPawn.GetControllerSafety and uMercenaryPawn:GetControllerSafety() or nil
    local bIsMercenaryMLAI = uMercenaryCtrl and uMercenaryCtrl.IsMLAI
    self:SetIsMercenaryMLAIServer(bIsMercenaryMLAI)
  else
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:HireMercenaryServer, not slua.isValid(uMercenaryPawn), Owner PlayerKey = %s", tostring(self.Owner.PlayerKey)))
  end
  print(bWriteLog and string.format("PlayerStateMercenaryFeature:HireMercenaryServer, Success, Owner PlayerKey = %s, uMercenaryPS.PlayerKey = %s, self.MercenaryHealth=%s, self.MercenaryHealthMax=%s", tostring(self.Owner.PlayerKey), tostring(uMercenaryPS.PlayerKey), tostring(self.MercenaryHealth), tostring(self.MercenaryHealthMax)))
  self:ForceNetUpdate()
  if self.Owner then
    self.Owner:ForceNetUpdate()
  end
end
function PlayerStateMercenaryFeature:RemoveUpdateLocationTimerServer()
  if self.UpdateLocationTimerServer then
    self:RemoveGameTimer(self.UpdateLocationTimerServer)
    self.UpdateLocationTimerServer = nil
  end
end
function PlayerStateMercenaryFeature:RemoveResetContentTimer()
  if self.ResetContentTimer then
    self:RemoveGameTimer(self.ResetContentTimer)
    self.ResetContentTimer = nil
  end
end
function PlayerStateMercenaryFeature:ResetMercenaryServer()
  self:RemoveCommonEvent(EVENTTYPE_PLAYER, EVENTID_PLAYEREVENT_ADD_KILLS)
  self.MercenaryPlayerState = nil
  self.MercenaryPawn = nil
  self.MercenaryHealthMax = 0
  self.MercenaryHealth = 0
  self.MercenaryMsgContent = ""
  self.MercenaryIsHide = false
  self.bIsMercenaryMLAI = false
  self:RemoveUpdateLocationTimerServer()
  self:RemoveResetContentTimer()
  self:ForceNetUpdate()
  print(bWriteLog and string.format("PlayerStateMercenaryFeature:ResetMercenaryServer, Success, Owner PlayerKey = %s, uMercenaryPS = nil", tostring(self.Owner.PlayerKey)))
end
function PlayerStateMercenaryFeature:UpdateMercenaryLocation()
  if self.Owner and Game:IsValid(self.Owner) and self:IsValidMercenaryPS() and slua.isValid(self.MercenaryPawn) then
    self.MercenaryLocation = self.MercenaryPawn:K2_GetActorLocation()
    self:ForceNetUpdate()
  end
end
function PlayerStateMercenaryFeature:IsValidMercenaryPS()
  if self.MercenaryPlayerState and Game:IsValid(self.MercenaryPlayerState) then
    return true
  end
  return false
end
function PlayerStateMercenaryFeature:MercenaryHealthChangeServer(NewHealth)
  if NewHealth and self:IsValidMercenaryPS() then
    self.MercenaryPlayerState.PlayerHealth = NewHealth
    self.MercenaryHealth = NewHealth
    self:ForceNetUpdate()
  else
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:MercenaryHealthChangeServer error NewHealth=%s", tostring(NewHealth)))
  end
end
function PlayerStateMercenaryFeature:SetMercenaryMsgContentServer(MsgContent)
  if self:IsValidMsgContent(MsgContent) then
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:SetMercenaryMsgContentServer %s", tostring(MsgContent)))
    self.Mercenary    self:ForceNetUpdate()
    self:RemoveResetContentTimer()
    self.ResetContentTimer = self:AddGameTimer(5, false, function()
      self.MercenaryMsgContent = ""
      self:ForceNetUpdate()
      self.ResetContentTimer = nil
    end)
  else
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:SetMercenaryMsgContentServer not IsValidMsgContent=%s", tostring(MsgContent)))
  end
end
function PlayerStateMercenaryFeature:IsValidMsgContent(MsgContent)
  if not MsgContent or self.MercenaryMsgContent == MsgContent then
    return false
  end
  if not self.MercenaryConfig then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    self.MercenaryConfig = GamePlayTools.GetCurrentConfig("MercenaryConfig")
  end
  if self.MercenaryConfig and self.MercenaryConfig.MsgContentType == 2 then
    if self.MercenaryConfig.tMsgLocalizeResIDs then
      return self.MercenaryConfig.tMsgLocalizeResIDs[MsgContent]
    else
      local nLocalizeResID = tonumber(MsgContent)
      return nLocalizeResID and 0 < nLocalizeResID
    end
  end
  return true
end
function PlayerStateMercenaryFeature:OnRep_MercenaryHealth()
  if self:IsValidMercenaryPS() then
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:OnRep_MercenaryHealth self.MercenaryHealth=%s", tostring(self.MercenaryHealth)))
    self.MercenaryPlayerState.PlayerHealth = self.MercenaryHealth
    local uMercenaryCharacter = self.MercenaryPlayerState.GetPlayerCharacter and self.MercenaryPlayerState:GetPlayerCharacter() or nil
    if slua.isValid(uMercenaryCharacter) then
      uMercenaryCharacter.Health = self.MercenaryHealth
    end
    local SuperData = self:GetSuperData()
    if SuperData then
      SuperData.MercenaryHealth = self.MercenaryHealth
    end
  end
end
function PlayerStateMercenaryFeature:OnRep_MercenaryHealthMax()
  if self:IsValidMercenaryPS() then
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:OnRep_MercenaryHealthMax self.MercenaryHealthMax=%s", tostring(self.MercenaryHealthMax)))
    self.MercenaryPlayerState.PlayerHealthMax = self.MercenaryHealthMax
    local SuperData = self:GetSuperData()
    if SuperData then
      SuperData.MercenaryHealthMax = self.MercenaryHealthMax
    end
  end
end
function PlayerStateMercenaryFeature:OnRep_MercenaryMsgContent()
  if self:IsValidMercenaryPS() then
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:OnRep_MercenaryMsgContent self.MercenaryMsgContent=%s", tostring(self.MercenaryMsgContent)))
    local SuperData = self:GetSuperData()
    if SuperData then
      SuperData.MercenaryMsgContent = self.MercenaryMsgContent
    end
  end
end
function PlayerStateMercenaryFeature:OnRep_MercenaryIsHide()
  print(bWriteLog and string.format("PlayerStateMercenaryFeature:OnRep_MercenaryIsHide self.MercenaryIsHide=%s", tostring(self.MercenaryIsHide)))
  self:UpdateMercenaryMapMark()
end
function PlayerStateMercenaryFeature:HideAllMarkAction()
  self:HideMercenaryMapMarkAction()
  if self:IsValidMercenaryPS() then
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:HideAllMarkAction IsValidMercenaryPS"))
    local TmpMercenaryPawn = self.MercenaryPlayerState.GetPlayerCharacter and self.MercenaryPlayerState:GetPlayerCharacter() or nil
    if not slua.isValid(TmpMercenaryPawn) then
      TmpMercenaryPawn = self.MercenaryPawn
    end
    if slua.isValid(TmpMercenaryPawn) and TmpMercenaryPawn.RemoveMapMark then
      TmpMercenaryPawn:RemoveMapMark()
    end
  end
end
function PlayerStateMercenaryFeature:HideMercenaryMapMarkAction()
  local SuperData = self:GetSuperData()
  if SuperData then
    SuperData.ShowNotBindMapMark = false
  end
  if self.UpdateMercenaryPawnMarkTimerClient then
    self:RemoveGameTimer(self.UpdateMercenaryPawnMarkTimerClient)
    self.UpdateMercenaryPawnMarkTimerClient = nil
  end
end
function PlayerStateMercenaryFeature:UpdateMercenaryMapMark()
  if self.UpdateMercenaryPawnMarkTimerClient then
    self:RemoveGameTimer(self.UpdateMercenaryPawnMarkTimerClient)
    self.UpdateMercenaryPawnMarkTimerClient = nil
  end
  if self:IsValidMercenaryPS() then
    if self:IsObserverClient() then
      return
    end
    if self.MercenaryIsHide then
      self:HideAllMarkAction()
      return
    end
    local TmpMercenaryPawn = self.MercenaryPlayerState.GetPlayerCharacter and self.MercenaryPlayerState:GetPlayerCharacter() or nil
    if not slua.isValid(TmpMercenaryPawn) then
      TmpMercenaryPawn = self.MercenaryPawn
    end
    if slua.isValid(TmpMercenaryPawn) and Game:IsValid(TmpMercenaryPawn) then
      if TmpMercenaryPawn.IsCharacterHideIngame and TmpMercenaryPawn:IsCharacterHideIngame() then
        self:HideAllMarkAction()
        return
      end
      self:HideMercenaryMapMarkAction()
      if TmpMercenaryPawn.AddMapMark then
        TmpMercenaryPawn:AddMapMark(self.MercenaryPlayerState)
      end
      self.UpdateMercenaryPawnMarkTimerClient = self:AddGameTimer(1.1, false, function()
        if self.Owner and Game:IsValid(self.Owner) and slua.isValid(self.Owner.Object) then
          self:UpdateMercenaryMapMark()
        end
        self.UpdateMercenaryPawnMarkTimerClient = nil
      end)
    else
      local SuperData = self:GetSuperData()
      if SuperData then
        SuperData.MercenaryLocationSD = self.MercenaryLocation
        SuperData.ShowNotBindMapMark = true
        if SuperData.MercenaryLocationCount == nil then
          SuperData.MercenaryLocationCount = 1
        else
          SuperData.MercenaryLocationCount = SuperData.MercenaryLocationCount + 1
        end
      end
    end
  end
end
function PlayerStateMercenaryFeature:OnRep_MercenaryLocation()
  self:UpdateMercenaryMapMark()
end
function PlayerStateMercenaryFeature:HandleOnAddKill(_, _, uKillerPS, uVictimPawn)
  if self.Owner and self:IsValidMercenaryPS() and slua.isValid(uKillerPS) and slua.isValid(uVictimPawn) and uKillerPS == self.MercenaryPlayerState and self.Owner.Kill then
    self.nMercenaryKillNum = self.nMercenaryKillNum + 1
    self.Owner:Kill(0, uVictimPawn)
    print(bWriteLog and string.format("PlayerStateMercenaryFeature:HandleOnAddKill, Kill self.Owner.Kills=%s,nMercenaryKillNum=%s", tostring(self.Owner.Kills), tostring(self.nMercenaryKillNum)))
    if not self.MercenaryConfig then
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      self.MercenaryConfig = GamePlayTools.GetCurrentConfig("MercenaryConfig")
    end
  end
end
function PlayerStateMercenaryFeature:IsObserverClient()
  if Client then
    local uPlayerController = GameplayData.GetPlayerController()
    if Game:IsValid(uPlayerController) and uPlayerController.IsObserver and uPlayerController:IsObserver() then
      return true
    end
  end
  return false
end
function PlayerStateMercenaryFeature:HandleOnCannotOpenVoice()
  if self:IsObserverClient() then
    return
  end
  local sLocalizeTips = LocUtil.GetLocalizeResStr(81114)
  if not sLocalizeTips then
    return
  end
  local SuperData = self:GetSuperData()
  if SuperData then
    SuperData.MercenaryMsgContent = sLocalizeTips
  end
end
function PlayerStateMercenaryFeature:IsCannotOpenVoiceTipsEnabled()
  local uOwnerPlayerState = GameplayData.GetPlayerState()
  if self.Owner and Game:IsValid(uOwnerPlayerState) and self.Owner.PlayerKey == uOwnerPlayerState.PlayerKey then
    if not self.MercenaryConfig then
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      self.MercenaryConfig = GamePlayTools.GetCurrentConfig("MercenaryConfig")
    end
    if self.MercenaryConfig then
      return self.MercenaryConfig.bEnableCannotOpenVoiceTips == true
    end
  end
  return false
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerStateMercenaryFeature)