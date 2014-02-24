
--新手引导

rookie_main = {};
local p = rookie_main;

p.userData = nil;
p.stepId = nil;
p.subStepId = nil;
--是否开启新手测试 true 开启
p.rookieTest = true;

p.tempStep = 0;
p.tempSubTemp = 0;

local MAX_STEP = {
		0,--1
		0,--2
		15,--3
		7,--4
		24,--5
		15,--6
		6,--7
		2,--8
		9,--9
		1,--10
		7,--11
		10,--12
		1,--13
		9,--14
	};
STORY_GUID_3_1 = 1;
STORY_GUID_3_14 = 2;
STORY_GUID_5_1 = 4
STORY_GUID_5_7 = 5
	
	
function p.getRookieStep(backData)
	if backData.result == false then
		dlg_msgbox.ShowOK("错误提示",backData.message,nil,p.layer);
		return;
	elseif backData.result == true then
		local stepId = tonumber(backData.user.Guide_id)
		local subStepId = tonumber(backData.user.Sub_Guide_id)
		--stepId = 7;	--测试用
		p.stepId = stepId;
		p.subStepId = subStepId
		p.userData = backData.user;
		
		if p.tempStep ~= 0 and p.tempSubTemp ~= 0 then
			p.ShowLearningStep( p.tempStep, p.tempSubTemp );
			p.tempStep = 0;
			p.tempSubTemp = 0;
			return;
		end
		
		if p.rookieTest == false then
			maininterface.ShowUI(backData.user);
			return ;
		end;
		
		if stepId == 0 then
			maininterface.ShowUI(backData.user);
		else
			p.ShowLearningStep( p.stepId, p.subStepId );
		end
	end
end

