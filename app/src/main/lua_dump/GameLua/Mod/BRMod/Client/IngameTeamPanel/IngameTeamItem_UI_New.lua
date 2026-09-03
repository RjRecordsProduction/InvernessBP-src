local IngameTeamItemUI = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BlazeConfig = require("GameLua.Mod.BRMod.Gameplay.Feature.Blazing.BlazeConfig")
local audio_util = require("client.common.audio_util")
local BlazingAudio = "/Game/WwiseEvent/UI/UI_440/Play_UI_Social_Ignite.Play_UI_Social_Ignite"
local BLAZE_COLOR_ACTIVE = {
  R = 1.0,
  G = 1.0,
  B = 1.0,
  A = 1.0
}
local BLAZE_COLOR_FADEOUT = {
  R = 0.4,
  G = 0.4,
  B = 0.4,
  A = 1.0
}
local BLAZE_COLOR_NONE = {
  R = 0.4,
  G = 0.4,
  B = 0.4,
  A = 0.0
}
local BLAZE_FADE_DURATION = 1.5
local BLAZE_TICK_INTERVAL = 0.1
function IngameTeamItemUI:InitTeamItem()
  IngameTeamItemUI.__super.InitTeamItem(self)
  self._BlazingColorFrom = {
    R = 1.0,
    G = 1.0,
    B = 1.0,
    A = 0.0
  }
  self._BlazingColorTo = {
    R = 1.0,
    G = 1.0,
    B = 1.0,
    A = 0.0
  }
  self._BlazingFadeElapsed = 0
  self:RegistEventsInternal()
end
function IngameTeamItemUI:RegistEventsInternal()
  print(bWriteLog and "IngameTeamItemUI:RegistEventsInternal", self.uPlayerState and self.uPlayerState.PlayerName or "nil")
  if not slua.isValid(self.uPlayerState) or not self.uPlayerState.BlazingFeature then
    return
  end
  self:BindLuaObjEvent(self.uPlayerState.BlazingFeature, "BLAZING_DATA_CHANGED", self.RefreshBlazingData, self)
  self:RefreshBlazingData()
end
function IngameTeamItemUI:RefreshBlazingData()
  if not slua.isValid(self.uPlayerState) or not self.uPlayerState.BlazingFeature then
    return
  end
  local BlazingFeature = self.uPlayerState.BlazingFeature
  print(bWriteLog and "IngameTeamItemUI:RefreshBlazingData", self.uPlayerState.PlayerName, BlazingFeature.BlazingScore, BlazingFeature.BlazingState)
  local IsFullBlaze = BlazingFeature.BlazingState == BlazeConfig.EBlazeState.Active or BlazingFeature.BlazingState == BlazeConfig.EBlazeState.FadeOut and BlazingFeature.BlazingScore >= BlazeConfig.BLAZE_SCORE_VISUAL_FULL_THRESHOLD
  if IsFullBlaze then
    if self.TargetColor ~= BLAZE_COLOR_ACTIVE then
      audio_util.PlayAudioByActorAsync(BlazingAudio)
    end
    self.TargetColor = BLAZE_COLOR_ACTIVE
  elseif BlazingFeature.BlazingState == BlazeConfig.EBlazeState.FadeOut then
    self.TargetColor = BLAZE_COLOR_FADEOUT
  else
    self.TargetColor = BLAZE_COLOR_NONE
  end
  self:_StartBlazingColorFade(self.TargetColor)
end
function IngameTeamItemUI:_StartBlazingColorFade(TargetColor)
  if not slua.isValid(self.UIRoot) or not slua.isValid(self.UIRoot.Border_Blazing) then
    return
  end
  print(bWriteLog and "IngameTeamItemUI:_StartBlazingColorFade", self._BlazingColorFrom, self._BlazingColorTo, TargetColor)
  if self._BlazingColorTo == TargetColor then
    return
  end
  self:_StopBlazingColorFade()
  local CurColor = self.UIRoot.Border_Blazing.ContentColorAndOpacity
  self._BlazingColorFrom = {
    R = CurColor.R,
    G = CurColor.G,
    B = CurColor.B,
    A = CurColor.A
  }
  self._BlazingColorTo = TargetColor
  self._BlazingFadeElapsed = 0
  if math.abs(CurColor.R - TargetColor.R) < 0.001 and math.abs(CurColor.G - TargetColor.G) < 0.001 and math.abs(CurColor.B - TargetColor.B) < 0.001 and math.abs(CurColor.A - TargetColor.A) < 0.001 then
    return
  end
  self._BlazingFadeTimer = self:AddGameTimer(BLAZE_TICK_INTERVAL, true, function()
    self:_TickBlazingColorFade(BLAZE_TICK_INTERVAL)
  end)
end
function IngameTeamItemUI:_TickBlazingColorFade(DeltaTime)
  if not slua.isValid(self.UIRoot) or not slua.isValid(self.UIRoot.Border_Blazing) then
    self:_StopBlazingColorFade()
    return
  end
  self._BlazingFadeElapsed = self._BlazingFadeElapsed + DeltaTime
  local Alpha = self._BlazingFadeElapsed / BLAZE_FADE_DURATION
  if 1.0 < Alpha then
    Alpha = 1.0
  end
  local From = self._BlazingColorFrom
  local To = self._BlazingColorTo
  local C = From.R + (To.R - From.R) * Alpha
  local A = From.A + (To.A - From.A) * Alpha
  self.UIRoot.Border_Blazing:SetContentColorAndOpacity(FLinearColor(C, C, C, A))
  print("IngameTeamItemUI:_TickBlazingColorFade", Alpha, self.UIRoot)
  if 1.0 <= Alpha then
    self:_StopBlazingColorFade()
  end
end
function IngameTeamItemUI:_StopBlazingColorFade()
  if self._BlazingFadeTimer then
    self:RemoveGameTimer(self._BlazingFadeTimer)
    self._BlazingFadeTimer = nil
  end
end
local class = require("class")
local ui_base = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.Items.IngameTeamItem_UI_New")
return class(ui_base, nil, IngameTeamItemUI)