pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--update
--[[
 initial setup and main update
 function
 
 poke(0x5f2d, 1) -> enables mouse
 stat(32) -> x coord
 stat(33) -> y coord
 stat(34) -> button bitmask
]]

//cursor vars and lists
pos={}
mouse={}
border={}
cross_pos={}

//bullet vars and lists
shoot={}
bullets={}

//alien list
aliens={}

//button list
buttons={}

//level list
l={}

//holds buy values for upgrades
buy={}

//holds weapon vars
p={}
ar={}
sg={}

//holds stars in background
stars={}

function _init()
 setup()
end

function setup()
 //sets up scenes
 //1=logo
 //2=splash
 //3=game
 //4=upgrades
 //5=end screen
 scene=1
 
 //checks for change to upgrade
 //menu
 up=false
 
 
 //enables mouse
	poke(0x5f2d, 1)
	
	//dimensions for player sprite
	w=12
	h=12
	
	//sets player position
	pos.x=64-8
	pos.y=64-8
	
	//sets mouse position used for
	//rotating player
	mouse.x=64-8
	mouse.y=64-8
	
	//sets mouse position used for
	//for drawing cursor
	cross_pos.x=0
	cross_pos.y=0
	
	//angle from player to cursor
	a=0
	
	//vars to handle shooting anim
	shoot.sprite=1
	shoot.shot=false
	shoot.semi=true
	--[[
	1: pistol
	2: shotgun
	3: asault rifle
	-]]
	shoot.class=1
	//amount of shotgun pellets
	shoot.pel=4
	
	//bullet speed
	bspeed=4
	
	//alien speed
	aspeed=0.5
	
	//gun damage
	damage=50
	
	//enemy spawn vars
	round=0
	enemies=0
	cur_enemies=0
	sp_timer=0
	sp_t=30
	max_enemies=24
	next_round=false
	
	//ship anim timer
	shipa=0
	
	//player's points
	points=0
	kills=0
	
	//player health,regen,armor
	hp=1000
	mhp=1000
	regen=0
	armor=0
	timer=0
	
	//checks the upgrade screen
	screen=1
	
	//checks to see if buttons have
	//printed
	but=false
	
	//gun's and powerup's draw vars
	gy=2
	py=2
	anim_timer=0
	
	//button click check
	cc=false
 
	
	//level vars
	l.r=0
	l.h=0
	l.a=0
	
	//sets buy values for upgrades
	buy.sg=false
	buy.ar=false
	buy.arp=10000
	buy.sgp=3000
	buy.r=500
	buy.h=500
	buy.a=500
	
	//sets weapon vars
	p.d=100
	p.v=1
	p.dl=1
	p.dc=1500
	p.vl=1
	p.vc=500
	
	ar.d=100
	ar.v=1
	ar.dl=1
	ar.dc=4000
	ar.vl=1
	ar.vc=4000
	
	sg.d=100
	sg.v=1
	sg.dl=1
	sg.dc=5000
	sg.vl=1
	sg.vc=5000
	
	//camera x
	camx=0
	
	//buy error vars
	error=false
	maxed=false
	eanim=0
	
	//x pressed down check
	xd=false
	
	//amount of stars
	snum=0
	
	//timer delay until round starts
 delay=90
 
 //sfx vars
 splashm=0
 mainm=0
 shopm=0
 overm=0
end


function _update()
 if snum<15 then
  snum+=1
  star()
 end

 //updates all stars
 for s in all(stars) do
  s:update()
 end
	
 if scene == 1 then
  map(120,0)
  logo()
  
 elseif scene == 2 then
  splash_mus()
  if not btn(❎) then
	  xd=false
	 end
	 
  splash_update()
  
 elseif scene == 3 then
  
  if cur_enemies>0 and  timer>=30 then
   hp+=regen
   timer=0
  end
  
  if hp>mhp then
   hp=mhp
  end
  
  timer+=1
  
  if shoot.class==1 or shoot.class==2 then
   shoot.semi=true
  else
   shoot.semi=false
  end
  
  speed()
  gun_damage()
  
  gun_swap()
  
  if stat(34)==0 then
	  cc=false
	 end
  
  if hp <= 0 then
   music(-1)
   sfx(6)
   scene=5
  end
  
	 //updates mouses position on
	 //player grid
	 mouse.x=stat(32) - pos.x
	 mouse.y=stat(33) - pos.y
	
	 //finds the player's angle of 
	 //rotation
	 a=atan2(mouse.x,mouse.y) * -360
	 a+=-90
	
	
	 //sets the camera to keep the
	 //player in the center
	 cam_x=pos.x-56
	 cam_y=pos.y-56
	 camera(cam_x, cam_y)
	 
	 if delay <= 0 then
	  spawn()
	 else
	  delay-=1
	 end
	 
	 //updates all bullets
	 for b in all(bullets) do
	  b:update(shoot.class)
	 end
	 
	 //updates all spawned aliens
	 for a in all(aliens) do
	  a:update()
	 end
	 
	 //checks bullet hits
	 hit_detection()
	 
	 //checks for alien player
	 //collision
	 attacking()
	 
	elseif scene == 4 then
		//updates mouses position on
	 //player grid
	 mouse.x=stat(32) - pos.x
	 mouse.y=stat(33) - pos.y
	 
	 if (stat(34)==1 and cc==false) then
	  cc=true
	  click(cross_pos.x,cross_pos.y)
	 end
	 
	 if stat(34)==0 then
	  cc=false
	 end
	 
	 if but==false then
		 //prints buttons
		 //1 for buy button
		 //2 for upgrade button
		 //3 for screen button
		 //power up buttons
		 button(1,16,39)
		 button(1,56,98)
		 button(1,96,39)
		 
		 //gun buttons
		 //pistol
		 button(1,2+128,24)
		 button(1,2+128,44)
		 
		 //shotgun
		 if buy.sg==false then
		  button(2,96+128,24)
		 else
		  for b in all (buttons) do
		  	if b.px==96+128 and b.py==24 then
		  	 del(buttons, b)
		  	end
		  end
		  button(1,68+128,24)
		 	button(1,68+128,44)
		 end
		 
		 //asault rifle
		 if buy.ar==false then
		  button(2,56+128,80)
		 else
		  for b in all (buttons) do
		  	if b.px==56+128 then
		  	 del(buttons, b)
		  	end
		  end
		  button(1,36+128,80)
		 	button(1,36+128,100)
		 end
		 
		 //arrow buttons
		 button(3,112,113)
		 button(4,128,113)
		 
		 but=true
	 end
	 
	 if btn(❎) then
	  sfx(5)
	  screen=1
	  scene=3
	  up=false
	 end
	else
	 if btn(❎) then
	  music(-1)
	  sfx(5)
	  scene=2
	  xd=true
	 end
	end
end

function gun_swap()
	if stat(34)==2 and cc==false then
  cc=true
  if buy.sg==true and buy.ar==true then
   shoot.class+=1
   if shoot.class>3 then
    shoot.class=1
   end
   
  elseif buy.sg==true and buy.ar==false then
   shoot.class+=1
   if shoot.class>2 then
    shoot.class=1
   end
   
  elseif buy.sg==false and buy.ar==true then
   shoot.class+=2
   if shoot.class>3 then
    shoot.class=1
   end
  end
 end
end
-->8
--draw
--[[
 drawing
]]

