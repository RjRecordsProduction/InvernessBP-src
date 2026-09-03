local old_androidback = {
  TeamAthleticsResultShare_UIBP_C_RewardDetail = function()
    LuaClassObj.HandleUIMessage(bp_battleresult_deathmatch, "HideRewardDetail")
  end,
  ResultsRanking_BP_C_RankingTitle = function()
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BACK_TO_OVERVIEWPANEL)
  end,
  [""] = function()
    log(bWriteLog and "Exit")
    EventAndroidQuitGame()
  end
}
return old_androidback