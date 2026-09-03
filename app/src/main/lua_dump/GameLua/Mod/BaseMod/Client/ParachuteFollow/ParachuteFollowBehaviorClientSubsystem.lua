local ParachuteFollowBehaviorClientSubsystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BehaviorConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ParachuteFollowBehaviorConfig")
function ParachuteFollowBehaviorClientSubsystem:ctor()
  print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:ctor")
  self.bMicStatusReported = false
  self.bUIActivityReported = false
  self.bBehaviorDetectionStarted = false
end
function ParachuteFollowBehaviorClientSubsystem:OnInit()
  print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:OnInit")
  ParachuteFollowBehaviorClientSubsystem.__super.OnInit(self)
  if not Client then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:OnInit - Skip on server side")
    return
  end
  if BehaviorConfig.IsDSSwitchOpen() then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:OnInit - DS switch already open, start detection")
    self:_StartBehaviorDetection()
    return
  end
  print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:OnInit - DS switch not available yet, waiting for OnRep")
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.OnDSSwitchChanged then
    self:AddControlEvent(uGameState, "OnDSSwitchChanged", self._OnDSSwitchReplicated, self)
  else
    print(bWriteLog and string.format("ParachuteFollowBehaviorClientSubsystem:OnInit - GameState invalid or OnDSSwitchChanged delegate not found, isValid=%s,", tostring(slua.isValid(uGameState))))
  end
end
function ParachuteFollowBehaviorClientSubsystem:_OnDSSwitchReplicated()
  print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:_OnDSSwitchReplicated")
  if self.bBehaviorDetectionStarted then
    return
  end
  if BehaviorConfig.IsDSSwitchOpen() then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:_OnDSSwitchReplicated - DS switch open, start detection")
    self:_StartBehaviorDetection()
  else
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:_OnDSSwitchReplicated - DS switch not open, skip")
  end
end
function ParachuteFollowBehaviorClientSubsystem:_StartBehaviorDetection()
  if self.bBehaviorDetectionStarted then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:_StartBehaviorDetection - Already started, skip")
    return
  end
  self.bBehaviorDetectionStarted = true
  print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:_StartBehaviorDetection")
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH_MICROPHONE, self.OnMicRefresh, self)
  local InputClass = import("ScreenInput")
  local UIUtil = require("client.common.ui_util")
  local worldContextObject = UIUtil.GetGameInstance()
  local screenInput = InputClass(worldContextObject)
  screenInput:Init()
  self:AddControlEvent(screenInput, "OnMouseButtonDown", function()
    self:CheckUIInteraction()
    if screenInput and self.bUIActivityReported then
      self:RemoveControlEvent(screenInput, "OnMouseButtonDown")
    end
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:_StartBehaviorDetection OnMouseButtonDown")
  end)
end
function ParachuteFollowBehaviorClientSubsystem:CheckUIInteraction()
  if self.bUIActivityReported then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:CheckUIInteraction - Already reported")
    return
  end
  print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:CheckUIInteraction  reporting")
  self:ReportUIActivityToDS()
  self.bUIActivityReported = true
end
function ParachuteFollowBehaviorClientSubsystem:OnMicRefresh()
  print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:OnMicRefresh")
  local bMicOpen = self:IsMicOpen()
  if not bMicOpen then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:OnMicRefresh - Mic not open, skip")
    return
  end
  if self.bMicStatusReported then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:OnMicRefresh - Already reported, skip")
    return
  end
  self:ReportMicStatusToDS(true)
  self.bMicStatusReported = true
end
function ParachuteFollowBehaviorClientSubsystem:IsMicOpen()
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  local logic_chat_voice = ModuleManager and ModuleManager.GetModule and ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  if not logic_chat_voice then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:IsMicOpen - logic_chat_voice not found")
    return false
  end
  local bMicOpen = logic_chat_voice:GetSelfRoomMicrophoneState(logic_chat_voice_const.Enum_AntsVoiceRoomType.BattleTeam)
  print(bWriteLog and string.format("ParachuteFollowBehaviorClientSubsystem:IsMicOpen - bMicOpen=%s", tostring(bMicOpen)))
  return bMicOpen == true
end
function ParachuteFollowBehaviorClientSubsystem:ReportMicStatusToDS(bMicOpen)
  print(bWriteLog and string.format("ParachuteFollowBehaviorClientSubsystem:ReportMicStatusToDS - bMicOpen=%s", tostring(bMicOpen)))
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:ReportMicStatusToDS - PC invalid")
    return
  end
  if not PC.ParachuteFollowBehaviorFeature then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:ReportMicStatusToDS - Feature not found")
    return
  end
  PC.ParachuteFollowBehaviorFeature:RPC_Server_ReportMicStatus(bMicOpen)
end
function ParachuteFollowBehaviorClientSubsystem:ReportUIActivityToDS()
  print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:ReportUIActivityToDS")
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:ReportUIActivityToDS - PC invalid")
    return
  end
  if not PC.ParachuteFollowBehaviorFeature then
    print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:ReportUIActivityToDS - Feature not found")
    return
  end
  PC.ParachuteFollowBehaviorFeature:RPC_Server_ReportUIActivity()
end
function ParachuteFollowBehaviorClientSubsystem:OnRelease()
  print(bWriteLog and "ParachuteFollowBehaviorClientSubsystem:OnRelease")
  self.bMicStatusReported = false
  self.bUIActivityReported = false
  self.bBehaviorDetectionStarted = false
  ParachuteFollowBehaviorClientSubsystem.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
local CParachuteFollowBehaviorClientSubsystem = class(SubsystemBase, nil, ParachuteFollowBehaviorClientSubsystem)
return CParachuteFollowBehaviorClientSubsystem