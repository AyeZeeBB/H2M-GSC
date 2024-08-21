#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include user_scripts\mp\main;
#include user_scripts\mp\CustomMapsEdits;
#include user_scripts\mp\utilities;
#include maps\mp\gametypes\_missions;

doSetup()  
{
    if(self.team == "axis" || self.team == "spectator")
    {
        self.addtoteam = "allies";
        thread maps\mp\gametypes\_playerlogic::spawnclient();
        return;
    }

    //Reset Score And Take Weapons
    self doScoreReset();
    self takeAllWeapons();
    self _clearPerks();
    self ThermalVisionFOFOverlayOff();
    
    //Give Human Weapons
    self.randomlmg = randomInt(5);
    self.randomar = randomInt(9);
    self.randommp = randomInt(4);
    self.randomsmg = randomInt(5);
    self.randomshot = randomInt(6);
    self.randomhand = randomInt(4);
    self giveWeapon(level.smg[self.randomsmg] + "_mp", 0, false);
    self giveWeapon(level.shot[self.randomshot] + "_mp", 0, false);
    self giveWeapon(level.hand[self.randomhand] + "_mp", 0, false);
    self GiveMaxAmmo(level.smg[self.randomsmg] + "_mp");
    self GiveMaxAmmo(level.shot[self.randomshot] + "_mp");
    self GiveMaxAmmo(level.hand[self.randomhand] + "_mp");
    self switchToWeapon(level.smg[self.randomsmg] + "_mp");

    //Give Human Perks
    self maps\mp\_utility::giveperk("specialty_marathon");
    self maps\mp\_utility::giveperk("specialty_automantle");
    self maps\mp\_utility::giveperk("specialty_fastmantle");
    self maps\mp\_utility::giveperk("specialty_falldamage");
    self maps\mp\_utility::giveperk("specialty_heartbreaker");
    self maps\mp\_utility::giveperk("specialty_quieter");
    
    self thread doHW();
    self.isZombie = 0;
    self.bounty   = 0;
    self notify("CASH");
    self.attach1 = [];
    self.attachweapon = [];
    self.attachweapon[0] = 0;
    self.attachweapon[1] = 0;
    self.attachweapon[2] = 0;
    self.attach1[0] = "none";
    self.attach1[1] = "none";
    self.attach1[2] = "none";
    self.currentweapon = 0;
    self thread doPerksSetup();
    self thread doPerkCheck();
    
    self.maxhp = 100;
    self.maxhealth = self.maxhp;
    self.health = self.maxhealth;
    self.moveSpeedScaler = 1;
    self.thermal = 0;
    self.throwingknife = 0;
    self setClientDvar("g_knockback", 1000);
    
    notifySpawn = spawnstruct();
    notifySpawn.titleText = "Human";
    notifySpawn.notifyText = "Survive for as long as possible!";
    notifySpawn.glowColor = (0.0, 0.0, 1.0);
    self thread maps\mp\gametypes\_hud_message::notifyMessage( notifySpawn );
    self thread doHumanBounty();
    self thread doHumanShop();
}

doLastAlive() 
{
    self endon("disconnect");
    self endon("death");

    wait 60;
    
    self thread maps\mp\gametypes\_hud_message::hintMessage("^1The Zombies Got Your Scent. ColdBlooded is off!");

    for(;;)
    {
        self _unsetPerk("specialty_coldblooded");
        self _unsetPerk("specialty_spygame");
        self.perkz["coldblooded"] = 3;
        wait .4;
    }
}

doAlphaZombie()  
{
    if(self.team == "allies")
    {
        self.addtoteam = "axis";
        thread maps\mp\gametypes\_playerlogic::spawnclient();
        self doScoreReset();
        self.bounty = 0;
        self notify("CASH");
        self.ck = self.kills;
        self.cd = self.deaths;
        self.cs = self.suicides;
        self.maxhp = 200;
        self thread doPerksSetup();
        return;
    }
    
    //Give Zombie Knife
    self takeAllWeapons();
    self _clearPerks();
    self giveWeapon("h2_karambit_mp", 0, false);
    self thread doZW();

    //Give Zombie Perks
    self maps\mp\_utility::giveperk("specialty_marathon");
    self maps\mp\_utility::giveperk("specialty_automantle");
    self maps\mp\_utility::giveperk("specialty_fastmantle");
    self maps\mp\_utility::giveperk("specialty_extendedmelee");
    self maps\mp\_utility::giveperk("specialty_falldamage");
    self maps\mp\_utility::giveperk("specialty_thermal");

    //Give Zombie Vision
    if(self.thermal == 1)
        self ThermalVisionFOFOverlayOn();

    //Give Zombie Throwing Knife
    if(self.throwingknife == 1)
    {
        self thread monitorThrowingKnife();
        self maps\mp\_utility::giveperk( "h2_throwingknife_mp" );
        self setWeaponAmmoClip("h2_throwingknife_mp", 1);
    }

    //Check Perks
    self thread doPerkCheck();
    self.maxhealth = self.maxhp;
    self.health = self.maxhealth;
    self.moveSpeedScaler = 1.25;
    self setClientDvar("g_knockback", 3500);
    
    //Notify Zombie
    notifySpawn = spawnstruct();
    notifySpawn.titleText = "^0Alpha Zombie";
    notifySpawn.notifyText = "Kill the Humans!";
    notifySpawn.glowColor = (1.0, 0.0, 0.0);

    self thread maps\mp\gametypes\_hud_message::notifyMessage( notifySpawn );

    self thread doZombieBounty();
    self thread doZombieShop();
}

