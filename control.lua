local function player_print(s)
   for i, player in pairs(game.players) do
      player.print(s)
   end
end
--##############################################################################
-- space station generation
--##############################################################################
local function create_space_surface() --makes a surface named space filled with nothing but water
   if not game.surfaces["space"] then
      local settings = {
	 terrain_segmentation = "none",
	 water = "none",
	 width = 0,
	 height = 0,
	 starting_area = "none",
	 peaceful_mode = true,
      }
      local surface = game.create_surface("space", settings)
      game.surfaces["space"].request_to_generate_chunks({0,0}, 3)
      game.surfaces["space"].always_day = true
      return surface
   end
   return nil
end

local function generate_space_surface(event)
   if event.surface.name == "space" then
      --replace normal tiles with space tiles
      local tiles = {}
      local area = event.area
      for x = area.left_top.x, event.area.right_bottom.x do
	 for y = area.left_top.y, event.area.right_bottom.y do
	    table.insert(tiles, {name = "space-tile", position = {x,y}})
	 end
      end
      event.surface.set_tiles(tiles)
   end
end
--##############################################################################
-- init
--##############################################################################
local function init_globals()
   
   --global.space_elevator_chest = {}
   global.space_elevator = global.space_elevator or {}
   global.space_energy = global.space_energy or {}
   global.space_pipe = global.space_pipe or {}
   global.spaceSurface = global.spaceSurface or create_space_surface()
end

--##############################################################################
-- utils
-- For creating linked entities
--##############################################################################
local function get_linking_surface(surface)
   if surface == global.spaceSurface then
      return game.surfaces[1]
   else
      return global.spaceSurface
   end
end

local function is_chunk_generated(linking_surface, entity)
   local chunk_pos = {}
   local area = entity.selection_box
   local entity_size = math.abs(area.left_top.x - area.right_bottom.x)
   chunk_pos.x = math.floor(entity.position.x) / 32
   chunk_pos.y = math.floor(entity.position.y) / 32
   for y = chunk_pos.y-1, chunk_pos.y+1 do
      for x = chunk_pos.x-1, chunk_pos.x+1 do
	 if not linking_surface.is_chunk_generated{x = x, y = y} then
	    player_print("The Chunk is not generated! Please try again")
	    entity.surface.create_entity{
	       name = "flying-text",
	       position = entity.position,
	       text = { "item-limitation.chunk-not-generated" },
	    }
	    linking_surface.request_to_generate_chunks(entity.position, math.ceil(entity_size/2) + 1)
	    entity.destroy()
	    return false
	 end
      end
   end
   return true
end

local function generate_tiles(linking_surface, area)
   local tile_fill = nil
   if linking_surface == global.spaceSurface then
      tile_fill = "space-station-tile"
   else
      tile_fill = "grass-1"
   end

   local tiles = {}
   for x = area.left_top.x-1, area.right_bottom.x do
      for y = area.left_top.y-1, area.right_bottom.y do
	 local tile = linking_surface.get_tile(x,y).name
	 if string.find(tile, "water") or tile == "space-tile" then
	    table.insert(tiles, {name = tile_fill, position = {x,y}})
	 end
      end
   end
   linking_surface.set_tiles(tiles)
end

local function create_valid_entity(linking_surface, old_entity, new_entity_name) -- new enity name optional
   local entity_name = new_entity_name or old_entity.name

   if linking_surface.can_place_entity{
      name = entity_name,
      position = old_entity.position,
   } then
      -- create new entity
      linking_surface.create_entity{
	 name = entity_name,
	 position = old_entity.position,
	 force = old_entity.force,
      }
      return true
   else 
      -- entity creation failed
      old_entity.surface.create_entity{
	 name = "flying-text",
	 position = old_entity.position,
	 text = { "item-limitation.space-not-empty" },
      }
      old_entity.destroy()
      return false
   end
end
--##############################################################################
-- space linking
--##############################################################################
local function create_linking_entity(event, global_array, entity_name, linking_entity_name)
   -- when an entity with a prefix matching prefix_name is placed
   -- place the resulting entity on the opposite surface

   -- event - the on_built_entity or on_robot_built_entity
   -- global_array - the array the entity uses
   -- entity_name - the name of the entity
   -- linking_entity_name(optional) - the name of the entity that gets placed on the opposite surface

   if event.created_entity.valid == false then return end
   if event.created_entity.name ~= entity_name then return end

   -- get opposite surface
   local linking_surface = get_linking_surface(event.created_entity.surface)

   -- check if chunk is generated
   if is_chunk_generated(linking_surface, event.created_entity) == false then return end

   -- generate tiles
   generate_tiles(linking_surface, event.created_entity.selection_box)

   -- check if valid position
   local created = nil
   if linking_entity_name == nil then
      created = create_valid_entity(linking_surface, event.created_entity)
   else
      created = create_valid_entity(linking_surface, event.created_entity, linking_entity_name)
   end
   if created then
      -- add to global.space_energy array
      table.insert(global_array, event.created_entity.position)
   else
      -- return item to player/robot or place item on ground
   end
