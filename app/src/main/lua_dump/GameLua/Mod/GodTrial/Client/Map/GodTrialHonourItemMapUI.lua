local GodTrialHonourItemMapUI = {}
local GodTrialHonorWayConfig = require("GameLua.Mod.GodTrial.Client.Config.GodTrialHonorWayConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function GodTrialHonourItemMapUI:OnInitialize()
  if self.UIRoot and self.UIRoot.TextBlock_Text then
    self.UIRoot.TextBlock_Text:SetText(LocUtil.GetLocalizeResStr(4401024))
  end
  if self.UIRoot and self.UIRoot.TextBlock_Tip1 then
    self.UIRoot.TextBlock_Tip1:SetText(LocUtil.GetLocalizeResStr(4401095))
  end
  self:InitHonorTipList()
end
function GodTrialHonourItemMapUI:RegistEvents()
  self:AddDataListener(GameplayData.GetSuperData(), "GameDataReady", self.OnGameDataReady, self)
end
function GodTrialHonourItemMapUI:OnGameDataReady()
  self:RefreshUI()
end
function GodTrialHonourItemMapUI:InitHonorTipList()
  print(bWriteLog and "GodTrialHonourItemMapUI:InitHonorTipList")
  if not self.UIRoot then
    print(bWriteLog and "GodTrialHonourItemMapUI:InitHonorTipList - UIRoot not found")
    return
  end
  if not self.LoopScrollBoxHonorTip then
    self.LoopScrollBoxHonorTip = self:InitScrollBox(self.UIRoot.LoopScrollBox_HonorTip)
    if self.LoopScrollBoxHonorTip then
      self.LoopScrollBoxHonorTip:SetRefreshItemCallback(self.OnRefreshHonorTipItem, self)
    end
  end
  self:RefreshHonorTipList()
end
function GodTrialHonourItemMapUI:RefreshUI()
  local MinimumScore = 0
  local RankQualifyThreshold = 4
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateTeamHonorFeature then
    MinimumScore = GameState.GameStateTeamHonorFeature.ArenaMinimumScore or 50
    RankQualifyThreshold = GameState.GameStateTeamHonorFeature.ArenaChoosenTeamNum or 4
  end
  if self.UIRoot and self.UIRoot.UTRichTextBlock_Tip2 then
    self.UIRoot.UTRichTextBlock_Tip2:SetText(LocUtil.LocalizeResFormat(4401098, MinimumScore, RankQualifyThreshold))
  end
  self:RefreshHonorTipList()
end
function GodTrialHonourItemMapUI:RefreshHonorTipList()
  if not self.LoopScrollBoxHonorTip then
    return
  end
  self.LoopScrollBoxHonorTip:SetData(GodTrialHonorWayConfig.Ways)
end
function GodTrialHonourItemMapUI:OnRefreshHonorTipItem(widget, index)
  if not self.LoopScrollBoxHonorTip then
    return
  end
  local Data = self.LoopScrollBoxHonorTip:GetItemData(index)
  print(bWriteLog and "GodTrialHonourItemMapUI:OnRefreshHonorTipItem index:" .. tostring(index))
  if not Data then
    return
  end
  if widget.Image_HonorTip and Data.Icon then
    widget.Image_HonorTip:SetBrushFromPathAsync(Data.Icon, false)
  end
  if widget.TextBlock_HonorTip then
    local LongTextID = Data.LongTextID or 0
    local DisplayText = ""
    if 0 < LongTextID then
      DisplayText = LocUtil.GetLocalizeResStr(LongTextID)
    end
    widget.TextBlock_HonorTip:SetText(DisplayText)
  end
end
function GodTrialHonourItemMapUI:OnClose()
  print(bWriteLog and "GodTrialHonourItemMapUI:OnClose")
  self.LoopScrollBoxHonorTip = nil
  GodTrialHonourItemMapUI.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CGodTrialHonourItemMapUI = class(ui_base, nil, GodTrialHonourItemMapUI)
return CGodTrialHonourItemMapUI