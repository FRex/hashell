module Parse (parseLineIntoProcesses) where
import System.Process


groupByPipes :: [String] -> [[String]]
groupByPipes [] = [[]]
groupByPipes lst = 
    if "|" `elem` lst
    then
        let cur = takeWhile (/= "|") lst
            rst = drop (1 + length cur) lst
        in [cur] ++ groupByPipes rst
    else [lst]

parseLineIntoProcesses :: String -> [CreateProcess]
parseLineIntoProcesses line = 
    let tokens = words line
        groups = groupByPipes tokens
    in map (\(x:xs) -> proc x xs) groups
