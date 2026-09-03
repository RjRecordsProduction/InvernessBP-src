local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESlateVisibility = import("ESlateVisibility")
local KismetTextLibrary = import("KismetTextLibrary")
local ERoundingMode = import("ERoundingMode")
local UAESkillManagerUtils = import("UAESkillManagerUtils")
local EPawnState = import("EPawnState")
local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
local CDBarUISubSystem = {}
function CDBarUISubSystem:ctor()
  self.CurPromptID = -1
  self.CDBarStack = {}
  self.CurrentThrowActor = nil
  self.SpecialPromptIDConfig = {
    RescueOther = 1000001,
    BeingRescue = 1000002,
    BeingCaptived = 1000003
  }
end
function CDBarUISubSystem:OnInit()
  print(bWriteLog and "CDBarUISubSystem:OnInit")
  self:RegistEvents()
end
function CDBarUISubSystem:RegistEvents()
  print(bWriteLog and "CDBarUISubSystem:RegistEvents")
  self:_ForceHideAll()
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_STOP_WONDERFULPLAYBACK, function()
    self:_ForceHideAll()
  end)
  self:AddCommonEventWithConditions(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_START_PHASE, {
    [1] = "BattleResultShowAvatarLogic"
  }, function()
    self:_ForceHideAll()
  end)
  self:AddUIMessageEvent("HandleAndroidBack", self.HandleAndroidBack, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_CDBAR, self.OnShowCDBar, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_CDBAR, self.OnHideCDBar, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.OnBattleResultEnterProtect, self)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    self:AddControlEvent(PlayerController, "OnSetViewTarget", self.HandleOnSetViewTarget, self)
  end
end
function CDBarUISubSystem:HandleOnSetViewTarget(NewViewTarget)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local CurViewTarget = PlayerController:GetViewTarget()
  print(bWriteLog and "CDBarUISubSystem:HandleOnSetViewTarget - NewViewTarget: " .. tostring(NewViewTarget) .. ", CurViewTarget: " .. tostring(CurViewTarget))
  local bNeedHideSkillPrompt = not slua.isValid(NewViewTarget) or CurViewTarget ~= NewViewTarget
  if bNeedHideSkillPrompt then
    if slua.isValid(NewViewTarget) and Game:IsClassOf(NewViewTarget, ASTExtraBaseCharacter) then
      if slua.isValid(CurViewTarget) and NewViewTarget.GetCurrentVehicle and NewViewTarget:GetCurrentVehicle() == CurViewTarget then
        print(bWriteLog and "CDBarUISubSystem:HandleOnSetViewTarget - bNeedHideSkillPrompt set false, vehicle to character")
        bNeedHideSkillPrompt = false
      elseif slua.isValid(CurViewTarget) and CurViewTarget.ActorHasTag and CurViewTarget:ActorHasTag("SequencerActor") then
        print(bWriteLog and "CDBarUISubSystem:HandleOnSetViewTarget - bNeedHideSkillPrompt set false, SequencerActor")
        bNeedHideSkillPrompt = false
      end
    elseif slua.isValid(CurViewTarget) and Game:IsClassOf(CurViewTarget, ASTExtraBaseCharacter) then
      if slua.isValid(NewViewTarget) and CurViewTarget.GetCurrentVehicle and CurViewTarget:GetCurrentVehicle() == NewViewTarget then
        print(bWriteLog and "CDBarUISubSystem:HandleOnSetViewTarget - bNeedHideSkillPrompt set false, character to vehicle")
        bNeedHideSkillPrompt = false
      elseif slua.isValid(NewViewTarget) and NewViewTarget.ActorHasTag and NewViewTarget:ActorHasTag("SequencerActor") then
        print(bWriteLog and "CDBarUISubSystem:HandleOnSetViewTarget - bNeedHideSkillPrompt set false, SequencerActor")
        bNeedHideSkillPrompt = false
      end
    end
  end
  if bNeedHideSkillPrompt then
    print(bWriteLog and "CDBarUISubSystem:HandleOnSetViewTarget - hide skill CDBar")
    local SkillPromptParams = {
      PromptID = -1,
      bForce = true,
      PromptReason = UEnums.EShowSkillPromptReason.Hide_SetViewTarget,
      PastTime = 0
    }
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_HIDE_CDBAR, UEnums.CDBarType.Skill, SkillPromptParams)
    self:_ForceHideAll()
  end
