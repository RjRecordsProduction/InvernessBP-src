local Activity_Newbie_Banner = {}
local item_size = 236.0
local half_item_size = 100
function Activity_Newbie_Banner:ctor(selfType)
end
function Activity_Newbie_Banner:OnInitialize()
  Activity_Newbie_Banner.__super.OnInitialize(self)
  self.delay = 0
  self.shouldRecordScrollOffset = true
  self.isFastSlide = false
  self.userBeginSlideTime = 0
  self.userEndSlideTime = 0
  self.handleSlideTimeStamp = 0
  self.firstOverScroll = nil
end
function Activity_Newbie_Banner:RegistEvents()
  Activity_Newbie_Banner.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, self.RefreshAwardUI, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_GET_AWARD, self.RefreshAwardUI, self)
  self:AddCommonEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_UPGRADE_DATA, self.RefreshAwardUI, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_BANNER_CHANGE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_BANNER_DATA_CHANGE, self.UpdateUI, self)
end
function Activity_Newbie_Banner:OnPostInitialize()
  Activity_Newbie_Banner.__super.OnPostInitialize(self)
  local logic_puffer_bundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local bFitLobbyDownloaded = logic_puffer_bundle.IsFitLobbyResDownloaded()
  self.LoopScrollBox_0 = nil
  if bFitLobbyDownloaded then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self.LoopScrollBox_0 = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
    self:AddControlEventByControl(self.UIRoot.LoopScrollBox_0, "OnUserScrolled", self.OnUserScrolled, self)
    self:AddControlEventByControl(self.UIRoot.LoopScrollBox_0, "OnEndScroll", self.OnEndScroll, self)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self.LoopScrollBox_0 = self:InitScrollBox(self.UIRoot.LoopScrollBox_1)
    self:AddControlEventByControl(self.UIRoot.LoopScrollBox_1, "OnUserScrolled", self.OnUserScrolled, self)
    self:AddControlEventByControl(self.UIRoot.LoopScrollBox_1, "OnEndScroll", self.OnEndScroll, self)
  end
  self.LoopScrollBox_0:SetRefreshItemCallback(self.OnRefreshItem, self)
  self.LoopScrollBox_0:AddItemWidgetChildEvent("Button_Activity", "OnClicked", self.OnClickedItem, self)
  self.isUserScrolling = false
  self:UpdateUI()
  self:UpdateDownload()
