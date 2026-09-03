local logic_return_activity_guide = {}
local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
local string_util = require("common.string_util")
function logic_return_activity_guide:DefineAndResetData()
  local config = CDataTable.GetTable("ReturnGuideCfg")
  self.guideUIs = {}
  for i, v in ipairs(config) do
    self.guideUIs[v.Type] = {}
    local result = string_util.Split(v.UIConfig, "|")
    for i, path in ipairs(result) do
      table.insert(self.guideUIs[v.Type], {
        guideType = v.Type,
        uiConfig = UIManager.UI_Config[path]
      })
    end
  end
end
function logic_return_activity_guide:_GMOpenGuideUI(guideType)
  local guideUIs = self:GetGuideUIs()
  UIManager.ShowUI(guideUIs[guideType].uiConfig)
end
function logic_return_activity_guide:OnInitialize()
end
function logic_return_activity_guide:RegistEvents()
end
function logic_return_activity_guide:OnLogin(bReLogin)
end
function logic_return_activity_guide:OnLogOut()
end
function logic_return_activity_guide:OnPreSwitchGameStatus(preState, nextState)
end
function logic_return_activity_guide:OnPostSwitchGameStatus(preState, nextState)
end
function logic_return_activity_guide:GetADjustLinkReturnType(SDKAdjustAttr)
  local wildcard_to_pattern = function(rule)
    rule = rule:gsub("([%%%.%+%-%^%$%(%)%[%]%?])", "%%%1")
    rule = rule:gsub("%*", ".*")
    return "^" .. rule .. "$"
  end
  local match_tag = function(str, rules)
    for _, rule in ipairs(rules) do
      local pattern = wildcard_to_pattern(rule.RegexRule)
      if string.match(str, pattern) then
        return true, rule
      end
    end
    return false, nil
  end
  if not SDKAdjustAttr then
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    SDKAdjustAttr = IMSDKHelperInstance.GetAdjustAttr and IMSDKHelperInstance:GetAdjustAttr()
    if not SDKAdjustAttr then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAdjustrReattribution)
      SDKAdjustAttr = saveData and saveData.jsonStr
    end
    if not SDKAdjustAttr then
      return
    end
  end
  log(bWriteLog and string.format("logic_return_activity_guide:GetADjustLinkReturnType, SDKAdjustAttr:%s", SDKAdjustAttr))
  local attrTable = json.decode(SDKAdjustAttr) or {}
  log_tree(bWriteLog and "logic_return_activity_guide:GetADjustLinkReturnType attrTable", attrTable)
  if attrTable and attrTable.adgroup and attrTable.adgroup ~= "" then
    local rules = CDataTable.GetTable("ReturnADLabelCfg")
    if rules then
      local ok, rule = match_tag(attrTable.adgroup, rules)
      if ok then
        return rule.ID
      end
    end
  end
