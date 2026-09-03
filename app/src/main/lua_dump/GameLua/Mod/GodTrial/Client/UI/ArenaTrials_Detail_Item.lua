local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GodTrialHonorWayConfig = require("GameLua.Mod.GodTrial.Client.Config.GodTrialHonorWayConfig")
local ArenaTrials_Detail_Item = {}
function ArenaTrials_Detail_Item:OnInitialize()
  print(bWriteLog and "ArenaTrials_Detail_Item:OnInitialize")
  ArenaTrials_Detail_Item.__super.OnInitialize(self)
  if self.UIRoot and self.UIRoot.TextBlock_Tip then
    self.UIRoot.TextBlock_Tip:SetText(LocUtil.GetLocalizeResStr(4401024))
  end
  if self.UIRoot and self.UIRoot.TextBlock_Tip2 then
    self.UIRoot.TextBlock_Tip2:SetText(LocUtil.GetLocalizeResStr(4401095))
  end
end
function ArenaTrials_Detail_Item:RegistEvents()
  print(bWriteLog and "ArenaTrials_Detail_Item:RegistEvents")
  ArenaTrials_Detail_Item.__super.RegistEvents(self)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
  self:AddDataListener(GameplayData.GetSuperData(), "GameDataReady", self.OnGameDataReady, self)
end
function ArenaTrials_Detail_Item:OnGameDataReady()
  print(bWriteLog and "ArenaTrials_Detail_Item:OnGameDataReady")
  local PlayerState = GameplayData.GetPlayerState()
  if slua.isValid(PlayerState) then
    self:AddDataListener(PlayerState:GetSuperData(), "TeamTotalScore", self.OnTeamTotalScoreChanged, self)
  else
    print(bWriteLog and "ArenaTrials_Detail_Item:OnGameDataReady - PlayerState not found")
  end
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateTeamHonorFeature then
    self:BindLuaObjEvent(GameState.GameStateTeamHonorFeature, "OnRep_TeamTotalScoreList", self.OnTeamTotalScoreListChanged, self)
  else
    print(bWriteLog and "ArenaTrials_Detail_Item:OnGameDataReady - GameStateTeamHonorFeature not found")
  end
end
function ArenaTrials_Detail_Item:OnTeamTotalScoreChanged(_, TeamTotalScore)
  print(bWriteLog and string.format("ArenaTrials_Detail_Item:OnTeamTotalScoreChanged - TeamTotalScore=%s", tostring(TeamTotalScore)))
  self:RefreshHonorInfo()
end
function ArenaTrials_Detail_Item:OnTeamTotalScoreListChanged()
  print(bWriteLog and "ArenaTrials_Detail_Item:OnTeamTotalScoreListChanged")
  self:RefreshRankInfo()
end
function ArenaTrials_Detail_Item:OnShow()
  print(bWriteLog and "ArenaTrials_Detail_Item:OnShow")
  self:RefreshAll()
end
function ArenaTrials_Detail_Item:OnHide()
  print(bWriteLog and "ArenaTrials_Detail_Item:OnHide")
end
function ArenaTrials_Detail_Item:OnClose()
  print(bWriteLog and "ArenaTrials_Detail_Item:OnClose")
  self.LoopScrollGridWays = nil
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
  ArenaTrials_Detail_Item.__super.OnClose(self)
end
function ArenaTrials_Detail_Item:RefreshAll()
  print(bWriteLog and "ArenaTrials_Detail_Item:RefreshAll")
  self:RefreshHonorInfo()
  self:RefreshRankInfo()
  self:RefreshWaysList()
