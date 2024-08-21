#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include user_scripts\mp\HumansZombiesSetup;
#include user_scripts\mp\main;
#include user_scripts\mp\utilities;

CustomMapsEditinit()
{
    level.doCustomMap = 0;
    level.doorwait = 2;
    level.elevator_model["enter"] = "h1_flag_mp_domination_usmc_blue";
    level.elevator_model["exit"] = "h1_flag_mp_domination_usmc_red";
    precacheModel( level.elevator_model["enter"] );
    precacheModel( level.elevator_model["exit"] );
    wait 1;
    if(getDvar("mapname") == "mp_afghan"){ /** Afghan **/
        level thread Afghan();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_boneyard"){ /** Scrapyard **/
        level thread Scrapyard();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_brecourt"){ /** Wasteland **/
        level thread Wasteland();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_checkpoint"){ /** Karachi **/
        level thread Karachi();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_derail"){ /** Derail **/
        level thread Derail();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_estate"){ /** Estate **/
        level thread Estate();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_favela"){ /** Favela **/
        level thread Favela();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_highrise"){ /** HighRise **/
        level thread HighRise();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_nightshift"){ /** Skidrow **/
        level thread Skidrow();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_invasion"){ /** Invasion **/
        level thread Invasion();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_quarry"){ /** Quarry **/
        level thread Quarry();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_rundown"){ /** Rundown **/
        level thread Rundown();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_rust"){ /** Rust **/
        level thread Rust();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_subbase"){ /** SubBase **/
        level thread SubBase();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_terminal"){ /** Terminal **/
        level thread Terminal();
        level.doCustomMap = 1;
    }
    if(getDvar("mapname") == "mp_underpass"){ /** Underpass **/
        level thread Underpass();
        level.doCustomMap = 1;
    }
    if(level.doCustomMap == 1){
        level.gameState = "starting";
        level thread CreateMapWait();
    } else {
        level.gameState = "starting";
        wait 15;
        level notify("CREATED");
    }
}

CreateMapWait()
{
    for(i = 30; i > 0; i--)
    {
        level.TimerText destroy();
        level.TimerText = level createServerFontString( "objective", 1.5 );
        level.TimerText setPoint( "CENTER", "CENTER", 0, -100 );
        level.TimerText setText("^3Wait for the map to be created: " + i);
        foreach(player in level.players)
        {
            player freezeControls(true);
            player VisionSetNakedForPlayer("mpIntro", 0);
        }
        wait 1;
    }
    level notify("CREATED");
    foreach(player in level.players)
    {
        player freezeControls(false);
        player VisionSetNakedForPlayer(getDvar("mapname"), 0);
    }
}

CreateElevator(enter, exit, angle)
{
    flag = spawn( "script_model", enter );
    flag setModel( level.elevator_model["enter"] );
    wait 0.01;
    flag showInMap();
    flag = spawn( "script_model", exit );
    flag setModel( level.elevator_model["exit"] );
    wait 0.01;
    self thread ElevatorThink(enter, exit, angle);
}

CreateHFlag(enter, exit, angle)
{
    flag = spawn( "script_model", enter );
    flag setModel( level.elevator_model["enter"] );
    wait 0.01;
    flag = spawn( "tag_origin", exit );
    flag setModel( level.elevator_model["exit"] );
    wait 0.01;
    self thread ElevatorThink(enter, exit, angle);
}

CreateInvisDoor(open, close, angle, size, height, hp, range)
{   level.fx_airstrike_afterburner = loadfx ("fire/jet_afterburner");
    level.chopper_fx["light"]["belly"] = loadfx( "misc/aircraft_light_red_blink" );
    level.harrier_afterburnerfx = loadfx ("fire/jet_afterburner_harrier");
    offset = (((size / 2) - 0.5) * -1);
    center = spawn("script_model", open );
    for(j = 0; j < size; j++){
        door = spawn("script_model", open + ((0, 30, 0) * offset));
        door setModel(level.spawnGlowModel["enemy"]);
        door Solid();
        door CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        //playfx(level.chopper_fx["light"]["belly"], open + ((0, 30, 0) * offset));
        door EnableLinkTo();
        door LinkTo(center);
        for(h = 1; h < height; h++){
            door = spawn("script_model", open + ((0, 30, 0) * offset) - ((70, 0, 0) * h));
            door setModel(level.spawnGlowModel["enemy"]);
            door Solid();
            door CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
            door EnableLinkTo();
            door LinkTo(center);
            //playfx(level.chopper_fx["light"]["belly"], open + ((0, 30, 0) * offset) - ((70, 0, 0) * h)); 
        }
        offset += 1;
    }
    center.angles = angle;
    center.state = "open";
    center.hp = hp;
    center.range = range;
    center thread IDoorThink(open, close);
    center thread IDoorUse();
    center thread IDCEffect(open, close, angle);
    center thread ResetDoors(open, hp);
    wait 0.01;
}

IDCEffect(open, close, angle)
{   self endon("disconnect");
    //playfx(level.chopper_fx["light"]["belly"], open + (0, 20, 40));
    //playfx(level.chopper_fx["light"]["belly"], open + (0, -20, 40));
    //playfx(level.chopper_fx["light"]["belly"], open + (20, 0, 40));
    //playfx(level.chopper_fx["light"]["belly"], open + (-20, -20, 40));
    while(1)
    {   
        if(self.state == "close")
        {   self playLoopSound("cobra_helicopter_dying_layer");
            fxti = SpawnFx(level.fx_airstrike_afterburner, close + (0,0,25));
            fxti.angles = (270,0,0);
            fxtiii = SpawnFx(level.harrier_afterburnerfx, close );
            fxtiii.angles = (270,0,0);
            TriggerFX(fxti);
            TriggerFX(fxtiii);
            wait .5;
            self stopLoopSound("cobra_helicopter_dying_layer");
            self playLoopSound("emt_road_flare_burn");
            while(self.state == "close")
            {   wait .1;
            }
            self stopLoopSound("emt_road_flare_burn");
            if(self.state == "broken"){
                self playLoopSound("cobra_helicopter_crash");
                wait .5;
            }
            self playLoopSound("cobra_helicopter_dying_layer");
            wait .8;
            self stopLoopSound("cobra_helicopter_dying_layer");
            self stopLoopSound("cobra_helicopter_crash");
            fxti delete();
            fxtiii delete();
        }
        wait 2;
    }
}
IDoorUse()
{
    self endon("disconnect");
    while(1)
    {
        foreach(player in level.players)
        {
            if(Distance(self.origin, player.origin) <= self.range){
                if(player.team == "allies"){
                    if(self.state == "open"){
                        player.hint = "^1[{+melee}] ^7to ^2Activate ^3ForceField";
                    }
                    if(self.state == "close"){
                        player.hint = "^1[{+melee}] to ^2De-Activate ^3ForceField. [{+breath_sprint}] Shows Power Level.";  
                    }
                    if(self.state == "broken"){
                        player.hint = "^1ForceField is Down";
                    }
                }
                if(player.team == "axis"){
                    if(self.state == "close"){
                        player.hint = "^[{+melee}] ^7to ^1Drain ^3the ForceField. [{+breath_sprint}] Shows Power Level.";
                    }
                    if(self.state == "broken"){
                        player.hint = "^1ForceField is Down";
                    }
                }
                if(player.buttonPressed[ "+melee" ] == 1){
                    player.buttonPressed[ "+melee" ] = 0;
                    self notify( "triggeruse" , player);
                }
                if(player.buttonPressed[ "+breath_sprint" ] == 1){
                    player.buttonPressed[ "+breath_sprint" ] = 0;
                    player iPrintlnBold("^3" + self.hp + "^1:Power Left");
                }
            }
        }
        wait .045;
    }
}
IDoorThink(open, close)
{   self.waitz = 1;
    while(1)
    {
        if(self.hp > 0){
            self waittill ( "triggeruse" , player );
            if(player.team == "allies"){
                if(self.state == "open"){
                    self MoveTo(close, self.waitz);
                    wait 1;
                    self.state = "close";
                    continue;
                }
                if(self.state == "close"){
                    self MoveTo(open, self.waitz);
                    wait 1;
                    self.state = "open";
                    continue;
                }
            }
            if(player.team == "axis"){
                if(self.state == "close"){
                    self.hp--;
                    player iPrintlnBold("HIT!");
                    player thread doDoorz();
                    wait 1;
                    continue;
                }
            }
        } else {
            if(self.state == "close"){
                self MoveTo(open, self.waitz);
            }
            self.state = "broken";
            wait .5;
        }
    }
}

