local moment_reddot_data = {}
local redPoint
function moment_reddot_data.InitData()
  if redPoint then
    return
  end
  local data = {
    has_new = false,
    has_new_fri_moments = false,
    has_new_fri_msgs = false,
    has_new_guide = false,
    has_new_square_guide = false
  }
  local super_data = require("common.super_data")
  redPoint = super_data.CreateSuperData(data)
  moment_reddot_data.InitGuideInfo()
  moment_reddot_data.InitSquareGuideInfo()
end
function moment_reddot_data.OnLogin()
  log(bWriteLog and "moment_reddot_data OnLogin")
  moment_reddot_data.InitData()
end
function moment_reddot_data.ClearData()
  if redPoint then
    redPoint = nil
  end
end
function moment_reddot_data.GetData()
  return redPoint
end
function moment_reddot_data.UpdateMomentRedPointData(has_new_fri_moments, has_new_fri_msgs)
  if redPoint then
    redPoint.    redPoint.    moment_reddot_data.UpdateHasNew()
    EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_GET_FRIEND_MOMENTS_RED, has_new_fri_moments)
  end
end
function moment_reddot_data.ClearRedPointDataByType(type)
  if type == 1 then
    redPoint.has_new_fri_moments = false
  elseif type == 2 then
    redPoint.has_new_fri_msgs = false
    local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
    logic_moment_bubble_tips:RemovePersonalBubble(logic_moment_bubble_tips.Enum_BubbleTipsID.Message)
  end
  moment_reddot_data.UpdateHasNew()
end
function moment_reddot_data.TryClearNewGuide()
  if redPoint and redPoint.has_new_guide then
    redPoint.has_new_guide = false
    moment_reddot_data.UpdateHasNew()
    moment_reddot_data.SaveGuideInfo()
  end
end
function moment_reddot_data.InitGuideInfo()
  if redPoint == nil then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.MomentGuide
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData == nil or not saveData.hasGuided then
    redPoint.has_new_guide = true
  else
    redPoint.has_new_guide = false
  end
  moment_reddot_data.UpdateHasNew()
end
function moment_reddot_data.SaveGuideInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.MomentGuide
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  saveData = saveData or {}
  saveData.hasGuided = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
end
function moment_reddot_data.InitSquareGuideInfo()
  if redPoint == nil then
    return
  end
  redPoint.has_new_square_guide = false
  moment_reddot_data.UpdateHasNew()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  if not LbsMgr.IsReady() then
    return
  end
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  if logic_moment.CheckMomentLbsOpen() == false then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.MomentSquareGuide
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData == nil or not saveData.hasSquareGuided then
    redPoint.has_new_square_guide = true
  else
    redPoint.has_new_square_guide = false
  end
  moment_reddot_data.UpdateHasNew()
end
function moment_reddot_data.SaveSquareGuideInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.MomentSquareGuide
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  saveData = saveData or {}
  saveData.hasSquareGuided = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
end
function moment_reddot_data.TryClearNewSquareGuide()
  if redPoint and redPoint.has_new_square_guide then
    redPoint.has_new_square_guide = false
    moment_reddot_data.UpdateHasNew()
    moment_reddot_data.SaveSquareGuideInfo()
  end
end
function moment_reddot_data.UpdateHasNew()
  log(bWriteLog and string.format("UpdateHasNew, has_new_fri_moments:%s has_new_fri_msgs:%s has_new_guide:%s has_new_square_guide:%s", redPoint.has_new_fri_moments, redPoint.has_new_fri_msgs, redPoint.has_new_guide, redPoint.has_new_square_guide))
  redPoint.has_new = redPoint.has_new_fri_moments or redPoint.has_new_fri_msgs or redPoint.has_new_guide or redPoint.has_new_square_guide
end
return moment_reddot_data