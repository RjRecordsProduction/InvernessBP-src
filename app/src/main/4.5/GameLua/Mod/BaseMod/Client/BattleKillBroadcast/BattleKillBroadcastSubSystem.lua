local BattleKillBroadcastSubSystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function BattleKillBroadcastSubSystem:OnInit()
  printf("[BattleKillBroadcastSubSystem]OnInit")
  self.LoadedEffectPath = {}
  self.LoadDel = {}
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_DISPLAY_KILL_MESSAGE, self.HandleDisplayKillOrPutDownMessage, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_WEAPON_1, self.OnWeaponChanged, self)
end
function BattleKillBroadcastSubSystem:OnRelease()
  printf("[BattleKillBroadcastSubSystem]OnRelease")
  local Util = require("client.slua_ui_framework.util")
  if self.LoadDel then
    for _, Del in pairs(self.LoadDel) do
      Util.ClearAssetAsync(Del)
    end
  end
  BattleKillBroadcastSubSystem.__super.OnRelease(self)
end
function BattleKillBroadcastSubSystem:IsInBattleResultProcess()
  local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
  if not BattleResultSubSystem then
    return false
  end
  return not BattleResultSubSystem.ResultProcessSuspended and BattleResultSubSystem:InResultProcess()
end
function BattleKillBroadcastSubSystem:HandleDisplayKillOrPutDownMessage()
  printf("[BattleKillBroadcastSubSystem]HandleDisplayKillOrPutDownMessage")
  if self:IsInBattleResultProcess() then
    printf(bWriteLog and "[BattleKillBroadcastSubSystem]HandleDisplayKillOrPutDownMessage IsInBattleResultProcess is true")
    return
  end
  local UIUtil = require("client.common.ui_util")
  local WorldContextObject = UIUtil.GetGameInstance()
  local UGameplayStatics = import("GameplayStatics")
  local uPlayerController = UGameplayStatics.GetPlayerController(WorldContextObject, 0)
  local messageData
  if uPlayerController and slua.isValid(uPlayerController) then
    messageData = self:CopyKillOrPutDownMessageDataUserDataToLuaTable(slua.IndexReference(uPlayerController, "KillOrPutDownMessageData"))
  else
    printf("[BattleKillBroadcastSubSystem]HandleDisplayKillOrPutDownMessage uPlayerController is nil")
  end
  if messageData == nil then
    printf("[BattleKillBroadcastSubSystem]HandleDisplayKillOrPutDownMessage messageData is nil")
    return
  end
  local CanDisplayMsg = true
  CanDisplayMsg, messageData = self:OnDisplayKillOrPutDownMessageProcessing(messageData)
  if CanDisplayMsg == false then
    printf("[BattleKillBroadcastSubSystem]HandleDisplayKillOrPutDownMessage CanDisplayMsg is false")
    return
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    local GameModeType = uGameState.GameModeType
    local EGameModeType = import("EGameModeType")
    if GameModeType and (GameModeType == EGameModeType.EDeathMatchGameMode or GameModeType == EGameModeType.EVehicleWar_CAMP) then
      messageData.bHideKillIcon = true
    end
  end
  if not messageData.bIamCauser or messageData.bIsCauserTeammate or messageData.bIamVictim then
    messageData.bHideKillIcon = true
  end
  self:OnDisplayKillOrPutDownMessage(messageData)
end
function BattleKillBroadcastSubSystem:OnDisplayKillOrPutDownMessageProcessing(messageData)
  local CanDisplayMsg = true
  printf("CauserName :" .. tostring(messageData.CauserRealPlayerName))
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  if IngameEntry.CurrentModeLogic and IngameEntry.CurrentModeLogic.OnDisplayKillOrPutDownMessageProcessing then
    CanDisplayMsg = IngameEntry.CurrentModeLogic:OnDisplayKillOrPutDownMessageProcessing(messageData)
  end
  printf("[BattleKillBroadcastSubSystem]OnDisplayKillOrPutDownMessageProcessing CanDisplayMsg:" .. tostring(CanDisplayMsg))
  return CanDisplayMsg, messageData
end
function BattleKillBroadcastSubSystem:CopyKillOrPutDownMessageDataUserDataToLuaTable(messageData)
  local msgData = {
    MsgType = messageData.MsgType,
    AttackActionName = messageData.AttackActionName,
    AttackName = messageData.AttackName,
    bIsHeadShot = messageData.bIsHeadShot,
    KillNum = messageData.KillNum,
    bShowKillNum = messageData.bShowKillNum,
    bHideKillIcon = messageData.bHideKillIcon,
    FullMsg = messageData.FullMsg,
    VictimPlayerName = messageData.VictimPlayerName,
    CauserPlayerName = messageData.CauserPlayerName,
    CauserRealPlayerName = messageData.CauserRealPlayerName,
    bIsCauserTeammate = messageData.bIsCauserTeammate,
    bIsVictimTeammate = messageData.bIsVictimTeammate,
    bIamCauser = messageData.bIamCauser,
    bIamVictim = messageData.bIamVictim,
    ResultHealthStatus = messageData.ResultHealthStatus,
    CauserType = messageData.CauserType,
    VictimType = messageData.VictimType,
    DamageType = messageData.DamageType,
    AdditionalParam = messageData.AdditionalParam,
    PreviousHealthStatus = messageData.PreviousHealthStatus,
    ExpandDataContent = messageData.ExpandDataContent,
    AssistNum = messageData.AssistNum
  }
  msgData.bNotShowIndex = false
  msgData.bShowBottomBothSidesKillInfo = true
  return msgData
end
function BattleKillBroadcastSubSystem:OnDisplayKillOrPutDownMessage(messageData)
  IngameTipsTools.BattleBottomKillTips(messageData)
end
function BattleKillBroadcastSubSystem:OnWeaponChanged(_, _, bpComp, DefineID)
  if not slua.isValid(bpComp) then
    return
  end
  local passive_resource_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.passive_resource_downloader)
  local BackpackUtils = import("BackpackUtils")
  local WeaponInfos = BackpackUtils.GetWeaponsInBackpack(bpComp)
  for key, value in pairs(WeaponInfos) do
    if slua.isValid(value) then
      local WeaponDefineID = value.DefineID
      local WeaponTypeSpecificID = WeaponDefineID.TypeSpecificID
      if not self.LoadedEffectPath[WeaponTypeSpecificID] then
        self.LoadedEffectPath[WeaponTypeSpecificID] = true
        local AdditionalData = value.AdditionalData
        for _, AddID in pairs(AdditionalData) do
          local TableData = CDataTable.GetTableData("WeaponAvatarBattleEffect", AddID.IntData)
          local EffectString = ""
          if TableData and TableData.EffectPath ~= "" and passive_resource_downloader:CheckResourceHasBeenDownloaded({
            TableData.EffectPath
          }) then
            EffectString = TableData.EffectPath
          end
          if EffectString ~= "" and not self.LoadDel[EffectString] then
            do
              local Util = require("client.slua_ui_framework.util")
              print(bWriteLog and "BattleKillBroadcastSubSystem:OnWeaponChanged LoadDel " .. EffectString)
              self.LoadDel[EffectString] = Util.GetAssetAsync(EffectString, function()
                self.LoadDel[EffectString] = nil
                print(bWriteLog and "BattleKillBroadcastSubSystem:OnWeaponChanged LoadDel End" .. EffectString)
              end)
            end
          end
        end
      end
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, BattleKillBroadcastSubSystem)