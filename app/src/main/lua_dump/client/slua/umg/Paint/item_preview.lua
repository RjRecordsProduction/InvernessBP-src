local ItemPreviewMgr = {}
function ItemPreviewMgr:GetPreview(uiConfig, attachPoint)
  local parentUI = UIManager.GetUI(uiConfig)
  self.preview = parentUI:CreateChildWindow(attachPoint, UIManager.UI_Config.Paint_UIBP)
  return self.preview
end
function ItemPreviewMgr:Show(uiConfig, attachPoint, resId)
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  self:Destroy()
  local preview = self:GetPreview(uiConfig, attachPoint)
  if preview then
    preview:SetFeature(resId)
  end
  local endTime = getTime()
  log(bWriteLog and "ItemPreviewMgr:Show:" .. tostring((endTime - startTime) / 1000))
end
function ItemPreviewMgr:ShowNew(preview, resId)
  self:Destroy()
  if preview then
    self.    preview:SetFeature(resId)
  end
end
function ItemPreviewMgr:GetPreviewWithBpPath(uiConfig, bpPath, attachPoint)
  local parentUI = UIManager.GetUI(uiConfig)
  self.preview = parentUI:CreateChildWindowWithBpPath(attachPoint, UIManager.UI_Config.Paint_UIBP, bpPath)
  return self.preview
end
function ItemPreviewMgr:ShowWithBpPath(uiConfig, bpPath, attachPoint, resId)
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  self:Destroy()
  local preview = self:GetPreviewWithBpPath(uiConfig, bpPath, attachPoint)
  if preview then
    preview:SetFeature(resId)
  end
  local endTime = getTime()
  log(bWriteLog and "ItemPreviewMgr:Show:" .. tostring((endTime - startTime) / 1000))
end
function ItemPreviewMgr:SetScale(x, y)
  if self.preview then
    self.preview.UIRoot:SetRenderScale(FVector2D(x, y))
  end
end
function ItemPreviewMgr:Hide()
  if self.preview then
    self.preview:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ItemPreviewMgr:Destroy()
  if self.preview then
    UIManager.CloseUI(UIManager.UI_Config.Paint_UIBP)
    self.preview:Close()
    self.preview = nil
  end
end
return ItemPreviewMgr