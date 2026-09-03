local logic_xmission_operation = {}
local chestdataList, chestState, accelerationConfig, chestConfig, isShowGuide, IsReceivingChset, countDownTimer, isOpen, isGuidesShow, buildPVEisLock
function logic_xmission_operation:OnInitialize()
  logic_xmission_operation.__super.OnInitialize(self)
end
function logic_xmission_operation:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_XMISSION_OPERATION, self.OnJumpUrl, self)
end
function logic_xmission_operation:OnLogin(bReLogin)
end
function logic_xmission_operation:OnLogOut()
  chestdataList = nil
  chestState = nil
  chestConfig = nil
  accelerationConfig = nil
  isShowGuide = nil
  IsReceivingChset = nil
  buildPVEisLock = nil
  isGuidesShow = nil
  local time_ticker = require("common.time_ticker")
  if countDownTimer then
    time_ticker.RemoveTimer(countDownTimer)
  end
end
function logic_xmission_operation:OnPreSwitchGameStatus(preState, nextState)
  local time_ticker = require("common.time_ticker")
  if countDownTimer then
    time_ticker.RemoveTimer(countDownTimer)
    countDownTimer = nil
  end
end
function logic_xmission_operation:OnPostSwitchGameStatus(preState, nextState)
end
function logic_xmission_operation:OnJumpUrl()
  self:OpenMainUI()
end
function logic_xmission_operation:OnConversationDone(_, _, nStartPlotID)
  if nStartPlotID and nStartPlotID == 200032 then
    self:send_receive_sys_gift()
  end
end
function logic_xmission_operation:GetTabConfig()
  local xmission_operation_tab_config = require("client.slua.logic.TxMission.research.xmission_operation_tab_config")
  local showConfigs = {}
  for i, config in ipairs(xmission_operation_tab_config) do
    if config.showFunc() then
      table.insert(showConfigs, config)
    end
  end
  return showConfigs
end
function logic_xmission_operation:CachePlotData(plot_id, param_type, param1)
  self.plotData = {
    plot_id = plot_id,
    param_type = param_type,
      }
end
function logic_xmission_operation:PlayGuidePlot()
  if self.plotData then
    local XMissionConversationSystem = require("client.slua.logic.TxMission.logic_xmission_conversation")
    XMissionConversationSystem.AddToConversationList(self.plotData.plot_id, XMissionConversationSystem.E_ConversationAwardType.Item, self.plotData.param1, self.plotData.param_type)
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_PLOT_TRIGGER)
    self.plotData = nil
  end
end
function logic_xmission_operation:IsOperationEntryOpen(isShowTips)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXMissionOperationGetRecord) or {}
  if saveData[DataMgr.roleData.uid] and saveData[DataMgr.roleData.uid].isGet then
    log(bWriteLog and string.format("logic_xmission_operation:IsOperationEntryOpen, saveData.isGet:%s", saveData.isGet))
    return true
  end
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if logic_xmission_info:GetGuideConsoleRewardStatus() == 1 then
    log(bWriteLog and "logic_xmission_operation:IsOperationEntryOpen, not guide")
    return true
  end
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  if xmission_wardrobe_data.HaveResearchChest() then
    log(bWriteLog and "logic_xmission_operation:IsOperationEntryOpen, is have cheset")
    return true
  end
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  local totalCnt = 0
  if LogicXMissionBeginnerGuide.currentState and LogicXMissionBeginnerGuide.currentState.totalCount then
    totalCnt = LogicXMissionBeginnerGuide.currentState.totalCount
  end
  if 2 <= totalCnt then
    log(bWriteLog and "logic_xmission_operation:IsOperationEntryOpen, is have totalCount >= 2")
    return true
  end
  return false