function _draw()
 //clears screen
	cls()
	palt()
	
 if scene == 1 then
  logo()
 elseif scene == 2 then
  //draws map
		map(0,0)
		
		palt()
	 palt(14,true)
	 palt(0,false)
	
	 //draws map
		map(0,0)
		
		//updates all stars
	 for s in all(stars) do
	  s:draw()
	 end
		
		//draws ship
		spr(32,40,40,6,6)
		
		if shipa <= 5 then
			spr(162,72,72,2,2)
		else
		 if shipa > 10 then
		  shipa = 0
		 end
			spr(164,72,72,2,2)
		end
		
	 shipa+=1
	 
  splash_draw()
 elseif scene == 3 then
	 //makes pink transparent
	 //and black not transparent
	 palt()
	 palt(14,true)
	 palt(0,false)
	
	 //draws map
		map(0,0)
		
		//updates all stars
	 for s in all(stars) do
	  s:draw()
	 end
		
		//draws ship
		spr(32,40,40,6,6)
		
		if shipa <= 5 then
			spr(162,72,72,2,2)
		else
		 if shipa > 10 then
		  shipa = 0
		 end
			spr(164,72,72,2,2)
		end
		
	 shipa+=1
		
	 //handles shooting
	 bam()
		
	 //draws all bullets to screen
	 for b in all(bullets) do
	  b:draw(shoot.class)
	 end
	 
	 
	 //draws sprite with rotation
	 //also handles shooting anim
	 if(shoot.sprite==1)
	 then
	  //idle sprite
	  spr_r(1,pos.x,pos.y,a,2,2,14)
	 else
	  //shooting sprite
	  spr_r(3,pos.x,pos.y,a,2,2,14)
	  
	  if shoot.class==2 then
	  	//creates multiple bullets
	  	//for shotgun
	  	for i=1, shoot.pel do
		  	bullet()
		  end
		  sfx(15)
	  else
	   if shoot.class==1 then
	    sfx(12)
	   else
	    sfx(13)
	   end
		  //creates bullet
		  bullet()
		 end
	 end
	 
	 //draws aliens
	 for a in all(aliens) do
	  a:draw()
	 end
	 
	 palt(14,true)
	 //draws the player's cursor
	 crosshair()
	 palt()
	 
	 //prints round number
	 print("round: ",2,2,0)
	 print(round,26,2,8)
	 
	 //prints player health
	 print("hp: ",52,88,0)
	 print(hp,64,88,11)
	 
	 //prints player points
	 print("points:$",2,122,9)
	 print(points,34,122,9)
	 if points>=32000 then
	  print("(max)",56,122,9)
	 end
	 
	 spr(12,110,2,2,2)
	 spr(46,110,18,2,2)
	 spr(14,110,34,2,2)
	 
	 if shoot.class==1 then
	  spr(110,110,2,2,2)
	 elseif shoot.class==2 then
	  spr(110,110,18,2,2)
	 else
	  spr(110,110,34,2,2)
	 end
	 
	 if buy.sg==false then
	  spr(128,110,18,2,2)
	 end
	 
	 if buy.ar==false then
	  spr(128,110,34,2,2)
	 end
	 
	 print("rmb to",84,2,0)
	 print("swap",88,8,0)
	 
	 if next_round==true then
	  music(-1)
	  splash_mus()
	  //next round message
	  print("press ❎",6,54,8)
	  print("to go to",6,61,8)
	  print("next round",3,68,8)
	  
	  //upgrade message
	  print("press 🅾️",88,54,8)
	  print("to purchase",82,61,8)
	  print("upgrades",88,68,8)
	 end
	elseif scene == 4 then
		//draws map
	 map(30,10)
	 
	 //updates all stars
	 for s in all(stars) do
	  s:draw()
	 end
	 
		//sets camera at start of 
		//upgrade menu
		if up==false then
		 camx=0
		 up=true
		end
	 
	 //controls camera
	 cam(screen)
		
  image_float()
		
		//plus
		palt(14,true)
	 palt(0,false)
		//draws aliens
	 for b in all(buttons) do
	  b:draw()
	 end
		palt()
		
		palt(14,true)
		pal(8,1)
	 //draws the player's cursor
	 crosshair()
	 palt()
	 pal()
	else
	 //draws map
	 map(112,0)
	 
	 //draws all stars
	 for s in all(stars) do
	  s:draw()
	 end
	 
	 print("game over!",44,20,8)
	 print("reached round",38,30,8)
	 print(round,62,40,8)
	 
	 print("total",38,57,1)
  print("kills",38,65,1)
  print(kills,66,65,0)
  print("points",36,73,1)
  if kills>0 then
   print(kills.."00",66,73,9)
  else
   print(kills,66,73,9)
  end
	
	 print("press ❎ to continue",24,100,1)
	end
end

//rotates sprite with given 
//angle
function spr_r(s,x,y,a,w,h,tc)
 sw=(w or 1)*8
 sh=(h or 1)*8
 sx=(s%8)*8
 sy=flr(s/8)*8
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 a=a/360
 sa=sin(a)
 ca=cos(a)
 for ix=0,sw-1 do
  for iy=0,sh-1 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 
   and xx<sw 
   and yy>=0 
   and yy<=sh) 
   then
    if sget(sx+xx,sy+yy) != tc 
    then
     pset(x+ix,y+iy,sget(sx+xx,sy+yy))
    end
   end
  end
 end
end


//draws images with floating anim
function image_float()
 //moves sprites to make them
 //look like they float
	if anim_timer==6 then
	 gy+=1
	 py+=1
	elseif anim_timer==12 then
	 gy+=1
	 py+=1
	elseif anim_timer==18 then
	 gy-=1
	 py-=1
	elseif anim_timer==24 then
	 gy-=1
	 py-=1
	else
	 if anim_timer>=32 then
	  anim_timer=0
	 end
	end
	
	anim_timer+=1

	//available points
	print("your points:$",2,2,9)
	print(points,54,2,9)
	
	print("upgrade menu",79,2,8)
	
	//go back
	print("❎:go back",2,121,8)

 //powerups
 //regen upgrade
	spr(40,16,py+20,2,2)
	print("health",13,10,11)
	print("regen",15,16,11)
	
	if l.r<5 then
	 print("lvl: ",14,54,0)
	 print(l.r,30,54,0)
		print("$",14,60,9)
		print(buy.r,18,60,9)
	else
	 print("lvl:max",10,54,0)
	end
	
	//armor upgrade
	spr(44,96,py+20,2,2)
	print("less damage",83,10,11)
	print("taken",95,16,11)
	if l.a<5 then
		print("lvl: ",95,54,0)
		print(l.a,111,54,0)
		print("$",95,60,9)
	 print(buy.a,99,60,9)
	else
	 print("lvl:max",90,54,0)
	end
	
	//health upgrade
	spr(42,56,py+79,2,2)
	print("max",59,70,11)
	print("health",53,76,11)
	if l.h<5 then
		print("lvl: ",54,44+69,0)
		print(l.h,70,44+69,0)
		print("$",54,50+69,9)
		print(buy.h,58,50+69,9)
	else
	 print("lvl:max",50,44+69,0)
	end
	
	//weapons
	//pistol
	spr(12,16+128,gy+9,2,2)
	print("pistol",14+128,9,11)
	print("damage",17+128,29,11)
	if p.dl<5 then
		print("lvl:",5+128,38,0)
		print(p.dl,21+128,38,0)
		print("$",34+128,38,9)
		print(p.dc,38+128,38,9)
	else
	 print("lvl:max",5+128,38,0)
	end
	
	print("velocity",17+128,49,11)
	if p.vl<5 then
		print("lvl:",5+128,58,0)
		print(p.vl,21+128,58,0)
		print("$",34+128,58,9)
		print(p.vc,38+128,58,9)
	else
	 print("lvl:max",5+128,58,0)
	end
	
	//shotgun
	spr(46,96+128,gy+9,2,2)
	print("shotgun",91+128,9,11)
	if buy.sg==false then
	 print("$",92+128,38,9)
	 print(buy.sgp,96+128,38,9)
	else
	 print("damage",83+128,29,11)
	 if sg.dl<5 then
			print("lvl:",71+128,38,0)
			print(sg.dl,87+128,38,0)
			print("$",100+128,38,9)
			print(sg.dc,104+128,38,9)
		else
		 print("lvl:max",71+128,38,0)
		end
		
		print("velocity",83+128,49,11)
		if sg.vl<5 then
			print("lvl:",71+128,58,0)
			print(sg.vl,87+128,58,0)
			print("$",100+128,58,9)
			print(sg.vc,104+128,58,9)
		else
		 print("lvl:max",71+128,58,0)
		end
	end
	
	//asault rifle
	spr(14,56+128,gy+65,2,2)
	print("asault rifle",42+128,65,11)
	if buy.ar==false then
	 print("$",52+128,94,9)
	 print(buy.arp,56+128,94,9)
	else
	 print("damage",51+128,85,11)
	 if ar.dl<5 then
			print("lvl:",39+128,94,0)
			print(ar.dl,55+128,94,0)
			print("$",68+128,94,9)
			print(ar.dc,72+128,94,9)
		else
		 print("lvl:max",39+128,94,0)
		end
			
		print("velocity",51+128,105,11)
		if ar.vl<5 then
			print("lvl:",39+128,114,0)
			print(ar.vl,55+128,114,0)
			print("$",68+128,114,9)
			print(ar.vc,72+128,114,9)
		else
		 print("lvl:max",39+128,114,0)
		end
	end
	
	print("your points:$",2+128,2,9)
	print(points,54+128,2,9)
	
	print("weapon menu",83+128,2,8)
	
	//go back
	print("❎:go back",87+128,121,8)

 if error==true and eanim < 30 then
  print("not enough",46,40,8)
  print("points",54,46,8)
  
  print("not enough",46+128,14,8)
  print("points",54+128,20,8)
  eanim+=1
 else
  error=false
 end
 
 if maxed==true and eanim < 30 then
  print("already",50,40,8)
  print("maxed out",46,46,8)
  
  print("already",50+128,14,8)
  print("maxed out",46+128,20,8)
  eanim+=1
 else
  maxed=false
 end
 
 if error==false and maxed==false then
  eanim=0
 end
