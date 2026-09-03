local UnknowPassAwardSystem = {
  AwardLevelList = nil,
  PreviewUnlockLevel = 0,
  titleList = nil,
  tailList = nil,
  bIsFirstOpenAward = true,
  bIsFirstOpenBonus = true,
  nInitAwardSeasonId = 0,
  nPostTimerId = nil,
  tSeasonLevelImage = {},
  tAllPreviewLevel = {},
  ENUM_UNKNOWPASS_NoAward = 0,
  ENUM_UNKNOWPASS_CanGet = 1,
  ENUM_UNKNOWPASS_Lock = 2,
  ENUM_UNKNOWPASS_HasGet = 3,
  ENUM_UNKNOWPASS_NeedBuy = 4,
  PASS_SEGMENT_COUNT = 50,
  rewardCfgTableMap = {},
  elitePlusRewardCfgTableMap = {},
  weekTaskRewardCfgTableMap = {},
  CoreAwardList = {},
  isNeedInitAwards = true,
  isNeedSelectPreview = false,
  isNeedSelectBranchPre = false,
  UnknowPassShowOrdinaryAward_EliteItem_List = {},
  FirstBuyEliteAwardList = {},
  reward_num = nil
}
function UnknowPassAwardSystem.OpenAwardUI(isFirst)
  UnknowPassAwardSystem.isNeedInitAwards = true
  UnknowPassAwardSystem.isNeedSelectPreview = false
  UnknowPassAwardSystem.isNeedSelectBranchPre = false
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local ver = UnknowPassUtil.GetVersionNumber()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local panelType = PassDataSystem.GetPanelType()
  local curType = PassDataSystem.GetCurRpPanelType()
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  local bIsJumpBack = UnknowPassTunnelSystem.jumpInfo and UnknowPassTunnelSystem.jumpInfo.panelType == panelType.BranchRp
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  if curType == panelType.BranchRp or UnknowPassOpenUISystem.GetIsOpenBonusPassAward() or bIsJumpBack then
    if UIManager.GetUI(UIManager.UI_Config.UnknowPass_Award_Branch_BP) then
      if UIManager.IsUIShow(UIManager.UI_Config.UnknowPass_Award_Branch_BP) then
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_REWARD_INTERNAL_JUMP)
      else
        UIManager.CloseUI(UIManager.UI_Config.UnknowPass_BranchRP_RewardsPreview_UIBP)
        UnknowPassAwardSystem.SwitchToBranchAwardPanel()
      end
    else
      local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
      UnknowPassTunnelSystem.UpdateCameraAndBg(true, true)
      PassDataSystem.SetCurPanelType(panelType.BranchRp)
      local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
      Logic_BonusPass:InitBonusPassConfig()
      local seasonInfo = Logic_BonusPass:GetBranchSeasonData()
      if seasonInfo and seasonInfo.seasonID == UnknowPassSystem.Season then
        local bpPath = string.format("/Game/Arts_UI/UnknowPass/%s/UIBP_Main/UnknowPass_Award_Branch_BP.UnknowPass_Award_Branch_BP", ver)
        UIManager.ShowUIWithBpPath(UIManager.UI_Config.UnknowPass_Award_Branch_BP, bpPath)
      end
      UnknowPassAwardSystem.bIsFirstOpenBonus = false
    end
  else
    UIManager.ShowUIWithBpPath(UIManager.UI_Config.unknowpass_award, string.format("/Game/Arts_UI/UnknowPass/%s/UIBP_Main/UnknowPass_Award_New_BP.UnknowPass_Award_New_BP", ver))
    UnknowPassAwardSystem.OpenCouponThrowNotifyPopup()
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local newGuideData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBonusPassNewReddot) or {}
  newGuideData[UnknowPassSystem.Season] = true
  PlayerPrefsSystem.SaveTableToFile_N(newGuideData, PlayerPrefsSystem.ePlayerPrefsType.eBonusPassNewReddot)
  if not isFirst then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE)
    local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
    passReddotMainSystem.InfoUpdate()
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_UPDATE_TAB)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_SHOW_AVATAR)
end
function UnknowPassAwardSystem.OpenCouponThrowNotifyPopup()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if not PassDataSystem.IsUseNewCouponUIShow() then
    return
  end
  if UnknowPassSystem.Season < 50 or UnknowPassSystem.IsBuyElite then
    return false
  end
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  local isShowAnimation = UnknowPassTunnelSystem.CheckShowNewSeasonVideo()
  if isShowAnimation then
    return false
  end
  if not DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassSystem.Season * 10) then
    return false
  end
  local nCouponIdList = PassDataSystem.GetHallDepotUnknowPassNewCoupon()
  local tPercentCoupon = PassDataSystem.GetPercentCouponInfo()
  local bHasPercentCoupon = false
  if nCouponIdList and 0 < #nCouponIdList then
    for _, itemId in pairs(nCouponIdList) do
      if itemId == tPercentCoupon.itemId then
        bHasPercentCoupon = true
        break
      end
    end
    local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
    local ver = UnknowPassUtil.GetVersionNumber()
    if bHasPercentCoupon then
      UIManager.ShowUIWithBpPath(UIManager.UI_Config.UnknowPass_Discount_Percentage_UIBP, string.format("/Game/Arts_UI/UnknowPass/%s/RP_Discount/UnknowPass_Discount_Percentage_UIBP.UnknowPass_Discount_Percentage_UIBP", ver))
    else
      UIManager.ShowUIWithBpPath(UIManager.UI_Config.UnknowPass_Discount_Fixed_UIBP, string.format("/Game/Arts_UI/UnknowPass/%s/RP_Discount/UnknowPass_Discount_Fixed_UIBP.UnknowPass_Discount_Fixed_UIBP", ver))
    end
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassSystem.Season * 10)
  end
