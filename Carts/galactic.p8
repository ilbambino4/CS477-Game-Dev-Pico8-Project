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

function _init()
 setup()
end

function setup()
 //sets up scenes
 //1=logo
 //2=splash
 //3=game
 //4=upgrades
 scene=1
 
 //checks for change to upgrade
 //menu
 up=false
 
 
 //enables mouse
	poke(0x5f2d, 1)
	
	//dimensions for player sprite
	w=12
	h=16
	
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
	
	//player's points
	points=0
	
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
end


function _update()
 if scene == 1 then
  logo()
 elseif scene == 2 then
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
   scene=2
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
	 
	 spawn()
	 
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
	else
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
	  screen=1
	  scene=3
	  up=false
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
  splash_draw()
 elseif scene == 3 then
	 //makes pink transparent
	 //and black not transparent
	 palt()
	 palt(14,true)
	 palt(0,false)
	
	 //draws map
		map(0,0)
		
		//draws ship
		spr(32,40,40,6,6)
		
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
	  else
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
	 print("hp: ",52,84,0)
	 print(hp,64,84,8)
	 
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
	 
	 if next_round then
	  //next round message
	  print("press ❎",6,54,8)
	  print("to go to",6,61,8)
	  print("next round",3,68,8)
	  
	  //upgrade message
	  print("press 🅾️",88,54,8)
	  print("to purchase",82,61,8)
	  print("upgrades",88,68,8)
	 end
	else
		//draws map
	 map(30,10)
	 
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
		pal(8,12)
	 //draws the player's cursor
	 crosshair()
	 palt()
	 pal()
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
	 print("lvl: ",14,54,7)
	 print(l.r,30,54,7)
		print("$",14,60,9)
		print(buy.r,18,60,9)
	else
	 print("lvl:max",10,54,7)
	end
	
	//armor upgrade
	spr(44,96,py+20,2,2)
	print("less damage",83,10,11)
	print("taken",95,16,11)
	if l.a<5 then
		print("lvl: ",95,54,7)
		print(l.a,111,54,7)
		print("$",95,60,9)
	 print(buy.a,99,60,9)
	else
	 print("lvl:max",90,54,7)
	end
	
	//health upgrade
	spr(42,56,py+79,2,2)
	print("max",59,70,11)
	print("health",53,76,11)
	if l.h<5 then
		print("lvl: ",54,44+69,7)
		print(l.h,70,44+69,7)
		print("$",54,50+69,9)
		print(buy.h,58,50+69,9)
	else
	 print("lvl:max",50,44+69,7)
	end
	
	//weapons
	//pistol
	spr(12,16+128,gy+9,2,2)
	print("pistol",14+128,9,11)
	print("damage",17+128,29,11)
	if p.dl<5 then
		print("lvl:",5+128,38,7)
		print(p.dl,21+128,38,7)
		print("$",34+128,38,9)
		print(p.dc,38+128,38,9)
	else
	 print("lvl:max",5+128,38,7)
	end
	
	print("velocity",17+128,49,11)
	if p.vl<5 then
		print("lvl:",5+128,58,7)
		print(p.vl,21+128,58,7)
		print("$",34+128,58,9)
		print(p.vc,38+128,58,9)
	else
	 print("lvl:max",5+128,58,7)
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
			print("lvl:",71+128,38,7)
			print(sg.dl,87+128,38,7)
			print("$",100+128,38,9)
			print(sg.dc,104+128,38,9)
		else
		 print("lvl:max",71+128,38,7)
		end
		
		print("velocity",83+128,49,11)
		if sg.vl<5 then
			print("lvl:",71+128,58,7)
			print(sg.vl,87+128,58,7)
			print("$",100+128,58,9)
			print(sg.vc,104+128,58,9)
		else
		 print("lvl:max",71+128,58,7)
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
			print("lvl:",39+128,94,7)
			print(ar.dl,55+128,94,7)
			print("$",68+128,94,9)
			print(ar.dc,72+128,94,9)
		else
		 print("lvl:max",39+128,94,7)
		end
			
		print("velocity",51+128,105,11)
		if ar.vl<5 then
			print("lvl:",39+128,114,7)
			print(ar.vl,55+128,114,7)
			print("$",68+128,114,9)
			print(ar.vc,72+128,114,9)
		else
		 print("lvl:max",39+128,114,7)
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
	 print("press ❎ to start",32,55,8)
