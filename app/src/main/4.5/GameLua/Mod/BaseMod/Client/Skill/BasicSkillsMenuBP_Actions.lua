local BasicSkillsMenuBP = require("GameLua.Mod.BaseMod.Client.Skill.BasicSkillsMenuBP_Config")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function BasicSkillsMenuBP:Action_InteractiveComponent(Param, ExtraParam)
  local Component = Param and Param.Component
  if Component and (type(Component) == "table" or slua.isValid(Component)) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_InteractiveComponent, Component = " .. tostring(Component))
    if Component.bAllowWhenCoolDown == true and Component:IsCoolingDown() == true and Component:GetCoolDownLeftTimeForShow() > 0 and 0 < Component.TipsIdWhenClickedInCoolDown then
      local CanShowCoolingDownTips = false
      if Param.LastShowCoolingDownTipsTime == nil then
        CanShowCoolingDownTips = true
        Param.LastShowCoolingDownTipsTime = os.time()
      else
        local CurrentTime = os.time()
        if CurrentTime >= Param.LastShowCoolingDownTipsTime + 1 then
          CanShowCoolingDownTips = true
          Param.LastShowCoolingDownTipsTime = CurrentTime
        elseif CurrentTime < Param.LastShowCoolingDownTipsTime then
          CanShowCoolingDownTips = true
          Param.LastShowCoolingDownTipsTime = CurrentTime
        end
      end
      if CanShowCoolingDownTips == true then
        local LeftTime = Component:GetCoolDownLeftTimeForShow()
        IngameTipsTools.BattleNormalTipsByTextID(Component.TipsIdWhenClickedInCoolDown, tostring(LeftTime))
      else
        print(bWriteLog and "BasicSkillsMenuBP:Action_InteractiveComponent, CanShowCoolingDownTips = false")
      end
      return
    end
    if Component.GetOwner then
      local owner = Component:GetOwner()
      if owner and slua.isValid(owner) then
        local GameplayStatics = import("GameplayStatics")
        local playerController = GameplayStatics.GetPlayerController(owner, 0)
        local character = playerController and playerController:GetPlayerCharacterSafety()
        if character and slua.isValid(character) then
          local OnePass = function()
            return owner:OnClientClickInteractiveButton(character, Component)
          end
          local Status, Result = pcall(OnePass)
          if Status then
            if Result == false then
              return
            end
          else
            local TwoPass = function()
              return Component:LuaOnClientClickInteractiveButton(character)
            end
            Status, Result = pcall(TwoPass)
            if Status and Result == false then
              return
            end
          end
          print(bWriteLog and "BasicSkillsMenuBP:Action_InteractiveComponent, ExtraParam = " .. tostring(ExtraParam))
          local RPCParam = Param.RPCParam or 0
          character:ServerRPCOnClickInteractiveButton(Component, ExtraParam or RPCParam)
        else
          print(bWriteLog and "BasicSkillsMenuBP:Action_InteractiveComponent, character = " .. tostring(character))
        end
      else
        print(bWriteLog and "BasicSkillsMenuBP:Action_InteractiveComponent, owner = " .. tostring(owner))
      end
    else
      print(bWriteLog and "BasicSkillsMenuBP:Action_InteractiveComponent, GetOwner = " .. tostring(Component.GetOwner))
    end
  else
    print(bWriteLog and "BasicSkillsMenuBP:Action_InteractiveComponent, HideNormalBtn, Component = ")
    self:HideNormalBtn("Type_InteractiveComponent", Param)
  end
end
function BasicSkillsMenuBP:Action_DesertDrinkMachine()
  print(bWriteLog and "BasicSkillsMenuBP:Action_DesertDrinkMachine")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_DesertDrinkMachine not slua.isValid(uPlayerCharacter)")
    return
  end
  if not uPlayerCharacter.MiniTreeTriggerServerLogic then
    return
  end
  uPlayerCharacter:MiniTreeTriggerServerLogic()
  local SkillManager = uPlayerCharacter:GetSkillManager()
  local UTSkillEventType = import("UTSkillEventType")
  SkillManager:TriggerEvent(1003005, UTSkillEventType.SET_SKILL_CAST)
  self:HideNormalBtn("Type_DesertDrinkMachine")
end
function BasicSkillsMenuBP:Action_Activity1()
  print(bWriteLog and "BasicSkillsMenuBP:Action_Activity1")
  self:Aciton_Activity(false)
