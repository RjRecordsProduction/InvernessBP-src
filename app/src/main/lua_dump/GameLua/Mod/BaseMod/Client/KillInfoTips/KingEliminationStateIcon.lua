local KingEliminationStateIcon = {}
function KingEliminationStateIcon:ctor(_, uPlayerState)
  self.PlayerState = uPlayerState
end
function KingEliminationStateIcon:RegistEvents()
  KingEliminationStateIcon.__super.RegistEvents(self)
  self:ResetRegistEvents()
end
function KingEliminationStateIcon:InitTeamItemPlayerStateWidget(uPlayerState)
  if slua.isValid(uPlayerState) and uPlayerState ~= self.PlayerState then
    self.PlayerState = uPlayerState
  end
  self:ResetRegistEvents()
end
function KingEliminationStateIcon:ResetRegistEvents()
  self:Collapsed()
  self:RemoveAllDataListener()
  if not slua.isValid(self.PlayerState) then
    self:Collapsed()
    return
  end
  if self.PlayerState.GetSuperData then
    self:AddDataListener(self.PlayerState:GetSuperData(), "bIsKingElimination", self.OnKingEliminationStateChanged, self)
  end
end
function KingEliminationStateIcon:OnKingEliminationStateChanged(_, bIsKingElimination)
  if bIsKingElimination then
    self:HitTestInvisible()
    self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
  else
    self:Collapsed()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, KingEliminationStateIcon)