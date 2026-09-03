local AInteractiveActorBase = {}
function AInteractiveActorBase:ctor(selfType)
  self.hasAuthority = nil
  self.loadDelegates = {}
  self.ComponentArray = {}
  self.FirstComponent = nil
  self.UseNewUI = true
  self.NewUIParam = {}
  self.BtnImagePath = nil
  self.ShowBtnWhenCasting = nil
  self.HaveShowCDBar = false
  self.NewCDUIParam = nil
  self.nSoundID = 0
end
function AInteractiveActorBase:GetInteractiveComponent()
  if self:IsValid(self.FirstComponent) == false then
    self.ComponentArray = {}
    self.FirstComponent = nil
    if self.Object and slua.isValid(self.Object) then
      local componentClass = import("InteractiveComponentBase")
      local uTargetArray = self:GetComponentsByClass(componentClass)
      for i = 0, uTargetArray:Num() - 1 do
        local temp = uTargetArray:Get(i)
        if self:IsValid(temp) then
          table.insert(self.ComponentArray, temp)
          if self.FirstComponent == nil then
            self.FirstComponent = temp
          end
        end
      end
    end
  end
  return self.FirstComponent, self.ComponentArray
end
function AInteractiveActorBase:ReceiveBeginPlay()
  AInteractiveActorBase.__super.ReceiveBeginPlay(self)
  if self.Super.ReceiveBeginPlay then
    self.Super:ReceiveBeginPlay()
  end
  self:BeginPlayImpl(false)
end
function AInteractiveActorBase:_PostConstruct()
  AInteractiveActorBase.__super._PostConstruct(self)
end
function AInteractiveActorBase:OnBPRespawned()
  self:BeginPlayImpl(true)
end
function AInteractiveActorBase:BeginPlayImpl(bFromPool)
  self.hasAuthority = self:HasAuthority()
  local FirstComponent, ComponentArray = self:GetInteractiveComponent()
  if ComponentArray then
    for _, v in ipairs(ComponentArray) do
      if self.hasAuthority then
        self:AddControlEvent(v, "OnAllowToInteract", self.OnAllowToInteract, self)
        self:AddControlEvent(v, "OnAllowToClickButton", self.OnAllowToClickButton, self)
        self:AddControlEvent(v, "OnInteractionEffective", self.OnInteractionEffective, self)
        self:AddControlEvent(v, "OnServerSetOccupied", self.OnServerSetOccupied, self)
        self:AddControlEvent(v, "OnServerClickInteractiveButton", self.MustCheckResultAfterServerClick, self)
        self:AddControlEvent(v, "OnStartCoolDown", self.OnStartCoolDown, self)
        self:AddControlEvent(v, "OnServerAddOrDeleteComponent", self.OnServerAddOrDeleteComponent, self)
        if self.ReportICNotAllowedTLog then
          self:AddControlEvent(v, "OnAllowToInteractFailed", self.OnAllowToInteractFailed, self)
        end
        if self.ReportICOverlappingTLog then
          self:AddControlEvent(v, "OnHideUIWhenOverlapping", self.OnHideUIWhenOverlapping, self)
        end
      else
        self:AddControlEvent(v, "OnClientShowInteractiveUI", self.OnClientShowInteractiveUI, self)
        self:AddControlEvent(v, "OnRepOccupied", self.OnRepOccupied, self)
        self:AddControlEvent(v, "OnRepOccupyingNumChanged", self.OnRepOccupyingNumChanged, self)
        self:AddControlEvent(v, "OnRepCoolDown", self.OnRepCoolDown, self)
        self:AddControlEvent(v, "OnRepCurrentCharacter", self.OnRepCurrentCharacter, self)
        self:AddControlEvent(v, "OnRepCurrentCharacterArray", self.OnRepCurrentCharacterArray, self)
        self:AddControlEvent(v, "OnRepEnabled", self.OnRepEnabled, self)
      end
      self:AddControlEvent(v, "OnResetSkillAction", self.OnResetSkillAction, self)
      self:AddControlEvent(v, "OnStartedSkillAction", self.OnStartedSkillAction, self)
      self:AddControlEvent(v, "OnFinishedSkillAction", self.MustCheckResultAfterSkillFinished, self)
      self:AddControlEvent(v, "OnStoppedSkillAction", self.OnStoppedSkillAction, self)
    end
  end
  if FirstComponent and self.hasAuthority == false then
    self:ChangeMaterialByState(FirstComponent:IsEnabled(), FirstComponent)
    self:PlayAudioIfEnabled(FirstComponent:IsEnabled(), FirstComponent)
  end
