alter table "public"."integrations" add constraint "integrations_userId_integrationType_key" unique ("userId", "integrationType");
