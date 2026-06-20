//
//  CalculatorController.m
//  shittyCalculator
//
//  Created by Xander Gomez on 20/06/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "CalculatorController.h"
#include <math.h>

@implementation CalculatorController
+ (id)addNumber:		(NSNumber*)num1 with:(NSNumber*)num2 { return [NSNumber numberWithDouble:[num1 doubleValue] + [num2 doubleValue]]; }
+ (id)subtractNumber:	(NSNumber*)num1 with:(NSNumber*)num2 { return [NSNumber numberWithDouble:[num1 doubleValue] - [num2 doubleValue]]; }
+ (id)divideNumber:		(NSNumber*)num1 with:(NSNumber*)num2 { return ([num2 doubleValue] == 0.0) ? [NSNumber numberWithDouble:INFINITY] : [NSNumber numberWithDouble: [num1 doubleValue] / [num2 doubleValue]]; }
+ (id)multiplyNumber:	(NSNumber*)num1 with:(NSNumber*)num2 { return [NSNumber numberWithDouble:[num1 doubleValue] * [num2 doubleValue]]; }

- (id)init {
	if (self = [super init]) {
		operators = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSValue valueWithPointer:@selector(addNumber:with:)		], [NSString stringWithUTF8String:"+"],
			[NSValue valueWithPointer:@selector(subtractNumber:with:)	], [NSString stringWithUTF8String:"-"],
			[NSValue valueWithPointer:@selector(divideNumber:with:)		], [NSString stringWithUTF8String:"÷"],
			[NSValue valueWithPointer:@selector(multiplyNumber:with:)	], [NSString stringWithUTF8String:"x"],
		nil];
		currentOperator = nil;
	}
	
	return self;
}

- (IBAction)invokeNumberButton:		(id)sender {
	NSString *value = [display stringValue];
	if (wasLastButtonCalculation) { currentOperator = nil; priorBuffer = 0.0; }
	wasLastButtonCalculation = NO; 
	if ([value length] >= 20 && !clearable) { NSBeep(); return; }
	if (([value isEqualToString:@"0"]) || clearable) {priorBuffer = [display doubleValue]; [display setStringValue:(value = ([[[sender cell] title] isEqualToString:@"."]) ? @"0." : @"")];}
	if ([[[sender cell] title] isEqualToString:@"."] && [[value componentsSeparatedByString:@"."] count] > 1) return;
	clearable = NO;
	[display setStringValue:[value stringByAppendingString:[[sender cell] title]]];
	currentBuffer = [display doubleValue];
}

- (IBAction)invokeOperatorButton:	(id)sender {
	wasLastButtonCalculation = NO;
	clearable = YES; priorBuffer = [display doubleValue];
	currentBuffer = priorBuffer;
	currentOperator = [[sender cell] title];
}

- (IBAction)clearCalculation:		(id)sender {
	wasLastButtonCalculation = NO;
	currentBuffer = 0.0; priorBuffer = 0.0;
	[display setStringValue:@"0"];
	currentOperator = nil; clearable = NO;
}

- (IBAction)performCalculation:		(id)sender {
	double numberOne, numberTwo, result;
	if (currentOperator == nil) {clearable = YES; return;}
	if (wasLastButtonCalculation) { numberOne = currentBuffer; numberTwo = priorBuffer; }
	else { numberOne = priorBuffer; numberTwo = currentBuffer; }
	SEL operation = [[operators objectForKey:currentOperator] pointerValue];
	result = [[[self class] performSelector:operation withObject:[NSNumber numberWithDouble:numberOne] withObject:[NSNumber numberWithDouble:numberTwo]] doubleValue];
	if (!wasLastButtonCalculation) priorBuffer = currentBuffer;
	currentBuffer = result;
	[display setDoubleValue:currentBuffer];
	clearable = YES; wasLastButtonCalculation = YES;
}

- (IBAction)flipSign:				(id)sender {
	if ([display doubleValue] == 0.0) return;
	if ([[[display stringValue] substringToIndex:1] isEqualToString:@"-"]) [display setStringValue:[[display stringValue] substringFromIndex:1]];
	else [display setStringValue:[[NSString stringWithString:@"-"] stringByAppendingString:[display stringValue]]];
}

- (IBAction)memoryClear:			(id)sender { wasLastButtonCalculation = NO; memory = 0.0; }
- (IBAction)memoryAdd:				(id)sender { wasLastButtonCalculation = NO; memory += [display doubleValue]; }
- (IBAction)memorySubtract:			(id)sender { wasLastButtonCalculation = NO; memory -= [display doubleValue]; }
- (IBAction)memoryRecall:			(id)sender { wasLastButtonCalculation = NO; [display setDoubleValue:memory]; clearable = YES; }

- (void)dealloc {
	[operators release];
	[super dealloc];
}
@end
