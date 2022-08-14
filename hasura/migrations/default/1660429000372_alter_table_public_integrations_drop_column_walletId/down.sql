alter table "public"."integrations"
  add constraint "integrations_walletId_fkey"
  foreign key (walletId)
  references "public"."wallets"
  (id) on update restrict on delete cascade;
alter table "public"."integrations" alter column "walletId" drop not null;
alter table "public"."integrations" add column "walletId" uuid;
