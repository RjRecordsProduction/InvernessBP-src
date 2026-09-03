local BattlePopTips = {
  CONSNT_NORMAL_TYPE = 1,
  CONSNT_TEXT_TYPE = 2,
  CONSNT_BOTTOM_KILL_TYPE = 10,
  CONSNT_MAX_CACHE_NUM = 4,
  DEFAULT_MIN_SHOW_TIME = 0.5,
  DEFAULT_BOTTOM_TIPS_MIN_SHOW_TIME = 0.6,
  TipsCache = {},
  ShowingTips = {},
  TickRate = 0.1,
  VoiceID = nil,
  VoiceDelegate = nil
}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function BattlePopTips:ctor()
  self.TipsWhiteList = {}
end
function BattlePopTips:OnPostInitialize()
  BattlePopTips.__super.OnPostInitialize(self)
  self.ShowingTips = {}
  self.TipsCache = {}
  self.TipsWhiteList = {}
  self.UIRoot.BottomKillTips_Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self:InitAnimationFinishCallBack()
  local killTipsClass = require(GamePlayTools.GetModPath(true, "Client.BattlePopTipsUI.BattlePopBottomKillTips", true))
  self.BottomKillTipsUICtrl = killTipsClass()
  self.BottomKillTipsUICtrl:OnInitialize(self.UIRoot)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SHOW_SETTING, self.OnShowSetting, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.OnEnterBattleResult, self)
  local level = Client.GetExactDeviceLevel()
  if level <= 0 then
    self.TickRate = 0.1
  else
    self.TickRate = 0.05
  end
  self.ReplayNotShowTips = {
    [10233] = true,
    [10234] = true,
    [10235] = true,
    [10236] = true,
    [10237] = true,
    [10238] = true,
    [10147] = true,
    [6310044] = true,
    [6350051] = true,
    [3800044] = true,
    [11331] = true,
    [4300042] = true,
    [4300043] = true,
    [4300036] = true,
    [4300037] = true,
    [4300038] = true
  }
  self.HawkEyeAndCompletePlaybackNotShowTips = {
    [40019] = true,
    [40039] = true,
    [40048] = true,
    [40049] = true,
    [11585] = true,
    [11592] = true,
    [11593] = true,
    [11594] = true,
    [11595] = true,
    [11596] = true,
    [11597] = true,
    [11598] = true,
    [6310044] = true,
    [112087] = true,
    [6330004] = true,
    [6330037] = true,
    [6330008] = true,
    [3400041] = true,
    [6350051] = true,
    [370001] = true,
    [3800044] = true,
    [4100011] = true,
    [4200029] = true,
    [11331] = true,
    [4300042] = true,
    [4300043] = true,
    [4300036] = true,
    [4300037] = true,
    [4300038] = true,
    [4101045] = true,
    [4101046] = true
  }
  self.ObserverNotShowTips = {
    [11800] = true,
    [11801] = true,
    [11802] = true,
    [11803] = true,
    [11804] = true,
    [11805] = true,
    [12090] = true,
    [12091] = true,
    [12092] = true,
    [12093] = true,
    [12094] = true,
    [12095] = true,
    [12096] = true,
    [12097] = true,
    [12098] = true,
    [12099] = true,
    [12100] = true,
    [12101] = true,
    [10233] = true,
    [10234] = true,
    [10235] = true,
    [10236] = true,
    [10237] = true,
    [10238] = true,
    [11331] = true
  }
  self.TickTimer = nil
  self.ShowingTipsWidget = {}
  self.LoadAsyncTimeoutTimers = {}
end
function BattlePopTips:OnClose()
  self.ShowingTips = {}
  self.TipsCache = {}
  if self.BottomKillTipsUICtrl then
    self.BottomKillTipsUICtrl:OnDestroy()
    self.BottomKillTipsUICtrl = nil
  end
  if self.VoiceDelegate ~= nil then
    local util = require("client.slua_ui_framework.util")
    util.ClearAssetAsync(self.VoiceDelegate)
    self.VoiceDelegate = nil
  end
  if self.ShowingTipsWidget then
    for key, Widget in pairs(self.ShowingTipsWidget) do
      if Widget then
        Widget:CloseSelf()
      end
    end
  end
  self.ShowingTipsWidget = {}
  if self.LoadAsyncTimeoutTimers then
    for tipsType, timerHandle in pairs(self.LoadAsyncTimeoutTimers) do
      if timerHandle then
        self:RemoveGameTimer(timerHandle)
      end
    end
    self.LoadAsyncTimeoutTimers = {}
  end
