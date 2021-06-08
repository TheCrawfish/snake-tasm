# snake-tasm

## Just a simple game, which called snake, written in assembler (works on DOSBox, compilable in Turbo Assembler + Turbo Linker)

```
  snake [/h] [/l=x] [/a=x] [/r=x] [/d=x] [/c=x] [/w=x]
```

/h - prints help

/l=x - sets snake's length as x

/a=x - sets amount of apples; apples incrase length

/r=x - sets amount of burgers; burgers decrase length

/d=x - sets amount of poison; poison automaticlly game over

/c=x - sets one of intersection modes:
 
 0 - no action
 
 1 - death
 
 2 - cut intersected part

/w=x - sets in which mode will be upper wall

 0 - reflection
 
 1 - death
 
 2 - teleport
 
 3 - random

Standard settings: l=2, a=3, r=1, d=1, c=1, x=1


Game controls:
 
 Num +    incrase speed
 
 Num -    decrase speed
 
 Esc      quit
 
 Space    pause
 
 F1       help
 
 ←,→,↓,↑  movement contols
