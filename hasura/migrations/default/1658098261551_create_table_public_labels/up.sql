CREATE TABLE "public"."labels" (
	"id" uuid NOT NULL DEFAULT gen_random_uuid(),
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"name" text NOT NULL,
	"color" text NOT NULL,
	PRIMARY KEY ("id"),
	UNIQUE ("id")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;