doDoorz()
{   self.bounty += 2;
    wait .2;
}

showInMap()
{
    self endon ( "disconnect" ); 
    self endon ( "death" ); 
        curObjID = maps\mp\gametypes\_gameobjects::getNextObjID();  
        name = precacheShader( "compass_waypoint_panic" );  
        objective_add( curObjID, "invisible", (0,0,0) );
        objective_position( curObjID, self.origin );
        objective_state( curObjID, "active" );
        objective_team( curObjID, self.team );
        objective_icon( curObjID, name );
        self.objIdFriendly = curObjID;
}

CreateBlocks(pos, angle)
{
    block = spawn("script_model", pos );
    block setModel("com_plasticcase_friendly");
    block.angles = angle;
    block Solid();
    block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
    wait 0.01;
}

CreateDoors(open, close, angle, size, height, hp, range)
{
    offset = (((size / 2) - 0.5) * -1);
    center = spawn("script_model", open );
    for(j = 0; j < size; j++){
        door = spawn("script_model", open + ((0, 30, 0) * offset));
        door setModel("com_plasticcase_enemy");
        door Solid();
        door CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        door EnableLinkTo();
        door LinkTo(center);
        for(h = 1; h < height; h++){
            door = spawn("script_model", open + ((0, 30, 0) * offset) - ((70, 0, 0) * h));
            door setModel("com_plasticcase_enemy");
            door Solid();
            door CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
            door EnableLinkTo();
            door LinkTo(center);
        }
        offset += 1;
    }
    center.angles = angle;
    center.state = "open";
    center.hp = hp;
    center.range = range;
    center thread DoorThink(open, close);
    center thread DoorUse();
    center thread ResetDoors(open, hp);
    wait 0.01;
}

CreateRamps(top, bottom)
{
    D = Distance(top, bottom);
    blocks = roundUp(D/30);
    CX = top[0] - bottom[0];
    CY = top[1] - bottom[1];
    CZ = top[2] - bottom[2];
    XA = CX/blocks;
    YA = CY/blocks;
    ZA = CZ/blocks;
    CXY = Distance((top[0], top[1], 0), (bottom[0], bottom[1], 0));
    Temp = VectorToAngles(top - bottom);
    BA = (Temp[2], Temp[1] + 90, Temp[0]);
    for(b = 0; b < blocks; b++){
        block = spawn("script_model", (bottom + ((XA, YA, ZA) * b)));
        block setModel("com_plasticcase_friendly");
        block.angles = BA;
        block Solid();
        block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        wait 0.01;
    }
    block = spawn("script_model", (bottom + ((XA, YA, ZA) * blocks) - (0, 0, 5)));
    block setModel("com_plasticcase_friendly");
    block.angles = (BA[0], BA[1], 0);
    block Solid();
    block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
    wait 0.01;
}

CreateIBlock(pos, angle)
{
    block = spawn("script_model", pos );
    block setModel("tag_origin");
    block.angles = angle;
    block Solid();
    block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
    wait 0.01;
}

CreateGrids(corner1, corner2, angle)
{
    W = Distance((corner1[0], 0, 0), (corner2[0], 0, 0));
    L = Distance((0, corner1[1], 0), (0, corner2[1], 0));
    H = Distance((0, 0, corner1[2]), (0, 0, corner2[2]));
    CX = corner2[0] - corner1[0];
    CY = corner2[1] - corner1[1];
    CZ = corner2[2] - corner1[2];
    ROWS = roundUp(W/55);
    COLUMNS = roundUp(L/30);
    HEIGHT = roundUp(H/20);
    XA = CX/ROWS;
    YA = CY/COLUMNS;
    ZA = CZ/HEIGHT;
    center = spawn("script_model", corner1);
    for(r = 0; r <= ROWS; r++){
        for(c = 0; c <= COLUMNS; c++){
            for(h = 0; h <= HEIGHT; h++){
                block = spawn("script_model", (corner1 + (XA * r, YA * c, ZA * h)));
                block setModel("com_plasticcase_friendly");
                block.angles = (0, 0, 0);
                block Solid();
                block LinkTo(center);
                block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
                wait 0.01;
            }
        }
    }
    center.angles = angle;
}

CreateWalls(start, end)
{
    D = Distance((start[0], start[1], 0), (end[0], end[1], 0));
    H = Distance((0, 0, start[2]), (0, 0, end[2]));
    blocks = roundUp(D/55);
    height = roundUp(H/30);
    CX = end[0] - start[0];
    CY = end[1] - start[1];
    CZ = end[2] - start[2];
    XA = (CX/blocks);
    YA = (CY/blocks);
    ZA = (CZ/height);
    TXA = (XA/4);
    TYA = (YA/4);
    Temp = VectorToAngles(end - start);
    Angle = (0, Temp[1], 90);
    for(h = 0; h < height; h++){
        block = spawn("script_model", (start + (TXA, TYA, 10) + ((0, 0, ZA) * h)));
        block setModel("com_plasticcase_friendly");
        block.angles = Angle;
        block Solid();
        block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        wait 0.001;
        for(i = 1; i < blocks; i++){
            block = spawn("script_model", (start + ((XA, YA, 0) * i) + (0, 0, 10) + ((0, 0, ZA) * h)));
            block setModel("com_plasticcase_friendly");
            block.angles = Angle;
            block Solid();
            block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
            wait 0.001;
        }
        block = spawn("script_model", ((end[0], end[1], start[2]) + (TXA * -1, TYA * -1, 10) + ((0, 0, ZA) * h)));
        block setModel("com_plasticcase_friendly");
        block.angles = Angle;
        block Solid();
        block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        wait 0.001;
    }
}

CreateCluster(amount, pos, radius)
{
    for(i = 0; i < amount; i++)
    {
        half = radius / 2;
        power = ((randomInt(radius) - half), (randomInt(radius) - half), 500);
        block = spawn("script_model", pos + (0, 0, 1000) );
        block setModel("com_plasticcase_friendly");
        block.angles = (90, 0, 0);
        block PhysicsLaunchServer((0, 0, 0), power);
        block Solid();
        block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        block thread ResetCluster(pos, radius);
        wait 0.05;
    }
}

