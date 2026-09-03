local season_redpoint_data = {}
local redpoint
local isInited = false
local ReddotType = {
  reward = 1,
  newSeasonFile = 2,
  LBSZoneSet = 3,
  cycleReward = 4,
  cycleYear = 5,
  newTitle = 6,
  cycleMemory = 7,
  cycleMemoryTab = 8,
  cycleMemoryNewSeason = 9,
  newReward = 10,
  segReward = 11,
  shopExchange = 12,
  lookback = 13,
  classicSeasonEntry = 14,
  leisureSeasonEntry = 15,
  peakGameSeasonEntry = 16,
  peakGameSeasonReward = 17,
  peakGameSegReward = 18,
  peakGameNewSeason = 19,
  leisureSeasonTaskAward = 20,
  leisureSeasonSegmentAward = 21,
  leisureSeasonFirstLogin = 22,
  classicNormalSegmentReward = 23,
  classicDoubleSeasonReward = 24,
  peakGameWonderfulPlayBack = 25,
  classicSegTargetEntry = 26,
  classicSegTarget = 27,
  classicProgressReward = 28,
  classicSwitchForReturn = 29,
  seasonYearEntry = 30,
  seasonYearTask = 31,
  seasonYearRankTask = 32,
  seasonYearTrialMission = 33,
  promotionNewSeasonStart = 34,
  promotionUnlockNewLevel = 35,
  seasonYearFirstOpen = 36,
  seasonYearBadge = 37,
  expand = 38,
  expandCycleReward = 39,
  seasonCombReward = 40
}
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.Season,
    types = {
      newCount = 0,
      [ReddotType.seasonCombReward] = {
        newCount = 0,
        category = Category.Receive,
        subID = 40,
        types = {
          newCount = 0,
          [ReddotType.classicSeasonEntry] = {
            newCount = 0,
            category = Category.Receive,
            subID = 14,
            types = {
              newCount = 0,
              [ReddotType.reward] = {
                newCount = 0,
                category = Category.Receive,
                subID = 1
              },
              [ReddotType.cycleYear] = {
                newCount = 0,
                category = Category.Receive,
                subID = 5,
                types = {
                  newCount = 0,
                  [ReddotType.newSeasonFile] = {
                    newCount = 0,
                    category = Category.NewArrivals,
                    subID = 2,
                    instanceId = {_isLeaf = true}
                  },
                  [ReddotType.cycleReward] = {
                    newCount = 0,
                    category = Category.Receive,
                    subID = 4,
                    instanceId = {_isLeaf = true}
                  },
                  [ReddotType.cycleMemory] = {
                    newCount = 0,
                    category = Category.Receive,
                    subID = 7,
                    types = {
                      newCount = 0,
                      [ReddotType.cycleMemoryTab] = {
                        newCount = 0,
                        category = Category.Receive,
                        subID = 8,
                        instanceId = {_isLeaf = true}
                      },
                      [ReddotType.cycleMemoryNewSeason] = {
                        newCount = 0,
                        category = Category.NewArrivals,
                        subID = 9,
                        instanceId = {_isLeaf = true}
                      }
                    }
                  }
                }
              },
              [ReddotType.newReward] = {
                newCount = 0,
                category = Category.Receive,
                subID = 10,
                types = {
                  newCount = 0,
                  [ReddotType.segReward] = {
                    newCount = 0,
                    category = Category.Receive,
                    subID = 11,
                    types = {
                      newCount = 0,
                      [ReddotType.classicNormalSegmentReward] = {
                        newCount = 0,
                        category = Category.Receive,
                        subID = 23,
                        instanceId = {_isLeaf = true}
                      },
                      [ReddotType.classicDoubleSeasonReward] = {
                        newCount = 0,
                        category = Category.Receive,
                        subID = 24,
                        instanceId = {_isLeaf = true}
                      }
                    }
                  }
                }
              },
              [ReddotType.shopExchange] = {
                newCount = 0,
                category = Category.Others,
                subID = 12
              },
              [ReddotType.expand] = {
                newCount = 0,
                category = Category.NewArrivals,
                subID = 38,
                types = {
                  newCount = 0,
                  [ReddotType.lookback] = {
                    newCount = 0,
                    category = Category.NewArrivals,
                    subID = 13
                  },
                  [ReddotType.expandCycleReward] = {
                    newCount = 0,
                    category = Category.Receive,
                    subID = 39,
                    instanceId = {_isLeaf = true}
                  }
                }
              },
              [ReddotType.classicSegTargetEntry] = {
                newCount = 0,
                category = Category.Receive,
                subID = 26,
                types = {
                  newCount = 0,
                  [ReddotType.classicSegTarget] = {
                    newCount = 0,
                    category = Category.Receive,
                    subID = 27,
                    instanceId = {_isLeaf = true}
                  },
                  [ReddotType.classicProgressReward] = {
                    newCount = 0,
                    category = Category.Receive,
                    subID = 28,
                    instanceId = {_isLeaf = true}
                  }
                }
              },
              [ReddotType.classicSwitchForReturn] = {
                newCount = 0,
                category = Category.NewArrivals,
                subID = 29
              },
              [ReddotType.promotionNewSeasonStart] = {
                newCount = 0,
                category = Category.NewArrivals,
                subID = 34
              },
              [ReddotType.promotionUnlockNewLevel] = {
                newCount = 0,
                category = Category.NewArrivals,
                subID = 35
              }
            }
          },
          [ReddotType.leisureSeasonEntry] = {
            newCount = 0,
            category = Category.Receive,
            subID = 15,
            types = {
              newCount = 0,
              [ReddotType.leisureSeasonTaskAward] = {
                newCount = 0,
                category = Category.Receive,
                subID = 20,
                instanceId = {_isLeaf = true}
              },
              [ReddotType.leisureSeasonSegmentAward] = {
                newCount = 0,
                category = Category.Receive,
                subID = 21,
                instanceId = {_isLeaf = true}
              },
              [ReddotType.leisureSeasonFirstLogin] = {
                newCount = 0,
                category = Category.Other,
                subID = 22,
                instanceId = {_isLeaf = true}
              }
            }
          },
          [ReddotType.peakGameSeasonEntry] = {
            newCount = 0,
            category = Category.Receive,
            subID = 16,
            types = {
              newCount = 0,
              [ReddotType.peakGameSeasonReward] = {
                newCount = 0,
                category = Category.Receive,
                subID = 17,
                types = {
                  newCount = 0,
                  [ReddotType.peakGameSegReward] = {
                    newCount = 0,
                    category = Category.Receive,
                    subID = 18,
                    instanceId = {_isLeaf = true}
                  }
                }
              },
              [ReddotType.peakGameNewSeason] = {
                newCount = 0,
                category = Category.Other,
                subID = 19,
                instanceId = {_isLeaf = true}
              },
              [ReddotType.peakGameWonderfulPlayBack] = {
                newCount = 0,
                category = Category.Other,
                subID = 25,
                instanceId = {_isLeaf = true}
              }
            }
          }
        }
      },
      [ReddotType.seasonYearEntry] = {
        newCount = 0,
        category = Category.Receive,
        subID = 30,
        types = {
          newCount = 0,
          [ReddotType.seasonYearTask] = {
            newCount = 0,
            category = Category.Receive,
            subID = 31,
            types = {
              newCount = 0,
              [ReddotType.seasonYearRankTask] = {
                newCount = 0,
                category = Category.Receive,
                subID = 32,
                instanceId = {_isLeaf = true}
              },
              [ReddotType.seasonYearTrialMission] = {
                newCount = 0,
                category = Category.Receive,
                subID = 33,
                instanceId = {_isLeaf = true}
              }
            }
          },
          [ReddotType.seasonYearFirstOpen] = {
            newCount = 0,
            category = Category.NewArrivals,
            subID = 36
          },
          [ReddotType.seasonYearBadge] = {
            newCount = 0,
            category = Category.Receive,
            subID = 37,
            instanceId = {_isLeaf = true}
          }
        }
      }
    }
  }
  return data
