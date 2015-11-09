//
//  PassengerTableViewCell.m
//  Pump
//
//  Created by Clay Jones on 9/15/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "PassengerTableViewCell.h"
#import "Utils.h"
@import Contacts;

#define CELL_HEIGHT 50

@implementation PassengerTableViewCell {
    UIButton *_detailView;
    CAShapeLayer *circle;
    BOOL animating;
}

@synthesize passenger = _passenger;
@synthesize cost = _cost;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
   // _detailView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width * .9 - 15, CELL_HEIGHT/2 - 15, 30, 30)];
    animating = NO;
    
    _cost = 0;
    
    return self;
}

-(void)setCost:(double)cost {
    _cost = cost;
}

-(void)setStatus:(PaymentStatus)status {
    _status = status;
    switch (status) {
        case PAYMENT_PENDING: {
            if (!_detailView) {
                _detailView = [[UIButton alloc] init];
                [self addSubview:_detailView];
            }
            [_detailView setFrame:CGRectMake(self.frame.size.width * .85 - 35, CELL_HEIGHT/2 - 15, 70, 30)];
            [_detailView.layer setBorderColor:[UIColor grayColor].CGColor];
            [_detailView.layer setBorderWidth:1];
            [_detailView setBackgroundColor:[UIColor whiteColor]];
            [_detailView.layer setCornerRadius:15];
            [((UIButton *)_detailView).titleLabel setAlpha:1];
            [((UIButton *)_detailView) setAttributedTitle:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", _cost] size:14 color:[UIColor grayColor]] forState:UIControlStateNormal];
            [((UIButton *)_detailView).titleLabel setAdjustsFontSizeToFitWidth:YES];
            break;
        }
        case PAYMENT_PROCESSING: {
            [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [((UIButton *)_detailView).titleLabel setAlpha:0];
            } completion:nil];
            [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_detailView setFrame:CGRectMake(self.frame.size.width * .85 - 15, CELL_HEIGHT/2 - 15, 30, 30)];
                [_detailView setAlpha:0];
            } completion:^(BOOL finished) {
                animating = YES;
                [self drawCircleToView:self withStart:0.0 end:.8 animated:YES];
            }];
            break;
        }
        case PAYMENT_FINISHING: {
            if (!animating) {
                [self drawCircleToView:self withStart:0.8 end:1.0 animated:YES];
            }
            break;
        }
        case PAYMENT_SUCCESS: {
            [self setUserInteractionEnabled:NO];
            self.detailTextLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"Charged $%.2f",_cost] size:8 color:[Utils greenColor]];
            break;
        }
        case PAYMENT_FAILED: {
            self.detailTextLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"Charge of $%.2f failed",_cost] size:8 color:[Utils redColor]];
            [_detailView setAlpha:1];
            const CGFloat scale = 0;
            [_detailView.layer setBorderColor:[Utils redColor].CGColor];
            [_detailView setBackgroundColor:[Utils redColor]];
            [_detailView setTransform:CGAffineTransformMakeScale(scale, scale)];
            circle.opacity = 0;
            [circle removeFromSuperlayer];
            //[_detailView setBackgroundImage:[UIImage imageNamed:@"white_exclamation"] forState:UIControlStateNormal]
            [_detailView setAttributedTitle:nil forState:UIControlStateNormal];
            [_detailView setImage:[UIImage imageNamed:@"white_exclamation"] forState:UIControlStateNormal];
            [(UIButton *)_detailView setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [(UIButton *)_detailView setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [((UIButton *)_detailView).imageView setAlpha:0];
            [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                _detailView.transform = CGAffineTransformMakeScale(1, 1);
                [((UIButton *)_detailView).imageView setAlpha:1];
                circle.opacity = 0;
            } completion:^(BOOL finished) {
                [circle removeFromSuperlayer];
                [self.textLabel setTextColor:[Utils redColor]];
            }];
            break;
        }
        default:
            break;
    }
}

