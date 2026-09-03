local CustomUIAdaptationCalculator = {}
local ANCHOR_NAMES = {
  "LeftAnchor",
  "RightAnchor",
  "TopAnchor",
  "BottomAnchor",
  "PositionX",
  "PositionY"
}
local DEFAULT_DESIGN_CANVAS_SIZE = {Width = 916, Height = 515}
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local SIZE_MIN = 5
local SIZE_MAX = 1024
do
  local OkRequire, CustomUIDefine = pcall(require, "GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CustomUIDefine")
  if OkRequire and type(CustomUIDefine) == "table" then
    SIZE_MIN = CustomUIDefine.C_SizeMin or SIZE_MIN
    SIZE_MAX = CustomUIDefine.C_SizeMax or SIZE_MAX
  end
end
local ClampSize = function(Size)
  if Size < SIZE_MIN then
    return SIZE_MIN
  end
  return Size
end
local ResolveAnchorValue = function(AnchorValue, ValueType, ParentDimension)
  if ValueType == 1 then
    return ParentDimension * AnchorValue / 10000
  end
  return AnchorValue
end
local ReverseResolveAnchorValue = function(PixelValue, ValueType, ParentDimension)
  if ValueType == 1 then
    if ParentDimension == 0 then
      return 0
    end
    return math_floor(PixelValue / ParentDimension * 10000 + 0.5)
  end
  return math_floor(PixelValue + 0.5)
end
function CustomUIAdaptationCalculator.ConvertAnchorValue(AnchorValue, OldValueType, NewValueType, ParentDimension)
  if OldValueType == NewValueType then
    return AnchorValue
  end
  local PixelValue = ResolveAnchorValue(AnchorValue, OldValueType, ParentDimension)
  return ReverseResolveAnchorValue(PixelValue, NewValueType, ParentDimension)
end
local ReadAnchorV = function(AdaptationInfo, AnchorName)
  local Anchor = AdaptationInfo and AdaptationInfo[AnchorName]
  if not Anchor then
    return false, 0, 0
  end
  return Anchor.bEnable or false, Anchor.Value or 0, Anchor.ValueType or 0
end
local CopyAnchor = function(AdaptationInfo, AnchorName)
  local bEnable, Value, ValueType = ReadAnchorV(AdaptationInfo, AnchorName)
  return {
    bEnable = bEnable,
    Value = math_floor(Value + 0.5),
      }
end
local GetDesignCanvasSize = function()
  local GameParameterManager = GetGameParameterManager()
  if GameParameterManager then
    local Param = GameParameterManager:GetGameParameter("CustomUICanvasType")
    if Param and Param.Value then
      local CustomUIDefine = require("GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CustomUIDefine")
      local CanvasSize = CustomUIDefine.CanvasSize[Param.Value]
      if CanvasSize then
        return CanvasSize
      end
    end
  end
  return DEFAULT_DESIGN_CANVAS_SIZE
end
local ForwardCalculateValues = function(AdaptationInfo, ParentBounds, OriginalWidth, OriginalHeight)
  local bLeftEnabled, LeftValue, LeftType = ReadAnchorV(AdaptationInfo, "LeftAnchor")
  local bRightEnabled, RightValue, RightType = ReadAnchorV(AdaptationInfo, "RightAnchor")
  local bTopEnabled, TopValue, TopType = ReadAnchorV(AdaptationInfo, "TopAnchor")
  local bBottomEnabled, BottomValue, BottomType = ReadAnchorV(AdaptationInfo, "BottomAnchor")
  local bPosXEnabled, PosXValue, PosXType = ReadAnchorV(AdaptationInfo, "PositionX")
  local bPosYEnabled, PosYValue, PosYType = ReadAnchorV(AdaptationInfo, "PositionY")
  local ParentX = ParentBounds.X or 0
  local ParentY = ParentBounds.Y or 0
  local ParentW = ParentBounds.Width or 0
  local ParentH = ParentBounds.Height or 0
  local ResultCenterX = 0
  local ResultCenterY = 0
  local ResultWidth = OriginalWidth or 0
  local ResultHeight = OriginalHeight or 0
  local bWidthOverridden = false
  local bHeightOverridden = false
  if bLeftEnabled and bRightEnabled then
    local LeftEdge = ParentX + ResolveAnchorValue(LeftValue, LeftType, ParentW)
    local RightEdge = ParentX + ParentW - ResolveAnchorValue(RightValue, RightType, ParentW)
    ResultWidth = RightEdge - LeftEdge
    ResultCenterX = (LeftEdge + RightEdge) / 2
    bWidthOverridden = true
  elseif bLeftEnabled then
    local LeftEdge = ParentX + ResolveAnchorValue(LeftValue, LeftType, ParentW)
    ResultCenterX = LeftEdge + ResultWidth / 2
  elseif bRightEnabled then
    local RightEdge = ParentX + ParentW - ResolveAnchorValue(RightValue, RightType, ParentW)
    ResultCenterX = RightEdge - ResultWidth / 2
  elseif bPosXEnabled then
    ResultCenterX = ParentX + ResolveAnchorValue(PosXValue, PosXType, ParentW)
  end
  if bTopEnabled and bBottomEnabled then
    local TopEdge = ParentY + ResolveAnchorValue(TopValue, TopType, ParentH)
    local BottomEdge = ParentY + ParentH - ResolveAnchorValue(BottomValue, BottomType, ParentH)
    ResultHeight = BottomEdge - TopEdge
    ResultCenterY = (TopEdge + BottomEdge) / 2
    bHeightOverridden = true
  elseif bTopEnabled then
    local TopEdge = ParentY + ResolveAnchorValue(TopValue, TopType, ParentH)
    ResultCenterY = TopEdge + ResultHeight / 2
  elseif bBottomEnabled then
    local BottomEdge = ParentY + ParentH - ResolveAnchorValue(BottomValue, BottomType, ParentH)
    ResultCenterY = BottomEdge - ResultHeight / 2
  elseif bPosYEnabled then
    ResultCenterY = ParentY + ResolveAnchorValue(PosYValue, PosYType, ParentH)
  end
  ResultWidth = ClampSize(ResultWidth)
  ResultHeight = ClampSize(ResultHeight)
  return ResultCenterX, ResultCenterY, ResultWidth, ResultHeight, bWidthOverridden, bHeightOverridden
