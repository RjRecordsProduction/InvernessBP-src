local BasicSkillsMenuBP = require("GameLua.Mod.BaseMod.Client.Skill.BasicSkillsMenuBP_Config")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TableUtil = require("common.table_util")
local IntlHelper = import("IntlHelper")
function BasicSkillsMenuBP:ShowNormalBtn(Type, InteractiveConfig)
  print(bWriteLog and string.format("BasicSkillsMenuBP:ShowNormalBtn---%s, %d, %s", Type, InteractiveConfig and InteractiveConfig.TextID or -1, InteractiveConfig and tostring(InteractiveConfig.Component) or "nil"))
  local Config = self.InteractTypes[Type]
  if Config then
    if not Config.bChangeOperation then
      local Key = InteractiveConfig and InteractiveConfig.Component or Type
      local ItemData = self.CurrentInteractItemDataMap[Key]
      if not ItemData then
        if InteractiveConfig then
          Config = TableUtil.DeepCloneTable(Config)
          Config.          Config.        end
        local Data = self.LoopScrollBoxInteract:GetSetData()
        local PriorityIndex = -1
        if not Config.bLast and Config.InteractiveConfig and Config.InteractiveConfig.Component and Config.InteractiveConfig.Component.ButtonPriority and Config.InteractiveConfig.Component.ButtonPriority > 0 then
          local nNewItemPriority = Config.InteractiveConfig.Component.ButtonPriority
          local nPosIndex = #Data
          if nPosIndex < 1 then
            table.insert(Data, Config)
            print(bWriteLog and "BasicSkillsMenuBP:OnRefreshItem Button_Priority First--------------------")
            print(bWriteLog and "BasicSkillsMenuBP:OnRefreshItem Button_Priority nNewItemPriority:" .. tostring(nNewItemPriority))
          else
            print(bWriteLog and "BasicSkillsMenuBP:OnRefreshItem Button_Priority nNewItemPriority:" .. tostring(nNewItemPriority))
            local bFindHigherLoc = false
            for Index, ExistConfig in pairs(Data) do
              if ExistConfig and ExistConfig.InteractiveConfig and ExistConfig.InteractiveConfig.Component and ExistConfig.InteractiveConfig.Component.ButtonPriority and nNewItemPriority >= ExistConfig.InteractiveConfig.Component.ButtonPriority then
                bFindHigherLoc = true
                if Index < nPosIndex then
                  nPos                end
                print(bWriteLog and "BasicSkillsMenuBP:OnRefreshItem Button_Priority NewIndex:" .. tostring(nPosIndex))
              end
            end
            if not bFindHigherLoc then
              nPosIndex = nPosIndex + 1
            end
            PriorityIndex = nPosIndex
            print(bWriteLog and "BasicSkillsMenuBP:OnRefreshItem Button_Priority InsertIndex:" .. tostring(PriorityIndex))
            table.insert(Data, nPosIndex, Config)
          end
        else
          table.insert(Data, Config)
        end
        self.LoopScrollBoxInteract:SetData(Data)
        ItemData = self:GetInteractItemData()
        if 0 < PriorityIndex then
          ItemData.Index = PriorityIndex
          for _, TempItemData in pairs(self.CurrentInteractItemDataMap) do
            if PriorityIndex <= TempItemData.Index then
              TempItemData.Index = TempItemData.Index + 1
            end
          end
        else
          ItemData.Index = self.LoopScrollBoxInteract:GetItemCount()
        end
        ItemData.        self.CurrentInteractItemDataMap[Key] = ItemData
        local NeedLastIndex
        for Index, Config in pairs(Data) do
          if Config.bLast then
            NeedLast            break
          end
        end
        if NeedLastIndex ~= nil then
          local Value = table.remove(Data, NeedLastIndex)
          table.insert(Data, Value)
        end
        if NeedLastIndex ~= nil then
          self.LoopScrollBoxInteract:SetData(Data)
          ItemData = self:GetInteractItemData()
          ItemData.Index = self.LoopScrollBoxInteract:GetItemCount()
          ItemData.          self.CurrentInteractItemDataMap[Key] = ItemData
          for TempKey, TempItemData in pairs(self.CurrentInteractItemDataMap) do
            if NeedLastIndex < TempItemData.Index then
              self.CurrentInteractItemDataMap[TempKey].Index = self.CurrentInteractItemDataMap[TempKey].Index - 1
            elseif TempItemData.Index == NeedLastIndex then
              self.CurrentInteractItemDataMap[TempKey].Index = self.LoopScrollBoxInteract:GetItemCount()
            end
          end
        end
        if Config.ActionOnShow then
          local ActionFn = self[Config.ActionOnShow]
          if ActionFn then
            ActionFn(self, InteractiveConfig)
          else
            print(bWriteLog and "BasicSkillsMenuBP:OnRefreshItem No Action")
          end
        end
        EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN_FINISHED, Type, InteractiveConfig)
      else
        if InteractiveConfig then
          Config = TableUtil.DeepCloneTable(Config)
          Config.          Config.        end
        self.LoopScrollBoxInteract:RefreshItem(ItemData.Index, Config)
      end
      self.UIRoot.GridPanel_Door:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.CanvasPanel_InteractibleObject:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      if not self.CurrentOperationsTypes[Type] then
        if Config.ActionOnPreShow then
          local ActionFn = self[Config.ActionOnPreShow]
          if ActionFn then
            Config = ActionFn(self, Config, InteractiveConfig)
          end
        end
        local Data = self.LoopScrollBoxOperation:GetSetData()
        Config.        Config.        table.insert(Data, Config)
        local NeedLastIndex
        for Index, Config in pairs(Data) do
          if Config.bLast then
            NeedLast            break
          end
        end
        if NeedLastIndex ~= nil then
          local Value = table.remove(Data, NeedLastIndex)
          table.insert(Data, Value)
        end
        self.LoopScrollBoxOperation:SetData(Data)
        self.CurrentOperationsTypes[Type] = self.LoopScrollBoxOperation:GetItemCount()
        if NeedLastIndex ~= nil then
          for TypeKey, Index in pairs(self.CurrentOperationsTypes) do
            if Index > NeedLastIndex then
              self.CurrentOperationsTypes[TypeKey] = self.CurrentOperationsTypes[TypeKey] - 1
            elseif Index == NeedLastIndex then
              self.CurrentOperationsTypes[TypeKey] = self.LoopScrollBoxOperation:GetItemCount()
            end
          end
        end
        if Config.ActionOnShow then
          local ActionFn = self[Config.ActionOnShow]
          if ActionFn then
            ActionFn(self)
          else
            print(bWriteLog and "BasicSkillsMenuBP:OnRefreshItem No Action")
          end
        end
        EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN_FINISHED, Type, InteractiveConfig)
      end
      self:SetBtnVisibleFlag(UEnums.ESlateVisibility.SelfHitTestInvisible, "GridPanel_DriveAndGetIn", "DriveAndGetInBase")
    end
  end
