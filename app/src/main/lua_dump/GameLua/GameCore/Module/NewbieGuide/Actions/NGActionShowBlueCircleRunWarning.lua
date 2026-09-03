local NGActionShowBlueCircleRunWarning = {}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function NGActionShowBlueCircleRunWarning:ctor(selfType, Params)
  self.PopTipInterval = Params.PopTipInterval or 20
  self.uNavigatorPanel = nil
  self.LastPopTipTime = -1
  self.bCanShowEnterSafeAreaTip = false
  self.bTipsKeepsFlashing = false
  self.CurCircleStatus = -1
  self.RuningCircleEventID = EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SYNC_CIRCILE_INFO, function(...)
    local args = table.pack(...)
    if #args == 3 then
      self.CurCircleStatus = args[3]
    end
  end)
  self.bShouldOpenWarning = true
  self.OpenWarningEventID = EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_NEWBIE_GUIDE_BLUECIRCLE_CANSHOW_WARNING, function(_, __, bShow)
    print(bWriteLog and "NGActionShowBlueCircleRunWarning CanShow:", bShow)
    self.bShouldOpenWarning = bShow
  end)
end
function NGActionShowBlueCircleRunWarning:RunAction(InGuideID)
  NGActionShowBlueCircleRunWarning.__super.RunAction(self, InGuideID)
  print(bWriteLog and "NGActionShowBlueCircleRunWarning RunAction InGuideID:" .. tostring(InGuideID))
  self.uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(self.uGameState) then
    return false
  end
  self.uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(self.uPlayerController) then
    return false
  end
  self:CheckBlueCircleWarning()
  local time_ticker = require("common.time_ticker")
  self.TimerHandle = time_ticker.AddTimer(0, function(...)
    while true do
      coroutine.yield(1.0)
      if self.bShouldOpenWarning then
        self:CheckBlueCircleWarning()
      end
    end
  end)
  return true
end
function NGActionShowBlueCircleRunWarning:CheckBlueCircleWarning()
  if not slua.isValid(self.uGameState) then
    return
  end
  if not slua.isValid(self.uPlayerController) then
    return
  end
  if not self.uPlayerController:IsInFight() then
    return
  end
  local CurGameState = self.uGameState:GetGameModeState()
  if CurGameState ~= "FightingState" then
    return
  end
  local uPlayerPawn = self.uPlayerController:GetPlayerCharacterSafety()
  local curTime = os.time()
  if slua.isValid(uPlayerPawn) then
    if uPlayerPawn.SkipCirclePain then
      return
    end
    if self.uGameState.CurCircleWave >= 0 then
      local uPawnLoc = uPlayerPawn:GetOverrideCirclePainPos()
      local DistanceToBlueCircle = FVector.DistXY(uPawnLoc, self.uGameState.BlueCircle)
      local BlueCircleRadiu = self.uGameState.BlueCircle.Z
      if 0 < self.uGameState.BlueCircle.Z and DistanceToBlueCircle >= BlueCircleRadiu then
        if curTime - self.LastPopTipTime > self.PopTipInterval then
          log(bWriteLog and "NGActionShowBlueCircleRunWarning:CheckBlueCircleWarning uPawnLoc X:" .. uPawnLoc.X .. " Y:" .. uPawnLoc.Y .. " BlueCircleLoc X:" .. self.uGameState.BlueCircle.X .. " Y:" .. self.uGameState.BlueCircle.Y .. " BlueCircleRadiu:" .. self.uGameState.BlueCircle.Z)
          self.LastPopTipTime = curTime
          if not self.CheckIsCircleCountDownRunning() then
            IngameTipsTools.BattleGeneralTip(10089, "", "")
          end
          self.bCanShowEnterSafeAreaTip = true
        end
        if not self.bTipsKeepsFlashing then
          self.bTipsKeepsFlashing = true
          self:PlaySafeAreaAnim(0)
        end
      else
        local DistanceToWhiteCircle = FVector.DistXY(uPawnLoc, self.uGameState.WhiteCircle)
        local WhiteCircleRadiu = self.uGameState.WhiteCircle.Z
        if 0 < self.uGameState.WhiteCircle.Z and DistanceToWhiteCircle > WhiteCircleRadiu then
          local ShowDist, TipID
          if self.CurCircleStatus == 1 then
            TipID = 10144
            ShowDist = math.floor((DistanceToWhiteCircle - WhiteCircleRadiu) / 100)
          elseif self.CurCircleStatus == 2 then
            TipID = 10087
            ShowDist = math.floor((BlueCircleRadiu - DistanceToBlueCircle) / 100)
          end
          if self.uGameState.CurCircleWave > 4 then
            if self.CurCircleStatus == 1 then
              TipID = 10145
            elseif self.CurCircleStatus == 2 then
              TipID = 10088
            end
          end
          if curTime - self.LastPopTipTime > self.PopTipInterval then
            log(bWriteLog and "NGActionShowBlueCircleRunWarning:CheckBlueCircleWarning WhiteCircle X:" .. self.uGameState.WhiteCircle.X .. " Y:" .. self.uGameState.WhiteCircle.Y .. " WhiteCircleRadius:" .. self.uGameState.WhiteCircle.Z)
            self.LastPopTipTime = curTime
            if not self.CheckIsCircleCountDownRunning() then
              IngameTipsTools.BattleGeneralSAPTip(TipID, tostring(ShowDist), "")
            end
            self:PlaySafeAreaAnim(3)
          end
          if self.bTipsKeepsFlashing then
            self.bTipsKeepsFlashing = false
            self:PlaySafeAreaAnim(-1)
          end
          self.bCanShowEnterSafeAreaTip = true
        elseif self.bCanShowEnterSafeAreaTip then
          self.bCanShowEnterSafeAreaTip = false
          self.bTipsKeepsFlashing = false
          IngameTipsTools.BattleNormalTipsByTextID(10910, "", "")
        end
      end
    end
  end
