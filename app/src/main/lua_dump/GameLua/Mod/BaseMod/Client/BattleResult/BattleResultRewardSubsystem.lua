local BattleResultRewardSubsystem = {}
local RP_SCORE_ITEM_RES_ID = 1099
local BP_SCORE_ITEM_RES_ID = 1121
local DPA_DISCOVERY_POINT_RES_ID = 1323
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
function BattleResultRewardSubsystem:OnInit()
  print(bWriteLog and "BattleResultRewardSubsystem:OnInit")
  self.UICloseCb = nil
  self.CurRewardData = nil
  self.CurDisplayed = false
  self.RewardDataRequested = false
  self.achievementScore = 0
  self.DpaDisPointChange = 0
  self.DpaDisPointResId = DPA_DISCOVERY_POINT_RES_ID
  self.bHasReceivedRewardData = false
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_REWARD_UI_CLOSE, self.OnBattleResultRewardUIClose, self)
  if BattleResult and BattleResult.USE_TEST then
    self:InitTestData()
  end
  self:AddCommonEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_ADD_PACK_RESULT, self.OnCardCollectionBattleResultReward, self)
  self.CardCollectionMap = nil
end
function BattleResultRewardSubsystem:OnRelease()
  print(bWriteLog and "BattleResultRewardSubsystem:OnRelease")
  self.CurRewardData = nil
  self.RewardDataRequested = false
  self.CurDisplayed = false
  self.achievementScore = 0
  self.DpaDisPointChange = 0
  self.DpaDisPointResId = DPA_DISCOVERY_POINT_RES_ID
  self.UICloseCb = nil
  self.CardCollectionMap = nil
  BattleResultRewardSubsystem.__super.OnRelease(self)
end
function BattleResultRewardSubsystem:Send_battle_end_get_all_reward_req(resultData)
  log(bWriteLog and "BattleResultRewardSubsystem.Send_battle_end_get_all_reward_req RewardDataRequested:" .. tostring(self.RewardDataRequested))
  if not self.RewardDataRequested then
    self.RewardDataRequested = true
    if self:SkipBattleResult(resultData) then
      print(bWriteLog and "BattleResultRewardSubsystem:Send_battle_end_get_all_reward_req SkipBattleResult")
      return
    end
    local BattleResultHandler = require("client.network.Protocol.BattleResultHandler")
    BattleResultHandler.send_battle_end_get_all_reward_req(resultData.sub_mode)
  end
end
function BattleResultRewardSubsystem:CheckShowBattleResultRewardUI(closeCb, resultData)
  print(bWriteLog and "BattleResultRewardSubsystem:CheckShowBattleResultRewardUI CurDisplayed:" .. tostring(self.CurDisplayed), self.CurRewardData)
  if self:SkipBattleResult(resultData) then
    print(bWriteLog and "BattleResultRewardSubsystem:CheckShowBattleResultRewardUI SkipBattleResult")
    return false
  end
  if self.CurDisplayed then
    return false
  end
  if self.CurRewardData and UIManager and UIManager.ShowUI(UIManager.UI_Config_InGame.BattleResultReward_UIBP) then
    print(bWriteLog and "BattleResultRewardSubsystem:CheckShowBattleResultRewardUI Show Suc")
    EventSystem:postEventSafety(EVENTTYPE_INGAME, EVENTID_SHOW_OR_HIDE_DETIAL_VIEW, false)
    self.UICloseCb = closeCb
    self.CurDisplayed = true
    return true
  end
  return false
