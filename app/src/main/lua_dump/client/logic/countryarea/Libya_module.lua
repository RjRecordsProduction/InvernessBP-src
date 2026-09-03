local Libya_module = {}
local LY = "LY"
local backLogin = function()
  local login = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login:backLogin()
end
local agreeFunc = function()
  log_warning(bWriteLog and "  .Libya_module agreeFunc ")
  DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LIBYA, 1)
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.GoToFaceSlapSystem()
end
local disagreeFunc = function()
  local title = LocUtil.GetLocalizeResStr(101001)
  local text = LocUtil.GetLocalizeResStr(4485)
  local cancelBtn = LocUtil.GetLocalizeResStr(4486)
  local okBtn = LocUtil.GetLocalizeResStr(4410)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, text, function()
    local Libya = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Libya_module)
    Libya:AskIfShowAgreement()
  end, backLogin, okBtn, cancelBtn)
end
function Libya_module:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SET_REGION_OK, self.OnInitRegionSetting, self)
end
function Libya_module:OnInitRegionSetting()
  log_warning(bWriteLog and "  Libya_module:OnInitRegionSetting. DataMgr.RegionData.region " .. tostring(DataMgr.RegionData.region))
  if DataMgr.RegionData.region == LY then
    self:AskIfShowAgreement()
  end
end
function Libya_module:AskIfShowAgreement()
  log_warning(bWriteLog and string.format("Libya_module:AskIfShowAgreement."))
  local bHasGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LIBYA, 1)
  if not bHasGuide then
    log_warning(bWriteLog and string.format("Libya_module:AskIfShowAgreement.  not"))
    return
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local text = LocUtil.GetLocalizeResStr(66533)
  local okWord = LocUtil.GetLocalizeResStr(38930)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, text, agreeFunc, disagreeFunc, okWord, nil)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLibya_module = class(CModuleBase, nil, Libya_module)
return CLibya_module