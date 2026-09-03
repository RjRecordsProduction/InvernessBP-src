local InputStateControl = {}
local InputFunctionMap = require("GameLua.GameCore.Module.Input.InputFunctionMap")
local InputMappingConfig = require("GameLua.GameCore.Module.Input.InputMappingConfig")
local TableUtil = require("common.table_util")
local Timer = require("common.time_ticker")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
InputStateControl._InputStateTable = {}
local _EnumsKeyMap = {
  LeftShift = "LeftShift",
  RightShift = "RightShift",
  LeftCtrl = "LeftControl",
  RightCtrl = "RightControl",
  LeftAlt = "LeftAlt",
  RightAlt = "RightAlt",
  LeftCmd = "LeftCommand",
  RightCmd = "RightCommand"
}
local _KeyState = {
  None = 0,
  Pressed = 1,
  Released = 2
}
local FKey = import("/Script/InputCore.Key")
local CachedKey = FKey()
function InputStateControl.Init()
  print(bWriteLog and "InputStateControl_Debug_Msg: Init")
  local DelegateContainerC = require("common.delegate_container")
  InputStateControl.DelegateContainer = DelegateContainerC()
  InputStateControl._InputStateTable = {}
  InputStateControl._MixOperationStateTable = {}
  for key, Actions in pairs(InputMappingConfig) do
    InputStateControl._InputStateTable[key] = {
      State = _KeyState.None,
      LastFrame = 0
    }
    for nPriority, Action in pairs(Actions) do
      if Action.ActionFlag then
        InputStateControl._MixOperationStateTable[Action.ActionFlag] = {Active = false, nLastTime = 0}
      end
    end
  end
  InputFunctionMap.SetMouseCursorShow()
  InputStateControl.RegistInGameEvents()
end
function InputStateControl.Destroy()
  print(bWriteLog and "InputStateControl_Debug_Msg: Destroy")
  InputFunctionMap.SetMouseCursorShow()
  if InputStateControl.DelegateContainer then
    InputStateControl.DelegateContainer:Dispose()
  end
end
function InputStateControl.RegistInGameEvents()
  local DelegateContainer = InputStateControl.DelegateContainer
  if not Game:IsValid(DelegateContainer) then
    return
  end
  DelegateContainer:AddUIMessageEvent("UIMSG_HightLightAimBtn", InputStateControl.AimStateHandle, true)
  DelegateContainer:AddUIMessageEvent("UIMSG_NormalAimBtn", InputStateControl.AimStateHandle, false)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  DelegateContainer:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", function()
    GameplayData.AddSelfPlayerCharacterEvent(DelegateContainer, "CharacterAnimEventDelegate", InputStateControl.CharacterAnimEventDelegate)
  end)
  DelegateContainer:AddCommonEvent(EVENTTYPE_GOOGLE_EMULATOR, EVENTID_SET_MOUSE_CAPTURE, InputStateControl.SetMouseCursor)
end
function InputStateControl.CharacterAnimEventDelegate(EventName)
  if EventName == "PeekState" then
    InputStateControl.OnPeekStateChange()
  end
end
function InputStateControl.OnPeekStateChange()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  if not PlayerCharacter:IsLocallyControlled() then
    return
  end
  if not slua.isValid(PlayerCharacter.SpringArmComp) then
    return
  end
  if PlayerCharacter:HasState(UEnums.EPawnState.Picth) then
    if PlayerCharacter.IsPeekLeft then
      InputStateControl.OnLeftPeekHandle(true)
    else
      InputStateControl.OnLeftPeekHandle(false)
    end
  else
    InputStateControl.OnDisablePeekHandle()
  end
end
function InputStateControl.RegistInputKeyState(key)
  if InputStateControl.WasInputKeyJustPressedByKey(key) then
    InputStateControl._AddInputActionState(key, _KeyState.Pressed)
  end
  if InputStateControl.WasInputKeyJustReleasedByKey(key) then
    InputStateControl._AddInputActionState(key, _KeyState.Released)
  end
