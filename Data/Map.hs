{-# LANGUAGE CPP #-}
#if !defined(TESTING) && __GLASGOW_HASKELL__ >= 703
{-# LANGUAGE Safe #-}
#endif
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Map
-- Copyright   :  (c) Daan Leijen 2002
--                (c) Andriy Palamarchuk 2008
-- License     :  BSD-style
-- Maintainer  :  libraries@haskell.org
-- Stability   :  provisional
-- Portability :  portable
--
-- An efficient implementation of maps from keys to values (dictionaries).
--
-- Since many function names (but not the type name) clash with
-- "Prelude" names, this module is usually imported @qualified@, e.g.
--
-- >  import Data.Map (Map)
-- >  import qualified Data.Map as Map
--
-- The implementation of 'Map' is based on /size balanced/ binary trees (or
-- trees of /bounded balance/) as described by:
--
--    * Stephen Adams, \"/Efficient sets: a balancing act/\",
--     Journal of Functional Programming 3(4):553-562, October 1993,
--     <http://www.swiss.ai.mit.edu/~adams/BB/>.
--
--    * J. Nievergelt and E.M. Reingold,
--      \"/Binary search trees of bounded balance/\",
--      SIAM journal of computing 2(1), March 1973.
--
-- Note that the implementation is /left-biased/ -- the elements of a
-- first argument are always preferred to the second, for example in
-- 'union' or 'insert'.
--
-- Operation comments contain the operation time complexity in
-- the Big-O notation <http://en.wikipedia.org/wiki/Big_O_notation>.
-----------------------------------------------------------------------------

module Data.Map (
            -- * Map type
#if !defined(TESTING)
              Map              -- instance Eq,Show,Read
#else
              Map(..)          -- instance Eq,Show,Read
#endif

            -- * Operators
            , (!), (\\)

            -- * Query
            , null
            , size
            , member
            , notMember
            , lookup
            , findWithDefault

            -- * Construction
            , empty
            , singleton

            -- ** Insertion
            , insert
            , insertWith
            , insertWith'
            , insertWithKey
            , insertWithKey'
            , insertLookupWithKey
            , insertLookupWithKey'

            -- ** Delete\/Update
            , delete
            , adjust
            , adjustWithKey
            , update
            , updateWithKey
            , updateLookupWithKey
            , alter

            -- * Combine

            -- ** Union
            , union
            , unionWith
            , unionWithKey
            , unions
            , unionsWith

            -- ** Difference
            , difference
            , differenceWith
            , differenceWithKey

            -- ** Intersection
            , intersection
            , intersectionWith
            , intersectionWithKey

            -- * Traversal
            -- ** Map
            , map
            , mapWithKey
            , mapAccum
            , mapAccumWithKey
            , mapAccumRWithKey
            , mapKeys
            , mapKeysWith
            , mapKeysMonotonic

            -- * Folds
            , foldr
            , foldl
            , foldrWithKey
            , foldlWithKey
            -- ** Strict folds
            , foldr'
            , foldl'
            , foldrWithKey'
            , foldlWithKey'
            -- ** Legacy folds
            , fold
            , foldWithKey

            -- * Conversion
            , elems
            , keys
            , keysSet
            , assocs

            -- ** Lists
            , toList
            , fromList
            , fromListWith
            , fromListWithKey

            -- ** Ordered lists
            , toAscList
            , toDescList
            , fromAscList
            , fromAscListWith
            , fromAscListWithKey
            , fromDistinctAscList

            -- * Filter
            , filter
            , filterWithKey
            , partition
            , partitionWithKey

            , mapMaybe
            , mapMaybeWithKey
            , mapEither
            , mapEitherWithKey

            , split
            , splitLookup

            -- * Submap
            , isSubmapOf, isSubmapOfBy
            , isProperSubmapOf, isProperSubmapOfBy

            -- * Indexed
            , lookupIndex
            , findIndex
            , elemAt
            , updateAt
            , deleteAt

            -- * Min\/Max
            , findMin
            , findMax
            , deleteMin
            , deleteMax
            , deleteFindMin
            , deleteFindMax
            , updateMin
            , updateMax
            , updateMinWithKey
            , updateMaxWithKey
            , minView
            , maxView
            , minViewWithKey
            , maxViewWithKey

            -- * Debugging
            , showTree
            , showTreeWith
            , valid

#if defined(TESTING)
            -- * Internals
            , bin
            , balanced
            , join
            , merge
#endif

            ) where

import Data.Map.Lazy
import qualified Data.Map.Strict as S
import Prelude hiding (lookup,map,filter,foldr,foldl,null)

-- | Same as 'insertWith', but the combining function is applied strictly.
-- This is often the most desirable behavior.
--
-- For example, to update a counter:
--
-- > insertWith' (+) k 1 m
--
insertWith' :: Ord k => (a -> a -> a) -> k -> a -> Map k a -> Map k a
insertWith' = S.insertWith
{-# INLINE insertWith' #-}

-- | Same as 'insertWithKey', but the combining function is applied strictly.
insertWithKey' :: Ord k => (k -> a -> a -> a) -> k -> a -> Map k a -> Map k a
insertWithKey' = S.insertWithKey
{-# INLINE insertWithKey' #-}

-- | /O(log n)/. A strict version of 'insertLookupWithKey'.
insertLookupWithKey' :: Ord k => (k -> a -> a -> a) -> k -> a -> Map k a
                     -> (Maybe a, Map k a)
insertLookupWithKey' = S.insertLookupWithKey
{-# INLINE insertLookupWithKey' #-}

-- | /O(n)/. Fold the values in the map using the given right-associative
-- binary operator. This function is an equivalent of 'foldr' and is present
-- for compatibility only.
--
-- /Please note that fold will be deprecated in the future and removed./
fold :: (a -> b -> b) -> b -> Map k a -> b
fold = foldr
{-# INLINE fold #-}

-- | /O(n)/. Fold the keys and values in the map using the given right-associative
-- binary operator. This function is an equivalent of 'foldrWithKey' and is present
-- for compatibility only.
--
-- /Please note that foldWithKey will be deprecated in the future and removed./
foldWithKey :: (k -> a -> b -> b) -> b -> Map k a -> b
foldWithKey = foldrWithKey
{-# INLINE foldWithKey #-}