ElevatorThink(enter, exit, angle)
{
    self endon("disconnect");
    while(1)
    {
        foreach(player in level.players)
        {
            if(Distance(enter, player.origin) <= 50){
                player SetOrigin(exit);
                player SetPlayerAngles(angle);
            }
        }
        wait .25;
    }
}

DoorThink(open, close)
{
    while(1)
    {
        if(self.hp > 0){
            self waittill ( "triggeruse" , player );
            if(player.team == "allies"){
                if(self.state == "open"){
                    self MoveTo(close, level.doorwait);
                    wait level.doorwait;
                    self.state = "close";
                    continue;
                }
                if(self.state == "close"){
                    self MoveTo(open, level.doorwait);
                    wait level.doorwait;
                    self.state = "open";
                    continue;
                }
            }
            if(player.team == "axis"){
                if(self.state == "close"){
                    self.hp--;
                    player iPrintlnBold("HIT");
                    wait 1;
                    continue;
                }
            }
        } else {
            if(self.state == "close"){
                self MoveTo(open, level.doorwait);
            }
            self.state = "broken";
            wait .5;
        }
    }
}

DoorUse()
{
    self endon("disconnect");
    while(1)
    {
        foreach(player in level.players)
        {
            if(Distance(self.origin, player.origin) <= self.range){
                if(player.team == "allies"){
                    if(self.state == "open"){
                        player.hint = "Press ^3[{+usereload}] ^7to ^2Close ^7the door";
                    }
                    if(self.state == "close"){
                        player.hint = "Press ^3[{+usereload}] ^7to ^2Open ^7the door";
                    }
                    if(self.state == "broken"){
                        player.hint = "^1Door is Broken";
                    }
                }
                if(player.team == "axis"){
                    if(self.state == "close"){
                        player.hint = "Press ^3[{+usereload}] ^7to ^2Attack ^7the door";
                    }
                    if(self.state == "broken"){
                        player.hint = "^1Door is Broken";
                    }
                }
                if(player.buttonPressed[ "+usereload" ] == 1){
                    player.buttonPressed[ "+usereload" ] = 0;
                    self notify( "triggeruse" , player);
                }
            }
        }
        wait .045;
    }
}

ResetDoors(open, hp)
{
    while(1)
    {
        level waittill("RESETDOORS");
        self.hp = hp;
        self MoveTo(open, level.doorwait);
        self.state = "open";
    }
}

ResetCluster(pos, radius)
{
    wait 5;
    self RotateTo(((randomInt(36)*10), (randomInt(36)*10), (randomInt(36)*10)), 1);
    level waittill("RESETCLUSTER");
    self thread CreateCluster(1, pos, radius);
    self delete();
}

roundUp( floatVal )
{
    if ( int( floatVal ) != floatVal )
        return int( floatVal+1 );
    else
        return int( floatVal );
}

CreateTWall(enter, exit, radius)
{
    flag = spawn( "script_model", enter );
    flag setModel("tag_origin");
    wait 0.01;
    self thread TWallAct(enter, exit, radius);
}

TWallAct(enter, exit, radius)
{
    self endon("disconnect");
    while(1)
    {
        foreach(player in level.players)
        {
            if(Distance(enter, player.origin) <= radius){
                player SetOrigin(exit);
                playFX(level.fxex, exit);
                player playsound("mp_war_objective_lost");
            }
        }
        wait .25;
    }
}

CreateIWall(start, end)
{
    D = Distance((start[0], start[1], 0), (end[0], end[1], 0));
    H = Distance((0, 0, start[2]), (0, 0, end[2]));
    blocks = roundUp(D/55);
    height = roundUp(H/30);
    CX = end[0] - start[0];
    CY = end[1] - start[1];
    CZ = end[2] - start[2];
    XA = (CX/blocks);
    YA = (CY/blocks);
    ZA = (CZ/height);
    TXA = (XA/4);
    TYA = (YA/4);
    Temp = VectorToAngles(end - start);
    Angle = (0, Temp[1], 90);
    for(h = 0; h < height; h++){
        block = spawn("script_model", (start + (TXA, TYA, 10) + ((0, 0, ZA) * h)));
        block setModel("tag_origin");
        block.angles = Angle;
        block Solid();
        block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        wait 0.001;
        for(i = 1; i < blocks; i++){
            block = spawn("script_model", (start + ((XA, YA, 0) * i) + (0, 0, 10) + ((0, 0, ZA) * h)));
            block setModel("tag_origin");
            block.angles = Angle;
            block Solid();
            block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
            wait 0.001;
        }
        block = spawn("script_model", ((end[0], end[1], start[2]) + (TXA * -1, TYA * -1, 10) + ((0, 0, ZA) * h)));
        block setModel("tag_origin");
        block.angles = Angle;
        block Solid();
        block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        wait 0.001;
    }
}

CreateFire(pos)
{   Flam = spawn( "script_model", pos );
    Flam setModel("tag_origin");
    angles = (90,90,0);
    if(getDvar("mapname") == "mp_boneyard" || getDvar("mapname") == "mp_checkpoint" || getDvar("mapname") == "mp_compact")
    {
        foreach(fx in level.fxf)
        {   playFX(fx, pos);
        }
    }   else    {   
        Flam thread doAltfire(pos);
    }
    Flam thread FBurn(pos);
    Flam thread FTrig(pos);
}
doAltfire(pos)
{   self endon("disconnect");
    while(1)
    {   foreach(fx in level.fxx)
        {   playFX(fx, pos);
        }
        wait .5;
    }
}
FBurn(pos)
{   self endon("disconnect");
    while(1)
    {   self waittill ( "triggeruse" );
        self playLoopSound( "veh_mig29_dist_loop" );
        RadiusDamage( pos, 70, 15, 10);
        earthquake( 0.4, 0.75, self.origin, 512 );
        wait .4;
        self stopLoopSound( "veh_mig29_dist_loop" );
        continue;
    }
}
FTrig(pos)
{   self endon("disconnect");
    for(;;)
    {
        foreach(player in level.players)
        {   if(Distance(self.origin, player.origin) <= 100)
            {   if(player.team == "axis") self notify( "triggeruse" );
            }
        }
        wait .1;
    }
}

CreateAsc(depart, arivee, angle, time)
{
    Asc = spawn("script_model", depart );
    Asc setModel("com_plasticcase_friendly");
    Asc.angles = angle;
    Asc Solid();
    Asc CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
    
    Asc thread Escalator(depart, arivee, time);
}

Escalator(depart, arivee, time)
{
    while(1)
    {
                if(self.state == "open"){
                    self MoveTo(depart, time);
                    wait (time*1.5);
                    self.state = "close";
                    continue;
                }
                if(self.state == "close"){
                    self MoveTo(arivee, time);
                    wait (time*1.5);
                    self.state = "open";
                    continue;
                }
    }
}

CreateKillIfBelow(z)
{   
    level thread KillBelow(z);
}

KillBelow(z)
{
    for(;;)
    {
        foreach(player in level.players)
        {
            if(player.origin[2] < z){
                RadiusDamage(player.origin,100,999999,999999);
            }
            wait .1;
        }
        wait .15;
    }
}

