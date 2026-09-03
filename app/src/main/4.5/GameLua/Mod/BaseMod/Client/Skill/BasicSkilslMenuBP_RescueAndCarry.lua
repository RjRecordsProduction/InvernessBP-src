local BasicSkillsMenuBP = require("GameLua.Mod.BaseMod.Client.Skill.BasicSkillsMenuBP_Config")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local DeadBoxCfg = require("GameLua.Mod.Library.GamePlay.Config.CarryDeadBoxConfig")
local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
local IntlHelper = import("IntlHelper")
local UKismetSystemLibrary = import("KismetSystemLibrary")
function BasicSkillsMenuBP:NewOnClickCarryBackBtn()
  print(bWriteLog and "[Resuce]BasicSkillsMenuBP:NewOnClickCarryBackBtn")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  local EPawnState = import("EPawnState")
  if uPlayerCharacter:IsCarryBackEnable() then
    if uPlayerCharacter:HasState(EPawnState.CarryBack) then
      print(bWriteLog and "[Resuce]BasicSkillsMenuBP:OnClickCarryBackBtn Start Put Down")
      uPlayerCharacter:RPC_Server_TriggerEntryEventByID(1013193, true)
      self:NewHideCarryBackBtn()
      return
    elseif slua.isValid(self.CarryCharacter) then
      if uPlayerCharacter:AllowState(EPawnState.CarryBack, true) then
        if self.CarryCharacter.HasState and self.CarryCharacter:HasState(EPawnState.InVehicle) then
          print(bWriteLog and "[Resuce]BasicSkillsMenuBP:OnClickCarryBackBtn Start Carry Back From Vehicle")
          uPlayerCharacter:RPC_Server_TriggerEntryEventByID(1013197, true)
        else
          print(bWriteLog and "[Resuce]BasicSkillsMenuBP:OnClickCarryBackBtn Start Carry Back")
          uPlayerCharacter:RPC_Server_TriggerEntryEventByID(1013192, true)
        end
        uPlayerCharacter.bDisableProne = true
        uPlayerCharacter:AddGameTimer(1, false, function()
          if slua.isValid(uPlayerCharacter) then
            uPlayerCharacter.bDisableProne = false
          end
        end)
        self:NewHideCarryBackBtn()
        return
      else
        print(bWriteLog and "[Resuce]BasicSkillsMenuBP:OnClickCarryBackBtn Start Carry Back failed, not allow")
      end
    end
  else
    print(bWriteLog and "[Resuce]BasicSkillsMenuBP:OnClickCarryBackBtn Failed")
  end
end
function BasicSkillsMenuBP:NewOnClickBtnRescue()
  print(bWriteLog and "[Resuce]BasicSkillsMenuBP:NewOnClickBtnRescue")
  local uPawn = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPawn) then
    if self:CanClickSelfRescue(uPawn) == false then
      return
    end
    local EPawnState = import("EPawnState")
    local bIsInCarryBack = uPawn:HasState(EPawnState.CarryBack)
    local bIsInCarryBox = uPawn.CarryDeadBoxFeature and slua.isValid(uPawn.CarryDeadBoxFeature.AttachedDeadBox)
    if bIsInCarryBack or bIsInCarryBox then
      return
    end
    if uPawn:PlayerConfirmToRescue() then
      local uRescueOtherCom = uPawn.RescueOtherComponent
      if slua.isValid(uRescueOtherCom) and not slua.isValid(uRescueOtherCom.RescueWho) then
        local ECharacterSearchEnum = import("ECharacterSearchEnum")
        local EExecutionCondition = import("EExecutionCondition")
        print(bWriteLog and "[Resuce]BasicSkillsMenuBP:NewOnClickBtnRescue 0")
        if uPawn.SearchOtherComponent then
          uPawn.SearchOtherComponent:ResetSearchResult(ECharacterSearchEnum.CanSelfRescue, EExecutionCondition.Client)
          uPawn.SearchOtherComponent:ResetTickCheckTime(ECharacterSearchEnum.CanSelfRescue, 0.1, EExecutionCondition.Client, false)
        end
      end
    end
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "BtnRescue", "CarryBackAndRescue")
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "CanvasPanel_NewBieGuideSave", "CarryBackAndRescue")
    self:NewHideCarryBackBtn()
  end
