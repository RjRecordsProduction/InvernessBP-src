local RPTaskRedPointData = {}
local redpoint
local isInited = false
local delegateContainer
local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    desc = "RPTask",
    pages = {
      newCount = 0,
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
      [UnknowPassMacro.ENUM_REDDOT.EXTRA_SCORE_NEW] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      },
      [UnknowPassMacro.ENUM_REDDOT.EXTRA_SCORE_RECEIVE] = {
        newCount = 0,
        subID = 1,
        category = reddot_macro.Category.Receive
      }
    }
  }
  return data
end
function RPTaskRedPointData.InitData()
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
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, RPTaskRedPointData.OnBackLogin)
end
function RPTaskRedPointData.GetRedPointSuperData()
  return redpoint
end
function RPTaskRedPointData.OnLogin()
  RPTaskRedPointData.InitData()
end
function RPTaskRedPointData.OnBackLogin()
  redpoint = nil
  isInited = false
  EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, RPTaskRedPointData.OnBackLogin)
end
function RPTaskRedPointData.AddAllRedPointData()
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  local newSeasonredId = UnknowPassSystem.Season * 100 + UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_ExtraScoreSeason_New
  local newSeasonRed = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, newSeasonredId)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local redDotData = {
    {
      UnknowPassMissionSystem.HasWeekAward,
      UnknowPassMacro.ENUM_REDDOT.TASK_WEEKRECEIVE
    },
    {
      UnknowPassMissionSystem.isNewWeek,
      UnknowPassMacro.ENUM_REDDOT.TASK_NEW
    },
    {
      UnknowPassMissionSystem.bHasSeasonAward,
      UnknowPassMacro.ENUM_REDDOT.TASK_SEASON
    },
    {
      PassDataSystem.CheckExtraScoreCanGet() == 2 and newSeasonRed,
      UnknowPassMacro.ENUM_REDDOT.EXTRA_SCORE_NEW
    },
    {
      PassDataSystem.CheckExtraScoreCanGet() == 1,
      UnknowPassMacro.ENUM_REDDOT.EXTRA_SCORE_RECEIVE
    }
  }
  for _, data in ipairs(redDotData) do
    local condition, redDot = table.unpack(data)
    if condition then
      RPTaskRedPointData.AddRedPointData(redDot)
      break
    else
      RPTaskRedPointData.RemoveRedPointData(redDot)
    end
  end
end
function RPTaskRedPointData.AddRedPointData(type)
  log(bWriteLog and "RPTaskRedPointData.AddRedPointData " .. type)
  if redpoint then
    redpoint.pages[type].newCount = 1
    redpoint.groupShow = true
  end
end
function RPTaskRedPointData.RemoveRedPointData(type)
  log(bWriteLog and "RPTaskRedPointData.RemoveRedPointData " .. type)
  if redpoint then
    redpoint.pages[type].newCount = 0
  end
end
return RPTaskRedPointData