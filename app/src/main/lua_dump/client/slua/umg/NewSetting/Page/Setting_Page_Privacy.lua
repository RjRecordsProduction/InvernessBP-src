local Setting_Page_Privacy = {}
function Setting_Page_Privacy:ctor(_, _PendingOpenPageParam)
  Setting_Page_Privacy.__super.ctor(self, _)
  if _PendingOpenPageParam and _PendingOpenPageParam.jumpKey then
    self.jumpKey = _PendingOpenPageParam.jumpKey
  end
end
function Setting_Page_Privacy:OnInitialize()
  Setting_Page_Privacy.__super.OnInitialize(self)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_get_peakgame_anchor_setting_req()
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  CollectHandler.send_get_collect_sys_privacy_req()
end
function Setting_Page_Privacy:RegisterEvents()
  Setting_Page_Privacy.__super.RegisterEvents(self)
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  if logic_lbs_warzone:CheackIsOpenZoneGPS() then
    self:AddCommonEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_LOCATION_INFO, self.OnGPSLBSInfoChenged, self)
  end
end
function Setting_Page_Privacy:OnPostInitialize()
  if self.jumpKey then
    self.bLoadStackByFrame = false
  end
  Setting_Page_Privacy.__super.OnPostInitialize(self)
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  logic_lbs_warzone:InitLocationInterface()
  local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
  logic_team_evaluation_view.send_get_evaluation_req(tonumber(DataMgr.roleData.uid))
end
function Setting_Page_Privacy:OnGPSLBSInfoChenged(_, _, msgType)
  log(bWriteLog and "Setting_Page_Privacy:OnGPSLBSInfoChenged msgType" .. tostring(msgType))
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  logic_lbs_warzone:ShowMsgBoxMgr(msgType)
end
function Setting_Page_Privacy:OnStackLoaded()
  if self.jumpKey then
    log(bWriteLog and "Setting_Page_Privacy:OnStackLoaded jumpKey " .. tostring(self.jumpKey))
    local itemUI = self:GetItemUI(self.jumpKey)
    if itemUI and itemUI.UIRoot then
      self.StackContainerWidget:ScrollWidgetIntoView(itemUI.UIRoot, true, UEnums.EDescendantScrollDestination.TopOrLeft)
    end
    self.jumpKey = nil
  end
end
local class = require("class")
local Setting_StackContainer = require("client.slua.umg.NewSetting.Page.Setting_StackContainer")
return class(Setting_StackContainer, nil, Setting_Page_Privacy)