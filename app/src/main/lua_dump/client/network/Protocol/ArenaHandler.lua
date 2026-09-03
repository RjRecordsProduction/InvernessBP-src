local NetManager = require("client.network.comm.NetManager")
local ArenaHandler = {}
function ArenaHandler.send_receive_arena_season_prize_req(task_id)
  NetManager.SendPkg(1591929223, task_id)
end
function ArenaHandler.on_receive_arena_season_prize_rsp(err_code, award_list, prize_list)
  log(bWriteLog and "[edward][ArenaHandler] ArenaHandler.on_receive_arena_season_prize_rsp, err_code = " .. err_code)
  if err_code == 0 then
    local ArenaSystem = require("client.slua.logic.arena.logic_arena")
    ArenaSystem.OnReceiveArenaSeasonPrizeRsp(award_list, prize_list)
  else
    ShowNotice(err_code)
  end
end
function ArenaHandler.send_get_arena_season_prize_req()
  NetManager.SendPkg(839069351)
end
function ArenaHandler.on_get_arena_season_prize_rsp(err_code, prize_list)
  log(bWriteLog and "[edward][ArenaHandler] ArenaHandler.on_get_arena_season_prize_rsp, err_code = " .. err_code)
  if err_code == 0 then
    local ArenaSystem = require("client.slua.logic.arena.logic_arena")
    ArenaSystem.OnGetArenaSeasonPrizeRsp(prize_list)
  else
    ShowNotice(err_code)
  end
end
function ArenaHandler.send_get_arena_season_record_req(zone_id)
  NetManager.SendPkg(1798603307, zone_id)
end
function ArenaHandler.on_get_arena_season_record_rsp(err_code, season_record_arena)
  log(bWriteLog and "[edward][ArenaHandler] ArenaHandler.on_get_arena_season_record_rsp, err_code = " .. err_code)
  log_tree("ArenaHandler.on_get_arena_season_record_rsp season_record_arena = ", season_record_arena)
  if err_code == 0 then
    local ArenaSystem = require("client.slua.logic.arena.logic_arena")
    ArenaSystem.OnGetArenaSeasonRecordRsp(season_record_arena)
  else
    ShowNotice(err_code)
  end
end
return ArenaHandler