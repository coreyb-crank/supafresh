local Pot = {}


function Pot:init(id, name)
  self.id = id
  self.name = name
  
  self:group('pot_' .. id) -- TODO: consider having the group passed in and reassignable
  self:empty()
end


-- Sets group and updates UI
function Pot:group(group)
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


function Pot:flavour(flavour)
  self._flavour = flavour
  
  if flavour then
    print("selected flavour: " .. flavour.name)
  
    local fields = {}
    
    fields[self.flavour_image] = flavour.image
    fields[self.flavour_image_alpha] = 255
  
    gre.set_data(fields)
  end
end

-- Do you have any coffee, Sir?
function Pot:coffee()
  return self._flavour
end

function Pot:time(time)
  self._time = time
  gre.set_value(self.time_var, self._time)
end


function Pot:tick()
  if self:coffee() then
    self:time(self._time + 1)
  end
end


function Pot:empty()
  self:flavour() -- no flava
  self:time(0) -- and no time eitha
end


function Pot:new(id, name)
  local instance = {}
  setmetatable(instance, {__index = Pot})
  instance:init(id, name)
  return instance
end
return Pot