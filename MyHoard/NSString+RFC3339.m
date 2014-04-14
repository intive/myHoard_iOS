
//https://gist.github.com/mwaterfall/953664

#import "NSString+RFC3339.h"

@implementation NSString (RFC3339)

- (NSDate *)dateFromRFC3339String
{
	// Create date formatter
	static NSDateFormatter *dateFormatter = nil;
	if (!dateFormatter) {
		NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:en_US_POSIX];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	}
	
	// Process date
	NSDate *date = nil;
	NSString *RFC3339String = [[NSString stringWithString:self] uppercaseString];
	RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];
	// Remove colon in timezone as iOS 4+ NSDateFormatter breaks. See https://devforums.apple.com/thread/45837
	if (RFC3339String.length > 20) {
		RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":"
																 withString:@""
																	options:0
																	  range:NSMakeRange(20, RFC3339String.length-20)];
	}
	if (!date) { // 1996-12-19T16:39:57-0800
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
		date = [dateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01T12:00:27.87+0020
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
		date = [dateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01 12:00:27.879876
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss.SSSSSS"];
		date = [dateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01T12:00:27
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
		date = [dateFormatter dateFromString:RFC3339String];
	}
	if (!date) NSLog(@"Could not parse RFC3339 date: \"%@\" Possibly invalid format.", self);
	return date;
}

@end
