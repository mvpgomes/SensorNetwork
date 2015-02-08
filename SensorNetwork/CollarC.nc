#include <Timer.h>
#include "Collar.h"

module CollarC {
	uses interface Boot;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface Gps;
  uses interface FeedingSpot;
 }

implementation {

  uint16_t received_msg_id;
  uint16_t previous_received_msg_id;
	uint16_t x_coordinate;
  uint16_t y_coordinate;
  uint16_t animal_daily_consumption;
  uint16_t food_amount_dropped;
  uint16_t food_amount_eated;
  uint16_t food_amount_available;
  uint16_t feeding_spot_food_amount;
	message_t pkt;
	bool busy = FALSE;

  event void Boot.booted() {
    call AMControl.start();
    call Gps.getCoordinates();
  }   

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_UPDATE);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired(){
    if(!busy){
      // actualize the coordinates
      uint32_t time_elapsed = call Timer0.getdt();
      call Gps.updateCoordinates(time_elapsed);
      if(food_amount_eated <= animal_daily_consumption){
        call FeedingSpot.deliverFood(x_coordinate, y_coordinate);
      }
    }
  }
  
  event void AMSend.sendDone(message_t* msg, error_t err) {
    dbg("CollarC", "sendDone\n");
    previous_received_msg_id = received_msg_id;
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    dbg("CollarC", "Received\n");
    if (len == sizeof(RadioCollarMsg)) {
      RadioCollarMsg* crmpkt = (RadioCollarMsg*)payload;
      // Change the payload value to retransmit the message received
      uint16_t type = crmpkt->msg_type;
      uint16_t id = crmpkt->msg_id;
      RadioCollarMsg* data = (RadioCollarMsg*)(call Packet.getPayload(&pkt, sizeof(RadioCollarMsg)));
      data->msg_type = type;
      data->msg_id = id;

      dbg("CollarC", "Message ID - %u\n", crmpkt->msg_id);

      // Verifies if the message already was received
      if(previous_received_msg_id == crmpkt->msg_id){
        return msg;
      }
      // Update the id of the last received message
      received_msg_id = crmpkt->msg_id;

      // Verify the message type and give the information
      if(type == LOCATION){
        dbg("CollarC", "Node position - X : %u Y : %u\n", x_coordinate, y_coordinate);
      }
      else if(type == ANIMAL_FOOD_AMOUNT){
        dbg("CollarC", "Food ate %d", food_amount_eated);
      }
      else if(type == SPOT_REMAINING_FOOD_AMOUNT){
        dbg("CollarC", "Remaining food at the FeedingSpot : %u\n", food_amount_available);
      }
      else if(type == DAILY_ANIMAL_CONSUMPTION){
        animal_daily_consumption = crmpkt->food_amount;
        dbg("CollarC", "Animal portion food updated to : %u\n", animal_daily_consumption);
      }
      else {
        feeding_spot_food_amount = crmpkt->food_amount;
        dbg("CollarC", "FeedingSpot food amount updated to : %u\n", feeding_spot_food_amount);
      }
      // Retransmmits the message
      if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(RadioCollarMsg)) == SUCCESS) {
          dbg("CollarC", "Sending...\n");  
          busy = TRUE;
        }
      }
    return msg;
  }

  event void Gps.coordinatesDone(error_t err, uint16_t x, uint16_t y){
    if(err == SUCCESS){
      x_coordinate = x;
      y_coordinate = y;
    }
  }

  event void FeedingSpot.deliverDone(error_t err, uint16_t feedingSpotId){
    if(err == SUCCESS){
      food_amount_eated += food_amount_dropped;
      food_amount_available -= food_amount_dropped;
      if(!busy){
        // update message to other nodes
        RadioCollarMsg* fsdata = (RadioCollarMsg*)(call Packet.getPayload(&pkt, sizeof(RadioCollarMsg)));
        fsdata->msg_type =  SPOT_REMAINING_FOOD_AMOUNT;
        fsdata->food_amount = food_amount_available;
        if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(RadioCollarMsg)) == SUCCESS) {
          dbg("CollarC", "Updating FeedingSpot food amount to other nodes ...\n");  
          busy = TRUE;
        }
      }
    }
  }
}