end
function BattleResultRewardSubsystem:BattleResultRewardDataHandle(reason, all_awards)
  print(bWriteLog and "BattleResultRewardSubsystem:BattleResultRewardDataHandle reason:" .. reason)
  log_tree("resRewardData:", all_awards)
  if reason ~= 0 then
    return
  end
  if all_awards.season_reward then
    for index, rewardInfo in pairs(all_awards.season_reward) do
      rewardInfo.res_id = rewardInfo.resid
      self:AddOneRewardData(UEnums.EResultRewardSourceType.SeasonReward, rewardInfo)
    end
  end
  local achievementScore = 0
  local AchieveRed = require("client.logic.achievement.achievement_red")
  if all_awards.achieve and AchieveRed then
    for index, onetask in pairs(all_awards.achieve) do
      for i, v in pairs(onetask.itemlist) do
        self:AddOneRewardData(UEnums.EResultRewardSourceType.AchieveReward, v)
      end
      local CfgData = CDataTable.GetTableData("AchievementCfg", onetask.id)
      if onetask.id and CfgData and CfgData.Score then
        achievementScore = achievementScore + CfgData.Score
      end
    end
  end
  if self.achievementScore == nil then
    self.achievementScore = 0
  end
  self.achievementScore = self.achievementScore + achievementScore
  if all_awards.achieve_record then
    for index, onetask in pairs(all_awards.achieve_record) do
      for i, v in pairs(onetask.itemlist) do
        self:AddOneRewardData(UEnums.EResultRewardSourceType.AchieveReward, v)
      end
    end
  end
  if all_awards.backuser_reward then
    for index, onetask in pairs(all_awards.backuser_reward) do
      for i, v in pairs(onetask.itemlist) do
        v.res_id = v.resid
        self:AddOneRewardData(UEnums.EResultRewardSourceType.BackUserReward, v)
      end
    end
  end
  if all_awards.level_task then
    local LevelTaskSystem = require("client.slua.logic.task.logic_level_task")
    if LevelTaskSystem then
      for _, onetask in pairs(all_awards.level_task) do
        if onetask[3] then
          for _, v in pairs(onetask[3]) do
            self:AddOneRewardData(UEnums.EResultRewardSourceType.LevelTaskReward, v)
          end
        end
      end
    else
      print(bWriteLog and "BattleResultRewardSubsystem:BattleResultRewardDataHandle LevelTaskSystem is nil")
    end
  end
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  if NewDayTaskSystem then
    local rpScoreReward = {
      res_id = RP_SCORE_ITEM_RES_ID,
      count = 0,
      valid_hours = 0
    }
    if all_awards.reward_score and 0 < all_awards.reward_score then
      rpScoreReward.count = rpScoreReward.count + all_awards.reward_score
    end
    local bpScoreReward = {
      res_id = BP_SCORE_ITEM_RES_ID,
      count = 0,
      valid_hours = 0
    }
    if all_awards.bp_reward_score and 0 < all_awards.bp_reward_score then
      bpScoreReward.count = bpScoreReward.count + all_awards.bp_reward_score
    end
    if all_awards.reward_id_list and #all_awards.reward_id_list >= 1 then
      for _, reward_id in ipairs(all_awards.reward_id_list) do
        local bShowReward = not NewDayTaskSystem.IsHideReward(reward_id)
        if bShowReward then
          local _, rewards = NewDayTaskSystem.GetTaskRewardCfg(reward_id)
          for _, reward in ipairs(rewards) do
            if reward.res_id ~= RP_SCORE_ITEM_RES_ID then
              self:AddOneRewardData(UEnums.EResultRewardSourceType.TaskReward, {
                res_id = reward.res_id,
                count = reward.res_num,
                valid_hours = reward.res_time_limit
              })
            end
          end
        end
      end
    end
    if 0 < rpScoreReward.count then
      self:AddOneRewardData(UEnums.EResultRewardSourceType.TaskReward, rpScoreReward)
    end
    if 0 < bpScoreReward.count then
      self:AddOneRewardData(UEnums.EResultRewardSourceType.TaskReward, bpScoreReward)
    end
    if all_awards.daily_login_reward_id then
      local _, rewards = NewDayTaskSystem.GetTaskRewardCfg(all_awards.daily_login_reward_id)
      for _, reward in ipairs(rewards) do
        self:AddOneRewardData(UEnums.EResultRewardSourceType.DailyLoginTaskReward, {
          res_id = reward.res_id,
          count = reward.res_num,
          valid_hours = reward.res_time_limit
        })
      end
    end
    if all_awards.daily_login_ext_res_map then
      for k, v in pairs(all_awards.daily_login_ext_res_map) do
        self:AddOneRewardData(UEnums.EResultRewardSourceType.TaskReward, {
          res_id = k,
          count = v,
          isTreasureBox = true
        })
      end
    end
  else
    print(bWriteLog and "BattleResultRewardSubsystem:BattleResultRewardDataHandle NewDayTaskSystem is nil")
  end
  if all_awards.mentor_reward then
    for index, onetask in pairs(all_awards.mentor_reward) do
      for i, v in pairs(onetask.itemlist) do
        v.res_id = v.resid
        self:AddOneRewardData(UEnums.EResultRewardSourceType.MentorReward, v)
      end
    end
  end
  if all_awards.ingame_redpack then
    for _, itemData in pairs(all_awards.ingame_redpack) do
      itemData.res_id = itemData.resid
      self:AddOneRewardData(UEnums.EResultRewardSourceType.RedpacketReward, itemData)
    end
  end
  if self.DpaDisPointChange and 0 < self.DpaDisPointChange then
    local ddPointReward = {
      res_id = self.DpaDisPointResId,
      count = self.DpaDisPointChange,
      valid_hours = 0
    }
    self:AddOneRewardData(UEnums.EResultRewardSourceType.DapDisPoint, ddPointReward)
    self.DpaDisPointChange = 0
  end
  self.bHasReceivedRewardData = true
