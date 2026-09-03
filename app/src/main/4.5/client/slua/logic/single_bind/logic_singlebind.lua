local logic_singlebind = {}
local SettingAccount = require("client.logic.setting.logic_setting_account")
function logic_singlebind:DefineAndResetData()
  self.activityData = nil
  self.cfg = nil
  self.bUseTestData = false
  self.missionData = nil
  self.singleBindAwardStatus = 0
  self.awardList = {}
end
function logic_singlebind:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, self.PopupNotSafe, self)
end
function logic_singlebind:UpdateData(data, cfg)
  log(bWriteLog and "logic_singlebind:UpdateData")
  self.activityData = data
  self.  if self.activityData and self.activityData.reward_status then
    self.singleBindAwardStatus = self.activityData.reward_status
  end
  self:UpdateMissionData()
end
function logic_singlebind:UpdateMissionData()
  log(bWriteLog and "logic_singlebind:UpdateMissionData")
  self:GenerateMissionData()
  log_tree("logic_singlebind:UpdateMissionData", self.missionData)
  EventSystem:postEvent(EVENTTYPE_BIND_INTL, EVENTID_INTL_SINGLE_BIND_ACTIVITY_NOTIFY)
  local changeList = {
    idList = {
      [ActivityFixedID.SingleBind] = true
    },
    typeList = {}
  }
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
end
function logic_singlebind:GenerateActivityTestData()
  log(bWriteLog and "logic_singlebind:GenerateActivityTestData")
  self.activityData = {
    act_id = 1,
    reward_status = 0,
    channel_id = 31
  }
  self.cfg = {
    start_time = 1708905600,
    end_time = 1711929600,
    switch_id = 950002,
    is_bind_one_channel = 1,
    channel_id = 31,
    item_list = {
      {
        res_id = 1001,
        valid_hours = 0,
        res_num = 1
      }
    }
  }
end
function logic_singlebind:GenerateMissionData()
  log(bWriteLog and "logic_singlebind:GenerateMissionData")
  self.missionData = {}
  local anyBindAwardList = self:GetAwardList(1)
  local anyItemData = {
    Index = 1,
    Title = LocUtil.GetLocalizeResStr(67666),
    Drop = anyBindAwardList,
    Order = 98,
    Total = 0,
    Type = 0,
    Status = self.singleBindAwardStatus,
    ImgLink = "game://?module=1000600",
    mainActID = ActivityFixedID.SingleBind
  }
  table.insert(self.missionData, anyItemData)
  if self:IsSingleBindVK() or self.cfg.is_bind_one_channel == 1 then
    local phoneOrMailBindAwardList = self:GetAwardList(2)
    local account_data = SettingAccount.GetSettingAccountData()
    local Status = 0
    local mail_state = account_data.award_state_mail
    local phone_state = account_data.award_state_phone
    if mail_state == 0 and phone_state == 0 then
      Status = 0
    elseif mail_state == 1 and phone_state == 0 or phone_state == 1 and mail_state == 0 then
      Status = 1
    else
      Status = 2
    end
    local singleBindData = {
      Index = 2,
      Title = LocUtil.GetLocalizeResStr(67667),
      Drop = phoneOrMailBindAwardList,
      Order = 99,
      Total = 0,
      Type = 0,
      Status = Status,
      ImgLink = "game://?module=1000600",
      mainActID = ActivityFixedID.SingleBind
    }
    table.insert(self.missionData, singleBindData)
  end
  log_tree(bWriteLog and "logic_singlebind:GenerateMissionData", self.missionData)
  return self.missionData
end
function logic_singlebind:GenerateAwardList(Index)
  local awardList = {}
  if Index == 1 then
    if not (self.cfg and next(self.cfg) and self.cfg.item_list) or not next(self.cfg.item_list) then
      return awardList
    end
    for _, item in pairs(self.cfg.item_list) do
      local awardItemData = {
        itemId = item.res_id,
        count = item.count,
        expireTime = 0,
        reviseId = 0
      }
      table.insert(awardList, awardItemData)
    end
  else
    local id = 99999
    if not PufferDownloader.DownloadRewardCfg[id] then
      log(bWriteLog and "logic_singlebind:GenerateAwardList == nil")
      return awardList
    end
    local itemID = PufferDownloader.DownloadRewardCfg[id].itemid1
    if not itemID then
      log(bWriteLog and "logic_singlebind:GenerateAwardList itemid1 == nil")
      return awardList
    end
    local awardItemData = {
      itemId = itemID,
      count = 0,
      expireTime = 0,
      reviseId = 0
    }
    table.insert(awardList, awardItemData)
  end
  log_tree("logic_singlebind:GenerateAwardList AwardList : ", awardList)
  self.awardList[Index] = awardList
  return awardList
