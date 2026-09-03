local BattlePopTipsBase = {}
local STExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function BattlePopTipsBase:ctor()
  print(bWriteLog and "BattlePopTipsBase:ctor")
  self.LoadedDelegates = {}
  self.FullAnimationName = {}
  self.OutTimer = nil
  self.TipsValue = nil
end
function BattlePopTipsBase:OnInitialize()
  print(bWriteLog and "BattlePopTipsBase:OnInitialize")
end
function BattlePopTipsBase:OnPostInitialize()
  print(bWriteLog and "BattlePopTipsBase:OnPostInitialize")
  BattlePopTipsBase.__super.OnPostInitialize(self)
  self:InitAnimation()
  if self.PopTipsFailed then
    self:PreparePopTips(self.TipsType, self.CacheTipsValue)
  end
end
function BattlePopTipsBase:ShowTips(tipsValue)
  print(bWriteLog and "BattlePopTipsBase:ShowTips", tipsValue, self.UIRoot)
  if not self.UIRoot then
    return
  end
  Client.RequireSlateTickEveryFrame(SlateUI_ID.BATTLE_POP_TIPS_BASE)
  self.TipsValue = tipsValue
  self.ShowingTips = true
  self.BeginShowTime = GamePlayTools.GetServerWorldTimeSeconds()
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self:PreProcessExternTable(tipsValue.ExternTable)
  self:SetContentText(tipsValue.Content)
  self:SetTipsOffset(tipsValue.OffsetX, tipsValue.OffsetY)
  self:PlaySound(tipsValue.AkAudio, tipsValue.VoicePath)
  local AllShowUIWidget = tipsValue.AllShowUIWidget or self.AllShowUIWidget
  local AllHideUIWidget = tipsValue.AllHideUIWidget or self.AllHideUIWidget
  self:ChangeWidgetVisibility(AllShowUIWidget, UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:ChangeWidgetVisibility(AllHideUIWidget, UEnums.ESlateVisibility.Collapsed)
  self:PlayCustomAnimation(tipsValue.InAnimation, tipsValue.OutAnimation, tipsValue.duration, tipsValue.AnimationSpeed_f)
  self:PostProcessExternTable(tipsValue.ExternTable)
  if tipsValue.MinShowTime and tipsValue.MinShowTime > 0 then
    local ForceStopTime = math.max(tipsValue.MinShowTime, tipsValue.duration or 0) + 1
    self.OutTimer = self:AddGameTimer(ForceStopTime, false, function()
      self:ForceStopTips(tipsValue.TipsID)
    end)
  end
  print(bWriteLog and "BattlePopTipsBase:ShowTips BeginShowTime: ", self.BeginShowTime, " : ", self.TipsType)
end
function BattlePopTipsBase:ChangeWidgetVisibility(NeedChangeWidget, Visibility)
  if not self.UIRoot or not NeedChangeWidget then
    return
  end
  for key, value in pairs(NeedChangeWidget) do
    local Widget = self.UIRoot[value]
    if Widget then
      Widget:SetWidgetVisibility(Visibility)
    end
  end
end
function BattlePopTipsBase:PreparePopTips(TipsType, TipsValue)
  self.BeginShowTime = nil
  self.bIsNeedClear = nil
  if not slua.isValid(self.UIRoot) then
    self.Cache    self.    self.PopTipsFailed = true
    self.IsOuting = false
    return
  end
  self.IsOuting = false
  self.Cache  self.  self.PopTipsFailed = false
end
function BattlePopTipsBase:SetControlTextureAsync(Control, InfoTable)
  if not slua.isValid(Control) or not InfoTable then
    return
  end
  if InfoTable.TexturePath == nil or InfoTable.TexturePath == "" or InfoTable.TexturePath == "None" then
    Control:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self:CheckLoadAsyncEnd()
    return
  end
  local USTExtraUIBPUtils = import("STExtraUIUtils")
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local LoadFunction
  if InfoTable.bKeepSize then
    function LoadFunction(_InPath, _inWidget, _inCallBack)
      if slua.isValid(_inWidget) then
        USTExtraUIBPUtils.SetImageTextureAsyncWithCallbackKeepSize(_InPath, _inWidget, _inCallBack)
      end
    end
  else
    function LoadFunction(_InPath, _inWidget, _inCallBack)
      if slua.isValid(_inWidget) then
        USTExtraUIBPUtils.SetImageTextureAsyncWithCallback(_InPath, _inWidget, _inCallBack)
      end
    end
  end
  self.LoadedDelegates[Control] = true
  print(bWriteLog and "BattlePopTipsBase:SetControlTextureAsync : ", InfoTable.TexturePath, Control)
  LoadFunction(InfoTable.TexturePath, Control, slua.createDelegate(function(image)
    self.LoadedDelegates[Control] = nil
    print(bWriteLog and "BattlePopTipsBase:SetControlTextureAsync : ", InfoTable.TexturePath, image, Control)
    if Control and InfoTable.ImageSize and #InfoTable.ImageSize >= 2 then
      local BrushRef = slua.IndexReference(Control, "Brush")
      if BrushRef then
        local BrushClone = BrushRef:clone()
        BrushClone.ImageSize = FVector2D(InfoTable.ImageSize[1], InfoTable.ImageSize[2])
        Control:SetBrush(BrushClone)
      end
    elseif InfoTable.bImageOriginalSize and image then
      local BrushRef = slua.IndexReference(Control, "Brush")
      if BrushRef then
        local BrushClone = BrushRef:clone()
        if image.SourceDimension then
          BrushClone.ImageSize = FVector2D(image.SourceDimension.X, image.SourceDimension.Y)
        elseif image.ImportedSize then
          BrushClone.ImageSize = FVector2D(image.ImportedSize.X, image.ImportedSize.Y)
        end
        Control:SetBrush(BrushClone)
      end
    end
    if Control and InfoTable.Padding and #InfoTable.Padding >= 4 then
      local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(Control)
      if slot then
        slot:SetOffsets(FMargin(InfoTable.Padding[1], InfoTable.Padding[2], InfoTable.Padding[3], InfoTable.Padding[4]))
      else
        slot = WidgetLayoutLibrary.SlotAsGridSlot(Control)
        if slot then
          slot:SetPadding(FMargin(InfoTable.Padding[1], InfoTable.Padding[2], InfoTable.Padding[3], InfoTable.Padding[4]))
        end
      end
    end
    if InfoTable.bKeepSize then
      local brush = Control.Brush
      brush.DrawAs = 1
      brush.margin = FMargin(0.5, 0.5, 0.5, 0.5)
      Control:SetBrush(brush)
    else
      Control:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    self:CheckLoadAsyncEnd()
  end))
end
function BattlePopTipsBase:CheckLoadAsyncEnd()
  if self.LoadedDelegates == nil then
    self:ShowTips(self.CacheTipsValue)
  end
  for key, value in pairs(self.LoadedDelegates) do
    if slua.isValid(key) then
      print(bWriteLog and "BattlePopTipsBase:CheckLoadAsyncEnd not end", key)
      return
    end
  end
  self:ShowTips(self.CacheTipsValue)
end
function BattlePopTipsBase:PreProcessExternTable(ExternTable)
  if not ExternTable then
    return
  end
  self:ProcessCountDown(ExternTable.CountDown)
end
function BattlePopTipsBase:PostProcessExternTable(ExternTable)
  self:SetCoundDownText()
end
function BattlePopTipsBase:SetContentText(Content)
end
function BattlePopTipsBase:SetTipsOffset(OffsetX, OffsetY)
end
function BattlePopTipsBase:PlaySound(AudioPath, VoicePath)
  local audio_util = require("client.common.audio_util")
  if not audio_util then
    return
  end
  if AudioPath and AudioPath ~= "" then
    audio_util.PlayAudioAsync(AudioPath)
  end
  if VoicePath and VoicePath ~= "" then
    local BattlePopTips = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePopTips)
    if BattlePopTips then
      BattlePopTips:PlayVoice(VoicePath)
    end
  end