end
function logic_xmission_operation:OpenMainUI()
  if not self:IsOpeartionOpened() then
    return
  end
  if not self:IsOperationEntryOpen(true) then
    return
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if MatchSystem.nMatchStatus ~= ENUM_MatchStatus.Not then
    if MatchSystem.nMatchStatus == ENUM_MatchStatus.Ready then
      ShowNotice(67761)
    else
      ShowNotice(67823)
    end
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Xmission_Operation_Main_UIBP)
end
function logic_xmission_operation:GetChestNum(itemId)
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local xmission_prepare_data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  if itemId then
    return xmission_wardrobe_data.GetItemNumByItemId(itemId, true)
  end
  local itemList = xmission_wardrobe_data.GetItemList() or {}
  local num = 0
  for _, data in ipairs(itemList) do
    local itemCfg = xmission_wardrobe_data.FastGetItemData(data.item_id)
    if itemCfg and itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Other and itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_ResearchChest then
      num = num + data.item_num
    end
  end
  if chestdataList and type(chestdataList) == "table" and next(chestdataList) then
    local TableUtil = require("common.table_util")
    num = num - TableUtil.CountTable(chestdataList)
  end
  num = num + xmission_prepare_data.GetItemNumInBag(3001069)
  log(bWriteLog and string.format("logic_xmission_operation:GetChestNum, num:%s", num))
  return num
end
function logic_xmission_operation:GetChestState()
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local chestNum = self:GetChestNum()
  if (not chestdataList or not next(chestdataList)) and chestNum == 0 then
    return xMission_macro.ENUM_OPERATION_STATE_TYPE.EnumType_Nothing
  end
  local remainTime = self:GetChestDataById()
  log(bWriteLog and string.format("logic_xmission_operation:GetChestState, curTime:%s", curTime))
  log(bWriteLog and string.format("logic_xmission_operation:GetChestState, remainTime:%s", remainTime))
  if 0 < chestNum and chestState == 100251055 then
    return xMission_macro.ENUM_OPERATION_STATE_TYPE.EnumType_Empty
  elseif chestdataList and next(chestdataList) and curTime < remainTime then
    return xMission_macro.ENUM_OPERATION_STATE_TYPE.EnumType_Busy
  elseif chestdataList and next(chestdataList) and curTime >= remainTime then
    return xMission_macro.ENUM_OPERATION_STATE_TYPE.EnumType_Available
  elseif chestNum == 0 and chestState == 100251055 then
    return xMission_macro.ENUM_OPERATION_STATE_TYPE.EnumType_Nothing
  end
end
function logic_xmission_operation:IsMakeAffixsNew()
  local logic_xmission_operation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation)
  if not logic_xmission_operation:GetBuildPVEAffixIsLock() then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXMissionOperationPVENew_Lobby) or {}
    if cfg and cfg[DataMgr.roleData.uid] and cfg[DataMgr.roleData.uid].isShowAffixGuide then
      return false
    else
      return true
    end
  else
    return false
  end
end
function logic_xmission_operation:IsEnhanceAffixsNew()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXMissionOperationPVPNew_Lobby) or {}
  if cfg and cfg[DataMgr.roleData.uid] and cfg[DataMgr.roleData.uid].isShowAffixGuide then
    return false
  else
    return true
  end
end
function logic_xmission_operation:GetBuildPVEAffixIsLock()
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  local pveGuideStatus = logic_xmission_info:GetMetroValueByKey("pve_affix_guide_task_reward") or 0
  return pveGuideStatus ~= 1
end
function logic_xmission_operation:GetBuildPVPAffixIsUnLock()
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  local pvpGuideStatus = logic_xmission_info:GetMetroValueByKey("affix_guide_task_status") or 0
  return pvpGuideStatus == 1
end
function logic_xmission_operation:GetAccelerationNum()
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  if not accelerationConfig then
    accelerationConfig = {}
    local configs = CDataTable.GetTable("XMAcceleration")
    for ID, data in pairs(configs) do
      local info = {
        time = data.time
      }
      accelerationConfig[ID] = info
    end
  end
  log_tree(bWriteLog and "logic_xmission_operation:GetAccelerationNum accelerationConfig", accelerationConfig)
  local num = 0
  for ID, _ in pairs(accelerationConfig) do
    num = num + xmission_wardrobe_data.GetItemNumByItemId(tonumber(ID))
  end
  log(bWriteLog and string.format("logic_xmission_operation:GetAccelerationNum, num:%s", num))
  return num
end
function logic_xmission_operation:GetAccelerationData(id)
  if not accelerationConfig then
    accelerationConfig = {}
    local configs = CDataTable.GetTable("XMAcceleration")
    for ID, data in pairs(configs) do
      local info = {
        time = data.time
      }
      accelerationConfig[ID] = info
    end
  end
  log_tree(bWriteLog and "logic_xmission_operation:GetAccelerationData accelerationConfig", accelerationConfig)
  local data = accelerationConfig[id]
  return data