end
function BasicSkillsMenuBP:Action_Activity2()
  print(bWriteLog and "BasicSkillsMenuBP:Action_Activity2")
  self:Aciton_Activity(true)
end
function BasicSkillsMenuBP:Action_ActivityCancel()
  print(bWriteLog and "BasicSkillsMenuBP:Action_ActivityCancel")
  self:Aciton_Activity(true)
end
function BasicSkillsMenuBP:Aciton_Activity(bCancel)
  print(bWriteLog and "BasicSkillsMenuBP:Aciton_Activity " .. tostring(bCancel))
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    if not bCancel then
      self:HideNormalBtn("Type_Activity1")
      self:HideNormalBtn("Type_Activity2")
    else
      self:HideNormalBtn("Type_ActivityCancel")
    end
    return
  end
end
function BasicSkillsMenuBP:Aciton_Activity1Hide()
  print(bWriteLog and "BasicSkillsMenuBP:Aciton_Activity1Hide")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "BasicSkillsMenuBP:Aciton_Activity1Hide not slua.isValid(uPlayerCharacter)")
    return
  end
  if not uPlayerCharacter:GetIsSelfieMode() then
    print(bWriteLog and "BasicSkillsMenuBP:Aciton_Activity1Hide not uPlayerCharacter:GetIsSelfieMode()")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  uPlayerController:CastUIMsg("UIMsg_SelfieShowTips", "ingame")
  uPlayerController:CastUIMsg("UIMsg_HideSelfieUI", "ingame")
end
function BasicSkillsMenuBP:Action_Activity1Show()
  print(bWriteLog and "BasicSkillsMenuBP:Action_Activity1Show")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    self:HideNormalBtn("Type_Activity1")
    return
  end
  if not self.CurrentInteractItemDataMap.Type_Activity1 then
    print(bWriteLog and "BasicSkillsMenuBP:Action_Activity1Show Fail")
    return
  end
  local ItemData = self.CurrentInteractItemDataMap.Type_Activity1
  local Item = self.LoopScrollBoxInteract:GetItemData(ItemData.Index)
  self.LoopScrollBoxInteract:RefreshItem(ItemData.Index, Item)
end
function BasicSkillsMenuBP:Action_Activity2Show()
  print(bWriteLog and "BasicSkillsMenuBP:Action_Activity2Show")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    self:HideNormalBtn("Type_Activity2")
    return
  end
  if not self.CurrentInteractItemDataMap.Type_Activity2 then
    print(bWriteLog and "BasicSkillsMenuBP:Action_Activity2Show Fail")
    return
  end
  local ItemData = self.CurrentInteractItemDataMap.Type_Activity2
  local Item = self.LoopScrollBoxInteract:GetItemData(ItemData.Index)
  self.LoopScrollBoxInteract:RefreshItem(ItemData.Index, Item)
end
function BasicSkillsMenuBP:Action_ActivityCancelShow()
  print(bWriteLog and "BasicSkillsMenuBP:Action_ActivityCancelShow")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    self:HideNormalBtn("Type_ActivityCancel")
    return
  end
  local ItemData = self.CurrentInteractItemDataMap.Type_ActivityCancel
  local Item = self.LoopScrollBoxInteract:GetItemData(ItemData.Index)
  self.LoopScrollBoxInteract:RefreshItem(ItemData.Index, Item)
end
function BasicSkillsMenuBP:Action_MVPStatueCelerbrate()
  print(bWriteLog and "BasicSkillsMenuBP:Action_MVPStatueCelerbrate")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_MVP_STATUE_CELEBRATE)
end
function BasicSkillsMenuBP:Action_EnterMegaDrop()
  print(bWriteLog and "BasicSkillsMenuBP:Action_EnterMegaDrop")
  local BP_VehicleUser = self:GetBP_VehicleUser()
  if not (slua.isValid(BP_VehicleUser) and slua.isValid(BP_VehicleUser.CurrentClosestVehicle)) or not slua.isValid(BP_VehicleUser.CurrentClosestVehicle.VehicleSeats) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_EnterMegaDrop Fail")
    return
  end
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  local IsSeatAvailable = BP_VehicleUser.CurrentClosestVehicle.VehicleSeats:IsSeatAvailable(ESTExtraVehicleSeatType.ESeatType_DriversSeat)
  BP_VehicleUser:EnterVehicle(IsSeatAvailable)
  self.MegaOperatorTimer = 0
