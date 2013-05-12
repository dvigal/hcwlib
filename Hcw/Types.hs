module Hcw.Types where

import System.Win32.Types (LPCTSTR,
						   HINSTANCE)
import Graphics.Win32.Window (WindowClosure,
							  ClassStyle,
							  ClassName)
import Graphics.Win32.GDI.Types (HICON,
								 HCURSOR,
								 HBRUSH)
import Data.Maybe

type WNDCLASS = 
	(ClassStyle,
	 WindowClosure, 
	 HINSTANCE,
	 Maybe HICON,
	 Maybe HCURSOR,
	 Maybe HBRUSH,
	 Maybe LPCTSTR,
	 ClassName)