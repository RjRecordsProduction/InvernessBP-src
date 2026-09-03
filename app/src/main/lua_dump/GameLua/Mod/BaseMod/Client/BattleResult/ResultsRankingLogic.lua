local ResultsRankingLogic = {}
local GameplayStatics = import("GameplayStatics")
local async = require("client.common.async")
local uActor = import("/Script/Engine.Actor")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local KismetSystemLibrary = import("KismetSystemLibrary")
local UKismetMathLibrary = import("KismetMathLibrary")
local BusinessHelper = import("BusinessHelper")
local util = require("client.slua_ui_framework.util")
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
local utility = require("common.utility")
local EAttachmentRule = import("EAttachmentRule")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local CONST_MINITV_ATTACH_BASE_SCALE = 0.3
local CONST_MINITV_BE_VOUTE_ACTION_ID = 50000002
function ResultsRankingLogic:Init(ModeId)
  print(bWriteLog and "ResultsRankingLogic:Init LogicInited:" .. tostring(self.LogicInited), ModeId)
  if self.LogicInited then
    return
  end
  self.LevelName = ""
  self.Cur  self.IndextoAnimIdMap = {}
  self.bCreateRolesSuccess = false
  self.bShowResultAnim = false
  self.ResultRoleRoot = nil
  self.RoleRootActors = nil
  self.PlayerActorSet = {}
  self.PlayerActorCnt = 0
  self.PetActorSet = {}
  self.MiniTvActorSet = {}
  self.EnterSpectateMode = false
  self.CurAvatarPage = 1
  self.TeammateRoleInfos = nil
  self.LogicInited = true
  self.AvatarViewLoaded = false
  self.CanSwitchAvatarPage = false
  self.OverrideLevelName = nil
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  print(bWriteLog and "ResultsRankingLogic:Init", PlayerController)
  if not slua.isValid(PlayerController) or PlayerController.bIsEnterBattleResultStep == nil then
    print(bWriteLog and "ResultsRankingLogic:Init PlayerController is not a UAEPlayerController!")
    self:OnReconnectFail()
  end
end
function ResultsRankingLogic:OnRelease()
  print(bWriteLog and "ResultsRankingLogic:OnRelease")
  self.CurModeId = 0
  self.PlayerActorSet = {}
  self.PlayerActorCnt = 0
  self.PetActorSet = {}
  self.MiniTvActorSet = {}
  self.CurAvatarPage = 1
  self.TeammateRoleInfos = nil
  self.LogicInited = false
  self.CanSwitchAvatarPage = false
  self.EnterSpectateMode = false
  self.RoleRootActors = nil
  self.TeammateRoleInfos = nil
  self.ResultRoleRoot = nil
end
function ResultsRankingLogic:OnReconnectFail()
  local strTile = DataMgr.GetMsgByID(102012)
  local strMsg = LocUtil.GetLocalizeResStr(301111)
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  IngameTipsTools.ShowMsgBox(1, strTile, strMsg, function()
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.ShowLoading(true)
    Client.ReturnToLobby(GameFrontendHUD)
  end, nil, nil, nil, true)
end
function ResultsRankingLogic:OnShowAvatarView(loadedCb)
  print(bWriteLog and "ResultsRankingLogic:OnShowAvatarView AvatarViewLoaded:" .. tostring(self.AvatarViewLoaded))
  if not self.AvatarViewLoaded then
    self:LoadResultLevel(loadedCb)
    self.AvatarViewLoaded = true
  elseif loadedCb then
    loadedCb(self.LevelName)
  end
end
function ResultsRankingLogic:LoadResultLevel(loadedCb)
  self.LevelName = self:GetResultLevelName()
  if self.OverrideLevelName ~= nil and self.OverrideLevelName ~= "" then
    self.LevelName = self.OverrideLevelName
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local BattleResultConfig = GamePlayTools.GetCurrentConfig("BattleResultConfig")
  local NotCloseWeatherLight = BattleResultConfig and BattleResultConfig.NoLightResultLevels and BattleResultConfig.NoLightResultLevels[self.LevelName]
  NotCloseWeatherLight = NotCloseWeatherLight or BattleResultConfig.bDontCloseLight
  print(bWriteLog and "ResultsRankingLogic:LoadResultLevel LevelName: ", self.LevelName, self.CurModeId, NotCloseWeatherLight, BattleResultConfig.bDontCloseLight)
  local nTimerID
  if self.CurModeId and self.CurModeId > 60010 and self.CurModeId < 60019 then
    nTimerID = Game:SetTimer(5, false, function(...)
      self:TimerLoadBackDell(loadedCb)
    end)
  end
  self.loadBackHaveDell = false
  async.Run(function(co)
    if not NotCloseWeatherLight then
      self:CloseWeatherLight()
      self:CloseWeatherHeightFog()
    end
    FuncUtil.UE4ExecuteConsoleCommand("r.Shadow.CSMCached 0")
    local world = slua_GameFrontendHUD:GetWorld()
    print(bWriteLog and "ResultsRankingLogic:LoadResultLevel load start: " .. self.LevelName, slua.getMiliseconds(), NotCloseWeatherLight)
    if slua.isValid(world) then
      GameplayStatics.LoadStreamLevel(world, self.LevelName, true, true)
    end
    print(bWriteLog and "ResultsRankingLogic:LoadResultLevel load complete: " .. self.LevelName, slua.getMiliseconds() .. tostring(self.loadBackHaveDell))
    if self.loadBackHaveDell then
      return
    end
    if loadedCb then
      loadedCb(self.LevelName)
    end
    EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_RESULT_LEVEL_LOADED, self.LevelName)
    self.loadBackHaveDell = true
    if nTimerID then
      Game:ClearTimer(nTimerID)
    end
  end)
end
function ResultsRankingLogic:TimerLoadBackDell(loadedCb)
  print(bWriteLog and "ResultsRankingLogic:TimerLoadBackDell: " .. tostring(self.loadBackHaveDell))
  local LevelStreamingMgr = SubsystemMgr:Get("LevelStreamingMgr")
  if not self.loadBackHaveDell and LevelStreamingMgr then
    LevelStreamingMgr:LoadStreamLevelNoLatent(self.LevelName, true, true)
    Game:SetTimer(0.02, false, function(...)
      if loadedCb then
        loadedCb(self.LevelName)
      end
      EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_RESULT_LEVEL_LOADED, self.LevelName)
      self.loadBackHaveDell = true
      print(bWriteLog and "ResultsRankingLogic:TimerLoadBackDell: over")
    end)
  end
