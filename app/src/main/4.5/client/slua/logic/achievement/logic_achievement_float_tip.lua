local logic_achievement_float_tip = {}
function logic_achievement_float_tip.Init()
  logic_achievement_float_tip.BlockingPopTip = false
  logic_achievement_float_tip.HasClickedIngore = false
  logic_achievement_float_tip.AchievementIDList = {}
  logic_achievement_float_tip.setDelay = false
  logic_achievement_float_tip.firstInitialize = false
  logic_achievement_float_tip.LoadData()
  EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, logic_achievement_float_tip.OnLoginRestoreStatus)
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, logic_achievement_float_tip.OnLoginRestoreStatus)
end
function logic_achievement_float_tip.LoadData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  log(bWriteLog and DataMgr.roleData.openID)
  local ppConfig = logic_achievement_float_tip.GetPlayerPrefabConfig()
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(ppConfig)
  logic_achievement_float_tip.LocalRecord = saveData or {}
end
function logic_achievement_float_tip.InsertLocalRecord(id)
  if not logic_achievement_float_tip.IsLocalRecords(id) then
    table.insert(logic_achievement_float_tip.LocalRecord, id)
  end
end
function logic_achievement_float_tip.IsLocalRecords(id)
  local bIn = false
  for i, AchID in ipairs(logic_achievement_float_tip.LocalRecord) do
    if id == AchID then
      bIn = true
      break
    end
  end
  return bIn
end
function logic_achievement_float_tip.OnModePostSwitch(preState, nextState)
end
function logic_achievement_float_tip.UpdateDataOnRsp(idList)
  if idList then
    local AchieveHandler = require("client.network.Protocol.AchieveHandler")
    for _, AchID in pairs(idList) do
      local bGeted = AchieveHandler.IsGetAchRewardByID(AchID)
      local bProgressFinish = AchieveHandler.CheckAchiveCanFinishWithCfg(AchID)
      if bProgressFinish and not bGeted then
        logic_achievement_float_tip.TryPushIdOnQueue(AchID)
      end
    end
  end
  if logic_achievement_float_tip.setDelay == false then
    local logic_post_switch_popup = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_post_switch_popup)
    logic_post_switch_popup:TryExecuteOne(BP_ENUM_MODULE_ACHIEVEMENT_POPUP)
  end
end
function logic_achievement_float_tip.TryPushIdOnQueue(id)
  log(bWriteLog and "[qintong] logic_achievement_float_tip.TryPushIdOnQueue =  " .. tostring(id))
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  if AchieveHandler.IsExtinctByID(id) then
    log(bWriteLog and "[qintong] logic_achievement_float_tip IsExtinctByID" .. id)
    return
  end
  if logic_achievement_float_tip.IsLocalRecords(id) then
    log(bWriteLog and "[qintong] logic_achievement_float_tip IsLocalRecords" .. id)
    return
  end
  if logic_achievement_float_tip.HasClickedIngore then
    log(bWriteLog and "ShowAchievementTip return 5 HasClickedIngoreID = " .. tostring(id))
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local ppConfig = logic_achievement_float_tip.GetPlayerPrefabConfig()
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(ppConfig) or {}
    table.insert(saveData, id)
    PlayerPrefsSystem.SaveTableToFile_N(saveData, ppConfig)
    logic_achievement_float_tip.InsertLocalRecord(id)
    return
  end
  local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
  if not achievement_cfg_helper.IsValidAchievementID(id) then
    log(bWriteLog and "[DeanJYT]  logic_achievement_float_tip.TryPushIdOnQueue not IsValidAchievementID, id = " .. tostring(id))
    return
  end
  logic_achievement_float_tip.AddQueue(id)
end
function logic_achievement_float_tip.AddQueue(id)
  for i = #logic_achievement_float_tip.AchievementIDList, 1, -1 do
    local AchID = logic_achievement_float_tip.AchievementIDList[i]
    if id == AchID then
      table.remove(logic_achievement_float_tip.AchievementIDList, i)
    end
  end
  local scoreSort = function(aAchID, bAchID)
    local aCfg = CDataTable.GetTableData("AchievementCfg", aAchID)
    local bCfg = CDataTable.GetTableData("AchievementCfg", bAchID)
    if aCfg == nil or bCfg == nil then
      return false
    end
    return aCfg.Score < bCfg.Score
  end
  table.insert(logic_achievement_float_tip.AchievementIDList, id)
  table.sort(logic_achievement_float_tip.AchievementIDList, scoreSort)
  log_tree("[qintong] logic_achievement_float_tip.AddQueue" .. tostring(id), logic_achievement_float_tip.AchievementIDList)
end
function logic_achievement_float_tip.CheckMenuOpen(id)
  return LobbySystem.CheckOpen(id)
end
function logic_achievement_float_tip.ShowAchievementTip()
  log(bWriteLog and "logic_achievement_float_tip.ShowAchievementTip")
  local CanPopUp = logic_achievement_float_tip.CanUpCommonLimit()
  if not CanPopUp then
    log(bWriteLog and "logic_achievement_float_tip.ShowAchievementTip not CanPopUp")
    return
  end
  local PopUpList = {}
  for i = 1, #logic_achievement_float_tip.AchievementIDList do
    local AchID = logic_achievement_float_tip.AchievementIDList[i]
    local CanPopLimit = logic_achievement_float_tip.CanPopUpAch(AchID)
    if CanPopLimit then
      table.insert(PopUpList, AchID)
    end
  end
  if #PopUpList == 0 then
    log(bWriteLog and "logic_achievement_float_tip.ShowAchievementTip PopUpList is empty")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Achievement_Tip_UIBP, PopUpList)
  logic_achievement_float_tip.AchievementIDList = {}
