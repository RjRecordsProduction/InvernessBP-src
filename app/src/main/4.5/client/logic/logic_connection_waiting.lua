logic_connection_waiting = logic_connection_waiting or {
  curTime = 0,
  isShowing = false,
  bLogicWait = false,
  bOldProtocol = false,
  bNewProtocol = false,
  bShowAniMap = {}
}
function logic_connection_waiting:Show(nType, bShowAni, bImmediatelyShow, textTips)
  nType = nType or 0
  if bShowAni == nil then
    logic_connection_waiting.bShowAniMap[nType] = true
  else
    logic_connection_waiting.bShowAniMap[nType] = bShowAni
  end
  if nType == 0 then
    if logic_connection_waiting.bLogicWait then
      return
    else
      logic_connection_waiting.bLogicWait = true
    end
  elseif nType == 1 then
    if logic_connection_waiting.bOldProtocol then
      return
    else
      logic_connection_waiting.bOldProtocol = true
    end
  elseif nType == 2 then
    if logic_connection_waiting.bNewProtocol then
      return
    else
      logic_connection_waiting.bNewProtocol = true
    end
  end
  local LoadingUI = UIManager.GetUI(UIManager.UI_Config.loading)
  if LoadingUI then
    return
  end
  local isShowAnim = logic_connection_waiting.bShowAniMap[nType]
  log(bWriteLog and "logic_connection_waiting:Show nType = " .. nType .. ", isShowAnim = " .. tostring(isShowAnim))
  if not UIManager.IsUIShow(UIManager.UI_Config.connect_wait) then
    UIManager.ShowUI(UIManager.UI_Config.connect_wait, isShowAnim, bImmediatelyShow, textTips)
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.connect_wait)
  if ui then
    ui:SwitchAnimState(isShowAnim)
    ui:SwitchImmediatelyShow(bImmediatelyShow)
    ui:ShowTips(textTips)
  end
end
function logic_connection_waiting:Hide(nType)
  nType = nType or 0
  if nType == 0 then
    logic_connection_waiting.bLogicWait = false
  elseif nType == 1 then
    logic_connection_waiting.bOldProtocol = false
  elseif nType == 2 then
    logic_connection_waiting.bNewProtocol = false
  end
  local showType = 0
  if logic_connection_waiting.bOldProtocol then
    showType = logic_connection_waiting.bShowAniMap[1]
  elseif logic_connection_waiting.bNewProtocol then
    showType = logic_connection_waiting.bShowAniMap[2]
  elseif logic_connection_waiting.bLogicWait then
    showType = logic_connection_waiting.bShowAniMap[0]
  end
  if logic_connection_waiting.bLogicWait or logic_connection_waiting.bOldProtocol or logic_connection_waiting.bNewProtocol then
    log(bWriteLog and "logic_connection_waiting:Hide Show nType = " .. nType .. ", showType = " .. tostring(showType))
    local ui = UIManager.GetUI(UIManager.UI_Config.connect_wait)
    if ui then
      ui:SwitchAnimState(showType)
    end
  elseif UIManager.IsUIShow(UIManager.UI_Config.connect_wait) then
    log(bWriteLog and "logic_connection_waiting:Hide Hide nType = " .. nType)
    UIManager.HideUI(UIManager.UI_Config.connect_wait)
  end
end
function logic_connection_waiting:ShowNoBlock()
  if not UIManager.IsUIShow(UIManager.UI_Config.connect_wait_without_block) then
    UIManager.ShowUI(UIManager.UI_Config.connect_wait_without_block)
  end
end
function logic_connection_waiting:HideNoBlock()
  UIManager.HideUI(UIManager.UI_Config.connect_wait_without_block)
end