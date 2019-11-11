-- b21_analysis.lua

print("b21_analysis.lua startup")

-- -------------------------
-- STARTUP CODE
components = {}

local analysis_window -- ContextWindow object for Analysis Window
local red = { 1.0, 0.0, 0.0, 1.0 }
local blue = { 0.0, 0.0, 1.0, 1.0 }

-- MENU CODE
--
local debug_menu_item_id

-- forward reference so we can put functions at end of file
local open_analysis_window
local test_update
-- project menu "Analysis Window" callback
function analysis_window()
    print("analysis_window() called on menu click")
    open_analysis_window()
end
--[[function test_update()
    update_analysis_window()
end
--]]

analysis_menu_item_id = sasl.appendMenuItem(globals.analysis_menu_id, "Analysis Window", analysis_window)
-- update_menu_item_id = sasl.appendMenuItem(globals.analysis_menu_id, "Update Analysis Window", test_update)
--
-- END MENU CODE
--
-- END STARTUP CODE
-- ------------------------------------

-- Open the "Analysis Window" on-screen
open_analysis_window = function ()
    print("open_ analysis_window() called on menu click")

    analysis_window = contextWindow {
        name = "B21 Soaring Analysis",
        position = { 50, 200, 300, 200 },
        visible = true,
        noBackground = false,
        minimumSize = { 100, 100 },
        maximumSize = { 1000, 1000 },
        gravity = { 0, 1, 0, 1 },
        components = {
            b21_analysis_content { position = { 0,0,300,200 }}
        }
    }

end

-- update "Analysis Window"
update_analysis_window = function ()
    print("update_analysis_window() called on menu click")
end
