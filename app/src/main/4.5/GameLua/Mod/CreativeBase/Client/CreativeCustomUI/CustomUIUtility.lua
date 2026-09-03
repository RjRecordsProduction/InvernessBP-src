local CustomUIUtility = {}
local CustomUIDefine = require("GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CustomUIDefine")
local E_Align = CustomUIDefine.E_Align
local CustomUIAdaptationCalculator = require("GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CustomUIAdaptationCalculator")
local _MirrorPositionInParentSpace = function(ChildCenterX, ChildCenterY, ChildAbsAngle, ParentCenterX, ParentCenterY, ParentAngle, bHorizontal)
  local DX = ChildCenterX - ParentCenterX
  local DY = ChildCenterY - ParentCenterY
  local Rad = math.rad(-ParentAngle)
  local S = math.sin(Rad)
  local C = math.cos(Rad)
  local LocalX = DX * C - DY * S
  local LocalY = DX * S + DY * C
  local MirroredLocalX, MirroredLocalY
  if bHorizontal then
    MirroredLocalX = -LocalX
    Mirrored  else
    Mirrored    MirroredLocalY = -LocalY
  end
  local Rad2 = math.rad(ParentAngle)
  local S2 = math.sin(Rad2)
  local C2 = math.cos(Rad2)
  local NewCenterX = MirroredLocalX * C2 - MirroredLocalY * S2 + ParentCenterX
  local NewCenterY = MirroredLocalX * S2 + MirroredLocalY * C2 + ParentCenterY
  local NewAbsAngle
  if bHorizontal then
    NewAbsAngle = 2 * ParentAngle - ChildAbsAngle
  else
    NewAbsAngle = 2 * ParentAngle + 360 - ChildAbsAngle
  end
  return NewCenterX, NewCenterY, NewAbsAngle
end
local _UnrotateFromParent = function(PosX, PosY, ParentBounds)
  local ParentAngle = ParentBounds.Angle or 0
  if ParentAngle == 0 then
    return PosX, PosY
  end
  local ParentCenterX = ParentBounds.CenterX or ParentBounds.X + ParentBounds.Width / 2
  local ParentCenterY = ParentBounds.CenterY or ParentBounds.Y + ParentBounds.Height / 2
  local DX = PosX - ParentCenterX
  local DY = PosY - ParentCenterY
  local Rad = math.rad(-ParentAngle)
  local S = math.sin(Rad)
  local C = math.cos(Rad)
  return DX * C - DY * S + ParentCenterX, DX * S + DY * C + ParentCenterY
end
local _InsertMirrorFlagChangeData = function(InstanceManager, InstanceID, MirrorKey, InputChangeDataList)
  local MirrorValue = InstanceManager:GetObjectValue(InstanceID, MirrorKey)
  table.insert(InputChangeDataList, {
    InstanceID = InstanceID,
    Key = MirrorKey,
    Value = not MirrorValue
  })
end
local _InsertMirrorAdaptationChangeData = function(InstanceID, NewCenterX, NewCenterY, NewAbsoluteAngle, UITransform, InputChangeDataList)
  local Width = UITransform.SizeX or 0
  local Height = UITransform.SizeY or 0
  local ParentBounds = CustomUIAdaptationCalculator.GetParentBounds(InstanceID, true)
  local InstanceManager = GetInstanceManager()
  local InstanceData = InstanceManager:GetInstance(InstanceID)
  local CurAdaptationInfo = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.AdaptationInfo", InstanceData, nil)
  local NewAdaptationInfo = CustomUIAdaptationCalculator.ReverseCalculate(NewCenterX, NewCenterY, Width, Height, CurAdaptationInfo, ParentBounds)
  table.insert(InputChangeDataList, {
    InstanceID = InstanceID,
    Key = "CustomUIBase.AdaptationInfo",
    Value = NewAdaptationInfo
  })
  local ParentAccumulatedAngle = ParentBounds.Angle or 0
  local RelativeAngle = NewAbsoluteAngle - ParentAccumulatedAngle
  table.insert(InputChangeDataList, {
    InstanceID = InstanceID,
    Key = "Transform.Location",
    Value = {
      X = 0,
      Y = 0,
      Z = RelativeAngle
    }
  })
