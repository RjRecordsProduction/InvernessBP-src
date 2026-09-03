local logic_module_mix_lucky = {}
function logic_module_mix_lucky:RegistEvents()
  logic_module_mix_lucky.__super.RegistEvents(self)
  log(bWriteLog and "logic_module_mix_lucky RegistEvents")
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LUCKY_MIX, self.OnJumpLuckyMix, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LUCKY_SCRAP_GOLD, self.OnJumpLuckyScrapGold, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_COMMON_PREVIEW_EXCHANGE, self.OnJumpExchange, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LUCKY_MULTI, self.OnJumpLuckyMuiti, self)
end
function logic_module_mix_lucky:OnJumpLuckyMuiti(_, __, vars)
  local logic_luckymulti_activity = require("client.slua.logic.lobby_activity.logic_luckymulti_activity")
  logic_luckymulti_activity.OpenMainUI(_, _, vars)
end
function logic_module_mix_lucky:OnJumpLuckyMix(_, __, vars)
  local logic_luckmix_activity = require("client.slua.logic.lobby_activity.logic_luckmix_activity")
  logic_luckmix_activity.OpenMainUI(_, _, vars)
end
function logic_module_mix_lucky:OnJumpLuckyScrapGold()
  log_warning(bWriteLog and "  : OnJumpLuckyScrapGold")
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  special_offer_module:OpenGolden()
end
function logic_module_mix_lucky:OnJumpExchange(_, __, vars)
  local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
  logic_scrapgold_draw.OpenExchangeStore(vars)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_module_mix_lucky = class(CModuleBase, nil, logic_module_mix_lucky)
return Clogic_module_mix_lucky