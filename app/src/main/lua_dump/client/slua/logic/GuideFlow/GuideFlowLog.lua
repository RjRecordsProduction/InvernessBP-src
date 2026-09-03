local GuideFlowLog = {bLog = false}
function GuideFlowLog.log(str)
  if GuideFlowLog.bLog then
    log(bWriteLog and str)
  end
end
function GuideFlowLog.log_tree(tag, val)
  if GuideFlowLog.bLog then
    log_tree(tag, val)
  end
end
return GuideFlowLog