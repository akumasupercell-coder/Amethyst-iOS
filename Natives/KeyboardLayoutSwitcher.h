#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    KeyboardLayoutEnglish = 0,
    KeyboardLayoutRussian = 1
} KeyboardLayout;

@interface KeyboardLayoutSwitcher : NSObject

/// Get the shared singleton instance
+ (instancetype)sharedManager;

/// Toggle between English and Russian keyboard layouts
- (void)toggleLayout;

/// Get current keyboard layout
- (KeyboardLayout)currentLayout;

/// Check if Russian layout is active
- (BOOL)isRussianLayoutActive;

/// Transliterate a character or string based on current layout
/// If layout is Russian, transliterates QWERTY to ЙЦУКЕН
/// Otherwise returns the string unchanged
- (NSString *)transliterateString:(NSString *)string;

/// Set the toggle key (e.g., "CapsLock", "RightAlt", "F12", or custom)
- (void)setToggleKeyCode:(UIKeyboardHIDUsage)keyCode;

/// Get current toggle key code
- (UIKeyboardHIDUsage)getToggleKeyCode;

/// Check if a UIPress represents the toggle key
- (BOOL)isPressToggleKey:(UIPress *)press;

/// Load saved preferences from UserDefaults
- (void)loadPreferences;

/// Save current state to UserDefaults
- (void)savePreferences;

NS_ASSUME_NONNULL_END
