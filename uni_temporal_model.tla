-------------------------- MODULE uni_temporal_model --------------------------
EXTENDS Integers, TLC, Sequences

CONSTANTS NULL

(*--algorithm uni_temporal_model

\* Uni-temporal data modelで状態遷移のモデル検査を行う
variables
  valid_time = 1, 
  temporal_table = [i \in 1..72 |-> "A"];  
  
define
  \* =============================================================================
  \* 🔍 Uni-temporal Data Model 不変条件
  \* =============================================================================
  TemporalInvariant == 
    \/ pc[1] = "InitializeTemporal"  
    \/ (/\ 
          Len(temporal_table) = 72  
       
       /\ \* 状態値の妥当性チェック
          \A i \in 1..Len(temporal_table):
              temporal_table[i] \in {"A", "B", "C"}
       
       /\ \* 有効な状態遷移ルール (A→A, A→B, B→B, B→C, C→C)
          \A j \in 1..(Len(temporal_table)-1):
              \/ (temporal_table[j] = "A" /\ temporal_table[j+1] \in {"A", "B"})
              \/ (temporal_table[j] = "B" /\ temporal_table[j+1] \in {"B", "C"})
              \/ (temporal_table[j] = "C" /\ temporal_table[j+1] = "C")
       
       /\ \* 無効な直接遷移の禁止 (A→C, C→A, C→B は無効)
          \A k \in 1..(Len(temporal_table)-1):
              /\ ~(temporal_table[k] = "A" /\ temporal_table[k+1] = "C")  \* A→C禁止
              /\ ~(temporal_table[k] = "C" /\ temporal_table[k+1] \in {"A", "B"})  \* C→A,B禁止
       
       /\ \* 初期状態は必ずA
          (Len(temporal_table) > 0 => temporal_table[1] = "A")
       
       /\ \* Historical Correctionの妥当性チェック
          (valid_time > 60 => 
              \A m \in 20..24:
                  (m < Len(temporal_table) => 
                      temporal_table[m] = "A" /\ temporal_table[m+1] \in {"A", "B"})))
end define;

process TemporalProcess = 1
begin
  InitializeTemporal:
    temporal_table := [i \in 1..72 |-> "A"];  \* 時間テーブルを"A"で初期化
  
  TemporalUpdate:
    while valid_time <= 72 do
      print << valid_time >>;
      
      \* Future Update: 現在時点から未来への状態更新
      FutureUpdate:
      if valid_time = 1 then
        temporal_table := [i \in valid_time..72 |-> "A"];
        print << "Future Update: A for valid_time 1..72" >>
      elsif valid_time = 25 then
        temporal_table := [i \in valid_time..72 |-> "B"];
        print << "Future Update: B for valid_time 25..72" >>
      elsif valid_time = 49 then
        temporal_table := [i \in valid_time..72 |-> "C"];
        print << "Future Update: C for valid_time 49..72" >>
      end if;

      \* Historical Correction: 過去データの修正
      HistoricalCorrection:
      if valid_time = 60 then
        temporal_table := [i \in 1..72 |-> IF i \in 20..25 THEN "A" ELSE temporal_table[i]];
        print << "Historical Correction: A for valid_time 20..25" >>
      end if;

      ValidTimeIncrement:
      valid_time := valid_time + 1;
    end while;
end process;

end algorithm; *)
\* BEGIN TRANSLATION (chksum(pcal) = "placeholder" /\ chksum(tla) = "placeholder")
VARIABLES valid_time, temporal_table, pc

