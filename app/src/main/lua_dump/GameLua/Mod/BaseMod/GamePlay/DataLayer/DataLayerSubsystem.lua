local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local DataLayerSubsystem = {}
function DataLayerSubsystem:ctor()
  self.FireBtnStatus = UEnums.ECurPlayerHandStatus.Fist
  self.RotateViewWithPeekSwitch = false
end
function DataLayerSubsystem:OnInit()
  DataLayerSubsystem.__super.OnInit(self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTER_OBSERVE, self.OnSpectatorReplayChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_POSSESSONPET, self.EnterPetSpectating, self)
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  local Bridge = STExtraGameplayStatics.GetGameBridge(CGameWorld)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnSpectatorReplayChanged, self)
  if slua.isValid(Bridge) then
    self:AddControlEvent(Bridge, "OnPlayReplayBegin", self.OnSpectatorReplayChanged, self)
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    self.RotateViewWithPeekSwitch = SettingSubsystem:GetUserSettings_Bool("RotateViewWithPeekSwitch")
    SettingSubsystem:RegisterUserSettingsDelegate_Bool("RotateViewWithPeekSwitch", function(RotateViewWithPeekSwitch)
      self.    end)
  end
end
function DataLayerSubsystem:EnterPetSpectating()
  self:UpdateSuperDataValue("OtherMortarEnterAimState", false)
end
function DataLayerSubsystem:OnSpectatorReplayChanged()
  local GameplayStatics = import("GameplayStatics")
  local PlayerController = GameplayStatics.GetPlayerController(CGameWorld, 0)
  if not slua.isValid(PlayerController) then
    self:UpdateSuperDataValue("OtherMortarEnterAimState", false)
    return
  end
  local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
  if PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator) or PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_Replay) then
    self:UpdateSuperDataValue("OtherMortarEnterAimState", false)
  end
end
function DataLayerSubsystem:GetFireBtnStatus()
  return self.FireBtnStatus
end
function DataLayerSubsystem:SetFireBtnStatus(InFireBtnStatus)
  self.FireBtnStatus = InFireBtnStatus
end
function DataLayerSubsystem:GetRotateViewWithPeekSwitch()
  return self.RotateViewWithPeekSwitch
end
function DataLayerSubsystem:SetRotateViewWithPeekSwitch(InRotateViewWithPeekSwitch)
  self.RotateViewWithPeekSwitch = InRotateViewWithPeekSwitch
end
function DataLayerSubsystem:OnRelease()
  DataLayerSubsystem.__super.OnRelease(self)
end
function DataLayerSubsystem:UpdateSuperDataValue(Key, Value)
  local SuperData = self:GetSuperData()
  SuperData[Key] = Value
end
local class = require("class")
local CSubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CSubsystemBase, nil, DataLayerSubsystem)