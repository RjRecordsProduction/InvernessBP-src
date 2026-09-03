local MiniTvBannerUI = {}
local MAX_INTERNAL = 5
local MIN_TICKER = 0.1
function MiniTvBannerUI:ctor(_, OwnerActor)
  self.NeedShowedList = {}
  self.HideTimer = nil
  self.end
function MiniTvBannerUI:RegistEvents()
  MiniTvBannerUI.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Click, self.OnClickJump, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnClickClose, self)
end
function MiniTvBannerUI:OnPostInitialize()
  MiniTvBannerUI.__super.OnPostInitialize(self)
  local log_mini_tv = require("client.slua.logic.mini_tv.logic_mini_tv")
  self.NeedShowedList = log_mini_tv.GetBannerList() or {}
  self.LoopScroll = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
  self.LoopScroll:SetRefreshItemCallback(self.OnRefreshItem, self)
end
function MiniTvBannerUI:OnShow()
  self.isHide = false
  self:TickChangeBanner()
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_Open, 0, 1, 0, 1)
end
function MiniTvBannerUI:DelayHide()
  if self.isHide then
    return
  end
  log(bWriteLog and "MiniTvBannerUI DelayHide ")
  if not slua.isValid(self.UIRoot) then
    return
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_Open, 0, 1, 1, 1)
  self.HideTimer = self:AddTimerOnce(0.7, function()
    self.HideTimer = nil
    self.OwnerActor:OnBannerUIHide()
    self:Hide()
  end)
end
function MiniTvBannerUI:OnHide()
  self.isHide = true
  if self.HideCallback then
    self.HideCallback()
  end
end
function MiniTvBannerUI:OnClose()
  self.isHide = true
  if self.HideTimer then
    self:RemoveTimer(self.HideTimer)
    self.HideTimer = nil
  end
end
function MiniTvBannerUI:TickChangeBanner()
  if self.NeedShowedList and #self.NeedShowedList > 0 then
    local TimeUtil = require("client.common.time_util")
    self.StartTime = TimeUtil.GetServerTimeInSec()
    self.CurTime = TimeUtil.GetServerTimeInSec()
    self.TotalTime = #self.NeedShowedList * MAX_INTERNAL
    self.CurIndex = 1
    self.CurBannerData = self.NeedShowedList[self.CurIndex]
    self.LoopScroll:SetData(self.NeedShowedList)
    self:SetCurBannerInfo()
    self:AddTimer(0, function()
      while not self.isHide do
        self.CurTime = self.CurTime + MIN_TICKER
        if self.CurTime - self.StartTime > self.TotalTime then
          break
        end
        do
          local TempIndex = math.ceil((self.CurTime - self.StartTime) / MAX_INTERNAL)
          if 0 < TempIndex and TempIndex and TempIndex ~= self.CurIndex then
            self.CurIndex = TempIndex
            self.CurBannerData = self.NeedShowedList[self.CurIndex]
            self:SetCurBannerInfo()
          end
          self.LoopScroll:RefreshItem(self.CurIndex, self.CurBannerData)
        end
        coroutine.yield(MIN_TICKER)
      end
    end)
  else
    self.LoopScroll:SetData({})
  end
end
function MiniTvBannerUI:SetCurBannerInfo()
  if self.StartTime and self.StartTime > 0 and self.NeedShowedList and 0 < #self.NeedShowedList and self.CurBannerData then
    if self.CurBannerData.ActivityName and self.CurBannerData.ActivityName ~= "" and self.CurBannerData.ActivityDesc and self.CurBannerData.ActivityDesc ~= "" then
      self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
      self.UIRoot.Text_Title:SetText(self.CurBannerData.ActivityName)
      self.UIRoot.Text_Desc:SetText(self.CurBannerData.ActivityDesc)
    elseif self.CurBannerData.IconPath and self.CurBannerData.IconPath ~= "" then
      self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
      self:SetImageByPicPath(self.UIRoot.Image_Picture, self.CurBannerData.IconPath)
    end
  end
end
function MiniTvBannerUI:OnRefreshItem(widget, index)
  local CurProgress = 0
  if index < self.CurIndex then
    widget.ProgressBar_0:SetPercent(1.0)
  elseif index > self.CurIndex then
    widget.ProgressBar_0:SetPercent(0)
  else
    CurProgress = math.fmod(self.CurTime - self.StartTime, MAX_INTERNAL)
    local rate = CurProgress / MAX_INTERNAL
    widget.ProgressBar_0:SetPercent(rate)
  end
end
function MiniTvBannerUI:SetImageByPicPath(BigImage, PicPath)
  if not BigImage or not PicPath then
    return
  end
  self:SetWidgetVisible(BigImage, false)
  if self.UIRoot.Image_Default then
    self:SetWidgetVisible(self.UIRoot.Image_Default, true)
  end
  local util = require("client.slua_ui_framework.util")
  local imgURL = util.GetUrlByLanguage(PicPath)
  if util.IsOnlineImageUrl(imgURL) then
    local params = {
      onDownloadSuccess = function(texture, url)
        BigImage:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
        if self.UIRoot.Image_Default then
          self:SetWidgetVisible(self.UIRoot.Image_Default, false)
        end
        self:SetWidgetVisible(BigImage, true)
      end,
      onDownloadFail = function()
        log(bWriteLog and "MiniTvBannerUI:SetImageByPicPath, OnLoadFailed url = " .. tostring(imgURL))
      end
    }
    self:SetTexture(BigImage, imgURL, params)
  else
    self:SetTexture(BigImage, imgURL)
  end
end
function MiniTvBannerUI:OnClickJump()
end
function MiniTvBannerUI:OnClickClose(bDisableAudio)
  if not bDisableAudio then
    self:PlayAudio(sound_config.close_v1)
  end
  self.OwnerActor:HideBannerUI()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerPawn = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerPawn) then
      uPlayerController:BroadcastUIMessage("UIMsg_HideMiniTvBannerUI", 0, "", "")
    end
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, MiniTvBannerUI)