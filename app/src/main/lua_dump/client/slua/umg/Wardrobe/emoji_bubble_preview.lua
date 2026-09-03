local EmojiBubblePreviewMgr = {}
local staticEmojiBluePrintPath = "/Game/UMG/UI_BP/Wardrobe/emojiBubble/EmojiBubble_static_UIBP.EmojiBubble_static_UIBP"
function EmojiBubblePreviewMgr:Show(resId, uiConfig, attachPoint)
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  self:Destroy()
  local cfg = CDataTable.GetTableData("EmojiBubblePreviewCfg", resId)
  if not cfg then
    return
  end
  local uiParent = UIManager.GetUI(uiConfig)
  local bpPath
  if cfg.StaticEmoji == 1 then
    bpPath = staticEmojiBluePrintPath
  else
    bpPath = cfg.BluePrintPath
  end
  self.preview = uiParent:CreateChildWindowWithBpPath(attachPoint, UIManager.UI_Config.EmojiBubblePreview, bpPath, resId)
  local endTime = getTime()
  log(bWriteLog and "EmojiBubblePreviewMgr:Show:" .. tostring((endTime - startTime) / 1000))
end
function EmojiBubblePreviewMgr:Destroy()
  if self.preview then
    self.preview:Close()
    self.preview = nil
  end
end
return EmojiBubblePreviewMgr