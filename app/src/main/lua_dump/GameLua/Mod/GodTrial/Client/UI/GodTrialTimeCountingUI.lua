local GodTrialTimeCountingUI = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
local TimeUtil = require("client.common.time_util")
function GodTrialTimeCountingUI:ctor()
  self.bOnArenaIsland = false
end
function GodTrialTimeCountingUI:OnInitialize()
  GodTrialTimeCountingUI.__super.OnInitialize(self)
end
function GodTrialTimeCountingUI:RegistEvents()
  GodTrialTimeCountingUI.__super.RegistEvents(self)
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "GameDataReady", function()
    self:_OnGameDataReady()
  end)
end
function GodTrialTimeCountingUI:_OnGameDataReady()
  print(bWriteLog and "GodTrialTimeCountingUI:_OnGameDataReady")
  self.bOnArenaIsland = false
  local PlayerState = GameplayData.GetPlayerState()
  if slua.isValid(PlayerState) then
    self:AddDataListener(PlayerState:GetSuperData(), "PlayerHonorState", self.OnPlayerHonorStateChanged, self)
  end
end
function GodTrialTimeCountingUI:OnClose()
  GodTrialTimeCountingUI.__super.OnClose(self)
end
function GodTrialTimeCountingUI:OnPlayerHonorStateChanged(_, PlayerHonorState)
  local bOnIsland = PlayerHonorState ~= nil and PlayerHonorState >= Enum.EHonorArenaState.GoldenCollecting and PlayerHonorState <= Enum.EHonorArenaState.FlameChariotRunning
  if self.bOnArenaIsland == bOnIsland then
    return
  end
  self.bOnArenaIsland = bOnIsland
  print(bWriteLog and string.format("GodTrialTimeCountingUI:_OnPlayerHonorStateChanged - bOnArenaIsland=%s", tostring(bOnIsland)))
end
function GodTrialTimeCountingUI:UpdateUI()
  if self.CDTime < 0 then
    self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    if self.bHideChasingProgress then
      self:ShowChasingProgressUI(true)
    end
  else
    if self.bStateChanged then
      if self.ProgressData.ImgPath ~= nil then
        local USTExtraUIUtils = import("STExtraUIUtils")
        USTExtraUIUtils.SetImageTextureAsync(self.ProgressData.ImgPath, self.UIRoot.Image_1)
      end
      if self.ProgressData.ImgColor ~= nil then
        self.UIRoot.Image_1:SetColorAndOpacity(FLinearColor.FromSRGBColor(FColor.FromHex(self.ProgressData.ImgColor)))
      end
      self.bStateChanged = false
    end
    if self.ProgressData.HighLightCD ~= nil and self.ProgressData.HighLightColor ~= nil and self.CDTime < self.ProgressData.HighLightCD then
      if self.ProgressData.ImgColor == nil then
        self.UIRoot.Image_1:SetColorAndOpacity(FLinearColor.FromSRGBColor(FColor.FromHex(self.ProgressData.HighLightColor)))
      end
      self.UIRoot.CountingDownText:SetColorAndOpacity(FSlateColor(FLinearColor.FromSRGBColor(FColor.FromHex(self.ProgressData.HighLightColor))))
      self.ProgressData.HighLightCD = nil
    end
    self.UIRoot.CountingDownText:SetText(TimeUtil.FormatCountDownTime_MS(self.CDTime, true))
    if not self.bOnArenaIsland then
      self:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
      if self.bHideChasingProgress then
        self:ShowChasingProgressUI(false)
      end
    end
  end
end
local class = require("class")
local CTimeCountingUI = require("GameLua.Mod.Library.Client.UI.TimeCountingUI")
local CGodTrialTimeCountingUI = class(CTimeCountingUI, nil, GodTrialTimeCountingUI)
return CGodTrialTimeCountingUI