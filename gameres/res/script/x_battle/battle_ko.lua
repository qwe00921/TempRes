--------------------------------------------------------------
-- FileName: 	battle_ko.lua
-- author:		Guo Hao
-- purpose:		剧情管理器（数据）
-------------------------------------------------------------

battle_ko = {}
local p = battle_ko;
p.m_kLeftHp = nil;
p.m_kLeftMp = nil;
p.m_kRightHp = nil;
p.m_kRightMp = nil;
p.m_nLeftCurrentHp = 0;
p.m_nRightCurrentHp = 0;
p.m_nLeftTotalHp = 0;
p.m_nRightTotalHp = 0;
p.m_nLeftCurrentMp = 0;
p.m_nRightCurrentMp = 0;
p.m_nLeftTotalMp = 0;
p.m_nRightTotalMp = 0;
p.m_kLayer = nil;
p.m_nHpTimer = 0;
p.m_nMpTimer = 0;
p.m_bIsOver = false;
p.m_kLeftTeam = {};
p.m_kRightTeam = {};
p.m_kOrigin = nil;
p.m_kUI = ui_x_battle_ko;

p.m_kLeftUIArray = {
    p.m_kUI.ID_CTRL_LEFT_P_1,
    p.m_kUI.ID_CTRL_LEFT_P_2,
    p.m_kUI.ID_CTRL_LEFT_P_3,
    p.m_kUI.ID_CTRL_LEFT_P_4,
    p.m_kUI.ID_CTRL_LEFT_P_5,
	p.m_kUI.ID_CTRL_LEFT_P_6,
	p.m_kUI.ID_CTRL_LEFT_P_7,
	p.m_kUI.ID_CTRL_LEFT_P_8
};

p.m_kRightUIArray = {
    p.m_kUI.ID_CTRL_RIGHT_P_1,
    p.m_kUI.ID_CTRL_RIGHT_P_2,
    p.m_kUI.ID_CTRL_RIGHT_P_3,
    p.m_kUI.ID_CTRL_RIGHT_P_4,
    p.m_kUI.ID_CTRL_RIGHT_P_5,
	p.m_kUI.ID_CTRL_RIGHT_P_6,
	p.m_kUI.ID_CTRL_RIGHT_P_7,
	p.m_kUI.ID_CTRL_RIGHT_P_8
};

function p.ShowUI()
	if nil == p.m_kLayer then
		local kLayer = createNDUIDialog();
		if kLayer == nil then
			return false;
		end
		
		kLayer:Init();
		kLayer:SetSwallowTouch(false);
		kLayer:SetFrameRectFull();
		GetRunningScene():AddChild(kLayer);
		
	    LoadUI("x_battle_ko.xui",kLayer, nil);
		
		local kImage = GetImage(kLayer,ui_x_battle_ko.ID_CTRL_PICTURE_23);
		
		p.m_kLayer = kLayer;
	end

	if false == p.InitFighters() then
		return false;
	end
	
	if false == p.InitHpBar() then
		return false;
	end
	
	if false == p.InitMpBar() then
		return false;
	end

	SetTimer(p.shake,0.01f);
	
	--pCmd = battle_show.AddActionEffect_ToSequence( 0,p.m_kLeftHp, "lancer.ko_shake");
	
	return true;
end

function p.shake(kNode)
	local x = 5 - math.random(0,10);
	local y = 5 - math.random(0,10);
	p.m_kLayer:SetFramePosXY(x,y);
end

function p.CloseUI()
	m_kLayer.SetVisible(false);
end

function p.HideUI()
	m_kLayer.SetVisible(false);
end

function p.InitMpBar()
	p.m_nLeftCurrentMp = 100;
	p.m_nRightCurrentMp = 100;
	p.m_nLeftTotalMp = 100;
	p.m_nRightTotalMp = 100;
	
	p.m_kLeftMp = createNDUIExp();
	p.m_kRightMp = createNDUIExp();
	
	p.m_kLeftMp:Init("","");
	p.m_kRightMp:Init("","");
	
	local picBg = GetPictureByAni( "lancer.hpbar", 2 );
	local picFg = GetPictureByAni( "lancer.hpbar", 1 );
	
	if nil == picBg or nil == picFg then
		WriteCon("Can't found hp bar picture!");
	end
	
	p.m_kLeftMp:SetPicture(picBg,picFg);
	p.m_kRightMp:SetPicture(picFg,picBg);
	
	p.m_kLeftMp:SetTotal(p.m_nLeftTotalMp);
	p.m_kLeftMp:SetProcess(p.m_nLeftTotalMp - p.m_nLeftCurrentMp);
	
	p.m_kRightMp:SetTotal(p.m_nRightCurrentMp);
	p.m_kRightMp:SetProcess(p.m_nRightTotalMp);
	
	p.m_kLayer:AddChildZ(p.m_kLeftMp,100);
	p.m_kLayer:AddChildZ(p.m_kRightMp,100);
	
	p.m_kLeftMp:SetFrameRect(CCRectMake(640 / 2 - 200 - 10,480,200,80));
	p.m_kRightMp:SetFrameRect(CCRectMake(640 / 2 + 10,480,200,80));
	
	p.m_kLeftMp:SetNoText();
	p.m_kRightMp:SetNoText();
	
	p.m_nMpTimer = SetTimer( p.MpAdd, 0.02f );
	
	return true;
end

