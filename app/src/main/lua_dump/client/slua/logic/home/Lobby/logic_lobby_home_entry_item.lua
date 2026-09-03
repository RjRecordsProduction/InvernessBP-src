local logic_lobby_home_entry_item = {
  eRedDotType = {
    None = 0,
    Gift = 1,
    RedDot = 2,
    TreeItem = 3,
    Message = 4,
    Visitor = 5,
    HomeUpgrade = 6,
    HomeIdleVehicle = 7,
    TreeInteractive = 8
  },
  eRedDotModule = {
    None = 0,
    VersionAward = 11,
    homePkAward = 12,
    homePkRedDot = 13,
    HomeStoreAward = 14,
    TreeCollect = 5,
    LeaveMessageOnLine = 16,
    LeaveMessageOffLine = 17,
    VisitOwnerOnLineFriend = 18,
    VisitOwnerOnLineNoFriend = 19,
    VisitOwnerOffLine = 20,
    TreeActiveOnLine = 21,
    TreeActiveOffLine = 22,
    HomeCanLevelUp = 23,
    ManorMysteryNotify = 24,
    AIHouseKeeper = 25,
    HomeAnniversaryAward = 26,
    HomeAnniversaryTips = 27,
    HomeParkingGift = 28,
    HomeIdleVehicle = 29,
    GetOneFromThree = 30,
    HomePromotionAward = 31
  }
}
function logic_lobby_home_entry_item:OnInitialize()
  log(bWriteLog and "logic_lobby_home_entry_item:OnInitialize")
  self.treeActiveMapOnLine = {}
  self.treeActiveMapOffLine = {}
  self.leaveMessageMapOnLine = {}
  self.leaveMessageMapOffLine = {}
  self.visitOwnerMapOnLineFriend = {}
  self.visitOwnerMapOnLineNoFriend = {}
  self.visitOwnerMapOffLine = {}
  self.manorMysteryNotify = false
end
function logic_lobby_home_entry_item:OnDestroy()
  log(bWriteLog and "logic_lobby_home_entry_item:OnDestroy")
