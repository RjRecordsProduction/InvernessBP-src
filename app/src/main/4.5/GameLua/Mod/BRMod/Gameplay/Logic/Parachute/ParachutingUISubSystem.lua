local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ParachuteOpenUI = require("GameLua.Mod.BRMod.Client.InGameUI.ParachuteOpenUI")
local ParachutingUISubSystem = {}
function ParachutingUISubSystem:ctor()
  self.bHasRegistEvents = false
  self.FormationFeatureRetryTimer = nil
  self.BoundFormationFeature = nil
  local super_data = require("common.super_data")
  self.Data = super_data.CreateSuperData({IsShowEntireMap = false})
end
function ParachutingUISubSystem:OnInit()
  print(bWriteLog and "ParachutingUISubSystem:OnInit")
  self:RegistEvents()
end
function ParachutingUISubSystem:OnRelease()
  print(bWriteLog and "ParachutingUISubSystem:OnRelease")
  if self.FormationFeatureRetryTimer then
    self:RemoveGameTimer(self.FormationFeatureRetryTimer)
    self.FormationFeatureRetryTimer = nil
  end
  if self.BoundFormationFeature then
    self:UnBindLuaObjEvent(self.BoundFormationFeature, "OnFormationStateChanged")
    self.BoundFormationFeature = nil
  end
  ParachutingUISubSystem.__super.OnRelease(self)
end
function ParachutingUISubSystem:GetSuperData()
  return self.Data
end
function ParachutingUISubSystem:RegistEvents()
  if self.bHasRegistEvents then
    self:RemoveCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_CLOSE_BACKPACK)
    self:RemoveCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_STATE)
    self:RemoveCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_CHANGE_STATE)
    self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOWALLUIFORDELATRESULT)
  end
  self.bHasRegistEvents = true
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.PlayerInPlane, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnplayerCanJump", self.PlayerCanJump, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterJumping", self.PlayerOutPlane, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerCanOpenParachute", self.PlayerCanOpenParachute, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerCanCloseParachute", self.PlayerCanCloseParachute, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterParachute", self.PlayerEnterParachute, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFighting", self.PlayerEnterFighting, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFinished", self.PlayerEnterFighting, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerControllerStateChangedDelegate", self.OnPlayerControllerStateChangedDelegate, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_CLOSE_BACKPACK, self.OnBackPackCLose, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_STATE, self.HandleEntireShowEvt, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOWALLUIFORDELATRESULT, self.ShowAllUIForDelayResult, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_CHANGE_STATE, self.OnBackpackVisibilityChanged, self)
  self:AddUIMessageEvent("UIMSG_ParachutingLeaderChange", self.OnParachutingLeaderChange, self)
  self:AddUIMessageEvent("UIMsg_ParachutingHeightBarMoveLeft", self.ParachutingHeightBarMoveLeft, self)
  self:AddUIMessageEvent("UIMsg_Parachuting_HeightBarMoveBack", self.ParachutingHeightBarMoveBack, self)
  self:AddUIMessageEvent("UIMsg_ReceiveParachuteFollowRequst", self.OnReceiveParachuteFollowRequst, self)
  self:AddUIMessageEvent("UIMsg_ReceiveParachuteTransferLeaderRequst", self.OnReceiveTransferLeaderRequest, self)
  self:AddUIMessageEvent("UIMsg_ReceiveParachuteAircraftFollowRequst", self.OnReceiveParachuteAirCraftFollowRequst, self)
  self:AddUIMessageEvent("UIMsg_ReceiveParachuteAircraftApplyRequst", self.OnReceiveParachuteAircraftApplyRequst, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.ReconnectResetUIByPlayerControllerState, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.OnSpectatorChanged, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnSpectatorChanged, self)
  self:ReconnectResetUIByPlayerControllerState()
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  self:BindFormationFeatureEvent()
end
function ParachutingUISubSystem:OnPlayerCharacterChange()
  GameplayData.AddSelfPlayerCharacterEvent(self, "OnFollowStateChanged", self.OnFollowStateChanged, self)
  self:BindFormationFeatureEvent()
