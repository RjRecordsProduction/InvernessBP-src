local ShootingUI_AutoSprintBtn = {}
local EPawnState = import("EPawnState")
local ESTEPoseState = import("ESTEPoseState")
local GameplayStatics = import("GameplayStatics")
local UTSkillEventType = import("UTSkillEventType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
function ShootingUI_AutoSprintBtn:ctor()
  self.bAutoSprintForCached = nil
  self.SpSprintNormalIcon = ""
  self.SpSprintLightIcon = ""
  self.bLight = false
  self.IsEmulator = false
  self.IsRunning = false
end
function ShootingUI_AutoSprintBtn:OnInitialize()
  self:InitPlayerControllerVariables()
end
function ShootingUI_AutoSprintBtn:RegistEvents()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:RegistEvents")
  self:AddControlEventByControl(self.UIRoot.Sprint, "OnPressed", self.OnPressedSprint, self)
  self:AddUIMessageEvent("ActiveSprint", self.ActiveSprint, self)
  self:AddUIMessageEvent("UIMsg_SetAutoSprint", self.UIMsg_SetAutoSprint, self)
  self:AddUIMessageEvent("OnSprintStateInterrupt", self.OnSprintStateInterrupt, self)
  self:AddUIMessageEvent("UIMsg_JoyStickTriggerSprint", self.UIMsg_JoyStickTriggerSprint, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_STOP_SPRINT_STATE, self.OnSprintStateInterrupt, self)
  self:AddUIMessageEvent("EnterNearDeathStatus", self.OnEnterNearDeathStatus, self)
  self:AddUIMessageEvent("UIMsg_BleSprint", self.UIMsg_BleSprint, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_SprintPanel, self, "ShootingUIPanel_MultiLayer_SprintPanel")
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.HandleUIWhenPlayerOnPlane, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFighting", self.HandleUIWhenPlayerLand, self)
  self:AddUIMessageEvent("UIMsg_UpdateStandCrouchAndSprint", self.UIMsg_UpdateStandCrouchAndSprint, self)
end
function ShootingUI_AutoSprintBtn:OnPostInitialize()
  self.IsEmulator = Client.IsEmulatorWhenInit()
  if self.IsEmulator then
    self:AddGameTimer(0.25, true, function()
      self:CombineKeyDownLogic()
    end)
  end
end
function ShootingUI_AutoSprintBtn:OnClose()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_SprintPanel)
end
function ShootingUI_AutoSprintBtn:HandleUIWhenPlayerOnPlane()
  self:ResetUIOnPlane()
end
function ShootingUI_AutoSprintBtn:Reconnect_ResetUIByPlayerControllerState()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:Reconnect_ResetUIByPlayerControllerState")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and (PlayerController:IsInPlane() or PlayerController:IsInParachute()) then
    self:ResetUIOnPlane()
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and PlayerCharacter.CurPoseState then
    self:UpdateStandCrouchProneAndSprint(PlayerCharacter.CurPoseState)
  end
end
function ShootingUI_AutoSprintBtn:ResetUIOnPlane()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:ResetUIOnPlane")
  self:HideAutoSprintUI()
end
function ShootingUI_AutoSprintBtn:HandleUIWhenPlayerLand()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:HandleUIWhenPlayerLand")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and PlayerCharacter:SwitchPoseState(PlayerCharacter.PoseState, false, false, false, false) then
    self:HideAutoSprintUI()
  end
end
function ShootingUI_AutoSprintBtn:InitPlayerControllerVariables()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:InitPlayerControllerVariables")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUI_AutoSprintBtn:InitPlayerControllerVariables not slua.isValid(uPlayerController)")
    return
  end
end
function ShootingUI_AutoSprintBtn:OnEnterNearDeathStatus()
  self:OnSprintStateInterrupt()
end
function ShootingUI_AutoSprintBtn:UIMsg_BleSprint()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:UIMsg_BleSprint")
  self:BleSprint()
end
function ShootingUI_AutoSprintBtn:UIMsg_JoyStickTriggerSprint()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if PlayerController.IsJoystickTriggerSprint then
    self:SetSpintImgBrush(true)
  else
    self:SetSpintImgBrush(false)
    self:HideAutoSprintUI()
  end
end
function ShootingUI_AutoSprintBtn:OnPressedSprint()
  local Character = GameplayStatics.GetPlayerPawn(self.UIRoot, 0)
  if slua.isValid(Character) then
    self:ActiveSprint()
  end
end
function ShootingUI_AutoSprintBtn:UIMsg_SetAutoSprint()
  self:OnPressedSprint()
end
function ShootingUI_AutoSprintBtn:BleSprint()
  self:OnPressedSprint()
