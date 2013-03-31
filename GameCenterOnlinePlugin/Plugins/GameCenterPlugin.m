//
//  GameCenterPlugin.m
//  Othello
//
//  Created by hackintosh on 20/02/13.
//
//

#import "GameCenterPlugin.h"

@implementation GameCenterPlugin


- (void)authenticateLocalPlayer:(CDVInvokedUrlCommand*)command
{
   
    [[GCHelper sharedInstance] authenticateLocalUserWithBlock:^(NSError *error) {
        if (error == nil)
        {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self writeJavascript: [pluginResult toSuccessCallbackString:command.callbackId]];
        }
        else
        {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self writeJavascript: [pluginResult toErrorCallbackString:command.callbackId]];
        }
    }];
}

- (void)startGame:(CDVInvokedUrlCommand*)command
{
    
    CDVPluginResult* pluginResult = nil;
    [self inicializar];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)getLocalPlayerId:(CDVInvokedUrlCommand*)command
{
    
    CDVPluginResult* pluginResult = nil;
    GKPlayer * localPlayer = [GKLocalPlayer localPlayer];
    if ([GKLocalPlayer localPlayer].authenticated) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:localPlayer.playerID];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)sendMove:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString * iString = [command.arguments objectAtIndex:0];
    NSString * jString = [command.arguments objectAtIndex:1];
    
    if (![iString isEqual:[NSNull null]]&&![jString isEqual:[NSNull null]]) {
        NSLog(@"enviado");
        uint32_t i = [iString integerValue];
        uint32_t j = [jString integerValue];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"sent"];
        [self sendGameMove:i andj:j];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"you have to send 2 params"];
    }
     
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}



-(void)inicializar {
    ourRandom = arc4random();
    [self setGameState:kGameStateWaitingForMatch];
    
    [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self.viewController delegate:self];
    
    ourRandom = arc4random();
    [self setGameState:kGameStateWaitingForMatch];
}

#pragma mark GCHelperDelegate

- (void)matchStarted {
    NSLog(@"Match started");
    if (receivedRandom) {
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    [self sendRandomNumber];
    [self tryStartGame];
    
}

- (void)matchEnded {
    
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    NSString * javascriptString = @"window.gameCenter._matchEnded();";
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
    
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = [playerID retain];
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
        
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom) {
            NSLog(@"TIE!");
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber) {
            NSLog(@"We are player 1");
            isPlayer1 = YES;
            NSString * javascriptString = [NSString stringWithFormat:@"window.gameCenter._receivedTurn(2);"];
            [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
        } else {
            NSLog(@"We are player 2");
            isPlayer1 = NO;
            NSString * javascriptString = [NSString stringWithFormat:@"window.gameCenter._receivedTurn(1);"];
            [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
        }
        
        if (!tie) {
            receivedRandom = YES;
            if (gameState == kGameStateWaitingForRandomNumber) {
                [self setGameState:kGameStateWaitingForStart];
            }
            [self tryStartGame];
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {
        [self sendGamerNames:otherPlayerID];
        [self setGameState:kGameStateActive];
        
    } else if (message->messageType == kMessageTypeMove) {
        
        MessageMove * messageMove = (MessageMove *) [data bytes];
        NSString * javascriptString = [NSString stringWithFormat:@"window.gameCenter._receivedMove('%i','%i');",messageMove->i,messageMove->j];
        [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
        
    }
}

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendData:data];
    
}

- (void)sendGameBegin {
    
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
    [self sendData:data];
    
}

- (void)tryStartGame {
    
    if (isPlayer1 && gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        [self sendGameBegin];
        [self sendGamerNames:otherPlayerID];
    }
    
}

- (void)setGameState:(GameState)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch) {
        NSLog(@"Waiting for match");
    } else if (gameState == kGameStateWaitingForRandomNumber) {
        NSLog(@"Waiting for rand #");
    } else if (gameState == kGameStateWaitingForStart) {
        NSLog(@"Waiting for start");
    } else if (gameState == kGameStateActive) {
        NSLog(@"Active");
    } else if (gameState == kGameStateDone) {
        NSLog(@"Done");
    }
    
}

- (void)sendGameMove:(uint32_t)i andj:(uint32_t)j {
    
    MessageMove message;
    message.message.messageType = kMessageTypeMove;
    message.i = i;
    message.j = j;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)];
    [self sendData:data];
    
}

-(void)inviteReceived {
    
    [self inicializar];
    
}

-(void)searchCancelled {
    NSString * javascriptString = @"window.gameCenter._searchCancelled();";
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
}

-(void)searchFailed {
    
    NSString * javascriptString = @"window.gameCenter._searchFailed();";
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
    
}

-(void)sendGamerNames:(NSString *)playerID {
    
    NSString * javascriptString;
    GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:playerID];

    if (isPlayer1) {
        
        javascriptString = [NSString stringWithFormat:@"window.gameCenter._receivedGamerNames('%@','%@');",[GKLocalPlayer localPlayer].alias,player.alias];
        
    } else {
        
        javascriptString = [NSString stringWithFormat:@"window.gameCenter._receivedGamerNames('%@','%@');",player.alias,[GKLocalPlayer localPlayer].alias];
        
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
}

@end
