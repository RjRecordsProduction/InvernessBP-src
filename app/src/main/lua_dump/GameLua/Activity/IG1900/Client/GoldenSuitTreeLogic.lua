local GoldenSuitLogic = {}
local UGameplayStatics = import("GameplayStatics")
function GoldenSuitLogic.Init()
  if not GoldenSuitLogic.bRegister then
    GoldenSuitLogic.bRegister = true
    EventSystem:registEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, GoldenSuitLogic.HandleTriggerGameFighting)
  end
end
function GoldenSuitLogic.HandleTriggerGameFighting()
  log(bWriteLog and "GoldenSuitLogic:HandleTriggerGameFighting")
  local UIUtil = require("client.common.ui_util")
  local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if uPlayerController and slua.isValid(uPlayerController) and uPlayerController.SetMovable and type(uPlayerController.SetMovable) == "function" then
    uPlayerController:SetMovable(true)
  end
end
function GoldenSuitLogic.Destroy()
  log(bWriteLog and "GoldenSuitLogic Destroy ")
  if GoldenSuitLogic.bRegister then
    EventSystem:unregistEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, GoldenSuitLogic.HandleTriggerGameFighting)
    GoldenSuitLogic.bRegister = false
  end
end
return GoldenSuitLogic