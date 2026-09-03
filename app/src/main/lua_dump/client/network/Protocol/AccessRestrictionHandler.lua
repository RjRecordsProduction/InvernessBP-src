local AccessRestrictionHandler = {}
function AccessRestrictionHandler.on_player_cheat_state_notify(player_cheat_state)
  local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
  AccessRestrictionSystem.on_player_cheat_state_notify(player_cheat_state)
end
return AccessRestrictionHandler