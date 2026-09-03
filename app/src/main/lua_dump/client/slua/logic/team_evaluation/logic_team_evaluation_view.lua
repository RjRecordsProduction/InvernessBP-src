local logic_team_evaluation_view = {
  cfg = {},
  bShowEvaluation = false,
  EScoreEntranceType = {
    hide = 0,
    active = 1,
    notActive = 2
  },
  selfEvaluationData = {}
}
function logic_team_evaluation_view.OnLogin()
  logic_team_evaluation_view.cfg = {}
  logic_team_evaluation_view.selfEvaluationData = {}
  logic_team_evaluation_view.bShowEvaluation = false
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.evaluation_table, logic_team_evaluation_view.InitEvaluationViewCfg)
end
function logic_team_evaluation_view.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    logic_team_evaluation_view.selfEvaluationData = {}
    logic_team_evaluation_view.bShowEvaluation = false
  end
end
function logic_team_evaluation_view.InitEvaluationViewCfg(_, cfg)
  logic_team_evaluation_view.  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_TEAM_EVALUATION_INIT)
end
function logic_team_evaluation_view.GetEntranceSettingType()
  local cfg = logic_team_evaluation_view.cfg
  if not cfg.Main_switch or cfg.Main_switch == 0 then
    return 0
  end
  return cfg.Socre_display_switch or 0
end
function logic_team_evaluation_view.GetEntranceView(uid)
  local EScoreEntranceType = logic_team_evaluation_view.EScoreEntranceType
  local settingType = logic_team_evaluation_view.GetEntranceSettingType()
  if settingType == 0 then
    return EScoreEntranceType.hide
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.GetEntranceView isSelf")
    local data = logic_team_evaluation_view.GetEvaluationDataByUID(uid) or {}
    local reason = data.reason or 1
    if (reason == 0 or 10 <= reason) and settingType == 2 then
      return EScoreEntranceType.active
    else
      return EScoreEntranceType.notActive
    end
  else
    log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.GetEntranceView uid = " .. tostring(uid))
    if logic_team_evaluation_view.IsPlayerEnableEvaluationView(uid) then
      return EScoreEntranceType.active
    else
      return EScoreEntranceType.hide
    end
  end
end
function logic_team_evaluation_view.GetEvaluationDataByUID(uid)
  local result = {}
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.GetEvaluationDataByUID isSelf")
    result = logic_team_evaluation_view.selfEvaluationData
  else
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
    if memberInfo and memberInfo.evaluation then
      log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.GetEvaluationDataByUID from team")
      result = memberInfo.evaluation
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local data = logic_profile:GetLocalProfile(uid)
      if result and next(result) and data and data.evaluation then
        data.evaluation = result
      end
    end
    if not result or not next(result) then
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local data = logic_profile:GetLocalProfile(uid) or {}
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        if data.evaluation and data.evaluation.privacy == 3 and LogicFriend.IsMyFriend(uid) then
          result = data.evaluation
        elseif data.evaluation and data.evaluation.privacy == 2 then
          result = data.evaluation
        end
      else
        result = data.evaluation
      end
      log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.GetEvaluationDataByUID from profile")
    end
  end
  log_tree("[DeanJYT] logic_team_evaluation_view.GetEvaluationDataByUID, uid = " .. tostring(uid), result)
  return result
end
function logic_team_evaluation_view.IsPlayerEnableEvaluationView(uid)
  local data = logic_team_evaluation_view.GetEvaluationDataByUID(uid)
  if not data then
    return false
  end
  if data.reason == 0 then
    return true
  else
    return false
  end
end
function logic_team_evaluation_view.GetPlayerEvaluationScore(uid)
  local data = logic_team_evaluation_view.GetEvaluationDataByUID(uid)
  return data and data.score
end
function logic_team_evaluation_view.GetLabelByID(labelID)
  local TableUtil = require("common.table_util")
  local labelCfg = TableUtil.GetTableValue(logic_team_evaluation_view.cfg, "teammate_evaluation_label_config", tonumber(labelID))
  return labelCfg
