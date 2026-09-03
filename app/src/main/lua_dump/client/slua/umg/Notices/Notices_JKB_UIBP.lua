local Notices_JKB_UIBP = {}
local NoticesUtil = require("client.logic.Notice.NoticesUtil")
local NoticesConst = require("client.logic.Notice.NoticesConst")
local AUTO_CHANGE_IMG_TIME = 5
function Notices_JKB_UIBP:ctor(_, noticeList)
  self.NoticeList = noticeList or {}
  self.CurSelectIndex = 1
  self.CDNDownloadIndex = nil
  self.AutoScrollHandle = nil
  self.ThumbNailItemMap = {}
end
function Notices_JKB_UIBP:OnInitialize()
  self.Reuse_fall = self:InitReuseFallMultiSize(self.UIRoot.ReuseFall, "client.slua.umg.Notices.Item.Notices_CollectionPage_Item_UIBP")
  self.ThumbNailScroll = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
end
function Notices_JKB_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_CloseUI, self.OnClickedClose, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_0, self.OnCheckedBoxRemind, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Jump, self.OnClickedJump, self)
  self.ThumbNailScroll:SetRefreshItemCallback(self.RefreshThumbNailItem, self)
  self.ThumbNailScroll:AddItemWidgetChildEvent("Button_item", "OnClicked", self.OnClickedThumbNailItem, self)
end
function Notices_JKB_UIBP:OnPostInitialize()
  local check = 0
  if NoticesUtil.IsTodayNoShow() then
    check = 1
  end
  self.UIRoot.CheckBox_0:SetCheckedState(check)
  self.ThumbNailScroll:SetData(self.NoticeList)
  self.CurSelectIndex = 1
  self.ThumbNailScroll:Select(1)
  self:RefreshContent(self.NoticeList[1])
  self:StartAutoScroll()
end
function Notices_JKB_UIBP:OnClickedClose()
  self:PlayAudio(sound_config.click_v1)
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  local CurScene = NoticesModule:GetCurNoticeScene()
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  if CurScene == NoticesConst.Scene.Login then
    local NoticesUtil = require("client.logic.Notice.NoticesUtil")
    if NoticesUtil.IsBlockingCloseByHDmpve() then
      return
    end
  end
  self:PushSeq()
end
function Notices_JKB_UIBP:OnCheckedBoxRemind()
  self:PlayAudio(sound_config.click_v1)
  NoticesUtil.SaveTodayNoShowTime(self.UIRoot.CheckBox_0:GetCheckedState())
end
function Notices_JKB_UIBP:OnClickedJump()
  self:PlayAudio(sound_config.click_v1)
  self:JumpUrl(self.NoticeList[self.CurSelectIndex])
end
function Notices_JKB_UIBP:OnClickedThumbNailItem(widget, index)
  self:PlayAudio(sound_config.click_v1)
  self:CancelAutoScroll()
  self.CurSelectIndex = index
  self.ThumbNailScroll:Select(index)
  self:RefreshContent(self.NoticeList[index])
  self:StartAutoScroll()
end
function Notices_JKB_UIBP:RefreshThumbNailItem(widget, index)
  local itemData = self.ThumbNailScroll:GetItemData(index)
  self:SetWidgetVisible(widget.Image_Loading, true)
  self:SetWidgetVisible(widget.Image_notice, false)
  if self.ThumbNailItemMap[widget] then
    local imageIndex = self.ThumbNailItemMap[widget]
    self.ThumbNailItemMap[widget] = nil
    self:CancelImageDownloadByIndex(imageIndex)
  end
  local downloadSuccessCallback = function(texture, path)
    if slua.isValid(self.UIRoot) then
      self:SetWidgetVisible(widget.Image_Loading, false)
      widget.Image_notice:SetBrushFromTexture(texture, false)
      self:SetWidgetVisible(widget.Image_notice, true)
    end
  end
  local params = {onDownloadSuccess = downloadSuccessCallback}
  local imageIndex = self:SetTexture(nil, itemData.ThumbNail, params)
  if imageIndex and 0 < imageIndex then
    self.ThumbNailItemMap[widget] = imageIndex
  end
  self:SetWidgetVisible(widget.Select, self.CurSelectIndex == index)
