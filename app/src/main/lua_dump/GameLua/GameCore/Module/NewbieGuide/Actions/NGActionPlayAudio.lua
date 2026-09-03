local NewbieGuideActionPlayAudio = {}
function NewbieGuideActionPlayAudio:ctor(selfType, Params)
  self.sAudioPath = Params.sAudioPath or ""
  self.VoiceID = nil
  self.VoiceDelegate = nil
end
function NewbieGuideActionPlayAudio:RunAction(InGuideID)
  NewbieGuideActionPlayAudio.__super.RunAction(self, InGuideID)
  log(bWriteLog and "Debug NewbieGuide: RunAction:", InGuideID)
  self:PlayAudio()
  return true
end
function NewbieGuideActionPlayAudio:EndAction()
  NewbieGuideActionPlayAudio.__super.EndAction(self)
  log(bWriteLog and "Debug NewbieGuide: NewbieGuideActionPlayAudio EndAction")
  self:StopAudio()
end
function NewbieGuideActionPlayAudio:Clear()
  log(bWriteLog and "Debug NewbieGuide: NewbieGuideActionPlayAudio Clear")
  self:StopAudio()
end
function NewbieGuideActionPlayAudio:PlayAudio()
  local voicePath = self.sAudioPath
  if voicePath and voicePath ~= "" then
    self:StopAudio()
    local util = require("client.slua_ui_framework.util")
    local audioPath = util.GetUrlByLanguage(voicePath)
    local UEPathUtilityMethods = import("UEPathUtilityMethods")
    local bExist = UEPathUtilityMethods.IsPathExist(audioPath)
    if not bExist then
      audioPath = voicePath
    end
    self.VoiceDelegate = util.GetAssetAsync(audioPath, function(akEvent)
      if akEvent then
        local AkGameplayStatics = import("AkGameplayStatics")
        local uWorld = slua_GameFrontendHUD:GetWorld()
        self.VoiceID = AkGameplayStatics.PostEventAtLocation(akEvent, FVector(0, 0, 0), FRotator(0, 0, 0), "", uWorld)
      end
    end)
  end
end
function NewbieGuideActionPlayAudio:StopAudio()
  if self.VoiceID ~= nil then
    local audio_util = require("client.common.audio_util")
    audio_util.StopSound(self.VoiceID)
    self.VoiceID = nil
  end
  if self.VoiceDelegate ~= nil then
    local util = require("client.slua_ui_framework.util")
    util.ClearAssetAsync(self.VoiceDelegate)
    self.VoiceDelegate = nil
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNewbieGuideActionPlayAudio = class(CObject, nil, NewbieGuideActionPlayAudio)
return CNewbieGuideActionPlayAudio