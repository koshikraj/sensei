export type LessonView = {
  position: number;
  title: string;
  format: string;
  status: "completed" | "available" | "planned" | string;
};

export type ResourceView = {
  kind: string;
  title: string;
  url: string | null;
  source: string | null;
};

export type Today = {
  topic: {
    title: string;
    module: string;
    description: string | null;
    objectives: string | null;
  } | null;
  lessons: LessonView[];
  resources: ResourceView[];
  quizStatus: string;
  topicsDone: number;
  topicsTotal: number;
  avgMastery: number;
};

export type CurriculumTopic = {
  seq: number;
  title: string;
  status: string;
  lessons: LessonView[];
};

export type CurriculumModule = {
  seq: number;
  title: string;
  topics: CurriculumTopic[];
};

export type ProgressTopic = { title: string; module: string; mastery: number; status: string };

export type ProjectItem = { moduleSeq: number; module: string; title: string; status: string };

export type NewsItem = {
  id: number;
  news_date: string;
  title: string;
  url: string;
  summary: string | null;
  source: string | null;
};
