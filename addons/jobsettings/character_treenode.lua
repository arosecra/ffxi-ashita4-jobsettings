

local libs2config = require('org_github_arosecra/config');
local libs2imgui = require('org_github_arosecra/imgui');
local macros_configuration = require('org_github_arosecra/macros/macros_configuration');
local macros_runner = require('org_github_arosecra/macros/macrorunner');
local imgui = require('imgui');
local setting = require('setting');
local character_treenode = {};


character_treenode.draw = function(runtime_config, name, mainjob, subjob)
    if imgui.TreeNode(name .. ' (' .. mainjob .. ')') then
                    
        local settings = libs2config.get_string_table(addon.name, mainjob, "Settings");
        settings:each(function(setting_array_name, setting_index)
            local setting_name = AshitaCore:GetConfigurationManager():GetString(addon.name, "Settings", setting_array_name .. '.Name');
            local setting_values = libs2config.get_string_table(addon.name, "Settings", setting_array_name .. '.Values');

            if setting_name ~= nil and setting_values ~= nil then
                
                local selected_value = ""
                if runtime_config[name] ~= nil and runtime_config[name][setting_name] ~= nil then
                    selected_value = setting_values[runtime_config[name][setting_name]]
                end

                character_treenode.draw_combo(runtime_config, name, setting_name, setting_values, selected_value);
            end

        end);
    end
end

character_treenode.draw_combo = function(runtime_config, name, setting_name, setting_values, selected_value)

    if imgui.BeginCombo(setting_name, selected_value, 0) then
        for j=1,#setting_values do
            character_treenode.draw_select(runtime_config, name, setting_name, j, setting_values[j])
        end
        imgui.EndCombo();
    end

end


character_treenode.draw_select = function(runtime_config, name, setting_name, index, setting_value)
    local selected = runtime_config[name][setting_name] == index;
    imgui.PushID(name .. setting_name .. setting_value);
    if imgui.Selectable(setting_value, selected) then
        runtime_config[name][setting_name] = index;
        setting.run_macro(setting_name, setting_value);
    end

    if selected then
        imgui.SetItemDefaultFocus();
    end
    imgui.PopID();
end

return character_treenode;