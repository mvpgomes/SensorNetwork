#include "FeedingSpot.h"
#include "math.h"

module FeedingSpotP {
	provides interface FeedingSpot;
}
implementation {

	uint16_t TAG = 1;
	
	command void FeedingSpot.deliverFood(uint16_t x_coordinate, uint16_t y_coordinate){
		// This condition must verify if the coordinates passed matches with
		// one of the feeding spots.
		if( (abs(X_COORDINATE - x_coordinate) <= 1) && (abs(Y_COORDINATE - y_coordinate) <= 1) ){
			signal FeedingSpot.deliverDone(SUCCESS, TAG);
			dbg("CollarC", "FeedingSpot dropped food.\n"); 
		}
		else {
			signal FeedingSpot.deliverDone(FAIL, -1);
		}
	}
}
