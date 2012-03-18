//
//  FSDataObject.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Wed Oct 02 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import "FSDataObject.h"
#import "KBEnvironment.h"

@implementation Number (FSDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env
{
    if([self hasFrac_bool])
    {
        obj->type = FLOAT;
        obj->value = EnvAddDouble([env _impl],[self doubleValue]);
    }
    else
    {
        obj->type = INTEGER;
        obj->value = EnvAddLong([env _impl],(long)[self doubleValue]);
    }
}

@end

@implementation False (FSDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env
{
    obj->type = SYMBOL;
    obj->value = EnvFalseSymbol([env _impl]);
}

@end

@implementation True (FSDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env
{
    obj->type = SYMBOL;
    obj->value = EnvTrueSymbol([env _impl]);
}

@end