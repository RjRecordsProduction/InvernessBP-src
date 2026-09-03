local ui_right_bottom_util = {C_RightTopOffset = 210, C_RightBottomOffset = 125}
function ui_right_bottom_util.SetPosYByLobbyOrMainCity(target, lobbyPosY, mainCityPosY, offset)
  if not slua.isValid(target) or not slua.isValid(target.Slot) then
    log_warning(bWriteLog and "ui_right_bottom_util.SetPosYByLobbyOrMainCity. target or target.Slot is nil")
    return
  end
  offset = offset or FVector2D(0, 0)
  if not lobbyPosY or not mainCityPosY then
    ui_right_bottom_util.SetFitPosYByLobbyOrMainCity(target, offset)
    log_warning(bWriteLog and "ui_right_bottom_util.SetPosYByLobbyOrMainCity. lobbyPosY or mainCityPosY is nil")
    return
  end
  ui_right_bottom_util.SetBPPosYByLobbyOrMainCity(target, lobbyPosY, mainCityPosY)
end
function ui_right_bottom_util.SetFitPosYByLobbyOrMainCity(target, offset)
  local UIUtil = require("client.common.ui_util")
  if not slua.isValid(target) or not slua.isValid(target.Slot) then
    log_warning(bWriteLog and "ui_right_bottom_util.SetFitPosYByLobbyOrMainCity. target or target.Slot is nil")
    return
  end
  local canvasPanelScale = target:GetParent()
  if not canvasPanelScale or not slua.isValid(canvasPanelScale) then
    log_warning(bWriteLog and "ui_right_bottom_util.SetFitPosYByLobbyOrMainCity. canvasPanelScale is nil")
    return
  end
  local scaleBoxRoot = canvasPanelScale:GetParent()
  if not (scaleBoxRoot and slua.isValid(scaleBoxRoot)) or not scaleBoxRoot.SetStretch then
    log_warning(bWriteLog and "ui_right_bottom_util.SetFitPosYByLobbyOrMainCity. scaleBoxRoot is nil")
    return
  end
  local canvasPanelUnScale = scaleBoxRoot:GetParent()
  if not slua.isValid(canvasPanelUnScale) or canvasPanelUnScale:GetParent() ~= nil then
    log_warning(bWriteLog and "ui_right_bottom_util.SetFitPosYByLobbyOrMainCity. canvasPanelUnScale is nil")
    return
  end
  target.Slot:SetAlignment(FVector2D(0, 0))
  target.Slot:SetAnchors(FAnchors(0, 0, 0, 0))
  log_format("ui_right_bottom_util.SetFitPosYByLobbyOrMainCity. canvasPanelScale = %s, scaleBoxRoot = %s, canvasPanelUnScale = %s", canvasPanelScale.DisplayLabel, scaleBoxRoot.DisplayLabel, canvasPanelUnScale.DisplayLabel)
  local timer_ticker = require("common.time_ticker")
  timer_ticker.AddTimerOnce(0, function()
    if not (slua.isValid(target) and slua.isValid(canvasPanelScale)) or not slua.isValid(canvasPanelUnScale) then
      log_warning(bWriteLog and "ui_right_bottom_util.SetFitPosYByLobbyOrMainCity. widget is missing")
      return
    end
    local scaledPanelSize = UIUtil.GetLocalSize(canvasPanelScale)
    local unscaledPanelSize = UIUtil.GetLocalSize(canvasPanelUnScale)
    local ratioX = scaledPanelSize.X / unscaledPanelSize.X
    local ratioY = scaledPanelSize.Y / unscaledPanelSize.Y
    log_format("ui_right_bottom_util.SetFitPosYByLobbyOrMainCity scaledPanelSize = { x = %s, y = %s }, unscaledPanelSize = { x = %s, y = %s }, ratio = { x = %s, y = %s }", scaledPanelSize.X, scaledPanelSize.Y, unscaledPanelSize.X, unscaledPanelSize.Y, ratioX, ratioY)
    local viewPortScale = UIUtil.GetViewportScale()
    local screenSize = UIUtil.GetViewportSize() / viewPortScale
    log_format("ui_right_bottom_util.SetFitPosYByLobbyOrMainCity screenSize = { x = %s, y = %s }", screenSize.X, screenSize.Y)
    local targetSize = UIUtil.GetAbsoluteSize(target) / viewPortScale
    log_format("ui_right_bottom_util.SetFitPosYByLobbyOrMainCity targetSize = { x = %s, y = %s }", targetSize.X, targetSize.Y)
    local screenRightBorder = screenSize.X * ratioX
    local screenBottomBorder = screenSize.Y * ratioY
    local posX = screenRightBorder - targetSize.X - offset.X * ratioX
    local bottomPosY = screenBottomBorder - targetSize.Y - (ui_right_bottom_util.C_RightBottomOffset + offset.Y) * ratioY
    local topPosY = 0 + (ui_right_bottom_util.C_RightTopOffset + offset.Y) * ratioY
    log_format("ui_right_bottom_util.SetFitPosYByLobbyOrMainCity offset = { x = %s, y = %s}", offset.X, offset.Y)
    log_format("ui_right_bottom_util.SetFitPosYByLobbyOrMainCity posX = %s, bottomPosY = %s, topPosY = %s", posX, bottomPosY, topPosY)
    local isInMainCity = GameStatus.IsInMainCity()
    local targetPosY = isInMainCity and topPosY or bottomPosY
    target.slot:SetPosition(FVector2D(posX, targetPosY))
  end)