end
function BattlePopTips:StartTipsLimitationWithWhiteList(whiteList)
  log(bWriteLog and "[DeanJYT] BattlePopTips:StartTipsLimitationWithWhiteList")
  log_tree("[DeanJYT] BattlePopTips:StartTipsLimitationWithWhiteList whiteList = ", whiteList)
  self.bIsTipsLimitaionOn = true
  for _, v in pairs(whiteList) do
    self.TipsWhiteList[v] = true
  end
end
function BattlePopTips:StopTipsLimitation()
  log(bWriteLog and "[DeanJYT] BattlePopTips:StopTipsLimitation")
  self.bIsTipsLimitaionOn = false
  self.TipsWhiteList = {}
end
function BattlePopTips:InitAnimationFinishCallBack()
  self.AnimationBeginOutTime = {}
  local InitAnimation = function(animationArray, tipType)
    for index = 0, animationArray:Num() - 1 do
      local animName = animationArray:Get(index)
      if self.UIRoot[animName] then
        self:AddControlEventByControl(self.UIRoot[animName], "OnAnimationFinished", function()
          self:HandleTipsOut(tipType, animName)
        end)
        do
          local outTime = self.UIRoot.InAnimationOutTime:Get(animName)
          if outTime and 0 < outTime then
            self.AnimationBeginOutTime[animName] = outTime
          end
        end
      end
    end
    if 0 < animationArray:Num() then
      return animationArray:Get(0)
    else
      log(bWriteLog and "BattlePopTips:InitAnimationFinishCallBack null animation")
      return ""
    end
  end
  InitAnimation(self.UIRoot.KillTipsInAnimations, self.CONSNT_BOTTOM_KILL_TYPE)
  InitAnimation(self.UIRoot.KillTipsOutAnimations, self.CONSNT_BOTTOM_KILL_TYPE)
end
function BattlePopTips:OnTickWidget()
  self.HasShowingTips = false
  self:CheckHasKillCachce()
  if self.ShowingTipsWidget then
    for TipsType, TipsWidget in pairs(self.ShowingTipsWidget) do
      local CacheTable = self.TipsCache[TipsType]
      local HasCache = CacheTable ~= nil and 0 < #CacheTable
      if slua.isValid(TipsWidget.UIRoot) then
        TipsWidget:CheckIsNeedOut(HasCache, self.EnterBattleResult)
        self.HasShowingTips = true
      elseif TipsWidget.UIRoot then
        self.HasShowingTips = true
      end
    end
  end
  if not self.HasShowingTips then
    self:RemoveGameTimer(self.TickTimer)
    self.TickTimer = nil
  end
end
function BattlePopTips:CheckHasKillCachce()
  local TipsType = self.CONSNT_BOTTOM_KILL_TYPE
  local CacheTable = self.TipsCache[TipsType]
  local HasCache = CacheTable ~= nil and 0 < #CacheTable
  if not HasCache then
    return
  end
  if self.ShowingTips and self.ShowingTips[TipsType] then
    self.HasShowingTips = true
    local currentShowingTips = self.ShowingTips[TipsType]
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local CurrentTime = UKismetSystemLibrary.GetGameTimeInSeconds(self.UIRoot)
    if currentShowingTips.IsOuting ~= true and currentShowingTips.ShowBeginTime and CurrentTime - currentShowingTips.ShowBeginTime >= currentShowingTips.MinShowTime then
      if slua.isValid(self.UIRoot) then
        if slua.isValid(currentShowingTips.Animation) then
          self.UIRoot:PauseAnimation(currentShowingTips.Animation)
        end
        if slua.isValid(self.UIRoot[currentShowingTips.OutAnimation]) then
          self:PlayUserWidgetAnimation(self.UIRoot[currentShowingTips.OutAnimation], 0, 1, 0, 3)
        end
      end
      currentShowingTips.IsOuting = true
    end
  end
