CREATE TABLE "public"."wallets" (
	"id" uuid NOT NULL DEFAULT gen_random_uuid(),
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"name" text NOT NULL,
	"color" text NOT NULL,
	"icon" text NOT NULL,
	"initialAmount" money NOT NULL,
	"currencyId" uuid NOT NULL,
	"userId" text NOT NULL,
	PRIMARY KEY ("id"),
	FOREIGN KEY ("currencyId") REFERENCES "public"."currencies"("id") ON UPDATE restrict ON DELETE restrict,
	FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON UPDATE restrict ON DELETE restrict,
	UNIQUE ("id")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;