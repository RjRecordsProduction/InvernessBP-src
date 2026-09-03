local GameletUtil = {}
function GameletUtil.IsGameletFaceSlapByServerData(serverData)
  if not serverData or not serverData.cfg then
    return false
  end
  return serverData.cfg.back_int_value == ActivityBackUpIntType.Gamelet
end
return GameletUtil