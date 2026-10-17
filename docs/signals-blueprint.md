# Signals Lean Blueprint

The generated blueprint covers the Signals Lean package and links formal nodes
to their Lean declarations.

The selected roadmap nodes cover finite routing and weighted measurements,
ordered minors and geometric representatives, scalar propagation and amplitude
controls, measure-derived quadrature, and affine forms with oriented residues.
Readiness markers mean that formal declarations are checked, not that physical
models or experiments are validated.

## Annotation Workflow

Keep a declaration docstring for the Lean API and supply explicit `statement`,
`title`, and, for proof milestones, `proof` metadata in `@[blueprint]`.
LeanArchitect does not copy ordinary declaration docstrings into blueprint
statements. Use stable labels; let it infer statement and proof dependencies
from the Lean terms unless a specific additional dependency is needed.

Include each annotated module using `\inputleanmodule` in the existing blueprint
chapter. Extraction alone does not add its nodes to the rendered document.
From the Signals package directory, `lake build :blueprint` extracts LaTeX,
`lake build :blueprintJson` exports metadata, and `make lean-api` generates
doc-gen API pages and the declaration finder in `.lake/build/doc`.
`make blueprint` builds that API reference, extracts the nodes, and renders the
standalone HTML blueprint with a relative `signals-api/` link to the API tree.
The documentation build copies both into its embedded blueprint output, so
declaration links work under the same URL prefix when served locally or published.

JSON preserves raw annotation configuration. Check inferred dependency links
and `leanok` readiness markers in the generated LaTeX and rendered HTML.
Importing Architect also enables tactic docstrings: align declaration docstrings
with their declarations so they are not consumed by a preceding tactic proof.

## Electricity Plants and Thrusters Blueprint (`Twistors-and-Positive-Grassmannian-Interference`)

This blueprint maps every electricity plant, cooling loop, and propulsion
architecture discussed in
{download}`Twistors-and-Positive-Grassmannian-Interference.md, lines 279-4019 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`
and formalized in
{download}`Twistors-and-Positive-Grassmannian-Interference.md.lean, lines 1-698 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md.lean>`
to its verified mathematical nodes in [MHD.lean](../src/signals/Signals/MHD.lean)
and [DDF.lean](../src/signals/Signals/DDF.lean) and its conditional boundary
contracts in [Pending.lean](../src/signals/Signals/Pending.lean) and
[SignalsPending.lean](../src/signals/SignalsPending.lean).

### Comparative Architecture Matrix

