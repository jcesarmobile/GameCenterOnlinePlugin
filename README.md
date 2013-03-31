GameCenterOnlinePlugin
======================

First of all a bit of self promotion. I created the Game Center Online plugin because I wanted to add online game to mi phonegap game, Othello Classic (http://goo.gl/hCJjC)
If you want to see the plugin in action or want to support me please download the game.
The plugin isn't exactly the same I used on Othello Classic because my game is done with Cleaver, I had to make some changes and add new code for the plugin so everyone can use it.

The plugin is a bit limited right now, it just do what I needed for Othello Classic, so right now it only can be used in 2 player games and only can send/receive 2 ints (board coordinates for example)

I have uploaded a full working sample game with almost no logic, where there are 2 players and they just put a disk in their turn. Nobody wins, nobody loses.

The plugin is based on the code from Ray Wenderlich Game Center tutorial
http://www.raywenderlich.com/3276/how-to-make-a-simple-multiplayer-game-with-game-center-tutorial-part-12
It's a recommended read before start using the pluging

DOCUMENTATION:

authenticate to Game Center
window.gameCenter.authenticate( successCallback, failureCallback );

start searching a new game
window.gameCenter.startGame( successCallback, failureCallback );

send move
window.gameCenter.sendMove( successCallback, failureCallback, x,y ); //x and y are the board coordinates.

Events
The user cancel the new game search (dissmiss the game center screen)
window.gameCenter.onSearchCancelled = function() {
//Do somethig
}

The search fails
window.gameCenter.onSearchFailed = function() {       
  //Do something      
}

The game receive the player's turn.
It can be 1 or 2.
It is only received once, you have to store it and consider it for turn based games. 
The plugin doesn't handle turns, but it knows which player sent the move.
The player turn is assigned randomly
window.gameCenter.receivedTurn = function(data) {
// do something with the turn (data) with values 1 or 2       
}

Game received the other player move
window.gameCenter.receivedMove = function(i,j) {
//i and j are the coordinates of the other player move, do something with them
}

Game received the player names
name 1 is the name for the player with turn 1, name 2 is the name for the player with turn 2
window.gameCenter.receivedGamerNames = function(name1, name2) {
  //show the names somewhere if you want.      
}

Game ended for technical problems:
One of the player lost the game center connection
The game couldn't connect with the other player
The game failed to send data to the other player
window.gameCenter.matchEnded = function () {
   //Do something when one of the above problems happended     
}


HOW TO USE:

1.- Add GameKit framework to your xcode project
2.- Drag GameCenterPlugin.h, GameCenterPlugin.m, GCHelper.h and GCHelper.m to your xcode project
3.- Add this line in the config.xml inside the <plugins> tag <plugin name="GameCenterPlugin" value="GameCenterPlugin" />

