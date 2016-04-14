//
//  FilePathView.m
//
//  Created by Wesley Yang on 16/4/12.
//

#import "LCFilePathView.h"

#define HEADER_HEIGHT   30
#define HEADER_FONT_SIZE    12
#define TABLE_CELL_HEIGHT  30


@interface LCFilePathViewCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) UILabel *textLabel;
@end


@interface LCFilePathView()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>
{
    LCFilePathViewNode *_tableDisplayingNode;
    NSArray<LCFilePathViewNode*> *_displayingNodes;
}

@property (nonatomic) NSMutableArray *currentDisplayingButtons;
@property (nonatomic) UITableView *leftTableView;
@property (nonatomic) UITableView *rightTableView;
@property (nonatomic) UICollectionView *headView;
@end

@implementation LCFilePathView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.headView];
    }
    return self;
}

-(void)setFileRootNode:(LCFilePathViewNode *)fileRootNode
{
    _fileRootNode = fileRootNode;
    
    _displayingNodes = [NSMutableArray arrayWithObject:fileRootNode];
    [self reloadHeader];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    self.headView.frame = CGRectMake(0, 0, self.frame.size.width, HEADER_HEIGHT);
    
}



#pragma mark - collectionView

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _displayingNodes.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LCFilePathViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    LCFilePathViewNode *data = _displayingNodes[indexPath.item];
    cell.textLabel.text = data.name;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LCFilePathViewNode *data = _displayingNodes[indexPath.item];
    float textWidth = [data.name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:HEADER_FONT_SIZE]}].width;
    return CGSizeMake(textWidth, HEADER_HEIGHT);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LCFilePathViewNode *data = _displayingNodes[indexPath.item];
    _tableDisplayingNode = data;
    if ([self isTableShowing]) {
        [self hideTable];
        _displayingNodes = [self getDisplayingNodesForCurrentSelectedNode:data];
        [self reloadHeader];
    }else{
        [self showTable];
    }
   
}
#pragma mark - table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.leftTableView) {
        return _tableDisplayingNode.brothers.count;
    }else{
        return _tableDisplayingNode.children.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:HEADER_FONT_SIZE];
    }
    LCFilePathViewNode *data;
    if (tableView==self.leftTableView) {
        data = _tableDisplayingNode.brothers[indexPath.row];
    }else{
        data = _tableDisplayingNode.children[indexPath.row];
    }
    cell.textLabel.text = data.name;

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.leftTableView) {
        _tableDisplayingNode = _tableDisplayingNode.brothers[indexPath.row];
    }else{
        _tableDisplayingNode = _tableDisplayingNode.children[indexPath.row];
    }
    [self hideTable];
    _displayingNodes = [self getDisplayingNodesForCurrentSelectedNode:_tableDisplayingNode];
    [self reloadHeader];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(filePathView:didSelectItem:)]){
        [self.delegate filePathView:self didSelectItem:_tableDisplayingNode];
    }
}





-(NSArray*)getDisplayingNodesForCurrentSelectedNode:(LCFilePathViewNode*)node
{
    NSMutableArray *datas = [NSMutableArray array];
    LCFilePathViewNode *currentNode = node;
    while (currentNode) {
        [datas addObject:currentNode];
        currentNode = currentNode.parent;
    }
    NSMutableArray *reverseDatas = [NSMutableArray array];
    for (int i = (int)datas.count-1; i>=0; --i) {
        [reverseDatas addObject:datas[i]];
    }
    return reverseDatas;
}

-(void)reloadTable{
    [self.leftTableView reloadData];
    [self.rightTableView reloadData];
}

-(BOOL)isTableShowing
{
    return self.leftTableView.superview!=nil;
}

-(void)hideTable{
    [self.leftTableView removeFromSuperview];
    [self.rightTableView removeFromSuperview];
    
    CGRect thisFrame = self.frame;
    thisFrame.size.height = HEADER_HEIGHT;
    self.frame = thisFrame;
}

-(void)showTable
{
    BOOL showRightTable = _tableDisplayingNode.children.count>0;
    float viewHeight = HEADER_HEIGHT;
    float maxTableHeight = 300;
    
    if (showRightTable) {
        self.leftTableView.frame = CGRectMake(0, HEADER_HEIGHT, self.frame.size.width/2,MIN(maxTableHeight,_tableDisplayingNode.brothers.count*TABLE_CELL_HEIGHT));
        self.rightTableView.frame = CGRectMake(self.frame.size.width/2, HEADER_HEIGHT, self.frame.size.width/2, MIN(maxTableHeight,_tableDisplayingNode.children.count*TABLE_CELL_HEIGHT));
        [self addSubview:self.rightTableView];
        viewHeight += MAX(self.leftTableView.frame.size.height,self.rightTableView.frame.size.height);
    }else{
        self.leftTableView.frame = CGRectMake(0, HEADER_HEIGHT, self.frame.size.width,MIN(maxTableHeight,_tableDisplayingNode.brothers.count*TABLE_CELL_HEIGHT));
        viewHeight += self.leftTableView.frame.size.height;
    }
    
    [self addSubview:self.leftTableView];

    [self reloadTable];
    
    CGRect thisFrame = self.frame;
    thisFrame.size.height = viewHeight;
    self.frame = thisFrame;
    
}



-(UITableView *)leftTableView{
    if (!_leftTableView) {
        _leftTableView =[[UITableView alloc] init];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
    }
    return _leftTableView;
}
-(UITableView *)rightTableView{
    if (!_rightTableView) {
        _rightTableView =[[UITableView alloc] init];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
    }
    return _rightTableView;
}

-(void)reloadHeader
{
    [self.headView reloadData];
    [self.headView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_displayingNodes.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

-(void)setCurrentDisplayingPaths:(NSArray *)displayingPaths
{
    _displayingNodes = displayingPaths;
    [self reloadHeader];
}

-(UIButton*)buttonWithFileData:(LCFilePathViewNode*)data
{
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt setTitle:data.name forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(headButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return bt;
}

-(UICollectionView *)headView
{
    if (!_headView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _headView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _headView.delegate = self;
        _headView.dataSource = self;
    
        [_headView registerClass:[LCFilePathViewCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _headView;
}

@end





@implementation LCFilePathViewCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.font = [UIFont systemFontOfSize:HEADER_FONT_SIZE];
        self.textLabel.textColor = [UIColor yellowColor];
        [self.contentView addSubview:self.textLabel];
        self.contentView.layer.borderWidth = 1;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = self.contentView.bounds;
}

@end

@implementation LCFilePathViewNode

-(NSMutableArray *)children
{
    if (!_children) {
        _children = [NSMutableArray array];
    }
    return _children;
}

-(void)addChild:(LCFilePathViewNode *)child
{
    [self.children addObject:child];
}

-(NSArray*)brothers
{
    if (self.parent) {
        return self.parent.children;
    }else{
        return @[self];
    }
}

@end