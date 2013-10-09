--------------------------------------------------------------
-- FileName: 	card_battle_mainui.lua
-- author:		zhangwq, 2013/08/14
-- purpose:		卡牌对战：主界面
--------------------------------------------------------------

card_battle_mainui = {}
local p = card_battle_mainui;

p.layer = nil;
p.imageMask = nil;
p.turnNumNode = nil;
p.heroRage = nil;
p.enemyRage = nil;
p.heroSkillBtn = nil;
p.enemySkillBtn = nil;

local useSkill = false;  --当前回合是否用技能攻击
local isHeroAutoAtk = false; --是否托管（自动攻击）
local waitingInput = true;

local atkBtn = nil;
local autoBtn = nil;
--local bossHpBar = nil;


--重置
function p.Reset()
	useSkill = false;
	isHeroAutoAtk = false;
	waitingInput = true;
end

--显示UI
function p.ShowUI()
	p.Reset();
		
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
	
    LoadUI("card_battle_mainui.xui", layer, nil);
	
	p.layer = layer;
	
	--初始化控件
	p.initWidget();
    
	p.SetDelegate(layer);
	p.SetTouchEnabled(false);
	--p.InitBossHpBar();
	
	if false then
	    --添加蒙版图片
	    p.AddMaskImage();
    	
	    --添加战斗开启光效
	    local id = AddHudEffect( "lancer.enter_battle" );
	    RegAniEffectCallBack( id, p.OnAniEffectCallBack );
	end
	
	--注册战斗表现结束的回调
	RegCallBack_BattleShowFinished( p.OnBattleShowFinished );
end

--初始化控件
function p.initWidget()
	p.turnNumNode = GetImage( p.layer,ui_card_battle_mainui.ID_CTRL_PICTURE_TURN_NUM );
	p.heroRage = GetExp( p.layer, ui_card_battle_mainui.ID_CTRL_EXP_HERO_RAGE);
    p.enemyRage = GetExp( p.layer, ui_card_battle_mainui.ID_CTRL_EXP_ENEMY_RAGE);
    p.heroRage:SetVertical();
    p.heroRage:SetNoText();
    p.enemyRage:SetVertical();
    p.enemyRage:SetNoText();
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
		card_battle_zorder.ResetZOrder();
		p.layer:LazyClose();
		p.layer = nil;
	end
end

--设置事件处理
function p.SetDelegate(layer)
	--攻击按钮
	atkBtn = GetButton( layer, ui_card_battle_mainui.ID_CTRL_BUTTON_10 );
    atkBtn:SetLuaDelegate( p.OnBtnClicked_Atk );
	
	--托管按钮
	autoBtn = GetButton( layer, ui_card_battle_mainui.ID_CTRL_BUTTON_11 );
	autoBtn:SetLuaDelegate( p.OnBtnClicked_Auto );
	
	p.heroSkillBtn = GetButton( layer, ui_card_battle_mainui.ID_CTRL_BUTTON_HERO_SKILL );
    p.enemySkillBtn = GetButton( layer, ui_card_battle_mainui.ID_CTRL_BUTTON_ENEMY_SKILL );
    
    p.heroSkillBtn:SetLuaDelegate( card_battle_mgr.HeroTeamSkill );
    p.enemySkillBtn:SetLuaDelegate( card_battle_mgr.EnemyTeamSkill );
    
    p.enemySkillBtn:SetEnabled( false );
    
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
	if IsClickEvent( uiEventType ) then
        
        --进入子回合阶段->ATK
        card_battle_stage.EnterBattle_SubTurnStage_Atk();
        
        --进入Atk表现
        card_battle_mgr.EnterBattle_SubTurnStage_Atk();
        
        --停止用户输入
        p.SetTouchEnabled( false );
        
        --[[
		--屏蔽按钮
		atkBtn:SetEnabled( false );
		
		card_battle_mgr.HeroTurn();
		card_battle_mgr.EnemyTurn();
		--]]
		waitingInput = false;
		
		--开启Z排序
		card_battle_zorder.SortZOrder();
	end
