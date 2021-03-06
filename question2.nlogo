globals [
  ; total 'living' grass in field A
  grassA-total
  ; total 'living' grass in field B
  grassB-total
  ; total 'living' grass in field C
  grassC-total

  ; record of how many sheep at various points in time
  sheep-history_A
    ; record of how many sheep at various points in time
  sheep-history_B

  ; historical population variation for farmer A's sheep
  sheep-variation_A
  ; historical population variation for farmer A's sheep
  sheep-variation_B

  ; all-time total sheep owned by farmer A
  sheepA-alltime
  ; all-time total sheep owned by farmer B
  sheepB-alltime


  ; all-time total grass count in field A
  grassA-alltime
  ; all-time total grass count in field B
  grassB-alltime
  ; all-time total grass count in field C
  grassC-alltime


  ; x_coordinate of fence between fields A and C
  farm_a_boundary
  ; x_coordinate of fence between fields B and C
  farm_b_boundary
]

breed [ sheep a-sheep ]  ; sheep is its own plural, so we use "a-sheep" as the singular.
breed [ sheep_A a-sheep_A ]
breed [ sheep_B a-sheep_B ]

turtles-own [ energy ]
patches-own [ countdown ]

to setup
  clear-all

  ; start a new 'sheep history' list
  set sheep-history_A []
  set sheep-history_B []

  ; boundaries are set to make all fields the same size
  set farm_a_boundary 30
  set farm_b_boundary 60

  ask patches [

    ; initially, all grass is in 'grown' state
    set pcolor green
    set countdown grass-regrowth-time

    ; draw the boundary between fields A, B, C
    if pxcor = 0 [ set pcolor black ]
    if pxcor = 90[ set pcolor black ]


    if not farmer-b-use-c [
      if pxcor = farm_b_boundary [ set pcolor black ]
    ]
    if not farmer-a-use-c [
      if pxcor = farm_a_boundary [ set pcolor black ]
    ]


  ]

  create-sheep_A initial-sheep-per-farmer  ; create the sheep, then initialize their variables
  [
    set shape  "sheep"
    set color blue
    set size 1.5  ; easier to see
    ; in the original  NetLogo model, a random 'starting health' for each sheep was set. This has been set as a consistent value.
    set energy 1
    setxy random farm_a_boundary random-ycor
  ]

  create-sheep_B initial-sheep-per-farmer  ; create the sheep, then initialize their variables
  [
    set shape  "sheep"
    set color yellow
    set size 1.5  ; easier to see
    ; in the original  NetLogo model, a random 'starting health' for each sheep was set. This has been set as a consistent value.
    set energy 1
    setxy (random farm_a_boundary) + farm_b_boundary random-ycor
  ]

  ;  Count grass in each field
  set grassC-total count patches with [pxcor > farm_b_boundary]
  set grassB-total count patches with [pxcor > farm_a_boundary and pxcor < farm_b_boundary]
  set grassA-total count patches with [pxcor < farm_a_boundary]

  reset-ticks
end

to go

  ask sheep_A [
    move_A
    ; each movement step costs the sheep energy
    set energy energy - 0.1
    eat-grass
    ; if sheep run out of energy, they die
    death
    ; if sheep has sufficient energy, it breeds
    reproduce-sheep A-breed-wait
  ]

  ask sheep_B [
    move_B
    ; each movement step costs the sheep energy
    set energy energy - 0.1
    eat-grass
    ; if sheep run out of energy, they die
    death
    ; if sheep has sufficient energy, it breeds
    reproduce-sheep B-breed-wait
  ]

  ask patches [

    ;; check each time if the boundary conditions have changed
    ifelse farmer-b-use-c
       [if pxcor = farm_b_boundary [ set pcolor green ] ]
       [if pxcor = farm_b_boundary [ set pcolor black ] ]

    ifelse farmer-a-use-c
       [if pxcor = farm_a_boundary [ set pcolor green ] ]
       [if pxcor = farm_a_boundary [ set pcolor black ] ]

    grow-grass
  ]

  ; Count farmer A's sheep (in any field) and add to the all-time total
  set sheepA-alltime sheepA-alltime + count sheep_A

  ; Count farmer A's sheep (in any field)
  set sheepB-alltime sheepB-alltime + count sheep_B



   ; Count field A's grass and add to all-time total
  set grassA-alltime grassA-alltime + grassA-total

  ; Count field B's grass and add to all-time total
  set grassB-alltime grassB-alltime + grassB-total

  ; Count field C's grass and add to all-time total
  set grassC-alltime grassC-alltime + grassC-total

  ; collect data on sheep numbers
  measure-variation

  ; set grass count patches with [pcolor = green]
  tick
