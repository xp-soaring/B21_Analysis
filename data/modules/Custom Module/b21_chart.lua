-- b21_chart.lua

print("b21_chart.lua startup")

-- -------------------------
-- STARTUP CODE

components = {}

local chart_window -- ContextWindow object for Chart Window
local red = { 1.0, 0.0, 0.0, 1.0 }
local blue = { 0.0, 0.0, 1.0, 1.0 }

-- MENU CODE
--
local debug_menu_item_id

-- forward reference so we can put functions at end of file
local open_chart_window
local test_update
-- project menu "Analysis Window" callback
function chart_window()
    print("chart_window() called on menu click")
    open_chart_window()
end

analysis_menu_item_id = sasl.appendMenuItem(globals.analysis_menu_id, "Polar Window", chart_window)

-- Open the "Polar Analysis" window on-screen
open_chart_window = function ()
    print("open_chart_window() called on menu click")

    chart_window = contextWindow {
        name = "Polar Analysis",
        position = { 20, 20, 700, 700 },
        visible = true,
        noBackground = false,
        minimumSize = { 100, 100 },
        maximumSize = { 1000, 1000 },
        gravity = { 0, 1, 0, 1 },
        components = {
            b21_chart_content { position = { 0,0,700,700 }}
        }
    }

end
