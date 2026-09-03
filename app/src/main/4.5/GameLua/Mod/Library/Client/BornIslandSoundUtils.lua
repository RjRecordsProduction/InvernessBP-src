local BornIslandSoundUtils = {bVoiceDecreased = false}
function BornIslandSoundUtils:GunshotAttenuation()
  log(bWriteLog and "BornIslandSoundUtils GunshotAttenuation")
  self:ResetVoice()
  local DelegateContainerC = require("common.delegate_container")
  if self.DelegateContainer == nil then
    self.DelegateContainer = DelegateContainerC()
    self.DelegateContainer:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_MAP_AIRPLANE_ROUTE, self.DecreaseVoice, self)
    self.DelegateContainer:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameStateChange, self)
  end
end
function BornIslandSoundUtils:OnGameStateChange(_, __, State)
  if State == "FightingState" then
    self:ResetVoice()
  end
end
function BornIslandSoundUtils:DecreaseVoice()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    local CurGameState = uGameState:GetGameModeState()
    if CurGameState == "ReadyState" or CurGameState == "ActiveState" then
      self:SetRTPCValue(true)
    end
  else
    self:SetRTPCValue(true)
  end
end
function BornIslandSoundUtils:ResetVoice()
  self:SetRTPCValue(false)
  if self.DelegateContainer then
    self.DelegateContainer:Dispose()
    self.DelegateContainer = nil
  end
end
function BornIslandSoundUtils:SetRTPCValue(param)
  if self.bVoiceDecreased == param then
    return
  end
  self.bVoiceDecreased = param
  print(bWriteLog and "BornIslandSoundUtils SetRTPCValue " .. tostring(param))
  local AkGameplayStatics = import("AkGameplayStatics")
  if param then
    AkGameplayStatics.SetRTPCValue("ContestMode", 100, 0, nil)
    AkGameplayStatics.SetRTPCValue("SocialIsland_GunVolume", 100, 0, nil)
    AkGameplayStatics.SetRTPCValue("BirthIsland_Hurt_Vo", 1, 0, nil)
  else
    AkGameplayStatics.SetRTPCValue("ContestMode", 0, 0, nil)
    AkGameplayStatics.SetRTPCValue("SocialIsland_GunVolume", 0, 0, nil)
    AkGameplayStatics.SetRTPCValue("BirthIsland_Hurt_Vo", 0, 0, nil)
  end
end
return BornIslandSoundUtils