end
CustomUIAdaptationCalculator._
function CustomUIAdaptationCalculator.ForwardCalculate(AdaptationInfo, ParentBounds, OriginalWidth, OriginalHeight)
  local CenterX, CenterY, Width, Height, bWidthOverridden, bHeightOverridden = ForwardCalculateValues(AdaptationInfo, ParentBounds, OriginalWidth, OriginalHeight)
  return {
    CenterX = CenterX,
    CenterY = CenterY,
    Width = Width,
    Height = Height,
    bWidthOverridden = bWidthOverridden,
      }
end
local ReverseCalculateCore = function(TargetInfo, CurrentCenterX, CurrentCenterY, CurrentWidth, CurrentHeight, ParentX, ParentY, ParentW, ParentH)
  local LeftAnchor = TargetInfo.LeftAnchor
  local RightAnchor = TargetInfo.RightAnchor
  local bLeftEnabled = LeftAnchor and LeftAnchor.bEnable
  local bRightEnabled = RightAnchor and RightAnchor.bEnable
  if bLeftEnabled then
    local LeftEdge = CurrentCenterX - CurrentWidth / 2
    LeftAnchor.Value = ReverseResolveAnchorValue(LeftEdge - ParentX, LeftAnchor.ValueType, ParentW)
  end
  if bRightEnabled then
    local RightEdge = CurrentCenterX + CurrentWidth / 2
    RightAnchor.Value = ReverseResolveAnchorValue(ParentX + ParentW - RightEdge, RightAnchor.ValueType, ParentW)
  end
  local PositionX = TargetInfo.PositionX
  if PositionX and PositionX.bEnable and not bLeftEnabled and not bRightEnabled then
    PositionX.Value = ReverseResolveAnchorValue(CurrentCenterX - ParentX, PositionX.ValueType, ParentW)
  end
  local TopAnchor = TargetInfo.TopAnchor
  local BottomAnchor = TargetInfo.BottomAnchor
  local bTopEnabled = TopAnchor and TopAnchor.bEnable
  local bBottomEnabled = BottomAnchor and BottomAnchor.bEnable
  if bTopEnabled then
    local TopEdge = CurrentCenterY - CurrentHeight / 2
    TopAnchor.Value = ReverseResolveAnchorValue(TopEdge - ParentY, TopAnchor.ValueType, ParentH)
  end
  if bBottomEnabled then
    local BottomEdge = CurrentCenterY + CurrentHeight / 2
    BottomAnchor.Value = ReverseResolveAnchorValue(ParentY + ParentH - BottomEdge, BottomAnchor.ValueType, ParentH)
  end
  local PositionY = TargetInfo.PositionY
  if PositionY and PositionY.bEnable and not bTopEnabled and not bBottomEnabled then
    PositionY.Value = ReverseResolveAnchorValue(CurrentCenterY - ParentY, PositionY.ValueType, ParentH)
  end
end
function CustomUIAdaptationCalculator.ReverseCalculate(CurrentCenterX, CurrentCenterY, CurrentWidth, CurrentHeight, AdaptationInfo, ParentBounds)
  local ParentX = ParentBounds.X or 0
  local ParentY = ParentBounds.Y or 0
  local ParentW = ParentBounds.Width or 0
  local ParentH = ParentBounds.Height or 0
  local NewInfo = {
    LeftAnchor = CopyAnchor(AdaptationInfo, "LeftAnchor"),
    RightAnchor = CopyAnchor(AdaptationInfo, "RightAnchor"),
    TopAnchor = CopyAnchor(AdaptationInfo, "TopAnchor"),
    BottomAnchor = CopyAnchor(AdaptationInfo, "BottomAnchor"),
    PositionX = CopyAnchor(AdaptationInfo, "PositionX"),
    PositionY = CopyAnchor(AdaptationInfo, "PositionY")
  }
  ReverseCalculateCore(NewInfo, CurrentCenterX, CurrentCenterY, CurrentWidth, CurrentHeight, ParentX, ParentY, ParentW, ParentH)
  return NewInfo
