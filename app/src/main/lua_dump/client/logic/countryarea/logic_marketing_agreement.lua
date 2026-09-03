local logic_marketing_agreement = {}
function logic_marketing_agreement:DefineAndResetData()
  self.hasCheck = false
  self.bAgree = false
  self.hasSend = false
  self.timer_loop = nil
  log(bWriteLog and "logic_marketing_agreement:DefineAndResetData. Data initialized successfully")
end
function logic_marketing_agreement:OnInitialize()
  self:LoadPlayerPrefs()
end
function logic_marketing_agreement:LoadPlayerPrefs()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAgreeMarketingAgreement) or {}
  self.hasCheck = cfg.hasCheck == true
  self.bAgree = cfg.bAgree == true
  log_format("logic_marketing_agreement:LoadPlayerPrefs. Data loaded successfully. hasCheck:%s bAgree:%s", tostring(self.hasCheck), tostring(self.bAgree))
end
function logic_marketing_agreement:OnEnterLobby(needUpdateRole)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsGlobalVersion() then
    log(bWriteLog and "logic_marketing_agreement:OnEnterLobby not global version")
    return
  end
  log(bWriteLog and string.format("logic_marketing_agreement:OnEnterLobby. hasSend:%s", tostring(self.hasSend)))
  if self.hasSend then
    return
  end
  log(bWriteLog and string.format("logic_marketing_agreement:OnEnterLobby. needUpdateRole:%s", tostring(needUpdateRole)))
  if needUpdateRole then
    self.timer_loop = self:AddTimerLoop(0, function()
      if self.hasSend then
        if self.timer_loop then
          self:RemoveTimer(self.timer_loop)
        end
        return
      end
      if UIManager.IsUIShow(UIManager.UI_Config.Lobby_CreatRole) then
        return
      else
        self:AddTimer(60, function()
          self:send_report_marketing_agreement(self.bAgree)
        end)
        if self.timer_loop then
          self:RemoveTimer(self.timer_loop)
          return
        end
      end
    end, TIMER_INFINITE, 5)
  else
    self:AddTimer(60, function()
      self:send_report_marketing_agreement(self.bAgree)
    end)
  end
end
function logic_marketing_agreement:send_report_marketing_agreement(is_agree)
  local MarketingAgreementHandler = require("client.network.Protocol.MarketingAgreementHandler")
  log_format("logic_marketing_agreement:send_report_marketing_agreement. Sending agreement report. is_agree:%s", tostring(is_agree))
  MarketingAgreementHandler.send_report_marketing_agreement(is_agree)
end
function logic_marketing_agreement:proc_report_marketing_agreement_rsp(ret)
  log(bWriteLog and string.format("logic_marketing_agreement:proc_report_marketing_agreement_rsp. ret:%s", tostring(ret)))
  if ret == 0 then
    self.hasSend = true
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_marketing_agreement = class(CModuleBase, nil, logic_marketing_agreement)
return Clogic_marketing_agreement