end
function ResultsRankingLogic:CloseWeatherLight()
  print(bWriteLog and "ResultsRankingLogic:CloseWeatherLight")
  local uDirectionalLightClass = import("/Script/Engine.DirectionalLight")
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  local directionalLightActors = GameplayStatics.GetAllActorsOfClass(uGameInstance, uDirectionalLightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  for _, v in pairs(directionalLightActors) do
    if v.LightComponent:IsVisible() then
      v.LightComponent:SetVisibility(false, true)
    end
  end
end
function ResultsRankingLogic:CloseWeatherHeightFog()
  print(bWriteLog and "ResultsRankingLogic:CloseWeatherHeightFog")
  local uExponentialHeightFogClass = import("/Script/Engine.ExponentialHeightFog")
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  local exponentialHeightFogActors = GameplayStatics.GetAllActorsOfClass(uGameInstance, uExponentialHeightFogClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  for _, v in pairs(exponentialHeightFogActors) do
    if v.Component:IsVisible() then
      v.Component:SetVisibility(false, true)
    end
  end
end
function ResultsRankingLogic:UnLoadUnnecessaryLevel()
end
function ResultsRankingLogic:GetResultLevelName()
  local curResultLevel = ResultsRankingLogic.GetResultLevelCfg(self.CurModeId)
  curResultLevel = curResultLevel or "PUBG_Baltic_ResultAvatar"
  return curResultLevel
end
function ResultsRankingLogic.GetResultLevelCfg(ModeId)
  if BattleResult.RESULTLEVEL_TEST then
    local LevelCfg = ResultsRankingLogic._GetResultLevelCfg()
    if LevelCfg then
      return LevelCfg
    end
  end
  local mapCfg = ResultUtil.GetMapCfg(ModeId)
  if mapCfg and mapCfg.RersultAvatarLevel ~= "" then
    return mapCfg.RersultAvatarLevel
  end
  return nil
end
function ResultsRankingLogic._GetResultLevelCfg()
  local UIUtil = require("client.common.ui_util")
  local curLevelName = GameplayStatics.GetCurrentLevelName(UIUtil.GetGameInstance(), true)
  print(bWriteLog and "ResultsRankingLogic:GetResultLevelName" .. curLevelName)
  if curLevelName == "Baltic_Main" then
    return "PUBG_Baltic_ResultAvatar"
  elseif curLevelName == "PUBG_Desert" then
    return "PUBG_Desert_ResultAvatar"
  elseif curLevelName == "PUBG_Savage_Main" then
    return "PUBG_Savage_ResultAvatar"
  elseif curLevelName == "DihorOtok_Main" then
    return "PUBG_DihorOtok_ResultAvatar_2"
  elseif curLevelName == "FourMaps_Main" then
    return "FourMaps_Main_ResultAvatar"
  elseif curLevelName == "PUBG_Summerland_Mian" then
    return "PUBG_Summerland_AvatarDisplay"
  elseif curLevelName == "Sink_Main" then
    return "Sink_Main_ResultAvatar"
  elseif curLevelName == "PUBG_Borderland_Main" then
    return "PUBG_Borderland_ResultAvatar"
  elseif curLevelName == "DBZ_Main" then
    return "DBZ_ResultAvatar"
  elseif curLevelName == "PUBG_Neon_Main" then
    return "PUBG_Neon_AvatarDisplay"
  elseif curLevelName == "Escape_Main" then
    return "Excape_ResultAvatar"
  end
  return nil
end
function ResultsRankingLogic:GetCameraLevelSequence(playerNum)
  local mapCfg = ResultUtil.GetMapCfg(self.CurModeId)
  local path
  if mapCfg then
    if playerNum == 2 and mapCfg.ResultPoseSeq_Double ~= nil then
      path = mapCfg.ResultPoseSeq_Double
    elseif playerNum == 4 and mapCfg.ResultPoseSeq_Four ~= nil then
      path = mapCfg.ResultPoseSeq_Four
    end
  end
  return path
end
function ResultsRankingLogic:GetRootTransforms()
  return self.RoleRootActors
end
function ResultsRankingLogic:OnCreateRoles(resultRoleData, CreateRoleCallBack)
  self.EnterSpectateMode = resultRoleData.EnterSpectateMode
  print(bWriteLog and "ResultsRankingLogic:OnCreateRoles", self.EnterSpectateMode)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    print(bWriteLog and "ResultsRankingLogic:OnCreateRoles IsLowMemoryDevice")
    return
  end
  self.IndextoAnimIdMap = {}
  self.RoleRootActors = nil
  self:GetResultRoleRoot(resultRoleData)
  if not self.ResultRoleRoot then
    print(bWriteLog and "ResultsRankingLogic:OnCreateRoles ResultRoleRoot is nil")
    return
  end
  print(bWriteLog and "ResultsRankingLogic:OnCreateRoles ", self.EnterSpectateMode, resultRoleData.MyName)
  self.TeammateRoleInfos = resultRoleData.TeammateRoleInfo
  if #self.TeammateRoleInfos == 0 then
    print(bWriteLog and "ResultsRankingLogic:OnCreateRoles #self.TeammateRoleInfos is 0")
    return
  end
  local showRoleInfos = {}
  showRoleInfos = self:GetCurPageRoleInfos(resultRoleData)
  log_tree(bWriteLog and "showRoleInfos", showRoleInfos)
  if 0 < #showRoleInfos then
    self:RefreshLobbyPawns(showRoleInfos, false, true, CreateRoleCallBack)
  else
    print(bWriteLog and "ResultsRankingLogic:OnCreateRoles #showRoleInfos is 0")
    return
  end
  self.bCreateRolesSuccess = true
end
function ResultsRankingLogic:SwitchShowAvatarPage(avatarPage)
  print(bWriteLog and "ResultsRankingLogic:SwitchShowAvatarPage avatarPage:" .. tostring(avatarPage))
  if not self.LogicInited or not self.TeammateRoleInfos then
    print(bWriteLog and "ResultsRankingLogic:SwitchShowAvatarPage not LogicInited or not TeammateRoleInfos")
    return false
  end
  if not self.CanSwitchAvatarPage then
    print(bWriteLog and "ResultsRankingLogic:SwitchShowAvatarPage CanSwitchAvatarPage is False")
    return false
  end
  self.CurAvatarPage = avatarPage
  local showRoleInfos = self:GetCurPageRoleInfos()
  self:RefreshLobbyPawns(showRoleInfos, false, false)
  return true
end
function ResultsRankingLogic:GetCurPageRoleInfos(resultRoleData)
  print(bWriteLog and "ResultsRankingLogic:GetCurPageRoleInfos CurAvatarPage:" .. tostring(self.CurAvatarPage))
  if self.TeammateRoleInfos == nil then
    print(bWriteLog and "ResultsRankingLogic:GetCurPageRoleInfos TeammateRoleInfos is nil")
    return nil
  end
  local showRoleInfos = {}
  local startIndex = 1 + (self.CurAvatarPage - 1) * 4
  local endIndex = resultRoleData and resultRoleData.NumToShowPawn or startIndex + 3
  if endIndex > #self.TeammateRoleInfos then
    endIndex = #self.TeammateRoleInfos
  end
  for i = startIndex, endIndex do
    if self.TeammateRoleInfos[i] then
      table.insert(showRoleInfos, self.TeammateRoleInfos[i])
    end
  end
  return showRoleInfos
end
function ResultsRankingLogic:RefreshLobbyPawns(roleInfos, isBestPartner, playBestPartner, CreateRoleCallBack)
  print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns #roleInfos:" .. tostring(#roleInfos))
  log_tree(bWriteLog and "roleInfos:", roleInfos)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    return
  end
  local uUtils = slua_GameFrontendHUD:GetUtils()
  self:GetResultRoleRoot()
  if slua.isValid(self.ResultRoleRoot) then
    local uCameraActor = self.ResultRoleRoot.CameraActor
    print(bWriteLog and "SwitchSceneCamera uCameraActor", uCameraActor)
    if slua.isValid(uCameraActor) and slua.isValid(uCameraActor.ChildActor) then
      uUtils:RegisterSceneCamera("close_up", uCameraActor.ChildActor)
      uUtils:SwitchSceneCamera("close_up", 0, true)
    end
  end
  uUtils:OnAllSceneCamerasRegistered()
  self:HidAllLobbyPawn()
  self.RoleRootActors = self.ResultRoleRoot:GetTransfroms(#roleInfos, self.EnterSpectateMode)
  if self.RoleRootActors == nil or 0 >= self.RoleRootActors:Num() then
    print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns RoleRootActors is nil or empty!")
    return
  end
  for Index, LocalAvatar in pairs(roleInfos) do
    if type(Index) == "number" and LocalAvatar ~= nil then
      log_tree(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns2", LocalAvatar)
      local bCanShowCharacter = true
      local originIndex = Index - 1
      if bCanShowCharacter and originIndex >= self.RoleRootActors:Num() then
        print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns out of range")
        bCanShowCharacter = false
      end
      local roleTransform
      if bCanShowCharacter then
        roleTransform = self.RoleRootActors:Get(originIndex)
        if roleTransform == nil then
          bCanShowCharacter = false
        end
      end
      print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns3", LocalAvatar.secondWeaponId, bCanShowCharacter)
      if bCanShowCharacter then
        local SingleActor, reuse = self:GetOneLobbyPawn(originIndex, roleTransform)
        if SingleActor == nil then
          print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns GetOneLobbyPawn failed")
          return
        end
        if slua.isValid(SingleActor) and SingleActor.SetPlayerUID then
          SingleActor:SetPlayerUID(tostring(LocalAvatar.uid))
        end
        local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
        LocalAvatar.headId = ResultUtil.CheckAvatarExist(LocalAvatar.headId)
        print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns headId", LocalAvatar.headId)
        self:PutOnAvatar(SingleActor, LocalAvatar.sex, LocalAvatar.headId, LocalAvatar.BP_ARRAY_AvatarList)
        SingleActor:SetResultAvatarPosIndex(LocalAvatar.resultAvatarPose * 2)
        local bShowWeapon = true
        if LocalAvatar.AvatarEmoteID and 0 < LocalAvatar.AvatarEmoteID and SingleActor.CharPlayEmoteByResId then
          local UBackpackUtils = import("BackpackUtils")
          local ItemDefineID = FItemDefineID(ENUM_ITEM_TYPE.Emote, LocalAvatar.AvatarEmoteID)
          local exist = UBackpackUtils.IsBattleItemHandleExist(ItemDefineID, false, false, false)
          if exist then
            bShowWeapon = false
            SingleActor:CharPlayEmoteByResId(LocalAvatar.AvatarEmoteID, "Default")
          else
            local PufferConst = require("client.slua.logic.download.puffer_const")
            local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
            print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns AvatarEmoteID not exist:", LocalAvatar.AvatarEmoteID)
            PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
              LocalAvatar.AvatarEmoteID
            })
          end
        end
        if bShowWeapon then
          print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns4 weaponId:", LocalAvatar.weaponId)
          if LocalAvatar.weaponSkinId and LocalAvatar.weaponSkinId ~= 0 then
            SingleActor:CharEquipWeaponByResId(LocalAvatar.weaponSkinId, true)
            local AvatarDIYUtils = import("AvatarDIYUtils")
            if AvatarDIYUtils.IsWeaponDIYAvatarItem(LocalAvatar.weaponSkinId) then
              SingleActor:RequestWeaponDIYData(LocalAvatar.uid, LocalAvatar.weaponSkinId, LocalAvatar.weaponSkinDIYPlanId)
            end
            SingleActor:CharEquipWeaponPendant(LocalAvatar.weaponSkinId, 2, LocalAvatar.weaponPendantID)
          elseif LocalAvatar.weaponId and LocalAvatar.weaponId ~= 0 then
            SingleActor:CharEquipWeaponByResId(LocalAvatar.weaponId, true)
          end
          SingleActor.bIsEmoteLooping = false
          SingleActor:PlayEmoteLoop()
          print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns LocalAvatar secondWeaponId", roleInfos, LocalAvatar.secondWeaponSkinId, LocalAvatar.secondWeaponId, LocalAvatar.uid)
          if LocalAvatar.secondWeaponSkinId and LocalAvatar.secondWeaponSkinId ~= 0 then
            SingleActor:CharEquipWeaponByResId(LocalAvatar.secondWeaponSkinId, false)
            local AvatarDIYUtils = import("AvatarDIYUtils")
            if AvatarDIYUtils.IsWeaponDIYAvatarItem(LocalAvatar.secondWeaponSkinId) then
              SingleActor:RequestWeaponDIYData(LocalAvatar.uid, LocalAvatar.secondWeaponSkinId, LocalAvatar.secondWeaponSkinDIYPlanId)
            end
            SingleActor:CharEquipWeaponPendant(LocalAvatar.secondWeaponSkinId, 2, LocalAvatar.secondWeaponPendantID)
          elseif LocalAvatar.secondWeaponId and LocalAvatar.secondWeaponId ~= 0 then
            print(bWriteLog and "ResultsRankingLogic:OnCreateRolesLocalAvatar", LocalAvatar.secondWeaponId)
            SingleActor:CharEquipWeaponByResId(LocalAvatar.secondWeaponId, false)
          else
            local tempLocalAvatar
            for i, avatar in pairs(self.TeammateRoleInfos) do
              if avatar ~= nil and avatar.uid ~= nil then
                print(bWriteLog and "TeammateRoleInfo uid", i, avatar.uid, LocalAvatar.uid)
                if tonumber(avatar.uid) == tonumber(LocalAvatar.uid) then
                  tempLocalAvatar = avatar
                  break
                end
              end
            end
            log_tree(bWriteLog and "get lua ResultsRankingLogic:RefreshLobbyPawns Index", tempLocalAvatar)
            if tempLocalAvatar then
              if tempLocalAvatar.secondWeaponSkinId and tempLocalAvatar.secondWeaponSkinId ~= 0 then
                SingleActor:CharEquipWeaponByResId(tempLocalAvatar.secondWeaponSkinId, false)
                local AvatarDIYUtils = import("AvatarDIYUtils")
                if AvatarDIYUtils.IsWeaponDIYAvatarItem(tempLocalAvatar.secondWeaponSkinId) then
                  SingleActor:RequestWeaponDIYData(tempLocalAvatar.uid, tempLocalAvatar.secondWeaponSkinId, tempLocalAvatar.secondWeaponSkinDIYPlanId)
                end
                SingleActor:CharEquipWeaponPendant(tempLocalAvatar.secondWeaponSkinId, 2, tempLocalAvatar.secondWeaponPendantID)
              elseif tempLocalAvatar.secondWeaponId and tempLocalAvatar.secondWeaponId ~= 0 then
                print(bWriteLog and "ResultsRankingLogic:OnCreateRolesLocalAvatar lua", tempLocalAvatar.secondWeaponId)
                SingleActor:CharEquipWeaponByResId(tempLocalAvatar.secondWeaponId, false)
              end
            end
          end
        end
        xpcall(function()
          self:ShowPetRole(LocalAvatar, SingleActor)
          self:ShowMiniTvRole(LocalAvatar, SingleActor)
        end, utility.ErrorMessageHandler)
        print(bWriteLog and "ResultsRankingLogic:RefreshLobbyPawns CallBack", SingleActor.CharacterAvatarComp2_BP, CreateRoleCallBack)
        if slua.isValid(SingleActor.CharacterAvatarComp2_BP) and CreateRoleCallBack then
          SingleActor.CharacterAvatarComp2_BP.OnAvatarAllMeshLoaded:Add(function()
            CreateRoleCallBack(SingleActor, LocalAvatar.BP_ARRAY_AvatarList)
          end)
        end
      end
      local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
      logic_outfit_combination:OnOutfitCombinationSettlementReport(LocalAvatar)
    end
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController.bEnableTouchEvents = true
  end
end
function ResultsRankingLogic:GetOneLobbyPawn(originIndex, roleTransform)
  print(bWriteLog and "ResultsRankingLogic:GetOneLobbyPawn")
  local SingleActor
  local Reuse = false
  if self.PlayerActorSet[originIndex] == nil then
    SingleActor = self:CreateSingleRole()
    self.PlayerActorCnt = self.PlayerActorCnt + 1
    self.PlayerActorSet[originIndex] = SingleActor
  else
    SingleActor = self.PlayerActorSet[originIndex]
    self:ClearEquipments(SingleActor)
    SingleActor:CharStopEmoteByResId()
    Reuse = true
  end
  SingleActor:K2_SetActorLocationAndRotation(roleTransform:GetLocation(), roleTransform:Rotator(), false, nil, false)
  SingleActor:SetCanRotate(true)
  return SingleActor, Reuse
end
function ResultsRankingLogic:CreateSingleRole()
  local SingleActor
  local playerLobbyPawnClass = import("/Game/Arts_PlayerBluePrints/Character_Show/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn_C")
  local world = slua_GameFrontendHUD:GetWorld()
  SingleActor = world:SpawnActor(playerLobbyPawnClass, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
  local UIUtil = require("client.common.ui_util")
  local gameInst = UIUtil.GetGameInstance()
  if gameInst ~= nil and slua.isValid(SingleActor) then
    if 0 >= gameInst:GetExactDeviceLevel() then
      SingleActor:SetAvatarLevel(2)
    else
      SingleActor:SetAvatarLevel(1)
    end
  end
  return SingleActor
end
function ResultsRankingLogic:HidAllLobbyPawn()
  print(bWriteLog and "ResultsRankingLogic:HidAllLobbyPawn")
  for index, SingleActor in pairs(self.PlayerActorSet) do
    SingleActor:K2_SetActorLocationAndRotation(FVector(0, 0, 0), FRotator(0, 0, 0), false, nil, false)
    self:ClearPets(SingleActor)
    self:ClearMiniTvs(SingleActor)
  end
end
function ResultsRankingLogic:PutOnAvatar(SingleActor, sex, headId, avatarList)
  print(bWriteLog and "ResultsRankingLogic:PutOnAvatar", sex, headId)
  if 0 <= sex then
    if sex == 0 then
      SingleActor:SetMaleAnimClass()
    elseif sex == 1 then
      SingleActor:SetFemaleAnimClass()
    end
    SingleActor:InitDefaultAvatarByResID(sex, headId, 0)
  end
  for _, tAvatarCustom in pairs(avatarList) do
    xpcall(function()
      SingleActor:PutOnEquipmentByResID(tAvatarCustom.ItemID, tAvatarCustom)
    end, utility.ErrorMessageHandler)
  end
end
function ResultsRankingLogic:ClearEquipments(actor)
  print(bWriteLog and "ResultsRankingLogic:ClearEquipments")
  local equipments = self:GetAllEquipments(actor)
  log_tree(bWriteLog and "ClearEquipments", equipments)
  for subType, equipmentInfo in pairs(equipments) do
    local itemID = equipmentInfo.ItemID
    local config = CDataTable.GetTableData("Item", itemID)
    if config == nil then
      log_error("[ResultsRankingLogic]ClearEquipments Error: config is nil " .. itemID)
    else
      self:PutoffEquipment(actor, itemID)
    end
  end
end
function ResultsRankingLogic:GetAllEquipments(actor)
  local result = {}
  if actor == nil then
    log(bWriteLog and "[ResultsRankingLogic]GetAllEquipments Error:Actor is nil.")
    return result
  end
  result = actor:GetAllEquipmentListMoreInfo()
  local tmpIndex = #result + 1
  if actor.BP_LobbyWeaponManager and actor.BP_LobbyWeaponManager.InventoryData then
    local curUsingWeapon = actor.BP_LobbyWeaponManager:GetUsingWeapon()
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    for slotName, weapon in pairs(actor.BP_LobbyWeaponManager.InventoryData) do
      if weapon then
        local weaponId = weapon:GetItemDefineID().TypeSpecificID
        if weaponId ~= LobbyAvatarManager.Enum_EquipWeapon.None then
          local item = {}
          item.ItemID = weaponId
          item.ColorID = 0
          item.PatternID = 0
          if curUsingWeapon then
            if curUsingWeapon == weapon then
              item.isCurUsingWeapon = true
            else
              item.isCurUsingWeapon = false
            end
          end
          result[tmpIndex] = item
          tmpIndex = tmpIndex + 1
        end
      end
    end
  end
  return result
end
function ResultsRankingLogic:PutoffEquipment(actor, itemID)
  print(bWriteLog and "[ResultsRankingLogic]PutoffEquipment PutoffEquipment " .. itemID)
  if actor == nil then
    log(bWriteLog and "[ResultsRankingLogic]PutoffEquipment Error:Actor is nil.")
    return
  end
  itemID = self:_GetDisplayItemID(itemID)
  local config = CDataTable.GetTableData("Item", itemID)
  if config == nil then
    log_error("[ResultsRankingLogic]PutoffEquipment Error: config is nil " .. itemID)
    return
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if config.ItemSubType == ENUM_ITEM_SUBTYPE.Head_Slot_400 then
    return
  end
  log(bWriteLog and "true PutoffEquipment " .. itemID .. " config.ItemType " .. config.ItemType)
  if config.ItemType == wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon then
    actor:CharUnEquipWeaponByResId(itemID)
  else
    actor:UnEquipByResID(itemID)
  end
end
function ResultsRankingLogic:_GetDisplayItemID(itemID)
  local displayItemID = itemID
  local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", itemID)
  if itemMappingCfg ~= nil then
    displayItemID = itemMappingCfg.LobbyShowItemID
  end
  return displayItemID
end
function ResultsRankingLogic:ClearPets(LobbyPawn)
  print(bWriteLog and "ResultsRankingLogic:ClearPets")
  local petActors = self.PetActorSet[LobbyPawn]
  if petActors then
    for uid, petActor in pairs(petActors) do
      if slua.isValid(petActor) and slua.isValid(petActor.Mesh) then
        petActor.Mesh:SetVisibility(false, true)
      end
    end
  end
end
function ResultsRankingLogic:ShowPetRole(LocalAvatar, SingleActor)
  local reusePetActor = self:GetPetRole(LocalAvatar.uid, SingleActor)
  if reusePetActor then
    if slua.isValid(reusePetActor) and slua.isValid(reusePetActor.Mesh) then
      reusePetActor.Mesh:SetVisibility(true, true)
    end
  else
    reusePetActor = self:CreatePetRole(LocalAvatar.PetId, LocalAvatar.PetLevel, SingleActor, LocalAvatar.PetAvatarID, LocalAvatar.uid)
    if self.PetActorSet[SingleActor] == nil then
      self.PetActorSet[SingleActor] = {}
    end
    if reusePetActor then
      self.PetActorSet[SingleActor][LocalAvatar.uid] = reusePetActor
    end
  end
  print(bWriteLog and "ResultsRankingLogic:ShowPetRole", LocalAvatar.PetId, reusePetActor)
  if reusePetActor and slua.isValid(reusePetActor) and LocalAvatar.PetId and LocalAvatar.PetId > 0 then
    local bEnlarged = false
    local uPlayerController = GameplayData.GetPlayerController()
    log(bWriteLog and "ResultsRankingLogic:ShowPetRole. slua_GameFrontendHUD:GetPlayerController(): " .. tostring(slua_GameFrontendHUD:GetPlayerController()))
    log(bWriteLog and "ResultsRankingLogic:ShowPetRole. uPlayerController: " .. tostring(uPlayerController))
    if slua.isValid(uPlayerController) then
      bEnlarged = uPlayerController.CommerFeature and uPlayerController.CommerFeature.TeamMemberPetID2EnlargeState and uPlayerController.CommerFeature.TeamMemberPetID2EnlargeState[LocalAvatar.uid] and uPlayerController.CommerFeature.TeamMemberPetID2EnlargeState[LocalAvatar.uid][LocalAvatar.PetId]
      local TableUtil = require("common.table_util")
      local TeamMemberPetID2EnlargeState = TableUtil.GetTableValue(uPlayerController, "CommerFeature", "TeamMemberPetID2EnlargeState")
      log_tree("ResultsRankingLogic:ShowPetRole. TeamMemberPetID2EnlargeState ", TeamMemberPetID2EnlargeState)
    end
    print(bWriteLog and "ResultsRankingLogic:ShowPetRole", LocalAvatar.uid, LocalAvatar.PetId, bEnlarged)
    reusePetActor:SetPetShowType(1, true)
    if LocalAvatar.PetId ~= 50001 then
      bEnlarged = bEnlarged or self:GetPetIsLarge(LocalAvatar.uid)
      reusePetActor:ResetPetScale(bEnlarged)
    end
  elseif reusePetActor and slua.isValid(reusePetActor) and slua.isValid(reusePetActor.Mesh) then
    reusePetActor.Mesh:SetVisibility(false, true)
  end
end
function ResultsRankingLogic:GetPetIsLarge(uid)
  local myUid = tonumber(DataMgr.roleData.uid)
  if myUid ~= uid then
    return false
  end
  local uPlayer = GameplayData.GetLocalCharacter()
  if not slua.isValid(uPlayer) then
    return false
  end
  local PetFormCharFeature = uPlayer.PetFormCharFeature
  if not PetFormCharFeature then
    return false
  end
  log(bWriteLog and "ResultsRankingLogic:GetPetIsLarge. PetFormCharFeature.bEnlarged: " .. tostring(PetFormCharFeature.bEnlarged))
  return PetFormCharFeature.bEnlarged
end
function ResultsRankingLogic:GetPetRole(playerUid, SingleActor)
  local petActor
  if self.PetActorSet[SingleActor] then
    petActor = self.PetActorSet[SingleActor][playerUid]
  end
  return petActor
end
function ResultsRankingLogic:CreatePetRole(PetID, PetLevel, Player, PetAvatarID, Uid)
  print(bWriteLog and "ResultsRankingLogic:CreatePetRole", PetID, PetLevel, Player, PetAvatarID)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local curPetLevelData = logic_pet:GetPetLevelItemCfg(PetID, PetLevel)
  if nil == curPetLevelData or nil == curPetLevelData.LobbyPetBP then
    print(bWriteLog and "ResultsRankingLogic:CreatePetRole GetPetLevelItemCfg failed!", PetID, PetLevel)
    return nil
  end
  print(bWriteLog and "ResultsRankingLogic:CreatePetRole LobbyPetBP", curPetLevelData.LobbyPetBP)
  local softObjPath = KismetSystemLibrary.MakeSoftObjectPath(curPetLevelData.LobbyPetBP)
  if softObjPath == nil then
    print(bWriteLog and "ResultsRankingLogic:CreatePetRole pet softObjPath is nil!")
    return nil
  end
  print(bWriteLog and "ResultsRankingLogic:CreatePetRole pet softObjPath", softObjPath)
  local ClassObj = STExtraBlueprintFunctionLibrary.GetClassByAssetReference(softObjPath)
  local world = slua_GameFrontendHUD:GetWorld()
  if ClassObj == nil then
    print(bWriteLog and "ResultsRankingLogic:CreatePetRole ClassObj is nil!")
    return nil
  end
  print(bWriteLog and "ResultsRankingLogic:CreatePetRole ClassObj", ClassObj)
  local actorObj = world:SpawnActor(ClassObj, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
  if actorObj == nil then
    print(bWriteLog and "ResultsRankingLogic:CreatePetRole spawn pet failed")
    return nil
  end
  actorObj:SetActorScale3D(FVector(1.0, 1.0, 1.0))
  local curPetData = logic_pet:GetPetItemCfgByPetItemID(PetID)
  if not curPetData or not curPetData.PetID then
    print(bWriteLog and "ResultsRankingLogic:CreatePetRole GetPetItemCfgByPetItemID failed", PetID)
    return nil
  end
  local PetUtil = require("GameLua.Mod.BaseMod.Actor.Pet.PetUtil")
  local isSpecialBird = PetUtil.IsClothesNotAttach(PetAvatarID)
  if not logic_pet:IsNotGyrfalcon(curPetData.PetID) and not isSpecialBird then
    if actorObj.PetAvatarComponent_BP and PetAvatarID then
      if type(PetAvatarID) == "number" and PetAvatarID ~= 0 then
        actorObj.PetAvatarComponent_BP:PetEquipItemById(PetAvatarID)
      elseif type(PetAvatarID) == "table" and next(PetAvatarID) then
        for i, v in pairs(PetAvatarID) do
          if tonumber(i) and 0 < tonumber(i) then
            actorObj.PetAvatarComponent_BP:PetEquipItemById(tonumber(i))
          end
        end
      end
    end
    actorObj:AttachToCharacter(Player)
    return actorObj
  else
    log(bWriteLog and "[ZH] curPetData.PetID: " .. tostring(curPetData.PetID))
    local playerPos = Game:GetActorLocation(Player)
    local angle = Game:GetActorRotation(Player).Yaw
    local x = math.cos(math.rad(angle)) * 50
    local y = math.sin(math.rad(angle)) * 50
    local pos = playerPos + FVector(x + 20, y - 15, -86)
    if isSpecialBird then
      pos = playerPos + FVector(x + 20, y - 15, 86)
    end
    local rot = FRotator(0, Game:GetActorRotation(Player).Yaw + 90, 0)
    local uScale = actorObj:GetActorScale3D()
    local uTransform = UKismetMathLibrary.MakeTransform(pos, rot, uScale)
    actorObj:K2_SetActorTransform(uTransform, false, nil, false)
    local FPetLevelInfo = import("/Script/ShadowTrackerExtra.PetLevelInfo")
    local PetLevelInfo = FPetLevelInfo()
    PetLevelInfo.PetId = PetID
    PetLevelInfo.    local bSimulate = true
    if tostring(Uid) == DataMgr.roleData.uid then
      bSimulate = false
    end
    actorObj:InitializePet(PetLevelInfo, bSimulate)
    if PetID == 50023 then
      local PetData = logic_pet:GetPetDataByPetItemID(PetID)
      if PetData and not bSimulate then
        actorObj:UpdateMeshColorMaterials(PetData.color)
      else
        local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
        local pet_info = TeamUpNewSystem.GetMemberPetInfo(tonumber(Uid))
        actorObj:UpdateMeshColorMaterials(pet_info.color or 1)
      end
    end
    if actorObj.PetAvatarComponent_BP and PetAvatarID then
      if type(PetAvatarID) == "number" and PetAvatarID ~= 0 then
        actorObj.PetAvatarComponent_BP:PetEquipItemById(PetAvatarID)
      elseif type(PetAvatarID) == "table" and next(PetAvatarID) then
        for i, v in pairs(PetAvatarID) do
          if tonumber(i) and 0 < tonumber(i) then
            actorObj.PetAvatarComponent_BP:PetEquipItemById(tonumber(i))
          end
        end
      end
    end
    return actorObj
  end
end
function ResultsRankingLogic:ClearMiniTvs(LobbyPawn)
  print(bWriteLog and "ResultsRankingLogic:ClearMiniTvs")
  local miniTvActors = self.MiniTvActorSet[LobbyPawn]
  if miniTvActors then
    for _, miniTvActor in pairs(miniTvActors) do
      if slua.isValid(miniTvActor) then
        if slua.isValid(miniTvActor.Mesh) then
          miniTvActor.Mesh:SetVisibility(false, true)
        end
        if slua.isValid(miniTvActor.Bubble) then
          miniTvActor.Bubble:SetVisibility(false, true)
        end
      end
    end
  end
end
function ResultsRankingLogic:ShowMiniTvRole(LocalAvatar, SingleActor)
  local uPlayerController = GameplayData.GetPlayerController()
  local bEnableMiniTv = false
  if slua.isValid(uPlayerController) and uPlayerController.CommerFeature and uPlayerController.CommerFeature.bEnableMiniTV then
    bEnableMiniTv = true
  end
  if not bEnableMiniTv then
    print(bWriteLog and "ResultsRankingLogic:ShowMiniTvRole mini tv is disabled.")
    return
  end
  local reuseMiniTvActor = self:GetMiniTvRole(LocalAvatar.uid, SingleActor)
  local miniTvDressID = self:GetMiniTvDressID(LocalAvatar.uid)
  if reuseMiniTvActor then
    if slua.isValid(reuseMiniTvActor) and slua.isValid(reuseMiniTvActor.Mesh) then
      reuseMiniTvActor.Mesh:SetVisibility(true, false)
    end
  else
    reuseMiniTvActor = self:CreateMiniTvRole(LocalAvatar.uid, SingleActor, miniTvDressID)
    if self.MiniTvActorSet[SingleActor] == nil then
      self.MiniTvActorSet[SingleActor] = {}
    end
    if reuseMiniTvActor then
      self.MiniTvActorSet[SingleActor][LocalAvatar.uid] = reuseMiniTvActor
    end
  end
  print(bWriteLog and "ResultsRankingLogic:ShowMiniTvRole", miniTvDressID, reuseMiniTvActor)
  if slua.isValid(reuseMiniTvActor) and slua.isValid(reuseMiniTvActor.Mesh) then
    reuseMiniTvActor.Mesh:SetVisibility(true, false)
    reuseMiniTvActor.Bubble:SetVisibility(false, true)
    local skeletalMesh = reuseMiniTvActor.Mesh
    local petActor = self.PetActorSet[SingleActor] and self.PetActorSet[SingleActor][LocalAvatar.uid]
    if petActor then
      local petID = LocalAvatar.PetId
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local bPetDownloaded = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {petID}) == PufferConst.ENUM_DownloadState.Done
      if petID ~= 50001 and bPetDownloaded then
        local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
        local socketScale = logic_pet:GetMiniTvSocketScale(petID) or 1
        local scale = CONST_MINITV_ATTACH_BASE_SCALE * socketScale
        skeletalMesh:SetWorldScale3D(FVector(scale, scale, scale))
        reuseMiniTvActor:K2_SetActorRelativeLocation(FVector(0, 0, 0), false, nil, true)
        reuseMiniTvActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, true)
        skeletalMesh:K2_AttachToComponent(petActor.Mesh, "MiniTvSocket", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepWorld, true)
        skeletalMesh:K2_SetRelativeLocation(FVector(0, 0, 0), false, nil, true)
        skeletalMesh:K2_SetRelativeRotation(FRotator(0, 0, 0), false, nil, false)
        reuseMiniTvActor.Bubble:SetVisibility(true, true)
      end
    end
  end
end
function ResultsRankingLogic:GetMiniTvRole(playerUid, SingleActor)
  return self.MiniTvActorSet and self.MiniTvActorSet[SingleActor] and self.MiniTvActorSet[SingleActor][playerUid]
end
function ResultsRankingLogic:CreateMiniTvRole(uid, Player, dressId)
  print(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole", uid, dressId)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MINI_TV_REV) then
    log(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole switcher BP_ENUM_LOBBY_MINI_TV_REV is closed.")
    return nil
  end
  local bMiniTvSwitch = false
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
  local bSelf = tostring(uid) == DataMgr.roleData.uid
  if uGameFrontendHUD then
    local uSettingConfig = uGameFrontendHUD:GetUserSettings()
    if slua.isValid(uSettingConfig) then
      local MiniTvSwitchKey = bSelf and "ShowMiniTvInFighting" or "ShowOtherMiniTvInFighting"
      bMiniTvSwitch = uSettingConfig[MiniTvSwitchKey]
      log(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetForShow key: " .. tostring(MiniTvSwitchKey) .. " bMiniTvSwitch: " .. tostring(bMiniTvSwitch))
    end
  end
  if not bMiniTvSwitch then
    log(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole bMiniTvSwitch: " .. tostring(bMiniTvSwitch))
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local miniTvLevelCfg = logic_pet:GetPetLevelItemCfg(50000, 1)
  if nil == miniTvLevelCfg or nil == miniTvLevelCfg.LobbyPetBP then
    print(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole GetPetLevelItemCfg for mini tv failed!")
    return nil
  end
  print(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole LobbyPetBP", miniTvLevelCfg.LobbyPetBP)
  local softObjPath = KismetSystemLibrary.MakeSoftObjectPath(miniTvLevelCfg.LobbyPetBP)
  if softObjPath == nil then
    print(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole mini tv softObjPath is nil!")
    return nil
  end
  print(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole mini tv softObjPath", softObjPath)
  local ClassObj = STExtraBlueprintFunctionLibrary.GetClassByAssetReference(softObjPath)
  local world = slua_GameFrontendHUD:GetWorld()
  if ClassObj == nil then
    print(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole ClassObj is nil!")
    return nil
  end
  print(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole ClassObj", ClassObj)
  local actorObj = world:SpawnActor(ClassObj, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
  if actorObj == nil then
    print(bWriteLog and "ResultsRankingLogic:CreateMiniTvRole spawn tv actor failed")
    return nil
  end
  actorObj:SetActorScale3D(FVector(1.0, 1.0, 1.0))
  local playerPos = Game:GetActorLocation(Player)
  local angle = Game:GetActorRotation(Player).Yaw
  local x = math.cos(math.rad(angle)) * 50
  local y = math.sin(math.rad(angle)) * 50
  local pos = playerPos + FVector(x + 20, y - 15, -86)
  local rot = FRotator(0, Game:GetActorRotation(Player).Yaw + 90, 0)
  local uScale = actorObj:GetActorScale3D()
  local uTransform = UKismetMathLibrary.MakeTransform(pos, rot, uScale)
  actorObj:K2_SetActorTransform(uTransform, false, nil, false)
  if actorObj.PetAvatarComponent_BP then
    actorObj.PetAvatarComponent_BP:PetEquipItemById(dressId)
  end
  return actorObj
end
function ResultsRankingLogic:GetMiniTvDressID(uid)
  local defaultDressID = 1601019
  local dressID
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    dressID = uPlayerController.CommerFeature and uPlayerController.CommerFeature.TeamMemberMiniTvDressID and uPlayerController.CommerFeature.TeamMemberMiniTvDressID[uid]
  end
  if not dressID then
    return defaultDressID
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local downloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {dressID})
  if downloadState ~= ENUM_DownloadState.Done then
    log(bWriteLog and "ResultsRankingLogic:GetMiniTvDressID skin not downloaded, use default. originID: " .. tostring(dressID))
    return defaultDressID
  end
  return dressID
end
function ResultsRankingLogic:OnShowResultAnim(InAnimPlayConfig)
  print(bWriteLog and "ResultsRankingLogic:OnShowResultAnim bShowResultAnim", self.bShowResultAnim)
  if self.bShowResultAnim then
    if InAnimPlayConfig and CGameState and CGameState:IsCreativeMode() then
      local CreativeModeCharacterAnimationUtility = require("GameLua.Mod.CreativeBase.Gameplay.Animation.CreativeModeCharacterAnimationUtility")
      for index, AnimSeqPath in pairs(InAnimPlayConfig.IndexToAnimSeqMap) do
        local PlayerPawn = self.PlayerActorSet[index - 1]
        if slua.isValid(PlayerPawn) then
          CreativeModeCharacterAnimationUtility.LocalPlayCreativeEmoteAnim(0, 1, true, "WholeBody", 0.25, 0.25, PlayerPawn, 0, AnimSeqPath, 0)
        end
      end
      return
    end
    local path
    if self.IndextoAnimIdMap[0] ~= nil then
      local CameraPlayer = self.PlayerActorSet[0]
      path = self:GetCameraLevelSequence(self.PlayerActorCnt)
      self.ResultRoleRootTransform = self.ResultRoleRoot:GetRootTransform()
      local PlayEmoteComp = CameraPlayer.LobbyPlayEmoteComponent_BP
      if PlayEmoteComp ~= nil then
        PlayEmoteComp.OnEmoteCameraStop:Bind(function()
          self:OnStopLevelSequence()
        end)
        PlayEmoteComp.isPlayCameraAnim = true
        self.HasLevelSeq = true
      end
    end
    local PlayActorAnim = function(loadObject)
      print(bWriteLog and "ResultsRankingLogic:OnShowResultAnim loadObject", loadObject)
      for index, Value in pairs(self.PlayerActorSet) do
        local id = self.IndextoAnimIdMap[index]
        print(bWriteLog and "ResultsRankingLogic:OnShowResultAnim11", index, id, Value)
        if id ~= nil and id ~= 0 and Value then
          local EmoteHandle = Value:GetEmoteHandle(id)
          if nil == EmoteHandle then
            print(bWriteLog and "ResultsRankingLogic:OnShowResultAnim cant get EmoteHandle", id)
            return
          end
          local AnimArray = EmoteHandle.MainCharacterAnimConfig
          local AnimConfig
          if AnimArray:Num() >= 2 then
            AnimConfig = AnimArray:Get(0)
            AnimConfig.MainCharacterTransform = self.ResultRoleRootTransform
            AnimConfig.EmoteLevelSequence = loadObject
            AnimArray:Set(0, AnimConfig)
            AnimConfig = AnimArray:Get(1)
            AnimConfig.MainCharacterTransform = self.ResultRoleRootTransform
            AnimConfig.EmoteLevelSequence = loadObject
            AnimArray:Set(1, AnimConfig)
          end
          Value:CharPlayEmotebyResId(id, "")
        end
      end
      EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_HANDLE_ALL_UPVOTE)
    end
    print(bWriteLog and "ResultsRankingLogic:OnShowResultAnim", path)
    if path ~= nil then
      local delegate = util.GetAssetAsync(path, PlayActorAnim)
    else
      self.CanSwitchAvatarPage = true
      PlayActorAnim()
    end
  end
end
function ResultsRankingLogic:OnStopLevelSequence()
  print(bWriteLog and "ResultsRankingLogic:OnStopLevelSequence")
  self.CanSwitchAvatarPage = true
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(playerController) then
    return
  end
  local uCameraClass = import("CameraActor")
  local UIUtil = require("client.common.ui_util")
  local uCameraArray = GameplayStatics.GetAllActorsOfClass(UIUtil.GetGameInstance(), uCameraClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  for _, uTarget in pairs(uCameraArray) do
    if uTarget and slua.isValid(uTarget) then
      local name = KismetSystemLibrary.GetObjectName(uTarget)
      print(bWriteLog and "ResultsRankingLogic:OnStopLevelSequence", name)
      if string.find(name, "Child") ~= nil or string.find(name, "child") ~= nil then
        local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
        playerController:SetViewTargetWithBlend(uTarget, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
        local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
        Lobby_camera_manager_module:_ExecuteLevelSequenceEndCallback()
        print(bWriteLog and "ResultsRankingLogic:OnStopLevelSequence done")
      end
    end
  end
  EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_HANDLE_ALL_UPVOTE)
end
function ResultsRankingLogic:GetResultRoleRoot(resultRoleData)
  print(bWriteLog and "ResultsRankingLogic:GetResultRoleRoot")
  if not slua.isValid(self.ResultRoleRoot) then
    local uTargetArray
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local BattleResultOtherConfig = GamePlayTools.GetCurrentConfig("BattleResultConfig").OtherConfig
    local RoleTransformPath = "/Game/BluePrints/ControlInput/ResultsshareUI/Item/ResultRoleTransform.ResultRoleTransform"
    if BattleResultOtherConfig and BattleResultOtherConfig.RoleTransformPath then
      RoleTransformPath = BattleResultOtherConfig.RoleTransformPath
    end
    if resultRoleData and resultRoleData.ResultRoleTransformBPPath then
      RoleTransformPath = resultRoleData.ResultRoleTransformBPPath
    end
    local ResultRoleTransformClass = slua.loadClass(RoleTransformPath)
    print(bWriteLog and "ResultsRankingLogic:GetResultRoleRoot ResultRoleTransformClass:", ResultRoleTransformClass, RoleTransformPath)
    local UIUtil = require("client.common.ui_util")
    uTargetArray = GameplayStatics.GetAllActorsOfClass(UIUtil.GetGameInstance(), ResultRoleTransformClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
    if not slua.isValid(uTargetArray) then
      print(bWriteLog and "ResultsRankingLogic:GetResultRoleRoot ResultRoleTransform Array is not valid!")
      return
    end
    print(bWriteLog and "ResultsRankingLogic:GetResultRoleRoot ResultRoleTransform Array", uTargetArray, uTargetArray:Num())
    local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
    for idx, uTarget in pairs(uTargetArray) do
      print(bWriteLog and "ResultsRankingLogic:GetResultRoleRoot ", idx, uTarget)
      if uTarget and slua.isValid(uTarget) then
        if BattleResultSubSystem and BattleResultSubSystem.CheckRoleTransform then
          if BattleResultSubSystem:CheckRoleTransform(uTarget) then
            self.ResultRoleRoot = uTarget
            break
          end
        else
          self.ResultRoleRoot = uTarget
          break
        end
      end
    end
  end
  if not slua.isValid(self.ResultRoleRoot) then
    self.ResultRoleRoot = nil
  end
  return self.ResultRoleRoot
end
function ResultsRankingLogic:GetRoleIndexByUID(uid)
  local showRoleInfos = self:GetCurPageRoleInfos()
  if not showRoleInfos then
    print(bWriteLog and "ResultsRankingLogic:nil showRoleInfos")
    return
  end
  log_tree(bWriteLog and "ResultsRankingLogic:GetRoleIndexByUID", showRoleInfos)
  for roleIndex, roleInfo in ipairs(showRoleInfos) do
    if tonumber(roleInfo.uid) == tonumber(uid) then
      return roleIndex
    end
  end
end
function ResultsRankingLogic:GetRoleInfoByIndex(roleIndex)
  local RoleInfos = self:GetCurPageRoleInfos()
  return RoleInfos[roleIndex]
end
function ResultsRankingLogic:GetRoleRootActors()
  return self.RoleRootActors
end
function ResultsRankingLogic:PlayRoleEmote(roleIndex, EmoteID, bInterrupt)
  print(bWriteLog and "ResultsRankingLogic:PlayRoleEmote", roleIndex, EmoteID, bInterrupt)
  local RolePawn = self.PlayerActorSet[roleIndex - 1]
  if not slua.isValid(RolePawn) then
    return
  end
  if RolePawn.IsPlayingAction and not bInterrupt then
    print(bWriteLog and "ResultsRankingLogic:PlayRoleEmote IsPlayingAction")
    return
  end
  RolePawn:CharPlayEmotebyResId(EmoteID, "")
end
function ResultsRankingLogic:PlayMiniTvBeVotedEmote(uid)
  print(bWriteLog and "ResultsRankingLogic:PlayMiniTvBeVotedEmote", uid)
  if not uid then
    return
  end
  local roleIndex = self:GetRoleIndexByUID(uid)
  if not roleIndex then
    print(bWriteLog and "ResultsRankingLogic:PlayMiniTvBeVotedEmote can not find role index by uid.")
    return
  end
  local RolePawn = self.PlayerActorSet[roleIndex - 1]
  if not slua.isValid(RolePawn) then
    print(bWriteLog and "ResultsRankingLogic:PlayMiniTvBeVotedEmote role pawn is not found.")
    return
  end
  local miniTvActor = self.MiniTvActorSet and self.MiniTvActorSet[RolePawn] and self.MiniTvActorSet[RolePawn][uid]
  if not slua.isValid(miniTvActor) then
    print(bWriteLog and "ResultsRankingLogic:PlayMiniTvBeVotedEmote mini tv action is invalid.")
    return
  end
  local actionCfg = CDataTable.GetTableData("PetActionTable", CONST_MINITV_BE_VOUTE_ACTION_ID)
  if not actionCfg then
    print(bWriteLog and "ResultsRankingLogic:PlayMiniTvBeVotedEmote can not find action cfg.")
    return
  end
  local path = actionCfg.PetAnimRes
  if not path or path == "" then
    print(bWriteLog and "ResultsRankingLogic:PlayMiniTvBeVotedEmote path is invalid.")
    return
  end
  local EMontagePlayReturnType = import("EMontagePlayReturnType")
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(path, function(animAsset)
    print(bWriteLog and "ResultsRankingLogic:PlayMiniTvBeVotedEmote animAsset", tostring(animAsset))
    if animAsset and slua.isValid(miniTvActor) and slua.isValid(miniTvActor.Mesh) then
      local AnimInstance = miniTvActor.Mesh:GetAnimInstance()
      if slua.isValid(AnimInstance) then
        AnimInstance:Montage_Play(animAsset, 1, EMontagePlayReturnType.MontageLength, 0)
      end
    end
  end)
end
function ResultsRankingLogic:CloseBRTDMEndWeathers(LevelName)
  print(bWriteLog and "ResultsRankingLogic:CloseBRTDMEndWeathers")
  local USTExtraGameplayStatics = import("STExtraGameplayStatics")
  local uDirectionalLightClass = import("/Script/Engine.DirectionalLight")
  local uAPointLightClass = import("/Script/Engine.PointLight")
  local uSkyLightClass = import("/Script/Engine.SkyLight")
  local uFogsClass = import("/Script/Engine.ExponentialHeightFog")
  local world = slua_GameFrontendHUD:GetWorld()
  local GameEndLevel = GameplayStatics.GetStreamingLevel(world, LevelName)
  if slua.isValid(GameEndLevel) then
    local GameEndLevelAct = GameEndLevel:GetLevelScriptActor()
    if slua.isValid(GameEndLevelAct) then
      local DirectionalLightActors = USTExtraGameplayStatics.GetAllActorsOfSameLevel(GameEndLevelAct, uDirectionalLightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      local APointLightClassActors = USTExtraGameplayStatics.GetAllActorsOfSameLevel(GameEndLevelAct, uAPointLightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      local SkyLightActors = USTExtraGameplayStatics.GetAllActorsOfSameLevel(GameEndLevelAct, uSkyLightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      local FogActors = USTExtraGameplayStatics.GetAllActorsOfSameLevel(GameEndLevelAct, uFogsClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      for _, v in pairs(DirectionalLightActors) do
        if v.LightComponent:IsVisible() then
          v.LightComponent:SetVisibility(false, true)
        end
      end
      for _, v in pairs(APointLightClassActors) do
        if v.LightComponent:IsVisible() then
          v.LightComponent:SetVisibility(false, true)
        end
      end
      for _, v in pairs(SkyLightActors) do
        if v.LightComponent:IsVisible() then
          v.LightComponent:SetVisibility(false, true)
        end
      end
      for _, v in pairs(FogActors) do
        if v.Component:IsVisible() then
          v.Component:SetVisibility(false, true)
        end
      end
    end
  end
  print(bWriteLog and "ResultsRankingLogic:CloseBRTDMEndWeathers over")
end
function ResultsRankingLogic:CloseMainLevelWeathersAndOpenBRTDMEndWeather(LevelName)
  print(bWriteLog and "CloseMainLevelWeathersAndOpenBRTDMEndWeather")
  local USTExtraGameplayStatics = import("STExtraGameplayStatics")
  local uDirectionalLightClass = import("/Script/Engine.DirectionalLight")
  local MainDirectionalLightActors = Game:GetActorsByClass(uDirectionalLightClass)
  local uSkyLightClass = import("/Script/Engine.SkyLight")
  local MainSkyLightActors = Game:GetActorsByClass(uSkyLightClass)
  local uFogsClass = import("/Script/Engine.ExponentialHeightFog")
  local MainFogActors = Game:GetActorsByClass(uFogsClass)
  local uAPointLightClass = import("/Script/Engine.PointLight")
  local world = slua_GameFrontendHUD:GetWorld()
  local GameEndLevel = GameplayStatics.GetStreamingLevel(world, LevelName)
  if slua.isValid(GameEndLevel) then
    local GameEndLevelAct = GameEndLevel:GetLevelScriptActor()
    if slua.isValid(GameEndLevelAct) then
      for _, v in pairs(MainDirectionalLightActors) do
        if v.LightComponent:IsVisible() then
          v.LightComponent:SetVisibility(false, true)
        end
      end
      for _, v in pairs(MainSkyLightActors) do
        if v.LightComponent:IsVisible() then
          v.LightComponent:SetVisibility(false, true)
        end
      end
      for _, v in pairs(MainFogActors) do
        if v.Component:IsVisible() then
          v.Component:SetVisibility(false, true)
        end
      end
      local DirectionalLightActors = USTExtraGameplayStatics.GetAllActorsOfSameLevel(GameEndLevelAct, uDirectionalLightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      local SkyLightActors = USTExtraGameplayStatics.GetAllActorsOfSameLevel(GameEndLevelAct, uSkyLightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      local FogActors = USTExtraGameplayStatics.GetAllActorsOfSameLevel(GameEndLevelAct, uFogsClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      local APointLightClassActors = USTExtraGameplayStatics.GetAllActorsOfSameLevel(GameEndLevelAct, uAPointLightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      for _, v in pairs(DirectionalLightActors) do
        if not v.LightComponent:IsVisible() then
          v.LightComponent:SetVisibility(true, true)
        end
      end
      for _, v in pairs(APointLightClassActors) do
        if not v.LightComponent:IsVisible() then
          v.LightComponent:SetVisibility(false, true)
        end
      end
      for _, v in pairs(SkyLightActors) do
        if not v.LightComponent:IsVisible() then
          v.LightComponent:SetVisibility(true, true)
        end
      end
      for _, v in pairs(FogActors) do
        if not v.Component:IsVisible() then
          v.Component:SetVisibility(true, true)
        end
      end
    end
  end
end
function ResultsRankingLogic:ResetAvatarViewLoaded()
  print(bWriteLog and "ResultsRankingLogic:ResetAvatarViewLoaded")
  self.AvatarViewLoaded = false
end
function ResultsRankingLogic:ChangeAllLobbyPawnMeshCollision(bValidate, CollisionProfileName)
  print(bWriteLog and "ResultsRankingLogic:ValidateLobbyPawnMeshCollision")
  if not self.PlayerActorSet then
    print(bWriteLog and "ResultsRankingLogic:ValidateLobbyPawnMeshCollision self.PlayerActorSet is nil")
    return
  end
  local ECollisionEnabled = import("ECollisionEnabled")
  local EnableCollision = bValidate and ECollisionEnabled.QueryAndPhysics or ECollisionEnabled.NoCollision
  for _, PawnActor in pairs(self.PlayerActorSet) do
    if slua.isValid(PawnActor) and slua.isValid(PawnActor.Mesh) then
      PawnActor.Mesh:SetCollisionEnabled(EnableCollision)
      if bValidate and CollisionProfileName and type(CollisionProfileName) == "string" then
        PawnActor.Mesh:SetCollisionProfileName(CollisionProfileName)
      else
        PawnActor.Mesh:SetCollisionProfileName("CharacterMesh")
      end
    end
  end
end
function ResultsRankingLogic:GetAllLobbyPawn()
  return DeepCopy(self.PlayerActorSet)
end
return ResultsRankingLogic