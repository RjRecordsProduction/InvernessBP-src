local EPawnState = import("EPawnState")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local logic_emote = {
  DisableStates = {
    EPawnState.Crouch,
    EPawnState.Jump,
    EPawnState.Prone
  },
  TipsID = {
    PawnStateTips = 44704,
    SelfieTips = 44703,
    FppTips = 44702,
    NoSpaceTips = 38877,
    DanceStartTips = 38851,
    NotDownLoadJoinTips = 44705,
    ModeNoticeTips = 77541
  },
  bShowEffect = false,
  bShowEffectDirty = false,
  DanceEmoteCacheTable = {},
  DanceTogetherSkillID = 1014074,
  PetExhibitActionID = 12220066,
  LastExhibitPetTime = -1,
  PetExhibitCD = 25,
  MileStoneMaxNum = 4,
  CustomWeaponShowEmoteID = -1,
  bCustomWeaponShow = false,
  WeaponShowEmoteIDMap = nil,
  IsWeaponShowEmoteIDMap = nil,
  MileStomeMap = nil,
  MileStoneDownloadListMap = nil
}
function logic_emote.CheckIsDanceTogetherEmote(EmoteID)
  if not EmoteID or EmoteID < 0 then
    return false
  end
  if logic_emote.DanceEmoteCacheTable[EmoteID] then
    return true
  end
  local TogetherEmoteCfg = CDataTable.GetTableData("TogetherEmoteCfg", EmoteID)
  if TogetherEmoteCfg then
    logic_emote.DanceEmoteCacheTable[EmoteID] = true
    return true
  end
  return false
end
function logic_emote.TriggerDanceBuildSkill(EmoteID)
  print(bWriteLog and "[DanceTogether] logic_emote.TriggerDanceBuildSkill EmoteID:" .. tostring(EmoteID))
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.TriggerDanceBuildSkill no uPlayerController")
    return
  end
  local uPlayer = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayer) then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.TriggerDanceBuildSkill no uPlayer")
    return
  end
  if logic_emote.CheckDancerIsFpp(uPlayer) then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.TriggerDanceBuildSkill Fpp Can`t Allow To Use")
    return
  end
  if not logic_emote.CheckDanceCharacterState(uPlayer) then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.TriggerDanceBuildSkill Pawn State Failed ")
    ShowNotice(logic_emote.TipsID.PawnStateTips)
    return
  end
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if IngameSelfieSubsystem and IngameSelfieSubsystem.bIsIngameSelfieMode then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.TriggerDanceBuildSkill Is In SelfieMode")
    ShowNotice(logic_emote.TipsID.SelfieTips)
    return
  end
  local TogetherEmoteCfg = CDataTable.GetTableData("TogetherEmoteCfg", EmoteID)
  if not TogetherEmoteCfg then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.TriggerDanceBuildSkill no Config EmoteID:" .. tostring(EmoteID))
    return false
  end
  local uSkillManagerComp = uPlayer:GetSkillManager()
  if not slua.isValid(uSkillManagerComp) then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.TriggerDanceBuildSkill uSkillManagerComp is not Valid")
    return false
  end
  if not logic_emote.CheckIsDanceTogetherMode() then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.TriggerDanceBuildSkill CheckIsDanceTogetherMode false")
    ShowNotice(logic_emote.TipsID.ModeNoticeTips)
    return
  end
  logic_emote.StopEmote(uPlayer)
  uSkillManagerComp:SetValueAsInt(logic_emote.DanceTogetherSkillID, "AvatarID", EmoteID)
  uPlayer:TriggerEntrySkillWithParams(logic_emote.DanceTogetherSkillID, {"AvatarID"}, true)
end
function logic_emote.CheckIsDanceTogetherMode()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.bPlanBT then
    print(bWriteLog and "[DanceTogether] logic_emote.CheckIsDanceTogetherMode PlanBT")
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.CheckIsDanceTogetherMode not slua.isValid(uGameState)")
    return false
  end
  print(bWriteLog and "[DanceTogether] logic_emote.CheckIsDanceTogetherMode Current Mode" .. tostring(uGameState.GameModeType))
  local EGameModeType = import("EGameModeType")
  if uGameState.GameModeType == EGameModeType.ETypicalGameMode or uGameState.GameModeType == EGameModeType.ESocialIsland or uGameState.GameModeType == EGameModeType.ECreativeModeGameMode or uGameState.GameModeType == EGameModeType.EPlanPHGameMode or uGameState.GameModeType == EGameModeType.EFourInOneGameMode or uGameState.GameModeType == EGameModeType.EMainCityGameMode or uGameState.GameModeType == EGameModeType.EPlanCHGameMode then
    return true
  end
  print(bWriteLog and "[DanceTogether][Warning] logic_emote.CheckIsDanceTogetherMode Current Mode: " .. tostring(uGameState.GameModeType))
  return false
end
function logic_emote.CheckDancerIsFpp(uPlayer)
  if not slua.isValid(uPlayer) then
    return false
  end
  if not uPlayer:IsAutonomousProxy() then
    return false
  end
  if uPlayer:GetIsFPP() then
    print(bWriteLog and "[DanceTogether] logic_emote CheckDancerIsFpp uPlayer is FPP")
    ShowNotice(logic_emote.TipsID.FppTips)
    return true
  end
  return false
end
function logic_emote.CheckEmoteIsBan(EmoteID)
  local EmoteData = CDataTable.GetTableData("BattleBanOnEmote", EmoteID)
  if not EmoteData then
    return false, 0
  end
  if logic_emote.IsBornisland() then
    return false, 0
  end
  if EmoteData.SocialIslandCanUse == 1 and (logic_emote.IsSocialIsland() or GameStatus.IsInLobbyOrMainCity()) then
    return false, 0
  end
  print(bWriteLog and "logic_emote.CheckEmoteIsBan EmoteID" .. tostring(EmoteID) .. "Can`t Use In Battle")
  return true, EmoteData.TipsID
