-------------------------- MODULE discrete_time_nontemporal_model --------------------------
EXTENDS Integers, TLC

(*--algorithm discrete_time_nontemporal_model

variables
  discrete_time = 0,
  data_state = "A";
  
define
  NontemporalInvariant == /\ (discrete_time >= 0 /\ discrete_time < 25 => data_state = "A")
                          /\ (discrete_time >= 25 /\ discrete_time < 49 => data_state = "B")
                          /\ (discrete_time >= 49 /\ discrete_time < 73 => data_state = "C")
end define;

process DiscreteTimeProcess = 1
begin
  UpdateNontemporalData:
    while discrete_time < 72 do
      print << discrete_time, data_state >>;
      discrete_time := discrete_time + 1;
      if discrete_time >= 25 /\ discrete_time < 49 then
        data_state := "B";
      elsif discrete_time >= 49 /\ discrete_time < 73 then
        data_state := "C";
      end if;
    end while;
end process;

end algorithm; *)
\* BEGIN TRANSLATION (chksum(pcal) = "c3d4e5f6" /\ chksum(tla) = "g7h8i9j0")
VARIABLES discrete_time, data_state, pc

(* define statement *)
NontemporalInvariant == /\ (discrete_time >= 0 /\ discrete_time < 25 => data_state = "A")
                        /\ (discrete_time >= 25 /\ discrete_time < 49 => data_state = "B")
                        /\ (discrete_time >= 49 /\ discrete_time < 73 => data_state = "C")

vars == << discrete_time, data_state, pc >>

ProcSet == {1}

Init == (* Global variables *)
        /\ discrete_time = 0
        /\ data_state = "A"
        /\ pc = [self \in ProcSet |-> "UpdateNontemporalData"]

UpdateNontemporalData == /\ pc[1] = "UpdateNontemporalData"
                         /\ IF discrete_time < 72
                               THEN /\ PrintT(<< discrete_time, data_state >>)
                                    /\ discrete_time' = discrete_time + 1
                                    /\ IF discrete_time' >= 25 /\ discrete_time' < 49
                                          THEN /\ data_state' = "B"
                                          ELSE /\ IF discrete_time' >= 49 /\ discrete_time' < 73
                                                     THEN /\ data_state' = "C"
                                                     ELSE /\ data_state' = data_state
                                    /\ pc' = [pc EXCEPT ![1] = "UpdateNontemporalData"]
                               ELSE /\ pc' = [pc EXCEPT ![1] = "Done"]
                                    /\ UNCHANGED << discrete_time, data_state >>

DiscreteTimeProcess == UpdateNontemporalData

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == DiscreteTimeProcess
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 

=============================================================================
\* Modification History
\* Last modified Sun Jul 27 20:30:00 JST 2025 by yumuuu
\* Created Sun Jul 27 20:30:00 JST 2025 by yumuuu
