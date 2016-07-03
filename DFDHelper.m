
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "DFDHelper.h"

#define GetUD(key)    [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define SetUD(k, v)   [[NSUserDefaults standardUserDefaults] setObject:v forKey:k]; [[NSUserDefaults standardUserDefaults]  synchronize];
#define RemoveUD(k)   [[NSUserDefaults standardUserDefaults] removeObjectForKey:k]; [[NSUserDefaults standardUserDefaults] synchronize];

#define kS(_S)        NSLocalizedString(_S, @"")
#define DNow          [NSDate date]

@implementation DFDHelper

+ (void)performBlockInMain:(void(^)())block{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

+ (void)performBlockInGlobal:(void(^)())block{
    [self performBlockInGlobal:block afterDelay:0];
}

+ (void)performBlockInCurrentTheard:(void (^)())block{
    [self performBlockInCurrentTheard:block afterDelay:0];
}

+ (void)performBlockInMain:(void(^)())block afterDelay:(NSTimeInterval)delay{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

+ (void)performBlockInGlobal:(void(^)())block afterDelay:(NSTimeInterval)delay{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{block();});
}

+ (void)performBlockInCurrentTheard:(void (^)())block afterDelay:(NSTimeInterval)delay{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{block();});
}

+ (NSString *)getIOSVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getIOSName{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

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
+ (int)getLanguage
{
    int langIn = [(NSNumber *)GetUD(@"CurrentLanguage") intValue];
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
    
    SetUD(@"CurrentLanguage", @(langIn));
    return langIn;
}

+ (NSString *)getPreferredLanguageStr
{
    return [[(NSArray *)GetUD(@"AppleLanguages") objectAtIndex:0] substringWithRange:NSMakeRange(0, 2)];
}


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

+ (NSData *)getCountiesAndCitiesrDataFromJSON
{
    //#warning ---------------- FIXME for Language 这里等百科数据中的法文和西班牙文翻译后，注释
    NSInteger langIndex =  [self getLanguage];
    NSString *jsonName = @"";
    switch (langIndex) {
        case 1:
            jsonName = @"city_zh";
            break;
        case 2:
            jsonName = @"city_en";
            break;
        case 3:
            
            jsonName = @"city_fr";
            jsonName = @"city_en";
            break;
        case 4:
            jsonName = @"city_es";
            jsonName = @"city_en";
            break;
    }
    
    NSData *data = [self getDataFromJSON:jsonName];
    return data;
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

// 把 NSSet 安卓指定的字段进行排序 返回 NSMutableArray
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

// 保存图片到
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

+ (NSString *)dataPath:(NSString *)file
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@""];
    BOOL bo;
    bo = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    bo = bo;
    return [path stringByAppendingPathComponent:file];
}