end
function Notices_JKB_UIBP:RefreshContent(noticeData)
  if not noticeData then
    return
  end
  log_tree("Notices_JKB_UIBP:RefreshContent. noticeData = ", noticeData)
  NoticesUtil.SaveShowTime(noticeData)
  NoticesUtil.SaveDisplayID(noticeData)
  NoticesUtil.SaveDisplayMsgIDs(noticeData)
  NoticesUtil.SaveDisplayTotalTimes(noticeData)
  self:SetWidgetVisible(self.UIRoot.Image_Default, true)
  if noticeData.MsgContentType == NoticesConst.NoticeContentType.Text then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self.UIRoot.TextBlock_WindowsTitle:SetText(noticeData.MsgTitle)
    local NoticeCfgUtil = require("client.logic.Notice.NoticeCfgUtil")
    local itemDataArr = NoticeCfgUtil.GenerateNoticeItemData(noticeData.MsgContent)
    self.Reuse_fall:SetData(itemDataArr)
    self.Reuse_fall:ScrollToStart()
    self:SetWidgetVisible(self.UIRoot.Image_Default, false)
  elseif noticeData.MsgContentType == NoticesConst.NoticeContentType.ImageOrBlueprint then
    if self.CDNDownloadIndex then
      self:CancelImageDownloadByIndex(self.CDNDownloadIndex)
      self.CDNDownloadIndex = nil
    end
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(2)
    local path = noticeData.PicPath
    local util = require("client.slua_ui_framework.util")
    local languagePath = util.GetUrlByLanguage(path)
    if util.IsOnlineImageUrl(languagePath) then
      local params = {
        onDownloadSuccess = function(texture)
          if not slua.isValid(self.UIRoot.Image_Pure) then
            return
          end
          self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
          self.UIRoot.Image_Pure:SetBrushFromTexture(texture, false)
          self.UIRoot.Image_Pure:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
          self:SetWidgetVisible(self.UIRoot.Image_Default, false)
        end,
        onDownloadFail = function()
          log(bWriteLog and "Notices_JKB_UIBP:SetImageByPicPath, OnLoadFailed url = " .. tostring(languagePath))
        end
      }
      local downloadIndex = self:SetTexture(nil, languagePath, params)
      if downloadIndex and 0 < downloadIndex then
        self.CDNDownloadIndex = downloadIndex
      end
    else
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
      self:SetTexture(self.UIRoot.Image_Pure, languagePath, {sync = true})
      self:SetWidgetVisible(self.UIRoot.Image_Default, false)
    end
  end
end
function Notices_JKB_UIBP:CancelAutoScroll()
  if self.AutoScrollHandle then
    self:RemoveTimer(self.AutoScrollHandle)
    self.AutoScrollHandle = nil
  end
end
function Notices_JKB_UIBP:StartAutoScroll()
  local display_seconds = AUTO_CHANGE_IMG_TIME
  local notiece = self.NoticeList[self.CurSelectIndex]
  if not notiece then
    return
  end
  if notiece.DisplaySeconds and notiece.DisplaySeconds > 0 then
    display_seconds = notiece.DisplaySeconds
  end
  log_format(bWriteLog and "Notices_JKB_UIBP. display_seconds=%s", display_seconds)
  self.AutoScrollHandle = self:AddTimerOnce(display_seconds, function()
    self.CurSelectIndex = self.CurSelectIndex + 1 > #self.NoticeList and 1 or self.CurSelectIndex + 1
    self.ThumbNailScroll:Select(self.CurSelectIndex)
    self:RefreshContent(self.NoticeList[self.CurSelectIndex])
    self:RemoveTimer(self.AutoScrollHandle)
    self.AutoScrollHandle = nil
    self:StartAutoScroll()
  end)
end
local class = require("class")
local Notices_SubUI_UIBP = require("client.slua.umg.Notices.Notices_SubUI_UIBP")
local CNotices_JKB_UIBP = class(Notices_SubUI_UIBP, nil, Notices_JKB_UIBP)
return CNotices_JKB_UIBP