end
function BasicSkillsMenuBP:HideNormalBtn(Type, InteractiveConfig)
  if bWriteLog and InteractiveConfig and InteractiveConfig.TextID and InteractiveConfig.Component then
    print(string.format("BasicSkillsMenuBP:HideNormalBtn---%s, %d, %s", Type, InteractiveConfig.TextID, tostring(InteractiveConfig.Component)))
  end
  local Config = self.InteractTypes[Type]
  if Config then
    if not Config.bChangeOperation then
      if self.CurrentInteractItemDataMap then
        local Key = InteractiveConfig and InteractiveConfig.Component or Type
        local ItemData = self.CurrentInteractItemDataMap[Key]
        if ItemData then
          local Data = self.LoopScrollBoxInteract:GetSetData()
          table.remove(Data, ItemData.Index)
          self.LoopScrollBoxInteract:SetData(Data)
          for TempKey, TempItemData in pairs(self.CurrentInteractItemDataMap) do
            if TempItemData.Index > ItemData.Index then
              self.CurrentInteractItemDataMap[TempKey].Index = self.CurrentInteractItemDataMap[TempKey].Index - 1
            end
          end
          self.CurrentInteractItemDataMap[Key] = nil
          self:RecycleInteractItemData(ItemData)
          if Config.ActionOnHide then
            local ActionFn = self[Config.ActionOnHide]
            if ActionFn then
              ActionFn(self, InteractiveConfig)
            else
              print(bWriteLog and "BasicSkillsMenuBP:HideNormalBtn No Action")
            end
          end
          print(bWriteLog and "BasicSkillsMenuBP:HideNormalBtn " .. Type)
          EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN_FINISHED, Type, InteractiveConfig)
        end
      end
      self:CheckGridPanelDoorHide()
    elseif self.CurrentOperationsTypes and self.CurrentOperationsTypes[Type] then
      local Data = self.LoopScrollBoxOperation:GetSetData()
      table.remove(Data, self.CurrentOperationsTypes[Type])
      self.LoopScrollBoxOperation:SetData(Data)
      for TypeKey, Index in pairs(self.CurrentOperationsTypes) do
        if Index > self.CurrentOperationsTypes[Type] then
          self.CurrentOperationsTypes[TypeKey] = self.CurrentOperationsTypes[TypeKey] - 1
        end
      end
      self.CurrentOperationsTypes[Type] = nil
      if Config.ActionOnHide then
        local ActionFn = self[Config.ActionOnHide]
        if ActionFn then
          ActionFn(self)
        else
          print(bWriteLog and "BasicSkillsMenuBP:HideNormalBtn No Action")
        end
      end
      print(bWriteLog and "BasicSkillsMenuBP:HideNormalBtn " .. Type)
      EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN_FINISHED, Type, InteractiveConfig)
    end
  end