| System | Role | Medium & Drive | Chat Estimates ({download}`lines 2167-2268 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`) | Formal Blueprint Nodes & Physical Critique |
|---|---|---|---|---|
| **1. Neon Glow-Discharge Lamp** | Baseline thermal plasma consumer | Low-pressure $\text{Ne}$ gas; stochastic Townsend discharge | Cost $\$10\text{--}\$50$; $F=0\text{ N}$ isotropic ($0.33\,\mu\text{N}$ if $100\text{ W}$ collimated, $I_{sp}\approx 3.05\times 10^7\text{ s}$); $\eta_{\text{prop}}=0\%$ | Isotropic photon momentum cancels identically; $80\%$ thermal / $20\%$ radiative loss with no coherent wave amplification. |
| **2. Cathode Ray Tube (CRT)** | Ballistic electron-beam benchmark | Hard vacuum; thermionic cathode + $20\text{ kV}$ anode + magnetic steering | Cost $\$100\text{--}\$500$; $F\approx 0.47\,\mu\text{N}$ at $1\text{ mA}$ ($v_e\approx 8.4\times 10^7\text{ m/s}$, $I_{sp}\approx 8.5\times 10^6\text{ s}$); $\eta_{\text{prop}}<0.001\%$ | Governed by `def:signals-magnetic-lorentz-force` and `thm:signals-magnetic-lorentz-work-free`. Unneutralized electron exhaust charges the hull positively, pulling the beam back. |
| **3. Argon MHD Wakefield Plant & Pulsed Thruster** | Multi-GW pulsed electricity generator & Earth-to-orbit thruster | Magnetized Argon plasma ($n_e\sim 10^{18}\text{ cm}^{-3}$); Fabry-Pérot Langmuir cavity + bump-on-tail $e^-$ beam + Halbach/B-LIG extraction | Cost $\$10\text{M--}\$100\text{M}+$; $I_{sp}\approx 3.05\times 10^7\text{ s}$; continuous $\sim 2\text{ N/GW}$ vs. pulsed $F_{\text{peak}}\sim 20\text{--}3300\text{ N}$; $1\text{ TW}$ peak electrical pulse stepped to $1.2\text{ MV}$ | Verified dispersion/Landau/ponderomotive/Halbach laws in [MHD.lean](../src/signals/Signals/MHD.lean); bounded by `def:signals-pulsed-wakefield-halbach`, `lem:signals-extracted-pulse-energy-le-dawson`, and `lem:signals-pulsed-wakefield-avg-thrust-le-peak`. |
| **4. Deborah-Number Shear-Fracture (DDF) Thruster & Siphon** | Proposed propellantless vacuum thruster & vortex-annealing generator | Two-component Dilatant Dark Fluid (`DDFSubstrate`); acoustic shear above Landau critical speed $v_c=c_s$ | Cost $\$1\text{B}+$; claimed $F\sim 10^3\text{--}10^5\text{ N}$, $I_{sp}=\infty$ (propellantless) | Madelung circulation and Bogoliubov threshold in [DDF.lean](../src/signals/Signals/DDF.lean); constrained by `def:signals-ddf-phase-slip-hull-stress` and `lem:signals-ddf-zero-drive-zero-thrust` (supercritical vortex shedding is drag without external drive power $P_{\text{drive}}\ge F v$). |
| **5. $\text{D-He3}$ Aneutronic Reactor & AMB Centrifugal Spool** | Deep-space direct-conversion power plant, cryo-cooler, & attitude control | Aneutronic $\text{D-He3}$ fusion plasma + supercritical $\text{He-3}$ spool on 5-axis $\text{MgB}_2$ AMBs | Direct proton/alpha Halbach capture; $\sim 39\text{ K}$ $\text{MgB}_2$ stator coils; $H_\infty$ active damping; proposed solid-$\text{He-3}$ labyrinth seal | Centrifugal head, thermosyphon buoyancy, and gyroscopic torque in [MHD.lean](../src/signals/Signals/MHD.lean); phase limits enforced by `def:signals-cryogenic-spool-amb`, `lem:signals-he3-supercritical-at-39k`, and `lem:signals-he3-no-solid-seal-below-3-4-mpa`. |

---

### 1. Neon Glow-Discharge Lamp & 2. Cathode Ray Tube (CRT) Benchmarks

In {download}`Twistors-and-Positive-Grassmannian-Interference.md, lines 2167-2245 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`,
the neon lamp and CRT serve as classical baselines:

- **Neon Glow Discharge**: Free electrons accelerated in a low-pressure gas
  undergo stochastic inelastic collisions, emitting uncollimated photons with
  zero net momentum transfer ($\sum \mathbf p_\gamma = \mathbf 0$). Even if a
  $100\text{ W}$ source were perfectly collimated into a unidirectional photon
  rocket ($I_{sp} = c/g_0 \approx 3.05\times 10^7\text{ s}$), its radiation
  thrust would be $F = P/c \approx 0.33\,\mu\text{N}$.
- **Cathode Ray Tube (CRT)**: Operating in hard vacuum at $V = 20\text{ kV}$ and
  $I = 1\text{ mA}$ ({download}`lines 2238-2244 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`),
  ballistic electrons reach $v_e \approx 8.4\times 10^7\text{ m/s}$ with mass
  flow $\dot m = I m_e / e \approx 5.69\times 10^{-15}\text{ kg/s}$ and thrust
  $F = \dot m v_e \approx 0.47\,\mu\text{N}$. Magnetic deflection coils steer
  the beam via $\mathbf F = q(\mathbf v\times\mathbf B)$
  (`def:signals-magnetic-lorentz-force`), which performs zero mechanical work
  (`thm:signals-magnetic-lorentz-work-free`). Without a neutralizing ion current,
  expelling electrons charges the vehicle positively and stalls the beam.

