-- Sensei — curriculum seed (v3): 10 modules · 27 topics · 78 lessons · 10 projects
-- The 2026 AI-engineer path: foundations → prompting/context → embeddings → RAG →
-- agents → frameworks/MCP → evals/observability/safety → shipping → open models/
-- fine-tuning/multimodal → capstone & career. Difficulty ramps week over week and
-- each module's project builds on the previous one.
-- Run after schema.sql (fresh DB), or after reset-curriculum.sql (existing DB).

-- ── Modules (≈ one per week) ─────────────────────────────────────────────────
insert into modules (seq, slug, title, description) values
(1,  'foundations',     'Foundations: The AI Engineer & LLMs',   'The role, the 2026 model landscape, and how LLMs actually work.'),
(2,  'prompt-context',  'Prompt & Context Engineering',          'Getting reliable output and controlling everything the model sees.'),
(3,  'embeddings',      'Embeddings & Vector Search',            'Turning meaning into vectors and searching it at scale.'),
(4,  'rag',             'RAG: Basics to Production',             'Grounding answers in your own data — accurately and with citations.'),
(5,  'agents',          'Tool Use & Agents',                     'Letting models take actions and run multi-step loops with memory.'),
(6,  'frameworks-mcp',  'Agent Frameworks, MCP & Multi-Agent',   'Frameworks, the Model Context Protocol, and orchestrating agent teams.'),
(7,  'quality',         'Evals, Observability & Safety',         'Measuring, tracing, and guarding AI systems in production.'),
(8,  'shipping',        'Shipping: APIs & Deployment',           'FastAPI backends, deployment, and AI-assisted development.'),
(9,  'specialization',  'Open Models, Fine-Tuning & Multimodal', 'Local inference, LoRA adaptation, and vision + voice.'),
(10, 'capstone-career', 'Capstone & Career',                     'AI system design, interview prep, and a portfolio capstone.')
on conflict (seq) do nothing;

