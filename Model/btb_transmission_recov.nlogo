globals[sus_h
  sus_a
  exp_h
  exp_a
  inf_h
  inf_a
  total_h
  total_a
  sus_h_agent
  sus_a_agent
  exp_h_agent
  exp_a_agent
  inf_h_agent
  inf_a_agent
  d
  r0
  a_size
  xlim
  border
  g_decay
  g_production
  g_change

  inf_rate_HH
  inf_rate_AH
  inf_rate_DH
  rate_h
  change_h
  mean_E_to_I
]

breed [humans human]
breed [animals animal]
breed [diarys diary]

humans-own[status]
animals-own[status]
diarys-own[status]

to setup
  no-display
  ca
  reset-ticks


  ;declare global size and location values
  set a_size 2
  set xlim 20
  set border 100


  ;create the initial population of animals and move them to their location
  create-animals Init_Animal [
    ;set size a_size
    ;set shape "cow"
    ;set color blue
    set status "Susceptible"
    ;setxy xlim + random (border - xlim) random border * 2 - border
]

  ;ask animals[
  ;  while [any? other turtles-here]
  ;  [setxy xlim + random (border - xlim) random border * 2 - border   ]
  ;]


  ;create the initail population of humans and move them to their location
  create-humans Init_Human [
    ;set size a_size
    ;set shape "person"
    ;set color blue
    set status "Susceptible"
    ;setxy -1 * xlim - random (border - xlim) random border * 2 - border
 ]

  ;ask humans[
  ;  while [any? other turtles-here]
  ;  [setxy -1 * xlim - random (border - xlim) random border * 2 - border]
  ;]


  ;create initial population of diary products and move them to their location
  create-diarys init_diary[

   set size a_size
   set shape "box"
   set color red

    setxy 10 - random 20 random border * 2 - border
    set status "NA"

  ]

  ask diarys[
    while [any? other turtles-here]
    [setxy 10 - random 20 random border * 2 - border]
  ]

  set sus_h_agent humans with [status =  "Susceptible"]
  set sus_a_agent animals with [status =  "Susceptible"]

  set exp_h_agent humans with [status =  "Exposed"]
  set exp_a_agent animals with [status =  "Exposed"]
  set inf_h_agent humans with [status =  "Infected"]
  set inf_a_agent animals with [status =  "Infected"]


  ;All agents except for diary starts with the status set to "Susceptible"
  ;This code turns n amount of them into "Exposed" and "Infected" according to gui controlls
  ask n-of Initial_Exposed_Animal sus_a_agent[
    set status "Exposed"    ]
  ask n-of Initial_Exposed_Human sus_h_agent[
    set status "Exposed"    ]
  ask n-of Initial_Infected_Animal sus_a_agent[
    set status "Infected"    ]
  ask n-of Initial_Infected_Human sus_h_agent[
    set status "Infected"    ]



  ;helper functions,
  ;colors agents acording to their status
  ;Susceptible = Blue
  ;Exposed = Yellow
  ;Infected = Red
  ;color-agent
  ;updates the global counts of susceptible exposed and infected animals and humans
  update-globals


  ;out_setup_sus_debug

end






to go
  tick

  pop_gain
  ;;show " pop gain done"

  sus_to_exp_H
  ;show " sus to exp human done"
  sus_to_exp_A
  ;show " sus to exp animal done"
  sus_death
  ;show " sus death done"
  exp_to_inf_H
  ;show " exp to inf Human done"
  exp_to_inf_A
  ;show " exp to inf animal done"
  inf_death_H
  ;show " inf to death done H"
  inf_death_A
  ;show " inf to death done A"
  diary-change
  ;show " dairy change done"
  ;out
  ;color-agent
  update-globals
  ;show " update globas done"


end



to pop_gain


  create-animals Lambda_A[
    ;set size a_size
    ;set shape "cow"
    set status "Susceptible"
    ;setxy xlim + random (border - xlim) random border * 2 - border

  ]
  ;ask animals[
  ;  while [any? other turtles-here]
  ;  [setxy  xlim + random (border - xlim) random border * 2 - border  ]
  ;]

    create-humans Lambda_H [
    ;set size a_size
    ;set shape "person"
    set status "Susceptible"
    ;setxy -1 * xlim - random (border - xlim) random border * 2 - border
 ]

 ; ask humans[
 ;   while [any? other turtles-here]
 ;   [setxy -1 * xlim - random (border - xlim) random border * 2 - border]
 ; ]



