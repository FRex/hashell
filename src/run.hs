module Run(runProcesses) where
import System.Process
import Control.Monad
import System.Exit
import GHC.IO.Handle (Handle)


makePipes :: Int -> IO([(Handle, Handle)])
makePipes n = mapM (\_ -> createPipe) [1..n]

adjustPipes :: [(Handle, Handle)] -> [(StdStream, StdStream)]
adjustPipes pipes =
    let flat = flatten pipes
        handles = [Inherit] ++ map (\h -> UseHandle h) flat ++ [Inherit]
    in pairUp handles
    where
        flatten [] = []
        flatten (x:xs) = (snd x):(fst x):(flatten xs)
        pairUp [] = []
        pairUp (a:b:rst) = (a, b):(pairUp rst)

replaceInOut :: [CreateProcess] -> [(StdStream, StdStream)] -> [CreateProcess]
replaceInOut [] [] = []
replaceInOut (p:ps) (s:ss) = (p {std_in = fst s, std_out = snd s}):(replaceInOut ps ss)

runProcesses :: [CreateProcess] -> IO(Int)
runProcesses [] = do return 0
runProcesses (ps:[]) = do
    (_, _, _, phandle) <- createProcess ps
    ecode <- waitForProcess phandle
    case ecode of
        ExitSuccess -> return 0
        ExitFailure ret -> return ret
runProcesses ps = do
    pipes <- liftM adjustPipes $ makePipes $ (length ps) - 1
    let procs = replaceInOut ps pipes
    handles <- liftM (map (\(_, _, _, h) -> h)) $ mapM createProcess procs
    ecode <- liftM last $ mapM waitForProcess handles
    case ecode of
        ExitSuccess -> return 0
        ExitFailure ret -> return ret