end
function BattlePopTipsBase:PlayCustomAnimation(InAnimationName, OutAnimationName, Duration, AnimSpeed)
  self:CheckAndPauseAnimation(self.CurInAnimation)
  self:CheckAndPauseAnimation(self.CurInOutimation)
  if InAnimationName == nil or InAnimationName == "" or self.UIRoot[InAnimationName] == nil then
    InAnimationName = self.DefaultInAnimationName
  end
  if OutAnimationName == nil or OutAnimationName == "" or self.UIRoot[OutAnimationName] == nil then
    OutAnimationName = self.DefaultOutAnimationName
  end
  self.CacheTipsValue.IsFullAnimation = self.FullAnimationName[InAnimationName]
  local UIRoot = self.UIRoot
  local InAnimation = UIRoot[InAnimationName]
  local OutAnimation = UIRoot[OutAnimationName]
  print(bWriteLog and "BattlePopTipsBase:PlayCustomAnimation", InAnimationName, OutAnimationName, Duration)
  if Duration == nil then
    UIRoot:PlayUserWidgetAnimation(InAnimation, 0, 1, 0, AnimSpeed or 1)
  else
    local speed = InAnimation:GetEndTime() / Duration
    UIRoot:PlayUserWidgetAnimation(InAnimation, 0, 1, 0, speed)
  end
  self.Cur  self.Curend
