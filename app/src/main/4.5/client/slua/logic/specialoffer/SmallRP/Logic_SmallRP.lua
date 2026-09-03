local Logic_SmallRPConst = require("client.slua.logic.specialoffer.SmallRP.Logic_SmallRPConst")
local Logic_QRCodeRestrictUtils = require("client.slua.logic.QRCodeLogin.Logic_QRCodeRestrictUtils")
local Logic_SmallRP = {}
local Enum_Task = Logic_SmallRPConst.Enum_Task
local _ScoreDefaultItemId = 1127
local _nLastRequestBaseDateTime = 0
local _nMaxTurnTableCount = 2
function Logic_SmallRP:DefineAndResetData()
  Logic_SmallRP.__super.DefineAndResetData(self)
  self._fBuyScoreCallback = nil
  self._tActData = nil
  self._tActCfg = nil
  self._tAllBannerLevel = nil
  self._nCurLevel = 1
  self._tLevelCfg = nil
  self._tAllTaskData = nil
  self._tAllTaskProReward = nil
  self._tRoundLevelAwardCfg = nil
  self._tRoundLevelGroup = {}
  self._tRoundTaskCfg = nil
  self._sGMSetShowRoundId = nil
  self._tCurShowRewardTipLevel = nil
  self._nTaskProRewardMinProValue = nil
  self._nUpgradeLastLevel = nil
  self._bIsNeedUpgradeAnim = false
  self._bIsShowUpgradeLevelPanelLine = false
  self._tScoreProBarQueue = {}
end
function Logic_SmallRP:OnInitialize()
  Logic_SmallRP.__super.OnInitialize(self)
  self:InitLevelCfg()
end
function Logic_SmallRP:RegistEvents()
  Logic_SmallRP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_COMMON_SCORE_PRO_BAR, EVENTID_COMMON_SCORE_PRO_BAR_CHECK_SHOW, self.CheckShowScoreProBarTip, self)
end
function Logic_SmallRP:OnLogin(bReLogin)
  Logic_SmallRP.__super.OnLogin(self, bReLogin)
  log(bWriteLog and " Logic_SmallRP OnLogin >>>>>" .. tostring(bReLogin))
  if bReLogin then
    self._fBuyScoreCallback = nil
  end
end
function Logic_SmallRP:OnPostSwitchGameStatus(nPreStatus, _)
  if not GameStatus.IsInLobbyOrMainCity() then
    self._nUpgradeLastLevel = nil
    self._bIsNeedUpgradeAnim = false
    self._bIsShowUpgradeLevelPanelLine = false
    self._tScoreProBarQueue = {}
  end
end
function Logic_SmallRP:ResetRoundData()
  self._tActData = nil
  self._tActCfg = nil
  self._tAllBannerLevel = nil
  self._tAllTaskData = nil
  self._tAllTaskProReward = nil
  self._nTaskProRewardMinProValue = nil
  self._tCurShowRewardTipLevel = nil
  self._nCurLevel = 1
  self._tLevelCfg = nil
  self._tRoundLevelAwardCfg = {}
  self._tRoundLevelGroup = {}
  self._tRoundCollectItemCfg = {}
  self._tRoundTaskCfg = {}
end
function Logic_SmallRP:GetActRoundId()
  if not self._tActData then
    return
  end
  if self._sGMSetShowRoundId then
    return self._sGMSetShowRoundId
  end
  return self._tActData.act_term_id
end
function Logic_SmallRP:GetActShowCfg()
  local nActRound = self:GetActRoundId()
  if not nActRound then
    return
  end
  local uObj_actCfg = CDataTable.GetTableData("AssembleActShowCfg", nActRound) or {}
  if not uObj_actCfg.TemplateBasePath or uObj_actCfg.TemplateBasePath == "" then
    return
  end
  return uObj_actCfg
end
function Logic_SmallRP:GetSmallRPBgIconCfg()
  local nActRound = self:GetActRoundId()
  if not nActRound then
    log(bWriteLog and "Logic_SmallRP:GetSmallRPBgIconCfg not nActRound")
    return
  end
  local uObj_actCfg = CDataTable.GetTableData("AssembleActShowCfg", nActRound) or {}
  if not (uObj_actCfg.SmallRPBgIconLeft and uObj_actCfg.SmallRPBgIconLeft ~= "" and uObj_actCfg.SmallRPBgIconRight) or uObj_actCfg.SmallRPBgIconRight == "" then
    log(bWriteLog and "Logic_SmallRP:GetSmallRPBgIconCfg not BgPath")
    return
  end
  log(bWriteLog and "Logic_SmallRP:GetSmallRPBgIconCfg " .. tostring(uObj_actCfg.SmallRPBgIconLeft) .. "   " .. tostring(uObj_actCfg.SmallRPBgIconRight))
  return uObj_actCfg.SmallRPBgIconLeft, uObj_actCfg.SmallRPBgIconRight
end
function Logic_SmallRP:GetActTime()
  local tActCfg = self._tActCfg
  if not tActCfg then
    return
  end
  return tActCfg.begin_time, tActCfg.end_time
end
function Logic_SmallRP:GetIsOpen()
  local tActCfg = self._tActCfg
  if not tActCfg then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  if nCurTime >= tActCfg.begin_time and nCurTime <= tActCfg.end_time then
    return true
  end
  return false
end
function Logic_SmallRP:GetIsTaskDataValid()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local taskCfgs = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple)
  return taskCfgs ~= nil
end
function Logic_SmallRP:RequestTaskData(callback)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.general_task_cond_cfg_simple, callback)
end
function Logic_SmallRP:GetSmallRPCardId()
  local tActCfg = self._tActCfg
  if not tActCfg then
    return
  end
  return tActCfg.unlock_card_item_id
end
function Logic_SmallRP:GetIPLineActId()
  local tActCfg = self._tActCfg
  if not tActCfg then
    return
  end
  return tActCfg.concerned_crossover_id
end
function Logic_SmallRP:GetIPScoreId()
  local tActCfg = self._tActCfg
  if not tActCfg then
    return
  end
  return tActCfg.crossover_score_res_id
end
function Logic_SmallRP:GetLevelExtraGetIPScoreNum()
  local tActCfg = self._tActCfg
  if not tActCfg then
    return 0
  end
  return tActCfg.crossover_score_count or 0
end
function Logic_SmallRP:GetIsUnlock()
  if self._tActData then
    return self._tActData.is_unlock
  end
  return false
end
function Logic_SmallRP:IsMaxLevelReached()
  local nCurLevel = self:GetCurLevel()
  local nMaxLevel = self:GetMaxLevel()
  return nCurLevel >= nMaxLevel
