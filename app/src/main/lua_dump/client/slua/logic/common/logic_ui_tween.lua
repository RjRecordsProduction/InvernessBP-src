local TRAIL_DIF = 2
local logic_ui_tween = {}
function logic_ui_tween.GetInstance()
  if not logic_ui_tween.tween_manager then
    local TweenManager = import("TweenManager")
    logic_ui_tween.tween_manager = TweenManager()
  end
  return logic_ui_tween.tween_manager
end
function logic_ui_tween.TweenPosition(canvas_panel, start_pos, end_pos, time_span, type)
  local tween_manager = logic_ui_tween.GetInstance()
  if tween_manager and (math.abs(start_pos.X - end_pos.X) > TRAIL_DIF or math.abs(start_pos.Y - end_pos.Y) > TRAIL_DIF) then
    tween_manager:TweenPosition(canvas_panel, start_pos, end_pos, time_span, type or 0)
  end
end
function logic_ui_tween.TweenAlpha(widget, start_alpha, end_alpha, time_span, type)
  local tween_manager = logic_ui_tween.GetInstance()
  if tween_manager then
    tween_manager:TweenAlpha(widget, start_alpha, end_alpha, time_span, type or 0)
  end
end
function logic_ui_tween.TweenScale(canvas_panel, start_scale, end_scale, time_span, type)
  local tween_manager = logic_ui_tween.GetInstance()
  if tween_manager then
    tween_manager:TweenScale(canvas_panel, start_scale, end_scale, time_span, type or 0)
  end
end
function logic_ui_tween.TweenPositionTo(canvas_panel, end_pos, time_span, type)
  local start_pos = canvas_panel.Slot:GetPosition()
  logic_ui_tween.TweenPosition(canvas_panel, start_pos, end_pos, time_span, type or 0)
end
return logic_ui_tween