function BattlePopTipsBase:CheckIsNeedOut(HasCache, bEnterBattleResult)
  if self.IsOuting or self.BeginShowTime == nil then
    return
  end
  local TipsValue = self.CacheTipsValue
  if self.bIsNeedClear then
    self:ForceStopTips(TipsValue.TipsID)
    self.bIsNeedClear = nil
    return
  end
  if TipsValue.ResultForbid and TipsValue.ResultForbid == 1 and bEnterBattleResult then
    self:ForceStopTips(TipsValue.TipsID)
    return
  end
  self:SetCoundDownText()
  if TipsValue.MinShowTime == -1 then
    return
  end
  if self.bIsCountDown and not HasCache then
    return
  end
  local DiffTime = GamePlayTools.GetServerWorldTimeSeconds() - self.BeginShowTime
  if DiffTime < TipsValue.MinShowTime and (TipsValue.MinShowTime ~= -2 or not HasCache) then
    return
  end
  if TipsValue.IsFullAnimation and not HasCache then
    return
  end
  self:ForceStopTips(TipsValue.TipsID)
end
function BattlePopTipsBase:ForceStopTips(TipsID)
  print(bWriteLog and "BattlePopTipsBase:ForceStopTips TipsID : ", TipsID, "IsOuting :", self.IsOuting, self.CurInAnimation, self.CurOutAnimation)
  if self.IsOuting then
    return
  end
  local TipsValue = self.CacheTipsValue
  if TipsValue.TipsID ~= TipsID then
    print(bWriteLog and "BattlePopTipsBase:ForceStopTips TipsID not match", TipsValue.TipsID, TipsID)
    return
  end
  local bSuccess = false
  local UIRoot = self.UIRoot
  if TipsValue.IsFullAnimation then
    if self.CurInAnimation then
      local halfTime = self.CurInAnimation:GetEndTime() / 2
      local curTime = UIRoot:GetAnimationCurrentTime(self.CurInAnimation)
      if halfTime < curTime then
        halfTime = curTime
      end
      UIRoot:PlayUserWidgetAnimation(self.CurInAnimation, halfTime, 1, 0, 3)
      bSuccess = true
    end
  else
    if self.CurInAnimation then
      UIRoot:PauseAnimation(self.CurInAnimation)
    end
    if self.CurOutAnimation then
      UIRoot:PlayUserWidgetAnimation(self.CurOutAnimation, 0, 1, 0, 1)
      bSuccess = true
    end
  end
  self.IsOuting = true
  if not bSuccess then
    self:HandleTipsOut()
  end
end
function BattlePopTipsBase:CheckAndPauseAnimation(Animation)
  if Animation then
    self.UIRoot:PauseAnimation(Animation)
  end
