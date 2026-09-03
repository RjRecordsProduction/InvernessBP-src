local logic_rank_component = {}
function logic_rank_component.IsSegmentStarSwitchOpen()
  local switch = false
  if DataMgr and DataMgr.isSeasonStarOpen then
    switch = true
  end
  log(bWriteLog and "logic_rank_component.IsSegmentStarSwitchOpen switch = " .. tostring(switch))
  return switch
end
function logic_rank_component.IsSegmentTitleSwitchOpen()
  local switch = false
  if DataMgr and DataMgr.isHsegmentTitleOpen then
    switch = true
  end
  log(bWriteLog and "logic_rank_component.IsSegmentTitleSwitchOpen switch = " .. tostring(switch))
  return switch
end
return logic_rank_component