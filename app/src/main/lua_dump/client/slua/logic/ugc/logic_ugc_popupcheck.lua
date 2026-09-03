local logic_ugc_popupcheck = {}
function logic_ugc_popupcheck:ctor()
end
function logic_ugc_popupcheck:OnInitialize()
end
function logic_ugc_popupcheck:RegistEvents()
end
function logic_ugc_popupcheck:OnLogin()
end
function logic_ugc_popupcheck:OnLogOut()
end
function logic_ugc_popupcheck.CheckShowEveryDayTips()
  local data
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local CanShowUGCEverydayDataTips = function()
    local TimeUtil = require("client.common.time_util")
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCModDataNoticeTime) or {}
    local canShow = false
    local key = TimeUtil.FormatTime_YMD(TimeUtil.GetServerTimeInSec(), true, false)
    if not cfg[key] then
      canShow = true
    end
    log(bWriteLog and "Logic_UGC:CheckShowEveryDayTips: " .. tostring(key) .. " CanShow : " .. tostring(canShow))
    return canShow
  end
  if not CanShowUGCEverydayDataTips() then
    return false
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local modList = Logic_UGC:GetCacheByType(UGCMacros.ENUM_MODE_TYPE.Pub)
  if not modList or not next(modList) then
    return false
  end
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  local author_summary = LogicUGCAuthor.MyAuthorSummaryData
  if not author_summary then
    return false
  end
  local collect = author_summary.total_collect_cnt or 0
  local lastCollect = author_summary.total_collect_cnt_last or 0
  local played = author_summary.total_play_cnt or 0
  local lastPlayed = author_summary.total_play_cnt_last or 0
  local detailCollect = collect - lastCollect
  local detailPlayed = played - lastPlayed
  if detailPlayed <= 0 then
    return false
  end
  local content = ""
  if detailCollect <= 0 then
    content = LocUtil.LocalizeResFormat(70109, tostring(detailPlayed))
  else
    content = LocUtil.LocalizeResFormat(70108, tostring(detailCollect), tostring(detailPlayed))
  end
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  data = {
    ui_cfg = config_ugc.MineWorksPanelTips_Sort.UGC_MineEverydayDataTips,
    config = {
      content = content,
      UIKey = "UGC_MineEverydayDataTips"
    }
  }
  return true, data
end
function logic_ugc_popupcheck.CheckShowColdBootTips()
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if Logic_UGC.caring_last_publish_mod then
    local config_ugc = require("client.slua.logic.ugc.config_ugc")
    local data = {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort.UGC_ColdBoot_Popup_UIBP,
      config = Logic_UGC.caring_last_publish_mod
    }
    return true, data
  end
  return false
end
function logic_ugc_popupcheck.CheckShowLevelupTips()
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if Logic_UGC.author_level_up_data and "UGC_Author_Levelup_Popup_UIBP" == Logic_UGC.author_level_up_data.Blueprint then
    local config_ugc = require("client.slua.logic.ugc.config_ugc")
    local data = {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort[Logic_UGC.author_level_up_data.Blueprint],
      config = Logic_UGC.author_level_up_data
    }
    return true, data
  end
  return false
end
function logic_ugc_popupcheck.CheckShowLevelupTips2()
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if Logic_UGC.author_level_up_data and "UGC_Author_Levelup_Popup_UIBP2" == Logic_UGC.author_level_up_data.Blueprint then
    local config_ugc = require("client.slua.logic.ugc.config_ugc")
    local data = {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort[Logic_UGC.author_level_up_data.Blueprint],
      config = Logic_UGC.author_level_up_data
    }
    return true, data
  end
  return false
end
function logic_ugc_popupcheck.CheckShowProgressTips()
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if Logic_UGC.author_progress then
    local config_ugc = require("client.slua.logic.ugc.config_ugc")
    local data = {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort.UGCAuthorProgressPopUI,
      config = Logic_UGC.author_progress
    }
    return true, data
  end
  return false
