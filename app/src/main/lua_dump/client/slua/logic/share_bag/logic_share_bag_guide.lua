local logic_share_bag_guide = {
  SHARE_TYPE_SUBSCRIPBE = 1,
  GUIDETYPE_SUBSCRIBE_WARDROBE = 1,
  GUIDETYPE_SUBSCRIBE_TEAM_USE_FRIEND = 2,
  GUIDETYPE_SUBSCRIBE_NON_FRIEND_TEAM_MAIN = 3,
  GUIDETYPE_SUBSCRIBE_NON_FRIEND_TEAM_SUB = 4,
  GUIDE_SHOWSTATUS_UNKNOW = -1,
  GUIDE_SHOWSTATUS_NOT = 0,
  GUIDE_SHOWSTATUS_HAS_SHOWN = 1
}
function logic_share_bag_guide:DefineAndResetData()
end
function logic_share_bag_guide:OnLogOut()
  self:ClearData()
end
function logic_share_bag_guide:GetShareBagGuideStatus(shareType, guideType)
  if not shareType or not guideType then
    return logic_share_bag_guide.GUIDE_SHOWSTATUS_UNKNOW
  end
  if not self.shareBagGuideStatus then
    self.shareBagGuideStatus = {}
  end
  if not self.shareBagGuideStatus[shareType] then
    self:ReqGetShareBagTipsData(shareType)
    return logic_share_bag_guide.GUIDE_SHOWSTATUS_UNKNOW
  end
  return self.shareBagGuideStatus[shareType][guideType] or logic_share_bag_guide.GUIDE_SHOWSTATUS_NOT
end
function logic_share_bag_guide:SetShareBagGuideStatus(shareType, guideType, showStatus)
  if not shareType or not guideType then
    return
  end
  if showStatus ~= logic_share_bag_guide.GUIDE_SHOWSTATUS_NOT and showStatus ~= logic_share_bag_guide.GUIDE_SHOWSTATUS_HAS_SHOWN then
    return
  end
  if not self.shareBagGuideStatus or not self.shareBagGuideStatus[shareType] then
    return
  end
  if self.shareBagGuideStatus[shareType][guideType] ~= showStatus then
    self.shareBagGuideStatus[shareType][guideType] = showStatus
    self:ReqSetShareBagTipsData(shareType, guideType, showStatus)
  end
end
function logic_share_bag_guide:ClearData()
  self.shareBagGuideStatus = nil
end
function logic_share_bag_guide:ReqGetShareBagTipsData(shareType)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_get_shared_backpack_guide_status_req(shareType)
end
function logic_share_bag_guide:OnGetShareBagTipsDataRsp(shareType, statusTable)
  if not shareType then
    return
  end
  if not self.shareBagGuideStatus then
    self.shareBagGuideStatus = {}
  end
  self.shareBagGuideStatus[shareType] = statusTable or {}
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARED_BAG_GUIDE_STATUS, shareType, self.shareBagGuideStatus[shareType])
end
function logic_share_bag_guide:ReqSetShareBagTipsData(shareType, guideType, status)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_set_shared_backpack_guide_status_req(shareType, guideType, status)
end
function logic_share_bag_guide:OnSetShareBagTipsDataRsp(shareType, guideType, status)
  if not shareType or not guideType then
    return
  end
  if not self.shareBagGuideStatus then
    self.shareBagGuideStatus = {}
  end
  if not self.shareBagGuideStatus[shareType] then
    self.shareBagGuideStatus[shareType] = {}
  end
  self.shareBagGuideStatus[shareType][guideType] = status
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_share_bag_guide = class(CModuleBase, nil, logic_share_bag_guide)
return Clogic_share_bag_guide