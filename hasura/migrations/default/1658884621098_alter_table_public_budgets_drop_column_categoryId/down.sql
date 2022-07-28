alter table "public"."budgets" alter column "categoryId" drop not null;
alter table "public"."budgets" add column "categoryId" uuid;
