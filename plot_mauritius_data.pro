PRO plot_mauritius_data
;
; This program - written in IDL performs all analyses steps to produce the range of graphs and tables shown in the paper
; by Awe et al. assessing the long term parallel measurements in Mauritius. The sole input file required for all analyses
; performed herein is the csv file containing the digitised data holdings at monthly resolution.
; 
; Users would need to modify input and output directory names to work on their local machines.
;
;--------------------------------------------------------------------------
; Program starts by reading in the parallel measurements digitised by Samuel Awe and augmented by Peter Thorne from a .csv file
; which is a conversion of the original. proprietary, excel spreadsheet used to perform the transcription. 

; set up the read in arrays
data_array=FLTARR(29,240)
data_array[*,*]=-999.
months=INTARR(240)
years= INTARR(240)

; Open the file and read in all variables

OPENR,1,'/Users/pthorne/Desktop/Mauritius/Mauritius_Data_rescue_parallel_measurements.csv' ; user specific pathway
  temp=''  ; temporary text just used to get each line read in first
  READF,1,temp ; This is the header line containing the column headers. It is known what these are so they are
               ; not used in the present program.
  FOR e=0,239 DO BEGIN ; A loop over the 20 years of measurement series
    READF,1,temp,FORMAT='(A)'
    years[e]=FIX(STRMID(temp,0,4))
    current_comma=4
    next_comma=STRPOS(temp,',',current_comma+1)
    months[e]=FIX(STRMID(temp,current_comma+1,next_comma-current_comma-1))
    current_comma=next_comma
    FOR val=0,28 DO BEGIN ; Note that the csv dummy column is to enable the final column to be read.
      next_comma=STRPOS(temp,',',current_comma+1)
      IF next_comma-current_comma GE 2 THEN data_array[val,e]=FLOAT(STRMID(temp,current_comma+1,next_comma-current_comma-1))
      current_comma=next_comma
    ENDFOR
  ENDFOR
CLOSE,1

;------------------------------------------------------------------------
; Next program sets up things that are common to all schemas for the figures
; 
; Will use a common colour schema so set this up here.
LOADCT,5
r = fltarr(255)
g = fltarr(255)
b = fltarr(255)

r(0) = 0
g(0) = 0
b(0) = 0

r(1) = 90
g(1) = 150
b(1) = 235

r(2) = 225
g(2) = 60
b(2) = 30

r(3) = 45
g(3) = 180
b(3) = 20

r(4) = 230
g(4) = 190
b(4) = 0

r(5) = 255
g(5) = 120
b(5) = 60

r(6) = 100
g(6) = 100
b(6) = 105

r(7)=255
g(7)=255
b(7)=255

r(8)=70
g(8)=50
b(8)=200

tvlct, r, g ,b

; The times axis is common to all figures so set it up top.
times=(findgen(240)/12.)+1884
xtick_vals=[times[0],times[12],times[24],times[36],times[48],times[60],times[72],times[84],times[96],$
  times[108],times[120],times[132],times[144],times[156],times[168],times[180],times[192],times[204],times[216],times[228]]
;
;----------------------------------------------------------------------------------------------------------------
; First create a figure that just denotes when the various measurements are available as well as the availability of the annual reports
; and the blue book series.
;
; To do so requires additional information on years of availability of the two series which we start by manually editing in here.
years_annual=[1887,1888,1889,1890,1891,1892,1893,1894,1895,1896,1897,1898,1899,1900,1901,1902,1903]
years_blue_book=[1884,1885,1887,1888,1889,1890,1892,1893,1894,1895,1896,1897,1898,1899,1900,1901,1902,1903]
;
;
SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/availability_timeseries_reports.ps',/color,/helvetica,/landscape
PLOT,times,[0.],xtickv=xtickvals,title='Data and report availability',yrange=[0,32],$
                xtitle='year',xrange=[1884,1904],ytickinterval=32.,xstyle=1
; Fill over the 0 and 32 marks on y-axis
x=[1883,1883.95,1883.95,1883]
y=[-1.,-1.,1.,1.]
polyfill,x,y,color=7
y=[31,31,33,33]
polyfill,x,y,color=7
For y=0,N_ELEMENTS(years_annual)-1 DO BEGIN
  points=WHERE(FIX(times) EQ years_annual[y])
  ypoints=INTARR(12)
  ypoints[*]=1.
  OPLOT,times[points],ypoints,psym=2
