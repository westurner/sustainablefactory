/* @ts-self-types="./oxirs_wasm.d.ts" */
import * as wasm from "./oxirs_wasm_bg.wasm";
import { __wbg_set_wasm } from "./oxirs_wasm_bg.js";

__wbg_set_wasm(wasm);
wasm.__wbindgen_start();
export {
    OxiRSStore, QueryResult, Triple, WasmSparqlStore, init, log, version
} from "./oxirs_wasm_bg.js";
