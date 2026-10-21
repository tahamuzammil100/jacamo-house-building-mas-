/* auxiliary rules for agents */

i_am_winning(Art)   // check if I placed the current best bid on auction artifact Art
   :- currentWinner(W)[artifact_id(Art)] &
      .my_name(Me) & .term2string(Me,MeS) & W == MeS.

/* PW2: Presentation phase — send profile to giacomo */

+!start : true
   <- !present_to_giacomo.

// Send all my_task beliefs to giacomo as external description
+!present_to_giacomo
   <- .my_name(Me);
      for ( my_task(Task) ) {
          .send(giacomo, tell, my_task(Task))
      }.

// When giacomo sends an invitation: auction_to_use(Task, ArtName)
// focus on that specific artifact to start bidding
+auction_to_use(Task, ArtName)[source(giacomo)]
   <- .print("Invited to auction for ", Task, " → ", ArtName);
      !discover_art(ArtName).

// try to find a particular artifact and then focus on it
+!discover_art(ToolName)
   <- lookupArtifact(ToolName,ToolId);
      focus(ToolId).
// keep trying until the artifact is found
-!discover_art(ToolName)
   <- .wait(100);
      !discover_art(ToolName).