Endfor
XYOUTS,1880.2,0.75,'Annual reports'
For y=0,N_ELEMENTS(years_blue_book)-1 DO BEGIN
  points=WHERE(FIX(times) EQ years_blue_book[y])
  ypoints=INTARR(12)
  ypoints[*]=2.
  OPLOT,times[points],ypoints,psym=2
Endfor
XYOUTS,1880.2,1.75,'Blue books'
labels=['Room Tx','Room Tn','Room Ta','Room Tm','Room Tm (c)','Thermograph Tx','Thermograph Tn',$
        'Thermograph Ta','Thermograph Tm','Thermograph Tm (c)','Stevenson Tx','Stevenson Tn','Stevenson Ta',$
        'Stevenson Tm','Stevenson Tm (c)','Hygrometer Tx','Hygrometer Tn','Hygrometer Ta','Hygrometer Tm',$
        '6ft Stevenson Tx','6ft Stevenson Tn','6ft Stevenson Ta','6ft Stevenson Tm','6ft Stevenson Tm (c)',$
        'Lg Stevenson Tx','Lg Stevenson Tn','Lg Stevenson Ta','Lg Stevenson Tm','Lg Stevenson Tm (c)']
FOR e=0,28 DO BEGIN
  points=WHERE(data_array[e,*] NE -999., cnt)
  IF cnt GE 1 THEN BEGIN
    ypoints=INTARR(cnt)
    ypoints[*]=e+3
    OPLOT,times[points],ypoints,psym=1
  ENDIF
  XYOUTS,1880.2,e+2.75,labels[e]
ENDFOR
;

DEVICE,/close_file
SET_PLOT,'X'

;------------------------------------------------------------------------------------------------
; Next convert values from Farenheit to Celcius ready to perform the subsequent data plots
legal_vals=WHERE(data_array NE -999.)
data_array[legal_vals]=(data_array[legal_vals]-32.)/1.8

;-------------------------------------------------------------------------------------------------
; Plot the maximum temperatures and their offsets

SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/tx_timeseries.ps',/color,/helvetica,/landscape
PLOT,times,data_array[0,*],min_value=0.,xtickv=xtickvals,title='Maximum temperature series',$
       xtitle='Year',ytitle='Converted temperature (C)',yrange=[14.,33.],xrange=[1884,1903],xstyle=1,ystyle=1
OPLOT,times,data_array[0,*],min_value=0.,color=1,thick=3
OPLOT,times,data_array[5,*],min_value=0.,color=2,thick=3
OPLOT,times,data_array[10,*],min_value=0.,color=3,thick=3
PLOTS,[1884,1903],[22,22]
PLOTS,[1884,1903],[20,20],linestyle=1
XYOUTS,1903.3,21.8,'2'
XYOUTS,1903.3,19.8,'0'
XYOUTS,1903.1,17.8,'-2'
XYOUTS,1903.1,15.8,'-4'
x=[1883.5,1883.95,1883.95,1883.5]
y=[14,14,16,16]
polyfill,x,y,color=7
y=[19,19,21,21]
polyfill,x,y,color=7
XYOUTS,1904,17,'Differences (C)',orientation=90 
; Plot the differences
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[0,t] NE -999. THEN BEGIN
    IF data_array[5,t] NE -999. THEN diffs[t]=data_array[0,t]-data_array[5,t]+20.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=4,thick=3
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[0,t] NE -999. THEN BEGIN
    IF data_array[10,t] NE -999. THEN diffs[t]=data_array[0,t]-data_array[10,t]+20.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=5,thick=3
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[5,t] NE -999. THEN BEGIN
    IF data_array[10,t] NE -999. THEN diffs[t]=data_array[5,t]-data_array[10,t]+20.
  ENDIF 
ENDFOR
OPLOT,times,diffs,min_value=0,color=6,thick=3
  
