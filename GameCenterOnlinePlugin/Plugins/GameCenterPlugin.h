//
//  GameCenterPlugin.h
//  Othello
//
//  Created by hackintosh on 20/02/13.
//
//

#import <Cordova/CDV.h>
#import "GCHelper.h"
@class OthelloOnlineViewController;

typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
} GameState;

typedef enum {
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnect
} EndReason;

typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeGameOver
} MessageType;

typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
    uint32_t i;
    uint32_t j;
} MessageMove;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;


@interface GameCenterPlugin : CDVPlugin <GCHelperDelegate>  {
    uint32_t ourRandom;
    BOOL receivedRandom;
    NSString *otherPlayerID;
    BOOL isPlayer1;
    GameState gameState;
    
}

- (void)authenticateLocalPlayer:(CDVInvokedUrlCommand*)command;
- (void)startGame:(CDVInvokedUrlCommand*)command;
- (void)sendMove:(CDVInvokedUrlCommand*)command;


@end
