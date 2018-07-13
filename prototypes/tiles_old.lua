local spaceStationTile = table.deepcopy(data.raw.tile["refined-concrete"])
local updates = {
   name = "space-station-tile",
   minable = {hardness = 0, mining_time = -1, result = "space-station-tile"},
   collision_mask = {
      --"ground-tile",
      "layer-11",
   },
}

for k,v in pairs(updates) do
   spaceStationTile[k] = updates[k]
end
spaceStationTile["minable"] = nil

local spaceTile = table.deepcopy(data.raw.tile["grass-1"])

local updates = {
   name = "space-tile",
   collision_mask = {
      --"water-tile", 
      "layer-11",
      "item-layer",
      "resource-layer",
      "player-layer",
      "doodad-layer",
   },
   autoplace = nil,
   draw_in_water_layer = true,
   layer = 2,
   variants = {
      main = {
	 {
	    picture = "__base__/graphics/terrain/lab-tiles/lab-dark-1.png",
	    count = 1,
	    size = 1,
	 },
      },
      inner_corner = {
	 picture = "__base__/graphics/terrain/out-of-map-inner-corner.png",
	 count = 0,
      },
      outer_corner = {
	 picture = "__base__/graphics/terrain/out-of-map-outer-corner.png",
	 count = 0,
      },
      side = {
	 picture = "__base__/graphics/terrain/out-of-map-side.png",
	 count = 0,
      },
   },
   transitions = nil,
   transitions_between_transitions = nil,
   ageing=0.00045,

}

for k,v in pairs(updates) do
   spaceTile[k] = updates[k]
end

data:extend({
      spaceStationTile,
      spaceTile,
})

for item, data in pairs(data.raw.tile) do
   if data.name == "space-tile" or data.name == "space-station-tile" then return end
   --log(data.name)
   table.insert(data.collision_mask, "layer-12")
   --log(serpent.block(data.collision_mask))
end
