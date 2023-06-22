createShader(shader, align, relative, x, y, width, height, color, alpha, sort)
{
    hud = newClientHudElem(self);
    hud.elemtype = "icon";
    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
	hud setParent(level.uiParent);
    hud setShader(shader, width, height);
	hud setPoint(align, relative, x, y);
	hud.hideWhenInMenu = true;
	hud.archived = false;
    return hud;
}

drawShader(shader, x, y, width, height, color, alpha, sort, allclients)
{
	hud = undefined;
	if( isDefined( allclients ) )
		hud = newHudElem();
	else
   		hud = newClientHudElem(self);
    hud.elemtype = "icon";
    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
    hud setParent(level.uiParent);
    hud setShader(shader, width, height);
    hud.x = x;
    hud.y = y;
	hud.hideWhenInMenu = true;
	hud.archived = false;
    return hud;
}

drawText(text, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort)
{
	hud = self createFontString(font, fontScale);
    hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud setText(text);
	if(text == "SInitialization")
		hud.foreground = true;
	hud.hideWhenInMenu = true;
	hud.archived = false;
	return hud;
}

drawText2(text, font, fontScale, x, y, color, alpha, glowColor, glowAlpha, sort, allclients)
{
	if (!isDefined(allclients))
		allclients = false;
	if (!allclients)
		hud = self createFontString(font, fontScale);
	else
		hud = level createServerFontString(font, fontScale);
    hud setText(text);
    hud.x = x;
	hud.y = y;
	hud.color = color;
	hud.foreground = true;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	return hud;
}

drawSVT(text, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort)
{
	hud = createServerFontString(font, fontScale);
    hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud setText(text);
	if(text == "SInitialization")
		hud.foreground = true;
	hud.hideWhenInMenu = true;
	hud.archived = false;
	return hud;
}

sSetText( svar )
{
	self SetText( svar );
	if(level.SENTINEL_CURRENT_OVERFLOW_COUNTER > level.SENTINEL_MIN_OVERFLOW_THRESHOLD)
	{
		level notify( "SENTINEL_OVERFLOW_BEGIN_WATCH" );
	}
}

drawValue(value, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort)
{
	hud = createServerFontString(font, fontScale);
    hud setPoint( align, relative, x, y );
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud setValue(value);
	hud.foreground = true;
	hud.hideWhenInMenu = true;
	return hud;
}

ZMiniMap()
{
	self thread z_killstreaks();
	self.minimap = self createShader("menu_zm_popup", "CENTER", "TOP", -300, 85, 170, 170, (1,1,1), .75, 1);
	self.playershaders = [];
	self createShader("ui_sliderbutt_1", "CENTER", "TOP", -300, 75, 7, 17, (0,1,0), .9, 2);
	foreach( player in level.players)
	{
		if( player == self )
			continue;
		self.playershaders[ player.name ] = self createShader("ui_sliderbutt_1", "CENTER", "TOP", -300, 75, 7, 17, (1,0,0), .8, 2);
	}
	while( 1 )
	{
		foreach( player in level.players )
		{
			if( player == self )
				continue;
			self.playershaders[ player.name ] updateMMPos( self getOrigin(), player getOrigin(), self getplayerangles() );
			self.playershaders[ player.name ] thread PingShader();
		}
		wait 1;
	}
}
 
updateMMPos( center, offset, angles )
{
	d = offset - center;
	d0 = Distance( offset, center );
	x = cos( angles[1] - ATan2( d[1], d[0] ) + 90 ) * d0;
	y = sin( angles[1] - ATan2( d[1], d[0] ) + 90 ) * d0;
	offx = x / 1500;
	if( offx > 1 )
		offx = 1;
	else if( offx < -1 )
		offx = -1;
	offy = y / 1500;
	if( offy > 1 )
		offy = 1;
	else if( offy < -1 )
		offy = -1;
	self.x = -300 + offx * 75;
	self.y = 75 + offy * 75;
}

ATan2( y, x )
{
	if( x > 0 )
		return ATan( y / x );
	if( x < 0 && y >= 0 )
		return ATan( y / x ) + 180;
	if( x < 0 && y < 0 )
		return ATan( y / x ) - 180;
	if( x == 0 && y > 0 )
		return 90;
	if( x == 0 && y < 0 )
		return -90;
	return 0;
}

PingShader()
{
	self.alpha = 1;
	self fadeovertime( .8 );
	self.alpha = 0;
}

