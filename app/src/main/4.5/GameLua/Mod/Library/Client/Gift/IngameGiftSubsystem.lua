local IngameGiftSubsystem = {}
function IngameGiftSubsystem:ctor()
  log(bWriteLog and "[IngameGiftSubsystem] ctor")
end
function IngameGiftSubsystem:OnInit()
  log(bWriteLog and "[IngameGiftSubsystem] OnInit")
  IngameGiftSubsystem.__super.OnInit(self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_SEND_GIFT_RSP, self.OnSendGiftRsp, self)
end
function IngameGiftSubsystem:OnRelease()
  log(bWriteLog and "[IngameGiftSubsystem] OnRelease")
  self:RemoveCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_SEND_GIFT_RSP, self.OnSendGiftRsp)
  IngameGiftSubsystem.__super.OnRelease(self)
end
function IngameGiftSubsystem:OnSendGiftRsp(_, _, gift_info, battle_id)
  log(bWriteLog and "[IngameGiftSubsystem] OnSendGiftRsp: " .. tostring(battle_id))
  if not gift_info then
    log(bWriteLog and "[IngameGiftSubsystem] nil gift info")
    return
  end
  local gift_const = require("client.slua.logic.gift.gift_const")
  if gift_info.gift_source == gift_const.GiftSourceType.IngameWatch then
    self:HandleSpectatingGiftRsp(gift_info)
  end
end
function IngameGiftSubsystem:HandleSpectatingGiftRsp(gift_info)
  log(bWriteLog and "[IngameGiftSubsystem] HandleSpectatingGiftRsp")
  if not gift_info then
    log(bWriteLog and "[IngameGiftSubsystem] nil gift info")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "[IngameGiftSubsystem] invalid playerController")
    return
  end
  if not uPlayerController:IsInSpectating() then
    log(bWriteLog and "[IngameGiftSubsystem] player not in spectating")
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local receiver_profile = logic_profile:GetLocalProfile(gift_info.uid)
  if receiver_profile then
    self:SendTeamGiftMsg(receiver_profile, gift_info)
  else
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      tonumber(gift_info.uid)
    }, function(list)
      if 1 <= #list then
        self:SendTeamGiftMsg(list[1], gift_info)
      end
    end, Enum_PROFILE_REPORT_CFG.INGAME_GIFT)
  end
  local logic_gift_notice = require("client.slua.logic.gift.logic_gift_notice")
  logic_gift_notice.AddGiftNotice(gift_info.gift_type, gift_info.gift_count, DataMgr.roleData.uid, gift_info.uid)
  self:PlayVideoOrAnimation(gift_info)
end
function IngameGiftSubsystem:PlayVideoOrAnimation(gift_info)
  log(bWriteLog and "IngameGiftSubsystem:PlayVideoOrAnimation")
  local logic_video_gift = require("client.slua.logic.gift.logic_video_gift")
  if logic_video_gift.IsVideoGift(gift_info.gift_type) and logic_video_gift.CheckVideoGiftValid(gift_info.gift_type) then
    log(bWriteLog and "IngameGiftSubsystem:PlayVideoOrAnimation PlayVideo")
    logic_video_gift.PlayGiftVideo(gift_info.gift_type)
    return
  end
  local logic_gift_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_gift_download)
  if not logic_gift_download:IsGiftResourceDownloaded(gift_info.gift_type) then
    log(bWriteLog and "IngameGiftSubsystem:PlayVideoOrAnimation gift resources not download yet")
    logic_gift_download:AddGiftToDownload(gift_info.gift_type)
    ShowNotice(62487)
    return
  end
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  local container = frontendUtils:GetGlobalUIContainer(UIContainers.Top)
  local UIUtil = require("client.common.ui_util")
  local ViewportSize = UIUtil.GetViewportSize() / UIUtil.GetViewportScale()
  local ui_depth_manager = require("client.common.uibase.ui_depth_manager")
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  logic_send_gift.PlayGiftAni(gift_info.gift_type, gift_info.gift_count, container, ViewportSize.X / 2, ViewportSize.Y * 2 / 3, ui_depth_manager.GetTopDepth() + 1)
end
function IngameGiftSubsystem:SendTeamGiftMsg(receiver_profile, gift_info)
  log(bWriteLog and "[IngameGiftSubsystem] SendTeamGiftMsg")
  if not receiver_profile or not gift_info then
    log(bWriteLog and "[IngameGiftSubsystem] invalid params")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "[IngameGiftSubsystem] invalid playerController")
    return
  end
  if not uPlayerController:IsInSpectating() then
    log(bWriteLog and "[IngameGiftSubsystem] player not in spectating")
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "[IngameGiftSubsystem] invalid playerState")
    return
  end
  local teamMsg = LocUtil.LocalizeResFormat(45997, gift_info.gift_count, receiver_profile.nickName)
  local pattern = "PopularityGift"
  teamMsg = string.gsub(teamMsg, pattern, pattern .. tostring(gift_info.gift_type))
  uPlayerController:SendStringWithMsgID(teamMsg, 45997, uPlayerState:GetPlayerKey())
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, IngameGiftSubsystem)