import Mathlib.Data.Nat.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace Signals.Pending

/-! # Distributed consensus and benchmark evidence

The Protocol Z.8 repository presents a ten-qubit star/GHZ circuit, reports a
98.85% logical-fidelity badge, and lists five claimed heartbeat runs averaging
92.42%. These are self-reported repository evidence. The records separate the
classical majority rule and shot-derived bookkeeping from that claim and do
not treat the repository prose as independent benchmark verification.
-/

/-- A finite majority decision for a measured bitstring.

A tie is represented by `none`; no tie-breaking convention is silently added. -/
def majorityDecision (nodeCount hammingWeight : ℕ) : Option Bool :=
  if 2 * hammingWeight < nodeCount then
    some false
  else if nodeCount < 2 * hammingWeight then
    some true
  else
    none

/-- A strict majority of zeroes yields logical zero. -/
lemma majorityDecision_zero
    {nodeCount hammingWeight : ℕ}
    (zero_majority : 2 * hammingWeight < nodeCount) :
    majorityDecision nodeCount hammingWeight = some false := by
  simp [majorityDecision, zero_majority]

/-- A strict majority of ones yields logical one. -/
lemma majorityDecision_one
    {nodeCount hammingWeight : ℕ}
    (one_majority : nodeCount < 2 * hammingWeight) :
    majorityDecision nodeCount hammingWeight = some true := by
  simp [majorityDecision, one_majority, Nat.not_lt_of_ge (Nat.le_of_lt one_majority)]

/-- A ten-node majority has the Protocol Z.8 threshold at five votes. -/
lemma majorityDecision_ten_zero
    (hammingWeight : ℕ) (below_threshold : hammingWeight < 5) :
    majorityDecision 10 hammingWeight = some false := by
  apply majorityDecision_zero
  omega

/-- A ten-node majority has the Protocol Z.8 threshold at five votes. -/
lemma majorityDecision_ten_one
    (hammingWeight : ℕ) (above_threshold : 5 < hammingWeight) :
    majorityDecision 10 hammingWeight = some true := by
  apply majorityDecision_one
  omega

/-- A finite star council with one anchor and explicitly counted spokes. -/
structure StarConsensusCouncil where
  nodeCount : ℕ
  nodeCount_at_least_two : 2 ≤ nodeCount
  anchorCount : ℕ
  anchorCountLaw : anchorCount = 1
  spokeCount : ℕ
  spokeCountLaw : spokeCount + anchorCount = nodeCount
  globalEntanglingRounds : ℕ
  globalEntanglingRounds_positive : 0 < globalEntanglingRounds
  postProcessingMajority : Bool

/-- The star council exposes its one-anchor topology. -/
lemma StarConsensusCouncil.one_anchor
    (council : StarConsensusCouncil) :
    council.anchorCount = 1 :=
  council.anchorCountLaw

/-- The star council exposes its node-count decomposition. -/
lemma StarConsensusCouncil.node_count_holds
    (council : StarConsensusCouncil) :
    council.spokeCount + council.anchorCount = council.nodeCount :=
  council.spokeCountLaw

/-- A shot-derived logical-fidelity observation.

`logicalSuccesses` counts accepted logical outcomes after the declared
post-processing rule. It is not a physical proof of fault tolerance. -/
structure ConsensusObservation where
  shots : ℕ
  shots_positive : 0 < shots
  logicalSuccesses : ℕ
  logicalSuccesses_le_shots : logicalSuccesses ≤ shots
  logicalFidelity : ℝ
  logicalFidelity_nonnegative : 0 ≤ logicalFidelity
  logicalFidelity_le_one : logicalFidelity ≤ 1
  logicalFidelityLaw : logicalFidelity =
    (logicalSuccesses : ℝ) / (shots : ℝ)

/-- The shot-derived logical fidelity is bounded by one. -/
lemma ConsensusObservation.fidelity_le_one
    (observation : ConsensusObservation) :
    observation.logicalFidelity ≤ 1 :=
  observation.logicalFidelity_le_one

/-- The shot-derived logical fidelity is nonnegative. -/
lemma ConsensusObservation.fidelity_nonnegative
    (observation : ConsensusObservation) :
    0 ≤ observation.logicalFidelity :=
  observation.logicalFidelity_nonnegative

/-- A finite measurement report with a majority-decoded logical bit. -/
structure MajorityDecodedObservation where
  council : StarConsensusCouncil
  measuredHammingWeight : ℕ
  hammingWeight_le_nodeCount :
    measuredHammingWeight ≤ council.nodeCount
  decodedBit : Option Bool
  decodedBitLaw : decodedBit =
    majorityDecision council.nodeCount measuredHammingWeight
  fidelity : ConsensusObservation

/-- The decoded bit is exactly the supplied majority decision. -/
lemma MajorityDecodedObservation.decoded_bit_holds
    (observation : MajorityDecodedObservation) :
    observation.decodedBit =
      majorityDecision observation.council.nodeCount
        observation.measuredHammingWeight :=
  observation.decodedBitLaw

/-- One self-reported logical-fidelity run from the Protocol Z.8 heartbeat
experiment. -/
structure HeartbeatRun where
  runId : ℕ
  logicalFidelity : ℝ
  logicalFidelity_nonnegative : 0 ≤ logicalFidelity
  logicalFidelity_le_one : logicalFidelity ≤ 1
  passed : Bool