end
function Logic_SmallRP:GetCurLevel()
  return self._nCurLevel or 1
end
function Logic_SmallRP:GetLevelScore(nLevel)
  if not self._tLevelCfg then
    self:InitLevelCfg()
  end
  return self._tLevelCfg and self._tLevelCfg[nLevel] or 0
end
function Logic_SmallRP:GetMaxLevel()
  if not self._tLevelCfg then
    self:InitLevelCfg()
  end
  return self._tLevelCfg and #self._tLevelCfg or 0
end
function Logic_SmallRP:GetCurScore()
  if not self._tActData or not self._tActData.score then
    return 0
  end
  return self._tActData.score
end
function Logic_SmallRP:GetCurLevelUpNeedScore()
  if not self._tLevelCfg then
    self:InitLevelCfg()
  end
  local nCurLevel = self:GetCurLevel()
  if nCurLevel == self:GetMaxLevel() then
    return 0
  end
  local nCurLevelScore = self:GetLevelScore(nCurLevel)
  local nNextLevelScore = self:GetLevelScore(nCurLevel + 1)
  return nNextLevelScore - nCurLevelScore
end
function Logic_SmallRP:GetShowItemIdByLevel(nLevel)
  local tCurRoundLevelCfg = self:GetCurRoundLevelRewardCfg()
  if tCurRoundLevelCfg and tCurRoundLevelCfg[nLevel] then
    return tCurRoundLevelCfg[nLevel][1].resid
  end
end
function Logic_SmallRP:GetItemDataByLevel(nLevel)
  local tCurRoundLevelCfg = self:GetCurRoundLevelRewardCfg()
  if tCurRoundLevelCfg and tCurRoundLevelCfg[nLevel] then
    return tCurRoundLevelCfg[nLevel]
  end
end
function Logic_SmallRP:GetChooseOneFlagByLevel(nLevel)
  local levelReward = self:GetItemDataByLevel(nLevel)
  if levelReward and levelReward[1] and levelReward[1].select_one then
    return levelReward[1].select_one
  end
end
function Logic_SmallRP:GetShowItemDataByLevel(nLevel)
  local tCurRoundLevelCfg = self:GetCurRoundLevelRewardCfg()
  if tCurRoundLevelCfg and tCurRoundLevelCfg[nLevel] then
    return tCurRoundLevelCfg[nLevel][1]
  end
end
function Logic_SmallRP:GetCurRoundLevelRewardCfg()
  local nCurRoundId = self:GetActRoundId()
  if not nCurRoundId then
    return
  end
  if self._tRoundLevelAwardCfg and self._tRoundLevelAwardCfg[nCurRoundId] then
    return self._tRoundLevelAwardCfg[nCurRoundId]
  else
    local SmallRPHandler = require("client.network.Protocol.SmallRPHandler")
    SmallRPHandler:send_small_rp_level_award_cfg_req()
  end