end
function CustomUIUtility.AlignInstances(InstanceIds, Align, AlignType, ReferenceBounds)
  if not InstanceIds or not next(InstanceIds) then
    return false
  end
  local CreateModeCustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
  if not CreateModeCustomUISubsystem then
    return false
  end
  local TreeEditSubsystem = SubsystemMgr:Get("CreativeModeCustomUITreeEditSubsystem")
  if not TreeEditSubsystem then
    return false
  end
  local ChangeDataList = {}
  local SortedList = CustomUIUtility.SortEditInstancesByDepth(InstanceIds, TreeEditSubsystem)
  local NewPositionMap = {}
  for _, Entry in ipairs(SortedList) do
    local InstanceID = Entry.InstanceID
    local EditInstance = CreateModeCustomUISubsystem:GetCustomUIInstance(InstanceID)
    if EditInstance then
      local Widget = EditInstance.Widget
      local UITransform = Widget:GetUITransform()
      local NewTranslationX, NewTranslationY
      if AlignType == "horizontal" then
        NewTranslationX, NewTranslationY = CustomUIUtility.CalcHorizontalAlignmentPosition(Align, UITransform, ReferenceBounds)
      elseif AlignType == "vertical" then
        NewTranslationX, NewTranslationY = CustomUIUtility.CalcVerticalAlignmentPosition(Align, UITransform, ReferenceBounds)
        goto lbl_67
        goto lbl_96
        ::lbl_67::
        local OverrideParentBounds
        local ParentInstanceID = TreeEditSubsystem:GetParentInstanceID(InstanceID)
        if ParentInstanceID and NewPositionMap[ParentInstanceID] then
          local ParentInfo = NewPositionMap[ParentInstanceID]
          OverrideParentBounds = CustomUIUtility.BuildParentBoundsFromNewPosition(ParentInfo.NewCenterX, ParentInfo.NewCenterY, ParentInfo.UITransform)
        end
        CustomUIUtility.InsertAdaptationChangeData(InstanceID, NewTranslationX, NewTranslationY, UITransform, ChangeDataList, OverrideParentBounds)
        NewPositionMap[InstanceID] = {
          NewCenterX = NewTranslationX,
          NewCenterY = NewTranslationY,
                  }
      end
    end
    ::lbl_96::
  end
  if next(ChangeDataList) then
    CreateModeCustomUISubsystem:MultiSetPropertyValue(ChangeDataList)
    return true
  end
  return false
end
function CustomUIUtility.CalcHorizontalAlignmentPosition(Align, UITransform, ReferenceBounds)
  local NewTranslationX = UITransform.TranslationX
  local NewTranslationY = UITransform.TranslationY
  if ReferenceBounds then
    if Align == E_Align.Left then
      local MinX = ReferenceBounds.TranslationX - ReferenceBounds.SizeX * 0.5
      NewTranslationX = MinX + (UITransform.MaxX - UITransform.MinX) * 0.5
    elseif Align == E_Align.Center then
      NewTranslationX = ReferenceBounds.TranslationX
    elseif Align == E_Align.Right then
      local MaxX = ReferenceBounds.TranslationX + ReferenceBounds.SizeX * 0.5
      NewTranslationX = MaxX - (UITransform.MaxX - UITransform.MinX) * 0.5
    end
  else
    local CreateModeCustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
    local CanvasWidth = CreateModeCustomUISubsystem:GetCanvasSize().Width
    if Align == E_Align.Left then
      NewTranslationX = UITransform.TranslationX - UITransform.MinX
    elseif Align == E_Align.Center then
      NewTranslationX = math.floor(CanvasWidth / 2 * 100) / 100
    elseif Align == E_Align.Right then
      NewTranslationX = CanvasWidth + UITransform.TranslationX - UITransform.MaxX
    end
  end
  return NewTranslationX, NewTranslationY