; Plot inline key
PLOTS,[1884.,1885.],[12.,12.],color=1,thick=3
XYOUTS,1885.5,11.85,'Ventialted room'
PLOTS,[1891.,1892.],[12.,12.],color=2,thick=3
XYOUTS,1892.5,11.85,'Thermograph'
PLOTS,[1898.,1899.],[12.,12.],color=3,thick=3
XYOUTS,1899.5,11.85,'Stevenson screen'
PLOTS,[1884.,1885],[11.,11.],color=4,thick=3
XYOUTS,1885.5,10.85,'Room - Thermograph'
PLOTS,[1891,1892],[11.,11.],color=5,thick=3
XYOUTS,1892.5,10.85,'Room - Stevenson'
PLOTS,[1898,1899],[11,11],color=6,thick=3
XYOUTS,1899.5,10.85,'Thermograph - Stevenson'
  
DEVICE,/close_file
SET_PLOT,'X'

;---------------------------------------------------------------------------------
; Plot the minimum temperatures and their offsets

SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/tn_timeseries.ps',/color,/helvetica,/landscape
PLOT,times,data_array[1,*],min_value=0.,xtickv=xtickvals,title='Minimum temperature series',$
  xtitle='Year',ytitle='Converted temperature (C)',yrange=[5.,24.],xrange=[1884,1903],xstyle=1,ystyle=1
OPLOT,times,data_array[1,*],min_value=0.,color=1,thick=3
OPLOT,times,data_array[6,*],min_value=0.,color=2,thick=3
OPLOT,times,data_array[11,*],min_value=0.,color=3,thick=3

PLOTS,[1884,1903],[13,13]
PLOTS,[1884,1903],[9,9],linestyle=1
XYOUTS,1903.3,12.8,'4'
XYOUTS,1903.3,10.8,'2'
XYOUTS,1903.3,8.8,'0'
XYOUTS,1903.1,6.8,'-2'
XYOUTS,1903.1,4.8,'-4'
x=[1883,1883.95,1883.95,1883]
y=[9,9,11,11]
polyfill,x,y,color=7
y=[4.5,4.5,5.5,5.5]
polyfill,x,y,color=7
XYOUTS,1904,6,'Differences (C)',orientation=90

diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[1,t] NE -999. THEN BEGIN
    IF data_array[6,t] NE -999. THEN diffs[t]=data_array[1,t]-data_array[6,t]+9.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=4,thick=3
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[1,t] NE -999. THEN BEGIN
    IF data_array[11,t] NE -999. THEN diffs[t]=data_array[1,t]-data_array[11,t]+9.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=5,thick=3
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[6,t] NE -999. THEN BEGIN
    IF data_array[11,t] NE -999. THEN diffs[t]=data_array[6,t]-data_array[11,t]+9.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=6,thick=3


; Plot inline key
PLOTS,[1884.,1885.],[3.,3.],color=1,thick=3
XYOUTS,1885.5,2.85,'Ventialted room'
PLOTS,[1891.,1892.],[3.,3.],color=2,thick=3
XYOUTS,1892.5,2.85,'Thermograph'
PLOTS,[1898.,1899.],[3.,3.],color=3,thick=3
XYOUTS,1899.5,2.85,'Stevenson screen'
PLOTS,[1884.,1885],[2.,2.],color=4,thick=3
XYOUTS,1885.5,1.85,'Room - Thermograph'
PLOTS,[1891,1892],[2.,2.],color=5,thick=3
XYOUTS,1892.5,1.85,'Room - Stevenson'
PLOTS,[1898,1899],[2.,2.],color=6,thick=3
XYOUTS,1899.5,1.85,'Thermograph - Stevenson'

DEVICE,/close_file
SET_PLOT,'X'

;----------------------------------------------------------------------------------------------------
; Plot Ta - the reported_averages
SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/ta_timeseries.ps',/color,/helvetica,/landscape
PLOT,times,data_array[2,*],min_value=0.,xtickv=xtickvals,title='Average temperature series',$
  xtitle='Year',ytitle='Converted temperature (C)',yrange=[14.,28.],xrange=[1884,1903],xstyle=1,ystyle=1
