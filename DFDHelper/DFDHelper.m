
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "DFDHelper.h"

#define DFDGetUD(key)    [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define DFDSetUD(k, v)   [[NSUserDefaults standardUserDefaults] setObject:v forKey:k]; [[NSUserDefaults standardUserDefaults]  synchronize];
#define DFDRemoveUD(k)   [[NSUserDefaults standardUserDefaults] removeObjectForKey:k]; [[NSUserDefaults standardUserDefaults] synchronize];

#define DFDkS(_S)        NSLocalizedString(_S, @"")
#define DFDNow           [NSDate date]

@implementation DFDHelper

// 在主线程执行
// 可以用在复杂页面的延迟绘制中
+ (void)performBlockInMain:(void(^)())block{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

// 在全局线程(后台线程)中执行
+ (void)performBlockInGlobal:(void(^)())block{
    [self performBlockInGlobal:block afterDelay:0];
}

// 在当前线程中执行(当前线程为非主线程)
+ (void)performBlockInCurrentTheard:(void (^)())block{
    [self performBlockInCurrentTheard:block afterDelay:0];
}

// 在几秒后主线程中执行
+ (void)performBlockInMain:(void(^)())block afterDelay:(NSTimeInterval)delay{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

// 在几秒后后台线程中执行
+ (void)performBlockInGlobal:(void(^)())block afterDelay:(NSTimeInterval)delay{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{block();});
}

// 在几秒后当前线程中执行(当前线程为非主线程)
+ (void)performBlockInCurrentTheard:(void (^)())block afterDelay:(NSTimeInterval)delay{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^{block();});
}

// 获取版本号
+ (NSString *)getIOSVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

// 获取APP名称 (中文下中文，多语言时为当前语言时的APP名称)
+ (NSString *)getIOSName{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

// APP是否允许通知
+ (BOOL)isAllowedNotification
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8)
    {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        return UIUserNotificationTypeNone != setting.types;
    }
    else
    {
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        return  UIRemoteNotificationTypeNone != type;
    }
}

// 获取当前语言环境   1:中文  2:英文  3:法文  4:西班牙
// 此方法需要配合APPDelegate中删除 UserDefaults 中的 DFDCurrentLanguage
+ (int)getLanguage
{
    int langIn = [(NSNumber *)DFDGetUD(@"DFDCurrentLanguage") intValue];
    if (langIn) return langIn;
    NSString * pre = [self getPreferredLanguageStr];
    if ([pre isEqualToString:@"zh"]) {
        langIn = 1;
    }
    else if([pre isEqualToString:@"en"])
    {
        langIn =  2;
    }
    else if([pre isEqualToString:@"fr"])
    {
        langIn =  3;
    }
    else if([pre isEqualToString:@"es"])
    {
        langIn =  4;
    }
    
    DFDSetUD(@"DFDCurrentLanguage", @(langIn));
    return langIn;
}

// 获取当前语言的字符串
+ (NSString *)getPreferredLanguageStr
{
    return [[(NSArray *)DFDGetUD(@"AppleLanguages") objectAtIndex:0] substringWithRange:NSMakeRange(0, 2)];
}

// 从工程目录中的json文件中获取NSData
+ (NSData *)getDataFromJSON:(NSString *)fileName
{
    NSData *jdata = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"json"]];
    NSError *error = nil;
    if (jdata) {
        NSData * adata = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
        return adata;
    }
    return nil;
}


