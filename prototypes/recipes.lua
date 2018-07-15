local spaceStationCategory = {
   type = "recipe-category",
   name = "space-station",
}

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

local spaceAssembler = {
   type = "recipe",
   name = "space-assembling-machine",
   enabled = false,
   ingredients = {
      {"assembling-machine-3", 1},
      {"low-density-structure", 10},
   },
   energy = 1,
   result = "space-assembling-machine",
}

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

local spaceScience = {
   type = "recipe",
   name = "space-science",
   enabled = false,
   category = "space-station",
   ingredients = {
      {"battery", 1},
      {"low-density-structure", 1},
      {"rocket-control-unit", 1},
      {"electric-engine-unit", 1},
   },
   energy = 20,
   result = "space-science-pack",
}

data:extend({
      spaceStationCategory,
      spaceElevator,
      spaceAssembler,
      spaceElevatorChest,
      spaceStationTile,
      spaceTile,
      spaceScience,
})