end
function logic_xmission_operation:GetChestDataById()
  if not chestdataList or not next(chestdataList) then
    return
  end
  return chestdataList[next(chestdataList)]
end
function logic_xmission_operation:GetChestInstID()
  if not chestdataList or not next(chestdataList) then
    return
  end
  return next(chestdataList)
end
function logic_xmission_operation:GetChestItemId()
  local instId = self:GetChestInstID()
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local itemData = xmission_wardrobe_data.GetItemByInstID(instId)
  return itemData and itemData.item_id
end
function logic_xmission_operation:GetIsGuidesShow()
  print(bWriteLog and "logic_xmission_operation:GetIsGuidesShow() isGuidesShow = ", isGuidesShow)
  return isGuidesShow
end
function logic_xmission_operation:SetIsReceivingChset(bReceive)
  IsReceivingChset = bReceive
end
function logic_xmission_operation:GetIsReceivingChset()
  return IsReceivingChset
end
function logic_xmission_operation:ShowItemGetPanel(arrayItemList)
  log_tree(bWriteLog and "logic_xmission_operation:ShowItemGetPanel arrayItemList", arrayItemList)
  for _, item in ipairs(arrayItemList) do
    if next(item.extra.affixs) then
      EventSystem:postEvent(EVENTTYPE_T_XMISSION_OPERATION, EVENTTYPE_T_XMISSION_OPERATION_ON_OPEN_CHEST, arrayItemList, true)
      return
    end
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION_OPERATION, EVENTTYPE_T_XMISSION_OPERATION_ON_OPEN_CHEST, arrayItemList)
end
function logic_xmission_operation:IsOpeartionChest(itemID)
  if not chestConfig then
    chestConfig = {}
    local configs = CDataTable.GetTable("XMChest")
    for ID, data in pairs(configs) do
      local info = {
        openTime = data.openTime
      }
      chestConfig[tonumber(ID)] = info
    end
  end
  if chestConfig[itemID] and chestConfig[itemID].openTime > 0 then
    return true
  end
  return false
end
function logic_xmission_operation:IsChestBuyLimited(itemID, isRPItem)
  local LogicXMissionBlackMarket = require("client.slua.logic.TxMission.logic_xmission_black_market")
  local tabInfo = LogicXMissionBlackMarket.GetTabInfoImmediately(LogicXMissionBlackMarket.hotNew)
  if not tabInfo then
    return
  end
  isRPItem = isRPItem and 1 or 0
  local shopInfo
  for _, data in pairs(tabInfo.info or {}) do
    if data.res_id == itemID and data.is_rp_item == isRPItem then
      shopInfo = data
      break
    end
  end
  if not shopInfo then
    return
  end
  if isRPItem == 0 then
    local userData = LogicXMissionBlackMarket.GetUserDataInfo()
    local buyNum = userData and userData.buy_cnt and userData.buy_cnt[shopInfo.shop_id] or 0
    return buyNum >= shopInfo.limit_num
  else
    shopInfo.shopId = shopInfo.shop_id
    local item_status = LogicXMissionBlackMarket.GetRPPrivilegeItemStatus(shopInfo)
    return item_status ~= LogicXMissionBlackMarket.ERPPrivilegeItemStatus.Available
  end
