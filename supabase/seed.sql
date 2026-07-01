-- Sensei — curriculum seed (v2): 10 modules · 20 topics · ~51 lessons · 10 projects
-- Run after schema.sql. Idempotent-ish for a fresh (migrated) database.

-- ── Modules ──────────────────────────────────────────────────────────────────
insert into modules (seq, slug, title, description) values
(1,  'llm-foundations',   'LLM Foundations',            'How language models actually work.'),
(2,  'prompt-engineering','Prompt Engineering',         'Getting reliable output from a model.'),
(3,  'embeddings',        'Embeddings & Vector Search', 'Turning meaning into vectors and searching it.'),
(4,  'rag',               'RAG',                        'Grounding answers in your own data.'),
(5,  'agents',            'Agents & Tools',             'Letting models take actions.'),
(6,  'mcp-evals',         'MCP + Evals',                'Connecting to real systems and measuring quality.'),
(7,  'production',        'Production',                 'Observability, cost, and safety.'),
(8,  'advanced',          'Advanced Techniques',        'Advanced RAG, multi-agent, and adaptation.'),
(9,  'ship-it',           'Ship It',                    'Building, deploying, and keeping current.'),
(10, 'capstone',          'Capstone',                   'Design, build, and present a real AI feature.')
on conflict (seq) do nothing;

-- ── Topics (with descriptions) ───────────────────────────────────────────────
insert into topics (seq, module_id, title, description)
select x.seq, m.id, x.title, x.description
from (values
  (1,  1,  'How LLMs work',              'What a language model is, and how it turns text into tokens and predictions.'),
  (2,  1,  'Calling models via API',     'Talk to a model from code: messages, roles, streaming, and cost.'),
  (3,  2,  'Prompt fundamentals',        'The building blocks of a good prompt.'),
  (4,  2,  'Reliable output',            'Get consistent, structured results you can build on.'),
  (5,  3,  'Embeddings',                 'Turning meaning into vectors.'),
  (6,  3,  'Vector search',              'Finding the nearest meaning at scale.'),
  (7,  4,  'RAG basics',                 'Ground answers in your own documents.'),
  (8,  4,  'Better RAG',                 'Make retrieval accurate and trustworthy.'),
  (9,  5,  'Tool use',                   'Let a model call your functions.'),
  (10, 5,  'Agent loops',                'From single calls to multi-step agents.'),
  (11, 6,  'MCP',                        'Connect agents to real systems with the Model Context Protocol.'),
  (12, 6,  'Evals',                      'Measure and trust your model''s output.'),
  (13, 7,  'Observability & cost',       'Run models efficiently and watch quality.'),
  (14, 7,  'Safety',                     'Ship responsibly with guardrails.'),
  (15, 8,  'Advanced RAG & multi-agent', 'Beyond basic retrieval and single agents.'),
  (16, 8,  'Adaptation & workflows',     'When to train, and how to run durable pipelines.'),
  (17, 9,  'Building & deploying',       'Take an AI feature to production.'),
  (18, 9,  'Staying current',            'Keep up with a fast-moving field.'),
  (19, 10, 'Plan & build',               'Design and build your capstone.'),
  (20, 10, 'Finish & present',           'Evaluate, polish, and show it off.')
) as x(seq, module_seq, title, description)
join modules m on m.seq = x.module_seq
on conflict (seq) do nothing;

