local QuickQuestionSystem = {
  _notify_question_list = nil,
  _notify_qustion_title = "",
  _answersData = nil,
  _act_question_list = nil,
  _act_tab_data = {},
  btnIndex = 1
}
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function QuickQuestionSystem.GetQuestionList()
  if not QuickQuestionSystem._notify_question_list then
    return
  end
  local total_question = {}
  for k, v in pairs(QuickQuestionSystem._notify_question_list) do
    for kk, vv in pairs(v) do
      if vv then
        local info = {}
        info = vv
        info.questionnaire_id = k or 0
        info.id = kk or 0
        table.insert(total_question, info)
      end
    end
  end
  if 1 < #total_question then
    local sortByID = function(a, b)
      return a.id < b.id
    end
    table.sort(total_question, sortByID)
  end
  return total_question
end
function QuickQuestionSystem.SetQuestionData(questionnaire_id, question_list)
  if not questionnaire_id or not question_list then
    return
  end
  if not QuickQuestionSystem._notify_question_list then
    QuickQuestionSystem._notify_question_list = {}
  end
  if not QuickQuestionSystem._notify_question_list[questionnaire_id] then
    QuickQuestionSystem._notify_question_list[questionnaire_id] = question_list
  end
end
function QuickQuestionSystem.ReceiveNotifyQuestion(questions, act_center_data)
  if act_center_data and next(act_center_data) then
    local showQuestionID = QuickQuestionSystem.GetQuestionID(act_center_data)
    QuickQuestionSystem.ReceiveQuestionByReq(act_center_data)
    QuickQuestionSystem.SetActCenterTabData(act_center_data)
    if not QuickQuestionSystem._act_question_list then
      QuickQuestionSystem._act_question_list = {}
    end
    QuickQuestionSystem._act_question_list[showQuestionID].Status = 0
    return
  end
  if questions ~= nil then
    log_tree("[v_wllwu test log with questionlist is:]", questions)
    for k, v_list in pairs(questions) do
      if v_list then
        local data_list = {}
        for i, v in pairs(v_list) do
          if v and type(v) == "table" then
            table.insert(data_list, v)
          end
          if type(v) == "string" then
            QuickQuestionSystem._notify_qustion_title = v
          end
        end
        if 1 <= #data_list then
          QuickQuestionSystem.SetQuestionData(k, data_list)
        end
      end
    end
    if GameStatus.IsInLobbyOrMainCity() then
      QuickQuestionSystem.OpenQuickQuestionUI()
    end
  end
end
function QuickQuestionSystem.IsFaceShow()
  log(bWriteLog and "[bgp] QuickQuestionSystem.IsFaceShow")
  if QuickQuestionSystem._notify_question_list and next(QuickQuestionSystem._notify_question_list) then
    return true
  end
  return false
end
function QuickQuestionSystem.OpenQuickQuestionUI()
  log(bWriteLog and "[bgp] QuickQuestionSystem.OpenQuickQuestionUI")
  local ui_question = UIManager.GetUI(UIManager.UI_Config.ui_quick_question)
  if ui_question and ui_question:IsShow() then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.ui_quick_question)
end
function QuickQuestionSystem.OpenOtherH5(eventType, eventID, vars)
  if not vars.url then
    return
  end
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(vars.url)
end
function QuickQuestionSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby and QuickQuestionSystem._notify_question_list and next(QuickQuestionSystem._notify_question_list) then
    local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
    local bSlapEnd = NewFaceSlapSystem:IsSlapEnd()
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    local isFinshNewwGuide = growthprojectMgrB.IsFinishAllNewGuide()
    log(bWriteLog and "[bgp] isFinshNewwGuide" .. tostring(isFinshNewwGuide))
    if bSlapEnd and isFinshNewwGuide then
      QuickQuestionSystem.OpenQuickQuestionUI()
    end
  end
end
function QuickQuestionSystem.GetQuestionActTableData()
  if not QuickQuestionSystem._act_question_list then
    return nil
  end
  local showQuestionID = QuickQuestionSystem.GetQuestionID(QuickQuestionSystem._act_question_list)
  local data = QuickQuestionSystem._act_question_list[showQuestionID] or {}
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local isExpired = false
  if next(data) and data.begin_time_ts and data.valid_time then
    log(bWriteLog and "[bgp] data.begin_time_ts" .. tostring(data.begin_time_ts))
    local nTotalTime = nowTime - tonumber(data.begin_time_ts)
    isExpired = math.floor(nTotalTime / 3600) >= tonumber(data.valid_time)
  end
  local isOldTime = false
  if next(data) and nowTime >= tonumber(data.end_time_ts) then
    log(bWriteLog and "[bgp] data.end_time_ts" .. tostring(data.end_time_ts))
    isOldTime = true
  end
  if next(data) and (isOldTime or isExpired) then
    QuickQuestionSystem._act_tab_data = {}
    QuickQuestionSystem._act_question_list = {}
    return nil
  end
  return next(QuickQuestionSystem._act_tab_data) and QuickQuestionSystem._act_tab_data or nil