end
function Logic_SmallRP:GetCurShowBannerLevel(nCurLevel, bIsInit)
  local tAllBanner = self._tAllBannerLevel
  if not tAllBanner then
    return
  end
  local nShowLevel = tAllBanner[#tAllBanner]
  if not bIsInit and not self:GetIsUnlock() then
    return nShowLevel
  end
  nCurLevel = nCurLevel or self:GetCurLevel()
  for _, v in pairs(tAllBanner) do
    if v >= nCurLevel then
      nShowLevel = v
      break
    end
  end
  return nShowLevel
end
function Logic_SmallRP:GetLevelRewardIsGot(nLevel)
  if not self._tActData or not self._tActData.level_award then
    return false
  end
  return self._tActData.level_award[nLevel]
end
function Logic_SmallRP:GetLevelRewardIsAllGot(nLevel)
  local chooseOneFlag = self:GetChooseOneFlagByLevel(nLevel)
  if chooseOneFlag then
    local levelReward = self:GetItemDataByLevel(nLevel)
    for i = 1, #levelReward do
      if not self:GetChooseOneItemHasGot(chooseOneFlag, i) then
        return false
      end
    end
    return true
  else
    return self:GetLevelRewardIsGot(nLevel)
  end
end
function Logic_SmallRP:GetLevelRewardIsGotByItemIndex(nLevel, itemIndex)
  local chooseOneFlag = self:GetChooseOneFlagByLevel(nLevel)
  if chooseOneFlag then
    return self:GetChooseOneItemHasGot(chooseOneFlag, itemIndex)
  else
    return self:GetLevelRewardIsGot(nLevel)
  end
end
function Logic_SmallRP:GetHaveRewardCanReceive()
  if not self._tActData then
    return false
  end
  local nCurLevel = self:GetCurLevel()
  for i = 1, nCurLevel do
    if not self._tActData.level_award[i] then
      return true
    end
  end
  return false
end
function Logic_SmallRP:GetScoreConversionUCValue(nScore)
  local nActRound = self:GetActRoundId()
  if not nActRound then
    return 0
  end
  local tCfg = CDataTable.GetTableData("AssembleActBuyCfg", nActRound) or {}
  if tCfg.ScoreValue then
    return math.ceil(nScore * tCfg.ScoreValue)
  end
  return 0
end
function Logic_SmallRP:GetUnlockNeedUC()
  local nActRound = self:GetActRoundId()
  if not nActRound then
    return 0
  end
  local tCfg = CDataTable.GetTableData("AssembleActBuyCfg", nActRound) or {}
  return tCfg.UnlockCost or 0
end
function Logic_SmallRP:GetCurRoundTaskCfg()
  local nActRound = self:GetActRoundId()
  if not nActRound then
    return {}
  end
  if self._tRoundTaskCfg[nActRound] then
    return self._tRoundTaskCfg[nActRound]
  end
  local tAllTemp = {}
  local tAllTaskCfg = CDataTable.GetTableByFilter("SmallRPTaskCfg", "ActRoundId", nActRound) or {}
  local nIndex = 1
  for _, v in pairs(tAllTaskCfg) do
    tAllTemp[nIndex] = v
    nIndex = nIndex + 1
  end
  self._tRoundTaskCfg[nActRound] = tAllTemp
  return tAllTemp
end
function Logic_SmallRP:GetAllTaskData()
  if not self._tAllTaskData then
    local SmallRPHandler = require("client.network.Protocol.SmallRPHandler")
    SmallRPHandler:send_sync_small_rp_task_data_req()
    return {}
  end
  return self._tAllTaskData
end
function Logic_SmallRP:GetTaskStatusByTaskId(nTaskId)
  local tAllTaskData = self._tAllTaskData
  if tAllTaskData and tAllTaskData[nTaskId] then
    return tAllTaskData[nTaskId].status
  end
  return Enum_Task.Unfinished
end
function Logic_SmallRP:GetTaskDataByTaskId(nTaskId)
  local tAllTaskData = self._tAllTaskData
  if tAllTaskData and tAllTaskData[nTaskId] then
    return tAllTaskData[nTaskId]
  end
end
function Logic_SmallRP:GetHasTaskCompletedStatus()
  local tAllTaskData = self._tAllTaskData
  if not tAllTaskData then
    return false
  end
  for _, v in pairs(tAllTaskData) do
    if v.status == Enum_Task.Completed then
      return true
    end
  end
  return false
end
function Logic_SmallRP:GetFinishTaskPro()
  local tAllTaskData = self._tAllTaskData
  if not tAllTaskData then
    return 0
  end
  local tAllTaskCfg = self:GetCurRoundTaskCfg()
  if not tAllTaskCfg or #tAllTaskCfg <= 0 then
    return 0
  end
  local nCount = 0
  for _, v in pairs(tAllTaskData) do
    if v.status >= Enum_Task.Completed then
      nCount = nCount + 1
    end
  end
  return math.floor(nCount / #tAllTaskCfg * 100)
end
function Logic_SmallRP:GetIsReceivedAllTaskProReward()
  local tAllTaskProReward = self._tAllTaskProReward
  if not tAllTaskProReward then
    return false
  end
  local Enum_TaskProRewardStatus = Logic_SmallRPConst.Enum_TaskProRewardStatus
  for _, v in pairs(tAllTaskProReward) do
    if v.status == Enum_TaskProRewardStatus.NotReceived then
      return false
    end
  end
  return true
end
function Logic_SmallRP:GetCanReceiveTaskProRewardCount(nCurProValue)
  local tAllTaskProReward = self._tAllTaskProReward
  if not tAllTaskProReward then
    return 0, {}
  end
  nCurProValue = nCurProValue or self:GetFinishTaskPro()
  local nCanReceiveCount = 0
  local tAllCanReceiveProValue = {}
  local Enum_TaskProRewardStatus = Logic_SmallRPConst.Enum_TaskProRewardStatus
  for nProValue, v in pairs(tAllTaskProReward) do
    if nProValue <= nCurProValue and v.status == Enum_TaskProRewardStatus.NotReceived then
      nCanReceiveCount = nCanReceiveCount + 1
      table.insert(tAllCanReceiveProValue, nProValue)
    end
  end
  return nCanReceiveCount, tAllCanReceiveProValue
end
function Logic_SmallRP:GetTaskProRewardAwardId()
  local tAllTaskProReward = self._tAllTaskProReward
  if not tAllTaskProReward then
    return
  end
  local _, tRewardData = next(tAllTaskProReward)
  if not tRewardData then
    return
  end
  return tRewardData.award
end
function Logic_SmallRP:GetTaskProRewardMinProValue()
  if self._nTaskProRewardMinProValue then
    return self._nTaskProRewardMinProValue
  end
  local tAllTaskProReward = self._tAllTaskProReward
  if not tAllTaskProReward then
    return 0
  end
  local tAllProValue = {}
  for nProValue, _ in pairs(tAllTaskProReward) do
    table.insert(tAllProValue, nProValue)
  end
  local nCount = #tAllProValue
  local nMinProValue = nCount <= 1 and tAllProValue[1] or 0
  if 1 < nCount then
    nMinProValue = math.min(table.unpack(tAllProValue))
  end
  self._nTaskProRewardMinProValue = nMinProValue
  return nMinProValue
end
function Logic_SmallRP:GetScoreShowItemId()
  local tActCfg = self._tActCfg
  if not tActCfg then
    return _ScoreDefaultItemId
  end
  return tActCfg.score_res_id or _ScoreDefaultItemId
end
function Logic_SmallRP:GetRichTextScoreIcon()
  local nActRound = self:GetActRoundId()
  if not nActRound then
    return
  end
  local uObj_actCfg = CDataTable.GetTableData("AssembleActShowCfg", nActRound) or {}
  return uObj_actCfg.RichTextScoreIcon
end
function Logic_SmallRP:GetCanExchangeScore()
  local nMaxLevelScore = self:GetLevelScore(self:GetMaxLevel())
  local nCurScore = self:GetCurScore()
  local nScore = nCurScore - nMaxLevelScore
  return 0 < nScore and nScore or 0
end
function Logic_SmallRP:GetCurLevelCanReceiveReward()
  local tCanReceive = {}
  local nCurLevel = self:GetCurLevel()
  local tAllReward = self:GetCurRoundLevelRewardCfg()
  if not tAllReward then
    return tCanReceive
  end
  for i = 1, #tAllReward do
    if i > nCurLevel then
      break
    end
    local tLevelReward = tAllReward[i]
    local bIsGot = self:GetLevelRewardIsGot(i)
    if not bIsGot then
      table.insert(tCanReceive, {nLevel = i, tAllReward = tLevelReward})
    end
  end
  return tCanReceive
end
function Logic_SmallRP:GetChooseOneGroupLevelGroup(chooseOneFlag)
  local levelGroups = self:GetChooseOneGroup()
  return levelGroups[chooseOneFlag]
end
function Logic_SmallRP:GetChooseOneGroupLevelData(chooseOneFlag)
  local levelGroup = self:GetChooseOneGroupLevelGroup(chooseOneFlag)
  return levelGroup and levelGroup.levelData
end
function Logic_SmallRP:GetChooseOneGroup()
  local nCurRoundId = self:GetActRoundId()
  if not nCurRoundId then
    return
  end
  local tAllReward = self:GetCurRoundLevelRewardCfg()
  if not tAllReward then
    return
  end
  if self._tRoundLevelGroup[nCurRoundId] then
    return self._tRoundLevelGroup[nCurRoundId]
  end
  local levelRewardGroup = {}
  for i = 1, #tAllReward do
    local tLevelReward = tAllReward[i]
    local nSelectOne = tLevelReward[1].select_one
    if nSelectOne then
      local itemCount = #tLevelReward
      if not levelRewardGroup[nSelectOne] then
        levelRewardGroup[nSelectOne] = {}
        levelRewardGroup[nSelectOne].      end
      if not levelRewardGroup[nSelectOne].levelData then
        levelRewardGroup[nSelectOne].levelData = {}
      end
      table.insert(levelRewardGroup[nSelectOne].levelData, i)
    end
  end
  self._tRoundLevelGroup[nCurRoundId] = levelRewardGroup
  return levelRewardGroup
end
function Logic_SmallRP:GetChooseOneLevelRewardSingleItem(nLevel, showStartLevel, showEndLevel)
  showStartLevel = showStartLevel or 1
  showEndLevel = showEndLevel or self:GetCurLevel()
  local levelReward = self:GetItemDataByLevel(nLevel)
  if not levelReward then
    return
  end
  local chooseOneFlag = levelReward[1].select_one
  local levelGroup = self:GetChooseOneGroupLevelGroup(chooseOneFlag)
  local itemCount = levelGroup.itemCount
  local levelData = levelGroup.levelData
  local showLevelIndex
  local notRewardItemCount = 0
  for i = 1, itemCount do
    if not self:GetChooseOneItemHasGot(chooseOneFlag, i) then
      notRewardItemCount = notRewardItemCount + 1
    end
  end
  local notRewardChooseOneCount = 0
  for i = 1, #levelData do
    local rewardLevel = levelData[i]
    if showEndLevel >= rewardLevel and showStartLevel <= rewardLevel then
      if not self:GetLevelRewardIsGot(rewardLevel) then
        notRewardChooseOneCount = notRewardChooseOneCount + 1
      end
      if nLevel == rewardLevel then
        showLevelIndex = notRewardChooseOneCount
      end
    end
  end
  if notRewardItemCount < showLevelIndex then
    return
  end
  if not showLevelIndex then
    return
  end
  if notRewardItemCount <= notRewardChooseOneCount then
    local itemIndex
    for i = 1, #levelReward do
      if not self:GetChooseOneItemHasGot(chooseOneFlag, i) then
        showLevelIndex = showLevelIndex - 1
      end
      if showLevelIndex == 0 then
        itemIndex = i
        break
      end
    end
    return itemIndex
  end
end
function Logic_SmallRP:GetChooseOneItemHasGot(chooseOneFlag, itemIndex)
  local levelData = self:GetChooseOneGroupLevelData(chooseOneFlag)
  local nLevel = levelData[1]
  local levelReward = self:GetItemDataByLevel(nLevel)
  local itemData = levelReward[itemIndex]
  if itemData then
    local nItemId = itemData.resid
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local bHasItem = wardrobe_data:HasItem(nItemId, true)
    return bHasItem
  end
  return false
end
function Logic_SmallRP:GetTipRewardLevelData()
  local tAllShowLevel = self._tCurShowRewardTipLevel
  if not tAllShowLevel then
    local nActRound = self:GetActRoundId()
    if not nActRound then
      return
    end
    local uObj_actCfg = CDataTable.GetTableData("AssembleActShowCfg", nActRound) or {}
    if not (uObj_actCfg and uObj_actCfg.ShowRewardTipLevel) or uObj_actCfg.ShowRewardTipLevel == "" then
      return
    end
    local StringUtil = require("common.string_util")
    tAllShowLevel = StringUtil.Split(uObj_actCfg.ShowRewardTipLevel, ";")
    table.sort(tAllShowLevel, function(a, b)
      return a < b
    end)
    self._tCurShowRewardTipLevel = tAllShowLevel
  end
  return tAllShowLevel
end
function Logic_SmallRP:GetIsShowUpgradeLevelPanelLine()
  return self._bIsShowUpgradeLevelPanelLine
end
function Logic_SmallRP:SetIsShowUpgradeLevelPanelLine(bIsShow)
  self._bIsShowUpgradeLevelPanelLine = bIsShow
end
function Logic_SmallRP:send_small_rp_player_data_req()
  if self._tActData and self:GetIsOpen() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  if nCurTime - _nLastRequestBaseDateTime <= 2 then
    log(bWriteLog and " Logic_SmallRP:send_small_rp_player_data_req Request interval Time < 2s >>>>>")
    return
  end
  _nLastRequestBaseDateTime = nCurTime
  local SmallRPHandler = require("client.network.Protocol.SmallRPHandler")
  SmallRPHandler.send_small_rp_player_data_req()
end
function Logic_SmallRP:on_small_rp_player_data_rsp(tActData, tActCfg)
  self:ResetRoundData()
  self._  self._  self:ResetCurLevel()
  self:GetCurRoundLevelRewardCfg()
  self:GetAllTaskData()
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
  EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_GOT_ACT_DATA)
end
function Logic_SmallRP:on_small_rp_level_award_cfg_rsp(tAllLevelAward)
  if not tAllLevelAward or not next(tAllLevelAward) then
    return
  end
  local nRoundId = self:GetActRoundId()
  if not nRoundId then
    return
  end
  self._tRoundLevelAwardCfg[nRoundId] = tAllLevelAward
  self:InitBannerShowData(tAllLevelAward)
  local Logic_SmallRPRedMgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRPRedMgr)
  Logic_SmallRPRedMgr:UpdateLevelRewardRed()
  EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_INIT_REWARD_LIST)
