"use strict";

(function () {
  function byId(id) {
    return document.getElementById(id);
  }

  function addText(parent, text) {
    var node = document.createElement("p");
    node.textContent = text;
    parent.appendChild(node);
  }

  function addResult(parent, result) {
    var item = document.createElement("li");
    var title = document.createElement("a");
    title.href = result.url || result.source_uri || "#";
    title.textContent = result.title || result.filename || result.id || "Result";
    item.appendChild(title);

    if (result.content_snippet || result.content) {
      var snippet = document.createElement("p");
      snippet.textContent = result.content_snippet || result.content;
      item.appendChild(snippet);
    }
    parent.appendChild(item);
  }

  function extractResults(payload) {
    if (Array.isArray(payload)) return payload;
    if (payload && Array.isArray(payload.hits)) return payload.hits;
    if (payload && payload.results && Array.isArray(payload.results.bindings)) {
      return payload.results.bindings.map(function (binding) {
        return {
          id: binding.id && binding.id.value,
          title: binding.title && binding.title.value,
          url: binding.url && binding.url.value,
          content: binding.content && binding.content.value
        };
      });
    }
    return [];
  }

  function searchMeilisearch(config, query, index) {
    var base = (config.url || "").replace(/\/$/, "");
    var endpoint = config.search_url || base + "/indexes/" +
      encodeURIComponent(config.index || index || "all") + "/search";
    var headers = {"Content-Type": "application/json"};
    if (config.public_api_key) {
      headers.Authorization = "Bearer " + config.public_api_key;
    }
    return fetch(endpoint, {
      method: "POST",
      headers: headers,
      body: JSON.stringify({q: query, limit: config.limit || 20})
    }).then(function (response) {
      if (!response.ok) throw new Error("Meilisearch returned " + response.status);
      return response.json();
    });
  }

  function searchOxirs(config, query, index) {
    var terms = query.trim().split(/\s+/).filter(Boolean).map(function (term) {
      var escaped = term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      return '(regex(str(?content), ' + JSON.stringify(escaped) + ', "i") || ' +
        'regex(str(?title), ' + JSON.stringify(escaped) + ', "i"))';
    });
    var graph = config.graph || config.index || index || "all";
    var namespace = "http://westurner.github.io/sustainablefactory/docindex/#";
    var queryText = "PREFIX docindex: <" + namespace + ">\n" +
      "SELECT ?id ?title ?url ?content WHERE { GRAPH <" +
      "http://westurner.github.io/sustainablefactory/docindex/graph/" + graph +
      "> { ?subject docindex:id ?id ; docindex:title ?title ; " +
      "docindex:content ?content . OPTIONAL { ?subject docindex:url ?url } " +
      (terms.length ? "FILTER (" + terms.join(" && ") + ") " : "") +
      "} } LIMIT " + (config.limit || 20);
    var body = new URLSearchParams({query: queryText});
    return fetch(config.query_url || config.url, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        Accept: "application/sparql-results+json"
      },
      body: body
    }).then(function (response) {
      if (!response.ok) throw new Error("OxiRS returned " + response.status);
      return response.json();
    });
  }

  var wasmStorePromise;

  function getWasmStore(config) {
    if (!wasmStorePromise) {
      var moduleUrl = config.wasm_module || "_static/oxirs_wasm.js";
      var hdtUrl = config.hdt_enabled && config.hdt_module ? config.hdt_module : "";
      wasmStorePromise = (hdtUrl ? import(hdtUrl) : Promise.resolve(null)).then(function (hdt) {
        if (hdt && typeof hdt.loadHDT === "function") {
          return hdt.loadHDT(config.static_hdt || "_static/docindex.hdt");
        }
        return import(moduleUrl);
      }).then(function (module) {
        if (module && typeof module.query === "function") return module;
        return Promise.resolve(module.init()).then(function () {
          return fetch(config.static_data || "_static/docindex.nt")
            .then(function (response) {
              if (!response.ok) throw new Error("Static OxiRS data returned " + response.status);
              return response.text();
            })
            .then(function (data) {
              var store = new module.OxiRSStore();
              store.loadNTriples(data);
              return store;
            });
        });
      });
    }
    return wasmStorePromise;
  }

  function searchOxirsWasm(config, query, index) {
    var namespace = "http://westurner.github.io/sustainablefactory/docindex/#";
    var terms = query.trim().split(/\s+/).filter(Boolean).map(function (term) {
      var escaped = term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      return '(regex(str(?content), ' + JSON.stringify(escaped) + ', "i") || ' +
        'regex(str(?title), ' + JSON.stringify(escaped) + ', "i"))';
    });
    var sparql = "PREFIX docindex: <" + namespace + "> SELECT ?id ?title ?url ?content WHERE { " +
      "?subject docindex:id ?id ; docindex:title ?title ; docindex:content ?content . " +
      "OPTIONAL { ?subject docindex:url ?url } FILTER (" + terms.join(" && ") + ") } LIMIT " +
      (config.limit || 20);
    return getWasmStore(config).then(function (store) {
      return {results: {bindings: store.query(sparql).map(function (row) {
        return Object.keys(row).reduce(function (binding, key) {
          binding[key] = {value: row[key]};
          return binding;
        }, {});
      })}};
    });
  }

  function searchBackend(name, config, query, index) {
    if (name === "oxirs-wasm") return searchOxirsWasm(config, query, index);
    if (name === "meilisearch") return searchMeilisearch(config, query, index);
    if (name === "oxirs") return searchOxirs(config, query, index);
    return Promise.reject(new Error("Unsupported docindex backend: " + name));
  }

  function runSearch(event) {
    event.preventDefault();
    var form = event.currentTarget;
    var query = form.elements.docindex_q.value.trim();
    var output = byId("docindex-search-results");
    var config = window.DOCINDEX_SEARCH_CONFIG || {};
    var docindex = config.docindex || {};
    output.replaceChildren();
    if (!query) return;
    if (!docindex.enabled) {
      addText(output, "DocIndex search is disabled.");
      return;
    }

    var backends = [];
    if (docindex.oxirs && docindex.oxirs.enabled) {
      backends.push("oxirs-wasm");
      if (docindex.oxirs.query_url || docindex.oxirs.url) backends.push("oxirs");
    }
    if (docindex.meilisearch && docindex.meilisearch.enabled && docindex.meilisearch.url) {
      backends.push("meilisearch");
    }
    if (!backends.length) {
      addText(output, "No DocIndex backend is configured.");
      return;
    }

    Promise.all(backends.map(function (name) {
      return searchBackend(name, docindex[name], query, docindex.index)
        .then(function (payload) {
          return {name: name, results: extractResults(payload)};
        });
    })).then(function (groups) {
      groups.forEach(function (group) {
        var heading = document.createElement("h3");
        heading.textContent = group.name === "oxirs-wasm" ? "DocIndex: OxiRS WASM" :
          (group.name === "oxirs" ? "DocIndex: OxiRS URL" : "DocIndex: Meilisearch");
        output.appendChild(heading);
        var list = document.createElement("ul");
        group.results.forEach(function (result) { addResult(list, result); });
        if (!group.results.length) addText(output, "No results.");
        else output.appendChild(list);
      });
    }).catch(function (error) {
      addText(output, "DocIndex search failed: " + error.message);
    });
  }

  function initialize() {
    var form = byId("docindex-search-form");
    if (!form) return;
    form.addEventListener("submit", runSearch);

    var query = new URLSearchParams(window.location.search).get("docindex_q") || "";
    var input = byId("docindex-search-query");
    input.value = query;
    if (query) form.dispatchEvent(new Event("submit", {cancelable: true}));
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initialize);
  } else {
    initialize();
  }
}());
