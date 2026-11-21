import Signals.SatoGrassmannian.Base
import Signals.SatoGrassmannian.RieszSchauder
import Signals.SatoGrassmannian.CircleL2
import Signals.SatoGrassmannian.Gr24Truncation
import Signals.SatoGrassmannian.KPFlow
import Signals.SatoGrassmannian.HirotaKP
import Signals.SatoGrassmannian.KP2Nonlinear
import Signals.SatoGrassmannian.PDESolver
import Signals.SatoGrassmannian.LaxPair
import Signals.SatoGrassmannian.AKNS
import Signals.SatoGrassmannian.DualSchubertQFIM
import Signals.SatoGrassmannian.RHGaps
import Signals.SatoGrassmannian.RemainingGaps
import Signals.SatoGrassmannian.CarlemanWeierstrass
import Signals.SatoGrassmannian.SchwingerCocycle
import Signals.SatoGrassmannian.DeterminantBundle
import Signals.SatoGrassmannian.BigCellCocycle
import Signals.SatoGrassmannian.SegalWilsonGr24
import Signals.SatoGrassmannian.WeilPositivity
import Signals.SatoGrassmannian.WeilGaussianL1
import Signals.SatoGrassmannian.RiemannSpectralBridge

/-!
# Infinite-Dimensional Sato Grassmannian, Integrable PDEs, and Adelic RH Gaps

Umbrella module importing the complete 21-module `Signals.SatoGrassmannian` stack:
- **Core Hilbert-space Grassmannian**: `Base`, `RieszSchauder`, `CircleL2`, `Gr24Truncation`,
  `KPFlow`, `HirotaKP`, `KP2Nonlinear`.
- **Integrable PDE Solver, Lax Pair, AKNS, & Dual-Schubert QFIM**: `PDESolver`, `LaxPair`,
  `AKNS`, `DualSchubertQFIM`.
- **Adelic Carleman–Weierstrass, Schwinger Cocycle, Determinant Bundle, Segal–Wilson $\tau$,
  Weil `L¹` Positivity, & RH Gaps**: `RHGaps`, `RemainingGaps`,
  `CarlemanWeierstrass`, `SchwingerCocycle`, `DeterminantBundle`, `BigCellCocycle`,
  `SegalWilsonGr24`, `WeilPositivity`, `WeilGaussianL1`.
- **Bridge to `Signals.RiemannSpectral`**: `RiemannSpectralBridge`.
-/