end
function BasicSkillsMenuBP:NewOnCanCarryOtherEvent(CarryWho, Owner, IsTurnInto)
  print(bWriteLog and "[Resuce]BasicSkillsMenuBP:NewOnCanCarryOtherEvent IsTurnInto=" .. tostring(IsTurnInto))
  local uOwnerPlayerController = Owner:GetPlayerControllerSafety()
  local uPlayerController = GameplayData.GetPlayerController()
  if uOwnerPlayerController ~= uPlayerController then
    return
  end
  if IsTurnInto then
    self:NewShowCarryBackBtn(Owner)
  else
    self:NewHideCarryBackBtn(Owner)
  end
end
function BasicSkillsMenuBP:NewOnCanRescueOtherEvent(RescueWho, Owner, IsTurnInto)
  print(bWriteLog and "[Resuce]BasicSkillsMenuBP:NewOnCanRescueOtherEvent IsTurnInto=" .. tostring(IsTurnInto))
  local uOwnerPlayerController = Owner:GetPlayerControllerSafety()
  local uPlayerController = GameplayData.GetPlayerController()
  if uOwnerPlayerController ~= uPlayerController then
    return
  end
  if not self.UIRoot then
    print(bWriteLog and "[Resuce]BasicSkillsMenuBP:OnCanRescueOtherEvent not self.UIRoot?")
    return
  end
  if IsTurnInto then
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Visible, "BtnRescue", "CarryBackAndRescue")
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.HitTestInvisible, "CanvasPanel_NewBieGuideSave", "CarryBackAndRescue")
    self.UIRoot.CanvasPanel_TeamUpPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_TeamUpFail:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if self.UIRoot.TextBlock_1 and self.UIRoot.Image_30 then
      self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(44136))
      self.UIRoot.Image_30:SetBrushFromPathAsync("/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_jiuyuan_png.ZD_icon_jiuyuan_png", false)
      if RescueWho and slua.isValid(RescueWho) and Owner and slua.isValid(Owner) and RescueWho.PlayerKey == Owner.PlayerKey then
        self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(77861))
      end
    end
  else
    if slua.isValid(Owner) and slua.isValid(Owner.SearchOtherComponent) then
      local ECharacterSearchEnum = import("ECharacterSearchEnum")
      local EExecutionCondition = import("EExecutionCondition")
      local RescueTeammateSearchResult = Owner.SearchOtherComponent.SearchResults:Get(ECharacterSearchEnum.CanRescueTeammate)
      local SelfRescueSearchResult = Owner.SearchOtherComponent.SearchResults:Get(ECharacterSearchEnum.CanSelfRescue)
      if slua.isValid(RescueTeammateSearchResult) and slua.isValid(SelfRescueSearchResult) and (RescueTeammateSearchResult.FinalResults:Num() > 0 or SelfRescueSearchResult.FinalResults:Num() > 0) then
        print(bWriteLog and "[Resuce]BasicSkillsMenuBP:NewOnCanRescueOtherEvent has result")
        return
      end
    end
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "BtnRescue", "CarryBackAndRescue")
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "CanvasPanel_NewBieGuideSave", "CarryBackAndRescue")
  end