end
function logic_singlebind:CheckActivityOnline()
  if not self.activityData or not self.cfg then
    log(bWriteLog and "logic_singlebind:CheckActivityOnline don't have data, so don't online")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.UnixTimeBetween(self.cfg.start_time, self.cfg.end_time) == 0 then
    return true
  end
  return false
end
local HasRedDot = function()
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = ActivityMacros.RedDotType.None
  local logic_singlebind = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_singlebind)
  local MissionData = logic_singlebind:GetMissionData()
  if not MissionData then
    log(bWriteLog and "logic_singlebind.HasRedDot no missionData, hasn't red dot!")
    return false, RedDotType
  else
    for _, v in pairs(MissionData) do
      if v.Status == 1 then
        log(bWriteLog and "logic_singlebind.HasRedDot, show the red dot")
        return true, ActivityMacros.RedDotType.Reward
      end
    end
    return false, RedDotType
  end
end
function logic_singlebind:GetActivitySubData_SingleBind()
  log(bWriteLog and "logic_singlebind:GetActivitySubData_SingleBind")
  if self.bUseTestData == true then
    self:GenerateActivityTestData()
    return {
      nActID = ActivityFixedID.SingleBind,
      sName = LocUtil.GetLocalizeResStr(4041),
      nSwitchType = ActivitySwitchType.IPLink,
      bRedDot = HasRedDot,
      sBgUrl = "",
      ImgUrl = "/Game/Mod/Lobby/Split/NewActivity/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_Default_BG1.NewActivty_Default_BG1",
      ImgLink = "",
      nStartTime = self.cfg.start_time,
      nEndTime = self.cfg.start_time
    }
  end
  if self.cfg and self.cfg.switch_id and not LobbySystem.CheckOpen(self.cfg.switch_id) then
    log(bWriteLog and "logic_singlebind:GetActivitySubData_SingleBind Switch isn't open")
    return nil
  end
  if not self.activityData or not self.cfg then
    log(bWriteLog and "logic_singlebind:GetActivitySubData_SingleBind no data, so don't show")
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  if self.cfg.start_time and self.cfg.end_time and TimeUtil.UnixTimeBetween(self.cfg.start_time, self.cfg.end_time) ~= 0 then
    log(bWriteLog and "logic_singlebind:GetActivitySubData_SingleBind out of the activity time, so don't show")
    return nil
  end
  local bSingleBindVK = self:IsSingleBindVK()
  local bCompleted = true
  if self.missionData then
    for _, data in pairs(self.missionData) do
      if data.Status ~= 2 then
        bCompleted = false
        break
      end
    end
  else
    if self.activityData and self.activityData.reward_status and self.activityData.reward_status ~= 2 then
      bCompleted = false
    end
    if bSingleBindVK or self.cfg.is_bind_one_channel == 1 then
      local account_data = SettingAccount.GetSettingAccountData()
      if account_data.award_state_mail ~= 2 and account_data.award_state_phone ~= 2 then
        bCompleted = false
      end
    end
  end
  if bCompleted then
    log(bWriteLog and "logic_singlebind:GetActivitySubData_SingleBind all completed, so don't show")
    return nil
  end
  local switch_type = ActivitySwitchType.Activity
  if bSingleBindVK or self.cfg.is_bind_one_channel == 1 then
    switch_type = ActivitySwitchType.IPLink
  end
  log(bWriteLog and "logic_singlebind:GetActivitySubData_SingleBind, return the activity data")
  return {
    nActID = ActivityFixedID.SingleBind,
    sName = LocUtil.GetLocalizeResStr(4041),
    nSwitchType = switch_type,
    bRedDot = HasRedDot,
    sBgUrl = "",
    ImgUrl = "/Game/Mod/Lobby/Split/NewActivity/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_Default_BG1.NewActivty_Default_BG1",
    ImgLink = "",
    nStartTime = self.cfg.start_time,
    nEndTime = self.cfg.start_time
  }
end
function logic_singlebind:GetData()
  return self.activityData
end
function logic_singlebind:GetConfig()
  return self.cfg
end
function logic_singlebind:GetMissionData()
  return self:GenerateMissionData()