end
function BasicSkillsMenuBP:UpdateNormalButton(Type, InteractiveConfig)
  print(bWriteLog and string.format("BasicSkillsMenuBP:UpdateNormalButton---%s, %d, %s", Type, InteractiveConfig and InteractiveConfig.TextID or -1, InteractiveConfig and tostring(InteractiveConfig.Component) or "nil"))
  local Config = self.InteractTypes[Type]
  if not Config then
    return
  end
  local Key = InteractiveConfig and InteractiveConfig.Component or Type
  local ItemData = self.CurrentInteractItemDataMap[Key]
  if not ItemData then
    return
  end
  if InteractiveConfig then
    Config = TableUtil.DeepCloneTable(Config)
    Config.    Config.  end
  if Config.bChangeOperation then
    self.LoopScrollBoxOperation:RefreshItem(ItemData.Index, Config)
  else
    self.LoopScrollBoxInteract:RefreshItem(ItemData.Index, Config)
  end
end
function BasicSkillsMenuBP:CanBeVisible(Data, bOperation)
  if not self:CheckShowInPhotographer(Data.Type, bOperation) then
    return false
  end
  if Data.InteractiveConfig and not Data.InteractiveConfig.ShowBtnWhenCasting and Data.InteractiveConfig and slua.isValid(Data.InteractiveConfig.Component) and self.CurrentSkills[Data.InteractiveConfig.Component.skillId] then
    return false
  end
  return true
end
function BasicSkillsMenuBP:OnRefreshItem(bOperation, Widget, Index)
  local Data
  if bOperation then
    Data = self.LoopScrollBoxOperation:GetItemData(Index)
  else
    Data = self.LoopScrollBoxInteract:GetItemData(Index)
  end
  local bCanBeVisible = self:CanBeVisible(Data, bOperation)
  print(bWriteLog and string.format("BasicSkillsMenuBP:OnRefreshItem bOperation=%s, CanBeVisible=%s", tostring(bOperation), tostring(bCanBeVisible)))
  local CurVisibility = bCanBeVisible and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed
  Widget:SetWidgetVisibility(CurVisibility)
  local TextID = Data.TextID
  local Params = Data.Params
  if Data.InteractiveConfig then
    TextID = Data.InteractiveConfig.TextID
    Params = Data.InteractiveConfig.Params
  end
  local Opactiy = 1.0
  if Params and Params.bGrayBtn then
    Opactiy = 0.5
  end
  if Widget.Image_Normal then
    Widget.Image_Normal:SetColorAndOpacity(FLinearColor(1, 1, 1, Opactiy))
  end
  if Widget.TextBlock_Normal then
    Widget.TextBlock_Normal:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, Opactiy)))
  end
  if TextID then
    if Params and Params.RichTextParam then
      if Widget.UTRichTextBlock_0 then
        Widget.UTRichTextBlock_0:SetText(LocUtil.LocalizeFormatConcatenation(TextID, table.unpack(Params.RichTextParam)))
        Widget.UTRichTextBlock_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if Widget.TextBlock_Normal then
        Widget.TextBlock_Normal:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    else
      if Widget.TextBlock_Normal then
        Widget.TextBlock_Normal:SetText(LocUtil.GetLocalizeResStr(TextID))
        Widget.TextBlock_Normal:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if Widget.UTRichTextBlock_0 then
        Widget.UTRichTextBlock_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
  local IconPath = Data.IconPath
  if Data.InteractiveConfig then
    IconPath = Data.InteractiveConfig.IconPath
  end
  if IconPath then
    local UIUtil = require("client.common.ui_util")
    local bHasAddKnownMissing = UIUtil.CheckSmallIconMissing(IconPath, Widget.Image_Normal)
    self:SetTexture(Widget.Image_Normal, IconPath, {bHasAddKnownMissing = bHasAddKnownMissing, sync = false})
  end
  Widget.vx_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if Params and Params.bShowGuide ~= nil then
    local bShowGuideEffect = Params.bShowGuide
    if bShowGuideEffect then
      Widget.vx_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  self:InvalidateLayoutCache(3, 0.1)
end
function BasicSkillsMenuBP:SetPutDownInVehicleBtnVisiable(bShow)
  local STExtraUIUtils = import("STExtraUIUtils")
  local uPlayerCharacter = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPlayerCharacter) then
    local USTExtraVehicleUtils = import("STExtraVehicleUtils")
    local VehicleUserComp = USTExtraVehicleUtils.GetVehicleUserComp(uPlayerCharacter)
    if slua.isValid(VehicleUserComp) and slua.isValid(VehicleUserComp.CurrentClosestVehicle) then
      local CurrentClosestVehicle = VehicleUserComp.CurrentClosestVehicle
      if CurrentClosestVehicle.bForbidCarryPlayerToVehicle then
        bShow = false
        print(bWriteLog and "SetPutDownInVehicleBtnVisiable set bShow=0, CurrentClosestVehicle:" .. tostring(CurrentClosestVehicle))
      end
    end
  end
  if bShow then
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Visible, "Button_PutDownInVehicle", "CarryBackAndRescue")
  else
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "Button_PutDownInVehicle", "CarryBackAndRescue")
  end
  print(bWriteLog and "SetPutDownInVehicleBtnVisiable bShow:", bShow)