end
function Logic_SmallRP:on_small_rp_get_level_award_rsp(nLevel, tAllReward, tDecList, tAdditionAwards)
  if self._tActData and self._tActData.level_award then
    self._tActData.level_award[nLevel] = true
    local relatedLevel = self:GetRelatedRewardLevel(nLevel)
    EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_REFRESH_REWARD_LIST, relatedLevel)
    local Logic_SmallRPRedMgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRPRedMgr)
    Logic_SmallRPRedMgr:UpdateLevelRewardRed()
  end
  self:ShowCommonItemGet(tAllReward, tDecList, tAdditionAwards)
end
function Logic_SmallRP:on_small_rp_batch_get_level_award_rsp(tAllReward, tDecList, tAdditionAwards)
  local tActData = self._tActData
  if tActData and tActData.level_award then
    for i = 1, self:GetCurLevel() do
      tActData.level_award[i] = true
    end
    EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_REFRESH_REWARD_LIST)
    local Logic_SmallRPRedMgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRPRedMgr)
    Logic_SmallRPRedMgr:UpdateLevelRewardRed()
  end
  self:ShowCommonItemGet(tAllReward, tDecList, tAdditionAwards)
end
function Logic_SmallRP:on_small_rp_unlock_rsp()
  if not self._tActData then
    return
  end
  self._tActData.is_unlock = true
  ShowNotice(66018)
  EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_UNLOCK)
  local Logic_SmallRPRedMgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRPRedMgr)
  Logic_SmallRPRedMgr:UpdateLevelRewardRed()
  Logic_SmallRPRedMgr:UpdateTaskRed()
