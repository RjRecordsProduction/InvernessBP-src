local Logic_Temu_Stage = {
  stageDetail = {},
  lastSendTime = 0,
  stageValue = {}
}
local Enum_BuyState = {
  Lock = 0,
  CanBuy = 1,
  AlreadyBuy = 2
}
local Enum_TaskState = {
  NotStart = 0,
  CanReceive = 1,
  Complete = 2
}
local lastTimeSpan = 10
local GetModule = function()
  return ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
end
function Logic_Temu_Stage.ResetData()
  Logic_Temu_Stage.stageDetail = {}
  Logic_Temu_Stage.stageValue = {}
  Logic_Temu_Stage.lastSendTime = 0
end
function Logic_Temu_Stage.SendGetAllStageInfo(isForce)
  Logic_Temu_Stage.SendGetStageInfo(isForce)
end
function Logic_Temu_Stage.SendGetStageInfo(isForce)
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local lastTime = Logic_Temu_Stage.lastSendTime or 0
  if not isForce and curTime < lastTime + lastTimeSpan then
    return
  end
  log(bWriteLog and "[SY]Logic_Temu_Stage.SendGetStageInfo.")
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_get_temu_stage_info_req()
end
function Logic_Temu_Stage.SendBuyPackage(stageId, packageId)
  local isCanBuy = Logic_Temu_Stage.IsCanBuyPackage(stageId)
  if not isCanBuy then
    log(bWriteLog and "[SY]Logic_Temu_Stage.SendBuyPakage. not can buy")
    return
  end
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Stage.SendBuyPackage. No Module")
    return
  end
  local priceInfo = Logic_Temu:GetPriceInfo(packageId)
  if not priceInfo then
    return
  end
  local directInfo = priceInfo
  local purchaseInfo = {}
  purchaseInfo.CentauriProductId = directInfo.productid
  purchaseInfo.CentauriCountry = directInfo.country
  purchaseInfo.CentauriCurrency = directInfo.curency_unit
  purchaseInfo.CentauriPrice = (tonumber(directInfo.CentauriPrice) or 0) / 10
  purchaseInfo.CentauriPayItem = directInfo.payItem
  purchaseInfo.priceDesc = CentauriManager.GetPriceByProductId(purchaseInfo.CentauriProductId, purchaseInfo.CentauriCurrency, tostring(purchaseInfo.CentauriCurrency) .. tostring(purchaseInfo.CentauriPrice), true)
  local info = {}
  info.item_id = directInfo.item_id
  info.CentauriProductId = purchaseInfo.CentauriProductId
  info.CentauriPayItem = purchaseInfo.CentauriPayItem
  info.CentauriPrice = purchaseInfo.CentauriPrice
  info.CentauriCountry = purchaseInfo.CentauriCountry
  info.CentauriCurrency = purchaseInfo.CentauriCurrency
  local store_direct_purchase_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_direct_purchase_manager)
  store_direct_purchase_manager:SetDirectPurchaseInfo(info)
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_buy_temu_group_pkg_req(stageId, packageId)
end
function Logic_Temu_Stage.SendGivePackage(stageId, packageId, uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local isFriend = LogicFriend.IsMyFriend(uid)
  if not isFriend then
    return
  end
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Stage.SendGivePackage. No Module")
    return
  end
  local priceInfo = Logic_Temu:GetPriceInfo(packageId)
  if not priceInfo then
    log(bWriteLog and "[SY]Logic_Temu_Stage.SendGivePackage. No priceInfo")
    return
  end
  local directInfo = priceInfo
  local purchaseInfo = {}
  purchaseInfo.CentauriProductId = directInfo.productid
  purchaseInfo.CentauriCountry = directInfo.country
  purchaseInfo.CentauriCurrency = directInfo.curency_unit
  purchaseInfo.CentauriPrice = (tonumber(directInfo.CentauriPrice) or 0) / 10
  purchaseInfo.CentauriPayItem = directInfo.payItem
  purchaseInfo.priceDesc = CentauriManager.GetPriceByProductId(purchaseInfo.CentauriProductId, purchaseInfo.CentauriCurrency, tostring(purchaseInfo.CentauriCurrency) .. tostring(purchaseInfo.CentauriPrice), true)
  local info = {}
  info.item_id = directInfo.item_id
  info.CentauriProductId = purchaseInfo.CentauriProductId
  info.CentauriPayItem = purchaseInfo.CentauriPayItem
  info.CentauriPrice = purchaseInfo.CentauriPrice
  info.CentauriCountry = purchaseInfo.CentauriCountry
  info.CentauriCurrency = purchaseInfo.CentauriCurrency
  local store_direct_purchase_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_direct_purchase_manager)
  store_direct_purchase_manager:SetDirectPurchaseInfo(info)
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_buy_temu_group_pkg_for_gift_req(stageId, packageId, uid)
end
function Logic_Temu_Stage.SendGetStageTaskProgress(stageId)
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Stage.SendBuyPackage. No Module")
    return
  end
  if not Logic_Temu:IsHaveTeam() then
    return
  end
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_get_temu_group_progress_req(stageId)
end
function Logic_Temu_Stage.IsCanBuyPackage(stage)
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Stage.SendBuyPackage. No Module")
    return
  end
  local curStage = Logic_Temu:GetCurStageID()
  local curSubStage = Logic_Temu:GetCurSubStageID()
  local state = Logic_Temu_Stage.GetStageBuyState(stage)
  local isCanBuy = false
  local isCurStageBuy = state == Enum_BuyState.AlreadyBuy
  if curStage == stage and 3 <= curSubStage or stage < curStage then
    isCanBuy = state == Enum_BuyState.CanBuy
  end
  return isCanBuy, isCurStageBuy
