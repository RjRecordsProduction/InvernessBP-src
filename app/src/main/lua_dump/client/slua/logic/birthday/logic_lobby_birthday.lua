local logic_lobby_birthday = {}
local bReceiveBirthdayNotify = false
function logic_lobby_birthday:DefineAndResetData()
  self.bGetReward = false
  self.gameTotalCount = 0
  self.rewardList = nil
  self.birthDayTime = 0
end
function logic_lobby_birthday:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BIRTHDAY_SLAP, self.OnBirthDaySlapShow, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BIRTHDAY_PAGE, self.OnBirthdayPageShow, self)
end
function logic_lobby_birthday:OnBirthDaySlapShow()
  log(bWriteLog and "logic_lobby_birthday:OnBirthDaySlapShow")
  UIManager.ShowUI(UIManager.UI_Config.BirthDay_Wish_Popup_UIBP)
end
function logic_lobby_birthday:OnBirthdayPageShow()
  log(bWriteLog and "logic_lobby_birthday:OnBirthdayPageShow")
  self:SendGetBirthdayGroupPageReq()
end
function logic_lobby_birthday.CanShowSlapFace()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBirthDaySlapShow)
  local bShow = true
  local TimeUtil = require("client.common.time_util")
  local bIsNextYear = true
  if data and data.setTime then
    bIsNextYear = not TimeUtil.WithinInNDay(data.setTime, 360)
  end
  if data and next(data) and data.alreadyShow and not bIsNextYear then
    bShow = false
    log(bWriteLog and "logic_lobby_birthday:CanShowSlapFace alreadyShow: " .. tostring(data.alreadyShow) .. ", bIsNextYear: " .. tostring(bIsNextYear))
  end
  log_tree(bWriteLog and "logic_lobby_birthday:CanShowSlapFace eBirthDaySlapShow", data)
  log(bWriteLog and "logic_lobby_birthday:CanShowSlapFace bReceiveBirthdayNotify: " .. tostring(bReceiveBirthdayNotify))
  return bShow and bReceiveBirthdayNotify
end
function logic_lobby_birthday:SetAlreadySlapFace()
  log(bWriteLog and "logic_lobby_birthday:SetAlreadySlapFace")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({
    alreadyShow = true,
    setTime = self.birthDayTime
  }, PlayerPrefsSystem.ePlayerPrefsType.eBirthDaySlapShow)
end
function logic_lobby_birthday:SetHaveGetReward()
  log(bWriteLog and "logic_lobby_birthday:SetHaveGetReward")
  self.bGetReward = true
end
function logic_lobby_birthday:GetHaveGetReward()
  log(bWriteLog and "logic_lobby_birthday:GetHaveGetReward : " .. tostring(self.bGetReward))
  return self.bGetReward
end
function logic_lobby_birthday:TakeSharePhoto()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_ANIMATION_HIDE)
  Client.DeleteDirectory(Client.ProjectSavedDir() .. "Screenshots/")
  local ScreenshotMaker = import("ScreenshotMaker")
  local sSharePath = ScreenshotMaker.MakePicture(true)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SOCIAL_PHOTO, true)
  local timer_ticker = require("common.time_ticker")
  local timer
  timer = timer_ticker.AddTimerLoop(0, function()
    if ScreenshotMaker.HasCaptured(sSharePath) then
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SOCIAL_PHOTO, false)
      local TimeUtil = require("client.common.time_util")
      local cfg = {
        capturePath = sSharePath,
        sceneType = ShareSceneType.BirthDayShare,
        otherTLog = TLogEventDefine.Birthday_Photo_Share,
        campaign = "birthday",
        share_type = ShareBtnTLogShareTypeDefine.BirthDayPage,
        reasonStr = json.encode({
          uid = DataMgr.roleData.uid,
          time = TimeUtil.GetServerTimeInSec()
        }),
        isOld = false
      }
      local Util = require("client.slua_ui_framework.util")
      Util.ShowShare(cfg)
      timer_ticker.RemoveTimer(timer)
    else
      log(bWriteLog and "  : not yet")
    end
  end, TIMER_INFINITE, 0.1)
