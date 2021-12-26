

local libs2config = require('org_github_arosecra/config');
local libs2imgui = require('org_github_arosecra/imgui');
local macros_configuration = require('org_github_arosecra/macros/macros_configuration');
local macros_runner = require('org_github_arosecra/macros/macrorunner');
local imgui = require('imgui');
local setting = require('setting');
local character_treenode = {};


character_treenode.draw = function(config, name, mainjob, subjob)
    if imgui.TreeNode(name .. ' (' .. mainjob .. ')') then
        local settingsForJob = config.settings.jobs[mainjob]
		if settingsForJob ~= nil then
			settingsForJob:each(function(setting_array_name, setting_index)
				local sequence = config.settings.sequences[setting_array_name]

				if sequence ~= nil and sequence.Name ~= nil and sequence.Values ~= nil then
					character_treenode.draw_combo(config, name, setting_array_name, sequence);
				end
			
			end);
		end
		imgui.TreePop()
    end
end

character_treenode.draw_combo = function(config, name, setting_array_name, sequence)

	local real_selected_value = ""
	if config.runtime_config.selections[name] ~= nil and config.runtime_config.selections[name][setting_array_name] ~= nil then
		local selected_index = config.runtime_config.selections[name][setting_array_name]
		real_selected_value = sequence.Values[selected_index]
	end

    if imgui.BeginCombo(sequence.Name, real_selected_value, 0) then
        for j=1,#sequence.Values do
			local selected = real_selected_value == sequence.Values[j];
			imgui.PushID(name .. sequence.Name .. sequence.Values[j]);
			if imgui.Selectable(sequence.Values[j], selected) then
				if config.runtime_config.selections[name] == nil then
					config.runtime_config.selections[name] = {}
				end
				config.runtime_config.selections[name][setting_array_name] = j;
				local macro_id = sequence[sequence.Values[j]]
				setting.run_macro(setting_array_name, sequence.Name, sequence.Values[j], name, macro_id);
			end
		
			if selected then
				imgui.SetItemDefaultFocus();
			end
			imgui.PopID();
        end
        imgui.EndCombo();
    end

end

return character_treenode;