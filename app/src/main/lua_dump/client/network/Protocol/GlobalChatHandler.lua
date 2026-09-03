local NetManager = require("client.network.comm.NetManager")
local GlobalChatHandler = {}
function GlobalChatHandler.send_report_game_activity(totalTalkingTime, totalGamingTime, MainModeID, SubModeID)
  NetManager.SendPkg(686687933, totalTalkingTime, totalGamingTime, MainModeID, SubModeID)
end
return GlobalChatHandler