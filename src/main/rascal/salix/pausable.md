

Internally maintain a "program counter" pc

- beginSession() sets PC = 0
- endSession() : sets PC = -1;
- pause(pc, data): if pc > PC, pops the stack till check point, throws Pause(data)
- beginScope(): checkPoints the render stack


for an interpreter

update()

debugMode(): beginSession(), model.debug = true;

step(): ...



view

eval(stat, pc, model) 

if stat is step && model.debug && stat is breakpoint
    pause(pc, stat.src);


if