end

to sus_death
  ;show "sus_death"

  let mort_h floor  sus_h * Mu_H
  ;;show mort_h

  ask n-of mort_h sus_h_agent [ die]

  let mort_a floor sus_a * Mu_A
  ;;show mort_a

  ask n-of mort_a sus_a_agent [ die]


end


to sus_to_exp_H

  set inf_rate_HH  Beta1 * inf_h
  set inf_rate_AH  Beta2 * inf_a
  set inf_rate_DH  Beta3 * d

  set rate_h (inf_rate_HH + inf_rate_AH + inf_rate_DH) / total_h

  if rate_h > 1 [ set rate_h 1]

  set change_h  floor (rate_h * sus_h)



  ask n-of change_h sus_h_agent
    [
      set status "Exposed"
    ]



end

to sus_to_exp_A

  let inf_rate_H  Beta4 * inf_h
  let inf_rate_A  Beta5 * inf_a
  let inf_rate_D  Beta6 * d

  let total count animals

  let rate (inf_rate_H + inf_rate_A + inf_rate_D) / total
  if rate > 1 [ set rate 1]

  let change floor (rate * sus_a)


  ask n-of change sus_a_agent
  [
   set status "Exposed"
  ]

end



to exp_to_inf_H


  let mort floor (Mu_H * exp_H)

  let inf_rate floor (Gamma_H * exp_H)

  ask n-of mort exp_h_agent
    [die]

  ask n-of inf_rate exp_h_agent
  [
    set status "Infected"]


end

to exp_to_inf_A


  let mort floor (Mu_A * exp_a)

  let inf_rate floor (Gamma_A * exp_a)

  ask n-of mort exp_a_agent
    [die]

  ask n-of inf_rate exp_a_agent
  [
    set status "Infected"]

  set mean_E_to_I mean_E_to_I + inf_rate

end


to inf_death_H

  let mort Mu_H + Alpha_H

  let change floor (mort * inf_h)

  ask n-of change inf_h_agent
  [die]



end


to inf_death_A

  let mort Mu_A + Alpha_A

  let change floor (mort * inf_a)

  ask n-of change inf_a_agent
  [die]



end

