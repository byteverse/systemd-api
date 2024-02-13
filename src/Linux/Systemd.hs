module Linux.Systemd
  ( listenFds
  , isSocket
  ) where

import Foreign.C.Error (Errno, getErrno)
import Foreign.C.Types (CInt (..))
import Posix.Socket (Family (..), Type (..))
import System.Posix.Types (Fd (..))

foreign import ccall unsafe "systemd/sd-daemon.h sd_listen_fds"
  c_listenFds :: CInt -> IO CInt

foreign import ccall unsafe "systemd/sd-daemon.h sd_is_socket"
  c_isSocket :: Fd -> Family -> Type -> CInt -> IO CInt

{- | Check for file descriptors passed by the system manager. Returns
the number of received file descriptors. If no file descriptors
have been received, zero is returned.
-}
listenFds ::
  -- | unset environment (non-zero unsets @LISTEN_FDS@, @LISTEN_PID@, and @LISTEN_FDNAMES@)
  CInt ->
  IO (Either Errno CInt)
listenFds a = c_listenFds a >>= errorsFromInt

isSocket ::
  -- | File descriptor
  Fd ->
  -- | Socket family
  Family ->
  -- | Socket type
  Type ->
  -- | Positive: require listen mode. Zero: require non-listening mode.
  CInt ->
  IO (Either Errno CInt)
isSocket a b c d = c_isSocket a b c d >>= errorsFromInt

errorsFromInt :: CInt -> IO (Either Errno CInt)
errorsFromInt r =
  if r >= 0
    then pure (Right r)
    else fmap Left getErrno
