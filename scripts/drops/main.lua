--[[
* ---------------------------------------------- *
               Simple Drop by Indiana
	 https://github.com/indianajson/simple-drop/
* ---------------------------------------------- *
]]--

print("[drops] Configuring Ice Drops")

--defaults
local dropping = {}
local drop_areas = {}
local ice_cache = {}
local drop_required_properties = {"Landing","Drop Edge"}

--Shorthand for async
function async(p)
    local co = coroutine.create(p)
    return Async.promisify(co)
end

--Shorthand for await
function await(v) return Async.await(v) end

--Checks if array has string
local function has_value (table, value)
    for index, val in ipairs(table) do
        if val == value then
            return true
        end
    end

    return false
end

local function validate_ice_drop(area_id,object_id)
    --check required properties are present
    local drop = ice_cache[area_id][object_id]
    for i, prop_name in pairs(drop_required_properties) do
        if not drop.custom_properties[prop_name] then
            print('   Ice Drop \''..object_id..'\' was not created because the custom property '..prop_name..' is required.')
            drop.remove()
            return false
        else
        end
    end
    --check Drop Edge is valid
    direction = drop.custom_properties["Drop Edge"]
    if direction == "Down Left" or direction == "Up Left" or direction == "Up Right" or direction == "Down Right" then
    else
        print("   '"..direction.."' is not a valid 'Drop Edge'")
        print("   You can use 'Down Right', 'Down Left', 'Up Left', or 'Up Right'")
        print("   Ice Drop "..object_id.." was not created due to this error. ")
        ice_cache[area_id][object_id] = nil
        return false
    end

    --fix x and Y values (should be whole numbers for tile)
    ice_cache[area_id][object_id].x = math.floor(drop.x) 
    ice_cache[area_id][object_id].y = math.floor(drop.y) 
    print("   Added "..drop.custom_properties["Drop Edge"].." ice drop at "..drop.x..","..drop.y..","..drop.z)
    table.insert(drop_areas, area_id)
end

-- add areas with drop zones to drop_area array
local function find_drops()
    local areas = Net.list_areas()
    --Check every area
    for i, area_id in next, areas do
        area_id = tostring(area_id)
        if not ice_cache[area_id] then
            ice_cache[area_id] = {}
        --Loop over all objects in area, spawning drops for each drop object.
        local objects = Net.list_objects(area_id)
            for i, object_id in next, objects do    
                local object = Net.get_object_by_id(area_id, object_id)
                object_id = tostring(object_id)
                if object.type == "Ice Drop" then
                    ice_cache[area_id][object_id] = object
                    Net.remove_object(area_id, object_id)
                    validate_ice_drop(area_id,object_id)
                end
            end
        end
    end
end