end
function season_redpoint_data.InitData()
  if isInited then
    return
  end
  isInited = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if redpoint == nil then
    redpoint = super_data.CreateSuperData(data)
  end
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  reddot_manager:Regist(redpoint)
  season_redpoint_data.RefreshSeasonSegmentProgressReddot()
  season_redpoint_data.CheckNeedReqSeasonSummaryReddot()
  season_redpoint_data.RefreshPromotionNewSeasonStart()
  season_redpoint_data.RefreshPromotionNewSeasonUnlock()
  season_redpoint_data.RefreshSeasonYearFirstEnter()
  EventSystem:registEvent(EVENTTYPE_SEASON_REVIEW, EVENTID_SEASON_REVIEW_SUMMARY_FILE_REDDOT, season_redpoint_data.OnGetReviewSummaryFile)
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, season_redpoint_data.OnRefreshSeasonShopReddot)
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, season_redpoint_data.RefreshSeasonShopReddot)
end
function season_redpoint_data.CheckNeedReqSeasonSummaryReddot()
  log(bWriteLog and "season_redpoint_data.CheckNeedReqSeasonSummaryReddot")
  local seasonId = DataMgr.season_id
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local sdata = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.newSeasonRedDotFlag) or {}
  if sdata and sdata[seasonId] == nil then
    log(bWriteLog and "season_redpoint_data.CheckNeedReqSeasonSummaryReddot send_get_season_file_reddot_req")
    local SeasonHandler = require("client.network.Protocol.SeasonHandler")
    SeasonHandler.send_get_season_file_reddot_req()
  end
  log(bWriteLog and "season_redpoint_data.CheckNeedReqSeasonSummaryReddot done")
