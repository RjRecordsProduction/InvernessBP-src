local BIsInit, BVideoDelay, NoticeQueue, NoticeIndexes
local C_NOTICE_INDEX_CONTENT = 1
local C_NOTICE_INDEX_STYLE = 2
local NoticeMgr = {}
local Enum_Tips_Style = {
  Default = 1,
  Gold = 2,
  Interaction = 3,
  UpgradeNotice = 4
}
local Tips_Style_Config = {
  [Enum_Tips_Style.Default] = UIManager.UI_Config.PopupTipItem,
  [Enum_Tips_Style.Gold] = UIManager.UI_Config.ItemPopupUCBack_UIBP,
  [Enum_Tips_Style.Interaction] = UIManager.UI_Config.Chat_ScintillaTip_UIBP,
  [Enum_Tips_Style.UpgradeNotice] = UIManager.UI_Config.UpgradeItemPopUpItem
}
NoticeMgr.NoticeMgr.
function NoticeMgr.InitOnlyOne()
  if BIsInit then
    return
  end
  log(bWriteLog and "  : NoticeMgr Init")
  BIsInit = true
  EventSystem:registEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_STARTS, NoticeMgr.OnVideoStart)
  EventSystem:registEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, NoticeMgr.OnVideoEnd)
  EventSystem:registEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_UNLOCK, NoticeMgr.OnVideoEnd)
end
function NoticeMgr.OnModePostSwitch()
end
function NoticeMgr.InsertNotice(content, style)
  if not content then
    return
  end
  if not NoticeQueue then
    NoticeQueue = {}
  end
  if not NoticeIndexes then
    NoticeIndexes = {}
  end
  if NoticeIndexes[content] ~= nil then
    log(bWriteLog and "  : content is Exist " .. tostring(content))
    return
  end
  style = style or NoticeMgr.Enum_Tips_Style.Default
  table.insert(NoticeQueue, {content, style})
  NoticeMgr._ReHash(content)
  log(bWriteLog and "[NoticeIndexes]: NoticeIndexes[content]" .. tostring(NoticeIndexes[content]) .. "        " .. content)
  if 1 < #NoticeQueue then
    return
  end
  return true
end
function NoticeMgr.ShowNewNotice(content, style)
  log(bWriteLog and "  :NoticeMgr.ShowNewNotice  content:" .. tostring(content))
  if not NoticeMgr.InsertNotice(tostring(content), style) then
    return
  end
  NoticeMgr.ShowNextNotice()
end
function NoticeMgr.ShowNextNotice()
  local ui = UIManager.GetUI(UIManager.UI_Config.PopupTip)
  if not ui then
    ui = UIManager.ShowUI(UIManager.UI_Config.PopupTip)
  elseif ui:IsClosing() then
    log(bWriteLog and "  : PopupTip:IsClosing()")
    return
  end
  if BVideoDelay then
    log(bWriteLog and "  : BVideoDelay")
    return
  end
  if not NoticeQueue then
    NoticeQueue = {}
  end
  if 0 < #NoticeQueue then
    local notice = NoticeQueue[1] or {}
    if not ui then
      log(bWriteLog and "  : ShowNextNotice not ui, content = " .. tostring(notice[C_NOTICE_INDEX_CONTENT]))
      NoticeMgr.RemoveOneNotice(notice[C_NOTICE_INDEX_CONTENT])
    else
      ui:ShowNotice(notice[C_NOTICE_INDEX_CONTENT], notice[C_NOTICE_INDEX_STYLE])
    end
  else
    log(bWriteLog and "  : #NoticeQueue <= 0")
  end
end
function NoticeMgr._ReHash(content)
  if content then
    NoticeIndexes[content] = #NoticeQueue
    return
  end
  for index, notice in pairs(NoticeQueue) do
    NoticeIndexes[notice[1]] = index
  end
end
function NoticeMgr.RemoveOneNotice(content)
  log(bWriteLog and "  : RemoveOneNotice " .. tostring(content))
  if not NoticeIndexes then
    return
  end
  if content then
    local index = NoticeIndexes[content]
    if index then
      log(bWriteLog and "  : content" .. index)
      table.remove(NoticeQueue, index)
      NoticeIndexes[content] = nil
      NoticeMgr._ReHash()
      NoticeMgr.ShowNextNotice()
    end
  end
end
function NoticeMgr.RemoveAllNotice()
  log(bWriteLog and "  : NoticeMgr.RemoveAllNotice")
  NoticeQueue = {}
  NoticeIndexes = {}
  EventSystem:postEvent(EVENTTYPE_REMOVE_NOTICE, EVENTID_REMOVE_NOTICE)
end
function NoticeMgr.OnVideoStart()
  local IS_Show_10Animation = GlobalData.GetMallShow10Animation()
  if IS_Show_10Animation then
    return
  end
  BVideoDelay = true
  log(bWriteLog and "  :VideoChange BVideoDelay" .. tostring(BVideoDelay))
  NoticeMgr.RemoveAllNotice()
end
function NoticeMgr.OnVideoEnd()
  if not BVideoDelay then
    return
  end
  BVideoDelay = false
  log(bWriteLog and "  :VideoChange BVideoDelay" .. tostring(BVideoDelay))
  NoticeMgr.ShowNextNotice()
end
function NoticeMgr.ShowHoldNotice(content)
  local ui = UIManager.GetUI(UIManager.UI_Config.PopupTip)
  if not ui then
    ui = UIManager.ShowUI(UIManager.UI_Config.PopupTip)
  elseif ui:IsClosing() then
    log(bWriteLog and "  : PopupTip:IsClosing()")
    return
  end
  ui:ShowHoldNotice(content)
end
function NoticeMgr.HideHoldNotice()
  local ui = UIManager.GetUI(UIManager.UI_Config.PopupTip)
  if not ui then
    return
  end
  ui:HideHoldNotice()
end
return NoticeMgr