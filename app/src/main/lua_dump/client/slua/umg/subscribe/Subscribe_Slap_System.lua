local Subscribe_Slap_System = {}
local canShow = true
local picUrlG = "/pictures/A8/ADA110D9107D22746B6284AC8D609977_pl/1_en.png"
local picUrlJK = "/pictures/common/V3.2_RP/1_en.png"
local picUrlB = "/pictures/A8/ADA110D9107D22746B6284AC8D609977_pl/3.3-subscription_Pop_IN.png"
local jumpUrl = "game://?module=" .. BP_ENUM_MODULE_PRIME
function Subscribe_Slap_System:DefineAndResetData()
end
function Subscribe_Slap_System:OnLogin()
end
function Subscribe_Slap_System:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    canShow = false
  end
end
function Subscribe_Slap_System:ShouldSlap()
  if not canShow then
    canShow = true
    return false
  end
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local isOpenSlap = subscribeModuleObj:IsOpenSubscribeSlap()
  if isOpenSlap == nil then
    return false
  end
  return isOpenSlap
end
function Subscribe_Slap_System:ShowSlap()
  local picUrl
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    picUrl = FuncUtil.GetDomainByID(3366052) .. picUrlB
  elseif PublishRegionMacros.IsJapanOrKorea() then
    picUrl = FuncUtil.GetDomainByID(3366036) .. picUrlJK
  else
    picUrl = FuncUtil.GetDomainByID(3366036) .. picUrlG
  end
  if picUrl == nil then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Subscribe_Slap_UIBP, picUrl, jumpUrl)
end
return Subscribe_Slap_System