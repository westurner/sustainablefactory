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
`lake build :blueprintJson` exports metadata, and `make blueprint` extracts and
renders the standalone HTML blueprint. The documentation build embeds that HTML.

JSON preserves raw annotation configuration. Check inferred dependency links
and `leanok` readiness markers in the generated LaTeX and rendered HTML.
Importing Architect also enables tactic docstrings: align declaration docstrings
with their declarations so they are not consumed by a preceding tactic proof.

```{raw} html
<p><a href="signals-blueprint/index.html">Open the standalone blueprint</a></p>
<iframe
  src="signals-blueprint/index.html"
  title="Signals Lean Blueprint"
  width="100%"
  height="800"
  loading="lazy"></iframe>
```