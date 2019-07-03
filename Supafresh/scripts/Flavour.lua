local Flavour = {}


function Flavour:init(id, name, image)
  self.id = id
  self.name = name
  self.image = 'images/coffee_' .. image .. '.jpg' --TODO: png
end


function Flavour:show(control_index)
  local control = 'flavours_layer.flavour_' .. control_index
  local fields = {}
  
  fields[control .. '.flavour'] = self.id
  fields[control .. '.text'] = self.name
  fields[control .. '.image'] = self.image
  
  gre.set_data(fields)
end


function Flavour:new(id, name, image)
  local instance = {}
  setmetatable(instance, {__index = Flavour})
  instance:init(id, name, image)
  return instance
end
return Flavour