local UI = {}
local LogicNews = require("client.slua.logic.lobby.logic_lobby_news")
local show = function(widget)
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
local selfHit = function(widget)
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
local collapse = function(widget)
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function UI:ctor()
  self.timer = nil
end
function UI:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button, self.OnClickButton, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_NEWS_RESPONSE, self.DisplayUI, self)
end
function UI:OnShow()
  self:DisplayUI()
end
function UI:DisplayUI()
  if not LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_NEWS_NOTIFY) then
    self:ShowUI(false)
    return
  end
  if LogicNews.CheckShowNews() then
    self:ShowUI(true)
  else
    self:ShowUI(false)
  end
end
function UI:ShowUI(showNews)
  if showNews then
    selfHit(self.UIRoot.Root)
    show(self.UIRoot.Button)
    if LogicNews.NoticeIcon >= 1 and LogicNews.NoticeIcon <= 4 then
      self.UIRoot.WidgetSwitcher_Type:SetActiveWidgetIndex(LogicNews.NoticeIcon - 1)
    end
    self:ShowRedPoint()
    self:AddTerminateTimer()
  else
    collapse(self.UIRoot.Root)
    collapse(self.UIRoot.Button)
  end
end
function UI:AddTerminateTimer()
  if self.timer then
    self:RemoveTimer(self.timer)
    self.timer = nil
  end
  local TimeUtil = require("client.common.time_util")
  self.timer = self:AddTimerOnce(LogicNews.NewsEndTime - TimeUtil.GetServerTimeInSec(), function()
    self:ShowUI(false)
  end)
end
function UI:OnClickButton()
  self:PlayAudio(sound_config.click_v1)
  self:SetRedPoint()
  self:ShowRedPoint()
  self:OpenNewsPanel()
end
function UI:OpenNewsPanel()
  if LogicNews.NewsType == 1 then
    UIManager.ShowUI(UIManager.UI_Config.lobby_common_news, LogicNews.NewsShowPos, LogicNews.NewsShowTitle, LogicNews.NewsShowContent, LogicNews.NewsItemID)
  elseif LogicNews.NewsType == 2 then
    if LogicNews.WarningNoticeTitle == "" or LogicNews.WarningNoticeContent == "" then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.Common_MessageBox_News_UIBP, LogicNews.WarningNoticeTitle, LogicNews.WarningNoticeContent, LogicNews.WarningNoticeImgUrl, LogicNews.WarningNoticeJump, LogicNews.WarningNoticePos)
  end
end
function UI:SetRedPoint()
  local curNewsID = LogicNews.NewsStartTime
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBindFaceBook) or {}
  saveData.  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eBindFaceBook)
end
function UI:ShowRedPoint()
  local curNewsID = LogicNews.NewsStartTime
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBindFaceBook)
  if not saveData then
    show(self.UIRoot.RedPoint)
  elseif saveData.curNewsID == curNewsID then
    collapse(self.UIRoot.RedPoint)
  else
    show(self.UIRoot.RedPoint)
  end
end
local Class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local UITemplate = Class(UIBase, nil, UI)
return UITemplate