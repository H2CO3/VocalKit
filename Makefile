TARGET = VocalKit
OBJECTS = $(patsubst %.m,%.o,$(wildcard *.m))

INCLUDES = -Iinclude/pocketsphinx -Iinclude/sphinxbase
STATIC_LIBS = $(wildcard libs/*.a)
DYNAMIC_LIBS = -liconv
FRAMEWORKS = -framework Foundation -framework AudioToolbox
SYSROOT = /Developer/Platforms/iPhoneOS.platform/SDKs/iPhoneOS4.2.sdk

CC = /usr/local/bin/arm-apple-darwin9-gcc
LD = $(CC)
RM = rm
CP = cp

CFLAGS = -isysroot $(SYSROOT) -c -dynamiclib -std=gnu99 -Wall
LDFLAGS = -isysroot $(SYSROOT) -w -dynamiclib -install_name /System/Library/Frameworks/$(TARGET).framework/$(TARGET)
RMFLAGS = -rf
CPFLAGS = -r

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) $(DYNAMIC_LIBS) $(FRAMEWORKS) -o $@ $^ $(STATIC_LIBS)

%.o: %.m
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $^

install: $(TARGET)
	$(CP) $(CPFLAGS) $^ $(TARGET).framework/

clean:
	$(RM) $(RMFLAGS) $(TARGET) $(OBJECTS) *~

