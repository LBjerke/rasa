{-# LANGUAGE OverloadedStrings #-}
module View (
    textWrap
    )
    where

import qualified Data.Text as T
import Data.List.Extra (takeEnd)
import Data.List (unfoldr)
import Control.Lens
import Control.Arrow (second)

import State

-- addCursor :: T.Text -> T.Text
-- addCursor = (`T.snoc` '_')

-- applyViewport :: St -> St
-- applyViewport = do
--     viewportSize <- view vHeight
--     ls <- T.lines . view focusedBuf
--     let window = T.unlines . getWindow viewportSize $ ls
--     set focusedBuf window
--         where getWindow = takeEnd


textWrap :: Int -> T.Text -> T.Text
textWrap n = T.dropEnd 1 . T.unlines . unfoldr (splitLine n)

splitLine :: Int -> (T.Text -> Maybe (T.Text, T.Text))
splitLine n t
  | T.null t = Nothing
  | T.compareLength (fst . splitAtNewline $ t) n == LT = Just $ splitAtNewline t
  | otherwise = Just $ second (T.append "-> ") $ T.splitAt n t

splitAtNewline :: T.Text -> (T.Text, T.Text)
splitAtNewline = second (T.drop 1) . T.span (/= '\n')