end

; move farmer A's sheep
to move_A

    ; move sheep in 'random walk' pattern
    random-walk

    ifelse farmer-a-use-c
    [
      ; if sheep reach the fence, sheep bounce off the fence!
      if xcor > farm_b_boundary [ set xcor farm_b_boundary ]
    ]
    ; if farmer A cannot use field C: stop sheep at the field A boundary
    [
      if xcor > farm_a_boundary [ set xcor farm_a_boundary ]
    ]

  ;; stop 'wrap around' effect for sheep leaving the left field edge
  if xcor < 1 [ set xcor 1]

end

; move farmer B's sheep
to move_B

  ; move sheep in 'random walk' pattern
  random-walk

  ifelse farmer-b-use-c
  [
    ; if sheep reach the fence, sheep bounce off the fence!
    if xcor < farm_a_boundary [ set xcor farm_a_boundary ]
  ]
  ; if farmer B cannot use field C: stop sheep at the field B boundary
  [
     if xcor < farm_b_boundary [ set xcor farm_b_boundary ]
  ]

  ;; stop 'wrap around' effect for sheep leaving the right field edge
  if xcor > 89 [ set xcor 89]

end


; simplest possible pattern to simulate sheep aimlessly walking all over the field
; in this model, sheep do not seek out available grass, they merely 'encounter' it
to random-walk
  rt random -100.100
  fd 1
end


; in the NetLogo example model, the user could set the amount of energy a sheep gained from eating the grass.
; this was decided to add unnecessary complexity, because the user is already choosing the threshhold level at
; which the sheep have accumulated enough energy to reproduce. For example, the model should behave the same
; if the grass adds 1 energy to reach a threshhold of 10, or if grass adds 2 energy to reach a threshhold of 20.
; Also, measuring the 'varying quality of grass' is not relevant to the model: what is being modelled is the effects
; of *area* and the effect of *shared vs seperate* areas on sheep numbers, not the effect of grass quality.
to eat-grass  ; sheep procedure
  ; sheep eat grass, turn the patch brown
  if pcolor = green [
    set pcolor brown
    set energy energy + 1 ; sheep gain energy by eating
  ]
end

; in the NetLogo example model a 'random dice' mechanism was used to determine when sheep would reproduce.
; this was decided to add unecessary complexity and 'noise' to the model without increasing the realism of the model.
; in this model, sheep simply reproduce when they reach a certain energy level.
to reproduce-sheep [breed-wait]
  if energy > breed-wait [
    set energy (energy / 2)    ; divide energy between parent and offspring
    hatch 1                    ; hatch an offspring
  ]
end

to death
  ; if energy below zero, sheep dies
  if energy < 0 [ die ]
end

to grow-grass  ; patch procedure
  ; countdown on brown patches: if reach 0, grow some grass
  if pcolor = brown [
    ifelse countdown <= 0
      [ set pcolor green
        set countdown grass-regrowth-time ]
      [ set countdown countdown - 1 ]
  ]
end

; updates data on historical sheep levels (to measure population variance over time)
to measure-variation

  ;count sheep
  let sheep-a-current count sheep_A
  let sheep-b-current count sheep_B

  ;add the count to the list of all-time counts
  set sheep-history_A lput sheep-a-current sheep-history_A
  set sheep-history_B lput sheep-b-current sheep-history_B

  ; if the 'variation' period is up:
  ; a) make changes to the breeding rate
  ; b) reset the sheep tallies to measure sheep variation in the most immediate 'time interval' only
  if ticks mod tally-interval = 0 and ticks != 0  [
    set sheep-history_A []
    set sheep-history_B []
  ]

end

to-report grass
  report patches with [pcolor = green]
end

