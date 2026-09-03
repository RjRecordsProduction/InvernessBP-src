local logic_account_sensitive_aciton = {}
local setting_macro = require("client.slua.logic.setting.setting_macro")
function logic_account_sensitive_aciton:DefineAndResetData()
  self.actionConfig = {
    [1] = {
      step = setting_macro.AccountSensitiveStep.Initiate,
      iconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Explain_png.Setting_Icon_Explain_png",
      targetUIConfig = {
        [setting_macro.AccountNewOperationType.BindSocial] = UIManager.UI_Config.Setting_BindChoice_Panel_New,
        [setting_macro.AccountNewOperationType.FirstBindMail] = UIManager.UI_Config.Setting_Bind_Email_Popup_UIBP,
        [setting_macro.AccountNewOperationType.FirstBindPhone] = UIManager.UI_Config.Setting_Bind_Email_Popup_UIBP,
        [setting_macro.AccountNewOperationType.ChangeBindMail] = UIManager.UI_Config.Setting_Bind_Email_Popup_UIBP,
        [setting_macro.AccountNewOperationType.ChangeBindPhone] = UIManager.UI_Config.Setting_Bind_Email_Popup_UIBP,
        [setting_macro.AccountNewOperationType.ExtraBindMail] = UIManager.UI_Config.Setting_Bind_Email_Popup_UIBP,
        [setting_macro.AccountNewOperationType.ExtraBindPhone] = UIManager.UI_Config.Setting_Bind_Email_Popup_UIBP,
        [setting_macro.AccountNewOperationType.UnBindSocial] = UIManager.UI_Config.Setting_UnbindPopup_New,
        [setting_macro.AccountNewOperationType.FastUnBindSocail] = UIManager.UI_Config.Setting_UnbindPopup_New,
        [setting_macro.AccountNewOperationType.GuestGuide] = UIManager.UI_Config.Setting_BindMailbox_Panel_UIBP,
        [setting_macro.AccountNewOperationType.BindSocialRemind] = UIManager.UI_Config.Setting_BindMailbox_Panel_UIBP,
        [setting_macro.AccountNewOperationType.CEBindSocial] = UIManager.UI_Config.Setting_CE_Bind_UIBP
      }
    },
    [2] = {
      step = setting_macro.AccountSensitiveStep.Verify,
      iconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Safe_png.Setting_Icon_Safe_png",
      targetUIConfig = UIManager.UI_Config.Setting_Verify_Item_UIBP
    },
    [3] = {
      step = setting_macro.AccountSensitiveStep.Execute,
      iconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Replace_png.Setting_Icon_Replace_png",
      targetUIConfig = {
        [setting_macro.AccountNewOperationType.BindSocial] = UIManager.UI_Config.Setting_BindChoice_Panel_New,
        [setting_macro.AccountNewOperationType.FirstBindMail] = UIManager.UI_Config.Setting_login_phone_UIBP,
        [setting_macro.AccountNewOperationType.FirstBindPhone] = UIManager.UI_Config.Setting_login_phone_UIBP,
        [setting_macro.AccountNewOperationType.ChangeBindMail] = UIManager.UI_Config.Setting_Change_Bind_Popup_UIBP,
        [setting_macro.AccountNewOperationType.ChangeBindPhone] = UIManager.UI_Config.Setting_Change_Bind_Popup_UIBP,
        [setting_macro.AccountNewOperationType.ExtraBindMail] = UIManager.UI_Config.Setting_login_phone_UIBP,
        [setting_macro.AccountNewOperationType.ExtraBindPhone] = UIManager.UI_Config.Setting_login_phone_UIBP,
        [setting_macro.AccountNewOperationType.UnBindSocial] = UIManager.UI_Config.Setting_UnBindChoice_Panel,
        [setting_macro.AccountNewOperationType.FastUnBindSocail] = UIManager.UI_Config.Setting_UnBindChoice_Panel
      }
    },
    [4] = {
      step = setting_macro.AccountSensitiveStep.Complete,
      iconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_FeedBack_png.Setting_Icon_FeedBack_png",
      targetUIConfig = {
        [setting_macro.AccountNewOperationType.BindSocial] = UIManager.UI_Config.Setting_BindChoice_Panel_New,
        [setting_macro.AccountNewOperationType.FirstBindMail] = UIManager.UI_Config.Setting_Result_Item_UIBP,
        [setting_macro.AccountNewOperationType.FirstBindPhone] = UIManager.UI_Config.Setting_Result_Item_UIBP,
        [setting_macro.AccountNewOperationType.ChangeBindMail] = UIManager.UI_Config.Setting_Result_Item_UIBP,
        [setting_macro.AccountNewOperationType.ChangeBindPhone] = UIManager.UI_Config.Setting_Result_Item_UIBP,
        [setting_macro.AccountNewOperationType.ExtraBindMail] = UIManager.UI_Config.Setting_Result_Item_UIBP,
        [setting_macro.AccountNewOperationType.ExtraBindPhone] = UIManager.UI_Config.Setting_Result_Item_UIBP,
        [setting_macro.AccountNewOperationType.UnBindSocial] = UIManager.UI_Config.Setting_UnBindChoice_Panel,
        [setting_macro.AccountNewOperationType.FastUnBindSocail] = UIManager.UI_Config.Setting_UnBindChoice_Panel
      }
    }
  }
  self.curOPSerialNo = 0
  self:ResetData()
  self.text_id = 76941