end
function BasicSkillsMenuBP:Action_LeaveMegaDrop()
  print(bWriteLog and "BasicSkillsMenuBP:Action_LeaveMegaDrop")
  local bIsCanOperator = self:TryMegaOperator()
  if not bIsCanOperator then
    return
  end
  local BP_VehicleUser = self:GetBP_VehicleUser()
  if not slua.isValid(BP_VehicleUser) then
    return
  end
  BP_VehicleUser:ExitVehicle()
end
function BasicSkillsMenuBP:Action_LaunchMegaDrop()
  print(bWriteLog and "BasicSkillsMenuBP:Action_LaunchMegaDrop")
  local BP_VehicleUser = self:GetBP_VehicleUser()
  if not slua.isValid(BP_VehicleUser) or not slua.isValid(BP_VehicleUser.Vehicle) then
    return
  end
  local uERole = import("ENetRole")
  if BP_VehicleUser.Vehicle:GetRole() ~= uERole.ROLE_AutonomousProxy then
    return
  end
  local bIsCanOperator = self:TryMegaOperator()
  if bIsCanOperator then
    BP_VehicleUser:SetBoosting(true)
  end
end
function BasicSkillsMenuBP:Action_SnowBoard()
  print(bWriteLog and "BasicSkillsMenuBP:Action_SnowBoard")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_SnowBoard not slua.isValid(uPlayerCharacter)")
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local uBackpackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uPlayerCharacter)
  local ItemDefineID = FItemDefineID(5, 507001)
  uBackpackComp:ServerEnableItem(ItemDefineID, true)
end
function BasicSkillsMenuBP:Action_Surfing()
  print(bWriteLog and "BasicSkillsMenuBP:Action_Surfing")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_Surfing not slua.isValid(uPlayerController)")
    return
  end
  uPlayerController:CastUIMsg("UIMsg_SwitchSurfBoard", "ingame")
end
function BasicSkillsMenuBP:Action_OpenOrCloseDoor()
  print(bWriteLog and "BasicSkillsMenuBP:Action_OpenOrCloseDoor, NewDoor = " .. tostring(self.NewDoor))
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:OnPressedOpenAndCloseDoor not slua.isValid(uPlayerController)")
    return
  end
  if self.NewDoor ~= nil then
    self:Action_InteractiveComponent(self.NewDoor)
  else
    local BP_CommonBtn = uPlayerController.BP_CommonBtn
    if slua.isValid(BP_CommonBtn) then
      BP_CommonBtn:OnShowDoorButton(self.CommonBtnType, 0)
    end
  end
end
function BasicSkillsMenuBP:Action_PullDoor()
  print(bWriteLog and "BasicSkillsMenuBP:Action_PullDoor, NewDoor = " .. tostring(self.NewDoor))
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if self.NewDoor ~= nil then
    self:Action_InteractiveComponent(self.NewDoor, 1)
  else
    local BP_CommonBtn = uPlayerController.BP_CommonBtn
    if slua.isValid(BP_CommonBtn) then
      BP_CommonBtn:OnShowDoorButton(self.CommonBtnType, 1)
    end
  end
end
function BasicSkillsMenuBP:Action_PushDoor()
  print(bWriteLog and "BasicSkillsMenuBP:Action_PushDoor, NewDoor = " .. tostring(self.NewDoor))
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if self.NewDoor ~= nil then
    self:Action_InteractiveComponent(self.NewDoor, 0)
  else
    local BP_CommonBtn = uPlayerController.BP_CommonBtn
    if slua.isValid(BP_CommonBtn) then
      BP_CommonBtn:OnShowDoorButton(self.CommonBtnType, 0)
    end
  end
end
function BasicSkillsMenuBP:Action_DriverEnter()
  print(bWriteLog and "BasicSkillsMenuBP:Action_DriverEnter")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_DriverEnter Fail not slua.isValid(uPlayerController)")
    return
  end
  if uPlayerController.CheckCanEnterVehicle and not uPlayerController:CheckCanEnterVehicle() then
    print(bWriteLog and "BasicSkillsMenuBP:Action_DriverEnter not uPlayerController:CheckCanEnterVehicle()")
    return
  end
  if not (not self.UIRoot.GridPanel_DriveAndGetIn:GetVisibility() ~= UEnums.ESlateVisibility.SelfHitTestInvisible and self.CanEnterVehicle) or not self.bRacingCanEnterVehicle then
    print(bWriteLog and "BasicSkillsMenuBP:Action_DriverEnter Fail")
    return
  end
  local BP_VehicleUser = self:GetBP_VehicleUser()
  if not slua.isValid(BP_VehicleUser) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_DriverEnter Fail not slua.isValid(BP_VehicleUser)")
    return
  end
  if not self:JudgePlanPhWeddingCarCanEnter() then
    print(bWriteLog and "BasicSkillsMenuBP:Action_DriverEnter Fail not self:JudgePlanPhWeddingCarCanEnter()")
    ShowNotice(8180)
    return
  end
  BP_VehicleUser:EnterVehicle(true)
  uPlayerController:OnPlayerClickDriveBtn()
