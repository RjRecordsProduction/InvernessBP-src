local performance_util = {
  AvatarDefaultTickInterval = 0.0,
  AvatarDisableTickInterval = 1.0,
  _switch = true
}
local uParticleSystemComponent = import("/Script/Engine.ParticleSystemComponent")
function performance_util:SetTickSwitch(switch)
  log(bWriteLog and "performance_util:SetTickSwitch switch = " .. tostring(switch))
  performance_util._end
function performance_util:SetActorTickRecursively(actor, bTick, bIgnoreSelf)
  log(bWriteLog and "performance_util:SetActorTickRecursively actor = " .. tostring(actor) .. " bTick = " .. tostring(bTick) .. " bIgnoreSelf = " .. tostring(bIgnoreSelf))
  if not performance_util._switch then
    log(bWriteLog and "performance_util:SetActorTickRecursively switch = false")
    return
  end
  if not slua.isValid(actor) then
    return
  end
  if not bIgnoreSelf then
    if actor.SetActorTickInterval then
      actor:SetActorTickInterval(0)
    end
    if actor.SetActorTickEnabled then
      actor:SetActorTickEnabled(bTick)
    end
  end
  if actor and actor.GetAttachedActors then
    local OutActors = actor:GetAttachedActors(nil)
    for _, OutActor in pairs(OutActors) do
      if OutActor and slua.isValid(OutActor) then
        performance_util:SetActorTickRecursively(OutActor, bTick)
      end
    end
  end
end
function performance_util:SetActorTickIntervalRecursively(actor, tickInterval)
  log(bWriteLog and "performance_util:SetActorTickIntervalRecursively actor = " .. tostring(actor) .. " tickInterval = " .. tostring(tickInterval))
  if not slua.isValid(actor) or not tickInterval then
    return
  end
  if actor.SetActorTickInterval then
    log(bWriteLog and string.format("performance_util:SetActorTickIntervalRecursively actor = %s tickInterval %f -> %f", tostring(actor), actor:GetActorTickInterval(), tickInterval))
    actor:SetActorTickInterval(tickInterval)
  end
  if actor and actor.GetAttachedActors then
    local OutActors = actor:GetAttachedActors(nil)
    for _, OutActor in pairs(OutActors) do
      if OutActor and slua.isValid(OutActor) then
        performance_util:SetActorTickIntervalRecursively(OutActor, tickInterval)
      end
    end
  end
end
function performance_util:SetComponentTickRecursively(Component, bTick)
  log(bWriteLog and "performance_util:SetComponentTickRecursively Component = " .. tostring(Component) .. " bTick = " .. tostring(bTick))
  if not performance_util._switch then
    log(bWriteLog and "performance_util:SetComponentTickRecursively switch = false")
    return
  end
  if not slua.isValid(Component) then
    return
  end
  if Component.SetCanRenderWhileSeeking then
    log(bWriteLog and "performance_util:SetComponentTickRecursively UNiagaraComponent")
    return
  end
  if Game:IsClassOf(Component, uParticleSystemComponent) then
    log(bWriteLog and "performance_util:SetComponentTickRecursively ParticleSystemComponent skip")
    return
  end
  if Component.SetComponentTickInterval then
    Component:SetComponentTickInterval(0)
  end
  if Component.SetComponentTickEnabled then
    Component:SetComponentTickEnabled(bTick)
  end
  if Component.GetNumChildrenComponents then
    local numChildrenComponents = Component:GetNumChildrenComponents()
    if numChildrenComponents == 0 then
      return
    end
  end
  if Component.GetChildrenComponents then
    local uComponentArray = Component:GetChildrenComponents(false, nil)
    for _, ChildComponent in pairs(uComponentArray) do
      if ChildComponent and slua.isValid(ChildComponent) then
        performance_util:SetComponentTickRecursively(ChildComponent, bTick)
      end
    end
  end
end
function performance_util:SetComponentTickRecursivelyWithClass(component, componentClass, bTick)
  log(bWriteLog and "performance_util:SetComponentTickRecursivelyWithClass component = " .. tostring(component) .. " componentClass = " .. tostring(componentClass) .. " bTick = " .. tostring(bTick))
  if not performance_util._switch then
    log(bWriteLog and "performance_util:SetComponentTickRecursivelyWithClass switch = false")
    return
  end
  if not slua.isValid(component) or not componentClass then
    log(bWriteLog and "performance_util:SetComponentTickRecursivelyWithClass component or componentClass is nil")
    return
  end
  if Game:IsClassOf(component, componentClass) then
    component:SetComponentTickInterval(0)
    component:SetComponentTickEnabled(bTick)
  end
  if component.GetNumChildrenComponents then
    local numChildrenComponents = component:GetNumChildrenComponents()
    if numChildrenComponents == 0 then
      return
    end
  end
  if component.GetChildrenComponents then
    local uComponentArray = component:GetChildrenComponents(false, nil)
    for _, childComponent in pairs(uComponentArray) do
      if childComponent and slua.isValid(childComponent) then
        performance_util:SetComponentTickRecursivelyWithClass(childComponent, componentClass, bTick)
      end
    end
  end