---

### 3. Argon MHD Wakefield Electricity Plant & Pulsed Monolithic Thruster

#### A. Resonant Langmuir Cavity & Inverse Landau Amplification (Sections 6--7)
The plant traps longitudinal electrostatic plasma waves inside a Fabry-Pérot
cavity ($L = n\lambda/2$, {download}`lines 2046-2065 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`)
governed by the warm **Bohm-Gross dispersion relation**
({download}`lines 3590-3637 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`,
{download}`Twistors-and-Positive-Grassmannian-Interference.md.lean, lines 441-519 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md.lean>`):

$$
\omega^2(k) = \omega_p^2 + 3 k^2 v_{\mathrm{th}}^2,
\qquad
v_\phi = \frac{\omega}{k},
\qquad
v_g = \frac{\partial\omega}{\partial k} = \frac{3 k v_{\mathrm{th}}^2}{\omega}.
$$

- **Blueprint nodes**: `def:signals-bohm-gross-omega-sq`,
  `def:signals-langmuir-phase-velocity`, `def:signals-bohm-gross-group-velocity`,
  `thm:signals-bohm-gross-velocity-product` ($v_\phi v_g = 3 v_{\mathrm{th}}^2$),
  and `thm:signals-bohm-gross-phase-velocity-bound` ($3 v_{\mathrm{th}}^2 \le v_\phi^2$).
- **Bump-on-tail Inverse Landau pump**: Injecting a fast electron beam with
  positive velocity-distribution slope $\partial_v f_0|_{v=\omega/k} > 0$
  ({download}`lines 2067-2081 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`,
  {download}`lines 3640-3680 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`)
  yields linear growth rate

$$
\gamma = \frac{\pi \omega_p^3}{2 k^2 n_0}\left.\frac{\partial f_0}{\partial v}\right|_{v=\omega/k} > 0
\quad (\text{\texttt{thm:signals-inverse-landau-growth-pos}}),
$$

  whereas a thermal Maxwellian tail ($\partial_v f_0 < 0$) damps the wave
  (`thm:signals-thermal-landau-damping-neg`) and quasilinear plateau formation
  ($\partial_v f_0 = 0$) saturates growth at $\gamma = 0$
  (`lem:signals-quasilinear-plateau-saturation`). Resonant wave-particle power
  exchange is conservative:
  $\frac{dU_{\mathrm{wave}}}{dt} + \frac{dK_{\mathrm{beam}}}{dt} = 2\gamma U_{\mathrm{wave}} - 2\gamma U_{\mathrm{wave}} = 0$
  (`thm:signals-resonant-energy-conservation`).
- **Dawson Wave-Breaking Ceiling**: Coherent longitudinal oscillation saturates
  at the Dawson field $E_{\mathrm{Dawson}} = m_e \omega_p v_\phi / e$
  ({download}`lines 2083-2093 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`),
  bounding the electrostatic energy density
  $u_E(\varepsilon_0, E_z) = \frac{1}{2}\varepsilon_0 E_z^2 \le u_E(\varepsilon_0, E_{\mathrm{Dawson}})$
  (`def:signals-electrostatic-wave-energy-density`, `thm:signals-dawson-energy-density-bound`).

#### B. Halbach Transverse MHD Extraction & UHV Substation Hull (Sections 4 & 9)
To convert axial electron oscillations $v_z$ into transverse current $J_x$ for
B-LIG electrode capture ({download}`lines 2354-2378 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`,
{download}`lines 2461-2525 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`):

1. **Lorentz Deflection (`thm:signals-halbach-transverse-conversion`)**: A static
   Halbach field $\mathbf B = (0, B_y, 0)$ deflects $\mathbf v = (0, 0, v_z)$
   with magnetic force $\mathbf F = q(\mathbf v\times\mathbf B) = (-q v_z B_y, 0, 0)$.
