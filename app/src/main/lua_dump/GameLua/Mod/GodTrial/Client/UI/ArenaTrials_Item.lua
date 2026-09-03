local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ArenaTrials_Item = {}
function ArenaTrials_Item:ctor()
  self.RankQualifyThreshold = 4
  self.TipTextIdYes = {4401037, 4401038}
  self.TipTextIdNo = {4401037, 4401038}
  self.bIsOnLeft = false
end
function ArenaTrials_Item:OnInitialize()
  print(bWriteLog and "ArenaTrials_Item:OnInitialize")
  ArenaTrials_Item.__super.OnInitialize(self)
  self:Collapsed()
end
function ArenaTrials_Item:RegistEvents()
  print(bWriteLog and "ArenaTrials_Item:RegistEvents")
  ArenaTrials_Item.__super.RegistEvents(self)
end
function ArenaTrials_Item:OnShow()
  print(bWriteLog and "ArenaTrials_Item:OnShow")
end
function ArenaTrials_Item:OnHide()
  print(bWriteLog and "ArenaTrials_Item:OnHide")
end
function ArenaTrials_Item:OnClose()
  print(bWriteLog and "ArenaTrials_Item:OnClose")
  ArenaTrials_Item.__super.OnClose(self)
end
function ArenaTrials_Item:SetIsOnLeft(bIsOnLeft)
  print(bWriteLog and string.format("ArenaTrials_Item:SetIsOnLeft - bIsOnLeft=%s", tostring(bIsOnLeft)))
  self.  self:RefreshImageFlip()
  self:RefreshAll()
end
function ArenaTrials_Item:RefreshImageFlip()
  if not self.UIRoot or not self.UIRoot.Image_0 then
    return
  end
  local scaleX = self.bIsOnLeft and -1 or 1
  self.UIRoot.Image_0:SetRenderScale(FVector2D(scaleX, 1))
end
function ArenaTrials_Item:RefreshAll()
  print(bWriteLog and "ArenaTrials_Item:RefreshAll")
  self:RefreshHonorGoal()
  self:RefreshRankGoal()
end
function ArenaTrials_Item:RefreshHonorGoal()
  local CurrentScore = 0
  local MinimumScore = 0
  local MyPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(MyPlayerController) then
    local MyPlayerState = MyPlayerController.PlayerState
    if slua.isValid(MyPlayerState) and MyPlayerState.PlayerStateHonorFeature then
      CurrentScore = MyPlayerState.PlayerStateHonorFeature.TeamTotalScore or 0
    end
  end
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateTeamHonorFeature then
    MinimumScore = GameState.GameStateTeamHonorFeature.ArenaMinimumScore or 0
  end
  local bQualified = 0 < MinimumScore and CurrentScore >= MinimumScore
  local widget = self.UIRoot.ArenaTrials_Goal_Item
  self:RefreshGoalItem(widget, 1, bQualified)
end
function ArenaTrials_Item:RefreshRankGoal()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateTeamHonorFeature then
    local Threshold = GameState.GameStateTeamHonorFeature.ArenaChoosenTeamNum
    if Threshold and 0 < Threshold then
      self.RankQualify    end
  end
  local Rank = 0
  local bQualified = false
  local MyPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(MyPlayerController) then
    local MyPlayerState = MyPlayerController.PlayerState
    if slua.isValid(MyPlayerState) and MyPlayerState.TeamID then
      local GameState2 = GameplayData.GetGameState()
      if slua.isValid(GameState2) and GameState2.GameStateTeamHonorFeature then
        local _, RankVal = GameState2.GameStateTeamHonorFeature:ClientGetTeamTotalScore(MyPlayerState.TeamID)
        if RankVal then
          Rank = math.floor(RankVal)
          bQualified = Rank <= self.RankQualifyThreshold
        end
      end
    end
  end
  local widget = self.UIRoot.ArenaTrials_Goal_Item_C_0
  self:RefreshGoalItem(widget, 2, bQualified)
end
function ArenaTrials_Item:RefreshGoalItem(widget, index, bQualified)
  if not widget then
    print(bWriteLog and string.format("ArenaTrials_Item:RefreshGoalItem - widget is nil, index=%d", index))
    return
  end
  local SwitcherIndex = (self.bIsOnLeft and 2 or 0) + (bQualified and 0 or 1)
  if widget.WidgetSwitcher_IsSelected then
    widget.WidgetSwitcher_IsSelected:SetActiveWidgetIndex(SwitcherIndex)
  end
  local TextId = bQualified and self.TipTextIdYes[index] or self.TipTextIdNo[index]
  if TextId then
    local Text
    if index == 2 then
      Text = LocUtil.LocalizeResFormat(TextId, self.RankQualifyThreshold)
    else
      Text = LocUtil.GetLocalizeResStr(TextId)
    end
    local TextBlockYes = self.bIsOnLeft and widget.TextBlock_Yes2 or widget.TextBlock_Yes1
    local TextBlockNo = self.bIsOnLeft and widget.TextBlock_No2 or widget.TextBlock_No1
    if bQualified and TextBlockYes then
      TextBlockYes:SetText(Text)
    elseif not bQualified and TextBlockNo then
      TextBlockNo:SetText(Text)
    end
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, ArenaTrials_Item)