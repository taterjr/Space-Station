
local autoplace_utils = require("autoplace_utils")

local function noise_layer_peak(noise_name)
  return {
    influence = 0.5,
    noise_layer = noise_name,
    noise_persistence = 0.7,
    octaves_difference = -6,
    noise_scale = 3
  }
end

local function add_peaks(autoplace, more_peaks)
  for _, peak in ipairs(more_peaks) do
    autoplace.peaks[#autoplace.peaks + 1] = peak
  end
  return autoplace
end

-- 'rectangles' indicate
-- {{aux0, water0}, {aux1, water1}}
local function autoplace_settings(noise_name, control, rectangle, rectangle2)
  local peaks = {
    noise_layer_peak(noise_name)
  }

  local aux_center = (rectangle[2][1] + rectangle[1][1]) / 2
  local aux_range = math.abs(rectangle[2][1] - rectangle[1][1]) / 2
  local water_center = (rectangle[2][2] + rectangle[1][2]) / 2
  local water_range = math.abs(rectangle[2][2] - rectangle[1][2]) / 2

  -- fadeout too small and you'll get gaps between biomes.
  -- too large and placement get unpredictable
  local fadeout = 0.15

  peaks[#peaks + 1] = {
    aux_optimal = aux_center,
    aux_range = aux_range,
    aux_max_range = aux_range + fadeout,

    water_optimal = water_center,
    water_range = water_range,
    water_max_range = water_range + fadeout,
  }

  if rectangle2 ~= nil then
    aux_center = (rectangle2[2][1] + rectangle2[1][1]) / 2
    aux_range = math.abs(rectangle2[2][1] - rectangle2[1][1]) / 2
    water_center = (rectangle[2][2] + rectangle2[1][2]) / 2
    water_range = math.abs(rectangle2[2][2] - rectangle2[1][2]) / 2

    peaks[#peaks + 1] = {
      aux_optimal = aux_center,
      aux_range = aux_range,
      aux_max_range = aux_range + fadeout,

      water_optimal = water_center,
      water_range = water_range,
      water_max_range = water_range + fadeout,
    }
  end

  return { peaks = peaks, control = control }
end

function tile_variations_template(normal_res_picture, normal_res_transition, high_res_picture, high_res_transition, options)
  local function main_variation(size_)
    local y_ = ((size_ == 1) and 0) or ((size_ == 2) and 64) or ((size_ == 4) and 160) or 320
    local ret = {
      picture = normal_res_picture,
      count = 16,
      size = size_,
      y = y_,
      line_length = (size_ == 8) and 8 or 16,
      hr_version =
      {
        picture = high_res_picture,
        count = 16,
        size = size_,
        y = 2 * y_,
        line_length = (size_ == 8) and 8 or 16,
        scale = 0.5
      }
    }

    if options[size_] then
      for k, v in pairs(options[size_]) do
        ret[k] = v
        ret.hr_version[k] = v
      end
    end

    return ret
  end

  local function make_transition_variation(x_, line_len_, cnt_)
    return
    {
      picture = normal_res_transition,
      count = cnt_ or 8,
      line_length = line_len_ or 8,
      x = x_,
      hr_version=
      {
        picture = high_res_transition,
        count = cnt_ or 8,
        line_length = line_len_ or 8,
        x = 2 * x_,
        scale = 0.5,
      }
    }
  end

  local main_ =
  {
    main_variation(1),
    main_variation(2),
    main_variation(4),
  }
  if (options.max_size == 8) then
    table.insert(main_, main_variation(8))
  end

  return
  {
    main = main_,
    inner_corner_mask = make_transition_variation(0),
    outer_corner_mask = make_transition_variation(288),
    side_mask         = make_transition_variation(576),
    u_transition_mask = make_transition_variation(864, 1, 1),
    o_transition_mask = make_transition_variation(1152, 2, 1),
  }
end


function water_transition_template(to_tiles, normal_res_transition, high_res_transition, options)
  local function make_transition_variation(src_x, src_y, cnt_, line_len_, is_tall)
    return
    {
      picture = normal_res_transition,
      count = cnt_,
      line_length = line_len_,
      x = src_x,
      y = src_y,
      tall = is_tall,
      hr_version=
      {
        picture = high_res_transition,
        count = cnt_,
        line_length = line_len_,
        x = 2 * src_x,
        y = 2 * (src_y or 0),
        tall = is_tall,
        scale = 0.5,
      }
    }
  end

  local t = options.base or {}
  t.to_tiles = to_tiles
  local default_count = options.count or 16
  for k,y in pairs({inner_corner = 0, outer_corner = 288, side = 576, u_transition = 864, o_transition = 1152}) do
    local count = options[k .. "_count"] or default_count
    if count > 0 and type(y) == "number" then
      local line_length = options[k .. "_line_length"] or count
      local is_tall = true
      if (options[k .. "_tall"] == false) then
        is_tall = false
      end
      t[k] = make_transition_variation(0, y, count, line_length, is_tall)
      t[k .. "_background"] = make_transition_variation(544, y, count, line_length, is_tall)
      t[k .. "_mask"] = make_transition_variation(1088, y, count, line_length)
    end
  end

  return t
end


local grass_vehicle_speed_modifier = 1.6
local concrete_vehicle_speed_modifier = 0.8

-- An 'infinity-like' number used to give water an elevation range that
-- is effectively unbounded on the low end
local water_inflike = 4096

function water_autoplace_settings(from_depth, rectangles)
  local ret =
  {
    {
      -- Water and deep water have absolute priority. We simulate this by giving
      -- them absurdly large influence
      influence = 1e3 + from_depth,
      elevation_optimal = -water_inflike - from_depth,
      elevation_range = water_inflike,
      elevation_max_range = water_inflike, -- everywhere below elevation 0 and nowhere else
    }
  }

  -- if rectangles == nil then
  --   ret[2] = { influence = 1 }
  -- end

  -- autoplace_utils.peaks(rectangles, ret)

  return { peaks = ret }
end

water_tile_type_names = { "space-tile" }
patch_for_inner_corner_of_transition_between_transition = 
{
  filename = "__base__/graphics/terrain/water-transitions/water-patch.png",
  width = 32,
  height = 32,
  hr_version =
  {
    filename = "__base__/graphics/terrain/water-transitions/hr-water-patch.png",
    scale = 0.5,
    width = 64,
    height = 64
  }
}

local grass_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__base__/graphics/terrain/water-transitions/grass.png",
      "__base__/graphics/terrain/water-transitions/hr-grass.png",
      {
        o_transition_tall = false,
        u_transition_count = 4,
        o_transition_count = 8,
        base =
        {
          side_weights = { 1, 1, 1, 1,  0.25, 0.25, 1, 1,  1, 1, 0.125, 0.25,  1, 1, 1, 1 }
        }
      }
  ),
}