end
function season_redpoint_data.OnGetReviewSummaryFile()
  log(bWriteLog and "season_redpoint_data.OnGetReviewSummaryFile")
  season_redpoint_data.SetRedByType(ReddotType.newSeasonFile, 1)
end
function season_redpoint_data.OnRefreshSeasonShopReddot(_, __, changeList)
  if changeList == nil or not next(changeList) then
    log(bWriteLog and "OnRefreshSeasonShopReddot changeList is nil")
    return
  end
  local bSeasonCoinChanged = false
  for i, v in pairs(changeList) do
    if v.res_id == 1702156 then
      bSeasonCoinChanged = true
      break
    end
  end
  if bSeasonCoinChanged then
    log(bWriteLog and "OnRefreshSeasonShopReddot bSeasonCoinChanged is " .. tostring(bSeasonCoinChanged))
    season_redpoint_data.RefreshSeasonShopReddot()
  end
end
function season_redpoint_data.OnLogin()
  season_redpoint_data.InitData()
  local logic_season_cycle_award = require("client.logic.season.logic_season_cycle_award")
  logic_season_cycle_award.send_get_season_year_reward_redpot_req()
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  log(bWriteLog and "[v_ywuyuan] OnLogin.send_get_task_state_list")
  SeasonHandler.send_get_task_state_list()
  if DataMgr and DataMgr.roleData then
    local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
    local lookbackSeasonId = logic_season_lookback:GetLookBackSeasonId()
    logic_season_lookback:send_get_season_lookback_data_req(DataMgr.roleData.uid, lookbackSeasonId)
  end
  season_redpoint_data.RefreshSeasonShopReddot()
  local peakgame_reddot_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.peakgame_reddot_util)
  peakgame_reddot_util:OnLoginSuccess()
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnRedDataReady()
end
function season_redpoint_data.OnLogout()
  season_redpoint_data.DestroyData()
end
function season_redpoint_data.DestroyData()
  redpoint = nil
  isInited = false
  EventSystem:unregistEvent(EVENTTYPE_SEASON_REVIEW, EVENTID_SEASON_REVIEW_SUMMARY_FILE_REDDOT, season_redpoint_data.OnGetReviewSummaryFile)
  EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, season_redpoint_data.OnRefreshSeasonShopReddot)
  EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, season_redpoint_data.RefreshSeasonShopReddot)