end
function logic_achievement_float_tip.RemoveFromQueue()
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  for index = #logic_achievement_float_tip.AchievementIDList, 1, -1 do
    local AchID = logic_achievement_float_tip.AchievementIDList[index]
    local bGeted = AchieveHandler.IsGetAchRewardByID(AchID)
    if bGeted then
      table.remove(logic_achievement_float_tip.AchievementIDList, index)
    end
  end
  log_tree("[qintong] ShowAchievementTip   ", logic_achievement_float_tip.AchievementIDList)
  for index = #logic_achievement_float_tip.AchievementIDList, 1, -1 do
    local AchID = logic_achievement_float_tip.AchievementIDList[index]
    if logic_achievement_float_tip.IsLocalRecords(AchID) then
      table.remove(logic_achievement_float_tip.AchievementIDList, index)
    end
  end
end
function logic_achievement_float_tip.CanUpCommonLimit()
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) then
    local bUIAutoTest = GameAutotest:IsUIAutoTest()
    if bUIAutoTest then
      log(bWriteLog and "ShowAchievementTip return 1")
      return false
    end
  end
  if IsWoWEditor then
    return false
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.achievement) then
    return false
  end
  if UIManager.IsUIShow(UIManager.UI_Config.vehicle_halloween_skin) then
    log(bWriteLog and "ShowAchievementTip return 3")
    return false
  end
  if UIManager.IsUIShow(UIManager.UI_Config.allstar_begin_popup) then
    log(bWriteLog and "ShowAchievementTip return 11")
    return false
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Championship_Begin_Popup) then
    log(bWriteLog and "ShowAchievementTip return 12")
    return false
  end
  if not LobbySystem.CheckOpen(10024) then
    log(bWriteLog and "ShowAchievementTip return 4")
    return false
  end
  if not logic_achievement_float_tip.CheckMenuOpen(BP_ENUM_ACHIEVEMENT_SWITCH_ID) then
    log(bWriteLog and "ShowAchievementTip return 6")
    return false
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local myselfOnIsland = MatchModeMgrSystem.IsSocialIslandMode()
  if myselfOnIsland then
    log(bWriteLog and "ShowAchievementTip return 7")
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "ShowAchievementTip return 8")
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and "ShowAchievementTip return 9")
    return false
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "ShowAchievementTip return 10")
    return false
  end
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  if logic_replay.IsPlayingReplay() then
    log(bWriteLog and "[yw ] TeamUpNewSystem.ShowInviteTip => replay is playing")
    return false
  end
  if DataMgr.anchor == 1 then
    logic_achievement_float_tip.BlockPopTip()
    log(bWriteLog and "[YY]OB Mode dont show UI")
    return false
  end
  return true
end
function logic_achievement_float_tip.CanPopUpAch(ID)
  local common_config = require("client.slua.common.common_config")
  if logic_achievement_float_tip.BlockingPopTip or common_config:IsBlockingPopupTip() then
    logic_achievement_float_tip.AddQueue(ID)
    log(bWriteLog and "ShowAchievementTip return 2")
    log(bWriteLog and "logic_achievement_float_tip.CanPopUpAch UI responsiveness testing")
    return false
  end
  if logic_achievement_float_tip.HasClickedIngore then
    log(bWriteLog and "ShowAchievementTip return 5 HasClickedIngoreID = " .. tostring(ID))
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local ppConfig = logic_achievement_float_tip.GetPlayerPrefabConfig()
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(ppConfig) or {}
    table.insert(saveData, ID)
    PlayerPrefsSystem.SaveTableToFile_N(saveData, ppConfig)
    logic_achievement_float_tip.InsertLocalRecord(ID)
    return false
  end
  return true
end
function logic_achievement_float_tip.CloseAchievementTip()
  log(bWriteLog and "logic_achievement_float_tip.CloseAchievementTip")
  local ui = UIManager.GetUI(UIManager.UI_Config.Achievement_Tip_UIBP)
  if ui then
    UIManager.CloseUI(UIManager.UI_Config.Achievement_Tip_UIBP)
  end
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.CloseSeasonChallengeTips()
end
function logic_achievement_float_tip.ClearNewAchievementList()
  logic_achievement_float_tip.AchievementIDList = {}
  local giftSystem = require("client.slua.logic.store.logic_store_gift")
  giftSystem.PopCommonTip()
end
function logic_achievement_float_tip.OnLoginRestoreStatus()
  logic_achievement_float_tip.ClearNewAchievementList()
  logic_achievement_float_tip.CloseAchievementTip()
end
function logic_achievement_float_tip.IslenthZeroNewAchievementList()
  return #logic_achievement_float_tip.AchievementIDList == 0
end
function logic_achievement_float_tip.BlockPopTip()
  log(bWriteLog and "[v_wllwu] logic_achievement_float_tip.BlockPopTip true")
  logic_achievement_float_tip.BlockingPopTip = true
  logic_achievement_float_tip.CloseAchievementTip()
end
function logic_achievement_float_tip.UnblockPopTip()
  log(bWriteLog and "[v_wllwu] logic_achievement_float_tip.BlockPopTip false")
  logic_achievement_float_tip.BlockingPopTip = false
end
function logic_achievement_float_tip.GetPlayerPrefabConfig()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local origin = PlayerPrefsSystem.ePlayerPrefsType.eNewVersionAchievement
  local TableUtil = require("common.table_util")
  local copy = TableUtil.CopyTable(origin)
  copy.path = copy.path .. "/" .. DataMgr.roleData.uid
  return copy
end
return logic_achievement_float_tip