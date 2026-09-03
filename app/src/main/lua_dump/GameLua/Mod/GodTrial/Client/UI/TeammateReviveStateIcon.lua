local TeammateReviveStateIcon = {}
function TeammateReviveStateIcon:ctor()
  self.LastSuperData = nil
  self.nLeftBuyLifeCounts = 0
end
function TeammateReviveStateIcon:RegistEvents()
  TeammateReviveStateIcon.__super.RegistEvents(self)
  self:AddOnAnimationFinishedEvent("Anim_In", self.OnEnterSpecialReviveState, self)
  self:AddOnAnimationFinishedEvent("Anim_Out", self.OnLeaveSpecialReviveState, self)
  self:ListerLeftBuyLifeCountsChange()
end
function TeammateReviveStateIcon:ListerLeftBuyLifeCountsChange()
  if self.LastSuperData then
    self:RemoveDataListener(self.LastSuperData, "nLeftBuyLifeCounts")
    self.LastSuperData = nil
  end
  if slua.isValid(self.uPlayerState) then
    self.LastSuperData = self.uPlayerState:GetSuperData()
    self:AddDataListener(self.LastSuperData, "nLeftBuyLifeCounts", self.OnLeftBuyLifeCountsChange, self)
  end
end
function TeammateReviveStateIcon:InitTeamItemPlayerStateWidget(uPlayerState)
  TeammateReviveStateIcon.__super.InitTeamItemPlayerStateWidget(self, uPlayerState)
  self:ListerLeftBuyLifeCountsChange()
end
function TeammateReviveStateIcon:OnLeftBuyLifeCountsChange(_, nLeftBuyLifeCounts)
  print(bWriteLog and "TeammateReviveStateIcon:OnLeftBuyLifeCountsChange 0", nLeftBuyLifeCounts)
  self.  if 1 <= nLeftBuyLifeCounts then
    print(bWriteLog and "TeammateReviveStateIcon:OnLeftBuyLifeCountsChange 1", nLeftBuyLifeCounts)
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_In, 0, 1, 0, 1)
  else
    print(bWriteLog and "TeammateReviveStateIcon:OnLeftBuyLifeCountsChange 2", nLeftBuyLifeCounts)
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Out, 0, 1, 0, 1)
  end
  self:RefreshUI()
end
function TeammateReviveStateIcon:OnEnterSpecialReviveState()
  print(bWriteLog and "TeammateReviveStateIcon:OnEnterSpecialReviveState")
  self:RefreshColor()
end
function TeammateReviveStateIcon:OnLeaveSpecialReviveState()
  print(bWriteLog and "TeammateReviveStateIcon:OnLeaveSpecialReviveState")
  self:RefreshColor()
end
function TeammateReviveStateIcon:RefreshColor()
  local Color = FLinearColor(1, 1, 1, 1)
  if self.nLeftBuyLifeCounts > 0.5 then
    Color = FLinearColor(1, 0.723055, 0.015209, 1)
  end
  self.UIRoot.ColorControllerBorder:SetContentColorAndOpacity(Color)
end
function TeammateReviveStateIcon:SetReviveIconState()
  local RestTime = self:GetReviveRestTime()
  local UIRoot = self.UIRoot
  if self.nReviveCount <= 0 and 0 >= self.nLeftBuyLifeCounts then
    UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(3)
    print(bWriteLog and "TeammateReviveStateIcon: SetReviveIconState 3")
  elseif RestTime >= self.ReviveIconConfig.BeginCountingTime then
    UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    print(bWriteLog and "TeammateReviveStateIcon: SetReviveIconState 0")
  else
    if RestTime >= self.ReviveIconConfig.RedWarningTime then
      UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
      print(bWriteLog and "TeammateReviveStateIcon: SetReviveIconState 1")
    end
    local nPercent = RestTime / self.ReviveIconConfig.BeginCountingTime
    print(bWriteLog and "TeammateReviveStateIcon: nPercent = ", nPercent)
    UIRoot.ProgressBar_1:SetPercent(nPercent)
    UIRoot.ProgressBar_2:SetPercent(nPercent)
  end
end
function TeammateReviveStateIcon:OnClose()
  TeammateReviveStateIcon.__super.OnClose(self)
  self.LastSuperData = nil
end
local class = require("class")
local UIBase = require("GameLua.Mod.Library.Revive1800.GamePlay.UI.TeammateReviveStateIcon")
return class(UIBase, nil, TeammateReviveStateIcon)