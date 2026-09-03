local AutoParachuteSubsystem = {}
local EStateType = import("EStateType")
local EFollowState = import("EFollowState")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function AutoParachuteSubsystem:ctor()
  self.AutoParachuteOption = false
end
function AutoParachuteSubsystem:Reset()
  self.MapMarkEnable = false
  self.LandingDeviationDist = 10000
  self.InParachute = false
end
function AutoParachuteSubsystem:OnInit()
  print(bWriteLog and "AutoParachuteSubsystem:OnInit")
  self:Reset()
  self:BindEvents()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig ~= nil then
    self:SetMapMarkEnable(SettingConfig.MapMarkEnable)
    self.AutoParachuteOption = SettingConfig.AutoParachute
  else
    print(bWriteLog and "AutoParachuteSubsystem:OnInit Setting Config is nil")
  end
end
function AutoParachuteSubsystem:OnRelease()
  self:UnBindEvents()
  self:Reset()
  AutoParachuteSubsystem.__super.OnRelease(self)
end
function AutoParachuteSubsystem:BindEvents()
  print(bWriteLog and "AutoParachuteSubsystem:RegistEvents")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    self:AddControlEvent(uPlayerController, "OnPlayerControllerStateChangedDelegate", self.OnPlayerControllerStateChanged, self)
    local uPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
    if slua.isValid(uPlayerCharacter) and not uPlayerController:IsSpectator() and not uPlayerController:IsDemoPlaySpectator() and not uPlayerController:IsInPetSpectator() then
      self:AddControlEvent(uPlayerCharacter, "OnFollowStateChanged", self.HandleOnFollowStateChanged, self)
    end
  else
    print(bWriteLog and "AutoParachuteSubsystem:RegistEvents uPlayerController is nil")
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem == nil then
    return
  end
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("AutoParachute", function(bAutoParachuteOptionOpen)
    print(bWriteLog and "AutoParachuteSubsystem AutoParachuteOptionOpen LuaDelegate " .. tostring(bAutoParachuteOptionOpen))
    if not bAutoParachuteOptionOpen then
      self:EnableAutoParachute(false)
    end
    self:SetAutoParachuteOptionOpen(bAutoParachuteOptionOpen)
    self:ShowAutoParachuteUI(bAutoParachuteOptionOpen)
  end)
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("MapMarkEnable", function(bMapMarkEnable)
    print(bWriteLog and "AutoParachuteSubsystem MapMarkEnable LuaDelegate " .. tostring(bMapMarkEnable))
    self:SetMapMarkEnable(bMapMarkEnable)
  end)
end
function AutoParachuteSubsystem:UnBindEvents()
  print(bWriteLog and "AutoParachuteSubsystem:UnBindEvents")
  self:EnableAutoParachute(false)
end
function AutoParachuteSubsystem:ShowAutoParachuteUI(bShow)
  print(bWriteLog and "AutoParachuteSubsystem:ShowAutoParachuteUI", bShow)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsSpectatorOrDemoPlayer then
    if not uPlayerController:IsSpectatorOrDemoPlayer() then
      print(bWriteLog and "AutoParachuteSubsystem:ShowAutoParachuteUI not IsSpectatorOrDemoPlayer", bShow, self:IsAutoParachuteOptionOpen())
      if bShow and self:IsAutoParachuteOptionOpen() then
        local CurStateType = uPlayerController:GetCurrentStateType()
        if CurStateType == EStateType.State_InPlane or CurStateType == EStateType.State_ParachuteJump then
          UIManager.ShowUI(UIManager.UI_Config_InGame.AutoParachuteUI)
        end
      else
        UIManager.HideUI(UIManager.UI_Config_InGame.AutoParachuteUI)
      end
    else
      print(bWriteLog and "AutoParachuteSubsystem:ShowAutoParachuteUI IsSpectatorOrDemoPlayer", bShow, self:IsAutoParachuteOptionOpen())
      if not bShow or not self:IsAutoParachuteOptionOpen() then
        UIManager.HideUI(UIManager.UI_Config_InGame.AutoParachuteUI)
      end
    end
  else
    print(bWriteLog and "AutoParachuteSubsystem:ShowAutoParachuteUI uPlayerController is invalid")
  end
end
function AutoParachuteSubsystem:SetMapMarkEnable(bEnable)
  self.MapMarkEnable = bEnable
end
function AutoParachuteSubsystem:IsMapMarkEnable()
  return self.MapMarkEnable
