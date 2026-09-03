local SoundVisualizationSubsystem = {}
local slua_isValid = slua.isValid
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SoundVisualizationType = require("GameLua.Mod.BaseMod.GamePlay.SoundVisualization.SoundVisualizationType")
local HearingEnhanceBuffID = 84106
function SoundVisualizationSubsystem:OnInit()
  print(bWriteLog and "SoundVisualizationSubsystem:OnInit")
  SoundVisualizationSubsystem.__super.OnInit(self)
end
function SoundVisualizationSubsystem:IsNeedShowVoice(otherCharacter, myCharacter)
  if not slua.isValid(otherCharacter) or not slua.isValid(myCharacter) then
    return true
  end
  if not Game:IsAI(otherCharacter) then
    return false
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  if uPlayerController:IsInSpectatingEnemy() or uPlayerController:IsSpectator() and myCharacter == otherCharacter then
    return false
  end
  if uPlayerController:IsInPetSpectator() and myCharacter == otherCharacter then
    return false
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if Game:IsValid(uGameState) then
    if uGameState.bForbitAudioVisual then
      print(bWriteLog and "SoundVisualizationSubsystem:IsNeedShowVoice False Case bForbitAudioVisual")
      return false
    end
    if uGameState.bIsTrainingMode then
      local uPlayerState = GameplayData.GetPlayerState()
      if not Game:IsValid(uPlayerState) then
        print(bWriteLog and "SoundVisualizationSubsystem:IsNeedShowVoice False Case uPlayerState")
        return false
      end
      if not uPlayerState.bEnableAITraining then
        print(bWriteLog and "SoundVisualizationSubsystem:IsNeedShowVoice False Case bEnableAITraining")
        return false
      end
    end
  end
  local CurCharacterAttr = myCharacter:GetAttrValue("IsInUnderGroundArea")
  local OtherCharacterAttr = otherCharacter:GetAttrValue("IsInUnderGroundArea")
  if math.abs(CurCharacterAttr - OtherCharacterAttr) < 0.1 then
    return true
  end
  return false
end
local class = require("class")
local SubsystemBase = require("GameLua.Mod.BaseMod.Client.SoundVisualization.SoundVisualizationSubsystem")
return class(SubsystemBase, nil, SoundVisualizationSubsystem)