(* define statement *)
TemporalInvariant ==
  \/ pc[1] = "InitializeTemporal"
  \/ (/\
        Len(temporal_table) = 72

     /\
        \A i \in 1..Len(temporal_table):
            temporal_table[i] \in {"A", "B", "C"}

     /\
        \A j \in 1..(Len(temporal_table)-1):
            \/ (temporal_table[j] = "A" /\ temporal_table[j+1] \in {"A", "B"})
            \/ (temporal_table[j] = "B" /\ temporal_table[j+1] \in {"B", "C"})
            \/ (temporal_table[j] = "C" /\ temporal_table[j+1] = "C")

     /\
        \A k \in 1..(Len(temporal_table)-1):
            /\ ~(temporal_table[k] = "A" /\ temporal_table[k+1] = "C")
            /\ ~(temporal_table[k] = "C" /\ temporal_table[k+1] \in {"A", "B"})

     /\
        (Len(temporal_table) > 0 => temporal_table[1] = "A")

     /\
        (valid_time > 60 =>
            \A m \in 20..24:
                (m < Len(temporal_table) =>
                    temporal_table[m] = "A" /\ temporal_table[m+1] \in {"A", "B"})))


vars == << valid_time, temporal_table, pc >>

ProcSet == {1}

Init == (* Global variables *)
        /\ valid_time = 1
        /\ temporal_table = [i \in 1..72 |-> "A"]
        /\ pc = [self \in ProcSet |-> "InitializeTemporal"]

InitializeTemporal == /\ pc[1] = "InitializeTemporal"
                      /\ temporal_table' = [i \in 1..72 |-> "A"]
                      /\ pc' = [pc EXCEPT ![1] = "TemporalUpdate"]
                      /\ UNCHANGED valid_time

TemporalUpdate == /\ pc[1] = "TemporalUpdate"
                  /\ IF valid_time <= 72
                        THEN /\ PrintT(<< valid_time >>)
                             /\ pc' = [pc EXCEPT ![1] = "FutureUpdate"]
                        ELSE /\ pc' = [pc EXCEPT ![1] = "Done"]
                  /\ UNCHANGED << valid_time, temporal_table >>

FutureUpdate == /\ pc[1] = "FutureUpdate"
                /\ IF valid_time = 1
                      THEN /\ temporal_table' = [i \in valid_time..72 |-> "A"]
                           /\ PrintT(<< "Future Update: A for valid_time 1..72" >>)
                      ELSE /\ IF valid_time = 25
                                 THEN /\ temporal_table' = [i \in valid_time..72 |-> "B"]
                                      /\ PrintT(<< "Future Update: B for valid_time 25..72" >>)
                                 ELSE /\ IF valid_time = 49
                                            THEN /\ temporal_table' = [i \in valid_time..72 |-> "C"]
                                                 /\ PrintT(<< "Future Update: C for valid_time 49..72" >>)
                                            ELSE /\ TRUE
                                                 /\ UNCHANGED temporal_table
                /\ pc' = [pc EXCEPT ![1] = "HistoricalCorrection"]
                /\ UNCHANGED valid_time

HistoricalCorrection == /\ pc[1] = "HistoricalCorrection"
                        /\ IF valid_time = 60
                              THEN /\ temporal_table' = [i \in 1..72 |-> IF i \in 20..25 THEN "A" ELSE temporal_table[i]]
                                   /\ PrintT(<< "Historical Correction: A for valid_time 20..25" >>)
                              ELSE /\ TRUE
                                   /\ UNCHANGED temporal_table
                        /\ pc' = [pc EXCEPT ![1] = "ValidTimeIncrement"]
                        /\ UNCHANGED valid_time

ValidTimeIncrement == /\ pc[1] = "ValidTimeIncrement"
                      /\ valid_time' = valid_time + 1
                      /\ pc' = [pc EXCEPT ![1] = "TemporalUpdate"]
                      /\ UNCHANGED temporal_table

TemporalProcess == InitializeTemporal \/ TemporalUpdate \/ FutureUpdate
                      \/ HistoricalCorrection \/ ValidTimeIncrement

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == TemporalProcess
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 

=============================================================================
\* Modification History
\* Last modified for Uni-temporal terminology standardization
\* Created for Uni-temporal Data Model verification