end
function Logic_SmallRP:on_small_rp_score_notify_change(nChangeScore, nCurScore, nReason)
  if not self._tActData then
    return
  end
  local nLastScore = self._tActData.score
  self._tActData.score = nCurScore
  if 0 < nChangeScore then
    local Enum_ScoreReason = Logic_SmallRPConst.Enum_ScoreReason
    local bIsDelayUpLevelShow = false
    if nReason == Enum_ScoreReason.LuckyDraw or nReason == Enum_ScoreReason.TaskAward or nReason == Enum_ScoreReason.BatchTaskReward then
      bIsDelayUpLevelShow = true
    end
    self:ResetCurLevel(true, nLastScore, bIsDelayUpLevelShow)
  else
    EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_SCORE_CHANGE)
  end
end
function Logic_SmallRP:send_small_rp_buy_score_req(nAddScore, nCurScore, fCallback)
  self._fBuyScoreCallback = fCallback
  local SmallRPHandler = require("client.network.Protocol.SmallRPHandler")
  SmallRPHandler.send_small_rp_buy_score_req(nAddScore, nCurScore)
end
function Logic_SmallRP:on_small_rp_buy_score_rsp(nErrCode, nAddScore, nCurScore)
  local fBuyScoreCallback = self._fBuyScoreCallback
  self._fBuyScoreCallback = nil
  if nErrCode == "qrcode_login_limit" then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  if nErrCode ~= 0 then
    ShowNotice(nErrCode)
    return
  end
  if not self._tActData then
    return
  end
  self._tActData.score = nCurScore
  if fBuyScoreCallback and type(fBuyScoreCallback) == "function" then
    fBuyScoreCallback()
  else
    local tAllReward = {
      {
        resid = self:GetScoreShowItemId(),
        count = nAddScore
      }
    }
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(tAllReward)
  end
end
function Logic_SmallRP:on_sync_small_rp_task_data_info(tAllTaskData)
  if not tAllTaskData then
    return
  end
  local nCurRoundId = self:GetActRoundId()
  if nCurRoundId ~= tAllTaskData.act_term_id then
    return
  end
  self._tAllTaskData = tAllTaskData.tasks
  self._tAllTaskProReward = tAllTaskData.stage_awards
  local Logic_SmallRPRedMgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRPRedMgr)
  Logic_SmallRPRedMgr:UpdateTaskRed()
  EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_TASK_UPDATE)
end
function Logic_SmallRP:on_small_rp_get_task_award_rsp(nTaskId, tTaskData, nRewardScore, nDecScore, tDecomposeList)
  local tAllTaskData = self._tAllTaskData
  if not tAllTaskData then
    return
  end
  tAllTaskData[nTaskId] = tTaskData
  local Logic_SmallRPRedMgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRPRedMgr)
  Logic_SmallRPRedMgr:UpdateTaskRed()
  EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_TASK_UPDATE)
  self:TaskReceiveShowCommonItemGet(nRewardScore, nDecScore, tDecomposeList)
end
function Logic_SmallRP:on_small_rp_batch_get_task_award_rsp(nRewardScore, nDecScore, tDecomposeList)
  self:TaskReceiveShowCommonItemGet(nRewardScore, nDecScore, tDecomposeList)
end
function Logic_SmallRP:on_small_rp_batch_get_stage_award_rsp(tAllReward)
  local tAllTaskProReward = self._tAllTaskProReward
  local tAllGetData = {}
  local Enum_TaskProRewardStatus = Logic_SmallRPConst.Enum_TaskProRewardStatus
  for nProValue, tProAllReward in pairs(tAllReward) do
    if tAllTaskProReward[nProValue] then
      tAllTaskProReward[nProValue].status = Enum_TaskProRewardStatus.Received
    end
    for _, tReward in pairs(tProAllReward) do
      table.insert(tAllGetData, tReward)
    end
  end
  EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_UPDATE_TASK_PRO_REWARD)
  if not next(tAllGetData) then
    return
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(tAllGetData)
end
function Logic_SmallRP:InitLevelCfg()
  local tLevelCfg = {}
  local nCurRound = self:GetActRoundId()
  if not nCurRound then
    return
  end
  local tAllLevel = CDataTable.GetTableByFilter("AssembleActLevel", "ActRound", nCurRound)
  for _, v in pairs(tAllLevel) do
    tLevelCfg[v.Level] = v.Score
  end
  self._end
function Logic_SmallRP:InitBannerShowData(tAllLevelAward)
  local tBannerShow = {}
  local nIndex = 1
  for k, v in ipairs(tAllLevelAward) do
    if v[1] and v[1].spec_show == 1 then
      tBannerShow[nIndex] = k
      nIndex = nIndex + 1
    end
  end
  table.sort(tBannerShow, function(a, b)
    return a < b
  end)
  self._tAllBannerLevel = tBannerShow
end
function Logic_SmallRP:ResetCurLevel(bIsCheckLevelUp, nLastScore, bIsDelayUpLevelShow)
  local nCurLevel = self._nCurLevel
  local nMaxIndex = self:GetMaxLevel()
  if nCurLevel == nMaxIndex then
    EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_SCORE_CHANGE)
    return
  end
  local tLevelCfg = self._tLevelCfg
  if not tLevelCfg then
    return
  end
  local nCurScore = self:GetCurScore()
  local nLastLevel = nCurLevel
  for i = nCurLevel + 1, nMaxIndex do
    if nCurScore >= tLevelCfg[i] then
      nCurLevel = i
    else
      break
    end
  end
  self._  if bIsCheckLevelUp then
    self:ShowLevelScoreProBarTip(nLastLevel, nCurLevel, nLastScore, nCurScore)
    if nLastLevel ~= nCurLevel then
      local Logic_SmallRPRedMgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRPRedMgr)
      Logic_SmallRPRedMgr:UpdateLevelRewardRed()
      self._bIsNeedUpgradeAnim = true
      if not self._nUpgradeLastLevel then
        self._nUpgradeLastLevel = nLastLevel
      end
      self:ShowLevelUpUI(bIsDelayUpLevelShow)
      EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_LEVEL_CHANGE)
    end
  end
  EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_SCORE_CHANGE)
