module Main where
import System.Console.Haskeline
import System.Process
import System.Directory
import Control.Exception
import System.IO
import Control.Monad.IO.Class
import Control.Monad
import qualified Run
import qualified Parse


attempt :: IO(Int) -> IO(Int)
attempt act = do
    ret <- try act
    case ret of
        Right x -> return x
        Left ex -> (putStrLn $ show (ex :: SomeException)) >> return 255

myNicePrompt :: Int -> IO ()
myNicePrompt lastret = do
    curdir <- liftM fixSlashes getCurrentDirectory
    putStr curdir
    putStr " ("
    putStr $ show lastret
    putStr ") "
    hFlush stdout
    where fixSlashes str = map (\c -> if c == '\\' then '/' else c) str

reloop :: Int -> InputT IO ()
reloop lastret = do
    liftIO $ myNicePrompt lastret
    curline <- getInputLine ">>= "
    case curline of
        Nothing -> puts' "\nEOF - bye!"
        Just line -> do
            let tokens = words line
            case tokens of
                [] -> reloop lastret
                "exit":_ -> puts' "Exitting - bye!"
                "cd":dirto:[] -> attempt' (setCurrentDirectory dirto >> return 0) >>= reloop
                "cd":_ -> (puts' "'cd' requires exactly 1 argument") >> reloop 255
                _ -> attempt' (Run.runProcesses $ Parse.parseLineIntoProcesses line) >>= reloop
                where attempt' = liftIO . attempt
        where puts' = liftIO . putStrLn

main :: IO ()
main = runInputT defaultSettings (reloop 0)