end
function BasicSkillsMenuBP:TriggerCarryBackAppearance(bIsCarryingBack, bIsInCarryBack, bIsInCarryBox)
  self:NewTriggerCarryBackAppearance(bIsCarryingBack, bIsInCarryBack, bIsInCarryBox)
end
function BasicSkillsMenuBP:ShowCarryBackBtn(uPlayerCharacter)
  self:NewShowCarryBackBtn(uPlayerCharacter)
end
function BasicSkillsMenuBP:HideCarryBackBtn(uPlayerCharacter)
  self:NewHideCarryBackBtn(uPlayerCharacter)
end
function BasicSkillsMenuBP:NeedShowNearDeathBreath(Player, Target)
  if slua.isValid(Target) then
    local uPlayerController = Player:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) and uPlayerController.IsTeamMate and uPlayerController:IsTeamMate(Target) then
      local PS = Target:GetPlayerStateSafety()
      if slua.isValid(PS) and PS.GetBreathPercentage then
        return true
      end
    end
  end
  return false
end
function BasicSkillsMenuBP:ShoworHideNearDeathBreath(bShow)
  print(bWriteLog and "BasicSkillsMenuBP:ShoworHideNearDeathBreath", bShow)
  if bShow then
    local Player = GameplayData.GetPlayerCharacter()
    if slua.isValid(Player) then
      local Target = Player:GetBeCarriedBackCharacter()
      if self:NeedShowNearDeathBreath(Player, Target) then
        self.UIRoot.Image_Breath:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.Image_BreathBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.Image_CarryBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        print(bWriteLog and "BasicSkillsMenuBP:ShoworHideNearDeathBreath")
        self:RefreshBreathHP(Target)
        if self.UpdateNearDeathTimer ~= nil then
          self:RemoveGameTimer(self.UpdateNearDeathTimer)
          self.UpdateNearDeathTimer = nil
        end
        self.UpdateNearDeathTimer = self:AddGameTimer(self.UpdateBreathInterval, true, function()
          self:RefreshBreathHP(Target)
        end)
        return
      end
    end
  end
  self.UIRoot.Image_Breath:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_BreathBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_CarryBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.UpdateNearDeathTimer ~= nil then
    self:RemoveGameTimer(self.UpdateNearDeathTimer)
    self.UpdateNearDeathTimer = nil
  end
end
function BasicSkillsMenuBP:RefreshBreathHP(uTargetCharacter)
  if not slua.isValid(uTargetCharacter) then
    return
  end
  local PS = uTargetCharacter:GetPlayerStateSafety()
  if slua.isValid(PS) and PS.GetBreathPercentage then
    local BreathHPMat = self.UIRoot.Image_Breath:GetDynamicMaterial()
    if slua.isValid(BreathHPMat) then
      BreathHPMat:SetScalarParameterValue("Mask_Percent", PS:GetBreathPercentage())
    end
  end
end
function BasicSkillsMenuBP:ShowCaptiveBtn(uPlayerCharacter)
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "CarryBack:ShowCaptiveBtn: Failed1")
    return
  end
  local LocalPlayerCharacter = GameplayData.GetPlayerCharacter()
  if uPlayerCharacter ~= LocalPlayerCharacter then
    print(bWriteLog and "CarryBack:ShowCaptiveBtn: Failed2")
    return
  end
  print(bWriteLog and "BasicSkillsMenuBP:ShowCaptiveBtn")
  self.UIRoot.Button_Captive:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.CanvasPanel_TeamUpPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  local uPlayerState = GameplayData.GetPlayerState()
  local TeamPlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  local Num = TeamPlayerStateList:Num()
  self.UIRoot.TextBlock_Time:SetText(tostring(7 - Num > 3 and 3 or Num) .. "/3")
end
function BasicSkillsMenuBP:HideCaptiveBtn(uPlayerCharacter)
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "CarryBack:HideCaptiveBtn: Failed1")
    self.UIRoot.Button_Captive:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_TeamUpPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local LocalPlayerCharacter = GameplayData.GetPlayerCharacter()
  if uPlayerCharacter ~= LocalPlayerCharacter then
    print(bWriteLog and "CarryBack:HideCaptiveBtn: Failed2")
    return
  end
  self.UIRoot.Button_Captive:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_TeamUpPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BasicSkillsMenuBP:ShowOrHideCanDriveTips(_, _, bShowGuide, GuideText)
  print(bWriteLog and "BasicSkillsMenuBP:ShowOrHideCanDriveTips")
  local Index = self.CurrentOperationsTypes.Type_DriverEnter
  local Widget = self.LoopScrollBoxOperation:GetIndexOfWidget(Index)
  if not slua.isValid(Widget) then
    print(bWriteLog and "BasicSkillsMenuBP:ShowOrHideCanDriveTips not slua.isValid(Widget)")
    return
  end
  if not bShowGuide then
    Widget.Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  Widget.Tips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  Widget.UTRichTextBlock_Tips:SetText(GuideText)
