pro plx
; create animation explaining parallax

; the sun is always at (0,0,0)
; the earth moves around the unit (x,y) circle
; stars have randomly generated (x,y,z)

; as we go around the circle, just calculate the viewing angle of the
; stars as they are projected in 2D

loadct,39,/silent
nstar = 2d3
nqso = 1d2
norbit= 1.
nsteps = 360./10.


set_plot,'ps'
;window,0,xsize=700,ysize=600


xs = (randomu(ss,nstar)-0.5)*2d2
ys = (randomu(ss,nstar))*2d2 ; stars
zs = (randomn(ss,nstar))*2d1

xq = (randomu(ss,nqso)-0.5)*1d5
yq = (randomu(ss,nqso)-0.5)*1d5 ; QSOs
zq = (randomu(ss,nqso)-0.5)*1d5

dx = xq  &  dy = yq - 1
rxy = sqrt(dx^2. + dy^2.)
d = sqrt(dx^2. + dy^2. + zq^2.)
theta_q = asin(dx/rxy) * 180./!pi ; these are fixed
phi_q = asin(zq/d) * 180./!pi

;!p.multi=[0,2,1]
!P.charsize=1.6

flist = ' '
for i=0,nsteps-1 do begin

   device,filename='frame_'+string(i,f='(I05)')+'.eps',$
          /encap,/color,/inch,xsize=8,ysize=8

;   orbit = i * !pi / 180.       ; orbital angle for earth
   orbit = i*(360./nsteps) * !pi/180.
   x_e = cos(orbit)             ; x(earth)
   y_e = sin(orbit)             ; y(earth)

   dx = xs - x_e
   dy = ys - y_e
   
   rxy = sqrt(dx^2. + dy^2.)
   d = sqrt(dx^2. + dy^2. + zs^2.)
   theta = asin(dx/rxy) * 180./!pi
   phi = asin(zs/d) * 180./!pi

   plot,theta,phi,/nodata,psym=3,xrange=[-25,25],yrange=[-25,25],xtickname=replicate(' ',8),ytickname=replicate(' ',8),position=[0,0,1,1],xstyle=5,ystyle=5
   oplot,theta_q,phi_q,color=250,psym=8,symsize=3 ; qso's
   oplot,theta,phi,psym=8,symsize=1

   loadct,0,/silent
   oplot,cos(findgen(360)/180.*!pi)-23,sin(findgen(360)/180.*!pi)-23,$
         thick=3,color=150

   loadct,39,/silent
   oplot,[x_e]-23,[y_e]-23,psym=8,color=90,symsize=3
   oplot,[-23],[-23],psym=8,color=200,symsize=3

   device,/close

   spawn,'convert -density 75x75 -flatten '+$
         'frame_'+string(i,f='(I05)')+'.eps '+$
         'frame_'+string(i,f='(I05)')+'.gif'

   spawn,'rm frame*.eps'

   flist = flist + ' frame_'+string(i,f='(I05)')+'.gif'
endfor


spawn,'gifsicle -d 5 --loop -O2'+flist+' > plx.gif'


spawn,'rm frame*.gif'


stop
end
