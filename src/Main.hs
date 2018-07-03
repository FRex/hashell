module Main where
import System.Console.Haskeline
import System.Process
import System.Exit
import System.Directory
import Control.Exception
import System.Console.ANSI
import System.IO
import Control.Monad.IO.Class
import Control.Monad
import qualified Run
import qualified Parse


tokenize :: String -> [String]
tokenize line = words line

execute :: [String] -> IO(Int)
execute (cmd:args) = do
    let pr = proc cmd args
    (_, _, _, phandle) <- createProcess pr
    ecode <- waitForProcess phandle
    case ecode of
        ExitSuccess -> return 0
        ExitFailure ret -> return ret

attempt :: IO(Int) -> IO(Int)
attempt act = do
    ret <- try act
    case ret of
        Right x -> return x
        Left ex -> (putStrLn $ show (ex :: SomeException)) >> return 255

fixSlashes :: String -> String
fixSlashes str = map (\c -> if c == '\\' then '/' else c) str

myNicePrompt :: Int -> IO ()
myNicePrompt lastret = do
    curdir <- liftM fixSlashes getCurrentDirectory
    putStr curdir
    putStr " ("
    --setSGR [SetColor Foreground Vivid (if (lastret == 0) then Green else Red)]
    putStr $ show lastret
    --setSGR []
    putStr ") "
    hFlush stdout

reloop :: Int -> InputT IO ()
reloop lastret = do
    liftIO $ myNicePrompt lastret
    curline <- getInputLine ">>= "
    case curline of
        Nothing -> liftIO $ putStrLn "\nEOF - bye!"
        Just line -> do
            let tokens = tokenize line
            case tokens of
                [] -> reloop lastret
                "exit":_ -> liftIO $ putStrLn "Exitting - bye!"
                "cd":dirto:[] -> attempt' (setCurrentDirectory dirto >> return 0) >>= reloop
                "cd":_ -> (liftIO $ putStrLn "'cd' requires exactly 1 argument") >> reloop 255
                _ -> attempt' (execute tokens) >>= reloop

                where attempt' = liftIO . attempt

main :: IO ()
main = runInputT defaultSettings (reloop 0)
