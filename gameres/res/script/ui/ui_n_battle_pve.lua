--------------------------------------------------------------
-- FileName:  n_battle_pve.lua
-- author: 此文件為自動生成，沒有作者。有問題請 @郭浩
--------------------------------------------------------------
ui_n_battle_pve = {};
local p =  ui_n_battle_pve;
p.ID_CTRL_PICTURE_172					    = 172;
p.ID_CTRL_TEXT_ITEMNUM5				   = 156;
p.ID_CTRL_TEXT_ITEMNUM4				   = 155;
p.ID_CTRL_TEXT_ITEMNUM3				   = 154;
p.ID_CTRL_TEXT_ITEMNUM2				   = 153;
p.ID_CTRL_TEXT_ITEMNUM1				   = 152;
p.ID_CTRL_SKILL_ROLE					     = 210;
p.ID_CTRL_SKILL_NAME					     = 208;
p.ID_CTRL_SKILL_BG					       = 207;
p.ID_CTRL_PICTURE_TARGET6				 = 144;
p.ID_CTRL_PICTURE_TARGET5				 = 143;
p.ID_CTRL_PICTURE_TARGET4				 = 142;
p.ID_CTRL_PICTURE_TARGET3				 = 141;
p.ID_CTRL_PICTURE_TARGET2				 = 140;
p.ID_CTRL_PICTURE_TARGET1				 = 139;
p.ID_CTRL_BUTTON_TARGET6				  = 138;
p.ID_CTRL_BUTTON_TARGET5				  = 137;
p.ID_CTRL_BUTTON_TARGET4				  = 136;
p.ID_CTRL_BUTTON_TARGET3				  = 135;
p.ID_CTRL_BUTTON_TARGET2				  = 134;
p.ID_CTRL_BUTTON_TARGET1				  = 133;
p.ID_CTRL_BUTTON_67					      = 67;
p.ID_CTRL_BUTTON_66					      = 66;
p.ID_CTRL_BUTTON_65					      = 65;
p.ID_CTRL_BUTTON_64					      = 64;
p.ID_CTRL_BUTTON_68					      = 68;
p.ID_CTRL_BUTTON_63					      = 63;
p.ID_CTRL_PICTURE_120					    = 132;
p.ID_CTRL_PICTURE_119					    = 131;
p.ID_CTRL_PICTURE_118					    = 130;
p.ID_CTRL_PICTURE_117					    = 129;
p.ID_CTRL_PICTURE_116					    = 128;
p.ID_CTRL_PICTURE_115					    = 127;
p.ID_CTRL_PICTURE_145					    = 151;
p.ID_CTRL_PICTURE_144					    = 150;
p.ID_CTRL_PICTURE_143					    = 149;
p.ID_CTRL_PICTURE_142					    = 148;
p.ID_CTRL_PICTURE_141					    = 147;
p.ID_CTRL_PICTURE_139					    = 146;
p.ID_CTRL_PICTURE_162					    = 162;
p.ID_CTRL_PICTURE_161					    = 161;
p.ID_CTRL_PICTURE_160					    = 160;
p.ID_CTRL_PICTURE_159					    = 159;
p.ID_CTRL_PICTURE_158					    = 158;
p.ID_CTRL_PICTURE_157					    = 157;
p.ID_CTRL_EXP_SP6						       = 111;
p.ID_CTRL_EXP_SP4						       = 119;
p.ID_CTRL_EXP_HP1						       = 102;
p.ID_CTRL_EXP_HP6						       = 107;
p.ID_CTRL_PICTURE_206					    = 206;
p.ID_CTRL_EXP_SP5						       = 115;
p.ID_CTRL_PICTURE_205					    = 205;
p.ID_CTRL_EXP_HP5						       = 105;
p.ID_CTRL_PICTURE_202					    = 202;
p.ID_CTRL_PICTURE_201					    = 201;
p.ID_CTRL_EXP_SP1						       = 117;
p.ID_CTRL_PICTURE_198					    = 198;
p.ID_CTRL_PICTURE_197					    = 197;
p.ID_CTRL_PICTURE_195					    = 195;
p.ID_CTRL_TEXT_118					       = 118;
p.ID_CTRL_TEXT_116					       = 116;
p.ID_CTRL_TEXT_114					       = 114;
p.ID_CTRL_EXP_SP2						       = 113;
p.ID_CTRL_TEXT_112					       = 112;
p.ID_CTRL_TEXT_110					       = 110;
p.ID_CTRL_EXP_SP3						       = 109;
p.ID_CTRL_PICTURE_204					    = 204;
p.ID_CTRL_PICTURE_200					    = 200;
p.ID_CTRL_EXP_HP3						       = 106;
p.ID_CTRL_PICTURE_203					    = 203;
p.ID_CTRL_TEXT_108					       = 108;
p.ID_CTRL_EXP_HP2						       = 104;
p.ID_CTRL_PICTURE_199					    = 199;
p.ID_CTRL_EXP_HP4						       = 103;
p.ID_CTRL_TEXT_HP3					       = 101;
p.ID_CTRL_TEXT_HP6					       = 100;
p.ID_CTRL_TEXT_HP						       = 163;
p.ID_CTRL_TEXT_HP5					       = 99;
p.ID_CTRL_TEXT_HP2					       = 98;
p.ID_CTRL_TEXT_HP4					       = 97;
p.ID_CTRL_TEXT_HP1					       = 96;
p.ID_CTRL_TEXT_95						       = 95;
p.ID_CTRL_TEXT_94						       = 94;
p.ID_CTRL_TEXT_93						       = 93;
p.ID_CTRL_TEXT_92						       = 92;
p.ID_CTRL_PICTURE_196					    = 196;
p.ID_CTRL_TEXT_91						       = 91;
p.ID_CTRL_TEXT_90						       = 90;
p.ID_CTRL_TEXT_NAME6					     = 89;
p.ID_CTRL_TEXT_NAME3					     = 88;
p.ID_CTRL_TEXT_NAME5					     = 87;
p.ID_CTRL_TEXT_NAME2					     = 86;
p.ID_CTRL_TEXT_NAME4					     = 85;
p.ID_CTRL_TEXT_NAME1					     = 83;
p.ID_CTRL_PICTURE_CHA6				    = 81;
p.ID_CTRL_PICTURE_CHA3				    = 80;
p.ID_CTRL_PICTURE_CHA5				    = 79;
p.ID_CTRL_PICTURE_CHA2				    = 78;
p.ID_CTRL_PICTURE_CHA4				    = 77;
p.ID_CTRL_PICTURE_CHA1				    = 76;
p.ID_CTRL_PIC_CARDBG1					    = 757;
p.ID_CTRL_PIC_CARDBG2					    = 756;
p.ID_CTRL_PIC_CARDBG3					    = 755;
p.ID_CTRL_PIC_CARDBG4					    = 754;
p.ID_CTRL_PIC_CARDBG5					    = 601;
p.ID_CTRL_PIC_CARDBG6					    = 164;
p.ID_CTRL_PICTURE_62					     = 62;
p.ID_CTRL_RIGHT_SPRITE_6				  = 18;
p.ID_CTRL_RIGHT_SPRITE_1				  = 9;
p.ID_CTRL_RIGHT_SPRITE_5				  = 11;
p.ID_CTRL_RIGHT_SPRITE_2				  = 8;
p.ID_CTRL_RIGHT_SPRITE_3				  = 7;
p.ID_CTRL_RIGHT_SPRITE_4				  = 10;
p.ID_CTRL_PICTURE_IMPORTANT			= 121;
p.ID_CTRL_PICTURE_140					    = 145;
p.ID_CTRL_TEXT_365					       = 365;
p.ID_CTRL_EXP_HP						        = 120;
p.ID_CTRL_PICTURE_342					    = 342;
p.ID_CTRL_PICTURE_209					    = 209;
p.ID_CTRL_PICTURE_341					    = 341;
p.ID_CTRL_PICTURE_340					    = 340;
p.ID_CTRL_PICTURE_339					    = 339;
p.ID_CTRL_PICTURE_338					    = 338;
p.ID_CTRL_TEXT_ITEM5					     = 337;
p.ID_CTRL_TEXT_ITEM4					     = 336;
p.ID_CTRL_TEXT_ITEM3					     = 335;
p.ID_CTRL_TEXT_ITEM2					     = 334;
p.ID_CTRL_TEXT_ITEM1					     = 333;
p.ID_CTRL_PICTURE_332					    = 332;
p.ID_CTRL_PICTURE_331					    = 331;
p.ID_CTRL_PICTURE_330					    = 330;
p.ID_CTRL_PICTURE_329					    = 329;
p.ID_CTRL_PICTURE_328					    = 328;
p.ID_CTRL_PICTURE_BOX					    = 84;
p.ID_CTRL_BUTTON_75					      = 75;
p.ID_CTRL_PICTURE_74					     = 74;
p.ID_CTRL_PICTURE_73					     = 73;
p.ID_CTRL_PICTURE_72					     = 72;
p.ID_CTRL_PICTURE_71					     = 71;
p.ID_CTRL_PICTURE_70					     = 70;
p.ID_CTRL_BUTTON_ITEM5				    = 126;
p.ID_CTRL_BUTTON_ITEM4				    = 125;
p.ID_CTRL_BUTTON_ITEM3				    = 124;
p.ID_CTRL_BUTTON_ITEM2				    = 123;
p.ID_CTRL_BUTTON_ITEM1				    = 122;
p.ID_CTRL_LEFT_SPRITE_6				   = 16;
p.ID_CTRL_PICTURE_CENTER				  = 12;
p.ID_CTRL_LEFT_SPRITE_5				   = 4;
p.ID_CTRL_LEFT_SPRITE_4				   = 3;
p.ID_CTRL_LEFT_SPRITE_3				   = 2;
p.ID_CTRL_LEFT_SPRITE_2				   = 5;
p.ID_CTRL_LEFT_SPRITE_1				   = 6;
p.ID_CTRL_PICTURE_BG1					    = 217;
p.ID_CTRL_PICTURE_BG					     = 294;
p.ID_CTRL_PICTURE_82					     = 82;