end
function BasicSkillsMenuBP:Action_ApplyDrive()
  print(bWriteLog and "BasicSkillsMenuBP:Action_ApplyDrive")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_ApplyDrive Fail not slua.isValid(uPlayerCharacter)")
    return
  end
  if not uPlayerCharacter:IsSwitchCoolingDownFinish() then
    print(bWriteLog and "BasicSkillsMenuBP:Action_ApplyDrive Fail not uPlayerCharacter:IsSwitchCoolingDownFinish()")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_ApplyDrive Fail not slua.isValid(uPlayerController)")
    return
  end
  local uVehicleUserComponent = uPlayerController:GetVehicleUserComp()
  if not slua.isValid(uVehicleUserComponent) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_ApplyDrive Fail not slua.isValid(uVehicleUserComponent)")
    return
  end
  EventSystem:postEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_APPLY_BORROW_VEHICLE, uVehicleUserComponent.CurrentClosestVehicle)
end
function BasicSkillsMenuBP:Action_PassengerEnterPreShow(Config, InteractiveConfig)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return Config
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComponent) then
    return Config
  end
  local CurrentClosestVehicle = VehicleUserComponent.CurrentClosestVehicle
  if not slua.isValid(CurrentClosestVehicle) then
    return Config
  end
  local TableUtil = require("common.table_util")
  local NewConfig = TableUtil.CopyTable(Config)
  if CurrentClosestVehicle.PassengerEnterShowTextID then
    NewConfig.TextID = CurrentClosestVehicle.PassengerEnterShowTextID
  end
  if CurrentClosestVehicle.PassengerEnterShowIconPath then
    NewConfig.IconPath = CurrentClosestVehicle.PassengerEnterShowIconPath
  end
  return NewConfig
end
function BasicSkillsMenuBP:Action_PassengerEnter()
  print(bWriteLog and "BasicSkillsMenuBP:Action_PassengerEnter")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PassengerEnter Fail not slua.isValid(uPlayerCharacter)")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PassengerEnter Fail not slua.isValid(uPlayerController)")
    return
  end
  if uPlayerController.CheckCanEnterVehicle and not uPlayerController:CheckCanEnterVehicle() then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PassengerEnter not uPlayerController:CheckCanEnterVehicle()")
    return
  end
  if not (not self.UIRoot.GridPanel_DriveAndGetIn:GetVisibility() ~= UEnums.ESlateVisibility.SelfHitTestInvisible and self.CanEnterVehicle) or not self.bRacingCanEnterVehicle then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PassengerEnter Fail. self.CanEnterVehicle " .. tostring(self.CanEnterVehicle) .. " self.bRacingCanEnterVehicle " .. tostring(self.bRacingCanEnterVehicle) .. " self.UIRoot.GridPanel_DriveAndGetIn:GetVisibility() " .. tostring(self.UIRoot.GridPanel_DriveAndGetIn:GetVisibility()))
    return
  end
  local BP_VehicleUser = self:GetBP_VehicleUser()
  if not slua.isValid(BP_VehicleUser) or not slua.isValid(BP_VehicleUser.CurrentClosestVehicle) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PassengerEnter Fail not slua.isValid(BP_VehicleUser) or not slua.isValid(BP_VehicleUser.CurrentClosestVehicle)")
    return
  end
  if not self:JudgePlanPhWeddingCarCanEnter() then
    print(bWriteLog and "BasicSkillsMenuBP:Action_DriverEnter Fail not self:JudgePlanPhWeddingCarCanEnter()")
    ShowNotice(8180)
    return
  end
  BP_VehicleUser:EnterVehicle(false)
