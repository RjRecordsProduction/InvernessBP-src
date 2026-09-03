local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
local logic_mic_evaluation = {
  respondent_info = {
    uid = 0,
    name = "hi",
    cur_avatar_box_id = 0,
    pic_url = "",
    mic_level = 3,
    first_match_lang = LanguageMacros.FR,
    max_segment_level = 103
  },
  questionnaire_list = nil,
  flag = false,
  from_type = 0
}
local E_StringType = {notNeedToReplaceZero = 0, needToReplaceZero = 1}
logic_mic_evaluation.local E_FromType = {Default = 0, TPlan = 1}
logic_mic_evaluation.
function logic_mic_evaluation.on_voice_feedback_rsp(res, respondent_info, questionnaire_list)
  log_tree("god test respondent_info", respondent_info)
  if res == 0 then
    logic_mic_evaluation.    local TableUtil = require("common.table_util")
    local rowCount = TableUtil.CountTable(questionnaire_list)
    if rowCount ~= 0 then
      logic_mic_evaluation.    end
  else
    log(bWriteLog and "god test on_voice_feedback_rsp not open")
  end
end
function logic_mic_evaluation.on_voice_feedback_notify(res, respondent_info, questionnaire_list, platform_type)
  if res == 0 then
    logic_mic_evaluation.flag = true
    logic_mic_evaluation.from_type = platform_type or E_FromType.Default
    logic_mic_evaluation.    local TableUtil = require("common.table_util")
    local rowCount = TableUtil.CountTable(questionnaire_list)
    if rowCount ~= 0 then
      logic_mic_evaluation.    end
  else
    log(bWriteLog and "god test on_voice_feedback_rsp not open")
  end
end
function logic_mic_evaluation.OnGameStateChange(eventType, eventID, vars)
  if GameStatus.IsInLobbyOrMainCity() and logic_mic_evaluation.flag == true and logic_mic_evaluation.from_type == E_FromType.Default then
    UIManager.ShowUI(UIManager.UI_Config.ui_mic_evaluation)
    logic_mic_evaluation.flag = false
  end
end
function logic_mic_evaluation.ShowUIInTPlan()
  if logic_mic_evaluation.flag and logic_mic_evaluation.from_type == E_FromType.TPlan then
    logic_mic_evaluation.flag = false
    logic_mic_evaluation.from_type = E_FromType.Default
    UIManager.ShowUI(UIManager.UI_Config.xmission_team_platform_evaluation)
  end
end
return logic_mic_evaluation