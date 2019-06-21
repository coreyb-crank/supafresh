
local font_size_long = 80
local font_size_short = 120

local CoffeeMachine = require 'CoffeeMachine'
local Carafe = require 'Carafe'
local Flavour = require 'Flavour'

local machine = {}
local carafes = {}
local flavours = {}


local function add_carafe(id, name)
  carafes[id] = Carafe:new(id, name)
end

local at_flavour = 1
local function add_flavour(id, name, image)
  local flavour = Flavour:new(id, name, image)
  flavours[id] = flavour
  
  flavour:show(at_flavour)
  at_flavour = at_flavour + 1
end


--- @param gre#context mapargs
function init_app(mapargs)
  -- Machine
  machine = CoffeeMachine:new()
  
  -- Carafes
  add_carafe('a', 'Carafe T1')
  add_carafe('b', 'Carafe T2')
  
  -- Flavas
  add_flavour('starbucks.verona', "Starbucks Verona", "starbucks_verona.jpg") --TODO: weird mix of whole/unwhole file name
  add_flavour('starbucks.veranda', "Starbucks Veranda", "starbucks_veranda.jpg")
  add_flavour('starbucks.pike_place', "Starbucks Pike Place", "starbucks_pike_place.jpg")
  add_flavour('starbucks.komodo_dragon', "Starbucks Komodo Dragon", "starbucks_komodo_dragon.jpg")
end

local function animate_flavour_set(carafe)
  --gre.set_value(carafe:get_group() .. '.flavour_set', gre.mstime())
  gre.send_event_target('flavour_set', carafe:get_group())
end

local function animate_empty(carafe)
  gre.send_event_target('empty', carafe:get_group())
end

local function animate_group_swap()
  local fields = {}
  
  fields['carafe_b_x'] = gre.get_value('times_layer.carafe_a.grd_x')
  fields['carafe_a_x'] = gre.get_value('times_layer.carafe_b.grd_x')
  
  gre.set_data(fields)
  gre.send_event('swap')
end

local function swap_carafes()
  --for _,carafe in pairs(carafes) do
  --  print (carafe:get_group())
  --  animate_empty(carafe)
  --end  --TODO: ask Mike why this doesn't work
  animate_empty(carafes['a'])
  --animate_empty(carafes['b']) --uhhh
  gre.timer_set_timeout(function()
    animate_empty(carafes['b'])
  end, 401)
  
  gre.timer_set_timeout(animate_group_swap, 802) --400 is empty animation length - any way to get() this?
end

local function flavour_selected(carafe, flavour)
  print("flavour_selected - carafe: " .. tostring(carafe and carafe.name) .. ", flavour: " .. tostring(flavour and flavour.name))
  
  carafe:empty()
  carafe:flavour(flavour)
  
  if not machine:carafe_in_brew_position(carafe) then
    swap_carafes()
  else
    animate_flavour_set(carafe)
  end
end

--- @param gre#context mapargs
function cb_flavour_selected(mapargs)
  print("cb_flavour_selected - carafe: " .. tostring(mapargs.carafe) .. ", flavour: " .. tostring(mapargs.flavour))
  flavour_selected(carafes[mapargs.carafe], flavours[mapargs.flavour])
end

-- Groups moved in closed/empty state, so deal with that
--- @param gre#context mapargs
function cb_groups_moved(mapargs)
  --[[local anim_length = 400
  local offset = 0
  
  for _,carafe in pairs(carafes) do
    if carafe:coffee() then
      gre.timer_set_timeout(function()
        animate_flavour_set(carafe)
      end, offset) -- can't run multiple animations at once, so this will fire one after another
      offset = offset + anim_length
    end
  end--]]
  -- lua doesn't make closures I guess? let's do it manual-style
  if carafes['a']:coffee() then
    animate_flavour_set(carafes['a'])
  end
  
  if carafes['b']:coffee() then
    gre.timer_set_timeout(function()
      animate_flavour_set(carafes['b'])
    end, 400)
  end
end

local function time_format(time)
  local hours = math.floor(time/3600)
  local minutes = math.floor((time - hours * 3600) / 60)
  local seconds = math.fmod(time, 60)
  
  if hours > 0 then
    return string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    return string.format("%d:%02d", minutes, seconds)
  end
end

--- @param gre#context mapargs
function cb_update_time_str(mapargs)
  gre.set_value(mapargs.control .. '.text', time_format(gre.get_value(mapargs.control .. '.time')))
end

-- May want to alter UI elements based on threshold times
--- @param gre#context mapargs
function cb_update_time_indicators(mapargs)
  local time = gre.get_value(mapargs.control .. '.time')
  if time >= 3600 then
    gre.set_value(mapargs.control .. '.fontSize', font_size_long)
  else
    gre.set_value(mapargs.control .. '.fontSize', font_size_short)
  end
end

--- @param gre#context mapargs
function cb_tick(mapargs) 
  -- TODO: really this is wrong, should get time of day and only tick if the second has changed
  for k,v in pairs(carafes) do
    v:tick() 
  end
end


--- @param gre#context mapargs
function cb_its_empty(mapargs) 
  carafes[mapargs.carafe]:empty()
end


--- @param gre#context mapargs
function cb_swap(mapargs) 
  swap_carafes()
end
