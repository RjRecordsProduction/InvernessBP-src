local image_style = {hasInit = false}
function image_style.AddImageStyle()
  if image_style.hasInit then
    return
  end
  image_style.hasInit = true
  Client.SetAllImageStyle()
end
return image_style