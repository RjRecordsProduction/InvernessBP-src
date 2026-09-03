local RankConfig = require("client.slua.logic.rank.rank_config")
local InspectEnum = RankConfig.InspectEnum
local areaSwitch
local myReplayState = InspectEnum.notSet
local settlementPush = false
local inspectURL = FuncUtil.GetDomainByID(3366036) .. "/act/a20190812aqxz/patrol.shtml?region={country}&sTicket={itop_ticket}&language={language}&game_area={game_area}&head_pic={head_pic}&gameid={gameid}&nickname={nickname}&openid={itop_openid}&version={version}&never_adjust=1&iPatrolList=1"
local logic_rank_inspect = {}
function logic_rank_inspect.ResRankInspectInfo(replaySwitch, replayValue)
  log(bWriteLog and string.format(" replaySwitch = %s , replayValue = %s", replaySwitch, replayValue))
  areaSwitch = replaySwitch or false
  if replayValue == nil then
    myReplayState = InspectEnum.notSet
  elseif replayValue == false then
    myReplayState = InspectEnum.notAccepted
  elseif replayValue == true then
    myReplayState = InspectEnum.accepted
  end
end
function logic_rank_inspect.ReportSelectResult(isAgree)
  log(bWriteLog and string.format(" ResSelectResult , isAgree = %s ", isAgree))
  local RankHandler = require("client.network.Protocol.RankHandler")
  if isAgree then
    RankHandler.send_rank_replay_switch_req(true)
  else
    RankHandler.send_rank_replay_switch_req(false)
  end
end
function logic_rank_inspect.ResSelectResult(err, isAgree)
  log(bWriteLog and string.format(" ResSelectResult err = %s, isAgree = %s ", err, isAgree))
  if err == 0 then
    if isAgree then
      myReplayState = InspectEnum.accepted
    else
      myReplayState = InspectEnum.notAccepted
    end
  else
    ShowNotice(err)
  end
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_INSPECT)
end
function logic_rank_inspect.NotifyAfterSettlement(zone_id, score_type, score)
  settlementPush = true
end
function logic_rank_inspect.PopAfterSettlement()
  if settlementPush then
    settlementPush = false
    logic_rank_inspect.PopInspectNotice(false)
    log(bWriteLog and string.format(" CheckPopWhenOpenRank settlementPush = true 1"))
  end
end
function logic_rank_inspect.CheckPopWhenOpenRank(no)
  if myReplayState ~= InspectEnum.notSet then
    log(bWriteLog and string.format(" CheckPopWhenOpenRank myReplayState ~= InspectEnum.notSet"))
    return
  end
  if settlementPush then
    settlementPush = false
    logic_rank_inspect.PopInspectNotice(false)
    log(bWriteLog and string.format(" CheckPopWhenOpenRank settlementPush = true"))
    return
  end
  local noNum = tonumber(no) or 0
  if noNum < 100 and 0 < noNum then
    logic_rank_inspect.PopInspectNotice(false)
    log(bWriteLog and string.format(" CheckPopWhenOpenRank no = %s", no))
    return
  end
end
function logic_rank_inspect.PopInspectNotice(fromSetting)
  if not areaSwitch then
    log(bWriteLog and string.format(" ResSelectResult areaSwitch is false"))
    return
  end
  if myReplayState == InspectEnum.accepted then
    log(bWriteLog and string.format(" ResSelectResult already"))
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.rank_inspect_msg_box, fromSetting)
end
function logic_rank_inspect.ShowInspectURL()
  local url = inspectURL
  local StringUtil = require("common.string_util")
  if url then
    if StringUtil.Starts(url, "http") then
      local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
      url = webModule:AddParameterByPersonalInfo(url, true)
    end
    GlobalData.JumpUrl(url)
  end
end
function logic_rank_inspect.IsMyFightVideoPublic()
  return myReplayState == InspectEnum.accepted
end
function logic_rank_inspect.IsAreaSwitchOpen()
  return areaSwitch
end
function logic_rank_inspect.IsAlreadySelected()
  return myReplayState ~= InspectEnum.notSet
end
return logic_rank_inspect