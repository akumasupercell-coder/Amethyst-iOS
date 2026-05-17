#import "KeyboardLayoutSwitcher.h"

static const NSString *PREF_KEY_LAYOUT = @"keyboard.layout";
static const NSString *PREF_KEY_TOGGLE = @"keyboard.toggle_key";

@interface KeyboardLayoutSwitcher ()
@property (nonatomic) KeyboardLayout currentLayout;
@property (nonatomic) UIKeyboardHIDUsage toggleKeyCode;
@property (nonatomic, strong) NSDictionary *qwertyToYozhikMap;
@property (nonatomic, strong) NSCharacterSet *lowerAlphaSet;
@end

@implementation KeyboardLayoutSwitcher

+ (instancetype)sharedManager {
    static KeyboardLayoutSwitcher *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KeyboardLayoutSwitcher alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize transliteration map QWERTY -> ЙЦУКЕН (Russian)
        self.qwertyToYozhikMap = @{
            // Top row
            @"q": @"й", @"w": @"ц", @"e": @"у", @"r": @"к", @"t": @"е",
            @"y": @"н", @"u": @"г", @"i": @"ш", @"o": @"щ", @"p": @"з",
            // Middle row
            @"a": @"ф", @"s": @"ы", @"d": @"в", @"f": @"а", @"g": @"п",
            @"h": @"р", @"j": @"о", @"k": @"л", @"l": @"д",
            // Bottom row
            @"z": @"я", @"x": @"ч", @"c": @"с", @"v": @"м", @"b": @"и", 
            @"n": @"т", @"m": @"ь",
            // Numbers and special chars (remain unchanged)
            @"0": @"0", @"1": @"1", @"2": @"2", @"3": @"3", @"4": @"4",
            @"5": @"5", @"6": @"6", @"7": @"7", @"8": @"8", @"9": @"9",
            @" ": @" ", @"-": @"-", @"_": @"_"
        };
        
        self.lowerAlphaSet = [NSCharacterSet lowercaseLetterCharacterSet];
        
        // Default toggle key is Caps Lock
        self.toggleKeyCode = UIKeyboardHIDUsageKeyboardCapsLock;
        
        // Load preferences from UserDefaults
        [self loadPreferences];
        
        NSLog(@"KeyboardLayoutSwitcher initialized. Current layout: %@",
              self.currentLayout == KeyboardLayoutRussian ? @"Russian" : @"English");
    }
    return self;
}

- (void)loadPreferences {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Load layout state
    NSInteger layoutValue = [defaults integerForKey:(NSString *)PREF_KEY_LAYOUT];
    self.currentLayout = (KeyboardLayout)layoutValue;
    
    // Load toggle key code
    NSInteger toggleKeyValue = [defaults integerForKey:(NSString *)PREF_KEY_TOGGLE];
    if (toggleKeyValue > 0) {
        self.toggleKeyCode = (UIKeyboardHIDUsage)toggleKeyValue;
    }
}

- (void)savePreferences {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:(NSInteger)self.currentLayout forKey:(NSString *)PREF_KEY_LAYOUT];
    [defaults setInteger:(NSInteger)self.toggleKeyCode forKey:(NSString *)PREF_KEY_TOGGLE];
    [defaults synchronize];
}

- (void)toggleLayout {
    self.currentLayout = (self.currentLayout == KeyboardLayoutEnglish) 
        ? KeyboardLayoutRussian 
        : KeyboardLayoutEnglish;
    
    [self savePreferences];
    
    NSLog(@"🔤 Keyboard layout switched to: %@", 
          self.currentLayout == KeyboardLayoutRussian ? @"Русский (Russian)" : @"English");
}

- (KeyboardLayout)currentLayout {
    return _currentLayout;
}

- (BOOL)isRussianLayoutActive {
    return self.currentLayout == KeyboardLayoutRussian;
}

- (NSString *)transliterateString:(NSString *)string {
    // If English layout is active, return string unchanged
    if (self.currentLayout == KeyboardLayoutEnglish) {
        return string;
    }
    
    if (!string || string.length == 0) {
        return string;
    }
    
    NSMutableString *result = [NSMutableString string];
    
    for (NSUInteger i = 0; i < string.length; i++) {
        NSString *character = [string substringWithRange:NSMakeRange(i, 1)];
        NSString *lowerChar = [character lowercaseString];
        
        // Try to find transliteration
        NSString *translated = self.qwertyToYozhikMap[lowerChar];
        
        if (translated) {
            // If original character was uppercase, uppercase the translation too
            if ([character isEqualToString:[character uppercaseString]] 
                && ![character isEqualToString:lowerChar]) {
                [result appendString:[translated uppercaseString]];
            } else {
                [result appendString:translated];
            }
        } else {
            // No transliteration found, keep original character
            [result appendString:character];
        }
    }
    
    return [result copy];
}

- (void)setToggleKeyCode:(UIKeyboardHIDUsage)keyCode {
    self.toggleKeyCode = keyCode;
    [self savePreferences];
}

- (UIKeyboardHIDUsage)getToggleKeyCode {
    return self.toggleKeyCode;
}

- (BOOL)isPressToggleKey:(UIPress *)press {
    if (!press.key) {
        return NO;
    }
    
    return press.key.keyCode == self.toggleKeyCode;
}

@end