end
function ShootingUI_AutoSprintBtn:SprintInterupted()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:SprintInterupted")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUI_AutoSprintBtn:SprintInterupted not uPlayerCharacter")
    return
  end
  local bSuccess = false
  local PoseState = PlayerCharacter.PoseState
  if PoseState == ESTEPoseState.Stand or PoseState == ESTEPoseState.Crouch or PoseState == ESTEPoseState.Prone then
    bSuccess = true
  elseif PoseState == ESTEPoseState.Sprint then
    bSuccess = PlayerCharacter:SwitchPoseState(ESTEPoseState.Stand, false, false, true, false)
  elseif PoseState == ESTEPoseState.CrouchSprint then
    bSuccess = PlayerCharacter:SwitchPoseState(ESTEPoseState.Crouch, false, false, true, false)
  elseif PoseState == ESTEPoseState.Crawl then
    bSuccess = PlayerCharacter:SwitchPoseState(ESTEPoseState.Prone, false, false, true, false)
  end
  if bSuccess then
    self:SetSpintImgBrush(false)
    self:HideAutoSprintUI()
  end
end
function ShootingUI_AutoSprintBtn:ActiveSprint()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:ActiveSprint")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUI_AutoSprintBtn:ActiveSprint not PlayerController")
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUI_AutoSprintBtn:ActiveSprint not PlayerCharacter")
    return
  end
  if PlayerController.bAutoSprint then
    self:TryExitAutoSprintState(PlayerCharacter)
  else
    self:TryEnterAutoSprintState(PlayerCharacter)
    local uPlayerState = PlayerController.PlayerState
    if slua.isValid(uPlayerState) then
      uPlayerState.MovingCount = uPlayerState.MovingCount + 1
    end
  end
end
function ShootingUI_AutoSprintBtn:TryExitAutoSprintState(PlayerCharacter)
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local bSuccess = false
  if PlayerCharacter.PoseState == ESTEPoseState.Stand or PlayerCharacter.PoseState == ESTEPoseState.Crouch or PlayerCharacter.PoseState == ESTEPoseState.Prone then
    bSuccess = true
  else
    local SwitchTargetTable = {
      [ESTEPoseState.Sprint] = ESTEPoseState.Stand,
      [ESTEPoseState.CrouchSprint] = ESTEPoseState.Crouch,
      [ESTEPoseState.Crawl] = ESTEPoseState.Prone,
      [ESTEPoseState.Swim] = ESTEPoseState.Swim,
      [ESTEPoseState.SwimSprint] = ESTEPoseState.Swim
    }
    local Target = SwitchTargetTable[PlayerCharacter.PoseState]
    if Target then
      bSuccess = PlayerCharacter:SwitchPoseState(Target, false, false, true, false)
    end
  end
  if bSuccess then
    self:SetSpintImgBrush(false)
    self:HideAutoSprintUI()
  end
end
function ShootingUI_AutoSprintBtn:TryEnterAutoSprintState(PlayerCharacter)
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  local SwitchTargetTable1 = {
    [ESTEPoseState.Stand] = ESTEPoseState.Sprint,
    [ESTEPoseState.Crouch] = ESTEPoseState.CrouchSprint,
    [ESTEPoseState.Prone] = ESTEPoseState.Crawl,
    [ESTEPoseState.Swim] = ESTEPoseState.SwimSprint
  }
  local Target = SwitchTargetTable1[PlayerCharacter.PoseState]
  if Target then
    local bCanSprintOrSwim = OperateSubsystem:CanPlayerAutoSprintOrSwim()
    if bCanSprintOrSwim then
      local bSuccess = PlayerCharacter:SwitchPoseState(Target, false, false, true, false)
      if bSuccess then
        self:SetSpintImgBrush(true)
        self:ShowAutoSprintUI()
      elseif PlayerCharacter.PoseState == ESTEPoseState.Swim then
        self:HideAutoSprintUI()
      elseif PlayerCharacter:AllowState(EPawnState.Move, true) then
        local PlayerController = GameplayData.GetPlayerController()
        if slua.isValid(PlayerController) then
          PlayerController.bAutoSprint = true
        end
      else
        self:HideAutoSprintUI()
      end
    end
  else
    local SwitchTargetTable2 = {
      [ESTEPoseState.Sprint] = ESTEPoseState.Stand,
      [ESTEPoseState.CrouchSprint] = ESTEPoseState.Crouch,
      [ESTEPoseState.Crawl] = ESTEPoseState.Prone,
      [ESTEPoseState.SwimSprint] = ESTEPoseState.Swim
    }
    Target = SwitchTargetTable1[PlayerCharacter.PoseState]
    if Target then
      local bSuccess = PlayerCharacter:SwitchPoseState(Target, false, false, true, false)
      if bSuccess then
        self:SetSpintImgBrush(false)
        self:HideAutoSprintUI()
      end
    end
  end
