local isUIShowing
local NInitPercent = 0
local NPercent = 1
local NBreakMinValue = 0
local NLoadingModeIndex = 0
local NLoadingUIIndex = 0
local BTimerSwitch = false
local BIsNeedSwapPosition
local random = math.random
local myTeam_uidList = {}
local oppoTeam_uidList = {}
local myUIds = {}
local oppoUIds = {}
local myTeam_robotData = {}
local oppoTeam_robotData = {}
local TeamCompLoading = {}
local GetProfile, TestData
local CacheRawData = {}
function TeamCompLoading.Test(is8v8)
  TestData = {
    [1] = {
      [1] = {
        is_robot = false,
        uid = DataMgr.roleData.uid
      }
    },
    [2] = {
      [1] = {
        is_robot = true,
        uid = 3280,
        info = {
          arena_segment_level = 305,
          is_robot = true,
          upass_level = 9,
          level = 7,
          nation = 0,
          segment_level = 305,
          pic_url = 30012,
          upass_is_buy = 1,
          name = "daniel1024",
          uid = 3280,
          avatar_box_id = 2003026,
          gender = 1,
          rating = 2664,
          ai_type = 1
        }
      },
      [2] = {
        is_robot = true,
        uid = 3281,
        info = {
          arena_segment_level = 101,
          is_robot = true,
          upass_level = 7,
          level = 20,
          nation = 0,
          segment_level = 305,
          pic_url = 3003,
          upass_is_buy = 1,
          name = "546456",
          uid = 3281,
          avatar_box_id = 2003026,
          gender = 1,
          rating = 1044,
          ai_type = 1
        }
      },
      [3] = {
        is_robot = true,
        uid = 3282,
        info = {
          arena_segment_level = 204,
          is_robot = true,
          upass_level = 5,
          level = 12,
          nation = 0,
          segment_level = 204,
          pic_url = 3003,
          upass_is_buy = 1,
          name = "fsdjkh",
          uid = 3282,
          avatar_box_id = 2002204,
          gender = 1,
          rating = 1044,
          ai_type = 1
        }
      },
      [4] = {
        is_robot = true,
        uid = 3283,
        info = {
          arena_segment_level = 204,
          is_robot = true,
          upass_level = 5,
          level = 12,
          nation = 0,
          segment_level = 204,
          pic_url = 3003,
          upass_is_buy = 1,
          name = "fsdjkh1",
          uid = 3283,
          avatar_box_id = 2002204,
          gender = 1,
          rating = 1044,
          ai_type = 1
        }
      }
    }
  }
  local size = 4
  local submode = 12040
  if is8v8 then
    size = 8
    submode = 12054
    table.insert(TestData[1], {
      is_robot = true,
      uid = 3288,
      info = {
        arena_segment_level = 204,
        is_robot = true,
        upass_level = 5,
        level = 12,
        nation = 0,
        segment_level = 204,
        pic_url = 3003,
        upass_is_buy = 1,
        name = "fsdjkh1",
        uid = 3283,
        avatar_box_id = 2002204,
        gender = 1,
        rating = 1044,
        ai_type = 1
      }
    })
    table.insert(TestData[2], {
      is_robot = true,
      uid = 3284,
      info = {
        arena_segment_level = 204,
        is_robot = true,
        upass_level = 5,
        level = 12,
        nation = 0,
        segment_level = 204,
        pic_url = 3003,
        upass_is_buy = 1,
        name = "fsdjkh1",
        uid = 3283,
        avatar_box_id = 2002204,
        gender = 1,
        rating = 1044,
        ai_type = 1
      }
    })
    table.insert(TestData[2], {
      is_robot = true,
      uid = 3285,
      info = {
        arena_segment_level = 204,
        is_robot = true,
        upass_level = 5,
        level = 12,
        nation = 0,
        segment_level = 204,
        pic_url = 3003,
        upass_is_buy = 1,
        name = "fsdjkh1",
        uid = 3283,
        avatar_box_id = 2002204,
        gender = 1,
        rating = 1044,
        ai_type = 1
      }
    })
    table.insert(TestData[2], {
      is_robot = true,
      uid = 3286,
      info = {
        arena_segment_level = 204,
        is_robot = true,
        upass_level = 5,
        level = 12,
        nation = 0,
        segment_level = 204,
        pic_url = 3003,
        upass_is_buy = 1,
        name = "fsdjkh1",
        uid = 3283,
        avatar_box_id = 2002204,
        gender = 1,
        rating = 1044,
        ai_type = 1
      }
    })
    table.insert(TestData[2], {
      is_robot = true,
      uid = 3287,
      info = {
        arena_segment_level = 204,
        is_robot = true,
        upass_level = 5,
        level = 12,
        nation = 0,
        segment_level = 204,
        pic_url = 3003,
        upass_is_buy = 1,
        name = "fsdjkh1",
        uid = 3283,
        avatar_box_id = 2002204,
        gender = 1,
        rating = 1044,
        ai_type = 1
      }
    })
  end
  TeamCompLoading.ShowLoading(TestData, size, submode)