end
function CustomUIAdaptationCalculator.ReverseCalculateDS(CurrentCenterX, CurrentCenterY, CurrentWidth, CurrentHeight, AdaptationInfo, ParentX, ParentY, ParentW, ParentH)
  ReverseCalculateCore(AdaptationInfo, CurrentCenterX, CurrentCenterY, CurrentWidth, CurrentHeight, ParentX or 0, ParentY or 0, ParentW or 0, ParentH or 0)
  return AdaptationInfo
end
function CustomUIAdaptationCalculator.GetScreenAdaptationScale(GameCanvasBounds)
  local GameParameterManager = GetGameParameterManager()
  if not GameParameterManager then
    return 1, 1
  end
  local Param = GameParameterManager:GetGameParameter("EnableCustomUIScreenAdaption")
  if not Param or not Param.Value then
    return 1, 1
  end
  GameCanvasBounds = GameCanvasBounds or CustomUIAdaptationCalculator._GetCanvasBounds(false)
  local DesignCanvas = GetDesignCanvasSize()
  local ScaleX = DesignCanvas.Width > 0 and GameCanvasBounds.Width / DesignCanvas.Width or 1
  local ScaleY = 0 < DesignCanvas.Height and GameCanvasBounds.Height / DesignCanvas.Height or 1
  return ScaleX, ScaleY
end
function CustomUIAdaptationCalculator.GetParentBounds(InstanceID, bIsEditorType)
  local TreeSubsystem
  if bIsEditorType then
    TreeSubsystem = SubsystemMgr:Get("CreativeModeCustomUITreeEditSubsystem")
  else
    TreeSubsystem = SubsystemMgr:Get("CreativeModeCustomUITreeSubsystem")
  end
  if not TreeSubsystem then
    return CustomUIAdaptationCalculator._GetCanvasBounds(bIsEditorType)
  end
  local ParentInstanceID = TreeSubsystem:GetParentInstanceID(InstanceID)
  if not ParentInstanceID then
    return CustomUIAdaptationCalculator._GetCanvasBounds(bIsEditorType)
  end
  if TreeSubsystem.IsCanvasNode and TreeSubsystem:IsCanvasNode(ParentInstanceID) then
    return CustomUIAdaptationCalculator._GetCanvasBounds(bIsEditorType)
  end
  if bIsEditorType then
    return CustomUIAdaptationCalculator._GetParentBoundsFromUITransform(ParentInstanceID)
  else
    return CustomUIAdaptationCalculator._GetParentBoundsFromInstance(ParentInstanceID)
  end
end
local _RotateAabb = function(Width, Height, CenterX, CenterY, Angle)
  local HalfWidth = Width * 0.5
  local HalfHeight = Height * 0.5
  local Rotate = function(LocalX, LocalY)
    if Angle == 0 then
      return LocalX + CenterX, LocalY + CenterY
    end
    local Rad = math.rad(Angle)
    local S = math.sin(Rad)
    local C = math.cos(Rad)
    return LocalX * C - LocalY * S + CenterX, LocalX * S + LocalY * C + CenterY
  end
  local TopLeftX, TopLeftY = Rotate(-HalfWidth, -HalfHeight)
  local TopRightX, TopRightY = Rotate(HalfWidth, -HalfHeight)
  local BottomLeftX, BottomLeftY = Rotate(-HalfWidth, HalfHeight)
  local BottomRightX, BottomRightY = Rotate(HalfWidth, HalfHeight)
  local Min_X = math_min(TopLeftX, TopRightX, BottomLeftX, BottomRightX)
  local Min_Y = math_min(TopLeftY, TopRightY, BottomLeftY, BottomRightY)
  local Max_X = math_max(TopLeftX, TopRightX, BottomLeftX, BottomRightX)
  local Max_Y = math_max(TopLeftY, TopRightY, BottomLeftY, BottomRightY)
  return Min_X, Min_Y, Max_X, Max_Y
