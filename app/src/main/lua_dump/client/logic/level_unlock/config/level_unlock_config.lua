local LobbyUnlockConfig = {}
local featureDef = {
  achievement = 1001,
  corps = 1002,
  socialIsland = 1003,
  teamLobby = 1004,
  teamCompetitionMode = 1005,
  matchMode = 1006,
  season = 1007,
  workshop = 1008,
  pveMode = 1009,
  workshopPet = 1010,
  mentor = 1011,
  pictorial = 1012,
  entertainMode = 1013,
  workshopGunDiy = 1014,
  newbieUpgrade = 1015,
  home = 1016,
  mainCity = 1017,
  collectCard = 1018
}
LobbyUnlockConfig.ELockType = {hide = 1, normal = 2}
local ELockType = LobbyUnlockConfig.ELockType
LobbyUnlockConfig.ETipDir = {
  left = 0,
  up = 1,
  right = 2,
  down = 3
}
local ETipDir = LobbyUnlockConfig.ETipDir
LobbyUnlockConfig.ETipStyle = {line = 0}
local tipStyle = LobbyUnlockConfig.ETipStyle
LobbyUnlockConfig.ELobbyType = {Lobby = 1, MainCity = 2}
local ELobbyType = LobbyUnlockConfig.ELobbyType
LobbyUnlockConfig.EAwardStatus = {
  CantGet = 0,
  CanGet = 1,
  AlreadyGet = 2
}
LobbyUnlockConfig.GuestUnLockFeatures = {
  [featureDef.matchMode] = 20
}
local unlockGuideConfig = {
  [featureDef.achievement] = {},
  [featureDef.corps] = {},
  [featureDef.socialIsland] = {},
  [featureDef.teamLobby] = {},
  [featureDef.teamCompetitionMode] = {},
  [featureDef.matchMode] = {},
  [featureDef.season] = {},
  [featureDef.workshop] = {},
  [featureDef.pveMode] = {},
  [featureDef.workshopPet] = {},
  [featureDef.mentor] = {},
  [featureDef.entertainMode] = {},
  [featureDef.workshopGunDiy] = {}
}
LobbyUnlockConfig.SLevelUnLockSystem = {
  SystemID = 0,
  SystemName = 0,
  IconPath = "",
  CheckFunction = nil,
  guideList = {}
}
LobbyUnlockConfig.SLevelUnLockAnim = {
  SystemID = 0,
  LobbyType = ELobbyType.Lobby,
  AnimTargetUIConfig = "",
  AnimTargetWidget = "",
  AnimTargetOffset = ""
}
LobbyUnlockConfig.SLevelUnLockGuide = {
  SystemID = 0,
  LobbyType = ELobbyType.Lobby,
  Step = 0,
  TargetUIConfig = "",
  TargetWidget = "",
  GetWidgetFunction = "",
  TargetRedPointWidget = "",
  NewSignWidget = "",
  DynamicVisibleWidget = "",
  Style = tipStyle.line,
  TipID = 0,
  TipDirection = ETipDir.right,
  HandEffect = false,
  FlashEffect = false,
  ShowFoldButtonNewSign = false,
  Interruptible = true,
  EntranceDisplayType = ELockType.normal,
  CallbackFunction = nil,
  UIQueueParam = nil
}
function LobbyUnlockConfig.InitUnlockGuideConfig()
  local systemList = {}
  local systemConfig = CDataTable.GetTable("LevelUnLockSystemConfig")
  for k, v in pairs(systemConfig or {}) do
    local systemID = v.SystemID
    systemList[systemID] = {
      SystemName = v.SystemName,
      IconPath = v.IconPath,
      AnimTargetUIConfig = v.AnimTargetUIConfig,
      AnimTargetWidget = v.AnimTargetWidget,
      AnimTargetOffset = v.AnimTargetOffset,
      CheckFunction = v.CheckFunction
    }
  end
  local animConfig = CDataTable.GetTable("LevelUnLockAnimConfig")
  for k, v in pairs(animConfig or {}) do
    local systemID = v.SystemID
    local system = systemList[systemID]
    if system then
      if not system.animList then
        system.animList = {}
      end
      system.animList[v.LobbyType] = {
        SystemID = systemID,
        LobbyType = v.LobbyType,
        AnimTargetUIConfig = v.AnimTargetUIConfig,
        AnimTargetWidget = v.AnimTargetWidget,
        AnimTargetOffset = v.AnimTargetOffset
      }
    end
  end
  local guideConfig = CDataTable.GetTable("LevelUnLockGuideConfig")
  for k, v in pairs(guideConfig or {}) do
    local systemID = v.SystemID
    local system = systemList[systemID]
    if system then
      if not system.guideList then
        system.guideList = {}
      end
      local lobbyType = v.LobbyType
      if not system.guideList[lobbyType] then
        system.guideList[lobbyType] = {}
      end
      system.guideList[lobbyType][v.Step] = {
        TargetUIConfig = v.TargetUIConfig,
        TargetWidget = v.TargetWidget,
        GetWidgetFunction = v.GetWidgetFunction,
        TargetRedPointWidget = v.TargetRedPointWidget,
        NewSignWidget = v.NewSignWidget,
        DynamicVisibleWidget = v.DynamicVisibleWidget,
        Style = v.Style,
        TipID = v.TipID,
        TipDirection = v.TipDirection,
        HandEffect = v.HandEffect,
        FlashEffect = v.FlashEffect,
        ShowFoldButtonNewSign = v.ShowFoldButtonNewSign,
        Interruptible = v.Interruptible,
        EntranceDisplayType = v.EntranceDisplayType,
        CallbackFunction = v.CallbackFunction,
        UIQueueParam = v.UIQueueParam
      }
    end
  end
  log_tree("LobbyUnlockConfig.InitUnlockGuideConfig systemList = ", systemList)
  return systemList
end
LobbyUnlockConfig.return LobbyUnlockConfig