end
function CustomUIUtility.CalcVerticalAlignmentPosition(Align, UITransform, ReferenceBounds)
  local NewTranslationX = UITransform.TranslationX
  local NewTranslationY = UITransform.TranslationY
  if ReferenceBounds then
    if Align == E_Align.Top then
      local MinY = ReferenceBounds.TranslationY - ReferenceBounds.SizeY * 0.5
      NewTranslationY = MinY + (UITransform.MaxY - UITransform.MinY) * 0.5
    elseif Align == E_Align.Center then
      NewTranslationY = ReferenceBounds.TranslationY
    elseif Align == E_Align.Bottom then
      local MaxY = ReferenceBounds.TranslationY + ReferenceBounds.SizeY * 0.5
      NewTranslationY = MaxY - (UITransform.MaxY - UITransform.MinY) * 0.5
    end
  else
    local CreateModeCustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
    local CanvasHeight = CreateModeCustomUISubsystem:GetCanvasSize().Height
    if Align == E_Align.Top then
      NewTranslationY = UITransform.TranslationY - UITransform.MinY
    elseif Align == E_Align.Center then
      NewTranslationY = math.floor(CanvasHeight / 2 * 100) / 100
    elseif Align == E_Align.Bottom then
      NewTranslationY = CanvasHeight + UITransform.TranslationY - UITransform.MaxY
    end
  end
  return NewTranslationX, NewTranslationY
end
function CustomUIUtility.InsertAdaptationChangeData(InstanceID, NewCenterX, NewCenterY, UITransform, InputChangeDataList, OverrideParentBounds)
  local Width = UITransform.SizeX or 0
  local Height = UITransform.SizeY or 0
  local ParentBounds = OverrideParentBounds or CustomUIAdaptationCalculator.GetParentBounds(InstanceID, true)
  local InstanceManager = GetInstanceManager()
  local InstanceData = InstanceManager:GetInstance(InstanceID)
  local CurAdaptationInfo = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.AdaptationInfo", InstanceData, nil)
  local NewAdaptationInfo = CustomUIAdaptationCalculator.ReverseCalculate(NewCenterX, NewCenterY, Width, Height, CurAdaptationInfo, ParentBounds)
  table.insert(InputChangeDataList, {
    InstanceID = InstanceID,
    Key = "CustomUIBase.AdaptationInfo",
    Value = NewAdaptationInfo
  })
  local ParentAccumulatedAngle = ParentBounds.Angle or 0
  local RelativeAngle = UITransform.Angle - ParentAccumulatedAngle
  table.insert(InputChangeDataList, {
    InstanceID = InstanceID,
    Key = "Transform.Location",
    Value = {
      X = 0,
      Y = 0,
      Z = RelativeAngle
    }
  })
end
function CustomUIUtility.GetInstanceDepth(InstanceID, TreeEditSubsystem)
  local Depth = 0
  local CurID = InstanceID
  while true do
    local ParentID = TreeEditSubsystem:GetParentInstanceID(CurID)
    if not ParentID then
      break
    end
    Depth = Depth + 1
    CurID = ParentID
  end
  return Depth
end
function CustomUIUtility.SortEditInstancesByDepth(InstanceIds, TreeEditSubsystem)
  local SortedList = {}
  for _, InstanceID in ipairs(InstanceIds) do
    local Depth = CustomUIUtility.GetInstanceDepth(InstanceID, TreeEditSubsystem)
    table.insert(SortedList, {InstanceID = InstanceID, Depth = Depth})
  end
  table.sort(SortedList, function(a, b)
    return a.Depth < b.Depth
  end)
  return SortedList
end
function CustomUIUtility.BuildParentBoundsFromNewPosition(ParentNewCenterX, ParentNewCenterY, ParentUITransform)
  local SizeX = ParentUITransform.SizeX or 0
  local SizeY = ParentUITransform.SizeY or 0
  return {
    X = ParentNewCenterX - SizeX / 2,
    Y = ParentNewCenterY - SizeY / 2,
    Width = SizeX,
    Height = SizeY,
    Angle = ParentUITransform.Angle or 0,
    CenterX = ParentNewCenterX,
    CenterY = ParentNewCenterY
  }
