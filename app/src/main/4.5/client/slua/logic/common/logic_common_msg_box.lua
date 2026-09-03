local CommonMsgBoxMgr = {
  SHOW_TYPE_ONE = 1,
  SHOW_TYPE_TWO = 2,
  SHOW_TYPE_THREE = 3,
  SHOW_TYPE_FOUR = 4,
  SHOW_TYPE_FIVE = 5,
  sCurrShowUIKey = nil
}
local ShowDataList = {}
local C_DefaultUIKey = "com_msg_box_slua"
function CommonMsgBoxMgr.Show(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
  if msg then
    log(bWriteLog and "CommonMsgBoxMgr.Show msg: " .. tostring(msg))
  end
  for _, v in ipairs(ShowDataList) do
    if v.msg == msg then
      log(bWriteLog and "CommonMsgBoxMgr.Show Same Msg ")
      return false
    end
  end
  local currentShowUI = UIManager.GetUI(CommonMsgBoxMgr.GetCurrUIConfig())
  if currentShowUI and currentShowUI.msg and currentShowUI.msg == msg then
    log(bWriteLog and "CommonMsgBoxMgr.Show current UI has Same Msg ")
    return
  end
  local extra = {}
  if extraData and type(extraData) == "table" then
    for key, value in pairs(extraData) do
      extra[key] = value
    end
  end
  local msgData = {
    styleType = styleType,
    title = title,
    msg = msg,
    clickOkCallback = clickOkCallback,
    clickCancelCallback = clickCancelCallback,
    btnOK = btnOK,
    btnCancel = btnCancel,
    extraData = extra
  }
  table.insert(ShowDataList, msgData)
  if currentShowUI then
    log(bWriteLog and "CommonMsgBoxMgr.Show return has existing panel ")
    return false
  end
  if extra.showUIKey and extra.showUIKey ~= "" then
    CommonMsgBoxMgr.SetCurrShowUIKey(extra.showUIKey)
  else
    CommonMsgBoxMgr.SetCurrShowUIKey(C_DefaultUIKey)
  end
  CommonMsgBoxMgr.ShowNextMsgBox()
  return true
end
function CommonMsgBoxMgr.ShowUSPolicyTip(msgData, extraData, dontCheckNeedPolicy)
  msgData = msgData or {}
  extraData = extraData or {}
  if not dontCheckNeedPolicy then
    CommonMsgBoxMgr._CheckIsUSNeedPolicy(extraData)
  end
  return CommonMsgBoxMgr.Show(msgData.styleType, msgData.title, msgData.msg, msgData.clickOkCallback, msgData.clickCancelCallback, msgData.btnOK, msgData.btnCancel, extraData)
end
function CommonMsgBoxMgr.ShowTPlan(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
  extraData = extraData or {}
  extraData.showUIKey = "xmission_com_msg_box"
  CommonMsgBoxMgr.Show(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
end
function CommonMsgBoxMgr.OnOneMsgBoxClose()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.05, function()
    CommonMsgBoxMgr.ShowNextMsgBox()
  end)
end
function CommonMsgBoxMgr.ShowNextMsgBox()
  local ui = UIManager.GetUI(CommonMsgBoxMgr.GetCurrUIConfig())
  if ui then
    log(bWriteLog and "CommonMsgBoxMgr:ShowNextPanel Has Panel")
    return
  end
  if ShowDataList[1] then
    local ParamTable, showUIKey
    log_tree("CommonMsgBoxMgr:ShowNextPanel", ShowDataList[1])
    if ShowDataList[1].extraData then
      local extraData = ShowDataList[1].extraData
      showUIKey = extraData.showUIKey
      ParamTable = extraData.ParamTable
    end
    CommonMsgBoxMgr.SetCurrShowUIKey(showUIKey or C_DefaultUIKey)
    local uiInfo, isInQueue = UIManager.ShowUI(CommonMsgBoxMgr.GetCurrUIConfig(), ShowDataList[1], ParamTable)
    if uiInfo or isInQueue then
      table.remove(ShowDataList, 1)
    end
  else
    log(bWriteLog and "CommonMsgBoxMgr:ShowNextPanel No data")
  end
end
function CommonMsgBoxMgr.HidePanel()
  log(bWriteLog and "CommonMsgBoxMgr:HidePanel")
  UIManager.CloseUI(CommonMsgBoxMgr.GetCurrUIConfig())
end
function CommonMsgBoxMgr.HideAllPanel()
  log(bWriteLog and "CommonMsgBoxMgr:Hide AllMessageBox")
  ShowDataList = {}
  UIManager.CloseUI(CommonMsgBoxMgr.GetCurrUIConfig())
end
function CommonMsgBoxMgr.HideConnectionPanel()
  log(bWriteLog and "CommonMsgBoxMgr HideConnectionPanel")
  local needHideCurPanel = false
  local curConfig = CommonMsgBoxMgr.GetCurrUIConfig()
  local uiInfo = UIManager.GetUI(curConfig)
  if uiInfo and uiInfo.extraData.isConnectionPanel then
    needHideCurPanel = true
  end
  local index = 2
  while ShowDataList and 0 < #ShowDataList and index <= #ShowDataList do
    if ShowDataList[index].extraData.isConnectionPanel then
      log(bWriteLog and "CommonMsgBoxMgr HideConnectionPanel Remove One ConnectPanel")
      table.remove(ShowDataList, index)
    else
      index = index + 1
    end
  end
  if needHideCurPanel then
    UIManager.CloseUI(curConfig)
  end
end
function CommonMsgBoxMgr.GetCurrUIConfig()
  return UIManager.UI_Config[CommonMsgBoxMgr.GetCurrShowUIKey()]
end
function CommonMsgBoxMgr.GetCurrShowUIKey()
  return CommonMsgBoxMgr.sCurrShowUIKey or C_DefaultUIKey
end
function CommonMsgBoxMgr.SetCurrShowUIKey(CurrShowUIKey)
  CommonMsgBoxMgr.send
function CommonMsgBoxMgr.UpdateMsg(msg)
  log(bWriteLog and "CommonMsgBoxMgr.UpdateMsg")
  local ui = UIManager.GetUI(CommonMsgBoxMgr.GetCurrUIConfig())
  if ui then
    ui:UpdateMsg(msg)
  end
end
function CommonMsgBoxMgr.UpdateOKText(txt)
  log(bWriteLog and "CommonMsgBoxMgr.UpdateOKText")
  local ui = UIManager.GetUI(CommonMsgBoxMgr.GetCurrUIConfig())
  if ui then
    ui:UpdateOKText(txt)
  end
end
function CommonMsgBoxMgr.EnableOKBtn()
  local ui = UIManager.GetUI(CommonMsgBoxMgr.GetCurrUIConfig())
  if ui then
    log(bWriteLog and "CommonMsgBoxMgr.EnableOKBtn")
    ui:EnableOKBtn()
  end
end
function CommonMsgBoxMgr.DisableOKBtn()
  local ui = UIManager.GetUI(CommonMsgBoxMgr.GetCurrUIConfig())
  if ui then
    log(bWriteLog and "CommonMsgBoxMgr.DisableOKBtn")
    ui:DisableOKBtn()
  end
end
function CommonMsgBoxMgr._CheckIsUSNeedPolicy(extraData)
  local isUS = DataMgr.CheckIsNeedUSAPolicy()
  if isUS then
    extraData.policyTips = extraData.policyTips or LocUtil.GetLocalizeResStr(300001)
    extraData.policyHandler = extraData.policyHandler or function()
      local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
      LeagalMsgSystem.ShowUserAgreement()
    end
  else
    extraData.policyTips = nil
    extraData.policyHandler = nil
  end
end
function CommonMsgBoxMgr.IsShowDataListEmpty()
  return #ShowDataList == 0
end
return CommonMsgBoxMgr