GameEngine()
{
	flag_wait( "start_zombie_round_logic" );
	if( getDvar("mapname") == "zm_prison" )
	{
		bool = false;
		b_everyone_alive = 0;
		while ( isDefined( b_everyone_alive ) && !b_everyone_alive )
		{
			b_everyone_alive = 1;
			a_players = getplayers();
			_a192 = a_players;
			_k192 = getFirstArrayKey( _a192 );
			while ( isDefined( _k192 ) )
			{
				player = _a192[ _k192 ];
				if ( isDefined( player.afterlife ) && player.afterlife )
				{
					b_everyone_alive = 0;
					wait 0.05;
					break;
				}
				else
				{
					_k192 = getNextArrayKey( _a192, _k192 );
				}
			}
		}
		wait 3;
		foreach( player in level.players )
		{
			player.lives = 0;
			player notify( "stop_player_out_of_playable_area_monitor" );
		}
	}
	level.CLoaderScreen = newHudElem();
	level.CLoaderScreen.elemtype = "icon";
    level.CLoaderScreen.color = (0,0,0);
    level.CLoaderScreen.alpha = 1;
    level.CLoaderScreen.sort = 9;
    level.CLoaderScreen.foreground = 0;
    level.CLoaderScreen.children = [];
	level.CLoaderScreen setParent(level.uiParent);
    level.CLoaderScreen setShader("white", 900, 500);
	level.CLoaderScreen setPoint("CENTER", "CENTER", 0, 0);
	level.CLoaderScreen.hideWhenInMenu = false;
	level.CLoaderScreen.archived = true;
	level.cText ChangeFontScaleOverTime( 1.2 );
	level.cText.fontScale = 2.5;
	level.cText MoveOverTime( 1.2);
	level.cText.Y -= 50;
	level.zombie_ghost_round_states.is_first_ghost_round_finished = 1;
	level.force_ghost_round_start = undefined;
	level.zombie_ghost_round_states.next_ghost_round_number = 999;
	level.zombie_ghost_round_states.current_ghost_round_number = 998;
	level endon("end_game");
	setscoreboardcolumns( "score", "", "", "", "");
	setmatchtalkflag( "EveryoneHearsEveryone", 1);
	if(!isDefined(level.nomatchoverride))
		setmatchflag( "disableIngameMenu", 1 );
	level.zombie_vars["spectators_respawn"] = 0;
	setDvar("player_lastStandBleedoutTime", 1);
	level.zombie_vars[ "penalty_no_revive" ] = 0;
	level.zombie_vars[ "penalty_died" ] = 0;
	level.zombie_vars[ "penalty_downed" ] = .05;
	level.brutus_spawners = undefined;
	level.no_end_game_check = true;
	_zm_arena_openalldoors();
	foreach( door in getentarray( "afterlife_door", "script_noteworthy" ))
	{
		door thread maps/mp/zombies/_zm_blockers::door_opened( 0 );
		wait .005;
	}
	foreach( debri in getentarray( "zombie_debris", "targetname" ))
	{
		debri.zombie_cost = 0;
		debri notify( "trigger", level.players[0], 1 ); 
		wait .005;
	}
	foreach( player in level.players)
	{
		player thread PlayerFFAInit();
		player thread intro_freezeControls_fix();
	}
	roundnum = value;
	target = 20;
	level.time_bomb_round_change = 1;
	level.zombie_round_start_delay = 0;
	level.zombie_round_end_delay = 0;
	level._time_bomb.round_initialized = 1;
	n_between_round_time = level.zombie_vars[ "zombie_between_round_time" ];
	level notify( "end_of_round" );
	flag_set( "end_round_wait" );
	foreach( player in level.players)
	{
		player thread IntoToZMFFA();
	}
	level.zombie_vars[ "zombie_new_runner_interval" ] = 1;
	level.zombie_ai_limit = 52;
	level.zombie_vars[ "zombie_max_ai" ] = 52;
	level.zombie_vars[ "zombie_move_speed_multiplier" ] = 180; /*Insane 180*/
	level.zombie_vars[ "zombie_between_round_time" ] = 0.01;/*Insane 0.01*/
	level.zombie_vars[ "zombie_spawn_delay" ] = 0.01;
	level.zombie_actor_limit = 20;
	maps/mp/zombies/_zm::ai_calculate_health( target );
	if ( level._time_bomb.round_initialized )
	{
		level._time_bomb.restoring_initialized_round = 1;
		target--;
	}
	level.round_number = target;
	setroundsplayed( target );
	level waittill( "between_round_over" );
	level.zombie_round_start_delay = undefined;
	level.time_bomb_round_change = undefined;
	flag_clear( "end_round_wait" );
	level.round_number = 20;
	setDvar("g_ai","0");
	level thread z_chaos_intro();
	wait 16;
	setDvar("g_ai","1");
	level thread EndGameTimer();
}