end
function season_redpoint_data.SetRedByType(_reddotType, count)
  log(bWriteLog and "season_redpoint_data.SetRedByType _reddotType = " .. tostring(_reddotType) .. " count = " .. tostring(count))
  if redpoint then
    if redpoint.types[_reddotType] then
      redpoint.types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[_reddotType] then
      redpoint.types[ReddotType.seasonCombReward].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[_reddotType] then
      redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.cycleYear].types[_reddotType] then
      redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.cycleYear].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.expand].types[_reddotType] then
      redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.expand].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.newReward].types[_reddotType] then
      redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.newReward].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.newReward].types[ReddotType.segReward].types[_reddotType] then
      redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.newReward].types[ReddotType.segReward].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.classicSegTargetEntry].types[_reddotType] then
      redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.classicSegTargetEntry].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonYearEntry].types[_reddotType] then
      redpoint.types[ReddotType.seasonYearEntry].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonYearEntry].types[ReddotType.seasonYearTask].types[_reddotType] then
      redpoint.types[ReddotType.seasonYearEntry].types[ReddotType.seasonYearTask].types[_reddotType].newCount = count
    end
  end
end
function season_redpoint_data.GetRedByType(_reddotType)
  log(bWriteLog and "season_redpoint_data.GetRedByType _reddotType = " .. tostring(_reddotType))
  if redpoint then
    return redpoint.types[_reddotType] or redpoint.types[ReddotType.seasonCombReward].types[_reddotType] or redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[_reddotType] or redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.cycleYear].types[_reddotType] or redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.expand].types[_reddotType] or redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.newReward].types[_reddotType] or redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.newReward].types[ReddotType.segReward].types[_reddotType] or redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.classicSegTargetEntry].types[_reddotType] or redpoint.types[ReddotType.seasonYearEntry].types[_reddotType] or redpoint.types[ReddotType.seasonYearEntry].types[ReddotType.seasonYearTask].types[_reddotType]
  end
end
function season_redpoint_data.GetRedData(count)
  return redpoint
end
function season_redpoint_data.UpdateNewSeasonFileRedDot()
  if redpoint and redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.cycleYear].types[ReddotType.newSeasonFile].newCount > 0 then
    local seasonId = DataMgr.season_id
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local sdata = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.newSeasonRedDotFlag) or {}
    sdata[seasonId] = true
    PlayerPrefsSystem.SaveTableToFile_N(sdata, PlayerPrefsSystem.ePlayerPrefsType.newSeasonRedDotFlag)
    season_redpoint_data.SetRedByType(ReddotType.newSeasonFile, 0)
  end
end
function season_redpoint_data.SetNewCycleRewardNumRedDot(count)
  if not redpoint then
    return
  end
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local isOpen = season_year_util.CheckCycleIsOpen()
  if isOpen then
    redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.cycleYear].types[ReddotType.cycleReward].newCount = count
    redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.expand].types[ReddotType.expandCycleReward].newCount = count
  else
    redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.cycleYear].types[ReddotType.cycleReward].newCount = 0
    redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.expand].types[ReddotType.expandCycleReward].newCount = 0
  end
end
function season_redpoint_data.ResetCycleAwardRed()
  if not redpoint then
    return
  end
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local isOpen = season_year_util.CheckCycleIsOpen()
  if not isOpen then
    redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.cycleYear].types[ReddotType.cycleReward].newCount = 0
    redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.expand].types[ReddotType.expandCycleReward].newCount = 0
  end
end
function season_redpoint_data.GetCycleMemoryData()
  return season_redpoint_data.GetRedByType(ReddotType.cycleMemory)
end
function season_redpoint_data.GetCycleMemoryTabRedData()
  if not redpoint then
    log(bWriteLog and "GetCycleMemoryTabRedData redPoint is nil")
    return
  end
  local memoryRed = season_redpoint_data.GetRedByType(ReddotType.cycleMemory)
  if memoryRed == nil then
    log(bWriteLog and "GetCycleMemoryTabRedData memory Redpoint data is nil")
    return
  end
  return memoryRed.types[ReddotType.cycleMemoryTab]
