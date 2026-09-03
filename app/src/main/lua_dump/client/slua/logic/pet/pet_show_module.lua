local PetExhibitConfig = require("client.lobby_ue_object.Actor.PetExhibit.PetExhibitConfig")
local TimeUtil = require("client.common.time_util")
local EActorHiddenMask = import("EActorHiddenMask")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local KismetSystemLibrary = import("KismetSystemLibrary")
local pet_show_module = {}
function pet_show_module:ctor()
  self.LastShowTime = 0
end
function pet_show_module:DefineAndResetData()
  self.LastShowTime = 0
end
function pet_show_module:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_EXHIBITION_START, self.OnExhibitionStart, self)
  self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_EXHIBITION_END, self.OnExhibitionEnd, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.OnTeamInfoSync, self)
end
function pet_show_module:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:DefineAndResetData()
  end
  if nextState == GameStatus.Lobby then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local CurrentNum = TeamUpNewSystem.GetTeamNum()
    self.bCurrentInTeam = CurrentNum and 1 < CurrentNum
  end
end
function pet_show_module:ShowPetSequence(uid, carry_info, equip_info, ext_info)
  local PetDataList = self:SetupPetData(uid, carry_info, equip_info)
  self:ClearPetSequence()
  local World = slua_GameFrontendHUD:GetWorld()
  local PetExhibitContainerClass = slua.loadClass(PetExhibitConfig.PetExhibitContainerLobbyPath)
  local bHasDownload = self:CheckHasDownloadedPet(PetDataList)
  if not bHasDownload then
    ShowNotice(73124)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local bInTeam = TeamUpNewSystem.IsInTeam()
  local bIsXMission = XMissionSystem.IsInXMission()
  local SpawnLocation, SpawnRotator
  if bInTeam and bIsXMission then
    SpawnLocation = PetExhibitConfig.TPlanLobbyOffsetTeam
    SpawnRotator = PetExhibitConfig.TPlanLobbyRotationTeam
  elseif not bInTeam and bIsXMission then
    SpawnLocation = PetExhibitConfig.TPlanLobbyOffsetSingle
    SpawnRotator = PetExhibitConfig.TPlanLobbyRotationSingle
  elseif bInTeam and not bIsXMission then
    SpawnLocation = PetExhibitConfig.LobbyOffsetTeam
    SpawnRotator = PetExhibitConfig.LobbyRotationTeam
  else
    SpawnLocation = PetExhibitConfig.LobbyOffsetSingle
    SpawnRotator = PetExhibitConfig.LobbyRotationSingle
  end
  self.PetExhibitContainerActor = World:SpawnActor(PetExhibitContainerClass, SpawnLocation, SpawnRotator, nil)
  self.PetExhibitContainerActor:SetOwnerUIDAndPlayerKey(uid, nil)
  self.PetExhibitContainerActor:SetPetDataList(PetDataList)
  self.PetExhibitContainerActor:SetEffectItemId(ext_info.effectItemId)
  self.PetExhibitContainerActor:SetActionDataMap(ext_info.actionData)
end
function pet_show_module:PreLoadParticle(ext_info)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local effectCfg = logic_pet:GetPortalCfgByItemId(ext_info.effectItemId)
  local Particle = effectCfg and effectCfg.Appear or PetExhibitConfig.PetAppear
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(Particle, function()
    log(bWriteLog and "  pet_show_module:LoadParticle.  PreLoadParticle complete.")
  end)
end
function pet_show_module:ClearPetSequence()
  if self.PetExhibitContainerActor and slua.isValid(self.PetExhibitContainerActor) then
    self.PetExhibitContainerActor:K2_DestroyActor()
    self.PetExhibitContainerActor = nil
  end
end
function pet_show_module:IsShowing()
  if self.PetExhibitContainerActor and slua.isValid(self.PetExhibitContainerActor) then
    return true
  end
  return false
end
function pet_show_module:SetupPetData(uid, carry_info, equip_info)
  if not uid then
    return
  end
  local PetDataList = {}
  if carry_info and next(carry_info) then
    for k, v in pairs(carry_info) do
      local PetData = {
        UID = uid,
        PetID = v.pet_id or 50000,
        PetLevel = v.pet_level or 1,
        Color = v.Color or 1,
        Dress = {}
      }
      if v.dress and next(v.dress) then
        for ItemID, _ in pairs(v.dress) do
          table.insert(PetData.Dress, ItemID)
        end
      end
      table.insert(PetDataList, PetData)
    end
  end
  table.sort(PetDataList, function(a, b)
    return a.PetID > b.PetID
  end)
  if equip_info then
    local PetData = {
      UID = uid,
      PetID = equip_info.pet_id or 50000,
      PetLevel = equip_info.pet_level or 1,
      Color = equip_info.Color or 1,
      Dress = {}
    }
    if equip_info.dress and next(equip_info.dress) then
      for ItemID, _ in pairs(equip_info.dress) do
        table.insert(PetData.Dress, ItemID)
      end
    end
    table.insert(PetDataList, 1, PetData)
  end
  return PetDataList
