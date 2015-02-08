#include <Timer.h>
#include "Collar.h"
#include "FeedingSpot.h"
#include "Gps.h"

configuration CollarAppC {
}
implementation {

  components MainC;
  components CollarC as App;
  components GpsP;
  components FeedingSpotP;

  components RandomC;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_COLLAR);
  components new AMReceiverC(AM_COLLAR);

  App.Boot -> MainC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.Gps -> GpsP;
  App.FeedingSpot -> FeedingSpotP;
 
  GpsP.Random -> RandomC;
}