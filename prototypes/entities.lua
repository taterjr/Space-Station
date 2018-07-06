local spaceElevator= table.deepcopy(data.raw.container["steel-chest"])
local updates = {
   name = "space-elevator",
   icon = "__base__/graphics/icons/assembling-machine-1.png",
   icon_size = 32,
   minable = {
      hardness = 0.2,
      mining_time = 0.5,
      result = "space-elevator",
   },
   corpse = "big-remnants",
   dying_explosion = "medium-explosion",
   collision_box = {{-3.6, -3.6}, {3.6, 3.6}},
   selection_box = {{-4, -4}, {4, 4}},
   inventory_size = 1000,
   picture = {
      filename = "__tater_spacestation__/graphics/space_elevator/space_elevator.png",
      priority = "high",
      width = 320,
      height = 256,
      shift = { 1, 0},
   },
}

for k,v in pairs(updates) do
   spaceElevator[k] = updates[k]
end

local spaceElevatorChest = table.deepcopy(data.raw.container["steel-chest"])
local updates = {
   name = "space-elevator-chest",
   minable = {
      hardness = 0.2,
      mining_time = 0.5,
      result = "space-elevator-chest",
   },
}

for k,v in pairs(updates) do
   spaceElevatorChest[k] = updates[k]
end

local spaceAssembler = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
local updates = {
   name = "space-assembling-machine",
   minable = {
      hardness = 0.2,
      mining_time = 0.5,
      result = "space-assembling-machine",
   },
   collision_mask = {
      "item-layer",
      "object-layer",
      "player-layer",
      "water-tile",
      "layer-12",
   },
}

for k,v in pairs(updates) do
   spaceAssembler[k] = updates[k]
end

data:extend({
      spaceElevator,
      spaceElevatorChest,
      spaceAssembler,
})