end
function BattlePopTips:BattleGeneralTipWithContent(tipsID, tipsConfig, content, ExternTable)
  if tipsConfig then
    local currentTips = {}
    currentTips.AkAudio = tipsConfig.AkAudio
    currentTips.VoicePath = tipsConfig.VoicePath
    currentTips.Content = content
    currentTips.TipsID = tipsID
    currentTips.IconPath = tipsConfig.IconPath
    currentTips.BgImagePath = tipsConfig.BgImagePath
    local SetDefaultValue = function(key, defaultValue)
      if tipsConfig[key] and tipsConfig[key] ~= "" then
        currentTips[key] = tipsConfig[key]
      else
        currentTips[key] = defaultValue
      end
    end
    SetDefaultValue("MinShowTime", self.DEFAULT_MIN_SHOW_TIME)
    SetDefaultValue("AnimationSpeed_f", 1)
    SetDefaultValue("OffsetX", 0)
    SetDefaultValue("OffsetY", 0)
    SetDefaultValue("IsUnique", 0)
    SetDefaultValue("IconSize", "")
    SetDefaultValue("SubType", 0)
    SetDefaultValue("IconPath", "")
    SetDefaultValue("BgImagePath", "")
    SetDefaultValue("InAnimation", "")
    SetDefaultValue("OutAnimation", "")
    SetDefaultValue("ResultForbid", 0)
    if tipsConfig.BgImagePadding and tipsConfig.BgImagePadding ~= "" then
      currentTips.BgImagePadding = load("return " .. tipsConfig.BgImagePadding)()
    end
    if tipsConfig.BgImageSize and tipsConfig.BgImageSize ~= "" then
      currentTips.BgImageSize = load("return " .. tipsConfig.BgImageSize)()
    end
    currentTips.    if currentTips.ResultForbid and currentTips.ResultForbid == 1 and self.EnterBattleResult then
      return
    end
    self:CheckShowTips(tipsConfig.type, currentTips)
  end
end
function BattlePopTips:TryGetParam(tipsID, ...)
  local ParamArray = {}
  local tipsConfig = CDataTable.GetTableData("BattleGeneralTip", tipsID)
  if tipsConfig == nil then
    return ParamArray
  end
  ParamArray = table.pack(...)
  return ParamArray
end
function BattlePopTips:BattleGeneralTipWithExternTable(tipsID, ExternTable)
  local tipsConfig = CDataTable.GetTableData("BattleGeneralTip", tipsID)
  if tipsConfig then
    self:BattleGeneralTipWithContent(tipsID, tipsConfig, LocUtil.LocalizeResFormat(tipsConfig.TextID), ExternTable)
  else
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_COMMON_BATTLE_TIPS_EXTERNTABLE, tipsID, ExternTable)
end
function BattlePopTips:BattleGeneralTip(tipsID, ...)
  local tipsConfig = CDataTable.GetTableData("BattleGeneralTip", tipsID)
  if tipsConfig then
    local ParamArray = self:TryGetParam(tipsID, ...)
    self:BattleGeneralTipWithContent(tipsID, tipsConfig, DataMgr.GetFormatMsgByIDForBattleText(tipsConfig.TextID, table.unpack(ParamArray)))
  else
  end
end
function BattlePopTips:BattleGeneralTipWithCustomTxt(tipsID, BattleGeneralTipWithCustomTxt)
  local tipsConfig = CDataTable.GetTableData("BattleGeneralTip", tipsID)
  if tipsConfig then
    BattleGeneralTipWithCustomTxt = BattleGeneralTipWithCustomTxt or ""
    self:BattleGeneralTipWithContent(tipsID, tipsConfig, BattleGeneralTipWithCustomTxt)
  else
  end
end
function BattlePopTips:BattleGeneralSAPTip(tipsID, ...)
  local tipsConfig = CDataTable.GetTableData("BattleGeneralTip", tipsID)
  if tipsConfig then
    local ParamArray = self:TryGetParam(tipsID, ...)
    self:BattleGeneralTipWithContent(tipsID, tipsConfig, DataMgr.GetFormatMsgByIDForBattleTextWithSAP(tipsConfig.TextID, table.unpack(ParamArray)))
  else
  end
end
function BattlePopTips:BattleStopGeneralTip(tipsID)
  if tipsID == nil then
    return
  end
  local tipsConfig = CDataTable.GetTableData("BattleGeneralTip", tipsID)
  if tipsID ~= 0 and tipsConfig == nil then
    return
  end
  if tipsID == 0 then
    self:ClearTips()
  elseif self.ShowingTipsWidget and self.ShowingTipsWidget[tipsConfig.Type] then
    local CurTipsWidget = self.ShowingTipsWidget[tipsConfig.Type]
    if CurTipsWidget then
      CurTipsWidget:ForceStopTips(tipsID)
    end
  elseif self.TipsCache and self.TipsCache[tipsConfig.Type] then
    local tCache = self.TipsCache[tipsConfig.Type]
    local index = #tCache
    while 0 < index and tCache[index] do
      if tCache[index].TipsID and tCache[index].TipsID == tipsID then
        table.remove(self.TipsCache, index)
      end
      index = index - 1
    end
  end
