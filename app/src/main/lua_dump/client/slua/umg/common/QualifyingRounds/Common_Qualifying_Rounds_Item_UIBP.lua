local Common_Qualifying_Rounds_Item_UIBP = {}
function Common_Qualifying_Rounds_Item_UIBP:ctor()
  self.checkClickTime = 0
end
function Common_Qualifying_Rounds_Item_UIBP:OnInitialize()
  self:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function Common_Qualifying_Rounds_Item_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Detail, self.OnClickButton_Detail, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Detail02, self.OnClickButton_Detail, self)
  self:AddControlEventByControl(self.UIRoot.CheckBox_1, "OnCheckStateChanged", self.OnCheckChanged, self)
  self:AddControlEventByControl(self.UIRoot.CheckBox_0, "OnCheckStateChanged", self.OnCheckChanged, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, self.SetPromotionShow, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PROMOTION_DATA_CHANGE, self.SetPromotionShow, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE, self.SetPromotionShow, self)
  self:AddCommonEvent(EVENTTYPE_PROMOTION, EVENTID_PROMOTION_SELECT_PROMOTION_RSP, self.SetPromotionOpen, self)
  self:AddCommonEvent(EVENTTYPE_PROMOTION, EVENTID_PROMOTION_BASE_CONFIG, self.OnPostInitialize, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, self.SetPromotionShow, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.SetPromotionShow, self)
  self:AddOnAnimationFinishedEvent("Anim_Refresh", self.OnAnimRefreshOver, self, 1)
end
function Common_Qualifying_Rounds_Item_UIBP:OnPostInitialize()
  self:SetPromotionShow()
  self:SetPromotionOpen()
  self:SetIsProtect()
end
function Common_Qualifying_Rounds_Item_UIBP:OnClose()
end
function Common_Qualifying_Rounds_Item_UIBP:OnClickButton_Detail()
  self:PlayAudio(sound_config.click_v1)
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  logic_promotion_mode:ShowQuestionMark()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportBtnClickEvent("PromotionBasicRule_View_Click")
end
function Common_Qualifying_Rounds_Item_UIBP:SetPromotionShow()
  if not self:IsValid() or not slua.isValid(self.UIRoot) then
    log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:SetPromotionShow not valid")
    return
  end
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  if logic_promotion_mode:IsCanSelect() then
    log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:SetPromotionShow can select")
    self:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:SetPromotionShow not can select")
    self:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Common_Qualifying_Rounds_Item_UIBP:SetPromotionOpen()
  log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:SetPromotionOpen")
  if not self:IsValid() or not slua.isValid(self.UIRoot) then
    log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:SetPromotionOpen not valid")
    return
  end
  self.UIRoot.TextBlock_Text:SetText("")
  self.UIRoot.TextBlock_Text02:SetText("")
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  local is_open_promotion = logic_promotion_mode:IsOpenPromotion()
  if is_open_promotion then
    local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
    local promotion_cfg = logic_promotion_homepage:GetCurPromotionBaseConfig()
    if not promotion_cfg then
      return
    end
    local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
    local promotion_datas = promotion_match_util.GetPromotionData()
    if not promotion_datas then
      return
    end
    local promotion_data = promotion_datas.locked_info[promotion_datas.cur_lock_index]
    if not promotion_data then
      return
    end
    self.UIRoot.TextBlock_Text:SetText(LocUtil.LocalizeResFormat(805913, promotion_data.progress, promotion_cfg.continue_win_cnt))
    self.UIRoot.TextBlock_Text02:SetText(LocUtil.LocalizeResFormat(805913, promotion_data.progress, promotion_cfg.continue_win_cnt))
  else
    self.UIRoot.TextBlock_Text:SetText(LocUtil.GetLocalizeResStr(85153))
    self.UIRoot.TextBlock_Text02:SetText(LocUtil.GetLocalizeResStr(85153))
  end
  self.UIRoot.CheckBox_1:SetIsChecked(is_open_promotion)
  self.UIRoot.CheckBox_0:SetIsChecked(is_open_promotion)
  self:ResetAnimRefresh()
  if is_open_promotion then
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Refresh, 0, 1, 0, 1)
  else
    self.UIRoot.Image_BG:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