end
function Logic_Temu_Stage.GetStageBuyState(stage)
  local info = Logic_Temu_Stage.GetStageInfo(stage)
  if not info then
    return 0
  end
  return info.pkg_status
end
function Logic_Temu_Stage.GetTaskData(stage, taskId)
  local info = Logic_Temu_Stage.GetStageInfo(stage)
  if not info or not info.task_list then
    return nil
  end
  return info.task_list[taskId]
end
function Logic_Temu_Stage.GetTaskProgressState(stage, taskId)
  local taskData = Logic_Temu_Stage.GetTaskData(stage, taskId)
  if not taskData then
    return 0
  end
  return taskData.status
end
function Logic_Temu_Stage.GetTaskProgress(stage, taskId)
  local info = Logic_Temu_Stage.GetStageInfo(stage)
  if not info then
    return 0
  end
  return info.task_list[taskId]
end
function Logic_Temu_Stage.SendCompleteTask(task_id, stageId)
  local state = Logic_Temu_Stage.GetTaskProgressState(stageId, task_id)
  if state ~= Enum_TaskState.CanReceive then
    log(bWriteLog and "[SY]Logic_Temu_Stage.SendCompleteTask.cant complete task", tostring(state))
    return
  end
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_take_temu_friendship_req(stageId, task_id)
end
function Logic_Temu_Stage.OnSendGetStageInfo(stageList)
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  Logic_Temu_Stage.stageDetail = {}
  for i, v in pairs(stageList) do
    if not Logic_Temu_Stage.stageDetail[i] then
      Logic_Temu_Stage.stageDetail[i] = {}
    end
    local detail = Logic_Temu_Stage.stageDetail[i]
    detail.stage = v.stage
    detail.task_list = v.tasks
    detail.pkg_status = v.pkg_status
    detail.task_progress = v.task_progress
    detail.friendship_value = v.friendship_value
    detail.chosen_pkg_id = v.chosen_pkg_id
  end
  Logic_Temu_Stage.lastSendTime = curTime
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_STAGE_INFO)
end
function Logic_Temu_Stage.OnSendGetStageTaskProgress(data)
  if not Logic_Temu_Stage.stageValue[data.stage_id] then
    Logic_Temu_Stage.stageValue[data.stage_id] = {}
  end
  Logic_Temu_Stage.stageValue[data.stage_id].task_progress = data.task_progress
  Logic_Temu_Stage.stageValue[data.stage_id].friendship_value = data.friendship_value
