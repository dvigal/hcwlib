module Hcw.Window where

import Hcw.Types (WNDCLASS)
import System.Win32.Types (ATOM,
						   INT,	
						   HINSTANCE,
						   maybePtr,
						   numToMaybe,
						   failIfNull,
						   newTString)
import Graphics.Win32.Window (Pos,
							  ClassName,
							  WindowStyle,
							  maybePos,
							  mkWindowClosure,
							  c_CreateWindowEx)
import Graphics.Win32.GDI.Types

import Control.Monad
import Foreign.Ptr
import Foreign.Marshal.Alloc (allocaBytes)
import Foreign.Storable (pokeByteOff)

withWNDCLASS :: WNDCLASS -> (Ptr WNDCLASS -> IO a) -> IO a
withWNDCLASS (style, wnd_proc, inst, mb_icon, mb_cursor, mb_bg, mb_menu, cls) f =
	allocaBytes (40) $ \ p -> do
	(\hsc_ptr -> pokeByteOff hsc_ptr 0) p style
	wnd_proc_ptr <- mkWindowClosure wnd_proc
	(\hsc_ptr -> pokeByteOff hsc_ptr 4) p wnd_proc_ptr
	(\hsc_ptr -> pokeByteOff hsc_ptr 8) p (0::INT)
	(\hsc_ptr -> pokeByteOff hsc_ptr 12) p (0::INT)
	(\hsc_ptr -> pokeByteOff hsc_ptr 16) p inst
	(\hsc_ptr -> pokeByteOff hsc_ptr 20) p (maybePtr mb_icon)
	(\hsc_ptr -> pokeByteOff hsc_ptr 24) p (maybePtr mb_cursor)
	(\hsc_ptr -> pokeByteOff hsc_ptr 28) p (maybePtr mb_bg)
	(\hsc_ptr -> pokeByteOff hsc_ptr 32) p (maybePtr mb_menu)
	(\hsc_ptr -> pokeByteOff hsc_ptr 36) p cls
	f p

registerClass :: WNDCLASS -> IO (Maybe ATOM)
registerClass cls = 
	withWNDCLASS cls $ \ p ->
	liftM numToMaybe $ c_RegisterClassHcw p

foreign import stdcall unsafe "windows.h RegisterClassW"
	c_RegisterClassHcw :: Ptr WNDCLASS -> IO ATOM

createWindow 
	:: ClassName -> String -> WindowStyle ->
	   Maybe Pos -> Maybe Pos -> Maybe Pos -> Maybe Pos ->
	   Maybe HWND -> Maybe HMENU -> HINSTANCE ->
	   IO HWND
createWindow cname wname wstyle mb_x mb_y mb_w mb_h mb_parent mb_menu inst = do
	c_wname <- newTString wname
	wnd <- failIfNull "CreateWindowEx" $
		c_CreateWindowEx 0 cname c_wname wstyle
		(maybePos mb_x) (maybePos mb_y) (maybePos mb_w) (maybePos mb_h)
		(maybePtr mb_parent) (maybePtr mb_menu) inst nullPtr
	return wnd	