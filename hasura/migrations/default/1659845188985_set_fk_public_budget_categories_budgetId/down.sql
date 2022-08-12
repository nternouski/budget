alter table "public"."budget_categories" drop constraint "budget_categories_budgetId_fkey",
  add constraint "budget_categories_budgetId_fkey"
  foreign key ("budgetId")
  references "public"."budgets"
  ("id") on update restrict on delete restrict;
