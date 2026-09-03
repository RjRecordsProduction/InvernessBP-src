local act_red_cfg = {}
act_red_cfg.NeedRefreshActs = {
  {
    moduleName = "client.slua.logic.activity.PeriodicCrate.logic_periodic_crate",
    funcName = "GetActivitySubData_PeriodicCrate"
  }
}
return act_red_cfg