end
function logic_xmission_operation:GetActData()
  local TActivityConfig = {}
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetActivityListByType(ActivitySwitchType.Xmission)
  for _, data in pairs(activityDataTable or {}) do
    if data.Type == ActivityType.GROUP or data.Type == ActivityType.XMISSION_SIGN then
      table.insert(TActivityConfig, {
        actID = data.ID,
        taskList = data.List,
        title = data.Title,
        order = data.Order,
        StartTime = data.StartTime,
        EndTime = data.EndTime
      })
    end
  end
  activityDataTable = ActivityNewSystem.GetActivityListByTypeAndLabel(ActivityType.ACTIVITY_TYPE_AREA_GROUP, ActivitySwitchType.Xmission)
  for _, data in pairs(activityDataTable or {}) do
    local logic_area_group = require("client.slua.logic.activity.commom_activity_center.logic_area_group")
    local areaActDataList = logic_area_group.GetRealDataByFatherActID(data.ID)
    for _, areaActData in ipairs(areaActDataList) do
      table.insert(TActivityConfig, {
        actID = areaActData.ID,
        taskList = areaActData.List,
        title = areaActData.Title,
        order = areaActData.Order,
        StartTime = areaActData.StartTime,
        EndTime = areaActData.EndTime
      })
    end
  end
  table.sort(TActivityConfig, function(a, b)
    return a.order < b.order
  end)
  local isHaveChestToGet = false
  local isHaveChestToReceive = false
  local actData
  for _, data in ipairs(TActivityConfig) do
    if actData then
      break
    end
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if data.StartTime and curTime < data.StartTime or data.EndTime and curTime > data.EndTime then
      break
    end
    for _, taskInfo in ipairs(data.taskList) do
      local isHaveChest = false
      for _, dropInfo in ipairs(taskInfo.Drop or {}) do
        if dropInfo.itemId == 3001069 then
          isHaveChest = true
          break
        end
      end
      if isHaveChest then
        if taskInfo.Status == 0 or taskInfo.Status == 1 then
          actData = data
          isHaveChestToGet = true
        end
        if taskInfo.Status == 1 then
          actData = data
          isHaveChestToReceive = true
        end
      end
    end
  end
  local AreaGroupSystem = require("client.slua.logic.activity.commom_activity_center.logic_area_group")
  local fatherActId = AreaGroupSystem.GetFatherIDBySubID(actData and actData.actID)
  log_tree(bWriteLog and "logic_xmission_operation:GetActData actData", actData)
  log(bWriteLog and string.format("logic_xmission_operation:GetActData, isHaveChestToGet:%s", isHaveChestToGet))
  log(bWriteLog and string.format("logic_xmission_operation:GetActData, isHaveChestToReceive:%s", isHaveChestToReceive))
  return fatherActId, isHaveChestToGet, isHaveChestToReceive
end
function logic_xmission_operation:IsOpeartionOpened()
  local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
  if not logic_xmission_entrance:CheckCanButtonClick() then
    return false
  end
  local switchCfg = CDataTable.GetTableData("TxMissionExtra", "label_switch_console")
  log(bWriteLog and string.format("Xmission_Operations_Area_UIBP:OnClickEntry, switchCfg.value:%s", switchCfg and switchCfg.value))
  if switchCfg and switchCfg.value == 0 or not isOpen then
    ShowNotice(48346)
    return false
  end
  return true
end
function logic_xmission_operation:RpClickTlog(playprefType, tlogType)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(playprefType) or {}
  if not cfg[DataMgr.roleData.uid] then
    cfg[DataMgr.roleData.uid] = {}
  end
  if not cfg[DataMgr.roleData.uid][UnknowPassSystem.Season] then
    cfg[DataMgr.roleData.uid][UnknowPassSystem.Season] = 0
    PlayerPrefsSystem.SaveTableToFile_N(cfg, playprefType)
    tlog_report_utils.ReportTLogEvent(tlogType, 0, UnknowPassSystem.Season)
  end
end
function logic_xmission_operation:send_get_chest_countdown()
  local TResearchHandler = require("client.network.Protocol.TResearchHandler")
  TResearchHandler.send_get_chest_countdown()
