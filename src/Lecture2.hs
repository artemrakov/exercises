{- |
Module                  : Lecture2
Copyright               : (c) 2021-2022 Haskell Beginners 2022 Course
SPDX-License-Identifier : MPL-2.0
Maintainer              : Haskell Beginners 2022 Course <haskell.beginners2022@gmail.com>
Stability               : Stable
Portability             : Portable

Exercises for the Lecture 2 of the Haskell Beginners course.

As in the previous section, implement functions and provide type
signatures. If the type signature is not already written, write the
most polymorphic type signature you can.

Unlike exercises to Lecture 1, this module also contains more
challenging exercises. You don't need to solve them to finish the
course but you can if you like challenges :)
-}

module Lecture2
    ( -- * Normal
      lazyProduct
    , duplicate
    , removeAt
    , evenLists
    , dropSpaces

    , Knight (..) , dragonFight
      -- * Hard
    , isIncreasing
    , merge
    , mergeSort

    , Expr (..)
    , Variables
    , EvalError (..)
    , eval
    , constantFolding
    ) where

import Data.Char (isSpace)
{- | Implement a function that finds a product of all the numbers in
the list. But implement a lazier version of this function: if you see
zero, you can stop calculating product and return 0 immediately.

>>> lazyProduct [4, 3, 7]
84
-}
lazyProduct :: [Int] -> Int
lazyProduct = helper 1
  where
    helper _ (0:_) = 0
    helper acc [] = acc
    helper acc (x:xs) = helper (acc * x) xs

{- | Implement a function that duplicates every element in the list.

>>> duplicate [3, 1, 2]
[3,3,1,1,2,2]
>>> duplicate "cab"
"ccaabb"
-}
duplicate :: [a] -> [a]
duplicate = foldr (\x acc -> x : x : acc) []

{- | Implement function that takes index and a list and removes the
element at the given position. Additionally, this function should also
return the removed element.

>>> removeAt 0 [1 .. 5]
(Just 1,[2,3,4,5])

>>> removeAt 10 [1 .. 5]
(Nothing,[1,2,3,4,5])
-}
-- removeAt :: Int -> [a] -> (Maybe a, [a])
-- removeAt index xs | index < 0 = (Nothing, xs)
--                   | index > (size - 1) = (Nothing, xs)
--                   | otherwise = (Just $ xs !! index, take index xs ++ drop (index + 1) xs)
--     where
--       size = length xs

removeAt :: Int -> [a] -> (Maybe a, [a])
removeAt = helper []
  where
    helper rest _ [] = (Nothing, rest)
    helper rest index list@(x:xs) | index < 0 = (Nothing, rest ++ list)
                                  | index == 0 = (Just x, rest ++ xs)
                                  | otherwise = helper (rest ++ [x]) (index - 1) xs

{- | Write a function that takes a list of lists and returns only
lists of even lengths.

>>> evenLists [[1,2,3], [3,1,2,7], [], [5, 7, 2]]
[[3,1,2,7],[]]

♫ NOTE: Use eta-reduction and function composition (the dot (.) operator)
  in this function.
-}
evenLists :: [[a]] -> [[a]]
evenLists = filter $ even . length

{- | The @dropSpaces@ function takes a string containing a single word
or number surrounded by spaces and removes all leading and trailing
spaces.

>>> dropSpaces "   hello  "
"hello"
>>> dropSpaces "-200            "
"-200"

♫ NOTE: As in the previous task, use eta-reduction and function
  composition (the dot (.) operator) in this function.

🕯 HINT: look into Data.Char and Prelude modules for functions you may use.
-}
dropSpaces :: String -> String
dropSpaces = takeWhile (not . isSpace) . dropWhile isSpace