end
function AutoParachuteSubsystem:EnableAutoParachute(bEnable)
  print(bWriteLog and "AutoParachuteSubsystem:EnableAutoParachute", bEnable)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.EnableAutoParachute then
    uPlayerController:EnableAutoParachute(bEnable)
  else
    print(bWriteLog and "AutoParachuteSubsystem:EnableAutoParachute uPlayerController is invalid")
  end
end
function AutoParachuteSubsystem:IsAutoParachuteEnable()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    return uPlayerController:IsAutoParachuteEnable()
  else
    print(bWriteLog and "AutoParachuteSubsystem:EnableAutoParIsAutoParachuteachute uPlayerController is invalid")
  end
  return false
end
function AutoParachuteSubsystem:GetTargetLocation()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uParachuteComponent = uPlayerController:GetParachuteComponent()
    if slua.isValid(uParachuteComponent) then
      return uParachuteComponent:GetAutoParachuteLocation()
    else
      print(bWriteLog and "AutoParachuteSubsystem:GetTargetLocation uParachuteComponent is invalid")
    end
  else
    print(bWriteLog and "AutoParachuteSubsystem:GetTargetLocation uPlayerController is invalid")
  end
  return nil
end
function AutoParachuteSubsystem:OnPlayerControllerStateChanged(CurStateType)
  print(bWriteLog and "AutoParachuteSubsystem:OnPlayerControllerStateChanged CurStateType: ", CurStateType)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if self:IsAutoParachuteOptionOpen() and slua.isValid(uPlayerController) then
    if CurStateType == EStateType.State_InPlane then
      print(bWriteLog and "AutoParachuteSubsystem:OnPlayerControllerStateChanged State_InPlane")
      self:ShowAutoParachuteUI(true)
      self.InParachute = true
    elseif CurStateType == EStateType.State_ParachuteJump then
      uPlayerController:EnableAutoParachute(uPlayerController:IsAutoParachuteEnable())
    elseif CurStateType == EStateType.State_ParachuteOpen then
      print(bWriteLog and "AutoParachuteSubsystem:OnPlayerControllerStateChanged State_ParachuteOpen")
      if self:IsAutoParachuteEnable() then
        EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "UseAutoParachute", 1)
      end
      self.InParachute = true
    elseif CurStateType == EStateType.State_Fight then
      print(bWriteLog and "AutoParachuteSubsystem:OnPlayerControllerStateChanged State_Fight: ", self.InParachute)
      if self:IsAutoParachuteEnable() then
        EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "UseAutoParachuteLanded", 1)
        uPlayerController:EnableAutoParachute(false)
        self:CheckLandingPosDeviation()
      end
      self:ShowAutoParachuteUI(false)
      self:UnBindEvents()
      self:Reset()
    elseif CurStateType == EStateType.State_PlaneJumpShow or CurStateType == EStateType.State_Dead then
      uPlayerController:EnableAutoParachute(false)
      self:ShowAutoParachuteUI(false)
      self:UnBindEvents()
      self:Reset()
    end
  end
end
function AutoParachuteSubsystem:CheckLandingPosDeviation()
  local AutoParachuteTargetLocation = self:GetTargetLocation()
  if AutoParachuteTargetLocation == nil then
    print(bWriteLog and "AutoParachuteSubsystem:CheckLandingPosDeviation AutoParachuteTargetLocation is invalid")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local PlayerLocation = uPlayerCharacter:K2_GetActorLocation()
      local Player2DLocation = FVector2D(PlayerLocation.X, PlayerLocation.Y)
      local Target2Dlocation = FVector2D(AutoParachuteTargetLocation.X, AutoParachuteTargetLocation.Y)
      local Dist = FVector2D.Distance(Player2DLocation, Target2Dlocation)
      if Dist > self.LandingDeviationDist then
        IngameTipsTools.BattleNormalTipsByTextID(24215)
      end
    end
  end
end
function AutoParachuteSubsystem:HandleOnFollowStateChanged(LastFollowState, NewFollowState)
  print(bWriteLog and "AutoParachuteSubsystem:HandleOnFollowStateChanged", LastFollowState, NewFollowState)
  if NewFollowState == EFollowState.Follower then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_CANCEL_AUTOPARACHUTE)
  end
end
function AutoParachuteSubsystem:IsAutoParachuteOptionOpen()
  return self.AutoParachuteOption
end
function AutoParachuteSubsystem:SetAutoParachuteOptionOpen(bEnable)
  self.AutoParachuteOption = bEnable
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, AutoParachuteSubsystem)