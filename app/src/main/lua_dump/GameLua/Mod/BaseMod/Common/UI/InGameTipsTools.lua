local IngameTipsTools = {}
function IngameTipsTools.BattleGeneralTip(tipsID, param1, param2, PlayerKey, IsToAll)
  if Client then
    BattleGeneralTip(tipsID, param1, param2)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    CGame:UIShowTips("BattleGeneralTip", PlayerKey or 0, tipsID, param1 or "", param2 or "", IsToAll or false)
  end
end
function IngameTipsTools.BattleNormalTipsByTextID(tipsID, param1, param2, controlTime, PlayerKey, IsToAll)
  if Client then
    BattleNormalTipsByTextID(tipsID, param1, param2, controlTime)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    if controlTime == nil or type(controlTime) ~= "number" or controlTime <= 0 then
      CGame:UIShowTips("BattleNormalTipsByTextID", PlayerKey or 0, tipsID, param1 or "", param2 or "", IsToAll or false)
    else
      CGame:UIShowTipsWithTime("BattleNormalTipsByTextID", PlayerKey or 0, tipsID, param1 or "", param2 or "", IsToAll or false, controlTime or 1)
    end
  end
end
function IngameTipsTools.BattleNormalTipsByTextIDAndDefaultConfig(tipsID, param1, param2, controlTime, PlayerKey, IsToAll)
  if Client then
    BattleNormalTipsByTextIDAndDefaultConfig(tipsID, param1, param2, controlTime)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    if controlTime == nil or type(controlTime) ~= "number" or controlTime <= 0 then
      CGame:UIShowTips("BattleNormalTipsByTextIDAndDefaultConfig", PlayerKey or 0, tipsID, param1 or "", param2 or "", IsToAll or false)
    else
      CGame:UIShowTipsWithTime("BattleNormalTipsByTextIDAndDefaultConfig", PlayerKey or 0, tipsID, param1 or "", param2 or "", IsToAll or false, controlTime or 1)
    end
  end