onDisconnectMipMapFix()
{
	level endon("end_game");
	self waittill("disconnect");
	wait 1.5;
	foreach( player in level.players )
		player.playershaders[ self.name ] destroy();
}

z_killstreaks()
{
	self.kill_streaks = [];
	self.kill_streaks[0] = spawnstruct();
	self.kill_streaks[0].bg = self createShader("menu_zm_popup", "CENTER", "TOP", -352.5, 182.5, 45, 45, (1,1,1), .75, 1);
	self.kill_streaks[1] = spawnstruct();
	self.kill_streaks[1].bg = self createShader("menu_zm_popup", "CENTER", "TOP", -300, 182.5, 45, 45, (1,1,1), .75, 1);
	self.kill_streaks[2] = spawnstruct();
	self.kill_streaks[2].bg = self createShader("menu_zm_popup", "CENTER", "TOP", -247.5, 182.5, 45, 45, (1,1,1), .75, 1);
	self.kill_streaks[0].active = false;
	self.kill_streaks[1].active = false;
	self.kill_streaks[2].active = false;
	self.kill_streaks[0].activeText = self drawText("Raygun MII", "default", 1.0, "CENTER", "TOP", -352.5, 182.5, (0,1,0), 0, (1,1,1), 0, 2);
	self.kill_streaks[1].activeText = self drawText("Start Pistol", "default", 1.0, "CENTER", "TOP", -300, 182.5, (0,1,0), 0, (1,1,1), 0, 2);
	self.kill_streaks[2].activeText = self drawText("Ammo", "default", 1.0, "CENTER", "TOP", -247.5, 182.5, (0,1,0), 0, (1,1,1), 0, 2);
	self.ks_index = -1;
	self thread KS_BUTTON_MONITOR();
	self thread OnSpawnedIndexReset();
	while( 1 )
	{
		self waittill_any("5_ks_achieved", "spawned_player");
		if( self.kill_streak < 5 )
			continue;
		self iprintlnbold("^25 Killstreak! Press [{+actionslot 2}] for a Raygun MarkII!");
		self ActivateKillstreakNumber( 0 );
		self waittill_any("10_ks_achieved", "spawned_player");
		if( self.kill_streak < 10 )
			continue;
		self iprintlnbold("^210 Killstreak! Press [{+actionslot 2}] for Upgraded Start Pistol");
		self ActivateKillstreakNumber( 1 );
		self waittill_any("20_ks_achieved", "spawned_player");
		if( self.kill_streak < 15 )
			continue;
		self iprintlnbold("^220 Killstreak! Press [{+actionslot 2}] for Unlimited Ammo");
		self ActivateKillstreakNumber( 2 );
		self waittill_any("25_ks_achieved", "spawned_player");
		if( self.kill_streak < 25 )
			continue;
		self iprintlnbold("^1 Tactical Nuke Ready... Press [{+actionslot 2}] to call in!");
		self thread TacNukeMonitor();
	}
}

KS_BUTTON_MONITOR()
{
	while( 1 )
	{
		wait .05;
		if( self actionslottwobuttonpressed() )
		{
			if( self.ks_index > -1 )
			{
				if( self.kill_streaks[ self.ks_index ].active )
				{
					self.kill_streaks[ self.ks_index ].active = false;
					self.kill_streaks[ self.ks_index ].activeText.alpha = 0;
					self.kill_streaks[ self.ks_index ].bg.color = (1, 1, 1 );
					self playlocalsound( level.zombie_sounds[ "purchase" ] );
					self thread Give_Z_KS( self.ks_index );
					for( i = 2; i > -2; i--)
					{
						if( i == -1 )
							self.ks_index = i;
						else if( self.kill_streaks[ index ].active )
						{
							self.ks_index = i;
							break;
						}
					}
				}
			}
			while( self actionslottwobuttonpressed() )
				wait .05;
		}
		if( self actionslotthreebuttonpressed() )
		{
			if(self.ks_index == -1)
				continue;
			if( self.ks_index != -1)
			{
				if( self.kill_streaks[ self.ks_index ].active )
					self.kill_streaks[ self.ks_index ].bg.color = (.15,.15,0);
				else
					self.kill_streaks[ self.ks_index ].bg.color = (1,1,1);
			}
			for( i = self.ks_index - 1; i > -2; i--)
			{
				if( i == -1 )
					break;
				else if( self.kill_streaks[ index ].active )
				{
					self.ks_index = i;
					break;
				}
			}
			if( self.ks_index != -1)
				self.kill_streaks[ self.ks_index ].bg.color = (1,1,0);
			while( self actionslotthreebuttonpressed() )
				wait .05;
		}
		if( self actionslotfourbuttonpressed() )
		{
			if(self.ks_index == -1)
				continue;
			if( self.ks_index != -1)
			{
				if( self.kill_streaks[ self.ks_index ].active )
					self.kill_streaks[ self.ks_index ].bg.color = (1,1,0);
				else
					self.kill_streaks[ self.ks_index ].bg.color = (1,1,1);
			}
			for( i = self.ks_index + 1; i < 3; i++)
			{
				if( self.kill_streaks[ index ].active )
				{
					self.ks_index = i;
					break;
				}
			}
			if( self.ks_index != -1)
				self.kill_streaks[ self.ks_index ].bg.color = (1,1,0);
			while( self actionslotfourbuttonpressed() )
				wait .05;
		}
	}
}