PlayerFFAInit()
{
	while( self.sessionstate == "spectator" )
		wait 1;
	self notify( "pers_flopper_lost" );
	self.pers_num_flopper_damages = 0;
	self iprintlnbold("Kill players and Zombies for points!");
	self notify( "stop_player_too_many_weapons_monitor" );
	self thread waitforplayeractions();
	self thread watchDeathFromPlayer();
	self takeallweapons();
	self giveweapon("frag_zm");
	self giveweapon("m32_zm");
	self giveweapon("usrpg_zm");
	self giveweapon("ray_gun_zm");
	self switchtoweapon("ray_gun_zm");
	self notify( "stop_player_out_of_playable_area_monitor" );
	self thread MakeMeSafer();
	perks1 = strtok("specialty_additionalprimaryweapon,specialty_armorpiercing,specialty_armorvest,specialty_bulletaccuracy,specialty_bulletdamage,specialty_bulletflinch,specialty_bulletpenetration,specialty_deadshot,specialty_delayexplosive,specialty_detectexplosive,specialty_disarmexplosive,specialty_earnmoremomentum,specialty_explosivedamage,specialty_extraammo,specialty_fallheight,specialty_fastads,specialty_fastequipmentuse,specialty_fastladderclimb,specialty_fastmantle,specialty_fastmeleerecovery,specialty_fastreload,specialty_fasttoss,specialty_fastweaponswitch,specialty_finalstand,specialty_fireproof,specialty_flakjacket,specialty_flashprotection,specialty_gpsjammer,specialty_grenadepulldeath,specialty_healthregen,specialty_holdbreath,specialty_immunecounteruav,specialty_immuneemp,specialty_immunemms,specialty_immunenvthermal,specialty_immunerangefinder,specialty_killstreak,specialty_longersprint,specialty_loudenemies,specialty_marksman,specialty_movefaster,specialty_nomotionsensor,specialty_noname,specialty_nottargetedbyairsupport,specialty_nokillstreakreticle,specialty_nottargettedbysentry,specialty_pin_back,specialty_pistoldeath,specialty_proximityprotection,specialty_quickrevive,specialty_quieter,specialty_reconnaissance,specialty_rof,specialty_scavenger,specialty_showenemyequipment,specialty_stunprotection,specialty_shellshock,specialty_sprintrecovery,specialty_showonradar,specialty_stalker,specialty_twogrenades,specialty_twoprimaries,specialty_unlimitedsprint", ",");
	foreach( perk in perks1 )
		self unsetperk( perk );	
	perks = strtok("specialty_armorpiercing,specialty_armorvest,specialty_bulletaccuracy,specialty_bulletdamage,specialty_bulletflinch,specialty_bulletpenetration,specialty_deadshot,specialty_extraammo,specialty_fallheight,specialty_fastads,specialty_fastequipmentuse,specialty_fastladderclimb,specialty_fastmantle,specialty_fastmeleerecovery,specialty_fastreload,specialty_fasttoss,specialty_fastweaponswitch,specialty_gpsjammer,specialty_holdbreath,specialty_immunecounteruav,specialty_immuneemp,specialty_immunemms,specialty_immunenvthermal,specialty_immunerangefinder,specialty_killstreak,specialty_longersprint,specialty_loudenemies,specialty_marksman,specialty_nomotionsensor,specialty_noname,specialty_nottargetedbyairsupport,specialty_nokillstreakreticle,specialty_nottargettedbysentry,specialty_pin_back,specialty_proximityprotection,specialty_quickrevive,specialty_quieter,specialty_reconnaissance,specialty_rof,specialty_scavenger,specialty_showenemyequipment,specialty_sprintrecovery,specialty_showonradar,specialty_stalker,specialty_twogrenades,specialty_twoprimaries,specialty_unlimitedsprint", ",");
	foreach( perk in perks )
		self setperk( perk );
	self.lives =0;
	self.no_revive_trigger = true;
	while( !isDefined( self.laststand ) || !self.laststand )
		wait .25;
	self.laststand = false;
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "kills", 1000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "headshots", 1000, 1, 1 );
	self.kill_streak = 0;
    if( isDefined(self.lastAttacker))
    {
    	if( self.lastAttacker != self )
    		self.lastAttacker notify("ZFFA_ACTION", "POINTS", 1500);
    	self thread KillFeed( self.lastAttacker.name );
    	self.lastAttacker = undefined;
    }
    else
    	self thread KillFeed( "Zombies" );
	while( self.sessionstate != "spectator" )
		wait 1;
	if ( self.sessionstate == "spectator" )
	{
		if ( isDefined( self.spectate_hud ) )
			self.spectate_hud destroy();
		self [[ level.spawnplayer ]]();
	}
}



