-------------------------- MODULE tick_uni_temporal_model --------------------------
EXTENDS Integers, TLC, Sequences

CONSTANTS NULL

(*--algorithm tick_uni_temporal_model

\* =============================================================================
\* 🎯 モデル検査で行いたい仕様
\* =============================================================================
\* 
\* 【1. Uni-temporal Data Model の概念】
\* - 目的: 状態遷移のモデル検査を行う
\* - データ構造: uni_temporal_datamode (時系列配列)
\* - 時間軸: tick (離散時間、1から72まで)
\* - 特殊な意味: tick=72 は無限の未来を表す
\*
\* 【2. 状態遷移の基本ルール】
\* - 状態セット: {"A", "B", "C"}
\* - 遷移パターン: A → B → C
\* - 始点: A (初期状態)
\* - 終点: C (最終状態)
\*
\* 【3. 更新条件の仕様】
\* - 未来方向の状態更新:
\*   * tick=1:  uni_temporal_datamode[1..72] := "A"
\*   * tick=25: uni_temporal_datamode[25..72] := "B"
\*   * tick=49: uni_temporal_datamode[49..72] := "C"
\* - 過去方向の状態更新:
\*   * tick=60: uni_temporal_datamode[20..25] := "A" (過去修正)
\*
\* 【4. 重要な設計思想】
\* - Uni-temporal の特徴:
\*   * 現在から未来への更新: tick..72 の範囲で一括更新
\*   * 過去の修正: tick=60 で過去の 20..25 を修正
\*   * 状態の一貫性: 過去から見て不正な状態遷移は発生しない設計
\*
\* 【5. 検証したい性質】
\* - 基本的な状態遷移ルール:
\*   * A → A (継続可能)
\*   * A → B (正常遷移)
\*   * B → B (継続可能)
\*   * B → C (正常遷移)
\*   * C → C (継続可能)
\* - 不正な遷移の検出:
\*   * A → C (直接遷移は不正)
\*   * B → A (逆行は条件付きで許可)
\*   * C → A, C → B (逆行は不正)
\* - 過去修正の妥当性:
\*   * tick=60 での過去修正が状態遷移ルールに違反しないか
\*   * 修正後の時系列が一貫性を保っているか
\*
\* 【6. モデル検査の焦点】
\* このモデルは Uni-temporal データモデル における 状態遷移の正当性 と
\* 過去修正の安全性 を検証することを目的とし、特に時間軸上での状態変更が
\* 基本的な遷移ルール A→B→C に違反しないことを保証する。
\* =============================================================================

\* uni-temporal datamodelで状態遷移のモデル検査を行う
variables
  tick = 1, \*tickは離散時間を表す。1から72まで存在し、72は無限の未来を表す
  uni_temporal_datamode = <<>>;
  
define
  \* =============================================================================
  \* 🔍 Uni-temporal Data Model 不変条件
  \* =============================================================================
  UniTemporalInvariant == 
    \/ pc[1] = "InitializeData"  \* 初期化段階では不変条件をスキップ
    \/ (
       /\ \* 状態値の妥当性チェック
          \A i \in 1..Len(uni_temporal_datamode):
              uni_temporal_datamode[i] \in {"A", "B", "C"}
       
       /\ \* 基本的な状態遷移ルール (A→A, A→B, B→B, B→C, C→C)
          \A i \in 1..(Len(uni_temporal_datamode)-1):
              \/ (uni_temporal_datamode[i] = "A" /\ uni_temporal_datamode[i+1] \in {"A", "B"})
              \/ (uni_temporal_datamode[i] = "B" /\ uni_temporal_datamode[i+1] \in {"B", "C"})
              \/ (uni_temporal_datamode[i] = "C" /\ uni_temporal_datamode[i+1] = "C")
       
       /\ \* 不正な直接遷移の禁止 (A→C, B→A, C→A, C→B は基本的に不正)
          \A i \in 1..(Len(uni_temporal_datamode)-1):
              /\ ~(uni_temporal_datamode[i] = "A" /\ uni_temporal_datamode[i+1] = "C")  \* A→C禁止
              /\ ~(uni_temporal_datamode[i] = "C" /\ uni_temporal_datamode[i+1] \in {"A", "B"})  \* C→A,B禁止
       
       /\ \* 初期状態は必ずA
          (Len(uni_temporal_datamode) > 0 => uni_temporal_datamode[1] = "A")
       
       /\ \* 過去修正の妥当性チェック (tick=60での修正後も遷移ルールを満たす)
          (tick > 60 => 
              \A i \in 20..24:
                  (i < Len(uni_temporal_datamode) => 
                      uni_temporal_datamode[i] = "A" /\ uni_temporal_datamode[i+1] \in {"A", "B"})))
end define;

process DiscreteTimeProcess = 1
begin
  InitializeData:
    uni_temporal_datamode := <<>>;
  UpdateUniTemporalData:
    while tick <= 72 do
      print << tick >>;
      if tick = 1 then
        uni_temporal_datamode := [i \in tick..72 |-> "A"];
        print << "uni-temporal update A in 1..72" >>
      elsif tick = 25 then
        uni_temporal_datamode := [i \in tick..72 |-> "B"];
        print << "uni-temporal update B in 25..72" >>
      elsif tick = 49 then
        uni_temporal_datamode := [i \in tick..72 |-> "c"];
        print << "uni-temporal update C in 25..72" >>
      end if;

      if tick = 60 then
        uni_temporal_datamode := [i \in 20..25 |-> "A"];
        print << "uni-temporal update A in 20..25" >>
      end if

      tick := tick + 1;
    end while;
end process;

end algorithm; *)
\* BEGIN TRANSLATION (chksum(pcal) = "e5f6g7h8" /\ chksum(tla) = "i9j0k1l2")
VARIABLES tick, uni_temporal_datamode, pc