end
function CDBarUISubSystem:HandleAndroidBack()
  print(bWriteLog and "CDBarUISubSystem:HandleAndroidBack 0")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  print(bWriteLog and "CDBarUISubSystem:HandleAndroidBack 1")
  local UTSkillStopReason = import("UTSkillStopReason")
  local uSkillManager = PlayerCharacter.SkillManager
  if slua.isValid(uSkillManager) then
    local CastingSkillIDs = uSkillManager:GetCastingSkillIDs()
    for i, CastingSkillID in CastingSkillIDs:Pairs() do
      if CastingSkillID ~= nil and CastingSkillID ~= 4401003 and CastingSkillID ~= 4401006 then
        print(bWriteLog and string.format("CDBarUISubSystem:HandleAndroidBack - StopSkill %d", CastingSkillID))
        uSkillManager:StopSkill(CastingSkillID, UTSkillStopReason.SkillStopReason_Interrupted)
      end
    end
  end
  PlayerCharacter:UserCancelRescue()
  PlayerCharacter:OnInterruptChangeWearing()
end
function CDBarUISubSystem:OnBattleResultEnterProtect()
  print(bWriteLog and "CDBarUISubSystem:OnEnterBattleResult")
  self.EnterBattleResult = true
end
function CDBarUISubSystem:OnShowCDBar(_, _, cdBarType, params)
  if cdBarType == UEnums.CDBarType.RescueOther or cdBarType == UEnums.CDBarType.BeingRescue or cdBarType == UEnums.CDBarType.BeingCaptived then
    self:_PushTask(cdBarType, params)
  elseif cdBarType == UEnums.CDBarType.ThrowItem then
    self:OnShowThrowTimeInfoPanel(params)
  elseif cdBarType == UEnums.CDBarType.Skill then
    self:_PushTask(cdBarType, params)
  end
end
function CDBarUISubSystem:OnHideCDBar(_, _, cdBarType, params)
  if cdBarType == UEnums.CDBarType.RescueOther or cdBarType == UEnums.CDBarType.BeingRescue or cdBarType == UEnums.CDBarType.BeingCaptived then
    local bForce = params and params.bForce or false
    self:_RemoveTask(cdBarType, params, bForce)
  elseif cdBarType == UEnums.CDBarType.ThrowItem then
    self:OnHideThrowTimeInfoPanel(params)
  elseif cdBarType == UEnums.CDBarType.Skill then
    local bForce = params and params.bForce or false
    self:_RemoveTask(cdBarType, params, bForce)
  end
end
function CDBarUISubSystem:_ForceHideAll()
  print(bWriteLog and "CDBarUISubSystem:_ForceHideAll")
  self.CDBarStack = {}
  self.CurPromptID = -1
  if UIManager.UI_Config_InGame.CDBarUIPanel then
    UIManager.HideUI(UIManager.UI_Config_InGame.CDBarUIPanel)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CDBAR_STATE_CHANGE, false)