+ (NSString *)getCacheURL{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)getDomentURL{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

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

// ------------------------------------------------------ 这两个是一对 ↓↓↓↓↓↓↓↓↓↓↓↓↓
//  int 转换成 年月日数组
+ (NSMutableArray *)HmF2KIntToDate:(int)f2kDate
{
    int times[3];
    times[0]=2000;
    
    while ( f2kDate >= [self yearDay:times[0]])
    {
        f2kDate-= [self yearDay:times[0]];
        times[0]++;
    }
    
    times[1]=0;
    
    while ( f2kDate >= [self monthDays:times[0] month:times[1]])
    {
        f2kDate -= [self monthDays:times[0] month:times[1]];
        times[1]++;
    }
    
    times[2]= f2kDate;
    NSMutableArray *arr = [NSMutableArray new];
    
    
    [arr addObject:@(times[0])];
    
    [arr addObject:@(++times[1])];
    
    [arr addObject:@(++times[2])];
    return arr;
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

//  年月日数组 转换成 int 
+ (int)HmF2KDateToInt:(NSMutableArray *)array
{
    int date= [((NSNumber *)array[2]) intValue] - 1;
    int month =  [((NSNumber *)array[1]) intValue] - 1;;
    int year = [((NSNumber *)array[0]) intValue];
    while ( --month >= 0 )
    {
        date += [self monthDays:year month:month];
    }
    while ( --year >= 2000 )
    {
        date += [self yearDay:year];
    }
    return date;
}
// ------------------------------------------------------ 这两个是一对 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑



// ------------------------------------------------------ 这两个是一对 ↓↓↓↓↓↓↓↓↓↓↓↓↓
//  NSDate 转换成 int    5934 -> NSDate
+ (int)HmF2KNSDateToInt:(NSDate *)date
{
    NSMutableArray *arr = [NSMutableArray new];
    int year  = [self getFromDate:date type:1];
    int month = [self getFromDate:date type:2];
    int day   = [self getFromDate:date type:3];
    
    [arr addObject:@(year)];
    [arr addObject:@(month)];
    [arr addObject:@(day)];
    
    int dateValue = [self HmF2KDateToInt:arr];
    return dateValue;
}

//  int 转换成 NSDate   5934  ->  NSDate
+ (NSDate *)HmF2KNSIntToDate:(int)dateValue
{
    return [self getDateFromArr:[self HmF2KIntToDate:dateValue]];
}



// ------------------------------------------------------ 这两个是一对 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑

+ (NSString *)toStringFromDateValue:(int)dateValue
{
    NSMutableArray *arr = [self HmF2KIntToDate:dateValue];
    return [NSString stringWithFormat:@"%d%02d%02d", [arr[0] intValue], [arr[1] intValue], [arr[2] intValue]];
}

// ------------------------------------------------------ 这两个是一对 ↓↓↓↓↓↓↓↓↓↓↓↓↓
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

+(BOOL)isSysTime24
{
    NSNumber *sysTime = GetUD(@"is24");
    if (sysTime) return [sysTime boolValue];
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    SetUD(@"is24", @(!hasAMPM));
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

#pragma mark  设置最新的同步时间
+(void)setLastSysDateTime:(NSDate *)date access:(NSString *)access
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:GetUD(@"LastSysDateTimeData")];
    [dic setValue:date forKey:access];
    SetUD(@"LastSysDateTimeData", dic);
}

#pragma mark  设置最新的上传时间
+(void)setLastUpLoadDateTime:(NSDate *)date access:(NSString *)access
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:GetUD(@"LastUpLoadDateTimeData")];
    [dic setValue:date forKey:access];
    SetUD(@"LastUpLoadDateTimeData", dic);
}

+(NSDate *)getLastSysDateTime:(NSString *)access
{
    NSDictionary *dicLastSyn = GetUD(@"LastSysDateTimeData");
    NSDate *date = (NSDate *)dicLastSyn[access];
    if (date) {
        return date;
    }else
        return [NSDate dateWithTimeIntervalSinceNow:-24 * 60 * 60];
}

