local GameplaySysMgr = {
  SysTable = {},
  SysNameTable = {}
}
local utility = require("common.utility")
function GameplaySysMgr.AddSysByName(SysName, SysPath)
  if GameplaySysMgr.SysTable[SysPath] then
    sandbox.LogError(string.format("GameplaySysMgr already has the same path sys:{%s}", SysPath))
    return
  end
  if GameplaySysMgr.SysNameTable[SysName] then
    sandbox.LogError(string.format("GameplaySysMgr already has the same name sys:{%s}", SysPath))
    return
  end
  local SysClass = require(SysPath)
  local SysInstance = SysClass()
  xpcall(SysInstance.Init, utility.ErrorMessageHandler, SysInstance)
  GameplaySysMgr.SysTable[SysPath] = SysInstance
  GameplaySysMgr.SysNameTable[SysName] = SysPath
end
function GameplaySysMgr.GetSysByPath(SysPath)
  local SysInstance = GameplaySysMgr.SysTable[SysPath]
  if not SysInstance then
  end
  return SysInstance
end
function GameplaySysMgr.GetSysByName(SysName)
  local SysPath = GameplaySysMgr.SysNameTable[SysName]
  if not SysPath then
    sandbox.LogWarning(string.format("GameplaySysMgr can not find system {%s}", SysPath))
    return nil
  end
  return GameplaySysMgr.GetSysByPath(SysPath)
end
function GameplaySysMgr.RemoveSysByPath(SysPath)
  local SysInstance = GameplaySysMgr.SysTable[SysPath]
  if not SysInstance then
    return
  end
  SysInstance:Dispose()
  return
end
function GameplaySysMgr.EndPlay()
  sandbox.LogNormal(bWriteLog and "GameplaySysMgr.EndPlay")
  for _, SysInstance in pairs(GameplaySysMgr.SysTable) do
    if SysInstance and SysInstance.EndPlay then
      xpcall(SysInstance.EndPlay, utility.ErrorMessageHandler, SysInstance)
    end
  end
  GameplaySysMgr.SysTable = {}
  GameplaySysMgr.SysNameTable = {}
end
function GameplaySysMgr.HandlePlayerSwitchLand(uPlayerController)
  if not slua.isValid(uPlayerController) then
    return
  end
  for _, SysInstance in pairs(GameplaySysMgr.SysTable) do
    if SysInstance and SysInstance.HandlePlayerSwitchLand then
      xpcall(SysInstance.HandlePlayerSwitchLand, utility.ErrorMessageHandler, SysInstance, uPlayerController)
    end
  end
end
function GameplaySysMgr.HandlePlayerPreSwitchLand(uPlayerController)
  if not slua.isValid(uPlayerController) then
    return
  end
  for _, SysInstance in pairs(GameplaySysMgr.SysTable) do
    if SysInstance and SysInstance.HandlePlayerPreSwitchLand then
      xpcall(SysInstance.HandlePlayerPreSwitchLand, utility.ErrorMessageHandler, SysInstance, uPlayerController)
    end
  end
end
function GameplaySysMgr.HandlePlayerExitLand(uPlayerController)
  if not slua.isValid(uPlayerController) then
    return
  end
  for _, SysInstance in pairs(GameplaySysMgr.SysTable) do
    if SysInstance and SysInstance.HandlePlayerExitLand then
      xpcall(SysInstance.HandlePlayerExitLand, utility.ErrorMessageHandler, SysInstance, uPlayerController)
    end
  end
end
function GameplaySysMgr.HandlePlayerEnterLand(uPlayerController)
  if not slua.isValid(uPlayerController) then
    return
  end
  for _, SysInstance in pairs(GameplaySysMgr.SysTable) do
    if SysInstance and SysInstance.HandlePlayerEnterLand then
      xpcall(SysInstance.HandlePlayerEnterLand, utility.ErrorMessageHandler, SysInstance, uPlayerController)
    end
  end
end
function GameplaySysMgr.HandlePlayerRealExit(PlayerKey)
  for _, SysInstance in pairs(GameplaySysMgr.SysTable) do
    if SysInstance and SysInstance.HandlePlayerRealExit then
      xpcall(SysInstance.HandlePlayerRealExit, utility.ErrorMessageHandler, SysInstance, PlayerKey)
    end
  end
end
function GameplaySysMgr.HandlePlayerJoinIn(uPlayer)
  if not slua.isValid(uPlayer) then
    return
  end
  for _, SysInstance in pairs(GameplaySysMgr.SysTable) do
    if SysInstance then
      SysInstance:HandlePlayerJoinIn(uPlayer)
    end
  end
end
return GameplaySysMgr