CreateCircle(depart, pass1, pass2, pass3, pass4, arivee, angle, time)
{
    Asc = spawn("script_model", depart );
    Asc setModel("com_plasticcase_friendly");
    Asc.angles = angle;
    Asc Solid();
    Asc CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
    
    Asc thread Circle(depart, arivee, pass1, pass2, pass3, pass4, time);
}

Circle(depart, pass1, pass2, pass3, pass4, arivee, time)
{
    while(1)
    {
                if(self.state == "open"){
                    self MoveTo(depart, time);
                    wait (time*1.5);
                    self.state = "op";
                    continue;
                }
                if(self.state == "op"){
                    self MoveTo(pass1, time);
                    wait (time);
                    self.state = "opi";
                    continue;
                }
                if(self.state == "opi"){
                    self MoveTo(pass2, time);
                    wait (time);
                    self.state = "opa";
                    continue;
                }
                if(self.state == "opa"){
                    self MoveTo(pass3, time);
                    wait (time);
                    self.state = "ope";
                    continue;
                }
                if(self.state == "ope"){
                    self MoveTo(pass4, time);
                    wait (time);
                    self.state = "close";
                    continue;
                }
                if(self.state == "close"){
                    self MoveTo(arivee, time);
                    wait (time);
                    self.state = "open";
                    continue;
                }
}
}

CreateTurret(pos, angles)
{   
    mgTurret1 = spawnTurret( "misc_turret", pos , "pavelow_minigun_mp" ); 
    mgTurret1 setModel( "weapon_minigun" );
    mgTurret1.angles = (angles);
    mgTurret1 SetLeftArc(360);
    mgTurret1 SetRightArc(360);
    wait 0.1;
    mgTurret1 thread TurMovez(pos);
}

TurMovez(pos)
{   
    self endon("disconnect");
    while(1)
    {   foreach(player in level.players)
        {   if(player.team == "axis")   {
                if(Distance(pos, player.origin) < 65){
                    player SetStance( "prone" );
                    player thread TurBurn();
                }
            }
        }
        wait .1;
    }
}

TurBurn()
{   
    RadiusDamage(self.origin, 40, 40, 15);
}

CreateTruck(depart, pass1, pass2, pass3, pass4, arivee, angle, time)
{
    Truck = spawn("script_model", depart );
    Truck setModel("vehicle_uaz_open_destructible");
    Truck.angles = angle;
    Truck Solid();
    Truck CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
    Truck thread TrUse();
    Truck thread TrStop();
    Truck thread TrReset(depart);
    Truck thread TrMove(depart, pass1, pass2, pass3, pass4, arivee, angle, time);
}

TrMove(depart, pass1, pass2, pass3, pass4, arivee, angle, time)
{   self.statez = "stopped";
    self.state = "op";
    while(1)
    {           if(self.statez == "stopped"){
                    self waittill ( "triggeruse" );
                    self.statez = "moving";
                    wait .5;
                    continue;
                }
                if(self.state == "open"){
                    self MoveTo(depart, time);
                    self thread doTurnz(time);
                    wait (time);
                    self.state = "op";
                    self.statez = "stopped";
                    continue;
                }
                if(self.state == "op"){
                    self MoveTo(pass1, time);
                    self thread doTurnz(time);
                    wait (time);
                    self.state = "opi";
                    continue;
                }
                if(self.state == "opi"){
                    self MoveTo(pass2, time);
                    self thread doTurnz(time);
                    wait (time);
                    self.state = "opa";
                    continue;
                }
                if(self.state == "opa"){
                    self MoveTo(pass3, time);
                    self thread doTurnz(time);
                    wait (time);
                    self.state = "ope";
                    continue;
                }
                if(self.state == "ope"){
                    self MoveTo(pass4, time);
                    self thread doTurnz(time);
                    wait (time);
                    self.state = "close";
                    continue;
                }
                if(self.state == "close"){
                    self MoveTo(arivee, time);
                    self thread doTurnz(time);
                    wait (time);
                    self.state = "open";
                    continue;
                }
    }
}
doTurnz(time)
{   self.counterz = 10;
    while(self.counterz > 0)
    {   self.angles += (0,6,0);
        self.counterz--;
        wait 0.01;
    }
}
TrUse()
{
    self endon("disconnect");
    while(1)
    {
        foreach(player in level.players)
        {
            if(Distance(self.origin, player.origin) <= 70){
                if(player.team == "allies"){
                    if(self.statez == "stopped"){
                        player.hint = "Press ^3[{+breath_sprint}] ^7to ^2Start ^7the Truck Moving";
                    }
                    if(self.statez == "moving"){
                        player.hint = "Press ^3[{+breath_sprint}] ^7to ^2Stop ^7the Truck Moving";
                    }
                    if(player.buttonPressed[ "+breath_sprint" ] == 1){
                    player.buttonPressed[ "+breath_sprint" ] = 0;
                    self notify( "triggeruse" );
                    }
                }
            }
        }
        wait .045;
    }
}
TrStop()
{   while(1)
    {   if(self.statez == "moving")
        {   self waittill ( "triggeruse" );
            self.statez = "stopped";
        }
        wait 1;
    }
}
TrReset(depart)
{
    while(1)
    {
        level waittill("RESETDOORS");
        self SetOrigin(depart);
        self.statez = "stopped";
        self.state = "op";
    }
}

Afghan()
{
    CreateRamps((2280, 1254, 142), (2548, 1168, 33));
    CreateDoors((1590, -238, 160), (1590, -168, 160), (90, 0, 0), 2, 2, 5, 50);
    CreateDoors((1938, -125, 160), (1938, -15, 160), (90, 0, 0), 4, 2, 15, 75);
    CreateDoors((2297, 10, 160), (2297, -100, 160), (90, 0, 0), 4, 2, 10, 75);
    CreateDoors((525, 1845, 162), (585, 1845, 162), (90, 90, 0), 2, 2, 5, 50);
    CreateDoors((-137, 1380, 226), (-137, 1505, 226), (90, 0, 0), 4, 2, 15, 75);
    CreateDoors((820, 1795, 165), (820, 1495, 165), (90, 0, 0), 12, 2, 40, 100);
    CreateDoors((2806, 893, 210), (2806, 806, 210), (90, 0, 0), 3, 2, 10, 50);
}

Derail()
{
    CreateElevator((-110, 2398, 124), (-125, 2263, 333), (0, 270, 0));
    CreateBlocks((-240, 1640, 422), (0, 90, 0));
    CreateBlocks((-270, 1640, 422), (0, 90, 0));
    CreateBlocks((-270, 1585, 422), (0, 90, 0));
    CreateBlocks((-270, 1530, 422), (0, 90, 0));
    CreateBlocks((-270, 1475, 422), (0, 90, 0));
    CreateBlocks((-270, 1420, 422), (0, 90, 0));
    CreateBlocks((-270, 1365, 422), (0, 90, 0));
    CreateBlocks((-270, 1310, 422), (0, 90, 0));
    CreateBlocks((-270, 1255, 422), (0, 90, 0));
    CreateBlocks((-970, 3018, 138), (0, 90, 0));
    CreateBlocks((-985, 3018, 148), (0, 90, 0));
    CreateBlocks((-1000, 3018, 158), (0, 90, 0));
    CreateBlocks((-1015, 3018, 168), (0, 90, 0));
    CreateBlocks((-1030, 3018, 178), (0, 90, 0));
    CreateBlocks((-1045, 3018, 188), (0, 90, 0));
    CreateBlocks((-1060, 3018, 198), (0, 90, 0));
    CreateBlocks((-1075, 3018, 208), (0, 90, 0));
    CreateBlocks((-1090, 3018, 218), (0, 90, 0));
    CreateBlocks((-1105, 3018, 228), (0, 90, 0));
    CreateBlocks((-1120, 3018, 238), (0, 90, 0));
    CreateBlocks((-1135, 3018, 248), (0, 90, 0));
    CreateRamps((-124, 2002, 437), (-124, 2189, 332));
    CreateDoors((400, 1486, 128), (400, 1316, 128), (90, 0, 0), 6, 2, 30, 100);
    CreateDoors((-61, 755, 128), (-161, 755, 128), (90, 90, 0), 3, 2, 20, 75);
}

