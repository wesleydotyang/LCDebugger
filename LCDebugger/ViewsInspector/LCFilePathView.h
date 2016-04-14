//
//  FilePathView.h
//
//  Created by Wesley Yang on 16/4/12.
//

#import <UIKit/UIKit.h>
@class LCFilePathViewNode;
@protocol  LCFilePathViewDelegate;


@interface LCFilePathView : UIView

@property (nonatomic,strong) LCFilePathViewNode* fileRootNode;
@property (nonatomic,weak)   id<LCFilePathViewDelegate> delegate;
-(void)setCurrentDisplayingPaths:(NSArray*)displayingPaths;

@end

@interface LCFilePathViewNode : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) id attachedData;
@property (nonatomic,strong) NSMutableArray *children;
@property (nonatomic,weak) LCFilePathViewNode *parent;

-(void)addChild:(LCFilePathViewNode*)child;
-(NSArray*)brothers;


@end


@protocol  LCFilePathViewDelegate<NSObject>

-(void)filePathView:(LCFilePathView*)pathView didSelectItem:(LCFilePathViewNode*)data;

@end
