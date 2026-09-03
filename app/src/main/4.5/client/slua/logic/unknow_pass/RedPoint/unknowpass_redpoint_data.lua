local UnknowPassRedPointData = {}
local redpoint
local isInited = false
local delegateContainer
local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
local GenDefaultTabData = function()
  return {
    newCount = 0,
    instanceId = {_isLeaf = true}
  }
end
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    desc = "RP",
    pages = {
      newCount = 0,
      [UnknowPassMacro.ENUM_REDDOT.AWARD] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.FIRSTRANK_NEW] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.FIRSTRANK_RECEIVE] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.GIFT_RECEIVE] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.GIFT_NEWVIDEO] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.PRIME_NEWVIDEO] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.EASYTICKET_NEWFREE] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.EASYTICKET_NEWWEEK] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.EASYTICKET_RECEIVE] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.TASK_NEW] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.TASK_WEEKRECEIVE] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.TASK_SEASON] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.UPGRADE_CARD] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.MOTION_CARD] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.EXTRA_SCORE_NEW] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.EXTRA_SCORE_RECEIVE] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.CONTINUE_BUY_RP] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.Bonus_Pass_Award_Reddot] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.Bonus_Pass_Task_Reddot] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      },
      [UnknowPassMacro.ENUM_REDDOT.Bonus_Pass_New] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.Priliege_New] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      }
    }
  }
  return data
end
function UnknowPassRedPointData.InitData()
  if isInited then
    return
  end
  isInited = true
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local super_data = require("common.super_data")
  local data = GenerateData()
  redpoint = {}
  redpoint = super_data.CreateSuperData(data)
  reddot_manager:Regist(redpoint)
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, UnknowPassRedPointData.OnBackLogin)
end
function UnknowPassRedPointData.GetRedPointSuperData()
  return redpoint
end
function UnknowPassRedPointData.OnLogin()
  UnknowPassRedPointData.InitData()
end
function UnknowPassRedPointData.OnBackLogin()
  redpoint = nil
  isInited = false
  EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, UnknowPassRedPointData.OnBackLogin)
end
function UnknowPassRedPointData.AddAllRedPointData()
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  local UnknowPassEasyTicketSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_easy_ticket")
  local hasUpgradeCard = UnknowPassBuySystem.HasUpgradeCard()
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  local rpgiftSyetem = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  local bBuy = UnknowPassSystem.IsBuyElite
  local bElite = UnknowPassSystem.PassType == 2
  local bGot = UnknowPassSystem.EmtionData and UnknowPassSystem.EmtionData.got or false
  local newSeasonredId = UnknowPassSystem.Season * 100 + UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_ExtraScoreSeason_New
  local newSeasonRed = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, newSeasonredId)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tSaveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassNewFirstClickPrilege) or {}
  local bIsPriliegeNew = UnknowPassSystem.Season >= 53 and not tSaveData[DataMgr.roleData.uid]
  local redDotData = {
    {
      passReddotMainSystem.showAwardReddot,
      UnknowPassMacro.ENUM_REDDOT.AWARD
    },
    {
      hasUpgradeCard and not UnknowPassSystem.IsBuyElite,
      UnknowPassMacro.ENUM_REDDOT.UPGRADE_CARD
    },
    {
      passReddotMainSystem.FirstWeek_Reddot_New,
      UnknowPassMacro.ENUM_REDDOT.FIRSTRANK_NEW
    },
    {
      rpgiftSyetem.CheckHasNotOpenGift(),
      UnknowPassMacro.ENUM_REDDOT.GIFT_RECEIVE
    },
    {
      not UnknowPassSystem.IsBuyElite and not UnknowPassEasyTicketSystem.HasBuyTicket() and 2 <= UnknowPassSystem.GetKeeyBuy() and UnknowPassEasyTicketSystem.GetNewSeasonRedPoint(),
      UnknowPassMacro.ENUM_REDDOT.EASYTICKET_RECEIVE
    },
    {
      UnknowPassEasyTicketSystem.GetNewSeasonRedPoint(),
      UnknowPassMacro.ENUM_REDDOT.EASYTICKET_NEWFREE
    },
    {
      UnknowPassEasyTicketSystem.HasBuyTicket() and UnknowPassEasyTicketSystem.HasRewardsReddot,
      UnknowPassMacro.ENUM_REDDOT.EASYTICKET_NEWWEEK
    },
    {
      UnknowPassMissionSystem.HasWeekAward,
      UnknowPassMacro.ENUM_REDDOT.TASK_WEEKRECEIVE
    },
    {
      UnknowPassMissionSystem.bHasSeasonAward,
      UnknowPassMacro.ENUM_REDDOT.TASK_SEASON
    },
    {
      UnknowPassMissionSystem.isNewWeek,
      UnknowPassMacro.ENUM_REDDOT.TASK_NEW
    },
    {
      bBuy and bElite and not bGot,
      UnknowPassMacro.ENUM_REDDOT.MOTION_CARD
    },
    {
      PassDataSystem.CheckExtraScoreCanGet() == 2 and newSeasonRed,
      UnknowPassMacro.ENUM_REDDOT.EXTRA_SCORE_NEW
    },
    {
      PassDataSystem.CheckExtraScoreCanGet() == 1,
      UnknowPassMacro.ENUM_REDDOT.EXTRA_SCORE_RECEIVE
    },
    {
      UnknowPassAwardSystem.IsShowReddot(),
      UnknowPassMacro.ENUM_REDDOT.CONTINUE_BUY_RP
    },
    {
      passReddotMainSystem.Bonus_Pass_Award_Reddot,
      UnknowPassMacro.ENUM_REDDOT.Bonus_Pass_Award_Reddot
    },
    {
      passReddotMainSystem.Bonus_Pass_Task_Reddot,
      UnknowPassMacro.ENUM_REDDOT.Bonus_Pass_Task_Reddot
    },
    {
      Logic_BonusPass:IsShowBonusPassNewReddot(),
      UnknowPassMacro.ENUM_REDDOT.Bonus_Pass_New
    },
    {
      bIsPriliegeNew,
      UnknowPassMacro.ENUM_REDDOT.Priliege_New
    }
  }
  for _, data in ipairs(redDotData) do
    local condition, redDot = table.unpack(data)
    if condition then
      UnknowPassRedPointData.AddRedPointData(redDot)
    else
      UnknowPassRedPointData.RemoveRedPointData(redDot)
    end
  end