Estate()
{
CreateElevator((665, 921, 490), (159, 378, 539), (0, 0, 0));
CreateElevator((132, 795, 920), (-1284, 1504, 920), (0, 0, 0));
        CreateBlocks((-371, 919, 245), (0, 100, 90));
        CreateBlocks((-383, 991, 245), (0, 100, 90));
        CreateBlocks((-349, 1115, 245), (0, 50, 90));
        CreateBlocks((-302, 1166, 245), (0, 50, 90));
        CreateBlocks((-55, 1231, 245), (0, -20, 90));
        CreateBlocks((8, 1217, 245), (0, -20, 90));
        CreateBlocks((102, 1188, 245), (0, -20, 90));
        CreateBlocks((162, 1168, 245), (0, -20, 90));
        CreateBlocks((1333, -92, 210), (0, 0, 90));
        CreateBlocks((-336, 739, 705), (0, 100, 90));
        CreateRamps((-344, 768, 710), (-214, 1252, 920));
        CreateGrids((-171, 1266, 920), (106, 830, 920), (0, 0, 0));
        CreateBlocks((-216, 1279, 920), (0, 0, 0));
        CreateDoors((-320, 1002, 840), (-260, 1002, 840), (0, -15, 90), 6, 2, 40, 75);
        CreateDoors((-300, 1148, 910), (-240, 1148, 910), (0, -15, 90), 6, 2, 40, 100);
        CreateElevator((-1230, 1193, -390), (-1543, 3205, 970), (0, -152, 0));
        CreateElevator((-675, 2037, -105), (1181, 2762 ,970), (0, 0, 0));
        CreateRamps((-3500, 3217, 260), (-3122, 3131, -115));
        CreateBlocks((-430, 1026, 940), (0, 100, 90));
        CreateBlocks((-430, 1075, 965), (0, 100, 90));
        CreateElevator((127, 627, 329), (384, 546, 465), (0, 0, 0));
        CreateRamps((-325, 721, 700), (-42, 729, 649));
        CreateRamps((15, 742, 649), (65, 928, 630));
        CreateBlocks((-3213, 1132, -156), (0, 90, 90));
        CreateBlocks((-3213, 1082, -156), (0, 90, 90));
        CreateBlocks((-3213, 1007, -156), (0, 90, 90));
        CreateElevator((-4469, 2689, -289), (1197, 3957, 157), (0, 0, 0));
        CreateElevator((669, 929, 563), (828, 822, 330), (0, 0, 0));
        CreateRamps((-506.143, 1053.75, 976.286), (-403.282, 649.006, 729.349));
        CreateRamps((-403.282, 649.006, 729.349), (5, 540.669, 729.349));
        CreateHFlag((-1923, 3851, 235), (-5, 544, 770), (0, -76, 0));
        CreateBlocks((-1923.3, 3851.14, 220.149), (0, 90, 90));
        CreateAsc((455,813,650), (155,813,920), 0, 5);
}

Favela()
{
CreateWalls((2445, 3065, 280), (2583, 2863, 310));
CreateWalls((2445, 3065, 340), (2583, 2863, 370));
CreateWalls((2130, 2613, 280), (2081, 2712, 310));
CreateWalls((2130, 2613, 340), (2081, 2712, 370));
CreateElevator((880, 2254, 282), (1177, 2402 ,281), (0, 0, 0));
CreateElevator((2404, 2992, 280), (10555.5, 18403.8, 13635.1), (0, 177.408, 0));
CreateInvisDoor((2081, 2712, 300), (2028, 2780, 300), (90,90, 55), 3, 2, 55, 100);
        CreateBlocks((9967.6, 18352.8, 13633.5), (90, 90, 90));
        CreateAsc((10010.5,18404.3,13635.1), (10047.6,18425,13864.9), 0, 5);
        CreateElevator((9386, 18434, 13645), (431, 2040, 1528));
        CreateBlocks((-2315.64, 5495, 350), (90, 90, 90));
        CreateBlocks((-2231.83, 737.505, 110), (90, 90, 90));
CreateElevator((496, 175, 5), (215.916, 2228.5, 281.523)); 
        CreateBlocks((10592.2, 18406, 13675), (90, 90, 90));
        CreateBlocks((10558, 18452, 13675), (90, 90, 90));
        CreateBlocks((10558, 18353.4, 13675), (90, 90, 90));
CreateElevator((2484, 2792, 280), (-184, -715, 72));
CreateTWall((10010,18404,9000), (-1450, 2658, 590), 4000);
        CreateHFlag((-2315, 5404, 307), (591, 1285, 384));
        CreateHFlag((474, 887, 355), (431, 2000, 1528));
    CreateInvisDoor((1481, 913, 220), (1483, 967, 220), (90,90,0), 1, 1, 30, 90);
    CreateHFlag((427, 1238, 459), (1617, 855, 211));
    CreateHFlag((1567, 1085, 211), (431, 2040, 1528));
    CreateInvisDoor((-1530, -591, 75), (-1440, -591, 90), (0,0,0), 1, 1, 30, 100);
        CreateIWall((-1623, -276, 65), (-1708, -515, 125));
        CreateIWall((-1708, -515, 125), (-1529, -585, 65));
        CreateIWall((-1529, -585, 125), (-1351, -926, 5));
        CreateElevator((-1244, -560, 18), (-1255, -669, 13));
        CreateRamps((-1452, -600, 55), (-1423, -765, 0));
    CreateElevator((-1639, -412, 51), (-746, -1735, 50));
    CreateElevator((-410, -1211, 65), (-515, 644, 459));
    CreateFire((-741, -1246, 59));
    CreateIWall((-757, -1576, 68), (-387, -1576, 98));
    CreateIWall((-380, -1374, 80), (-621, -1380, 110));
    CreateIWall((-621, -1380, 110), (-661, -1182, 80));
    CreateIWall((-617, -1785, 120), (-219, -1798, 90));
        CreateElevator((-938, 3145, 295), (-1011, 2967, 300)); 
        CreateIBlock((-836, -1032, 163), (0,90,0));
        CreateBlocks((-332, -1153, 163), (0,90,0));
        CreateIBlock((-836, -1032, 133), (0,90,0));
        CreateBlocks((-302, -1153, 163), (0,90,0));
        CreateTWall((-979, -1244, 220), (-515, 644, 459), 120);
}