end
function logic_team_evaluation_view.RefreshEvaluationEntrance(uid, root)
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) and not next(logic_team_evaluation_view.selfEvaluationData) then
    logic_team_evaluation_view.send_get_evaluation_req(tonumber(DataMgr.roleData.uid))
  end
  local EScoreEntranceType = logic_team_evaluation_view.EScoreEntranceType
  local viewType = logic_team_evaluation_view.GetEntranceView(uid)
  if not root then
    return
  end
  log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.RefreshEvaluationEntrance, viewType = " .. tostring(viewType))
  if viewType == EScoreEntranceType.hide then
    local UIUtil = require("client.common.ui_util")
    UIUtil.SetWidgetVisible(root.CanvasPanel_Score, false)
  else
    local UIUtil = require("client.common.ui_util")
    UIUtil.SetWidgetVisible(root.CanvasPanel_Score, true)
    local score = tonumber(logic_team_evaluation_view.GetPlayerEvaluationScore(uid))
    if viewType == EScoreEntranceType.active then
      if not score then
        return
      end
      root.WidgetSwitcher_Score:SetActiveWidgetIndex(0)
      local scoreStr = string.format("%.1f", score)
      root.TextBlock_Score:SetText(scoreStr)
      local scoreFloored = math.floor(score + 0.55)
      if scoreFloored == 0 then
        scoreFloored = 1
      end
      local descCfg = CDataTable.GetTableData("EvaluationDescCfg", scoreFloored)
      if descCfg then
        local util = require("client.slua_ui_framework.util")
        util.SetTexture(root.Image_ScoreLevel, descCfg.SmallScoreIconPath)
      end
    else
      root.WidgetSwitcher_Score:SetActiveWidgetIndex(1)
    end
  end
end
function logic_team_evaluation_view.ShowDetailedEvaluationView(uid)
  local settingType = logic_team_evaluation_view.GetEntranceSettingType()
  if settingType ~= 2 then
    return
  end
  local bIsViewEnabled = logic_team_evaluation_view.IsPlayerEnableEvaluationView(uid)
  local bIsSelf = tonumber(uid) == tonumber(DataMgr.roleData.uid)
  if not bIsViewEnabled and not bIsSelf then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Team_Evaluation_UIBP, uid)
end
function logic_team_evaluation_view.ShowNotEnoughEvaluationTips()
  if logic_team_evaluation_view.GetEntranceSettingType() == 1 then
    ShowNotice(23304)
    return
  end
  local minEvaluations = logic_team_evaluation_view.cfg.MinDisplayRecordRounds
  ShowNotice(LocUtil.LocalizeResFormat(23301, minEvaluations))
end
function logic_team_evaluation_view.send_get_evaluation_req(player_uid)
  log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.send_get_evaluation_req player_uid = " .. tostring(player_uid))
  local ProfileHander = require("client.network.Protocol.ProfileHander")
  ProfileHander.send_get_evaluation_req(tonumber(player_uid))
end
function logic_team_evaluation_view.on_get_evaluation_rsp(error_code, player_uid, evaluation)
  log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.on_get_evaluation_rsp, player_uid = " .. tostring(player_uid) .. ", error_code = " .. tostring(error_code))
  log_tree("[DeanJYT] logic_team_evaluation_view.on_get_evaluation_rsp evaluation = ", evaluation)
  if error_code ~= 0 then
    return
  end
  if not evaluation then
    log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.on_get_evaluation_rsp evaluation is nil")
    return
  end
  if tonumber(player_uid) == tonumber(DataMgr.roleData.uid) then
    logic_team_evaluation_view.selfEvaluationData = evaluation or {}
    if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
      logic_team_evaluation_view.bShowEvaluation = evaluation.privacy
    elseif evaluation.privacy == 2 then
      logic_team_evaluation_view.bShowEvaluation = true
    else
      logic_team_evaluation_view.bShowEvaluation = false
    end
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_TEAM_EVALUATION_INIT)
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local data = logic_profile:GetLocalProfile(player_uid)
    if data then
      data.    end
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_TEAM_EVALUATION_DETAIL, player_uid, evaluation)
end
function logic_team_evaluation_view.send_set_evaluation_privacy(privacy_type)
  log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.send_set_evaluation_privacy privacy_type = " .. tostring(privacy_type))
  local ProfileHander = require("client.network.Protocol.ProfileHander")
  ProfileHander.send_set_evaluation_privacy(privacy_type)
end
function logic_team_evaluation_view.on_evaluation_privacy_rsp(error_code, privacy_type)
  if error_code ~= 0 then
    return
  end
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    logic_team_evaluation_view.bShowEvaluation = privacy_type
  elseif privacy_type == 2 then
    logic_team_evaluation_view.bShowEvaluation = true
  else
    logic_team_evaluation_view.bShowEvaluation = false
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_TEAM_EVALUATION_PRIVACY)
end
function logic_team_evaluation_view.send_finish_evaluation_guide_req()
  local ProfileHander = require("client.network.Protocol.ProfileHander")
  ProfileHander.send_finish_evaluation_guide_req()
end
function logic_team_evaluation_view.on_finish_evaluation_guide_rsp()
  logic_team_evaluation_view.selfEvaluationData.reason = 0
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_TEAM_EVALUATION_INIT)
  log(bWriteLog and "[DeanJYT] logic_team_evaluation_view.on_finish_evaluation_guide_rsp")
end
return logic_team_evaluation_view