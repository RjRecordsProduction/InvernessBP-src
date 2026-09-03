local SingleTrainSoundScoreUI = {
  _GameType = -1,
  _Score = -1,
  _Level = -1
}
function SingleTrainSoundScoreUI:ctor(selfType, GameType, Score, Level)
  self._  self._  self._end
function SingleTrainSoundScoreUI:OnConstruct(GameType, Score, Level)
  self._  self._  self._end
function SingleTrainSoundScoreUI:RegistEvents()
  SingleTrainSoundScoreUI.__super.RegistEvents(self)
  self.UIRoot.TextBlock_9:SetText(LocUtil.GetLocalizeResStr("39023"))
end
function SingleTrainSoundScoreUI:OnShow()
  self:PlayUserWidgetAnimation(self.UIRoot.open, 0, 1, 0, 1)
  self:AddGameTimer(5, false, function()
    self:ShowOutAnimation()
  end)
  self:_UpdateView()
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_End.Play_UI_Training_End")
end
function SingleTrainSoundScoreUI:OnHide()
  self:RemoveAllTimer()
end
function SingleTrainSoundScoreUI:_UpdateView()
  self.UIRoot.TextBlock_10:SetText(LocUtil.LocalizeFormatConcatenation(39018, self._Score))
  if self._Level == 1 then
    self.UIRoot.TextBlock_4:SetText(LocUtil.GetLocalizeResStr(39014))
  elseif self._Level == 2 then
    self.UIRoot.TextBlock_4:SetText(LocUtil.GetLocalizeResStr(39015))
  elseif self._Level == 3 then
    self.UIRoot.TextBlock_4:SetText(LocUtil.GetLocalizeResStr(39016))
  elseif self._Level == 4 then
    self.UIRoot.TextBlock_4:SetText(LocUtil.GetLocalizeResStr(39017))
  end
end
function SingleTrainSoundScoreUI:ShowOutAnimation()
  self:PlayUserWidgetAnimation(self.UIRoot.out, 0, 1, 0, 1)
  self:AddGameTimer(self.UIRoot.out:GetEndTime(), false, function()
    self:Collapsed()
  end)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, SingleTrainSoundScoreUI)