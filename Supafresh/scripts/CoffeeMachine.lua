local CoffeeMachine = {}


function CoffeeMachine:init(id, name, image)

end


function CoffeeMachine:carafe_in_brew_position(carafe)
  --return ends_with(carafe:get_group(), 'a')
  return gre.get_value(carafe:get_group() .. '.grd_x') < 400 -- el oh el
end


function CoffeeMachine:new()
  local instance = {}
  setmetatable(instance, {__index = CoffeeMachine})
  instance:init()
  return instance
end
return CoffeeMachine