end
function BasicSkillsMenuBP:GetOperationWidget(OpTypeName)
  local Index = self.CurrentOperationsTypes[OpTypeName]
  local Widget
  if self.LoopScrollBoxOperation and Index then
    Widget = self.LoopScrollBoxOperation:GetIndexOfWidget(Index)
  end
  if not slua.isValid(Widget) then
    print(bWriteLog and "BasicSkillsMenuBP:GetOperationWidget not slua.isValid(Widget) " .. tostring(OpTypeName))
    return nil
  end
  return Widget
end
function BasicSkillsMenuBP:CheckVehicleTireRepairButtonVisibility()
  self:HideNormalBtn("Type_TireRepair")
  local STExtraUIUtils = import("STExtraUIUtils")
  local PlayerCharacter = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "BasicSkillsMenuBP:CheckVehicleTireRepairButtonVisibility PlayerCharacter is nil")
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local BackpackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(PlayerCharacter)
  if not slua.isValid(BackpackComp) then
    print(bWriteLog and "BasicSkillsMenuBP:CheckVehicleTireRepairButtonVisibility BackpackComp is nil")
    return
  end
  local BackpackUtils = import("BackpackUtils")
  local ItemDefineID = FItemDefineID(6, 604025)
  local Count = BackpackUtils.GetItemCountByDefineID(BackpackComp, ItemDefineID, false)
  if Count < 1 then
    return
  end
  local USTExtraVehicleUtils = import("STExtraVehicleUtils")
  local VehicleUserComp = USTExtraVehicleUtils.GetVehicleUserComp(PlayerCharacter)
  if not slua.isValid(VehicleUserComp) then
    print(bWriteLog and "BasicSkillsMenuBP:CheckVehicleTireRepairButtonVisibility VehicleUserComp is nil")
    return
  end
  local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
  if VehicleUserComp.VehicleUserState == ESTExtraVehicleUserState.EVUS_AsDriver or VehicleUserComp.VehicleUserState == ESTExtraVehicleUserState.EVUS_ASPassenger then
    return
  end
  local Vehicle = VehicleUserComp.CurrentClosestVehicle
  if not slua.isValid(Vehicle) then
    print(bWriteLog and "BasicSkillsMenuBP:CheckVehicleTireRepairButtonVisibility CurrentClosestVehicle is nil")
    return
  end
  local SkillManager = PlayerCharacter:GetSkillManager()
  if not slua.isValid(SkillManager) then
    print(bWriteLog and "BasicSkillsMenuBP:CheckVehicleTireRepairButtonVisibility SkillManager is nil")
    return
  end
  local Skill = SkillManager:QueryOrNewSkill(1003018)
  if not slua.isValid(Skill) then
    print(bWriteLog and "BasicSkillsMenuBP:CheckVehicleTireRepairButtonVisibility Skill 1003018 is nil")
    return
  end
  local ESkillCanBePlayedResult = import("ESkillCanBePlayedResult")
  local Ret = Skill:CanBePlayed(SkillManager)
  if Ret == ESkillCanBePlayedResult.Success then
    self:ShowNormalBtn("Type_TireRepair")
    return
  end