end
function season_redpoint_data.SetCycleMemoryEntryRedData(ifShow)
  if not redpoint then
    log(bWriteLog and "season redpoint data SetCycleMemoryEntryRedData redPoint is nil")
    return
  end
  local memoryRed = season_redpoint_data.GetRedByType(ReddotType.cycleMemory)
  if memoryRed == nil then
    log(bWriteLog and "season redpoint data SetCycleMemoryEntryRedData memory Redpoint data is nil")
    return
  end
  if ifShow then
    memoryRed.types[ReddotType.cycleMemoryNewSeason].newCount = 1
  else
    memoryRed.types[ReddotType.cycleMemoryNewSeason].newCount = 0
  end
end
function season_redpoint_data.SetCycleMemoryTabRedData(count)
  if not redpoint or not count then
    log(bWriteLog and "season redpoint data SetCycleMemoryTabRedData redPoint or count is nil")
    return
  end
  redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.cycleYear].types[ReddotType.cycleMemory].types[ReddotType.cycleMemoryTab].newCount = count
end
function season_redpoint_data.CollectOneCycleMemoryRedDot()
  if not redpoint then
    log(bWriteLog and "CollectOneCycleMemoryRedDot redPoint is nil")
    return
  end
  local memoryRed = season_redpoint_data.GetRedByType(ReddotType.cycleMemory)
  if memoryRed == nil then
    log(bWriteLog and "CollectOneCycleMemoryRedDot memory Redpoint data is nil")
    return
  end
  local cycleMemoryTabCount = memoryRed.types[ReddotType.cycleMemoryTab].newCount
  memoryRed.types[ReddotType.cycleMemoryTab].newCount = cycleMemoryTabCount - 1
end
function season_redpoint_data.RefreshSeasonShopReddot()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local count = wardrobe_data:GetHallDepotItemCountByResID(1702156)
  log(bWriteLog and "RefreshSeasonShopReddot seasonCoin count = " .. tostring(count))
  season_redpoint_data.ResetCycleAwardRed()
  local logic_season_shop_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_shop_system)
  local minPrice = logic_season_shop_system:GetMinPrice()
  if minPrice == nil then
    log(bWriteLog and "RefreshSeasonShopReddot minPrice is nil")
    return
  end
  if count >= minPrice then
    if DataMgr == nil or DataMgr.season_id == nil or DataMgr.season_id <= 23 then
      log(bWriteLog and "RefreshSeasonShopReddot season_id = " .. tostring(DataMgr.season_id))
      return
    end
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local flagTab = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonShopReddot)
    if flagTab and flagTab.isShow and flagTab.isShow == 1 then
      log(bWriteLog and "RefreshSeasonShopReddot flagTab.isShow == 1")
      return
    end
    season_redpoint_data.SetRedByType(ReddotType.shopExchange, 1)
  end
end
function season_redpoint_data.DestroySeasonShopReddot()
  if redpoint and redpoint.types[ReddotType.seasonCombReward].types[ReddotType.classicSeasonEntry].types[ReddotType.shopExchange].newCount > 0 then
    local flagTab = {isShow = 1}
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N(flagTab, PlayerPrefsSystem.ePlayerPrefsType.eSeasonShopReddot)
    season_redpoint_data.SetRedByType(ReddotType.shopExchange, 0)
  end
end
function season_redpoint_data.SetLookbackEntryRedData(ifShow)
  if not redpoint then
    log(bWriteLog and "season redpoint data SetLookbackEntryRedData redPoint is nil")
    return
  end
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  if logic_season_lookback:GetEntranceSwitch() and ifShow then
    season_redpoint_data.SetRedByType(ReddotType.lookback, 1)
  else
    season_redpoint_data.SetRedByType(ReddotType.lookback, 0)
  end
end
function season_redpoint_data.RefreshSeasonSegmentProgressReddot()
  local segment_progress_goal = LobbySystem.roleData.segment_progress_goal
  local logic_season_segment_target = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_segment_target)
  logic_season_segment_target:UpdateProgressReward(segment_progress_goal)
