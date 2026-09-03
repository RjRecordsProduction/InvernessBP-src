local reddot_id = {
  corps_training = 1,
  corps_exchange = 2,
  corps_energy = 3,
  applicaton = 4,
  setting = 5,
  store_new = 6,
  welfare = 7,
  invite = 8,
  unlock = 9,
  corps_energy_new = 10,
  corps_fight_open = 11,
  corps_fight_daily = 12,
  corps_fight_occupy = 13,
  corps_fight_score = 14,
  corps_fight_reward = 15,
  type_change_enable = 17
}
local page_id = {
  home_panel = 1,
  info_panel = 2,
  store_panel = 3,
  suggestion_panel = 4,
  unlock_reddot = 6,
  EnergyMissionTab = 7,
  fight_panel = 8
}
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local page_id_config = {
  [page_id.home_panel] = {
    [1] = {
      id = reddot_id.corps_training,
      category = reddot_macro.Category.Receive
    },
    [2] = {
      id = reddot_id.corps_exchange,
      category = reddot_macro.Category.Receive
    },
    [3] = {
      id = reddot_id.welfare,
      category = reddot_macro.Category.Receive
    }
  },
  [page_id.info_panel] = {
    [1] = {
      id = reddot_id.applicaton,
      category = reddot_macro.Category.Other
    },
    [2] = {
      id = reddot_id.setting,
      category = reddot_macro.Category.Other
    },
    [3] = {
      id = reddot_id.type_change_enable,
      category = reddot_macro.Category.Other
    }
  },
  [page_id.store_panel] = {
    [1] = {
      id = reddot_id.store_new,
      category = reddot_macro.Category.NewArrivals
    }
  },
  [page_id.suggestion_panel] = {
    [1] = {
      id = reddot_id.invite,
      category = reddot_macro.Category.Other
    }
  },
  [page_id.unlock_reddot] = {
    [1] = {
      id = reddot_id.unlock,
      category = reddot_macro.Category.Other
    }
  },
  [page_id.EnergyMissionTab] = {
    [1] = {
      id = reddot_id.corps_energy,
      category = reddot_macro.Category.Receive
    },
    [2] = {
      id = reddot_id.corps_energy_new,
      category = reddot_macro.Category.Other
    }
  },
  [page_id.fight_panel] = {
    [1] = {
      id = reddot_id.corps_fight_open,
      category = reddot_macro.Category.Other
    },
    [2] = {
      id = reddot_id.corps_fight_daily,
      category = reddot_macro.Category.Other
    },
    [3] = {
      id = reddot_id.corps_fight_occupy,
      category = reddot_macro.Category.Receive
    },
    [4] = {
      id = reddot_id.corps_fight_score,
      category = reddot_macro.Category.Receive
    },
    [5] = {
      id = reddot_id.corps_fight_reward,
      category = reddot_macro.Category.Receive
    }
  }
}
local reddotCond
local InitRedDotCond = function(condName, func)
  reddotCond = {}
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local CorpsApplyListUILogic = require("client.slua.logic.corps.logic_corps_apply_list")
  local CorpsSuggestionSystem = require("client.slua.logic.corps.logic_corps_suggestion")
  local CorpsTrainingSystem = require("client.slua.logic.corps.logic_corps_training")
  local CorpsShopSystem = require("client.slua.logic.corps.logic_corps_shop")
  local LogicRedPoint = require("client.slua.logic.corps.logic_corps_red_point")
  local CorpGiftExchangeSystem = require("client.slua.logic.corps_gift_exchange.logic_corp_gift_exchange")
  reddotCond[reddot_id.applicaton] = function()
    return CorpsMgr.IsInCorps() and CorpsApplyListUILogic.HasRedPoint
  end
  reddotCond[reddot_id.corps_training] = function()
    return CorpsMgr.IsInCorps() and CorpsTrainingSystem.TrainRedPointIsShow
  end
  reddotCond[reddot_id.invite] = function()
    if LobbySystem.roleData.is_low_corps then
      return CorpsSuggestionSystem.hasNewIvitedCorps
    else
      return not CorpsMgr.IsInCorps() and CorpsSuggestionSystem.hasNewIvitedCorps
    end
  end
  reddotCond[reddot_id.store_new] = function()
    return CorpsMgr.IsInCorps() and CorpsShopSystem.HasNewOpenShopItem()
  end
  reddotCond[reddot_id.welfare] = function()
    local CorpsWelfareSystem = require("client.slua.logic.corps.logic_corps_welfare")
    if CorpsMgr.IsInCorps() and CorpsWelfareSystem.GetWelfareReceiveFlag() then
      return true
    end
    return false
  end
  reddotCond[reddot_id.unlock] = function()
    local limitLevel = CorpsMgr.GetConfigToNumber("CreateCorpsLevel") or 0
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local tab = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CorpsUnlockRedDot) or {}
    if limitLevel <= DataMgr.roleData.level and not tab.unlockMark then
      return true
    end
    return false
  end
  reddotCond[reddot_id.corps_exchange] = CorpGiftExchangeSystem.is_show_redPoint or false
  reddotCond[reddot_id.corps_energy] = LogicRedPoint.EnergyMissionReward
  reddotCond[reddot_id.corps_energy_new] = LogicRedPoint.EnergyMissionNew
  reddotCond[reddot_id.setting] = LogicRedPoint.ManageButtonRedPoint
  reddotCond[reddot_id.corps_fight_open] = LogicRedPoint.FightButtonOpenRedPoint
  reddotCond[reddot_id.corps_fight_daily] = LogicRedPoint.FightButtonDailyRedPoint
  reddotCond[reddot_id.corps_fight_occupy] = LogicRedPoint.FightButtonOccupyRedPoint
  reddotCond[reddot_id.corps_fight_score] = LogicRedPoint.FightButtonScoreRedPoint
  reddotCond[reddot_id.corps_fight_reward] = LogicRedPoint.FightButtonRewardRedPoint
  reddotCond[reddot_id.type_change_enable] = LogicRedPoint.TypeChangeEnableRedPoint