end
function UnknowPassAwardSystem.CloseAwardUI()
  UIManager.CloseUI(UIManager.UI_Config.unknowpass_award)
  UIManager.CloseUI(UIManager.UI_Config.UnknowPass_Award_Branch_BP)
end
function UnknowPassAwardSystem.GetRewardCfgTable(cfgType)
  local rewardCfgTable = UnknowPassAwardSystem.rewardCfgTableMap[cfgType]
  if rewardCfgTable == nil then
    UnknowPassAwardSystem.rewardCfgTableMap[cfgType] = {}
    rewardCfgTable = UnknowPassAwardSystem.rewardCfgTableMap[cfgType]
  end
  local resData = UnknowPassSystem.Data
  if resData == nil or resData.base == nil then
    return nil
  end
  local curSeason = resData.base.cur_season
  local cfgTable = rewardCfgTable[curSeason]
  if cfgTable then
    return cfgTable
  end
  cfgTable = {}
  local tableName = cfgType == 0 and "UPassOrdinaryRewardCfg" or "UPassEliteRewardCfg"
  local tb = CDataTable.GetTableByFilter(tableName, "season_index", curSeason) or {}
  for _, v in pairs(tb) do
    cfgTable[v.level] = v
  end
  rewardCfgTable[curSeason] = cfgTable
  return cfgTable
end
function UnknowPassAwardSystem.GetElitePlusRewardCfgTable()
  local rewardCfgTable = UnknowPassAwardSystem.elitePlusRewardCfgTableMap
  local resData = UnknowPassSystem.Data
  if resData == nil or resData.base == nil then
    return {}
  end
  local curSeason = resData.base.cur_season
  local cfgTable = rewardCfgTable[curSeason]
  if cfgTable then
    return cfgTable
  end
  cfgTable = {}
  local tb = CDataTable.GetTableByFilter("UPassElitePlusRewardCfg", "season_index", curSeason) or {}
  for _, v in pairs(tb) do
    cfgTable[v.level] = v
  end
  rewardCfgTable[curSeason] = cfgTable
  return cfgTable
end
function UnknowPassAwardSystem.GetLevelAwardGroupCfg(groupId)
  if not groupId then
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    local tTempCfg = CDataTable.GetTableData("UPassLevelAwardGroupForKRCfg", groupId)
    if tTempCfg then
      return tTempCfg
    end
  end
  local tAwardCfg = CDataTable.GetTableData("UPassLevelAwardGroupCfg", groupId)
  return tAwardCfg
end
function UnknowPassAwardSystem.GetWeekTaskRewardCfgTable()
  local rewardCfgTable = UnknowPassAwardSystem.weekTaskRewardCfgTable
  if rewardCfgTable == nil then
    UnknowPassAwardSystem.weekTaskRewardCfgTable = {}
    rewardCfgTable = UnknowPassAwardSystem.weekTaskRewardCfgTable
  end
  local resData = UnknowPassSystem.Data
  if resData == nil then
    return nil
  end
  local curSeason = resData.base.cur_season
  local cfgTable = rewardCfgTable[curSeason]
  if cfgTable then
    return cfgTable
  end
  cfgTable = {}
  local tb = {}
  for k, v in pairs(tb) do
    if v.season_index == curSeason then
      cfgTable[v.week_index] = v
    end
  end
  rewardCfgTable[curSeason] = cfgTable
  return cfgTable
end
function UnknowPassAwardSystem.LevelToIndex(level)
  if not level or level <= 0 then
    return
  end
  local index = level // 51 + 1
  local subIndex = level - 50 * (index - 1)
  return index, subIndex
end
function UnknowPassAwardSystem.IndexToLevel(index, subIndex)
  if not index or index <= 0 then
    return
  end
  if not subIndex or subIndex <= 0 then
    return
  end
  return subIndex + (index - 1) * 50
end
function UnknowPassAwardSystem.GetSegmentAwardList()
  local AwardLevelList = UnknowPassAwardSystem.GetAwardLevelList(false)
  if not AwardLevelList then
    return {}
  end
  local SegmentAwardList = {}
  for level, award in ipairs(AwardLevelList) do
    local index, subIndex = UnknowPassAwardSystem.LevelToIndex(level)
    if index and subIndex then
      if not SegmentAwardList[index] then
        SegmentAwardList[index] = {}
      end
      SegmentAwardList[index][subIndex] = award
    end
  end
  return SegmentAwardList
