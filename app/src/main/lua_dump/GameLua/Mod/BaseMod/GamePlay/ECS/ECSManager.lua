local ECSManager = {}
local EECSSystemType = import("EECSSystemType")
local SystemConifgH = {
  [1] = {
    ProcessDataPerFrame = 5,
    MaxHeapData = 10,
    STickInterval = 0
  },
  [2] = {
    ProcessDataPerFrame = 5,
    MaxHeapData = 10,
    STickInterval = 0
  },
  [3] = {
    ProcessDataPerFrame = 5,
    MaxHeapData = 10,
    STickInterval = 0
  },
  [4] = {
    ProcessDataPerFrame = 1,
    MaxHeapData = 10,
    STickInterval = 0
  },
  [6] = {
    ProcessDataPerFrame = 10,
    MaxHeapData = 20,
    STickInterval = 2
  }
}
local SystemConifgM = {}
local SystemConifgL = {
  [1] = {
    ProcessDataPerFrame = 3,
    MaxHeapData = 20,
    STickInterval = 0
  },
  [2] = {
    ProcessDataPerFrame = 2,
    MaxHeapData = 10,
    STickInterval = 0
  },
  [3] = {
    ProcessDataPerFrame = 3,
    MaxHeapData = 10,
    STickInterval = 0
  },
  [4] = {
    ProcessDataPerFrame = 1,
    MaxHeapData = 10,
    STickInterval = 0
  },
  [6] = {
    ProcessDataPerFrame = 10,
    MaxHeapData = 20,
    STickInterval = 2
  }
}
function ECSManager:ctor(selfType)
  print(bWriteLog and "ECSManager:ctor")
end
function ECSManager:InitSystemConfig(USystem)
  if not Client then
    return
  end
  if not slua.isValid(USystem) or not USystem.SystemType then
    return
  end
  local UIUtil = require("client.common.ui_util")
  local gameInstance = UIUtil.GetGameInstance()
  local nDeviceLevel = gameInstance:GetDeviceLevel()
  print(bWriteLog and "ECSManager:InitSystemConfig nDeviceLevel", nDeviceLevel, USystem.SystemType)
  local SystemConifg = SystemConifgH
  if nDeviceLevel == 1 and SystemConifgM[USystem.SystemType] then
    SystemConifg = SystemConifgM
  elseif nDeviceLevel == 0 and SystemConifgM[USystem.SystemType] then
    SystemConifg = SystemConifgL
  end
  if USystem.SystemType and SystemConifg[USystem.SystemType] then
    local CurSystemConfig = SystemConifg[USystem.SystemType]
    print(bWriteLog and "ECSManager:InitSystemConfig", CurSystemConfig)
    USystem.ProcessDataPerFrame = CurSystemConfig.ProcessDataPerFrame
    USystem.MaxHeapData = CurSystemConfig.MaxHeapData
    USystem.STickInterval = CurSystemConfig.STickInterval
  end
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local ECSManager = class(CObjectBase, nil, ECSManager)
return ECSManager