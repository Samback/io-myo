## *io-myo* - Nim bindings for the Thalmic Labs Myo gesture control armband SDK.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

import libmyo


# The following program is a basic example of using `libmyo` to connect to a
# Myo armband and log out EMG data.

const appId: cstring = "us.nimio.examples.emg"

var errorDetails: LibmyoErrorDetails
var hub: LibmyoHub
var myo: LibmyoMyo


proc findMyoHandler(userData: pointer; event: LibmyoEvent): LibmyoHandlerResult =
  myo = libmyoEventGetMyo(event)
  case libmyoEventGetType(event)
  of LibmyoEventType.paired:
    return LibmyoHandlerResult.stop
  else:
    return LibmyoHandlerResult.continueProcessing


proc runHandler(userData: pointer; event: LibmyoEvent): LibmyoHandlerResult =
  let m = libmyoEventGetMyo(event)
  if (m != nil) and (libmyoEventGetType(event) == LibmyoEventType.emg):
    echo "EMG data"
  LibmyoHandlerResult.continueProcessing  


# initialize hub
if libmyoInitHub(addr hub, appId, addr errorDetails) != LibmyoResult.success:
  echo "Error: Failed to initialize hub"
else:
  while myo == nil:
    echo "Attempting to find a Myo..."
    if libmyoRun(hub, 1000, findMyoHandler, nil, addr errorDetails) != LibmyoResult.success:
      echo "Error: Failed to find devices"
      break

  # enable EMG stream
  if myo != nil:
    if libmyoSetStreamEmg(myo, LibmyoStreamEmg.enabled, addr errorDetails) != LibmyoResult.success:
      echo "Error: Failed to enable EMG stream"
    else:
      while true:
        if libmyoRun(hub, 50, runHandler, nil, addr errorDetails) != LibmyoResult.success:
          echo "Error: Failed to run main loop"
          break

  # shut down hub
  if libmyoShutdownHub(hub, addr errorDetails) != LibmyoResult.success:
    echo "Warning: Failed to shut down hub"