end
function season_redpoint_data.RefreshClassicSwitchForReturnReddot()
  local canSlap = false
  if DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.quick_battle_switch then
    local logic_season_switch_slap = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_switch_slap)
    canSlap = logic_season_switch_slap:CheckShouldSlap()
  end
  local redPoint = canSlap and 1 or 0
  season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.classicSwitchForReturn, redPoint)
end
function season_redpoint_data.RefreshPromotionNewSeasonStart()
  local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
  local redPoint = 0
  if logic_promotion_homepage:NeedPromotionRewardGuide() then
    redPoint = 1
  end
  season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.promotionNewSeasonStart, redPoint)
end
function season_redpoint_data.RefreshPromotionNewSeasonUnlock()
  local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
  local redPoint = 0
  if logic_promotion_homepage:NeedShowFirstEffect() then
    redPoint = 1
  end
  season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.promotionNewSeasonUnlock, redPoint)
end
function season_redpoint_data.UpdateSeasonYearRankTaskRedpoint()
  local logic_season_year_rank_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_rank_task)
  local rankTaskData = logic_season_year_rank_task:GetRankTaskData()
  local redPoint = 0
  local ERankTaskStatus = require("client.logic.season_year.config.season_year_config").ERankTaskStatus
  for k, v in pairs(rankTaskData) do
    if v.status == ERankTaskStatus.NotReceived then
      redPoint = redPoint + 1
    end
  end
  season_redpoint_data.SetRedByType(ReddotType.seasonYearRankTask, redPoint)
end
function season_redpoint_data.GetSeasonYearRankTaskRedpointData()
  return season_redpoint_data.GetRedByType(ReddotType.seasonYearRankTask)
end
function season_redpoint_data.UpdateSeasonYearTrialMissionRedpoint()
  local logic_season_year_trial_mission = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_trial_mission)
  local redPoint = logic_season_year_trial_mission:GetReddotCount()
  season_redpoint_data.SetRedByType(ReddotType.seasonYearTrialMission, redPoint)
end
function season_redpoint_data.UpdateSeasonYearBadgeRedpoint()
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  local badgeTaskData = logic_season_year_badge:GetCurSeasonYearTaskInfo()
  local redPoint = 0
  local ERankTaskStatus = require("client.logic.season_year.config.season_year_config").ERankTaskStatus
  for k, v in pairs(badgeTaskData) do
    if v.status == ERankTaskStatus.NotReceived then
      redPoint = redPoint + 1
    end
  end
  season_redpoint_data.SetRedByType(ReddotType.seasonYearBadge, redPoint)
end
function season_redpoint_data.GetSeasonYearTrialMissionRedpointData()
  return season_redpoint_data.GetRedByType(ReddotType.seasonYearTrialMission)
end
function season_redpoint_data.GetSeasonYearTaskData()
  return season_redpoint_data.GetRedByType(ReddotType.seasonYearTask)
end
function season_redpoint_data.GetSeasonYearRedpointData()
  return season_redpoint_data.GetRedByType(ReddotType.seasonYearEntry)
end
function season_redpoint_data.GetSeasonCombRedpointData()
  return season_redpoint_data.GetRedByType(ReddotType.seasonCombReward)
end
function season_redpoint_data.RefreshSeasonYearFirstEnter()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  if season_year_util.CheckFunctionIsOpen() then
    local season_year_store_util = require("client.logic.season_year.util.season_year_store_util")
    local file = season_year_store_util.LoadFile()
    if not file or not file.bIsFirstOpen then
      season_redpoint_data.SetRedByType(ReddotType.seasonYearFirstOpen, 1)
    else
      season_redpoint_data.SetRedByType(ReddotType.seasonYearFirstOpen, 0)
    end
  end
end
function season_redpoint_data.GetSeasonYearBadgeRedpointData()
  return season_redpoint_data.GetRedByType(ReddotType.seasonYearBadge)
end
season_redpoint_data.return season_redpoint_data