end
function UnknowPassAwardSystem.GetAwardLevelList(bForceParse, isExperience, isSub)
  log(bWriteLog and "UnknowPassAwardSystem.GetAwardLevelList " .. tostring(isSub))
  if not bForceParse and UnknowPassAwardSystem.AwardLevelList then
    return UnknowPassAwardSystem.AwardLevelList
  end
  local resData = UnknowPassSystem.Data
  if resData == nil then
    return nil
  end
  local tNormalRewardCfg = UnknowPassAwardSystem.GetRewardCfgTable(0)
  local tPlusRewardCfg = UnknowPassAwardSystem.GetRewardCfgTable(1)
  local tElitePlusRewardCfg = UnknowPassAwardSystem.GetElitePlusRewardCfgTable()
  if not (tNormalRewardCfg and next(tNormalRewardCfg) and tPlusRewardCfg) or not next(tPlusRewardCfg) then
    return nil
  end
  local tAllPreviewLevel = {}
  UnknowPassAwardSystem.titleList = {}
  UnknowPassAwardSystem.tailList = {}
  UnknowPassAwardSystem.FirstBuyEliteAwardList = {}
  local nMaxLevel = resData.upass_max_level
  local nCurLevel = UnknowPassSystem.Level
  local tAllLevelReward = {}
  for i = 1, nMaxLevel do
    local tLevelReward = {level = i}
    tLevelReward.isUnlock = nCurLevel >= tLevelReward.level
    local tCurLevelNorCfg = tNormalRewardCfg[tLevelReward.level]
    local tCurLevelPlusCfg = tPlusRewardCfg[tLevelReward.level]
    local tCurLevelElitePlusCfg = tElitePlusRewardCfg[tLevelReward.level]
    UnknowPassAwardSystem.UpdateCurLevelRewardStatus(tLevelReward, resData, isExperience)
    tLevelReward.OrdinaryAwardList = {}
    UnknowPassAwardSystem.InitNormalRewardList(tLevelReward, tCurLevelNorCfg)
    tLevelReward.EliteAwardList = {}
    UnknowPassAwardSystem.InitPlusRewardList(tLevelReward, tCurLevelPlusCfg, false, isExperience, isSub)
    if tCurLevelElitePlusCfg and tCurLevelPlusCfg.item_id_new_user == 0 then
      if 1 < #tLevelReward.EliteAwardList then
        log(bWriteLog and string.format("UnknowPassAwardSystem.GetAwardLevelList #tLevelReward.EliteAwardList > 1 "))
        tLevelReward.EliteAwardList = {
          tLevelReward.EliteAwardList[1]
        }
      end
      UnknowPassAwardSystem.InitPlusRewardList(tLevelReward, tCurLevelElitePlusCfg, true)
    end
    if tCurLevelPlusCfg then
      local bIsPreview = tCurLevelPlusCfg.spec_show == 1
      if bIsPreview then
        local nCount = #tAllPreviewLevel
        tAllPreviewLevel[nCount + 1] = tLevelReward
      end
      tLevelReward.isPreview = bIsPreview
      if isExperience then
        tLevelReward.isSplitGroup = false
      else
        tLevelReward.isSplitGroup = 0 < tCurLevelPlusCfg.item_id_2
      end
      tLevelReward.isBuyTo = tCurLevelPlusCfg.show_buy == 1
    else
      tLevelReward.isPreview = false
      tLevelReward.isSplitGroup = false
      tLevelReward.isBuyTo = false
    end
    if i == 1 then
      table.insert(UnknowPassAwardSystem.titleList, tLevelReward)
    else
      table.insert(UnknowPassAwardSystem.tailList, tLevelReward)
    end
    table.insert(tAllLevelReward, tLevelReward)
    tAllLevelReward[i] = tLevelReward
  end
  UnknowPassAwardSystem.  UnknowPassAwardSystem.AwardLevelList = tAllLevelReward
  return tAllLevelReward
end
function UnknowPassAwardSystem.UpdateCurLevelRewardStatus(tLevelReward, tResData, bIsExperience)
  local nCurLevel = UnknowPassSystem.Level
  local bIsBuyElite = UnknowPassSystem.IsBuyElite
  local bIsBuyEliteSeg2 = UnknowPassSystem.IsBuyEliteSeg2
  local nSeg2StartLevel = UnknowPassAwardSystem.PASS_SEGMENT_COUNT
  tLevelReward.ordinaryAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_NoAward
  if tResData.reward_status.ordinary[tLevelReward.level] then
    tLevelReward.ordinaryAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
  elseif nCurLevel >= tLevelReward.level then
    tLevelReward.ordinaryAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet
  else
    tLevelReward.ordinaryAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_Lock
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if not bIsExperience and PassDataSystem.is_experience == 1 then
    tLevelReward.eliteAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_Lock
  elseif bIsBuyElite then
    if tResData.reward_status.elite[tLevelReward.level] then
      tLevelReward.eliteAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
    elseif nCurLevel >= tLevelReward.level then
      if not bIsBuyEliteSeg2 and nSeg2StartLevel < tLevelReward.level then
        tLevelReward.eliteAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_Lock
      else
        tLevelReward.eliteAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet
      end
    else
      tLevelReward.eliteAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_Lock
    end
  else
    tLevelReward.eliteAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_Lock
  end