end
function BasicSkillsMenuBP:CheckEnterVehicleButtonVisibility()
  local STExtraUIUtils = import("STExtraUIUtils")
  local uPlayerCharacter = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  local EPawnState = import("EPawnState")
  if not slua.isValid(uPlayerCharacter) or uPlayerCharacter:HasState(EPawnState.Dying) then
    self:HideEnterVehicleButtons()
    return
  end
  local USTExtraVehicleUtils = import("STExtraVehicleUtils")
  local VehicleUserComp = USTExtraVehicleUtils.GetVehicleUserComp(uPlayerCharacter)
  if not slua.isValid(VehicleUserComp) then
    return
  end
  local CurrentClosestVehicle = VehicleUserComp.CurrentClosestVehicle
  if slua.isValid(CurrentClosestVehicle) and (not CurrentClosestVehicle.ShouldShowVehicleEnterUIToCharacher or CurrentClosestVehicle:ShouldShowVehicleEnterUIToCharacher(uPlayerCharacter)) then
    local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
    local VehicleSeats = CurrentClosestVehicle.VehicleSeats
    local bHasDriversSeat = false
    local bHasPsgersSeat = false
    local bHasSameTeam = false
    if slua.isValid(VehicleSeats) then
      local bHasShootDriver = VehicleSeats:GetFirstSeatCharacterBySeatType(ESTExtraVehicleSeatType.ESeatType_ShootDriver)
      bHasDriversSeat = VehicleSeats:IsSeatAvailable(ESTExtraVehicleSeatType.ESeatType_DriversSeat) and not bHasShootDriver
      bHasPsgersSeat = VehicleSeats:IsSeatAvailable(ESTExtraVehicleSeatType.ESeatType_PassengersSeat) or VehicleSeats:IsSeatAvailable(ESTExtraVehicleSeatType.ESeatType_AssistantSeat)
      bHasSameTeam = VehicleSeats:IsSeatAvailableTeam()
    end
    local bCanDrive = self:CanDriveVehicle(CurrentClosestVehicle, uPlayerCharacter)
    local bExclusive = self:IsVehicleExclusive(CurrentClosestVehicle)
    local VehicleType = CurrentClosestVehicle.VehicleType
    local bCanPickable = self:CanPickVehicle(CurrentClosestVehicle)
    self:ShowEnterVehicleButtons(nil, nil, bHasDriversSeat, bHasPsgersSeat, bHasSameTeam, bCanDrive, bExclusive, VehicleType, bCanPickable)
    if uPlayerCharacter:HasState(EPawnState.CarryBack) then
      self:SetPutDownInVehicleBtnVisiable(true)
    end
    self.UpdateTireRepairBtnTimer = self:AddGameTimer(self.UpdateTireRepairBtnInterval, true, function()
      self:CheckVehicleTireRepairButtonVisibility()
    end)
  else
    self:HideEnterVehicleButtons()
    self:SetPutDownInVehicleBtnVisiable(false)
    if self.UpdateTireRepairBtnTimer ~= nil then
      self:RemoveGameTimer(self.UpdateTireRepairBtnTimer)
      self.UpdateTireRepairBtnTimer = nil
    end
  end
  self:CheckMechaDanceButton(CurrentClosestVehicle)
  self:CheckPandaDanceButton(CurrentClosestVehicle)
end
function BasicSkillsMenuBP:ShowEnterVehicleButtons(_, _, bHasDriversSeat, bHasPsgersSeat, bHasSameTeam, bCanDrive, bExclusive, VehicleType, bCanPickable)
  print(bWriteLog and "BasicSkillsMenuBP:ShowEnterVehicleButtons bHasSameTeam: " .. tostring(bHasSameTeam))
  self.CanEnterVehicle = bHasSameTeam
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "BasicSkillsMenuBP:ShowEnterVehicleButtons not uPlayerCharacter")
    return
  end
  local PlanPH_WeddingCarSystem_Client = SubsystemMgr:Get("PlanPH_WeddingCarSystem_Client")
  local USTExtraVehicleUtils = import("STExtraVehicleUtils")
  local VehicleUserComp = USTExtraVehicleUtils.GetVehicleUserComp(uPlayerCharacter)
  if PlanPH_WeddingCarSystem_Client and not PlanPH_WeddingCarSystem_Client:CanShowWeddingCarUI(uPlayerCharacter.PlayerUID, VehicleUserComp.CurrentClosestVehicle) then
    print(bWriteLog and "BasicSkillsMenuBP:ShowNormalBtn CanShowWeddingCarUI false")
    return
  end
  local ECharacterMainType = import("ECharacterMainType")
  if uPlayerCharacter:GetCharacterMainType() ~= ECharacterMainType.NormalPlayer then
    return
  end
  if not self.UIRoot or not self.UIRoot.GridPanel_DriveAndGetIn then
    print(bWriteLog and "BasicSkillsMenuBP:ShowEnterVehicleButtons not self.UIRoot or not self.UIRoot.GridPanel_DriveAndGetIn")
    return
  end
  local ESTExtraVehicleType = import("ESTExtraVehicleType")
  if VehicleType == ESTExtraVehicleType.VT_MegaDrop then
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.SelfHitTestInvisible, "GridPanel_DriveAndGetIn", "DriveAndGetInBase")
    if bHasDriversSeat or bHasPsgersSeat then
      self:ShowNormalBtn("Type_EnterMegaDrop")
    else
      self:HideNormalBtn("Type_EnterMegaDrop")
      self:HideNormalBtn("Type_LeaveMegaDrop")
      self:HideNormalBtn("Type_LaunchMegaDrop")
    end
  else
    self:SetBtnVisibleFlag(UEnums.ESlateVisibility.SelfHitTestInvisible, "GridPanel_DriveAndGetIn", "DriveAndGetInBase")
    self:HideNormalBtn("Type_EnterMegaDrop")
    self:HideNormalBtn("Type_LeaveMegaDrop")
    self:HideNormalBtn("Type_LaunchMegaDrop")
    self:HideNormalBtn("Type_ApplyDrive")
    self:HideNormalBtn("Type_DriverEnter")
    self:HideNormalBtn("Type_BikeEnter")
    self:HideNormalBtn("Type_PassengerEnter")
    self:HideNormalBtn("Type_BikePick")
    self:CheckColdSkillBtn()
    local bIsBike = VehicleType == ESTExtraVehicleType.VT_Bike_WithRack or VehicleType == ESTExtraVehicleType.VT_Bike
    local bNotShowDriveBtnType = VehicleType == ESTExtraVehicleType.VT_SnowBall
    if not bIsBike and not bNotShowDriveBtnType and bHasDriversSeat then
      if bCanDrive then
        self:ShowNormalBtn("Type_DriverEnter")
      elseif not bExclusive then
        self:ShowNormalBtn("Type_ApplyDrive")
      end
    end
    if bIsBike then
      self:HideNormalBtn("Type_DriverEnter")
      self:HideNormalBtn("Type_ApplyDrive")
      if bHasDriversSeat and bCanDrive then
        self:ShowNormalBtn("Type_BikeEnter")
      end
    end
    if bHasPsgersSeat then
      self:ShowNormalBtn("Type_PassengerEnter")
    end
    if bCanPickable then
      self:ShowNormalBtn("Type_BikePick")
    end
  end
  self:InvalidateLayoutCache(3, 0.1)
