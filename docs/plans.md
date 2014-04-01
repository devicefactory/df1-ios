Features
========

The library should aim to make most of the features of the accelerometer accessible
via BLE. The accelerometer has slew of configuration options, and depending on the
config, variety of events can be received.

The structure of the library should be organized such that it can expose
functions related to these 3 main areas:

1. BLE Connectivity
2. Data Subscription
3. Data Manipulation

On top of these basic functionalities, extra layer of API's can use the data
and give software generated events. The user will have to define specific data
"recipe", which defines specific sequence of accelerometer data conditions or
events that can trigger a more sophisticated event.

These recipes can look like the following.

Action sequences:

  z-axis change over 1g -> 0.5 sec wait -> tap detected 

On successful sequence of tree conditions, call user registered callback
or fireoff a delegate function:
    
  didTriggerCustomEvent
  
These can be implemented as runtime definable state machines.


1. BLE Connectivity
-------------------

Delegate is required, and it should call these delegates upon status change.

* scan
  - didScan

* connect
  - didConnect

* disconnect
  - didDisconnect

OTA related functions

* update
  - didUpdate:peripheral error:err


2. Data Subscription
--------------------

Each subscription function should accept user specific config (perhaps just bitmask
bytes??) and pass the config data to appropriate BLE UUID. Of course, the firmware
needs to support accel config change over BLE, but also make sensible defaults.

* subscribeXYZ(config)
  - didSubscribeXYZ

* subscribeTap(config)
  - didSubscribeTap

* subscribeFreefall(config)
  - didSubscribeFreefall

* subscribeTransient(config)
  - didSubscribeTransient

* unsubscribe(events)
  - didUnsubscribe

* delegate functions
  - receivedXYZ
  - receivedTap
  - receivedFreefall
  - receivedTransient


3. Data Manipulation
--------------------

Numerical capabilities should be presented here.

* doFFT
* doMA(window)
* doEE(window) : energy expenditure, Euclidean distance of diffs
* doMax(array) 
* doMin(array)

* subscribeFFT(config)
  - calls subscribeXYZ under the hood if not enabled already

* subscribeMA(config)
  - calls subscribeXYZ under the hood if not enabled already


Considerations
==============

BLE protocol itself is hardware agnostic. That is, it is designed for interoperability across variety
of manufacturers and their implementations. As such, it's important to recognize that the iOS library
can be made portable across future motion-sensor devices. Move3 can be the prototyping ground, but
the carefully designed library can be extended to work with devices with better motion sensors in the future.

As long as the UUID are consistent and the mechanisms for configuring the underlying hardware sensors stay
compatible, the library can go a long way to create an ecosystem that can be used across generation of devices.