end

--自动按钮点击事件
function p.OnBtnClicked_Auto(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
		isHeroAutoAtk = not isHeroAutoAtk;
		
		if waitingInput then
			p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
		end
	end
end

--战斗表现结束的回调
function p.OnBattleShowFinished()
    --战斗阶段->起手
    if card_battle_stage.IsBattle_Stage_Hand() then
    
    	--进入->对战回合阶段
    	card_battle_stage.EnterBattle_Stage_Turn();
    	
    	--回合阶段开始：进入上半场->英雄回合
    	card_battle_stage.EnterBattle_TurnStage_Hero();
    	
    	--进入子回合阶段->DOT
    	card_battle_stage.EnterBattle_SubTurnStage_Dot();
    	
    	--进入DOT表现->英雄方
    	card_battle_mgr.EnterBattle_SubTurnStage_Dot();
    
    --战斗阶段->回合
    elseif card_battle_stage.IsBattle_Stage_Turn() then
        --dot阶段结束->英雄方
        if card_battle_stage.IsBattleTurnHeroDot() then
        
        	--进入子回合阶段->SKILL
        	card_battle_stage.EnterBattle_SubTurnStage_Skill();
        	
        	--开启响应用户输入
        	p.SetTouchEnabled( true )
        
        --dot阶段结束->敌方
        elseif card_battle_stage.IsBattleTurnEnemyDot() then
        
            --进入子回合阶段->SKILL
            card_battle_stage.EnterBattle_SubTurnStage_Skill();
            
            --进入SKILL表现->敌方自动触发
            card_battle_mgr.EnemyTriggerSkills();
            
        --SKILL阶段结束->敌方
        elseif card_battle_stage.IsBattleTurnEnemySkill() then
            
            --进入子回合阶段->atk敌方  
            card_battle_stage.EnterBattle_SubTurnStage_Atk();
            
            --进入ATK表现->敌方自动触发
            card_battle_mgr.EnterBattle_SubTurnStage_Atk();
        
        --stk阶段结束->英雄方
        elseif card_battle_stage.IsBattleTurnHeroAtk() then
            --进入下半场->敌方回合
            card_battle_stage.EnterBattle_TurnStage_Enemy();
            
            --进入子回合阶段->DOT敌方
            card_battle_stage.EnterBattle_SubTurnStage_Dot();
            
            --进入DOT表现->敌方
            card_battle_mgr.EnterBattle_SubTurnStage_Dot();
        
        --stk阶段结束->敌方    
        elseif card_battle_stage.IsBattleTurnEnemyAtk() then
            --回合结束
            card_battle_stage.EnterBattle_TurnStage_End();
            
            --进入回合处理
            card_battle_mgr.EnterBattle_TurnStage_End();
        end
        --card_battle_mgr.TurnStageBegin();
        --WriteCon( "OnBattleShowFinished()" );
        --SetTimerOnce( p.CheckAutoAtk, 0.1f );	
    end
end	

--自动攻击
function p.CheckAutoAtk()
	waitingInput = true;
	atkBtn:SetEnabled( not isHeroAutoAtk );
	
	if card_battle_mgr.IsBattleEnd() then
	    card_battle_zorder.ResetZOrder();
	else
		if isHeroAutoAtk then
			p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK );
        else
            card_battle_zorder.ResetZOrder();			
		end
	end
end

--是否接收用户操作
function p.SetTouchEnabled( flag )
    --攻击按钮
	local atkBtn = GetButton( p.layer, ui_battle_mainui.ID_CTRL_BUTTON_10 );
	
    --托管按钮
    local autoBtn = GetButton( p.layer, ui_battle_mainui.ID_CTRL_BUTTON_11 );
    atkBtn:SetEnabled( flag );
    autoBtn:SetEnabled( flag );
end