end


function cam(s)
 if s==1 then
 	if camx>0 then
   camx-=8
  end
 else
  if camx<128 then
   camx+=8
  end
 end
 
 camera(camx,0)
end
-->8
--logo/splash
timer=0
middle=true
fcount=0
function logo()
 local cx = 54
 local cy = 45
 
 if timer<=10 and middle then
  spr(74,cx,cy,2,2)
  timer+=1
 elseif timer<20 and middle then
  spr(76,cx,cy,2,2)
  timer+=1
 elseif timer<30 and middle then
  spr(78,cx,cy,2,2)
  timer+=1
 else
  spr(76,cx,cy,2,2)
  middle=false
  if timer <= 20 then
   timer=0
   middle=true
  end
  timer-=1
 end
 

 if(fcount > 60) then
  print("galactic",47,cy+20,8)
 end
 if(fcount > 120) then
  print("games",53,cy+26,13)
 end
 
 if(fcount >= 240) then
  scene+=1
  
 end
 fcount+=1
end


function splash_draw()
	print("press ❎ to start",32,95,1)
 palt(0,true)
 spr(192,34,10,8,4)
 palt()
end

function splash_update()
	 if btn(❎) and xd==false then
	  
	  splash_mus_end()
	  sfx(5)
	  music(0)
	  
	  setup()
	  for a in all(aliens) do
			 del(aliens,a)
			end
	  scene=3
	 end
end
-->8
--cursor
--[[
 crosshair(cursor) drawing and
 handling
]]

//draws the cursor and
//checks cursor's borders
function crosshair()
 //cursor's position used for
 //drawing
 if screen==1 then
  cross_pos.x=stat(32)+4
	 cross_pos.y=stat(33)+4
	else
	 cross_pos.x=stat(32)+4+128
	 cross_pos.y=stat(33)+4
	end
	
	//sets the right border bool
 if (mouse.x >= 59) 
 then
  border.r=true
 else
  border.r=false
 end
 
 //sets the left border bool
 if (mouse.x <= -59) 
 then
  border.l=true
 else
  border.l=false
 end
 
 //sets the top border bool
 if (mouse.y <= -59) 
 then
  border.u=true
 else
  border.u=false
 end
 
 //sets the bottom border bool
 if (mouse.y >= 59) 
 then
  border.d=true
 else
  border.d=false
 end
 
 //draws the cursor only inside
 //the borders of the screen,
 //by using the set border bools
 
 //checks right border collision
 if (border.r) 
 then
  if(border.u) 
  then
   if screen==1 then
    spr(0,pos.x+64,pos.y-56)
   else
    spr(0,pos.x+64+128,pos.y-56)
   end
  elseif(border.d) 
  then
   if screen==1 then
    spr(0,pos.x+64,pos.y+64)
   else
    spr(0,pos.x+64+128,pos.y+64)
   end
  else
   if screen==1 then
    spr(0,pos.x+64,cross_pos.y)
   else
    spr(0,pos.x+64+128,cross_pos.y)
   end
  end

 //checks left border collision 
 elseif(border.l) 
 then
  if(border.u) 
  then
   if screen==1 then
    spr(0,pos.x-56,pos.y-56)
   else
    spr(0,pos.x-56+128,pos.y-56)
   end
  elseif(border.d) 
  then
   if screen==1 then
    spr(0,pos.x-56,pos.y+64)
   else
    spr(0,pos.x-56+128,pos.y+64)
   end
  else
  	if screen==1 then
    spr(0,pos.x-56,cross_pos.y)
   else
    spr(0,pos.x-56+128,cross_pos.y)
   end
  end

 //checks top border collision
 elseif (border.u) 
 then
  spr(0,cross_pos.x,pos.y-56)

 //checks bottom border collision
 elseif (border.d) 
 then
  spr(0,cross_pos.x,pos.y+64)
 
 //no cursor collision with borders
 else
  spr(0,cross_pos.x,cross_pos.y)
 end
 
 //resets broder bool values
 border.r=false
 border.l=false
 border.u=false
 border.d=false
end

-->8
--shooting
--[[
 weapon firing
]]

//handles shooting event
function bam()
 if (stat(34)==1)
 then
  if (shoot.semi)
  then
   semi_a()
  else
	  full_a()
  end
 else
  shoot.shot=false
  shoot.sprite=1
 end
end

//handles shooting anim for semi
//auto weapons
function semi_a()
 if (shoot.shot==false)
 then
  shoot.sprite=2
  shoot.shot=true
 else
  shoot.sprite=1
 end
end

//handles shooting anim for full
//auto weapons
function full_a()
 shoot.sprite +=1
	if shoot.sprite > 2
	then
	 shoot.sprite=1
 end
end
-->8
--bullets
--[[
 handles projectiles
]]


//bullet object
function bullet()
 add(bullets,{
  x=pos.x+4,
  y=pos.y+4,
  ogx=pos.x+4,
  ogy=pos.x+4,
  damage=damage,
  w=4,
  h=4,
  
  mya=atan2(mouse.x, mouse.y),
  ba=(a+90)*-1,
  
  spawned=false,
  
  draw=function(self, class)
   if class==2 then
    spr_r(31,self.x,self.y,self.ba*-1,1,1,14)
   else
    spr_r(5,self.x,self.y,self.ba*-1,1,1,0)
   end
  end,
  
  update=function(self, class)
   if self.spawned==false then
	  	if class==1 then
		   self.mya-=rnd(.02)
		   self.mya+=rnd(.02)
		  end
		  
		  if class==2 then
		   self.mya-=rnd(.1)
		   self.mya+=rnd(.1)
		  end
		  
		  if class==3 then
		   self.mya-=rnd(.04)
		   self.mya+=rnd(.04)
		  end
		  
		  self.spawned=true
		 end
	  
  	dx=cos(self.mya)*bspeed
  	dy=sin(self.mya)*bspeed
   
   self.x+=dx
   self.y+=dy
   
   if self.x>self.ogx+68
   or self.x<self.ogx+-68
   or self.y>self.ogy+68
   or self.y<self.ogx+-68
   then
    del(bullets,self)
   end
  end
 })
end


//function that checks for
//bullet collision with aliens
function hit_detection()
 for b in all(bullets) do
  for a in all(aliens) do
   if
		 (a.x > b.x+b.w) 
			or
			(a.x+a.w < b.x) 
			or
			(a.y > b.y+b.h) 
			or
			(a.y+a.h < b.y) 
			then
			else
			 del(bullets,b)
				a.health-=b.damage
				a.hurt=true
			end
  end
 end
end


