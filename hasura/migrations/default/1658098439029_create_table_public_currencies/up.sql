CREATE TABLE "public"."currencies" (
	"id" uuid NOT NULL DEFAULT gen_random_uuid(),
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"symbol" text NOT NULL,
	"name" text NOT NULL,
	PRIMARY KEY ("id"),
	UNIQUE ("id"),
	UNIQUE ("symbol")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;