end
function InputStateControl.CheckInputKeyState(key, TargetState)
  if not key then
    return
  end
  local sFinalKey = key.KeyName or "AnyKey"
  local sModifierKey = InputStateControl.GetCurModifierKeyName() or ""
  if sModifierKey ~= "" then
    sFinalKey = sModifierKey .. "+" .. sFinalKey
  end
  if not InputStateControl._InputStateTable[sFinalKey] or not InputStateControl._InputStateTable[sFinalKey].LastFrame then
    return false
  end
  local bFrameCheck = InputStateControl._InputStateTable[sFinalKey].LastFrame ~= Timer.GFrameCount
  return bFrameCheck
end
function InputStateControl.CallInputAction(key)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    return
  end
  if not PlayerController.bPCInputSwitcher then
    return
  end
  local sFinalKey = key.KeyName or "AnyKey"
  local sModifierKey = InputStateControl.GetCurModifierKeyName() or ""
  if sModifierKey ~= "" then
    sFinalKey = sModifierKey .. "+" .. sFinalKey
  end
  local InputAction = InputMappingConfig[sFinalKey]
  if not InputAction then
    return
  end
  local CurInputAction = InputStateControl.GetCurInputAction(InputAction)
  if not CurInputAction then
    return
  end
  local Params = CurInputAction.Params or {}
  if InputStateControl.WasInputKeyJustPressedByKey(key) and CurInputAction.PressedFunction and InputStateControl.CheckInputKeyState(key, _KeyState.Released) then
    if CurInputAction.ActionFlag then
      InputStateControl.CheckMixOperationPressed(CurInputAction)
    else
      CurInputAction.PressedFunction(table.unpack(Params))
    end
  end
  if InputStateControl.WasInputKeyJustReleasedByKey(key) and CurInputAction.ReleasedFunction and InputStateControl.CheckInputKeyState(key, _KeyState.Pressed) then
    if CurInputAction.ActionFlag then
      InputStateControl.CheckMixOperationReleased(CurInputAction)
    else
      CurInputAction.ReleasedFunction(table.unpack(Params))
    end
  end
  InputStateControl.RegistInputKeyState(key)
end
function InputStateControl.CheckMixOperationPressed(CurInputAction)
  local ActionFlag = CurInputAction.ActionFlag
  if not ActionFlag then
    return
  end
  local Params = CurInputAction.Params or {}
  if InputStateControl._MixOperationStateTable[ActionFlag].Active == true and CurInputAction.ReleasedFunction then
    CurInputAction.ReleasedFunction(table.unpack(Params))
  elseif InputStateControl._MixOperationStateTable[ActionFlag].Active == false and CurInputAction.PressedFunction then
    CurInputAction.PressedFunction(table.unpack(Params))
    InputStateControl._MixOperationStateTable[ActionFlag].nLastTime = GamePlayTools.GetServerWorldTimeSeconds()
  end
end
function InputStateControl.CheckMixOperationReleased(CurInputAction)
  local ActionFlag = CurInputAction.ActionFlag
  if not ActionFlag then
    return
  end
  local MixOperationThreshold = CurInputAction.MixOperationThreshold or 0
  local nCurTime = GamePlayTools.GetServerWorldTimeSeconds()
  local nLastTime = InputStateControl._MixOperationStateTable[ActionFlag].nLastTime or 0
  local Params = CurInputAction.Params or {}
  if MixOperationThreshold <= nCurTime - nLastTime then
    CurInputAction.ReleasedFunction(table.unpack(Params))
  end
end
function InputStateControl.GetCurInputAction(InputAction)
  local FinalInputAction
  for nPriority, CurInputAction in ipairs(InputAction) do
    if CurInputAction and (CurInputAction.ActiveCondition == nil or CurInputAction.ActiveCondition == true or CurInputAction.ActiveCondition()) then
      return CurInputAction
    end
  end
  return FinalInputAction
end
function InputStateControl.IsInputKeyDownByKeyName(sName)
  if not sName then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  CachedKey.KeyName = sName
  return uPlayerController:IsInputKeyDown(CachedKey)
end
function InputStateControl.IsInputKeyDownByKey(Key)
  if not Key then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  return uPlayerController:IsInputKeyDown(Key)
end
function InputStateControl.WasInputKeyJustPressedByKeyName(sName)
  if not sName then
    return
  end
  CachedKey.KeyName = sName
  return InputStateControl.WasInputKeyJustPressedByKey(CachedKey)
