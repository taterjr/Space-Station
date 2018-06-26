local spaceElevator= table.deepcopy(data.raw.item["assembling-machine-1"])
local updates = {
   name = "space-elevator",
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

local spaceStationTile = table.deepcopy(data.raw.item["landfill"])
local updates = {
   name = "space-station-tile",
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

data:extend({
      spaceElevator,
      spaceElevatorChest,
      spaceStationTile,
      spaceTile,
})
