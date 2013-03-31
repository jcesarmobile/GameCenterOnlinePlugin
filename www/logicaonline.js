var gameTurn=0;
var primera=0;
var boardArray;
var gameStarted = false;
var otherGamerId;
var myTurn = -1;
var player1Name;
var player2Name;


 $(document).ready(function() {

    document.addEventListener("deviceready", onDeviceReady, false);

    createBoard();
    
	$("#start_button").hide();
    $("#reset").hide();
    $("#start_button").click(openGameCenter);
  
 });
 

function onDeviceReady() {
    
    
    window.gameCenter.authenticate( function() {
        
        window.gameCenter.startGame( function() {}, nativePluginErrorHandler);
                                   
    }, nativePluginErrorHandler);
    
    window.gameCenter.onSearchCancelled = function() {
        
        $("#start_button").show();
        $("#status").text("Search was Cancelled, Press Start button");
    
    }
    
    window.gameCenter.onSearchFailed = function() {
        
        $("#start_button").show();
        $("#status").text("Search Failed, Press Start button");
        
    }
    
    window.gameCenter.receivedTurn = function(data) {
        
        myTurn = data;
        var color;
        if (myTurn ==1) {
            
            color = "You are White Player";
            
        } else {
            
            color = "You are Black Player";
            
        }
        
        $("#your_color").text(color);
        startNewGame();
        
    }
    
    window.gameCenter.receivedMove = function(i,j) {
       
        makeMove(i,j, false);
        
    }
    
    window.gameCenter.receivedGamerNames = function(name1, name2) {
        
        player1Name = name1;
        player2Name = name2;
        updateTexts();
        
    }
    
    window.gameCenter.matchEnded = function () {
        
        console.log('match ended');
        gameStarted = false;
        $("#status").text("Match Ended");
        $("#start_button").show();
        
    }
    
}

function nativePluginErrorHandler (error) {
    console.log('error: '+error);
}

function createBoard(){
    
    var boardString ="";
    var arrIds = new Array();
    for (var i=0;i<8;i++) {
        
        boardString += "<div class='fila'>";
        for (var j=0;j<8;j++){
            boardString += "<div class='casilla' id='"+i+j+"'><div></div></div>";
            var id = i.toString()+j.toString();
            arrIds.push(id);
        }
        boardString += "</div>"
    }
    $("#board").append(boardString);
    
	jQuery.each(arrIds, function(index, value) {
        $("#" + this).click(function(e) {
                            
            var i=parseInt(value.charAt(0));
            var j=parseInt(value.charAt(1));
            makeMove( i,j, true);
                            
        });
                
    });
    paintBoard();
	
}

function paintBoard(){
    var cont=1;
    for (var i=0;i<8;i++) {
        
        for (var j=0;j<8;j++){
			if (cont%2==0)
                $("#"+i+j).addClass("lightGreen");
			else
                $("#"+i+j).addClass("darkGreen");
			cont++;
			
		}
		cont++;
        
	}
}


function makeMove( i,j, send){
    
    if ((myTurn == gameTurn)||(send==false)) {
        
            if (gameStarted) {

                    if (!$("#"+i+j).is('.black')&&!$("#"+i+j).is('.white')) {
                        

                        
                        if (putDisk(i,j,true)==true) {
                            
                            if (send) {
                                window.gameCenter.sendMove( function(result) {
                                                           
                                                           console.log(result);
                                                           }, nativePluginErrorHandler, i,j );
                            }
                            
                            repaintBoard();
                            
                            
                        } else {
                            
                            invalidMoveAlert();
                        }
                        
                    }
                    
                updateTexts();
                if (diskNumberWithColor(null)==0) {
                    
                    $("#status").text("Board Full");
                    repaintBoard();
                    gameStarted=false;
                    $("#start_button").show();
  
                }
                
            }
        
    } else {
        
        if ((myTurn != gameTurn)&&(send==true))
        navigator.notification.alert(
                                     "Please wait until the other player makes his move",  // message
                                     alertDismissed,         // callback
                                     "It isn't your turn",            // title
                                     "OK"                  // buttonName
                                     );
       
    }
	
	
 }

function initializeBoard(){
	boardArray=new Array(8);
	for (var i=0;i<8;i++)
		boardArray [i]=new Array (8);
		
	for (var i=0;i<8;i++)
		for (var j=0;j<8;j++){
			boardArray[i][j]=new Array(2);
			boardArray[i][j][0]=false;
			boardArray[i][j][1]=null;
			$("#"+i+j+" div").removeClass("black");
			$("#"+i+j+" div").removeClass("white");
			
		}

}
		
function repaintBoard(){

    for (i=0;i<8;i++)

        for (j=0;j<8;j++){
                
            $("#"+i+j+" div").removeClass("black");
            $("#"+i+j+" div").removeClass("white");
            
			if (boardArray[i][j][0]==true){
                
                $("#"+i+j+" div").addClass(boardArray[i][j][1]);
                console.log(boardArray[i][j][1]);
                    
            } 
					
        }
			
}
			
function openGameCenter(){

    window.gameCenter.startGame( function() {}, nativePluginErrorHandler);
    
}
				

function startNewGame(){
    

    primera=1;
	initializeBoard();
    gameStarted=true;
    gameTurn=2;
	$("#start_button").hide();
    updateTexts();

}

function putDisk(f,c, change){
	
	if (getDiskAtPosition(f,c)==null){
        
        if(change) {
            
            if (gameTurn==1){
                
                gameTurn = 2;
                setDiskAtPosition(f,c,"white");
                
            } else {
                
                gameTurn = 1;
                setDiskAtPosition(f,c,"black");
                
            }
            
        }
        
        return true;

    } else return false;

}


function getDiskAtPosition(f,c) {
	
	return boardArray[f][c][1];
	
}
	
function setDiskAtPosition(f,c,type){
	
		boardArray[f][c][1]=type;
		boardArray[f][c][0]=true;
	
}
	
function diskNumberWithColor(color){

    var cont=0;
    for (var i=0;i<8;i++)
        for (var j=0;j<8;j++){
				
            if (boardArray[i][j][1]==color){

                cont++;
                    
            }
				
        }
    
    return cont;

}

function alertDismissed() {
    // do something
}

function invalidMoveAlert(){
    
    navigator.notification.alert(
                                 "You can't move here",  // message
                                 alertDismissed,         // callback
                                 "Invalid move",            // title
                                 "OK"                  // buttonName
                                 );


    
}


function updateTexts(){
    
    var turnoTitle;

    if (gameTurn == 1) {
        
        turnoTitle = "White Player Turn";
        
    }
    
    else {
        
        turnoTitle = "Black Player Turn";
        
    }
    
    $("#status").text(turnoTitle);
    $("#player2").text(player2Name+": "+diskNumberWithColor("white"));
    $("#player1").text(player1Name+": "+diskNumberWithColor("black"));

}



