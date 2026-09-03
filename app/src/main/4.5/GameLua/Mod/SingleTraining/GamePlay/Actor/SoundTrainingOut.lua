local SoundTrainingOut = {_IsShowingUI = false}
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
function SoundTrainingOut:ctor()
end
function SoundTrainingOut:ReceiveBeginPlay()
  print(bWriteLog and "SoundTrainingOut:ReceiveBeginPlay")
  SoundTrainingOut.__super.ReceiveBeginPlay(self)
end
function SoundTrainingOut:ShowUI()
  if self._IsShowingUI == false then
    self._IsShowingUI = true
    local SingleTraining_Sound_Tips = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Tips)
    if SingleTraining_Sound_Tips then
      SingleTraining_Sound_Tips:Collapsed()
    end
  end
end
function SoundTrainingOut:CloseUI(component)
  if self._IsShowingUI == true then
    self._IsShowingUI = false
    if not UIManager.UI_Config_InGame or not UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps then
      return
    end
    if require("GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundUtil").IsNeedCloseSoundTrain() then
      UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Tips)
    end
  end
end
function SoundTrainingOut:OnClientClickInteractiveButton()
  return true
end
function SoundTrainingOut:MustCheckResultAfterServerClick(character, result)
  if result ~= nil and result == true then
    self:MustCheckResultAfterSkillFinished(character, result)
  end
end
local class = require("class")
local CInteractiveActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local CSoundTrainingEntrance = class(CInteractiveActorBase, nil, SoundTrainingOut)
return CSoundTrainingEntrance