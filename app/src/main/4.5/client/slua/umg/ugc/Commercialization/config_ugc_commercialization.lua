local config_ugc_commercialization = {}
local _WorkDataInfo = {
  Follow = 1,
  Publish = 2,
  Played = 3,
  Hot = 4
}
config_ugc_commercialization.Elocal _PlayDataInfo = {
  Follow = 1,
  Collect = 2,
  PlayCnt = 3,
  PlayTime = 4
}
config_ugc_commercialization.Elocal _PersonalTabID = {Detail = 1}
config_ugc_commercialization.Config_UGClocal _UGCPersonalDetail = {
  nID = _PersonalTabID.Detail,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab03_png.UGC_tab03_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab04_png.UGC_tab04_png",
  sModule = "UGC_PersonalMainDetail_Sub_UIBP",
  sRoot = "CanvasPanel_Border_Comment"
}
local _UGC_PersonalMainPanelTabs = {_UGCPersonalDetail}
config_ugc_commercialization.Configlocal _UGCIncentiveProgramState = {
  NotApplying = -1,
  JoinSucceed = 1,
  AuditFailed = 2
}
config_ugc_commercialization.Clocal _UGCIncentiveProgramAwardState = {
  general_task_status_not_finish = 0,
  general_task_status_finished = 1,
  general_task_status_awarded = 2,
  general_task_status_expired = 3,
  general_task_status_frozen = 4
}
config_ugc_commercialization.Clocal _UGCIncentiveProgramTabID = {IncentiveIncomeID = 1, MonthlyTasksID = 2}
local _UGCIncentiveProgramTab = {
  {
    Name = 68702,
    Open = function()
      return true
    end
  },
  {
    Name = 68703,
    Open = function()
      if LobbySystem.CheckOpen(BP_ENUM_UGC_ACTIVE_MOTIVATION_MONTHLY_TASKS_SWITCH) then
        return true
      else
        return false
      end
    end
  }
}
config_ugc_commercialization.Clocal _UGC_Wallet_API_Name = {
  QueryIncomeRecord = "QueryIncomeRecord",
  QueryWithdrawRecord = "QueryWithdrawRecord"
}
config_ugc_commercialization.Clocal _UGCWithdrawalOrderStatus = {
  WithdrawingInProgress = 0,
  WithdrawalCompleted = 1,
  PendingProcessing = 2,
  OrderHasExpired = 3,
  WithdrawalFailed = 4
}
config_ugc_commercialization.Cconfig_ugc_commercialization.Enum_Url_Id = {
  UGCWalletRegisterFL = 6,
  UGCWalletCreativeCompetition = 7,
  UGCWalletPDPActivity = 8
}
config_ugc_commercialization.Enum_Income_Type = {
  match = "match",
  incentive = "incentive",
  shop_incentive = "shop_incentive"
}
config_ugc_commercialization.Enum_Income_Classify_Type = {
  wow = "wow",
  pdp = "pdp",
  home = "home",
  crazy_weekend = "crazy_weekend",
  wow_shop = "wow_shop"
}
local _UGC_Crystal_Incentive_Join_Status = {
  NotJoin = -1,
  UnderReview = 0,
  Approved = 1,
  Rejected = 2
}
config_ugc_commercialization.Clocal _UGC_Crystal_API_NAME = {
  RevenueRecord = "QueryCrystalIncomeRecord",
  WithdrawRecord = "QueryCrystalWithdrawalRecord"
}
config_ugc_commercialization.Clocal _UGC_Crystal_Exchange_Type = {Crystal2WOWCoin = 1}
config_ugc_commercialization.Clocal _UGC_WOWCoin_Exchange_Popup_Source = {
  Personal = 1,
  WOWPass = 2,
  Center = 3,
  PropShopInGame = 4,
  PropShopLobby = 5,
  Withdrawal = 6,
  Exchange = 7
}
config_ugc_commercialization.Clocal _UGC_CrystalIncentive_Guide_Type = {
  Join = 1,
  PaidProps = 2,
  Withdrawal = 3
}
config_ugc_commercialization.Creturn config_ugc_commercialization