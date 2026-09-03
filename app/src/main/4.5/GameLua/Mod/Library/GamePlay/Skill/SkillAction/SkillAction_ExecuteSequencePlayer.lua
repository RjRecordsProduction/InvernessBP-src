local SkillAction_ExecuteSequencePlayer = {
  sObjectName = "SkillAction_ExecuteSequencePlayer",
  PlanIDBlackboardKey = "ExecutePlanID",
  TargetBlackboardKey = "ExecuteTarget",
  BIZ_ACTOR_BP_PATH = "/Game/BluePrints/Execute/BP_ExecuteSeqLuaActor.BP_ExecuteSeqLuaActor_C",
  SPAWN_OFFSET_Z = 10000,
  FIXED_SPAWN_ROTATION = {
    Pitch = 0,
    Yaw = 0,
    Roll = 0
  }
}
function SkillAction_ExecuteSequencePlayer:ctor(selfType)
  self.BizActor = nil
  self.bIsLocalMainControl = false
end
function SkillAction_ExecuteSequencePlayer:LuaRealDoAction()
  if not Client then
    return false
  end
  local uOwnerPawn = self:GetOwnerPawn()
  local uCurSkill = self:GetOwnerSkill()
  local uSkillManager = self:GetOwnerSkillManager()
  if not (slua.isValid(uOwnerPawn) and slua.isValid(uCurSkill)) or not slua.isValid(uSkillManager) then
    print(bWriteLog and "SkillAction_ExecuteSequencePlayer:LuaRealDoAction invalid Owner/Skill/SkillMgr")
    return false
  end
  local PlanID = uSkillManager:GetValueAsInt(uCurSkill.SkillID, self.PlanIDBlackboardKey)
  if not PlanID or PlanID <= 0 then
    print(bWriteLog and string.format("SkillAction_ExecuteSequencePlayer:LuaRealDoAction invalid PlanID=%s, skip", tostring(PlanID)))
    return false
  end
  local SeqPath = self:QuerySequencePath(PlanID)
  if not SeqPath or SeqPath == "" then
    print(bWriteLog and string.format("SkillAction_ExecuteSequencePlayer:LuaRealDoAction PlanID=%d no SequencePath, fallback to Montage", PlanID))
    return false
  end
  if not self:_IsSeqResourceReady(SeqPath) then
    print(bWriteLog and string.format("SkillAction_ExecuteSequencePlayer:LuaRealDoAction PlanID=%d SeqPath not downloaded, fallback to Montage path=%s", PlanID, SeqPath))
    return false
  end
  local uTarget = uSkillManager:GetValueAsWeakObject(uCurSkill.SkillID, self.TargetBlackboardKey)
  if not slua.isValid(uTarget) then
    print(bWriteLog and "SkillAction_ExecuteSequencePlayer:LuaRealDoAction ExecuteTarget invalid")
    return false
  end
  local bIsExecutor = uOwnerPawn.IsLocalControlOrView and uOwnerPawn:IsLocalControlOrView()
  local bIsTarget = uTarget.IsLocalControlOrView and uTarget:IsLocalControlOrView()
  if not bIsExecutor and not bIsTarget then
    print(bWriteLog and string.format("SkillAction_ExecuteSequencePlayer:LuaRealDoAction third-party client, skip Sequence (PlanID=%d)", PlanID))
    return false
  end
  local BizActorClass = import(self.BIZ_ACTOR_BP_PATH)
  if not BizActorClass then
    print(bWriteLog and string.format("SkillAction_ExecuteSequencePlayer:LuaRealDoAction import BizActor class failed: %s", self.BIZ_ACTOR_BP_PATH))
    return false
  end
  local OwnerLoc = uOwnerPawn:K2_GetActorLocation()
  local SpawnLoc = FVector(OwnerLoc.X, OwnerLoc.Y, OwnerLoc.Z + self.SPAWN_OFFSET_Z)
  local SpawnRot = FRotator(self.FIXED_SPAWN_ROTATION.Pitch, self.FIXED_SPAWN_ROTATION.Yaw, self.FIXED_SPAWN_ROTATION.Roll)
  local UKismetMathLibrary = import("KismetMathLibrary")
  local SpawnTransform = UKismetMathLibrary.MakeTransform(SpawnLoc, SpawnRot, FVector(1, 1, 1))
  local UGameplayStatics = import("GameplayStatics")
  local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
  local BizActor = UGameplayStatics.BeginDeferredActorSpawnFromClass(uOwnerPawn, BizActorClass, SpawnTransform, ESpawnActorCollisionHandlingMethod.AlwaysSpawn, uOwnerPawn)
  if not slua.isValid(BizActor) then
    print(bWriteLog and "SkillAction_ExecuteSequencePlayer:LuaRealDoAction Spawn BizActor failed")
    return false
  end
  BizActor:SetReplicates(false)
  UGameplayStatics.FinishSpawningActor(BizActor, SpawnTransform)
  if not slua.isValid(BizActor) or not BizActor.StartExecutePlay then
    print(bWriteLog and "SkillAction_ExecuteSequencePlayer:LuaRealDoAction BizActor StartExecutePlay missing")
    return false
  end
  BizActor:StartExecutePlay(uOwnerPawn, uTarget, SeqPath, PlanID)
  self.  self:_HideIngameMainUI()
  local bIsLocalMainControl = uOwnerPawn.IsLocallyControlled and uOwnerPawn:IsLocallyControlled()
  if bIsLocalMainControl then
    self.bIsLocalMainControl = true
    self:_ShowExitUI(uSkillManager, uCurSkill.SkillID)
  end
  print(bWriteLog and string.format("SkillAction_ExecuteSequencePlayer:LuaRealDoAction OK SkillID=%d PlanID=%d SeqPath=%s bIsExecutor=%s bIsLocalMainControl=%s", uCurSkill.SkillID, PlanID, SeqPath, tostring(bIsExecutor), tostring(bIsLocalMainControl)))
  return true