doZombie() 
{
    if(self.team == "allies")
    {
        self.addtoteam = "axis";
        thread maps\mp\gametypes\_playerlogic::spawnclient();
        self doScoreReset();
        self.bounty = 0;
        self notify("CASH");
        self.ck = self.kills;
        self.cd = self.deaths;
        self.cs = self.suicides;
        self.maxhp = 100;
        self thread doPerksSetup();
        return;
    }

    //Give Zombie Knife
    self takeAllWeapons();
    self _clearPerks();
    self giveWeapon("h2_karambit_mp", 0, false);
    self thread doZW();

    //Give Zombie Perks
    self maps\mp\_utility::giveperk("specialty_marathon");
    self maps\mp\_utility::giveperk("specialty_automantle");
    self maps\mp\_utility::giveperk("specialty_fastmantle");
    self maps\mp\_utility::giveperk("specialty_extendedmelee");
    self maps\mp\_utility::giveperk("specialty_falldamage");
    self maps\mp\_utility::giveperk("specialty_thermal");

    //Give Zombie Vision
    if(self.thermal == 1)
        self ThermalVisionFOFOverlayOn();
    
    //Give Zombie Throwing Knife
    if(self.throwingknife == 1)
    {
        self thread monitorThrowingKnife();
        self maps\mp\_utility::giveperk( "h2_throwingknife_mp" );
        self setWeaponAmmoClip("h2_throwingknife_mp", 1);
    }

    //Check Perks
    self thread doPerkCheck();
    self.maxhealth = self.maxhp;
    self.health = self.maxhealth;
    self.moveSpeedScaler = 1.15;
    self setClientDvar("g_knockback", 3500);
    
    //Notify Zombie
    notifySpawn = spawnstruct();
    notifySpawn.titleText = "^0Zombie";
    notifySpawn.notifyText = "Kill the Humans!";
    notifySpawn.glowColor = (1.0, 0.0, 0.0);

    self thread maps\mp\gametypes\_hud_message::notifyMessage( notifySpawn );

    self thread doZombieBounty();
    self thread doZombieShop();
}