OPLOT,times,data_array[2,*],min_value=0.,color=1,thick=3
OPLOT,times,data_array[7,*],min_value=0.,color=2,thick=3
OPLOT,times,data_array[12,*],min_value=0.,color=3,thick=3
OPLOT,times,data_array[17,*],min_value=0,color=8,thick=3
PLOTS,[1884,1903],[18,18]
PLOTS,[1884,1903],[16,16],linestyle=1
XYOUTS,1903.3,17.9,'2'
XYOUTS,1903.3,15.9,'0'
XYOUTS,1903.1,13.9,'-2'
x=[1883,1883.95,1883.95,1883]
y=[13,13,16.5,16.5]
polyfill,x,y,color=7
XYOUTS,1904,15,'Differences (C)',orientation=90
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[2,t] NE -999. THEN BEGIN
    IF data_array[7,t] NE -999. THEN diffs[t]=data_array[2,t]-data_array[7,t]+16.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=4,thick=3
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[2,t] NE -999. THEN BEGIN
    IF data_array[12,t] NE -999. THEN diffs[t]=data_array[2,t]-data_array[12,t]+16.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=5,thick=3
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[7,t] NE -999. THEN BEGIN
    IF data_array[12,t] NE -999. THEN diffs[t]=data_array[7,t]-data_array[12,t]+16.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=6,thick=3


; Plot inline key
PLOTS,[1884.,1885.],[13.,13.],color=1,thick=3
XYOUTS,1885.5,12.85,'Ventialted room'
PLOTS,[1890.,1891.],[13.,13.],color=2,thick=3
XYOUTS,1891.5,12.85,'Thermograph'
PLOTS,[1895.,1896.],[13.,13.],color=3,thick=3
XYOUTS,1896.5,12.85,'Stevenson screen'
PLOTS,[1900.5,1901.5],[13.,13.],color=8,thick=3
XYOUTS,1902,12.85,'Hygrometer'
PLOTS,[1884.,1885],[12.,12.],color=4,thick=3
XYOUTS,1885.5,11.85,'Room - Thermograph'
PLOTS,[1891,1892],[12.,12.],color=5,thick=3
XYOUTS,1892.5,11.85,'Room - Stevenson'
PLOTS,[1898,1899],[12,12],color=6,thick=3
XYOUTS,1899.5,11.85,'Thermograph - Stevenson'
DEVICE,/close_file
SET_PLOT,'X'

;-------------------------------------------------------------------------------------
;Plot Tm - the mean series 

SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/tm_timeseries.ps',/color,/helvetica,/landscape
PLOT,times,data_array[4,*],min_value=0.,xtickv=xtickvals,title='Mean temperature series',$
  xtitle='Year',ytitle='Converted temperature (C)',yrange=[14.,28.],xrange=[1884,1903],xstyle=1,ystyle=1
OPLOT,times,data_array[4,*],min_value=0.,color=1,thick=3
OPLOT,times,data_array[9,*],min_value=0.,color=2,thick=3
OPLOT,times,data_array[14,*],min_value=0.,color=3,thick=3
PLOTS,[1884,1903],[18,18]
PLOTS,[1884,1903],[16,16],linestyle=1
XYOUTS,1903.3,17.9,'2'
XYOUTS,1903.3,15.9,'0'
XYOUTS,1903.1,13.9,'-2'
x=[1883,1883.95,1883.95,1883]
y=[13,13,16.5,16.5]
polyfill,x,y,color=7
XYOUTS,1904,15,'Differences (C)',orientation=90
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[4,t] NE -999. THEN BEGIN
    IF data_array[9,t] NE -999. THEN diffs[t]=data_array[4,t]-data_array[9,t]+16.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=4,thick=3
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[4,t] NE -999. THEN BEGIN
    IF data_array[14,t] NE -999. THEN diffs[t]=data_array[4,t]-data_array[14,t]+16.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=5,thick=3
diffs=FLTARR(240)
diffs[*]=-999.
FOR t=0,239 DO BEGIN
  IF data_array[9,t] NE -999. THEN BEGIN
    IF data_array[14,t] NE -999. THEN diffs[t]=data_array[9,t]-data_array[14,t]+16.
  ENDIF
ENDFOR
OPLOT,times,diffs,min_value=0,color=6,thick=3


