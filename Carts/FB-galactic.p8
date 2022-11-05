pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--[[
 initial setup and main update
 function
 
 poke(0x5f2d, 1) -> enables mouse
 stat(32) -> x coord
 stat(33) -> y coord
 stat(34) -> button bitmask
]]

pos={}
mouse={}
a=0
border={}
cross_pos={}
shoot={}
bullets={}
bspeed=4

function _init()
 //enables mouse
	poke(0x5f2d, 1)
	
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
	
	//vars to handle shooting anim
	shoot.sprite=1
	shoot.shot=false
	shoot.semi=true
end

function _update()
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
 
 for b in all(bullets) do
  b:update()
 end
end
-->8
--[[
 drawing
]]

function _draw()
 //clears screen
 cls()

 //makes pink transparent
 palt(14,true)

 //draws map
	map(0,0)
	
	//draws ship
	palt(0,false)
	spr(32,40,40,6,6)
	palt(0,true)

 //handles shooting
 bam()
 
 //draws all bullets to screen
 for b in all(bullets) do
  b:draw()
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
  
  //creates bullet
  bullet()
 end
 
 //debug
 //print(mouse.x)
 //print(mouse.y*-1)
 //print((a+90)*-1)
 
 //draws the player's cursor
 crosshair()
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
-->8
--[[
 crosshair(cursor) drawing and
 handling
]]

//draws the cursor and
//checks cursor's borders
function crosshair()
 //cursor's position used for
 //drawing
 cross_pos.x=stat(32)+4
	cross_pos.y=stat(33)+4
	
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
   spr(0,pos.x+64,pos.y-56)
  elseif(border.d) 
  then
   spr(0,pos.x+64,pos.y+64)
  else
   spr(0,pos.x+64,cross_pos.y)
  end

 //checks left border collision 
 elseif(border.l) 
 then
  if(border.u) 
  then
   spr(0,pos.x-56,pos.y-56)
  elseif(border.d) 
  then
   spr(0,pos.x-56,pos.y+64)
  else
   spr(0,pos.x-56,cross_pos.y)
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
--[[
 handles projectiles
]]