end
function CustomUIAdaptationCalculator.CalculateWidgetGroupBoundingBox(InstanceList, CanvasBounds)
  if not InstanceList or not next(InstanceList) then
    return 0, 0, 0, 0
  end
  CanvasBounds = CanvasBounds or CustomUIAdaptationCalculator._GetCanvasBounds(true)
  local InstanceManager = GetInstanceManager()
  if not InstanceManager then
    return 0, 0, 0, 0
  end
  local ChildSet = {}
  for _, Instance in pairs(InstanceList) do
    local Children = InstanceManager:GetObjectValue(nil, "ObjectGroup.Children", Instance) or nil
    if Children then
      for i = 1, #Children do
        ChildSet[Children[i]] = true
      end
    end
  end
  local MinX, MinY = 10240, 10240
  local MaxX, MaxY = -10240, -10240
  local bAnyHit = false
  for InstanceID, Instance in pairs(InstanceList) do
    if not ChildSet[InstanceID] and Instance and Instance.CustomUIBase then
      local Width, Height = Instance.CustomUIBase.Width, Instance.CustomUIBase.Height
      local AdaptationInfo = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.AdaptationInfo", Instance)
      local Angle = Instance.Transform and Instance.Transform.Location and Instance.Transform.Location.Z or 0
      local Result = CustomUIAdaptationCalculator.ForwardCalculate(AdaptationInfo, CanvasBounds, Width, Height)
      local CenterX, CenterY = Result.CenterX, Result.CenterY
      local ActualWidth, ActualHeight = Result.Width, Result.Height
      local BoxMinX, BoxMinY, BoxMaxX, BoxMaxY = _RotateAabb(ActualWidth, ActualHeight, CenterX, CenterY, Angle)
      MinX = math_min(MinX, BoxMinX)
      MinY = math_min(MinY, BoxMinY)
      MaxX = math_max(MaxX, BoxMaxX)
      MaxY = math_max(MaxY, BoxMaxY)
      bAnyHit = true
    end
  end
  if not bAnyHit then
    return 0, 0, 0, 0
  end
  return MinX, MinY, MaxX, MaxY
end
function CustomUIAdaptationCalculator.GetCanvasBounds(bIsEditorType)
  return CustomUIAdaptationCalculator._GetCanvasBounds(bIsEditorType)
end
function CustomUIAdaptationCalculator._GetCanvasBounds(bIsEditorType)
  if bIsEditorType then
    local CreateModeCustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
    if CreateModeCustomUISubsystem then
      local CanvasSize = CreateModeCustomUISubsystem:GetCanvasSize()
      if CanvasSize then
        return {
          X = 0,
          Y = 0,
          Width = CanvasSize.Width,
          Height = CanvasSize.Height
        }
      end
    end
    return {
      X = 0,
      Y = 0,
      Width = 916,
      Height = 515
    }
  else
    local UIUtil = require("client.common.ui_util")
    local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
    if CreativeModeBlueprintLibrary.IsOfflineBuild() then
      local Parent = UIManager.GetUI(UIManager.UI_Config_InGame.CustomUI_MainPanel_Offline)
      if Parent then
        local LocalSize = UIUtil:GetViewportSize()
        return {
          X = 0,
          Y = 0,
          Width = LocalSize.X,
          Height = LocalSize.Y
        }
      end
    else
      local MainControlPanelTochButton = UIUtil.GetWidgetByName("ingame", "MainControlPanelTochButton")
      if MainControlPanelTochButton and MainControlPanelTochButton.CreativeCustomUILayer then
        local LocalSize = UIUtil.GetLocalSize(MainControlPanelTochButton.CreativeCustomUILayer)
        return {
          X = 0,
          Y = 0,
          Width = LocalSize.X,
          Height = LocalSize.Y
        }
      end
    end
    return {
      X = 0,
      Y = 0,
      Width = 916,
      Height = 515
    }
  end
end
function CustomUIAdaptationCalculator._GetParentBoundsFromUITransform(ParentInstanceID)
  local CreateModeCustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
  if CreateModeCustomUISubsystem and CreateModeCustomUISubsystem.Instances then
    local ParentInstance = CreateModeCustomUISubsystem.Instances[ParentInstanceID]
    if ParentInstance and ParentInstance.UITransform then
      local UITransform = ParentInstance.UITransform
      local CenterX = UITransform.TranslationX
      local CenterY = UITransform.TranslationY
      local SizeX = UITransform.SizeX
      local SizeY = UITransform.SizeY
      return {
        X = CenterX - SizeX / 2,
        Y = CenterY - SizeY / 2,
        Width = SizeX,
        Height = SizeY,
        Angle = UITransform.Angle or 0,
        CenterX = CenterX,
              }
    end
  end
  return CustomUIAdaptationCalculator._GetParentBoundsFromInstance(ParentInstanceID, true)
end
local GetClientCustomUIData = function()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if PlayerController and slua.isValid(PlayerController) then
    local DataComp = PlayerController.BP_CreativeCustomUIDataComponent
    if DataComp and slua.isValid(DataComp) then
      return DataComp.CustomUIData
    end
  end
  return nil