end
function CDBarUISubSystem:_PushTask(cdBarType, params)
  local promptID = self:_GetPromptID(cdBarType, params)
  local now = slua.getMiliseconds() / 1000.0
  for i, task in ipairs(self.CDBarStack) do
    if task.promptID == promptID then
      self.CDBarStack[i] = {
        promptID = promptID,
        cdBarType = cdBarType,
        params = params,
        enqueueTime = now
      }
      print(bWriteLog and string.format("CDBarUISubSystem:_PushTask - replace existing task promptID=%d", promptID))
      if i == #self.CDBarStack then
        self:_RefreshDisplay()
      end
      return
    end
  end
  table.insert(self.CDBarStack, {
    promptID = promptID,
    cdBarType = cdBarType,
    params = params,
    enqueueTime = now
  })
  print(bWriteLog and string.format("CDBarUISubSystem:_PushTask - push new task promptID=%d stackSize=%d", promptID, #self.CDBarStack))
  self:_RefreshDisplay()
end
function CDBarUISubSystem:_RemoveTask(cdBarType, params, bForce)
  if bForce then
    self:_ForceHideAll()
    return
  end
  if cdBarType == UEnums.CDBarType.Skill then
    local PlayerController = GameplayData.GetPlayerController()
    local PlayerCharacter = PlayerController and PlayerController:GetCurPlayerCharacter() or nil
    if slua.isValid(PlayerCharacter) and PlayerCharacter:HasState(EPawnState.Save) and PlayerController:IsSpectator() then
      print(bWriteLog and string.format("CDBarUISubSystem:_RemoveTask - skip, character HasState Save, promptID=%d", self:_GetPromptID(cdBarType, params)))
      return
    end
  end
  local promptID = self:_GetPromptID(cdBarType, params)
  local wasTop = #self.CDBarStack > 0 and self.CDBarStack[#self.CDBarStack].promptID == promptID
  for i = #self.CDBarStack, 1, -1 do
    if self.CDBarStack[i].promptID == promptID then
      table.remove(self.CDBarStack, i)
      print(bWriteLog and string.format("CDBarUISubSystem:_RemoveTask - removed promptID=%d wasTop=%s stackSize=%d", promptID, tostring(wasTop), #self.CDBarStack))
      break
    end
  end
  if wasTop then
    if #self.CDBarStack > 0 then
      self:_RefreshDisplay()
    else
      self.CurPromptID = -1
      UIManager.HideUI(UIManager.UI_Config_InGame.CDBarUIPanel)
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CDBAR_STATE_CHANGE, false)
    end
  end
end
function CDBarUISubSystem:_RefreshDisplay()
  if #self.CDBarStack == 0 then
    return
  end
  local topTask = self.CDBarStack[#self.CDBarStack]
  self.CurPromptID = topTask.promptID
  print(bWriteLog and string.format("CDBarUISubSystem:_RefreshDisplay - show promptID=%d cdBarType=%d", topTask.promptID, topTask.cdBarType))
  if topTask.cdBarType == UEnums.CDBarType.Skill then
    local now = slua.getMiliseconds() / 1000.0
    local elapsed = now - topTask.enqueueTime
    local resumeParams = topTask.params
    if 0 < elapsed and resumeParams then
      resumeParams = {}
      for k, v in pairs(topTask.params) do
        resumeParams[k] = v
      end
      resumeParams.PastTime = (topTask.params.PastTime or 0) + elapsed
    end
    local bSuccess = self:OnShowSkillPrompt(resumeParams)
    if not bSuccess then
      print(bWriteLog and string.format("CDBarUISubSystem:_RefreshDisplay - skill display failed, remove stuck task promptID=%d", topTask.promptID))
      table.remove(self.CDBarStack, #self.CDBarStack)
      self.CurPromptID = -1
      if #self.CDBarStack > 0 then
        self:_RefreshDisplay()
      else
        UIManager.HideUI(UIManager.UI_Config_InGame.CDBarUIPanel)
        EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CDBAR_STATE_CHANGE, false)
      end
    end
  elseif topTask.cdBarType == UEnums.CDBarType.RescueOther or topTask.cdBarType == UEnums.CDBarType.BeingRescue or topTask.cdBarType == UEnums.CDBarType.BeingCaptived then
    local now = slua.getMiliseconds() / 1000.0
    local elapsed = now - topTask.enqueueTime
    self:OnShowRescueOrCaptived(topTask.cdBarType, topTask.params, elapsed)
  end
end
function CDBarUISubSystem:_GetPromptID(cdBarType, params)
  if cdBarType == UEnums.CDBarType.Skill then
    return params and params.PromptID or 0
  elseif cdBarType == UEnums.CDBarType.RescueOther then
    return self.SpecialPromptIDConfig.RescueOther
  elseif cdBarType == UEnums.CDBarType.BeingRescue then
    return self.SpecialPromptIDConfig.BeingRescue
  elseif cdBarType == UEnums.CDBarType.BeingCaptived then
    return self.SpecialPromptIDConfig.BeingCaptived
  end
  return 0
end
function CDBarUISubSystem:_GetTopTask()
  if #self.CDBarStack > 0 then
    return self.CDBarStack[#self.CDBarStack]
  end
  return nil
end
function CDBarUISubSystem:OnShowSkillPrompt(params)
  print(bWriteLog and "CDBarUISubSystem:OnShowSkillPrompt Start")
  if self.EnterBattleResult or not params then
    return false
  end
  local PromptID = params and params.PromptID or 0
  local PastTime = params and params.PastTime or 0
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return false
  end
  local CurCharacter = PlayerController:GetCurPlayerCharacter()
  if not slua.isValid(CurCharacter) or not slua.isValid(CurCharacter.SkillManager) then
    return false
  end
  local PromptConfig
  if params.PromptConfig and 0 < params.PromptConfig.PromptDuration_f then
    PromptConfig = params.PromptConfig
  elseif 0 <= PromptID then
    PromptConfig = CDataTable.GetTableData("PromptConfigTable", PromptID)
  end
  print(bWriteLog and string.format("CDBarUISubSystem:OnShowSkillPrompt PlayerKey:%d PromptID:%d", CurCharacter.PlayerKey, PromptID))
  local RelatedSkill = CurCharacter.SkillManager:GetSkill(PromptID)
  local bHasRelatedSkill = slua.isValid(RelatedSkill)
  if PromptConfig == nil and bHasRelatedSkill and RelatedSkill.GetPromtConfig then
    PromptConfig = RelatedSkill:GetPromtConfig(PromptID)
  end
  local PromptIconPath = PromptConfig and PromptConfig.Icon ~= "" and PromptConfig.Icon or "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_CD_icon_default_png.ZD_CD_icon_default_png"
  local Duration = PromptConfig and PromptConfig.PromptDuration_f or 0
  if bHasRelatedSkill and RelatedSkill.GetPromtDurationDynamically then
    local TempDuration = RelatedSkill:GetPromtDurationDynamically(PromptID)
    if 0 < TempDuration then
      Duration = TempDuration
      print(bWriteLog and string.format("SkillPromptBP:OnShowSkillPrompt Dynamically Assigned Prompt Duration:%f", Duration))
    end
  end
  local AdditionalData
  if CurCharacter.GetCurrentInteractiveComponent then
    local uInteractiveComponent = CurCharacter:GetCurrentInteractiveComponent(PromptID, false)
    if slua.isValid(uInteractiveComponent) and uInteractiveComponent.bResetSkillData and uInteractiveComponent.SkillId == PromptID then
      if uInteractiveComponent.LoadingIcon.AssetPathName ~= "None" then
        PromptIconPath = uInteractiveComponent.LoadingIcon.AssetPathName
      end
      Duration = uInteractiveComponent.LoadingDuration
      local owner = uInteractiveComponent:GetOwner()
      if owner and slua.isValid(owner) and owner.GetCDAddtionalData then
        AdditionalData = owner:GetCDAddtionalData()
      end
    end
  end
  local DurationScale = bHasRelatedSkill and RelatedSkill:GetSkillDurationScale(CurCharacter.SkillManager) or 1
  if PromptConfig and PromptConfig.TimeAdjustAttr ~= "" then
    local uAttrModifyComp = CurCharacter:GetAttrModifyComponent()
    if slua.isValid(uAttrModifyComp) then
      DurationScale = DurationScale * (1 + uAttrModifyComp:GetAttributeValue(PromptConfig.TimeAdjustAttr))
    end
  end
  local FinalDuration = Duration * DurationScale
  if FinalDuration <= 0 then
    print(bWriteLog and string.format("CDBarUISubSystem:OnShowSkillPrompt Invalid FinalDuration :%d", PromptID))
    return false
  end
  self.Cur  local GameplayStatics = import("GameplayStatics")
  local CurrentTime = slua.getMiliseconds() / 1000.0
  local CDBarUIPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.CDBarUIPanel)
  if CDBarUIPanel then
    local bNeedRefresh = true
    if CDBarUIPanel.CheckNeedSkillRefresh then
      bNeedRefresh = CDBarUIPanel:CheckNeedSkillRefresh(RelatedSkill)
    end
    if bNeedRefresh ~= false then
      CDBarUIPanel:SetTimeInfo(PromptIconPath, FinalDuration, CurrentTime - PastTime, AdditionalData, PromptID, RelatedSkill)
      if PromptConfig and not PromptConfig.bCanCancelSkill then
        CDBarUIPanel.UIRoot.CanvasPanel_CancelUse:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CDBAR_STATE_CHANGE, true, AdditionalData)
  return true
end
function CDBarUISubSystem:OnHideSkillPrompt(params)
  local bForce = params and params.bForce or true
  local PromptID = params and params.PromptID or -1
  print(bWriteLog and string.format("CDBarUISubSystem:OnHideSkillPrompt %s", bForce))
  if not bForce and PromptID ~= self.CurPromptID then
    print(bWriteLog and string.format("CDBarUISubSystem:OnHideSkillPrompt Try Hide Other Prompt Inst, Current:%d, Try To Hide:%d", self.CurPromptID, PromptID))
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and not bForce and PlayerCharacter:HasState(EPawnState.Save) then
    print(bWriteLog and string.format("CDBarUISubSystem:OnHideSkillPrompt HasState Save"))
    return
  end
  self.CurPromptID = -1
  if UIManager.UI_Config_InGame.CDBarUIPanel then
    UIManager.HideUI(UIManager.UI_Config_InGame.CDBarUIPanel)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CDBAR_STATE_CHANGE, false)
end
function CDBarUISubSystem:OnShowRescueOrCaptived(cdBarType, params, elapsed)
  local configKeyMap = {
    [UEnums.CDBarType.RescueOther] = "RescueOther",
    [UEnums.CDBarType.BeingRescue] = "BeingRescue",
    [UEnums.CDBarType.BeingCaptived] = "BeingCaptived"
  }
  local configKey = configKeyMap[cdBarType]
  self.CurPromptID = self.SpecialPromptIDConfig[configKey]
  elapsed = elapsed or 0
  print(bWriteLog and string.format("CDBarUISubSystem:OnShowRescueOrCaptived type=%d elapsed=%.2f", cdBarType, elapsed))
  local CDBarUIPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.CDBarUIPanel)
  if CDBarUIPanel then
    CDBarUIPanel:SetRescueTimeInfo(cdBarType, self.CurPromptID, elapsed)
  end
end
function CDBarUISubSystem:OnHideRescueOrCaptived(cdBarType, params)
  print(bWriteLog and "CDBarUISubSystem:OnHideRescueOrCaptived", cdBarType)
  self.CurPromptID = -1
  UIManager.HideUI(UIManager.UI_Config_InGame.CDBarUIPanel)
end
function CDBarUISubSystem:OnShowThrowTimeInfoPanel(params)
  local GrenadeID = params and params.GrenadeID or nil
  local ThrowActor = params and params.ThrowActor or nil
  if GrenadeID and 0 < GrenadeID then
    local CountDownTime = UAESkillManagerUtils.GetGrenadeCountDownTime(GrenadeID)
    if CountDownTime and 0 < CountDownTime and ThrowActor and ThrowActor.EffectDelay and 0 < ThrowActor.EffectDelay then
      CountDownTime = ThrowActor.EffectDelay
    end
    if CountDownTime and 0 < CountDownTime then
      local ThrowTimeInfoPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.ThrowTimeInfoPanel)
      if ThrowTimeInfoPanel then
        self.Current        print(bWriteLog and "CDBarUISubSystem:OnShowThrowTimeInfoPanel CurGrenadeID=" .. GrenadeID .. " Time=" .. CountDownTime)
        local CountDownIcon = UAESkillManagerUtils.GetGrenadeCountDownIcon(GrenadeID)
        ThrowTimeInfoPanel:SetTimeInfo(CountDownIcon.IconPath, CountDownTime)
      end
      return
    end
  end
  self:OnHideThrowTimeInfoPanel(params)
end
function CDBarUISubSystem:OnHideThrowTimeInfoPanel(params)
  local GrenadeID = params and params.GrenadeID or nil
  local ThrowActor = params and params.ThrowActor or nil
  print(bWriteLog and "CDBarUISubSystem:OnHideThrowTimeInfoPanel CurGrenadeID=" .. tostring(GrenadeID))
  if UIManager.UI_Config_InGame.ThrowTimeInfoPanel == nil then
    return
  end
  if not slua.isValid(self.CurrentThrowActor) or self.CurrentThrowActor == ThrowActor then
    UIManager.HideUI(UIManager.UI_Config_InGame.ThrowTimeInfoPanel)
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, CDBarUISubSystem)