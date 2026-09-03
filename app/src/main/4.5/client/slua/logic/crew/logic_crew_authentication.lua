local logic_crew_authentication = {}
local NONE = 0
local BRank = 1
local Info = {}
local Detail = {}
local SenderMap = {}
local authCount
local auth_is_pass = false
local auth_check_cnt = 0
local auth_code = 0
local auth_is_pass_pug = false
local auth_check_cnt_pug = 0
local auth_check_interval_pug = 1
local auth_code_pub
local auth_is_pass_allstar = false
local auth_check_cnt_allstar = 0
local auth_check_interval_allstar = 1
local auth_code_allstar
local auth_is_pass_tournament = false
local auth_check_cnt_tournament = 0
local auth_check_interval_tournament = 1
local auth_code_tournament
function logic_crew_authentication.InsertSender(ID)
  SenderMap[ID] = true
  local NetManager = require("client.network.comm.NetManager")
  NetManager.SendPkg(ID)
end
function logic_crew_authentication.RemoveSender(ID)
  SenderMap[ID] = nil
  if not next(SenderMap) then
    EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_RESPONSE)
  end
end
function logic_crew_authentication.RequestData()
  logic_crew_authentication.InsertSender(1910)
  logic_crew_authentication.InsertSender(8101)
end
function logic_crew_authentication.SetInfo(svrInfo, reward, isEnroll, rankCfg)
  Info = {}
  Info.scoreInfo = svrInfo
  Info.authScore = svrInfo.average_score
  Info.rankConfig = rankCfg
  Info.isEnrolled = isEnroll
  Info.currentRank = NONE
  Info.rewardState = 0
  for rank, cfg in pairs(rankCfg) do
    if Info.authScore >= cfg.min_auth_score and Info.authScore <= cfg.max_auth_score then
      Info.currentRank = rank
    end
  end
  Info.rankConfig[NONE] = {}
  Info.rankConfig[NONE].min_auth_score = 0
  Info.rankConfig[NONE].max_auth_score = rankCfg[BRank].min_auth_score - 1
  if reward.carteam_level then
    if Info.currentRank == reward.carteam_level then
      Info.rewardState = 1
    else
      Info.rewardState = 2
    end
  else
    Info.rewardState = 0
  end
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_INFO_UPDATE)
end
function logic_crew_authentication.SetDetail(selfDetail, memberDetail, cfg)
  Detail = {}
  Detail.punish = {}
  Detail.mission = {}
  for _, v in pairs(CDataTable.GetTable("auth_task_table")) do
    Detail.mission[v.id] = {
      id = v.id,
      cond_val = v.cond_val,
      is_valid = v.is_valid,
      task_type = v.task_type,
      task_desc = v.task_desc,
      auth_score = v.auth_score
    }
  end
  for _, v in pairs(CDataTable.GetTable("auth_punish_table")) do
    Detail.punish[v.punish_type] = {
      is_valid = v.is_valid,
      punish_type = v.punish_type,
      punish_desc = v.punish_desc,
      punish_score = v.punish_score
    }
  end
  if cfg and cfg.task_cfg then
    for _, v in pairs(cfg.task_cfg) do
      Detail.mission[v.id] = v
    end
  end
  if cfg and cfg.punish_cfg then
    for _, v in pairs(cfg.punish_cfg) do
      Detail.punish[v.punish_type] = v
    end
  end
  for UID, Player in pairs(memberDetail) do
    Detail[UID] = logic_crew_authentication.ProcessDetail(Player.auth_task_list, Player.punish_list, Player.punish_score, Player.devote_score, false)
  end
  Detail[tonumber(DataMgr.roleData.uid)] = logic_crew_authentication.ProcessDetail(selfDetail.auth_task_info, selfDetail.punish_list, selfDetail.punish_score, selfDetail.devote_score, true)
end
function logic_crew_authentication.ProcessDetail(MissionList, PunishList, PunishScore, DevoteScore, IsSelf)
  local record = {
    Mission = {},
    Punish = {},
    PunishScore = math.abs(PunishScore),
    DevoteScore = math.max(DevoteScore - 100, 0)
  }
  for ID, nums in pairs(PunishList) do
    local Data = logic_crew_authentication.GetPunishCfg(ID)
    if Data and Data.is_valid == 1 and 0 < nums then
      table.insert(record.Punish, {
        score = Data.punish_score,
        desc = Data.punish_desc,
        nums = nums,
        type = Data.punish_type
      })
    end
  end
  if IsSelf then
    for ID, Data in pairs(Detail.mission) do
      local Rec = {
        score = Data.auth_score,
        desc = Data.task_desc,
        type = Data.task_type,
        status = 0
      }
      local numerator = 0
      local denominator = Data.cond_val
      if MissionList[ID] then
        Rec.status = MissionList[ID].status
        numerator = MissionList[ID].proc
      end
      if Rec.type == 2 then
        denominator = 1
        numerator = 0
      end
      Rec.progress = string.format("%d/%d", numerator, denominator)
      if Data.is_valid == 1 then
        table.insert(record.Mission, Rec)
      end
    end
  else
    for ID, _ in pairs(MissionList) do
      local Data = logic_crew_authentication.GetMissionCfg(ID)
      if Data and Data.is_valid == 1 then
        table.insert(record.Mission, {
          score = Data.auth_score,
          desc = Data.task_desc,
          type = Data.task_type,
          status = 1,
          progress = ""
        })
      end
    end
  end
  return record