end
function CustomUIAdaptationCalculator._GetParentBoundsFromInstance(ParentInstanceID, bIsEditorType)
  if bIsEditorType == nil then
    bIsEditorType = false
  end
  local ParentWidth, ParentHeight, ParentAdaptation, ParentAngle
  if bIsEditorType then
    local InstanceManager = GetInstanceManager()
    if not InstanceManager then
      return {
        X = 0,
        Y = 0,
        Width = 0,
        Height = 0,
        Angle = 0,
        CenterX = 0,
        CenterY = 0
      }
    end
    local ParentInstance = InstanceManager:GetInstance(ParentInstanceID)
    if not ParentInstance then
      return {
        X = 0,
        Y = 0,
        Width = 0,
        Height = 0,
        Angle = 0,
        CenterX = 0,
        CenterY = 0
      }
    end
    ParentWidth = InstanceManager:GetObjectValue(ParentInstanceID, "CustomUIBase.Width", ParentInstance, nil) or 0
    ParentHeight = InstanceManager:GetObjectValue(ParentInstanceID, "CustomUIBase.Height", ParentInstance, nil) or 0
    ParentAdaptation = InstanceManager:GetObjectValue(ParentInstanceID, "CustomUIBase.AdaptationInfo", ParentInstance, nil)
    local ParentLocation = InstanceManager:GetObjectValue(ParentInstanceID, "Transform.Location", ParentInstance, nil)
    ParentAngle = ParentLocation and ParentLocation.Z or 0
  else
    local CustomUIData = GetClientCustomUIData()
    if not CustomUIData then
      return {
        X = 0,
        Y = 0,
        Width = 0,
        Height = 0,
        Angle = 0,
        CenterX = 0,
        CenterY = 0
      }
    end
    local ParentInstance = CustomUIData[ParentInstanceID]
    if not ParentInstance then
      return {
        X = 0,
        Y = 0,
        Width = 0,
        Height = 0,
        Angle = 0,
        CenterX = 0,
        CenterY = 0
      }
    end
    if not ParentInstance.CustomUIBase then
      return {
        X = 0,
        Y = 0,
        Width = 0,
        Height = 0,
        Angle = 0,
        CenterX = 0,
        CenterY = 0
      }
    end
    local InstanceManager = GetInstanceManager()
    if not InstanceManager then
      return {
        X = 0,
        Y = 0,
        Width = 0,
        Height = 0,
        Angle = 0,
        CenterX = 0,
        CenterY = 0
      }
    end
    ParentWidth = InstanceManager:GetObjectValue(ParentInstanceID, "CustomUIBase.Width", ParentInstance, nil) or 0
    ParentHeight = InstanceManager:GetObjectValue(ParentInstanceID, "CustomUIBase.Height", ParentInstance, nil) or 0
    ParentAdaptation = InstanceManager:GetObjectValue(ParentInstanceID, "CustomUIBase.AdaptationInfo", ParentInstance, nil)
    local ParentLocation = InstanceManager:GetObjectValue(ParentInstanceID, "Transform.Location", ParentInstance, nil)
    ParentAngle = ParentLocation and ParentLocation.Z or 0
  end
  local GrandParentBounds = CustomUIAdaptationCalculator.GetParentBounds(ParentInstanceID, bIsEditorType)
  if not bIsEditorType then
    local ScaleX, ScaleY = CustomUIAdaptationCalculator.GetScreenAdaptationScale()
    ParentWidth = ParentWidth * ScaleX
    ParentHeight = ParentHeight * ScaleY
  end
  local ParentCenterX, ParentCenterY, ParentResultW, ParentResultH = ForwardCalculateValues(ParentAdaptation, GrandParentBounds, ParentWidth, ParentHeight)
  local GrandParentAccAngle = GrandParentBounds.Angle or 0
  local ParentAccumulatedAngle = GrandParentAccAngle + (ParentAngle or 0)
  return {
    X = ParentCenterX - ParentResultW / 2,
    Y = ParentCenterY - ParentResultH / 2,
    Width = ParentResultW,
    Height = ParentResultH,
    Angle = ParentAccumulatedAngle,
    CenterX = ParentCenterX,
    CenterY = ParentCenterY
  }
end
function CustomUIAdaptationCalculator.BuildDefaultAdaptationInfo(CenterX, CenterY, ParentBounds)
  local ParentX = ParentBounds.X or 0
  local ParentY = ParentBounds.Y or 0
  local ParentW = ParentBounds.Width or 0
  local ParentH = ParentBounds.Height or 0
  local PosXPixel = CenterX - ParentX
  local PosYPixel = CenterY - ParentY
  local PosXValue = 0 < ParentW and math_floor(PosXPixel / ParentW * 10000 + 0.5) or 0
  local PosYValue = 0 < ParentH and math_floor(PosYPixel / ParentH * 10000 + 0.5) or 0
  return {
    LeftAnchor = {
      bEnable = false,
      Value = 0,
      ValueType = 0
    },
    RightAnchor = {
      bEnable = false,
      Value = 0,
      ValueType = 0
    },
    TopAnchor = {
      bEnable = false,
      Value = 0,
      ValueType = 0
    },
    BottomAnchor = {
      bEnable = false,
      Value = 0,
      ValueType = 0
    },
    PositionX = {
      bEnable = true,
      Value = PosXValue,
      ValueType = 1
    },
    PositionY = {
      bEnable = true,
      Value = PosYValue,
      ValueType = 1
    }
  }
