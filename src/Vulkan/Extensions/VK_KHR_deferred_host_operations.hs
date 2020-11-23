{-# language CPP #-}
module Vulkan.Extensions.VK_KHR_deferred_host_operations  ( createDeferredOperationKHR
                                                          , withDeferredOperationKHR
                                                          , destroyDeferredOperationKHR
                                                          , getDeferredOperationMaxConcurrencyKHR
                                                          , getDeferredOperationResultKHR
                                                          , deferredOperationJoinKHR
                                                          , KHR_DEFERRED_HOST_OPERATIONS_SPEC_VERSION
                                                          , pattern KHR_DEFERRED_HOST_OPERATIONS_SPEC_VERSION
                                                          , KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME
                                                          , pattern KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME
                                                          , DeferredOperationKHR(..)
                                                          ) where

import Control.Exception.Base (bracket)
import Control.Monad (unless)
import Control.Monad.IO.Class (liftIO)
import Foreign.Marshal.Alloc (callocBytes)
import Foreign.Marshal.Alloc (free)
import GHC.Base (when)
import GHC.IO (throwIO)
import GHC.Ptr (nullFunPtr)
import Foreign.Ptr (nullPtr)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Cont (evalContT)
import Control.Monad.IO.Class (MonadIO)
import Data.String (IsString)
import Foreign.Storable (Storable(peek))
import GHC.IO.Exception (IOErrorType(..))
import GHC.IO.Exception (IOException(..))
import Foreign.Ptr (FunPtr)
import Foreign.Ptr (Ptr)
import Data.Word (Word32)
import Control.Monad.Trans.Cont (ContT(..))
import Vulkan.NamedType ((:::))
import Vulkan.Core10.AllocationCallbacks (AllocationCallbacks)
import Vulkan.Extensions.Handles (DeferredOperationKHR)
import Vulkan.Extensions.Handles (DeferredOperationKHR(..))
import Vulkan.Core10.Handles (Device)
import Vulkan.Core10.Handles (Device(..))
import Vulkan.Dynamic (DeviceCmds(pVkCreateDeferredOperationKHR))
import Vulkan.Dynamic (DeviceCmds(pVkDeferredOperationJoinKHR))
import Vulkan.Dynamic (DeviceCmds(pVkDestroyDeferredOperationKHR))
import Vulkan.Dynamic (DeviceCmds(pVkGetDeferredOperationMaxConcurrencyKHR))
import Vulkan.Dynamic (DeviceCmds(pVkGetDeferredOperationResultKHR))
import Vulkan.Core10.Handles (Device_T)
import Vulkan.Core10.Enums.Result (Result)
import Vulkan.Core10.Enums.Result (Result(..))
import Vulkan.CStruct (ToCStruct(..))
import Vulkan.Exception (VulkanException(..))
import Vulkan.Core10.Enums.Result (Result(SUCCESS))
import Vulkan.Extensions.Handles (DeferredOperationKHR(..))
foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkCreateDeferredOperationKHR
  :: FunPtr (Ptr Device_T -> Ptr AllocationCallbacks -> Ptr DeferredOperationKHR -> IO Result) -> Ptr Device_T -> Ptr AllocationCallbacks -> Ptr DeferredOperationKHR -> IO Result

-- | vkCreateDeferredOperationKHR - Create a deferred operation handle
--
-- == Valid Usage (Implicit)
--
-- -   #VUID-vkCreateDeferredOperationKHR-device-parameter# @device@ /must/
--     be a valid 'Vulkan.Core10.Handles.Device' handle
--
-- -   #VUID-vkCreateDeferredOperationKHR-pAllocator-parameter# If
--     @pAllocator@ is not @NULL@, @pAllocator@ /must/ be a valid pointer
--     to a valid 'Vulkan.Core10.AllocationCallbacks.AllocationCallbacks'
--     structure
--
-- -   #VUID-vkCreateDeferredOperationKHR-pDeferredOperation-parameter#
--     @pDeferredOperation@ /must/ be a valid pointer to a
--     'Vulkan.Extensions.Handles.DeferredOperationKHR' handle
--
-- == Return Codes
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-successcodes Success>]
--
--     -   'Vulkan.Core10.Enums.Result.SUCCESS'
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-errorcodes Failure>]
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_HOST_MEMORY'
--
-- = See Also
--
-- 'Vulkan.Core10.AllocationCallbacks.AllocationCallbacks',
-- 'Vulkan.Extensions.Handles.DeferredOperationKHR',
-- 'Vulkan.Core10.Handles.Device'
createDeferredOperationKHR :: forall io
                            . (MonadIO io)
                           => -- | @device@ is the device which owns @operation@.
                              Device
                           -> -- | @pAllocator@ controls host memory allocation as described in the
                              -- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#memory-allocation Memory Allocation>
                              -- chapter.
                              ("allocator" ::: Maybe AllocationCallbacks)
                           -> io (DeferredOperationKHR)
