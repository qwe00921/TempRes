--------------------------------------------------------------
-- FileName:    w_battle_stage.lua
-- author:      hst, 2013��11��26��
-- purpose:     ս��״̬
--------------------------------------------------------------

w_battle_stage = {}
local p = w_battle_stage;

p.roundNum = 0;                 --ս���غ���
p.battleStage = 0;              --��ս�׶�,��1~4���׶�:���ؽ׶�,����BUFF�׶�,�غϽ׶�,�����׶�
p.battleRoundStage = 0;         --�غϽ׶�,��4���ӽ׶�:�ٻ���,BUFF����,��Ź������

--��ʹ��
function p.Init()
    p.roundNum = 1;                  
    p.battleStage = 0;              
    p.battleRoundStage = 0;      
end

--������һ���غ�
function p.NextRound()
   p.roundNum = p.roundNum + 1;
end

--��ȡ�غ���
function p.GetRoundNum()
    return p.roundNum;
end

--------------------------------------------------------------
--��ս�ĸ��ֽ׶ι���
--------------------------------------------------------------

--ս���׶�->����
function p.EnterBattle_Stage_Loading()
    p.battleStage = W_BATTLE_STAGE_LOADING;
end

--ս���׶�->����BUFF����
function p.EnterBattle_Stage_Permanent_Buff()
    p.battleStage = W_BATTLE_STAGE_PERMANENT_BUFF;
end

--ս���׶�->�غ�
function p.EnterBattle_Stage_Round()
    p.battleStage = W_BATTLE_STAGE_ROUND;
end

--ս���׶�->����
function p.EnterBattle_Stage_End()
    p.battleStage = W_BATTLE_STAGE_END;
end

--------------------------------------------------------------
--���뻥Ź�׶εĻغϽ׶ι���
--------------------------------------------------------------

--�غϽ׶�->�ٻ��� 
function p.EnterBattle_RoundStage_Pet()
    p.battleRoundStage = W_BATTLE_ROUND_STAGE_PET;
end

--�غϽ׶�->BUFF����
function p.EnterBattle_RoundStage_Buff()
    p.battleRoundStage = W_BATTLE_ROUND_STAGE_BUFF;
end

--�غϽ׶�->��Ź
function p.EnterBattle_RoundStage_Atk()
    p.battleRoundStage = W_BATTLE_ROUND_STAGE_ATK;
end

--�غϽ׶�->����
function p.EnterBattle_RoundStage_Clearing()
    p.battleRoundStage = W_BATTLE_ROUND_STAGE_CLEARING;
end

--------------------------------------------------------------
--��ս�ĸ��ֽ׶ε��ж�
--------------------------------------------------------------

--�Ƿ���ս�����ؽ׶�
function p.IsBattle_Stage_Loading()
    if p.battleStage == W_BATTLE_STAGE_LOADING then
        return true;
    end
    return false;
end

--�Ƿ���ս������BUFF�׶�
function p.IsBattle_Stage_Permanent_Buff()
    if p.battleStage == W_BATTLE_STAGE_PERMANENT_BUFF then
        return true;
    end
    return false;
end

--�Ƿ���ս���غϽ׶�
function p.IsBattle_Stage_Round()
    if p.battleStage == W_BATTLE_STAGE_ROUND then
        return true;
    end
    return false;
end

--�Ƿ���ս�������׶�
function p.IsBattle_Stage_End()
    if p.battleStage == W_BATTLE_STAGE_END then
        return true;
    end
    return false;
end

--------------------------------------------------------------
--�غϵĸ��ֽ׶ε��ж�
--------------------------------------------------------------

--�Ƿ��ǻ�Ź�׶��ٻ��ޱ���
function p.IsBattle_RoundStage_Pet()
    if p.battleRoundStage == W_BATTLE_ROUND_STAGE_PET then
        return true;
    end
    return false;
end

--�Ƿ��ǻ�Ź�׶�BUFF����
function p.IsBattle_RoundStage_Buff()
    if p.battleRoundStage == W_BATTLE_ROUND_STAGE_BUFF then
        return true;
    end
    return false;
end

--�Ƿ��ǻ�Ź�׶�BUFF����
function p.IsBattle_RoundStage_Atk()
    if p.battleRoundStage == W_BATTLE_ROUND_STAGE_ATK then
        return true;
    end
    return false;
end