doHW() 
{
    self endon ( "disconnect" );
    self endon ( "death" );
    while(1)
    {
        self.current = self getCurrentWeapon();
        switch(getWeaponClass(self.current))
        {
            case "weapon_lmg":
                self.exTo = "Unavailable";
                self.currentweapon = 0;
                break;
            case "weapon_assault":
                self.exTo = "LMG";
                self.currentweapon = 0;
                break;
            case "weapon_smg":
                self.exTo = "Assault Rifle";
                self.currentweapon = 0;
                break;
            case "weapon_shotgun":
                self.exTo = "Unavailable";
                self.currentweapon = 1;
                break;
            case "weapon_machine_pistol":
                self.exTo = "Unavailable";
                self.currentweapon = 2;
                break;
            case "weapon_pistol":
                self.exTo = "Machine Pistol";
                self.currentweapon = 2;
                break;
            default:
                self.exTo = "Unavailable";
                self.currentweapon = 3;
                break;
        }

        basename = strtok(self.current, "_");

        if(basename.size > 2)
        {
            self.attach1[self.currentweapon] = basename[1];
            self.attachweapon[self.currentweapon] = basename.size - 2;
        } 
        else 
        {
            self.attach1[self.currentweapon] = "none";
            self.attachweapon[self.currentweapon] = 0;
        }

        if(self.currentweapon == 3 || self.attachweapon[self.currentweapon] == 2)
        {
            self.attach["akimbo"] = 0;
            self.attach["fmj"] = 0;
            self.attach["eotech"] = 0;
            self.attach["silencer"] = 0;
            self.attach["xmags"] = 0;
            self.attach["rof"] = 0;
        }

        if((self.attachweapon[self.currentweapon] == 0) || (self.attachweapon[self.currentweapon] == 1))
        {
            akimbo = buildWeaponName(basename[0], self.attach1[self.currentweapon], "akimbo");
            fmj = buildWeaponName(basename[0], self.attach1[self.currentweapon], "fmj");
            eotech = buildWeaponName(basename[0], self.attach1[self.currentweapon], "eotech");
            silencer = buildWeaponName(basename[0], self.attach1[self.currentweapon], "silencer");
            xmags = buildWeaponName(basename[0], self.attach1[self.currentweapon], "xmags");
            rof = buildWeaponName(basename[0], self.attach1[self.currentweapon], "rof");
            
            if(isValidWeapon(akimbo))
                self.attach["akimbo"] = 1;
            else
                self.attach["akimbo"] = 0;
            

            if(isValidWeapon(fmj))
                self.attach["fmj"] = 1;
            else
                self.attach["fmj"] = 0;
            

            if(isValidWeapon(eotech))
                self.attach["eotech"] = 1;
            else
                self.attach["eotech"] = 0;
            

            if(isValidWeapon(silencer))
                self.attach["silencer"] = 1;
            else
                self.attach["silencer"] = 0;
            

            if(isValidWeapon(xmags))
                self.attach["xmags"] = 1;
            else
                self.attach["xmags"] = 0;
            

            if(isValidWeapon(rof))
                self.attach["rof"] = 1;
            else
                self.attach["rof"] = 0;
            
        }
        wait .5;
    }
}

doZW() 
{
    self endon ( "disconnect" );
    self endon ( "death" );
    while(1)
    {
        if(self getCurrentWeapon() == "h2_karambit_mp")
        {
            self setWeaponAmmoClip("h2_karambit_mp", 0);
            self setWeaponAmmoStock("h2_karambit_mp", 0);
        }
        else
        {
            current = self getCurrentWeapon();
            self takeWeapon(current);
            self switchToWeapon("h2_karambit_mp");
        }

        if(self.team == "allies")
            return;
            
        wait .5;
    }
}

doPerkCheck()
{
    self endon ( "disconnect" );
    self endon ( "death" );

    while(1)
    {
        if(self.perkz["steadyaim"] == 1)
            if(!self _hasPerk("specialty_bulletaccuracy"))
                self maps\mp\_utility::giveperk("specialty_bulletaccuracy");

        if(self.perkz["steadyaim"] == 2)
        {
            if(!self _hasPerk("specialty_bulletaccuracy"))
                self maps\mp\_utility::giveperk("specialty_bulletaccuracy");

            if(!self _hasPerk("specialty_holdbreath"))
                self maps\mp\_utility::giveperk("specialty_holdbreath");
        }

        if(self.perkz["sleightofhand"] == 1)
            if(!self _hasPerk("specialty_fastreload"))
                self maps\mp\_utility::giveperk("specialty_fastreload");

        if(self.perkz["sleightofhand"] == 2)
        {
            if(!self _hasPerk("specialty_fastreload"))
                self maps\mp\_utility::giveperk("specialty_fastreload");
            
            if(!self _hasPerk("specialty_quickdraw"))
                self maps\mp\_utility::giveperk("specialty_quickdraw");
            
            if(!self _hasPerk("specialty_fastsnipe"))
                self maps\mp\_utility::giveperk("specialty_fastsnipe");
        }

        if(self.perkz["sitrep"] == 1)
            if(!self _hasPerk("specialty_detectexplosive"))
                self maps\mp\_utility::giveperk("specialty_detectexplosive");

        if(self.perkz["sitrep"] == 2)
        {
            if(!self _hasPerk("specialty_detectexplosive"))
                self maps\mp\_utility::giveperk("specialty_detectexplosive");
            
            if(!self _hasPerk("specialty_selectivehearing"))
                self maps\mp\_utility::giveperk("specialty_selectivehearing");
            
        }

        if(self.perkz["stoppingpower"] == 1)
            if(!self _hasPerk("specialty_bulletdamage"))
                self maps\mp\_utility::giveperk("specialty_bulletdamage");

        if(self.perkz["stoppingpower"] == 2)
        {
            if(!self _hasPerk("specialty_bulletdamage"))
                self maps\mp\_utility::giveperk("specialty_bulletdamage");
            
            if(!self _hasPerk("specialty_armorpiercing"))
                self maps\mp\_utility::giveperk("specialty_armorpiercing");
        }

        if(self.perkz["coldblooded"] == 1)
            if(!self _hasPerk("specialty_coldblooded"))
                self maps\mp\_utility::giveperk("specialty_coldblooded");

        if(self.perkz["coldblooded"] == 2)
        {
            if(!self _hasPerk("specialty_coldblooded"))
                self maps\mp\_utility::giveperk("specialty_coldblooded");
            
            if(!self _hasPerk("specialty_spygame"))
                self maps\mp\_utility::giveperk("specialty_spygame");
            
        }

        if(self.perkz["ninja"] == 1)
            if(!self _hasPerk("specialty_heartbreaker"))
                self maps\mp\_utility::giveperk("specialty_heartbreaker");

        if(self.perkz["ninja"] == 2)
        {
            if(!self _hasPerk("specialty_heartbreaker"))
                self maps\mp\_utility::giveperk("specialty_heartbreaker");
            
            if(!self _hasPerk("specialty_quieter"))
                self maps\mp\_utility::giveperk("specialty_quieter");
            
        }

        if(self.perkz["lightweight"] == 1)
        {
            if(!self _hasPerk("specialty_lightweight"))
                self maps\mp\_utility::giveperk("specialty_lightweight");
            
            self setMoveSpeedScale(1.2);
        }

        if(self.perkz["lightweight"] == 2)
        {
            if(!self _hasPerk("specialty_lightweight"))
                self maps\mp\_utility::giveperk("specialty_lightweight");
            
            if(!self _hasPerk("specialty_fastsprintrecovery"))
                self maps\mp\_utility::giveperk("specialty_fastsprintrecovery");

            self setMoveSpeedScale(1.5);
        }

        if(self.perkz["finalstand"] == 2)
            if(!self _hasPerk("specialty_finalstand"))
                self maps\mp\_utility::giveperk("specialty_finalstand");

        wait 1;
    }
}