-- ── Topics ───────────────────────────────────────────────────────────────────
insert into topics (seq, module_id, title, description, objectives)
select x.seq, m.id, x.title, x.description, x.objectives
from (values
  (1,  1,  'The AI engineer role & model landscape', 'What AI engineers do, and the closed/open model + platform landscape in 2026.',
           'Distinguish AI vs ML engineering; compare closed (GPT, Claude, Gemini) and open (Llama, Qwen, DeepSeek) models; know the key platforms (Hugging Face, OpenRouter, Ollama, gateways).'),
  (2,  1,  'How LLMs actually work', 'Tokens, context windows, next-token prediction, and sampling.',
           'Explain tokenization and context limits; describe why LLMs hallucinate; control output with temperature, top-p/top-k and penalties.'),
  (3,  1,  'Calling models from code', 'Talk to models via API: messages, roles, streaming, cost, and multi-provider code.',
           'Use a chat API with system/user/assistant roles; stream responses; account for tokens and cost; write provider-agnostic code.'),
  (4,  2,  'Prompt fundamentals', 'The building blocks of a good prompt.',
           'Write clear instructions; use zero-shot and few-shot; know when chain-of-thought helps and when reasoning models make it redundant.'),
  (5,  2,  'Reliable, structured output', 'Consistent, machine-readable results you can build a product on.',
           'Enforce JSON schemas with structured outputs; use prompt caching; catch prompt regressions with tests.'),
  (6,  2,  'Context engineering', 'Managing everything the model sees: write, select, compress, isolate.',
           'Apply the four context moves; design session memory and compaction; inject knowledge dynamically.'),
  (7,  3,  'Embeddings', 'Turning meaning into vectors.',
           'Explain embeddings and cosine similarity; pick an embedding model; apply embeddings beyond search (classification, clustering, recommendations).'),
  (8,  3,  'Vector databases & search', 'Finding the nearest meaning at scale with ANN indexes.',
           'Explain kNN vs ANN and HNSW; use pgvector/Chroma/Qdrant; combine metadata filtering with hybrid keyword+vector search.'),
  (9,  4,  'RAG fundamentals', 'Ground answers in your own documents.',
           'Build the retrieve→augment→generate loop; choose chunking strategies; produce answers with citations.'),
  (10, 4,  'Production RAG', 'Make retrieval accurate, measurable, and trustworthy.',
           'Apply query rewriting and reranking; evaluate faithfulness and relevance RAGAS-style; mitigate hallucination and debug retrieval failures.'),
  (11, 5,  'Tool calling', 'Let a model call your functions.',
           'Define tool schemas; run the tool-use loop; parse results and handle errors and retries.'),
  (12, 5,  'Agent loops', 'From single calls to multi-step agents.',
           'Implement ReAct / plan-and-execute; set stopping conditions and budgets; recognize and fix agent failure modes.'),
  (13, 5,  'Agent memory', 'Short-term and long-term memory for agents.',
           'Design short vs long-term memory; implement compaction; back memory with retrieval.'),
  (14, 6,  'Agent frameworks', 'The 2026 framework landscape and when to use one.',
           'Compare LangGraph, OpenAI Agents SDK, and Claude Agent SDK; build the same agent in two of them; judge when no framework is best.'),
  (15, 6,  'Model Context Protocol (MCP)', 'The standard for connecting agents to real systems.',
           'Explain hosts/clients/servers and transports; build an MCP server with tools and resources; reason about MCP security and trust boundaries.'),
  (16, 6,  'Multi-agent systems', 'Orchestrators, sub-agents, and handoffs.',
           'Design orchestrator + sub-agent architectures with context isolation; judge when multi-agent pays for itself.'),
  (17, 7,  'Evals', 'Evals are the unit tests of AI engineering.',
           'Build golden datasets and assertion-based evals; use LLM-as-judge with rubrics while controlling bias; run evals in CI and grow them from production failures.'),
  (18, 7,  'Observability', 'Tracing, cost, and quality monitoring for LLM apps.',
           'Trace prompts, tools and retrieval with Langfuse/LangSmith; engineer cost and latency (caching, routing, batching); watch for quality drift.'),
  (19, 7,  'Safety & guardrails', 'Ship responsibly: injection defense, validation, and responsible AI.',
           'Attack and defend against prompt injection and jailbreaks; add input/output guardrails and PII handling; apply responsible-AI practices.'),
  (20, 8,  'AI backends', 'FastAPI + async Python for LLM products.',
           'Build async FastAPI services; stream over SSE/WebSockets; add auth, rate limiting, and durable background jobs.'),
  (21, 8,  'Deployment & infra', 'Take an AI feature to production.',
           'Containerize with Docker; choose serverless vs containers; version prompts like code and roll out with canaries.'),
  (22, 8,  'AI-assisted engineering', 'Using coding agents well is now a core skill.',
           'Work effectively with Claude Code/Cursor: specs, skills, review discipline, and knowing what not to delegate.'),
  (23, 9,  'Open models & local inference', 'Running open-weight models yourself.',
           'Run models with Ollama locally and vLLM for serving; understand quantization (GGUF, 4-bit) trade-offs.'),
  (24, 9,  'Fine-tuning & adaptation', 'When (and when not) to fine-tune, and how with LoRA/QLoRA.',
           'Apply the prompt vs RAG vs fine-tune decision tree; prepare a dataset and train a LoRA; evaluate a fine-tune honestly against prompting.'),
  (25, 9,  'Multimodal & voice', 'Vision, speech, and generation in real products.',
           'Use vision inputs for documents and screenshots; build STT/TTS and realtime speech-to-speech voice agents; use image/video generation APIs.'),
  (26, 10, 'AI system design & interviews', 'Design AI systems on a whiteboard and tell the story of your work.',
           'Design RAG/agent systems end-to-end; revise Python and SQL for interviews; polish resume and GitHub portfolio around your projects.'),
  (27, 10, 'Capstone', 'Design, build, evaluate, and present a complete AI product.',
           'Scope and document an architecture; build agentic RAG with tools and guardrails; present eval results and cost analysis.')
) as x(seq, module_seq, title, description, objectives)
join modules m on m.seq = x.module_seq
on conflict (seq) do nothing;