end
function BasicSkillsMenuBP:Action_DriverEnterPreShow(Config, InteractiveConfig)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return Config
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComponent) then
    return Config
  end
  local CurrentClosestVehicle = VehicleUserComponent.CurrentClosestVehicle
  if not slua.isValid(CurrentClosestVehicle) then
    return Config
  end
  local TableUtil = require("common.table_util")
  local NewConfig = TableUtil.CopyTable(Config)
  if CurrentClosestVehicle.DriverEnterShowTextID then
    NewConfig.TextID = CurrentClosestVehicle.DriverEnterShowTextID
  end
  if CurrentClosestVehicle.DriverEnterShowIconPath then
    NewConfig.IconPath = CurrentClosestVehicle.DriverEnterShowIconPath
  end
  return NewConfig
end
function BasicSkillsMenuBP:Action_DriverEnterShow()
  print(bWriteLog and "BasicSkillsMenuBP:Action_DriverEnterShow")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PassengerEnter Fail not slua.isValid(uPlayerController)")
    return
  end
  uPlayerController:OnPlayerCanGetInVehicle(true)
end
function BasicSkillsMenuBP:Action_TireRepair()
  print(bWriteLog and "BasicSkillsMenuBP:Action_TireRepair")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_TireRepair Fail not slua.isValid(PlayerCharacter)")
    return
  end
  PlayerCharacter:TriggerEntrySkillWithID(1003018, true)
end
function BasicSkillsMenuBP:Action_PickupVehicle()
  print(bWriteLog and "BasicSkillsMenuBP:Action_PickupVehicle")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PickupVehicle Fail not slua.isValid(uPlayerCharacter)")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PickupVehicle Fail not slua.isValid(uPlayerController)")
    return
  end
  local BP_VehicleUser = self:GetBP_VehicleUser()
  if not slua.isValid(BP_VehicleUser) or not slua.isValid(BP_VehicleUser.CurrentClosestVehicle) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PassengerEnter Fail not slua.isValid(BP_VehicleUser) or not slua.isValid(BP_VehicleUser.CurrentClosestVehicle)")
    return
  end
  local VehiclePickableComponent_C = import("VehiclePickableComponent")
  local VehiclePickableComponent = BP_VehicleUser.CurrentClosestVehicle:GetComponentByClass(VehiclePickableComponent_C)
  if not Game:IsValid(VehiclePickableComponent) or not VehiclePickableComponent.bEnablePickupInClient then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PickupVehicle Fail not Game:IsValid(VehiclePickableComponent)")
    return
  end
  VehiclePickableComponent:PickupBy(uPlayerCharacter)
end
function BasicSkillsMenuBP:Action_UseHangGlider()
  print(bWriteLog and "BasicSkillsMenuBP:Action_UseHangGlider")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    local EPawnState = import("EPawnState")
    if uPlayerCharacter:AllowState(EPawnState.Slide, false) then
      uPlayerCharacter:TriggerEntrySkillWithID(1014414, not uPlayerCharacter:IsCastingSkillIDFix(1014414))
    else
      IngameTipsTools.BattleNormalTipsByTextID(512312)
    end
  end
end
function BasicSkillsMenuBP:Action_FollowEmote()
  print(bWriteLog and "BasicSkillsMenuBP:Action_FollowEmote")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    local PlayEmoteComp = uPlayerCharacter:GetPlayEmoteComponent()
    if PlayEmoteComp then
      PlayEmoteComp:OnFollowNearPlayerEmote()
      PlayEmoteComp:CheckNearPlayingEmote()
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTIP_ON_CLICK_FOLLOW_EMOTE)
    end
  end
end
function BasicSkillsMenuBP:Action_JoinCoopEmote()
  print(bWriteLog and "BasicSkillsMenuBP:Action_JoinCoopEmote")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.CoopEmotePCFeature then
    uPlayerController.CoopEmotePCFeature:OnClickJoinCoopEmote()
  end
end
function BasicSkillsMenuBP:Action_StoreSkate()
  print(bWriteLog and "BasicSkillsMenuBP:Action_StoreSkate")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.BuildSkateFeature then
    uPlayerCharacter.BuildSkateFeature:TryPickupVehicle()
  end
end
function BasicSkillsMenuBP:Action_StoreBlanket()
  print(bWriteLog and "BasicSkillsMenuBP:Action_StoreBlanket")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.BuildBlanketFeature then
    uPlayerCharacter.BuildBlanketFeature:TryPickupVehicle()
  end
