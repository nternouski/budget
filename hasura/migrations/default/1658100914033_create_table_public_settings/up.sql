CREATE TABLE "public"."settings" (
	"id" uuid NOT NULL DEFAULT gen_random_uuid(),
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"darkMode" boolean NOT NULL DEFAULT true,
	"userId" uuid NOT NULL,
	PRIMARY KEY ("id"),
	UNIQUE ("id"),
	UNIQUE ("userId")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;