function speed()
 if shoot.class==1 then
  if p.vl==1 then
   bspeed=4
  elseif p.vl==2 then
   bspeed=6
  elseif p.vl==3 then
   bspeed=9
  elseif p.vl==4 then
   bspeed=12
  else
   bspeed=16
  end
  
 elseif shoot.class==2 then
  if ar.vl==1 then
   bspeed=4
  elseif ar.vl==2 then
   bspeed=6
  elseif ar.vl==3 then
   bspeed=9
  elseif ar.vl==4 then
   bspeed=13
  else
   bspeed=18
  end
  
 else
  if sg.vl==1 then
   bspeed=4
  elseif sg.vl==2 then
   bspeed=5
  elseif sg.vl==3 then
   bspeed=7
  elseif sg.vl==4 then
   bspeed=10
  else
   bspeed=14
  end
 end
end


function gun_damage()
 if shoot.class==1 then
  if p.dl==1 then
   damage=250
  elseif p.dl==2 then
   damage=500
  elseif p.dl==3 then
   damage=700
  elseif p.dl==4 then
   damage=1000
  else
   damage=1300
  end
  
 elseif shoot.class==2 then
  if ar.dl==1 then
   damage=350
  elseif ar.dl==2 then
   damage=500
  elseif ar.dl==3 then
   damage=680
  elseif ar.dl==4 then
   damage=760
  else
   damage=950
  end
  
 else
  if sg.dl==1 then
   damage=300
  elseif sg.dl==2 then
   damage=450
  elseif sg.dl==3 then
   damage=600
  elseif sg.dl==4 then
   damage=750
  else
   damage=800
  end
 end
end
-->8
--aliens
--[[
 handles enemy aliens
]]

//alien object
function alien()
 add(aliens,{
  x=pos.x,
  y=pos.y,
  spawned=false,
  e_ang=0,
  health=0,
  w=8,
  h=11,
  anim_speed=6,
  attack_speed=20,
  anim_timer=0,
  hurt=false,
  hurt_speed=2,
  hurt_timer=0,
  attacking=false,
  
  draw=function(self)
   pal()
   palt(14,true)
   palt(0,false)
   if (self.spawned==true) then
    if (self.hurt) then
     sfx(14)
     pal(3,8)
     pal(2,8)
    	self.hurt=false;
    end
			
				if (self.attacking) then
					if self.anim_timer<self.attack_speed then
	     spr(10,self.x,self.y,2,2)
	     if self.anim_timer==0 then
	      hp-=(100-armor)
	      sfx(11)
	     end
	     self.anim_timer+=1
	    else
	     spr(8,self.x,self.y,2,2)
	     self.anim_timer+=1
	    end
				else
	    if self.anim_timer<self.anim_speed then
	     spr(6,self.x,self.y,2,2)
	     self.anim_timer+=1     
	    else
	     spr(8,self.x,self.y,2,2)
	     self.anim_timer+=1
	    end
	   end
    
    if self.anim_timer>self.anim_speed*2 then
     if self.attacking then 
      if self.anim_timer>self.attack_speed*2 then
       self.anim_timer=0
      end
     else
      self.anim_timer=0
     end
    end
   end
   pal()
  end,
  
  update=function(self)
   self:spawn(self)
   
   if(self.health > 0) then
	   dx=-cos(self.e_ang)*aspeed
	   dy=-sin(self.e_ang)*aspeed
	   
	   if (self.attacking==false) then
	   	self.x+=dx
	   	self.y+=dy
	   end
	  else
	   del(aliens, self)
	   cur_enemies-=1
	   points+=100
	   kills+=1
	   
	   if points>32000 then
	    points=32000
	   end
   end
  end,
  
  spawn=function(self)
   if self.spawned==false then
    check=true
    side=flr(rnd(5))+0
    num=side
    
    if (side==1) then
     self.y=-16
     self.x=-16+rnd(144)
    elseif (side==2) then
     self.x=144
     self.y=-16+rnd(144)
    elseif (side==3) then
     self.y=144
     self.x=-16+rnd(144)
    else
     self.x=-16
     self.y=-16+rnd(144)
    end
    
    //gets the angle of the enemy
    //in reference to the player
    self.e_ang=atan2(self.x-60, self.y-60)
    
    self.health=round*200
    
    self.spawned=true
   end
  end,
 })
end


//randomly spawns aliens
function spawn()
 //spawns aliens based on round
 if enemies<=0 then
  //checks to see if any enemies
  //are still alive
  if cur_enemies <= 0 then
   if round==0 then
    sp_t=30
		  round+=1
		  aspeed+=0.05
		  enemies=sqrt(round)*15
		 else
		  next_round=true
		  if btn(❎) then
		   splash_mus_end()
		   music(0)
		   sfx(5)
		   delay=90
		   sp_t-=1
			  round+=1
			  enemies=sqrt(round)*15
			  next_round=false
		  end
		  if btn(🅾️) then
		   splash_mus_end()
		   sfx(5)
		   music(5)
			  scene=4
			  next_round=false
		  end
		 end
  end
 end
 
 if delay <= 0 then
	 if cur_enemies < max_enemies then
		 if sp_timer<=0 and enemies > 0 then
		  sp_timer=sp_t
		  cur_enemies+=1
		  alien()
			 enemies-=1
		 else
		  sp_timer-=1
		 end
	 end
 end
end


function attacking()
 for a in all(aliens) do
  if
	 (a.x+2 > pos.x+w+2) 
		or
		(a.x+a.w+2 < pos.x+2) 
		or
		(a.y > pos.y+h) 
		or
		(a.y+a.h+2 < pos.y) 
		then
		else
		 if a.attacking==false then
		  hp-=(100-armor)
		  sfx(11)
		 end
		 a.attacking=true
		end
 end
end
-->8
--button
--[[
 handles upgrade screen buttons
]]

function button(t,px,py)
	add(buttons,{
		typ=t,
		px=px,
		py=py,
		w=12,
		h=11,
		anim=0,
		clicked=false,
		
		draw=function(self)
		 if self.clicked==false then
			 if (self.typ==1) then
			  spr(70,self.px,self.py,2,2)
			 elseif (self.typ==2) then
			  if  self.px==224
			  and self.py==24
			  and buy.sg==false
			  then
				  spr(102,self.px,self.py,2,2)
				 	self.w=16
				  self.h=10
			  end
			  
			  if  self.px==184 
			  and self.py==80
			  and buy.ar==false
			  then
				  spr(102,self.px,self.py,2,2)
				 	self.w=16
				  self.h=10
			  end
			 elseif (self.typ==3) then
			  spr(106,self.px,self.py,2,2)
			 elseif (self.typ==4) then
			  spr(106,self.px,self.py,2,2,true)
			 end
		 else
		 	if (self.typ==1) then
			  spr(72,self.px,self.py,2,2)
			 elseif (self.typ==2) then
			  spr(104,self.px,self.py,2,2)
			 elseif (self.typ==3) then
			  spr(108,self.px,self.py,2,2)
			 	if self.anim>0 then
			 	 screen+=1
			 	end
			 elseif (self.typ==4) then
			  spr(108,self.px,self.py,2,2,true)
		 		if self.anim>0 then
			 	 screen-=1
			 	end
		 	end
		 end
		 
		 if self.clicked==true then
		  if self.anim<1 then
		   self.anim+=1
		  else
		   self.anim=0
		   self.clicked=false
		  end
		 end
		end
	})
end


function click(x,y)
	 for b in all(buttons) do
	  if
		 (x > b.px+b.w)
			or
			(x+2 < b.px) 
			or
			(y > b.py+b.h) 
			or
			(y+2 < b.py) 
			then
			else
				b.clicked=true
				upgrade(b.px,b.py)
			end
	 end
end


