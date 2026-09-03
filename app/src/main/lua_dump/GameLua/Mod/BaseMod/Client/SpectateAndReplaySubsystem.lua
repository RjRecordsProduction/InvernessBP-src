local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SpectateAndReplaySubsystem = {}
function SpectateAndReplaySubsystem:ctor()
  self.RevivalStateGotoSpectatingTimer = nil
end
function SpectateAndReplaySubsystem:OnInit()
  print(bWriteLog and "SpectateAndReplaySubsystem:OnInit")
  self:RegistEvents()
end
function SpectateAndReplaySubsystem:RegistEvents()
  if Game:IsEnableUIStateRefreshFlag() and false then
    self:AddUIMessageEvent("RequestGotoSpectatingForResultToSpectate", self.RequestGotoSpectatingForResultToSpectate, self)
    GameplayData.AddSelfPlayerStateEvent(self, "OnRevivalStateChangeDelegate", self.OnRevivalStateChangeDelegate, self)
  end
end
function SpectateAndReplaySubsystem:OnRevivalStateChangeDelegate(IsInWaittingRevivalState)
  if self.RevivalStateGotoSpectatingTimer then
    print(bWriteLog and "SpectateAndReplaySubsystem:OnRevivalStateChangeDelegate RevivalStateGotoSpectatingTimer is not null")
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  if GameState.PlayerNumPerTeam <= 1 then
    return
  end
  if not IsInWaittingRevivalState or PlayerController:IsSpectator() then
    return
  end
  PlayerController:BroadcastUIMessage("MainControlPanel_HideAllUI", 0, "", "")
  self:RequestGotoSpectatingForDelay()
end
function SpectateAndReplaySubsystem:RequestGotoSpectatingForDelay()
  self.RevivalStateGotoSpectatingTimer = self:AddGameTimer(2.4, false, function()
    self.RevivalStateGotoSpectatingTimer = nil
    local GameState = slua_GameFrontendHUD:GetGameState()
    local bIsLowMatch = false
    if GameState and slua.isValid(GameState) and GameState.CheckIsLowMatch then
      bIsLowMatch = GameState:CheckIsLowMatch()
    end
    if bIsLowMatch then
      return
    end
    self:RequestGotoSpectatingImp(0)
  end)
end
function SpectateAndReplaySubsystem:RequestGotoSpectatingForResultToSpectate()
  local bIsInSpectating = false
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.IsInSpectating then
    bIsInSpectating = PlayerController:IsInSpectating()
  end
  log(bWriteLog and "SpectateAndReplaySubsystem:RequestGotoSpectatingForResultToSpectate isInSpectating:" .. tostring(bIsInSpectating))
  if not bIsInSpectating then
    self:RequestGotoSpectatingForDelay()
  else
    self:RequestGotoSpectatingImp(0)
  end
end
function SpectateAndReplaySubsystem:RequestGotoSpectating()
  self:RequestGotoSpectatingImp(0)
end
function SpectateAndReplaySubsystem:RequestGotoSpectatingImp(PlayerKey)
  local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
  if BattleResultSubSystem and BattleResultSubSystem:InResultProcess() then
    print(bWriteLog and "SpectateAndReplaySubsystem:RequestGotoSpectatingImp InResultProcess return")
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if self.RevivalStateGotoSpectatingTimer then
    self:RemoveGameTimer(self.RevivalStateGotoSpectatingTimer)
    self.RevivalStateGotoSpectatingTimer = nil
  end
  PlayerKey = PlayerKey or 0
  PlayerController:GotoSpectating(PlayerKey)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, SpectateAndReplaySubsystem)