end
function IngameTipsTools.BattleGeneralTipWithTranslation(tipsID, EncodeParams, PlayerKey, IsToAll)
  if Client then
    BattleGeneralTipWithTranslation(tipsID, EncodeParams)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, EncodeParams)
    CGame:UIShowCustomTips("BattleGeneralTipWithTranslation", PlayerKey or 0, tipsID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleGeneralShowItemTipsByTextID(TipsID, EncodeParams, PlayerKey, IsToAll)
  if Client then
    ShowItemTipsByTextID(TipsID, EncodeParams)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, EncodeParams)
    CGame:UIShowCustomTips("ShowItemTipsByTextID", PlayerKey or 0, TipsID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleGeneralTipWithExternTable(tipsID, ExternTable, PlayerKey, IsToAll)
  if Client then
    BattleGeneralTipWithExternTable(tipsID, ExternTable)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, ExternTable)
    CGame:UIShowCustomTips("BattleGeneralTipWithExternTableFromServer", PlayerKey or 0, tipsID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleGeneralTranslateTip(tipsID, params, PlayerKey, IsToAll)
  if Client then
    BattleGeneralTranslateTip(tipsID, params)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, params)
    CGame:UIShowCustomTips("BattleGeneralTranslateTip", PlayerKey or 0, tipsID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleGeneralTipWithParams(tipsID, paramTable, PlayerKey, IsToAll)
  if Client then
    BattleGeneralTipWithParams(tipsID, paramTable)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, paramTable)
    CGame:UIShowCustomTips("BattleGeneralTipWithParams", PlayerKey or 0, tipsID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleGeneralSAPTipWithParams(tipsID, paramTable, PlayerKey, IsToAll)
  if Client then
    BattleGeneralSAPTipWithParams(tipsID, paramTable)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, paramTable)
    CGame:UIShowCustomTips("BattleGeneralSAPTipWithParams", PlayerKey or 0, tipsID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleGeneralSAPTip(tipsID, param1, param2, PlayerKey, IsToAll)
  if Client then
    BattleGeneralSAPTip(tipsID, param1, param2)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    CGame:UIShowTips("BattleGeneralSAPTip", PlayerKey or 0, tipsID, param1 or "", param2 or "", IsToAll or false)
  end
end
function IngameTipsTools.BattleStopGeneralTip(tipsID, PlayerKey, IsToAll)
  if Client then
    BattleStopGeneralTip(tipsID)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    CGame:UIShowTips("BattleStopGeneralTip", PlayerKey or 0, tipsID, "", "", IsToAll or false)
  end
end
function IngameTipsTools.BattleNormalTips(tipsContent, tipsAnimType, controlTime)
  if not Client then
    return
  end
  BattleNormalTips(tipsContent, tipsAnimType, controlTime)
end
function IngameTipsTools.BattleNormalTipsByTextIDAndTipsValue(tipsID, param1, param2, controlTime, tipsValue)
  if not Client then
    return
  end
  BattleNormalTipsByTextIDAndTipsValue(tipsID, param1, param2, controlTime, tipsValue)
end
function IngameTipsTools.BattleNormalTipsByTextIDAndParams(textID, paramTable, controlTime, PlayerKey, IsToAll)
  if Client then
    BattleNormalTipsByTextIDAndParams(textID, paramTable, controlTime)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, paramTable)
    CGame:UIShowCustomTips("BattleNormalTipsByTextIDAndParams", PlayerKey or 0, textID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleNormalSAPTipsByTextIDAndParams(textID, paramTable, controlTime, PlayerKey, IsToAll)
  if Client then
    BattleNormalSAPTipsByTextIDAndParams(textID, paramTable, controlTime)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, paramTable)
    CGame:UIShowCustomTips("BattleNormalSAPTipsByTextIDAndParams", PlayerKey or 0, textID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleNormalSAPTipsByTextID(textID, param1, param2, controlTime, PlayerKey, IsToAll)
  if Client then
    BattleNormalSAPTipsByTextID(textID, param1, param2, controlTime)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    CGame:UIShowTips("BattleNormalSAPTipsByTextID", PlayerKey or 0, textID, param1 or "", param2 or "", IsToAll or false)
  end
end
function IngameTipsTools.BattleGeneralTipWithSetting(tipsID, EncodeParams, PlayerKey, IsToAll)
  if Client then
    BattleGeneralTipWithSetting(tipsID, EncodeParams)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, EncodeParams)
    CGame:UIShowCustomTips("BattleGeneralTipWithSetting", PlayerKey or 0, tipsID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleGeneralShowNormalTipsByTextIDAlias(tipsID, param1, param2)
  if not Client then
    return
  end
  ShowNormalTipsByTextIDAlias(tipsID, param1, param2)
end
function IngameTipsTools.BattleWariningTipsByTextID(tipsID, param1, param2)
  if not Client then
    return
  end
  BattleWariningTipsByTextID(tipsID, param1, param2)
end
function IngameTipsTools.BattleWariningTipsByTextIDWithSpeed(tipsID, animationSpeed, param1, param2)
  if not Client then
    return
  end
  BattleWariningTipsByTextIDWithSpeed(tipsID, animationSpeed, param1, param2)
end
function IngameTipsTools.BattleBottomKillTips(messageData)
  if not Client then
    return
  end
  BattleBottomKillTips(messageData)
end
function IngameTipsTools.ClearBattleGeneralTip()
  if not Client then
    return
  end
  ClearBattleGeneralTip()
end
function IngameTipsTools.BattleGeneralShowItemTipsByTextID2(TipsID, Param1, Param2, controlTime)
  if not Client then
    return
  end
  ShowItemTipsByTextID2(TipsID, Param1, Param2, controlTime)
end
function IngameTipsTools.BattleGeneralShowItemTipsWithAllTextID(TipsID, EncodeParams, PlayerKey, IsToAll)
  if Client then
    ShowItemTipsWithAllTextID(TipsID, EncodeParams)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, EncodeParams)
    CGame:UIShowCustomTips("ShowItemTipsWithAllTextID", PlayerKey or 0, TipsID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.BattleGeneralShowTipsByAllTextID(TipsID, EncodeParams, PlayerKey, IsToAll)
  if Client then
    ShowTipsByAllTextID(TipsID, EncodeParams)
  else
    if PlayerKey == nil or PlayerKey <= 0 then
      IsToAll = true
      PlayerKey = 0
    end
    local ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, EncodeParams)
    CGame:UIShowCustomTips("ShowTipsByAllTextID", PlayerKey or 0, TipsID, ExpandDataContent or {}, IsToAll or false)
  end