-(void) drawCircleToView:(UIView *)view withStart: (float) start end:(float)end animated: (BOOL) animated {
    if (circle.superlayer) {
        [circle removeFromSuperlayer];
    }
    
    // Set up the shape of the circle
    int radius = 15;
    circle = [CAShapeLayer layer];
    // Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;
    // Center the shape in self.view
    circle.position = CGPointMake(self.frame.size.width * .85 - 15, CELL_HEIGHT/2 - 15);
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [Utils greenColor].CGColor;
    circle.lineWidth = 3;
    
    // Add to parent layer
    [view.layer addSublayer:circle];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    if (animated) {
        drawAnimation.duration            = (start - end) * .5;
    } else {
        drawAnimation.duration            = 0.0; // "animate over 10 seconds or so.."
    }
    drawAnimation.repeatCount         = 1.0;  // Animate only once..
    
    drawAnimation.delegate = self;
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:start];
    drawAnimation.toValue   = [NSNumber numberWithFloat:end];
    
    drawAnimation.fillMode = kCAFillModeForwards;
    drawAnimation.removedOnCompletion = NO;
    
    // Experiment with timing to get the appearence to look the way you want
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // Add the animation to the circle
    if (end == 1.0) {
        [circle addAnimation:drawAnimation forKey:@"finishCircleAnimation"];
    } else {
        [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    }
}

-(void)runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict {
    
}

-(void)animationDidStart:(CAAnimation *)anim {
    animating = YES;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    animating = NO;
    if ([((CABasicAnimation *)anim).toValue floatValue] != 1.0 && _status == PAYMENT_FINISHING) {
        [self drawCircleToView:self withStart:0.8 end:1.0 animated:YES];
    } else if(_status == PAYMENT_FINISHING) {
        [_detailView setAlpha:1];
        const CGFloat scale = 0;
        [_detailView.layer setBorderColor:[Utils greenColor].CGColor];
        [_detailView setBackgroundColor:[Utils greenColor]];
        [_detailView setTransform:CGAffineTransformMakeScale(scale, scale)];
        //_detailView.transform = CGAffineTransformMakeScale(1, 1);
        circle.opacity = 1;
        //[_detailView setBackgroundImage:[UIImage imageNamed:@"white_exclamation"] forState:UIControlStateNormal]
        [_detailView setAttributedTitle:nil forState:UIControlStateNormal];
        [_detailView setImage:[UIImage imageNamed:@"white_checkmark"] forState:UIControlStateNormal];
        [(UIButton *)_detailView setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [(UIButton *)_detailView setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [((UIButton *)_detailView).imageView setAlpha:0];
        [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _detailView.transform = CGAffineTransformMakeScale(1, 1);
            [((UIButton *)_detailView).imageView setAlpha:1];
            circle.opacity = 0;
        } completion:^(BOOL finished) {
            [circle removeFromSuperlayer];
            [self.textLabel setTextColor:[Utils greenColor]];
            [self setStatus:PAYMENT_SUCCESS];
        }];
    } else if (_status == PAYMENT_FAILED) {
        //[_detailView setBackgroundImage:[UIImage imageNamed:@"white_exclamation"] forState:UIControlStateNormal]
        [_detailView setAttributedTitle:nil forState:UIControlStateNormal];
        [_detailView setImage:[UIImage imageNamed:@"white_exclamation"] forState:UIControlStateNormal];
        [(UIButton *)_detailView setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [(UIButton *)_detailView setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [((UIButton *)_detailView).imageView setAlpha:0];
        [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _detailView.transform = CGAffineTransformMakeScale(1, 1);
            [((UIButton *)_detailView).imageView setAlpha:1];
            circle.opacity = 0;
        } completion:^(BOOL finished) {
            [circle removeFromSuperlayer];
            [self.textLabel setTextColor:[Utils redColor]];
        }];
    }
}

-(void)setPassenger:(id)passenger {
    _passenger = passenger;
    if ([passenger isKindOfClass:[PFUser class]]) {
        self.textLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@ %@",_passenger[@"first_name_cased"], _passenger[@"last_name_cased"]] size:16 color:[UIColor blackColor]] ;
    } else {
        self.textLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@ %@",((CNContact *)_passenger).givenName, ((CNContact *)_passenger).familyName] size:16 color:[UIColor blackColor]] ;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(self.frame.size.width * .1 - 20, CELL_HEIGHT * .5 - 20,30,30);
}

@end