end
local CorpsRedPointData = {
  countFieldName = "newCount",
  desc = "corps",
  reddot_id = reddot_id,
  }
local isShowInLobby = false
local redPointDataCfg, corpsPageClickedInfo, superRedPoint
local isInited = false
local delegateContainer
local reddot_id2data = {}
local GenDefaultSubData = function(subID, category)
  local data = {
    newCount = 0,
    category = category,
      }
  return data
end
local GenPageData = function()
  local data = {
    newCount = 0,
    SubDatas = {newCount = 0}
  }
  return data
end
local GenerateData = function()
  local data = {
    newCount = 0,
    pages = {newCount = 0}
  }
  data.desc = CorpsRedPointData.desc
  return data
end
local ClearListeners = function()
  if delegateContainer then
    delegateContainer:Dispose()
    delegateContainer = nil
  end
end
function CorpsRedPointData.InitData()
  if isInited then
    return
  end
  log(bWriteLog and "CorpsRedPointData.InitData")
  isInited = true
  isShowInLobby = true
  ClearListeners()
  local delegate_container = require("common.delegate_container")
  delegateContainer = delegate_container()
  local super_data = require("common.super_data")
  local data = GenerateData()
  for id, config in pairs(page_id_config) do
    local PageData = GenPageData()
    data.pages[id] = PageData
    for _, reddot_config in ipairs(config) do
      local reddotData = GenDefaultSubData(reddot_config.id, reddot_config.category)
      PageData.SubDatas[reddot_config.id] = reddotData
      reddotData.pageIndex = id
    end
  end
  if superRedPoint == nil then
    superRedPoint = super_data.CreateSuperData(data)
    for id, config in pairs(page_id_config) do
      local PageData = superRedPoint.pages[id]
      for _, reddot_config in ipairs(config) do
        reddot_id2data[reddot_config.id] = PageData.SubDatas[reddot_config.id]
      end
    end
  else
    for k, v in pairs(data) do
      superRedPoint[k] = v
    end
  end
end
function CorpsRedPointData.OnLogin()
  log(bWriteLog and "CorpsRedPointData.OnLogin")
  CorpsRedPointData.InitData()
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  reddot_manager:Regist(superRedPoint)
  EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_CORPS)
end
function CorpsRedPointData.OnLogout()
  CorpsRedPointData.DestroyData()
end
function CorpsRedPointData.SetNewCount(dot_id, newCount)
  CorpsRedPointData.InitData()
  if superRedPoint then
    local data = reddot_id2data[dot_id]
    if 0 < dot_id and data then
      data.newCount = newCount or 0
      if isShowInLobby then
        CorpsRedPointData.RedPoitShowInLobby(dot_id, data, newCount)
      end
    end
  end
end
function CorpsRedPointData.UpdateRedDot(reddotid)
  if reddotCond == nil then
    InitRedDotCond()
  end
  local Cond = reddotCond[reddotid]
  if Cond then
    local isShow = Cond()
    CorpsRedPointData.SetNewCount(reddotid, isShow and 1 or 0)
  end
