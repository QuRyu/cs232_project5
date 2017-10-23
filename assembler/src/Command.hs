module Command where

import Data.Tuple (swap)
import Data.Maybe (fromJust)

type Addr = String 
type Val  = String

-- Source and Destination type encoding for move instruction
data SrcM = ACC_MS | LR_MS | LR_L_M | Fill_M deriving (Eq, Show)
data DstM = ACC_MD | LR_MD | ACC_L | ACC_H deriving (Eq, Show)

-- Source and Destination type encoding for binary operator
data SrcA = ACC_AS | LR_AS | IR_L_A | Fill_A deriving (Eq, Show)
data DstA = ACC_AD | LR_AD deriving (Eq, Show)

-- Source type encoding for conditional jump
data SrcB = ACC_BS | LR_B_B deriving (Eq, Show)

-- operation type encoding for binary operations
data Op = Add | Sub | Shift_L | Shift_R | Xor | And | Rotate_L | Rotate_R 
          deriving (Eq, Show)

opTable = [(Add, 000), (Sub, 001), (Shift_L, 010), (Shift_R, 011), 
           (Xor, 100), (And, 101), (Rotate_L, 110), (Rotate_R, 111)]
srcMTable = [(ACC_MS, 00), (LR_MS, 01), (LR_L_M, 10), (Fill_M, 11)]
dstMTable = [(ACC_MD, 00), (LR_MD, 01), (ACC_L, 10), (ACC_H, 11)]
srcATable = [(ACC_AS, 00), (LR_AS, 01), (IR_L_A, 10), (Fill_A, 11)]
dstATable = [(ACC_AD, 0), (LR_AD, 1)]

instance Enum Op where 
    fromEnum = fromJust . flip lookup opTable 
    toEnum   = fromJust . flip lookup (map swap opTable)


instance Enum SrcM where 
    fromEnum = fromJust . flip lookup srcMTable 
    toEnum   = fromJust . flip lookup (map swap srcMTable)

instance Enum DstM where 
    fromEnum = fromJust . flip lookup dstMTable 
    toEnum   = fromJust . flip lookup (map swap dstMTable)


instance Enum SrcA where 
    fromEnum = fromJust . flip lookup srcATable
    toEnum   = fromJust . flip lookup (map swap srcATable)

instance Enum DstA where 
    fromEnum = fromJust . flip lookup dstATable 
    toEnum   = fromJust . flip lookup (map swap dstATable)

instance Enum SrcB where 
    fromEnum ACC_BS = 0 
    fromEnum LR_B_B = 1
    toEnum   0      = ACC_BS
    toEnum   1      = LR_B_B


-- convert each type enconding into binary form
fromEnumS :: (Show a, Eq a, Enum a) => a -> String 
fromEnumS = show . fromEnum


-- type encoding for commands
data Command = Move   SrcM DstM Val        -- move instruction
             | Arith  Op   SrcA DstA Val   -- binary opeartor 
             | Jump   Addr                 -- unconditional jump
             | Branch SrcB Addr            -- conditional jump
                deriving (Eq, Show)
            