end
function UnknowPassRedPointData.AddRedPointData(type)
  log(bWriteLog and "UnknowPassRedPointData.AddRedPointData " .. type)
  if redpoint and redpoint.pages and redpoint.pages[type] then
    redpoint.pages[type].newCount = 1
  end
end
function UnknowPassRedPointData.RemoveRedPointData(type)
  log(bWriteLog and "UnknowPassRedPointData.RemoveRedPointData " .. tostring(type))
  if redpoint and redpoint.pages[type] then
    redpoint.pages[type].newCount = 0
  end
end
function UnknowPassRedPointData.GetCanGetAwardList()
  local TableUtil = require("common.table_util")
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local awardLevelList = UnknowPassAwardSystem.GetAwardLevelList(true)
  local awardtb = {}
  for k, data in pairs(awardLevelList) do
    if data.level <= UnknowPassSystem.Level then
      for k2, award in pairs(data.OrdinaryAwardList) do
        if award.status == UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet then
          award.ItemQuality = CDataTable.GetTableData("Item", award.resId).ItemQuality
          if awardtb[award.resId] == nil then
            awardtb[award.resId] = TableUtil.CopyTable(award)
          else
            awardtb[award.resId].number = awardtb[award.resId].number + award.number
          end
        end
      end
      if UnknowPassSystem.IsBuyElite then
        for k3, award in pairs(data.EliteAwardList) do
          if award.status == UnknowPassAwardSystem.ENUM_UNKNOWPASS_CanGet then
            local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
            if award.item_show_type == PassDataSystem.UCAndDiamondShowType then
              if StoreUtils.CanShowDiamond() == false then
                award.ItemQuality = CDataTable.GetTableData("Item", award.resId).ItemQuality
                if awardtb[award.resId] == nil then
                  awardtb[award.resId] = TableUtil.CopyTable(award)
                  break
                end
                awardtb[award.resId].number = awardtb[award.resId].number + award.number
                break
              end
              do
                local ucDiamondId = UnknowPassAwardSystem.GetUCDiamondItemId(data.EliteAwardList[1].number)
                local temp = TableUtil.CopyTable(award)
                temp.resId = ucDiamondId
                temp.number = 1
                temp.ItemQuality = CDataTable.GetTableData("Item", temp.resId).ItemQuality
                if awardtb[temp.resId] == nil then
                  awardtb[temp.resId] = temp
                  break
                end
                awardtb[temp.resId].number = awardtb[temp.resId].number + temp.number
              end
              break
            else
              award.ItemQuality = CDataTable.GetTableData("Item", award.resId).ItemQuality
              if awardtb[award.resId] == nil then
                awardtb[award.resId] = TableUtil.CopyTable(award)
              else
                awardtb[award.resId].number = awardtb[award.resId].number + award.number
              end
            end
          end
        end
      end
    end
  end
  local awards = {}
  for k, v in pairs(awardtb) do
    table.insert(awards, v)
  end
  local res = {}
  for i, v in ipairs(awards) do
    table.insert(res, {
      itemId = v.resId,
      itemCount = v.number,
      ItemQuality = v.ItemQuality
    })
  end
  return res
end
function UnknowPassRedPointData.SortIconListFunc(awards)
  table.sort(awards, function(a, b)
    if a.ItemQuality < b.ItemQuality then
      return false
    elseif a.ItemQuality > b.ItemQuality then
      return true
    else
      return a.itemCount > b.itemCount
    end
  end)
end
function UnknowPassRedPointData.GetSubWayData()
  if redpoint ~= nil then
    return redpoint.pages[UnknowPassMacro.ENUM_REDDOT.SUBWAY_NEW]
  end
end
function UnknowPassRedPointData.GetRedDataByRedType(red_type)
  if redpoint ~= nil then
    return redpoint.pages[red_type]
  end
  return nil
end
return UnknowPassRedPointData