end
function logic_lobby_home_entry_item:GetShowInfo()
  log(bWriteLog and "logic_lobby_home_entry_item:GetShowInfo")
  local info = {
    bShow = false,
    redType = self.eRedDotType.None,
    redModule = self.eRedDotModule.None,
    cfgText = nil
  }
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(false) then
    log(bWriteLog and "logic_lobby_home_entry_item:GetShowInfo limit")
    return info
  end
  local logic_lobby_home_entry_item_version_award = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_version_award")
  local info1 = logic_lobby_home_entry_item_version_award.GetShowInfo()
  if info1.bShow then
    info1.redType = self.eRedDotType.Gift
    info1.redModule = self.eRedDotModule.VersionAward
    info1.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info1.textCfgId)
    return info1
  end
  local logic_home_anniversary_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_anniversary_activity)
  if logic_home_anniversary_activity:NeedShowTips() then
    info.bShow = true
    info.redType = self.eRedDotType.None
    info.redModule = self.eRedDotModule.HomeAnniversaryTips
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  local logic_lobby_home_entry_item_housekeeper = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_housekeeper")
  local info2 = logic_lobby_home_entry_item_housekeeper.GetShowInfo()
  if info2.bShow then
    info2.redType = self.eRedDotType.RedDot
    info2.redModule = self.eRedDotModule.AIHouseKeeper
    info2.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info2.redModule)
    return info2
  end
  local logic_home_promotion_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_promotion_activity)
  if logic_home_promotion_activity:IsHaveReddot() then
    info.bShow = true
    info.redType = self.eRedDotType.RedDot
    info.redModule = self.eRedDotModule.HomePromotionAward
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  local logic_lobby_home_entry_item_HomeStore_Award = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_HomeStore_Award")
  local info3 = logic_lobby_home_entry_item_HomeStore_Award.GetShowInfo()
  if info3.bShow then
    info3.redType = self.eRedDotType.RedDot
    info3.redModule = self.eRedDotModule.HomeStoreAward
    info3.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info3.redModule)
    return info3
  end
  local logic_lobby_home_entry_item_tree_item = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_tree_item")
  local info4 = logic_lobby_home_entry_item_tree_item.GetShowInfo(DataMgr.roleData.uid)
  if info4.bShow then
    info4.redType = self.eRedDotType.TreeItem
    info4.redModule = self.eRedDotModule.TreeCollect
    info4.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info4.redModule)
    return info4
  end
  if self.manorMysteryNotify then
    info.bShow = true
    info.redType = self.eRedDotType.RedDot
    info.redModule = self.eRedDotModule.ManorMysteryNotify
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  if next(self.treeActiveMapOnLine) then
    info.bShow = true
    info.redType = self.eRedDotType.RedDot
    info.redModule = self.eRedDotModule.TreeActiveOnLine
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  if next(self.treeActiveMapOffLine) then
    info.bShow = true
    info.redType = self.eRedDotType.RedDot
    info.redModule = self.eRedDotModule.TreeActiveOffLine
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  if next(self.leaveMessageMapOnLine) then
    info.bShow = true
    info.redType = self.eRedDotType.Message
    info.redModule = self.eRedDotModule.LeaveMessageOnLine
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  if next(self.leaveMessageMapOffLine) then
    info.bShow = true
    info.redType = self.eRedDotType.Message
    info.redModule = self.eRedDotModule.LeaveMessageOffLine
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  local logic_home_car_parking_gift = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking_gift)
  local logic_home_car_parking = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking)
  local session = logic_home_car_parking:GetSessionConfig()
  log(bWriteLog and "logic_lobby_home_entry_item:GetShowInfo session =" .. tostring(session))
  if session and logic_home_car_parking_gift:hasGift() then
    local logic_lobby_home_entry_item_File = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_File")
    local fileTb = logic_lobby_home_entry_item_File.LoadFile()
    local tLastClick = fileTb.show_info[28]
    if tLastClick then
      local TimeUtil = require("client.common.time_util")
      local currtetime = TimeUtil.GetServerTimeInSec()
      if TimeUtil.IsSameDay(currtetime, tLastClick) then
        return info
      else
        info.bShow = true
        info.redType = self.eRedDotType.Gift
        info.redModule = self.eRedDotModule.HomeParkingGift
        info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
        return info
      end
    else
      info.bShow = true
      info.redType = self.eRedDotType.Gift
      info.redModule = self.eRedDotModule.HomeParkingGift
      info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
      return info
    end
  end
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local homeProfile
  if logic_home_joint:HasJointHome() then
    homeProfile = logic_home_profile:GetHomeProfileByUid(logic_home_joint.res_joint_info.master_uid)
  else
    homeProfile = logic_home_profile:GetHomeProfileByUid(tonumber(DataMgr.roleData.uid))
  end
  if homeProfile then
    local home_car_parking_utils = require("client.slua.logic.home.CarParking.home_car_parking_utils")
    if session and home_car_parking_utils.GetHomeIdleVehicleNum(homeProfile) > 0 then
      local logic_lobby_home_entry_item_File = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_File")
      local fileTb = logic_lobby_home_entry_item_File.LoadFile()
      local tLastClick = fileTb.show_info[29]
      if tLastClick then
        local TimeUtil = require("client.common.time_util")
        local currtetime = TimeUtil.GetServerTimeInSec()
        if TimeUtil.IsSameDay(currtetime, tLastClick) then
          return info
        else
          info.bShow = true
          info.redType = self.eRedDotType.RedDot
          info.redModule = self.eRedDotModule.HomeIdleVehicle
          info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
          return info
        end
      else
        info.bShow = true
        info.redType = self.eRedDotType.RedDot
        info.redModule = self.eRedDotModule.HomeIdleVehicle
        info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
        return info
      end
    end
  end
  if next(self.visitOwnerMapOnLineFriend) then
    info.bShow = true
    info.redType = self.eRedDotType.Visitor
    info.redModule = self.eRedDotModule.VisitOwnerOnLineFriend
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  if next(self.visitOwnerMapOnLineNoFriend) then
    info.bShow = true
    info.redType = self.eRedDotType.Visitor
    info.redModule = self.eRedDotModule.VisitOwnerOnLineNoFriend
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  if next(self.visitOwnerMapOffLine) then
    info.bShow = true
    info.redType = self.eRedDotType.Visitor
    info.redModule = self.eRedDotModule.VisitOwnerOffLine
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  local logic_home_smart_upgrade = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_smart_upgrade)
  if logic_home_smart_upgrade:CheckCanSmartUpgradeFull() then
    local logic_lobby_home_entry_item_File = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_File")
    local fileTb = logic_lobby_home_entry_item_File.LoadFile()
    local tLastClick = fileTb.show_info[23]
    if tLastClick then
      local time_util = require("client.common.time_util")
      local tNow = time_util.GetServerTimeInSec()
      local tDis = tNow - tLastClick
      log(bWriteLog and "logic_lobby_home_entry_item.GetShowInfo tDis = " .. tDis)
      local cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", 23)
      if 0 <= tDis and tDis <= cfgText.showCD * 3600 then
        return info
      end
    end
    info.bShow = true
    info.redType = self.eRedDotType.RedDot
    info.redModule = self.eRedDotModule.HomeCanLevelUp
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  if logic_home_anniversary_activity:NeedShowReddot() then
    info.bShow = true
    info.redType = self.eRedDotType.RedDot
    info.redModule = self.eRedDotModule.HomeAnniversaryAward
    info.cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", info.redModule)
    return info
  end
  return info