monitorThrowingKnife()
{
    self endon("disconnect");
    self endon("death");

    while(1)
    {
        if(self.buttonPressed[ "+frag" ] == 1)
        {
            self.buttonPressed[ "+frag" ] = 0;
            self.throwingknife = 0;
        }
        wait .04;
    }
}

doHumanBounty()
{
    self endon("disconnect");
    self endon("death");
    self.ck = self.kills;
    self.ca = self.assists;

    for(;;)
    {
        if(self.kills - self.ck > 0)
        {
            self.bounty += 50;
            self.ck++;
            self notify("CASH");
        }

        if(self.assists - self.ca > 0)
        {
            self.bounty += 25;
            self.ca++;
            self notify("CASH");
        }

        wait .5;
    }
}

doZombieBounty()
{
    self endon("disconnect");
    self endon("death");

    for(;;)
    {
        if(self.kills - self.ck > 0)
        {
            self.bounty += 100;
            self.ck++;
            self notify("CASH");
        }

        if(self.deaths - self.cd > 0)
        {
            self.bounty += 50;
            self.cd++;
            self notify("CASH");
        }

        if(self.suicides - self.cs > 0)
        {
            self.bounty -= 50;
            self.cs++;
            self notify("CASH");
        }

        wait .5;
    }
}