end
function logic_return_activity_guide:GetGuideUIs()
  local guideUIs = {}
  for guideType, v in ipairs(self.guideUIs) do
    if guideType ~= return_activity_macro.Enum_Guide_Type.Unknow then
      if guideType == return_activity_macro.Enum_Guide_Type.Social then
        local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
        local friendList = logic_player_return.GetNotifyFriendList()
        local ui1 = {
          guideType = guideType,
          uiConfig = UIManager.UI_Config.ReturnActivity_Socialize_UIBP
        }
        local ui2 = {
          guideType = guideType,
          uiConfig = UIManager.UI_Config.ReturnActivity_Friends_Recommend
        }
        table.insert(guideUIs, friendList and 1 < #friendList and ui1 or ui2)
      elseif guideType == return_activity_macro.Enum_Guide_Type.Content then
        if self:CanShowContentType() then
          table.insert(guideUIs, v[1])
        end
      elseif guideType == return_activity_macro.Enum_Guide_Type.TryNeW then
        if self:CanShowTastingType() then
          table.insert(guideUIs, v[1])
        end
      else
        table.insert(guideUIs, v[1])
      end
    end
  end
  return guideUIs
end
function logic_return_activity_guide:GetGuideType()
  if not DataMgr.roleData.back_user_data then
    return nil
  end
  local guideType = DataMgr.roleData.back_user_data.guide_profile_id
  if not guideType then
    return nil
  end
  if guideType == return_activity_macro.Enum_Guide_Type.Unknow or guideType == 0 then
    return return_activity_macro.Enum_Guide_Type.TryNeW
  end
  return guideType
end
function logic_return_activity_guide:GetGuideConifg()
  if not DataMgr.roleData.back_user_data then
    return {}
  end
  local guideType = self:GetGuideType()
  if not guideType then
    return {}
  end
  local guideCfg = CDataTable.GetTableData("ReturnGuideCfg", guideType)
  if guideCfg then
    self.guideCfg = {
      main_page = guideCfg.main_page,
      pop_frd_recommand = guideCfg.pop_frd_recommand,
      pop_back_award = guideCfg.pop_back_award,
      pop_sign_award = guideCfg.pop_sign_award
    }
  end
  return self.guideCfg
end
function logic_return_activity_guide:IsHitNewGuide()
  if not DataMgr.roleData.back_user_data then
    return false
  end
  return self:GetGuideType() ~= nil
end
function logic_return_activity_guide:HasValidGuideUI()
  local guideType = self:GetGuideType()
  if not guideType then
    return false
  end
  local guideUIs = self.guideUIs and self.guideUIs[guideType]
  if not guideUIs then
    return false
  end
  return guideUIs[1] ~= nil and guideUIs[1].uiConfig ~= nil
end
function logic_return_activity_guide:ShowNewGuide()
  if not DataMgr.roleData.back_user_data then
    return
  end
  if DataMgr.roleData.back_user_data.version_update_guide_cfg then
    UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_Version_Update_UIBP)
    return
  end
  local guideType = self:GetGuideType()
  if not guideType then
    return
  end
  local guideUIs = self.guideUIs[guideType]
  if not guideUIs then
    log_error(bWriteLog and string.format("logic_return_activity_guide:ShowNewGuide, not guideUIs guideType:%s", guideType))
    return
  end
  if guideType == return_activity_macro.Enum_Guide_Type.Social then
    local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
    local friendList = logic_player_return.GetNotifyFriendList()
    if friendList and 1 < #friendList then
      UIManager.ShowUI(guideUIs[1].uiConfig)
    else
      UIManager.ShowUI(guideUIs[2].uiConfig)
    end
  elseif guideType == return_activity_macro.Enum_Guide_Type.Content then
    UIManager.ShowUI(guideUIs[1].uiConfig)
  elseif guideType == return_activity_macro.Enum_Guide_Type.TryNeW then
    self:ShowFBGuideUI()
  else
    UIManager.ShowUI(guideUIs[1].uiConfig)
  end
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.ReturnAct_NEW_GUIDE_UI_SHOW, guideType)
end
function logic_return_activity_guide:GetContentByTabType(tabType)
  local contents = {}
  if tabType == return_activity_macro.Enum_Newest_Tab_Type.Theme then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
    if not logic_player_return.new_post_info then
      log(bWriteLog and "[v_zhanggao] OnReturnNewPostChange logic_player_return.new_post_info is nil")
    else
      for _, v in pairs(logic_player_return.new_post_info) do
        if v.page_id == return_activity_macro.Enum_Newest_Tab_Type.Theme and (v.notify_order > 0 or serverTime >= v.start_time and (serverTime <= v.end_time or v.end_time == 0)) then
          table.insert(contents, v)
        end
      end
    end
  elseif tabType == return_activity_macro.Enum_Newest_Tab_Type.Commercialization then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
    if not logic_player_return.new_post_info then
      log(bWriteLog and "[v_zhanggao] OnReturnNewPostChange logic_player_return.new_post_info is nil")
    else
      for _, v in pairs(logic_player_return.new_post_info) do
        if v.page_id == return_activity_macro.Enum_Newest_Tab_Type.Commercialization and (v.notify_order > 0 or serverTime >= v.start_time and (serverTime <= v.end_time or v.end_time == 0)) then
          table.insert(contents, v)
        end
      end
    end
  end
  return contents
end
function logic_return_activity_guide:CanShowContentType()
  local themeData = self:GetContentByTabType(return_activity_macro.Enum_Newest_Tab_Type.Theme)
  local commercializationData = self:GetContentByTabType(return_activity_macro.Enum_Newest_Tab_Type.Commercialization)
  if not next(themeData) and not next(commercializationData) then
    log(bWriteLog and "logic_return_activity_guide:CanShowContentType return of not data")
    return false
  end
  return true
end
function logic_return_activity_guide:CanShowTastingType()
  local loigic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  local data = loigic_return_activity:GetAbtestConfig()
  if not data then
    log(bWriteLog and "logic_return_activity_guide:CanShowTastingType data is nil")
    return false
  end
  local cfgMapList = {}
  local StringUtil = require("common.string_util")
  local guideModeList = StringUtil.Split(data.guide_mode, "|")
  local imgUrlList = StringUtil.Split(data.pic_url, "|")
  local mapDescList = StringUtil.Split(data.mode_desc, "|")
  local mapNameList = StringUtil.Split(data.mode_name, "|")
  for i = 1, #guideModeList do
    cfgMapList[i] = {}
    cfgMapList[i].guide_mode = guideModeList[i]
    cfgMapList[i].mode_desc = mapDescList[i]
    cfgMapList[i].mode_name = mapNameList[i]
    cfgMapList[i].pic_url = imgUrlList[i]
  end
  table.sort(cfgMapList, function(a, b)
    if a.guide_mode == data.default_mode and b.guide_mode ~= data.default_mode then
      return true
    end
    return false
  end)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local mapInfoList = {}
  for _, v in ipairs(cfgMapList) do
    local name = logic_mode_utils.GetMapNameByViewID(tonumber(v.guide_mode))
    if name ~= "" then
      table.insert(mapInfoList, v)
    end
  end
  if not next(mapInfoList) then
    return false
  end
  return true