ActivateKillstreakNumber( index )
{
	if( self.ks_index != -1)
	{
		if( self.kill_streaks[ self.ks_index ].active )
			self.kill_streaks[ self.ks_index ].bg.color = (.15,.15,0);
		else
			self.kill_streaks[ self.ks_index ].bg.color = (1,1,1);
	}
	self.kill_streaks[ index ].active = true;
	self.ks_index = index;
	self.kill_streaks[ index ].bg.color = (.15, .15, 0 );
	self.kill_streaks[ index ].activeText.alpha = 1;
	if( self.ks_index != -1)
		self.kill_streaks[ self.ks_index ].bg.color = (1,1,0);
}

OnSpawnedIndexReset()
{
	while( 1 )
	{
		self waittill("spawned_player");
		if( self.ks_index != -1)
		{
			if( self.kill_streaks[ self.ks_index ].active )
				self.kill_streaks[ self.ks_index ].bg.color = (.15,.15,0);
			else
				self.kill_streaks[ self.ks_index ].bg.color = (1,1,1);
		}
		self.ks_index = -1;
		for( i = 0; i < 3; i++)
		{
			if( self.kill_streaks[ i ].active )
			{
				self.ks_index = i;
				break;
			}
		}
		if( self.ks_index != -1)
			self.kill_streaks[ self.ks_index ].bg.color = (1,1,0);
	}
}

TacNukeMonitor()
{
	while( !self actionslottwobuttonpressed() )
		wait .05;
	ent = spawn( "script_origin", self.origin );
	ent playsound( "zmb_dog_round_start" );
	for( i = 10; i > 0; i--)
	{
		foreach( player in level.players )
			player iprintlnbold("^1TACTICAL NUKE IN "+i);
		wait 1;
	}
	level thread maps/mp/zombies/_zm_powerups::specific_powerup_drop( "nuke", self.origin );
	level.nukeActive = self.name;
	foreach( player in level.players )
		player dodamage( 9999, player getorigin() );
	wait 1;
	level.nukeActive = undefined;
	self maps/mp/zombies/_zm_score::add_to_player_score( 100000 );
}

Give_Z_KS( ks )
{
	if( ks == 0)
	{
		self giveweapon("raygun_mark2_zm");
		self switchtoweapon("raygun_mark2_zm");
	}
	if( ks == 1 )
	{
		self giveweapon( level.laststandpistol );
		weap = maps/mp/zombies/_zm_weapons::get_base_name( level.laststandpistol );
		weapon = get_upgrade( weap );
		if ( isDefined( weapon ) )
		{
			self takeweapon( weap );
			self giveweapon( weapon, 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
			self givestartammo( weapon );
			self switchtoweapon( weapon );
		}
	}
	if( ks == 2 )
	{
		self thread AmmoForLife();
	}
}

get_upgrade( weaponname )
{

	if ( isDefined( level.zombie_weapons[ weaponname ] ) && isDefined( level.zombie_weapons[ weaponname ].upgrade_name ) )
	{
		return maps/mp/zombies/_zm_weapons::get_upgrade_weapon( weaponname, 0 );
	}
	else
	{
		return maps/mp/zombies/_zm_weapons::get_upgrade_weapon( weaponname, 1 );
	}
}

AmmoForLife()
{
	self endon("spawned_player");
	while( 1 )
	{
		weapon = self getcurrentweapon();
		if(weapon != "none")
		{
			self setWeaponAmmoClip(weapon, weaponClipSize(weapon));
			self giveMaxAmmo(weapon);
		}
		if(self getCurrentOffHand() != "none")
			self giveMaxAmmo(self getCurrentOffHand());
		self waittill_any("weapon_fired", "grenade_fire", "missile_fire");
	}
}