end
function BattlePopTips:ShowGameWarning(textID, animationSpeed, param1, param2)
  local currentTips = {}
  currentTips.Content = DataMgr.GetFormatMsgByIDForBattleText(textID, param1, param2)
  currentTips.InAnimation = "Tips1InAnimation3"
  currentTips.OutAnimation = self.DEFAULT_NORMAL_OUT_ANIM
  currentTips.MinShowTime = self.DEFAULT_MIN_SHOW_TIME
  currentTips.Priority = 8
  currentTips.AnimationSpeed_f = animationSpeed or 1
  self:CheckShowTips(self.CONSNT_NORMAL_TYPE, currentTips)
end
function BattlePopTips:ShowNormalTips(tipsContent, inAnimationType, controlTime, tipsValue)
  print("BattlePopTips.ShowNormalTips", tipsContent, inAnimationType, controlTime, tipsValue)
  if tipsContent == nil then
    return
  end
  local currentTips = {}
  currentTips.MinShowTime = self.DEFAULT_MIN_SHOW_TIME
  currentTips.OutAnimation = self.DEFAULT_TEXT_OUT_ANIM
  currentTips.Content = tipsContent
  currentTips.duration = controlTime
  currentTips.AnimationSpeed_f = 1
  currentTips.Priority = 0
  currentTips.BgImagePath = self.DEFAULT_TEXT_BG_IMAGE
  if inAnimationType then
    currentTips.InAnimation = inAnimationType
  else
    currentTips.InAnimation = self.DEFAULT_TEXT_IN_ANIM
  end
  if tipsValue ~= nil then
    currentTips.MinShowTime = tipsValue.MinShowTime or currentTips.MinShowTime
    currentTips.OutAnimation = tipsValue.OutAnimation or currentTips.OutAnimation
    currentTips.Content = tipsValue.Content or currentTips.Content
    currentTips.duration = tipsValue.duration or currentTips.duration
    currentTips.AnimationSpeed_f = tipsValue.AnimationSpeed_f or currentTips.AnimationSpeed_f
    currentTips.Priority = tipsValue.Priority or currentTips.Priority
    currentTips.BgImagePath = tipsValue.BgImagePath or currentTips.BgImagePath
    currentTips.AllShowUIWidget = tipsValue.AllShowUIWidget or currentTips.AllShowUIWidget
    currentTips.AllHideUIWidget = tipsValue.AllHideUIWidget or currentTips.AllHideUIWidget
    currentTips.InAnimation = tipsValue.InAnimation or currentTips.InAnimation
    currentTips.TipsTextBlockStr = tipsValue.TipsTextBlockStr or currentTips.TipsTextBlockStr
    currentTips.OnTipsEnd = tipsValue.OnTipsEnd or nil
    currentTips.OffsetX = tipsValue.OffsetX or currentTips.OffsetX
    currentTips.OffsetY = tipsValue.OffsetY or currentTips.OffsetY
    currentTips.VoicePath = tipsValue.VoicePath or currentTips.VoicePath
    currentTips.AkAudio = tipsValue.AkAudio or currentTips.AkAudio
    if tipsValue.BgImagePadding and tipsValue.BgImagePadding ~= "" then
      currentTips.BgImagePadding = load("return " .. tipsValue.BgImagePadding)()
    end
    currentTips.IconPath = tipsValue.IconPath or currentTips.IconPath
  end
  self:CheckShowTips(self.CONSNT_TEXT_TYPE, currentTips)
  self:InvalidateLayoutCache()
end
function BattlePopTips:ShowNormalTipsByTextID(textID, param1, param2, controlTime)
  if self.bIsTipsLimitaionOn and not self.TipsWhiteList[textID] then
    log(bWriteLog and "[DeanJYT] BattlePopTips:ShowNormalTipsByTextID tips limited, textID = " .. tostring(textID))
    return
  end
  local content = DataMgr.GetFormatMsgByIDForBattleText(textID, param1, param2)
  print("BattlePopTips.ShowNormalTipsByTextID:" .. tostring(textID), content)
  if content then
    if content == "" then
      content = tostring(textID)
    end
    self:ShowNormalTips(content, nil, controlTime)
  end
end
function BattlePopTips:ShowNormalTipsByTextIDAndTipsValue(textID, param1, param2, controlTime, tipsValue)
  if self.bIsTipsLimitaionOn and not self.TipsWhiteList[textID] then
    log(bWriteLog and "[DeanJYT] BattlePopTips:ShowNormalTipsByTextIDAndTipsValue tips limited, textID = " .. tostring(textID))
    return
  end
  local content = DataMgr.GetFormatMsgByIDForBattleText(textID, param1, param2)
  if content then
    self:ShowNormalTips(content, nil, controlTime, tipsValue)
  end