end
function AInteractiveActorBase:OnAllowToInteractFailed(Character, Failed, Component)
  local ICTLogSubsystem = SubsystemMgr:Get("ICTLogSubsystem")
  if ICTLogSubsystem then
    ICTLogSubsystem:OnAllowToInteractFailed(Character, Failed, self.Object)
  end
end
function AInteractiveActorBase:OnHideUIWhenOverlapping(Character, HideUI, Component)
  local ICTLogSubsystem = SubsystemMgr:Get("ICTLogSubsystem")
  if ICTLogSubsystem then
    ICTLogSubsystem:OnHideUIWhenOverlapping(Character, HideUI, self.Object)
  end
end
function AInteractiveActorBase:OnServerAddOrDeleteComponent(Character, bAddOrDelete, Component)
end
function AInteractiveActorBase:OnAllowToInteract(character, Component)
  return true
end
function AInteractiveActorBase:OnAllowToClickButton(Character, Component)
  return self:OnAllowToInteract(Character, Component)
end
function AInteractiveActorBase:OnInteractionEffective(Character, Component)
  return self:OnAllowToClickButton(Character, Component)
end
function AInteractiveActorBase:OnClientShowInteractiveUI(show, component, Param)
  component = component or self:GetInteractiveComponent()
  if show then
    self:ShowUI(component, Param)
  else
    self:CloseUI(component, Param)
  end
end
function AInteractiveActorBase:ShowUI(component)
  component = component or self:GetInteractiveComponent()
  if type(component) == "table" then
    component = component.Object
  end
  if component == nil or slua.isValid(component) == false then
    return
  end
  if component.bEnabled == false then
    return
  end
  if self.UseNewUI then
    if self.NewUIParam[component] == nil then
      self.NewUIParam[component] = {
        IconPath = self.BtnImagePath or component.BtnImage.AssetPathName,
        TextID = component.TextId,
        Component = component,
        Params = component.Params,
        RPCParam = component.RPCParam,
        ShowBtnWhenCasting = self.ShowBtnWhenCasting
      }
    else
      self.NewUIParam[component].IconPath = self.BtnImagePath or component.BtnImage.AssetPathName
      self.NewUIParam[component].TextID = component.TextId
      self.NewUIParam[component].Params = component.Params
      self.NewUIParam[component].RPCParam = component.RPCParam
      self.NewUIParam[component].Component = component
      self.NewUIParam[component].ShowBtnWhenCasting = self.ShowBtnWhenCasting
    end
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    print(bWriteLog and string.format("AInteractiveActorBase:ShowUI, Name = %s(%s), Icon = %s, TextID = %d", tostring(UKismetSystemLibrary.GetObjectName(self.Object)), tostring(UKismetSystemLibrary.GetObjectName(component)), self.NewUIParam[component].IconPath, self.NewUIParam[component].TextID))
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN, "Type_InteractiveComponent", self.NewUIParam[component])
  else
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.InteractiveUI)
    if ui ~= nil then
      ui:Show(component, component.BtnImage, component.TextId, component.SkillId)
    else
      UIManager.ShowUI(UIManager.UI_Config_InGame.InteractiveUI, component, component.BtnImage, component.TextId, component.SkillId)
    end
  end
end
function AInteractiveActorBase:CloseUI(component)
  component = component or self:GetInteractiveComponent()
  if type(component) == "table" then
    component = component.Object
  end
  if component == nil or slua.isValid(component) == false then
    return
  end
  if self.UseNewUI then
    if self.NewUIParam[component] ~= nil then
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      print(bWriteLog and "AInteractiveActorBase:CloseUI, Name = " .. tostring(UKismetSystemLibrary.GetObjectName(self.Object)))
      EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_InteractiveComponent", self.NewUIParam[component])
    end
  elseif UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.InteractiveUI then
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.InteractiveUI)
    if ui then
      ui:Hide(component)
    end
  end
