local M = {}
local STATIC_TEXT_LOC_ID = {SameLanguage = 7470, TeammateMatch = 29862}
function M.IsSameLanguageMatchOn()
  local matchLang = DataMgr and DataMgr.MatchLanguage
  return matchLang and matchLang.only_match == true
end
function M.IsSameLanguageMatchEffective()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() and not TeamUpNewSystem.IsTeamLeader() then
    local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
    local team_match_langs = LanguageSelectSystem.GetTeamMatchLanguage()
    return team_match_langs.only_match
  end
  if not M.IsSameLanguageMatchOn() then
    return false
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  return not MatchSystem.IsSameLanguageMatchTimeOut()
end
function M.IsTeammateMatchOn()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local filterInfo = logic_mode_selection and logic_mode_selection:GetFilterInfo()
  return filterInfo and filterInfo.bAutoFill == true
end
function M.ApplyMatchToggleVisual(uiBase, textWidget, checkBox, bOn)
  if textWidget and textWidget.SetActiveColorIndex then
    textWidget:SetActiveColorIndex(bOn and 0 or 1)
  end
  if checkBox then
    checkBox:SetCheckedState(bOn and 1 or 0)
  end
end
function M.SetMatchTeamStatusIndex(uiBase, bAbnormal)
  local switcher = uiBase and uiBase.UIRoot and uiBase.UIRoot.WidgetSwitcher_MatchAndTeamStatus
  if not switcher then
    return
  end
  local nTargetIndex = bAbnormal and 1 or 0
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local bIsUGC = false
  if logic_ugc_mode then
    bIsUGC = logic_ugc_mode:IsSelectUgcMode()
  end
  if bIsUGC then
    if switcher:GetActiveWidgetIndex() == 1 then
      uiBase:SetWidgetVisible(switcher, bAbnormal)
    else
      M.CheckShowSwitcher(uiBase, bAbnormal)
    end
  else
    M.CheckShowSwitcher(uiBase)
  end
  if switcher.GetActiveWidgetIndex and switcher:GetActiveWidgetIndex() == nTargetIndex then
    return
  end
  local uiRoot = uiBase.UIRoot
  local anim = bAbnormal and uiRoot.Anim_Refresh_01 or uiRoot.Anim_Refresh_02
  if anim and uiBase.PlayUserWidgetAnimation then
    uiBase:PlayUserWidgetAnimation(anim, 0, 1, 0, 1)
    if uiBase.RecoverAlpha then
      local name = bAbnormal and "Anim_Refresh_01" or "Anim_Refresh_02"
      uiBase:RecoverAlpha(name, bAbnormal)
    end
    switcher:SetActiveWidgetIndex(nTargetIndex)
    log(bWriteLog and "SetMatchTeamStatusIndex", "fallback1", nTargetIndex)
  else
    switcher:SetActiveWidgetIndex(nTargetIndex)
    log(bWriteLog and "SetMatchTeamStatusIndex", "fallback2", nTargetIndex)
  end
end
function M.UpdateMatchPreInfoBar(uiBase)
  if not uiBase or not uiBase.UIRoot then
    return
  end
  local uiRoot = uiBase.UIRoot
  local panel = uiRoot.CanvasPanel_Match
  if not panel then
    return
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local bExcludedScene = MatchModeMgrSystem.bIsMatchingSocialIsland or MatchModeMgrSystem.bIsMatchingTrainMode
  M.CheckShowSwitcher(uiBase)
  if bExcludedScene then
    return
  end
  local bSameLangMatchOn = M.IsSameLanguageMatchEffective()
  local bTeammateMatchOn = M.IsTeammateMatchOn()
  log(bWriteLog and string.format("match_pre_info_bar_helper.UpdateMatchPreInfoBar bSameLang=%s bTeammate=%s", tostring(bSameLangMatchOn), tostring(bTeammateMatchOn)))
  M.ApplyMatchToggleVisual(uiBase, uiRoot.TextBlock_SameLanguage, uiRoot.CheckBox_SameLanguage, bSameLangMatchOn)
  local arrow = uiRoot.Image_Arrow
  if arrow and arrow.SetActiveColorIndex then
    local bAnyOn = bSameLangMatchOn or bTeammateMatchOn
    arrow:SetActiveColorIndex(bAnyOn and 0 or 1)
  end
end
function M.PlaySameLanguageTimeoutAnim(uiBase)
  if not uiBase or not uiBase.UIRoot then
    return
  end
  local anim = uiBase.UIRoot.Anim_Switch_Match
  if anim and uiBase.PlayUserWidgetAnimation then
    uiBase:PlayUserWidgetAnimation(anim, 0, 1, 0, 1)
  end
