local TimeCountingUI = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TimeUtil = require("client.common.time_util")
function TimeCountingUI:ctor()
  print(bWriteLog and "TimeCountingUI:ctor")
  self.AreaProgressData = {}
  self.CDTime = -1
  self.bHideChasingProgress = false
end
function TimeCountingUI:OnInitialize()
  print(bWriteLog and "TimeCountingUI:OnInitialize")
  TimeCountingUI.__super.OnInitialize(self)
  self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function TimeCountingUI:OnClose()
  print(bWriteLog and "TimeCountingUI:OnClose")
  if self.bHideChasingProgress then
    self:ShowChasingProgressUI(true)
  end
  if self.CountDownTimer ~= nil then
    self:RemoveGameTimer(self.CountDownTimer)
    self.CountDownTimer = nil
  end
  TimeCountingUI.__super.OnClose(self)
end
function TimeCountingUI:RegistEvents()
  print(bWriteLog and "TimeCountingUI:RegistEvents")
  TimeCountingUI.__super.RegistEvents(self)
end
function TimeCountingUI:OnPostInitialize()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    if self.bHideChasingProgress then
      self:ShowChasingProgressUI(false)
    end
    local CountDownUIParent = MainControlBaseUI.CanvasPanel_Plan
    if slua.isValid(CountDownUIParent) then
      CountDownUIParent:AddChildToCanvas(self.UIRoot)
      self:SetAnchors(1, 0, 1, 0)
      self:SetOffsets(0, 1, 83, 24)
      self:SetAlignment(1, 0)
    end
  end
  self.CountDownTimer = self:AddGameTimer(1, true, function()
    self:OnCountDown()
  end)
end
function TimeCountingUI:OnCountDown()
  self.CDTime = -1
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local nAreaID = math.floor(uPlayerCharacter:GetAttrValue("AreaID") + 0.5)
      if self.ProgressData ~= self.AreaProgressData[nAreaID] then
        self.ProgressData = self.AreaProgressData[nAreaID]
        self.bStateChanged = true
      end
      if self.ProgressData == nil and self.AreaProgressData[0] ~= nil then
        self.ProgressData = self.AreaProgressData[0]
        self.bStateChanged = true
      end
      if slua.isValid(CGameState) and self.ProgressData ~= nil and self.ProgressData.CountingDownTimeStamp ~= 0 then
        local NowTime = CGameState:GetServerWorldTimeSeconds()
        self.CDTime = self.ProgressData.CountingDownTimeStamp - NowTime
        if self.CDTime < 0 then
          self.AreaProgressData[nAreaID] = nil
          self:CheckCloseUI()
        end
      end
    end
  end
  self:UpdateUI()
end
function TimeCountingUI:CheckCloseUI()
  local bNeedClose = true
  if self.AreaProgressData ~= nil then
    for nAreaID, ProgressData in pairs(self.AreaProgressData) do
      if ProgressData ~= nil then
        bNeedClose = false
        return
      end
    end
  end
  if bNeedClose then
    self:CloseSelf()
  end
end
function TimeCountingUI:UpdateUI()
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
    self:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    if self.bHideChasingProgress then
      self:ShowChasingProgressUI(false)
    end
  end
end
function TimeCountingUI:ShowChasingProgressUI(bShow)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    local CircleChasingUI = MainControlBaseUI.CircleChasingProgress
    if not slua.isValid(CircleChasingUI) then
      return
    end
    if bShow then
      CircleChasingUI:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    else
      CircleChasingUI:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  end
end
function TimeCountingUI:SetProgressData(ProgressData, AreaID, bForceStateChanged)
  self.AreaProgressData[AreaID] = ProgressData
  if bForceStateChanged then
    self.bStateChanged = true
  end
end
function TimeCountingUI:SetHideChasingProgress(bHide)
  self.bHideChasingProgress = bHide
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CTimeCountingUI = class(ui_base, nil, TimeCountingUI)
return CTimeCountingUI