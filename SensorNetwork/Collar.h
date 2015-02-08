#ifndef COLLAR_H
#define COLLAR_H

enum {
  AM_COLLAR = 255,
  TIMER_PERIOD_MILLI = 250,
  TIMER_PERIOD_UPDATE = 2500,
  LOCATION = 0,
  ANIMAL_FOOD_AMOUNT = 1,
  SPOT_REMAINING_FOOD_AMOUNT = 2,
  DAILY_ANIMAL_CONSUMPTION = 3,
  DAILY_FEEDING_SPOT_DROP = 4,
  NODE_LOWEST_ID = 0,
  NODE_HIGHEST_ID = 17
};

typedef nx_struct RadioCollarMsg {
  nx_uint16_t msg_id;
  nx_uint16_t msg_type;
  nx_uint16_t food_amount;
} RadioCollarMsg;

#endif