to diary-change

  let production Rho * inf_a
  let decay Omega * d




  let change floor (production - decay)

  ;show change



  set g_production production
  set g_decay decay
  set g_change change



  if change > 0
  [create-diarys change[

    set size a_size
    set shape "box"
    set color red

    setxy 10 - random 20 random border * 2 - border
    set status "NA" ]]

   if change < 0
   [ ask n-of (change * -1) diarys [die]]

  ;  ask diarys[
  ;    while [any? other turtles-here]
  ;    [setxy 10 - random 20  random border * 2 - border]




end


to color-agent

  ask turtles[

    if status = "Susceptible"
    [set color blue]

    if status = "Exposed"
    [set color yellow]

    if status = "Infected"
    [set color red]

  ]
end

to update-globals

  set sus_h_agent humans with [status =  "Susceptible"]
  set sus_a_agent animals with [status =  "Susceptible"]

  set exp_h_agent humans with [status =  "Exposed"]
  set exp_a_agent animals with [status =  "Exposed"]
  set inf_h_agent humans with [status =  "Infected"]
  set inf_a_agent animals with [status =  "Infected"]

  set sus_h  count sus_h_agent

  set exp_h count exp_h_agent

  set inf_h count inf_h_agent

  set sus_a count sus_a_agent

  set exp_a count exp_a_agent

  set inf_a count inf_a_agent


  set total_h count humans
  set total_a count animals

  set d count diarys


end





to out_setup

  if (file-exists? "tb_diary_Test.csv")
  [
    carefully
        [file-delete "tb_diary_Test.csv"]
        [print error-message]
  ]

  file-open "tb_diary_Test.csv"
  file-type "tick,"
  file-type "inf_a,"
  file-type "d,"
  file-type "production,"
  file-type "decay,"
  file-type "change\n"
  file-close
end

to out_setup_sus_debug

  if (file-exists? "tb_diary_Test.csv")
  [
    carefully
        [file-delete "tb_diary_Test.csv"]
        [print error-message]
  ]

  file-open "tb_diary_Test.csv"
  file-type "tick,"
  file-type "Lambda_H,"
  file-type "Mu_H,"
  file-type "sus_h,"
  file-type "Beta1,"
  file-type "inf_h,"
  file-type "inf_rate_H,"
  file-type "Beta2,"
  file-type "inf_a,"
  file-type "inf_rate_A,"
  file-type "Beta3,"
  file-type "d,"
  file-type "inf_rate_D,"
  file-type "rate,"
  file-type "total_h,"
  file-type "change\n"
  file-close
end









to out



  file-open "tb_diary_Test.csv"

  file-type (word ticks ",")
  file-type (word Lambda_H ",")
  file-type (word Mu_H ",")
  file-type (word sus_h ",")
  file-type (word Beta1 ",")
  file-type (word inf_h ",")
  file-type (word inf_rate_HH ",")
  file-type (word Beta2 ",")
  file-type (word inf_a ",")
  file-type (word inf_rate_AH ",")
  file-type (word Beta3 ",")
  file-type (word d ",")
  file-type (word inf_rate_DH ",")
  file-type (word rate_h ",")
  file-type (word total_h ",")
  file-type (word change_h ",")

  file-print ""


  file-close



end
@#$#@#$#@
GRAPHICS-WINDOW
650
10
1462
823
-1
-1
4.0
1
10
1
1
1
0
1
1
1
-100
100
-100
100
0
0
1
ticks
30.0

BUTTON
0
10
63
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
0
42
63
75
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
0
75
63
108
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
85
10
257
43
Lambda_H
Lambda_H
0
100
36.0
1
1
NIL
HORIZONTAL

SLIDER
85
41
257
74
Mu_H
Mu_H
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
85
73
257
106
Gamma_H
Gamma_H
0
0.5
0.18
0.01
1
NIL
HORIZONTAL

SLIDER
85
105
257
138
Alpha_H
Alpha_H
0
0.3
0.14
0.01
1
NIL
HORIZONTAL

SLIDER
86
170
259
203
Beta1
Beta1
0
1
0.35
0.01
1
NIL
HORIZONTAL

SLIDER
86
201
259
234
Beta2
Beta2
0
1
0.55
0.01
1
NIL
HORIZONTAL

SLIDER
86
233
259
266
Beta3
Beta3
0
1
0.99
0.01
1
NIL
HORIZONTAL

SLIDER
290
10
463
43
Lambda_A
Lambda_A
0
400
200.0
1
1
NIL
HORIZONTAL

SLIDER
290
41
463
74
Mu_A
Mu_A
0
1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
290
75
463
108
Gamma_A
Gamma_A
0
0.5
0.18
0.01
1
NIL
HORIZONTAL

SLIDER
290
109
463
142
Alpha_A
Alpha_A
0
0.3
0.03
0.01
1
NIL
HORIZONTAL

SLIDER
289
165
462
198
Beta4
Beta4
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
289
200
462
233
Beta5
Beta5
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
289
235
462
268
Beta6
Beta6
0
1
0.34
0.01
1
NIL
HORIZONTAL

SLIDER
472
11
645
44
Rho
Rho
0
1
0.69
0.01
1
NIL
HORIZONTAL

SLIDER
472
44
645
77
Omega
Omega
0
1
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
84
322
257
355
Init_Human
Init_Human
0
1000000
500.0
50
1
NIL
HORIZONTAL

SLIDER
290
324
463
357
Init_Animal
Init_Animal
0
1000000
550.0
50
1
NIL
HORIZONTAL

SLIDER
83
365
256
398
Initial_Exposed_Human
Initial_Exposed_Human
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
85
410
258
443
Initial_Infected_Human
Initial_Infected_Human
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
291
365
464
398
Initial_Exposed_Animal
Initial_Exposed_Animal
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
290
414
463
447
Initial_Infected_Animal
Initial_Infected_Animal
0
100
1.0
1
1
NIL
HORIZONTAL

MONITOR
87
464
145
509
NIL
sus_h
17
1
11

MONITOR
142
464
200
509
NIL
exp_h
17
1
11

MONITOR
197
464
255
509
NIL
inf_h
17
1
11

MONITOR
289
464
347
509
NIL
sus_a
17
1
11

MONITOR
344
464
402
509
NIL
exp_a
17
1
11

MONITOR
400
465
458
510
NIL
inf_a
17
1
11

SLIDER
474
327
647
360
Init_Diary
Init_Diary
0
30
1.0
1
1
NIL
HORIZONTAL

MONITOR
482
370
540
415
Diary
d
17
1
11

PLOT
7
569
622
828
Animal population change over time
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Susceptibel" 1.0 0 -10899396 true "" "plot sus_a"
"Exposed" 1.0 0 -13345367 true "" "plot exp_a"
"Infected" 1.0 0 -2674135 true "" "plot inf_a"
"pen-3" 1.0 0 -1184463 true "" "plot d"

BUTTON
16
507
79
540
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
123
526
231
559
NIL
repeat 30 [go]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
17
466
80
499
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
497
173
587
218
NIL
count animals
17
1
11

MONITOR
494
224
589
269
NIL
count humans
17
1
11

MONITOR
479
519
605
564
NIL
mean_E_to_I / ticks
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Rho_sensitivity_analysis" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>inf_a</metric>
    <metric>mean_E_to_I / ticks</metric>
    <metric>count animals</metric>
    <steppedValueSet variable="Rho" first="0.345" step="0.03275" last="1"/>
  </experiment>
  <experiment name="Omega_sensitivity" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>count animals</metric>
    <metric>inf_a</metric>
    <metric>mean_E_to_I / ticks</metric>
    <steppedValueSet variable="Omega" first="0.2" step="0.02" last="0.6"/>
  </experiment>
  <experiment name="beta6_sensitivity" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>inf_a</metric>
    <metric>mean_E_to_I / ticks</metric>
    <metric>count animals</metric>
    <steppedValueSet variable="Beta6" first="0.17" step="0.017" last="0.51"/>
  </experiment>
  <experiment name="beta4_sensitivity" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>inf_a</metric>
    <metric>mean_E_to_I / ticks</metric>
    <metric>count animals</metric>
    <steppedValueSet variable="Beta4" first="0.125" step="0.0125" last="0.375"/>
  </experiment>
  <experiment name="beta5_sensitivity" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>inf_a</metric>
    <metric>mean_E_to_I / ticks</metric>
    <metric>count animals</metric>
    <steppedValueSet variable="Beta5" first="0.3" step="0.03" last="0.9"/>
  </experiment>
  <experiment name="Alpha_A_Sensitivity" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>inf_a</metric>
    <metric>mean_E_to_I / ticks</metric>
    <metric>count animals</metric>
    <steppedValueSet variable="Alpha_A" first="0.015" step="0.0015" last="0.1"/>
  </experiment>
  <experiment name="beta1_sensitivity" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>inf_a</metric>
    <metric>mean_E_to_I / ticks</metric>
    <metric>count animals</metric>
    <steppedValueSet variable="Beta1" first="0.175" step="0.0175" last="0.525"/>
  </experiment>
  <experiment name="beta2_sensitivity" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>inf_a</metric>
    <metric>mean_E_to_I / ticks</metric>
    <metric>count animals</metric>
    <steppedValueSet variable="Beta2" first="0.275" step="0.0275" last="0.825"/>
  </experiment>
  <experiment name="beta3_sensitivity" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>inf_a</metric>
    <metric>mean_E_to_I / ticks</metric>
    <metric>count animals</metric>
    <steppedValueSet variable="Beta3" first="0.4995" step="0.025025" last="1"/>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>inf_h</metric>
    <metric>inf_a</metric>
    <enumeratedValueSet variable="Initial_Infected_Human">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Mu_A">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Init_Animal">
      <value value="550"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Init_Diary">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Gamma_H">
      <value value="0.18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Initial_Exposed_Human">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Beta1">
      <value value="0.35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Gamma_A">
      <value value="0.18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Beta2">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Alpha_H">
      <value value="0.14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Init_Human">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Beta3">
      <value value="0.99"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Initial_Exposed_Animal">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Alpha_A">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Beta4">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Initial_Infected_Animal">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Rho">
      <value value="0.69"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Lambda_A">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Beta5">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Lambda_H">
      <value value="36"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Mu_H">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Beta6">
      <value value="0.34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Omega">
      <value value="0.4"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
