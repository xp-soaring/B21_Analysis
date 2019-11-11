-- b21_analysis_content.lua

components = {
	-- textureLit	{ position = {0, 0, 512, 512}, image = background }
}
-- local engn_rpm = globalPropertyf("sim/cockpit2/engine/indicators/engine_speed_rpm[0]", 0)

local FONTSIZE = 18
local LINE_SPACING = 18
local UNITS = "german" -- (knots, knots) vs. "german" (kph, mps), "metric" (mps, mps)

local KG_TO_LBS = 2.20462

local background	= loadImage("resources/tacho_background.png")
local needle		= loadImage("resources/tacho_needle.png")
local white = { 1.0, 1.0, 1.0, 1.0 }
local red = { 1.0, 0.0, 0.0, 1.0 }
local green = { 0.0, 1.0, 0.0, 1.0 }
local blue = { 0.0, 0.0, 1.0, 1.0 }

-- local arial_font = sasl.gl.loadFont("Resources/plugins/B21_Soaring/data/modules/Custom Module/tachometer/arial20.fnt")
local font = sasl.gl.loadFont("resources/UbuntuMono-Regular.ttf")

local DATAREF_TIME_S = globalPropertyf("sim/network/misc/network_time_sec")
local DATAREF_TE_MPS = globalPropertyf("b21_soaring/total_energy_mps")
local DATAREF_SPEED_MPS = globalPropertyf("sim/flightmodel/position/true_airspeed")
local DATAREF_SPEEDBRAKES = globalPropertyf("sim/flightmodel2/controls/speedbrake_ratio")
local DATAREF_FLAPS = globalPropertyfa("sim/flightmodel2/wing/flap1_deg")
-- local sim_cl = globalPropertyf("sim/airfoils/afl_cl")
-- local sim_cd = globalPropertyf("sim/airfoils/afl_cd")
-- local sim_cm = globalPropertyf("sim/airfoils/afl_cm")
local DATAREF_ALPHA = globalPropertyf("sim/flightmodel/position/alpha")
local DATAREF_WEIGHT_KG = globalPropertyf("sim/flightmodel/weight/m_total")
local DATAREF_BALLAST_KG = globalPropertyf("sim/flightmodel/weight/m_jettison")
local DATAREF_LIFT_N = globalPropertyf("sim/flightmodel/forces/lift_path_axis")
local DATAREF_DRAG_N = globalPropertyf("sim/flightmodel/forces/drag_path_axis")

-- each mouse click into the window will switch the UNITS
function onMouseDown(component, x, y, button, parentX, parentY)
	if UNITS == "metric"
	then
		UNITS = "german"
	elseif UNITS == "german"
	then
		UNITS = "uk"
	else
		UNITS = "metric"
	end
end

function draw()
	
	drawAll(components)

	-- 4000 rpm = 270° -> 1 rpm = 0.0675°
	-- texture is vertical so 0 rpm is at -135°
	-- local angle = 2000 -- get(engn_rpm) * 0.0675 - 135
	-- drawRotatedTextureCenter(needle, angle, 256, 256, 240, 294, 32, 128, 1, 1, 1, 1)
	-- sasl.gl.drawLine(20, 20, 50, 50, green)

	local speed_mps = get(DATAREF_SPEED_MPS)
	local total_energy_mps = get(DATAREF_TE_MPS)
	local weight_kg = get(DATAREF_WEIGHT_KG)
	local ballast_kg = get(DATAREF_BALLAST_KG)

	local speed_str
	local sink_str
	local glide_str
	local spoilers_str
	local weight_str
	local ballast_str
	local lift_str
	local drag_str
	local alpha_str

	if UNITS == "metric"
	then
		speed_str = "Speed m/s: "..tostring(math.floor(speed_mps * 100.0) / 100.0) -- floor/divide to set to 2 decimal places
		sink_str = "Sink m/s:  "..tostring(math.floor((-total_energy_mps) * 100.0) / 100.0)
		weight_str = "Weight kg: "..tostring(math.floor(weight_kg + 0.5 ))
		ballast_str = "Ballast kg: "..tostring(math.floor(ballast_kg + 0.5 ))
	elseif UNITS == "german"
	then
		speed_str = "Speed kph: "..tostring(math.floor(speed_mps * 3.6 * 100.0) / 100.0)
		sink_str = "Sink m/s:  "..tostring(math.floor((-total_energy_mps) * 100.0) / 100.0)
		weight_str = "Weight kg: "..tostring(math.floor(weight_kg + 0.5 ))
		ballast_str = "Ballast kg: "..tostring(math.floor(ballast_kg + 0.5 ))
	else -- "uk"
		speed_str = "Speed kts: "..tostring(math.floor(speed_mps * 1.94384 * 100.0) / 100.0)
		sink_str = "Sink kts:  "..tostring(math.floor((-total_energy_mps) * 1.94384 * 100.0) / 100.0)
		weight_str = "Weight lbs: "..tostring(math.floor(weight_kg * KG_TO_LBS + 0.5))
		ballast_str = "Ballast lbs: "..tostring(math.floor(ballast_kg  * KG_TO_LBS + 0.5))
	end

	-- cl_str = "CL: "..tostring(math.floor(get(sim_cl) * 1000.0) / 1000.0)
	-- cd_str = "CD: "..tostring(math.floor(get(sim_cd) * 1000.0) / 1000.0)
	-- cm_str = "CM: "..tostring(math.floor(get(sim_cm) * 1000.0) / 1000.0)
	alpha_str = "Alpha: "..tostring(math.floor(get(DATAREF_ALPHA) * 10.0) / 10.0) -- (degrees) 1 decimal place

	lift_str = "Lift N: "..tostring(math.floor(get(DATAREF_LIFT_N) * 10.0) / 10.0)
	drag_str = "Drag N: "..tostring(math.floor(get(DATAREF_DRAG_N) * 10.0) / 10.0)

	if (total_energy_mps < -0.1) -- limit to avoid silly readings and divide by zero error on pause
	then
		glide_str = "L/D ratio: "..tostring(math.floor(speed_mps / (-total_energy_mps) * 100.0) / 100.0)
	else
		glide_str = "L/D ratio: n/a"
	end 

	local spoilers_str = "Spoilers:  "..tostring(math.floor(get(DATAREF_SPEEDBRAKES) * 10000.0) / 10000.0)

	local flaps_str = "Flaps (deg):  "..tostring(math.floor(get(DATAREF_FLAPS,1) * 100.0) / 100.0)

	-- sasl.gl.drawText(font,30,380,cl_str,40,false,false,TEXT_ALIGN_LEFT,white)
	-- sasl.gl.drawText(font,30,330,cd_str,40,false,false,TEXT_ALIGN_LEFT,white)
	-- sasl.gl.drawText(font,30,280,cm_str,40,false,false,TEXT_ALIGN_LEFT,white)

	local y = size[2]
	local x = 10

	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,ballast_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,weight_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,lift_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,drag_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,alpha_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,spoilers_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,flaps_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,speed_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,sink_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	y = y - LINE_SPACING
	sasl.gl.drawText(font,x,y,glide_str,FONTSIZE,false,false,TEXT_ALIGN_LEFT,white)
	
end