end
function BasicSkillsMenuBP:NewShowCarryBackBtnProxy(_, _, uPlayerCharacter, bSuccess)
  print(bWriteLog and "[Resuce]BasicSkillsMenuBP:NewShowCarryBackBtnProxy " .. tostring(bSuccess))
  local EPawnState = import("EPawnState")
  if bSuccess or slua.isValid(uPlayerCharacter) and uPlayerCharacter:HasState(EPawnState.CarryBack) then
    if slua.isValid(uPlayerCharacter.SearchOtherComponent) then
      local ECharacterSearchEnum = import("ECharacterSearchEnum")
      local EExecutionCondition = import("EExecutionCondition")
      uPlayerCharacter.SearchOtherComponent:ResetSearchResult(ECharacterSearchEnum.CanCarryPlayerTombBox, EExecutionCondition.Client)
      uPlayerCharacter.SearchOtherComponent:ResetTickCheckTime(ECharacterSearchEnum.CanCarryPlayerTombBox, 0, EExecutionCondition.Client, false)
      uPlayerCharacter.SearchOtherComponent:ResetSearchResult(ECharacterSearchEnum.CanCarryPawn, EExecutionCondition.Client)
      uPlayerCharacter.SearchOtherComponent:ResetTickCheckTime(ECharacterSearchEnum.CanCarryPawn, 0, EExecutionCondition.Client, false)
    end
    self:NewShowCarryBackBtn(uPlayerCharacter)
  elseif slua.isValid(uPlayerCharacter) and slua.isValid(uPlayerCharacter.SearchOtherComponent) then
    local ECharacterSearchEnum = import("ECharacterSearchEnum")
    local EExecutionCondition = import("EExecutionCondition")
    uPlayerCharacter.SearchOtherComponent:ResetSearchResult(ECharacterSearchEnum.CanCarryPawn, EExecutionCondition.Client)
    uPlayerCharacter.SearchOtherComponent:ResetTickCheckTime(ECharacterSearchEnum.CanCarryPawn, 0, EExecutionCondition.Client, false)
    uPlayerCharacter.SearchOtherComponent:ResetTickCheckTime(ECharacterSearchEnum.CanRescueTeammate, 0, EExecutionCondition.Client, false)
  end
end
function BasicSkillsMenuBP:NewShowCarryBackBtn(uPlayerCharacter)
  local uLocalPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uLocalPlayerCharacter) then
    return
  end
  local isInMainCity = GameStatus.IsInLobbyOrMainCity()
  if isInMainCity then
    self:NewHideCarryBackBtn(uPlayerCharacter)
    return
  end
  print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:ShowCarryBackBtn %s %s", uPlayerCharacter:GetPlayerNameSafety(), uLocalPlayerCharacter:GetPlayerNameSafety()))
  if uPlayerCharacter ~= uLocalPlayerCharacter or not uPlayerCharacter:IsCarryBackEnable() then
    print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:ShowCarryBackBtn Fail, %s %s", tostring(uPlayerCharacter:IsCarryBackEnable()), tostring(uPlayerCharacter ~= uLocalPlayerCharacter)))
    return
  end
  local EPawnState = import("EPawnState")
  local bIsInCarryBack = uPlayerCharacter:HasState(EPawnState.CarryBack)
  local bIsInCarryBox = uPlayerCharacter.CarryDeadBoxFeature and slua.isValid(uPlayerCharacter.CarryDeadBoxFeature.AttachedDeadBox)
  if bIsInCarryBack or bIsInCarryBox then
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Visible, "Button_PutDown", "CarryBackAndRescue")
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.HitTestInvisible, "CanvasPanel_NewBieGuidePutDown", "CarryBackAndRescue")
    self:TriggerCarryBackAppearance(true, bIsInCarryBack, bIsInCarryBox)
    if bIsInCarryBack then
      self:ShoworHideNearDeathBreath(true)
      local USTExtraVehicleUtils = import("STExtraVehicleUtils")
      local VehicleUserComp = USTExtraVehicleUtils.GetVehicleUserComp(uPlayerCharacter)
      if slua.isValid(VehicleUserComp) then
        local CurrentClosestVehicle = VehicleUserComp.CurrentClosestVehicle
        if CurrentClosestVehicle then
          self:SetPutDownInVehicleBtnVisiable(true)
        end
      end
    end
  else
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Visible, "Button_PutDown", "CarryBackAndRescue")
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.HitTestInvisible, "CanvasPanel_NewBieGuidePutDown", "CarryBackAndRescue")
    self:TriggerCarryBackAppearance(false, slua.isValid(self.CarryCharacter), slua.isValid(self.CarryPlayerTombBox))
    if slua.isValid(self.CarryCharacter) then
      self:ShoworHideNearDeathBreath(false)
      self:SetPutDownInVehicleBtnVisiable(false)
    end
  end