--进入新手引导
function p.ShowLearningStep( step, substep )
	WriteConErr("rookie step = "..step .. " substep = " .. substep);
	rookie_mask.CloseUI();
	
	p.stepId = step;
	p.subStepId = substep;

	if step == 1 then
		WriteConErr("step error");
	elseif step == 2 then
		start_game.ShowUI();
	elseif step == 3 then
		choose_card.CloseUI()
		if p.rookieTest then
			w_battle_guid.fighterGuid(substep);
		else
			maininterface.ShowUI(p.userData);
			return
		end
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
			rookie_mask.ShowUI( step, 4 );
		elseif substep == 5 then
			dlg_msgbox.rookieCloseBtn()
			rookie_mask.ShowUI( step, 5 );
		elseif substep == 6 then
			country_building.CloseUI()
			maininterface.ShowUI(p.userData);
			maininterface.HideUI();
			country_main.ShowUI()
			dlg_userinfo.HideUI( );
			rookie_mask.ShowUI( step, 6 );
		elseif substep == 7 then
			p.SendUpdateStep(step)
		end
	elseif step == 5 then
		--p.SendUpdateStep(p.stepId)
		w_battle_guid.fighterSecondGuid(substep);
	elseif step == 6 then
		if substep == 1 then
			maininterface.HideUI();
			dlg_drama.ShowUI( 6,after_drama_data.ROOKIE,0,0)
		elseif substep == 2 then
			country_main.ShowUI();
			rookie_mask.ShowUI( step, 2 );
		elseif substep == 3 then
			country_main.CloseUI();
			maininterface.ShowUI(p.userData);
			card_bag_mian.ShowUI();
			rookie_mask.ShowUI( step, 3 );
		elseif substep == 4 then
			card_bag_mian.rookieNode()
			rookie_mask.ShowUI( step, 4 );
		elseif substep == 5 then
			dlg_card_attr_base.rookieIntensify()
			rookie_mask.ShowUI( step, 5 );
		elseif substep == 6 then
			card_rein.rookieStep()
			rookie_mask.ShowUI( step, 6 );
		elseif substep == 7 then
			card_intensify.rookieClickOnCard_1()
			rookie_mask.ShowUI( step, 7 );
		elseif substep == 8 then
			card_intensify.rookieClickOnCard_2()
			rookie_mask.ShowUI( step, 8 );
		elseif substep == 9 then
			card_intensify.rookieClickOnCard_3()
			rookie_mask.ShowUI( step, 9 );
		elseif substep == 10 then
			card_intensify.rookieClickOnCard_4()
			rookie_mask.ShowUI( step, 10 );
		elseif substep == 11 then
			card_intensify.rookieClickOnCard_5()
			rookie_mask.ShowUI( step, 11 );
		elseif substep == 12 then
			card_intensify.rookieClickEvent();
			rookie_mask.ShowUI( step, 12 );
		elseif substep == 13 then
			card_rein.rookieStart()
			rookie_mask.ShowUI( step, 13 );
		elseif substep == 14 then
			card_intensify_succeed.CloseUI();
			dlg_drama.ShowUI( 7,after_drama_data.ROOKIE,0,0)
		elseif substep == 15 then
			p.SendUpdateStep( step )
		end
		
	elseif step == 7 then
		if substep == 1 then
			maininterface.HideUI();
			dlg_drama.ShowUI( 90,after_drama_data.ROOKIE,0,0)
		elseif substep == 2 then
			country_main.ShowUI();
			rookie_mask.ShowUI( step, 2 );
		elseif substep == 3 then
			country_main.CloseUI()
			maininterface.ShowUI(p.userData);
			dlg_card_group_main.ShowUI();
			rookie_mask.ShowUI( step, 3 );
		elseif substep == 4 then
			dlg_card_group_main.rookieClickNode();
			rookie_mask.ShowUI( step, 4 );
		elseif substep == 5 then
			card_bag_mian.rookieClickTeamCard()
			rookie_mask.ShowUI( step, 5 );
		elseif substep == 6 then
			--p.SendUpdateStep( step )
			p.ShowLearningStep(8, 1)
		end
		
	elseif step == 8 then
		if substep == 1 then
			maininterface.HideUI();
			dlg_menu.HideUI();
			
			dlg_card_group_main.CloseUI();
			dlg_drama.ShowUI( 8, after_drama_data.ROOKIE, 0, 0);
		elseif substep == 2 then
			maininterface.HideUI();
			dlg_menu.HideUI();
			
			quest_reward.CloseUI();
			--quest_result.CloseUI();
			
			dlg_drama.ShowUI( 9, after_drama_data.ROOKIE, 0, 0);
		end
	elseif step == 9 then
		if substep == 1 then
			maininterface.HideUI();
			dlg_menu.HideUI();
			dlg_drama.ShowUI( 10, after_drama_data.ROOKIE, 0, 0);
		elseif substep == 9 then
			maininterface.HideUI();
			dlg_menu.HideUI();
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
				maininterface.ShowUI( p.userData );
				country_main.ShowUI();
			end
			rookie_mask.ShowUI( step, substep );
		end
	elseif step == 10 then
		maininterface.HideUI();
		dlg_menu.HideUI();
		dlg_drama.ShowUI( 12, after_drama_data.ROOKIE, 0, 0);
	elseif step == 11 then
		if substep == 1 then
			maininterface.HideUI();
			dlg_menu.HideUI();
			dlg_drama.ShowUI( 13, after_drama_data.ROOKIE, 0, 0);
		elseif substep == 7 then
			maininterface.HideUI();
			dlg_menu.HideUI();
			dlg_drama.ShowUI( 14, after_drama_data.ROOKIE, 0, 0);
		elseif substep == 5 then
			--dlg_gacha.ReqStartGacha( 3, 2, 1);
			rookie_mask.ShowUI( step, substep );
		else
			if substep == 2 then
				maininterface.ShowUI( p.userData );
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
		if substep == 1 then
			dlg_drama.ShowUI( 15,after_drama_data.ROOKIE,0,0)
		elseif substep == 2 then
			maininterface.ShowUI(p.userData);
			country_main.ShowUI();
			rookie_mask.ShowUI( step, 2 );
		elseif substep == 3 then
			country_main.CloseUI();
			maininterface.ShowUI(p.userData);
			card_bag_mian.ShowUI();
			rookie_mask.ShowUI( step, 3 );
		elseif substep == 4 then
			card_bag_mian.rookieClick_12_3()
			rookie_mask.ShowUI( step, 4 );
		elseif substep == 5 then
			dlg_card_attr_base.rookie_12_4()
			rookie_mask.ShowUI( step, 5 );
		elseif substep == 6 then
			equip_dress_select.rookieClick_12_5()
			rookie_mask.ShowUI( step, 6 );
		elseif substep == 7 then
			dlg_card_equip_detail.rookieClick_12_7()
			rookie_mask.ShowUI( step, 7 );
		elseif substep == 8 then
			dlg_msgbox.rookieCloseBtn()
			dlg_card_equip_detail.OnOk()
			rookie_mask.ShowUI( step, 8 );
		elseif substep == 9 then
			dlg_card_attr_base.CloseUI();
			--p.SendUpdateStep( step )
			p.ShowLearningStep(13, 1)
		end

	elseif step == 13 then
		local playLv = tonumber(msg_cache.msg_player.Level)
		if playLv < 5 then
			maininterface.ShowUI(p.userData);
		else
			maininterface.HideUI();
			dlg_menu.HideUI();
			dlg_drama.ShowUI( 16, after_drama_data.ROOKIE, 0, 0);
		end
	elseif step == 14 then
		if substep == 1 then
			maininterface.HideUI();
			dlg_menu.HideUI();
			dlg_drama.ShowUI( 17, after_drama_data.ROOKIE, 0, 0);
			do return end;
		elseif substep == 2 then
			maininterface.ShowUI( p.userData );
			country_main.ShowUI();
		elseif substep == 3 then
			equip_room.ShowUI();
		elseif substep == 4 then
			local node = equip_room.GetRookieNode();
			if node then
				equip_room.OnItemClickEvent( node, 1, nil );
			end
		elseif substep == 5 then
			equip_rein_list.ShowUI(dlg_card_equip_detail.equip,dlg_card_equip_detail.callback);
			if (dlg_card_equip_detail.redirectCallback) then
				dlg_card_equip_detail.redirectCallback();
			end
			dlg_card_equip_detail.CloseUI();
		elseif substep == 6 then
			equip_rein_list.HideUI();
			equip_rein_select.ShowUI(equip_rein_list.itemListInfo,equip_rein_list.OnSelectCallback);
		elseif substep == 7 then
			local node = equip_rein_select.GetRookieNode();
			if node then
				equip_rein_select.OnItemClickEvent( node, 1, nil );
			end
		elseif substep == 8 then
			local node = equip_rein_select.GetRookieNode1();
			if node then
				equip_rein_select.OnEquipUIEvent( node, 1, nil );
			end
		elseif substep == 9 then
			
		end
		rookie_mask.ShowUI( step, substep );
	end
