export type Topic = {
  id: number;
  seq: number;
  week: number;
  module: string;
  title: string;
  format: string;
  prerequisites: string | null;
};

export type Lesson = {
  id: number;
  topic_id: number | null;
  lesson_date: string;
  format: string;
  title: string;
  content: string;
  status: string;
  note: string | null;
};

export type Quiz = {
  id: number;
  quiz_date: string;
  topic_ids: number[];
  questions: unknown;
};

export type Mastery = {
  topic_id: number;
  score: number;
  last_reviewed: string | null;
  next_review: string | null;
};

export type Project = {
  id: number;
  week: number;
  title: string;
  brief: string | null;
  solution: string | null;
  status: string;
};

export type NewsItem = {
  id: number;
  news_date: string;
  module: string | null;
  title: string;
  url: string;
  summary: string | null;
  source: string | null;
};
