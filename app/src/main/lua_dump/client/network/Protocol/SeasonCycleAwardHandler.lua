local NetManager = require("client.network.comm.NetManager")
local SeasonCycleAwardHandler = {}
function SeasonCycleAwardHandler.send_get_season_year_reward_info_req()
  NetManager.SendPkg(1731057543)
end
function SeasonCycleAwardHandler.on_get_season_year_reward_info_rsp(err_code, season_year_detail_info, _, reward_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_cycle_award = require("client.logic.season.logic_season_cycle_award")
  logic_season_cycle_award.on_get_season_year_reward_info_rsp(season_year_detail_info, reward_info)
end
function SeasonCycleAwardHandler.send_get_season_year_reward_req(season_year_id, icon_id)
  NetManager.SendPkg(1016661319, season_year_id, icon_id)
end
function SeasonCycleAwardHandler.on_get_season_year_reward_rsp(err_code, season_year_id, year_reward_list, itemlist)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_cycle_award = require("client.logic.season.logic_season_cycle_award")
  logic_season_cycle_award.on_get_season_year_reward_rsp(season_year_id, year_reward_list, itemlist)
end
function SeasonCycleAwardHandler.on_ace_imprint_status_chg_notify(icon_id, cur_status_list)
  local logic_season_cycle_award = require("client.logic.season.logic_season_cycle_award")
  logic_season_cycle_award.on_ace_imprint_status_chg_notify(icon_id, cur_status_list)
end
function SeasonCycleAwardHandler.on_season_year_makeup_task_notify(list)
  local logic_season_cycle_award = require("client.logic.season.logic_season_cycle_award")
  logic_season_cycle_award.on_season_year_makeup_task_notify(list)
end
function SeasonCycleAwardHandler.send_get_single_icon_reward_req(season_year_id, icon_id, season_id)
  NetManager.SendPkg(66080968, season_year_id, icon_id, season_id)
end
function SeasonCycleAwardHandler.on_get_single_icon_reward_res(res, season_year_id, icon_collect_pro_list, one_reward_itemlist, season_id)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_season_cycle_award = require("client.logic.season.logic_season_cycle_award")
  logic_season_cycle_award.on_get_single_icon_reward_res(season_year_id, icon_collect_pro_list, one_reward_itemlist, season_id)
end
function SeasonCycleAwardHandler.on_ace_imprint_icon_got_notify(medal_id, season_id)
  local logic_season_cycle_award = require("client.logic.season.logic_season_cycle_award")
  logic_season_cycle_award.on_ace_imprint_icon_got_notify(medal_id, season_id)
end
function SeasonCycleAwardHandler.send_get_all_season_prize_reward_req(season_reward_list, year_reward_list)
  NetManager.SendPkg(696037015, season_reward_list, year_reward_list)
end
function SeasonCycleAwardHandler.on_get_all_season_prize_reward_rsp(res, icon_collect_pro_list, reward_list, year_reward_list)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_season_cycle_award = require("client.logic.season.logic_season_cycle_award")
  logic_season_cycle_award.on_get_all_season_prize_reward_rsp(icon_collect_pro_list, reward_list, year_reward_list)
end
function SeasonCycleAwardHandler.send_get_season_year_reward_redpot_req()
  log(bWriteLog and "SeasonCycleAwardHandler.send_get_season_year_reward_redpot_req")
  NetManager.SendPkg(890365279)
end
function SeasonCycleAwardHandler.on_get_season_year_reward_redpot_rsp(err_code, redpot_flag)
  log(bWriteLog and "SeasonCycleAwardHandler.on_get_season_year_reward_redpot_rsp err_code:" .. tostring(err_code) .. " redpot_flag:" .. tostring(redpot_flag))
  local logic_season_cycle_award = require("client.logic.season.logic_season_cycle_award")
  logic_season_cycle_award.on_get_season_year_reward_redpot_rsp(err_code, redpot_flag)
end
return SeasonCycleAwardHandler