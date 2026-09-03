local logic_comp_combobox = {
  curComboboxMap = {},
  curOpenComboboxMap = {}
}
local time_ticker = require("common.time_ticker")
function logic_comp_combobox.AddCombobox(comboboxWidget)
  log(bWriteLog and "logic_comp_combobox.AddCombobox comboboxWidget = " .. tostring(comboboxWidget))
  logic_comp_combobox.curComboboxMap[comboboxWidget] = 1
end
function logic_comp_combobox.RemoveCombobox(comboboxWidget)
  log(bWriteLog and "logic_comp_combobox.RemoveCombobox comboboxWidget = " .. tostring(comboboxWidget))
  logic_comp_combobox.curComboboxMap[comboboxWidget] = nil
end
function logic_comp_combobox.ProcScreenMouseUp()
  time_ticker.AddTimer(0, function()
    for k, v in pairs(logic_comp_combobox.curOpenComboboxMap) do
      if slua.isValid(k.UIRoot) and (k.bHasCompEmptyItem or k.bIsNew) then
        if logic_comp_combobox.bClickSelf then
          k:RefreshOptions()
        else
          k:CloseComboBox()
        end
      end
    end
    logic_comp_combobox.curOpenComboboxMap = {}
    logic_comp_combobox.bClickSelf = false
  end)
end
function logic_comp_combobox.ProcScreenMouseDown()
  logic_comp_combobox.curOpenComboboxMap = {}
  for k, v in pairs(logic_comp_combobox.curComboboxMap) do
    if slua.isValid(k.UIRoot) and k.bIsOpen then
      logic_comp_combobox.curOpenComboboxMap[k] = v
    end
  end
end
function logic_comp_combobox.ProcPressCombobox()
  logic_comp_combobox.bClickSelf = true
end
return logic_comp_combobox