end
function Logic_SmallRP:ShowLevelScoreProBarTip(nLastLevel, nCurLevel, nLastScore, nCurScore)
  local uObj_actCfg = self:GetActShowCfg()
  if not uObj_actCfg then
    return
  end
  local sBasePath = uObj_actCfg.TemplateBasePath
  local sActIcon = sBasePath .. "NoAtlas/Image_LevelIcon.Image_LevelIcon"
  local tShowData = {
    sActIcon = sActIcon,
    nOldLevel = nLastLevel,
    nNewLevel = nCurLevel,
    nOldExp = nLastScore,
    nNewExp = nCurScore,
    nLevelKey = 8904007,
    fGetExpByLevel = function(nLevel)
      local nMinScore = self:GetLevelScore(nLevel)
      local nMaxScore = self:GetLevelScore(nLevel + 1)
      return nMinScore, nMaxScore
    end
  }
  if UIManager.IsUIShow(UIManager.UI_Config.NewSupplySystem) or UIManager.IsUIShow(UIManager.UI_Config.NewSupplySystemJK) then
    table.insert(self._tScoreProBarQueue, tShowData)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Common_ProBarTip_UIBP, tShowData)
end
function Logic_SmallRP:CheckShowScoreProBarTip()
  if #self._tScoreProBarQueue <= 0 then
    return
  end
  for _, v in ipairs(self._tScoreProBarQueue) do
    UIManager.ShowUI(UIManager.UI_Config.Common_ProBarTip_UIBP, v)
  end
  self._tScoreProBarQueue = {}
end
function Logic_SmallRP:ShowLevelUpUI(bIsDelayUpLevelShow)
  if not self:GetIsOpen() then
    self._bIsNeedUpgradeAnim = false
    self._nUpgradeLastLevel = nil
    return
  end
  if bIsDelayUpLevelShow or not self._bIsNeedUpgradeAnim then
    return
  end
  local nCurLevel = self._nCurLevel
  local fCloseCallback = self:CheckShowUnlockRewardPop()
  UIManager.ShowUI(UIManager.UI_Config.SmallRP_LevelUp_UIBP, nCurLevel, fCloseCallback)
  self._bIsNeedUpgradeAnim = false
end
function Logic_SmallRP:UnlockActBuy(nSourceType, bIsCardUnlock)
  if not bIsCardUnlock and Logic_QRCodeRestrictUtils.IsUcUseLimit() then
    return
  end
  local nUCCount = DataMgr.ticket
  local nNeedCount = self:GetUnlockNeedUC()
  if not bIsCardUnlock and nUCCount < nNeedCount then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(nNeedCount)
    return
  end
  local sTitle = LocUtil.GetLocalizeResStr(5077)
  local sContent = LocUtil.LocalizeResFormat(66017, nNeedCount)
  if bIsCardUnlock then
    sContent = LocUtil.GetLocalizeResStr(73559)
  end
  local sOKStr = LocUtil.GetLocalizeResStr(6752)
  local sCancelStr = LocUtil.GetLocalizeResStr(7510)
  local msgData = {
    styleType = 2,
    title = sTitle,
    msg = sContent,
    clickOkCallback = function()
      local SmallRPHandler = require("client.network.Protocol.SmallRPHandler")
      SmallRPHandler.send_small_rp_unlock_req(nSourceType, bIsCardUnlock, false)
    end,
    btnOK = sOKStr,
    btnCancel = sCancelStr
  }
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.ShowUSPolicyTip(msgData)
end
function Logic_SmallRP:ShowAlreadyHasGiftConfirm(nSourceType)
  local sTitle = LocUtil.GetLocalizeResStr(5077)
  local sContent = LocUtil.GetLocalizeResStr(88308)
  local sOKStr = LocUtil.GetLocalizeResStr(6752)
  local sCancelStr = LocUtil.GetLocalizeResStr(7510)
  local msgData = {
    styleType = 2,
    title = sTitle,
    msg = sContent,
    clickOkCallback = function()
      local SmallRPHandler = require("client.network.Protocol.SmallRPHandler")
      SmallRPHandler.send_small_rp_unlock_req(nSourceType, false, true)
    end,
    btnOK = sOKStr,
    btnCancel = sCancelStr
  }
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.ShowUSPolicyTip(msgData)
end
function Logic_SmallRP:GetCostIcon(nCostItemId)
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  if nCostItemId == CoinMacro.SmallRPScore then
    nCostItemId = self:GetScoreShowItemId()
  end
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetItemBigIcon(nCostItemId)
end
function Logic_SmallRP:ShowMultiChooseOneUI(tAllItem, fCallback, tSelectedItem)
  local tAllItemId = {}
  local tValidItem = {}
  for _, v in ipairs(tAllItem) do
    table.insert(tAllItemId, v.resid)
    if v.valid_hours and v.valid_hours ~= 0 then
      tValidItem[v.resid] = true
    end
  end
  local nItemCount = #tAllItemId
  local tShowData = {
    tAllItemId = tAllItemId,
    nShowGroupId = tAllItem[1].select_one,
    fSelectedCallback = fCallback,
    bIsShowGotTip = true,
    tValidItem = tValidItem,
      }
  local Logic_MultiChooseOne = require("client.slua.logic.common.Logic_MultiChooseOne")
  Logic_MultiChooseOne.ShowUI(nItemCount, tShowData)
end
function Logic_SmallRP:GetAllRewardMultiChooseOne()
  local tAllSelect = {}
  local multiChoose1Array = {}
  local tCanReceive = self:GetCurLevelCanReceiveReward()
  for _, tLevelReward in ipairs(tCanReceive) do
    local nSelectOne = tLevelReward.tAllReward[1].select_one
    if nSelectOne then
      local singleItemIndex = self:GetChooseOneLevelRewardSingleItem(tLevelReward.nLevel)
      if singleItemIndex then
        tAllSelect[tLevelReward.nLevel] = singleItemIndex
      else
        table.insert(multiChoose1Array, tLevelReward.nLevel)
      end
    end
  end
  if #multiChoose1Array == 0 then
    local SmallRPHandler = require("client.network.Protocol.SmallRPHandler")
    SmallRPHandler.send_small_rp_batch_get_level_award_req(tAllSelect)
  else
    local tSelectedItem = {}
    self:_ShowMultiChooseOne(multiChoose1Array, tAllSelect, tSelectedItem)
  end
end
function Logic_SmallRP:_ShowMultiChooseOne(multiChoose1Array, tAllSelect, tSelectedItem)
  if multiChoose1Array[1] == nil then
    local SmallRPHandler = require("client.network.Protocol.SmallRPHandler")
    SmallRPHandler.send_small_rp_batch_get_level_award_req(tAllSelect)
    return
  end
  local level = multiChoose1Array[1]
  table.remove(multiChoose1Array, 1)
  local tLevelReward = self:GetItemDataByLevel(level)
  self:ShowMultiChooseOneUI(tLevelReward, function(nSelectIndex, nSelectItemId)
    tAllSelect[level] = nSelectIndex
    if tSelectedItem and nSelectItemId then
      tSelectedItem[nSelectItemId] = true
    end
    self:AddTimerOnce(0, function()
      self:_ShowMultiChooseOne(multiChoose1Array, tAllSelect, tSelectedItem)
    end)
  end, tSelectedItem)
