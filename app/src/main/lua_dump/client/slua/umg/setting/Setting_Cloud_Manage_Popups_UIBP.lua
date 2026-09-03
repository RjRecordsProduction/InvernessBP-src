local Setting_Cloud_Manage_Popups_UIBP = {}
function Setting_Cloud_Manage_Popups_UIBP:ctor(_, ExtraParams)
  self.ExtraParams = ExtraParams or {}
end
function Setting_Cloud_Manage_Popups_UIBP:OnInitialize()
  self.Common_Popup_Medium_UIBP = self:InitCommonPopup(self.UIRoot.Common_Popup_Medium_UIBP)
  self.Common_Popup_Medium_UIBP:SetData(self, LocUtil.GetLocalizeResStr(32989), {showCloseBtn = true})
end
function Setting_Cloud_Manage_Popups_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Confirm, self.Common_Popup_Medium_UIBP.ClosePopup, self.Common_Popup_Medium_UIBP)
  if self.ExtraParams.ApplyFunc then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Download, self.OnNewButton_DownloadClick, self)
  end
  if self.ExtraParams.UploadFunc then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Upload, self.OnClickUpload, self)
  end
  if self.ExtraParams.ShareFunc then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Share, self.OnNewButton_ShareClick, self)
  end
  if self.ExtraParams.ShowDiffFunc then
    self:AddOnClickedEventByControl(self.UIRoot.Button_DiffCloud, self.OnClickButtonDiff, self)
  end
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SHOW_SETTING, self.CloseSelf, self)
end
function Setting_Cloud_Manage_Popups_UIBP:OnPostInitialize()
  local bNoCloudData = self.ExtraParams.CloudData == nil
  if bNoCloudData then
    self.UIRoot.UTRichTextBlock_Cloud:SetText(LocUtil.GetLocalizeResStr(157113))
    self:SetWidgetVisible(self.UIRoot.Button_Confirm, false)
    self:SetWidgetVisible(self.UIRoot.Button_Share, false)
    self:SetWidgetVisible(self.UIRoot.Image_CloudDiff, false)
    self:SetWidgetVisible(self.UIRoot.Button_DiffCloud, false)
    self:SetWidgetVisible(self.UIRoot.Button_Download, false)
    self:SetWidgetVisible(self.UIRoot.Button_Upload, true, true)
    self:SetWidgetVisible(self.UIRoot.Text_time, false)
    return
  end
  local bSameWithCloud = self.ExtraParams.bSameAsCloud
  print(bWriteLog and "Setting_Cloud_Manage_Popups_UIBP:OnPostInitialize bSameWithCloud = " .. tostring(bSameWithCloud))
  self.UIRoot.UTRichTextBlock_Cloud:SetText(bSameWithCloud and LocUtil.GetLocalizeResStr(32983) or LocUtil.GetLocalizeResStr(32985))
  self:SetWidgetVisible(self.UIRoot.Button_Confirm, bSameWithCloud, true)
  self:SetWidgetVisible(self.UIRoot.Button_Share, bSameWithCloud and self.ExtraParams.ShareFunc, true)
  self:SetWidgetVisible(self.UIRoot.Image_CloudDiff, not bSameWithCloud and self.ExtraParams.ShowDiffFunc)
  self:SetWidgetVisible(self.UIRoot.Button_DiffCloud, not bSameWithCloud and self.ExtraParams.ShowDiffFunc, true)
  self:SetWidgetVisible(self.UIRoot.Button_Download, not bSameWithCloud and self.ExtraParams.ApplyFunc, true)
  self:SetWidgetVisible(self.UIRoot.Button_Upload, not bSameWithCloud and self.ExtraParams.UploadFunc, true)
  if self.ExtraParams.CloudUploadTime and self.ExtraParams.CloudUploadTime > 0 then
    self.UIRoot.Text_time:SetText(LocUtil.LocalizeResFormat("32984", self:GetFormatTimeString(self.ExtraParams.CloudUploadTime)))
    self.UIRoot.Text_time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Text_time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Setting_Cloud_Manage_Popups_UIBP:GetFormatTimeString(Time)
  local TimeUtil = require("client.common.time_util")
  local TimeString = TimeUtil.FormatTime_YMDHMS(Time, true)
  local StringUtil = require("common.string_util")
  local TimeStrings = StringUtil.Split(TimeString, " ")
  return TimeStrings[1]
end
function Setting_Cloud_Manage_Popups_UIBP:OnNewButton_ShareClick()
  if self.ExtraParams.ShareFunc then
    self.ExtraParams.ShareFunc()
    self:CloseSelf()
  end
end
function Setting_Cloud_Manage_Popups_UIBP:OnNewButton_DownloadClick()
  if self.ExtraParams.ApplyFunc then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(9900), self.ExtraParams.ApplyText, function()
      self.ExtraParams.ApplyFunc(self.ExtraParams.CloudData)
      EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_ON_APPLY_CLOUD_DATA)
    end)
    self:CloseSelf()
  end
end
function Setting_Cloud_Manage_Popups_UIBP:OnClickButtonDiff()
  if self.ExtraParams.ShowDiffFunc then
    self.ExtraParams.ShowDiffFunc(self.ExtraParams.CloudData)
    self:CloseSelf()
  end
end
function Setting_Cloud_Manage_Popups_UIBP:OnClickUpload()
  if self.ExtraParams.UploadFunc then
    UIManager.ShowUI(UIManager.UI_Config.SettingSaveToCloud_TipsUIBP, self.ExtraParams.UploadText, function()
      self.ExtraParams.UploadFunc()
      EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_ON_UPLOAD_CLOUD_DATA)
    end)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSetting_Cloud_Manage_Popups_UIBP = class(ui_base, nil, Setting_Cloud_Manage_Popups_UIBP)
return CSetting_Cloud_Manage_Popups_UIBP