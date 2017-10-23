module Command (Command, 
                command)
       where

import Data.Tuple (swap)
import Data.Maybe (fromJust)
import Data.Char (isDigit)
import Data.Foldable (foldl')

type Addr = String 
type Val  = String
type Src  = String
type Dst  = String 
type Op   = String


opEncod = [("Add", 000), ("Sub", 001), ("Shift_L", 010), ("Shift_R", 011), 
           ("Xor", 100), ("And", 101), ("(Rotate_L", 110), ("Rotate_R", 111)]
srcMEncod = [("ACC", 00), ("LR", 01), ("LR", 10), ("Fill", 11)]
dstMEncod = [("ACC", 00), ("LR", 01), ("ACC", 10), ("ACC", 11)]
srcAEncod = [("ACC", 00), ("LR", 01), ("IR", 10), ("Fill", 11)]
dstAEncod = [("ACC", 0), ("LR", 1)]
srcBEncod = [("ACC", 0), ("LR", 1)]

fstList :: [(a, b)] -> [a]
fstList = map fst 

opTable   = fstList opEncod
srcMTable = fstList srcMEncod
dstMTable = fstList dstMEncod
srcATable = fstList srcAEncod
dstATable = fstList dstAEncod
srcBTable = fstList srcBEncod

-- type encoding for commands
data Command = Move   Src Dst Val        -- move instruction
             | Arith  Op  Src Dst Val   -- binary opeartor 
             | Jump   Addr                 -- unconditional jump
             | Branch Src Addr            -- conditional jump
                deriving (Eq, Show)
            
command :: [String] -> Maybe Command 
command ["Move", src, dst, val] = let x =  elemMaybe src srcMTable >> 
                                           elemMaybe dst dstMTable >> 
                                           isVal     val  
                                  in case x of 
                                       Just _  -> Just $ Move src dst val
                                       Nothing -> Nothing
command ["Jump", addr]         = let x = isAddr addr 
                                 in case x of 
                                         Just _  -> Just $ Jump addr 
                                         Nothing -> Nothing
command ["Branch", src, addr]  = let x = elemMaybe src srcBTable >>
                                         isAddr    addr
                                 in case x of 
                                      Just _  -> Just $ Branch src addr
                                      Nothing -> Nothing 
command [op, src, dst, val]    = let x = elemMaybe op  opTable >>
                                         elemMaybe src srcATable >> 
                                         elemMaybe dst dstATable >>
                                         isVal     val
                                 in case x of 
                                      Just _  -> Just $ Arith op src dst val
                                      Nothing -> Nothing
command _                      = Nothing 

                               

elemMaybe :: (Eq a, Foldable t) => a -> t a -> Maybe a
elemMaybe x xs = if x `elem` xs 
                    then Just x 
                    else Nothing 

isVal :: String -> Maybe String 
isVal s = if length s == 4 && isDigitString s
          then Just "" 
          else Nothing

isAddr = isVal

{-# INLINE isAddr #-}

isDigitString :: String -> Bool
isDigitString = foldl' step True 
    where 
      step False _ = False 
      step True  x = isDigit x

converter :: Command -> String 
converter (Move src dst val) = "00" ++ fromEnumS dst ++ fromEnumS src ++ val
converter (Arith op src dst val) = "01" ++ fromEnumS op ++ fromEnumS src ++ fromEnumS dst
converter (Jump addr)            = "10" ++ "0000" ++ addr
converter (Branch src addr)      = "11" ++ fromEnumS src ++ "000" ++ addr