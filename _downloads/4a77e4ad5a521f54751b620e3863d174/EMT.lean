import Architect
import Mathlib.Tactic
namespace Signals

/-! Shared effective-medium and loss-regularized ENZ definitions. -/

/-- Loss-regularized Drude ENZ longitudinal intensity enhancement factor
$\Gamma_{\mathrm{ENZ,reg}}(\varepsilon_{\mathrm{air}}, \varepsilon_r, \varepsilon_i) = \frac{\varepsilon_{\mathrm{air}}^2}{\varepsilon_r^2 + \varepsilon_i^2}$
for a physical passive ENZ thin film with complex relative permittivity
$\varepsilon_{\mathrm{ENZ}} = \varepsilon_r + i\varepsilon_i$ ($\varepsilon_i > 0$),
preventing unphysical infinite-field singularities at the real ENZ crossover $\varepsilon_r = 0$. -/
@[blueprint "def:signals-ddf-regularized-enz-enhancement"
  (title := "Loss-regularized complex Drude ENZ longitudinal intensity enhancement factor")
  (statement := /-- Define $\operatorname{regularizedEnzEnhancement}(\varepsilon_{\mathrm{air}}, \varepsilon_r, \varepsilon_i)
    = \varepsilon_{\mathrm{air}}^2 / (\varepsilon_r^2 + \varepsilon_i^2)$. -/)]
noncomputable def regularizedEnzEnhancement (epsAir epsReal epsImag : ℝ) : ℝ :=
  epsAir ^ 2 / (epsReal ^ 2 + epsImag ^ 2)

/-- Effective Medium Theory (EMT) in-plane permittivity
$\varepsilon_\parallel(f, \varepsilon_m, \varepsilon_d) = f\,\varepsilon_m + (1 - f)\,\varepsilon_d$
for a sub-wavelength nanolaminate stack (`IQ-Sampling-for-Signal-Phase.md`, lines 15754 & 15779). -/
@[blueprint "def:signals-ddf-emt-epsilon-parallel"
  (title := "Effective Medium Theory in-plane permittivity ε_∥(f) = f ε_m + (1 - f) ε_d")
  (statement := /-- Define $\operatorname{emtEpsilonParallel}(f, \varepsilon_m, \varepsilon_d)
    = f\,\varepsilon_m + (1 - f)\,\varepsilon_d$. -/)]
def emtEpsilonParallel (f epsM epsD : ℝ) : ℝ :=
  f * epsM + (1 - f) * epsD

/-- Effective Medium Theory (EMT) out-of-plane permittivity
$\varepsilon_\perp(f, \varepsilon_m, \varepsilon_d) = \frac{\varepsilon_m\,\varepsilon_d}{(1 - f)\,\varepsilon_m + f\,\varepsilon_d}$
for a sub-wavelength nanolaminate stack (`IQ-Sampling-for-Signal-Phase.md`, lines 15754 & 15781). -/
@[blueprint "def:signals-ddf-emt-epsilon-perp"
  (title := "Effective Medium Theory out-of-plane permittivity ε_⊥(f)")
  (statement := /-- Define $\operatorname{emtEpsilonPerp}(f, \varepsilon_m, \varepsilon_d)
    = (\varepsilon_m\,\varepsilon_d) / ((1 - f)\,\varepsilon_m + f\,\varepsilon_d)$. -/)]
noncomputable def emtEpsilonPerp (f epsM epsD : ℝ) : ℝ :=
  (epsM * epsD) / ((1 - f) * epsM + f * epsD)

/-- Critical volume fill fraction
$f_{\mathrm{ENZ}}(\varepsilon_d, |\varepsilon_m|) = \frac{\varepsilon_d}{\varepsilon_d + |\varepsilon_m|}$
at which the in-plane permittivity $\varepsilon_\parallel(f_{\mathrm{ENZ}}, -|\varepsilon_m|, \varepsilon_d)$
crosses zero (`IQ-Sampling-for-Signal-Phase.md`, line 15787). -/
@[blueprint "def:signals-ddf-emt-critical-enz-fill-fraction"
  (title := "Critical ENZ volume fill fraction f_ENZ = ε_d / (ε_d + |ε_m|)")
  (statement := /-- Define $\operatorname{emtCriticalEnzFillFraction}(\varepsilon_d, |\varepsilon_m|)
    = \varepsilon_d / (\varepsilon_d + |\varepsilon_m|)$. -/)]
noncomputable def emtCriticalEnzFillFraction (epsD absEpsM : ℝ) : ℝ :=
  epsD / (epsD + absEpsM)

/-- Out-of-plane resonance pole fill fraction
$f_{\perp,\mathrm{pole}}(\varepsilon_d, |\varepsilon_m|) = \frac{|\varepsilon_m|}{\varepsilon_d + |\varepsilon_m|} = 1 - f_{\mathrm{ENZ}}$
separating the Type-II Hyperbolic window ($f_{\mathrm{ENZ}} < f < f_{\perp,\mathrm{pole}}$)
from the high-fill regime (`IQ-Sampling-for-Signal-Phase.md`, lines 15787–15789). -/
@[blueprint "def:signals-ddf-emt-perp-pole-fill-fraction"
  (title := "Out-of-plane pole fill fraction f_⊥,pole = |ε_m| / (ε_d + |ε_m|)")
  (statement := /-- Define $\operatorname{emtPerpendicularPoleFillFraction}(\varepsilon_d, |\varepsilon_m|)
    = |\varepsilon_m| / (\varepsilon_d + |\varepsilon_m|)$. -/)]
noncomputable def emtPerpendicularPoleFillFraction (epsD absEpsM : ℝ) : ℝ :=
  absEpsM / (epsD + absEpsM)


end Signals
