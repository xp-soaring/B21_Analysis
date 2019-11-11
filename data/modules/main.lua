
-- B21_Soaring

size = { 2048, 2048 }

globals = {}
globals.main_menu_item_id = sasl.appendMenuItem(PLUGINS_MENU_ID, "B21 Analysis")
-- create sub-menu beneath "B21 Analysis"
globals.analysis_menu_id = sasl.createMenu("B21 Analysis", PLUGINS_MENU_ID, globals.main_menu_item_id)

print("B21_Soaring loading...")

components = {
               b21_te {},
               b21_analysis {},
               b21_chart {}
             }

