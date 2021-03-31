
addon.name      = 'jobsettings';
addon.author    = 'arosecra';
addon.version   = '1.0';
addon.desc      = '';
addon.link      = '';

local imgui = require('imgui');
local common = require('common');

local libs2config = require('org_github_arosecra/config');
local libs2imgui = require('org_github_arosecra/imgui');
local jobs = require('org_github_arosecra/jobs');

local jobsettings_window = {
    is_open                 = { true }
};

local runtime_config = {

};

ashita.events.register('load', 'jobsettings_load_cb', function ()
    print("[jobsettings] 'load' event was called.");
	AshitaCore:GetConfigurationManager():Load(addon.name, 'jobsettings\\jobsettings.ini');
    
end);

ashita.events.register('command', 'jobsettings_command_cb', function (e)
    if (not e.command:startswith('/jobsettings') and not e.command:startswith('/js')) then
		return;
    end
    jobsettings_window.is_open = not jobsettings_window.is_open;
    e.blocked = true;
end);

ashita.events.register('d3d_beginscene', 'jobsettings_beginscene_callback1', function (isRenderingBackBuffer)
	local memoryManager = AshitaCore:GetMemoryManager();
	local party = memoryManager:GetParty();
	
	for i=0,5 do
		local mainjob = jobs[party:GetMemberMainJob(i)];
		local subjob = jobs[party:GetMemberSubJob(i)];
		local name = party:GetMemberName(i);
        if mainjob ~= nil then
            if runtime_config[name] == nil or runtime_config[name].MainJob ~= mainjob then
                runtime_config[name] = {};
                runtime_config[name].MainJob = mainjob;
                local settings = libs2config.get_string_table(addon.name, mainjob, "Settings");
                    settings:each(function(setting, setting_index)
                        local setting_name = AshitaCore:GetConfigurationManager():GetString(addon.name, "Settings", setting .. '.Name');
                        local setting_values = libs2config.get_string_table(addon.name, "Settings", setting .. '.Values');
                        local default = AshitaCore:GetConfigurationManager():GetString(addon.name, "Settings", setting .. '.Default');

                        local default_index, default_value = setting_values:find(function(index, value)
                            return value == default;
                        end);
                        runtime_config[name][setting_name] = default_index;
                    end);
            end

        end

		runtime_config[name .. ".MainJob"] = mainjob;
		runtime_config[name .. ".SubJob"] = subjob;
	end
end);


ashita.events.register('d3d_present', 'jobsettings_present_cb', function ()
	
	local playerEntity = GetPlayerEntity();
	if playerEntity == nil then
		return;
	end
	
	local windowStyleFlags = libs2imgui.gui_style_table_to_var("imguistyle", "left_drawer", "window.style");
	local tableStyleFlags = libs2imgui.gui_style_table_to_var("imguistyle", addon.name, "table.style");
	libs2imgui.set_left_drawer_window(addon.name);
    if jobsettings_window.is_open then
        if imgui.Begin(addon.name, jobsettings_window.is_open, windowStyleFlags) then
           imgui.SetCursorPosX(450);
           if(imgui.SmallButton("v")) then
               jobsettings_window.is_open = false;
           end
           imgui.Separator();


           
        local memoryManager = AshitaCore:GetMemoryManager();
        local party = memoryManager:GetParty();
        
        for i=0,5 do
            local mainjob = jobs[party:GetMemberMainJob(i)];
            local subjob = jobs[party:GetMemberSubJob(i)];
            local name = party:GetMemberName(i);
            
            if mainjob ~= nil then --alter egos have no job
            
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


                    --local item_curr_index = 2;
                    --if imgui.BeginCombo("Items", settings[item_curr_index], 0) then
                    --    for j=1,3 do
                    --        local is_selected = (item_curr_index == j);
                    --        if(imgui.Selectable(settings[j], is_selected)) then
                    --            print(j)
                    --            item_curr_index = j;
                    --        end
                    --        if is_selected then
                    --            imgui.SetItemDefaultFocus();
                    --        end
                    --    end
                    --    imgui.EndCombo();
                    --end
                    
                    --const char* items[] = { "AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIII", "JJJJ", "KKKK", "LLLLLLL", "MMMM", "OOOOOOO" };
                    --static int item_current_idx = 0; // Here we store our selection data as an index.
                    --const char* combo_label = items[item_current_idx];  // Label to preview before opening the combo (technically it could be anything)
                    --if (ImGui::BeginCombo("combo 1", combo_label, flags))
                    --{
                    --    for (int n = 0; n < IM_ARRAYSIZE(items); n++)
                    --    {
                    --        const bool is_selected = (item_current_idx == n);
                    --        if (ImGui::Selectable(items[n], is_selected))
                    --            item_current_idx = n;
                    --    
                    --        // Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
                    --        if (is_selected)
                    --            ImGui::SetItemDefaultFocus();
                    --    }
                    --    ImGui::EndCombo();
                    --}
                end
            end
        end

        end
        imgui.End();
    end
end);