end
function ArenaTrials_Detail_Item:RefreshHonorInfo()
  print(bWriteLog and "ArenaTrials_Detail_Item:RefreshHonorInfo")
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
  if self.UIRoot and self.UIRoot.UTRichTextBlock_Num then
    local DisplayText = math.floor(CurrentScore)
    self.UIRoot.UTRichTextBlock_Num:SetText(DisplayText)
  end
  local widget = self.UIRoot and self.UIRoot.ArenaTrials_Goal02_Item
  if widget then
    local bQualified = 0 < MinimumScore and CurrentScore >= MinimumScore
    if widget.WidgetSwitcher_IsSelected then
      widget.WidgetSwitcher_IsSelected:SetActiveWidgetIndex(bQualified and 0 or 1)
    end
    if widget.UTRichTextBlock_Tip then
      widget.UTRichTextBlock_Tip:SetText(LocUtil.LocalizeResFormat(4401096, math.floor(MinimumScore)))
    end
  end
end
function ArenaTrials_Detail_Item:RefreshRankInfo()
  print(bWriteLog and "ArenaTrials_Detail_Item:RefreshRankInfo")
  local RankQualifyThreshold = 4
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateTeamHonorFeature then
    local Threshold = GameState.GameStateTeamHonorFeature.ArenaChoosenTeamNum
    if Threshold and 0 < Threshold then
      RankQualify    end
  end
  local Rank = 0
  local MyPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(MyPlayerController) then
    local MyPlayerState = MyPlayerController.PlayerState
    if slua.isValid(MyPlayerState) and MyPlayerState.TeamID and slua.isValid(GameState) and GameState.GameStateTeamHonorFeature then
      local _, RankVal = GameState.GameStateTeamHonorFeature:ClientGetTeamTotalScore(MyPlayerState.TeamID)
      if RankVal then
        Rank = math.floor(RankVal)
      end
    end
  end
  if self.UIRoot and self.UIRoot.TextBlock_Lecel then
    local RankStr = 0 < Rank and tostring(Rank) or "--"
    self.UIRoot.TextBlock_Lecel:SetText(LocUtil.LocalizeResFormat(4401022, RankStr))
  end
  local widget = self.UIRoot and self.UIRoot.ArenaTrials_Goal02_Item_1
  if widget then
    local bQualified = 0 < Rank and RankQualifyThreshold >= Rank
    if widget.WidgetSwitcher_IsSelected then
      widget.WidgetSwitcher_IsSelected:SetActiveWidgetIndex(bQualified and 0 or 1)
    end
    if widget.UTRichTextBlock_Tip then
      widget.UTRichTextBlock_Tip:SetText(LocUtil.LocalizeResFormat(4401097, RankQualifyThreshold))
    end
  end
end
function ArenaTrials_Detail_Item:RefreshWaysList()
  print(bWriteLog and "ArenaTrials_Detail_Item:RefreshWaysList")
  if not self.UIRoot or not self.UIRoot.LoopScrollGrid_Ways then
    return
  end
  if not self.LoopScrollGridWays then
    self.LoopScrollGridWays = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Ways)
    if self.LoopScrollGridWays then
      self.LoopScrollGridWays:SetRefreshItemCallback(self.OnRefreshWaysItem, self)
    end
  end
  if not self.LoopScrollGridWays then
    print(bWriteLog and "ArenaTrials_Detail_Item:RefreshWaysList - LoopScrollGridWays init failed")
    return
  end
  self.LoopScrollGridWays:SetData(GodTrialHonorWayConfig.Ways)
end
function ArenaTrials_Detail_Item:OnRefreshWaysItem(widget, index)
  if not self.LoopScrollGridWays then
    return
  end
  local Data = self.LoopScrollGridWays:GetItemData(index)
  if not Data then
    return
  end
  if widget.Image_Icon and Data.Icon then
    widget.Image_Icon:SetBrushFromPathAsync(Data.Icon, false)
  end
  if widget.TextBlock_Name then
    local TextID = Data.ShortTextID or Data.TextID or 0
    local DisplayText = ""
    if 0 < TextID then
      DisplayText = LocUtil.GetLocalizeResStr(TextID)
    end
    widget.TextBlock_Name:SetText(DisplayText)
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, ArenaTrials_Detail_Item)