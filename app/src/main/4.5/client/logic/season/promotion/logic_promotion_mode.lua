local logic_promotion_mode = {}
function logic_promotion_mode:OnInitialize()
  log(bWriteLog and "logic_promotion_mode:OnInitialize")
  self.zoneID = 0
end
function logic_promotion_mode:RegistEvents()
end
function logic_promotion_mode:IsCanSelect()
  local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
  if not logic_promotion_homepage:IsOpen() then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect not open")
    return false
  end
  if not logic_promotion_homepage:IsCanSelectPromotionMode() then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect not qualified")
    return false
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local promotion_datas = promotion_match_util.GetPromotionData()
  if promotion_datas == nil then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect promotion_datas is nil")
    return false
  end
  local seasonID = DataMgr.season_id
  local SeasonCardUtil = require("client.logic.season.logic_season_card_util")
  local seasonEndTime = SeasonCardUtil.GetSeasonEndTime(seasonID)
  if not seasonEndTime then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect no seasonEndTime")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if seasonEndTime <= curTime then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect is during season frozen")
    return false
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local curZoneID = self.zoneID or ZoneSystem.nChooseZoneID
  local found = false
  for _, v in ipairs(promotion_datas.locked_info or {}) do
    if v.unlocked_zone == curZoneID then
      found = true
      break
    end
  end
  if not found then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect not unlocked zone")
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode, viewId = logic_mode_selection:GetCurSelectInfo()
  if matchMode ~= 103 then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect not TPP4 rank mode")
    return false
  end
  log(bWriteLog and "logic_promotion_mode:IsCanSelect matchMode: " .. tostring(matchMode) .. " viewId: " .. tostring(viewId))
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewId)
  if not viewInfo then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect viewInfo is nil")
    return false
  end
  local groupKey = viewInfo.group_key or ""
  if not string.find(groupKey, "erangel") and not string.find(groupKey, "livik") then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect not erangel or livik")
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "logic_promotion_mode:IsCanSelect is in x mission")
    return false
  end
  return true
end
function logic_promotion_mode:IsOpenPromotion()
  return LobbySystem.roleData.is_open_promotion and LobbySystem.roleData.is_open_promotion == 1
end
function logic_promotion_mode:ConstructInfoTab(tabID, titleID, type, contentID)
  local infoTab = {}
  infoTab.tab = LocUtil.GetLocalizeResStr(tabID)
  infoTab.title = LocUtil.GetLocalizeResStr(titleID)
  local textInfoTab = {}
  local textInfoSubTab = {}
  textInfoSubTab.  textInfoSubTab.content1 = LocUtil.GetLocalizeStrConcatenation(contentID)
  table.insert(textInfoTab, textInfoSubTab)
  infoTab.textInfo = textInfoTab
  return infoTab
end
function logic_promotion_mode:ShowQuestionMark()
  local LogicPeakGameHomepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameHomepage)
  local allinfo = LogicPeakGameHomepage:GetPeakGameRules(6, 85344)
  if not allinfo or #allinfo <= 0 then
    log(bWriteLog and "logic_promotion_mode:ShowQuestionMark no info")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_two, allinfo)
end
function logic_promotion_mode:InitQualifyingItemByWidget(parentUI, widget)
  if not slua.isValid(widget) then
    return
  end
  if not UIManager.UI_Config.Common_Qualifying_Rounds_Item_UIBP then
    return
  end
  local UIClass = require(UIManager.UI_Config.Common_Qualifying_Rounds_Item_UIBP.moduleName)
  local promotion_ui = UIClass()
  promotion_ui:InitWithParentWidget(parentUI, widget)
  promotion_ui:OnShow()
  return promotion_ui
end
function logic_promotion_mode:proc_select_promotion_layer_rsp(err_code, is_open_promotion)
  if err_code ~= 0 then
    LobbySystem.roleData.is_open_promotion = 0
  else
    LobbySystem.roleData.  end
  EventSystem:postEvent(EVENTTYPE_PROMOTION, EVENTID_PROMOTION_SELECT_PROMOTION_RSP, LobbySystem.roleData.is_open_promotion)
end
function logic_promotion_mode:HandleErrorCode(err_code, uid)
  if err_code == 0 then
    return
  end
  local userName = ""
  if uid and uid ~= 0 then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if profile then
      userName = profile.nickName
    end
  end
  if err_code == 100610006 then
    local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
    local promotion_data = promotion_match_util.GetPromotionData()
    local index = promotion_data.cur_lock_index
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    local zoneName = logic_multiple_area:GetDisplayNameByZoneID(promotion_data.locked_info[index].unlocked_zone)
    ShowNotice(LocUtil.LocalizeResFormat(85378, zoneName))
  elseif err_code == 100610004 then
    ShowNotice(LocUtil.LocalizeResFormat(85161, userName))
  else
    ShowNotice(LocUtil.LocalizeResFormat(err_code, userName))
  end
end
function logic_promotion_mode:SetZoneInfo(zoneID)
  self.end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_promotion_mode)