collision = {}
collision.map = require "map"
collision.tiles = collision.map.layers[3].data

local width = collision.map.layers[1].width
local height = collision.map.layers[1].height

local basictilesWalkable = collision.map.tilesets[1].tiles

local walkable = {}

for i, v in ipairs(basictilesWalkable) do
    walkable[basictilesWalkable[i].id] = true
end

collision.getTileType = function(xTile, yTile)
    idx = ((yTile-1)*width+xTile)
    return collision.tiles[idx]
end

collision.isWalkable = function(tileType)
    return walkable[tileType]
end
