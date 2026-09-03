local wardrobe_data_util = {}
function wardrobe_data_util.OnModePostSwitch(preState, nextState)
end
function wardrobe_data_util.IsNewWhenCountChange(ResID)
  local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
  if ResID == WardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE or ResID == WardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE_SEASON or LogicAddScordCard:IsPutOnSeasonAddScoreCard(ResID) or ResID == WardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONE_HOUR or ResID == WardrobeMacro.ENUM_WardrobePropResId.VS_TEAM_WEAPON_EXP_CARD or ResID == WardrobeMacro.ENUM_WardrobePropResId.VS_TEAM_RATING_PROTECT_TIMES_CARD then
    return true
  end
  return false
end
return wardrobe_data_util