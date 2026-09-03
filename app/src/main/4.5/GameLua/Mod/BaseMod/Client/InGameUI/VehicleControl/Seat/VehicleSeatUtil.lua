local EVHSeatGUIType = import("EVHSeatGUIType")
local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
local VehicleSeatComponentClass = import("VehicleSeatComponent")
local TableUtil = require("common.table_util")
local Visible = UEnums.ESlateVisibility.Visible
local Collapsed = UEnums.ESlateVisibility.Collapsed
local HitTestInvisible = UEnums.ESlateVisibility.HitTestInvisible
local SelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
local SeatGUITypeForColorMap = {
  [EVHSeatGUIType.EVHSeatGUIType_NoSeat] = FLinearColor(0.0, 0.0, 0.0, 0.0),
  [EVHSeatGUIType.EVHSeatGUIType_Empty] = FLinearColor(0.322917, 0.322917, 0.322917, 0.65),
  [EVHSeatGUIType.EVHSeatGUIType_Other] = FLinearColor(1.0, 1.0, 1.0, 1.0),
  [EVHSeatGUIType.EVHSeatGUIType_Self] = FLinearColor(0.991102, 0.396755, 0.039546, 1.0)
}
local VehicleSeatUtil = {}
function VehicleSeatUtil.UpdateGUISeats(VehicleUserComponent, Image_SeatBGs, bIsCollapsedSeatBGParent, Image_SeatTags, RealIndexMap)
  local CurrentRealSeatIndex = -1
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleSeatUtil:UpdateGUISeats VehicleUserComponent nil")
    return CurrentRealSeatIndex
  end
  local Vehicle = VehicleUserComponent.Vehicle
  if not slua.isValid(Vehicle) then
    print(bWriteLog and "VehicleSeatUtil:UpdateGUISeats Vehicle nil")
    return CurrentRealSeatIndex
  end
  local VehicleSeatComponent = Vehicle:GetComponentByClass(VehicleSeatComponentClass)
  if not slua.isValid(VehicleSeatComponent) then
    print(bWriteLog and "VehicleSeatUtil:UpdateGUISeats VehicleSeatComponent nil")
    return CurrentRealSeatIndex
  end
  print(bWriteLog and "VehicleSeatUtil:UpdateGUISeats VehicleSeatComponent " .. tostring(VehicleUserComponent.Vehicle.VehicleType))
  local SeatGUITypes = VehicleSeatComponent.SeatGUITypes
  local MaxInUseSeatGUIIndex = VehicleSeatComponent.MaxInUseSeatGUIIndex
  local Seats = VehicleSeatComponent.Seats
  if RealIndexMap then
    TableUtil.Clear(RealIndexMap)
  end
  local RealIndex = 0
  for Index, Value in ipairs(Image_SeatBGs) do
    if Index <= MaxInUseSeatGUIIndex + 1 then
      Value:SetWidgetVisibility(HitTestInvisible)
      local SetGUIType = SeatGUITypes:Get(Index - 1)
      local Color = SeatGUITypeForColorMap[SetGUIType]
      if Color then
        Value:SetColorAndOpacity(Color)
      end
      if SetGUIType == EVHSeatGUIType.EVHSeatGUIType_Self then
        CurrentRealSeatIndex = RealIndex
      end
      if RealIndexMap and SetGUIType ~= EVHSeatGUIType.EVHSeatGUIType_NoSeat then
        RealIndexMap[Index] = RealIndex
        RealIndex = RealIndex + 1
      end
      local PanelWidget = Value:GetParent()
      if PanelWidget.OnClicked then
        PanelWidget:SetWidgetVisibility(Visible)
      else
        PanelWidget:SetWidgetVisibility(SelfHitTestInvisible)
      end
    elseif bIsCollapsedSeatBGParent then
      Value:GetParent():SetWidgetVisibility(Collapsed)
    else
      Value:SetWidgetVisibility(Collapsed)
    end
  end
  for Index, Value in ipairs(Image_SeatTags) do
    Value:GetParent():SetWidgetVisibility(Collapsed)
  end
  for _, SeatConfig in pairs(Seats) do
    if SeatConfig.SeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat or SeatConfig.bEnableVehicleWeapon then
      local PanelWidget = Image_SeatTags[SeatConfig.GUIDisplayIndex + 1]
      if PanelWidget then
        PanelWidget:GetParent():SetWidgetVisibility(SelfHitTestInvisible)
      end
    end
  end
  return CurrentRealSeatIndex
end
return VehicleSeatUtil