end
function performance_util:SetComponentTickIntervalRecursively(component, tickInterval)
  log(bWriteLog and "performance_util:SetComponentTickIntervalRecursively component = " .. tostring(component) .. " tickInterval = " .. tostring(tickInterval))
  if not slua.isValid(component) or not tickInterval then
    return
  end
  if component.SetComponentTickInterval then
    log(bWriteLog and string.format("performance_util:SetComponentTickIntervalRecursively component = %s tickInterval %f -> %f", tostring(component), component:GetComponentTickInterval(), tickInterval))
    component:SetComponentTickInterval(tickInterval)
  end
  if component.GetNumChildrenComponents then
    local numChildrenComponents = component:GetNumChildrenComponents()
    if numChildrenComponents == 0 then
      return
    end
  end
  if component.GetChildrenComponents then
    local uComponentArray = component:GetChildrenComponents(false, nil)
    for _, ChildComponent in pairs(uComponentArray) do
      if ChildComponent and slua.isValid(ChildComponent) then
        performance_util:SetComponentTickIntervalRecursively(ChildComponent, tickInterval)
      end
    end
  end
end
function performance_util:SetAvatarTick(avatar, bTick, bIgnoreSelf, bSetForcedLOD)
  log(bWriteLog and "performance_util:SetAvatarTick avatar = " .. tostring(avatar) .. " bTick = " .. tostring(bTick) .. " bIgnoreSelf = " .. tostring(bIgnoreSelf))
  if avatar == nil then
    return
  end
  if not bTick then
    if avatar.StopAction then
      avatar:StopAction()
    end
    if avatar.GetPet then
      local pet = avatar:GetPet()
      if pet and pet.StopAction then
        pet:StopAction()
      end
    end
  end
  if avatar.GetModel then
    local lobbyPawn = avatar:GetModel()
    if slua.isValid(lobbyPawn) and lobbyPawn.SetLobbyPawnTick and lobbyPawn.bAllMeshLoaded then
      if bSetForcedLOD then
        lobbyPawn:SwitchMeshToMinLOD(not bTick)
      end
      if not bTick and bSetForcedLOD then
        local timer_tick = require("common.time_ticker")
        timer_tick.AddTimer(0.1, function()
          if slua.isValid(lobbyPawn) then
            lobbyPawn:SetLobbyPawnTick(bTick, bIgnoreSelf)
          end
        end)
      else
        lobbyPawn:SetLobbyPawnTick(bTick, bIgnoreSelf)
      end
    end
  end
end
function performance_util:SetAvatarTickInterval(avatar, tickInterval)
  log(bWriteLog and "performance_util:SetAvatarTickInterval avatar = " .. tostring(avatar) .. " tickInterval = " .. tostring(tickInterval))
  if avatar == nil then
    return
  end
  if 0 < tickInterval then
    if avatar.StopAction then
      avatar:StopAction()
    end
    if avatar.GetPet then
      local pet = avatar:GetPet()
      if pet and pet.StopAction then
        pet:StopAction()
      end
    end
  end
  if avatar.GetModel then
    local lobbyPawn = avatar:GetModel()
    if slua.isValid(lobbyPawn) and lobbyPawn.SetLobbyPawnTickInterval then
      lobbyPawn:SetLobbyPawnTickInterval(tickInterval)
    end
  end
end
function performance_util:SetVehicleTick(vehicles, bTick)
  log(bWriteLog and "performance_util:SetVehicleTick bTick = " .. tostring(bTick))
  if vehicles == nil or not next(vehicles) then
    return
  end
  for _, showActor in pairs(vehicles) do
    if slua.isValid(showActor) then
      if showActor.SetActorTickEnabled then
        showActor:SetActorTickEnabled(bTick)
      end
      local SubActor = showActor.SubActor
      if slua.isValid(SubActor) and SubActor.SetVehicleTick then
        SubActor:SetVehicleTick(bTick)
      end
    end
  end
end
return performance_util