end
function CustomUIUtility.MirrorInstances(EditInstances, bHorizontal)
  if not EditInstances or not next(EditInstances) then
    return false
  end
  local InstanceManager = GetInstanceManager()
  if not InstanceManager then
    return false
  end
  local CreateModeCustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
  if not CreateModeCustomUISubsystem then
    return false
  end
  local TreeEditSubsystem = SubsystemMgr:Get("CreativeModeCustomUITreeEditSubsystem")
  if not TreeEditSubsystem then
    return false
  end
  local MirrorKey = bHorizontal and "CustomUIBase.MirrorH" or "CustomUIBase.MirrorV"
  local TableUtil = require("common.table_util")
  local SelectNum = TableUtil.CountTable(EditInstances)
  if 1 < SelectNum then
    local ChangeDataList = {}
    local OperateUITransform = CreateModeCustomUISubsystem:GetOperateUITransform()
    local PropertyChangeFunc = function(InstanceID, EditInstance, InputChangeDataList)
      local UITransform = EditInstance.UITransform
      local NewCenterX = UITransform.TranslationX
      local NewCenterY = UITransform.TranslationY
      local NewAngle
      if bHorizontal then
        NewCenterX = OperateUITransform.TranslationX * 2 - UITransform.TranslationX
        NewAngle = -UITransform.Angle
      else
        NewCenterY = OperateUITransform.TranslationY * 2 - UITransform.TranslationY
        NewAngle = 360 - UITransform.Angle
      end
      _InsertMirrorAdaptationChangeData(InstanceID, NewCenterX, NewCenterY, NewAngle, UITransform, InputChangeDataList)
      _InsertMirrorFlagChangeData(InstanceManager, InstanceID, MirrorKey, InputChangeDataList)
    end
    for InstanceID, EditInstance in pairs(EditInstances) do
      if TreeEditSubsystem:HasChildren(InstanceID) then
        CreateModeCustomUISubsystem:AddChildUIToChangeDataList(InstanceID, ChangeDataList, PropertyChangeFunc)
      else
        PropertyChangeFunc(InstanceID, EditInstance, ChangeDataList)
      end
    end
    if next(ChangeDataList) then
      CreateModeCustomUISubsystem:MultiSetPropertyValue(ChangeDataList)
      return true
    end
    return false
  end
  local InstanceID = next(EditInstances)
  if not InstanceID then
    return false
  end
  if TreeEditSubsystem:HasChildren(InstanceID) then
    local Root    local ChangeDataList = {}
    local PropertyChangeFunc = function(InputInstanceID, EditInstance, InputChangeDataList)
      if InputInstanceID == RootInstanceID then
        _InsertMirrorFlagChangeData(InstanceManager, InputInstanceID, MirrorKey, InputChangeDataList)
        return
      end
      local UITransform = EditInstance.UITransform
      local ParentBounds = CustomUIAdaptationCalculator.GetParentBounds(InputInstanceID, true)
      local ParentCenterX = ParentBounds.CenterX or ParentBounds.X + ParentBounds.Width / 2
      local ParentCenterY = ParentBounds.CenterY or ParentBounds.Y + ParentBounds.Height / 2
      local ParentAngle = ParentBounds.Angle or 0
      local NewCenterX, NewCenterY, NewAngle = _MirrorPositionInParentSpace(UITransform.TranslationX, UITransform.TranslationY, UITransform.Angle, ParentCenterX, ParentCenterY, ParentAngle, bHorizontal)
      local FinalX, FinalY = _UnrotateFromParent(NewCenterX, NewCenterY, ParentBounds)
      _InsertMirrorAdaptationChangeData(InputInstanceID, FinalX, FinalY, NewAngle, UITransform, InputChangeDataList)
      _InsertMirrorFlagChangeData(InstanceManager, InputInstanceID, MirrorKey, InputChangeDataList)
    end
    CreateModeCustomUISubsystem:AddChildUIToChangeDataList(InstanceID, ChangeDataList, PropertyChangeFunc)
    if next(ChangeDataList) then
      CreateModeCustomUISubsystem:MultiSetPropertyValue(ChangeDataList)
      return true
    end
    return false
  end
  local MirrorValue = InstanceManager:GetObjectValue(InstanceID, MirrorKey)
  CreateModeCustomUISubsystem:SetPropertyValue(MirrorKey, not MirrorValue, InstanceID)
  return true