end
function logic_crew_authentication.GetPunishCfg(ID)
  return Detail.punish[ID]
end
function logic_crew_authentication.GetMissionCfg(ID)
  return Detail.mission[ID]
end
function logic_crew_authentication.RewardResponse(teamLevel, items)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(items, true)
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_REWARD_RESPONSE, teamLevel)
end
function logic_crew_authentication.ClearData()
  Info = nil
  Detail = nil
end
function logic_crew_authentication.GetInfo()
  return Info
end
function logic_crew_authentication.GetDetail()
  return Detail
end
function logic_crew_authentication.SetAuthCount(count)
  authCount = count
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_COUNT_UPDATE)
end
function logic_crew_authentication.GetAuthCount()
  return authCount
end
function logic_crew_authentication.ShouldAuthGuide(phrase)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eCrewAuthenticationGuide
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData and saveData[phrase] then
    return false
  end
  return true
end
function logic_crew_authentication.SaveAuthGuideInfo(phrase)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eCrewAuthenticationGuide
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  saveData = saveData or {}
  saveData[phrase] = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
end
function logic_crew_authentication.GetTeamLevelName(lv)
  local levelName = {
    [1] = 8819,
    [2] = 8820,
    [3] = 8821
  }
  if 1 <= lv and lv <= 3 then
    return LocUtil.GetLocalizeResStr(levelName[lv])
  end
  return ""
end
function logic_crew_authentication.GetTeamLevelAuthText(lv)
  local levelName = {
    [1] = 8815,
    [2] = 8816,
    [3] = 8817
  }
  if 1 <= lv and lv <= 3 then
    return LocUtil.GetLocalizeResStr(levelName[lv])
  end
  return ""
end
function logic_crew_authentication.IsAuthGuideSuccess()
  return true
end
function logic_crew_authentication.GetAuthRankConfig()
  if Info.rankConfig then
    return Info.rankConfig
  end
  return {}
end
function logic_crew_authentication.GetAuthScore()
  if Info.authScore then
    return Info.authScore
  end
  return 0
end
function logic_crew_authentication.GetScoreInfo()
  return Info.scoreInfo
end
function logic_crew_authentication.SetAuthCheckInfo(is_pass, check_cnt)
  log(bWriteLog and "SetAuthCheckInfo is_pass:" .. tostring(is_pass))
  log(bWriteLog and "SetAuthCheckInfo check_cnt:" .. tostring(check_cnt))
  auth_  auth_  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_CHECK_INFO_UPDATE)
end
function logic_crew_authentication.GetAuthCheckInfo()
  return auth_is_pass, auth_check_cnt
end
function logic_crew_authentication.SyncAuthCheckResult(err_code)
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_SYNC_AUTH_CHECK_RESULT, err_code)
end
function logic_crew_authentication.SetBanNameList(name_list)
  local ban_name_list = {}
  for k, v in pairs(name_list) do
    local tb = {name = k, time = v}
    table.insert(ban_name_list, tb)
  end
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_BAN_NAME_LIST_UPDATE, ban_name_list)
end
function logic_crew_authentication.SetAuthCode(code)
  log(bWriteLog and "logic_crew_authentication.SetAuthCode code: " .. tostring(code))
  auth_end
function logic_crew_authentication.GetAuthCode()
  return auth_code
