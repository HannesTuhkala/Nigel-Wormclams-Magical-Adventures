local draw = {}

local constants = require('constants')

-- Will only be drawn if tab_index is set to 0. Is called by draw.tabs(tab_index).
draw.inventory = function(inventory)
	for i = 0,3,1 do
		for j = 0,2,1 do
			love.graphics.draw(imgs.invslot, constants.inventory.origin_x + (j * constants.inventory.slot_width),
								constants.inventory.origin_y + (i * constants.inventory.slot_height))
		end
	end
	
	--for i = 0,19,1 do
	--	if not inventory[i+1] then
	--		print()
	--	else
	--		local x, y = 800 + (math.floor(i%3) * 80), 335 + (math.floor(i%4) * 80)
	--		love.graphics.draw(inventory[i+1].image, x, y, 0, 0.1, 0.1)
	--	end
	--end
	
	if not inventory[1] then return end
	love.graphics.draw(inventory[1].image, 800, 335, 0, 0.1, 0.1)
end

-- Draws a context_menu if a player right-clicks on a slot in the inventory tab.
draw.context_menu = function(inv_selected)
	if inv_selected.clicked then
		local x
		local y = inv_selected.y
		
		if inv_selected.mirror then
			x = inv_selected.x - constants.context_menu.width
		else
			x = inv_selected.x
		end
		
		love.graphics.rectangle("fill", x, y, constants.context_menu.width, constants.context_menu.height)
		
		love.graphics.setColor(constants.context_menu.hover_color)
		if inv_selected.hover[1] then
			love.graphics.rectangle("fill", x, y, constants.context_menu.width, constants.context_menu.sub_height)
		elseif inv_selected.hover[2] then
			love.graphics.rectangle("fill", x, y + constants.context_menu.sub_height, constants.context_menu.width, constants.context_menu.sub_height)
		elseif inv_selected.hover[3] then
			love.graphics.rectangle("fill", x, y + constants.context_menu.sub_height * 2, constants.context_menu.width, constants.context_menu.sub_height)
		end
		love.graphics.setColor(1, 1, 1, 1)
		
		x = x + 5
		love.graphics.print({{0, 0, 0, 255}, "Use"}, x, y + 1, 0, 0.6)
		love.graphics.print({{0, 0, 0, 255}, "Drop"}, x, y + 16, 0, 0.6)
		love.graphics.print({{0, 0, 0, 255}, "Cancel"}, x, y + 31, 0, 0.6)
	end
end

-- Decides whether to draw the skills-tab or the inventory tab based on tab_index.
-- inv_selected is used for draw.context_menu to let it know which option the mouse is on.
draw.tabs = function(tab_index, inv_selected, player_attributes, inventory)
	love.graphics.draw(imgs.inventoryIcon, 785, 280)
	love.graphics.draw(imgs.skillsIcon, 905, 280)
	love.graphics.setColor(constants.tabs.selected_color)
	love.graphics.line(795 + (120 * tab_index), 314, 890 + (120 * tab_index), 314)
	love.graphics.setColor(1, 1, 1, 1)
	
	if tab_index == 0 then
		draw.inventory(inventory)
		draw.context_menu(inv_selected)
	elseif tab_index == 1 then
		draw.skills(player_attributes)
	end
end

-- Will only be drawn if tab_index is set to 1. Is called by draw.tabs(tab_index).
draw.skills = function(ply_attr)
	love.graphics.rectangle("fill", 785, 320, 240, 320)
	love.graphics.setColor(constants.tabs.selected_color)
	love.graphics.print("Strength:", 815, 340)
	love.graphics.print(ply_attr.strength, 940, 340)
	love.graphics.print("Intellect:", 815, 390)
	love.graphics.print(ply_attr.intellect, 940, 390)
	love.graphics.print("Speed:", 815, 440)
	love.graphics.print(ply_attr.speed, 940, 440)
	love.graphics.print("Charisma:", 815, 490)
	love.graphics.print(ply_attr.charisma, 940, 490)
	love.graphics.print("Agility:", 815, 540)
	love.graphics.print(ply_attr.agility, 940, 540)
	love.graphics.print("Spirit:", 815, 590)
	love.graphics.print(ply_attr.spirit, 940, 590)
	love.graphics.setColor(1, 1, 1, 1)
end

draw.health_bar = function(health)
	love.graphics.rectangle("line", 250, 590, 400, 40)
	local health_length = 398 * (health/100)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.rectangle("fill", 251, 591, health_length, 39)
	love.graphics.setColor(1, 1, 1, 1)
end

return draw