end
function BattlePopTips:ShowNormalTipsByTextIDAndParams(textID, paramTable, controlTime)
  if self.bIsTipsLimitaionOn and not self.TipsWhiteList[textID] then
    log(bWriteLog and "[DeanJYT] BattlePopTips:ShowNormalTipsByTextIDAndParams tips limited, textID = " .. tostring(textID))
    return
  end
  local content = DataMgr.GetFormatMsgByIDForBattleText(textID, table.unpack(paramTable))
  if content then
    self:ShowNormalTips(content, nil, controlTime)
  end
end
function BattlePopTips:ShowNormalSAPTipsByTextIDAndParams(textID, paramTable, controlTime)
  if self.bIsTipsLimitaionOn and not self.TipsWhiteList[textID] then
    log(bWriteLog and "[DeanJYT] BattlePopTips:ShowNormalSAPTipsByTextIDAndParams tips limited, textID = " .. tostring(textID))
    return
  end
  local content = DataMgr.GetFormatMsgByIDForBattleTextWithSAP(textID, table.unpack(paramTable))
  if content then
    self:ShowNormalTips(content, nil, controlTime)
  end
end
function BattlePopTips:ShowNormalSAPTipsByTextID(textID, param1, param2, controlTime)
  if self.bIsTipsLimitaionOn and not self.TipsWhiteList[textID] then
    log(bWriteLog and "[DeanJYT] BattlePopTips:ShowNormalTipsByTextID tips limited, textID = " .. tostring(textID))
    return
  end
  local content = DataMgr.GetFormatMsgByIDForBattleTextWithSAP(textID, param1, param2)
  if content then
    self:ShowNormalTips(content, nil, controlTime)
  end
end
function BattlePopTips:ShowItemTipsByTextID(textID, param1, param2, param3, controlTime)
  local ItemID = tonumber(param1)
  local ItemData = CDataTable.GetTableData("Item", ItemID)
  local ItemName = ItemData and ItemData.ItemName or ""
  local content = DataMgr.GetFormatMsgByIDForBattleText(textID, ItemName, param2, param3)
  if content then
    self:ShowNormalTips(content, nil, controlTime)
  end
end
function BattlePopTips:ShowItemTipsByTextID2(textID, param1, param2, controlTime)
  local ItemID = tonumber(param2)
  local ItemData = CDataTable.GetTableData("Item", ItemID)
  local ItemName = ItemData and ItemData.ItemName or ""
  local content = DataMgr.GetFormatMsgByIDForBattleText(textID, param1, ItemName)
  if content then
    self:ShowNormalTips(content, nil, controlTime)
  end
end
function BattlePopTips:ShowItemTipsWithAllTextID(textID, param1, param2, param3, controlTime)
  local ItemID = tonumber(param1)
  local ItemData = CDataTable.GetTableData("Item", ItemID)
  local ItemName = ItemData and ItemData.ItemName or ""
  local sText2 = LocUtil.GetLocalizeResStr(tonumber(param2))
  local sText3 = LocUtil.GetLocalizeResStr(tonumber(param3))
  local content = DataMgr.GetFormatMsgByIDForBattleText(textID, ItemName, sText2, sText3)
  if content then
    self:ShowNormalTips(content, nil, controlTime)
  end
end
function BattlePopTips:ShowTipsByAllTextID(textID, param1, param2, param3, controlTime)
  local sText1 = LocUtil.GetLocalizeResStr(tonumber(param1))
  local sText2 = LocUtil.GetLocalizeResStr(tonumber(param2))
  local sText3 = LocUtil.GetLocalizeResStr(tonumber(param3))
  local content = DataMgr.GetFormatMsgByIDForBattleText(textID, sText1, sText2, sText3)
  if content then
    self:ShowNormalTips(content, nil, controlTime)
  end
end
function BattlePopTips:ShowNormalTipsByTextIDAlias(textID, param1, param2)
  local AliasName = LocUtil.GetLocalizeResStr(param1)
  AliasName = AliasName or ""
  local content = DataMgr.GetFormatMsgByIDForBattleText(textID, AliasName, param2)
  print(bWriteLog and "ShowNormalTipsByTextIDAlias", content)
  self:ShowNormalTips(content)
