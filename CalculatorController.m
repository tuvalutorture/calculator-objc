#import "CalculatorController.h"
#include <math.h>

@implementation CalculatorController
+ (id)addNumber:		(NSNumber*)num1 with:(NSNumber*)num2 { return [NSNumber numberWithDouble:[num1 doubleValue] + [num2 doubleValue]]; }
+ (id)subtractNumber:	(NSNumber*)num1 with:(NSNumber*)num2 { return [NSNumber numberWithDouble:[num1 doubleValue] - [num2 doubleValue]]; }
+ (id)divideNumber:		(NSNumber*)num1 with:(NSNumber*)num2 { return ([num2 doubleValue] == 0.0) ? [NSNumber numberWithDouble:INFINITY] : [NSNumber numberWithDouble: [num1 doubleValue] / [num2 doubleValue]]; }
+ (id)multiplyNumber:	(NSNumber*)num1 with:(NSNumber*)num2 { return [NSNumber numberWithDouble:[num1 doubleValue] * [num2 doubleValue]]; }

- (void)updateDisplay:(double)number { [display setDoubleValue:number]; currentBuffer = number; } /* wrapper to make porting between uikit/appkit easier */
- (double)getDisplayNum { return [display doubleValue]; } /* same here */

- (id)init {
	if (self = [super init]) {
		operators = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSValue valueWithPointer:@selector(addNumber:with:)		], [NSString stringWithUTF8String:"+"],
			[NSValue valueWithPointer:@selector(subtractNumber:with:)	], [NSString stringWithUTF8String:"-"],
			[NSValue valueWithPointer:@selector(divideNumber:with:)		], [NSString stringWithUTF8String:"÷"], /* this one right here is why i did it to all the others (for consistencies sake), otherwise this one'd warn me on xcode 2.5 */
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
	if ([value length] >= 20 && !clearable) return;
	if (([value isEqualToString:@"0"]) || clearable) {priorBuffer = [display doubleValue]; [display setStringValue:(value = ([[[sender cell] title] isEqualToString:@"."]) ? @"0." : @"")];}
	if ([[[sender cell] title] isEqualToString:@"."] && [[value componentsSeparatedByString:@"."] count] > 1) return;
	clearable = NO;
	[display setStringValue:[value stringByAppendingString:[[sender cell] title]]];
	currentBuffer = [self getDisplayNum];
}

- (IBAction)invokeOperatorButton:	(id)sender {
	if (!clearable && currentOperator != nil) [self performCalculation:sender]; 
	wasLastButtonCalculation = NO; clearable = YES; 
	priorBuffer = [self getDisplayNum]; currentBuffer = priorBuffer;
	currentOperator = [[sender cell] title];
}

- (IBAction)clearCalculation:		(id)sender {
	[self updateDisplay:(priorBuffer = 0.0)];
	currentOperator = nil; wasLastButtonCalculation = NO; clearable = NO;
}

- (IBAction)performCalculation:		(id)sender {
	double numberOne, numberTwo;
	if (currentOperator == nil) {clearable = YES; return;}
	if (wasLastButtonCalculation) { numberOne = currentBuffer; numberTwo = priorBuffer; }
	else { numberOne = priorBuffer; numberTwo = currentBuffer; priorBuffer = currentBuffer; }
	[self updateDisplay:[[[self class] performSelector:[[operators objectForKey:currentOperator] pointerValue] withObject:[NSNumber numberWithDouble:numberOne] withObject:[NSNumber numberWithDouble:numberTwo]] doubleValue]]; /* square bracket hell */
	clearable = YES; wasLastButtonCalculation = YES;
}

- (IBAction)flipSign:				(id)sender { [self updateDisplay:[display doubleValue] * -1]; }
- (IBAction)memoryClear:			(id)sender { wasLastButtonCalculation = NO; memory = 0.0; }
- (IBAction)memoryAdd:				(id)sender { wasLastButtonCalculation = NO; memory += [self getDisplayNum]; }
- (IBAction)memorySubtract:			(id)sender { wasLastButtonCalculation = NO; memory -= [self getDisplayNum]; }
- (IBAction)memoryRecall:			(id)sender { wasLastButtonCalculation = NO; [self updateDisplay:memory]; clearable = YES; }

- (void)dealloc {
	[operators release];
	[super dealloc];
}
@end