end
function BattlePopTipsBase:InitAnimation()
  local UIRoot = self.UIRoot
  print(bWriteLog and "BattlePopTipsBase:InitAnimation", UIRoot and UIRoot.InAnimation or "no InAnimation", UIRoot and UIRoot.OutAnimation or "no OutAnimation")
  if UIRoot.InAnimation then
    for InAniIndex = 0, UIRoot.InAnimation:Num() - 1 do
      local AnimName = UIRoot.InAnimation:Get(InAniIndex)
      print(bWriteLog and "BattlePopTipsBase:InitAnimation In AnimName:", AnimName, InAniIndex, UIRoot[AnimName])
      if UIRoot[AnimName] then
        self:AddControlEventByControl(UIRoot[AnimName], "OnAnimationFinished", function()
          print(bWriteLog and "BattlePopTipsBase:InitAnimation In AnimName OnAnimationFinished:", AnimName)
          self:HandleTipsOut()
        end)
      end
      self.FullAnimationName[AnimName] = true
      if InAniIndex == 0 then
        self.DefaultInAnimationName = AnimName
      end
    end
  end
  if UIRoot.OutAnimation then
    for OutAniIndex = 0, UIRoot.OutAnimation:Num() - 1 do
      local AnimName = UIRoot.OutAnimation:Get(OutAniIndex)
      print(bWriteLog and "BattlePopTipsBase:InitAnimation Out AnimName:", AnimName, OutAniIndex, UIRoot[AnimName])
      if UIRoot[AnimName] then
        self:AddControlEventByControl(UIRoot[AnimName], "OnAnimationFinished", function()
          print(bWriteLog and "BattlePopTipsBase:InitAnimation Out AnimName OnAnimationFinished:", AnimName)
          self:HandleTipsOut()
        end)
      end
      self.FullAnimationName[AnimName] = true
      if OutAniIndex == 0 then
        self.DefaultOutAnimationName = AnimName
      end
    end
  end
end
function BattlePopTipsBase:HandleTipsOut()
  if not slua.isValid(self.UIRoot) then
    return
  end
  if self.CacheTipsValue and self.CacheTipsValue.OnTipsEnd then
    self.CacheTipsValue.OnTipsEnd()
  end
  Client.ResetSlateTickEveryFrame(SlateUI_ID.BATTLE_POP_TIPS_BASE)
  print(bWriteLog and "BattlePopTipsBase:HandleTipsOut")
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.ShowingTips = false
  if self.OutTimer then
    self:RemoveGameTimer(self.OutTimer)
    self.OutTimer = nil
  end
  if UIManager.UI_Config_InGame.BattlePopTips then
    local BattlePopTips = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePopTips)
    if BattlePopTips then
      BattlePopTips:HandleTipsOut(self.TipsType)
    end
  end
  self.bIsCountDown = false
  self.EndCountDownTime = nil
  self.CountDownSeconds = nil
end
function BattlePopTipsBase:ProcessCountDown(CountDownTable)
  if not CountDownTable then
    return
  end
  if CountDownTable.EndCountDownTime then
    self.EndCountDownTime = CountDownTable.EndCountDownTime
    self.bIsCountDown = true
  elseif CountDownTable.CountDownSeconds then
    self.CountDownSeconds = CountDownTable.CountDownSeconds
    self.bIsCountDown = true
  end
end
function BattlePopTipsBase:SetCoundDownText()
  local LastSeconds = 0
  if not self.bIsCountDown then
    return
  end
  if self.EndCountDownTime then
    if self.EndCountDownTime > self.BeginShowTime then
      LastSeconds = self.EndCountDownTime - GamePlayTools.GetServerWorldTimeSeconds()
    end
  elseif self.CountDownSeconds then
    local DiffTime = GamePlayTools.GetServerWorldTimeSeconds() - self.BeginShowTime
    if DiffTime < self.CountDownSeconds then
      LastSeconds = self.CountDownSeconds - DiffTime
    end
  else
    return
  end
  local IntSeconds = math.floor(LastSeconds)
  if IntSeconds < 0 then
    IntSeconds = 0
  end
  local Content = LocUtil.LocalizeResFormatByStr(self.CacheTipsValue.Content, IntSeconds)
  self:SetContentText(Content)
  if LastSeconds <= 0 then
    self:ForceStopTips(self.CacheTipsValue.TipsID)
  end
end
function BattlePopTipsBase:SetNeedClear()
  print(bWriteLog and "BattlePopTipsBase:SetNeedClear")
  self.bIsNeedClear = true
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CBattlePopTipsBase = class(UIBase, nil, BattlePopTipsBase)
return CBattlePopTipsBase