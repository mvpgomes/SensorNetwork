#include "FeedingSpot.h"

module FeedingSpotC{
	provides interface FeedingSpot;
}
implementation {
	command FeedingSpot.dropFood(){
		return SUCCESS;
	}
}