+(NSDate *)getLastUpLoadDateTime:(NSString *)access
{
    NSDictionary *dicLastSyn = GetUD(@"LastUpLoadDateTimeData");
    NSDate *date = (NSDate *)dicLastSyn[access];
    if (date) {
        return date;
    }else
        return [NSDate dateWithTimeIntervalSinceNow:-24 * 60 * 60];
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

//  把从时间（时分秒）获取 当天的时间
+ (NSDate *)getDateTimeFormDateValue:(int)timeValue
{
    NSDate *now              = DNow;
    int year                 = [self getFromDate:now type:1];
    int month                = [self getFromDate:now type:2];
    int day                  = [self getFromDate:now type:3];
    NSMutableArray *arrDate6 = [@[@(year), @(month), @(day)] mutableCopy];
    NSMutableArray *arr_3    = [self getHourMinuteSecondFormDateValue:timeValue];
    [arrDate6 addObjectsFromArray:arr_3];
    return  [self getDateFromArr:arrDate6];
}


//  从喝水集合和时间集合中获取每小时的喝水量集合
+ (NSString *)getWater_array_Hour_FromArray:(NSString *)water_array time_array:(NSString *)time_array
{
    NSArray *arrWater = [water_array componentsSeparatedByString:@","];
    NSArray *arrTime = [time_array componentsSeparatedByString:@","];
    
    int waterHour[24] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    for (int i = 0 ; i < arrWater.count; i++)
    {
        NSMutableArray *arrDate = [self getHourMinuteSecondFormDateValue:[arrTime[i] intValue]];
        int hour = [arrDate[0] intValue];
        waterHour[hour] += [arrWater[i] intValue];
    }
    
    return  [self intIntsToString: waterHour length:24];
}

// 从时间(datevalue)获取  小时 分 秒 数组
+ (NSMutableArray *)getHourMinuteSecondFormDateValue:(int)timeValue
{
    int hour = timeValue / 1800;
    int minute = (timeValue - hour * 1800) / 30;
    int second = timeValue - hour * 1800 - minute * 30;
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@(hour), @(minute), @(second), nil];
    return arr;
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

// 获取喝水最多的时间字符串
+ (NSString *)getMaxWaterOnTime:(NSString *)water_array time_array:(NSString *)time_array
{
    if (!water_array || !time_array) return @"";
    NSArray *arrWater = [water_array componentsSeparatedByString:@","];
    NSArray *arrTime = [time_array componentsSeparatedByString:@","];
    int indexMax = 0;
    int biggestWater = [arrWater[0] intValue];
    for (int i = 0; i < arrWater.count; i++)
    {
        int waterThis = [arrWater[i] intValue];
        if (biggestWater < waterThis)
        {
            biggestWater = waterThis;
            indexMax = i;
        }
    }
    
    int timeValue = [arrTime[indexMax] intValue];
    NSMutableArray *arrHourMinuteSencond = [self getHourMinuteSecondFormDateValue: timeValue];
    int hour = [arrHourMinuteSencond[0] intValue];
    int minute = [arrHourMinuteSencond[1] intValue];
    
    return [self toStringByHourAndMinute:@(hour) minute:@(minute)];
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

// ------------------------------------------------------ 这两个是一对 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑
// ------------------------------------------------------ 这两个是一对 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑

// 进行排序
+ (NSMutableArray *)sort:(NSMutableArray *)arr
{
    NSMutableArray *arrResult = [arr mutableCopy];
    for (int i = 1; i < arr.count; i++)
    {
        for (int j = i + 1; j < arr.count; j++)
        {
            NSDictionary *dicLeft = arr[i];
            NSDictionary *dicRight = arr[j];
            int left = [dicLeft.allKeys[0] intValue];
            int right = [dicRight.allKeys[0] intValue];
            if (left > right) {
                NSDictionary *dicTag = [dicLeft mutableCopy];
                arrResult[i] = [dicRight mutableCopy];
                arrResult[j] = [dicTag mutableCopy];
                arr = [arrResult mutableCopy];
            }
        }
    }
    return arrResult;
}


// 把 小时  分钟  转化成 显示 （14：20  或者 02：20 PM）

+(NSString *)toStringByHourAndMinute:(NSNumber *)hour minute:(NSNumber *)minute
{
    if ([self isSysTime24]) {
        return [NSString stringWithFormat:@" %02d:%02d", [hour intValue], [minute intValue]];
    }else
    {
        int hourInt = [hour intValue];
        int minuteInt = [minute intValue];
        hourInt = hourInt == 0 ? 24 : hourInt;
        
        NSString *str = [NSString stringWithFormat:@"%d:%02d%@",
                         (hourInt > 12 ? hourInt - 12 : hourInt),
                         minuteInt,
                         ((hourInt >= 12 && hourInt != 24) ? @"PM":@"AM")];
        return str;
    }
}

//  把 距离转换成 显示的字符  800 ——> 800米   1800 ——>  1.8公里
+ (NSString *)toStringFromDist:(int)dist isMetric:(BOOL)isMetric
{
    NSString *disStr;
    if (isMetric) {
        disStr = dist >= 1000 ? [NSString stringWithFormat:@"%.2f%@", dist / 1000.0, kS(@"公里")] : [NSString stringWithFormat:@"%d%@", dist, kS(@"米")];
    }else{
        CGFloat distMi = dist / 1000.0 * 0.6213712;
        disStr = distMi >= 1 ? [NSString stringWithFormat:@"%.2f%@", distMi, kS(@"英里")]: [NSString stringWithFormat:@"%.0f%@", distMi * 5280, kS(@"英尺")];;
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
        NSDate *now         = DNow;
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
+ (NSString *)dateToString:(NSDate *)date stringType:(NSString *)stringType
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
        return DNow;
    }
    return  date;
}

+ (BOOL)isToday:(NSDate *)date
{
    if (!self) return NO;
    NSDate *now   = DNow;
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

+ (NSString *)toStringForShow:(NSDate *)date
{
    int hour   = [self getFromDate:date type:4];
    int minute = [self getFromDate:date type:5];
    
    if ([self isSysTime24]) {
        return [NSString stringWithFormat:@"%02d:%02d", hour, minute];
    }else
    {
        hour = hour == 0 ? 24 : hour;
        NSString *str = [NSString stringWithFormat:@"%02d:%02d%@",
                         (hour > 12 ? hour - 12 : hour),
                         minute,
                         ((hour >= 12 && hour != 24) ? @"PM":@"AM")];
        return str;
    }
}

+ (int)getAgeFromBirthDay:(NSDate *)date
{
    return [DNow timeIntervalSinceDate:date] / (3600*24*365);
}


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
+ (NSMutableArray *)sort:(NSMutableArray *)arr byString:(NSString *)byString
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




@end
