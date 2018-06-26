
for item, data in pairs(data.raw["item"]) do
    if data["place_as_tile"] ~= nil then
       if data.name == "space-tile" or data.name == "space-station-tile" then return end
       table.insert(data.place_as_tile.condition, "layer-11")
    end
end