HighRise() 
{       CreateRamps((557, 5963, 2956), (74, 5918, 3020)); 
        CreateRamps((273, 6380, 2824), (611, 6417, 2968));
        CreateBlocks((30, 6881, 3048), (0, 0, 0)); 
        CreateBlocks((30, 6881, 3108), (0, 0, 0)); 
        
    CreateElevator((-2308, 6088, 2780), (-2767, 7044, 3066));
    CreateGrids((-2600, 7150, 3225), (-2510, 7360, 3225));
    CreateGrids((-2600, 7150, 3360), (-2510, 7360, 3360));
    CreateWalls((-2480, 7150, 3215), (-2480, 7360, 3274));
    CreateWalls((-2480, 7150, 3310), (-2480, 7360, 3369));
    CreateWalls((-2510, 7150, 3255), (-2600, 7150, 3345));
    CreateWalls((-2510, 7360, 3255), (-2570, 7360, 3345));
    CreateGrids((-2810, 7445, 3225), (-2570, 7470, 3225));
    CreateBlocks((-2600, 7400, 3225), (0, 90, 0));
    CreateBlocks((-2650, 7450, 3245), (0, 90, 0));
    CreateIWall((-5444, 783, 209), (-5471, 845, 269));
}

Invasion()
{
    CreateElevator((-2150, -2366, 268), (-2276, -1353, 573), (0, -90, 0));
    CreateElevator((-1413, -1333, 270), (-1558, -1485, 1064), (0, 0, 0));
    CreateElevator((-607, -984, 293), (-842, -1053, 878), (0, 0, 0));
    CreateGrids((-1400, -1850, 390), (-1359, -1455, 390), (0, 0, 0));
    CreateBlocks((-1468, -1470, 1044), (0, -80, 0));
    CreateBlocks((-1498, -1475, 1044), (0, -80, 0));
    CreateBlocks((-1528, -1480, 1044), (0, -80, 0));
    CreateBlocks((-1558, -1485, 1044), (0, -80, 0));
    CreateBlocks((-1588, -1490, 1044), (0, -80, 0));
    CreateBlocks((-1618, -1495, 1044), (0, -80, 0));
    CreateBlocks((-1648, -1500, 1044), (0, -80, 0));
}

Karachi()
{
    CreateElevator((25, 519, 200), (25, 457, 336), (0, 180, 0));
    CreateElevator((-525, 520, 336), (-522, 783, 336), (0, 0, 0));
    CreateElevator((25, 854, 336), (25, 854, 472), (0, 180, 0));
    CreateElevator((-522, 783, 472), (-525, 520, 472), (0, 0, 0));
    CreateElevator((25, 457, 472), (25, 457, 608), (0, 180, 0));
    CreateElevator((-525, 520, 608), (-522, 783, 608), (0, 0, 0));
    CreateElevator((561, 116, 176), (568, -67, 280), (0, 0, 0));
    CreateBlocks((800, 206, 254), (0, 0, 0));
    CreateBlocks((800, 256, 254), (0, 0, 0));
    CreateBlocks((800, 375, 254), (0, 0, 0));
    CreateBlocks((479, -831, 369), (90, 90, 0));
    CreateBlocks((768, -253, 582), (90, -45, 0));
    CreateBlocks((814, -253, 582), (90, -45, 0));
    CreateBlocks((860, -253, 582), (90, -45, 0));
    CreateBlocks((916, -253, 582), (90, -45, 0));
    CreateBlocks((962, -253, 582), (90, -45, 0));
    CreateBlocks((415, -777, 582), (0, 0, 0));
    CreateBlocks((360, -777, 582), (0, 0, 0));
    CreateBlocks((305, -777, 582), (0, 0, 0));
    CreateBlocks((516, -74, 564), (90, 90, 0));
    CreateBlocks((516, -74, 619), (90, 90, 0));
    CreateRamps((559, -255, 554), (559, -99, 415));
}

Quarry()
{
    CreateBlocks((-5817, -319, -88), (0, 0, 0));
    CreateBlocks((-5817, -289, -108), (0, 0, 0));
    CreateRamps((-3742, -1849, 304), (-3605, -1849, 224));
    CreateRamps((-3428, -1650, 224), (-3188, -1650, 160));
    CreateRamps((-3412, -1800, 416), (-3735, -1800, 304));
    CreateGrids((-3520, -1880, 320), (-3215, -2100, 320), (0, 0, 0));
    CreateGrids((-3100, -1725, 400), (-2740, -1840, 400), (3, 0, 0));
}

Rundown()
{
    CreateDoors((360, -1462, 202), (300, -1342, 202), (90, 25, 0), 3, 2, 10, 75);
    CreateDoors((460, -1420, 206), (400, -1300, 206), (90, 25, 0), 3, 2, 10, 75);
    CreateDoors((30, -1630, 186), (-30, -1510, 186), (90, 25, 0), 4, 2, 15, 75);
    CreateDoors((-280, -1482, 186), (-220, -1602, 186), (90, 25, 0), 4, 2, 15, 75);
    CreateBlocks((385, -1660, 40), (0, 120, 90));
    CreateRamps((-597, -280, 212), (-332, -522, 180));
    CreateRamps((726, -389, 142), (560, -373, 13));
    CreateRamps((2250, -1155, 306), (1905, -876, 200));
    CreateRamps((850, -3125, 312), (535, -3125, 189));
    CreateRamps((1775, 450, 144), (1775, 735, -5));

    CreateRamps((970, -3284, 262), (969, -3145, 309));
    CreateRamps((949, 104, 192), (966, -312, 163));
    CreateRamps((730, -887, 157), (748, -433, 145));
    CreateWalls((965, 377, 214), (725, 384, 274));
    CreateFire((948, -71, 206));
    CreateAsc((1522,-582,350), (947,132,205), 0, 5);
    CreateAsc((1611, -924, 165), (1648, -656, 355), 0, 3);
CreateHFlag((3443, -2396, 203), (-519, -2240, 51));
CreateHFlag((-407, -2417, 69), (-292, -2525, 95));
CreateHFlag((-378, -2513, 88), (3097, -2358, 205));
CreateHFlag((3443, -2396, 203), (-519, -2240, 51));
    CreateTWall((1306, 2273, 184), (-159, -368, 167), 50);
    CreateFire((-200, -400, 187));
    //CreateFire((-249, -411, 187));
    //CreateFire((-179, -439, 187));
CreateKillIfBelow(-250);
CreateWalls((3214, -2024, 220), (2972, -2249, 250));
CreateWalls((3410, -1882, 215), (3610, -1712, 305));
CreateInvisDoor((3248, -1996, 225), (3340, -1900, 225), (0, 305, 0), 4, 1, 50, 90);
CreateGrids((3054, -1261, 320), (3210, -1000, 320));
CreateElevator((3203, -2530, 200), (901, -1493, 110));
CreateElevator((320, -536, 31), (2912, -1348, 171));
CreateElevator((3035, -68, -117), (901, -1493, 110));
CreateElevator((3339, -2250, 200), (3120, -1100, 355));
CreateTWall((3720, -1450, 532), (901, -1493, 110), 100);
CreateIWall((2880, -1206, 156), (3390, -1329, 246));
CreateTWall((4800, 354, 0), (901, -1493, 110), 900);
CreateTruck((-119, 721, 20), (-1209, 88, 120), (-997, -495, 200), (-120, -1179, 250), (554, -789, 200), (357, 732, 120), (0, 180, 0), 2);
}