local grass_transitions_between_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__base__/graphics/terrain/water-transitions/grass-transition.png",
      "__base__/graphics/terrain/water-transitions/hr-grass-transition.png",
      {
        inner_corner_tall = true,
        inner_corner_count = 3,
        outer_corner_count = 3,
        side_count = 3,
        u_transition_count = 1,
        o_transition_count = 0,
        base = { water_patch = patch_for_inner_corner_of_transition_between_transition, },
      }
  ),
}


local space_layer = "layer-" .. settings.startup["tater-spacestation-space-collision"].value
local spaceTile = table.deepcopy(data.raw.tile["grass-1"])
local updates = {
    name = "space-tile",
    collision_mask = {
       space_layer,
      "item-layer",
      "resource-layer",
      "player-layer",
      "doodad-layer"
    },
    draw_in_water_layer = true,
    layer = 2,
    variants = {
      main = {
        {
          picture = "__tater_spacestation__/graphics/water/water1.png",
          count = 8,
          size = 1,
          hr_version =
          {
            picture = "__tater_spacestation__/graphics/water/hr-water1.png",
            count = 8,
            scale = 0.5,
            size = 1
          },
        },
        {
          picture = "__tater_spacestation__/graphics/water/water1.png",
          count = 8,
          size = 2,
          hr_version =
          {
            picture = "__tater_spacestation__/graphics/water/hr-water1.png",
            count = 8,
            scale = 0.5,
            size = 2
          },
        },
        {
          picture = "__tater_spacestation__/graphics/water/water1.png",
          count = 6,
          size = 4,
          hr_version =
          {
            picture = "__tater_spacestation__/graphics/water/hr-water1.png",
            count = 8,
            scale = 0.5,
            size = 4
          },
        }
      },
      inner_corner =
      {
        picture = "__tater_spacestation__/graphics/water/water-inner-corner.png",
        count = 0
      },
      outer_corner =
      {
        picture = "__tater_spacestation__/graphics/water/water-outer-corner.png",
        count = 0
      },
      side =
      {
        picture = "__tater_spacestation__/graphics/water/water-side.png",
        count = 0
      }
    },
    --allowed_neighbors = { "grass-1" },
    map_color={r=0.1, g=0.1, b=0.1},
    ageing=0.0006
  }
   
for k,v in pairs(updates) do
   spaceTile[k] = updates[k]
end

--//////////////////////////////////////////////////////////////spaceStationTile
local spaceStationTile = table.deepcopy(data.raw.tile["refined-concrete"])
local updates = {
    name = "space-station-tile",
    collision_mask = {
       space_layer,
    },
    --autoplace = autoplace_settings("grass-1", "grass", {{0, 0.7}, {1, 1}}),
    variants = tile_variations_template(
      "__tater_spacestation__/graphics/grass-1.png", "__base__/graphics/terrain/masks/transition-3.png",
      "__tater_spacestation__/graphics/hr-grass-1.png", "__base__/graphics/terrain/masks/hr-transition-3.png",
      {
        max_size = 4,
        [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
        [2] = { probability = 0.91, weights = {0.150, 0.150, 0.150, 0.150, 0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025 }, },
        [4] = { probability = 0.91, weights = {0.100, 0.80, 0.80, 0.100, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01 }, },
        --[8] = { probability = 1.00, weights = {0.090, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.025, 0.125, 0.005, 0.010, 0.100, 0.100, 0.010, 0.020, 0.020} },
      }
    ),
    transitions = grass_transitions,
    transitions_between_transitions = grass_transitions_between_transitions,
    walking_sound =
    {
      {
        filename = "__base__/sound/walking/grass-01.ogg",
        volume = 0.8
      },
      {
        filename = "__base__/sound/walking/grass-02.ogg",
        volume = 0.8
      },
      {
        filename = "__base__/sound/walking/grass-03.ogg",
        volume = 0.8
      },
      {
        filename = "__base__/sound/walking/grass-04.ogg",
        volume = 0.8
      }
    },
    map_color={r=0.8, g=0.8, b=0.9},
    ageing=0.00045,
}

for k,v in pairs(updates) do
   spaceStationTile[k] = updates[k]
end
spaceStationTile["minable"] = nil

data:extend{
   spaceTile,
   spaceStationTile,
}

local floor_collision = "layer-" .. settings.startup["tater-spacestation-floor-collision"].value
for item, data in pairs(data.raw.tile) do
   if data.name == "space-tile" or data.name == "space-station-tile" then return end
   table.insert(data.collision_mask, floor_collision)
end
