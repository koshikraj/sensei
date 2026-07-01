-- Sensei — curriculum seed (10 weeks · 50 lessons + 10 weekly projects)
-- Run after schema.sql.

insert into topics (seq, week, module, title, format) values
-- Week 1 — LLM Foundations
(1,  1, 'LLM Foundations', 'Tokens & tokenization',                              'explainer'),
(2,  1, 'LLM Foundations', 'Context windows & next-token prediction',            'explainer'),
(3,  1, 'LLM Foundations', 'Temperature, top-p & sampling',                      'code-along'),
(4,  1, 'LLM Foundations', 'The chat API: roles & messages',                     'code-along'),
(5,  1, 'LLM Foundations', 'Streaming + token/cost accounting',                  'case-study'),
-- Week 2 — Prompt Engineering
(6,  2, 'Prompt Engineering', 'Writing clear instructions',                      'explainer'),
(7,  2, 'Prompt Engineering', 'Few-shot examples',                               'code-along'),
(8,  2, 'Prompt Engineering', 'Chain-of-thought',                                'explain-back'),
(9,  2, 'Prompt Engineering', 'Role/persona prompting + templates',              'case-study'),
(10, 2, 'Prompt Engineering', 'Structured JSON output',                          'debug'),
-- Week 3 — Embeddings & Vector Search
(11, 3, 'Embeddings & Vector Search', 'Embeddings & vectors',                    'explainer'),
(12, 3, 'Embeddings & Vector Search', 'Similarity, cosine distance & models',    'explainer'),
(13, 3, 'Embeddings & Vector Search', 'kNN search',                              'code-along'),
(14, 3, 'Embeddings & Vector Search', 'Vector DBs (pgvector/Pinecone/Chroma)',   'case-study'),
(15, 3, 'Embeddings & Vector Search', 'Metadata filtering',                      'code-along'),
-- Week 4 — RAG
(16, 4, 'RAG', 'The retrieve→augment→generate loop',                            'explainer'),
(17, 4, 'RAG', 'Chunking strategies & overlap',                                 'code-along'),
(18, 4, 'RAG', 'Hybrid search (keyword + vector)',                              'explain-back'),
(19, 4, 'RAG', 'Reranking',                                                     'case-study'),
(20, 4, 'RAG', 'Retrieval evaluation & failure modes',                          'debug'),
-- Week 5 — Agents & Tools
(21, 5, 'Agents & Tools', 'Tool / function calling',                            'explainer'),
(22, 5, 'Agents & Tools', 'Parsing tool results',                               'code-along'),
(23, 5, 'Agents & Tools', 'Agent loops (ReAct)',                                'explainer'),
(24, 5, 'Agents & Tools', 'Planning & stopping conditions',                     'explain-back'),
(25, 5, 'Agents & Tools', 'Memory: short/long-term & summarization',            'case-study'),
-- Week 6 — MCP + Evals
(26, 6, 'MCP + Evals', 'MCP concepts: servers & tools',                         'explainer'),
(27, 6, 'MCP + Evals', 'Connecting agents to real systems (MCP)',               'code-along'),
(28, 6, 'MCP + Evals', 'Why evals matter',                                      'explainer'),
(29, 6, 'MCP + Evals', 'Assertion-based evals',                                 'code-along'),
(30, 6, 'MCP + Evals', 'LLM-as-judge: rubrics, pairwise, bias',                 'case-study'),
-- Week 7 — Production: Observability, Cost, Safety
(31, 7, 'Production', 'Tracing & logging',                                      'explainer'),
(32, 7, 'Production', 'Monitoring quality drift',                               'case-study'),
(33, 7, 'Production', 'Cost & latency: caching, routing, batching',             'code-along'),
(34, 7, 'Production', 'Streaming UX',                                           'explain-back'),
(35, 7, 'Production', 'Guardrails: injection defense & PII',                    'debug'),
-- Week 8 — Advanced Techniques
(36, 8, 'Advanced Techniques', 'Advanced RAG: query rewriting & multi-hop',     'explainer'),
(37, 8, 'Advanced Techniques', 'GraphRAG & agentic RAG',                        'case-study'),
(38, 8, 'Advanced Techniques', 'Multi-agent: orchestrator/worker & handoffs',   'explainer'),
(39, 8, 'Advanced Techniques', 'Fine-tuning vs prompt vs RAG (+ LoRA)',         'explain-back'),
(40, 8, 'Advanced Techniques', 'Durable workflows: retries & human-in-loop',    'code-along'),
-- Week 9 — Ship It
(41, 9, 'Ship It', 'App architecture & the AI SDK (streaming UIs)',             'code-along'),
(42, 9, 'Ship It', 'Server/client patterns',                                    'explainer'),
(43, 9, 'Ship It', 'Deployment & infra: serverless, edge vs node, secrets',     'case-study'),
(44, 9, 'Ship It', 'Reading papers & following releases',                       'explain-back'),
(45, 9, 'Ship It', 'Benchmarks and their limits',                              'case-study'),
-- Week 10 — Capstone
(46, 10, 'Capstone', 'Capstone design',                                         'explainer'),
(47, 10, 'Capstone', 'Build day 1: RAG + data',                                 'code-along'),
(48, 10, 'Capstone', 'Build day 2: tools + agent',                              'code-along'),
(49, 10, 'Capstone', 'Build day 3: evals + UI',                                 'code-along'),
(50, 10, 'Capstone', 'Final eval, self-review & portfolio',                     'case-study')
on conflict (seq) do nothing;

insert into projects (week, title) values
(1,  'Streaming CLI chat with Claude'),
(2,  'Messy-text → structured-JSON prompt library'),
(3,  'Semantic search over your notes (pgvector)'),
(4,  '"Chat with your notes" RAG bot'),
(5,  'Weather + calendar tool-calling agent'),
(6,  'Eval suite grading the Week-4 RAG bot'),
(7,  'Add tracing + prompt caching to an earlier project'),
(8,  'Multi-agent research assistant (planner + searcher + writer)'),
(9,  'Deploy a small AI app end-to-end'),
(10, 'Capstone: full AI app (RAG + tools + evals + UI)')
on conflict (week) do nothing;

-- Initialize mastery rows for every topic
insert into mastery (topic_id)
select id from topics
on conflict (topic_id) do nothing;
