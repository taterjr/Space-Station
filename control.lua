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
	 autoplace_controls = {
	 },
      }
      local autoplace_controls = { "coal", "copper-ore", "crude-oil", "desert", "dirt", "enemy-base", "iron-ore", "sand", "stone", "trees", "uranium-ore"}
      for name, value in ipairs(autoplace_controls) do
	 settings.autoplace_controls[value] = { frequency = "none" }
      end
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
   global.space_elevator = {}
   global.spaceSurface = create_space_surface()
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

local function is_chunk_generated(linking_surface, entity, entity_size)
   local chunk_pos = {}
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
-- space elevator
--##############################################################################
   
local function create_space_elevator(event)
   if event.created_entity.name:sub(1, 14) ~= "space-elevator" then return end -- if the entity is not prefixed with space-elevator dont do anything
   local surface = event.created_entity.surface
   local linking_surface = get_linking_surface(surface)
   local tile_fill = nil
   local entity = event.created_entity
   local new_space_elevator = nil

   --player_print(entity.bounding_box.left_top.x .. " " .. entity.bounding_box.left_top.y)
   --player_print(entity.bounding_box.right_bottom.x .. " " .. entity.bounding_box.right_bottom.y)

   if linking_surface == global.spaceSurface then
      tile_fill = "space-station-tile"
   else
      tile_fill = "grass-1"
   end

   --for i, entites in pairs(linking_surface.find_entities(entity.bounding_box)) do
      --player_print(i)
   --end

   -- check if chunk is generated
   local chunk_pos = {}
   chunk_pos.x = math.floor(entity.position.x) / 32
   chunk_pos.y = math.floor(entity.position.y) / 32
   for y = chunk_pos.y-1, chunk_pos.y+1 do
      for x = chunk_pos.x-1, chunk_pos.x+1 do
	 if not global.spaceSurface.is_chunk_generated({x = x, y = y}) then
	    player_print("This is not a valid position")
	    surface.create_entity{
	       name = "flying-text",
	       position = entity.position,
	       text = { "item-limitation.chunk-not-generated" },
	    }
	    entity.destroy()
	    return
	 end
      end
   end
   -- generate tiles under the space elevator when there is water or space under it
   linking_surface.request_to_generate_chunks(entity.position, 5)
   local tiles = {}
   for x = entity.selection_box.left_top.x-1, entity.selection_box.right_bottom.x do
      for y = entity.selection_box.left_top.y-1, entity.selection_box.right_bottom.y do
	 local tile = linking_surface.get_tile(x,y).name
	 if string.find(tile, "water") or tile == "space-tile" then
	    table.insert(tiles, {name = tile_fill, position = {x,y}})
	 end
      end
   end
   linking_surface.set_tiles(tiles)

   -- check if a valid position
   if linking_surface.can_place_entity{ name = entity.name, position = entity.position} then
      new_space_elevator = linking_surface.create_entity{
	 name = entity.name,
	 position = entity.position,
	 force = entity.force,
      }
   end

   if new_space_elevator == nil then
      player_print("This position is not valid please try another position")
      surface.create_entity{
	 name = "flying-text",
	 position = entity.position,
	 text = { "item-limitation.space-not-empty" }, -- make a localized string
      }
      entity.destroy()
   else
	 table.insert(global.space_elevator, new_space_elevator.position)
   end
end

local function destroy_space_elevator(event)
   if event.entity.name:sub(1, 14) ~= "space-elevator" then return end -- if the entity is not prefixed with space-elevator dont do anything
   local entity = event.entity
   local linked_surface = nil
   if entity.surface.name == "space" then
      linked_surface = game.surfaces[1]
   else
      linked_surface = game.surfaces["space"]
   end

   for index, elevator_pos in pairs(global.space_elevator) do
      if elevator_pos.x == entity.position.x and elevator_pos.y == entity.position.y then
	 table.remove(global.space_elevator, index)
      end
   end

   local space_elevator = linked_surface.find_entity(entity.name, entity.position)
   space_elevator.destroy()

end


--##############################################################################
-- space energy
--##############################################################################
local function create_space_energy(event) 
   -- when a space energy entity is placed
   -- place the opposite space energy in the opposite surface
   if event.created_entity.name:sub(1,12) ~= "space-energy" then return end

   -- get opposite space energy
   local linking_entity_name = nil
   if event.created_entity.name == "space-energy-input" then
      linking_entity_name = "space-energy-output"
   else
      linking_entity_name = "space-energy-input"
   end

   -- get opposite surface
   local linking_surface = get_linking_surface(event.created_entity.surface)

   -- check if chunk is generated
   if is_chunk_generated(linking_surface, event.created_entity, 2) == false then return end

   -- generate tiles
   generate_tiles(linking_surface, event.created_entity.selection_box)

   -- check if valid position
   local created = create_valid_entity(linking_surface, event.created_entity, linking_entity_name)
   if created then
      -- add to global.space_energy array
   else
      -- return item to player/robot or place item on ground
   end
end

local function destroy_space_energy(event)
   -- when a space energy is destroyed
   -- destroy the other one in the opposite surface
   if event.entity.name:sub(1,12) ~= "space-energy" then return end

   -- get opposite surface
   local linking_surface = get_linking_surface(event.entity.surface)

   -- remove from space_energy array

   -- remove other entity
   local linking_entity_name = nil
   if event.entity.name == "space-energy-input" then
      linking_entity_name = "space-energy-output"
   else
      linking_entity_name = "space-energy-input"
   end
   local space_energy = linking_surface.find_entity(linking_entity_name, event.entity.position)
   space_energy.destroy()

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

script.on_init(function()
      --create space station surface
      --create_space_surface()
      init_globals()
end)

script.on_event(defines.events.on_tick, function(event)
		   -- when a player walks into a space elevator teleport them
		   teleport_players()
		   teleport_items_chest()
end)

script.on_event(defines.events.on_chunk_generated, function(event)
		   --fill space station surface with space tiles
		   generate_space_surface(event)
end)

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
      -- link space elevators on the ground and on the space station
      create_space_elevator(event)
      create_space_energy(event)
end)

script.on_event({defines.events.on_player_built_tile, defines.events.on_robot_built_tile}, function(event)
      remove_space_station(event)
end)

script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity, defines.events.on_entity_died}, function(event)
      destroy_space_elevator(event)
      destroy_space_energy(event)
end)
