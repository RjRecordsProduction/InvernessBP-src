local OBUtilitySubsystem = {}
function OBUtilitySubsystem:OnInit()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_GAME_RESULT_OB, self.OnGameResultOB, self)
  self.TeamID2LogoState = {}
end
function OBUtilitySubsystem:OnGameResultOB(_, _, Result)
  print(bWriteLog and "OBUtilitySubsystem:OnGameResultOB")
  local WeaponReport = Result.WeaponRecord
  if not WeaponReport then
    return
  end
  local Res = {}
  for sUID, tPlayerWeaponReport in pairs(WeaponReport) do
    local SinglePlayerRes = {}
    SinglePlayerRes.OBPlayerWeaponRecord_UID = tonumber(sUID)
    SinglePlayerRes.OBPlayerWeaponRecord_UId = tonumber(sUID)
    SinglePlayerRes.WeaponReport = {}
    for sWeaponID, tData in pairs(tPlayerWeaponReport) do
      local PlayerWeaponReport = {}
      PlayerWeaponReport.OBSingleWeaponRecord_WeaponID = tonumber(sWeaponID)
      PlayerWeaponReport.OBSingleWeaponRecord_WeaponId = tonumber(sWeaponID)
      PlayerWeaponReport.TotalDamage = tData.TotalDamage
      PlayerWeaponReport.KillCount = tData.KillCount
      PlayerWeaponReport.KnockDownCount = tData.KnockDownCount
      table.insert(SinglePlayerRes.WeaponReport, PlayerWeaponReport)
    end
    table.insert(Res, SinglePlayerRes)
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.SendWeaponInfoToOB then
    uPlayerController:SendWeaponInfoToOB(Res)
  end
end
function OBUtilitySubsystem:LoadTeamLogoByTeamID(TeamID, CallBack)
  if not TeamID or not self.TeamID2LogoState then
    return
  end
  if self.TeamID2LogoState[TeamID] then
    CallBack(self.TeamID2LogoState[TeamID])
    return
  elseif self.TeamID2LogoState[TeamID] == false then
    return
  end
  local Texture2D = import("/Script/Engine.Texture2D")
  local AsSTExtraPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local STExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
  if not Game:IsClassOf(AsSTExtraPlayerController, STExtraPlayerController) then
    return
  end
  local uSyncOBDataActor = self:GetSyncOBDataActor()
  if not slua.isValid(uSyncOBDataActor) then
    return
  end
  local TeamInfoMap = uSyncOBDataActor.TeamInfoMap
  local TeamData = TeamInfoMap:Get(TeamID)
  local IsShowLogo = false
  local LogoPicUrl
  if TeamData then
    IsShowLogo = TeamData.IsShowLogo
    LogoPicUrl = TeamData.LogoPicUrl
  end
  local OBUI_Library = import("/Game/BluePrints/UI/OBUI/Lib/OBUI_Library.OBUI_Library_C")
  local _, _, LogoObject = OBUI_Library.GetCustomTeamLogoByTeamID(TeamID, {
    256,
    128,
    64
  }, self.UIRoot)
  print(bWriteLog and "OBUtilitySubsystem:LoadTeamLogoByTeamID-", TeamID, LogoPicUrl, LogoObject, slua.isValid(LogoObject), IsShowLogo)
  if slua.isValid(LogoObject) then
    CallBack(LogoObject)
    print(bWriteLog and "OBUtilitySubsystem:LoadTeamLogoByTeamID GetCustomTeamLogoByTeamID", TeamID, LogoObject)
    self.TeamID2LogoState[TeamID] = LogoObject
  elseif LogoPicUrl and LogoPicUrl ~= "" and IsShowLogo then
    local util = require("client.slua_ui_framework.util")
    local IsNetUrl = util.IsOnlineImageUrl(LogoPicUrl)
    if IsNetUrl then
      self:DownloadImage(LogoPicUrl, function(texture)
        CallBack(texture)
        self.TeamID2LogoState[TeamID] = texture
        print(bWriteLog and "OBUtilitySubsystem:LoadTeamLogoByTeamID DownLoad", TeamID, LogoPicUrl, texture)
      end, function()
        self.TeamID2LogoState[TeamID] = false
        print(bWriteLog and "OBUtilitySubsystem:LoadTeamLogoByTeamID DownLoad fail!", TeamID, LogoPicUrl)
      end)
    else
      local asset_util = require("common.asset_util")
      local BusinessHelper = import("BusinessHelper")
      local Texture = asset_util.GetAssetSync(LogoPicUrl)
      if Texture and BusinessHelper.IsClassOf(Texture, Texture2D) then
        CallBack(Texture)
        self.TeamID2LogoState[TeamID] = Texture
        print(bWriteLog and "OBUtilitySubsystem:LoadTeamLogoByTeamID Load", TeamID, LogoPicUrl, Texture)
      else
        self.TeamID2LogoState[TeamID] = false
        print(bWriteLog and "OBUtilitySubsystem:LoadTeamLogoByTeamID Load fail", TeamID, LogoPicUrl)
      end
    end
  end
end
function OBUtilitySubsystem:DownloadImage(imgUrl, OnDownloadSuccess, OnDownloadFail)
  if not self._downloadImageMgrData then
    self._downloadImageMgrData = {}
  end
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  image_download_mgr:DownloadImageForBase(imgUrl, self._downloadImageMgrData, OnDownloadSuccess, OnDownloadFail)
end
function OBUtilitySubsystem:GetSyncOBDataActor()
  local Utility = require("common.utility")
  local uSpectatingSubsystem = Utility.GetWorldSubsystemByName("SpectatingSubsystem")
  if not slua.isValid(uSpectatingSubsystem) then
    return nil
  end
  return uSpectatingSubsystem.SyncOBDataActor
end
function OBUtilitySubsystem:GetOBHttpComponent()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
  if slua.isValid(uPlayerController) and Game:IsClassOf(uPlayerController, ASTExtraPlayerController) then
    local uClassOBHttpComponent = import("OBHttpComponent")
    if uClassOBHttpComponent then
      return uPlayerController:GetComponentByClass(uClassOBHttpComponent)
    end
  end
end
function OBUtilitySubsystem:GetPCOBCommonComponent()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
  if slua.isValid(uPlayerController) and Game:IsClassOf(uPlayerController, ASTExtraPlayerController) then
    local uClassPCOBCommonComponent = import("PCOBCommonComponent")
    if uClassPCOBCommonComponent then
      return uPlayerController:GetComponentByClass(uClassPCOBCommonComponent)
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, OBUtilitySubsystem)