Rust()
{
    CreateBlocks((773, 1080, 258), (0, 90, 0));
    CreateRamps((745, 1570, 383), (745, 1690, 273));
    CreateDoors((565, 1540, 295), (653, 1540, 295), (90, 90, 0), 3, 2, 15, 60);
    CreateGrids((773, 1135, 258), (533, 1795, 258), (0, 0, 0));
    CreateGrids((695, 1795, 378), (533, 1540, 378), (0, 0, 0));
    CreateGrids((773, 1540, 498), (533, 1795, 498), (0, 0, 0));
    CreateWalls((533, 1795, 278), (773, 1795, 498));
    CreateWalls((790, 1795, 278), (790, 1540, 498));
    CreateWalls((515, 1540, 278), (515, 1795, 498));
    CreateWalls((773, 1540, 278), (715, 1540, 378));
    CreateWalls((590, 1540, 278), (533, 1540, 378));
    CreateWalls((773, 1540, 398), (533, 1540, 428));
    CreateWalls((773, 1540, 458), (740, 1540, 498));
    CreateWalls((566, 1540, 458), (533, 1540, 498));

    CreateAsc((457,125,-265), (457,125,332), 0, 5);
CreateElevator((520,310,362), (1745, 1650, -130), 0);
CreateGrids((420,210,332), (620,410,332), 0);
CreateCircle((512,378,-106), (1421,1100,100), (633,1147,332), (-242,997,400), (470,302,700), (1240,254,-58), 0, 5);
    CreateBlocks((773, 1080, 258), (0, 90, 0));
    CreateRamps((745, 1570, 383), (745, 1690, 273));
    CreateInvisDoor((565, 1540, 330), (653, 1540, 330), (90, 90, 0), 3, 1, 55, 100);
    CreateGrids((773, 1135, 258), (533, 1795, 258), (0, 0, 0));
    CreateGrids((695, 1795, 378), (533, 1540, 378), (0, 0, 0));
    CreateWalls((533, 1795, 278), (773, 1795, 438));
    CreateWalls((790, 1795, 278), (790, 1540, 438));
    CreateWalls((515, 1540, 278), (515, 1795, 438));
    CreateWalls((773, 1540, 278), (715, 1540, 378));
    CreateWalls((590, 1540, 278), (533, 1540, 378));
    CreateWalls((773, 1540, 398), (533, 1540, 428));
    //CreateWalls((773, 1540, 458), (740, 1540, 498));
    //CreateWalls((566, 1540, 458), (533, 1540, 498));
    CreateHFlag((285, 1926, -214), (1745, 1650, -130), (0,180,0), 25);
}

Scrapyard()
{
    CreateElevator((206, -319, -125), (-2810, 884, 1399));
    CreateElevator((-428, 0, 1558), (1943, -614, -116));
    
    CreateRamps((-1330, -86, 135), (-1575, -74, -10));
    CreateFire((-1326, 158, 155));
    CreateDoors((-1480, 767, 108), (-1583, 767, 108), (0, 0, 0), 1, 1, 15, 75);
    CreateRamps((393, 1633, 175), (887, 1619, 156));
    CreateElevator((-876, 1410, -128), (820, 1635, 200));
    CreateFire((413, 1649, 205));
    CreateFire((630, 1644, 195));
    CreateGrids((-1628, 790, 145), (-1713, 312, 145), 0);
    CreateAsc((54, 922, 0), (51, 1173, 185), 0, 3);
    CreateTWall((-2810, 884, 599), (1943, -614, -116), 700);
    CreateTWall((86, -2107, 100), (1943, -614, -116), 1000);
    CreateKillIfBelow(-280);
    CreateElevator((-1820, 1256, -110), (-1614, 927, -119));
    CreateFire((351, 1600, 220));

    //og
    CreateBlocks((420, 1636, 174), (0, 0, 0));
    CreateBlocks((475, 1636, 174), (0, 0, 0));
    CreateBlocks((530, 1636, 174), (0, 0, 0));
    CreateBlocks((585, 1636, 174), (0, 0, 0));
    CreateBlocks((640, 1636, 174), (0, 0, 0));
    CreateBlocks((695, 1636, 174), (0, 0, 0));
    CreateBlocks((750, 1636, 174), (0, 0, 0));
    CreateBlocks((805, 1636, 174), (0, 0, 0));
    CreateBlocks((860, 1636, 174), (0, 0, 0));
    CreateBlocks((420, 1606, 174), (0, 0, 0));
    CreateBlocks((475, 1606, 174), (0, 0, 0));
    CreateBlocks((530, 1606, 174), (0, 0, 0));
    CreateBlocks((585, 1606, 174), (0, 0, 0));
    CreateBlocks((640, 1606, 174), (0, 0, 0));
    CreateBlocks((695, 1606, 174), (0, 0, 0));
    CreateBlocks((750, 1606, 174), (0, 0, 0));
    CreateBlocks((805, 1606, 174), (0, 0, 0));
    CreateBlocks((860, 1606, 174), (0, 0, 0));
    CreateBlocks((420, 1576, 174), (0, 0, 0));
    CreateBlocks((475, 1576, 174), (0, 0, 0));
    CreateBlocks((530, 1576, 174), (0, 0, 0));
    CreateBlocks((585, 1576, 174), (0, 0, 0));
    CreateBlocks((640, 1576, 174), (0, 0, 0));
    CreateBlocks((695, 1576, 174), (0, 0, 0));
    CreateBlocks((750, 1576, 174), (0, 0, 0));
    CreateBlocks((805, 1576, 174), (0, 0, 0));
    CreateBlocks((860, 1576, 174), (0, 0, 0));
    CreateBlocks((-1541, -80, 1), (0, 90, -33.3));
    CreateBlocks((-1517.7, -80, 16.3), (0, 90, -33.3));
    CreateBlocks((-1494.4, -80, 31.6), (0, 90, -33.3));
    CreateBlocks((-1471.1, -80, 46.9), (0, 90, -33.3));
    CreateBlocks((-1447.8, -80, 62.2), (0, 90, -33.3));
    CreateBlocks((-1424.5, -80, 77.5), (0, 90, -33.3));
    CreateBlocks((-1401.2, -80, 92.8), (0, 90, -33.3));
    CreateBlocks((-1377.9, -80, 108.1), (0, 90, -33.3));
    CreateBlocks((-1354.6, -80, 123.4), (0, 90, -33.3));
    CreateElevator((10, 1659, -72), (860, 1606, 194), (0, 180, 0));
    CreateDoors((1992, 266, -130), (1992, 336, -130), (90, 0, 0), 2, 2, 5, 50);
    CreateDoors((1992, 710, -130), (1992, 640, -130), (90, 0, 0), 2, 2, 5, 50);
}

Skidrow()
{
    CreateElevator((-725, -410, 136), (-910, -620, 570), (0, 0, 0));
    CreateRamps((-705, -830, 688), (-495, -830, 608));
    CreateRamps((-580, -445, 608), (-580, -375, 568));
    CreateRamps((1690, 325, 213), (1890, 325, 108));
    CreateGrids((-1540, -1687, 600), (-275, -1687, 660), (0, 0, 0));
    CreateGrids((-1060, -1535, 584), (-470, -1650, 584), (0, 0, 0));
    CreateGrids((-700, -120, 580), (-700, -120, 640), (0, 90, 0));
    CreateGrids((-705, -490, 580), (-705, -770, 580), (-45, 0, 0));
}