end
function NGActionShowBlueCircleRunWarning:PlaySafeAreaAnim(nRepeatTimes)
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimer(3, function()
    if not slua.isValid(self.uNavigatorPanel) then
      if not UIManager.UI_Config_InGame.NavigatorPanel then
        return
      end
      local NavigatorPanel = UIManager.GetUI(UIManager.UI_Config_InGame.NavigatorPanel)
      if NavigatorPanel then
        self.uNavigatorPanel = NavigatorPanel.UIRoot
      end
      if not slua.isValid(self.uNavigatorPanel) then
        log(bWriteLog and "Can't get NavigatorPanel")
        return
      end
      if self.uNavigatorPanel.bSafeAreaHighlightMode ~= nil then
        self.uNavigatorPanel.bSafeAreaHighlightMode = true
      end
      if self.uNavigatorPanel.bShowFadeOutAnim ~= nil then
        self.uNavigatorPanel.bShowFadeOutAnim = true
      end
    end
    if self.uNavigatorPanel.Anim_Guide then
      self.uNavigatorPanel:StopAnimation(self.uNavigatorPanel.Anim_Guide)
      self.uNavigatorPanel:StopAnimation(self.uNavigatorPanel.Anim_FadeOut)
      if 0 <= nRepeatTimes then
        self.uNavigatorPanel:PlayUserWidgetAnimation(self.uNavigatorPanel.Anim_Guide, 0, nRepeatTimes, 0, 1)
      end
    end
  end)
end
function NGActionShowBlueCircleRunWarning.CheckIsCircleCountDownRunning()
  local CheckGuides = {"Base002", "Base003"}
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  if not NewbieGuideMgr or not NewbieGuideMgr.ServerData then
    return false
  end
  for _, GuideID in ipairs(CheckGuides) do
    local GuideItem = NewbieGuideMgr.EnableGuideItemTable[GuideID]
    if GuideItem and GuideItem.RuningState == 2 then
      log(bWriteLog and "NGActionShowBlueCircleRunWarning.CheckIsCircleCountDownRunning True.")
      return true
    end
  end
  return false
end
function NGActionShowBlueCircleRunWarning:EndAction()
  NGActionShowBlueCircleRunWarning.__super.EndAction(self)
end
function NGActionShowBlueCircleRunWarning:Clear()
  log(bWriteLog and "Debug NewbieGuide: NGActionShowBlueCircleRunWarning Clear")
  if self.TimerHandle then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.TimerHandle)
    self.TimerHandle = nil
  end
  self.uNavigatorPanel = nil
  EventSystem:UnregistEventByID(self.RuningCircleEventID)
  EventSystem:UnregistEventByID(self.OpenWarningEventID)
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionShowBlueCircleRunWarning = class(CObject, nil, NGActionShowBlueCircleRunWarning)
return CNGActionShowBlueCircleRunWarning