local UnknowPassLevelupSystem = {
  HideCallBack = nil,
  ShowRPCallFunc = nil,
  delayShow = false,
  fAnnualCallBack = nil,
  fOldUserAwardCallBack = nil,
  bBlockCameraChange = false,
  isInExperienceUpgrading = false,
  bGmShowFriendPanel = false
}
local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
local numberPath = "/Game/UMG/Texture/Atlas/UnknowntrialUI_0_16_5/Frames/RP_%d_png.RP_%d_png"
local numberPathNormal = "/Game/UMG/Texture/Atlas/UnknowntrialUI_0_16_5/Frames/RP_%d_normal_png.RP_%d_normal_png"
function UnknowPassLevelupSystem.OpenLevelUpUI(ParamTable)
  log(bWriteLog and "UnknowPassLevelupSystem.OpenLevelUpUI-----")
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetRpResourceDownloadState() ~= ENUM_DownloadState.Done then
    ShowNotice(23951)
    return
  end
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  if not UnknowPassUtil.CheckVersionValid() then
    local text = LocUtil.LocalizeResFormat(25032)
    ShowNotice(text)
    return
  end
  if LobbySystem.CheckUseNewGuide() then
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    if not growthprojectMgrB.IsFinishAllNewGuide() then
      log(bWriteLog and "not growthprojectMgrB.IsFinishAllNewGuide")
      return
    end
  end
  local logic_player_return_slap = require("client.slua.logic.player_return.logic_player_return_slap")
  if logic_player_return_slap.CanShowFBUI() then
    log(bWriteLog and "UnknowPassLevelupSystem.OpenLevelUpUI not NewFaceSlapSystem:IsSlapEnd")
    return
  end
  log(bWriteLog and "OpenLevelUpUI GameStatus.IsInLobbyOrMainCity()-----")
  if GameStatus.IsInLobbyOrMainCity() then
    local ResourseVersion = UnknowPassUtil.GetVersionNumber()
    Client.SetImageVersionString("1_3_0", ResourseVersion)
    local levelupUI = UIManager.GetUI(UIManager.UI_Config.unknowpass_levelup)
    if levelupUI and levelupUI:IsShow() then
      log(bWriteLog and "unknowpass_levelup is Show")
    else
      local PufferConst = require("client.slua.logic.download.puffer_const")
      if PassDataSystem.GetRpResourceDownloadState() ~= PufferConst.ENUM_DownloadState.Done then
        return
      end
      log(bWriteLog and "ShowUI UIManager.UI_Config.unknowpass_levelup")
      UIManager.ShowUI(UIManager.UI_Config.unknowpass_levelup, 1, UnknowPassLevelupSystem.bBlockCameraChange, ParamTable)
      UnknowPassLevelupSystem.bBlockCameraChange = false
    end
  end
end
function UnknowPassLevelupSystem.BlockUICameraChange(bBlock)
  UnknowPassLevelupSystem.bBlockCameraChange = bBlock
end
function UnknowPassLevelupSystem.OpenUnlockUI()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetRpResourceDownloadState() ~= ENUM_DownloadState.Done then
    ShowNotice(23951)
    return
  end
  local levelupUI = UIManager.GetUI(UIManager.UI_Config.unknowpass_levelup)
  if levelupUI and levelupUI:IsShow() then
    levelupUI:ShowUnlockUI()
  else
    local PufferConst = require("client.slua.logic.download.puffer_const")
    if PassDataSystem.GetRpResourceDownloadState() ~= PufferConst.ENUM_DownloadState.Done then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.unknowpass_levelup, 2)
  end
end
function UnknowPassLevelupSystem.HideLevelUpUI(bDontChangeCamera)
  log(bWriteLog and "UnknowPassLevelupSystem.HideLevelUpUI")
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.unknowpass_levelup)
  end