end
function BattlePopTips:ShowBottomKillTips(messageData)
  print(bWriteLog and "BattlePopTips:ShowBottomKillTips", messageData and messageData.FullMsg or "no message")
  local currentTips = {}
  currentTips.Content = messageData.FullMsg
  if messageData.bHideKillIcon then
    currentTips.InAnimation = "KillTypeTipsInAnimation2"
  else
    currentTips.InAnimation = "KillTypeTipsInAnimation"
  end
  currentTips.OutAnimation = "KillTypeTipsOutAnimation"
  currentTips.MinShowTime = self.DEFAULT_BOTTOM_TIPS_MIN_SHOW_TIME
  currentTips.Priority = 0
  currentTips.AnimationSpeed_f = 1
  currentTips.KillMessageData = messageData
  self:CheckShowTips(self.CONSNT_BOTTOM_KILL_TYPE, currentTips)
end
function BattlePopTips:CheckShowTips(tipsType, tipsValue)
  if tipsValue == nil then
    print(bWriteLog and "BattlePopTips:CheckShowTips tipsValue is nil")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  local TipsID = tipsValue.TipsID
  if slua.isValid(uPlayerController) and uPlayerController:IsDemoPlaySpectator() and TipsID and self.ReplayNotShowTips[TipsID] then
    print(bWriteLog and "BattlePopTips:CheckShowTips is demo play spectator")
    return
  end
  local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
  if slua.isValid(uPlayerController) and uPlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_HawkEye | ESpectatorReplayFlag.ESpectatorReplayFlag_CompletePlayback) and TipsID and self.HawkEyeAndCompletePlaybackNotShowTips[TipsID] then
    print(bWriteLog and "BattlePopTips:CheckShowTips is hawk eye or complete playback")
    return
  end
  if slua.isValid(uPlayerController) and uPlayerController.ObserverFlags > 0 and TipsID and self.ObserverNotShowTips[TipsID] then
    print(bWriteLog and "BattlePopTips:CheckShowTips is observer")
    return
  end
  if self.Disable then
    print(bWriteLog and "BattlePopTips:CheckShowTips self.Disable == true")
    return
  end
  if (tipsValue.Content == nil or tipsValue.Content == "") and Client.IsShipping() then
    print(bWriteLog and "BattlePopTips:CheckShowTips content is nil")
    return
  end
  if not self.TickTimer then
    self.TickTimer = self:AddGameTimer(self.TickRate, true, function()
      self:OnTickWidget()
    end)
  end
  print(bWriteLog and "BattlePopTips:PreparePopTips:CheckShowTips id:" .. tostring(tipsValue.TipsID) .. " Content:" .. tipsValue.Content .. " tipsType:" .. tostring(tipsType))
  if self.ShowingTips and self.ShowingTips[tipsType] and self.ShowingTips[tipsType].MinShowTime ~= -2 then
    print(bWriteLog and "BattlePopTips:PreparePopTips:CheckShowTips cache tips")
    if self.TipsCache[tipsType] == nil then
      self.TipsCache[tipsType] = {}
    end
    if tipsValue.MinShowTime == -1 and tipsValue.TipsID or tipsValue.IsUnique and tipsValue.IsUnique == 1 then
      if self.ShowingTips[tipsType].TipsID and self.ShowingTips[tipsType].TipsID == tipsValue.TipsID then
        return
      end
      for index = 1, #self.TipsCache[tipsType] do
        if self.TipsCache[tipsType].TipsID and self.TipsCache[tipsType].TipsID == tipsValue.TipsID then
          return
        end
      end
    end
    if tipsValue.Priority and -1 == tipsValue.Priority then
      local CurShowingWidget = self.ShowingTipsWidget[tipsType]
      local CurShowingTipsInfo = self.ShowingTips[tipsType]
      if CurShowingTipsInfo and CurShowingWidget then
        local TipsID = CurShowingTipsInfo.TipsID
        CurShowingWidget:ForceStopTips(TipsID)
      end
    end
    if #self.TipsCache[tipsType] > self.CONSNT_MAX_CACHE_NUM - 1 then
      local minTime
      local needRemoveIndex = 1
      for index = 1, #self.TipsCache[tipsType] do
        if minTime == nil then
          minTime = self.TipsCache[tipsType][index].InCacheTime
          needRemoveIndex = index
        elseif minTime < self.TipsCache[tipsType][index].InCacheTime then
          minTime = self.TipsCache[tipsType][index].InCacheTime
          needRemoveIndex = index
        end
      end
      table.remove(self.TipsCache[tipsType], needRemoveIndex)
    end
    table.insert(self.TipsCache[tipsType], #self.TipsCache[tipsType] + 1, tipsValue)
    tipsValue.InCacheTime = os.time()
    tipsValue.Priority = tipsValue.Priority or 0
    table.sort(self.TipsCache[tipsType], function(a, b)
      if a.Priority == b.Priority then
        return a.InCacheTime < b.InCacheTime
      else
        return a.Priority < b.Priority
      end
    end)
  else
    print(bWriteLog and "BattlePopTips:PreparePopTips:CheckShowTips show tips")
    if self.ShowingTips and self.ShowingTips[tipsType] and self.ShowingTips[tipsType].MinShowTime == -2 and self.ShowingTips[tipsType].ShowBeginTime ~= nil then
      local CurShowingWidget = self.ShowingTipsWidget[tipsType]
      if CurShowingWidget then
        CurShowingWidget:HandleTipsOut()
      end
    end
    self:PreparePopTips(tipsType, tipsValue)
  end
end
function BattlePopTips:PreparePopTips(tipsType, tipsValue)
  if not self.TickTimer then
    self.TickTimer = self:AddGameTimer(self.TickRate, true, function()
      self:OnTickWidget()
    end)
  end
  if tipsType == self.CONSNT_BOTTOM_KILL_TYPE then
    self:PopKillTips(tipsType, tipsValue)
  else
    if self.EnterBattleResult and tipsValue.ResultForbid and tipsValue.ResultForbid == 1 then
      self:PopNextTips(tipsType)
      return
    end
    local BattlePopTipsConfig = GamePlayTools.GetCurrentConfig("BattlePopTipsConfig")
    if not BattlePopTipsConfig then
      print(bWriteLog and "BattlePopTips:PreparePopTips FAILED Case None Config")
      return
    end
    if tipsValue.SubType == nil then
      tipsValue.SubType = 0
    end
    if not BattlePopTipsConfig[tipsType] or not BattlePopTipsConfig[tipsType][tipsValue.SubType] then
      print(bWriteLog and "BattlePopTips:PreparePopTips FAILED tipsType : " .. tostring(tipsValue) .. " SubType: " .. tostring(tipsValue.SubType))
      return
    end
    local ModuleName = BattlePopTipsConfig[tipsType][tipsValue.SubType]
    local TipsUI = UIManager.GetUI(UIManager.UI_Config_InGame[ModuleName])
    TipsUI = TipsUI or UIManager.ShowUI(UIManager.UI_Config_InGame[ModuleName])
    if TipsUI then
      TipsUI:PreparePopTips(tipsType, tipsValue)
      if self.ShowingTipsWidget[tipsType] then
        self.ShowingTipsWidget[tipsType]:HandleTipsOut()
      end
      self.ShowingTipsWidget[tipsType] = TipsUI
      print(bWriteLog and "BattlePopTips:PreparePopTips SUCCESS tipsType : " .. tostring(tipsType) .. " SubType: " .. tostring(tipsValue.SubType))
      self.ShowingTips[tipsType] = tipsValue
      self:StartLoadAsyncTimeoutGuard(tipsType)
    end
  end
end
function BattlePopTips:StartLoadAsyncTimeoutGuard(tipsType)
  if self.LoadAsyncTimeoutTimers[tipsType] then
    self:RemoveGameTimer(self.LoadAsyncTimeoutTimers[tipsType])
    self.LoadAsyncTimeoutTimers[tipsType] = nil
  end
  local LoadAsyncTimeoutSeconds = 5
  self.LoadAsyncTimeoutTimers[tipsType] = self:AddGameTimer(LoadAsyncTimeoutSeconds, false, function()
    self.LoadAsyncTimeoutTimers[tipsType] = nil
    local TipsWidget = self.ShowingTipsWidget[tipsType]
    local isStuck = TipsWidget and (not slua.isValid(TipsWidget.UIRoot) or not TipsWidget.ShowingTips)
    if isStuck then
      print(bWriteLog and "BattlePopTips:StartLoadAsyncTimeoutGuard timeout, force skip tipsType:" .. tostring(tipsType))
      self:ForceSkipCurrentTips(tipsType)
    end
  end)
end
function BattlePopTips:ForceSkipCurrentTips(tipsType)
  print(bWriteLog and "BattlePopTips:ForceSkipCurrentTips tipsType:" .. tostring(tipsType))
  local TipsWidget = self.ShowingTipsWidget[tipsType]
  if TipsWidget then
    if TipsWidget.LoadedDelegates then
      TipsWidget.LoadedDelegates = {}
    end
    TipsWidget.ShowingTips = false
    TipsWidget.IsOuting = false
    TipsWidget:HandleTipsOut()
  end
end
function BattlePopTips:PopNextTips(tipsType)
  if self.TipsCache and self.TipsCache[tipsType] and #self.TipsCache[tipsType] > 0 then
    local TipsValue = self.TipsCache[tipsType][1]
    table.remove(self.TipsCache[tipsType], 1)
    self:PreparePopTips(tipsType, TipsValue)
  end
end
function BattlePopTips:PopKillTips(tipsType, tipsValue)
  if not self.TickTimer then
    self.TickTimer = self:AddGameTimer(self.TickRate, true, function()
      self:OnTickWidget()
    end)
  end
  print(bWriteLog and "BattlePopTips.PopKillTips:" .. tipsValue.Content)
  if self.BottomKillTipsUICtrl then
    self.BottomKillTipsUICtrl:RefreshTillTopsInfo(tipsValue.KillMessageData)
  end
  tipsValue.Animation = self.UIRoot[tipsValue.InAnimation]
  tipsValue.IsFullAnimation = true
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  tipsValue.ShowBeginTime = UKismetSystemLibrary.GetGameTimeInSeconds(self.UIRoot)
  self:PlayUserWidgetAnimation(self.UIRoot[tipsValue.InAnimation], 0, 1, 0, 1)
  self.ShowingTips[tipsType] = tipsValue
  self.UIRoot.BottomKillTips_Panel:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end
function BattlePopTips:HandleTipsOut(tipsType, animName)
  if tipsType == 2 then
    log(bWriteLog and "BattlePopTips:HandleTipsOut tipsType:" .. tostring(tipsType))
  end
  print(bWriteLog and "BattlePopTips:PreparePopTips HandleTipsOut : tipsType:" .. tostring(tipsType))
  if self.LoadAsyncTimeoutTimers and self.LoadAsyncTimeoutTimers[tipsType] then
    self:RemoveGameTimer(self.LoadAsyncTimeoutTimers[tipsType])
    self.LoadAsyncTimeoutTimers[tipsType] = nil
  end
  self.ShowingTips[tipsType] = nil
  self:HideTips(tipsType)
  self.ShowingTipsWidget[tipsType] = nil
  self:PopNextTips(tipsType)
end
function BattlePopTips:HideTips(tipsType)
  if tipsType == self.CONSNT_BOTTOM_KILL_TYPE then
    self.UIRoot.BottomKillTips_Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.UIRoot.BottomTips_KillTypeTips_Border:SetContentColorAndOpacity(FLinearColor(1, 1, 1, 1))
  end
end
function BattlePopTips:ClearTips()
  print(bWriteLog and "BattlePopTips:ClearTips")
  if self.ShowingTipsWidget then
    for _, TipsWidget in pairs(self.ShowingTipsWidget) do
      if TipsWidget then
        TipsWidget:SetNeedClear()
      end
    end
  end
  self.ShowingTips = {}
  self.TipsCache = {}
  self.UIRoot.BottomKillTips_Panel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function BattlePopTips:OnShowSetting(_, _, isShow)
  log(bWriteLog and "BattlePopTips:OnShowSetting isShow:" .. tostring(isShow))
  if isShow then
    self.UIRoot.BottomTips_KillTypeTips:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  else
    self.UIRoot.BottomTips_KillTypeTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function BattlePopTips:PlayVoice(AudioPath)
  self:StopVoice()
  local util = require("client.slua_ui_framework.util")
  local audioPath = util.GetUrlByLanguage(AudioPath)
  local UEPathUtilityMethods = import("UEPathUtilityMethods")
  local bExist = UEPathUtilityMethods.IsPathExist(audioPath)
  if not bExist then
    audioPath = AudioPath
  end
  self.VoiceDelegate = util.GetAssetAsync(audioPath, function(akEvent)
    if akEvent then
      local AkGameplayStatics = import("AkGameplayStatics")
      self.VoiceID = AkGameplayStatics.PostEventAtLocation(akEvent, FVector(0, 0, 0), FRotator(0, 0, 0), "", self.UIRoot)
    end
  end)
end
function BattlePopTips:StopVoice()
  if self.VoiceID ~= nil then
    local audio_util = require("client.common.audio_util")
    audio_util.StopSound(self.VoiceID)
    self.VoiceID = nil
  end
  if self.VoiceDelegate ~= nil then
    local util = require("client.slua_ui_framework.util")
    util.ClearAssetAsync(self.VoiceDelegate)
    self.VoiceDelegate = nil
  end
end
function BattlePopTips:OnEnterBattleResult()
  print(bWriteLog and "BattlePopTips:OnEnterBattleResult")
  self.EnterBattleResult = true
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, BattlePopTips)