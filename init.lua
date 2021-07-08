--[[
    Minetest Random Teleport Mod
    Version: 1.0.2
    License: GNU Affero General Public License version 3 (AGPLv3)
]]--

local players = {}

-- Register the random teleport command "/rtp".
minetest.register_chatcommand("rtp", {
    description = "Random Teleport",
    privs = {
        interact = true,
    },
    func = function(name)
        local teleporting = false

        -- Check if the player's name exists in the cooldown timer table.
        for k, v in pairs(players) do
            if v == name then
                teleporting = true
                break
            end
        end

        if teleporting == false then
            table.insert(players, name) -- Insert the player's name into the cooldown timer table.
            local player = minetest.get_player_by_name(name) -- The player who entered the command.
            local old_pos = player:getpos() -- The current position of the player.
            
            -- Create a random position.
            local x = math.random(-30000, 30000)
            local y = 0
            local z = math.random(-30000, 30000)
            local pos = vector.new(x, y, z)
            local failed = false

            -- Move the player to the random position.
            player:setpos(pos)

            minetest.chat_send_player(name, "Teleporting...")
                
            -- Wait 3 seconds for the world to generate around the player, then move the player to the surface.
            minetest.after(3, function()
                local node_name = minetest.get_node(player:getpos()).name -- Get the name of the node at the player's position.
        
                while node_name ~= "air" do

                    -- Move the player up 1 node on the y axis and update the node_name variable.
                    y = y + 1
                    local pos = vector.new(x, y, z)
                    player:setpos(pos)
                    node_name = minetest.get_node(player:getpos()).name

                    -- If the player is not at the surface after moving up 500 nodes, return the player to their original position.
                    if y > 500 then
                        player:setpos(old_pos)
                        failed = true
                        break
                    end
        
                end
        
                if failed == true then
                    minetest.chat_send_player(name, "Teleportation failed! Returned to " .. minetest.pos_to_string(player:getpos()) .. ".")
                else
                    minetest.chat_send_player(name, "Teleported to " .. minetest.pos_to_string(player:getpos()) .. ".")
                end
            end)

            -- Remove the player's name from the cooldown timer table after 10 seconds.
            minetest.after(10, function()
                for k, v in pairs(players) do
                    if v == name then
                        table.remove(players, k)
                        break
                    end
                end
            end)

        else
            minetest.chat_send_player(name, "Please wait a few seconds before using /rtp again.")
        end          
    end,
})