end
function CustomUIAdaptationCalculator.RecalculateForNewParent(ChildInstanceID, OldParentBounds, NewParentBounds, InstanceMgr)
  if not InstanceMgr then
    return nil
  end
  local ChildInstance = InstanceMgr:GetInstance(ChildInstanceID)
  if not ChildInstance then
    return nil
  end
  local ChildWidth = InstanceMgr:GetObjectValue(ChildInstanceID, "CustomUIBase.Width", ChildInstance, nil) or 0
  local ChildHeight = InstanceMgr:GetObjectValue(ChildInstanceID, "CustomUIBase.Height", ChildInstance, nil) or 0
  local ChildAdaptation = InstanceMgr:GetObjectValue(ChildInstanceID, "CustomUIBase.AdaptationInfo", ChildInstance, nil)
  local AbsCenterX, AbsCenterY, AbsWidth, AbsHeight = ForwardCalculateValues(ChildAdaptation, OldParentBounds, ChildWidth, ChildHeight)
  local NewAdaptationInfo = CustomUIAdaptationCalculator.ReverseCalculate(AbsCenterX, AbsCenterY, AbsWidth, AbsHeight, ChildAdaptation, NewParentBounds)
  return NewAdaptationInfo
end
function CustomUIAdaptationCalculator.HasAnyAnchorEnabled(AdaptationInfo)
  if not AdaptationInfo then
    return false
  end
  for i = 1, #ANCHOR_NAMES do
    local Anchor = AdaptationInfo[ANCHOR_NAMES[i]]
    if Anchor and Anchor.bEnable then
      return true
    end
  end
  return false
end
function CustomUIAdaptationCalculator.GetMutualExclusionState(AdaptationInfo)
  local bLeftEnabled = ReadAnchorV(AdaptationInfo, "LeftAnchor")
  local bRightEnabled = ReadAnchorV(AdaptationInfo, "RightAnchor")
  local bTopEnabled = ReadAnchorV(AdaptationInfo, "TopAnchor")
  local bBottomEnabled = ReadAnchorV(AdaptationInfo, "BottomAnchor")
  local bPositionXDisabled = bLeftEnabled or bRightEnabled
  local bPositionYDisabled = bTopEnabled or bBottomEnabled
  local bWidthOverridden = bLeftEnabled and bRightEnabled
  local bHeightOverridden = bTopEnabled and bBottomEnabled
  return bPositionXDisabled, bPositionYDisabled, bWidthOverridden, bHeightOverridden
end
local DeepCopyAdaptationInfo = function(AdaptationInfo)
  if not AdaptationInfo then
    return {}
  end
  local Result = {}
  for i = 1, #ANCHOR_NAMES do
    local Name = ANCHOR_NAMES[i]
    local Src = AdaptationInfo[Name]
    if Src then
      Result[Name] = {
        bEnable = Src.bEnable or false,
        Value = Src.Value or 0,
        ValueType = Src.ValueType or 0
      }
    else
      Result[Name] = {
        bEnable = false,
        Value = 0,
        ValueType = 0
      }
    end
  end
  return Result
end
local ApplyMutualExclusionFlags = function(AdaptationInfo, ChangedAnchorName)
  if not AdaptationInfo.PositionX then
    AdaptationInfo.PositionX = {
      bEnable = false,
      Value = 0,
      ValueType = 0
    }
  end
  if not AdaptationInfo.PositionY then
    AdaptationInfo.PositionY = {
      bEnable = false,
      Value = 0,
      ValueType = 0
    }
  end
  if ChangedAnchorName == "PositionX" and AdaptationInfo.PositionX.bEnable then
    if AdaptationInfo.LeftAnchor then
      AdaptationInfo.LeftAnchor.bEnable = false
    end
    if AdaptationInfo.RightAnchor then
      AdaptationInfo.RightAnchor.bEnable = false
    end
  end
  if ChangedAnchorName == "PositionY" and AdaptationInfo.PositionY.bEnable then
    if AdaptationInfo.TopAnchor then
      AdaptationInfo.TopAnchor.bEnable = false
    end
    if AdaptationInfo.BottomAnchor then
      AdaptationInfo.BottomAnchor.bEnable = false
    end
  end
  local Left = AdaptationInfo.LeftAnchor
  local Right = AdaptationInfo.RightAnchor
  local Top = AdaptationInfo.TopAnchor
  local Bottom = AdaptationInfo.BottomAnchor
  local bLeftEnabled = Left and Left.bEnable or false
  local bRightEnabled = Right and Right.bEnable or false
  local bTopEnabled = Top and Top.bEnable or false
  local bBottomEnabled = Bottom and Bottom.bEnable or false
  if bLeftEnabled or bRightEnabled then
    AdaptationInfo.PositionX.bEnable = false
  else
    AdaptationInfo.PositionX.bEnable = true
  end
  if bTopEnabled or bBottomEnabled then
    AdaptationInfo.PositionY.bEnable = false
  else
    AdaptationInfo.PositionY.bEnable = true
  end