end
function AInteractiveActorBase:OnServerSetOccupied(character, occupied, component, Index)
  print(bWriteLog and "AInteractiveActorBase:OnServerSetOccupied, occupied = " .. tostring(occupied))
end
function AInteractiveActorBase:OnClientClickInteractiveButton(Character, Component)
  Component = Component or self:GetInteractiveComponent()
  if Component and Component.AutoStandWhenInteract == true then
    local ESTEPoseState = import("ESTEPoseState")
    if Character.PoseState == ESTEPoseState.Crouch then
      local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
      if OperateSubsystem then
        local Result = OperateSubsystem:BleCrouch()
        if Result then
          return true
        else
          print(bWriteLog and "AInteractiveActorBase:OnClientClickInteractiveButton, Crouch, Result = " .. tostring(Result))
          return false
        end
      else
        print(bWriteLog and "AInteractiveActorBase:OnClientClickInteractiveButton, Crouch, OperateSubsystem = " .. tostring(OperateSubsystem))
        return false
      end
    elseif Character.PoseState == ESTEPoseState.Prone then
      local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
      if OperateSubsystem then
        local Result = OperateSubsystem:BleProne()
        if Result then
          return true
        else
          print(bWriteLog and "AInteractiveActorBase:OnClientClickInteractiveButton, Prone, Result = " .. tostring(Result))
          return false
        end
      else
        print(bWriteLog and "AInteractiveActorBase:OnClientClickInteractiveButton, Prone, ShootingUIPanel = " .. tostring(ShootingUIPanel))
        return false
      end
    end
  end
  return true
end
function AInteractiveActorBase:MustCheckResultAfterServerClick(character, result, component, Flag, Reason)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  print(bWriteLog and "AInteractiveActorBase:MustCheckResultAfterServerClick, PlayerKey = " .. tostring(character.PlayerKey) .. ", result = " .. tostring(result) .. ", actor = " .. tostring(UKismetSystemLibrary.GetObjectName(self.Object)))
  component = component or self:GetInteractiveComponent()
  if result then
    if Flag == -1 then
      self:OnUploadLoots(character)
    elseif component then
      local SkillId = component.SkillId
      print(bWriteLog and "AInteractiveActorBase:MustCheckResultAfterServerClick, SkillId = " .. tostring(SkillId))
      if SkillId ~= nil and SkillId ~= 0 and slua.isValid(character) and (not character:IsCastingSkillIDFix(SkillId) or component == Game:GetSkillBlackboardValue(character, SkillId, UEnums.EBlackBoardKeyType.WeakObject, "CurInteractiveComp")) then
        Game:SetSkillBlackboardValue(character, SkillId, UEnums.EBlackBoardKeyType.WeakObject, "CurInteractiveComp", component)
        character:TriggerEntrySkillWithID(SkillId, true)
      end
    end
  elseif Flag == -1 then
  elseif component and component.bAllowWhenCoolDown == true and component:IsCoolingDown() == true and 0 < component:GetCoolDownLeftTimeForShow() and 0 < component.TipsIdWhenClickedInCoolDown then
    local LeftTime = component:GetCoolDownLeftTimeForShow()
    Game:UIShowTips(character.PlayerKey, component.TipsIdWhenClickedInCoolDown, tostring(LeftTime))
  end
