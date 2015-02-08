#include "Gps.h"

module GpsC{
	provides interface Gps;
}
implementation {
	command Gps.getPosition(){
		return SUCCESS;
	}
}