end
local _OpenBindLogicDeviceOrTextUI = function(Value, Config, BindingType, OnValueChangeFunc)
  local CurVal = Value or {}
  local ExtraUIConfig = Config and Config.ExtraUIConfig or nil
  local DeviceDescriptionText, DeviceTittleText, DeviceConditionText, DeviceTriggerText, EventTittleText, EventDescriptionText
  if ExtraUIConfig then
    if ExtraUIConfig.DeviceTittleText then
      DeviceTittleText = ExtraUIConfig.DeviceTittleText
    end
    if ExtraUIConfig.DeviceDescriptionText then
      DeviceDescriptionText = ExtraUIConfig.DeviceDescriptionText
    end
    if ExtraUIConfig.DeviceConditionText then
      DeviceConditionText = ExtraUIConfig.DeviceConditionText
    end
    if ExtraUIConfig.DeviceTriggerText then
      DeviceTriggerText = ExtraUIConfig.DeviceTriggerText
    end
    if ExtraUIConfig.EventTittleText then
      EventTittleText = ExtraUIConfig.EventTittleText
    end
    if ExtraUIConfig.EventDescriptionText then
      EventDescriptionText = ExtraUIConfig.EventDescriptionText
    end
  end
  local BindTypeInfo = {
    BindingType = BindingType,
    DeviceTittleText = DeviceTittleText,
    DeviceDescriptionText = DeviceDescriptionText,
    DeviceConditionText = DeviceConditionText,
    DeviceTriggerText = DeviceTriggerText,
    EventTittleText = EventTittleText,
    EventDescriptionText = EventDescriptionText,
    InstanceID = CurVal.InstanceID or "",
    FunctionIndex = BindingType == 1 and (CurVal.FunctionIndex or 0) or 0,
    SignalName = CurVal.SignalName or "",
    EventName = BindingType == 0 and (CurVal.EventName or "") or nil,
    BranchKey = BindingType == 0 and (CurVal.BranchKey or 0) or nil
  }
  return UIManager.ShowUI(UIManager.UI_Config_InGame.Common_Param_Item_BindFunction_BindLogicDeviceOrTextUICtrl, BindTypeInfo, Config, OnValueChangeFunc)
end
function CustomUIUtility.OpenBindEventSelector(Value, Config, OnValueChangeFunc)
  return _OpenBindLogicDeviceOrTextUI(Value, Config, 0, OnValueChangeFunc)
end
function CustomUIUtility.OpenBindFunctionSelector(Value, Config, OnValueChangeFunc)
  return _OpenBindLogicDeviceOrTextUI(Value, Config, 1, OnValueChangeFunc)
end
CustomUIUtility.E_NudgeDir = {
  Left = 1,
  Up = 2,
  Right = 3,
  Down = 4
}
function CustomUIUtility.ApplyNudgeDataChange(CurEditInstances)
  if not CurEditInstances or not next(CurEditInstances) then
    return
  end
  local CreateModeCustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
  if not CreateModeCustomUISubsystem then
    return
  end
  local InstanceManager = GetInstanceManager()
  local CustomUIAdaptationCalculator = require("GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CustomUIAdaptationCalculator")
  local ChangeDataList = {}
  local PropertyChangeFunc = function(InstanceID, EditInstance, InputChangeDataList)
    local UITransform = EditInstance.UITransform
    local Width = UITransform.SizeX or 0
    local Height = UITransform.SizeY or 0
    local ParentBounds = CustomUIAdaptationCalculator.GetParentBounds(InstanceID, true)
    local CurInstanceData = InstanceManager:GetInstance(InstanceID)
    local CurAdaptationInfo = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.AdaptationInfo", CurInstanceData, nil)
    local NewAdaptationInfo = CustomUIAdaptationCalculator.ReverseCalculate(UITransform.TranslationX, UITransform.TranslationY, Width, Height, CurAdaptationInfo, ParentBounds)
    table.insert(InputChangeDataList, {
      InstanceID = InstanceID,
      Key = "CustomUIBase.AdaptationInfo",
      Value = NewAdaptationInfo
    })
    local ParentAccumulatedAngle = ParentBounds.Angle or 0
    local RelativeAngle = UITransform.Angle - ParentAccumulatedAngle
    table.insert(InputChangeDataList, {
      InstanceID = InstanceID,
      Key = "Transform.Location",
      Value = {
        X = 0,
        Y = 0,
        Z = RelativeAngle
      }
    })
  end
  local TreeEditSubsystem = SubsystemMgr:Get("CreativeModeCustomUITreeEditSubsystem")
  for InstanceID, EditInstance in pairs(CurEditInstances) do
    local bLock
    if TreeEditSubsystem and TreeEditSubsystem.IsWidgetEditModeLocked then
      bLock = TreeEditSubsystem:IsWidgetEditModeLocked(InstanceID)
    else
      bLock = InstanceManager:GetInstanceValue(InstanceID, "CustomUIBase.EditModeLocked")
    end
    if not bLock then
      if TreeEditSubsystem and TreeEditSubsystem:HasChildren(InstanceID) then
        CreateModeCustomUISubsystem:AddChildUIToChangeDataList(InstanceID, ChangeDataList, PropertyChangeFunc)
      else
        PropertyChangeFunc(InstanceID, EditInstance, ChangeDataList)
      end
    end
  end
  CreateModeCustomUISubsystem:MultiSetPropertyValue(ChangeDataList)
