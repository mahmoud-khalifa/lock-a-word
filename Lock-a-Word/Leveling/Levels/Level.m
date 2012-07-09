//
//  Level.m
//

#import "Level.h"

@implementation Level

// Synthesize variables
@synthesize name = _name;
@synthesize number = _number;
@synthesize unlocked = _unlocked;
@synthesize stars = _stars;
@synthesize data = _data;
@synthesize goldenTileFound=_goldenTileFound;

// Custom init method takes a variable 
// for each class instance variable
- (id)initWithName:(NSString *)name 
            number:(int)number 
          unlocked:(BOOL)unlocked 
             stars:(int)stars 
              data:(NSString *)data
            goldenTileFound:(BOOL)goldenTileFound{

    if ((self = [super init])) {

        // Set class instance variables based 
        // on values given to this method
        self.name = name;  
        self.number = number;
        self.unlocked = unlocked;
        self.stars = stars;
        self.data = data;
        self.goldenTileFound=goldenTileFound;
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}

@end