end
function logic_lobby_home_entry_item:NeedCheckSameDay(Module)
  return Module == logic_lobby_home_entry_item.eRedDotModule.HomeIdleVehicle or Module == logic_lobby_home_entry_item.eRedDotModule.HomeParkingGift
end
function logic_lobby_home_entry_item:ProcClickEntry(info)
  log(bWriteLog and "logic_lobby_home_entry_item:ProcClickEntry")
  if info.redModule == logic_lobby_home_entry_item.eRedDotModule.TreeActiveOnLine then
    self.treeActiveMapOnLine = {}
  elseif info.redModule == logic_lobby_home_entry_item.eRedDotModule.TreeActiveOffLine then
    self.treeActiveMapOffLine = {}
  elseif info.redModule == logic_lobby_home_entry_item.eRedDotModule.LeaveMessageOnLine then
    self.leaveMessageMapOnLine = {}
  elseif info.redModule == logic_lobby_home_entry_item.eRedDotModule.LeaveMessageOffLine then
    self.leaveMessageMapOffLine = {}
  elseif info.redModule == logic_lobby_home_entry_item.eRedDotModule.VisitOwnerOnLineFriend then
    self.visitOwnerMapOnLineFriend = {}
  elseif info.redModule == logic_lobby_home_entry_item.eRedDotModule.VisitOwnerOnLineNoFriend then
    self.visitOwnerMapOnLineNoFriend = {}
  elseif info.redModule == logic_lobby_home_entry_item.eRedDotModule.VisitOwnerOffLine then
    self.visitOwnerMapOffLine = {}
  elseif info.redModule == logic_lobby_home_entry_item.eRedDotModule.AIHouseKeeper then
  end
  if info.redModule ~= logic_lobby_home_entry_item.eRedDotModule.None then
    log(bWriteLog and "logic_lobby_home_entry_item:ProcClickEntry 2")
    if info.cfgText and info.cfgText.showCD > 0 or self:NeedCheckSameDay(info.redModule) then
      log(bWriteLog and "logic_lobby_home_entry_item:ProcClickEntry 3")
      local logic_lobby_home_entry_item_File = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_File")
      local fileTb = logic_lobby_home_entry_item_File.LoadFile()
      fileTb.show_info[info.redModule] = FuncUtil.GetServerTimeInSec()
      logic_lobby_home_entry_item_File.SaveFile(fileTb)
    end
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE)
end
function logic_lobby_home_entry_item:ClearSomeNotifyData()
  log(bWriteLog and "logic_lobby_home_entry_item:ClearSomeNotifyData")
  self.treeActiveMapOnLine = {}
  self.treeActiveMapOffLine = {}
  self.leaveMessageMapOnLine = {}
  self.leaveMessageMapOffLine = {}
  self.visitOwnerMapOnLineFriend = {}
  self.visitOwnerMapOnLineNoFriend = {}
  self.visitOwnerMapOffLine = {}
  self.manorMysteryNotify = false