{- |

The next task requires to create several data types and functions to
model the given situation.

An evil dragon attacked a village of innocent citizens! After
returning to its lair, the dragon became hungry and ate one of its
treasure chests by accident.

The guild in the village found a brave knight to slay the dragon!
As a reward, the knight can take the treasure chest.

Below is the description of the fight and character specifications:

  * A chest contains a non-zero amount of gold and a possible treasure.
    When defining the type of a treasure chest, you don't know what
    treasures it stores insight, so your chest data type must be able
    to contain any possible treasure.
  * As a reward, knight takes all the gold, the treasure and experience.
  * Experience is calculated based on the dragon type. A dragon can be
    either red, black or green.
  * Red dragons grant 100 experience points, black dragons — 150, and green — 250.
  * Stomachs of green dragons contain extreme acid and they melt any
    treasure except gold. So green dragons has only gold as reward.
    All other dragons always contain treasure in addition to gold.
  * Knight tries to slay dragon with their sword. Each sword strike
    decreases dragon health by the "sword attack" amount. When the
    dragon health becomes zero or less, a dragon dies and the knight
    takes the reward.
  * After each 10 sword strikes, dragon breathes fire and decreases
    knight health by the amount of "dragon fire power". If the
    knight's health becomes 0 or less, the knight dies.
  * Additionally, each sword strike decreases "knight's endurance" by one.
    If knight's endurance becomes zero, they become tired and are not
    able to continue the fight so they run away.

Implement data types to describe treasure, knight and dragon.
And implement a function that takes a knight and a dragon and returns
one of the three possible fight outcomes.

You're free to define any helper functions.

🕯 HINT: If you find the description overwhelming to implement entirely
  from scratch, try modelling the problem in stages.

    1. Implement all custom data types without using polymorphism.
    2. Add @newtype@s for safety where you think is appropriate.
    3. Encode the fight result as a sum type.
    4. Add polymorphism.
    5. Make all invalid states unrepresentable. Think, how you can
       change your types to prevent green dragons from having any
       treasure besides gold (if you already haven't done this).
-}

-- some help in the beginning ;)

data Chest a = Chest
    { chestGold :: Int
    , chestTreasure :: a
    } deriving (Show)

data DragonType = Red | Black | Green deriving (Show)
data Dragon = Dragon
     { dragonHealth :: Int
     , dragonAttack :: Int
     , dragonType :: DragonType
     } deriving (Show)

data Knight = Knight
    { knightHealth    :: Int
    , knightAttack    :: Int
    , knightEndurance :: Int
    } deriving (Show)

newtype Experience = MkExperience Int

experience :: Dragon -> Experience
experience Dragon {dragonType = Green} = MkExperience 250
experience Dragon {dragonType = Black} = MkExperience 150
experience Dragon {dragonType = Red} = MkExperience 100

reward :: Dragon -> Chest a -> (Chest (Maybe a), Experience)
reward dragon@Dragon {dragonType = Green} chest = (chest { chestTreasure = Nothing }, experience dragon)
reward dragon chest = (chest { chestTreasure = Just $ chestTreasure chest }, experience dragon)

-- I want to pass Chest (Maybe a) and Experience to the win type but could not find out how to do it
data FightResult a = Runaway | Die | Win a

class Creature a where
  isDead :: a -> Bool

instance Creature Dragon where
  isDead dragon = dragonHealth dragon <= 0

instance Creature Knight where
  isDead knight = knightHealth knight <= 0

dragonFight :: Chest a -> Dragon -> Knight -> FightResult (Chest (Maybe a), Experience)
dragonFight chest = attack (0 :: Int, False, False)
    where
      -- Could not work it out how to create type here.
      -- attack :: (Int, Bool, Bool) -> Dragon -> Knight -> FightResult (Chest (Maybe a), Experience)
      attack (_, _, True) _ _ = Die
      attack (_, True, _) dragon _ = Win (reward dragon chest)
      attack (_, _, _) _ Knight { knightEndurance = 0 } = Runaway
      attack (turn, _, _) dragon knight | turn `mod` 10 == 0 = attack (turn + 1, isDead dragon, isDead knight)
                                                               dragon { dragonHealth = dragonHealth dragon - knightAttack knight }
                                                               knight { knightHealth = knightHealth knight - dragonAttack dragon, knightEndurance = knightEndurance knight - 1}
                                        | otherwise = attack (turn + 1, isDead dragon, isDead knight)
                                                      dragon { dragonHealth = dragonHealth dragon - knightAttack knight }
                                                      knight { knightEndurance = knightEndurance knight - 1 }


----------------------------------------------------------------------------
-- Challenges
----------------------------------------------------------------------------

{- The following exercises are considered more challenging. However,
you still may find some of them easier than some of the previous
ones. Difficulty is a relative concept.
-}

{- | Write a function that takes a list of numbers and returns 'True'
if all the numbers are in the increasing order (i.e. the list is
sorted).

>>> isIncreasing [3, 1, 2]
False
>>> isIncreasing [1 .. 10]
True
-}
isIncreasing :: [Int] -> Bool
isIncreasing [] = True
isIncreasing [_] = True
isIncreasing (x : y : ys) = x < y && isIncreasing (y : ys)