end
function SkillAction_ExecuteSequencePlayer:LuaUndoAction()
  if not Client then
    SkillAction_ExecuteSequencePlayer.__super.LuaUndoAction(self)
    return
  end
  print(bWriteLog and string.format("SkillAction_ExecuteSequencePlayer:LuaUndoAction BizActor valid=%s bIsLocalMainControl=%s", tostring(slua.isValid(self.BizActor)), tostring(self.bIsLocalMainControl)))
  self:_ShowIngameMainUI()
  if self.bIsLocalMainControl then
    self:_CloseExitUI()
    self.bIsLocalMainControl = false
  end
  if slua.isValid(self.BizActor) then
    if self.BizActor.StopExecutePlay then
      self.BizActor:StopExecutePlay()
    else
      self.BizActor:K2_DestroyActor()
    end
    self.BizActor = nil
  end
  SkillAction_ExecuteSequencePlayer.__super.LuaUndoAction(self)
end
function SkillAction_ExecuteSequencePlayer:QuerySequencePath(PlanID)
  if not PlanID or PlanID <= 0 then
    return nil
  end
  local Cfg = CDataTable.GetTableData("ExecuteSkinTable", PlanID)
  if not Cfg then
    print(bWriteLog and string.format("SkillAction_ExecuteSequencePlayer:QuerySequencePath PlanID=%d not in ExecuteSkinTable", PlanID))
    return nil
  end
  local PathStr = Cfg.SeqPath
  if not PathStr or PathStr == "" then
    return nil
  end
  return PathStr
end
function SkillAction_ExecuteSequencePlayer:_ShowExitUI(uSkillManager, SkillID)
  if UIManager and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.Exit_Execute_UIBP then
    UIManager.ShowUI(UIManager.UI_Config_InGame.Exit_Execute_UIBP, uSkillManager, SkillID)
  else
    print(bWriteLog and "SkillAction_ExecuteSequencePlayer:_ShowExitUI Exit_Execute_UIBP config not found")
  end
end
function SkillAction_ExecuteSequencePlayer:_CloseExitUI()
  if UIManager and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.Exit_Execute_UIBP then
    UIManager.CloseUI(UIManager.UI_Config_InGame.Exit_Execute_UIBP)
  end
end
function SkillAction_ExecuteSequencePlayer:_HideIngameMainUI()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.BroadcastUIMessage then
    PlayerController:BroadcastUIMessage("UIMsg_HideIngameMainUI", 0, "", "")
  end
end
function SkillAction_ExecuteSequencePlayer:_ShowIngameMainUI()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.BroadcastUIMessage then
    PlayerController:BroadcastUIMessage("UIMsg_ShowIngameMainUI", 0, "", "")
  end
end
function SkillAction_ExecuteSequencePlayer:_IsSeqResourceReady(SeqPath)
  if not SeqPath or SeqPath == "" then
    return false
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  return PufferManager.GetListIsDownloaded(PufferConst.ENUM_DownloadType.ODPAK, {SeqPath})
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
return class(CSkillNodeBase, nil, SkillAction_ExecuteSequencePlayer)