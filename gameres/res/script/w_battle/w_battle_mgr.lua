--------------------------------------------------------------
-- FileName: 	w_battle_mgr.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		战斗管理器（单实例）demo v2.0
--------------------------------------------------------------

w_battle_mgr = {}
local p = w_battle_mgr;

p.heroCamp = nil;			--玩家阵营
p.enemyCamp = nil;			--敌对阵营
p.uiLayer = nil;			--战斗层
p.heroUIArray = nil;		--玩家阵营站位UITag表
p.enemyUIArray = nil;		--敌对阵营站位UITag表

p.petNode={};       --双方宠物结点
p.petNameNode={};   --双方宠物名称结点

p.imageMask = nil			--增加蒙版特效
p.PVEEnemyID = nil;   --当前被攻击的敌人ID
p.PVEShowEnemyID = nil;  --当前显示血量的敌人ID
p.LockEnemy = false; --敌人是否被锁定攻击
p.LockFagID = nil;  --之前的锁定标志

local isPVE = false;
local isActive = false;
local useParallelBatch = true; --是否.使用并行批次
p.isBattleEnd = false;
p.isCanSelFighter = false;  --是否还有可选择的怪物,战斗UI界面点击我方人员时,需先判断此变理,再处理点击

local BATTLE_PVE = 1;
local BATTLE_PVP = 2;
p.seqStar = nil;

p.battle_result = false;
--[[
--创建角色后, 按活着的怪物,给个目标
  p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID();
  p.LockEnemy = false;
  p.isCanSelFighter = true;

--点选目标后,计算伤害
atkID,targerID

    --默认选择的目标,判定怪物将死
	if (hp < damage) and (p.LockEnemy == false) then
		p.PVEEnemyID = p.enemyCamp:GetActiveFighterID(targerID); --除此外的活的怪物目标
		
		if p.enemyCamp:GetActiveFighterCount() == 1 then
			p.LockEnemy = true;
		end
	end
	
  end;


]]--
function p.starFighter()
	w_battle_PVEStaMachMgr.init();
	GetBattleShow():EnableTick( true );
	p.createHeroCamp( w_battle_db_mgr.GetPlayerCardList() );
    p.createEnemyCamp( w_battle_db_mgr.GetTargetCardList() );
	--按活着的怪物,给个目标
    p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID(nil);
	p.PVEShowEnemyID = p.PVEEnemyID; 
	p.LockEnemy = false;
	p.isCanSelFighter = true;	
	
	local batch = battle_show.GetNewBatch(); 
	p.seqStar = batch:AddParallelSequence(); --战斗开始的并行动画
	--p.SetPVEAtkID(2);
	
end;


--攻击方是自己,受击方ID之前已选或自动选择,给战斗主界面调用
function p.SetPVEAtkID(atkID)
   local atkFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( atkID ) );

   local targerID = w_battle_mgr.PVEEnemyID;
   if targerID == nil then
      WriteCon( "Error! SetPVEAtkID targerID is nil");
	  return false;
   end; 

   if atkFighter == nil then
      WriteCon( "Error! SetPVEAtkID atkFighter is nil! id:"..tostring(atkID));
	  return false;
   end;

   local targetFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( targerID ) );
   if targetFighter == nil then
      WriteCon( "Error! SetPVEAtkID targetFighter is nil! id:"..tostring(targerID));
	  return false;
   end;

   

   --点选目标后,先计算伤害
   local damage,lIsJoinAtk,lIsCrit = w_battle_atkDamage.SimpleDamage(atkFighter, targetFighter);
   targetFighter:SubLife(damage); --扣掉生命,但表现不要扣
   

   --默认选择的目标,判定怪物将死
	if (targetFighter.nowlife <= 0) and (p.LockEnemy == false) then
		p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID(targerID); --选择下个nowHP > 0活的怪物目标
		
		if p.enemyCamp:GetActiveFighterCount() == 1 then
			p.LockEnemy = true;
		end
	end
	
   --受击次数先累加,攻击方动画播完后,再减一
    targetFighter:BeHitAdd(atkID);  
    
	--攻击某个人物
     --w_battle_atk.SelOver(atkFighter,targetFighter,batch,damage,lIsJoinAtk,lIsCrit);	--选择结束阶断
	
    --w_battle_atk.AtkPVE_NPC(atkFighter,targetFighter,batch,damage,lIsJoinAtk,lIsCrit);	
	local pStateMachine = w_battle_PVEStateMachine:new();
	local id = w_battle_PVEStaMachMgr.addStateMachine(pStateMachine);
	pStateMachine:init(p.seqStar,id,atkFighter,atkCampType,targetFighter, W_BATTLE_HERO,damage,lIsCrit,lIsJoinAtk);
	return false;