end
function TeamCompLoading.InitOnlyOne()
  log(bWriteLog and "  : TeamCompLoading Init")
end
function TeamCompLoading.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "  :TeamCompLoading nextState" .. tostring(nextState))
  if nextState ~= GameStatus.Fighting and nextState ~= GameStatus.Loading then
    TeamCompLoading.RefreshLoadPercent(1)
  end
end
function TeamCompLoading.RefreshLoadPercent(p, bForceSetToSlider)
  log(bWriteLog and "  ---LoadingDeathMatchUI scene object loading finished, start loading progress bar----" .. tostring(p))
  if 1 <= p then
    log(bWriteLog and "   LoadingDeathMatchUI.RefreshLoadPercent isUIShowing = false")
    isUIShowing = false
  end
  if bForceSetToSlider then
    NPercent = p
    NBreakMinValue = p
  else
    NPercent = p
    NBreakMinValue = 1
  end
end
function TeamCompLoading.GetLoadingMode()
  return NLoadingModeIndex
end
function TeamCompLoading.SetInitPercent(percent)
  NPercent = percent / 100
  NInitPercent = percent
end
function TeamCompLoading.ValidTimer()
  BTimerSwitch = true
end
function TeamCompLoading.ShowLoading(_teamsData, game_team_size, sub_mode)
  if not LobbySystem.isWaittingEnterBattle then
    NBreakMinValue = math.random(55, 85) / 100
  end
  BTimerSwitch = true
  NPercent = NInitPercent / 100
  log(bWriteLog and "  : NSliderPercent" .. tostring(NPercent))
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  log_tree("  Src TeamsData :", _teamsData)
  log(bWriteLog and "LoadingDeathMatchUI:Init submode is " .. tostring(sub_mode))
  if not isUIShowing then
    log(bWriteLog and "TeamCompLoading isUIShowing = true")
    isUIShowing = true
    local myUID = ""
    TeamCompLoading._InitData(game_team_size, sub_mode)
    myUID = DataMgr.roleData.uid
    BIsNeedSwapPosition = true
    for _, val in ipairs(_teamsData[1]) do
      if tonumber(val.uid) == tonumber(myUID) then
        log(bWriteLog and "---LoadingDeathMatchUI: Find in teamsData[1]---")
        BIsNeedSwapPosition = false
        break
      else
        log(bWriteLog and "---LoadingDeathMatchUI: Not find in teamsData[1]---")
      end
    end
    if BIsNeedSwapPosition == false then
      myTeam_uidList = _teamsData[1]
      oppoTeam_uidList = _teamsData[2]
    else
      myTeam_uidList = _teamsData[2]
      oppoTeam_uidList = _teamsData[1]
    end
    CacheRawData = {myTeam_uidList, oppoTeam_uidList}
    myUIds = {}
    if myTeam_uidList and next(myTeam_uidList) then
      for i, _ in ipairs(myTeam_uidList) do
        if myTeam_uidList[i].is_robot == false then
          table.insert(myUIds, myTeam_uidList[i].uid)
        end
      end
    end
    oppoUIds = {}
    local isEmpty = true
    if oppoTeam_uidList then
      for i, _ in ipairs(oppoTeam_uidList) do
        if oppoTeam_uidList[i].is_robot == false then
          table.insert(oppoUIds, oppoTeam_uidList[i].uid)
          isEmpty = false
        end
      end
    end
    if isEmpty == true then
      oppoUIds = nil
    end
    log_tree("outUid_myTeam =", myUIds)
    log_tree("outUid_oppoTeam =", oppoUIds)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(myUIds, TeamCompLoading.CallbackMyTeam, Enum_PROFILE_REPORT_CFG.DEATHMATCH_LOADING_MY, 0, true)
    if not isEmpty then
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles(oppoUIds, TeamCompLoading.CallbackOppoTeam, Enum_PROFILE_REPORT_CFG.DEATHMATCH_LOADING_OTHER, 0, true)
    end
    TeamCompLoading.UseRobot()
    UIManager.ShowUI(UIManager.UI_Config.team_comp_loading)
    logic_achievement_float_tip.CloseAchievementTip()
  end