end
function BattleResultRewardSubsystem:AddOneRewardData(rewardSource, new)
  if self.CurRewardData == nil then
    self.CurRewardData = {}
  end
  local award_table = self.CurRewardData[rewardSource]
  if award_table == nil then
    award_table = {}
    self.CurRewardData[rewardSource] = award_table
  end
  local Has = award_table[new.res_id]
  new.valid_hours = new.valid_hours or 0
  new.expire_ts = new.expire_ts or 0
  if Has and Has.valid_hours == new.valid_hours and Has.expire_ts == new.expire_ts then
    Has.count = Has.count + new.count
  else
    award_table[new.res_id] = new
  end
end
function BattleResultRewardSubsystem:OnDpaDiscoveryPointChange(point_change, explore_item_id)
  print(bWriteLog and "BattleResultRewardSubsystem:OnDpaDiscoveryPointChange point_change:" .. tostring(point_change) .. " explore_item_id:" .. tostring(explore_item_id))
  if self.bHasReceivedRewardData then
    local ddPointReward = {
      res_id = explore_item_id,
      count = point_change,
      valid_hours = 0
    }
    self:AddOneRewardData(UEnums.EResultRewardSourceType.DapDisPoint, ddPointReward)
  else
    self.DpaDisPointChange = point_change
    self.DpaDisPointResId = explore_item_id
  end
end
function BattleResultRewardSubsystem:GetCurBattleResultRewardData()
  print(bWriteLog and "BattleResultRewardSubsystem:GetCurBattleResultRewardData")
  log_tree("BattleResultRewardSubsystem:GetCurBattleResultRewardData self.CurRewardData:", self.CurRewardData)
  return self.CurRewardData
end
function BattleResultRewardSubsystem:GetCardCollectionMap()
  print(bWriteLog and "BattleResultRewardSubsystem:GetCardCollectionMap")
  log_tree("BattleResultRewardSubsystem:GetCardCollectionMap self.CardCollectionMap:", self.CardCollectionMap)
  return self.CardCollectionMap
