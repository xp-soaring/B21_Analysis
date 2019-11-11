-- b21_chart_content.lua

local POLAR_WET = {{85,0.9},{90,0.71},{95,0.64},{100,0.61},{125,0.7},{150,0.9},{175,1.23},{200,1.7},{225,2.31}}
local POLAR_DRY = {{75,0.5},{80,0.48},{85,0.47},{90,0.49},{95,0.52},{100,0.55},{105,0.58},{110,0.63},{125,0.8},{150,1.25},{175,1.85}}

local FLAP_LABELS = {"1","2","3","4","5","T","L"}

components = {
	-- textureLit	{ position = {0, 0, 512, 512}, image = background }
}

local white = { 1.0, 1.0, 1.0, 1.0 }
local gray = { 0.5, 0.5, 0.5, 1.0 }
local red = { 1.0, 0.0, 0.0, 1.0 }
local darkred = { 0.5, 0.0, 0.0, 1.0 }
local pink = { 1.0, 0.3, 0.3, 1.0 }
local green = { 0.0, 1.0, 0.0, 1.0 }
local darkgreen = {0.0, 0.5, 0.0, 1.0 }
local lightgreen = { 0.3, 1.0, 0.3, 1.0 }
local blue = { 0.0, 0.0, 1.0, 1.0 }
local darkblue = { 0.0, 0.0, 0.5, 1.0 }
local lightblue = { 0.3, 0.3, 1.0, 1.0 }
local yellow = { 1.0, 1.0, 0.0, 1.0 }
local darkyellow = { 0.5, 0.5, 0.0, 1.0 }
local magenta = { 1.0, 0.0, 1.0, 1.0 }
local cyan = { 0.0, 1.0, 1.0, 1.0 }
local black = { 0.0, 0.0, 0.0, 1.0 }

local COLOR_BACKGROUND=white
local COLOR_AXIS=black
local COLOR_SCALE=black
local COLOR_MINOR_GRID=gray
local COLOR_POLAR_DRY=black
local COLOR_POLAR_WET=black
local COLOR_CHART_LINE = { darkgreen, darkred, darkblue, darkyellow, red, cyan, magenta }
local PATTERN_CHART_LINE = { {7,0},{7,-1},{7,-2},{7,-3},{7,-4},{7,-5},{7,-6} }


-- local arial_font = sasl.gl.loadFont("Resources/plugins/B21_Soaring/data/modules/Custom Module/tachometer/arial20.fnt")
local font = sasl.gl.loadFont("resources/UbuntuMono-Regular.ttf")

local b21_total_energy_mps = globalPropertyf("b21_soaring/total_energy_mps")
local DATAREF_TIME_S = globalPropertyf("sim/network/misc/network_time_sec")
local sim_speed_mps = globalPropertyf("sim/flightmodel/position/true_airspeed")
local pause = globalPropertyf("sim/time/paused") -- check if sim is paused
local DATAREF_FLAP_COUNT = globalPropertyi("sim/aircraft/controls/acf_flap_detents")
local DATAREF_FLAP_RATIO = globalPropertyf("sim/flightmodel2/controls/flap_handle_deploy_ratio")

local FLAP_COUNT = get(DATAREF_FLAP_COUNT)
print("FLAP_COUNT",FLAP_COUNT)

-- width & height of chart window in pixels
local w = size[1] -- remember Lua arrays first element is [1]
local h = size[2]

-- axis coordinates are { { value1, value2 }, {pixel1, pixel2} }
local SPEED_AXIS = { {60.0, 225.0}, { 40.0, w-20} } -- values in kph, pixels
local SINK_AXIS = { { 0.0, 4.0 }, { h-100, 10} } -- values in mps, pixels

local SPEED_MAJOR = 20 -- vertical lines every 20 kmh
local SPEED_MINOR_STEPS = 4
local SPEED_MINOR = SPEED_MAJOR / SPEED_MINOR_STEPS

local SINK_MAJOR = 0.5 -- horizontal lines every 0.5 m/s
local SINK_MINOR_STEPS = 5
local SINK_MINOR = SINK_MAJOR / SINK_MINOR_STEPS

local RESET_BUTTON = { 10, h-40, 100, 30, black } -- x,y,w,h
local CLEAR_BUTTON = { 120, h-40, 100, 30, black } -- x,y,w,h