2. **Work-Free Identity & Faraday Load Requirement (`thm:signals-magnetic-lorentz-work-free`)**:
   Because $q(\mathbf v\times\mathbf B)\cdot\mathbf v = 0$, the static magnetic
   field alone does zero work and cannot extract energy without an opposing
   transverse load electric field $E_x$ (`FaradayChannel` in [MHD.lean](../src/signals/Signals/MHD.lean#L86)),
   whose matched-load power density is bounded by $\frac{1}{4}\sigma v^2 B^2$
   (`FaradayChannel.power_density_le_quarter_base`) and whose plant efficiency
   cannot exceed unity (`MHDPowerAccounting.full_efficiency_le_one`,
   `ClosedLoopArgonMHD.exported_le_declared_input`).
3. **Dawson Cavity Energy Bound (`def:signals-pulsed-wakefield-halbach`, `lem:signals-extracted-pulse-energy-le-dawson`)**:
   The chat estimate of $100\text{ GV/m} \times 0.1\text{ m} = 10\text{ GV}$ and
   $10\text{ GV}\times 100\text{ A} = 1\text{ TW}$
   ({download}`lines 2368-2376 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`)
   extrapolates the peak field monotonically across $10\text{ cm}$ rather than
   integrating over the plasma wavelength $\lambda_p \approx 33\,\mu\text{m}$.
   In `PulsedWakefieldHalbachHypothesis`, extracted pulse energy is bounded by
   the total electrostatic energy stored in the cavity volume:
   $U_{\mathrm{extracted}} \le u_E(\varepsilon_0, E_{\mathrm{Dawson}})\,V_{\mathrm{cav}}$.
4. **Beltrami/Taylor State & Active Cooling Pinch (`thm:signals-taylor-state-force-free`, `thm:signals-active-cooling-stabilizes-pinch`, `thm:signals-discrete-four-cycle-gauge-invariance`)**:
   A collinear Beltrami current $\mathbf J = \alpha\mathbf B$ eliminates internal
   disruptive Lorentz forces ($\mathbf J\times\mathbf B = \mathbf 0$), active
   thermal extraction ($\Delta P_{\mathrm{cool}} > \Delta P_{\mathrm{ohm}}$)
   maintains a positive radial magnetic pressure margin, and discrete 4-link
   circulation is invariant under vertex gauge transformations.

#### C. Ponderomotive Thruster, Aerodynamic Hull Moments, & Bi-Twistor Sink (Sections 1--2)
When operated as an Earth-to-orbit or high-G thruster
({download}`lines 279-337 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`,
{download}`lines 2289-2341 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`,
{download}`lines 2577-2587 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`):

- **Ponderomotive Cycle Averaging (`def:signals-ponderomotive-potential`, `def:signals-ponderomotive-force`, `lem:signals-ponderomotive-down-gradient`, `lem:signals-oscillatory-lorentz-cancels`, `thm:signals-ponderomotive-cycle-average`)**:
  First-order quiver motion $\cos(\omega t)$ integrates to zero over each RF
  period $T = 2\pi/\omega$, isolating the secular drift force
  $\mathbf F_p(\mathbf x) = -\frac{e^2}{4 m_e \omega^2}\nabla(\lVert\mathbf E_0(\mathbf x)\rVert^2)$
  directed down the intensity gradient.
- **Pulsed Duty-Cycle Scaling (`def:signals-pulsed-average-force`, `lem:signals-pulsed-average-force-le-peak`, `lem:signals-pulsed-wakefield-avg-thrust-le-peak`)**:
  Dumping hull supercapacitors in nanosecond pulses raises instantaneous peak
  force $F_{\mathrm{peak}}$, but time-averaged thrust remains bounded by duty
  cycle $d\in[0,1]$: $F_{\mathrm{avg}} = d\,F_{\mathrm{peak}} \le F_{\mathrm{peak}}$.
- **Classical Aerodynamic Hull Torque (`def:signals-bernoulli-dynamic-pressure`, `def:signals-differential-aerodynamic-moment`, `def:signals-total-aerodynamic-moment`, `lem:signals-aerodynamic-moment-orthogonal-lever`, `lem:signals-aerodynamic-moment-orthogonal-force`)**:
  Integrating Bernoulli dynamic pressure $q(\mathbf x) = \frac{1}{2}\rho\lVert\mathbf V_{\mathrm{wake}}(\mathbf x)\rVert^2$
  with respect to an explicit 2D surface-area measure $\mu$ (fixing the chat's
  3D Lebesgue `volume` measure bug) yields differential moments orthogonal to
  both the lever arm $\mathbf x - \mathbf x_{\mathrm{CM}}$ and normal force.
- **Bi-Twistor Momentum Sink (`def:signals-twistor-momentum-sink`, `lem:signals-craft-momentum-opposite-wake`, `lem:signals-closed-polygon-zero-thrust`)**:
  In dual spacetime ({download}`lines 437-449 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`),
  momentum leaked to the wakefield leaves an unclosed polygon residual
  $\Delta\mathbf P_{\mathrm{wake}} = \mathbf x_n - \mathbf x_1$ represented by a
  bi-twistor sink in $Gr_{\ge 0}(k, n+2)$, enforcing exact Newton-pair
  conservation $\Delta\mathbf P_{\mathrm{craft}} = -\Delta\mathbf P_{\mathrm{wake}}$.

---

### 4. Deborah-Number Shear-Fracture / Dilatant Dark Fluid (DDF) Thruster (Sections 3 & 8)

In {download}`Twistors-and-Positive-Grassmannian-Interference.md, lines 1268-1346 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`
and {download}`lines 1546-1618 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`,
the alternative vacuum thruster replaces plasma ions with Marco Fedi's
Dilatant Dark Fluid (`DDFSubstrate` in [DDF.lean](../src/signals/Signals/DDF.lean)):

- **Madelung Hydrodynamics & Quantized Circulation (`def:signals-madelung-density`, `def:signals-bohm-quantum-potential`, `def:signals-superfluid-velocity`, `thm:signals-quantized-vortex-circulation`, `thm:signals-ddf-substrate-circulation-eq`)**:
  Writing $\psi = \sqrt{\rho}e^{iS}$ gives $\mathbf v = (\hbar/m)\nabla S$ and
  Bohm potential $Q = -\frac{\hbar^2}{2m}\frac{\Delta\sqrt{\rho}}{\sqrt{\rho}}$.
  Around a vortex of integer winding $n\in\mathbb Z$ at radius $R\ne 0$,
  $\int_0^{2\pi} v_\theta R\,d\theta = n(2\pi\hbar/m)$.
- **Discrete Plaquette Cohomology (`thm:signals-plaquette-coboundary-zero`, `thm:signals-plaquette-phase-slip-syndrome`)**:
  On a 2D lattice plaquette, single-valued site phases have zero coboundary
  ($\delta^1\circ\delta^0 = 0$), while a $2\pi n$ branch cut extracts the exact
  topological charge $2\pi n$.
- **Bogoliubov Spectrum & Landau Critical Velocity (`def:signals-bogoliubov-phase-vel-sq`, `thm:signals-bogoliubov-landau-bound`, `thm:signals-subcritical-no-dissipation`, `thm:signals-supercritical-excitation-onset`)**:
  Since $(\epsilon(p)/p)^2 = c_s^2 + (p/(2m))^2 \ge c_s^2$, the Landau critical
  velocity is $v_c = c_s$. For $v < v_c$, $\Delta E = \epsilon(p) - p v > 0$
  (frictionless flow); for $v > v_c$, acoustic modes at $\epsilon(p) = v_c p$
  have $\Delta E < 0$, nucleating vortices.
- **Pending Hull-Stress & Power-Accounting Boundary (`def:signals-ddf-phase-slip-hull-stress`, `lem:signals-ddf-hull-boundary-density-pos`, `lem:signals-ddf-zero-drive-zero-thrust`)**:
  Supercritical vortex shedding in a superfluid is a **dissipative drag mechanism**,
  and $Q$ diverges at $\rho = 0$ unless regularized by a positive density floor
  $0 < \rho_{\mathrm{floor}} \le \rho_{\mathrm{hull}}$. `DDFPhaseSlipHullStressHypothesis`
  requires $F_{\mathrm{thrust}} v \le P_{\mathrm{drive}}$, proving that zero
  external drive power ($P_{\mathrm{drive}} = 0$) yields zero net forward thrust.

---

### 5. $\text{D-He3}$ Aneutronic Deep-Space Reactor & AMB Centrifugal Cooling Spool (Section 5)

In {download}`Twistors-and-Positive-Grassmannian-Interference.md, lines 2577-2798 <../data/chats/Twistors-and-Positive-Grassmannian-Interference.md>`,
deep-space transit pairs aneutronic $\text{D-He3}$ direct conversion with a
levitated centrifugal cooling spool:

- **Radial Centrifugal Head & Closed-Loop Thermosyphon (`def:signals-centrifugal-pressure-gradient`, `thm:signals-centrifugal-pump-head`, `thm:signals-centrifugal-thermosyphon-head`, `lem:signals-centrifugal-isothermal-zero`)**:
  Integrating $\frac{dP}{dr} = \rho\omega^2 r$ over $[r_{\mathrm{in}}, r_{\mathrm{out}}]$
  gives $\Delta P = \frac{1}{2}\rho\omega^2(r_{\mathrm{out}}^2 - r_{\mathrm{in}}^2)$.
  In a closed loop, outward and inward radial legs cancel identically unless
  cooled/heated density differences drive a thermosyphon head
  $\Delta P_{\mathrm{loop}} = \frac{1}{2}(\rho_{\mathrm{cold}} - \rho_{\mathrm{hot}})\omega^2(r_{\mathrm{out}}^2 - r_{\mathrm{in}}^2)$
  (`centrifugal_thermosyphon_net_head`).
- **Gyroscopic Attitude Control (`def:signals-spool-angular-momentum`, `def:signals-gyroscopic-torque`, `thm:signals-pitch-induces-yaw-torque`, `lem:signals-gyroscopic-torque-orthogonal-precession`, `lem:signals-gyroscopic-torque-orthogonal-momentum`)**:
  Precessing the $z$-axis spool ($\mathbf L = (0, 0, I_{\mathrm{spool}}\omega_z)$)
  around the $x$-axis ($\boldsymbol\Omega = (\Omega_x, 0, 0)$) produces the
  orthogonal $y$-axis yaw torque $(0, -\Omega_x I_{\mathrm{spool}}\omega_z, 0)$.
- **5-Axis $\text{MgB}_2$ AMB & $\text{He-3}$ Phase Diagram Critique (`def:signals-cryogenic-spool-amb`, `lem:signals-he3-supercritical-at-39k`, `lem:signals-he3-no-solid-seal-below-3-4-mpa`)**:
  Because $\text{He-3}$ has critical temperature $T_c = 3.32\text{ K}$ and
  minimum solidification pressure $P_{\mathrm{solid}} = 3.4\text{ MPa}$,
  operating at the $\text{MgB}_2$ temperature of $39\text{ K}$ places $\text{He-3}$
  in the supercritical gas regime (`supercritical_at_39K`), and eddy currents
  cannot freeze electrically insulating $\text{He-3}$ into a solid labyrinth
  seal below $3.4\text{ MPa}$ (`no_solid_seal_below_3_4_MPa`).

```{raw} html
<p><a href="signals-blueprint/index.html">Open the standalone blueprint</a></p>
<p><a href="signals-blueprint/signals-api/index.html">Open the Lean API reference</a></p>
<iframe
  src="signals-blueprint/index.html"
  title="Signals Lean Blueprint"
  width="100%"
  height="800"
  loading="lazy"></iframe>
```