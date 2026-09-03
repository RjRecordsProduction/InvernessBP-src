local logic_teammate_info = require("client.slua.umg.MainCity.Lobby_Friend.logic_teammate_info")
local Common_Certification_UIBP = {}
function Common_Certification_UIBP:RegistEvents()
  self:AddControlEvent(self.Button_Tips, "OnClicked", self.OnClickTips, self)
end
function Common_Certification_UIBP:OnPostInitialize()
  log(bWriteLog and "Common_Certification_UIBP:Construct self.OnlyImage = " .. tostring(self.OnlyImage))
  if self.OnlyImage then
    self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  else
    self.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  end
end
function Common_Certification_UIBP:SetAuthInfo(authType, authEndTime)
  log(bWriteLog and "Common_Certification_UIBP:SetAuthInfo authType = " .. tostring(authType) .. ", authEndTime = " .. tostring(authEndTime))
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if not logic_teammate_info.CheckAuthInfoOpen(authType, authEndTime) then
    return false
  end
  local authCfg = CDataTable.GetTableData("AuthTitleTable", authType)
  self.titleName = authCfg.AuthTypeText
  self.TextBlock_Title:SetText(self.titleName)
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  return true
end
function Common_Certification_UIBP:SetTextFontSize(fontSize)
  if not fontSize then
    log(bWriteLog and "Common_Certification_UIBP:SetTextFontSize not fontSize")
    return
  end
  local font = self.TextBlock_Title.Font
  font.Size = fontSize
  self.TextBlock_Title:SetFont(font)
end
function Common_Certification_UIBP:SetTextLight()
  self.TextBlock_Title:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
end
function Common_Certification_UIBP:SetImageSize(sizeX, sizeY)
  if not sizeX or not sizeY then
    log(bWriteLog and "Common_Certification_UIBP:SetImageSize invalid param")
    return
  end
  local brush = slua.IndexReference(self.Image_Certification2, "Brush"):clone()
  brush.ImageSize = FVector2D(sizeX, sizeY)
  self.Image_Certification2:SetBrush(brush)
end
function Common_Certification_UIBP:OnClickTips()
  if not self.titleName then
    log(bWriteLog and "Common_Certification_UIBP:OnClickTips not self.titleName")
  end
  local tipsParam = {
    widget = self.Button_Tips,
    title = self.titleName
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tipsParam)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Common_Certification_UIBP)