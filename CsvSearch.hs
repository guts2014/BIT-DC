-- This program takes a (formatted) query as a command line agument and returns a list of (formatted) lines that match the query
import System.Environment
import Text.JSON.Generic (toJSON)
import Text.CSV (parseCSV)
import Data.List (isInfixOf)
import qualified Data.Map.Lazy as M
import qualified Data.Text as T
import System.IO

main = do
    args <- getArgs
    let query = read $ head args :: [(String, String)]
    
    handle <- openFile "BIGBOOK.csv" ReadMode
    hSetEncoding handle latin1
    contents <- hGetContents handle
    
    let (ts:ls) = lines contents
    let titles = lineToList $ parseCSV "BIGBOOK.csv" ts
    let eithErrCsv = map (parseCSV "BIGBOOK.csv") ls
    
    let tupleLines = map lineToTuple eithErrCsv
    let listLines  = map lineToList  eithErrCsv
    
        -- Big Data Structures
    let tree  = M.fromAscList tupleLines
    let index = indicise titles listLines
    
    print . toJSON $ search titles query listLines


-- toCSV :: Either ParseError CSV -> [(Integer,[String])]
lineToTuple x = case x of
    Left   err   -> (0, ["ERROR"])
    Right (c:cs) -> (read $ head c, c) :: (Integer, [String])

lineToList x = case x of
    Left   err   -> []
    Right (c:cs) -> c :: [String] -- :: [T.Text]


-- Search Functions not using trees

search :: [String] -> [(String, String)] -> [[String]] -> [[String]]
search titles keyWords doc = foldr step [] doc
    where step :: [String] -> [[String]] -> [[String]]
          step entry acc = case matches titles keyWords entry of
                    True  -> entry:acc
                    False -> acc

matches ts keyWords entry = foldr step False $ zip ts entry
    where step (t,e) acc = case lookup t keyWords of
            Just value -> if value `isInfixOf` e
                            then True
                            else acc
            Nothing    ->        acc


-- For both indexing functions the commented types are simplified;
-- the lists actually are M.Maps

-- Titles -> All entries -> [(title, [(word,[line IDs])])]
indicise :: [String] -> [[String]] -> M.Map String (M.Map String [Integer])
indicise titles entries = foldr step M.empty entries
    where step :: [String] -> M.Map String (M.Map String [Integer]) -> M.Map String (M.Map String [Integer])
          step entry acc = M.unionWith (M.unionWith (++)) acc newStuff
            where newStuff :: M.Map String (M.Map String [Integer])
                  newStuff = M.fromList $ zip titles (subIndicise entry)

-- Entry -> [(word, [line IDs])]
subIndicise :: [String] -> [M.Map String [Integer]]
subIndicise entry = foldr step [] entry
    where eID = read $ head entry :: Integer
          step :: String -> [M.Map String [Integer]] -> [M.Map String [Integer]]
          step field acc = newWords:acc
            where newWords :: M.Map String [Integer]
                  newWords = M.fromList $ zip (words field) (repeat [eID])