end
function ui_right_bottom_util.SetBPPosYByLobbyOrMainCity(target, lobbyPosY, mainCityPosY)
  if not slua.isValid(target) or not slua.isValid(target.Slot) then
    log_warning(bWriteLog and "ui_right_bottom_util.SetBPPosYByLobbyOrMainCity. target or target.Slot is nil")
    return
  end
  local slot = target.Slot
  local posY, anchor
  if GameStatus.IsIn2DLobby() then
    posY = lobbyPosY
    anchor = FAnchors(1, 1, 1, 1)
  elseif GameStatus.IsInMainCity() then
    posY = mainCityPosY
    anchor = FAnchors(1, 0, 1, 0)
  end
  if not posY then
    log_warning(bWriteLog and "ui_right_bottom_util.SetBPPosYByLobbyOrMainCity. posY is nil")
    return
  end
  log(bWriteLog and "ui_right_bottom_util.SetBPPosYByLobbyOrMainCity. anchor = ( minX = " .. anchor.Minimum.X .. ", minY = " .. anchor.Minimum.Y .. ", maxX = " .. anchor.Maximum.X .. ", maxY = " .. anchor.Maximum.Y .. ")")
  log(bWriteLog and "ui_right_bottom_util.SetBPPosYByLobbyOrMainCity. posY = " .. posY)
  local timer_ticker = require("common.time_ticker")
  timer_ticker.AddTimerOnce(0, function()
    if not slot or not slua.isValid(slot) then
      return
    end
    local oriPos = slot:GetPosition()
    slot:SetAnchors(anchor)
    slot:SetPosition(FVector2D(oriPos.X, posY))
  end)
end
function ui_right_bottom_util.ResetChangePosWidgetPosition(target, lobbyPosY, mainCityPosY)
  if not slua.isValid(target) or not slua.isValid(target.Slot) then
    log_warning(bWriteLog and "ui_right_bottom_util.ResetChangePosWidgetPosition. target or target.Slot is nil")
    return
  end
  if lobbyPosY or mainCityPosY then
    return
  end
  target.Slot:SetPosition(FVector2D(0, 0))
end
function ui_right_bottom_util.CloseRightPopUpPanel()
  local callback = function(_, uiConfig)
    UIManager.CloseUI(uiConfig)
  end
  ui_right_bottom_util._DoWithRightPopUpPanel(callback, true)
end
function ui_right_bottom_util.SwitchRightPopUpPanelPos()
  local callback = function(uiInfo, uiConfig)
    if uiInfo and uiInfo.SwitchPosInLobbyOrMainCity then
      log(bWriteLog and "ui_right_bottom_util.SwitchRightPopUpPanelPos. SwitchPosInLobbyOrMainCity keyName = " .. tostring(uiConfig and uiConfig.keyName))
      uiInfo:SwitchPosInLobbyOrMainCity()
    end
  end
  ui_right_bottom_util._DoWithRightPopUpPanel(callback)
end
function ui_right_bottom_util._DoWithRightPopUpPanel(doFunc, onlyOne)
  local hasDoFunc = doFunc ~= nil and type(doFunc) == "function"
  local changedList = {}
  local list = UIManager.GetTopUINameList(5)
  if 0 < #list then
    local count = 0
    for i = 1, #list do
      local uiConfig = UIManager.GetConfigByKey(list[i])
      local uiInfo = uiConfig and UIManager.GetUI(uiConfig)
      if uiInfo and uiInfo.UIRoot and uiInfo.UIRoot.LobbyPosY ~= nil and uiInfo.UIRoot.MainCityPosY ~= nil then
        if hasDoFunc then
          doFunc(uiInfo, uiConfig)
        end
        count = count + 1
        table.insert(changedList, uiConfig.keyName)
        if onlyOne then
          break
        end
      end
    end
  end
  local ui_show_queue_manager = require("client.common.uibase.ui_show_queue_manager")
  local queueShowUI = ui_show_queue_manager.sortListCurUI
  local table_util = require("common.table_util")
  log(bWriteLog and "ui_right_bottom_util._DoWithRightPopUpPanel queueShowUI = " .. tostring(queueShowUI))
  if queueShowUI and queueShowUI ~= "" and not table_util.IsInTable(changedList, queueShowUI) then
    local uiConfig = UIManager.GetConfigByKey(queueShowUI)
    local uiInfo = uiConfig and UIManager.GetUI(uiConfig)
    if uiInfo and hasDoFunc then
      doFunc(uiInfo, uiConfig)
    end
  end
end
return ui_right_bottom_util