// 删除本地通知 根据userinfo中是否还有 name    name为nil时 删除所有
+ (void)clearNotification:(NSString *)name
{
    if(name)
    {
        NSArray *arrNotification =[[UIApplication sharedApplication] scheduledLocalNotifications];
        for(int i = 0; i  < arrNotification.count ; i++)
        {
            UILocalNotification *not = arrNotification[i];
            if (not.userInfo && [not.userInfo.allKeys containsObject:name])
            {
                [[UIApplication sharedApplication] cancelLocalNotification:not];
            }
        }
    }
    else [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

// 添加本地通知
+ (void)addLocalNotification:(NSDate *)date
                      repeat:(NSCalendarUnit)repeat
                   soundName:(NSString *)soundName
                   alertBody:(NSString *)alertBody
  applicationIconBadgeNumber:(NSInteger)applicationIconBadgeNumber
                    userInfo:(NSDictionary *)userInfo
{
    UILocalNotification *notifi          = [[UILocalNotification alloc]init];
    notifi.repeatInterval                = repeat ;
    notifi.fireDate                      = date;
    notifi.timeZone                      = [NSTimeZone defaultTimeZone];
    notifi.soundName                     = soundName;
    notifi.alertBody                     = alertBody;
    notifi.applicationIconBadgeNumber    = applicationIconBadgeNumber;
    notifi.userInfo                      = userInfo;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
    UIUserNotificationType type          = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    notifi.repeatInterval                = repeat;
    [[UIApplication sharedApplication] scheduleLocalNotification:notifi];
}

// 获取 Image 的图片类型 data：image的NSData
+ (NSString *)typeForImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

// 把 NSSet 按照指定的字段进行排序 返回 NSMutableArray
+ (NSMutableArray *)setNSDestByOrder:(NSSet *)set
                            orderStr:(NSString *)orderStr
                           ascending:(BOOL)ascending
{
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:orderStr ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
    return [[set sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

// 根据label的字体大小， 最大宽度， 文字， 获取需要的高度 不包括上下间距
+ (CGSize)getTextSizeWith:(NSString *)text
               fontNumber:(int)fontNumber
             biggestWidth:(CGFloat)biggestWidth
{
    CGSize sizeBiggest = CGSizeMake(biggestWidth,MAXFLOAT);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByWordWrapping]; // NSLineBreakByCharWrapping
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:fontNumber], NSParagraphStyleAttributeName : style };
    CGSize size = [text boundingRectWithSize:sizeBiggest
                                   options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                attributes:attributes context:nil].size;
    return size;
}

// 摄氏温度转化成华氏温度
+ (NSInteger)cTof:(NSInteger)c
{
    // 华氏度 = 32 + 摄氏度 × 1.8
    double fD = 32 + c * 1.8;
    return (NSInteger)fD;
}

// 保存图片到Document下的指定文件夹
+ (BOOL)saveImageToDocoment:(NSData *)imageData
                       name:(NSString *)name
{
    NSString *norPicPath = [self dataPath:name];
    BOOL norResult = [imageData writeToFile:norPicPath atomically:YES];
    if (norResult) {
        return YES;
    }else {
        NSLog(@"图片保存不成功");
        return NO;
    }
}

// 获取Document下的具体文件的路径
+ (NSString *)dataPath:(NSString *)file
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@""];
    BOOL bo;
    bo = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    bo = bo;
    return [path stringByAppendingPathComponent:file];
}

