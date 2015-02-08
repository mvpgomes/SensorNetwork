interface FeedingSpot{
	// implemented by te provider
	command void deliverFood(uint16_t x_coordinate, uint16_t y_coordinate);
	// implemented by the user
	event void deliverDone(error_t err, uint16_t feddingSpotId);
}