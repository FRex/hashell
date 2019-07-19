# Hashell

Small Haskell shell, similar to [FRex/shell](https://github.com/FRex/shell) but
with pipes and in Haskell instead of C. Written for Haskell class back at uni.

```
$ ./dist/build/shell/shell.exe
D:/miscwork/hashell (0) >>= ls
dist  README.md  shell.cabal  src  stack.yaml
D:/miscwork/hashell (0) >>= ls | grep s
dist
shell.cabal
src
stack.yaml
D:/miscwork/hashell (0) >>= ls | grep ^s
shell.cabal
src
stack.yaml
D:/miscwork/hashell (0) >>= cd src
D:/miscwork/hashell/src (0) >>= ls
Main.hs  parse.hs  run.hs
D:/miscwork/hashell/src (0) >>= head -n 5 run.hs
module Run(runProcesses) where
import System.Process
import Control.Monad
import System.Exit
import GHC.IO.Handle (Handle)
D:/miscwork/hashell/src (0) >>= false
D:/miscwork/hashell/src (1) >>= exit
Exitting - bye!
```