end
function ParachutingUISubSystem:OnFollowStateChanged()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) or not PlayerCharacter:IsLocallyControlled() then
    return
  end
  local ParachutingControl = self:TryGetOrCleateParachutingUI(false)
  if not ParachutingControl then
    return
  end
  ParachutingControl:OnFollowStateChange()
end
function ParachutingUISubSystem:ScheduleBindFormationFeatureEventRetry()
  if self.FormationFeatureRetryTimer then
    return
  end
  self.FormationFeatureRetryTimer = self:AddGameTimer(0.1, false, function()
    self.FormationFeatureRetryTimer = nil
    self:BindFormationFeatureEvent()
  end)
  print(bWriteLog and "ParachutingUISubSystem:ScheduleBindFormationFeatureEventRetry - Scheduled retry")
end
function ParachutingUISubSystem:BindFormationFeatureEvent()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "ParachutingUISubSystem:BindFormationFeatureEvent - PlayerCharacter is invalid")
    self:ScheduleBindFormationFeatureEventRetry()
    return
  end
  local Feature = uPlayerCharacter.ParachuteFormation
  if not Feature then
    print(bWriteLog and "ParachutingUISubSystem:BindFormationFeatureEvent - ParachuteFormation not found")
    self:ScheduleBindFormationFeatureEventRetry()
    return
  end
  if self.FormationFeatureRetryTimer then
    self:RemoveGameTimer(self.FormationFeatureRetryTimer)
    self.FormationFeatureRetryTimer = nil
  end
  if self.BoundFormationFeature == Feature then
    self:OnFormationStateChanged(Feature.nFormationState or 0)
    return
  end
  if self.BoundFormationFeature then
    self:UnBindLuaObjEvent(self.BoundFormationFeature, "OnFormationStateChanged")
  end
  self.BoundFormation  self:BindLuaObjEvent(Feature, "OnFormationStateChanged", self.OnFormationStateChanged, self)
  self:OnFormationStateChanged(Feature.nFormationState or 0)
  print(bWriteLog and "ParachutingUISubSystem:BindFormationFeatureEvent - Bound OnFormationStateChanged")
end
function ParachutingUISubSystem:OnFormationStateChanged(nFormationState)
  print(bWriteLog and string.format("ParachutingUISubSystem:OnFormationStateChanged - State: %s", tostring(nFormationState)))
  local ParachutingControl = self:TryGetOrCleateParachutingUI(false)
  if not ParachutingControl then
    return
  end
  ParachutingControl:OnFormationStateChanged(nFormationState)
end
function ParachutingUISubSystem:OnParachutingLeaderChange()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(false)
  if not ParachutingControl then
    return
  end
  ParachutingControl:OnParachutingLeaderChange()
end
function ParachutingUISubSystem:ParachutingHeightBarMoveLeft()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(false)
  if not ParachutingControl then
    return
  end
  ParachutingControl:ParachutingHeightBarMoveLeft()
end
function ParachutingUISubSystem:ParachutingHeightBarMoveBack()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(false)
  if not ParachutingControl then
    return
  end
  ParachutingControl:ParachutingHeightBarMoveBack()
end
function ParachutingUISubSystem:ShowAllUIForDelayResult()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(false)
  if not ParachutingControl then
    return
  end
  ParachutingControl:ShowAllUIForDelayResult()
end
function ParachutingUISubSystem:OnReceiveParachuteFollowRequst()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:OnReceiveParachuteFollowRequst()
end
function ParachutingUISubSystem:OnReceiveTransferLeaderRequest()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:OnReceiveTransferLeaderRequest()
end
function ParachutingUISubSystem:OnReceiveParachuteAirCraftFollowRequst()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:OnReceiveParachuteAirCraftFollowRequst()
end
function ParachutingUISubSystem:OnReceiveParachuteAircraftApplyRequst()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:OnReceiveParachuteAircraftApplyRequst()
end
function ParachutingUISubSystem:OnSpectatorChanged()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(false)
  if not ParachutingControl then
    return
  end
  ParachutingControl:OnSpectatorChanged()