end
function pet_show_module:OnExhibitionStart(_, __, UID, PlayerKey)
  if tonumber(UID) == tonumber(DataMgr.roleData.uid) then
    self:SetMyRobotVisiblility(false)
  else
    self:SetMyRobotVisiblility(true)
  end
  self:UpdateTeamPetVisibility(UID, true)
end
function pet_show_module:OnExhibitionEnd(_, __, UID, PlayerKey)
  if tonumber(UID) == tonumber(DataMgr.roleData.uid) then
    self:SetMyRobotVisiblility(true)
  end
  self:UpdateTeamPetVisibility(UID, false)
end
function pet_show_module:SetMyRobotVisiblility(bVisible)
  local MiniTvSystem = require("client.slua.logic.mini_tv.logic_mini_tv")
  local MiniTVActor = MiniTvSystem.GetMiniTVActor()
  if MiniTVActor then
    MiniTVActor:SetActorHiddenInGame(not bVisible)
  end
end
function pet_show_module:UpdateTeamPetVisibility(UID, bStartExhibit)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  UID = tostring(UID)
  if bStartExhibit then
    if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
      for k, _ in pairs(TeamUpNewSystem.teamInfo.members) do
        local bHidden = tostring(k) == tostring(UID)
        local Avatar = TeamAvatarManager.GetAvatarByUid(k)
        local Pet = Avatar and Avatar:GetPet()
        local Model = Pet and Pet:GetModel()
        if Model then
          Model:SetActorHiddenInGameMask(bHidden, EActorHiddenMask.ActorHiddenMask5)
        end
      end
    end
    local XMissionAvatarList = XMissionAvatarMgr.GetAvatarList()
    if XMissionAvatarList then
      for k, Avatar in pairs(XMissionAvatarList) do
        local bHidden = tostring(k) == tostring(UID)
        local Pet = Avatar:GetPet()
        local Model = Pet and Pet:GetModel()
        if Model then
          Model:SetActorHiddenInGameMask(bHidden, EActorHiddenMask.ActorHiddenMask5)
        end
      end
    end
  else
    local Avatar = TeamAvatarManager.GetAvatarByUid(UID)
    if Avatar then
      local Pet = Avatar:GetPet()
      local Model = Pet and Pet:GetModel()
      if Model then
        Pet:GetModel():SetActorHiddenInGameMask(false, EActorHiddenMask.ActorHiddenMask5)
      end
    end
    local XMissionAvatar = XMissionAvatarMgr.GetAvatarByUID(UID)
    if XMissionAvatar then
      local Pet = XMissionAvatar:GetPet()
      local Model = Pet and Pet:GetModel()
      if Model then
        Model:SetActorHiddenInGameMask(false, EActorHiddenMask.ActorHiddenMask5)
      end
    end
  end
end
function pet_show_module:CheckAndRequestPetShow()
  local RemainCD = self:GetLobbyRemainCD()
  log(bWriteLog and "pet_show_module:CheckAndRequestPetShow RemainCD: " .. tostring(RemainCD))
  if 0 < RemainCD then
    ShowNotice(421015)
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local effectItemId = logic_pet:GetCurrentEquipEffect()
  local extraData = {
    actionData = self:GenerateActionDataMap(),
      }
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_pet_show_req(extraData)
  self:ResetShowTime()
end
function pet_show_module:GetLobbyRemainCD()
  local CurrentTime = TimeUtil.GetMiliseconds()
  local PassedTime = CurrentTime - self.LastShowTime
  local RemainTime = PetExhibitConfig.LobbyPlayCD - PassedTime
  if 0 < RemainTime then
    return RemainTime
  end
  return 0
end
function pet_show_module:on_notify_pet_show(uid, carry_info, equip_info, ext_info)
  log(bWriteLog and string.format("pet_show_module:on_notify_pet_show. uid=%s, carry_info=%s, equip_info=%s", tostring(uid), tostring(carry_info), tostring(equip_info)))
  self:ClearPetSequence()
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({uid}, function(list)
    local profile = list[1]
    if profile and profile.nickName then
      local tips = LocUtil.LocalizeResFormat(66956, profile.nickName)
      ShowNotice(tips)
    end
  end, Enum_PROFILE_REPORT_CFG.PET)
  local PetExhibitConfig = require("client.lobby_ue_object.Actor.PetExhibit.PetExhibitConfig")
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local IsInXMission = XMissionSystem.IsInXMission()
  if IsInXMission then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    XMissionAvatarMgr.PlayAction(uid, PetExhibitConfig.PlayerActionID)
  else
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.PlayEmoteAction(uid, PetExhibitConfig.PlayerActionID)
  end
  self:AddTimer(PetExhibitConfig.PetStartTime, function()
    self:ShowPetSequence(uid, carry_info, equip_info, ext_info)
  end)
  self:PreLoadParticle(ext_info)
