#!/bin/bash
#----------------------------------------
#Put your program name in place of "DEMO"
name='BOSSHELL.8xp'
#----------------------------------------

mkdir "bin" || echo ""

echo "compiling to $name"
~/CEdev/bin/fasmg src/bos.asm bin/$name
echo $name
echo "Wrote binary to $name."

read -p "Finished. Press any key to exit"