end
function logic_lobby_birthday:GetGameTotalCount()
  return self.gameTotalCount or 0
end
function logic_lobby_birthday:GetBirthDay()
  local TimeUtil = require("client.common.time_util")
  local serverTime = self.birthDayTime
  local birthDayTime = TimeUtil.OSDate("*t", serverTime)
  return birthDayTime.month, birthDayTime.day
end
function logic_lobby_birthday:GetBirthdayMonthDays()
  local TimeUtil = require("client.common.time_util")
  local month = TimeUtil.OSDate("*t", self.birthDayTime).month
  local days = TimeUtil.GetDaysInMonth(month)
  log(bWriteLog and "ogic_lobby_birthday:GetBirthdayMonthDays " .. tostring(days))
  return days
end
function logic_lobby_birthday:GetRewardList()
  local reward = {}
  if not self.rewardList then
    log(bWriteLog and "logic_lobby_birthday:GetRewardList no reward List")
    return reward
  end
  for id, data in pairs(self.rewardList) do
    local data = {
      res_id = id,
      count = data.count,
      valid_hours = data.valid_hours
    }
    table.insert(reward, data)
  end
  log_tree(bWriteLog and "logic_lobby_birthday:GetRewardList", reward)
  return reward
end
function logic_lobby_birthday:GetBirthDayTime()
  return self.birthDayTime
end
function logic_lobby_birthday:SetReceiveNotify()
  log(bWriteLog and "logic_lobby_birthday:SetReceiveNotify")
  bReceiveBirthdayNotify = true
  local TimeUtil = require("client.common.time_util")
  self.birthDayTime = TimeUtil.GetServerTimeInSec()
end
function logic_lobby_birthday:SendGetBirthdayGroupPageReq()
  local BirthdayHandler = require("client.network.Protocol.BirthDayHandler")
  BirthdayHandler.send_get_birthday_group_page_req()
end
function logic_lobby_birthday:SetPageDatas(player_game_total_cnt, item_list, already_received_reward)
  log(bWriteLog and "logic_lobby_birthday:SetPageDatas player_game_total_cnt : " .. player_game_total_cnt .. " already_received_reward : " .. tostring(already_received_reward))
  log_tree("logic_lobby_birthday:SetPageDatas item_list:", item_list)
  self.gameTotalCount = player_game_total_cnt
  self.rewardList = item_list
  self.bGetReward = already_received_reward
  local BirthDay_Information_UIBP = UIManager.GetUI(UIManager.UI_Config.BirthDay_Information_UIBP)
  if BirthDay_Information_UIBP then
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_GET_BIRTHDAY_DATA)
  else
    UIManager.ShowUI(UIManager.UI_Config.BirthDay_Information_UIBP)
  end
end
function logic_lobby_birthday:SendReceiveBirthdayGift()
  log(bWriteLog and "logic_lobby_birthday:SendReceiveBirthdayGift")
  local BirthdayHandler = require("client.network.Protocol.BirthDayHandler")
  BirthdayHandler.send_receive_birthday_gift_req()
end
function logic_lobby_birthday:OnReceiveBirthdayGift()
  log(bWriteLog and "logic_lobby_birthday:OnReceiveBirthdayGift")
  self:SetHaveGetReward()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_RECEIVE_BIRTHDAY_GIFT)
  if not self.rewardList or not next(self.rewardList) then
    log(bWriteLog and "logic_lobby_birthday:OnReceiveBirthdayGift not reward")
    return
  end
  local datas = {}
  for id, data in pairs(self.rewardList) do
    local data = {
      res_id = id,
      count = data.count,
      valid_hours = data.valid_hours
    }
    table.insert(datas, data)
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(datas)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_birthday = class(CModuleBase, nil, logic_lobby_birthday)
return Clogic_lobby_birthday