end
function logic_xmission_operation:on_get_chest_countdown_rsp(ret_code, dataList, use_accelerate)
  isOpen = ret_code ~= 1
  if ret_code == 100250000 or ret_code == 100251053 then
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission(true) then
    log(bWriteLog and string.format("on_get_chest_countdown_rsp, not IsInXMission"))
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self:RpClickTlog(PlayerPrefsSystem.ePlayerPrefsType.eXMissionOperationRpClick, TLogEventDefine.OperationRPClick)
  self:RpClickTlog(PlayerPrefsSystem.ePlayerPrefsType.eXMissionInsuranceRpClick, TLogEventDefine.InsuranceRPClick)
  self:RpClickTlog(PlayerPrefsSystem.ePlayerPrefsType.eXMissionMarketAccRpClick, TLogEventDefine.BlackMarketAccRPClick)
  self:RpClickTlog(PlayerPrefsSystem.ePlayerPrefsType.eXMissionMarketAccBuyRpClick, TLogEventDefine.BlackMarketAccBuyRPClick)
  local LogicXMissionBlackMarket = require("client.slua.logic.TxMission.logic_xmission_black_market")
  local tabInfo = LogicXMissionBlackMarket.GetTabInfoImmediately(LogicXMissionBlackMarket.hotNew)
  if not tabInfo then
    LogicXMissionBlackMarket.GetTabInfoReq(LogicXMissionBlackMarket.hotNew)
  end
  chestState = ret_code
  chest  if use_accelerate then
    local noticeSystem = require("client.slua.logic.common.logic_notice_mgr")
    noticeSystem.RemoveAllNotice()
    ShowNotice(48321)
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION_OPERATION, EVENTTYPE_T_XMISSION_OPERATION_ON_GET_DATA, use_accelerate)
  local state = self:GetChestState()
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  if not (chestdataList and next(chestdataList)) or state ~= xMission_macro.ENUM_OPERATION_STATE_TYPE.EnumType_Busy then
    return
  end
  if not countDownTimer then
    local TimeUtil = require("client.common.time_util")
    countDownTimer = self:AddTimerLoop(0, function()
      if not UIManager.IsUIShow(UIManager.UI_Config.Xmission_Operation_Main_UIBP) then
        local curTime = TimeUtil.GetServerTimeInSec()
        local remainTime = self:GetChestDataById()
        if chestdataList and next(chestdataList) then
          if remainTime - curTime < 0 then
            self:RemoveTimer(countDownTimer)
            countDownTimer = nil
            self:send_get_chest_countdown()
          end
        else
          self:RemoveTimer(countDownTimer)
          countDownTimer = nil
        end
      end
    end, TIMER_INFINITE, 1)
  end
end
function logic_xmission_operation:send_use_chest_accelerate(inst_id, count, chestID)
  local TResearchHandler = require("client.network.Protocol.TResearchHandler")
  TResearchHandler.send_use_chest_accelerate(inst_id, count, chestID)
end
function logic_xmission_operation:send_put_chest_on_console(inst_id)
  local TResearchHandler = require("client.network.Protocol.TResearchHandler")
  TResearchHandler.send_put_chest_on_console(inst_id)
  self:send_get_chest_countdown()
end
function logic_xmission_operation:on_put_chest_on_console_rsp(ret_code)
  if ret_code ~= 0 then
    return
  end
  self:send_get_chest_countdown()
end
function logic_xmission_operation:send_receive_sys_gift()
  if isGuidesShow then
    return
  end
  local TResearchHandler = require("client.network.Protocol.TResearchHandler")
  TResearchHandler.send_receive_sys_gift()
end
function logic_xmission_operation:on_receive_sys_gift_rsp(ret_code, item_list)
  if ret_code == 100251057 then
    isGuidesShow = true
    return
  elseif ret_code ~= 0 then
    return
  end
  local rewardList = {}
  for itemId, count in pairs(item_list) do
    table.insert(rewardList, {resid = itemId, count = count})
  end
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  if TxMissionHandler.bUseNewLogic then
    local logic_xmission_npc_plot_config = require("client.slua.logic.TxMission.plot.logic_xmission_npc_plot_config")
    local logic_xmission_npc_plot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_npc_plot)
    logic_xmission_npc_plot:AddOnePlotData(200032, logic_xmission_npc_plot_config.EPlotParamType.Item, rewardList)
  else
    local XMissionConversationSystem = require("client.slua.logic.TxMission.logic_xmission_conversation")
    XMissionConversationSystem.PushConversation(200032, XMissionConversationSystem.E_ConversationAwardType.Item, rewardList)
  end
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  logic_xmission_info:SetGuideConsoleRewardStatus(1)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION_OPERATION, EVENTTYPE_T_XMISSION_OPERATION_ON_GET_DATA)
end
function logic_xmission_operation:on_get_pve_affix_guide_task_reveive_rsp(isGet)
  if isGet == 0 then
    buildPVEisLock = true
  else
    buildPVEisLock = false
    local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
    logic_xmission_info:SetMetroValueByKey("pve_affix_guide_task_reward", 1)
  end
end
function logic_xmission_operation:OnMetroDecomposeItemRsp(item_id, item_num)
  local Result = {}
  table.insert(Result, {res_id = item_id, count = item_num})
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(Result)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_xmission_operation = class(CModuleBase, nil, logic_xmission_operation)
return Clogic_xmission_operation