end
function splash_update()
	 if btn(❎) then
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
    spr_r(5,self.x,self.y,self.ba*-1,1,1,1)
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
  w=12,
  h=13,
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
    	pal(3,8)
    	self.hurt=false;
    end
			
				if (self.attacking) then
					if self.anim_timer<self.attack_speed then
	     spr(10,self.x,self.y,2,2)
	     if self.anim_timer==0 then
	      hp-=100
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
		   sp_t-=1
			  round+=1
			  enemies=sqrt(round)*15
			  next_round=false
		  end
		  if btn(🅾️) then
			  scene=4
			  next_round=false
		  end
		 end
  end
 end
 
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


function attacking()
 for a in all(aliens) do
  if
	 (a.x > pos.x+w+2) 
		or
		(a.x+a.w < pos.x+2) 
		or
		(a.y > pos.y+h) 
		or
		(a.y+a.h < pos.y) 
		then
		else
		 if a.attacking==false then
		  hp-=(100-armor)
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
		 return 1
		else
		 error=true
		 return 0
		end
	else
	 maxed=true
	 return 0
	end
end
__gfx__
8eeeeee8eeeee000000eeeeeeeeee000000eeeee11111111000eeeeeee00eeee000eeeeeee00eeee000eeeeeee00eeee00000000000000000000000000000000
e8e88e8eeeee08888880eeeeeeee08888880eeee11111111ee0eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeee00000000000000000000000000000000
ee8ee8eeeee0888887770eeeeee0888887770eee11111111eeee00000eeeeeeeeeee00000eeeeeeeeeee00000eeeeeee00000000000000000000000000000000
e8e88e8eee088888887780eeee088888887780ee11999911eee00337000eeeeeeee00337000eeeeeeee00337000eeeee00000000000000000000000000000000
e8e88e8eee088888888780eeee088888888780ee11999911ee003333770eeeeeee003333770eeeeeee003333770eeeee00005555555500000055555555555550
ee8ee8eeee088000000880eeee088000000880ee11111111ee0333333300eeeeee0333333300eeeeee0333333300eeee00056656565650000565656565656565
e8e88e8eee080000077080eeee080000077080ee11111111ee0333333330eeeeee0333333330eeeeee0333aa3330eeee00056666666650005666666666666650
8eeeeee8ee080700007080eeee080700007080ee11111111ee0033333300eeeeee0033333300eeeeee003aaaa300eeee00056666665500005666666666665500
77777777ee080770000080eeee080770000080ee11111111eee00073300eeeeeeee00073300eeeeeeee00aeea00eeeee00054445550000005444555544450000
77777777eee0800000080eeeeee0800000080eee11111111eeee0e000e0eeeeeeeee0e000e0eeeeeeeee0eeeee0eeeee00054450000000005445000544500000
77777777eeee000000000eeeeeee000000000eee11111111eeee0eeeee0eeeeeeeee0eeeee0eeeeeeeee0eeeee0eeeee00054450000000005445000055000000
77777777eeee088800880eeeeeee055500880eee11111111eeee0eeee000eeeeeee000eeee0eeeeeeeee0eeee000eeee00054450000000005445000000000000
77777777eeee05550880eeeeeeee05550880eeee11111111eee000eeeeeeeeeeeeeeeeeee000eeeeeee000eeeeeeeeee00005500000000000550000000000000
77777777eeee0555000eeeeeeee9a555a00eeeee11111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
77777777eeee05550eeeeeeeeeee9aaa9eeeeeee11111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
77777777eeeee000eeeeeeeeeeeee999eeeeeeee11111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000555000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000050000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000555000000000066000066000000005500005500000000000000000000
eeeeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000555550000000068860068860000005dd5005dd50000000000000000000
eeeeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000005666665000000688886688b8600005dddd55dbdd5000055555555555500
eeeee006666660000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000005d6866500000688888888bbb860005ddddddbbbd5000566565656565650
eeeee006666660000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000005688865000006888888888b88600005ddddddbd50000566666666666650
eee0066600000666600eeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000005d68665000006888888888888600005dddddddd50000566666666666500
eee0066007770066600eeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeee000005666665000006888888888888600005dddddddd50000544455444555000
eee006600077700666600eeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeee000005d88885000000688888888886000005dddddddd50000544500555000000
eee006600007700666600eeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeee000005888885000000068888888860000005dddddddd50000544500000000000
eee0066000000066600660000000000000000eeeeeeeeeee00000000eee99eee000005d88885000000006888888600000005dddddddd50000544500000000000
eee0066000000666600660000000000000000eeeeeeeeeee00000000eee99eee0000005555500000000006888860000000005dddddd500000055000000000000
eeeee0060000666006666660066666666666600eeeeeeeee00000000eeeeeeee0000000666000000000000688600000000000555555000000000000000000000
eeeee0066006666006666660066666666666600eeeeeeeee00000000eeeeeeee0000000060000000000000066000000000000000000000000000000000000000
eeeee006666660066666666660066666666666600eeeeeee00000000eeeeeeee0000000060000000000000000000000000000000000000000000000000000000
eeeee006666660066666666660066666666666600eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee007090088880000000700008888000000007000888800090
eeeeeee0066006666666666666600666666666600eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee090000866668009000000086666800900900708666680707
eeeeeee0066006666666666666600666666666600eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeee000a08600006800790070860000680000000086000068000
eeeeeeeee006666666666666666660066666600eeeeeeeeeeee0333333330eeeeeee00000000eeee088008077cc08000000008077cc08007709008077cc080a0
eeeeeeeee006666666666666666660066666600eeeeeeeeeee03333bb33330eeeee0333333330eee86680807ccc0807008800807ccc089000000a807ccc08007
eeeeeeeeeee00666666666666666666006600eeeeeeeeeeeee03333bb33330eeee03333bb33330ee8786860cccc068008778860cccc068000888860cccc06800
eeeeeeeeeee00666666666666666666006600eeeeeeeeeeeee033bbbbbb330eeee03333bb33330ee087688700007868086878870000686808787887000068680
eeeeeeeeeee000066666666666666666600eeeeeeeeeeeeeee033bbbbbb330eeee033bbbbbb330ee008876877778686808667787777868688686678777786868
eeeeeeeeeee000066666666666666666600eeeeeeeeeeeeeee03333bb33330eeee033bbbbbb330eea00887688887686890888778888668680888867888866868
eeeeeeeeeee00660066666666666666666600eeeeeeeeeeeee03333bb33330eeee03333bb33330ee000008777777686800000877777768680009087777776868
eeeeeeeeeee00660066666666666666666600eeeeeeeeeeeee003333333300eeee03333bb33330ee07090877777768680907087777776878a000087777776878
eeeeeeeeeee006666006666666666666600eeeeeeeeeeeeeeee0000000000eeeeee0333333330eee900008777766808000000877776680800070087777668080
eeeeeeeeeee006666006666666666666600eeeeeeeeeeeeeeeee00000000eeeeeeee00000000eeee000a08877688809007000887768887000900088776888007
eeeeeeeeeee006666660066666666660066000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee070087686876800700078768687680090000876868768090
eeeeeeeeeee006666660066666666660066000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00087668876800007098766887680000709876688768000a
eeeeeeeeeee00666666660066666600666666666600eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7090888008800a0700008880088007070000888008800700
eeeeeeeeeee00666666660066666600600666666600eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbbbbbb
eeeeeeeeeee006666666666006600666000666600eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb00000000000000b
eeeeeeeeeee006666666666006600666600066600eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeb00000000000000b
eeeeeeeeeee006666666600ee00ee0066600600eeeeeeeeeee000000000000eeeeeeeeeeeeeeeeeeeee0888888880eeeeeee00000000eeeeb00000000000000b
eeeeeeeeeee006666666600ee00ee0066666600eeeeeeeeee03333333333330eee000000000000eeee088800088880eeeee0888888880eeeb00000000000000b
eeeeeeeeeeeee00666600eeeeeeee00666600eeeeeeeeeee03aa33a33a3a3a30e03333333333330eee088800008880eeee088800088880eeb00000000000000b
eeeeeeeeeeeee00666600eeeeeeee00666600eeeeeeeeeee03a3a3a33a3a3a3003aa33a33a3a3a30ee088800000880eeee088800008880eeb00000000000000b
eeeeeeeeeeeeeee0000eeeeeeeeee006600eeeeeeeeeeeee03aa33a33a33a33003a3a3a33a3a3a30ee088800000880eeee088800000880eeb00000000000000b
eeeeeeeeeeeeeee0000eeeeeeeeee006600eeeeeeeeeeeee03a3a3a33a33a33003aa33a33a33a330ee088800008880eeee088800000880eeb00000000000000b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeee03aa333aa333a33003a3a3a33a33a330ee088800088880eeee088800008880eeb00000000000000b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeee003333333333330003aa333aa333a330ee008888888800eeee088800088880eeb00000000000000b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000e0033333333333300eee0000000000eeeeee0888888880eeeb00000000000000b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000eee00000000000000eeeee00000000eeeeeeee00000000eeeeb00000000000000b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb00000000000000b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb00000000000000b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbbbbbb
88888888888888885151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
88000000000000085151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
80800000000000085151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80080000000000085151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
80008000000000085151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80000800000000085151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
80000080000000085151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80000008000000085151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
80000000800000085151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80000000080000085151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
80000000008000085151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80000000000800085151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
80000000000080085151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
80000000000008085151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
80000000000000885151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
88888888888888885151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
51515151515151515151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
51515151515151515151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
51515151515151515151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
51515151515151515151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
51515151515151515151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
51515151515151515151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
51515151515151515151515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
51515151515151515151515151000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151
51515151515151515151515151000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
51515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000051515151515151515151515151515151515151515151000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777779
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777779977777779
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777799977777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777799777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777997777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777779997777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777779977777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777799777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777999777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777997777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777787777778777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777778788787777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777877877777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777778788787777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777778788787777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777877877777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777778788787777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777787777778777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777779977777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777999997777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777799777777777777
77777777777777777777777777777777777777777777777000000777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777000000777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700666666000077777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700666666000077777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770066600000666600777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770066007770066600777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770066000777006666007777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770066000077006666007777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770066000000066600660000000000000000777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770066000000666600660000000000000000777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700600006660066666600666666666669907777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700660066660066666600666666666699907777777997777777777777777777777799777777777777777
77777777777777777777777777777777777777777777700666666006666666666006666666699660077799999777777777777777777779999977777777777777
77777777777777777777777777777777777777777777700666666006666666666006666666666660077779977777777777777777777777997777777777777777
77777777777777777777777777777777777777777777777006600666666666666660099666666660077777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777006600666666666600600999666666660077777777777777777777777777777777777777777777777
7777777777777777777777777777777777777777777777777006666666666608880a999666666007777777777777777777777777777777777777777777777777
777777777777777777777777777777777777777777777777700666666666000080805aa966666007777777777777777777777777777777777777777777777777
7777777777777777777777777777777777777777777777777770066666608880000555a906600777777777777777777777777777777777777777777777777777
7777777777777777777777777777777777777777777777777770066666008000000555a006600777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700006660807700000500960077777777777777777779999777799997777777777777777777777
77777777777777777777777777777777777777777777777777700006608787700000006660077777777777777777779999777799997777777777777777777777
77777777777777777777777777777777777777777777777777700660007780000070866666600777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700660067788000770066666600777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666608788800008806660077777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666608888888888066660077777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666660088888880666006600000077777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666666008888806666006600000077777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666666600800066600666666666600777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666666660066666600600666666600777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666666666600660066600066660077777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666666666600660066660006660077777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666666660077007700666006007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777700666666660077007700666666007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777006666007777777700666600777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777006666007777777700666600777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777770000777777777700660077777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777770000777777777700660077777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777007777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777007777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777

__map__
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515150000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515150000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515150000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515150000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515150000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515150000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515150000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515150000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

