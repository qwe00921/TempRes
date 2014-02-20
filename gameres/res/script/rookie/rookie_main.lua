
--新手引导

rookie_main = {};
local p = rookie_main;

p.userData = nil;
p.stepId = nil;

MAX_STEP = {
		--0,--0
		0,--1
		0,--2
		0,--3
		6,--4
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
		--stepId = 7;	--测试用
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
		if substep == 1 then
			dlg_drama.ShowUI( 3,after_drama_data.ROOKIE,0,0)
		elseif substep == 2 then
			maininterface.ShowUI(p.userData);
			country_main.ShowUI();
			rookie_mask.ShowUI( step, 2 );
		elseif substep == 3 then
			--maininterface.ShowUI();
			--country_main.CloseUI();
			country_main.ShowBuildUP()
			rookie_mask.ShowUI( step, 3 );
		elseif substep == 4 then
			country_building.upBuild();
		end
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
		
		
	end
end

--显示下一步前相关操作，返回true为直接显示下一步，false为不直接显示（发消息给服务端，服务端返回后进入下一步）
function p.DoSomething( step, substep )
	
	return true;
end

--点击高亮区域回调
--step：步骤 substep：分步骤 index：N个高亮按钮可能值范围为1-N
function p.MaskTouchCallBack( step, substep, index )
	--更新步骤
	local flag = p.DoSomething( step, substep );
	if flag then
		local curstep = step;
		local cursubstep = substep;
		local maxstep = MAX_STEP[tonumber(step)];
		if substep >= maxstep then
			curstep = curstep + 1;
			cursubstep = 1;
		else
			cursubstep = cursubstep + 1;
		end
		p.ShowLearningStep( curstep, cursubstep );
	end
end

--剧情回调
function p.dramaCallBack(storyId)
	if storyId == 10 then
		if maininterface.m_bgImage then
			maininterface.m_bgImage:SetVisible(true);
		end
		p.ShowLearningStep( 9, 2 );
	elseif storyId == 2 then
	elseif storyId == 3 then
		p.ShowLearningStep( p.stepId, 2 )
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