end
function logic_emote.IsBornisland()
  if not slua_GameFrontendHUD then
    return false
  end
  local GameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(GameState) or not GameState.GetGameModeState then
    return false
  end
  return GameState:GetGameModeState() == "ReadyState"
end
function logic_emote.IsSocialIsland()
  if Client then
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    if MatchModeMgrSystem.IsSocialIslandMode(true) then
      print(bWriteLog and "BP_Battle_VehicleLicenseComponent:IsSocialIsland true")
      return true
    end
  else
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    if GamePlayTools.IsSocialIslandModeDS() then
      print(bWriteLog and "BP_Battle_VehicleLicenseComponent:IsSocialIsland true")
      return true
    end
  end
end
function logic_emote.CheckDanceCharacterState(Character)
  if not slua.isValid(Character) then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.CheckDanceCharacterState Character is not Valid")
    return false
  end
  if not Character:AllowState(EPawnState.PlayEmote, true) then
    print(bWriteLog and "[DanceTogether][Warning] logic_emote.CheckDanceCharacterState Character don`t Allow PlayEmote")
    return false
  end
  for _, _PawnState in pairs(logic_emote.DisableStates) do
    if Character:HasState(_PawnState) then
      print(bWriteLog and "[DanceTogether][Warning] logic_emote.CheckDanceCharacterState Character HasDisableState " .. tostring(_PawnState))
      return false
    end
  end
  return true
end
function logic_emote.CheckEmoteDownloaded(EmoteID, bUseCache, bLobby, bForeceLobby)
  local ItemDefineID = FItemDefineID(22, EmoteID)
  local BackpackUtils = import("BackpackUtils")
  return BackpackUtils.IsBattleItemHandleExist(ItemDefineID, bUseCache, bLobby, bForeceLobby)
end
function logic_emote.RecordShowEffect_Battle(bShowEffect)
  print(bWriteLog and "[ParticleEmote] logic_emote.RecordShowEffect_Battle" .. tostring(bShowEffect))
  logic_emote.  logic_emote.bShowEffectDirty = true