end
function BasicSkillsMenuBP:HideEnterVehicleButtons()
  if not self.UIRoot or not self.UIRoot.GridPanel_DriveAndGetIn then
    print(bWriteLog and "BasicSkillsMenuBP:HideEnterVehicleButtons not self.UIRoot or not self.UIRoot.GridPanel_DriveAndGetIn")
    return
  end
  self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "GridPanel_DriveAndGetIn", "DriveAndGetInBase")
  self:HideNormalBtn("Type_BikePick")
  self:HideNormalBtn("Type_PassengerEnter")
  self:HideNormalBtn("Type_DriverEnter")
  self:HideNormalBtn("Type_ApplyDrive")
  self:HideNormalBtn("Type_BikeEnter")
  local ESTExtraVehicleType = import("ESTExtraVehicleType")
  local VehicleType = self:GetCurrentVehicleType()
  if VehicleType == ESTExtraVehicleType.VT_MegaDrop then
    self:ShowNormalBtn("Type_LeaveMegaDrop")
    self:ShowNormalBtn("Type_LaunchMegaDrop")
  else
    self:HideNormalBtn("Type_EnterMegaDrop")
    self:HideNormalBtn("Type_LeaveMegaDrop")
    self:HideNormalBtn("Type_LaunchMegaDrop")
    self:CheckColdBtn()
  end
end
function BasicSkillsMenuBP:ShowDoorBtnPanel()
  self.UIRoot.GridPanel_Door:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.CanvasPanel_InteractibleObject:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:CheckGridPanelDoorHide()
  self:CheckColdBtn()
end
function BasicSkillsMenuBP:HideDoorBtnPanel()
  self.UIRoot.GridPanel_Door:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_InteractibleObject:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:CheckColdBtn()
end
function BasicSkillsMenuBP:SwitchDoorButtonVisibility(bShow)
  if not self.UIRoot then
    print(bWriteLog and "BasicSkillsMenuBP:SwitchDoorButtonVisibility -self.UIRoot is nil")
    return
  end
  if bShow then
    self.UIRoot.Button_Door:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Button_PullDoor:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Button_PushDoor:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.WidgetSwitcher_Door:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Button_Door:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_PullDoor:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_PushDoor:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_Door:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BasicSkillsMenuBP:UpdateDoorBtn(_, _, Type, AutoMode, NewDoor)
  self.  self.CommonBtn  local ECommonBtn = UEnums.ECommonBtn
  if self.CommonBtnType == ECommonBtn.None then
    self:CheckGridPanelDoorHide()
    self:SwitchDoorButtonVisibility(false)
    self.UIRoot.Button_AutoDoor:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:CheckColdBtn()
    return
  elseif self.CommonBtnType == ECommonBtn.OpenDoorIn or self.CommonBtnType == ECommonBtn.OpenDoorOut then
    self.UIRoot.Image_Door:SetBrushFromPathAsync(self.InteractTypes.Type_OpenDoor.IconPath, false)
    self.UIRoot.TextBlock_Door:SetText(LocUtil.GetLocalizeResStr(self.InteractTypes.Type_OpenDoor.TextID))
    self:SwitchDoorButtonVisibility(true)
  elseif self.CommonBtnType == ECommonBtn.CloseDoor then
    self.UIRoot.Image_Door:SetBrushFromPathAsync(self.InteractTypes.Type_CloseDoor.IconPath, false)
    self.UIRoot.TextBlock_Door:SetText(LocUtil.GetLocalizeResStr(self.InteractTypes.Type_CloseDoor.TextID))
    self:SwitchDoorButtonVisibility(true)
  end
  if self:CanShowDoorPanel() then
    print(bWriteLog and "BasicSkillsMenuBP:UpdateDoorBtn Show, NewDoor = " .. tostring(NewDoor))
    self.UIRoot.GridPanel_Door:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_InteractibleObject:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    print(bWriteLog and "BasicSkillsMenuBP:UpdateDoorBtn Hide, NewDoor = " .. tostring(NewDoor))
    self.UIRoot.GridPanel_Door:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_InteractibleObject:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.OpenDoorMode = AutoMode
  if self.OpenDoorMode == 0 then
    self.UIRoot.Button_AutoDoor:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif self.OpenDoorMode == 1 then
    self.UIRoot.TextBlock_BtnName:SetText(LocUtil.GetLocalizeResStr(33864))
    self.UIRoot.Button_AutoDoor:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  elseif self.OpenDoorMode == 2 then
    self.UIRoot.TextBlock_BtnName:SetText(LocUtil.GetLocalizeResStr(33865))
    self.UIRoot.Button_AutoDoor:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  self:CheckColdBtn()
