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

// PW3: Reputation scores for known agents (0-10 scale)
// companyC and companyD have multiple instances (companyC1..5, companyD1..13)
// so we assign reputation per individual agent name
reputation("companyA",  9).   // reliable plumber, always on time
reputation("companyB",  7).   // decent site prep company
reputation("companyC1", 6).   // average multi-tasker
reputation("companyC2", 6).
reputation("companyC3", 6).
reputation("companyC4", 6).
reputation("companyC5", 6).
reputation("companyD1",  2).   // random bidder, unreliable
reputation("companyD2",  2).
reputation("companyD3",  2).
reputation("companyD4",  2).
reputation("companyD5",  2).
reputation("companyD6",  2).
reputation("companyD7",  2).
reputation("companyD8",  2).
reputation("companyD9",  2).
reputation("companyD10", 2).
reputation("companyD11", 2).
reputation("companyD12", 2).
reputation("companyD13", 2).
reputation("companyE",   9).   // excellent for structural work

// Giacomo's minimum reputation threshold to get an invitation
min_reputation(5).

// PW3: rule — agent is trusted if its reputation >= threshold
trusted(Ag) :-
    .term2string(Ag, AgS) &
    reputation(AgS, R) &
    min_reputation(MinR) &
    R >= MinR.

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
   <- !presentation_phase;
      !create_auction_artifacts;
      !wait_for_bids.

// PW2: Wait for company agents to present themselves, then invite them
+!presentation_phase
   <- println("Waiting 5 seconds for company presentations...");
      .wait(5000);
      println("Presentation phase done. Processing profiles...").

// Plan for creating all the artifacts for each task AND inviting relevant agents
+!create_auction_artifacts
   <- for ( my_preference(Task,Amount) ) {
          !create_auction_artifact(Task, Amount, _);
      }.

// Plan for creation of an auction artifact for a given task and maxprice
// PW3: invite only agents with skill AND sufficient reputation
+!create_auction_artifact(Task, MaxPrice, ArtId)
   <- .concat("auction_for_", Task, ArtName);
      makeArtifact(ArtName, "tools.AuctionArt", [Task, MaxPrice], ArtId);
      focus(ArtId);
      // find agents with the skill who also pass the reputation threshold
      .findall(Ag, my_task(Task)[source(Ag)] & trusted(Ag), TrustedAgents);
      .length(TrustedAgents, N);
      println("Task ", Task, " → inviting ", N, " trusted agents (reputation filter active)");
      for ( .member(Ag, TrustedAgents) ) {
          .term2string(Ag, AgS);
          ?reputation(AgS, R);
          println("  + ", Ag, " (reputation: ", R, ")");
          .send(Ag, tell, auction_to_use(Task, ArtName))
      }.

// Recovery Plan for failure in the creation of an auction artifact
-!create_auction_artifact(Task,MaxPrice,_)[error_code(Code)]
   <- .print("Error creating artifact for ", Task, ": ", Code).

// Plan for handling the bids and getting the winner of an auction
+!wait_for_bids
   <- println("Waiting bids for 5 seconds...");
      .wait(5000);
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
      !!go;  // Auto-trigger execution phase after contracting
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