end
function Activity_Newbie_Banner:UpdateUI()
  local logic_lobby_mid_banner = require("client.slua.logic.lobby.Mid.logic_lobby_mid_banner")
  self.bannerDataList = {
    [1] = {}
  }
  local bannerDataList = logic_lobby_mid_banner.GetBannerByLine()
  if bannerDataList and 0 < #bannerDataList then
    for i = 1, #bannerDataList do
      if self:NeedShowOnNewbieBanner(bannerDataList[i]) then
        table.insert(self.bannerDataList, 2, bannerDataList[i])
        break
      end
    end
  end
  self.LoopScrollBox_0:SetData(self.bannerDataList)
  self.UIRoot:SetActivityListPageCount(#self.bannerDataList)
end
function Activity_Newbie_Banner:NeedShowOnNewbieBanner(bannerData)
  if bannerData.ActivityType == 12229 then
    return true
  end
  local url = bannerData.JumpUrl
  if not url then
    return false
  end
  return false
end
function Activity_Newbie_Banner:RefreshAwardUI()
  self.LoopScrollBox_0:RefreshItem(1)
end
function Activity_Newbie_Banner:OnRefreshItem(widget, index)
  if index == 1 then
    self:RefreshItem(widget)
  else
    local data = self.bannerDataList[index]
    local util = require("client.slua_ui_framework.util")
    local imgUrl = util.GetUrlByLanguage(data.IconPath)
    self:SetWidgetVisible(widget.ActivityName, false)
    self:SetWidgetVisible(widget.UnLockLevel, false)
    local params = {
      onDownloadFail = function(url)
        log(bWriteLog and "  : failFunc" .. tostring(url))
        self:SetTexture(widget.Image_Activity, data.IconPath, {tryTimes = 2})
      end
    }
    self:SetTexture(widget.Image_Activity, imgUrl, params)
  end
end
function Activity_Newbie_Banner:RefreshItem(widget)
  local currentLevel = DataMgr.roleData.level
  self:SetWidgetVisible(widget.ActivityName, true)
  self:SetWidgetVisible(widget.UnLockLevel, true)
  widget.ActivityName:SetText(LocUtil.GetLocalizeResStr(29945))
  local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
  local link, level = level_unlock_award_manager:GetNextBannerLink(currentLevel)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    local logic_newbie_reward_level_sprint = require("client.slua.logic.activity.newbie.logic_newbie_reward_level_sprint")
    link, level = logic_newbie_reward_level_sprint.GetNextBannerLink(currentLevel)
  end
  widget.UnLockLevel:SetText(LocUtil.LocalizeResFormat(29946, level))
  local util = require("client.slua_ui_framework.util")
  local imgUrl
  if link then
    imgUrl = util.GetUrlByLanguage(link)
  end
  local successFunc = function(texture)
    widget.Image_Activity:SetBrushFromTexture(texture, false)
  end
  local failFunc = function(url)
    log(bWriteLog and "  : failFunc" .. tostring(url))
    self:SetTexture(widget.Image_Activity, link, {tryTimes = 2})
  end
  local params = {onDownloadFail = failFunc}
  self:SetTexture(widget.Image_Activity, imgUrl, params)
end
function Activity_Newbie_Banner:OnClickedItem(widget, index)
  self:PlayAudio(sound_config.new_activityBtn)
  if index == 1 then
    local logicNewbieMain = require("client.slua.logic.activity.newbie.logic_newbie_activity_config")
    local activityDef = logicNewbieMain.activityDef
    local logic_newbie_activity = require("client.slua.logic.activity.newbie.logic_newbie_activity")
    logic_newbie_activity.ShowUIWithModCheck(UIManager.UI_Config.Activity_Newbie_Main, activityDef.Sprint)
  else
    local data = self.bannerDataList[index]
    self:OnClickBanner(data.ID, data.JumpUrl, widget)
  end
end
function Activity_Newbie_Banner:OnClickBanner(ID, JumpUrl, widget)
  log(bWriteLog and "Lobby_Mid_Binner_More_UIBP:OnClickBanner activityId = " .. ID .. ", url = " .. JumpUrl)
  self:PlayAudio(sound_config.new_activityBtn)
  for i = 1, #self.bannerDataList do
    local v = self.bannerDataList[i]
    if v.ID == ID then
      if v.IsNew then
        v.IsNew = false
        LobbySystem.SaveIfBannerGotClicked(v.ID, v.StartTimeUTC)
      end
      break
    end
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.fromClickBanner = true
  local logic_lobby_mid_banner = require("client.slua.logic.lobby.Mid.logic_lobby_mid_banner")
  logic_lobby_mid_banner.ProcOnClickBanner(ID, self.bannerDataList)
end
function Activity_Newbie_Banner:OnUserScrolled(offset)
  log(bWriteLog and "[YY] Activity_Newbie_Banner:OnUserScrolled, offset = " .. offset .. "  type==" .. type(offset))
  self.isUserScrolling = true
  self.LoopScrollBox_0:ClearAnimationPlayTimer()
  local TimeUtil = require("client.common.time_util")
  if self.shouldRecordScrollOffset then
    self.beginOffset = offset
    self.shouldRecordScrollOffset = false
    self.userBeginSlideTime = TimeUtil.GetServerTimeInSecWithFraction()
    self.handleSlideTimeStamp = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "[YY] Activity_Newbie_Banner:OnUserScrolled, beginOffset = " .. self.beginOffset .. "\tbeginTime===" .. self.userBeginSlideTime)
  end
  if not self.beginOffset then
    log(bWriteLog and "Activity_Newbie_Banner:OnUserScrolled, begin offset is nil")
    return
  end
  local directOffset = self.beginOffset - offset
  local absOffset = math.abs(directOffset)
  local target = 0
  local num = 0
  log(bWriteLog and "[YY] Activity_Newbie_Banner:OnUserScrolled, directOffset = " .. directOffset .. " absOffset= " .. absOffset)
  if absOffset >= item_size or self.firstOverScroll then
    log(bWriteLog and "[YY] Activity_Newbie_Banner:OnUserScrolled,  \230\187\145\229\138\168\232\140\131\229\155\180\232\182\138\231\149\140")
    if 0 < directOffset then
      target = self:GetTarget(self.beginOffset, 0, 0)
    else
      target = self:GetTarget(self.beginOffset, 0, 1)
    end
    if self.bannerDataList then
      num = #self.bannerDataList
    end
    if target >= num * item_size then
      self.LoopScrollBox_0:SetItemOffset(0)
    else
      self.LoopScrollBox_0:SetItemOffset(target)
      self.firstOverScroll = target
      log(bWriteLog and "[YY] Activity_Newbie_Banner:OnUserScrolled,SetItemOffset to target:\t" .. target)
    end
  end
end
function Activity_Newbie_Banner:OnEndScroll()
  self.isUserScrolling = false
  local offset = self.LoopScrollBox_0:GetItemOffset()
  if not self.beginOffset then
    log(bWriteLog and "[DeanJYT] Lobby_Mid_Binner_More_UIBP:OnEndScroll, begin offset is nil")
    self.shouldRecordScrollOffset = true
    return
  end
  log(bWriteLog and "[YY] Lobby_Mid_Binner_More_UIBP:OnEndScroll, beginOffset===" .. self.beginOffset .. "  endOffset===" .. offset)
  local TimeUtil = require("client.common.time_util")
  self.userEndSlideTime = TimeUtil.GetServerTimeInSecWithFraction()
  local slideTimeSpan = self.userEndSlideTime - self.userBeginSlideTime
  if slideTimeSpan <= 0.5 then
    self.isFastSlide = true
  end
  local shouldStay = offset <= self.beginOffset
  if self.bannerDataList then
    local num = #self.bannerDataList
    local maxOffset = (num - 1) * item_size
    shouldStay = shouldStay or offset > maxOffset
  end
  self:ResetScroll(shouldStay)
  self.shouldRecordScrollOffset = true
