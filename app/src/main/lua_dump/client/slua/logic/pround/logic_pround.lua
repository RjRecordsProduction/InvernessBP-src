local logic_pround = {}
function logic_pround.SendGiftRsp(pround_info)
  log(bWriteLog and "[logic_pround] SendGiftRsp")
  local prev_pround_exp, prev_pround_level
  if DataMgr.roleData.pround_info then
    prev_pround_exp = DataMgr.roleData.pround_info.exp
    prev_pround_level = DataMgr.roleData.pround_info.level
  end
  local addProundExp = 0
  if pround_info then
    if pround_info.added_pround then
      addProundExp = pround_info.added_pround
      log(bWriteLog and "[RoleInfoPopularitySystem] send gift add pround: " .. tostring(addProundExp))
    else
      addProundExp = pround_info.exp - (prev_pround_exp or 0)
    end
    if prev_pround_level and prev_pround_level < pround_info.level then
      logic_pround.ShowProundLevelUpNotice(pround_info.level)
    end
  else
    log(bWriteLog and "[RoleInfoPopularitySystem] invalid gift rsp pround_info")
  end
  logic_pround.UpdateSelfProundInfo(pround_info)
  return addProundExp
end
function logic_pround.UpdateSelfProundInfo(pround_info)
  log(bWriteLog and "[logic_pround] UpdateSelfProundInfo")
  if not pround_info then
    log(bWriteLog and "[logic_pround] nil pround_info")
    return
  end
  log_tree("[logic_pround] SyncSelfProundInfo", pround_info)
  if not DataMgr.roleData.pround_info then
    log(bWriteLog and "[logic_pround] nil DataMgr.roleData.pround_info")
    DataMgr.roleData.pround_info = {}
  end
  DataMgr.roleData.pround_info.level = pround_info.level
  DataMgr.roleData.pround_info.exp = pround_info.exp
  DataMgr.roleData.pround_info.last_exp_update_time = pround_info.last_exp_update_time
  DataMgr.roleData.pround_info.last_week_exp = pround_info.last_week_exp
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local myProfile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if myProfile then
    if not myProfile.pround_info then
      myProfile.pround_info = {}
    end
    myProfile.pround_info.level = pround_info.level
    myProfile.pround_info.exp = pround_info.exp
    myProfile.pround_info.last_exp_update_time = pround_info.last_exp_update_time
    myProfile.pround_info.last_week_exp = pround_info.last_week_exp
  end
end
function logic_pround.ShowProundLevelUpNotice(new_pround_level)
  local levelUpTips = LocUtil.LocalizeResFormat(44239, new_pround_level)
  local patternIcon = "HoroismIcon"
  local iconLevel = logic_pround.GetProundIconLevel(new_pround_level)
  levelUpTips = string.gsub(levelUpTips, patternIcon, patternIcon .. tostring(iconLevel))
  ShowNotice(levelUpTips)
end
function logic_pround.GetProundIconLevel(pround_level)
  local icon_level = 0
  local ProundLevelCfg = CDataTable.GetTable("ProundLevelCfg")
  for level = pround_level, 1, -1 do
    local curLevelCfg = ProundLevelCfg[level]
    if curLevelCfg and curLevelCfg.EffectType and curLevelCfg.EffectType == 1 then
      icon_level = icon_level + 1
    end
  end
  if icon_level < 1 then
    icon_level = 1
  elseif 5 < icon_level then
    icon_level = 5
  end
  return icon_level
end
return logic_pround