end
function Logic_SmallRP:GetOnlyOneItemIndex(nLevel)
  local levelReward = self:GetItemDataByLevel(nLevel)
  if not levelReward then
    return
  end
  local chooseOneFlag = levelReward[1].select_one
  if chooseOneFlag then
    local itemIndex
    local itemCount = 0
    for i = 1, #levelReward do
      if not self:GetChooseOneItemHasGot(chooseOneFlag, i) then
        itemIndex = i
        itemCount = itemCount + 1
      end
    end
    if itemCount == 1 then
      return itemIndex
    end
  end
end
function Logic_SmallRP:GetRelatedRewardLevel(nLevel)
  local tLevelReward = self:GetItemDataByLevel(nLevel)
  if not tLevelReward then
    return
  end
  local nSelectOne = tLevelReward[1].select_one
  if nSelectOne then
    local levelData = self:GetChooseOneGroupLevelData(nSelectOne)
    return levelData
  end
  return {nLevel}
end
function Logic_SmallRP:CheckShowUnlockRewardPop()
  local bIsUnlock = self:GetIsUnlock()
  if bIsUnlock then
    return
  end
  local nLastLevel = self._nUpgradeLastLevel or 1
  self._nUpgradeLastLevel = nil
  local nCurLevel = self._nCurLevel
  local tAllTipRewardLevel = self:GetTipRewardLevelData()
  if not tAllTipRewardLevel then
    return
  end
  for _, v in ipairs(tAllTipRewardLevel) do
    local nLevel = tonumber(v)
    if nLastLevel < nLevel and nCurLevel >= nLevel then
      return function()
        local bIsTaskUIShow = UIManager.IsUIShow(UIManager.UI_Config.SmallRP_Task_UIBP)
        UIManager.ShowUI(UIManager.UI_Config.SpecialOffer_SmallRP_Push_Popup_UIBP, bIsTaskUIShow)
      end
    end
  end
end
function Logic_SmallRP:GMSetShowRoundId(nRoundId)
  self._sGMSetShowRoundId = nRoundId
end
function Logic_SmallRP:ShowCommonItemGet(tAllReward, tDecList, tAdditionAwards)
  local bIsExtraGet = false
  local bIsShowExtraGetTip = false
  local nAddScore = 0
  if tAdditionAwards and next(tAdditionAwards) then
    nAddScore = tAdditionAwards.count
    bIsExtraGet = true
    bIsShowExtraGetTip = true
  end
  local nIPScoreItemId = self:GetIPScoreId()
  local Logic_SmallRPUtils = require("client.slua.logic.specialoffer.SmallRP.Logic_SmallRPUtils")
  local Logic_ItemUtils = require("client.slua.logic.common.Logic_ItemUtils")
  local nCurScore = Logic_ItemUtils.GetItemCount(nIPScoreItemId) or 0
  local nMaxScore = Logic_SmallRPUtils.GetIPLineMaxProgressScore() or 0
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if nMaxScore > nCurScore - nAddScore and bIsExtraGet then
    local tExtraData = {}
    tAdditionAwards.nItemGetGroupId = 2
    table.insert(tAllReward, tAdditionAwards)
    tExtraData.tAllGroupTitle = {
      [1] = LocUtil.GetLocalizeResStr(4328),
      [2] = LocUtil.GetLocalizeResStr(76907)
    }
    Logic_CommonItemGet.ShowPanel_RewardGroupShow(tAllReward, tDecList, tExtraData)
    bIsShowExtraGetTip = false
  else
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(tAllReward, tDecList)
  end
  if bIsShowExtraGetTip then
    ShowNotice(76904)
  end
  if tDecList and next(tDecList) then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    for k, v in pairs(tDecList) do
      local uObj_itemCfg = CDataTable.GetTableData("Item", tAllReward[k].resid)
      local uObj_toItemCfg = CDataTable.GetTableData("Item", v.resid)
      if uObj_itemCfg and uObj_toItemCfg then
        local sTipContent = LocUtil.LocalizeResFormat(6345, uObj_itemCfg.ItemName or "", v.count, uObj_toItemCfg.ItemName or "")
        ShowNotice(sTipContent)
      end
    end
  end
end
function Logic_SmallRP:TaskReceiveShowCommonItemGet(nRewardScore, nDecScore, tDecomposeList)
  local nScoreId = self:GetScoreShowItemId()
  if 0 < nDecScore and tDecomposeList and next(tDecomposeList) then
    ShowNotice(self:ReplaceTextScoreIcon(LocUtil.LocalizeResFormat(74028)))
    local tAllReward = {}
    table.insert(tAllReward, {res_id = nScoreId, count = nDecScore})
    if 0 < nRewardScore then
      table.insert(tAllReward, 1, {res_id = nScoreId, count = nRewardScore})
      local tDecItem = tDecomposeList[1]
      tDecomposeList[1] = nil
      tDecomposeList[2] = tDecItem
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(tAllReward, tDecomposeList)
  else
    local tAllReward = {
      {res_id = nScoreId, count = nRewardScore}
    }
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(tAllReward)
  end
end
function Logic_SmallRP:ReplaceTextScoreIcon(sShowStr)
  local sRichIcon = self:GetRichTextScoreIcon()
  if not sRichIcon or sRichIcon == "" then
    return sShowStr
  end
  local StringUtil = require("common.string_util")
  sShowStr = StringUtil.StrReplace(sShowStr, "img src=\"MinippImage\"", "img src=\"" .. sRichIcon .. "\"")
  return sShowStr
end
function Logic_SmallRP:JumpToRelatedModule(num)
  local url, hasNoData = self:GetConcernEntranceUrl(num)
  if hasNoData then
    ShowNotice(108101)
    return
  end
  GlobalData.JumpUrl(url)
end
function Logic_SmallRP:GetLuckDrawGuideData(nCurActId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tSmallRPLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSmallRP) or {}
  local nLuckDrawGuideActId
  local index = self:GetConnectedLuckIndex(nCurActId)
  if index then
    if index == 1 then
      nLuckDrawGuideActId = tSmallRPLocalCache.nLuckDrawGuideActId
    else
      nLuckDrawGuideActId = tSmallRPLocalCache["nLuckDrawGuideActId" .. tostring(index)]
    end
  end
  return nLuckDrawGuideActId
