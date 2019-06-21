local Carafe = {}


function Carafe:init(id, name)
  self.id = id
  self.name = name
  
  self:group('carafe_' .. id) -- TODO: consider having the group passed in and reassignable
  self:empty()
end

function Carafe:get_group()
  return self._group
end

-- Sets group and updates UI
function Carafe:group(group)
  self._group = 'times_layer.' .. group
  self.group_name = self._group .. '.name'
  self.time_var = self._group .. '.time.time'
  self.flavour_image = self._group .. '.flavour.image'
  self.flavour_image_alpha = self._group .. '.flavour.alpha'
  self.box = self._group .. 'box'
  
  local fields = {}
  
  fields[self.group_name] = self.name
  fields[self.time_var] = 0
  fields[self.flavour_image] = ''
  fields[self.flavour_image_alpha] = 0
  
  gre.set_data(fields)
end


function Carafe:flavour(flavour)
  self._flavour = flavour
  
  if flavour then
    print("selected flavour: " .. flavour.name)
  
    local fields = {}
    
    fields[self.flavour_image] = flavour.image
    --fields[self.flavour_image_alpha] = 255
  
    gre.set_data(fields)
  end
end

-- Do you have any coffee, Sir?
function Carafe:coffee()
  return self._flavour
end

function Carafe:time(time)
  self._time = time
  gre.set_value(self.time_var, self._time)
end


function Carafe:tick()
  if self:coffee() then
    self:time(self._time + 1)
  end
end

function Carafe:empty()
  self:flavour() -- no flava
  self:time(0) -- and no time eitha
end


function Carafe:new(id, name)
  local instance = {}
  setmetatable(instance, {__index = Carafe})
  instance:init(id, name)
  return instance
end
return Carafe