end
function ParachutingUISubSystem:HandleEntireShowEvt(_, _, IsShowEntireMap)
  local SPData = self:GetSuperData()
  SPData.end
function ParachutingUISubSystem:OnBackpackVisibilityChanged(_, _, bShowState)
  local SPData = self:GetSuperData()
  SPData.BackpackVisibilityShowState = bShowState
end
function ParachutingUISubSystem:OnBackPackCLose()
  self:OnBackpackVisibilityChanged(nil, nil, false)
  local ParachutingControl = self:TryGetOrCleateParachutingUI(false)
  if not ParachutingControl then
    return
  end
  ParachutingControl:OnBackPackCLose()
end
function ParachutingUISubSystem:ReconnectResetUIByPlayerControllerState()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if PlayerController:IsInFight() then
    self:TryCloseParachuteingUI()
    return
  end
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:ReconnectResetUIByPlayerControllerState()
  self:BindFormationFeatureEvent()
end
function ParachutingUISubSystem:PlayerInPlane()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:PlayerInPlane()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.bCanJump then
    ParachutingControl:PlayerCanJump()
  end
end
function ParachutingUISubSystem:PlayerCanJump()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:PlayerCanJump()
end
function ParachutingUISubSystem:PlayerOutPlane()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:PlayerOutPlane()
end
function ParachutingUISubSystem:PlayerCanOpenParachute()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:PlayerCanOpenParachute()
end
function ParachutingUISubSystem:PlayerCanCloseParachute()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  print(bWriteLog and "ParachutingUISubSystem:PlayerCanCloseParachute" .. tostring(ParachutingControl == nil))
  if not ParachutingControl then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController.IsSpectator and PlayerController:IsSpectator() then
    print(bWriteLog and "ParachutingUISubSystem:PlayerCanCloseParachute PlayerController IsSpectator")
    return
  end
  ParachutingControl:PlayerCanCloseParachute()
end
function ParachutingUISubSystem:PlayerEnterParachute()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(true)
  if not ParachutingControl then
    return
  end
  ParachutingControl:PlayerEnterParachute()
end
function ParachutingUISubSystem:PlayerEnterFighting()
  local ParachutingControl = self:TryGetOrCleateParachutingUI(false)
  if ParachutingControl then
    ParachutingControl:PlayerEnterFighting()
  end
  self:TryCloseParachuteingUI()
end
function ParachutingUISubSystem:OnPlayerControllerStateChangedDelegate(NewState)
  local EStateType = import("EStateType")
  print(bWriteLog and "ParachutingUISubSystem:OnPlayerControllerStateChangedDelegate" .. tostring(NewState))
  local Pcontroller = GameplayData.GetPlayerController()
  if slua.isValid(Pcontroller) and Pcontroller.bIsForReplay and NewState == EStateType.State_Fight then
    self:TryCloseParachuteingUI()
  end
end
function ParachutingUISubSystem:TryGetOrCleateParachutingUI(bNeedCreate)
  if not UIManager.UI_Config_InGame.ParachutingControl then
    return nil
  end
  local ParachutingControl = UIManager.GetUI(UIManager.UI_Config_InGame.ParachutingControl)
  if not ParachutingControl and bNeedCreate then
    ParachutingControl = UIManager.ShowUI(UIManager.UI_Config_InGame.ParachutingControl)
  end
  return ParachutingControl
end
function ParachutingUISubSystem:TryCloseParachuteingUI()
  if not UIManager.UI_Config_InGame.ParachutingControl then
    return
  end
  local ParachutingControl = UIManager.GetUI(UIManager.UI_Config_InGame.ParachutingControl)
  if ParachutingControl then
    UIManager.CloseUI(UIManager.UI_Config_InGame.ParachutingControl)
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ParachutingUISubSystem)