end
function logic_account_sensitive_aciton:OnInitialize()
end
function logic_account_sensitive_aciton:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACCOUNT_SENSITIVE_ACTION, self.ShowSAPopUI, self)
end
function logic_account_sensitive_aciton:OnLogin(bReLogin)
  if bReLogin then
    local ui = UIManager.GetUI(UIManager.UI_Config.Setting_Common_Popup_Large_UIBP)
    if ui then
      ui:CloseSelf()
    end
  end
end
function logic_account_sensitive_aciton:OnLogOut()
end
function logic_account_sensitive_aciton:OnPreSwitchGameStatus(preState, nextState)
end
function logic_account_sensitive_aciton:OnPostSwitchGameStatus(preState, nextState)
end
function logic_account_sensitive_aciton:SetGMCheckStatus(status)
  self.GMCheckStatus = status
end
function logic_account_sensitive_aciton:GetGMCheckStatus()
  return self.GMCheckStatus
end
function logic_account_sensitive_aciton:SetGMSkipAction(status)
  self.GMSkipAction = status
end
function logic_account_sensitive_aciton:GetGMSkipAction()
  return self.GMSkipAction
end
function logic_account_sensitive_aciton:CheckAccountLegal(type, account)
  local checkType = 1
  if type == 1 then
    checkType = 2
  end
  local StringUtil = require("common.string_util")
  if account == "" or not StringUtil.CheckStringLegal(account, checkType) then
    return false
  end
  local accountLen = StringUtil.GetCharactersLength(StringUtil.StrTrim(account))
  if type == 2 and (not (5 <= accountLen) or not (accountLen <= 50)) then
    return false
  elseif type == 1 and (not (5 <= accountLen) or not (accountLen <= 15)) then
    return false
  end
  return true
end
function logic_account_sensitive_aciton:ShowSAPopUI(_, _, params)
  log_tree(bWriteLog and "logic_account_sensitive_aciton:ShowSAPopUI params", params)
  local jump_utils = require("client.logic.store.jump_utils")
  jump_utils.OpenJumpModule(BP_ENUM_MODULE_SETTING)
  local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
  if not logic_account_sensitive_aciton:IsGrayNew() then
    UIManager.ShowUI(UIManager.UI_Config.setting_bindchoice_panel)
  else
    local opType = params and tonumber(params.type)
    if opType then
      local bIsExtraBind = logic_account_sensitive_aciton:CheckbIsExtraBind()
      if bIsExtraBind then
        if opType == setting_macro.AccountNewOperationType.FirstBindMail then
          opType = setting_macro.AccountNewOperationType.ExtraBindMail
        elseif opType == setting_macro.AccountNewOperationType.FirstBindPhone then
          opType = setting_macro.AccountNewOperationType.ExtraBindPhone
        end
      end
      self:ShowCommonPopupUI(opType)
    end
  end
end
function logic_account_sensitive_aciton:CanFastUnbind()
  local fastUnbindInfo = self.fastUnbindInfo
  if not fastUnbindInfo then
    return false, false
  end
  if not fastUnbindInfo.is_open then
    return false, false
  end
  for _, v in pairs(fastUnbindInfo.cond or {}) do
    if v.satisfy then
      return true, true
    end
  end
  return true, false
end
function logic_account_sensitive_aciton:JumpToFeedbackH5()
  local BusinessHelper = import("BusinessHelper")
  local iEnv = BusinessHelper.GetIMSDKEnv()
  local url = FuncUtil.GetDomainByID(3366217)
  if iEnv == 1 then
    url = FuncUtil.GetDomainByID(3366218)
  end
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local openID = webModule:GetEncryptedDeviceInfoUrlValue(3, "{openid}")
  local deviceID = webModule:GetEncryptedDeviceInfoUrlValue(3, "{device_id}")
  local clientIP = Client.GetIpAddr()
  local serialNo = self.curOPSerialNo
  local token = Client.GetToken(NetInterface)
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local langType = webModule:GetCurrentLanguage()
  local params = "?openID=%s&deviceID=%s&clientIP=%s&serialNo=%s&token=%s&langType=%s"
  params = string.format(params, openID, deviceID, clientIP, serialNo, token, langType)
  url = url .. params
  log(bWriteLog and string.format("logic_account_sensitive_aciton:JumpToFeedbackH5, url:%s", url))
  GlobalData.JumpWebUrl(url)
