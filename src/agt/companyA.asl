// This company bids for Plumbing only
// Strategy: fixed price

// Inclusion of standards agent's behavior to make agents able to work in an JaCaMo environment
{ include("$jacamoJar/templates/common-cartago.asl") }
// Inclusion of common behaviors for this application
{ include("common.asl") }

// initial belief
my_price(300). 
my_task("Plumbing").

// initial goal to discover artifact
!start.

/* Plans for Auction phase */

+currentBid(V)[artifact_id(Art)]         // there is a new value for current bid
    : not i_am_winning(Art)  &           // I am not the current winner
      my_price(P) & P < V                // I can offer a better bid
   <- //.print("my bid in auction artifact ", Art, " is ",P);
      bid( P ).                          // place my bid offering a cheaper service

/* plans for execution phase */

{ include("org_code.asl") }
{ include("skills.asl") }