end

local function destroy_linking_entity(event, global_array, entity_name, linking_entity_name)
   -- when an entity is destroyed
   -- destroy the other one in the opposite surface

   -- event - the on_player_mined_entity or on_robot_mined_entity or on_entity_died
   -- global_array - the array the entity uses
   -- entity_name - the name of the entity
   -- linking_entity_name(optional) - the name of the entity that gets destroyed on the opposite surface
   if event.entity.name ~= entity_name then return end

   -- get opposite surface
   local linking_surface = get_linking_surface(event.entity.surface)

   -- remove from space_energy array
   for i, energy_pos in pairs(global_array) do
      if energy_pos.x == event.entity.position.x and energy_pos.y == event.entity.position.y then
	 table.remove(global_array, i)
      end
   end

   -- remove other entity
   local linking_entity = nil
   if linking_entity_name == nil then
      linking_entity = linking_surface.find_entity(entity_name, event.entity.position)
   else
      linking_entity = linking_surface.find_entity(linking_entity_name, event.entity.position)
   end
   linking_entity.destroy()
end
--##############################################################################
--tiles
--##############################################################################
local function remove_space_station(event)
   if event.item.name ~= "space-tile" then return end
   local placer = nil
   if event.name == defines.events.on_player_built_tile then
      placer = game.players[event.player_index]
   else
      placer = event.robot
   end
   local count = 0
   for i, tile in pairs(event.tiles) do
      count = count + 1
   end
   local inserted = placer.insert({name = "space-station-tile", count = count})
   if count - inserted > 0 then
      placer.surface.spill_item_stack(placer.position, {name = "space-station-tile", count = count - inserted})
   end
end
--##############################################################################
--transportation between space and nauvis
--##############################################################################
local function teleport_players()
   for player_index, player in pairs(game.players) do
      if player.connected and not player.driving then
	 local walking_state = player.walking_state
	 if walking_state.walking then
	    if walking_state.direction == defines.direction.north
	    or walking_state.direction == defines.direction.northeast
	    or walking_state.direction == defines.direction.northwest then
	       -- teleport player
	       -- player bounding box is 0.2 x 0.2
	       local pos = player.position
	       local entities = player.surface.find_entities_filtered({
		     name = "space-elevator",
		     area = {
			{pos.x-0.2, pos.y-0.3},
			{pos.x+0.2, pos.y},
		     },
	       })
	       for i, entity in pairs(entities) do
		  if math.abs(pos.x-entity.position.x) < 0.6 then
		     local new_pos = entity.position
		     new_pos.y = new_pos.y - 4
		     if player.surface.name == "space" then
			player.teleport(new_pos, game.surfaces[1])
		     else
			player.teleport(new_pos, game.surfaces["space"])
		     end
		  end
	       end
	    end
	 end
      end
   end
end

local function teleport_items_chest()
   if game.tick % 60 ~= 0 then return end
   for i, elevator_pos in pairs(global.space_elevator) do
      local surface_elevator= game.surfaces["nauvis"].find_entity("space-elevator", elevator_pos)
      local space_elevator= global.spaceSurface.find_entity("space-elevator", elevator_pos)

      if surface_elevator.valid and space_elevator.valid then
	 local surface_inv = surface_elevator.get_inventory(defines.inventory.chest)
	 local space_inv = space_elevator.get_inventory(defines.inventory.chest)

	 local surface_contents = surface_inv.get_contents()
	 local space_contents = space_inv.get_contents()
	 for item, surface_count in pairs(surface_contents) do
	    local space_count = space_contents[item] or 0
	    local difference = surface_count - space_count

	    if difference > 1 then
	       local inserted = space_inv.insert({name = item, count = math.floor(difference/2)})
	       if inserted > 0 then
		  surface_inv.remove({name = item, count = inserted})
	       end
	    elseif difference < -1 then
	       local inserted = surface_inv.insert({name = item, count = math.floor(-difference/2)})
	       if inserted > 0 then
		  space_inv.remove({name = item, count = inserted})
	       end
	    end
	 end

	 for item, count in pairs(space_contents) do
	    if count > 1 and not surface_contents[item] then
	       local inserted = surface_inv.insert({name = item, count = math.floor(count/2)})

	       if inserted > 0 then
		  space_inv.remove({name = item, count = inserted})
	       end
	    end
	 end
      end
   end
