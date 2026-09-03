local logic_home_status = {}
function logic_home_status:DefineAndResetData()
  self.manorDetail = nil
end
function logic_home_status:IsHomeVisitMode(subModeID)
  local home_macros = require("client.slua.logic.home.home_macros")
  local isIn = false
  if subModeID then
    isIn = subModeID == home_macros.Home_SubMode.Visit
  end
  log(bWriteLog and "logic_home_status:IsHomeVisitMode " .. tostring(isIn))
  return isIn
end
function logic_home_status:IsHomeBuildMode(subModeID)
  local home_macros = require("client.slua.logic.home.home_macros")
  local isIn = false
  if subModeID then
    isIn = subModeID == home_macros.Home_SubMode.EditHome or subModeID == home_macros.Home_SubMode.EditPlan or subModeID == home_macros.Home_SubMode.EditPlan_Standalone
  end
  log(bWriteLog and "logic_home_status:IsHomeBuildMode " .. tostring(isIn))
  return isIn
end
function logic_home_status:CheckEnterHome(uid, keyList, detail)
  log(bWriteLog and "logic_home_status:CheckEnterHome")
  self.manorDetail = detail
  if not self.manorDetail then
    log(bWriteLog and "logic_home_status:CheckEnterHome not detail")
    return
  end
  local gotoFuc = function()
    self:ShowEnterHomePopUp(uid)
  end
  local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
  logic_home_download.CheckHomeDownloadedDone(uid, gotoFuc)
end
function logic_home_status:ShowEnterHomePopUp(uid)
  log(bWriteLog and "logic_home_status:ShowEnterHomePopUp")
  local name = ""
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile then
    name = profile.nickName
  end
  local okCallBack = function()
    local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
    logic_home_entry:FollowEnterManor(uid, self.manorDetail.manorOwnerId, self.manorDetail.manorInstId)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, nil, LocUtil.LocalizeResFormat(655311, name), okCallBack)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_home_status)
return CModuleTemplate