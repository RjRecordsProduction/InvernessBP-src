local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local MainSoundVisualizationUI = {}
function MainSoundVisualizationUI:AddCustomVoiceKey(character, posVector, IsWeapon, isSlience, myCharacter, CustomVoiceKey)
  if CustomVoiceKey == "CentaurArrow" then
    local CustomIconPath = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/SoundVisualization_Icon_Centaur_png.SoundVisualization_Icon_Centaur_png"
    self.StayTime = 2
    self:HandleCustomVoice(character, posVector, myCharacter, CustomIconPath)
  end
end
function MainSoundVisualizationUI:HandleCustomVoice(character, posVector, myCharacter, path)
  local angle = self:GetAngle(posVector, myCharacter)
  if not angle then
    self:HideAllUI()
    return
  end
  print("MainSoundVisualizationUI:HandleCustomVoice Angle ", angle)
  self:SetSoundAngle(angle)
  local nowDistance = posVector:Size()
  if nowDistance <= 0 then
    nowDistance = 1
  end
  if nowDistance <= 10000 then
    local alpha = self:ComputeAlpha(10000, 500, nowDistance)
    self:ShowSoundIcon(posVector, myCharacter, alpha, path, false, self.BgPath.NormalBG)
  else
    self:HideAllUI()
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local curTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self.UIRoot.LeaveTime = self.StayTime + curTime
  self.UIRoot.StartTime = curTime
  print(bWriteLog and "MainSoundVisualizationUI:HandleCustomVoice  ", self.UIRoot.LeaveTime, " : ", self.UIRoot.StartTime)
end
local class = require("class")
local MainSoundVisualizationUIBase = require("GameLua.Mod.BaseMod.Client.SoundVisualization.MainSoundVisualizationUI")
MainSoundVisualizationUI = class(MainSoundVisualizationUIBase, nil, MainSoundVisualizationUI)
return MainSoundVisualizationUI