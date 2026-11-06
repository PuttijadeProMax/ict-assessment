CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE "assessment_status" AS ENUM ('DRAFT', 'PUBLISHED', 'CLOSED');
CREATE TYPE "question_type" AS ENUM ('SHORT_TEXT', 'LONG_TEXT', 'SINGLE_CHOICE', 'MULTIPLE_CHOICE', 'RATING', 'NUMBER');
CREATE TYPE "respondent_type" AS ENUM ('INTERNAL', 'EXTERNAL');
CREATE TYPE "role_name" AS ENUM ('ADMIN', 'STAFF');
CREATE TYPE "target_group" AS ENUM ('INTERNAL', 'EXTERNAL', 'BOTH');

CREATE TABLE "assessment_categories" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "name" VARCHAR(150) NOT NULL,
  "description" TEXT,
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "assessment_categories_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "roles" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "name" "role_name" NOT NULL,
  "description" VARCHAR(255),
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "users" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "role_id" UUID NOT NULL,
  "full_name" VARCHAR(150) NOT NULL,
  "email" VARCHAR(150) NOT NULL,
  "password_hash" VARCHAR(255) NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "assessments" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "category_id" UUID NOT NULL,
  "created_by" UUID NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT,
  "target_group" "target_group" NOT NULL,
  "public_token" VARCHAR(100),
  "start_at" TIMESTAMP(6),
  "end_at" TIMESTAMP(6),
  "status" "assessment_status" NOT NULL DEFAULT 'DRAFT',
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "assessments_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "questions" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "assessment_id" UUID NOT NULL,
  "question_text" TEXT NOT NULL,
  "question_type" "question_type" NOT NULL,
  "is_required" BOOLEAN NOT NULL DEFAULT false,
  "sort_order" INTEGER NOT NULL DEFAULT 0,
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "questions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "question_options" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "question_id" UUID NOT NULL,
  "option_text" VARCHAR(255) NOT NULL,
  "score" INTEGER NOT NULL DEFAULT 0,
  "sort_order" INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT "question_options_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "responses" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "assessment_id" UUID NOT NULL,
  "respondent_type" "respondent_type" NOT NULL,
  "respondent_name" VARCHAR(150),
  "respondent_email" VARCHAR(150),
  "submitted_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "responses_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "answers" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "response_id" UUID NOT NULL,
  "question_id" UUID NOT NULL,
  "answer_text" TEXT,
  "answer_number" DECIMAL(12,2),
  CONSTRAINT "answers_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "answer_options" (
  "answer_id" UUID NOT NULL,
  "option_id" UUID NOT NULL,
  CONSTRAINT "pk_answer_options" PRIMARY KEY ("answer_id", "option_id")
);

CREATE UNIQUE INDEX "roles_name_key" ON "roles"("name");
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
CREATE INDEX "idx_users_role_id" ON "users"("role_id");
CREATE UNIQUE INDEX "assessments_public_token_key" ON "assessments"("public_token");
CREATE INDEX "idx_assessments_category_id" ON "assessments"("category_id");
CREATE INDEX "idx_assessments_created_by" ON "assessments"("created_by");
CREATE INDEX "idx_assessments_status" ON "assessments"("status");
CREATE INDEX "idx_questions_assessment_id" ON "questions"("assessment_id");
CREATE INDEX "idx_question_options_question_id" ON "question_options"("question_id");
CREATE INDEX "idx_responses_assessment_id" ON "responses"("assessment_id");
CREATE INDEX "idx_responses_submitted_at" ON "responses"("submitted_at");
CREATE INDEX "idx_answers_question_id" ON "answers"("question_id");
CREATE UNIQUE INDEX "uq_answers_response_question" ON "answers"("response_id", "question_id");

ALTER TABLE "users" ADD CONSTRAINT "fk_users_roles" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "assessments" ADD CONSTRAINT "fk_assessments_categories" FOREIGN KEY ("category_id") REFERENCES "assessment_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "assessments" ADD CONSTRAINT "fk_assessments_users" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "questions" ADD CONSTRAINT "fk_questions_assessments" FOREIGN KEY ("assessment_id") REFERENCES "assessments"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "question_options" ADD CONSTRAINT "fk_options_questions" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "responses" ADD CONSTRAINT "fk_responses_assessments" FOREIGN KEY ("assessment_id") REFERENCES "assessments"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "answers" ADD CONSTRAINT "fk_answers_questions" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "answers" ADD CONSTRAINT "fk_answers_responses" FOREIGN KEY ("response_id") REFERENCES "responses"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "answer_options" ADD CONSTRAINT "fk_answer_options_answers" FOREIGN KEY ("answer_id") REFERENCES "answers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "answer_options" ADD CONSTRAINT "fk_answer_options_options" FOREIGN KEY ("option_id") REFERENCES "question_options"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

INSERT INTO "roles" ("name", "description") VALUES
  ('ADMIN', 'System administrator'),
  ('STAFF', 'Assessment staff');