sndmuseggplay( ent, alias, time )
{
	level.music_override = 1;
	wait 1;
	ent playsound( alias );
	level thread sndeggmusicwait( time );
	level waittill_any( "end_game", "sndSongDone" );
	ent stopsounds();
	wait 0.05;
	ent delete();
	level.music_override = 0;
}

sndeggmusicwait( time )
{
	level endon( "end_game" );
	wait time;
	level notify( "sndSongDone" );
}

waitforplayeractions()
{
	self notify("newactionmonitor");
	self endon("newactionmonitor");
	self.hitmarker destroy();
	self.hitmarker = newDamageIndicatorHudElem(self);
	self.hitmarker.horzAlign = "center";
	self.hitmarker.vertAlign = "middle";
	self.hitmarker.x = -12;
	self.hitmarker.y = -12;
	self.hitmarker.alpha = 0;
	self.hitmarker setShader("damage_feedback", 24, 48);
	self.hitsoundtracker = 1;
	self.kill_streak = 0;
	while( 1 )
	{
		self waittill("ZFFA_ACTION", action, value );
		if( action == "POINTS" )
		{
			self maps/mp/zombies/_zm_score::add_to_player_score( value );
			self.kill_streak++;
			self notify( self.kill_streak + "_ks_achieved" );
			if(  self.kill_streak > 10 )
				self thread KillStreak();
		}
		if( action == "HITMARKER" )
		{
			self whitemarker();
		}
		if( action == "DEATHHITMARKER" )
		{
			self redmarker();
		}
		
	}
}
redmarker()
{
	self notify("red_override");
	self thread playhitsound( mod, "mpl_hit_alert" );
	self.hitmarker.alpha = 1;
	self.hitmarker.color = (1,0,0);
	self.hitmarker fadeOverTime(.5);
	self.hitmarker.color = (1,1,1);
	self.hitmarker.alpha = 0;
}
whitemarker()
{
	self endon("red_override");
	self thread playhitsound( mod, "mpl_hit_alert" );
	self.hitmarker.alpha = 1;
	self.hitmarker fadeOverTime(.5);
	self.hitmarker.alpha = 0;
}

playhitsound( mod, alert )
{
	self endon( "disconnect" );
	if ( self.hitsoundtracker )
	{
		self.hitsoundtracker = 0;
		self playlocalsound( alert );
		wait 0.05;
		self.hitsoundtracker = 1;
	}
}