end
function BasicSkillsMenuBP:Action_LeaveForwardEmote()
  print(bWriteLog and "BasicSkillsMenuBP:Action_LeaveForwardEmote")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    if uPlayerCharacter:IsCastingSkillIDFix(1014707) then
      local uSkillManagerComp = uPlayerCharacter:GetSkillManager()
      if slua.isValid(uSkillManagerComp) then
        uSkillManagerComp:TriggerStringEvent(1014707, "LeaveForwardEmote")
      end
    end
    if uPlayerCharacter:IsCastingSkillIDFix(1014708) then
      local uSkillManagerComp = uPlayerCharacter:GetSkillManager()
      if slua.isValid(uSkillManagerComp) then
        uSkillManagerComp:TriggerStringEvent(1014708, "LeaveForwardEmote")
      end
    end
  end
end
function BasicSkillsMenuBP:Action_MechaDance()
  print(bWriteLog and "BasicSkillsMenuBP:Action_MechaDance 0")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_MechaDance 1")
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  local VehicleUserComp = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComp) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_MechaDance 2")
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  local CurrentClosestVehicle = VehicleUserComp.CurrentClosestVehicle
  if not slua.isValid(CurrentClosestVehicle) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_MechaDance 3")
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  local ESTExtraVehicleType = import("ESTExtraVehicleType")
  if CurrentClosestVehicle.VehicleType ~= ESTExtraVehicleType.VT_MechaVehicle then
    print(bWriteLog and "BasicSkillsMenuBP:Action_MechaDance 4")
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  if not CurrentClosestVehicle:HasCombined() then
    print(bWriteLog and "BasicSkillsMenuBP:Action_MechaDance 5")
    self:HideNormalBtn("Type_MechaDance")
    return
  end
  if CurrentClosestVehicle.bMechaDancing then
    print(bWriteLog and "BasicSkillsMenuBP:Action_MechaDance 6")
    return
  end
  print(bWriteLog and "BasicSkillsMenuBP:Action_MechaDance 7")
  if PlayerController.Server_MakeMechaDance ~= nil then
    PlayerController:Server_MakeMechaDance(CurrentClosestVehicle, PlayerController:GetCurPawn())
  end
end
function BasicSkillsMenuBP:Action_PandaDance()
  print(bWriteLog and "BasicSkillsMenuBP:Action_PandaDance 0")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PandaDance 1")
    self:HideNormalBtn("Type_PandaDance")
    return
  end
  local VehicleUserComp = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComp) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PandaDance 2")
    self:HideNormalBtn("Type_PandaDance")
    return
  end
  local CurrentClosestVehicle = VehicleUserComp.CurrentClosestVehicle
  if not slua.isValid(CurrentClosestVehicle) then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PandaDance 3")
    self:HideNormalBtn("Type_PandaDance")
    return
  end
  local ESTExtraVehicleType = import("ESTExtraVehicleType")
  if CurrentClosestVehicle.VehicleType ~= ESTExtraVehicleType.VT_Panda then
    print(bWriteLog and "BasicSkillsMenuBP:Action_PandaDance 4")
    self:HideNormalBtn("Type_PandaDance")
    return
  end
  local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
  if CurrentClosestVehicle.VehicleShapeType == ESTExtraVehicleShapeType.VST_PandaBall then
    print(bWriteLog and string.format("BasicSkillsMenuBP:Action_PandaDance VehicleShapeType is VST_PandaBall"))
    self:HideNormalBtn("Type_PandaDance")
    return
  end
  print(bWriteLog and "BasicSkillsMenuBP:Action_PandaDance 7")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.SkillManager then
    if uPlayerCharacter:IsCastingSkillIDFix(1040002) or uPlayerCharacter:IsCastingSkillIDFix(1040003) then
      print(bWriteLog and "BasicSkillsMenuBP:Action_PandaDance IsCastingSkillIDFix 1040002")
      self:HideNormalBtn("Type_PandaDance")
      return
    end
    local PandaDanceSkillID = 1040024
    uPlayerCharacter.SkillManager:SetValueAsObject(PandaDanceSkillID, "PandaVehicle", CurrentClosestVehicle)
    uPlayerCharacter:TriggerEntrySkillWithParams(PandaDanceSkillID, {
      "PandaVehicle"
    }, true)
  end