end;

--战斗界面选择怪物目标,选择后怪物就被锁定
function p.SetPVETargerID(targerId)
	if targerId > 6 or targerId < 0 then
	    WriteCon("SetPVEEnemyID id error! id = "..tostring(targetId));	
		return ;
	end
	p.PVEEnemyID = targerId;
	p.PVEShowEnemyID = p.PVEEnemyID;
	--显示怪物血量
	p.LockEnemy = true;
    p.SetLockAction(targerId);	
	
end;	

function p.SetLockAction(targerId)
   local lfighter = p.enemyUIArray:FindFighter(targerId);
   if LockFagID ~= targerId then
		--取消锁定标志
   end;
   --设置锁定标志
end;

--开始战斗表现:pve
function p.play_pve( targetId )
    WriteCon("-----------------Enter the pve mission id = "..targetId);
	isPVE = true;	
	w_battle_stage.Init();
    w_battle_stage.EnterBattle_Stage_Loading();
    p.SendStartPVEReq( targetId );
end

--开始战斗表现:pvp
function p.play_pvp( targetId )
    WriteCon("-----------------Enter the pvp Tuser id = "..targetId);
    isPVE = false;
    w_battle_stage.Init();
    w_battle_stage.EnterBattle_Stage_Loading();
    p.SendStartPVPReq( targetId );
end

--显示回合数
function p.ShowRoundNum()
    --local roundNum = w_battle_stage.GetRoundNum();
    --w_battle_mainui.ShowRoundNum( roundNum );
    w_battle_show.DoEffectShowTurnNum();
end

--战斗阶段->加载->请求
function p.SendStartPVPReq( targetId )
    local UID = GetUID();
    if UID == 0 or UID == nil then
        return ;
    end;
    local param = string.format("&target=%d", targetId);
    SendReq("Fight","StartPvP",UID,param);
end

--战斗阶段->加载->请求
function p.SendStartPVEReq( targetId )
    --local TID = 101011;
    local UID = GetUID();
    if UID == 0 or UID == nil then
        return ;
    end;
    local param = string.format("&missionID=%d", targetId);
    SendReq("Fight","StartPvC",UID,param);
end

--战斗阶段PVP->加载->响应
function p.ReceiveStartPVPRes( msg )
    w_battle_db_mgr.Init( msg );
    local UCardList = w_battle_db_mgr.GetPlayerCardList();
    local TCardList = w_battle_db_mgr.GetTargetCardList();
    local TPetList = w_battle_db_mgr.GetTargetPetList();
    local UPetList = w_battle_db_mgr.GetPlayerPetList();
    if UCardList == nil or TCardList == nil or #UCardList == 0 or #TCardList == 0 then
    	WriteConErr(" battle data err! ");
    	return false;
    end
    p.createHeroCamp( UCardList );
    p.createEnemyCamp( TCardList );
	--按活着的怪物,给个目标
    p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID(nil);
	p.PVEShowEnemyID = p.PVEEnemyID; 
	p.LockEnemy = false;
	p.isCanSelFighter = true;	
	    
    p.createPet( UPetList, E_CARD_CAMP_HERO );
    p.createPet( TPetList, E_CARD_CAMP_ENEMY );
    p.ReSetPetNodePos();
    
    w_battle_pvp.ReadyGo();
    p.ShowRoundNum();
end

--战斗阶段PVE->加载->响应
function p.ReceiveStartPVERes( msg )
	p.ReceiveStartPVPRes( msg );
end

--战斗阶段->永久BUFF表现
function p.EnterBattle_Stage_Permanent_Buff()
	w_battle_mainui.OnBattleShowFinished();
end

