local spaceElevator = {
   type = "recipe",
   name = "space-elevator",
   energy_required = 10,
   enabled = false,
   ingredients = {
      {"satellite", 2},
      {"low-density-structure", 1000},
   },
   result = "space-elevator",
   result_count = 1,
}

local spaceElevatorChest = table.deepcopy(data.raw.recipe["steel-chest"])
local updates = {
   name = "space-elevator-chest",
   enabled = false,
   result = "space-elevator-chest",
}

for k,v in pairs(updates) do
   spaceElevatorChest[k] = updates[k]
end

local spaceStationTile = table.deepcopy(data.raw.recipe["landfill"])
local updates = {
   name = "space-station-tile",
   enabled = false,
   ingredients = {
      {"low-density-structure", 10},
   },
   result = "space-station-tile",
   result_count = 10,
}

for k,v in pairs(updates) do
   spaceStationTile[k] = updates[k]
end

local spaceTile = table.deepcopy(data.raw.recipe["landfill"])
local updates = {
   name = "space-tile",
   enabled = false,
   ingredients = {},
   result = "space-tile",
   result_count = 10,
}

for k,v in pairs(updates) do
    spaceTile[k] = updates[k]
end

data:extend({
      spaceElevator,
      spaceElevatorChest,
      spaceStationTile,
      spaceTile,
})