end

local function teleport_power()
   --if game.tick % 60 ~= 0 then return end
   for i, energy_pos in pairs(global.space_energy) do
      -- find input
      local output_surface = nil
      local energy_input = game.surfaces["nauvis"].find_entity("space-energy-input", energy_pos)
      if energy_input == nil then
	 energy_input = global.spaceSurface.find_entity("space-energy-input", energy_pos)
	 output_surface = game.surfaces["nauvis"]
      else
	 output_surface = global.spaceSurface
      end

      -- find output
      local energy_output = output_surface.find_entity("space-energy-output", energy_pos)

      -- test if entities are valid
      if energy_input.valid and energy_output.valid then
	 -- transfer power from input to output
	 local energy = energy_input.energy + energy_output.energy
	 local out_buffer = energy_output.electric_buffer_size
	 if energy > out_buffer then
	    energy_output.energy = out_buffer
	    energy_input.energy = energy - out_buffer
	 else
	    energy_output.energy = energy
	    energy_input.energy = 0
	 end
      end
   end
end

local function teleport_fluids()
   if game.tick % 60 ~= 0 then return end

   for i, pipe_pos in pairs(global.space_pipe) do
      local surface_pipe = game.surfaces["nauvis"].find_entity("space-pipe", pipe_pos)
      local space_pipe = global.spaceSurface.find_entity("space-pipe", pipe_pos)

      if surface_pipe.valid and space_pipe.valid then
	 local surface_boxes = surface_pipe.fluidbox
	 local surface_box = surface_boxes[1]
	 local space_boxes = space_pipe.fluidbox
	 local space_box = space_boxes[1]
	 if surface_box ~= nil and space_box ~= nil then
	    player_print(surface_box.name .. " " .. space_box.name)
	    if surface_box.name == space_box.name then
	       -- both have the same type of fluids
	       local sur_amount = surface_box.amount
	       local sp_amount = space_box.amount

	       local trans_amount = (sur_amount + sp_amount) * surface_boxes.get_capacity(1) / (surface_boxes.get_capacity(1) + space_boxes.get_capacity(1)) - sp_amount

	       surface_box.amount = sur_amount - trans_amount
	       space_box.amount = sp_amount + trans_amount
	       surface_boxes[1] = surface_box
	       space_boxes[1] = space_box
	    end
	 elseif surface_box ~= nil then
	    -- only surface has fluid
	    local sur_amount = surface_box.amount
	    local trans_amount = sur_amount * space_boxes.get_capacity(1) / (surface_boxes.get_capacity(1) + space_boxes.get_capacity(1))
	    surface_box.amount = sur_amount - trans_amount
	    surface_boxes[1] = surface_box
	    surface_box.amount = trans_amount
	    space_boxes[1] = surface_box
	 elseif space_box ~= nil then
	    -- only space has fluid
	    local sp_amount = space_box.amount
	    local trans_amount = sp_amount * surface_boxes.get_capacity(1) / (surface_boxes.get_capacity(1) + space_boxes.get_capacity(1))
	    space_box.amount = sp_amount - trans_amount
	    space_boxes[1] = space_box
	    space_box.amount = trans_amount
	    surface_boxes[1] = space_box
	 end
      end
   end
end

script.on_init(function()
      --create space station surface
      --create_space_surface()
      init_globals()
end)

script.on_configuration_changed(function()
      init_globals()
end)

script.on_event(defines.events.on_tick, function(event)
		   -- when a player walks into a space elevator teleport them
		   teleport_players()
		   teleport_items_chest()
		   teleport_fluids()
		   teleport_power()
end)

script.on_event(defines.events.on_chunk_generated, function(event)
		   --fill space station surface with space tiles
		   generate_space_surface(event)
end)

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
      create_linking_entity(event, global.space_elevator, "space-elevator")
      create_linking_entity(event, global.space_energy, "space-energy-input", "space-energy-output")
      create_linking_entity(event, global.space_energy, "space-energy-output", "space-energy-input")
      create_linking_entity(event, global.space_pipe, "space-pipe")
end)

script.on_event({defines.events.on_player_built_tile, defines.events.on_robot_built_tile}, function(event)
      remove_space_station(event)
end)

script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity, defines.events.on_entity_died}, function(event)
      destroy_linking_entity(event, global.space_elevator, "space-elevator")
      destroy_linking_entity(event, global.space_energy, "space-energy-input", "space-energy-output")
      destroy_linking_entity(event, global.space_energy, "space-energy-output", "space-energy-input")
      destroy_linking_entity(event, global.space_pipe, "space-pipe")
end)