// 获取缓存目录
+ (NSString *)getCacheURL{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

// 获取Document目录
+ (NSString *)getDomentURL{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

// 获取具体目录下的所有文件名的集合
+ (NSArray *)getFileNamesFromURL:(NSString *)url{
    return [[NSArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:url error:nil]];
}

// 判断当前的输入方是否是中文
+ (BOOL)isChineseInput{
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    return ([lang isEqualToString:@"zh-hans"] || [lang isEqualToString:@"zh-hant"]);
}

// 返回年的天数
+ (int)yearDay:(int)year{
    return [self isLeapYear:year] ? 366:365;
}

// 判断是否是闰年
+ (BOOL)isLeapYear:(int)year{
    return ((year%4==0)&&(year%100!=0))||(year%400==0);
}

// 根据月份获得这个月的所有天的集合
+ (NSMutableArray *)getXarrList:(NSInteger)year month:(NSInteger)month
{
    NSInteger count = [self getDaysByYearAndMonth: year month: month];
    NSMutableArray *arr = [NSMutableArray new];
    for (int i = 0; i < count; i++)
        [arr addObject:[NSString stringWithFormat:@"%d", i + 1]];
    return arr;
}

// 获得具体的年月里有多少天
+ (NSInteger)getDaysByYearAndMonth:(NSInteger)year month:(NSInteger)month
{
    NSInteger count = 0;
    if (month == 4 || month == 6 || month == 9 || month == 11)
    {
        count = 30;
    }
    else if (month == 2)
    {
        if ([self isLeapYear:(int)year])
            count = 29;
        else
            count = 28;
    }
    else count = 31;
    return  count;
}


+ (int)monthDays:(int)year month:(int)month
{
    int days = 31;
    if ( month == 1 ) 		//	feb
    {
        days=28;
        if([self isLeapYear:year]){
            days+=1;
        }
    }
    else
    {
        if ( month > 6 )		//	8月->7月	 9月->8月...
        {
            month--;
        }
        int s = month&1;
        if (s==1)
        {
            days--;			//	30天
        }
    }
    return days;
}

// ------------------------------------------------------ 这两个是一对 ↓↓↓↓↓↓↓↓↓↓↓↓↓
// dic -> json
+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *error = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"dic -> json失败：%@",error);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

// json -> dic
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (!jsonString) return nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
        NSLog(@"json -> dic失败：%@",error);
        return nil;
    }
    return dic;
}
// ------------------------------------------------------ 这两个是一对 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑


//   把末尾的 0 过滤掉  如果都是 0 返回空的数组
+(NSMutableArray *)filterArr:(NSMutableArray *)arr
{
    NSMutableArray *arrNew = [NSMutableArray new];
    NSMutableArray* reversedArray = [[[arr reverseObjectEnumerator] allObjects] mutableCopy];
    
    BOOL isNotFi = NO;
    for (int i = 0; i < arr.count; i++)
    {
        NSString *st = reversedArray[i];
        if ([st integerValue] || isNotFi)
        {
            [arrNew addObject:st];
            isNotFi = YES;
        }
        else
        {
            isNotFi = NO;
        }
    }
    return [[[arrNew reverseObjectEnumerator] allObjects] mutableCopy];
}

// 当前是否是24小时
// 需要配合 AppDelegate 中 删除 DFDis24
+(BOOL)isSysTime24
{
    NSNumber *sysTime = DFDGetUD(@"DFDis24");
    if (sysTime) return [sysTime boolValue];
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    DFDSetUD(@"DFDis24", @(!hasAMPM));
    return !hasAMPM;
}


//  把复杂的数据集合 转化成json字符串  为上传使用
+(NSString *)toJsonStringForUpload:(NSObject *)obj
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString : @"\r\n" withString : @""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString : @"\n" withString : @"" ];
    jsonString = [jsonString stringByReplacingOccurrencesOfString : @"\t" withString : @"" ];
    jsonString = [jsonString stringByReplacingOccurrencesOfString : @"\\" withString : @"" ];
    return jsonString;
}


// 从喝水集合中获取喝水总量 (过滤掉相同时间点的数据)
+ (NSInteger)getWaterCountFromWater_array:(NSString *)water_array time_array:(NSString *)time_array
{
    NSArray *arrData = [water_array componentsSeparatedByString:@","];
    NSArray *arrTi = [time_array componentsSeparatedByString:@","];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (int i = 0; i < arrData.count; i++) {
        [dic setObject:arrData[i] forKey:[arrTi[i] description]];
    }
    
    NSInteger waterCount = 0;
    for (int i = 0 ; i < dic.count; i++)
    {
        waterCount += [dic.allValues[i] integerValue];
    }
    return waterCount;
}

