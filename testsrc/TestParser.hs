{-
Copyright (C) 2002-2008 John Goerzen <jgoerzen@complete.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-}
module TestParser where
import qualified Data.Map as Map
import Data.List
import qualified Test.HUnit as HU
import Test.HUnit.Utils
import Data.Word
import Test.QuickCheck
import TestInfrastructure

import Network.IMAP.Parser
import Network.IMAP.Connection
import Network.IMAP.Types

import TestInfrastructure
import TestConnection(expectedString, noCR)

prop_getFullLine_basic :: [String] -> Property
prop_getFullLine_basic s =
    (null s || not ("}" `isSuffixOf` (head s))) && noCR s ==>
        runLinesConnection s (getFullLine []) @?= 
            if null s
               then Left "EOF in input in readLine"
               else Right (head s, (expectedString (tail s), []))

prop_getFullLine_count :: [String] -> Property
prop_getFullLine_count s =
    length s >= 2 && noCR s && (length s < 3 || not ("}" `isSuffixOf` (s !! 2)))
           ==> 
           runLinesConnection lenS (getFullLine []) @?=
                              Right (expectedResult, (expectedRemain, []))
    where lenS = [braceString] ++ [(head . tail $ s)] ++ drop 2 s
          braceString = head s ++ "{" ++ show (length (s !! 1)) ++ "}"
          expectedResult = braceString ++ "\r\n" ++ (s !! 1)
          expectedRemain = expectedString (drop 2 s)

allt = [q "getFullLine_basic" prop_getFullLine_basic,
        q "getFullLine_count" prop_getFullLine_count
       ]