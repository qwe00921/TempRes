
--新手引导

rookie_main = {};
local p = rookie_main;

p.userData = nil;
p.stepId = nil;

local MAX_STEP = {
		0,--1
		0,--2
		0,--3
		6,--4
		0,--5
		0,--6
		0,--7
		2,--8
		9,--9
		1,--10
		7,--11
		0,--12
		1,--13
		9,--14
	};

function p.getRookieStep(backData)
	if backData.result == false then
		dlg_msgbox.ShowOK("错误提示",backData.message,nil,p.layer);
		return;
	elseif backData.result == true then
		local stepId = tonumber(backData.user.Guide_id)
		--stepId = 7;	--测试用
		p.stepId = stepId;
		p.userData = backData.user;
		if stepId == 0 then
			maininterface.ShowUI(backData.user);
		else
			p.ShowLearningStep( p.stepId, 1 );
		end
	end
end

--进入新手引导
function p.ShowLearningStep( step, substep )
	WriteConErr("rookie step = "..step .. " substep = " .. substep);
	
	rookie_mask.CloseUI();

	if step == 1 then
		WriteConErr("step error");
	elseif step == 2 then
		start_game.ShowUI();
	elseif step == 3 then
		choose_card.CloseUI()
		--第3步为战斗，暂时直接跳过   等思栋接入
		maininterface.ShowUI(p.userData);
		-- local uid = GetUID();
		-- local param = "guide="..(rookie_main.stepId);
		-- SendReq("User","Complete",uid,param);
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
				maininterface.ShowUI( p.userData );
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
			dlg_gacha.ReqStartGacha( 3, 2, 1);
			rookie_mask.ShowUI( step, substep );
		else
			if substep == 2 then
				country_main.ShowUI();
			elseif substep == 3 then
				dlg_gacha.ShowUI( SHOP_ITEM );
			elseif substep == 4 then
				dlg_gacha.ShowGachaData( dlg_gacha.gachadata );
			elseif substep == 6 then
				dlg_gacha_result.ShowUI( dlg_gacha_effect.gacharesult );
				dlg_gacha_effect.HideUI();
				dlg_gacha_effect.CloseUI();
			end
			rookie_mask.ShowUI( step, substep );
		end
	elseif step == 12 then
		maininterface.ShowUI(p.userData);
	elseif step == 13 then
		dlg_drama.ShowUI( 16, after_drama_data.ROOKIE, 0, 0);
	elseif step == 14 then
		if substep == 1 then
			dlg_drama.ShowUI( 17, after_drama_data.ROOKIE, 0, 0);
			do return end;
		elseif substep == 2 then
			country_main.ShowUI();
		elseif substep == 3 then
			equip_room.ShowUI();
		elseif substep == 4 then
			local node = equip_room.GetRookieNode();
			if node then
				equip_room.OnItemClickEvent( node, 1, nil );
			end
		elseif substep == 5 then
			
		elseif substep == 6 then
		elseif substep == 7 then
		elseif substep == 8 then
		elseif substep == 9 then
		end
		rookie_mask.ShowUI( step, substep );
	end
end

--显示下一步前相关操作，返回true为直接显示下一步，false为不直接显示（发消息给服务端，服务端返回后进入下一步）
function p.DoSomething( step, substep, index )
	if step == 9 then
		if substep == 7 then
			if index == 1 then
				country_collect.Collect( E_COLLECT_HOME );
			elseif index == 2 then
				country_collect.Collect( E_COLLECT_FIELD );
			elseif index == 3 then
				country_collect.Collect( E_COLLECT_TREE );
			elseif index == 4 then
				country_collect.Collect( E_COLLECT_RIVER );
			end
		end
	elseif step == 11 then
		if substep == 6 then
			
		end
	end
	return true;
end

--点击高亮区域回调
--step：步骤 substep：分步骤 index：N个高亮按钮可能值范围为1-N
function p.MaskTouchCallBack( step, substep, index )
	--更新步骤
	local flag = p.DoSomething( step, substep, index );
	if flag then
		local curstep, cursubstep = p.UpdateStep( step, substep );
		p.ShowLearningStep( curstep, cursubstep );
	end
end

function p.UpdateStep( step, substep )
	local curstep = step;
	local cursubstep = substep;
	local maxstep = MAX_STEP[tonumber(step)];
	if substep >= maxstep then
		curstep = curstep + 1;
		cursubstep = 1;
	else
		cursubstep = cursubstep + 1;
	end
	return curstep, cursubstep;
end

--剧情回调
function p.dramaCallBack(storyId)
	if storyId == 1 then
	elseif storyId == 2 then
	elseif storyId == 3 then
		p.ShowLearningStep( p.stepId, 2 )
	elseif storyId == 4 then
	elseif storyId == 5 then
	elseif storyId == 6 then
	elseif storyId == 7 then
	elseif storyId == 8 then
		p.ShowLearningStep( 8, 2 );
	elseif storyId == 9 then
		p.ShowLearningStep( 9, 1 );
	elseif storyId == 10 then
		p.ShowLearningStep( 9, 2 );
	elseif storyId == 11 then
		p.ShowLearningStep( 10, 1 );
	elseif storyId == 12 then
		p.ShowLearningStep( 11, 1 );
	elseif storyId == 13 then
		p.ShowLearningStep( 11, 2 );
	elseif storyId == 14 then
		p.ShowLearningStep( 12, 1 );
	elseif storyId == 15 then
	elseif storyId == 16 then
		p.ShowLearningStep( 14, 1 );
	elseif storyId == 17 then
		p.ShowLearningStep( 14, 2 );
	end
end