--进入回合阶段->召唤兽表现
function p.EnterBattle_RoundStage_Pet()
    local rounds = w_battle_stage.GetRoundNum();
    local petData = w_battle_db_mgr.GetPetRoundDB( rounds );
    if petData ~= nil and #petData > 0 and rounds <= W_BATTLE_MAX_ROUND then
        w_battle_show.DoEffectPetSkill( petData );
    else
        w_battle_mainui.OnBattleShowFinished();    
    end
end

--进入回合阶段->BUFF表现
function p.EnterBattle_RoundStage_Buff()
    local rounds = w_battle_stage.GetRoundNum();
    local buffEffectData = w_battle_db_mgr.GetBuffEffectRoundDB( rounds );
    if buffEffectData ~= nil and #buffEffectData > 0 and rounds <= W_BATTLE_MAX_ROUND then
        w_battle_show.DoEffectBuff( buffEffectData );
    else
        w_battle_mainui.OnBattleShowFinished();   
    end
end

--更新战士身上的BUFF
function p.UpdateFighterBuff()
	local heroes = p.heroCamp:GetAliveFighters();
	p.DelFighterBuff( heroes );
	local enemies = p.enemyCamp:GetAliveFighters();
	p.DelFighterBuff( enemies );
end

--更新战士身上的BUFF
function p.DelFighterBuff( fighters )
	if fighters ~= nil and #fighters >0 then
        for key, fighter in ipairs(fighters) do
            local fighterBuff = fighter.buffList;
            for k, v in ipairs(fighterBuff) do
                local buffType = v.buttType;
                local buffAni = v.buffAni;
                if not v.isDel and not HasBuffType( fighter, buffType ) then
                    fighter:GetNode():DelAniEffect( buffAni );
                    v.isDel = true;
                end
            end
        end
    end
end

--进入回合阶段->互殴
function p.EnterBattle_RoundStage_Atk()
    local rounds = w_battle_stage.GetRoundNum();
    local atkData = w_battle_db_mgr.GetRoundDB( rounds );
    if atkData ~= nil and #atkData > 0 and rounds <= W_BATTLE_MAX_ROUND then
    	w_battle_show.DoEffectAtk( atkData );
    else
        w_battle_mainui.OnBattleShowFinished();	
    end
end

--进入回合阶段->清算
function p.EnterBattle_RoundStage_Clearing()
    if not p.CheckBattleWin() then
         p.CheckBattleLose();
    end
    --进入下一个回合
    w_battle_stage.NextRound();
    p.ShowRoundNum();
    p.UpdatePetRage();
    w_battle_mainui.OnBattleShowFinished();
end

--取战斗层
function p:GetBattleLayer()
	if not isPVE then
		return w_battle_pvp.battleLayer;
	end
	return nil;
end