end
function AInteractiveActorBase:OnUploadLoots(uPlayerCharacter)
  print(bWriteLog and "AInteractiveActorBase:OnUploadLoots")
  local ResultArray = {}
  local Loots = self:GetUploadLoots(uPlayerCharacter)
  local Upload = {}
  for k, v in pairs(Loots) do
    if k == 0 or v == 0 then
      print(bWriteLog and "AInteractiveActorBase:OnUploadLoots, itemId = " .. tostring(k) .. ", Num = " .. tostring(v))
      ResultArray[k] = v
    else
      local Result = Game:AddItemByResID(uPlayerCharacter, k, -v)
      print(bWriteLog and "AInteractiveActorBase:OnUploadLoots, itemId = " .. tostring(k) .. ", Num = " .. tostring(v) .. ", result = " .. tostring(Result))
      ResultArray[k] = v
      if Result == true and 0 < v then
        Upload[k] = v
      end
    end
  end
  if next(Upload) ~= nil then
    log_tree("AInteractiveActorBase:OnUploadLoots, Upload = ", Upload)
    if NetUtil then
      local UID = Game:GetPlayerUID(uPlayerCharacter)
      if UID ~= nil and UID ~= 0 then
        print(bWriteLog and "AInteractiveActorBase:OnUploadLoots, UID = " .. tostring(UID) .. " when PlayerKey = " .. tostring(uPlayerCharacter.PlayerKey) .. " upload_loots")
        GameplayCallbacks.UploadLootsCache(UID, Upload)
        return true
      else
        print(bWriteLog and "AInteractiveActorBase:OnUploadLoots, UID = " .. tostring(UID) .. " when PlayerKey = " .. tostring(uPlayerCharacter.PlayerKey))
      end
    else
      print(bWriteLog and "AInteractiveActorBase:OnUploadLoots, NetUtil = nil")
      return true
    end
  end
  return false
end
function AInteractiveActorBase:GetUploadLoots(uPlayerCharacter)
  return {}
end
function AInteractiveActorBase:OnStartCoolDown(component)
  print(bWriteLog and "AInteractiveActorBase:OnStartCoolDown")
end
function AInteractiveActorBase:OnRepOccupied(component)
  print(bWriteLog and "AInteractiveActorBase:OnRepOccupied")
end
function AInteractiveActorBase:OnRepOccupyingNumChanged(Component)
  print(bWriteLog and "AInteractiveActorBase:OnRepOccupyingNumChanged")
end
function AInteractiveActorBase:OnRepCoolDown(component)
  print(bWriteLog and "AInteractiveActorBase:OnRepCoolDown")
end
function AInteractiveActorBase:OnRepCurrentCharacter(component)
  print(bWriteLog and "AInteractiveActorBase:OnRepCurrentCharacter")
end
function AInteractiveActorBase:OnRepCurrentCharacterArray(component)
  print(bWriteLog and "AInteractiveActorBase:OnRepCurrentCharacterArray")
end
function AInteractiveActorBase:OnRepEnabled(component)
  component = component or self:GetInteractiveComponent()
  if component then
    print(bWriteLog and "AInteractiveActorBase:OnRepEnabled, component.bEnabled = " .. tostring(component.bEnabled))
    if component.bEnabled == false then
      self:CloseUI(component)
    end
    self:ChangeMaterialByState(component.bEnabled, component)
    self:PlayAudioIfEnabled(component.bEnabled, component)
  else
    print(bWriteLog and "AInteractiveActorBase:OnRepEnabled")
  end
end
function AInteractiveActorBase:GetStaticMesh()
  if self:IsValid(self.FirstStaticMesh) == false then
    self.StaticMeshArray = {}
    self.FirstStaticMesh = nil
    local StaticMeshComponentClass = import("StaticMeshComponent")
    local uTargetArray = self:GetComponentsByClass(StaticMeshComponentClass)
    for i = 0, uTargetArray:Num() - 1 do
      local temp = uTargetArray:Get(i)
      if self:IsValid(temp) and temp:ComponentHasTag("Ignore") == false then
        table.insert(self.StaticMeshArray, temp)
        if self.FirstStaticMesh == nil then
          self.FirstStaticMesh = temp
        end
      end
    end
  end
  return self.FirstStaticMesh, self.StaticMeshArray