end
function logic_ugc_popupcheck.CheckShowIncentiveAuthorRewardTips()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWowIncentiveAuthorInspireStage) or {}
  if logic_ugc_popupcheck.CheckIsSameMonth(Record.SlapShowTime) then
    return false
  end
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  local Config_UGC_Commercialization = require("client.slua.umg.ugc.Commercialization.config_ugc_commercialization")
  local ActiveMotivationState = logic_ugc_active_motivation:GetActiveMotivationState()
  if ActiveMotivationState == Config_UGC_Commercialization.C_UGCIncentiveProgramState.JoinSucceed then
    local authorData = logic_ugc_active_motivation:GetIncentiveAuthorInspire()
    if authorData and next(authorData) and authorData.task4 ~= 1 then
      local data = {}
      return true, data
    end
  end
  return false
end
function logic_ugc_popupcheck.CheckShowAutoTranslate()
  local ConfigUGC = require("client.slua.logic.ugc.config_ugc")
  local NewUGCMainPanel = UIManager.GetUI(UIManager.UI_Config.NewUGCMainPanel)
  if NewUGCMainPanel == nil then
    log(bWriteLog and "logic_ugc_popupcheck:CheckShowAutoTranslate NewUGCMainPanel == nil")
    return false
  end
  local tagID = NewUGCMainPanel.nTab
  if tagID == ConfigUGC.Config_UGC_TabID.PHome then
    log(bWriteLog and "logic_ugc_popupcheck:CheckShowAutoTranslate tagID == ConfigUGC.Config_UGC_TabID.PHome")
    return false
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local transState = LogicUGC:GetClientOutsideAutoTransEnabled()
  log(bWriteLog and "logic_ugc_popupcheck:CheckShowAutoTranslate transState = " .. tostring(transState))
  if LogicUGC:CheckFirstEnterWOWAutoTransTips() and LogicUGC:CheckShowOutsideAutoTranslateCheckWindow() then
    return true
  end
  return false
end
function logic_ugc_popupcheck.CheckShowAutoTranslateWOWUI()
  if logic_ugc_popupcheck.CheckShowAutoTranslate() then
    local ConfigUGC = require("client.slua.logic.ugc.config_ugc")
    local data = {
      ui_cfg = ConfigUGC.Enum_WOW_PopupPriority.UGC_AutoTranslate_Popup_UIBP,
      config = {
        UIKey = "UGC_AutoTranslate_Popup_UIBP"
      }
    }
    return true, data
  end
  return false
end
function logic_ugc_popupcheck.CheckShowAutoTranslateWOWQuickEnterUI()
  if logic_ugc_popupcheck.CheckShowAutoTranslate() then
    local ConfigUGC = require("client.slua.logic.ugc.config_ugc")
    local data = {
      ui_cfg = ConfigUGC.Enum_WOW_QuickEntry_PopupPriority.UGC_AutoTranslate_Popup_UIBP,
      config = {
        UIKey = "UGC_AutoTranslate_Popup_UIBP"
      }
    }
    return true, data
  end
  return false
end
function logic_ugc_popupcheck.CheckShowFaceSlapWOWUI()
  local show_result = logic_ugc_popupcheck.GetWoWFaceSlapData()
  local TableUtil = require("common.table_util")
  if show_result and TableUtil.CountTable(show_result) > 0 then
    local config_ugc = require("client.slua.logic.ugc.config_ugc")
    local data = {
      ui_cfg = config_ugc.Enum_WOW_PopupPriority.UGC_FaceSlap_Popup_UIBP,
      config = show_result
    }
    return true, data
  end
  return false
end
function logic_ugc_popupcheck.CheckShowFaceSlapWOWQuickEnteyUI()
  local show_result = logic_ugc_popupcheck.GetWoWFaceSlapData()
  local TableUtil = require("common.table_util")
  if show_result and TableUtil.CountTable(show_result) > 0 then
    local config_ugc = require("client.slua.logic.ugc.config_ugc")
    local data = {
      ui_cfg = config_ugc.Enum_WOW_QuickEntry_PopupPriority.UGC_FaceSlap_Popup_UIBP,
      config = show_result
    }
    return true, data
  end
  return false
