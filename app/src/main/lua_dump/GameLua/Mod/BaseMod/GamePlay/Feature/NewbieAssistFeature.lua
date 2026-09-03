local NewbieAssistFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
NewbieAssistFeature.ServerRPC.RPC_Server_StartNewbieAssistDSSubSystem = {
  Reliable = true,
  Params = {}
}
function NewbieAssistFeature:RPC_Server_StartNewbieAssistDSSubSystem()
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_NEWBIE_ASSIST_STARTUP_DS_SUBSYSTEM)
end
NewbieAssistFeature.ClientRPC.RPC_Client_RescueOtherSuccessfully = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32
  }
}
function NewbieAssistFeature:RPC_Client_RescueOtherSuccessfully(PlayerKey)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.GetCurPawn then
    local uPawn = uPlayerController:GetCurPawn()
    if slua.isValid(uPawn) and uPawn.PlayerKey == PlayerKey then
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_RESCUE_OTHER_SUCCESSFULLY)
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, NewbieAssistFeature)