end
function UnknowPassAwardSystem.InitNormalRewardList(tLevelReward, tCurLevelNorCfg)
  if not tCurLevelNorCfg then
    return
  end
  local itemGroupCfg = UnknowPassAwardSystem.GetLevelAwardGroupCfg(tCurLevelNorCfg.item_id_1)
  if not itemGroupCfg then
    return
  end
  local tItemData = {}
  tItemData.resId = itemGroupCfg.item_id_1
  tItemData.number = itemGroupCfg.item_num_1
  if GlobalData.IsJapanOrKorea() and tItemData.resId == 1109 then
    tItemData.resId = 1001
    tItemData.number = math.floor(tItemData.number / 6)
  end
  tItemData.item_show_type = itemGroupCfg.item_show_type_1
  tItemData.showSpecialEffect = itemGroupCfg.item_show_effect_1 == 1
  tItemData.status = tLevelReward.ordinaryAwardState
  tLevelReward.OrdinaryAwardList[#tLevelReward.OrdinaryAwardList + 1] = tItemData
end
local GetRewardGroupId = function(tCurLevelPlusCfg, nGroupIndex, bIsExperience, bIsSub)
  if bIsSub then
    return tCurLevelPlusCfg["item_id_exp_sub_" .. nGroupIndex]
  elseif bIsExperience then
    return tCurLevelPlusCfg["item_id_exp_" .. nGroupIndex]
  else
    return tCurLevelPlusCfg["item_id_" .. nGroupIndex]
  end
end
local CreateItemData = function(itemGroupCfg, nItemIndex, tLevelReward, nGroupId, bIsPlus)
  local nResId = itemGroupCfg["item_id_" .. nItemIndex]
  if not nResId or nResId <= 0 then
    return nil
  end
  return {
    resId = nResId,
    number = itemGroupCfg["item_num_" .. nItemIndex],
    item_show_type = itemGroupCfg["item_show_type_" .. nItemIndex],
    status = tLevelReward.eliteAwardState,
    groupId = nGroupId,
    price = itemGroupCfg.show_price,
    showSpecialEffect = itemGroupCfg["item_show_effect_" .. nItemIndex] == 1,
    isLimitTime = 0 < itemGroupCfg["item_expire_time_" .. nItemIndex],
    isPlus = bIsPlus
  }
end
local HandleFirstBuyReward = function(tLevelReward, tCurLevelPlusCfg, bIsPlus, nFullAwardNum)
  if not tCurLevelPlusCfg.item_id_new_user or tCurLevelPlusCfg.item_id_new_user <= 0 then
    return
  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local ENUM_NEWUSER_STATE = UnknowPassMacro.ENUM_NEWUSER_STATE
  local nNewUserState = UnknowPassSystem.upass_newuser_state
  if nNewUserState ~= ENUM_NEWUSER_STATE.NEVER_BUY and nNewUserState ~= ENUM_NEWUSER_STATE.NEVER_BUY_USED then
    return
  end
  local itemGroupCfg = UnknowPassAwardSystem.GetLevelAwardGroupCfg(tCurLevelPlusCfg.item_id_new_user)
  if not itemGroupCfg then
    return
  end
  UnknowPassAwardSystem.FirstBuyEliteAwardList[#UnknowPassAwardSystem.FirstBuyEliteAwardList + 1] = {
    level = tLevelReward.level,
    firstBuyNum = itemGroupCfg.item_num_1,
    fullBuyNum = nFullAwardNum
  }
  local tItemData = CreateItemData(itemGroupCfg, 1, tLevelReward, tCurLevelPlusCfg.item_id_new_user, bIsPlus)
  if not tItemData then
    return
  end
  table.insert(tLevelReward.EliteAwardList, 1, tItemData)
  if nNewUserState == ENUM_NEWUSER_STATE.NEVER_BUY then
    tLevelReward.EliteAwardList[1].showFirstBuy = true
    tLevelReward.EliteAwardList[1].showImageOr = true
    if tLevelReward.EliteAwardList[2] then
      tLevelReward.EliteAwardList[2].showEliteOrPlus = true
    end
  elseif nNewUserState == ENUM_NEWUSER_STATE.NEVER_BUY_USED then
    tLevelReward.EliteAwardList[1].showFirstBuy = true
    tLevelReward.EliteAwardList[1].showImageOr = false
    if tLevelReward.EliteAwardList[2] then
      tLevelReward.EliteAwardList[2].showEliteOrPlus = true
      tLevelReward.EliteAwardList[2].number = tLevelReward.EliteAwardList[2].number - tLevelReward.EliteAwardList[1].number
      if UnknowPassSystem.PassType == 1 then
        tLevelReward.EliteAwardList[2].status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_Lock
      elseif UnknowPassSystem.PassType == 2 then
        tLevelReward.EliteAwardList[2].isPlus = true
        tLevelReward.EliteAwardList[2].newUserAward = true
        if UnknowPassSystem.Data.reward_status.elite_plus[tLevelReward.level] then
          tLevelReward.EliteAwardList[2].status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
        elseif UnknowPassSystem.Level >= tLevelReward.level then
          tLevelReward.EliteAwardList[2].status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet
        else
          tLevelReward.EliteAwardList[2].status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_Lock
        end
      end
    end
  end
end
function UnknowPassAwardSystem.InitPlusRewardList(tLevelReward, tCurLevelPlusCfg, isPlus, bIsExperience, bIsSub)
  if not tCurLevelPlusCfg then
    return
  end
  local MAX_GROUP_COUNT = 2
  local MAX_ITEM_PER_GROUP = 4
  local nFullAwardNum = tCurLevelPlusCfg.item_num_1
  local bIsPlusReward = isPlus and UnknowPassSystem.PassType == 2
  local bIsReceived = bIsPlusReward and UnknowPassSystem.Data.reward_status.elite_plus[tLevelReward.level]
  local bIsLevelSufficient = bIsPlusReward and UnknowPassSystem.Level >= tLevelReward.level
  for nGroupIndex = 1, MAX_GROUP_COUNT do
    local nGroupId = GetRewardGroupId(tCurLevelPlusCfg, nGroupIndex, bIsExperience, bIsSub)
    local itemGroupCfg = UnknowPassAwardSystem.GetLevelAwardGroupCfg(nGroupId)
    if itemGroupCfg then
      nFullAwardNum = itemGroupCfg.item_num_1
      for nItemIndex = 1, MAX_ITEM_PER_GROUP do
        local tItemData = CreateItemData(itemGroupCfg, nItemIndex, tLevelReward, nGroupId, isPlus)
        if tItemData then
          if isPlus then
            if UnknowPassSystem.PassType == 1 then
              tItemData.status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_Lock
            elseif UnknowPassSystem.PassType == 2 then
              tItemData.status = bIsReceived and UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet or bIsLevelSufficient and UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet or UnknowPassAwardSystem.ENUM_UNKNOWPASS_Lock
            end
          end
          table.insert(tLevelReward.EliteAwardList, tItemData)
        end
      end
    end
  end
  if UnknowPassSystem.Season ~= 59 then
    return
  end
  HandleFirstBuyReward(tLevelReward, tCurLevelPlusCfg, isPlus, nFullAwardNum)
end
function UnknowPassAwardSystem.GetAwardLevelPreviewList()
  return UnknowPassAwardSystem.tAllPreviewLevel or {}
end
function UnknowPassAwardSystem.IsBanVedioAndAnmiOnGrowthRPGuide()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local Ban = growthprojectMgrB.IsSkipOldRPGuide()
  return Ban
end
function UnknowPassAwardSystem.UpdateAwardList()
  log(bWriteLog and "---UnknowPassAwardUI.UpdateAwardList")
  if not UnknowPassAwardSystem.AwardLevelList then
    return 1
  end
  local stayLevel = UnknowPassSystem.Level
  local bCanGetReward = false
  for i, info in ipairs(UnknowPassAwardSystem.AwardLevelList) do
    if info.ordinaryAwardState == UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet then
      stayLevel = info.level
      bCanGetReward = true
      break
    end
    if info.eliteAwardState == UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet then
      stayLevel = info.level
      bCanGetReward = true
      break
    end
  end
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  local jumpInfo = UnknowPassTunnelSystem.jumpInfo
  if jumpInfo then
    local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
    if not UnknowPassOpenUISystem.GetIsOpenBonusPassAward() and (jumpInfo.Tab1 == 1 or jumpInfo.Tab1 == 2) then
      local bJumpOK, isInBox = UnknowPassAwardSystem.JumpTo(jumpInfo.itemId)
      if bJumpOK == false then
        local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
        PassPreviewSystem.ShowDefaultModelWear()
      end
    end
  else
    if bCanGetReward == false and 1 < stayLevel then
      stayLevel = stayLevel - 1
    end
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_JUMPTO_LEVEL, stayLevel)
    if UnknowPassAwardSystem.isNeedInitAwards then
      if not UnknowPassSystem.IsBuyElite then
        UnknowPassAwardSystem.HideSelectItem()
        local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
        local panelType = PassDataSystem.GetPanelType()
        local curPanel = PassDataSystem.GetCurRpPanelType()
        if curPanel ~= panelType.BranchRp then
          EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_SHOW_LEFTDETAIL, true)
        end
      else
        local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
        PassPreviewSystem.ShowDefaultModelWear()
      end
    end
    UnknowPassAwardSystem.isNeedInitAwards = false
  end
  return stayLevel