end
function AInteractiveActorBase:ChangeMaterialByState(Enabled, Component)
  Component = Component or self:GetInteractiveComponent()
  local TargetMaterial
  if Enabled then
    TargetMaterial = Component.DefaultMaterial
  else
    TargetMaterial = Component.DisabledMaterial
  end
  if TargetMaterial and TargetMaterial.AssetPathName and TargetMaterial.AssetPathName ~= "None" then
    print(bWriteLog and "AInteractiveActorBase:ChangeMaterialByState, Enabled = " .. tostring(Enabled))
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(TargetMaterial.AssetPathName, function(NewMaterail)
      if NewMaterail and self and self:IsValid(self.Object) then
        local _, StaticMeshArray = self:GetStaticMesh()
        for _, v in ipairs(StaticMeshArray) do
          if self:IsValid(v) then
            local NumMaterials = v:GetNumMaterials()
            for i = 0, NumMaterials - 1 do
              v:SetMaterial(i, NewMaterail)
            end
          end
        end
      else
        print(bWriteLog and "AInteractiveActorBase:ChangeMaterialByState, invalid")
      end
    end)
  end
end
function AInteractiveActorBase:PlayAudioIfEnabled(Enabled, Component)
  if Enabled then
    local TargetAudio
    Component = Component or self:GetInteractiveComponent()
    TargetAudio = Component.AudioEvent
    if TargetAudio and TargetAudio.AssetPathName and TargetAudio.AssetPathName ~= "None" then
      print(bWriteLog and "AInteractiveActorBase:PlayAudioIfEnabled, Enabled = " .. tostring(Enabled))
      self:StopAudioBySoundId(self.EnabledSoundId)
      self.EnabledSoundId = self:PlayAudioByPath(TargetAudio.AssetPathName)
    end
  else
    self:StopAudioBySoundId(self.EnabledSoundId)
  end
end
function AInteractiveActorBase:OnResetSkillAction(character, component)
end
function AInteractiveActorBase:OnStartedSkillAction(character, component)
end
function AInteractiveActorBase:MustCheckResultAfterSkillFinished(character, Result, Component)
  if Result == false then
    return
  end
  if self.hasAuthority then
    if character then
      Component = Component or self:GetInteractiveComponent()
      if Component and slua.isValid(Component) and Component.TLogKey and Component.TLogKey > 0 then
        local PlayerState = character:GetPlayerStateSafety()
        if Game:IsValid(PlayerState) then
          PlayerState:AddGeneralCount(Component.TLogKey, 1, Component.bTLogCountReset)
        end
      end
    end
  else
    self:CloseUI(Component)
  end
end
function AInteractiveActorBase:OnStoppedSkillAction(Character, StopReason, SkillId, Component)
  print(bWriteLog and "AInteractiveActorBase:OnStoppedSkillAction, self.hasAuthority = " .. tostring(self.hasAuthority) .. ", StopReason = " .. tostring(StopReason) .. ", SkillId = " .. tostring(SkillId) .. ", PlayerKey = " .. tostring(Character.PlayerKey))