to-report grassA
  report patches with [pcolor = green and pxcor < farm_a_boundary]
end

to-report grassC
  report patches with [pcolor = green and  pxcor > farm_a_boundary and pxcor < farm_b_boundary]
end

to-report grassB
  report patches with [pcolor = green and pxcor > farm_b_boundary]
end

;; calculate all-time averages of sheep numbers: useful if graphs are highly fluctuating
to-report sheepA-avg
  report precision ( sheepA-alltime / ticks) 1
end

to-report sheepB-avg
  report precision (sheepB-alltime / ticks) 1
end

;to-report grassC-alltimeavg
;  report precision (grass-alltime / ticks) 1
;end





;; report the percentage of grass remaining
to-report grassA-percent
  report precision ((count grassA / grassA-total) * 100) 1
end

to-report grassB-percent
  report precision ((count grassB / grassB-total) * 100) 1
end

to-report grassC-percent
  report precision ((count grassC / grassC-total) * 100) 1
end
@#$#@#$#@
GRAPHICS-WINDOW
220
10
1138
529
-1
-1
10.0
1
14
1
1
1
0
1
1
1
0
90
0
50
1
1
1
ticks
30.0

SLIDER
10
155
215
188
grass-regrowth-time
grass-regrowth-time
0
100
50.0
1
1
NIL
HORIZONTAL

PLOT
1145
15
1360
330
sheeps
time
pop.
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"sheep_A" 1.0 0 -13345367 true "" "plot count sheep_A"
"sheep_B" 1.0 0 -4079321 true "" "plot count sheep_B"

MONITOR
10
275
100
320
sheep A
count sheep_A
3
1
11

PLOT
10
535
455
805
grass
NIL
NIL
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"grass A" 1.0 0 -13345367 true "" "plot grassA-percent"
"grass B" 1.0 0 -4079321 true "" "plot grassB-percent"
"grass C" 1.0 0 -7500403 true "" "plot grassC-percent"

SWITCH
10
120
162
153
farmer-a-use-c
farmer-a-use-c
1
1
-1000

TEXTBOX
310
30
460
61
Farm A
25
0.0
1

TEXTBOX
955
30
1105
61
Farm B
25
0.0
1

TEXTBOX
630
30
780
61
Farm C
25
130.0
1

MONITOR
115
275
215
320
sheep B
count sheep_B
17
1
11

BUTTON
10
495
72
528
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
90
495
153
528
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

SWITCH
10
85
162
118
farmer-b-use-c
farmer-b-use-c
1
1
-1000

SLIDER
10
10
212
43
initial-sheep-per-farmer
initial-sheep-per-farmer
0
100
10.0
1
1
NIL
HORIZONTAL

MONITOR
1155
430
1227
475
Grass A %
grassA-percent
17
1
11

MONITOR
1225
430
1297
475
Grass C %
grassC-percent
17
1
11

MONITOR
1295
430
1362
475
Grass B %
grassB-percent
17
1
11

SLIDER
0
195
202
228
B-breed-wait
B-breed-wait
0
200
100.0
1
1
NIL
HORIZONTAL

SLIDER
0
235
207
268
A-breed-wait
A-breed-wait
0
200
100.0
1
1
NIL
HORIZONTAL

MONITOR
1150
335
1252
380
NIL
sheepA-avg
17
1
11

MONITOR
1255
335
1337
380
NIL
sheepB-avg
17
1
11

SWITCH
10
50
177
83
auto-stock-mgmt
auto-stock-mgmt
1
1
-1000

SLIDER
1150
490
1322
523
tally-interval
tally-interval
1
1000
500.0
1
1
NIL
HORIZONTAL

MONITOR
1155
535
1232
580
A-variance
variance sheep-history_A
5
1
11

MONITOR
1240
535
1317
580
B-variance
variance sheep-history_B
5
1
11

PLOT
1155
590
1355
740
Variance
time
variance
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -14070903 true "" "plot variance sheep-history_A"
"pen-1" 1.0 0 -1184463 true "" "plot variance sheep-history_B"

@#$#@#$#@
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
NetLogo 6.0.4
@#$#@#$#@
set model-version "sheep-wolves-grass"
set show-energy? false
setup
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
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
1
@#$#@#$#@
