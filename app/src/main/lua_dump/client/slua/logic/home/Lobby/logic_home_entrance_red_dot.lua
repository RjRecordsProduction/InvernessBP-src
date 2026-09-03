local logic_home_entrance_red_dot = {}
local redDotIconMap = {
  None = "",
  Gift = "/Game/UMG/Texture_200/Atlas/Home/Home_Entrance_Atlas/Frames/Home_Entrance_Icon_Reddot_Gift_png.Home_Entrance_Icon_Reddot_Gift_png",
  RedDot = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_RedPoint_png.Common_Icon_RedPoint_png",
  TreeItem = "/Game/UMG/Texture_200/Atlas/Home/Home_Entrance_Atlas/Frames/Home_Entrance_Icon_Reddot_Tree_png.Home_Entrance_Icon_Reddot_Tree_png",
  Message = "/Game/UMG/Texture_200/Atlas/Home/Home_Entrance_Atlas/Frames/Home_Entrance_Icon_Reddot_FriendMessage_png.Home_Entrance_Icon_Reddot_FriendMessage_png",
  TreeInteractive = "/Game/UMG/Texture_200/Atlas/Home/Home_Entrance_Atlas/Frames/Home_Entrance_Icon_Reddot_FriendInteract_png.Home_Entrance_Icon_Reddot_FriendInteract_png",
  HomeUpgrade = "/Game/UMG/Texture_200/Atlas/Home/Home_Entrance_Atlas/Frames/Home_Entrance_Icon_Reddot_Uprade_png.Home_Entrance_Icon_Reddot_Uprade_png",
  HomeIdleVehicle = "/Game/UMG/Texture_200/Atlas/Home/Home_Entrance_Atlas/Frames/Home_Entrance_Icon_Reddot_ParkingLot_png.Home_Entrance_Icon_Reddot_ParkingLot_png"
}
function logic_home_entrance_red_dot.GetHomeEntranceRedDotInfo()
  log(bWriteLog and "logic_home_entrance_red_dot.GetHomeEntranceRedDotInfo")
  local logic_lobby_home_entry_item = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_lobby_home_entry_item)
  local logic_lobby_home_entry_item_File = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_File")
  local TimeUtil = require("client.common.time_util")
  local info = {
    bShow = false,
    redType = logic_lobby_home_entry_item.eRedDotType.None,
    redModule = logic_lobby_home_entry_item.eRedDotModule.None,
    iconPath = nil
  }
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(false) then
    log(bWriteLog and "logic_home_entrance_red_dot.GetHomeEntranceRedDotInfo limit")
    return info
  end
  local type = logic_lobby_home_entry_item.eRedDotType.None
  local typeModule = logic_lobby_home_entry_item.eRedDotModule.None
  local logic_lobby_home_entry_item_version_award = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_version_award")
  local info1 = logic_lobby_home_entry_item_version_award.GetShowInfo()
  type = logic_lobby_home_entry_item.eRedDotType.Gift
  if info1.bShow then
    log(bWriteLog and "logic_home_entrance_red_dot.GetHomeEntranceRedDotInfo version award")
    info1.redType = logic_lobby_home_entry_item.eRedDotType.Gift
    info1.redModule = logic_lobby_home_entry_item.eRedDotModule.VersionAward
    info1.iconPath = redDotIconMap.Gift
    return info1
  end
  local logic_lobby_home_entry_item_tree_item = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_tree_item")
  local info4 = logic_lobby_home_entry_item_tree_item.GetShowInfo(DataMgr.roleData.uid)
  if info4.bShow then
    log(bWriteLog and "logic_home_entrance_red_dot.GetHomeEntranceRedDotInfo tree item")
    type = logic_lobby_home_entry_item.eRedDotType.TreeItem
    typeModule = logic_lobby_home_entry_item.eRedDotModule.TreeCollect
    info4.redType = type
    info4.redModule = typeModule
    info4.iconPath = redDotIconMap.TreeItem
    return info4
  end
  type = logic_lobby_home_entry_item.eRedDotType.TreeInteractive
  if next(logic_lobby_home_entry_item.treeActiveMapOnLine) then
    info.bShow = true
    info.redType = type
    info.redModule = logic_lobby_home_entry_item.eRedDotModule.TreeActiveOnLine
    info.iconPath = redDotIconMap.TreeInteractive
    return info
  end
  if next(logic_lobby_home_entry_item.treeActiveMapOffLine) then
    info.bShow = true
    info.redType = type
    info.redModule = logic_lobby_home_entry_item.eRedDotModule.TreeActiveOffLine
    info.iconPath = redDotIconMap.TreeInteractive
    return info
  end
  type = logic_lobby_home_entry_item.eRedDotType.Message
  if next(logic_lobby_home_entry_item.leaveMessageMapOnLine) then
    info.bShow = true
    info.redType = type
    info.redModule = logic_lobby_home_entry_item.eRedDotModule.LeaveMessageOnLine
    info.iconPath = redDotIconMap.Message
    return info
  end
  if next(logic_lobby_home_entry_item.leaveMessageMapOffLine) then
    info.bShow = true
    info.redType = type
    info.redModule = logic_lobby_home_entry_item.eRedDotModule.LeaveMessageOffLine
    info.iconPath = redDotIconMap.Message
    return info
  end
  local logic_home_car_parking_gift = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking_gift)
  local logic_home_car_parking = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking)
  local session = logic_home_car_parking:GetSessionConfig()
  if session and logic_home_car_parking_gift:hasGift() then
    log(bWriteLog and "logic_home_entrance_red_dot.GetHomeEntranceRedDotInfo parking gift")
    type = logic_lobby_home_entry_item.eRedDotType.Gift
    typeModule = logic_lobby_home_entry_item.eRedDotModule.HomeParkingGift
    local fileTb = logic_lobby_home_entry_item_File.LoadFile()
    local tLastClick = fileTb.show_info[typeModule]
    if tLastClick then
      local curTime = TimeUtil.GetServerTimeInSec()
      if TimeUtil.IsSameDay(curTime, tLastClick) then
        return info
      else
        info.bShow = true
        info.redType = type
        info.redModule = typeModule
        info.iconPath = redDotIconMap.Gift
        return info
      end
    else
      info.bShow = true
      info.redType = type
      info.redModule = typeModule
      info.iconPath = redDotIconMap.Gift
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
      log(bWriteLog and "logic_home_entrance_red_dot.GetHomeEntranceRedDotInfo home idle vehicle")
      type = logic_lobby_home_entry_item.eRedDotType.HomeIdleVehicle
      typeModule = logic_lobby_home_entry_item.eRedDotModule.HomeIdleVehicle
      local fileTb = logic_lobby_home_entry_item_File.LoadFile()
      local tLastClick = fileTb.show_info[typeModule]
      if tLastClick then
        local curTime = TimeUtil.GetServerTimeInSec()
        if TimeUtil.IsSameDay(curTime, tLastClick) then
          return info
        else
          info.bShow = true
          info.redType = type
          info.redModule = typeModule
          info.iconPath = redDotIconMap.HomeIdleVehicle
          return info
        end
      else
        info.bShow = true
        info.redType = type
        info.redModule = typeModule
        info.iconPath = redDotIconMap.HomeIdleVehicle
        return info
      end
    end
  end
  local logic_home_smart_upgrade = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_smart_upgrade)
  if logic_home_smart_upgrade:CheckCanSmartUpgradeFull() then
    type = logic_lobby_home_entry_item.eRedDotType.HomeUpgrade
    typeModule = logic_lobby_home_entry_item.eRedDotModule.HomeCanLevelUp
    local fileTb = logic_lobby_home_entry_item_File.LoadFile()
    local tLastClick = fileTb.show_info[typeModule]
    if tLastClick then
      local tNow = TimeUtil.GetServerTimeInSec()
      local tDis = tNow - tLastClick
      log(bWriteLog and "logic_home_entrance_red_dot.GetShowInfo tDis = " .. tDis)
      local cfgText = CDataTable.GetTableData("PlanPH_Bubble_Text", 23)
      if 0 <= tDis and tDis <= cfgText.showCD * 3600 then
        return info
      end
    end
    info.bShow = true
    info.redType = type
    info.redModule = logic_lobby_home_entry_item.eRedDotModule.HomeCanLevelUp
    info.iconPath = redDotIconMap.HomeUpgrade
    return info
  end
  return info
end
return logic_home_entrance_red_dot