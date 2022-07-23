CREATE TABLE "public"."categories" (
	"id" uuid NOT NULL DEFAULT gen_random_uuid(),
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"color" text NOT NULL,
	"name" text NOT NULL,
	"icon" text NOT NULL,
	PRIMARY KEY ("id"),
	UNIQUE ("id"),
	UNIQUE ("name")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;