end
function BasicSkillsMenuBP:CheckShowInPhotographer(ButtonType, bOperation)
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if not PhotoGrapherSubSystem then
    print(bWriteLog and "BasicSkillsMenuBP:IsShowInPhotographer PhotoGrapherSubSystem is nil")
    return true
  end
  if PhotoGrapherSubSystem.bIsPhotoGrapherMode then
    if bOperation then
      if ButtonType ~= "Type_InteractiveComponent" and not PhotoGrapherSubSystem:CheckBasicSkillButtonState(ButtonType) then
        print(bWriteLog and "BasicSkillsMenuBP:CheckShowInPhotographer 1")
        return false
      end
    elseif not PhotoGrapherSubSystem:CheckBasicSkillButtonState(ButtonType) then
      print(bWriteLog and "BasicSkillsMenuBP:CheckShowInPhotographer 2")
      return false
    end
  end
  return true
end
function BasicSkillsMenuBP:HideButtonEnterSelifeMode()
  print(bWriteLog and "BasicSkillsMenuBP:HideButtonEnterSelifeMode")
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if not PhotoGrapherSubSystem then
    print(bWriteLog and "BasicSkillsMenuBP:HideButtonEnterSelifeMode PhotoGrapherSubSystem is nil")
    return true
  end
  if self.CurrentInteractItemDataMap then
    for Key, ItemData in pairs(self.CurrentInteractItemDataMap) do
      if not PhotoGrapherSubSystem:CheckBasicSkillButtonState(ItemData.Type) then
        self:UpdateNormalButton(ItemData.Type)
      end
    end
    for ButtonType, _ in pairs(self.CurrentOperationsTypes) do
      if not PhotoGrapherSubSystem:CheckBasicSkillButtonState(ButtonType) and ButtonType ~= "Type_InteractiveComponent" then
        self:UpdateNormalButton(ButtonType)
      end
    end
  end
end
function BasicSkillsMenuBP:CheckMechaDanceButton(InCurrentClosestVehicle)
  if not slua.isValid(InCurrentClosestVehicle) then
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  local ESTExtraVehicleType = import("ESTExtraVehicleType")
  if InCurrentClosestVehicle.VehicleType ~= ESTExtraVehicleType.VT_MechaVehicle then
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  if not InCurrentClosestVehicle:HasCombined() then
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  if not InCurrentClosestVehicle.bSkipDanceCheck then
    local ThemeTaskFeature = PlayerState.ThemeTaskFeature
    if ThemeTaskFeature == nil or ThemeTaskFeature.GetDanceRewardState == nil or not ThemeTaskFeature:GetDanceRewardState() then
      self:HideNormalBtn("Type_MechaDance")
      return
    end
  end
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  local VehicleSeats = InCurrentClosestVehicle.VehicleSeats
  if not slua.isValid(VehicleSeats) then
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  local bHasDriversSeat = false
  if slua.isValid(VehicleSeats) then
    bHasDriversSeat = VehicleSeats:IsSeatAvailable(ESTExtraVehicleSeatType.ESeatType_DriversSeat)
  end
  local bCanDrive = self:CanDriveVehicle(InCurrentClosestVehicle, PlayerCharacter)
  if not bCanDrive or not bHasDriversSeat then
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  self:ShowNormalBtn("Type_MechaDance")
end
function BasicSkillsMenuBP:CheckPandaDanceButton(InCurrentClosestVehicle)
  if not slua.isValid(InCurrentClosestVehicle) then
    self:HideNormalBtn("Type_PandaDance")
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    self:HideNormalBtn("Type_PandaDance")
    return
  end
  local ESTExtraVehicleType = import("ESTExtraVehicleType")
  if InCurrentClosestVehicle.VehicleType ~= ESTExtraVehicleType.VT_Panda then
    self:HideNormalBtn("Type_PandaDance")
    return
  end
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    self:HideNormalBtn("Type_PandaDance")
    return
  end
  self:ShowNormalBtn("Type_PandaDance")
end