end
function logic_crew_authentication.ObfuscationTest(filter, num)
  local feature = {
    [1] = "root",
    [2] = "malware",
    [3] = "cdn",
    [4] = "cs",
    [5] = "permission"
  }
  local CrewHandler = require("client.network.Protocol.CrewHandler")
  local DelegateContainer = require("common.delegate_container")
  local delegate = DelegateContainer()
  local list = {}
  local temp
  local times = tonumber(num) or 10000
  local function generate(index, value)
    table.insert(temp, value)
    if 5 <= index then
      local x = {}
      for _, v in pairs(temp) do
        table.insert(x, v)
      end
      table.insert(list, x)
      return
    end
    generate(index + 1, true)
    table.remove(temp)
    generate(index + 1, false)
    table.remove(temp)
  end
  temp = {}
  generate(1, true)
  temp = {}
  generate(1, false)
  if tonumber(filter) == 0 then
    delegate:AddTimer(0, function()
      local result
      print(bWriteLog and "[CrewAuthentication] SDK test begin", times)
      for i = 1, times do
        result = Tss.GetDeviceFeature(logic_crew_authentication.GetAuthCode())
        CrewHandler.send_test_client_umix(result)
        coroutine.yield(0.01)
      end
      print(bWriteLog and "[CrewAuthentication] SDK test end")
    end)
  else
    delegate:AddTimer(0, function()
      for k, v in pairs(list) do
        local str = ""
        local input = ""
        local result
        for m, n in pairs(v) do
          if n then
            input = input .. feature[m] .. ";"
          end
          str = str .. tostring(n) .. " "
        end
        print(bWriteLog and "[CrewAuthentication] Now iterate : ", k, str, times)
        print(bWriteLog and "[CrewAuthentication] ObfuscationTest Feature String : ", input)
        for i = 1, times do
          result = Tss.EigenArrayObfuscationVerify(logic_crew_authentication.GetAuthCode(), input)
          CrewHandler.send_test_client_umix(result, v)
          coroutine.yield(0.01)
        end
      end
    end)
  end
end
function logic_crew_authentication.SetAuthCheckInfo_Pug(is_pass, check_cnt, auth_check_interval, au_code)
  log(bWriteLog and "SetAuthCheckInfo_Pug is_pass:" .. tostring(is_pass))
  log(bWriteLog and "SetAuthCheckInfo_Pug check_cnt:" .. tostring(check_cnt))
  log(bWriteLog and "SetAuthCheckInfo_Pug auth_check_interval:" .. tostring(auth_check_interval))
  log(bWriteLog and "SetAuthCheckInfo_Pug au_code:" .. tostring(au_code))
  auth_is_pass_pug = is_pass
  auth_check_cnt_pug = check_cnt
  auth_check_interval_pug = auth_check_interval
  auth_code_pub = au_code
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_CHECK_INFO_UPDATE)
end
function logic_crew_authentication.GetAuthCheckInfo_Pug()
  return auth_is_pass_pug, auth_check_cnt_pug, auth_check_interval_pug, auth_code_pub
end
function logic_crew_authentication.SyncAuthCheckResult_Pug(err_code)
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_SYNC_AUTH_CHECK_RESULT, err_code)
end
function logic_crew_authentication.SetAuthCheckInfo_AllStar(is_pass, check_cnt, auth_check_interval, au_code)
  log(bWriteLog and "SetAuthCheckInfo_AllStar is_pass:" .. tostring(is_pass))
  log(bWriteLog and "SetAuthCheckInfo_AllStar check_cnt:" .. tostring(check_cnt))
  log(bWriteLog and "SetAuthCheckInfo_AllStar auth_check_interval:" .. tostring(auth_check_interval))
  log(bWriteLog and "SetAuthCheckInfo_AllStar au_code:" .. tostring(au_code))
  auth_is_pass_allstar = is_pass
  auth_check_cnt_allstar = check_cnt
  auth_check_interval_allstar = auth_check_interval
  auth_code_allstar = au_code
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_CHECK_INFO_UPDATE)
end
function logic_crew_authentication.GetAuthCheckInfo_AllStar()
  return auth_is_pass_allstar, auth_check_cnt_allstar, auth_check_interval_allstar, auth_code_allstar
end
function logic_crew_authentication.SyncAuthCheckResult_AllStar(err_code)
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_SYNC_AUTH_CHECK_RESULT, err_code)
end
function logic_crew_authentication.SetAuthCheckInfo_Tournament(is_pass, check_cnt, auth_check_interval, au_code)
  log(bWriteLog and "SetAuthCheckInfo_Tournament is_pass:" .. tostring(is_pass))
  log(bWriteLog and "SetAuthCheckInfo_Tournament check_cnt:" .. tostring(check_cnt))
  log(bWriteLog and "SetAuthCheckInfo_Tournament auth_check_interval:" .. tostring(auth_check_interval))
  log(bWriteLog and "SetAuthCheckInfo_Tournament au_code:" .. tostring(au_code))
  auth_is_pass_tournament = is_pass
  auth_check_cnt_tournament = check_cnt
  auth_check_interval_tournament = auth_check_interval
  auth_code_tournament = au_code
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_CHECK_INFO_UPDATE)
end
function logic_crew_authentication.GetAuthCheckInfo_Tournament()
  return auth_is_pass_tournament, auth_check_cnt_tournament, auth_check_interval_tournament, auth_code_tournament
end
function logic_crew_authentication.SyncAuthCheckResult_Tournament(err_code)
  EventSystem:postEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_SYNC_AUTH_CHECK_RESULT, err_code)
end
return logic_crew_authentication