end
function BattleResultRewardSubsystem:GetCurBattleResultRewardDataWithCardCollection()
  print(bWriteLog and "BattleResultRewardSubsystem:GetCurBattleResultRewardDataWithCardCollection")
  if not self.CardCollectionMap or not next(self.CardCollectionMap) then
    print(bWriteLog and "BattleResultRewardSubsystem:GetCurBattleResultRewardDataWithCardCollection CardCollectionMap is nil")
    return self.CurRewardData
  end
  if not self.CurRewardData then
    print(bWriteLog and "BattleResultRewardSubsystem:GetCurBattleResultRewardDataWithCardCollection CurRewardData is nil")
    return nil
  end
  local TaskRewardData = self.CurRewardData[UEnums.EResultRewardSourceType.TaskReward]
  if not TaskRewardData then
    print(bWriteLog and "BattleResultRewardSubsystem:GetCurBattleResultRewardDataWithCardCollection TaskRewardData is nil")
    return self.CurRewardData
  end
  local ToRemove = {}
  local ToAdd = {}
  for ResId in pairs(TaskRewardData) do
    local Pack = self.CardCollectionMap[ResId]
    if Pack then
      ToRemove[#ToRemove + 1] = ResId
      for _, CardItem in pairs(Pack.card_list or {}) do
        ToAdd[#ToAdd + 1] = CardItem
      end
    end
  end
  for _, ResId in ipairs(ToRemove) do
    TaskRewardData[ResId] = nil
  end
  for _, CardItem in ipairs(ToAdd) do
    local ValidHours = CardItem.valid_hours or 0
    local ExpireTs = CardItem.expire_ts or 0
    local Existing = TaskRewardData[CardItem.res_id]
    if Existing and Existing.valid_hours == ValidHours and Existing.expire_ts == ExpireTs then
      Existing.count = Existing.count + CardItem.count
    else
      TaskRewardData[CardItem.res_id] = {
        res_id = CardItem.res_id,
        count = CardItem.count,
        valid_hours = ValidHours,
        expire_ts = ExpireTs
      }
    end
  end
  log_tree("BattleResultRewardSubsystem:GetCurBattleResultRewardDataWithCardCollection self.CurRewardData:", self.CurRewardData)
  return self.CurRewardData
end
function BattleResultRewardSubsystem:GetCurBattleResultAchSocreData()
  print(bWriteLog and "BattleResultRewardSubsystem:GetCurBattleResultAchSocreData")
  return self.achievementScore
end
function BattleResultRewardSubsystem:SkipBattleResult(resultData)
  if resultData == nil then
    print(bWriteLog and "BattleResultRewardSubsystem:SkipBattleResult resultData is null")
    return true
  end
  print(bWriteLog and "BattleResultRewardSubsystem:SkipBattleResult modeId:" .. tostring(resultData.sub_mode) .. " battle_owner:" .. tostring(resultData.battle_owner))
  if resultData.battle_owner ~= 0 then
    return true
  end
  if not ResultUtil.CheckResultProSwitch(resultData.sub_mode, ResultUtil.SwitchKey.ResultRewardSwitch) then
    return true
  end
  return false
end
function BattleResultRewardSubsystem:OnBattleResultRewardUIClose()
  print(bWriteLog and "BattleResultRewardSubsystem:OnBattleResultRewardUIClose")
  if self.UICloseCb then
    self.UICloseCb()
  end
end
function BattleResultRewardSubsystem:OnCardCollectionBattleResultReward(_, __, card_pack_id, card_pack_count, card_list, reason, subreason)
  print(bWriteLog and "BattleResultRewardSubsystem:OnCardCollectionBattleResultReward")
  if tonumber(reason) ~= 1002 then
    return
  end
  if self.CardCollectionMap == nil then
    self.CardCollectionMap = {}
  end
  self.CardCollectionMap[card_pack_id] = {
    card_pack_id = card_pack_id,
    card_pack_count = card_pack_count,
      }
end
function BattleResultRewardSubsystem:InitTestData()
  print(bWriteLog and "BattleResultRewardSubsystem:InitTestData")
  local resRewardData = {
    achieve_record = {
      {
        record_id = 1,
        itemlist = {
          {res_id = 1000, count = 3000}
        }
      },
      {
        record_id = 2,
        itemlist = {
          {res_id = 1001, count = 30}
        }
      }
    },
    daily_login_reward_id = 403,
    reward_id_list = {
      {2001}
    },
    reward_score = 300,
    reward_id_list_2 = {
      {2001}
    },
    weekly_task = {},
    achieve = {
      {
        id = 20160,
        itemlist = {
          {res_id = 1532021, count = 1}
        }
      },
      {
        id = 20161,
        itemlist = {
          {res_id = 1532022, count = 3}
        }
      },
      {
        id = 20200,
        itemlist = {
          {res_id = 1000, count = 1000}
        }
      },
      {
        id = 20200,
        itemlist = {
          {res_id = 1532025, count = 3}
        }
      }
    },
    level_task = {
      {
        4,
        0,
        {
          {
            valid_hours = 0,
            res_id = 1000,
            expire_ts = 0,
            count = 100
          }
        }
      },
      {
        2,
        0,
        {
          {
            valid_hours = 0,
            res_id = 1000,
            expire_ts = 0,
            count = 100
          }
        }
      },
      {
        3,
        0,
        {
          {
            valid_hours = 0,
            res_id = 1000,
            expire_ts = 0,
            count = 100
          }
        }
      }
    },
    backuser_reward = {
      {
        id = 1,
        itemlist = {
          {
            resid = 1101001136,
            count = 1,
            valid_hours = 72
          }
        }
      }
    },
    mentor_reward = {
      {
        id = 3001,
        itemlist = {
          {count = 3, resid = 1532025}
        }
      },
      {
        id = 3002,
        itemlist = {
          {count = 2, resid = 1532021}
        }
      }
    },
    season_reward = {
      {
        valid_hours = 0,
        resid = 1109,
        count = 35
      },
      {
        valid_hours = 0,
        resid = 1532025,
        count = 3
      },
      {
        valid_hours = 0,
        resid = 1109,
        count = 40
      },
      {
        valid_hours = 0,
        resid = 1532025,
        count = 35
      },
      {
        valid_hours = 0,
        resid = 1501000258,
        count = 35
      },
      {
        valid_hours = 0,
        resid = 1501000259,
        count = 35
      }
    }
  }
  self:BattleResultRewardDataHandle(0, resRewardData)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, BattleResultRewardSubsystem)