end
function CustomUIAdaptationCalculator.BuildAdaptationChangeData(InstanceID, AnchorName, NewAnchorValue, bIsEditorType)
  local InstanceManager = GetInstanceManager()
  if not InstanceManager then
    return {}
  end
  local OldAdaptationInfo = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.AdaptationInfo")
  if not OldAdaptationInfo then
    return {}
  end
  local OldWidth = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.Width") or 0
  local OldHeight = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.Height") or 0
  local ParentBounds = CustomUIAdaptationCalculator.GetParentBounds(InstanceID, bIsEditorType)
  local OldAnchorEnable = ReadAnchorV(OldAdaptationInfo, AnchorName)
  local bEnableChanged = OldAnchorEnable ~= (NewAnchorValue.bEnable or false)
  local CurrentCenterX, CurrentCenterY, CurrentWidth, CurrentHeight = ForwardCalculateValues(OldAdaptationInfo, ParentBounds, OldWidth, OldHeight)
  local NewAdaptationInfo = DeepCopyAdaptationInfo(OldAdaptationInfo)
  NewAdaptationInfo[AnchorName] = {
    bEnable = NewAnchorValue.bEnable or false,
    Value = NewAnchorValue.Value or 0,
    ValueType = NewAnchorValue.ValueType or 0
  }
  ApplyMutualExclusionFlags(NewAdaptationInfo, AnchorName)
  local ResultInfo
  if bEnableChanged then
    ResultInfo = CustomUIAdaptationCalculator.ReverseCalculate(CurrentCenterX, CurrentCenterY, CurrentWidth, CurrentHeight, NewAdaptationInfo, ParentBounds)
  else
    ResultInfo = NewAdaptationInfo
  end
  local _, _, FinalResultW, FinalResultH = ForwardCalculateValues(ResultInfo, ParentBounds, OldWidth, OldHeight)
  local ChangeDataList = {
    {
      InstanceID = InstanceID,
      Key = "CustomUIBase.AdaptationInfo",
      Value = ResultInfo
    }
  }
  local FinalWidth = math_floor(FinalResultW + 0.5)
  local FinalHeight = math_floor(FinalResultH + 0.5)
  if FinalWidth ~= OldWidth then
    ChangeDataList[#ChangeDataList + 1] = {
      InstanceID = InstanceID,
      Key = "CustomUIBase.Width",
      Value = FinalWidth
    }
  end
  if FinalHeight ~= OldHeight then
    ChangeDataList[#ChangeDataList + 1] = {
      InstanceID = InstanceID,
      Key = "CustomUIBase.Height",
      Value = FinalHeight
    }
  end
  return ChangeDataList
end
function CustomUIAdaptationCalculator.BuildSizeChangeData(InstanceID, SizeField, NewSize, bIsEditorType)
  local InstanceManager = GetInstanceManager()
  if not InstanceManager then
    return nil, true
  end
  local AdaptationInfo = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.AdaptationInfo")
  local OldWidth = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.Width") or 0
  local OldHeight = InstanceManager:GetObjectValue(InstanceID, "CustomUIBase.Height") or 0
  if not AdaptationInfo then
    return {
      {
        InstanceID = InstanceID,
        Key = "CustomUIBase." .. SizeField,
        Value = NewSize
      }
    }, false
  end
  if not CustomUIAdaptationCalculator.HasAnyAnchorEnabled(AdaptationInfo) then
    return {
      {
        InstanceID = InstanceID,
        Key = "CustomUIBase." .. SizeField,
        Value = NewSize
      }
    }, false
  end
  local ParentBounds = CustomUIAdaptationCalculator.GetParentBounds(InstanceID, bIsEditorType)
  local CurrentCenterX, CurrentCenterY = ForwardCalculateValues(AdaptationInfo, ParentBounds, OldWidth, OldHeight)
  local UsedWidth = OldWidth
  local UsedHeight = OldHeight
  if SizeField == "Width" then
    UsedWidth = NewSize
  else
    UsedHeight = NewSize
  end
  local NewAdaptationInfo = CustomUIAdaptationCalculator.ReverseCalculate(CurrentCenterX, CurrentCenterY, UsedWidth, UsedHeight, AdaptationInfo, ParentBounds)
  local ChangeDataList = {
    {
      InstanceID = InstanceID,
      Key = "CustomUIBase." .. SizeField,
      Value = NewSize
    },
    {
      InstanceID = InstanceID,
      Key = "CustomUIBase.AdaptationInfo",
      Value = NewAdaptationInfo
    }
  }
  return ChangeDataList, false
