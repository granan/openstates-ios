#import "SLFDataModels.h"

@implementation CommitteeRole
@dynamic committeeID;
@dynamic committeeName;
@dynamic chamber;
@dynamic role;
@dynamic legislatorInverse;

- (SLFCommittee *)foundCommittee {
    if (!self.committeeID)
        return nil;
    return [SLFCommittee findFirstByAttribute:@"committeeID" withValue:self.committeeID];
}

- (NSString *)role {
    [self willAccessValueForKey:@"role"];
    NSString *aRole = [self primitiveValueForKey:@"role"];
    [self didAccessValueForKey:@"role"];
    if (aRole)
        aRole = [aRole capitalizedString];
    return aRole;
}
@end
