{-# LANGUAGE CPP #-}

module OpenXR.Internal.Utils
  ( enumReadPrec
  , enumShowsPrec
  , traceAroundEvent
  ) where

import           Data.Foldable
import           Debug.Trace
import           GHC.Read                       ( expectP )
import           Text.ParserCombinators.ReadP   ( skipSpaces
                                                , string
                                                )
import           Text.Read

-- | The common bits of enumeration and bitmask read instances
enumReadPrec
  :: Read i
  => String
  -- ^ The common constructor prefix
  -> [(a, String)]
  -- ^ The table of values to constructor suffixes
  -> String
  -- ^ The newtype constructor name
  -> (i -> a)
  -- ^ The newtype constructor
  -> ReadPrec a
enumReadPrec prefix table conName con = parens
  (   lift
      (do
        skipSpaces
        _ <- string prefix
        asum ((\(e, s) -> e <$ string s) <$> table)
      )
  +++ prec
        10
        (do
          expectP (Ident conName)
          v <- step readPrec
          pure (con v)
        )
  )

-- | The common bits of enumeration and bitmask show instances
enumShowsPrec
  :: Eq a
  => String
  -- ^ The common constructor prefix
  -> [(a, String)]
  -- ^ A table of values to constructor suffixes
  -> String
  -- ^ The newtype constructor name
  -> (a -> i)
  -- ^ Unpack the newtype
  -> (i -> ShowS)
  -- ^ Show the underlying value
  -> Int
  -> a
  -> ShowS
enumShowsPrec prefix table conName getInternal showsInternal p e =
  case lookup e table of
    Just s -> showString prefix . showString s
    Nothing ->
      let x = getInternal e
      in  showParen (p >= 11)
                    (showString conName . showString " " . showsInternal x)

-- | Wrap an IO action with a pair of 'traceEventIO' using the specified
-- message with "begin" or "end" appended.
traceAroundEvent :: String -> IO a -> IO a
#if defined(TRACE_CALLS)
traceAroundEvent msg a =
  traceEventIO (msg <> " begin") *> a <* traceEventIO (msg <> " end")
#else
traceAroundEvent _ a = a
#endif