end
function BasicSkillsMenuBP:NewHideCarryBackBtn(uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) then
    print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:HideCarryBackBtn %s", uPlayerCharacter:GetPlayerNameSafety()))
    local uLocalPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uLocalPlayerCharacter) and uPlayerCharacter == uLocalPlayerCharacter then
      self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "Button_PutDown", "CarryBackAndRescue")
      self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "CanvasPanel_NewBieGuidePutDown", "CarryBackAndRescue")
      self:ShoworHideNearDeathBreath(false)
    end
  else
    print(bWriteLog and "[Resuce]BasicSkillsMenuBP:HideCarryBackBtn None")
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "Button_PutDown", "CarryBackAndRescue")
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "CanvasPanel_NewBieGuidePutDown", "CarryBackAndRescue")
    self:ShoworHideNearDeathBreath(false)
  end
  self:SetPutDownInVehicleBtnVisiable(false)
end
function BasicSkillsMenuBP:OnCanCarryAnyActorEvent(CarryActor, Owner, IsTurnInto, bHasDifference, CompositeName)
  if CompositeName ~= "CanCarrySomeOne" then
    return
  end
  if not slua.isValid(Owner) then
    return
  end
  if slua.isValid(CarryActor) then
    print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:OnCanCarryAnyActorEvent IsTurnInto=%s, CarryActor=%s, Owner=%s", tostring(IsTurnInto), UKismetSystemLibrary.GetObjectName(CarryActor), Owner:GetPlayerNameSafety()))
  else
    print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:OnCanCarryAnyActorEvent IsTurnInto=%s, CarryActor=nil, Owner=%s", tostring(IsTurnInto), Owner:GetPlayerNameSafety()))
  end
  self.CarryCharacter = nil
  self.CarryPlayerTombBox = nil
  if IsTurnInto and slua.isValid(CarryActor) then
    local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
    if Game:IsClassOf(CarryActor, ASTExtraPlayerCharacter) then
      self.CarryCharacter = CarryActor
      self.CarryPlayerTombBox = nil
    else
      self.CarryCharacter = nil
      self.CarryPlayerTombBox = CarryActor
    end
  end
  local uOwnerPlayerController = Owner:GetPlayerControllerSafety()
  local uPlayerController = GameplayData.GetPlayerController()
  if uOwnerPlayerController ~= uPlayerController then
    return
  end
  if IsTurnInto then
    self:NewShowCarryBackBtn(Owner)
  else
    self:NewHideCarryBackBtn(Owner)
  end
end
function BasicSkillsMenuBP:NewTriggerCarryBackAppearance(bIsCarryingBack, bIsInCarryBack, bIsInCarryBox)
  print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:NewTriggerCarryBackAppearance  bIsCarryingBack=%s, bIsInCarryBack=%s, bIsInCarryBox=%s", bIsCarryingBack, bIsInCarryBack, bIsInCarryBox))
  if bIsInCarryBack then
    if bIsCarryingBack then
      self.UIRoot.Text_CarryBack:SetText(IntlHelper.GetLocalizationStringWithID(23980))
    else
      self.UIRoot.Text_CarryBack:SetText(IntlHelper.GetLocalizationStringWithID(23979))
    end
    self.UIRoot.Image_PutDown:SetBrushFromPathAsync("/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/ZD_icon_Rescue_png.ZD_icon_Rescue_png", true)
  elseif bIsInCarryBox then
    if bIsCarryingBack then
      self.UIRoot.Text_CarryBack:SetText(IntlHelper.GetLocalizationStringWithID(86796))
      self.UIRoot.Image_PutDown:SetBrushFromPathAsync("/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_icon_LayDown80x80_png.ZD_icon_LayDown80x80_png", true)
    else
      self.UIRoot.Text_CarryBack:SetText(IntlHelper.GetLocalizationStringWithID(86795))
      self.UIRoot.Image_PutDown:SetBrushFromPathAsync("/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_icon_Carry80x80_png.ZD_icon_Carry80x80_png", true)
    end
  else
    self.UIRoot.Image_PutDown:SetBrushFromPathAsync("/Game/Arts/UI/Atlas/BattleUI/MainBackPack/Frames/ZD_icon_Rescue_png.ZD_icon_Rescue_png", true)
  end
