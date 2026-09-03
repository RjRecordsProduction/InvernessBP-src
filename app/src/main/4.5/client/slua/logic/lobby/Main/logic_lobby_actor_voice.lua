local logic_lobby_actor_voice = {}
function logic_lobby_actor_voice:OnInitialize()
  log(bWriteLog and "logic_lobby_actor_voice:OnInitialize")
end
function logic_lobby_actor_voice:RegistEvents()
  log(bWriteLog and "logic_lobby_actor_voice:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_SHOW_LOBBY_UI, self.OnShowLobbyVoiceUI, self)
end
function logic_lobby_actor_voice:OnDestroy()
  log(bWriteLog and "logic_lobby_actor_voice:OnDestroy")
end
function logic_lobby_actor_voice:OnShowLobbyVoiceUI(_, __, voiceID, voicePlayCD, voiceText, bKeepPreviousSound)
  log(bWriteLog and "logic_lobby_actor_voice:OnShowLobbyVoiceUI voiceID = " .. tostring(voiceID) .. ", voicePlayCD = " .. tostring(voicePlayCD) .. ", voiceText = " .. tostring(voiceText) .. ", bKeepPreviousSound = " .. tostring(bKeepPreviousSound))
  local lobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not lobbyMainUI then
    return
  end
  local actorVoiceUI = lobbyMainUI:GetChildUI(UIManager.UI_Config.Lobby_Main_Actor_Voice_UIBP)
  if not actorVoiceUI then
    lobbyMainUI:AddChildUI("Border_ActorVoice", UIManager.UI_Config.Lobby_Main_Actor_Voice_UIBP)
    actorVoiceUI = lobbyMainUI:GetChildUI(UIManager.UI_Config.Lobby_Main_Actor_Voice_UIBP)
  end
  actorVoiceUI:ProcShowLobbyVoiceUI(voiceID, voicePlayCD, voiceText, bKeepPreviousSound)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_lobby_actor_voice)