end
function TeamCompLoading.GetMyUIds()
  return myUIds
end
function TeamCompLoading.GetOppoUIds()
  return oppoUIds
end
function TeamCompLoading.CallbackMyTeam()
  GetProfile.my = true
end
function TeamCompLoading.GetSwapPositionFlag()
  return BIsNeedSwapPosition
end
function TeamCompLoading.GetShowing()
  log(bWriteLog and "  : isUIShowing" .. tostring(isUIShowing))
  return isUIShowing
end
function TeamCompLoading.UseRobot()
  log(bWriteLog and "  : UseRobot")
  oppoTeam_robotData = {}
  if not oppoTeam_uidList or not myTeam_uidList then
    log(bWriteLog and "  : UseRobot noData")
    return
  end
  for i = 1, #oppoTeam_uidList do
    local teamInfo = oppoTeam_uidList[i]
    if teamInfo and teamInfo.is_robot then
      local uInfo = teamInfo.info
      local info = {}
      if uInfo then
        info.uid = uInfo.uid
        info.picUrl = uInfo.pic_url
        info.player_level = uInfo.level
        info.segment_level = uInfo.segment_level
        info.cur_avatar_box_id = uInfo.avatar_box_id
      end
      table.insert(oppoTeam_robotData, info)
    end
  end
  myTeam_robotData = {}
  for i = 1, #myTeam_uidList do
    local teamInfo = myTeam_uidList[i]
    if teamInfo and teamInfo.is_robot then
      local uInfo = teamInfo.info
      local info = {}
      if uInfo then
        info.uid = uInfo.uid
        info.picUrl = uInfo.pic_url
        info.player_level = uInfo.level
        info.segment_level = uInfo.segment_level
        info.cur_avatar_box_id = uInfo.avatar_box_id
      end
      table.insert(myTeam_robotData, info)
    end
  end
  log_tree("  : myTeam_robotData", myTeam_robotData)
  log_tree("  : oppoTeam_robotData", oppoTeam_robotData)
end
function TeamCompLoading.GetOppoTeamRobotProfile()
  return oppoTeam_robotData
end
function TeamCompLoading.GetMyTeamRobotProfile()
  return myTeam_robotData
end
function TeamCompLoading.CallbackOppoTeam()
  GetProfile.oppo = true
end
function TeamCompLoading.Tick()
  if not BTimerSwitch then
    return
  end
  local rand = random(20, 30) / 100
  local percent = NPercent + rand
  if percent < NBreakMinValue or 1 <= NBreakMinValue then
    NPercent = percent
  end
  if 1 <= NPercent then
    log(bWriteLog and "  : TeamCompLoading end")
    BTimerSwitch = false
  end
  TeamCompLoading.SetSliderPercent()
end
function TeamCompLoading.SetSliderPercent()
  local ui = UIManager.GetUI(UIManager.UI_Config.team_comp_loading)
  if ui then
    ui:UpdatePercent(NPercent)
  end
  local Lobby_Team_competition1v1_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Team_competition1v1_UIBP)
  if Lobby_Team_competition1v1_UIBP then
    Lobby_Team_competition1v1_UIBP:UpdatePercent(NPercent)
  end
end
function TeamCompLoading.GetLoadingUIIndex()
  log(bWriteLog and "  : NLoadingUIIndex" .. tostring(NLoadingUIIndex))
  return NLoadingUIIndex
