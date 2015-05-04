#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>


extern "C"
{
NSString* makeNSStringFromCString(char const * str)
{
    return [NSString stringWithCString: str encoding: NSUTF8StringEncoding];
}


/**
http://stackoverflow.com/questions/19525921/removing-a-dock-icon-in-osx-mavericks-programatically
*/
void removeDockItemNamed(NSString* dockIconLabel)
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSMutableDictionary* dockDict = [[userDefaults persistentDomainForName:@"com.apple.dock"] mutableCopy];

    NSMutableArray* apps = [[dockDict valueForKey:@"persistent-apps"] mutableCopy];
    if (apps != nil)
    {
        NSArray* appsCopy = [apps copy];
        bool modified = NO;
        for(NSDictionary *anApp in appsCopy)
        {
            NSDictionary* fileDict = [anApp valueForKey:@"tile-data"];
            if(fileDict != nil)
            {
                NSString *appName = [fileDict valueForKey:@"file-label"];

                if([dockIconLabel isEqualToString:appName])
                {
                    [apps removeObject:anApp];
                    modified = YES;
                    break;
                }
            }
        }
        if(modified)
        {
            //If the dictionary was modified, save the new settings.
            dockDict[@"persistent-apps"] = apps;
            [userDefaults setPersistentDomain:dockDict forName:@"com.apple.dock"];
            //Reset the standardUserDefaults so that the modified data gets synchronized
            //and next time when this function is invoked, we get the up-to-date dock icon details.
            [NSUserDefaults resetStandardUserDefaults];
        }
    }
}
}