end
function InputStateControl.WasInputKeyJustPressedByKey(Key)
  if not Key then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  return uPlayerController:WasInputKeyJustPressed(Key)
end
function InputStateControl.WasInputKeyJustReleasedByKeyName(sName)
  if not sName then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  CachedKey.KeyName = sName
  return uPlayerController:WasInputKeyJustReleased(CachedKey)
end
function InputStateControl.WasInputKeyJustReleasedByKey(Key)
  if not Key then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  return uPlayerController:WasInputKeyJustReleased(Key)
end
function InputStateControl.IsLeftCtrlPressed()
  return InputStateControl.IsInputKeyDownByKeyName(_EnumsKeyMap.LeftCtrl)
end
function InputStateControl.IsRightCtrlPressed()
  return InputStateControl.IsInputKeyDownByKeyName(_EnumsKeyMap.RightCtrl)
end
function InputStateControl.IsLeftShiftPressed()
  return InputStateControl.IsInputKeyDownByKeyName(_EnumsKeyMap.LeftShift)
end
function InputStateControl.IsRightShiftPressed()
  return InputStateControl.IsInputKeyDownByKeyName(_EnumsKeyMap.RightShift)
end
function InputStateControl.IsLeftAltPressed()
  return InputStateControl.IsInputKeyDownByKeyName(_EnumsKeyMap.LeftAlt)
end
function InputStateControl.IsRightAltPressed()
  return InputStateControl.IsInputKeyDownByKeyName(_EnumsKeyMap.RightAlt)
end
function InputStateControl.IsLeftCmdPressed()
  return InputStateControl.IsInputKeyDownByKeyName(_EnumsKeyMap.LeftCmd)
end
function InputStateControl.IsRightCmdPressed()
  return InputStateControl.IsInputKeyDownByKeyName(_EnumsKeyMap.RightCmd)
end
function InputStateControl.GetCurModifierKeyName()
  local sModifierKey = ""
  if InputStateControl.IsLeftAltPressed() then
  elseif InputStateControl.IsRightAltPressed() then
    sModifierKey = _EnumsKeyMap.RightAlt
  elseif InputStateControl.IsLeftCtrlPressed() then
  elseif InputStateControl.IsRightCtrlPressed() then
    sModifierKey = _EnumsKeyMap.RightCtrl
  elseif InputStateControl.IsLeftShiftPressed() then
  elseif InputStateControl.IsRightShiftPressed() then
    sModifierKey = _EnumsKeyMap.RightShift
  elseif InputStateControl.IsLeftCmdPressed() then
    sModifierKey = _EnumsKeyMap.LeftCmd
  elseif InputStateControl.IsRightCmdPressed() then
    sModifierKey = _EnumsKeyMap.RightCmd
  end
  return sModifierKey
end
function InputStateControl._AddInputActionState(key, state)
  if not key then
    return
  end
  local sFinalKey = key.KeyName or "AnyKey"
  local sModifierKey = InputStateControl.GetCurModifierKeyName() or ""
  if sModifierKey ~= "" then
    sFinalKey = sModifierKey .. "+" .. sFinalKey
  end
  if not InputStateControl._InputStateTable[sFinalKey] or not InputStateControl._InputStateTable[sFinalKey].LastFrame then
    return false
  end
  InputStateControl._InputStateTable[sFinalKey].State = state
  InputStateControl._InputStateTable[sFinalKey].LastFrame = Timer.GFrameCount
end
function InputStateControl.AimStateHandle(bIsScoping)
  InputStateControl._MixOperationStateTable.Aim.Active = bIsScoping
end
function InputStateControl.OnLeftPeekHandle(bLeft)
  InputStateControl._MixOperationStateTable.LeftPeek.Active = bLeft
  InputStateControl._MixOperationStateTable.RightPeek.Active = not bLeft
end
function InputStateControl.OnDisablePeekHandle()
  InputStateControl._MixOperationStateTable.LeftPeek.Active = false
  InputStateControl._MixOperationStateTable.RightPeek.Active = false
end
function InputStateControl.SetMouseCursor(_, _, bShow)
  if bShow then
    InputFunctionMap.SetMouseCursorShow()
  else
    InputFunctionMap.SetMouseCursorHide()
  end
end
return InputStateControl