end
function UnknowPassAwardSystem.OnGetLevelAward(level, is_elite_task, reward_list, group_id, _, is_elite_plus)
  local info = UnknowPassAwardSystem.AwardLevelList[level]
  if not info then
    return
  end
  if is_elite_task then
    info.eliteAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
    if info.EliteAwardList[2] and is_elite_plus then
      info.EliteAwardList[2].status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
      UnknowPassSystem.Data.reward_status.elite_plus[info.level] = 1
    end
    if info.isSplitGroup and info.EliteAwardList then
      for ii, eliteAward in pairs(info.EliteAwardList) do
        if UnknowPassSystem.Data.reward_status.elite[info.level] then
          eliteAward.status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
        elseif group_id == eliteAward.groupId then
          eliteAward.status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
        else
          eliteAward.status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_NeedBuy
        end
      end
    end
    UnknowPassSystem.Data.reward_status.elite[info.level] = 1
  else
    info.ordinaryAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
    UnknowPassSystem.Data.reward_status.ordinary[info.level] = 1
  end
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.UpdateReddot()
  UnknowPassAwardSystem.ShowAwardList(reward_list)
  UnknowPassAwardSystem.isNeedInitAwards = false
  passReddotMainSystem.InfoUpdate()
end
function UnknowPassAwardSystem.OnGetTotalLevelAward(reward_list)
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  local tRewardStatus = UnknowPassSystem.Data.reward_status
  for i, info in ipairs(UnknowPassAwardSystem.AwardLevelList) do
    if info.ordinaryAwardState == UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet then
      info.ordinaryAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
      tRewardStatus.ordinary[i] = nCurTime
    end
    if info.eliteAwardState == UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet or info.EliteAwardList[2] and info.EliteAwardList[2].status == UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet then
      info.eliteAwardState = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
      if info.EliteAwardList[2] and UnknowPassSystem.IsBuyElite and UnknowPassSystem.PassType == 2 then
        info.EliteAwardList[2].status = UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet
        UnknowPassSystem.Data.reward_status.elite_plus[info.level] = 1
      end
      tRewardStatus.elite[i] = nCurTime
    end
  end
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.UpdateReddot()
  UnknowPassAwardSystem.ShowAwardList(reward_list)
end
function UnknowPassAwardSystem.HasCanGetReward(bForceParse)
  local awardLevelList = UnknowPassAwardSystem.GetAwardLevelList(bForceParse)
  if not awardLevelList then
    return false
  end
  for _, item in ipairs(awardLevelList) do
    if #item.OrdinaryAwardList > 0 then
      for _, v in pairs(item.OrdinaryAwardList) do
        if v.status == UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet then
          return true
        end
      end
    end
    if 0 < #item.EliteAwardList then
      for _, v in pairs(item.EliteAwardList) do
        if v.status == UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet then
          return true
        end
      end
    end
  end
  return false