/-- The five-run heartbeat table reported by the Protocol Z.8 repository.

The average is arithmetic bookkeeping over the five supplied percentages. It
does not verify the hardware jobs or the reported decoder. -/
structure HeartbeatExperiment where
  backend : String
  date : String
  run1 : HeartbeatRun
  run1_id_law : run1.runId = 1
  run2 : HeartbeatRun
  run2_id_law : run2.runId = 2
  run3 : HeartbeatRun
  run3_id_law : run3.runId = 3
  run4 : HeartbeatRun
  run4_id_law : run4.runId = 4
  run5 : HeartbeatRun
  run5_id_law : run5.runId = 5
  averageFidelity : ℝ
  averageFidelity_nonnegative : 0 ≤ averageFidelity
  averageFidelity_le_one : averageFidelity ≤ 1
  averageFidelityLaw : averageFidelity =
    (run1.logicalFidelity + run2.logicalFidelity + run3.logicalFidelity +
      run4.logicalFidelity + run5.logicalFidelity) / 5
  reportedAverageFidelity : ℝ
  reportedAverageFidelity_nonnegative : 0 ≤ reportedAverageFidelity
  reportedAverageFidelity_le_one : reportedAverageFidelity ≤ 1
  reportedAverageFidelityLaw : reportedAverageFidelity = 0.9242

/-- The heartbeat record exposes its five-run arithmetic average. -/
lemma HeartbeatExperiment.average_fidelity_holds
    (experiment : HeartbeatExperiment) :
    experiment.averageFidelity =
      (experiment.run1.logicalFidelity + experiment.run2.logicalFidelity +
        experiment.run3.logicalFidelity + experiment.run4.logicalFidelity +
        experiment.run5.logicalFidelity) / 5 :=
  experiment.averageFidelityLaw

/-- The heartbeat record exposes the rounded average printed by the source. -/
lemma HeartbeatExperiment.reported_average_fidelity_holds
    (experiment : HeartbeatExperiment) :
    experiment.reportedAverageFidelity = 0.9242 :=
  experiment.reportedAverageFidelityLaw

/-- Evidence status for a reported consensus benchmark. -/
inductive ConsensusEvidenceStatus
  | modelOnly
  | simulation
  | reportedHardware
  | independentlyReproduced
  deriving DecidableEq, Repr

/-- A reported Protocol Z.8 benchmark kept separate from shot-derived evidence.

The source claim is stored as provenance-bearing data. `completeRawCounts` and
`reproduction` make the missing evidence boundary visible instead of allowing
the claimed percentage to act as a theorem. -/
structure ProtocolZ8ReportedBenchmark where
  backend : String
  heartbeat : HeartbeatExperiment
  jobIdentifier : String
  totalShots : ℕ
  totalShots_positive : 0 < totalShots
  majorityThreshold : ℕ
  majorityThreshold_positive : 0 < majorityThreshold
  consensusZeroCount : ℕ
  consensusOneCount : ℕ
  correctedCount : ℕ
  listedRawCountCoverage : ℕ
  listedRawCountCoverageLaw : listedRawCountCoverage =
    consensusZeroCount + consensusOneCount + correctedCount
  listedRawCountCoverage_le_total : listedRawCountCoverage ≤ totalShots
  reportedPhysicalFidelity : ℝ
  reportedPhysicalFidelity_nonnegative : 0 ≤ reportedPhysicalFidelity
  reportedPhysicalFidelity_le_one : reportedPhysicalFidelity ≤ 1
  reportedLogicalFidelity : ℝ
  reportedLogicalFidelityLaw : reportedLogicalFidelity = 0.9885
  reportedLogicalFidelity_nonnegative : 0 ≤ reportedLogicalFidelity
  reportedLogicalFidelity_le_one : reportedLogicalFidelity ≤ 1
  reportedCorrectionRate : ℝ
  reportedCorrectionRate_nonnegative : 0 ≤ reportedCorrectionRate
  reportedCorrectionRate_le_one : reportedCorrectionRate ≤ 1
  evidenceStatus : ConsensusEvidenceStatus
  completeRawCounts : Bool
  reproduction : Bool
  sourceRepository : String

/-- The Protocol Z.8 report exposes its claimed percentage. -/
lemma ProtocolZ8ReportedBenchmark.reported_fidelity
    (report : ProtocolZ8ReportedBenchmark) :
    report.reportedLogicalFidelity = 0.9885 :=
  report.reportedLogicalFidelityLaw

/-- A reported benchmark is not independently verified merely because it has a
numeric fidelity field. -/
def ProtocolZ8ReportedBenchmark.independentlyVerified
    (report : ProtocolZ8ReportedBenchmark) : Prop :=
  report.evidenceStatus = ConsensusEvidenceStatus.independentlyReproduced ∧
    report.completeRawCounts = true ∧ report.reproduction = true

/-- A Protocol Z.8 report with incomplete raw counts cannot satisfy the local
independent-verification predicate. -/
lemma ProtocolZ8ReportedBenchmark.not_independentlyVerified_of_incomplete
    (report : ProtocolZ8ReportedBenchmark)
    (incomplete : report.completeRawCounts = false) :
    ¬report.independentlyVerified := by
  intro verified
  unfold ProtocolZ8ReportedBenchmark.independentlyVerified at verified
  rcases verified with ⟨_, complete, _⟩
  rw [incomplete] at complete
  cases complete

end Signals.Pending
