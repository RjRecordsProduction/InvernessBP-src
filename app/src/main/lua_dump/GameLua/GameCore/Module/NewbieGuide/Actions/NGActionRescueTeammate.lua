local NGActionRescueTeammate = {}
function NGActionRescueTeammate:ctor(selfType, Params)
  self.AttachParentWindow = Params.AttachParentWindow or "ingamesub"
  self.AttachParentSlot = Params.AttachParentSlot or "Canvas_Border_Team"
  self.RegisterButtonNameGetter = Params.RegisterButtonNameGetter or function(Index)
    return "Ingame_TeamItem_BP_C_" .. tostring(Index)
  end
  self.TextID = Params.TextID or 12529
  self.CheckPositionItemFlashing = true
  if Params.CheckPositionItemFlashing ~= nil then
    self.CheckPositionItemFlashing = Params.CheckPositionItemFlashing
  end
  self.MaxDistance = Params.MaxDistance or 100
  self.TeammateIndex = nil
  self.UITipAction = nil
  self.PositionItem = nil
  self.TimerHandle = nil
end
function NGActionRescueTeammate:RunAction(InGuideID, TeammateIndex)
  NGActionRescueTeammate.__super.RunAction(self, InGuideID)
  log(bWriteLog and "Debug NewbieGuide: NGActionRescueTeammate RunAction GuideID:" .. tostring(InGuideID))
  if 0 <= TeammateIndex and TeammateIndex <= 4 then
    self.  end
  if not self:CheckCanRunAction() then
    return false
  end
  self:CreateUITip()
  if self.UITipAction and self.UITipAction.RunAction and not self.UITipAction:RunAction() then
    self:EndAction()
    return false
  end
  local Result = self:PositionItemFlashing()
  if not Result and self.CheckPositionItemFlashing then
    self:EndAction()
    return false
  end
  return true
end
function NGActionRescueTeammate:EndAction()
  NGActionRescueTeammate.__super.EndAction(self)
  log(bWriteLog and "Debug NewbieGuide: NGActionRescueTeammate EndAction")
  self.TeammateIndex = nil
  if self.UITipAction then
    self.UITipAction:EndAction()
  end
  self.UITipAction = nil
  if self.TimerHandle then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.TimerHandle)
    self.TimerHandle = nil
  end
  if self.PositionItem then
    self:SetPositionItemAlpha(1.0)
    self.PositionItem = nil
  end
end
function NGActionRescueTeammate:Clear()
  NGActionRescueTeammate.__super.Clear(self)
  self:EndAction()
end
function NGActionRescueTeammate:CheckCanRunAction()
  if not self.TeammateIndex then
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    sandbox.LogError("NGActionRescueTeammate CheckCanRunAction PlayerController not valid!")
    return false
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    sandbox.LogError("NGActionRescueTeammate CheckCanRunAction PlayerState not valid!")
    return false
  end
  local uTeamMatePlayerStateList
  if uPlayerState.GetTeamMatePlayerStateList then
    uTeamMatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, true)
  end
  if not uTeamMatePlayerStateList then
    return
  end
  local uTeammatePlayerState = uTeamMatePlayerStateList:Get(self.TeammateIndex)
  if not uTeammatePlayerState then
    log(bWriteLog and "NGActionRescueTeammate CheckCanRunAction Teammate PlayerState is null!")
    return false
  end
  local uPawnLoc = uPlayerController:GetCurPawnLocation()
  local uTeammateCharacter = uTeammatePlayerState.CharacterOwner
  if not slua.isValid(uTeammateCharacter) then
    sandbox.LogError("NGActionRescueTeammate CheckCanRunAction TeammateCharacter not valid!")
    return false
  end
  local uTeammateLoc = uTeammateCharacter:K2_GetActorLocation()
  local nDistance = FVector.DistXY(uPawnLoc, uTeammateLoc) * 0.01
  log(bWriteLog and "Debug NewbieGuide: NGActionRescueTeammate Distance With Teammate:" .. tostring(nDistance))
  if nDistance < self.MaxDistance then
    return true
  else
    return false
  end
end
function NGActionRescueTeammate:CreateUITip()
  local Params = {
    AttachParentWindow = self.AttachParentWindow,
    AttachParentSlot = self.AttachParentSlot,
    RegisterButtonName = self.RegisterButtonNameGetter(self.TeammateIndex),
    HighlightOutlineType = -1,
    TextID = self.TextID
  }
  local CAction = require("GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI")
  if CAction then
    self.UITipAction = CAction(Params)
    if not self.UITipAction then
      sandbox.LogError("Debug NewbieGuide: NGActionRescueTeammate Create Action Failed!")
    end
  end
end
function NGActionRescueTeammate:PositionItemFlashing()
  local TeamPanelSaved
  if UIManager.UI_Config_InGame.TeamPanel then
    TeamPanelSaved = UIManager.GetUI(UIManager.UI_Config_InGame.TeamPanel)
    if not TeamPanelSaved then
      return false
    end
  else
    local UIUtil = require("client.common.ui_util")
    TeamPanelSaved = UIUtil.GetWidgetByName("ingamesub", "Ingame_TeamPanel_BP")
    if not slua.isValid(TeamPanelSaved) then
      return false
    end
  end
  if UIManager.UI_Config_InGame.TeamPanel then
    local TeammatePosItemList = TeamPanelSaved.TeammatePosItemList
    for _, TeammatePosItem in pairs(TeammatePosItemList) do
      if TeammatePosItem and TeammatePosItem.nTeamMemberIndex == self.TeammateIndex then
        self.PositionItem = TeammatePosItem
        break
      end
    end
  else
    for Index = 0, TeamPanelSaved.TeammatePosList:Num() do
      local Item = TeamPanelSaved.TeammatePosList:Get(Index)
      if Item and Item.TeamMemberIndex == self.TeammateIndex then
        self.Position        break
      end
    end
  end
  if not slua.isValid(self.PositionItem) then
    log(bWriteLog and "Debug can't find TeammatePositionItem.")
    return false
  end
  local time_ticker = require("common.time_ticker")
  self.nCurAlpha = 1.0
  self.nDeltAlpha = 0.2
  self.OriginPositionItemColor = self.PositionItem.Image_PlayerOffOnlineBG.ColorAndOpacity
  self.TimerHandle = time_ticker.AddTimer(0, function(...)
    while self.PositionItem do
      if self.nCurAlpha < 0 then
        self.nDeltAlpha = 0.2
      elseif self.nCurAlpha > 1 then
        self.nDeltAlpha = -0.2
      end
      self.nCurAlpha = self.nCurAlpha + self.nDeltAlpha
      self:SetPositionItemAlpha(self.nCurAlpha)
      coroutine.yield(0.1)
    end
  end)
  return true
end
function NGActionRescueTeammate:SetPositionItemAlpha(DeltAlpha)
  local NewItemColor = FLinearColor(self.OriginPositionItemColor.R, self.OriginPositionItemColor.G, self.OriginPositionItemColor.B, DeltAlpha)
  self.PositionItem.Image_PlayerFallToTheGroundBG:SetColorAndOpacity(NewItemColor)
  self.PositionItem.Image_PlayerFallToTheGround:SetColorAndOpacity(FLinearColor(1, 1, 1, DeltAlpha))
  self.PositionItem.Image_Arrow:SetColorAndOpacity(FLinearColor(1, 1, 1, DeltAlpha))
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionRescueTeammate = class(CObject, nil, NGActionRescueTeammate)
return CNGActionRescueTeammate