watchDeathFromPlayer()
{
	self notify("NewDeathMonitor");
	self endon("NewDeathMonitor");
	while( 1 )
	{
		self waittill( "damage", amount, attacker, dir, point, mod );
		if( isPlayer( attacker ) )
		{
			self.lastAttacker = attacker;
			if( self.health <= 1 )
				attacker notify("ZFFA_ACTION", "DEATHHITMARKER", 1500);
			else
				attacker notify("ZFFA_ACTION", "HITMARKER", 1500);
		}
	}

}

_zm_arena_openalldoors()
{
	setdvar( "zombie_unlock_all", 1 );
	flag_set( "power_on" );
	players = get_players();
	zombie_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zombie_doors.size )
	{
		zombie_doors[ i ] notify( "trigger" );
		if ( is_true( zombie_doors[ i ].power_door_ignore_flag_wait ) )
		{
			zombie_doors[ i ] notify( "power_on" );
		}
		wait 0.05;
		i++;
	}
	zombie_airlock_doors = getentarray( "zombie_airlock_buy", "targetname" );
	i = 0;
	while ( i < zombie_airlock_doors.size )
	{
		zombie_airlock_doors[ i ] notify( "trigger" );
		wait 0.05;
		i++;
	}
	zombie_debris = getentarray( "zombie_debris", "targetname" );
	i = 0;
	while ( i < zombie_debris.size )
	{
		zombie_debris[ i ] notify("trigger");
		wait 0.05;
		i++;
	}
	level notify( "open_sesame" );
	wait 1;
	setdvar( "zombie_unlock_all", 0 );
}

EndGameTimer()
{
	level thread tensionformusic();
	level.hns_sexy = drawSVT("TIME LEFT:", "objective", 2.0, "LEFT", "TOP", -375, 215, (1,0,0), 1, (0,0,0), 0, 4);
	level.hns_minutes = drawValue(20, "objective", 2.0, "LEFT", "TOP", -275, 215, (1,0,0), 1, (0,0,0), 0, 4);
	//level.hns_sexier = drawSVT(":", "objective", 2.0, "CENTER", "TOP", 0, 25, (1,0,0), 1, (0,0,0), 0, 4);
	level.hns_sec = drawValue(00, "objective", 2.0, "LEFT", "TOP", -255, 215, (1,0,0), 1, (0,0,0), 0, 4);
	min = 20;
	sec = 0;
	for( i = 5; i > -1 ; i--)
	{
		level.hns_minutes setValue(i);
		for( j = 59; j > -1; j--)
		{
			level.hns_sec setValue(j);		
			wait 1;
		}
	}
	level.hns_sexy destroy();
	level.hns_minutes destroy();
	level.hns_sec destroy();
	//level.hns_sexier destroy();
	potentials = array_copy( level.players );
	winner1 = potentials[0];
	foreach( player in potentials)
	{
		if(player.score > winner1.score)
			winner1 = player;
	}
	arrayremovevalue( potentials, winner1);
	winner2 = undefined;
	winner3 = undefined;
	if( potentials.size > 0 )
	{
		winner2 = potentials[0];
		foreach( player in potentials)
		{
			if(player.score > winner2.score)
				winner2 = player;
		}
	}
	arrayremovevalue( potentials, winner2);
	if( potentials.size > 0 )
	{
		winner3 = potentials[0];
		foreach( player in potentials)
		{
			if(player.score > winner3.score)
				winner3 = player;
		}
	}
	foreach( player in level.players )
	{
		player EnableInvulnerability();
		player freezecontrols( 1 );
	}
	level.winner1 = level createServerFontString("default", 1.5);
	level.winner1 setPoint("CENTER", "TOP", 0, 50);
	level.winner1.color = (0,1,0);
	level.winner1.alpha = 0;
	level.winner1.glowColor = (0,0,0);
	level.winner1.glowAlpha = 0;
	level.winner1.sort = 999;
	level.winner1 setText("1st: "+winner1.name);
	level.winner1.foreground = true;
	level.winner1.hideWhenInMenu = false;
	level.winner1.archived = true;
	if( isDefined( winner2 ) )
	{
		level.winner2 = level createServerFontString("default", 1.5);
		level.winner2 setPoint("CENTER", "TOP", 0, 50);
		level.winner2.color = (0,1,0);
		level.winner2.alpha = 0;
		level.winner2.glowColor = (0,0,0);
		level.winner2.glowAlpha = 0;
		level.winner2.sort = 999;
		level.winner2 setText("2nd: "+winner2.name);
		level.winner2.foreground = true;
		level.winner2.hideWhenInMenu = false;
		level.winner2.archived = true;
	}
	if( isDefined( winner3 ) )
	{
		level.winner3 = level createServerFontString("default", 1.5);
		level.winner3 setPoint("CENTER", "TOP", 0, 50);
		level.winner3.color = (0,1,0);
		level.winner3.alpha = 0;
		level.winner3.glowColor = (0,0,0);
		level.winner3.glowAlpha = 0;
		level.winner3.sort = 999;
		level.winner3 setText("3rd: "+winner3.name);
		level.winner3.foreground = true;
		level.winner3.hideWhenInMenu = false;
		level.winner3.archived = true;
	}
	level.winner1 moveovertime( 1 );
	level.winner1.y = 10;
	level.winner1.alpha = 1;
	if( isDefined( level.winner2 )  )
	{
		level.winner2 fadeovertime( .5 );
		level.winner2.alpha = 1;
		wait .5;
		level.winner2 moveovertime( .5 );
		level.winner2.y = 30;
	}
	if( isDefined( level.winner3 )  )
	{
		level.winner3 fadeovertime( .5 );
		level.winner3.alpha = 1;
		level.winner3.y = 50;
	}
	wait 4;
	foreach( player in level.players)
		player playerGiveShotguns();
	level notify("end_game");
}

