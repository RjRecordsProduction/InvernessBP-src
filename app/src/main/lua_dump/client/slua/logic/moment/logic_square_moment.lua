local logic_square_moment = {}
local cur_page_no = 1
local max_page_no = 0
function logic_square_moment.set_cur_page_no(_page_no)
  curend
function logic_square_moment.get_cur_page_no()
  return cur_page_no or 0
end
function logic_square_moment.next_page()
  cur_page_no = cur_page_no + 1
end
function logic_square_moment.get_max_page()
  return max_page_no
end
function logic_square_moment.set_max_page(max_page)
  max_page_no = max_page
end
function logic_square_moment.check_can_get_next_page()
  if max_page_no == 0 then
    return true
  else
    return false
  end
end
function logic_square_moment.clear()
  cur_page_no = 1
  max_page_no = 0
end
return logic_square_moment