
--新手引导

rookie_main = {};
local p = rookie_main;

p.userData = nil;
p.stepId = nil;

--每个步骤的分步骤数量配置
local MAX_STEP = 
	{
		0,--1
		0,--2
		0,--3
		0,--4
		0,--5
		0,--6
		0,--7
		0,--8
		0,--9
		0,--10
		0,--11
		0,--12
		0,--13
		0,--14
	};

function p.getRookieStep(backData)
	if backData.result == false then
		dlg_msgbox.ShowOK("错误提示",backData.message,nil,p.layer);
		return;
	elseif backData.result == true then
		local stepId = tonumber(backData.user.Guide_id)
		--stepId = 2;	--测试用
		p.stepId = stepId;
		p.userData = backData.user;
		if stepId == 0 then
			maininterface.ShowUI(backData.user);
		else
			p.ShowLearningStep( stepId, 1 );
		end
	end
end

--进入新手引导
function p.ShowLearningStep( step, substep )
	WriteConErr("rookie step = "..step .. " substep = " .. substep);

	if step == 1 then
		WriteConErr("step error");
	elseif step == 2 then
		start_game.ShowUI();
	elseif step == 3 then
		choose_card.CloseUI()
		--dlg_drama.ShowUI( 3,after_drama_data.ROOKIE,0,0,maininterface.ShowUI)
		maininterface.ShowUI(p.userData);
	elseif step == 4 then
		maininterface.ShowUI(p.userData);
	elseif step == 5 then
		maininterface.ShowUI(p.userData);
	elseif step == 6 then
		maininterface.ShowUI(p.userData);
	elseif step == 7 then
		maininterface.ShowUI(p.userData);
	elseif step == 8 then
		if substep == 1 then
			dlg_drama.ShowUI( 8, after_drama_data.ROOKIE, 0, 0);
		elseif substep == 2 then
			dlg_drama.ShowUI( 9, after_drama_data.ROOKIE, 0, 0);
		end
	elseif step == 9 then
		if substep == 1 then
			dlg_drama.ShowUI( 10, after_drama_data.ROOKIE, 0, 0);
		elseif substep == 9 then
			dlg_drama.ShowUI( 11, after_drama_data.ROOKIE, 0, 0);
		else
			if substep == 2 then
				country_main.ShowUI();
			elseif substep == 3 then
				country_mixhouse.ShowUI();
			elseif substep == 4 then
				country_mixhouse.HideUI();
				country_mix.ShowUI( 1 );--打开回复药合成
			elseif substep == 5 then
				country_mixhouse.DidMix( country_mix.drug_mix_id, nil, country_mix.MixCallBack );
			elseif substep == 6 then
				country_mixhouse.SendMixRequest( 1 );
				country_mix.CloseUI();
				country_mixhouse.ShowUI();
			elseif substep == 7 then
				country_mixhouse.CloseUI();
				country_main.ShowUI();
			elseif substep == 8 then
				
			end
			rookie_mask.ShowUI( step, substep );
		end
	elseif step == 10 then
		dlg_drama.ShowUI( 12, after_drama_data.ROOKIE, 0, 0);
	elseif step == 11 then
		if substep == 1 then
			dlg_drama.ShowUI( 13, after_drama_data.ROOKIE, 0, 0);
		elseif substep == 7 then
			dlg_drama.ShowUI( 14, after_drama_data.ROOKIE, 0, 0);
		elseif substep == 5 then
			
		else
			if substep == 2 then
			elseif substep == 3 then
			elseif substep == 4 then
			elseif substep == 6 then
			end
			rookie_mask.ShowUI( step, substep );
		end
	elseif step == 12 then
		maininterface.ShowUI(p.userData);
	elseif step == 13 then
		dlg_drama.ShowUI( 16, after_drama_data.ROOKIE, 0, 0);
	elseif step == 14 then
		
		
		
	end
end

--点击高亮区域回调
function p.MaskTouchCallBack( step, substep )
	rookie_mask.CloseUI();

	--更新步骤
	local maxsubstep = MAX_STEP[step] or 0;
	local curstep = step;
	local cursubstep = substep;
	if cursubstep >= maxsubstep then
		curstep = curstep + 1;
		cursubstep = 1;
	else
		cursubstep = cursubstep + 1;
	end
	p.ShowLearningStep( curstep, cursubstep );
end

--获取高亮区域
function p.GetHighLightRectList( step, substep )
	local rect = CCRectMake( 0, 0, 0, 0 );
	if step == 1 then
		
	elseif step == 2 then
		
	elseif step == 3 then
		
	elseif step == 4 then
		
	elseif step == 5 then
		
	elseif step == 6 then
		
	elseif step == 7 then
		
	elseif step == 8 then
		
	elseif step == 9 then
		if substep == 2 then
			local layer = country_main.layer;
			local tag = ui_country.ID_CTRL_BUTTON_MERGE;
			if layer ~= nil then
				local ctrl = GetButton( layer, tag );
				rect = ctrl:GetFrameRect();
			end	
		elseif substep == 3 then
			local layer = country_mixhouse.layer;
			local tag = ui_country_produce_list.ID_CTRL_VERTICAL_LIST_16;
			if layer ~= nil then
				local ctrl = GetListBoxVert( layer, tag );
				local view = ctrl:GetViewAt( 0 );
				if view then
					rect = view:GetScreenRect();
				end
			end
		elseif substep == 4 then
			local layer = country_mix.layer;
			local tag = ui_item_produce.ID_CTRL_BUTTON_8;
			if layer ~= nil then
				local ctrl = GetButton( layer, tag );
				rect = ctrl:GetFrameRect();
			end
		elseif substep == 5 then
			local layer = country_mix.layer;
			local tag = ui_item_produce.ID_CTRL_BUTTON_RETURN;
			if layer ~= nil then
				local ctrl = GetButton( layer, tag );
				rect = ctrl:GetFrameRect();
			end
		elseif substep == 6 then
			local layer = country_mixhouse.layer;
			local tag = ui_country_produce_list.ID_CTRL_BUTTON_RETURN;
			if layer ~= nil then
				local ctrl = GetButton( layer, tag );
				rect = ctrl:GetFrameRect();
			end
		elseif substep == 7 then
			
		elseif substep == 8 then
		end
	elseif step == 10 then
		
	elseif step == 11 then
		
	elseif step == 12 then
		
	elseif step == 13 then
		
	elseif step == 14 then
		
	end
	return rect;
end

--获取响应区域
function p.GetDelegateArea( step, substep )
	local rect =  CCRectMake( 0, 0, 0, 0 );
	if step == 1 then
		
	elseif step == 2 then
		
	elseif step == 3 then
		
	elseif step == 4 then
		
	elseif step == 5 then
		
	elseif step == 6 then
		
	elseif step == 7 then
		
	elseif step == 8 then
		
	elseif step == 9 then
		
	elseif step == 10 then
		
	elseif step == 11 then
		
	elseif step == 12 then
		
	elseif step == 13 then
		
	elseif step == 14 then
		
	end
	return rect;
end

function p.dramaCallBack(storyId)
	if storyId == 1 then
	elseif storyId == 2 then
	elseif storyId == 3 then
	elseif storyId == 4 then
	elseif storyId == 5 then
	elseif storyId == 6 then
	elseif storyId == 7 then
	elseif storyId == 8 then
	elseif storyId == 9 then
	elseif storyId == 10 then
	elseif storyId == 11 then
	elseif storyId == 12 then
	elseif storyId == 13 then
	elseif storyId == 14 then
	elseif storyId == 15 then
	elseif storyId == 16 then
	elseif storyId == 17 then
	end
end