end
function UnknowPassAwardSystem.ShowAwardList(reward_list)
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local isExp = false
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.is_experience and PassDataSystem.is_experience == 1 then
    isExp = true
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local tAllItem = UnknowPassUtil.GetAwardList(reward_list)
  UnknowPassAwardSystem.DelayPostRefreshRPMain()
  if UnknowPassSystem.IsBuyElite then
    local tExtendData = UnknowPassAwardSystem.GetRPRewardShowCfg(tAllItem, isExp)
    Logic_CommonItemGet.ShowPanel_RPRewardGet(tAllItem, tExtendData)
  else
    UnknowPassAwardSystem.GetEliteItem(false)
    local tBottomAllItem = UnknowPassAwardSystem.UnknowPassShowOrdinaryAward_EliteItem_List
    Logic_CommonItemGet.ShowPanel_RPTwoScrollGet(tAllItem, tBottomAllItem, function()
      local logic_upass_level_slap = require("client.slua.logic.upass.levelSlap.logic_upass_level_slap")
      logic_upass_level_slap.ShowLevelSlap()
      if not UnknowPassAwardSystem.nPostTimerId then
        return
      end
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE)
      UnknowPassAwardSystem.RemovePostTimer()
    end)
  end
end
function UnknowPassAwardSystem.GetRPRewardShowCfg(tAllItem, bIsExp)
  local tExtendData = {
    fCloseCallback = function()
      UnknowPassAwardSystem.CheckShowCoinTip(tAllItem)
      local UnknowPassSlapSystem = require("client.slua.logic.unknow_pass.NewRPInitFlow.logic_unknowpass_slap")
      UnknowPassSlapSystem.ShowPostBuySlap()
      if not UnknowPassAwardSystem.nPostTimerId then
        return
      end
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE)
      UnknowPassAwardSystem.RemovePostTimer()
    end
  }
  if bIsExp then
    local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
    local tRPUpgradeBtn = CommonItemGet_BtnCfgUtils.GetRPUpgradeBtn(function()
      local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
      PassPreviewSystem.StopAction()
      local UnknowPassBuySyetem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
      UnknowPassBuySyetem.OpenBuyUI(false, 2)
      EventSystem:postEvent(EVENTTYPE_COMMON_ITEM_GET, EVENTID_CHECK_NEXT_SHOW)
    end)
    tExtendData.tAddBtn = {tRPUpgradeBtn}
    tExtendData.sBottomTipStr = LocUtil.GetLocalizeResStr(45520)
  end
  return tExtendData
end
function UnknowPassAwardSystem.DelayPostRefreshRPMain()
  UnknowPassAwardSystem.RemovePostTimer()
  local ui_util = require("client.common.ui_util")
  local nDeviceLevel = ui_util.GetGameInstance():GetDeviceLevel()
  local nDelayTime = 1 < nDeviceLevel and 1 or 2
  local time_ticker = require("common.time_ticker")
  local nTimerId = time_ticker.AddTimerOnce(nDelayTime, function()
    if not UnknowPassAwardSystem.nPostTimerId then
      return
    end
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE)
    UnknowPassAwardSystem.RemovePostTimer()
  end)
  UnknowPassAwardSystem.nPostTimerId = nTimerId
end
function UnknowPassAwardSystem.RemovePostTimer()
  if not UnknowPassAwardSystem.nPostTimerId then
    return
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.RemoveTimer(UnknowPassAwardSystem.nPostTimerId)
  UnknowPassAwardSystem.nPostTimerId = nil
end
function UnknowPassAwardSystem.CheckShowCoinTip(tAllItem)
  local unknowpassSubwaySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subway")
  local coinType = unknowpassSubwaySystem.GetWillShowCoinTipType(tAllItem)
  if coinType and 0 < coinType then
    unknowpassSubwaySystem.SetShowCoinTipFlag(true)
    unknowpassSubwaySystem.SetShowCoinTipType(coinType)
  else
    unknowpassSubwaySystem.SetShowCoinTipFlag(false)
  end
end
function UnknowPassAwardSystem.CheckItemGetHandler(tAllItem)
  UnknowPassAwardSystem.CheckShowCoinTip(tAllItem)
  EventSystem:postEvent(EVENTTYPE_COMMON_ITEM_GET, EVENTID_CHECK_NEXT_SHOW)
end
function UnknowPassAwardSystem.JumpTo(ItemId)
  log(bWriteLog and "ItemId: " .. tostring(ItemId))
  local isInBox = false
  local info = {}
  local ToLevel = -1
  for i, v in pairs(UnknowPassAwardSystem.AwardLevelList) do
    local OrdinaryAward = v.OrdinaryAwardList
    local EliteAward = v.EliteAwardList
    local bFind = false
    for _, Item in pairs(OrdinaryAward) do
      if Item.resId == ItemId then
        ToLevel = v.level
        info.Idx = i - 1
        info.IsElite = false
        info.EliteIdx = 0
        info.ResId = ItemId
        break
      else
        local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
        local itemList = PassPreviewSystem.GetTreasureBoxItemList(Item.resId)
        if itemList then
          for _, vv in pairs(itemList) do
            if vv.itemId == ItemId then
              ToLevel = v.level
              info.Idx = i - 1
              info.IsElite = true
              info.EliteIdx = 0
              info.ResId = ItemId
              bFind = true
              isInBox = true
              break
            end
          end
        end
      end
      if bFind then
        break
      end
    end
    for idx, Item in pairs(EliteAward) do
      if Item.resId == ItemId then
        ToLevel = v.level
        info.Idx = i - 1
        info.IsElite = true
        info.EliteIdx = idx - 1
        info.ResId = ItemId
        break
      else
        local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
        local itemList = PassPreviewSystem.GetTreasureBoxItemList(Item.resId)
        if itemList then
          for _, vv in pairs(itemList) do
            if vv.itemId == ItemId then
              ToLevel = v.level
              info.Idx = i - 1
              info.IsElite = true
              info.EliteIdx = idx - 1
              info.ResId = ItemId
              bFind = true
              break
            end
          end
        end
      end
      if bFind then
        break
      end
    end
    if 0 <= ToLevel then
      break
    end
  end
  log(bWriteLog and "UnknowPassAwardUI.JumpTo: " .. ToLevel)
  if ToLevel < 0 then
    return false, isInBox
  end
  info.itemLevel = ToLevel
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_JUMPTO_LEVEL, ToLevel)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_JUMP_SELECT, info)
  return true, isInBox