end
function ShootingUI_AutoSprintBtn:ShowAutoSprintUI()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:ShowAutoSprintUI")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUI_AutoSprintBtn:ShowAutoSprintUI not PlayerController")
    return
  end
  PlayerController.bAutoSprint = true
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  InGameUITools.SetJoystickSprintState(true)
  PlayerController:SetVirtualStickAutoSprintStatus(true)
end
function ShootingUI_AutoSprintBtn:HideAutoSprintUI()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:HideAutoSprintUI")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUI_AutoSprintBtn:HideAutoSprintUI not PlayerController")
    return
  end
  PlayerController.bAutoSprint = false
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  InGameUITools.SetJoystickSprintState(false)
  PlayerController:SetVirtualStickAutoSprintStatus(false)
  self:SetSpintImgBrush(false)
end
function ShootingUI_AutoSprintBtn:OnSprintStateInterrupt()
  self:SprintInterupted()
end
function ShootingUI_AutoSprintBtn:SetSpintImgBrush(bLight)
  self.  if self.SpSprintNormalIcon ~= "" and self.SpSprintLightIcon ~= "" then
    if self.bLight then
      self.UIRoot.SprintImg:SetBrushFromPathAsync(self.SpSprintLightIcon, true)
    else
      self.UIRoot.SprintImg:SetBrushFromPathAsync(self.SpSprintNormalIcon, true)
    end
    return
  end
  local SprintNormalBrushPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_zidongbenpao_png.ZD_icon_zidongbenpao_png"
  local SprintLightBrushPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_zidongbenpao_2_png.ZD_icon_zidongbenpao_2_png"
  local SprintBrushPath = SprintNormalBrushPath
  if bLight then
    SprintBrushPath = SprintLightBrushPath
  end
  if self.UIRoot.SprintImg then
    self.UIRoot.SprintImg:SetBrushFromPathAsync(SprintBrushPath, false)
  end
end
function ShootingUI_AutoSprintBtn:SetSpecialSprintIcon(NormalIcon, LightIcon)
  self.SpSprint  self.SpSprint  if self.bLight then
    if LightIcon == "" then
      self:SetSpintImgBrush(self.bLight)
    else
      self.UIRoot.SprintImg:SetBrushFromPathAsync(LightIcon, true)
    end
  elseif NormalIcon == "" then
    self:SetSpintImgBrush(self.bLight)
  else
    self.UIRoot.SprintImg:SetBrushFromPathAsync(NormalIcon, true)
  end
end
function ShootingUI_AutoSprintBtn:SetSprintImgOpacity(Opacity)
  if self.UIRoot.SprintImg then
    self.UIRoot.SprintImg:SetOpacity(Opacity)
  end
end
function ShootingUI_AutoSprintBtn:UIMsg_UpdateStandCrouchAndSprint()
  print(bWriteLog and "ShootingUI_AutoSprintBtn:UIMsg_UpdateStandCrouchAndSprint")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    self:UpdateStandCrouchProneAndSprint(PlayerCharacter.PoseState)
  end
end
function ShootingUI_AutoSprintBtn:UpdateStandCrouchProneAndSprint(PoseState)
  print(bWriteLog and "ShootingUI_AutoSprintBtn:UpdateStandCrouchProneAndSprint PoseState=" .. tostring(PoseState))
  if PoseState == ESTEPoseState.Sprint then
    return
  end
  if PoseState == ESTEPoseState.CrouchSprint then
    return
  end
  if PoseState == ESTEPoseState.Crawl then
    return
  end
  if PoseState == ESTEPoseState.Stand or PoseState == ESTEPoseState.Crouch then
    self:SetSpintImgBrush(false)
    return
  end
  if PoseState == ESTEPoseState.Prone then
    self:SetSpintImgBrush(false)
    return
  end
end
function ShootingUI_AutoSprintBtn:CombineKeyDownLogic()
  if self.IsRunning then
    if not self:CheckIsKeyDown({KeyName = "LeftShift"}) or not self:CheckIsKeyDown({KeyName = "W"}) then
      self:ActiveSprint()
      self.IsRunning = false
    end
  elseif self:CheckIsKeyDown({KeyName = "LeftShift"}) and self:CheckIsKeyDown({KeyName = "W"}) then
    self:ActiveSprint()
    self.IsRunning = true
  end
end
function ShootingUI_AutoSprintBtn:CheckIsKeyDown(KeyCode)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    return PlayerController:GetInputKeyTimeDown(KeyCode) >= 1.0E-5
  end
  return false
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CAutoSprintUI = class(ui_base, nil, ShootingUI_AutoSprintBtn)
return CAutoSprintUI