local Collect_Guide_UIBP = {}
function Collect_Guide_UIBP:ctor(_, callback)
  self.end
function Collect_Guide_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Experience, self.OnClickButton_Experience, self)
  self:AddOnClickedEventByControl(self.UIRoot.Common_Popup_Theme_UIBP.Button_Close, self.OnClickButton_Close, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_MAIN_DATA, self.UpdateUI, self)
end
function Collect_Guide_UIBP:OnPostInitialize()
  self.UIRoot.Common_Popup_Theme_UIBP.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(77550))
  self:SetWidgetVisible(self.UIRoot.Common_Popup_Theme_UIBP.Button_Skip, false)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module.collect_data then
    self:UpdateUI()
  else
    local CollectHandler = require("client.network.Protocol.CollectHandler")
    CollectHandler.send_get_collect_sys_main_data_req()
  end
end
function Collect_Guide_UIBP:OnClose()
  self:SetWidgetVisible(self.UIRoot.Common_Popup_Theme_UIBP.Button_Skip, true, true)
end
function Collect_Guide_UIBP:UpdateUI()
  log(bWriteLog and "Collect_Guide_UIBP:UpdateUI")
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local season = collect_module:GetSeasonId()
  local TableUtil = require("common.table_util")
  local score = TableUtil.GetTableValue(collect_module.collect_data.season_score, season) or 0
  local sLevel = collect_module:GetSeasonLevelByScore(score)
  local curLevel, dan = collect_module:GetLevelByScore(collect_module.collect_data.total_score)
  self.UIRoot.Collect_Level_Item_UIBP:InitExquisiteCollectBadge(DataMgr.roleData.uid, {
    seasonLevel = sLevel,
    rank = dan,
    totalLevel = curLevel
  })
end
function Collect_Guide_UIBP:OnClickButton_Close()
  self:PlayAudio(sound_config.click_v1)
  if self.callback then
    self.callback()
  end
  self:CloseSelf()
end
function Collect_Guide_UIBP:OnClickButton_Experience()
  self:PlayAudio(sound_config.click_v1)
  self:CloseSelf()
  GlobalData.JumpUrl("game://?module=1002300&index=16")
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCollect_Guide_UIBP = class(ui_base, nil, Collect_Guide_UIBP)
return CCollect_Guide_UIBP