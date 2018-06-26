local planetToSpaceTransportation = table.deepcopy(data.raw.technology["rocket-silo"])
local updates = {
   name = "planet-to-space-transportation",
   effects = {
      {
	 type = "unlock-recipe",
	 recipe = "space-elevator",
      },
      {
	 type = "unlock-recipe",
	 recipe = "space-station-tile",
      },
      {
	 type = "unlock-recipe",
	 recipe = "space-tile",
      },
   },
   prerequisites = { "rocket-silo" },
   unit = {
      count = 1000,
      ingredients = {
	 {"science-pack-1", 1},
	 {"science-pack-2", 1},
	 {"science-pack-3", 1},
	 {"military-science-pack", 1},
	 {"production-science-pack", 1},
	 {"high-tech-science-pack", 1},
	 {"space-science-pack", 1},
      },
      time = 60,
   },
   order = "k-b",
}

for k,v in pairs(updates) do
   planetToSpaceTransportation[k] = updates[k]
end

data:extend{
   planetToSpaceTransportation,
}