end
function logic_emote.GetShowEffect_Battle()
  print(bWriteLog and "[ParticleEmote] logic_emote.GetShowEffect_Battle" .. tostring(logic_emote.bShowEffect))
  return logic_emote.bShowEffect
end
function logic_emote.SetShowEffect(bShowEffect)
  print(bWriteLog and "[ParticleEmote] logic_emote.SetShowEffect" .. tostring(bShowEffect))
  logic_emote.end
function logic_emote.IsMileStoneEmote(ItemID)
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if not ItemCfg then
    return false
  end
  if ItemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.MileStoneAction then
    return true
  end
  return false
end
function logic_emote.IsAceImprintEmote(EmoteID)
  return EmoteID == 22010050
end
function logic_emote.PlayEmote(Player, EmoteID)
  if not Game:IsValid(Player) then
    return false
  end
  local ExtraInfo = ""
  if logic_emote.IsMileStoneEmote(EmoteID) then
    if not logic_emote.IsEmoteExist(EmoteID) then
      IngameTipsTools.BattleNormalTipsByTextID(27679)
      return false
    end
    ExtraInfo = logic_emote.GetMileStoneData(Player, EmoteID) or ""
    log(bWriteLog and "logic_emote.PlayEmote ExtraInfo = " .. ExtraInfo)
  end
  local result = Player:OnPlayEmote(EmoteID, ExtraInfo)
  return result
end
function logic_emote.StopEmote(Player)
  if not Game:IsValid(Player) then
    return false
  end
  local EmoteComp = Player:GetPlayEmoteComponent()
  if not Game:IsValid(EmoteComp) then
    log_warning("logic_emote.StopEmote EmoteComp:Is not Valid" .. tostring(Player))
    return false
  end
  if EmoteComp.CurrentPlayEmoteId > 0 then
    EmoteComp:LocalInteruptPlayEmote(EmoteComp.CurrentPlayEmoteId)
  end
end
function logic_emote.IsEmoteExist(EmoteID)
  local ItemDefineIDTemp = FItemDefineID(22, EmoteID)
  local UBackpackUtils = import("BackpackUtils")
  local bLobby = GameStatus.IsInLobbyOrMainCity()
  return UBackpackUtils.IsBattleItemHandleExist(ItemDefineIDTemp, true, bLobby, false)
end
function logic_emote.GetMileStoneDataInFight(Player, EmoteID)
  if not slua.isValid(Player) then
    return ""
  end
  local ENetRole = import("ENetRole")
  if Player.Role ~= ENetRole.ROLE_AutonomousProxy then
    return ""
  end
  local uPlayerController = Player:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    return ""
  end
  if not uPlayerController.CommerFeature.MileStoneMap then
    return ""
  end
  local StoneList = uPlayerController.CommerFeature.MileStoneMap[EmoteID] or {}
  local ExtraInfo = ""
  for key, ItemID in pairs(StoneList) do
    ExtraInfo = ExtraInfo .. tostring(ItemID) .. "|"
  end
  ExtraInfo = string.sub(ExtraInfo, 1, -2)
  return ExtraInfo
end
function logic_emote.GetMileStoneDataInLobby(Player, EmoteID)
  if not slua.isValid(Player) then
    return ""
  end
  local sysType = logic_emote.GetMileStoneTypeByItemID(EmoteID)
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  local ExtraInfo = LobbyEmoteManager:GetSelfMilestoneSlotExtraInfo(sysType)
  return ExtraInfo or ""
end
function logic_emote.GetMileStoneData(Player, EmoteID)
  log(bWriteLog and "logic_emote.GetMileStoneData IsInLobbyOrMainCity = " .. tostring(GameStatus.IsInLobbyOrMainCity()))
  if GameStatus.IsInLobbyOrMainCity() then
    return logic_emote.GetMileStoneDataInLobby(Player, EmoteID)
  else
    return logic_emote.GetMileStoneDataInFight(Player, EmoteID)
  end