end
function UnknowPassAwardSystem.HideSelectItem()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_HIDE_SELECTITEM)
end
function UnknowPassAwardSystem.SwitchToAwardPanel()
  if UIManager.GetUI(UIManager.UI_Config.unknowpass_award) then
    local ui = UIManager.GetUI(UIManager.UI_Config.UnknowPass_Award_Branch_BP)
    if ui then
      ui:Collapsed()
      local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
      local panelType = PassDataSystem.GetPanelType()
      PassDataSystem.SetCurPanelType(panelType.MainRp)
    end
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_TAB)
    local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
    PassPreviewSystem.StopAction()
    local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
    UnknowPassBuySystem.HideAwardBuyScoreUI()
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    if PassDataSystem.GetCurTab() == PassDataSystem.GetTabType().award then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_AWARDUI, true)
      PassPreviewSystem.ShowDefaultModelWear()
    end
  end
end
function UnknowPassAwardSystem.SwitchToBranchAwardPanel()
  if UIManager.GetUI(UIManager.UI_Config.UnknowPass_Award_Branch_BP) then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_TAB)
    local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
    PassPreviewSystem.StopAction()
    local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
    UnknowPassBuySystem.HideAwardBuyScoreUI()
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    if PassDataSystem.GetCurTab() == PassDataSystem.GetTabType().award then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_SHOW_AWARDUI, true)
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_SHOW_AVATAR)
    end
  end
end
function UnknowPassAwardSystem.GetCoreAwardData()
  local retList = {}
  local AwardTable = CDataTable.GetTable("UnknowPassCoreAwardTipsCfg")
  for i, v in pairs(AwardTable) do
    log(bWriteLog and "UnknowPassAwardUI.GetCoreAwardData" .. UnknowPassSystem.Season .. v.SeasonId)
    if UnknowPassSystem.Season == v.SeasonId then
      table.insert(retList, {
        Level = v.Level,
        ItemId = v.ItemId,
        id = v.id,
        isPlus = v.IsPlus
      })
    end
  end
  table.sort(retList, function(a, b)
    return a.id < b.id
  end)
  return retList
end
function UnknowPassAwardSystem.GetContinueBuyAwardCfg(passtype)
  local awardTable = CDataTable.GetTableData("UPassContinueBuyAwardCfg", passtype)
  if not awardTable then
    return {}
  end
  local buyType = awardTable.PassType
  local awardStr = awardTable.ContinueBuyAward
  local StringUtil = require("common.string_util")
  local awardSplit = StringUtil.Split(awardStr, "|")
  local awardList = {}
  for index, str in pairs(awardSplit) do
    local dataList = StringUtil.SplitToNum(str, ";")
    awardList[index] = {
      passType = buyType,
      buyCount = dataList[1],
      itemId = dataList[2],
      count = dataList[3],
      vaild_hours = dataList[4]
    }
  end
  UnknowPassAwardSystem.reward_num = #awardList
  return awardList
end
function UnknowPassAwardSystem.UpdateContinueBuyData(buy_data)
  local continuous_buy = UnknowPassSystem.continuous_buy
  if not continuous_buy or not buy_data then
    return
  end
  for passtype, data in pairs(buy_data) do
    continuous_buy[passtype].cur_cont_buy = data.cur_cont_buy
    continuous_buy[passtype].max_cont_buy = data.max_cont_buy
  end
end
function UnknowPassAwardSystem.GetCurContinueBuyCount()
  local continuous_buy = UnknowPassSystem.continuous_buy
  if not continuous_buy then
    log(bWriteLog and "UnknowPassSystem.continuous_buy data is nil")
    return
  end
  local cur_cont_nor = continuous_buy[1].cur_cont_buy
  local cur_cont_plus = continuous_buy[2].cur_cont_buy
  return cur_cont_nor, cur_cont_plus
end
function UnknowPassAwardSystem.HandGetRewardRsp(pass_type, index, items)
  local continuous_buy = UnknowPassSystem.continuous_buy
  local award_record = continuous_buy[pass_type].award_record
  award_record[index] = 1
  local reward_info = {
    [1] = {
      res_id = items.item_id,
      count = items.item_num,
      valid_hours = items.item_expire_time
    }
  }
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GET_CONTINUE_BUY_REWARD)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(reward_info, nil, nil)
end
function UnknowPassAwardSystem.IsShowReddot()
  local reward_cfg_nor = UnknowPassAwardSystem.GetContinueBuyAwardCfg(1)
  local reward_cfg_plus = UnknowPassAwardSystem.GetContinueBuyAwardCfg(2)
  local continuous_buy = UnknowPassSystem.continuous_buy
  if not continuous_buy then
    return false
  end
  local nor_buy_data = continuous_buy[1]
  local plus_buy_data = continuous_buy[2]
  return UnknowPassAwardSystem.HasAvailableReward(reward_cfg_nor, nor_buy_data) or UnknowPassAwardSystem.HasAvailableReward(reward_cfg_plus, plus_buy_data)
end
function UnknowPassAwardSystem.HasAvailableReward(reward_cfg, buy_data)
  local max_cont_buy = buy_data.max_cont_buy
  local reward_record = buy_data.award_record
  for _, data in pairs(reward_cfg) do
    if max_cont_buy >= data.buyCount and not reward_record[data.buyCount] then
      return true
    end
  end
  return false