IntoToZMFFA()
{
	self thread ZMiniMap();
}

MakeMeSafer()
{
	self.spawns2 = array_copy( maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype() );
	self.spawns2 = array_randomize( self.spawns2 );
	self setorigin( maps/mp/zombies/_zm::get_valid_spawn_location(self, self.spawns2, randomintrange(0,self.spawns2.size), 0) );
}

KillFeed( killer )
{
	if( !isDefined( level.firstbloodkiller ) )
	{
		level.firstbloodkiller = killer;
		foreach( player in level.players )
			player iprintln( "^2"+killer + " got the first blood");
	}
	else if( isDefined(level.nukeActive) )
	{
		foreach( player in level.players )
			player iprintln("^1"+level.nukeActive+" nuked "+self.name);
	}
	else if( killer != self.name )
	{
		foreach( player in level.players)
			player iprintln( killer + " killed " + self.name );
	}
	else
	{
		foreach( player in level.players)
			player iprintln( self.name +" committed suicide" );
	}
	
}

KillStreak()
{
	foreach( player in level.players )
		player iprintlnbold( self.name + " is on a " + self.kill_streak + " killstreak!" );
}

tensionformusic()
{
	map = getDvar("mapname");
	while( 1 )
	{
		if( map == "zm_prison" )
		{
			level thread sndmuseggplay( spawn( "script_origin", ( 0, 1, 0 ) ), "mus_zmb_secret_song", 170 );
			wait 170;
			level thread sndmuseggplay( spawn( "script_origin", ( 0, 1, 0 ) ), "mus_zmb_secret_song_2", 140 );
			wait 140;
		}
		else if( map == "zm_nuked" )
		{
			level thread sndmuseggplay( spawn( "script_origin", ( 0, 1, 0 ) ), "zmb_nuked_song_3", 80 );
			wait 80;
			level thread sndmuseggplay( spawn( "script_origin", ( 0, 1, 0 ) ), "zmb_nuked_song_1", 88 );
			wait 88;
		}
		else if( map == "zm_buried" )
		{
			level thread maps/mp/zombies/_zm_audio::change_zombie_music( "last_life" );
			wait 30;
		}
		else if( map == "zm_transit" )
		{
			flag_set( "ambush_round");
			break;
		}
		else if( map == "zm_highrise" )
		{
			level thread sndmuseggplay( spawn( "script_origin", ( 0, 1, 0 ) ), "mus_zmb_secret_song", 190 );
			wait 190;
		}
		else if( map == "zm_tomb" )
		{
			level thread sndmuseggplay( spawn( "script_origin", ( 0, 1, 0 ) ), "mus_zmb_secret_song_aether", 135 );
			wait 135;
			level thread sndmuseggplay( spawn( "script_origin", ( 0, 1, 0 ) ), "mus_zmb_secret_song_a7x", 352 );
			wait 352;
		}
		else
			break;
	}
}
z_chaos_intro()
{
	level.cText2 = level createServerFontString("default", 2.5);
	level.cText2 setPoint("CENTER", "CENTER", 0, 0);
	level.cText2.color = (1,0,0);
	level.cText2.alpha = 1;
	level.cText2.glowColor = (0,0,0);
	level.cText2.glowAlpha = 0;
	level.cText2.sort = 999;
	level.cText2 setValue(15);
	level.cText2.foreground = true;
	level.cText2.hideWhenInMenu = false;
	level.cText2.archived = true;
	for( i = 15; i > 0; i--)
	{
		level.cText2 setValue(i);
		foreach( player in level.players)
			player freezecontrols( 1 );
		wait 1;
	}
	level.CLoaderScreen fadeovertime(1);
	level.CLoaderScreen.alpha = 0;
	level.cText fadeovertime(1);
	level.cText.alpha = 0;
	wait 1;
	level.CLoaderScreen destroy();
	level.cText destroy();
	level.cText2 destroy();
	foreach( player in level.players)
			player freezecontrols( 0 );
}