doHumanShop()
{
    self endon("disconnect");
    self endon("death");

    while(1)
    {
        if(self.buttonPressed[ "+actionslot 3" ] == 1)
        {
            self.buttonPressed[ "+actionslot 3" ] = 0;
            
            if(self.menu == 0)
            {
                if(self.bounty >= level.itemCost["ammo"])
                {
                    self.bounty -= level.itemCost["ammo"];
                    self GiveMaxAmmo(self.current);
                    self notify("CASH");
                } else {
                    self iPrintlnBold("^1Not Enough ^3Cash");
                }
            }

            if(self.menu == 1)
            {
                if(self.attach["akimbo"] == 1)
                {
                    if(self.bounty >= level.itemCost["Akimbo"])
                    {
                        self.bounty -= level.itemCost["Akimbo"];
                        ammo = self GetWeaponAmmoStock(self.current);
                        basename = strtok(self.current, "_");
                        gun = buildWeaponName(basename[0], self.attach1[self.currentweapon], "akimbo");
                        self takeWeapon(self.current);
                        self giveWeapon(gun , 0, true);
                        self SetWeaponAmmoStock( gun, ammo );
                        self switchToWeapon(gun);
                        self thread maps\mp\gametypes\_hud_message::hintMessage("^2Weapon Upgraded!");
                        self notify("CASH");
                    } else {
                        self iPrintlnBold("^1Not Enough ^3Cash");
                    }
                }
            }

            if(self.menu == 2)
            {
                if(self.attach["silencer"] == 1)
                {
                    if(self.bounty >= level.itemCost["Silencer"])
                    {
                        self.bounty -= level.itemCost["Silencer"];
                        ammo = self GetWeaponAmmoStock(self.current);
                        basename = strtok(self.current, "_");
                        gun = buildWeaponName(basename[0], self.attach1[self.currentweapon], "silencer");
                        self takeWeapon(self.current);

                        if(self.attach1[self.currentweapon] == "akimbo")
                            self giveWeapon(gun , 0, true);
                        else
                            self giveWeapon(gun , 0, false);
                        
                        self SetWeaponAmmoStock( gun, ammo );
                        self switchToWeapon(gun);
                        self thread maps\mp\gametypes\_hud_message::hintMessage("^2Weapon Upgraded!");
                        self notify("CASH");
                    } else {
                        self iPrintlnBold("^1Not Enough ^3Cash");
                    }
                }
            }
            if(self.menu == 3)
            {
                switch(self.perkz["steadyaim"])
                {
                    case 0:
                        if(self.bounty >= level.itemCost["SteadyAim"])
                        {
                            self.bounty -= level.itemCost["SteadyAim"];
                            self.perkz["steadyaim"] = 1;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Bought!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    case 1:
                        if(self.bounty >= level.itemCost["SteadyAimPro"])
                        {
                            self.bounty -= level.itemCost["SteadyAimPro"];
                            self.perkz["steadyaim"] = 2;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Upgraded!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    default:
                        break;
                }
            }
            if(self.menu == 4)
            {
                switch(self.perkz["stoppingpower"])
                {
                    case 0:
                        if(self.bounty >= level.itemCost["StoppingPower"])
                        {
                            self.bounty -= level.itemCost["StoppingPower"];
                            self.perkz["stoppingpower"] = 1;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Bought!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    case 1:
                        if(self.bounty >= level.itemCost["StoppingPowerPro"])
                        {
                            self.bounty -= level.itemCost["StoppingPowerPro"];
                            self.perkz["stoppingpower"] = 2;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Upgraded!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    default:
                        break;
                }
            }
            wait .25;
        }
        if(self.buttonPressed[ "+actionslot 4" ] == 1)
        {
            self.buttonPressed[ "+actionslot 4" ] = 0;
            if(self.menu == 0)
                self thread doExchangeWeapons();

            if(self.menu == 1)
            {
                if(self.attach["fmj"] == 1)
                {
                    if(self.bounty >= level.itemCost["FMJ"])
                    {
                        self.bounty -= level.itemCost["FMJ"];
                        ammo = self GetWeaponAmmoStock(self.current);
                        basename = strtok(self.current, "_");
                        gun = buildWeaponName(basename[0], self.attach1[self.currentweapon], "fmj");
                        self takeWeapon(self.current);

                        if(self.attach1[self.currentweapon] == "akimbo")
                            self giveWeapon(gun , 0, true);
                        else
                            self giveWeapon(gun , 0, false);
                        
                        self SetWeaponAmmoStock( gun, ammo );
                        self switchToWeapon(gun);
                        self thread maps\mp\gametypes\_hud_message::hintMessage("^2Weapon Upgraded!");
                        self notify("CASH");
                    } else {
                        self iPrintlnBold("^1Not Enough ^3Cash");
                    }
                }
            }

            if(self.menu == 2)
            {
                if(self.attach["xmags"] == 1)
                {
                    if(self.bounty >= level.itemCost["XMags"])
                    {
                        self.bounty -= level.itemCost["XMags"];
                        ammo = self GetWeaponAmmoStock(self.current);
                        basename = strtok(self.current, "_");
                        gun = buildWeaponName(basename[0], self.attach1[self.currentweapon], "xmags");
                        self takeWeapon(self.current);

                        if(self.attach1[self.currentweapon] == "akimbo")
                            self giveWeapon(gun , 0, true);
                        else
                            self giveWeapon(gun , 0, false);
                        
                        self SetWeaponAmmoStock( gun, ammo );
                        self switchToWeapon(gun);
                        self thread maps\mp\gametypes\_hud_message::hintMessage("^2Weapon Upgraded!");
                        self notify("CASH");
                    } else {
                        self iPrintlnBold("^1Not Enough ^3Cash");
                    }
                }
            }

            if(self.menu == 3)
            {
                switch(self.perkz["sleightofhand"])
                {
                    case 0:
                        if(self.bounty >= level.itemCost["SleightOfHand"])
                        {
                            self.bounty -= level.itemCost["SleightOfHand"];
                            self.perkz["sleightofhand"] = 1;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Bought!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    case 1:
                        if(self.bounty >= level.itemCost["SleightOfHandPro"])
                        {
                            self.bounty -= level.itemCost["SleightOfHandPro"];
                            self.perkz["sleightofhand"] = 2;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Upgraded!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    default:
                        break;
                }
            }

            if(self.menu == 4)
            {
                switch(self.perkz["coldblooded"])
                {
                    case 0:
                        if(self.bounty >= level.itemCost["ColdBlooded"])
                        {
                            self.bounty -= level.itemCost["ColdBlooded"];
                            self.perkz["coldblooded"] = 1;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Bought!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    case 1:
                        if(self.bounty >= level.itemCost["ColdBloodedPro"])
                        {
                            self.bounty -= level.itemCost["ColdBloodedPro"];
                            self.perkz["coldblooded"] = 2;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Upgraded!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    default:
                        break;
                }
            }
            wait .25;
        }
        if(self.buttonPressed[ "+actionslot 2" ] == 1)
        {
            self.buttonPressed[ "+actionslot 2" ] = 0;

            if(self.menu == 0)
            {
                if(self.bounty >= level.itemCost["Riot"])
                {
                    self.bounty -= level.itemCost["Riot"];
                    self giveWeapon("h2_riotshield_mp", 0, false);
                    self switchToWeapon("h2_riotshield_mp");
                    self thread maps\mp\gametypes\_hud_message::hintMessage("^2Riot Shield Bought!");
                    self notify("CASH");
                } else {
                    self iPrintlnBold("^1Not Enough ^3Cash");
                }
            }

            if(self.menu == 1)
            {
                if(self.attach["eotech"] == 1)
                {
                    if(self.bounty >= level.itemCost["Eotech"])
                    {
                        self.bounty -= level.itemCost["Eotech"];
                        ammo = self GetWeaponAmmoStock(self.current);
                        basename = strtok(self.current, "_");
                        gun = buildWeaponName(basename[0], self.attach1[self.currentweapon], "eotech");
                        self takeWeapon(self.current);
                        if(self.attach1[self.currentweapon] == "akimbo"){
                            self giveWeapon(gun , 0, true);
                        } else {
                            self giveWeapon(gun , 0, false);
                        }
                        self SetWeaponAmmoStock( gun, ammo );
                        self switchToWeapon(gun);
                        self thread maps\mp\gametypes\_hud_message::hintMessage("^2Weapon Upgraded!");
                        self notify("CASH");
                    } else {
                        self iPrintlnBold("^1Not Enough ^3Cash");
                    }
                }
            }

            if(self.menu == 2)
            {
                if(self.attach["rof"] == 1)
                {
                    if(self.bounty >= level.itemCost["ROF"])
                    {
                        self.bounty -= level.itemCost["ROF"];
                        ammo = self GetWeaponAmmoStock(self.current);
                        basename = strtok(self.current, "_");
                        gun = buildWeaponName(basename[0], self.attach1[self.currentweapon], "rof");
                        self takeWeapon(self.current);
                        if(self.attach1[self.currentweapon] == "akimbo"){
                            self giveWeapon(gun , 0, true);
                        } else {
                            self giveWeapon(gun , 0, false);
                        }
                        self SetWeaponAmmoStock( gun, ammo );
                        self switchToWeapon(gun);
                        self thread maps\mp\gametypes\_hud_message::hintMessage("^2Weapon Upgraded!");
                        self notify("CASH");
                    } else {
                        self iPrintlnBold("^1Not Enough ^3Cash");
                    }
                }
            }

            if(self.menu == 3)
            {
                switch(self.perkz["sitrep"])
                {
                    case 0:
                        if(self.bounty >= level.itemCost["SitRep"])
                        {
                            self.bounty -= level.itemCost["SitRep"];
                            self.perkz["sitrep"] = 1;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Bought!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    case 1:
                        if(self.bounty >= level.itemCost["SitRepPro"])
                        {
                            self.bounty -= level.itemCost["SitRepPro"];
                            self.perkz["sitrep"] = 2;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Upgraded!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    default:
                        break;
                }
            }
            wait .25;
        }
        wait .04;
    }
}

doZombieShop()
{
    self endon("disconnect");
    self endon("death");
    while(1)
    {
        if(self.buttonPressed[ "+actionslot 3" ] == 1){
            self.buttonPressed[ "+actionslot 3" ] = 0;
            if(self.menu == 0){
                if(self.maxhp != 1000){
                    if(self.bounty >= level.itemCost["health"]){
                        self.bounty -= level.itemCost["health"];
                        self.maxhp += level.itemCost["health"];
                        self.maxhealth = self.maxhp;
                        self thread maps\mp\gametypes\_hud_message::hintMessage("^2 Health Increased!");
                        self notify("CASH");
                    } else {
                        self iPrintlnBold("^1Not Enough ^3Cash");
                    }
                } else {
                    self thread maps\mp\gametypes\_hud_message::hintMessage("^1Max Health Achieved!");
                }
            }
            if(self.menu == 1){
                switch(self.perkz["coldblooded"])
                {
                    case 0:
                        if(self.bounty >= level.itemCost["ColdBlooded"]){
                            self.bounty -= level.itemCost["ColdBlooded"];
                            self.perkz["coldblooded"] = 1;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Bought!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    case 1:
                        if(self.bounty >= level.itemCost["ColdBloodedPro"]){
                            self.bounty -= level.itemCost["ColdBloodedPro"];
                            self.perkz["coldblooded"] = 2;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Upgraded!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    default:
                        break;
                }
            }
            if(self.menu == 2){
                switch(self.perkz["finalstand"])
                {
                    case 0:
                        if(self.bounty >= level.itemCost["FinalStand"]){
                            self.bounty -= level.itemCost["FinalStand"];
                            self.perkz["finalstand"] = 2;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Bought!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    default:
                        break;
                }
            }
            wait .25;
        }
        if(self.buttonPressed[ "+actionslot 4" ] == 1){
            self.buttonPressed[ "+actionslot 4" ] = 0;
            if(self.menu == 0){
                if(self.thermal == 0){
                    if(self.bounty >= level.itemCost["Thermal"]){
                        self.bounty -= level.itemCost["Thermal"];
                        self ThermalVisionFOFOverlayOn();
                        self.thermal = 1;
                        self thread maps\mp\gametypes\_hud_message::hintMessage("^2Thermal Vision Overlay Activated!");
                        self notify("CASH");
                    } else {
                        self iPrintlnBold("^1Not Enough ^3Cash");
                    }
                } else {
                    self thread maps\mp\gametypes\_hud_message::hintMessage("^1Thermal already activated!");
                }
            }
            if(self.menu == 1){
                switch(self.perkz["ninja"])
                {
                    case 0:
                        if(self.bounty >= level.itemCost["Ninja"]){
                            self.bounty -= level.itemCost["Ninja"];
                            self.perkz["ninja"] = 1;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Bought!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    case 1:
                        if(self.bounty >= level.itemCost["NinjaPro"]){
                            self.bounty -= level.itemCost["NinjaPro"];
                            self.perkz["ninja"] = 2;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Upgraded!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    default:
                        break;
                }
            }
            wait .25;
        }
        if(self.buttonPressed[ "+actionslot 2" ] == 1){
            self.buttonPressed[ "+actionslot 2" ] = 0;
            if(self.menu == 0){
                if(self getWeaponAmmoClip("h2_throwingknife_mp") == 0){
                    if(self.bounty >= level.itemCost["ThrowingKnife"]){
                        self.bounty -= level.itemCost["ThrowingKnife"];
                        self thread monitorThrowingKnife();
                        self maps\mp\_utility::giveperk( "h2_throwingknife_mp" );
                        self setWeaponAmmoClip("h2_throwingknife_mp", 1);
                        self.throwingknife = 1;
                        self thread maps\mp\gametypes\_hud_message::hintMessage("^2Throwing Knife Purchased");
                        self notify("CASH");
                    } else {
                        self iPrintlnBold("^1Not Enough ^3Cash");
                    }
                } else {
                    self thread maps\mp\gametypes\_hud_message::hintMessage("^1Throwknife already on hand!");
                }
            }
            if(self.menu == 1){
                switch(self.perkz["lightweight"])
                {
                    case 0:
                        if(self.bounty >= level.itemCost["Lightweight"]){
                            self.bounty -= level.itemCost["Lightweight"];
                            self.perkz["lightweight"] = 1;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Bought!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    case 1:
                        if(self.bounty >= level.itemCost["LightweightPro"]){
                            self.bounty -= level.itemCost["LightweightPro"];
                            self.perkz["lightweight"] = 2;
                            self thread maps\mp\gametypes\_hud_message::hintMessage("^2Perk Upgraded!");
                            self notify("CASH");
                        } else {
                            self iPrintlnBold("^1Not Enough ^3Cash");
                        }
                        break;
                    default:
                        break;
                }
            }
            wait .25;
        }
        wait .04;
    }
}

doExchangeWeapons()
{
    switch(self.exTo)
    {
        case "LMG":
            if(self.bounty >= level.itemCost["LMG"]){
                self.bounty -= level.itemCost["LMG"];
                self takeWeapon(self.current);
                self giveWeapon(level.lmg[self.randomlmg] + "_mp", 0, false);
                self GiveStartAmmo(level.lmg[self.randomlmg] + "_mp");
                self switchToWeapon(level.lmg[self.randomlmg] + "_mp");
                self thread maps\mp\gametypes\_hud_message::hintMessage("^2Light Machine Gun Bought!");
                self notify("CASH");
            } else {
                self iPrintlnBold("^1Not Enough ^3Cash");
            }
            break;
        case "Assault Rifle":
            if(self.bounty >= level.itemCost["Assault Rifle"]){
                self.bounty -= level.itemCost["Assault Rifle"];
                self takeWeapon(self.current);
                self giveWeapon(level.assault[self.randomar] + "_mp", 0, false);
                self GiveStartAmmo(level.assault[self.randomar] + "_mp");
                self switchToWeapon(level.assault[self.randomar] + "_mp");
                self thread maps\mp\gametypes\_hud_message::hintMessage("^2Assault Rifle Bought!");
                self notify("CASH");
            } else {
                self iPrintlnBold("^1Not Enough ^3Cash");
            }
            break;
        case "Machine Pistol":
            if(self.bounty >= level.itemCost["Machine Pistol"]){
                self.bounty -= level.itemCost["Machine Pistol"];
                self takeWeapon(self.current);
                self giveWeapon(level.machine[self.randommp] + "_mp", 0, false);
                self GiveStartAmmo(level.machine[self.randommp] + "_mp");
                self switchToWeapon(level.machine[self.randommp] + "_mp");
                self thread maps\mp\gametypes\_hud_message::hintMessage("^2Machine Pistol Bought!");
                self notify("CASH");
            } else {
                self iPrintlnBold("^1Not Enough ^3Cash");
            }
            break;
        default:
            break;
    }
}

buildWeaponName( baseName, attachment1, attachment2 )
{
    if ( !isDefined( level.letterToNumber ) ){
        level.letterToNumber = makeLettersToNumbers();
    }
    
    if ( getDvarInt ( "scr_game_perks" ) == 0 )
    {
        attachment2 = "none";

        if ( baseName == "onemanarmy" ){
            return ( "beretta_mp" );
        }
    }

    weaponName = baseName;
    attachments = [];

    if ( attachment1 != "none" && attachment2 != "none" )
    {
        if ( level.letterToNumber[attachment1[0]] < level.letterToNumber[attachment2[0]] )
        {
            
            attachments[0] = attachment1;
            attachments[1] = attachment2;
            
        }
        else if ( level.letterToNumber[attachment1[0]] == level.letterToNumber[attachment2[0]] )
        {
            if ( level.letterToNumber[attachment1[1]] < level.letterToNumber[attachment2[1]] )
            {
                attachments[0] = attachment1;
                attachments[1] = attachment2;
            }
            else
            {
                attachments[0] = attachment2;
                attachments[1] = attachment1;
            }   
        }
        else
        {
            attachments[0] = attachment2;
            attachments[1] = attachment1;
        }       
    }
    else if ( attachment1 != "none" )
    {
        attachments[0] = attachment1;
    }
    else if ( attachment2 != "none" )
    {
        attachments[0] = attachment2;   
    }
    
    foreach ( attachment in attachments )
    {
        weaponName += "_" + attachment;
    }

    return ( weaponName + "_mp" );
}

makeLettersToNumbers()
{
    array = [];
    
    array["a"] = 0;
    array["b"] = 1;
    array["c"] = 2;
    array["d"] = 3;
    array["e"] = 4;
    array["f"] = 5;
    array["g"] = 6;
    array["h"] = 7;
    array["i"] = 8;
    array["j"] = 9;
    array["k"] = 10;
    array["l"] = 11;
    array["m"] = 12;
    array["n"] = 13;
    array["o"] = 14;
    array["p"] = 15;
    array["q"] = 16;
    array["r"] = 17;
    array["s"] = 18;
    array["t"] = 19;
    array["u"] = 20;
    array["v"] = 21;
    array["w"] = 22;
    array["x"] = 23;
    array["y"] = 24;
    array["z"] = 25;
    
    return array;
}

isValidWeapon( refString )
{
    if ( !isDefined( level.weaponRefs ) )
    {
        level.weaponRefs = [];

        foreach ( weaponRef in level.weaponList ){
            level.weaponRefs[ weaponRef ] = true;
        }
    }

    if ( isDefined( level.weaponRefs[ refString ] ) ){
        return true;
    }

    return false;
}