end
function pet_show_module:OnTeamInfoSync()
  log(bWriteLog and "pet_show_module:OnTeamInfoSync. ")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local NewTeamNum = TeamUpNewSystem.GetTeamNum()
  local bNewInTeam = NewTeamNum and 1 < NewTeamNum
  if bNewInTeam ~= self.bCurrentInTeam then
    self.bCurrentInTeam = bNewInTeam
    self:ClearPetSequence()
  end
end
function pet_show_module:GenerateActionDataMap()
  local ActionDataMap = {}
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local EquipPetID = logic_pet:GetEquipedPetItemID()
  if EquipPetID and EquipPetID ~= 0 then
    local ActionData = self:GetOnePetActionData(EquipPetID)
    if ActionData then
      ActionDataMap[EquipPetID] = ActionData
    end
  end
  local CarryPets = logic_pet:GetCurrentCarryPets()
  if CarryPets then
    for _, PetID in pairs(CarryPets) do
      if PetID and PetID ~= 0 and not ActionDataMap[PetID] then
        local ActionData = self:GetOnePetActionData(PetID)
        if ActionData then
          ActionDataMap[PetID] = ActionData
        end
      end
    end
  end
  return ActionDataMap
end
function pet_show_module:GetOnePetActionData(PetID)
  if not PetID then
    return nil
  end
  if PetID == 50001 then
    return {
      PetID = PetID,
      AnimAsset = PetExhibitConfig.GyrfalconActionAsset,
      Length = PetExhibitConfig.GyrfalconActionLength
    }
  else
    local PetConfigData = CDataTable.GetTableData("PetTable", PetID)
    if not PetConfigData then
      log(bWriteLog and "pet_show_module:GetOnePetActionData. no PetConfigData return")
      return {}
    end
    local ClickAction = PetConfigData.ClickAction
    local StringUtil = require("common.string_util")
    local ClickActionList = StringUtil.Split(tostring(ClickAction), "|")
    local RandomActionID
    if 0 < #ClickActionList then
      local RandomSelected = math.random(#ClickActionList)
      RandomActionID = tonumber(ClickActionList[RandomSelected])
    end
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    if not RandomActionID then
      log(bWriteLog and "pet_show_module:GetOnePetActionData. RandomActionID is nil return")
      return nil
    end
    if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {RandomActionID}) ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and "pet_show_module:GetOnePetActionData. Action resource is not downloaded, return")
      return nil
    end
    local ActionConfig = CDataTable.GetTableData("PetActionTable", RandomActionID)
    if not ActionConfig then
      log(bWriteLog and "pet_show_module:GetOnePetActionData. no ActionConfig for " .. tostring(RandomActionID) .. " return")
      return nil
    end
    local MontageAsset = self:LoadMontageAsset(ActionConfig.LobbyPetAnimRes)
    if not MontageAsset then
      return nil
    end
    local Duration = self:GetMontageLength(MontageAsset)
    return {
      ActionID = RandomActionID,
      Length = Duration or PetExhibitConfig.MiniTVActionLength,
          }
  end
end
function pet_show_module:LoadMontageAsset(MontagePath)
  if not MontagePath then
    return 0
  end
  local SoftObjectPath = KismetSystemLibrary.MakeSoftObjectPath(MontagePath)
  local Asset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(SoftObjectPath)
  return Asset
end
function pet_show_module:GetMontageLength(MontageAsset)
  return slua.isValid(MontageAsset) and MontageAsset.SequenceLength or 0
end
function pet_show_module:on_pet_show_rsp()
  self:ResetShowTime()
end
function pet_show_module:ResetShowTime()
  self.LastShowTime = TimeUtil.GetMiliseconds()
end
function pet_show_module:CheckHasDownloadedPet(PetDataList)
  if not PetDataList then
    return false
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local bHasDownload = false
  for i, v in pairs(PetDataList) do
    if v and v.PetID then
      local DownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
        v.PetID
      })
      if DownloadState == PufferConst.ENUM_DownloadState.Done then
        bHasDownload = true
      end
    end
  end
  return bHasDownload
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cpet_show_module = class(CModuleBase, nil, pet_show_module)
return Cpet_show_module