-- ── Lessons (multiple per topic) ─────────────────────────────────────────────
insert into lessons (topic_id, position, title, format)
select t.id, x.position, x.title, x.format
from (values
  (1,1,'Tokens & tokenization','explainer'),(1,2,'Context windows & next-token prediction','explainer'),(1,3,'Temperature, top-p & sampling','code-along'),
  (2,1,'The chat API: roles & messages','code-along'),(2,2,'Streaming + token/cost accounting','case-study'),
  (3,1,'Writing clear instructions','explainer'),(3,2,'Few-shot examples','code-along'),(3,3,'Chain-of-thought','explain-back'),
  (4,1,'Role/persona prompting + templates','case-study'),(4,2,'Structured JSON output','debug'),
  (5,1,'Embeddings & vectors','explainer'),(5,2,'Similarity, cosine distance & models','explainer'),
  (6,1,'kNN search','code-along'),(6,2,'Vector DBs (pgvector/Pinecone/Chroma)','case-study'),(6,3,'Metadata filtering','code-along'),
  (7,1,'The retrieve→augment→generate loop','explainer'),(7,2,'Chunking strategies & overlap','code-along'),
  (8,1,'Hybrid search (keyword + vector)','explain-back'),(8,2,'Reranking','case-study'),(8,3,'Retrieval evaluation & failure modes','debug'),
  (9,1,'Tool / function calling','explainer'),(9,2,'Parsing tool results','code-along'),
  (10,1,'Agent loops (ReAct)','explainer'),(10,2,'Planning & stopping conditions','explain-back'),(10,3,'Memory: short/long-term & summarization','case-study'),
  (11,1,'MCP concepts: servers & tools','explainer'),(11,2,'Connecting agents to real systems','code-along'),
  (12,1,'Why evals matter','explainer'),(12,2,'Assertion-based evals','code-along'),(12,3,'LLM-as-judge: rubrics, pairwise, bias','case-study'),
  (13,1,'Tracing & logging','explainer'),(13,2,'Monitoring quality drift','case-study'),(13,3,'Cost & latency: caching, routing, batching','code-along'),
  (14,1,'Streaming UX','explain-back'),(14,2,'Guardrails: injection defense & PII','debug'),
  (15,1,'Advanced RAG: query rewriting & multi-hop','explainer'),(15,2,'GraphRAG & agentic RAG','case-study'),(15,3,'Multi-agent systems','explainer'),
  (16,1,'Fine-tuning vs prompt vs RAG (+ LoRA)','explain-back'),(16,2,'Durable workflows: retries & human-in-loop','code-along'),
  (17,1,'App architecture & the AI SDK','code-along'),(17,2,'Server/client patterns','explainer'),(17,3,'Deployment & infra: serverless, edge vs node','case-study'),
  (18,1,'Reading papers & following releases','explain-back'),(18,2,'Benchmarks and their limits','case-study'),
  (19,1,'Capstone design','explainer'),(19,2,'Build: RAG + data','code-along'),(19,3,'Build: tools + agent','code-along'),
  (20,1,'Build: evals + UI','code-along'),(20,2,'Final eval, self-review & portfolio','case-study')
) as x(topic_seq, position, title, format)
join topics t on t.seq = x.topic_seq
on conflict (topic_id, position) do nothing;

-- ── Projects (one per module) ────────────────────────────────────────────────
insert into projects (module_id, title)
select m.id, x.title
from (values
  (1,  'Streaming CLI chat with Claude'),
  (2,  'Messy-text → structured-JSON prompt library'),
  (3,  'Semantic search over your notes (pgvector)'),
  (4,  '"Chat with your notes" RAG bot'),
  (5,  'Weather + calendar tool-calling agent'),
  (6,  'Eval suite grading your RAG bot'),
  (7,  'Add tracing + prompt caching to an earlier project'),
  (8,  'Multi-agent research assistant (planner + searcher + writer)'),
  (9,  'Deploy a small AI app end-to-end'),
  (10, 'Capstone: full AI app (RAG + tools + evals + UI)')
) as x(module_seq, title)
join modules m on m.seq = x.module_seq
on conflict (module_id) do nothing;

-- ── Sample resources (demonstrate the attachments layer on topic 1) ──────────
insert into resources (topic_id, kind, title, url, source)
select t.id, x.kind, x.title, x.url, x.source
from (values
  (1, 'video',   'But what is a GPT? — visual intro',        'https://www.youtube.com/watch?v=wjZofJX0v4M', '3Blue1Brown'),
  (1, 'article', 'What are tokens and how to count them',    'https://help.openai.com/en/articles/4936856', 'OpenAI')
) as x(topic_seq, kind, title, url, source)
join topics t on t.seq = x.topic_seq;

-- ── Initialize mastery per topic ─────────────────────────────────────────────
insert into mastery (topic_id) select id from topics on conflict (topic_id) do nothing;
