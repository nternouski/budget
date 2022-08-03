CREATE TABLE "public"."budgets" (
	"id" uuid NOT NULL DEFAULT gen_random_uuid(),
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"name" text NOT NULL,
	"amount" money NOT NULL,
	"color" text NOT NULL,
	"userId" text NOT NULL,
	PRIMARY KEY ("id"),
	FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON UPDATE restrict ON DELETE restrict,
	UNIQUE ("id")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;