end
function UnknowPassLevelupSystem.OnBuyPass(evenType, eventID, reward_list, buyId)
  log(bWriteLog and "UnknowPassLevelupSystem.OpenUnlockUI11")
  if reward_list and 0 < #reward_list then
    function UnknowPassLevelupSystem.HideCallBack()
      local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
      local itemList = UnknowPassUtil.GetAwardList(reward_list) or {}
      local tExtendData
      if UnknowPassLevelupSystem.fAnnualCallBack then
        tExtendData = {
          fCloseCallback = UnknowPassLevelupSystem.fAnnualCallBack
        }
      elseif UnknowPassLevelupSystem.fOldUserAwardCallBack then
        tExtendData = {
          fCloseCallback = UnknowPassLevelupSystem.fOldUserAwardCallBack
        }
      end
      log(bWriteLog and "UnknowPassLevelupSystem.OnBuyPass->itemList: " .. tostring(#itemList))
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_RPRewardGet(itemList, tExtendData)
    end
  end
  function UnknowPassLevelupSystem.ShowRPCallFunc()
    local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
    local BlackFridayRPGroupModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayRPGroupModule)
    if not UnknowPassTunnelSystem.isShowRP and not BlackFridayRPGroupModule:GetIsBlackFridayJumpToRPBuy() then
      log(bWriteLog and "[chub]UnknowPassLevelupSystem.ShowRPCallFunc(), UnknowPassTunnelSystem.isShowRP is false")
      UnknowPassTunnelSystem.ShowRP()
      local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
      PassPreviewSystem.ShowExistPanels()
    end
  end
  log(bWriteLog and "UnknowPassLevelupSystem.OpenUnlockUI222")
  if buyId then
    local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
    if UnknowPassBuySystem.IsUnlockBuy(buyId) then
      UnknowPassLevelupSystem.OpenUnlockUI()
    elseif UnknowPassSystem.Level > UnknowPassSystem.BuyBeforeLevel then
      UnknowPassLevelupSystem.OpenLevelUpUI()
    elseif UnknowPassLevelupSystem.HideCallBack then
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimerOnce(0, function()
        UnknowPassLevelupSystem.HideCallBack()
        UnknowPassLevelupSystem.HideCallBack = nil
      end)
    end
  else
    UnknowPassLevelupSystem.OpenUnlockUI()
  end
end
function UnknowPassLevelupSystem.OnAddScore(evenType, eventID, reason, isRewardClick)
  log(bWriteLog and "UnknowPassLevelupSystem.OnAddScore " .. UnknowPassSystem.BuyBeforeLevel)
  log(bWriteLog and "UnknowPassLevelupSystem.OnAddScore " .. UnknowPassSystem.Level .. tostring(reason))
  log(bWriteLog and "UnknowPassLevelupSystem.OnAddScore isRewardClick " .. tostring(isRewardClick))
  if UnknowPassSystem.Level > UnknowPassSystem.BuyBeforeLevel then
    local CrateOpenBoxUI = UIManager.GetUI(UIManager.UI_Config.new_supply_get_panel)
    if UIManager.IsUIShow(UIManager.UI_Config.new_supply_get_panel) or CrateOpenBoxUI and CrateOpenBoxUI:IsAsyncLoading() then
      UnknowPassLevelupSystem.delayShow = true
    elseif reason and tonumber(reason) == 1044 then
    elseif GameStatus.IsInFightingStatus() and not GameStatus.IsInMainCity() then
      log(bWriteLog and "UnknowPassLevelupSystem.OnAddScore delayShow")
      UnknowPassLevelupSystem.delayShow = true
    else
      local Logic_BonusPass_Buy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass_Buy)
      local bShowPopup = not Logic_BonusPass_Buy:GetIsNotPopup()
      if isRewardClick == 0 and bShowPopup then
        UnknowPassLevelupSystem.OpenLevelUpUI()
      end
    end
    local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
    if not UnknowPassTunnelSystem.isShowRP then
      local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
      PassDataSystem.upass_get_req()
    end
  end
end
function UnknowPassLevelupSystem.CheckShowLevelUp()
  if UnknowPassLevelupSystem.delayShow then
    UnknowPassLevelupSystem.delayShow = false
    UnknowPassLevelupSystem.OpenLevelUpUI()
  end
  if UnknowPassLevelupSystem.bBlockCameraChange then
    UnknowPassLevelupSystem.bBlockCameraChange = false
  end
  local corp_welfare = require("client.slua.logic.corps.logic_corps_welfare")
  corp_welfare.ShowRedEnvelopUI()
end
function UnknowPassLevelupSystem.ClearShowLevelUpMark()
  UnknowPassLevelupSystem.delayShow = false
end
function UnknowPassLevelupSystem.OnShopBuyAgain()
  local UI = UIManager.GetUI(UIManager.UI_Config.unknowpass_levelup)
  if UI and UI:IsShow() then
    UnknowPassLevelupSystem.HideLevelUpUI()
  end
end
function UnknowPassLevelupSystem.GotoAward()
  if GameStatus.IsInFightingStatus() and not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  UnknowPassLevelupSystem.HideLevelUpUI()
  local UnknowPassTreasureBoxSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_treasurebox")
  UnknowPassTreasureBoxSystem.CloseTreasureBoxUI()
  local UnknowPassEasyTicketSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_easy_ticket")
  UnknowPassEasyTicketSystem.HideEasyTicketUI()
  if not UnknowPassSystem.IsBuyElite then
    local logic_upass_level_slap = require("client.slua.logic.upass.levelSlap.logic_upass_level_slap")
    logic_upass_level_slap.SetIsShowSlapLevel(true)
  end
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local E_TabType = PassDataSystem.GetTabType()
  local panelType = PassDataSystem.GetPanelType()
  local nCurType = PassDataSystem.GetCurRpPanelType()
  if E_TabType.curTab == E_TabType.award and nCurType == panelType.BranchRp then
    PassDataSystem.TurnToRPAwardPanel()
    local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
    PassPreviewSystem.ShowDefaultModelWear()
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GETALL_AWARD)
  else
    PassDataSystem.SetCurPanelType(panelType.MainRp)
    UnknowPassOpenUISystem.GoToRPAward(UnknowPassAwardSystem.HasCanGetReward(true))
  end