end
function logic_account_sensitive_aciton:IsGrayNew()
  if not LobbySystem.roleData then
    return
  end
  log(bWriteLog and string.format("logic_account_sensitive_aciton:IsGrayNew, LobbySystem.roleData.account_operate_gray:%s", LobbySystem.roleData.account_operate_gray))
  return LobbySystem.roleData.account_operate_gray
end
function logic_account_sensitive_aciton:IsGrayUnbindNew()
  if not LobbySystem.roleData then
    return
  end
  if not LobbySystem.roleData.unbind_social_account then
    return
  end
  log(bWriteLog and string.format("logic_account_sensitive_aciton:IsGrayNew, LobbySystem.roleData.unbind_social_account.new_operate_ver:%s", LobbySystem.roleData.unbind_social_account.new_operate_ver))
  return LobbySystem.roleData.unbind_social_account.new_operate_ver
end
function logic_account_sensitive_aciton:GetUnbindCDDay()
  if self:IsGrayUnbindNew() then
    return 3
  else
    return 7
  end
end
function logic_account_sensitive_aciton:ShowCommonPopupUI(opType)
  UIManager.ShowUI(UIManager.UI_Config.Setting_Common_Popup_Large_UIBP, opType)
end
function logic_account_sensitive_aciton:CheckbIsExtraBind()
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local accountData = SettingAccount.GetSettingAccountData()
  if accountData.bind_mail or accountData.bind_phone then
    return true
  end
  return false
end
function logic_account_sensitive_aciton:GetActionConfig()
  return self.actionConfig
end
function logic_account_sensitive_aciton:GetCurStep()
  return self.curStep
end
function logic_account_sensitive_aciton:SetCurStep(step, bHideProgress)
  self.curStep = step
  EventSystem:postEvent(EVENTTYPE_BIND_INTL, EVENTID_INTL_SENSITIVE_OP_STEP_CHANGE, step, bHideProgress)
end
function logic_account_sensitive_aciton:BindSuccessRsp()
  log(bWriteLog and "logic_account_sensitive_aciton:BindSuccessRsp.  ")
  local ui = UIManager.GetUI(UIManager.UI_Config.Setting_Common_Popup_Large_UIBP)
  if ui then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Setting_Common_Popup_Large_UIBP, 10)
end
function logic_account_sensitive_aciton:SetCurOPChannel(channelID)
  self.curOPChannel = channelID
end
function logic_account_sensitive_aciton:GetCurOPChannel(channelID)
  return self.curOPChannel
end
function logic_account_sensitive_aciton:ResetData()
  self.curStep = setting_macro.AccountSensitiveStep.Initiate
  self.curOPChannel = 0
end
function logic_account_sensitive_aciton:OnBindSuccess()
  self:SetCurStep(setting_macro.AccountSensitiveStep.Complete)
end
function logic_account_sensitive_aciton:GetFastUnbindInfo()
  return self.fastUnbindInfo
end
function logic_account_sensitive_aciton:CheckShowBindRemind(text_id, popup_cd_days, end_time)
  log(bWriteLog and "logic_account_sensitive_aciton:CheckShowBindRemind. text_id: " .. tostring(text_id))
  log(bWriteLog and "logic_account_sensitive_aciton:CheckShowBindRemind. popup_cd_days: " .. tostring(popup_cd_days))
  self.  self.  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if end_time and end_time < serverTime then
    log(bWriteLog and "logic_account_sensitive_aciton:CheckShowBindRemind.  end_time < serverTime")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountBindPopup)
  local time = saveData and saveData.time
  if time and TimeUtil.WithinInNDay(time, popup_cd_days) then
    log(bWriteLog and "logic_account_sensitive_aciton:CheckShowBindRemind.  is in cd")
    return
  end
  self:CancelFaceSlap()
  self.nCheckFace = self:AddTimerLoop(1, function()
    self:CheckFaceSlap()
  end, TIMER_INFINITE, 1)
end
function logic_account_sensitive_aciton:CheckFaceSlap()
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if not NewFaceSlapSystem:IsSlapEnd() then
    log(bWriteLog and "logic_account_sensitive_aciton:CheckFaceSlap.  not NewFaceSlapSystem:IsSlapEnd()")
    return
  end
  if not UIManager.IsAndroidStackEmpty() then
    log(bWriteLog and "logic_account_sensitive_aciton:CheckFaceSlap.  not UIManager.IsAndroidStackEmpty()")
    return
  end
  self:CancelFaceSlap()
  self:ShowCommonPopupUI(setting_macro.AccountNewOperationType.BindSocialRemind)
