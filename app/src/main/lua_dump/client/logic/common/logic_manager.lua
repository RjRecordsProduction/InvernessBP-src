local LogicManager = {
  logicManagerNameList = {
    "client.network.comm.NetManager",
    "client.slua.logic.mini_tv.logic_mini_tv",
    "client.logic.LogicPlayerPrefs.playerprefs",
    "client.logic.LogicPlayerPrefs.LogicPlayerPrefs",
    "client.network.Protocol.WeaponDiyHandler",
    "client.slua.logic.gamemaster.logic_accel",
    "client.slua.logic.friend.logic_new_friend",
    "client.slua.logic.Pandora.pandora_logic",
    "client.slua.logic.lobby_chat.logic_chat_main",
    "client.slua.logic.GuideFlow.Event.GuideFlowEventMap",
    "client.slua.logic.GuideFlow.logic_guide_flow",
    "client.slua.logic.growth_project.logic_growth_project_b",
    "client.slua.logic.growth_project.enter_guide",
    "client.logic.message_push.logic_message_push_trigger",
    "client.slua.logic.growth_project.logic_new_player_spin",
    "client.slua.logic.achievement.logic_achievement_float_tip",
    "client.slua.logic.community.logic_community",
    "client.slua.logic.lobby.logic_mode_entry",
    "client.slua.logic.lbs.logic_lbs",
    "client.slua.logic.replay.logic_replay"
  }
}
function LogicManager.Init()
  log(bWriteLog and "[trace][init] LogicManager.Init Begin")
  local _beginTime = slua.getMicroseconds()
  for _, v in pairs(LogicManager.logicManagerNameList) do
    local moduleStart = slua.getMicroseconds()
    local manager = require(v)
    if manager == nil then
    else
      local initFunc = manager.Init
      if initFunc ~= nil then
        log(bWriteLog and "LogicManager.Init call " .. v)
        local utility = require("common.utility")
        xpcall(initFunc, utility.ErrorMessageHandler)
      end
    end
    local moduleCost = (slua.getMicroseconds() - moduleStart) / 1000
    log(bWriteLog and string.format("TimeTracer LogicManager.Init module:%s  time: [%.3fms]", tostring(v), moduleCost))
  end
  local _useTime = (slua.getMicroseconds() - _beginTime) / 1000
  log(bWriteLog and string.format("TimeTracer LogicManager.Init  time: [%.3fms]", _useTime))
end
return LogicManager