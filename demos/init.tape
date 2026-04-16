# demos/init.tape
# Run: vhs demos/init.tape  →  imgs/init.gif
# Scope: quick `ai-agency init` → scaffold → validate, no real AI calls.

Output imgs/init.gif

Set FontSize 15
Set Width 1200
Set Height 720
Set Theme "Dracula"
Set TypingSpeed 45ms
Set PlaybackSpeed 1.0

Hide
Type "export PATH=$PWD/demos/mock:$PATH"
Enter
Type "SANDBOX=$(bash demos/mock/init-sandbox.sh) && cd $SANDBOX"
Enter
Type "clear"
Enter
Show

Sleep 600ms
Type "ai-agency init"
Sleep 400ms
Enter
Sleep 7s

Type "tree -L 2 .ai-agents 2>/dev/null || find .ai-agents -maxdepth 2 | sort"
Sleep 300ms
Enter
Sleep 2s

Type "head -14 AGENTS.md"
Sleep 300ms
Enter
Sleep 3s

Sleep 1s
