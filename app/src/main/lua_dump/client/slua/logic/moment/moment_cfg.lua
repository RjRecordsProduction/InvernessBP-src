local moment_cfg = {
  moment_info = {
    access_switch = 0,
    notify_switch = 0,
    ban_time = 0,
    moment_cfg = {
      post_moment_day_limit = 20,
      moment_min_level = 25,
      hot_moment_gray_switch = 99,
      moment_min_segment = 101,
      post_moment_total_limit = 300,
      moment_top_reddot_switch = true
    }
  },
  bForceRemoveLimit = false
}
function moment_cfg.GetMomentCfg()
  return moment_cfg.moment_info.moment_cfg
end
function moment_cfg.SetMomentInfo(moment_info)
  if moment_info then
    moment_cfg.    if moment_cfg.moment_info then
      moment_cfg.moment_info.ban_time = moment_info.ban_time or 0
    end
  end
end
function moment_cfg.IsLevelEnough()
  if moment_cfg.bForceRemoveLimit then
    return true
  end
  local level = DataMgr.roleData.level
  local cfg = moment_cfg.GetMomentCfg()
  if cfg and cfg.moment_min_level and level < cfg.moment_min_level then
    return false
  end
  return true
end
function moment_cfg.IsSegmentLevelEnough()
  if moment_cfg.bForceRemoveLimit then
    return true
  end
  local cfg = moment_cfg.GetMomentCfg()
  if cfg and cfg.moment_min_segment then
    local segment_level = FuncUtil.GetCurMaxSegementLevel(DataMgr.roleData.allzoneSegment)
    if segment_level < cfg.moment_min_segment then
      return false
    end
  end
  return true
end
local err_moment_level_state = 104000027
local err_moment_segment_state = 104000028
function moment_cfg.IsLevelLimitEnough(showTips)
  if not moment_cfg.IsLevelEnough() then
    if showTips then
      moment_cfg.ShowLevelTips(err_moment_level_state)
    end
    return false
  end
  if not moment_cfg.IsSegmentLevelEnough() then
    if showTips then
      moment_cfg.ShowLevelTips(err_moment_segment_state)
    end
    return false
  end
  return true
end
function moment_cfg.ShowLevelTips(codeTips)
  local cfg = moment_cfg.GetMomentCfg()
  if not cfg then
    return
  end
  if codeTips == err_moment_level_state then
    ShowNotice(LocUtil.LocalizeResFormat(codeTips, cfg.moment_min_level))
  elseif codeTips == err_moment_segment_state then
    local segment = FuncUtil.GetRankTableData(cfg.moment_min_segment)
    if segment then
      ShowNotice(LocUtil.LocalizeResFormat(codeTips, segment.Name or ""))
    end
  end
end
function moment_cfg.IsReachDayMaxLimit(showTips)
  local moment_data = require("client.slua.logic.moment.logic_moment_data")
  local my_moment_info = moment_data.get_my_moment_info()
  if my_moment_info then
    local cfg = moment_cfg.GetMomentCfg()
    local day_cnt = my_moment_info.day_post_cnt or 0
    if cfg.post_moment_day_limit and day_cnt >= cfg.post_moment_day_limit then
      if showTips then
        ShowNotice(18465)
      end
      return true
    end
    local total_cnt = my_moment_info.total_post_cnt or 0
    if cfg.post_moment_total_limit and total_cnt >= cfg.post_moment_total_limit then
      if showTips then
        ShowNotice(18940)
      end
      return true
    end
  end
  return false
end
function moment_cfg.RemoveAccountLimit()
  moment_cfg.bForceRemoveLimit = true
end
function moment_cfg.UpdatePlayerMomentSettings(setting_info)
  if setting_info then
    if setting_info.access then
      moment_cfg.moment_info.access_switch = setting_info.access or 0
    end
    if setting_info.notify then
      moment_cfg.moment_info.notify_switch = setting_info.notify or 0
    end
  end
end
function moment_cfg.CheckHotOpen()
  local switch = moment_cfg.moment_info.moment_cfg.hot_moment_gray_switch
  if switch then
    return true
  end
  return false
end
function moment_cfg.IsOpenToStranger()
  return moment_cfg.moment_info.access_switch == 0
end
function moment_cfg.GetMsgNotifySet()
  return moment_cfg.moment_info.notify_switch
end
function moment_cfg.GetPostMomentTotalLimit()
  return moment_cfg.moment_info.moment_cfg.post_moment_total_limit
end
return moment_cfg