--创建宠物
function p.createPet( petList, camp )
	if petList == nil or #petList < 0 then
        return false;
    end
    for key, var in ipairs(petList) do
        local petId = tonumber( var.Pet_id );
        local skillId = tonumber( var.Skill_id );
        local Position = tonumber( var.Position );
        
        if camp == E_CARD_CAMP_ENEMY then
        	Position = Position + W_BATTLE_CAMP_CARD_NUM ;
        end
        
        local petPic = createNDUINode();
        petPic:Init();
        if camp == E_CARD_CAMP_ENEMY then
        	petPic:AddFgReverseEffect( SelectCell( T_PET_RES, petId, "total_pic" ) );
        else
            petPic:AddFgEffect( SelectCell( T_PET_RES, petId, "total_pic" ) );
        end
        p.uiLayer:AddChildZ( petPic,101);
        petPic:SetId( Position );
        p.petNode[ #p.petNode+1 ] = petPic;
        
        local petName = createNDUINode();
        petName:Init();
        petName:AddFgEffect( SelectCell( T_SKILL_RES, skillId, "name_effect" ) );
        p.uiLayer:AddChildZ( petName,101);
        p.petNameNode[ #p.petNameNode+1 ] = petName;
        petName:SetId( Position );
        
        local petLV = tonumber( var.Level );
        local petName = SelectCell( T_PET, petId, "name" );
        local petIconAni = SelectCell( T_PET_RES, petId, "face_pic" );
        local petSkillIconAni = SelectCell( T_SKILL_RES, skillId, "icon" );
        
        w_battle_pvp.InitPetUI( Position, petName, petLV, petIconAni, petSkillIconAni );
        w_battle_pvp.InitPetRage( Position, 0 );
    end
end

--更新宠物怒气
function p.UpdatePetRage()
    local UPetList = w_battle_db_mgr.GetPlayerPetList();
    local TPetList = w_battle_db_mgr.GetTargetPetList();
    if UPetList ~= nil then
    	for key, var in ipairs(UPetList) do
            local pos = tonumber( var.Position );
            local sp = tonumber( var.Sp );
            w_battle_pvp.UpdatePetRage( pos, sp );
        end
    end
    if TPetList ~= nil then
        for key, var in ipairs(UPetList) do
            local pos = tonumber( var.Position ) + W_BATTLE_CAMP_CARD_NUM;
            local sp = tonumber( var.Sp );
            w_battle_pvp.UpdatePetRage( pos, sp );
        end
    end
    
end

--获取宠物结点
function p.GetPetNode( posId, camp )
	if posId == nil or camp == nil then
		return false;
	end
	local ln = #p.petNode;
	local posId = tonumber( posId )
	if camp == E_CARD_CAMP_ENEMY then
		posId = posId + W_BATTLE_CAMP_CARD_NUM;
	end
	for i=1, ln do
		local pNode = p.petNode[i];
		if pNode ~= nil and pNode:GetId() == posId then
			return pNode;
		end
	end
end 

--获取宠物名称结点
function p.GetPetNameNode( posId, camp )
    if posId == nil or camp == nil then
        return false;
    end
    local ln = #p.petNameNode;
    local posId = tonumber( posId )
    if camp == E_CARD_CAMP_ENEMY then
        posId = posId + W_BATTLE_CAMP_CARD_NUM;
    end
    for i=1, ln do
        local pNode = p.petNameNode[i];
        if pNode ~= nil and pNode:GetId() == posId then
            return pNode;
        end
    end
end

--设置宠物及名称结点位置
function p.ReSetPetNodePos()
	local ln = #p.petNode;
	local ln2 = #p.petNameNode;
    for i=1, ln do
        local petNode = p.petNode[i];
        local id = petNode:GetId();
        if id > W_BATTLE_CAMP_CARD_NUM then
            petNode:SetFramePosXY( 768, GetScreenHeight()/2 - 128 );
        else
            petNode:SetFramePosXY( -256, GetScreenHeight()/2 ); 
        end
    end
    for j=1, ln2 do
        local pNode = p.petNameNode[j];
        local pId = pNode:GetId();
        if pId > W_BATTLE_CAMP_CARD_NUM then
            pNode:SetFramePosXY( -256, GetScreenHeight()/2 - 128 );
        else
            pNode:SetFramePosXY( 768, GetScreenHeight()/2 ); 
        end
    end
end

--添加蒙版图片
function p.AddMaskImage()
	if p.imageMask == nil then
		p.imageMask = createNDUIImage();
		p.imageMask:Init();
		p.imageMask:SetFrameRectFull();
		
		local pic = GetPictureByAni("lancer.mask", 0); 
		p.imageMask:SetPicture( pic );
		p.uiLayer:AddChildZ( p.imageMask,100);
		p.imageMask:AddActionEffect("x.imageMask_fadein");
	else
		p.ShowMaskImage();
	end
end

--显示蒙版
function p.ShowMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(true);
		p.imageMask:AddActionEffect("x.imageMask_fadein");
	end
end

--不显示蒙版
function p.HideMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(false);
		p.imageMask:AddActionEffect("x.imageMask_fadeout");
	end
end

--[[
--取boss
function p.GetBoss()
	return p.enemyCamp:GetFirstFighter();
end
--]]

--是否active
function p.IsActive()
    return isActive;
end

--取第一个hero
function p.GetFirstHero()
	return p.heroCamp:GetFirstFighter();
end

--取第一个enemy
function p.GetFirstEnemy()
	return p.enemyCamp:GetFirstFighter();
end

--创建玩家阵营
function p.createHeroCamp( fighters )
	p.heroCamp = w_battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray, fighters );
	p.heroCamp:AddShadows( p.heroUIArray, fighters );
	p.heroCamp:AddAllRandomTimeJumpEffect(true);
end

--创建敌对阵营
function p.createEnemyCamp( fighters )
	p.enemyCamp = w_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray, fighters );
	p.enemyCamp:AddShadows( p.enemyUIArray, fighters );
	p.enemyCamp:AddAllRandomTimeJumpEffect(false);
