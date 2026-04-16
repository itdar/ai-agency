# demos/multi.tape
# Run: vhs demos/multi.tape  →  imgs/multi.gif
# Scope: interactive launcher → pick PM → pick sub-agents → panes spawn.

Output imgs/multi.gif

Require tmux
Require bash

Set FontSize 13
Set Width 1400
Set Height 820
Set Theme "Dracula"
Set TypingSpeed 55ms
Set PlaybackSpeed 1.0

Hide
Type "export PATH=$PWD/demos/mock:$PATH"
Enter
Type "clear"
Enter
Show

Sleep 500ms
Type "ai-agency"
Sleep 400ms
Enter
Sleep 2.5s

Type "1"
Sleep 300ms
Enter
Sleep 2.2s

Type "2 3 4"
Sleep 300ms
Enter
Sleep 4s

Sleep 18s