// 从int数组 拼接字符串
+ (NSString *)intIntsToString:(int[])arr length:(int)length
{
    NSMutableString *strResult = [NSMutableString new];
    for (int i = 0; i < length; i++)
    {
        NSString *str = [NSString stringWithFormat:@"%d", arr[i]];
        [strResult appendString:str];
        if (i != length - 1)
        {
            [strResult appendString:@","];
        }
    }
    return strResult;
}


+ (NSData *)dicToData:(NSDictionary *)dic
{
    if (!dic) return nil;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"Some Key Value"];
    [archiver finishEncoding];
    return data;
}

+ (NSDictionary *)dataTodic:(NSData *)data
{
    if (!data) return nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *myDictionary = [unarchiver decodeObjectForKey:@"Some Key Value"];
    [unarchiver finishDecoding];
    return myDictionary;
}

// 根据距离00：00 的时间差 获取现在的时候， 返回  NSDate
+ (NSDate *)getTimeFromInterval:(int)interval
{
    NSDate *date0 = [self clearTimeZone:[self getDateFromArr:@[ @0,@0,@0,@0 ]]];
    NSDate *dateRemind = [NSDate dateWithTimeInterval:interval * 60 sinceDate:date0];
    return dateRemind;
}

// ------------------------------------------------------ 这两个是一对 ↓↓↓↓↓↓↓↓↓↓↓↓↓
// ------------------------------------------------------ 这两个是一对 ↓↓↓↓↓↓↓↓↓↓↓↓↓
//  根据距离00：00 的时间差 获取现在的时候， 返回  07：21
+ (NSString *)getTimeStringFromInterval:(int)interval
{
    NSDate *date0 = [self getDateFromArr:@[@0,@0,@0,@0]];
    NSDate *dateRemind = [NSDate dateWithTimeInterval:interval * 60 sinceDate:date0];
    dateRemind = dateRemind;
    
    NSString *str = [self dateToString:dateRemind stringType:@"HH:mm"];
    str = [self getTimeStringFromDate:dateRemind];
    return str;
}

//  根据传入的时间算出距离当日00：00的间隔（分钟）        和上面是一对
+ (int)getIntervalFromTime:(NSDate *)date
{
    NSDate *date0 = [self clearTimeZone:[self getDateFromArr:@[@0,@0,@0,@0]]];
    int interval = [date timeIntervalSinceDate:date0] / 60;
    return interval;
}


//  把 距离转换成 显示的字符  800 ——> 800米   1800 ——>  1.8公里
+ (NSString *)toStringFromDist:(int)dist isMetric:(BOOL)isMetric
{
    NSString *disStr;
    if (isMetric) {
        disStr = dist >= 1000 ? [NSString stringWithFormat:@"%.2f%@", dist / 1000.0, DFDkS(@"公里")] : [NSString stringWithFormat:@"%d%@", dist, DFDkS(@"米")];
    }else{
        CGFloat distMi = dist / 1000.0 * 0.6213712;
        disStr = distMi >= 1 ? [NSString stringWithFormat:@"%.2f%@", distMi, DFDkS(@"英里")]: [NSString stringWithFormat:@"%.0f%@", distMi * 5280, DFDkS(@"英尺")];;
    }
    return disStr;
}


+ (int)getFromDate:(NSDate *)date type:(int)type
{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    switch (type) {
        case 1:
            return (int)[comps year];
            break;
        case 2:
            return (int)[comps month];
            break;
        case 3:
            return (int)[comps day];
            break;
        case 4:
            return (int)[comps hour];
            break;
        case 5:
            return (int)[comps minute];
            break;
        case 6:
            return (int)[comps second];
            break;
        case 7:
            return (int)([comps weekday] - 1);
            break;
    }
    return 0;
}