end
function BasicSkillsMenuBP:Action_FeedHorse()
  print(bWriteLog and "BasicSkillsMenuBP:Action_FeedHorse")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    uPlayerCharacter:RPC_Server_TriggerEntryEventByID(1014674, true)
  end
end
function BasicSkillsMenuBP:Action_Broadcast()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTIP_ON_CLICK_BROADCAST)
end
function BasicSkillsMenuBP:Action_StoreUpload(Param)
  print(bWriteLog and "BasicSkillsMenuBP:Action_StoreUpload")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and slua.isValid(Param.StoreComponent) then
    uPlayerCharacter:ServerRPCOnClickInteractiveButton(Param.StoreComponent, -1)
  end
end
function BasicSkillsMenuBP:Action_StoreCamel()
  print(bWriteLog and "BasicSkillsMenuBP:Action_StoreCamel")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.StoreCamelFeature then
    uPlayerCharacter.StoreCamelFeature:TryPickupVehicle()
  end
end
function BasicSkillsMenuBP:Action_Execute()
  print(bWriteLog and "[Execute]BasicSkillsMenuBP:Action_Execute")
  if CGameState and CGameState.bIsCreativeWoW then
    print(bWriteLog and "[Execute]BasicSkillsMenuBP:Action_Execute aborted by CreativeWoW mode")
    return
  end
  local uPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPawn) then
    return
  end
  local EPawnState = import("EPawnState")
  local bIsInCarryBack = uPawn:HasState(EPawnState.CarryBack)
  local bIsInCarryBox = uPawn.CarryDeadBoxFeature and slua.isValid(uPawn.CarryDeadBoxFeature.AttachedDeadBox)
  if bIsInCarryBack or bIsInCarryBox then
    print(bWriteLog and "[Execute]BasicSkillsMenuBP:Action_Execute aborted by CarryBack/CarryBox state")
    return
  end
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local EXECUTE_SKILL_ID = 1015060
  local BB_KEY_EXECUTE_TARGET = "ExecuteTarget"
  local BB_KEY_EXECUTE_PLAN_ID = "ExecutePlanID"
  local uRescueComp = uPawn.RescueOtherComponent
  if not slua.isValid(uRescueComp) then
    print(bWriteLog and "[Execute]BasicSkillsMenuBP:Action_Execute RescueOtherComponent invalid")
    return
  end
  local uTarget = uRescueComp.ExecuteWho
  if not slua.isValid(uTarget) then
    print(bWriteLog and "[Execute]BasicSkillsMenuBP:Action_Execute no execute target available")
    return
  end
  local PlanID = XSuitUtil:GetEquippedExecutePlanID(uPawn)
  if PlanID <= 0 then
    print(bWriteLog and "[Execute]BasicSkillsMenuBP:Action_Execute no equipped execute plan, abort")
    self:HideNormalBtn("Type_Execute")
    return
  end
  local uSkillMgr = uPawn:GetSkillManager()
  if not slua.isValid(uSkillMgr) then
    print(bWriteLog and "[Execute]BasicSkillsMenuBP:Action_Execute SkillManager invalid")
    return
  end
  uSkillMgr:SetValueAsWeakObject(EXECUTE_SKILL_ID, BB_KEY_EXECUTE_TARGET, uTarget)
  uSkillMgr:SetValueAsInt(EXECUTE_SKILL_ID, BB_KEY_EXECUTE_PLAN_ID, PlanID)
  uPawn:TriggerEntrySkillWithParams(EXECUTE_SKILL_ID, {BB_KEY_EXECUTE_TARGET, BB_KEY_EXECUTE_PLAN_ID}, true)
  print(bWriteLog and string.format("[Execute]BasicSkillsMenuBP:Action_Execute SkillID=%d Target=%s PlanID=%d", EXECUTE_SKILL_ID, tostring(uTarget), PlanID))
  self:HideNormalBtn("Type_Execute")
end
function BasicSkillsMenuBP:JudgePlanPhWeddingCarCanEnter()
  print(bWriteLog and "BasicSkillsMenuBP:Action_CheckCanEnterVehicle")
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  if not logic_home_entry:IsPlanPHMode() then
    return true
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return true
  end
  local uVehicleUserComponent = uPlayerController:GetVehicleUserComp()
  if not slua.isValid(uVehicleUserComponent) then
    return true
  end
  local CurrentClosestVehicle = uVehicleUserComponent.CurrentClosestVehicle
  if not slua.isValid(CurrentClosestVehicle) then
    return true
  end
  return true
end