end
function logic_lobby_home_entry_item:proc_manor_tree_active_notify(active_uid)
  log(bWriteLog and "logic_lobby_home_entry_item:proc_manor_tree_active_notify active_uid = " .. active_uid)
  local tNow = FuncUtil.GetServerTimeInSec()
  self.treeActiveMapOnLine[active_uid] = tNow
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE, true)
end
function logic_lobby_home_entry_item:proc_manor_tree_active_off_notify(active_uid, active_time)
  log(bWriteLog and "logic_lobby_home_entry_item:proc_manor_tree_active_off_notify active_uid = " .. active_uid .. ", active_time = " .. active_time)
  self.treeActiveMapOffLine[active_uid] = active_time
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE, true)
end
function logic_lobby_home_entry_item:proc_manor_leave_message_notify(message_uid)
  log(bWriteLog and "logic_lobby_home_entry_item:proc_manor_leave_message_notify message_uid = " .. message_uid)
  local tNow = FuncUtil.GetServerTimeInSec()
  self.leaveMessageMapOnLine[message_uid] = tNow
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE, true)
end
function logic_lobby_home_entry_item:proc_manor_leave_message_off_notify(message_uid, message_time)
  log(bWriteLog and "logic_lobby_home_entry_item:proc_manor_leave_message_off_notify message_uid = " .. message_uid .. ", message_time = " .. message_time)
  self.leaveMessageMapOffLine[message_uid] = message_time
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE, true)
end
function logic_lobby_home_entry_item:proc_manor_visit_owner_notify(vistor, is_friend)
  log(bWriteLog and "logic_lobby_home_entry_item:proc_manor_visit_owner_notify vistor = " .. vistor .. ", is_friend = " .. tostring(is_friend))
  local tNow = FuncUtil.GetServerTimeInSec()
  if is_friend then
    self.visitOwnerMapOnLineFriend[vistor] = tNow
  else
    self.visitOwnerMapOnLineNoFriend[vistor] = tNow
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE, true)
end
function logic_lobby_home_entry_item:proc_manor_visit_owner_off_notify(visitor, off_time)
  log(bWriteLog and "logic_lobby_home_entry_item:proc_manor_visit_owner_off_notify visitor = " .. visitor .. ", off_time = " .. off_time)
  self.visitOwnerMapOffLine[visitor] = off_time
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE, true)
end
function logic_lobby_home_entry_item:proc_manor_mystery_man_notify(mystery_man_id)
  log(bWriteLog and "logic_lobby_home_entry_item:proc_manor_mystery_man_notify mystery_man_id = " .. mystery_man_id)
  self.manorMysteryNotify = true
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE, true)
end
function logic_lobby_home_entry_item:ReqNeedData()
  log(bWriteLog and "logic_lobby_home_entry_item:ReqNeedData")
  local bGetData = true
  local logic_home_newbieguide = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_newbieguide)
  if not logic_home_newbieguide.bFetchedNewbieGuideTaskStatus then
    log(bWriteLog and "logic_lobby_home_entry_item:ReqNeedData 4")
    local PlanPHNewbieGuideHandler = require("client.network.Protocol.PlanPHNewbieGuideHandler")
    PlanPHNewbieGuideHandler.send_get_manor_newbie_guide_req()
    bGetData = false
  end
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local homeProfile = logic_home_profile:GetHomeProfileByUid(DataMgr.roleData.uid)
  if not homeProfile then
    log(bWriteLog and "logic_lobby_home_entry_item:ReqNeedData 5")
    logic_home_profile:GetOrReqHomeProfile({
      DataMgr.roleData.uid
    }, function()
      log(bWriteLog and "logic_lobby_home_entry_item:ReqNeedData 6")
      EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE)
    end)
    bGetData = false
  end
  local logic_home_pass = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_pass)
  if logic_home_pass:GetCurSeasonConfig() and logic_home_pass.currentDays == 0 then
    log(bWriteLog and "logic_lobby_home_entry_item:ReqNeedData 7")
    logic_home_pass:send_manor_upass_info_req()
  end
  return bGetData
end
function logic_lobby_home_entry_item:GetEnterHomeRewardList(ParentRewardID)
  log(bWriteLog and "logic_lobby_home_entry_item:GetEnterHomeRewardList ParentRewardID = ", ParentRewardID)
  local cfgReward = CDataTable.GetTableDataByFilter("PlanPH_Bubble_Reward", "ID", ParentRewardID)
  local rewardList = {}
  if not cfgReward then
    log(bWriteLog and "logic_lobby_home_entry_item:GetEnterHomeRewardList not cfgReward", ParentRewardID)
    return rewardList
  end
  local RewardItemID = cfgReward.RewardItemID
  if RewardItemID and 0 < RewardItemID then
    local data = {
      RewardItemID = cfgReward.RewardItemID,
      RewardItemNumber = cfgReward.RewardItemNumber
    }
    table.insert(rewardList, data)
  end
  RewardItemID = cfgReward.RewardItemID1
  if RewardItemID and 0 < RewardItemID then
    local data1 = {
      RewardItemID = cfgReward.RewardItemID1,
      RewardItemNumber = cfgReward.RewardItemNumber1
    }
    table.insert(rewardList, data1)
  end
  RewardItemID = cfgReward.RewardItemID2
  if RewardItemID and 0 < RewardItemID then
    local data2 = {
      RewardItemID = cfgReward.RewardItemID2,
      RewardItemNumber = cfgReward.RewardItemNumber2
    }
    table.insert(rewardList, data2)
  end
  log_tree(bWriteLog and "logic_lobby_home_entry_item:GetEnterHomeRewardList rewardList = ", rewardList)
  return rewardList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_home_entry_item = class(CModuleBase, nil, logic_lobby_home_entry_item)
return Clogic_lobby_home_entry_item