// 从日期数组中，获取日期
// 数组个数=3， 里面放的是年月日
// 数组个数=6， 里面放的是年月日时分秒
// 数组个数=4， 里面放的是时分秒 这个不关心年月日
+ (NSDate *)getDateFromArr:(NSArray *)arr
{
    NSString *strDate;
    if (arr.count == 3)
    {
        int year          = [arr[0] intValue];
        int month         = [arr[1] intValue];
        int day           = [arr[2] intValue];
        strDate           = [NSString stringWithFormat:@"%d-%02d-%02d 00:00:00 000", year, month, day];
    }
    else if(arr.count == 6)
    {
        int year          = [arr[0] intValue];
        int month         = [arr[1] intValue];
        int day           = [arr[2] intValue];
        int hour          = [arr[3] intValue];
        int minute        = [arr[4] intValue];
        int second        = [arr[5] intValue];
        strDate           = [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d 000", year, month, day, hour, minute , second];
    }
    else if(arr.count == 4)
    {
        NSDate *now         = DFDNow;
        int year            = [self getFromDate:now type:1];
        int month           = [self getFromDate:now type:2];
        int day             = [self getFromDate:now type:3];
        int hour            = [arr[0] intValue];
        int minute          = [arr[1] intValue];
        int second          = [arr[2] intValue];
        strDate             = [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d 000", year, month, day, hour, minute, second];
    }
    return  [self toDate:strDate];
}


//把任意时区的日期转换为现在的时区
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)date
{
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date] ;
    return destinationDateNow;
}

// 忽略时区
+ (NSDate *)clearTimeZone:(NSDate *)date
{
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:-interval sinceDate:date] ;
    return destinationDateNow;
}

// 原来的 Date toString
// 把日期转换成指定的格式   //  如果是 小时分钟 类似  hh:mm a  这样的， 应该使用 getTimeStringFromDate
+ (NSString *)dateToString:(NSDate *)date
                stringType:(NSString *)stringType
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:stringType];
    return [dateformatter stringFromDate:date];
}

// 把出入的日期 转化化为  7:13AM   8:45PM
+ (NSString *)getTimeStringFromDate:(NSDate *)date
{
    NSString *result;
    if ([self isSysTime24])
        result = [self dateToString:[self clearTimeZone:date] stringType:@"hh:mm"];
    else
    {
        int hourInt = [self getFromDate:[self clearTimeZone:date] type:4];
        int minuteInt = [self getFromDate:[self clearTimeZone:date] type:5];
        hourInt = hourInt == 0 ? 24 : hourInt;
        
        result = [NSString stringWithFormat:@"%d:%02d%@",
                         (hourInt > 12 ? hourInt - 12 : hourInt),
                         minuteInt,
                         ((hourInt >= 12 && hourInt != 24) ? @"PM":@"AM")];
    }
    return result;
}

// 从 0930 获取日期
+ (NSDate *)getDateFromString:(NSString *)strTime
{
    if (strTime.length < 4) return nil;
    int hour = [[strTime substringWithRange:NSMakeRange(0, 2)] intValue];
    int minute = [[strTime substringWithRange:NSMakeRange(2, 2)] intValue];
    return [self clearTimeZone:[self getDateFromArr:@[@(hour),@(minute),@0,@0]]];
}

// 从日期获取 0930
+ (NSString *)getStringFromDate:(NSDate *)date
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *locationString=[dateformatter stringFromDate:date];
    return locationString;
}


// 这个是原来的 toDate  没有参数
//  1989-09-09 10:22:23 000   ---> NSDate
+ (NSDate *)toDate:(NSString *)string
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
    return [dateFormater dateFromString:string];
}

