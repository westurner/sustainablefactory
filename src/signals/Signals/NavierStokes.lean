import Signals.NavierStokes.PluckerFrame
import Signals.NavierStokes.Incompressible
import Signals.NavierStokes.Compressible

/-!
# Compressible & Incompressible Navier–Stokes via Dual-Schubert QFIM (`F_μν = 4 g_FS_μν`)

Umbrella module importing the three-module `Signals.NavierStokes` formalization:
- `PluckerFrame`: 4×2 1-jet Stiefel frame, Klein quadric `1/p₀₁²` cancellation, smooth
  Schubert chart transition `Ω₀ ↔ Ω₀₂` across `Σ₁ = {p₀₁ = 0}`, 2-component Clebsch spinor
  continuous vorticity (`ω_z ≠ 0`), and formal audit of Chat Defect #2 (Hermitian off-diagonal
  `± i ℏ ν ∇²` vs. corrected Bateman doubled viscous operator).
- `Incompressible`: Channel-2 annihilation (`dρ = 0`), Dual-Schubert energy–enstrophy split,
  and full `deriv`/`iteratedDeriv 2` PDE proofs for 2D Taylor–Green decaying vortex,
  2D Lamb–Oseen viscous vortex, plane Poiseuille shear flow, and 3D decaying Beltrami/ABC flow.
- `Compressible`: 3D compressible viscous stress & dissipation positivity (`Φ_visc ≥ 0`),
  exact Korteweg capillary stress divergence (`-(ρ/m) ∂_x Q = ∂_x K_{xx}`), Bresch–Desjardins
  Dual-Schubert QFIM velocity split (`v_± = v ± ν ρ_x / ρ`), Cole–Hopf & moving viscous
  Burgers tanh shock PDE, and linearized compressible Stokes acoustic dispersion.
-/