end
function M.PlaySameLanguageRecoverAnim(uiBase)
  if not uiBase or not uiBase.UIRoot then
    return
  end
  local anim = uiBase.UIRoot.Anim_Switch_Match
  if anim and uiBase.PlayUserWidgetAnimation then
    uiBase:PlayUserWidgetAnimation(anim, 0, 1, 1, 1)
  end
end
function M.OpenMatchSettingPopup(modeMenuId)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_MatchSettingAndStatus_UIBP, {PageIndex = 1, ModeMenuId = modeMenuId})
end
function M.SetMatchPreInfoBarStaticText(uiBase)
  if not uiBase or not uiBase.UIRoot then
    return
  end
  local uiRoot = uiBase.UIRoot
  if uiRoot.TextBlock_SameLanguage then
    uiRoot.TextBlock_SameLanguage:SetText(LocUtil.GetLocalizeResStr(STATIC_TEXT_LOC_ID.SameLanguage))
  end
end
function M.CheckShowSwitcher(uiBase, bAbnormal)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local bExcludedScene = MatchModeMgrSystem.bIsMatchingSocialIsland or MatchModeMgrSystem.bIsMatchingTrainMode
  local bIsXmission = false
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  log(bWriteLog and "match_pre_info_bar_helper:CheckShowSwitcher IsInXMission " .. tostring(LogicTxMissionMain.IsInXMission(true)))
  if LogicTxMissionMain.IsInXMission(true) then
    log(bWriteLog and "match_pre_info_bar_helper:CheckShowSwitcher IsInXMission return false")
    bIsXmission = true
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection then
    log(bWriteLog and "match_pre_info_bar_helper:CheckShowSwitcher logic_mode_selection " .. tostring(logic_mode_selection.hasSelectTxMission))
    if logic_mode_selection.hasSelectTxMission then
      bIsXmission = true
    end
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local bIsUGC = false
  if logic_ugc_mode then
    bIsUGC = logic_ugc_mode:IsSelectUgcMode()
  end
  local uiRoot = uiBase.UIRoot
  local switcher = uiRoot.WidgetSwitcher_MatchAndTeamStatus
  if switcher then
    uiBase:SetWidgetVisible(switcher, not bExcludedScene and not bIsXmission)
    uiBase:SetWidgetVisible(uiRoot.Spacer_2, bExcludedScene or not not bIsXmission)
    if bIsUGC then
      if not bAbnormal then
        uiBase:SetWidgetVisible(switcher, false)
        uiBase:SetWidgetVisible(uiRoot.Spacer_2, true)
      else
        uiBase:SetWidgetVisible(switcher, true)
        uiBase:SetWidgetVisible(uiRoot.Spacer_2, false)
      end
    end
  end
end
function M.OnClickedCheckBox(isCheck)
  log(bWriteLog and "match_pre_info_bar_helper:OnClickedCheckBox isCheck " .. tostring(isCheck))
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local bIsInTeam = TeamUpNewSystem.IsInTeam() and not TeamUpNewSystem.IsTeamLeader()
  if bIsInTeam then
    ShowNotice(500062)
    return
  end
  local bSameLanguage = isCheck and true or false
  local matchLang = DataMgr and DataMgr.MatchLanguage
  if not (matchLang and next(matchLang)) or not matchLang[1] then
    return
  end
  local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
  LanguageSelectSystem.MatchLanguageSelectReq(matchLang[1], matchLang[2], bSameLanguage or false, matchLang.lang_timeout and true or false)
end
function M.UpdateCheckBox(uiBase)
  if not uiBase or not uiBase.UIRoot then
    return
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local status = MatchSystem.nMatchStatus
  if status == ENUM_MatchStatus.Matching then
    if uiBase.UIRoot.CheckBox_SameLanguage then
      uiBase.UIRoot.CheckBox_SameLanguage:SetIsEnabled(false)
    end
    if uiBase.UIRoot.Button_MatchingTips then
      uiBase:SetWidgetVisible(uiBase.UIRoot.Button_MatchingTips, true, true)
    end
  else
    if uiBase.UIRoot.CheckBox_SameLanguage then
      uiBase.UIRoot.CheckBox_SameLanguage:SetIsEnabled(true)
    end
    if uiBase.UIRoot.Button_MatchingTips then
      uiBase:SetWidgetVisible(uiBase.UIRoot.Button_MatchingTips, false, false)
    end
  end
end
return M