end
function Common_Qualifying_Rounds_Item_UIBP:OnAnimRefreshOver()
  log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:OnAnimRefreshOver")
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  local is_open_promotion = logic_promotion_mode:IsOpenPromotion()
  self.UIRoot.CheckBox_1:SetIsChecked(is_open_promotion)
  self.UIRoot.CheckBox_0:SetIsChecked(is_open_promotion)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(is_open_promotion and 1 or 0)
end
function Common_Qualifying_Rounds_Item_UIBP:ResetAnimRefresh()
  log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:ResetAnimRefresh")
  self:StopAnimation("Anim_Refresh")
  self.UIRoot.TextBlock_Text:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.7)))
  self.UIRoot.Fx_Image:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
  self.UIRoot.Fx_Image_3:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
  self.UIRoot.Image_2:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  self.UIRoot.Image_Arrow:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  self.UIRoot.Image_BG:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
end
function Common_Qualifying_Rounds_Item_UIBP:OnCheckChanged(bIsChecked)
  self:PlayAudio(sound_config.click_v1)
  if not self:IsValid() or not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.CheckBox_1:SetIsChecked(not bIsChecked)
  self.UIRoot.CheckBox_0:SetIsChecked(not bIsChecked)
  log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:OnCheckChanged bIsChecked: " .. tostring(bIsChecked))
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if MatchSystem.nMatchStatus == ENUM_MatchStatus.Matching then
    ShowNotice(110017)
    return
  end
  local TimeUtil = require("client.common.time_util")
  local checkTime = TimeUtil.GetServerTimeInSec()
  if self.checkClickTime and self.checkClickTime ~= 0 and self.checkClickTime ~= nil and checkTime - self.checkClickTime < 2 then
    log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:OnCheckChanged checkTime - self.checkClickTime < 2")
    ShowNotice(LocUtil.GetLocalizeResStr(421015))
    return
  end
  self.checkClickTime = checkTime
  self:ResetAnimRefresh()
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  local is_open_promotion = logic_promotion_mode:IsOpenPromotion()
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  if is_open_promotion then
    SeasonHandler.send_select_promotion_layer_req(0)
  else
    SeasonHandler.send_select_promotion_layer_req(1)
  end
end
function Common_Qualifying_Rounds_Item_UIBP:SetIsProtect()
  log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:SetIsProtect")
  if not self:IsValid() or not slua.isValid(self.UIRoot) then
    return
  end
  local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
  local cur_protect_cnt, max_protect_cnt = logic_promotion_homepage:GetCurProtectCount()
  log(bWriteLog and "Common_Qualifying_Rounds_Item_UIBP:SetIsProtect cur_protect_cnt = " .. tostring(cur_protect_cnt) .. " max_protect_cnt = " .. tostring(max_protect_cnt))
  self:SetWidgetVisible(self.UIRoot.Image_Arrow, true)
  self:SetWidgetVisible(self.UIRoot.Image_Arrow02, true)
  if 0 < cur_protect_cnt then
    self:SetTexture(self.UIRoot.Image_Arrow, "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Challenge/Common_Icon_Challenge19_128.Common_Icon_Challenge19_128")
    self:SetTexture(self.UIRoot.Image_Arrow02, "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Challenge/Common_Icon_Challenge19_128.Common_Icon_Challenge19_128")
  else
    self:SetTexture(self.UIRoot.Image_Arrow, "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Challenge/Common_Icon_Challenge20_128.Common_Icon_Challenge20_128")
    self:SetTexture(self.UIRoot.Image_Arrow02, "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Challenge/Common_Icon_Challenge20_128.Common_Icon_Challenge20_128")
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Common_Qualifying_Rounds_Item_UIBP)