end
function QuickQuestionSystem.SetActCenterTabData(questions)
  local showQuestionID = QuickQuestionSystem.GetQuestionID(questions)
  local data = questions[showQuestionID]
  local title = data.name
  QuickQuestionSystem._act_tab_data = {
    nActID = ActivityFixedID.ActivityQuestion,
    sName = title or LocUtil.GetLocalizeResStr(32005),
    bRedDot = QuickQuestionSystem.UpdateRedTip,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0,
    tData = QuickQuestionSystem.GetActCenterShowData()
  }
end
function QuickQuestionSystem.GetActCenterShowData()
  local showData = {}
  local showQuestionID = QuickQuestionSystem.GetQuestionID(QuickQuestionSystem._act_question_list)
  local data = QuickQuestionSystem._act_question_list[showQuestionID]
  showData.Title = data.name
  showData.Desc = data.desc or ""
  showData.StartTime = data.begin_time_ts
  showData.EndTime = data.end_time_ts
  showData.ImgUrl = ""
  if not showData.List then
    showData.List = {}
  end
  local itemData = {}
  itemData.Title = data.name
  itemData.Progress = data.Status or 0 >= 1 and 1 or 0
  itemData.Total = 1
  itemData.Type = data.type
  itemData.ImgLink = data.q_list or ""
  itemData.ID = showQuestionID or 1
  itemData.Status = data.Status or 0
  itemData.actID = ActivityFixedID.ActivityQuestion
  itemData.Drop = {}
  if data.item_id and tonumber(data.item_id) ~= 0 then
    table.insert(itemData.Drop, {
      itemId = data.item_id,
      count = data.item_num,
      expireTime = data.item_time or 0
    })
  end
  table.insert(showData.List, itemData)
  return showData
end
function QuickQuestionSystem.UpdateRedTip()
  local questionData = QuickQuestionSystem._act_question_list
  if not questionData or not next(questionData) then
    return false, ActivityMacros.RedDotType.None
  end
  local showQuestionID = QuickQuestionSystem.GetQuestionID(questionData)
  if questionData[showQuestionID] and questionData[showQuestionID].Status and questionData[showQuestionID].Status == 1 then
    return true, ActivityMacros.RedDotType.Reward
  end
  return false, ActivityMacros.RedDotType.None
end
function QuickQuestionSystem.RemoveRedPoint()
  local questionData = QuickQuestionSystem._act_question_list
  if not questionData or not next(questionData) then
    return
  end
  local showQuestionID = QuickQuestionSystem.GetQuestionID(questionData)
  if questionData[showQuestionID] and questionData[showQuestionID].Status then
    questionData[showQuestionID].Status = 0
  end
end
function QuickQuestionSystem.ResetData()
  QuickQuestionSystem._notify_question_list = nil
end
function QuickQuestionSystem.ReceiveQuestionDtatByRep(err_code, questions, is_h5_jump)
  if err_code ~= 0 then
    ShowNotice(err_code)
    log(bWriteLog and "[bgp] ReceiveQuestionDtatByRep err_code" .. tostring(err_code))
    return
  end
  if not questions or not next(questions) then
    log(bWriteLog and "[bgp] ReceiveQuestionDtatByRep not data")
    return
  end
  QuickQuestionSystem.ReceiveQuestionByReq(questions, is_h5_jump)
  QuickQuestionSystem.SetActCenterTabData(questions)
end
function QuickQuestionSystem.GetQuestionID(questions)
  if not questions or not next(questions) then
    return 0
  end
  for question_id, v in pairs(questions) do
    if v then
      return question_id
    end
  end
  return 0
end
function QuickQuestionSystem.ReceiveQuestionByReq(questions, is_h5_jump)
  QuickQuestionSystem._act_question_list = questions
  if is_h5_jump and next(is_h5_jump) then
    local showQuestionID = QuickQuestionSystem.GetQuestionID(questions)
    local nextState = is_h5_jump[showQuestionID or 1] - 1 or 0
    log(bWriteLog and "[bgp] nextState:" .. tostring(nextState) .. "questionsID:" .. tostring(showQuestionID))
    QuickQuestionSystem._act_question_list[showQuestionID].Status = nextState
  end
end
function QuickQuestionSystem.SetAwardStatusByNotify(question_id)
  if not QuickQuestionSystem._act_question_list or not QuickQuestionSystem._act_question_list[question_id] then
    log(bWriteLog and "[bgp] SetAwardStatusByNotify not data:")
    return
  end
  QuickQuestionSystem._act_question_list[question_id].Status = 1
end
return QuickQuestionSystem