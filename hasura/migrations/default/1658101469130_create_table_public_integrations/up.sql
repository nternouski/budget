CREATE TABLE "public"."integrations" (
	"id" uuid NOT NULL DEFAULT gen_random_uuid(),
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"apiKey" text NOT NULL,
	"integrationKey" text NOT NULL,
	"userId" uuid NOT NULL,
	"walletId" uuid NOT NULL,
	PRIMARY KEY ("id"),
	FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON UPDATE restrict ON DELETE restrict,
	FOREIGN KEY ("walletId") REFERENCES "public"."wallets"("id") ON UPDATE restrict ON DELETE restrict,
	UNIQUE ("id")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;