--------------------------------------------------------------
-- FileName: 	boss_out.lua
-- author:		hst, 2013/05/28
-- purpose:		遇敌（boss出现）
--------------------------------------------------------------

boss_out = {}
local p = boss_out;

p.layer = nil;
p.step = 10;
p.travelId = nil;
p.positionX = nil;
p.positionY = nil;

--显示UI
function p.ShowUI( travelId, positionX, positionY )
	if travelId == nil or positionX == nil or positionY == nil then
		return false;
	else	
		p.travelId = travelId;
		p.positionX = positionX;
		p.positionY = positionY;
	end
	local pMainLayer = createNDUILayer();
    if pMainLayer == nil then
        return false;
    end
	
	local pBottomLayer = createNDUILayer();
    if pBottomLayer == nil then
        return false;
    end
	
	local pTopLayer = createNDUILayer();
    if pTopLayer == nil then
        return false;
    end
	
	pTopLayer:Init();
	pTopLayer:SetSwallowTouch(false);
	pTopLayer:SetFrameRectFull();
	
	pBottomLayer:Init();
	pBottomLayer:SetSwallowTouch(false);
	pBottomLayer:SetFrameRectFull();
	
	pMainLayer:Init();
	pMainLayer:SetSwallowTouch(false);
	pMainLayer:SetFrameRectFull();
	
	pMainLayer:AddChildZTag(pBottomLayer,0,1);
	pMainLayer:AddChildZTag(pTopLayer,0,2);
	
	GetUIRoot():AddChildZTag(pMainLayer,0xff,10);
	
    LoadUI("boss_out_info.xui", pBottomLayer, nil);
	
    LoadUI("boss_out.xui", pTopLayer, nil);
	
	p.DoEffect(pTopLayer, pBottomLayer);
	
	--p.SetDelegate(layer);
	p.layer = pMainLayer;
	
	-- BOSS关闭按钮，点击屏幕触发
	--[[
	local closeBtn = createNDUIButton();
	closeBtn:Init();
	closeBtn:SetFrameRectFull();
	pMainLayer:AddChildZ(closeBtn,5);
	closeBtn:SetLuaDelegate(p.OnUIEventBtn);
	--]]
	
	--按钮事件
	local btn1 = GetButton( pBottomLayer, ui_boss_out_info.ID_CTRL_BUTTON_13 );
	local btn2 = GetButton( pBottomLayer, ui_boss_out_info.ID_CTRL_BUTTON_14 );
	local btn3 = GetButton( pBottomLayer, ui_boss_out_info.ID_CTRL_BUTTON_15 );
	
	btn1:SetLuaDelegate( p.OnBtnFight );
	--btn2:SetLuaDelegate( p.OnUIEventBtn );
	--btn3:SetLuaDelegate( p.OnUIEventBtn );
	btn2:SetLuaDelegate( p.OnBtnFight );
	btn3:SetLuaDelegate( p.OnBtnFight );
	
	PlayEffectSoundByName( "sk_boss.mp3" );--音效
	
	p.layer:SetSwallowTouch( true );
end

--关闭界面
function p.OnUIEventBtn(uiNode, uiEventType, param)	
	WriteCon( "p.OnUIEventBtn" );
	
	if p.layer ~= nil then
	    p.layer:LazyClose();
	    p.layer = nil;
    end
end

function p.DoEffect(pTopLayer, pBottomLayer)

	pTopLayer:SetFramePosXY(0,UIOffsetY(-500));
	pTopLayer:AddActionEffect("test.out_boss_down");
	
	
	local pOutBossCardFX = GetImage( pTopLayer,ui_boss_out.ID_CTRL_PICTURE_1 );
	local pBarFX = GetImage( pTopLayer,ui_boss_out.ID_CTRL_PICTURE_22 );
	local pOutBossFX = GetImage( pTopLayer,ui_boss_out.ID_CTRL_PICTURE_23 );
		
	pOutBossCardFX:AddFgEffect("lancer_cmb.boss_card_fx");
	pBarFX:AddFgEffect("lancer_cmb.bar_fx");
	pOutBossFX:AddFgEffect("lancer_cmb.boss_fx");
	
	local bossInfoDode = GetImage( pBottomLayer,ui_boss_out_info.ID_CTRL_PICTURE_2 );
	if nil == bossInfoDode then
        return false;
    end
	local bossInfo_x = bossInfoDode:GetFramePos().x + UIOffsetX(70);
	pBottomLayer:SetFramePosXY(0,bossInfo_x);
	pBottomLayer:AddActionEffect("test.out_boss_info_up");
end

--开始打boss
function p.OnBtnFight(uiNode, uiEventType, param)	
	WriteCon( "p.OnBtnFighter" );
	
	p.HideUI();
	
	--进战斗
	if E_DEMO_VER == 2 then
	    x_battle_mgr.EnterBattle();
	elseif E_DEMO_VER == 3 then 
		card_battle_mgr.EnterBattle();   
    elseif E_DEMO_VER == 1 then 
		battle_mgr.EnterBattle();
    end
    
    --请求战斗
    local user_id = GetUID();
    local param = string.format("&travel_id=%d&position_x=%d&position_y=%d", p.travelId, p.positionX, p.positionY );
    if tonumber( p.travelId ) > 999999 then
    	SendReq( "Dungeon","Battle",user_id,param );
    else
    	SendReq( "Mission","Battle",user_id,param );	
    end
      
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
  if p.layer ~= nil then
    p.layer:LazyClose();
    p.layer = nil;
  end
end