end
function logic_singlebind:GetAwardList(Index)
  if self.awardList and self.awardList[Index] then
    return self.awardList[Index]
  else
    return self:GenerateAwardList(Index)
  end
end
function logic_singlebind:GetChannel()
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if IMSDKHelperInstance then
    local channelId = IMSDKHelperInstance:GetLastIMSDKChannelID()
    log(bWriteLog and string.format("logic_singlebind:GetChannel channelId : %s ", tostring(channelId)))
    return channelId
  end
end
function logic_singlebind:GetBindCount()
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local bindCount = IMSDKHelperInstance:GetBindCount()
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local mailInfo = SettingAccount.GetSettingAccountData()
  if mailInfo.bind_phone then
    bindCount = bindCount + 1
  end
  if mailInfo.bind_mail then
    bindCount = bindCount + 1
  end
  log(bWriteLog and string.format("logic_singlebind:GetBindCount Count : %s", bindCount))
  return bindCount
end
function logic_singlebind:IsSingleBindVK()
  if self:GetBindCount() == 1 then
    local channelId = self:GetChannel()
    if channelId == BP_ENUM_IMSDK_CHANNEL_VK then
      return true
    end
  end
  return false
end
function logic_singlebind:TakeAward(index)
  log(bWriteLog and string.format("logic_singlebind:TakeAward index=%s", tostring(index)))
  if index == 1 then
    self:_TakeAnyBindAward()
  elseif index == 2 then
    self:_TakePhoneOrMailBindAward()
  end
end
function logic_singlebind:_TakeAnyBindAward()
  log(bWriteLog and "logic_singlebind:_TakeAnyBindAward")
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_get_activity_reward_req()
end
function logic_singlebind:TakeAnyBindAwardRsp(_, itemlist)
  log(bWriteLog and "logic_singlebind:TakeAnyBindAwardRsp")
  self.singleBindAwardStatus = 2
  self:UpdateMissionData()
end
function logic_singlebind:_TakePhoneOrMailBindAward()
  local mailInfo = SettingAccount.GetSettingAccountData()
  local mail_state = mailInfo.award_state_mail
  local phone_state = mailInfo.award_state_phone
  if phone_state == 1 then
    log(bWriteLog and "logic_singlebind:_TakePhoneOrMailBindAward bind phone, get phone bind award!")
    local Handler = require("client.network.Protocol.PhoneMailLoginHandler")
    Handler.request_get_self_build_account_award(1)
  elseif mail_state == 1 then
    log(bWriteLog and "logic_singlebind:_TakePhoneOrMailBindAward bind mail, get mail bind award!")
    local Handler = require("client.network.Protocol.PhoneMailLoginHandler")
    Handler.request_get_self_build_account_award(0)
  end
end
function logic_singlebind:TakePhoneOrMailBindAwardRsp()
  if not self.activityData or not self.cfg then
    log(bWriteLog and "logic_singlebind:TakePhoneOrMailBindAwardRsp no data, so don't handle")
    return
  end
  self:UpdateMissionData()
end
function logic_singlebind:PopupNotSafe(_, __, param)
  log(bWriteLog and "logic_singlebind:PopupNotSafe")
  log_tree("param = ", param)
  if param.pre == GameStatus.Fighting and GameStatus.IsInLobbyOrMainCity() then
    self:AddTimer(0.5, function()
      if GameStatus.GetGameStatus() == GameStatus.Createrole then
        log(bWriteLog and "logic_singlebind:PopupNotSafe status is in create role, don't show popup!")
        return
      end
      if UIManager.IsUIShow(UIManager.UI_Config.Lobby_CreatRole) then
        log(bWriteLog and "logic_singlebind:PopupNotSafe is in create role, don't show popup!")
        return
      end
      if self:IsSingleBindVK() and LobbySystem.CheckOpen(BP_ENUM_SWITCH_ACCOUNT_SAFE_SINGLE_BIND) and self:CheckActivityOnline() then
        self:Popup()
      end
    end)
  end
end
function logic_singlebind:Popup()
  local jumpBtn = {}
  function jumpBtn.callback()
    GlobalData.JumpGameUrl("game://?module=1001300")
  end
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ConfigTab = ui_show_queue_config.GetParamTable(nil, "SingleBindVK")
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  RightPopSystem.CommonPopup(ConfigTab, "", LocUtil.GetLocalizeResStr(67686), "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Warn_02_png.Setting_Icon_Warn_02_png", jumpBtn, 10)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSingleBindModule = class(CModuleBase, nil, logic_singlebind)
return CSingleBindModule