end
function logic_ugc_popupcheck.GetWoWFaceSlapData()
  local show_result = {}
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local FaceSlaps = Logic_UGC:GetUGCFaceSlapData()
  if not FaceSlaps or not next(FaceSlaps) then
    log(bWriteLog and "logic_ugc_popupcheck:GetWoWFaceSlapData FaceSlaps is nil")
    return nil
  end
  if not Logic_UGC:IsCanShow() then
    log(bWriteLog and "logic_ugc_popupcheck:GetWoWFaceSlapData return of IsCanShow = false ")
    return nil
  end
  for i, v in pairs(FaceSlaps) do
    local loc_exposure_cnt = Logic_UGC:GetFaceSlapValidExposureCnt(v)
    log(bWriteLog and " logic_ugc_popupcheck.GetWoWFaceSlapData acti id = " .. v.ID .. " loc_exposure_cnt = " .. loc_exposure_cnt)
    if loc_exposure_cnt < v.Condition2 then
      if v.Level_Up_Limit ~= 0 then
        if v.Level_Down_Limit <= DataMgr.ugc_author_info.new_level and v.Level_Up_Limit >= DataMgr.ugc_author_info.new_level then
          table.insert(show_result, v)
        else
          log(bWriteLog and "logic_ugc_popupcheck:GetWoWFaceSlapData return of ID =  " .. v.ID .. " Level_Down_Limit = " .. v.Level_Down_Limit .. " Level_Up_Limit = " .. v.Level_Up_Limit)
        end
      else
        table.insert(show_result, v)
        log(bWriteLog and "logic_ugc_popupcheck:GetWoWFaceSlapData insert ID =  " .. v.ID .. " not has Level_Down_Limit or Level_Up_Limit")
      end
    else
      log(bWriteLog and "logic_ugc_popupcheck:GetWoWFaceSlapData return of ID =  " .. v.ID .. " Condition2 = " .. v.Condition2)
    end
  end
  return show_result
end
function logic_ugc_popupcheck.CheckShowWOWPassPopup()
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  log(bWriteLog and "logic_ugc_popupcheck.CheckShowWOWPassPopup logic_ugc_WOWPass.show_flag = " .. tostring(logic_ugc_WOWPass.show_flag))
  local logic_home_pass = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_pass)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if LogicUGC:GetUGCPopupCheckGM("WOWPassBlue") or logic_ugc_WOWPass.show_flag and not logic_home_pass:IsJoinBuyOpen() then
    return true
  end
  return false
end
function logic_ugc_popupcheck.CheckShowWOWPassTogetherPopup()
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  log(bWriteLog and "logic_ugc_popupcheck.CheckShowWOWPassTogetherPopup logic_ugc_WOWPass.show_flag = " .. tostring(logic_ugc_WOWPass.show_flag))
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local logic_home_pass = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_pass)
  if LogicUGC:GetUGCPopupCheckGM("WOWPassYellow") or logic_home_pass:IsJoinBuyOpen() and logic_ugc_WOWPass.show_flag then
    return true
  end
  return false
end
function logic_ugc_popupcheck.CheckUGCMineMainUIStrongNewGuide()
  log(bWriteLog and "logic_ugc_popupcheck.CheckUGCMineMainUIStrongNewGuide")
  local bstrong_guide = false
  return bstrong_guide
end
function logic_ugc_popupcheck.CheckUGCModeSelectMainUIStrongNewGuide()
  log(bWriteLog and "logic_ugc_popupcheck.CheckUGCModeSelectMainUIStrongNewGuide")
  local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
  local bstrong_guide = logic_ugc_newbie_guide:IsOngoingStrongGuide()
  print(bWriteLog and "logic_ugc_popupcheck.CheckUGCModeSelectMainUIStrongNewGuide = " .. tostring(bstrong_guide))
  return bstrong_guide