end
function logic_emote.GetMileStoneEmoteInFight()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return {}
  end
  if not uPlayerController.CommerFeature.MileStoneMap then
    return {}
  end
  local result = {}
  for EmoteID, _ in pairs(uPlayerController.CommerFeature.MileStoneMap) do
    table.insert(result, EmoteID)
  end
  local LogStr = "logic_emote:GetMileStoneEmote result: "
  for _, v in pairs(result) do
    LogStr = LogStr .. tostring(v) .. " "
  end
  print(bWriteLog and LogStr)
  return result
end
function logic_emote.GetMileStoneEmoteInLobby()
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  local Emotes = LobbyEmoteManager:GetMilestoneEmotionMark()
  local result = {}
  for k, v in pairs(Emotes) do
    if v then
      table.insert(result, k)
    end
  end
  return result
end
function logic_emote.GetMileStoneEmote()
  log(bWriteLog and "logic_emote.GetMileStoneEmote IsInLobbyOrMainCity = " .. tostring(GameStatus.IsInLobbyOrMainCity()))
  if GameStatus.IsInLobbyOrMainCity() then
    return logic_emote.GetMileStoneEmoteInLobby()
  else
    return logic_emote.GetMileStoneEmoteInFight()
  end
end
function logic_emote.GetFlauntEmote()
  local result = logic_emote.GetMileStoneEmote()
  table.insert(result, 1, logic_emote.PetExhibitActionID)
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.PlayEmoteFeature then
    local PlacardList = PlayerController.PlayEmoteFeature.PlacardList
    for i, id in pairs(PlacardList) do
      result[#result + 1] = id
    end
    local PopularPKList = PlayerController.PlayEmoteFeature.PopularPKList
    for i, id in pairs(PopularPKList) do
      result[#result + 1] = id
    end
  end
  local playerDisplayModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionPlayerDisplayModule)
  if playerDisplayModule then
    local actionID = playerDisplayModule:GetActionItemID()
    local StoreUtils = require("client.slua.logic.store.utils.store_utils")
    if playerDisplayModule:HasUnlockAction() or StoreUtils.HasItem(actionID) or IsEditor then
      result[#result + 1] = actionID
    end
  end
  return result
end
function logic_emote.CheckIsPetExhibitionEmote(EmoteID)
  return EmoteID == logic_emote.PetExhibitActionID
end
function logic_emote.CheckCanUsePetExhibitionEmote()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local PetInfoArray = uPlayerController.AdditionalPetInfo
  for _, PetInfo in pairs(PetInfoArray) do
    if PetInfo and PetInfo.PetID ~= 0 then
      return true
    end
  end
  return false
end
function logic_emote.ErrorReport(msg)
  if not Client then
    return
  end
  if Client.IsDevelopment() then
    local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
    ClientToolsReport:SendReport(ClientToolsReport.Enum_SvrReport_Type.Enum_Xpcall, msg, false)
  end
end
function logic_emote.StartPetExibition()
  print(bWriteLog and "logic_emote.StartPetExibition. ")
  if not slua.isValid(CGameState) then
    print(bWriteLog and "logic_emote.StartPetExibition. no valid GameState return")
    return
  end
  logic_emote.LastExhibitPetTime = CGameState:GetServerWorldTimeSeconds()
end
function logic_emote.GetPetExhibitRemainCD()
  print(bWriteLog and "logic_emote.GetPetExhibitRemainCD. ")
  if not slua.isValid(CGameState) then
    print(bWriteLog and "logic_emote.GetPetExhibitRemainCD. no valid CGameState")
    return 0
  end
  if 0 > logic_emote.LastExhibitPetTime then
    print(bWriteLog and "logic_emote.GetPetExhibitRemainCD. LastExhibitPetTime < 0")
    return 0
  end
  local CurrentTime = CGameState:GetServerWorldTimeSeconds()
  local ElapsedTime = CurrentTime - logic_emote.LastExhibitPetTime
  local RemainTime = logic_emote.PetExhibitCD - ElapsedTime
  print(bWriteLog and "logic_emote.GetPetExhibitRemainCD RemainTime: " .. tostring(RemainTime))
  return 0 < RemainTime and RemainTime or 0
end
function logic_emote.ResetLastExhibitPetTime()
  print(bWriteLog and "logic_emote.ResetLastExhibitPetTime. ")
  logic_emote.LastExhibitPetTime = -1
end
function logic_emote.OnModePostSwitch(_, _, status)
  if status.current == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    logic_emote.ResetLastExhibitPetTime()
  end
end
function logic_emote.ChangeWeaponShow(bEnabled, EmoteID)
  logic_emote.bCustomWeaponShow = bEnabled
  if bEnabled then
    logic_emote.CustomWeaponShow  else
    logic_emote.CustomWeaponShowEmoteID = -1
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_WEAPON_SHOW_CHANGE)
end
function logic_emote.GetCustomWeaponShowID(ItemID)
  if not logic_emote.WeaponShowEmoteIDMap then
    logic_emote.WeaponShowEmoteIDMap = {}
    local Data = CDataTable.GetTable("CustomWeaponShow")
    for _, value in pairs(Data) do
      logic_emote.WeaponShowEmoteIDMap[value.ID] = value.WeaponShowEmoteID
    end
  end
  return logic_emote.WeaponShowEmoteIDMap[ItemID]
end
function logic_emote.GetCustomWeaponItemID(EmoteID)
  EmoteID = tonumber(EmoteID)
  if not logic_emote.IsWeaponShowEmoteIDMap then
    logic_emote.IsWeaponShowEmoteIDMap = {}
    local Data = CDataTable.GetTable("CustomWeaponShow")
    for _, value in pairs(Data) do
      logic_emote.IsWeaponShowEmoteIDMap[value.WeaponShowEmoteID] = value.ID
    end
  end
  return logic_emote.IsWeaponShowEmoteIDMap[EmoteID] or 0
end
function logic_emote.IsCustomWeaponShow(EmoteID)
  return logic_emote.GetCustomWeaponItemID(EmoteID) > 0
end
function logic_emote.GetMileStoneDownloadList(ItemID, itemCfg)
  itemCfg = itemCfg or CDataTable.GetTableData("Item", ItemID)
  if itemCfg.ItemSubType ~= ENUM_ITEM_SUBTYPE.MileStoneAction and itemCfg.ItemSubType ~= ENUM_ITEM_SUBTYPE.MileStone then
    return
  end
  local Type = logic_emote.GetMileStoneTypeByItemID(ItemID, itemCfg)
  if not Type then
    return
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  return collect_module:GetSplitTableByFilter("MilestoneConfig", nil, "Type", Type), logic_emote.MileStoneDownloadListMap[Type]
end
function logic_emote.GetMileStoneTypeByItemID(ItemID, itemCfg)
  itemCfg = itemCfg or CDataTable.GetTableData("Item", ItemID)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  logic_emote.InitMileStoneActionIdDownloadList()
  if itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.MileStone then
    local MilestoneConfig = collect_module:GetSplitTableData("MilestoneConfig", nil, ItemID)
    return MilestoneConfig and MilestoneConfig.ID > 0 and MilestoneConfig.Type
  end
  return logic_emote.MileStomeMap[ItemID]
end
function logic_emote.InitMileStoneActionIdDownloadList()
  if not logic_emote.MileStomeMap then
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    logic_emote.MileStomeMap = {}
    logic_emote.MileStoneDownloadListMap = {}
    local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
    local typeList = collect_cfg.E_Milestone_Server_Type
    for _, type in pairs(typeList) do
      local MilestoneConfig = collect_module:GetSplitTableDataByFilter("MilestoneConfig", nil, "Type", type)
      local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
      local sameTypeEmoteIds = LobbyEmoteManager:GetEmotesByMilestoneConfig(MilestoneConfig)
      logic_emote.MileStoneDownloadListMap[type] = {}
      for _, EmoteID in pairs(sameTypeEmoteIds) do
        local id = tonumber(EmoteID)
        logic_emote.MileStomeMap[id] = type
        logic_emote.MileStoneDownloadListMap[type][id] = true
      end
    end
  end
end
return logic_emote