function bullet()
 add(bullets,{
  x=pos.x+4,
  y=pos.y+4,
  ogx=pos.x+4,
  ogy=pos.x+4,
  
  mya=atan2(mouse.x, mouse.y),
  ba=(a+90)*-1,
  
  draw=function(self)
   spr_r(5,self.x,self.y,self.ba*-1,1,1,0)
  end,
  
  update=function(self)
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
__gfx__
80000008eeeee000000eeeeeeeeee000000eeeee00000000eeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee0000000000000000
08088080eeee08888880eeeeeeee08888880eeee00000000e000eeeeeee00eee00000000ee000eeeeeee00ee00000000ee000eeeeeee00ee0000000000000000
00800800eee0888887770eeeeee0888887770eee00000000eee0eeeeeee0eeee00000000eeee0eeeeeee0eee00000000eeee0eeeeeee0eee0000000000000000
08088080ee088888887780eeee088888887780ee00999900eeeee00000eeeeee00000000eeeeee00000eeeee00000000eeeeee00000eeeee0000000000000000
08088080ee088888888780eeee088888888780ee00999900eeee00337000eeee00000000eeeee00337000eee00000000eeeee00337000eee0000000000000000
00800800ee088000000880eeee088000000880ee00000000eee003333770eeee00000000eeee003333770eee00000000eeee003333770eee0000000000000000
08088080ee080000077080eeee080000077080ee00000000eee0333333300eee000e0000eeee0333333300ee00000000eeee0333333300ee0000000000000000
80000008ee080700007080eeee080700007080ee00000000eee0333333330eee00000000eeee0333333330ee00000000eeee0333aa3330ee0000000000000000
77777777ee080770000080eeee080770000080ee00000000eee0033333300eee00000000eeee0033333300ee00000000eeee003aaaa300ee0000000000000000
77777777eee0800000080eeeeee0800000080eee00000000eeee00073300eeee00000000eeeee00073300eee00000000eeeee00aeea00eee0000000000000000
77777777eeee000000000eeeeeee000000000eee00000000eeeee0e000e0eeee00000000eeeeee0e000e0eee00000000eeeeee0eeeee0eee0000000000000000
77777777eeee088800880eeeeeee055500880eee00000000eeeee0eeeee0eeee00000000eeeeee0eeeee0eee00000000eeeeee0eeeee0eee0000000000000000
77777777eeee05550880eeeeeeee05550880eeee00000000eeeee0eeee000eee00000000eeeee000eeee0eee00000000eeeeee0eeee000ee0000000000000000
77777777eeee0555000eeeeeeee9a555a00eeeee00000000eeee000eeeeeeeee00000000eeeeeeeeeee000ee00000000eeeee000eeeeeeee0000000000000000
77777777eeee05550eeeeeeeeeee9aaa9eeeeeee00000000eeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee0000000000000000
77777777eeeee000eeeeeeeeeeeee999eeeeeeee00000000eeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee0000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee006666660000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee006666660000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0066600000666600eeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0066007770066600eeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000
eee006600077700666600eeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000
eee006600007700666600eeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000eeeeeeaaaaeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000
eee0066000000066600660000000000000000eeeeeeeeeee0000000000000000eeeeeaa88aaeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000
eee0066000000666600660000000000000000eeeeeeeeeee0000000000000000eeeea88888aaeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000
eeeee0060000666006666660066666666666600eeeeeeeee0000000000000000eeeea888888aeeeee0000000eeeeeeee0000000080000000eeeeeeee00000000
eeeee0066006666006666660066666666666600eeeeeeeee0000000000000000eeea88888888aeeee0333330000000ee0000000080333330000000ee00000000
eeeee006666660066666666660066666666666600eeeeeee0000000000000000eeeea888888aeeeee0000003333370ee00000000e0000003333370ee00000000
eeeee006666660066666666660066666666666600eeeeeee0000000000000000eeeeaa88888aeeeeeeeeee00000370ee00000000eeeeee00000370ee00000000
eeeeeee0066006666666666666600666666666600eeeeeee0000000000000000eeeeeeaaa8aeeeeeeeeeeeee0e0370ee00000000eeeeeeee0e0370ee00000000
eeeeeee0066006666666666666600666666666600eeeeeee0000000000000000eeeeeeeeeaeeeeeeeeeeeeee000370ee00000000eeeeeeee000370ee00000000
eeeeeeeee006666666666666666660066666600eeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeee0370ee00000000eeeeeeeeee0370ee00000000
eeeeeeeee006666666666666666660066666600eeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeee0000ee00000000eeeeeeeeee0000ee00000000
eeeeeeeeeee00666666666666666666006600eeeeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000
eeeeeeeeeee00666666666666666666006600eeeeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000
eeeeeeeeeee000066666666666666666600eeeeeeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000
eeeeeeeeeee000066666666666666666600eeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee00660066666666666666666600eeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee00660066666666666666666600eeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee006666006666666666666600eeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee006666006666666666666600eeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee006666660066666666660066000000eeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee006666660066666666660066000000eeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee00666666660066666600666666666600eeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee00666666660066666600600666666600eeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee006666666666006600666000666600eeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee006666666666006600666600066600eeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee006666666600ee00ee0066600600eeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeee006666666600ee00ee0066666600eeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeee00666600eeeeeeee00666600eeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeee00666600eeeeeeee00666600eeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeee0000eeeeeeeeee006600eeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeee0000eeeeeeeeee006600eeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeee8eeeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeee8eeeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeee0eeeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeee000eeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeee00300eeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeee0033300eeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeee003333300eee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeee033333330eee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeee000000000eee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
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
1010101010101010101010061010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010100610101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344