end
function AInteractiveActorBase:GetAllInteractiveCharacters()
  local AllCharacters = {}
  local _, ComponentArray = self:GetInteractiveComponent()
  if ComponentArray and 0 < #ComponentArray then
    for i, Component in ipairs(ComponentArray) do
      local allCharacters = self:GetInteractiveCharactersByComponent(Component)
      if 0 < #AllCharacters then
        for Index1, Char1 in ipairs(allCharacters) do
          for Index2, Char2 in ipairs(AllCharacters) do
            if Char2.PlayerKey == Char1.PlayerKey then
              table.remove(AllCharacters, Index2)
              break
            end
          end
        end
      end
      table.move(allCharacters, 1, #allCharacters, #AllCharacters + 1, AllCharacters)
    end
  else
    print(bWriteLog and "AInteractiveActorBase:GetAllInteractiveCharacters, component = nil")
  end
  print(bWriteLog and "AInteractiveActorBase:GetAllInteractiveCharacters, num = " .. tostring(#AllCharacters))
  return AllCharacters
end
function AInteractiveActorBase:GetInteractiveCharactersByComponent(Component)
  local allCharacters = {}
  if Component and slua.isValid(Component) then
    local uActor = import("Character")
    local resultArray = Component:GetAllInteractiveCharacters(slua.Array(UEnums.EPropertyClass.Object, uActor))
    for i = 0, resultArray:Num() - 1 do
      local char = resultArray:Get(i)
      if char and char:IsAlive() and char:IsNearDeath() == false then
        table.insert(allCharacters, char)
      end
    end
    print(bWriteLog and "AInteractiveActorBase:GetInteractiveCharactersByComponent, num = " .. tostring(#allCharacters) .. ", Component = " .. tostring(Component))
  else
    print(bWriteLog and "AInteractiveActorBase:GetInteractiveCharactersByComponent, Component = nil")
  end
  return allCharacters
end
function AInteractiveActorBase:PlayAudioByPath(path)
  if path == nil or path == "" then
    return 0
  end
  local TempSoundId = 0
  local akComponent = self:GetAkComponent()
  if akComponent then
    local util = require("client.slua_ui_framework.util")
    if util then
      if self.loadDelegates[path] then
        util.ClearAssetAsync(self.loadDelegates[path])
        self.loadDelegates[path] = nil
      end
      self.loadDelegates[path] = util.GetAssetAsync(path, function(akEvent)
        if akEvent then
          if slua.isValid(akComponent) then
            akComponent.AkAudioEvent = akEvent
            TempSoundId = akComponent:PostAssociatedAkEvent()
            print(bWriteLog and "AInteractiveActorBase:PlayAudioByPath, soundId = " .. tostring(TempSoundId))
          else
            print(bWriteLog and "AInteractiveActorBase:PlayAudioByPath, akComponent is invalid")
          end
        else
          print(bWriteLog and "AInteractiveActorBase:PlayAudioByPath, GetAssetAsync failed, path = " .. tostring(path))
        end
      end)
    else
      print(bWriteLog and "AInteractiveActorBase:PlayAudioByPath, util = nil")
    end
  end
  return TempSoundId
end
function AInteractiveActorBase:PlayAudioByPathAtTime(sPath, nStartTime, nTotalTime)
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  if sPath == nil or sPath == "" or nStartTime == nil or nTotalTime == nil then
    return 0
  end
  if self.nSoundID ~= 0 then
    self:StopAudioBySoundId(self.nSoundID)
    self.nSoundID = 0
  end
  local uAkComponent = self:GetAkComponent()
  if uAkComponent and GamePlayTools then
    local util = require("client.slua_ui_framework.util")
    if util then
      if self.loadDelegates[sPath] then
        util.ClearAssetAsync(self.loadDelegates[sPath])
        self.loadDelegates[sPath] = nil
      end
      self.loadDelegates[sPath] = util.GetAssetAsync(sPath, function(akEvent)
        if akEvent then
          if slua.isValid(uAkComponent) then
            uAkComponent.AkAudioEvent = akEvent
            self.nSoundID = uAkComponent:PostAssociatedAkEvent()
            print(bWriteLog and "[YY-D] AInteractiveActorBase:PlayAudioByPathAtTime, nSoundId = " .. tostring(self.nSoundID))
            local nCurrentTime = GamePlayTools.GetServerWorldTimeSeconds()
            local nPassingTime = nCurrentTime - nStartTime
            if 0 < nPassingTime then
              local nTimeInSeconds = nPassingTime % nTotalTime
              local nTime = math.floor(nTimeInSeconds * 1000)
              if 0 < nTime then
                print(bWriteLog and "[YY-D] AInteractiveActorBase:PlayAudioByPathAtTime, nTime = " .. nTime)
                local result = uAkComponent:SeekOnEvent("", nTime)
              end
            end
          else
            print(bWriteLog and "[YY-D] AInteractiveActorBase:PlayAudioByPathAtTime, akComponent is invalid")
          end
        else
          print(bWriteLog and "[YY-D] AInteractiveActorBase:PlayAudioByPathAtTime, GetAssetAsync failed, path = " .. tostring(sPath))
        end
      end)
    else
      print(bWriteLog and "[YY-D] AInteractiveActorBase:PlayAudioByPathAtTime, util = nil")
    end
  else
    print(bWriteLog and "[YY-D] AInteractiveActorBase:PlayAudioByPathAtTime, AkComponent or GamePlayTools is Nil")
  end
end
function AInteractiveActorBase:StopAudioBySoundId(soundId)
  if soundId and soundId ~= 0 then
    local akComponent = self:GetAkComponent()
    if akComponent then
      print(bWriteLog and "[YY-D] AInteractiveActorBase:StopAudioBySoundId, soundId = " .. soundId)
      akComponent:StopPlayingID(soundId)
    end
  end
end
function AInteractiveActorBase:GetAkComponent()
  if self:IsValid(self.akComponent) == false then
    self.akComponent = nil
    local akComponentClass = import("/Script/AkAudio.AkComponent")
    local uTargetArray = self:GetComponentsByClass(akComponentClass)
    if uTargetArray then
      for j = 0, uTargetArray:Num() - 1 do
        local temp = uTargetArray:Get(j)
        if self:IsValid(temp) then
          self.akComponent = temp
          break
        end
      end
    else
      print(bWriteLog and "AInteractiveActorBase:GetAkComponent, uTargetArray = nil")
    end
  end
  print(bWriteLog and "AInteractiveActorBase:GetAkComponent, self.akComponent = " .. tostring(self.akComponent))
  return self.akComponent
end
function AInteractiveActorBase:IsValid(object)
  if object == nil then
    return false
  elseif type(object) == "table" then
    return true
  elseif type(object) == "userdata" then
    if slua.isValid(object) then
      return true
    else
      print(bWriteLog and "AInteractiveActorBase:IsValid, slua.isValid = false")
      return false
    end
  elseif type(object) == "boolean" then
    return object
  end
  return true
end
function AInteractiveActorBase:OnBPRecycled()
  self:EndPlayImpl(true)
end
function AInteractiveActorBase:ReceiveEndPlay(EndPlayReason)
  self:EndPlayImpl(false)
  if self.Super.ReceiveEndPlay then
    self.Super:ReceiveEndPlay(EndPlayReason)
  end
  AInteractiveActorBase.__super.ReceiveEndPlay(self, EndPlayReason, false)
end
function AInteractiveActorBase:EndPlayImpl(bRecycled)
  self:Dispose()
  if self.hasAuthority == false and self.ComponentArray and type(self.ComponentArray) == "table" then
    for i, Component in ipairs(self.ComponentArray) do
      self:CloseUI(Component)
    end
  end
end
function AInteractiveActorBase:ShowCDBar(uComponent, nDuration, bShowCancleButton)
  uComponent = uComponent or self:GetInteractiveComponent()
  if 0 < nDuration and slua.isValid(uComponent) then
    if self.HaveShowCDBar == false then
      self.HaveShowCDBar = true
      if self.NewCDUIParam == nil then
        self.NewCDUIParam = {
          IconPath = uComponent.LoadingIcon.AssetPathName,
          TextID = uComponent.TextId,
          Params = uComponent.Params,
          Component = uComponent,
          Duration = nDuration,
          ShowCancleButton = bShowCancleButton
        }
      else
        self.NewCDUIParam.IconPath = uComponent.LoadingIcon.AssetPathName
        self.NewCDUIParam.TextID = uComponent.TextId
        self.NewCDUIParam.Params = uComponent.Params
        self.NewCDUIParam.Component = uComponent
        self.NewCDUIParam.Duration = nDuration
        self.NewCDUIParam.ShowCancleButton = bShowCancleButton
      end
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      print(bWriteLog and "[YY-D]AInteractiveActorBase:ShowCDBar, Name = " .. tostring(UKismetSystemLibrary.GetObjectName(self.Object)))
      EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_CDBAR_BTN, self.NewCDUIParam)
    end
  else
    print(bWriteLog and "[YY-E]AInteractiveActorBase:ShowCDBar, nDuration <= 0 ")
  end
end
function AInteractiveActorBase:HideCDBar()
  if self.HaveShowCDBar == true then
    self.HaveShowCDBar = false
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    print(bWriteLog and "[YY-D]AInteractiveActorBase:HideCDBar, Name = " .. tostring(UKismetSystemLibrary.GetObjectName(self.Object)))
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_CDBAR_BTN, self.NewUIParam)
  end
end
local Class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local AInteractiveActorBaseClass = Class(CActorBase, nil, AInteractiveActorBase)
return AInteractiveActorBaseClass