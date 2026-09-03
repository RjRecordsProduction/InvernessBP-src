local adapter_gyroscope = {}
function OnRotationRateGyroscope(deltaX, deltaY, deltaZ)
  if deltaX == 0 and deltaX == 0 and deltaX == 0 then
    return
  end
  EventSystem:postEvent(EVENTTYPE_GYROSCOPE, EVENTID_GYROSCOPE_INPUT, deltaX, deltaY, deltaZ)
end
return adapter_gyroscope