function p.InitHpBar()
    if p.m_kLayer == nil then
        return false;
    end
	
	p.m_kLeftHp = createNDUIExp();
	p.m_kRightHp = createNDUIExp();
	
	p.m_kLeftHp:Init("","");
	p.m_kRightHp:Init("","");
	
	local picBg = GetPictureByAni( "lancer.hpbar", 0 );
	local picFg = GetPictureByAni( "lancer.hpbar", 1 );
	
	if nil == picBg or nil == picFg then
		WriteCon("Can't found hp bar picture!");
	end
	
	p.m_kLeftHp:SetPicture(picBg,picFg);
	p.m_kRightHp:SetPicture(picFg,picBg);
	
	p.m_kLeftHp:SetTotal(p.m_nLeftTotalHp);
	p.m_kLeftHp:SetProcess(p.m_nLeftTotalHp - p.m_nLeftCurrentHp);
	
	p.m_kRightHp:SetTotal(p.m_nRightCurrentHp);
	p.m_kRightHp:SetProcess(p.m_nRightTotalHp);
	
	p.m_kLayer:AddChildZ(p.m_kLeftHp,100);
	p.m_kLayer:AddChildZ(p.m_kRightHp,100);
	
	p.m_kLeftHp:SetFrameRect(CCRectMake(640 / 2 - 200 - 10,400,200,80));
	p.m_kRightHp:SetFrameRect(CCRectMake(640 / 2 + 10,400,200,80));
	
	p.m_kLeftHp:SetNoText();
	p.m_kRightHp:SetNoText();
	
	return true;
end

function p.HpAdd()
	p.m_nLeftCurrentHp = p.m_nLeftCurrentHp - 5;
	p.m_nRightCurrentHp = p.m_nRightCurrentHp - 5;
	
	if 0 > p.m_nLeftCurrentHp then
		p.m_nLeftCurrentHp = 0;
		p.m_kLeftHp:SetProcess(p.m_nLeftTotalHp);
		KillTimer(p.m_nHpTimer);
		return;
	end
	
	if 0 > p.m_nRightCurrentHp then
		p.m_nRightCurrentHp = 0;
		p.m_kRightHp:SetProcess(0);
		KillTimer(p.m_nHpTimer);
		return;
	end
	
	p.m_kLeftHp:SetProcess(p.m_nLeftTotalHp - p.m_nLeftCurrentHp);
	p.m_kRightHp:SetProcess(p.m_nRightCurrentHp);
end

function p.MpAdd()
	p.m_nLeftCurrentMp = p.m_nLeftCurrentMp - 0.6;
	p.m_nRightCurrentMp = p.m_nRightCurrentMp - 0.9;
	
	if 0 > p.m_nLeftCurrentMp then
		p.m_nLeftCurrentMp = 0;
		p.m_kLeftMp:SetProcess(p.m_nLeftTotalMp);
		KillTimer(p.m_nMpTimer);
		p.m_nHpTimer = SetTimer( p.HpAdd, 0.02f );
		return;
	end
	
	if 0 > p.m_nRightCurrentMp then
		p.m_nRightCurrentMp = 0;
		p.m_kRightMp:SetProcess(0);
		KillTimer(p.m_nMpTimer);
		p.m_nHpTimer = SetTimer( p.HpAdd, 0.02f );
		return;
	end
	
	p.m_kLeftMp:SetProcess(p.m_nLeftTotalMp - p.m_nLeftCurrentMp);
	p.m_kRightMp:SetProcess(p.m_nRightCurrentMp);
end

function p.AddKoFighters(kUIArray,bLeft)
	if nil == kUIArray then
		return false;
	end
	
	local uiArray = nil;
	
	if true == bLeft then
		uiArray = p.m_kLeftTeam;
	else
		uiArray = p.m_kRightTeam;
	end
	
	for i = 1,#uiArray do
		local kImage = GetImage(p.m_kLayer,kUIArray[i]);
		local kPosition = kImage:GetFramePos();
		local kFighter = uiArray[i];
		
		if true == bLeft then
			p.m_nLeftTotalHp = p.m_nLeftTotalHp + kFighter.tmplife;
		else
			p.m_nRightTotalHp = p.m_nRightTotalHp + kFighter.tmplife;
		end
		
		kFighter:SetPosition(kPosition.x,kPosition.y);
		kFighter:GetPlayerNode():RemoveFromParent(false);
		p.m_kLayer:AddChildZ(kFighter:GetPlayerNode(),333);
	end
	
	return true;
end

function p.InitFighters()
	if nil == x_battle_mgr.heroCamp or nil == x_battle_mgr.enemyCamp then
		WriteCon("No init battle!");
		return false;
	end
	
	p.m_kLeftTeam = x_battle_mgr.heroCamp:GetAliveFighters();
	p.m_kRightTeam = x_battle_mgr.enemyCamp:GetAliveFighters();
	
	p.AddKoFighters(p.m_kLeftUIArray,true);
	p.AddKoFighters(p.m_kRightUIArray,false);
	
	p.m_nLeftCurrentHp = p.m_nLeftTotalHp;
	p.m_nRightCurrentHp = p.m_nRightTotalHp;
	
	local strLeft = string.format("Left team total HP is %d",p.m_nLeftCurrentHp);
	local strRight = string.format("Right team total HP is %d",p.m_nRightCurrentHp);
	
	WriteCon(strLeft);
	WriteCon(strRight);

	return true;
end