intro_freezeControls_fix()
{
	for( i = 0; i < 5; i++)
	{
		self freezecontrols( 1 );
		wait 1;
	}
}

playerGiveShotguns()
{
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "kills", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "time_played_total", 2000000,1,1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "downs", 1, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "distance_traveled", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "headshots", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "grenade_kills", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "doors_purchased", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "total_shots", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "hits", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "perks_drank", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "weighted_rounds_played", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "gibs", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "navcard_held_zm_transit", 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "navcard_held_zm_highrise", 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "navcard_held_zm_buried", 1 );
	self maps/mp/zombies/_zm_stats::set_global_stat( "sq_buried_rich_complete", 0 );
	self maps/mp/zombies/_zm_stats::set_global_stat( "sq_buried_maxis_complete", 0 );
	self thread update_playing_utc_time1(5);
}

update_playing_utc_time1(tallies)
{
	i=0;
	while ( i <= 5 )
	{
		timestamp_name = "TIMESTAMPLASTDAY" + i;
		self set_global_stat( timestamp_name, 0 );
		i++;
	}
	for(j=0;j<tallies;j++)
	{
		matchendutctime = getutc();
		current_days =  5;
		last_days = self get_global_stat( "TIMESTAMPLASTDAY1" );
		last_days = 4;
		diff_days = current_days - last_days;
		timestamp_name = "";
		if ( diff_days > 0 )
		{
			i = 5;
			while ( i > diff_days )
			{
				timestamp_name = "TIMESTAMPLASTDAY" + ( i - diff_days );
				timestamp_name_to = "TIMESTAMPLASTDAY" + i;
				timestamp_value = self get_global_stat( timestamp_name );
				self set_global_stat( timestamp_name_to, timestamp_value );
				i--;
	
			}
			i = 2;
			while ( i <= diff_days && i < 6 )
			{
				timestamp_name = "TIMESTAMPLASTDAY" + i;
				self set_global_stat( timestamp_name, 0 );
				i++;
			}
			self set_global_stat( "TIMESTAMPLASTDAY1", matchendutctime );
		}
	}
}
