
local space_collision = "layer-" .. settings.startup["tater-spacestation-space-collision"].value
for item, data in pairs(data.raw["item"]) do
    if data["place_as_tile"] ~= nil then
       if data.name == "space-tile" or data.name == "space-station-tile" then return end
       table.insert(data.place_as_tile.condition, space_collision)
    end
end