end
function CustomUIUtility.NudgeInstancePosition(OperateDir, bSkipDataChange)
  local CreateModeCustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
  if not CreateModeCustomUISubsystem then
    return
  end
  local CurEditInstances = CreateModeCustomUISubsystem:GetCurEditInstances()
  if not CurEditInstances or not next(CurEditInstances) then
    return
  end
  local OperateUITransform = CreateModeCustomUISubsystem:GetOperateUITransform()
  if not OperateUITransform then
    return
  end
  local LocationX = OperateUITransform.TranslationX
  local LocationY = OperateUITransform.TranslationY
  local UserScaledDist = 1 * CreateModeCustomUISubsystem.UserScale
  if OperateDir == CustomUIUtility.E_NudgeDir.Left then
    LocationX = LocationX - UserScaledDist
  elseif OperateDir == CustomUIUtility.E_NudgeDir.Right then
    LocationX = LocationX + UserScaledDist
  elseif OperateDir == CustomUIUtility.E_NudgeDir.Up then
    LocationY = LocationY - UserScaledDist
  elseif OperateDir == CustomUIUtility.E_NudgeDir.Down then
    LocationY = LocationY + UserScaledDist
  else
    return
  end
  EventSystem:postEvent(EVENTTYPE_IMAGE_GESTURE_OPERATE, EVENTID_IMAGE_GESTURE_OPERATE_MOVE, LocationX, LocationY)
  if OperateDir == CustomUIUtility.E_NudgeDir.Left or OperateDir == CustomUIUtility.E_NudgeDir.Right then
    EventSystem:postEvent(EVENTTYPE_CREATIVE, EVENTID_CUSTOMUI_PROPERTY_CHANGE, "Transform.Location.X", LocationX)
  elseif OperateDir == CustomUIUtility.E_NudgeDir.Up or OperateDir == CustomUIUtility.E_NudgeDir.Down then
    EventSystem:postEvent(EVENTTYPE_CREATIVE, EVENTID_CUSTOMUI_PROPERTY_CHANGE, "Transform.Location.Y", LocationY)
  end
  if not bSkipDataChange then
    CustomUIUtility.ApplyNudgeDataChange(CurEditInstances)
  end
end
CustomUIUtility._NudgeRepeatData = nil
function CustomUIUtility.StartNudgeRepeat(OperateDir)
  CustomUIUtility.StopNudgeRepeat()
  CustomUIUtility.NudgeInstancePosition(OperateDir)
  CustomUIUtility._NudgeRepeatData = {OperateDir = OperateDir, bLongPress = false}
  CustomUIUtility._NudgeRepeatData.DelayTimer = Game:SetTimer(0.5, false, function()
    if not CustomUIUtility._NudgeRepeatData then
      return
    end
    CustomUIUtility._NudgeRepeatData.bLongPress = true
    CustomUIUtility._NudgeRepeatData.LoopTimer = Game:SetTimer(0.1, true, function()
      if not CustomUIUtility._NudgeRepeatData then
        return
      end
      CustomUIUtility.NudgeInstancePosition(CustomUIUtility._NudgeRepeatData.OperateDir, true)
    end)
  end)
end
function CustomUIUtility.StopNudgeRepeat()
  local Data = CustomUIUtility._NudgeRepeatData
  if not Data then
    return
  end
  if Data.DelayTimer then
    Game:ClearTimer(Data.DelayTimer)
    Data.DelayTimer = nil
  end
  if Data.LoopTimer then
    Game:ClearTimer(Data.LoopTimer)
    Data.LoopTimer = nil
  end
  if Data.bLongPress then
    local CreateModeCustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
    if CreateModeCustomUISubsystem then
      local CurEditInstances = CreateModeCustomUISubsystem:GetCurEditInstances()
      CustomUIUtility.ApplyNudgeDataChange(CurEditInstances or {})
    end
  end
  CustomUIUtility._NudgeRepeatData = nil
end
return CustomUIUtility