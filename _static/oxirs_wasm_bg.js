/**
 * OxiRS in-memory RDF store exposed to JavaScript via wasm_bindgen
 */
export class OxiRSStore {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        OxiRSStoreFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_oxirsstore_free(ptr, 0);
    }
    /**
     * Register a namespace prefix
     * @param {string} prefix
     * @param {string} uri
     */
    addPrefix(prefix, uri) {
        const ptr0 = passStringToWasm0(prefix, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(uri, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len1 = WASM_VECTOR_LEN;
        wasm.oxirsstore_addPrefix(this.__wbg_ptr, ptr0, len0, ptr1, len1);
    }
    /**
     * Execute a SPARQL ASK query
     * @param {string} sparql
     * @returns {boolean}
     */
    ask(sparql) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(sparql, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.oxirsstore_ask(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return r0 !== 0;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Clear all triples
     */
    clear() {
        wasm.oxirsstore_clear(this.__wbg_ptr);
    }
    /**
     * Remove the solution budget set by [`OxiRSStore::set_solution_budget`].
     */
    clearSolutionBudget() {
        wasm.oxirsstore_clearSolutionBudget(this.__wbg_ptr);
    }
    /**
     * Remove the triple-count ceiling set by [`OxiRSStore::set_triple_limit`].
     */
    clearTripleLimit() {
        wasm.oxirsstore_clearTripleLimit(this.__wbg_ptr);
    }
    /**
     * Execute a SPARQL CONSTRUCT query
     * @param {string} sparql
     * @returns {Triple[]}
     */
    construct(sparql) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(sparql, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.oxirsstore_construct(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            var r3 = getDataViewMemory0().getInt32(retptr + 4 * 3, true);
            if (r3) {
                throw takeObject(r2);
            }
            var v2 = getArrayJsValueFromWasm0(r0, r1).slice();
            wasm.__wbindgen_export(r0, r1 * 4, 4);
            return v2;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Check if a triple exists
     * @param {string} subject
     * @param {string} predicate
     * @param {string} object
     * @returns {boolean}
     */
    contains(subject, predicate, object) {
        const ptr0 = passStringToWasm0(subject, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(object, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.oxirsstore_contains(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2);
        return ret !== 0;
    }
    /**
     * Delete a single triple, returning true if it was found.
     *
     * Rebuilds the subject/predicate/object indexes so that [`OxiRSStore::subjects`],
     * [`OxiRSStore::predicates`] and [`OxiRSStore::objects`] never report a term whose
     * last triple was just deleted, and so `triple_list`/the indexes do not grow
     * unboundedly across long insert/delete churn.
     * @param {string} subject
     * @param {string} predicate
     * @param {string} object
     * @returns {boolean}
     */
    delete(subject, predicate, object) {
        const ptr0 = passStringToWasm0(subject, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(object, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.oxirsstore_delete(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2);
        return ret !== 0;
    }
    /**
     * Apply RDFS forward-chaining entailment rules and materialise inferred triples.
     *
     * Returns a JS object `{ added: number }` describing how many new triples
     * were derived.  Calling this multiple times is idempotent — subsequent
     * calls return 0 once the fixed-point has been reached.
     *
     * Rules implemented: rdfs:subClassOf transitivity (rdfs11), rdf:type
     * propagation via rdfs:subClassOf (rdfs9), rdfs:subPropertyOf transitivity
     * (rdfs5), rdfs:subPropertyOf usage propagation (rdfs7), rdfs:domain
     * subject-typing (rdfs2), rdfs:range object-typing (rdfs3).
     * @returns {any}
     */
    inferRdfs() {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.oxirsstore_inferRdfs(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return takeObject(r0);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Insert a single triple
     * @param {string} subject
     * @param {string} predicate
     * @param {string} object
     * @returns {boolean}
     */
    insert(subject, predicate, object) {
        const ptr0 = passStringToWasm0(subject, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(object, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.oxirsstore_insert(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2);
        return ret !== 0;
    }
    /**
     * Load N-Triples data
     * @param {string} ntriples
     * @returns {number}
     */
    loadNTriples(ntriples) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(ntriples, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.oxirsstore_loadNTriples(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return r0 >>> 0;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Load Turtle data
     * @param {string} turtle
     * @returns {number}
     */
    loadTurtle(turtle) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(turtle, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.oxirsstore_loadTurtle(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return r0 >>> 0;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Create a new empty store
     */
    constructor() {
        const ret = wasm.oxirsstore_new();
        this.__wbg_ptr = ret;
        OxiRSStoreFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * Get all objects
     * @returns {string[]}
     */
    objects() {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.oxirsstore_objects(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var v1 = getArrayJsValueFromWasm0(r0, r1).slice();
            wasm.__wbindgen_export(r0, r1 * 4, 4);
            return v1;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Get all predicates
     * @returns {string[]}
     */
    predicates() {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.oxirsstore_predicates(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var v1 = getArrayJsValueFromWasm0(r0, r1).slice();
            wasm.__wbindgen_export(r0, r1 * 4, 4);
            return v1;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Execute a SPARQL SELECT query
     * @param {string} sparql
     * @returns {any}
     */
    query(sparql) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(sparql, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.oxirsstore_query(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return takeObject(r0);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Cap the number of intermediate solutions a single query may produce.
     *
     * A join is evaluated left to right, so an unselective pattern early in a
     * WHERE clause can build a huge intermediate result before a later pattern
     * cuts it back down — the join is what costs, not the rows returned, and a
     * LIMIT cannot bound it because it applies at the end. A caller that
     * answers queries under a time or CPU budget (an endpoint on a serverless
     * platform, say) sets this so that such a query fails fast with a query
     * error instead of running to completion.
     *
     * Unset by default: queries are unbounded.
     * @param {number} budget
     */
    setSolutionBudget(budget) {
        wasm.oxirsstore_setSolutionBudget(this.__wbg_ptr, budget);
    }
    /**
     * Cap the total number of triples this store may hold.
     *
     * `load_turtle`/`load_ntriples` check this budget as they insert, and
     * fail with an explicit, catchable error the moment a document would
     * push the store past the cap — rather than growing without bound until
     * the WASM heap itself is exhausted (which surfaces to JS as an
     * uncatchable trap, not a clean `Err`).
     *
     * Unset by default: the store is unbounded.
     * @param {number} limit
     */
    setTripleLimit(limit) {
        wasm.oxirsstore_setTripleLimit(this.__wbg_ptr, limit);
    }
    /**
     * Get the number of triples
     * @returns {number}
     */
    size() {
        const ret = wasm.oxirsstore_size(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * Get all subjects
     * @returns {string[]}
     */
    subjects() {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.oxirsstore_subjects(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var v1 = getArrayJsValueFromWasm0(r0, r1).slice();
            wasm.__wbindgen_export(r0, r1 * 4, 4);
            return v1;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Export to N-Triples format
     * @returns {string}
     */
    toNTriples() {
        let deferred1_0;
        let deferred1_1;
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.oxirsstore_toNTriples(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            deferred1_0 = r0;
            deferred1_1 = r1;
            return getStringFromWasm0(r0, r1);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
            wasm.__wbindgen_export(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * Export to Turtle format
     * @returns {string}
     */
    toTurtle() {
        let deferred1_0;
        let deferred1_1;
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.oxirsstore_toTurtle(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            deferred1_0 = r0;
            deferred1_1 = r1;
            return getStringFromWasm0(r0, r1);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
            wasm.__wbindgen_export(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * Execute a SPARQL UPDATE (INSERT DATA, DELETE DATA, INSERT/DELETE WHERE,
     * CLEAR, DROP). Returns the number of triples affected.
     * @param {string} sparql
     * @returns {number}
     */
    update(sparql) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(sparql, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.oxirsstore_update(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return r0 >>> 0;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
}
if (Symbol.dispose) OxiRSStore.prototype[Symbol.dispose] = OxiRSStore.prototype.free;

/**
 * Query result for JavaScript
 */
export class QueryResult {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        QueryResultFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_queryresult_free(ptr, 0);
    }
    /**
     * @returns {any[]}
     */
    get bindings() {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.queryresult_bindings(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var v1 = getArrayJsValueFromWasm0(r0, r1).slice();
            wasm.__wbindgen_export(r0, r1 * 4, 4);
            return v1;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * @returns {number}
     */
    get length() {
        const ret = wasm.queryresult_length(this.__wbg_ptr);
        return ret >>> 0;
    }
}
if (Symbol.dispose) QueryResult.prototype[Symbol.dispose] = QueryResult.prototype.free;

/**
 * RDF Triple representation for JavaScript
 */
export class Triple {
    static __wrap(ptr) {
        const obj = Object.create(Triple.prototype);
        obj.__wbg_ptr = ptr;
        TripleFinalization.register(obj, obj.__wbg_ptr, obj);
        return obj;
    }
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        TripleFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_triple_free(ptr, 0);
    }
    /**
     * @param {string} subject
     * @param {string} predicate
     * @param {string} object
     */
    constructor(subject, predicate, object) {
        const ptr0 = passStringToWasm0(subject, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(object, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.triple_new(ptr0, len0, ptr1, len1, ptr2, len2);
        this.__wbg_ptr = ret;
        TripleFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @returns {string}
     */
    get object() {
        let deferred1_0;
        let deferred1_1;
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.triple_object(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            deferred1_0 = r0;
            deferred1_1 = r1;
            return getStringFromWasm0(r0, r1);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
            wasm.__wbindgen_export(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * @returns {string}
     */
    get predicate() {
        let deferred1_0;
        let deferred1_1;
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.triple_predicate(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            deferred1_0 = r0;
            deferred1_1 = r1;
            return getStringFromWasm0(r0, r1);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
            wasm.__wbindgen_export(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * @returns {string}
     */
    get subject() {
        let deferred1_0;
        let deferred1_1;
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.triple_subject(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            deferred1_0 = r0;
            deferred1_1 = r1;
            return getStringFromWasm0(r0, r1);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
            wasm.__wbindgen_export(deferred1_0, deferred1_1, 1);
        }
    }
}
if (Symbol.dispose) Triple.prototype[Symbol.dispose] = Triple.prototype.free;

/**
 * A SPARQL-capable RDF store suitable for WASM binding.
 *
 * Combines a [`CompactTripleStore`] (memory-efficient storage) with a
 * [`StreamingParser`] (incremental RDF parsing) into a single convenient API.
 *
 * # Usage (Rust)
 * ```no_run
 * # use oxirs_wasm::api::wasm_api::WasmSparqlStore;
 * let mut store = WasmSparqlStore::new();
 * let count = store.load_ntriples("<http://s> <http://p> <http://o> .\n").expect("should succeed");
 * assert_eq!(count, 1);
 *
 * let results = store.query_pattern(Some("<http://s>"), None, None);
 * assert_eq!(results.len(), 1);
 * ```
 */
export class WasmSparqlStore {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        WasmSparqlStoreFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_wasmsparqlstore_free(ptr, 0);
    }
    /**
     * Begin a streaming load session. `format` is one of `"turtle"`,
     * `"ntriples"`, or `"nquads"` (case-insensitive).
     * @param {string} format
     */
    beginStreaming(format) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(format, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.wasmsparqlstore_beginStreaming(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            if (r1) {
                throw takeObject(r0);
            }
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Create a new empty store. JavaScript: `new WasmSparqlStore()`.
     */
    constructor() {
        const ret = wasm.wasmsparqlstore_create();
        this.__wbg_ptr = ret;
        WasmSparqlStoreFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * Delete a triple. Returns `true` if it existed and was deleted.
     * @param {string} subject
     * @param {string} predicate
     * @param {string} object
     * @returns {boolean}
     */
    deleteTriple(subject, predicate, object) {
        const ptr0 = passStringToWasm0(subject, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(object, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.wasmsparqlstore_deleteTriple(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2);
        return ret !== 0;
    }
    /**
     * Feed a chunk of RDF data in the current streaming session. Returns the
     * number of triples parsed from complete statements in this chunk.
     * @param {string} chunk
     * @returns {number}
     */
    feedChunk(chunk) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(chunk, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.wasmsparqlstore_feedChunk(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return r0 >>> 0;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Find all triples with the given predicate.
     * @param {string} predicate
     * @returns {any}
     */
    findByPredicate(predicate) {
        const ptr0 = passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmsparqlstore_findByPredicate(this.__wbg_ptr, ptr0, len0);
        return takeObject(ret);
    }
    /**
     * Find all triples with the given subject.
     * @param {string} subject
     * @returns {any}
     */
    findBySubject(subject) {
        const ptr0 = passStringToWasm0(subject, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmsparqlstore_findBySubject(this.__wbg_ptr, ptr0, len0);
        return takeObject(ret);
    }
    /**
     * Find all subjects that have a specific predicate-object pair.
     * @param {string} predicate
     * @param {string} object
     * @returns {string[]}
     */
    findSubjectsByPredicateObject(predicate, object) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            const ptr1 = passStringToWasm0(object, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len1 = WASM_VECTOR_LEN;
            wasm.wasmsparqlstore_findSubjectsByPredicateObject(retptr, this.__wbg_ptr, ptr0, len0, ptr1, len1);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var v3 = getArrayJsValueFromWasm0(r0, r1).slice();
            wasm.__wbindgen_export(r0, r1 * 4, 4);
            return v3;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Finish the current streaming session. Returns the total number of
     * triples inserted during the session.
     * @returns {number}
     */
    finishLoading() {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.wasmsparqlstore_finishLoading(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return r0 >>> 0;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Insert a single triple (terms in N-Triples serialization format).
     * @param {string} subject
     * @param {string} predicate
     * @param {string} object
     */
    insertTriple(subject, predicate, object) {
        const ptr0 = passStringToWasm0(subject, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(object, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len2 = WASM_VECTOR_LEN;
        wasm.wasmsparqlstore_insertTriple(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2);
    }
    /**
     * Load a complete N-Quads document (graph names are ignored for storage).
     * Returns the number of triples inserted.
     * @param {string} data
     * @returns {number}
     */
    loadNQuads(data) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(data, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.wasmsparqlstore_loadNQuads(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return r0 >>> 0;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Load a complete N-Triples document. Returns the number of triples inserted.
     * @param {string} data
     * @returns {number}
     */
    loadNTriples(data) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(data, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.wasmsparqlstore_loadNTriples(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return r0 >>> 0;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Load a complete Turtle document. Returns the number of triples inserted.
     * @param {string} data
     * @returns {number}
     */
    loadTurtle(data) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passStringToWasm0(data, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
            const len0 = WASM_VECTOR_LEN;
            wasm.wasmsparqlstore_loadTurtle(retptr, this.__wbg_ptr, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
            if (r2) {
                throw takeObject(r1);
            }
            return r0 >>> 0;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    /**
     * Estimated memory usage in bytes (triples + dictionary).
     * @returns {number}
     */
    memoryBytes() {
        const ret = wasm.wasmsparqlstore_memoryBytes(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * Execute a triple pattern query. Each argument is an optional
     * N-Triples-serialized term filter (`null`/`undefined` = wildcard).
     * Returns a JS array of `[subject, predicate, object]` arrays.
     * @param {string | null} [subject]
     * @param {string | null} [predicate]
     * @param {string | null} [object]
     * @returns {any}
     */
    queryPattern(subject, predicate, object) {
        var ptr0 = isLikeNone(subject) ? 0 : passStringToWasm0(subject, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        var len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(predicate) ? 0 : passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        var len1 = WASM_VECTOR_LEN;
        var ptr2 = isLikeNone(object) ? 0 : passStringToWasm0(object, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        var len2 = WASM_VECTOR_LEN;
        const ret = wasm.wasmsparqlstore_queryPattern(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2);
        return takeObject(ret);
    }
    /**
     * The number of unique RDF terms in the dictionary.
     * @returns {number}
     */
    termCount() {
        const ret = wasm.wasmsparqlstore_termCount(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * Export all triples as N-Triples text.
     * @returns {string}
     */
    toNTriples() {
        let deferred1_0;
        let deferred1_1;
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.wasmsparqlstore_toNTriples(retptr, this.__wbg_ptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            deferred1_0 = r0;
            deferred1_1 = r1;
            return getStringFromWasm0(r0, r1);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
            wasm.__wbindgen_export(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * The number of triples currently stored.
     * @returns {number}
     */
    tripleCount() {
        const ret = wasm.wasmsparqlstore_tripleCount(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * Check whether a triple exists.
     * @param {string} subject
     * @param {string} predicate
     * @param {string} object
     * @returns {boolean}
     */
    tripleExists(subject, predicate, object) {
        const ptr0 = passStringToWasm0(subject, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(predicate, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(object, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.wasmsparqlstore_tripleExists(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2);
        return ret !== 0;
    }
}
if (Symbol.dispose) WasmSparqlStore.prototype[Symbol.dispose] = WasmSparqlStore.prototype.free;

export function init() {
    wasm.init();
}

/**
 * Log a message to the browser console
 * @param {string} message
 */
export function log(message) {
    const ptr0 = passStringToWasm0(message, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
    const len0 = WASM_VECTOR_LEN;
    wasm.log(ptr0, len0);
}

/**
 * Get OxiRS WASM version
 * @returns {string}
 */
export function version() {
    let deferred1_0;
    let deferred1_1;
    try {
        const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
        wasm.version(retptr);
        var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
        var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
        deferred1_0 = r0;
        deferred1_1 = r1;
        return getStringFromWasm0(r0, r1);
    } finally {
        wasm.__wbindgen_add_to_stack_pointer(16);
        wasm.__wbindgen_export(deferred1_0, deferred1_1, 1);
    }
}
export function __wbg___wbindgen_throw_344f42d3211c4765(arg0, arg1) {
    throw new Error(getStringFromWasm0(arg0, arg1));
}
export function __wbg_error_a6fa202b58aa1cd3(arg0, arg1) {
    let deferred0_0;
    let deferred0_1;
    try {
        deferred0_0 = arg0;
        deferred0_1 = arg1;
        console.error(getStringFromWasm0(arg0, arg1));
    } finally {
        wasm.__wbindgen_export(deferred0_0, deferred0_1, 1);
    }
}
export function __wbg_log_d267660666346fb3(arg0) {
    console.log(getObject(arg0));
}
export function __wbg_new_227d7c05414eb861() {
    const ret = new Error();
    return addHeapObject(ret);
}
export function __wbg_new_32b398fb48b6d94a() {
    const ret = new Array();
    return addHeapObject(ret);
}
export function __wbg_new_b667d279fd5aa943(arg0, arg1) {
    const ret = new Error(getStringFromWasm0(arg0, arg1));
    return addHeapObject(ret);
}
export function __wbg_new_da52cf8fe3429cb2() {
    const ret = new Object();
    return addHeapObject(ret);
}
export function __wbg_push_d2ae3af0c1217ae6(arg0, arg1) {
    const ret = getObject(arg0).push(getObject(arg1));
    return ret;
}
export function __wbg_set_8535240470bf2500() { return handleError(function (arg0, arg1, arg2) {
    const ret = Reflect.set(getObject(arg0), getObject(arg1), getObject(arg2));
    return ret;
}, arguments); }
export function __wbg_set_name_3bbc583faefa4193(arg0, arg1, arg2) {
    getObject(arg0).name = getStringFromWasm0(arg1, arg2);
}
export function __wbg_stack_3b0d974bbf31e44f(arg0, arg1) {
    const ret = getObject(arg1).stack;
    const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export3, wasm.__wbindgen_export4);
    const len1 = WASM_VECTOR_LEN;
    getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
    getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
}
export function __wbg_triple_new(arg0) {
    const ret = Triple.__wrap(arg0);
    return addHeapObject(ret);
}
export function __wbindgen_cast_0000000000000001(arg0) {
    // Cast intrinsic for `F64 -> Externref`.
    const ret = arg0;
    return addHeapObject(ret);
}
export function __wbindgen_cast_0000000000000002(arg0, arg1) {
    // Cast intrinsic for `Ref(String) -> Externref`.
    const ret = getStringFromWasm0(arg0, arg1);
    return addHeapObject(ret);
}
export function __wbindgen_object_clone_ref(arg0) {
    const ret = getObject(arg0);
    return addHeapObject(ret);
}
export function __wbindgen_object_drop_ref(arg0) {
    takeObject(arg0);
}
const OxiRSStoreFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_oxirsstore_free(ptr, 1));
const QueryResultFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_queryresult_free(ptr, 1));
const TripleFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_triple_free(ptr, 1));
const WasmSparqlStoreFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_wasmsparqlstore_free(ptr, 1));

function addHeapObject(obj) {
    if (heap_next === heap.length) heap.push(heap.length + 1);
    const idx = heap_next;
    heap_next = heap[idx];

    heap[idx] = obj;
    return idx;
}

function dropObject(idx) {
    if (idx < 1028) return;
    heap[idx] = heap_next;
    heap_next = idx;
}

function getArrayJsValueFromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    const mem = getDataViewMemory0();
    const result = [];
    for (let i = ptr; i < ptr + 4 * len; i += 4) {
        result.push(takeObject(mem.getUint32(i, true)));
    }
    return result;
}

let cachedDataViewMemory0 = null;
function getDataViewMemory0() {
    if (cachedDataViewMemory0 === null || cachedDataViewMemory0.buffer.detached === true || (cachedDataViewMemory0.buffer.detached === undefined && cachedDataViewMemory0.buffer !== wasm.memory.buffer)) {
        cachedDataViewMemory0 = new DataView(wasm.memory.buffer);
    }
    return cachedDataViewMemory0;
}

function getStringFromWasm0(ptr, len) {
    return decodeText(ptr >>> 0, len);
}

let cachedUint8ArrayMemory0 = null;
function getUint8ArrayMemory0() {
    if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
        cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
    }
    return cachedUint8ArrayMemory0;
}

function getObject(idx) { return heap[idx]; }

function handleError(f, args) {
    try {
        return f.apply(this, args);
    } catch (e) {
        wasm.__wbindgen_export2(addHeapObject(e));
    }
}

let heap = new Array(1024).fill(undefined);
heap.push(undefined, null, true, false);

let heap_next = heap.length;

function isLikeNone(x) {
    return x === undefined || x === null;
}

function passStringToWasm0(arg, malloc, realloc) {
    if (realloc === undefined) {
        const buf = cachedTextEncoder.encode(arg);
        const ptr = malloc(buf.length, 1) >>> 0;
        getUint8ArrayMemory0().subarray(ptr, ptr + buf.length).set(buf);
        WASM_VECTOR_LEN = buf.length;
        return ptr;
    }

    let len = arg.length;
    let ptr = malloc(len, 1) >>> 0;

    const mem = getUint8ArrayMemory0();

    let offset = 0;

    for (; offset < len; offset++) {
        const code = arg.charCodeAt(offset);
        if (code > 0x7F) break;
        mem[ptr + offset] = code;
    }
    if (offset !== len) {
        if (offset !== 0) {
            arg = arg.slice(offset);
        }
        ptr = realloc(ptr, len, len = offset + arg.length * 3, 1) >>> 0;
        const view = getUint8ArrayMemory0().subarray(ptr + offset, ptr + len);
        const ret = cachedTextEncoder.encodeInto(arg, view);

        offset += ret.written;
        ptr = realloc(ptr, len, offset, 1) >>> 0;
    }

    WASM_VECTOR_LEN = offset;
    return ptr;
}

function takeObject(idx) {
    const ret = getObject(idx);
    dropObject(idx);
    return ret;
}

let cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
cachedTextDecoder.decode();
const MAX_SAFARI_DECODE_BYTES = 2146435072;
let numBytesDecoded = 0;
function decodeText(ptr, len) {
    numBytesDecoded += len;
    if (numBytesDecoded >= MAX_SAFARI_DECODE_BYTES) {
        cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
        cachedTextDecoder.decode();
        numBytesDecoded = len;
    }
    return cachedTextDecoder.decode(getUint8ArrayMemory0().subarray(ptr, ptr + len));
}

const cachedTextEncoder = new TextEncoder();

if (!('encodeInto' in cachedTextEncoder)) {
    cachedTextEncoder.encodeInto = function (arg, view) {
        const buf = cachedTextEncoder.encode(arg);
        view.set(buf);
        return {
            read: arg.length,
            written: buf.length
        };
    };
}

let WASM_VECTOR_LEN = 0;


let wasm;
export function __wbg_set_wasm(val) {
    wasm = val;
}