// 这个是原来的 toDate:intString
// 19890302 或者是 19910201202332 --> NSDate
+ (NSDate *)toDateByString:(NSString *)intString
{
    NSArray *arr;
    if (intString.length == 8)
    {
        int year  = [[intString substringWithRange:NSMakeRange(0, 4)] intValue];
        int month = [[intString substringWithRange:NSMakeRange(4, 2)] intValue];
        int day   = [[intString substringWithRange:NSMakeRange(6, 2)] intValue];
        
        arr = @[ @(year),@(month),@(day)];
    }
    else if (intString.length == 16)
    {
        int year   = [[intString substringWithRange:NSMakeRange(0, 4)] intValue];
        int month  = [[intString substringWithRange:NSMakeRange(4, 2)] intValue];
        int day    = [[intString substringWithRange:NSMakeRange(6, 2)] intValue];
        int hour   = [[intString substringWithRange:NSMakeRange(8, 2)] intValue];   // 4 -> 2
        int minute = [[intString substringWithRange:NSMakeRange(10, 2)] intValue];
        int second = [[intString substringWithRange:NSMakeRange(12, 2)] intValue];
        
        arr = @[@(year),@(month),@(day),@(hour),@(minute),@(second)];
    }
    
    
    NSDate *date = [self getDateFromArr:arr];
    if (!date) {
        NSLog(@"尼玛  日期错误啦 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        return DFDNow;
    }
    return  date;
}

// 是否是当天
+ (BOOL)isToday:(NSDate *)date
{
    if (!self) return NO;
    NSDate *now   = DFDNow;
    int year      = [self getFromDate:now type:1];
    int month     = [self getFromDate:now type:2];
    int day       = [self getFromDate:now type:3];

    int yearThis  = [self getFromDate:date type:1];
    int monthThis = [self getFromDate:date type:2];
    int dayThis   = [self getFromDate:date type:3];
    if (year == yearThis && month == monthThis && day == dayThis)
        return YES;
    else
        return NO;
}


// 获取年龄
+ (int)getAgeFromBirthDay:(NSDate *)date
{
    return [DFDNow timeIntervalSinceDate:date] / (3600*24*365);
}

// 获取照片
// isFromPhotos:YES:从相册  NO:从摄像头
// 当前的控制器
// 调用前检查
+ (void)getPictureFormPhotosOrCamera:(BOOL)isFromPhotos
                                  vc:(UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> *)vc
                   checekBeforeBlock:(void(^)())checekBeforeBlock
{
    checekBeforeBlock();
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = vc;
    picker.allowsEditing = YES;
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if(isFromPhotos)                                                        // 相册
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        }
    }
    else                                                                    // 摄像头
    {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            NSLog(@"模拟器打不开相机");
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        picker.sourceType = sourceType;
    }
    [vc.navigationController presentViewController:picker animated:YES completion:^{ }];
}

// 给数组中的字典排序，按照指定的key, 由大到小
+ (NSMutableArray *)sort:(NSMutableArray *)arr
                byString:(NSString *)byString
{
    [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        int a  = [((NSDictionary *)obj1)[byString] intValue];
        int b = [((NSDictionary *)obj2)[byString] intValue];
        
        if (a < b) {
            return NSOrderedDescending;
        } else if (a > b) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    return arr;
}

// 滚回到指定的控制器
+ (void)backToVcByNav:(UINavigationController *)nav
               vcName:(NSString *)vcName
             animated:(BOOL)animated
{
    for (UIViewController *vc in nav.viewControllers) {
        if ([[[vc class] description] isEqualToString:vcName]) {
            [nav popToViewController:vc animated:animated];
            break;
        }
    }
}

// 从longlong的13位毫秒时间戳中获取日期
+ (NSDate *)getDateFromLong:(long long) miliSeconds
{
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli / 1000.0;
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

//从日期获取longlong的13位毫秒时间戳
+ (long long)getLongFromDate:(NSDate *)datetime
{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    long long totalMilliseconds = interval * 1000 ;
    return totalMilliseconds;
}

//设置APP角标
+ (void)setIconNumber:(int)num
{
    UIApplication *app = [UIApplication sharedApplication];
    if (app.applicationIconBadgeNumber != num) {
        if([[UIDevice currentDevice]systemVersion].floatValue >= 8)
        {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
        app.applicationIconBadgeNumber = num;
    }
}

@end