-- ── Lessons ──────────────────────────────────────────────────────────────────
insert into lessons (topic_id, position, title, format)
select t.id, x.position, x.title, x.format
from (values
  -- Week 1 · Foundations
  (1,1,'What an AI engineer is (vs ML engineer) & career paths','explainer'),
  (1,2,'The 2026 model landscape: closed vs open models','case-study'),
  (1,3,'Platforms & ecosystem: Hugging Face, OpenRouter, Ollama, gateways','explainer'),
  (2,1,'Tokens, tokenization & context windows','explainer'),
  (2,2,'Next-token prediction, attention & why LLMs hallucinate','explain-back'),
  (2,3,'Sampling: temperature, top-p/top-k, repetition penalties','code-along'),
  (3,1,'The chat API: messages, roles, system prompts','code-along'),
  (3,2,'Streaming responses & token/cost accounting','code-along'),
  (3,3,'Multi-provider code: OpenAI-compatible APIs & gateway routing','case-study'),
  -- Week 2 · Prompt & Context Engineering
  (4,1,'Clear instructions, zero-shot & few-shot','code-along'),
  (4,2,'Chain-of-thought & reasoning models','explain-back'),
  (4,3,'Role/system prompting & prompt templates','case-study'),
  (5,1,'Structured outputs & JSON schema enforcement','code-along'),
  (5,2,'Prompt caching & long-prompt economics','explainer'),
  (5,3,'Debugging flaky prompts: prompt regression testing','debug'),
  (6,1,'The four moves: write, select, compress, isolate','explainer'),
  (6,2,'Session memory, compaction & summarization','code-along'),
  (6,3,'Knowledge injection & dynamic context composition','case-study'),
  -- Week 3 · Embeddings & Vector Search
  (7,1,'What embeddings are: meaning as vectors','explainer'),
  (7,2,'Similarity, cosine distance & choosing an embedding model','code-along'),
  (7,3,'Beyond search: classification, clustering, recommendations','case-study'),
  (8,1,'kNN vs ANN: how HNSW indexing works','explainer'),
  (8,2,'Vector DBs hands-on: pgvector, Chroma, Qdrant','code-along'),
  (8,3,'Metadata filtering & hybrid (keyword + vector) search','code-along'),
  -- Week 4 · RAG
  (9,1,'The retrieve→augment→generate loop & RAG vs fine-tuning','explainer'),
  (9,2,'Chunking strategies: size, overlap, semantic & structural','code-along'),
  (9,3,'Grounded answers with citations','code-along'),
  (10,1,'Query rewriting, HyDE & multi-query retrieval','explainer'),
  (10,2,'Reranking & hybrid retrieval','code-along'),
  (10,3,'RAG evaluation: faithfulness, relevance & hallucination mitigation','case-study'),
  (10,4,'Debugging retrieval failure modes','debug'),
  -- Week 5 · Tool Use & Agents
  (11,1,'Function/tool calling: schemas & the tool-use loop','explainer'),
  (11,2,'Executing tools, parsing results, errors & retries','code-along'),
  (12,1,'From workflows to agents: ReAct & plan-and-execute','explainer'),
  (12,2,'Stopping conditions, reflection & self-correction','explain-back'),
  (12,3,'Agent failure modes: loops, tool-thrashing, runaway cost','debug'),
  (13,1,'Short-term vs long-term memory design','explainer'),
  (13,2,'Compaction, external memory stores & retrieval-backed memory','code-along'),
  -- Week 6 · Frameworks, MCP & Multi-Agent
  (14,1,'The 2026 framework landscape: LangGraph, OpenAI Agents SDK, Claude Agent SDK','case-study'),
  (14,2,'Build the same agent twice: LangGraph vs an SDK','code-along'),
  (14,3,'When to skip frameworks entirely','explain-back'),
  (15,1,'MCP architecture: hosts, clients, servers, transports','explainer'),
  (15,2,'Building your own MCP server (tools + resources)','code-along'),
  (15,3,'MCP security: injection via tools, permissions, trust boundaries','case-study'),
  (16,1,'Orchestrator + sub-agents, handoffs & context isolation','explainer'),
  (16,2,'When multi-agent helps (and when it just costs more)','case-study'),
  -- Week 7 · Evals, Observability & Safety
  (17,1,'Evals are unit tests: golden datasets & assertion-based evals','code-along'),
  (17,2,'LLM-as-judge: rubrics, pairwise comparison, judge bias','case-study'),
  (17,3,'Evals in CI + turning production failures into eval cases','code-along'),
  (18,1,'Tracing LLM apps: spans across prompts, tools & retrieval','code-along'),
  (18,2,'Cost & latency engineering: caching, routing, batching, tiering','explainer'),
  (18,3,'Monitoring quality drift in production','case-study'),
  (19,1,'Prompt injection & jailbreaks: attack and defend your own bot','debug'),
  (19,2,'Guardrails: input/output validation, PII handling, moderation','code-along'),
  (19,3,'Responsible AI: bias, disclosure, human-in-the-loop','explain-back'),
  -- Week 8 · Shipping
  (20,1,'FastAPI + async Python for LLM apps','code-along'),
  (20,2,'Streaming endpoints (SSE/WebSockets) & durable background jobs','code-along'),
  (20,3,'Auth, rate limiting & API design for AI products','explainer'),
  (21,1,'Docker for AI apps & environment management','code-along'),
  (21,2,'Deployment targets: serverless vs containers; gateways & failover','case-study'),
  (21,3,'Rollouts: feature flags, canary prompts, prompts versioned like code','explainer'),
  (22,1,'Claude Code, Cursor & agentic coding workflows','code-along'),
  (22,2,'Working with coding agents: specs, skills, review discipline','explain-back'),
  -- Week 9 · Open Models, Fine-Tuning & Multimodal
  (23,1,'Running open models: Ollama locally, vLLM for serving','code-along'),
  (23,2,'Quantization: GGUF, 4-bit, quality/VRAM trade-offs','explainer'),
  (24,1,'Prompting vs RAG vs fine-tuning: the real decision tree','explain-back'),
  (24,2,'LoRA/QLoRA hands-on: dataset prep → train → compare','code-along'),
  (24,3,'Serving adapters & evaluating a fine-tune honestly','case-study'),
  (25,1,'Vision inputs: documents, screenshots, image understanding','code-along'),
  (25,2,'Voice agents: STT/TTS pipelines vs realtime speech-to-speech','explainer'),
  (25,3,'Image & video generation APIs in products','case-study'),
  -- Week 10 · Capstone & Career
  (26,1,'AI system design: whiteboard a RAG/agent system','case-study'),
  (26,2,'Python & SQL rapid revision for AI interviews','code-along'),
  (26,3,'Mock interview: defend your architecture choices','explain-back'),
  (26,4,'Resume, GitHub portfolio & the story of your 9 projects','case-study'),
  (27,1,'Capstone design: scope, architecture doc, eval plan','explainer'),
  (27,2,'Build sprint: agentic RAG + MCP tools + guardrails','code-along'),
  (27,3,'Final eval, cost analysis, demo & self-review','case-study')
) as x(topic_seq, position, title, format)
join topics t on t.seq = x.topic_seq
on conflict (topic_id, position) do nothing;

