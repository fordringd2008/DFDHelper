
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DFDHelper : NSObject

+ (void)performBlockInMain:(void(^)())block;

+ (void)performBlockInGlobal:(void(^)())block;

+ (void)performBlockInCurrentTheard:(void (^)())block;

+ (void)performBlockInMain:(void(^)())block afterDelay:(NSTimeInterval)delay;

+ (void)performBlockInGlobal:(void(^)())block afterDelay:(NSTimeInterval)delay;

+ (void)performBlockInCurrentTheard:(void (^)())block afterDelay:(NSTimeInterval)delay;

+ (NSString *)getIOSVersion;

+ (NSString *)getIOSName;

+ (BOOL)isAllowedNotification;

+ (int)getLanguage;

+ (NSString *)getPreferredLanguageStr;

+ (NSData *)getDataFromJSON:(NSString *)fileName;

+ (NSData *)getCountiesAndCitiesrDataFromJSON;

+ (void)clearNotification:(NSString *)name;

+ (void)addLocalNotification:(NSDate *)date
                     repeat:(NSCalendarUnit)repeat
                  soundName:(NSString *)soundName
                  alertBody:(NSString *)alertBody
 applicationIconBadgeNumber:(NSInteger)applicationIconBadgeNumber
                   userInfo:(NSDictionary *)userInfo;

+ (NSString *)typeForImageData:(NSData *)data;

+ (CGSize)getTextSizeWith:(NSString *)text
               fontNumber:(int)fontNumber
             biggestWidth:(CGFloat)biggestWidth;

+ (NSMutableArray *)setNSDestByOrder:(NSSet *)set orderStr:(NSString *)orderStr ascending:(BOOL)ascending;


+ (NSInteger)cTof:(NSInteger)c;

+ (BOOL)saveImageToDocoment:(NSData *)imageData name:(NSString *)name;

+ (NSString *)getCacheURL;

+ (NSString *)getDomentURL;

+ (NSArray *)getFileNamesFromURL:(NSString *)url;

+ (BOOL)isChineseInput;

+ (int)yearDay:(int)year;

+ (BOOL)isLeapYear:(int)year;

+ (NSMutableArray *)getXarrList:(NSInteger)year month:(NSInteger)month;

+ (NSInteger)getDaysByYearAndMonth:(NSInteger)year month:(NSInteger)month;

+ (NSMutableArray *)HmF2KIntToDate:(int)f2kDate;
+ (int)HmF2KDateToInt:(NSMutableArray *)array;

+ (int)HmF2KNSDateToInt:(NSDate *)date;
+ (NSDate *)HmF2KNSIntToDate:(int)dateValue;

+ (NSString *)toStringFromDateValue:(int)dateValue;

+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSMutableArray *)filterArr:(NSMutableArray *)arr;

+ (BOOL)isSysTime24;

+ (NSString *)toJsonStringForUpload:(NSObject *)obj;

+ (void)setLastSysDateTime:(NSDate *)date access:(NSString *)access;

+ (void)setLastUpLoadDateTime:(NSDate *)date access:(NSString *)access;

+ (NSDate *)getLastSysDateTime:(NSString *)access;

+ (NSDate *)getLastUpLoadDateTime:(NSString *)access;

+ (NSInteger)getWaterCountFromWater_array:(NSString *)water_array time_array:(NSString *)time_array;

+ (NSString *)getWater_array_Hour_FromArray:(NSString *)water_array time_array:(NSString *)time_array;

+ (NSMutableArray *)getHourMinuteSecondFormDateValue:(int)timeValue;

+ (NSDate *)getDateTimeFormDateValue:(int)timeValue;

+ (NSString *)intIntsToString:(int[])arr length:(int)length;

+ (NSString *)getMaxWaterOnTime:(NSString *)water_array time_array:(NSString *)time_array;

+ (NSData *)dicToData:(NSDictionary *)dic;

+ (NSDictionary *)dataTodic:(NSData *)data;

+ (NSDate *)getTimeFromInterval:(int)interval;

+ (NSString *)getTimeStringFromDate:(NSDate *)date;

+ (NSString *)getTimeStringFromInterval:(int)interval;

+ (int)getIntervalFromTime:(NSDate *)date;

+ (NSMutableArray *)sort:(NSMutableArray *)arr;

+ (NSString *)toStringByHourAndMinute:(NSNumber *)hour minute:(NSNumber *)minute;

+ (NSString *)toStringFromDist:(int)dist isMetric:(BOOL)isMetric;

+ (int)getFromDate:(NSDate *)date type:(int)type;

+ (NSDate *)getNowDateFromatAnDate:(NSDate *)date;

+ (NSDate *)clearTimeZone:(NSDate *)date;

+ (NSString *)dateToString:(NSDate *)date stringType:(NSString *)stringType;

+ (NSDate *)getDateFromArr:(NSArray *)arr;

+ (NSDate *)getDateFromString:(NSString *)strTime;

+ (NSString *)getStringFromDate:(NSDate *)date;

+ (NSDate *)toDate:(NSString *)string;

+ (NSDate *)toDateByString:(NSString *)string;

+ (BOOL)isToday:(NSDate *)date;

+ (NSString *)toStringForShow:(NSDate *)date;

+ (int)getAgeFromBirthDay:(NSDate *)date;

+ (void)getPictureFormPhotosOrCamera:(BOOL)isFromPhotos
                                  vc:(UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> *)vc
                   checekBeforeBlock:(void(^)())checekBeforeBlock;

+ (NSMutableArray *)sort:(NSMutableArray *)arr byString:(NSString *)byString;

+ (void)backToVcByNav:(UINavigationController *)nav
               vcName:(NSString *)vcName
             animated:(BOOL)animated;

+ (NSDate *)getDateFromLong:(long long) miliSeconds;

+ (long long)getLongFromDate:(NSDate *)datetime;


@end