(* define statement *)
\* =============================================================================
\* 🔍 Uni-temporal Data Model 不変条件
\* =============================================================================
UniTemporalInvariant == 
  \/ pc[1] = "InitializeData"  \* 初期化段階では不変条件をスキップ
  \/ (/\ \* 基本的な配列構造の整合性
        Len(uni_temporal_datamode) = 72  \* 配列は常に72要素
     
     /\ \* 状態値の妥当性チェック
        \A i \in 1..Len(uni_temporal_datamode):
            uni_temporal_datamode[i] \in {"A", "B", "C"}
     
     /\ \* 基本的な状態遷移ルール (A→A, A→B, B→B, B→C, C→C)
        \A i \in 1..(Len(uni_temporal_datamode)-1):
            \/ (uni_temporal_datamode[i] = "A" /\ uni_temporal_datamode[i+1] \in {"A", "B"})
            \/ (uni_temporal_datamode[i] = "B" /\ uni_temporal_datamode[i+1] \in {"B", "C"})
            \/ (uni_temporal_datamode[i] = "C" /\ uni_temporal_datamode[i+1] = "C")
     
     /\ \* 不正な直接遷移の禁止 (A→C, B→A, C→A, C→B は基本的に不正)
        \A i \in 1..(Len(uni_temporal_datamode)-1):
            /\ ~(uni_temporal_datamode[i] = "A" /\ uni_temporal_datamode[i+1] = "C")  \* A→C禁止
            /\ ~(uni_temporal_datamode[i] = "C" /\ uni_temporal_datamode[i+1] \in {"A", "B"})  \* C→A,B禁止
     
     /\ \* 初期状態は必ずA
        (Len(uni_temporal_datamode) > 0 => uni_temporal_datamode[1] = "A")
     
     /\ \* 過去修正の妥当性チェック (tick=60での修正後も遷移ルールを満たす)
        (tick > 60 => 
            \A i \in 20..24:
                (i < Len(uni_temporal_datamode) => 
                    uni_temporal_datamode[i] = "A" /\ uni_temporal_datamode[i+1] \in {"A", "B"})))

vars == << tick, uni_temporal_datamode, pc >>

ProcSet == {1}

Init == (* Global variables *)
        /\ tick = 1
        /\ uni_temporal_datamode = <<>>
        /\ pc = [self \in ProcSet |-> "InitializeData"]

InitializeData == /\ pc[1] = "InitializeData"
                  /\ uni_temporal_datamode' = <<>>
                  /\ pc' = [pc EXCEPT ![1] = "UpdateUniTemporalData"]
                  /\ UNCHANGED tick

UpdateUniTemporalData == /\ pc[1] = "UpdateUniTemporalData"
                         /\ IF tick <= 72
                               THEN \* 更新条件を一旦コメントアウト
                                    \* /\ IF tick = 1
                                    \*       THEN /\ uni_temporal_datamode' = [i \in 1..72 |-> "A"]
                                    \*       ELSE /\ IF tick = 25
                                    \*                  THEN /\ uni_temporal_datamode' = [i \in 1..72 |-> IF i >= 25 THEN "B" ELSE uni_temporal_datamode[i]]
                                    \*                  ELSE /\ IF tick = 49
                                    \*                             THEN /\ uni_temporal_datamode' = [i \in 1..72 |-> IF i >= 49 THEN "C" ELSE uni_temporal_datamode[i]]
                                    \*                             ELSE /\ IF tick = 60
                                    \*                                        THEN /\ uni_temporal_datamode' = [uni_temporal_datamode EXCEPT ![25] = "A"]
                                    \*                                        ELSE /\ uni_temporal_datamode' = uni_temporal_datamode
                                    /\ uni_temporal_datamode' = uni_temporal_datamode  \* 一時的に何もしない
                                    /\ PrintT(<< tick, "SKIP" >>)
                                    /\ tick' = tick + 1
                                    /\ pc' = [pc EXCEPT ![1] = "UpdateUniTemporalData"]
                               ELSE /\ pc' = [pc EXCEPT ![1] = "Done"]
                                    /\ UNCHANGED << tick, uni_temporal_datamode >>

DiscreteTimeProcess == InitializeData \/ UpdateUniTemporalData

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
\* Last modified Sun Jul 27 21:35:00 JST 2025 by yumuuu
\* Created Sun Jul 27 21:35:00 JST 2025 by yumuuu