-- ── Projects (one per module; each builds on the last) ───────────────────────
insert into projects (module_id, title, brief)
select m.id, x.title, x.brief
from (values
  (1,  'Multi-model CLI chat',
       'A streaming CLI chat that hot-swaps between Claude, GPT, and a local Ollama model, with a live token/cost meter and a sampling-parameter playground (temperature, top-p) to see their effect first-hand.'),
  (2,  'Structured-extraction pipeline',
       'Turn messy real-world text (emails, receipts, job posts) into validated JSON using structured outputs, a prompt-template library, and prompt caching — guarded by a mini regression-test suite that catches prompt regressions.'),
  (3,  'Semantic search over your notes',
       'Index your own notes in pgvector (Supabase) with metadata filtering, and run an embedding-model bake-off: measure retrieval quality across two embedding models on the same query set.'),
  (4,  'PDF chatbot with citations',
       'Chat with a folder of PDFs. Answers must cite page-level sources, refuse when retrieval confidence is weak, and pass a small faithfulness eval. Uses chunking, hybrid retrieval, and reranking.'),
  (5,  'Personal ops agent',
       'An agent with 3–4 real tools (calendar, weather, your Week-3 notes search, a to-do list) that plans multi-step tasks — with a hard budget cap, stopping conditions, and a visible reasoning trace.'),
  (6,  'MCP-powered research assistant',
       'Wrap your PDF chatbot as an MCP server (tools + resources), then build a planner→searcher→writer multi-agent team that uses it to produce a cited research brief.'),
  (7,  'Quality harness',
       'Retrofit your Week 4–6 projects with tracing (Langfuse/LangSmith), a 20-case golden dataset, an LLM-as-judge eval that runs in CI, and a prompt-injection red-team report with fixes.'),
  (8,  'Ship the PDF chatbot',
       'Production-grade API for your PDF chatbot: FastAPI with streaming and auth, a minimal web UI, Dockerized and deployed — with the Week-7 tracing and evals wired in. A real URL for your resume.'),
  (9,  'Give your bot senses',
       'Add vision (ask questions about scanned/image PDFs) and a voice interface (STT + TTS) to your deployed chatbot. Stretch: LoRA fine-tune a small open model on your Week-2 extraction task and benchmark it against prompting.'),
  (10, 'Capstone: a complete AI product',
       'Design, build, and present an AI product of your choosing: agentic RAG + tools/MCP + guardrails + evals + observability + deployed UI, with a system-design doc, eval results, and cost analysis.')
) as x(module_seq, title, brief)
join modules m on m.seq = x.module_seq
on conflict (module_id) do nothing;