end
function Logic_Temu_Stage.OnSendCompleteTask(award_list, stage_id, task_id)
  local stageInfo = Logic_Temu_Stage.GetStageInfo(stage_id)
  if not stageInfo then
    Logic_Temu_Stage.SendGetStageInfo(true)
  else
    stageInfo.task_list[task_id].status = 2
  end
  Logic_Temu_Stage.SendGetStageTaskProgress(stage_id)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list, nil, nil)
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_COMPLETE_TASK)
end
function Logic_Temu_Stage.OnBuyComplete(stage_id, reward_list)
  local stageInfo = Logic_Temu_Stage.GetStageInfo(stage_id)
  if stageInfo then
    stageInfo.pkg_status = 2
  end
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Stage.SendBuyPackage. No Module")
    return
  end
  local teamInfo = Logic_Temu:GetSelfTeamInfo()
  if teamInfo then
    for i, v in pairs(teamInfo.member) do
      if v.uid == tonumber(DataMgr.roleData.uid) then
        v.package_purchased = true
      end
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(reward_list, nil, nil)
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_BUY_COMPLETE)
end
function Logic_Temu_Stage.GetStageInfo(stageID)
  local stageInfo = Logic_Temu_Stage.stageDetail[stageID]
  if not stageInfo then
    return nil
  end
  return stageInfo
end
function Logic_Temu_Stage.GetAllStageData()
  return Logic_Temu_Stage.stageDetail
end
function Logic_Temu_Stage.GetStageAnimationState()
  if Logic_Temu_Stage.stageAnimationState then
    return Logic_Temu_Stage.stageAnimationState
  end
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Stage.GetStageAnimationState.No Module")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.TemuStageAnim)
  local seasonID = Logic_Temu:GetCurSeasonID()
  local groupID = Logic_Temu:GetSelfTeamID()
  log(bWriteLog and "[SY]Logic_Temu_Stage.GetStageAnimationState.seasonID: " .. tostring(seasonID) .. "  groupID:" .. tostring(groupID))
  log_tree("Logic_Temu_Stage.GetStageAnimationState", info)
  Logic_Temu_Stage.stageAnimationState = {}
  if info and seasonID ~= 0 and groupID ~= 0 and info.seasonID == seasonID and info.groupID == groupID and info.stageAnimationState then
    for i, j in pairs(info.inviteList) do
      Logic_Temu_Stage.stageAnimationState[i] = j
    end
  end
  return Logic_Temu_Stage.stageAnimationState
end
function Logic_Temu_Stage.StageAnimShow(stageList)
  for i, stageID in pairs(stageList) do
    Logic_Temu_Stage.stageAnimationState[stageID] = true
  end
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Stage.StageAnimShow.No Module")
    return
  end
  local seasonID = Logic_Temu:GetCurSeasonID()
  local groupID = Logic_Temu:GetSelfTeamID()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({
    seasonID = seasonID,
    groupID = groupID,
    stageAnimationState = Logic_Temu_Stage.stageAnimationState
  }, PlayerPrefsSystem.ePlayerPrefsType.TemuStageAnim)
end
function Logic_Temu_Stage.ClearStageAnimationState()
  Logic_Temu_Stage.stageAnimationState = {}
end
function Logic_Temu_Stage.IsBuyAllPackage()
  local allStage = Logic_Temu_Stage.stageDetail
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Stage.IsBuyAllPackage.No Module")
    return
  end
  local allStageCfg = Logic_Temu:GetAllStageCfg()
  if not (allStageCfg and allStage) or not next(allStage) then
    return false
  end
  for i, v in pairs(allStageCfg) do
    local stageData = allStage[i]
    if not stageData or stageData.pkg_status ~= Enum_BuyState.AlreadyBuy then
      return false
    end
  end
  return true
end
function Logic_Temu_Stage.GetStageBuyPackageID(stage)
  local stageInfo = Logic_Temu_Stage.GetStageInfo(stage)
  if not stageInfo then
    return 0
  end
  return stageInfo.chosen_pkg_id
end
function Logic_Temu_Stage.IsStageAllPersonalTaskComplete(stage, number)
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Stage.IsStageAllPersonalTaskComplete.No Module")
    return
  end
  local allTask = Logic_Temu:GetStageAllTask(stage, number)
  if not allTask or not next(allTask) then
    return false
  end
  for i, v in pairs(allTask) do
    local state = Logic_Temu_Stage.GetTaskProgressState(stage, v.id)
    if v.type == 0 and state ~= Enum_TaskState.Complete and state ~= Enum_TaskState.CanReceive then
      return false
    end
  end
  return true
end
function Logic_Temu_Stage.ClearLastSendTime()
  Logic_Temu_Stage.lastSendTime = 0
end
return Logic_Temu_Stage