end
function logic_ugc_popupcheck.CheckUGCModeSelectWOWUIStrongNewGuide()
  log(bWriteLog and "logic_ugc_popupcheck.CheckUGCModeSelectWOWUIStrongNewGuide")
  local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
  local bstrong_guide = logic_ugc_newbie_guide:IsOngoingStrongGuide()
  print(bWriteLog and "logic_ugc_popupcheck.CheckUGCModeSelectWOWUIStrongNewGuide = " .. tostring(bstrong_guide))
  return bstrong_guide
end
function logic_ugc_popupcheck.CheckIsSameMonth(time)
  if not time or type(time) == "table" then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local saveTime = os.date("*t", time)
  local nowTime = os.date("*t", TimeUtil.GetServerTimeInSec())
  return saveTime.year == nowTime.year and saveTime.month == nowTime.month
end
function logic_ugc_popupcheck.CheckShowCrystalPopup()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if LogicUGC:GetUGCPopupCheckGM("Crystal") then
    return true
  end
  if not LobbySystem.CheckOpen(92073) then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCCrystalIncentivePopup) or {}
  if Record.show_time then
    local TimeUtil = require("client.common.time_util")
    local cur_time = TimeUtil.GetServerTimeInSec()
    if TimeUtil.IsSameWeek(cur_time, Record.show_time) then
      log(bWriteLog and "logic_ugc_popupcheck.CheckShowCrystalPopup return false of IsSameDay")
      return false
    end
  end
  local Logic_UGC_CrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
  if not Logic_UGC_CrystalIncentive:CheckShowJoinGuide() then
    log(bWriteLog and "logic_ugc_popupcheck.CheckShowCrystalPopup return false of CheckShowJoinGuide")
    return false
  end
  return true
end
function logic_ugc_popupcheck.CheckShowIntentionUI()
  local logic_ugc_intention = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_intention)
  local Is_new = logic_ugc_intention:GetIsNew()
  local Is_back = logic_ugc_intention:GetIsBack()
  local bRecommendModsRsp = logic_ugc_intention:GetBRecommendModsRsp()
  log(bWriteLog and "logic_ugc_popupcheck.CheckShowIntentionUI bRecommendModsRsp = " .. tostring(bRecommendModsRsp) .. " Is_new = " .. tostring(Is_new) .. " Is_back = " .. tostring(Is_back))
  if bRecommendModsRsp and (Is_new or Is_back) then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INTENTION_MOD_RSP)
    return true
  end
  return false
end
function logic_ugc_popupcheck.CheckShowThemePlayActivityTemplateFaceSlap()
  log(bWriteLog and "logic_ugc_popupcheck.CheckShowThemePlayActivityTemplateFaceSlap")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local shownRecord = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCThemePlayActivityTemplateFaceSlapShown) or {}
  shownRecord.shownParams = shownRecord.shownParams or {}
  shownRecord.lastShownTimestamp = shownRecord.lastShownTimestamp or 0
  local paramKey = "wow_lobby"
  local Logic_UGC_ThemePlay_ActivityTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_theme_play_activity_template)
  local firstValidActID = Logic_UGC_ThemePlay_ActivityTemplate:GetFirstValidActivityID()
  local bHasValidActivity = firstValidActID ~= nil
  if not bHasValidActivity then
    log(bWriteLog and "logic_ugc_popupcheck.CheckShowThemePlayActivityTemplateFaceSlap  not bHasValidActivity ")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local shownTimestamp = shownRecord.lastShownTimestamp
  local isWithInOneDay = shownTimestamp and TimeUtil.IsToday(shownTimestamp) or false
  if isWithInOneDay then
    log(bWriteLog and string.format("logic_ugc_popupcheck.CheckShowThemePlayActivityTemplateFaceSlap time out"))
    return false
  end
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  local data = {
    ui_cfg = config_ugc.Enum_WOW_QuickEntry_PopupPriority.UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP,
    config = {}
  }
  return true, data
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_popupcheck = class(CModuleBase, nil, logic_ugc_popupcheck)
return Clogic_ugc_popupcheck