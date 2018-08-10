local spaceElevator= table.deepcopy(data.raw.item["assembling-machine-1"])
local updates = {
   name = "space-elevator",
   icon = "__tater_spacestation__/graphics/space_elevator/space_elevator.png",
   icon_size = 256,
   place_result = "space-elevator",
   subgroup = "space-station",
}

for k,v in pairs(updates) do
   spaceElevator[k] = updates[k]
end

local spaceElevatorChest = table.deepcopy(data.raw.item["steel-chest"])
local updates = {
   name = "space-elevator-chest",
   place_result = "space-elevator-chest",
   subgroup = "space-station",
}

for k,v in pairs(updates) do
   spaceElevatorChest[k] = updates[k]
end

local spaceStationTile = table.deepcopy(data.raw.item["refined-concrete"])
local updates = {
   name = "space-station-tile",
   icon = "__tater_spacestation__/graphics/landfill.png",
   subgroup = "space-station",
   place_as_tile = {
      result = "space-station-tile",
      condition_size = 1,
      condition = { "ground-tile", "water-tile" } -- don't know what this does and api just says condition :: table
   },
}

for k,v in pairs(updates) do
   spaceStationTile[k] = updates[k]
end

local spaceTile = table.deepcopy(data.raw.item["landfill"])
local updates = {
   name = "space-tile",
   icon = "__tater_spacestation__/graphics/space.png",
   icon_size = 32,
   subgroup = "space-station",
   place_as_tile = {
      result = "space-tile",
      condition_size = 1,
      condition = { "ground-tile", "water-tile" } -- don't know what this does and api just says condition :: table
   },
}

for k,v in pairs(updates) do
    spaceTile[k] = updates[k]
end

local spaceAssembler = table.deepcopy(data.raw.item["assembling-machine-3"])
local updates = {
   name = "space-assembling-machine",
   icon = "__tater_spacestation__/graphics/space_assembling_machine/space-assembling-machine-icon.png",
   icon_size = 32,
   place_result = "space-assembling-machine",
   subgroup = "space-station",
}

for k,v in pairs(updates) do
   spaceAssembler[k] = updates[k]
end

-- space energy input
local space_energy_input = table.deepcopy(data.raw.item["accumulator"])
local updates = {
   name = "space-energy-input",
   place_result = "space-energy-input",
   subgroup = "space-station",
}

for k,v in pairs(updates) do
   space_energy_input[k] = updates[k]
end
-- space energy output
local space_energy_output = table.deepcopy(data.raw.item["accumulator"])
local updates = {
   name = "space-energy-output",
   place_result = "space-energy-output",
   subgroup = "space-station",
}

for k,v in pairs(updates) do
   space_energy_output [k] = updates[k]
end

local space_pipe = table.deepcopy(data.raw.item.pipe)
local updates = {
   name = "space-pipe",
   place_result = "space-pipe",
   subgroup = "space-station",
}

for k,v in pairs(updates) do
   space_pipe[k] = updates[k]
end

data:extend({
      spaceElevator,
      spaceElevatorChest,
      spaceStationTile,
      spaceTile,
      spaceAssembler,
      space_energy_input,
      space_energy_output,
      space_pipe,
})