function upgrade(x,y)
 if x==16 and y==39 then
  if buying(buy.r,l.r) > 0 then
   l.r+=1
   points-=buy.r
   buy.r+=2000
   regen+=3
  end
 elseif x==56 and y==98 then
 	if buying(buy.h,l.h) > 0 then
   l.h+=1
   points-=buy.h
   buy.h+=3000
   mhp+=200
   hp=mhp
  end
 elseif x==96 and y==39 then
 	if buying(buy.a,l.a) > 0 then
   l.a+=1
   points-=buy.a
   buy.a+=500
   armor+=10
  end
 elseif x==130 and y==24 then
  if buying(p.dc,p.dl) > 0 then
   p.dl+=1
   points-=p.dc
   p.dc+=2500
  end
 elseif x==130 and y==44 then
  if buying(p.vc,p.vl) > 0 then
   p.vl+=1
   points-=p.vc
   p.vc+=2000
  end
 elseif x==224 and y==24 and buy.sg==false then
  if buying(buy.sgp,0) > 0 then
   buy.sg=true
   for b in all (buttons) do
    del(buttons,b)
   end
   but=false
   points-=buy.sgp
  end
 elseif x==164 and y==80 then
  if buying(ar.dc,ar.dl) > 0 then
   ar.dl+=1
   points-=ar.dc
   ar.dc+=3000
  end
 elseif x==164 and y==100 then
  if buying(ar.vc,ar.vl) > 0 then
   ar.vl+=1
   points-=ar.vc
   ar.vc+=2000
  end
 elseif x==184 and y==80 and buy.ar==false then
  if buying(buy.arp,0) > 0 then
   buy.ar=true
   for b in all (buttons) do
    del(buttons,b)
   end
   but=false
   points-=buy.arp
  end
 elseif x==196 and y==24 then
  if buying(sg.dc,sg.dl) > 0 then
   sg.dl+=1
   points-=sg.dc
   sg.dc+=3500
  end
 elseif x==196 and y==44 then
  if buying(sg.vc,sg.vl) > 0 then
   sg.vl+=1
   points-=sg.vc
   sg.vc+=2000
  end
	end
end


function buying(cost,lvl)
 if lvl<5 then
		if points>=cost then
		 sfx(16)
		 return 1
		else
		 sfx(17)
		 error=true
		 return 0
		end
	else
	 sfx(17)
	 maxed=true
	 return 0
	end
end
-->8
--stars
--[[
 handles background stars
]]

function star()
  add(stars,{
	  x=0,
	  y=0,
	  spawned=false,
	  c=0,
	  
	  draw=function(self)
	   if self.spawned==true then
	    palt(15,true)
	    if self.c==0 then
	     spr(134,self.x,self.y,1,1)
	    elseif self.c==1 then
	     spr(135,self.x,self.y,1,1)
	    elseif self.c==2 then
	     spr(136,self.x,self.y,1,1)
	    else
	     spr(137,self.x,self.y,1,1)
	    end
	   end
	  end,
	  
	  update=function(self)
	   if self.spawned==false then
	    if (flr(0+rnd(2))) == 0 then
	     self.x = 0+rnd(128*2)
	     self.y = -8
	    else
	     self.x = -8
	     self.y = 0+rnd(128)
	    end
	    self.c=flr(0+rnd(4))
	    self.spawned=true
	   else
	    if self.x>128*2 or self.y>128 then
	     del(stars,self)
	     snum-=1
	    else
      self.x+=1
      self.y+=1
	    end
	   end
	  end
	 })
end
-->8
--sounds
--[[
 handles game noise
]]

function splash_mus()
 if splashm==0 then
	 sfx(0,1)
	 splashm+=1
 end
end

function splash_mus_end()
 sfx(0,-2)
 splashm=0