end
function IngameTipsTools.ClientCallPartnerTips(_, EncodeParams)
  if not Client then
    return
  end
  ClientCallSidePopupTips(_, EncodeParams)
end
local GetCommonMsgBoxMgr = function()
  if not Client then
    return nil
  end
  return require("client.slua.logic.common.logic_common_msg_box")
end
IngameTipsTools.MSGBOX_SHOW_TYPE_ONE = 1
IngameTipsTools.MSGBOX_SHOW_TYPE_TWO = 2
IngameTipsTools.MSGBOX_SHOW_TYPE_THREE = 3
IngameTipsTools.MSGBOX_SHOW_TYPE_FOUR = 4
function IngameTipsTools.ShowMsgBox(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
  if not Client then
    return false
  end
  local CommonMsgBoxMgr = GetCommonMsgBoxMgr()
  if not CommonMsgBoxMgr then
    return false
  end
  return CommonMsgBoxMgr.Show(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
end
function IngameTipsTools.ShowMsgBoxEdit(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
  if not Client then
    return false
  end
  local CommonMsgBoxMgr = GetCommonMsgBoxMgr()
  if not CommonMsgBoxMgr then
    return false
  end
  extraData = extraData or {}
  extraData.showUIKey = "com_msg_box_ingame_slua"
  extraData.OKBgUrl = "/Game/Mod/CreativeBase/Arts/Atlas/Common_New/Frames/Common_Btn_Huangse_png.Common_Btn_Huangse_png"
  return CommonMsgBoxMgr.Show(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
end
function IngameTipsTools.ShowMsgBoxWithUSPolicy(msgData, extraData, dontCheckNeedPolicy)
  if not Client then
    return false
  end
  local CommonMsgBoxMgr = GetCommonMsgBoxMgr()
  if not CommonMsgBoxMgr then
    return false
  end
  return CommonMsgBoxMgr.ShowUSPolicyTip(msgData, extraData, dontCheckNeedPolicy)
end
function IngameTipsTools.ShowTPlanMsgBox(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
  if not Client then
    return
  end
  local CommonMsgBoxMgr = GetCommonMsgBoxMgr()
  if not CommonMsgBoxMgr then
    return
  end
  CommonMsgBoxMgr.ShowTPlan(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
end
function IngameTipsTools.HideAllMsgBox()
  if not Client then
    return
  end
  local CommonMsgBoxMgr = GetCommonMsgBoxMgr()
  if not CommonMsgBoxMgr then
    return
  end
  CommonMsgBoxMgr.HideAllPanel()
end
function IngameTipsTools.HideMsgBox()
  if not Client then
    return
  end
  local CommonMsgBoxMgr = GetCommonMsgBoxMgr()
  if not CommonMsgBoxMgr then
    return
  end
  CommonMsgBoxMgr.HidePanel()
end
function IngameTipsTools.HideConnectionMsgBox()
  if not Client then
    return
  end
  local CommonMsgBoxMgr = GetCommonMsgBoxMgr()
  if not CommonMsgBoxMgr then
    return
  end
  CommonMsgBoxMgr.HideConnectionPanel()
end
function IngameTipsTools.GetCurrMsgBoxUIConfig()
  if not Client then
    return nil
  end
  local CommonMsgBoxMgr = GetCommonMsgBoxMgr()
  if not CommonMsgBoxMgr then
    return nil
  end
  return CommonMsgBoxMgr.GetCurrUIConfig()
end
function IngameTipsTools.GetCurrMsgBoxUIKey()
  if not Client then
    return nil
  end
  local CommonMsgBoxMgr = GetCommonMsgBoxMgr()
  if not CommonMsgBoxMgr then
    return nil
  end
  return CommonMsgBoxMgr.GetCurrShowUIKey()
end
return IngameTipsTools