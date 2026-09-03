local logic_friendnum_limit = {nFriendNumMax = 200, nTipTimes = 2}
function logic_friendnum_limit.CheckAndShowFriendNumLimitTipsUI(parentUI, attachWidgetName)
  log(bWriteLog and "logic_friendnum_limit.CheckAndShowFriendNumLimitTipsUI")
  local nShowTipsTimes = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_FRIENDSTATUS, 3)
  if nShowTipsTimes and nShowTipsTimes >= logic_friendnum_limit.nTipTimes then
    log(bWriteLog and "logic_friendnum_limit.CheckAndShowFriendNumLimitTipsUI nShowTipsTimes = " .. nShowTipsTimes)
    return false
  end
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  local res_friendlist = logic_friend_list.res_friendlist
  if res_friendlist == nil then
    log(bWriteLog and "logic_friendnum_limit.CheckAndShowFriendNumLimitTipsUI res_friendlist == nil")
    return false
  end
  local totalFriendNum = res_friendlist.inner_fri_count + res_friendlist.plat_fri_count
  if totalFriendNum < logic_friendnum_limit.nFriendNumMax then
    log(bWriteLog and "logic_friendnum_limit.CheckAndShowFriendNumLimitTipsUI totalFriendNum < " .. logic_friendnum_limit.nFriendNumMax)
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_FRIENDSTATUS, 3, 10)
    return false
  end
  if nShowTipsTimes == nil then
    nShowTipsTimes = 1
  else
    nShowTipsTimes = nShowTipsTimes + 1
  end
  DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_FRIENDSTATUS, 3, nShowTipsTimes)
  if parentUI.tipsChildUI then
    parentUI.tipsChildUI:Close()
    parentUI.tipsChildUI = nil
  end
  parentUI.tipsChildUI = parentUI:CreateChildWindow(attachWidgetName, UIManager.UI_Config.Friendlimit_Tips)
  log(bWriteLog and "logic_friendnum_limit.CheckAndShowFriendNumLimitTipsUI show tips")
  return true
end
function logic_friendnum_limit.CloseFriendNumLimitTipsUI(parentUI, bNeverShow)
  log(bWriteLog and "logic_friendnum_limit.CloseFriendNumLimitTipsUI")
  if not parentUI then
    log(bWriteLog and "logic_friendnum_limit.CloseFriendNumLimitTipsUI not parentUI")
    return
  end
  if bNeverShow then
    local nShowTipsTimes = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_FRIENDSTATUS, 3)
    if nShowTipsTimes == nil or nShowTipsTimes < logic_friendnum_limit.nTipTimes then
      DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_FRIENDSTATUS, 3, 10)
    end
  end
  if parentUI.tipsChildUI then
    parentUI.tipsChildUI:Close()
    parentUI.tipsChildUI = nil
  end
end
function logic_friendnum_limit.GM_ShowTips()
  logic_friendnum_limit.nFriendNumMax = 0
  logic_friendnum_limit.nTipTimes = 9999
end
return logic_friendnum_limit