SubBase()
{
    CreateBlocks((-1506, 800, 123), (0, 0, 45));
    CreateDoors((-503, -3642, 22), (-313, -3642, 22), (90, 90, 0), 7, 2, 25, 75);
    CreateDoors((-423, -3086, 22), (-293, -3086, 22), (90, 90, 0), 6, 2, 20, 75);
    CreateDoors((-183, -3299, 22), (-393, -3299, 22), (90, 90, 0), 7, 2, 25, 75);
    CreateDoors((1100, -1138, 294), (1100, -1078, 294), (90, 0, 0), 2, 2, 5, 50);
    CreateDoors((331, -1400, 294), (331, -1075, 294), (90, 0, 0), 11, 2, 40, 100);
    CreateDoors((-839, -1249, 278), (-839, -1319, 278), (90, 0, 0), 2, 2, 5, 50);
    CreateDoors((-1428, -1182, 278), (-1498, -1182, 278), (90, 90, 0), 2, 2, 5, 50);
    CreateDoors((-435, -50, 111), (-380, -50, 111), (90, 90, 0), 2, 2, 5, 50);
    CreateDoors((-643, -50, 111), (-708, -50, 111), (90, 90, 0), 2, 2, 5, 50);
    CreateDoors((1178, -438, 102), (1248, -438, 102), (90, 90, 0), 2, 2, 5, 50);
    CreateDoors((1112, -90, 246), (1112, -160, 246), (90, 0, 0), 2, 2, 5, 50);
}

Terminal()
{
    CreateElevator((2859, 4529, 192), (3045, 4480, 250), (0, 0, 0));
    CreateElevator((2975, 4080, 192), (2882, 4289, 55), (0, 180, 0));
    CreateElevator((520, 7375, 192), (-898, 5815, 460), (0, -90, 0));
    CreateElevator((-670, 5860, 460), (1585, 7175, 200), (0, 180, 0));
    CreateElevator((-895, 4300, 392), (-895, 4300, 570), (0, 90, 0));
    CreateWalls((-640, 4910, 390), (-640, 4685, 660));
    CreateWalls((-1155, 4685, 390), (-1155, 4910, 660));
    CreateWalls((-570, 5440, 460), (-640, 4930, 660));
    CreateWalls((-1155, 4930, 460), (-1155, 5945, 660));
    CreateWalls((-1155, 5945, 460), (-910, 5945, 660));
    CreateWalls((-1105, 4665, 392), (-965, 4665, 512));
    CreateWalls((-825, 4665, 392), (-685, 4665, 512));
    CreateWalls((3375, 2715, 195), (3765, 3210, 245));
    CreateWalls((4425, 3580, 195), (4425, 3230, 315));
    CreateWalls((4425, 3580, 380), (4425, 3230, 440));
    CreateWalls((4045, 3615, 382), (3850, 3615, 412));
    CreateWalls((2960, 2800, 379), (3250, 2800, 409));
    CreateDoors((-705, 4665, 412), (-895, 4665, 412), (90, -90, 0), 4, 2, 20, 75);
    CreateDoors((3860, 3305, 212), (3860, 3485, 212), (90, 0, 0), 6, 2, 30, 100);
    CreateRamps((3620, 2415, 369), (4015, 2705, 192));
    CreateGrids((4380, 2330, 360), (4380, 2980, 360), (0, 0, 0));
    CreateBlocks((1635, 2470, 121), (0, 0, 0));
    CreateBlocks((2675, 3470, 207), (90, 0, 0));
}

Underpass()
{
    CreateElevator((-415, 3185, 392), (-1630, 3565, 1035), (0, 180, 0));
    CreateBlocks((1110, 1105, 632), (90, 0, 0));
    CreateBlocks((-2740, 3145, 1100), (90, 0, 0));
    CreateBlocks((2444, 1737, 465), (90, 0, 0));
    CreateWalls((-1100, 3850, 1030), (-1100, 3085, 1160));
    CreateWalls((-2730, 3453, 1030), (-2730, 3155, 1150));
    CreateWalls((-2730, 3155, 1030), (-3330, 3155, 1180));
    CreateWalls((-3330, 3155, 1030), (-3330, 3890, 1180));
    CreateWalls((-3330, 3890, 1030), (-2730, 3890, 1180));
    CreateWalls((-2730, 3890, 1030), (-2730, 3592, 1150));
    CreateWalls((-2730, 3890, 1150), (-2730, 3155, 1180));
    CreateDoors((-2730, 3400, 1052), (-2730, 3522.5, 1052), (90, 180, 0), 4, 2, 20, 75);
    CreateRamps((-3285, 3190, 1125), (-3285, 3353, 1030));
    CreateRamps((-3285, 3855, 1125), (-3285, 3692, 1030));
    CreateGrids((-2770, 3190, 1120), (-3230, 3190, 1120), (0, 0, 0));
    CreateGrids((-2770, 3855, 1120), (-3230, 3855, 1120), (0, 0, 0));
    CreateGrids((-2770, 3220, 1120), (-2770, 3825, 1120), (0, 0, 0));
    CreateCluster(20, (-3030, 3522.5, 1030), 250);

    CreateWalls((-1201, 617, 435), (-1089, 823, 465));
    CreateElevator((618, 255, 380), (-1100, 2666, 494));
    CreateElevator((-3253, 552, 423), (1178, 2280, 253));           
    CreateElevator((3631, 347, 299), (3825, 1111, 395));
    CreateElevator((4608, 671, 656), (540, 1479, 552));
    CreateHFlag((3389, 3394, 395), (531, -1536, 1500));
    CreateElevator((-2886, -392, 2195), (-464, 2078, 369));
    CreateAsc((636, 2529, 507), (621, 2529, 699), 0, 5);
    CreateAsc((-1281, 2000, 415), (-1281, 2000, 675), 0, 5);
    CreateTurret((-1281, 2100, 620), (0, -90, 0));
    CreateBlocks((-1110, 708, 430), (0, 0, 0));
    CreateBlocks((-510, 571, 565), (0, 90, 0));
    CreateRamps((4388, 1903, 628), (4508, 2528, 450));
    CreateWalls((-326, 1229, 363), (-524, 1229, 419));
    CreateElevator((-1616, 2660, 616), (-1685, 1692, 2009));
    CreateRamps((-1223, 2286, 580), (-1050, 2286, 580));
}

Wasteland()
{
    CreateDoors((1344, -778, -33), (1344, -898, -33), (90, 0, 0), 5, 2, 15, 75);
    CreateDoors((684, -695, -16), (684, -825, -16), (90, 0, 0), 5, 2, 15, 75);
    CreateDoors((890, -120, -12), (760, -120, -12), (90, 90, 0), 5, 2, 15, 125);
    CreateDoors((958, -1072, -36), (958, -972, -36), (90, 0, 0), 3, 2, 10, 50);
    CreateDoors((1057, -648, -36), (997, -748, -36), (90, -30, 0), 3, 2, 10, 50);
}