-- ── Starter resources per topic ──────────────────────────────────────────────
insert into resources (topic_id, kind, title, url, source)
select t.id, x.kind, x.title, x.url, x.source
from (values
  (2,  'video',   'But what is a GPT? — visual intro',                'https://www.youtube.com/watch?v=wjZofJX0v4M', '3Blue1Brown'),
  (2,  'article', 'What are tokens and how to count them',            'https://help.openai.com/en/articles/4936856', 'OpenAI'),
  (3,  'doc',     'Claude API — getting started',                     'https://docs.anthropic.com/en/api/getting-started', 'Anthropic'),
  (3,  'doc',     'OpenAI API reference',                             'https://platform.openai.com/docs/api-reference', 'OpenAI'),
  (4,  'doc',     'Prompt engineering overview',                      'https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview', 'Anthropic'),
  (4,  'doc',     'Prompt engineering guide',                         'https://platform.openai.com/docs/guides/prompt-engineering', 'OpenAI'),
  (5,  'doc',     'Structured outputs',                               'https://platform.openai.com/docs/guides/structured-outputs', 'OpenAI'),
  (5,  'doc',     'Prompt caching',                                   'https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching', 'Anthropic'),
  (6,  'article', 'Effective context engineering for AI agents',      'https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents', 'Anthropic'),
  (6,  'article', 'Context engineering for agents',                   'https://blog.langchain.com/context-engineering-for-agents/', 'LangChain'),
  (7,  'doc',     'Embeddings guide',                                 'https://platform.openai.com/docs/guides/embeddings', 'OpenAI'),
  (7,  'link',    'MTEB embedding leaderboard',                       'https://huggingface.co/spaces/mteb/leaderboard', 'Hugging Face'),
  (8,  'code',    'pgvector',                                         'https://github.com/pgvector/pgvector', 'GitHub'),
  (8,  'doc',     'Supabase AI & vectors guide',                      'https://supabase.com/docs/guides/ai', 'Supabase'),
  (9,  'article', 'Chunking strategies for LLM applications',         'https://www.pinecone.io/learn/chunking-strategies/', 'Pinecone'),
  (9,  'article', 'Contextual retrieval',                             'https://www.anthropic.com/news/contextual-retrieval', 'Anthropic'),
  (10, 'doc',     'RAGAS documentation',                              'https://docs.ragas.io', 'RAGAS'),
  (11, 'doc',     'Tool use with Claude',                             'https://docs.anthropic.com/en/docs/build-with-claude/tool-use', 'Anthropic'),
  (12, 'article', 'Building effective agents',                        'https://www.anthropic.com/engineering/building-effective-agents', 'Anthropic'),
  (13, 'doc',     'Mem0 — memory for AI agents',                      'https://docs.mem0.ai', 'Mem0'),
  (14, 'doc',     'LangGraph documentation',                          'https://langchain-ai.github.io/langgraph/', 'LangChain'),
  (14, 'doc',     'OpenAI Agents SDK',                                'https://openai.github.io/openai-agents-python/', 'OpenAI'),
  (14, 'doc',     'Claude Agent SDK overview',                        'https://docs.anthropic.com/en/api/agent-sdk/overview', 'Anthropic'),
  (15, 'doc',     'Model Context Protocol',                           'https://modelcontextprotocol.io', 'MCP'),
  (16, 'article', 'How we built our multi-agent research system',     'https://www.anthropic.com/engineering/multi-agent-research-system', 'Anthropic'),
  (17, 'article', 'Your AI product needs evals',                      'https://hamel.dev/blog/posts/evals/', 'Hamel Husain'),
  (18, 'doc',     'Langfuse documentation',                           'https://langfuse.com/docs', 'Langfuse'),
  (19, 'link',    'OWASP Top 10 for LLM applications',                'https://genai.owasp.org/llm-top-10/', 'OWASP'),
  (20, 'doc',     'FastAPI documentation',                            'https://fastapi.tiangolo.com', 'FastAPI'),
  (21, 'doc',     'Docker — get started',                             'https://docs.docker.com/get-started/', 'Docker'),
  (22, 'doc',     'Claude Code documentation',                        'https://code.claude.com/docs', 'Anthropic'),
  (23, 'link',    'Ollama',                                           'https://ollama.com', 'Ollama'),
  (23, 'doc',     'vLLM documentation',                               'https://docs.vllm.ai', 'vLLM'),
  (24, 'doc',     'Fine-tuning LLMs guide',                           'https://unsloth.ai/docs/get-started/fine-tuning-llms-guide', 'Unsloth'),
  (24, 'doc',     'PEFT (LoRA) documentation',                        'https://huggingface.co/docs/peft', 'Hugging Face'),
  (25, 'doc',     'Vision with Claude',                               'https://docs.anthropic.com/en/docs/build-with-claude/vision', 'Anthropic'),
  (25, 'doc',     'Realtime API (speech-to-speech)',                  'https://platform.openai.com/docs/guides/realtime', 'OpenAI'),
  (26, 'link',    'AI Engineering (book) & blog',                     'https://huyenchip.com/books/', 'Chip Huyen')
) as x(topic_seq, kind, title, url, source)
join topics t on t.seq = x.topic_seq;

-- ── Initialize mastery per topic ─────────────────────────────────────────────
insert into mastery (topic_id) select id from topics on conflict (topic_id) do nothing;
