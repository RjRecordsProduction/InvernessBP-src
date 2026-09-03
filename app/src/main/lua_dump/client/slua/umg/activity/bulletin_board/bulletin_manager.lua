local bulletinmanager = {
  typeImage = 1,
  typeReward = 2,
  rewardStatus = 2,
  rewardActID = 0,
  rewardDesc = "",
  rewardTitle = "",
  style = 0
}
bulletinmanager.pageData = {}
bulletinmanager.bulletinData = {
  startTime = 0,
  endTime = 0,
  bgImageUrl = "",
  pageNum = 3
}
bulletinmanager.rewardData = {}
function bulletinmanager.ShouldSlap()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and "bulletinmanager ShouldSlap return not FinishAllNewGuide")
    return false
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityListByType(ActivityType.BULLETINBOARD)
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  for i, v in ipairs(activityData) do
    if now >= v.StartTime and now <= v.EndTime then
      local style = 0
      for index, value in ipairs(v.List) do
        if value.Type == ActivityType.BULLETINBOARD then
          style = value.Condition[1]
          break
        end
      end
      if style == 1 or style == 2 then
        for index, value in ipairs(v.List) do
          if value.Type ~= ActivityType.BULLETINBOARD and 0 < #value.Drop and value.Status == ActivityProgressStatus.Done then
            return true
          end
        end
      end
    end
  end
  return false
end
function bulletinmanager.Entrance()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityListByType(ActivityType.BULLETINBOARD)
  for i, v in ipairs(activityData) do
    for ii, vv in ipairs(v.List) do
      if vv.Type == ActivityType.BULLETINBOARD and (vv.Condition[1] == 1 or vv.Condition[1] == 2) then
        bulletinmanager.style = vv.Condition[1]
        bulletinmanager.SetData(v)
        return
      end
    end
  end
end
function bulletinmanager.EntranceSlapUI()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityListByType(ActivityType.BULLETINBOARD)
  for i, v in ipairs(activityData) do
    for ii, vv in ipairs(v.List) do
      if vv.Type == ActivityType.BULLETINBOARD and (vv.Condition[1] == 1 or vv.Condition[1] == 2) then
        bulletinmanager.style = vv.Condition[1]
        bulletinmanager.SetData(v, true)
        return
      end
    end
  end
end
function bulletinmanager.EntranceForComeback()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityListByType(ActivityType.BULLETINBOARD)
  for i, v in ipairs(activityData) do
    for ii, vv in ipairs(v.List) do
      if vv.Type == ActivityType.BULLETINBOARD and vv.Condition[1] == 3 then
        bulletinmanager.style = 3
        bulletinmanager.SetData(v)
        return
      end
    end
  end
end
function bulletinmanager.SetData(_data, isSlapUI)
  local data = {}
  data = _data
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if now < data.StartTime or now > data.EndTime then
    local tips = LocUtil.GetLocalizeResStr(120106)
    ShowNotice(tips)
    return
  end
  local orderMap = {}
  for i, v in ipairs(data.List) do
    if v.Type == ActivityType.BULLETINBOARD then
      for ii, vv in ipairs(v.Condition) do
        orderMap[vv] = ii
      end
      break
    end
  end
  bulletinmanager.pageData = {}
  bulletinmanager.rewardData = {}
  for i, v in ipairs(data.List) do
    if bulletinmanager.IsCanShowBullet(v) then
      local tempPage = {}
      if #v.Drop == 0 then
        tempPage.type = 1
      else
        tempPage.type = 2
        for _, dropdata in ipairs(v.Drop) do
          local drop = {
            itemID = dropdata.itemId,
            num = dropdata.count,
            limit_time = dropdata.expireTime
          }
          table.insert(bulletinmanager.rewardData, drop)
        end
        bulletinmanager.rewardStartTime = v.StartTime
        bulletinmanager.rewardStatus = v.Status
        bulletinmanager.rewardActID = v.ID
        bulletinmanager.rewardDesc = v.Desc
        bulletinmanager.rewardTitle = v.Title
      end
      tempPage.Condition = v.Condition
      tempPage.Id = v.ID
      tempPage.data = {
        title = v.Title,
        url = v.ImgLink,
        image = v.ShowImgLink,
        SharePicture = v.SharePicture or "",
        ViedoUrl = v.ViedoUrl or ""
      }
      tempPage.bEntered = false
      tempPage.order = orderMap[tempPage.Id]
      tempPage.ActType = v.Type
      table.insert(bulletinmanager.pageData, tempPage)
    end
  end
  bulletinmanager.bulletinData.pageNum = #bulletinmanager.pageData
  bulletinmanager.bulletinData.startTime = data.StartTime
  bulletinmanager.bulletinData.endTime = data.EndTime
  bulletinmanager.bulletinData.bgImageUrl = data.ImgUrl
  bulletinmanager.bulletinData.shareImageUrl = data.ImgUrl
  if #bulletinmanager.pageData == 0 then
    log_warning("[bulletin_manager] bulletinmanager, act type = 110, no pagedata")
    return
  end
  table.sort(bulletinmanager.pageData, function(a, b)
    return a.order < b.order
  end)
  local ParamTable
  if isSlapUI then
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    ParamTable = ui_show_queue_config.GetParamTable(nil, "IsSlapUI")
  end
  if bulletinmanager.style == 2 then
    UIManager.ShowUI(UIManager.UI_Config.bulletin_board_anniversary)
  else
    UIManager.ShowUI(UIManager.UI_Config.bulletin_board, ParamTable)
  end
end
function bulletinmanager.IsCanShowBullet(bulletinData)
  if not bulletinData or bulletinData.Type == ActivityType.BULLETINBOARD then
    return false
  end
  if bulletinData.ImgLink ~= "" and string.find(bulletinData.ImgLink, tostring(BP_ENUM_MODULE_COMMUNITY_VERSIONTOPIC)) then
    local logic_community = require("client.slua.logic.community.logic_community")
    if logic_community.GetShowEntry() == false then
      log(bWriteLog and "[v_wllwu] bulletinmanager.IsCanShowBullet, block the club bulletin, bulletData.ImgLink is: " .. tostring(bulletinData.ImgLink))
      return false
    end
  end
  return true
end
function bulletinmanager.BulletinRewardRes(res)
  EventSystem:postEvent(EVENTTYPE_BULLETIN, EVENTID_BULLETIN_REWARD_RESULT, {isSuccessed = true})
end
function bulletinmanager.ComebackBannerCheck()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityListByType(ActivityType.BULLETINBOARD)
  for i, v in ipairs(activityData) do
    for index, value in ipairs(v.List) do
      if value.Type == ActivityType.BULLETINBOARD and value.Condition[1] == 3 then
        if DataMgr.RejoinTaskData and DataMgr.RejoinTaskData.is_open then
          local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
          local table = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eComeBackBillboard)
          local ver = Client.GetAppVersion()
          if table == nil then
            table = {}
          end
          if table[ver] == nil then
            local TimeUtil = require("client.common.time_util")
            table[ver] = TimeUtil.GetServerTimeInSec()
            PlayerPrefsSystem.SaveTableToFile_N(table, PlayerPrefsSystem.ePlayerPrefsType.eComeBackBillboard)
            return true
          else
            local firstTime = tonumber(table[ver])
            local TimeUtil = require("client.common.time_util")
            local now = TimeUtil.GetServerTimeInSec()
            local sevenDay = 604800
            if sevenDay > now - firstTime then
              return true
            else
              return false
            end
          end
        else
          return false
        end
      end
    end
  end
  return false
end
return bulletinmanager