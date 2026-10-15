// Agent Giacomo, who wants to build a house

// Inclusion of standards agent's behavior to make agents able to work in an JaCaMo environment
{ include("$jacamoJar/templates/common-cartago.asl") }
// Inclusion of standards agent's behavior to make agents able to work in an JaCaMo organisation
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
// Inclusion of common behaviors for this application
{ include("common.asl") }

/* Initial beliefs and rules */

my_preference("SitePreparation", 2000). // 2000 is the maximum value I can pay for the task
my_preference("Floors",          1000).
my_preference("Walls",           1000).
my_preference("Roof",            2000).
my_preference("WindowsDoors",    2500).
my_preference("Plumbing",         500).
my_preference("ElectricalSystem", 500).
my_preference("Painting",        1200).

// rule for counting the number of tasks based on the observable properties of the auction artifacts
number_of_tasks(NS) :- .findall( S, task(S), L) & .length(L,NS).

// rule for testing if we have the right number of winners
enough_winners :- number_of_tasks(NS) &
       .findall( ArtId, currentWinner(A)[artifact_id(ArtId)] & A \== "no_winner", L) &
       .length(L, NS).
       
/* Initial goals */

!have_a_house.


/* Plans */

/* Reactive data-directed plans monitoring the building of the house */
+sitePrepared : true <- .print("site has been prepared !!!! :-)").
+interiorPainted : true <- .print("interior has been painted !!!! :-)").
+exteriorPainted : true <- .print("exterior has been painted !!!! :-)").
+electricalSystemInstalled : true <- .print("electrical system has been installed !!!! :-)").
+plumbingInstalled : true <- .print("plumbing has been installed !!!! :-)").
+windowsFitted : true <- .print("windows have been fitted !!!! :-)").
+doorsFitted : true <- .print("doors have been fitted !!!! :-)").
+roofBuilt : true <- .print("roof has been built !!!! :-)").
+wallsBuilt : true <- .print("walls have been built !!!! :-)").
+floorsLayed : true <- .print("floors have been layed !!!! :-)").

// plan for building the house with two sub-goals: contract and execute
+!have_a_house
   <- !contract; // hire the companies that will build the house
      !execute;  // (simulates) the execution of the construction
      .
// recovery plan for the failure of the achievement of the goal have_a_house
-!have_a_house[error(E),error_msg(Msg),code(Cmd),code_src(Src),code_line(Line)]
   <- .print("Failed to build a house due to: ",Msg," (",E,"). Command: ",Cmd, " on ",Src,":", Line).


/* Plans for the contracting phase */

+!contract : true
   <- !create_auction_artifacts;
      !wait_for_bids.

// Plan for creating all the artifacts for each task
+!create_auction_artifacts
   <- for ( my_preference(Task,Amount) ) {  // iterate over the beliefs my_preference
          !create_auction_artifact(Task, Amount,ArtId);
          };
       .

// Plan for creation of an auction artifact for a given task and maxprice
+!create_auction_artifact(Task,MaxPrice,ArtId)
   <- .concat("auction_for_",Task,ArtName);
      makeArtifact(ArtName, "tools.AuctionArt", [Task, MaxPrice], ArtId);
      focus(ArtId).
// Recovery Plan for failure in the creation of an auction artifact for a given task and maxprice      
-!create_auction_artifact(Task,MaxPrice)[error_code(Code)]
   <- .print("Error creating artifact ", Code).

// Plan for handling the bids and getting the winner of an auction
+!wait_for_bids
   <- println("Waiting bids for 5 seconds...");
      .wait(5000); // use an internal deadline of 5 seconds to close the auctions
      !show_winners.

+!show_winners
   <- for ( currentWinner(Ag)[artifact_id(ArtId)] ) {
         ?currentBid(Price)[artifact_id(ArtId)]; // check the current bid
         ?task(Task)[artifact_id(ArtId)];          // and the task it is for
         println("Winner of task ", Task," is ", Ag, " for ", Price)
      }.

/* Plans for managing the execution of the house construction */

+!execute
   <- println;
      println("*** Execution Phase ***");
      println("Waiting the `go` from the user");
      //!!go;  // Commented to stop the execution and waiting for message
      .

+!go <-
      // create the organisation for managing the building of the house
      .my_name(Me);
      createWorkspace("ora4mas");
      joinWorkspace("ora4mas",WOrg);

      // NB.: we (have to) use the same id for OrgBoard and Workspace (ora4mas in this example)
      makeArtifact(ora4mas, "ora4mas.nopl.OrgBoard", ["src/org/house-os.xml"], OrgArtId)[wid(WOrg)];
      focus(OrgArtId);
      // create the group and adopt the role house_owner
      createGroup(hsh_group, house_group, GrArtId);
      debug(inspector_gui(on))[artifact_id(GrArtId)];
      adoptRole(house_owner)[artifact_id(GrArtId)];
      focus(GrArtId);

      // sub-goal for contracting the winner and making them enter enter into the group
      !contract_winners("hsh_group"); 

      // create the scheme
      createScheme(bhsch, build_house_sch, SchArtId);
      debug(inspector_gui(on))[artifact_id(SchArtId)];
      focus(SchArtId);

      ?formationStatus(ok)[artifact_id(GrArtId)]; // see plan below to ensure we wait until it is well formed
      addScheme("bhsch")[artifact_id(GrArtId)];
      commitMission("management_of_house_building")[artifact_id(SchArtId)];
      .

// plan for contracting with each of the winning company in case we have all winners
+!contract_winners(GroupName) : enough_winners
   <- for ( currentWinner(Ag)[artifact_id(ArtId)] ) {
            ?task(Task)[artifact_id(ArtId)];
            println("Contracting ",Ag," for ", Task);
            // sends the message to the agent notifying it about the result
            .send(Ag, achieve, contract(Task,GroupName)) 
      }.

// plan for contracting in case we don't have enough winners
+!contract_winners(_)
   <- println("** I didn't find enough builders!");
      .fail.

// Plans to wait until the group is well formed
// Makes this intention suspend until the group is believed to be well formed
+?formationStatus(ok)[artifact_id(G)]
   <- .wait({+formationStatus(ok)[artifact_id(G)]}).

+!house_built // I have an obligation towards the top-level goal of the scheme: finished!
   <- println("*** Finished ***").
