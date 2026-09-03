local esport_reddot_data = {}
local redpoint
local isInited = false
local ReddotType = {
  ApplyList = 1,
  GameStart = 2,
  Promotion = 3,
  Sponsor = 4,
  Bonus = 5,
  WeeklyAwards = 6
}
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.ESport,
    types = {
      newCount = 0,
      [ReddotType.ApplyList] = {
        newCount = 0,
        category = Category.Other,
        subID = 1
      },
      [ReddotType.GameStart] = {
        newCount = 0,
        subID = 2,
        category = Category.Other,
        instanceId = {_isLeaf = true}
      },
      [ReddotType.Promotion] = {
        newCount = 0,
        category = Category.Receive,
        subID = 3
      },
      [ReddotType.Sponsor] = {
        newCount = 0,
        pages = {
          newCount = 0,
          isDynamic = true,
          subPages = {newCount = 0, isDynamic = true}
        }
      },
      [ReddotType.Bonus] = {
        newCount = 0,
        category = Category.Other,
        subID = 5
      },
      [ReddotType.WeeklyAwards] = {
        newCount = 0,
        category = Category.Receive,
        subID = 6,
        instanceId = {_isLeaf = true}
      }
    }
  }
  return data
end
function esport_reddot_data.InitData()
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
end
function esport_reddot_data.OnLogin()
  log(bWriteLog and "esport_reddot_data OnLogin")
  esport_reddot_data.InitData()
end
function esport_reddot_data.OnLogout()
  log(bWriteLog and "esport_reddot_data OnLogout")
  esport_reddot_data.DestroyData()
end
function esport_reddot_data.DestroyData()
  redpoint = nil
  isInited = false
end
function esport_reddot_data.GetApplyRedPointData()
  if redpoint then
    return redpoint.types[ReddotType.ApplyList]
  end
end
function esport_reddot_data.UpdateApplyCount(count)
  if redpoint then
    redpoint.types[ReddotType.ApplyList].newCount = count
  end
end
function esport_reddot_data.SendRemoveApplyTlog()
end
function esport_reddot_data.GetGameStartRedDotData()
  if redpoint then
    return redpoint.types[ReddotType.GameStart]
  end
end
function esport_reddot_data.UpdateGameStartCount(isShow)
  if redpoint then
    local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
    local E_GameScheduleStage = ESportAllStarSystem.E_GameScheduleStage
    for i = E_GameScheduleStage.AllIn, E_GameScheduleStage.Final do
      if redpoint.types[ReddotType.GameStart].instanceId[i] then
        redpoint.types[ReddotType.GameStart].instanceId[i] = isShow
      end
    end
  end
end
function esport_reddot_data.UpdateGameStartStageCount(stage, isShow)
  if redpoint then
    redpoint.types[ReddotType.GameStart].instanceId[stage] = isShow
  end
end
function esport_reddot_data.SendRemoveGameStartTlog(instanceKey)
end
function esport_reddot_data.GetGameStartStageRedData(stage)
  if redpoint then
    return redpoint.types[ReddotType.GameStart].instanceId[stage]
  end
end
function esport_reddot_data.GetPromoteRedDotData()
  if redpoint then
    return redpoint.types[ReddotType.Promotion]
  end
end
function esport_reddot_data.UpdatePromoteCount(count)
  if redpoint then
    redpoint.types[ReddotType.Promotion].newCount = count
  end
end
function esport_reddot_data.SendRemovePromoteTlog()
end
function esport_reddot_data.GetSponsorRedDotData()
  if redpoint then
    return redpoint.types[ReddotType.Sponsor]
  end
end
function esport_reddot_data.UpdateSponsorCount()
  if redpoint then
    redpoint.types[ReddotType.Sponsor].newCount = 0
  end
end
function esport_reddot_data.SendRemoveSponsorTlog(instanceKey)
end
function esport_reddot_data.UpdateSponsorItemCount(pugId, count)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  if redpoint then
    redpoint.types[ReddotType.Sponsor].pages.subPages[pugId] = {
      newCount = count or 0,
      subID = 4,
      category = Category.Other
    }
  end
end
function esport_reddot_data.GetSponsorItemRedData(pugId)
  if redpoint then
    return redpoint.types[ReddotType.Sponsor].pages.subPages[pugId]
  end
end
function esport_reddot_data.GetData()
  return redpoint
end
function esport_reddot_data.GetBonusRedPointData()
  if redpoint then
    return redpoint.types[ReddotType.Bonus]
  end
end
function esport_reddot_data.UpdateBonusCount(count)
  if redpoint then
    redpoint.types[ReddotType.Bonus].newCount = count
  end
end
function esport_reddot_data.SendRemoveBonusTlog()
end
function esport_reddot_data.GetWeeklyAwardsRedDotData()
  if redpoint then
    return redpoint.types[ReddotType.WeeklyAwards]
  end
end
function esport_reddot_data.UpdateWeeklyAwardsCount(isShow)
  if redpoint then
    redpoint.types[ReddotType.WeeklyAwards].newCount = 0
    for i = 1, 2 do
      if redpoint.types[ReddotType.WeeklyAwards].instanceId[i] then
        redpoint.types[ReddotType.WeeklyAwards].instanceId[i] = isShow
      end
    end
  end
end
function esport_reddot_data.UpdateWeeklyAwardTypeCount(awardType, isShow)
  if redpoint then
    redpoint.types[ReddotType.WeeklyAwards].instanceId[awardType] = isShow
  end
end
function esport_reddot_data.GetWeeklyAwardTypeData(awardType)
  if redpoint then
    return redpoint.types[ReddotType.WeeklyAwards].instanceId[awardType]
  end
end
function esport_reddot_data.GetDescription(subID, instanceId)
  local msg = LocUtil.GetLocalizeResStr(12587)
  if subID == 1 then
    msg = LocUtil.GetLocalizeResStr(18835)
  elseif subID == 2 then
    msg = LocUtil.GetLocalizeResStr(18836)
  elseif subID == 3 then
    msg = LocUtil.GetLocalizeResStr(18837)
  elseif subID == 4 then
    local ChampionshipSponsorSystem = require("client.slua.logic.championship.logic_championship_sponsor")
    local statusInfo = ChampionshipSponsorSystem.GetPubStatus(instanceId)
    local round = statusInfo.Round or 0
    if round < 2 then
      msg = LocUtil.LocalizeResFormat(18838, instanceId)
    else
      msg = LocUtil.LocalizeResFormat(18839, instanceId, round)
    end
  elseif subID == 5 then
    msg = LocUtil.GetLocalizeResStr(18840)
  elseif subID == 6 then
    msg = LocUtil.GetLocalizeResStr(21165)
  end
  return msg
end
return esport_reddot_data