end
local GetDSScreenAdaptationScale = function(GameCanvasSize)
  local GameParameterManager = GetGameParameterManager()
  if not GameParameterManager then
    return 1, 1
  end
  local Param = GameParameterManager:GetGameParameter("EnableCustomUIScreenAdaption")
  if not Param or not Param.Value then
    return 1, 1
  end
  local DesignCanvas = GetDesignCanvasSize()
  local ScaleX = DesignCanvas.Width > 0 and GameCanvasSize.X / DesignCanvas.Width or 1
  local ScaleY = 0 < DesignCanvas.Height and GameCanvasSize.Y / DesignCanvas.Height or 1
  return ScaleX, ScaleY
end
function CustomUIAdaptationCalculator.GetCanvasBoundsForDS(GameCanvasSize)
  return 0, 0, GameCanvasSize.X, GameCanvasSize.Y
end
local function GetParentBoundsForDS_V(InstanceID, GameCanvasSize, CustomUIData, ScaleX, ScaleY)
  local TreeSubsystem = SubsystemMgr:Get("CreativeModeCustomUITreeSubsystem")
  if not TreeSubsystem then
    return 0, 0, GameCanvasSize.X, GameCanvasSize.Y
  end
  local ParentInstanceID = TreeSubsystem:GetParentInstanceID(InstanceID)
  if not ParentInstanceID then
    return 0, 0, GameCanvasSize.X, GameCanvasSize.Y
  end
  local ParentInstance = CustomUIData and CustomUIData[ParentInstanceID]
  if ParentInstance and ParentInstance.UMGCanvasInfo then
    return CustomUIAdaptationCalculator.GetCanvasBoundsForDS(GameCanvasSize)
  end
  if not ParentInstance or not ParentInstance.CustomUIBase then
    return 0, 0, 0, 0
  end
  local ParentWidth = (ParentInstance.CustomUIBase.Width or 0) * ScaleX
  local ParentHeight = (ParentInstance.CustomUIBase.Height or 0) * ScaleY
  local InstanceManager = GetInstanceManager()
  local ParentAdaptation = InstanceManager:GetObjectValue(nil, "CustomUIBase.AdaptationInfo", ParentInstance)
  local GPX, GPY, GPW, GPH = GetParentBoundsForDS_V(ParentInstanceID, GameCanvasSize, CustomUIData, ScaleX, ScaleY)
  local GrandParentBounds = {
    X = GPX,
    Y = GPY,
    Width = GPW,
    Height = GPH
  }
  local ParentCenterX, ParentCenterY, ParentResultW, ParentResultH = ForwardCalculateValues(ParentAdaptation, GrandParentBounds, ParentWidth, ParentHeight)
  return ParentCenterX - ParentResultW / 2, ParentCenterY - ParentResultH / 2, ParentResultW, ParentResultH
end
CustomUIAdaptationCalculator._
function CustomUIAdaptationCalculator.GetParentBoundsForDS(InstanceID, GameCanvasSize, CustomUIData)
  local ScaleX, ScaleY = GetDSScreenAdaptationScale(GameCanvasSize)
  return GetParentBoundsForDS_V(InstanceID, GameCanvasSize, CustomUIData, ScaleX, ScaleY)
end
function CustomUIAdaptationCalculator.CalculateAdaptationFromScreenPercent(InstanceID, ScreenPercentX, ScreenPercentY, GameCanvasSize, CustomUIData)
  local InstanceData = CustomUIData and CustomUIData[InstanceID]
  if not InstanceData or not InstanceData.CustomUIBase then
    return nil
  end
  local Width = InstanceData.CustomUIBase.Width or 0
  local Height = InstanceData.CustomUIBase.Height or 0
  local InstanceManager = GetInstanceManager()
  local AdaptationInfo = InstanceManager:GetObjectValue(InstanceData.InstanceId, "CustomUIBase.AdaptationInfo", InstanceData)
  local DesignCanvas = GetDesignCanvasSize()
  local GameCanvasScaleX = DesignCanvas.Width > 0 and GameCanvasSize.X / DesignCanvas.Width or 1
  local GameCanvasScaleY = 0 < DesignCanvas.Height and GameCanvasSize.Y / DesignCanvas.Height or 1
  local VisualWidth = Width * GameCanvasScaleX
  local VisualHeight = Height * GameCanvasScaleY
  local RatioX = math_max(0, math_min(100, ScreenPercentX or 0)) / 100
  local RatioY = math_max(0, math_min(100, ScreenPercentY or 0)) / 100
  local TargetCenterX = VisualWidth / 2 + (GameCanvasSize.X - VisualWidth) * RatioX
  local TargetCenterY = VisualHeight / 2 + (GameCanvasSize.Y - VisualHeight) * RatioY
  local PBX, PBY, PBW, PBH = CustomUIAdaptationCalculator.GetParentBoundsForDS(InstanceID, GameCanvasSize, CustomUIData)
  local NewAdaptationInfo = CustomUIAdaptationCalculator.ReverseCalculateDS(TargetCenterX, TargetCenterY, VisualWidth, VisualHeight, AdaptationInfo, PBX, PBY, PBW, PBH)
  return NewAdaptationInfo
end
return CustomUIAdaptationCalculator