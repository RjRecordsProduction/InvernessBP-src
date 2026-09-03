local TournamentIntroduceSystem = {}
function TournamentIntroduceSystem.ShowUI()
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.tournament_introduce)
  end
end
function TournamentIntroduceSystem.CloseUI()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.tournament_introduce)
  end
end
function TournamentIntroduceSystem.CheckAndShow()
  local newbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Introduce)
  if newbieGuide then
    TournamentIntroduceSystem.ShowUI()
  end
end
function TournamentIntroduceSystem.UpdateRedPoint()
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  if not TournamentsManager.LockEnter then
    local timeData = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Tournament_New)
    if timeData then
      local TimeUtil = require("client.common.time_util")
      local nowData = math.floor(TimeUtil.GetServerTimeInSec() / 86400)
      if 0 < nowData - timeData then
        TournamentsManager.UpdateBonusReddot()
      end
    end
  end
end
function TournamentIntroduceSystem.OnIntroduceFinished()
  local newbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Introduce)
  if newbieGuide then
    local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
    TournamentsManager.get_tournament_newbie_award_req()
  end
end
function TournamentIntroduceSystem.OnGetNewbieAwards(arrayItemData)
  TournamentIntroduceSystem.CloseUI()
  local newbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, 1)
  if newbieGuide then
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, 1)
    local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
    TournamentsManager.get_tournament_score_req()
    if arrayItemData and next(arrayItemData) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
    end
  end
end
return TournamentIntroduceSystem