end
function TeamCompLoading.GetProfileFlag()
  return GetProfile
end
function TeamCompLoading.GetPlayerNum()
  local myTeamNum = myUIds and #myUIds or 0
  local oppoTeamNum = oppoUIds and #oppoUIds or 0
  local myTeamRobotNum = myTeam_robotData and #myTeam_robotData or 0
  local oppoTeamRobotNum = oppoTeam_robotData and #oppoTeam_robotData or 0
  return myTeamNum + oppoTeamNum + myTeamRobotNum + oppoTeamRobotNum
end
function TeamCompLoading.Release()
  log(bWriteLog and "  : TeamCompLoading.Release")
  isUIShowing = nil
  myTeam_uidList = {}
  oppoTeam_uidList = {}
  myUIds = nil
  oppoUIds = nil
  myTeam_robotData = nil
  oppoTeam_robotData = nil
  TestData = nil
end
function TeamCompLoading._InitData(game_team_size, sub_mode)
  local super_data = require("common.super_data")
  GetProfile = super_data.CreateSuperData({my = false, oppo = false})
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  log(bWriteLog and "game_team_size=" .. tostring(game_team_size))
  local TableUtil = require("common.table_util")
  if game_team_size == 4 then
    local CurrentMapId = LoadingSystem.GetCurrentMapId()
    local TDRushHourMapIdArray = {
      98,
      99,
      121,
      122,
      123,
      124,
      125,
      126,
      127,
      128,
      130,
      131
    }
    local IsTDRushHour = TableUtil.Find(TDRushHourMapIdArray, CurrentMapId) > 0
    if IsTDRushHour then
      NLoadingModeIndex = 2
    else
      NLoadingModeIndex = 1
    end
  else
    NLoadingModeIndex = 0
  end
  if sub_mode ~= nil then
    local row_Info = CDataTable.GetTableData("BTMode", tostring(sub_mode))
    local map_id = 22
    if row_Info then
      map_id = tonumber(row_Info.MapID)
    else
      log(bWriteLog and "Error: FCFF IsClassicMode, Not exist in BTMode with row id = " .. tostring(sub_mode))
    end
    NLoadingUIIndex = -1
    if map_id == 22 then
      log(bWriteLog and "BP_TDMLoadingUI_Index=0")
      NLoadingUIIndex = 0
    elseif map_id == 27 then
      log(bWriteLog and "BP_TDMLoadingUI_Index=1")
      NLoadingUIIndex = 1
    elseif map_id == 43 then
      log(bWriteLog and "BP_TDMLoadingUI_Index=2")
      NLoadingUIIndex = 2
    elseif map_id == 61 then
      NLoadingUIIndex = 3
    elseif 0 < TableUtil.Find({
      86,
      87,
      96,
      97
    }, map_id) then
      NLoadingUIIndex = 4
    end
  end
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.CloseAchievementTip()
end
function TeamCompLoading.IsRank(subMode)
  log(bWriteLog and "TeamCompLoading.IsRank subMode = " .. subMode)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:GetSimpleViewInfoDictionary()
  local simpleView = logic_mode_selection:GetSimpleViewInfoDictionary()
  if not simpleView then
    log(bWriteLog and "TeamCompLoading.IsRank simpleView is nil")
    return false
  end
  local viewData = simpleView[subMode]
  if not viewData or not viewData.id then
    log(bWriteLog and "TeamCompLoading.IsRank viewData data is nil")
    return false
  end
  local viewTable = CDataTable.GetTableData("view_contain_table", viewData.id)
  if not viewTable then
    log(bWriteLog and "TeamCompLoading.IsRank viewTable data is nil")
    return false
  end
  log(bWriteLog and string.format("TeamCompLoading.IsRank tag_id = [%s]  is_rank = [%s]", viewTable.tag_id, viewTable.is_rank))
  if viewTable.tag_id == 130 or viewTable.is_rank == 2 then
    return true
  end
  return false
end
function TeamCompLoading.GetCacheRawData()
  return CacheRawData
end
function TeamCompLoading.ClearCacheRawData()
  CacheRawData = {}
  log(bWriteLog and "TeamCompLoading.ClearCacheRawData")
end
return TeamCompLoading