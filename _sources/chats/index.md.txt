
```{index} Chats
```
(chats)=

# Chats

```{toctree}
:glob:

*.myst
```

- {ref}`tables_and_figures.md`


```{note}
These chats are transformed into Markdown and Notebooks with https://github.com/westurner/transform_md
```


## AgentSession schema

AgentSession:
- name
- description
- dateCreated
- dateUpdated
- tags


### Agent Session Formats
#### OpenInference
- basedOpenTelemetry

#### agentsview schema
- kenn-io/agentsview schema (in Go)

### Workflow
- 0. Research Question
  - "Is it possible to", "How to", "Could we/they instead"
  - list of search terms; topics
  - txt, markdown
  - formulate as a sentence or paragraph to ask a search engine / LLM
  - research capture
    - might be captured in an AgentSession or a wiki page,
    - often just an idea
- 1. Chat with agent(s), experts(s)
  - context management
    - reuse existing context
    - create new context
      - clean context
        - can attempt to verify that we haven't talked the model into an ungrounded finding
        - can attempt to verify that another finding was not simply a chance model "hallucination"
      - load the context
        - here, we intentionally bias the model response
        - read precedent information into context first
    
  - Ask question

Layout:

  - regex: data/chats/*.md
  - regex: data/chats/*.json
  - regex: data/chats/_*.md
    - tool: TODO
  - regex: data/chats/_* .md
    - tool: TODO
  - regex: data/chats/Gemini-_(\d).*
    - tool: TODO
  - regex: data/chats/gemini_google-gemini_.$(date -Is).*
    - tool: TODO
  - regex: data/chats/


## Tag Folders TODO
Each of these directories are tag folders; they contain symlinks to other chats:

```sh

  find . -type d -maxdepth 1 | sort

  find . -type l -printf '%p'$'\t''%l\n'
```

## chat index.md
We could instead create a YAML-LD metadata document which lists each chat and its metadata fields.


We could instead create a per-chat YAML-LD metadata document which lists each chat and its metadata fields; named like `.meta.yml`