local chart_line_index = 1
local chart_lines -- initialized with init_chart_lines() to { {0}, {0}, ... {0} }

local polar_line_wet = {}
local polar_line_dry = {}

local prev_time_s = 0.0

-- return true if mouse click x,y within bounds of button
function in_button(x,y,button)
    if x < button[1]
        or x > button[1] + button[3]
        or y < button[2]
        or y > button[2] + button[4]
    then
        return false
    end
    return true
end

function init_chart_lines()
	chart_lines = {}
	for i = 1, FLAP_COUNT+1
	do
		table.insert(chart_lines,{0})
	end
end

-- check mouse down to see if button clicked
function onMouseDown(component, x, y, button, parentX, parentY)
    if button == MB_LEFT and in_button(x,y,RESET_BUTTON)
    then
        print('reset button clicked')
        init_chart_lines()
        chart_line_index = 1
        return
    end
    if button == MB_LEFT and in_button(x,y,CLEAR_BUTTON)
    then
        print('clear button clicked')
        chart_lines[chart_line_index] = {0}
        return
    end

end

function speed_to_x(speed)
	local x = (speed - SPEED_AXIS[1][1]) / (SPEED_AXIS[1][2] - SPEED_AXIS[1][1]) *
				(SPEED_AXIS[2][2] - SPEED_AXIS[2][1]) + SPEED_AXIS[2][1]
	return x
end

function sink_to_y(sink)
	local y = (sink - SINK_AXIS[1][1]) / (SINK_AXIS[1][2] - SINK_AXIS[1][1]) *
				(SINK_AXIS[2][2] - SINK_AXIS[2][1]) + SINK_AXIS[2][1]
	return y
end

-- create polar_line values
for i = 1, #POLAR_WET
do
	local x = speed_to_x(POLAR_WET[i][1])
	local y = sink_to_y(POLAR_WET[i][2])
	table.insert(polar_line_wet,x)
	table.insert(polar_line_wet,y)
end
for i = 1, #POLAR_DRY
do
	local x = speed_to_x(POLAR_DRY[i][1])
	local y = sink_to_y(POLAR_DRY[i][2])
	table.insert(polar_line_dry,x)
	table.insert(polar_line_dry,y)
end

-- Draw reset button
function draw_reset_button()
    sasl.gl.drawRectangle(RESET_BUTTON[1], RESET_BUTTON[2], RESET_BUTTON[3], RESET_BUTTON[4], RESET_BUTTON[5])
    sasl.gl.drawText(font, RESET_BUTTON[1]+3,RESET_BUTTON[2]+3,"RESET",20,false,false,TEXT_ALIGN_LEFT,white)
end

-- Draw clear button
function draw_clear_button()
    sasl.gl.drawRectangle(CLEAR_BUTTON[1], CLEAR_BUTTON[2], CLEAR_BUTTON[3], CLEAR_BUTTON[4], CLEAR_BUTTON[5])
    sasl.gl.drawText(font, CLEAR_BUTTON[1]+3,CLEAR_BUTTON[2]+3,"CLEAR",20,false,false,TEXT_ALIGN_LEFT,white)
end

-- Add buttons to Polar Analysis window
function draw_buttons()
    draw_reset_button()
    draw_clear_button()
end

-- Draw horizontal axis and vertical grid
function draw_speed_axis()
	sasl.gl.setLinePattern({ 5.0, -2.0 }) -- minor grid line pattern
	--sasl.gl.drawLine(5, 200, 200, 200, white )
	-- draw major speed grid lines
	local speed = SPEED_AXIS[1][1]
	while speed <= SPEED_AXIS[1][2]
	do
		local x = speed_to_x(speed)
		sasl.gl.drawLine(x, SINK_AXIS[2][1]+5, x, SINK_AXIS[2][2], COLOR_AXIS )
		local speed_str = tostring(math.floor(speed+0.001))
		sasl.gl.drawText(font,x-5,SINK_AXIS[2][1]+5,speed_str,16,false,false,TEXT_ALIGN_LEFT,COLOR_SCALE)
		for i = 1, SPEED_MINOR_STEPS-1
		do
			x = speed_to_x(speed + i * SPEED_MINOR)
			sasl.gl.drawLinePattern(x, SINK_AXIS[2][1], x, SINK_AXIS[2][2], false, COLOR_MINOR_GRID )
		end
		speed = speed + SPEED_MAJOR
	end