end
function Logic_SmallRP:SetLuckDrawGuideData(nCurActId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tSmallRPLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSmallRP) or {}
  local index = self:GetConnectedLuckIndex(nCurActId)
  if index then
    if index == 1 then
      tSmallRPLocalCache.nLuckDrawGuideActId = nCurActId
    else
      tSmallRPLocalCache["nLuckDrawGuideActId" .. tostring(index)] = nCurActId
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(tSmallRPLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eSmallRP)
end
function Logic_SmallRP:GetDoubleDrawGuideData(nCurActId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tSmallRPLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSmallRP) or {}
  local nDoubleDrawGuideActId
  local index = self:GetConnectedDontPutBackIndex(nCurActId)
  if index then
    if index == 1 then
      nDoubleDrawGuideActId = tSmallRPLocalCache.nDoubleDrawGuideActId
    else
      nDoubleDrawGuideActId = tSmallRPLocalCache["nDoubleDrawGuideActId" .. tostring(index)]
    end
  end
  return nDoubleDrawGuideActId
end
function Logic_SmallRP:SetDoubleDrawGuideData(nCurActId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tSmallRPLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSmallRP) or {}
  local index = self:GetConnectedDontPutBackIndex(nCurActId)
  if index then
    if index == 1 then
      tSmallRPLocalCache.nDoubleDrawGuideActId = nCurActId
    else
      tSmallRPLocalCache["nDoubleDrawGuideActId" .. tostring(index)] = nCurActId
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(tSmallRPLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eSmallRP)
end
function Logic_SmallRP:GetConcernEntranceUrl(num)
  local entranceType = self:GetConcernEntranceType(num)
  local url, hasNoActivityData
  if entranceType ~= Logic_SmallRPConst.Enum_EntranceType.Invalid then
    local id = self:GetConcernEntranceID(num)
    if not id then
      log_error("Logic_SmallRP:GetConcernEntranceUrl id is nil, num=" .. tostring(num))
      return
    end
    if entranceType == Logic_SmallRPConst.Enum_EntranceType.SportBox then
      local templateUrl = Logic_SmallRPConst.EntranceUrlTemplate[entranceType]
      if not templateUrl then
        log_error("Logic_SmallRP:GetConcernEntranceUrl templateUrl is nil, num=" .. tostring(num))
        return
      end
      url = string.format(templateUrl, id)
    else
      local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
      local data = ActivityNewSystem.GetActivityByID(id)
      if data then
        url = data.ImgLink
      end
      hasNoActivityData = data == nil
    end
  end
  log(bWriteLog and "Logic_SmallRP:GetConcernEntranceUrl url=" .. tostring(url))
  return url, hasNoActivityData
end
function Logic_SmallRP:GetConcernCfg(num)
  if not self:CheckConfigValid() then
    return
  end
  return self._tActCfg.concerned_cfg[num] or {}
end
function Logic_SmallRP:GetConcernEntranceID(num)
  local cfg = self:GetConcernCfg(num)
  return cfg and cfg.id
end
function Logic_SmallRP:GetConcernEntranceType(num)
  local cfg = self:GetConcernCfg(num)
  return cfg and cfg.type or 0
end
function Logic_SmallRP:GetEntranceImagePath(num)
  local iconName = Logic_SmallRPConst.EntranceImageName[num]
  if not iconName then
    return Logic_SmallRPConst.DefaultEntranceImagePath
  end
  local uObj_actCfg = self:GetActShowCfg()
  local sBasePath = uObj_actCfg.TemplateBasePath
  local imagePath = sBasePath .. "NoAtlas/" .. iconName
  local pak_util = require("client.common.pak_util")
  if not pak_util.IsFileExist(imagePath) then
    imagePath = Logic_SmallRPConst.DefaultEntranceImagePath
  end
  log(bWriteLog and "Logic_SmallRP:GetConcernEntranceUrl imagePath=" .. tostring(imagePath))
  return imagePath
end
function Logic_SmallRP:GetEntranceTittleID(num)
  local entranceType = self:GetConcernEntranceType(num)
  local entranceTittleID = Logic_SmallRPConst.EntranceTittleID[entranceType]
  if not entranceTittleID then
    log_error("Logic_SmallRP:GetEntranceTittleID entranceTittleID is nil, type=" .. tostring(entranceType))
    return
  end
  log(bWriteLog and "Logic_SmallRP:GetConcernEntranceUrl entranceTittleID=" .. tostring(entranceTittleID))
  return entranceTittleID
end
function Logic_SmallRP:IsConnectedRPByID(id)
  log(bWriteLog and "Logic_SmallRP:IsConnectedRPByID id=" .. tostring(id))
  if not self:CheckConfigValid() then
    return
  end
  for index, concerned_cfg in pairs(self._tActCfg.concerned_cfg) do
    if concerned_cfg.id == id then
      return true
    end
  end
  return false
end
function Logic_SmallRP:CheckConfigValid()
  local tActCfg = self._tActCfg
  if not tActCfg then
    log_error("Logic_SmallRP:CheckConfigValid tActCfg is nil")
    return
  end
  if not self._tActCfg.concerned_cfg then
    log_error("Logic_SmallRP:CheckConfigValid concerned_cfg is nil")
    return
  end
  return true
end
function Logic_SmallRP:GetConnectedLuckIndex(actID)
  if not self:CheckConfigValid() then
    return
  end
  for index, concerned_cfg in pairs(self._tActCfg.concerned_cfg) do
    if concerned_cfg.type == Logic_SmallRPConst.Enum_EntranceType.LuckyDraw and concerned_cfg.id == actID then
      return index
    end
  end
end
function Logic_SmallRP:GetConnectedDontPutBackIndex(actID)
  if not self:CheckConfigValid() then
    return
  end
  for index, concerned_cfg in pairs(self._tActCfg.concerned_cfg) do
    if concerned_cfg.type == Logic_SmallRPConst.Enum_EntranceType.DontPutBack and concerned_cfg.id == actID then
      return index
    end
  end
end
function Logic_SmallRP:IsEntranceConnectedRPScore(num)
  local entranceType = self:GetConcernEntranceType(num)
  local bNotRelatedRPScore = Logic_SmallRPConst.NotRelatedRPScoreTypeMap[entranceType]
  return entranceType ~= 0 and not bNotRelatedRPScore
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_SmallRP = class(CModuleBase, nil, Logic_SmallRP)
return CLogic_SmallRP