end
function logic_account_sensitive_aciton:CancelFaceSlap()
  if self.nCheckFace then
    self:RemoveTimer(self.nCheckFace)
    self.nCheckFace = nil
  end
end
function logic_account_sensitive_aciton:send_account_operate_check_req(callback, op_type, op_channel)
  local AccountBindHandler = require("client.network.Protocol.AccountBindHandler")
  AccountBindHandler.send_account_operate_check_req(op_type, op_channel):Then(callback)
end
function logic_account_sensitive_aciton:BindSocialReq(channel, sparams, bind_params)
  local AccountBindHandler = require("client.network.Protocol.AccountBindHandler")
  AccountBindHandler.send_account_operate_start_req(setting_macro.AccountNewOperationType.BindSocial, sparams, channel, bind_params.account, bind_params.account_type, bind_params.verify_code, bind_params.area_code, false)
end
function logic_account_sensitive_aciton:UnBindSocialReq(callback, channel, is_imm)
  local AccountBindHandler = require("client.network.Protocol.AccountBindHandler")
  local type = setting_macro.AccountNewOperationType.UnBindSocial
  if is_imm then
    type = setting_macro.AccountNewOperationType.FastUnBindSocail
  end
  AccountBindHandler.send_account_operate_start_req(type, nil, channel, nil, nil, nil, nil, is_imm):Then(callback)
end
function logic_account_sensitive_aciton:BindSelfBuildReq(sparams, sacc_params)
  local AccountBindHandler = require("client.network.Protocol.AccountBindHandler")
  local opType = setting_macro.AccountNewOperationType.FirstBindMail
  if sacc_params.account_type == 2 then
    opType = setting_macro.AccountNewOperationType.FirstBindPhone
  end
  AccountBindHandler.send_account_operate_start_req(opType, sparams, BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT, sacc_params.account, sacc_params.account_type, sacc_params.verify_code, sacc_params.area_code, false)
end
function logic_account_sensitive_aciton:ChangeBindSelfBuildReq(opType, account, verify_code, area_code)
  local AccountBindHandler = require("client.network.Protocol.AccountBindHandler")
  local account_type = 1
  if opType == setting_macro.AccountNewOperationType.ChangeBindPhone then
    account_type = 2
  end
  AccountBindHandler.send_account_operate_start_req(opType, nil, BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT, account, account_type, verify_code, area_code, false)
end
function logic_account_sensitive_aciton:ExtraBindSelfBuildReq(sparams, sacc_params)
  local AccountBindHandler = require("client.network.Protocol.AccountBindHandler")
  local opType = setting_macro.AccountNewOperationType.ExtraBindMail
  if sacc_params.account_type_modify == 2 then
    opType = setting_macro.AccountNewOperationType.ExtraBindPhone
  end
  AccountBindHandler.send_account_operate_start_req(opType, sparams, BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT, sacc_params.account_modify, sacc_params.account_type_modify, sacc_params.verify_code_modify, sacc_params.area_code_modify, false)
end
function logic_account_sensitive_aciton:on_account_operate_get_serialno_rsp(serial_no)
  self.curOPSerialNo = serial_no
end
function logic_account_sensitive_aciton:ReportPlayerAction(opType, reason)
  if self.curOPSerialNo == 0 then
    log(bWriteLog and "logic_account_sensitive_aciton:ReportPlayerAction return of curOPSerialNo == 0")
    return
  end
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_report_account_group_log(0, tostring(reason), opType, self.curOPChannel, self.curOPSerialNo, self.curStep)
end
function logic_account_sensitive_aciton:on_get_unbind_social_info_rsp(err, fast_unbind_info)
  if err ~= 0 then
    self.fastUnbindInfo = {is_open = false}
    return
  end
  self.fastUnbindInfo = fast_unbind_info or {is_open = false}
end
function logic_account_sensitive_aciton:on_only_social_bind_notify(only_bind_channel_id, emails)
  log_tree("logic_account_sensitive_aciton:on_only_social_bind_notify. emails ", emails)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  PlayerPrefsSystem.SaveTableToFile_N({
    channelId = only_bind_channel_id,
    time = TimeUtil.GetServerTimeInSec(),
      }, PlayerPrefsSystem.ePlayerPrefsType.eAccountBindSocialRemind)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_account_sensitive_aciton = class(CModuleBase, nil, logic_account_sensitive_aciton)
return Clogic_account_sensitive_aciton