module Rasa.Ext.Vim
  ( vim
  , VimSt
  ) where

import Rasa.Ext
import Rasa.Ext.Files (saveCurrent)
import Rasa.Ext.Directive

import Data.Default
import Data.Typeable
import Data.Maybe
import qualified Data.Text as T

data VimSt
  = Normal
  | Insert
  deriving (Show, Typeable)

instance Default VimSt where
  def = Normal

getVim :: Alteration VimSt
getVim = fromMaybe def <$> getPlugin

vim :: Alteration ()
vim = do
  mode <- getVim
  let modeFunc =
        case mode of
          Normal -> normal
          Insert -> insert
  evt <- getEvent
  mapM_ modeFunc evt

insert :: Event -> Alteration ()
insert Esc = setPlugin Normal
insert BS = deleteChar
insert Enter = insertText "\n"
insert (Keypress 'w' [Ctrl]) = killWord
insert (Keypress 'c' [Ctrl]) = exit
insert (Keypress c _) = insertText $ T.singleton c
insert _ = return ()

normal :: Event -> Alteration ()
normal (Keypress 'i' _) = setPlugin Insert
normal (Keypress 'I' _) = startOfLine >> setPlugin Insert
normal (Keypress 'a' _) = moveCursor 1 >> setPlugin Insert
normal (Keypress 'A' _) = endOfLine >> setPlugin Insert
normal (Keypress '0' _) = startOfLine
normal (Keypress '$' _) = findNext "\n"
normal (Keypress 'g' _) = startOfBuffer
normal (Keypress 'G' _) = endOfBuffer
normal (Keypress 'o' _) = endOfLine >> insertText "\n" >> setPlugin Insert
normal (Keypress 'O' _) = startOfLine >> insertText "\n" >> setPlugin Insert
normal (Keypress '+' _) = switchBuf 1
normal (Keypress '-' _) = switchBuf (-1)
normal (Keypress 'h' _) = moveCursor (-1)
normal (Keypress 'l' _) = moveCursor 1
normal (Keypress 'k' _) = moveCursorCoord (-1, 0)
normal (Keypress 'j' _) = moveCursorCoord (1, 0)
normal (Keypress 'f' _) = findNext "f"
normal (Keypress 'F' _) = findPrev "f"
normal (Keypress 'X' _) = deleteChar >> moveCursor (-1)
normal (Keypress 'x' _) = moveCursor 1 >> deleteChar >> moveCursor (-1)
normal (Keypress 'D' _) = deleteTillEOL
normal (Keypress 'q' _) = exit
normal (Keypress 'c' [Ctrl]) = exit
normal (Keypress 's' [Ctrl]) = saveCurrent
normal _ = return ()