; Plot inline key
PLOTS,[1884.,1885.],[13.,13.],color=1,thick=3
XYOUTS,1885.5,12.85,'Ventialted room'
PLOTS,[1891.,1892.],[13.,13.],color=2,thick=3
XYOUTS,1892.5,12.85,'Thermograph'
PLOTS,[1898.,1899.],[13.,13.],color=3,thick=3
XYOUTS,1899.5,12.85,'Stevenson screen
PLOTS,[1884.,1885],[12.,12.],color=4,thick=3
XYOUTS,1885.5,11.85,'Room - Thermograph'
PLOTS,[1891,1892],[12.,12.],color=5,thick=3
XYOUTS,1892.5,11.85,'Room - Stevenson'
PLOTS,[1898,1899],[12,12],color=6,thick=3
XYOUTS,1899.5,11.85,'Thermograph - Stevenson'
DEVICE,/close_file
SET_PLOT,'X'


;---------------------------------------------------------------------------------------
; Now plot difference scatter plots over the annual cycle for Tavg diffs

!P.Multi=[0,1,3]
SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/ta_diffs.ps',/color,/helvetica,/portrait
months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-1.3,0.8],title='ventilated room - thermograph',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
XYOUTS,4.5,1.3,'Average temperature differences'
temp1=data_array[2,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[7,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted) 
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR


months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-1.3,0.8],title='ventilated room - stevenson screen',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[2,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[12,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR

months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-1.3,0.8],title='thermograph - stevenson screen',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[7,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[12,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR
DEVICE,/close_file
SET_PLOT,'X'
;-----------------------------------------------------------------------------------------------------
;
; Repeat for mean temperatures
!P.Multi=[0,1,3]
SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/tm_diffs.ps',/color,/helvetica,/portrait
months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-1.5,0.7],title='ventilated room - thermograph',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
XYOUTS,4.5,1.2,'Mean temperature differences'
temp1=data_array[4,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[9,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR


months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-1.5,0.7],title='ventilated room - stevenson screen',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[4,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[14,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR

months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-1.5,0.7],title='thermograph - stevenson screen',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[9,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[14,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR
DEVICE,/close_file
SET_PLOT,'X'
;-----------------------------------------------------------------------------------------------
; Repeat for minimum temperatures
;
!P.Multi=[0,1,3]
SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/tn_diffs.ps',/color,/helvetica,/portrait
months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[0,3.5],title='ventilated room - thermograph',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
XYOUTS,4.5,4.,'Minimum temperature differences'
temp1=data_array[1,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[6,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR


months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[0,3.5],title='ventilated room - stevenson screen',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[1,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[11,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR

months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[0.,3.5],title='thermograph - stevenson screen',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[6,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[11,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR
DEVICE,/close_file
SET_PLOT,'X'

;------------------------------------------------------------------------------------------
; Repeat with maximum temperatures
!P.Multi=[0,1,3]
SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/tx_diffs.ps',/color,/helvetica,/portrait
months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-5.,0],title='ventilated room - thermograph',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
XYOUTS,4.5,1,'Maximum temperature differences'
temp1=data_array[0,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[5,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR


months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-5.,0],title='ventilated room - stevenson screen',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[0,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[10,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR

months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-5.,0],title='thermograph - stevenson screen',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[5,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[10,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR
DEVICE,/close_file
SET_PLOT,'X'

;----------------------------------------------------------------------------------------------------------------------
; Plot the differences between Tavg and Tm
;
SET_PLOT,'PS'
Device,file='/Users/pthorne/Desktop/Mauritius/ta_tm_diffs.ps',/color,/helvetica,/portrait
months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-1.,1.2],title='ventilated room',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
XYOUTS,3.5,1.5,'Reported average - mean temperature differences'
temp1=data_array[2,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[4,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR


months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-1.,1.2],title='thermograph',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[7,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[9,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR

months=INDGEN(12)+1
dummy=[0]
PLOT,months,dummy,xrange=[0.5,12.5],yrange=[-1.,1.2],title='stevenson screen',$
  xtitle='Month of year',ytitle='Difference (C)',xstyle=1,ystyle=1
PLOTS,[0.5,12.5],[0,0],linestyle=1
temp1=data_array[12,*]
temp1=REFORM(temp1,12,20)
temp2=data_array[14,*]
temp2=REFORM(temp2,12,20)
FOR m=0,11 DO BEGIN
  vtemp1=temp1[m,*]
  vtemp2=temp2[m,*]
  points=WHERE(vtemp1 NE -999. AND vtemp2 NE -999.)
  diffs=vtemp1[points]-vtemp2[points]
  sorted=SORT(diffs)
  diffs=diffs(sorted)
  med_val=median(diffs)
  PLOTS,[m+0.5,m+1.5],[med_val,med_val],thick=3
  FOR e=0,N_ELEMENTS(diffs)-1 DO PLOTS,m+1,diffs[e],psym=1
ENDFOR
DEVICE,/close_file
SET_PLOT,'X'

!P.multi=0
;-------------------------------------------------------------------------------------------
;
; Perform paired t-tests and output to a text file
;
OPENW,1,'/Users/pthorne/Desktop/Mauritius/t-test_results.csv'
PRINTF,1,'Diagnostic,t-test value,t-test significance'
; start with Tx differences between instruments
temp1=data_array[0,*]
temp2=data_array[5,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tx room-thermograph,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[0,*]
temp2=data_array[10,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tx room-stevenson,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[5,*]
temp2=data_array[10,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tx thermograph-stevenson,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
;
; Repeat with Tn
temp1=data_array[1,*]
temp2=data_array[6,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tn room-thermograph,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[1,*]
temp2=data_array[11,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tn room-stevenson,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[6,*]
temp2=data_array[11,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tn thermograph-stevenson,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
;
; Repeat with Ta
temp1=data_array[2,*]
temp2=data_array[7,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Ta room-thermograph,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[2,*]
temp2=data_array[12,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Ta room-stevenson,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[2,*]
temp2=data_array[17,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Ta room-hygrometer,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[7,*]
temp2=data_array[12,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Ta thermograph-stevenson,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[7,*]
temp2=data_array[17,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Ta thermograph-hygrometer,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[12,*]
temp2=data_array[17,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Ta stevenson-hygrometer,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
;
;
; repeat for Tm
temp1=data_array[4,*]
temp2=data_array[9,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tm room-thermograph,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[4,*]
temp2=data_array[14,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tm room-stevenson,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[9,*]
temp2=data_array[14,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tm thermograph-stevenson,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
;
; Perform for Ta-Tm for single instruments
temp1=data_array[2,*]
temp2=data_array[4,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tm-Ta room,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[7,*]
temp2=data_array[9,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tm-Ta thermograph,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)
temp1=data_array[12,*]
temp2=data_array[14,*]
points=WHERE(temp1 NE -999. AND temp2 NE -999.)
Result = TM_TEST(temp1[points],temp2[points],/PAIRED)
PRINTF,1,'Tm-Ta stevenson,'+STRCOMPRESS(STRING(result[0]),/remove_all)+','+STRCOMPRESS(STRING(result[1]),/remove_all)

CLOSE,1
;---------------------------------------------------------------------------------
;
; Write out the Stevenson Screen comparison as a table
;
OPENW,1,'/Users/pthorne/Desktop/Mauritius/ss_comparison_results.csv'
PRINTF,1,'Instrument / month,SS Tx,SS Tn,SS Tm,6ft Tm, 6ft Tn,6ft Tm,Lg Tx, Lg Tn,Lg Tm'
FOR e=99,107 DO BEGIN
  PRINTF,1,STRCOMPRESS(STRING(e-95),/remove_all)+'/'+STRCOMPRESS(STRING(years[e]),/remove_all)+','+$
           STRMID(STRCOMPRESS(STRING(data_array[10,e]),/remove_all),0,4)+','+$
           STRMID(STRCOMPRESS(STRING(data_array[11,e]),/remove_all),0,4)+','+$
           STRMID(STRCOMPRESS(STRING(data_array[13,e]),/remove_all),0,4)+','+$
           STRMID(STRCOMPRESS(STRING(data_array[19,e]),/remove_all),0,4)+','+$
           STRMID(STRCOMPRESS(STRING(data_array[20,e]),/remove_all),0,4)+','+$
           STRMID(STRCOMPRESS(STRING(data_array[22,e]),/remove_all),0,4)+','+$
           STRMID(STRCOMPRESS(STRING(data_array[24,e]),/remove_all),0,4)+','+$
           STRMID(STRCOMPRESS(STRING(data_array[25,e]),/remove_all),0,4)+','+$
           STRMID(STRCOMPRESS(STRING(data_array[27,e]),/remove_all),0,4)
ENDFOR

CLOSE,1

RETURN

END