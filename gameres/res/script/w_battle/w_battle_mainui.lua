--------------------------------------------------------------
-- FileName: 	w_battle_mainui.lua
-- author:		zhangwq, 2013/06/25
-- purpose:		对战主UI (demo v2.0)
--------------------------------------------------------------

w_battle_mainui = {}
local p = w_battle_mainui;

p.layer = nil;
p.imageMask = nil;
p.m_kPower = nil;
p.m_nPowerTimer = 0;
p.m_fPowerPercent = 100.0f;
p.roundNumNode = nil;

local skillBtn = nil;
local idTimer_SortZOrder = 0; --定时更新ZOrder

--显示UI
function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return true;
	end
	
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddChild(layer);
	
    LoadUI("n_battle_mainui.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	p.roundNumNode = GetImage( layer, ui_n_battle_mainui.ID_CTRL_PICTURE_ROUNDNUM );
	
	--[[
	p.m_kPower = GetExp(p.layer,ui_n_battle_mainui.ID_CTRL_HOR3SLICES_POWER);

	if nil == p.m_kPower then
		WriteCon("Power process bar is nil");
		return false;
	end
	
	if false == p.InitialisePowerProcessBar() then
		WriteCon("InitialisePowerProcessBar failed");
		return false;
	end
	--]]
	--p.InitBossHpBar();
	
	--添加蒙版图片
--	p.AddMaskImage();

	return true;
end

--设置对战双方玩家名称
function p.SetName( uName, tName )
    local uNameNode = GetLabel( p.layer, ui_n_battle_mainui.ID_CTRL_TEXT_UNAME );
    local tNameNode = GetLabel( p.layer, ui_n_battle_mainui.ID_CTRL_TEXT_TNAME );
    uNameNode:SetText( uName );
    tNameNode:SetText( tName );
end

function p.InitialisePowerProcessBar()
	if nil == p.m_kPower then
		return false;
	end
	
	local kFgImage = GetPictureByAni("lancer.power_process",0);
	local kBgImage = GetPictureByAni("lancer.power_process",1);
	
	if nil == kFgImage or nil == kBgImage then
		WriteCon("Can't find lancer.power_process images!");
		return false;
	end
	
	p.m_kPower:SetPicture(kBgImage,kFgImage);
	p.m_kPower:SetUse3Slices(true,false);
	p.m_kPower:SetTotal(100);
	p.m_kPower:SetProcess(1000.0f);
--	p.m_kPower:SetFramePosXY(200,200);
	p.m_kPower:SetReverseExp(true);
	
	return true;
end

function p.StartBattleEffect()
		--添加战斗开启光效
	local id = AddHudEffect( "lancer.enter_battle" );
	--local id = AddHudEffect( "lancer_cmb.enter_battle" );
	RegAniEffectCallBack( id, p.OnAniEffectCallBack );
	
	--注册战斗表现结束的回调
	RegCallBack_BattleShowFinished( p.OnBattleShowFinished );
	--SetTimerOnce(p.OnBattleShowFinished,1.0f);
end

--隐藏
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭
function p.CloseUI()
	if p.layer ~= nil then	
		p.ResetZOrder();
		p.layer:LazyClose();
		p.layer = nil;
		p.imageMask = nil;
        p.m_kPower = nil;
        p.roundNumNode = nil;
	end
end

--设置事件处理
function p.SetDelegate(layer)
	--攻击按钮
	--atkBtn = GetButton( layer, ui_w_battle_mainui.ID_CTRL_BUTTON_17 );
   -- atkBtn:SetLuaDelegate( p.OnBtnClicked_Atk );
	
	--SKIP按钮
	skillBtn = GetButton( layer, ui_n_battle_mainui.ID_CTRL_BUTTON_SKIP );
	skillBtn:SetLuaDelegate( p.OnBtnClicked_Skill );
end

function p.OnBtnClicked_Skill( uiNode, uiEventType, param )
	uiNode:SetVisible(false);
    GetBattleShow():Stop();
    w_battle_mgr.isBattleEnd = true;
    local battleResult = w_battle_db_mgr.GetBattleResult();
    local result = tonumber( battleResult.Result ); 
    if result == 1 then
        w_battle_mgr.OnBattleWin();
    elseif result == 0 then
        w_battle_mgr.OnBattleLose();
    end
end

--[[
--初始化boss血条
function p.InitBossHpBar()
	bossHpBarNode = GetExp( p.layer, ui_battle_mainui.ID_CTRL_EXP_13 );
	if bossHpBarNode == nil then return end;
	
	local boss = battle_mgr.GetBoss();
	boss:SetLife(1000);
	boss:SetLifeMax(1000);	
	
	local hpbar = boss:GetHpBar();
	if hpbar ~= nil and bossHpBarNode~= nil then
		hpbar:SetNode( bossHpBarNode );
		hpbar:InitForBoss( bossHpBarNode, boss:GetLife(), boss:GetLifeMax());
	end
end

--取boss血条
function p.GetBossHpBar()
	return p.bossHpBar;
end

--]]

--添加蒙版图片
function p.AddMaskImage()
	imageMask = createNDUIImage();
	imageMask:Init();
	imageMask:SetFrameRectFull();
	
	local pic = GetPictureByAni("lancer.mask", 0); 
	imageMask:SetPicture( pic );
	p.layer:AddChildZ( imageMask, 1 );
end

--Ani特效播放完毕
function p.OnAniEffectCallBack(id)
	local s = string.format( "OnAniEffectCallBack(): id = %d", id);
	WriteCon(s);
	
	--蒙版渐变，播放结束后删除蒙版
	if imageMask ~= nil then
		local id = imageMask:AddActionEffect( "lancer.fadeout" );	
		RegActionEffectCallBack( id, p.OnActionEffectCallBack );
	end
end

--Action特效播放完毕
function p.OnActionEffectCallBack(id)
	local s = string.format( "OnActionEffectCallBack(): id = %d", id);
	WriteCon(s);
	
	if imageMask ~= nil then
		imageMask:SetVisible(false);
	end
end

--攻击按钮点击事件
function p.OnBtnClicked_Atk(uiNode, uiEventType, param)
		--屏蔽按钮
		--atkBtn:SetEnabled( false );
	w_battle_mgr.HeroTurn();
	w_battle_mgr.EnemyTurn();
		
	waitingInput = false;
		
		--定时更新Z序 (every tick)
	if idTimer_SortZOrder == 0 then
		idTimer_SortZOrder = SetTimer( p.OnTimer_SortZOrder, 0.04f );
	end
end

--自动按钮点击事件
function p.OnBtnClicked_Auto(uiNode, uiEventType, param)	
	if isHeroAutoAtk == true then
		p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
	end
end

function p.OnKoRound()
	w_battle_ko.ShowUI();
end

--战斗表现结束的回调
function p.OnBattleShowFinished()
	WriteCon( "OnBattleShowFinished()" );
	
	if w_battle_mgr.isBattleEnd then
		WriteCon("-------------------------is battle end ----------------------------");
		return ;
	end
	
	if W_BATTLE_MAX_ROUND < tonumber( w_battle_stage.GetRoundNum() ) and not w_battle_stage.IsBattle_Stage_End() then
	    w_battle_stage.EnterBattle_Stage_End();--战斗阶段->结束
        p.HideUI();
        local id = AddHudEffect( "lancer.enter_battle" );
        --local id = AddHudEffect( "lancer_cmb.enter_battle" );
        RegAniEffectCallBack( id, p.OnKoRound );
        isHeroAutoAtk = false;
        --p.m_nBattleRound = 0;
        return;
    end
    
    --战斗阶段->加载完成
    if w_battle_stage.IsBattle_Stage_Loading() then
        w_battle_stage.EnterBattle_Stage_Permanent_Buff();--战斗阶段->永久BUFF表现
        w_battle_mgr.EnterBattle_Stage_Permanent_Buff();--永久BUFF表现效果
    
	--战斗阶段->永久BUFF表现
	elseif w_battle_stage.IsBattle_Stage_Permanent_Buff() then
		w_battle_stage.EnterBattle_Stage_Round();--进入回合阶段
		w_battle_stage.EnterBattle_RoundStage_Pet();--进入回合阶段->召唤兽表现 
		w_battle_mgr.EnterBattle_RoundStage_Pet();--召唤兽表现效果
		
	--战斗阶段->回合
    elseif w_battle_stage.IsBattle_Stage_Round() then
    	
    	--召唤兽表现完成
    	if w_battle_stage.IsBattle_RoundStage_Pet() then
    	   WriteConWarning("=============EnterBattle_RoundStage_Buff============");
    	   w_battle_stage.EnterBattle_RoundStage_Buff();--回合阶段->BUFF表现
    	   w_battle_mgr.EnterBattle_RoundStage_Buff();--BUFF表现效果
    	
    	--BUFF表现完成	
    	elseif w_battle_stage.IsBattle_RoundStage_Buff() then	
    	   WriteConWarning("=============EnterBattle_RoundStage_Atk============");
    	   w_battle_mgr.UpdateFighterBuff();--更新战士身上的BUFF
    	   w_battle_stage.EnterBattle_RoundStage_Atk();--回合阶段->互殴
           w_battle_mgr.EnterBattle_RoundStage_Atk();--互殴表现效果
        
        --互殴表现完成  
        elseif w_battle_stage.IsBattle_RoundStage_Atk() then   
           WriteConWarning("=============EnterBattle_RoundStage_Clearing============");
           w_battle_stage.EnterBattle_RoundStage_Clearing();--回合阶段->清算
           w_battle_mgr.EnterBattle_RoundStage_Clearing();--互殴表现效果
        
        --清算完成  
        elseif w_battle_stage.IsBattle_RoundStage_Clearing() then   
           WriteConWarning("=============EnterBattle_RoundStage_Pet============");
           w_battle_stage.EnterBattle_RoundStage_Pet();--进入回合阶段->召唤兽表现 
           w_battle_mgr.EnterBattle_RoundStage_Pet();--召唤兽表现效果
                 
    	end
	end
	
	--[[
	if isHeroAutoAtk == true then
		p.OnBtnClicked_Auto( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
		p.m_nBattleRound = p.m_nBattleRound + 1;
		
		if 0 == p.m_nPowerTimer then
			p.m_nPowerTimer = SetTimer(p.OnPowerProcessBarTimer,0.1f);
		end
	else
		if idTimer_SortZOrder ~= 0 then
			KillTimer(idTimer_SortZOrder);
			idTimer_SortZOrder = 0;
		end
		
		if p.m_nPowerTimer ~= 0 then
			KillTimer(p.m_nPowerTimer);
			p.m_nPowerTimer = 0;
		end
	end
	--]]
	--SetTimer( p.CheckAutoAtk, 0.5f );
end

function p.OnPowerProcessBarTimer()
	p.m_fPowerPercent = p.m_fPowerPercent - 1.5f;
	p.m_kPower:SetProcess(p.m_fPowerPercent);
end

--自动攻击
function p.CheckAutoAtk()
	--waitingInput = true;
	--atkBtn:SetEnabled( not isHeroAutoAtk );
	
	if w_battle_mgr.IsBattleEnd() or p.m_nBattleRound > 1 then
	    p.ResetZOrder();
    else
		if isHeroAutoAtk then
			p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK );
		else
		    p.ResetZOrder();
		end
	end
end

--定时更新Z序
function p.OnTimer_SortZOrder()
	--WriteCon( "w_battle_mainui: OnTimer_SortZOrder" );
	local layer = w_battle_mgr.GetBattleLayer();
	if layer ~= nil then
		layer:SortZOrder();
	end
end

--重置Z序
function p.ResetZOrder()
	--WriteCon( "w_battle_mainui: ResetZOrder" );
	local layer = w_battle_mgr.GetBattleLayer();
	if layer ~= nil then 
		layer:ResetZOrder();
	end
	
	if idTimer_SortZOrder > 0 then
		KillTimer( idTimer_SortZOrder );
		idTimer_SortZOrder = 0;	
	end
end