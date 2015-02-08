COMPONENT=CollarAppC
BUILD_EXTRA_DEPS = RadioCollarMsg.py RadioCollarMsg.class
CLEAN_EXTRA = RadioCollarMsg.py RadioCollarMsg.class RadioCollarMsg.java

RadioCollarMsg.py: Collar.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=RadioCollarMsg Collar.h RadioCollarMsg -o $@

RadioCollarMsg.class: RadioCollarMsg.java
	javac RadioCollarMsg.java

RadioCollarMsg.java: Collar.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=RadioCollarMsg Collar.h RadioCollarMsg -o $@


include $(MAKERULES)