createDeferredOperationKHR device allocator = liftIO . evalContT $ do
  let vkCreateDeferredOperationKHRPtr = pVkCreateDeferredOperationKHR (deviceCmds (device :: Device))
  lift $ unless (vkCreateDeferredOperationKHRPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkCreateDeferredOperationKHR is null" Nothing Nothing
  let vkCreateDeferredOperationKHR' = mkVkCreateDeferredOperationKHR vkCreateDeferredOperationKHRPtr
  pAllocator <- case (allocator) of
    Nothing -> pure nullPtr
    Just j -> ContT $ withCStruct (j)
  pPDeferredOperation <- ContT $ bracket (callocBytes @DeferredOperationKHR 8) free
  r <- lift $ vkCreateDeferredOperationKHR' (deviceHandle (device)) pAllocator (pPDeferredOperation)
  lift $ when (r < SUCCESS) (throwIO (VulkanException r))
  pDeferredOperation <- lift $ peek @DeferredOperationKHR pPDeferredOperation
  pure $ (pDeferredOperation)

-- | A convenience wrapper to make a compatible pair of calls to
-- 'createDeferredOperationKHR' and 'destroyDeferredOperationKHR'
--
-- To ensure that 'destroyDeferredOperationKHR' is always called: pass
-- 'Control.Exception.bracket' (or the allocate function from your
-- favourite resource management library) as the last argument.
-- To just extract the pair pass '(,)' as the last argument.
--
withDeferredOperationKHR :: forall io r . MonadIO io => Device -> Maybe AllocationCallbacks -> (io DeferredOperationKHR -> (DeferredOperationKHR -> io ()) -> r) -> r
withDeferredOperationKHR device pAllocator b =
  b (createDeferredOperationKHR device pAllocator)
    (\(o0) -> destroyDeferredOperationKHR device o0 pAllocator)


foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkDestroyDeferredOperationKHR
  :: FunPtr (Ptr Device_T -> DeferredOperationKHR -> Ptr AllocationCallbacks -> IO ()) -> Ptr Device_T -> DeferredOperationKHR -> Ptr AllocationCallbacks -> IO ()

-- | vkDestroyDeferredOperationKHR - Destroy a deferred operation handle
--
-- == Valid Usage
--
-- -   #VUID-vkDestroyDeferredOperationKHR-operation-03434# If
--     'Vulkan.Core10.AllocationCallbacks.AllocationCallbacks' were
--     provided when @operation@ was created, a compatible set of callbacks
--     /must/ be provided here
--
-- -   #VUID-vkDestroyDeferredOperationKHR-operation-03435# If no
--     'Vulkan.Core10.AllocationCallbacks.AllocationCallbacks' were
--     provided when @operation@ was created, @pAllocator@ /must/ be @NULL@
--
-- -   #VUID-vkDestroyDeferredOperationKHR-operation-03436# @operation@
--     /must/ be completed
--
-- == Valid Usage (Implicit)
--
-- -   #VUID-vkDestroyDeferredOperationKHR-device-parameter# @device@
--     /must/ be a valid 'Vulkan.Core10.Handles.Device' handle
--
-- -   #VUID-vkDestroyDeferredOperationKHR-operation-parameter# If
--     @operation@ is not 'Vulkan.Core10.APIConstants.NULL_HANDLE',
--     @operation@ /must/ be a valid
--     'Vulkan.Extensions.Handles.DeferredOperationKHR' handle
--
-- -   #VUID-vkDestroyDeferredOperationKHR-pAllocator-parameter# If
--     @pAllocator@ is not @NULL@, @pAllocator@ /must/ be a valid pointer
--     to a valid 'Vulkan.Core10.AllocationCallbacks.AllocationCallbacks'
--     structure
--
-- -   #VUID-vkDestroyDeferredOperationKHR-operation-parent# If @operation@
--     is a valid handle, it /must/ have been created, allocated, or
--     retrieved from @device@
--
-- == Host Synchronization
--
-- -   Host access to @operation@ /must/ be externally synchronized
--
-- = See Also
--
-- 'Vulkan.Core10.AllocationCallbacks.AllocationCallbacks',
-- 'Vulkan.Extensions.Handles.DeferredOperationKHR',
-- 'Vulkan.Core10.Handles.Device'
destroyDeferredOperationKHR :: forall io
                             . (MonadIO io)
                            => -- | @device@ is the device which owns @operation@.
                               Device
                            -> -- | @operation@ is the completed operation to be destroyed.
                               DeferredOperationKHR
                            -> -- | @pAllocator@ controls host memory allocation as described in the
                               -- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#memory-allocation Memory Allocation>
                               -- chapter.
                               ("allocator" ::: Maybe AllocationCallbacks)
                            -> io ()
destroyDeferredOperationKHR device operation allocator = liftIO . evalContT $ do
  let vkDestroyDeferredOperationKHRPtr = pVkDestroyDeferredOperationKHR (deviceCmds (device :: Device))
  lift $ unless (vkDestroyDeferredOperationKHRPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkDestroyDeferredOperationKHR is null" Nothing Nothing
  let vkDestroyDeferredOperationKHR' = mkVkDestroyDeferredOperationKHR vkDestroyDeferredOperationKHRPtr
  pAllocator <- case (allocator) of
    Nothing -> pure nullPtr
    Just j -> ContT $ withCStruct (j)
  lift $ vkDestroyDeferredOperationKHR' (deviceHandle (device)) (operation) pAllocator
  pure $ ()


foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkGetDeferredOperationMaxConcurrencyKHR
  :: FunPtr (Ptr Device_T -> DeferredOperationKHR -> IO Word32) -> Ptr Device_T -> DeferredOperationKHR -> IO Word32

-- | vkGetDeferredOperationMaxConcurrencyKHR - Query the maximum concurrency
-- on a deferred operation
--
-- = Description
--
-- The returned value is the maximum number of threads that can usefully
-- execute a deferred operation concurrently, reported for the state of the
-- deferred operation at the point this command is called. This value is
-- intended to be used to better schedule work onto available threads.
-- Applications /can/ join any number of threads to the deferred operation
-- and expect it to eventually complete, though excessive joins /may/
-- return 'Vulkan.Core10.Enums.Result.THREAD_DONE_KHR' immediately,
-- performing no useful work.
--
-- If @operation@ is complete, 'getDeferredOperationMaxConcurrencyKHR'
-- returns zero.
--
-- If @operation@ is currently joined to any threads, the value returned by
-- this command /may/ immediately be out of date.
--
-- If @operation@ is pending, implementations /must/ not return zero unless
-- at least one thread is currently executing 'deferredOperationJoinKHR' on
-- @operation@. If there are such threads, the implementation /should/
-- return an estimate of the number of additional threads which it could
-- profitably use.
--
-- Implementations /may/ return 232-1 to indicate that the maximum
-- concurrency is unknown and cannot be easily derived. Implementations
-- /may/ return values larger than the maximum concurrency available on the
-- host CPU. In these situations, an application /should/ clamp the return
-- value rather than oversubscribing the machine.
--
-- Note
--
-- The recommended usage pattern for applications is to query this value
-- once, after deferral, and schedule no more than the specified number of
-- threads to join the operation. Each time a joined thread receives
-- 'Vulkan.Core10.Enums.Result.THREAD_IDLE_KHR', the application should
-- schedule an additional join at some point in the future, but is not
-- required to do so.
--
-- == Valid Usage (Implicit)
--
-- = See Also
--
-- 'Vulkan.Extensions.Handles.DeferredOperationKHR',
-- 'Vulkan.Core10.Handles.Device'
getDeferredOperationMaxConcurrencyKHR :: forall io
                                       . (MonadIO io)
                                      => -- | @device@ is the device which owns @operation@.
                                         --
                                         -- #VUID-vkGetDeferredOperationMaxConcurrencyKHR-device-parameter# @device@
                                         -- /must/ be a valid 'Vulkan.Core10.Handles.Device' handle
                                         Device
                                      -> -- | @operation@ is the deferred operation to be queried.
                                         --
                                         -- #VUID-vkGetDeferredOperationMaxConcurrencyKHR-operation-parameter#
                                         -- @operation@ /must/ be a valid
                                         -- 'Vulkan.Extensions.Handles.DeferredOperationKHR' handle
                                         --
                                         -- #VUID-vkGetDeferredOperationMaxConcurrencyKHR-operation-parent#
                                         -- @operation@ /must/ have been created, allocated, or retrieved from
                                         -- @device@
                                         DeferredOperationKHR
                                      -> io (Word32)
getDeferredOperationMaxConcurrencyKHR device operation = liftIO $ do
  let vkGetDeferredOperationMaxConcurrencyKHRPtr = pVkGetDeferredOperationMaxConcurrencyKHR (deviceCmds (device :: Device))
  unless (vkGetDeferredOperationMaxConcurrencyKHRPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkGetDeferredOperationMaxConcurrencyKHR is null" Nothing Nothing
  let vkGetDeferredOperationMaxConcurrencyKHR' = mkVkGetDeferredOperationMaxConcurrencyKHR vkGetDeferredOperationMaxConcurrencyKHRPtr
  r <- vkGetDeferredOperationMaxConcurrencyKHR' (deviceHandle (device)) (operation)
  pure $ (r)


foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkGetDeferredOperationResultKHR
  :: FunPtr (Ptr Device_T -> DeferredOperationKHR -> IO Result) -> Ptr Device_T -> DeferredOperationKHR -> IO Result

-- | vkGetDeferredOperationResultKHR - Query the result of a deferred
-- operation
--
-- = Description
--
-- If no command has been deferred on @operation@,
-- 'getDeferredOperationResultKHR' returns
-- 'Vulkan.Core10.Enums.Result.SUCCESS'.
--
-- If the deferred operation is pending, 'getDeferredOperationResultKHR'
-- returns 'Vulkan.Core10.Enums.Result.NOT_READY'.
--
-- If the deferred operation is complete, it returns the appropriate return
-- value from the original command. This value /must/ be one of the
-- 'Vulkan.Core10.Enums.Result.Result' values which could have been
-- returned by the original command if the operation had not been deferred.
--
-- == Return Codes
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-successcodes Success>]
--
--     -   'Vulkan.Core10.Enums.Result.SUCCESS'
--
--     -   'Vulkan.Core10.Enums.Result.NOT_READY'
--
-- = See Also
--
-- 'Vulkan.Extensions.Handles.DeferredOperationKHR',
-- 'Vulkan.Core10.Handles.Device'
getDeferredOperationResultKHR :: forall io
                               . (MonadIO io)
                              => -- | @device@ is the device which owns @operation@.
                                 --
                                 -- #VUID-vkGetDeferredOperationResultKHR-device-parameter# @device@ /must/
                                 -- be a valid 'Vulkan.Core10.Handles.Device' handle
                                 Device
                              -> -- | @operation@ is the operation whose deferred result is being queried.
                                 --
                                 -- #VUID-vkGetDeferredOperationResultKHR-operation-parameter# @operation@
                                 -- /must/ be a valid 'Vulkan.Extensions.Handles.DeferredOperationKHR'
                                 -- handle
                                 --
                                 -- #VUID-vkGetDeferredOperationResultKHR-operation-parent# @operation@
                                 -- /must/ have been created, allocated, or retrieved from @device@
                                 DeferredOperationKHR
                              -> io (Result)
getDeferredOperationResultKHR device operation = liftIO $ do
  let vkGetDeferredOperationResultKHRPtr = pVkGetDeferredOperationResultKHR (deviceCmds (device :: Device))
  unless (vkGetDeferredOperationResultKHRPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkGetDeferredOperationResultKHR is null" Nothing Nothing
  let vkGetDeferredOperationResultKHR' = mkVkGetDeferredOperationResultKHR vkGetDeferredOperationResultKHRPtr
  r <- vkGetDeferredOperationResultKHR' (deviceHandle (device)) (operation)
  pure $ (r)


foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkDeferredOperationJoinKHR
  :: FunPtr (Ptr Device_T -> DeferredOperationKHR -> IO Result) -> Ptr Device_T -> DeferredOperationKHR -> IO Result

-- | vkDeferredOperationJoinKHR - Assign a thread to a deferred operation
--
-- = Description
--
-- The 'deferredOperationJoinKHR' command will execute a portion of the
-- deferred operation on the calling thread.
--
-- The return value will be one of the following:
--
-- -   A return value of 'Vulkan.Core10.Enums.Result.SUCCESS' indicates
--     that @operation@ is complete. The application /should/ use
--     'getDeferredOperationResultKHR' to retrieve the result of
--     @operation@.
--
-- -   A return value of 'Vulkan.Core10.Enums.Result.THREAD_DONE_KHR'
--     indicates that the deferred operation is not complete, but there is
--     no work remaining to assign to threads. Future calls to
--     'deferredOperationJoinKHR' are not necessary and will simply harm
--     performance. This situation /may/ occur when other threads executing
--     'deferredOperationJoinKHR' are about to complete @operation@, and
--     the implementation is unable to partition the workload any further.
--
-- -   A return value of 'Vulkan.Core10.Enums.Result.THREAD_IDLE_KHR'
--     indicates that the deferred operation is not complete, and there is
--     no work for the thread to do at the time of the call. This situation
--     /may/ occur if the operation encounters a temporary reduction in
--     parallelism. By returning
--     'Vulkan.Core10.Enums.Result.THREAD_IDLE_KHR', the implementation is
--     signaling that it expects that more opportunities for parallelism
--     will emerge as execution progresses, and that future calls to
--     'deferredOperationJoinKHR' /can/ be beneficial. In the meantime, the
--     application /can/ perform other work on the calling thread.
--
-- Implementations /must/ guarantee forward progress by enforcing the
-- following invariants:
--
-- 1.  If only one thread has invoked 'deferredOperationJoinKHR' on a given
--     operation, that thread /must/ execute the operation to completion
--     and return 'Vulkan.Core10.Enums.Result.SUCCESS'.
--
-- 2.  If multiple threads have concurrently invoked
--     'deferredOperationJoinKHR' on the same operation, then at least one
--     of them /must/ complete the operation and return
--     'Vulkan.Core10.Enums.Result.SUCCESS'.
--
-- == Valid Usage (Implicit)
--
-- -   #VUID-vkDeferredOperationJoinKHR-device-parameter# @device@ /must/
--     be a valid 'Vulkan.Core10.Handles.Device' handle
--
-- -   #VUID-vkDeferredOperationJoinKHR-operation-parameter# @operation@
--     /must/ be a valid 'Vulkan.Extensions.Handles.DeferredOperationKHR'
--     handle
--
-- -   #VUID-vkDeferredOperationJoinKHR-operation-parent# @operation@
--     /must/ have been created, allocated, or retrieved from @device@
--
-- == Return Codes
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-successcodes Success>]
--
--     -   'Vulkan.Core10.Enums.Result.SUCCESS'
--
--     -   'Vulkan.Core10.Enums.Result.THREAD_DONE_KHR'
--
--     -   'Vulkan.Core10.Enums.Result.THREAD_IDLE_KHR'
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-errorcodes Failure>]
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_HOST_MEMORY'
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_DEVICE_MEMORY'
--
-- = See Also
--
-- 'Vulkan.Extensions.Handles.DeferredOperationKHR',
-- 'Vulkan.Core10.Handles.Device'
deferredOperationJoinKHR :: forall io
                          . (MonadIO io)
                         => -- | @device@ is the device which owns @operation@.
                            Device
                         -> -- | @operation@ is the deferred operation that the calling thread should
                            -- work on.
                            DeferredOperationKHR
                         -> io (Result)
deferredOperationJoinKHR device operation = liftIO $ do
  let vkDeferredOperationJoinKHRPtr = pVkDeferredOperationJoinKHR (deviceCmds (device :: Device))
  unless (vkDeferredOperationJoinKHRPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkDeferredOperationJoinKHR is null" Nothing Nothing
  let vkDeferredOperationJoinKHR' = mkVkDeferredOperationJoinKHR vkDeferredOperationJoinKHRPtr
  r <- vkDeferredOperationJoinKHR' (deviceHandle (device)) (operation)
  when (r < SUCCESS) (throwIO (VulkanException r))
  pure $ (r)


type KHR_DEFERRED_HOST_OPERATIONS_SPEC_VERSION = 4

-- No documentation found for TopLevel "VK_KHR_DEFERRED_HOST_OPERATIONS_SPEC_VERSION"
pattern KHR_DEFERRED_HOST_OPERATIONS_SPEC_VERSION :: forall a . Integral a => a
pattern KHR_DEFERRED_HOST_OPERATIONS_SPEC_VERSION = 4


type KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME = "VK_KHR_deferred_host_operations"

-- No documentation found for TopLevel "VK_KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME"
pattern KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME :: forall a . (Eq a, IsString a) => a
pattern KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME = "VK_KHR_deferred_host_operations"