end
function UnknowPassLevelupSystem.GotoUpgrade()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  UnknowPassLevelupSystem.HideLevelUpUI()
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  UnknowPassBuySystem.OpenBuyUI()
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.Clear()
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_PassFriendPanelJump)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassFriendPanelJump)
end
function UnknowPassLevelupSystem.GotoShare()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  UnknowPassLevelupSystem.HideLevelUpUI()
  local UnknowPassSlapSystem = require("client.slua.logic.unknow_pass.NewRPInitFlow.logic_unknowpass_slap")
  UnknowPassSlapSystem.ShowPostBuySlap()
  local cfg = {
    showPass = true,
    isOld = true,
    campaign = "rp_level_up",
    share_type = ShareBtnTLogShareTypeDefine.TotalRPPoints,
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      rpLevel = UnknowPassSystem.Level
    })
  }
  local util = require("client.slua_ui_framework.util")
  util.ShowShare(cfg, UIManager.UI_Config.unknowpass_share)
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_PassClickShare)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassClickShare)
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.TotalRPPoints, nil, nil)
end
function UnknowPassLevelupSystem.ShowLevelForThreeImage(widget1, widget2, widget3, level, scaleX, scaleY, IsBuyElite, ver)
  if widget1 and widget2 and widget3 then
    local UIUtil = require("client.common.ui_util")
    widget2:SetWidgetVisibility(UIUtil.BoolToVisible(10 <= level))
    widget1:SetWidgetVisibility(UIUtil.BoolToVisible(100 <= level))
    if level < 10 then
      UnknowPassLevelupSystem.LoadImage(level, widget3, scaleX, scaleY, IsBuyElite, ver)
      widget3:SetRenderScale(FVector2D(1.2, 1.2))
    elseif level < 100 then
      local ten = math.floor(level / 10)
      local sNumber = level % 10
      UnknowPassLevelupSystem.LoadImage(sNumber, widget3, scaleX, scaleY, IsBuyElite, ver)
      UnknowPassLevelupSystem.LoadImage(ten, widget2, scaleX, scaleY, IsBuyElite, ver)
      widget2:SetRenderScale(FVector2D(1.2, 1.2))
      widget3:SetRenderScale(FVector2D(1.2, 1.2))
    else
      UnknowPassLevelupSystem.LoadImage(0, widget3, scaleX, scaleY, IsBuyElite, ver)
      UnknowPassLevelupSystem.LoadImage(0, widget2, scaleX, scaleY, IsBuyElite, ver)
      UnknowPassLevelupSystem.LoadImage(1, widget1, scaleX, scaleY, IsBuyElite, ver)
      widget1:SetRenderScale(FVector2D(1, 1))
      widget2:SetRenderScale(FVector2D(1, 1))
      widget3:SetRenderScale(FVector2D(1, 1))
    end
  end
end
function UnknowPassLevelupSystem.LoadImage(number, Image, scaleX, scaleY, IsBuyElite, version)
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local ver = version or UnknowPassUtil.GetVersionNumber()
  numberPath = string.format("%s%s%s", "/Game/Arts_UI/UnknowPass/Common/", ver, "/Atlas/Frames/RP_%d_png.RP_%d_png")
  local StringUtil = require("common.string_util")
  local numList = StringUtil.Split(ver, "_")
  local res = 0
  for i, v in ipairs(numList) do
    res = res * 100 + tonumber(v)
  end
  if res <= 10400 then
    numberPathNormal = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RP_%d_normal_png.RP_%d_normal_png"
  elseif res < 20600 then
    numberPathNormal = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RP_%d_png.RP_%d_png"
  else
    numberPathNormal = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RPA_%d_normal_png.RPA_%d_normal_png"
  end
  local texturePath = ""
  if IsBuyElite == nil then
    if UnknowPassSystem.IsBuyElite then
      texturePath = string.format(numberPath, number, number)
    else
      texturePath = string.format(numberPathNormal, number, number)
    end
  elseif IsBuyElite == false then
    texturePath = string.format(numberPathNormal, number, number)
  elseif IsBuyElite == true then
    texturePath = string.format(numberPath, number, number)
  end
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(Image, texturePath)
  if number == 1 and res <= 10400 then
    Image:SetRenderScale(FVector2D(0.6, 1))
  else
    Image:SetRenderScale(FVector2D(1, 1))
  end
end
return UnknowPassLevelupSystem