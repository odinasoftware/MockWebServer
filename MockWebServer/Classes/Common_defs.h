//
//  Common_defs.h
//  MockServer
//
//  Created by Jae Han on 11/14/16.
//  Copyright © 2016 Jae Han. All rights reserved.
//

#ifndef Common_defs_h
#define Common_defs_h

#ifdef DEBUG
#define TRACE(fmt, args...) NSLog(@fmt, ## args)
#define fTRACE(fmt, args...) NSLog(@"%s: " fmt, __func__, ## args)
#else
#define TRACE(fmt, args...)
#define fTRACE(fmt, args...)
#endif

#define	TRACE_HERE		TRACE("%s\n", __func__)

#endif /* Common_defs_h */
