

local libs2config = require('org_github_arosecra/config');
local libs2imgui = require('org_github_arosecra/imgui');
local imgui = require('imgui');
local character_treenode = {};


character_treenode.draw = function(runtime_config, name, mainjob, subjob)
    if imgui.TreeNode(name .. ' (' .. mainjob .. ')') then
                    
        local settings = libs2config.get_string_table(addon.name, mainjob, "Settings");
        settings:each(function(setting, setting_index)
            local setting_name = AshitaCore:GetConfigurationManager():GetString(addon.name, "Settings", setting .. '.Name');
            local setting_values = libs2config.get_string_table(addon.name, "Settings", setting .. '.Values');
            local selected_value = ""
            if runtime_config[name] ~= nil and runtime_config[name][setting_name] ~= nil then
                selected_value = setting_values[runtime_config[name][setting_name]]
            end

            if imgui.BeginCombo(setting_name, selected_value, 0) then
                for j=1,#setting_values do
                    local selected = runtime_config[name][setting_name] == j;
                    if imgui.Selectable(setting_values[j], selected) then
                        runtime_config[name][setting_name] = j;
                    end

                    if selected then
                        imgui.SetItemDefaultFocus();
                    end
                end
                imgui.EndCombo();
            end

        end);
    end
end


return character_treenode;