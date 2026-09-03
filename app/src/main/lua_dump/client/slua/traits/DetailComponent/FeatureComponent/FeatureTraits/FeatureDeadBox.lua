local FeatureDeadBox = {}
local Trait = require("common.trait")
local TFeatureDeadBox = Trait(Trait.TraitPrototype, nil, FeatureDeadBox)
function FeatureDeadBox:PlayDeadBox(data)
  log(bWriteLog and "[edward][store_feature_component] PlayDeadBox")
  if self.deadBoxHandler then
    return
  end
  self:StopAllFeature()
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_HIDE_VIEW_COMPONENT, false)
  self.deadBoxHandler = self:CreateDeadBox(data)
end
function FeatureDeadBox:PlayDeadShow(data)
  log(bWriteLog and "[edward][store_feature_component] PlayDeadShow")
  if self.deadShowBoxHandler then
    self.deadShowBoxHandler:Destroy()
    self.deadShowBoxHandler = nil
  end
  self:StopAllFeature()
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_HIDE_VIEW_COMPONENT, false)
  self.deadShowBoxHandler = self:CreateDeadBox(data)
end
function FeatureDeadBox:CreateDeadBox(data)
  local isResExist = true
  local path = data.config.DeadBox
  local pak_util = require("client.common.pak_util")
  if path ~= "" and not pak_util.IsFileExist(path) then
    log(bWriteLog and "[tinghaohu] StoreDetail:PlayDeadBox. DeadBox res is not exist.")
    path = "/Game/Res/IG0170/Arts_PlayerBluePrints/Weapon/DeathBox/Ammo_DropBox.Ammo_DropBox_C"
    isResExist = false
  end
  local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  local SpawnLocation = ConstAvatarDislay.GetSpawnLocationByDeadBox(self.curScene)
  local SpawnRotation = ConstAvatarDislay.GetSpawnRotationByDeadBox(path)
  local deadBox = LobbySceneManager.CreateSceneExtraModel(path, SpawnLocation, SpawnRotation)
  if deadBox then
    if data.config.DeadBoxScale ~= 0 and isResExist then
      log(bWriteLog and "StoreDetail:PlayDeadBox, deadBoxScale = " .. tostring(data.config.DeadBoxScale))
      deadBox:SetScale(data.config.DeadBoxScale, data.config.DeadBoxScale, data.config.DeadBoxScale, 100)
    end
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    ModelDisplayer.Hide()
    return deadBox
  else
    return nil
  end
end
function FeatureDeadBox:RestoreDeadBox(close)
  log(bWriteLog and "[edward][store_feature_component] RestoreDeadBox")
  self:RemoveAllFeatureTimer()
  if self.deadBoxHandler then
    self.deadBoxHandler:Destroy()
    self.deadBoxHandler = nil
    if not close then
      local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
      ModelDisplayer.Show()
      self:SetWeaponAutoRotate()
    end
    EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_HIDE_VIEW_COMPONENT, true)
  end
end
function FeatureDeadBox:RestoreDeadShow(close)
  log(bWriteLog and "[edward][store_feature_component] RestoreDeadBox")
  self:RemoveAllFeatureTimer()
  if self.deadShowBoxHandler then
    self.deadShowBoxHandler:Destroy()
    self.deadShowBoxHandler = nil
    if not close then
      local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
      ModelDisplayer.Show()
      self:SetWeaponAutoRotate()
    end
    EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_HIDE_VIEW_COMPONENT, true)
  end
end
return TFeatureDeadBox