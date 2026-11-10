import DocGen4
import Lean

open DocGen4 DocGen4.DB DocGen4.Process Lean

private def parseEntries : List String → Except String (Array (Name × String))
  | [] => .ok #[]
  | moduleName :: sourceUri :: rest =>
    (parseEntries rest).map (fun entries => entries.push (moduleName.toName, sourceUri))
  | [_] => .error "expected a source URL for every module"

def main (args : List String) : IO UInt32 := do
  match args with
  | buildDir :: dbFile :: rawEntries =>
    let entries ← match parseEntries rawEntries with
      | .ok entries => pure entries
      | .error message => throw <| IO.userError message
    if entries.isEmpty then
      throw <| IO.userError "expected at least one module and source URL"

    let modules := entries.map Prod.fst
    let analysis ← load (.analyzeConcreteModules modules)
    for (moduleName, sourceUri) in entries do
      let some moduleInfo := analysis.moduleInfo[moduleName]? | unreachable!
      let moduleAnalysis : AnalyzerResult := {
        analysis with
        moduleInfo := ({} : Std.HashMap Name DocGen4.Process.Module).insert moduleName moduleInfo
      }
      updateModuleDb builtinDocstringValues moduleAnalysis buildDir dbFile (some sourceUri)
    return 0
  | _ =>
    throw <| IO.userError "usage: signalsApiDocs BUILD_DIR DB_FILE MODULE SOURCE_URL [...]"