end
__gfx__
8eeeeee8eeeee000000eeeeeeeeee000000eeeee0000000000eeeeeeeee00eeeeeeeeeeeeeeeeeee000eeeeeee00eeee00000000000000000000000000000000
e8e88e8eeeee08888880eeeeeeee08888880eeee00000000ee0eeeeeee0eeeeeeeeeeeeeeeeeeeeeee0eeeeeee0eeeee00000000000000000000000000000000
ee8ee8eeeee0888887770eeeeee0888887770eee00000000eeee000000eeeeeeeee00eee00eeeeeeeeee000000eeeeee00000000000000000000000000000000
e8e88e8eee088888887780eeee088888887780ee00999900eee00337700eeeeeee0eeeeeee0eeeeeeee00222700eeeee00000000000000000000000000000000
e8e88e8eee088888888780eeee088888888780ee00999900ee003333370eeeeeeeee000000eeeeeeee002022070eeeee00005555555500000055555555555550
ee8ee8eeee088000000880eeee088000000880ee00000000ee0330330300eeeeeee00337700eeeeeee0227007200eeee00056656565650000565656565656565
e8e88e8eee080000077080eeee080000077080ee00000000ee0333aa3330eeeeee003333370eeeeeee0222aa2220eeee00056666666650005666666666666650
8eeeeee8ee080700007080eeee080700007080ee00000000ee003a33a300eeeeee0330330300eeeeee002a88a200eeee00056666665500005666666666665500
77777777ee080770000080eeee080770000080ee00000000eee00033300eeeeeee0333aa3330eeeeeee00088000eeeee00054445550000005444555544450000
77777777eee0800000080eeeeee0800000080eee00000000eeee0e000e0eeeeeee003a33a300eeeeeeee0e00ee0eeeee00054450000000005445000544500000
77777777eeee000000000eeeeeee000000000eee00000000eeee0eeeee0eeeeeeee00033300eeeeeeeee0eeeee0eeeee00054450000000005445000055000000
77777777eeee088800880eeeeeee055500880eee00000000eeee0eeeee0eeeeeeeee0e000e0eeeeeeeee0eeee000eeee00054450000000005445000000000000
77777777eeee05550880eeeeeeee05550880eeee00000000eee000eeee0eeeeeeeee0eeee000eeeeeee000eeee0eeeee00005500000000000550000000000000
77777777eeee0555000eeeeeeee9a555a00eeeee00000000eeee0eeee000eeeeeee000eeee0eeeeeeeee0eeee0e0eeee00000000000000000000000000000000
77777777eeee05550eeeeeeeeeee9aaa9eeeeeee00000000eeeeeeeeee0eeeeeeeee0eeee0e0eeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
77777777eeeee000eeeeeeeeeeeee999eeeeeeee00000000eeeeeeeeeeeeeeeeeee0e0eeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000555000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000050000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000555000000000066000066000000005500005500000000000000000000
eeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000555550000000068860068860000005dd5005dd50000000000000000000
eeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000005666665000000688886688b8600005dddd55dbdd5000055555555555500
eee007777770000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000005d6866500000688888888bbb860005ddddddbbbd5000566565656565650
eee007777770000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000005688865000006888888888b88600005ddddddbd50000566666666666650
eee00771111777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000005d68665000006888888888888600005dddddddd50000566666666666500
eee00771777117700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeee000005666665000006888888888888600005dddddddd50000544455444555000
eee0077111777177700eeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeee000005d88885000000688888888886000005dddddddd50000544500555000000
eee0077111117117700eeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeee000005888885000000068888888860000005dddddddd50000544500000000000
eeeee0071111117777700000000000000000000000000eee00000000eee99eee000005d88885000000006888888600000005dddddddd50000544500000000000
eeeee0071111177777700000000000000000000000000eee00000000eee99eee0000005555500000000006888860000000005dddddd500000055000000000000
eeeee007711177777007777007777777777777777777700e00000000eeeeeeee0000000666000000000000688600000000000555555000000000000000000000
eeeee007771777777007777007777777777777777777700e00000000eeeeeeee0000000060000000000000066000000000000000000000000000000000000000
eeeeeee00777777007777777700777777777777777700eee00000000eeeeeeee0000000060000000000000000000000000000000000000000000000000000000
eeeeeee00777777007777777700777777777777777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee007090088880000000700008888000000007000888800090
eeeeeeeee0077007777777777770077777777000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee090000866668009000000086666800900900708666680707
eeeeeeeee0077007777777777770077777777000000eeeeeeeee00000000eeeeeeeeeeeeeeeeeeee000a08600006800790070860000680000000086000068000
eeeeeeeeeee00777777777777777700770000eeeeeeeeeeeeee0333333330eeeeeee00000000eeee088008077cc08000000008077cc08007709008077cc080a0
eeeeeeeeeee00777777777777777700770000eeeeeeeeeeeee03333bb33330eeeee0333333330eee86680807ccc0807008800807ccc089000000a807ccc08007
eeeeeeeeeee0077777777777777777700eeeeeeeeeeeeeeeee03333bb33330eeee03333bb33330ee8786860cccc068008778860cccc068000888860cccc06800
eeeeeeeeeee0077777777777777777700eeeeeeeeeeeeeeeee033bbbbbb330eeee03333bb33330ee087688700007868086878870000686808787887000068680
eeeeeeeeeee0000777777777777777700eeeeeeeeeeeeeeeee033bbbbbb330eeee033bbbbbb330ee008876877778686808667787777868688686678777786868
eeeeeeeeeee0000777777777777777700eeeeeeeeeeeeeeeee03333bb33330eeee033bbbbbb330eea00887688887686890888778888668680888867888866868
eeeeeeeeeee007700777777777777777700eeeeeeeeeeeeeee03333bb33330eeee03333bb33330ee000008777777686800000877777768680009087777776868
eeeeeeeeeee007700777777777777777700eeeeeeeeeeeeeee003333333300eeee03333bb33330ee07090877777768680907087777776878a000087777776878
eeeeeeeeeee007777007777777777777700eeeeeeeeeeeeeeee0000000000eeeeee0333333330eee900008777766808000000877776680800070087777668080
eeeeeeeeeee007777007777777777777700eeeeeeeeeeeeeeeee00000000eeeeeeee00000000eeee000a08877688809007000887768887000900088776888007
eeeeeeeeeee007777770077777777770077000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee070087686876800700078768687680090000876868768090
eeeeeeeeeee007777770077777777770077000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00087668876800007098766887680000709876688768000a
eeeeeeeeeee00777777770000777700777777777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7090888008800a0700008880088007070000888008800700
eeeeeeeeeee00777777770000777700700777777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbbbbbb
eeeeeeeeeee0077777700eeee0000777000777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb00000000000000b
eeeeeeeeeee0077777700eeee0000777700077700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeb00000000000000b
eeeeeeeeeee0077777700eeeeeeee0077700700eeeeeeeeeee000000000000eeeeeeeeeeeeeeeeeeeee0888888880eeeeeee00000000eeeeb00000000000000b
eeeeeeeeeee0077777700eeeeeeee0077777700eeeeeeeeee03333333333330eee000000000000eeee088800088880eeeee0888888880eeeb00000000000000b
eeeeeeeeeee00777700eeeeeeeeee00777700eeeeeeeeeee03aa33a33a3a3a30e03333333333330eee088800008880eeee088800088880eeb00000000000000b
eeeeeeeeeee00777700eeeeeeeeee00777700eeeeeeeeeee03a3a3a33a3a3a3003aa33a33a3a3a30ee088800000880eeee088800008880eeb00000000000000b
eeeeeeeeeee00777700eeeeeeeeee007700eeeeeeeeeeeee03aa33a33a33a33003a3a3a33a3a3a30ee088800000880eeee088800000880eeb00000000000000b
eeeeeeeeeee00777700eeeeeeeeee007700eeeeeeeeeeeee03a3a3a33a33a33003aa33a33a33a330ee088800008880eeee088800000880eeb00000000000000b
eeeeeeeeeee00777700eeeeeeeeeeee00eeeeeeeeeeeeeee03aa333aa333a33003a3a3a33a33a330ee088800088880eeee088800008880eeb00000000000000b
eeeeeeeeeee00777700eeeeeeeeeeee00eeeeeeeeeeeeeee003333333333330003aa333aa333a330ee008888888800eeee088800088880eeb00000000000000b
eeeeeeeeeee007700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000e0033333333333300eee0000000000eeeeee0888888880eeeb00000000000000b
eeeeeeeeeee007700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000eee00000000000000eeeee00000000eeeeeeee00000000eeeeb00000000000000b
eeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb00000000000000b
eeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb00000000000000b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbbbbbb
8888888888888888cccccccccccccc7c7cccccccccccccccffffffffffffffffffffffffffffffff515151515151515151515151515151515151515151515151
8800000000000008cccccccccccccc7c7cccccccccccccccff777fffff7777ffffff777ff7777fff515151515151515151515151515151515151515151515151
8080000000000008cccccccccccccc7c7cccccccccccccccf777777ff777777ff777777f777777ff515151515151515151515151515151515151515151515151
8008000000000008cccccccccccccc7c7ccccccccccccccc7777777f77777777777777777777777f515151515151515151515151515151515151515151515151
8000800000000008cccccccccccccc7c7ccccccccccccccc77777777f777777777777777f777777f515151515151515151515151515151515151515151515151
8000080000000008cccccccccccccc7c7cccccccccccccccf7777777ff77777f77777777f777777f515151515151515151515151515151515151515151515151
8000008000000008cccccccccccccc7c7cccccccccccccccff77f77ffffffffff77f7777ff77777f515151515151515151515151515151515151515151515151
8000000800000008777777777777777777777777ccccccccfffffffffffffffffffffffffff777ff515151515151515151515151515151515151515151515151
80000000800000080000000000000000515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80000000080000080000000000000000515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80000000008000080000000000000000515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80000000000800080000000000000000515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
80000000000080080000000000000000515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80000000000008080000000000000000515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
80000000000000880000000000000000515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
88888888888888880000000000000000515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
333b33b33333333300777777700eeeee00777777700eeeee51515151515151515151515151515151515151515151515151515151515151515151515151515151
b333333b33b334330007777009eeeeee0007777009eeeeee51510000000000000000000000000000000000000000000000000000000000000000000000000000
3b34b3333433333370007770099eeeee70007770099eeeee51515151515151515151515151515151515151515151515151515151515151515151515151515151
3333b33b33333b3b7700700a999eeeee7700700a9999eeee51510000000000000000000000000000000000000000000000000000000000000000000000000000
b3b33b3333333b337777700aaa99eeee7777700aaa99eeee51515151515151515151515151515151515151515151515151515151515151515151515151515151
b33333333334333377700aaaaaa99eee77700aaaaaa99eee51510000000000000000000000000000000000000000000000000000000000000000000000000000
3b3333bb33b3333377700aaaaaa99e9e77700aaaaaaa99ee51515151515151515151515151515151515151515151515151515151515151515151515151515151
b433b3333333b33b700aaaaaaaaa99e9700aaaaaaaaa999e51510000000000000000000000000000000000000000000000000000000000000000000000000000
333333333b43b3337009aaaaaaaa99ee7009aaaaaaaa99e951515151515151515151515151515151515151515151515151515151515151515151515151515151
333b3334333333b309999aaaaaaa99e909999aaaaa99999e51510000000000000000000000000000000000000000000000000000000000000000000000000000
b3333333b33333330ee9999aaaa9999e0ee9999aaa9999e951515151515151515151515151515151515151515151515151515151515151515151515151515151
33b333b33bb33b33eeee999999999ee9eeee999999999eee51510000000000000000000000000000000000000000000000000000000000000000000000000000
333333333b333b33eeeeeeeee999e9eeeeeeeee99999ee9e51515151515151515151515151515151515151515151515151515151515151515151515151515151
34333433333b3333eeeeeeee9e9eee99eeeeee9eee9e9eee51510000000000000000000000000000000000000000000000000000000000000000000000000000
3b3bb3333b333433eeeeeeeee99e9eeeeeeeeeee9eeeee9951515151515151515151515151515151515151515151515151515151515151515151515151515151
33333333333333bbeeeeeeeeeee9ee9eeeeeeee9eee9e9ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000515151515151515151515151515151515151515151515151
00001111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000
00011111111111111111111111111111111111111111111111111111111110000000000000000000515151515151000000000000000000000000000000000000
00111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000
01111000000110000001100000011000000110000001100000011000011111100000000000000000000000000000000000000000000000000000000000000000
11111000000110000001100000011000000110000001100000011000011111110000000000000000000000000000000000000000000000000000000000000000
11111001100111100111100110011001100110011001100110011001100111110000000000000000000000000000000000000000000000000000000000000000
11111001100111100111100110011001100110011001100110011001100111110000000000000000000000000000000000000000000000000000000000000000
11111000000111100111100001111000011110011001100001111001100111110000000000000000000000000000000000000000000000000000000000000000
11111000000111100111100001111000011110011001100001111001100111110000000000000000000000000000000000000000000000000000000000000000
11111001100111100111100110011001100110011001100110011001100111110000000000000000000000000000000000000000000000000000000000000000
11111001100111100111100110011001100110011001100110011001100111110000000000000000000000000000000000000000000000000000000000000000
11111001100110000001100110011000000110000001100110011001100111110000000000000000000000000000000000000000000000000000000000000000
11111001100110000001100110011000000110000001100110011001100111110000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
11100001100110011000000110011001100000011001100110000001100111110000000000000000000000000000000000000000000000000000000000000000
11100001100110011000000110011001100000011001100110000001100111110000000000000000000000000000000000000000000000000000000000000000
10011111100110011001100110011001111001111001100110011001100111110000000000000000000000000000000000000000000000000000000000000000
10011111100110011001100110011001111001111001100110011001100111110000000000000000000000000000000000000000000000000000000000000000
10000001100110011000011110011001111001111001100110000001100111110000000000000000000000000000000000000000000000000000000000000000
10000001100110011000011110011001111001111001100110000001100111110000000000000000000000000000000000000000000000000000000000000000
11111001100110011001100110000001111001111000000110011001100111110000000000000000000000000000000000000000000000000000000000000000
11111001100110011001100110000001111001111000000110011001100111110000000000000000000000000000000000000000000000000000000000000000
10000111111000011001100111100111100000011110011110011001100000010000000000000000000000000000000000000000000000000000000000000000
10000111111000011001100111100111100000011110011110011001100000010000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000
00111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000
00011111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000
00001111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888777777888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88778877788ee888ee88ee888ee88ee8e8ee88ee888ee88ee8eeee88ee888ee88888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8777787778eeeee8ee8eeeee8ee8eee8e8ee8eee8eeee8eee8eeee8eeeee8ee88888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8777787778eee888ee8eeee88ee8eee888ee8eee888ee8eee888ee8eeeee8ee88e8e888ff888ff888222222888888222888228882888822288888
888eee8e8ee8777787778eee8eeee8eeeee8ee8eeeee8ee8eeeee8ee8eee8e8ee8eeeee8ee88888888ff888ff888822228888228222888882282888222288888
888eee888ee8777888778eee888ee8eee888ee8eeeee8ee8eee888ee8eee888ee8eeeee8ee888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8777777778eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1eee1111166616161616111111661166111111111ccc1ccc1c1111cc1ccc11111eee1e1e1eee1ee1111111111111111111111111111111111111
1111111111e11e111111161616161616111116111611177717771c111c1c1c111c111c11111111e11e1e1e111e1e111111111111111111111111111111111111
1111111111e11ee11111166116161666111116661611111111111cc11ccc1c111ccc1cc1111111e11eee1ee11e1e111111111111111111111111111111111111
1111111111e11e111111161616161116111111161616177717771c111c1c1c11111c1c11111111e11e1e1e111e1e111111111111111111111111111111111111
111111111eee1e111111166611661666117116611666111111111c111c1c1ccc1cc11ccc111111e11e1e1eee1e1e111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111bb1bbb1bbb11711cc11ccc1ccc11111cc11cc11ccc11111cc11ccc11111ccc11111ccc11711111111111111111111111111111111111111111
1111111111111b111b1b1b1b171111c1111c1c1c111111c111c11c1c111111c11c1c1111111c1111111c11171111111111111111111111111111111111111111
1111111111111bbb1bbb1bb1171111c11ccc1ccc111111c111c11c1c111111c11ccc11111ccc11111ccc11171111111111111111111111111111111111111111
111111111111111b1b111b1b171111c11c111c1c117111c111c11c1c117111c11c1c11711c1111711c1111171111111111111111111111111111111111111111
1111111111111bb11b111b1b11711ccc1ccc1ccc17111ccc1ccc1ccc17111ccc1ccc17111ccc17111ccc11711111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1ee11ee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1e1e1eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1eee1111166616161616111116661666111111111ccc1ccc1c1111cc1ccc11111eee1e1e1eee1ee1111111111111111111111111111111111111
1111111111e11e111111161616161616111116161616177717771c111c1c1c111c111c11111111e11e1e1e111e1e111111111111111111111111111111111111
1111111111e11ee11111166116161666111116661661111111111cc11ccc1c111ccc1cc1111111e11eee1ee11e1e111111111111111111111111111111111111
1111111111e11e111111161616161116111116161616177717771c111c1c1c11111c1c11111111e11e1e1e111e1e111111111111111111111111111111111111
111111111eee1e111111166611661666117116161616111111111c111c1c1ccc1cc11ccc111111e11e1e1eee1e1e111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111bb1bbb1bbb11711cc11ccc1ccc11111cc11cc11ccc11111ccc1c1c11111ccc11111ccc11711111111111111111111111111111111111111111
1111111111111b111b1b1b1b171111c1111c1c1c111111c111c11c1c1111111c1c1c1111111c1111111c11171111111111111111111111111111111111111111
1111111111111bbb1bbb1bb1171111c11ccc1ccc111111c111c11c1c111111cc1ccc11111ccc11111ccc11171111111111111111111111111111111111111111
111111111111111b1b111b1b171111c11c111c1c117111c111c11c1c1171111c111c11711c1111711c1111171111111111111111111111111111111111111111
1111111111111bb11b111b1b11711ccc1ccc1ccc17111ccc1ccc1ccc17111ccc111c17111ccc17111ccc11711111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1ee11ee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1e1e1eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111bbb1bbb1bbb1bb11bbb11711c1c1ccc1ccc1ccc11111ccc11cc1c1c11111ccc1c1c11111ccc11111ccc117111111111111111111111111111111111
111111111b1b1b1b11b11b1b11b117111c1c1c1c1ccc1c1c111111c11c1c1c1c11111c1c1c1c1111111c1111111c111711111111111111111111111111111111
111111111bbb1bb111b11b1b11b1171111111cc11c1c1cc1111111c11c1c111111111ccc1ccc11111ccc1111111c111711111111111111111111111111111111
111111111b111b1b11b11b1b11b1171111111c1c1c1c1c1c111111c11c1c111111711c1c111c11711c111171111c111711111111111111111111111111111111
111111111b111b1b1bbb1b1b11b1117111111c1c1c1c1ccc111111c11cc1111117111ccc111c17111ccc1711111c117111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111888881111111111111111111111111111111111111111111
111111111bbb1bbb1bbb1bb11bbb11711c1c11cc1c1c1ccc1ccc1c1c11111ccc1ccc11111ccc1111887881111111111111111111111111111111111111111111
111111111b1b1b1b11b11b1b11b117111c1c1c111c1c1c1c1c1c1c1c11111c1c1c1c11111c1c1111888781111111111111111111111111111111111111111111
111111111bbb1bb111b11b1b11b1171111111ccc1c1c1ccc1ccc111111111ccc1ccc11111ccc1111888781111111111111111111111111111111111111111111
111111111b111b1b11b11b1b11b117111111111c1ccc1c1c1c11111111711c1c1c1c11711c1c1171888781117111111111111111111111111111111111111111
111111111b111b1b1bbb1b1b11b1117111111cc11ccc1c1c1c11111117111ccc1ccc17111ccc1711887881117711111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111117771111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111117777111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111117711111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111171111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1eee1111166116661616166611111666116616161661166111111eee1e1e1eee1ee1111111111111111111111111111111111111111111111111
1111111111e11e1111111616161116161161111116161616161616161616111111e11e1e1e111e1e111111111111111111111111111111111111111111111111
1111111111e11ee111111616166111611161111116611616161616161616111111e11eee1ee11e1e111111111111111111111111111111111111111111111111
1111111111e11e1111111616161116161161111116161616161616161616111111e11e1e1e111e1e111111111111111111111111111111111111111111111111
111111111eee1e1111111616166616161161166616161661116616161666111111e11e1e1eee1e1e111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111d111d1dd11ddd1d1d1ddd11111ddd11dd1d1d1dd11dd111111ddd1ddd11dd11dd1ddd11dd1ddd111111111111111111111111111111111111
11111111111111d111d11d1d1d111d1d11d111111d1d1d1d1d1d1d1d1d1d11111ddd1d111d111d111d1d1d111d11111111111111111111111111111111111111
11111111111111d111d11d1d1dd111d111d111111dd11d1d1d1d1d1d1d1d11111d1d1dd11ddd1ddd1ddd1d111dd1111111111111111111111111111111111111
11111111111111d111d11d1d1d111d1d11d111111d1d1d1d1d1d1d1d1d1d11111d1d1d11111d111d1d1d1d1d1d11111111111111111111111111111111111111
1111111111111d111d111d1d1ddd1d1d11d111111d1d1dd111dd1d1d1ddd11111d1d1ddd1dd11dd11d1d1ddd1ddd111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111bbb1bbb1bbb1bb11bbb11711c1c1ccc1ccc1ccc11cc11cc111111ccccc11c1c11111c1111111ccc1c1c11111ccc117111111111111111111111
1111111111111b1b1b1b11b11b1b11b117111c1c1c1c1c1c1c111c111c1111111cc1c1cc1c1c11111c1111111c111c1c11111c1c111711111111111111111111
1111111111111bbb1bb111b11b1b11b1171111111ccc1cc11cc11ccc1ccc11111ccc1ccc111111111ccc11111ccc1ccc11111ccc111711111111111111111111
1111111111111b111b1b11b11b1b11b1171111111c111c1c1c11111c111c11111cc1c1cc111111711c1c1171111c111c11711c1c111711111111111111111111
1111111111111b111b1b1bbb1b1b11b1117111111c111c1c1ccc1cc11cc1111111ccccc1111117111ccc17111ccc111c17111ccc117111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111bbb1bbb1bbb1bb11bbb11711c1c1ccc11cc111111cc11cc11111ccc11cc1c1c11111c1111111c111cc111111ccc117111111111111111111111
1111111111111b1b1b1b11b11b1b11b117111c1c11c11c1c11111c111c1c111111c11c1c1c1c11111c1111111c1111c111111c1c111711111111111111111111
1111111111111bbb1bb111b11b1b11b11711111111c11c1c11111c111c1c111111c11c1c111111111ccc11111ccc11c111111ccc111711111111111111111111
1111111111111b111b1b11b11b1b11b11711111111c11c1c11111c1c1c1c111111c11c1c111111711c1c11711c1c11c111711c1c111711111111111111111111
1111111111111b111b1b1bbb1b1b11b11171111111c11cc111111ccc1cc1111111c11cc1111117111ccc17111ccc1ccc17111ccc117111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111bbb1bbb1bbb1bb11bbb11711c1c1cc11ccc1c1c1ccc11111ccc11cc1c1c1cc11cc11c1c11111ccc11111c111ccc11111ccc1171111111111111
1111111111111b1b1b1b11b11b1b11b117111c1c1c1c1c111c1c11c111111c1c1c1c1c1c1c1c1c1c1c1c1111111c11111c111c1c11111c1c1117111111111111
1111111111111bbb1bb111b11b1b11b1171111111c1c1cc111c111c111111cc11c1c1c1c1c1c1c1c1111111111cc11111ccc1ccc11111ccc1117111111111111
1111111111111b111b1b11b11b1b11b1171111111c1c1c111c1c11c111111c1c1c1c1c1c1c1c1c1c11111171111c11711c1c1c1c11711c1c1117111111111111
1111111111111b111b1b1bbb1b1b11b1117111111c1c1ccc1c1c11c111111c1c1cc111cc1c1c1ccc111117111ccc17111ccc1ccc17111ccc1171111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111d111d1d1d1ddd11dd1ddd1ddd1dd11ddd11111ddd1ddd11dd11dd1ddd11dd1ddd111111111111111111111111111111111111111111111111
11111111111111d111d11d1d1d1d1d111d1d1d1d1d1d1d1111111ddd1d111d111d111d1d1d111d11111111111111111111111111111111111111111111111111
11111111111111d111d11d1d1ddd1d111dd11ddd1d1d1dd111111d1d1dd11ddd1ddd1ddd1d111dd1111111111111111111111111111111111111111111111111
11111111111111d111d11d1d1d111d1d1d1d1d1d1d1d1d1111111d1d1d11111d111d1d1d1d1d1d11111111111111111111111111111111111111111111111111
1111111111111d111d1111dd1d111ddd1d1d1d1d1ddd1ddd11111d1d1ddd1dd11dd11d1d1ddd1ddd111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822882288222888282828228822888888888888888888888888888888888888882828222822282228882822282288222822288866688
82888828828282888888882888288282882882828828882888888888888888888888888888888888888882828282888282828828828288288282888288888888
82888828828282288888882888288282882882228828882888888888888888888888888888888888888882228222822282828828822288288222822288822288
82888828828282888888882888288282882888828828882888888888888888888888888888888888888888828882828882828828828288288882828888888888
82228222828282228888822282228222828888828222822288888888888888888888888888888888888888828882822282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585828282828282828285858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585848282838282828285858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585848282838282828285858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151585858585858585858585858585858585
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
8585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
1515151515158585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
1515151515158585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
1515151515158585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
1515151515158585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
1515151515158585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
1515151515158585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
1515151515158585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
1515151515158585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
__sfx__
0010001f1303013030130301303011030110300f0300f0300f0300f0300f030160301603016030160300f0300f0300f0300f0300c0300c0300c0300c0300f0300f0300f0300f0300c0300c0300c0300c03013000
151000000c0730c0030c0730c073130030c0730c0030c0030c073070030c0730c0730c0030c0730c0030c0030c0730c0030c0730c0730c0030c0730c0030c0030c0730c0030c0730c0730c0030c0730c0030c003
0d1000002803028030180002803028030280302b030247002803028030280002803028030280302e030300002803028030180002803028030280302c03028030230302300021030240001e030240002303024000
45100f0f1175213002130021675212002120021675212002137521100216752167020f7520f7020f7520f7021b75216702167021675215002167021b752160020f7520750218752075021b752075020750207502
2c1000001372013720137201372013720137201372013720137201372013720117200f7200f7200f7200f7200f7200f7200f7200f7200f7200f7200f7200f7200f7200f7200f7201172013720137201372013720
10060000115501d5502e55024500175001b5002550000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
051000003505433054300542e0542b0542905427054220501f0501b05018050160501605013050130501305013050130500f0500f0500f0500a0500a0500a0500f0500f0500f0500f0502b000170001700000000
11100707241512415124151241510010124151241512415124151001012415124151241512415124151241510a1010a101061010b1010c1010d101201010e1010f101071011010111101111011c1011210112101
15100000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0730c0030c0730c0730c0030c07300000000000c0730c0030c0730c0730c0030c0730000000000
0d100000000000000000000000000000000000000000000000000000000000000000000000000000000000002803028030180002803028030280302c03028030230302300021030240001e030240002303024000
00100000160501705016050170501605017050160501705016050170501605017050160501705016050170500a0500b0500a0500b0500a0500b0500a0500b0500a0500b0500a0500b0500a0500b0500a0500b050
590400001537614376123760f3760e37605306043060a306063060030600306003060030600306003060030600306003060030600306003060030600306003060030600306003060030600306003060030600306
150100000515603156031560315603156051560a1560f156161561b156081060a1060c10611106171061a10620106001060010600106001060010600106001060010600106001060010600106001060010600106
15020000181560c1560e1561115613156181561c1561c1561c156191561d1560a1060c10611106171061a10620106001060010600106001060010600106001060010600106001060010600106001060010600106
5f0200001c3411c341193411734116341143411334112341000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
1402000009352063520165209652096520d65212352143521265219302143021430216302153021330213302133021630216302183021b3020030200302003020030200302003020030200302003020030200302
350200001b1501b15016150111500f150161501b150221502e1502e15030150301503315033150001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
340100001d4501b4501b45016450134501045013450124500f450104500a4500f4500c4500a4500a4500040000400004000040000400004000040000400004000040000400004000040000400004000040000400
__music__
01 07084941
01 02014a41
00 02014244
00 010a4a44
02 010a4a44
03 03044244

