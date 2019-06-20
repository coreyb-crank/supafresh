
local font_size_long = 80
local font_size_short = 120

local Pot = require 'Pot'
local Flavour = require 'Flavour'

local pots = {}
local flavours = {}


local function add_pot(id, name)
  pots[id] = Pot:new(id, name)
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
  -- Pots
  add_pot('a', 'Pot T1')
  add_pot('b', 'Pot T2')
  
  -- Flavas
  add_flavour('starbucks.verona', "Starbucks Verona", "starbucks_verona.jpg") --TODO: weird mix of whole/unwhole file name
  add_flavour('starbucks.veranda', "Starbucks Veranda", "starbucks_veranda.jpg")
  add_flavour('starbucks.pike_place', "Starbucks Pike Place", "starbucks_pike_place.jpg")
  add_flavour('starbucks.komodo_dragon', "Starbucks Komodo Dragon", "starbucks_komodo_dragon.jpg")
end


local function flavour_selected(pot, flavour)
  print("flavour_selected - pot: " .. tostring(pot and pot.name) .. ", flavour: " .. tostring(flavour and flavour.name))
  pot:flavour(flavour)
end

--- @param gre#context mapargs
function cb_flavour_selected(mapargs)
  print("cb_flavour_selected - pot: " .. tostring(mapargs.pot) .. ", flavour: " .. tostring(mapargs.flavour))
  flavour_selected(pots[mapargs.pot], flavours[mapargs.flavour])
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
  for k,v in pairs(pots) do
    v:tick() 
  end
end


--- @param gre#context mapargs
function cb_its_empty(mapargs) 
  pots[mapargs.pot]:empty()
end
