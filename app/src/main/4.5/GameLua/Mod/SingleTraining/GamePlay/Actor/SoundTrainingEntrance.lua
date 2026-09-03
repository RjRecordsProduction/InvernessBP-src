local SoundTrainingEntrance = {_ID = 16010}
function SoundTrainingEntrance:ctor()
end
function SoundTrainingEntrance:ReceiveBeginPlay()
  print(bWriteLog and "SoundTrainingEntrance:ReceiveBeginPlay")
  SoundTrainingEntrance.__super.ReceiveBeginPlay(self)
  if self.hasAuthority == false then
    self.NewBie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SINGLETRAIN, self._ID)
    if self.NewBie then
      self.ParticleSystem:SetVisibility(true, true)
      self.ParticleSystem1:SetVisibility(true, true)
    else
      self.ParticleSystem:SetVisibility(false, true)
      self.ParticleSystem1:SetVisibility(false, true)
    end
  end
end
function SoundTrainingEntrance:OnClientShowInteractiveUI(show, component)
  component = component or self:GetInteractiveComponent()
  local SingleTrainSoundUtil = require("GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundUtil")
  if show and not SingleTrainSoundUtil.IsTraining() then
    self:ShowUI(component)
  else
    self:CloseUI(component)
  end
end
function SoundTrainingEntrance:ShowUI(component)
  local ui = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTrainEntranceUI)
  if ui ~= nil then
    ui:SelfHitTestInvisible()
    ui.  else
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTrainEntranceUI, component)
  end
end
function SoundTrainingEntrance:CloseUI(component)
  if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.SingleTrainEntranceUI then
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTrainEntranceUI)
    if ui then
      ui:Hide(component)
    end
  end
end
function SoundTrainingEntrance:OnClientClickInteractiveButton()
  return true
end
function SoundTrainingEntrance:MustCheckResultAfterServerClick(character, result)
  if result ~= nil and result == true then
    self:MustCheckResultAfterSkillFinished(character, result)
  end
end
local class = require("class")
local CInteractiveActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local CSoundTrainingEntrance = class(CInteractiveActorBase, nil, SoundTrainingEntrance)
return CSoundTrainingEntrance