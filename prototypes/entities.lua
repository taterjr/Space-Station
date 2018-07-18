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

local spaceAssembler = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
local updates = {
   name = "space-assembling-machine",
   icon = "__tater_spacestation__/graphics/space_assembling_machine/space-assembling-machine-icon.png",
   minable = {
      hardness = 0.2,
      mining_time = 0.5,
      result = "space-assembling-machine",
   },
   crafting_speed = 2,
   collision_mask = {
      "item-layer",
      "object-layer",
      "player-layer",
      "water-tile",
      "layer-12",
   },
   crafting_categories = {"crafting", "advanced-crafting", "crafting-with-fluid", "space-station"},
}
spaceAssembler.animation.layers[1].filename = "__tater_spacestation__/graphics/space_assembling_machine/space-assembling-machine.png"
spaceAssembler.animation.layers[1].hr_version.filename = "__tater_spacestation__/graphics/space_assembling_machine/hr-space-assembling-machine.png"

for k,v in pairs(updates) do
   spaceAssembler[k] = updates[k]
end

--space energy input
local space_energy_input = table.deepcopy(data.raw["electric-energy-interface"]["electric-energy-interface"])
local updates = {
   name = "space-energy-input",
   minable = {
      hardness = 0.2,
      mining_time = 0.5,
      result = "space-energy-input",
   },
   collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
   selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
   enable_gui = false,
   energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      input_flow_limit = "1MW",
      buffer_capacity = "1MW",
      render_no_power_icon = false,
   },
   energy_usage = "0MW",
   energy_production = "0MW",
   picture = {
      filename = "__tater_spacestation__/graphics/space-energy/space-energy.png",
      priority = "high",
      width = 64,
      height = 128,
      shift = {0, -1.5},
   },
}

for k,v in pairs(updates) do
   space_energy_input[k] = updates[k]
end
--space energy output
local space_energy_output= table.deepcopy(data.raw["electric-energy-interface"]["electric-energy-interface"])
local updates = {
   name = "space-energy-output",
   minable = {
      hardness = 0.2,
      mining_time = 0.5,
      result = "space-energy-output",
   },
   collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
   selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
   enable_gui = false,
   energy_source = {
      type = "electric",
      usage_priority = "secondary-output",
      input_flow_limit = "1MW",
      buffer_capacity = "1MW",
      render_no_power_icon = false,
   },
   energy_usage = "0MW",
   energy_production = "0MW",
   picture = {
      filename = "__tater_spacestation__/graphics/space-energy/space-energy.png",
      priority = "high",
      width = 64,
      height = 128,
      shift = {0, -1.5},
   },
}

for k,v in pairs(updates) do
   space_energy_output[k] = updates[k]
end

data:extend({
      spaceElevator,
      spaceElevatorChest,
      spaceAssembler,
      space_energy_input,
      space_energy_output,
})
