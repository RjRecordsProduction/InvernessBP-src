local EnvironmentTools = {}
local UKismetSystemLibrary = import("KismetSystemLibrary")
local GameplayData
local nGrassDisplayState = true
function EnvironmentTools.ToggleGrassDisplay(uPlayerController)
  if not uPlayerController then
    GameplayData = GameplayData or require("GameLua.GameCore.Data.GameplayData")
    uPlayerController = GameplayData.GetPlayerController()
  end
  if not slua.isValid(uPlayerController) then
    log_error_format("EnvironmentTools:ToggleGrassDisplay. Invalid player controller")
    return nGrassDisplayState
  end
  nGrassDisplayState = not nGrassDisplayState
  if nGrassDisplayState then
    UKismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "r.DisableGrassRender 0")
    log("EnvironmentTools:ToggleGrassDisplay. Show grass")
  else
    UKismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "r.DisableGrassRender 1")
    log("EnvironmentTools:ToggleGrassDisplay. Hide grass (Please wait a moment)")
  end
  return nGrassDisplayState
end
function EnvironmentTools.SetGrassDisplay(bShow, uPlayerController)
  if not uPlayerController then
    GameplayData = GameplayData or require("GameLua.GameCore.Data.GameplayData")
    uPlayerController = GameplayData.GetPlayerController()
  end
  if not slua.isValid(uPlayerController) then
    log_error_format("EnvironmentTools:SetGrassDisplay. Invalid player controller")
    return nGrassDisplayState
  end
  if nGrassDisplayState == bShow then
    return nGrassDisplayState
  end
  nGrassDisplayState = bShow
  if nGrassDisplayState then
    UKismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "r.DisableGrassRender 0")
    log("EnvironmentTools:SetGrassDisplay. Show grass")
  else
    UKismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "r.DisableGrassRender 1")
    log("EnvironmentTools:SetGrassDisplay. Hide grass (Please wait a moment)")
  end
  return nGrassDisplayState
end
function EnvironmentTools.GetGrassDisplayState()
  return nGrassDisplayState
end
function EnvironmentTools.ResetGrassDisplay(uPlayerController)
  if not uPlayerController then
    GameplayData = GameplayData or require("GameLua.GameCore.Data.GameplayData")
    uPlayerController = GameplayData.GetPlayerController()
  end
  if not slua.isValid(uPlayerController) then
    log_error_format("EnvironmentTools:ResetGrassDisplay. Invalid player controller")
    return nGrassDisplayState
  end
  nGrassDisplayState = true
  UKismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "r.DisableGrassRender 0")
  log("EnvironmentTools:ResetGrassDisplay. Reset grass display to show")
  return nGrassDisplayState
end
return EnvironmentTools