end

--发送跟新步骤 otherParam 附带的其他参数 传入格式为：param=XXX&XXXX=XXX......
function p.SendUpdateStep(guide,subguide,otherParam)
	local uid = GetUID();
	local param = nil;
	if otherParam then
		if subguide ~= nil and tonumber(subguide) > 0 then
			param = "guide="..guide.."&subguide="..subguide.."&"..otherParam;
		else
			param = "guide="..guide.."&"..otherParam;
		end
	else
		if subguide ~= nil and tonumber(subguide) > 0 then
			param = "guide="..guide.."&subguide="..subguide;
		else
			param = "guide="..guide;
		end
	end
	SendReq("User","Complete",uid,param);
end

--显示下一步前相关操作，返回true为直接显示下一步，false为不直接显示（发消息给服务端，服务端返回后进入下一步）
function p.DoSomething( step, substep, index )
	if step == 5 then
		if w_battle_guid.substep == 4 then
			return w_battle_guid.CanSubStep4;
		elseif w_battle_guid.substep == 5 then
			return w_battle_guid.CanSubStep5;
		elseif w_battle_guid.substep == 6 then
			return w_battle_guid.CanSubStep6;
		end;
	elseif step == 9 then
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
			p.SendUpdateStep( step, substep );
			return false;
		elseif substep == 5 then
			p.tempStep = step;
			p.tempSubTemp = substep+1;
			
			p.SendUpdateStep( step, substep+1 );
			return false;
		elseif substep == 2 then
			if country_main.countryInfoT["B3"] == nil then
				return false;
			end
		elseif substep == 3 then
			if country_main.rookie_flag == false then
				return false;
			end
		end
	elseif step == 11 then
		if substep == 4 then
			dlg_gacha.ReqStartGacha( 3, 2, 1);
			p.tempStep = step;
			p.tempSubTemp = substep+1;
			p.SendUpdateStep( step );
			return false;
		elseif substep == 5 then
			if dlg_gacha_effect.gacharesult == nil then
				return false;
			end
		elseif substep == 6 then
			dlg_gacha_result.CloseUI();
			dlg_gacha.CloseUI();
		end
	elseif step == 4 then
		if substep == 2 then
			if country_main.countryInfoT["B1"] then
				return true
			else
				return false
			end
		elseif substep == 3 then
			p.tempStep = step;
			p.tempSubTemp = substep+1;
			p.SendUpdateStep( step,5 );
			return false;
		end
	elseif step == 6 then
		if substep == 12 then
			p.tempStep = step;
			p.tempSubTemp = substep+1;
			p.SendUpdateStep( step,13 );
			return false;
		end
	elseif step == 7 then
		if substep == 4 then
			p.tempStep = step;
			p.tempSubTemp = substep+1;
			p.SendUpdateStep( step);
			return false;
		end
	elseif step == 12 then
		if substep == 6 then
			p.tempStep = step;
			p.tempSubTemp = substep+1;
			p.SendUpdateStep( step);
			return false;
		end
	elseif step == 14 then
		if substep == 8 then
			local node = equip_rein_list.GetRookieNode();
			if node then
				equip_rein_list.OnUIClickEvent( node, 1, nil );
			end
			
			p.tempStep = step;
			p.tempSubTemp = substep+1;
			
			p.SendUpdateStep( step );
			return false;
		elseif substep == 9 then
			if equip_rein_result.layer == nil then
				return false;
			end
		
			--引导结束，切回主页
			equip_rein_result.CloseUI();
			equip_rein_list.CloseUI();
			equip_room.CloseUI();
			
			world_map.CheckToCloseMap();
			dlg_menu.SetNewUI( {} );
			PlayMusic_MainUI();
			maininterface.ShowUI();
		elseif substep == 2 then
			if country_main.countryInfoT["B2"] == nil then
				return false;
			end
		elseif substep == 3 then
			local node = equip_room.GetRookieNode();
			if node == nil then
				return false;
			end
		elseif substep == 6 then
			local node = equip_rein_select.GetRookieNode();
			if node == nil then
				return false;
			end
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
	if storyId == 90 then
		p.ShowLearningStep( 7, 2 );
	elseif storyId == 1 then --战斗引导的剧情
		--p.ShowLearningStep( 7, 2 );
		p.ShowLearningStep( 3, 2 );
	elseif storyId == 2 then
		rookie_main.SendUpdateStep(3);
	elseif storyId == 3 then
		p.ShowLearningStep( p.stepId, 2 )
	elseif storyId == STORY_GUID_5_1 then -- 4
		p.ShowLearningStep(5,2);
	elseif storyId == STORY_GUID_5_7 then --5
		quest_team_item.FightClick();
	elseif storyId == 6 then
		p.ShowLearningStep( p.stepId, 2 )
	elseif storyId == 7 then
		p.ShowLearningStep( 6, 15);
	elseif storyId == 8 then
		w_battle_mgr.EnterBattle(1,100031,1);
		--p.ShowLearningStep( 8, 2 );
		
	elseif storyId == 9 then
		--p.ShowLearningStep( 9, 1 );
		p.SendUpdateStep( p.stepId )
	elseif storyId == 10 then
		p.ShowLearningStep( 9, 2 );
	elseif storyId == 11 then
		--p.ShowLearningStep( 10, 1 );
		p.SendUpdateStep( p.stepId )

	elseif storyId == 12 then
		--p.ShowLearningStep( 11, 1 );
		p.SendUpdateStep( p.stepId )

	elseif storyId == 13 then
		p.ShowLearningStep( 11, 2 );
	elseif storyId == 14 then
		p.ShowLearningStep( 12, 1 );
		--p.SendUpdateStep( p.stepId );

	elseif storyId == 15 then
		p.ShowLearningStep( 12, 2 );
	elseif storyId == 16 then
		p.SendUpdateStep( p.stepId );
		--p.ShowLearningStep( 14, 1 );
	elseif storyId == 17 then
		p.ShowLearningStep( 14, 2 );
	end
end


