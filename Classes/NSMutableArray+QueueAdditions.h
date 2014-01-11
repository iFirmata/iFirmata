//
//  NSMutableArray+QueueAdditions.h
//  Pods
//
//  Created by Jacob on 1/8/14.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end