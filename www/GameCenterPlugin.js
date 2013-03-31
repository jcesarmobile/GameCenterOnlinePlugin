(function(window) {
 var GameCenter = function() {

 this.onSearchCancelled = null;
 this.receivedMove = null;
 this.receivedTurn = null;
 this.matchEnded = null;
 
 }
 
 GameCenter.prototype = {
 authenticate: function(s, f) {
    cordova.exec(s, f, "GameCenterPlugin", "authenticateLocalPlayer", []);
 },
 startGame: function (success, fail) {
  cordova.exec( success, fail, "GameCenterPlugin", "startGame", []);
 },
 sendMove: function (success, fail, i,j) {
  cordova.exec( success, fail, "GameCenterPlugin", "sendMove", [i,j]);
 },
 _searchCancelled: function() {
 if (typeof this.onSearchCancelled === 'function') { this.onSearchCancelled(); }
 },
 _searchFailed: function() {
 if (typeof this.onSearchFailed === 'function') { this.onSearchFailed(); }
 },
 _receivedMove: function (i,j) {
 if (typeof this.receivedMove === 'function') { this.receivedMove(i,j); }
 },
 _receivedTurn: function (turn) {
 if (typeof this.receivedTurn === 'function') { this.receivedTurn(turn); }
 }, _matchEnded: function () {
 if(typeof this.matchEnded === 'function') {
    this.matchEnded();
 }
 }, _receivedGamerNames: function (name1,name2) {
 if(typeof this.receivedGamerNames === 'function') {
 this.receivedGamerNames(name1,name2);
 }
 }
 };
 
 cordova.addConstructor(function() {
                        window.gameCenter = new GameCenter();
                        });
 })(window);