end
function UnknowPassAwardSystem.IsSeasonNearExpire()
  local seasonEndTime = UnknowPassSystem.SeasonInfo.cfg.end_timestamp
  local TimeUtil = require("client.common.time_util")
  local diffTime = seasonEndTime - TimeUtil.GetServerTimeInSec()
  return 0 < diffTime and diffTime < 259200
end
function UnknowPassAwardSystem.TrySetIsTodayShow()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local currentDay = TimeUtil.OSDate("!%Y%m%d", TimeUtil.GetServerTimeInSec())
  local lastShowDay = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassAwardUI) or ""
  if currentDay == lastShowDay then
    return true
  else
    PlayerPrefsSystem.SaveTableToFile_N(currentDay, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassAwardUI)
    return false
  end
end
function UnknowPassAwardSystem.GetSpecialPreviewMap()
  local tAllCfg = UnknowPassAwardSystem.tSeasonLevelImage
  if tAllCfg[UnknowPassSystem.Season] then
    return tAllCfg[UnknowPassSystem.Season]
  end
  local cfgTable = CDataTable.GetTableByFilter("UnknowPassSpecialPreviewAward", "SeasonId", UnknowPassSystem.Season) or {}
  local res = {}
  for i, v in pairs(cfgTable) do
    if v.SeasonId == UnknowPassSystem.Season then
      res[v.Level] = v.ImagePath
    end
  end
  tAllCfg[UnknowPassSystem.Season] = res
  return res
end
function UnknowPassAwardSystem.GetEliteItem(forceParse)
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  UnknowPassAwardSystem.UnknowPassShowOrdinaryAward_EliteItem_List = {}
  local reward_map = {}
  local awardLevelList = UnknowPassAwardSystem.GetAwardLevelList(forceParse)
  if not awardLevelList then
    return nil
  end
  for i = 1, UnknowPassSystem.Level do
    local item = awardLevelList[i]
    if not item then
      break
    end
    for j = 1, #item.EliteAwardList do
      local item0 = item.EliteAwardList[j]
      local reward = reward_map[item0.resId]
      if reward then
        if item0.resId ~= 1101006027 then
          reward.item_num = reward.item_num + item0.number
        end
      else
        local cfgItem = CDataTable.GetTableData("Item", item0.resId)
        if cfgItem then
          local item = {
            item_id = item0.resId,
            item_num = item0.number,
            item_show_type = item0.item_show_type,
            item_quality = cfgItem.ItemQuality
          }
          reward_map[item0.resId] = item
        end
      end
    end
  end
  local elite_reward_array = {}
  for _, eliteReward in pairs(reward_map) do
    table.insert(elite_reward_array, {
      item_id = eliteReward.item_id,
      item_num = eliteReward.item_num,
      item_show_type = eliteReward.item_show_type,
      item_quality = eliteReward.item_quality
    })
  end
  table.sort(elite_reward_array, function(a, b)
    return a.item_quality > b.item_quality
  end)
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local sTimeStr = UnknowPassUtil.GetSeasonEndTimeStr()
  local tTimeExtra = {is_limit = true, time_s = sTimeStr}
  for _, eliteReward in pairs(elite_reward_array) do
    local tTempItem = {
      res_id = eliteReward.item_id,
      count = eliteReward.item_num,
      showType = eliteReward.item_show_type
    }
    if UnknowPassUtil.IsSeasonTimeLimitItem(eliteReward.item_id) then
      tTempItem.extra = tTimeExtra
    end
    if eliteReward.item_id == 1006 then
      table.insert(UnknowPassAwardSystem.UnknowPassShowOrdinaryAward_EliteItem_List, 1, tTempItem)
    else
      table.insert(UnknowPassAwardSystem.UnknowPassShowOrdinaryAward_EliteItem_List, tTempItem)
    end
  end
end
function UnknowPassAwardSystem.GetUCDiamondItemId(item_num)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if item_num == 30 then
    return PassDataSystem.UCAndDiamondIconId
  elseif item_num == 100 then
    return PassDataSystem.UCAndDiamondIconId2
  elseif item_num == 50 then
    return PassDataSystem.UCAndDiamondIconId3
  elseif item_num == 80 then
    return PassDataSystem.UCAndDiamondIconId5
  elseif item_num == 40 then
    return PassDataSystem.UCAndDiamondIconId6
  else
    return PassDataSystem.UCAndDiamondIconId4
  end
end
function UnknowPassAwardSystem.upass_get_level_award_req(level, is_elite_task, is_elite_plus)
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_get_level_award_req(level, is_elite_task, nil, is_elite_plus)
end
function UnknowPassAwardSystem.upass_get_level_award_rsp(res, level, is_elite_task, reward_list, group_id, need_buy_awards, is_elite_plus)
  if res ~= 0 then
    ShowNotice(res)
  else
    UnknowPassAwardSystem.OnGetLevelAward(level, is_elite_task, reward_list, group_id, need_buy_awards, is_elite_plus)
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GET_LEVEL_AWARD, {
      level = level,
      is_elite_task = is_elite_task,
      reward_list = reward_list,
          })
  end
end
function UnknowPassAwardSystem.upass_batch_get_level_award_req(selects)
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_batch_get_level_award_req(selects)
end
function UnknowPassAwardSystem.upass_batch_get_level_award_rsp(res, reward_tb, need_buy_awards)
  if res ~= 0 then
    ShowNotice(res)
  else
    UnknowPassAwardSystem.OnGetTotalLevelAward(reward_tb)
  end
end
return UnknowPassAwardSystem