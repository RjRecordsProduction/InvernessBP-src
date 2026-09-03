local MapUIMarkManager = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
function MapUIMarkManager:ctor()
  print(bWriteLog and "Lua MapUIMarkManager:ctor()")
end
function MapUIMarkManager:OnInitConfig(ID)
  local NewMapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
  if NewMapMarkConfig and NewMapMarkConfig[ID] then
    local TempMapMarkConfig = import("MapMarkConfig")()
    TempMapMarkConfig.Config    TempMapMarkConfig.UIPath = NewMapMarkConfig[ID].UIPath or ""
    TempMapMarkConfig.bIsIcon = NewMapMarkConfig[ID].bIsIcon or false
    TempMapMarkConfig.Size = NewMapMarkConfig[ID].Size or FVector2D(30, 30)
    TempMapMarkConfig.bIsBigPOI = NewMapMarkConfig[ID].bIsBigPOI or false
    TempMapMarkConfig.bIsUpdateSize = NewMapMarkConfig[ID].bIsUpdateSize or false
    TempMapMarkConfig.ZOrder = NewMapMarkConfig[ID].ZOrder or 0
    TempMapMarkConfig.bIsControlByLegend = NewMapMarkConfig[ID].bIsControlByLegend or false
    TempMapMarkConfig.LegendTags = NewMapMarkConfig[ID].LegendTags or ""
    TempMapMarkConfig.MountTags = NewMapMarkConfig[ID].MountTags or ""
    TempMapMarkConfig.bIsBindActor = NewMapMarkConfig[ID].bIsBindActor or false
    TempMapMarkConfig.MaxShowDistance = NewMapMarkConfig[ID].MaxShowDistance or 0
    self.MapMarkConfigs:Add(ID, TempMapMarkConfig)
  end
end
function MapUIMarkManager:LuaGetMarkPriority(ID)
  local Priority = 0
  local NewMapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
  if NewMapMarkConfig and NewMapMarkConfig[ID] then
    Priority = NewMapMarkConfig[ID].Priority or 0
  end
  return Priority
end
function MapUIMarkManager:LuaProcessLegndMark(bIsShow, instanceID, typeID)
  local MapMarkLegendSubsystem = SubsystemMgr:Get("MapMarkLegendSubsystem")
  if MapMarkLegendSubsystem then
    MapMarkLegendSubsystem:OnMarkShowOrHide(bIsShow, instanceID, typeID)
  end
end
function MapUIMarkManager:AfterChangeMark(bIsShow, TypeID, Location, InstanceID, CustomState)
  if not bIsShow then
    InGameMarkTools.ClientDestroyMarkToNavigator(InstanceID)
    return
  end
  local MapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
  if not (MapMarkConfig and MapMarkConfig[TypeID]) or not MapMarkConfig[TypeID].NavigatorMarkPath then
    return
  end
  local UIPath = MapMarkConfig[TypeID].NavigatorMarkPath
  local bIsIcon = MapMarkConfig[TypeID].NavigatorMarkIsIcon
  if UIPath == "" then
    return
  end
  InGameMarkTools.ClientAddMarkToNavigator(UIPath, Location, true, bIsIcon, CustomState, InstanceID)
end
function MapUIMarkManager:CheckShouldShowInOB(ConfigID)
  local NewMapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
  if not NewMapMarkConfig or not NewMapMarkConfig[ConfigID] then
    return false
  end
  local Config = NewMapMarkConfig[ConfigID]
  if Config.LegendTextID and Config.LegendIconPath and Config.bIsControlByLegend then
    return true
  elseif Config.bOBShow then
    return true
  end
  return false
end
local Class = require("class")
local Object = require("common.delegate_container")
local CMapUIMarkManager = Class(Object, nil, MapUIMarkManager)
return CMapUIMarkManager