end

--测试PVP
function p.TestPVP()

end

--测试随机打一次(PVP)
function p.JumpToPoint( pSeq,Pos )
	local batch = battle_show.GetNewBatch();
	local f1 = p.heroCamp:GetRandomFighter();
	local f2 = p.enemyCamp:GetRandomFighter();
	local f3,f4 = p.enemyCamp:GetRandomFighter_2();
	
--	f1:AtkSkillMul( f3, f4, batch );
--	do return end

end

--查找fighter
function p.FindFighter(id)
	local f = p.heroCamp:FindFighter(id);
	if f == nil then
		f = p.enemyCamp:FindFighter(id);
	end
	return f;
end

--战斗胜利
function p.OnBattleWin()
	--GetBattleShow():Stop();
	p.isBattleEnd = true;
	SetTimerOnce( p.OpenBattleWin, 1.0f );
end

--打开战斗胜利界面
function p.OpenBattleWin()
	PlayEffectSoundByName( "battle_win.mp3" );
	w_battle_ko.CloseUI();
	--dlg_battle_win.ShowUI();
	quest_reward.ShowUI( w_battle_db_mgr.GetRewardData() );
end

--战斗失败
function p.OnBattleLose()
	--GetBattleShow():Stop();
	p.isBattleEnd = true;
	SetTimerOnce( p.OpenBattleLose, 2.0f );
end

--打开战斗失败界面
function p.OpenBattleLose()
	--dlg_battle_lose.ShowUI();
	quest_reward.ShowUI( w_battle_db_mgr.GetRewardData() );
end

--检查是否战斗胜利
function p.CheckBattleWin()
	if p.enemyCamp:IsAllFighterDead() then
		p.OnBattleWin();
		return true;
	end
	return false;
end

--检查是否战斗失败
function p.CheckBattleLose()
	if p.heroCamp:IsAllFighterDead() then
		p.OnBattleLose();
		return true;
	end
	return false;
end

function p.SendResult(missionID,result)
	local uid = GetUID();
	--uid = 10002;
	if uid ~= nil and uid > 0 then
		--模块  Action idm = 饲料卡牌unique_ID (1000125,10000123) 
		local param = string.format("&missionID=%d&result=%d&money=0&soul=0", tonumber(missionID), tonumber(result));
		SendReq("Fight","PvEReward",uid,param);
		--card_intensify_succeed.ShowUI(p.baseCardInfo);
		--p.ClearData();
	end
end;

function p.GetReuslt()
	return p.battle_result;
end;

--进入战斗
function p.EnterBattle( battleType, missionId )
	WriteCon( "w_battle_mgr.EnterBattle()" );

	math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
	p.battle_result = math.random(0,1);
	p.battle_result = 1;
	p.SendResult(missionId, p.battle_result);

	--隐藏按钮
--[[
    dlg_menu.CloseUI();
    dlg_userinfo.CloseUI();
    
	
	--enter PVP
	w_battle_pvp.ShowUI( battleType, missionId );	
	w_battle_mainui.ShowUI();
	
	--音乐
	PlayMusic_Battle();
	
	isActive = true;
	]]--
end

--退出战斗
function p.QuitBattle()
	--WriteCon( "w_battle_mgr.QuitBattle()" );

	--w_battle_pvp.CloseUI();
	--w_battle_mainui.CloseUI();

	--game_main.EnterWorldMap();
	dlg_menu.ShowUI();
	dlg_userinfo.ShowUI();
		
	hud.FadeIn();
	
	--音乐
	PlayMusic_Task();
	
	isActive = false;
	p.clearDate();
end

--检查战斗结束
function p.IsBattleEnd()
	if p.heroCamp:IsAllFighterDead() then
		return true;
	end
	
	if p.enemyCamp:IsAllFighterDead() then
		return true;
	end

	return false;
end

function p.clearDate()
	p.heroCamp = nil;
    p.enemyCamp = nil;          
    p.uiLayer = nil;           
    p.heroUIArray = nil;        
    p.enemyUIArray = nil;       
    p.petNode={};     
    p.petNameNode={};   
    p.imageMask = nil          
    p.isBattleEnd = false;
    w_battle_show.DestroyAll();
end