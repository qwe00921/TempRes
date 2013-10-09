--------------------------------------------------------------
-- FileName: 	card_fighter.lua
-- BaseClass:   fighter
-- author:		zhangwq, 2013/08/14
-- purpose:		����ս����սʿ�ࣨ��ʵ����
--------------------------------------------------------------

card_fighter = fighter:new();
local p = card_fighter;
local super = fighter;

--������ʵ��
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
    super.ctor(self);
	self.skillbar = nil;
	self.skillnum = nil;
	self.UseConfig = nil;
end

--��ʼ�������أ�
function p:Init( idFighter, node, camp )
	super.Init( self, idFighter, node, camp );
	--self.hpbar:GetNode():SetVisible( false );
	self.tmplife = self.life;
	self:CreateSkillBar();
end

function p:CreateSkillBar()
	if self.skillbar == nil then
	    self.skillnum = math.random( 1, 4 );
        local skillbar = createNDUIImage();
        skillbar:Init();
        
        local pic = GetPictureByAni("card_battle.skill_num", self.skillnum - 1); 
        skillbar:SetPicture( pic );
        
        local pos = self.hpbar.node:GetFramePos();
        skillbar:SetFramePosXY(pos.x + UIOffsetX(13), pos.y + UIOffsetY(8));
        skillbar:ResizeToFitPicture();
        self.node:AddChildZ( skillbar, 2 );
        self.skillbar = skillbar;
    end 
end

--����Ѫ��
function p:CreateHpBar()
	if self.hpbar == nil then
		self.hpbar = card_hp_bar:new();
		self.hpbar:CreateExpNode();
		self.node:AddChildZ( self.hpbar:GetNode(), -1 );
		self.hpbar:Init( self.node, self.life, self.lifeMax );
	end	
end

--��ʱ����ֵ
function p:SetTmpLife()         self.tmplife = self.life; end
function p:CheckTmpLife() 		return self.tmplife > 0; end
function p:SubTmpLife( val ) 	self.tmplife = self.tmplife - val; end

--��������
function p:UseConfig( config )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:UseConfig( config );
    end	
end

--ս��
function p:standby()
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:Standby("");
    end
end

--���ó���
function p:SetLookAt( lookat )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:SetLookAt( lookat );
    end
end

--��ȡ����
function p:GetLookAt()
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        return playerNode:GetLookAt();
	else
		return E_PLAYER_LOOKAT_RIGHT;
    end
end

--ȡplayer�ڵ�
function p:GetPlayerNode()
    return ConverToPlayer(self:GetNode());
end

--��ȡ����սʿ֮��ĽǶ�
function p:GetAngleByFighter( targetFighter )
	local selfPos = self:GetNode():GetCenterPos();
	local targetPos = targetFighter:GetNode():GetCenterPos();
	
	local tang = (selfPos.y - targetPos.y) / (targetPos.x - selfPos.x);
	local radians = math.atan(tang);
	
	local degree = radians * 180 / math.pi;
	return degree;
end

--��ȡսʿǰ������
function p:GetFrontPos(targetNode)
	local frontPos = self:GetNode():GetCenterPos();
	local halfWidthSum = self:GetNode():GetCurAnimRealSize().w/2 + targetNode:GetCurAnimRealSize().w/2;
	
	if self.camp == E_CARD_CAMP_HERO then
		frontPos.x = frontPos.x + halfWidthSum;
	else
		frontPos.x = frontPos.x - halfWidthSum;
	end
	return frontPos;
end

--��ȡսʿǰ������
function p:GetFrontFarPos(targetNode)
	local farPos = self:GetFrontPos(targetNode);
	if self.camp == E_CARD_CAMP_HERO then
		farPos.x = farPos.x + 100;
	else
		farPos.x = farPos.x - 100;
	end
	return farPos;
end

--���lua����
function p:cmdLua( cmdtype, num, str, seq )
	--��ʱ��ʱ��Ѫ���浽tmplife
	if cmdtype == "fighter_damage" then
		self:SubTmpLife( num );	
	end
	return super.cmdLua( self, cmdtype, num, str, seq );
end