end
function logic_return_activity_guide:ReqSocialData()
  log(bWriteLog and "logic_return_activity_guide:ReqSocialData")
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local friendList = logic_player_return.GetNotifyFriendList() or {}
  local TableUtil = require("common.table_util")
  friendList = TableUtil.TableSlice(friendList, 1, 3)
  if friendList and 1 < #friendList then
    self:AddTimer(0, function()
      for _, friend in ipairs(friendList) do
        local logic_lobby_social = require("client.slua.logic.lobby.Left.logic_lobby_social")
        if not logic_lobby_social.GetCombatInfo(friend.uid) then
          logic_lobby_social.get_role_combat_info_req(friend.uid)
        end
        local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
        logic_friend_interact_record:RequestCumulativeInteractDataForPlayer(friend.uid)
        coroutine.yield(0.5)
      end
    end)
  end
end
function logic_return_activity_guide:GetResultOneMoreGameTips(battle_result)
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and "logic_return_activity_guide:GetResultOneMoreGameTips return of not IsActInProgress")
    return ""
  end
  local modeId = battle_result.battle_type
  local history_combat_util = require("client.logic.combat.history.history_combat_util")
  if not history_combat_util.IsClassicRankMode(modeId) then
    log(bWriteLog and "logic_return_activity_guide:GetResultOneMoreGameTips return of not IsClassicRankMode")
    return ""
  end
  local RatingRewardConfig = {
    [1] = {
      team = {17},
      solo = {7}
    },
    [2] = {
      team = {
        21,
        22,
        23,
        26,
        27,
        28
      },
      solo = {14, 15}
    },
    [3] = {
      team = {16},
      solo = {1, 2}
    }
  }
  local typeToLocId = {
    [1] = 86330,
    [2] = 86331,
    [3] = 86332
  }
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isInTeam = 1 < TeamUpNewSystem.GetTeamNum()
  local matchProtectId = function(data, config, isTeam)
    if not data.protect_id then
      return false
    end
    local targetList = isTeam and config.team or config.solo
    for _, id in ipairs(targetList) do
      if data.protect_id == id then
        return true
      end
    end
    return false
  end
  local CheckDataList = function(dataList)
    for _, data in ipairs(dataList or {}) do
      for typeId, config in ipairs(RatingRewardConfig) do
        if matchProtectId(data, config, isInTeam) then
          log(bWriteLog and string.format("logic_return_activity_guide:GetResultOneMoreGameTips, protect_id:%s", data.protect_id))
          return LocUtil.GetLocalizeResStr(typeToLocId[typeId])
        end
      end
    end
    return ""
  end
  local FindAddScoreText = function()
    local logic_rating_card_buff_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rating_card_buff_mgr)
    local addScoreList = logic_rating_card_buff_mgr:GetAddScoreList()
    log_tree(bWriteLog and "logic_return_activity_guide:GetResultOneMoreGameTips addScoreList", addScoreList)
    local result = CheckDataList(addScoreList)
    if result ~= "" then
      return result
    end
    local logic_buffer_panel_for_act = require("client.slua.logic.activity.rating_protect_activity.logic_buffer_panel_for_act")
    local actList = logic_buffer_panel_for_act.GetActListForSegmentBuffer() or {}
    log_tree(bWriteLog and "logic_return_activity_guide:GetResultOneMoreGameTips actList", actList)
    for _, actData in pairs(actList) do
      result = CheckDataList(actData)
      if result ~= "" then
        return result
      end
    end
    return ""
  end
  local addScoreText = FindAddScoreText()
  if addScoreText ~= "" then
    return addScoreText
  end
  local logic_rating_card_buff_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rating_card_buff_mgr)
  local segProtectList = logic_rating_card_buff_mgr:GetSegmentProtectList()
  log_tree(bWriteLog and "logic_return_activity_guide:GetResultOneMoreGameTips segProtectList", segProtectList)
  if not segProtectList or not next(segProtectList) then
    return ""
  end
  return CheckDataList(segProtectList) or ""
end
function logic_return_activity_guide:ShowFBGuideUI()
  if not DataMgr.roleData.back_user_data then
    return
  end
  local returnClientVersion = DataMgr.roleData.back_user_data.back_cli_ver or "3.9.0"
  local version_util = require("client.common.version_util")
  local ClientVersion = "4.0.0"
  if version_util.CompareVersionStandard(returnClientVersion, ClientVersion) >= 0 then
    UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_TastingType_UIBP)
  else
    UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_FristBattle_Popup_UIBP)
  end
end
function logic_return_activity_guide:IsHitABTest()
  local id = DataMgr.roleData.back_user_data.guide_profile_id or 0
  if id == 0 then
    return false
  end
  return true
end
function logic_return_activity_guide:on_back_user_guide_profile_notify(profile_id, backuser_guide_type_table)
  if not DataMgr.roleData.back_user_data then
    return
  end
  if profile_id == return_activity_macro.Enum_Guide_Type.Unknown then
    profile_id = return_activity_macro.Enum_Guide_Type.TryNeW
  end
  DataMgr.roleData.back_user_data.guide_  self.guideCfg = backuser_guide_type_table
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_return_activity_guide = class(CModuleBase, nil, logic_return_activity_guide)
return Clogic_return_activity_guide