end
function CorpsRedPointData.UpdateLobbyRedDot()
  for _, id in pairs(reddot_id) do
    CorpsRedPointData.UpdateRedDot(id)
  end
end
function CorpsRedPointData.GetRedDotSuperData(cur_page_id)
  if cur_page_id == nil then
    return superRedPoint
  end
  return superRedPoint and superRedPoint.pages[cur_page_id]
end
function CorpsRedPointData.GetData()
  return superRedPoint
end
function CorpsRedPointData.DestroyData()
  superRedPoint = nil
  isInited = false
  redPointDataCfg = nil
  isShowInLobby = false
  corpsPageClickedInfo = nil
  reddot_id2data = {}
end
function CorpsRedPointData.GetCorpFightRedDotSuperData(id)
  local data = CorpsRedPointData.GetRedDotSuperData(page_id.fight_panel)
  return data.SubDatas[id]
end
function CorpsRedPointData.GetHomeRedDotData(id)
  local data = CorpsRedPointData.GetRedDotSuperData(page_id.home_panel)
  return data.SubDatas[id]
end
function CorpsRedPointData.GetInfoRedDotData(id)
  local data = CorpsRedPointData.GetRedDotSuperData(page_id.info_panel)
  return data.SubDatas[id]
end
function CorpsRedPointData.RedPoitShowInLobby(reddotID, data, newCount)
  local redPointNum = CorpsRedPointData.GetRedPointData(reddotID)
  redPointNum = tonumber(redPointNum)
  if redPointNum == newCount then
    return
  end
  CorpsRedPointData.SetRedPointData(reddotID, newCount, data.category)
  redPointNum = redPointNum or 0
  if newCount > redPointNum then
    local pageIndex = data.pageIndex
    CorpsRedPointData.ClearNormalPageRedPoint(pageIndex, false)
  end
end
function CorpsRedPointData.SetRedPointData(reddotID, newCount, category)
  log_format(bWriteLog and "CorpsRedPointData.SetRedPointData reddotID:%s newCount:%s Category:%s", tostring(reddotID), tostring(newCount), tostring(category))
  if not redPointDataCfg or not next(redPointDataCfg) then
    redPointDataCfg = {}
  end
  redPointDataCfg[reddotID] = {newCount = newCount, category = category}
end
function CorpsRedPointData.GetRedPointData(reddotID)
  local cfg = redPointDataCfg and redPointDataCfg[reddotID]
  if cfg and next(cfg) then
    return cfg.newCount, cfg.category
  end
end
function CorpsRedPointData.ClearNormalPageRedPoint(pageIndex, isClicked)
  log_format(bWriteLog and "CorpsRedPointData.ClearNormalPageRedPoint pageIndex:%s isShowInLobby:%s isClicked:%s ", tostring(pageIndex), tostring(isShowInLobby), tostring(isClicked))
  if isShowInLobby then
    pageIndex = tonumber(pageIndex)
    isClicked = isClicked and true or false
    if not pageIndex then
      log(bWriteLog and "CorpsRedPointData.ClearNormalPageRedPoint not pageIndex")
      return
    end
    if not corpsPageClickedInfo then
      corpsPageClickedInfo = {}
    end
    local hasClicked = corpsPageClickedInfo[pageIndex] or false
    if hasClicked == isClicked then
      log(bWriteLog and "CorpsRedPointData.ClearNormalPageRedPoint has set hasClicked:" .. tostring(hasClicked))
      return
    else
      corpsPageClickedInfo[pageIndex] = isClicked
      if isClicked then
        local showRedpoint = false
        for pageID, config in pairs(page_id_config) do
          if corpsPageClickedInfo[pageID] then
            for _, reddot_config in pairs(config) do
              if reddot_config.category == reddot_macro.Category.Receive then
                local newCount = CorpsRedPointData.GetRedPointData(reddot_config.id) or 0
                if 0 < newCount then
                  showRedpoint = true
                  break
                end
              end
            end
          else
            for _, reddot_config in pairs(config) do
              local newCount = CorpsRedPointData.GetRedPointData(reddot_config.id) or 0
              if 0 < newCount then
                showRedpoint = true
                break
              end
            end
          end
        end
        if not showRedpoint then
          local redpointData = CorpsRedPointData.GetData()
          redpointData.newCount = 0
        end
      end
    end
  end
end
return CorpsRedPointData