end
function BasicSkillsMenuBP:OnPlayerCarryBoxDone(_, __, uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) then
    print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:OnPlayerCarryBoxDone %s", uPlayerCharacter:GetPlayerNameSafety()))
    self:CheckShowCarryBackBtn()
  end
end
function BasicSkillsMenuBP:OnPlayerCarryBoxInterupt(_, __, uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) then
    print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:OnPlayerCarryBoxInterupt %s", uPlayerCharacter:GetPlayerNameSafety()))
    self:CheckShowCarryBackBtn()
  end
end
function BasicSkillsMenuBP:NewOnClickPutDownDeadBoxBtn()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:NewOnClickPutDownDeadBoxBtn"))
    local EPawnState = import("EPawnState")
    local uSkillManager = uPlayerCharacter:GetSkillManager()
    if uPlayerCharacter:HasState(EPawnState.CarryBox) and slua.isValid(uSkillManager) and not uSkillManager:IsCastingSkillID(DeadBoxCfg.CarryDeadBoxSkillID) then
      print(bWriteLog and "[Resuce]BasicSkillsMenuBP:NewOnClickPutDownDeadBoxBtn Start Put Down Box")
      uPlayerCharacter:TriggerEntrySkillWithID(DeadBoxCfg.PutDownDeadBoxSkillID, true)
      self.UIRoot.Button_PutDownDeadBox:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function BasicSkillsMenuBP:CheckShowCarryBackBtn()
  printf(bWriteLog and "[Resuce]BasicSkillsMenuBP CheckShowCarryBackBtn")
  local Visibility = UEnums.ESlateVisibility.Collapsed
  local uLocalPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uLocalPlayerCharacter) then
    local bIsInCarryBox = uLocalPlayerCharacter.CarryDeadBoxFeature and slua.isValid(uLocalPlayerCharacter.CarryDeadBoxFeature.AttachedDeadBox)
    if bIsInCarryBox then
      print(bWriteLog and string.format("[Resuce]BasicSkillsMenuBP:OnPlayerCarryBoxDone %s", uLocalPlayerCharacter:GetPlayerNameSafety()))
      Visibility = UEnums.ESlateVisibility.Visible
    end
  end
  self.UIRoot.Button_PutDownDeadBox:SetVisibility(Visibility)
end
function BasicSkillsMenuBP:NewOnCanExecuteOtherEvent(ExecuteWho, Owner, IsTurnInto)
  print(bWriteLog and "[Execute]BasicSkillsMenuBP:NewOnCanExecuteOtherEvent IsTurnInto=" .. tostring(IsTurnInto))
  local uOwnerPlayerController = Owner:GetPlayerControllerSafety()
  local uPlayerController = GameplayData.GetPlayerController()
  if uOwnerPlayerController ~= uPlayerController then
    return
  end
  if not self.UIRoot then
    print(bWriteLog and "[Execute]BasicSkillsMenuBP:NewOnCanExecuteOtherEvent not self.UIRoot")
    return
  end
  if IsTurnInto then
    if CGameState and CGameState.bIsCreativeWoW then
      print(bWriteLog and "[Execute]BasicSkillsMenuBP:NewOnCanExecuteOtherEvent suppressed by CreativeWoW mode")
      return
    end
    if XSuitUtil:GetEquippedExecutePlanID(Owner) <= 0 then
      print(bWriteLog and "[Execute]BasicSkillsMenuBP:NewOnCanExecuteOtherEvent no execute plan equipped, suppress btn")
      return
    end
    self:ShowNormalBtn("Type_Execute")
  else
    self:HideNormalBtn("Type_Execute")
  end
end