{- | Implement a function that takes two lists, sorted in the
increasing order, and merges them into new list, also sorted in the
increasing order.

The lists are guaranteed to be given sorted, so you don't need to
verify that.

>>> merge [1, 2, 4] [3, 7]
[1,2,3,4,7]
-}
-- The best solution here is timsort. I am not the best in algorithms and will not try to implement it
merge :: [Int] -> [Int] -> [Int]
merge xs [] = xs
merge [] xs = xs
merge list1@(x:xs) list2@(y:ys) | x > y = y : merge list1 ys
                                | x == y = x : y : merge xs ys
                                | otherwise = x : merge xs list2

{- | Implement the "Merge Sort" algorithm in Haskell. The @mergeSort@
function takes a list of numbers and returns a new list containing the
same numbers but in the increasing order. merge [1, 2, 4] [3, 7]

The algorithm of merge sort is the following:

  1. If the given list has less than 2 elements, it's already sorted.
  2. Otherwise, split list into two lists of the same size.
  3. Sort each of two lists recursively.
  4. Merge two resulting sorted lists to get a new sorted list.

>>> mergeSort [3, 1, 2]
[1,2,3]
-}

halve :: [a] -> ([a], [a])
halve [] = ([], [])
halve (x:xs) = (x:evens, odds)
  where
    (odds, evens) = halve xs

mergeSort :: [Int] -> [Int]
mergeSort list | length list < 2 = list
               | otherwise = merge (mergeSort firstHalf) (mergeSort rest)
  where
    (firstHalf, rest) = halve list


{- | Haskell is famous for being a superb language for implementing
compilers and interpeters to other programming languages. In the next
tasks, you need to implement a tiny part of a compiler.

We're going to work on a small subset of arithmetic operations.

In programming we write expressions like "x + 1" or "y + x + 10".
Such expressions can be represented in a more structured way (than a
string) using the following recursive Algebraic Data Type:
-}
data Expr
    = Lit Int
    | Var String
    | Add Expr Expr
    deriving (Show, Eq)

{- Now, you can use this data type to describe such expressions:

> x + 1
Add (Var "x") (Lit 1)

> y + x + 10
Add (Var "y") (Add (Var "x") (Lit 10))
-}

{- | We want to evaluate such expressions. We can associate a value
with a variable using a list of pairs.

You can use the @lookup@ function to search in this list by a variable name:

 * https://hackage.haskell.org/package/base-4.16.0.0/docs/Prelude.html#v:lookup
-}
type Variables = [(String, Int)]

{- | Unfortunately, it's not guaranteed that variables in our @Expr@
data type are present in the given list. So we're going to introduce a
separate data for possible evaluation errors.

Normally, this would be a sum type with several constructors
describing all possible errors. But we have only one error in our
evaluation process.
-}
data EvalError
    = VariableNotFound String
    deriving (Show, Eq)

{- | Having all this set up, we can finally implement an evaluation function.
It returns either a successful evaluation result or an error.
-}
eval :: Variables -> Expr -> Either EvalError Int
eval _ (Lit num) = Right num
eval variables (Var var) = case lookup var variables of
                               Just num -> Right num
                               Nothing -> Left (VariableNotFound var)
-- No idea how this works just found similar example in Data Either docs (parseMultiple)
-- Maybe I have a bit of understanding but not 100% sure :D
eval variables (Add expr1 expr2) = do
                      x <- eval variables expr1
                      y <- eval variables expr2
                      return (x+y)

{- | Compilers also perform optimizations! One of the most common
optimizations is "Constant Folding". It performs arithmetic operations
on all constants known during compile time. This way you can write
more verbose and clear code that works as efficient as its shorter
version.

For example, if you have an expression:

x + 10 + y + 15 + 20

The result of constant folding can be:

x + y + 45

It also can be:

x + 45 + y

Write a function that takes and expression and performs "Constant
Folding" optimization on the given expression.
-}


collector :: Expr -> (Int, [Expr]) -> (Int, [Expr])
collector (Lit num) (total, variables) = (total + num, variables)
collector (Var var) (total, variables) = (total, Var var : variables)
collector (Add expr1 expr2) (total, variables) = (total + fst (collector expr1 startingValues) + fst (collector expr2 startingValues), variables ++ snd (collector expr1 startingValues)  ++ snd (collector expr2 startingValues))
  where
    startingValues = (0, [])

constantFolding :: Expr -> Expr
constantFolding expr = case collector expr (0, []) of
                            (0, []) -> Lit 0
                            (0, [var]) -> var
                            (total, []) -> Lit total
                            (total, [var]) -> Add var (Lit total)
                            (0, variables) -> foldr1 Add variables
                            (total, variables) -> foldr1 Add (Lit total : variables)