end
function Activity_Newbie_Banner:ResetScroll(shouldStay)
  if self.isUserScrolling == true then
    self.isUserScrolling = false
    return
  end
  if self.LoopScrollBox_0:IsAnmationPlaying() then
    return
  end
  local indexAddition = 1
  if shouldStay then
    indexAddition = 0
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local isTouched = false
  if now <= self.handleSlideTimeStamp + 4 then
    isTouched = true
    indexAddition = 0
  end
  local endOffset = self.LoopScrollBox_0:GetItemOffset()
  local target = self:GetTarget(endOffset, indexAddition, 0)
  if indexAddition == 1 or not self.beginOffset then
    if isTouched then
      return
    end
    target = self:GetTarget(endOffset, indexAddition, 0)
  elseif self.beginOffset == 0 and endOffset == 0 then
    target = -1
  elseif self.beginOffset and self.beginOffset == endOffset then
    target = self:GetTarget(endOffset, 1, 0)
  elseif self.beginOffset then
    target = self:GetSlideTarget(endOffset, indexAddition)
  end
  local num = 0
  if self.bannerDataList then
    num = #self.bannerDataList
  end
  if target >= num * item_size then
    self.LoopScrollBox_0:SetItemOffset(0)
    self:ResetAllSlideParam()
  elseif target < 0 then
    self.LoopScrollBox_0:SetItemOffset(num * item_size)
    self:ResetAllSlideParam()
  else
    self.LoopScrollBox_0:PlayAnimToTarget(target, 0.8, 1, nil, function()
      self:ResetAllSlideParam()
    end)
  end
end
function Activity_Newbie_Banner:ResetAllSlideParam()
  self.userBeginSlideTime = 0
  self.userEndSlideTime = 0
  self.beginOffset = nil
  self.isFastSlide = false
  self.firstOverScroll = nil
end
function Activity_Newbie_Banner:GetSlideTarget(endOffset, indexAddition)
  if self.beginOffset then
    local absOffset = math.abs(self.beginOffset - endOffset)
    if self.isFastSlide then
      log(bWriteLog and "ResetScroll===333=======\229\191\171\233\128\159\230\187\145\229\138\168")
      return self:GetFastSlideTarget(absOffset, endOffset, indexAddition)
    else
      log(bWriteLog and "ResetScroll===444=======\230\133\162\233\128\159\230\187\145\229\138\168")
      return self:GetSlowSlideTarget(absOffset, endOffset, indexAddition)
    end
  end
  return 0
end
function Activity_Newbie_Banner:GetFastSlideTarget(absOffset, endOffset, indexAddition)
  if endOffset < self.beginOffset then
    if absOffset < item_size and 0 < absOffset then
      return self:GetTarget(endOffset, indexAddition, 0)
    elseif absOffset >= item_size then
      log(bWriteLog and "[YY] Activity_Newbie_Banner:OnUserScrolled, beginOffset==1===2222==\229\143\179\230\187\145\229\138\168")
      if endOffset == 0 then
        return self:GetTarget(self.beginOffset, indexAddition, 0)
      else
        return self:GetTarget(self.beginOffset, indexAddition, 1)
      end
    end
  elseif endOffset > self.beginOffset then
    if absOffset < item_size and 0 < absOffset then
      return self:GetTarget(endOffset, indexAddition, 0)
    elseif absOffset >= item_size then
      log(bWriteLog and "[YY] Activity_Newbie_Banner:OnUserScrolled, beginOffset==1===2222==\229\190\128\229\183\166\230\187\145\229\138\168")
      return self:GetTarget(self.beginOffset, indexAddition, 1)
    end
  end
  return 0
end
function Activity_Newbie_Banner:GetSlowSlideTarget(absOffset, endOffset, indexAddition)
  if endOffset < self.beginOffset then
    if absOffset >= half_item_size then
      return self:GetTarget(self.beginOffset, indexAddition, 0)
    else
      return self:GetTarget(endOffset, indexAddition, 1)
    end
  elseif endOffset > self.beginOffset then
    if absOffset >= half_item_size then
      return self:GetTarget(self.beginOffset, indexAddition, 1)
    else
      return self:GetTarget(endOffset, indexAddition, 0)
    end
  end
  return 0
end
function Activity_Newbie_Banner:GetTarget(endOffset, indexAddition, offset)
  return (math.floor(endOffset / item_size) + indexAddition + offset) * item_size
end
function Activity_Newbie_Banner:UpdateDownload()
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  NewbieActivitySystem.CreateDownloadPanel(self.UIRoot.CanvasPanel_Download)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CActivity_Newbie_Banner = class(ui_base, nil, Activity_Newbie_Banner)
return CActivity_Newbie_Banner