-- purpose: turns the edge of an ice tile into a drop down to another walkable tile below.
-- usage: called automatically when Net:on("player_move") occurs
local function handle_ice_drop(player_id, x, y, z, ice_x, ice_y, ice_z, drop_z, direction)
    return async(function ()
        if dropping[player_id] == false then
            ice_x = tonumber(ice_x)
            ice_y = tonumber(ice_y)
            ice_z = tonumber(ice_z)
            drop_z = tonumber(drop_z)
            if direction == "Up Left" then 
                if x <= ice_x-.03125 and x >= ice_x-1 and y >= ice_y and y <= ice_y+1 and z == ice_z then
                local floors = ice_z-drop_z
                local offset = 0
                if floors % 2 == 0 then
                    offset = math.ceil(floors/2)
                    dropOffset = 1
                    --3 = 
                else
                    offset = math.ceil(floors/2)-.5
                    dropOffset = 0
                end
                startOffset = math.ceil(3/2)-.5
                dropping[player_id] = true
                Net.lock_player_input(player_id)
                Net.animate_player(player_id, "IDLE_UL", true)
                local keyframes = {{properties={{property="X",value=x-startOffset},{property="Y",value=y-startOffset},{property="Z",value=z-3}},duration=0.0}}

                keyframes[#keyframes+1] = {properties={{property="X",ease="In",value=x-startOffset+offset},{property="Y",ease="In",value=y-startOffset+offset},{property="Z",value=z-3}},duration=0.3}

                keyframes[#keyframes+1] = {properties={{property="X",ease="In",value=x},{property="Y",ease="In",value=y},{property="Z",value=z-floors}},duration=0}

                keyframes[#keyframes+1] = {properties={{property="Z",value=z-floors}},duration=0.0}
                keyframes[#keyframes+1] = {properties={{property="X",value=x},{property="Y",value=y}},duration=0.0}
                Net.animate_player_properties(player_id, keyframes)
                await(Async.sleep(0.32))
                Net.unlock_player_input(player_id)
                dropping[player_id] = false

                end
            elseif direction == "Up Right" then 
                if x <= ice_x+1 and x >= ice_x and y <= ice_y-.03125 and y >= ice_y-1 and z == ice_z then
                local floors = ice_z-drop_z
                local offset = 0
                if floors % 2 == 0 then
                    offset = math.ceil(floors/2)
                    dropOffset = 0
                else
                    offset = math.ceil(floors/2)-.5
                    dropOffset = 1
                end
                dropping[player_id] = true
                Net.lock_player_input(player_id)
                Net.animate_player(player_id, "IDLE_UR", true)
                startOffset = math.ceil(3/2)-.5
                local keyframes = {{properties={{property="X",value=x-startOffset},{property="Y",value=y-startOffset},{property="Z",value=z-3}},duration=0.0}}

                keyframes[#keyframes+1] = {properties={{property="X",ease="In",value=x-startOffset+offset},{property="Y",ease="In",value=y-startOffset+offset},{property="Z",value=z-3}},duration=0.3}

                keyframes[#keyframes+1] = {properties={{property="X",ease="In",value=x},{property="Y",ease="In",value=y},{property="Z",value=z-floors}},duration=0}

                keyframes[#keyframes+1] = {properties={{property="Z",value=z-floors}},duration=0.0}
                keyframes[#keyframes+1] = {properties={{property="X",value=x},{property="Y",value=y}},duration=0.0}
                Net.animate_player_properties(player_id, keyframes)
                await(Async.sleep(0.32))
                Net.unlock_player_input(player_id)
                dropping[player_id] = false

                end

            elseif direction == "Down Left" then --borked
                if x >= ice_x and x<= ice_x+1 and y >= ice_y+1.03125 and y <= ice_y+2 and z == ice_z then
                local floors = ice_z-drop_z
                offset = 0
                if floors % 2 == 0 then
                    offset = math.ceil(floors/2)
                    dropOffset = 0
                else
                    offset = math.ceil(floors/2)+.5
                    dropOffset = 1
                end
                dropping[player_id] = true
                Net.lock_player_input(player_id)
                Net.animate_player(player_id, "IDLE_DL", true)
                local keyframes = {{properties={{property="X",value=x},{property="Y",value=y},{property="Z",value=z}},duration=0.0}}
                keyframes[#keyframes+1] = {properties={{property="X",ease="In",value=x+offset},{property="Y",ease="In",value=y+offset},{property="Z",value=z}},duration=0.3}
                keyframes[#keyframes+1] = {properties={{property="Z",value=z-floors}},duration=0.0}
                keyframes[#keyframes+1] = {properties={{property="X",value=x+dropOffset},{property="Y",value=y+dropOffset}},duration=0.0}
                Net.animate_player_properties(player_id, keyframes)
                await(Async.sleep(0.32))
                Net.unlock_player_input(player_id)
                dropping[player_id] = false
                end
            elseif direction == "Down Right" then --working
                if x >= ice_x+1.03125 and x<= ice_x+2 and y >= ice_y and y <= ice_y+1 and z == ice_z then

                local floors = ice_z-drop_z
                    offset = 0
                    if floors % 2 == 0 then
                        offset = math.ceil(floors/2)
                        dropOffset = 0
                    else
                        offset = math.ceil(floors/2)+.5
                        dropOffset = 1
                    end
                    dropping[player_id] = true
                    Net.lock_player_input(player_id)
                    Net.animate_player(player_id, "IDLE_DR", true)
                    local keyframes = {{properties={{property="X",value=x},{property="Y",value=y},{property="Z",value=z}},duration=0}}
                    keyframes[#keyframes+1] = {properties={{property="X",ease="In",value=x+offset},{property="Y",ease="In",value=y+offset},{property="Z",value=z}},duration=0.3}
                    keyframes[#keyframes+1] = {properties={{property="Z",value=z-floors}},duration=0.0}
                    keyframes[#keyframes+1] = {properties={{property="X",value=x+dropOffset},{property="Y",value=y+dropOffset}},duration=0.0}
                    Net.animate_player_properties(player_id, keyframes)
                    await(Async.sleep(0.32))
                    Net.animate_player(player_id, "IDLE_DR", true)
                    Net.unlock_player_input(player_id)
                    dropping[player_id] = false
                end
            end
        end
    end)
end

Net:on("player_move", function(event)
    -- checks if player is in an area with ice drops
    local area_id = Net.get_player_area(event.player_id)
    if has_value(drop_areas,area_id) and dropping[event.player_id] == false then
        for i,drop in pairs(ice_cache[area_id]) do
            -- checks if player is on the right Z for the given ice drop
            if event.z == drop.z then
                handle_ice_drop(event.player_id, event.x, event.y, event.z, drop.x, drop.y, drop.z, drop.custom_properties["Landing"], drop.custom_properties["Drop Edge"], "Up Left")
            end
        end
    end 
end)

find_drops()

Net:on("player_join", function(event)
    dropping[event.player_id] = false
end)

Net:on("player_disconnect", function(event)
    dropping[event.player_id] = false
end)

