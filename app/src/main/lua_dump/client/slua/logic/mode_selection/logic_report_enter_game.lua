local logic_report_enter_game = {}
function logic_report_enter_game.ReportWhenEnterGame(sub_mode)
  log(bWriteLog and "logic_enter_game:EnterBattle ReportEnterBattleFromMainCityClickStart")
  log(bWriteLog and sub_mode)
  logic_report_enter_game._ReportEnterBattleFromMainCityClickStart()
  logic_report_enter_game._RecordHasEnterZombieBattle(sub_mode)
  logic_report_enter_game._ReportLeaveMainCity(sub_mode)
end
function logic_report_enter_game._ReportEnterBattleFromMainCityClickStart()
  xpcall(function()
    log(bWriteLog and "logic_enter_game:EnterBattle ReportEnterBattleFromMainCityClickStart")
    local logic_main_city_achievement_task_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_achievement_task_report")
    logic_main_city_achievement_task_report.ReportEnterBattleFromMainCityClickStart()
  end, require("common.utility").ErrorMessageHandler)
end
function logic_report_enter_game._RecordHasEnterZombieBattle(sub_mode)
  xpcall(function()
    local logic_config_mission_select_mode = require("client.slua.umg.TxMission.xMission.zombie.logic.logic_config_mission_select_mode")
    local logic = logic_config_mission_select_mode.getLogic()
    if logic.RecordHasEnterZombieBattle then
      logic:RecordHasEnterZombieBattle(sub_mode)
    end
  end, require("common.utility").ErrorMessageHandler)
end
function logic_report_enter_game._ReportLeaveMainCity(sub_mode)
  log(bWriteLog and "logic_report_enter_game ReportLeaveMainCity")
  if sub_mode then
    local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
    if Lobby_Main_City.IsMainCitySubMode(sub_mode) then
      log(bWriteLog and "logic_report_enter_game ReportLeaveMainCity -- EnterMainCity, not leave MC")
      return
    end
    if not GameStatus.IsInMainCity() then
      log(bWriteLog and "logic_report_enter_game ReportLeaveMainCity-- not enter fight from main city")
      return
    end
    xpcall(function()
      local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
      logic_main_city_enter_report.ReportLeaveMainCity(logic_main_city_enter_report.LeaveMainCityReasonList.EnterBattle)
    end, require("common.utility").ErrorMessageHandler)
  end
end
return logic_report_enter_game