CREATE TABLE "public"."users" (
	"id" text NOT NULL,
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"name" text NOT NULL,
	"email" text NOT NULL,
	"defaultCurrencyId" uuid,
	PRIMARY KEY ("id"),
	FOREIGN KEY ("defaultCurrencyId") REFERENCES "public"."currencies"("id") ON UPDATE restrict ON DELETE restrict,
	UNIQUE ("id"),
	UNIQUE ("email")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;