end

-- Draw vertical axis and horizontal grid
function draw_sink_axis()
	sasl.gl.setLinePattern({ 5.0, -2.0 }) -- minor grid line pattern
	local sink = SINK_AXIS[1][1]
	while sink <= SINK_AXIS[1][2]
	do
		local y = sink_to_y(sink)
		sasl.gl.drawLine(SPEED_AXIS[2][1]-5, y, SPEED_AXIS[2][2], y, COLOR_AXIS )
		local sink_str = tostring(math.floor(sink*10.0)/10.0)
		sasl.gl.drawText(font,5,y-5,sink_str,16,false,false,TEXT_ALIGN_LEFT,COLOR_SCALE)
		for i = 1, SINK_MINOR_STEPS-1
		do
			y = sink_to_y(sink + i * SINK_MINOR)
			sasl.gl.drawLinePattern(SPEED_AXIS[2][1], y, SPEED_AXIS[2][2], y, false, COLOR_MINOR_GRID )
		end
		sink = sink + SINK_MAJOR
	end
end

function draw_polar()
	sasl.gl.setLinePattern({ 5.0, -2.0 }) -- minor grid line pattern
	sasl.gl.drawPolyLinePattern(polar_line_wet, COLOR_POLAR_WET)
	sasl.gl.drawPolyLinePattern(polar_line_dry, COLOR_POLAR_DRY)
end

function draw_axes()
	draw_speed_axis()
	draw_sink_axis()
end

function draw_line(i)
	-- do not draw line if chart_line still in init state
	if chart_lines[i][1] == 0
	then
		return
	end
	-- ok have confirmed chart_line doesn't start with 0, so can draw line
	sasl.gl.setLinePattern(PATTERN_CHART_LINE[i])
	sasl.gl.drawPolyLine(chart_lines[i], COLOR_CHART_LINE[i])
end

function draw_graph()
    for i = 1,#chart_lines
    do
        draw_line(i)
    end
end

-- STARTUP
init_chart_lines()

-- on each update we try and append a new point to the polar chart
function update()
	local speed_kph = get(sim_speed_mps) * 3.6

	-- do nothing if speed below min polar speed (e.g. 60 kph)
	if speed_kph < SPEED_AXIS[1][1]
	then
		return
	end

	local time_s = get(DATAREF_TIME_S)

	-- do nothing if less than a second since last update
	if time_s < prev_time_s + 1
	then
		return
	end

	prev_time_s = time_s

	local sink_mps = -get(b21_total_energy_mps)

	-- do nothing if aircraft isn't actually sinking
	if sink_mps < 0
	then
		return
	end

	-- don't update if paused
	if get(pause) == 1
	then
		return
	end

	-- flap setting as index into flap count
	local flap_setting = math.floor(get(DATAREF_FLAP_RATIO) * FLAP_COUNT + 0.5)

	chart_line_index = flap_setting + 1
	
	-- OK speed/sink data looks ok, add to curve
	-- append point to polar curve
	local x = speed_to_x(speed_kph)
	local y = sink_to_y(sink_mps)

	-- if chart_line still {0,0} then set to {x,y}
	if chart_lines[chart_line_index][1] == 0
	then
		chart_lines[chart_line_index] = { x, y }
		print("polar init",chart_line_index,x,y)
		return
	end

	-- otherwise iterate through chart_line to get index to insert x and y
	local i = 1
	while i <= #chart_lines[chart_line_index]
	do
		if chart_lines[chart_line_index][i] > x
		then
			break
		end
		i = i + 2 -- chart_line is pairs of numbers
	end
	-- now i is index of x, y we want to insert
	table.insert(chart_lines[chart_line_index], i, x)
	table.insert(chart_lines[chart_line_index], i +1, y)

	print("polar logging "..chart_line_index.." ["..i.."/"..#chart_lines[chart_line_index].."]",x,y)
end

function draw()

	sasl.gl.drawRectangle(0,0,w,h,COLOR_BACKGROUND)

	drawAll(components)

	--sasl.gl.drawLine(20, 20, w-20, h-20, white)

    draw_buttons()
	draw_axes()
	draw_polar()
	draw_graph()

end