--�Ƿ��ǻ�Ź�׶ν���
function p.IsBattle_RoundStage_Clearing()
    if p.battleRoundStage == W_BATTLE_ROUND_STAGE_CLEARING then
        return true;
    end
    return false;
end

--ѡ�߽���
function p.SelOver(atkFighter, targetFighter, batch, damage, lIsJoinAtk, lIsCrit )
	--�Ȳ��Ź���������
	if batch == nil then return end
    
    --[[local Damage = tonumber( target.Damage ); --�۳�Ѫ��
    local RemainHp = tonumber( target.RemainHp ); --��ʣѪ��
    local Crit = target.Crit ; --����
    local Dead = target.TargetDead;--����
    local Revive = target.Revive;--����
    ]]--
	local distance = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "distance" ) );
    local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );
    
    local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddSerialSequence();
    local seqBullet = batch:AddSerialSequence();
    
    if (seqAtk == nil) or (seqTarget == nil) then
        WriteCon( "create 2 seq failed");
        return;
    end
    
    local isBullet = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "is_bullet" ) );
    local bulletAni;
    if isBullet == W_BATTLE_BULLET_1 then --Զ�̹���
        bulletAni = "w_bullet."..tostring( atkFighter.cardId );
    end
    
    local playerNode = atkFighter:GetPlayerNode();
    
    --�����������λ��
    local originPos = playerNode:GetCenterPos();

    --�ܻ�Ŀ���λ��
    local enemyPos = targetFighter:GetFrontPos(playerNode);
    
	--��������
    local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
    seqAtk:AddCommand( cmdAtkBegin );
    
    local cmdSetPic = atkFighter:cmdLua( "SetFighterPic",  0, "", seqAtk );
    
    if distance == W_BATTLE_DISTANCE_NoArcher then  --��ս����
        --�򹥻�Ŀ���ƶ�
        local cmd2 = JumpMoveTo(atkFighter, originPos, enemyPos, seqAtk, false);
		

		seqTarget:SetWaitEnd( cmd2 ); --�ܻ���ʼͬʱ���Ŷ���
		--show������ֵ����,ƮѪ,�жϲ������ܻ�����
		atkFighter:cmdLua( "atk_damage",  targetFighter:GetId(), damage, seqTarget );
    end
    
    --�������˶���
    local cmdAtk = createCommandPlayer():Atk( 0.3, playerNode, "" );
    seqAtk:AddCommand( cmdAtk );
    --cmdAtk:SetDelay(0.2f); --���ù����ӳ�
    
    --�ܻ�����
    if atkSound ~= nil then
        local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
        seqAtk:AddCommand( cmdAtkMusic );
    end
    
    --���վ������
    local cmd4 = createCommandPlayer():Standby( 0.01, playerNode, "" );
    seqAtk:AddCommand( cmd4 );
    
    if distance == W_BATTLE_DISTANCE_NoArcher then
        --����ԭ����λ��
        local cmd5 = JumpMoveTo(atkFighter, enemyPos, originPos, seqAtk, false);
    end
    
    local bulletend;
    if bulletAni ~= nil then
        local deg = atkFighter:GetAngleByFighter( targetFighter );
        local bullet = w_bullet:new();
        bullet:AddToBattleLayer();
        bullet:SetEffectAni( bulletAni );
                    
        bullet:GetNode():SetRotationDeg( deg );
        local bullet1 = bullet:cmdSetVisible( true, seqBullet );
        bulletend = bullet:cmdShoot( atkFighter, targetFighter, seqBullet, false );
        local bullet3 = bullet:cmdSetVisible( false, seqBullet );
        seqBullet:SetWaitEnd( cmdAtk );
		
		
		--show������ֵ����,ƮѪ,�жϲ������ܻ�����
		atkFighter:cmdLua( "atk_damage",  targetFighter:GetId(), damage, seqAtk );
    end
    
    local cmdAtkEnd = createCommandInstant_Misc():SetZOrderAtTop( atkFighter:GetNode(), false );
    seqAtk:AddCommand( cmdAtkEnd );
    
	--��������������, ����˳�д�����1,��Ϊ0ʱ,�ж��Ƿ����վ����������.
	--��cmd����ִ��ѹ��seqAtk˳��ִ��
	atkFighter:cmdLua( "atk_hurt",  targetFighter:GetId(), "", seqAtk );
	

end;	






